//===-- ImplicitNullChecks.cpp - Fold null checks into memory accesses ----===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This pass turns explicit null checks of the form
//
//   test %r10, %r10
//   je throw_npe
//   movl (%r10), %esi
//   ...
//
// to
//
//   faulting_load_op("movl (%r10), %esi", throw_npe)
//   ...
//
// With the help of a runtime that understands the .fault_maps section,
// faulting_load_op branches to throw_npe if executing movl (%r10), %esi incurs
// a page fault.
//
//===----------------------------------------------------------------------===//

#include "llvm/ADT/SmallVector.h"
#include "llvm/CodeGen/Passes.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineOperand.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/MachineModuleInfo.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/Instruction.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#include "llvm/Target/TargetSubtargetInfo.h"
#include "llvm/Target/TargetInstrInfo.h"

using namespace llvm;

static cl::opt<unsigned> PageSize("imp-null-check-page-size",
                                  cl::desc("The page size of the target in "
                                           "bytes"),
                                  cl::init(4096));

namespace {

class ImplicitNullChecks : public MachineFunctionPass {
  /// Represents one null check that can be made implicit.
  struct NullCheck {
    // The memory operation the null check can be folded into.
    MachineInstr *MemOperation;

    // The instruction actually doing the null check (Ptr != 0).
    MachineInstr *CheckOperation;

    // The block the check resides in.
    MachineBasicBlock *CheckBlock;

    // The block branched to if the the pointer is non-null.
    MachineBasicBlock *NotNullSucc;

    // The block branched to if the the pointer is null.
    MachineBasicBlock *NullSucc;

    NullCheck()
        : MemOperation(), CheckOperation(), CheckBlock(), NotNullSucc(),
          NullSucc() {}

    explicit NullCheck(MachineInstr *memOperation, MachineInstr *checkOperation,
                       MachineBasicBlock *checkBlock,
                       MachineBasicBlock *notNullSucc,
                       MachineBasicBlock *nullSucc)
        : MemOperation(memOperation), CheckOperation(checkOperation),
          CheckBlock(checkBlock), NotNullSucc(notNullSucc), NullSucc(nullSucc) {
    }
  };

  const TargetInstrInfo *TII = nullptr;
  const TargetRegisterInfo *TRI = nullptr;
  MachineModuleInfo *MMI = nullptr;

  bool analyzeBlockForNullChecks(MachineBasicBlock &MBB,
                                 SmallVectorImpl<NullCheck> &NullCheckList);
  MachineInstr *insertFaultingLoad(MachineInstr *LoadMI, MachineBasicBlock *MBB,
                                   MCSymbol *HandlerLabel);
  void rewriteNullChecks(ArrayRef<NullCheck> NullCheckList);

public:
  static char ID;

  ImplicitNullChecks() : MachineFunctionPass(ID) {
    initializeImplicitNullChecksPass(*PassRegistry::getPassRegistry());
  }

  bool runOnMachineFunction(MachineFunction &MF) override;
};
}

bool ImplicitNullChecks::runOnMachineFunction(MachineFunction &MF) {
  TII = MF.getSubtarget().getInstrInfo();
  TRI = MF.getRegInfo().getTargetRegisterInfo();
  MMI = &MF.getMMI();

  SmallVector<NullCheck, 16> NullCheckList;

  for (auto &MBB : MF)
    analyzeBlockForNullChecks(MBB, NullCheckList);

  if (!NullCheckList.empty())
    rewriteNullChecks(NullCheckList);

  return !NullCheckList.empty();
}

/// Analyze MBB to check if its terminating branch can be turned into an
/// implicit null check.  If yes, append a description of the said null check to
/// NullCheckList and return true, else return false.
bool ImplicitNullChecks::analyzeBlockForNullChecks(
    MachineBasicBlock &MBB, SmallVectorImpl<NullCheck> &NullCheckList) {
  typedef TargetInstrInfo::MachineBranchPredicate MachineBranchPredicate;

  MachineBranchPredicate MBP;

  if (TII->AnalyzeBranchPredicate(MBB, MBP, true))
    return false;

  // Is the predicate comparing an integer to zero?
  if (!(MBP.LHS.isReg() && MBP.RHS.isImm() && MBP.RHS.getImm() == 0 &&
        (MBP.Predicate == MachineBranchPredicate::PRED_NE ||
         MBP.Predicate == MachineBranchPredicate::PRED_EQ)))
    return false;

  // If we cannot erase the test instruction itself, then making the null check
  // implicit does not buy us much.
  if (!MBP.SingleUseCondition)
    return false;

  MachineBasicBlock *NotNullSucc, *NullSucc;

  if (MBP.Predicate == MachineBranchPredicate::PRED_NE) {
    NotNullSucc = MBP.TrueDest;
    NullSucc = MBP.FalseDest;
  } else {
    NotNullSucc = MBP.FalseDest;
    NullSucc = MBP.TrueDest;
  }

  // We handle the simplest case for now.  We can potentially do better by using
  // the machine dominator tree.
  if (NotNullSucc->pred_size() != 1)
    return false;

  // Starting with a code fragment like:
  //
  //   test %RAX, %RAX
  //   jne LblNotNull
  //
  //  LblNull:
  //   callq throw_NullPointerException
  //
  //  LblNotNull:
  //   Def = Load (%RAX + <offset>)
  //   ...
  //
  //
  // we want to end up with
  //
  //   Def = TrappingLoad (%RAX + <offset>), LblNull
  //   jmp LblNotNull ;; explicit or fallthrough
  //
  //  LblNotNull:
  //   ...
  //
  //  LblNull:
  //   callq throw_NullPointerException
  //

  unsigned PointerReg = MBP.LHS.getReg();
  MachineInstr *MemOp = &*NotNullSucc->begin();
  unsigned BaseReg, Offset;
  if (TII->getMemOpBaseRegImmOfs(MemOp, BaseReg, Offset, TRI))
    if (MemOp->mayLoad() && !MemOp->isPredicable() && BaseReg == PointerReg &&
        Offset < PageSize && MemOp->getDesc().getNumDefs() == 1) {
      NullCheckList.emplace_back(MemOp, MBP.ConditionDef, &MBB, NotNullSucc,
                                 NullSucc);
      return true;
    }

  return false;
}

/// Wrap a machine load instruction, LoadMI, into a FAULTING_LOAD_OP machine
/// instruction.  The FAULTING_LOAD_OP instruction does the same load as LoadMI
/// (defining the same register), and branches to HandlerLabel if the load
/// faults.  The FAULTING_LOAD_OP instruction is inserted at the end of MBB.
MachineInstr *ImplicitNullChecks::insertFaultingLoad(MachineInstr *LoadMI,
                                                     MachineBasicBlock *MBB,
                                                     MCSymbol *HandlerLabel) {
  DebugLoc DL;
  unsigned NumDefs = LoadMI->getDesc().getNumDefs();
  assert(NumDefs == 1 && "other cases unhandled!");
  (void)NumDefs;

  unsigned DefReg = LoadMI->defs().begin()->getReg();
  assert(std::distance(LoadMI->defs().begin(), LoadMI->defs().end()) == 1 &&
         "expected exactly one def!");

  auto MIB = BuildMI(MBB, DL, TII->get(TargetOpcode::FAULTING_LOAD_OP), DefReg)
                 .addSym(HandlerLabel)
                 .addImm(LoadMI->getOpcode());

  for (auto &MO : LoadMI->uses())
    MIB.addOperand(MO);

  MIB.setMemRefs(LoadMI->memoperands_begin(), LoadMI->memoperands_end());

  return MIB;
}

/// Rewrite the null checks in NullCheckList into implicit null checks.
void ImplicitNullChecks::rewriteNullChecks(
    ArrayRef<ImplicitNullChecks::NullCheck> NullCheckList) {
  DebugLoc DL;

  for (auto &NC : NullCheckList) {
    MCSymbol *HandlerLabel = MMI->getContext().createTempSymbol();

    // Remove the conditional branch dependent on the null check.
    unsigned BranchesRemoved = TII->RemoveBranch(*NC.CheckBlock);
    (void)BranchesRemoved;
    assert(BranchesRemoved > 0 && "expected at least one branch!");

    // Insert a faulting load where the conditional branch was originally.  We
    // check earlier ensures that this bit of code motion is legal.  We do not
    // touch the successors list for any basic block since we haven't changed
    // control flow, we've just made it implicit.
    insertFaultingLoad(NC.MemOperation, NC.CheckBlock, HandlerLabel);
    NC.MemOperation->removeFromParent();
    NC.CheckOperation->eraseFromParent();

    // Insert an *unconditional* branch to not-null successor.
    TII->InsertBranch(*NC.CheckBlock, NC.NotNullSucc, nullptr, /*Cond=*/None,
                      DL);

    // Emit the HandlerLabel as an EH_LABEL.
    BuildMI(*NC.NullSucc, NC.NullSucc->begin(), DL,
            TII->get(TargetOpcode::EH_LABEL)).addSym(HandlerLabel);
  }
}

char ImplicitNullChecks::ID = 0;
char &llvm::ImplicitNullChecksID = ImplicitNullChecks::ID;
INITIALIZE_PASS_BEGIN(ImplicitNullChecks, "implicit-null-checks",
                      "Implicit null checks", false, false)
INITIALIZE_PASS_END(ImplicitNullChecks, "implicit-null-checks",
                    "Implicit null checks", false, false)
