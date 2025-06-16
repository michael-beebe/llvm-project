# TODO: Uncomment when transform passes are implemented
# add_mlir_library(MLIROpenSHMEMTransforms
#   # Add transform passes here as they are implemented
#   # OpenSHMEMCoalesce.cpp
# 
#   ADDITIONAL_HEADER_DIRS
#   ${MLIR_MAIN_INCLUDE_DIR}/mlir/Dialect/OpenSHMEM
# 
#   DEPENDS
#   MLIROpenSHMEMIncGen
#   MLIROpenSHMEMOpsIncGen
#   MLIROpenSHMEMTypesIncGen
#   MLIROpenSHMEMAttrsIncGen
# 
#   LINK_LIBS PUBLIC
#   MLIROpenSHMEMDialect
#   MLIRPass
#   MLIRTransforms
#   )
