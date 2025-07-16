module attributes {openshmem.num_pes = 8 : i32} {
  func.func @stencil_boundary_exchange(%arg0: memref<100x100xf32>) {
    openshmem.init
    %0 = openshmem.my_pe : i32
    %1 = openshmem.n_pes : i32
    %c400 = arith.constant 400 : index
    %ptr = openshmem.malloc(%c400) : index -> <f32>
    %ptr_0 = openshmem.malloc(%c400) : index -> <f32>
    %c0_i32 = arith.constant 0 : i32
    %c1_i32 = arith.constant 1 : i32
    %c400_1 = arith.constant 400 : index
    %2 = arith.subi %0, %c1_i32 : i32
    openshmem.putmem(%ptr, %arg0, %c400_1, %2) : <f32>, memref<100x100xf32>, index, i32
    %3 = arith.addi %0, %c1_i32 : i32
    openshmem.putmem(%ptr_0, %arg0, %c400_1, %3) : <f32>, memref<100x100xf32>, index, i32
    openshmem.free(%ptr) : <f32>
    openshmem.free(%ptr_0) : <f32>
    openshmem.finalize
    return
  }
}

