// RUN: mlir-opt %s --convert-openshmem-to-llvm --convert-func-to-llvm --reconcile-unrealized-casts | mlir-translate --mlir-to-llvmir | FileCheck %s

// Test OpenSHMEM atomic operations

module {
  // Test generic typed atomic fetch operations
  func.func @test_i32_atomic_fetch() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index // 4 bytes for i32
    
    // Allocate symmetric memory for source
    %src = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>
    
    // Perform atomic fetch operation
    %result = openshmem.atomic_fetch(%src, %pe) : memref<i32, #openshmem.symmetric_memory>, i32 -> i32
    
    openshmem.free(%src) : memref<i32, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_i32_atomic_fetch()
// CHECK: llvm.call @shmem_{{.*}}atomic_fetch{{.*}}(

  func.func @test_i64_atomic_fetch() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index // 8 bytes for i64
    
    // Allocate symmetric memory for source
    %src = openshmem.malloc(%size) : index -> memref<i64, #openshmem.symmetric_memory>
    
    // Perform atomic fetch operation
    %result = openshmem.atomic_fetch(%src, %pe) : memref<i64, #openshmem.symmetric_memory>, i32 -> i64
    
    openshmem.free(%src) : memref<i64, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_i64_atomic_fetch()
// CHECK: llvm.call @shmem_{{.*}}atomic_fetch{{.*}}(

  func.func @test_f32_atomic_fetch() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index // 4 bytes for f32
    
    // Allocate symmetric memory for source
    %src = openshmem.malloc(%size) : index -> memref<f32, #openshmem.symmetric_memory>
    
    // Perform atomic fetch operation
    %result = openshmem.atomic_fetch(%src, %pe) : memref<f32, #openshmem.symmetric_memory>, i32 -> f32
    
    openshmem.free(%src) : memref<f32, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_f32_atomic_fetch()
// CHECK: llvm.call @shmem_{{.*}}atomic_fetch{{.*}}(

  func.func @test_f64_atomic_fetch() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index // 8 bytes for f64
    
    // Allocate symmetric memory for source
    %src = openshmem.malloc(%size) : index -> memref<f64, #openshmem.symmetric_memory>
    
    // Perform atomic fetch operation
    %result = openshmem.atomic_fetch(%src, %pe) : memref<f64, #openshmem.symmetric_memory>, i32 -> f64
    
    openshmem.free(%src) : memref<f64, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_f64_atomic_fetch()
// CHECK: llvm.call @shmem_{{.*}}atomic_fetch{{.*}}(

  // Test context-aware typed atomic fetch operations
  func.func @test_ctx_i32_atomic_fetch() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index
    
    // Allocate symmetric memory for source
    %src = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>
    
    // Perform context-aware atomic fetch operation
    %result = openshmem.ctx_atomic_fetch(%ctx, %src, %pe) : !openshmem.ctx, memref<i32, #openshmem.symmetric_memory>, i32 -> i32
    
    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    openshmem.free(%src) : memref<i32, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_i32_atomic_fetch()
// CHECK: llvm.call @shmem_{{.*}}ctx_atomic_fetch{{.*}}(

  func.func @test_ctx_i64_atomic_fetch() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index
    
    // Allocate symmetric memory for source
    %src = openshmem.malloc(%size) : index -> memref<i64, #openshmem.symmetric_memory>
    
    // Perform context-aware atomic fetch operation
    %result = openshmem.ctx_atomic_fetch(%ctx, %src, %pe) : !openshmem.ctx, memref<i64, #openshmem.symmetric_memory>, i32 -> i64
    
    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    openshmem.free(%src) : memref<i64, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_i64_atomic_fetch()
// CHECK: llvm.call @shmem_{{.*}}ctx_atomic_fetch{{.*}}(

  func.func @test_ctx_f32_atomic_fetch() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index
    
    // Allocate symmetric memory for source
    %src = openshmem.malloc(%size) : index -> memref<f32, #openshmem.symmetric_memory>
    
    // Perform context-aware atomic fetch operation
    %result = openshmem.ctx_atomic_fetch(%ctx, %src, %pe) : !openshmem.ctx, memref<f32, #openshmem.symmetric_memory>, i32 -> f32
    
    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    openshmem.free(%src) : memref<f32, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_f32_atomic_fetch()
// CHECK: llvm.call @shmem_{{.*}}ctx_atomic_fetch{{.*}}(

  func.func @test_ctx_f64_atomic_fetch() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index
    
    // Allocate symmetric memory for source
    %src = openshmem.malloc(%size) : index -> memref<f64, #openshmem.symmetric_memory>
    
    // Perform context-aware atomic fetch operation
    %result = openshmem.ctx_atomic_fetch(%ctx, %src, %pe) : !openshmem.ctx, memref<f64, #openshmem.symmetric_memory>, i32 -> f64
    
    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    openshmem.free(%src) : memref<f64, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_f64_atomic_fetch()
// CHECK: llvm.call @shmem_{{.*}}ctx_atomic_fetch{{.*}}(

  // Test generic typed atomic set operations
  func.func @test_i32_atomic_set() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index // 4 bytes for i32
    %value = arith.constant 42 : i32
    
    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>
    
    // Perform atomic set operation
    openshmem.atomic_set(%dest, %value, %pe) : memref<i32, #openshmem.symmetric_memory>, i32, i32
    
    openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_i32_atomic_set()
// CHECK: llvm.call @shmem_{{.*}}atomic_set{{.*}}(

  func.func @test_i64_atomic_set() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index // 8 bytes for i64
    %value = arith.constant 42 : i64
    
    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i64, #openshmem.symmetric_memory>
    
    // Perform atomic set operation
    openshmem.atomic_set(%dest, %value, %pe) : memref<i64, #openshmem.symmetric_memory>, i64, i32
    
    openshmem.free(%dest) : memref<i64, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_i64_atomic_set()
// CHECK: llvm.call @shmem_{{.*}}atomic_set{{.*}}(

  func.func @test_f32_atomic_set() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index // 4 bytes for f32
    %value = arith.constant 42.0 : f32
    
    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<f32, #openshmem.symmetric_memory>
    
    // Perform atomic set operation
    openshmem.atomic_set(%dest, %value, %pe) : memref<f32, #openshmem.symmetric_memory>, f32, i32
    
    openshmem.free(%dest) : memref<f32, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_f32_atomic_set()
// CHECK: llvm.call @shmem_{{.*}}atomic_set{{.*}}(

  func.func @test_f64_atomic_set() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index // 8 bytes for f64
    %value = arith.constant 42.0 : f64
    
    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<f64, #openshmem.symmetric_memory>
    
    // Perform atomic set operation
    openshmem.atomic_set(%dest, %value, %pe) : memref<f64, #openshmem.symmetric_memory>, f64, i32
    
    openshmem.free(%dest) : memref<f64, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_f64_atomic_set()
// CHECK: llvm.call @shmem_{{.*}}atomic_set{{.*}}(

  // Test context-aware typed atomic set operations
  func.func @test_ctx_i32_atomic_set() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index
    %value = arith.constant 42 : i32
    
    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>
    
    // Perform context-aware atomic set operation
    openshmem.ctx_atomic_set(%ctx, %dest, %value, %pe) : !openshmem.ctx, memref<i32, #openshmem.symmetric_memory>, i32, i32
    
    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_i32_atomic_set()
// CHECK: llvm.call @shmem_{{.*}}ctx_atomic_set{{.*}}(

  func.func @test_ctx_i64_atomic_set() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index
    %value = arith.constant 42 : i64
    
    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i64, #openshmem.symmetric_memory>
    
    // Perform context-aware atomic set operation
    openshmem.ctx_atomic_set(%ctx, %dest, %value, %pe) : !openshmem.ctx, memref<i64, #openshmem.symmetric_memory>, i64, i32
    
    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    openshmem.free(%dest) : memref<i64, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_i64_atomic_set()
// CHECK: llvm.call @shmem_{{.*}}ctx_atomic_set{{.*}}(

  func.func @test_ctx_f32_atomic_set() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index
    %value = arith.constant 42.0 : f32
    
    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<f32, #openshmem.symmetric_memory>
    
    // Perform context-aware atomic set operation
    openshmem.ctx_atomic_set(%ctx, %dest, %value, %pe) : !openshmem.ctx, memref<f32, #openshmem.symmetric_memory>, f32, i32
    
    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    openshmem.free(%dest) : memref<f32, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_f32_atomic_set()
// CHECK: llvm.call @shmem_{{.*}}ctx_atomic_set{{.*}}(

  func.func @test_ctx_f64_atomic_set() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index
    %value = arith.constant 42.0 : f64
    
    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<f64, #openshmem.symmetric_memory>
    
    // Perform context-aware atomic set operation
    openshmem.ctx_atomic_set(%ctx, %dest, %value, %pe) : !openshmem.ctx, memref<f64, #openshmem.symmetric_memory>, f64, i32
    
    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    openshmem.free(%dest) : memref<f64, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_f64_atomic_set()
// CHECK: llvm.call @shmem_{{.*}}ctx_atomic_set{{.*}}(

  // Test generic typed atomic compare-and-swap operations
  func.func @test_i32_atomic_compare_swap() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index // 4 bytes for i32
    %cond = arith.constant 42 : i32
    %value = arith.constant 43 : i32
    
    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>
    
    // Perform atomic compare-and-swap operation
    %result = openshmem.atomic_compare_swap(%dest, %cond, %value, %pe) : memref<i32, #openshmem.symmetric_memory>, i32, i32, i32 -> i32
    
    openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_i32_atomic_compare_swap()
// CHECK: llvm.call @shmem_{{.*}}atomic_compare_swap{{.*}}(

  func.func @test_i64_atomic_compare_swap() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index // 8 bytes for i64
    %cond = arith.constant 42 : i64
    %value = arith.constant 43 : i64
    
    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i64, #openshmem.symmetric_memory>
    
    // Perform atomic compare-and-swap operation
    %result = openshmem.atomic_compare_swap(%dest, %cond, %value, %pe) : memref<i64, #openshmem.symmetric_memory>, i64, i64, i32 -> i64
    
    openshmem.free(%dest) : memref<i64, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_i64_atomic_compare_swap()
// CHECK: llvm.call @shmem_{{.*}}atomic_compare_swap{{.*}}(

  func.func @test_f32_atomic_compare_swap() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index // 4 bytes for f32
    %cond = arith.constant 42.0 : f32
    %value = arith.constant 43.0 : f32
    
    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<f32, #openshmem.symmetric_memory>
    
    // Perform atomic compare-and-swap operation
    %result = openshmem.atomic_compare_swap(%dest, %cond, %value, %pe) : memref<f32, #openshmem.symmetric_memory>, f32, f32, i32 -> f32
    
    openshmem.free(%dest) : memref<f32, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_f32_atomic_compare_swap()
// CHECK: llvm.call @shmem_{{.*}}atomic_compare_swap{{.*}}(

  func.func @test_f64_atomic_compare_swap() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index // 8 bytes for f64
    %cond = arith.constant 42.0 : f64
    %value = arith.constant 43.0 : f64
    
    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<f64, #openshmem.symmetric_memory>
    
    // Perform atomic compare-and-swap operation
    %result = openshmem.atomic_compare_swap(%dest, %cond, %value, %pe) : memref<f64, #openshmem.symmetric_memory>, f64, f64, i32 -> f64
    
    openshmem.free(%dest) : memref<f64, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_f64_atomic_compare_swap()
// CHECK: llvm.call @shmem_{{.*}}atomic_compare_swap{{.*}}(

  // Test context-aware typed atomic compare-and-swap operations
  func.func @test_ctx_i32_atomic_compare_swap() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index // 4 bytes for i32
    
    %cond = arith.constant 42 : i32
    %value = arith.constant 43 : i32
    
    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>
    
    // Perform context-aware atomic compare-and-swap operation
    %result = openshmem.ctx_atomic_compare_swap(%ctx, %dest, %cond, %value, %pe) : !openshmem.ctx, memref<i32, #openshmem.symmetric_memory>, i32, i32, i32 -> i32
    
    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_i32_atomic_compare_swap()
// CHECK: llvm.call @shmem_{{.*}}ctx_atomic_compare_swap{{.*}}(

  func.func @test_ctx_i64_atomic_compare_swap() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index // 8 bytes for i64
    
    %cond = arith.constant 42 : i64
    %value = arith.constant 43 : i64
    
    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i64, #openshmem.symmetric_memory>
    
    // Perform context-aware atomic compare-and-swap operation
    %result = openshmem.ctx_atomic_compare_swap(%ctx, %dest, %cond, %value, %pe) : !openshmem.ctx, memref<i64, #openshmem.symmetric_memory>, i64, i64, i32 -> i64
    
    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    openshmem.free(%dest) : memref<i64, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_i64_atomic_compare_swap()
// CHECK: llvm.call @shmem_{{.*}}ctx_atomic_compare_swap{{.*}}(

  func.func @test_ctx_f32_atomic_compare_swap() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index // 4 bytes for f32
    
    %cond = arith.constant 42.0 : f32
    %value = arith.constant 43.0 : f32
    
    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<f32, #openshmem.symmetric_memory>
    
    // Perform context-aware atomic compare-and-swap operation
    %result = openshmem.ctx_atomic_compare_swap(%ctx, %dest, %cond, %value, %pe) : !openshmem.ctx, memref<f32, #openshmem.symmetric_memory>, f32, f32, i32 -> f32
    
    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    openshmem.free(%dest) : memref<f32, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_f32_atomic_compare_swap()
// CHECK: llvm.call @shmem_{{.*}}ctx_atomic_compare_swap{{.*}}(

  func.func @test_ctx_f64_atomic_compare_swap() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index // 8 bytes for f64
    
    %cond = arith.constant 42.0 : f64
    %value = arith.constant 43.0 : f64
    
    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<f64, #openshmem.symmetric_memory>
    
    // Perform context-aware atomic compare-and-swap operation
    %result = openshmem.ctx_atomic_compare_swap(%ctx, %dest, %cond, %value, %pe) : !openshmem.ctx, memref<f64, #openshmem.symmetric_memory>, f64, f64, i32 -> f64
    
    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    openshmem.free(%dest) : memref<f64, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_f64_atomic_compare_swap()
// CHECK: llvm.call @shmem_{{.*}}ctx_atomic_compare_swap{{.*}}(

  // Test generic typed atomic swap operations
  func.func @test_i32_atomic_swap() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index // 4 bytes for i32
    %value = arith.constant 42 : i32

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>

    // Perform atomic swap operation
    %result = openshmem.atomic_swap(%dest, %value, %pe) : memref<i32, #openshmem.symmetric_memory>, i32, i32 -> i32


    openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_i32_atomic_swap()
// CHECK: llvm.call @shmem_{{.*}}atomic_swap{{.*}}(

  func.func @test_i64_atomic_swap() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index // 8 bytes for i64
    %value = arith.constant 42 : i64

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i64, #openshmem.symmetric_memory>

    // Perform atomic swap operation
    %result = openshmem.atomic_swap(%dest, %value, %pe) : memref<i64, #openshmem.symmetric_memory>, i64, i32 -> i64

    openshmem.free(%dest) : memref<i64, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_i64_atomic_swap()
// CHECK: llvm.call @shmem_{{.*}}atomic_swap{{.*}}(

  // Test context-aware typed atomic swap operations
  func.func @test_ctx_i32_atomic_swap() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index // 4 bytes for i32
    %value = arith.constant 42 : i32

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>

    // Perform context-aware atomic swap operation
    %result = openshmem.ctx_atomic_swap(%ctx, %dest, %value, %pe) : !openshmem.ctx, memref<i32, #openshmem.symmetric_memory>, i32, i32 -> i32

    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_i32_atomic_swap()
// CHECK: llvm.call @shmem_{{.*}}ctx_atomic_swap{{.*}}( 

  func.func @test_ctx_i64_atomic_swap() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index // 8 bytes for i64
    %value = arith.constant 42 : i64

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i64, #openshmem.symmetric_memory>

    // Perform context-aware atomic swap operation
    %result = openshmem.ctx_atomic_swap(%ctx, %dest, %value, %pe) : !openshmem.ctx, memref<i64, #openshmem.symmetric_memory>, i64, i32 -> i64

    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    openshmem.free(%dest) : memref<i64, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_i64_atomic_swap()
// CHECK: llvm.call @shmem_{{.*}}ctx_atomic_swap{{.*}}(

  // Test generic typed atomic swap operations
  func.func @test_f32_atomic_swap() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index // 4 bytes for f32
    %value = arith.constant 42.0 : f32

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<f32, #openshmem.symmetric_memory>

    // Perform atomic swap operation
    %result = openshmem.atomic_swap(%dest, %value, %pe) : memref<f32, #openshmem.symmetric_memory>, f32, i32 -> f32

    openshmem.free(%dest) : memref<f32, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_f32_atomic_swap()
// CHECK: llvm.call @shmem_{{.*}}atomic_swap{{.*}}(

  func.func @test_f64_atomic_swap() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index // 8 bytes for f64
    %value = arith.constant 42.0 : f64

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<f64, #openshmem.symmetric_memory>

    // Perform atomic swap operation
    %result = openshmem.atomic_swap(%dest, %value, %pe) : memref<f64, #openshmem.symmetric_memory>, f64, i32 -> f64

    openshmem.free(%dest) : memref<f64, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_f64_atomic_swap()
// CHECK: llvm.call @shmem_{{.*}}atomic_swap{{.*}}(

  // Test context-aware typed atomic swap operations
  func.func @test_ctx_f32_atomic_swap() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index // 4 bytes for f32
    %value = arith.constant 42.0 : f32

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<f32, #openshmem.symmetric_memory>

    // Perform context-aware atomic swap operation
    %result = openshmem.ctx_atomic_swap(%ctx, %dest, %value, %pe) : !openshmem.ctx, memref<f32, #openshmem.symmetric_memory>, f32, i32 -> f32

    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    openshmem.free(%dest) : memref<f32, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }

// CHECK-LABEL: llvm.func @test_ctx_f32_atomic_swap()
// CHECK: llvm.call @shmem_{{.*}}ctx_atomic_swap{{.*}}(

  func.func @test_ctx_f64_atomic_swap() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index // 8 bytes for f64
    %value = arith.constant 42.0 : f64

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<f64, #openshmem.symmetric_memory>

    // Perform context-aware atomic swap operation
    %result = openshmem.ctx_atomic_swap(%ctx, %dest, %value, %pe) : !openshmem.ctx, memref<f64, #openshmem.symmetric_memory>, f64, i32 -> f64

    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    openshmem.free(%dest) : memref<f64, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_f64_atomic_swap()
// CHECK: llvm.call @shmem_{{.*}}ctx_atomic_swap{{.*}}(

  // Test generic typed atomic fetch-and-increment operations
  func.func @test_i32_atomic_fetch_inc() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index // 4 bytes for i32
    %value = arith.constant 42 : i32

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>

    // Perform atomic fetch-and-increment operation
    %result = openshmem.atomic_fetch_inc(%dest, %pe) : memref<i32, #openshmem.symmetric_memory>, i32 -> i32

    openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_i32_atomic_fetch_inc()
// CHECK: llvm.call @shmem_{{.*}}atomic_fetch_inc{{.*}}(

  func.func @test_i64_atomic_fetch_inc() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index // 8 bytes for i64

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i64, #openshmem.symmetric_memory>

    // Perform atomic fetch-and-increment operation
    %result = openshmem.atomic_fetch_inc(%dest, %pe) : memref<i64, #openshmem.symmetric_memory>, i32 -> i64

    openshmem.free(%dest) : memref<i64, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_i64_atomic_fetch_inc()
// CHECK: llvm.call @shmem_{{.*}}atomic_fetch_inc{{.*}}(

  // Test context-aware typed atomic fetch-and-increment operations
  func.func @test_ctx_i32_atomic_fetch_inc() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index // 4 bytes for i32

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>

    // Perform context-aware atomic fetch-and-increment operation
    %result = openshmem.ctx_atomic_fetch_inc(%ctx, %dest, %pe) : !openshmem.ctx, memref<i32, #openshmem.symmetric_memory>, i32 -> i32

    openshmem.ctx_destroy(%ctx) : !openshmem.ctx

    openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_i32_atomic_fetch_inc()
// CHECK: llvm.call @shmem_{{.*}}ctx_atomic_fetch_inc{{.*}}(

  func.func @test_ctx_i64_atomic_fetch_inc() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index // 8 bytes for i64

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i64, #openshmem.symmetric_memory>

    // Perform context-aware atomic fetch-and-increment operation
    %result = openshmem.ctx_atomic_fetch_inc(%ctx, %dest, %pe) : !openshmem.ctx, memref<i64, #openshmem.symmetric_memory>, i32 -> i64

    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    openshmem.free(%dest) : memref<i64, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_i64_atomic_fetch_inc()
// CHECK: llvm.call @shmem_{{.*}}ctx_atomic_fetch_inc{{.*}}(

  // Test generic typed atomic increment operations
  func.func @test_i32_atomic_inc() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index // 4 bytes for i32
    %value = arith.constant 42 : i32

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>

    // Perform atomic increment operation
    openshmem.atomic_inc(%dest, %pe) : memref<i32, #openshmem.symmetric_memory>, i32

    openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_i32_atomic_inc()
// CHECK: llvm.call @shmem_{{.*}}atomic_inc{{.*}}(

  func.func @test_i64_atomic_inc() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index // 8 bytes for i64

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i64, #openshmem.symmetric_memory>

    // Perform atomic increment operation
    openshmem.atomic_inc(%dest, %pe) : memref<i64, #openshmem.symmetric_memory>, i32

    openshmem.free(%dest) : memref<i64, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }

// CHECK-LABEL: llvm.func @test_i64_atomic_inc()
// CHECK: llvm.call @shmem_{{.*}}atomic_inc{{.*}}(

  // Test context-aware typed atomic increment operations

  func.func @test_ctx_i32_atomic_inc() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index // 4 bytes for i32
    %value = arith.constant 42 : i32

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>

    // Perform context-aware atomic increment operation
    openshmem.ctx_atomic_inc(%ctx, %dest, %pe) : !openshmem.ctx, memref<i32, #openshmem.symmetric_memory>, i32

    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_i32_atomic_inc()
// CHECK: llvm.call @shmem_{{.*}}ctx_atomic_inc{{.*}}(

  func.func @test_ctx_i64_atomic_inc() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index // 8 bytes for i64

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i64, #openshmem.symmetric_memory>

    // Perform context-aware atomic increment operation
    openshmem.ctx_atomic_inc(%ctx, %dest, %pe) : !openshmem.ctx, memref<i64, #openshmem.symmetric_memory>, i32

    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    openshmem.free(%dest) : memref<i64, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_i64_atomic_inc()
// CHECK: llvm.call @shmem_{{.*}}ctx_atomic_inc{{.*}}(

  // Test generic typed atomic fetch-and-add operations
  func.func @test_i32_atomic_fetch_add() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index // 4 bytes for i32
    %value = arith.constant 5 : i32

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>

    // Perform atomic fetch-and-add operation
    %result = openshmem.atomic_fetch_add(%dest, %value, %pe) : memref<i32, #openshmem.symmetric_memory>, i32, i32 -> i32

    openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_i32_atomic_fetch_add()
// CHECK: llvm.call @shmem_{{.*}}atomic_fetch_add{{.*}}(

  func.func @test_i64_atomic_fetch_add() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index // 8 bytes for i64
    %value = arith.constant 5 : i64

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i64, #openshmem.symmetric_memory>

    // Perform atomic fetch-and-add operation
    %result = openshmem.atomic_fetch_add(%dest, %value, %pe) : memref<i64, #openshmem.symmetric_memory>, i64, i32 -> i64

    openshmem.free(%dest) : memref<i64, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_i64_atomic_fetch_add()
// CHECK: llvm.call @shmem_{{.*}}atomic_fetch_add{{.*}}(

  func.func @test_f32_atomic_fetch_add() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index // 4 bytes for f32
    %value = arith.constant 5.0 : f32

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<f32, #openshmem.symmetric_memory>

    // Perform atomic fetch-and-add operation
    %result = openshmem.atomic_fetch_add(%dest, %value, %pe) : memref<f32, #openshmem.symmetric_memory>, f32, i32 -> f32

    openshmem.free(%dest) : memref<f32, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_f32_atomic_fetch_add()
// CHECK: llvm.call @shmem_{{.*}}atomic_fetch_add{{.*}}(

  func.func @test_f64_atomic_fetch_add() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index // 8 bytes for f64
    %value = arith.constant 5.0 : f64

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<f64, #openshmem.symmetric_memory>

    // Perform atomic fetch-and-add operation
    %result = openshmem.atomic_fetch_add(%dest, %value, %pe) : memref<f64, #openshmem.symmetric_memory>, f64, i32 -> f64

    openshmem.free(%dest) : memref<f64, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_f64_atomic_fetch_add()
// CHECK: llvm.call @shmem_{{.*}}atomic_fetch_add{{.*}}(

  // Test context-aware typed atomic fetch-and-add operations
  func.func @test_ctx_i32_atomic_fetch_add() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index // 4 bytes for i32
    %value = arith.constant 5 : i32

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>

    // Perform context-aware atomic fetch-and-add operation
    %result = openshmem.ctx_atomic_fetch_add(%ctx, %dest, %value, %pe) : !openshmem.ctx, memref<i32, #openshmem.symmetric_memory>, i32, i32 -> i32

    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_i32_atomic_fetch_add()
// CHECK: llvm.call @shmem_{{.*}}ctx_atomic_fetch_add{{.*}}(

  func.func @test_ctx_i64_atomic_fetch_add() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index // 8 bytes for i64
    %value = arith.constant 5 : i64

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i64, #openshmem.symmetric_memory>

    // Perform context-aware atomic fetch-and-add operation
    %result = openshmem.ctx_atomic_fetch_add(%ctx, %dest, %value, %pe) : !openshmem.ctx, memref<i64, #openshmem.symmetric_memory>, i64, i32 -> i64

    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    openshmem.free(%dest) : memref<i64, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_i64_atomic_fetch_add()
// CHECK: llvm.call @shmem_{{.*}}ctx_atomic_fetch_add{{.*}}(

  // Test generic typed atomic add operations
  func.func @test_i32_atomic_add() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index // 4 bytes for i32
    %value = arith.constant 5 : i32

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>

    // Perform atomic add operation
    openshmem.atomic_add(%dest, %value, %pe) : memref<i32, #openshmem.symmetric_memory>, i32, i32

    openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_i32_atomic_add()
// CHECK: llvm.call @shmem_{{.*}}atomic_add{{.*}}(

  func.func @test_i64_atomic_add() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index // 8 bytes for i64
    %value = arith.constant 5 : i64

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i64, #openshmem.symmetric_memory>

    // Perform atomic add operation
    openshmem.atomic_add(%dest, %value, %pe) : memref<i64, #openshmem.symmetric_memory>, i64, i32

    openshmem.free(%dest) : memref<i64, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_i64_atomic_add()
// CHECK: llvm.call @shmem_{{.*}}atomic_add{{.*}}(

  // Test context-aware typed atomic add operations
  func.func @test_ctx_i32_atomic_add() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index // 4 bytes for i32
    %value = arith.constant 5 : i32

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>

    // Perform context-aware atomic add operation
    openshmem.ctx_atomic_add(%ctx, %dest, %value, %pe) : !openshmem.ctx, memref<i32, #openshmem.symmetric_memory>, i32, i32

    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_i32_atomic_add()
// CHECK: llvm.call @shmem_{{.*}}ctx_atomic_add{{.*}}(

  func.func @test_ctx_i64_atomic_add() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index // 8 bytes for i64
    %value = arith.constant 5 : i64

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i64, #openshmem.symmetric_memory>

    // Perform context-aware atomic add operation
    openshmem.ctx_atomic_add(%ctx, %dest, %value, %pe) : !openshmem.ctx, memref<i64, #openshmem.symmetric_memory>, i64, i32

    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    openshmem.free(%dest) : memref<i64, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_i64_atomic_add()
// CHECK: llvm.call @shmem_{{.*}}ctx_atomic_add{{.*}}(

  // Test generic typed atomic fetch-and operations
  func.func @test_i32_atomic_fetch_and() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index // 4 bytes for i32
    %value = arith.constant 255 : i32

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>

    // Perform atomic fetch-and operation
    %result = openshmem.atomic_fetch_and(%dest, %value, %pe) : memref<i32, #openshmem.symmetric_memory>, i32, i32 -> i32

    openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_i32_atomic_fetch_and()
// CHECK: llvm.call @shmem_{{.*}}atomic_fetch_and{{.*}}(

  func.func @test_i64_atomic_fetch_and() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index // 8 bytes for i64
    %value = arith.constant 255 : i64

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i64, #openshmem.symmetric_memory>

    // Perform atomic fetch-and operation
    %result = openshmem.atomic_fetch_and(%dest, %value, %pe) : memref<i64, #openshmem.symmetric_memory>, i64, i32 -> i64

    openshmem.free(%dest) : memref<i64, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_i64_atomic_fetch_and()
// CHECK: llvm.call @shmem_{{.*}}atomic_fetch_and{{.*}}(

  // Test context-aware typed atomic fetch-and operations
  func.func @test_ctx_i32_atomic_fetch_and() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index // 4 bytes for i32
    %value = arith.constant 255 : i32

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>

    // Perform context-aware atomic fetch-and operation
    %result = openshmem.ctx_atomic_fetch_and(%ctx, %dest, %value, %pe) : !openshmem.ctx, memref<i32, #openshmem.symmetric_memory>, i32, i32 -> i32

    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_i32_atomic_fetch_and()
// CHECK: llvm.call @shmem_{{.*}}ctx_atomic_fetch_and{{.*}}(

  func.func @test_ctx_i64_atomic_fetch_and() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index // 8 bytes for i64
    %value = arith.constant 255 : i64

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i64, #openshmem.symmetric_memory>

    // Perform context-aware atomic fetch-and operation
    %result = openshmem.ctx_atomic_fetch_and(%ctx, %dest, %value, %pe) : !openshmem.ctx, memref<i64, #openshmem.symmetric_memory>, i64, i32 -> i64

    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    openshmem.free(%dest) : memref<i64, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_i64_atomic_fetch_and()
// CHECK: llvm.call @shmem_{{.*}}ctx_atomic_fetch_and{{.*}}(

  // Test generic typed atomic fetch-or operations
  func.func @test_i32_atomic_fetch_or() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index // 4 bytes for i32
    %value = arith.constant 128 : i32

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>

    // Perform atomic fetch-or operation
    %result = openshmem.atomic_fetch_or(%dest, %value, %pe) : memref<i32, #openshmem.symmetric_memory>, i32, i32 -> i32

    openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_i32_atomic_fetch_or()
// CHECK: llvm.call @shmem_{{.*}}atomic_fetch_or{{.*}}(

  func.func @test_i64_atomic_fetch_or() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index // 8 bytes for i64
    %value = arith.constant 128 : i64

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i64, #openshmem.symmetric_memory>

    // Perform atomic fetch-or operation
    %result = openshmem.atomic_fetch_or(%dest, %value, %pe) : memref<i64, #openshmem.symmetric_memory>, i64, i32 -> i64

    openshmem.free(%dest) : memref<i64, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_i64_atomic_fetch_or()
// CHECK: llvm.call @shmem_{{.*}}atomic_fetch_or{{.*}}(

  // Test context-aware typed atomic fetch-or operations
  func.func @test_ctx_i32_atomic_fetch_or() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index // 4 bytes for i32
    %value = arith.constant 128 : i32

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>

    // Perform context-aware atomic fetch-or operation
    %result = openshmem.ctx_atomic_fetch_or(%ctx, %dest, %value, %pe) : !openshmem.ctx, memref<i32, #openshmem.symmetric_memory>, i32, i32 -> i32

    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_i32_atomic_fetch_or()
// CHECK: llvm.call @shmem_{{.*}}ctx_atomic_fetch_or{{.*}}(

  func.func @test_ctx_i64_atomic_fetch_or() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index // 8 bytes for i64
    %value = arith.constant 128 : i64

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i64, #openshmem.symmetric_memory>

    // Perform context-aware atomic fetch-or operation
    %result = openshmem.ctx_atomic_fetch_or(%ctx, %dest, %value, %pe) : !openshmem.ctx, memref<i64, #openshmem.symmetric_memory>, i64, i32 -> i64

    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    openshmem.free(%dest) : memref<i64, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_i64_atomic_fetch_or()
// CHECK: llvm.call @shmem_{{.*}}ctx_atomic_fetch_or{{.*}}(

  // Test generic typed atomic or operations
  func.func @test_i32_atomic_or() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index // 4 bytes for i32
    %value = arith.constant 128 : i32

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>

    // Perform atomic or operation
    openshmem.atomic_or(%dest, %value, %pe) : memref<i32, #openshmem.symmetric_memory>, i32, i32

    openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_i32_atomic_or()
// CHECK: llvm.call @shmem_{{.*}}atomic_or{{.*}}(

  func.func @test_i64_atomic_or() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index // 8 bytes for i64
    %value = arith.constant 128 : i64

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i64, #openshmem.symmetric_memory>

    // Perform atomic or operation
    openshmem.atomic_or(%dest, %value, %pe) : memref<i64, #openshmem.symmetric_memory>, i64, i32

    openshmem.free(%dest) : memref<i64, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_i64_atomic_or()
// CHECK: llvm.call @shmem_{{.*}}atomic_or{{.*}}(

  // Test context-aware typed atomic or operations
  func.func @test_ctx_i32_atomic_or() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index // 4 bytes for i32
    %value = arith.constant 128 : i32

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>

    // Perform context-aware atomic or operation
    openshmem.ctx_atomic_or(%ctx, %dest, %value, %pe) : !openshmem.ctx, memref<i32, #openshmem.symmetric_memory>, i32, i32

    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_i32_atomic_or()
// CHECK: llvm.call @shmem_{{.*}}ctx_atomic_or{{.*}}(

  func.func @test_ctx_i64_atomic_or() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index // 8 bytes for i64
    %value = arith.constant 128 : i64

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i64, #openshmem.symmetric_memory>

    // Perform context-aware atomic or operation
    openshmem.ctx_atomic_or(%ctx, %dest, %value, %pe) : !openshmem.ctx, memref<i64, #openshmem.symmetric_memory>, i64, i32

    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    openshmem.free(%dest) : memref<i64, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_i64_atomic_or()
// CHECK: llvm.call @shmem_{{.*}}ctx_atomic_or{{.*}}(

  // Test generic typed atomic fetch-xor operations
  func.func @test_i32_atomic_fetch_xor() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index // 4 bytes for i32
    %value = arith.constant 85 : i32

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>

    // Perform atomic fetch-xor operation
    %result = openshmem.atomic_fetch_xor(%dest, %value, %pe) : memref<i32, #openshmem.symmetric_memory>, i32, i32 -> i32

    openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_i32_atomic_fetch_xor()
// CHECK: llvm.call @shmem_{{.*}}atomic_fetch_xor{{.*}}(

  func.func @test_i64_atomic_fetch_xor() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index // 8 bytes for i64
    %value = arith.constant 85 : i64

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i64, #openshmem.symmetric_memory>

    // Perform atomic fetch-xor operation
    %result = openshmem.atomic_fetch_xor(%dest, %value, %pe) : memref<i64, #openshmem.symmetric_memory>, i64, i32 -> i64

    openshmem.free(%dest) : memref<i64, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_i64_atomic_fetch_xor()
// CHECK: llvm.call @shmem_{{.*}}atomic_fetch_xor{{.*}}(

  // Test context-aware typed atomic fetch-xor operations
  func.func @test_ctx_i32_atomic_fetch_xor() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index // 4 bytes for i32
    %value = arith.constant 85 : i32

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>

    // Perform context-aware atomic fetch-xor operation
    %result = openshmem.ctx_atomic_fetch_xor(%ctx, %dest, %value, %pe) : !openshmem.ctx, memref<i32, #openshmem.symmetric_memory>, i32, i32 -> i32

    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_i32_atomic_fetch_xor()
// CHECK: llvm.call @shmem_{{.*}}ctx_atomic_fetch_xor{{.*}}(

  func.func @test_ctx_i64_atomic_fetch_xor() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index // 8 bytes for i64
    %value = arith.constant 85 : i64

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i64, #openshmem.symmetric_memory>

    // Perform context-aware atomic fetch-xor operation
    %result = openshmem.ctx_atomic_fetch_xor(%ctx, %dest, %value, %pe) : !openshmem.ctx, memref<i64, #openshmem.symmetric_memory>, i64, i32 -> i64

    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    openshmem.free(%dest) : memref<i64, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_i64_atomic_fetch_xor()
// CHECK: llvm.call @shmem_{{.*}}ctx_atomic_fetch_xor{{.*}}(

  // Test generic typed atomic xor operations
  func.func @test_i32_atomic_xor() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index // 4 bytes for i32
    %value = arith.constant 85 : i32

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>

    // Perform atomic xor operation
    openshmem.atomic_xor(%dest, %value, %pe) : memref<i32, #openshmem.symmetric_memory>, i32, i32

    openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_i32_atomic_xor()
// CHECK: llvm.call @shmem_{{.*}}atomic_xor{{.*}}(

  func.func @test_i64_atomic_xor() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index // 8 bytes for i64
    %value = arith.constant 85 : i64

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i64, #openshmem.symmetric_memory>

    // Perform atomic xor operation
    openshmem.atomic_xor(%dest, %value, %pe) : memref<i64, #openshmem.symmetric_memory>, i64, i32

    openshmem.free(%dest) : memref<i64, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_i64_atomic_xor()
// CHECK: llvm.call @shmem_{{.*}}atomic_xor{{.*}}(

  // Test context-aware typed atomic xor operations
  func.func @test_ctx_i32_atomic_xor() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index // 4 bytes for i32
    %value = arith.constant 85 : i32

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>

    // Perform context-aware atomic xor operation
    openshmem.ctx_atomic_xor(%ctx, %dest, %value, %pe) : !openshmem.ctx, memref<i32, #openshmem.symmetric_memory>, i32, i32

    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_i32_atomic_xor()
// CHECK: llvm.call @shmem_{{.*}}ctx_atomic_xor{{.*}}(

  func.func @test_ctx_i64_atomic_xor() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index // 8 bytes for i64
    %value = arith.constant 85 : i64

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i64, #openshmem.symmetric_memory>

    // Perform context-aware atomic xor operation
    openshmem.ctx_atomic_xor(%ctx, %dest, %value, %pe) : !openshmem.ctx, memref<i64, #openshmem.symmetric_memory>, i64, i32

    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    openshmem.free(%dest) : memref<i64, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_i64_atomic_xor()
// CHECK: llvm.call @shmem_{{.*}}ctx_atomic_xor{{.*}}(

  // Test non-blocking atomic fetch operations
  func.func @test_i32_atomic_fetch_nbi() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index // 4 bytes for i32

    // Allocate symmetric memory for source
    %src = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>
    // Allocate local memory for fetch buffer
    %fetch = memref.alloc() : memref<i32>

    // Perform atomic fetch nbi operation
    openshmem.atomic_fetch_nbi(%fetch, %src, %pe) : memref<i32>, memref<i32, #openshmem.symmetric_memory>, i32

    memref.dealloc %fetch : memref<i32>
    openshmem.free(%src) : memref<i32, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_i32_atomic_fetch_nbi()
// CHECK: llvm.call @shmem_{{.*}}atomic_fetch_nbi{{.*}}(

  func.func @test_i64_atomic_fetch_nbi() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index // 8 bytes for i64

    // Allocate symmetric memory for source
    %src = openshmem.malloc(%size) : index -> memref<i64, #openshmem.symmetric_memory>
    // Allocate local memory for fetch buffer
    %fetch = memref.alloc() : memref<i64>

    // Perform atomic fetch nbi operation
    openshmem.atomic_fetch_nbi(%fetch, %src, %pe) : memref<i64>, memref<i64, #openshmem.symmetric_memory>, i32

    memref.dealloc %fetch : memref<i64>
    openshmem.free(%src) : memref<i64, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_i64_atomic_fetch_nbi()
// CHECK: llvm.call @shmem_{{.*}}atomic_fetch_nbi{{.*}}(

  // Test context-aware non-blocking atomic fetch operations
  func.func @test_ctx_i32_atomic_fetch_nbi() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index // 4 bytes for i32

    // Allocate symmetric memory for source
    %src = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>
    // Allocate local memory for fetch buffer
    %fetch = memref.alloc() : memref<i32>

    // Perform context-aware atomic fetch nbi operation
    openshmem.ctx_atomic_fetch_nbi(%ctx, %fetch, %src, %pe) : !openshmem.ctx, memref<i32>, memref<i32, #openshmem.symmetric_memory>, i32

    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    memref.dealloc %fetch : memref<i32>
    openshmem.free(%src) : memref<i32, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_i32_atomic_fetch_nbi()
// CHECK: llvm.call @shmem_{{.*}}ctx_atomic_fetch_nbi{{.*}}(

  func.func @test_ctx_i64_atomic_fetch_nbi() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index // 8 bytes for i64

    // Allocate symmetric memory for source
    %src = openshmem.malloc(%size) : index -> memref<i64, #openshmem.symmetric_memory>
    // Allocate local memory for fetch buffer
    %fetch = memref.alloc() : memref<i64>

    // Perform context-aware atomic fetch nbi operation
    openshmem.ctx_atomic_fetch_nbi(%ctx, %fetch, %src, %pe) : !openshmem.ctx, memref<i64>, memref<i64, #openshmem.symmetric_memory>, i32

    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    memref.dealloc %fetch : memref<i64>
    openshmem.free(%src) : memref<i64, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_i64_atomic_fetch_nbi()
// CHECK: llvm.call @shmem_{{.*}}ctx_atomic_fetch_nbi{{.*}}(

  // Test non-blocking atomic compare-and-swap operations
  func.func @test_i32_atomic_compare_swap_nbi() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index // 4 bytes for i32
    %cond = arith.constant 42 : i32
    %value = arith.constant 43 : i32

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>
    // Allocate local memory for fetch buffer
    %fetch = memref.alloc() : memref<i32>

    // Perform atomic compare-and-swap nbi operation
    openshmem.atomic_compare_swap_nbi(%fetch, %dest, %cond, %value, %pe) : memref<i32>, memref<i32, #openshmem.symmetric_memory>, i32, i32, i32

    memref.dealloc %fetch : memref<i32>
    openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_i32_atomic_compare_swap_nbi()
// CHECK: llvm.call @shmem_{{.*}}atomic_compare_swap_nbi{{.*}}(

  func.func @test_i64_atomic_compare_swap_nbi() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index // 8 bytes for i64
    %cond = arith.constant 42 : i64
    %value = arith.constant 43 : i64

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i64, #openshmem.symmetric_memory>
    // Allocate local memory for fetch buffer
    %fetch = memref.alloc() : memref<i64>

    // Perform atomic compare-and-swap nbi operation
    openshmem.atomic_compare_swap_nbi(%fetch, %dest, %cond, %value, %pe) : memref<i64>, memref<i64, #openshmem.symmetric_memory>, i64, i64, i32

    memref.dealloc %fetch : memref<i64>
    openshmem.free(%dest) : memref<i64, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_i64_atomic_compare_swap_nbi()
// CHECK: llvm.call @shmem_{{.*}}atomic_compare_swap_nbi{{.*}}(

  // Test context-aware non-blocking atomic compare-and-swap operations
  func.func @test_ctx_i32_atomic_compare_swap_nbi() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index // 4 bytes for i32
    %cond = arith.constant 42 : i32
    %value = arith.constant 43 : i32

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>
    // Allocate local memory for fetch buffer
    %fetch = memref.alloc() : memref<i32>

    // Perform context-aware atomic compare-and-swap nbi operation
    openshmem.ctx_atomic_compare_swap_nbi(%ctx, %fetch, %dest, %cond, %value, %pe) : !openshmem.ctx, memref<i32>, memref<i32, #openshmem.symmetric_memory>, i32, i32, i32

    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    memref.dealloc %fetch : memref<i32>
    openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_i32_atomic_compare_swap_nbi()
// CHECK: llvm.call @shmem_{{.*}}ctx_atomic_compare_swap_nbi{{.*}}(

  func.func @test_ctx_i64_atomic_compare_swap_nbi() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index // 8 bytes for i64
    %cond = arith.constant 42 : i64
    %value = arith.constant 43 : i64

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i64, #openshmem.symmetric_memory>
    // Allocate local memory for fetch buffer
    %fetch = memref.alloc() : memref<i64>

    // Perform context-aware atomic compare-and-swap nbi operation
    openshmem.ctx_atomic_compare_swap_nbi(%ctx, %fetch, %dest, %cond, %value, %pe) : !openshmem.ctx, memref<i64>, memref<i64, #openshmem.symmetric_memory>, i64, i64, i32

    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    memref.dealloc %fetch : memref<i64>
    openshmem.free(%dest) : memref<i64, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_i64_atomic_compare_swap_nbi()
// CHECK: llvm.call @shmem_{{.*}}ctx_atomic_compare_swap_nbi{{.*}}(

  // Test non-blocking atomic swap operations
  func.func @test_i32_atomic_swap_nbi() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index // 4 bytes for i32
    %value = arith.constant 42 : i32

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>
    // Allocate local memory for fetch buffer
    %fetch = memref.alloc() : memref<i32>

    // Perform atomic swap nbi operation
    openshmem.atomic_swap_nbi(%fetch, %dest, %value, %pe) : memref<i32>, memref<i32, #openshmem.symmetric_memory>, i32, i32

    memref.dealloc %fetch : memref<i32>
    openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_i32_atomic_swap_nbi()
// CHECK: llvm.call @shmem_{{.*}}atomic_swap_nbi{{.*}}(

  func.func @test_i64_atomic_swap_nbi() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index // 8 bytes for i64
    %value = arith.constant 42 : i64

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i64, #openshmem.symmetric_memory>
    // Allocate local memory for fetch buffer
    %fetch = memref.alloc() : memref<i64>

    // Perform atomic swap nbi operation
    openshmem.atomic_swap_nbi(%fetch, %dest, %value, %pe) : memref<i64>, memref<i64, #openshmem.symmetric_memory>, i64, i32

    memref.dealloc %fetch : memref<i64>
    openshmem.free(%dest) : memref<i64, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_i64_atomic_swap_nbi()
// CHECK: llvm.call @shmem_{{.*}}atomic_swap_nbi{{.*}}(

  // Test context-aware non-blocking atomic swap operations
  func.func @test_ctx_i32_atomic_swap_nbi() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index // 4 bytes for i32
    %value = arith.constant 42 : i32

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>
    // Allocate local memory for fetch buffer
    %fetch = memref.alloc() : memref<i32>

    // Perform context-aware atomic swap nbi operation
    openshmem.ctx_atomic_swap_nbi(%ctx, %fetch, %dest, %value, %pe) : !openshmem.ctx, memref<i32>, memref<i32, #openshmem.symmetric_memory>, i32, i32

    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    memref.dealloc %fetch : memref<i32>
    openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_i32_atomic_swap_nbi()
// CHECK: llvm.call @shmem_{{.*}}ctx_atomic_swap_nbi{{.*}}(

  func.func @test_ctx_i64_atomic_swap_nbi() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index // 8 bytes for i64
    %value = arith.constant 42 : i64

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i64, #openshmem.symmetric_memory>
    // Allocate local memory for fetch buffer
    %fetch = memref.alloc() : memref<i64>

    // Perform context-aware atomic swap nbi operation
    openshmem.ctx_atomic_swap_nbi(%ctx, %fetch, %dest, %value, %pe) : !openshmem.ctx, memref<i64>, memref<i64, #openshmem.symmetric_memory>, i64, i32

    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    memref.dealloc %fetch : memref<i64>
    openshmem.free(%dest) : memref<i64, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_i64_atomic_swap_nbi()
// CHECK: llvm.call @shmem_{{.*}}ctx_atomic_swap_nbi{{.*}}(

  // Test non-blocking atomic fetch-and-increment operations
  func.func @test_i32_atomic_fetch_inc_nbi() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index // 4 bytes for i32

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>
    // Allocate local memory for fetch buffer
    %fetch = memref.alloc() : memref<i32>

    // Perform atomic fetch-and-increment nbi operation
    openshmem.atomic_fetch_inc_nbi(%fetch, %dest, %pe) : memref<i32>, memref<i32, #openshmem.symmetric_memory>, i32

    memref.dealloc %fetch : memref<i32>
    openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_i32_atomic_fetch_inc_nbi()
// CHECK: llvm.call @shmem_{{.*}}atomic_fetch_inc_nbi{{.*}}(

  func.func @test_i64_atomic_fetch_inc_nbi() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index // 8 bytes for i64

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i64, #openshmem.symmetric_memory>
    // Allocate local memory for fetch buffer
    %fetch = memref.alloc() : memref<i64>

    // Perform atomic fetch-and-increment nbi operation
    openshmem.atomic_fetch_inc_nbi(%fetch, %dest, %pe) : memref<i64>, memref<i64, #openshmem.symmetric_memory>, i32

    memref.dealloc %fetch : memref<i64>
    openshmem.free(%dest) : memref<i64, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_i64_atomic_fetch_inc_nbi()
// CHECK: llvm.call @shmem_{{.*}}atomic_fetch_inc_nbi{{.*}}(

  // Test context-aware non-blocking atomic fetch-and-increment operations
  func.func @test_ctx_i32_atomic_fetch_inc_nbi() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index // 4 bytes for i32

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>
    // Allocate local memory for fetch buffer
    %fetch = memref.alloc() : memref<i32>

    // Perform context-aware atomic fetch-and-increment nbi operation
    openshmem.ctx_atomic_fetch_inc_nbi(%ctx, %fetch, %dest, %pe) : !openshmem.ctx, memref<i32>, memref<i32, #openshmem.symmetric_memory>, i32

    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    memref.dealloc %fetch : memref<i32>
    openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_i32_atomic_fetch_inc_nbi()
// CHECK: llvm.call @shmem_{{.*}}ctx_atomic_fetch_inc_nbi{{.*}}(

  func.func @test_ctx_i64_atomic_fetch_inc_nbi() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index // 8 bytes for i64

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i64, #openshmem.symmetric_memory>
    // Allocate local memory for fetch buffer
    %fetch = memref.alloc() : memref<i64>

    // Perform context-aware atomic fetch-and-increment nbi operation
    openshmem.ctx_atomic_fetch_inc_nbi(%ctx, %fetch, %dest, %pe) : !openshmem.ctx, memref<i64>, memref<i64, #openshmem.symmetric_memory>, i32

    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    memref.dealloc %fetch : memref<i64>
    openshmem.free(%dest) : memref<i64, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_i64_atomic_fetch_inc_nbi()
// CHECK: llvm.call @shmem_{{.*}}ctx_atomic_fetch_inc_nbi{{.*}}(

  // Test non-blocking atomic fetch-and-add operations
  func.func @test_i32_atomic_fetch_add_nbi() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index // 4 bytes for i32
    %value = arith.constant 5 : i32

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>
    // Allocate local memory for fetch buffer
    %fetch = memref.alloc() : memref<i32>

    // Perform atomic fetch-and-add nbi operation
    openshmem.atomic_fetch_add_nbi(%fetch, %dest, %value, %pe) : memref<i32>, memref<i32, #openshmem.symmetric_memory>, i32, i32

    memref.dealloc %fetch : memref<i32>
    openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_i32_atomic_fetch_add_nbi()
// CHECK: llvm.call @shmem_{{.*}}atomic_fetch_add_nbi{{.*}}(

  func.func @test_i64_atomic_fetch_add_nbi() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index // 8 bytes for i64
    %value = arith.constant 5 : i64

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i64, #openshmem.symmetric_memory>
    // Allocate local memory for fetch buffer
    %fetch = memref.alloc() : memref<i64>

    // Perform atomic fetch-and-add nbi operation
    openshmem.atomic_fetch_add_nbi(%fetch, %dest, %value, %pe) : memref<i64>, memref<i64, #openshmem.symmetric_memory>, i64, i32

    memref.dealloc %fetch : memref<i64>
    openshmem.free(%dest) : memref<i64, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_i64_atomic_fetch_add_nbi()
// CHECK: llvm.call @shmem_{{.*}}atomic_fetch_add_nbi{{.*}}(

  // Test context-aware non-blocking atomic fetch-and-add operations
  func.func @test_ctx_i32_atomic_fetch_add_nbi() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index // 4 bytes for i32
    %value = arith.constant 5 : i32

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>
    // Allocate local memory for fetch buffer
    %fetch = memref.alloc() : memref<i32>

    // Perform context-aware atomic fetch-and-add nbi operation
    openshmem.ctx_atomic_fetch_add_nbi(%ctx, %fetch, %dest, %value, %pe) : !openshmem.ctx, memref<i32>, memref<i32, #openshmem.symmetric_memory>, i32, i32

    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    memref.dealloc %fetch : memref<i32>
    openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_i32_atomic_fetch_add_nbi()
// CHECK: llvm.call @shmem_{{.*}}ctx_atomic_fetch_add_nbi{{.*}}(

  func.func @test_ctx_i64_atomic_fetch_add_nbi() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index // 8 bytes for i64
    %value = arith.constant 5 : i64

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i64, #openshmem.symmetric_memory>
    // Allocate local memory for fetch buffer
    %fetch = memref.alloc() : memref<i64>

    // Perform context-aware atomic fetch-and-add nbi operation
    openshmem.ctx_atomic_fetch_add_nbi(%ctx, %fetch, %dest, %value, %pe) : !openshmem.ctx, memref<i64>, memref<i64, #openshmem.symmetric_memory>, i64, i32

    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    memref.dealloc %fetch : memref<i64>
    openshmem.free(%dest) : memref<i64, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_i64_atomic_fetch_add_nbi()
// CHECK: llvm.call @shmem_{{.*}}ctx_atomic_fetch_add_nbi{{.*}}(

  // Test non-blocking atomic fetch-and operations
  func.func @test_i32_atomic_fetch_and_nbi() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index // 4 bytes for i32
    %value = arith.constant 255 : i32

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>
    // Allocate local memory for fetch buffer
    %fetch = memref.alloc() : memref<i32>

    // Perform atomic fetch-and nbi operation
    openshmem.atomic_fetch_and_nbi(%fetch, %dest, %value, %pe) : memref<i32>, memref<i32, #openshmem.symmetric_memory>, i32, i32

    memref.dealloc %fetch : memref<i32>
    openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_i32_atomic_fetch_and_nbi()
// CHECK: llvm.call @shmem_{{.*}}atomic_fetch_and_nbi{{.*}}(

  func.func @test_i64_atomic_fetch_and_nbi() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index // 8 bytes for i64
    %value = arith.constant 255 : i64

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i64, #openshmem.symmetric_memory>
    // Allocate local memory for fetch buffer
    %fetch = memref.alloc() : memref<i64>

    // Perform atomic fetch-and nbi operation
    openshmem.atomic_fetch_and_nbi(%fetch, %dest, %value, %pe) : memref<i64>, memref<i64, #openshmem.symmetric_memory>, i64, i32

    memref.dealloc %fetch : memref<i64>
    openshmem.free(%dest) : memref<i64, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_i64_atomic_fetch_and_nbi()
// CHECK: llvm.call @shmem_{{.*}}atomic_fetch_and_nbi{{.*}}(

  // Test context-aware non-blocking atomic fetch-and operations
  func.func @test_ctx_i32_atomic_fetch_and_nbi() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index // 4 bytes for i32
    %value = arith.constant 255 : i32

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>
    // Allocate local memory for fetch buffer
    %fetch = memref.alloc() : memref<i32>

    // Perform context-aware atomic fetch-and nbi operation
    openshmem.ctx_atomic_fetch_and_nbi(%ctx, %fetch, %dest, %value, %pe) : !openshmem.ctx, memref<i32>, memref<i32, #openshmem.symmetric_memory>, i32, i32

    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    memref.dealloc %fetch : memref<i32>
    openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_i32_atomic_fetch_and_nbi()
// CHECK: llvm.call @shmem_{{.*}}ctx_atomic_fetch_and_nbi{{.*}}(

  func.func @test_ctx_i64_atomic_fetch_and_nbi() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index // 8 bytes for i64
    %value = arith.constant 255 : i64

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i64, #openshmem.symmetric_memory>
    // Allocate local memory for fetch buffer
    %fetch = memref.alloc() : memref<i64>

    // Perform context-aware atomic fetch-and nbi operation
    openshmem.ctx_atomic_fetch_and_nbi(%ctx, %fetch, %dest, %value, %pe) : !openshmem.ctx, memref<i64>, memref<i64, #openshmem.symmetric_memory>, i64, i32

    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    memref.dealloc %fetch : memref<i64>
    openshmem.free(%dest) : memref<i64, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_i64_atomic_fetch_and_nbi()
// CHECK: llvm.call @shmem_{{.*}}ctx_atomic_fetch_and_nbi{{.*}}(

  // Test non-blocking atomic fetch-or operations
  func.func @test_i32_atomic_fetch_or_nbi() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index // 4 bytes for i32
    %value = arith.constant 128 : i32

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>
    // Allocate local memory for fetch buffer
    %fetch = memref.alloc() : memref<i32>

    // Perform atomic fetch-or nbi operation
    openshmem.atomic_fetch_or_nbi(%fetch, %dest, %value, %pe) : memref<i32>, memref<i32, #openshmem.symmetric_memory>, i32, i32

    memref.dealloc %fetch : memref<i32>
    openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_i32_atomic_fetch_or_nbi()
// CHECK: llvm.call @shmem_{{.*}}atomic_fetch_or_nbi{{.*}}(

  func.func @test_i64_atomic_fetch_or_nbi() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index // 8 bytes for i64
    %value = arith.constant 128 : i64

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i64, #openshmem.symmetric_memory>
    // Allocate local memory for fetch buffer
    %fetch = memref.alloc() : memref<i64>

    // Perform atomic fetch-or nbi operation
    openshmem.atomic_fetch_or_nbi(%fetch, %dest, %value, %pe) : memref<i64>, memref<i64, #openshmem.symmetric_memory>, i64, i32

    memref.dealloc %fetch : memref<i64>
    openshmem.free(%dest) : memref<i64, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_i64_atomic_fetch_or_nbi()
// CHECK: llvm.call @shmem_{{.*}}atomic_fetch_or_nbi{{.*}}(

  // Test context-aware non-blocking atomic fetch-or operations
  func.func @test_ctx_i32_atomic_fetch_or_nbi() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index // 4 bytes for i32
    %value = arith.constant 128 : i32

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>
    // Allocate local memory for fetch buffer
    %fetch = memref.alloc() : memref<i32>

    // Perform context-aware atomic fetch-or nbi operation
    openshmem.ctx_atomic_fetch_or_nbi(%ctx, %fetch, %dest, %value, %pe) : !openshmem.ctx, memref<i32>, memref<i32, #openshmem.symmetric_memory>, i32, i32

    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    memref.dealloc %fetch : memref<i32>
    openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_i32_atomic_fetch_or_nbi()
// CHECK: llvm.call @shmem_{{.*}}ctx_atomic_fetch_or_nbi{{.*}}(

  func.func @test_ctx_i64_atomic_fetch_or_nbi() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index // 8 bytes for i64
    %value = arith.constant 128 : i64

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i64, #openshmem.symmetric_memory>
    // Allocate local memory for fetch buffer
    %fetch = memref.alloc() : memref<i64>

    // Perform context-aware atomic fetch-or nbi operation
    openshmem.ctx_atomic_fetch_or_nbi(%ctx, %fetch, %dest, %value, %pe) : !openshmem.ctx, memref<i64>, memref<i64, #openshmem.symmetric_memory>, i64, i32

    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    memref.dealloc %fetch : memref<i64>
    openshmem.free(%dest) : memref<i64, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_i64_atomic_fetch_or_nbi()
// CHECK: llvm.call @shmem_{{.*}}ctx_atomic_fetch_or_nbi{{.*}}(

  // Test non-blocking atomic fetch-xor operations
  func.func @test_i32_atomic_fetch_xor_nbi() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index // 4 bytes for i32
    %value = arith.constant 85 : i32

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>
    // Allocate local memory for fetch buffer
    %fetch = memref.alloc() : memref<i32>

    // Perform atomic fetch-xor nbi operation
    openshmem.atomic_fetch_xor_nbi(%fetch, %dest, %value, %pe) : memref<i32>, memref<i32, #openshmem.symmetric_memory>, i32, i32

    memref.dealloc %fetch : memref<i32>
    openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_i32_atomic_fetch_xor_nbi()
// CHECK: llvm.call @shmem_{{.*}}atomic_fetch_xor_nbi{{.*}}(

  func.func @test_i64_atomic_fetch_xor_nbi() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index // 8 bytes for i64
    %value = arith.constant 85 : i64

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i64, #openshmem.symmetric_memory>
    // Allocate local memory for fetch buffer
    %fetch = memref.alloc() : memref<i64>

    // Perform atomic fetch-xor nbi operation
    openshmem.atomic_fetch_xor_nbi(%fetch, %dest, %value, %pe) : memref<i64>, memref<i64, #openshmem.symmetric_memory>, i64, i32

    memref.dealloc %fetch : memref<i64>
    openshmem.free(%dest) : memref<i64, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_i64_atomic_fetch_xor_nbi()
// CHECK: llvm.call @shmem_{{.*}}atomic_fetch_xor_nbi{{.*}}(

  // Test context-aware non-blocking atomic fetch-xor operations
  func.func @test_ctx_i32_atomic_fetch_xor_nbi() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index // 4 bytes for i32
    %value = arith.constant 85 : i32

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>
    // Allocate local memory for fetch buffer
    %fetch = memref.alloc() : memref<i32>

    // Perform context-aware atomic fetch-xor nbi operation
    openshmem.ctx_atomic_fetch_xor_nbi(%ctx, %fetch, %dest, %value, %pe) : !openshmem.ctx, memref<i32>, memref<i32, #openshmem.symmetric_memory>, i32, i32

    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    memref.dealloc %fetch : memref<i32>
    openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_i32_atomic_fetch_xor_nbi()
// CHECK: llvm.call @shmem_{{.*}}ctx_atomic_fetch_xor_nbi{{.*}}(

  func.func @test_ctx_i64_atomic_fetch_xor_nbi() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index // 8 bytes for i64
    %value = arith.constant 85 : i64

    // Allocate symmetric memory for destination
    %dest = openshmem.malloc(%size) : index -> memref<i64, #openshmem.symmetric_memory>
    // Allocate local memory for fetch buffer
    %fetch = memref.alloc() : memref<i64>

    // Perform context-aware atomic fetch-xor nbi operation
    openshmem.ctx_atomic_fetch_xor_nbi(%ctx, %fetch, %dest, %value, %pe) : !openshmem.ctx, memref<i64>, memref<i64, #openshmem.symmetric_memory>, i64, i32

    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    memref.dealloc %fetch : memref<i64>
    openshmem.free(%dest) : memref<i64, #openshmem.symmetric_memory>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_i64_atomic_fetch_xor_nbi()
// CHECK: llvm.call @shmem_{{.*}}ctx_atomic_fetch_xor_nbi{{.*}}(

}
