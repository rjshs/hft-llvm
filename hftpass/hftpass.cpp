#include <vector>
#include <cmath>
#include <set>

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
#include "llvm/IR/GlobalVariable.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Type.h"

using namespace llvm;

using FieldWeightsTy = DenseMap<const StructType *, std::vector<uint64_t>>;

/*
  Struct Validity Checker: Only split structs that will result in performance gain
*/
static bool isCandidateStruct(const StructType *ST) {
  if (!ST->hasName()) return false;
  StringRef N = ST->getName();

  // Ideal candidate struct is main orderbook struct
  if (N.contains("LevelAnalytics")) return true;
  return false;
}

/*
  getGEPStructType - Identify whether a getelementptr is directly indexing into a struct.
*/
static const StructType *getGEPStructType(const GetElementPtrInst *GEP) {
  Type *SourceTy = GEP->getSourceElementType();
  return dyn_cast<StructType>(SourceTy);
}

/*
  Returns the constant struct field index encoded in a GEP, or nullopt if not a valid static field access.
*/
static std::optional<unsigned> getStructFieldIndex(const GetElementPtrInst *GEP) {
  // not a struct field index
  if (GEP->getNumIndices() < 2) return std::nullopt;

  // Skip the first index (the struct pointer index)
  auto IdxIt = GEP->idx_begin();
  ++IdxIt;

  // GEP::idx_iterator yields a Use& → extract Value*
  const Value *FieldIdxVal = IdxIt->get();

  if (const auto *CI = dyn_cast<ConstantInt>(FieldIdxVal)) return static_cast<unsigned>(CI->getZExtValue());

  return std::nullopt;
}

struct HFTHotColdStructSplitPass : public PassInfoMixin<HFTHotColdStructSplitPass> {
  PreservedAnalyses run(Module &M, ModuleAnalysisManager &MAM) {
    LLVMContext &Ctx = M.getContext();

    // 1. Find original OrderBookLevel struct.
    StructType *OrderBookTy = nullptr;
    for (StructType *ST : M.getIdentifiedStructTypes()) {
      if (isCandidateStruct(ST)){
        OrderBookTy = ST;
        break;
      }
    }

    if (!OrderBookTy || OrderBookTy->isOpaque()) {
      errs() << "[HFTHotColdSplit] OrderBook loc/access error\n";
      return PreservedAnalyses::all();
    }

    // 2. Compute dynamic field weights for OrderBookLevel using BFI
    FieldWeightsTy Weights;

    // Get the FunctionAnalysisManager from the ModuleAnalysisManager
    auto &FAMProxy = MAM.getResult<FunctionAnalysisManagerModuleProxy>(M);
    FunctionAnalysisManager &FAM = FAMProxy.getManager();

    for (Function &F : M) {
      if (F.isDeclaration()) continue;

      // Only focused on optimizing the hot path function
      if (!F.getName().contains("onMessage") && !F.getName().contains("onAnalyticsUpdate")) continue;

      auto &BFI = FAM.getResult<BlockFrequencyAnalysis>(F);

      for (BasicBlock &BB : F) {
        uint64_t BlockFreq = BFI.getBlockFreq(&BB).getFrequency();

        for (Instruction &I : BB) {
          auto *GEP = dyn_cast<GetElementPtrInst>(&I);
          if (!GEP) continue;

          const StructType *ST = getGEPStructType(GEP);
          if (!ST || !isCandidateStruct(ST)) continue;

          auto FieldIdxOpt = getStructFieldIndex(GEP);
          if (!FieldIdxOpt) continue;

          unsigned FieldIdx = *FieldIdxOpt;
          auto &Vec = Weights[ST];

          if (Vec.size() <= FieldIdx){
            Vec.resize(FieldIdx + 1, 0);
          }

          Vec[FieldIdx] += BlockFreq;
        }
      }
    }

    // Extract weights for OrderBook type
    auto It = Weights.find(OrderBookTy);
    if (It == Weights.end()) {
      errs() << "[HFTHotColdSplit] No dynamic field weights for OrderBookLevel; aborting.\n";
      return PreservedAnalyses::all();
    }

    const std::vector<uint64_t> &FieldW = It->second;
    
    // --- Heuristic: pick fields whose weight is >= 0.5 * max_weight ---
    uint64_t MaxW = 0;
    for (uint64_t W : FieldW)
      MaxW = std::max(MaxW, W);

    // If somehow all fields have zero weight (weird but possible), bail.
    if (MaxW == 0) {
      errs() << "[HFTHotColdSplit] All fields have zero weight; aborting.\n";
      return PreservedAnalyses::all();
    }

    double Threshold = MaxW * 0.5;  // <-- the 0.5 from the paper

    SmallVector<unsigned, 8> HotFieldIdxs, ColdFieldIdxs;

    for (unsigned i = 0; i < FieldW.size(); ++i) {
      if (FieldW[i] >= Threshold)
        HotFieldIdxs.push_back(i);
      else
        ColdFieldIdxs.push_back(i);
    }

    if (HotFieldIdxs.empty()) {
      errs() << "[HFTHotColdSplit] No hot fields found; aborting.\n";
      return PreservedAnalyses::all();
    }

    errs() << "[HFTHotColdSplit] Dynamic hot fields for " << OrderBookTy->getName() << " = {";
    for (unsigned i = 0; i < HotFieldIdxs.size(); ++i) {
      errs() << HotFieldIdxs[i];
      if (i + 1 < HotFieldIdxs.size()) errs() << ", ";
    }
    errs() << "}\n";

    // For simplicity, require that the hot set is exactly {0,1,2}.
    // if (!(HotFieldIdxs.size() == 3 &&
    //       HotFieldIdxs[0] == 0 &&
    //       HotFieldIdxs[1] == 1 &&
    //       HotFieldIdxs[2] == 2)) {
    //   errs() << "[HFTHotColdSplit] Hot fields are not exactly {0,1,2}; skipping split.\n";
    //   return PreservedAnalyses::all();
    // }

    unsigned HotFieldCount = HotFieldIdxs.size();

    // 3. Build hot/cold type layouts and index maps.
    ArrayRef<Type *> Elems = OrderBookTy->elements();
    unsigned NumFields = Elems.size();

    errs() << "[HFTHotColdSplit] Found struct type: " << OrderBookTy->getName()
          << " with " << NumFields << " fields.\n";

    if (NumFields == 0 || HotFieldCount == 0 || HotFieldCount == NumFields) {
      errs() << "[HFTHotColdSplit] Degenerate hot/cold split; aborting.\n";
      return PreservedAnalyses::all();
    }

    // Map from *original* field index → index in HotTy / ColdTy, or -1 if not there.
    SmallVector<int, 16> HotIndexMap(NumFields, -1);
    SmallVector<int, 16> ColdIndexMap(NumFields, -1);

    SmallVector<Type *, 8> HotFields;
    SmallVector<Type *, 8> ColdFields;

    for (unsigned OldIdx = 0; OldIdx < NumFields; ++OldIdx) {
      // Treat fields beyond FieldW.size() as cold (never referenced in on_message).
      uint64_t W = (OldIdx < FieldW.size()) ? FieldW[OldIdx] : 0;

      bool IsHot = (W >= Threshold);
      if (IsHot) {
        HotIndexMap[OldIdx] = (int)HotFields.size();
        HotFields.push_back(Elems[OldIdx]);
      } else {
        ColdIndexMap[OldIdx] = (int)ColdFields.size();
        ColdFields.push_back(Elems[OldIdx]);
      }
    }

    if (HotFields.empty() || ColdFields.empty()) {
      errs() << "[HFTHotColdSplit] After mapping, hot or cold set is empty; aborting.\n";
      return PreservedAnalyses::all();
    }

    std::string BaseName = std::string(OrderBookTy->getName());
    std::string HotName  = BaseName + ".hot";
    std::string ColdName = BaseName + ".cold";

    StructType *HotTy  = StructType::create(Ctx, HotFields, HotName, false);
    StructType *ColdTy = StructType::create(Ctx, ColdFields, ColdName, false);

    errs() << "[HFTHotColdSplit] Created hot struct type: " << HotTy->getName()
          << " with " << HotFields.size() << " fields.\n";
    errs() << "[HFTHotColdSplit] Created cold struct type: " << ColdTy->getName()
          << " with " << ColdFields.size() << " fields.\n";

    // Optional: print the mapping for your sanity.
    errs() << "[HFTHotColdSplit] HotIndexMap (old_index -> new_hot_index): ";
    for (unsigned i = 0; i < NumFields; ++i) {
      if (HotIndexMap[i] >= 0)
        errs() << i << "->" << HotIndexMap[i] << " ";
    }
    errs() << "\n";

    errs() << "[HFTHotColdSplit] ColdIndexMap (old_index -> new_cold_index): ";
    for (unsigned i = 0; i < NumFields; ++i) {
      if (ColdIndexMap[i] >= 0)
        errs() << i << "->" << ColdIndexMap[i] << " ";
    }
    errs() << "\n";

    // 4. Find bids / asks globals.
    GlobalVariable *BidsGV = M.getGlobalVariable("bidAnalytics", true);
    GlobalVariable *AsksGV = M.getGlobalVariable("askAnalytics", true);

    if (!BidsGV || !AsksGV) {
      errs() << "[HFTHotColdRewrite] Could not find globals 'bids' and 'asks'; aborting.\n";
      return PreservedAnalyses::all();
    }
    
    auto *BidsArrayTy = dyn_cast<ArrayType>(BidsGV->getValueType());
    auto *AsksArrayTy = dyn_cast<ArrayType>(AsksGV->getValueType());

    if (!BidsArrayTy || !AsksArrayTy) {
      errs() << "[HFTHotColdRewrite] bids/asks are not arrays; aborting.\n";
      return PreservedAnalyses::all();
    }

    if (BidsArrayTy->getElementType() != OrderBookTy || AsksArrayTy->getElementType() != OrderBookTy) {
      errs() << "[HFTHotColdRewrite] bids/asks element type mismatch; aborting.\n";
      return PreservedAnalyses::all();
    }

    uint64_t NumLevels = BidsArrayTy->getNumElements();
    if (NumLevels != AsksArrayTy->getNumElements()) {
      errs() << "[HFTHotColdRewrite] bids/asks size mismatch; aborting.\n";
      return PreservedAnalyses::all();
    }

    // 5. Create new hot/cold global arrays for bids/asks.
    ArrayType *BidsHotArrayTy  = ArrayType::get(HotTy,  NumLevels);
    ArrayType *BidsColdArrayTy = ArrayType::get(ColdTy, NumLevels);
    ArrayType *AsksHotArrayTy  = ArrayType::get(HotTy,  NumLevels);
    ArrayType *AsksColdArrayTy = ArrayType::get(ColdTy, NumLevels);

    auto *BidsHotGV = new GlobalVariable(M, BidsHotArrayTy, false, BidsGV->getLinkage(), ConstantAggregateZero::get(BidsHotArrayTy), BidsGV->getName() + ".hot");
    auto *BidsColdGV = new GlobalVariable(M, BidsColdArrayTy, false, BidsGV->getLinkage(), ConstantAggregateZero::get(BidsColdArrayTy), BidsGV->getName() + ".cold");
    auto *AsksHotGV = new GlobalVariable(M, AsksHotArrayTy, false, AsksGV->getLinkage(), ConstantAggregateZero::get(AsksHotArrayTy), AsksGV->getName() + ".hot");
    auto *AsksColdGV = new GlobalVariable(M, AsksColdArrayTy, false, AsksGV->getLinkage(), ConstantAggregateZero::get(AsksColdArrayTy), AsksGV->getName() + ".cold");

    errs() << "[HFTHotColdRewrite] Created hot/cold globals for bids/asks.\n";

    bool Changed = false;

    // 6. For each function, rewrite struct field GEPs whose base comes from orignal bids/asks array
    for (Function &F : M) {
      if (F.isDeclaration()) continue;
      SmallVector<GetElementPtrInst *, 32> FieldGEPs;

      // Collect candidate struct-field GEPs.
      for (BasicBlock &BB : F) {
        for (Instruction &I : BB) {
          auto *GEP = dyn_cast<GetElementPtrInst>(&I);
          if (!GEP) continue;

          Type *SrcTy = GEP->getSourceElementType();
          auto *ST = dyn_cast<StructType>(SrcTy);
          if (!ST || ST != OrderBookTy) continue;

          if (GEP->getNumIndices() < 2) continue;

          auto IdxIt = GEP->idx_begin();
          ++IdxIt; // skip the leading 0
          Value *FieldIdxV = IdxIt->get();
          auto *FieldCI = dyn_cast<ConstantInt>(FieldIdxV);
          if (!FieldCI) continue;

          FieldGEPs.push_back(GEP);
        }
      }

      // Rewrite each field GEP if its base struct pointer is from orignal bids/asks array
      for (GetElementPtrInst *FieldGEP : FieldGEPs) {
        auto IdxIt = FieldGEP->idx_begin();
        ++IdxIt; // skip leading 0
        Value *FieldIdxV = IdxIt->get();
        auto *FieldCI    = cast<ConstantInt>(FieldIdxV);
        unsigned FieldIdx = (unsigned)FieldCI->getZExtValue();

        Value *StructPtr = FieldGEP->getPointerOperand();

        auto *ElemGEP = dyn_cast<GetElementPtrInst>(StructPtr);
        if (!ElemGEP) continue;

        Type *ElemSrcTy = ElemGEP->getSourceElementType();
        auto *ArrTy = dyn_cast<ArrayType>(ElemSrcTy);
        if (!ArrTy || ArrTy->getElementType() != OrderBookTy) continue;

        if (ElemGEP->getNumIndices() != 2) continue;

        auto ElemIdxIt = ElemGEP->idx_begin();
        Value *Idx0 = ElemIdxIt->get(); ++ElemIdxIt;
        Value *LevelIdx = ElemIdxIt->get();

        Value *BasePtr = ElemGEP->getPointerOperand();
        bool IsBids = (BasePtr == BidsGV);
        bool IsAsks = (BasePtr == AsksGV);
        if (!IsBids && !IsAsks) continue;

        IRBuilder<> B(FieldGEP);

        GlobalVariable *HotGV  = IsBids ? BidsHotGV  : AsksHotGV;
        GlobalVariable *ColdGV = IsBids ? BidsColdGV : AsksColdGV;
        ArrayType *HotArr  = IsBids ? BidsHotArrayTy  : AsksHotArrayTy;
        ArrayType *ColdArr = IsBids ? BidsColdArrayTy : AsksColdArrayTy;

        Value *NewElemPtr;
        Value *NewFieldPtr;
        Value *ZeroI32 = ConstantInt::get(Type::getInt32Ty(Ctx), 0);

        // Map original field index to new hot/cold index.
        int NewHotIdx  = (FieldIdx < HotIndexMap.size())  ? HotIndexMap[FieldIdx]  : -1;
        int NewColdIdx = (FieldIdx < ColdIndexMap.size()) ? ColdIndexMap[FieldIdx] : -1;

        // Sanity: every field should be either hot or cold (by construction).
        if (NewHotIdx < 0 && NewColdIdx < 0) {
          errs() << "[HFTHotColdRewrite] FieldIdx " << FieldIdx
                << " not present in hot or cold maps; skipping.\n";
          continue;
        }

        if (NewHotIdx >= 0) {
          // Go through the hot array
          NewElemPtr = B.CreateGEP(
              HotArr, HotGV, {Idx0, LevelIdx},
              ElemGEP->getName() + ".hot.elem");

          Value *HotFieldCI =
              ConstantInt::get(Type::getInt32Ty(Ctx), (unsigned)NewHotIdx);

          NewFieldPtr = B.CreateGEP(
              HotTy, NewElemPtr, {ZeroI32, HotFieldCI},
              FieldGEP->getName() + ".hot");
        } else {
          // Must be cold
          unsigned ColdIdxUnsigned = (unsigned)NewColdIdx;
          NewElemPtr = B.CreateGEP(
              ColdArr, ColdGV, {Idx0, LevelIdx},
              ElemGEP->getName() + ".cold.elem");

          Value *ColdFieldCI =
              ConstantInt::get(Type::getInt32Ty(Ctx), ColdIdxUnsigned);

          NewFieldPtr = B.CreateGEP(
              ColdTy, NewElemPtr, {ZeroI32, ColdFieldCI},
              FieldGEP->getName() + ".cold");
        }

        FieldGEP->replaceAllUsesWith(NewFieldPtr);
        FieldGEP->eraseFromParent();
        Changed = true;
      }
    }

    if (Changed) {
      errs() << "[HFTHotColdRewrite] Successfully rewrote struct field accesses on bids/asks.\n";
      return PreservedAnalyses::none();
    }

    return PreservedAnalyses::all();
  }
};

struct HFTPrintPass : public PassInfoMixin<HFTPrintPass> {
  PreservedAnalyses run(Function &F, FunctionAnalysisManager &FAM) {
    size_t NumBlocks = 0;
    for (auto &BB : F) (void)BB, ++NumBlocks;
    errs() << "[HFTPrintPass] Function " << F.getName() << " has " << NumBlocks << " basic blocks\n";
    return PreservedAnalyses::all();
  }
};

struct HFTExperiment1Pass : public PassInfoMixin<HFTExperiment1Pass> {
  PreservedAnalyses run(Function &F, FunctionAnalysisManager &FAM) {
    // TODO: your real optimization code here later.
    // For now, do nothing and claim we preserved everything.
    return PreservedAnalyses::all();
  }
};

extern "C" ::llvm::PassPluginLibraryInfo LLVM_ATTRIBUTE_WEAK llvmGetPassPluginInfo() {
  return {
    LLVM_PLUGIN_API_VERSION, "HFTPasses", "v0.1",
    [](PassBuilder &PB) {
      PB.registerPipelineParsingCallback(
        [](StringRef Name, FunctionPassManager &FPM,
        ArrayRef<PassBuilder::PipelineElement>) {

          if (Name == "hft-print") {
            FPM.addPass(HFTPrintPass());
            return true;
          }
          return false;
        }
      );

      PB.registerPipelineParsingCallback(
        [](StringRef Name, ModulePassManager &MPM,
           ArrayRef<PassBuilder::PipelineElement>) {

          if (Name == "hft-split") {
            MPM.addPass(HFTHotColdStructSplitPass());
            return true;
          }
          return false;
        }
      );
    }
  };
}
