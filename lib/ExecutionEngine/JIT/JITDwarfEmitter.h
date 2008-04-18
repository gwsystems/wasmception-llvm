//===------ JITDwarfEmitter.h - Write dwarf tables into memory ------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines a JITDwarfEmitter object that is used by the JIT to
// write dwarf tables to memory.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_EXECUTION_ENGINE_JIT_DWARFEMITTER_H
#define LLVM_EXECUTION_ENGINE_JIT_DWARFEMITTER_H

namespace llvm {

class Function;
class MachineCodeEmitter;
class MachineFunction;
class MachineModuleInfo;
class MachineMove;
class TargetData;
class TargetMachine;
class TargetRegisterInfo;

class JITDwarfEmitter {
  const TargetData* TD;
  MachineCodeEmitter* MCE;
  const TargetRegisterInfo* RI;
  MachineModuleInfo* MMI;
  JIT& Jit;
  bool needsIndirectEncoding;
  bool stackGrowthDirection;
  
  unsigned char* EmitExceptionTable(MachineFunction* MF,
                                    unsigned char* StartFunction, 
                                    unsigned char* EndFunction);

  void EmitFrameMoves(intptr_t BaseLabelPtr, 
                      const std::vector<MachineMove> &Moves);
    
  unsigned char* EmitCommonEHFrame(const Function* Personality);

  unsigned char* EmitEHFrame(const Function* Personality, 
                             unsigned char* StartBufferPtr,
                             unsigned char* StartFunction, 
                             unsigned char* EndFunction,
                             unsigned char* ExceptionTable);
    
  unsigned GetExceptionTableSize(MachineFunction* MF);
  
  unsigned GetFrameMovesSize(intptr_t BaseLabelPtr, 
                             const std::vector<MachineMove> &Moves);
    
  unsigned GetCommonEHFrameSize(const Function* Personality);

  unsigned GetEHFrameSize(const Function* Personality, 
                          unsigned char* StartFunction); 
    
public:
  
  JITDwarfEmitter(JIT& jit);
  
  unsigned char* EmitDwarfTable(MachineFunction& F, 
                                MachineCodeEmitter& MCE,
                                unsigned char* StartFunction,
                                unsigned char* EndFunction);
  
  
  unsigned GetDwarfTableSize(MachineFunction& F, 
                             MachineCodeEmitter& MCE,
                             unsigned char* StartFunction,
                             unsigned char* EndFunction);

  void setModuleInfo(MachineModuleInfo* Info) {
    MMI = Info;
  }
};


} // end namespace llvm

#endif // LLVM_EXECUTION_ENGINE_JIT_DWARFEMITTER_H
