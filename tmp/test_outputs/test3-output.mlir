module attributes {openshmem.num_pes = 8 : i32} {
  func.func @stencil_boundary_exchange(%arg0: memref<100x100xf32>) {
    openshmem.init
    %0 = openshmem.my_pe : i32
    %1 = openshmem.n_pes : i32
    %c400_i64 = arith.constant 400 : i64
    %ptr = openshmem.malloc(%c400_i64) : i64 -> <f32>
    %ptr_0 = openshmem.malloc(%c400_i64) : i64 -> <f32>
    %c0_i32 = arith.constant 0 : i32
    %c1_i32 = arith.constant 1 : i32
    %c100_i64 = arith.constant 100 : i64
    %2 = arith.subi %0, %c1_i32 : i32
    openshmem.put(%ptr, %arg0, %c100_i64, %2) : <f32>, memref<100x100xf32>, i64, i32
    %3 = arith.addi %0, %c1_i32 : i32
    openshmem.put(%ptr_0, %arg0, %c100_i64, %3) : <f32>, memref<100x100xf32>, i64, i32
    openshmem.free(%ptr) : <f32>
    openshmem.free(%ptr_0) : <f32>
    openshmem.finalize
    return
  }
}

