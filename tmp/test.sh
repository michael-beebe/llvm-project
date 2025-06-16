#!/bin/bash

# Simple OpenSHMEM MLIR Dialect Test
set -e

BUILD_DIR="build"
TEST_FILE="mlir/test/Dialect/OpenSHMEM/openshmemops.mlir"
MLIR_OPT="$BUILD_DIR/bin/mlir-opt"
MLIR_TRANSLATE="$BUILD_DIR/bin/mlir-translate"

echo "🧪 Testing OpenSHMEM MLIR Dialect"
echo "=================================="

# Check if tools exist
if [[ ! -f "$MLIR_OPT" ]]; then
    echo "❌ mlir-opt not found. Build MLIR first: ./tmp/build.sh --mlir"
    exit 1
fi

if [[ ! -f "$MLIR_TRANSLATE" ]]; then
    echo "❌ mlir-translate not found. Build MLIR first: ./tmp/build.sh --mlir"
    exit 1
fi

echo "✅ Tools found"

# Run the test
echo "📝 Running OpenSHMEM test..."
echo

# Show the original MLIR
echo "Original MLIR:"
echo "--------------"
cat "$TEST_FILE"
echo

# Convert to LLVM IR
echo "Generated LLVM IR:"
echo "------------------"
"$MLIR_OPT" "$TEST_FILE" --convert-openshmem-to-llvm --convert-func-to-llvm --reconcile-unrealized-casts | \
"$MLIR_TRANSLATE" --mlir-to-llvmir

echo
echo "✅ Test completed!"



