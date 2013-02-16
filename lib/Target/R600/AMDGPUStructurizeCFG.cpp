//===-- AMDGPUStructurizeCFG.cpp -  ------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
/// \file
/// The pass implemented in this file transforms the programs control flow
/// graph into a form that's suitable for code generation on hardware that
/// implements control flow by execution masking. This currently includes all
/// AMD GPUs but may as well be useful for other types of hardware.
//
//===----------------------------------------------------------------------===//

#include "AMDGPU.h"
#include "llvm/ADT/SCCIterator.h"
#include "llvm/Analysis/RegionInfo.h"
#include "llvm/Analysis/RegionIterator.h"
#include "llvm/Analysis/RegionPass.h"
#include "llvm/IR/Module.h"
#include "llvm/Transforms/Utils/SSAUpdater.h"

using namespace llvm;

namespace {

// Definition of the complex types used in this pass.

typedef std::pair<BasicBlock *, Value *> BBValuePair;

typedef SmallVector<RegionNode*, 8> RNVector;
typedef SmallVector<BasicBlock*, 8> BBVector;
typedef SmallVector<BranchInst*, 8> BranchVector;
typedef SmallVector<BBValuePair, 2> BBValueVector;

typedef SmallPtrSet<BasicBlock *, 8> BBSet;

typedef DenseMap<PHINode *, BBValueVector> PhiMap;
typedef DenseMap<DomTreeNode *, unsigned> DTN2UnsignedMap;
typedef DenseMap<BasicBlock *, PhiMap> BBPhiMap;
typedef DenseMap<BasicBlock *, Value *> BBPredicates;
typedef DenseMap<BasicBlock *, BBPredicates> PredMap;
typedef DenseMap<BasicBlock *, BBVector> BB2BBVecMap;

// The name for newly created blocks.

static const char *FlowBlockName = "Flow";

/// @brief Find the nearest common dominator for multiple BasicBlocks
///
/// Helper class for AMDGPUStructurizeCFG
/// TODO: Maybe move into common code
class NearestCommonDominator {

  DominatorTree *DT;

  DTN2UnsignedMap IndexMap;

  BasicBlock *Result;
  unsigned ResultIndex;
  bool ExplicitMentioned;

public:
  /// \brief Start a new query
  NearestCommonDominator(DominatorTree *DomTree) {
    DT = DomTree;
    Result = 0;
  }

  /// \brief Add BB to the resulting dominator
  void addBlock(BasicBlock *BB, bool Remember = true) {

    DomTreeNode *Node = DT->getNode(BB);

    if (Result == 0) {
      unsigned Numbering = 0;
      for (;Node;Node = Node->getIDom())
        IndexMap[Node] = ++Numbering;
      Result = BB;
      ResultIndex = 1;
      ExplicitMentioned = Remember;
      return;
    }

    for (;Node;Node = Node->getIDom())
      if (IndexMap.count(Node))
        break;
      else
        IndexMap[Node] = 0;

    assert(Node && "Dominator tree invalid!");

    unsigned Numbering = IndexMap[Node];
    if (Numbering > ResultIndex) {
      Result = Node->getBlock();
      ResultIndex = Numbering;
      ExplicitMentioned = Remember && (Result == BB);
    } else if (Numbering == ResultIndex) {
      ExplicitMentioned |= Remember;
    }
  }

  /// \brief Is "Result" one of the BBs added with "Remember" = True?
  bool wasResultExplicitMentioned() {
    return ExplicitMentioned;
  }

  /// \brief Get the query result
  BasicBlock *getResult() {
    return Result;
  }
};

/// @brief Transforms the control flow graph on one single entry/exit region
/// at a time.
///
/// After the transform all "If"/"Then"/"Else" style control flow looks like
/// this:
///
/// \verbatim
/// 1
/// ||
/// | |
/// 2 |
/// | /
/// |/   
/// 3
/// ||   Where:
/// | |  1 = "If" block, calculates the condition
/// 4 |  2 = "Then" subregion, runs if the condition is true
/// | /  3 = "Flow" blocks, newly inserted flow blocks, rejoins the flow
/// |/   4 = "Else" optional subregion, runs if the condition is false
/// 5    5 = "End" block, also rejoins the control flow
/// \endverbatim
///
/// Control flow is expressed as a branch where the true exit goes into the
/// "Then"/"Else" region, while the false exit skips the region
/// The condition for the optional "Else" region is expressed as a PHI node.
/// The incomming values of the PHI node are true for the "If" edge and false
/// for the "Then" edge.
///
/// Additionally to that even complicated loops look like this:
///
/// \verbatim
/// 1
/// ||
/// | |
/// 2 ^  Where:
/// | /  1 = "Entry" block
/// |/   2 = "Loop" optional subregion, with all exits at "Flow" block
/// 3    3 = "Flow" block, with back edge to entry block
/// |
/// \endverbatim
///
/// The back edge of the "Flow" block is always on the false side of the branch
/// while the true side continues the general flow. So the loop condition
/// consist of a network of PHI nodes where the true incoming values expresses
/// breaks and the false values expresses continue states.
class AMDGPUStructurizeCFG : public RegionPass {

  static char ID;

  Type *Boolean;
  ConstantInt *BoolTrue;
  ConstantInt *BoolFalse;
  UndefValue *BoolUndef;

  Function *Func;
  Region *ParentRegion;

  DominatorTree *DT;

  RNVector Order;
  BBSet Visited;
  PredMap Predicates;
  BBPhiMap DeletedPhis;
  BB2BBVecMap AddedPhis;
  BranchVector Conditions;

  BasicBlock *LoopStart;
  BasicBlock *LoopEnd;
  BBSet LoopTargets;
  BBPredicates LoopPred;

  void orderNodes();

  Value *buildCondition(BranchInst *Term, unsigned Idx, bool Invert);

  bool analyzeLoopStart(BasicBlock *From, BasicBlock *To, Value *Condition);

  void analyzeNode(RegionNode *N);

  void analyzeLoopEnd(RegionNode *N);

  void collectInfos();

  void insertConditions();

  void delPhiValues(BasicBlock *From, BasicBlock *To);

  void addPhiValues(BasicBlock *From, BasicBlock *To);

  void setPhiValues();

  void killTerminator(BasicBlock *BB);

  void changeExit(RegionNode *Node, BasicBlock *NewExit,
                  bool IncludeDominator);

  BasicBlock *getNextFlow(BasicBlock *Dominator);

  BasicBlock *needPrefix(RegionNode *&Prev, RegionNode *Node);

  BasicBlock *needPostfix(BasicBlock *Flow, bool ExitUseAllowed);

  RegionNode *getNextPrev(BasicBlock *Next);

  bool dominatesPredicates(BasicBlock *BB, RegionNode *Node);

  bool isPredictableTrue(RegionNode *Who, RegionNode *Where);

  RegionNode *wireFlow(RegionNode *&Prev, bool ExitUseAllowed);

  void createFlow();

  void rebuildSSA();

public:
  AMDGPUStructurizeCFG():
    RegionPass(ID) {

    initializeRegionInfoPass(*PassRegistry::getPassRegistry());
  }

  virtual bool doInitialization(Region *R, RGPassManager &RGM);

  virtual bool runOnRegion(Region *R, RGPassManager &RGM);

  virtual const char *getPassName() const {
    return "AMDGPU simplify control flow";
  }

  void getAnalysisUsage(AnalysisUsage &AU) const {

    AU.addRequired<DominatorTree>();
    AU.addPreserved<DominatorTree>();
    RegionPass::getAnalysisUsage(AU);
  }

};

} // end anonymous namespace

char AMDGPUStructurizeCFG::ID = 0;

/// \brief Initialize the types and constants used in the pass
bool AMDGPUStructurizeCFG::doInitialization(Region *R, RGPassManager &RGM) {
  LLVMContext &Context = R->getEntry()->getContext();

  Boolean = Type::getInt1Ty(Context);
  BoolTrue = ConstantInt::getTrue(Context);
  BoolFalse = ConstantInt::getFalse(Context);
  BoolUndef = UndefValue::get(Boolean);

  return false;
}

/// \brief Build up the general order of nodes
void AMDGPUStructurizeCFG::orderNodes() {
  scc_iterator<Region *> I = scc_begin(ParentRegion),
                         E = scc_end(ParentRegion);
  for (Order.clear(); I != E; ++I) {
    std::vector<RegionNode *> &Nodes = *I;
    Order.append(Nodes.begin(), Nodes.end());
  }
}

/// \brief Build the condition for one edge
Value *AMDGPUStructurizeCFG::buildCondition(BranchInst *Term, unsigned Idx,
                                            bool Invert) {
  Value *Cond = Invert ? BoolFalse : BoolTrue;
  if (Term->isConditional()) {
    Cond = Term->getCondition();

    if (Idx != Invert)
      Cond = BinaryOperator::CreateNot(Cond, "", Term);
  }
  return Cond;
}

/// \brief Analyze the start of a loop and insert predicates as necessary
bool AMDGPUStructurizeCFG::analyzeLoopStart(BasicBlock *From, BasicBlock *To,
                                            Value *Condition) {
  LoopPred[From] = Condition;
  LoopTargets.insert(To);
  if (!LoopStart) {
    LoopStart = To;
    return true;

  } else if (LoopStart == To)
    return true;

  // We need to handle the case of intersecting loops, e. g.
  //
  //    /----<-----
  //    |         |
  // -> A -> B -> C -> D
  //         |         |
  //         -----<----/

  RNVector::reverse_iterator OI = Order.rbegin(), OE = Order.rend();

  for (;OI != OE; ++OI)
    if ((*OI)->getEntry() == LoopStart)
      break;

  for (;OI != OE && (*OI)->getEntry() != To; ++OI) {
    BBPredicates &Pred = Predicates[(*OI)->getEntry()];
    if (!Pred.count(From))
      Pred[From] = Condition;
  }
  return false;
}

/// \brief Analyze the predecessors of each block and build up predicates
void AMDGPUStructurizeCFG::analyzeNode(RegionNode *N) {
  RegionInfo *RI = ParentRegion->getRegionInfo();
  BasicBlock *BB = N->getEntry();
  BBPredicates &Pred = Predicates[BB];

  for (pred_iterator PI = pred_begin(BB), PE = pred_end(BB);
       PI != PE; ++PI) {

    if (!ParentRegion->contains(*PI)) {
      // It's a branch from outside into our region entry
      Pred[*PI] = BoolTrue;
      continue;
    }

    Region *R = RI->getRegionFor(*PI);
    if (R == ParentRegion) {

      // It's a top level block in our region
      BranchInst *Term = cast<BranchInst>((*PI)->getTerminator());
      for (unsigned i = 0, e = Term->getNumSuccessors(); i != e; ++i) {
        BasicBlock *Succ = Term->getSuccessor(i);
        if (Succ != BB)
          continue;

        if (Visited.count(*PI)) {
          // Normal forward edge
          if (Term->isConditional()) {
            // Try to treat it like an ELSE block
            BasicBlock *Other = Term->getSuccessor(!i);
            if (Visited.count(Other) && !LoopTargets.count(Other) &&
                !Pred.count(Other) && !Pred.count(*PI)) {

              Pred[Other] = BoolFalse;
              Pred[*PI] = BoolTrue;
              continue;
            }
          }

        } else {
          // Back edge
          if (analyzeLoopStart(*PI, BB, buildCondition(Term, i, true)))
            continue;
        }
        Pred[*PI] = buildCondition(Term, i, false);
      }

    } else {

      // It's an exit from a sub region
      while(R->getParent() != ParentRegion)
        R = R->getParent();

      // Edge from inside a subregion to its entry, ignore it
      if (R == N)
        continue;

      BasicBlock *Entry = R->getEntry();
      if (!Visited.count(Entry))
        if (analyzeLoopStart(Entry, BB, BoolFalse))
          continue;

      Pred[Entry] = BoolTrue;
    }
  }
}

/// \brief Determine the end of the loop
void AMDGPUStructurizeCFG::analyzeLoopEnd(RegionNode *N) {

  if (N->isSubRegion()) {
    // Test for exit as back edge
    BasicBlock *Exit = N->getNodeAs<Region>()->getExit();
    if (Visited.count(Exit))
      LoopEnd = N->getEntry();

  } else {
    // Test for sucessors as back edge
    BasicBlock *BB = N->getNodeAs<BasicBlock>();
    BranchInst *Term = cast<BranchInst>(BB->getTerminator());

    for (unsigned i = 0, e = Term->getNumSuccessors(); i != e; ++i) {
      BasicBlock *Succ = Term->getSuccessor(i);

      if (Visited.count(Succ))
        LoopEnd = BB;
    }
  }
}

/// \brief Collect various loop and predicate infos
void AMDGPUStructurizeCFG::collectInfos() {

  // Reset predicate
  Predicates.clear();

  // and loop infos
  LoopStart = LoopEnd = 0;
  LoopTargets.clear();
  LoopPred.clear();

  // Reset the visited nodes
  Visited.clear();

  for (RNVector::reverse_iterator OI = Order.rbegin(), OE = Order.rend();
       OI != OE; ++OI) {

    // Analyze all the conditions leading to a node
    analyzeNode(*OI);

    // Remember that we've seen this node
    Visited.insert((*OI)->getEntry());

    // Find the last back edge
    analyzeLoopEnd(*OI);
  }

  // Both or neither must be set
  assert(!LoopStart == !LoopEnd);
}

/// \brief Insert the missing branch conditions
void AMDGPUStructurizeCFG::insertConditions() {
  SSAUpdater PhiInserter;

  for (BranchVector::iterator I = Conditions.begin(),
       E = Conditions.end(); I != E; ++I) {

    BranchInst *Term = *I;
    BasicBlock *Parent = Term->getParent();

    assert(Term->isConditional());

    PhiInserter.Initialize(Boolean, "");
    if (Parent == LoopEnd) {
      PhiInserter.AddAvailableValue(LoopStart, BoolTrue);
    } else {
      PhiInserter.AddAvailableValue(&Func->getEntryBlock(), BoolFalse);
      PhiInserter.AddAvailableValue(Parent, BoolFalse);
    }

    bool ParentHasValue = false;
    BasicBlock *Succ = Term->getSuccessor(0);
    BBPredicates &Preds = (Parent == LoopEnd) ? LoopPred : Predicates[Succ];
    for (BBPredicates::iterator PI = Preds.begin(), PE = Preds.end();
         PI != PE; ++PI) {

      PhiInserter.AddAvailableValue(PI->first, PI->second);
      ParentHasValue |= PI->first == Parent;
    }

    if (ParentHasValue)
      Term->setCondition(PhiInserter.GetValueAtEndOfBlock(Parent));
    else
      Term->setCondition(PhiInserter.GetValueInMiddleOfBlock(Parent));
  }
}

/// \brief Remove all PHI values coming from "From" into "To" and remember
/// them in DeletedPhis
void AMDGPUStructurizeCFG::delPhiValues(BasicBlock *From, BasicBlock *To) {
  PhiMap &Map = DeletedPhis[To];
  for (BasicBlock::iterator I = To->begin(), E = To->end();
       I != E && isa<PHINode>(*I);) {

    PHINode &Phi = cast<PHINode>(*I++);
    while (Phi.getBasicBlockIndex(From) != -1) {
      Value *Deleted = Phi.removeIncomingValue(From, false);
      Map[&Phi].push_back(std::make_pair(From, Deleted));
    }
  }
}

/// \brief Add a dummy PHI value as soon as we knew the new predecessor
void AMDGPUStructurizeCFG::addPhiValues(BasicBlock *From, BasicBlock *To) {
  for (BasicBlock::iterator I = To->begin(), E = To->end();
       I != E && isa<PHINode>(*I);) {

    PHINode &Phi = cast<PHINode>(*I++);
    Value *Undef = UndefValue::get(Phi.getType());
    Phi.addIncoming(Undef, From);
  }
  AddedPhis[To].push_back(From);
}

/// \brief Add the real PHI value as soon as everything is set up
void AMDGPUStructurizeCFG::setPhiValues() {

  SSAUpdater Updater;
  for (BB2BBVecMap::iterator AI = AddedPhis.begin(), AE = AddedPhis.end();
       AI != AE; ++AI) {

    BasicBlock *To = AI->first;
    BBVector &From = AI->second;

    if (!DeletedPhis.count(To))
      continue;

    PhiMap &Map = DeletedPhis[To];
    for (PhiMap::iterator PI = Map.begin(), PE = Map.end();
         PI != PE; ++PI) {

      PHINode *Phi = PI->first;
      Value *Undef = UndefValue::get(Phi->getType());
      Updater.Initialize(Phi->getType(), "");
      Updater.AddAvailableValue(&Func->getEntryBlock(), Undef);
      Updater.AddAvailableValue(To, Undef);

      NearestCommonDominator Dominator(DT);
      Dominator.addBlock(To, false);
      for (BBValueVector::iterator VI = PI->second.begin(),
           VE = PI->second.end(); VI != VE; ++VI) {

        Updater.AddAvailableValue(VI->first, VI->second);
        Dominator.addBlock(VI->first);
      }

      if (!Dominator.wasResultExplicitMentioned())
        Updater.AddAvailableValue(Dominator.getResult(), Undef);

      for (BBVector::iterator FI = From.begin(), FE = From.end();
           FI != FE; ++FI) {

        int Idx = Phi->getBasicBlockIndex(*FI);
        assert(Idx != -1);
        Phi->setIncomingValue(Idx, Updater.GetValueAtEndOfBlock(*FI));
      }
    }

    DeletedPhis.erase(To);
  }
  assert(DeletedPhis.empty());
}

/// \brief Remove phi values from all successors and then remove the terminator.
void AMDGPUStructurizeCFG::killTerminator(BasicBlock *BB) {
  TerminatorInst *Term = BB->getTerminator();
  if (!Term)
    return;

  for (succ_iterator SI = succ_begin(BB), SE = succ_end(BB);
       SI != SE; ++SI) {

    delPhiValues(BB, *SI);
  }

  Term->eraseFromParent();
}

/// \brief Let node exit(s) point to NewExit
void AMDGPUStructurizeCFG::changeExit(RegionNode *Node, BasicBlock *NewExit,
                                      bool IncludeDominator) {

  if (Node->isSubRegion()) {
    Region *SubRegion = Node->getNodeAs<Region>();
    BasicBlock *OldExit = SubRegion->getExit();
    BasicBlock *Dominator = 0;

    // Find all the edges from the sub region to the exit
    for (pred_iterator I = pred_begin(OldExit), E = pred_end(OldExit);
         I != E;) {

      BasicBlock *BB = *I++;
      if (!SubRegion->contains(BB))
        continue;

      // Modify the edges to point to the new exit
      delPhiValues(BB, OldExit);
      BB->getTerminator()->replaceUsesOfWith(OldExit, NewExit);
      addPhiValues(BB, NewExit);

      // Find the new dominator (if requested)
      if (IncludeDominator) {
        if (!Dominator)
          Dominator = BB;
        else
          Dominator = DT->findNearestCommonDominator(Dominator, BB);
      }
    }

    // Change the dominator (if requested)
    if (Dominator)
      DT->changeImmediateDominator(NewExit, Dominator);

    // Update the region info
    SubRegion->replaceExit(NewExit);

  } else {
    BasicBlock *BB = Node->getNodeAs<BasicBlock>();
    killTerminator(BB);
    BranchInst::Create(NewExit, BB);
    addPhiValues(BB, NewExit);
    if (IncludeDominator)
      DT->changeImmediateDominator(NewExit, BB);
  }
}

/// \brief Create a new flow node and update dominator tree and region info
BasicBlock *AMDGPUStructurizeCFG::getNextFlow(BasicBlock *Dominator) {
  LLVMContext &Context = Func->getContext();
  BasicBlock *Insert = Order.empty() ? ParentRegion->getExit() :
                       Order.back()->getEntry();
  BasicBlock *Flow = BasicBlock::Create(Context, FlowBlockName,
                                        Func, Insert);
  DT->addNewBlock(Flow, Dominator);
  ParentRegion->getRegionInfo()->setRegionFor(Flow, ParentRegion);
  return Flow;
}

/// \brief Create a new or reuse the previous node as flow node
BasicBlock *AMDGPUStructurizeCFG::needPrefix(RegionNode *&Prev,
                                             RegionNode *Node) {

  if (!Prev || Prev->isSubRegion() ||
      (Node && Node->getEntry() == LoopStart)) {

    // We need to insert a flow node, first figure out the dominator
    DomTreeNode *Dominator = Prev ? DT->getNode(Prev->getEntry()) : 0;
    if (!Dominator)
      Dominator = DT->getNode(Node->getEntry())->getIDom();
    assert(Dominator && "Illegal loop to function entry");

    // then create the flow node
    BasicBlock *Flow = getNextFlow(Dominator->getBlock());

    // wire up the new flow
    if (Prev) {
      changeExit(Prev, Flow, true);
    } else {
      // Parent regions entry needs predicates, create a new region entry
      BasicBlock *Entry = Node->getEntry();
      for (pred_iterator I = pred_begin(Entry), E = pred_end(Entry);
           I != E;) {

        BasicBlock *BB = *(I++);
        if (ParentRegion->contains(BB))
          continue;

        // Remove PHY values from outside to our entry node
        delPhiValues(BB, Entry);

        // Update the branch instructions
        BB->getTerminator()->replaceUsesOfWith(Entry, Flow);
      }

      // Populate the region tree with the new entry
      for (Region *R = ParentRegion; R && R->getEntry() == Entry;
           R = R->getParent()) {
        R->replaceEntry(Flow);
      }
    }
    Prev = ParentRegion->getBBNode(Flow);

  } else {
    killTerminator(Prev->getEntry());
  }

  return Prev->getEntry();
}

/// \brief Returns the region exit if possible, otherwise just a new flow node
BasicBlock *AMDGPUStructurizeCFG::needPostfix(BasicBlock *Flow,
                                              bool ExitUseAllowed) {

  if (Order.empty() && ExitUseAllowed) {
    BasicBlock *Exit = ParentRegion->getExit();
    DT->changeImmediateDominator(Exit, Flow);
    addPhiValues(Flow, Exit);
    return Exit;
  }
  return getNextFlow(Flow);
}

/// \brief Returns the region node for Netx, or null if Next is the exit
RegionNode *AMDGPUStructurizeCFG::getNextPrev(BasicBlock *Next) {
  return ParentRegion->contains(Next) ? ParentRegion->getBBNode(Next) : 0;
}

/// \brief Does BB dominate all the predicates of Node ?
bool AMDGPUStructurizeCFG::dominatesPredicates(BasicBlock *BB, RegionNode *Node) {
  BBPredicates &Preds = Predicates[Node->getEntry()];
  for (BBPredicates::iterator PI = Preds.begin(), PE = Preds.end();
       PI != PE; ++PI) {

    if (!DT->dominates(BB, PI->first))
      return false;
  }
  return true;
}

/// \brief Can we predict that this node will always be called?
bool AMDGPUStructurizeCFG::isPredictableTrue(RegionNode *Who,
                                             RegionNode *Where) {

  BBPredicates &Preds = Predicates[Who->getEntry()];
  bool Dominated = Where == 0;

  for (BBPredicates::iterator I = Preds.begin(), E = Preds.end();
       I != E; ++I) {

    if (I->second != BoolTrue)
      return false;

    if (!Dominated && DT->dominates(I->first, Where->getEntry()))
      Dominated = true;
  }

  // TODO: The dominator check is too strict
  return Dominated;
}

/// Take one node from the order vector and wire it up
RegionNode *AMDGPUStructurizeCFG::wireFlow(RegionNode *&Prev,
                                           bool ExitUseAllowed) {

  RegionNode *Node = Order.pop_back_val();

  if (isPredictableTrue(Node, Prev)) {
    // Just a linear flow
    if (Prev) {
      changeExit(Prev, Node->getEntry(), true);
    }
    Prev = Node;

  } else {
    // Insert extra prefix node (or reuse last one)
    BasicBlock *Flow = needPrefix(Prev, Node);
    if (Node->getEntry() == LoopStart)
      LoopStart = Flow;

    // Insert extra postfix node (or use exit instead)
    BasicBlock *Entry = Node->getEntry();
    BasicBlock *Next = needPostfix(Flow, ExitUseAllowed && Entry != LoopEnd);

    // let it point to entry and next block
    Conditions.push_back(BranchInst::Create(Entry, Next, BoolUndef, Flow));
    addPhiValues(Flow, Entry);
    DT->changeImmediateDominator(Entry, Flow);

    Prev = Node;
    while (!Order.empty() && Node->getEntry() != LoopEnd &&
           !LoopTargets.count(Order.back()->getEntry()) &&
           dominatesPredicates(Entry, Order.back())) {
      Node = wireFlow(Prev, false);
    }

    changeExit(Prev, Next, false);
    Prev = getNextPrev(Next);
  }

  return Node;
}

/// After this function control flow looks like it should be, but
/// branches and PHI nodes only have undefined conditions.
void AMDGPUStructurizeCFG::createFlow() {

  BasicBlock *Exit = ParentRegion->getExit();
  bool EntryDominatesExit = DT->dominates(ParentRegion->getEntry(), Exit);

  DeletedPhis.clear();
  AddedPhis.clear();
  Conditions.clear();

  RegionNode *Prev = 0;
  while (!Order.empty()) {

    RegionNode *Node = wireFlow(Prev, EntryDominatesExit);

    // Create an extra loop end node
    if (Node->getEntry() == LoopEnd) {
      LoopEnd = needPrefix(Prev, 0);
      BasicBlock *Next = needPostfix(LoopEnd, EntryDominatesExit);

      Conditions.push_back(BranchInst::Create(Next, LoopStart,
                                              BoolUndef, LoopEnd));
      addPhiValues(LoopEnd, LoopStart);
      Prev = getNextPrev(Next);
    }
  }

  if (Prev)
    changeExit(Prev, Exit, EntryDominatesExit);
  else
    assert(EntryDominatesExit);
}

/// Handle a rare case where the disintegrated nodes instructions
/// no longer dominate all their uses. Not sure if this is really nessasary
void AMDGPUStructurizeCFG::rebuildSSA() {
  SSAUpdater Updater;
  for (Region::block_iterator I = ParentRegion->block_begin(),
                              E = ParentRegion->block_end();
       I != E; ++I) {

    BasicBlock *BB = *I;
    for (BasicBlock::iterator II = BB->begin(), IE = BB->end();
         II != IE; ++II) {

      bool Initialized = false;
      for (Use *I = &II->use_begin().getUse(), *Next; I; I = Next) {

        Next = I->getNext();

        Instruction *User = cast<Instruction>(I->getUser());
        if (User->getParent() == BB) {
          continue;

        } else if (PHINode *UserPN = dyn_cast<PHINode>(User)) {
          if (UserPN->getIncomingBlock(*I) == BB)
            continue;
        }

        if (DT->dominates(II, User))
          continue;

        if (!Initialized) {
          Value *Undef = UndefValue::get(II->getType());
          Updater.Initialize(II->getType(), "");
          Updater.AddAvailableValue(&Func->getEntryBlock(), Undef);
          Updater.AddAvailableValue(BB, II);
          Initialized = true;
        }
        Updater.RewriteUseAfterInsertions(*I);
      }
    }
  }
}

/// \brief Run the transformation for each region found
bool AMDGPUStructurizeCFG::runOnRegion(Region *R, RGPassManager &RGM) {
  if (R->isTopLevelRegion())
    return false;

  Func = R->getEntry()->getParent();
  ParentRegion = R;

  DT = &getAnalysis<DominatorTree>();

  orderNodes();
  collectInfos();
  createFlow();
  insertConditions();
  setPhiValues();
  rebuildSSA();

  // Cleanup
  Order.clear();
  Visited.clear();
  Predicates.clear();
  DeletedPhis.clear();
  AddedPhis.clear();
  Conditions.clear();
  LoopTargets.clear();
  LoopPred.clear();

  return true;
}

/// \brief Create the pass
Pass *llvm::createAMDGPUStructurizeCFGPass() {
  return new AMDGPUStructurizeCFG();
}
