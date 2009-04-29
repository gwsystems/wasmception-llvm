//===-- XCoreAsmPrinter.cpp - XCore LLVM assembly writer ------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains a printer that converts from our internal representation
// of machine-dependent LLVM code to the XAS-format XCore assembly language.
//
//===----------------------------------------------------------------------===//

#define DEBUG_TYPE "asm-printer"
#include "XCore.h"
#include "XCoreInstrInfo.h"
#include "XCoreSubtarget.h"
#include "XCoreTargetMachine.h"
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
#include "llvm/Support/Mangler.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/ADT/StringExtras.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/MathExtras.h"
#include "llvm/Support/raw_ostream.h"
#include <algorithm>
#include <cctype>
using namespace llvm;

STATISTIC(EmittedInsts, "Number of machine instrs printed");

static cl::opt<std::string> FileDirective("xcore-file-directive", cl::Optional,
  cl::desc("Output a file directive into the assembly file"),
  cl::Hidden,
  cl::value_desc("filename"),
  cl::init(""));

static cl::opt<unsigned> MaxThreads("xcore-max-threads", cl::Optional,
  cl::desc("Maximum number of threads (for emulation thread-local storage)"),
  cl::Hidden,
  cl::value_desc("number"),
  cl::init(8));

namespace {
  class VISIBILITY_HIDDEN XCoreAsmPrinter : public AsmPrinter {
    DwarfWriter *DW;
    const XCoreSubtarget &Subtarget;
  public:
    XCoreAsmPrinter(raw_ostream &O, XCoreTargetMachine &TM,
                    const TargetAsmInfo *T, unsigned OL, bool V)
      : AsmPrinter(O, TM, T, OL, V), DW(0),
        Subtarget(*TM.getSubtargetImpl()) {}

    virtual const char *getPassName() const {
      return "XCore Assembly Printer";
    }

    void printMemOperand(const MachineInstr *MI, int opNum);
    void printOperand(const MachineInstr *MI, int opNum);
    bool PrintAsmOperand(const MachineInstr *MI, unsigned OpNo,
                        unsigned AsmVariant, const char *ExtraCode);
    
    void emitFileDirective(const std::string &filename);
    void emitGlobalDirective(const std::string &name);
    void emitExternDirective(const std::string &name);
    
    void emitArrayBound(const std::string &name, const GlobalVariable *GV);
    void emitGlobal(const GlobalVariable *GV);

    void emitFunctionStart(MachineFunction &MF);
    void emitFunctionEnd(MachineFunction &MF);

    bool printInstruction(const MachineInstr *MI);  // autogenerated.
    void printMachineInstruction(const MachineInstr *MI);
    bool runOnMachineFunction(MachineFunction &F);
    bool doInitialization(Module &M);
    bool doFinalization(Module &M);
    
    void getAnalysisUsage(AnalysisUsage &AU) const {
      AsmPrinter::getAnalysisUsage(AU);
      AU.setPreservesAll();
      AU.addRequired<MachineModuleInfo>();
      AU.addRequired<DwarfWriter>();
    }
  };
} // end of anonymous namespace

#include "XCoreGenAsmWriter.inc"

/// createXCoreCodePrinterPass - Returns a pass that prints the XCore
/// assembly code for a MachineFunction to the given output stream,
/// using the given target machine description.  This should work
/// regardless of whether the function is in SSA form.
///
FunctionPass *llvm::createXCoreCodePrinterPass(raw_ostream &o,
                                               XCoreTargetMachine &tm,
                                               unsigned OptLevel,
                                               bool verbose) {
  return new XCoreAsmPrinter(o, tm, tm.getTargetAsmInfo(), OptLevel, verbose);
}

// PrintEscapedString - Print each character of the specified string, escaping
// it if it is not printable or if it is an escape char.
static void PrintEscapedString(const std::string &Str, raw_ostream &Out) {
  for (unsigned i = 0, e = Str.size(); i != e; ++i) {
    unsigned char C = Str[i];
    if (isprint(C) && C != '"' && C != '\\') {
      Out << C;
    } else {
      Out << '\\'
          << (char) ((C/16  < 10) ? ( C/16 +'0') : ( C/16 -10+'A'))
          << (char)(((C&15) < 10) ? ((C&15)+'0') : ((C&15)-10+'A'));
    }
  }
}

void XCoreAsmPrinter::
emitFileDirective(const std::string &name)
{
  O << "\t.file\t\"";
  PrintEscapedString(name, O);
  O << "\"\n";
}

void XCoreAsmPrinter::
emitGlobalDirective(const std::string &name)
{
  O << TAI->getGlobalDirective() << name;
  O << "\n";
}

void XCoreAsmPrinter::
emitExternDirective(const std::string &name)
{
  O << "\t.extern\t" << name;
  O << '\n';
}

void XCoreAsmPrinter::
emitArrayBound(const std::string &name, const GlobalVariable *GV)
{
  assert(((GV->hasExternalLinkage() ||
    GV->hasWeakLinkage()) ||
    GV->hasLinkOnceLinkage()) && "Unexpected linkage");
  if (const ArrayType *ATy = dyn_cast<ArrayType>(
    cast<PointerType>(GV->getType())->getElementType()))
  {
    O << TAI->getGlobalDirective() << name << ".globound" << "\n";
    O << TAI->getSetDirective() << name << ".globound" << ","
      << ATy->getNumElements() << "\n";
    if (GV->hasWeakLinkage() || GV->hasLinkOnceLinkage()) {
      // TODO Use COMDAT groups for LinkOnceLinkage
      O << TAI->getWeakDefDirective() << name << ".globound" << "\n";
    }
  }
}

void XCoreAsmPrinter::
emitGlobal(const GlobalVariable *GV)
{
  const TargetData *TD = TM.getTargetData();

  if (GV->hasInitializer()) {
    // Check to see if this is a special global used by LLVM, if so, emit it.
    if (EmitSpecialLLVMGlobal(GV))
      return;

    SwitchToSection(TAI->SectionForGlobal(GV));
    
    std::string name = Mang->getValueName(GV);
    Constant *C = GV->getInitializer();
    unsigned Align = (unsigned)TD->getPreferredTypeAlignmentShift(C->getType());
    
    // Mark the start of the global
    O << "\t.cc_top " << name << ".data," << name << "\n";

    switch (GV->getLinkage()) {
    case GlobalValue::AppendingLinkage:
      cerr << "AppendingLinkage is not supported by this target!\n";
      abort();
    case GlobalValue::LinkOnceAnyLinkage:
    case GlobalValue::LinkOnceODRLinkage:
    case GlobalValue::WeakAnyLinkage:
    case GlobalValue::WeakODRLinkage:
    case GlobalValue::ExternalLinkage:
      emitArrayBound(name, GV);
      emitGlobalDirective(name);
      // TODO Use COMDAT groups for LinkOnceLinkage
      if (GV->hasWeakLinkage() || GV->hasLinkOnceLinkage()) {
        O << TAI->getWeakDefDirective() << name << "\n";
      }
      // FALL THROUGH
    case GlobalValue::InternalLinkage:
    case GlobalValue::PrivateLinkage:
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

    EmitAlignment(Align, GV, 2);
    
    unsigned Size = TD->getTypePaddedSize(C->getType());
    if (GV->isThreadLocal()) {
      Size *= MaxThreads;
    }
    if (TAI->hasDotTypeDotSizeDirective()) {
      O << "\t.type " << name << ",@object\n";
      O << "\t.size " << name << "," << Size << "\n";
    }
    O << name << ":\n";
    
    EmitGlobalConstant(C);
    if (GV->isThreadLocal()) {
      for (unsigned i = 1; i < MaxThreads; ++i) {
        EmitGlobalConstant(C);
      }
    }
    if (Size < 4) {
      // The ABI requires that unsigned scalar types smaller than 32 bits
      // are are padded to 32 bits.
      EmitZeros(4 - Size);
    }
    
    // Mark the end of the global
    O << "\t.cc_bottom " << name << ".data\n";
  } else {
    if (GV->hasExternalWeakLinkage())
      ExtWeakSymbols.insert(GV);
  }
}

/// Emit the directives on the start of functions
void XCoreAsmPrinter::
emitFunctionStart(MachineFunction &MF)
{
  // Print out the label for the function.
  const Function *F = MF.getFunction();

  SwitchToSection(TAI->SectionForGlobal(F));
  
  // Mark the start of the function
  O << "\t.cc_top " << CurrentFnName << ".function," << CurrentFnName << "\n";

  switch (F->getLinkage()) {
  default: assert(0 && "Unknown linkage type!");
  case Function::InternalLinkage:  // Symbols default to internal.
  case Function::PrivateLinkage:
    break;
  case Function::ExternalLinkage:
    emitGlobalDirective(CurrentFnName);
    break;
  case Function::LinkOnceAnyLinkage:
  case Function::LinkOnceODRLinkage:
  case Function::WeakAnyLinkage:
  case Function::WeakODRLinkage:
    // TODO Use COMDAT groups for LinkOnceLinkage
    O << TAI->getGlobalDirective() << CurrentFnName << "\n";
    O << TAI->getWeakDefDirective() << CurrentFnName << "\n";
    break;
  }
  // (1 << 1) byte aligned
  EmitAlignment(1, F, 1);
  if (TAI->hasDotTypeDotSizeDirective()) {
    O << "\t.type " << CurrentFnName << ",@function\n";
  }
  O << CurrentFnName << ":\n";
}

/// Emit the directives on the end of functions
void XCoreAsmPrinter::
emitFunctionEnd(MachineFunction &MF) 
{
  // Mark the end of the function
  O << "\t.cc_bottom " << CurrentFnName << ".function\n";
}

/// runOnMachineFunction - This uses the printMachineInstruction()
/// method to print assembly for each instruction.
///
bool XCoreAsmPrinter::runOnMachineFunction(MachineFunction &MF)
{
  this->MF = &MF;

  SetupMachineFunction(MF);

  // Print out constants referenced by the function
  EmitConstantPool(MF.getConstantPool());

  // Print out jump tables referenced by the function
  EmitJumpTableInfo(MF.getJumpTableInfo(), MF);

  // Emit the function start directives
  emitFunctionStart(MF);
  
  // Emit pre-function debug information.
  DW->BeginFunction(&MF);

  // Print out code for the function.
  for (MachineFunction::const_iterator I = MF.begin(), E = MF.end();
       I != E; ++I) {

    // Print a label for the basic block.
    if (I != MF.begin()) {
      printBasicBlockLabel(I, true , true);
      O << '\n';
    }

    for (MachineBasicBlock::const_iterator II = I->begin(), E = I->end();
         II != E; ++II) {
      // Print the assembly for the instruction.
      O << "\t";
      printMachineInstruction(II);
    }

    // Each Basic Block is separated by a newline
    O << '\n';
  }

  // Emit function end directives
  emitFunctionEnd(MF);
  
  // Emit post-function debug information.
  DW->EndFunction(&MF);

  // We didn't modify anything.
  return false;
}

void XCoreAsmPrinter::printMemOperand(const MachineInstr *MI, int opNum)
{
  printOperand(MI, opNum);
  
  if (MI->getOperand(opNum+1).isImm()
    && MI->getOperand(opNum+1).getImm() == 0)
    return;
  
  O << "+";
  printOperand(MI, opNum+1);
}

void XCoreAsmPrinter::printOperand(const MachineInstr *MI, int opNum) {
  const MachineOperand &MO = MI->getOperand(opNum);
  switch (MO.getType()) {
  case MachineOperand::MO_Register:
    if (TargetRegisterInfo::isPhysicalRegister(MO.getReg()))
      O << TM.getRegisterInfo()->get(MO.getReg()).AsmName;
    else
      assert(0 && "not implemented");
    break;
  case MachineOperand::MO_Immediate:
    O << MO.getImm();
    break;
  case MachineOperand::MO_MachineBasicBlock:
    printBasicBlockLabel(MO.getMBB());
    break;
  case MachineOperand::MO_GlobalAddress:
    {
      const GlobalValue *GV = MO.getGlobal();
      O << Mang->getValueName(GV);
      if (GV->hasExternalWeakLinkage())
        ExtWeakSymbols.insert(GV);
    }
    break;
  case MachineOperand::MO_ExternalSymbol:
    O << MO.getSymbolName();
    break;
  case MachineOperand::MO_ConstantPoolIndex:
    O << TAI->getPrivateGlobalPrefix() << "CPI" << getFunctionNumber()
      << '_' << MO.getIndex();
    break;
  case MachineOperand::MO_JumpTableIndex:
    O << TAI->getPrivateGlobalPrefix() << "JTI" << getFunctionNumber()
      << '_' << MO.getIndex();
    break;
  default:
    assert(0 && "not implemented");
  }
}

/// PrintAsmOperand - Print out an operand for an inline asm expression.
///
bool XCoreAsmPrinter::PrintAsmOperand(const MachineInstr *MI, unsigned OpNo,
                                      unsigned AsmVariant, 
                                      const char *ExtraCode) {
  printOperand(MI, OpNo);
  return false;
}

void XCoreAsmPrinter::printMachineInstruction(const MachineInstr *MI) {
  ++EmittedInsts;

  // Check for mov mnemonic
  unsigned src, dst, srcSR, dstSR;
  if (TM.getInstrInfo()->isMoveInstr(*MI, src, dst, srcSR, dstSR)) {
    O << "\tmov ";
    O << TM.getRegisterInfo()->get(dst).AsmName;
    O << ", ";
    O << TM.getRegisterInfo()->get(src).AsmName;
    O << "\n";
    return;
  }
  if (printInstruction(MI)) {
    return;
  }
  assert(0 && "Unhandled instruction in asm writer!");
}

bool XCoreAsmPrinter::doInitialization(Module &M) {
  bool Result = AsmPrinter::doInitialization(M);
  
  if (!FileDirective.empty()) {
    emitFileDirective(FileDirective);
  }
  
  // Print out type strings for external functions here
  for (Module::const_iterator I = M.begin(), E = M.end();
       I != E; ++I) {
    if (I->isDeclaration() && !I->isIntrinsic()) {
      switch (I->getLinkage()) {
      default:
        assert(0 && "Unexpected linkage");
      case Function::ExternalWeakLinkage:
        ExtWeakSymbols.insert(I);
        // fallthrough
      case Function::ExternalLinkage:
        break;
      }
    }
  }

  // Emit initial debug information.
  DW = getAnalysisIfAvailable<DwarfWriter>();
  assert(DW && "Dwarf Writer is not available");
  DW->BeginModule(&M, getAnalysisIfAvailable<MachineModuleInfo>(),
                  O, this, TAI);
  return Result;
}

bool XCoreAsmPrinter::doFinalization(Module &M) {

  // Print out module-level global variables.
  for (Module::const_global_iterator I = M.global_begin(), E = M.global_end();
       I != E; ++I) {
    emitGlobal(I);
  }
  
  // Emit final debug information.
  DW->EndModule();

  return AsmPrinter::doFinalization(M);
}
