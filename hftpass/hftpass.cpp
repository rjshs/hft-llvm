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
          
          return false;
        }
      );
    }
  };
}
