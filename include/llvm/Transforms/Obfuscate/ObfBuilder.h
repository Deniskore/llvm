//===-- ObfBuilder.h - Instruction class definition -------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===---------------------------------------------------------------------===//
// Build obfuscated Nand/Nor code
//===---------------------------------------------------------------------===//
#pragma once
#include "XorShift.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/NoFolder.h"
#include <memory>

using namespace llvm;

class ObfBuilder {
public:
  ObfBuilder(LLVMContext &context) {
    Builder = std::make_unique<IRBuilder<NoFolder>>(context);
  }
  ~ObfBuilder() = default;

  Value *CreateNot(Value *a);
  Value *CreateAnd(Value *a, Value *b);
  Value *CreateOr(Value *a, Value *b);
  Value *CreateXor(Value *a, Value *b);
  Value *CreateInc(Value *a);
  Value *CreateDec(Value *a);

  void SetInsertPoint(Instruction *i);
  BasicBlock::iterator GetInsertPoint();

private:
  Value *Not(Value *a);
  Value *Or(Value *a, Value *b);
  Value *And(Value *a, Value *b);
  Value *Nor(Value *a, Value *b);
  Value *Nand(Value *a, Value *b);
  Value *Xor(Value *a, Value *b);

  Value *Nand_1(Value *a, Value *b);
  Value *Nand_2(Value *a, Value *b);
  Value *Nand_3(Value *a, Value *b);
  Value *Nand_4(Value *a, Value *b);
  Value *Nand_5(Value *a, Value *b);

  Value *Nor_1(Value *a, Value *b);
  Value *Nor_2(Value *a, Value *b);
  Value *Nor_3(Value *a, Value *b);
  Value *Nor_4(Value *a, Value *b);
  Value *Nor_5(Value *a, Value *b);

  Value *Nand_r(Value *a, Value *b);
  Value *Nor_r(Value *a, Value *b);
  Value *Not_r(Value *a);
  Value *And_r(Value *a, Value *b);
  Value *Or_r(Value *a, Value *b);
  Value *Xor_r(Value *a, Value *b);
  Value *Inc_r(Value *a);
  Value *Dec_r(Value *a);

private:
  std::unique_ptr<IRBuilder<NoFolder>> Builder;
  XorShift Rnd;
};

Value *ObfBuilder::CreateNot(Value *a) { return Not_r(a); }

Value *ObfBuilder::CreateAnd(Value *a, Value *b) { return And_r(a, b); }

Value *ObfBuilder::CreateOr(Value *a, Value *b) { return Or_r(a, b); }

Value *ObfBuilder::CreateXor(Value *a, Value *b) { return Xor_r(a, b); }

Value *ObfBuilder::CreateInc(Value *a) { return Inc_r(a); }

Value *ObfBuilder::CreateDec(Value *a) { return Dec_r(a); }

Value *ObfBuilder::Not(Value *a) { return Builder->CreateNot(a); }

Value *ObfBuilder::Or(Value *a, Value *b) { return Builder->CreateOr(a, b); }

Value *ObfBuilder::And(Value *a, Value *b) { return Builder->CreateAnd(a, b); }

//! Not (a Or b)
Value *ObfBuilder::Nor(Value *a, Value *b) { return Not(Or(a, b)); }

//! Not (a And b)
Value *ObfBuilder::Nand(Value *a, Value *b) { return Not(And(a, b)); }

//! (a Nand (a Nand b)) Nand (b Nand (a Nand b))
Value *ObfBuilder::Xor(Value *a, Value *b) {
  return Nand(Nand(a, Nand(a, b)), (Nand(b, Nand(a, b))));
}

//! (Not a) Or (Not b)
Value *ObfBuilder::Nand_1(Value *a, Value *b) { return Or(Not(a), Not(b)); }

//! Not(a And b)
Value *ObfBuilder::Nand_2(Value *a, Value *b) { return Not(And(a, b)); }

//! Not ((Not a) Nor (Not b))
Value *ObfBuilder::Nand_3(Value *a, Value *b) {
  return Not(Nor(Not(a), Not(b)));
}

//! (Not a) Or (Not b)
Value *ObfBuilder::Nand_4(Value *a, Value *b) { return Or(Not(a), Not(b)); }

//! ((Not a) And b) Xor (Not b)
Value *ObfBuilder::Nand_5(Value *a, Value *b) {
  return Xor(And(Not(a), b), Not(b));
}

//! (Not a) And (Not b)
Value *ObfBuilder::Nor_1(Value *a, Value *b) { return And(Not(a), Not(b)); }

//! Not(a Xor b Xor (a And b))
Value *ObfBuilder::Nor_2(Value *a, Value *b) {
  return Not(Xor(Xor(a, b), And(a, b)));
}

//! Not((Not a) Nand (Not b))
Value *ObfBuilder::Nor_3(Value *a, Value *b) {
  return Not(Nand(Not(a), Not(b)));
}

//! (Not a) And (Not b)
Value *ObfBuilder::Nor_4(Value *a, Value *b) { return And(Not(a), Not(b)); }

//! Not(a Or b)
Value *ObfBuilder::Nor_5(Value *a, Value *b) { return Not(Or(a, b)); }

Value *ObfBuilder::Nand_r(Value *a, Value *b) {
  switch (Rnd.next() % 5) {
  case 0:
    return Nand_1(a, b);
  case 1:
    return Nand_2(a, b);
  case 2:
    return Nand_3(a, b);
  case 3:
    return Nand_4(a, b);
  case 4:
    return Nand_5(a, b);
  default:
    return Nand_1(a, b);
  }
}

Value *ObfBuilder::Nor_r(Value *a, Value *b) {
  switch (Rnd.next() % 5) {
  case 0:
    return Nor_1(a, b);
  case 1:
    return Nor_2(a, b);
  case 2:
    return Nor_3(a, b);
  case 3:
    return Nor_4(a, b);
  case 4:
    return Nor_5(a, b);
  default:
    return Nor_1(a, b);
  }
}

Value *ObfBuilder::Not_r(Value *a) {
  switch (Rnd.next() % 10) {
  case 0:
    return Nand_1(a, a);
  case 1:
    return Nand_2(a, a);
  case 2:
    return Nand_3(a, a);
  case 3:
    return Nand_4(a, a);
  case 4:
    return Nand_5(a, a);
  case 5:
    return Nor_1(a, a);
  case 6:
    return Nor_2(a, a);
  case 7:
    return Nor_3(a, a);
  case 8:
    return Nor_4(a, a);
  case 9:
    return Nor_5(a, a);
  default:
    return Nand_1(a, a);
  }
}

Value *ObfBuilder::And_r(Value *a, Value *b) {
  switch (Rnd.next() % 5) {
  // (Not a) Nor (Not b)
  case 0:
    return Nor_r(Not_r(a), Not_r(b));
  // Not (a Nand b)
  case 1:
    return Not_r(Nand_r(a, b));
  // Not((Not a) Or (Not b))
  case 2:
    return Not_r(Or(Not_r(a), Not_r(b)));
  // (a Xor (Not b)) And a
  case 3:
    return And(a, Xor(a, Not_r(b)));
    // Not((Not a) Or (Not b))
  case 4:
    return Not(Or(Not_r(a), Not_r(b)));

  default:
    return Nor_r(Not_r(a), Not_r(b));
  }
}

Value *ObfBuilder::Or_r(Value *a, Value *b) {
  switch (Rnd.next() % 5) {
  // a Xor b Xor (a And b)
  case 0:
    return Xor(Xor(a, b), And_r(a, b));
  // Not (a Nor b)
  case 1:
    return Not_r(Nor_r(a, b));
  // (Not a) Nand (Not b)
  case 2:
    return Nand_r(Not_r(a), Not_r(b));
  // Not((Not a) And (Not b))
  case 3:
    return Not_r(And_r(Not_r(a), Not_r(b)));
  // b Xor (a And (Not b))
  case 4:
    return Xor(b, And_r(a, Not_r(b)));

  default:
    return Xor(Xor(a, b), And_r(a, b));
  }
}

Value *ObfBuilder::Xor_r(Value *a, Value *b) {
  switch (Rnd.next() % 6) {
  // (a And (Not b)) Or ((Not a) And b)
  case 0:
    return Or_r(And_r(a, (Not_r(b))), And_r(Not_r(a), b));
  // ((Not a) Or (Not b)) And (a Or b)
  case 1:
    return And(Or_r(Not_r(a), Not_r(b)), Or_r(a, b));
  // ((Not a) Nor (Not b)) Nor (a Nor b)
  case 2:
    return Nor_r(Nor_r(Not_r(a), Not_r(b)), Nor_r(a, b));
  //  (a Nand (a Nand b)) Nand (b Nand (a Nand b))
  case 3:
    return Nand_r(Nand_r(a, Nand_r(a, b)), Nand_r(b, Nand_r(a, b)));
  // (Not (a And b)) And (Not ((Not a) And (Not b)))
  case 4:
    return And_r((Not_r(And_r(a, b))), Not_r(And_r(Not_r(a), Not_r(b))));
  // (Not ((Not a) Or b)) Or (Not (a Or (Not b)))
  case 5:
    return Or_r(Not_r(Or_r(Not_r(a), b)), (Not_r(Or_r(a, Not_r(b)))));

  default:
    return Or_r(And_r(a, (Not_r(b))), And_r(Not_r(a), b));
  }
}

Value *ObfBuilder::Inc_r(Value *a) {
  auto bitWidth = a->getType()->getIntegerBitWidth();
  auto zero = ConstantInt::get(a->getContext(), APInt(bitWidth, 0));

  return Builder->CreateSub(zero, Not_r(a));
}

Value *ObfBuilder::Dec_r(Value *a) {
  auto bitWidth = a->getType()->getIntegerBitWidth();
  auto zero = ConstantInt::get(a->getContext(), APInt(bitWidth, 0));
  return Not_r(Builder->CreateSub(zero, a));
}

void ObfBuilder::SetInsertPoint(Instruction *i) { Builder->SetInsertPoint(i); }

BasicBlock::iterator ObfBuilder::GetInsertPoint() {
  return Builder->GetInsertPoint();
}