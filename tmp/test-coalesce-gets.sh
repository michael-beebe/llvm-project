#!/bin/bash

set -e

BUILD_DIR="build"
COALESCE_GETS_TEST_FILE="mlir/test/Dialect/OpenSHMEM/coalesce-gets.mlir"
MLIR_OPT="$BUILD_DIR/bin/mlir-opt"
FILECHECK="$BUILD_DIR/bin/FileCheck"
OUTPUT_DIR="tmp/test_outputs"
COALESCE_GETS_OUT="$OUTPUT_DIR/openshmem-coalesce-gets.mlir"

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

echo "Testing OpenSHMEM CoalesceGets Pass"
echo "===================================="

# Test CoalesceGets pass
echo -e "\n===== [ Testing CoalesceGets Pass ] ====="
echo "Testing CoalesceGets optimization patterns..."
if "$MLIR_OPT" "$COALESCE_GETS_TEST_FILE" --openshmem-coalesce-gets -o "$COALESCE_GETS_OUT" && \
   "$MLIR_OPT" "$COALESCE_GETS_TEST_FILE" --openshmem-coalesce-gets | "$FILECHECK" "$COALESCE_GETS_TEST_FILE"; then
	echo "PASS: CoalesceGets pass (FileCheck validated)"
	echo -e "\nOriginal MLIR:"
	$CAT "$COALESCE_GETS_TEST_FILE"
	echo -e "\nAfter CoalesceGets optimization:"
	$CAT "$COALESCE_GETS_OUT"
else
	echo "FAIL: CoalesceGets pass failed FileCheck validation"
	exit 1
fi

# Test CoalesceGets with LLVM lowering
echo -e "\n===== [ Testing CoalesceGets with LLVM Lowering ] ====="
COALESCE_GETS_LLVM_OUT="$OUTPUT_DIR/openshmem-coalesce-gets-llvm.mlir"
if "$MLIR_OPT" "$COALESCE_GETS_TEST_FILE" \
	--openshmem-coalesce-gets \
	--convert-openshmem-to-llvm \
	--convert-arith-to-llvm \
	--finalize-memref-to-llvm \
	--convert-func-to-llvm \
	--reconcile-unrealized-casts \
	-o "$COALESCE_GETS_LLVM_OUT" 2>/dev/null; then
	echo "PASS: CoalesceGets + LLVM lowering"
	echo -e "\nAfter CoalesceGets + LLVM lowering:"
	$CAT "$COALESCE_GETS_LLVM_OUT"
else
	echo "FAIL: CoalesceGets + LLVM lowering failed"
	exit 1
fi

echo -e "\nCoalesceGets pass tests completed successfully!"
echo "=============================================="
echo "PASS: CoalesceGets pass tested with FileCheck validation"
echo "PASS: CoalesceGets + LLVM lowering tested"
echo ""
echo "Output files saved in: $OUTPUT_DIR"
