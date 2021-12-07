#include "llvm/Transforms/Obfuscate/InstSweller.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/Transforms/Obfuscate/ObfBuilder.h"
#include "llvm/Transforms/Obfuscate/ObfUtils.h"
#include "llvm/Transforms/Obfuscate/XorShift.h"
#include "llvm/Transforms/Scalar/Reg2Mem.h"
#include <string>

using namespace llvm;
using namespace std;

#define DEBUG_TYPE "instsweller"

STATISTIC(NumSwelled, "Number of instructions swelled");

extern cl::list<std::string> FunctionsList;

PreservedAnalyses InstSwellerPass::run(Function &F,
                                       FunctionAnalysisManager &AM) {

  if (!IsFunctionInList(FunctionsList, F.getName())) {
    return PreservedAnalyses::all();
  }

  ObfBuilder ObfBuilder(F.getContext());
  XorShift RND;
  std::vector<Instruction *> Insts;

  for (BasicBlock &BB : F) {
    for (Instruction &I : BB) {
      if (I.getNumOperands() >= 2) {
        Insts.push_back(&I);
      }
    }
  }

  for (auto I : Insts) {
    Value *First = I->getOperand(0);
    Value *Second = I->getOperand(1);

    switch (I->getOpcode()) {
    case Instruction::GetElementPtr: {
      if (I->getNumOperands() == 3) {
        ConstantInt *CI = dyn_cast<ConstantInt>(I->getOperand(2));
        AllocaInst *Alloca = dyn_cast<AllocaInst>(I->getOperand(0));
        if (CI && Alloca && Alloca->getAllocatedType()->isArrayTy() &&
            Alloca->getAllocatedType()->getArrayNumElements() > 1) {
          IRBuilder<> Builder(I);
          Builder.SetInsertPoint(I);
          auto Alloc = Builder.CreateAlloca(CI->getType());
          auto RndValue = RND.next();
          auto CRndValue = ConstantInt::get(CI->getType(),
                                            APInt(CI->getBitWidth(), RndValue));
          Constant *Constant = ConstantInt::get(
              CI->getType(),
              APInt(CI->getBitWidth(), RndValue ^ CI->getZExtValue()));
          Builder.CreateStore(Constant, Alloc, true);
          auto LoadInst = Builder.CreateLoad(Alloc);
          ObfBuilder.SetInsertPoint(&*Builder.GetInsertPoint());
          CI->replaceAllUsesWith(ObfBuilder.CreateXor(LoadInst, CRndValue));
          NumSwelled++;
        }
      }
      break;
    }

    case Instruction::Add: {
      break;
    }

    case Instruction::Sub: {
      break;
    }

    case Instruction::And: {
      ObfBuilder.SetInsertPoint(I);
      I->replaceAllUsesWith(ObfBuilder.CreateAnd(First, Second));
      I->eraseFromParent();
      NumSwelled++;
      break;
    }

    case Instruction::Or: {
      ObfBuilder.SetInsertPoint(I);
      I->replaceAllUsesWith(ObfBuilder.CreateOr(First, Second));
      I->eraseFromParent();
      NumSwelled++;
      break;
    }

    case Instruction::Xor: {
      ObfBuilder.SetInsertPoint(I);
      I->replaceAllUsesWith(ObfBuilder.CreateXor(First, Second));
      I->eraseFromParent();
      NumSwelled++;
      break;
    }

    case Instruction::ICmp: {
      auto CMP = dyn_cast<CmpInst>(I);
      auto predicate = CMP->getPredicate();
      if (predicate == CmpInst::Predicate::ICMP_EQ ||
          predicate == CmpInst::Predicate::ICMP_NE) {
        Value *NewCMP = nullptr;
        IRBuilder<> Builder(I);
        Builder.SetInsertPoint(I);
        ObfBuilder.SetInsertPoint(I);
        if (IsInteger(First, Second)) {
          auto Xor = ObfBuilder.CreateXor(First, Second);
          auto Zero = APInt(Xor->getType()->getIntegerBitWidth(), 0);
          if (predicate == CmpInst::Predicate::ICMP_EQ) {
            NewCMP = Builder.CreateCmp(CmpInst::Predicate::ICMP_EQ, Xor,
                                       Builder.getInt(Zero));
          } else if (predicate == CmpInst::Predicate::ICMP_NE) {
            NewCMP = Builder.CreateCmp(CmpInst::Predicate::ICMP_NE, Xor,
                                       Builder.getInt(Zero));
          }
          I->replaceAllUsesWith(NewCMP);
          I->eraseFromParent();
          NumSwelled++;
        }
      }
      break;
    }

    default:
      break;
    }
  }

  return PreservedAnalyses::none();
}
