**HFT-Aware Data Layout and Atomic Elision in LLVM**

## **1. Big Picture**

### **1.1 Motivation**

High-frequency trading (HFT) systems live and die by **microseconds**. A
typical HFT engine:

- Keeps a large **order book** in memory (arrays of levels, orders,
  trades).

- Processes **millions of messages per second** from exchanges.

- Often runs its hot path on a **single dedicated CPU core**.

Two recurring performance pain points:

1.  **Poor data layout\**

    - Large structs mix fields that are:

      - touched every message (price, size, side), with

      - fields used rarely (debug info, audit IDs, extra metadata).

    - This causes **cache misses**, more memory traffic, and worse
      latency

2.  **Unnecessary atomics & fences\**

    - Codebases reuse data structures across:

      - multi-threaded backtesting/simulation, and

      - single-threaded production engines on a pinned core.

    - For safety, everything is written with std::atomic, fences, and
      strong memory ordering.

    - In a truly single-threaded build, these are **semantically
      redundant**, but still cost cycles and complicate the pipeline.

We want a compiler mode that understands:

> "This is order-book-style HFT code, running single-threaded. Optimize
> the data layout for cache, and strip away unnecessary concurrency
> overhead."

This directly reflects the ideas in Chilimbi's work on **cache-conscious
structure splitting** and **field reordering**, combined with practical
HFT concerns around atomics and single-core deployments.

## **2. Problem Statement**

### **2.1 Technical problem**

Given a C/C++ codebase that:

- Uses **POD (Plain Old Data) structs** to represent order books,
  levels, orders, etc.

- Uses **arrays** or **vectors** of these structs in the hot path (AoS
  layout).

- Uses **std::atomic** and memory fences in its hot loop but is compiled
  for a **single thread**,

we want to automatically:

1.  **Restructure data** so hot fields are tightly packed and cold
    fields are moved out of the way.

2.  Optionally convert **Array of Structs (AoS)** into **Struct of
    Arrays (SoA)** for certain hot arrays.

3.  **Remove or weaken atomic/fence operations** that are unnecessary in
    a single-threaded build.

All transformations must:

- **Preserve program semantics** under clearly defined assumptions.

- Only apply when **profiling data** shows the optimization is
  **profitable**, not just legal.

### **2.2 Project goals**

**Primary goals**

1.  Implement an LLVM-based, profile-guided optimization pipeline that:

    - Identifies **hot and cold fields** in HFT-relevant structs.

    - Performs **structure splitting** and **field reordering** for
      eligible structs.

    - Optionally performs **AoS→SoA** for simple hot arrays of those
      structs.

    - Removes or weakens **atomic and fence operations** under a
      single-thread build mode.

2.  Build a **toy HFT order-book engine** + benchmarks to:

    - Generate realistic access patterns.

    - Demonstrate performance improvements (cycle counts and cache
      metrics).

3.  Provide a clear **correctness story**:

    - Explicit legality checks.

    - Explicit profitability heuristics (inspired by Chilimbi).

## **3. What We Are Building**

### **3.1 Input**

- C++ source implementing:

  - OrderBookLevel, OrderBook, Order, Trade, etc. as plain structs.

  - Hot loop processing market messages: on_message(msg) in a tight
    loop.

  - Some fields marked std::atomic for generality.

- Annotations:

  - \[\[hft_struct\]\] on structs that are allowed to have their layout
    changed.

  - Optional \[\[no_hft_layout_change\]\] on sensitive structs.

- Build flag:

  - -Dhft_single_thread_build to indicate single-thread compilation
    mode.

### **3.2 Output**

- A recompiled binary where:

  - Hot order-book structs have been **split** into hot and cold parts
    when profitable.

  - Their fields are **reordered** to improve cache locality.

  - Certain arrays of these structs are transformed from AoS to SoA
    (when safe and profitable).

  - Many atomic operations and fences on hot path fields have been
    **elided** or weakened in the single-thread build.

The final system consists of:

1.  A **profiling / instrumentation pass**.

2.  A **data layout optimization pass**:

    - structure splitting + field reordering + optional AoS→SoA.

3.  An **atomic / fence elision pass** for single-thread HFT builds.

4.  A **benchmark harness** (market data replay) to demonstrate
    speedups.

## **4. Why This Is Crucial in HFT**

- **L1 / L2 cache misses = latency spikes.\
  \**
  Structure splitting and field reordering are directly aimed at
  improving cache behavior for frequently accessed fields, which is
  exactly what HFT cares about: predictable, low latency on the hot
  message path.

- **AoS vs SoA is a real HFT design decision.\
  \**
  Many engines hand-roll SoA for order-book levels to enable
  vectorization and predictable cache access. Automating part of this
  with profiling makes the code more maintainable and safer.

- **Atomics and fences are expensive in the hot loop.\
  \**
  In a single-threaded environment, strong atomics are unnecessary but
  still incur instruction and pipeline cost. A compiler pass that safely
  strips them in a dedicated **"HFT single-core build"** is extremely
  valuable.

- **Interview / resume value.\
  \**
  This project touches:

  - cache-aware data structures,

  - AoS/SoA layout,

  - atomics/memory ordering,

  - compiler IR passes and PGO.\
    \
    It gives you a very concrete story to tell in both compiler and HFT
    interviews.

## **5. Detailed Design**

### **5.1 Data Model and Annotations**

We assume simple C++ structs, e.g.:

![](media/image9.png){width="2.8020833333333335in"
height="2.1354166666666665in"}

Constraints:

- POD, no virtual functions, no inheritance.

- Not used in network packet layouts or external ABIs, unless explicitly
  opted out.

We introduce:

- \[\[hft_struct\]\] → opt-in for layout changes.

- \[\[no_hft_layout_change\]\] → opt-out for safety.

- Build flag hft_single_thread_build → to control atomic/fence elision.

### **5.2 Profiling / Instrumentation Pass**

**Purpose**: Collect dynamic field access counts and basic block counts.

**Mechanism**:

1.  For each \[\[hft_struct\]\] type S:

    - Assign each field [![](media/image10.png){width="0.125in"
      height="0.16666666666666666in"}](https://www.codecogs.com/eqnedit.php?latex=f_j#0)
      an index j.

    - Insert lightweight counters in IR where fields are accessed
      (loads/stores via GEPs).

2.  Maintain:

    - Ai = total field accesses to struct
      [![](media/image8.png){width="0.125in"
      height="0.1388888888888889in"}](https://www.codecogs.com/eqnedit.php?latex=S_i#0).

    - [![](media/image3.png){width="0.6527777777777778in"
      height="0.16666666666666666in"}](https://www.codecogs.com/eqnedit.php?latex=count(f_j)#0)
      = dynamic count for each field.

    - LS = total field accesses across all structs.

    - C = number of structs with ≥1 access.

3.  Optionally:

    - Record which functions / basic blocks are on the hot path (counts
      per block).

**Output**:

- A profile file (or embedded metadata) containing:

  - per-struct Ai, Fi, field counts,

  - total LS, C,

  - hot-path block info.

### 5.2.1 Discovery & Classification Pass (reuse HW2 helpers)

Before running the data layout optimization pass, we will implement a small
"Discovery & Classification" pass that scans the IR and marks which LLVM
`StructType`s are structurally safe for layout changes and potentially relevant
to the hot path.

Implementation note (code reuse):

- This pass will reuse the pointer canonicalization helpers from `hw2pass.cpp`
  (`stripCasts`, `canonicalPtr`, and `ptrEqualCanonical`) when reasoning about
  how struct pointers are used (e.g., filtering out structs that participate in
  raw `memcpy` / `memcmp` / `read` / `write` patterns or opaque bitcasts).
- The pass will also reuse the basic loop/block iteration patterns and analysis
  retrieval idioms from `hw1pass.cpp` to traverse hot functions and identify
  candidate structs.

### **5.3 Data Layout Optimization Pass**

This pass consumes the profile and performs:

1.  **Eligibility filtering** (legality).

2.  **Profitability analysis** (is it worth it?).

3.  **Structure splitting** (hot/cold).

4.  **Field reordering** within hot and cold parts.

5.  **Optional AoS→SoA** conversion for selected arrays.

#### **5.3.1 Legality checks**

A struct S is **not** transformed if:

- It has:

  - virtual methods, inheritance, bitfields, flexible arrays.

  - explicit packing/alignment pragmas.

- It is:

  - used in memcpy, memcmp, read, write, or other raw byte operations.

  - involved in reinterpret_cast to/from unrelated types.

- It is:

  - tagged \[\[no_hft_layout_change\]\], or

  - observed in any extern \"C\" interface.

Only \[\[hft_struct\]\] structs that pass all these checks are
considered.

#### **5.3.2 Profitability heuristics (from the paper)**

We use the same style as Chilimbi:

- **"Live" struct rule**: only consider
  [![](media/image8.png){width="0.125in"
  height="0.1388888888888889in"}](https://www.codecogs.com/eqnedit.php?latex=S_i#0)
  if\
  \
  [![](media/image5.png){width="0.9166666666666666in"
  height="0.3472222222222222in"}](https://www.codecogs.com/eqnedit.php?latex=A_i%20%3E%20%5Cfrac%7BL_S%7D%7B100%20%5Ccdot%20C%7D#0)\
  \
  i.e., its total field accesses are significant.

- **Size / field-count constraints**:

  - sizeof(S_i) \> 8 bytes, and

  - [![](media/image6.png){width="0.125in"
    height="0.1388888888888889in"}](https://www.codecogs.com/eqnedit.php?latex=F_i#0)
    \> 2 fields.

- **Field hot/cold classification**:

  - mark field f as cold if\
    \
    [![](media/image12.png){width="1.2361111111111112in"
    height="0.375in"}](https://www.codecogs.com/eqnedit.php?latex=count(f)%20%3C%20%5Cfrac%7BA_i%7D%7B2%20%5Ccdot%20F_i%7D#0)\
    \
    otherwise hot.

- **Temperature differential**:

  - compute the "temperature differential"
    [![](media/image11.png){width="0.5277777777777778in"
    height="0.16666666666666666in"}](https://www.codecogs.com/eqnedit.php?latex=TD(S_i)#0)
    as in the paper,

  - require normalized TD \> 0.5 for aggressive splitting; otherwise use
    more conservative "very cold" threshold.

- **Cold size threshold**:

  - only split if the aggregate size of cold fields ≥ pointer size
    (e.g., ≥8 bytes).

If these profitability conditions fail, we leave
[![](media/image8.png){width="0.125in"
height="0.1388888888888889in"}](https://www.codecogs.com/eqnedit.php?latex=S_i#0)
unchanged (or only lightly reorder fields).

#### **5.3.3 Structure splitting algorithm**

For an eligible, profitable struct S:

1.  Partition fields into hot_fields and cold_fields.

2.  Construct new LLVM types:

    - [![](media/image7.png){width="0.2916666666666667in"
      height="0.1388888888888889in"}](https://www.codecogs.com/eqnedit.php?latex=S_hot#0)
      containing hot_fields (reordered by hotness).

    - [![](media/image1.png){width="0.375in"
      height="0.1388888888888889in"}](https://www.codecogs.com/eqnedit.php?latex=S_cold#0)
      containing cold_fields (reordered for compactness).

3.  Choose representation:

    - For **arrays** of S:

      - either maintain S_hot arr_hot\[N\]; and S_cold arr_cold\[N\]; in
        parallel, or

      - store in S_hot a pointer/index to its S_cold.

4.  Rewrite IR:

    - Any access to a hot field is redirected to S_hot.

    - Any access to a cold field goes through the cold pointer/index.

    - getelementptr instructions are updated accordingly.

We will start with **parallel arrays** (arr_hot + arr_cold) because it
simplifies the transformation.

#### **5.3.4 Field reordering algorithm**

Within S_hot and S_cold:

1.  Sort fields by **frequency** (descending).

2.  Respect alignment requirements so no misaligned loads/stores.

3.  Optionally cluster fields with strong **affinity** (often accessed
    together) to fit into single cache lines.

If the affinity graph is essentially flat (no clear clusters), we may
skip fancy clustering and simply sort by hotness.

#### **5.3.5 AoS→SoA conversion**

We only do this for arrays that:

- Are arrays or simple vectors of S_hot or original S.

- Are accessed using straightforward indexing (arr\[i\].field).

- Do not escape as void\* or to external functions that assume AoS
  layout.

For such arrays:

1.  For selected fields (price, size), create separate arrays:

    - double price\[N\];

    - int size\[N\];

2.  Rewrite loops so they access these arrays instead of arr\[i\].field.

3.  Leave rarely used fields in:

    - a companion array S_cold cold\[N\], or

    - a side structure.

We can treat AoS→SoA as an optional "phase 2" optimization after
splitting/reordering works.

### **5.4 Atomic / Fence Elision Pass**

This pass assumes the hft_single_thread_build flag is set.

#### **5.4.1 Safety conditions**

We only run the transform if:

- Module flag hft.single_thread = true.

- No calls found to:

  - pthread_create, std::thread constructors, std::async, or
    user-specified thread-start functions.

- For each atomic variable we consider:

  - It lives in a \[\[hft_struct\]\] or a function-scope variable.

  - Its address does not escape to unknown external code.

  - It is not declared volatile.

  - It is not in a custom address space (e.g., MMIO).

If any of these checks fail, we keep atomics and fences unchanged.

#### **5.4.2 Transformations**

Within those safety conditions:

- **Atomic loads/stores**:

  - load atomic → plain load.

  - store atomic → plain store.

- **Atomic read-modify-write (atomicrmw) and cmpxchg**:

  - For simple patterns (counters, flags), replace with:

    - load → operation → store (no atomic).

  - If usage suggests spin locks or complex lock-free structures, leave
    as-is.

- **Fences**:

  - Remove fence instructions entirely in single-thread mode.

  - Keep signal fences if present (mostly irrelevant here).

Optionally, as a stretch goal, we can have a weaker mode that downgrades
seq_cst / acquire_release to monotonic instead of dropping atomics
fully.

### **5.5 Compilation Pipeline**

A typical pipeline:

1.  **Profile build**:

    - Compile with instrumentation pass enabled.

    - Run benchmark (market data replay) to generate profile.

2.  **Optimized build**:

    - Recompile with:

      - LLVM PGO (if desired).

      - Our **data layout pass** using the profile.

      - Our **atomic/fence elision pass** with hft_single_thread_build
        flag.

    - Then run standard -O3 optimization pipeline.

3.  **Run benchmarks** and compare:

    - Baseline -O3.

    - -O3 + layout pass.

    - -O3 + layout + atomic-elision.

### **5.6 Evaluation Plan**

For each benchmark (toy order book, ring buffer, etc.):

- Measure:

  - Time per message or operation.

  - Total cycles (via std::chrono or RDTSC).

  - Cache misses (L1/L2/L3) and branch/inst stats using perf if
    available.

- Visualize:

  - Before/after struct layouts (ASCII cache-line diagrams).

  - Before/after IR for atomics.

  - Performance plots.

## **5.7 Code Reuse from HW1 and HW2**

To avoid re-implementing already-tested LLVM pass patterns, this project will
explicitly reuse code from earlier course homeworks:

- From `hw1pass.cpp`:
  - Pass plugin scaffolding (PassPluginLibraryInfo, pipeline parsing callback).
  - Function pass `run` structure and analysis retrieval (`BlockFrequencyAnalysis`,
    `BranchProbabilityAnalysis`, `LoopAnalysis`).
  - Function/loop/basic-block instruction traversal patterns.

- From `hw2pass.cpp`:
  - Helper functions `stripCasts`, `canonicalPtr`, and `ptrEqualCanonical` for
    pointer canonicalization and equality checks.
  - Frequent-path builder `buildFrequentPath` and the associated logic for
    computing `FrequentOrder` and `FrequentBlocks`.
  - IR transformation patterns demonstrated in `replaceLoopUsesWithSlotLoads`
    for safely rewriting uses with newly generated loads/stores inside loops.

All new passes (discovery/classification, profiling, data layout, AoS→SoA, and
atomic/fence elision) should **start by copying and adapting these existing
helpers** instead of designing fresh implementations. Any AI assistant working
on this repository should first consult `hw1pass.cpp` and `hw2pass.cpp` for
these patterns and reuse them where possible.

## **6. Step-by-Step Build Plan**

We want an incremental, testable path. Each step should **compile and
run** and give us feedback

### **Phase 0 -- Setup and Baseline**

**Goal:** Have a working "toy HFT engine" and a minimal LLVM pass
skeleton.

Tasks:

1.  **Set up LLVM dev environment\**

    - Clone correct version.

    - Build clang, opt, and a pass template.

2. **Reuse HW1 pass skeleton**: The LLVM pass plugin scaffolding from `hw1pass.cpp`
      (including `PassPluginLibraryInfo`, `registerPipelineParsingCallback`, and the
      `PreservedAnalyses run(Function &F, FunctionAnalysisManager &FAM)` structure)
      will be copied and adapted as the base template for all project passes
      (discovery/classification, profiling, data layout, and atomic-elision). We do **not**
      re-implement this boilerplate from scratch; we extend and rename the existing `HW1Pass`
      code.

3.  **Implement toy HFT engine\**

    - Implement:

      - OrderBookLevel, OrderBook, etc. as simple structs.

      - message types: add, cancel, modify.

      - on_message(msg) hot loop.

    - Add some std::atomic fields (e.g., version, sequence numbers) even
      though we'll run single-threaded.

4.  **Baseline benchmark\**

    - Write a driver that:

      - loads N messages from a file or generates synthetic ones,

      - processes them in a tight loop.

    - Measure baseline -O3 performance (just cycles/message).

**Why this is necessary:**

You need a realistic workload and a known baseline before you modify
anything. This also proves your build environment is solid.

### **Phase 1 -- Profiling Infrastructure (Instrumentation Pass)**

**Goal:** Collect field access counts for \[\[hft_struct\]\] structs.

Tasks:

1.  **Start from HW1 `run` implementation**: The instrumentation pass will reuse the
    HW1 `HW1Pass::run` function structure from `hw1pass.cpp` as a template for:
    fetching `BlockFrequencyAnalysis`, `BranchProbabilityAnalysis`, and `LoopAnalysis`,
    and for iterating over functions, loops, basic blocks, and instructions. The new
    pass will replace the HW1 counting logic with field-access counters, but the
    overall control structure and analysis usage are inherited from HW1.

2.  **Reuse pointer canonicalization logic from HW2**: When identifying and counting
    field accesses, we reuse the `stripCasts`, `canonicalPtr`, and `ptrEqualCanonical`
    helper functions from `hw2pass.cpp` to canonicalize pointers before deciding
    which struct/field a load/store refers to. This avoids re-writing subtle pointer
    reasoning logic and ensures that instrumentation attaches to the correct underlying
    object even in the presence of GEPs, bitcasts, or addrspace casts.

3.  **Add \[\[hft_struct\]\] annotation to candidate structs** in your
    code.

4.  **Implement instrumentation pass**:

    - For each load/store through a GEP into a \[\[hft_struct\]\],
      insert a counter increment.

    - Maintain global counters for:

      - per-field counts,

      - per-struct Ai,

      - totals LS, C.

5.  **Emit profile\**

    - At program exit or via a flush function, write counters to a file
      in a simple format (e.g., JSON or text).

6.  **Test\**

    - Rebuild with instrumentation.

    - Run benchmark.

    - Inspect profile file for sanity (numbers add up, etc.).

**Why it's necessary:**

All later decisions (split or not, cold vs hot, AoS→SoA or not) depend
on trustworthy profile data.

### **Phase 2 -- Structure Splitting (Minimal Version)**

**Goal:** Implement basic hot/cold splitting with conservative
heuristics.

Tasks:

1.  **Read profile data inside an LLVM pass**:

    - Map struct names → Ai, Fi, field access counts.

2.  **Leverage HW2 frequent-path utilities**: When restricting structure splitting to
    the hottest parts of the program, we will reuse the `buildFrequentPath` helper
    and associated `FrequentOrder` / `FrequentBlocks` logic from `hw2pass.cpp` as
    the mechanism for identifying frequent-path basic blocks inside each loop. The
    splitting pass should call `buildFrequentPath` to identify which blocks are
    considered "frequent" and prefer applying splitting/reordering to struct
    accesses in those blocks first.

3.  **Implement eligibility checks**:

    - Enforce POD, no raw byte ops, no external ABI, \[\[hft_struct\]\]
      only.

4.  **Implement simple profitability test**:

    - Use the **"live" struct** condition and **size/field-count**
      thresholds.

    - Mark a field cold if count(f) \< Ai/(2\*Fi).

    - Require cold size ≥ pointer size.

    - You can ignore temperature differential in this first iteration.

5.  **Implement splitting transform**:

    - For one simple pattern: arrays of S used only in your engine.

    - Create S_hot + S_cold and parallel arrays.

    - Update GEPs and accesses accordingly.

6.  **Test**:

    - Rebuild engine with this pass enabled.

    - Check that:

      i.  program still runs and produces identical results.

      ii. printing some structures shows changed layouts.

    - Measure performance impact (even if small).

**Why this is necessary:**

Gives you an end-to-end path: profile → transform → run. It's better to
get a simple splitting working and tested before layering more complex
heuristics and reordering.

### **Phase 3 -- Add Full Profitability Heuristics + Field Reordering**

**Goal:** Make splitting decisions smarter and reorder fields inside
hot/cold parts.

Tasks:

1.  **Reuse HW1 BFI/BPI integration**: When computing more refined profitability
    metrics (e.g., weighting field-access counts by dynamic block frequency),
    the pass will reuse the BFI/BPI integration pattern from `hw1pass.cpp` rather
    than re-implementing how block frequencies are accessed and combined.

2.  **Implement temperature differential logic** from the paper:

    - Compute TD(S_i), normalize, and use \>0.5 as threshold for
      aggressive splitting.

    - For lower TD, fallback to more conservative "very cold" threshold
      (e.g., Ai/(5\*Fi)).

3.  **Refine cold size checks**:

    - Confirm cold size is large enough to offset pointer cost.

4.  **Field reordering**:

    - Sort hot_fields by descending count(f).

    - Respect alignment; verify new layout in IR.

5.  **Re-run benchmarks**:

    - Compare:

      - baseline,

      - Phase 2 basic splitting,

      - Phase 3 improved heuristics + reordering.

**Why this is necessary:**

Now you're closer to the real research paper: not just "we split because
we can," but "we split when it's *statistically profitable*."

### **Phase 4 -- Optional AoS→SoA for Hot Arrays**

**Goal:** Transform specific arrays of hot structs into SoA when safe.

Tasks:

1. **Reuse HW2 IR rewriting pattern**: The AoS→SoA transformation will mirror the
    "replace uses with loads from a slot" pattern used in `replaceLoopUsesWithSlotLoads`
    in `hw2pass.cpp`. Specifically:
    - We will reuse the approach of collecting `Use`s inside a loop and replacing
      them with newly inserted IRBuilder-generated loads/stores.
    - This avoids re-inventing the delicate "update all uses inside a loop body
    while preserving correctness" logic.

2.  **Detect candidate arrays**:

    - Arrays/vectors of S_hot or original S used in tight loops.

    - All uses inside these loops are arr\[i\].field style (no escapes).

3.  **Transform representation**:

    - For each such array:

      - create separate arrays per hot field.

      - rewrite loops to use these arrays.

4.  **Correctness checks**:

    - Make sure no code outside these loops relies on AoS layout.

    - If in doubt, skip.

5.  **Benchmark**:

    - Run AoS vs AoS+split vs SoA+split.

    - Measure speedups; decide whether AoS→SoA becomes part of your
      "default" project or stays as a stretch feature.

**Why this is necessary:**

SoA is a major real-world HFT optimization; even a small, constrained
implementation shows you understand the tradeoffs.

### **Phase 5 -- Atomic / Fence Elision Pass (Single-Thread Mode)**

**Goal:** Strip unnecessary atomics/fences based on an explicit
contract.

Tasks:

1. **Use HW1/HW2 pass patterns for scanning**: The atomic/fence elision pass will
    reuse the same function/loop/block traversal and analysis access patterns from
    `hw1pass.cpp` and `hw2pass.cpp` (rather than introducing a new traversal
    style), to keep the codebase consistent and reduce the risk of subtle bugs in
    iteration logic.

2.  **Module flag and config**:

    - Add a compile-time flag that sets hft.single_thread = true.

3.  **Static safety checks**:

    - In your pass, scan for:

      - pthread_create, std::thread, std::async, custom thread-start.

    - If any are present, either:

      - abort the transform, or

      - restrict it to known single-thread regions.

4.  **Transform atomics**:

    - Replace load atomic / store atomic with plain operations for safe
      variables.

    - For atomicrmw / cmpxchg, handle simple patterns (counters, flags).

    - Remove fence instructions.

5.  **Testing**:

    - Run unit tests on small examples:

      - incremental counters,

      - flags,

      - your ring buffer.

    - Compare results to baseline to ensure semantics match in
      single-thread runs.

6.  **Benchmark**:

    - Measure impact on:

      - atomic-heavy toy code,

      - your order-book engine (version counters etc.).

**Why this is necessary:**

Atomics can significantly affect performance in tight loops; this step
ties in the concurrency story and makes the "HFT single-core build"
real.

### **Phase 6 -- Integration & Pipeline Polishing**

**Goal:** Make the whole system feel like a coherent compiler mode.

Tasks:

1.  **Integration script / CMake target**:

    - Provide simple commands:

      - make hft_profile_build

      - make hft_optimized_build

2.  **Pass ordering**:

    - Decide:

      - instrumentation before everything,

      - data-layout pass relatively early,

      - atomic-elision pass after inlining and before machine code.

3.  **Command-line options**:

    - Expose flags:

      - enable/disable splitting,

      - enable/disable AoS→SoA,

      - enable/disable atomic-elision.

**Why this is necessary:**

A polished pipeline is important for demoing and for your own sanity
while iterating.

### **Phase 7 -- Final Evaluation, Demo, and Report**

**Goal:** Produce convincing experimental results and a clean
demonstration.

Tasks:

1.  **Run all configurations**:

    - baseline -O3,

    - -O3 + layout,

    - -O3 + layout + atomic-elision,

    - optionally + AoS→SoA.

2.  **Collect metrics**:

    - cycles/message,

    - cache misses (if possible),

    - instruction count, branch misses.

3.  **Create visualizations**:

    - struct layouts before/after,

    - IR snippets before/after atomics,

    - speedup graphs.

4.  **Write report**:

    - Motivation & background (Chilimbi, HFT cache & concurrency
      issues).

    - Design, correctness conditions, heuristics.

    - Implementation details.

    - Evaluation & discussion.
