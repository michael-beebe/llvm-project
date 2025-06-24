// RUN: mlir-opt %s -openshmem-coalesce-puts -split-input-file | FileCheck %s

// Test basic consecutive putmem coalescing in a 1D stencil pattern
func.func @stencil_1d_consecutive(%local_data: memref<100xf32>, 
                                  %remote_data: !openshmem.symmetric_memref<f32>) {
  %c0 = arith.constant 0 : i32
  %c1 = arith.constant 1 : i32
  %c2 = arith.constant 2 : i32
  %size = arith.constant 4 : index  // 4 bytes per f32

  // Multiple consecutive putmem operations to the same PE
  // These should be coalesced into a single larger transfer
  openshmem.putmem(%remote_data, %local_data, %size, %c1) : !openshmem.symmetric_memref<f32>, memref<100xf32>, index, i32
  openshmem.putmem(%remote_data, %local_data, %size, %c1) : !openshmem.symmetric_memref<f32>, memref<100xf32>, index, i32
  openshmem.putmem(%remote_data, %local_data, %size, %c1) : !openshmem.symmetric_memref<f32>, memref<100xf32>, index, i32

  return
}

// CHECK-LABEL: func.func @stencil_1d_consecutive
// CHECK: %[[FINAL_SIZE:.*]] = arith.constant 12 : index
// CHECK: openshmem.putmem(%{{.*}}, %{{.*}}, %[[FINAL_SIZE]], %{{.*}}) : <f32>, memref<100xf32>, index, i32
// CHECK-NOT: openshmem.putmem

// -----

// Test that putmem operations to different PEs are NOT coalesced
func.func @stencil_different_pes(%local_data: memref<100xf32>, 
                                 %remote_data: !openshmem.symmetric_memref<f32>) {
  %c0 = arith.constant 0 : i32
  %c1 = arith.constant 1 : i32
  %c2 = arith.constant 2 : i32
  %size = arith.constant 4 : index

  // These target different PEs and should NOT be coalesced
  openshmem.putmem(%remote_data, %local_data, %size, %c0) : !openshmem.symmetric_memref<f32>, memref<100xf32>, index, i32
  openshmem.putmem(%remote_data, %local_data, %size, %c1) : !openshmem.symmetric_memref<f32>, memref<100xf32>, index, i32
  openshmem.putmem(%remote_data, %local_data, %size, %c2) : !openshmem.symmetric_memref<f32>, memref<100xf32>, index, i32

  return
}

// CHECK-LABEL: func.func @stencil_different_pes
// CHECK: openshmem.putmem(%{{.*}}, %{{.*}}, %{{.*}}, %c0_i32) : <f32>, memref<100xf32>, index, i32
// CHECK: openshmem.putmem(%{{.*}}, %{{.*}}, %{{.*}}, %c1_i32) : <f32>, memref<100xf32>, index, i32
// CHECK: openshmem.putmem(%{{.*}}, %{{.*}}, %{{.*}}, %c2_i32) : <f32>, memref<100xf32>, index, i32

// -----

// Test block-level coalescing with intervening operations
func.func @stencil_block_coalescing(%local_data: memref<100xf32>, 
                                    %remote_data: !openshmem.symmetric_memref<f32>) {
  %c1 = arith.constant 1 : i32
  %size = arith.constant 4 : index
  %dummy = arith.constant 42 : i32

  // First putmem
  openshmem.putmem(%remote_data, %local_data, %size, %c1) : !openshmem.symmetric_memref<f32>, memref<100xf32>, index, i32
  
  // Some other operation in between
  %result = arith.addi %dummy, %dummy : i32
  
  // Second putmem to same PE - should be coalesced with first
  openshmem.putmem(%remote_data, %local_data, %size, %c1) : !openshmem.symmetric_memref<f32>, memref<100xf32>, index, i32

  return
}

// CHECK-LABEL: func.func @stencil_block_coalescing
// CHECK: %[[TOTAL_SIZE:.*]] = arith.constant 8 : index
// CHECK: openshmem.putmem(%{{.*}}, %{{.*}}, %[[TOTAL_SIZE]], %{{.*}}) : <f32>, memref<100xf32>, index, i32
// CHECK-NOT: openshmem.putmem

// -----

// Test realistic 2D stencil communication pattern
func.func @stencil_2d_halo_exchange(%local_grid: memref<10x10xf32>, 
                                    %remote_grid: !openshmem.symmetric_memref<f32>) {
  %c0 = arith.constant 0 : i32
  %c1 = arith.constant 1 : i32
  %c2 = arith.constant 2 : i32
  %c3 = arith.constant 3 : i32
  %row_size = arith.constant 40 : index  // 10 f32 elements * 4 bytes = 40 bytes

  // Simulate halo exchange - send boundary rows to neighboring PEs
  // Send top row to PE above (PE 0)
  openshmem.putmem(%remote_grid, %local_grid, %row_size, %c0) : !openshmem.symmetric_memref<f32>, memref<10x10xf32>, index, i32
  
  // Send bottom row to PE below (PE 2) 
  openshmem.putmem(%remote_grid, %local_grid, %row_size, %c2) : !openshmem.symmetric_memref<f32>, memref<10x10xf32>, index, i32
  
  // Send left column to PE left (PE 3) - multiple small transfers
  openshmem.putmem(%remote_grid, %local_grid, %row_size, %c3) : !openshmem.symmetric_memref<f32>, memref<10x10xf32>, index, i32
  openshmem.putmem(%remote_grid, %local_grid, %row_size, %c3) : !openshmem.symmetric_memref<f32>, memref<10x10xf32>, index, i32
  openshmem.putmem(%remote_grid, %local_grid, %row_size, %c3) : !openshmem.symmetric_memref<f32>, memref<10x10xf32>, index, i32

  return
}

// CHECK-LABEL: func.func @stencil_2d_halo_exchange
// CHECK: %[[TRIPLE_SIZE:.*]] = arith.constant 120 : index
// CHECK: %[[ROW_SIZE:.*]] = arith.constant 40 : index
// CHECK: openshmem.putmem(%{{.*}}, %{{.*}}, %[[ROW_SIZE]], %c0_i32) : <f32>, memref<10x10xf32>, index, i32
// CHECK: openshmem.putmem(%{{.*}}, %{{.*}}, %[[ROW_SIZE]], %c2_i32) : <f32>, memref<10x10xf32>, index, i32
// CHECK: openshmem.putmem(%{{.*}}, %{{.*}}, %[[TRIPLE_SIZE]], %c3_i32) : <f32>, memref<10x10xf32>, index, i32
// CHECK-NOT: openshmem.putmem 