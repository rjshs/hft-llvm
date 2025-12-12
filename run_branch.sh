#!/usr/bin/env bash
set -e

LIB="build/hft_branch/HFTBranch.so"
if [ ! -f "$LIB" ]; then
  echo "HFTBranch.so not found at $LIB; build first."
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
  COMPILER=clang
else
  COMPILER=clang++
fi

PASSES=(
  "baseline"
  "hft-branchless"
  "hft-prefetch"
  "hft-opt"
)

cd "$(dirname "$SRC_FILE")"

rm -f default.profraw *_prof *_fplicm *.bc *.profdata *_output *.ll \
      ${FILENAME}_* 2>/dev/null || true

echo "Compiling to LLVM IR with -O1..."
$COMPILER -O1 -emit-llvm -S "$FILE_BASENAME" -o ${FILENAME}.ll

# Convert to bitcode
llvm-as ${FILENAME}.ll -o ${FILENAME}.bc

# Normalize loops (needed for prefetch pass)
opt -passes='loop-simplify' ${FILENAME}.bc -o ${FILENAME}.ls.bc

echo
echo "=========================================="
echo "HFT Optimization Benchmark: $FILE_BASENAME"
echo "=========================================="

# Show baseline IR stats
echo
echo "Baseline IR statistics:"
echo "  Conditional branches: $(grep -c 'br i1' ${FILENAME}.ll || echo 0)"
echo "  Select instructions:  $(grep -c 'select i1' ${FILENAME}.ll || echo 0)"
echo "  Prefetch calls:       $(grep -c 'llvm.prefetch' ${FILENAME}.ll || echo 0)"

for PIPELINE in "${PASSES[@]}"; do
  if [ "$PIPELINE" = "baseline" ]; then
    OUT_BC="${FILENAME}.baseline.bc"
    BIN="${FILENAME}_baseline"
    cp ${FILENAME}.ls.bc "$OUT_BC"
    echo
    echo "--- BASELINE (no optimization) ---"
  else
    OUT_BC="${FILENAME}.${PIPELINE}.bc"
    BIN="${FILENAME}_${PIPELINE}"
    echo
    echo "--- ${PIPELINE^^} ---"
    
    # Run our pass and capture output
    opt -load-pass-plugin="$PATH2LIB" \
        -passes="${PIPELINE}" \
        "${FILENAME}.ls.bc" -o "$OUT_BC" 2>&1 | grep -E "^\[" | head -20
    
    # Generate readable IR for this pass
    opt -load-pass-plugin="$PATH2LIB" \
        -passes="${PIPELINE}" \
        "${FILENAME}.ls.bc" -S -o "${FILENAME}.${PIPELINE}.ll" 2>/dev/null
    
    echo "  IR changes:"
    echo "    Branches: $(grep -c 'br i1' ${FILENAME}.${PIPELINE}.ll || echo 0)"
    echo "    Selects:  $(grep -c 'select i1' ${FILENAME}.${PIPELINE}.ll || echo 0)"
    echo "    Prefetch: $(grep -c 'llvm.prefetch' ${FILENAME}.${PIPELINE}.ll || echo 0)"
  fi

  $COMPILER -O3 "$OUT_BC" -o "$BIN"

  # Run benchmark 3 times and show all results
  echo "Running $BIN (3 trials)..."
  for i in 1 2 3; do
    echo -n "  Trial $i: "
    "./$BIN" 2>&1 | grep -E "(Time|Throughput|Latency)" | head -3 | tr '\n' ' '
    echo
  done
done

echo
echo "=========================================="
echo "IR Comparison Summary"
echo "=========================================="
printf "%-20s %10s %10s %10s\n" "Version" "Branches" "Selects" "Prefetch"
printf "%-20s %10s %10s %10s\n" "--------" "--------" "-------" "--------"
printf "%-20s %10s %10s %10s\n" "baseline" \
  "$(grep -c 'br i1' ${FILENAME}.ll || echo 0)" \
  "$(grep -c 'select i1' ${FILENAME}.ll || echo 0)" \
  "$(grep -c 'llvm.prefetch' ${FILENAME}.ll || echo 0)"

for PIPELINE in "${PASSES[@]:1}"; do
  if [ -f "${FILENAME}.${PIPELINE}.ll" ]; then
    printf "%-20s %10s %10s %10s\n" "$PIPELINE" \
      "$(grep -c 'br i1' ${FILENAME}.${PIPELINE}.ll || echo 0)" \
      "$(grep -c 'select i1' ${FILENAME}.${PIPELINE}.ll || echo 0)" \
      "$(grep -c 'llvm.prefetch' ${FILENAME}.${PIPELINE}.ll || echo 0)"
  fi
done

# Cleanup intermediate files
rm -f default.profraw *_prof *_fplicm *.bc *.profdata 2>/dev/null || true
cd "$CURRENT_DIR"

echo
echo "Done! Binaries and IR left in place for inspection:"
echo "  ${FILENAME}_baseline"
echo "  ${FILENAME}_hft-branchless"
echo "  ${FILENAME}_hft-prefetch"  
echo "  ${FILENAME}_hft-opt"
echo
echo "IR files:"
echo "  ${FILENAME}.ll (baseline)"
echo "  ${FILENAME}.hft-branchless.ll"
echo "  ${FILENAME}.hft-prefetch.ll"
echo "  ${FILENAME}.hft-opt.ll"