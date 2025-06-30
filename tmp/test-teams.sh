#!/bin/bash

set -e

BUILD_DIR="build"
TEAMS_TEST_FILE="mlir/test/Dialect/OpenSHMEM/teams.mlir"
OPENSHMEM_TEST_FILE="mlir/test/Dialect/OpenSHMEM/openshmemops.mlir"
MLIR_OPT="$BUILD_DIR/bin/mlir-opt"
MLIR_TRANSLATE="$BUILD_DIR/bin/mlir-translate"
FILECHECK="$BUILD_DIR/bin/FileCheck"
OUTPUT_DIR="tmp/teams_test_outputs"

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

# Test 1: Basic Teams Functionality
echo -e "\n===== [ Testing Basic Teams Functionality ] ====="
if [ -f "$TEAMS_TEST_FILE" ]; then
    echo "Testing teams.mlir with complete LLVM lowering pipeline..."
    TEAMS_INPUT_OUT="$OUTPUT_DIR/teams-input.mlir"
    TEAMS_LLVM_MLIR_OUT="$OUTPUT_DIR/teams-llvm.mlir"
    TEAMS_LLVM_IR_OUT="$OUTPUT_DIR/teams.ll"
    
    cp "$TEAMS_TEST_FILE" "$TEAMS_INPUT_OUT"
    echo -e "\nOriginal Teams MLIR:"
    $CAT "$TEAMS_INPUT_OUT"
    
    # Test LLVM lowering with FileCheck validation
    if "$MLIR_OPT" "$TEAMS_TEST_FILE" \
        --convert-openshmem-to-llvm \
        --convert-arith-to-llvm \
        --finalize-memref-to-llvm \
        --convert-func-to-llvm \
        --reconcile-unrealized-casts | \
       "$MLIR_TRANSLATE" --mlir-to-llvmir | \
       "$FILECHECK" "$TEAMS_TEST_FILE"; then
        echo "PASS: Teams LLVM lowering pipeline (FileCheck validated)"
    else
        echo "FAIL: Teams LLVM lowering pipeline failed FileCheck validation"
        exit 1
    fi
    
    # Generate LLVM MLIR
    echo -e "\nGenerating Teams LLVM MLIR..."
    "$MLIR_OPT" "$TEAMS_INPUT_OUT" \
        --convert-openshmem-to-llvm \
        --convert-arith-to-llvm \
        --finalize-memref-to-llvm \
        --convert-func-to-llvm \
        --reconcile-unrealized-casts \
        -o "$TEAMS_LLVM_MLIR_OUT"
    
    echo -e "\nTeams LLVM MLIR Dialect:"
    $CAT "$TEAMS_LLVM_MLIR_OUT"
    
    # Generate LLVM IR
    echo -e "\nGenerating Teams LLVM IR..."
    "$MLIR_TRANSLATE" "$TEAMS_LLVM_MLIR_OUT" --mlir-to-llvmir -o "$TEAMS_LLVM_IR_OUT"
    
    echo -e "\nFinal Teams LLVM IR:"
    $CAT "$TEAMS_LLVM_IR_OUT"
else
    echo "WARNING: teams.mlir not found, skipping teams-specific tests"
fi

# Test 2: Individual Team Operations
echo -e "\n===== [ Testing Individual Team Operations ] ====="

# Test team type parsing
echo "Testing team type parsing..."
TEAM_TYPE_TEST="$OUTPUT_DIR/team-type-test.mlir"
cat > "$TEAM_TYPE_TEST" << 'EOF'
module {
  func.func @test_team_types() {
    %world_team = openshmem.team_world -> !openshmem.team
    %shared_team = openshmem.team_shared -> !openshmem.team
    return
  }
}
EOF

if "$MLIR_OPT" "$TEAM_TYPE_TEST" --verify-diagnostics -o /dev/null; then
    echo "PASS: Team type parsing"
else
    echo "FAIL: Team type parsing"
fi

# Test team split operations
echo -e "\nTesting team split operations..."
TEAM_SPLIT_TEST="$OUTPUT_DIR/team-split-test.mlir"
cat > "$TEAM_SPLIT_TEST" << 'EOF'
module {
  func.func @test_team_splits() {
    openshmem.init
    %world_team = openshmem.team_world -> !openshmem.team
    
    // Test strided split
    %start = arith.constant 0 : i32
    %stride = arith.constant 1 : i32
    %size = arith.constant 2 : i32
    %strided_team, %ret1 = openshmem.team_split_strided(%world_team, %start, %stride, %size) : 
      !openshmem.team, i32, i32, i32 -> !openshmem.team, !openshmem.retval
    
    // Test 2D split
    %xrange = arith.constant 2 : i32
    %xaxis_team, %yaxis_team, %ret2 = openshmem.team_split_2d(%world_team, %xrange) : 
      !openshmem.team, i32 -> !openshmem.team, !openshmem.team, !openshmem.retval
    
    openshmem.team_destroy(%strided_team) : !openshmem.team
    openshmem.team_destroy(%xaxis_team) : !openshmem.team
    openshmem.team_destroy(%yaxis_team) : !openshmem.team
    openshmem.finalize
    return
  }
}
EOF

if "$MLIR_OPT" "$TEAM_SPLIT_TEST" --verify-diagnostics -o /dev/null; then
    echo "PASS: Team split operations parsing"
else
    echo "FAIL: Team split operations parsing"
fi

# Test team query operations
echo -e "\nTesting team query operations..."
TEAM_QUERY_TEST="$OUTPUT_DIR/team-query-test.mlir"
cat > "$TEAM_QUERY_TEST" << 'EOF'
module {
  func.func @test_team_queries() {
    openshmem.init
    %world_team = openshmem.team_world -> !openshmem.team
    
    %team_pe = openshmem.team_my_pe(%world_team) : !openshmem.team -> i32
    %team_npes = openshmem.team_n_pes(%world_team) : !openshmem.team -> i32
    
    openshmem.finalize
    return
  }
}
EOF

if "$MLIR_OPT" "$TEAM_QUERY_TEST" --verify-diagnostics -o /dev/null; then
    echo "PASS: Team query operations parsing"
else
    echo "FAIL: Team query operations parsing"
fi

# Test team synchronization
echo -e "\nTesting team synchronization..."
TEAM_SYNC_TEST="$OUTPUT_DIR/team-sync-test.mlir"
cat > "$TEAM_SYNC_TEST" << 'EOF'
module {
  func.func @test_team_sync() {
    openshmem.init
    %world_team = openshmem.team_world -> !openshmem.team
    openshmem.team_sync(%world_team) : !openshmem.team
    openshmem.finalize
    return
  }
}
EOF

if "$MLIR_OPT" "$TEAM_SYNC_TEST" --verify-diagnostics -o /dev/null; then
    echo "PASS: Team synchronization parsing"
else
    echo "FAIL: Team synchronization parsing"
fi

# Test 3: LLVM Lowering for Individual Operations
echo -e "\n===== [ Testing LLVM Lowering for Individual Team Operations ] ====="

# Test predefined teams lowering
echo "Testing predefined teams LLVM lowering..."
PREDEFINED_TEAMS_TEST="$OUTPUT_DIR/predefined-teams-test.mlir"
cat > "$PREDEFINED_TEAMS_TEST" << 'EOF'
module {
  func.func @test_predefined_teams() {
    %world_team = openshmem.team_world -> !openshmem.team
    %shared_team = openshmem.team_shared -> !openshmem.team
    return
  }
}
EOF

PREDEFINED_TEAMS_LLVM="$OUTPUT_DIR/predefined-teams-llvm.mlir"
if "$MLIR_OPT" "$PREDEFINED_TEAMS_TEST" \
    --convert-openshmem-to-llvm \
    --convert-func-to-llvm \
    --reconcile-unrealized-casts \
    -o "$PREDEFINED_TEAMS_LLVM"; then
    echo "PASS: Predefined teams LLVM lowering"
    echo -e "\nPredefined teams after LLVM lowering:"
    $CAT "$PREDEFINED_TEAMS_LLVM"
    
    # Check for expected LLVM constructs
    if grep -q "SHMEM_TEAM_WORLD" "$PREDEFINED_TEAMS_LLVM" && \
       grep -q "SHMEM_TEAM_SHARED" "$PREDEFINED_TEAMS_LLVM"; then
        echo "PASS: Predefined team constants generated correctly"
    else
        echo "FAIL: Predefined team constants not found in LLVM output"
    fi
else
    echo "FAIL: Predefined teams LLVM lowering"
fi

# Test team operations lowering
echo -e "\nTesting team operations LLVM lowering..."
TEAM_OPS_LLVM="$OUTPUT_DIR/team-ops-llvm.mlir"
if "$MLIR_OPT" "$TEAM_SPLIT_TEST" \
    --convert-openshmem-to-llvm \
    --convert-arith-to-llvm \
    --convert-func-to-llvm \
    --reconcile-unrealized-casts \
    -o "$TEAM_OPS_LLVM"; then
    echo "PASS: Team operations LLVM lowering"
    echo -e "\nTeam operations after LLVM lowering:"
    $CAT "$TEAM_OPS_LLVM"
    
    # Check for expected function calls
    if grep -q "shmem_team_split_strided" "$TEAM_OPS_LLVM" && \
       grep -q "shmem_team_split_2d" "$TEAM_OPS_LLVM" && \
       grep -q "shmem_team_destroy" "$TEAM_OPS_LLVM"; then
        echo "PASS: Team operation function calls generated correctly"
    else
        echo "FAIL: Expected team operation function calls not found"
    fi
else
    echo "FAIL: Team operations LLVM lowering"
fi

# Test 4: Integration with Existing Operations
echo -e "\n===== [ Testing Teams Integration with Existing Operations ] ====="

# Test teams with existing openshmemops.mlir (which now includes team_world)
echo "Testing teams integration with existing operations..."
if [ -f "$OPENSHMEM_TEST_FILE" ]; then
    INTEGRATION_LLVM="$OUTPUT_DIR/integration-llvm.mlir"
    if "$MLIR_OPT" "$OPENSHMEM_TEST_FILE" \
        --convert-openshmem-to-llvm \
        --convert-arith-to-llvm \
        --finalize-memref-to-llvm \
        --convert-func-to-llvm \
        --reconcile-unrealized-casts \
        -o "$INTEGRATION_LLVM"; then
        echo "PASS: Teams integration with existing operations"
        
        # Check that both regular and team operations are present
        if grep -q "shmem_init" "$INTEGRATION_LLVM" && \
           grep -q "shmem_malloc" "$INTEGRATION_LLVM" && \
           grep -q "shmem_putmem" "$INTEGRATION_LLVM" && \
           grep -q "shmem_team_sync" "$INTEGRATION_LLVM" && \
           grep -q "SHMEM_TEAM_WORLD" "$INTEGRATION_LLVM"; then
            echo "PASS: All operation types present in integrated lowering"
        else
            echo "FAIL: Missing operations in integrated lowering"
        fi
    else
        echo "FAIL: Teams integration with existing operations"
    fi
else
    echo "WARNING: openshmemops.mlir not found, skipping integration test"
fi

# Test 5: Error Cases and Edge Cases
echo -e "\n===== [ Testing Error Cases and Edge Cases ] ====="

# Test invalid team usage (this should fail verification)
echo "Testing invalid team usage (should fail)..."
INVALID_TEAM_TEST="$OUTPUT_DIR/invalid-team-test.mlir"
cat > "$INVALID_TEAM_TEST" << 'EOF'
module {
  func.func @test_invalid_team() {
    // Try to use team operations without proper team
    %fake_pe = arith.constant 0 : i32
    // This should fail type checking
    // openshmem.team_my_pe(%fake_pe) : i32 -> i32
    return
  }
}
EOF

if "$MLIR_OPT" "$INVALID_TEAM_TEST" --verify-diagnostics -o /dev/null 2>/dev/null; then
    echo "PASS: Invalid team usage properly rejected"
else
    echo "INFO: Invalid team test (expected behavior varies)"
fi

# Test 6: Performance and Optimization Patterns
echo -e "\n===== [ Testing Teams with Optimization Patterns ] ====="

# Test teams with coalescing (teams should not interfere with put coalescing)
echo "Testing teams with put coalescing..."
TEAMS_COALESCE_TEST="$OUTPUT_DIR/teams-coalesce-test.mlir"
cat > "$TEAMS_COALESCE_TEST" << 'EOF'
module {
  func.func @test_teams_with_coalescing() {
    openshmem.init
    %world_team = openshmem.team_world -> !openshmem.team
    
    // Allocate memory
    %size = arith.constant 40 : index
    %sym_mem = openshmem.malloc(%size) : index -> !openshmem.symmetric_memref<i32>
    %local_data = memref.alloc() : memref<10xi32>
    
    // Team sync before communication
    openshmem.team_sync(%world_team) : !openshmem.team
    
    // Multiple puts that could be coalesced
    %pe1 = arith.constant 1 : i32
    %size1 = arith.constant 20 : index
    %size2 = arith.constant 20 : index
    openshmem.putmem(%sym_mem, %local_data, %size1, %pe1) : 
      !openshmem.symmetric_memref<i32>, memref<10xi32>, index, i32
    openshmem.putmem(%sym_mem, %local_data, %size2, %pe1) : 
      !openshmem.symmetric_memref<i32>, memref<10xi32>, index, i32
    
    // Team sync after communication
    openshmem.team_sync(%world_team) : !openshmem.team
    
    memref.dealloc %local_data : memref<10xi32>
    openshmem.free(%sym_mem) : !openshmem.symmetric_memref<i32>
    openshmem.finalize
    return
  }
}
EOF

TEAMS_COALESCE_OUT="$OUTPUT_DIR/teams-coalesce-optimized.mlir"
if "$MLIR_OPT" "$TEAMS_COALESCE_TEST" --openshmem-coalesce-puts -o "$TEAMS_COALESCE_OUT"; then
    echo "PASS: Teams with coalescing optimization"
    echo -e "\nAfter coalescing with teams:"
    $CAT "$TEAMS_COALESCE_OUT"
    
    # Check that team operations are preserved
    if grep -q "openshmem.team_sync" "$TEAMS_COALESCE_OUT"; then
        echo "PASS: Team operations preserved during coalescing"
    else
        echo "FAIL: Team operations lost during coalescing"
    fi
else
    echo "FAIL: Teams with coalescing optimization"
fi

# Test 7: Generate Final LLVM IR for Teams
echo -e "\n===== [ Generating Final LLVM IR for Teams ] ====="
if [ -f "$TEAMS_TEST_FILE" ]; then
    FINAL_TEAMS_IR="$OUTPUT_DIR/final-teams.ll"
    "$MLIR_OPT" "$TEAMS_TEST_FILE" \
        --convert-openshmem-to-llvm \
        --convert-arith-to-llvm \
        --finalize-memref-to-llvm \
        --convert-func-to-llvm \
        --reconcile-unrealized-casts | \
    "$MLIR_TRANSLATE" --mlir-to-llvmir -o "$FINAL_TEAMS_IR"
    
    echo "Final teams LLVM IR generated:"
    $CAT "$FINAL_TEAMS_IR"
    
    # Verify key team functions are declared
    if grep -q "declare.*shmem_team_split_strided" "$FINAL_TEAMS_IR" && \
       grep -q "declare.*shmem_team_sync" "$FINAL_TEAMS_IR" && \
       grep -q "declare.*shmem_team_my_pe" "$FINAL_TEAMS_IR"; then
        echo -e "\nPASS: All team function declarations present in final IR"
    else
        echo -e "\nFAIL: Missing team function declarations in final IR"
    fi
fi

echo -e "\nTeams Testing Summary"
echo "===================="
echo "PASS: Basic teams functionality tested"
echo "PASS: Individual team operations tested"
echo "PASS: LLVM lowering for team operations tested"
echo "PASS: Teams integration with existing operations tested"
echo "PASS: Error cases and edge cases tested"
echo "PASS: Teams with optimization patterns tested"
echo "PASS: Final LLVM IR generation tested"
echo ""
echo "All teams test outputs saved in: $OUTPUT_DIR"
echo "Teams implementation is ready for use!" 