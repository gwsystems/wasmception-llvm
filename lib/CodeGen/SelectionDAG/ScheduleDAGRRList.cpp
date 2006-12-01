//===----- ScheduleDAGList.cpp - Reg pressure reduction list scheduler ----===//
//
//                     The LLVM Compiler Infrastructure
//
// This file was developed by Evan Cheng and is distributed under the
// University of Illinois Open Source License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This implements bottom-up and top-down register pressure reduction list
// schedulers, using standard algorithms.  The basic approach uses a priority
// queue of available nodes to schedule.  One at a time, nodes are taken from
// the priority queue (thus in priority order), checked for legality to
// schedule, and emitted if legal.
//
//===----------------------------------------------------------------------===//

#define DEBUG_TYPE "sched"
#include "llvm/CodeGen/ScheduleDAG.h"
#include "llvm/CodeGen/SchedulerRegistry.h"
#include "llvm/CodeGen/SSARegMap.h"
#include "llvm/Target/MRegisterInfo.h"
#include "llvm/Target/TargetData.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/Target/TargetInstrInfo.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/Compiler.h"
#include "llvm/ADT/Statistic.h"
#include <climits>
#include <iostream>
#include <queue>
#include "llvm/Support/CommandLine.h"
using namespace llvm;

static RegisterScheduler
  burrListDAGScheduler("list-burr",
                       "  Bottom-up register reduction list scheduling",
                       createBURRListDAGScheduler);
static RegisterScheduler
  tdrListrDAGScheduler("list-tdrr",
                       "  Top-down register reduction list scheduling",
                       createTDRRListDAGScheduler);

namespace {
//===----------------------------------------------------------------------===//
/// ScheduleDAGRRList - The actual register reduction list scheduler
/// implementation.  This supports both top-down and bottom-up scheduling.
///

class VISIBILITY_HIDDEN ScheduleDAGRRList : public ScheduleDAG {
private:
  /// isBottomUp - This is true if the scheduling problem is bottom-up, false if
  /// it is top-down.
  bool isBottomUp;
  
  /// AvailableQueue - The priority queue to use for the available SUnits.
  ///
  SchedulingPriorityQueue *AvailableQueue;

public:
  ScheduleDAGRRList(SelectionDAG &dag, MachineBasicBlock *bb,
                  const TargetMachine &tm, bool isbottomup,
                  SchedulingPriorityQueue *availqueue)
    : ScheduleDAG(dag, bb, tm), isBottomUp(isbottomup),
      AvailableQueue(availqueue) {
    }

  ~ScheduleDAGRRList() {
    delete AvailableQueue;
  }

  void Schedule();

private:
  void ReleasePred(SUnit *PredSU, bool isChain, unsigned CurCycle);
  void ReleaseSucc(SUnit *SuccSU, bool isChain, unsigned CurCycle);
  void ScheduleNodeBottomUp(SUnit *SU, unsigned CurCycle);
  void ScheduleNodeTopDown(SUnit *SU, unsigned CurCycle);
  void ListScheduleTopDown();
  void ListScheduleBottomUp();
  void CommuteNodesToReducePressure();
};
}  // end anonymous namespace


/// Schedule - Schedule the DAG using list scheduling.
void ScheduleDAGRRList::Schedule() {
  DEBUG(std::cerr << "********** List Scheduling **********\n");
  
  // Build scheduling units.
  BuildSchedUnits();

  DEBUG(for (unsigned su = 0, e = SUnits.size(); su != e; ++su)
          SUnits[su].dumpAll(&DAG));
  CalculateDepths();
  CalculateHeights();

  AvailableQueue->initNodes(SUnitMap, SUnits);

  // Execute the actual scheduling loop Top-Down or Bottom-Up as appropriate.
  if (isBottomUp)
    ListScheduleBottomUp();
  else
    ListScheduleTopDown();
  
  AvailableQueue->releaseState();

  CommuteNodesToReducePressure();
  
  DEBUG(std::cerr << "*** Final schedule ***\n");
  DEBUG(dumpSchedule());
  DEBUG(std::cerr << "\n");
  
  // Emit in scheduled order
  EmitSchedule();
}

/// CommuteNodesToReducePressure - If a node is two-address and commutable, and
/// it is not the last use of its first operand, add it to the CommuteSet if
/// possible. It will be commuted when it is translated to a MI.
void ScheduleDAGRRList::CommuteNodesToReducePressure() {
  std::set<SUnit *> OperandSeen;
  for (unsigned i = Sequence.size()-1; i != 0; --i) {  // Ignore first node.
    SUnit *SU = Sequence[i];
    if (!SU) continue;
    if (SU->isCommutable) {
      unsigned Opc = SU->Node->getTargetOpcode();
      unsigned NumRes = CountResults(SU->Node);
      unsigned NumOps = CountOperands(SU->Node);
      for (unsigned j = 0; j != NumOps; ++j) {
        if (TII->getOperandConstraint(Opc, j+NumRes, TOI::TIED_TO) == -1)
          continue;

        SDNode *OpN = SU->Node->getOperand(j).Val;
        SUnit *OpSU = SUnitMap[OpN];
        if (OpSU && OperandSeen.count(OpSU) == 1) {
          // Ok, so SU is not the last use of OpSU, but SU is two-address so
          // it will clobber OpSU. Try to commute SU if no other source operands
          // are live below.
          bool DoCommute = true;
          for (unsigned k = 0; k < NumOps; ++k) {
            if (k != j) {
              OpN = SU->Node->getOperand(k).Val;
              OpSU = SUnitMap[OpN];
              if (OpSU && OperandSeen.count(OpSU) == 1) {
                DoCommute = false;
                break;
              }
            }
          }
          if (DoCommute)
            CommuteSet.insert(SU->Node);
        }

        // Only look at the first use&def node for now.
        break;
      }
    }

    for (SUnit::pred_iterator I = SU->Preds.begin(), E = SU->Preds.end();
         I != E; ++I) {
      if (!I->second)
        OperandSeen.insert(I->first);
    }
  }
}

//===----------------------------------------------------------------------===//
//  Bottom-Up Scheduling
//===----------------------------------------------------------------------===//

/// ReleasePred - Decrement the NumSuccsLeft count of a predecessor. Add it to
/// the Available queue is the count reaches zero. Also update its cycle bound.
void ScheduleDAGRRList::ReleasePred(SUnit *PredSU, bool isChain, 
                                    unsigned CurCycle) {
  // FIXME: the distance between two nodes is not always == the predecessor's
  // latency. For example, the reader can very well read the register written
  // by the predecessor later than the issue cycle. It also depends on the
  // interrupt model (drain vs. freeze).
  PredSU->CycleBound = std::max(PredSU->CycleBound, CurCycle + PredSU->Latency);

  if (!isChain)
    PredSU->NumSuccsLeft--;
  else
    PredSU->NumChainSuccsLeft--;
  
#ifndef NDEBUG
  if (PredSU->NumSuccsLeft < 0 || PredSU->NumChainSuccsLeft < 0) {
    std::cerr << "*** List scheduling failed! ***\n";
    PredSU->dump(&DAG);
    std::cerr << " has been released too many times!\n";
    assert(0);
  }
#endif
  
  if ((PredSU->NumSuccsLeft + PredSU->NumChainSuccsLeft) == 0) {
    // EntryToken has to go last!  Special case it here.
    if (PredSU->Node->getOpcode() != ISD::EntryToken) {
      PredSU->isAvailable = true;
      AvailableQueue->push(PredSU);
    }
  }
}

/// ScheduleNodeBottomUp - Add the node to the schedule. Decrement the pending
/// count of its predecessors. If a predecessor pending count is zero, add it to
/// the Available queue.
void ScheduleDAGRRList::ScheduleNodeBottomUp(SUnit *SU, unsigned CurCycle) {
  DEBUG(std::cerr << "*** Scheduling [" << CurCycle << "]: ");
  DEBUG(SU->dump(&DAG));
  SU->Cycle = CurCycle;

  AvailableQueue->ScheduledNode(SU);
  Sequence.push_back(SU);

  // Bottom up: release predecessors
  for (SUnit::pred_iterator I = SU->Preds.begin(), E = SU->Preds.end();
       I != E; ++I)
    ReleasePred(I->first, I->second, CurCycle);
  SU->isScheduled = true;
}

/// isReady - True if node's lower cycle bound is less or equal to the current
/// scheduling cycle. Always true if all nodes have uniform latency 1.
static inline bool isReady(SUnit *SU, unsigned CurCycle) {
  return SU->CycleBound <= CurCycle;
}

/// ListScheduleBottomUp - The main loop of list scheduling for bottom-up
/// schedulers.
void ScheduleDAGRRList::ListScheduleBottomUp() {
  unsigned CurCycle = 0;
  // Add root to Available queue.
  AvailableQueue->push(SUnitMap[DAG.getRoot().Val]);

  // While Available queue is not empty, grab the node with the highest
  // priority. If it is not ready put it back. Schedule the node.
  std::vector<SUnit*> NotReady;
  while (!AvailableQueue->empty()) {
    SUnit *CurNode = AvailableQueue->pop();
    while (CurNode && !isReady(CurNode, CurCycle)) {
      NotReady.push_back(CurNode);
      CurNode = AvailableQueue->pop();
    }
    
    // Add the nodes that aren't ready back onto the available list.
    AvailableQueue->push_all(NotReady);
    NotReady.clear();

    if (CurNode != NULL)
      ScheduleNodeBottomUp(CurNode, CurCycle);
    CurCycle++;
  }

  // Add entry node last
  if (DAG.getEntryNode().Val != DAG.getRoot().Val) {
    SUnit *Entry = SUnitMap[DAG.getEntryNode().Val];
    Sequence.push_back(Entry);
  }

  // Reverse the order if it is bottom up.
  std::reverse(Sequence.begin(), Sequence.end());
  
  
#ifndef NDEBUG
  // Verify that all SUnits were scheduled.
  bool AnyNotSched = false;
  for (unsigned i = 0, e = SUnits.size(); i != e; ++i) {
    if (SUnits[i].NumSuccsLeft != 0 || SUnits[i].NumChainSuccsLeft != 0) {
      if (!AnyNotSched)
        std::cerr << "*** List scheduling failed! ***\n";
      SUnits[i].dump(&DAG);
      std::cerr << "has not been scheduled!\n";
      AnyNotSched = true;
    }
  }
  assert(!AnyNotSched);
#endif
}

//===----------------------------------------------------------------------===//
//  Top-Down Scheduling
//===----------------------------------------------------------------------===//

/// ReleaseSucc - Decrement the NumPredsLeft count of a successor. Add it to
/// the PendingQueue if the count reaches zero.
void ScheduleDAGRRList::ReleaseSucc(SUnit *SuccSU, bool isChain, 
                                    unsigned CurCycle) {
  // FIXME: the distance between two nodes is not always == the predecessor's
  // latency. For example, the reader can very well read the register written
  // by the predecessor later than the issue cycle. It also depends on the
  // interrupt model (drain vs. freeze).
  SuccSU->CycleBound = std::max(SuccSU->CycleBound, CurCycle + SuccSU->Latency);

  if (!isChain)
    SuccSU->NumPredsLeft--;
  else
    SuccSU->NumChainPredsLeft--;
  
#ifndef NDEBUG
  if (SuccSU->NumPredsLeft < 0 || SuccSU->NumChainPredsLeft < 0) {
    std::cerr << "*** List scheduling failed! ***\n";
    SuccSU->dump(&DAG);
    std::cerr << " has been released too many times!\n";
    assert(0);
  }
#endif
  
  if ((SuccSU->NumPredsLeft + SuccSU->NumChainPredsLeft) == 0) {
    SuccSU->isAvailable = true;
    AvailableQueue->push(SuccSU);
  }
}


/// ScheduleNodeTopDown - Add the node to the schedule. Decrement the pending
/// count of its successors. If a successor pending count is zero, add it to
/// the Available queue.
void ScheduleDAGRRList::ScheduleNodeTopDown(SUnit *SU, unsigned CurCycle) {
  DEBUG(std::cerr << "*** Scheduling [" << CurCycle << "]: ");
  DEBUG(SU->dump(&DAG));
  SU->Cycle = CurCycle;

  AvailableQueue->ScheduledNode(SU);
  Sequence.push_back(SU);

  // Top down: release successors
  for (SUnit::succ_iterator I = SU->Succs.begin(), E = SU->Succs.end();
       I != E; ++I)
    ReleaseSucc(I->first, I->second, CurCycle);
  SU->isScheduled = true;
}

void ScheduleDAGRRList::ListScheduleTopDown() {
  unsigned CurCycle = 0;
  SUnit *Entry = SUnitMap[DAG.getEntryNode().Val];

  // All leaves to Available queue.
  for (unsigned i = 0, e = SUnits.size(); i != e; ++i) {
    // It is available if it has no predecessors.
    if (SUnits[i].Preds.size() == 0 && &SUnits[i] != Entry) {
      AvailableQueue->push(&SUnits[i]);
      SUnits[i].isAvailable = true;
    }
  }
  
  // Emit the entry node first.
  ScheduleNodeTopDown(Entry, CurCycle);
  CurCycle++;

  // While Available queue is not empty, grab the node with the highest
  // priority. If it is not ready put it back. Schedule the node.
  std::vector<SUnit*> NotReady;
  while (!AvailableQueue->empty()) {
    SUnit *CurNode = AvailableQueue->pop();
    while (CurNode && !isReady(CurNode, CurCycle)) {
      NotReady.push_back(CurNode);
      CurNode = AvailableQueue->pop();
    }
    
    // Add the nodes that aren't ready back onto the available list.
    AvailableQueue->push_all(NotReady);
    NotReady.clear();

    if (CurNode != NULL)
      ScheduleNodeTopDown(CurNode, CurCycle);
    CurCycle++;
  }
  
  
#ifndef NDEBUG
  // Verify that all SUnits were scheduled.
  bool AnyNotSched = false;
  for (unsigned i = 0, e = SUnits.size(); i != e; ++i) {
    if (!SUnits[i].isScheduled) {
      if (!AnyNotSched)
        std::cerr << "*** List scheduling failed! ***\n";
      SUnits[i].dump(&DAG);
      std::cerr << "has not been scheduled!\n";
      AnyNotSched = true;
    }
  }
  assert(!AnyNotSched);
#endif
}



//===----------------------------------------------------------------------===//
//                RegReductionPriorityQueue Implementation
//===----------------------------------------------------------------------===//
//
// This is a SchedulingPriorityQueue that schedules using Sethi Ullman numbers
// to reduce register pressure.
// 
namespace {
  template<class SF>
  class RegReductionPriorityQueue;
  
  /// Sorting functions for the Available queue.
  struct bu_ls_rr_sort : public std::binary_function<SUnit*, SUnit*, bool> {
    RegReductionPriorityQueue<bu_ls_rr_sort> *SPQ;
    bu_ls_rr_sort(RegReductionPriorityQueue<bu_ls_rr_sort> *spq) : SPQ(spq) {}
    bu_ls_rr_sort(const bu_ls_rr_sort &RHS) : SPQ(RHS.SPQ) {}
    
    bool operator()(const SUnit* left, const SUnit* right) const;
  };

  struct td_ls_rr_sort : public std::binary_function<SUnit*, SUnit*, bool> {
    RegReductionPriorityQueue<td_ls_rr_sort> *SPQ;
    td_ls_rr_sort(RegReductionPriorityQueue<td_ls_rr_sort> *spq) : SPQ(spq) {}
    td_ls_rr_sort(const td_ls_rr_sort &RHS) : SPQ(RHS.SPQ) {}
    
    bool operator()(const SUnit* left, const SUnit* right) const;
  };
}  // end anonymous namespace

namespace {
  template<class SF>
  class VISIBILITY_HIDDEN RegReductionPriorityQueue
   : public SchedulingPriorityQueue {
    std::priority_queue<SUnit*, std::vector<SUnit*>, SF> Queue;

  public:
    RegReductionPriorityQueue() :
    Queue(SF(this)) {}
    
    virtual void initNodes(std::map<SDNode*, SUnit*> &sumap,
                           std::vector<SUnit> &sunits) {}
    virtual void releaseState() {}
    
    virtual int getSethiUllmanNumber(unsigned NodeNum) const {
      return 0;
    }
    
    bool empty() const { return Queue.empty(); }
    
    void push(SUnit *U) {
      Queue.push(U);
    }
    void push_all(const std::vector<SUnit *> &Nodes) {
      for (unsigned i = 0, e = Nodes.size(); i != e; ++i)
        Queue.push(Nodes[i]);
    }
    
    SUnit *pop() {
      if (empty()) return NULL;
      SUnit *V = Queue.top();
      Queue.pop();
      return V;
    }

    virtual bool isDUOperand(const SUnit *SU1, const SUnit *SU2) {
      return false;
    }
  };

  template<class SF>
  class VISIBILITY_HIDDEN BURegReductionPriorityQueue
   : public RegReductionPriorityQueue<SF> {
    // SUnitMap SDNode to SUnit mapping (n -> 1).
    std::map<SDNode*, SUnit*> *SUnitMap;

    // SUnits - The SUnits for the current graph.
    const std::vector<SUnit> *SUnits;
    
    // SethiUllmanNumbers - The SethiUllman number for each node.
    std::vector<int> SethiUllmanNumbers;

    const TargetInstrInfo *TII;
  public:
    BURegReductionPriorityQueue(const TargetInstrInfo *tii)
      : TII(tii) {}

    void initNodes(std::map<SDNode*, SUnit*> &sumap,
                   std::vector<SUnit> &sunits) {
      SUnitMap = &sumap;
      SUnits = &sunits;
      // Add pseudo dependency edges for two-address nodes.
      AddPseudoTwoAddrDeps();
      // Calculate node priorities.
      CalculatePriorities();
    }

    void releaseState() {
      SUnits = 0;
      SethiUllmanNumbers.clear();
    }

    int getSethiUllmanNumber(unsigned NodeNum) const {
      assert(NodeNum < SethiUllmanNumbers.size());
      return SethiUllmanNumbers[NodeNum];
    }

    bool isDUOperand(const SUnit *SU1, const SUnit *SU2) {
      unsigned Opc = SU1->Node->getTargetOpcode();
      unsigned NumRes = ScheduleDAG::CountResults(SU1->Node);
      unsigned NumOps = ScheduleDAG::CountOperands(SU1->Node);
      for (unsigned i = 0; i != NumOps; ++i) {
        if (TII->getOperandConstraint(Opc, i+NumRes, TOI::TIED_TO) == -1)
          continue;
        if (SU1->Node->getOperand(i).isOperand(SU2->Node))
          return true;
      }
      return false;
    }
  private:
    bool canClobber(SUnit *SU, SUnit *Op);
    void AddPseudoTwoAddrDeps();
    void CalculatePriorities();
    int CalcNodePriority(const SUnit *SU);
  };


  template<class SF>
  class TDRegReductionPriorityQueue : public RegReductionPriorityQueue<SF> {
    // SUnitMap SDNode to SUnit mapping (n -> 1).
    std::map<SDNode*, SUnit*> *SUnitMap;

    // SUnits - The SUnits for the current graph.
    const std::vector<SUnit> *SUnits;
    
    // SethiUllmanNumbers - The SethiUllman number for each node.
    std::vector<int> SethiUllmanNumbers;

  public:
    TDRegReductionPriorityQueue() {}

    void initNodes(std::map<SDNode*, SUnit*> &sumap,
                   std::vector<SUnit> &sunits) {
      SUnitMap = &sumap;
      SUnits = &sunits;
      // Calculate node priorities.
      CalculatePriorities();
    }

    void releaseState() {
      SUnits = 0;
      SethiUllmanNumbers.clear();
    }

    int getSethiUllmanNumber(unsigned NodeNum) const {
      assert(NodeNum < SethiUllmanNumbers.size());
      return SethiUllmanNumbers[NodeNum];
    }

  private:
    void CalculatePriorities();
    int CalcNodePriority(const SUnit *SU);
  };
}

static bool isFloater(const SUnit *SU) {
  if (SU->Node->isTargetOpcode()) {
    if (SU->NumPreds == 0)
      return true;
    if (SU->NumPreds == 1) {
      for (SUnit::const_pred_iterator I = SU->Preds.begin(),E = SU->Preds.end();
           I != E; ++I) {
        if (I->second) continue;

        SUnit *PredSU = I->first;
        unsigned Opc = PredSU->Node->getOpcode();
        if (Opc != ISD::EntryToken && Opc != ISD::TokenFactor &&
            Opc != ISD::CopyToReg)
          return false;
      }
      return true;
    }
  }
  return false;
}

static bool isSimpleFloaterUse(const SUnit *SU) {
  unsigned NumOps = 0;
  for (SUnit::const_pred_iterator I = SU->Preds.begin(), E = SU->Preds.end();
       I != E; ++I) {
    if (I->second) continue;
    if (++NumOps > 1)
      return false;
    if (!isFloater(I->first))
      return false;
  }
  return true;
}

// Bottom up
bool bu_ls_rr_sort::operator()(const SUnit *left, const SUnit *right) const {
  unsigned LeftNum  = left->NodeNum;
  unsigned RightNum = right->NodeNum;
  bool LIsTarget = left->Node->isTargetOpcode();
  bool RIsTarget = right->Node->isTargetOpcode();
  int LPriority = SPQ->getSethiUllmanNumber(LeftNum);
  int RPriority = SPQ->getSethiUllmanNumber(RightNum);
  int LBonus = 0;
  int RBonus = 0;

  // Schedule floaters (e.g. load from some constant address) and those nodes
  // with a single predecessor each first. They maintain / reduce register
  // pressure.
  if (isFloater(left) || isSimpleFloaterUse(left))
    LBonus += 2;
  if (isFloater(right) || isSimpleFloaterUse(right))
    RBonus += 2;

  // Special tie breaker: if two nodes share a operand, the one that use it
  // as a def&use operand is preferred.
  if (LIsTarget && RIsTarget) {
    if (left->isTwoAddress && !right->isTwoAddress) {
      if (SPQ->isDUOperand(left, right))
        LBonus += 2;
    }
    if (!left->isTwoAddress && right->isTwoAddress) {
      if (SPQ->isDUOperand(right, left))
        RBonus += 2;
    }
  }

  if (LPriority+LBonus < RPriority+RBonus)
    return true;
  else if (LPriority+LBonus == RPriority+RBonus)
    if (left->Height > right->Height)
      return true;
    else if (left->Height == right->Height)
      if (left->Depth < right->Depth)
        return true;
      else if (left->Depth == right->Depth)
        if (left->CycleBound > right->CycleBound) 
          return true;
  return false;
}

static inline bool isCopyFromLiveIn(const SUnit *SU) {
  SDNode *N = SU->Node;
  return N->getOpcode() == ISD::CopyFromReg &&
    N->getOperand(N->getNumOperands()-1).getValueType() != MVT::Flag;
}

// FIXME: This is probably too slow!
static void isReachable(SUnit *SU, SUnit *TargetSU,
                        std::set<SUnit *> &Visited, bool &Reached) {
  if (Reached) return;
  if (SU == TargetSU) {
    Reached = true;
    return;
  }
  if (!Visited.insert(SU).second) return;

  for (SUnit::pred_iterator I = SU->Preds.begin(), E = SU->Preds.end(); I != E;
       ++I)
    isReachable(I->first, TargetSU, Visited, Reached);
}

static bool isReachable(SUnit *SU, SUnit *TargetSU) {
  std::set<SUnit *> Visited;
  bool Reached = false;
  isReachable(SU, TargetSU, Visited, Reached);
  return Reached;
}

template<class SF>
bool BURegReductionPriorityQueue<SF>::canClobber(SUnit *SU, SUnit *Op) {
  if (SU->isTwoAddress) {
    unsigned Opc = SU->Node->getTargetOpcode();
    unsigned NumRes = ScheduleDAG::CountResults(SU->Node);
    unsigned NumOps = ScheduleDAG::CountOperands(SU->Node);
    for (unsigned i = 0; i != NumOps; ++i) {
      if (TII->getOperandConstraint(Opc, i+NumRes, TOI::TIED_TO) != -1) {
        SDNode *DU = SU->Node->getOperand(i).Val;
        if (Op == (*SUnitMap)[DU])
          return true;
      }
    }
  }
  return false;
}


/// AddPseudoTwoAddrDeps - If two nodes share an operand and one of them uses
/// it as a def&use operand. Add a pseudo control edge from it to the other
/// node (if it won't create a cycle) so the two-address one will be scheduled
/// first (lower in the schedule).
template<class SF>
void BURegReductionPriorityQueue<SF>::AddPseudoTwoAddrDeps() {
  for (unsigned i = 0, e = SUnits->size(); i != e; ++i) {
    SUnit *SU = (SUnit *)&((*SUnits)[i]);
    if (!SU->isTwoAddress)
      continue;

    SDNode *Node = SU->Node;
    if (!Node->isTargetOpcode())
      continue;

    unsigned Opc = Node->getTargetOpcode();
    unsigned NumRes = ScheduleDAG::CountResults(Node);
    unsigned NumOps = ScheduleDAG::CountOperands(Node);
    for (unsigned j = 0; j != NumOps; ++j) {
      if (TII->getOperandConstraint(Opc, j+NumRes, TOI::TIED_TO) != -1) {
        SDNode *DU = SU->Node->getOperand(j).Val;
        SUnit *DUSU = (*SUnitMap)[DU];
        if (!DUSU) continue;
        for (SUnit::succ_iterator I = DUSU->Succs.begin(),E = DUSU->Succs.end();
             I != E; ++I) {
          if (I->second) continue;
          SUnit *SuccSU = I->first;
          if (SuccSU != SU &&
              (!canClobber(SuccSU, DUSU) ||
               (!SU->isCommutable && SuccSU->isCommutable))){
            if (SuccSU->Depth == SU->Depth && !isReachable(SuccSU, SU)) {
              DEBUG(std::cerr << "Adding an edge from SU # " << SU->NodeNum
                    << " to SU #" << SuccSU->NodeNum << "\n");
              if (SU->addPred(SuccSU, true))
                SU->NumChainPredsLeft++;
              if (SuccSU->addSucc(SU, true))
                SuccSU->NumChainSuccsLeft++;
            }
          }
        }
      }
    }
  }
}

/// CalcNodePriority - Priority is the Sethi Ullman number. 
/// Smaller number is the higher priority.
template<class SF>
int BURegReductionPriorityQueue<SF>::CalcNodePriority(const SUnit *SU) {
  int &SethiUllmanNumber = SethiUllmanNumbers[SU->NodeNum];
  if (SethiUllmanNumber != 0)
    return SethiUllmanNumber;

  unsigned Opc = SU->Node->getOpcode();
  if (Opc == ISD::CopyFromReg && !isCopyFromLiveIn(SU))
    // CopyFromReg should be close to its def because it restricts allocation
    // choices. But if it is a livein then perhaps we want it closer to the
    // uses so it can be coalesced.
    SethiUllmanNumber = INT_MIN + 10;
  else if (Opc == ISD::TokenFactor || Opc == ISD::CopyToReg)
    // CopyToReg should be close to its uses to facilitate coalescing and avoid
    // spilling.
    SethiUllmanNumber = INT_MAX - 10;
  else if (SU->NumSuccsLeft == 0)
    // If SU does not have a use, i.e. it doesn't produce a value that would
    // be consumed (e.g. store), then it terminates a chain of computation.
    // Give it a small SethiUllman number so it will be scheduled right before its
    // predecessors that it doesn't lengthen their live ranges.
    SethiUllmanNumber = INT_MIN + 10;
  else if (SU->NumPredsLeft == 0)
    // If SU does not have a def, schedule it close to its uses because it does
    // not lengthen any live ranges.
    SethiUllmanNumber = INT_MAX - 10;
  else {
    int Extra = 0;
    for (SUnit::const_pred_iterator I = SU->Preds.begin(), E = SU->Preds.end();
         I != E; ++I) {
      if (I->second) continue;  // ignore chain preds
      SUnit *PredSU = I->first;
      int PredSethiUllman = CalcNodePriority(PredSU);
      if (PredSethiUllman > SethiUllmanNumber) {
        SethiUllmanNumber = PredSethiUllman;
        Extra = 0;
      } else if (PredSethiUllman == SethiUllmanNumber && !I->second)
        Extra++;
    }

    SethiUllmanNumber += Extra;
  }
  
  return SethiUllmanNumber;
}

/// CalculatePriorities - Calculate priorities of all scheduling units.
template<class SF>
void BURegReductionPriorityQueue<SF>::CalculatePriorities() {
  SethiUllmanNumbers.assign(SUnits->size(), 0);
  
  for (unsigned i = 0, e = SUnits->size(); i != e; ++i)
    CalcNodePriority(&(*SUnits)[i]);
}

static unsigned SumOfUnscheduledPredsOfSuccs(const SUnit *SU) {
  unsigned Sum = 0;
  for (SUnit::const_succ_iterator I = SU->Succs.begin(), E = SU->Succs.end();
       I != E; ++I) {
    SUnit *SuccSU = I->first;
    for (SUnit::const_pred_iterator II = SuccSU->Preds.begin(),
         EE = SuccSU->Preds.end(); II != EE; ++II) {
      SUnit *PredSU = II->first;
      if (!PredSU->isScheduled)
        Sum++;
    }
  }

  return Sum;
}


// Top down
bool td_ls_rr_sort::operator()(const SUnit *left, const SUnit *right) const {
  unsigned LeftNum  = left->NodeNum;
  unsigned RightNum = right->NodeNum;
  int LPriority = SPQ->getSethiUllmanNumber(LeftNum);
  int RPriority = SPQ->getSethiUllmanNumber(RightNum);
  bool LIsTarget = left->Node->isTargetOpcode();
  bool RIsTarget = right->Node->isTargetOpcode();
  bool LIsFloater = LIsTarget && left->NumPreds == 0;
  bool RIsFloater = RIsTarget && right->NumPreds == 0;
  unsigned LBonus = (SumOfUnscheduledPredsOfSuccs(left) == 1) ? 2 : 0;
  unsigned RBonus = (SumOfUnscheduledPredsOfSuccs(right) == 1) ? 2 : 0;

  if (left->NumSuccs == 0 && right->NumSuccs != 0)
    return false;
  else if (left->NumSuccs != 0 && right->NumSuccs == 0)
    return true;

  // Special tie breaker: if two nodes share a operand, the one that use it
  // as a def&use operand is preferred.
  if (LIsTarget && RIsTarget) {
    if (left->isTwoAddress && !right->isTwoAddress) {
      SDNode *DUNode = left->Node->getOperand(0).Val;
      if (DUNode->isOperand(right->Node))
        RBonus += 2;
    }
    if (!left->isTwoAddress && right->isTwoAddress) {
      SDNode *DUNode = right->Node->getOperand(0).Val;
      if (DUNode->isOperand(left->Node))
        LBonus += 2;
    }
  }
  if (LIsFloater)
    LBonus -= 2;
  if (RIsFloater)
    RBonus -= 2;
  if (left->NumSuccs == 1)
    LBonus += 2;
  if (right->NumSuccs == 1)
    RBonus += 2;

  if (LPriority+LBonus < RPriority+RBonus)
    return true;
  else if (LPriority == RPriority)
    if (left->Depth < right->Depth)
      return true;
    else if (left->Depth == right->Depth)
      if (left->NumSuccsLeft > right->NumSuccsLeft)
        return true;
      else if (left->NumSuccsLeft == right->NumSuccsLeft)
        if (left->CycleBound > right->CycleBound) 
          return true;
  return false;
}

/// CalcNodePriority - Priority is the Sethi Ullman number. 
/// Smaller number is the higher priority.
template<class SF>
int TDRegReductionPriorityQueue<SF>::CalcNodePriority(const SUnit *SU) {
  int &SethiUllmanNumber = SethiUllmanNumbers[SU->NodeNum];
  if (SethiUllmanNumber != 0)
    return SethiUllmanNumber;

  unsigned Opc = SU->Node->getOpcode();
  if (Opc == ISD::TokenFactor || Opc == ISD::CopyToReg)
    SethiUllmanNumber = INT_MAX - 10;
  else if (SU->NumSuccsLeft == 0)
    // If SU does not have a use, i.e. it doesn't produce a value that would
    // be consumed (e.g. store), then it terminates a chain of computation.
    // Give it a small SethiUllman number so it will be scheduled right before its
    // predecessors that it doesn't lengthen their live ranges.
    SethiUllmanNumber = INT_MIN + 10;
  else if (SU->NumPredsLeft == 0 &&
           (Opc != ISD::CopyFromReg || isCopyFromLiveIn(SU)))
    SethiUllmanNumber = 1;
  else {
    int Extra = 0;
    for (SUnit::const_pred_iterator I = SU->Preds.begin(), E = SU->Preds.end();
         I != E; ++I) {
      if (I->second) continue;  // ignore chain preds
      SUnit *PredSU = I->first;
      int PredSethiUllman = CalcNodePriority(PredSU);
      if (PredSethiUllman > SethiUllmanNumber) {
        SethiUllmanNumber = PredSethiUllman;
        Extra = 0;
      } else if (PredSethiUllman == SethiUllmanNumber && !I->second)
        Extra++;
    }

    SethiUllmanNumber += Extra;
  }
  
  return SethiUllmanNumber;
}

/// CalculatePriorities - Calculate priorities of all scheduling units.
template<class SF>
void TDRegReductionPriorityQueue<SF>::CalculatePriorities() {
  SethiUllmanNumbers.assign(SUnits->size(), 0);
  
  for (unsigned i = 0, e = SUnits->size(); i != e; ++i)
    CalcNodePriority(&(*SUnits)[i]);
}

//===----------------------------------------------------------------------===//
//                         Public Constructor Functions
//===----------------------------------------------------------------------===//

llvm::ScheduleDAG* llvm::createBURRListDAGScheduler(SelectionDAGISel *IS,
                                                    SelectionDAG *DAG,
                                                    MachineBasicBlock *BB) {
  const TargetInstrInfo *TII = DAG->getTarget().getInstrInfo();
  return new ScheduleDAGRRList(*DAG, BB, DAG->getTarget(), true,
                           new BURegReductionPriorityQueue<bu_ls_rr_sort>(TII));
}

llvm::ScheduleDAG* llvm::createTDRRListDAGScheduler(SelectionDAGISel *IS,
                                                    SelectionDAG *DAG,
                                                    MachineBasicBlock *BB) {
  return new ScheduleDAGRRList(*DAG, BB, DAG->getTarget(), false,
                               new TDRegReductionPriorityQueue<td_ls_rr_sort>());
}

