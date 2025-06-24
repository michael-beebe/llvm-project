// RUN: mlir-opt %s -convert-openshmem-to-llvm | FileCheck %s

// Test basic OpenSHMEM operations conversion to LLVM

func.func @test_openshmem_basic() {
  // CHECK-LABEL: @test_openshmem_basic

  // Test init operation
  // CHECK: llvm.call @shmem_init() : () -> ()
  openshmem.init

  // Test PE operations  
  // CHECK: llvm.call @shmem_my_pe() : () -> i32
  %1 = openshmem.my_pe : i32
  
  // CHECK: llvm.call @shmem_n_pes() : () -> i32
  %2 = openshmem.n_pes : i32

  // Test finalize operation
  // CHECK: llvm.call @shmem_finalize() : () -> ()
  openshmem.finalize

  return
}

func.func @test_openshmem_memory(%size: index) {
  // CHECK-LABEL: @test_openshmem_memory
  
  // Test malloc operation
  // CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i{{32|64}}) -> !llvm.ptr
  %ptr = openshmem.malloc(%size) : index -> !openshmem.symmetric_memref<i32>
  
  // Test free operation  
  // CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
  openshmem.free(%ptr) : !openshmem.symmetric_memref<i32>
  
  return
}

func.func @test_openshmem_communication(%arg0: !openshmem.symmetric_memref<i32>, %arg1: memref<10xi32>, %size: index, %pe: i32) {
  // CHECK-LABEL: @test_openshmem_communication
  
  // Test putmem operation
  // CHECK: llvm.call @shmem_putmem(%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, !llvm.ptr, i{{32|64}}, i32) -> ()
  openshmem.putmem(%arg0, %arg1, %size, %pe) : !openshmem.symmetric_memref<i32>, memref<10xi32>, index, i32
  
  // Test getmem operation
  // CHECK: llvm.call @shmem_getmem(%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, !llvm.ptr, i{{32|64}}, i32) -> ()
  openshmem.getmem(%arg1, %arg0, %size, %pe) : memref<10xi32>, !openshmem.symmetric_memref<i32>, index, i32
      
  return
}
