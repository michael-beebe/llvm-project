module {
  func.func @stencil_1d_consecutive(%arg0: memref<100xf32>, %arg1: !openshmem.symmetric_memref<f32>) {
    %c1_i32 = arith.constant 1 : i32
    %c12 = arith.constant 12 : index
    openshmem.putmem(%arg1, %arg0, %c12, %c1_i32) : <f32>, memref<100xf32>, index, i32
    return
  }
}

// -----
module {
  func.func @stencil_different_pes(%arg0: memref<100xf32>, %arg1: !openshmem.symmetric_memref<f32>) {
    %c0_i32 = arith.constant 0 : i32
    %c1_i32 = arith.constant 1 : i32
    %c2_i32 = arith.constant 2 : i32
    %c4 = arith.constant 4 : index
    openshmem.putmem(%arg1, %arg0, %c4, %c0_i32) : <f32>, memref<100xf32>, index, i32
    openshmem.putmem(%arg1, %arg0, %c4, %c1_i32) : <f32>, memref<100xf32>, index, i32
    openshmem.putmem(%arg1, %arg0, %c4, %c2_i32) : <f32>, memref<100xf32>, index, i32
    return
  }
}

// -----
module {
  func.func @stencil_block_coalescing(%arg0: memref<100xf32>, %arg1: !openshmem.symmetric_memref<f32>) {
    %c1_i32 = arith.constant 1 : i32
    %c8 = arith.constant 8 : index
    openshmem.putmem(%arg1, %arg0, %c8, %c1_i32) : <f32>, memref<100xf32>, index, i32
    return
  }
}

// -----
module {
  func.func @stencil_2d_halo_exchange(%arg0: memref<10x10xf32>, %arg1: !openshmem.symmetric_memref<f32>) {
    %c120 = arith.constant 120 : index
    %c0_i32 = arith.constant 0 : i32
    %c2_i32 = arith.constant 2 : i32
    %c3_i32 = arith.constant 3 : i32
    %c40 = arith.constant 40 : index
    openshmem.putmem(%arg1, %arg0, %c40, %c0_i32) : <f32>, memref<10x10xf32>, index, i32
    openshmem.putmem(%arg1, %arg0, %c40, %c2_i32) : <f32>, memref<10x10xf32>, index, i32
    openshmem.putmem(%arg1, %arg0, %c120, %c3_i32) : <f32>, memref<10x10xf32>, index, i32
    return
  }
}

