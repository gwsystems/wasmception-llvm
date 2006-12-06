//===-- ARMAsmPrinter.cpp - ARM LLVM assembly writer ----------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file was developed by the "Instituto Nokia de Tecnologia" and
// is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains a printer that converts from our internal representation
// of machine-dependent LLVM code to GAS-format ARM assembly language.
//
//===----------------------------------------------------------------------===//

#include "ARM.h"
#include "ARMInstrInfo.h"
#include "llvm/Constants.h"
#include "llvm/DerivedTypes.h"
#include "llvm/Module.h"
#include "llvm/CodeGen/AsmPrinter.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineConstantPool.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/Target/TargetAsmInfo.h"
#include "llvm/Target/TargetData.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/Support/Mangler.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/ADT/StringExtras.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/MathExtras.h"
#include <cctype>
#include <iostream>
using namespace llvm;

namespace {
  Statistic<> EmittedInsts("asm-printer", "Number of machine instrs printed");

  static const char *ARMCondCodeToString(ARMCC::CondCodes CC) {
    switch (CC) {
    default: assert(0 && "Unknown condition code");
    case ARMCC::EQ:  return "eq";
    case ARMCC::NE:  return "ne";
    case ARMCC::CS:  return "cs";
    case ARMCC::CC:  return "cc";
    case ARMCC::MI:  return "mi";
    case ARMCC::PL:  return "pl";
    case ARMCC::VS:  return "vs";
    case ARMCC::VC:  return "vc";
    case ARMCC::HI:  return "hi";
    case ARMCC::LS:  return "ls";
    case ARMCC::GE:  return "ge";
    case ARMCC::LT:  return "lt";
    case ARMCC::GT:  return "gt";
    case ARMCC::LE:  return "le";
    case ARMCC::AL:  return "al";
    }
  }

  struct VISIBILITY_HIDDEN ARMAsmPrinter : public AsmPrinter {
    ARMAsmPrinter(std::ostream &O, TargetMachine &TM, const TargetAsmInfo *T)
      : AsmPrinter(O, TM, T) {
    }

    std::set<std::string> ExtWeakSymbols;

    /// We name each basic block in a Function with a unique number, so
    /// that we can consistently refer to them later. This is cleared
    /// at the beginning of each call to runOnMachineFunction().
    ///
    typedef std::map<const Value *, unsigned> ValueMapTy;
    ValueMapTy NumberForBB;

    virtual const char *getPassName() const {
      return "ARM Assembly Printer";
    }

    void printAddrMode1(const MachineInstr *MI, int opNum);
    void printAddrMode2(const MachineInstr *MI, int opNum);
    void printAddrMode5(const MachineInstr *MI, int opNum);
    void printOperand(const MachineInstr *MI, int opNum);
    void printMemOperand(const MachineInstr *MI, int opNum,
                         const char *Modifier = 0);
    void printCCOperand(const MachineInstr *MI, int opNum);

    bool printInstruction(const MachineInstr *MI);  // autogenerated.
    bool runOnMachineFunction(MachineFunction &F);
    bool doInitialization(Module &M);
    bool doFinalization(Module &M);
  };
} // end of anonymous namespace

#include "ARMGenAsmWriter.inc"

/// createARMCodePrinterPass - Returns a pass that prints the ARM
/// assembly code for a MachineFunction to the given output stream,
/// using the given target machine description.  This should work
/// regardless of whether the function is in SSA form.
///
FunctionPass *llvm::createARMCodePrinterPass(std::ostream &o,
                                               TargetMachine &tm) {
  return new ARMAsmPrinter(o, tm, tm.getTargetAsmInfo());
}

/// runOnMachineFunction - This uses the printMachineInstruction()
/// method to print assembly for each instruction.
///
bool ARMAsmPrinter::runOnMachineFunction(MachineFunction &MF) {
  SetupMachineFunction(MF);
  O << "\n\n";

  // Print out constants referenced by the function
  EmitConstantPool(MF.getConstantPool());

  // Print out jump tables referenced by the function
  EmitJumpTableInfo(MF.getJumpTableInfo(), MF);

  // Print out labels for the function.
  const Function *F = MF.getFunction();
  SwitchToTextSection(getSectionForFunction(*F).c_str(), F);

  switch (F->getLinkage()) {
  default: assert(0 && "Unknown linkage type!");
  case Function::InternalLinkage:
    break;
  case Function::ExternalLinkage:
    O << "\t.globl\t" << CurrentFnName << "\n";
    break;
  case Function::WeakLinkage:
  case Function::LinkOnceLinkage:
    O << TAI->getWeakRefDirective() << CurrentFnName << "\n";
    break;
  }
  EmitAlignment(2, F);
  O << CurrentFnName << ":\n";

  // Print out code for the function.
  for (MachineFunction::const_iterator I = MF.begin(), E = MF.end();
       I != E; ++I) {
    // Print a label for the basic block.
    if (I != MF.begin()) {
      printBasicBlockLabel(I, true);
      O << '\n';
    }
    for (MachineBasicBlock::const_iterator II = I->begin(), E = I->end();
         II != E; ++II) {
      // Print the assembly for the instruction.
      O << "\t";
      printInstruction(II);
    }
  }

  return false;
}

void ARMAsmPrinter::printAddrMode1(const MachineInstr *MI, int opNum) {
  const MachineOperand &Arg       = MI->getOperand(opNum);
  const MachineOperand &Shift     = MI->getOperand(opNum + 1);
  const MachineOperand &ShiftType = MI->getOperand(opNum + 2);

  if(Arg.isImmediate()) {
    assert(Shift.getImmedValue() == 0);
    printOperand(MI, opNum);
  } else {
    assert(Arg.isRegister());
    printOperand(MI, opNum);
    if(Shift.isRegister() || Shift.getImmedValue() != 0) {
      const char *s = NULL;
      switch(ShiftType.getImmedValue()) {
      case ARMShift::LSL:
	s = ", lsl ";
	break;
      case ARMShift::LSR:
	s = ", lsr ";
	break;
      case ARMShift::ASR:
	s = ", asr ";
	break;
      case ARMShift::ROR:
	s = ", ror ";
	break;
      case ARMShift::RRX:
	s = ", rrx ";
	break;
      }
      O << s;
      printOperand(MI, opNum + 1);
    }
  }
}

void ARMAsmPrinter::printAddrMode2(const MachineInstr *MI, int opNum) {
  const MachineOperand &Arg    = MI->getOperand(opNum);
  const MachineOperand &Offset = MI->getOperand(opNum + 1);
  assert(Offset.isImmediate());

  if (Arg.isConstantPoolIndex()) {
    assert(Offset.getImmedValue() == 0);
    printOperand(MI, opNum);
  } else {
    assert(Arg.isRegister());
    O << '[';
    printOperand(MI, opNum);
    O << ", ";
    printOperand(MI, opNum + 1);
    O << ']';
  }
}

void ARMAsmPrinter::printAddrMode5(const MachineInstr *MI, int opNum) {
  const MachineOperand &Arg    = MI->getOperand(opNum);
  const MachineOperand &Offset = MI->getOperand(opNum + 1);
  assert(Offset.isImmediate());

  if (Arg.isConstantPoolIndex()) {
    assert(Offset.getImmedValue() == 0);
    printOperand(MI, opNum);
  } else {
    assert(Arg.isRegister());
    O << '[';
    printOperand(MI, opNum);
    O << ", ";
    printOperand(MI, opNum + 1);
    O << ']';
  }
}

void ARMAsmPrinter::printOperand(const MachineInstr *MI, int opNum) {
  const MachineOperand &MO = MI->getOperand (opNum);
  const MRegisterInfo &RI = *TM.getRegisterInfo();
  switch (MO.getType()) {
  case MachineOperand::MO_Register:
    if (MRegisterInfo::isPhysicalRegister(MO.getReg()))
      O << LowercaseString (RI.get(MO.getReg()).Name);
    else
      assert(0 && "not implemented");
    break;
  case MachineOperand::MO_Immediate:
    O << "#" << (int)MO.getImmedValue();
    break;
  case MachineOperand::MO_MachineBasicBlock:
    printBasicBlockLabel(MO.getMachineBasicBlock());
    return;
  case MachineOperand::MO_GlobalAddress: {
    GlobalValue *GV = MO.getGlobal();
    std::string Name = Mang->getValueName(GV);
    O << Name;
    if (GV->hasExternalWeakLinkage()) {
      ExtWeakSymbols.insert(Name);
    }
  }
    break;
  case MachineOperand::MO_ExternalSymbol:
    O << TAI->getGlobalPrefix() << MO.getSymbolName();
    break;
  case MachineOperand::MO_ConstantPoolIndex:
    O << TAI->getPrivateGlobalPrefix() << "CPI" << getFunctionNumber()
      << '_' << MO.getConstantPoolIndex();
    break;
  default:
    O << "<unknown operand type>"; abort (); break;
  }
}

void ARMAsmPrinter::printMemOperand(const MachineInstr *MI, int opNum,
                                      const char *Modifier) {
  assert(0 && "not implemented");
}

void ARMAsmPrinter::printCCOperand(const MachineInstr *MI, int opNum) {
  int CC = (int)MI->getOperand(opNum).getImmedValue();
  O << ARMCondCodeToString((ARMCC::CondCodes)CC);
}

bool ARMAsmPrinter::doInitialization(Module &M) {
  AsmPrinter::doInitialization(M);
  return false; // success
}

bool ARMAsmPrinter::doFinalization(Module &M) {
  const TargetData *TD = TM.getTargetData();

  for (Module::const_global_iterator I = M.global_begin(), E = M.global_end();
       I != E; ++I) {
    if (!I->hasInitializer())   // External global require no code
      continue;

    if (EmitSpecialLLVMGlobal(I))
      continue;

    O << "\n\n";
    std::string name = Mang->getValueName(I);
    Constant *C = I->getInitializer();
    unsigned Size = TD->getTypeSize(C->getType());
    unsigned Align = TD->getTypeAlignment(C->getType());

    if (C->isNullValue() &&
        (I->hasLinkOnceLinkage() || I->hasInternalLinkage() ||
         I->hasWeakLinkage())) {
      SwitchToDataSection(".data", I);
      if (I->hasInternalLinkage())
        O << "\t.local " << name << "\n";

      O << "\t.comm " << name << "," << TD->getTypeSize(C->getType())
        << "," << (unsigned)TD->getTypeAlignment(C->getType());
      O << "\n";
    } else {
      switch (I->getLinkage()) {
      default:
        assert(0 && "Unknown linkage type!");
        break;
      case GlobalValue::ExternalLinkage:
        O << "\t.globl " << name << "\n";
        break;
      case GlobalValue::InternalLinkage:
        break;
      }

      if (C->isNullValue())
        SwitchToDataSection(".bss",  I);
      else
        SwitchToDataSection(".data", I);

      EmitAlignment(Align, I);
      O << "\t.type " << name << ", %object\n";
      O << "\t.size " << name << ", " << Size << "\n";
      O << name << ":\n";
      EmitGlobalConstant(C);
    }
  }

  if (ExtWeakSymbols.begin() != ExtWeakSymbols.end())
    SwitchToDataSection("");
  for (std::set<std::string>::iterator i = ExtWeakSymbols.begin(),
         e = ExtWeakSymbols.end(); i != e; ++i) {
    O << TAI->getWeakRefDirective() << *i << "\n";
  }

  AsmPrinter::doFinalization(M);
  return false; // success
}
