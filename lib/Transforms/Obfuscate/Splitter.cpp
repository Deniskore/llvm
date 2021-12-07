#include "llvm/ADT/Statistic.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/InstIterator.h"
#include "llvm/IR/Instructions.h"
#include "llvm/Transforms/Obfuscate/XorShift.h"
#include "llvm/Transforms/Obfuscate/ObfUtils.h"
#include "llvm/Transforms/Obfuscate/Splitter.h"
#include "llvm/Transforms/Scalar/Reg2Mem.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Transforms/Utils/ModuleUtils.h"
#include <unordered_set>
#include <vector>

using namespace llvm;
using namespace std;

#define DEBUG_TYPE "bbsplitter"

STATISTIC(NumSplitted, "Number of BBs splitted");

extern cl::list<std::string> FunctionsList;

static cl::opt<unsigned>
    SplitterBlockSizeMin("bbsplitter-block-size-min", cl::init(6),
                         cl::NotHidden,
                         cl::desc("The minimum size of the splitted block"));

static cl::opt<unsigned>
    SplitterBlockSizeMax("bbsplitter-block-size-max", cl::init(10),
                         cl::NotHidden,
                         cl::desc("The maximum size of the splitted block"));

bool isBBValid(BasicBlock *BB) {
  return BB->size() > SplitterBlockSizeMin && BB->getTerminator() && !BB->isEHPad() &&
         !BB->isLandingPad();
}

Instruction *GetInstruction(uint32_t pos, BasicBlock *BB) {
  auto Counter = 0;
  for (BasicBlock::iterator I = BB->begin(), e = BB->end(); I != e; ++I) {
    if (Counter == pos)
      return &(*I);
    Counter++;
  }
  return nullptr;
}

void SplitToSmaller(Function &F, XorShift &RND) {
  list<BasicBlock *> BBs;

  for (auto &BB : F) {
    if (isBBValid(&BB))
      BBs.push_back(&BB);
  }

  for (auto BB : BBs) {
    for (auto I = BB->begin(), IE = BB->end(); I != IE; ++I) {
      auto SplitPosition =
          RND.in_range(SplitterBlockSizeMin, SplitterBlockSizeMax);
      if (BB->size() > SplitPosition &&
          (BB->size() / 2) > SplitterBlockSizeMax) {
        auto SplitOnInst = GetInstruction(SplitPosition, BB);
        if (SplitOnInst) {
          NumSplitted++;
          BBs.push_back(BB->splitBasicBlock(SplitOnInst, "split"));
          break;
        }
      }
    }
  }
}

void RandomReorder(Function &F, XorShift &RND) {
  vector<BasicBlock *> BBs;

  for (auto &BB : F) {
    if (!BB.isEntryBlock())
      BBs.push_back(&BB);
  }

  for (auto BB : BBs) {
    auto First = RND.in_range(0, BBs.size());
    auto Second = RND.in_range(0, BBs.size());
    if (RND.in_range(0, 2))
      BBs[First]->moveBefore(BBs[Second]);
    else {
      BBs[First]->moveAfter(BBs[Second]);
    }
    Second = RND.in_range(0, BBs.size());
    if (RND.in_range(0, 2) && BB != BBs[Second])
      BB->moveAfter(BBs[Second]);
    else {
      BB->moveBefore(BBs[Second]);
    }
  }
}

PreservedAnalyses SplitterPass::run(Function &F, FunctionAnalysisManager &AM) {
  if (!IsFunctionInList(FunctionsList, F.getName())) {
    return PreservedAnalyses::all();
  }

  XorShift RND;

  SplitToSmaller(F, RND);
  RandomReorder(F, RND);

  AM.invalidate(F, PreservedAnalyses::none());

  return PreservedAnalyses::none();
}