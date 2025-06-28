module {
  llvm.func @free(!llvm.ptr)
  llvm.func @malloc(i64) -> !llvm.ptr
  llvm.func @shmem_finalize()
  llvm.func @shmem_free(!llvm.ptr)
  llvm.func @shmem_quiet()
  llvm.func @shmem_getmem(!llvm.ptr, !llvm.ptr, i64, i32)
  llvm.func @shmem_putmem(!llvm.ptr, !llvm.ptr, i64, i32)
  llvm.func @shmem_team_sync(!llvm.ptr)
  llvm.mlir.global external constant @SHMEM_TEAM_WORLD() {addr_space = 0 : i32} : !llvm.ptr
  llvm.func @shmem_barrier_all()
  llvm.func @shmem_malloc(i64) -> !llvm.ptr
  llvm.func @shmem_n_pes() -> i32
  llvm.func @shmem_my_pe() -> i32
  llvm.func @shmem_init()
  llvm.func @main() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.call @shmem_my_pe() : () -> i32
    %1 = llvm.call @shmem_n_pes() : () -> i32
    %2 = llvm.mlir.constant(40 : index) : i64
    %3 = llvm.call @shmem_malloc(%2) : (i64) -> !llvm.ptr
    %4 = llvm.mlir.constant(10 : index) : i64
    %5 = llvm.mlir.constant(1 : index) : i64
    %6 = llvm.mlir.zero : !llvm.ptr
    %7 = llvm.getelementptr %6[%4] : (!llvm.ptr, i64) -> !llvm.ptr, i32
    %8 = llvm.ptrtoint %7 : !llvm.ptr to i64
    %9 = llvm.call @malloc(%8) : (i64) -> !llvm.ptr
    %10 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %11 = llvm.insertvalue %9, %10[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %12 = llvm.insertvalue %9, %11[1] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %13 = llvm.mlir.constant(0 : index) : i64
    %14 = llvm.insertvalue %13, %12[2] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %15 = llvm.insertvalue %4, %14[3, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %16 = llvm.insertvalue %5, %15[4, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %17 = llvm.mlir.constant(40 : index) : i64
    %18 = llvm.mlir.constant(1 : i32) : i32
    llvm.call @shmem_barrier_all() : () -> ()
    %19 = llvm.mlir.addressof @SHMEM_TEAM_WORLD : !llvm.ptr
    llvm.call @shmem_team_sync(%19) : (!llvm.ptr) -> ()
    %20 = llvm.extractvalue %16[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    llvm.call @shmem_putmem(%3, %20, %17, %18) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
    %21 = llvm.mlir.constant(40 : index) : i64
    %22 = llvm.extractvalue %16[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    llvm.call @shmem_getmem(%22, %3, %21, %18) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
    llvm.call @shmem_quiet() : () -> ()
    %23 = llvm.extractvalue %16[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    llvm.call @free(%23) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
}

