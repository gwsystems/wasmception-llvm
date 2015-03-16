//===-- HexagonISelDAGToDAG.cpp - A dag to dag inst selector for Hexagon --===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines an instruction selector for the Hexagon target.
//
//===----------------------------------------------------------------------===//

#include "Hexagon.h"
#include "HexagonISelLowering.h"
#include "HexagonTargetMachine.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/CodeGen/SelectionDAGISel.h"
#include "llvm/IR/Intrinsics.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Compiler.h"
#include "llvm/Support/Debug.h"
using namespace llvm;

#define DEBUG_TYPE "hexagon-isel"

static
cl::opt<unsigned>
MaxNumOfUsesForConstExtenders("ga-max-num-uses-for-constant-extenders",
  cl::Hidden, cl::init(2),
  cl::desc("Maximum number of uses of a global address such that we still us a"
           "constant extended instruction"));

//===----------------------------------------------------------------------===//
// Instruction Selector Implementation
//===----------------------------------------------------------------------===//

namespace llvm {
  void initializeHexagonDAGToDAGISelPass(PassRegistry&);
}

//===--------------------------------------------------------------------===//
/// HexagonDAGToDAGISel - Hexagon specific code to select Hexagon machine
/// instructions for SelectionDAG operations.
///
namespace {
class HexagonDAGToDAGISel : public SelectionDAGISel {
  const HexagonTargetMachine& HTM;
  const HexagonSubtarget &HST;
public:
  explicit HexagonDAGToDAGISel(HexagonTargetMachine &tm,
                               CodeGenOpt::Level OptLevel)
      : SelectionDAGISel(tm, OptLevel), HTM(tm),
        HST(tm.getSubtarget<HexagonSubtarget>()) {
    initializeHexagonDAGToDAGISelPass(*PassRegistry::getPassRegistry());
  }

  SDNode *Select(SDNode *N) override;

  // Complex Pattern Selectors.
  inline bool SelectAddrGA(SDValue &N, SDValue &R);
  inline bool SelectAddrGP(SDValue &N, SDValue &R);
  bool SelectGlobalAddress(SDValue &N, SDValue &R, bool UseGP);
  bool SelectAddrFI(SDValue &N, SDValue &R);

  const char *getPassName() const override {
    return "Hexagon DAG->DAG Pattern Instruction Selection";
  }

  SDNode *SelectFrameIndex(SDNode *N);
  /// SelectInlineAsmMemoryOperand - Implement addressing mode selection for
  /// inline asm expressions.
  bool SelectInlineAsmMemoryOperand(const SDValue &Op,
                                    unsigned ConstraintID,
                                    std::vector<SDValue> &OutOps) override;
  SDNode *SelectLoad(SDNode *N);
  SDNode *SelectBaseOffsetLoad(LoadSDNode *LD, SDLoc dl);
  SDNode *SelectIndexedLoad(LoadSDNode *LD, SDLoc dl);
  SDNode *SelectIndexedLoadZeroExtend64(LoadSDNode *LD, unsigned Opcode,
                                        SDLoc dl);
  SDNode *SelectIndexedLoadSignExtend64(LoadSDNode *LD, unsigned Opcode,
                                        SDLoc dl);
  SDNode *SelectBaseOffsetStore(StoreSDNode *ST, SDLoc dl);
  SDNode *SelectIndexedStore(StoreSDNode *ST, SDLoc dl);
  SDNode *SelectStore(SDNode *N);
  SDNode *SelectSHL(SDNode *N);
  SDNode *SelectSelect(SDNode *N);
  SDNode *SelectTruncate(SDNode *N);
  SDNode *SelectMul(SDNode *N);
  SDNode *SelectZeroExtend(SDNode *N);
  SDNode *SelectIntrinsicWOChain(SDNode *N);
  SDNode *SelectIntrinsicWChain(SDNode *N);
  SDNode *SelectConstant(SDNode *N);
  SDNode *SelectConstantFP(SDNode *N);
  SDNode *SelectAdd(SDNode *N);

  // XformMskToBitPosU5Imm - Returns the bit position which
  // the single bit 32 bit mask represents.
  // Used in Clr and Set bit immediate memops.
  SDValue XformMskToBitPosU5Imm(uint32_t Imm) {
    int32_t bitPos;
    bitPos = Log2_32(Imm);
    assert(bitPos >= 0 && bitPos < 32 &&
           "Constant out of range for 32 BitPos Memops");
    return CurDAG->getTargetConstant(bitPos, MVT::i32);
  }

  // XformMskToBitPosU4Imm - Returns the bit position which the single-bit
  // 16 bit mask represents. Used in Clr and Set bit immediate memops.
  SDValue XformMskToBitPosU4Imm(uint16_t Imm) {
    return XformMskToBitPosU5Imm(Imm);
  }

  // XformMskToBitPosU3Imm - Returns the bit position which the single-bit
  // 8 bit mask represents. Used in Clr and Set bit immediate memops.
  SDValue XformMskToBitPosU3Imm(uint8_t Imm) {
    return XformMskToBitPosU5Imm(Imm);
  }

  // Return true if there is exactly one bit set in V, i.e., if V is one of the
  // following integers: 2^0, 2^1, ..., 2^31.
  bool ImmIsSingleBit(uint32_t v) const {
    return isPowerOf2_32(v);
  }

  // XformM5ToU5Imm - Return a target constant with the specified value, of
  // type i32 where the negative literal is transformed into a positive literal
  // for use in -= memops.
  inline SDValue XformM5ToU5Imm(signed Imm) {
     assert( (Imm >= -31 && Imm <= -1)  && "Constant out of range for Memops");
     return CurDAG->getTargetConstant( - Imm, MVT::i32);
  }

  // XformU7ToU7M1Imm - Return a target constant decremented by 1, in range
  // [1..128], used in cmpb.gtu instructions.
  inline SDValue XformU7ToU7M1Imm(signed Imm) {
    assert((Imm >= 1 && Imm <= 128) && "Constant out of range for cmpb op");
    return CurDAG->getTargetConstant(Imm - 1, MVT::i8);
  }

  // XformS8ToS8M1Imm - Return a target constant decremented by 1.
  inline SDValue XformSToSM1Imm(signed Imm) {
    return CurDAG->getTargetConstant(Imm - 1, MVT::i32);
  }

  // XformU8ToU8M1Imm - Return a target constant decremented by 1.
  inline SDValue XformUToUM1Imm(unsigned Imm) {
    assert((Imm >= 1) && "Cannot decrement unsigned int less than 1");
    return CurDAG->getTargetConstant(Imm - 1, MVT::i32);
  }

  // XformSToSM2Imm - Return a target constant decremented by 2.
  inline SDValue XformSToSM2Imm(unsigned Imm) {
    return CurDAG->getTargetConstant(Imm - 2, MVT::i32);
  }

  // XformSToSM3Imm - Return a target constant decremented by 3.
  inline SDValue XformSToSM3Imm(unsigned Imm) {
    return CurDAG->getTargetConstant(Imm - 3, MVT::i32);
  }

  // Include the pieces autogenerated from the target description.
  #include "HexagonGenDAGISel.inc"

private:
  bool isValueExtension(const SDValue &Val, unsigned FromBits, SDValue &Src);
}; // end HexagonDAGToDAGISel
}  // end anonymous namespace


/// createHexagonISelDag - This pass converts a legalized DAG into a
/// Hexagon-specific DAG, ready for instruction scheduling.
///
namespace llvm {
FunctionPass *createHexagonISelDag(HexagonTargetMachine &TM,
                                   CodeGenOpt::Level OptLevel) {
  return new HexagonDAGToDAGISel(TM, OptLevel);
}
}

static void initializePassOnce(PassRegistry &Registry) {
  const char *Name = "Hexagon DAG->DAG Pattern Instruction Selection";
  PassInfo *PI = new PassInfo(Name, "hexagon-isel",
                              &SelectionDAGISel::ID, nullptr, false, false);
  Registry.registerPass(*PI, true);
}

void llvm::initializeHexagonDAGToDAGISelPass(PassRegistry &Registry) {
  CALL_ONCE_INITIALIZATION(initializePassOnce)
}


// Intrinsics that return a a predicate.
static unsigned doesIntrinsicReturnPredicate(unsigned ID)
{
  switch (ID) {
    default:
      return 0;
    case Intrinsic::hexagon_C2_cmpeq:
    case Intrinsic::hexagon_C2_cmpgt:
    case Intrinsic::hexagon_C2_cmpgtu:
    case Intrinsic::hexagon_C2_cmpgtup:
    case Intrinsic::hexagon_C2_cmpgtp:
    case Intrinsic::hexagon_C2_cmpeqp:
    case Intrinsic::hexagon_C2_bitsset:
    case Intrinsic::hexagon_C2_bitsclr:
    case Intrinsic::hexagon_C2_cmpeqi:
    case Intrinsic::hexagon_C2_cmpgti:
    case Intrinsic::hexagon_C2_cmpgtui:
    case Intrinsic::hexagon_C2_cmpgei:
    case Intrinsic::hexagon_C2_cmpgeui:
    case Intrinsic::hexagon_C2_cmplt:
    case Intrinsic::hexagon_C2_cmpltu:
    case Intrinsic::hexagon_C2_bitsclri:
    case Intrinsic::hexagon_C2_and:
    case Intrinsic::hexagon_C2_or:
    case Intrinsic::hexagon_C2_xor:
    case Intrinsic::hexagon_C2_andn:
    case Intrinsic::hexagon_C2_not:
    case Intrinsic::hexagon_C2_orn:
    case Intrinsic::hexagon_C2_pxfer_map:
    case Intrinsic::hexagon_C2_any8:
    case Intrinsic::hexagon_C2_all8:
    case Intrinsic::hexagon_A2_vcmpbeq:
    case Intrinsic::hexagon_A2_vcmpbgtu:
    case Intrinsic::hexagon_A2_vcmpheq:
    case Intrinsic::hexagon_A2_vcmphgt:
    case Intrinsic::hexagon_A2_vcmphgtu:
    case Intrinsic::hexagon_A2_vcmpweq:
    case Intrinsic::hexagon_A2_vcmpwgt:
    case Intrinsic::hexagon_A2_vcmpwgtu:
    case Intrinsic::hexagon_C2_tfrrp:
    case Intrinsic::hexagon_S2_tstbit_i:
    case Intrinsic::hexagon_S2_tstbit_r:
      return 1;
  }
}

SDNode *HexagonDAGToDAGISel::SelectIndexedLoadSignExtend64(LoadSDNode *LD,
                                                           unsigned Opcode,
                                                           SDLoc dl) {
  SDValue Chain = LD->getChain();
  EVT LoadedVT = LD->getMemoryVT();
  SDValue Base = LD->getBasePtr();
  SDValue Offset = LD->getOffset();
  SDNode *OffsetNode = Offset.getNode();
  int32_t Val = cast<ConstantSDNode>(OffsetNode)->getSExtValue();

  const HexagonInstrInfo &TII = *HST.getInstrInfo();
  if (TII.isValidAutoIncImm(LoadedVT, Val)) {
    SDValue TargetConst = CurDAG->getTargetConstant(Val, MVT::i32);
    SDNode *Result_1 = CurDAG->getMachineNode(Opcode, dl, MVT::i32, MVT::i32,
                                              MVT::Other, Base, TargetConst,
                                              Chain);
    SDNode *Result_2 = CurDAG->getMachineNode(Hexagon::A2_sxtw, dl, MVT::i64,
                                              SDValue(Result_1, 0));
    MachineSDNode::mmo_iterator MemOp = MF->allocateMemRefsArray(1);
    MemOp[0] = LD->getMemOperand();
    cast<MachineSDNode>(Result_1)->setMemRefs(MemOp, MemOp + 1);
    const SDValue Froms[] = { SDValue(LD, 0),
                              SDValue(LD, 1),
                              SDValue(LD, 2) };
    const SDValue Tos[]   = { SDValue(Result_2, 0),
                              SDValue(Result_1, 1),
                              SDValue(Result_1, 2) };
    ReplaceUses(Froms, Tos, 3);
    return Result_2;
  }

  SDValue TargetConst0 = CurDAG->getTargetConstant(0, MVT::i32);
  SDValue TargetConstVal = CurDAG->getTargetConstant(Val, MVT::i32);
  SDNode *Result_1 = CurDAG->getMachineNode(Opcode, dl, MVT::i32, MVT::Other,
                                            Base, TargetConst0, Chain);
  SDNode *Result_2 = CurDAG->getMachineNode(Hexagon::A2_sxtw, dl, MVT::i64,
                                            SDValue(Result_1, 0));
  SDNode* Result_3 = CurDAG->getMachineNode(Hexagon::A2_addi, dl, MVT::i32,
                                            Base, TargetConstVal,
                                            SDValue(Result_1, 1));
  MachineSDNode::mmo_iterator MemOp = MF->allocateMemRefsArray(1);
  MemOp[0] = LD->getMemOperand();
  cast<MachineSDNode>(Result_1)->setMemRefs(MemOp, MemOp + 1);
  const SDValue Froms[] = { SDValue(LD, 0),
                            SDValue(LD, 1),
                            SDValue(LD, 2) };
  const SDValue Tos[]   = { SDValue(Result_2, 0),
                            SDValue(Result_3, 0),
                            SDValue(Result_1, 1) };
  ReplaceUses(Froms, Tos, 3);
  return Result_2;
}


SDNode *HexagonDAGToDAGISel::SelectIndexedLoadZeroExtend64(LoadSDNode *LD,
                                                           unsigned Opcode,
                                                           SDLoc dl) {
  SDValue Chain = LD->getChain();
  EVT LoadedVT = LD->getMemoryVT();
  SDValue Base = LD->getBasePtr();
  SDValue Offset = LD->getOffset();
  SDNode *OffsetNode = Offset.getNode();
  int32_t Val = cast<ConstantSDNode>(OffsetNode)->getSExtValue();

  const HexagonInstrInfo &TII = *HST.getInstrInfo();
  if (TII.isValidAutoIncImm(LoadedVT, Val)) {
    SDValue TargetConstVal = CurDAG->getTargetConstant(Val, MVT::i32);
    SDValue TargetConst0 = CurDAG->getTargetConstant(0, MVT::i32);
    SDNode *Result_1 = CurDAG->getMachineNode(Opcode, dl, MVT::i32,
                                              MVT::i32, MVT::Other, Base,
                                              TargetConstVal, Chain);
    SDNode *Result_2 = CurDAG->getMachineNode(Hexagon::A4_combineir, dl,
                                              MVT::i64, MVT::Other,
                                              TargetConst0,
                                              SDValue(Result_1,0));
    MachineSDNode::mmo_iterator MemOp = MF->allocateMemRefsArray(1);
    MemOp[0] = LD->getMemOperand();
    cast<MachineSDNode>(Result_1)->setMemRefs(MemOp, MemOp + 1);
    const SDValue Froms[] = { SDValue(LD, 0),
                              SDValue(LD, 1),
                              SDValue(LD, 2) };
    const SDValue Tos[]   = { SDValue(Result_2, 0),
                              SDValue(Result_1, 1),
                              SDValue(Result_1, 2) };
    ReplaceUses(Froms, Tos, 3);
    return Result_2;
  }

  // Generate an indirect load.
  SDValue TargetConst0 = CurDAG->getTargetConstant(0, MVT::i32);
  SDValue TargetConstVal = CurDAG->getTargetConstant(Val, MVT::i32);
  SDNode *Result_1 = CurDAG->getMachineNode(Opcode, dl, MVT::i32,
                                            MVT::Other, Base, TargetConst0,
                                            Chain);
  SDNode *Result_2 = CurDAG->getMachineNode(Hexagon::A4_combineir, dl,
                                            MVT::i64, MVT::Other,
                                            TargetConst0,
                                            SDValue(Result_1,0));
  // Add offset to base.
  SDNode* Result_3 = CurDAG->getMachineNode(Hexagon::A2_addi, dl, MVT::i32,
                                            Base, TargetConstVal,
                                            SDValue(Result_1, 1));
  MachineSDNode::mmo_iterator MemOp = MF->allocateMemRefsArray(1);
  MemOp[0] = LD->getMemOperand();
  cast<MachineSDNode>(Result_1)->setMemRefs(MemOp, MemOp + 1);
  const SDValue Froms[] = { SDValue(LD, 0),
                            SDValue(LD, 1),
                            SDValue(LD, 2) };
  const SDValue Tos[]   = { SDValue(Result_2, 0), // Load value.
                            SDValue(Result_3, 0), // New address.
                            SDValue(Result_1, 1) };
  ReplaceUses(Froms, Tos, 3);
  return Result_2;
}


SDNode *HexagonDAGToDAGISel::SelectIndexedLoad(LoadSDNode *LD, SDLoc dl) {
  SDValue Chain = LD->getChain();
  SDValue Base = LD->getBasePtr();
  SDValue Offset = LD->getOffset();
  SDNode *OffsetNode = Offset.getNode();
  // Get the constant value.
  int32_t Val = cast<ConstantSDNode>(OffsetNode)->getSExtValue();
  EVT LoadedVT = LD->getMemoryVT();
  unsigned Opcode = 0;

  // Check for zero extended loads. Treat any-extend loads as zero extended
  // loads.
  ISD::LoadExtType ExtType = LD->getExtensionType();
  bool IsZeroExt = (ExtType == ISD::ZEXTLOAD || ExtType == ISD::EXTLOAD);

  // Figure out the opcode.
  const HexagonInstrInfo &TII = *HST.getInstrInfo();
  if (LoadedVT == MVT::i64) {
    if (TII.isValidAutoIncImm(LoadedVT, Val))
      Opcode = Hexagon::L2_loadrd_pi;
    else
      Opcode = Hexagon::L2_loadrd_io;
  } else if (LoadedVT == MVT::i32) {
    if (TII.isValidAutoIncImm(LoadedVT, Val))
      Opcode = Hexagon::L2_loadri_pi;
    else
      Opcode = Hexagon::L2_loadri_io;
  } else if (LoadedVT == MVT::i16) {
    if (TII.isValidAutoIncImm(LoadedVT, Val))
      Opcode = IsZeroExt ? Hexagon::L2_loadruh_pi : Hexagon::L2_loadrh_pi;
    else
      Opcode = IsZeroExt ? Hexagon::L2_loadruh_io : Hexagon::L2_loadrh_io;
  } else if (LoadedVT == MVT::i8) {
    if (TII.isValidAutoIncImm(LoadedVT, Val))
      Opcode = IsZeroExt ? Hexagon::L2_loadrub_pi : Hexagon::L2_loadrb_pi;
    else
      Opcode = IsZeroExt ? Hexagon::L2_loadrub_io : Hexagon::L2_loadrb_io;
  } else
    llvm_unreachable("unknown memory type");

  // For zero extended i64 loads, we need to add combine instructions.
  if (LD->getValueType(0) == MVT::i64 && IsZeroExt)
    return SelectIndexedLoadZeroExtend64(LD, Opcode, dl);
  // Handle sign extended i64 loads.
  if (LD->getValueType(0) == MVT::i64 && ExtType == ISD::SEXTLOAD)
    return SelectIndexedLoadSignExtend64(LD, Opcode, dl);

  if (TII.isValidAutoIncImm(LoadedVT, Val)) {
    SDValue TargetConstVal = CurDAG->getTargetConstant(Val, MVT::i32);
    SDNode* Result = CurDAG->getMachineNode(Opcode, dl,
                                            LD->getValueType(0),
                                            MVT::i32, MVT::Other, Base,
                                            TargetConstVal, Chain);
    MachineSDNode::mmo_iterator MemOp = MF->allocateMemRefsArray(1);
    MemOp[0] = LD->getMemOperand();
    cast<MachineSDNode>(Result)->setMemRefs(MemOp, MemOp + 1);
    const SDValue Froms[] = { SDValue(LD, 0),
                              SDValue(LD, 1),
                              SDValue(LD, 2)
    };
    const SDValue Tos[]   = { SDValue(Result, 0),
                              SDValue(Result, 1),
                              SDValue(Result, 2)
    };
    ReplaceUses(Froms, Tos, 3);
    return Result;
  } else {
    SDValue TargetConst0 = CurDAG->getTargetConstant(0, MVT::i32);
    SDValue TargetConstVal = CurDAG->getTargetConstant(Val, MVT::i32);
    SDNode* Result_1 = CurDAG->getMachineNode(Opcode, dl,
                                              LD->getValueType(0),
                                              MVT::Other, Base, TargetConst0,
                                              Chain);
    SDNode* Result_2 = CurDAG->getMachineNode(Hexagon::A2_addi, dl, MVT::i32,
                                              Base, TargetConstVal,
                                              SDValue(Result_1, 1));
    MachineSDNode::mmo_iterator MemOp = MF->allocateMemRefsArray(1);
    MemOp[0] = LD->getMemOperand();
    cast<MachineSDNode>(Result_1)->setMemRefs(MemOp, MemOp + 1);
    const SDValue Froms[] = { SDValue(LD, 0),
                              SDValue(LD, 1),
                              SDValue(LD, 2)
    };
    const SDValue Tos[]   = { SDValue(Result_1, 0),
                              SDValue(Result_2, 0),
                              SDValue(Result_1, 1)
    };
    ReplaceUses(Froms, Tos, 3);
    return Result_1;
  }
}


SDNode *HexagonDAGToDAGISel::SelectLoad(SDNode *N) {
  SDNode *result;
  SDLoc dl(N);
  LoadSDNode *LD = cast<LoadSDNode>(N);
  ISD::MemIndexedMode AM = LD->getAddressingMode();

  // Handle indexed loads.
  if (AM != ISD::UNINDEXED) {
    result = SelectIndexedLoad(LD, dl);
  } else {
    result = SelectCode(LD);
  }

  return result;
}


SDNode *HexagonDAGToDAGISel::SelectIndexedStore(StoreSDNode *ST, SDLoc dl) {
  SDValue Chain = ST->getChain();
  SDValue Base = ST->getBasePtr();
  SDValue Offset = ST->getOffset();
  SDValue Value = ST->getValue();
  SDNode *OffsetNode = Offset.getNode();
  // Get the constant value.
  int32_t Val = cast<ConstantSDNode>(OffsetNode)->getSExtValue();
  EVT StoredVT = ST->getMemoryVT();
  EVT ValueVT = Value.getValueType();

  // Offset value must be within representable range
  // and must have correct alignment properties.
  const HexagonInstrInfo &TII = *HST.getInstrInfo();
  if (TII.isValidAutoIncImm(StoredVT, Val)) {
    unsigned Opcode = 0;

    // Figure out the post inc version of opcode.
    if (StoredVT == MVT::i64) Opcode = Hexagon::S2_storerd_pi;
    else if (StoredVT == MVT::i32) Opcode = Hexagon::S2_storeri_pi;
    else if (StoredVT == MVT::i16) Opcode = Hexagon::S2_storerh_pi;
    else if (StoredVT == MVT::i8) Opcode = Hexagon::S2_storerb_pi;
    else llvm_unreachable("unknown memory type");

    if (ST->isTruncatingStore() && ValueVT.getSizeInBits() == 64) {
      assert(StoredVT.getSizeInBits() < 64 && "Not a truncating store");
      Value = CurDAG->getTargetExtractSubreg(Hexagon::subreg_loreg,
                                             dl, MVT::i32, Value);
    }
    SDValue Ops[] = {Base, CurDAG->getTargetConstant(Val, MVT::i32), Value,
                     Chain};
    // Build post increment store.
    SDNode* Result = CurDAG->getMachineNode(Opcode, dl, MVT::i32,
                                            MVT::Other, Ops);
    MachineSDNode::mmo_iterator MemOp = MF->allocateMemRefsArray(1);
    MemOp[0] = ST->getMemOperand();
    cast<MachineSDNode>(Result)->setMemRefs(MemOp, MemOp + 1);

    ReplaceUses(ST, Result);
    ReplaceUses(SDValue(ST,1), SDValue(Result,1));
    return Result;
  }

  // Note: Order of operands matches the def of instruction:
  // def S2_storerd_io
  //   : STInst<(outs), (ins IntRegs:$base, imm:$offset, DoubleRegs:$src1), ...
  // and it differs for POST_ST* for instance.
  SDValue Ops[] = { Base, CurDAG->getTargetConstant(0, MVT::i32), Value,
                    Chain};
  unsigned Opcode = 0;

  // Figure out the opcode.
  if (StoredVT == MVT::i64) Opcode = Hexagon::S2_storerd_io;
  else if (StoredVT == MVT::i32) Opcode = Hexagon::S2_storeri_io;
  else if (StoredVT == MVT::i16) Opcode = Hexagon::S2_storerh_io;
  else if (StoredVT == MVT::i8) Opcode = Hexagon::S2_storerb_io;
  else llvm_unreachable("unknown memory type");

  // Build regular store.
  SDValue TargetConstVal = CurDAG->getTargetConstant(Val, MVT::i32);
  SDNode* Result_1 = CurDAG->getMachineNode(Opcode, dl, MVT::Other, Ops);
  // Build splitted incriment instruction.
  SDNode* Result_2 = CurDAG->getMachineNode(Hexagon::A2_addi, dl, MVT::i32,
                                            Base,
                                            TargetConstVal,
                                            SDValue(Result_1, 0));
  MachineSDNode::mmo_iterator MemOp = MF->allocateMemRefsArray(1);
  MemOp[0] = ST->getMemOperand();
  cast<MachineSDNode>(Result_1)->setMemRefs(MemOp, MemOp + 1);

  ReplaceUses(SDValue(ST,0), SDValue(Result_2,0));
  ReplaceUses(SDValue(ST,1), SDValue(Result_1,0));
  return Result_2;
}

SDNode *HexagonDAGToDAGISel::SelectStore(SDNode *N) {
  SDLoc dl(N);
  StoreSDNode *ST = cast<StoreSDNode>(N);
  ISD::MemIndexedMode AM = ST->getAddressingMode();

  // Handle indexed stores.
  if (AM != ISD::UNINDEXED) {
    return SelectIndexedStore(ST, dl);
  }

  return SelectCode(ST);
}

SDNode *HexagonDAGToDAGISel::SelectMul(SDNode *N) {
  SDLoc dl(N);

  //
  // %conv.i = sext i32 %tmp1 to i64
  // %conv2.i = sext i32 %add to i64
  // %mul.i = mul nsw i64 %conv2.i, %conv.i
  //
  //   --- match with the following ---
  //
  // %mul.i = mpy (%tmp1, %add)
  //

  if (N->getValueType(0) == MVT::i64) {
    // Shifting a i64 signed multiply.
    SDValue MulOp0 = N->getOperand(0);
    SDValue MulOp1 = N->getOperand(1);

    SDValue OP0;
    SDValue OP1;

    // Handle sign_extend and sextload.
    if (MulOp0.getOpcode() == ISD::SIGN_EXTEND) {
      SDValue Sext0 = MulOp0.getOperand(0);
      if (Sext0.getNode()->getValueType(0) != MVT::i32) {
        return SelectCode(N);
      }

      OP0 = Sext0;
    } else if (MulOp0.getOpcode() == ISD::LOAD) {
      LoadSDNode *LD = cast<LoadSDNode>(MulOp0.getNode());
      if (LD->getMemoryVT() != MVT::i32 ||
          LD->getExtensionType() != ISD::SEXTLOAD ||
          LD->getAddressingMode() != ISD::UNINDEXED) {
        return SelectCode(N);
      }

      SDValue Chain = LD->getChain();
      SDValue TargetConst0 = CurDAG->getTargetConstant(0, MVT::i32);
      OP0 = SDValue(CurDAG->getMachineNode(Hexagon::L2_loadri_io, dl, MVT::i32,
                                            MVT::Other,
                                            LD->getBasePtr(), TargetConst0,
                                            Chain), 0);
    } else {
      return SelectCode(N);
    }

    // Same goes for the second operand.
    if (MulOp1.getOpcode() == ISD::SIGN_EXTEND) {
      SDValue Sext1 = MulOp1.getOperand(0);
      if (Sext1.getNode()->getValueType(0) != MVT::i32) {
        return SelectCode(N);
      }

      OP1 = Sext1;
    } else if (MulOp1.getOpcode() == ISD::LOAD) {
      LoadSDNode *LD = cast<LoadSDNode>(MulOp1.getNode());
      if (LD->getMemoryVT() != MVT::i32 ||
          LD->getExtensionType() != ISD::SEXTLOAD ||
          LD->getAddressingMode() != ISD::UNINDEXED) {
        return SelectCode(N);
      }

      SDValue Chain = LD->getChain();
      SDValue TargetConst0 = CurDAG->getTargetConstant(0, MVT::i32);
      OP1 = SDValue(CurDAG->getMachineNode(Hexagon::L2_loadri_io, dl, MVT::i32,
                                            MVT::Other,
                                            LD->getBasePtr(), TargetConst0,
                                            Chain), 0);
    } else {
      return SelectCode(N);
    }

    // Generate a mpy instruction.
    SDNode *Result = CurDAG->getMachineNode(Hexagon::M2_dpmpyss_s0, dl, MVT::i64,
                                            OP0, OP1);
    ReplaceUses(N, Result);
    return Result;
  }

  return SelectCode(N);
}


SDNode *HexagonDAGToDAGISel::SelectSelect(SDNode *N) {
  SDLoc dl(N);
  SDValue N0 = N->getOperand(0);
  if (N0.getOpcode() == ISD::SETCC) {
    SDValue N00 = N0.getOperand(0);
    if (N00.getOpcode() == ISD::SIGN_EXTEND_INREG) {
      SDValue N000 = N00.getOperand(0);
      SDValue N001 = N00.getOperand(1);
      if (cast<VTSDNode>(N001)->getVT() == MVT::i16) {
        SDValue N01 = N0.getOperand(1);
        SDValue N02 = N0.getOperand(2);

        // Pattern: (select:i32 (setcc:i1 (sext_inreg:i32 IntRegs:i32:$src2,
        // i16:Other),IntRegs:i32:$src1, SETLT:Other),IntRegs:i32:$src1,
        // IntRegs:i32:$src2)
        // Emits: (MAXh_rr:i32 IntRegs:i32:$src1, IntRegs:i32:$src2)
        // Pattern complexity = 9  cost = 1  size = 0.
        if (cast<CondCodeSDNode>(N02)->get() == ISD::SETLT) {
          SDValue N1 = N->getOperand(1);
          if (N01 == N1) {
            SDValue N2 = N->getOperand(2);
            if (N000 == N2 &&
                N0.getNode()->getValueType(N0.getResNo()) == MVT::i1 &&
                N00.getNode()->getValueType(N00.getResNo()) == MVT::i32) {
              SDNode *SextNode = CurDAG->getMachineNode(Hexagon::A2_sxth, dl,
                                                        MVT::i32, N000);
              SDNode *Result = CurDAG->getMachineNode(Hexagon::A2_max, dl,
                                                      MVT::i32,
                                                      SDValue(SextNode, 0),
                                                      N1);
              ReplaceUses(N, Result);
              return Result;
            }
          }
        }

        // Pattern: (select:i32 (setcc:i1 (sext_inreg:i32 IntRegs:i32:$src2,
        // i16:Other), IntRegs:i32:$src1, SETGT:Other), IntRegs:i32:$src1,
        // IntRegs:i32:$src2)
        // Emits: (MINh_rr:i32 IntRegs:i32:$src1, IntRegs:i32:$src2)
        // Pattern complexity = 9  cost = 1  size = 0.
        if (cast<CondCodeSDNode>(N02)->get() == ISD::SETGT) {
          SDValue N1 = N->getOperand(1);
          if (N01 == N1) {
            SDValue N2 = N->getOperand(2);
            if (N000 == N2 &&
                N0.getNode()->getValueType(N0.getResNo()) == MVT::i1 &&
                N00.getNode()->getValueType(N00.getResNo()) == MVT::i32) {
              SDNode *SextNode = CurDAG->getMachineNode(Hexagon::A2_sxth, dl,
                                                        MVT::i32, N000);
              SDNode *Result = CurDAG->getMachineNode(Hexagon::A2_min, dl,
                                                      MVT::i32,
                                                      SDValue(SextNode, 0),
                                                      N1);
              ReplaceUses(N, Result);
              return Result;
            }
          }
        }
      }
    }
  }

  return SelectCode(N);
}


SDNode *HexagonDAGToDAGISel::SelectTruncate(SDNode *N) {
  SDLoc dl(N);
  SDValue Shift = N->getOperand(0);

  //
  // %conv.i = sext i32 %tmp1 to i64
  // %conv2.i = sext i32 %add to i64
  // %mul.i = mul nsw i64 %conv2.i, %conv.i
  // %shr5.i = lshr i64 %mul.i, 32
  // %conv3.i = trunc i64 %shr5.i to i32
  //
  //   --- match with the following ---
  //
  // %conv3.i = mpy (%tmp1, %add)
  //
  // Trunc to i32.
  if (N->getValueType(0) == MVT::i32) {
    // Trunc from i64.
    if (Shift.getNode()->getValueType(0) == MVT::i64) {
      // Trunc child is logical shift right.
      if (Shift.getOpcode() != ISD::SRL) {
        return SelectCode(N);
      }

      SDValue ShiftOp0 = Shift.getOperand(0);
      SDValue ShiftOp1 = Shift.getOperand(1);

      // Shift by const 32
      if (ShiftOp1.getOpcode() != ISD::Constant) {
        return SelectCode(N);
      }

      int32_t ShiftConst =
        cast<ConstantSDNode>(ShiftOp1.getNode())->getSExtValue();
      if (ShiftConst != 32) {
        return SelectCode(N);
      }

      // Shifting a i64 signed multiply
      SDValue Mul = ShiftOp0;
      if (Mul.getOpcode() != ISD::MUL) {
        return SelectCode(N);
      }

      SDValue MulOp0 = Mul.getOperand(0);
      SDValue MulOp1 = Mul.getOperand(1);

      SDValue OP0;
      SDValue OP1;

      // Handle sign_extend and sextload
      if (MulOp0.getOpcode() == ISD::SIGN_EXTEND) {
        SDValue Sext0 = MulOp0.getOperand(0);
        if (Sext0.getNode()->getValueType(0) != MVT::i32) {
          return SelectCode(N);
        }

        OP0 = Sext0;
      } else if (MulOp0.getOpcode() == ISD::LOAD) {
        LoadSDNode *LD = cast<LoadSDNode>(MulOp0.getNode());
        if (LD->getMemoryVT() != MVT::i32 ||
            LD->getExtensionType() != ISD::SEXTLOAD ||
            LD->getAddressingMode() != ISD::UNINDEXED) {
          return SelectCode(N);
        }

        SDValue Chain = LD->getChain();
        SDValue TargetConst0 = CurDAG->getTargetConstant(0, MVT::i32);
        OP0 = SDValue(CurDAG->getMachineNode(Hexagon::L2_loadri_io, dl, MVT::i32,
                                              MVT::Other,
                                              LD->getBasePtr(),
                                              TargetConst0, Chain), 0);
      } else {
        return SelectCode(N);
      }

      // Same goes for the second operand.
      if (MulOp1.getOpcode() == ISD::SIGN_EXTEND) {
        SDValue Sext1 = MulOp1.getOperand(0);
        if (Sext1.getNode()->getValueType(0) != MVT::i32)
          return SelectCode(N);

        OP1 = Sext1;
      } else if (MulOp1.getOpcode() == ISD::LOAD) {
        LoadSDNode *LD = cast<LoadSDNode>(MulOp1.getNode());
        if (LD->getMemoryVT() != MVT::i32 ||
            LD->getExtensionType() != ISD::SEXTLOAD ||
            LD->getAddressingMode() != ISD::UNINDEXED) {
          return SelectCode(N);
        }

        SDValue Chain = LD->getChain();
        SDValue TargetConst0 = CurDAG->getTargetConstant(0, MVT::i32);
        OP1 = SDValue(CurDAG->getMachineNode(Hexagon::L2_loadri_io, dl, MVT::i32,
                                              MVT::Other,
                                              LD->getBasePtr(),
                                              TargetConst0, Chain), 0);
      } else {
        return SelectCode(N);
      }

      // Generate a mpy instruction.
      SDNode *Result = CurDAG->getMachineNode(Hexagon::M2_mpy_up, dl, MVT::i32,
                                              OP0, OP1);
      ReplaceUses(N, Result);
      return Result;
    }
  }

  return SelectCode(N);
}


SDNode *HexagonDAGToDAGISel::SelectSHL(SDNode *N) {
  SDLoc dl(N);
  if (N->getValueType(0) == MVT::i32) {
    SDValue Shl_0 = N->getOperand(0);
    SDValue Shl_1 = N->getOperand(1);
    // RHS is const.
    if (Shl_1.getOpcode() == ISD::Constant) {
      if (Shl_0.getOpcode() == ISD::MUL) {
        SDValue Mul_0 = Shl_0.getOperand(0); // Val
        SDValue Mul_1 = Shl_0.getOperand(1); // Const
        // RHS of mul is const.
        if (Mul_1.getOpcode() == ISD::Constant) {
          int32_t ShlConst =
            cast<ConstantSDNode>(Shl_1.getNode())->getSExtValue();
          int32_t MulConst =
            cast<ConstantSDNode>(Mul_1.getNode())->getSExtValue();
          int32_t ValConst = MulConst << ShlConst;
          SDValue Val = CurDAG->getTargetConstant(ValConst,
                                                  MVT::i32);
          if (ConstantSDNode *CN = dyn_cast<ConstantSDNode>(Val.getNode()))
            if (isInt<9>(CN->getSExtValue())) {
              SDNode* Result =
                CurDAG->getMachineNode(Hexagon::M2_mpysmi, dl,
                                       MVT::i32, Mul_0, Val);
              ReplaceUses(N, Result);
              return Result;
            }

        }
      } else if (Shl_0.getOpcode() == ISD::SUB) {
        SDValue Sub_0 = Shl_0.getOperand(0); // Const 0
        SDValue Sub_1 = Shl_0.getOperand(1); // Val
        if (Sub_0.getOpcode() == ISD::Constant) {
          int32_t SubConst =
            cast<ConstantSDNode>(Sub_0.getNode())->getSExtValue();
          if (SubConst == 0) {
            if (Sub_1.getOpcode() == ISD::SHL) {
              SDValue Shl2_0 = Sub_1.getOperand(0); // Val
              SDValue Shl2_1 = Sub_1.getOperand(1); // Const
              if (Shl2_1.getOpcode() == ISD::Constant) {
                int32_t ShlConst =
                  cast<ConstantSDNode>(Shl_1.getNode())->getSExtValue();
                int32_t Shl2Const =
                  cast<ConstantSDNode>(Shl2_1.getNode())->getSExtValue();
                int32_t ValConst = 1 << (ShlConst+Shl2Const);
                SDValue Val = CurDAG->getTargetConstant(-ValConst, MVT::i32);
                if (ConstantSDNode *CN =
                    dyn_cast<ConstantSDNode>(Val.getNode()))
                  if (isInt<9>(CN->getSExtValue())) {
                    SDNode* Result =
                      CurDAG->getMachineNode(Hexagon::M2_mpysmi, dl, MVT::i32,
                                             Shl2_0, Val);
                    ReplaceUses(N, Result);
                    return Result;
                  }
              }
            }
          }
        }
      }
    }
  }
  return SelectCode(N);
}


//
// If there is an zero_extend followed an intrinsic in DAG (this means - the
// result of the intrinsic is predicate); convert the zero_extend to
// transfer instruction.
//
// Zero extend -> transfer is lowered here. Otherwise, zero_extend will be
// converted into a MUX as predicate registers defined as 1 bit in the
// compiler. Architecture defines them as 8-bit registers.
// We want to preserve all the lower 8-bits and, not just 1 LSB bit.
//
SDNode *HexagonDAGToDAGISel::SelectZeroExtend(SDNode *N) {
  SDLoc dl(N);
  SDNode *IsIntrinsic = N->getOperand(0).getNode();
  if ((IsIntrinsic->getOpcode() == ISD::INTRINSIC_WO_CHAIN)) {
    unsigned ID =
      cast<ConstantSDNode>(IsIntrinsic->getOperand(0))->getZExtValue();
    if (doesIntrinsicReturnPredicate(ID)) {
      // Now we need to differentiate target data types.
      if (N->getValueType(0) == MVT::i64) {
        // Convert the zero_extend to Rs = Pd followed by COMBINE_rr(0,Rs).
        SDValue TargetConst0 = CurDAG->getTargetConstant(0, MVT::i32);
        SDNode *Result_1 = CurDAG->getMachineNode(Hexagon::C2_tfrpr, dl,
                                                  MVT::i32,
                                                  SDValue(IsIntrinsic, 0));
        SDNode *Result_2 = CurDAG->getMachineNode(Hexagon::A2_tfrsi, dl,
                                                  MVT::i32,
                                                  TargetConst0);
        SDNode *Result_3 = CurDAG->getMachineNode(Hexagon::A2_combinew, dl,
                                                  MVT::i64, MVT::Other,
                                                  SDValue(Result_2, 0),
                                                  SDValue(Result_1, 0));
        ReplaceUses(N, Result_3);
        return Result_3;
      }
      if (N->getValueType(0) == MVT::i32) {
        // Convert the zero_extend to Rs = Pd
        SDNode* RsPd = CurDAG->getMachineNode(Hexagon::C2_tfrpr, dl,
                                              MVT::i32,
                                              SDValue(IsIntrinsic, 0));
        ReplaceUses(N, RsPd);
        return RsPd;
      }
      llvm_unreachable("Unexpected value type");
    }
  }
  return SelectCode(N);
}

//
// Checking for intrinsics which have predicate registers as operand(s)
// and lowering to the actual intrinsic.
//
SDNode *HexagonDAGToDAGISel::SelectIntrinsicWOChain(SDNode *N) {
  unsigned IID = cast<ConstantSDNode>(N->getOperand(0))->getZExtValue();
  unsigned Bits;
  switch (IID) {
  case Intrinsic::hexagon_S2_vsplatrb:
    Bits = 8;
    break;
  case Intrinsic::hexagon_S2_vsplatrh:
    Bits = 16;
    break;
  default:
    return SelectCode(N);
  }

  SDValue const &V = N->getOperand(1);
  SDValue U;
  if (isValueExtension(V, Bits, U)) {
    SDValue R = CurDAG->getNode(N->getOpcode(), SDLoc(N), N->getValueType(0),
      N->getOperand(0), U);
    return SelectCode(R.getNode());
  }
  return SelectCode(N);
}

//
// Map floating point constant values.
//
SDNode *HexagonDAGToDAGISel::SelectConstantFP(SDNode *N) {
  SDLoc dl(N);
  ConstantFPSDNode *CN = dyn_cast<ConstantFPSDNode>(N);
  APFloat APF = CN->getValueAPF();
  if (N->getValueType(0) == MVT::f32) {
    return CurDAG->getMachineNode(Hexagon::TFRI_f, dl, MVT::f32,
              CurDAG->getTargetConstantFP(APF.convertToFloat(), MVT::f32));
  }
  else if (N->getValueType(0) == MVT::f64) {
    return CurDAG->getMachineNode(Hexagon::CONST64_Float_Real, dl, MVT::f64,
              CurDAG->getTargetConstantFP(APF.convertToDouble(), MVT::f64));
  }

  return SelectCode(N);
}

//
// Map predicate true (encoded as -1 in LLVM) to a XOR.
//
SDNode *HexagonDAGToDAGISel::SelectConstant(SDNode *N) {
  SDLoc dl(N);
  if (N->getValueType(0) == MVT::i1) {
    SDNode* Result;
    int32_t Val = cast<ConstantSDNode>(N)->getSExtValue();
    if (Val == -1) {
      // Create the IntReg = 1 node.
      SDNode* IntRegTFR =
        CurDAG->getMachineNode(Hexagon::A2_tfrsi, dl, MVT::i32,
                               CurDAG->getTargetConstant(0, MVT::i32));

      // Pd = IntReg
      SDNode* Pd = CurDAG->getMachineNode(Hexagon::C2_tfrrp, dl, MVT::i1,
                                          SDValue(IntRegTFR, 0));

      // not(Pd)
      SDNode* NotPd = CurDAG->getMachineNode(Hexagon::C2_not, dl, MVT::i1,
                                             SDValue(Pd, 0));

      // xor(not(Pd))
      Result = CurDAG->getMachineNode(Hexagon::C2_xor, dl, MVT::i1,
                                      SDValue(Pd, 0), SDValue(NotPd, 0));

      // We have just built:
      // Rs = Pd
      // Pd = xor(not(Pd), Pd)

      ReplaceUses(N, Result);
      return Result;
    }
  }

  return SelectCode(N);
}


//
// Map add followed by a asr -> asr +=.
//
SDNode *HexagonDAGToDAGISel::SelectAdd(SDNode *N) {
  SDLoc dl(N);
  if (N->getValueType(0) != MVT::i32) {
    return SelectCode(N);
  }
  // Identify nodes of the form: add(asr(...)).
  SDNode* Src1 = N->getOperand(0).getNode();
  if (Src1->getOpcode() != ISD::SRA || !Src1->hasOneUse()
      || Src1->getValueType(0) != MVT::i32) {
    return SelectCode(N);
  }

  // Build Rd = Rd' + asr(Rs, Rt). The machine constraints will ensure that
  // Rd and Rd' are assigned to the same register
  SDNode* Result = CurDAG->getMachineNode(Hexagon::S2_asr_r_r_acc, dl, MVT::i32,
                                          N->getOperand(1),
                                          Src1->getOperand(0),
                                          Src1->getOperand(1));
  ReplaceUses(N, Result);

  return Result;
}

SDNode *HexagonDAGToDAGISel::SelectFrameIndex(SDNode *N) {
  int FX = cast<FrameIndexSDNode>(N)->getIndex();
  SDValue FI = CurDAG->getTargetFrameIndex(FX, MVT::i32);
  SDValue Zero = CurDAG->getTargetConstant(0, MVT::i32);
  SDLoc DL(N);

  SDNode *R = CurDAG->getMachineNode(Hexagon::TFR_FI, DL, MVT::i32, FI, Zero);

  if (N->getHasDebugValue())
    CurDAG->TransferDbgValues(SDValue(N, 0), SDValue(R, 0));
  return R;
}


SDNode *HexagonDAGToDAGISel::Select(SDNode *N) {
  if (N->isMachineOpcode()) {
    N->setNodeId(-1);
    return nullptr;   // Already selected.
  }

  switch (N->getOpcode()) {
  case ISD::Constant:
    return SelectConstant(N);

  case ISD::ConstantFP:
    return SelectConstantFP(N);

  case ISD::FrameIndex:
    return SelectFrameIndex(N);

  case ISD::ADD:
    return SelectAdd(N);

  case ISD::SHL:
    return SelectSHL(N);

  case ISD::LOAD:
    return SelectLoad(N);

  case ISD::STORE:
    return SelectStore(N);

  case ISD::SELECT:
    return SelectSelect(N);

  case ISD::TRUNCATE:
    return SelectTruncate(N);

  case ISD::MUL:
    return SelectMul(N);

  case ISD::ZERO_EXTEND:
    return SelectZeroExtend(N);

  case ISD::INTRINSIC_WO_CHAIN:
    return SelectIntrinsicWOChain(N);
  }

  return SelectCode(N);
}


bool HexagonDAGToDAGISel::
SelectInlineAsmMemoryOperand(const SDValue &Op, unsigned ConstraintID,
                             std::vector<SDValue> &OutOps) {
  SDValue Inp = Op, Res;

  switch (ConstraintID) {
  case InlineAsm::Constraint_o:   // Offsetable.
  case InlineAsm::Constraint_v:   // Not offsetable.
  default:
    return true;
  case InlineAsm::Constraint_m:   // Memory.
    if (SelectAddrFI(Inp, Res))
      OutOps.push_back(Res);
    else
      OutOps.push_back(Inp);
    break;
  }

  OutOps.push_back(CurDAG->getTargetConstant(0, MVT::i32));
  return false;
}

bool HexagonDAGToDAGISel::SelectAddrFI(SDValue& N, SDValue &R) {
  if (N.getOpcode() != ISD::FrameIndex)
    return false;
  FrameIndexSDNode *FX = cast<FrameIndexSDNode>(N);
  R = CurDAG->getTargetFrameIndex(FX->getIndex(), MVT::i32);
  return true;
}

inline bool HexagonDAGToDAGISel::SelectAddrGA(SDValue &N, SDValue &R) {
  return SelectGlobalAddress(N, R, false);
}

inline bool HexagonDAGToDAGISel::SelectAddrGP(SDValue &N, SDValue &R) {
  return SelectGlobalAddress(N, R, true);
}

bool HexagonDAGToDAGISel::SelectGlobalAddress(SDValue &N, SDValue &R,
                                              bool UseGP) {
  switch (N.getOpcode()) {
  case ISD::ADD: {
    SDValue N0 = N.getOperand(0);
    SDValue N1 = N.getOperand(1);
    unsigned GAOpc = N0.getOpcode();
    if (UseGP && GAOpc != HexagonISD::CONST32_GP)
      return false;
    if (!UseGP && GAOpc != HexagonISD::CONST32)
      return false;
    if (ConstantSDNode *Const = dyn_cast<ConstantSDNode>(N1)) {
      SDValue Addr = N0.getOperand(0);
      if (GlobalAddressSDNode *GA = dyn_cast<GlobalAddressSDNode>(Addr)) {
        if (GA->getOpcode() == ISD::TargetGlobalAddress) {
          uint64_t NewOff = GA->getOffset() + (uint64_t)Const->getSExtValue();
          R = CurDAG->getTargetGlobalAddress(GA->getGlobal(), SDLoc(Const),
                                             N.getValueType(), NewOff);
          return true;
        }
      }
    }
    break;
  }
  case HexagonISD::CONST32:
    // The operand(0) of CONST32 is TargetGlobalAddress, which is what we
    // want in the instruction.
    if (!UseGP)
      R = N.getOperand(0);
    return !UseGP;
  case HexagonISD::CONST32_GP:
    if (UseGP)
      R = N.getOperand(0);
    return UseGP;
  default:
    return false;
  }

  return false;
}

bool HexagonDAGToDAGISel::isValueExtension(const SDValue &Val,
      unsigned FromBits, SDValue &Src) {
  unsigned Opc = Val.getOpcode();
  switch (Opc) {
  case ISD::SIGN_EXTEND:
  case ISD::ZERO_EXTEND:
  case ISD::ANY_EXTEND: {
    SDValue const &Op0 = Val.getOperand(0);
    EVT T = Op0.getValueType();
    if (T.isInteger() && T.getSizeInBits() == FromBits) {
      Src = Op0;
      return true;
    }
    break;
  }
  case ISD::SIGN_EXTEND_INREG:
  case ISD::AssertSext:
  case ISD::AssertZext:
    if (Val.getOperand(0).getValueType().isInteger()) {
      VTSDNode *T = cast<VTSDNode>(Val.getOperand(1));
      if (T->getVT().getSizeInBits() == FromBits) {
        Src = Val.getOperand(0);
        return true;
      }
    }
    break;
  case ISD::AND: {
    // Check if this is an AND with "FromBits" of lower bits set to 1.
    uint64_t FromMask = (1 << FromBits) - 1;
    if (ConstantSDNode *C = dyn_cast<ConstantSDNode>(Val.getOperand(0))) {
      if (C->getZExtValue() == FromMask) {
        Src = Val.getOperand(1);
        return true;
      }
    }
    if (ConstantSDNode *C = dyn_cast<ConstantSDNode>(Val.getOperand(1))) {
      if (C->getZExtValue() == FromMask) {
        Src = Val.getOperand(0);
        return true;
      }
    }
    break;
  }
  case ISD::OR:
  case ISD::XOR: {
    // OR/XOR with the lower "FromBits" bits set to 0.
    uint64_t FromMask = (1 << FromBits) - 1;
    if (ConstantSDNode *C = dyn_cast<ConstantSDNode>(Val.getOperand(0))) {
      if ((C->getZExtValue() & FromMask) == 0) {
        Src = Val.getOperand(1);
        return true;
      }
    }
    if (ConstantSDNode *C = dyn_cast<ConstantSDNode>(Val.getOperand(1))) {
      if ((C->getZExtValue() & FromMask) == 0) {
        Src = Val.getOperand(0);
        return true;
      }
    }
  }
  default:
    break;
  }
  return false;
}
