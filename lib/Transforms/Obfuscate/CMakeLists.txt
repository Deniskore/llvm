add_llvm_component_library(LLVMObfuscate
  InstSweller.cpp
  Splitter.cpp
  Indirector.cpp
  MoveConstants.cpp

  ADDITIONAL_HEADER_DIRS
  ${LLVM_MAIN_INCLUDE_DIR}/llvm/Transforms/Obfuscate
  ${LLVM_MAIN_INCLUDE_DIR}/llvm/Transforms/Scalars

  DEPENDS
  intrinsics_gen

  LINK_COMPONENTS
  Analysis
  Core
  Support
  TransformUtils
  Scalar
  ScalarOpts
  )
