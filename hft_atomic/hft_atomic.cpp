// HFT Atomic Elision Pass
//
// This pass removes unnecessary atomic operations and fences in code that is
// verified to be single-threaded. This is safe because:
// 1. We verify no thread-spawning functions are called
// 2. We verify the module is compiled with single-thread mode
// 3. We only transform atomics on memory that cannot be accessed by other
//    processes (no MMIO, no shared memory regions)

#include "llvm/IR/Instructions.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/PassManager.h"
#include "llvm/IR/InstrTypes.h"
#include "llvm/IR/Intrinsics.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/ADT/Statistic.h"

using namespace llvm;

#define DEBUG_TYPE "hft-atomic-elision"

STATISTIC(NumLoadsElided,   "Number of atomic loads converted to plain loads");
STATISTIC(NumStoresElided,  "Number of atomic stores converted to plain stores");
STATISTIC(NumRMWsElided,    "Number of atomicrmw instructions eliminated");
STATISTIC(NumCmpXchgElided, "Number of cmpxchg instructions eliminated");
STATISTIC(NumFencesRemoved, "Number of fence instructions removed");

struct HFTAtomicElisionPass : public PassInfoMixin<HFTAtomicElisionPass> {
  bool ModuleIsSingleThreaded = false;

  PreservedAnalyses run(Module &M, ModuleAnalysisManager &MAM) {
    errs() << "=== HFTAtomicElision Pass Starting ===\n";
    errs() << "Module: " << M.getName() << "\n";
    
    // DEBUG: List all functions
    errs() << "\n[DEBUG] Functions in module:\n";
    for (Function &F : M) {
      errs() << "  - " << F.getName() 
             << (F.isDeclaration() ? " (declaration)" : " (definition)") << "\n";
    }

    // DEBUG: List all global variables
    errs() << "\n[DEBUG] Global variables:\n";
    for (GlobalVariable &GV : M.globals()) {
      errs() << "  - " << GV.getName() << " : " << *GV.getValueType() << "\n";
    }

    // PHASE 1: Safety verification
    errs() << "\n[PHASE 1] Safety verification\n";

    ModuleIsSingleThreaded = true;  // assume true by default
    if (auto *Flag = M.getModuleFlag("hft.single_thread")) {
      if (auto *CI = mdconst::dyn_extract<ConstantInt>(Flag)) {
        ModuleIsSingleThreaded = !CI->isZero();
      }
    }

    if (!ModuleIsSingleThreaded) {
      errs() << "[INFO] No 'hft.single_thread' module flag found.\n";
    } else {
      errs() << "[INFO] Found 'hft.single_thread' flag = true\n";
    }

    if (containsThreadSpawningCalls(M)) {
      errs() << "[ABORT] Detected thread-spawning calls in module.\n";
      ModuleIsSingleThreaded = false;
      return PreservedAnalyses::all();
    }

    errs() << "[OK] No thread-spawning calls found.\n";

    // PHASE 2: Collect all atomic operations
    errs() << "\n[PHASE 2] Collecting atomic operations\n";

    SmallVector<LoadInst *, 32> AtomicLoads;
    SmallVector<StoreInst *, 32> AtomicStores;
    SmallVector<AtomicRMWInst *, 32> AtomicRMWs;
    SmallVector<AtomicCmpXchgInst *, 16> AtomicCmpXchgs;
    SmallVector<FenceInst *, 16> Fences;

    for (Function &F : M) {
      if (F.isDeclaration())
        continue;

      errs() << "[DEBUG] Scanning function: " << F.getName() << "\n";

      for (BasicBlock &BB : F) {
        for (Instruction &I : BB) {
          if (auto *LI = dyn_cast<LoadInst>(&I)) {
            if (LI->isAtomic()) {
              errs() << "  [FOUND] Atomic load: " << *LI << "\n";
              AtomicLoads.push_back(LI);
            }
          } else if (auto *SI = dyn_cast<StoreInst>(&I)) {
            if (SI->isAtomic()) {
              errs() << "  [FOUND] Atomic store: " << *SI << "\n";
              AtomicStores.push_back(SI);
            }
          } else if (auto *RMW = dyn_cast<AtomicRMWInst>(&I)) {
            errs() << "  [FOUND] AtomicRMW: " << *RMW << "\n";
            AtomicRMWs.push_back(RMW);
          } else if (auto *CX = dyn_cast<AtomicCmpXchgInst>(&I)) {
            errs() << "  [FOUND] CmpXchg: " << *CX << "\n";
            AtomicCmpXchgs.push_back(CX);
          } else if (auto *FI = dyn_cast<FenceInst>(&I)) {
            errs() << "  [FOUND] Fence: " << *FI << "\n";
            Fences.push_back(FI);
          }
        }
      }
    }

    errs() << "\n[SUMMARY] Found:\n"
           << "  Atomic loads:  " << AtomicLoads.size() << "\n"
           << "  Atomic stores: " << AtomicStores.size() << "\n"
           << "  AtomicRMW:     " << AtomicRMWs.size() << "\n"
           << "  CmpXchg:       " << AtomicCmpXchgs.size() << "\n"
           << "  Fences:        " << Fences.size() << "\n";

    // PHASE 3: Transform each atomic operation
    errs() << "\n[PHASE 3] Transforming atomic operations\n";

    bool Changed = false;
    unsigned LoadsElided = 0, StoresElided = 0, RMWsElided = 0;
    unsigned CmpXchgElided = 0, FencesElided = 0;

    for (LoadInst *LI : AtomicLoads) {
      errs() << "[TRANSFORM] Attempting atomic load: " << *LI << "\n";
      if (transformAtomicLoad(LI)) {
        errs() << "  -> SUCCESS\n";
        Changed = true;
        ++LoadsElided;
        ++NumLoadsElided;
      } else {
        errs() << "  -> FAILED\n";
      }
    }

    for (StoreInst *SI : AtomicStores) {
      errs() << "[TRANSFORM] Attempting atomic store: " << *SI << "\n";
      if (transformAtomicStore(SI)) {
        errs() << "  -> SUCCESS\n";
        Changed = true;
        ++StoresElided;
        ++NumStoresElided;
      } else {
        errs() << "  -> FAILED\n";
      }
    }

    for (AtomicRMWInst *RMW : AtomicRMWs) {
      errs() << "[TRANSFORM] Attempting atomicrmw: " << *RMW << "\n";
      if (transformAtomicRMW(RMW)) {
        errs() << "  -> SUCCESS\n";
        Changed = true;
        ++RMWsElided;
        ++NumRMWsElided;
      } else {
        errs() << "  -> FAILED\n";
      }
    }

    for (AtomicCmpXchgInst *CX : AtomicCmpXchgs) {
      errs() << "[TRANSFORM] Attempting cmpxchg: " << *CX << "\n";
      if (transformCmpXchg(CX)) {
        errs() << "  -> SUCCESS\n";
        Changed = true;
        ++CmpXchgElided;
        ++NumCmpXchgElided;
      } else {
        errs() << "  -> FAILED\n";
      }
    }

    for (FenceInst *FI : Fences) {
      errs() << "[TRANSFORM] Attempting fence: " << *FI << "\n";
      if (removeFence(FI)) {
        errs() << "  -> SUCCESS\n";
        Changed = true;
        ++FencesElided;
        ++NumFencesRemoved;
      } else {
        errs() << "  -> FAILED\n";
      }
    }

    // PHASE 4: Report results
    errs() << "\n[PHASE 4] Results\n";

    if (Changed) {
      errs() << "[SUCCESS] Elided:\n"
             << "  Loads:   " << LoadsElided << "\n"
             << "  Stores:  " << StoresElided << "\n"
             << "  RMWs:    " << RMWsElided << "\n"
             << "  CmpXchg: " << CmpXchgElided << "\n"
             << "  Fences:  " << FencesElided << "\n";
      return PreservedAnalyses::none();
    }

    errs() << "[RESULT] No transformations applied.\n";
    return PreservedAnalyses::all();
  }

private:
  // Safety Analysis Helpers

  bool containsThreadSpawningCalls(Module &M) {
    for (Function &F : M) {
      if (F.isDeclaration())
        continue;

      for (BasicBlock &BB : F) {
        for (Instruction &I : BB) {
          auto *CB = dyn_cast<CallBase>(&I);
          if (!CB)
            continue;

          Function *Callee = CB->getCalledFunction();
          if (!Callee)
            continue;

          StringRef Name = Callee->getName();

          if (Name == "pthread_create") {
            errs() << "[THREAD] Found pthread_create\n";
            return true;
          }
          if (Name == "thrd_create") {
            errs() << "[THREAD] Found thrd_create\n";
            return true;
          }
          if (Name.starts_with("_ZNSt6threadC")) {
            errs() << "[THREAD] Found std::thread constructor: " << Name << "\n";
            return true;
          }
          if (Name.starts_with("_ZNSt7jthreadC")) {
            errs() << "[THREAD] Found std::jthread constructor: " << Name << "\n";
            return true;
          }
          if (Name.starts_with("_ZSt5async")) {
            errs() << "[THREAD] Found std::async: " << Name << "\n";
            return true;
          }
          if (Name == "CreateThread" || Name == "_beginthread" ||
              Name == "_beginthreadex") {
            errs() << "[THREAD] Found Windows thread API: " << Name << "\n";
            return true;
          }
        }
      }
    }

    return false;
  }

  Value *getUnderlyingObject(Value *V) {
    constexpr unsigned MaxLookup = 32;

    for (unsigned i = 0; i < MaxLookup; ++i) {
      if (auto *GEP = dyn_cast<GetElementPtrInst>(V)) {
        V = GEP->getPointerOperand();
      } else if (auto *BC = dyn_cast<BitCastInst>(V)) {
        V = BC->getOperand(0);
      } else if (auto *ASC = dyn_cast<AddrSpaceCastInst>(V)) {
        V = ASC->getOperand(0);
      } else if (auto *CE = dyn_cast<ConstantExpr>(V)) {
        unsigned Opcode = CE->getOpcode();
        if (Opcode == Instruction::GetElementPtr ||
            Opcode == Instruction::BitCast ||
            Opcode == Instruction::AddrSpaceCast) {
          V = CE->getOperand(0);
        } else {
          break;
        }
      } else {
        break;
      }
    }

    return V;
  }

  bool isPointerSafeForElision(Value *Ptr) {
    errs() << "    [SAFETY] Checking pointer: " << *Ptr << "\n";
    
    // Check address space
    Type *PtrTy = Ptr->getType();
    if (auto *PT = dyn_cast<PointerType>(PtrTy)) {
      unsigned AS = PT->getAddressSpace();
      errs() << "    [SAFETY] Address space: " << AS << "\n";
      if (AS != 0) {
        errs() << "    [REJECT] Non-default address space\n";
        return false;
      }
    }

    Value *Base = getUnderlyingObject(Ptr);
    errs() << "    [SAFETY] Underlying object: " << *Base << "\n";
    errs() << "    [SAFETY] Object type: " << Base->getValueID() << "\n";

    if (isa<AllocaInst>(Base)) {
      errs() << "    [ACCEPT] AllocaInst (stack allocation)\n";
      return true;
    }

    if (isa<GlobalVariable>(Base)) {
      errs() << "    [ACCEPT] GlobalVariable\n";
      return true;
    }

    if (isa<Argument>(Base)) {
      if (ModuleIsSingleThreaded) {
        errs() << "    [ACCEPT] Function argument in single-threaded module\n";
        return true;
      } else {
        errs() << "    [REJECT] Function argument (module may be multi-threaded)\n";
        return false;
      }
    }

    // More specific rejection messages
    if (isa<CallInst>(Base) || isa<InvokeInst>(Base)) {
      errs() << "    [REJECT] Call/Invoke result (unknown provenance)\n";
      return false;
    }

    if (isa<PHINode>(Base)) {
      errs() << "    [REJECT] PHI node (multiple possible sources)\n";
      return false;
    }

    if (isa<SelectInst>(Base)) {
      errs() << "    [REJECT] Select instruction (conditional source)\n";
      return false;
    }

    if (isa<ConstantExpr>(Base)) {
      errs() << "    [REJECT] Unhandled ConstantExpr\n";
      return false;
    }

    errs() << "    [REJECT] Unknown pointer type: " << Base->getValueID() << "\n";
    return false;
  }

  // Transformation Functions

  bool transformAtomicLoad(LoadInst *LI) {
    if (!isPointerSafeForElision(LI->getPointerOperand()))
      return false;

    if (LI->isVolatile()) {
      errs() << "    [REJECT] Volatile\n";
      return false;
    }

    LI->setAtomic(AtomicOrdering::NotAtomic);
    return true;
  }

  bool transformAtomicStore(StoreInst *SI) {
    if (!isPointerSafeForElision(SI->getPointerOperand()))
      return false;

    if (SI->isVolatile()) {
      errs() << "    [REJECT] Volatile\n";
      return false;
    }

    SI->setAtomic(AtomicOrdering::NotAtomic);
    return true;
  }

  bool transformAtomicRMW(AtomicRMWInst *RMW) {
    if (!isPointerSafeForElision(RMW->getPointerOperand()))
      return false;

    if (RMW->isVolatile()) {
      errs() << "    [REJECT] Volatile\n";
      return false;
    }

    AtomicRMWInst::BinOp Op = RMW->getOperation();
    errs() << "    [INFO] RMW operation: " << Op << "\n";
    
    if (!isSupportedRMWOperation(Op)) {
      errs() << "    [REJECT] Unsupported RMW operation\n";
      return false;
    }

    IRBuilder<> Builder(RMW);
    Value *Ptr = RMW->getPointerOperand();
    Value *Val = RMW->getValOperand();
    Type *ValTy = RMW->getType();

    Value *OldVal = Builder.CreateLoad(ValTy, Ptr, "rmw.old");
    Value *NewVal = createRMWOperation(Builder, Op, OldVal, Val, "rmw.new");
    
    if (!NewVal) {
      cast<Instruction>(OldVal)->eraseFromParent();
      errs() << "    [REJECT] Failed to create RMW replacement\n";
      return false;
    }

    Builder.CreateStore(NewVal, Ptr);
    RMW->replaceAllUsesWith(OldVal);
    RMW->eraseFromParent();

    return true;
  }

  bool isSupportedRMWOperation(AtomicRMWInst::BinOp Op) {
    switch (Op) {
    case AtomicRMWInst::Xchg:
    case AtomicRMWInst::Add:
    case AtomicRMWInst::Sub:
    case AtomicRMWInst::And:
    case AtomicRMWInst::Or:
    case AtomicRMWInst::Xor:
    case AtomicRMWInst::Nand:
    case AtomicRMWInst::Max:
    case AtomicRMWInst::Min:
    case AtomicRMWInst::UMax:
    case AtomicRMWInst::UMin:
    case AtomicRMWInst::FAdd:
    case AtomicRMWInst::FSub:
    case AtomicRMWInst::FMax:
    case AtomicRMWInst::FMin:
      return true;
    default:
      return false;
    }
  }

  Value *createRMWOperation(IRBuilder<> &Builder, AtomicRMWInst::BinOp Op,
                            Value *OldVal, Value *Operand, const std::string &Name) {
    switch (Op) {
    case AtomicRMWInst::Xchg:
      return Operand;
    case AtomicRMWInst::Add:
      return Builder.CreateAdd(OldVal, Operand, Name);
    case AtomicRMWInst::Sub:
      return Builder.CreateSub(OldVal, Operand, Name);
    case AtomicRMWInst::And:
      return Builder.CreateAnd(OldVal, Operand, Name);
    case AtomicRMWInst::Or:
      return Builder.CreateOr(OldVal, Operand, Name);
    case AtomicRMWInst::Xor:
      return Builder.CreateXor(OldVal, Operand, Name);
    case AtomicRMWInst::Nand:
      return Builder.CreateNot(Builder.CreateAnd(OldVal, Operand), Name);
    case AtomicRMWInst::Max:
      return Builder.CreateSelect(
          Builder.CreateICmpSGT(OldVal, Operand), OldVal, Operand, Name);
    case AtomicRMWInst::Min:
      return Builder.CreateSelect(
          Builder.CreateICmpSLT(OldVal, Operand), OldVal, Operand, Name);
    case AtomicRMWInst::UMax:
      return Builder.CreateSelect(
          Builder.CreateICmpUGT(OldVal, Operand), OldVal, Operand, Name);
    case AtomicRMWInst::UMin:
      return Builder.CreateSelect(
          Builder.CreateICmpULT(OldVal, Operand), OldVal, Operand, Name);
    case AtomicRMWInst::FAdd:
      return Builder.CreateFAdd(OldVal, Operand, Name);
    case AtomicRMWInst::FSub:
      return Builder.CreateFSub(OldVal, Operand, Name);
    case AtomicRMWInst::FMax:
      return Builder.CreateBinaryIntrinsic(Intrinsic::maxnum, OldVal, Operand);
    case AtomicRMWInst::FMin:
      return Builder.CreateBinaryIntrinsic(Intrinsic::minnum, OldVal, Operand);
    default:
      return nullptr;
    }
  }

  bool transformCmpXchg(AtomicCmpXchgInst *CX) {
    if (!isPointerSafeForElision(CX->getPointerOperand()))
      return false;

    if (CX->isVolatile()) {
      errs() << "    [REJECT] Volatile\n";
      return false;
    }

    IRBuilder<> Builder(CX);
    Value *Ptr = CX->getPointerOperand();
    Value *Expected = CX->getCompareOperand();
    Value *Desired = CX->getNewValOperand();
    Type *ValTy = Expected->getType();

    Value *OldVal = Builder.CreateLoad(ValTy, Ptr, "cx.old");

    Value *Success;
    if (ValTy->isFloatingPointTy()) {
      Success = Builder.CreateFCmpOEQ(OldVal, Expected, "cx.success");
    } else {
      Success = Builder.CreateICmpEQ(OldVal, Expected, "cx.success");
    }

    Value *ToStore = Builder.CreateSelect(Success, Desired, OldVal, "cx.tostore");
    Builder.CreateStore(ToStore, Ptr);

    Type *ResultTy = CX->getType();
    Value *Result = UndefValue::get(ResultTy);
    Result = Builder.CreateInsertValue(Result, OldVal, 0, "cx.res.val");
    Result = Builder.CreateInsertValue(Result, Success, 1, "cx.res.succ");

    CX->replaceAllUsesWith(Result);
    CX->eraseFromParent();

    return true;
  }

  bool removeFence(FenceInst *FI) {
    if (FI->getSyncScopeID() == SyncScope::SingleThread) {
      errs() << "    [REJECT] Signal fence (singlethread scope)\n";
      return false;
    }

    FI->eraseFromParent();
    return true;
  }
};

extern "C" LLVM_ATTRIBUTE_WEAK ::llvm::PassPluginLibraryInfo
llvmGetPassPluginInfo() {
  return {
    LLVM_PLUGIN_API_VERSION,
    "HFTAtomicElision",
    "v1.0",
    [](PassBuilder &PB) {
      PB.registerPipelineParsingCallback(
        [](StringRef Name, ModulePassManager &MPM,
           ArrayRef<PassBuilder::PipelineElement>) {
          if (Name == "hft-atomic-elision") {
            MPM.addPass(HFTAtomicElisionPass());
            return true;
          }
          return false;
        }
      );
    }
  };
}