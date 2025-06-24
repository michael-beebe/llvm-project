add_mlir_dialect_library(MLIROpenSHMEMTransforms
  CoalescePuts.cpp
  InjectNumPEsPass.cpp
  Passes.cpp

  DEPENDS
  MLIROpenSHMEMTransformsIncGen

  LINK_LIBS PUBLIC
  MLIROpenSHMEMDialect
  MLIRPass
  MLIRTransforms
) 