; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"

declare void @shmem_finalize()

declare void @shmem_free(ptr)

declare void @shmem_float_get(ptr, ptr, i64, i32)

declare void @shmem_float_put(ptr, ptr, i64, i32)

declare ptr @shmem_malloc(i64)

declare i32 @shmem_n_pes()

declare i32 @shmem_my_pe()

declare void @shmem_init()

define i32 @test_typed(i32 %0, ptr %1) {
  call void @shmem_init()
  %3 = call i32 @shmem_my_pe()
  %4 = call i32 @shmem_n_pes()
  %5 = call ptr @shmem_malloc(i64 64)
  %6 = alloca float, i64 1, align 4
  %7 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } poison, ptr %6, 0
  %8 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %7, ptr %6, 1
  %9 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %8, i64 0, 2
  %10 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %9, i64 1, 3, 0
  %11 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %10, i64 1, 4, 0
  %12 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %11, 0
  call void @shmem_float_put(ptr %5, ptr %12, i64 1, i32 %3)
  %13 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %11, 0
  call void @shmem_float_get(ptr %13, ptr %5, i64 1, i32 %3)
  call void @shmem_free(ptr %5)
  call void @shmem_finalize()
  ret i32 0
}

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
