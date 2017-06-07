//===--- GlobalsModRefTest.cpp - Mixed TBAA unit tests --------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "llvm/Analysis/GlobalsModRef.h"
#include "llvm/AsmParser/Parser.h"
#include "llvm/Support/SourceMgr.h"
#include "gtest/gtest.h"

using namespace llvm;

TEST(GlobalsModRef, OptNone) {
  StringRef Assembly = R"(
    define void @f1() optnone {
      ret void
    }
    define void @f2() optnone readnone {
      ret void
    }
    define void @f3() optnone readonly {
      ret void
    }
  )";

  LLVMContext Context;
  SMDiagnostic Error;
  auto M = parseAssemblyString(Assembly, Error, Context);
  ASSERT_TRUE(M) << "Bad assembly?";

  const auto &funcs = M->functions();
  auto I = funcs.begin();
  ASSERT_NE(I, funcs.end());
  const Function &F1 = *I;
  ASSERT_NE(++I, funcs.end());
  const Function &F2 = *I;
  ASSERT_NE(++I, funcs.end());
  const Function &F3 = *I;
  EXPECT_EQ(++I, funcs.end());

  Triple Trip(M->getTargetTriple());
  TargetLibraryInfoImpl TLII(Trip);
  TargetLibraryInfo TLI(TLII);
  llvm::CallGraph CG(*M);

  auto AAR = GlobalsAAResult::analyzeModule(*M, TLI, CG);

  EXPECT_EQ(FMRB_UnknownModRefBehavior, AAR.getModRefBehavior(&F1));
  EXPECT_EQ(FMRB_DoesNotAccessMemory, AAR.getModRefBehavior(&F2));
  EXPECT_EQ(FMRB_OnlyReadsMemory, AAR.getModRefBehavior(&F3));
}
