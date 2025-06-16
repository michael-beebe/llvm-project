add_mlir_conversion_library(MLIROpenSHMEMToLLVM
  OpenSHMEMToLLVM.cpp

  ADDITIONAL_HEADER_DIRS
  ${MLIR_MAIN_INCLUDE_DIR}/mlir/Conversion/OpenSHMEMToLLVM

  DEPENDS
  MLIRConversionPassIncGen

  LINK_COMPONENTS
  Core

  LINK_LIBS PUBLIC
  MLIRArithDialect
  MLIRLLVMCommonConversion
  MLIRLLVMDialect
  MLIROpenSHMEMDialect
  MLIRPass
  MLIRTransforms
) 