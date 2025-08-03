module attributes {openshmem.num_pes = 4 : i32} {
  func.func @main(%arg0: i32, %arg1: !llvm.ptr) -> i32 {
    openshmem.init
    %0 = openshmem.my_pe : i32
    %1 = openshmem.n_pes : i32
    %c0 = arith.constant 0 : index
    %c1 = arith.constant 1 : index
    %c2 = arith.constant 2 : index
    %c4 = arith.constant 4 : index
    %c16 = arith.constant 16 : index
    %c64 = arith.constant 64 : index
    %cst = arith.constant 2.500000e-01 : f32
    %cst_0 = arith.constant 2.000000e+00 : f32
    %cst_1 = arith.constant 1.000000e+00 : f32
    %c4_2 = arith.constant 4 : index
    %c16_3 = arith.constant 16 : index
    %2 = openshmem.malloc(%c64) : index -> <f32>
    %3 = arith.index_cast %0 : i32 to index
    %4 = arith.muli %3, %c4_2 : index
    %5 = arith.addi %4, %c0 : index
    %6 = arith.addi %4, %c1 : index
    %7 = arith.addi %4, %c2 : index
    %c3 = arith.constant 3 : index
    %8 = arith.addi %4, %c3 : index
    openshmem.barrier_all
    %9 = arith.addi %4, %c1 : index
    %10 = arith.addi %4, %c2 : index
    %c1_i32 = arith.constant 1 : i32
    %c0_i32 = arith.constant 0 : i32
    %11 = arith.subi %0, %c1_i32 : i32
    %12 = arith.addi %0, %c1_i32 : i32
    %13 = arith.subi %1, %c1_i32 : i32
    %14 = arith.cmpi sgt, %0, %c0_i32 : i32
    %15 = arith.cmpi slt, %0, %13 : i32
    %16 = arith.sitofp %0 : i32 to f32
    %cst_4 = arith.constant 4.000000e+00 : f32
    %17 = arith.mulf %16, %cst_4 : f32
    %cst_5 = arith.constant 1.000000e+00 : f32
    %18 = arith.addf %17, %cst_5 : f32
    openshmem.barrier_all
    openshmem.barrier_all
    %cst_6 = arith.constant 0.000000e+00 : f32
    %19 = arith.sitofp %11 : i32 to f32
    %20 = arith.sitofp %12 : i32 to f32
    %21 = arith.mulf %19, %cst_4 : f32
    %22 = arith.mulf %20, %cst_4 : f32
    %23 = arith.addf %21, %cst_5 : f32
    %24 = arith.addf %22, %cst_5 : f32
    %25 = arith.select %14, %23, %18 : f32
    %26 = arith.select %15, %24, %18 : f32
    %27 = arith.mulf %18, %cst_0 : f32
    %28 = arith.addf %25, %26 : f32
    %29 = arith.addf %27, %28 : f32
    %30 = arith.mulf %29, %cst : f32
    openshmem.barrier_all
    openshmem.free(%2) : <f32>
    openshmem.finalize
    %c0_i32_7 = arith.constant 0 : i32
    return %c0_i32_7 : i32
  }
}

