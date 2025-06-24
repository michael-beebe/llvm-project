// RUN: mlir-opt %s --openshmem-inject-num-pes="num-pes=4" | FileCheck %s

// Test demonstrating optimization opportunities with compile-time known num_pes

// CHECK: module attributes {openshmem.num_pes = 4 : i32}
module {
  func.func @stencil_boundary_exchange(%data: memref<100x100xf32>) {
    openshmem.init
    
    %pe = openshmem.my_pe : i32
    %npes = openshmem.n_pes : i32
    
    // Allocate symmetric memory for boundary data
    %boundary_size = arith.constant 400 : index  // 100 * sizeof(f32)
    %left_boundary = openshmem.malloc(%boundary_size) : index -> !openshmem.symmetric_memref<f32>
    %right_boundary = openshmem.malloc(%boundary_size) : index -> !openshmem.symmetric_memref<f32>
    
    // Example: With compile-time known num_pes=4, we could:
    // 1. Unroll this loop completely
    // 2. Generate PE-specific communication patterns
    // 3. Optimize memory layout based on PE topology
    
    %c0 = arith.constant 0 : i32
    %c1 = arith.constant 1 : i32
    %transfer_size = arith.constant 400 : index  // 100 elements * 4 bytes each
    
    // Send left boundary to left neighbor (PE-1)
    %left_pe = arith.subi %pe, %c1 : i32
    openshmem.putmem(%left_boundary, %data, %transfer_size, %left_pe) : 
      !openshmem.symmetric_memref<f32>, memref<100x100xf32>, index, i32
    
    // Send right boundary to right neighbor (PE+1)  
    %right_pe = arith.addi %pe, %c1 : i32
    openshmem.putmem(%right_boundary, %data, %transfer_size, %right_pe) : 
      !openshmem.symmetric_memref<f32>, memref<100x100xf32>, index, i32
    
    // Clean up
    openshmem.free(%left_boundary) : !openshmem.symmetric_memref<f32>
    openshmem.free(%right_boundary) : !openshmem.symmetric_memref<f32>
    
    openshmem.finalize
    return
  }
}
