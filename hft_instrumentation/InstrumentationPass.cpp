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
#include "llvm/IR/GlobalVariable.h"
/* *******Implementation Ends Here******* */

using namespace llvm;

// --- Small utilities (mostly from HW2, some may be unused but kept around) ---

static inline BranchProbability FPThreshold() {
  return BranchProbability(4, 5); // 0.8
}

static const Value *stripPtrCasts(const Value *V) {
  return V->stripPointerCasts();
}

static bool samePointerSSA(const Value *A, const Value *B) {
  return stripPtrCasts(A) == stripPtrCasts(B);
}

static const Value *getBasePtr(const Value *V) {
  V = stripPtrCasts(V);
  while (auto *G = dyn_cast<GEPOperator>(V)) {
    V = stripPtrCasts(G->getPointerOperand());
  }
  return V;
}

static bool isLatchOf(const Loop &L, const BasicBlock *BB) {
  SmallVector<BasicBlock *, 2> Latches;
  L.getLoopLatches(Latches);
  return is_contained(Latches, BB);
}

static std::vector<BasicBlock *>
buildFrequentPath(Loop &L, BranchProbabilityInfo &BPI) {
  std::vector<BasicBlock *> Path;
  BasicBlock *Cur = L.getHeader();
  if (!Cur)
    return {};
  Path.push_back(Cur);

  while (!isLatchOf(L, Cur)) {
    auto *TI = Cur->getTerminator();
    BasicBlock *Next = nullptr;

    if (auto *Br = dyn_cast<BranchInst>(TI)) {
      if (!Br->isConditional()) {
        BasicBlock *S = Br->getSuccessor(0);
        if (L.contains(S))
          Next = S;
        else
          return {};
      } else {
        BasicBlock *S0 = Br->getSuccessor(0);
        BasicBlock *S1 = Br->getSuccessor(1);
        auto P0 = BPI.getEdgeProbability(Cur, S0);
        auto P1 = BPI.getEdgeProbability(Cur, S1);
        if (L.contains(S0) && P0 >= FPThreshold())
          Next = S0;
        if (L.contains(S1) && P1 >= FPThreshold() &&
            (!Next || P1 > BPI.getEdgeProbability(Cur, Next)))
          Next = S1;
      }
    } else if (auto *Sw = dyn_cast<SwitchInst>(TI)) {
      for (unsigned i = 0; i < Sw->getNumSuccessors(); ++i) {
        auto *S = Sw->getSuccessor(i);
        if (!L.contains(S))
          continue;
        auto P = BPI.getEdgeProbability(Cur, S);
        if (P >= FPThreshold() &&
            (!Next || P > BPI.getEdgeProbability(Cur, Next)))
          Next = S;
      }
    }

    if (!Next)
      return {};
    Cur = Next;
    Path.push_back(Cur);
  }
  return Path;
}

static DenseSet<const BasicBlock *>
toSet(const std::vector<BasicBlock *> &v) {
  DenseSet<const BasicBlock *> S;
  for (auto *b : v)
    S.insert(b);
  return S;
}

// Helper: get the StructType that a GEP is indexing into (if any).
static const StructType *getGEPStructType(const GetElementPtrInst *GEP) {
  Type *SourceTy = GEP->getSourceElementType();
  return dyn_cast<StructType>(SourceTy);
}

// Simple predicate for "is this one of our HFT structs?".
static bool isHFTStruct(const StructType *ST) {
  if (!ST || !ST->hasName())
    return false;
  StringRef N = ST->getName();
  return N.contains("OrderBookLevel") || N.contains("hft_struct");
}

// Create (or reuse) the dump function that writes hft_profile.txt.
// It prints one line per field: "<field_index> <count>\n".
static Function *getOrCreateDumpFunction(Module &M,
                                         GlobalVariable *FieldCountsGV,
                                         unsigned NumFields) {
  LLVMContext &Ctx = M.getContext();
  Type *VoidTy   = Type::getVoidTy(Ctx);
  Type *I32Ty    = Type::getInt32Ty(Ctx);
  Type *I64Ty    = Type::getInt64Ty(Ctx);
  Type *I8PtrTy  = PointerType::getUnqual(Type::getInt8Ty(Ctx));

  // Signature: void __hft_dump_profile()
  FunctionType *DumpFTy = FunctionType::get(VoidTy, {}, false);
  Function *DumpFn =
      dyn_cast<Function>(M.getFunction("__hft_dump_profile"));
  if (!DumpFn) {
    DumpFn = Function::Create(DumpFTy, GlobalValue::InternalLinkage,
                              "__hft_dump_profile", &M);
  }

  // If it already has a body, don't rebuild it.
  if (!DumpFn->empty())
    return DumpFn;

  // Declare libc functions we need: fopen, fprintf, fclose.
  // We model FILE* as i8*.
  FunctionType *FopenTy =
      FunctionType::get(I8PtrTy, {I8PtrTy, I8PtrTy}, false);
  FunctionCallee FopenFn = M.getOrInsertFunction("fopen", FopenTy);

  FunctionType *FcloseTy =
      FunctionType::get(I32Ty, {I8PtrTy}, false);
  FunctionCallee FcloseFn = M.getOrInsertFunction("fclose", FcloseTy);

  // int fprintf(FILE *stream, const char *fmt, ...);
  FunctionType *FprintfTy =
      FunctionType::get(I32Ty, {I8PtrTy}, true);
  FunctionCallee FprintfFn = M.getOrInsertFunction("fprintf", FprintfTy);

  // Build the body of __hft_dump_profile.
  BasicBlock *EntryBB = BasicBlock::Create(Ctx, "entry", DumpFn);
  IRBuilder<> B(EntryBB);

  // fopen("hft_profile.txt", "w")
  Value *FileName = B.CreateGlobalStringPtr("hft_profile.txt",
                                            "hft_profile_filename");
  Value *Mode = B.CreateGlobalStringPtr("w", "hft_profile_mode");
  Value *FilePtr = B.CreateCall(FopenFn, {FileName, Mode}, "file");
  // If fopen fails, FilePtr will be null; we ignore that for simplicity.

  // Common constants.
  Value *ZeroI32 = ConstantInt::get(I32Ty, 0);

  // Format string: "%u %llu\n"
  Value *FmtStr = B.CreateGlobalStringPtr("%u %llu\n",
                                          "hft_profile_format");

  ArrayType *ArrTy =
      cast<ArrayType>(FieldCountsGV->getValueType());

  // Emit: for each field index i, load field_counts[i] and fprintf it.
  for (unsigned i = 0; i < NumFields; ++i) {
    Value *IdxI = ConstantInt::get(I32Ty, i);

    // &__hft_field_counts[0][i]
    Value *CounterPtr = B.CreateGEP(
        ArrTy, FieldCountsGV, {ZeroI32, IdxI},
        "hft_field_count_ptr");

    Value *Count = B.CreateLoad(I64Ty, CounterPtr, "hft_count");

    Value *IdxVal = ConstantInt::get(I32Ty, i);

    // fprintf(file, "%u %llu\n", i, count);
    SmallVector<Value *, 4> Args;
    Args.push_back(FilePtr);   // FILE*
    Args.push_back(FmtStr);    // const char *fmt
    Args.push_back(IdxVal);    // %u
    Args.push_back(Count);     // %llu

    B.CreateCall(FprintfFn, Args, "fprintf_call");
  }

  // fclose(file);
  B.CreateCall(FcloseFn, {FilePtr});
  B.CreateRetVoid();

  return DumpFn;
}

// Insert a call to DumpFn before every return in main().
static void insertDumpCallInMain(Function &MainF, Function *DumpFn) {
  for (BasicBlock &BB : MainF) {
    if (auto *Ret = dyn_cast<ReturnInst>(BB.getTerminator())) {
      IRBuilder<> B(Ret);
      B.CreateCall(DumpFn);
    }
  }
}

namespace {

struct HFTInstrumentationPass : public PassInfoMixin<HFTInstrumentationPass> {
  PreservedAnalyses run(Function &F, FunctionAnalysisManager &FAM) {
    Module &M = *F.getParent();
    LLVMContext &Ctx = M.getContext();

    // Find the concrete struct type for OrderBookLevel in this module.
    StructType *OrderBookTy = nullptr;
    for (StructType *ST : M.getIdentifiedStructTypes()) {
      if (!ST->hasName())
        continue;
      if (ST->getName().contains("OrderBookLevel")) {
        OrderBookTy = ST;
        break;
      }
    }

    if (!OrderBookTy || OrderBookTy->isOpaque())
      return PreservedAnalyses::all();

    unsigned NumFields = OrderBookTy->getNumElements();

    // Ensure we have a global counter array: [NumFields x i64] __hft_field_counts
    GlobalVariable *FieldCountsGV =
        M.getGlobalVariable("__hft_field_counts");
    if (!FieldCountsGV) {
      ArrayType *ArrTy =
          ArrayType::get(Type::getInt64Ty(Ctx), NumFields);
      FieldCountsGV = new GlobalVariable(
          M,
          ArrTy,
          /*isConstant*/ false,
          GlobalValue::InternalLinkage,
          ConstantAggregateZero::get(ArrTy),
          "__hft_field_counts");
    } else {
      auto *ArrTy =
          dyn_cast<ArrayType>(FieldCountsGV->getValueType());
      if (!ArrTy || ArrTy->getNumElements() != NumFields) {
        // Mismatch: bail out conservatively for this function.
        return PreservedAnalyses::all();
      }
    }

    bool Changed = false;

    Type *I32Ty = Type::getInt32Ty(Ctx);
    Type *I64Ty = Type::getInt64Ty(Ctx);

    // --- 1. Instrument loads/stores to OrderBookLevel fields in this function. ---
    for (BasicBlock &BB : F) {
      for (Instruction &I : BB) {
        auto *GEP = dyn_cast<GetElementPtrInst>(&I);
        if (!GEP)
          continue;

        const StructType *ST = getGEPStructType(GEP);
        if (!ST || ST != OrderBookTy)
          continue;
        if (!isHFTStruct(ST))
          continue;

        // Expect: %fieldPtr = getelementptr %OrderBookLevel, %OrderBookLevel* %p, i32 0, i32 <fieldIdx>
        if (GEP->getNumIndices() < 2)
          continue;

        auto IdxIt = GEP->idx_begin();
        ++IdxIt; // skip the leading "0" index into the struct
        Value *FieldIdxV = IdxIt->get();
        auto *FieldCI = dyn_cast<ConstantInt>(FieldIdxV);
        if (!FieldCI)
          continue;

        unsigned FieldIdx =
            (unsigned)FieldCI->getZExtValue();
        if (FieldIdx >= NumFields)
          continue;

        // Collect direct load/store uses of this field pointer.
        SmallVector<Instruction *, 4> UsesToInstrument;
        for (User *U : GEP->users()) {
          if (auto *Ld = dyn_cast<LoadInst>(U)) {
            UsesToInstrument.push_back(Ld);
          } else if (auto *St = dyn_cast<StoreInst>(U)) {
            if (St->getPointerOperand() == GEP)
              UsesToInstrument.push_back(St);
          }
        }

        if (UsesToInstrument.empty())
          continue;

        for (Instruction *UseI : UsesToInstrument) {
          Instruction *InsertPt = UseI->getNextNode();
          if (!InsertPt)
            continue; // very defensive

          IRBuilder<> B(InsertPt);

          // GEP into __hft_field_counts[FieldIdx]
          Value *Zero = ConstantInt::get(I32Ty, 0);
          Value *IdxVal = ConstantInt::get(I32Ty, FieldIdx);

          Value *CounterPtr = B.CreateGEP(
              FieldCountsGV->getValueType(),
              FieldCountsGV,
              {Zero, IdxVal},
              "__hft_field_count_ptr");

          // Load, increment, store
          Value *OldV =
              B.CreateLoad(I64Ty, CounterPtr, "hft_old_count");
          Value *One = ConstantInt::get(I64Ty, 1);
          Value *NewV =
              B.CreateAdd(OldV, One, "hft_new_count");
          B.CreateStore(NewV, CounterPtr);

          Changed = true;
        }
      }
    }

    // --- 2. If this is main(), wire in the dump function. ---
    if (F.getName() == "main") {
      Function *DumpFn =
          getOrCreateDumpFunction(M, FieldCountsGV, NumFields);
      insertDumpCallInMain(F, DumpFn);
      Changed = true;
    }

    if (Changed)
      return PreservedAnalyses::none();
    return PreservedAnalyses::all();
  }
};

} // end anonymous namespace

extern "C" ::llvm::PassPluginLibraryInfo LLVM_ATTRIBUTE_WEAK
llvmGetPassPluginInfo() {
  return {
      LLVM_PLUGIN_API_VERSION, "HFTInstrumentationPass", "v0.1",
      [](PassBuilder &PB) {
        PB.registerPipelineParsingCallback(
            [](StringRef Name, FunctionPassManager &FPM,
               ArrayRef<PassBuilder::PipelineElement>) {
              if (Name == "hft-inst") {
                FPM.addPass(HFTInstrumentationPass());
                return true;
              }
              return false;
            });
      }};
}