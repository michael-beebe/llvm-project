module {
  func.func @test_invalid_team() {
    // Try to use team operations without proper team
    %fake_pe = arith.constant 0 : i32
    // This should fail type checking
    // openshmem.team_my_pe(%fake_pe) : i32 -> i32
    return
  }
}
