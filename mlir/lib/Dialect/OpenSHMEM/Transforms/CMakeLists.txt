add_mlir_dialect_library(MLIROpenSHMEMTransforms
  InjectNumPEsPass.cpp
  MessageAggregationPass.cpp
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
