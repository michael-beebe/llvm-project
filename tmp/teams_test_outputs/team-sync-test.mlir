module {
  func.func @test_team_sync() {
    openshmem.init
    %world_team = openshmem.team_world -> !openshmem.team
    openshmem.team_sync(%world_team) : !openshmem.team
    openshmem.finalize
    return
  }
}
