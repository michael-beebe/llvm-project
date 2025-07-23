module {
  func.func @test_team_splits() {
    openshmem.init
    %world_team = openshmem.team_world -> !openshmem.team
    
    // Test strided split
    %start = arith.constant 0 : i32
    %stride = arith.constant 1 : i32
    %size = arith.constant 2 : i32
    %strided_team, %ret1 = openshmem.team_split_strided(%world_team, %start, %stride, %size) : 
      !openshmem.team, i32, i32, i32 -> !openshmem.team 
    
    // Test 2D split
    %xrange = arith.constant 2 : i32
    %xaxis_team, %yaxis_team, %ret2 = openshmem.team_split_2d(%world_team, %xrange) : 
      !openshmem.team, i32 -> !openshmem.team, !openshmem.team
    
    openshmem.team_destroy(%strided_team) : !openshmem.team
    openshmem.team_destroy(%xaxis_team) : !openshmem.team
    openshmem.team_destroy(%yaxis_team) : !openshmem.team
    openshmem.finalize
    return
  }
}
