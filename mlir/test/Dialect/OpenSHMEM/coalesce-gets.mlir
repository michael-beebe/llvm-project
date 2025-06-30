// RUN: mlir-opt %s --openshmem-coalesce-gets | FileCheck %s

// Test CoalesceGets pass functionality

module {
  func.func @test_coalesce_gets(%local_data: memref<100xi32>, 
                                %remote_data: !openshmem.symmetric_memref<i32>) {
    %c1 = arith.constant 1 : i32
    %size = arith.constant 4 : index  // 4 bytes per i32

    // These consecutive getmem operations should be coalesced
    openshmem.getmem(%local_data, %remote_data, %size, %c1) : memref<100xi32>, !openshmem.symmetric_memref<i32>, index, i32
    openshmem.getmem(%local_data, %remote_data, %size, %c1) : memref<100xi32>, !openshmem.symmetric_memref<i32>, index, i32
    openshmem.getmem(%local_data, %remote_data, %size, %c1) : memref<100xi32>, !openshmem.symmetric_memref<i32>, index, i32

    return
  }

  func.func @test_different_pes(%local_data: memref<100xi32>, 
                                %remote_data: !openshmem.symmetric_memref<i32>) {
    %c0 = arith.constant 0 : i32
    %c1 = arith.constant 1 : i32
    %c2 = arith.constant 2 : i32
    %size = arith.constant 4 : index

    // These target different PEs and should NOT be coalesced
    openshmem.getmem(%local_data, %remote_data, %size, %c0) : memref<100xi32>, !openshmem.symmetric_memref<i32>, index, i32
    openshmem.getmem(%local_data, %remote_data, %size, %c1) : memref<100xi32>, !openshmem.symmetric_memref<i32>, index, i32
    openshmem.getmem(%local_data, %remote_data, %size, %c2) : memref<100xi32>, !openshmem.symmetric_memref<i32>, index, i32

    return
  }

  func.func @test_mixed_operations(%local_data: memref<100xi32>, 
                                   %remote_data: !openshmem.symmetric_memref<i32>) {
    %c1 = arith.constant 1 : i32
    %size = arith.constant 4 : index

    // Mixed getmem and putmem operations - getmems should be coalesced separately
    openshmem.getmem(%local_data, %remote_data, %size, %c1) : memref<100xi32>, !openshmem.symmetric_memref<i32>, index, i32
    openshmem.putmem(%remote_data, %local_data, %size, %c1) : !openshmem.symmetric_memref<i32>, memref<100xi32>, index, i32
    openshmem.getmem(%local_data, %remote_data, %size, %c1) : memref<100xi32>, !openshmem.symmetric_memref<i32>, index, i32

    return
  }
}

// CHECK-LABEL: func.func @test_coalesce_gets
// CHECK: %c12 = arith.constant 12 : index
// CHECK: openshmem.getmem(%{{.*}}, %{{.*}}, %c12, %{{.*}}) : memref<100xi32>, <i32>, index, i32
// CHECK-NOT: openshmem.getmem

// CHECK-LABEL: func.func @test_different_pes
// CHECK: openshmem.getmem(%{{.*}}, %{{.*}}, %{{.*}}, %c0_i32) : memref<100xi32>, <i32>, index, i32
// CHECK: openshmem.getmem(%{{.*}}, %{{.*}}, %{{.*}}, %c1_i32) : memref<100xi32>, <i32>, index, i32
// CHECK: openshmem.getmem(%{{.*}}, %{{.*}}, %{{.*}}, %c2_i32) : memref<100xi32>, <i32>, index, i32

// CHECK-LABEL: func.func @test_mixed_operations
// CHECK: %c8 = arith.constant 8 : index
// CHECK: openshmem.getmem(%{{.*}}, %{{.*}}, %c8, %{{.*}}) : memref<100xi32>, <i32>, index, i32
// CHECK: openshmem.putmem(%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}) : <i32>, memref<100xi32>, index, i32
// CHECK-NOT: openshmem.getmem
