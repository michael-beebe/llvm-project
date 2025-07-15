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

}
