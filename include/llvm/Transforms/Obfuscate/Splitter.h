//===-- Splitter.h - Instruction class definition -------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===---------------------------------------------------------------------===//
// Split and reorder basic blocks.
//===---------------------------------------------------------------------===//

#ifndef LLVM_TRANSFORMS_SPLITTER_H
#define LLVM_TRANSFORMS_SPLITTER_H

#include "llvm/IR/PassManager.h"
#include "llvm/Support/CommandLine.h"

using namespace std;

namespace llvm {
class SplitterPass : public PassInfoMixin<SplitterPass> {
public:
  PreservedAnalyses run(Function &F, FunctionAnalysisManager &AM);
};

} // end namespace llvm

#endif