#!/bin/bash

set -e

BUILD_DIR="build"
TEST_FILE="mlir/test/Dialect/OpenSHMEM/openshmemops.mlir"
MLIR_OPT="$BUILD_DIR/bin/mlir-opt"
MLIR_TRANSLATE="$BUILD_DIR/bin/mlir-translate"
OUTPUT_DIR="tmp/test_outputs"
INPUT_OUT="$OUTPUT_DIR/openshmem-input.mlir"
BUFFERIZED_OUT="$OUTPUT_DIR/openshmem-bufferized.mlir"
AFFINE_OUT="$OUTPUT_DIR/openshmem-affine.mlir"
SCF_OUT="$OUTPUT_DIR/openshmem-scf.mlir"
CF_OUT="$OUTPUT_DIR/openshmem-cf.mlir"
LLVM_MLIR_OUT="$OUTPUT_DIR/openshmem-llvm.mlir"
LLVM_IR_OUT="$OUTPUT_DIR/openshmem.ll"

mkdir -p "$OUTPUT_DIR"

# Check if tools exist
if [ ! -f "$MLIR_OPT" ]; then
	echo "❌ mlir-opt not found. Build MLIR first: ./tmp/build.sh --mlir"
	exit 1
fi
if [ ! -f "$MLIR_TRANSLATE" ]; then
	echo "❌ mlir-translate not found. Build MLIR first: ./tmp/build.sh --mlir"
	exit 1
fi

echo "🧪 Testing OpenSHMEM MLIR Dialect"
echo "=================================="

# 1. Dump the original OpenSHMEM MLIR
cp "$TEST_FILE" "$INPUT_OUT"
echo -e "\n===== [ OpenSHMEM Dialect MLIR (input) ] ====="
bat "$INPUT_OUT"

# 2. Bufferization (if possible)
if "$MLIR_OPT" "$INPUT_OUT" --one-shot-bufferize="bufferize-function-boundaries=true" -o "$BUFFERIZED_OUT" 2>/dev/null; then
	echo -e "\n===== [ After Bufferization ] ====="
	bat "$BUFFERIZED_OUT"
else
	echo -e "\n[Bufferization not applicable or failed, skipping]"
fi

# 3. Lower to Affine (if possible)
if "$MLIR_OPT" "$INPUT_OUT" --convert-openshmem-to-affine -o "$AFFINE_OUT" 2>/dev/null; then
	echo -e "\n===== [ After Lowering to Affine ] ====="
	bat "$AFFINE_OUT"
else
	echo -e "\n[Affine lowering not applicable or failed, skipping]"
fi

# 4. Lower to SCF (if possible)
if "$MLIR_OPT" "$INPUT_OUT" --convert-openshmem-to-scf -o "$SCF_OUT" 2>/dev/null; then
	echo -e "\n===== [ After Lowering to SCF ] ====="
	bat "$SCF_OUT"
else
	echo -e "\n[SCF lowering not applicable or failed, skipping]"
fi

# 5. Lower to CF (if possible)
if "$MLIR_OPT" "$INPUT_OUT" --convert-openshmem-to-scf --convert-scf-to-cf -o "$CF_OUT" 2>/dev/null; then
	echo -e "\n===== [ After Lowering to CF ] ====="
	bat "$CF_OUT"
else
	echo -e "\n[CF lowering not applicable or failed, skipping]"
fi

# 6. Lower to LLVM MLIR dialect
if "$MLIR_OPT" "$INPUT_OUT" \
	--convert-openshmem-to-llvm \
	--convert-func-to-llvm \
	--test-lower-to-llvm \
	--reconcile-unrealized-casts \
	-o "$LLVM_MLIR_OUT"; then
	echo -e "\n===== [ LLVM MLIR Dialect ] ====="
	bat "$LLVM_MLIR_OUT"
else
	echo "❌ MLIR lowering to LLVM dialect failed"
	bat "$LLVM_MLIR_OUT"
	exit 1
fi

# 7. Lower to LLVM IR
if "$MLIR_TRANSLATE" "$LLVM_MLIR_OUT" --mlir-to-llvmir -o "$LLVM_IR_OUT"; then
	echo -e "\n===== [ LLVM IR ] ====="
	bat "$LLVM_IR_OUT"
	exit 0
else
	echo "❌ LLVM IR generation failed"
	bat "$LLVM_IR_OUT"
	exit 1
fi
