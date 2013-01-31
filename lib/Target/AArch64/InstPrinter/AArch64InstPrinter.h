//===-- AArch64InstPrinter.h - Convert AArch64 MCInst to assembly syntax --===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This class prints an AArch64 MCInst to a .s file.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_AARCH64INSTPRINTER_H
#define LLVM_AARCH64INSTPRINTER_H

#include "MCTargetDesc/AArch64BaseInfo.h"
#include "llvm/MC/MCInstPrinter.h"
#include "llvm/MC/MCSubtargetInfo.h"

namespace llvm {

class MCOperand;

class AArch64InstPrinter : public MCInstPrinter {
public:
  AArch64InstPrinter(const MCAsmInfo &MAI, const MCInstrInfo &MII,
                     const MCRegisterInfo &MRI, const MCSubtargetInfo &STI);

  // Autogenerated by tblgen
  void printInstruction(const MCInst *MI, raw_ostream &O);
  bool printAliasInstr(const MCInst *MI, raw_ostream &O);
  static const char *getRegisterName(unsigned RegNo);
  static const char *getInstructionName(unsigned Opcode);

  void printRegName(raw_ostream &O, unsigned RegNum) const;

  template<unsigned MemSize, unsigned RmSize>
  void printAddrRegExtendOperand(const MCInst *MI, unsigned OpNum,
                                 raw_ostream &O) {
    printAddrRegExtendOperand(MI, OpNum, O, MemSize, RmSize);
  }


  void printAddrRegExtendOperand(const MCInst *MI, unsigned OpNum,
                                 raw_ostream &O, unsigned MemSize,
                                 unsigned RmSize);

  void printAddSubImmLSL0Operand(const MCInst *MI,
                                 unsigned OpNum, raw_ostream &O);
  void printAddSubImmLSL12Operand(const MCInst *MI,
                                  unsigned OpNum, raw_ostream &O);

  void printBareImmOperand(const MCInst *MI, unsigned OpNum, raw_ostream &O);

  template<unsigned RegWidth>
  void printBFILSBOperand(const MCInst *MI, unsigned OpNum, raw_ostream &O);
  void printBFIWidthOperand(const MCInst *MI, unsigned OpNum, raw_ostream &O);
  void printBFXWidthOperand(const MCInst *MI, unsigned OpNum, raw_ostream &O);


  void printCondCodeOperand(const MCInst *MI, unsigned OpNum,
                            raw_ostream &O);

  void printCRxOperand(const MCInst *MI, unsigned OpNum,
                       raw_ostream &O);

  void printCVTFixedPosOperand(const MCInst *MI, unsigned OpNum,
                               raw_ostream &O);

  void printFPImmOperand(const MCInst *MI, unsigned OpNum, raw_ostream &o);

  void printFPZeroOperand(const MCInst *MI, unsigned OpNum, raw_ostream &o);

  template<int MemScale>
  void printOffsetUImm12Operand(const MCInst *MI,
                                  unsigned OpNum, raw_ostream &o) {
    printOffsetUImm12Operand(MI, OpNum, o, MemScale);
  }

  void printOffsetUImm12Operand(const MCInst *MI, unsigned OpNum,
                                  raw_ostream &o, int MemScale);

  template<unsigned field_width, unsigned scale>
  void printLabelOperand(const MCInst *MI, unsigned OpNum,
                         raw_ostream &O);

  template<unsigned RegWidth>
  void printLogicalImmOperand(const MCInst *MI, unsigned OpNum, raw_ostream &O);

  template<typename SomeNamedImmMapper>
  void printNamedImmOperand(const MCInst *MI, unsigned OpNum,
                            raw_ostream &O) {
    printNamedImmOperand(SomeNamedImmMapper(), MI, OpNum, O);
  }

  void printNamedImmOperand(const NamedImmMapper &Mapper,
                            const MCInst *MI, unsigned OpNum,
                            raw_ostream &O);

  void printSysRegOperand(const A64SysReg::SysRegMapper &Mapper,
                          const MCInst *MI, unsigned OpNum,
                          raw_ostream &O);

  void printMRSOperand(const MCInst *MI, unsigned OpNum,
                       raw_ostream &O) {
    printSysRegOperand(A64SysReg::MRSMapper(), MI, OpNum, O);
  }

  void printMSROperand(const MCInst *MI, unsigned OpNum,
                       raw_ostream &O) {
    printSysRegOperand(A64SysReg::MSRMapper(), MI, OpNum, O);
  }

  void printShiftOperand(const char *name, const MCInst *MI,
                         unsigned OpIdx, raw_ostream &O);  

  void printLSLOperand(const MCInst *MI, unsigned OpNum, raw_ostream &O);

  void printLSROperand(const MCInst *MI, unsigned OpNum, raw_ostream &O) {
    printShiftOperand("lsr", MI, OpNum, O);
  }
  void printASROperand(const MCInst *MI, unsigned OpNum, raw_ostream &O) {
    printShiftOperand("asr", MI, OpNum, O);
  }
  void printROROperand(const MCInst *MI, unsigned OpNum, raw_ostream &O) {
    printShiftOperand("ror", MI, OpNum, O);
  }

  template<A64SE::ShiftExtSpecifiers Shift>
  void printShiftOperand(const MCInst *MI, unsigned OpNum, raw_ostream &O) {
    printShiftOperand(MI, OpNum, O, Shift);
  }

  void printShiftOperand(const MCInst *MI, unsigned OpNum,
                         raw_ostream &O, A64SE::ShiftExtSpecifiers Sh);


  void printMoveWideImmOperand(const  MCInst *MI, unsigned OpNum,
                               raw_ostream &O);

  template<int MemSize> void
  printSImm7ScaledOperand(const MCInst *MI, unsigned OpNum, raw_ostream &O);

  void printOffsetSImm9Operand(const MCInst *MI, unsigned OpNum,
                               raw_ostream &O);

  void printPRFMOperand(const MCInst *MI, unsigned OpNum, raw_ostream &O);

  template<A64SE::ShiftExtSpecifiers EXT>
  void printRegExtendOperand(const MCInst *MI, unsigned OpNum,
                             raw_ostream &O) {
    printRegExtendOperand(MI, OpNum, O, EXT);
  }

  void printRegExtendOperand(const MCInst *MI, unsigned OpNum,
                             raw_ostream &O, A64SE::ShiftExtSpecifiers Ext);

  void printOperand(const MCInst *MI, unsigned OpNo, raw_ostream &O);
  virtual void printInst(const MCInst *MI, raw_ostream &O, StringRef Annot);

  bool isStackReg(unsigned RegNo) {
    return RegNo == AArch64::XSP || RegNo == AArch64::WSP;
  }


};

}

#endif
