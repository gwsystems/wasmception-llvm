//===-- llvm/Metadata.h - Metadata definitions ------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
/// @file
/// This file contains the declarations for metadata subclasses.
/// They represent the different flavors of metadata that live in LLVM.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_METADATA_H
#define LLVM_METADATA_H

#include "llvm/Value.h"
#include "llvm/ADT/ArrayRef.h"
#include "llvm/ADT/FoldingSet.h"
#include "llvm/ADT/ilist_node.h"

namespace llvm {
class Constant;
class Instruction;
class LLVMContext;
class Module;
template <typename T> class SmallVectorImpl;
template<typename ValueSubClass, typename ItemParentClass>
  class SymbolTableListTraits;
  
  
//===----------------------------------------------------------------------===//
/// MDString - a single uniqued string.
/// These are used to efficiently contain a byte sequence for metadata.
/// MDString is always unnamd.
class MDString : public Value {
  MDString(const MDString &);            // DO NOT IMPLEMENT

  StringRef Str;
  explicit MDString(LLVMContext &C, StringRef S);

public:
  static MDString *get(LLVMContext &Context, StringRef Str);
  static MDString *get(LLVMContext &Context, const char *Str) {
    return get(Context, Str ? StringRef(Str) : StringRef());
  }

  StringRef getString() const { return Str; }

  unsigned getLength() const { return (unsigned)Str.size(); }

  typedef StringRef::iterator iterator;
  
  /// begin() - Pointer to the first byte of the string.
  ///
  iterator begin() const { return Str.begin(); }

  /// end() - Pointer to one byte past the end of the string.
  ///
  iterator end() const { return Str.end(); }

  /// Methods for support type inquiry through isa, cast, and dyn_cast:
  static inline bool classof(const MDString *) { return true; }
  static bool classof(const Value *V) {
    return V->getValueID() == MDStringVal;
  }
};

  
class MDNodeOperand;
  
//===----------------------------------------------------------------------===//
/// MDNode - a tuple of other values.
class MDNode : public Value, public FoldingSetNode {
  MDNode(const MDNode &);                // DO NOT IMPLEMENT
  void operator=(const MDNode &);        // DO NOT IMPLEMENT
  friend class MDNodeOperand;
  friend class LLVMContextImpl;

  /// NumOperands - This many 'MDNodeOperand' items are co-allocated onto the
  /// end of this MDNode.
  unsigned NumOperands;
  
  // Subclass data enums.
  enum {
    /// FunctionLocalBit - This bit is set if this MDNode is function local.
    /// This is true when it (potentially transitively) contains a reference to
    /// something in a function, like an argument, basicblock, or instruction.
    FunctionLocalBit = 1 << 0,
    
    /// NotUniquedBit - This is set on MDNodes that are not uniqued because they
    /// have a null operand.
    NotUniquedBit    = 1 << 1,
    
    /// DestroyFlag - This bit is set by destroy() so the destructor can assert
    /// that the node isn't being destroyed with a plain 'delete'.
    DestroyFlag      = 1 << 2
  };
  
  // FunctionLocal enums.
  enum FunctionLocalness {
    FL_Unknown = -1,
    FL_No = 0,
    FL_Yes = 1
  };
  
  /// replaceOperand - Replace each instance of F from the operand list of this 
  /// node with T.
  void replaceOperand(MDNodeOperand *Op, Value *NewVal);
  ~MDNode();

  MDNode(LLVMContext &C, Value *const *Vals, unsigned NumVals,
         bool isFunctionLocal);
  
  static MDNode *getMDNode(LLVMContext &C, Value *const *Vals, unsigned NumVals,
                           FunctionLocalness FL, bool Insert = true);
public:
  // Constructors and destructors.
  static MDNode *get(LLVMContext &Context, ArrayRef<Value*> V);
  // FIXME: Eliminate this constructor form.
  static MDNode *get(LLVMContext &Context, Value *const *Vals,
                     unsigned NumVals);
  // getWhenValsUnresolved - Construct MDNode determining function-localness
  // from isFunctionLocal argument, not by analyzing Vals.
  static MDNode *getWhenValsUnresolved(LLVMContext &Context, Value *const *Vals,
                                       unsigned NumVals, bool isFunctionLocal);
                                       
  static MDNode *getIfExists(LLVMContext &Context, Value *const *Vals,
                             unsigned NumVals);

  /// getTemporary - Return a temporary MDNode, for use in constructing
  /// cyclic MDNode structures. A temporary MDNode is not uniqued,
  /// may be RAUW'd, and must be manually deleted with deleteTemporary.
  static MDNode *getTemporary(LLVMContext &Context, Value *const *Vals,
                              unsigned NumVals);

  /// deleteTemporary - Deallocate a node created by getTemporary. The
  /// node must not have any users.
  static void deleteTemporary(MDNode *N);
  
  /// getOperand - Return specified operand.
  Value *getOperand(unsigned i) const;
  
  /// getNumOperands - Return number of MDNode operands.
  unsigned getNumOperands() const { return NumOperands; }
  
  /// isFunctionLocal - Return whether MDNode is local to a function.
  bool isFunctionLocal() const {
    return (getSubclassDataFromValue() & FunctionLocalBit) != 0;
  }
  
  // getFunction - If this metadata is function-local and recursively has a
  // function-local operand, return the first such operand's parent function.
  // Otherwise, return null. getFunction() should not be used for performance-
  // critical code because it recursively visits all the MDNode's operands.  
  const Function *getFunction() const;

  /// Profile - calculate a unique identifier for this MDNode to collapse
  /// duplicates
  void Profile(FoldingSetNodeID &ID) const;

  /// Methods for support type inquiry through isa, cast, and dyn_cast:
  static inline bool classof(const MDNode *) { return true; }
  static bool classof(const Value *V) {
    return V->getValueID() == MDNodeVal;
  }
private:
  // destroy - Delete this node.  Only when there are no uses.
  void destroy();

  bool isNotUniqued() const { 
    return (getSubclassDataFromValue() & NotUniquedBit) != 0;
  }
  void setIsNotUniqued();
  
  // Shadow Value::setValueSubclassData with a private forwarding method so that
  // any future subclasses cannot accidentally use it.
  void setValueSubclassData(unsigned short D) {
    Value::setValueSubclassData(D);
  }
};

//===----------------------------------------------------------------------===//
/// NamedMDNode - a tuple of MDNodes. Despite its name, a NamedMDNode isn't
/// itself an MDNode. NamedMDNodes belong to modules, have names, and contain
/// lists of MDNodes.
class NamedMDNode : public ilist_node<NamedMDNode> {
  friend class SymbolTableListTraits<NamedMDNode, Module>;
  friend struct ilist_traits<NamedMDNode>;
  friend class LLVMContextImpl;
  friend class Module;
  NamedMDNode(const NamedMDNode &);      // DO NOT IMPLEMENT

  std::string Name;
  Module *Parent;
  void *Operands; // SmallVector<TrackingVH<MDNode>, 4>

  void setParent(Module *M) { Parent = M; }

  explicit NamedMDNode(const Twine &N);

public:
  /// eraseFromParent - Drop all references and remove the node from parent
  /// module.
  void eraseFromParent();

  /// dropAllReferences - Remove all uses and clear node vector.
  void dropAllReferences();

  /// ~NamedMDNode - Destroy NamedMDNode.
  ~NamedMDNode();

  /// getParent - Get the module that holds this named metadata collection.
  inline Module *getParent() { return Parent; }
  inline const Module *getParent() const { return Parent; }

  /// getOperand - Return specified operand.
  MDNode *getOperand(unsigned i) const;
  
  /// getNumOperands - Return the number of NamedMDNode operands.
  unsigned getNumOperands() const;

  /// addOperand - Add metadata operand.
  void addOperand(MDNode *M);

  /// getName - Return a constant reference to this named metadata's name.
  StringRef getName() const;

  /// print - Implement operator<< on NamedMDNode.
  void print(raw_ostream &ROS, AssemblyAnnotationWriter *AAW = 0) const;
};

} // end llvm namespace

#endif
