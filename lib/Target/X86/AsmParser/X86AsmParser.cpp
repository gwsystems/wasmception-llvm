//===-- X86AsmParser.cpp - Parse X86 assembly to MCInst instructions ------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "X86.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/MC/MCAsmLexer.h"
#include "llvm/MC/MCAsmParser.h"
#include "llvm/Target/TargetRegistry.h"
#include "llvm/Target/TargetAsmParser.h"
using namespace llvm;

namespace {
  struct X86Operand {
  };

  class X86ATTAsmParser : public TargetAsmParser {
    MCAsmParser &Parser;

  private:
    bool ParseOperand(X86Operand &Op);
    
    bool MatchInstruction(const StringRef &Name, 
                          llvm::SmallVector<X86Operand, 3> &Operands,
                          MCInst &Inst);

    MCAsmLexer &getLexer() const { return Parser.getLexer(); }

  public:
    X86ATTAsmParser(const Target &T, MCAsmParser &_Parser)
      : TargetAsmParser(T), Parser(_Parser) {}
    
    virtual bool ParseInstruction(MCAsmParser &AP, const StringRef &Name, 
                                  MCInst &Inst);
  };
}

bool X86ATTAsmParser::ParseOperand(X86Operand &Op) {
  return true;
}

bool 
X86ATTAsmParser::MatchInstruction(const StringRef &Name, 
                                  llvm::SmallVector<X86Operand, 3> &Operands,
                                  MCInst &Inst) {
  return false;
}

bool X86ATTAsmParser::ParseInstruction(MCAsmParser &AP, const StringRef &Name, 
                                       MCInst &Inst) {
  llvm::SmallVector<X86Operand, 3> Operands;
  
  return MatchInstruction(Name, Operands, Inst);
}

// Force static initialization.
extern "C" void LLVMInitializeX86AsmParser() {
  RegisterAsmParser<X86ATTAsmParser> X(TheX86_32Target);
  RegisterAsmParser<X86ATTAsmParser> Y(TheX86_64Target);
}
