#!/bin/bash

set -e

BUILD_DIR="build"
TEAMS_TEST_FILE="mlir/test/Dialect/OpenSHMEM/teams.mlir"
MLIR_OPT="$BUILD_DIR/bin/mlir-opt"
MLIR_TRANSLATE="$BUILD_DIR/bin/mlir-translate"
FILECHECK="$BUILD_DIR/bin/FileCheck"
OUTPUT_DIR="tmp/test_outputs"

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

echo "Testing OpenSHMEM Teams MLIR Dialect"
echo "====================================="

# Print the original test file
echo -e "\n===== [ Original Test File ] ====="
$CAT "$TEAMS_TEST_FILE"

# Test: Teams Functionality with FileCheck Validation
echo -e "\n===== [ Testing Teams Functionality ] ====="
if [ -f "$TEAMS_TEST_FILE" ]; then
    echo "Running teams.mlir with complete LLVM lowering pipeline..."
    
    # Test LLVM lowering with FileCheck validation
    if "$MLIR_OPT" "$TEAMS_TEST_FILE" \
        --convert-openshmem-to-llvm \
        --convert-arith-to-llvm \
        --finalize-memref-to-llvm \
        --convert-func-to-llvm \
        --reconcile-unrealized-casts | \
       "$MLIR_TRANSLATE" --mlir-to-llvmir | \
       "$FILECHECK" "$TEAMS_TEST_FILE"; then
        echo "PASS: Teams functionality (FileCheck validated)"
    else
        echo "FAIL: Teams functionality failed FileCheck validation"
        exit 1
    fi
    
    # Generate intermediate outputs for inspection
    TEAMS_LLVM_MLIR_OUT="$OUTPUT_DIR/teams-llvm.mlir"
    TEAMS_LLVM_IR_OUT="$OUTPUT_DIR/teams.ll"
    
    echo -e "\nGenerating Teams LLVM MLIR..."
    "$MLIR_OPT" "$TEAMS_TEST_FILE" \
        --convert-openshmem-to-llvm \
        --convert-arith-to-llvm \
        --finalize-memref-to-llvm \
        --convert-func-to-llvm \
        --reconcile-unrealized-casts \
        -o "$TEAMS_LLVM_MLIR_OUT"
    
    echo -e "\nTeams LLVM MLIR:"
    $CAT "$TEAMS_LLVM_MLIR_OUT"
    
    echo -e "\nGenerating Teams LLVM IR..."
    "$MLIR_TRANSLATE" "$TEAMS_LLVM_MLIR_OUT" --mlir-to-llvmir -o "$TEAMS_LLVM_IR_OUT"
    
    echo -e "\nFinal Teams LLVM IR:"
    $CAT "$TEAMS_LLVM_IR_OUT"
    
    # Verify key team functions are declared
    if grep -q "declare.*shmem_team_split_strided" "$TEAMS_LLVM_IR_OUT" && \
       grep -q "declare.*shmem_team_sync" "$TEAMS_LLVM_IR_OUT" && \
       grep -q "declare.*shmem_team_my_pe" "$TEAMS_LLVM_IR_OUT" && \
       grep -q "@SHMEM_TEAM_WORLD" "$TEAMS_LLVM_IR_OUT" && \
       grep -q "@SHMEM_TEAM_SHARED" "$TEAMS_LLVM_IR_OUT"; then
        echo -e "\nPASS: All team function declarations and constants present in final IR"
    else
        echo -e "\nFAIL: Missing team function declarations or constants in final IR"
        exit 1
    fi
else
    echo "ERROR: teams.mlir not found at $TEAMS_TEST_FILE"
    exit 1
fi

echo -e "\nTeams Testing Summary"
echo "===================="
echo "PASS: All teams functionality tested with FileCheck validation"
echo "PASS: LLVM lowering for team operations verified"
echo "PASS: Final LLVM IR generation completed"
echo ""
echo "All teams test outputs saved in: $OUTPUT_DIR"
echo "Teams implementation is ready for use!" 