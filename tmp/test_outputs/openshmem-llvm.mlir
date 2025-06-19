module {
  llvm.func @free(!llvm.ptr)
  llvm.func @malloc(i64) -> !llvm.ptr
  llvm.func @shmem_finalize() -> i32
  llvm.func @shmem_free(!llvm.ptr) -> i32
  llvm.func @shmem_get(!llvm.ptr, !llvm.ptr, i64, i32)
  llvm.func @shmem_put(!llvm.ptr, !llvm.ptr, i64, i32)
  llvm.func @shmem_malloc(i64) -> !llvm.ptr
  llvm.func @shmem_n_pes() -> i32
  llvm.func @shmem_my_pe() -> i32
  llvm.func @shmem_init() -> i32
  llvm.func @main() {
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(10 : i64) : i64
    %2 = llvm.mlir.constant(40 : i64) : i64
    %3 = llvm.call @shmem_init() : () -> i32
    %4 = llvm.call @shmem_my_pe() : () -> i32
    %5 = llvm.call @shmem_n_pes() : () -> i32
    %6 = llvm.call @shmem_malloc(%2) : (i64) -> !llvm.ptr
    %7 = llvm.mlir.constant(10 : index) : i64
    %8 = llvm.mlir.constant(1 : index) : i64
    %9 = llvm.mlir.zero : !llvm.ptr
    %10 = llvm.getelementptr %9[%7] : (!llvm.ptr, i64) -> !llvm.ptr, i32
    %11 = llvm.ptrtoint %10 : !llvm.ptr to i64
    %12 = llvm.call @malloc(%11) : (i64) -> !llvm.ptr
    %13 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %14 = llvm.insertvalue %12, %13[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %15 = llvm.insertvalue %12, %14[1] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %16 = llvm.mlir.constant(0 : index) : i64
    %17 = llvm.insertvalue %16, %15[2] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %18 = llvm.insertvalue %7, %17[3, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %19 = llvm.insertvalue %8, %18[4, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %20 = llvm.extractvalue %19[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    llvm.call @shmem_put(%6, %20, %1, %0) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
    llvm.call @shmem_get(%20, %6, %1, %0) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
    %21 = llvm.extractvalue %19[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    llvm.call @free(%21) : (!llvm.ptr) -> ()
    %22 = llvm.call @shmem_free(%6) : (!llvm.ptr) -> i32
    %23 = llvm.call @shmem_finalize() : () -> i32
    llvm.return
  }
}

