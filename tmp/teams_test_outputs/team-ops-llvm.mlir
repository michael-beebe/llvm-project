module {
  llvm.func @shmem_finalize()
  llvm.func @shmem_team_destroy(!llvm.ptr)
  llvm.func @shmem_team_split_2d(!llvm.ptr, i32, !llvm.ptr, i64, !llvm.ptr, !llvm.ptr, i64, !llvm.ptr) -> i32
  llvm.func @shmem_team_split_strided(!llvm.ptr, i32, i32, i32, !llvm.ptr, i64, !llvm.ptr) -> i32
  llvm.mlir.global external constant @SHMEM_TEAM_WORLD() {addr_space = 0 : i32} : !llvm.ptr
  llvm.func @shmem_init()
  llvm.func @test_team_splits() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.addressof @SHMEM_TEAM_WORLD : !llvm.ptr
    %1 = llvm.mlir.constant(0 : i32) : i32
    %2 = llvm.mlir.constant(1 : i32) : i32
    %3 = llvm.mlir.constant(2 : i32) : i32
    %4 = llvm.mlir.constant(1 : i32) : i32
    %5 = llvm.alloca %4 x !llvm.ptr : (i32) -> !llvm.ptr
    %6 = llvm.mlir.zero : !llvm.ptr
    %7 = llvm.mlir.constant(0 : i64) : i64
    %8 = llvm.call @shmem_team_split_strided(%0, %1, %2, %3, %6, %7, %5) : (!llvm.ptr, i32, i32, i32, !llvm.ptr, i64, !llvm.ptr) -> i32
    %9 = llvm.load %5 : !llvm.ptr -> !llvm.ptr
    %10 = llvm.mlir.constant(2 : i32) : i32
    %11 = llvm.mlir.constant(1 : i32) : i32
    %12 = llvm.alloca %11 x !llvm.ptr : (i32) -> !llvm.ptr
    %13 = llvm.alloca %11 x !llvm.ptr : (i32) -> !llvm.ptr
    %14 = llvm.mlir.zero : !llvm.ptr
    %15 = llvm.mlir.constant(0 : i64) : i64
    %16 = llvm.call @shmem_team_split_2d(%0, %10, %14, %15, %12, %14, %15, %13) : (!llvm.ptr, i32, !llvm.ptr, i64, !llvm.ptr, !llvm.ptr, i64, !llvm.ptr) -> i32
    %17 = llvm.load %12 : !llvm.ptr -> !llvm.ptr
    %18 = llvm.load %13 : !llvm.ptr -> !llvm.ptr
    llvm.call @shmem_team_destroy(%9) : (!llvm.ptr) -> ()
    llvm.call @shmem_team_destroy(%17) : (!llvm.ptr) -> ()
    llvm.call @shmem_team_destroy(%18) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
}

