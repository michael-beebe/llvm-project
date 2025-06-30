module {
  func.func @main() {
    openshmem.init
    %0 = openshmem.my_pe : i32
    %1 = openshmem.n_pes : i32
    %c40 = arith.constant 40 : index
    %ptr = openshmem.malloc(%c40) : index -> <i32>
    %alloc = memref.alloc() : memref<10xi32>
    %c40_0 = arith.constant 40 : index
    %c1_i32 = arith.constant 1 : i32
    openshmem.barrier_all
    %2 = openshmem.team_world -> !openshmem.team
    openshmem.team_sync(%2) : !openshmem.team
    openshmem.putmem(%ptr, %alloc, %c40_0, %c1_i32) : <i32>, memref<10xi32>, index, i32
    %c40_1 = arith.constant 40 : index
    openshmem.getmem(%alloc, %ptr, %c40_1, %c1_i32) : memref<10xi32>, <i32>, index, i32
    openshmem.quiet
    memref.dealloc %alloc : memref<10xi32>
    openshmem.free(%ptr) : <i32>
    openshmem.finalize
    return
  }
}

