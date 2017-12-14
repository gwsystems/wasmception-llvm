//===- MachineOperandTest.cpp ---------------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "llvm/CodeGen/MachineOperand.h"
#include "llvm/ADT/ilist_node.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/ModuleSlotTracker.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCAsmInfo.h"
#include "llvm/Support/raw_ostream.h"
#include "gtest/gtest.h"

using namespace llvm;

namespace {

TEST(MachineOperandTest, ChangeToTargetIndexTest) {
  // Creating a MachineOperand to change it to TargetIndex
  MachineOperand MO = MachineOperand::CreateImm(50);

  // Checking some precondition on the newly created
  // MachineOperand.
  ASSERT_TRUE(MO.isImm());
  ASSERT_TRUE(MO.getImm() == 50);
  ASSERT_FALSE(MO.isTargetIndex());

  // Changing to TargetIndex with some arbitrary values
  // for index, offset and flags.
  MO.ChangeToTargetIndex(74, 57, 12);

  // Checking that the mutation to TargetIndex happened
  // correctly.
  ASSERT_TRUE(MO.isTargetIndex());
  ASSERT_TRUE(MO.getIndex() == 74);
  ASSERT_TRUE(MO.getOffset() == 57);
  ASSERT_TRUE(MO.getTargetFlags() == 12);
}

TEST(MachineOperandTest, PrintRegisterMask) {
  uint32_t Dummy;
  MachineOperand MO = MachineOperand::CreateRegMask(&Dummy);

  // Checking some preconditions on the newly created
  // MachineOperand.
  ASSERT_TRUE(MO.isRegMask());
  ASSERT_TRUE(MO.getRegMask() == &Dummy);

  // Print a MachineOperand containing a RegMask. Here we check that without a
  // TRI and IntrinsicInfo we still print a less detailed regmask.
  std::string str;
  raw_string_ostream OS(str);
  MO.print(OS, /*TRI=*/nullptr, /*IntrinsicInfo=*/nullptr);
  ASSERT_TRUE(OS.str() == "<regmask ...>");
}

TEST(MachineOperandTest, PrintSubReg) {
  // Create a MachineOperand with RegNum=1 and SubReg=5.
  MachineOperand MO = MachineOperand::CreateReg(
      /*Reg=*/1, /*isDef=*/false, /*isImp=*/false, /*isKill=*/false,
      /*isDead=*/false, /*isUndef=*/false, /*isEarlyClobber=*/false,
      /*SubReg=*/5, /*isDebug=*/false, /*isInternalRead=*/false);

  // Checking some preconditions on the newly created
  // MachineOperand.
  ASSERT_TRUE(MO.isReg());
  ASSERT_TRUE(MO.getReg() == 1);
  ASSERT_TRUE(MO.getSubReg() == 5);

  // Print a MachineOperand containing a SubReg. Here we check that without a
  // TRI and IntrinsicInfo we can still print the subreg index.
  std::string str;
  raw_string_ostream OS(str);
  MO.print(OS, /*TRI=*/nullptr, /*IntrinsicInfo=*/nullptr);
  ASSERT_TRUE(OS.str() == "%physreg1.subreg5");
}

TEST(MachineOperandTest, PrintCImm) {
  LLVMContext Context;
  APInt Int(128, UINT64_MAX);
  ++Int;
  ConstantInt *CImm = ConstantInt::get(Context, Int);
  // Create a MachineOperand with an Imm=(UINT64_MAX + 1)
  MachineOperand MO = MachineOperand::CreateCImm(CImm);

  // Checking some preconditions on the newly created
  // MachineOperand.
  ASSERT_TRUE(MO.isCImm());
  ASSERT_TRUE(MO.getCImm() == CImm);
  ASSERT_TRUE(MO.getCImm()->getValue() == Int);

  // Print a MachineOperand containing a SubReg. Here we check that without a
  // TRI and IntrinsicInfo we can still print the subreg index.
  std::string str;
  raw_string_ostream OS(str);
  MO.print(OS, /*TRI=*/nullptr, /*IntrinsicInfo=*/nullptr);
  ASSERT_TRUE(OS.str() == "i128 18446744073709551616");
}

TEST(MachineOperandTest, PrintSubRegIndex) {
  // Create a MachineOperand with an immediate and print it as a subreg index.
  MachineOperand MO = MachineOperand::CreateImm(3);

  // Checking some preconditions on the newly created
  // MachineOperand.
  ASSERT_TRUE(MO.isImm());
  ASSERT_TRUE(MO.getImm() == 3);

  // Print a MachineOperand containing a SubRegIdx. Here we check that without a
  // TRI and IntrinsicInfo we can print the operand as a subreg index.
  std::string str;
  raw_string_ostream OS(str);
  ModuleSlotTracker DummyMST(nullptr);
  MachineOperand::printSubregIdx(OS, MO.getImm(), nullptr);
  ASSERT_TRUE(OS.str() == "%subreg.3");
}

TEST(MachineOperandTest, PrintCPI) {
  // Create a MachineOperand with a constant pool index and print it.
  MachineOperand MO = MachineOperand::CreateCPI(0, 8);

  // Checking some preconditions on the newly created
  // MachineOperand.
  ASSERT_TRUE(MO.isCPI());
  ASSERT_TRUE(MO.getIndex() == 0);
  ASSERT_TRUE(MO.getOffset() == 8);

  // Print a MachineOperand containing a constant pool index and a positive
  // offset.
  std::string str;
  {
    raw_string_ostream OS(str);
    MO.print(OS, /*TRI=*/nullptr, /*IntrinsicInfo=*/nullptr);
    ASSERT_TRUE(OS.str() == "%const.0 + 8");
  }

  str.clear();

  MO.setOffset(-12);

  // Print a MachineOperand containing a constant pool index and a negative
  // offset.
  {
    raw_string_ostream OS(str);
    MO.print(OS, /*TRI=*/nullptr, /*IntrinsicInfo=*/nullptr);
    ASSERT_TRUE(OS.str() == "%const.0 - 12");
  }
}

TEST(MachineOperandTest, PrintTargetIndexName) {
  // Create a MachineOperand with a target index and print it.
  MachineOperand MO = MachineOperand::CreateTargetIndex(0, 8);

  // Checking some preconditions on the newly created
  // MachineOperand.
  ASSERT_TRUE(MO.isTargetIndex());
  ASSERT_TRUE(MO.getIndex() == 0);
  ASSERT_TRUE(MO.getOffset() == 8);

  // Print a MachineOperand containing a target index and a positive offset.
  std::string str;
  {
    raw_string_ostream OS(str);
    MO.print(OS, /*TRI=*/nullptr, /*IntrinsicInfo=*/nullptr);
    ASSERT_TRUE(OS.str() == "target-index(<unknown>) + 8");
  }

  str.clear();

  MO.setOffset(-12);

  // Print a MachineOperand containing a target index and a negative offset.
  {
    raw_string_ostream OS(str);
    MO.print(OS, /*TRI=*/nullptr, /*IntrinsicInfo=*/nullptr);
    ASSERT_TRUE(OS.str() == "target-index(<unknown>) - 12");
  }
}

TEST(MachineOperandTest, PrintJumpTableIndex) {
  // Create a MachineOperand with a jump-table index and print it.
  MachineOperand MO = MachineOperand::CreateJTI(3);

  // Checking some preconditions on the newly created
  // MachineOperand.
  ASSERT_TRUE(MO.isJTI());
  ASSERT_TRUE(MO.getIndex() == 3);

  // Print a MachineOperand containing a jump-table index.
  std::string str;
  raw_string_ostream OS(str);
  MO.print(OS, /*TRI=*/nullptr, /*IntrinsicInfo=*/nullptr);
  ASSERT_TRUE(OS.str() == "%jump-table.3");
}

TEST(MachineOperandTest, PrintExternalSymbol) {
  // Create a MachineOperand with an external symbol and print it.
  MachineOperand MO = MachineOperand::CreateES("foo");

  // Checking some preconditions on the newly created
  // MachineOperand.
  ASSERT_TRUE(MO.isSymbol());
  ASSERT_TRUE(MO.getSymbolName() == StringRef("foo"));

  // Print a MachineOperand containing an external symbol and no offset.
  std::string str;
  {
    raw_string_ostream OS(str);
    MO.print(OS, /*TRI=*/nullptr, /*IntrinsicInfo=*/nullptr);
    ASSERT_TRUE(OS.str() == "$foo");
  }

  str.clear();
  MO.setOffset(12);

  // Print a MachineOperand containing an external symbol and a positive offset.
  {
    raw_string_ostream OS(str);
    MO.print(OS, /*TRI=*/nullptr, /*IntrinsicInfo=*/nullptr);
    ASSERT_TRUE(OS.str() == "$foo + 12");
  }

  str.clear();
  MO.setOffset(-12);

  // Print a MachineOperand containing an external symbol and a negative offset.
  {
    raw_string_ostream OS(str);
    MO.print(OS, /*TRI=*/nullptr, /*IntrinsicInfo=*/nullptr);
    ASSERT_TRUE(OS.str() == "$foo - 12");
  }
}

TEST(MachineOperandTest, PrintGlobalAddress) {
  LLVMContext Ctx;
  Module M("MachineOperandGVTest", Ctx);
  M.getOrInsertGlobal("foo", Type::getInt32Ty(Ctx));

  GlobalValue *GV = M.getNamedValue("foo");

  // Create a MachineOperand with a global address and a positive offset and
  // print it.
  MachineOperand MO = MachineOperand::CreateGA(GV, 12);

  // Checking some preconditions on the newly created
  // MachineOperand.
  ASSERT_TRUE(MO.isGlobal());
  ASSERT_TRUE(MO.getGlobal() == GV);
  ASSERT_TRUE(MO.getOffset() == 12);

  std::string str;
  // Print a MachineOperand containing a global address and a positive offset.
  {
    raw_string_ostream OS(str);
    MO.print(OS, /*TRI=*/nullptr, /*IntrinsicInfo=*/nullptr);
    ASSERT_TRUE(OS.str() == "@foo + 12");
  }

  str.clear();
  MO.setOffset(-12);

  // Print a MachineOperand containing a global address and a negative offset.
  {
    raw_string_ostream OS(str);
    MO.print(OS, /*TRI=*/nullptr, /*IntrinsicInfo=*/nullptr);
    ASSERT_TRUE(OS.str() == "@foo - 12");
  }
}

TEST(MachineOperandTest, PrintRegisterLiveOut) {
  // Create a MachineOperand with a register live out list and print it.
  uint32_t Mask = 0;
  MachineOperand MO = MachineOperand::CreateRegLiveOut(&Mask);

  // Checking some preconditions on the newly created
  // MachineOperand.
  ASSERT_TRUE(MO.isRegLiveOut());
  ASSERT_TRUE(MO.getRegLiveOut() == &Mask);

  std::string str;
  // Print a MachineOperand containing a register live out list without a TRI.
  raw_string_ostream OS(str);
  MO.print(OS, /*TRI=*/nullptr, /*IntrinsicInfo=*/nullptr);
  ASSERT_TRUE(OS.str() == "liveout(<unknown>)");
}

TEST(MachineOperandTest, PrintMetadata) {
  LLVMContext Ctx;
  Module M("MachineOperandMDNodeTest", Ctx);
  NamedMDNode *MD = M.getOrInsertNamedMetadata("namedmd");
  ModuleSlotTracker DummyMST(&M);
  Metadata *MDS = MDString::get(Ctx, "foo");
  MDNode *Node = MDNode::get(Ctx, MDS);
  MD->addOperand(Node);

  // Create a MachineOperand with a metadata and print it.
  MachineOperand MO = MachineOperand::CreateMetadata(Node);

  // Checking some preconditions on the newly created
  // MachineOperand.
  ASSERT_TRUE(MO.isMetadata());
  ASSERT_TRUE(MO.getMetadata() == Node);

  std::string str;
  // Print a MachineOperand containing a metadata node.
  raw_string_ostream OS(str);
  MO.print(OS, DummyMST, LLT{}, false, false, 0, /*TRI=*/nullptr,
           /*IntrinsicInfo=*/nullptr);
  ASSERT_TRUE(OS.str() == "!0");
}

TEST(MachineOperandTest, PrintMCSymbol) {
  MCAsmInfo MAI;
  MCContext Ctx(&MAI, /*MRI=*/nullptr, /*MOFI=*/nullptr);
  MCSymbol *Sym = Ctx.getOrCreateSymbol("foo");

  // Create a MachineOperand with a metadata and print it.
  MachineOperand MO = MachineOperand::CreateMCSymbol(Sym);

  // Checking some preconditions on the newly created
  // MachineOperand.
  ASSERT_TRUE(MO.isMCSymbol());
  ASSERT_TRUE(MO.getMCSymbol() == Sym);

  std::string str;
  // Print a MachineOperand containing a metadata node.
  raw_string_ostream OS(str);
  MO.print(OS, /*TRI=*/nullptr, /*IntrinsicInfo=*/nullptr);
  ASSERT_TRUE(OS.str() == "<mcsymbol foo>");
}

} // end namespace
