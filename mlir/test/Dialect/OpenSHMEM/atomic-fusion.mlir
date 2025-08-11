// RUN: mlir-opt %s --openshmem-atomic-fusion | FileCheck %s

module {
  func.func @fuse_add_constants(%dest: !openshmem.symmetric_memref<i32>) {
    %pe = arith.constant 3 : i32
    %c1 = arith.constant 4 : i32
    %c2 = arith.constant 5 : i32
    // CHECK-LABEL: func.func @fuse_add_constants
    // CHECK: openshmem.atomic_add(%{{.*}}, %{{.*}}, %{{.*}})
    // CHECK-NOT: openshmem.atomic_add
    openshmem.atomic_add(%dest, %c1, %pe) : !openshmem.symmetric_memref<i32>, i32, i32
    openshmem.atomic_add(%dest, %c2, %pe) : !openshmem.symmetric_memref<i32>, i32, i32
    return
  }

  func.func @fuse_inc_chain(%dest: !openshmem.symmetric_memref<i64>) {
    %pe = arith.constant 1 : i32
    // CHECK-LABEL: func.func @fuse_inc_chain
    // CHECK: openshmem.atomic_add(%{{.*}}, %{{.*}}, %{{.*}})
    // CHECK-NOT: openshmem.atomic_inc
    openshmem.atomic_inc(%dest, %pe) : !openshmem.symmetric_memref<i64>, i32
    openshmem.atomic_inc(%dest, %pe) : !openshmem.symmetric_memref<i64>, i32
    openshmem.atomic_inc(%dest, %pe) : !openshmem.symmetric_memref<i64>, i32
    return
  }

  func.func @fuse_or_constants(%dest: !openshmem.symmetric_memref<i32>) {
    %pe = arith.constant 7 : i32
    %v1 = arith.constant 16 : i32
    %v2 = arith.constant 32 : i32
    // CHECK-LABEL: func.func @fuse_or_constants
    // CHECK: openshmem.atomic_or(%{{.*}}, %{{.*}}, %{{.*}})
    // CHECK-NOT: openshmem.atomic_or
    openshmem.atomic_or(%dest, %v1, %pe) : !openshmem.symmetric_memref<i32>, i32, i32
    openshmem.atomic_or(%dest, %v2, %pe) : !openshmem.symmetric_memref<i32>, i32, i32
    return
  }

  func.func @fuse_xor_constants(%dest: !openshmem.symmetric_memref<i64>) {
    %pe = arith.constant 7 : i32
    %v1 = arith.constant 85 : i64
    %v2 = arith.constant 170 : i64
    // CHECK-LABEL: func.func @fuse_xor_constants
    // CHECK: openshmem.atomic_xor(%{{.*}}, %{{.*}}, %{{.*}})
    // CHECK-NOT: openshmem.atomic_xor
    openshmem.atomic_xor(%dest, %v1, %pe) : !openshmem.symmetric_memref<i64>, i64, i32
    openshmem.atomic_xor(%dest, %v2, %pe) : !openshmem.symmetric_memref<i64>, i64, i32
    return
  }
}


