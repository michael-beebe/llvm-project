#!/bin/bash

set -e

BUILD_DIR="build"
RMA_TEST_FILE="mlir/test/Dialect/OpenSHMEM/rma.mlir"
MLIR_OPT="$BUILD_DIR/bin/mlir-opt"
FILECHECK="$BUILD_DIR/bin/FileCheck"
OUTPUT_DIR="tmp/test_outputs"
RMA_OUT="$OUTPUT_DIR/rma.mlir"
MLIR_TRANSLATE="$BUILD_DIR/bin/mlir-translate"
LLVM_IR_OUT="$OUTPUT_DIR/rma.ll"

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
if [ ! -f "$MLIR_TRANSLATE" ]; then
    echo "ERROR: mlir-translate not found. Build MLIR first: ./tmp/build.sh --mlir"
    exit 1
fi

echo "Testing OpenSHMEM RMA Operations"
echo "==================================="

echo -e "\n===== [ Testing RMA Lowering ] ====="
if "$MLIR_OPT" "$RMA_TEST_FILE" \
    --convert-openshmem-to-llvm \
    --convert-arith-to-llvm \
    --finalize-memref-to-llvm \
    --convert-func-to-llvm \
    --reconcile-unrealized-casts \
    -o "$RMA_OUT" && \
   "$MLIR_OPT" "$RMA_TEST_FILE" \
    --convert-openshmem-to-llvm \
    --convert-arith-to-llvm \
    --finalize-memref-to-llvm \
    --convert-func-to-llvm \
    --reconcile-unrealized-casts \
    | "$FILECHECK" "$RMA_TEST_FILE"; then
    echo "PASS: RMA lowering (FileCheck validated)"
    echo -e "\nOriginal MLIR:"
    $CAT "$RMA_TEST_FILE"
    echo -e "\nAfter lowering to LLVM dialect:"
    $CAT "$RMA_OUT"
else
    echo "FAIL: RMA lowering failed FileCheck validation"
    exit 1
fi

# Lower from LLVM dialect to LLVM IR
if "$MLIR_TRANSLATE" --mlir-to-llvmir "$RMA_OUT" -o "$LLVM_IR_OUT"; then
    echo -e "\nAfter lowering to LLVM IR:"
    $CAT "$LLVM_IR_OUT"
    echo -e "\nPASS: Lowered to LLVM IR successfully"
else
    echo "FAIL: Lowering to LLVM IR failed"
    exit 1
fi

echo -e "\nRMA test completed successfully!"
echo "==================================="
echo "PASS: RMA lowering tested with FileCheck validation"
echo "Output file saved in: $RMA_OUT"
