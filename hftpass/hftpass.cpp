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
// You can include more Header files here
#include <vector>
#include <cmath>
#include <set>
#include "llvm/IR/IRBuilder.h"


/* *******Implementation Ends Here******* */

using namespace llvm;

// Helper: identify the OrderBookLevel struct type by name.
static StructType *getOrderBookLevelTy(Module &M) {
  for (StructType *ST : M.getIdentifiedStructTypes()) {
    if (!ST->hasName()) continue;
    StringRef Name = ST->getName();
    // Adjust if your mangled name is different.
    if (Name.ends_with("OrderBookLevel") || Name.find("OrderBookLevel") != llvm::StringRef::npos)
      return ST;
  }
  return nullptr;
}

struct HFTHotColdSplitPass : public PassInfoMixin<HFTHotColdSplitPass> {
  // To avoid recreating globals on every function, we memoize in the pass object.
  GlobalVariable *BidsPrice = nullptr;
  GlobalVariable *BidsSize  = nullptr;
  GlobalVariable *BidsCnt   = nullptr;
  GlobalVariable *AsksPrice = nullptr;
  GlobalVariable *AsksSize  = nullptr;
  GlobalVariable *AsksCnt   = nullptr;

  bool setupHotGlobals(Module &M, StructType *OBLTy) {
    if (!OBLTy)
      return false;

    // Find original AoS globals
    GlobalVariable *Bids = M.getGlobalVariable("bids");
    GlobalVariable *Asks = M.getGlobalVariable("asks");
    if (!Bids || !Asks)
      return false; // nothing to do for now

    auto &Ctx = M.getContext();
    // Assume [N x %struct.OrderBookLevel]
    auto *ArrTy = dyn_cast<ArrayType>(Bids->getValueType());
    if (!ArrTy || ArrTy->getElementType() != OBLTy)
      return false;

    uint64_t N = ArrTy->getNumElements();

    auto *PriceArrTy = ArrayType::get(OBLTy->getElementType(0), N); // double
    auto *SizeArrTy  = ArrayType::get(OBLTy->getElementType(1), N); // i32
    auto *CntArrTy   = ArrayType::get(OBLTy->getElementType(2), N); // i32

    if (!BidsPrice) {
      BidsPrice = new GlobalVariable(
          M, PriceArrTy, /*isConstant*/false, GlobalValue::InternalLinkage,
          ConstantAggregateZero::get(PriceArrTy), "bids_price");
      BidsSize  = new GlobalVariable(
          M, SizeArrTy, false, GlobalValue::InternalLinkage,
          ConstantAggregateZero::get(SizeArrTy), "bids_size");
      BidsCnt   = new GlobalVariable(
          M, CntArrTy, false, GlobalValue::InternalLinkage,
          ConstantAggregateZero::get(CntArrTy), "bids_count");

      AsksPrice = new GlobalVariable(
          M, PriceArrTy, false, GlobalValue::InternalLinkage,
          ConstantAggregateZero::get(PriceArrTy), "asks_price");
      AsksSize  = new GlobalVariable(
          M, SizeArrTy, false, GlobalValue::InternalLinkage,
          ConstantAggregateZero::get(SizeArrTy), "asks_size");
      AsksCnt   = new GlobalVariable(
          M, CntArrTy, false, GlobalValue::InternalLinkage,
          ConstantAggregateZero::get(CntArrTy), "asks_count");
    }
    return true;
  }

  PreservedAnalyses run(Function &F, FunctionAnalysisManager &FAM) {
    Module &M = *F.getParent();
    StructType *OBLTy = getOrderBookLevelTy(M);
    if (!OBLTy)
      return PreservedAnalyses::all();

    bool OK = setupHotGlobals(M, OBLTy);
    if (!OK)
      return PreservedAnalyses::all();

    GlobalVariable *Bids = M.getGlobalVariable("bids");
    GlobalVariable *Asks = M.getGlobalVariable("asks");
    if (!Bids || !Asks)
      return PreservedAnalyses::all();

    bool Changed = false;

    // Scan all instructions in this function, looking for GEPs into bids/asks.
    for (auto &BB : F) {
      for (auto II = BB.begin(), IE = BB.end(); II != IE; ) {
        Instruction *I = &*II++;
        auto *GEP = dyn_cast<GetElementPtrInst>(I);
        if (!GEP)
          continue;

        Value *Base = GEP->getPointerOperand();
        auto *GV = dyn_cast<GlobalVariable>(Base);
        if (!GV)
          continue;

        bool IsBids = (GV == Bids);
        bool IsAsks = (GV == Asks);
        if (!IsBids && !IsAsks)
          continue;

        // We expect GEP indices: 0, idx, field_index
        if (GEP->getNumIndices() != 3)
          continue;

        auto IdxIt = GEP->idx_begin();
        auto *First = dyn_cast<ConstantInt>(IdxIt->get());
        ++IdxIt;
        Value *LevelIdx = IdxIt->get();
        ++IdxIt;
        auto *FieldConst = dyn_cast<ConstantInt>(IdxIt->get());

        if (!First || !FieldConst || !First->isZero())
          continue;

        unsigned FieldIndex = FieldConst->getZExtValue();

        GlobalVariable *HotArr = nullptr;
        if (FieldIndex == 0)      HotArr = IsBids ? BidsPrice : AsksPrice;
        else if (FieldIndex == 1) HotArr = IsBids ? BidsSize  : AsksSize;
        else if (FieldIndex == 2) HotArr = IsBids ? BidsCnt   : AsksCnt;
        else
          continue; // cold fields: ignore for now

        IRBuilder<> B(GEP);

        // Build new GEP into hot array: [N x Ty], 0, LevelIdx
        auto *ArrTy = cast<ArrayType>(HotArr->getValueType());
        auto *Zero = ConstantInt::get(Type::getInt64Ty(M.getContext()), 0);

        Value *NewPtr = B.CreateInBoundsGEP(
            ArrTy, HotArr,
            {Zero, LevelIdx},
            GEP->getName() + ".hot");

        // Now we must redirect all loads/stores that use this GEP.
        SmallVector<User*, 4> Users(GEP->user_begin(), GEP->user_end());
        for (User *U : Users) {
          if (auto *Ld = dyn_cast<LoadInst>(U)) {
            Ld->setOperand(0, NewPtr);
            Changed = true;
          } else if (auto *St = dyn_cast<StoreInst>(U)) {
            if (St->getPointerOperand() == GEP) {
              St->setOperand(1, NewPtr);
              Changed = true;
            }
          } else {
            // Other uses (e.g., bitcasts) are more complex; skip for v1.
          }
        }

        // We *do not* erase GEP here if there are still strange users.
      }
    }

    return Changed ? PreservedAnalyses::none() : PreservedAnalyses::all();
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
    }
  };
}
