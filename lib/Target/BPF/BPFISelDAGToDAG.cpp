//===-- BPFISelDAGToDAG.cpp - A dag to dag inst selector for BPF ----------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file defines a DAG pattern matching instruction selector for BPF,
// converting from a legalized dag to a BPF dag.
//
//===----------------------------------------------------------------------===//

#include "BPF.h"
#include "BPFRegisterInfo.h"
#include "BPFSubtarget.h"
#include "BPFTargetMachine.h"
#include "llvm/CodeGen/FunctionLoweringInfo.h"
#include "llvm/CodeGen/MachineConstantPool.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/SelectionDAGISel.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/Endian.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Target/TargetMachine.h"

using namespace llvm;

#define DEBUG_TYPE "bpf-isel"

// Instruction Selector Implementation
namespace {

class BPFDAGToDAGISel : public SelectionDAGISel {

  /// Subtarget - Keep a pointer to the BPFSubtarget around so that we can
  /// make the right decision when generating code for different subtargets.
  const BPFSubtarget *Subtarget;

public:
  explicit BPFDAGToDAGISel(BPFTargetMachine &TM)
      : SelectionDAGISel(TM), Subtarget(nullptr) {
    curr_func_ = nullptr;
  }

  StringRef getPassName() const override {
    return "BPF DAG->DAG Pattern Instruction Selection";
  }

  bool runOnMachineFunction(MachineFunction &MF) override {
    // Reset the subtarget each time through.
    Subtarget = &MF.getSubtarget<BPFSubtarget>();
    return SelectionDAGISel::runOnMachineFunction(MF);
  }

  void PreprocessISelDAG() override;

  bool SelectInlineAsmMemoryOperand(const SDValue &Op, unsigned ConstraintCode,
                                    std::vector<SDValue> &OutOps) override;


private:
// Include the pieces autogenerated from the target description.
#include "BPFGenDAGISel.inc"

  void Select(SDNode *N) override;

  // Complex Pattern for address selection.
  bool SelectAddr(SDValue Addr, SDValue &Base, SDValue &Offset);
  bool SelectFIAddr(SDValue Addr, SDValue &Base, SDValue &Offset);

  // Node preprocessing cases
  void PreprocessLoad(SDNode *Node, SelectionDAG::allnodes_iterator &I);
  void PreprocessCopyToReg(SDNode *Node);
  void PreprocessTrunc(SDNode *Node, SelectionDAG::allnodes_iterator &I);

  // Find constants from a constant structure
  typedef std::vector<unsigned char> val_vec_type;
  bool fillGenericConstant(const DataLayout &DL, const Constant *CV,
                           val_vec_type &Vals, uint64_t Offset);
  bool fillConstantDataArray(const DataLayout &DL, const ConstantDataArray *CDA,
                             val_vec_type &Vals, int Offset);
  bool fillConstantArray(const DataLayout &DL, const ConstantArray *CA,
                         val_vec_type &Vals, int Offset);
  bool fillConstantStruct(const DataLayout &DL, const ConstantStruct *CS,
                          val_vec_type &Vals, int Offset);
  bool getConstantFieldValue(const GlobalAddressSDNode *Node, uint64_t Offset,
                             uint64_t Size, unsigned char *ByteSeq);
  bool checkLoadDef(unsigned DefReg, unsigned match_load_op);

  // Mapping from ConstantStruct global value to corresponding byte-list values
  std::map<const void *, val_vec_type> cs_vals_;
  // Mapping from vreg to load memory opcode
  std::map<unsigned, unsigned> load_to_vreg_;
  // Current function
  const Function *curr_func_;
};
} // namespace

// ComplexPattern used on BPF Load/Store instructions
bool BPFDAGToDAGISel::SelectAddr(SDValue Addr, SDValue &Base, SDValue &Offset) {
  // if Address is FI, get the TargetFrameIndex.
  SDLoc DL(Addr);
  if (FrameIndexSDNode *FIN = dyn_cast<FrameIndexSDNode>(Addr)) {
    Base = CurDAG->getTargetFrameIndex(FIN->getIndex(), MVT::i64);
    Offset = CurDAG->getTargetConstant(0, DL, MVT::i64);
    return true;
  }

  if (Addr.getOpcode() == ISD::TargetExternalSymbol ||
      Addr.getOpcode() == ISD::TargetGlobalAddress)
    return false;

  // Addresses of the form Addr+const or Addr|const
  if (CurDAG->isBaseWithConstantOffset(Addr)) {
    ConstantSDNode *CN = dyn_cast<ConstantSDNode>(Addr.getOperand(1));
    if (isInt<16>(CN->getSExtValue())) {

      // If the first operand is a FI, get the TargetFI Node
      if (FrameIndexSDNode *FIN =
              dyn_cast<FrameIndexSDNode>(Addr.getOperand(0)))
        Base = CurDAG->getTargetFrameIndex(FIN->getIndex(), MVT::i64);
      else
        Base = Addr.getOperand(0);

      Offset = CurDAG->getTargetConstant(CN->getSExtValue(), DL, MVT::i64);
      return true;
    }
  }

  Base = Addr;
  Offset = CurDAG->getTargetConstant(0, DL, MVT::i64);
  return true;
}

// ComplexPattern used on BPF FI instruction
bool BPFDAGToDAGISel::SelectFIAddr(SDValue Addr, SDValue &Base,
                                   SDValue &Offset) {
  SDLoc DL(Addr);

  if (!CurDAG->isBaseWithConstantOffset(Addr))
    return false;

  // Addresses of the form Addr+const or Addr|const
  ConstantSDNode *CN = dyn_cast<ConstantSDNode>(Addr.getOperand(1));
  if (isInt<16>(CN->getSExtValue())) {

    // If the first operand is a FI, get the TargetFI Node
    if (FrameIndexSDNode *FIN = dyn_cast<FrameIndexSDNode>(Addr.getOperand(0)))
      Base = CurDAG->getTargetFrameIndex(FIN->getIndex(), MVT::i64);
    else
      return false;

    Offset = CurDAG->getTargetConstant(CN->getSExtValue(), DL, MVT::i64);
    return true;
  }

  return false;
}

bool BPFDAGToDAGISel::SelectInlineAsmMemoryOperand(
    const SDValue &Op, unsigned ConstraintCode, std::vector<SDValue> &OutOps) {
  SDValue Op0, Op1;
  switch (ConstraintCode) {
  default:
    return true;
  case InlineAsm::Constraint_m: // memory
    if (!SelectAddr(Op, Op0, Op1))
      return true;
    break;
  }

  SDLoc DL(Op);
  SDValue AluOp = CurDAG->getTargetConstant(ISD::ADD, DL, MVT::i32);;
  OutOps.push_back(Op0);
  OutOps.push_back(Op1);
  OutOps.push_back(AluOp);
  return false;
}

void BPFDAGToDAGISel::Select(SDNode *Node) {
  unsigned Opcode = Node->getOpcode();

  // If we have a custom node, we already have selected!
  if (Node->isMachineOpcode()) {
    LLVM_DEBUG(dbgs() << "== "; Node->dump(CurDAG); dbgs() << '\n');
    return;
  }

  // tablegen selection should be handled here.
  switch (Opcode) {
  default:
    break;
  case ISD::SDIV: {
    DebugLoc Empty;
    const DebugLoc &DL = Node->getDebugLoc();
    if (DL != Empty)
      errs() << "Error at line " << DL.getLine() << ": ";
    else
      errs() << "Error: ";
    errs() << "Unsupport signed division for DAG: ";
    Node->print(errs(), CurDAG);
    errs() << "Please convert to unsigned div/mod.\n";
    break;
  }
  case ISD::INTRINSIC_W_CHAIN: {
    unsigned IntNo = cast<ConstantSDNode>(Node->getOperand(1))->getZExtValue();
    switch (IntNo) {
    case Intrinsic::bpf_load_byte:
    case Intrinsic::bpf_load_half:
    case Intrinsic::bpf_load_word: {
      SDLoc DL(Node);
      SDValue Chain = Node->getOperand(0);
      SDValue N1 = Node->getOperand(1);
      SDValue Skb = Node->getOperand(2);
      SDValue N3 = Node->getOperand(3);

      SDValue R6Reg = CurDAG->getRegister(BPF::R6, MVT::i64);
      Chain = CurDAG->getCopyToReg(Chain, DL, R6Reg, Skb, SDValue());
      Node = CurDAG->UpdateNodeOperands(Node, Chain, N1, R6Reg, N3);
      break;
    }
    }
    break;
  }

  case ISD::FrameIndex: {
    int FI = cast<FrameIndexSDNode>(Node)->getIndex();
    EVT VT = Node->getValueType(0);
    SDValue TFI = CurDAG->getTargetFrameIndex(FI, VT);
    unsigned Opc = BPF::MOV_rr;
    if (Node->hasOneUse()) {
      CurDAG->SelectNodeTo(Node, Opc, VT, TFI);
      return;
    }
    ReplaceNode(Node, CurDAG->getMachineNode(Opc, SDLoc(Node), VT, TFI));
    return;
  }
  }

  // Select the default instruction
  SelectCode(Node);
}

void BPFDAGToDAGISel::PreprocessLoad(SDNode *Node,
                                     SelectionDAG::allnodes_iterator &I) {
  union {
    uint8_t c[8];
    uint16_t s;
    uint32_t i;
    uint64_t d;
  } new_val; // hold up the constant values replacing loads.
  bool to_replace = false;
  SDLoc DL(Node);
  const LoadSDNode *LD = cast<LoadSDNode>(Node);
  uint64_t size = LD->getMemOperand()->getSize();

  if (!size || size > 8 || (size & (size - 1)))
    return;

  SDNode *LDAddrNode = LD->getOperand(1).getNode();
  // Match LDAddr against either global_addr or (global_addr + offset)
  unsigned opcode = LDAddrNode->getOpcode();
  if (opcode == ISD::ADD) {
    SDValue OP1 = LDAddrNode->getOperand(0);
    SDValue OP2 = LDAddrNode->getOperand(1);

    // We want to find the pattern global_addr + offset
    SDNode *OP1N = OP1.getNode();
    if (OP1N->getOpcode() <= ISD::BUILTIN_OP_END || OP1N->getNumOperands() == 0)
      return;

    LLVM_DEBUG(dbgs() << "Check candidate load: "; LD->dump(); dbgs() << '\n');

    const GlobalAddressSDNode *GADN =
        dyn_cast<GlobalAddressSDNode>(OP1N->getOperand(0).getNode());
    const ConstantSDNode *CDN = dyn_cast<ConstantSDNode>(OP2.getNode());
    if (GADN && CDN)
      to_replace =
          getConstantFieldValue(GADN, CDN->getZExtValue(), size, new_val.c);
  } else if (LDAddrNode->getOpcode() > ISD::BUILTIN_OP_END &&
             LDAddrNode->getNumOperands() > 0) {
    LLVM_DEBUG(dbgs() << "Check candidate load: "; LD->dump(); dbgs() << '\n');

    SDValue OP1 = LDAddrNode->getOperand(0);
    if (const GlobalAddressSDNode *GADN =
            dyn_cast<GlobalAddressSDNode>(OP1.getNode()))
      to_replace = getConstantFieldValue(GADN, 0, size, new_val.c);
  }

  if (!to_replace)
    return;

  // replacing the old with a new value
  uint64_t val;
  if (size == 1)
    val = new_val.c[0];
  else if (size == 2)
    val = new_val.s;
  else if (size == 4)
    val = new_val.i;
  else {
    val = new_val.d;
  }

  LLVM_DEBUG(dbgs() << "Replacing load of size " << size << " with constant "
                    << val << '\n');
  SDValue NVal = CurDAG->getConstant(val, DL, MVT::i64);

  // After replacement, the current node is dead, we need to
  // go backward one step to make iterator still work
  I--;
  SDValue From[] = {SDValue(Node, 0), SDValue(Node, 1)};
  SDValue To[] = {NVal, NVal};
  CurDAG->ReplaceAllUsesOfValuesWith(From, To, 2);
  I++;
  // It is safe to delete node now
  CurDAG->DeleteNode(Node);
}

void BPFDAGToDAGISel::PreprocessISelDAG() {
  // Iterate through all nodes, interested in the following cases:
  //
  //  . loads from ConstantStruct or ConstantArray of constructs
  //    which can be turns into constant itself, with this we can
  //    avoid reading from read-only section at runtime.
  //
  //  . reg truncating is often the result of 8/16/32bit->64bit or
  //    8/16bit->32bit conversion. If the reg value is loaded with
  //    masked byte width, the AND operation can be removed since
  //    BPF LOAD already has zero extension.
  //
  //    This also solved a correctness issue.
  //    In BPF socket-related program, e.g., __sk_buff->{data, data_end}
  //    are 32-bit registers, but later on, kernel verifier will rewrite
  //    it with 64-bit value. Therefore, truncating the value after the
  //    load will result in incorrect code.

  // clear the load_to_vreg_ map so that we have a clean start
  // for this function.
  if (!curr_func_) {
    curr_func_ = FuncInfo->Fn;
  } else if (curr_func_ != FuncInfo->Fn) {
    load_to_vreg_.clear();
    curr_func_ = FuncInfo->Fn;
  }

  for (SelectionDAG::allnodes_iterator I = CurDAG->allnodes_begin(),
                                       E = CurDAG->allnodes_end();
       I != E;) {
    SDNode *Node = &*I++;
    unsigned Opcode = Node->getOpcode();
    if (Opcode == ISD::LOAD)
      PreprocessLoad(Node, I);
    else if (Opcode == ISD::CopyToReg)
      PreprocessCopyToReg(Node);
    else if (Opcode == ISD::AND)
      PreprocessTrunc(Node, I);
  }
}

bool BPFDAGToDAGISel::getConstantFieldValue(const GlobalAddressSDNode *Node,
                                            uint64_t Offset, uint64_t Size,
                                            unsigned char *ByteSeq) {
  const GlobalVariable *V = dyn_cast<GlobalVariable>(Node->getGlobal());

  if (!V || !V->hasInitializer())
    return false;

  const Constant *Init = V->getInitializer();
  const DataLayout &DL = CurDAG->getDataLayout();
  val_vec_type TmpVal;

  auto it = cs_vals_.find(static_cast<const void *>(Init));
  if (it != cs_vals_.end()) {
    TmpVal = it->second;
  } else {
    uint64_t total_size = 0;
    if (const ConstantStruct *CS = dyn_cast<ConstantStruct>(Init))
      total_size =
          DL.getStructLayout(cast<StructType>(CS->getType()))->getSizeInBytes();
    else if (const ConstantArray *CA = dyn_cast<ConstantArray>(Init))
      total_size = DL.getTypeAllocSize(CA->getType()->getElementType()) *
                   CA->getNumOperands();
    else
      return false;

    val_vec_type Vals(total_size, 0);
    if (fillGenericConstant(DL, Init, Vals, 0) == false)
      return false;
    cs_vals_[static_cast<const void *>(Init)] = Vals;
    TmpVal = std::move(Vals);
  }

  // test whether host endianness matches target
  union {
    uint8_t c[2];
    uint16_t s;
  } test_buf;
  uint16_t test_val = 0x2345;
  if (DL.isLittleEndian())
    support::endian::write16le(test_buf.c, test_val);
  else
    support::endian::write16be(test_buf.c, test_val);

  bool endian_match = test_buf.s == test_val;
  for (uint64_t i = Offset, j = 0; i < Offset + Size; i++, j++)
    ByteSeq[j] = endian_match ? TmpVal[i] : TmpVal[Offset + Size - 1 - j];

  return true;
}

bool BPFDAGToDAGISel::fillGenericConstant(const DataLayout &DL,
                                          const Constant *CV,
                                          val_vec_type &Vals, uint64_t Offset) {
  uint64_t Size = DL.getTypeAllocSize(CV->getType());

  if (isa<ConstantAggregateZero>(CV) || isa<UndefValue>(CV))
    return true; // already done

  if (const ConstantInt *CI = dyn_cast<ConstantInt>(CV)) {
    uint64_t val = CI->getZExtValue();
    LLVM_DEBUG(dbgs() << "Byte array at offset " << Offset << " with value "
                      << val << '\n');

    if (Size > 8 || (Size & (Size - 1)))
      return false;

    // Store based on target endian
    for (uint64_t i = 0; i < Size; ++i) {
      Vals[Offset + i] = DL.isLittleEndian()
                             ? ((val >> (i * 8)) & 0xFF)
                             : ((val >> ((Size - i - 1) * 8)) & 0xFF);
    }
    return true;
  }

  if (const ConstantDataArray *CDA = dyn_cast<ConstantDataArray>(CV))
    return fillConstantDataArray(DL, CDA, Vals, Offset);

  if (const ConstantArray *CA = dyn_cast<ConstantArray>(CV))
    return fillConstantArray(DL, CA, Vals, Offset);

  if (const ConstantStruct *CVS = dyn_cast<ConstantStruct>(CV))
    return fillConstantStruct(DL, CVS, Vals, Offset);

  return false;
}

bool BPFDAGToDAGISel::fillConstantDataArray(const DataLayout &DL,
                                            const ConstantDataArray *CDA,
                                            val_vec_type &Vals, int Offset) {
  for (unsigned i = 0, e = CDA->getNumElements(); i != e; ++i) {
    if (fillGenericConstant(DL, CDA->getElementAsConstant(i), Vals, Offset) ==
        false)
      return false;
    Offset += DL.getTypeAllocSize(CDA->getElementAsConstant(i)->getType());
  }

  return true;
}

bool BPFDAGToDAGISel::fillConstantArray(const DataLayout &DL,
                                        const ConstantArray *CA,
                                        val_vec_type &Vals, int Offset) {
  for (unsigned i = 0, e = CA->getNumOperands(); i != e; ++i) {
    if (fillGenericConstant(DL, CA->getOperand(i), Vals, Offset) == false)
      return false;
    Offset += DL.getTypeAllocSize(CA->getOperand(i)->getType());
  }

  return true;
}

bool BPFDAGToDAGISel::fillConstantStruct(const DataLayout &DL,
                                         const ConstantStruct *CS,
                                         val_vec_type &Vals, int Offset) {
  const StructLayout *Layout = DL.getStructLayout(CS->getType());
  for (unsigned i = 0, e = CS->getNumOperands(); i != e; ++i) {
    const Constant *Field = CS->getOperand(i);
    uint64_t SizeSoFar = Layout->getElementOffset(i);
    if (fillGenericConstant(DL, Field, Vals, Offset + SizeSoFar) == false)
      return false;
  }
  return true;
}

void BPFDAGToDAGISel::PreprocessCopyToReg(SDNode *Node) {
  const RegisterSDNode *RegN = dyn_cast<RegisterSDNode>(Node->getOperand(1));
  if (!RegN || !Register::isVirtualRegister(RegN->getReg()))
    return;

  const LoadSDNode *LD = dyn_cast<LoadSDNode>(Node->getOperand(2));
  if (!LD)
    return;

  // Assign a load value to a virtual register. record its load width
  unsigned mem_load_op = 0;
  switch (LD->getMemOperand()->getSize()) {
  default:
    return;
  case 4:
    mem_load_op = BPF::LDW;
    break;
  case 2:
    mem_load_op = BPF::LDH;
    break;
  case 1:
    mem_load_op = BPF::LDB;
    break;
  }

  LLVM_DEBUG(dbgs() << "Find Load Value to VReg "
                    << Register::virtReg2Index(RegN->getReg()) << '\n');
  load_to_vreg_[RegN->getReg()] = mem_load_op;
}

void BPFDAGToDAGISel::PreprocessTrunc(SDNode *Node,
                                      SelectionDAG::allnodes_iterator &I) {
  ConstantSDNode *MaskN = dyn_cast<ConstantSDNode>(Node->getOperand(1));
  if (!MaskN)
    return;

  // The Reg operand should be a virtual register, which is defined
  // outside the current basic block. DAG combiner has done a pretty
  // good job in removing truncating inside a single basic block except
  // when the Reg operand comes from bpf_load_[byte | half | word] for
  // which the generic optimizer doesn't understand their results are
  // zero extended.
  SDValue BaseV = Node->getOperand(0);
  if (BaseV.getOpcode() == ISD::INTRINSIC_W_CHAIN) {
    unsigned IntNo = cast<ConstantSDNode>(BaseV->getOperand(1))->getZExtValue();
    uint64_t MaskV = MaskN->getZExtValue();

    if (!((IntNo == Intrinsic::bpf_load_byte && MaskV == 0xFF) ||
          (IntNo == Intrinsic::bpf_load_half && MaskV == 0xFFFF) ||
          (IntNo == Intrinsic::bpf_load_word && MaskV == 0xFFFFFFFF)))
      return;

    LLVM_DEBUG(dbgs() << "Remove the redundant AND operation in: ";
               Node->dump(); dbgs() << '\n');

    I--;
    CurDAG->ReplaceAllUsesWith(SDValue(Node, 0), BaseV);
    I++;
    CurDAG->DeleteNode(Node);

    return;
  }

  // Multiple basic blocks case.
  if (BaseV.getOpcode() != ISD::CopyFromReg)
    return;

  unsigned match_load_op = 0;
  switch (MaskN->getZExtValue()) {
  default:
    return;
  case 0xFFFFFFFF:
    match_load_op = BPF::LDW;
    break;
  case 0xFFFF:
    match_load_op = BPF::LDH;
    break;
  case 0xFF:
    match_load_op = BPF::LDB;
    break;
  }

  const RegisterSDNode *RegN =
      dyn_cast<RegisterSDNode>(BaseV.getNode()->getOperand(1));
  if (!RegN || !Register::isVirtualRegister(RegN->getReg()))
    return;
  unsigned AndOpReg = RegN->getReg();
  LLVM_DEBUG(dbgs() << "Examine " << printReg(AndOpReg) << '\n');

  // Examine the PHI insns in the MachineBasicBlock to found out the
  // definitions of this virtual register. At this stage (DAG2DAG
  // transformation), only PHI machine insns are available in the machine basic
  // block.
  MachineBasicBlock *MBB = FuncInfo->MBB;
  MachineInstr *MII = nullptr;
  for (auto &MI : *MBB) {
    for (unsigned i = 0; i < MI.getNumOperands(); ++i) {
      const MachineOperand &MOP = MI.getOperand(i);
      if (!MOP.isReg() || !MOP.isDef())
        continue;
      Register Reg = MOP.getReg();
      if (Register::isVirtualRegister(Reg) && Reg == AndOpReg) {
        MII = &MI;
        break;
      }
    }
  }

  if (MII == nullptr) {
    // No phi definition in this block.
    if (!checkLoadDef(AndOpReg, match_load_op))
      return;
  } else {
    // The PHI node looks like:
    //   %2 = PHI %0, <%bb.1>, %1, <%bb.3>
    // Trace each incoming definition, e.g., (%0, %bb.1) and (%1, %bb.3)
    // The AND operation can be removed if both %0 in %bb.1 and %1 in
    // %bb.3 are defined with a load matching the MaskN.
    LLVM_DEBUG(dbgs() << "Check PHI Insn: "; MII->dump(); dbgs() << '\n');
    unsigned PrevReg = -1;
    for (unsigned i = 0; i < MII->getNumOperands(); ++i) {
      const MachineOperand &MOP = MII->getOperand(i);
      if (MOP.isReg()) {
        if (MOP.isDef())
          continue;
        PrevReg = MOP.getReg();
        if (!Register::isVirtualRegister(PrevReg))
          return;
        if (!checkLoadDef(PrevReg, match_load_op))
          return;
      }
    }
  }

  LLVM_DEBUG(dbgs() << "Remove the redundant AND operation in: "; Node->dump();
             dbgs() << '\n');

  I--;
  CurDAG->ReplaceAllUsesWith(SDValue(Node, 0), BaseV);
  I++;
  CurDAG->DeleteNode(Node);
}

bool BPFDAGToDAGISel::checkLoadDef(unsigned DefReg, unsigned match_load_op) {
  auto it = load_to_vreg_.find(DefReg);
  if (it == load_to_vreg_.end())
    return false; // The definition of register is not exported yet.

  return it->second == match_load_op;
}

FunctionPass *llvm::createBPFISelDag(BPFTargetMachine &TM) {
  return new BPFDAGToDAGISel(TM);
}
