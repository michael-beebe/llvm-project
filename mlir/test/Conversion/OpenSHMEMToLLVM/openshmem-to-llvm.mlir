// RUN: mlir-opt %s -convert-openshmem-to-llvm | FileCheck %s

// Test basic OpenSHMEM operations conversion to LLVM

func.func @test_openshmem_basic() {
  // CHECK-LABEL: @test_openshmem_basic

  // Test init operation
  // CHECK: llvm.call @shmem_init() : () -> i32
  %0 = openshmem.init : !openshmem.retval

  // Test PE operations  
  // CHECK: llvm.call @shmem_my_pe() : () -> i32
  %1 = openshmem.my_pe : !openshmem.pe
  
  // CHECK: llvm.call @shmem_n_pes() : () -> i32
  %2 = openshmem.n_pes : !openshmem.pe

  // Test finalize operation
  // CHECK: llvm.call @shmem_finalize() : () -> i32
  %3 = openshmem.finalize : !openshmem.retval

  return
}

func.func @test_openshmem_memory(%size: !openshmem.size) {
  // CHECK-LABEL: @test_openshmem_memory
  
  // Test malloc operation
  // CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
  %ptr = openshmem.malloc(%size) : !openshmem.size -> memref<1024xi32>
  
  // Test free operation  
  // CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> i32
  openshmem.free(%ptr) : memref<1024xi32>
  
  return
}

func.func @test_openshmem_communication(%arg0: memref<10xi32>, %arg1: memref<10xi32>, %size: !openshmem.size, %pe: !openshmem.pe) {
  // CHECK-LABEL: @test_openshmem_communication
  
  // Test put operation
  // CHECK: llvm.call @shmem_put_nbi(%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, !llvm.ptr, i64, i32) -> i32
  openshmem.put(%arg0, %arg1, %size, %pe) : memref<10xi32>, memref<10xi32>, !openshmem.size, !openshmem.pe
  
  // Test get operation
  // CHECK: llvm.call @shmem_get_nbi(%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, !llvm.ptr, i64, i32) -> i32
  openshmem.get(%arg1, %arg0, %size, %pe) : memref<10xi32>, memref<10xi32>, !openshmem.size, !openshmem.pe
      
  return
}

func.func @test_openshmem_atomics(%dest: memref<1xi32>, %value: i32, %pe: !openshmem.pe) {
  // CHECK-LABEL: @test_openshmem_atomics
  
  // Test atomic add
  // CHECK: llvm.call @shmem_atomic_add(%{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, i32, i32) -> i32
  openshmem.atomic_add(%dest, %value, %pe) : memref<1xi32>, i32, !openshmem.pe
  
  // Test atomic fetch add
  // CHECK: llvm.call @shmem_atomic_fetch_add(%{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, i32, i32) -> i32
  %old = openshmem.atomic_fetch_add(%dest, %value, %pe) : memref<1xi32>, i32, !openshmem.pe -> i32
  
  // Test atomic compare swap
  // CHECK: llvm.call @shmem_atomic_compare_swap(%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, i32, i32, i32) -> i32
  %old2 = openshmem.atomic_compare_swap(%dest, %value, %value, %pe) : memref<1xi32>, i32, i32, !openshmem.pe -> i32
  
  // Test atomic swap
  // CHECK: llvm.call @shmem_atomic_swap(%{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, i32, i32) -> i32
  %old3 = openshmem.atomic_swap(%dest, %value, %pe) : memref<1xi32>, i32, !openshmem.pe -> i32
  
  // Test bitwise atomics
  // CHECK: llvm.call @shmem_atomic_and(%{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, i32, i32) -> i32
  openshmem.atomic_and(%dest, %value, %pe) : memref<1xi32>, i32, !openshmem.pe
  
  // CHECK: llvm.call @shmem_atomic_or(%{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, i32, i32) -> i32
  openshmem.atomic_or(%dest, %value, %pe) : memref<1xi32>, i32, !openshmem.pe
  
  // CHECK: llvm.call @shmem_atomic_xor(%{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, i32, i32) -> i32
  openshmem.atomic_xor(%dest, %value, %pe) : memref<1xi32>, i32, !openshmem.pe
  
  return
} 