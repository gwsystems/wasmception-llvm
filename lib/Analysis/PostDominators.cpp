//===- PostDominators.cpp - Post-Dominator Calculation --------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file was developed by the LLVM research group and is distributed under
// the University of Illinois Open Source License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the post-dominator construction algorithms.
//
//===----------------------------------------------------------------------===//

#include "llvm/Analysis/PostDominators.h"
#include "llvm/Instructions.h"
#include "llvm/Support/CFG.h"
#include "llvm/ADT/DepthFirstIterator.h"
#include "llvm/ADT/SetOperations.h"
using namespace llvm;

//===----------------------------------------------------------------------===//
//  ImmediatePostDominators Implementation
//===----------------------------------------------------------------------===//

static RegisterPass<ImmediatePostDominators>
D("postidom", "Immediate Post-Dominators Construction", true);

unsigned ImmediatePostDominators::DFSPass(BasicBlock *V, InfoRec &VInfo,
                                          unsigned N) {
  std::vector<std::pair<BasicBlock *, InfoRec *> > workStack;
  std::set<BasicBlock *> visited;
  workStack.push_back(std::make_pair(V, &VInfo));

  do {
    BasicBlock *currentBB = workStack.back().first; 
    InfoRec *currentVInfo = workStack.back().second;

    // Visit each block only once.
    if (visited.count(currentBB) == 0) {

      visited.insert(currentBB);
      currentVInfo->Semi = ++N;
      currentVInfo->Label = currentBB;
      
      Vertex.push_back(currentBB);  // Vertex[n] = current;
      // Info[currentBB].Ancestor = 0;     
      // Ancestor[n] = 0
      // Child[currentBB] = 0;
      currentVInfo->Size = 1;       // Size[currentBB] = 1
    }

    // Visit children
    bool visitChild = false;
    for (pred_iterator PI = pred_begin(currentBB), PE = pred_end(currentBB); 
         PI != PE && !visitChild; ++PI) {
      InfoRec &SuccVInfo = Info[*PI];
      if (SuccVInfo.Semi == 0) {
        SuccVInfo.Parent = currentBB;
        if (visited.count (*PI) == 0) {
          workStack.push_back(std::make_pair(*PI, &SuccVInfo));   
          visitChild = true;
        }
      }
    }

    // If all children are visited or if this block has no child then pop this
    // block out of workStack.
    if (!visitChild)
      workStack.pop_back();

  } while (!workStack.empty());

  return N;
}

void ImmediatePostDominators::Compress(BasicBlock *V, InfoRec &VInfo) {
  BasicBlock *VAncestor = VInfo.Ancestor;
  InfoRec &VAInfo = Info[VAncestor];
  if (VAInfo.Ancestor == 0)
    return;
  
  Compress(VAncestor, VAInfo);
  
  BasicBlock *VAncestorLabel = VAInfo.Label;
  BasicBlock *VLabel = VInfo.Label;
  if (Info[VAncestorLabel].Semi < Info[VLabel].Semi)
    VInfo.Label = VAncestorLabel;
  
  VInfo.Ancestor = VAInfo.Ancestor;
}

BasicBlock *ImmediatePostDominators::Eval(BasicBlock *V) {
  InfoRec &VInfo = Info[V];

  // Higher-complexity but faster implementation
  if (VInfo.Ancestor == 0)
    return V;
  Compress(V, VInfo);
  return VInfo.Label;
}

void ImmediatePostDominators::Link(BasicBlock *V, BasicBlock *W, 
                                   InfoRec &WInfo) {
  // Higher-complexity but faster implementation
  WInfo.Ancestor = V;
}

bool ImmediatePostDominators::runOnFunction(Function &F) {
  IDoms.clear();     // Reset from the last time we were run...
  Roots.clear();

  // Step #0: Scan the function looking for the root nodes of the post-dominance
  // relationships.  These blocks, which have no successors, end with return and
  // unwind instructions.
  for (Function::iterator I = F.begin(), E = F.end(); I != E; ++I)
    if (succ_begin(I) == succ_end(I))
      Roots.push_back(I);
  
  Vertex.push_back(0);
  
  // Step #1: Number blocks in depth-first order and initialize variables used
  // in later stages of the algorithm.
  unsigned N = 0;
  for (unsigned i = 0, e = Roots.size(); i != e; ++i)
    N = DFSPass(Roots[i], Info[Roots[i]], N);
  
  for (unsigned i = N; i >= 2; --i) {
    BasicBlock *W = Vertex[i];
    InfoRec &WInfo = Info[W];
    
    // Step #2: Calculate the semidominators of all vertices
    for (succ_iterator SI = succ_begin(W), SE = succ_end(W); SI != SE; ++SI)
      if (Info.count(*SI)) {  // Only if this predecessor is reachable!
        unsigned SemiU = Info[Eval(*SI)].Semi;
        if (SemiU < WInfo.Semi)
          WInfo.Semi = SemiU;
      }
        
    Info[Vertex[WInfo.Semi]].Bucket.push_back(W);
    
    BasicBlock *WParent = WInfo.Parent;
    Link(WParent, W, WInfo);
    
    // Step #3: Implicitly define the immediate dominator of vertices
    std::vector<BasicBlock*> &WParentBucket = Info[WParent].Bucket;
    while (!WParentBucket.empty()) {
      BasicBlock *V = WParentBucket.back();
      WParentBucket.pop_back();
      BasicBlock *U = Eval(V);
      IDoms[V] = Info[U].Semi < Info[V].Semi ? U : WParent;
    }
  }
  
  // Step #4: Explicitly define the immediate dominator of each vertex
  for (unsigned i = 2; i <= N; ++i) {
    BasicBlock *W = Vertex[i];
    BasicBlock *&WIDom = IDoms[W];
    if (WIDom != Vertex[Info[W].Semi])
      WIDom = IDoms[WIDom];
  }
  
  // Free temporary memory used to construct idom's
  Info.clear();
  std::vector<BasicBlock*>().swap(Vertex);
  
  return false;
}

//===----------------------------------------------------------------------===//
//  PostDominatorSet Implementation
//===----------------------------------------------------------------------===//

static RegisterPass<PostDominatorSet>
B("postdomset", "Post-Dominator Set Construction", true);

// Postdominator set construction.  This converts the specified function to only
// have a single exit node (return stmt), then calculates the post dominance
// sets for the function.
//
bool PostDominatorSet::runOnFunction(Function &F) {
  // Scan the function looking for the root nodes of the post-dominance
  // relationships.  These blocks end with return and unwind instructions.
  // While we are iterating over the function, we also initialize all of the
  // domsets to empty.
  Roots.clear();
  for (Function::iterator I = F.begin(), E = F.end(); I != E; ++I)
    if (succ_begin(I) == succ_end(I))
      Roots.push_back(I);

  // If there are no exit nodes for the function, postdomsets are all empty.
  // This can happen if the function just contains an infinite loop, for
  // example.
  ImmediatePostDominators &IPD = getAnalysis<ImmediatePostDominators>();
  Doms.clear();   // Reset from the last time we were run...
  if (Roots.empty()) return false;

  // If we have more than one root, we insert an artificial "null" exit, which
  // has "virtual edges" to each of the real exit nodes.
  //if (Roots.size() > 1)
  //  Doms[0].insert(0);

  // Root nodes only dominate themselves.
  for (unsigned i = 0, e = Roots.size(); i != e; ++i)
    Doms[Roots[i]].insert(Roots[i]);
  
  // Loop over all of the blocks in the function, calculating dominator sets for
  // each function.
  for (Function::iterator I = F.begin(), E = F.end(); I != E; ++I)
    if (BasicBlock *IPDom = IPD[I]) {   // Get idom if block is reachable
      DomSetType &DS = Doms[I];
      assert(DS.empty() && "PostDomset already filled in for this block?");
      DS.insert(I);  // Blocks always dominate themselves

      // Insert all dominators into the set...
      while (IPDom) {
        // If we have already computed the dominator sets for our immediate post
        // dominator, just use it instead of walking all the way up to the root.
        DomSetType &IPDS = Doms[IPDom];
        if (!IPDS.empty()) {
          DS.insert(IPDS.begin(), IPDS.end());
          break;
        } else {
          DS.insert(IPDom);
          IPDom = IPD[IPDom];
        }
      }
    } else {
      // Ensure that every basic block has at least an empty set of nodes.  This
      // is important for the case when there is unreachable blocks.
      Doms[I];
    }

  return false;
}

//===----------------------------------------------------------------------===//
//  PostDominatorTree Implementation
//===----------------------------------------------------------------------===//

static RegisterPass<PostDominatorTree>
F("postdomtree", "Post-Dominator Tree Construction", true);

DominatorTreeBase::Node *PostDominatorTree::getNodeForBlock(BasicBlock *BB) {
  Node *&BBNode = Nodes[BB];
  if (BBNode) return BBNode;
  
  // Haven't calculated this node yet?  Get or calculate the node for the
  // immediate postdominator.
  BasicBlock *IPDom = getAnalysis<ImmediatePostDominators>()[BB];
  Node *IPDomNode = getNodeForBlock(IPDom);
  
  // Add a new tree node for this BasicBlock, and link it as a child of
  // IDomNode
  return BBNode = IPDomNode->addChild(new Node(BB, IPDomNode));
}

void PostDominatorTree::calculate(const ImmediatePostDominators &IPD) {
  if (Roots.empty()) return;

  // Add a node for the root.  This node might be the actual root, if there is
  // one exit block, or it may be the virtual exit (denoted by (BasicBlock *)0)
  // which postdominates all real exits if there are multiple exit blocks.
  BasicBlock *Root = Roots.size() == 1 ? Roots[0] : 0;
  Nodes[Root] = RootNode = new Node(Root, 0);
  
  Function *F = Roots[0]->getParent();
  // Loop over all of the reachable blocks in the function...
  for (Function::iterator I = F->begin(), E = F->end(); I != E; ++I)
    if (BasicBlock *ImmPostDom = IPD.get(I)) {  // Reachable block.
      Node *&BBNode = Nodes[I];
      if (!BBNode) {  // Haven't calculated this node yet?
                      // Get or calculate the node for the immediate dominator
        Node *IPDomNode = getNodeForBlock(ImmPostDom);
        
        // Add a new tree node for this BasicBlock, and link it as a child of
        // IDomNode
        BBNode = IPDomNode->addChild(new Node(I, IPDomNode));
      }
    }
}

//===----------------------------------------------------------------------===//
// PostETForest Implementation
//===----------------------------------------------------------------------===//

static RegisterPass<PostETForest>
G("postetforest", "Post-ET-Forest Construction", true);

ETNode *PostETForest::getNodeForBlock(BasicBlock *BB) {
  ETNode *&BBNode = Nodes[BB];
  if (BBNode) return BBNode;

  // Haven't calculated this node yet?  Get or calculate the node for the
  // immediate dominator.
  BasicBlock *IDom = getAnalysis<ImmediatePostDominators>()[BB];

  // If we are unreachable, we may not have an immediate dominator.
  if (!IDom)
    return BBNode = new ETNode(BB);
  else {
    ETNode *IDomNode = getNodeForBlock(IDom);
    
    // Add a new tree node for this BasicBlock, and link it as a child of
    // IDomNode
    BBNode = new ETNode(BB);
    BBNode->setFather(IDomNode);
    return BBNode;
  }
}

void PostETForest::calculate(const ImmediatePostDominators &ID) {
  for (unsigned i = 0, e = Roots.size(); i != e; ++i)
    Nodes[Roots[i]] = new ETNode(Roots[i]); // Add a node for the root

  // Iterate over all nodes in inverse depth first order.
  for (unsigned i = 0, e = Roots.size(); i != e; ++i)
    for (idf_iterator<BasicBlock*> I = idf_begin(Roots[i]),
           E = idf_end(Roots[i]); I != E; ++I) {
    BasicBlock *BB = *I;
    ETNode *&BBNode = Nodes[BB];
    if (!BBNode) {  
      ETNode *IDomNode =  NULL;

      if (ID.get(BB))
        IDomNode = getNodeForBlock(ID.get(BB));

      // Add a new ETNode for this BasicBlock, and set it's parent
      // to it's immediate dominator.
      BBNode = new ETNode(BB);
      if (IDomNode)          
        BBNode->setFather(IDomNode);
    }
  }

  int dfsnum = 0;
  // Iterate over all nodes in depth first order...
  for (unsigned i = 0, e = Roots.size(); i != e; ++i)
    for (idf_iterator<BasicBlock*> I = idf_begin(Roots[i]),
           E = idf_end(Roots[i]); I != E; ++I) {
        if (!getNodeForBlock(*I)->hasFather())
          getNodeForBlock(*I)->assignDFSNumber(dfsnum);
    }
  DFSInfoValid = true;
}

//===----------------------------------------------------------------------===//
//  PostDominanceFrontier Implementation
//===----------------------------------------------------------------------===//

static RegisterPass<PostDominanceFrontier>
H("postdomfrontier", "Post-Dominance Frontier Construction", true);

const DominanceFrontier::DomSetType &
PostDominanceFrontier::calculate(const PostDominatorTree &DT,
                                 const DominatorTree::Node *Node) {
  // Loop over CFG successors to calculate DFlocal[Node]
  BasicBlock *BB = Node->getBlock();
  DomSetType &S = Frontiers[BB];       // The new set to fill in...
  if (getRoots().empty()) return S;

  if (BB)
    for (pred_iterator SI = pred_begin(BB), SE = pred_end(BB);
         SI != SE; ++SI)
      // Does Node immediately dominate this predecessor?
      if (DT[*SI]->getIDom() != Node)
        S.insert(*SI);

  // At this point, S is DFlocal.  Now we union in DFup's of our children...
  // Loop through and visit the nodes that Node immediately dominates (Node's
  // children in the IDomTree)
  //
  for (PostDominatorTree::Node::const_iterator
         NI = Node->begin(), NE = Node->end(); NI != NE; ++NI) {
    DominatorTree::Node *IDominee = *NI;
    const DomSetType &ChildDF = calculate(DT, IDominee);

    DomSetType::const_iterator CDFI = ChildDF.begin(), CDFE = ChildDF.end();
    for (; CDFI != CDFE; ++CDFI) {
      if (!Node->properlyDominates(DT[*CDFI]))
        S.insert(*CDFI);
    }
  }

  return S;
}

// Ensure that this .cpp file gets linked when PostDominators.h is used.
DEFINING_FILE_FOR(PostDominanceFrontier)
