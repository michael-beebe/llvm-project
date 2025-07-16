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
// CHECK: llvm.call @shmem_init() : () -> ()
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_putmem(%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_finalize() : () -> ()
// CHECK: llvm.return

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
// CHECK: llvm.call @shmem_init() : () -> ()
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_getmem(%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_finalize() : () -> ()
// CHECK: llvm.return

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
// CHECK: llvm.call @shmem_init() : () -> ()
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_putmem_nbi(%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
// CHECK: llvm.call @shmem_quiet
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_finalize() : () -> ()
// CHECK: llvm.return

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
// CHECK: llvm.call @shmem_init() : () -> ()
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_getmem_nbi(%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
// CHECK: llvm.call @shmem_quiet
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_finalize() : () -> ()
// CHECK: llvm.return

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
// CHECK: llvm.call @shmem_init() : () -> ()
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_put32(%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_finalize() : () -> ()
// CHECK: llvm.return

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
// CHECK: llvm.call @shmem_init() : () -> ()
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_put64(%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_finalize() : () -> ()
// CHECK: llvm.return

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
// CHECK: llvm.call @shmem_init() : () -> ()
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_put32(%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_finalize() : () -> ()
// CHECK: llvm.return

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
// CHECK: llvm.call @shmem_init() : () -> ()
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_put_nbi32(%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
// CHECK: llvm.call @shmem_quiet() : () -> ()
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_finalize() : () -> ()
// CHECK: llvm.return



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
// CHECK: llvm.call @shmem_init() : () -> ()
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_put8(%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_finalize() : () -> ()
// CHECK: llvm.return

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
// CHECK: llvm.call @shmem_init() : () -> ()
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_put16(%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_finalize() : () -> ()
// CHECK: llvm.return

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
// CHECK: llvm.call @shmem_init() : () -> ()
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_put32(%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_finalize() : () -> ()
// CHECK: llvm.return

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
// CHECK: llvm.call @shmem_init() : () -> ()
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_put64(%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_finalize() : () -> ()
// CHECK: llvm.return

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
// CHECK: llvm.call @shmem_init() : () -> ()
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_put128(%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_finalize() : () -> ()
// CHECK: llvm.return

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
// CHECK: llvm.call @shmem_init() : () -> ()
// CHECK: llvm.mlir.constant(0 : i64) : i64
// CHECK: llvm.mlir.constant(1 : i32) : i32
// CHECK: llvm.alloca %{{.*}} x !llvm.ptr : (i32) -> !llvm.ptr
// CHECK: llvm.call @shmem_ctx_create(%{{.*}}, %{{.*}}) : (i64, !llvm.ptr) -> i32
// CHECK: llvm.load %{{.*}} : !llvm.ptr -> !llvm.ptr
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_ctx_put32(%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, i64, i32) -> ()
// CHECK: llvm.call @shmem_ctx_destroy(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_finalize() : () -> ()
// CHECK: llvm.return

}
