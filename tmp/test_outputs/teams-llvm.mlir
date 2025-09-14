module {
  llvm.func @shmem_g(!llvm.ptr, i32) -> i32
  llvm.func @shmem_p(!llvm.ptr, i32, i32)
  llvm.func @shmem_put32(!llvm.ptr, !llvm.ptr, i64, i32)
  llvm.func @shmem_free(!llvm.ptr)
  llvm.func @shmem_putmem(!llvm.ptr, !llvm.ptr, i64, i32)
  llvm.func @shmem_malloc(i64) -> !llvm.ptr
  llvm.func @shmem_barrier_all()
  llvm.func @shmem_team_destroy(!llvm.ptr)
  llvm.func @shmem_team_sync(!llvm.ptr)
  llvm.func @shmem_team_split_2d(!llvm.ptr, i32, !llvm.ptr, i64, !llvm.ptr, !llvm.ptr, i64, !llvm.ptr) -> i32
  llvm.func @shmem_team_split_strided(!llvm.ptr, i32, i32, i32, !llvm.ptr, i64, !llvm.ptr) -> i32
  llvm.func @shmem_team_n_pes(!llvm.ptr) -> i32
  llvm.func @shmem_team_my_pe(!llvm.ptr) -> i32
  llvm.mlir.global external constant @SHMEM_TEAM_SHARED() {addr_space = 0 : i32} : !llvm.ptr
  llvm.mlir.global external constant @SHMEM_TEAM_WORLD() {addr_space = 0 : i32} : !llvm.ptr
  llvm.func @shmem_n_pes() -> i32
  llvm.func @shmem_my_pe() -> i32
  llvm.func @shmem_finalize()
  llvm.func @shmem_init()
  llvm.func @test_teams() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.call @shmem_my_pe() : () -> i32
    %1 = llvm.call @shmem_n_pes() : () -> i32
    %2 = llvm.mlir.addressof @SHMEM_TEAM_WORLD : !llvm.ptr
    %3 = llvm.mlir.addressof @SHMEM_TEAM_SHARED : !llvm.ptr
    %4 = llvm.call @shmem_team_my_pe(%2) : (!llvm.ptr) -> i32
    %5 = llvm.call @shmem_team_n_pes(%2) : (!llvm.ptr) -> i32
    %6 = llvm.call @shmem_team_my_pe(%3) : (!llvm.ptr) -> i32
    %7 = llvm.mlir.constant(0 : i32) : i32
    %8 = llvm.mlir.constant(1 : i32) : i32
    %9 = llvm.mlir.constant(2 : i32) : i32
    %10 = llvm.mlir.constant(1 : i32) : i32
    %11 = llvm.alloca %10 x !llvm.ptr : (i32) -> !llvm.ptr
    %12 = llvm.mlir.zero : !llvm.ptr
    %13 = llvm.mlir.constant(0 : i64) : i64
    %14 = llvm.call @shmem_team_split_strided(%2, %7, %8, %9, %12, %13, %11) : (!llvm.ptr, i32, i32, i32, !llvm.ptr, i64, !llvm.ptr) -> i32
    %15 = llvm.load %11 : !llvm.ptr -> !llvm.ptr
    %16 = llvm.mlir.constant(2 : i32) : i32
    %17 = llvm.mlir.constant(1 : i32) : i32
    %18 = llvm.alloca %17 x !llvm.ptr : (i32) -> !llvm.ptr
    %19 = llvm.alloca %17 x !llvm.ptr : (i32) -> !llvm.ptr
    %20 = llvm.mlir.zero : !llvm.ptr
    %21 = llvm.mlir.constant(0 : i64) : i64
    %22 = llvm.call @shmem_team_split_2d(%2, %16, %20, %21, %18, %20, %21, %19) : (!llvm.ptr, i32, !llvm.ptr, i64, !llvm.ptr, !llvm.ptr, i64, !llvm.ptr) -> i32
    %23 = llvm.load %18 : !llvm.ptr -> !llvm.ptr
    %24 = llvm.load %19 : !llvm.ptr -> !llvm.ptr
    llvm.call @shmem_team_sync(%15) : (!llvm.ptr) -> ()
    llvm.call @shmem_team_sync(%23) : (!llvm.ptr) -> ()
    llvm.call @shmem_team_sync(%24) : (!llvm.ptr) -> ()
    %25 = llvm.call @shmem_team_my_pe(%15) : (!llvm.ptr) -> i32
    %26 = llvm.call @shmem_team_n_pes(%15) : (!llvm.ptr) -> i32
    llvm.call @shmem_team_destroy(%15) : (!llvm.ptr) -> ()
    llvm.call @shmem_team_destroy(%23) : (!llvm.ptr) -> ()
    llvm.call @shmem_team_destroy(%24) : (!llvm.ptr) -> ()
    llvm.call @shmem_barrier_all() : () -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_predefined_teams() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.addressof @SHMEM_TEAM_WORLD : !llvm.ptr
    %1 = llvm.mlir.addressof @SHMEM_TEAM_SHARED : !llvm.ptr
    %2 = llvm.call @shmem_team_my_pe(%0) : (!llvm.ptr) -> i32
    %3 = llvm.call @shmem_team_my_pe(%1) : (!llvm.ptr) -> i32
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
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
  llvm.func @test_team_queries() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.addressof @SHMEM_TEAM_WORLD : !llvm.ptr
    %1 = llvm.call @shmem_team_my_pe(%0) : (!llvm.ptr) -> i32
    %2 = llvm.call @shmem_team_n_pes(%0) : (!llvm.ptr) -> i32
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_team_sync() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.addressof @SHMEM_TEAM_WORLD : !llvm.ptr
    llvm.call @shmem_team_sync(%0) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_team_communication() {
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
    %10 = llvm.mlir.constant(40 : index) : i64
    %11 = llvm.call @shmem_malloc(%10) : (i64) -> !llvm.ptr
    %12 = llvm.mlir.constant(4 : i64) : i64
    %13 = llvm.alloca %12 x !llvm.ptr : (i64) -> !llvm.ptr
    llvm.call @shmem_team_sync(%9) : (!llvm.ptr) -> ()
    %14 = llvm.call @shmem_team_my_pe(%9) : (!llvm.ptr) -> i32
    %15 = llvm.call @shmem_team_n_pes(%9) : (!llvm.ptr) -> i32
    %16 = llvm.mlir.constant(0 : i32) : i32
    %17 = llvm.mlir.constant(1 : i32) : i32
    %18 = llvm.icmp "eq" %14, %16 : i32
    %19 = llvm.select %18, %17, %16 : i1, i32
    %20 = llvm.mlir.constant(40 : index) : i64
    llvm.call @shmem_putmem(%11, %13, %20, %19) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
    llvm.call @shmem_team_sync(%9) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%11) : (!llvm.ptr) -> ()
    llvm.call @shmem_team_destroy(%9) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_team_with_typed_rma() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.addressof @SHMEM_TEAM_WORLD : !llvm.ptr
    %1 = llvm.mlir.constant(0 : i32) : i32
    %2 = llvm.mlir.constant(2 : i32) : i32
    %3 = llvm.mlir.constant(2 : i32) : i32
    %4 = llvm.mlir.constant(1 : i32) : i32
    %5 = llvm.alloca %4 x !llvm.ptr : (i32) -> !llvm.ptr
    %6 = llvm.mlir.zero : !llvm.ptr
    %7 = llvm.mlir.constant(0 : i64) : i64
    %8 = llvm.call @shmem_team_split_strided(%0, %1, %2, %3, %6, %7, %5) : (!llvm.ptr, i32, i32, i32, !llvm.ptr, i64, !llvm.ptr) -> i32
    %9 = llvm.load %5 : !llvm.ptr -> !llvm.ptr
    %10 = llvm.mlir.constant(40 : index) : i64
    %11 = llvm.call @shmem_malloc(%10) : (i64) -> !llvm.ptr
    %12 = llvm.mlir.constant(4 : i64) : i64
    %13 = llvm.alloca %12 x !llvm.ptr : (i64) -> !llvm.ptr
    llvm.call @shmem_team_sync(%9) : (!llvm.ptr) -> ()
    %14 = llvm.mlir.constant(10 : index) : i64
    %15 = llvm.mlir.constant(1 : i32) : i32
    llvm.call @shmem_put32(%11, %13, %14, %15) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
    llvm.call @shmem_team_sync(%9) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%11) : (!llvm.ptr) -> ()
    llvm.call @shmem_team_destroy(%9) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_multiple_team_splits() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.addressof @SHMEM_TEAM_WORLD : !llvm.ptr
    %1 = llvm.mlir.constant(0 : i32) : i32
    %2 = llvm.mlir.constant(1 : i32) : i32
    %3 = llvm.mlir.constant(4 : i32) : i32
    %4 = llvm.mlir.constant(1 : i32) : i32
    %5 = llvm.alloca %4 x !llvm.ptr : (i32) -> !llvm.ptr
    %6 = llvm.mlir.zero : !llvm.ptr
    %7 = llvm.mlir.constant(0 : i64) : i64
    %8 = llvm.call @shmem_team_split_strided(%0, %1, %2, %3, %6, %7, %5) : (!llvm.ptr, i32, i32, i32, !llvm.ptr, i64, !llvm.ptr) -> i32
    %9 = llvm.load %5 : !llvm.ptr -> !llvm.ptr
    %10 = llvm.mlir.constant(0 : i32) : i32
    %11 = llvm.mlir.constant(1 : i32) : i32
    %12 = llvm.mlir.constant(2 : i32) : i32
    %13 = llvm.mlir.constant(1 : i32) : i32
    %14 = llvm.alloca %13 x !llvm.ptr : (i32) -> !llvm.ptr
    %15 = llvm.mlir.zero : !llvm.ptr
    %16 = llvm.mlir.constant(0 : i64) : i64
    %17 = llvm.call @shmem_team_split_strided(%9, %10, %11, %12, %15, %16, %14) : (!llvm.ptr, i32, i32, i32, !llvm.ptr, i64, !llvm.ptr) -> i32
    %18 = llvm.load %14 : !llvm.ptr -> !llvm.ptr
    %19 = llvm.mlir.constant(4 : i32) : i32
    %20 = llvm.mlir.constant(1 : i32) : i32
    %21 = llvm.alloca %20 x !llvm.ptr : (i32) -> !llvm.ptr
    %22 = llvm.alloca %20 x !llvm.ptr : (i32) -> !llvm.ptr
    %23 = llvm.mlir.zero : !llvm.ptr
    %24 = llvm.mlir.constant(0 : i64) : i64
    %25 = llvm.call @shmem_team_split_2d(%0, %19, %23, %24, %21, %23, %24, %22) : (!llvm.ptr, i32, !llvm.ptr, i64, !llvm.ptr, !llvm.ptr, i64, !llvm.ptr) -> i32
    %26 = llvm.load %21 : !llvm.ptr -> !llvm.ptr
    %27 = llvm.load %22 : !llvm.ptr -> !llvm.ptr
    llvm.call @shmem_team_sync(%18) : (!llvm.ptr) -> ()
    llvm.call @shmem_team_sync(%26) : (!llvm.ptr) -> ()
    llvm.call @shmem_team_sync(%27) : (!llvm.ptr) -> ()
    %28 = llvm.call @shmem_team_my_pe(%18) : (!llvm.ptr) -> i32
    %29 = llvm.call @shmem_team_my_pe(%26) : (!llvm.ptr) -> i32
    %30 = llvm.call @shmem_team_n_pes(%27) : (!llvm.ptr) -> i32
    llvm.call @shmem_team_destroy(%18) : (!llvm.ptr) -> ()
    llvm.call @shmem_team_destroy(%9) : (!llvm.ptr) -> ()
    llvm.call @shmem_team_destroy(%26) : (!llvm.ptr) -> ()
    llvm.call @shmem_team_destroy(%27) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_teams_with_p2p() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.addressof @SHMEM_TEAM_WORLD : !llvm.ptr
    %1 = llvm.mlir.constant(4 : index) : i64
    %2 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    llvm.call @shmem_team_sync(%0) : (!llvm.ptr) -> ()
    %3 = llvm.mlir.constant(42 : i32) : i32
    %4 = llvm.mlir.constant(1 : i32) : i32
    llvm.call @shmem_p(%2, %3, %4) : (!llvm.ptr, i32, i32) -> ()
    %5 = llvm.call @shmem_g(%2, %4) : (!llvm.ptr, i32) -> i32
    llvm.call @shmem_team_sync(%0) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%2) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
}

