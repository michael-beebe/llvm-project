// RUN: mlir-opt %s --convert-openshmem-to-llvm --convert-func-to-llvm --reconcile-unrealized-casts | mlir-translate --mlir-to-llvmir | FileCheck %s

// Test OpenSHMEM atomic operations

module {
  // Test generic typed atomic fetch operations
  func.func @test_i32_atomic_fetch() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index // 4 bytes for i32
    
    // Allocate symmetric memory for source
    %src = openshmem.malloc(%size) : index -> !openshmem.symmetric_memref<i32>
    
    // Perform atomic fetch operation
    %result = openshmem.atomic_fetch(%src, %pe) : !openshmem.symmetric_memref<i32>, i32 -> i32
    
    openshmem.free(%src) : !openshmem.symmetric_memref<i32>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_i32_atomic_fetch()
// CHECK: llvm.call @shmem_atomic_fetch32(

  func.func @test_i64_atomic_fetch() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index // 8 bytes for i64
    
    // Allocate symmetric memory for source
    %src = openshmem.malloc(%size) : index -> !openshmem.symmetric_memref<i64>
    
    // Perform atomic fetch operation
    %result = openshmem.atomic_fetch(%src, %pe) : !openshmem.symmetric_memref<i64>, i32 -> i64
    
    openshmem.free(%src) : !openshmem.symmetric_memref<i64>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_i64_atomic_fetch()
// CHECK: llvm.call @shmem_atomic_fetch64(

  func.func @test_f32_atomic_fetch() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index // 4 bytes for f32
    
    // Allocate symmetric memory for source
    %src = openshmem.malloc(%size) : index -> !openshmem.symmetric_memref<f32>
    
    // Perform atomic fetch operation
    %result = openshmem.atomic_fetch(%src, %pe) : !openshmem.symmetric_memref<f32>, i32 -> f32
    
    openshmem.free(%src) : !openshmem.symmetric_memref<f32>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_f32_atomic_fetch()
// CHECK: llvm.call @shmem_atomic_fetch32(

  func.func @test_f64_atomic_fetch() {
    openshmem.init
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index // 8 bytes for f64
    
    // Allocate symmetric memory for source
    %src = openshmem.malloc(%size) : index -> !openshmem.symmetric_memref<f64>
    
    // Perform atomic fetch operation
    %result = openshmem.atomic_fetch(%src, %pe) : !openshmem.symmetric_memref<f64>, i32 -> f64
    
    openshmem.free(%src) : !openshmem.symmetric_memref<f64>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_f64_atomic_fetch()
// CHECK: llvm.call @shmem_atomic_fetch64(

  // Test context-aware typed atomic fetch operations
  func.func @test_ctx_i32_atomic_fetch() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index
    
    // Allocate symmetric memory for source
    %src = openshmem.malloc(%size) : index -> !openshmem.symmetric_memref<i32>
    
    // Perform context-aware atomic fetch operation
    %result = openshmem.ctx_atomic_fetch(%ctx, %src, %pe) : !openshmem.ctx, !openshmem.symmetric_memref<i32>, i32 -> i32
    
    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    openshmem.free(%src) : !openshmem.symmetric_memref<i32>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_i32_atomic_fetch()
// CHECK: llvm.call @shmem_ctx_atomic_fetch32(

  func.func @test_ctx_i64_atomic_fetch() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index
    
    // Allocate symmetric memory for source
    %src = openshmem.malloc(%size) : index -> !openshmem.symmetric_memref<i64>
    
    // Perform context-aware atomic fetch operation
    %result = openshmem.ctx_atomic_fetch(%ctx, %src, %pe) : !openshmem.ctx, !openshmem.symmetric_memref<i64>, i32 -> i64
    
    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    openshmem.free(%src) : !openshmem.symmetric_memref<i64>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_i64_atomic_fetch()
// CHECK: llvm.call @shmem_ctx_atomic_fetch64(

  func.func @test_ctx_f32_atomic_fetch() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 4 : index
    
    // Allocate symmetric memory for source
    %src = openshmem.malloc(%size) : index -> !openshmem.symmetric_memref<f32>
    
    // Perform context-aware atomic fetch operation
    %result = openshmem.ctx_atomic_fetch(%ctx, %src, %pe) : !openshmem.ctx, !openshmem.symmetric_memref<f32>, i32 -> f32
    
    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    openshmem.free(%src) : !openshmem.symmetric_memref<f32>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_f32_atomic_fetch()
// CHECK: llvm.call @shmem_ctx_atomic_fetch32(

  func.func @test_ctx_f64_atomic_fetch() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %pe = arith.constant 1 : i32
    %size = arith.constant 8 : index
    
    // Allocate symmetric memory for source
    %src = openshmem.malloc(%size) : index -> !openshmem.symmetric_memref<f64>
    
    // Perform context-aware atomic fetch operation
    %result = openshmem.ctx_atomic_fetch(%ctx, %src, %pe) : !openshmem.ctx, !openshmem.symmetric_memref<f64>, i32 -> f64
    
    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    openshmem.free(%src) : !openshmem.symmetric_memref<f64>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_f64_atomic_fetch()
// CHECK: llvm.call @shmem_ctx_atomic_fetch64(

}
