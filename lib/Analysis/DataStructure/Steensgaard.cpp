//===- Steensgaard.cpp - Context Insensitive Alias Analysis ---------------===//
//
// This pass uses the data structure graphs to implement a simple context
// insensitive alias analysis.  It does this by computing the local analysis
// graphs for all of the functions, then merging them together into a single big
// graph without cloning.
//
//===----------------------------------------------------------------------===//

#include "llvm/Analysis/DataStructure.h"
#include "llvm/Analysis/DSGraph.h"
#include "llvm/Analysis/AliasAnalysis.h"
#include "llvm/Module.h"
#include "Support/Statistic.h"

namespace {
  class Steens : public Pass, public AliasAnalysis {
    DSGraph *ResultGraph;
    DSGraph *GlobalsGraph;  // FIXME: Eliminate globals graph stuff from DNE
  public:
    Steens() : ResultGraph(0) {}
    ~Steens() { assert(ResultGraph == 0 && "releaseMemory not called?"); }

    //------------------------------------------------
    // Implement the Pass API
    //

    // run - Build up the result graph, representing the pointer graph for the
    // program.
    //
    bool run(Module &M);

    virtual void releaseMemory() { delete ResultGraph; ResultGraph = 0; }

    virtual void getAnalysisUsage(AnalysisUsage &AU) const {
      AU.setPreservesAll();                    // Does not transform code...
      AU.addRequired<LocalDataStructures>();   // Uses local dsgraph
      AU.addRequired<AliasAnalysis>();         // Chains to another AA impl...
    }

    // print - Implement the Pass::print method...
    void print(std::ostream &O, const Module *M) const {
      assert(ResultGraph && "Result graph has not yet been computed!");
      ResultGraph->writeGraphToFile(O, "steensgaards");
    }

    //------------------------------------------------
    // Implement the AliasAnalysis API
    //  

    // alias - This is the only method here that does anything interesting...
    Result alias(const Value *V1, const Value *V2);
    
    /// canCallModify - Not implemented yet: FIXME
    ///
    Result canCallModify(const CallInst &CI, const Value *Ptr) {
      return MayAlias;
    }
    
    /// canInvokeModify - Not implemented yet: FIXME
    ///
    Result canInvokeModify(const InvokeInst &I, const Value *Ptr) {
      return MayAlias;
    }

  private:
    void ResolveFunctionCall(Function *F, const DSCallSite &Call,
                             DSNodeHandle &RetVal);
  };

  // Register the pass...
  RegisterOpt<Steens> X("steens-aa",
                        "Steensgaard's alias analysis (DSGraph based)");

  // Register as an implementation of AliasAnalysis
  RegisterAnalysisGroup<AliasAnalysis, Steens> Y;
}


/// ResolveFunctionCall - Resolve the actual arguments of a call to function F
/// with the specified call site descriptor.  This function links the arguments
/// and the return value for the call site context-insensitively.
///
void Steens::ResolveFunctionCall(Function *F, const DSCallSite &Call,
                                 DSNodeHandle &RetVal) {
  assert(ResultGraph != 0 && "Result graph not allocated!");
  hash_map<Value*, DSNodeHandle> &ValMap = ResultGraph->getScalarMap();

  // Handle the return value of the function...
  if (Call.getRetVal().getNode() && RetVal.getNode())
    RetVal.mergeWith(Call.getRetVal());

  // Loop over all pointer arguments, resolving them to their provided pointers
  unsigned PtrArgIdx = 0;
  for (Function::aiterator AI = F->abegin(), AE = F->aend(); AI != AE; ++AI) {
    hash_map<Value*, DSNodeHandle>::iterator I = ValMap.find(AI);
    if (I != ValMap.end())    // If its a pointer argument...
      I->second.mergeWith(Call.getPtrArg(PtrArgIdx++));
  }
}


/// run - Build up the result graph, representing the pointer graph for the
/// program.
///
bool Steens::run(Module &M) {
  assert(ResultGraph == 0 && "Result graph already allocated!");
  LocalDataStructures &LDS = getAnalysis<LocalDataStructures>();

  // Create a new, empty, graph...
  ResultGraph = new DSGraph();
  GlobalsGraph = new DSGraph();
  ResultGraph->setGlobalsGraph(GlobalsGraph);
  // RetValMap - Keep track of the return values for all functions that return
  // valid pointers.
  //
  hash_map<Function*, DSNodeHandle> RetValMap;

  // Loop over the rest of the module, merging graphs for non-external functions
  // into this graph.
  //
  for (Module::iterator I = M.begin(), E = M.end(); I != E; ++I)
    if (!I->isExternal()) {
      hash_map<Value*, DSNodeHandle> ValMap;
      {  // Scope to free NodeMap memory ASAP
        hash_map<const DSNode*, DSNodeHandle> NodeMap;
        const DSGraph &FDSG = LDS.getDSGraph(*I);
        DSNodeHandle RetNode = ResultGraph->cloneInto(FDSG, ValMap, NodeMap);

        // Keep track of the return node of the function's graph if it returns a
        // value...
        //
        if (RetNode.getNode())
          RetValMap[I] = RetNode;
      }

      // Incorporate the inlined Function's ScalarMap into the global
      // ScalarMap...
      hash_map<Value*, DSNodeHandle> &GVM = ResultGraph->getScalarMap();
      for (hash_map<Value*, DSNodeHandle>::iterator I = ValMap.begin(),
             E = ValMap.end(); I != E; ++I)
        GVM[I->first].mergeWith(I->second);
    }

  // FIXME: Must recalculate and use the Incomplete markers!!

  // Now that we have all of the graphs inlined, we can go about eliminating
  // call nodes...
  //
  std::vector<DSCallSite> &Calls =
    ResultGraph->getAuxFunctionCalls();
  assert(Calls.empty() && "Aux call list is already in use??");

  // Start with a copy of the original call sites...
  Calls = ResultGraph->getFunctionCalls();

  for (unsigned i = 0; i != Calls.size(); ) {
    DSCallSite &CurCall = Calls[i];
    
    // Loop over the called functions, eliminating as many as possible...
    std::vector<GlobalValue*> CallTargets;
    if (CurCall.isDirectCall())
      CallTargets.push_back(CurCall.getCalleeFunc());
    else 
      CallTargets = CurCall.getCalleeNode()->getGlobals();

    for (unsigned c = 0; c != CallTargets.size(); ) {
      // If we can eliminate this function call, do so!
      bool Eliminated = false;
      if (Function *F = dyn_cast<Function>(CallTargets[c]))
        if (!F->isExternal()) {
          ResolveFunctionCall(F, CurCall, RetValMap[F]);
          Eliminated = true;
        }
      if (Eliminated)
        CallTargets.erase(CallTargets.begin()+c);
      else
        ++c;  // Cannot eliminate this call, skip over it...
    }

    if (CallTargets.empty())          // Eliminated all calls?
      Calls.erase(Calls.begin()+i);   // Remove from call list...
    else
      ++i;                            // Skip this call site...
  }

  // Update the "incomplete" markers on the nodes, ignoring unknownness due to
  // incoming arguments...
  ResultGraph->maskIncompleteMarkers();
  ResultGraph->markIncompleteNodes(DSGraph::IgnoreFormalArgs);

  // Remove any nodes that are dead after all of the merging we have done...
  // FIXME: We should be able to disable the globals graph for steens!
  ResultGraph->removeDeadNodes(DSGraph::KeepUnreachableGlobals);

  DEBUG(print(std::cerr, &M));
  return false;
}

// alias - This is the only method here that does anything interesting...
AliasAnalysis::Result Steens::alias(const Value *V1, const Value *V2) {
  assert(ResultGraph && "Result graph has not been computed yet!");

  hash_map<Value*, DSNodeHandle> &GSM = ResultGraph->getScalarMap();

  hash_map<Value*, DSNodeHandle>::iterator I = GSM.find(const_cast<Value*>(V1));
  if (I != GSM.end() && I->second.getNode()) {
    DSNodeHandle &V1H = I->second;
    hash_map<Value*, DSNodeHandle>::iterator J=GSM.find(const_cast<Value*>(V2));
    if (J != GSM.end() && J->second.getNode()) {
      DSNodeHandle &V2H = J->second;
      // If the two pointers point to different data structure graph nodes, they
      // cannot alias!
      if (V1H.getNode() != V2H.getNode())    // FIXME: Handle incompleteness!
        return NoAlias;

      // FIXME: If the two pointers point to the same node, and the offsets are
      // different, and the LinkIndex vector doesn't alias the section, then the
      // two pointers do not alias.  We need access size information for the two
      // accesses though!
      //
    }
  }

  // If we cannot determine alias properties based on our graph, fall back on
  // some other AA implementation.
  //
  return getAnalysis<AliasAnalysis>().alias(V1, V2);
}
