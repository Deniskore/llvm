//===-- InstSweller.h - Instruction class definition -------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===---------------------------------------------------------------------===//
// Instruction swelling.
//===---------------------------------------------------------------------===//

#ifndef LLVM_TRANSFORMS_SWELLER_H
#define LLVM_TRANSFORMS_SWELLER_H

#include "llvm/IR/PassManager.h"
#include "llvm/Support/CommandLine.h"


using namespace std;

namespace llvm {
class InstSwellerPass : public PassInfoMixin<InstSwellerPass> {
public:
  PreservedAnalyses run(Function &F, FunctionAnalysisManager &AM);
};

} // end namespace llvm

#endif