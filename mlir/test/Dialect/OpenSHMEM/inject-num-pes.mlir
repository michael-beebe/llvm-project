// RUN: mlir-opt %s --openshmem-inject-num-pes="num-pes=4" | FileCheck %s

// Test that the InjectNumPEsPass correctly adds the openshmem.num_pes attribute

// CHECK: module attributes {openshmem.num_pes = 4 : i32}
module {
  func.func @test_inject_num_pes() {
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