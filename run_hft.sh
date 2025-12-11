#!/usr/bin/env bash
set -e

LIB="build/hftpass/HFTPasses.so"
if [ ! -f "$LIB" ]; then
  echo "HFTPasses.so not found at $LIB; build first."
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
  "baseline"  # normal wo any passes applied
  "hft-print" # diagnostic print test pass
)

cd "$(dirname "$SRC_FILE")"

# Clean old stuff
rm -f default.profraw *_prof *_fplicm *.bc *.profdata *_output *.ll \ ${FILENAME}_* 2>/dev/null || true

# Convert source code to bitcode (IR). EDITED FOR CPP FILES
$COMPILER -emit-llvm -c "$FILE_BASENAME" -Xclang -disable-O0-optnone -o ${FILENAME}.bc

opt -passes='loop-simplify' ${FILENAME}.bc -o ${FILENAME}.ls.bc


echo
echo "HFT timing for $FILE_BASENAME"

for PIPELINE in "${PASSES[@]}"; do
  if [ "$PIPELINE" = "baseline" ]; then
    OUT_BC="${FILENAME}.baseline.bc"
    BIN="${FILENAME}_baseline"
    cp ${FILENAME}.ls.bc "$OUT_BC"
    echo
    echo "--- Pipeline: baseline (loop-simplify only) ---"
  else
    OUT_BC="${FILENAME}.${PIPELINE}.bc"
    BIN="${FILENAME}_${PIPELINE}"
    echo
    echo "--- Pipeline: $PIPELINE ---"
    opt -S -load-pass-plugin="$PATH2LIB" \
        -passes="$PIPELINE" \
        ${FILENAME}.ls.bc -o "$OUT_BC" >/dev/null
  fi

  # Build binary
  $COMPILER "$OUT_BC" -o "$BIN"

  # Time it
  echo "Running $BIN ..."
  time "./$BIN" >/dev/null
done

rm -f default.profraw *_prof *_fplicm *.bc *.profdata *.ll
cd $CURRENT_DIR
