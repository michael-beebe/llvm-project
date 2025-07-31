#!/bin/bash

# Script to clean up all temporary files and binaries from OpenSHMEM compilation

echo "Cleaning up compilation artifacts..."

# Remove intermediate MLIR and LLVM IR files
rm -f step1_with_num_pes.mlir
rm -f step2_llvm_dialect.mlir 
rm -f step3_llvm_ir.ll

# Remove binaries
rm -f hello hello_mlir hello_c hello_gcc hello_mlir_with_printf test_verbose

# Remove assembly files
rm -f hello_c.s

# Remove any test files
rm -f step1_test.mlir

echo "Cleanup complete!"
echo "Removed:"
echo "  - MLIR intermediate files (step1_*, step2_*)"
echo "  - LLVM IR files (step3_*)"
echo "  - Binary executables (hello*, *_c, *_gcc, test_verbose)"
echo "  - Assembly files (*.s)"
echo "  - Test files"
