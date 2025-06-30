add_mlir_dialect_library(MLIROpenSHMEMTransforms
  CoalesceGets.cpp
  CoalescePuts.cpp
  InjectNumPEsPass.cpp
  Passes.cpp

  DEPENDS
  MLIROpenSHMEMTransformsIncGen

  LINK_LIBS PUBLIC
  MLIRArithDialect
  MLIRMemRefDialect
  MLIROpenSHMEMDialect
  MLIRPass
  MLIRTransforms
) 