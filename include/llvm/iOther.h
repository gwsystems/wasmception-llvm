//===-- llvm/iOther.h - "Other" instruction node definitions -----*- C++ -*--=//
//
// This file contains the declarations for instructions that fall into the 
// grandios 'other' catagory...
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_IOTHER_H
#define LLVM_IOTHER_H

#include "llvm/InstrTypes.h"
#include "llvm/Method.h"

//===----------------------------------------------------------------------===//
//                                 CastInst Class
//===----------------------------------------------------------------------===//

// CastInst - This class represents a cast from Operand[0] to the type of
// the instruction (i->getType()).
//
class CastInst : public Instruction {
  CastInst(const CastInst &CI) : Instruction(CI.getType(), Cast) {
    Operands.reserve(1);
    Operands.push_back(Use(CI.Operands[0], this));
  }
public:
  CastInst(Value *S, const Type *Ty, const string &Name = "")
    : Instruction(Ty, Cast, Name) {
    Operands.reserve(1);
    Operands.push_back(Use(S, this));
  }

  virtual Instruction *clone() const { return new CastInst(*this); }
  virtual const char *getOpcodeName() const { return "cast"; }

  // Methods for support type inquiry through isa, cast, and dyn_cast:
  static inline bool classof(const CastInst *) { return true; }
  static inline bool classof(const Instruction *I) {
    return I->getOpcode() == Cast;
  }
  static inline bool classof(const Value *V) {
    return isa<Instruction>(V) && classof(cast<Instruction>(V));
  }
};


//===----------------------------------------------------------------------===//
//                           MethodArgument Class
//===----------------------------------------------------------------------===//

class MethodArgument : public Value {  // Defined in the InstrType.cpp file
  Method *Parent;

  friend class ValueHolder<MethodArgument,Method,Method>;
  inline void setParent(Method *parent) { Parent = parent; }

public:
  MethodArgument(const Type *Ty, const string &Name = "") 
    : Value(Ty, Value::MethodArgumentVal, Name) {
    Parent = 0;
  }

  // Specialize setName to handle symbol table majik...
  virtual void setName(const string &name, SymbolTable *ST = 0);

  inline const Method *getParent() const { return Parent; }
  inline       Method *getParent()       { return Parent; }

  // Methods for support type inquiry through isa, cast, and dyn_cast:
  static inline bool classof(const MethodArgument *) { return true; }
  static inline bool classof(const Value *V) {
    return V->getValueType() == MethodArgumentVal;
  }
};


//===----------------------------------------------------------------------===//
//             Classes to function calls and method invocations
//===----------------------------------------------------------------------===//

class CallInst : public Instruction {
  CallInst(const CallInst &CI);
public:
  CallInst(Value *Meth, const vector<Value*> &params, const string &Name = "");

  virtual const char *getOpcodeName() const { return "call"; }

  virtual Instruction *clone() const { return new CallInst(*this); }
  bool hasSideEffects() const { return true; }

  const Method *getCalledMethod() const {
    return dyn_cast<Method>(Operands[0]);
  }
  Method *getCalledMethod() {
    return dyn_cast<Method>(Operands[0]); 
  }

  // getCalledValue - Get a pointer to a method that is invoked by this inst.
  inline const Value *getCalledValue() const { return Operands[0]; }
  inline       Value *getCalledValue()       { return Operands[0]; }

  // Methods for support type inquiry through isa, cast, and dyn_cast:
  static inline bool classof(const CallInst *) { return true; }
  static inline bool classof(const Instruction *I) {
    return I->getOpcode() == Instruction::Call; 
  }
  static inline bool classof(const Value *V) {
    return isa<Instruction>(V) && classof(cast<Instruction>(V));
  }
};


//===----------------------------------------------------------------------===//
//                                 ShiftInst Class
//===----------------------------------------------------------------------===//

// ShiftInst - This class represents left and right shift instructions.
//
class ShiftInst : public Instruction {
  ShiftInst(const ShiftInst &SI) : Instruction(SI.getType(), SI.getOpcode()) {
    Operands.reserve(2);
    Operands.push_back(Use(SI.Operands[0], this));
    Operands.push_back(Use(SI.Operands[1], this));
  }
public:
  ShiftInst(OtherOps Opcode, Value *S, Value *SA, const string &Name = "")
    : Instruction(S->getType(), Opcode, Name) {
    assert((Opcode == Shl || Opcode == Shr) && "ShiftInst Opcode invalid!");
    Operands.reserve(2);
    Operands.push_back(Use(S, this));
    Operands.push_back(Use(SA, this));
  }

  OtherOps getOpcode() const { return (OtherOps)Instruction::getOpcode(); }

  virtual Instruction *clone() const { return new ShiftInst(*this); }
  virtual const char *getOpcodeName() const {
    return getOpcode() == Shl ? "shl" : "shr"; 
  }

  // Methods for support type inquiry through isa, cast, and dyn_cast:
  static inline bool classof(const ShiftInst *) { return true; }
  static inline bool classof(const Instruction *I) {
    return (I->getOpcode() == Instruction::Shr) | 
           (I->getOpcode() == Instruction::Shl);
  }
  static inline bool classof(const Value *V) {
    return isa<Instruction>(V) && classof(cast<Instruction>(V));
  }
};

#endif
