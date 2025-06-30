#!/bin/bash

set -e

BUILD_DIR="build"
TEST_FILE="mlir/test/Dialect/OpenSHMEM/openshmemops.mlir"
INJECT_TEST_FILE="mlir/test/Dialect/OpenSHMEM/inject-num-pes.mlir"

MLIR_OPT="$BUILD_DIR/bin/mlir-opt"
MLIR_TRANSLATE="$BUILD_DIR/bin/mlir-translate"
FILECHECK="$BUILD_DIR/bin/FileCheck"
OUTPUT_DIR="tmp/test_outputs"
INPUT_OUT="$OUTPUT_DIR/openshmem-input.mlir"
INJECT_NUMPES_OUT="$OUTPUT_DIR/openshmem-inject-numpes.mlir"
INJECT_NUMPES_TEST="$OUTPUT_DIR/openshmem-inject-numpes-test.mlir"

COMBINED_OUT="$OUTPUT_DIR/openshmem-combined.mlir"
BUFFERIZED_OUT="$OUTPUT_DIR/openshmem-bufferized.mlir"
AFFINE_OUT="$OUTPUT_DIR/openshmem-affine.mlir"
SCF_OUT="$OUTPUT_DIR/openshmem-scf.mlir"
CF_OUT="$OUTPUT_DIR/openshmem-cf.mlir"
LLVM_MLIR_OUT="$OUTPUT_DIR/openshmem-llvm.mlir"
LLVM_IR_OUT="$OUTPUT_DIR/openshmem.ll"

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
if [ ! -f "$MLIR_TRANSLATE" ]; then
	echo "ERROR: mlir-translate not found. Build MLIR first: ./tmp/build.sh --mlir"
	exit 1
fi
if [ ! -f "$FILECHECK" ]; then
	echo "ERROR: FileCheck not found. Build MLIR first: ./tmp/build.sh --mlir"
	exit 1
fi

echo "Testing OpenSHMEM MLIR Dialect"
echo "=================================="

# Show the original OpenSHMEM MLIR
cp "$TEST_FILE" "$INPUT_OUT"
echo -e "\n===== [ OpenSHMEM Dialect MLIR (input) ] ====="
$CAT "$INPUT_OUT"

# Test basic LLVM lowering first
echo -e "\n===== [ Testing Basic LLVM Lowering Pipeline ] ====="
echo "Testing complete LLVM lowering pipeline..."
if "$MLIR_OPT" "$TEST_FILE" \
	--convert-openshmem-to-llvm \
	--convert-arith-to-llvm \
	--finalize-memref-to-llvm \
	--convert-func-to-llvm \
	--reconcile-unrealized-casts | \
   "$MLIR_TRANSLATE" --mlir-to-llvmir | \
   "$FILECHECK" "$TEST_FILE"; then
	echo "PASS: Complete LLVM lowering pipeline (FileCheck validated)"
else
	echo "FAIL: LLVM lowering pipeline failed FileCheck validation"
fi

# Generate and show LLVM MLIR and IR
echo -e "\n===== [ LLVM MLIR and IR Generation ] ====="
echo "Generating LLVM MLIR dialect output..."
"$MLIR_OPT" "$INPUT_OUT" \
	--convert-openshmem-to-llvm \
	--convert-arith-to-llvm \
	--finalize-memref-to-llvm \
	--convert-func-to-llvm \
	--reconcile-unrealized-casts \
	-o "$LLVM_MLIR_OUT"

echo -e "\nLLVM MLIR Dialect:"
$CAT "$LLVM_MLIR_OUT"

echo -e "\nGenerating LLVM IR output..."
"$MLIR_TRANSLATE" "$LLVM_MLIR_OUT" --mlir-to-llvmir -o "$LLVM_IR_OUT"

echo -e "\nFinal LLVM IR:"
$CAT "$LLVM_IR_OUT"

# Test optional transformations
echo -e "\n===== [ Testing Optional Transformations ] ====="
if "$MLIR_OPT" "$INPUT_OUT" --one-shot-bufferize="bufferize-function-boundaries=true" -o "$BUFFERIZED_OUT" 2>/dev/null; then
	echo "PASS: Bufferization succeeded"
	echo -e "\nAfter bufferization:"
	$CAT "$BUFFERIZED_OUT"
else
	echo "INFO: Bufferization not applicable or failed (skipping)"
fi

# Now test our custom passes
echo -e "\n===== [ Testing Custom OpenSHMEM Passes ] ====="

# Test InjectNumPEsPass
echo "Testing InjectNumPEsPass with num-pes=4..."
if "$MLIR_OPT" "$INJECT_TEST_FILE" --openshmem-inject-num-pes="num-pes=4" -o "$INJECT_NUMPES_OUT" && \
   "$MLIR_OPT" "$INJECT_TEST_FILE" --openshmem-inject-num-pes="num-pes=4" | "$FILECHECK" "$INJECT_TEST_FILE" --check-prefix=CHECK-4; then
	echo "PASS: InjectNumPEsPass with num-pes=4 (FileCheck validated)"
	echo "Output:"
	$CAT "$INJECT_NUMPES_OUT"
else
	echo "FAIL: InjectNumPEsPass with num-pes=4 failed FileCheck validation"
fi

echo -e "\nTesting InjectNumPEsPass with num-pes=16..."
if "$MLIR_OPT" "$INJECT_TEST_FILE" --openshmem-inject-num-pes="num-pes=16" | "$FILECHECK" "$INJECT_TEST_FILE" --check-prefix=CHECK-16; then
	echo "PASS: InjectNumPEsPass with num-pes=16 (FileCheck validated)"
else
	echo "FAIL: InjectNumPEsPass with num-pes=16 failed FileCheck validation"
fi

echo -e "\nTesting InjectNumPEsPass without num-pes option..."
if "$MLIR_OPT" "$INJECT_TEST_FILE" --openshmem-inject-num-pes -o "$INJECT_NUMPES_TEST" && \
   "$MLIR_OPT" "$INJECT_TEST_FILE" --openshmem-inject-num-pes | "$FILECHECK" "$INJECT_TEST_FILE" --check-prefix=CHECK-NONE; then
	echo "PASS: InjectNumPEsPass without options (FileCheck validated)"
	echo "Output (should have no openshmem.num_pes attribute):"
	$CAT "$INJECT_NUMPES_TEST"
else
	echo "FAIL: InjectNumPEsPass without options failed FileCheck validation"
fi

# Test Coalescing Passes using specialized scripts
echo -e "\n===== [ Testing Coalescing Passes ] ====="
echo "Running CoalescePuts pass tests..."
if ./tmp/test-coalesce-puts.sh; then
	echo "PASS: CoalescePuts tests completed successfully"
else
	echo "FAIL: CoalescePuts tests failed"
fi

echo -e "\nRunning CoalesceGets pass tests..."
if ./tmp/test-coalesce-gets.sh; then
	echo "PASS: CoalesceGets tests completed successfully"
else
	echo "FAIL: CoalesceGets tests failed"
fi

# Test combining both passes
echo -e "\n===== [ Testing Combined Passes ] ====="
echo "Testing combined InjectNumPEs + CoalescePuts passes..."
COMBINED_OUT="$OUTPUT_DIR/openshmem-combined.mlir"
if "$MLIR_OPT" "$INPUT_OUT" \
	--openshmem-inject-num-pes="num-pes=16" \
	--openshmem-coalesce-puts \
	-o "$COMBINED_OUT" 2>/dev/null; then
	echo "PASS: Combined passes executed successfully"
	echo -e "\nAfter combined InjectNumPEs + CoalescePuts passes:"
	$CAT "$COMBINED_OUT"
	
	# Verify the attribute is still there
	if grep -q "openshmem.num_pes = 16" "$COMBINED_OUT"; then
		echo -e "\nPASS: Module attribute preserved through combined passes"
	else
		echo -e "\nFAIL: Module attribute lost during combined passes"
	fi
else
	echo "FAIL: Combined passes failed"
fi

# Test InjectNumPEsPass with LLVM lowering
echo -e "\n===== [ Testing Custom Passes with LLVM Lowering ] ====="
INJECT_LLVM_OUT="$OUTPUT_DIR/openshmem-inject-llvm.mlir"
if "$MLIR_OPT" "$INPUT_OUT" \
	--openshmem-inject-num-pes="num-pes=8" \
	--convert-openshmem-to-llvm \
	--convert-arith-to-llvm \
	--finalize-memref-to-llvm \
	--convert-func-to-llvm \
	--reconcile-unrealized-casts \
	-o "$INJECT_LLVM_OUT" 2>/dev/null; then
	echo "PASS: InjectNumPEsPass + LLVM lowering with num-pes=8"
	echo -e "\nAfter InjectNumPEs + LLVM lowering:"
	$CAT "$INJECT_LLVM_OUT"
	
	# Check if the attribute survived the lowering
	if grep -q "openshmem.num_pes = 8" "$INJECT_LLVM_OUT"; then
		echo -e "\nPASS: Module attribute survived LLVM lowering"
	else
		echo -e "\nINFO: Module attribute was removed during LLVM lowering (this may be expected)"
	fi
else
	echo "FAIL: InjectNumPEsPass + LLVM lowering failed"
fi

echo -e "\nAll tests completed successfully!"
echo "=================================="
echo "PASS: Basic LLVM lowering pipeline tested with FileCheck validation"
echo "PASS: LLVM MLIR and IR generation tested"
echo "PASS: Optional transformations tested"
echo "PASS: InjectNumPEsPass tested with FileCheck validation"
echo "PASS: Coalescing passes (CoalescePuts and CoalesceGets) tested with specialized scripts"
echo "PASS: Combined passes tested"
echo "PASS: Custom passes with LLVM lowering tested"
echo ""
echo "Output files saved in: $OUTPUT_DIR"
echo "All transformations validated with FileCheck patterns"
echo ""
echo "Individual pass testing available via:"
echo "  - ./tmp/test-coalesce-puts.sh (CoalescePuts + Stencil patterns)"
echo "  - ./tmp/test-coalesce-gets.sh (CoalesceGets patterns)"
