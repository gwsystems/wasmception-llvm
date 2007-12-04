//===-- SPUISelLowering.h - Cell SPU DAG Lowering Interface -----*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file was developed by a team from the Computer Systems Research
// Department at The Aerospace Corporation.
//
// See README.txt for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines the interfaces that Cell SPU uses to lower LLVM code into
// a selection DAG.
//
//===----------------------------------------------------------------------===//

#ifndef SPU_ISELLOWERING_H
#define SPU_ISELLOWERING_H

#include "llvm/Target/TargetLowering.h"
#include "llvm/CodeGen/SelectionDAG.h"
#include "SPU.h"

namespace llvm {
  namespace SPUISD {
    enum NodeType {
      // Start the numbering where the builting ops and target ops leave off.
      FIRST_NUMBER = ISD::BUILTIN_OP_END+SPU::INSTRUCTION_LIST_END,
      
      // Pseudo instructions:
      RET_FLAG,                 ///< Return with flag, matched by bi instruction
      
      Hi,                       ///< High address component (upper 16)
      Lo,                       ///< Low address component (lower 16)
      PCRelAddr,                ///< Program counter relative address
      DFormAddr,                ///< D-Form address "imm($r)"
      XFormAddr,		///< X-Form address "$r1($r2)"

      LDRESULT,                 ///< Load result (value, chain)
      CALL,                     ///< CALL instruction
      SHUFB,                    ///< Vector shuffle (permute)
      INSERT_MASK,              ///< Insert element shuffle mask
      CNTB,			///< Count leading ones in bytes
      PROMOTE_SCALAR,           ///< Promote scalar->vector
      EXTRACT_ELT0,             ///< Extract element 0
      EXTRACT_ELT0_CHAINED,	///< Extract element 0, with chain
      EXTRACT_I1_ZEXT,          ///< Extract element 0 as i1, zero extend
      EXTRACT_I1_SEXT,          ///< Extract element 0 as i1, sign extend
      EXTRACT_I8_ZEXT,          ///< Extract element 0 as i8, zero extend
      EXTRACT_I8_SEXT,          ///< Extract element 0 as i8, sign extend
      MPY,			///< 16-bit Multiply (low parts of a 32-bit)
      MPYU,			///< Multiply Unsigned
      MPYH,			///< Multiply High
      MPYHH,			///< Multiply High-High
      VEC_SHL,			///< Vector shift left
      VEC_SRL,			///< Vector shift right (logical)
      VEC_SRA,			///< Vector shift right (arithmetic)
      VEC_ROTL,			///< Vector rotate left
      VEC_ROTR,			///< Vector rotate right
      ROTBYTES_RIGHT_Z,		///< Vector rotate right, by bytes, zero fill
      ROTBYTES_RIGHT_S,         ///< Vector rotate right, by bytes, sign fill
      ROTBYTES_LEFT,		///< Rotate bytes (loads -> ROTQBYI)
      ROTBYTES_LEFT_CHAINED,	///< Rotate bytes (loads -> ROTQBYI), with chain
      FSMBI,			///< Form Select Mask for Bytes, Immediate
      SELB,			///< Select bits -> (b & mask) | (a & ~mask)
      SFPConstant,		///< Single precision floating point constant
      FPInterp,                 ///< Floating point interpolate
      FPRecipEst,		///< Floating point reciprocal estimate
      SEXT32TO64,		///< Sign-extended 32-bit const -> 64-bits
      LAST_SPUISD		///< Last user-defined instruction
    };
  }

  /// Predicates that are used for node matching:
  namespace SPU {
    SDOperand get_vec_u18imm(SDNode *N, SelectionDAG &DAG,
                             MVT::ValueType ValueType);
    SDOperand get_vec_i16imm(SDNode *N, SelectionDAG &DAG,
                             MVT::ValueType ValueType);
    SDOperand get_vec_i10imm(SDNode *N, SelectionDAG &DAG,
                             MVT::ValueType ValueType);
    SDOperand get_vec_i8imm(SDNode *N, SelectionDAG &DAG,
                            MVT::ValueType ValueType);
    SDOperand get_ILHUvec_imm(SDNode *N, SelectionDAG &DAG,
                              MVT::ValueType ValueType);
    SDOperand get_v4i32_imm(SDNode *N, SelectionDAG &DAG);
    SDOperand get_v2i64_imm(SDNode *N, SelectionDAG &DAG);
  }

  class SPUTargetMachine;            // forward dec'l.
  
  class SPUTargetLowering :
    public TargetLowering
  {
    int VarArgsFrameIndex;            // FrameIndex for start of varargs area.
    int ReturnAddrIndex;              // FrameIndex for return slot.
    SPUTargetMachine &SPUTM;

  public:
    SPUTargetLowering(SPUTargetMachine &TM);
    
    /// getTargetNodeName() - This method returns the name of a target specific
    /// DAG node.
    virtual const char *getTargetNodeName(unsigned Opcode) const;
    
    /// LowerOperation - Provide custom lowering hooks for some operations.
    ///
    virtual SDOperand LowerOperation(SDOperand Op, SelectionDAG &DAG);
    
    virtual SDOperand PerformDAGCombine(SDNode *N, DAGCombinerInfo &DCI) const;

    virtual void computeMaskedBitsForTargetNode(const SDOperand Op,
                                                uint64_t Mask,
                                                uint64_t &KnownZero, 
                                                uint64_t &KnownOne,
                                                const SelectionDAG &DAG,
                                                unsigned Depth = 0) const;

    virtual MachineBasicBlock *InsertAtEndOfBasicBlock(MachineInstr *MI,
                                                       MachineBasicBlock *MBB);
    
    ConstraintType getConstraintType(const std::string &ConstraintLetter) const;

    std::pair<unsigned, const TargetRegisterClass*> 
      getRegForInlineAsmConstraint(const std::string &Constraint,
                                   MVT::ValueType VT) const;

    void LowerAsmOperandForConstraint(SDOperand Op, char ConstraintLetter,
                                      std::vector<SDOperand> &Ops,
                                      SelectionDAG &DAG);

    /// isLegalAddressImmediate - Return true if the integer value can be used
    /// as the offset of the target addressing mode.
    virtual bool isLegalAddressImmediate(int64_t V, const Type *Ty) const;
    virtual bool isLegalAddressImmediate(GlobalValue *) const;
  };
}

#endif
