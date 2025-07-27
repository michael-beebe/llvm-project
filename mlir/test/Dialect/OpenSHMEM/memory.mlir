// RUN: mlir-opt %s --convert-openshmem-to-llvm --convert-func-to-llvm --reconcile-unrealized-casts | mlir-translate --mlir-to-llvmir | FileCheck %s

// Test OpenSHMEM memory management operations

module {
  func.func @test_malloc() {
    // Initialize OpenSHMEM
    openshmem.init

    %size = arith.constant 1024 : index // 1024 bytes

    // Allocate symmetric memory
    %ptr = openshmem.malloc(%size) : index -> !openshmem.symmetric_memref<i8>

    // Free symmetric memory
    openshmem.free(%ptr) : !openshmem.symmetric_memref<i8>

    // Finalize OpenSHMEM
    openshmem.finalize
    return
  }

// CHECK-LABEL: llvm.func @test_malloc()
// CHECK: llvm.call @shmem_malloc(
// CHECK: llvm.call @shmem_free(

  func.func @test_malloc_different_types() {
    openshmem.init

    // Test with i32 type
    %size_i32 = arith.constant 400 : index // 100 * 4 bytes
    %ptr_i32 = openshmem.malloc(%size_i32) : index -> !openshmem.symmetric_memref<i32>

    // Test with f64 type
    %size_f64 = arith.constant 800 : index // 100 * 8 bytes
    %ptr_f64 = openshmem.malloc(%size_f64) : index -> !openshmem.symmetric_memref<f64>

    // Test with i64 type
    %size_i64 = arith.constant 800 : index // 100 * 8 bytes
    %ptr_i64 = openshmem.malloc(%size_i64) : index -> !openshmem.symmetric_memref<i64>

    // Free all allocations
    openshmem.free(%ptr_i32) : !openshmem.symmetric_memref<i32>
    openshmem.free(%ptr_f64) : !openshmem.symmetric_memref<f64>
    openshmem.free(%ptr_i64) : !openshmem.symmetric_memref<i64>

    openshmem.finalize
    return
  }

// CHECK-LABEL: llvm.func @test_malloc_different_types()
// CHECK: llvm.call @shmem_malloc(
// CHECK: llvm.call @shmem_malloc(
// CHECK: llvm.call @shmem_malloc(
// CHECK: llvm.call @shmem_free(
// CHECK: llvm.call @shmem_free(
// CHECK: llvm.call @shmem_free(

  func.func @test_realloc() {
    openshmem.init

    %initial_size = arith.constant 512 : index
    %new_size = arith.constant 1024 : index

    // Initial allocation
    %ptr = openshmem.malloc(%initial_size) : index -> !openshmem.symmetric_memref<i32>

    // Reallocate to larger size
    %new_ptr = openshmem.realloc(%ptr, %new_size) : !openshmem.symmetric_memref<i32>, index -> !openshmem.symmetric_memref<i32>

    // Free the reallocated memory
    openshmem.free(%new_ptr) : !openshmem.symmetric_memref<i32>

    openshmem.finalize
    return
  }

// CHECK-LABEL: llvm.func @test_realloc()
// CHECK: llvm.call @shmem_malloc(
// CHECK: llvm.call @shmem_realloc(
// CHECK: llvm.call @shmem_free(

  func.func @test_realloc_different_sizes() {
    openshmem.init

    %size1 = arith.constant 256 : index
    %size2 = arith.constant 512 : index
    %size3 = arith.constant 128 : index

    // Initial allocation
    %ptr1 = openshmem.malloc(%size1) : index -> !openshmem.symmetric_memref<f32>

    // Increase size
    %ptr2 = openshmem.realloc(%ptr1, %size2) : !openshmem.symmetric_memref<f32>, index -> !openshmem.symmetric_memref<f32>

    // Decrease size
    %ptr3 = openshmem.realloc(%ptr2, %size3) : !openshmem.symmetric_memref<f32>, index -> !openshmem.symmetric_memref<f32>

    openshmem.free(%ptr3) : !openshmem.symmetric_memref<f32>

    openshmem.finalize
    return
  }

// CHECK-LABEL: llvm.func @test_realloc_different_sizes()
// CHECK: llvm.call @shmem_malloc(
// CHECK: llvm.call @shmem_realloc(
// CHECK: llvm.call @shmem_realloc(
// CHECK: llvm.call @shmem_free(

  func.func @test_align() {
    openshmem.init

    %alignment = arith.constant 64 : index  // 64-byte alignment
    %size = arith.constant 1024 : index     // 1024 bytes

    // Allocate aligned memory
    %ptr = openshmem.align(%alignment, %size) : index, index -> !openshmem.symmetric_memref<i8>

    // Free aligned memory
    openshmem.free(%ptr) : !openshmem.symmetric_memref<i8>

    openshmem.finalize
    return
  }

// CHECK-LABEL: llvm.func @test_align()
// CHECK: llvm.call @shmem_align(
// CHECK: llvm.call @shmem_free(

  func.func @test_align_different_alignments() {
    openshmem.init

    // Test different alignment values
    %align8 = arith.constant 8 : index
    %align16 = arith.constant 16 : index
    %align32 = arith.constant 32 : index
    %align64 = arith.constant 64 : index
    %size = arith.constant 512 : index

    %ptr8 = openshmem.align(%align8, %size) : index, index -> !openshmem.symmetric_memref<i32>
    %ptr16 = openshmem.align(%align16, %size) : index, index -> !openshmem.symmetric_memref<i64>
    %ptr32 = openshmem.align(%align32, %size) : index, index -> !openshmem.symmetric_memref<f32>
    %ptr64 = openshmem.align(%align64, %size) : index, index -> !openshmem.symmetric_memref<f64>

    openshmem.free(%ptr8) : !openshmem.symmetric_memref<i32>
    openshmem.free(%ptr16) : !openshmem.symmetric_memref<i64>
    openshmem.free(%ptr32) : !openshmem.symmetric_memref<f32>
    openshmem.free(%ptr64) : !openshmem.symmetric_memref<f64>

    openshmem.finalize
    return
  }

// CHECK-LABEL: llvm.func @test_align_different_alignments()
// CHECK: llvm.call @shmem_align(
// CHECK: llvm.call @shmem_align(
// CHECK: llvm.call @shmem_align(
// CHECK: llvm.call @shmem_align(
// CHECK: llvm.call @shmem_free(
// CHECK: llvm.call @shmem_free(
// CHECK: llvm.call @shmem_free(
// CHECK: llvm.call @shmem_free(

  func.func @test_calloc() {
    openshmem.init

    %count = arith.constant 100 : index  // 100 elements
    %size = arith.constant 4 : index     // 4 bytes per element

    // Allocate and zero-initialize memory
    %ptr = openshmem.calloc(%count, %size) : index, index -> !openshmem.symmetric_memref<i32>

    // Free allocated memory
    openshmem.free(%ptr) : !openshmem.symmetric_memref<i32>

    openshmem.finalize
    return
  }

// CHECK-LABEL: llvm.func @test_calloc()
// CHECK: llvm.call @shmem_calloc(
// CHECK: llvm.call @shmem_free(

  func.func @test_calloc_different_types() {
    openshmem.init

    // Test with different element types and counts
    %count_small = arith.constant 50 : index
    %count_large = arith.constant 200 : index
    
    %size_i8 = arith.constant 1 : index   // 1 byte per i8
    %size_i16 = arith.constant 2 : index  // 2 bytes per i16
    %size_i64 = arith.constant 8 : index  // 8 bytes per i64
    %size_f32 = arith.constant 4 : index  // 4 bytes per f32

    %ptr_i8 = openshmem.calloc(%count_large, %size_i8) : index, index -> !openshmem.symmetric_memref<i8>
    %ptr_i16 = openshmem.calloc(%count_small, %size_i16) : index, index -> !openshmem.symmetric_memref<i16>
    %ptr_i64 = openshmem.calloc(%count_small, %size_i64) : index, index -> !openshmem.symmetric_memref<i64>
    %ptr_f32 = openshmem.calloc(%count_large, %size_f32) : index, index -> !openshmem.symmetric_memref<f32>

    openshmem.free(%ptr_i8) : !openshmem.symmetric_memref<i8>
    openshmem.free(%ptr_i16) : !openshmem.symmetric_memref<i16>
    openshmem.free(%ptr_i64) : !openshmem.symmetric_memref<i64>
    openshmem.free(%ptr_f32) : !openshmem.symmetric_memref<f32>

    openshmem.finalize
    return
  }

// CHECK-LABEL: llvm.func @test_calloc_different_types()
// CHECK: llvm.call @shmem_calloc(
// CHECK: llvm.call @shmem_calloc(
// CHECK: llvm.call @shmem_calloc(
// CHECK: llvm.call @shmem_calloc(
// CHECK: llvm.call @shmem_free(
// CHECK: llvm.call @shmem_free(
// CHECK: llvm.call @shmem_free(
// CHECK: llvm.call @shmem_free(

  func.func @test_memory_sequence() {
    openshmem.init

    %size = arith.constant 256 : index
    %count = arith.constant 64 : index
    %elem_size = arith.constant 4 : index
    %alignment = arith.constant 16 : index
    %new_size = arith.constant 512 : index

    // Test sequence: malloc -> realloc -> free
    %ptr1 = openshmem.malloc(%size) : index -> !openshmem.symmetric_memref<i32>
    %ptr2 = openshmem.realloc(%ptr1, %new_size) : !openshmem.symmetric_memref<i32>, index -> !openshmem.symmetric_memref<i32>
    openshmem.free(%ptr2) : !openshmem.symmetric_memref<i32>

    // Test aligned allocation
    %ptr3 = openshmem.align(%alignment, %size) : index, index -> !openshmem.symmetric_memref<f32>
    openshmem.free(%ptr3) : !openshmem.symmetric_memref<f32>

    // Test calloc
    %ptr4 = openshmem.calloc(%count, %elem_size) : index, index -> !openshmem.symmetric_memref<i32>
    openshmem.free(%ptr4) : !openshmem.symmetric_memref<i32>

    openshmem.finalize
    return
  }

// CHECK-LABEL: llvm.func @test_memory_sequence()
// CHECK: llvm.call @shmem_malloc(
// CHECK: llvm.call @shmem_realloc(
// CHECK: llvm.call @shmem_free(
// CHECK: llvm.call @shmem_align(
// CHECK: llvm.call @shmem_free(
// CHECK: llvm.call @shmem_calloc(
// CHECK: llvm.call @shmem_free(

  func.func @test_zero_size_allocations() {
    openshmem.init

    %zero_size = arith.constant 0 : index
    %alignment = arith.constant 8 : index

    // Test malloc with zero size
    %ptr1 = openshmem.malloc(%zero_size) : index -> !openshmem.symmetric_memref<i8>
    openshmem.free(%ptr1) : !openshmem.symmetric_memref<i8>

    // Test calloc with zero count
    %ptr2 = openshmem.calloc(%zero_size, %alignment) : index, index -> !openshmem.symmetric_memref<i8>
    openshmem.free(%ptr2) : !openshmem.symmetric_memref<i8>

    // Test align with zero size
    %ptr3 = openshmem.align(%alignment, %zero_size) : index, index -> !openshmem.symmetric_memref<i8>
    openshmem.free(%ptr3) : !openshmem.symmetric_memref<i8>

    openshmem.finalize
    return
  }

// CHECK-LABEL: llvm.func @test_zero_size_allocations()
// CHECK: llvm.call @shmem_malloc(
// CHECK: llvm.call @shmem_free(
// CHECK: llvm.call @shmem_calloc(
// CHECK: llvm.call @shmem_free(
// CHECK: llvm.call @shmem_align(
// CHECK: llvm.call @shmem_free(
}
