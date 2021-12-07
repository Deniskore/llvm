#include "llvm/Transforms/Obfuscate/MoveConstants.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/Demangle/Demangle.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/InstIterator.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/PassInstrumentation.h"
#include "llvm/IR/PassManager.h"
#include "llvm/Transforms/Obfuscate/ObfUtils.h"
#include "llvm/Transforms/Scalar/Reg2Mem.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Transforms/Utils/ModuleUtils.h"
#include <unordered_set>
#include <vector>

using namespace llvm;
using namespace std;

#define DEBUG_TYPE "moveconstants"

STATISTIC(NumMovedConstants, "Number of constants moved");

struct UserAnalysis {
  GlobalVariable *GV;
  Instruction *I;
  ConstantDataSequential *ConstData;
  std::pair<vector<uint64_t>, uint8_t> RawData;
  IntegerType *IntType;
  Constant *Init;

  bool operator==(const UserAnalysis &UA) const {
    return (this->I == UA.I);
  }
};

struct UsersAnalysisHasher {
  std::size_t operator()(const UserAnalysis &K) const {
    using std::hash;
    using std::size_t;

    return std::hash<GlobalVariable *>{}(K.GV) ^
           std::hash<Instruction *>{}(K.I) ^
           std::hash<Constant *>{}(K.Init);
  }
};

std::pair<vector<uint64_t>, uint8_t>
GetRawData(LLVMContext &Context, ConstantDataSequential *ConstData,
           IntegerType *Type) {
  std::vector<uint64_t> data;
  for (unsigned i = 0; i < ConstData->getNumElements(); i++) {
    uint64_t Element = ConstData->getElementAsInteger(i);
    data.push_back(Element);
  }
  switch (Type->getScalarSizeInBits()) {
  case 8: {
    return std::make_pair(data, 8);
  }

  case 16: {
    return std::make_pair(data, 16);
  }

  case 32: {
    return std::make_pair(data, 32);
  }

  case 64: {
    return std::make_pair(data, 64);
  }

  default: {
    return std::make_pair(data, 8);
  }
  }
}

void HandleInstruction(UserAnalysis UA, AllocaInst *Alloca) {
  auto I = UA.I;
  auto OpCounter = 0;
  for (Value *Op : I->operands()) {
    if (GlobalVariable *G = dyn_cast<GlobalVariable>(Op->stripPointerCasts())) {
      if (G != UA.GV) {
        return;
      }
      if (auto OldGEP = dyn_cast<GEPOperator>(Op)) {
        if (OldGEP->isInBounds()) {
          IRBuilder<> Builder(UA.I);
          auto NewGEP = Builder.CreateInBoundsGEP(
              Alloca, {OldGEP->getOperand(1), OldGEP->getOperand(2)});

          Op->replaceUsesWithIf(NewGEP, [Fn = I->getFunction()](Use &U) {
            if (auto Inst = dyn_cast<Instruction>(U.getUser())) {
              if (Inst->getOpcode() == Instruction::Call)
                if (auto BB = Inst->getParent()) {
                  if (auto F = BB->getParent()) {
                    if (IsFunctionInList(FunctionsList,
                                         F->getName())) {
                      return F == Fn;
                    }
                  }
                }
            }
            return false;
          });
          OpCounter++;
        }
      }
    }
  }
}

AllocaInst *InsertInitializer(UserAnalysis &UA) {
  auto I = UA.I;
  auto Entry = &I->getFunction()->getEntryBlock();
  IRBuilder<> Builder(Entry->getFirstNonPHI());
  Builder.SetInsertPoint(Entry->getFirstNonPHI());
  auto Alloca = Builder.CreateAlloca(UA.Init->getType(),
                                     Builder.getInt32(UA.RawData.first.size()),
                                     demangle(UA.GV->getName().str()));
  auto Counter = 0;
  for (auto Element : UA.RawData.first) {
    auto Index = Builder.CreateGEP(
        Alloca, {Builder.getInt32(0), Builder.getInt32(Counter)});
    Builder.CreateStore(Builder.getInt(APInt(UA.RawData.second, Element)),
                        Index);
    Counter++;
  }
  return Alloca;
}

PreservedAnalyses MoveConstantsPass::run(Module &M, ModuleAnalysisManager &MA) {
  std::unordered_set<UserAnalysis, UsersAnalysisHasher> UA;

  for (Module::global_iterator GVI = M.global_begin(), E = M.global_end();
       GVI != E; GVI++) {
    GlobalVariable *GV = &*GVI;
    GV = dyn_cast<GlobalVariable>(GV->stripPointerCasts());
    if (GV && GV->hasInitializer() && GV->isDSOLocal() && IsArray(GV)) {
      Constant *Init = GV->getInitializer();
      if (auto ConstData = dyn_cast<ConstantDataSequential>(Init)) {
        IntegerType *Type = dyn_cast<IntegerType>(ConstData->getElementType());
        if (!Type) {
          continue;
        }
        LLVMContext &Context = M.getContext();
        auto Data = GetRawData(Context, ConstData, Type);

        for (auto &U : GV->uses()) {
          Use *UI, *UE;
          if (ConstantExpr *CE = dyn_cast<ConstantExpr>(U.getUser())) {
            if (CE->use_empty())
              continue;
            UI = &*CE->use_begin();
            UE = nullptr;
          } else if (isa<Instruction>(U.getUser())) {
            UI = &U;
            UE = UI->getNext();
          } else {
            continue;
          }

          for (; UI != UE; UI = UI->getNext()) {
            if (auto I = dyn_cast<Instruction>(UI->getUser())) {
              auto Parent = I->getParent();
              if ((I->getOpcode() == Instruction::Call) && Parent &&
                  Parent->getParent()) {

                if (IsFunctionInList(FunctionsList,
                                     I->getFunction()->getName())) {
                  auto Data = UserAnalysis{
                      GV,        I,
                      ConstData, GetRawData(I->getContext(), ConstData, Type),
                      Type,      Init,
                  };

                  UA.insert(Data);
                }
              }
            }
          }
        }
      }
    }
  }

  for (auto U : UA) {
    HandleInstruction(U, InsertInitializer(U));
    NumMovedConstants++;
  }

  return PreservedAnalyses::none();
}
