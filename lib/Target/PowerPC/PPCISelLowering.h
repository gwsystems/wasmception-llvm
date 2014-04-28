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

#include "PPC.h"
#include "PPCInstrInfo.h"
#include "PPCRegisterInfo.h"
#include "PPCSubtarget.h"
#include "llvm/CodeGen/CallingConvLower.h"
#include "llvm/CodeGen/SelectionDAG.h"
#include "llvm/Target/TargetLowering.h"

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

      /// Newer FCFID[US] integer-to-floating-point conversion instructions for
      /// unsigned integers and single-precision outputs.
      FCFIDU, FCFIDS, FCFIDUS,

      /// FCTI[D,W]Z - The FCTIDZ and FCTIWZ instructions, taking an f32 or f64
      /// operand, producing an f64 value containing the integer representation
      /// of that FP value.
      FCTIDZ, FCTIWZ,

      /// Newer FCTI[D,W]UZ floating-point-to-integer conversion instructions for
      /// unsigned integers.
      FCTIDUZ, FCTIWUZ,

      /// Reciprocal estimate instructions (unary FP ops).
      FRE, FRSQRTE,

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

      /// CALL - A direct function call.
      /// CALL_NOP is a call with the special NOP which follows 64-bit
      /// SVR4 calls.
      CALL, CALL_NOP,

      /// CHAIN,FLAG = MTCTR(VAL, CHAIN[, INFLAG]) - Directly corresponds to a
      /// MTCTR instruction.
      MTCTR,

      /// CHAIN,FLAG = BCTRL(CHAIN, INFLAG) - Directly corresponds to a
      /// BCTRL instruction.
      BCTRL,

      /// Return with a flag operand, matched by 'blr'
      RET_FLAG,

      /// R32 = MFOCRF(CRREG, INFLAG) - Represents the MFOCRF instruction.
      /// This copies the bits corresponding to the specified CRREG into the
      /// resultant GPR.  Bits corresponding to other CR regs are undefined.
      MFOCRF,

      // FIXME: Remove these once the ANDI glue bug is fixed:
      /// i1 = ANDIo_1_[EQ|GT]_BIT(i32 or i64 x) - Represents the result of the
      /// eq or gt bit of CR0 after executing andi. x, 1. This is used to
      /// implement truncation of i32 or i64 to i1.
      ANDIo_1_EQ_BIT, ANDIo_1_GT_BIT,

      // EH_SJLJ_SETJMP - SjLj exception handling setjmp.
      EH_SJLJ_SETJMP,

      // EH_SJLJ_LONGJMP - SjLj exception handling longjmp.
      EH_SJLJ_LONGJMP,

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

      /// CHAIN = BDNZ CHAIN, DESTBB - These are used to create counter-based
      /// loops.
      BDNZ, BDZ,

      /// F8RC = FADDRTZ F8RC, F8RC - This is an FADD done with rounding
      /// towards zero.  Used only as part of the long double-to-int
      /// conversion sequence.
      FADDRTZ,

      /// F8RC = MFFS - This moves the FPSCR (not modeled) into the register.
      MFFS,

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

      /// ch, gl = CR6[UN]SET ch, inglue - Toggle CR bit 6 for SVR4 vararg calls
      CR6SET,
      CR6UNSET,

      /// GPRC = address of _GLOBAL_OFFSET_TABLE_. Used by initial-exec TLS
      /// on PPC32.
      PPC32_GOT,

      /// G8RC = ADDIS_GOT_TPREL_HA %X2, Symbol - Used by the initial-exec
      /// TLS model, produces an ADDIS8 instruction that adds the GOT
      /// base to sym\@got\@tprel\@ha.
      ADDIS_GOT_TPREL_HA,

      /// G8RC = LD_GOT_TPREL_L Symbol, G8RReg - Used by the initial-exec
      /// TLS model, produces a LD instruction with base register G8RReg
      /// and offset sym\@got\@tprel\@l.  This completes the addition that
      /// finds the offset of "sym" relative to the thread pointer.
      LD_GOT_TPREL_L,

      /// G8RC = ADD_TLS G8RReg, Symbol - Used by the initial-exec TLS
      /// model, produces an ADD instruction that adds the contents of
      /// G8RReg to the thread pointer.  Symbol contains a relocation
      /// sym\@tls which is to be replaced by the thread pointer and
      /// identifies to the linker that the instruction is part of a
      /// TLS sequence.
      ADD_TLS,

      /// G8RC = ADDIS_TLSGD_HA %X2, Symbol - For the general-dynamic TLS
      /// model, produces an ADDIS8 instruction that adds the GOT base
      /// register to sym\@got\@tlsgd\@ha.
      ADDIS_TLSGD_HA,

      /// G8RC = ADDI_TLSGD_L G8RReg, Symbol - For the general-dynamic TLS
      /// model, produces an ADDI8 instruction that adds G8RReg to
      /// sym\@got\@tlsgd\@l.
      ADDI_TLSGD_L,

      /// G8RC = GET_TLS_ADDR %X3, Symbol - For the general-dynamic TLS
      /// model, produces a call to __tls_get_addr(sym\@tlsgd).
      GET_TLS_ADDR,

      /// G8RC = ADDIS_TLSLD_HA %X2, Symbol - For the local-dynamic TLS
      /// model, produces an ADDIS8 instruction that adds the GOT base
      /// register to sym\@got\@tlsld\@ha.
      ADDIS_TLSLD_HA,

      /// G8RC = ADDI_TLSLD_L G8RReg, Symbol - For the local-dynamic TLS
      /// model, produces an ADDI8 instruction that adds G8RReg to
      /// sym\@got\@tlsld\@l.
      ADDI_TLSLD_L,

      /// G8RC = GET_TLSLD_ADDR %X3, Symbol - For the local-dynamic TLS
      /// model, produces a call to __tls_get_addr(sym\@tlsld).
      GET_TLSLD_ADDR,

      /// G8RC = ADDIS_DTPREL_HA %X3, Symbol, Chain - For the
      /// local-dynamic TLS model, produces an ADDIS8 instruction
      /// that adds X3 to sym\@dtprel\@ha. The Chain operand is needed
      /// to tie this in place following a copy to %X3 from the result
      /// of a GET_TLSLD_ADDR.
      ADDIS_DTPREL_HA,

      /// G8RC = ADDI_DTPREL_L G8RReg, Symbol - For the local-dynamic TLS
      /// model, produces an ADDI8 instruction that adds G8RReg to
      /// sym\@got\@dtprel\@l.
      ADDI_DTPREL_L,

      /// VRRC = VADD_SPLAT Elt, EltSize - Temporary node to be expanded
      /// during instruction selection to optimize a BUILD_VECTOR into
      /// operations on splats.  This is necessary to avoid losing these
      /// optimizations due to constant folding.
      VADD_SPLAT,

      /// CHAIN = SC CHAIN, Imm128 - System call.  The 7-bit unsigned
      /// operand identifies the operating system entry point.
      SC,

      /// CHAIN = STBRX CHAIN, GPRC, Ptr, Type - This is a
      /// byte-swapping store instruction.  It byte-swaps the low "Type" bits of
      /// the GPRC input, then stores it through Ptr.  Type can be either i16 or
      /// i32.
      STBRX = ISD::FIRST_TARGET_MEMORY_OPCODE,

      /// GPRC, CHAIN = LBRX CHAIN, Ptr, Type - This is a
      /// byte-swapping load instruction.  It loads "Type" bits, byte swaps it,
      /// then puts it in the bottom bits of the GPRC.  TYPE can be either i16
      /// or i32.
      LBRX,

      /// STFIWX - The STFIWX instruction.  The first operand is an input token
      /// chain, then an f64 value to store, then an address to store it to.
      STFIWX,

      /// GPRC, CHAIN = LFIWAX CHAIN, Ptr - This is a floating-point
      /// load which sign-extends from a 32-bit integer value into the
      /// destination 64-bit register.
      LFIWAX,

      /// GPRC, CHAIN = LFIWZX CHAIN, Ptr - This is a floating-point
      /// load which zero-extends from a 32-bit integer value into the
      /// destination 64-bit register.
      LFIWZX,

      /// G8RC = ADDIS_TOC_HA %X2, Symbol - For medium and large code model,
      /// produces an ADDIS8 instruction that adds the TOC base register to
      /// sym\@toc\@ha.
      ADDIS_TOC_HA,

      /// G8RC = LD_TOC_L Symbol, G8RReg - For medium and large code model,
      /// produces a LD instruction with base register G8RReg and offset
      /// sym\@toc\@l. Preceded by an ADDIS_TOC_HA to form a full 32-bit offset.
      LD_TOC_L,

      /// G8RC = ADDI_TOC_L G8RReg, Symbol - For medium code model, produces
      /// an ADDI8 instruction that adds G8RReg to sym\@toc\@l.
      /// Preceded by an ADDIS_TOC_HA to form a full 32-bit offset.
      ADDI_TOC_L
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

    virtual MVT getScalarShiftAmountTy(EVT LHSTy) const { return MVT::i32; }

    /// getSetCCResultType - Return the ISD::SETCC ValueType
    virtual EVT getSetCCResultType(LLVMContext &Context, EVT VT) const;

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
    /// is not better represented as reg+reg.  If Aligned is true, only accept
    /// displacements suitable for STD and friends, i.e. multiples of 4.
    bool SelectAddressRegImm(SDValue N, SDValue &Disp, SDValue &Base,
                             SelectionDAG &DAG, bool Aligned) const;

    /// SelectAddressRegRegOnly - Given the specified addressed, force it to be
    /// represented as an indexed [r+r] operation.
    bool SelectAddressRegRegOnly(SDValue N, SDValue &Base, SDValue &Index,
                                 SelectionDAG &DAG) const;

    Sched::Preference getSchedulingPreference(SDNode *N) const;

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

    MachineBasicBlock *emitEHSjLjSetJmp(MachineInstr *MI,
                                        MachineBasicBlock *MBB) const;

    MachineBasicBlock *emitEHSjLjLongJmp(MachineInstr *MI,
                                         MachineBasicBlock *MBB) const;

    ConstraintType getConstraintType(const std::string &Constraint) const;

    /// Examine constraint string and operand type and determine a weight value.
    /// The operand object must already have been set up with the operand type.
    ConstraintWeight getSingleConstraintMatchWeight(
      AsmOperandInfo &info, const char *constraint) const;

    std::pair<unsigned, const TargetRegisterClass*>
      getRegForInlineAsmConstraint(const std::string &Constraint,
                                   MVT VT) const;

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

    /// isLegalICmpImmediate - Return true if the specified immediate is legal
    /// icmp immediate, that is the target has icmp instructions which can
    /// compare a register against the immediate without having to materialize
    /// the immediate into a register.
    bool isLegalICmpImmediate(int64_t Imm) const override;

    /// isLegalAddImmediate - Return true if the specified immediate is legal
    /// add immediate, that is the target has add instructions which can
    /// add a register and the immediate without having to materialize
    /// the immediate into a register.
    bool isLegalAddImmediate(int64_t Imm) const override;

    /// isTruncateFree - Return true if it's free to truncate a value of
    /// type Ty1 to type Ty2. e.g. On PPC it's free to truncate a i64 value in
    /// register X1 to i32 by referencing its sub-register R1.
    bool isTruncateFree(Type *Ty1, Type *Ty2) const override;
    bool isTruncateFree(EVT VT1, EVT VT2) const override;

    /// \brief Returns true if it is beneficial to convert a load of a constant
    /// to just the constant itself.
    bool shouldConvertConstantLoadToIntImm(const APInt &Imm,
                                           Type *Ty) const override;

    virtual bool isOffsetFoldingLegal(const GlobalAddressSDNode *GA) const;

    /// getOptimalMemOpType - Returns the target specific optimal type for load
    /// and store operations as a result of memset, memcpy, and memmove
    /// lowering. If DstAlign is zero that means it's safe to destination
    /// alignment can satisfy any constraint. Similarly if SrcAlign is zero it
    /// means there isn't a need to check it against alignment requirement,
    /// probably because the source does not need to be loaded. If 'IsMemset' is
    /// true, that means it's expanding a memset. If 'ZeroMemset' is true, that
    /// means it's a memset of zero. 'MemcpyStrSrc' indicates whether the memcpy
    /// source is constant so it does not need to be loaded.
    /// It returns EVT::Other if the type should be determined using generic
    /// target-independent logic.
    virtual EVT
    getOptimalMemOpType(uint64_t Size, unsigned DstAlign, unsigned SrcAlign,
                        bool IsMemset, bool ZeroMemset, bool MemcpyStrSrc,
                        MachineFunction &MF) const;

    /// Is unaligned memory access allowed for the given type, and is it fast
    /// relative to software emulation.
    virtual bool allowsUnalignedMemoryAccesses(EVT VT,
                                               unsigned AddrSpace,
                                               bool *Fast = nullptr) const;

    /// isFMAFasterThanFMulAndFAdd - Return true if an FMA operation is faster
    /// than a pair of fmul and fadd instructions. fmuladd intrinsics will be
    /// expanded to FMAs when this method returns true, otherwise fmuladd is
    /// expanded to fmul + fadd.
    virtual bool isFMAFasterThanFMulAndFAdd(EVT VT) const;

    // Should we expand the build vector with shuffles?
    virtual bool
    shouldExpandBuildVectorWithShuffles(EVT VT,
                                        unsigned DefinedValues) const;

    /// createFastISel - This method returns a target-specific FastISel object,
    /// or null if the target does not support "fast" instruction selection.
    virtual FastISel *createFastISel(FunctionLoweringInfo &FuncInfo,
                                     const TargetLibraryInfo *LibInfo) const;

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
                                         SDLoc dl) const;

    SDValue LowerRETURNADDR(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerFRAMEADDR(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerConstantPool(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerBlockAddress(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerGlobalTLSAddress(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerGlobalAddress(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerJumpTable(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerSETCC(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerINIT_TRAMPOLINE(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerADJUST_TRAMPOLINE(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerVASTART(SDValue Op, SelectionDAG &DAG,
                         const PPCSubtarget &Subtarget) const;
    SDValue LowerVAARG(SDValue Op, SelectionDAG &DAG,
                       const PPCSubtarget &Subtarget) const;
    SDValue LowerVACOPY(SDValue Op, SelectionDAG &DAG,
                        const PPCSubtarget &Subtarget) const;
    SDValue LowerSTACKRESTORE(SDValue Op, SelectionDAG &DAG,
                                const PPCSubtarget &Subtarget) const;
    SDValue LowerDYNAMIC_STACKALLOC(SDValue Op, SelectionDAG &DAG,
                                      const PPCSubtarget &Subtarget) const;
    SDValue LowerLOAD(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerSTORE(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerTRUNCATE(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerSELECT_CC(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerFP_TO_INT(SDValue Op, SelectionDAG &DAG, SDLoc dl) const;
    SDValue LowerINT_TO_FP(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerFLT_ROUNDS_(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerSHL_PARTS(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerSRL_PARTS(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerSRA_PARTS(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerBUILD_VECTOR(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerVECTOR_SHUFFLE(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerINTRINSIC_WO_CHAIN(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerSCALAR_TO_VECTOR(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerSIGN_EXTEND_INREG(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerMUL(SDValue Op, SelectionDAG &DAG) const;

    SDValue LowerCallResult(SDValue Chain, SDValue InFlag,
                            CallingConv::ID CallConv, bool isVarArg,
                            const SmallVectorImpl<ISD::InputArg> &Ins,
                            SDLoc dl, SelectionDAG &DAG,
                            SmallVectorImpl<SDValue> &InVals) const;
    SDValue FinishCall(CallingConv::ID CallConv, SDLoc dl, bool isTailCall,
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
                           SDLoc dl, SelectionDAG &DAG,
                           SmallVectorImpl<SDValue> &InVals) const;

    virtual SDValue
      LowerCall(TargetLowering::CallLoweringInfo &CLI,
                SmallVectorImpl<SDValue> &InVals) const;

    virtual bool
      CanLowerReturn(CallingConv::ID CallConv, MachineFunction &MF,
                   bool isVarArg,
                   const SmallVectorImpl<ISD::OutputArg> &Outs,
                   LLVMContext &Context) const;

    virtual SDValue
      LowerReturn(SDValue Chain,
                  CallingConv::ID CallConv, bool isVarArg,
                  const SmallVectorImpl<ISD::OutputArg> &Outs,
                  const SmallVectorImpl<SDValue> &OutVals,
                  SDLoc dl, SelectionDAG &DAG) const;

    SDValue
      extendArgForPPC64(ISD::ArgFlagsTy Flags, EVT ObjectVT, SelectionDAG &DAG,
                        SDValue ArgVal, SDLoc dl) const;

    void
      setMinReservedArea(MachineFunction &MF, SelectionDAG &DAG,
                         unsigned nAltivecParamsAtEnd,
                         unsigned MinReservedArea, bool isPPC64) const;

    SDValue
      LowerFormalArguments_Darwin(SDValue Chain,
                                  CallingConv::ID CallConv, bool isVarArg,
                                  const SmallVectorImpl<ISD::InputArg> &Ins,
                                  SDLoc dl, SelectionDAG &DAG,
                                  SmallVectorImpl<SDValue> &InVals) const;
    SDValue
      LowerFormalArguments_64SVR4(SDValue Chain,
                                  CallingConv::ID CallConv, bool isVarArg,
                                  const SmallVectorImpl<ISD::InputArg> &Ins,
                                  SDLoc dl, SelectionDAG &DAG,
                                  SmallVectorImpl<SDValue> &InVals) const;
    SDValue
      LowerFormalArguments_32SVR4(SDValue Chain,
                                  CallingConv::ID CallConv, bool isVarArg,
                                  const SmallVectorImpl<ISD::InputArg> &Ins,
                                  SDLoc dl, SelectionDAG &DAG,
                                  SmallVectorImpl<SDValue> &InVals) const;

    SDValue
      createMemcpyOutsideCallSeq(SDValue Arg, SDValue PtrOff,
                                 SDValue CallSeqStart, ISD::ArgFlagsTy Flags,
                                 SelectionDAG &DAG, SDLoc dl) const;

    SDValue
      LowerCall_Darwin(SDValue Chain, SDValue Callee,
                       CallingConv::ID CallConv,
                       bool isVarArg, bool isTailCall,
                       const SmallVectorImpl<ISD::OutputArg> &Outs,
                       const SmallVectorImpl<SDValue> &OutVals,
                       const SmallVectorImpl<ISD::InputArg> &Ins,
                       SDLoc dl, SelectionDAG &DAG,
                       SmallVectorImpl<SDValue> &InVals) const;
    SDValue
      LowerCall_64SVR4(SDValue Chain, SDValue Callee,
                       CallingConv::ID CallConv,
                       bool isVarArg, bool isTailCall,
                       const SmallVectorImpl<ISD::OutputArg> &Outs,
                       const SmallVectorImpl<SDValue> &OutVals,
                       const SmallVectorImpl<ISD::InputArg> &Ins,
                       SDLoc dl, SelectionDAG &DAG,
                       SmallVectorImpl<SDValue> &InVals) const;
    SDValue
    LowerCall_32SVR4(SDValue Chain, SDValue Callee, CallingConv::ID CallConv,
                     bool isVarArg, bool isTailCall,
                     const SmallVectorImpl<ISD::OutputArg> &Outs,
                     const SmallVectorImpl<SDValue> &OutVals,
                     const SmallVectorImpl<ISD::InputArg> &Ins,
                     SDLoc dl, SelectionDAG &DAG,
                     SmallVectorImpl<SDValue> &InVals) const;

    SDValue lowerEH_SJLJ_SETJMP(SDValue Op, SelectionDAG &DAG) const;
    SDValue lowerEH_SJLJ_LONGJMP(SDValue Op, SelectionDAG &DAG) const;

    SDValue DAGCombineExtBoolTrunc(SDNode *N, DAGCombinerInfo &DCI) const;
    SDValue DAGCombineTruncBoolExt(SDNode *N, DAGCombinerInfo &DCI) const;
    SDValue DAGCombineFastRecip(SDValue Op, DAGCombinerInfo &DCI) const;
    SDValue DAGCombineFastRecipFSQRT(SDValue Op, DAGCombinerInfo &DCI) const;

    CCAssignFn *useFastISelCCs(unsigned Flag) const;
  };

  namespace PPC {
    FastISel *createFastISel(FunctionLoweringInfo &FuncInfo,
                             const TargetLibraryInfo *LibInfo);
  }

  bool CC_PPC32_SVR4_Custom_Dummy(unsigned &ValNo, MVT &ValVT, MVT &LocVT,
                                  CCValAssign::LocInfo &LocInfo,
                                  ISD::ArgFlagsTy &ArgFlags,
                                  CCState &State);

  bool CC_PPC32_SVR4_Custom_AlignArgRegs(unsigned &ValNo, MVT &ValVT,
                                         MVT &LocVT,
                                         CCValAssign::LocInfo &LocInfo,
                                         ISD::ArgFlagsTy &ArgFlags,
                                         CCState &State);

  bool CC_PPC32_SVR4_Custom_AlignFPArgRegs(unsigned &ValNo, MVT &ValVT,
                                           MVT &LocVT,
                                           CCValAssign::LocInfo &LocInfo,
                                           ISD::ArgFlagsTy &ArgFlags,
                                           CCState &State);
}

#endif   // LLVM_TARGET_POWERPC_PPC32ISELLOWERING_H
