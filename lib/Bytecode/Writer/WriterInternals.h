//===- WriterInternals.h - Data structures shared by the Writer -*- C++ -*-===//
// 
//                     The LLVM Compiler Infrastructure
//
// This file was developed by the LLVM research group and is distributed under
// the University of Illinois Open Source License. See LICENSE.TXT for details.
// 
//===----------------------------------------------------------------------===//
//
// This header defines the interface used between components of the bytecode
// writer.
//
// Note that the performance of this library is not terribly important, because
// it shouldn't be used by JIT type applications... so it is not a huge focus
// at least.  :)
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_BYTECODE_WRITER_WRITERINTERNALS_H
#define LLVM_LIB_BYTECODE_WRITER_WRITERINTERNALS_H

#include "llvm/Bytecode/Writer.h"
#include "WriterPrimitives.h"
#include "llvm/Bytecode/Format.h"
#include "llvm/SlotCalculator.h"
#include "llvm/Instruction.h"

namespace llvm {

class BytecodeWriter {
  std::deque<unsigned char> &Out;
  SlotCalculator Table;
public:
  BytecodeWriter(std::deque<unsigned char> &o, const Module *M);

private:
  void outputConstants(bool isFunction);
  void outputConstantStrings();
  void outputFunction(const Function *F);
  void processInstruction(const Instruction &I);

  void outputModuleInfoBlock(const Module *C);
  void outputSymbolTable(const SymbolTable &ST);
  void outputConstantsInPlane(const std::vector<const Value*> &Plane,
                              unsigned StartNo);
  void outputConstant(const Constant *CPV);
  void outputType(const Type *T);
};




// BytecodeBlock - Little helper class that helps us do backpatching of bytecode
// block sizes really easily.  It backpatches when it goes out of scope.
//
class BytecodeBlock {
  unsigned Loc;
  std::deque<unsigned char> &Out;

  BytecodeBlock(const BytecodeBlock &);   // do not implement
  void operator=(const BytecodeBlock &);  // do not implement
public:
  inline BytecodeBlock(unsigned ID, std::deque<unsigned char> &o) : Out(o) {
    output(ID, Out);
    output((unsigned)0, Out);         // Reserve the space for the block size...
    Loc = Out.size();
  }

  inline ~BytecodeBlock() {           // Do backpatch when block goes out
                                      // of scope...
    //cerr << "OldLoc = " << Loc << " NewLoc = " << NewLoc << " diff = "
    //     << (NewLoc-Loc) << endl;
    output((unsigned)(Out.size()-Loc), Out, (int)Loc-4);
    align32(Out);  // Blocks must ALWAYS be aligned
  }
};

} // End llvm namespace

#endif
