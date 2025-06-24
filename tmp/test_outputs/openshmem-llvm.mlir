module {
  llvm.func @free(!llvm.ptr)
  llvm.func @malloc(i64) -> !llvm.ptr
  llvm.func @shmem_finalize()
  llvm.func @shmem_free(!llvm.ptr)
  llvm.func @shmem_quiet()
  llvm.func @shmem_getmem(!llvm.ptr, !llvm.ptr, i64, i32)
  llvm.func @shmem_putmem(!llvm.ptr, !llvm.ptr, i64, i32)
  llvm.func @shmem_barrier_all()
  llvm.func @shmem_malloc(i64) -> !llvm.ptr
  llvm.func @shmem_n_pes() -> i32
  llvm.func @shmem_my_pe() -> i32
  llvm.func @shmem_init()
  llvm.func @main() {
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(40 : index) : i64
    llvm.call @shmem_init() : () -> ()
    %2 = llvm.call @shmem_my_pe() : () -> i32
    %3 = llvm.call @shmem_n_pes() : () -> i32
    %4 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    %5 = llvm.mlir.constant(10 : index) : i64
    %6 = llvm.mlir.constant(1 : index) : i64
    %7 = llvm.mlir.zero : !llvm.ptr
    %8 = llvm.getelementptr %7[%5] : (!llvm.ptr, i64) -> !llvm.ptr, i32
    %9 = llvm.ptrtoint %8 : !llvm.ptr to i64
    %10 = llvm.call @malloc(%9) : (i64) -> !llvm.ptr
    %11 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %12 = llvm.insertvalue %10, %11[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %13 = llvm.insertvalue %10, %12[1] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %14 = llvm.mlir.constant(0 : index) : i64
    %15 = llvm.insertvalue %14, %13[2] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %16 = llvm.insertvalue %5, %15[3, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %17 = llvm.insertvalue %6, %16[4, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    llvm.call @shmem_barrier_all() : () -> ()
    %18 = llvm.extractvalue %17[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    llvm.call @shmem_putmem(%4, %18, %1, %0) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
    llvm.call @shmem_getmem(%18, %4, %1, %0) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
    llvm.call @shmem_quiet() : () -> ()
    %19 = llvm.extractvalue %17[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    llvm.call @free(%19) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%4) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
}

