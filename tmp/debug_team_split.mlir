module {
  func.func @test_split() {
    openshmem.init
    %world_team = openshmem.team_world -> !openshmem.team
    %start = arith.constant 0 : i32
    %stride = arith.constant 1 : i32
    %size = arith.constant 2 : i32
    %new_team, %ret = openshmem.team_split_strided(%world_team, %start, %stride, %size) : 
      !openshmem.team, i32, i32, i32 -> !openshmem.team, !openshmem.retval
    openshmem.finalize
    return
  }
}
