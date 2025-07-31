#!/bin/bash

# Script to clean up all temporary files and binaries from OpenSHMEM stencil compilation

echo "Cleaning up stencil compilation artifacts..."

# Remove intermediate MLIR and LLVM IR files
rm -f step1_with_num_pes.mlir
rm -f step2_llvm_dialect.mlir 
rm -f step3_llvm_ir.ll

# Remove binaries
rm -f stencil01 stencil01_mlir stencil01_c stencil01_gcc test_verbose

# Remove assembly files
rm -f stencil01_c.s

# Remove any test files
rm -f step1_test.mlir

echo "Cleanup complete!"
echo "Removed:"
echo "  - MLIR intermediate files (step1_*, step2_*)"
echo "  - LLVM IR files (step3_*)"
echo "  - Binary executables (stencil01*, *_c, *_gcc, test_verbose)"
echo "  - Assembly files (*.s)"
echo "  - Test files"