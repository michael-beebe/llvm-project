add_mlir_dialect_library(MLIROpenSHMEMDialect
  OpenSHMEMOps.cpp
  OpenSHMEM.cpp

  ADDITIONAL_HEADER_DIRS
  ${MLIR_MAIN_INCLUDE_DIR}/mlir/Dialect/OpenSHMEM

  DEPENDS
  MLIROpenSHMEMIncGen
  MLIROpenSHMEMOpsIncGen
  MLIROpenSHMEMTypesIncGen
  MLIROpenSHMEMAttrsIncGen

  LINK_LIBS PUBLIC
  MLIRDialect
  MLIRIR
  MLIRMemRefDialect
  MLIRInferTypeOpInterface
  MLIRSideEffectInterfaces
  )
