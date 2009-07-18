//===-- SystemZAsmPrinter.cpp - SystemZ LLVM assembly writer ---------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains a printer that converts from our internal representation
// of machine-dependent LLVM code to the SystemZ assembly language.
//
//===----------------------------------------------------------------------===//

#define DEBUG_TYPE "asm-printer"
#include "SystemZ.h"
#include "SystemZInstrInfo.h"
#include "SystemZTargetMachine.h"
#include "llvm/Constants.h"
#include "llvm/DerivedTypes.h"
#include "llvm/Module.h"
#include "llvm/CodeGen/AsmPrinter.h"
#include "llvm/CodeGen/DwarfWriter.h"
#include "llvm/CodeGen/MachineModuleInfo.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineConstantPool.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/Target/TargetAsmInfo.h"
#include "llvm/Target/TargetData.h"
#include "llvm/Target/TargetRegistry.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/Support/Compiler.h"
#include "llvm/Support/FormattedStream.h"
#include "llvm/Support/Mangler.h"

using namespace llvm;

STATISTIC(EmittedInsts, "Number of machine instrs printed");

namespace {
  class VISIBILITY_HIDDEN SystemZAsmPrinter : public AsmPrinter {
  public:
    SystemZAsmPrinter(formatted_raw_ostream &O, TargetMachine &TM,
                      const TargetAsmInfo *TAI, bool V)
      : AsmPrinter(O, TM, TAI, V) {}

    virtual const char *getPassName() const {
      return "SystemZ Assembly Printer";
    }

    void printOperand(const MachineInstr *MI, int OpNum,
                      const char* Modifier = 0);
    void printPCRelImmOperand(const MachineInstr *MI, int OpNum);
    void printRIAddrOperand(const MachineInstr *MI, int OpNum,
                            const char* Modifier = 0);
    void printRRIAddrOperand(const MachineInstr *MI, int OpNum,
                             const char* Modifier = 0);
    void printS16ImmOperand(const MachineInstr *MI, int OpNum) {
      O << (int16_t)MI->getOperand(OpNum).getImm();
    }
    void printS32ImmOperand(const MachineInstr *MI, int OpNum) {
      O << (int32_t)MI->getOperand(OpNum).getImm();
    }

    bool printInstruction(const MachineInstr *MI);  // autogenerated.
    void printMachineInstruction(const MachineInstr * MI);

    void emitFunctionHeader(const MachineFunction &MF);
    bool runOnMachineFunction(MachineFunction &F);
    bool doInitialization(Module &M);
    bool doFinalization(Module &M);
    void printModuleLevelGV(const GlobalVariable* GVar);

    void getAnalysisUsage(AnalysisUsage &AU) const {
      AsmPrinter::getAnalysisUsage(AU);
      AU.setPreservesAll();
    }
  };
} // end of anonymous namespace

#include "SystemZGenAsmWriter.inc"

/// createSystemZCodePrinterPass - Returns a pass that prints the SystemZ
/// assembly code for a MachineFunction to the given output stream,
/// using the given target machine description.  This should work
/// regardless of whether the function is in SSA form.
///
FunctionPass *llvm::createSystemZCodePrinterPass(formatted_raw_ostream &o,
                                                 TargetMachine &tm,
                                                 bool verbose) {
  return new SystemZAsmPrinter(o, tm, tm.getTargetAsmInfo(), verbose);
}

bool SystemZAsmPrinter::doInitialization(Module &M) {
  Mang = new Mangler(M, "", TAI->getPrivateGlobalPrefix());
  return false; // success
}


bool SystemZAsmPrinter::doFinalization(Module &M) {
  // Print out module-level global variables here.
  for (Module::const_global_iterator I = M.global_begin(), E = M.global_end();
       I != E; ++I)
    printModuleLevelGV(I);

  return AsmPrinter::doFinalization(M);
}

void SystemZAsmPrinter::emitFunctionHeader(const MachineFunction &MF) {
  unsigned FnAlign = MF.getAlignment();
  const Function *F = MF.getFunction();

  SwitchToSection(TAI->SectionForGlobal(F));

  EmitAlignment(FnAlign, F);

  switch (F->getLinkage()) {
  default: assert(0 && "Unknown linkage type!");
  case Function::InternalLinkage:  // Symbols default to internal.
  case Function::PrivateLinkage:
    break;
  case Function::ExternalLinkage:
    O << "\t.globl\t" << CurrentFnName << '\n';
    break;
  case Function::LinkOnceAnyLinkage:
  case Function::LinkOnceODRLinkage:
  case Function::WeakAnyLinkage:
  case Function::WeakODRLinkage:
    O << "\t.weak\t" << CurrentFnName << '\n';
    break;
  }

  printVisibility(CurrentFnName, F->getVisibility());

  O << "\t.type\t" << CurrentFnName << ",@function\n"
    << CurrentFnName << ":\n";
}

bool SystemZAsmPrinter::runOnMachineFunction(MachineFunction &MF) {
  SetupMachineFunction(MF);
  O << "\n\n";

  // Print out constants referenced by the function
  EmitConstantPool(MF.getConstantPool());

  // Print the 'header' of function
  emitFunctionHeader(MF);

  // Print out code for the function.
  for (MachineFunction::const_iterator I = MF.begin(), E = MF.end();
       I != E; ++I) {
    // Print a label for the basic block.
    if (!VerboseAsm && (I->pred_empty() || I->isOnlyReachableByFallthrough())) {
      // This is an entry block or a block that's only reachable via a
      // fallthrough edge. In non-VerboseAsm mode, don't print the label.
    } else {
      printBasicBlockLabel(I, true, true, VerboseAsm);
      O << '\n';
    }

    for (MachineBasicBlock::const_iterator II = I->begin(), E = I->end();
         II != E; ++II)
      // Print the assembly for the instruction.
      printMachineInstruction(II);
  }

  if (TAI->hasDotTypeDotSizeDirective())
    O << "\t.size\t" << CurrentFnName << ", .-" << CurrentFnName << '\n';

  // Print out jump tables referenced by the function.
  EmitJumpTableInfo(MF.getJumpTableInfo(), MF);

  O.flush();

  // We didn't modify anything
  return false;
}

void SystemZAsmPrinter::printMachineInstruction(const MachineInstr *MI) {
  ++EmittedInsts;

  // Call the autogenerated instruction printer routines.
  if (printInstruction(MI))
    return;

  llvm_unreachable("Unreachable!");
}

void SystemZAsmPrinter::printPCRelImmOperand(const MachineInstr *MI, int OpNum) {
  const MachineOperand &MO = MI->getOperand(OpNum);
  switch (MO.getType()) {
  case MachineOperand::MO_Immediate:
    O << MO.getImm();
    return;
  case MachineOperand::MO_MachineBasicBlock:
    printBasicBlockLabel(MO.getMBB(), false, false, VerboseAsm);
    return;
  case MachineOperand::MO_GlobalAddress: {
    const GlobalValue *GV = MO.getGlobal();
    std::string Name = Mang->getMangledName(GV);

    O << Name;

    // Assemble calls via PLT for externally visible symbols if PIC.
    if (TM.getRelocationModel() == Reloc::PIC_ &&
        !GV->hasHiddenVisibility() && !GV->hasProtectedVisibility() &&
        !GV->hasLocalLinkage())
      O << "@PLT";

    printOffset(MO.getOffset());
    return;
  }
  case MachineOperand::MO_ExternalSymbol: {
    std::string Name(TAI->getGlobalPrefix());
    Name += MO.getSymbolName();
    O << Name;

    if (TM.getRelocationModel() == Reloc::PIC_)
      O << "@PLT";

    return;
  }
  default:
    assert(0 && "Not implemented yet!");
  }
}


void SystemZAsmPrinter::printOperand(const MachineInstr *MI, int OpNum,
                                     const char* Modifier) {
  const MachineOperand &MO = MI->getOperand(OpNum);
  switch (MO.getType()) {
  case MachineOperand::MO_Register: {
    assert (TargetRegisterInfo::isPhysicalRegister(MO.getReg()) &&
            "Virtual registers should be already mapped!");
    unsigned Reg = MO.getReg();
    if (Modifier && strncmp(Modifier, "subreg", 6) == 0) {
      if (strncmp(Modifier + 7, "even", 4) == 0)
        Reg = TRI->getSubReg(Reg, SystemZ::SUBREG_EVEN);
      else if (strncmp(Modifier + 7, "odd", 3) == 0)
        Reg = TRI->getSubReg(Reg, SystemZ::SUBREG_ODD);
      else
        assert(0 && "Invalid subreg modifier");
    }

    O << '%' << TRI->getAsmName(Reg);
    return;
  }
  case MachineOperand::MO_Immediate:
    O << MO.getImm();
    return;
  case MachineOperand::MO_MachineBasicBlock:
    printBasicBlockLabel(MO.getMBB());
    return;
  case MachineOperand::MO_JumpTableIndex:
    O << TAI->getPrivateGlobalPrefix() << "JTI" << getFunctionNumber() << '_'
      << MO.getIndex();

    return;
  case MachineOperand::MO_ConstantPoolIndex:
    O << TAI->getPrivateGlobalPrefix() << "CPI" << getFunctionNumber() << '_'
      << MO.getIndex();

    printOffset(MO.getOffset());
    break;
  case MachineOperand::MO_GlobalAddress: {
    const GlobalValue *GV = MO.getGlobal();
    std::string Name = Mang->getMangledName(GV);

    O << Name;
    break;
  }
  case MachineOperand::MO_ExternalSymbol: {
    std::string Name(TAI->getGlobalPrefix());
    Name += MO.getSymbolName();
    O << Name;
    break;
  }
  default:
    assert(0 && "Not implemented yet!");
  }

  switch (MO.getTargetFlags()) {
  default:
    llvm_unreachable("Unknown target flag on GV operand");
  case SystemZII::MO_NO_FLAG:
    break;
  case SystemZII::MO_GOTENT:    O << "@GOTENT";    break;
  case SystemZII::MO_PLT:       O << "@PLT";       break;
  }

  printOffset(MO.getOffset());
}

void SystemZAsmPrinter::printRIAddrOperand(const MachineInstr *MI, int OpNum,
                                           const char* Modifier) {
  const MachineOperand &Base = MI->getOperand(OpNum);

  // Print displacement operand.
  printOperand(MI, OpNum+1);

  // Print base operand (if any)
  if (Base.getReg()) {
    O << '(';
    printOperand(MI, OpNum);
    O << ')';
  }
}

void SystemZAsmPrinter::printRRIAddrOperand(const MachineInstr *MI, int OpNum,
                                            const char* Modifier) {
  const MachineOperand &Base = MI->getOperand(OpNum);
  const MachineOperand &Index = MI->getOperand(OpNum+2);

  // Print displacement operand.
  printOperand(MI, OpNum+1);

  // Print base operand (if any)
  if (Base.getReg()) {
    O << '(';
    printOperand(MI, OpNum);
    if (Index.getReg()) {
      O << ',';
      printOperand(MI, OpNum+2);
    }
    O << ')';
  } else
    assert(!Index.getReg() && "Should allocate base register first!");
}

/// PrintUnmangledNameSafely - Print out the printable characters in the name.
/// Don't print things like \\n or \\0.
static void PrintUnmangledNameSafely(const Value *V, formatted_raw_ostream &OS) {
  for (const char *Name = V->getNameStart(), *E = Name+V->getNameLen();
       Name != E; ++Name)
    if (isprint(*Name))
      OS << *Name;
}

void SystemZAsmPrinter::printModuleLevelGV(const GlobalVariable* GVar) {
  const TargetData *TD = TM.getTargetData();

  if (!GVar->hasInitializer())
    return;   // External global require no code

  // Check to see if this is a special global used by LLVM, if so, emit it.
  if (EmitSpecialLLVMGlobal(GVar))
    return;

  std::string name = Mang->getMangledName(GVar);
  Constant *C = GVar->getInitializer();
  unsigned Size = TD->getTypeAllocSize(C->getType());
  unsigned Align = std::max(1U, TD->getPreferredAlignmentLog(GVar));

  printVisibility(name, GVar->getVisibility());

  O << "\t.type\t" << name << ",@object\n";

  SwitchToSection(TAI->SectionForGlobal(GVar));

  if (C->isNullValue() && !GVar->hasSection() &&
      !GVar->isThreadLocal() &&
      (GVar->hasLocalLinkage() || GVar->isWeakForLinker())) {

    if (Size == 0) Size = 1;   // .comm Foo, 0 is undefined, avoid it.

    if (GVar->hasLocalLinkage())
      O << "\t.local\t" << name << '\n';

    O << TAI->getCOMMDirective()  << name << ',' << Size;
    if (TAI->getCOMMDirectiveTakesAlignment())
      O << ',' << (TAI->getAlignmentIsInBytes() ? (1 << Align) : Align);

    if (VerboseAsm) {
      O << "\t\t" << TAI->getCommentString() << ' ';
      PrintUnmangledNameSafely(GVar, O);
    }
    O << '\n';
    return;
  }

  switch (GVar->getLinkage()) {
  case GlobalValue::CommonLinkage:
  case GlobalValue::LinkOnceAnyLinkage:
  case GlobalValue::LinkOnceODRLinkage:
  case GlobalValue::WeakAnyLinkage:
  case GlobalValue::WeakODRLinkage:
    O << "\t.weak\t" << name << '\n';
    break;
  case GlobalValue::DLLExportLinkage:
  case GlobalValue::AppendingLinkage:
    // FIXME: appending linkage variables should go into a section of
    // their name or something.  For now, just emit them as external.
  case GlobalValue::ExternalLinkage:
    // If external or appending, declare as a global symbol
    O << "\t.globl " << name << '\n';
    // FALL THROUGH
  case GlobalValue::PrivateLinkage:
  case GlobalValue::InternalLinkage:
     break;
  default:
    assert(0 && "Unknown linkage type!");
  }

  // Use 16-bit alignment by default to simplify bunch of stuff
  EmitAlignment(Align, GVar, 1);
  O << name << ":";
  if (VerboseAsm) {
    O << "\t\t\t\t" << TAI->getCommentString() << ' ';
    PrintUnmangledNameSafely(GVar, O);
  }
  O << '\n';
  if (TAI->hasDotTypeDotSizeDirective())
    O << "\t.size\t" << name << ", " << Size << '\n';

  EmitGlobalConstant(C);
}

// Force static initialization.
extern "C" void LLVMInitializeSystemZAsmPrinter() {
  TargetRegistry::RegisterAsmPrinter(TheSystemZTarget,
                                     createSystemZCodePrinterPass);
}
