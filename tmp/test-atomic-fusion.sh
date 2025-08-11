#!/bin/bash

set -e

BUILD_DIR="build"
AF_TEST_FILE="mlir/test/Dialect/OpenSHMEM/atomic-fusion.mlir"
MLIR_OPT="$BUILD_DIR/bin/mlir-opt"
FILECHECK="$BUILD_DIR/bin/FileCheck"
OUTPUT_DIR="tmp/test_outputs"
AF_OUT="$OUTPUT_DIR/atomic-fusion.mlir"

if command -v bat &> /dev/null; then
  CAT="bat --paging=never"
else
  CAT="cat"
fi

mkdir -p "$OUTPUT_DIR"

# Check if tools exist
if [ ! -f "$MLIR_OPT" ]; then
    echo "ERROR: mlir-opt not found. Build MLIR first: ./tmp/build.sh --mlir"
    exit 1
fi
if [ ! -f "$FILECHECK" ]; then
    echo "ERROR: FileCheck not found. Build MLIR first: ./tmp/build.sh --mlir"
    exit 1
fi

echo "Testing OpenSHMEM Atomic Fusion Pass"
echo "===================================="

echo -e "\n===== [ Testing Atomic Fusion Pass ] ====="
if "$MLIR_OPT" "$AF_TEST_FILE" \
    --openshmem-atomic-fusion \
    -o "$AF_OUT" && \
   "$MLIR_OPT" "$AF_TEST_FILE" \
    --openshmem-atomic-fusion \
    | "$FILECHECK" "$AF_TEST_FILE"; then
    echo "PASS: Atomic fusion (FileCheck validated)"
    echo -e "\nOriginal MLIR:"
    $CAT "$AF_TEST_FILE"
    echo -e "\nAfter atomic fusion:"
    $CAT "$AF_OUT"
else
    echo "FAIL: Atomic fusion failed FileCheck validation"
    exit 1
fi

echo -e "\n===== [ Idempotence Check ] ====="
AF_OUT2="$OUTPUT_DIR/atomic-fusion-2.mlir"
"$MLIR_OPT" "$AF_OUT" --openshmem-atomic-fusion -o "$AF_OUT2"
if diff -u "$AF_OUT" "$AF_OUT2" >/dev/null; then
  echo "PASS: Running the pass twice is idempotent"
else
  echo "WARN: Running the pass twice changed output (non-idempotent)"
fi

echo -e "\nAtomic fusion test completed. Outputs in: $OUTPUT_DIR"


