// RUN: mlir-opt %s --convert-openshmem-to-llvm --convert-func-to-llvm --reconcile-unrealized-casts | mlir-translate --mlir-to-llvmir | FileCheck %s

// Test OpenSHMEM RMA operations

module {
  func.func @test_putmem() {
    // Initialize OpenSHMEM
    openshmem.init

    // Set SHMEM_TEAM_WORLD to a team handle (not needed for putmem)
    %nelems = arith.constant 10 : index // 10 elements
    %size = arith.constant 40 : index // 10 elements * 4 bytes each = 40 bytes
    %pe = arith.constant 1 : i32 // Target PE

    // Allocate symmetric memory for dest
    %dest = openshmem.malloc(%size) : index -> !openshmem.symmetric_memref<i32>
    // Allocate local memory for src
    %src = memref.alloc() : memref<10xi32>

    // Perform putmem operation
    openshmem.putmem(%dest, %src, %size, %pe) : !openshmem.symmetric_memref<i32>, memref<10xi32>, index, i32

    // Free symmetric memory
    openshmem.free(%dest) : !openshmem.symmetric_memref<i32>

    // Finalize OpenSHMEM
    openshmem.finalize
    return
  }

// CHECK-LABEL: llvm.func @test_putmem()
// CHECK: llvm.call @shmem_putmem(

  func.func @test_getmem() {
    openshmem.init
    %nelems = arith.constant 10 : index
    %size = arith.constant 40 : index
    %pe = arith.constant 1 : i32
    // Allocate local memory for dest
    %dest = memref.alloc() : memref<10xi32>
    // Allocate symmetric memory for src
    %src = openshmem.malloc(%size) : index -> !openshmem.symmetric_memref<i32>
    // Perform getmem operation
    openshmem.getmem(%dest, %src, %size, %pe) : memref<10xi32>, !openshmem.symmetric_memref<i32>, index, i32
    openshmem.free(%src) : !openshmem.symmetric_memref<i32>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_getmem()
// CHECK: llvm.call @shmem_getmem(

  func.func @test_putmem_nbi() {
    openshmem.init
    %nelems = arith.constant 10 : index
    %size = arith.constant 40 : index
    %pe = arith.constant 1 : i32
    %dest = openshmem.malloc(%size) : index -> !openshmem.symmetric_memref<i32>
    %src = memref.alloc() : memref<10xi32>
    openshmem.putmem_nbi(%dest, %src, %size, %pe) : !openshmem.symmetric_memref<i32>, memref<10xi32>, index, i32
    openshmem.quiet
    openshmem.free(%dest) : !openshmem.symmetric_memref<i32>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_putmem_nbi()
// CHECK: llvm.call @shmem_putmem_nbi(

  func.func @test_getmem_nbi() {
    openshmem.init
    %nelems = arith.constant 10 : index
    %size = arith.constant 40 : index
    %pe = arith.constant 1 : i32
    %dest = memref.alloc() : memref<10xi32>
    %src = openshmem.malloc(%size) : index -> !openshmem.symmetric_memref<i32>
    openshmem.getmem_nbi(%dest, %src, %size, %pe) : memref<10xi32>, !openshmem.symmetric_memref<i32>, index, i32
    openshmem.quiet
    openshmem.free(%src) : !openshmem.symmetric_memref<i32>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_getmem_nbi()
// CHECK: llvm.call @shmem_getmem_nbi(

  // Test generic typed put operations
  func.func @test_i32_put() {
    openshmem.init
    %nelems = arith.constant 10 : index
    %pe = arith.constant 1 : i32
    %size = arith.constant 40 : index // 10 * 4 bytes
    
    // Allocate symmetric memory for dest (i32 type)
    %dest = openshmem.malloc(%size) : index -> !openshmem.symmetric_memref<i32>
    // Allocate local memory for src
    %src = memref.alloc() : memref<10xi32>
    
    // Perform typed put operation
    openshmem.put(%dest, %src, %nelems, %pe) : !openshmem.symmetric_memref<i32>, memref<10xi32>, index, i32
    
    openshmem.free(%dest) : !openshmem.symmetric_memref<i32>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_i32_put()
// CHECK: llvm.call @shmem_put32(

  // Test generic typed put operations
  func.func @test_i64_put() {
    openshmem.init
    %nelems = arith.constant 10 : index
    %pe = arith.constant 1 : i32
    %size = arith.constant 80 : index // 10 * 8 bytes
    
    // Allocate symmetric memory for dest (i64 type)
    %dest = openshmem.malloc(%size) : index -> !openshmem.symmetric_memref<i64>
    // Allocate local memory for src
    %src = memref.alloc() : memref<10xi64>
    
    // Perform typed put operation
    openshmem.put(%dest, %src, %nelems, %pe) : !openshmem.symmetric_memref<i64>, memref<10xi64>, index, i32
    
    openshmem.free(%dest) : !openshmem.symmetric_memref<i64>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_i64_put()
// CHECK: llvm.call @shmem_put64(

  func.func @test_f32_put() {
    openshmem.init
    %nelems = arith.constant 10 : index
    %pe = arith.constant 1 : i32
    %size = arith.constant 40 : index // 10 * 4 bytes
    
    // Allocate symmetric memory for dest (f32 type)
    %dest = openshmem.malloc(%size) : index -> !openshmem.symmetric_memref<f32>
    // Allocate local memory for src
    %src = memref.alloc() : memref<10xf32>
    
    // Perform typed put operation
    openshmem.put(%dest, %src, %nelems, %pe) : !openshmem.symmetric_memref<f32>, memref<10xf32>, index, i32
    
    openshmem.free(%dest) : !openshmem.symmetric_memref<f32>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_f32_put()
// CHECK: llvm.call @shmem_put32(

  // Test non-blocking typed put operations
  func.func @test_put_nbi_typed() {
    openshmem.init
    %nelems = arith.constant 10 : index
    %pe = arith.constant 1 : i32
    %size = arith.constant 40 : index
    
    // Allocate symmetric memory for dest (f32 type)
    %dest = openshmem.malloc(%size) : index -> !openshmem.symmetric_memref<f32>
    // Allocate local memory for src
    %src = memref.alloc() : memref<10xf32>
    
    // Perform non-blocking typed put operation
    openshmem.put_nbi(%dest, %src, %nelems, %pe) : !openshmem.symmetric_memref<f32>, memref<10xf32>, index, i32
    
    openshmem.quiet
    openshmem.free(%dest) : !openshmem.symmetric_memref<f32>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_put_nbi_typed()
// CHECK: llvm.call @shmem_put_nbi32(

  // Test sized put operations
  func.func @test_put8_sized() {
    openshmem.init
    %nelems = arith.constant 10 : index
    %pe = arith.constant 1 : i32
    %size = arith.constant 10 : index // 10 bytes for put8
    
    // Allocate symmetric memory for dest (i8 type)
    %dest = openshmem.malloc(%size) : index -> !openshmem.symmetric_memref<i8>
    // Allocate local memory for src
    %src = memref.alloc() : memref<10xi8>
    
    // Perform sized put operations
    openshmem.put8(%dest, %src, %nelems, %pe) : !openshmem.symmetric_memref<i8>, memref<10xi8>, index, i32
    
    openshmem.free(%dest) : !openshmem.symmetric_memref<i8>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_put8_sized()
// CHECK: llvm.call @shmem_put8(

  func.func @test_put16_sized() {
    openshmem.init
    %nelems = arith.constant 10 : index
    %pe = arith.constant 1 : i32
    %size = arith.constant 20 : index // 10 * 2 bytes
    
    %dest = openshmem.malloc(%size) : index -> !openshmem.symmetric_memref<i16>
    %src = memref.alloc() : memref<10xi16>
    
    openshmem.put16(%dest, %src, %nelems, %pe) : !openshmem.symmetric_memref<i16>, memref<10xi16>, index, i32
    
    openshmem.free(%dest) : !openshmem.symmetric_memref<i16>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_put16_sized()
// CHECK: llvm.call @shmem_put16(

  func.func @test_put32_sized() {
    openshmem.init
    %nelems = arith.constant 10 : index
    %pe = arith.constant 1 : i32
    %size = arith.constant 40 : index // 10 * 4 bytes
    
    %dest = openshmem.malloc(%size) : index -> !openshmem.symmetric_memref<i32>
    %src = memref.alloc() : memref<10xi32>
    
    openshmem.put32(%dest, %src, %nelems, %pe) : !openshmem.symmetric_memref<i32>, memref<10xi32>, index, i32
    
    openshmem.free(%dest) : !openshmem.symmetric_memref<i32>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_put32_sized()
// CHECK: llvm.call @shmem_put32(

  func.func @test_put64_sized() {
    openshmem.init
    %nelems = arith.constant 10 : index
    %pe = arith.constant 1 : i32
    %size = arith.constant 80 : index // 10 * 8 bytes
    
    %dest = openshmem.malloc(%size) : index -> !openshmem.symmetric_memref<i64>
    %src = memref.alloc() : memref<10xi64>
    
    openshmem.put64(%dest, %src, %nelems, %pe) : !openshmem.symmetric_memref<i64>, memref<10xi64>, index, i32
    
    openshmem.free(%dest) : !openshmem.symmetric_memref<i64>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_put64_sized()
// CHECK: llvm.call @shmem_put64(

  func.func @test_put128_sized() {
    openshmem.init
    %nelems = arith.constant 10 : index
    %pe = arith.constant 1 : i32
    %size = arith.constant 160 : index // 10 * 16 bytes
    
    %dest = openshmem.malloc(%size) : index -> !openshmem.symmetric_memref<f128>
    %src = memref.alloc() : memref<10xf128>
    
    openshmem.put128(%dest, %src, %nelems, %pe) : !openshmem.symmetric_memref<f128>, memref<10xf128>, index, i32
    
    openshmem.free(%dest) : !openshmem.symmetric_memref<f128>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_put128_sized()
// CHECK: llvm.call @shmem_put128(

  func.func @test_ctx_put() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %nelems = arith.constant 10 : index
    %pe = arith.constant 1 : i32
    %size = arith.constant 40 : index
    %dest = openshmem.malloc(%size) : index -> !openshmem.symmetric_memref<i32>
    %src = memref.alloc() : memref<10xi32>
    openshmem.ctx_put(%ctx, %dest, %src, %nelems, %pe) : !openshmem.ctx, !openshmem.symmetric_memref<i32>, memref<10xi32>, index, i32
    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_put()
// CHECK: llvm.call @shmem_ctx_put32(

  // Test generic typed get operations
  func.func @test_i32_get() {
    openshmem.init
    %nelems = arith.constant 10 : index
    %pe = arith.constant 1 : i32
    %size = arith.constant 40 : index // 10 * 4 bytes
    // Allocate local memory for dest (i32 type)
    %dest = memref.alloc() : memref<10xi32>
    // Allocate symmetric memory for src
    %src = openshmem.malloc(%size) : index -> !openshmem.symmetric_memref<i32>
    // Perform typed get operation
    openshmem.get(%dest, %src, %nelems, %pe) : memref<10xi32>, !openshmem.symmetric_memref<i32>, index, i32
    openshmem.free(%src) : !openshmem.symmetric_memref<i32>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_i32_get()
// CHECK: llvm.call @shmem_get32(

  // Test context-aware typed get operations
  func.func @test_ctx_get() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %nelems = arith.constant 10 : index
    %pe = arith.constant 1 : i32
    %size = arith.constant 40 : index
    %dest = memref.alloc() : memref<10xi32>
    %src = openshmem.malloc(%size) : index -> !openshmem.symmetric_memref<i32>
    openshmem.ctx_get(%ctx, %dest, %src, %nelems, %pe) : !openshmem.ctx, memref<10xi32>, !openshmem.symmetric_memref<i32>, index, i32
    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_get()
// CHECK: llvm.call @shmem_ctx_get32(

  // Test non-blocking typed get operations
  func.func @test_get_nbi_typed() {
    openshmem.init
    %nelems = arith.constant 10 : index
    %pe = arith.constant 1 : i32
    %size = arith.constant 40 : index
    %dest = memref.alloc() : memref<10xi32>
    %src = openshmem.malloc(%size) : index -> !openshmem.symmetric_memref<i32>
    openshmem.get_nbi(%dest, %src, %nelems, %pe) : memref<10xi32>, !openshmem.symmetric_memref<i32>, index, i32
    openshmem.quiet
    openshmem.free(%src) : !openshmem.symmetric_memref<i32>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_get_nbi_typed()
// CHECK: llvm.call @shmem_get_nbi32(

  // Test context-aware non-blocking typed get operations
  func.func @test_ctx_get_nbi() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %nelems = arith.constant 10 : index
    %pe = arith.constant 1 : i32
    %size = arith.constant 40 : index
    %dest = memref.alloc() : memref<10xi32>
    %src = openshmem.malloc(%size) : index -> !openshmem.symmetric_memref<i32>
    openshmem.ctx_get_nbi(%ctx, %dest, %src, %nelems, %pe) : !openshmem.ctx, memref<10xi32>, !openshmem.symmetric_memref<i32>, index, i32
    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_get_nbi()
// CHECK: llvm.call @shmem_ctx_get_nbi32(

  // Test sized get operations
  func.func @test_get8_sized() {
    openshmem.init
    %nelems = arith.constant 10 : index
    %pe = arith.constant 1 : i32
    %size = arith.constant 10 : index // 10 bytes for get8
    %dest = memref.alloc() : memref<10xi8>
    %src = openshmem.malloc(%size) : index -> !openshmem.symmetric_memref<i8>
    openshmem.get8(%dest, %src, %nelems, %pe) : memref<10xi8>, !openshmem.symmetric_memref<i8>, index, i32
    openshmem.free(%src) : !openshmem.symmetric_memref<i8>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_get8_sized()
// CHECK: llvm.call @shmem_get8(

  func.func @test_get16_sized() {
    openshmem.init
    %nelems = arith.constant 10 : index
    %pe = arith.constant 1 : i32
    %size = arith.constant 20 : index // 10 * 2 bytes
    %dest = memref.alloc() : memref<10xi16>
    %src = openshmem.malloc(%size) : index -> !openshmem.symmetric_memref<i16>
    openshmem.get16(%dest, %src, %nelems, %pe) : memref<10xi16>, !openshmem.symmetric_memref<i16>, index, i32
    openshmem.free(%src) : !openshmem.symmetric_memref<i16>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_get16_sized()
// CHECK: llvm.call @shmem_get16(

  func.func @test_get32_sized() {
    openshmem.init
    %nelems = arith.constant 10 : index
    %pe = arith.constant 1 : i32
    %size = arith.constant 40 : index // 10 * 4 bytes
    %dest = memref.alloc() : memref<10xi32>
    %src = openshmem.malloc(%size) : index -> !openshmem.symmetric_memref<i32>
    openshmem.get32(%dest, %src, %nelems, %pe) : memref<10xi32>, !openshmem.symmetric_memref<i32>, index, i32
    openshmem.free(%src) : !openshmem.symmetric_memref<i32>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_get32_sized()
// CHECK: llvm.call @shmem_get32(

  func.func @test_get64_sized() {
    openshmem.init
    %nelems = arith.constant 10 : index
    %pe = arith.constant 1 : i32
    %size = arith.constant 80 : index // 10 * 8 bytes
    %dest = memref.alloc() : memref<10xi64>
    %src = openshmem.malloc(%size) : index -> !openshmem.symmetric_memref<i64>
    openshmem.get64(%dest, %src, %nelems, %pe) : memref<10xi64>, !openshmem.symmetric_memref<i64>, index, i32
    openshmem.free(%src) : !openshmem.symmetric_memref<i64>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_get64_sized()
// CHECK: llvm.call @shmem_get64(

  func.func @test_get128_sized() {
    openshmem.init
    %nelems = arith.constant 10 : index
    %pe = arith.constant 1 : i32
    %size = arith.constant 160 : index // 10 * 16 bytes
    %dest = memref.alloc() : memref<10xf128>
    %src = openshmem.malloc(%size) : index -> !openshmem.symmetric_memref<f128>
    openshmem.get128(%dest, %src, %nelems, %pe) : memref<10xf128>, !openshmem.symmetric_memref<f128>, index, i32
    openshmem.free(%src) : !openshmem.symmetric_memref<f128>
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_get128_sized()
// CHECK: llvm.call @shmem_get128(

  // Test context-aware sized get operations
  func.func @test_ctx_get8_sized() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %nelems = arith.constant 10 : index
    %pe = arith.constant 1 : i32
    %size = arith.constant 10 : index
    %dest = memref.alloc() : memref<10xi8>
    %src = openshmem.malloc(%size) : index -> !openshmem.symmetric_memref<i8>
    openshmem.ctx_get8(%ctx, %dest, %src, %nelems, %pe) : !openshmem.ctx, memref<10xi8>, !openshmem.symmetric_memref<i8>, index, i32
    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_get8_sized()
// CHECK: llvm.call @shmem_ctx_get8(

  func.func @test_ctx_get16_sized() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %nelems = arith.constant 10 : index
    %pe = arith.constant 1 : i32
    %size = arith.constant 20 : index
    %dest = memref.alloc() : memref<10xi16>
    %src = openshmem.malloc(%size) : index -> !openshmem.symmetric_memref<i16>
    openshmem.ctx_get16(%ctx, %dest, %src, %nelems, %pe) : !openshmem.ctx, memref<10xi16>, !openshmem.symmetric_memref<i16>, index, i32
    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_get16_sized()
// CHECK: llvm.call @shmem_ctx_get16(

  func.func @test_ctx_get32_sized() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %nelems = arith.constant 10 : index
    %pe = arith.constant 1 : i32
    %size = arith.constant 40 : index
    %dest = memref.alloc() : memref<10xi32>
    %src = openshmem.malloc(%size) : index -> !openshmem.symmetric_memref<i32>
    openshmem.ctx_get32(%ctx, %dest, %src, %nelems, %pe) : !openshmem.ctx, memref<10xi32>, !openshmem.symmetric_memref<i32>, index, i32
    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_get32_sized()
// CHECK: llvm.call @shmem_ctx_get32(

  func.func @test_ctx_get64_sized() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %nelems = arith.constant 10 : index
    %pe = arith.constant 1 : i32
    %size = arith.constant 80 : index
    %dest = memref.alloc() : memref<10xi64>
    %src = openshmem.malloc(%size) : index -> !openshmem.symmetric_memref<i64>
    openshmem.ctx_get64(%ctx, %dest, %src, %nelems, %pe) : !openshmem.ctx, memref<10xi64>, !openshmem.symmetric_memref<i64>, index, i32
    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_get64_sized()
// CHECK: llvm.call @shmem_ctx_get64(

  func.func @test_ctx_get128_sized() {
    openshmem.init
    %opts = arith.constant 0 : i64
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32
    %nelems = arith.constant 10 : index
    %pe = arith.constant 1 : i32
    %size = arith.constant 160 : index
    %dest = memref.alloc() : memref<10xf128>
    %src = openshmem.malloc(%size) : index -> !openshmem.symmetric_memref<f128>
    openshmem.ctx_get128(%ctx, %dest, %src, %nelems, %pe) : !openshmem.ctx, memref<10xf128>, !openshmem.symmetric_memref<f128>, index, i32
    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    openshmem.finalize
    return
  }
// CHECK-LABEL: llvm.func @test_ctx_get128_sized()
// CHECK: llvm.call @shmem_ctx_get128(

}
