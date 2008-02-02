//===-- MipsAsmPrinter.cpp - Mips LLVM assembly writer --------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
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
#include "llvm/Target/TargetOptions.h"
#include "llvm/Support/Mangler.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/ADT/SetVector.h"
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

    unsigned int getSavedRegsBitmask(bool isFloat, MachineFunction &MF);
    void printHex32(unsigned int Value);

    void emitFunctionStart(MachineFunction &MF);
    void emitFunctionEnd(MachineFunction &MF);
    void emitFrameDirective(MachineFunction &MF);
    void emitMaskDirective(MachineFunction &MF);
    void emitFMaskDirective(MachineFunction &MF);
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

//===----------------------------------------------------------------------===//
//
//  Mips Asm Directives
//
//  -- Frame directive "frame Stackpointer, Stacksize, RARegister"
//  Describe the stack frame.
//
//  -- Mask directives "(f)mask  bitmask, offset" 
//  Tells the assembler which registers are saved and where.
//  bitmask - contain a little endian bitset indicating which registers are 
//            saved on function prologue (e.g. with a 0x80000000 mask, the 
//            assembler knows the register 31 (RA) is saved at prologue.
//  offset  - the position before stack pointer subtraction indicating where 
//            the first saved register on prologue is located. (e.g. with a
//
//  Consider the following function prologue:
//
//    .frame	$fp,48,$ra
//    .mask	  0xc0000000,-8
//	  addiu $sp, $sp, -48
//	  sw $ra, 40($sp)
//	  sw $fp, 36($sp)
//
//    With a 0xc0000000 mask, the assembler knows the register 31 (RA) and 
//    30 (FP) are saved at prologue. As the save order on prologue is from 
//    left to right, RA is saved first. A -8 offset means that after the 
//    stack pointer subtration, the first register in the mask (RA) will be
//    saved at address 48-8=40.
//
//===----------------------------------------------------------------------===//

/// Mask directive for GPR
void MipsAsmPrinter::
emitMaskDirective(MachineFunction &MF)
{
  MipsFunctionInfo *MipsFI = MF.getInfo<MipsFunctionInfo>();

  int StackSize = MF.getFrameInfo()->getStackSize();
  int Offset    = (!MipsFI->getTopSavedRegOffset()) ? 0 : 
                  (-(StackSize-MipsFI->getTopSavedRegOffset()));
             
  #ifndef NDEBUG
  DOUT << "--> emitMaskDirective" << "\n";
  DOUT << "StackSize :  " << StackSize << "\n";
  DOUT << "getTopSavedReg : " << MipsFI->getTopSavedRegOffset() << "\n";
  DOUT << "Offset : " << Offset << "\n\n";
  #endif

  unsigned int Bitmask = getSavedRegsBitmask(false, MF);
  O << "\t.mask \t"; 
  printHex32(Bitmask);
  O << "," << Offset << "\n";
}

/// TODO: Mask Directive for Float Point
void MipsAsmPrinter::
emitFMaskDirective(MachineFunction &MF)
{
  unsigned int Bitmask = getSavedRegsBitmask(true, MF);

  O << "\t.fmask\t";
  printHex32(Bitmask);
  O << ",0" << "\n";
}

/// Frame Directive
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

/// Emit Set directives.
void MipsAsmPrinter::
emitSetDirective(SetDirectiveFlags Flag) 
{  
  O << "\t.set\t";
  switch(Flag) {
      case REORDER:   O << "reorder" << "\n"; break;
      case NOREORDER: O << "noreorder" << "\n"; break;
      case MACRO:     O << "macro" << "\n"; break;
      case NOMACRO:   O << "nomacro" << "\n"; break;
      default: break;
  }
}  

// Create a bitmask with all callee saved registers for CPU
// or Float Point registers. For CPU registers consider RA,
// GP and FP for saving if necessary.
unsigned int MipsAsmPrinter::
getSavedRegsBitmask(bool isFloat, MachineFunction &MF)
{
  const MRegisterInfo &RI = *TM.getRegisterInfo();
             
  // Float Point Registers, TODO
  if (isFloat)
    return 0;

  // CPU Registers
  unsigned int Bitmask = 0;

  MachineFrameInfo *MFI = MF.getFrameInfo();
  const std::vector<CalleeSavedInfo> &CSI = MFI->getCalleeSavedInfo();
  for (unsigned i = 0, e = CSI.size(); i != e; ++i)
    Bitmask |= (1 << MipsRegisterInfo::getRegisterNumbering(CSI[i].getReg()));

  if (RI.hasFP(MF)) 
    Bitmask |= (1 << MipsRegisterInfo::
                getRegisterNumbering(RI.getFrameRegister(MF)));
  
  if (MF.getFrameInfo()->hasCalls()) 
    Bitmask |= (1 << MipsRegisterInfo::
                getRegisterNumbering(RI.getRARegister()));

  return Bitmask;
}

// Print a 32 bit hex number with all numbers.
void MipsAsmPrinter::
printHex32(unsigned int Value) 
{
  O << "0x" << std::hex;
  for (int i = 7; i >= 0; i--) 
    O << std::hex << ( (Value & (0xF << (i*4))) >> (i*4) );
  O << std::dec;
}

/// Emit the directives used by GAS on the start of functions
void MipsAsmPrinter::
emitFunctionStart(MachineFunction &MF)
{
  // Print out the label for the function.
  const Function *F = MF.getFunction();
  SwitchToTextSection(getSectionForFunction(*F).c_str(), F);

  // 2 bits aligned
  EmitAlignment(2, F);

  O << "\t.globl\t"  << CurrentFnName << "\n";
  O << "\t.ent\t"    << CurrentFnName << "\n";
  O << "\t.type\t"   << CurrentFnName << ", @function\n";
  O << CurrentFnName << ":\n";

  emitFrameDirective(MF);
  emitMaskDirective(MF);
  emitFMaskDirective(MF);

  if (TM.getRelocationModel() == Reloc::Static) {
    emitSetDirective(NOREORDER);
    emitSetDirective(NOMACRO);
  }

  O << "\n";
}

/// Emit the directives used by GAS on the end of functions
void MipsAsmPrinter::
emitFunctionEnd(MachineFunction &MF) 
{
  if (TM.getRelocationModel() == Reloc::Static) {
    emitSetDirective(MACRO);
    emitSetDirective(REORDER);
  }    

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

  // Print out jump tables referenced by the function
  EmitJumpTableInfo(MF.getJumpTableInfo(), MF);

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
      printInstruction(II);
      ++EmittedInsts;
    }

    // Each Basic Block is separated by a newline
    O << '\n';
  }

  // Emit function end directives
  emitFunctionEnd(MF);

  // We didn't modify anything.
  return false;
}

void MipsAsmPrinter::
printOperand(const MachineInstr *MI, int opNum) 
{
  const MachineOperand &MO = MI->getOperand(opNum);
  const MRegisterInfo  &RI = *TM.getRegisterInfo();
  bool closeP = false;
  bool isPIC = (TM.getRelocationModel() == Reloc::PIC_);
  bool isCodeLarge = (TM.getCodeModel() == CodeModel::Large);

  // %hi and %lo used on mips gas to load global addresses on
  // static code. %got is used to load global addresses when 
  // using PIC_. %call16 is used to load direct call targets
  // on PIC_ and small code size. %call_lo and %call_hi load 
  // direct call targets on PIC_ and large code size.
  if (MI->getOpcode() == Mips::LUi && !MO.isRegister() 
      && !MO.isImmediate()) {
    if ((isPIC) && (isCodeLarge))
      O << "%call_hi(";
    else
      O << "%hi(";
    closeP = true;
  } else if ((MI->getOpcode() == Mips::ADDiu) && !MO.isRegister() 
             && !MO.isImmediate()) {
    O << "%lo(";
    closeP = true;
  } else if ((isPIC) && (MI->getOpcode() == Mips::LW)
             && (!MO.isRegister()) && (!MO.isImmediate())) {
    const MachineOperand &firstMO = MI->getOperand(opNum-1);
    const MachineOperand &lastMO  = MI->getOperand(opNum+1);
    if ((firstMO.isRegister()) && (lastMO.isRegister())) {
      if ((firstMO.getReg() == Mips::T9) && (lastMO.getReg() == Mips::GP) 
          && (!isCodeLarge))
        O << "%call16(";
      else if ((firstMO.getReg() != Mips::T9) && (lastMO.getReg() == Mips::GP))
        O << "%got(";
      else if ((firstMO.getReg() == Mips::T9) && (lastMO.getReg() != Mips::GP) 
               && (isCodeLarge))
        O << "%call_lo(";
      closeP = true;
    }
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
        O << (unsigned short int)MO.getImm();
      else
        O << (short int)MO.getImm();
      break;

    case MachineOperand::MO_MachineBasicBlock:
      printBasicBlockLabel(MO.getMBB());
      return;

    case MachineOperand::MO_GlobalAddress:
      O << Mang->getValueName(MO.getGlobal());
      break;

    case MachineOperand::MO_ExternalSymbol:
      O << MO.getSymbolName();
      break;

    case MachineOperand::MO_JumpTableIndex:
      O << TAI->getPrivateGlobalPrefix() << "JTI" << getFunctionNumber()
      << '_' << MO.getIndex();
      break;

    // FIXME: Verify correct
    case MachineOperand::MO_ConstantPoolIndex:
      O << TAI->getPrivateGlobalPrefix() << "CPI"
        << getFunctionNumber() << "_" << MO.getIndex();
      break;
  
    default:
      O << "<unknown operand type>"; abort (); break;
  }

  if (closeP) O << ")";
}

void MipsAsmPrinter::
printMemOperand(const MachineInstr *MI, int opNum, const char *Modifier) 
{
  // when using stack locations for not load/store instructions
  // print the same way as all normal 3 operand instructions.
  if (Modifier && !strcmp(Modifier, "stackloc")) {
    printOperand(MI, opNum+1);
    O << ", ";
    printOperand(MI, opNum);
    return;
  }

  // Load/Store memory operands -- imm($reg) 
  // If PIC target the target is loaded as the 
  // pattern lw $25,%call16($28)
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
      unsigned Size    = TD->getABITypeSize(C->getType());
      unsigned Align   = TD->getPreferredAlignmentLog(I);

      // Is this correct ?
      if (C->isNullValue() && (I->hasLinkOnceLinkage() || 
          I->hasInternalLinkage() || I->hasWeakLinkage())) 
      {
        if (Size == 0) Size = 1;   // .comm Foo, 0 is undefined, avoid it.

        if (!NoZerosInBSS && TAI->getBSSSection())
          SwitchToDataSection(TAI->getBSSSection(), I);
        else
          SwitchToDataSection(TAI->getDataSection(), I);

        if (I->hasInternalLinkage()) {
          if (TAI->getLCOMMDirective())
            O << TAI->getLCOMMDirective() << name << "," << Size;
          else            
            O << "\t.local\t" << name << "\n";
        } else {
          O << TAI->getCOMMDirective() << name << "," << Size;
          // The .comm alignment in bytes.
          if (TAI->getCOMMDirectiveTakesAlignment())
            O << "," << (1 << Align);
        }

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
            O << TAI->getGlobalDirective() << name << "\n";
            // Fall Through
          case GlobalValue::InternalLinkage:
            // FIXME: special handling for ".ctors" & ".dtors" sections
            if (I->hasSection() && (I->getSection() == ".ctors" ||
                I->getSection() == ".dtors")) {
              std::string SectionName = ".section " + I->getSection();
              SectionName += ",\"aw\",%progbits";
              SwitchToDataSection(SectionName.c_str());
            } else {
              if (C->isNullValue() && !NoZerosInBSS && TAI->getBSSSection())
                SwitchToDataSection(TAI->getBSSSection(), I);
              else if (!I->isConstant())
                SwitchToDataSection(TAI->getDataSection(), I);
              else {
                // Read-only data.
                if (TAI->getReadOnlySection())
                  SwitchToDataSection(TAI->getReadOnlySection(), I);
                else
                  SwitchToDataSection(TAI->getDataSection(), I);
              }
            }
            break;
          case GlobalValue::GhostLinkage:
            cerr << "Should not have any unmaterialized functions!\n";
            abort();
          case GlobalValue::DLLImportLinkage:
            cerr << "DLLImport linkage is not supported by this target!\n";
            abort();
          case GlobalValue::DLLExportLinkage:
            cerr << "DLLExport linkage is not supported by this target!\n";
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
