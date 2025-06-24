// RUN: mlir-opt %s --openshmem-inject-num-pes | FileCheck %s

// Test that the InjectNumPEsPass doesn't add the attribute when no option is provided

// CHECK: module {
// CHECK-NOT: openshmem.num_pes
module {
  func.func @test_no_inject() {
    // Initialize OpenSHMEM
    openshmem.init
    
    // Get PE information
    %pe = openshmem.my_pe : i32
    %npes = openshmem.n_pes : i32
    
    // Finalize OpenSHMEM
    openshmem.finalize
    return
  }
} 