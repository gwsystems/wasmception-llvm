//===-- ARMInstPrinter.h - Convert ARM MCInst to assembly syntax ----------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This class prints an ARM MCInst to a .s file.
//
//===----------------------------------------------------------------------===//

#ifndef ARMINSTPRINTER_H
#define ARMINSTPRINTER_H

#include "llvm/MC/MCInstPrinter.h"

namespace llvm {
  class MCOperand;
  
class ARMInstPrinter : public MCInstPrinter {
  bool VerboseAsm;
public:
  ARMInstPrinter(raw_ostream &O, const MCAsmInfo &MAI, bool verboseAsm)
    : MCInstPrinter(O, MAI), VerboseAsm(verboseAsm) {}

  virtual void printInst(const MCInst *MI);
  
  // Autogenerated by tblgen.
  void printInstruction(const MCInst *MI);
  static const char *getRegisterName(unsigned RegNo);


  void printOperand(const MCInst *MI, unsigned OpNo,
                    const char *Modifier = 0);
    
  void printSOImmOperand(const MCInst *MI, unsigned OpNum);
  
  
  void printSOImm2PartOperand(const MCInst *MI, unsigned OpNum) {}
  void printSORegOperand(const MCInst *MI, unsigned OpNum) {}
  void printAddrMode2Operand(const MCInst *MI, unsigned OpNum);
  void printAddrMode2OffsetOperand(const MCInst *MI, unsigned OpNum) {}
  void printAddrMode3Operand(const MCInst *MI, unsigned OpNum) {}
  void printAddrMode3OffsetOperand(const MCInst *MI, unsigned OpNum) {}
  void printAddrMode4Operand(const MCInst *MI, unsigned OpNum,
                             const char *Modifier = 0);
  void printAddrMode5Operand(const MCInst *MI, unsigned OpNum,
                             const char *Modifier = 0) {}
  void printAddrMode6Operand(const MCInst *MI, unsigned OpNum) {}
  void printAddrModePCOperand(const MCInst *MI, unsigned OpNum,
                              const char *Modifier = 0) {}
  void printBitfieldInvMaskImmOperand (const MCInst *MI, unsigned OpNum) {}
  
  void printThumbITMask(const MCInst *MI, unsigned OpNum) {}
  void printThumbAddrModeRROperand(const MCInst *MI, unsigned OpNum) {}
  void printThumbAddrModeRI5Operand(const MCInst *MI, unsigned OpNum,
                                    unsigned Scale) {}
  void printThumbAddrModeS1Operand(const MCInst *MI, unsigned OpNum) {}
  void printThumbAddrModeS2Operand(const MCInst *MI, unsigned OpNum) {}
  void printThumbAddrModeS4Operand(const MCInst *MI, unsigned OpNum) {}
  void printThumbAddrModeSPOperand(const MCInst *MI, unsigned OpNum) {}
  
  void printT2SOOperand(const MCInst *MI, unsigned OpNum) {}
  void printT2AddrModeImm12Operand(const MCInst *MI, unsigned OpNum) {}
  void printT2AddrModeImm8Operand(const MCInst *MI, unsigned OpNum) {}
  void printT2AddrModeImm8s4Operand(const MCInst *MI, unsigned OpNum) {}
  void printT2AddrModeImm8OffsetOperand(const MCInst *MI, unsigned OpNum) {}
  void printT2AddrModeSoRegOperand(const MCInst *MI, unsigned OpNum) {}
  
  void printPredicateOperand(const MCInst *MI, unsigned OpNum) {}
  void printSBitModifierOperand(const MCInst *MI, unsigned OpNum) {}
  void printRegisterList(const MCInst *MI, unsigned OpNum);
  void printCPInstOperand(const MCInst *MI, unsigned OpNum,
                          const char *Modifier) {}
  void printJTBlockOperand(const MCInst *MI, unsigned OpNum) {}
  void printJT2BlockOperand(const MCInst *MI, unsigned OpNum) {}
  void printTBAddrMode(const MCInst *MI, unsigned OpNum) {}
  void printNoHashImmediate(const MCInst *MI, unsigned OpNum) {}

  void printPCLabel(const MCInst *MI, unsigned OpNum);  
  // FIXME: Implement.
  void PrintSpecial(const MCInst *MI, const char *Kind) {}
};
  
}

#endif
