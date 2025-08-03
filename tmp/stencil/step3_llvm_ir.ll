; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"
declare i32 @printf(ptr, ...)

@start_str = private constant [40 x i8] c"PE %d/%d: Starting stencil computation\0A\00"
@alloc_str = private constant [50 x i8] c"PE %d/%d: Allocated 64 bytes of symmetric memory\0A\00"
@barrier_enter_str = private constant [44 x i8] c"PE %d/%d: Entering barrier synchronization\0A\00"
@barrier_exit_str = private constant [45 x i8] c"PE %d/%d: Completed barrier synchronization\0A\00"
@complete_str = private constant [52 x i8] c"PE %d/%d: Freed symmetric memory, stencil complete\0A\00"


declare void @shmem_finalize()

declare void @shmem_free(ptr)

declare void @shmem_barrier_all()

declare ptr @shmem_malloc(i64)

declare i32 @shmem_n_pes()

declare i32 @shmem_my_pe()

declare void @shmem_init()

define i32 @main(i32 %0, ptr %1) {
  call void @shmem_init()
  %3 = call i32 @shmem_my_pe()
  %4 = call i32 @shmem_n_pes()
  %start_str_ptr = getelementptr [40 x i8], ptr @start_str, i32 0, i32 0
  %printf_call1 = call i32 (ptr, ...) @printf(ptr %start_str_ptr, i32 %3, i32 %4)
  %5 = call ptr @shmem_malloc(i64 64)
  %alloc_str_ptr = getelementptr [50 x i8], ptr @alloc_str, i32 0, i32 0
  %printf_call2 = call i32 (ptr, ...) @printf(ptr %alloc_str_ptr, i32 %3, i32 %4)
  %6 = sext i32 %3 to i64
  %7 = mul i64 %6, 4
  %8 = add i64 %7, 1
  %9 = add i64 %7, 2
  %10 = add i64 %7, 3
  call void @shmem_barrier_all()
  %11 = add i64 %7, 1
  %12 = add i64 %7, 2
  %13 = sub i32 %3, 1
  %14 = add i32 %3, 1
  %15 = sub i32 %4, 1
  %16 = icmp sgt i32 %3, 0
  %17 = icmp slt i32 %3, %15
  %18 = sitofp i32 %3 to float
  %19 = fmul float %18, 4.000000e+00
  %20 = fadd float %19, 1.000000e+00
  call void @shmem_barrier_all()
  call void @shmem_barrier_all()
  %21 = sitofp i32 %13 to float
  %22 = sitofp i32 %14 to float
  %23 = fmul float %21, 4.000000e+00
  %24 = fmul float %22, 4.000000e+00
  %25 = fadd float %23, 1.000000e+00
  %26 = fadd float %24, 1.000000e+00
  %27 = select i1 %16, float %25, float %20
  %28 = select i1 %17, float %26, float %20
  %29 = fmul float %20, 2.000000e+00
  %30 = fadd float %27, %28
  %31 = fadd float %29, %30
  %32 = fmul float %31, 2.500000e-01
  call void @shmem_barrier_all()
  call void @shmem_free(ptr %5)
  %complete_str_ptr = getelementptr [52 x i8], ptr @complete_str, i32 0, i32 0
  %printf_call3 = call i32 (ptr, ...) @printf(ptr %complete_str_ptr, i32 %3, i32 %4)
  call void @shmem_finalize()
  ret i32 0
}

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
