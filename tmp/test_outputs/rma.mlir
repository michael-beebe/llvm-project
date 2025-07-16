module {
  llvm.func @malloc(i64) -> !llvm.ptr
  llvm.func @shmem_ctx_destroy(!llvm.ptr)
  llvm.func @shmem_ctx_put32(!llvm.ptr, !llvm.ptr, !llvm.ptr, i64, i32)
  llvm.func @shmem_ctx_create(i64, !llvm.ptr) -> i32
  llvm.func @shmem_put128(!llvm.ptr, !llvm.ptr, i64, i32)
  llvm.func @shmem_put16(!llvm.ptr, !llvm.ptr, i64, i32)
  llvm.func @shmem_put8(!llvm.ptr, !llvm.ptr, i64, i32)
  llvm.func @shmem_put_nbi32(!llvm.ptr, !llvm.ptr, i64, i32)
  llvm.func @shmem_put64(!llvm.ptr, !llvm.ptr, i64, i32)
  llvm.func @shmem_put32(!llvm.ptr, !llvm.ptr, i64, i32)
  llvm.func @shmem_getmem_nbi(!llvm.ptr, !llvm.ptr, i64, i32)
  llvm.func @shmem_quiet()
  llvm.func @shmem_putmem_nbi(!llvm.ptr, !llvm.ptr, i64, i32)
  llvm.func @shmem_getmem(!llvm.ptr, !llvm.ptr, i64, i32)
  llvm.func @shmem_finalize()
  llvm.func @shmem_free(!llvm.ptr)
  llvm.func @shmem_putmem(!llvm.ptr, !llvm.ptr, i64, i32)
  llvm.func @shmem_malloc(i64) -> !llvm.ptr
  llvm.func @shmem_init()
  llvm.func @test_putmem() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(10 : index) : i64
    %1 = llvm.mlir.constant(40 : index) : i64
    %2 = llvm.mlir.constant(1 : i32) : i32
    %3 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
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
    %17 = llvm.extractvalue %16[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    llvm.call @shmem_putmem(%3, %17, %1, %2) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_getmem() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(10 : index) : i64
    %1 = llvm.mlir.constant(40 : index) : i64
    %2 = llvm.mlir.constant(1 : i32) : i32
    %3 = llvm.mlir.constant(10 : index) : i64
    %4 = llvm.mlir.constant(1 : index) : i64
    %5 = llvm.mlir.zero : !llvm.ptr
    %6 = llvm.getelementptr %5[%3] : (!llvm.ptr, i64) -> !llvm.ptr, i32
    %7 = llvm.ptrtoint %6 : !llvm.ptr to i64
    %8 = llvm.call @malloc(%7) : (i64) -> !llvm.ptr
    %9 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %10 = llvm.insertvalue %8, %9[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %11 = llvm.insertvalue %8, %10[1] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %12 = llvm.mlir.constant(0 : index) : i64
    %13 = llvm.insertvalue %12, %11[2] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %14 = llvm.insertvalue %3, %13[3, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %15 = llvm.insertvalue %4, %14[4, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %16 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    %17 = llvm.extractvalue %15[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    llvm.call @shmem_getmem(%17, %16, %1, %2) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
    llvm.call @shmem_free(%16) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_putmem_nbi() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(10 : index) : i64
    %1 = llvm.mlir.constant(40 : index) : i64
    %2 = llvm.mlir.constant(1 : i32) : i32
    %3 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
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
    %17 = llvm.extractvalue %16[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    llvm.call @shmem_putmem_nbi(%3, %17, %1, %2) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
    llvm.call @shmem_quiet() : () -> ()
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_getmem_nbi() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(10 : index) : i64
    %1 = llvm.mlir.constant(40 : index) : i64
    %2 = llvm.mlir.constant(1 : i32) : i32
    %3 = llvm.mlir.constant(10 : index) : i64
    %4 = llvm.mlir.constant(1 : index) : i64
    %5 = llvm.mlir.zero : !llvm.ptr
    %6 = llvm.getelementptr %5[%3] : (!llvm.ptr, i64) -> !llvm.ptr, i32
    %7 = llvm.ptrtoint %6 : !llvm.ptr to i64
    %8 = llvm.call @malloc(%7) : (i64) -> !llvm.ptr
    %9 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %10 = llvm.insertvalue %8, %9[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %11 = llvm.insertvalue %8, %10[1] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %12 = llvm.mlir.constant(0 : index) : i64
    %13 = llvm.insertvalue %12, %11[2] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %14 = llvm.insertvalue %3, %13[3, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %15 = llvm.insertvalue %4, %14[4, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %16 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    %17 = llvm.extractvalue %15[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    llvm.call @shmem_getmem_nbi(%17, %16, %1, %2) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
    llvm.call @shmem_quiet() : () -> ()
    llvm.call @shmem_free(%16) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_i32_put() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(10 : index) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
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
    %17 = llvm.extractvalue %16[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    llvm.call @shmem_put32(%3, %17, %0, %1) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_i64_put() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(10 : index) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.mlir.constant(80 : index) : i64
    %3 = llvm.call @shmem_malloc(%2) : (i64) -> !llvm.ptr
    %4 = llvm.mlir.constant(10 : index) : i64
    %5 = llvm.mlir.constant(1 : index) : i64
    %6 = llvm.mlir.zero : !llvm.ptr
    %7 = llvm.getelementptr %6[%4] : (!llvm.ptr, i64) -> !llvm.ptr, i64
    %8 = llvm.ptrtoint %7 : !llvm.ptr to i64
    %9 = llvm.call @malloc(%8) : (i64) -> !llvm.ptr
    %10 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %11 = llvm.insertvalue %9, %10[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %12 = llvm.insertvalue %9, %11[1] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %13 = llvm.mlir.constant(0 : index) : i64
    %14 = llvm.insertvalue %13, %12[2] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %15 = llvm.insertvalue %4, %14[3, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %16 = llvm.insertvalue %5, %15[4, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %17 = llvm.extractvalue %16[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    llvm.call @shmem_put64(%3, %17, %0, %1) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_f32_put() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(10 : index) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.mlir.constant(40 : index) : i64
    %3 = llvm.call @shmem_malloc(%2) : (i64) -> !llvm.ptr
    %4 = llvm.mlir.constant(10 : index) : i64
    %5 = llvm.mlir.constant(1 : index) : i64
    %6 = llvm.mlir.zero : !llvm.ptr
    %7 = llvm.getelementptr %6[%4] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %8 = llvm.ptrtoint %7 : !llvm.ptr to i64
    %9 = llvm.call @malloc(%8) : (i64) -> !llvm.ptr
    %10 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %11 = llvm.insertvalue %9, %10[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %12 = llvm.insertvalue %9, %11[1] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %13 = llvm.mlir.constant(0 : index) : i64
    %14 = llvm.insertvalue %13, %12[2] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %15 = llvm.insertvalue %4, %14[3, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %16 = llvm.insertvalue %5, %15[4, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %17 = llvm.extractvalue %16[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    llvm.call @shmem_put32(%3, %17, %0, %1) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_put_nbi_typed() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(10 : index) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.mlir.constant(40 : index) : i64
    %3 = llvm.call @shmem_malloc(%2) : (i64) -> !llvm.ptr
    %4 = llvm.mlir.constant(10 : index) : i64
    %5 = llvm.mlir.constant(1 : index) : i64
    %6 = llvm.mlir.zero : !llvm.ptr
    %7 = llvm.getelementptr %6[%4] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %8 = llvm.ptrtoint %7 : !llvm.ptr to i64
    %9 = llvm.call @malloc(%8) : (i64) -> !llvm.ptr
    %10 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %11 = llvm.insertvalue %9, %10[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %12 = llvm.insertvalue %9, %11[1] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %13 = llvm.mlir.constant(0 : index) : i64
    %14 = llvm.insertvalue %13, %12[2] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %15 = llvm.insertvalue %4, %14[3, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %16 = llvm.insertvalue %5, %15[4, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %17 = llvm.extractvalue %16[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    llvm.call @shmem_put_nbi32(%3, %17, %0, %1) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
    llvm.call @shmem_quiet() : () -> ()
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_put8_sized() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(10 : index) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.mlir.constant(10 : index) : i64
    %3 = llvm.call @shmem_malloc(%2) : (i64) -> !llvm.ptr
    %4 = llvm.mlir.constant(10 : index) : i64
    %5 = llvm.mlir.constant(1 : index) : i64
    %6 = llvm.mlir.zero : !llvm.ptr
    %7 = llvm.getelementptr %6[%4] : (!llvm.ptr, i64) -> !llvm.ptr, i8
    %8 = llvm.ptrtoint %7 : !llvm.ptr to i64
    %9 = llvm.call @malloc(%8) : (i64) -> !llvm.ptr
    %10 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %11 = llvm.insertvalue %9, %10[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %12 = llvm.insertvalue %9, %11[1] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %13 = llvm.mlir.constant(0 : index) : i64
    %14 = llvm.insertvalue %13, %12[2] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %15 = llvm.insertvalue %4, %14[3, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %16 = llvm.insertvalue %5, %15[4, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %17 = llvm.extractvalue %16[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    llvm.call @shmem_put8(%3, %17, %0, %1) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_put16_sized() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(10 : index) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.mlir.constant(20 : index) : i64
    %3 = llvm.call @shmem_malloc(%2) : (i64) -> !llvm.ptr
    %4 = llvm.mlir.constant(10 : index) : i64
    %5 = llvm.mlir.constant(1 : index) : i64
    %6 = llvm.mlir.zero : !llvm.ptr
    %7 = llvm.getelementptr %6[%4] : (!llvm.ptr, i64) -> !llvm.ptr, i16
    %8 = llvm.ptrtoint %7 : !llvm.ptr to i64
    %9 = llvm.call @malloc(%8) : (i64) -> !llvm.ptr
    %10 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %11 = llvm.insertvalue %9, %10[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %12 = llvm.insertvalue %9, %11[1] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %13 = llvm.mlir.constant(0 : index) : i64
    %14 = llvm.insertvalue %13, %12[2] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %15 = llvm.insertvalue %4, %14[3, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %16 = llvm.insertvalue %5, %15[4, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %17 = llvm.extractvalue %16[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    llvm.call @shmem_put16(%3, %17, %0, %1) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_put32_sized() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(10 : index) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
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
    %17 = llvm.extractvalue %16[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    llvm.call @shmem_put32(%3, %17, %0, %1) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_put64_sized() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(10 : index) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.mlir.constant(80 : index) : i64
    %3 = llvm.call @shmem_malloc(%2) : (i64) -> !llvm.ptr
    %4 = llvm.mlir.constant(10 : index) : i64
    %5 = llvm.mlir.constant(1 : index) : i64
    %6 = llvm.mlir.zero : !llvm.ptr
    %7 = llvm.getelementptr %6[%4] : (!llvm.ptr, i64) -> !llvm.ptr, i64
    %8 = llvm.ptrtoint %7 : !llvm.ptr to i64
    %9 = llvm.call @malloc(%8) : (i64) -> !llvm.ptr
    %10 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %11 = llvm.insertvalue %9, %10[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %12 = llvm.insertvalue %9, %11[1] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %13 = llvm.mlir.constant(0 : index) : i64
    %14 = llvm.insertvalue %13, %12[2] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %15 = llvm.insertvalue %4, %14[3, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %16 = llvm.insertvalue %5, %15[4, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %17 = llvm.extractvalue %16[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    llvm.call @shmem_put64(%3, %17, %0, %1) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_put128_sized() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(10 : index) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.mlir.constant(160 : index) : i64
    %3 = llvm.call @shmem_malloc(%2) : (i64) -> !llvm.ptr
    %4 = llvm.mlir.constant(10 : index) : i64
    %5 = llvm.mlir.constant(1 : index) : i64
    %6 = llvm.mlir.zero : !llvm.ptr
    %7 = llvm.getelementptr %6[%4] : (!llvm.ptr, i64) -> !llvm.ptr, f128
    %8 = llvm.ptrtoint %7 : !llvm.ptr to i64
    %9 = llvm.call @malloc(%8) : (i64) -> !llvm.ptr
    %10 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %11 = llvm.insertvalue %9, %10[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %12 = llvm.insertvalue %9, %11[1] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %13 = llvm.mlir.constant(0 : index) : i64
    %14 = llvm.insertvalue %13, %12[2] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %15 = llvm.insertvalue %4, %14[3, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %16 = llvm.insertvalue %5, %15[4, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %17 = llvm.extractvalue %16[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    llvm.call @shmem_put128(%3, %17, %0, %1) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_ctx_put() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(0 : i64) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.alloca %1 x !llvm.ptr : (i32) -> !llvm.ptr
    %3 = llvm.call @shmem_ctx_create(%0, %2) : (i64, !llvm.ptr) -> i32
    %4 = llvm.load %2 : !llvm.ptr -> !llvm.ptr
    %5 = llvm.mlir.constant(10 : index) : i64
    %6 = llvm.mlir.constant(1 : i32) : i32
    %7 = llvm.mlir.constant(40 : index) : i64
    %8 = llvm.call @shmem_malloc(%7) : (i64) -> !llvm.ptr
    %9 = llvm.mlir.constant(10 : index) : i64
    %10 = llvm.mlir.constant(1 : index) : i64
    %11 = llvm.mlir.zero : !llvm.ptr
    %12 = llvm.getelementptr %11[%9] : (!llvm.ptr, i64) -> !llvm.ptr, i32
    %13 = llvm.ptrtoint %12 : !llvm.ptr to i64
    %14 = llvm.call @malloc(%13) : (i64) -> !llvm.ptr
    %15 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %16 = llvm.insertvalue %14, %15[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %17 = llvm.insertvalue %14, %16[1] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %18 = llvm.mlir.constant(0 : index) : i64
    %19 = llvm.insertvalue %18, %17[2] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %20 = llvm.insertvalue %9, %19[3, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %21 = llvm.insertvalue %10, %20[4, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %22 = llvm.extractvalue %21[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    llvm.call @shmem_ctx_put32(%4, %8, %22, %5, %6) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, i64, i32) -> ()
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
}

