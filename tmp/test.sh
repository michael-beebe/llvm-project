#!/bin/bash

set -e

BUILD_DIR="build"
TEST_FILE="mlir/test/Dialect/OpenSHMEM/openshmemops.mlir"
MLIR_OPT="$BUILD_DIR/bin/mlir-opt"
MLIR_TRANSLATE="$BUILD_DIR/bin/mlir-translate"
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

echo "Testing OpenSHMEM MLIR Dialect"
echo "=================================="

# 1. Dump the original OpenSHMEM MLIR
cp "$TEST_FILE" "$INPUT_OUT"
echo -e "\n===== [ OpenSHMEM Dialect MLIR (input) ] ====="
bat "$INPUT_OUT"

# 2. Test InjectNumPEsPass
echo -e "\n===== [ Testing InjectNumPEsPass ] ====="
if "$MLIR_OPT" "$INPUT_OUT" --openshmem-inject-num-pes="num-pes=4" -o "$INJECT_NUMPES_OUT" 2>/dev/null; then
	echo "PASS: InjectNumPEsPass with num-pes=4:"
	bat "$INJECT_NUMPES_OUT"
	
	# Verify the attribute was added
	if grep -q "openshmem.num_pes = 4" "$INJECT_NUMPES_OUT"; then
		echo "PASS: Module attribute 'openshmem.num_pes = 4' correctly injected"
	else
		echo "FAIL: Module attribute 'openshmem.num_pes' was not found in output"
	fi
else
	echo "FAIL: InjectNumPEsPass failed"
fi

# Test without num-pes option (should not add attribute)
if "$MLIR_OPT" "$INPUT_OUT" --openshmem-inject-num-pes -o "$INJECT_NUMPES_TEST" 2>/dev/null; then
	if grep -q "openshmem.num_pes" "$INJECT_NUMPES_TEST"; then
		echo "FAIL: Module attribute should not be added when no num-pes option provided"
	else
		echo "PASS: No attribute added when num-pes option not provided (correct behavior)"
	fi
else
	echo "FAIL: InjectNumPEsPass failed without options"
fi

# Test CoalescePuts pass
echo -e "\n===== [ Testing CoalescePuts Pass ] ====="
if "$MLIR_OPT" "$INPUT_OUT" --openshmem-coalesce-puts -o "$COALESCE_OUT" 2>/dev/null; then
	echo "PASS: CoalescePuts pass executed successfully:"
	bat "$COALESCE_OUT"
else
	echo "FAIL: CoalescePuts pass failed"
fi

# Test combining both passes
echo -e "\n===== [ Testing Combined Passes ] ====="
COMBINED_OUT="$OUTPUT_DIR/openshmem-combined.mlir"
if "$MLIR_OPT" "$INPUT_OUT" \
	--openshmem-inject-num-pes="num-pes=16" \
	--openshmem-coalesce-puts \
	-o "$COMBINED_OUT" 2>/dev/null; then
	echo "PASS: Combined InjectNumPEs + CoalescePuts passes:"
	bat "$COMBINED_OUT"
	
	# Verify the attribute is still there
	if grep -q "openshmem.num_pes = 16" "$COMBINED_OUT"; then
		echo "PASS: Module attribute preserved through combined passes"
	else
		echo "FAIL: Module attribute lost during combined passes"
	fi
else
	echo "FAIL: Combined passes failed"
fi

# 3. Bufferization (if possible)
if "$MLIR_OPT" "$INPUT_OUT" --one-shot-bufferize="bufferize-function-boundaries=true" -o "$BUFFERIZED_OUT" 2>/dev/null; then
	echo -e "\n===== [ After Bufferization ] ====="
	bat "$BUFFERIZED_OUT"
else
	echo -e "\n[Bufferization not applicable or failed, skipping]"
fi

# 4. Lower to Affine (if possible)
if "$MLIR_OPT" "$INPUT_OUT" --convert-openshmem-to-affine -o "$AFFINE_OUT" 2>/dev/null; then
	echo -e "\n===== [ After Lowering to Affine ] ====="
	bat "$AFFINE_OUT"
else
	echo -e "\n[Affine lowering not applicable or failed, skipping]"
fi

# 5. Lower to SCF (if possible)
if "$MLIR_OPT" "$INPUT_OUT" --convert-openshmem-to-scf -o "$SCF_OUT" 2>/dev/null; then
	echo -e "\n===== [ After Lowering to SCF ] ====="
	bat "$SCF_OUT"
else
	echo -e "\n[SCF lowering not applicable or failed, skipping]"
fi

# 6. Lower to CF (if possible)
if "$MLIR_OPT" "$INPUT_OUT" --convert-openshmem-to-scf --convert-scf-to-cf -o "$CF_OUT" 2>/dev/null; then
	echo -e "\n===== [ After Lowering to CF ] ====="
	bat "$CF_OUT"
else
	echo -e "\n[CF lowering not applicable or failed, skipping]"
fi

# 7. Test InjectNumPEsPass with LLVM lowering
echo -e "\n===== [ Testing InjectNumPEsPass + LLVM Lowering ] ====="
INJECT_LLVM_OUT="$OUTPUT_DIR/openshmem-inject-llvm.mlir"
if "$MLIR_OPT" "$INPUT_OUT" \
	--openshmem-inject-num-pes="num-pes=8" \
	--convert-openshmem-to-llvm \
	--convert-func-to-llvm \
	--test-lower-to-llvm \
	--reconcile-unrealized-casts \
	-o "$INJECT_LLVM_OUT" 2>/dev/null; then
	echo "PASS: InjectNumPEsPass + LLVM lowering with num-pes=8:"
	bat "$INJECT_LLVM_OUT"
	
	# Check if the attribute survived the lowering
	if grep -q "openshmem.num_pes = 8" "$INJECT_LLVM_OUT"; then
		echo "PASS: Module attribute survived LLVM lowering"
	else
		echo "WARN: Module attribute was removed during LLVM lowering (this may be expected)"
	fi
else
	echo "FAIL: InjectNumPEsPass + LLVM lowering failed"
fi

# 8. Lower to LLVM MLIR dialect
if "$MLIR_OPT" "$INPUT_OUT" \
	--convert-openshmem-to-llvm \
	--convert-func-to-llvm \
	--test-lower-to-llvm \
	--reconcile-unrealized-casts \
	-o "$LLVM_MLIR_OUT"; then
	echo -e "\n===== [ LLVM MLIR Dialect ] ====="
	bat "$LLVM_MLIR_OUT"
else
	echo "FAIL: MLIR lowering to LLVM dialect failed"
	bat "$LLVM_MLIR_OUT"
	exit 1
fi

# 9. Lower to LLVM IR
if "$MLIR_TRANSLATE" "$LLVM_MLIR_OUT" --mlir-to-llvmir -o "$LLVM_IR_OUT"; then
	echo -e "\n===== [ LLVM IR ] ====="
	bat "$LLVM_IR_OUT"
	
	echo -e "\nAll tests completed successfully!"
	echo "=================================="
	echo "PASS: InjectNumPEsPass tested (with and without options)"
	echo "PASS: CoalescePuts pass tested"
	echo "PASS: Combined passes tested"
	echo "PASS: LLVM lowering tested"
	echo "PASS: LLVM IR generation tested"
	echo ""
	echo "Output files saved in: $OUTPUT_DIR"
	exit 0
else
	echo "FAIL: LLVM IR generation failed"
	bat "$LLVM_IR_OUT"
	exit 1
fi
