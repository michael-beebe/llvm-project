#!/bin/bash

set -euo pipefail

# Resolve repo root (script is in tmp/)
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$ROOT_DIR/build"
TEST_FILE="$ROOT_DIR/mlir/test/Dialect/OpenSHMEM/async-conversion.mlir"
MLIR_OPT="$BUILD_DIR/bin/mlir-opt"
FILECHECK="$BUILD_DIR/bin/FileCheck"
OUTPUT_DIR="$ROOT_DIR/tmp/test_outputs"
OUT1="$OUTPUT_DIR/async-conversion.mlir"
OUT2="$OUTPUT_DIR/async-conversion-twice.mlir"

if command -v bat &> /dev/null; then
  CAT="bat --paging=never"
else
  CAT="cat"
fi

mkdir -p "$OUTPUT_DIR"

# Check for tools
if [[ ! -x "$MLIR_OPT" ]]; then
  echo "ERROR: mlir-opt not found at: $MLIR_OPT" >&2
  echo "Build MLIR first (from repo root): ./tmp/build.sh --mlir" >&2
  exit 1
fi
if [[ ! -x "$FILECHECK" ]]; then
  echo "ERROR: FileCheck not found at: $FILECHECK" >&2
  echo "Build MLIR first (from repo root): ./tmp/build.sh --mlir" >&2
  exit 1
fi

echo "Testing OpenSHMEM Async Conversion Pass"
echo "======================================="

echo -e "\n===== [ Async conversion + FileCheck ] ====="
if "$MLIR_OPT" "$TEST_FILE" \
    --openshmem-async-conversion \
    -o "$OUT1" && \
   "$MLIR_OPT" "$TEST_FILE" \
    --openshmem-async-conversion \
    | "$FILECHECK" "$TEST_FILE"; then
  echo "PASS: Async conversion (FileCheck validated)"
  echo -e "\nOriginal MLIR:"
  $CAT "$TEST_FILE"
  echo -e "\nAfter async conversion:"
  $CAT "$OUT1"
else
  echo "FAIL: Async conversion failed FileCheck validation" >&2
  exit 1
fi

echo -e "\n===== [ Idempotence Check ] ====="
echo "Running the pass twice and comparing output..."
if "$MLIR_OPT" "$OUT1" \
    --openshmem-async-conversion \
    -o "$OUT2" && \
   diff -q "$OUT1" "$OUT2" &> /dev/null; then
  echo "PASS: Running the pass twice is idempotent"
else
  echo "FAIL: Pass is not idempotent. Diff:" >&2
  diff "$OUT1" "$OUT2" || true
  exit 1
fi

echo -e "\nAsync conversion test completed successfully!"
echo "============================================"
echo "Output files saved in: $OUTPUT_DIR"
echo "- Converted once: $OUT1"
echo "- Converted twice: $OUT2"


