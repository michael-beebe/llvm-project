module {
  func.func @test_team_types() {
    %world_team = openshmem.team_world -> !openshmem.team
    %shared_team = openshmem.team_shared -> !openshmem.team
    return
  }
}
