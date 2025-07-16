#!/bin/bash

set -e

BUILD_DIR="build"
MLIR_OPT="$BUILD_DIR/bin/mlir-opt"
OUTPUT_DIR="tmp/test_outputs"

if command -v bat &> /dev/null; then
  CAT="bat --paging=never"
else
  CAT="cat"
fi

mkdir -p "$OUTPUT_DIR"

# Check if mlir-opt exists
if [ ! -f "$MLIR_OPT" ]; then
	echo "ERROR: mlir-opt not found. Build MLIR first."
	exit 1
fi

echo "Testing InjectNumPEsPass"
echo "==========================="

# Test 1: Basic functionality
echo -e "\n===== [ Test 1: Basic InjectNumPEsPass ] ====="
TEST1_INPUT="mlir/test/Dialect/OpenSHMEM/inject-num-pes.mlir"
TEST1_OUTPUT="$OUTPUT_DIR/test1-output.mlir"

echo "Input file:"
$CAT "$TEST1_INPUT"
echo ""

if "$MLIR_OPT" "$TEST1_INPUT" --openshmem-inject-num-pes="num-pes=4" -o "$TEST1_OUTPUT"; then
	echo "PASS: Basic test passed"
	echo "Output file:"
	$CAT "$TEST1_OUTPUT"
	echo ""
	if grep -q "openshmem.num_pes = 4" "$TEST1_OUTPUT"; then
		echo "PASS: Module attribute correctly injected"
	else
		echo "FAIL: Module attribute not found"
		exit 1
	fi
else
	echo "FAIL: Basic test failed"
	exit 1
fi

# Test 2: No option provided
echo -e "\n===== [ Test 2: No num-pes option ] ====="
TEST2_OUTPUT="$OUTPUT_DIR/test2-output.mlir"

echo "Input file:"
$CAT "$TEST1_INPUT"
echo ""

if "$MLIR_OPT" "$TEST1_INPUT" --openshmem-inject-num-pes -o "$TEST2_OUTPUT"; then
	echo "PASS: No-option test passed"
	echo "Output file:"
	$CAT "$TEST2_OUTPUT"
	echo ""
	if grep -q "openshmem.num_pes" "$TEST2_OUTPUT"; then
		echo "FAIL: Module attribute should not be added"
		exit 1
	else
		echo "PASS: No attribute added (correct behavior)"
	fi
else
	echo "FAIL: No-option test failed"
	exit 1
fi

# Test 3: Optimization example
echo -e "\n===== [ Test 3: Optimization Example ] ====="
TEST3_INPUT="mlir/test/Dialect/OpenSHMEM/inject-num-pes-optimization-example.mlir"
TEST3_OUTPUT="$OUTPUT_DIR/test3-output.mlir"

echo "Input file:"
$CAT "$TEST3_INPUT"
echo ""

if "$MLIR_OPT" "$TEST3_INPUT" --openshmem-inject-num-pes="num-pes=8" -o "$TEST3_OUTPUT"; then
	echo "PASS: Optimization example test passed"
	echo "Output file:"
	$CAT "$TEST3_OUTPUT"
	echo ""
	if grep -q "openshmem.num_pes = 8" "$TEST3_OUTPUT"; then
		echo "PASS: Module attribute correctly injected in complex example"
	else
		echo "FAIL: Module attribute not found in complex example"
		exit 1
	fi
else
	echo "FAIL: Optimization example test failed"
	exit 1
fi

echo -e "\nAll InjectNumPEsPass tests passed!"
echo "Output files saved in: $OUTPUT_DIR" 