#!/bin/bash

set -e

BUILD_DIR="build"
COALESCE_PUTS_TEST_FILE="mlir/test/Dialect/OpenSHMEM/coalesce-puts.mlir"
STENCIL_TEST_FILE="mlir/test/Dialect/OpenSHMEM/stencil-01.mlir"
MLIR_OPT="$BUILD_DIR/bin/mlir-opt"
FILECHECK="$BUILD_DIR/bin/FileCheck"
OUTPUT_DIR="tmp/test_outputs"
COALESCE_PUTS_OUT="$OUTPUT_DIR/openshmem-coalesce-puts.mlir"

mkdir -p "$OUTPUT_DIR"

if command -v bat &> /dev/null; then
  CAT="bat --paging=never"
else
  CAT="cat"
fi


# Check if tools exist
if [ ! -f "$MLIR_OPT" ]; then
	echo "ERROR: mlir-opt not found. Build MLIR first: ./tmp/build.sh --mlir"
	exit 1
fi
if [ ! -f "$FILECHECK" ]; then
	echo "ERROR: FileCheck not found. Build MLIR first: ./tmp/build.sh --mlir"
	exit 1
fi

echo "Testing OpenSHMEM CoalescePuts Pass"
echo "===================================="

# Test CoalescePuts pass
echo -e "\n===== [ Testing CoalescePuts Pass ] ====="
echo "Testing CoalescePuts optimization patterns..."
if "$MLIR_OPT" "$COALESCE_PUTS_TEST_FILE" --openshmem-coalesce-puts -o "$COALESCE_PUTS_OUT" && \
   "$MLIR_OPT" "$COALESCE_PUTS_TEST_FILE" --openshmem-coalesce-puts | "$FILECHECK" "$COALESCE_PUTS_TEST_FILE"; then
	echo "PASS: CoalescePuts pass (FileCheck validated)"
	echo -e "\nOriginal MLIR:"
	$CAT "$COALESCE_PUTS_TEST_FILE"
	echo -e "\nAfter CoalescePuts optimization:"
	$CAT "$COALESCE_PUTS_OUT"
else
	echo "FAIL: CoalescePuts pass failed FileCheck validation"
	exit 1
fi

# Test Stencil Coalescing Patterns (if stencil test file exists)
if [ -f "$STENCIL_TEST_FILE" ]; then
	echo -e "\n===== [ Testing Stencil Coalescing Patterns ] ====="
	echo "Testing advanced stencil optimization patterns..."
	STENCIL_OUT="$OUTPUT_DIR/stencil-optimized.mlir"
	if "$MLIR_OPT" "$STENCIL_TEST_FILE" --openshmem-coalesce-puts -split-input-file -o "$STENCIL_OUT" && \
	   "$MLIR_OPT" "$STENCIL_TEST_FILE" --openshmem-coalesce-puts -split-input-file | "$FILECHECK" "$STENCIL_TEST_FILE"; then
		echo "PASS: Stencil coalescing patterns (FileCheck validated)"
		echo -e "\nOriginal stencil patterns:"
		$CAT "$STENCIL_TEST_FILE"
		echo -e "\nAfter stencil coalescing optimization:"
		$CAT "$STENCIL_OUT"
	else
		echo "FAIL: Stencil coalescing patterns failed FileCheck validation"
		exit 1
	fi
else
	echo -e "\nINFO: Stencil test file not found, skipping stencil tests"
fi

# Test CoalescePuts with LLVM lowering
echo -e "\n===== [ Testing CoalescePuts with LLVM Lowering ] ====="
COALESCE_PUTS_LLVM_OUT="$OUTPUT_DIR/openshmem-coalesce-puts-llvm.mlir"
if "$MLIR_OPT" "$COALESCE_PUTS_TEST_FILE" \
	--openshmem-coalesce-puts \
	--convert-openshmem-to-llvm \
	--convert-arith-to-llvm \
	--finalize-memref-to-llvm \
	--convert-func-to-llvm \
	--reconcile-unrealized-casts \
	-o "$COALESCE_PUTS_LLVM_OUT" 2>/dev/null; then
	echo "PASS: CoalescePuts + LLVM lowering"
	echo -e "\nAfter CoalescePuts + LLVM lowering:"
	$CAT "$COALESCE_PUTS_LLVM_OUT"
else
	echo "FAIL: CoalescePuts + LLVM lowering failed"
	exit 1
fi

echo -e "\nCoalescePuts pass tests completed successfully!"
echo "=============================================="
echo "PASS: CoalescePuts pass tested with FileCheck validation"
if [ -f "$STENCIL_TEST_FILE" ]; then
	echo "PASS: Stencil coalescing patterns tested with FileCheck validation"
fi
echo "PASS: CoalescePuts + LLVM lowering tested"
echo ""
echo "Output files saved in: $OUTPUT_DIR"
