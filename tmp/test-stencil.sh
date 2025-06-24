#!/bin/bash

echo "Testing OpenSHMEM CoalescePuts Pass with Stencil Pattern"
echo "========================================================"

cd /root/lanl/llvm/llvm-project-openshmem

echo
echo "MLIR with OpenSHMEM dialect already built!"

echo
echo "Running stencil coalescing test..."
echo "Input MLIR:"
echo "----------"
cat mlir/test/Dialect/OpenSHMEM/stencil-01.mlir

echo
echo "Running mlir-opt with CoalescePuts pass..."
echo "=========================================="
build/bin/mlir-opt mlir/test/Dialect/OpenSHMEM/stencil-01.mlir -openshmem-coalesce-puts -split-input-file

echo
echo "Running FileCheck to validate optimization..."
echo "============================================"
build/bin/mlir-opt mlir/test/Dialect/OpenSHMEM/stencil-01.mlir -openshmem-coalesce-puts -split-input-file | build/bin/FileCheck mlir/test/Dialect/OpenSHMEM/stencil-01.mlir

if [ $? -eq 0 ]; then
    echo
    echo "SUCCESS: CoalescePuts pass correctly optimized stencil patterns!"
    echo "All FileCheck patterns matched - optimization working as expected!"
else
    echo
    echo "FAILED: CoalescePuts pass test failed!"
    echo "FileCheck validation failed - optimization not working correctly!"
    exit 1
fi

echo
echo "Test completed successfully!" 