module attributes {openshmem.num_pes = 2 : i32} {
  llvm.mlir.global private constant @hello_str("Hello from PE %d of %d\0A\00") {addr_space = 0 : i32}
  func.func @main(%arg0: i32, %arg1: !llvm.ptr) -> i32 {
    openshmem.init
    %0 = openshmem.my_pe : i32
    %1 = openshmem.n_pes : i32
    %2 = llvm.mlir.addressof @hello_str : !llvm.ptr
    %3 = llvm.mlir.constant(0 : i32) : i32
    %4 = llvm.mlir.zero : !llvm.ptr
    openshmem.finalize
    %c0_i32 = arith.constant 0 : i32
    return %c0_i32 : i32
  }
}

