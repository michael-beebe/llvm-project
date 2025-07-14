module {
  llvm.func @shmem_fcollectmem(!llvm.ptr, !llvm.ptr, !llvm.ptr, i64) -> i32
  llvm.func @shmem_collectmem(!llvm.ptr, !llvm.ptr, !llvm.ptr, i64) -> i32
  llvm.func @shmem_broadcastmem(!llvm.ptr, !llvm.ptr, !llvm.ptr, i64, i32) -> i32
  llvm.func @shmem_finalize()
  llvm.func @shmem_free(!llvm.ptr)
  llvm.func @shmem_alltoallsmem(!llvm.ptr, !llvm.ptr, !llvm.ptr, i64, i64, i64) -> i32
  llvm.func @shmem_malloc(i64) -> !llvm.ptr
  llvm.mlir.global external constant @SHMEM_TEAM_WORLD() {addr_space = 0 : i32} : !llvm.ptr
  llvm.func @shmem_init()
  module {
    llvm.func @shmem_finalize()
    llvm.func @shmem_free(!llvm.ptr)
    llvm.func @shmem_alltoallmem(!llvm.ptr, !llvm.ptr, !llvm.ptr, i64) -> i32
    llvm.func @shmem_malloc(i64) -> !llvm.ptr
    llvm.mlir.global external constant @SHMEM_TEAM_WORLD() {addr_space = 0 : i32} : !llvm.ptr
    llvm.func @shmem_init()
    llvm.func @test_alltoallmem() {
      llvm.call @shmem_init() : () -> ()
      %0 = llvm.mlir.addressof @SHMEM_TEAM_WORLD : !llvm.ptr
      %1 = llvm.mlir.constant(10 : index) : i64
      %2 = llvm.mlir.constant(40 : index) : i64
      %3 = llvm.call @shmem_malloc(%2) : (i64) -> !llvm.ptr
      %4 = llvm.call @shmem_malloc(%2) : (i64) -> !llvm.ptr
      %5 = llvm.call @shmem_alltoallmem(%0, %3, %4, %1) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, i64) -> i32
      llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
      llvm.call @shmem_free(%4) : (!llvm.ptr) -> ()
      llvm.call @shmem_finalize() : () -> ()
      llvm.return
    }
  }
  llvm.func @test_alltoallsmem() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.addressof @SHMEM_TEAM_WORLD : !llvm.ptr
    %1 = llvm.mlir.constant(10 : index) : i64
    %2 = llvm.mlir.constant(40 : index) : i64
    %3 = llvm.call @shmem_malloc(%2) : (i64) -> !llvm.ptr
    %4 = llvm.call @shmem_malloc(%2) : (i64) -> !llvm.ptr
    %5 = llvm.mlir.constant(2 : index) : i64
    %6 = llvm.mlir.constant(2 : index) : i64
    %7 = llvm.call @shmem_alltoallsmem(%0, %3, %4, %5, %6, %1) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, i64, i64, i64) -> i32
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%4) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_broadcastmem() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.addressof @SHMEM_TEAM_WORLD : !llvm.ptr
    %1 = llvm.mlir.constant(10 : index) : i64
    %2 = llvm.mlir.constant(40 : index) : i64
    %3 = llvm.mlir.constant(0 : i32) : i32
    %4 = llvm.call @shmem_malloc(%2) : (i64) -> !llvm.ptr
    %5 = llvm.call @shmem_malloc(%2) : (i64) -> !llvm.ptr
    %6 = llvm.call @shmem_broadcastmem(%0, %4, %5, %1, %3) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, i64, i32) -> i32
    llvm.call @shmem_free(%4) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%5) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_collectmem() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.addressof @SHMEM_TEAM_WORLD : !llvm.ptr
    %1 = llvm.mlir.constant(10 : index) : i64
    %2 = llvm.mlir.constant(40 : index) : i64
    %3 = llvm.call @shmem_malloc(%2) : (i64) -> !llvm.ptr
    %4 = llvm.call @shmem_malloc(%2) : (i64) -> !llvm.ptr
    %5 = llvm.call @shmem_collectmem(%0, %3, %4, %1) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, i64) -> i32
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%4) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_fcollectmem() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.addressof @SHMEM_TEAM_WORLD : !llvm.ptr
    %1 = llvm.mlir.constant(10 : index) : i64
    %2 = llvm.mlir.constant(40 : index) : i64
    %3 = llvm.call @shmem_malloc(%2) : (i64) -> !llvm.ptr
    %4 = llvm.call @shmem_malloc(%2) : (i64) -> !llvm.ptr
    %5 = llvm.call @shmem_fcollectmem(%0, %3, %4, %1) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, i64) -> i32
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%4) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
}

