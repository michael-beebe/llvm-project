#!/bin/bash

# Script to compile OpenSHMEM stencil MLIR dialect to binary executable
# This demonstrates the lowering pipeline from OpenSHMEM dialect to executable

set -e  # Exit on any error

# Paths
MLIR_OPT="/root/lanl/llvm/llvm-project-openshmem/build/bin/mlir-opt"
MLIR_TRANSLATE="/root/lanl/llvm/llvm-project-openshmem/build/bin/mlir-translate"
CLANG="/root/lanl/llvm/llvm-project-openshmem/build/bin/clang"

INPUT_FILE="stencil01.mlir"
OUTPUT_BINARY="stencil01_mlir"

echo "=== OpenSHMEM Stencil Compilation Pipeline ==="
echo "Input: $INPUT_FILE"
echo "Output: $OUTPUT_BINARY"
echo

# Step 0: Clean up any existing intermediate files and binary
echo "Step 0: Cleaning up previous compilation artifacts..."
./clean.sh
echo

# Step 1: Inject number of PEs (if not already set in the module)
echo "Step 1: Injecting number of PEs..."
$MLIR_OPT $INPUT_FILE \
    --openshmem-inject-num-pes=num-pes=4 \
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

# Step 3.5: Add printf functionality to LLVM IR
echo "Step 3.5: Adding printf declaration and functionality to LLVM IR..."

# Add global string constants and printf declaration 
cat > temp_globals.ll << 'EOF'
declare i32 @printf(ptr, ...)

@start_str = private constant [40 x i8] c"PE %d/%d: Starting stencil computation\0A\00"
@alloc_str = private constant [50 x i8] c"PE %d/%d: Allocated 64 bytes of symmetric memory\0A\00"
@barrier_enter_str = private constant [44 x i8] c"PE %d/%d: Entering barrier synchronization\0A\00"
@barrier_exit_str = private constant [45 x i8] c"PE %d/%d: Completed barrier synchronization\0A\00"
@complete_str = private constant [52 x i8] c"PE %d/%d: Freed symmetric memory, stencil complete\0A\00"

EOF

# Fix the structure by placing globals after ModuleID 
# Extract the first line (ModuleID) and source_filename
head -2 step3_llvm_ir.ll > temp_header.ll
# Get the rest starting from the first declare
tail -n +3 step3_llvm_ir.ll > temp_body.ll
# Combine: header + globals + body
cat temp_header.ll temp_globals.ll temp_body.ll > temp_combined.ll
mv temp_combined.ll step3_llvm_ir.ll
rm temp_globals.ll temp_header.ll temp_body.ll

# Add printf calls after specific OpenSHMEM operations
# After shmem_init and getting PE info
sed -i '/call i32 @shmem_n_pes/a \
  %start_str_ptr = getelementptr [40 x i8], ptr @start_str, i32 0, i32 0\
  %printf_call1 = call i32 (ptr, ...) @printf(ptr %start_str_ptr, i32 %3, i32 %4)' step3_llvm_ir.ll

# After shmem_malloc  
sed -i '/call ptr @shmem_malloc/a \
  %alloc_str_ptr = getelementptr [50 x i8], ptr @alloc_str, i32 0, i32 0\
  %printf_call2 = call i32 (ptr, ...) @printf(ptr %alloc_str_ptr, i32 %3, i32 %4)' step3_llvm_ir.ll

# Before shmem_finalize
sed -i '/call void @shmem_finalize/i \
  %complete_str_ptr = getelementptr [52 x i8], ptr @complete_str, i32 0, i32 0\
  %printf_call3 = call i32 (ptr, ...) @printf(ptr %complete_str_ptr, i32 %3, i32 %4)' step3_llvm_ir.ll

echo "  Output: step3_llvm_ir.ll (with printf support)"

# Step 4: Compile LLVM IR to executable with proper OpenSHMEM library linking
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
echo "Compiling stencil01.c with oshcc..."
oshcc stencil01.c -o stencil01_c
echo "  Output: stencil01_c (C version)"
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
echo "   oshrun -np 4 --allow-run-as-root ./$OUTPUT_BINARY"
echo
echo "3. Try with simple execution to test basic functionality:"
echo "   timeout 5s ./$OUTPUT_BINARY || echo 'Program may have run but OpenSHMEM runtime failed'"
echo
echo "To clean up intermediate files:"
echo "  ./clean.sh"
