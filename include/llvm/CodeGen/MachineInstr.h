//===-- llvm/CodeGen/MachineInstr.h - MachineInstr class ---------*- C++ -*--=//
//
// This file contains the declaration of the MachineInstr class, which is the
// basic representation for all target dependant machine instructions used by
// the back end.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_CODEGEN_MACHINEINSTR_H
#define LLVM_CODEGEN_MACHINEINSTR_H

#include "llvm/Target/MachineInstrInfo.h"
#include <iterator>
class Instruction;
template<class _MI, class _V> class ValOpIterator;


//---------------------------------------------------------------------------
// class MachineOperand 
// 
// Purpose:
//   Representation of each machine instruction operand.
//   This class is designed so that you can allocate a vector of operands
//   first and initialize each one later.
//
//   E.g, for this VM instruction:
//		ptr = alloca type, numElements
//   we generate 2 machine instructions on the SPARC:
// 
//		mul Constant, Numelements -> Reg
//		add %sp, Reg -> Ptr
// 
//   Each instruction has 3 operands, listed above.  Of those:
//   -	Reg, NumElements, and Ptr are of operand type MO_Register.
//   -	Constant is of operand type MO_SignExtendedImmed on the SPARC.
//	
//   For the register operands, the virtual register type is as follows:
//	
//   -  Reg will be of virtual register type MO_MInstrVirtualReg.  The field
//	MachineInstr* minstr will point to the instruction that computes reg.
// 
//   -	%sp will be of virtual register type MO_MachineReg.
//	The field regNum identifies the machine register.
// 
//   -	NumElements will be of virtual register type MO_VirtualReg.
//	The field Value* value identifies the value.
// 
//   -	Ptr will also be of virtual register type MO_VirtualReg.
//	Again, the field Value* value identifies the value.
// 
//---------------------------------------------------------------------------


class MachineOperand {
public:
  enum MachineOperandType {
    MO_VirtualRegister,		// virtual register for *value
    MO_MachineRegister,		// pre-assigned machine register `regNum'
    MO_CCRegister,
    MO_SignExtendedImmed,
    MO_UnextendedImmed,
    MO_PCRelativeDisp,
  };
  
private:
  MachineOperandType opType;
  
  union {
    Value*	value;		// BasicBlockVal for a label operand.
				// ConstantVal for a non-address immediate.
				// Virtual register for an SSA operand,
				// including hidden operands required for
				// the generated machine code.     
    int64_t immedVal;		// constant value for an explicit constant
  };

  int regNum;	                // register number for an explicit register
                                // will be set for a value after reg allocation
  bool isDef;                   // is this a defition for the value
  
public:
  /*ctor*/		MachineOperand	();
  /*ctor*/		MachineOperand	(MachineOperandType operandType,
					 Value* _val);
  /*copy ctor*/		MachineOperand	(const MachineOperand&);
  /*dtor*/		~MachineOperand	() {}
  
  // Accessor methods.  Caller is responsible for checking the
  // operand type before invoking the corresponding accessor.
  // 
  inline MachineOperandType getOperandType	() const {
    return opType;
  }
  inline Value*		getVRegValue	() const {
    assert(opType == MO_VirtualRegister || opType == MO_CCRegister || 
	   opType == MO_PCRelativeDisp);
    return value;
  }
  inline int            getMachineRegNum() const {
    assert(opType == MO_MachineRegister);
    return regNum;
  }
  inline int64_t	getImmedValue	() const {
    assert(opType == MO_SignExtendedImmed || opType == MO_UnextendedImmed);
    return immedVal;
  }
  inline bool		opIsDef		() const {
    return isDef;
  }
  
public:
  friend std::ostream& operator<<(std::ostream& os, const MachineOperand& mop);

  
private:
  // These functions are provided so that a vector of operands can be
  // statically allocated and individual ones can be initialized later.
  // Give class MachineInstr gets access to these functions.
  // 
  void			Initialize	(MachineOperandType operandType,
					 Value* _val);
  void			InitializeConst	(MachineOperandType operandType,
					 int64_t intValue);
  void			InitializeReg	(int regNum);

  friend class MachineInstr;
  friend class ValOpIterator<const MachineInstr, const Value>;
  friend class ValOpIterator<      MachineInstr,       Value>;


public:

  // replaces the Value with its corresponding physical register after
  // register allocation is complete
  void setRegForValue(int reg) {
    assert(opType == MO_VirtualRegister || opType == MO_CCRegister || 
	   opType == MO_MachineRegister);
    regNum = reg;
  }

  // used to get the reg number if when one is allocted (must be
  // called only after reg alloc)
  inline int  getAllocatedRegNum() const {
    assert(opType == MO_VirtualRegister || opType == MO_CCRegister || 
	   opType == MO_MachineRegister);
    return regNum;
  }

 
};


inline
MachineOperand::MachineOperand()
  : opType(MO_VirtualRegister),
    immedVal(0),
    regNum(-1),
    isDef(false)
{}

inline
MachineOperand::MachineOperand(MachineOperandType operandType,
			       Value* _val)
  : opType(operandType),
    immedVal(0),
    regNum(-1),
    isDef(false)
{}

inline
MachineOperand::MachineOperand(const MachineOperand& mo)
  : opType(mo.opType),
    isDef(false)
{
  switch(opType) {
  case MO_VirtualRegister:
  case MO_CCRegister:		value = mo.value; break;
  case MO_MachineRegister:	regNum = mo.regNum; break;
  case MO_SignExtendedImmed:
  case MO_UnextendedImmed:
  case MO_PCRelativeDisp:	immedVal = mo.immedVal; break;
  default: assert(0);
  }
}

inline void
MachineOperand::Initialize(MachineOperandType operandType,
			   Value* _val)
{
  opType = operandType;
  value = _val;
  regNum = -1;
}

inline void
MachineOperand::InitializeConst(MachineOperandType operandType,
				int64_t intValue)
{
  opType = operandType;
  value = NULL;
  immedVal = intValue;
  regNum = -1;
}

inline void
MachineOperand::InitializeReg(int _regNum)
{
  opType = MO_MachineRegister;
  value = NULL;
  regNum = (int) _regNum;
}


//---------------------------------------------------------------------------
// class MachineInstr 
// 
// Purpose:
//   Representation of each machine instruction.
// 
//   MachineOpCode must be an enum, defined separately for each target.
//   E.g., It is defined in SparcInstructionSelection.h for the SPARC.
// 
//   opCodeMask is used to record variants of an instruction.
//   E.g., each branch instruction on SPARC has 2 flags (i.e., 4 variants):
//	ANNUL:		   if 1: Annul delay slot instruction.
//	PREDICT-NOT-TAKEN: if 1: predict branch not taken.
//   Instead of creating 4 different opcodes for BNZ, we create a single
//   opcode and set bits in opCodeMask for each of these flags.
//
//  There are 2 kinds of operands:
// 
//  (1) Explicit operands of the machine instruction in vector operands[] 
// 
//  (2) "Implicit operands" are values implicitly used or defined by the
//      machine instruction, such as arguments to a CALL, return value of
//      a CALL (if any), and return value of a RETURN.
//---------------------------------------------------------------------------

class MachineInstr : public NonCopyable {
private:
  MachineOpCode         opCode;
  OpCodeMask            opCodeMask;	// extra bits for variants of an opcode
  std::vector<MachineOperand> operands;
  std::vector<Value*>   implicitRefs;   // values implicitly referenced by this
  std::vector<bool>     implicitIsDef;  // machine instruction (eg, call args)
  
public:
  typedef ValOpIterator<const MachineInstr, const Value> val_const_op_iterator;
  typedef ValOpIterator<const MachineInstr,       Value> val_op_iterator;
  
public:
  /*ctor*/		MachineInstr	(MachineOpCode _opCode,
					 OpCodeMask    _opCodeMask = 0x0);
  /*ctor*/		MachineInstr	(MachineOpCode _opCode,
					 unsigned	numOperands,
					 OpCodeMask    _opCodeMask = 0x0);
  inline           	~MachineInstr	() {}
  const MachineOpCode	getOpCode	() const { return opCode; }

  //
  // Information about explicit operands of the instruction
  // 
  unsigned int		getNumOperands	() const { return operands.size(); }
  
  bool			operandIsDefined(unsigned int i) const;
  
  const MachineOperand& getOperand	(unsigned int i) const;
        MachineOperand& getOperand	(unsigned int i);
  
  //
  // Information about implicit operands of the instruction
  // 
  unsigned int		getNumImplicitRefs() const{return implicitRefs.size();}
  
  bool			implicitRefIsDefined(unsigned int i) const;
  
  const Value*          getImplicitRef  (unsigned int i) const;
        Value*          getImplicitRef  (unsigned int i);
  
  //
  // Debugging support
  // 
  void			dump		(unsigned int indent = 0) const;

  
public:
  friend std::ostream& operator<<(std::ostream& os, const MachineInstr& minstr);
  friend class val_const_op_iterator;
  friend class val_op_iterator;

public:
  // Access to set the operands when building the machine instruction
  void			SetMachineOperand(unsigned int i,
			      MachineOperand::MachineOperandType operandType,
			      Value* _val, bool isDef=false);
  void			SetMachineOperand(unsigned int i,
			      MachineOperand::MachineOperandType operandType,
			      int64_t intValue, bool isDef=false);
  void			SetMachineOperand(unsigned int i,
					  int regNum, 
					  bool isDef=false);

  void                  addImplicitRef	 (Value* val, 
                                          bool isDef=false);
  
  void                  setImplicitRef	 (unsigned int i,
                                          Value* val, 
                                          bool isDef=false);
};


inline MachineOperand&
MachineInstr::getOperand(unsigned int i)
{
  assert(i < operands.size() && "getOperand() out of range!");
  return operands[i];
}

inline const MachineOperand&
MachineInstr::getOperand(unsigned int i) const
{
  assert(i < operands.size() && "getOperand() out of range!");
  return operands[i];
}

inline bool
MachineInstr::operandIsDefined(unsigned int i) const
{
  return getOperand(i).opIsDef();
}

inline bool
MachineInstr::implicitRefIsDefined(unsigned int i) const
{
  assert(i < implicitIsDef.size() && "operand out of range!");
  return implicitIsDef[i];
}

inline const Value*
MachineInstr::getImplicitRef(unsigned int i) const
{
  assert(i < implicitRefs.size() && "getImplicitRef() out of range!");
  return implicitRefs[i];
}

inline Value*
MachineInstr::getImplicitRef(unsigned int i)
{
  assert(i < implicitRefs.size() && "getImplicitRef() out of range!");
  return implicitRefs[i];
}

inline void
MachineInstr::addImplicitRef(Value* val, 
                             bool isDef)
{
  implicitRefs.push_back(val);
  implicitIsDef.push_back(isDef);
}

inline void
MachineInstr::setImplicitRef(unsigned int i,
                             Value* val, 
                             bool isDef)
{
  assert(i < implicitRefs.size() && "setImplicitRef() out of range!");
  implicitRefs[i] = val;
  implicitIsDef[i] = isDef;
}


template<class _MI, class _V>
class ValOpIterator : public std::forward_iterator<_V, ptrdiff_t> {
private:
  unsigned int i;
  int resultPos;
  _MI* minstr;
  
  inline void	skipToNextVal() {
    while (i < minstr->getNumOperands() &&
	   ! ((minstr->operands[i].opType == MachineOperand::MO_VirtualRegister
	       || minstr->operands[i].opType == MachineOperand::MO_CCRegister)
	      && minstr->operands[i].value != NULL))
      ++i;
  }
  
public:
  typedef ValOpIterator<_MI, _V> _Self;
  
  inline ValOpIterator(_MI* _minstr) : i(0), minstr(_minstr) {
    resultPos = TargetInstrDescriptors[minstr->opCode].resultPos;
    skipToNextVal();
  };
  
  inline _V*	operator*()  const { return minstr->getOperand(i).getVRegValue();}

  const MachineOperand & getMachineOperand() const { return minstr->getOperand(i);  }

  inline _V*	operator->() const { return operator*(); }
  //  inline bool	isDef	()   const { return (((int) i) == resultPos); }
  
  inline bool	isDef	()   const { return minstr->getOperand(i).isDef; } 
  inline bool	done	()   const { return (i == minstr->getNumOperands()); }
  
  inline _Self& operator++()	   { i++; skipToNextVal(); return *this; }
  inline _Self  operator++(int)	   { _Self tmp = *this; ++*this; return tmp; }
};


//---------------------------------------------------------------------------
// class MachineCodeForBasicBlock
// 
// Purpose:
//   Representation of the sequence of machine instructions created
//   for a basic block.
//---------------------------------------------------------------------------


class MachineCodeForBasicBlock: public std::vector<MachineInstr*> {
public:
  typedef std::vector<MachineInstr*>::iterator iterator;
  typedef std::vector<MachineInstr*>::const_iterator const_iterator;
};


//---------------------------------------------------------------------------
// Debugging Support
//---------------------------------------------------------------------------


std::ostream& operator<<    (std::ostream& os, const MachineInstr& minstr);


std::ostream& operator<<    (std::ostream& os, const MachineOperand& mop);
					 

void	PrintMachineInstructions(const Method *method);


//**************************************************************************/

#endif
