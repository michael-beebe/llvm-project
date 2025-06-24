module {
  llvm.func @free(!llvm.ptr)
  llvm.func @malloc(i64) -> !llvm.ptr
  llvm.func @shmem_finalize()
  llvm.func @shmem_free(!llvm.ptr)
  llvm.func @shmem_quiet()
  llvm.func @shmem_get(!llvm.ptr, !llvm.ptr, i64, i32)
  llvm.func @shmem_put(!llvm.ptr, !llvm.ptr, i64, i32)
  llvm.func @shmem_barrier_all()
  llvm.func @shmem_malloc(i64) -> !llvm.ptr
  llvm.func @shmem_n_pes() -> i32
  llvm.func @shmem_my_pe() -> i32
  llvm.func @shmem_init()
  llvm.func @main() {
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(10 : i64) : i64
    %2 = llvm.mlir.constant(40 : i64) : i64
    llvm.call @shmem_init() : () -> ()
    %3 = llvm.call @shmem_my_pe() : () -> i32
    %4 = llvm.call @shmem_n_pes() : () -> i32
    %5 = llvm.call @shmem_malloc(%2) : (i64) -> !llvm.ptr
    %6 = llvm.mlir.constant(10 : index) : i64
    %7 = llvm.mlir.constant(1 : index) : i64
    %8 = llvm.mlir.zero : !llvm.ptr
    %9 = llvm.getelementptr %8[%6] : (!llvm.ptr, i64) -> !llvm.ptr, i32
    %10 = llvm.ptrtoint %9 : !llvm.ptr to i64
    %11 = llvm.call @malloc(%10) : (i64) -> !llvm.ptr
    %12 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %13 = llvm.insertvalue %11, %12[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %14 = llvm.insertvalue %11, %13[1] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %15 = llvm.mlir.constant(0 : index) : i64
    %16 = llvm.insertvalue %15, %14[2] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %17 = llvm.insertvalue %6, %16[3, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %18 = llvm.insertvalue %7, %17[4, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    llvm.call @shmem_barrier_all() : () -> ()
    %19 = llvm.extractvalue %18[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    llvm.call @shmem_put(%5, %19, %1, %0) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
    llvm.call @shmem_get(%19, %5, %1, %0) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
    llvm.call @shmem_quiet() : () -> ()
    %20 = llvm.extractvalue %18[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    llvm.call @free(%20) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%5) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
}

