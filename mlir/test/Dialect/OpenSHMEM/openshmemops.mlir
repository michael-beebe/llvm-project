// RUN: mlir-opt %s --convert-openshmem-to-llvm --convert-func-to-llvm --reconcile-unrealized-casts | mlir-translate --mlir-to-llvmir | FileCheck %s

// Test a complete OpenSHMEM program with init/finalize operations
module {
  func.func @openshmem_program() {
    // Initialize OpenSHMEM
    openshmem.init
    
    // TODO: Add more operations as we implement them:
    // - openshmem.my_pe : i32
    // - openshmem.n_pes : i32  
    // - openshmem.put operations
    // - openshmem.get operations
    // - openshmem.fence operations
    // - openshmem.quiet operations
    // - openshmem.barrier_all operations
    
    // Finalize OpenSHMEM
    openshmem.finalize
    
    return
  }
}

// CHECK: define void @openshmem_program()
// CHECK: call void @shmem_init()
// CHECK: call void @shmem_finalize()
// CHECK: ret void
