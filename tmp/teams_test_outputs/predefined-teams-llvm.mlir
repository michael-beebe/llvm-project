module {
  llvm.mlir.global external constant @SHMEM_TEAM_SHARED() {addr_space = 0 : i32} : !llvm.ptr
  llvm.mlir.global external constant @SHMEM_TEAM_WORLD() {addr_space = 0 : i32} : !llvm.ptr
  llvm.func @test_predefined_teams() {
    %0 = llvm.mlir.addressof @SHMEM_TEAM_WORLD : !llvm.ptr
    %1 = llvm.mlir.addressof @SHMEM_TEAM_SHARED : !llvm.ptr
    llvm.return
  }
}

