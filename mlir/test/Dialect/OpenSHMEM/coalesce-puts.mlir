// RUN: mlir-opt %s --openshmem-coalesce-puts | FileCheck %s

// Test CoalescePuts pass functionality

module {
  func.func @test_coalesce_puts(%local_data: memref<100xi32>, 
                                %remote_data: !openshmem.symmetric_memref<i32>) {
    %c1 = arith.constant 1 : i32
    %size = arith.constant 4 : index  // 4 bytes per i32

    // These consecutive putmem operations should be coalesced
    openshmem.putmem(%remote_data, %local_data, %size, %c1) : !openshmem.symmetric_memref<i32>, memref<100xi32>, index, i32
    openshmem.putmem(%remote_data, %local_data, %size, %c1) : !openshmem.symmetric_memref<i32>, memref<100xi32>, index, i32
    openshmem.putmem(%remote_data, %local_data, %size, %c1) : !openshmem.symmetric_memref<i32>, memref<100xi32>, index, i32

    return
  }

  func.func @test_different_pes(%local_data: memref<100xi32>, 
                                %remote_data: !openshmem.symmetric_memref<i32>) {
    %c0 = arith.constant 0 : i32
    %c1 = arith.constant 1 : i32
    %c2 = arith.constant 2 : i32
    %size = arith.constant 4 : index

    // These target different PEs and should NOT be coalesced
    openshmem.putmem(%remote_data, %local_data, %size, %c0) : !openshmem.symmetric_memref<i32>, memref<100xi32>, index, i32
    openshmem.putmem(%remote_data, %local_data, %size, %c1) : !openshmem.symmetric_memref<i32>, memref<100xi32>, index, i32
    openshmem.putmem(%remote_data, %local_data, %size, %c2) : !openshmem.symmetric_memref<i32>, memref<100xi32>, index, i32

    return
  }
}

// CHECK-LABEL: func.func @test_coalesce_puts
// CHECK: %[[TOTAL_SIZE:.*]] = arith.constant 12 : index
// CHECK: openshmem.putmem(%{{.*}}, %{{.*}}, %[[TOTAL_SIZE]], %{{.*}}) : <i32>, memref<100xi32>, index, i32
// CHECK-NOT: openshmem.putmem

// CHECK-LABEL: func.func @test_different_pes
// CHECK: openshmem.putmem(%{{.*}}, %{{.*}}, %{{.*}}, %c0_i32) : <i32>, memref<100xi32>, index, i32
// CHECK: openshmem.putmem(%{{.*}}, %{{.*}}, %{{.*}}, %c1_i32) : <i32>, memref<100xi32>, index, i32
// CHECK: openshmem.putmem(%{{.*}}, %{{.*}}, %{{.*}}, %c2_i32) : <i32>, memref<100xi32>, index, i32 