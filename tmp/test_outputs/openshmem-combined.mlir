module attributes {openshmem.num_pes = 16 : i32} {
  func.func @main() {
    %c1_i32 = arith.constant 1 : i32
    %c40 = arith.constant 40 : index
    openshmem.init
    %0 = openshmem.my_pe : i32
    %1 = openshmem.n_pes : i32
    %ptr = openshmem.malloc(%c40) : index -> <i32>
    %alloc = memref.alloc() : memref<10xi32>
    openshmem.barrier_all
    openshmem.putmem(%ptr, %alloc, %c40, %c1_i32) : <i32>, memref<10xi32>, index, i32
    openshmem.getmem(%alloc, %ptr, %c40, %c1_i32) : memref<10xi32>, <i32>, index, i32
    openshmem.quiet
    memref.dealloc %alloc : memref<10xi32>
    openshmem.free(%ptr) : <i32>
    openshmem.finalize
    return
  }
}

