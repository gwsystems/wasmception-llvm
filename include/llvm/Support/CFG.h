//===-- llvm/Support/CFG.h - Process LLVM structures as graphs --*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines specializations of GraphTraits that allow Function and
// BasicBlock graphs to be treated as proper graphs for generic algorithms.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_SUPPORT_CFG_H
#define LLVM_SUPPORT_CFG_H

#include "llvm/ADT/GraphTraits.h"
#include "llvm/Function.h"
#include "llvm/InstrTypes.h"

namespace llvm {

//===----------------------------------------------------------------------===//
// BasicBlock pred_iterator definition
//===----------------------------------------------------------------------===//

template <class _Ptr,  class _USE_iterator> // Predecessor Iterator
class PredIterator : public std::iterator<std::forward_iterator_tag,
                                          _Ptr, ptrdiff_t> {
  typedef std::iterator<std::forward_iterator_tag, _Ptr, ptrdiff_t> super;
  _USE_iterator It;
public:
  typedef PredIterator<_Ptr,_USE_iterator> _Self;
  typedef typename super::pointer pointer;

  inline void advancePastNonTerminators() {
    // Loop to ignore non terminator uses (for example PHI nodes)...
    while (!It.atEnd() && !isa<TerminatorInst>(*It))
      ++It;
  }

  inline PredIterator(_Ptr *bb) : It(bb->use_begin()) {
    advancePastNonTerminators();
  }
  inline PredIterator(_Ptr *bb, bool) : It(bb->use_end()) {}

  inline bool operator==(const _Self& x) const { return It == x.It; }
  inline bool operator!=(const _Self& x) const { return !operator==(x); }

  inline pointer operator*() const {
    assert(!It.atEnd() && "pred_iterator out of range!");
    return cast<TerminatorInst>(*It)->getParent();
  }
  inline pointer *operator->() const { return &(operator*()); }

  inline _Self& operator++() {   // Preincrement
    assert(!It.atEnd() && "pred_iterator out of range!");
    ++It; advancePastNonTerminators();
    return *this;
  }

  inline _Self operator++(int) { // Postincrement
    _Self tmp = *this; ++*this; return tmp;
  }
};

typedef PredIterator<BasicBlock, Value::use_iterator> pred_iterator;
typedef PredIterator<const BasicBlock,
                     Value::const_use_iterator> pred_const_iterator;

inline pred_iterator pred_begin(BasicBlock *BB) { return pred_iterator(BB); }
inline pred_const_iterator pred_begin(const BasicBlock *BB) {
  return pred_const_iterator(BB);
}
inline pred_iterator pred_end(BasicBlock *BB) { return pred_iterator(BB, true);}
inline pred_const_iterator pred_end(const BasicBlock *BB) {
  return pred_const_iterator(BB, true);
}



//===----------------------------------------------------------------------===//
// BasicBlock succ_iterator definition
//===----------------------------------------------------------------------===//

template <class Term_, class BB_>           // Successor Iterator
class SuccIterator : public std::iterator<std::bidirectional_iterator_tag,
                                          BB_, ptrdiff_t> {
  const Term_ Term;
  unsigned idx;
  typedef std::iterator<std::bidirectional_iterator_tag, BB_, ptrdiff_t> super;
public:
  typedef SuccIterator<Term_, BB_> _Self;
  typedef typename super::pointer pointer;
  // TODO: This can be random access iterator, only operator[] missing.

  inline SuccIterator(Term_ T) : Term(T), idx(0) {         // begin iterator
    assert(T && "getTerminator returned null!");
  }
  inline SuccIterator(Term_ T, bool)                       // end iterator
    : Term(T), idx(Term->getNumSuccessors()) {
    assert(T && "getTerminator returned null!");
  }

  inline const _Self &operator=(const _Self &I) {
    assert(Term == I.Term &&"Cannot assign iterators to two different blocks!");
    idx = I.idx;
    return *this;
  }

  inline bool index_is_valid (int idx) {
    return idx >= 0 && (unsigned) idx < Term->getNumSuccessors();
  }

  /// getSuccessorIndex - This is used to interface between code that wants to
  /// operate on terminator instructions directly.
  unsigned getSuccessorIndex() const { return idx; }

  inline bool operator==(const _Self& x) const { return idx == x.idx; }
  inline bool operator!=(const _Self& x) const { return !operator==(x); }

  inline pointer operator*() const { return Term->getSuccessor(idx); }
  inline pointer operator->() const { return operator*(); }

  inline _Self& operator++() { ++idx; return *this; } // Preincrement

  inline _Self operator++(int) { // Postincrement
    _Self tmp = *this; ++*this; return tmp;
  }

  inline _Self& operator--() { --idx; return *this; }  // Predecrement
  inline _Self operator--(int) { // Postdecrement
    _Self tmp = *this; --*this; return tmp;
  }

  inline bool operator<(const _Self& x) const {
    assert(Term == x.Term && "Cannot compare iterators of different blocks!");
    return idx < x.idx;
  }

  inline bool operator<=(const _Self& x) const {
    assert(Term == x.Term && "Cannot compare iterators of different blocks!");
    return idx <= x.idx;
  }
  inline bool operator>=(const _Self& x) const {
    assert(Term == x.Term && "Cannot compare iterators of different blocks!");
    return idx >= x.idx;
  }

  inline bool operator>(const _Self& x) const {
    assert(Term == x.Term && "Cannot compare iterators of different blocks!");
    return idx > x.idx;
  }

  inline _Self& operator+=(int Right) {
    unsigned new_idx = idx + Right;
    assert(index_is_valid(new_idx) && "Iterator index out of bound");
    idx = new_idx;
    return *this;
  }

  inline _Self operator+(int Right) {
    _Self tmp = *this;
    tmp += Right;
    return tmp;
  }

  inline _Self& operator-=(int Right) {
    return operator+=(-Right);
  }

  inline _Self operator-(int Right) {
    return operator+(-Right);
  }

  inline int operator-(const _Self& x) {
    assert(Term == x.Term && "Cannot work on iterators of different blocks!");
    int distance = idx - x.idx;
    return distance;
  }

  // This works for read access, however write access is difficult as changes
  // to Term are only possible with Term->setSuccessor(idx). Pointers that can
  // be modified are not available.
  //
  // inline pointer operator[](int offset) {
  //  _Self tmp = *this;
  //  tmp += offset;
  //  return tmp.operator*();
  // }

  /// Get the source BB of this iterator.
  inline BB_ *getSource() {
      return Term->getParent();
  }
};

typedef SuccIterator<TerminatorInst*, BasicBlock> succ_iterator;
typedef SuccIterator<const TerminatorInst*,
                     const BasicBlock> succ_const_iterator;

inline succ_iterator succ_begin(BasicBlock *BB) {
  return succ_iterator(BB->getTerminator());
}
inline succ_const_iterator succ_begin(const BasicBlock *BB) {
  return succ_const_iterator(BB->getTerminator());
}
inline succ_iterator succ_end(BasicBlock *BB) {
  return succ_iterator(BB->getTerminator(), true);
}
inline succ_const_iterator succ_end(const BasicBlock *BB) {
  return succ_const_iterator(BB->getTerminator(), true);
}



//===--------------------------------------------------------------------===//
// GraphTraits specializations for basic block graphs (CFGs)
//===--------------------------------------------------------------------===//

// Provide specializations of GraphTraits to be able to treat a function as a
// graph of basic blocks...

template <> struct GraphTraits<BasicBlock*> {
  typedef BasicBlock NodeType;
  typedef succ_iterator ChildIteratorType;

  static NodeType *getEntryNode(BasicBlock *BB) { return BB; }
  static inline ChildIteratorType child_begin(NodeType *N) {
    return succ_begin(N);
  }
  static inline ChildIteratorType child_end(NodeType *N) {
    return succ_end(N);
  }
};

template <> struct GraphTraits<const BasicBlock*> {
  typedef const BasicBlock NodeType;
  typedef succ_const_iterator ChildIteratorType;

  static NodeType *getEntryNode(const BasicBlock *BB) { return BB; }

  static inline ChildIteratorType child_begin(NodeType *N) {
    return succ_begin(N);
  }
  static inline ChildIteratorType child_end(NodeType *N) {
    return succ_end(N);
  }
};

// Provide specializations of GraphTraits to be able to treat a function as a
// graph of basic blocks... and to walk it in inverse order.  Inverse order for
// a function is considered to be when traversing the predecessor edges of a BB
// instead of the successor edges.
//
template <> struct GraphTraits<Inverse<BasicBlock*> > {
  typedef BasicBlock NodeType;
  typedef pred_iterator ChildIteratorType;
  static NodeType *getEntryNode(Inverse<BasicBlock *> G) { return G.Graph; }
  static inline ChildIteratorType child_begin(NodeType *N) {
    return pred_begin(N);
  }
  static inline ChildIteratorType child_end(NodeType *N) {
    return pred_end(N);
  }
};

template <> struct GraphTraits<Inverse<const BasicBlock*> > {
  typedef const BasicBlock NodeType;
  typedef pred_const_iterator ChildIteratorType;
  static NodeType *getEntryNode(Inverse<const BasicBlock*> G) {
    return G.Graph;
  }
  static inline ChildIteratorType child_begin(NodeType *N) {
    return pred_begin(N);
  }
  static inline ChildIteratorType child_end(NodeType *N) {
    return pred_end(N);
  }
};



//===--------------------------------------------------------------------===//
// GraphTraits specializations for function basic block graphs (CFGs)
//===--------------------------------------------------------------------===//

// Provide specializations of GraphTraits to be able to treat a function as a
// graph of basic blocks... these are the same as the basic block iterators,
// except that the root node is implicitly the first node of the function.
//
template <> struct GraphTraits<Function*> : public GraphTraits<BasicBlock*> {
  static NodeType *getEntryNode(Function *F) { return &F->getEntryBlock(); }

  // nodes_iterator/begin/end - Allow iteration over all nodes in the graph
  typedef Function::iterator nodes_iterator;
  static nodes_iterator nodes_begin(Function *F) { return F->begin(); }
  static nodes_iterator nodes_end  (Function *F) { return F->end(); }
};
template <> struct GraphTraits<const Function*> :
  public GraphTraits<const BasicBlock*> {
  static NodeType *getEntryNode(const Function *F) {return &F->getEntryBlock();}

  // nodes_iterator/begin/end - Allow iteration over all nodes in the graph
  typedef Function::const_iterator nodes_iterator;
  static nodes_iterator nodes_begin(const Function *F) { return F->begin(); }
  static nodes_iterator nodes_end  (const Function *F) { return F->end(); }
};


// Provide specializations of GraphTraits to be able to treat a function as a
// graph of basic blocks... and to walk it in inverse order.  Inverse order for
// a function is considered to be when traversing the predecessor edges of a BB
// instead of the successor edges.
//
template <> struct GraphTraits<Inverse<Function*> > :
  public GraphTraits<Inverse<BasicBlock*> > {
  static NodeType *getEntryNode(Inverse<Function*> G) {
    return &G.Graph->getEntryBlock();
  }
};
template <> struct GraphTraits<Inverse<const Function*> > :
  public GraphTraits<Inverse<const BasicBlock*> > {
  static NodeType *getEntryNode(Inverse<const Function *> G) {
    return &G.Graph->getEntryBlock();
  }
};

} // End llvm namespace

#endif
