//===- Support/DepthFirstIterator.h - Depth First iterator ------*- C++ -*-===//
//
// This file builds on the Support/GraphTraits.h file to build generic depth
// first graph iterator.  This file exposes the following functions/types:
//
// df_begin/df_end/df_iterator
//   * Normal depth-first iteration - visit a node and then all of its children.
//
// idf_begin/idf_end/idf_iterator
//   * Depth-first iteration on the 'inverse' graph.
//
//===----------------------------------------------------------------------===//

#ifndef SUPPORT_DEPTHFIRSTITERATOR_H
#define SUPPORT_DEPTHFIRSTITERATOR_H

#include "Support/GraphTraits.h"
#include "Support/iterator"
#include <vector>
#include <set>

// Generic Depth First Iterator
template<class GraphT, class GT = GraphTraits<GraphT> >
class df_iterator : public forward_iterator<typename GT::NodeType, ptrdiff_t> {
  typedef forward_iterator<typename GT::NodeType, ptrdiff_t> super;

  typedef typename GT::NodeType          NodeType;
  typedef typename GT::ChildIteratorType ChildItTy;

  std::set<NodeType *> Visited;    // All of the blocks visited so far...
  // VisitStack - Used to maintain the ordering.  Top = current block
  // First element is node pointer, second is the 'next child' to visit
  std::vector<std::pair<NodeType *, ChildItTy> > VisitStack;
private:
  inline df_iterator(NodeType *Node) {
    Visited.insert(Node);
    VisitStack.push_back(std::make_pair(Node, GT::child_begin(Node)));
  }
  inline df_iterator() { /* End is when stack is empty */ }

public:
  typedef typename super::pointer pointer;
  typedef df_iterator<GraphT, GT> _Self;

  // Provide static begin and end methods as our public "constructors"
  static inline _Self begin(GraphT G) {
    return _Self(GT::getEntryNode(G));
  }
  static inline _Self end(GraphT G) { return _Self(); }


  inline bool operator==(const _Self& x) const { 
    return VisitStack.size() == x.VisitStack.size() &&
           VisitStack == x.VisitStack;
  }
  inline bool operator!=(const _Self& x) const { return !operator==(x); }

  inline pointer operator*() const { 
    return VisitStack.back().first;
  }

  // This is a nonstandard operator-> that dereferences the pointer an extra
  // time... so that you can actually call methods ON the Node, because
  // the contained type is a pointer.  This allows BBIt->getTerminator() f.e.
  //
  inline NodeType *operator->() const { return operator*(); }

  inline _Self& operator++() {   // Preincrement
    do {
      std::pair<NodeType *, ChildItTy> &Top = VisitStack.back();
      NodeType *Node = Top.first;
      ChildItTy &It  = Top.second;
      
      while (It != GT::child_end(Node)) {
        NodeType *Next = *It++;
        if (!Visited.count(Next)) {  // Has our next sibling been visited?
          // No, do it now.
          Visited.insert(Next);
          VisitStack.push_back(std::make_pair(Next, GT::child_begin(Next)));
          return *this;
        }
      }
      
      // Oops, ran out of successors... go up a level on the stack.
      VisitStack.pop_back();
    } while (!VisitStack.empty());
    return *this; 
  }

  inline _Self operator++(int) { // Postincrement
    _Self tmp = *this; ++*this; return tmp; 
  }

  // nodeVisited - return true if this iterator has already visited the
  // specified node.  This is public, and will probably be used to iterate over
  // nodes that a depth first iteration did not find: ie unreachable nodes.
  //
  inline bool nodeVisited(NodeType *Node) const { 
    return Visited.count(Node) != 0;
  }
};


// Provide global constructors that automatically figure out correct types...
//
template <class T>
df_iterator<T> df_begin(T G) {
  return df_iterator<T>::begin(G);
}

template <class T>
df_iterator<T> df_end(T G) {
  return df_iterator<T>::end(G);
}

// Provide global definitions of inverse depth first iterators...
template <class T>
struct idf_iterator : public df_iterator<Inverse<T> > {
  idf_iterator(const df_iterator<Inverse<T> > &V) :df_iterator<Inverse<T> >(V){}
};

template <class T>
idf_iterator<T> idf_begin(T G) {
  return idf_iterator<T>::begin(G);
}

template <class T>
idf_iterator<T> idf_end(T G){
  return idf_iterator<T>::end(G);
}

#endif
