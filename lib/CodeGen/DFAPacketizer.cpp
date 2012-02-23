//=- llvm/CodeGen/DFAPacketizer.cpp - DFA Packetizer for VLIW -*- C++ -*-=====//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
// This class implements a deterministic finite automaton (DFA) based
// packetizing mechanism for VLIW architectures. It provides APIs to
// determine whether there exists a legal mapping of instructions to
// functional unit assignments in a packet. The DFA is auto-generated from
// the target's Schedule.td file.
//
// A DFA consists of 3 major elements: states, inputs, and transitions. For
// the packetizing mechanism, the input is the set of instruction classes for
// a target. The state models all possible combinations of functional unit
// consumption for a given set of instructions in a packet. A transition
// models the addition of an instruction to a packet. In the DFA constructed
// by this class, if an instruction can be added to a packet, then a valid
// transition exists from the corresponding state. Invalid transitions
// indicate that the instruction cannot be added to the current packet.
//
//===----------------------------------------------------------------------===//

#include "ScheduleDAGInstrs.h"
#include "llvm/CodeGen/DFAPacketizer.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/CodeGen/MachineInstrBundle.h"
#include "llvm/Target/TargetInstrInfo.h"
#include "llvm/MC/MCInstrItineraries.h"
using namespace llvm;

DFAPacketizer::DFAPacketizer(const InstrItineraryData *I, const int (*SIT)[2],
                             const unsigned *SET):
  InstrItins(I), CurrentState(0), DFAStateInputTable(SIT),
  DFAStateEntryTable(SET) {}


//
// ReadTable - Read the DFA transition table and update CachedTable.
//
// Format of the transition tables:
// DFAStateInputTable[][2] = pairs of <Input, Transition> for all valid
//                           transitions
// DFAStateEntryTable[i] = Index of the first entry in DFAStateInputTable
//                         for the ith state
//
void DFAPacketizer::ReadTable(unsigned int state) {
  unsigned ThisState = DFAStateEntryTable[state];
  unsigned NextStateInTable = DFAStateEntryTable[state+1];
  // Early exit in case CachedTable has already contains this
  // state's transitions.
  if (CachedTable.count(UnsignPair(state,
                                   DFAStateInputTable[ThisState][0])))
    return;

  for (unsigned i = ThisState; i < NextStateInTable; i++)
    CachedTable[UnsignPair(state, DFAStateInputTable[i][0])] =
      DFAStateInputTable[i][1];
}


// canReserveResources - Check if the resources occupied by a MCInstrDesc
// are available in the current state.
bool DFAPacketizer::canReserveResources(const llvm::MCInstrDesc *MID) {
  unsigned InsnClass = MID->getSchedClass();
  const llvm::InstrStage *IS = InstrItins->beginStage(InsnClass);
  unsigned FuncUnits = IS->getUnits();
  UnsignPair StateTrans = UnsignPair(CurrentState, FuncUnits);
  ReadTable(CurrentState);
  return (CachedTable.count(StateTrans) != 0);
}


// reserveResources - Reserve the resources occupied by a MCInstrDesc and
// change the current state to reflect that change.
void DFAPacketizer::reserveResources(const llvm::MCInstrDesc *MID) {
  unsigned InsnClass = MID->getSchedClass();
  const llvm::InstrStage *IS = InstrItins->beginStage(InsnClass);
  unsigned FuncUnits = IS->getUnits();
  UnsignPair StateTrans = UnsignPair(CurrentState, FuncUnits);
  ReadTable(CurrentState);
  assert(CachedTable.count(StateTrans) != 0);
  CurrentState = CachedTable[StateTrans];
}


// canReserveResources - Check if the resources occupied by a machine
// instruction are available in the current state.
bool DFAPacketizer::canReserveResources(llvm::MachineInstr *MI) {
  const llvm::MCInstrDesc &MID = MI->getDesc();
  return canReserveResources(&MID);
}

// reserveResources - Reserve the resources occupied by a machine
// instruction and change the current state to reflect that change.
void DFAPacketizer::reserveResources(llvm::MachineInstr *MI) {
  const llvm::MCInstrDesc &MID = MI->getDesc();
  reserveResources(&MID);
}

namespace {
// DefaultVLIWScheduler - This class extends ScheduleDAGInstrs and overrides
// Schedule method to build the dependence graph.
//
// ScheduleDAGInstrs has LLVM_LIBRARY_VISIBILITY so we have to reference it as
// an opaque pointer in VLIWPacketizerList.
class DefaultVLIWScheduler : public ScheduleDAGInstrs {
public:
  DefaultVLIWScheduler(MachineFunction &MF, MachineLoopInfo &MLI,
                       MachineDominatorTree &MDT, bool IsPostRA);
  // Schedule - Actual scheduling work.
  void Schedule();
};
} // end anonymous namespace

DefaultVLIWScheduler::DefaultVLIWScheduler(
  MachineFunction &MF, MachineLoopInfo &MLI, MachineDominatorTree &MDT,
  bool IsPostRA) :
  ScheduleDAGInstrs(MF, MLI, MDT, IsPostRA) {
}

void DefaultVLIWScheduler::Schedule() {
  // Build the scheduling graph.
  BuildSchedGraph(0);
}

// VLIWPacketizerList Ctor
VLIWPacketizerList::VLIWPacketizerList(
  MachineFunction &MF, MachineLoopInfo &MLI, MachineDominatorTree &MDT,
  bool IsPostRA) : TM(MF.getTarget()), MF(MF)  {
  TII = TM.getInstrInfo();
  ResourceTracker = TII->CreateTargetScheduleState(&TM, 0);
  SchedulerImpl = new DefaultVLIWScheduler(MF, MLI, MDT, IsPostRA);
}

// VLIWPacketizerList Dtor
VLIWPacketizerList::~VLIWPacketizerList() {
  delete (DefaultVLIWScheduler *)SchedulerImpl;
  delete ResourceTracker;
}

// ignorePseudoInstruction - ignore pseudo instructions.
bool VLIWPacketizerList::ignorePseudoInstruction(MachineInstr *MI,
                                                 MachineBasicBlock *MBB) {
  if (MI->isDebugValue())
    return true;

  if (TII->isSchedulingBoundary(MI, MBB, MF))
    return true;

  return false;
}

// isSoloInstruction - return true if instruction I must end previous
// packet.
bool VLIWPacketizerList::isSoloInstruction(MachineInstr *I) {
  if (I->isInlineAsm())
    return true;

  return false;
}

// addToPacket - Add I to the current packet and reserve resource.
void VLIWPacketizerList::addToPacket(MachineInstr *MI) {
  CurrentPacketMIs.push_back(MI);
  ResourceTracker->reserveResources(MI);
}

// endPacket - End the current packet, bundle packet instructions and reset
// DFA state.
void VLIWPacketizerList::endPacket(MachineBasicBlock *MBB,
                                         MachineInstr *I) {
  if (CurrentPacketMIs.size() > 1) {
    MachineInstr *MIFirst = CurrentPacketMIs.front();
    finalizeBundle(*MBB, MIFirst, I);
  }
  CurrentPacketMIs.clear();
  ResourceTracker->clearResources();
}

// PacketizeMIs - Bundle machine instructions into packets.
void VLIWPacketizerList::PacketizeMIs(MachineBasicBlock *MBB,
                                      MachineBasicBlock::iterator BeginItr,
                                      MachineBasicBlock::iterator EndItr) {
  DefaultVLIWScheduler *Scheduler = (DefaultVLIWScheduler *)SchedulerImpl;
  Scheduler->Run(MBB, BeginItr, EndItr, MBB->size());

  // Remember scheduling units.
  SUnits = Scheduler->SUnits;

  // Generate MI -> SU map.
  std::map <MachineInstr*, SUnit*> MIToSUnit;
  for (unsigned i = 0, e = SUnits.size(); i != e; ++i) {
    SUnit *SU = &SUnits[i];
    MIToSUnit[SU->getInstr()] = SU;
  }

  // The main packetizer loop.
  for (; BeginItr != EndItr; ++BeginItr) {
    MachineInstr *MI = BeginItr;

    // Ignore pseudo instructions.
    if (ignorePseudoInstruction(MI, MBB))
      continue;

    // End the current packet if needed.
    if (isSoloInstruction(MI)) {
      endPacket(MBB, MI);
      continue;
    }

    SUnit *SUI = MIToSUnit[MI];
    assert(SUI && "Missing SUnit Info!");

    // Ask DFA if machine resource is available for MI.
    bool ResourceAvail = ResourceTracker->canReserveResources(MI);
    if (ResourceAvail) {
      // Dependency check for MI with instructions in CurrentPacketMIs.
      for (std::vector<MachineInstr*>::iterator VI = CurrentPacketMIs.begin(),
           VE = CurrentPacketMIs.end(); VI != VE; ++VI) {
        MachineInstr *MJ = *VI;
        SUnit *SUJ = MIToSUnit[MJ];
        assert(SUJ && "Missing SUnit Info!");

        // Is it legal to packetize SUI and SUJ together.
        if (!isLegalToPacketizeTogether(SUI, SUJ)) {
          // Allow packetization if dependency can be pruned.
          if (!isLegalToPruneDependencies(SUI, SUJ)) {
            // End the packet if dependency cannot be pruned.
            endPacket(MBB, MI);
            break;
          } // !isLegalToPruneDependencies.
        } // !isLegalToPacketizeTogether.
      } // For all instructions in CurrentPacketMIs.
    } else {
      // End the packet if resource is not available.
      endPacket(MBB, MI);
    }

    // Add MI to the current packet.
    addToPacket(MI);
  } // For all instructions in BB.

  // End any packet left behind.
  endPacket(MBB, EndItr);
}
