// RUN: mlir-opt %s --convert-openshmem-to-llvm --convert-func-to-llvm --reconcile-unrealized-casts | mlir-translate --mlir-to-llvmir | FileCheck %s

// Test OpenSHMEM region-based operations

module {
  func.func @test_region_based() {
    openshmem.region {
      %pe = openshmem.my_pe : i32
      %n_pes = openshmem.n_pes : i32
    }
    func.return
  }
  // CHECK-LABEL: llvm.func @test_region_based()
  // CHECK: llvm.call @shmem_init() : () -> ()
  // CHECK: llvm.call @shmem_my_pe() : () -> i32
  // CHECK: llvm.call @shmem_n_pes() : () -> i32
  // CHECK: llvm.call @shmem_finalize() : () -> ()
  // CHECK: llvm.return

  func.func @test_region_with_memory() {
    openshmem.region {
      %size = arith.constant 4 : index
      %src = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>
      openshmem.free(%src) : memref<i32, #openshmem.symmetric_memory>
    }
    func.return
  }
  // CHECK-LABEL: llvm.func @test_region_with_memory()
  // CHECK: llvm.call @shmem_init() : () -> ()
  // CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
  // CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
  // CHECK: llvm.call @shmem_finalize() : () -> ()
  // CHECK: llvm.return

  func.func @test_region_with_atomics() {
    openshmem.region {
      %pe = arith.constant 1 : i32
      %size = arith.constant 4 : index
      %src = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>
      %result = openshmem.atomic_fetch(%src, %pe) : memref<i32, #openshmem.symmetric_memory>, i32 -> i32
      openshmem.free(%src) : memref<i32, #openshmem.symmetric_memory>
    }
    func.return
  }
  // CHECK-LABEL: llvm.func @test_region_with_atomics()
  // CHECK: llvm.call @shmem_init() : () -> ()
  // CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
  // CHECK: llvm.call @shmem_{{.*}}atomic_fetch{{.*}}(
  // CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
  // CHECK: llvm.call @shmem_finalize() : () -> ()
  // CHECK: llvm.return
}
