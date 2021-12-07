#include "llvm/Transforms/Obfuscate/Indirector.h"
#include "llvm/Transforms/Obfuscate/ObfUtils.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/InstIterator.h"
#include "llvm/IR/Instructions.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Transforms/Utils/ModuleUtils.h"
#include "llvm/Transforms/Scalar/Reg2Mem.h"
#include <unordered_map>
#include <vector>

using namespace llvm;
using namespace std;

#define DEBUG_TYPE "indirector"

STATISTIC(NumIndirected, "Number of BranchInst replaced");

extern cl::list<std::string> FunctionsList;

PreservedAnalyses IndirectorPass::run(Function &F,
                                      FunctionAnalysisManager &AM) {
  if (!IsFunctionInList(FunctionsList, F.getName())) {
    return PreservedAnalyses::all();
  }

  std::unordered_map<BasicBlock *, uint64_t> BBmap;

  vector<Constant *> BBs;
  vector<BranchInst *> BranchInsts;

  uint64_t Counter = 0;
  for (auto &BB : F) {
    if (!BB.isEntryBlock()) {
      auto address = BlockAddress::get(&BB);
      BBs.push_back(address);
      BBmap.insert({&BB, Counter});
      Counter++;
    }
  }

  auto Entry = &F.getEntryBlock();
  IRBuilder<> Builder(Entry);
  ArrayType *AT = ArrayType::get(Builder.getInt8PtrTy(), BBs.size());
  Builder.SetInsertPoint(Entry, Entry->getFirstInsertionPt());

  Value *Alloca = Builder.CreateAlloca(AT, Builder.getInt32(BBs.size()));
  Counter = 0;
  for (auto I : BBs) {
    auto Index = Builder.CreateGEP(
        Alloca->getType()->getScalarType()->getPointerElementType(), Alloca,
        {Builder.getInt32(0), Builder.getInt32(Counter)});
    Builder.CreateStore(I, Index, true);
    Counter++;
  }

  for (auto &I : instructions(F)) {
    if (auto BrInst = dyn_cast<BranchInst>(&I)) {
      BranchInsts.push_back(BrInst);
    }
  }

  IndirectBrInst *IndirBranch = nullptr;
  Value *Index = nullptr;

  for (auto BrInst : BranchInsts) {
    NumIndirected++;
    Builder.SetInsertPoint(BrInst);
    vector<BasicBlock *> Destinations;

    if (BrInst->isConditional()) {
      Destinations.push_back(BrInst->getSuccessor(1));
      Destinations.push_back(BrInst->getSuccessor(0));

      vector<Constant *> BBAddresses;
      for (auto BB : Destinations) {
        BBAddresses.push_back(BlockAddress::get(BB));
      }

      ArrayType *ATC =
          ArrayType::get(Builder.getInt8PtrTy(), Destinations.size());

      Value *AllocaTwo =
          Builder.CreateAlloca(ATC, Builder.getInt32(Destinations.size()));

      auto ElementType =
          AllocaTwo->getType()->getScalarType()->getPointerElementType();

      Counter = 0;
      for (auto I : Destinations) {
        auto BlockIndex =
            Builder.CreateGEP(ElementType, AllocaTwo,
                              {Builder.getInt32(0), Builder.getInt32(Counter)});
        Builder.CreateStore(BlockAddress::get(I), BlockIndex, true);
        Counter++;
      }

      Value *Condition = BrInst->getCondition();
      Index = Builder.CreateZExt(Condition, Builder.getInt32Ty());

      Value *GEP = Builder.CreateGEP(ElementType, AllocaTwo,
                                     {Builder.getInt32(0), Index});
      LoadInst *LoadIndirectAddr =
          Builder.CreateLoad(GEP->getType()->getPointerElementType(), GEP,
                             "load_indirect_cond_addr");

      IndirBranch =
          Builder.CreateIndirectBr(LoadIndirectAddr, Destinations.size());
      for (BasicBlock *BB : Destinations) {
        IndirBranch->addDestination(BB);
      }

    } else {
      auto ElementType =
          Alloca->getType()->getScalarType()->getPointerElementType();
      Index = Builder.getInt32(BBmap[BrInst->getSuccessor(0)]);
      Value *GEP =
          Builder.CreateGEP(ElementType, Alloca, {Builder.getInt32(0), Index});
      LoadInst *LoadIndirectAddr = Builder.CreateLoad(
          GEP->getType()->getPointerElementType(), GEP, "load_indirect_addr");

      IndirBranch =
          Builder.CreateIndirectBr(LoadIndirectAddr, Destinations.size());
      IndirBranch->addDestination(BrInst->getSuccessor(0));
    }
    BrInst->replaceAllUsesWith(IndirBranch);
    BrInst->eraseFromParent();
  }

  return PreservedAnalyses::none();
}