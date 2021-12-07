//===-- MoveConstants.h - Instruction class definition -------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===---------------------------------------------------------------------===//
// Split and reorder basic blocks.
//===---------------------------------------------------------------------===//

#ifndef LLVM_TRANSFORMS_MOVECONSTANTS_H
#define LLVM_TRANSFORMS_MOVECONSTANTS_H

#include "llvm/IR/PassManager.h"
#include "llvm/Support/CommandLine.h"

using namespace std;

namespace llvm {
class MoveConstantsPass : public PassInfoMixin<MoveConstantsPass> {
public:
  PreservedAnalyses run(Module &M, ModuleAnalysisManager &MA);
};

} // end namespace llvm

#endif