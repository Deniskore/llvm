#pragma once

#include "llvm/ADT/StringExtras.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/NoFolder.h"

using namespace llvm;

static bool IsPointerNull(Value *First, Value *Second) {
  return dyn_cast<ConstantPointerNull>(First) ||
         dyn_cast<ConstantPointerNull>(Second);
}

static bool IsInteger(Value *First, Value *Second) {
  return First->getType()->isIntegerTy() && Second->getType()->isIntegerTy();
}

static bool IsArray(Value *V) {
  auto GType = V->getType();
  if (GType->isPointerTy()) {
    if (GType->getPointerElementType()->isArrayTy())
      return true;
  }
  return false;
}

static bool IsFunctionInList(cl::list<std::string> &FunctionsList,
                             StringRef F) {
  for (auto &FL : FunctionsList) {
    if (F.find(FL.c_str()) != std::string::npos) {
      return true;
    }
  }
  return false;
}