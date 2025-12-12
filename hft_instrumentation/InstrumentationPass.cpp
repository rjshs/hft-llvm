#include "llvm/Analysis/BlockFrequencyInfo.h"
#include "llvm/Analysis/BranchProbabilityInfo.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Analysis/LoopIterator.h"
#include "llvm/Analysis/LoopPass.h"
#include "llvm/IR/CFG.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/PassManager.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Transforms/Scalar/LoopPassManager.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Transforms/Utils/LoopUtils.h"

/* *******Implementation Starts Here******* */
#include "llvm/IR/IRBuilder.h"
#include "llvm/ADT/DenseSet.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/IR/Operator.h"

/* *******Implementation Starts Here******* */

// --- Small utilities ---

static inline llvm::BranchProbability FPThreshold() {
  return llvm::BranchProbability(4, 5); // 0.8
}
static const llvm::Value* stripPtrCasts(const llvm::Value *V) {
  return V->stripPointerCasts();
}
static bool samePointerSSA(const llvm::Value *A, const llvm::Value *B) {
  return stripPtrCasts(A) == stripPtrCasts(B);
}

// Conservative base extractor (helps cheap screening; not required for candidate check)
static const llvm::Value* getBasePtr(const llvm::Value *V) {
  V = stripPtrCasts(V);
  while (auto *G = llvm::dyn_cast<llvm::GEPOperator>(V)) {
    V = stripPtrCasts(G->getPointerOperand());
  }
  return V;
}

static bool isLatchOf(const llvm::Loop &L, const llvm::BasicBlock *BB) {
  llvm::SmallVector<llvm::BasicBlock*, 2> Latches;
  L.getLoopLatches(Latches);
  return llvm::is_contained(Latches, BB);
}

// Build frequent path: header -> ... -> a latch (stay inside loop; choose >=80% successor)
static std::vector<llvm::BasicBlock*>
buildFrequentPath(llvm::Loop &L, llvm::BranchProbabilityInfo &BPI) {
  using namespace llvm;
  std::vector<BasicBlock*> Path;
  BasicBlock *Cur = L.getHeader();
  if (!Cur) return {};
  Path.push_back(Cur);

  while (!isLatchOf(L, Cur)) {
    auto *TI = Cur->getTerminator();
    BasicBlock *Next = nullptr;

    if (auto *Br = dyn_cast<BranchInst>(TI)) {
      if (!Br->isConditional()) {
        BasicBlock *S = Br->getSuccessor(0);
        if (L.contains(S)) Next = S; else return {};
      } else {
        BasicBlock *S0 = Br->getSuccessor(0);
        BasicBlock *S1 = Br->getSuccessor(1);
        auto P0 = BPI.getEdgeProbability(Cur, S0);
        auto P1 = BPI.getEdgeProbability(Cur, S1);
        if (L.contains(S0) && P0 >= FPThreshold()) Next = S0;
        if (L.contains(S1) && P1 >= FPThreshold() &&
            (!Next || P1 > BPI.getEdgeProbability(Cur, Next))) Next = S1;
      }
    } else if (auto *Sw = dyn_cast<SwitchInst>(TI)) {
      for (unsigned i = 0; i < Sw->getNumSuccessors(); ++i) {
        auto *S = Sw->getSuccessor(i);
        if (!L.contains(S)) continue;
        auto P = BPI.getEdgeProbability(Cur, S);
        if (P >= FPThreshold() && (!Next || P > BPI.getEdgeProbability(Cur, Next)))
          Next = S;
      }
    }

    if (!Next) return {};       // fail cleanly; skip this loop
    Cur = Next;
    Path.push_back(Cur);
  }
  return Path;
}

static llvm::DenseSet<const llvm::BasicBlock*>
toSet(const std::vector<llvm::BasicBlock*> &v) {
  llvm::DenseSet<const llvm::BasicBlock*> S;
  for (auto *b : v) S.insert(b);
  return S;
}

// Re-materialize a *pure* pointer expression at insertion point.
// Supports GEP/bitcast/addrspacecast; will also re-load non-volatile indices if needed.
static llvm::Value*
rematerializeAddr(llvm::Value *V, llvm::IRBuilder<> &B,
                  llvm::DenseMap<llvm::Value*, llvm::Value*> &Cache) {
  using namespace llvm;
  if (auto It = Cache.find(V); It != Cache.end()) return It->second;

  if (auto *I = dyn_cast<Instruction>(V)) {
    if (auto *G = dyn_cast<GetElementPtrInst>(I)) {
      SmallVector<Value*, 4> Idxs;
      for (auto &Op : G->indices()) {
        Value *Idx = Op.get();
        if (auto *Ld = dyn_cast<LoadInst>(Idx)) {
          auto *Ptr = rematerializeAddr(Ld->getPointerOperand(), B, Cache);
          auto *NL  = B.CreateLoad(Ld->getType(), Ptr);
          NL->setAlignment(Ld->getAlign());
          NL->setAtomic(AtomicOrdering::NotAtomic);
          NL->setVolatile(false);
          Idxs.push_back(NL);
        } else {
          Idxs.push_back(Idx);
        }
      }
      auto *Base = rematerializeAddr(G->getPointerOperand(), B, Cache);
      auto *NewG = B.CreateGEP(G->getSourceElementType(), Base, Idxs, G->getName() + ".rm");
      Cache[V] = NewG; return NewG;
    } else if (auto *BC = dyn_cast<BitCastInst>(I)) {
      auto *Op0 = rematerializeAddr(BC->getOperand(0), B, Cache);
      auto *New = B.CreateBitCast(Op0, BC->getType(), BC->getName() + ".rm");
      Cache[V] = New; return New;
    } else if (auto *ASC = dyn_cast<AddrSpaceCastInst>(I)) {
      auto *Op0 = rematerializeAddr(ASC->getOperand(0), B, Cache);
      auto *New = B.CreateAddrSpaceCast(Op0, ASC->getType(), ASC->getName() + ".rm");
      Cache[V] = New; return New;
    }
    Cache[V] = V; return V; // fallback: assume dominates
  }
  Cache[V] = V; return V;   // constants/args/globals
}

// --- Hoist plan container ---

struct HoistPlan {
  llvm::LoadInst  *Original;      // load inside loop (on frequent path)
  llvm::AllocaInst *Spill;        // per-candidate spill in entry
  llvm::Value     *PreheaderAddr; // rematerialized pointer usable in preheader
  const llvm::Value *Base;        // base object (optional, for screening)
};

// --- Main per-loop transformer (correctness pass) ---

static bool processLoop(llvm::Loop &L,
                        llvm::BranchProbabilityInfo &BPI,
                        llvm::BlockFrequencyInfo &BFI,
                        llvm::LoopInfo &LI) {
  using namespace llvm;

  BasicBlock *Preheader = L.getLoopPreheader();
  if (!Preheader) return false;

  auto Path = buildFrequentPath(L, BPI);
  if (Path.empty()) return false;
  auto FP = toSet(Path);

  Function &F = *Preheader->getParent();
  BasicBlock &EntryBB = F.getEntryBlock();

  llvm::IRBuilder<> PreB(Preheader->getTerminator());

  SmallVector<HoistPlan, 8> Plans;

  // (1) Collect candidate loads ON the frequent path
  for (BasicBlock *BB : Path) {
    for (Instruction &I : *BB) {
      auto *Ld = dyn_cast<LoadInst>(&I);
      if (!Ld) continue;
      if (Ld->isVolatile() || Ld->isAtomic()) continue;

      Value *Ptr = Ld->getPointerOperand();

      // Must be almost-invariant: no store to the SAME POINTER SSA on the frequent path
      bool StoreOnFP = false;
      for (BasicBlock *B : Path) {
        for (Instruction &J : *B) {
          if (auto *St = dyn_cast<StoreInst>(&J)) {
            if (samePointerSSA(St->getPointerOperand(), Ptr)) { StoreOnFP = true; break; }
          }
        }
        if (StoreOnFP) break;
      }
      if (StoreOnFP) continue;

      // Build preheader-usable pointer expression
      DenseMap<Value*, Value*> Cache;
      Value *PrePtr = rematerializeAddr(Ptr, PreB, Cache);

      Plans.push_back({Ld, /*Spill*/nullptr, PrePtr, getBasePtr(Ptr)});
    }
  }

  if (Plans.empty()) return false;
  bool Changed = false;

  // (2) Hoist each: create aligned spill in entry, load in preheader -> store spill, rewrite original
  for (auto &P : Plans) {
    Type  *Ty  = P.Original->getType();
    Align  Aln = P.Original->getAlign();

    // Spill: aligned alloca at entry (insert at the very beginning)
    auto *Spill = new AllocaInst(Ty, /*AddrSpace*/0, /*ArraySize*/nullptr, Aln,
                                 P.Original->getName() + ".spill",
                                 &*EntryBB.getFirstInsertionPt());
    P.Spill = Spill;

    // Hoisted load in preheader (match alignment), then store to spill
    auto *Hoisted = PreB.CreateLoad(Ty, P.PreheaderAddr, P.Original->getName() + ".pre");
    Hoisted->setAlignment(Aln);
    PreB.CreateStore(Hoisted, P.Spill);

    // Replace original with reload-from-spill at the same point; erase original
    IRBuilder<> Here(P.Original);
    auto *Reload = Here.CreateLoad(Ty, P.Spill, P.Original->getName() + ".fromspill");
    Reload->setAlignment(Aln);
    P.Original->replaceAllUsesWith(Reload);
    P.Original->eraseFromParent();

    Changed = true;
  }

  // (3) Repair: on INFREQUENT paths, right AFTER any store to the SAME POINTER SSA
  for (BasicBlock *BB : L.blocks()) {
    if (FP.contains(BB)) continue; // only infrequent blocks

    for (auto It = BB->begin(); It != BB->end(); ++It) {
      if (auto *St = dyn_cast<StoreInst>(&*It)) {
        for (auto &P : Plans) {
          if (!samePointerSSA(St->getPointerOperand(), P.Original->getPointerOperand()))
            continue;

          // Insert repair immediately after this store
          auto NextIt = std::next(It);
          IRBuilder<> FixB(&*NextIt);

          DenseMap<Value*, Value*> Cache;
          Value *CurPtr = rematerializeAddr(
              const_cast<Value*>(P.Original->getPointerOperand()), FixB, Cache);

          auto *NewVal = FixB.CreateLoad(P.Spill->getAllocatedType(), CurPtr, "fplicm.fix");
          NewVal->setAlignment(P.Original->getAlign());
          FixB.CreateStore(NewVal, P.Spill);

          Changed = true;
        }
      }
    }
  }

  return Changed;
}

/* *******Implementation Ends Here******* */

using namespace llvm;

namespace {
  struct HFTInstrumentationPass : public PassInfoMixin<HFTInstrumentationPass> {

    PreservedAnalyses run(Function &F, FunctionAnalysisManager &FAM) {
      llvm::errs() << "[HFT-Inst] Function: " << F.getName() << "\n";
      return PreservedAnalyses::all();
    }
  };
}

extern "C" ::llvm::PassPluginLibraryInfo LLVM_ATTRIBUTE_WEAK llvmGetPassPluginInfo() {
  return {
    LLVM_PLUGIN_API_VERSION, "HFTInstrumentationPass", "v0.1",
    [](PassBuilder &PB) {
      PB.registerPipelineParsingCallback(
        [](StringRef Name, FunctionPassManager &FPM,
        ArrayRef<PassBuilder::PipelineElement>) {
          if(Name == "hft-inst"){
            FPM.addPass(HFTInstrumentationPass());
            return true;
          }
          return false;
        }
      );
    }
  };
}
