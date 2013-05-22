//===----- AggressiveAntiDepBreaker.cpp - Anti-dep breaker ----------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the AggressiveAntiDepBreaker class, which
// implements register anti-dependence breaking during post-RA
// scheduling. It attempts to break all anti-dependencies within a
// block.
//
//===----------------------------------------------------------------------===//

#define DEBUG_TYPE "post-RA-sched"
#include "AggressiveAntiDepBreaker.h"
#include "llvm/CodeGen/MachineBasicBlock.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/CodeGen/RegisterClassInfo.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Target/TargetInstrInfo.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/Target/TargetRegisterInfo.h"
using namespace llvm;

// If DebugDiv > 0 then only break antidep with (ID % DebugDiv) == DebugMod
static cl::opt<int>
DebugDiv("agg-antidep-debugdiv",
         cl::desc("Debug control for aggressive anti-dep breaker"),
         cl::init(0), cl::Hidden);
static cl::opt<int>
DebugMod("agg-antidep-debugmod",
         cl::desc("Debug control for aggressive anti-dep breaker"),
         cl::init(0), cl::Hidden);

AggressiveAntiDepState::AggressiveAntiDepState(const unsigned TargetRegs,
                                               MachineBasicBlock *BB) :
  NumTargetRegs(TargetRegs), GroupNodes(TargetRegs, 0),
  GroupNodeIndices(TargetRegs, 0),
  KillIndices(TargetRegs, 0),
  DefIndices(TargetRegs, 0)
{
  const unsigned BBSize = BB->size();
  for (unsigned i = 0; i < NumTargetRegs; ++i) {
    // Initialize all registers to be in their own group. Initially we
    // assign the register to the same-indexed GroupNode.
    GroupNodeIndices[i] = i;
    // Initialize the indices to indicate that no registers are live.
    KillIndices[i] = ~0u;
    DefIndices[i] = BBSize;
  }
}

unsigned AggressiveAntiDepState::GetGroup(unsigned Reg) {
  unsigned Node = GroupNodeIndices[Reg];
  while (GroupNodes[Node] != Node)
    Node = GroupNodes[Node];

  return Node;
}

void AggressiveAntiDepState::GetGroupRegs(
  unsigned Group,
  std::vector<unsigned> &Regs,
  std::multimap<unsigned, AggressiveAntiDepState::RegisterReference> *RegRefs)
{
  for (unsigned Reg = 0; Reg != NumTargetRegs; ++Reg) {
    if ((GetGroup(Reg) == Group) && (RegRefs->count(Reg) > 0))
      Regs.push_back(Reg);
  }
}

unsigned AggressiveAntiDepState::UnionGroups(unsigned Reg1, unsigned Reg2)
{
  assert(GroupNodes[0] == 0 && "GroupNode 0 not parent!");
  assert(GroupNodeIndices[0] == 0 && "Reg 0 not in Group 0!");

  // find group for each register
  unsigned Group1 = GetGroup(Reg1);
  unsigned Group2 = GetGroup(Reg2);

  // if either group is 0, then that must become the parent
  unsigned Parent = (Group1 == 0) ? Group1 : Group2;
  unsigned Other = (Parent == Group1) ? Group2 : Group1;
  GroupNodes.at(Other) = Parent;
  return Parent;
}

unsigned AggressiveAntiDepState::LeaveGroup(unsigned Reg)
{
  // Create a new GroupNode for Reg. Reg's existing GroupNode must
  // stay as is because there could be other GroupNodes referring to
  // it.
  unsigned idx = GroupNodes.size();
  GroupNodes.push_back(idx);
  GroupNodeIndices[Reg] = idx;
  return idx;
}

bool AggressiveAntiDepState::IsLive(unsigned Reg)
{
  // KillIndex must be defined and DefIndex not defined for a register
  // to be live.
  return((KillIndices[Reg] != ~0u) && (DefIndices[Reg] == ~0u));
}



AggressiveAntiDepBreaker::
AggressiveAntiDepBreaker(MachineFunction& MFi,
                         const RegisterClassInfo &RCI,
                         TargetSubtargetInfo::RegClassVector& CriticalPathRCs) :
  AntiDepBreaker(), MF(MFi),
  MRI(MF.getRegInfo()),
  TII(MF.getTarget().getInstrInfo()),
  TRI(MF.getTarget().getRegisterInfo()),
  RegClassInfo(RCI),
  State(NULL) {
  /* Collect a bitset of all registers that are only broken if they
     are on the critical path. */
  for (unsigned i = 0, e = CriticalPathRCs.size(); i < e; ++i) {
    BitVector CPSet = TRI->getAllocatableSet(MF, CriticalPathRCs[i]);
    if (CriticalPathSet.none())
      CriticalPathSet = CPSet;
    else
      CriticalPathSet |= CPSet;
   }

  DEBUG(dbgs() << "AntiDep Critical-Path Registers:");
  DEBUG(for (int r = CriticalPathSet.find_first(); r != -1;
             r = CriticalPathSet.find_next(r))
          dbgs() << " " << TRI->getName(r));
  DEBUG(dbgs() << '\n');
}

AggressiveAntiDepBreaker::~AggressiveAntiDepBreaker() {
  delete State;
}

void AggressiveAntiDepBreaker::StartBlock(MachineBasicBlock *BB) {
  assert(State == NULL);
  State = new AggressiveAntiDepState(TRI->getNumRegs(), BB);

  bool IsReturnBlock = (!BB->empty() && BB->back().isReturn());
  std::vector<unsigned> &KillIndices = State->GetKillIndices();
  std::vector<unsigned> &DefIndices = State->GetDefIndices();

  // Examine the live-in regs of all successors.
  for (MachineBasicBlock::succ_iterator SI = BB->succ_begin(),
         SE = BB->succ_end(); SI != SE; ++SI)
    for (MachineBasicBlock::livein_iterator I = (*SI)->livein_begin(),
           E = (*SI)->livein_end(); I != E; ++I) {
      for (MCRegAliasIterator AI(*I, TRI, true); AI.isValid(); ++AI) {
        unsigned Reg = *AI;
        State->UnionGroups(Reg, 0);
        KillIndices[Reg] = BB->size();
        DefIndices[Reg] = ~0u;
      }
    }

  // Mark live-out callee-saved registers. In a return block this is
  // all callee-saved registers. In non-return this is any
  // callee-saved register that is not saved in the prolog.
  const MachineFrameInfo *MFI = MF.getFrameInfo();
  BitVector Pristine = MFI->getPristineRegs(BB);
  for (const uint16_t *I = TRI->getCalleeSavedRegs(&MF); *I; ++I) {
    unsigned Reg = *I;
    if (!IsReturnBlock && !Pristine.test(Reg)) continue;
    for (MCRegAliasIterator AI(Reg, TRI, true); AI.isValid(); ++AI) {
      unsigned AliasReg = *AI;
      State->UnionGroups(AliasReg, 0);
      KillIndices[AliasReg] = BB->size();
      DefIndices[AliasReg] = ~0u;
    }
  }
}

void AggressiveAntiDepBreaker::FinishBlock() {
  delete State;
  State = NULL;
}

void AggressiveAntiDepBreaker::Observe(MachineInstr *MI, unsigned Count,
                                       unsigned InsertPosIndex) {
  assert(Count < InsertPosIndex && "Instruction index out of expected range!");

  std::set<unsigned> PassthruRegs;
  GetPassthruRegs(MI, PassthruRegs);
  PrescanInstruction(MI, Count, PassthruRegs);
  ScanInstruction(MI, Count);

  DEBUG(dbgs() << "Observe: ");
  DEBUG(MI->dump());
  DEBUG(dbgs() << "\tRegs:");

  std::vector<unsigned> &DefIndices = State->GetDefIndices();
  for (unsigned Reg = 0; Reg != TRI->getNumRegs(); ++Reg) {
    // If Reg is current live, then mark that it can't be renamed as
    // we don't know the extent of its live-range anymore (now that it
    // has been scheduled). If it is not live but was defined in the
    // previous schedule region, then set its def index to the most
    // conservative location (i.e. the beginning of the previous
    // schedule region).
    if (State->IsLive(Reg)) {
      DEBUG(if (State->GetGroup(Reg) != 0)
              dbgs() << " " << TRI->getName(Reg) << "=g" <<
                State->GetGroup(Reg) << "->g0(region live-out)");
      State->UnionGroups(Reg, 0);
    } else if ((DefIndices[Reg] < InsertPosIndex)
               && (DefIndices[Reg] >= Count)) {
      DefIndices[Reg] = Count;
    }
  }
  DEBUG(dbgs() << '\n');
}

bool AggressiveAntiDepBreaker::IsImplicitDefUse(MachineInstr *MI,
                                                MachineOperand& MO)
{
  if (!MO.isReg() || !MO.isImplicit())
    return false;

  unsigned Reg = MO.getReg();
  if (Reg == 0)
    return false;

  MachineOperand *Op = NULL;
  if (MO.isDef())
    Op = MI->findRegisterUseOperand(Reg, true);
  else
    Op = MI->findRegisterDefOperand(Reg);

  return((Op != NULL) && Op->isImplicit());
}

void AggressiveAntiDepBreaker::GetPassthruRegs(MachineInstr *MI,
                                           std::set<unsigned>& PassthruRegs) {
  for (unsigned i = 0, e = MI->getNumOperands(); i != e; ++i) {
    MachineOperand &MO = MI->getOperand(i);
    if (!MO.isReg()) continue;
    if ((MO.isDef() && MI->isRegTiedToUseOperand(i)) ||
        IsImplicitDefUse(MI, MO)) {
      const unsigned Reg = MO.getReg();
      for (MCSubRegIterator SubRegs(Reg, TRI, /*IncludeSelf=*/true);
           SubRegs.isValid(); ++SubRegs)
        PassthruRegs.insert(*SubRegs);
    }
  }
}

/// AntiDepEdges - Return in Edges the anti- and output- dependencies
/// in SU that we want to consider for breaking.
static void AntiDepEdges(const SUnit *SU, std::vector<const SDep*>& Edges) {
  SmallSet<unsigned, 4> RegSet;
  for (SUnit::const_pred_iterator P = SU->Preds.begin(), PE = SU->Preds.end();
       P != PE; ++P) {
    if ((P->getKind() == SDep::Anti) || (P->getKind() == SDep::Output)) {
      unsigned Reg = P->getReg();
      if (RegSet.count(Reg) == 0) {
        Edges.push_back(&*P);
        RegSet.insert(Reg);
      }
    }
  }
}

/// CriticalPathStep - Return the next SUnit after SU on the bottom-up
/// critical path.
static const SUnit *CriticalPathStep(const SUnit *SU) {
  const SDep *Next = 0;
  unsigned NextDepth = 0;
  // Find the predecessor edge with the greatest depth.
  if (SU != 0) {
    for (SUnit::const_pred_iterator P = SU->Preds.begin(), PE = SU->Preds.end();
         P != PE; ++P) {
      const SUnit *PredSU = P->getSUnit();
      unsigned PredLatency = P->getLatency();
      unsigned PredTotalLatency = PredSU->getDepth() + PredLatency;
      // In the case of a latency tie, prefer an anti-dependency edge over
      // other types of edges.
      if (NextDepth < PredTotalLatency ||
          (NextDepth == PredTotalLatency && P->getKind() == SDep::Anti)) {
        NextDepth = PredTotalLatency;
        Next = &*P;
      }
    }
  }

  return (Next) ? Next->getSUnit() : 0;
}

void AggressiveAntiDepBreaker::HandleLastUse(unsigned Reg, unsigned KillIdx,
                                             const char *tag,
                                             const char *header,
                                             const char *footer) {
  std::vector<unsigned> &KillIndices = State->GetKillIndices();
  std::vector<unsigned> &DefIndices = State->GetDefIndices();
  std::multimap<unsigned, AggressiveAntiDepState::RegisterReference>&
    RegRefs = State->GetRegRefs();

  if (!State->IsLive(Reg)) {
    KillIndices[Reg] = KillIdx;
    DefIndices[Reg] = ~0u;
    RegRefs.erase(Reg);
    State->LeaveGroup(Reg);
    DEBUG(if (header != NULL) {
        dbgs() << header << TRI->getName(Reg); header = NULL; });
    DEBUG(dbgs() << "->g" << State->GetGroup(Reg) << tag);
  }
  // Repeat for subregisters.
  for (MCSubRegIterator SubRegs(Reg, TRI); SubRegs.isValid(); ++SubRegs) {
    unsigned SubregReg = *SubRegs;
    if (!State->IsLive(SubregReg)) {
      KillIndices[SubregReg] = KillIdx;
      DefIndices[SubregReg] = ~0u;
      RegRefs.erase(SubregReg);
      State->LeaveGroup(SubregReg);
      DEBUG(if (header != NULL) {
          dbgs() << header << TRI->getName(Reg); header = NULL; });
      DEBUG(dbgs() << " " << TRI->getName(SubregReg) << "->g" <<
            State->GetGroup(SubregReg) << tag);
    }
  }

  DEBUG(if ((header == NULL) && (footer != NULL)) dbgs() << footer);
}

void AggressiveAntiDepBreaker::PrescanInstruction(MachineInstr *MI,
                                                  unsigned Count,
                                             std::set<unsigned>& PassthruRegs) {
  std::vector<unsigned> &DefIndices = State->GetDefIndices();
  std::multimap<unsigned, AggressiveAntiDepState::RegisterReference>&
    RegRefs = State->GetRegRefs();

  // Handle dead defs by simulating a last-use of the register just
  // after the def. A dead def can occur because the def is truly
  // dead, or because only a subregister is live at the def. If we
  // don't do this the dead def will be incorrectly merged into the
  // previous def.
  for (unsigned i = 0, e = MI->getNumOperands(); i != e; ++i) {
    MachineOperand &MO = MI->getOperand(i);
    if (!MO.isReg() || !MO.isDef()) continue;
    unsigned Reg = MO.getReg();
    if (Reg == 0) continue;

    HandleLastUse(Reg, Count + 1, "", "\tDead Def: ", "\n");
  }

  DEBUG(dbgs() << "\tDef Groups:");
  for (unsigned i = 0, e = MI->getNumOperands(); i != e; ++i) {
    MachineOperand &MO = MI->getOperand(i);
    if (!MO.isReg() || !MO.isDef()) continue;
    unsigned Reg = MO.getReg();
    if (Reg == 0) continue;

    DEBUG(dbgs() << " " << TRI->getName(Reg) << "=g" << State->GetGroup(Reg));

    // If MI's defs have a special allocation requirement, don't allow
    // any def registers to be changed. Also assume all registers
    // defined in a call must not be changed (ABI).
    if (MI->isCall() || MI->hasExtraDefRegAllocReq() ||
        TII->isPredicated(MI)) {
      DEBUG(if (State->GetGroup(Reg) != 0) dbgs() << "->g0(alloc-req)");
      State->UnionGroups(Reg, 0);
    }

    // Any aliased that are live at this point are completely or
    // partially defined here, so group those aliases with Reg.
    for (MCRegAliasIterator AI(Reg, TRI, false); AI.isValid(); ++AI) {
      unsigned AliasReg = *AI;
      if (State->IsLive(AliasReg)) {
        State->UnionGroups(Reg, AliasReg);
        DEBUG(dbgs() << "->g" << State->GetGroup(Reg) << "(via " <<
              TRI->getName(AliasReg) << ")");
      }
    }

    // Note register reference...
    const TargetRegisterClass *RC = NULL;
    if (i < MI->getDesc().getNumOperands())
      RC = TII->getRegClass(MI->getDesc(), i, TRI, MF);
    AggressiveAntiDepState::RegisterReference RR = { &MO, RC };
    RegRefs.insert(std::make_pair(Reg, RR));
  }

  DEBUG(dbgs() << '\n');

  // Scan the register defs for this instruction and update
  // live-ranges.
  for (unsigned i = 0, e = MI->getNumOperands(); i != e; ++i) {
    MachineOperand &MO = MI->getOperand(i);
    if (!MO.isReg() || !MO.isDef()) continue;
    unsigned Reg = MO.getReg();
    if (Reg == 0) continue;
    // Ignore KILLs and passthru registers for liveness...
    if (MI->isKill() || (PassthruRegs.count(Reg) != 0))
      continue;

    // Update def for Reg and aliases.
    for (MCRegAliasIterator AI(Reg, TRI, true); AI.isValid(); ++AI)
      DefIndices[*AI] = Count;
  }
}

void AggressiveAntiDepBreaker::ScanInstruction(MachineInstr *MI,
                                               unsigned Count) {
  DEBUG(dbgs() << "\tUse Groups:");
  std::multimap<unsigned, AggressiveAntiDepState::RegisterReference>&
    RegRefs = State->GetRegRefs();

  // If MI's uses have special allocation requirement, don't allow
  // any use registers to be changed. Also assume all registers
  // used in a call must not be changed (ABI).
  // FIXME: The issue with predicated instruction is more complex. We are being
  // conservatively here because the kill markers cannot be trusted after
  // if-conversion:
  // %R6<def> = LDR %SP, %reg0, 92, pred:14, pred:%reg0; mem:LD4[FixedStack14]
  // ...
  // STR %R0, %R6<kill>, %reg0, 0, pred:0, pred:%CPSR; mem:ST4[%395]
  // %R6<def> = LDR %SP, %reg0, 100, pred:0, pred:%CPSR; mem:LD4[FixedStack12]
  // STR %R0, %R6<kill>, %reg0, 0, pred:14, pred:%reg0; mem:ST4[%396](align=8)
  //
  // The first R6 kill is not really a kill since it's killed by a predicated
  // instruction which may not be executed. The second R6 def may or may not
  // re-define R6 so it's not safe to change it since the last R6 use cannot be
  // changed.
  bool Special = MI->isCall() ||
    MI->hasExtraSrcRegAllocReq() ||
    TII->isPredicated(MI);

  // Scan the register uses for this instruction and update
  // live-ranges, groups and RegRefs.
  for (unsigned i = 0, e = MI->getNumOperands(); i != e; ++i) {
    MachineOperand &MO = MI->getOperand(i);
    if (!MO.isReg() || !MO.isUse()) continue;
    unsigned Reg = MO.getReg();
    if (Reg == 0) continue;

    DEBUG(dbgs() << " " << TRI->getName(Reg) << "=g" <<
          State->GetGroup(Reg));

    // It wasn't previously live but now it is, this is a kill. Forget
    // the previous live-range information and start a new live-range
    // for the register.
    HandleLastUse(Reg, Count, "(last-use)");

    if (Special) {
      DEBUG(if (State->GetGroup(Reg) != 0) dbgs() << "->g0(alloc-req)");
      State->UnionGroups(Reg, 0);
    }

    // Note register reference...
    const TargetRegisterClass *RC = NULL;
    if (i < MI->getDesc().getNumOperands())
      RC = TII->getRegClass(MI->getDesc(), i, TRI, MF);
    AggressiveAntiDepState::RegisterReference RR = { &MO, RC };
    RegRefs.insert(std::make_pair(Reg, RR));
  }

  DEBUG(dbgs() << '\n');

  // Form a group of all defs and uses of a KILL instruction to ensure
  // that all registers are renamed as a group.
  if (MI->isKill()) {
    DEBUG(dbgs() << "\tKill Group:");

    unsigned FirstReg = 0;
    for (unsigned i = 0, e = MI->getNumOperands(); i != e; ++i) {
      MachineOperand &MO = MI->getOperand(i);
      if (!MO.isReg()) continue;
      unsigned Reg = MO.getReg();
      if (Reg == 0) continue;

      if (FirstReg != 0) {
        DEBUG(dbgs() << "=" << TRI->getName(Reg));
        State->UnionGroups(FirstReg, Reg);
      } else {
        DEBUG(dbgs() << " " << TRI->getName(Reg));
        FirstReg = Reg;
      }
    }

    DEBUG(dbgs() << "->g" << State->GetGroup(FirstReg) << '\n');
  }
}

BitVector AggressiveAntiDepBreaker::GetRenameRegisters(unsigned Reg) {
  BitVector BV(TRI->getNumRegs(), false);
  bool first = true;

  // Check all references that need rewriting for Reg. For each, use
  // the corresponding register class to narrow the set of registers
  // that are appropriate for renaming.
  std::pair<std::multimap<unsigned,
                     AggressiveAntiDepState::RegisterReference>::iterator,
            std::multimap<unsigned,
                     AggressiveAntiDepState::RegisterReference>::iterator>
    Range = State->GetRegRefs().equal_range(Reg);
  for (std::multimap<unsigned,
       AggressiveAntiDepState::RegisterReference>::iterator Q = Range.first,
       QE = Range.second; Q != QE; ++Q) {
    const TargetRegisterClass *RC = Q->second.RC;
    if (RC == NULL) continue;

    BitVector RCBV = TRI->getAllocatableSet(MF, RC);
    if (first) {
      BV |= RCBV;
      first = false;
    } else {
      BV &= RCBV;
    }

    DEBUG(dbgs() << " " << RC->getName());
  }

  return BV;
}

bool AggressiveAntiDepBreaker::FindSuitableFreeRegisters(
                                unsigned AntiDepGroupIndex,
                                RenameOrderType& RenameOrder,
                                std::map<unsigned, unsigned> &RenameMap) {
  std::vector<unsigned> &KillIndices = State->GetKillIndices();
  std::vector<unsigned> &DefIndices = State->GetDefIndices();
  std::multimap<unsigned, AggressiveAntiDepState::RegisterReference>&
    RegRefs = State->GetRegRefs();

  // Collect all referenced registers in the same group as
  // AntiDepReg. These all need to be renamed together if we are to
  // break the anti-dependence.
  std::vector<unsigned> Regs;
  State->GetGroupRegs(AntiDepGroupIndex, Regs, &RegRefs);
  assert(Regs.size() > 0 && "Empty register group!");
  if (Regs.size() == 0)
    return false;

  // Find the "superest" register in the group. At the same time,
  // collect the BitVector of registers that can be used to rename
  // each register.
  DEBUG(dbgs() << "\tRename Candidates for Group g" << AntiDepGroupIndex
        << ":\n");
  std::map<unsigned, BitVector> RenameRegisterMap;
  unsigned SuperReg = 0;
  for (unsigned i = 0, e = Regs.size(); i != e; ++i) {
    unsigned Reg = Regs[i];
    if ((SuperReg == 0) || TRI->isSuperRegister(SuperReg, Reg))
      SuperReg = Reg;

    // If Reg has any references, then collect possible rename regs
    if (RegRefs.count(Reg) > 0) {
      DEBUG(dbgs() << "\t\t" << TRI->getName(Reg) << ":");

      BitVector BV = GetRenameRegisters(Reg);
      RenameRegisterMap.insert(std::pair<unsigned, BitVector>(Reg, BV));

      DEBUG(dbgs() << " ::");
      DEBUG(for (int r = BV.find_first(); r != -1; r = BV.find_next(r))
              dbgs() << " " << TRI->getName(r));
      DEBUG(dbgs() << "\n");
    }
  }

  // All group registers should be a subreg of SuperReg.
  for (unsigned i = 0, e = Regs.size(); i != e; ++i) {
    unsigned Reg = Regs[i];
    if (Reg == SuperReg) continue;
    bool IsSub = TRI->isSubRegister(SuperReg, Reg);
    assert(IsSub && "Expecting group subregister");
    if (!IsSub)
      return false;
  }

#ifndef NDEBUG
  // If DebugDiv > 0 then only rename (renamecnt % DebugDiv) == DebugMod
  if (DebugDiv > 0) {
    static int renamecnt = 0;
    if (renamecnt++ % DebugDiv != DebugMod)
      return false;

    dbgs() << "*** Performing rename " << TRI->getName(SuperReg) <<
      " for debug ***\n";
  }
#endif

  // Check each possible rename register for SuperReg in round-robin
  // order. If that register is available, and the corresponding
  // registers are available for the other group subregisters, then we
  // can use those registers to rename.

  // FIXME: Using getMinimalPhysRegClass is very conservative. We should
  // check every use of the register and find the largest register class
  // that can be used in all of them.
  const TargetRegisterClass *SuperRC =
    TRI->getMinimalPhysRegClass(SuperReg, MVT::Other);

  ArrayRef<MCPhysReg> Order = RegClassInfo.getOrder(SuperRC);
  if (Order.empty()) {
    DEBUG(dbgs() << "\tEmpty Super Regclass!!\n");
    return false;
  }

  DEBUG(dbgs() << "\tFind Registers:");

  if (RenameOrder.count(SuperRC) == 0)
    RenameOrder.insert(RenameOrderType::value_type(SuperRC, Order.size()));

  unsigned OrigR = RenameOrder[SuperRC];
  unsigned EndR = ((OrigR == Order.size()) ? 0 : OrigR);
  unsigned R = OrigR;
  do {
    if (R == 0) R = Order.size();
    --R;
    const unsigned NewSuperReg = Order[R];
    // Don't consider non-allocatable registers
    if (!MRI.isAllocatable(NewSuperReg)) continue;
    // Don't replace a register with itself.
    if (NewSuperReg == SuperReg) continue;

    DEBUG(dbgs() << " [" << TRI->getName(NewSuperReg) << ':');
    RenameMap.clear();

    // For each referenced group register (which must be a SuperReg or
    // a subregister of SuperReg), find the corresponding subregister
    // of NewSuperReg and make sure it is free to be renamed.
    for (unsigned i = 0, e = Regs.size(); i != e; ++i) {
      unsigned Reg = Regs[i];
      unsigned NewReg = 0;
      if (Reg == SuperReg) {
        NewReg = NewSuperReg;
      } else {
        unsigned NewSubRegIdx = TRI->getSubRegIndex(SuperReg, Reg);
        if (NewSubRegIdx != 0)
          NewReg = TRI->getSubReg(NewSuperReg, NewSubRegIdx);
      }

      DEBUG(dbgs() << " " << TRI->getName(NewReg));

      // Check if Reg can be renamed to NewReg.
      BitVector BV = RenameRegisterMap[Reg];
      if (!BV.test(NewReg)) {
        DEBUG(dbgs() << "(no rename)");
        goto next_super_reg;
      }

      // If NewReg is dead and NewReg's most recent def is not before
      // Regs's kill, it's safe to replace Reg with NewReg. We
      // must also check all aliases of NewReg, because we can't define a
      // register when any sub or super is already live.
      if (State->IsLive(NewReg) || (KillIndices[Reg] > DefIndices[NewReg])) {
        DEBUG(dbgs() << "(live)");
        goto next_super_reg;
      } else {
        bool found = false;
        for (MCRegAliasIterator AI(NewReg, TRI, false); AI.isValid(); ++AI) {
          unsigned AliasReg = *AI;
          if (State->IsLive(AliasReg) ||
              (KillIndices[Reg] > DefIndices[AliasReg])) {
            DEBUG(dbgs() << "(alias " << TRI->getName(AliasReg) << " live)");
            found = true;
            break;
          }
        }
        if (found)
          goto next_super_reg;
      }

      // Record that 'Reg' can be renamed to 'NewReg'.
      RenameMap.insert(std::pair<unsigned, unsigned>(Reg, NewReg));
    }

    // If we fall-out here, then every register in the group can be
    // renamed, as recorded in RenameMap.
    RenameOrder.erase(SuperRC);
    RenameOrder.insert(RenameOrderType::value_type(SuperRC, R));
    DEBUG(dbgs() << "]\n");
    return true;

  next_super_reg:
    DEBUG(dbgs() << ']');
  } while (R != EndR);

  DEBUG(dbgs() << '\n');

  // No registers are free and available!
  return false;
}

/// BreakAntiDependencies - Identifiy anti-dependencies within the
/// ScheduleDAG and break them by renaming registers.
///
unsigned AggressiveAntiDepBreaker::BreakAntiDependencies(
                              const std::vector<SUnit>& SUnits,
                              MachineBasicBlock::iterator Begin,
                              MachineBasicBlock::iterator End,
                              unsigned InsertPosIndex,
                              DbgValueVector &DbgValues) {

  std::vector<unsigned> &KillIndices = State->GetKillIndices();
  std::vector<unsigned> &DefIndices = State->GetDefIndices();
  std::multimap<unsigned, AggressiveAntiDepState::RegisterReference>&
    RegRefs = State->GetRegRefs();

  // The code below assumes that there is at least one instruction,
  // so just duck out immediately if the block is empty.
  if (SUnits.empty()) return 0;

  // For each regclass the next register to use for renaming.
  RenameOrderType RenameOrder;

  // ...need a map from MI to SUnit.
  std::map<MachineInstr *, const SUnit *> MISUnitMap;
  for (unsigned i = 0, e = SUnits.size(); i != e; ++i) {
    const SUnit *SU = &SUnits[i];
    MISUnitMap.insert(std::pair<MachineInstr *, const SUnit *>(SU->getInstr(),
                                                               SU));
  }

  // Track progress along the critical path through the SUnit graph as
  // we walk the instructions. This is needed for regclasses that only
  // break critical-path anti-dependencies.
  const SUnit *CriticalPathSU = 0;
  MachineInstr *CriticalPathMI = 0;
  if (CriticalPathSet.any()) {
    for (unsigned i = 0, e = SUnits.size(); i != e; ++i) {
      const SUnit *SU = &SUnits[i];
      if (!CriticalPathSU ||
          ((SU->getDepth() + SU->Latency) >
           (CriticalPathSU->getDepth() + CriticalPathSU->Latency))) {
        CriticalPathSU = SU;
      }
    }

    CriticalPathMI = CriticalPathSU->getInstr();
  }

#ifndef NDEBUG
  DEBUG(dbgs() << "\n===== Aggressive anti-dependency breaking\n");
  DEBUG(dbgs() << "Available regs:");
  for (unsigned Reg = 0; Reg < TRI->getNumRegs(); ++Reg) {
    if (!State->IsLive(Reg))
      DEBUG(dbgs() << " " << TRI->getName(Reg));
  }
  DEBUG(dbgs() << '\n');
#endif

  // Attempt to break anti-dependence edges. Walk the instructions
  // from the bottom up, tracking information about liveness as we go
  // to help determine which registers are available.
  unsigned Broken = 0;
  unsigned Count = InsertPosIndex - 1;
  for (MachineBasicBlock::iterator I = End, E = Begin;
       I != E; --Count) {
    MachineInstr *MI = --I;

    if (MI->isDebugValue())
      continue;

    DEBUG(dbgs() << "Anti: ");
    DEBUG(MI->dump());

    std::set<unsigned> PassthruRegs;
    GetPassthruRegs(MI, PassthruRegs);

    // Process the defs in MI...
    PrescanInstruction(MI, Count, PassthruRegs);

    // The dependence edges that represent anti- and output-
    // dependencies that are candidates for breaking.
    std::vector<const SDep *> Edges;
    const SUnit *PathSU = MISUnitMap[MI];
    AntiDepEdges(PathSU, Edges);

    // If MI is not on the critical path, then we don't rename
    // registers in the CriticalPathSet.
    BitVector *ExcludeRegs = NULL;
    if (MI == CriticalPathMI) {
      CriticalPathSU = CriticalPathStep(CriticalPathSU);
      CriticalPathMI = (CriticalPathSU) ? CriticalPathSU->getInstr() : 0;
    } else {
      ExcludeRegs = &CriticalPathSet;
    }

    // Ignore KILL instructions (they form a group in ScanInstruction
    // but don't cause any anti-dependence breaking themselves)
    if (!MI->isKill()) {
      // Attempt to break each anti-dependency...
      for (unsigned i = 0, e = Edges.size(); i != e; ++i) {
        const SDep *Edge = Edges[i];
        SUnit *NextSU = Edge->getSUnit();

        if ((Edge->getKind() != SDep::Anti) &&
            (Edge->getKind() != SDep::Output)) continue;

        unsigned AntiDepReg = Edge->getReg();
        DEBUG(dbgs() << "\tAntidep reg: " << TRI->getName(AntiDepReg));
        assert(AntiDepReg != 0 && "Anti-dependence on reg0?");

        if (!MRI.isAllocatable(AntiDepReg)) {
          // Don't break anti-dependencies on non-allocatable registers.
          DEBUG(dbgs() << " (non-allocatable)\n");
          continue;
        } else if ((ExcludeRegs != NULL) && ExcludeRegs->test(AntiDepReg)) {
          // Don't break anti-dependencies for critical path registers
          // if not on the critical path
          DEBUG(dbgs() << " (not critical-path)\n");
          continue;
        } else if (PassthruRegs.count(AntiDepReg) != 0) {
          // If the anti-dep register liveness "passes-thru", then
          // don't try to change it. It will be changed along with
          // the use if required to break an earlier antidep.
          DEBUG(dbgs() << " (passthru)\n");
          continue;
        } else {
          // No anti-dep breaking for implicit deps
          MachineOperand *AntiDepOp = MI->findRegisterDefOperand(AntiDepReg);
          assert(AntiDepOp != NULL &&
                 "Can't find index for defined register operand");
          if ((AntiDepOp == NULL) || AntiDepOp->isImplicit()) {
            DEBUG(dbgs() << " (implicit)\n");
            continue;
          }

          // If the SUnit has other dependencies on the SUnit that
          // it anti-depends on, don't bother breaking the
          // anti-dependency since those edges would prevent such
          // units from being scheduled past each other
          // regardless.
          //
          // Also, if there are dependencies on other SUnits with the
          // same register as the anti-dependency, don't attempt to
          // break it.
          for (SUnit::const_pred_iterator P = PathSU->Preds.begin(),
                 PE = PathSU->Preds.end(); P != PE; ++P) {
            if (P->getSUnit() == NextSU ?
                (P->getKind() != SDep::Anti || P->getReg() != AntiDepReg) :
                (P->getKind() == SDep::Data && P->getReg() == AntiDepReg)) {
              AntiDepReg = 0;
              break;
            }
          }
          for (SUnit::const_pred_iterator P = PathSU->Preds.begin(),
                 PE = PathSU->Preds.end(); P != PE; ++P) {
            if ((P->getSUnit() == NextSU) && (P->getKind() != SDep::Anti) &&
                (P->getKind() != SDep::Output)) {
              DEBUG(dbgs() << " (real dependency)\n");
              AntiDepReg = 0;
              break;
            } else if ((P->getSUnit() != NextSU) &&
                       (P->getKind() == SDep::Data) &&
                       (P->getReg() == AntiDepReg)) {
              DEBUG(dbgs() << " (other dependency)\n");
              AntiDepReg = 0;
              break;
            }
          }

          if (AntiDepReg == 0) continue;
        }

        assert(AntiDepReg != 0);
        if (AntiDepReg == 0) continue;

        // Determine AntiDepReg's register group.
        const unsigned GroupIndex = State->GetGroup(AntiDepReg);
        if (GroupIndex == 0) {
          DEBUG(dbgs() << " (zero group)\n");
          continue;
        }

        DEBUG(dbgs() << '\n');

        // Look for a suitable register to use to break the anti-dependence.
        std::map<unsigned, unsigned> RenameMap;
        if (FindSuitableFreeRegisters(GroupIndex, RenameOrder, RenameMap)) {
          DEBUG(dbgs() << "\tBreaking anti-dependence edge on "
                << TRI->getName(AntiDepReg) << ":");

          // Handle each group register...
          for (std::map<unsigned, unsigned>::iterator
                 S = RenameMap.begin(), E = RenameMap.end(); S != E; ++S) {
            unsigned CurrReg = S->first;
            unsigned NewReg = S->second;

            DEBUG(dbgs() << " " << TRI->getName(CurrReg) << "->" <<
                  TRI->getName(NewReg) << "(" <<
                  RegRefs.count(CurrReg) << " refs)");

            // Update the references to the old register CurrReg to
            // refer to the new register NewReg.
            std::pair<std::multimap<unsigned,
                           AggressiveAntiDepState::RegisterReference>::iterator,
                      std::multimap<unsigned,
                           AggressiveAntiDepState::RegisterReference>::iterator>
              Range = RegRefs.equal_range(CurrReg);
            for (std::multimap<unsigned,
                 AggressiveAntiDepState::RegisterReference>::iterator
                   Q = Range.first, QE = Range.second; Q != QE; ++Q) {
              Q->second.Operand->setReg(NewReg);
              // If the SU for the instruction being updated has debug
              // information related to the anti-dependency register, make
              // sure to update that as well.
              const SUnit *SU = MISUnitMap[Q->second.Operand->getParent()];
              if (!SU) continue;
              for (DbgValueVector::iterator DVI = DbgValues.begin(),
                     DVE = DbgValues.end(); DVI != DVE; ++DVI)
                if (DVI->second == Q->second.Operand->getParent())
                  UpdateDbgValue(DVI->first, AntiDepReg, NewReg);
            }

            // We just went back in time and modified history; the
            // liveness information for CurrReg is now inconsistent. Set
            // the state as if it were dead.
            State->UnionGroups(NewReg, 0);
            RegRefs.erase(NewReg);
            DefIndices[NewReg] = DefIndices[CurrReg];
            KillIndices[NewReg] = KillIndices[CurrReg];

            State->UnionGroups(CurrReg, 0);
            RegRefs.erase(CurrReg);
            DefIndices[CurrReg] = KillIndices[CurrReg];
            KillIndices[CurrReg] = ~0u;
            assert(((KillIndices[CurrReg] == ~0u) !=
                    (DefIndices[CurrReg] == ~0u)) &&
                   "Kill and Def maps aren't consistent for AntiDepReg!");
          }

          ++Broken;
          DEBUG(dbgs() << '\n');
        }
      }
    }

    ScanInstruction(MI, Count);
  }

  return Broken;
}
