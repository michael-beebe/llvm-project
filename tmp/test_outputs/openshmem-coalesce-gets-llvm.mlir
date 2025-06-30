module {
  llvm.func @shmem_putmem(!llvm.ptr, !llvm.ptr, i64, i32)
  llvm.func @shmem_getmem(!llvm.ptr, !llvm.ptr, i64, i32)
  func.func @test_coalesce_gets(%arg0: memref<100xi32>, %arg1: !openshmem.symmetric_memref<i32>) {
    %0 = builtin.unrealized_conversion_cast %arg1 : !openshmem.symmetric_memref<i32> to !llvm.ptr
    %1 = builtin.unrealized_conversion_cast %arg0 : memref<100xi32> to !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %2 = llvm.mlir.constant(1 : i32) : i32
    %3 = llvm.mlir.constant(12 : index) : i64
    %4 = llvm.extractvalue %1[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    llvm.call @shmem_getmem(%4, %0, %3, %2) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
    llvm.return
  }
  func.func @test_different_pes(%arg0: memref<100xi32>, %arg1: !openshmem.symmetric_memref<i32>) {
    %0 = builtin.unrealized_conversion_cast %arg1 : !openshmem.symmetric_memref<i32> to !llvm.ptr
    %1 = builtin.unrealized_conversion_cast %arg0 : memref<100xi32> to !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %2 = llvm.mlir.constant(0 : i32) : i32
    %3 = llvm.mlir.constant(1 : i32) : i32
    %4 = llvm.mlir.constant(2 : i32) : i32
    %5 = llvm.mlir.constant(4 : index) : i64
    %6 = llvm.extractvalue %1[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    llvm.call @shmem_getmem(%6, %0, %5, %2) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
    %7 = llvm.extractvalue %1[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    llvm.call @shmem_getmem(%7, %0, %5, %3) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
    %8 = llvm.extractvalue %1[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    llvm.call @shmem_getmem(%8, %0, %5, %4) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
    llvm.return
  }
  func.func @test_mixed_operations(%arg0: memref<100xi32>, %arg1: !openshmem.symmetric_memref<i32>) {
    %0 = builtin.unrealized_conversion_cast %arg1 : !openshmem.symmetric_memref<i32> to !llvm.ptr
    %1 = builtin.unrealized_conversion_cast %arg0 : memref<100xi32> to !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %2 = llvm.mlir.constant(8 : index) : i64
    %3 = llvm.mlir.constant(1 : i32) : i32
    %4 = llvm.mlir.constant(4 : index) : i64
    %5 = llvm.extractvalue %1[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    llvm.call @shmem_getmem(%5, %0, %2, %3) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
    %6 = llvm.extractvalue %1[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    llvm.call @shmem_putmem(%0, %6, %4, %3) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
    llvm.return
  }
}

