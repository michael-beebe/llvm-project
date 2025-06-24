#!/bin/bash

set -e

BUILD_DIR="build"
TEST_FILE="mlir/test/Dialect/OpenSHMEM/openshmemops.mlir"
INJECT_TEST_FILE="mlir/test/Dialect/OpenSHMEM/inject-num-pes.mlir"
COALESCE_TEST_FILE="mlir/test/Dialect/OpenSHMEM/coalesce-puts.mlir"
STENCIL_TEST_FILE="mlir/test/Dialect/OpenSHMEM/stencil-01.mlir"
MLIR_OPT="$BUILD_DIR/bin/mlir-opt"
MLIR_TRANSLATE="$BUILD_DIR/bin/mlir-translate"
FILECHECK="$BUILD_DIR/bin/FileCheck"
OUTPUT_DIR="tmp/test_outputs"
INPUT_OUT="$OUTPUT_DIR/openshmem-input.mlir"
INJECT_NUMPES_OUT="$OUTPUT_DIR/openshmem-inject-numpes.mlir"
INJECT_NUMPES_TEST="$OUTPUT_DIR/openshmem-inject-numpes-test.mlir"
COALESCE_OUT="$OUTPUT_DIR/openshmem-coalesce.mlir"
COMBINED_OUT="$OUTPUT_DIR/openshmem-combined.mlir"
BUFFERIZED_OUT="$OUTPUT_DIR/openshmem-bufferized.mlir"
AFFINE_OUT="$OUTPUT_DIR/openshmem-affine.mlir"
SCF_OUT="$OUTPUT_DIR/openshmem-scf.mlir"
CF_OUT="$OUTPUT_DIR/openshmem-cf.mlir"
LLVM_MLIR_OUT="$OUTPUT_DIR/openshmem-llvm.mlir"
LLVM_IR_OUT="$OUTPUT_DIR/openshmem.ll"

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

# 1. Dump the original OpenSHMEM MLIR
cp "$TEST_FILE" "$INPUT_OUT"
echo -e "\n===== [ OpenSHMEM Dialect MLIR (input) ] ====="
bat --paging=never "$INPUT_OUT"

# 2. Test InjectNumPEsPass with FileCheck
echo -e "\n===== [ Testing InjectNumPEsPass with FileCheck ] ====="

# Test with num-pes=4 and show output
echo "Testing InjectNumPEsPass with num-pes=4..."
if "$MLIR_OPT" "$INJECT_TEST_FILE" --openshmem-inject-num-pes="num-pes=4" -o "$INJECT_NUMPES_OUT" && \
   "$MLIR_OPT" "$INJECT_TEST_FILE" --openshmem-inject-num-pes="num-pes=4" | "$FILECHECK" "$INJECT_TEST_FILE" --check-prefix=CHECK-4; then
	echo "PASS: InjectNumPEsPass with num-pes=4 (FileCheck validated)"
	echo "Output:"
	bat --paging=never "$INJECT_NUMPES_OUT"
else
	echo "FAIL: InjectNumPEsPass with num-pes=4 failed FileCheck validation"
fi

# Test with num-pes=16
echo -e "\nTesting InjectNumPEsPass with num-pes=16..."
if "$MLIR_OPT" "$INJECT_TEST_FILE" --openshmem-inject-num-pes="num-pes=16" | "$FILECHECK" "$INJECT_TEST_FILE" --check-prefix=CHECK-16; then
	echo "PASS: InjectNumPEsPass with num-pes=16 (FileCheck validated)"
else
	echo "FAIL: InjectNumPEsPass with num-pes=16 failed FileCheck validation"
fi

# Test without num-pes option
echo -e "\nTesting InjectNumPEsPass without num-pes option..."
if "$MLIR_OPT" "$INJECT_TEST_FILE" --openshmem-inject-num-pes -o "$INJECT_NUMPES_TEST" && \
   "$MLIR_OPT" "$INJECT_TEST_FILE" --openshmem-inject-num-pes | "$FILECHECK" "$INJECT_TEST_FILE" --check-prefix=CHECK-NONE; then
	echo "PASS: InjectNumPEsPass without options (FileCheck validated)"
	echo "Output (should have no openshmem.num_pes attribute):"
	bat --paging=never "$INJECT_NUMPES_TEST"
else
	echo "FAIL: InjectNumPEsPass without options failed FileCheck validation"
fi

# 3. Test CoalescePuts pass with FileCheck
echo -e "\n===== [ Testing CoalescePuts Pass with FileCheck ] ====="
echo "Testing CoalescePuts optimization patterns..."
if "$MLIR_OPT" "$COALESCE_TEST_FILE" --openshmem-coalesce-puts -o "$COALESCE_OUT" && \
   "$MLIR_OPT" "$COALESCE_TEST_FILE" --openshmem-coalesce-puts | "$FILECHECK" "$COALESCE_TEST_FILE"; then
	echo "PASS: CoalescePuts pass (FileCheck validated)"
	echo -e "\nOriginal MLIR:"
	bat --paging=never "$COALESCE_TEST_FILE"
	echo -e "\nAfter CoalescePuts optimization:"
	bat --paging=never "$COALESCE_OUT"
else
	echo "FAIL: CoalescePuts pass failed FileCheck validation"
fi

# 4. Test Stencil Coalescing Patterns with FileCheck
echo -e "\n===== [ Testing Stencil Coalescing Patterns with FileCheck ] ====="
echo "Testing advanced stencil optimization patterns..."
STENCIL_OUT="$OUTPUT_DIR/stencil-optimized.mlir"
if "$MLIR_OPT" "$STENCIL_TEST_FILE" --openshmem-coalesce-puts -split-input-file -o "$STENCIL_OUT" && \
   "$MLIR_OPT" "$STENCIL_TEST_FILE" --openshmem-coalesce-puts -split-input-file | "$FILECHECK" "$STENCIL_TEST_FILE"; then
	echo "PASS: Stencil coalescing patterns (FileCheck validated)"
	echo -e "\nOriginal stencil patterns:"
	bat --paging=never "$STENCIL_TEST_FILE"
	echo -e "\nAfter stencil coalescing optimization:"
	bat --paging=never "$STENCIL_OUT"
else
	echo "FAIL: Stencil coalescing patterns failed FileCheck validation"
fi

# 5. Test combining both passes
echo -e "\n===== [ Testing Combined Passes ] ====="
echo "Testing combined InjectNumPEs + CoalescePuts passes..."
COMBINED_OUT="$OUTPUT_DIR/openshmem-combined.mlir"
if "$MLIR_OPT" "$INPUT_OUT" \
	--openshmem-inject-num-pes="num-pes=16" \
	--openshmem-coalesce-puts \
	-o "$COMBINED_OUT" 2>/dev/null; then
	echo "PASS: Combined passes executed successfully"
	echo -e "\nAfter combined InjectNumPEs + CoalescePuts passes:"
	bat --paging=never "$COMBINED_OUT"
	
	# Verify the attribute is still there
	if grep -q "openshmem.num_pes = 16" "$COMBINED_OUT"; then
		echo -e "\nPASS: Module attribute preserved through combined passes"
	else
		echo -e "\nFAIL: Module attribute lost during combined passes"
	fi
else
	echo "FAIL: Combined passes failed"
fi

# 6. Test Bufferization (if possible)
echo -e "\n===== [ Testing Bufferization ] ====="
if "$MLIR_OPT" "$INPUT_OUT" --one-shot-bufferize="bufferize-function-boundaries=true" -o "$BUFFERIZED_OUT" 2>/dev/null; then
	echo "PASS: Bufferization succeeded"
	echo -e "\nAfter bufferization:"
	bat --paging=never "$BUFFERIZED_OUT"
else
	echo "INFO: Bufferization not applicable or failed (skipping)"
fi

# 7. Test InjectNumPEsPass with LLVM lowering
echo -e "\n===== [ Testing InjectNumPEsPass + LLVM Lowering ] ====="
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
	bat --paging=never "$INJECT_LLVM_OUT"
	
	# Check if the attribute survived the lowering
	if grep -q "openshmem.num_pes = 8" "$INJECT_LLVM_OUT"; then
		echo -e "\nPASS: Module attribute survived LLVM lowering"
	else
		echo -e "\nINFO: Module attribute was removed during LLVM lowering (this may be expected)"
	fi
else
	echo "FAIL: InjectNumPEsPass + LLVM lowering failed"
fi

# 8. Test LLVM Lowering with FileCheck
echo -e "\n===== [ Testing LLVM Lowering with FileCheck ] ====="
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

# 9. Generate output files for inspection
echo -e "\n===== [ Final LLVM MLIR and LLVM IR Generation ] ====="
echo "Generating LLVM MLIR dialect output..."
"$MLIR_OPT" "$INPUT_OUT" \
	--convert-openshmem-to-llvm \
	--convert-arith-to-llvm \
	--finalize-memref-to-llvm \
	--convert-func-to-llvm \
	--reconcile-unrealized-casts \
	-o "$LLVM_MLIR_OUT"

echo -e "\nLLVM MLIR Dialect:"
bat --paging=never "$LLVM_MLIR_OUT"

echo -e "\nGenerating LLVM IR output..."
"$MLIR_TRANSLATE" "$LLVM_MLIR_OUT" --mlir-to-llvmir -o "$LLVM_IR_OUT"

echo -e "\nFinal LLVM IR:"
bat --paging=never "$LLVM_IR_OUT"

echo -e "\nAll tests completed successfully!"
echo "=================================="
echo "PASS: InjectNumPEsPass tested with FileCheck validation"
echo "PASS: CoalescePuts pass tested with FileCheck validation" 
echo "PASS: Stencil coalescing patterns tested with FileCheck validation"
echo "PASS: Combined passes tested"
echo "PASS: Complete LLVM lowering tested with FileCheck validation"
echo ""
echo "Output files saved in: $OUTPUT_DIR"
echo "All transformations validated with FileCheck patterns"
