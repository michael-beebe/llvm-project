#!/bin/bash

set -e

BUILD_DIR="build"
CONTEXTS_TEST_FILE="mlir/test/Dialect/OpenSHMEM/contexts.mlir"
MLIR_OPT="$BUILD_DIR/bin/mlir-opt"
FILECHECK="$BUILD_DIR/bin/FileCheck"
OUTPUT_DIR="tmp/test_outputs"
CONTEXTS_OUT="$OUTPUT_DIR/contexts.mlir"
MLIR_TRANSLATE="$BUILD_DIR/bin/mlir-translate"
LLVM_IR_OUT="$OUTPUT_DIR/contexts.ll"

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

echo "Testing OpenSHMEM Context Management"
echo "====================================="

echo -e "\n===== [ Testing Contexts Lowering ] ====="
if "$MLIR_OPT" "$CONTEXTS_TEST_FILE" \
    --convert-openshmem-to-llvm \
    --convert-func-to-llvm \
    --convert-arith-to-llvm \
    --reconcile-unrealized-casts \
    -o "$CONTEXTS_OUT" && \
   "$MLIR_OPT" "$CONTEXTS_TEST_FILE" \
    --convert-openshmem-to-llvm \
    --convert-func-to-llvm \
    --convert-arith-to-llvm \
    --reconcile-unrealized-casts \
    | "$FILECHECK" "$CONTEXTS_TEST_FILE"; then
    echo "PASS: Contexts lowering (FileCheck validated)"
    echo -e "\nOriginal MLIR:"
    $CAT "$CONTEXTS_TEST_FILE"
    echo -e "\nAfter lowering to LLVM dialect:"
    $CAT "$CONTEXTS_OUT"
else
    echo "FAIL: Contexts lowering failed FileCheck validation"
    exit 1
fi

# Lower from LLVM dialect to LLVM IR
if "$MLIR_TRANSLATE" --mlir-to-llvmir "$CONTEXTS_OUT" -o "$LLVM_IR_OUT"; then
    echo -e "\nAfter lowering to LLVM IR:"
    $CAT "$LLVM_IR_OUT"
    echo -e "\nPASS: Lowered to LLVM IR successfully"
else
    echo "FAIL: Lowering to LLVM IR failed"
    exit 1
fi

echo -e "\nContexts test completed successfully!"
echo "====================================="
echo "PASS: Contexts lowering tested with FileCheck validation"
echo "Output file saved in: $CONTEXTS_OUT"
