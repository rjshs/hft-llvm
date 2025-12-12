# #!/usr/bin/env bash
# set -e

# # Path to your atomic pass shared library.
# # Adjust this if your CMake target/path is different.
# LIB="build/hft_atomic/HFTAtomic.so"
# if [ ! -f "$LIB" ]; then
#   echo "HFTAtomicPass.so not found at $LIB; build first."
#   exit 1
# fi

# PATH2LIB=$(realpath "$LIB")

# if [ $# -lt 1 ]; then
#   echo "Usage: $0 <source.cpp>"
#   exit 1
# fi

# SRC_FILE=$1
# if [ ! -f "$SRC_FILE" ]; then
#   echo "Error: $SRC_FILE is not a file"
#   exit 1
# fi

# CURRENT_DIR=$(pwd)
# FILE_BASENAME=$(basename "$SRC_FILE")
# FILENAME=${FILE_BASENAME%.*}
# EXT=${FILE_BASENAME##*.}

# # Choose C vs C++
# if [ "$EXT" = "c" ]; then
#   COMPILER=/usr/local/bin/clang
# else
#   COMPILER=/usr/local/bin/clang++
# fi

# PASSES=(
#   "baseline"     # just loop-simplify
#   "hft-atomic-elision"   # your atomic pass
# )

# # Work in the source directory so the binaries sit next to the .cpp
# cd "$(dirname "$SRC_FILE")"

# # Clean old junk
# rm -f default.profraw *_prof *_fplicm *.bc *.profdata *_output *.ll \
#       ${FILENAME}_* 2>/dev/null || true

# # 1) Compile to LLVM bitcode (IR). Same as run_hft.
# $COMPILER -emit-llvm -c "$FILE_BASENAME" \
#   -Xclang -disable-O0-optnone \
#   -o ${FILENAME}.bc

# # 2) Normalize loops so passes are happy.
# opt -passes='loop-simplify' ${FILENAME}.bc -o ${FILENAME}.ls.bc

# echo
# echo "Atomic timing for $FILE_BASENAME"

# for PIPELINE in "${PASSES[@]}"; do
#   if [ "$PIPELINE" = "baseline" ]; then
#     OUT_BC="${FILENAME}.baseline.bc"
#     BIN="${FILENAME}_baseline"
#     cp ${FILENAME}.ls.bc "$OUT_BC"
#     echo
#     echo "--- Pipeline: baseline (loop-simplify only) ---"
#   else
#     OUT_BC="${FILENAME}.${PIPELINE}.bc"
#     BIN="${FILENAME}_${PIPELINE}"
#     echo
#     echo "--- Pipeline: $PIPELINE ---"
#     # It is registered as a MODULE pass, so we pass the name directly.
#     opt -load-pass-plugin="$PATH2LIB" \
#         -passes="${PIPELINE}" \
#         "${FILENAME}.ls.bc" -o "$OUT_BC" >/dev/null
#   fi

#   # Build binary
#   $COMPILER "$OUT_BC" -o "$BIN"

#   # Time it
#   echo "Running $BIN ..."
#   time "./$BIN" >/dev/null
# done

# # Clean again
# rm -f default.profraw *_prof *_fplicm *.bc *.profdata *.ll
# cd "$CURRENT_DIR"

#!/usr/bin/env bash
set -e

LIB="build/hft_atomic/HFTAtomic.so"
if [ ! -f "$LIB" ]; then
  echo "HFTAtomicPass.so not found at $LIB; build first."
  exit 1
fi

PATH2LIB=$(realpath "$LIB")

if [ $# -lt 1 ]; then
  echo "Usage: $0 <source.cpp>"
  exit 1
fi

SRC_FILE=$1
if [ ! -f "$SRC_FILE" ]; then
  echo "Error: $SRC_FILE is not a file"
  exit 1
fi

CURRENT_DIR=$(pwd)
FILE_BASENAME=$(basename "$SRC_FILE")
FILENAME=${FILE_BASENAME%.*}
EXT=${FILE_BASENAME##*.}

if [ "$EXT" = "c" ]; then
  COMPILER=/usr/local/bin/clang
else
  COMPILER=/usr/local/bin/clang++
fi

PASSES=(
  "baseline"
  "hft-atomic-elision"
)

cd "$(dirname "$SRC_FILE")"

rm -f default.profraw *_prof *_fplicm *.bc *.profdata *_output *.ll \
      ${FILENAME}_* 2>/dev/null || true

# ============================================================================
# FIX 1: Compile with -O1 to get realistic IR with atomics preserved
# -O1 keeps atomics visible while removing trivial inefficiencies
# -O0 produces terribly slow code that masks all other effects
# ============================================================================
echo "Compiling to LLVM IR with -O1..."
$COMPILER -O1 -emit-llvm -S "$FILE_BASENAME" -o ${FILENAME}.ll

# Convert to bitcode
llvm-as ${FILENAME}.ll -o ${FILENAME}.bc

# Normalize loops
opt -passes='loop-simplify' ${FILENAME}.bc -o ${FILENAME}.ls.bc

echo
echo "=========================================="
echo "Atomic Elision Benchmark: $FILE_BASENAME"
echo "=========================================="

for PIPELINE in "${PASSES[@]}"; do
  if [ "$PIPELINE" = "baseline" ]; then
    OUT_BC="${FILENAME}.baseline.bc"
    BIN="${FILENAME}_baseline"
    cp ${FILENAME}.ls.bc "$OUT_BC"
    echo
    echo "--- BASELINE (no atomic elision) ---"
  else
    OUT_BC="${FILENAME}.${PIPELINE}.bc"
    BIN="${FILENAME}_${PIPELINE}"
    echo
    echo "--- OPTIMIZED (atomic elision applied) ---"
    
    # Run our pass and capture output
    opt -load-pass-plugin="$PATH2LIB" \
        -passes="${PIPELINE}" \
        "${FILENAME}.ls.bc" -o "$OUT_BC" 2>&1 | grep -E "^\[" | head -20
  fi

  # ============================================================================
  # FIX 2: Compile final binary with -O3 for realistic performance
  # ============================================================================
  $COMPILER -O3 "$OUT_BC" -o "$BIN"

  # Run benchmark 3 times and show all results
  echo "Running $BIN (3 trials)..."
  for i in 1 2 3; do
    echo -n "  Trial $i: "
    # Use the program's internal timing (more accurate than shell time)
    "./$BIN" 2>&1 | grep -E "(Time|Throughput|Latency)" | tr '\n' ' '
    echo
  done
done

# ============================================================================
# FIX 3: Show the actual difference in the IR
# ============================================================================
echo
echo "=========================================="
echo "IR Comparison"
echo "=========================================="
echo "Baseline atomics:  $(grep -c 'atomic' ${FILENAME}.baseline.bc.ll 2>/dev/null || echo 'N/A')"
echo "Optimized atomics: $(grep -c 'atomic' ${FILENAME}.${PASSES[1]}.bc.ll 2>/dev/null || echo 'N/A')"

# Generate readable IR for inspection
opt -passes='loop-simplify' ${FILENAME}.bc -S -o ${FILENAME}.baseline.ll
opt -load-pass-plugin="$PATH2LIB" -passes="hft-atomic-elision" ${FILENAME}.bc -S -o ${FILENAME}.optimized.ll 2>/dev/null

echo
echo "Atomic instructions in baseline:"
grep -c "atomicrmw\|cmpxchg\|load atomic\|store atomic" ${FILENAME}.baseline.ll || echo "0"

echo "Atomic instructions after elision:"
grep -c "atomicrmw\|cmpxchg\|load atomic\|store atomic" ${FILENAME}.optimized.ll || echo "0"

# Cleanup
rm -f default.profraw *_prof *_fplicm *.bc *.profdata 2>/dev/null || true
cd "$CURRENT_DIR"

echo
echo "Done! Binaries left in place for inspection."
echo "  ${FILENAME}_baseline"
echo "  ${FILENAME}_hft-atomic-elision"
```

## Key Fixes

| Issue | Before | After |
|-------|--------|-------|
| Initial compilation | No `-O` flag (O0) | `-O1` |
| Final binary | No `-O` flag (O0) | `-O3` |
| Visibility | Suppressed pass output | Shows pass results |
| Verification | None | Counts atomics before/after |
| Trials | Single run | 3 runs for consistency |

## Why `-O1` for Initial IR?

- **`-O0`**: Keeps all atomics but produces horribly slow code
- **`-O1`**: Keeps atomics visible, removes trivial inefficiencies
- **`-O2`/`-O3`**: May optimize some atomics away before our pass sees them

## Expected Output

After fixing, you should see something like:
```
========================================== 
Atomic Elision Benchmark: orderbook.cpp
==========================================

--- BASELINE (no atomic elision) ---
Running orderbook_baseline (3 trials)...
  Trial 1: Time: 850 ms Throughput: 11.7 M msgs/sec Latency: 85 ns/msg
  Trial 2: Time: 848 ms Throughput: 11.8 M msgs/sec Latency: 84.8 ns/msg
  Trial 3: Time: 852 ms Throughput: 11.7 M msgs/sec Latency: 85.2 ns/msg

--- OPTIMIZED (atomic elision applied) ---
[SUCCESS] Elided: Loads: 15, Stores: 14, RMWs: 4, CmpXchg: 1
Running orderbook_hft-atomic-elision (3 trials)...
  Trial 1: Time: 720 ms Throughput: 13.9 M msgs/sec Latency: 72 ns/msg
  Trial 2: Time: 718 ms Throughput: 13.9 M msgs/sec Latency: 71.8 ns/msg
  Trial 3: Time: 722 ms Throughput: 13.8 M msgs/sec Latency: 72.2 ns/msg

Atomic instructions in baseline: 37
Atomic instructions after elision: 3

Done!