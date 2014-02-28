//===-- MipsAsmPrinter.h - Mips LLVM Assembly Printer ----------*- C++ -*--===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// Mips Assembly printer class.
//
//===----------------------------------------------------------------------===//

#ifndef MIPSASMPRINTER_H
#define MIPSASMPRINTER_H

#include "Mips16HardFloatInfo.h"
#include "MipsMCInstLower.h"
#include "MipsMachineFunction.h"
#include "MipsSubtarget.h"
#include "llvm/CodeGen/AsmPrinter.h"
#include "llvm/Support/Compiler.h"
#include "llvm/Target/TargetMachine.h"

namespace llvm {
class MCStreamer;
class MachineInstr;
class MachineBasicBlock;
class MipsTargetStreamer;
class Module;
class raw_ostream;

class LLVM_LIBRARY_VISIBILITY MipsAsmPrinter : public AsmPrinter {
  MipsTargetStreamer &getTargetStreamer();

  void EmitInstrWithMacroNoAT(const MachineInstr *MI);

private:
  // tblgen'erated function.
  bool emitPseudoExpansionLowering(MCStreamer &OutStreamer,
                                   const MachineInstr *MI);

  // lowerOperand - Convert a MachineOperand into the equivalent MCOperand.
  bool lowerOperand(const MachineOperand &MO, MCOperand &MCOp);

  /// MCP - Keep a pointer to constantpool entries of the current
  /// MachineFunction.
  const MachineConstantPool *MCP;

  /// InConstantPool - Maintain state when emitting a sequence of constant
  /// pool entries so we can properly mark them as data regions.
  bool InConstantPool;

  std::map<const char *, const llvm::Mips16HardFloatInfo::FuncSignature *>
  StubsNeeded;

  void EmitJal(MCSymbol *Symbol);

  void EmitInstrReg(unsigned Opcode, unsigned Reg);

  void EmitInstrRegReg(unsigned Opcode, unsigned Reg1, unsigned Reg2);

  void EmitInstrRegRegReg(unsigned Opcode, unsigned Reg1, unsigned Reg2,
                          unsigned Reg3);

  void EmitMovFPIntPair(unsigned MovOpc, unsigned Reg1, unsigned Reg2,
                        unsigned FPReg1, unsigned FPReg2, bool LE);

  void EmitSwapFPIntParams(Mips16HardFloatInfo::FPParamVariant, bool LE,
                           bool ToFP);

  void EmitSwapFPIntRetval(Mips16HardFloatInfo::FPReturnVariant, bool LE);

  void EmitFPCallStub(const char *, const Mips16HardFloatInfo::FuncSignature *);

  void NaClAlignIndirectJumpTargets(MachineFunction &MF);

public:

  const MipsSubtarget *Subtarget;
  const MipsFunctionInfo *MipsFI;
  MipsMCInstLower MCInstLowering;

  explicit MipsAsmPrinter(TargetMachine &TM,  MCStreamer &Streamer)
    : AsmPrinter(TM, Streamer), MCP(0), InConstantPool(false),
      MCInstLowering(*this) {
    Subtarget = &TM.getSubtarget<MipsSubtarget>();
  }

  virtual const char *getPassName() const {
    return "Mips Assembly Printer";
  }

  virtual bool runOnMachineFunction(MachineFunction &MF);

  virtual void EmitConstantPool() LLVM_OVERRIDE {
    bool UsingConstantPools =
      (Subtarget->inMips16Mode() && Subtarget->useConstantIslands());
    if (!UsingConstantPools)
      AsmPrinter::EmitConstantPool();
    // we emit constant pools customly!
  }

  void EmitInstruction(const MachineInstr *MI);
  void printSavedRegsBitmask();
  void emitFrameDirective();
  const char *getCurrentABIString() const;
  virtual void EmitFunctionEntryLabel();
  virtual void EmitFunctionBodyStart();
  virtual void EmitFunctionBodyEnd();
  virtual bool isBlockOnlyReachableByFallthrough(const MachineBasicBlock*
                                                 MBB) const;
  bool PrintAsmOperand(const MachineInstr *MI, unsigned OpNo,
                       unsigned AsmVariant, const char *ExtraCode,
                       raw_ostream &O);
  bool PrintAsmMemoryOperand(const MachineInstr *MI, unsigned OpNum,
                             unsigned AsmVariant, const char *ExtraCode,
                             raw_ostream &O);
  void printOperand(const MachineInstr *MI, int opNum, raw_ostream &O);
  void printUnsignedImm(const MachineInstr *MI, int opNum, raw_ostream &O);
  void printUnsignedImm8(const MachineInstr *MI, int opNum, raw_ostream &O);
  void printMemOperand(const MachineInstr *MI, int opNum, raw_ostream &O);
  void printMemOperandEA(const MachineInstr *MI, int opNum, raw_ostream &O);
  void printFCCOperand(const MachineInstr *MI, int opNum, raw_ostream &O,
                       const char *Modifier = 0);
  void EmitStartOfAsmFile(Module &M);
  void EmitEndOfAsmFile(Module &M);
  void PrintDebugValueComment(const MachineInstr *MI, raw_ostream &OS);
};
}

#endif

