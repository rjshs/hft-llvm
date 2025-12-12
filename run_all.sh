#!/usr/bin/env bash
set -e

# =========================
# CONFIG
# =========================
SRC_FILE=$1
if [ -z "$SRC_FILE" ] || [ ! -f "$SRC_FILE" ]; then
  echo "Usage: $0 <source.cpp>"
  exit 1
fi

# Pass plugins
ATOMIC_LIB="build/hft_atomic/HFTAtomic.so"
BRANCH_LIB="build/hft_branch/HFTBranch.so"
SPLIT_LIB="build/hft_split/HFTSplit.so"

for LIB in "$ATOMIC_LIB" "$BRANCH_LIB" "$SPLIT_LIB"; do
  if [ ! -f "$LIB" ]; then
    echo "Missing pass library: $LIB"
    exit 1
  fi
done

ATOMIC_LIB=$(realpath "$ATOMIC_LIB")
BRANCH_LIB=$(realpath "$BRANCH_LIB")
SPLIT_LIB=$(realpath "$SPLIT_LIB")

FILE_BASENAME=$(basename "$SRC_FILE")
FILENAME=${FILE_BASENAME%.*}
EXT=${FILE_BASENAME##*.}
WORKDIR=$(dirname "$SRC_FILE")

if [ "$EXT" = "c" ]; then
  COMPILER=clang
else
  COMPILER=clang++
fi

cd "$WORKDIR"

# =========================
# CLEANUP
# =========================
rm -f *.bc *.ll *_baseline *_final *_stage* default.profraw 2>/dev/null || true

# =========================
# COMPILE ONCE
# =========================
echo "Compiling to LLVM IR (-O1, atomics preserved)..."
$COMPILER -O1 -emit-llvm -S "$FILE_BASENAME" -o ${FILENAME}.ll
llvm-as ${FILENAME}.ll -o ${FILENAME}.bc

# Canonicalize IR
opt -passes='loop-simplify' ${FILENAME}.bc -o ${FILENAME}.stage0.bc

# =========================
# BASELINE (ONCE)
# =========================
echo
echo "=========================================="
echo "BASELINE"
echo "=========================================="

cp ${FILENAME}.stage0.bc ${FILENAME}.baseline.bc
$COMPILER -O3 ${FILENAME}.baseline.bc -o ${FILENAME}_baseline

echo "Running baseline (3 trials)..."
for i in 1 2 3; do
  echo -n "  Trial $i: "
  ./${FILENAME}_baseline 2>&1 | grep -E "(Time|Throughput|Latency)" | tr '\n' ' '
  echo
done

# =========================
# PASS PIPELINE
# =========================
echo
echo "=========================================="
echo "OPTIMIZATION PIPELINE"
echo "=========================================="

STAGE=0
CUR_BC=${FILENAME}.stage0.bc

run_pass () {
  local LIB=$1
  local PASSES=$2
  local NAME=$3

  STAGE=$((STAGE+1))
  OUT=${FILENAME}.stage${STAGE}.${NAME}.bc

  echo
  echo "--- Applying $NAME ---"
  opt -load-pass-plugin="$LIB" \
      -passes="$PASSES" \
      "$CUR_BC" -o "$OUT" 2>&1 | grep -E "^\[" || true

  # Save readable IR
  opt -S "$OUT" -o ${FILENAME}.stage${STAGE}.${NAME}.ll

  CUR_BC=$OUT
}

# 1. Struct splitting
run_pass "$SPLIT_LIB"  "hft-split"              "split"

# 2. Atomic elision
run_pass "$ATOMIC_LIB" "hft-atomic-elision"     "atomic"

# 3. Branch + prefetch + combined opt
run_pass "$BRANCH_LIB" "hft-branchless"         "branchless"
run_pass "$BRANCH_LIB" "hft-prefetch"           "prefetch"
run_pass "$BRANCH_LIB" "hft-opt"                 "opt"

# =========================
# FINAL BINARY
# =========================
echo
echo "=========================================="
echo "FINAL BINARY"
echo "=========================================="

FINAL_BIN=${FILENAME}_final
$COMPILER -O3 "$CUR_BC" -o "$FINAL_BIN"

echo "Running final optimized binary (3 trials)..."
for i in 1 2 3; do
  echo -n "  Trial $i: "
  ./"$FINAL_BIN" 2>&1 | grep -E "(Time|Throughput|Latency)" | tr '\n' ' '
  echo
done

# =========================
# SUMMARY
# =========================
echo
echo "=========================================="
echo "IR SUMMARY"
echo "=========================================="

echo "Baseline atomics:"
grep -c "atomicrmw\|cmpxchg\|load atomic\|store atomic" ${FILENAME}.ll || echo 0

echo "Final atomics:"
grep -c "atomicrmw\|cmpxchg\|load atomic\|store atomic" ${FILENAME}.stage*.ll | tail -1 || echo 0

echo
echo "Artifacts:"
echo "  ${FILENAME}_baseline"
echo "  ${FILENAME}_final"
echo "  stage*.ll (pipeline inspection)"

echo
echo "Done."
