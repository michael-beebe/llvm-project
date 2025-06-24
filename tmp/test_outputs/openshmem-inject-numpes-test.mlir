module {
  func.func @test_inject_numpes() {
    openshmem.init
    %0 = openshmem.my_pe : i32
    %1 = openshmem.n_pes : i32
    openshmem.finalize
    return
  }
}

