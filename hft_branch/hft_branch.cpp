// HFT Optimization Pass - Branchless Conversion & Prefetch Injection
//
// Two HFT-specific optimizations:
//
// 1. BRANCHLESS CONVERSION: Converts unpredictable 50/50 branches to select
//    instructions (CMOV on x86). CPU branch predictors are wrong 50% of the
//    time on bid/ask branches, causing ~12-15 cycle misprediction penalties.
//
// 2. PREFETCH INJECTION: Injects software prefetch for indirect memory access
//    patterns that hardware prefetchers cannot predict.

#include "llvm/IR/Function.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/PassManager.h"
#include "llvm/IR/Intrinsics.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"

using namespace llvm;

static cl::opt<bool> Verbose("hft-verbose",
    cl::desc("Enable verbose output for HFT optimization passes"),
    cl::init(false));

// BRANCHLESS PASS

namespace {

struct HFTBranchlessPass : public PassInfoMixin<HFTBranchlessPass> {
    
    unsigned NumConverted = 0;
    
    PreservedAnalyses run(Function &F, FunctionAnalysisManager &FAM) {
        if (Verbose) {
            errs() << "\n[HFT-BRANCHLESS] Analyzing: " << F.getName() << "\n";
        }
        
        bool Changed = false;
        SmallVector<BranchInst*, 16> Candidates;
        
        for (BasicBlock &BB : F) {
            if (auto *BI = dyn_cast<BranchInst>(BB.getTerminator())) {
                if (BI->isConditional()) {
                    Candidates.push_back(BI);
                }
            }
        }
        
        for (BranchInst *BI : Candidates) {
            if (tryConvertToSelect(BI, F)) {
                ++NumConverted;
                Changed = true;
            }
        }
        
        if (NumConverted > 0) {
            errs() << "[HFT-BRANCHLESS] " << F.getName() 
                   << ": Converted " << NumConverted << " branches\n";
        }
        
        return Changed ? PreservedAnalyses::none() : PreservedAnalyses::all();
    }
    
private:
    
    // Structure to hold info about a read-modify-write pattern
    struct RMWInfo {
        LoadInst *Load;
        StoreInst *Store;
        Value *Ptr;
        Instruction *ModifyOp;
    };
    
    bool tryConvertToSelect(BranchInst *BI, Function &F) {
        BasicBlock *CondBB = BI->getParent();
        BasicBlock *TrueBB = BI->getSuccessor(0);
        BasicBlock *FalseBB = BI->getSuccessor(1);
        
        // Check diamond pattern
        if (!TrueBB->getSinglePredecessor() || !FalseBB->getSinglePredecessor())
            return false;
            
        BasicBlock *TrueSucc = TrueBB->getSingleSuccessor();
        BasicBlock *FalseSucc = FalseBB->getSingleSuccessor();
        
        if (!TrueSucc || !FalseSucc || TrueSucc != FalseSucc)
            return false;
            
        BasicBlock *MergeBB = TrueSucc;
        
        // Analyze both branches for read-modify-write pattern
        RMWInfo TrueRMW, FalseRMW;
        if (!analyzeRMWBlock(TrueBB, TrueRMW) || !analyzeRMWBlock(FalseBB, FalseRMW))
            return false;
            
        // Both blocks must have same operation type
        if (TrueRMW.ModifyOp->getOpcode() != FalseRMW.ModifyOp->getOpcode())
            return false;
            
        // Pointers must be different
        if (TrueRMW.Ptr == FalseRMW.Ptr)
            return false;
            
        // Both pointers must be to globals
        if (!isGlobalPtr(TrueRMW.Ptr) || !isGlobalPtr(FalseRMW.Ptr))
            return false;
        
        if (Verbose) {
            errs() << "  MATCH: Diamond RMW pattern in " << CondBB->getName() << "\n";
        }
        
        return transformRMWDiamond(BI, TrueBB, FalseBB, MergeBB, TrueRMW, FalseRMW);
    }
    
    bool analyzeRMWBlock(BasicBlock *BB, RMWInfo &Info) {
        Info.Load = nullptr;
        Info.Store = nullptr;
        Info.ModifyOp = nullptr;
        
        for (Instruction &I : *BB) {
            if (I.isTerminator()) continue;
            
            if (auto *LI = dyn_cast<LoadInst>(&I)) {
                if (Info.Load) return false;
                Info.Load = LI;
                Info.Ptr = LI->getPointerOperand();
            }
            else if (auto *SI = dyn_cast<StoreInst>(&I)) {
                if (Info.Store) return false;
                Info.Store = SI;
            }
            else if (I.isBinaryOp()) {
                if (Info.ModifyOp) return false;
                Info.ModifyOp = &I;
            }
            else if (!isa<GetElementPtrInst>(&I) && !isa<CastInst>(&I)) {
                return false;
            }
        }
        
        if (!Info.Load || !Info.Store || !Info.ModifyOp)
            return false;
            
        if (Info.Store->getValueOperand() != Info.ModifyOp)
            return false;
            
        bool UsesLoad = false;
        for (Use &U : Info.ModifyOp->operands()) {
            if (U.get() == Info.Load) UsesLoad = true;
        }
        if (!UsesLoad) return false;
        
        return true;
    }
    
    bool isGlobalPtr(Value *Ptr) {
        Value *Base = Ptr->stripPointerCasts();
        if (isa<GlobalVariable>(Base)) return true;
        
        if (auto *GEP = dyn_cast<GetElementPtrInst>(Ptr)) {
            return isa<GlobalVariable>(GEP->getPointerOperand()->stripPointerCasts());
        }
        if (auto *CE = dyn_cast<ConstantExpr>(Ptr)) {
            if (CE->getOpcode() == Instruction::GetElementPtr) {
                return isa<GlobalVariable>(CE->getOperand(0)->stripPointerCasts());
            }
        }
        return false;
    }
    
    bool transformRMWDiamond(BranchInst *BI,
                             BasicBlock *TrueBB, BasicBlock *FalseBB,
                             BasicBlock *MergeBB,
                             RMWInfo &TrueRMW, RMWInfo &FalseRMW) {
        
        Value *Cond = BI->getCondition();
        IRBuilder<> Builder(BI);
        
        // Select pointer
        Value *SelPtr = Builder.CreateSelect(Cond, TrueRMW.Ptr, FalseRMW.Ptr, 
                                              "branchless.ptr");
        
        // Load from selected pointer
        Type *LoadTy = TrueRMW.Load->getType();
        LoadInst *NewLoad = Builder.CreateLoad(LoadTy, SelPtr, "branchless.load");
        NewLoad->setAlignment(std::min(TrueRMW.Load->getAlign(), 
                                        FalseRMW.Load->getAlign()));
        
        // Get the "other" operand for the modify op
        Value *OtherOp = nullptr;
        for (Use &U : TrueRMW.ModifyOp->operands()) {
            if (U.get() != TrueRMW.Load) {
                OtherOp = U.get();
                break;
            }
        }
        
        // Create modify operation
        Value *NewModify = nullptr;
        switch (TrueRMW.ModifyOp->getOpcode()) {
            case Instruction::FAdd:
                NewModify = Builder.CreateFAdd(NewLoad, OtherOp, "branchless.fadd");
                break;
            case Instruction::FSub:
                NewModify = Builder.CreateFSub(NewLoad, OtherOp, "branchless.fsub");
                break;
            case Instruction::FMul:
                NewModify = Builder.CreateFMul(NewLoad, OtherOp, "branchless.fmul");
                break;
            case Instruction::Add:
                NewModify = Builder.CreateAdd(NewLoad, OtherOp, "branchless.add");
                break;
            case Instruction::Sub:
                NewModify = Builder.CreateSub(NewLoad, OtherOp, "branchless.sub");
                break;
            default:
                return false;
        }
        
        // Store to selected pointer
        StoreInst *NewStore = Builder.CreateStore(NewModify, SelPtr);
        NewStore->setAlignment(std::min(TrueRMW.Store->getAlign(),
                                         FalseRMW.Store->getAlign()));
        
        // Jump to merge
        Builder.CreateBr(MergeBB);
        BI->eraseFromParent();
        
        // Clean up PHIs
        for (PHINode &PN : MergeBB->phis()) {
            for (int i = PN.getNumIncomingValues() - 1; i >= 0; --i) {
                BasicBlock *Inc = PN.getIncomingBlock(i);
                if (Inc == TrueBB || Inc == FalseBB) {
                    PN.removeIncomingValue(i, false);
                }
            }
        }
        
        // Delete old blocks
        TrueBB->eraseFromParent();
        FalseBB->eraseFromParent();
        
        if (Verbose) errs() << "  SUCCESS: Converted to branchless\n";
        return true;
    }
};

// PREFETCH PASS

struct HFTPrefetchPass : public PassInfoMixin<HFTPrefetchPass> {
    
    static constexpr int PREFETCH_DISTANCE = 4;
    unsigned NumPrefetches = 0;
    
    PreservedAnalyses run(Function &F, FunctionAnalysisManager &FAM) {
        if (Verbose) {
            errs() << "\n[HFT-PREFETCH] Analyzing: " << F.getName() << "\n";
        }
        
        auto &LI = FAM.getResult<LoopAnalysis>(F);
        bool Changed = false;
        
        for (Loop *L : LI) {
            Changed |= processLoop(F, L);
        }
        
        if (NumPrefetches > 0) {
            errs() << "[HFT-PREFETCH] " << F.getName() 
                   << ": Injected " << NumPrefetches << " prefetches\n";
        }
        
        return Changed ? PreservedAnalyses::none() : PreservedAnalyses::all();
    }
    
private:
    
    struct IndirectAccess {
        GetElementPtrInst *IndexGEP;
        LoadInst *IndexLoad;
        GetElementPtrInst *DataGEP;
        Value *LoopIndex;
    };
    
    bool processLoop(Function &F, Loop *L) {
        if (Verbose) errs() << "  Checking loop\n";
        
        SmallVector<IndirectAccess, 4> Accesses;
        
        for (BasicBlock *BB : L->blocks()) {
            for (Instruction &I : *BB) {
                if (auto *GEP = dyn_cast<GetElementPtrInst>(&I)) {
                    IndirectAccess IA;
                    if (isIndirectAccess(GEP, L, IA)) {
                        Accesses.push_back(IA);
                    }
                }
            }
        }
        
        if (Accesses.empty()) {
            if (Verbose) errs() << "    No indirect accesses found\n";
            return false;
        }
        
        if (Verbose) errs() << "    Found " << Accesses.size() << " indirect accesses\n";
        
        bool Changed = false;
        for (auto &IA : Accesses) {
            if (injectPrefetch(F, IA)) {
                ++NumPrefetches;
                Changed = true;
            }
        }
        
        return Changed;
    }
    
    bool isIndirectAccess(GetElementPtrInst *GEP, Loop *L, IndirectAccess &IA) {
        for (auto It = GEP->idx_begin(); It != GEP->idx_end(); ++It) {
            Value *Idx = It->get();
            
            if (auto *Ext = dyn_cast<SExtInst>(Idx)) Idx = Ext->getOperand(0);
            if (auto *Ext = dyn_cast<ZExtInst>(Idx)) Idx = Ext->getOperand(0);
            
            auto *IdxLoad = dyn_cast<LoadInst>(Idx);
            if (!IdxLoad || !L->contains(IdxLoad)) continue;
            
            auto *IdxGEP = dyn_cast<GetElementPtrInst>(IdxLoad->getPointerOperand());
            if (!IdxGEP || !L->contains(IdxGEP)) continue;
            
            IA.DataGEP = GEP;
            IA.IndexLoad = IdxLoad;
            IA.IndexGEP = IdxGEP;
            
            if (IdxGEP->getNumIndices() > 0) {
                IA.LoopIndex = IdxGEP->getOperand(IdxGEP->getNumOperands() - 1);
            }
            
            if (Verbose) {
                errs() << "    Indirect: " << *GEP << "\n";
            }
            
            return true;
        }
        
        return false;
    }
    
    bool injectPrefetch(Function &F, IndirectAccess &IA) {
        IRBuilder<> Builder(IA.IndexLoad);
        
        if (!IA.LoopIndex) return false;
        
        Value *Dist = ConstantInt::get(IA.LoopIndex->getType(), PREFETCH_DISTANCE);
        Value *FutureI = Builder.CreateAdd(IA.LoopIndex, Dist, "prefetch.future.i");
        
        // GEP for future index array element
        SmallVector<Value*, 4> IdxGEPIndices;
        for (auto &Idx : IA.IndexGEP->indices()) {
            IdxGEPIndices.push_back(Idx.get());
        }
        if (IdxGEPIndices.empty()) return false;
        IdxGEPIndices.back() = FutureI;
        
        Value *FutureIdxPtr = Builder.CreateGEP(
            IA.IndexGEP->getSourceElementType(),
            IA.IndexGEP->getPointerOperand(),
            IdxGEPIndices,
            "prefetch.idx.ptr");
        
        // Load future index
        Value *FutureIdxVal = Builder.CreateLoad(
            IA.IndexLoad->getType(), FutureIdxPtr, "prefetch.idx.val");
        
        // Extend if needed
        Value *OrigIdx = nullptr;
        for (auto It = IA.DataGEP->idx_begin(); It != IA.DataGEP->idx_end(); ++It) {
            Value *V = It->get();
            if (auto *Ext = dyn_cast<SExtInst>(V)) {
                if (Ext->getOperand(0) == IA.IndexLoad) {
                    FutureIdxVal = Builder.CreateSExt(FutureIdxVal, Ext->getType(),
                                                       "prefetch.idx.ext");
                    OrigIdx = V;
                    break;
                }
            }
            if (auto *Ext = dyn_cast<ZExtInst>(V)) {
                if (Ext->getOperand(0) == IA.IndexLoad) {
                    FutureIdxVal = Builder.CreateZExt(FutureIdxVal, Ext->getType(),
                                                       "prefetch.idx.ext");
                    OrigIdx = V;
                    break;
                }
            }
        }
        
        // GEP for future data element
        SmallVector<Value*, 4> DataGEPIndices;
        for (unsigned i = 1; i < IA.DataGEP->getNumOperands(); ++i) {
            Value *Orig = IA.DataGEP->getOperand(i);
            if (Orig == OrigIdx || Orig == IA.IndexLoad) {
                DataGEPIndices.push_back(FutureIdxVal);
            } else {
                DataGEPIndices.push_back(Orig);
            }
        }
        
        Value *FutureDataPtr = Builder.CreateGEP(
            IA.DataGEP->getSourceElementType(),
            IA.DataGEP->getPointerOperand(),
            DataGEPIndices,
            "prefetch.data.ptr");
        
        // Call prefetch
        Module *M = F.getParent();
        Type *PtrTy = Builder.getPtrTy();
        Function *PrefetchFn = Intrinsic::getDeclaration(M, Intrinsic::prefetch, {PtrTy});
        
        Builder.CreateCall(PrefetchFn, {
            FutureDataPtr,
            Builder.getInt32(0),   // read
            Builder.getInt32(3),   // high locality
            Builder.getInt32(1)    // data cache
        });
        
        if (Verbose) errs() << "    Injected prefetch\n";
        
        return true;
    }
};

// COMBINED PASS

struct HFTOptPass : public PassInfoMixin<HFTOptPass> {
    PreservedAnalyses run(Function &F, FunctionAnalysisManager &FAM) {
        bool Changed = false;
        
        HFTBranchlessPass BP;
        if (!BP.run(F, FAM).areAllPreserved()) Changed = true;
        
        HFTPrefetchPass PP;
        if (!PP.run(F, FAM).areAllPreserved()) Changed = true;
        
        return Changed ? PreservedAnalyses::none() : PreservedAnalyses::all();
    }
};

}

// PLUGIN REGISTRATION

extern "C" LLVM_ATTRIBUTE_WEAK ::llvm::PassPluginLibraryInfo
llvmGetPassPluginInfo() {
    return {
        LLVM_PLUGIN_API_VERSION,
        "HFTOptPasses",
        LLVM_VERSION_STRING,
        [](PassBuilder &PB) {
            PB.registerPipelineParsingCallback(
                [](StringRef Name, FunctionPassManager &FPM,
                   ArrayRef<PassBuilder::PipelineElement>) {
                    if (Name == "hft-branchless") {
                        FPM.addPass(HFTBranchlessPass());
                        return true;
                    }
                    if (Name == "hft-prefetch") {
                        FPM.addPass(HFTPrefetchPass());
                        return true;
                    }
                    if (Name == "hft-opt") {
                        FPM.addPass(HFTOptPass());
                        return true;
                    }
                    return false;
                });
        }
    };
}