module {
  llvm.func @free(!llvm.ptr)
  llvm.func @malloc(i64) -> !llvm.ptr
  llvm.func @shmem_free(!llvm.ptr)
  llvm.func @shmem_putmem(!llvm.ptr, !llvm.ptr, i64, i32)
  llvm.func @shmem_malloc(i64) -> !llvm.ptr
  llvm.func @shmem_finalize()
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
    %12 = llvm.mlir.constant(10 : index) : i64
    %13 = llvm.mlir.constant(1 : index) : i64
    %14 = llvm.mlir.zero : !llvm.ptr
    %15 = llvm.getelementptr %14[%12] : (!llvm.ptr, i64) -> !llvm.ptr, i32
    %16 = llvm.ptrtoint %15 : !llvm.ptr to i64
    %17 = llvm.call @malloc(%16) : (i64) -> !llvm.ptr
    %18 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %19 = llvm.insertvalue %17, %18[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %20 = llvm.insertvalue %17, %19[1] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %21 = llvm.mlir.constant(0 : index) : i64
    %22 = llvm.insertvalue %21, %20[2] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %23 = llvm.insertvalue %12, %22[3, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %24 = llvm.insertvalue %13, %23[4, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    llvm.call @shmem_team_sync(%9) : (!llvm.ptr) -> ()
    %25 = llvm.call @shmem_team_my_pe(%9) : (!llvm.ptr) -> i32
    %26 = llvm.call @shmem_team_n_pes(%9) : (!llvm.ptr) -> i32
    %27 = llvm.mlir.constant(0 : i32) : i32
    %28 = llvm.mlir.constant(1 : i32) : i32
    %29 = llvm.icmp "eq" %25, %27 : i32
    %30 = llvm.select %29, %28, %27 : i1, i32
    %31 = llvm.mlir.constant(40 : index) : i64
    %32 = llvm.extractvalue %24[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    llvm.call @shmem_putmem(%11, %32, %31, %30) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
    llvm.call @shmem_team_sync(%9) : (!llvm.ptr) -> ()
    %33 = llvm.extractvalue %24[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    llvm.call @free(%33) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%11) : (!llvm.ptr) -> ()
    llvm.call @shmem_team_destroy(%9) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
}

