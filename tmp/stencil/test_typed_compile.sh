#!/bin/bash

echo "=== Testing Fixed Typed Function Name Generation ==="
echo "Input: test_typed.mlir"
echo "Testing if openshmem.put/get generate correct function names"
echo

# Paths to tools
MLIR_OPT="/root/lanl/llvm/llvm-project-openshmem/build/bin/mlir-opt"
MLIR_TRANSLATE="/root/lanl/llvm/llvm-project-openshmem/build/bin/mlir-translate"

echo "Step 1: Inject number of PEs..."
$MLIR_OPT test_typed.mlir \
    --openshmem-inject-num-pes="num-pes=4" \
    -o step1_typed.mlir
if [ $? -ne 0 ]; then
    echo "ERROR: Step 1 failed"
    exit 1
fi

echo "Step 2: Convert OpenSHMEM to LLVM dialect..."
$MLIR_OPT step1_typed.mlir \
    --convert-openshmem-to-llvm \
    --convert-arith-to-llvm \
    --convert-func-to-llvm \
    --finalize-memref-to-llvm \
    --convert-cf-to-llvm \
    --reconcile-unrealized-casts \
    -o step2_typed.mlir
if [ $? -ne 0 ]; then
    echo "ERROR: Step 2 failed"
    exit 1
fi

echo "Step 3: Convert to LLVM IR..."
$MLIR_TRANSLATE step2_typed.mlir \
    --mlir-to-llvmir \
    -o step3_typed.ll
if [ $? -ne 0 ]; then
    echo "ERROR: Step 3 failed"
    exit 1
fi

echo
echo "=== SUCCESS: All steps completed ==="
echo
echo "Checking generated function calls..."
echo "Looking for correct typed function names:"
echo

# Check what functions are being called
echo "1. Should see 'shmem_float_put' (not 'shmem_put32'):"
grep -n "shmem.*put" step3_typed.ll || echo "   No put calls found"

echo
echo "2. Should see 'shmem_float_get' (not 'shmem_get32'):"
grep -n "shmem.*get" step3_typed.ll || echo "   No get calls found"

echo
echo "3. All function declarations:"
grep -n "declare.*shmem" step3_typed.ll || echo "   No shmem declarations found"

echo
echo "=== Generated LLVM IR Analysis ==="
echo "If you see 'shmem_float_put' and 'shmem_float_get', the fix worked!"
echo "If you see 'shmem_put32' and 'shmem_get32', the fix didn't work."