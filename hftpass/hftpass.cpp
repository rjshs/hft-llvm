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



/* *******Implementation Starts Here******* */
// You can include more Header files here
#include <vector>
#include <cmath>
#include <set>

#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Type.h"
#include "llvm/IR/Instructions.h"


/* *******Implementation Ends Here******* */

using namespace llvm;

struct HFTHotColdSplitPass : public PassInfoMixin<HFTHotColdSplitPass> {

  // Per-struct, per-field weight
  using FieldWeightsTy = DenseMap<const StructType *, std::vector<uint64_t>>;

  // Simple heuristic to decide if this struct is one of our HFT structs.
  // For your project we just check the name contains "OrderBookLevel" or
  // has an opaque name with "hft" in it. You can tighten this if needed.
  static bool isCandidateStruct(const StructType *ST) {
    if (!ST->hasName())
      return false;
    StringRef N = ST->getName();
    // Typical clang naming: "struct.OrderBookLevel" or similar.
    if (N.contains("OrderBookLevel"))
      return true;
    if (N.contains("hft_struct"))
      return true;
    return false;
  }

  static const StructType *getGEPStructType(const GetElementPtrInst *GEP) {
    Type *SourceTy = GEP->getSourceElementType();   // works on LLVM 15/16+
    return dyn_cast<StructType>(SourceTy);
  }

  static std::optional<unsigned> getStructFieldIndex(const GetElementPtrInst *GEP) {
    if (GEP->getNumIndices() < 2) return std::nullopt;

    // Skip the first index (the struct pointer index)
    auto IdxIt = GEP->idx_begin();
    ++IdxIt;

    // GEP::idx_iterator yields a Use& → extract Value*
    const Value *FieldIdxVal = IdxIt->get();

    if (const auto *CI = dyn_cast<ConstantInt>(FieldIdxVal)) return static_cast<unsigned>(CI->getZExtValue());

    return std::nullopt;
  }


  PreservedAnalyses run(Function &F, FunctionAnalysisManager &FAM) {
    // Only analyze Engine::on_message
    if (!F.getName().contains("on_message")) {
        return PreservedAnalyses::all();
    }

    errs() << "[HFTHotCold] Analyzing ONLY hot path function: " 
           << F.getName() << "\n";

    FieldWeightsTy Weights;

    auto &BFI = FAM.getResult<BlockFrequencyAnalysis>(F);

    for (BasicBlock &BB : F) {
        uint64_t BlockFreq = BFI.getBlockFreq(&BB).getFrequency();

        for (Instruction &I : BB) {
            auto *GEP = dyn_cast<GetElementPtrInst>(&I);
            if (!GEP)
                continue;

            const StructType *ST = getGEPStructType(GEP);
            if (!ST || !isCandidateStruct(ST))
                continue;

            auto FieldIdxOpt = getStructFieldIndex(GEP);
            if (!FieldIdxOpt)
                continue;

            unsigned FieldIdx = *FieldIdxOpt;

            auto &Vec = Weights[ST];
            if (Vec.size() <= FieldIdx)
                Vec.resize(FieldIdx + 1, 0);

            Vec[FieldIdx] += BlockFreq;
        }
    }

    // Classify hot/cold fields
    for (auto &Entry : Weights) {
        const StructType *ST = Entry.first;
        const std::vector<uint64_t> &FieldW = Entry.second;

        uint64_t MaxW = 0;
        double SumW = 0.0;
        for (uint64_t W : FieldW) {
            MaxW = std::max(MaxW, W);
            SumW += (double)W;
        }

        if (MaxW == 0)
            continue;

        SmallVector<unsigned, 8> HotFields, ColdFields;
        for (unsigned i = 0; i < FieldW.size(); ++i) {
            if (FieldW[i] > 0)
                HotFields.push_back(i);
            else
                ColdFields.push_back(i);
        }

        errs() << "[HFTHotCold] Struct " << ST->getName() << "\n";
        errs() << "  Field weights (on_message only): ";
        for (unsigned i = 0; i < FieldW.size(); ++i) {
            errs() << "#" << i << "=" << FieldW[i];
            if (i + 1 < FieldW.size()) errs() << ", ";
        }
        errs() << "\n";

        errs() << "  Hot fields: {";
        for (size_t i = 0; i < HotFields.size(); ++i) {
            errs() << HotFields[i];
            if (i + 1 < HotFields.size()) errs() << ", ";
        }
        errs() << "}\n";

        errs() << "  Cold fields: {";
        for (size_t i = 0; i < ColdFields.size(); ++i) {
            errs() << ColdFields[i];
            if (i + 1 < ColdFields.size()) errs() << ", ";
        }
        errs() << "}\n\n";
    }

    return PreservedAnalyses::all();
  }
};

struct HFTHotColdStructSplitPass : public PassInfoMixin<HFTHotColdStructSplitPass> {
  static constexpr unsigned HotFieldCount = 3; // fields 0,1,2 are hot

  PreservedAnalyses run(Module &M, ModuleAnalysisManager &MAM) {
    LLVMContext &Ctx = M.getContext();

    // 1. Find original OrderBookLevel struct.
    StructType *OrderBookTy = nullptr;
    for (StructType *ST : M.getIdentifiedStructTypes()) {
      if (!ST->hasName())
        continue;
      if (ST->getName().contains("OrderBookLevel")) {
        OrderBookTy = ST;
        break;
      }
    }

    if (!OrderBookTy) {
      errs() << "[HFTHotColdSplit] No struct type containing 'OrderBookLevel' found.\n";
      return PreservedAnalyses::all();
    }

    if (OrderBookTy->isOpaque()) {
      errs() << "[HFTHotColdSplit] OrderBookLevel type is opaque; cannot inspect fields.\n";
      return PreservedAnalyses::all();
    }

    ArrayRef<Type *> Elems = OrderBookTy->elements();
    unsigned NumFields = Elems.size();

    errs() << "[HFTHotColdSplit] Found struct type: " << OrderBookTy->getName()
           << " with " << NumFields << " fields.\n";

    if (NumFields <= HotFieldCount) {
      errs() << "[HFTHotColdSplit] Not enough fields to split; aborting.\n";
      return PreservedAnalyses::all();
    }

    // 2. Build hot and cold field type lists.
    SmallVector<Type *, 8> HotFields;
    SmallVector<Type *, 8> ColdFields;
    for (unsigned i = 0; i < NumFields; ++i) {
      if (i < HotFieldCount)
        HotFields.push_back(Elems[i]);
      else
        ColdFields.push_back(Elems[i]);
    }

    // 3. Create hot/cold struct types.
    std::string BaseName = std::string(OrderBookTy->getName());
    std::string HotName  = BaseName + ".hot";
    std::string ColdName = BaseName + ".cold";

    StructType *HotTy  = StructType::create(Ctx, HotFields, HotName,  /*isPacked*/ false);
    StructType *ColdTy = StructType::create(Ctx, ColdFields, ColdName, /*isPacked*/ false);

    errs() << "[HFTHotColdSplit] Created hot struct type: " << HotTy->getName()
           << " with " << HotFields.size() << " fields.\n";
    errs() << "[HFTHotColdSplit] Created cold struct type: " << ColdTy->getName()
           << " with " << ColdFields.size() << " fields.\n";

    errs() << "[HFTHotColdSplit] Hot fields correspond to original indices {0,1,2}.\n";
    errs() << "[HFTHotColdSplit] Cold fields correspond to original indices {3.."
           << (NumFields - 1) << "}.\n";

    // 4. Find bids / asks globals.
    GlobalVariable *BidsGV = M.getGlobalVariable("bids", /*AllowInternal*/ true);
    GlobalVariable *AsksGV = M.getGlobalVariable("asks", /*AllowInternal*/ true);

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

    if (BidsArrayTy->getElementType() != OrderBookTy ||
        AsksArrayTy->getElementType() != OrderBookTy) {
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

    auto *BidsHotGV = new GlobalVariable(
        M, BidsHotArrayTy,
        /*isConstant*/ false,
        BidsGV->getLinkage(),
        ConstantAggregateZero::get(BidsHotArrayTy),
        BidsGV->getName() + ".hot");

    auto *BidsColdGV = new GlobalVariable(
        M, BidsColdArrayTy,
        /*isConstant*/ false,
        BidsGV->getLinkage(),
        ConstantAggregateZero::get(BidsColdArrayTy),
        BidsGV->getName() + ".cold");

    auto *AsksHotGV = new GlobalVariable(
        M, AsksHotArrayTy,
        /*isConstant*/ false,
        AsksGV->getLinkage(),
        ConstantAggregateZero::get(AsksHotArrayTy),
        AsksGV->getName() + ".hot");

    auto *AsksColdGV = new GlobalVariable(
        M, AsksColdArrayTy,
        /*isConstant*/ false,
        AsksGV->getLinkage(),
        ConstantAggregateZero::get(AsksColdArrayTy),
        AsksGV->getName() + ".cold");

    errs() << "[HFTHotColdRewrite] Created hot/cold globals for bids/asks.\n";

    bool Changed = false;

    // 6. For each function, rewrite *field* GEPs whose struct pointer
    //    ultimately comes from bids[] / asks[].
    for (Function &F : M) {
      if (F.isDeclaration())
        continue;

      SmallVector<GetElementPtrInst *, 32> FieldGEPs;

      // Collect candidate struct-field GEPs.
      for (BasicBlock &BB : F) {
        for (Instruction &I : BB) {
          auto *GEP = dyn_cast<GetElementPtrInst>(&I);
          if (!GEP)
            continue;

          // We want GEPs whose source element type is the struct itself:
          //   %field = getelementptr %struct.OrderBookLevel, ptr %elem, i32 0, i32 field
          Type *SrcTy = GEP->getSourceElementType();
          auto *ST = dyn_cast<StructType>(SrcTy);
          if (!ST || ST != OrderBookTy)
            continue;

          // Need at least [0, field]
          if (GEP->getNumIndices() < 2)
            continue;

          auto IdxIt = GEP->idx_begin();
          ++IdxIt; // skip the leading 0
          Value *FieldIdxV = IdxIt->get();
          auto *FieldCI = dyn_cast<ConstantInt>(FieldIdxV);
          if (!FieldCI)
            continue; // only handle constant field idx

          FieldGEPs.push_back(GEP);
        }
      }

      // Rewrite each field GEP if its base struct pointer is from bids[] / asks[].
      for (GetElementPtrInst *FieldGEP : FieldGEPs) {
        auto IdxIt = FieldGEP->idx_begin();
        ++IdxIt; // skip leading 0
        Value *FieldIdxV = IdxIt->get();
        auto *FieldCI    = cast<ConstantInt>(FieldIdxV);
        unsigned FieldIdx = (unsigned)FieldCI->getZExtValue();

        Value *StructPtr = FieldGEP->getPointerOperand();

        // We expect StructPtr to be an array-element GEP:
        //
        //   %elem = getelementptr [N x %struct.OrderBookLevel],
        //                      ptr @bids/@asks, i64 0, i64 %level
        //
        auto *ElemGEP = dyn_cast<GetElementPtrInst>(StructPtr);
        if (!ElemGEP)
          continue;

        Type *ElemSrcTy = ElemGEP->getSourceElementType();
        auto *ArrTy = dyn_cast<ArrayType>(ElemSrcTy);
        if (!ArrTy || ArrTy->getElementType() != OrderBookTy)
          continue;

        // Expect [0, level]
        if (ElemGEP->getNumIndices() != 2)
          continue;

        auto ElemIdxIt = ElemGEP->idx_begin();
        Value *Idx0     = ElemIdxIt->get(); ++ElemIdxIt;
        Value *LevelIdx = ElemIdxIt->get();

        Value *BasePtr = ElemGEP->getPointerOperand();
        bool IsBids = (BasePtr == BidsGV);
        bool IsAsks = (BasePtr == AsksGV);
        if (!IsBids && !IsAsks)
          continue;

        IRBuilder<> B(FieldGEP);

        // Choose the appropriate hot/cold globals + array types.
        GlobalVariable *HotGV  = IsBids ? BidsHotGV  : AsksHotGV;
        GlobalVariable *ColdGV = IsBids ? BidsColdGV : AsksColdGV;
        ArrayType     *HotArr  = IsBids ? BidsHotArrayTy  : AsksHotArrayTy;
        ArrayType     *ColdArr = IsBids ? BidsColdArrayTy : AsksColdArrayTy;

        // GEP 1: element pointer into hot/cold array: [0, level]
        Value *NewElemPtr;
        Value *NewFieldPtr;

        Value *ZeroI32 = ConstantInt::get(Type::getInt32Ty(Ctx), 0);

        if (FieldIdx < HotFieldCount) {
          // Hot field: go through HotTy
          NewElemPtr = B.CreateGEP(
              HotArr, HotGV, {Idx0, LevelIdx},
              ElemGEP->getName() + ".hot.elem");

          Value *HotFieldCI =
              ConstantInt::get(Type::getInt32Ty(Ctx), FieldIdx);

          // GEP 2: struct-field GEP on HotTy: [0, HotFieldIdx]
          NewFieldPtr = B.CreateGEP(
              HotTy, NewElemPtr, {ZeroI32, HotFieldCI},
              FieldGEP->getName() + ".hot");
        } else {
          // Cold field: index into ColdTy with adjusted index.
          unsigned ColdFieldIdx = FieldIdx - HotFieldCount;
          NewElemPtr = B.CreateGEP(
              ColdArr, ColdGV, {Idx0, LevelIdx},
              ElemGEP->getName() + ".cold.elem");

          Value *ColdFieldCI =
              ConstantInt::get(Type::getInt32Ty(Ctx), ColdFieldIdx);

          NewFieldPtr = B.CreateGEP(
              ColdTy, NewElemPtr, {ZeroI32, ColdFieldCI},
              FieldGEP->getName() + ".cold");
        }

        FieldGEP->replaceAllUsesWith(NewFieldPtr);
        FieldGEP->eraseFromParent();
        Changed = true;

        // ElemGEP will likely become dead and be DCE'd later; no need to force-delete here.
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
    errs() << "[HFTPrintPass] Function " << F.getName()
           << " has " << NumBlocks << " basic blocks\n";
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
          if (Name == "hft-hotcold") {
            FPM.addPass(HFTHotColdSplitPass());
            return true;
          }
          return false;
        }
      );

      PB.registerPipelineParsingCallback(
        [](StringRef Name, ModulePassManager &MPM,
           ArrayRef<PassBuilder::PipelineElement>) {

          if (Name == "hft-split") {
            MPM.addPass(HFTHotColdStructSplitPass()); // Pass 2 (type split)
            return true;
          }
          return false;
        }
      );
    }
  };
}
