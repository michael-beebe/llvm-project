#!/bin/bash

set -e

BUILD_DIR="build"
PT2PT_SYNC_TEST_FILE="mlir/test/Dialect/OpenSHMEM/pt2pt-sync.mlir"
MLIR_OPT="$BUILD_DIR/bin/mlir-opt"
FILECHECK="$BUILD_DIR/bin/FileCheck"
OUTPUT_DIR="tmp/test_outputs"
PT2PT_SYNC_OUT="$OUTPUT_DIR/pt2pt-sync.mlir"
MLIR_TRANSLATE="$BUILD_DIR/bin/mlir-translate"
LLVM_IR_OUT="$OUTPUT_DIR/pt2pt-sync.ll"

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

echo "Testing OpenSHMEM Point-to-Point Synchronization Operations"
echo "=========================================================="

echo -e "\n===== [ Testing Pt2pt Sync Lowering ] ====="
if "$MLIR_OPT" "$PT2PT_SYNC_TEST_FILE" \
    --convert-openshmem-to-llvm \
    --convert-arith-to-llvm \
    --finalize-memref-to-llvm \
    --convert-func-to-llvm \
    --reconcile-unrealized-casts \
    -o "$PT2PT_SYNC_OUT" && \
   "$MLIR_OPT" "$PT2PT_SYNC_TEST_FILE" \
    --convert-openshmem-to-llvm \
    --convert-arith-to-llvm \
    --finalize-memref-to-llvm \
    --convert-func-to-llvm \
    --reconcile-unrealized-casts \
    | "$FILECHECK" "$PT2PT_SYNC_TEST_FILE"; then
    echo "PASS: Pt2pt Sync lowering (FileCheck validated)"
    echo -e "\nOriginal MLIR:"
    $CAT "$PT2PT_SYNC_TEST_FILE"
    echo -e "\nAfter lowering to LLVM dialect:"
    $CAT "$PT2PT_SYNC_OUT"
else
    echo "FAIL: Pt2pt Sync lowering failed FileCheck validation"
    exit 1
fi

# Lower from LLVM dialect to LLVM IR
if "$MLIR_TRANSLATE" --mlir-to-llvmir "$PT2PT_SYNC_OUT" -o "$LLVM_IR_OUT"; then
    echo -e "\nAfter lowering to LLVM IR:"
    $CAT "$LLVM_IR_OUT"
    echo -e "\nPASS: Lowered to LLVM IR successfully"
else
    echo "FAIL: Lowering to LLVM IR failed"
    exit 1
fi

echo -e "\nPoint-to-Point Synchronization test completed successfully!"
echo "=========================================================="
echo "PASS: Pt2pt Sync lowering tested with FileCheck validation"
echo "Output file saved in: $PT2PT_SYNC_OUT"
