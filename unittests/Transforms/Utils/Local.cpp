//===- Local.cpp - Unit tests for Local -----------------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "llvm/Transforms/Utils/Local.h"
#include "llvm/AsmParser/Parser.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/DIBuilder.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/Support/SourceMgr.h"
#include "gtest/gtest.h"

using namespace llvm;

TEST(Local, RecursivelyDeleteDeadPHINodes) {
  LLVMContext C;

  IRBuilder<> builder(C);

  // Make blocks
  BasicBlock *bb0 = BasicBlock::Create(C);
  BasicBlock *bb1 = BasicBlock::Create(C);

  builder.SetInsertPoint(bb0);
  PHINode    *phi = builder.CreatePHI(Type::getInt32Ty(C), 2);
  BranchInst *br0 = builder.CreateCondBr(builder.getTrue(), bb0, bb1);

  builder.SetInsertPoint(bb1);
  BranchInst *br1 = builder.CreateBr(bb0);

  phi->addIncoming(phi, bb0);
  phi->addIncoming(phi, bb1);

  // The PHI will be removed
  EXPECT_TRUE(RecursivelyDeleteDeadPHINode(phi));

  // Make sure the blocks only contain the branches
  EXPECT_EQ(&bb0->front(), br0);
  EXPECT_EQ(&bb1->front(), br1);

  builder.SetInsertPoint(bb0);
  phi = builder.CreatePHI(Type::getInt32Ty(C), 0);

  EXPECT_TRUE(RecursivelyDeleteDeadPHINode(phi));

  builder.SetInsertPoint(bb0);
  phi = builder.CreatePHI(Type::getInt32Ty(C), 0);
  builder.CreateAdd(phi, phi);

  EXPECT_TRUE(RecursivelyDeleteDeadPHINode(phi));

  bb0->dropAllReferences();
  bb1->dropAllReferences();
  delete bb0;
  delete bb1;
}

TEST(Local, RemoveDuplicatePHINodes) {
  LLVMContext C;
  IRBuilder<> B(C);

  std::unique_ptr<Function> F(
      Function::Create(FunctionType::get(B.getVoidTy(), false),
                       GlobalValue::ExternalLinkage, "F"));
  BasicBlock *Entry(BasicBlock::Create(C, "", F.get()));
  BasicBlock *BB(BasicBlock::Create(C, "", F.get()));
  BranchInst::Create(BB, Entry);

  B.SetInsertPoint(BB);

  AssertingVH<PHINode> P1 = B.CreatePHI(Type::getInt32Ty(C), 2);
  P1->addIncoming(B.getInt32(42), Entry);

  PHINode *P2 = B.CreatePHI(Type::getInt32Ty(C), 2);
  P2->addIncoming(B.getInt32(42), Entry);

  AssertingVH<PHINode> P3 = B.CreatePHI(Type::getInt32Ty(C), 2);
  P3->addIncoming(B.getInt32(42), Entry);
  P3->addIncoming(B.getInt32(23), BB);

  PHINode *P4 = B.CreatePHI(Type::getInt32Ty(C), 2);
  P4->addIncoming(B.getInt32(42), Entry);
  P4->addIncoming(B.getInt32(23), BB);

  P1->addIncoming(P3, BB);
  P2->addIncoming(P4, BB);
  BranchInst::Create(BB, BB);

  // Verify that we can eliminate PHIs that become duplicates after chaning PHIs
  // downstream.
  EXPECT_TRUE(EliminateDuplicatePHINodes(BB));
  EXPECT_EQ(3U, BB->size());
}

static std::unique_ptr<Module> parseIR(LLVMContext &C, const char *IR) {
  SMDiagnostic Err;
  std::unique_ptr<Module> Mod = parseAssemblyString(IR, Err, C);
  if (!Mod)
    Err.print("UtilsTests", errs());
  return Mod;
}

TEST(Local, ReplaceDbgDeclare) {
  LLVMContext C;

  // Original C source to get debug info for a local variable:
  // void f() { int x; }
  std::unique_ptr<Module> M = parseIR(C,
                                      R"(
      define void @f() !dbg !8 {
      entry:
        %x = alloca i32, align 4
        call void @llvm.dbg.declare(metadata i32* %x, metadata !11, metadata !DIExpression()), !dbg !13
        call void @llvm.dbg.declare(metadata i32* %x, metadata !11, metadata !DIExpression()), !dbg !13
        ret void, !dbg !14
      }
      declare void @llvm.dbg.declare(metadata, metadata, metadata)
      !llvm.dbg.cu = !{!0}
      !llvm.module.flags = !{!3, !4}
      !0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "clang version 6.0.0", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !2)
      !1 = !DIFile(filename: "t2.c", directory: "foo")
      !2 = !{}
      !3 = !{i32 2, !"Dwarf Version", i32 4}
      !4 = !{i32 2, !"Debug Info Version", i32 3}
      !8 = distinct !DISubprogram(name: "f", scope: !1, file: !1, line: 1, type: !9, isLocal: false, isDefinition: true, scopeLine: 1, isOptimized: false, unit: !0, variables: !2)
      !9 = !DISubroutineType(types: !10)
      !10 = !{null}
      !11 = !DILocalVariable(name: "x", scope: !8, file: !1, line: 2, type: !12)
      !12 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
      !13 = !DILocation(line: 2, column: 7, scope: !8)
      !14 = !DILocation(line: 3, column: 1, scope: !8)
      )");
  auto *GV = M->getNamedValue("f");
  ASSERT_TRUE(GV);
  auto *F = dyn_cast<Function>(GV);
  ASSERT_TRUE(F);
  Instruction *Inst = &F->front().front();
  auto *AI = dyn_cast<AllocaInst>(Inst);
  ASSERT_TRUE(AI);
  Inst = Inst->getNextNode()->getNextNode();
  ASSERT_TRUE(Inst);
  auto *DII = dyn_cast<DbgDeclareInst>(Inst);
  ASSERT_TRUE(DII);
  Value *NewBase = Constant::getNullValue(Type::getInt32PtrTy(C));
  DIBuilder DIB(*M);
  replaceDbgDeclare(AI, NewBase, DII, DIB, DIExpression::NoDeref, 0,
                    DIExpression::NoDeref);

  // There should be exactly two dbg.declares.
  int Declares = 0;
  for (const Instruction &I : F->front())
    if (isa<DbgDeclareInst>(I))
      Declares++;
  EXPECT_EQ(2, Declares);
}

/// Build the dominator tree for the function and run the Test.
static void runWithDomTree(
    Module &M, StringRef FuncName,
    function_ref<void(Function &F, DominatorTree *DT)> Test) {
  auto *F = M.getFunction(FuncName);
  ASSERT_NE(F, nullptr) << "Could not find " << FuncName;
  // Compute the dominator tree for the function.
  DominatorTree DT(*F);
  Test(*F, &DT);
}

TEST(Local, MergeBasicBlockIntoOnlyPred) {
  LLVMContext C;

  std::unique_ptr<Module> M = parseIR(C,
                                      R"(
      define i32 @f(i8* %str) {
      entry:
        br label %bb2.i
      bb2.i:                                            ; preds = %bb4.i, %entry
        br i1 false, label %bb4.i, label %base2flt.exit204
      bb4.i:                                            ; preds = %bb2.i
        br i1 false, label %base2flt.exit204, label %bb2.i
      bb10.i196.bb7.i197_crit_edge:                     ; No predecessors!
        br label %bb7.i197
      bb7.i197:                                         ; preds = %bb10.i196.bb7.i197_crit_edge
        %.reg2mem.0 = phi i32 [ %.reg2mem.0, %bb10.i196.bb7.i197_crit_edge ]
        br i1 undef, label %base2flt.exit204, label %base2flt.exit204
      base2flt.exit204:                                 ; preds = %bb7.i197, %bb7.i197, %bb2.i, %bb4.i
        ret i32 0
      }
      )");
  runWithDomTree(
      *M, "f", [&](Function &F, DominatorTree *DT) {
        for (Function::iterator I = F.begin(), E = F.end(); I != E;) {
          BasicBlock *BB = &*I++;
          BasicBlock *SinglePred = BB->getSinglePredecessor();
          if (!SinglePred || SinglePred == BB || BB->hasAddressTaken()) continue;
          BranchInst *Term = dyn_cast<BranchInst>(SinglePred->getTerminator());
          if (Term && !Term->isConditional())
            MergeBasicBlockIntoOnlyPred(BB, DT);
        }
        EXPECT_TRUE(DT->verify());
      });
}

TEST(Local, ConstantFoldTerminator) {
  LLVMContext C;

  std::unique_ptr<Module> M = parseIR(C,
                                      R"(
      define void @br_same_dest() {
      entry:
        br i1 false, label %bb0, label %bb0
      bb0:
        ret void
      }

      define void @br_different_dest() {
      entry:
        br i1 true, label %bb0, label %bb1
      bb0:
        br label %exit
      bb1:
        br label %exit
      exit:
        ret void
      }

      define void @switch_2_different_dest() {
      entry:
        switch i32 0, label %default [ i32 0, label %bb0 ]
      default:
        ret void
      bb0:
        ret void
      }
      define void @switch_2_different_dest_default() {
      entry:
        switch i32 1, label %default [ i32 0, label %bb0 ]
      default:
        ret void
      bb0:
        ret void
      }
      define void @switch_3_different_dest() {
      entry:
        switch i32 0, label %default [ i32 0, label %bb0
                                       i32 1, label %bb1 ]
      default:
        ret void
      bb0:
        ret void
      bb1:
        ret void
      }

      define void @switch_variable_2_default_dest(i32 %arg) {
      entry:
        switch i32 %arg, label %default [ i32 0, label %default ]
      default:
        ret void
      }

      define void @switch_constant_2_default_dest() {
      entry:
        switch i32 1, label %default [ i32 0, label %default ]
      default:
        ret void
      }

      define void @switch_constant_3_repeated_dest() {
      entry:
        switch i32 0, label %default [ i32 0, label %bb0
                                       i32 1, label %bb0 ]
       bb0:
         ret void
      default:
        ret void
      }

      define void @indirectbr() {
      entry:
        indirectbr i8* blockaddress(@indirectbr, %bb0), [label %bb0, label %bb1]
      bb0:
        ret void
      bb1:
        ret void
      }

      define void @indirectbr_repeated() {
      entry:
        indirectbr i8* blockaddress(@indirectbr_repeated, %bb0), [label %bb0, label %bb0]
      bb0:
        ret void
      }

      define void @indirectbr_unreachable() {
      entry:
        indirectbr i8* blockaddress(@indirectbr_unreachable, %bb0), [label %bb1]
      bb0:
        ret void
      bb1:
        ret void
      }
        )");

  auto CFAllTerminators = [&](Function &F, DominatorTree *DT) {
    DeferredDominance DDT(*DT);
    for (Function::iterator I = F.begin(), E = F.end(); I != E;) {
      BasicBlock *BB = &*I++;
      ConstantFoldTerminator(BB, true, nullptr, &DDT);
    }

    EXPECT_TRUE(DDT.flush().verify());
  };

  runWithDomTree(*M, "br_same_dest", CFAllTerminators);
  runWithDomTree(*M, "br_different_dest", CFAllTerminators);
  runWithDomTree(*M, "switch_2_different_dest", CFAllTerminators);
  runWithDomTree(*M, "switch_2_different_dest_default", CFAllTerminators);
  runWithDomTree(*M, "switch_3_different_dest", CFAllTerminators);
  runWithDomTree(*M, "switch_variable_2_default_dest", CFAllTerminators);
  runWithDomTree(*M, "switch_constant_2_default_dest", CFAllTerminators);
  runWithDomTree(*M, "switch_constant_3_repeated_dest", CFAllTerminators);
  runWithDomTree(*M, "indirectbr", CFAllTerminators);
  runWithDomTree(*M, "indirectbr_repeated", CFAllTerminators);
  runWithDomTree(*M, "indirectbr_unreachable", CFAllTerminators);
}

TEST(Local, SalvageDebugValuesInRecursiveInstDeletion) {
  LLVMContext C;

  std::unique_ptr<Module> M = parseIR(C,
                                      R"(
      define void @f() !dbg !8 {
      entry:
        %x = add i32 0, 1
        %y = add i32 %x, 2
        call void @llvm.dbg.value(metadata i32 %x, metadata !11, metadata !DIExpression()), !dbg !13
        call void @llvm.dbg.value(metadata i32 %y, metadata !11, metadata !DIExpression()), !dbg !13
        ret void, !dbg !14
      }
      declare void @llvm.dbg.value(metadata, metadata, metadata)
      !llvm.dbg.cu = !{!0}
      !llvm.module.flags = !{!3, !4}
      !0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "clang version 6.0.0", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !2)
      !1 = !DIFile(filename: "t2.c", directory: "foo")
      !2 = !{}
      !3 = !{i32 2, !"Dwarf Version", i32 4}
      !4 = !{i32 2, !"Debug Info Version", i32 3}
      !8 = distinct !DISubprogram(name: "f", scope: !1, file: !1, line: 1, type: !9, isLocal: false, isDefinition: true, scopeLine: 1, isOptimized: false, unit: !0, variables: !2)
      !9 = !DISubroutineType(types: !10)
      !10 = !{null}
      !11 = !DILocalVariable(name: "x", scope: !8, file: !1, line: 2, type: !12)
      !12 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
      !13 = !DILocation(line: 2, column: 7, scope: !8)
      !14 = !DILocation(line: 3, column: 1, scope: !8)
      )");
  auto *GV = M->getNamedValue("f");
  ASSERT_TRUE(GV);
  auto *F = dyn_cast<Function>(GV);
  ASSERT_TRUE(F);
  Instruction *Inst = &F->front().front();
  Inst = Inst->getNextNode();
  ASSERT_TRUE(Inst);
  bool Deleted = RecursivelyDeleteTriviallyDeadInstructions(Inst);
  ASSERT_TRUE(Deleted);

  // The debug values should have been salvaged.
  bool FoundX = false;
  bool FoundY = false;
  uint64_t X_expr[] = {dwarf::DW_OP_plus_uconst, 1, dwarf::DW_OP_stack_value};
  uint64_t Y_expr[] = {dwarf::DW_OP_plus_uconst, 1, dwarf::DW_OP_plus_uconst, 2,
                       dwarf::DW_OP_stack_value};
  for (const Instruction &I : F->front()) {
    auto DI = dyn_cast<DbgValueInst>(&I);
    if (!DI)
      continue;
    EXPECT_EQ(DI->getVariable()->getName(), "x");
    ASSERT_TRUE(cast<ConstantInt>(DI->getValue())->isZero());
    ArrayRef<uint64_t> ExprElts = DI->getExpression()->getElements();
    if (ExprElts.equals(X_expr))
      FoundX = true;
    else if (ExprElts.equals(Y_expr))
      FoundY = true;
  }
  ASSERT_TRUE(FoundX);
  ASSERT_TRUE(FoundY);
}
