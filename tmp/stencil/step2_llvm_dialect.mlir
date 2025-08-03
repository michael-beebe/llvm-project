module attributes {openshmem.num_pes = 4 : i32} {
  llvm.func @shmem_finalize()
  llvm.func @shmem_free(!llvm.ptr)
  llvm.func @shmem_barrier_all()
  llvm.func @shmem_malloc(i64) -> !llvm.ptr
  llvm.func @shmem_n_pes() -> i32
  llvm.func @shmem_my_pe() -> i32
  llvm.func @shmem_init()
  llvm.func @main(%arg0: i32, %arg1: !llvm.ptr) -> i32 {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.call @shmem_my_pe() : () -> i32
    %1 = llvm.call @shmem_n_pes() : () -> i32
    %2 = llvm.mlir.constant(0 : index) : i64
    %3 = llvm.mlir.constant(1 : index) : i64
    %4 = llvm.mlir.constant(2 : index) : i64
    %5 = llvm.mlir.constant(4 : index) : i64
    %6 = llvm.mlir.constant(16 : index) : i64
    %7 = llvm.mlir.constant(64 : index) : i64
    %8 = llvm.mlir.constant(2.500000e-01 : f32) : f32
    %9 = llvm.mlir.constant(2.000000e+00 : f32) : f32
    %10 = llvm.mlir.constant(1.000000e+00 : f32) : f32
    %11 = llvm.mlir.constant(4 : index) : i64
    %12 = llvm.mlir.constant(16 : index) : i64
    %13 = llvm.call @shmem_malloc(%7) : (i64) -> !llvm.ptr
    %14 = llvm.sext %0 : i32 to i64
    %15 = llvm.mul %14, %11 : i64
    %16 = llvm.add %15, %3 : i64
    %17 = llvm.add %15, %4 : i64
    %18 = llvm.mlir.constant(3 : index) : i64
    %19 = llvm.add %15, %18 : i64
    llvm.call @shmem_barrier_all() : () -> ()
    %20 = llvm.add %15, %3 : i64
    %21 = llvm.add %15, %4 : i64
    %22 = llvm.mlir.constant(1 : i32) : i32
    %23 = llvm.mlir.constant(0 : i32) : i32
    %24 = llvm.sub %0, %22 : i32
    %25 = llvm.add %0, %22 : i32
    %26 = llvm.sub %1, %22 : i32
    %27 = llvm.icmp "sgt" %0, %23 : i32
    %28 = llvm.icmp "slt" %0, %26 : i32
    %29 = llvm.sitofp %0 : i32 to f32
    %30 = llvm.mlir.constant(4.000000e+00 : f32) : f32
    %31 = llvm.fmul %29, %30 : f32
    %32 = llvm.mlir.constant(1.000000e+00 : f32) : f32
    %33 = llvm.fadd %31, %32 : f32
    llvm.call @shmem_barrier_all() : () -> ()
    llvm.call @shmem_barrier_all() : () -> ()
    %34 = llvm.mlir.constant(0.000000e+00 : f32) : f32
    %35 = llvm.sitofp %24 : i32 to f32
    %36 = llvm.sitofp %25 : i32 to f32
    %37 = llvm.fmul %35, %30 : f32
    %38 = llvm.fmul %36, %30 : f32
    %39 = llvm.fadd %37, %32 : f32
    %40 = llvm.fadd %38, %32 : f32
    %41 = llvm.select %27, %39, %33 : i1, f32
    %42 = llvm.select %28, %40, %33 : i1, f32
    %43 = llvm.fmul %33, %9 : f32
    %44 = llvm.fadd %41, %42 : f32
    %45 = llvm.fadd %43, %44 : f32
    %46 = llvm.fmul %45, %8 : f32
    llvm.call @shmem_barrier_all() : () -> ()
    llvm.call @shmem_free(%13) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    %47 = llvm.mlir.constant(0 : i32) : i32
    llvm.return %47 : i32
  }
}

