//===-- MipsAsmPrinter.cpp - Mips LLVM assembly writer --------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file was developed by Bruno Cardoso Lopes and is distributed under the 
// University of Illinois Open Source License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains a printer that converts from our internal representation
// of machine-dependent LLVM code to GAS-format MIPS assembly language.
//
//===----------------------------------------------------------------------===//

#define DEBUG_TYPE "mips-asm-printer"

#include "Mips.h"
#include "MipsInstrInfo.h"
#include "MipsTargetMachine.h"
#include "MipsMachineFunction.h"
#include "llvm/Constants.h"
#include "llvm/DerivedTypes.h"
#include "llvm/Module.h"
#include "llvm/CodeGen/AsmPrinter.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineConstantPool.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/Target/TargetAsmInfo.h"
#include "llvm/Target/TargetData.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/Support/Mangler.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/ADT/StringExtras.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/MathExtras.h"
#include <cctype>

using namespace llvm;

STATISTIC(EmittedInsts, "Number of machine instrs printed");

namespace {
  struct VISIBILITY_HIDDEN MipsAsmPrinter : public AsmPrinter {
    MipsAsmPrinter(std::ostream &O, MipsTargetMachine &TM, 
                   const TargetAsmInfo *T): 
                   AsmPrinter(O, TM, T) {}

    virtual const char *getPassName() const {
      return "Mips Assembly Printer";
    }

    enum SetDirectiveFlags {
      REORDER,      // enables instruction reordering.
      NOREORDER,    // disables instruction reordering.
      MACRO,        // enables GAS macros.
      NOMACRO       // disables GAS macros.
    };

    void printOperand(const MachineInstr *MI, int opNum);
    void printMemOperand(const MachineInstr *MI, int opNum, 
                         const char *Modifier = 0);

    void printHex32(unsigned int Value);
    void emitFunctionStart(MachineFunction &MF);
    void emitFunctionEnd();
    void emitFrameDirective(MachineFunction &MF);
    void emitMaskDirective(MachineFunction &MF);
    void emitFMaskDirective();
    void emitSetDirective(SetDirectiveFlags Flag);

    bool printInstruction(const MachineInstr *MI);  // autogenerated.
    bool runOnMachineFunction(MachineFunction &F);
    bool doInitialization(Module &M);
    bool doFinalization(Module &M);
  };
} // end of anonymous namespace

#include "MipsGenAsmWriter.inc"

/// createMipsCodePrinterPass - Returns a pass that prints the MIPS
/// assembly code for a MachineFunction to the given output stream,
/// using the given target machine description.  This should work
/// regardless of whether the function is in SSA form.
FunctionPass *llvm::createMipsCodePrinterPass(std::ostream &o,
                                              MipsTargetMachine &tm) 
{
  return new MipsAsmPrinter(o, tm, tm.getTargetAsmInfo());
}

/// This pattern will be emitted :
///   .frame reg1, size, reg2
/// It describes the stack frame. 
/// reg1 - stack pointer
/// size - stack size allocated for the function
/// reg2 - return address register
void MipsAsmPrinter::
emitFrameDirective(MachineFunction &MF)
{
  const MRegisterInfo &RI = *TM.getRegisterInfo();

  unsigned stackReg  = RI.getFrameRegister(MF);
  unsigned returnReg = RI.getRARegister();
  unsigned stackSize = MF.getFrameInfo()->getStackSize();


  O << "\t.frame\t" << "$" << LowercaseString(RI.get(stackReg).Name) 
                    << "," << stackSize << ","
                    << "$" << LowercaseString(RI.get(returnReg).Name) 
                    << "\n";
}

/// This pattern will be emitted :
///   .mask bitmask, offset
/// Tells the assembler (and possibly linker) which registers are saved and where. 
/// bitmask - mask of all GPRs (little endian) 
/// offset  - negative value. offset+stackSize should give where on the stack
///           the first GPR is saved.
/// TODO: consider calle saved GPR regs here, not hardcode register numbers.
void MipsAsmPrinter::
emitMaskDirective(MachineFunction &MF)
{
  const MRegisterInfo &RI  = *TM.getRegisterInfo();
  MipsFunctionInfo *MipsFI = MF.getInfo<MipsFunctionInfo>();

  bool hasFP  = RI.hasFP(MF);
  bool saveRA = MF.getFrameInfo()->hasCalls();

  int offset;

  if (!MipsFI->getTopSavedRegOffset())
    offset = 0;
  else
    offset = -(MF.getFrameInfo()->getStackSize()
               -MipsFI->getTopSavedRegOffset());

  #ifndef NDEBUG
  DOUT << "<--ASM PRINTER--emitMaskDirective-->" << "\n";
  DOUT << "StackSize :  " << MF.getFrameInfo()->getStackSize() << "\n";
  DOUT << "getTopSavedRegOffset() : " << MipsFI->getTopSavedRegOffset() << "\n";
  DOUT << "offset : " << offset << "\n\n";
  #endif

  unsigned int bitmask = 0;

  if (hasFP) 
    bitmask |= (1 << 30);
  
  if (saveRA) 
    bitmask |= (1 << 31);

  O << "\t.mask\t"; 
  printHex32(bitmask);
  O << "," << offset << "\n";
}

/// This pattern will be emitted :
///   .fmask bitmask, offset
/// Tells the assembler (and possibly linker) which float registers are saved.
/// bitmask - mask of all Float Point registers (little endian) 
/// offset  - negative value. offset+stackSize should give where on the stack
///           the first Float Point register is saved.
/// TODO: implement this, dummy for now
void MipsAsmPrinter::
emitFMaskDirective()
{
  O << "\t.fmask\t0x00000000,0" << "\n";
}

/// Print a 32 bit hex number filling with 0's on the left.
/// TODO: make this setfill and setw
void MipsAsmPrinter::
printHex32(unsigned int Value) {
  O << "0x" << std::hex << Value << std::dec;  
}

/// Emit Set directives.
void MipsAsmPrinter::
emitSetDirective(SetDirectiveFlags Flag) {
  
  O << "\t.set\t";
  switch(Flag) {
      case REORDER:   O << "reorder" << "\n"; break;
      case NOREORDER: O << "noreorder" << "\n"; break;
      case MACRO:     O << "macro" << "\n"; break;
      case NOMACRO:   O << "nomacro" << "\n"; break;
      default: break;
  }
}

/// Emit the directives used by GAS on the start of functions
void MipsAsmPrinter::
emitFunctionStart(MachineFunction &MF)
{
  // Print out the label for the function.
  const Function *F = MF.getFunction();
  SwitchToTextSection(getSectionForFunction(*F).c_str(), F);

  // On Mips GAS, if .align #n is present, #n means the number of bits 
  // to be cleared. So, if we want 4 byte alignment, we must have .align 2
  EmitAlignment(1, F);

  O << "\t.globl\t"  << CurrentFnName << "\n";
  O << "\t.ent\t"    << CurrentFnName << "\n";
  O << "\t.type\t"   << CurrentFnName << ", @function\n";
  O << CurrentFnName << ":\n";

  emitFrameDirective(MF);
  emitMaskDirective(MF);
  emitFMaskDirective();

  emitSetDirective(NOREORDER);
  emitSetDirective(NOMACRO);
}

/// Emit the directives used by GAS on the end of functions
void MipsAsmPrinter::
emitFunctionEnd() {
  emitSetDirective(MACRO);
  emitSetDirective(REORDER);
  O << "\t.end\t" << CurrentFnName << "\n";
}

/// runOnMachineFunction - This uses the printMachineInstruction()
/// method to print assembly for each instruction.
bool MipsAsmPrinter::
runOnMachineFunction(MachineFunction &MF) 
{
  SetupMachineFunction(MF);

  // Print out constants referenced by the function
  EmitConstantPool(MF.getConstantPool());

  O << "\n\n";

  // What's my mangled name?
  CurrentFnName = Mang->getValueName(MF.getFunction());

  // Emit the function start directives
  emitFunctionStart(MF);

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

  // Emit function end directives
  emitFunctionEnd();

  // We didn't modify anything.
  return false;
}

void MipsAsmPrinter::
printOperand(const MachineInstr *MI, int opNum) 
{
  const MachineOperand &MO = MI->getOperand(opNum);
  const MRegisterInfo  &RI = *TM.getRegisterInfo();
  bool  closeP=false;

  // %hi and %lo used on mips gas to break large constants
  if (MI->getOpcode() == Mips::LUi && !MO.isRegister() 
      && !MO.isImmediate()) {
    O << "%hi(";
    closeP = true;
  } else if ((MI->getOpcode() == Mips::ADDiu) && !MO.isRegister() 
             && !MO.isImmediate()) {
    O << "%lo(";
    closeP = true;
  }
 
  switch (MO.getType()) 
  {
    case MachineOperand::MO_Register:
      if (MRegisterInfo::isPhysicalRegister(MO.getReg()))
        O << "$" << LowercaseString (RI.get(MO.getReg()).Name);
      else
        O << "$" << MO.getReg();
      break;

    case MachineOperand::MO_Immediate:
      if ((MI->getOpcode() == Mips::SLTiu) || (MI->getOpcode() == Mips::ORi) || 
          (MI->getOpcode() == Mips::LUi)   || (MI->getOpcode() == Mips::ANDi))
        O << (unsigned short int)MO.getImmedValue();
      else
        O << (short int)MO.getImmedValue();
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
      O << TAI->getPrivateGlobalPrefix() << "CPI"
        << getFunctionNumber() << "_" << MO.getConstantPoolIndex();
      break;
  
    default:
      O << "<unknown operand type>"; abort (); break;
  }

  if (closeP) O << ")";
}

void MipsAsmPrinter::
printMemOperand(const MachineInstr *MI, int opNum, const char *Modifier) 
{
  // lw/sw $reg, MemOperand
  // will turn into :
  // lw/sw $reg, imm($reg)
  printOperand(MI, opNum);
  O << "(";
  printOperand(MI, opNum+1);
  O << ")";
}

bool MipsAsmPrinter::
doInitialization(Module &M) 
{
  Mang = new Mangler(M);
  return false; // success
}

bool MipsAsmPrinter::
doFinalization(Module &M) 
{
  const TargetData *TD = TM.getTargetData();

  // Print out module-level global variables here.
  for (Module::const_global_iterator I = M.global_begin(),
         E = M.global_end(); I != E; ++I)

    // External global require no code
    if (I->hasInitializer()) {

      // Check to see if this is a special global 
      // used by LLVM, if so, emit it.
      if (EmitSpecialLLVMGlobal(I))
        continue;
      
      O << "\n\n";
      std::string name = Mang->getValueName(I);
      Constant *C      = I->getInitializer();
      unsigned Size    = TD->getTypeSize(C->getType());
      unsigned Align   = TD->getPrefTypeAlignment(C->getType());

      if (C->isNullValue() && (I->hasLinkOnceLinkage() || 
        I->hasInternalLinkage() || I->hasWeakLinkage() 
        /* FIXME: Verify correct */)) {

        SwitchToDataSection(".data", I);
        if (I->hasInternalLinkage())
          O << "\t.local " << name << "\n";

        O << "\t.comm " << name << "," 
          << TD->getTypeSize(C->getType()) 
          << "," << Align << "\n";

      } else {

        switch (I->getLinkage()) 
        {
          case GlobalValue::LinkOnceLinkage:
          case GlobalValue::WeakLinkage:   
            // FIXME: Verify correct for weak.
            // Nonnull linkonce -> weak
            O << "\t.weak " << name << "\n";
            SwitchToDataSection("", I);
            O << "\t.section\t\".llvm.linkonce.d." << name
                          << "\",\"aw\",@progbits\n";
            break;
          case GlobalValue::AppendingLinkage:
            // FIXME: appending linkage variables 
            // should go into a section of  their name or 
            // something.  For now, just emit them as external.
          case GlobalValue::ExternalLinkage:
            // If external or appending, declare as a global symbol
            O << "\t.globl " << name << "\n";
          case GlobalValue::InternalLinkage:
            if (C->isNullValue())
              SwitchToDataSection(".bss", I);
            else
              SwitchToDataSection(".data", I);
            break;
          case GlobalValue::GhostLinkage:
            cerr << "Should not have any" 
                 << "unmaterialized functions!\n";
            abort();
          case GlobalValue::DLLImportLinkage:
            cerr << "DLLImport linkage is" 
                 << "not supported by this target!\n";
            abort();
          case GlobalValue::DLLExportLinkage:
            cerr << "DLLExport linkage is" 
                 << "not supported by this target!\n";
            abort();
          default:
            assert(0 && "Unknown linkage type!");          
        }
        O << "\t.align " << Align << "\n";
        O << "\t.type " << name << ",@object\n";
        O << "\t.size " << name << "," << Size << "\n";
        O << name << ":\n";
        EmitGlobalConstant(C);
    }
  }

  return AsmPrinter::doFinalization(M);
}
