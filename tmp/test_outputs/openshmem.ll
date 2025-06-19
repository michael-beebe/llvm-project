; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"

declare void @free(ptr)

declare ptr @malloc(i64)

declare i32 @shmem_finalize()

declare i32 @shmem_free(ptr)

declare void @shmem_get(ptr, ptr, i64, i32)

declare void @shmem_put(ptr, ptr, i64, i32)

declare ptr @shmem_malloc(i64)

declare i32 @shmem_n_pes()

declare i32 @shmem_my_pe()

declare i32 @shmem_init()

define void @main() {
  %1 = call i32 @shmem_init()
  %2 = call i32 @shmem_my_pe()
  %3 = call i32 @shmem_n_pes()
  %4 = call ptr @shmem_malloc(i64 40)
  %5 = call ptr @malloc(i64 40)
  %6 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } poison, ptr %5, 0
  %7 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %6, ptr %5, 1
  %8 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %7, i64 0, 2
  %9 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %8, i64 10, 3, 0
  %10 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %9, i64 1, 4, 0
  %11 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %10, 0
  call void @shmem_put(ptr %4, ptr %11, i64 10, i32 1)
  call void @shmem_get(ptr %11, ptr %4, i64 10, i32 1)
  %12 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %10, 0
  call void @free(ptr %12)
  %13 = call i32 @shmem_free(ptr %4)
  %14 = call i32 @shmem_finalize()
  ret void
}

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
