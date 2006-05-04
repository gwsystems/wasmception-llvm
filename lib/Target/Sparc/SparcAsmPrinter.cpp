//===-- SparcAsmPrinter.cpp - Sparc LLVM assembly writer ------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file was developed by the LLVM research group and is distributed under
// the University of Illinois Open Source License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains a printer that converts from our internal representation
// of machine-dependent LLVM code to GAS-format SPARC assembly language.
//
//===----------------------------------------------------------------------===//

#include "Sparc.h"
#include "SparcInstrInfo.h"
#include "llvm/Constants.h"
#include "llvm/DerivedTypes.h"
#include "llvm/Module.h"
#include "llvm/Assembly/Writer.h"
#include "llvm/CodeGen/AsmPrinter.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineConstantPool.h"
#include "llvm/CodeGen/MachineInstr.h"
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

  struct SparcAsmPrinter : public AsmPrinter {
    SparcAsmPrinter(std::ostream &O, TargetMachine &TM) : AsmPrinter(O, TM) {
      Data16bitsDirective = "\t.half\t";
      Data32bitsDirective = "\t.word\t";
      Data64bitsDirective = 0;  // .xword is only supported by V9.
      ZeroDirective = "\t.skip\t";
      CommentString = "!";
      ConstantPoolSection = "\t.section \".rodata\",#alloc\n";
    }

    /// We name each basic block in a Function with a unique number, so
    /// that we can consistently refer to them later. This is cleared
    /// at the beginning of each call to runOnMachineFunction().
    ///
    typedef std::map<const Value *, unsigned> ValueMapTy;
    ValueMapTy NumberForBB;

    virtual const char *getPassName() const {
      return "Sparc Assembly Printer";
    }

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

#include "SparcGenAsmWriter.inc"

/// createSparcCodePrinterPass - Returns a pass that prints the SPARC
/// assembly code for a MachineFunction to the given output stream,
/// using the given target machine description.  This should work
/// regardless of whether the function is in SSA form.
///
FunctionPass *llvm::createSparcCodePrinterPass(std::ostream &o,
                                               TargetMachine &tm) {
  return new SparcAsmPrinter(o, tm);
}

/// runOnMachineFunction - This uses the printMachineInstruction()
/// method to print assembly for each instruction.
///
bool SparcAsmPrinter::runOnMachineFunction(MachineFunction &MF) {
  SetupMachineFunction(MF);

  // Print out constants referenced by the function
  EmitConstantPool(MF.getConstantPool());

  // BBNumber is used here so that a given Printer will never give two
  // BBs the same name. (If you have a better way, please let me know!)
  static unsigned BBNumber = 0;

  O << "\n\n";
  // What's my mangled name?
  CurrentFnName = Mang->getValueName(MF.getFunction());

  // Print out labels for the function.
  O << "\t.text\n";
  O << "\t.align 16\n";
  O << "\t.globl\t" << CurrentFnName << "\n";
  O << "\t.type\t" << CurrentFnName << ", #function\n";
  O << CurrentFnName << ":\n";

  // Number each basic block so that we can consistently refer to them
  // in PC-relative references.
  NumberForBB.clear();
  for (MachineFunction::const_iterator I = MF.begin(), E = MF.end();
       I != E; ++I) {
    NumberForBB[I->getBasicBlock()] = BBNumber++;
  }

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
      ++EmittedInsts;
    }
  }

  // We didn't modify anything.
  return false;
}

void SparcAsmPrinter::printOperand(const MachineInstr *MI, int opNum) {
  const MachineOperand &MO = MI->getOperand (opNum);
  const MRegisterInfo &RI = *TM.getRegisterInfo();
  bool CloseParen = false;
  if (MI->getOpcode() == SP::SETHIi && !MO.isRegister() && !MO.isImmediate()) {
    O << "%hi(";
    CloseParen = true;
  } else if ((MI->getOpcode() == SP::ORri || MI->getOpcode() == SP::ADDri)
             && !MO.isRegister() && !MO.isImmediate()) {
    O << "%lo(";
    CloseParen = true;
  }
  switch (MO.getType()) {
  case MachineOperand::MO_Register:
    if (MRegisterInfo::isPhysicalRegister(MO.getReg()))
      O << "%" << LowercaseString (RI.get(MO.getReg()).Name);
    else
      O << "%reg" << MO.getReg();
    break;

  case MachineOperand::MO_Immediate:
    O << (int)MO.getImmedValue();
    break;
  case MachineOperand::MO_MachineBasicBlock:
    printBasicBlockLabel(MO.getMachineBasicBlock());
    return;
  case MachineOperand::MO_GlobalAddress:
    O << Mang->getValueName(MO.getGlobal());
    break;
  case MachineOperand::MO_ExternalSymbol:
    O << MO.getSymbolName();
    break;
  case MachineOperand::MO_ConstantPoolIndex:
    O << PrivateGlobalPrefix << "CPI" << getFunctionNumber() << "_"
      << MO.getConstantPoolIndex();
    break;
  default:
    O << "<unknown operand type>"; abort (); break;
  }
  if (CloseParen) O << ")";
}

void SparcAsmPrinter::printMemOperand(const MachineInstr *MI, int opNum,
                                      const char *Modifier) {
  printOperand(MI, opNum);
  
  // If this is an ADD operand, emit it like normal operands.
  if (Modifier && !strcmp(Modifier, "arith")) {
    O << ", ";
    printOperand(MI, opNum+1);
    return;
  }
  
  MachineOperand::MachineOperandType OpTy = MI->getOperand(opNum+1).getType();
  
  if (MI->getOperand(opNum+1).isRegister() &&
      MI->getOperand(opNum+1).getReg() == SP::G0)
    return;   // don't print "+%g0"
  if (MI->getOperand(opNum+1).isImmediate() &&
      MI->getOperand(opNum+1).getImmedValue() == 0)
    return;   // don't print "+0"
  
  O << "+";
  if (MI->getOperand(opNum+1).isGlobalAddress() ||
      MI->getOperand(opNum+1).isConstantPoolIndex()) {
    O << "%lo(";
    printOperand(MI, opNum+1);
    O << ")";
  } else {
    printOperand(MI, opNum+1);
  }
}

void SparcAsmPrinter::printCCOperand(const MachineInstr *MI, int opNum) {
  int CC = (int)MI->getOperand(opNum).getImmedValue();
  O << SPARCCondCodeToString((SPCC::CondCodes)CC);
}



bool SparcAsmPrinter::doInitialization(Module &M) {
  Mang = new Mangler(M);
  return false; // success
}

bool SparcAsmPrinter::doFinalization(Module &M) {
  const TargetData *TD = TM.getTargetData();

  // Print out module-level global variables here.
  for (Module::const_global_iterator I = M.global_begin(), E = M.global_end();
       I != E; ++I)
    if (I->hasInitializer()) {   // External global require no code
      // Check to see if this is a special global used by LLVM, if so, emit it.
      if (EmitSpecialLLVMGlobal(I))
        continue;
      
      O << "\n\n";
      std::string name = Mang->getValueName(I);
      Constant *C = I->getInitializer();
      unsigned Size = TD->getTypeSize(C->getType());
      unsigned Align = TD->getTypeAlignment(C->getType());

      if (C->isNullValue() &&
          (I->hasLinkOnceLinkage() || I->hasInternalLinkage() ||
           I->hasWeakLinkage() /* FIXME: Verify correct */)) {
        SwitchSection(".data", I);
        if (I->hasInternalLinkage())
          O << "\t.local " << name << "\n";

        O << "\t.comm " << name << "," << TD->getTypeSize(C->getType())
          << "," << (unsigned)TD->getTypeAlignment(C->getType());
        O << "\t\t! ";
        WriteAsOperand(O, I, true, true, &M);
        O << "\n";
      } else {
        switch (I->getLinkage()) {
        case GlobalValue::LinkOnceLinkage:
        case GlobalValue::WeakLinkage:   // FIXME: Verify correct for weak.
          // Nonnull linkonce -> weak
          O << "\t.weak " << name << "\n";
          SwitchSection("", I);
          O << "\t.section\t\".llvm.linkonce.d." << name
            << "\",\"aw\",@progbits\n";
          break;

        case GlobalValue::AppendingLinkage:
          // FIXME: appending linkage variables should go into a section of
          // their name or something.  For now, just emit them as external.
        case GlobalValue::ExternalLinkage:
          // If external or appending, declare as a global symbol
          O << "\t.globl " << name << "\n";
          // FALL THROUGH
        case GlobalValue::InternalLinkage:
          if (C->isNullValue())
            SwitchSection(".bss", I);
          else
            SwitchSection(".data", I);
          break;
        case GlobalValue::GhostLinkage:
          std::cerr << "Should not have any unmaterialized functions!\n";
          abort();
        }

        O << "\t.align " << Align << "\n";
        O << "\t.type " << name << ",#object\n";
        O << "\t.size " << name << "," << Size << "\n";
        O << name << ":\t\t\t\t! ";
        WriteAsOperand(O, I, true, true, &M);
        O << "\n";
        EmitGlobalConstant(C);
      }
    }

  AsmPrinter::doFinalization(M);
  return false; // success
}
