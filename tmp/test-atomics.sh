#!/bin/bash

set -e

BUILD_DIR="build"
ATOMICS_TEST_FILE="mlir/test/Dialect/OpenSHMEM/atomics.mlir"
MLIR_OPT="$BUILD_DIR/bin/mlir-opt"
FILECHECK="$BUILD_DIR/bin/FileCheck"
OUTPUT_DIR="tmp/test_outputs"
ATOMICS_OUT="$OUTPUT_DIR/atomics.mlir"
MLIR_TRANSLATE="$BUILD_DIR/bin/mlir-translate"
LLVM_IR_OUT="$OUTPUT_DIR/atomics.ll"

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

echo "Testing OpenSHMEM Atomic Operations"
echo "==================================="

echo -e "\n===== [ Testing Atomic Lowering ] ====="
if "$MLIR_OPT" "$ATOMICS_TEST_FILE" \
    --convert-openshmem-to-llvm \
    --convert-arith-to-llvm \
    --convert-func-to-llvm \
    --reconcile-unrealized-casts \
    -o "$ATOMICS_OUT" && \
   "$MLIR_OPT" "$ATOMICS_TEST_FILE" \
    --convert-openshmem-to-llvm \
    --convert-arith-to-llvm \
    --convert-func-to-llvm \
    --reconcile-unrealized-casts \
    | "$FILECHECK" "$ATOMICS_TEST_FILE"; then
    echo "PASS: Atomic lowering (FileCheck validated)"
    echo -e "\nOriginal MLIR:"
    $CAT "$ATOMICS_TEST_FILE"
    echo -e "\nAfter lowering to LLVM dialect:"
    $CAT "$ATOMICS_OUT"
else
    echo "FAIL: Atomic lowering failed FileCheck validation"
    exit 1
fi

# Lower from LLVM dialect to LLVM IR
if "$MLIR_TRANSLATE" --mlir-to-llvmir "$ATOMICS_OUT" -o "$LLVM_IR_OUT"; then
    echo -e "\nAfter lowering to LLVM IR:"
    $CAT "$LLVM_IR_OUT"
    echo -e "\nPASS: Lowered to LLVM IR successfully"
else
    echo "FAIL: Lowering to LLVM IR failed"
    exit 1
fi

echo -e "\nAtomic test completed successfully!"
echo "==================================="
echo "PASS: Atomic lowering tested with FileCheck validation"
echo "Output file saved in: $ATOMICS_OUT"
