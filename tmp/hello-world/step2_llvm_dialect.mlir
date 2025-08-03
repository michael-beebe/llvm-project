module attributes {openshmem.num_pes = 2 : i32} {
  llvm.func @shmem_finalize()
  llvm.func @shmem_n_pes() -> i32
  llvm.func @shmem_my_pe() -> i32
  llvm.func @shmem_init()
  llvm.mlir.global private constant @hello_str("Hello from PE %d of %d\0A\00") {addr_space = 0 : i32}
  llvm.func @main(%arg0: i32, %arg1: !llvm.ptr) -> i32 {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.call @shmem_my_pe() : () -> i32
    %1 = llvm.call @shmem_n_pes() : () -> i32
    %2 = llvm.mlir.addressof @hello_str : !llvm.ptr
    %3 = llvm.mlir.constant(0 : i32) : i32
    %4 = llvm.mlir.zero : !llvm.ptr
    llvm.call @shmem_finalize() : () -> ()
    %5 = llvm.mlir.constant(0 : i32) : i32
    llvm.return %5 : i32
  }
}

