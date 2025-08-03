; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"

@hello_str = private constant [24 x i8] c"Hello from PE %d of %d\0A\00"

declare void @shmem_finalize()

declare i32 @shmem_n_pes()

declare i32 @shmem_my_pe()

declare void @shmem_init()
declare i32 @printf(ptr, ...)

define i32 @main(i32 %0, ptr %1) {
  call void @shmem_init()
  %3 = call i32 @shmem_my_pe()
  %4 = call i32 @shmem_n_pes()
  %5 = getelementptr [24 x i8], ptr @hello_str, i32 0, i32 0
  %6 = call i32 (ptr, ...) @printf(ptr %5, i32 %3, i32 %4)
  call void @shmem_finalize()
  ret i32 0
}

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
