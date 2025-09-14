module {
  llvm.func @shmem_ctx_destroy(!llvm.ptr)
  llvm.func @shmem_ctx_get_team(!llvm.ptr, !llvm.ptr) -> i32
  llvm.func @shmem_team_create_ctx(!llvm.ptr, i64, !llvm.ptr) -> i32
  llvm.mlir.global external constant @SHMEM_TEAM_WORLD() {addr_space = 0 : i32} : !llvm.ptr
  llvm.func @shmem_ctx_create(i64, !llvm.ptr) -> i32
  llvm.func @shmem_finalize()
  llvm.func @shmem_init()
  llvm.func @test_context_ops() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(0 : i64) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.alloca %1 x !llvm.ptr : (i32) -> !llvm.ptr
    %3 = llvm.call @shmem_ctx_create(%0, %2) : (i64, !llvm.ptr) -> i32
    %4 = llvm.load %2 : !llvm.ptr -> !llvm.ptr
    %5 = llvm.mlir.addressof @SHMEM_TEAM_WORLD : !llvm.ptr
    %6 = llvm.mlir.constant(1 : i32) : i32
    %7 = llvm.alloca %6 x !llvm.ptr : (i32) -> !llvm.ptr
    %8 = llvm.call @shmem_team_create_ctx(%5, %0, %7) : (!llvm.ptr, i64, !llvm.ptr) -> i32
    %9 = llvm.load %7 : !llvm.ptr -> !llvm.ptr
    %10 = llvm.mlir.constant(1 : i32) : i32
    %11 = llvm.alloca %10 x !llvm.ptr : (i32) -> !llvm.ptr
    %12 = llvm.call @shmem_ctx_get_team(%9, %11) : (!llvm.ptr, !llvm.ptr) -> i32
    %13 = llvm.load %11 : !llvm.ptr -> !llvm.ptr
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    llvm.call @shmem_ctx_destroy(%9) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
}

