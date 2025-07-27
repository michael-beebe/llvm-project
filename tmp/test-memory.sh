#!/bin/bash

set -e

BUILD_DIR="build"
MEMORY_TEST_FILE="mlir/test/Dialect/OpenSHMEM/memory.mlir"
MLIR_OPT="$BUILD_DIR/bin/mlir-opt"
FILECHECK="$BUILD_DIR/bin/FileCheck"
OUTPUT_DIR="tmp/test_outputs"
MEMORY_OUT="$OUTPUT_DIR/memory.mlir"
MLIR_TRANSLATE="$BUILD_DIR/bin/mlir-translate"
LLVM_IR_OUT="$OUTPUT_DIR/memory.ll"

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

echo "Testing OpenSHMEM Memory Management Operations"
echo "=============================================="

echo -e "\n===== [ Testing Memory Operation Lowering ] ====="
if "$MLIR_OPT" "$MEMORY_TEST_FILE" \
    --convert-openshmem-to-llvm \
    --convert-arith-to-llvm \
    --finalize-memref-to-llvm \
    --convert-func-to-llvm \
    --reconcile-unrealized-casts \
    -o "$MEMORY_OUT" && \
   "$MLIR_OPT" "$MEMORY_TEST_FILE" \
    --convert-openshmem-to-llvm \
    --convert-arith-to-llvm \
    --finalize-memref-to-llvm \
    --convert-func-to-llvm \
    --reconcile-unrealized-casts \
    | "$FILECHECK" "$MEMORY_TEST_FILE"; then
    echo "PASS: Memory operation lowering (FileCheck validated)"
    echo -e "\nOriginal MLIR:"
    $CAT "$MEMORY_TEST_FILE"
    echo -e "\nAfter lowering to LLVM dialect:"
    $CAT "$MEMORY_OUT"
else
    echo "FAIL: Memory operation lowering failed FileCheck validation"
    exit 1
fi

# Lower from LLVM dialect to LLVM IR
if "$MLIR_TRANSLATE" --mlir-to-llvmir "$MEMORY_OUT" -o "$LLVM_IR_OUT"; then
    echo -e "\nAfter lowering to LLVM IR:"
    $CAT "$LLVM_IR_OUT"
    echo -e "\nPASS: Lowered to LLVM IR successfully"
else
    echo "FAIL: Lowering to LLVM IR failed"
    exit 1
fi

echo -e "\nMemory management test completed successfully!"
echo "=============================================="
echo "PASS: Memory operation lowering tested with FileCheck validation"
echo "Output file saved in: $MEMORY_OUT"
echo ""
echo "Summary of tested operations:"
echo "  openshmem.malloc  - Allocate symmetric memory"
echo "  openshmem.free    - Free symmetric memory"
echo "  openshmem.realloc - Resize symmetric memory allocation"
echo "  openshmem.align   - Allocate aligned symmetric memory"
echo "  openshmem.calloc  - Allocate zero-initialized symmetric memory"
echo ""
echo "All memory operations successfully lowered to:"
echo "  shmem_malloc()  calls"
echo "  shmem_free()    calls"
echo "  shmem_realloc() calls"
echo "  shmem_align()   calls"
echo "  shmem_calloc()  calls"
