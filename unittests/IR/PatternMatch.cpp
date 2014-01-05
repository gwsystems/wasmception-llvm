//===---- llvm/unittest/IR/PatternMatch.cpp - PatternMatch unit tests ----===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "llvm/ADT/STLExtras.h"
#include "llvm/Analysis/ValueTracking.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/MDBuilder.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Operator.h"
#include "llvm/IR/Type.h"
#include "llvm/Support/NoFolder.h"
#include "llvm/Support/PatternMatch.h"
#include "gtest/gtest.h"

using namespace llvm;
using namespace llvm::PatternMatch;

namespace {

struct PatternMatchTest : ::testing::Test {
  LLVMContext Ctx;
  OwningPtr<Module> M;
  Function *F;
  BasicBlock *BB;
  IRBuilder<true, NoFolder> Builder;

  PatternMatchTest()
      : M(new Module("PatternMatchTestModule", Ctx)),
        F(Function::Create(
            FunctionType::get(Type::getVoidTy(Ctx), /* IsVarArg */ false),
            Function::ExternalLinkage, "f", M.get())),
        BB(BasicBlock::Create(Ctx, "entry", F)), Builder(BB) {}
};

TEST_F(PatternMatchTest, FloatingPointOrderedMin) {
  Type *FltTy = Builder.getFloatTy();
  Value *L = ConstantFP::get(FltTy, 1.0);
  Value *R = ConstantFP::get(FltTy, 2.0);
  Value *MatchL, *MatchR;

  // Test OLT.
  EXPECT_TRUE(m_OrdFMin(m_Value(MatchL), m_Value(MatchR)).match(
      Builder.CreateSelect(Builder.CreateFCmpOLT(L, R), L, R)));
  EXPECT_EQ(L, MatchL);
  EXPECT_EQ(R, MatchR);

  // Test OLE.
  EXPECT_TRUE(m_OrdFMin(m_Value(MatchL), m_Value(MatchR)).match(
      Builder.CreateSelect(Builder.CreateFCmpOLE(L, R), L, R)));
  EXPECT_EQ(L, MatchL);
  EXPECT_EQ(R, MatchR);

  // Test no match on OGE.
  EXPECT_FALSE(m_OrdFMin(m_Value(MatchL), m_Value(MatchR)).match(
      Builder.CreateSelect(Builder.CreateFCmpOGE(L, R), L, R)));

  // Test no match on OGT.
  EXPECT_FALSE(m_OrdFMin(m_Value(MatchL), m_Value(MatchR)).match(
      Builder.CreateSelect(Builder.CreateFCmpOGT(L, R), L, R)));

  // Test match on OGE with inverted select.
  EXPECT_TRUE(m_OrdFMin(m_Value(MatchL), m_Value(MatchR)).match(
      Builder.CreateSelect(Builder.CreateFCmpOGE(L, R), R, L)));
  EXPECT_EQ(L, MatchL);
  EXPECT_EQ(R, MatchR);

  // Test match on OGT with inverted select.
  EXPECT_TRUE(m_OrdFMin(m_Value(MatchL), m_Value(MatchR)).match(
      Builder.CreateSelect(Builder.CreateFCmpOGT(L, R), R, L)));
  EXPECT_EQ(L, MatchL);
  EXPECT_EQ(R, MatchR);
}

TEST_F(PatternMatchTest, FloatingPointOrderedMax) {
  Type *FltTy = Builder.getFloatTy();
  Value *L = ConstantFP::get(FltTy, 1.0);
  Value *R = ConstantFP::get(FltTy, 2.0);
  Value *MatchL, *MatchR;

  // Test OGT.
  EXPECT_TRUE(m_OrdFMax(m_Value(MatchL), m_Value(MatchR)).match(
  Builder.CreateSelect(Builder.CreateFCmpOGT(L, R), L, R)));
  EXPECT_EQ(L, MatchL);
  EXPECT_EQ(R, MatchR);

  // Test OGE.
  EXPECT_TRUE(m_OrdFMax(m_Value(MatchL), m_Value(MatchR)).match(
  Builder.CreateSelect(Builder.CreateFCmpOGE(L, R), L, R)));
  EXPECT_EQ(L, MatchL);
  EXPECT_EQ(R, MatchR);

  // Test no match on OLE.
  EXPECT_FALSE(m_OrdFMax(m_Value(MatchL), m_Value(MatchR)).match(
  Builder.CreateSelect(Builder.CreateFCmpOLE(L, R), L, R)));

  // Test no match on OLT.
  EXPECT_FALSE(m_OrdFMax(m_Value(MatchL), m_Value(MatchR)).match(
  Builder.CreateSelect(Builder.CreateFCmpOLT(L, R), L, R)));

  // Test match on OLE with inverted select.
  EXPECT_TRUE(m_OrdFMax(m_Value(MatchL), m_Value(MatchR)).match(
  Builder.CreateSelect(Builder.CreateFCmpOLE(L, R), R, L)));
  EXPECT_EQ(L, MatchL);
  EXPECT_EQ(R, MatchR);

  // Test match on OLT with inverted select.
  EXPECT_TRUE(m_OrdFMax(m_Value(MatchL), m_Value(MatchR)).match(
  Builder.CreateSelect(Builder.CreateFCmpOLT(L, R), R, L)));
  EXPECT_EQ(L, MatchL);
  EXPECT_EQ(R, MatchR);
}

TEST_F(PatternMatchTest, FloatingPointUnorderedMin) {
  Type *FltTy = Builder.getFloatTy();
  Value *L = ConstantFP::get(FltTy, 1.0);
  Value *R = ConstantFP::get(FltTy, 2.0);
  Value *MatchL, *MatchR;

  // Test ULT.
  EXPECT_TRUE(m_UnordFMin(m_Value(MatchL), m_Value(MatchR)).match(
      Builder.CreateSelect(Builder.CreateFCmpULT(L, R), L, R)));
  EXPECT_EQ(L, MatchL);
  EXPECT_EQ(R, MatchR);

  // Test ULE.
  EXPECT_TRUE(m_UnordFMin(m_Value(MatchL), m_Value(MatchR)).match(
      Builder.CreateSelect(Builder.CreateFCmpULE(L, R), L, R)));
  EXPECT_EQ(L, MatchL);
  EXPECT_EQ(R, MatchR);

  // Test no match on UGE.
  EXPECT_FALSE(m_UnordFMin(m_Value(MatchL), m_Value(MatchR)).match(
      Builder.CreateSelect(Builder.CreateFCmpUGE(L, R), L, R)));

  // Test no match on UGT.
  EXPECT_FALSE(m_UnordFMin(m_Value(MatchL), m_Value(MatchR)).match(
      Builder.CreateSelect(Builder.CreateFCmpUGT(L, R), L, R)));

  // Test match on UGE with inverted select.
  EXPECT_TRUE(m_UnordFMin(m_Value(MatchL), m_Value(MatchR)).match(
      Builder.CreateSelect(Builder.CreateFCmpUGE(L, R), R, L)));
  EXPECT_EQ(L, MatchL);
  EXPECT_EQ(R, MatchR);

  // Test match on UGT with inverted select.
  EXPECT_TRUE(m_UnordFMin(m_Value(MatchL), m_Value(MatchR)).match(
      Builder.CreateSelect(Builder.CreateFCmpUGT(L, R), R, L)));
  EXPECT_EQ(L, MatchL);
  EXPECT_EQ(R, MatchR);
}

TEST_F(PatternMatchTest, FloatingPointUnorderedMax) {
  Type *FltTy = Builder.getFloatTy();
  Value *L = ConstantFP::get(FltTy, 1.0);
  Value *R = ConstantFP::get(FltTy, 2.0);
  Value *MatchL, *MatchR;

  // Test UGT.
  EXPECT_TRUE(m_UnordFMax(m_Value(MatchL), m_Value(MatchR)).match(
      Builder.CreateSelect(Builder.CreateFCmpUGT(L, R), L, R)));
  EXPECT_EQ(L, MatchL);
  EXPECT_EQ(R, MatchR);

  // Test UGE.
  EXPECT_TRUE(m_UnordFMax(m_Value(MatchL), m_Value(MatchR)).match(
      Builder.CreateSelect(Builder.CreateFCmpUGE(L, R), L, R)));
  EXPECT_EQ(L, MatchL);
  EXPECT_EQ(R, MatchR);

  // Test no match on ULE.
  EXPECT_FALSE(m_UnordFMax(m_Value(MatchL), m_Value(MatchR)).match(
      Builder.CreateSelect(Builder.CreateFCmpULE(L, R), L, R)));

  // Test no match on ULT.
  EXPECT_FALSE(m_UnordFMax(m_Value(MatchL), m_Value(MatchR)).match(
      Builder.CreateSelect(Builder.CreateFCmpULT(L, R), L, R)));

  // Test match on ULE with inverted select.
  EXPECT_TRUE(m_UnordFMax(m_Value(MatchL), m_Value(MatchR)).match(
      Builder.CreateSelect(Builder.CreateFCmpULE(L, R), R, L)));
  EXPECT_EQ(L, MatchL);
  EXPECT_EQ(R, MatchR);

  // Test match on ULT with inverted select.
  EXPECT_TRUE(m_UnordFMax(m_Value(MatchL), m_Value(MatchR)).match(
      Builder.CreateSelect(Builder.CreateFCmpULT(L, R), R, L)));
  EXPECT_EQ(L, MatchL);
  EXPECT_EQ(R, MatchR);
}

} // anonymous namespace.
