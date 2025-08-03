module attributes {openshmem.num_pes = 4 : i32} {
  llvm.func @shmem_finalize()
  llvm.func @shmem_free(!llvm.ptr)
  llvm.func @shmem_float_get(!llvm.ptr, !llvm.ptr, i64, i32)
  llvm.func @shmem_float_put(!llvm.ptr, !llvm.ptr, i64, i32)
  llvm.func @shmem_malloc(i64) -> !llvm.ptr
  llvm.func @shmem_n_pes() -> i32
  llvm.func @shmem_my_pe() -> i32
  llvm.func @shmem_init()
  llvm.func @test_typed(%arg0: i32, %arg1: !llvm.ptr) -> i32 {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.call @shmem_my_pe() : () -> i32
    %1 = llvm.call @shmem_n_pes() : () -> i32
    %2 = llvm.mlir.constant(64 : index) : i64
    %3 = llvm.call @shmem_malloc(%2) : (i64) -> !llvm.ptr
    %4 = llvm.mlir.constant(1 : index) : i64
    %5 = llvm.mlir.constant(1 : index) : i64
    %6 = llvm.mlir.constant(1 : index) : i64
    %7 = llvm.alloca %5 x f32 : (i64) -> !llvm.ptr
    %8 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %9 = llvm.insertvalue %7, %8[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %10 = llvm.insertvalue %7, %9[1] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %11 = llvm.mlir.constant(0 : index) : i64
    %12 = llvm.insertvalue %11, %10[2] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %13 = llvm.insertvalue %5, %12[3, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %14 = llvm.insertvalue %6, %13[4, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %15 = llvm.extractvalue %14[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    llvm.call @shmem_float_put(%3, %15, %4, %0) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
    %16 = llvm.extractvalue %14[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    llvm.call @shmem_float_get(%16, %3, %4, %0) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    %17 = llvm.mlir.constant(0 : i32) : i32
    llvm.return %17 : i32
  }
}

