//===-- PPCISelLowering.h - PPC32 DAG Lowering Interface --------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines the interfaces that PPC uses to lower LLVM code into a
// selection DAG.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_TARGET_POWERPC_PPC32ISELLOWERING_H
#define LLVM_TARGET_POWERPC_PPC32ISELLOWERING_H

#include "llvm/Target/TargetLowering.h"
#include "llvm/CodeGen/SelectionDAG.h"
#include "PPC.h"
#include "PPCSubtarget.h"

namespace llvm {
  namespace PPCISD {
    enum NodeType {
      // Start the numbering where the builtin ops and target ops leave off.
      FIRST_NUMBER = ISD::BUILTIN_OP_END,

      /// FSEL - Traditional three-operand fsel node.
      ///
      FSEL,

      /// FCFID - The FCFID instruction, taking an f64 operand and producing
      /// and f64 value containing the FP representation of the integer that
      /// was temporarily in the f64 operand.
      FCFID,

      /// FCTI[D,W]Z - The FCTIDZ and FCTIWZ instructions, taking an f32 or f64
      /// operand, producing an f64 value containing the integer representation
      /// of that FP value.
      FCTIDZ, FCTIWZ,

      /// STFIWX - The STFIWX instruction.  The first operand is an input token
      /// chain, then an f64 value to store, then an address to store it to.
      STFIWX,

      // VMADDFP, VNMSUBFP - The VMADDFP and VNMSUBFP instructions, taking
      // three v4f32 operands and producing a v4f32 result.
      VMADDFP, VNMSUBFP,

      /// VPERM - The PPC VPERM Instruction.
      ///
      VPERM,

      /// Hi/Lo - These represent the high and low 16-bit parts of a global
      /// address respectively.  These nodes have two operands, the first of
      /// which must be a TargetGlobalAddress, and the second of which must be a
      /// Constant.  Selected naively, these turn into 'lis G+C' and 'li G+C',
      /// though these are usually folded into other nodes.
      Hi, Lo,

      TOC_ENTRY,

      /// The following three target-specific nodes are used for calls through
      /// function pointers in the 64-bit SVR4 ABI.

      /// Restore the TOC from the TOC save area of the current stack frame.
      /// This is basically a hard coded load instruction which additionally
      /// takes/produces a flag.
      TOC_RESTORE,

      /// Like a regular LOAD but additionally taking/producing a flag.
      LOAD,

      /// LOAD into r2 (also taking/producing a flag). Like TOC_RESTORE, this is
      /// a hard coded load instruction.
      LOAD_TOC,

      /// OPRC, CHAIN = DYNALLOC(CHAIN, NEGSIZE, FRAME_INDEX)
      /// This instruction is lowered in PPCRegisterInfo::eliminateFrameIndex to
      /// compute an allocation on the stack.
      DYNALLOC,

      /// GlobalBaseReg - On Darwin, this node represents the result of the mflr
      /// at function entry, used for PIC code.
      GlobalBaseReg,

      /// These nodes represent the 32-bit PPC shifts that operate on 6-bit
      /// shift amounts.  These nodes are generated by the multi-precision shift
      /// code.
      SRL, SRA, SHL,

      /// EXTSW_32 - This is the EXTSW instruction for use with "32-bit"
      /// registers.
      EXTSW_32,

      /// CALL - A direct function call.
      CALL_Darwin, CALL_SVR4,

      /// NOP - Special NOP which follows 64-bit SVR4 calls.
      NOP,

      /// CHAIN,FLAG = MTCTR(VAL, CHAIN[, INFLAG]) - Directly corresponds to a
      /// MTCTR instruction.
      MTCTR,

      /// CHAIN,FLAG = BCTRL(CHAIN, INFLAG) - Directly corresponds to a
      /// BCTRL instruction.
      BCTRL_Darwin, BCTRL_SVR4,

      /// Return with a flag operand, matched by 'blr'
      RET_FLAG,

      /// R32 = MFCR(CRREG, INFLAG) - Represents the MFCRpseud/MFOCRF
      /// instructions.  This copies the bits corresponding to the specified
      /// CRREG into the resultant GPR.  Bits corresponding to other CR regs
      /// are undefined.
      MFCR,

      /// RESVEC = VCMP(LHS, RHS, OPC) - Represents one of the altivec VCMP*
      /// instructions.  For lack of better number, we use the opcode number
      /// encoding for the OPC field to identify the compare.  For example, 838
      /// is VCMPGTSH.
      VCMP,

      /// RESVEC, OUTFLAG = VCMPo(LHS, RHS, OPC) - Represents one of the
      /// altivec VCMP*o instructions.  For lack of better number, we use the
      /// opcode number encoding for the OPC field to identify the compare.  For
      /// example, 838 is VCMPGTSH.
      VCMPo,

      /// CHAIN = COND_BRANCH CHAIN, CRRC, OPC, DESTBB [, INFLAG] - This
      /// corresponds to the COND_BRANCH pseudo instruction.  CRRC is the
      /// condition register to branch on, OPC is the branch opcode to use (e.g.
      /// PPC::BLE), DESTBB is the destination block to branch to, and INFLAG is
      /// an optional input flag argument.
      COND_BRANCH,

      // The following 5 instructions are used only as part of the
      // long double-to-int conversion sequence.

      /// OUTFLAG = MFFS F8RC - This moves the FPSCR (not modelled) into the
      /// register.
      MFFS,

      /// OUTFLAG = MTFSB0 INFLAG - This clears a bit in the FPSCR.
      MTFSB0,

      /// OUTFLAG = MTFSB1 INFLAG - This sets a bit in the FPSCR.
      MTFSB1,

      /// F8RC, OUTFLAG = FADDRTZ F8RC, F8RC, INFLAG - This is an FADD done with
      /// rounding towards zero.  It has flags added so it won't move past the
      /// FPSCR-setting instructions.
      FADDRTZ,

      /// MTFSF = F8RC, INFLAG - This moves the register into the FPSCR.
      MTFSF,

      /// LARX = This corresponds to PPC l{w|d}arx instrcution: load and
      /// reserve indexed. This is used to implement atomic operations.
      LARX,

      /// STCX = This corresponds to PPC stcx. instrcution: store conditional
      /// indexed. This is used to implement atomic operations.
      STCX,

      /// TC_RETURN - A tail call return.
      ///   operand #0 chain
      ///   operand #1 callee (register or absolute)
      ///   operand #2 stack adjustment
      ///   operand #3 optional in flag
      TC_RETURN,

      /// STD_32 - This is the STD instruction for use with "32-bit" registers.
      STD_32 = ISD::FIRST_TARGET_MEMORY_OPCODE,

      /// CHAIN = STBRX CHAIN, GPRC, Ptr, Type - This is a
      /// byte-swapping store instruction.  It byte-swaps the low "Type" bits of
      /// the GPRC input, then stores it through Ptr.  Type can be either i16 or
      /// i32.
      STBRX,

      /// GPRC, CHAIN = LBRX CHAIN, Ptr, Type - This is a
      /// byte-swapping load instruction.  It loads "Type" bits, byte swaps it,
      /// then puts it in the bottom bits of the GPRC.  TYPE can be either i16
      /// or i32.
      LBRX
    };
  }

  /// Define some predicates that are used for node matching.
  namespace PPC {
    /// isVPKUHUMShuffleMask - Return true if this is the shuffle mask for a
    /// VPKUHUM instruction.
    bool isVPKUHUMShuffleMask(ShuffleVectorSDNode *N, bool isUnary);

    /// isVPKUWUMShuffleMask - Return true if this is the shuffle mask for a
    /// VPKUWUM instruction.
    bool isVPKUWUMShuffleMask(ShuffleVectorSDNode *N, bool isUnary);

    /// isVMRGLShuffleMask - Return true if this is a shuffle mask suitable for
    /// a VRGL* instruction with the specified unit size (1,2 or 4 bytes).
    bool isVMRGLShuffleMask(ShuffleVectorSDNode *N, unsigned UnitSize,
                            bool isUnary);

    /// isVMRGHShuffleMask - Return true if this is a shuffle mask suitable for
    /// a VRGH* instruction with the specified unit size (1,2 or 4 bytes).
    bool isVMRGHShuffleMask(ShuffleVectorSDNode *N, unsigned UnitSize,
                            bool isUnary);

    /// isVSLDOIShuffleMask - If this is a vsldoi shuffle mask, return the shift
    /// amount, otherwise return -1.
    int isVSLDOIShuffleMask(SDNode *N, bool isUnary);

    /// isSplatShuffleMask - Return true if the specified VECTOR_SHUFFLE operand
    /// specifies a splat of a single element that is suitable for input to
    /// VSPLTB/VSPLTH/VSPLTW.
    bool isSplatShuffleMask(ShuffleVectorSDNode *N, unsigned EltSize);

    /// isAllNegativeZeroVector - Returns true if all elements of build_vector
    /// are -0.0.
    bool isAllNegativeZeroVector(SDNode *N);

    /// getVSPLTImmediate - Return the appropriate VSPLT* immediate to splat the
    /// specified isSplatShuffleMask VECTOR_SHUFFLE mask.
    unsigned getVSPLTImmediate(SDNode *N, unsigned EltSize);

    /// get_VSPLTI_elt - If this is a build_vector of constants which can be
    /// formed by using a vspltis[bhw] instruction of the specified element
    /// size, return the constant being splatted.  The ByteSize field indicates
    /// the number of bytes of each element [124] -> [bhw].
    SDValue get_VSPLTI_elt(SDNode *N, unsigned ByteSize, SelectionDAG &DAG);
  }

  class PPCTargetLowering : public TargetLowering {
    const PPCSubtarget &PPCSubTarget;

  public:
    explicit PPCTargetLowering(PPCTargetMachine &TM);

    /// getTargetNodeName() - This method returns the name of a target specific
    /// DAG node.
    virtual const char *getTargetNodeName(unsigned Opcode) const;

    virtual MVT getShiftAmountTy(EVT LHSTy) const { return MVT::i32; }

    /// getSetCCResultType - Return the ISD::SETCC ValueType
    virtual MVT::SimpleValueType getSetCCResultType(EVT VT) const;

    /// getPreIndexedAddressParts - returns true by value, base pointer and
    /// offset pointer and addressing mode by reference if the node's address
    /// can be legally represented as pre-indexed load / store address.
    virtual bool getPreIndexedAddressParts(SDNode *N, SDValue &Base,
                                           SDValue &Offset,
                                           ISD::MemIndexedMode &AM,
                                           SelectionDAG &DAG) const;

    /// SelectAddressRegReg - Given the specified addressed, check to see if it
    /// can be represented as an indexed [r+r] operation.  Returns false if it
    /// can be more efficiently represented with [r+imm].
    bool SelectAddressRegReg(SDValue N, SDValue &Base, SDValue &Index,
                             SelectionDAG &DAG) const;

    /// SelectAddressRegImm - Returns true if the address N can be represented
    /// by a base register plus a signed 16-bit displacement [r+imm], and if it
    /// is not better represented as reg+reg.
    bool SelectAddressRegImm(SDValue N, SDValue &Disp, SDValue &Base,
                             SelectionDAG &DAG) const;

    /// SelectAddressRegRegOnly - Given the specified addressed, force it to be
    /// represented as an indexed [r+r] operation.
    bool SelectAddressRegRegOnly(SDValue N, SDValue &Base, SDValue &Index,
                                 SelectionDAG &DAG) const;

    /// SelectAddressRegImmShift - Returns true if the address N can be
    /// represented by a base register plus a signed 14-bit displacement
    /// [r+imm*4].  Suitable for use by STD and friends.
    bool SelectAddressRegImmShift(SDValue N, SDValue &Disp, SDValue &Base,
                                  SelectionDAG &DAG) const;


    /// LowerOperation - Provide custom lowering hooks for some operations.
    ///
    virtual SDValue LowerOperation(SDValue Op, SelectionDAG &DAG) const;

    /// ReplaceNodeResults - Replace the results of node with an illegal result
    /// type with new values built out of custom code.
    ///
    virtual void ReplaceNodeResults(SDNode *N, SmallVectorImpl<SDValue>&Results,
                                    SelectionDAG &DAG) const;

    virtual SDValue PerformDAGCombine(SDNode *N, DAGCombinerInfo &DCI) const;

    virtual void computeMaskedBitsForTargetNode(const SDValue Op,
                                                const APInt &Mask,
                                                APInt &KnownZero,
                                                APInt &KnownOne,
                                                const SelectionDAG &DAG,
                                                unsigned Depth = 0) const;

    virtual MachineBasicBlock *
      EmitInstrWithCustomInserter(MachineInstr *MI,
                                  MachineBasicBlock *MBB) const;
    MachineBasicBlock *EmitAtomicBinary(MachineInstr *MI,
                                        MachineBasicBlock *MBB, bool is64Bit,
                                        unsigned BinOpcode) const;
    MachineBasicBlock *EmitPartwordAtomicBinary(MachineInstr *MI,
                                                MachineBasicBlock *MBB,
                                            bool is8bit, unsigned Opcode) const;

    ConstraintType getConstraintType(const std::string &Constraint) const;

    /// Examine constraint string and operand type and determine a weight value.
    /// The operand object must already have been set up with the operand type.
    ConstraintWeight getSingleConstraintMatchWeight(
      AsmOperandInfo &info, const char *constraint) const;

    std::pair<unsigned, const TargetRegisterClass*>
      getRegForInlineAsmConstraint(const std::string &Constraint,
                                   EVT VT) const;

    /// getByValTypeAlignment - Return the desired alignment for ByVal aggregate
    /// function arguments in the caller parameter area.  This is the actual
    /// alignment, not its logarithm.
    unsigned getByValTypeAlignment(Type *Ty) const;

    /// LowerAsmOperandForConstraint - Lower the specified operand into the Ops
    /// vector.  If it is invalid, don't add anything to Ops.
    virtual void LowerAsmOperandForConstraint(SDValue Op,
                                              std::string &Constraint,
                                              std::vector<SDValue> &Ops,
                                              SelectionDAG &DAG) const;

    /// isLegalAddressingMode - Return true if the addressing mode represented
    /// by AM is legal for this target, for a load/store of the specified type.
    virtual bool isLegalAddressingMode(const AddrMode &AM, Type *Ty)const;

    /// isLegalAddressImmediate - Return true if the integer value can be used
    /// as the offset of the target addressing mode for load / store of the
    /// given type.
    virtual bool isLegalAddressImmediate(int64_t V, Type *Ty) const;

    /// isLegalAddressImmediate - Return true if the GlobalValue can be used as
    /// the offset of the target addressing mode.
    virtual bool isLegalAddressImmediate(GlobalValue *GV) const;

    virtual bool isOffsetFoldingLegal(const GlobalAddressSDNode *GA) const;

    /// getOptimalMemOpType - Returns the target specific optimal type for load
    /// and store operations as a result of memset, memcpy, and memmove
    /// lowering. If DstAlign is zero that means it's safe to destination
    /// alignment can satisfy any constraint. Similarly if SrcAlign is zero it
    /// means there isn't a need to check it against alignment requirement,
    /// probably because the source does not need to be loaded. If
    /// 'NonScalarIntSafe' is true, that means it's safe to return a
    /// non-scalar-integer type, e.g. empty string source, constant, or loaded
    /// from memory. 'MemcpyStrSrc' indicates whether the memcpy source is
    /// constant so it does not need to be loaded.
    /// It returns EVT::Other if the type should be determined using generic
    /// target-independent logic.
    virtual EVT
    getOptimalMemOpType(uint64_t Size, unsigned DstAlign, unsigned SrcAlign,
                        bool NonScalarIntSafe, bool MemcpyStrSrc,
                        MachineFunction &MF) const;

  private:
    SDValue getFramePointerFrameIndex(SelectionDAG & DAG) const;
    SDValue getReturnAddrFrameIndex(SelectionDAG & DAG) const;

    bool
    IsEligibleForTailCallOptimization(SDValue Callee,
                                      CallingConv::ID CalleeCC,
                                      bool isVarArg,
                                      const SmallVectorImpl<ISD::InputArg> &Ins,
                                      SelectionDAG& DAG) const;

    SDValue EmitTailCallLoadFPAndRetAddr(SelectionDAG & DAG,
                                         int SPDiff,
                                         SDValue Chain,
                                         SDValue &LROpOut,
                                         SDValue &FPOpOut,
                                         bool isDarwinABI,
                                         DebugLoc dl) const;

    SDValue LowerRETURNADDR(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerFRAMEADDR(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerConstantPool(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerBlockAddress(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerGlobalAddress(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerJumpTable(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerSETCC(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerTRAMPOLINE(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerVASTART(SDValue Op, SelectionDAG &DAG,
                         const PPCSubtarget &Subtarget) const;
    SDValue LowerVAARG(SDValue Op, SelectionDAG &DAG,
                       const PPCSubtarget &Subtarget) const;
    SDValue LowerSTACKRESTORE(SDValue Op, SelectionDAG &DAG,
                                const PPCSubtarget &Subtarget) const;
    SDValue LowerDYNAMIC_STACKALLOC(SDValue Op, SelectionDAG &DAG,
                                      const PPCSubtarget &Subtarget) const;
    SDValue LowerSELECT_CC(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerFP_TO_INT(SDValue Op, SelectionDAG &DAG, DebugLoc dl) const;
    SDValue LowerSINT_TO_FP(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerFLT_ROUNDS_(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerSHL_PARTS(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerSRL_PARTS(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerSRA_PARTS(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerBUILD_VECTOR(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerVECTOR_SHUFFLE(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerINTRINSIC_WO_CHAIN(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerSCALAR_TO_VECTOR(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerMUL(SDValue Op, SelectionDAG &DAG) const;

    SDValue LowerCallResult(SDValue Chain, SDValue InFlag,
                            CallingConv::ID CallConv, bool isVarArg,
                            const SmallVectorImpl<ISD::InputArg> &Ins,
                            DebugLoc dl, SelectionDAG &DAG,
                            SmallVectorImpl<SDValue> &InVals) const;
    SDValue FinishCall(CallingConv::ID CallConv, DebugLoc dl, bool isTailCall,
                       bool isVarArg,
                       SelectionDAG &DAG,
                       SmallVector<std::pair<unsigned, SDValue>, 8>
                         &RegsToPass,
                       SDValue InFlag, SDValue Chain,
                       SDValue &Callee,
                       int SPDiff, unsigned NumBytes,
                       const SmallVectorImpl<ISD::InputArg> &Ins,
                       SmallVectorImpl<SDValue> &InVals) const;

    virtual SDValue
      LowerFormalArguments(SDValue Chain,
                           CallingConv::ID CallConv, bool isVarArg,
                           const SmallVectorImpl<ISD::InputArg> &Ins,
                           DebugLoc dl, SelectionDAG &DAG,
                           SmallVectorImpl<SDValue> &InVals) const;

    virtual SDValue
      LowerCall(SDValue Chain, SDValue Callee,
                CallingConv::ID CallConv, bool isVarArg, bool &isTailCall,
                const SmallVectorImpl<ISD::OutputArg> &Outs,
                const SmallVectorImpl<SDValue> &OutVals,
                const SmallVectorImpl<ISD::InputArg> &Ins,
                DebugLoc dl, SelectionDAG &DAG,
                SmallVectorImpl<SDValue> &InVals) const;

    virtual SDValue
      LowerReturn(SDValue Chain,
                  CallingConv::ID CallConv, bool isVarArg,
                  const SmallVectorImpl<ISD::OutputArg> &Outs,
                  const SmallVectorImpl<SDValue> &OutVals,
                  DebugLoc dl, SelectionDAG &DAG) const;

    SDValue
      LowerFormalArguments_Darwin(SDValue Chain,
                                  CallingConv::ID CallConv, bool isVarArg,
                                  const SmallVectorImpl<ISD::InputArg> &Ins,
                                  DebugLoc dl, SelectionDAG &DAG,
                                  SmallVectorImpl<SDValue> &InVals) const;
    SDValue
      LowerFormalArguments_SVR4(SDValue Chain,
                                CallingConv::ID CallConv, bool isVarArg,
                                const SmallVectorImpl<ISD::InputArg> &Ins,
                                DebugLoc dl, SelectionDAG &DAG,
                                SmallVectorImpl<SDValue> &InVals) const;

    SDValue
      LowerCall_Darwin(SDValue Chain, SDValue Callee,
                       CallingConv::ID CallConv, bool isVarArg, bool isTailCall,
                       const SmallVectorImpl<ISD::OutputArg> &Outs,
                       const SmallVectorImpl<SDValue> &OutVals,
                       const SmallVectorImpl<ISD::InputArg> &Ins,
                       DebugLoc dl, SelectionDAG &DAG,
                       SmallVectorImpl<SDValue> &InVals) const;
    SDValue
      LowerCall_SVR4(SDValue Chain, SDValue Callee,
                     CallingConv::ID CallConv, bool isVarArg, bool isTailCall,
                     const SmallVectorImpl<ISD::OutputArg> &Outs,
                     const SmallVectorImpl<SDValue> &OutVals,
                     const SmallVectorImpl<ISD::InputArg> &Ins,
                     DebugLoc dl, SelectionDAG &DAG,
                     SmallVectorImpl<SDValue> &InVals) const;
  };
}

#endif   // LLVM_TARGET_POWERPC_PPC32ISELLOWERING_H
