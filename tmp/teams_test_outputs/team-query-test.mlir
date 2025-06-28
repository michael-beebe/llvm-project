module {
  func.func @test_team_queries() {
    openshmem.init
    %world_team = openshmem.team_world -> !openshmem.team
    
    %team_pe = openshmem.team_my_pe(%world_team) : !openshmem.team -> i32
    %team_npes = openshmem.team_n_pes(%world_team) : !openshmem.team -> i32
    
    openshmem.finalize
    return
  }
}
