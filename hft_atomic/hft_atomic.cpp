// // #include "llvm/IR/PassManager.h"
// // #include "llvm/Passes/PassBuilder.h"
// // #include "llvm/Passes/PassPlugin.h"

// // #include "llvm/IR/Function.h"
// // #include "llvm/IR/Module.h"
// // #include "llvm/IR/Instructions.h"
// // #include "llvm/IR/IRBuilder.h"
// // #include "llvm/IR/GlobalVariable.h"
// // #include "llvm/Support/raw_ostream.h"

// // using namespace llvm;

// // // --- Small utilities to chase through casts/GEPs to the base object ---

// // static const Value *stripPtrCasts(const Value *V) {
// //   return V->stripPointerCasts();
// // }

// // // Follow GEPs / pointer casts back to the underlying base object.
// // // This is the same idea as in your other pass.
// // static const Value *getBasePtr(const Value *V) {
// //   V = stripPtrCasts(V);
// //   while (auto *GEP = dyn_cast<GEPOperator>(V)) {
// //     V = stripPtrCasts(GEP->getPointerOperand());
// //   }
// //   return V;
// // }

// // // --- Atomic optimization pass ---

// // namespace {

// // struct HFTAtomicPass : public PassInfoMixin<HFTAtomicPass> {

// //   PreservedAnalyses run(Function &F, FunctionAnalysisManager &FAM) {
// //     Module &M = *F.getParent();

// //     // We only do anything if the module actually has seq_no.
// //     // In your orderbook.cpp, this is:
// //     //   std::atomic<uint64_t> seq_no;
// //     GlobalVariable *SeqNoGV = M.getGlobalVariable("seq_no", /*AllowInternal*/ true);
// //     if (!SeqNoGV) {
// //       // Nothing to do in this function.
// //       return PreservedAnalyses::all();
// //     }

// //     bool Changed = false;

// //     // Walk all instructions and look for atomics that ultimately touch seq_no.
// //     for (BasicBlock &BB : F) {
// //       // We may erase instructions (fences, atomicrmw), so use an iterator we advance manually.
// //       for (auto It = BB.begin(); It != BB.end(); ) {
// //         Instruction &I = *It++;
// //         // 1) atomicrmw (this is what std::atomic::fetch_add usually lowers to)
// //         if (auto *RMW = dyn_cast<AtomicRMWInst>(&I)) {
// //           const Value *Base =
// //               getBasePtr(RMW->getPointerOperand());
// //           if (Base != SeqNoGV)
// //             continue;  // Different atomic; leave it alone.

// //           // We only understand ADD; bail on other ops for safety.
// //           if (RMW->getOperation() != AtomicRMWInst::Add)
// //             continue;

// //           // Replace:
// //           //   %old = atomicrmw add i64* @seq_no, %inc monotonic
// //           // with:
// //           //   %old = load i64, i64* @seq_no
// //           //   %new = add i64 %old, %inc
// //           //   store i64 %new, i64* @seq_no
// //           //
// //           // The RMW result (old value) is preserved via %old.

// //           IRBuilder<> B(RMW);
// //           Value *Ptr = RMW->getPointerOperand();
// //           Type *Ty = RMW->getType();         // result type (i64 for seq_no)
// //           Value *Inc = RMW->getValOperand(); // increment

// //           // Load old value.
// //           LoadInst *Old = B.CreateLoad(Ty, Ptr, RMW->getName() + ".old");
// //           Old->setAlignment(Align(8));  // seq_no is uint64_t, 8-byte aligned

// //           // Compute new value.
// //           Value *New = B.CreateAdd(Old, Inc, RMW->getName() + ".new");

// //           // Store new value.
// //           StoreInst *St = B.CreateStore(New, Ptr);
// //           St->setAlignment(Align(8));

// //           // RMW returns the old value; wire its uses to the load.
// //           if (!RMW->use_empty())
// //             RMW->replaceAllUsesWith(Old);

// //           RMW->eraseFromParent();
// //           Changed = true;
// //           continue;
// //         }

// //         // 2) Atomic loads on seq_no → non-atomic loads.
// //         if (auto *Ld = dyn_cast<LoadInst>(&I)) {
// //           if (!Ld->isAtomic())
// //             continue;

// //           const Value *Base =
// //               getBasePtr(Ld->getPointerOperand());
// //           if (Base != SeqNoGV)
// //             continue;

// //           // Demote to non-atomic: clear the atomic ordering.
// //           Ld->setOrdering(AtomicOrdering::NotAtomic);
// //           Changed = true;
// //           continue;
// //         }

// //         // 3) Atomic stores on seq_no → non-atomic stores.
// //         if (auto *St = dyn_cast<StoreInst>(&I)) {
// //           if (!St->isAtomic())
// //             continue;

// //           const Value *Base =
// //               getBasePtr(St->getPointerOperand());
// //           if (Base != SeqNoGV)
// //             continue;

// //           St->setOrdering(AtomicOrdering::NotAtomic);
// //           Changed = true;
// //           continue;
// //         }

// //         // 4) Fences: if you want to be aggressive, just drop them.
// //         // In your benchmark, there aren't explicit fences, but this is here
// //         // for completeness.
// //         if (auto *Fence = dyn_cast<FenceInst>(&I)) {
// //           // Optional: you could restrict this to functions that also
// //           // touch seq_no, but at this point we already know SeqNoGV exists.
// //           Fence->eraseFromParent();
// //           Changed = true;
// //           continue;
// //         }
// //       }
// //     }

// //     if (Changed)
// //       return PreservedAnalyses::none();
// //     return PreservedAnalyses::all();
// //   }
// // };

// // } // end anonymous namespace

// // // --- Plugin entry point ---

// // extern "C" ::llvm::PassPluginLibraryInfo LLVM_ATTRIBUTE_WEAK
// // llvmGetPassPluginInfo() {
// //   return {
// //       LLVM_PLUGIN_API_VERSION,
// //       "HFTAtomicPass",
// //       "v0.1",
// //       [](PassBuilder &PB) {
// //         PB.registerPipelineParsingCallback(
// //             [](StringRef Name,
// //                FunctionPassManager &FPM,
// //                ArrayRef<PassBuilder::PipelineElement>) {
// //               if (Name == "hft-atomic") {
// //                 FPM.addPass(HFTAtomicPass());
// //                 return true;
// //               }
// //               return false;
// //             });
// //       }};
// // }

// // Add these includes to your existing ones:
// #include "llvm/IR/InstrTypes.h"     // For CallBase
// #include "llvm/IR/Intrinsics.h"     // For Intrinsic::maxnum, minnum
// #include "llvm/ADT/Statistic.h"     // For STATISTIC macro

// // After the using namespace llvm; line, add:
// #define DEBUG_TYPE "hft-atomic-elision"

// STATISTIC(NumLoadsElided,   "Number of atomic loads converted to plain loads");
// STATISTIC(NumStoresElided,  "Number of atomic stores converted to plain stores");
// STATISTIC(NumRMWsElided,    "Number of atomicrmw instructions eliminated");
// STATISTIC(NumCmpXchgElided, "Number of cmpxchg instructions eliminated");
// STATISTIC(NumFencesRemoved, "Number of fence instructions removed");
// //===----------------------------------------------------------------------===//
// // HFT Atomic Elision Pass
// //
// // This pass removes unnecessary atomic operations and fences in code that is
// // verified to be single-threaded. This is safe because:
// // 1. We verify no thread-spawning functions are called
// // 2. We verify the module is compiled with single-thread mode
// // 3. We only transform atomics on memory that cannot be accessed by other
// //    processes (no MMIO, no shared memory regions)
// //===----------------------------------------------------------------------===//

// #include "llvm/IR/Instructions.h"
// #include "llvm/IR/IRBuilder.h"
// #include "llvm/IR/Module.h"
// #include "llvm/IR/PassManager.h"
// #include "llvm/IR/InstrTypes.h"  // For CallBase
// #include "llvm/Passes/PassBuilder.h"
// #include "llvm/Passes/PassPlugin.h"
// #include "llvm/Support/raw_ostream.h"
// #include "llvm/ADT/SmallVector.h"
// #include "llvm/ADT/Statistic.h"

// #define DEBUG_TYPE "hft-atomic-elision"

// STATISTIC(NumLoadsElided,   "Number of atomic loads converted to plain loads");
// STATISTIC(NumStoresElided,  "Number of atomic stores converted to plain stores");
// STATISTIC(NumRMWsElided,    "Number of atomicrmw instructions eliminated");
// STATISTIC(NumCmpXchgElided, "Number of cmpxchg instructions eliminated");
// STATISTIC(NumFencesRemoved, "Number of fence instructions removed");

// using namespace llvm;

// struct HFTAtomicElisionPass : public PassInfoMixin<HFTAtomicElisionPass> {

//   PreservedAnalyses run(Module &M, ModuleAnalysisManager &MAM) {
//     //=========================================================================
//     // PHASE 1: Safety verification
//     //=========================================================================

//     // 1a. Check for explicit single-thread mode flag in module metadata
//     bool HasSingleThreadFlag = false;
//     if (auto *Flag = M.getModuleFlag("hft.single_thread")) {
//       if (auto *CI = mdconst::dyn_extract<ConstantInt>(Flag)) {
//         HasSingleThreadFlag = !CI->isZero();
//       }
//     }

//     if (!HasSingleThreadFlag) {
//       errs() << "[HFTAtomicElision] Note: No 'hft.single_thread' module flag found.\n"
//              << "[HFTAtomicElision] Will proceed if no thread-spawning calls are detected.\n";
//     }

//     // 1b. Scan for thread-spawning function calls
//     if (containsThreadSpawningCalls(M)) {
//       errs() << "[HFTAtomicElision] ABORT: Detected thread-spawning calls in module.\n"
//              << "[HFTAtomicElision] Cannot safely elide atomics.\n";
//       return PreservedAnalyses::all();
//     }

//     errs() << "[HFTAtomicElision] Safety check passed: No thread-spawning calls found.\n";

//     //=========================================================================
//     // PHASE 2: Collect all atomic operations
//     //=========================================================================

//     // We collect first, then transform, to avoid iterator invalidation
//     SmallVector<LoadInst *, 32> AtomicLoads;
//     SmallVector<StoreInst *, 32> AtomicStores;
//     SmallVector<AtomicRMWInst *, 32> AtomicRMWs;
//     SmallVector<AtomicCmpXchgInst *, 16> AtomicCmpXchgs;
//     SmallVector<FenceInst *, 16> Fences;

//     for (Function &F : M) {
//       if (F.isDeclaration())
//         continue;

//       for (BasicBlock &BB : F) {
//         for (Instruction &I : BB) {
//           if (auto *LI = dyn_cast<LoadInst>(&I)) {
//             if (LI->isAtomic()) {
//               AtomicLoads.push_back(LI);
//             }
//           } else if (auto *SI = dyn_cast<StoreInst>(&I)) {
//             if (SI->isAtomic()) {
//               AtomicStores.push_back(SI);
//             }
//           } else if (auto *RMW = dyn_cast<AtomicRMWInst>(&I)) {
//             AtomicRMWs.push_back(RMW);
//           } else if (auto *CX = dyn_cast<AtomicCmpXchgInst>(&I)) {
//             AtomicCmpXchgs.push_back(CX);
//           } else if (auto *FI = dyn_cast<FenceInst>(&I)) {
//             Fences.push_back(FI);
//           }
//         }
//       }
//     }

//     errs() << "[HFTAtomicElision] Found: "
//            << AtomicLoads.size() << " atomic loads, "
//            << AtomicStores.size() << " atomic stores, "
//            << AtomicRMWs.size() << " atomicrmw, "
//            << AtomicCmpXchgs.size() << " cmpxchg, "
//            << Fences.size() << " fences.\n";

//     //=========================================================================
//     // PHASE 3: Transform each atomic operation
//     //=========================================================================

//     bool Changed = false;

//     // 3a. Transform atomic loads → plain loads
//     for (LoadInst *LI : AtomicLoads) {
//       if (transformAtomicLoad(LI)) {
//         Changed = true;
//         ++NumLoadsElided;
//       }
//     }

//     // 3b. Transform atomic stores → plain stores
//     for (StoreInst *SI : AtomicStores) {
//       if (transformAtomicStore(SI)) {
//         Changed = true;
//         ++NumStoresElided;
//       }
//     }

//     // 3c. Transform atomicrmw → load-op-store
//     for (AtomicRMWInst *RMW : AtomicRMWs) {
//       if (transformAtomicRMW(RMW)) {
//         Changed = true;
//         ++NumRMWsElided;
//       }
//     }

//     // 3d. Transform cmpxchg → load-cmp-select-store
//     for (AtomicCmpXchgInst *CX : AtomicCmpXchgs) {
//       if (transformCmpXchg(CX)) {
//         Changed = true;
//         ++NumCmpXchgElided;
//       }
//     }

//     // 3e. Remove fences (except signal fences)
//     for (FenceInst *FI : Fences) {
//       if (removeFence(FI)) {
//         Changed = true;
//         ++NumFencesRemoved;
//       }
//     }

//     //=========================================================================
//     // PHASE 4: Report results
//     //=========================================================================

//     if (Changed) {
//       errs() << "[HFTAtomicElision] SUCCESS: Elided "
//              << NumLoadsElided << " loads, "
//              << NumStoresElided << " stores, "
//              << NumRMWsElided << " RMWs, "
//              << NumCmpXchgElided << " cmpxchgs, "
//              << NumFencesRemoved << " fences.\n";
//       return PreservedAnalyses::none();
//     }

//     errs() << "[HFTAtomicElision] No transformations applied.\n";
//     return PreservedAnalyses::all();
//   }

// private:
//   //===========================================================================
//   // Safety Analysis Helpers
//   //===========================================================================

//   /// Check if the module contains any calls to thread-spawning functions.
//   /// We check for:
//   ///   - pthread_create (POSIX threads)
//   ///   - std::thread constructor (C++11 threads, mangled name)
//   ///   - std::jthread constructor (C++20 threads, mangled name)
//   ///   - std::async (C++11 async, mangled name)
//   ///
//   /// Note: Indirect calls through function pointers are not detected.
//   /// This is a known limitation; HFT code typically doesn't spawn threads
//   /// through function pointers.
//   bool containsThreadSpawningCalls(Module &M) {
//     for (Function &F : M) {
//       // Check both definitions and declarations - a declaration of
//       // pthread_create means we might call it
//       for (BasicBlock &BB : F) {
//         for (Instruction &I : BB) {
//           // Use CallBase to handle both CallInst and InvokeInst
//           auto *CB = dyn_cast<CallBase>(&I);
//           if (!CB)
//             continue;

//           // Get the called function (nullptr for indirect calls)
//           Function *Callee = CB->getCalledFunction();
//           if (!Callee)
//             continue;

//           StringRef Name = Callee->getName();

//           // POSIX threads
//           if (Name == "pthread_create") {
//             errs() << "[HFTAtomicElision] Found pthread_create call.\n";
//             return true;
//           }

//           // C11 threads
//           if (Name == "thrd_create") {
//             errs() << "[HFTAtomicElision] Found thrd_create call.\n";
//             return true;
//           }

//           // std::thread constructor - mangled name starts with _ZNSt6threadC
//           // Examples: _ZNSt6threadC1..., _ZNSt6threadC2...
//           if (Name.startswith("_ZNSt6threadC")) {
//             errs() << "[HFTAtomicElision] Found std::thread constructor call.\n";
//             return true;
//           }

//           // std::jthread constructor (C++20) - mangled name starts with _ZNSt7jthreadC
//           if (Name.startswith("_ZNSt7jthreadC")) {
//             errs() << "[HFTAtomicElision] Found std::jthread constructor call.\n";
//             return true;
//           }

//           // std::async - mangled name starts with _ZSt5async
//           if (Name.startswith("_ZSt5async")) {
//             errs() << "[HFTAtomicElision] Found std::async call.\n";
//             return true;
//           }

//           // Windows thread APIs (for portability)
//           if (Name == "CreateThread" || Name == "_beginthread" ||
//               Name == "_beginthreadex") {
//             errs() << "[HFTAtomicElision] Found Windows thread API call.\n";
//             return true;
//           }
//         }
//       }
//     }

//     // Also check for declarations that might indicate threading is used
//     for (Function &F : M) {
//       if (!F.isDeclaration())
//         continue;

//       StringRef Name = F.getName();
//       if (Name == "pthread_create" || Name == "thrd_create" ||
//           Name.startswith("_ZNSt6threadC") || Name.startswith("_ZNSt7jthreadC") ||
//           Name.startswith("_ZSt5async")) {
//         errs() << "[HFTAtomicElision] Found declaration of thread function: "
//                << Name << "\n";
//         // Note: Just having the declaration doesn't mean it's called,
//         // but we already checked for calls above. This is extra paranoia.
//       }
//     }

//     return false;
//   }

//   /// Trace back through GEPs and bitcasts to find the underlying memory object.
//   /// Returns the base allocation (GlobalVariable, AllocaInst, or Argument).
//   Value *getUnderlyingObject(Value *V) {
//     // Limit iterations to avoid infinite loops on malformed IR
//     constexpr unsigned MaxLookup = 32;

//     for (unsigned i = 0; i < MaxLookup; ++i) {
//       if (auto *GEP = dyn_cast<GetElementPtrInst>(V)) {
//         V = GEP->getPointerOperand();
//       } else if (auto *BC = dyn_cast<BitCastInst>(V)) {
//         V = BC->getOperand(0);
//       } else if (auto *ASC = dyn_cast<AddrSpaceCastInst>(V)) {
//         V = ASC->getOperand(0);
//       } else if (auto *CE = dyn_cast<ConstantExpr>(V)) {
//         // Handle constant expression GEPs and bitcasts
//         unsigned Opcode = CE->getOpcode();
//         if (Opcode == Instruction::GetElementPtr ||
//             Opcode == Instruction::BitCast ||
//             Opcode == Instruction::AddrSpaceCast) {
//           V = CE->getOperand(0);
//         } else {
//           break;
//         }
//       } else {
//         // Reached a base object (GlobalVariable, AllocaInst, Argument, etc.)
//         break;
//       }
//     }

//     return V;
//   }

//   /// Check if an atomic operation on this pointer is safe to elide.
//   ///
//   /// Safety requirements:
//   /// 1. Must be in default address space (not MMIO, GPU memory, etc.)
//   /// 2. Must be a local allocation (alloca) or a global variable
//   /// 3. Must not be volatile
//   /// 4. For globals: we've already verified no threads can access them
//   ///
//   /// We do NOT transform atomics through function arguments because:
//   /// - The argument might point to shared memory
//   /// - The caller might have passed memory accessible by other processes
//   bool isPointerSafeForElision(Value *Ptr) {
//     // Check 1: Address space must be default (0)
//     // Non-zero address spaces might be MMIO, GPU memory, etc.
//     Type *PtrTy = Ptr->getType();
//     if (auto *PT = dyn_cast<PointerType>(PtrTy)) {
//       if (PT->getAddressSpace() != 0) {
//         errs() << "[HFTAtomicElision] SKIP: Pointer in non-default address space "
//                << PT->getAddressSpace() << "\n";
//         return false;
//       }
//     }

//     // Check 2: Find the base object
//     Value *Base = getUnderlyingObject(Ptr);

//     // Case A: Alloca (stack allocation) - always safe in single-thread mode
//     if (isa<AllocaInst>(Base)) {
//       return true;
//     }

//     // Case B: Global variable
//     if (auto *GV = dyn_cast<GlobalVariable>(Base)) {
//       // Globals with internal/private linkage can't be accessed externally
//       // Globals with external linkage could theoretically be accessed by
//       // other processes via shared memory, but:
//       // 1. We've verified no threads are spawned
//       // 2. True shared memory would use specific APIs we don't detect
//       //
//       // For HFT single-thread mode, we transform all globals.
//       // This matches the spec: if no threads exist, atomics are unnecessary.
//       return true;
//     }

//     // Case C: Function argument - NOT safe
//     // The pointer might come from the caller and point to shared memory
//     if (isa<Argument>(Base)) {
//       errs() << "[HFTAtomicElision] SKIP: Atomic through function argument "
//              << "(may point to shared memory)\n";
//       return false;
//     }

//     // Case D: Other (phi nodes, select, call returns, etc.) - NOT safe
//     // These are complex to analyze; be conservative
//     errs() << "[HFTAtomicElision] SKIP: Atomic through complex pointer expression\n";
//     return false;
//   }

//   //===========================================================================
//   // Transformation Functions
//   //===========================================================================

//   /// Transform an atomic load to a plain load.
//   /// Returns true if transformation was applied.
//   bool transformAtomicLoad(LoadInst *LI) {
//     // Safety checks
//     if (!isPointerSafeForElision(LI->getPointerOperand()))
//       return false;

//     if (LI->isVolatile()) {
//       errs() << "[HFTAtomicElision] SKIP: Volatile atomic load\n";
//       return false;
//     }

//     // Transform: simply remove the atomic ordering
//     // setAtomic(NotAtomic) clears the atomic flag and sets ordering to NotAtomic
//     LI->setAtomic(AtomicOrdering::NotAtomic);

//     return true;
//   }

//   /// Transform an atomic store to a plain store.
//   /// Returns true if transformation was applied.
//   bool transformAtomicStore(StoreInst *SI) {
//     // Safety checks
//     if (!isPointerSafeForElision(SI->getPointerOperand()))
//       return false;

//     if (SI->isVolatile()) {
//       errs() << "[HFTAtomicElision] SKIP: Volatile atomic store\n";
//       return false;
//     }

//     // Transform: simply remove the atomic ordering
//     SI->setAtomic(AtomicOrdering::NotAtomic);

//     return true;
//   }

//   /// Transform an atomicrmw instruction to a non-atomic load-op-store sequence.
//   ///
//   /// Before: %old = atomicrmw add ptr %p, i64 1 acquire
//   /// After:  %old = load i64, ptr %p
//   ///         %new = add i64 %old, 1
//   ///         store i64 %new, ptr %p
//   ///
//   /// Returns true if transformation was applied.
//   bool transformAtomicRMW(AtomicRMWInst *RMW) {
//     // Safety checks BEFORE creating any new instructions
//     if (!isPointerSafeForElision(RMW->getPointerOperand()))
//       return false;

//     if (RMW->isVolatile()) {
//       errs() << "[HFTAtomicElision] SKIP: Volatile atomicrmw\n";
//       return false;
//     }

//     // Check if we support this atomic operation
//     AtomicRMWInst::BinOp Op = RMW->getOperation();
//     if (!isSupportedRMWOperation(Op)) {
//       errs() << "[HFTAtomicElision] SKIP: Unsupported atomicrmw operation\n";
//       return false;
//     }

//     // All checks passed - now we can create new instructions
//     IRBuilder<> Builder(RMW);
//     Value *Ptr = RMW->getPointerOperand();
//     Value *Val = RMW->getValOperand();
//     Type *ValTy = RMW->getType();

//     // Step 1: Load the current value
//     // Use the same name as the atomicrmw for easier debugging
//     StringRef BaseName = RMW->getName();
//     std::string LoadName = BaseName.empty() ? "rmw.old" : (BaseName + ".old").str();
//     Value *OldVal = Builder.CreateLoad(ValTy, Ptr, LoadName);

//     // Step 2: Compute the new value
//     std::string NewName = BaseName.empty() ? "rmw.new" : (BaseName + ".new").str();
//     Value *NewVal = createRMWOperation(Builder, Op, OldVal, Val, NewName);

//     if (!NewVal) {
//       // This shouldn't happen since we checked isSupportedRMWOperation,
//       // but handle it gracefully
//       errs() << "[HFTAtomicElision] ERROR: Failed to create RMW operation\n";
//       // Clean up the load we created
//       cast<Instruction>(OldVal)->eraseFromParent();
//       return false;
//     }

//     // Step 3: Store the new value
//     Builder.CreateStore(NewVal, Ptr);

//     // Step 4: Replace all uses of the atomicrmw with the old value
//     // (atomicrmw returns the value BEFORE the operation)
//     RMW->replaceAllUsesWith(OldVal);

//     // Step 5: Delete the original atomicrmw
//     RMW->eraseFromParent();

//     return true;
//   }

//   /// Check if we support transforming this atomicrmw operation.
//   bool isSupportedRMWOperation(AtomicRMWInst::BinOp Op) {
//     switch (Op) {
//     case AtomicRMWInst::Xchg:  // Exchange
//     case AtomicRMWInst::Add:   // Integer add
//     case AtomicRMWInst::Sub:   // Integer sub
//     case AtomicRMWInst::And:   // Bitwise AND
//     case AtomicRMWInst::Or:    // Bitwise OR
//     case AtomicRMWInst::Xor:   // Bitwise XOR
//     case AtomicRMWInst::Nand:  // Bitwise NAND
//     case AtomicRMWInst::Max:   // Signed integer max
//     case AtomicRMWInst::Min:   // Signed integer min
//     case AtomicRMWInst::UMax:  // Unsigned integer max
//     case AtomicRMWInst::UMin:  // Unsigned integer min
//     case AtomicRMWInst::FAdd:  // Floating-point add
//     case AtomicRMWInst::FSub:  // Floating-point sub
//     case AtomicRMWInst::FMax:  // Floating-point max
//     case AtomicRMWInst::FMin:  // Floating-point min
//       return true;
//     default:
//       // BAD_BINOP or future operations we don't handle
//       return false;
//     }
//   }

//   /// Create the non-atomic equivalent of an atomicrmw operation.
//   Value *createRMWOperation(IRBuilder<> &Builder, AtomicRMWInst::BinOp Op,
//                             Value *OldVal, Value *Operand, const std::string &Name) {
//     switch (Op) {
//     case AtomicRMWInst::Xchg:
//       // Exchange: new value is just the operand
//       return Operand;

//     case AtomicRMWInst::Add:
//       return Builder.CreateAdd(OldVal, Operand, Name);

//     case AtomicRMWInst::Sub:
//       return Builder.CreateSub(OldVal, Operand, Name);

//     case AtomicRMWInst::And:
//       return Builder.CreateAnd(OldVal, Operand, Name);

//     case AtomicRMWInst::Or:
//       return Builder.CreateOr(OldVal, Operand, Name);

//     case AtomicRMWInst::Xor:
//       return Builder.CreateXor(OldVal, Operand, Name);

//     case AtomicRMWInst::Nand:
//       // NAND = NOT(AND(a, b))
//       return Builder.CreateNot(Builder.CreateAnd(OldVal, Operand), Name);

//     case AtomicRMWInst::Max:
//       // Signed max: select(old > operand, old, operand)
//       return Builder.CreateSelect(
//           Builder.CreateICmpSGT(OldVal, Operand),
//           OldVal, Operand, Name);

//     case AtomicRMWInst::Min:
//       // Signed min: select(old < operand, old, operand)
//       return Builder.CreateSelect(
//           Builder.CreateICmpSLT(OldVal, Operand),
//           OldVal, Operand, Name);

//     case AtomicRMWInst::UMax:
//       // Unsigned max
//       return Builder.CreateSelect(
//           Builder.CreateICmpUGT(OldVal, Operand),
//           OldVal, Operand, Name);

//     case AtomicRMWInst::UMin:
//       // Unsigned min
//       return Builder.CreateSelect(
//           Builder.CreateICmpULT(OldVal, Operand),
//           OldVal, Operand, Name);

//     case AtomicRMWInst::FAdd:
//       return Builder.CreateFAdd(OldVal, Operand, Name);

//     case AtomicRMWInst::FSub:
//       return Builder.CreateFSub(OldVal, Operand, Name);

//     case AtomicRMWInst::FMax:
//       // Floating-point max using maxnum intrinsic
//       return Builder.CreateBinaryIntrinsic(Intrinsic::maxnum, OldVal, Operand);

//     case AtomicRMWInst::FMin:
//       // Floating-point min using minnum intrinsic
//       return Builder.CreateBinaryIntrinsic(Intrinsic::minnum, OldVal, Operand);

//     default:
//       return nullptr;
//     }
//   }

//   /// Transform a cmpxchg instruction to a non-atomic load-compare-select-store.
//   ///
//   /// Before: %res = cmpxchg ptr %p, i64 %expected, i64 %desired acq_rel acquire
//   ///         ; %res is { i64, i1 } - the old value and whether CAS succeeded
//   ///
//   /// After:  %old = load i64, ptr %p
//   ///         %success = icmp eq i64 %old, %expected
//   ///         %newval = select i1 %success, i64 %desired, i64 %old
//   ///         store i64 %newval, ptr %p
//   ///         ; Construct { %old, %success } to replace uses
//   ///
//   /// Returns true if transformation was applied.
//   bool transformCmpXchg(AtomicCmpXchgInst *CX) {
//     // Safety checks
//     if (!isPointerSafeForElision(CX->getPointerOperand()))
//       return false;

//     if (CX->isVolatile()) {
//       errs() << "[HFTAtomicElision] SKIP: Volatile cmpxchg\n";
//       return false;
//     }

//     IRBuilder<> Builder(CX);
//     Value *Ptr = CX->getPointerOperand();
//     Value *Expected = CX->getCompareOperand();
//     Value *Desired = CX->getNewValOperand();
//     Type *ValTy = Expected->getType();

//     StringRef BaseName = CX->getName();
//     std::string Prefix = BaseName.empty() ? "cx" : BaseName.str();

//     // Step 1: Load the current value
//     Value *OldVal = Builder.CreateLoad(ValTy, Ptr, Prefix + ".old");

//     // Step 2: Compare with expected value
//     Value *Success;
//     if (ValTy->isFloatingPointTy()) {
//       // For floating-point, use ordered equality (OEQ)
//       // This matches the semantics of atomic cmpxchg on floats
//       Success = Builder.CreateFCmpOEQ(OldVal, Expected, Prefix + ".success");
//     } else {
//       // Integer comparison
//       Success = Builder.CreateICmpEQ(OldVal, Expected, Prefix + ".success");
//     }

//     // Step 3: Select the value to store
//     // If comparison succeeded, store Desired; otherwise store OldVal (no change)
//     Value *ToStore = Builder.CreateSelect(Success, Desired, OldVal, Prefix + ".tostore");

//     // Step 4: Store the result
//     Builder.CreateStore(ToStore, Ptr);

//     // Step 5: Construct the return value { OldVal, Success }
//     // cmpxchg returns a struct containing the loaded value and a success flag
//     Type *ResultTy = CX->getType();
//     Value *Result = UndefValue::get(ResultTy);
//     Result = Builder.CreateInsertValue(Result, OldVal, 0, Prefix + ".res.val");
//     Result = Builder.CreateInsertValue(Result, Success, 1, Prefix + ".res.succ");

//     // Step 6: Replace uses and delete
//     CX->replaceAllUsesWith(Result);
//     CX->eraseFromParent();

//     return true;
//   }

//   /// Remove a fence instruction, unless it's a signal fence.
//   ///
//   /// Signal fences (SyncScope::SingleThread) are used for signal handler
//   /// synchronization, not thread synchronization. They should be preserved
//   /// because signals can still occur in single-threaded code.
//   ///
//   /// Returns true if the fence was removed.
//   bool removeFence(FenceInst *FI) {
//     // Check for signal fence (single-thread sync scope)
//     // A signal fence has SyncScope::SingleThread
//     SyncScope::ID Scope = FI->getSyncScopeID();

//     if (Scope == SyncScope::SingleThread) {
//       errs() << "[HFTAtomicElision] KEEP: Signal fence (singlethread scope)\n";
//       return false;
//     }

//     // Remove the fence
//     FI->eraseFromParent();
//     return true;
//   }
// };

// extern "C" ::llvm::PassPluginLibraryInfo LLVM_ATTRIBUTE_WEAK llvmGetPassPluginInfo() {
//   return {
//     LLVM_PLUGIN_API_VERSION, "HFTPasses", "v0.1",
//     [](PassBuilder &PB) {
//       // Register function passes
//       PB.registerPipelineParsingCallback(
//         [](StringRef Name, FunctionPassManager &FPM,
//            ArrayRef<PassBuilder::PipelineElement>) {
//           if (Name == "hft-print") {
//             FPM.addPass(HFTPrintPass());
//             return true;
//           }
//           return false;
//         }
//       );

//       // Register module passes
//       PB.registerPipelineParsingCallback(
//         [](StringRef Name, ModulePassManager &MPM,
//            ArrayRef<PassBuilder::PipelineElement>) {
//           if (Name == "hft-split") {
//             MPM.addPass(HFTHotColdStructSplitPass());
//             return true;
//           }
//           if (Name == "hft-atomic-elision") {
//             MPM.addPass(HFTAtomicElisionPass());
//             return true;
//           }
//           return false;
//         }
//       );
//     }
//   };
// }

//===----------------------------------------------------------------------===//
// HFT Atomic Elision Pass
//
// This pass removes unnecessary atomic operations and fences in code that is
// verified to be single-threaded. This is safe because:
// 1. We verify no thread-spawning functions are called
// 2. We verify the module is compiled with single-thread mode
// 3. We only transform atomics on memory that cannot be accessed by other
//    processes (no MMIO, no shared memory regions)
//===----------------------------------------------------------------------===//

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
    
    //=========================================================================
    // DEBUG: List all functions
    //=========================================================================
    errs() << "\n[DEBUG] Functions in module:\n";
    for (Function &F : M) {
      errs() << "  - " << F.getName() 
             << (F.isDeclaration() ? " (declaration)" : " (definition)") << "\n";
    }

    //=========================================================================
    // DEBUG: List all global variables
    //=========================================================================
    errs() << "\n[DEBUG] Global variables:\n";
    for (GlobalVariable &GV : M.globals()) {
      errs() << "  - " << GV.getName() << " : " << *GV.getValueType() << "\n";
    }

    //=========================================================================
    // PHASE 1: Safety verification
    //=========================================================================
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

    //=========================================================================
    // PHASE 2: Collect all atomic operations
    //=========================================================================
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

    //=========================================================================
    // PHASE 3: Transform each atomic operation
    //=========================================================================
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

    //=========================================================================
    // PHASE 4: Report results
    //=========================================================================
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
  //===========================================================================
  // Safety Analysis Helpers
  //===========================================================================

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

  //===========================================================================
  // Transformation Functions
  //===========================================================================

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