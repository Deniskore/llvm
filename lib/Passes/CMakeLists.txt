add_llvm_component_library(LLVMPasses
  PassBuilder.cpp
  PassBuilderBindings.cpp
  PassPlugin.cpp
  StandardInstrumentations.cpp

  ADDITIONAL_HEADER_DIRS
  ${LLVM_MAIN_INCLUDE_DIR}/llvm
  ${LLVM_MAIN_INCLUDE_DIR}/llvm/Passes
  ${LLVM_MAIN_INCLUDE_DIR}/llvm/Transforms/Obfuscate

  DEPENDS
  intrinsics_gen

  LINK_COMPONENTS
  Obfuscate
  AggressiveInstCombine
  Analysis
  Core
  Coroutines
  IPO
  InstCombine
  ObjCARC
  Scalar
  Support
  Target
  TransformUtils
  Vectorize
  Instrumentation
  )
