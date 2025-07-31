#!/bin/bash

# Script to compile simple OpenSHMEM Hello World MLIR to binary executable
# This demonstrates a minimal compilation pipeline

set -e  # Exit on any error

# Paths
MLIR_OPT="/root/lanl/llvm/llvm-project-openshmem/build/bin/mlir-opt"
MLIR_TRANSLATE="/root/lanl/llvm/llvm-project-openshmem/build/bin/mlir-translate"
CLANG="/root/lanl/llvm/llvm-project-openshmem/build/bin/clang"

INPUT_FILE="hello.mlir"
OUTPUT_BINARY="hello_mlir"

echo "=== OpenSHMEM Hello World Compilation Pipeline ==="
echo "Input: $INPUT_FILE"
echo "Output: $OUTPUT_BINARY"
echo

# Step 0: Clean up any existing intermediate files and binary
echo "Step 0: Cleaning up previous compilation artifacts..."
./clean.sh
echo

# Step 1: Inject number of PEs (using default 2 for hello world)
echo "Step 1: Injecting number of PEs..."
$MLIR_OPT $INPUT_FILE \
    --openshmem-inject-num-pes=num-pes=2 \
    -o step1_with_num_pes.mlir
echo "  Output: step1_with_num_pes.mlir"

# Step 2: Convert OpenSHMEM dialect to LLVM dialect
echo "Step 2: Converting OpenSHMEM to LLVM dialect..."
$MLIR_OPT step1_with_num_pes.mlir \
    --convert-openshmem-to-llvm \
    --convert-arith-to-llvm \
    --convert-func-to-llvm \
    --finalize-memref-to-llvm \
    --convert-cf-to-llvm \
    --reconcile-unrealized-casts \
    --allow-unregistered-dialect \
    -o step2_llvm_dialect.mlir
echo "  Output: step2_llvm_dialect.mlir"

# Step 3: Convert MLIR LLVM dialect to LLVM IR
echo "Step 3: Converting MLIR LLVM dialect to LLVM IR..."
$MLIR_TRANSLATE step2_llvm_dialect.mlir \
    --mlir-to-llvmir \
    --allow-unregistered-dialect \
    -o step3_llvm_ir.ll
echo "  Output: step3_llvm_ir.ll"

# Step 3.5: Add printf functionality to match C version exactly
echo "Step 3.5: Adding printf functionality to LLVM IR..."
# Add printf declaration after shmem_init declaration
sed -i '/declare void @shmem_init()/a declare i32 @printf(ptr, ...)' step3_llvm_ir.ll

# Add printf call in main function after shmem_n_pes call
sed -i '/call i32 @shmem_n_pes()/a \  %5 = getelementptr [24 x i8], ptr @hello_str, i32 0, i32 0\n  %6 = call i32 (ptr, ...) @printf(ptr %5, i32 %3, i32 %4)' step3_llvm_ir.ll
echo "  Modified LLVM IR to include printf calls"

# Step 4: Compile LLVM IR to executable with OpenSHMEM library
echo "Step 4: Compiling LLVM IR to executable..."
$CLANG step3_llvm_ir.ll \
    -I/usr/local/include \
    -L/usr/local/lib \
    -L/root/sw/linuxkit-aarch64/pmix/lib64 \
    -L/root/sw/linuxkit-aarch64/pmix/lib \
    -L/root/sw/linuxkit-aarch64/ucx/lib64 \
    -L/root/sw/linuxkit-aarch64/ucx/lib \
    -lshmem -lshmemc-ucx -lshmemu -lshmemt -lshmem-amo -lpmix -lucp -lshcoll \
    -o $OUTPUT_BINARY
echo "  Output: $OUTPUT_BINARY"

echo
echo "=== Compilation Complete ==="
echo "Binary created: $OUTPUT_BINARY"
echo

# Optional: Compile C version for comparison
echo "=== Compiling C version for comparison ==="
echo "Compiling hello.c with oshcc..."
oshcc hello.c -o hello_c
echo "  Output: hello_c (C version)"
echo

# Let's verify the binary was properly linked
echo "=== Binary Analysis ==="
echo "File type:"
file $OUTPUT_BINARY

echo
echo "OpenSHMEM library linkage:"
ldd $OUTPUT_BINARY | grep -i shmem || echo "  Note: OpenSHMEM library linked statically or not found"

echo
echo "OpenSHMEM symbols in the binary:"
nm $OUTPUT_BINARY | grep shmem || echo "  Note: No shmem symbols found (may be dynamically linked)"

echo
echo "Generated LLVM IR preview:"
echo "------------------------"
head -20 step3_llvm_ir.ll

echo
echo "=== Testing Options ==="
echo "1. Try running directly (may fail due to OpenSHMEM runtime setup):"
echo "   ./$OUTPUT_BINARY"
echo
echo "2. Try with oshrun (if environment is properly configured):"
echo "   oshrun -np 2 --allow-run-as-root ./$OUTPUT_BINARY"
echo
echo "3. Try with simple execution to test basic functionality:"
echo "   timeout 5s ./$OUTPUT_BINARY || echo 'Program may have run but OpenSHMEM runtime failed'"
echo
echo "To clean up intermediate files:"
echo "  ./clean.sh"