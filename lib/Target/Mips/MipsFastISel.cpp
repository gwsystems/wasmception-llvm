//===-- MipsastISel.cpp - Mips FastISel implementation
//---------------------===//

#include "llvm/CodeGen/FunctionLoweringInfo.h"
#include "llvm/CodeGen/FastISel.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/IR/GlobalAlias.h"
#include "llvm/IR/GlobalVariable.h"
#include "llvm/Target/TargetInstrInfo.h"
#include "llvm/Target/TargetLibraryInfo.h"
#include "MipsRegisterInfo.h"
#include "MipsISelLowering.h"
#include "MipsMachineFunction.h"
#include "MipsSubtarget.h"

using namespace llvm;

namespace {

// All possible address modes.
typedef struct Address {
  enum { RegBase, FrameIndexBase } BaseType;

  union {
    unsigned Reg;
    int FI;
  } Base;

  int64_t Offset;

  // Innocuous defaults for our address.
  Address() : BaseType(RegBase), Offset(0) { Base.Reg = 0; }
} Address;

class MipsFastISel final : public FastISel {

  /// Subtarget - Keep a pointer to the MipsSubtarget around so that we can
  /// make the right decision when generating code for different targets.
  const MipsSubtarget *Subtarget;
  Module &M;
  const TargetMachine &TM;
  const TargetInstrInfo &TII;
  const TargetLowering &TLI;
  MipsFunctionInfo *MFI;

  // Convenience variables to avoid some queries.
  LLVMContext *Context;

  bool TargetSupported;

public:
  explicit MipsFastISel(FunctionLoweringInfo &funcInfo,
                        const TargetLibraryInfo *libInfo)
      : FastISel(funcInfo, libInfo),
        M(const_cast<Module &>(*funcInfo.Fn->getParent())),
        TM(funcInfo.MF->getTarget()), TII(*TM.getInstrInfo()),
        TLI(*TM.getTargetLowering()) {
    Subtarget = &TM.getSubtarget<MipsSubtarget>();
    MFI = funcInfo.MF->getInfo<MipsFunctionInfo>();
    Context = &funcInfo.Fn->getContext();
    TargetSupported = ((Subtarget->getRelocationModel() == Reloc::PIC_) &&
                       (Subtarget->hasMips32r2() && (Subtarget->isABI_O32())));
  }

  bool TargetSelectInstruction(const Instruction *I) override;
  unsigned TargetMaterializeConstant(const Constant *C) override;

  bool ComputeAddress(const Value *Obj, Address &Addr);

private:
  bool EmitStore(MVT VT, unsigned SrcReg, Address &Addr,
                 unsigned Alignment = 0);
  bool SelectRet(const Instruction *I);
  bool SelectStore(const Instruction *I);

  bool isTypeLegal(Type *Ty, MVT &VT);
  bool isLoadTypeLegal(Type *Ty, MVT &VT);

  unsigned MaterializeFP(const ConstantFP *CFP, MVT VT);
  unsigned MaterializeGV(const GlobalValue *GV, MVT VT);
  unsigned MaterializeInt(const Constant *C, MVT VT);
  unsigned Materialize32BitInt(int64_t Imm, const TargetRegisterClass *RC);
};

bool MipsFastISel::isTypeLegal(Type *Ty, MVT &VT) {
  EVT evt = TLI.getValueType(Ty, true);
  // Only handle simple types.
  if (evt == MVT::Other || !evt.isSimple())
    return false;
  VT = evt.getSimpleVT();

  // Handle all legal types, i.e. a register that will directly hold this
  // value.
  return TLI.isTypeLegal(VT);
}

bool MipsFastISel::isLoadTypeLegal(Type *Ty, MVT &VT) {
  if (isTypeLegal(Ty, VT))
    return true;
  // We will extend this in a later patch:
  //   If this is a type than can be sign or zero-extended to a basic operation
  //   go ahead and accept it now.
  return false;
}

bool MipsFastISel::ComputeAddress(const Value *Obj, Address &Addr) {
  // This construct looks a big awkward but it is how other ports handle this
  // and as this function is more fully completed, these cases which
  // return false will have additional code in them.
  //
  if (isa<Instruction>(Obj))
    return false;
  else if (isa<ConstantExpr>(Obj))
    return false;
  Addr.Base.Reg = getRegForValue(Obj);
  return Addr.Base.Reg != 0;
}

// Materialize a constant into a register, and return the register
// number (or zero if we failed to handle it).
unsigned MipsFastISel::TargetMaterializeConstant(const Constant *C) {
  EVT CEVT = TLI.getValueType(C->getType(), true);

  // Only handle simple types.
  if (!CEVT.isSimple())
    return 0;
  MVT VT = CEVT.getSimpleVT();

  if (const ConstantFP *CFP = dyn_cast<ConstantFP>(C))
    return MaterializeFP(CFP, VT);
  else if (const GlobalValue *GV = dyn_cast<GlobalValue>(C))
    return MaterializeGV(GV, VT);
  else if (isa<ConstantInt>(C))
    return MaterializeInt(C, VT);

  return 0;
}

bool MipsFastISel::EmitStore(MVT VT, unsigned SrcReg, Address &Addr,
                             unsigned Alignment) {
  //
  // more cases will be handled here in following patches.
  //
  if (VT != MVT::i32)
    return false;
  BuildMI(*FuncInfo.MBB, FuncInfo.InsertPt, DbgLoc, TII.get(Mips::SW))
      .addReg(SrcReg)
      .addReg(Addr.Base.Reg)
      .addImm(Addr.Offset);
  return true;
}

bool MipsFastISel::SelectStore(const Instruction *I) {
  Value *Op0 = I->getOperand(0);
  unsigned SrcReg = 0;

  // Atomic stores need special handling.
  if (cast<StoreInst>(I)->isAtomic())
    return false;

  // Verify we have a legal type before going any further.
  MVT VT;
  if (!isLoadTypeLegal(I->getOperand(0)->getType(), VT))
    return false;

  // Get the value to be stored into a register.
  SrcReg = getRegForValue(Op0);
  if (SrcReg == 0)
    return false;

  // See if we can handle this address.
  Address Addr;
  if (!ComputeAddress(I->getOperand(1), Addr))
    return false;

  if (!EmitStore(VT, SrcReg, Addr, cast<StoreInst>(I)->getAlignment()))
    return false;
  return true;
}

bool MipsFastISel::SelectRet(const Instruction *I) {
  const ReturnInst *Ret = cast<ReturnInst>(I);

  if (!FuncInfo.CanLowerReturn)
    return false;
  if (Ret->getNumOperands() > 0) {
    return false;
  }
  unsigned RetOpc = Mips::RetRA;
  BuildMI(*FuncInfo.MBB, FuncInfo.InsertPt, DbgLoc, TII.get(RetOpc));
  return true;
}

bool MipsFastISel::TargetSelectInstruction(const Instruction *I) {
  if (!TargetSupported)
    return false;
  switch (I->getOpcode()) {
  default:
    break;
  case Instruction::Store:
    return SelectStore(I);
  case Instruction::Ret:
    return SelectRet(I);
  }
  return false;
}
}

unsigned MipsFastISel::MaterializeFP(const ConstantFP *CFP, MVT VT) {
  return 0;
}

unsigned MipsFastISel::MaterializeGV(const GlobalValue *GV, MVT VT) {
  // For now 32-bit only.
  if (VT != MVT::i32)
    return 0;
  const TargetRegisterClass *RC = &Mips::GPR32RegClass;
  unsigned DestReg = createResultReg(RC);
  const GlobalVariable *GVar = dyn_cast<GlobalVariable>(GV);
  bool IsThreadLocal = GVar && GVar->isThreadLocal();
  // TLS not supported at this time.
  if (IsThreadLocal)
    return 0;
  BuildMI(*FuncInfo.MBB, FuncInfo.InsertPt, DbgLoc, TII.get(Mips::LW), DestReg)
      .addReg(MFI->getGlobalBaseReg())
      .addGlobalAddress(GV, 0, MipsII::MO_GOT);
  return DestReg;
}
unsigned MipsFastISel::MaterializeInt(const Constant *C, MVT VT) {
  if (VT != MVT::i32 && VT != MVT::i16 && VT != MVT::i8 && VT != MVT::i1)
    return 0;
  const TargetRegisterClass *RC = &Mips::GPR32RegClass;
  const ConstantInt *CI = cast<ConstantInt>(C);
  int64_t Imm;
  if (CI->isNegative())
    Imm = CI->getSExtValue();
  else
    Imm = CI->getZExtValue();
  return Materialize32BitInt(Imm, RC);
}

unsigned MipsFastISel::Materialize32BitInt(int64_t Imm,
                                           const TargetRegisterClass *RC) {
  unsigned ResultReg = createResultReg(RC);

  if (isInt<16>(Imm)) {
    unsigned Opc = Mips::ADDiu;
    BuildMI(*FuncInfo.MBB, FuncInfo.InsertPt, DbgLoc, TII.get(Opc), ResultReg)
        .addReg(Mips::ZERO)
        .addImm(Imm);
    return ResultReg;
  } else if (isUInt<16>(Imm)) {
    BuildMI(*FuncInfo.MBB, FuncInfo.InsertPt, DbgLoc, TII.get(Mips::ORi),
            ResultReg)
        .addReg(Mips::ZERO)
        .addImm(Imm);
    return ResultReg;
  }
  unsigned Lo = Imm & 0xFFFF;
  unsigned Hi = (Imm >> 16) & 0xFFFF;
  if (Lo) {
    // Both Lo and Hi have nonzero bits.
    unsigned TmpReg = createResultReg(RC);
    BuildMI(*FuncInfo.MBB, FuncInfo.InsertPt, DbgLoc, TII.get(Mips::LUi),
            TmpReg).addImm(Hi);
    BuildMI(*FuncInfo.MBB, FuncInfo.InsertPt, DbgLoc, TII.get(Mips::ORi),
            ResultReg)
        .addReg(TmpReg)
        .addImm(Lo);

  } else {
    BuildMI(*FuncInfo.MBB, FuncInfo.InsertPt, DbgLoc, TII.get(Mips::LUi),
            ResultReg).addImm(Hi);
  }
  return ResultReg;
}

namespace llvm {
FastISel *Mips::createFastISel(FunctionLoweringInfo &funcInfo,
                               const TargetLibraryInfo *libInfo) {
  return new MipsFastISel(funcInfo, libInfo);
}
}
