//===- DAGISelMatcherOpt.cpp - Optimize a DAG Matcher ---------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the DAG Matcher optimizer.
//
//===----------------------------------------------------------------------===//

#define DEBUG_TYPE "isel-opt"
#include "DAGISelMatcher.h"
#include "CodeGenDAGPatterns.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/StringSet.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/raw_ostream.h"
#include <vector>
using namespace llvm;

/// ContractNodes - Turn multiple matcher node patterns like 'MoveChild+Record'
/// into single compound nodes like RecordChild.
static void ContractNodes(OwningPtr<Matcher> &MatcherPtr,
                          const CodeGenDAGPatterns &CGP) {
  // If we reached the end of the chain, we're done.
  Matcher *N = MatcherPtr.get();
  if (N == 0) return;
  
  // If we have a scope node, walk down all of the children.
  if (ScopeMatcher *Scope = dyn_cast<ScopeMatcher>(N)) {
    for (unsigned i = 0, e = Scope->getNumChildren(); i != e; ++i) {
      OwningPtr<Matcher> Child(Scope->takeChild(i));
      ContractNodes(Child, CGP);
      Scope->resetChild(i, Child.take());
    }
    return;
  }
  
  // If we found a movechild node with a node that comes in a 'foochild' form,
  // transform it.
  if (MoveChildMatcher *MC = dyn_cast<MoveChildMatcher>(N)) {
    Matcher *New = 0;
    if (RecordMatcher *RM = dyn_cast<RecordMatcher>(MC->getNext()))
      New = new RecordChildMatcher(MC->getChildNo(), RM->getWhatFor(),
                                   RM->getResultNo());
    
    if (CheckTypeMatcher *CT= dyn_cast<CheckTypeMatcher>(MC->getNext()))
      New = new CheckChildTypeMatcher(MC->getChildNo(), CT->getType());
    
    if (New) {
      // Insert the new node.
      New->setNext(MatcherPtr.take());
      MatcherPtr.reset(New);
      // Remove the old one.
      MC->setNext(MC->getNext()->takeNext());
      return ContractNodes(MatcherPtr, CGP);
    }
  }
  
  // Zap movechild -> moveparent.
  if (MoveChildMatcher *MC = dyn_cast<MoveChildMatcher>(N))
    if (MoveParentMatcher *MP = 
          dyn_cast<MoveParentMatcher>(MC->getNext())) {
      MatcherPtr.reset(MP->takeNext());
      return ContractNodes(MatcherPtr, CGP);
    }

  // Turn EmitNode->MarkFlagResults->CompleteMatch into
  // MarkFlagResults->EmitNode->CompleteMatch when we can to encourage
  // MorphNodeTo formation.  This is safe because MarkFlagResults never refers
  // to the root of the pattern.
  if (isa<EmitNodeMatcher>(N) && isa<MarkFlagResultsMatcher>(N->getNext()) &&
      isa<CompleteMatchMatcher>(N->getNext()->getNext())) {
    // Unlink the two nodes from the list.
    Matcher *EmitNode = MatcherPtr.take();
    Matcher *MFR = EmitNode->takeNext();
    Matcher *Tail = MFR->takeNext();
        
    // Relink them.
    MatcherPtr.reset(MFR);
    MFR->setNext(EmitNode);
    EmitNode->setNext(Tail);
    return ContractNodes(MatcherPtr, CGP);
  }

  // Turn EmitNode->CompleteMatch into MorphNodeTo if we can.
  if (EmitNodeMatcher *EN = dyn_cast<EmitNodeMatcher>(N))
    if (CompleteMatchMatcher *CM =
          dyn_cast<CompleteMatchMatcher>(EN->getNext())) {
      // We can only use MorphNodeTo if the result values match up.
      unsigned RootResultFirst = EN->getFirstResultSlot();
      bool ResultsMatch = true;
      for (unsigned i = 0, e = CM->getNumResults(); i != e; ++i)
        if (CM->getResult(i) != RootResultFirst+i)
          ResultsMatch = false;
      
      // If the selected node defines a subset of the flag/chain results, we
      // can't use MorphNodeTo.  For example, we can't use MorphNodeTo if the
      // matched pattern has a chain but the root node doesn't.
      const PatternToMatch &Pattern = CM->getPattern();
      
      if (!EN->hasChain() &&
          Pattern.getSrcPattern()->NodeHasProperty(SDNPHasChain, CGP))
        ResultsMatch = false;

      // If the matched node has a flag and the output root doesn't, we can't
      // use MorphNodeTo.
      //
      // NOTE: Strictly speaking, we don't have to check for the flag here
      // because the code in the pattern generator doesn't handle it right.  We
      // do it anyway for thoroughness.
      if (!EN->hasOutFlag() &&
          Pattern.getSrcPattern()->NodeHasProperty(SDNPOutFlag, CGP))
        ResultsMatch = false;
      
      
      // If the root result node defines more results than the source root node
      // *and* has a chain or flag input, then we can't match it because it
      // would end up replacing the extra result with the chain/flag.
#if 0
      if ((EN->hasFlag() || EN->hasChain()) &&
          EN->getNumNonChainFlagVTs() > ... need to get no results reliably ...)
        ResultMatch = false;
#endif
          
      if (ResultsMatch) {
        const SmallVectorImpl<MVT::SimpleValueType> &VTs = EN->getVTList();
        const SmallVectorImpl<unsigned> &Operands = EN->getOperandList();
        MatcherPtr.reset(new MorphNodeToMatcher(EN->getOpcodeName(),
                                                VTs.data(), VTs.size(),
                                                Operands.data(),Operands.size(),
                                                EN->hasChain(), EN->hasInFlag(),
                                                EN->hasOutFlag(),
                                                EN->hasMemRefs(),
                                                EN->getNumFixedArityOperands(),
                                                Pattern));
        return;
      }

      // FIXME2: Kill off all the SelectionDAG::MorphNodeTo and getMachineNode
      // variants.
    }
  
  ContractNodes(N->getNextPtr(), CGP);
  
  
  // If we have a CheckType/CheckChildType/Record node followed by a
  // CheckOpcode, invert the two nodes.  We prefer to do structural checks
  // before type checks, as this opens opportunities for factoring on targets
  // like X86 where many operations are valid on multiple types.
  if ((isa<CheckTypeMatcher>(N) || isa<CheckChildTypeMatcher>(N) ||
       isa<RecordMatcher>(N)) &&
      (isa<CheckOpcodeMatcher>(N->getNext()) ||
       isa<CheckMultiOpcodeMatcher>(N->getNext()))) {
    // Unlink the two nodes from the list.
    Matcher *CheckType = MatcherPtr.take();
    Matcher *CheckOpcode = CheckType->takeNext();
    Matcher *Tail = CheckOpcode->takeNext();
    
    // Relink them.
    MatcherPtr.reset(CheckOpcode);
    CheckOpcode->setNext(CheckType);
    CheckType->setNext(Tail);
    return ContractNodes(MatcherPtr, CGP);
  }
}

/// SinkPatternPredicates - Pattern predicates can be checked at any level of
/// the matching tree.  The generator dumps them at the top level of the pattern
/// though, which prevents factoring from being able to see past them.  This
/// optimization sinks them as far down into the pattern as possible.
///
/// Conceptually, we'd like to sink these predicates all the way to the last
/// matcher predicate in the series.  However, it turns out that some
/// ComplexPatterns have side effects on the graph, so we really don't want to
/// run a the complex pattern if the pattern predicate will fail.  For this
/// reason, we refuse to sink the pattern predicate past a ComplexPattern.
///
static void SinkPatternPredicates(OwningPtr<Matcher> &MatcherPtr) {
  // Recursively scan for a PatternPredicate.
  // If we reached the end of the chain, we're done.
  Matcher *N = MatcherPtr.get();
  if (N == 0) return;
  
  // Walk down all members of a scope node.
  if (ScopeMatcher *Scope = dyn_cast<ScopeMatcher>(N)) {
    for (unsigned i = 0, e = Scope->getNumChildren(); i != e; ++i) {
      OwningPtr<Matcher> Child(Scope->takeChild(i));
      SinkPatternPredicates(Child);
      Scope->resetChild(i, Child.take());
    }
    return;
  }
  
  // If this node isn't a CheckPatternPredicateMatcher we keep scanning until
  // we find one.
  CheckPatternPredicateMatcher *CPPM =dyn_cast<CheckPatternPredicateMatcher>(N);
  if (CPPM == 0)
    return SinkPatternPredicates(N->getNextPtr());
  
  // Ok, we found one, lets try to sink it. Check if we can sink it past the
  // next node in the chain.  If not, we won't be able to change anything and
  // might as well bail.
  if (!CPPM->getNext()->isSafeToReorderWithPatternPredicate())
    return;
  
  // Okay, we know we can sink it past at least one node.  Unlink it from the
  // chain and scan for the new insertion point.
  MatcherPtr.take();  // Don't delete CPPM.
  MatcherPtr.reset(CPPM->takeNext());
  
  N = MatcherPtr.get();
  while (N->getNext()->isSafeToReorderWithPatternPredicate())
    N = N->getNext();
  
  // At this point, we want to insert CPPM after N.
  CPPM->setNext(N->takeNext());
  N->setNext(CPPM);
}

/// FactorNodes - Turn matches like this:
///   Scope
///     OPC_CheckType i32
///       ABC
///     OPC_CheckType i32
///       XYZ
/// into:
///   OPC_CheckType i32
///     Scope
///       ABC
///       XYZ
///
static void FactorNodes(OwningPtr<Matcher> &MatcherPtr) {
  // If we reached the end of the chain, we're done.
  Matcher *N = MatcherPtr.get();
  if (N == 0) return;
  
  // If this is not a push node, just scan for one.
  ScopeMatcher *Scope = dyn_cast<ScopeMatcher>(N);
  if (Scope == 0)
    return FactorNodes(N->getNextPtr());
  
  // Okay, pull together the children of the scope node into a vector so we can
  // inspect it more easily.  While we're at it, bucket them up by the hash
  // code of their first predicate.
  SmallVector<Matcher*, 32> OptionsToMatch;
  
  for (unsigned i = 0, e = Scope->getNumChildren(); i != e; ++i) {
    // Factor the subexpression.
    OwningPtr<Matcher> Child(Scope->takeChild(i));
    FactorNodes(Child);
    
    if (Matcher *N = Child.take())
      OptionsToMatch.push_back(N);
  }
  
  SmallVector<Matcher*, 32> NewOptionsToMatch;
  
  // Loop over options to match, merging neighboring patterns with identical
  // starting nodes into a shared matcher.
  for (unsigned OptionIdx = 0, e = OptionsToMatch.size(); OptionIdx != e;) {
    // Find the set of matchers that start with this node.
    Matcher *Optn = OptionsToMatch[OptionIdx++];

    if (OptionIdx == e) {
      NewOptionsToMatch.push_back(Optn);
      continue;
    }
    
    // See if the next option starts with the same matcher.  If the two
    // neighbors *do* start with the same matcher, we can factor the matcher out
    // of at least these two patterns.  See what the maximal set we can merge
    // together is.
    SmallVector<Matcher*, 8> EqualMatchers;
    EqualMatchers.push_back(Optn);
    
    // Factor all of the known-equal matchers after this one into the same
    // group.
    while (OptionIdx != e && OptionsToMatch[OptionIdx]->isEqual(Optn))
      EqualMatchers.push_back(OptionsToMatch[OptionIdx++]);

    // If we found a non-equal matcher, see if it is contradictory with the
    // current node.  If so, we know that the ordering relation between the
    // current sets of nodes and this node don't matter.  Look past it to see if
    // we can merge anything else into this matching group.
    unsigned Scan = OptionIdx;
    while (1) {
      while (Scan != e && Optn->isContradictory(OptionsToMatch[Scan]))
        ++Scan;
      
      // Ok, we found something that isn't known to be contradictory.  If it is
      // equal, we can merge it into the set of nodes to factor, if not, we have
      // to cease factoring.
      if (Scan == e || !Optn->isEqual(OptionsToMatch[Scan])) break;

      // If is equal after all, add the option to EqualMatchers and remove it
      // from OptionsToMatch.
      EqualMatchers.push_back(OptionsToMatch[Scan]);
      OptionsToMatch.erase(OptionsToMatch.begin()+Scan);
      --e;
    }
      
    if (Scan != e &&
        // Don't print it's obvious nothing extra could be merged anyway.
        Scan+1 != e) {
      DEBUG(errs() << "Couldn't merge this:\n";
            Optn->print(errs(), 4);
            errs() << "into this:\n";
            OptionsToMatch[Scan]->print(errs(), 4);
            if (Scan+1 != e)
              OptionsToMatch[Scan+1]->printOne(errs());
            if (Scan+2 < e)
              OptionsToMatch[Scan+2]->printOne(errs());
            errs() << "\n");
    }
    
    // If we only found one option starting with this matcher, no factoring is
    // possible.
    if (EqualMatchers.size() == 1) {
      NewOptionsToMatch.push_back(EqualMatchers[0]);
      continue;
    }
    
    // Factor these checks by pulling the first node off each entry and
    // discarding it.  Take the first one off the first entry to reuse.
    Matcher *Shared = Optn;
    Optn = Optn->takeNext();
    EqualMatchers[0] = Optn;

    // Remove and delete the first node from the other matchers we're factoring.
    for (unsigned i = 1, e = EqualMatchers.size(); i != e; ++i) {
      Matcher *Tmp = EqualMatchers[i]->takeNext();
      delete EqualMatchers[i];
      EqualMatchers[i] = Tmp;
    }
    
    Shared->setNext(new ScopeMatcher(&EqualMatchers[0], EqualMatchers.size()));

    // Recursively factor the newly created node.
    FactorNodes(Shared->getNextPtr());
    
    NewOptionsToMatch.push_back(Shared);
  }
  
  // If we're down to a single pattern to match, then we don't need this scope
  // anymore.
  if (NewOptionsToMatch.size() == 1) {
    MatcherPtr.reset(NewOptionsToMatch[0]);
    return;
  }
  
  // If our factoring failed (didn't achieve anything) see if we can simplify in
  // other ways.
  
  // Check to see if all of the leading entries are now opcode checks.  If so,
  // we can convert this Scope to be a OpcodeSwitch instead.
  bool AllOpcodeChecks = true;
  for (unsigned i = 0, e = NewOptionsToMatch.size(); i != e; ++i) {
    if (isa<CheckOpcodeMatcher>(NewOptionsToMatch[i])) continue;
   
#if 0
    if (i > 3) {
      errs() << "FAILING OPC #" << i << "\n";
      NewOptionsToMatch[i]->dump();
    }
#endif
    
    AllOpcodeChecks = false;
    break;
  }
  
  // If all the options are CheckOpcode's, we can form the SwitchOpcode, woot.
  if (AllOpcodeChecks) {
    StringSet<> Opcodes;
    SmallVector<std::pair<const SDNodeInfo*, Matcher*>, 8> Cases;
    for (unsigned i = 0, e = NewOptionsToMatch.size(); i != e; ++i) {
      CheckOpcodeMatcher *COM =cast<CheckOpcodeMatcher>(NewOptionsToMatch[i]);
      assert(Opcodes.insert(COM->getOpcode().getEnumName()) &&
             "Duplicate opcodes not factored?");
      Cases.push_back(std::make_pair(&COM->getOpcode(), COM->getNext()));
    }
    
    MatcherPtr.reset(new SwitchOpcodeMatcher(&Cases[0], Cases.size()));
    return;
  }
  

  // Reassemble a new Scope node.
  assert(!NewOptionsToMatch.empty() &&
         "Where'd all our children go?  Did we really factor everything??");
  if (NewOptionsToMatch.empty())
    MatcherPtr.reset(0);
  else {
    Scope->setNumChildren(NewOptionsToMatch.size());
    for (unsigned i = 0, e = NewOptionsToMatch.size(); i != e; ++i)
      Scope->resetChild(i, NewOptionsToMatch[i]);
  }
}

Matcher *llvm::OptimizeMatcher(Matcher *TheMatcher,
                               const CodeGenDAGPatterns &CGP) {
  OwningPtr<Matcher> MatcherPtr(TheMatcher);
  ContractNodes(MatcherPtr, CGP);
  SinkPatternPredicates(MatcherPtr);
  FactorNodes(MatcherPtr);
  return MatcherPtr.take();
}
