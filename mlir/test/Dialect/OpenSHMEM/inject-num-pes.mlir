// RUN: mlir-opt %s --openshmem-inject-num-pes="num-pes=4" | FileCheck %s --check-prefix=CHECK-4
// RUN: mlir-opt %s --openshmem-inject-num-pes="num-pes=16" | FileCheck %s --check-prefix=CHECK-16
// RUN: mlir-opt %s --openshmem-inject-num-pes | FileCheck %s --check-prefix=CHECK-NONE

// Test InjectNumPEsPass functionality

module {
  func.func @test_inject_numpes() {
    openshmem.init
    %pe = openshmem.my_pe : i32
    %npes = openshmem.n_pes : i32
    openshmem.finalize
    return
  }
}

// CHECK-4-LABEL: module attributes {openshmem.num_pes = 4 : i32}
// CHECK-4: func.func @test_inject_numpes()
// CHECK-4: openshmem.init
// CHECK-4: openshmem.my_pe
// CHECK-4: openshmem.n_pes
// CHECK-4: openshmem.finalize

// CHECK-16-LABEL: module attributes {openshmem.num_pes = 16 : i32}
// CHECK-16: func.func @test_inject_numpes()

// CHECK-NONE-LABEL: module {
// CHECK-NONE-NOT: openshmem.num_pes
// CHECK-NONE: func.func @test_inject_numpes() 