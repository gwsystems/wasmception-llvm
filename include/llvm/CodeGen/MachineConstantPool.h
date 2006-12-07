//===-- CodeGen/MachineConstantPool.h - Abstract Constant Pool --*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file was developed by the LLVM research group and is distributed under
// the University of Illinois Open Source License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
/// @file This file declares the MachineConstantPool class which is an abstract
/// constant pool to keep track of constants referenced by a function.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_CODEGEN_MACHINECONSTANTPOOL_H
#define LLVM_CODEGEN_MACHINECONSTANTPOOL_H

#include "llvm/ADT/FoldingSet.h"
#include "llvm/CodeGen/SelectionDAGNodes.h"
#include "llvm/Support/Streams.h"
#include <vector>
#include <iosfwd>

namespace llvm {

class AsmPrinter;
class Constant;
class TargetData;
class TargetMachine;
class MachineConstantPool;

/// Abstract base class for all machine specific constantpool value subclasses.
///
class MachineConstantPoolValue {
  const Type *Ty;

public:
  MachineConstantPoolValue(const Type *ty) : Ty(ty) {}
  virtual ~MachineConstantPoolValue() {};

  /// getType - get type of this MachineConstantPoolValue.
  ///
  inline const Type *getType() const { return Ty; }

  virtual int getExistingMachineCPValue(MachineConstantPool *CP,
                                        unsigned Alignment) = 0;

  virtual void AddSelectionDAGCSEId(FoldingSetNodeID &ID) = 0;

  /// print - Implement operator<<...
  ///
  void print(OStream &O) const {
    if (O.stream()) print(*O.stream());
  }
  virtual void print(std::ostream &O) const = 0;
};

inline OStream &operator<<(OStream &OS,
                           const MachineConstantPoolValue &V) {
  V.print(OS);
  return OS;
}
inline std::ostream &operator<<(std::ostream &OS,
                                const MachineConstantPoolValue &V) {
  V.print(OS);
  return OS;
}

/// This class is a data container for one entry in a MachineConstantPool.
/// It contains a pointer to the value and an offset from the start of
/// the constant pool.
/// @brief An entry in a MachineConstantPool
class MachineConstantPoolEntry {
public:
  /// The constant itself.
  union {
    Constant *ConstVal;
    MachineConstantPoolValue *MachineCPVal;
  } Val;

  /// The offset of the constant from the start of the pool. The top bit is set
  /// when Val is a MachineConstantPoolValue.
  unsigned Offset;

  MachineConstantPoolEntry(Constant *V, unsigned O)
    : Offset(O) {
    assert((int)Offset >= 0 && "Offset is too large");
    Val.ConstVal = V;
  }
  MachineConstantPoolEntry(MachineConstantPoolValue *V, unsigned O)
    : Offset(O){
    assert((int)Offset >= 0 && "Offset is too large");
    Val.MachineCPVal = V; 
    Offset |= 1 << (sizeof(unsigned)*8-1);
  }

  bool isMachineConstantPoolEntry() const {
    return (int)Offset < 0;
  }

  int getOffset() const { 
    return Offset & ~(1 << (sizeof(unsigned)*8-1));
  }

  const Type *getType() const;
};
  
/// The MachineConstantPool class keeps track of constants referenced by a
/// function which must be spilled to memory.  This is used for constants which
/// are unable to be used directly as operands to instructions, which typically
/// include floating point and large integer constants.
///
/// Instructions reference the address of these constant pool constants through
/// the use of MO_ConstantPoolIndex values.  When emitting assembly or machine
/// code, these virtual address references are converted to refer to the
/// address of the function constant pool values.
/// @brief The machine constant pool.
class MachineConstantPool {
  const TargetData *TD;   ///< The machine's TargetData.
  unsigned PoolAlignment; ///< The alignment for the pool.
  std::vector<MachineConstantPoolEntry> Constants; ///< The pool of constants.
public:
  /// @brief The only constructor.
  MachineConstantPool(const TargetData *td) : TD(td), PoolAlignment(1) {}
  ~MachineConstantPool();
    
  /// getConstantPoolAlignment - Return the log2 of the alignment required by
  /// the whole constant pool, of which the first element must be aligned.
  unsigned getConstantPoolAlignment() const { return PoolAlignment; }
  
  /// getConstantPoolIndex - Create a new entry in the constant pool or return
  /// an existing one.  User must specify an alignment in bytes for the object.
  unsigned getConstantPoolIndex(Constant *C, unsigned Alignment);
  unsigned getConstantPoolIndex(MachineConstantPoolValue *V,unsigned Alignment);
  
  /// isEmpty - Return true if this constant pool contains no constants.
  bool isEmpty() const { return Constants.empty(); }

  const std::vector<MachineConstantPoolEntry> &getConstants() const {
    return Constants;
  }

  /// print - Used by the MachineFunction printer to print information about
  /// constant pool objects.  Implemented in MachineFunction.cpp
  ///
  void print(OStream &OS) const {
    if (OS.stream()) print(*OS.stream());
  }
  void print(std::ostream &OS) const;

  /// dump - Call print(std::cerr) to be called from the debugger.
  ///
  void dump() const;
};

} // End llvm namespace

#endif
