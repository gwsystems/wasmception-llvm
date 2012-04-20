//===-- MipsISelDAGToDAG.cpp - A Dag to Dag Inst Selector for Mips --------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines an instruction selector for the MIPS target.
//
//===----------------------------------------------------------------------===//

#define DEBUG_TYPE "mips-isel"
#include "Mips.h"
#include "MipsAnalyzeImmediate.h"
#include "MipsMachineFunction.h"
#include "MipsRegisterInfo.h"
#include "MipsSubtarget.h"
#include "MipsTargetMachine.h"
#include "MCTargetDesc/MipsBaseInfo.h"
#include "llvm/GlobalValue.h"
#include "llvm/Instructions.h"
#include "llvm/Intrinsics.h"
#include "llvm/Support/CFG.h"
#include "llvm/Type.h"
#include "llvm/CodeGen/MachineConstantPool.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/SelectionDAGISel.h"
#include "llvm/CodeGen/SelectionDAGNodes.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"
using namespace llvm;

//===----------------------------------------------------------------------===//
// Instruction Selector Implementation
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// MipsDAGToDAGISel - MIPS specific code to select MIPS machine
// instructions for SelectionDAG operations.
//===----------------------------------------------------------------------===//
namespace {

class MipsDAGToDAGISel : public SelectionDAGISel {

  /// TM - Keep a reference to MipsTargetMachine.
  MipsTargetMachine &TM;

  /// Subtarget - Keep a pointer to the MipsSubtarget around so that we can
  /// make the right decision when generating code for different targets.
  const MipsSubtarget &Subtarget;

public:
  explicit MipsDAGToDAGISel(MipsTargetMachine &tm) :
  SelectionDAGISel(tm),
  TM(tm), Subtarget(tm.getSubtarget<MipsSubtarget>()) {}

  // Pass Name
  virtual const char *getPassName() const {
    return "MIPS DAG->DAG Pattern Instruction Selection";
  }

  virtual bool runOnMachineFunction(MachineFunction &MF);

private:
  // Include the pieces autogenerated from the target description.
  #include "MipsGenDAGISel.inc"

  /// getTargetMachine - Return a reference to the TargetMachine, casted
  /// to the target-specific type.
  const MipsTargetMachine &getTargetMachine() {
    return static_cast<const MipsTargetMachine &>(TM);
  }

  /// getInstrInfo - Return a reference to the TargetInstrInfo, casted
  /// to the target-specific type.
  const MipsInstrInfo *getInstrInfo() {
    return getTargetMachine().getInstrInfo();
  }

  SDNode *getGlobalBaseReg();

  std::pair<SDNode*, SDNode*> SelectMULT(SDNode *N, unsigned Opc, DebugLoc dl,
                                         EVT Ty, bool HasLo, bool HasHi);

  SDNode *Select(SDNode *N);

  // Complex Pattern.
  bool SelectAddr(SDNode *Parent, SDValue N, SDValue &Base, SDValue &Offset);

  // getImm - Return a target constant with the specified value.
  inline SDValue getImm(const SDNode *Node, unsigned Imm) {
    return CurDAG->getTargetConstant(Imm, Node->getValueType(0));
  }

  void ProcessFunctionAfterISel(MachineFunction &MF);
  bool ReplaceUsesWithZeroReg(MachineRegisterInfo *MRI, const MachineInstr&);
  void InitGlobalBaseReg(MachineFunction &MF);

  virtual bool SelectInlineAsmMemoryOperand(const SDValue &Op,
                                            char ConstraintCode,
                                            std::vector<SDValue> &OutOps);
};

}

// Insert instructions to initialize the global base register in the
// first MBB of the function. When the ABI is O32 and the relocation model is
// PIC, the necessary instructions are emitted later to prevent optimization
// passes from moving them.
void MipsDAGToDAGISel::InitGlobalBaseReg(MachineFunction &MF) {
  MipsFunctionInfo *MipsFI = MF.getInfo<MipsFunctionInfo>();

  if (!MipsFI->globalBaseRegSet())
    return;

  MachineBasicBlock &MBB = MF.front();
  MachineBasicBlock::iterator I = MBB.begin();
  MachineRegisterInfo &RegInfo = MF.getRegInfo();
  const TargetInstrInfo &TII = *MF.getTarget().getInstrInfo();
  DebugLoc DL = I != MBB.end() ? I->getDebugLoc() : DebugLoc();
  unsigned V0, V1, GlobalBaseReg = MipsFI->getGlobalBaseReg();
  bool FixGlobalBaseReg = MipsFI->globalBaseRegFixed();

  if (Subtarget.isABI_O32() && FixGlobalBaseReg)
    // $gp is the global base register.
    V0 = V1 = GlobalBaseReg;
  else {
    const TargetRegisterClass *RC;
    RC = Subtarget.isABI_N64() ?
      (const TargetRegisterClass*)&Mips::CPU64RegsRegClass :
      (const TargetRegisterClass*)&Mips::CPURegsRegClass;

    V0 = RegInfo.createVirtualRegister(RC);
    V1 = RegInfo.createVirtualRegister(RC);
  }

  if (Subtarget.isABI_N64()) {
    MF.getRegInfo().addLiveIn(Mips::T9_64);
    MBB.addLiveIn(Mips::T9_64);

    // lui $v0, %hi(%neg(%gp_rel(fname)))
    // daddu $v1, $v0, $t9
    // daddiu $globalbasereg, $v1, %lo(%neg(%gp_rel(fname)))
    const GlobalValue *FName = MF.getFunction();
    BuildMI(MBB, I, DL, TII.get(Mips::LUi64), V0)
      .addGlobalAddress(FName, 0, MipsII::MO_GPOFF_HI);
    BuildMI(MBB, I, DL, TII.get(Mips::DADDu), V1).addReg(V0).addReg(Mips::T9_64);
    BuildMI(MBB, I, DL, TII.get(Mips::DADDiu), GlobalBaseReg).addReg(V1)
      .addGlobalAddress(FName, 0, MipsII::MO_GPOFF_LO);
  } else if (MF.getTarget().getRelocationModel() == Reloc::Static) {
    // Set global register to __gnu_local_gp.
    //
    // lui   $v0, %hi(__gnu_local_gp)
    // addiu $globalbasereg, $v0, %lo(__gnu_local_gp)
    BuildMI(MBB, I, DL, TII.get(Mips::LUi), V0)
      .addExternalSymbol("__gnu_local_gp", MipsII::MO_ABS_HI);
    BuildMI(MBB, I, DL, TII.get(Mips::ADDiu), GlobalBaseReg).addReg(V0)
      .addExternalSymbol("__gnu_local_gp", MipsII::MO_ABS_LO);
  } else {
    MF.getRegInfo().addLiveIn(Mips::T9);
    MBB.addLiveIn(Mips::T9);

    if (Subtarget.isABI_N32()) {
      // lui $v0, %hi(%neg(%gp_rel(fname)))
      // addu $v1, $v0, $t9
      // addiu $globalbasereg, $v1, %lo(%neg(%gp_rel(fname)))
      const GlobalValue *FName = MF.getFunction();
      BuildMI(MBB, I, DL, TII.get(Mips::LUi), V0)
        .addGlobalAddress(FName, 0, MipsII::MO_GPOFF_HI);
      BuildMI(MBB, I, DL, TII.get(Mips::ADDu), V1).addReg(V0).addReg(Mips::T9);
      BuildMI(MBB, I, DL, TII.get(Mips::ADDiu), GlobalBaseReg).addReg(V1)
        .addGlobalAddress(FName, 0, MipsII::MO_GPOFF_LO);
    } else if (!MipsFI->globalBaseRegFixed()) {
      assert(Subtarget.isABI_O32());

      BuildMI(MBB, I, DL, TII.get(Mips::SETGP2), GlobalBaseReg)
        .addReg(Mips::T9);
    }
  }
}

bool MipsDAGToDAGISel::ReplaceUsesWithZeroReg(MachineRegisterInfo *MRI,
                                              const MachineInstr& MI) {
  unsigned DstReg = 0, ZeroReg = 0;

  // Check if MI is "addiu $dst, $zero, 0" or "daddiu $dst, $zero, 0".
  if ((MI.getOpcode() == Mips::ADDiu) &&
      (MI.getOperand(1).getReg() == Mips::ZERO) &&
      (MI.getOperand(2).getImm() == 0)) {
    DstReg = MI.getOperand(0).getReg();
    ZeroReg = Mips::ZERO;
  } else if ((MI.getOpcode() == Mips::DADDiu) &&
             (MI.getOperand(1).getReg() == Mips::ZERO_64) &&
             (MI.getOperand(2).getImm() == 0)) {
    DstReg = MI.getOperand(0).getReg();
    ZeroReg = Mips::ZERO_64;
  }

  if (!DstReg)
    return false;

  // Replace uses with ZeroReg.
  for (MachineRegisterInfo::use_iterator U = MRI->use_begin(DstReg),
       E = MRI->use_end(); U != E; ++U) {
    MachineOperand &MO = U.getOperand();
    MachineInstr *MI = MO.getParent();

    // Do not replace if it is a phi's operand or is tied to def operand.
    if (MI->isPHI() || MI->isRegTiedToDefOperand(U.getOperandNo()))
      continue;

    MO.setReg(ZeroReg);
  }

  return true;
}

void MipsDAGToDAGISel::ProcessFunctionAfterISel(MachineFunction &MF) {
  InitGlobalBaseReg(MF);

  MachineRegisterInfo *MRI = &MF.getRegInfo();

  for (MachineFunction::iterator MFI = MF.begin(), MFE = MF.end(); MFI != MFE;
       ++MFI)
    for (MachineBasicBlock::iterator I = MFI->begin(); I != MFI->end(); ++I)
      ReplaceUsesWithZeroReg(MRI, *I);
}

bool MipsDAGToDAGISel::runOnMachineFunction(MachineFunction &MF) {
  bool Ret = SelectionDAGISel::runOnMachineFunction(MF);

  ProcessFunctionAfterISel(MF);

  return Ret;
}

/// getGlobalBaseReg - Output the instructions required to put the
/// GOT address into a register.
SDNode *MipsDAGToDAGISel::getGlobalBaseReg() {
  unsigned GlobalBaseReg = MF->getInfo<MipsFunctionInfo>()->getGlobalBaseReg();
  return CurDAG->getRegister(GlobalBaseReg, TLI.getPointerTy()).getNode();
}

/// ComplexPattern used on MipsInstrInfo
/// Used on Mips Load/Store instructions
bool MipsDAGToDAGISel::
SelectAddr(SDNode *Parent, SDValue Addr, SDValue &Base, SDValue &Offset) {
  EVT ValTy = Addr.getValueType();

  // If Parent is an unaligned f32 load or store, select a (base + index)
  // floating point load/store instruction (luxc1 or suxc1).
  const LSBaseSDNode* LS = 0;

  if (Parent && (LS = dyn_cast<LSBaseSDNode>(Parent))) {
    EVT VT = LS->getMemoryVT();

    if (VT.getSizeInBits() / 8 > LS->getAlignment()) {
      assert(TLI.allowsUnalignedMemoryAccesses(VT) &&
             "Unaligned loads/stores not supported for this type.");
      if (VT == MVT::f32)
        return false;
    }
  }

  // if Address is FI, get the TargetFrameIndex.
  if (FrameIndexSDNode *FIN = dyn_cast<FrameIndexSDNode>(Addr)) {
    Base   = CurDAG->getTargetFrameIndex(FIN->getIndex(), ValTy);
    Offset = CurDAG->getTargetConstant(0, ValTy);
    return true;
  }

  // on PIC code Load GA
  if (Addr.getOpcode() == MipsISD::Wrapper) {
    Base   = Addr.getOperand(0);
    Offset = Addr.getOperand(1);
    return true;
  }

  if (TM.getRelocationModel() != Reloc::PIC_) {
    if ((Addr.getOpcode() == ISD::TargetExternalSymbol ||
        Addr.getOpcode() == ISD::TargetGlobalAddress))
      return false;
  }

  // Addresses of the form FI+const or FI|const
  if (CurDAG->isBaseWithConstantOffset(Addr)) {
    ConstantSDNode *CN = dyn_cast<ConstantSDNode>(Addr.getOperand(1));
    if (isInt<16>(CN->getSExtValue())) {

      // If the first operand is a FI, get the TargetFI Node
      if (FrameIndexSDNode *FIN = dyn_cast<FrameIndexSDNode>
                                  (Addr.getOperand(0)))
        Base = CurDAG->getTargetFrameIndex(FIN->getIndex(), ValTy);
      else
        Base = Addr.getOperand(0);

      Offset = CurDAG->getTargetConstant(CN->getZExtValue(), ValTy);
      return true;
    }
  }

  // Operand is a result from an ADD.
  if (Addr.getOpcode() == ISD::ADD) {
    // When loading from constant pools, load the lower address part in
    // the instruction itself. Example, instead of:
    //  lui $2, %hi($CPI1_0)
    //  addiu $2, $2, %lo($CPI1_0)
    //  lwc1 $f0, 0($2)
    // Generate:
    //  lui $2, %hi($CPI1_0)
    //  lwc1 $f0, %lo($CPI1_0)($2)
    if (Addr.getOperand(1).getOpcode() == MipsISD::Lo) {
      SDValue LoVal = Addr.getOperand(1);
      if (isa<ConstantPoolSDNode>(LoVal.getOperand(0)) ||
          isa<GlobalAddressSDNode>(LoVal.getOperand(0))) {
        Base = Addr.getOperand(0);
        Offset = LoVal.getOperand(0);
        return true;
      }
    }

    // If an indexed floating point load/store can be emitted, return false.
    if (LS && (LS->getMemoryVT() == MVT::f32 || LS->getMemoryVT() == MVT::f64) &&
        Subtarget.hasMips32r2Or64())
      return false;
  }

  Base   = Addr;
  Offset = CurDAG->getTargetConstant(0, ValTy);
  return true;
}

/// Select multiply instructions.
std::pair<SDNode*, SDNode*>
MipsDAGToDAGISel::SelectMULT(SDNode *N, unsigned Opc, DebugLoc dl, EVT Ty,
                             bool HasLo, bool HasHi) {
  SDNode *Lo = 0, *Hi = 0;
  SDNode *Mul = CurDAG->getMachineNode(Opc, dl, MVT::Glue, N->getOperand(0),
                                       N->getOperand(1));
  SDValue InFlag = SDValue(Mul, 0);

  if (HasLo) {
    Lo = CurDAG->getMachineNode(Ty == MVT::i32 ? Mips::MFLO : Mips::MFLO64, dl,
                                Ty, MVT::Glue, InFlag);
    InFlag = SDValue(Lo, 1);
  }
  if (HasHi)
    Hi = CurDAG->getMachineNode(Ty == MVT::i32 ? Mips::MFHI : Mips::MFHI64, dl,
                                Ty, InFlag);

  return std::make_pair(Lo, Hi);
}


/// Select instructions not customized! Used for
/// expanded, promoted and normal instructions
SDNode* MipsDAGToDAGISel::Select(SDNode *Node) {
  unsigned Opcode = Node->getOpcode();
  DebugLoc dl = Node->getDebugLoc();

  // Dump information about the Node being selected
  DEBUG(errs() << "Selecting: "; Node->dump(CurDAG); errs() << "\n");

  // If we have a custom node, we already have selected!
  if (Node->isMachineOpcode()) {
    DEBUG(errs() << "== "; Node->dump(CurDAG); errs() << "\n");
    return NULL;
  }

  ///
  // Instruction Selection not handled by the auto-generated
  // tablegen selection should be handled here.
  ///
  EVT NodeTy = Node->getValueType(0);
  unsigned MultOpc;

  switch(Opcode) {
  default: break;

  case ISD::SUBE:
  case ISD::ADDE: {
    SDValue InFlag = Node->getOperand(2), CmpLHS;
    unsigned Opc = InFlag.getOpcode(); (void)Opc;
    assert(((Opc == ISD::ADDC || Opc == ISD::ADDE) ||
            (Opc == ISD::SUBC || Opc == ISD::SUBE)) &&
           "(ADD|SUB)E flag operand must come from (ADD|SUB)C/E insn");

    unsigned MOp;
    if (Opcode == ISD::ADDE) {
      CmpLHS = InFlag.getValue(0);
      MOp = Mips::ADDu;
    } else {
      CmpLHS = InFlag.getOperand(0);
      MOp = Mips::SUBu;
    }

    SDValue Ops[] = { CmpLHS, InFlag.getOperand(1) };

    SDValue LHS = Node->getOperand(0);
    SDValue RHS = Node->getOperand(1);

    EVT VT = LHS.getValueType();
    SDNode *Carry = CurDAG->getMachineNode(Mips::SLTu, dl, VT, Ops, 2);
    SDNode *AddCarry = CurDAG->getMachineNode(Mips::ADDu, dl, VT,
                                              SDValue(Carry,0), RHS);

    return CurDAG->SelectNodeTo(Node, MOp, VT, MVT::Glue,
                                LHS, SDValue(AddCarry,0));
  }

  /// Mul with two results
  case ISD::SMUL_LOHI:
  case ISD::UMUL_LOHI: {
    if (NodeTy == MVT::i32)
      MultOpc = (Opcode == ISD::UMUL_LOHI ? Mips::MULTu : Mips::MULT);
    else
      MultOpc = (Opcode == ISD::UMUL_LOHI ? Mips::DMULTu : Mips::DMULT);

    std::pair<SDNode*, SDNode*> LoHi = SelectMULT(Node, MultOpc, dl, NodeTy,
                                                  true, true);

    if (!SDValue(Node, 0).use_empty())
      ReplaceUses(SDValue(Node, 0), SDValue(LoHi.first, 0));

    if (!SDValue(Node, 1).use_empty())
      ReplaceUses(SDValue(Node, 1), SDValue(LoHi.second, 0));

    return NULL;
  }

  /// Special Muls
  case ISD::MUL: {
    // Mips32 has a 32-bit three operand mul instruction.
    if (Subtarget.hasMips32() && NodeTy == MVT::i32)
      break;
    return SelectMULT(Node, NodeTy == MVT::i32 ? Mips::MULT : Mips::DMULT,
                      dl, NodeTy, true, false).first;
  }
  case ISD::MULHS:
  case ISD::MULHU: {
    if (NodeTy == MVT::i32)
      MultOpc = (Opcode == ISD::MULHU ? Mips::MULTu : Mips::MULT);
    else
      MultOpc = (Opcode == ISD::MULHU ? Mips::DMULTu : Mips::DMULT);

    return SelectMULT(Node, MultOpc, dl, NodeTy, false, true).second;
  }

  // Get target GOT address.
  case ISD::GLOBAL_OFFSET_TABLE:
    return getGlobalBaseReg();

  case ISD::ConstantFP: {
    ConstantFPSDNode *CN = dyn_cast<ConstantFPSDNode>(Node);
    if (Node->getValueType(0) == MVT::f64 && CN->isExactlyValue(+0.0)) {
      if (Subtarget.hasMips64()) {
        SDValue Zero = CurDAG->getCopyFromReg(CurDAG->getEntryNode(), dl,
                                              Mips::ZERO_64, MVT::i64);
        return CurDAG->getMachineNode(Mips::DMTC1, dl, MVT::f64, Zero);
      }

      SDValue Zero = CurDAG->getCopyFromReg(CurDAG->getEntryNode(), dl,
                                            Mips::ZERO, MVT::i32);
      return CurDAG->getMachineNode(Mips::BuildPairF64, dl, MVT::f64, Zero,
                                    Zero);
    }
    break;
  }

  case ISD::Constant: {
    const ConstantSDNode *CN = dyn_cast<ConstantSDNode>(Node);
    unsigned Size = CN->getValueSizeInBits(0);

    if (Size == 32)
      break;

    MipsAnalyzeImmediate AnalyzeImm;
    int64_t Imm = CN->getSExtValue();

    const MipsAnalyzeImmediate::InstSeq &Seq =
      AnalyzeImm.Analyze(Imm, Size, false);

    MipsAnalyzeImmediate::InstSeq::const_iterator Inst = Seq.begin();
    DebugLoc DL = CN->getDebugLoc();
    SDNode *RegOpnd;
    SDValue ImmOpnd = CurDAG->getTargetConstant(SignExtend64<16>(Inst->ImmOpnd),
                                                MVT::i64);

    // The first instruction can be a LUi which is different from other
    // instructions (ADDiu, ORI and SLL) in that it does not have a register
    // operand.
    if (Inst->Opc == Mips::LUi64)
      RegOpnd = CurDAG->getMachineNode(Inst->Opc, DL, MVT::i64, ImmOpnd);
    else
      RegOpnd =
        CurDAG->getMachineNode(Inst->Opc, DL, MVT::i64,
                               CurDAG->getRegister(Mips::ZERO_64, MVT::i64),
                               ImmOpnd);

    // The remaining instructions in the sequence are handled here.
    for (++Inst; Inst != Seq.end(); ++Inst) {
      ImmOpnd = CurDAG->getTargetConstant(SignExtend64<16>(Inst->ImmOpnd),
                                          MVT::i64);
      RegOpnd = CurDAG->getMachineNode(Inst->Opc, DL, MVT::i64,
                                       SDValue(RegOpnd, 0), ImmOpnd);
    }

    return RegOpnd;
  }

  case MipsISD::ThreadPointer: {
    EVT PtrVT = TLI.getPointerTy();
    unsigned RdhwrOpc, SrcReg, DestReg;

    if (PtrVT == MVT::i32) {
      RdhwrOpc = Mips::RDHWR;
      SrcReg = Mips::HWR29;
      DestReg = Mips::V1;
    } else {
      RdhwrOpc = Mips::RDHWR64;
      SrcReg = Mips::HWR29_64;
      DestReg = Mips::V1_64;
    }

    SDNode *Rdhwr =
      CurDAG->getMachineNode(RdhwrOpc, Node->getDebugLoc(),
                             Node->getValueType(0),
                             CurDAG->getRegister(SrcReg, PtrVT));
    SDValue Chain = CurDAG->getCopyToReg(CurDAG->getEntryNode(), dl, DestReg,
                                         SDValue(Rdhwr, 0));
    SDValue ResNode = CurDAG->getCopyFromReg(Chain, dl, DestReg, PtrVT);
    ReplaceUses(SDValue(Node, 0), ResNode);
    return ResNode.getNode();
  }
  }

  // Select the default instruction
  SDNode *ResNode = SelectCode(Node);

  DEBUG(errs() << "=> ");
  if (ResNode == NULL || ResNode == Node)
    DEBUG(Node->dump(CurDAG));
  else
    DEBUG(ResNode->dump(CurDAG));
  DEBUG(errs() << "\n");
  return ResNode;
}

bool MipsDAGToDAGISel::
SelectInlineAsmMemoryOperand(const SDValue &Op, char ConstraintCode,
                             std::vector<SDValue> &OutOps) {
  assert(ConstraintCode == 'm' && "unexpected asm memory constraint");
  OutOps.push_back(Op);
  return false;
}

/// createMipsISelDag - This pass converts a legalized DAG into a
/// MIPS-specific DAG, ready for instruction scheduling.
FunctionPass *llvm::createMipsISelDag(MipsTargetMachine &TM) {
  return new MipsDAGToDAGISel(TM);
}
