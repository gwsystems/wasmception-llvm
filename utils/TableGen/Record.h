//===- Record.h - Classes to represent Table Records ------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines the main TableGen data structures, including the TableGen
// types, values, and high-level data structures.
//
//===----------------------------------------------------------------------===//

#ifndef RECORD_H
#define RECORD_H

#include "llvm/ADT/FoldingSet.h"
#include "llvm/Support/Allocator.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/DataTypes.h"
#include "llvm/Support/raw_ostream.h"
#include <map>

namespace llvm {
class raw_ostream;

// RecTy subclasses.
class BitRecTy;
class BitsRecTy;
class IntRecTy;
class StringRecTy;
class ListRecTy;
class CodeRecTy;
class DagRecTy;
class RecordRecTy;

// Init subclasses.
class Init;
class UnsetInit;
class BitInit;
class BitsInit;
class IntInit;
class StringInit;
class CodeInit;
class ListInit;
class UnOpInit;
class BinOpInit;
class TernOpInit;
class DefInit;
class DagInit;
class TypedInit;
class VarInit;
class FieldInit;
class VarBitInit;
class VarListElementInit;

// Other classes.
class Record;
class RecordVal;
struct MultiClass;
class RecordKeeper;

//===----------------------------------------------------------------------===//
//  Type Classes
//===----------------------------------------------------------------------===//

struct RecTy {
  virtual ~RecTy() {}

  virtual std::string getAsString() const = 0;
  void print(raw_ostream &OS) const { OS << getAsString(); }
  void dump() const;

  /// typeIsConvertibleTo - Return true if all values of 'this' type can be
  /// converted to the specified type.
  virtual bool typeIsConvertibleTo(const RecTy *RHS) const = 0;

public:   // These methods should only be called from subclasses of Init
  virtual const Init *convertValue(const  UnsetInit *UI) { return 0; }
  virtual const Init *convertValue(const    BitInit *BI) { return 0; }
  virtual const Init *convertValue(const   BitsInit *BI) { return 0; }
  virtual const Init *convertValue(const    IntInit *II) { return 0; }
  virtual const Init *convertValue(const StringInit *SI) { return 0; }
  virtual const Init *convertValue(const   ListInit *LI) { return 0; }
  virtual const Init *convertValue(const   UnOpInit *UI) {
    return convertValue((const TypedInit*)UI);
  }
  virtual const Init *convertValue(const  BinOpInit *UI) {
    return convertValue((const TypedInit*)UI);
  }
  virtual const Init *convertValue(const TernOpInit *UI) {
    return convertValue((const TypedInit*)UI);
  }
  virtual const Init *convertValue(const   CodeInit *CI) { return 0; }
  virtual const Init *convertValue(const VarBitInit *VB) { return 0; }
  virtual const Init *convertValue(const    DefInit *DI) { return 0; }
  virtual const Init *convertValue(const    DagInit *DI) { return 0; }
  virtual const Init *convertValue(const  TypedInit *TI) { return 0; }
  virtual const Init *convertValue(const    VarInit *VI) {
    return convertValue((const TypedInit*)VI);
  }
  virtual const Init *convertValue(const  FieldInit *FI) {
    return convertValue((const TypedInit*)FI);
  }

public:   // These methods should only be called by subclasses of RecTy.
  // baseClassOf - These virtual methods should be overloaded to return true iff
  // all values of type 'RHS' can be converted to the 'this' type.
  virtual bool baseClassOf(const BitRecTy    *RHS) const { return false; }
  virtual bool baseClassOf(const BitsRecTy   *RHS) const { return false; }
  virtual bool baseClassOf(const IntRecTy    *RHS) const { return false; }
  virtual bool baseClassOf(const StringRecTy *RHS) const { return false; }
  virtual bool baseClassOf(const ListRecTy   *RHS) const { return false; }
  virtual bool baseClassOf(const CodeRecTy   *RHS) const { return false; }
  virtual bool baseClassOf(const DagRecTy    *RHS) const { return false; }
  virtual bool baseClassOf(const RecordRecTy *RHS) const { return false; }
};

inline raw_ostream &operator<<(raw_ostream &OS, const RecTy &Ty) {
  Ty.print(OS);
  return OS;
}


/// BitRecTy - 'bit' - Represent a single bit
///
class BitRecTy : public RecTy {
public:
  virtual const Init *convertValue(const  UnsetInit *UI) {
    return (const Init*)UI;
  }
  virtual const Init *convertValue(const    BitInit *BI) {
    return (const Init*)BI;
  }
  virtual const Init *convertValue(const   BitsInit *BI);
  virtual const Init *convertValue(const    IntInit *II);
  virtual const Init *convertValue(const StringInit *SI) { return 0; }
  virtual const Init *convertValue(const   ListInit *LI) { return 0; }
  virtual const Init *convertValue(const   CodeInit *CI) { return 0; }
  virtual const Init *convertValue(const VarBitInit *VB) {
    return (const Init*)VB;
  }
  virtual const Init *convertValue(const    DefInit *DI) { return 0; }
  virtual const Init *convertValue(const    DagInit *DI) { return 0; }
  virtual const Init *convertValue(const   UnOpInit *UI) {
    return RecTy::convertValue(UI);
  }
  virtual const Init *convertValue(const  BinOpInit *UI) {
    return RecTy::convertValue(UI);
  }
  virtual const Init *convertValue(const TernOpInit *UI) {
    return RecTy::convertValue(UI);
  }
  virtual const Init *convertValue(const  TypedInit *TI);
  virtual const Init *convertValue(const    VarInit *VI) {
    return RecTy::convertValue(VI);
  }
  virtual const Init *convertValue(const  FieldInit *FI) {
    return RecTy::convertValue(FI);
  }

  std::string getAsString() const { return "bit"; }

  bool typeIsConvertibleTo(const RecTy *RHS) const {
    return RHS->baseClassOf(this);
  }
  virtual bool baseClassOf(const BitRecTy    *RHS) const { return true; }
  virtual bool baseClassOf(const BitsRecTy   *RHS) const;
  virtual bool baseClassOf(const IntRecTy    *RHS) const { return true; }
  virtual bool baseClassOf(const StringRecTy *RHS) const { return false; }
  virtual bool baseClassOf(const ListRecTy   *RHS) const { return false; }
  virtual bool baseClassOf(const CodeRecTy   *RHS) const { return false; }
  virtual bool baseClassOf(const DagRecTy    *RHS) const { return false; }
  virtual bool baseClassOf(const RecordRecTy *RHS) const { return false; }

};


// BitsRecTy - 'bits<n>' - Represent a fixed number of bits
/// BitsRecTy - 'bits&lt;n&gt;' - Represent a fixed number of bits
///
class BitsRecTy : public RecTy {
  unsigned Size;
public:
  explicit BitsRecTy(unsigned Sz) : Size(Sz) {}

  unsigned getNumBits() const { return Size; }

  virtual const Init *convertValue(const  UnsetInit *UI);
  virtual const Init *convertValue(const    BitInit *UI);
  virtual const Init *convertValue(const   BitsInit *BI);
  virtual const Init *convertValue(const    IntInit *II);
  virtual const Init *convertValue(const StringInit *SI) { return 0; }
  virtual const Init *convertValue(const   ListInit *LI) { return 0; }
  virtual const Init *convertValue(const   CodeInit *CI) { return 0; }
  virtual const Init *convertValue(const VarBitInit *VB) { return 0; }
  virtual const Init *convertValue(const    DefInit *DI) { return 0; }
  virtual const Init *convertValue(const    DagInit *DI) { return 0; }
  virtual const Init *convertValue(const   UnOpInit *UI) {
    return RecTy::convertValue(UI);
  }
  virtual const Init *convertValue(const  BinOpInit *UI) {
    return RecTy::convertValue(UI);
  }
  virtual const Init *convertValue(const TernOpInit *UI) {
    return RecTy::convertValue(UI);
  }
  virtual const Init *convertValue(const  TypedInit *TI);
  virtual const Init *convertValue(const    VarInit *VI) {
    return RecTy::convertValue(VI);
  }
  virtual const Init *convertValue(const  FieldInit *FI) {
    return RecTy::convertValue(FI);
  }

  std::string getAsString() const;

  bool typeIsConvertibleTo(const RecTy *RHS) const {
    return RHS->baseClassOf(this);
  }
  virtual bool baseClassOf(const BitRecTy    *RHS) const { return Size == 1; }
  virtual bool baseClassOf(const BitsRecTy   *RHS) const {
    return RHS->Size == Size;
  }
  virtual bool baseClassOf(const IntRecTy    *RHS) const { return true; }
  virtual bool baseClassOf(const StringRecTy *RHS) const { return false; }
  virtual bool baseClassOf(const ListRecTy   *RHS) const { return false; }
  virtual bool baseClassOf(const CodeRecTy   *RHS) const { return false; }
  virtual bool baseClassOf(const DagRecTy    *RHS) const { return false; }
  virtual bool baseClassOf(const RecordRecTy *RHS) const { return false; }

};


/// IntRecTy - 'int' - Represent an integer value of no particular size
///
class IntRecTy : public RecTy {
public:
  virtual const Init *convertValue(const  UnsetInit *UI) {
    return (const Init*)UI;
  }
  virtual const Init *convertValue(const    BitInit *BI);
  virtual const Init *convertValue(const   BitsInit *BI);
  virtual const Init *convertValue(const    IntInit *II) {
    return (const Init*)II;
  }
  virtual const Init *convertValue(const StringInit *SI) { return 0; }
  virtual const Init *convertValue(const   ListInit *LI) { return 0; }
  virtual const Init *convertValue(const   CodeInit *CI) { return 0; }
  virtual const Init *convertValue(const VarBitInit *VB) { return 0; }
  virtual const Init *convertValue(const    DefInit *DI) { return 0; }
  virtual const Init *convertValue(const    DagInit *DI) { return 0; }
  virtual const Init *convertValue(const  UnOpInit *UI) {
    return RecTy::convertValue(UI);
  }
  virtual const Init *convertValue(const  BinOpInit *UI) {
    return RecTy::convertValue(UI);
  }
  virtual const Init *convertValue(const  TernOpInit *UI) {
    return RecTy::convertValue(UI);
  }
  virtual const Init *convertValue(const  TypedInit *TI);
  virtual const Init *convertValue(const    VarInit *VI) {
    return RecTy::convertValue(VI);
  }
  virtual const Init *convertValue(const  FieldInit *FI) {
    return RecTy::convertValue(FI);
  }

  std::string getAsString() const { return "int"; }

  bool typeIsConvertibleTo(const RecTy *RHS) const {
    return RHS->baseClassOf(this);
  }

  virtual bool baseClassOf(const BitRecTy    *RHS) const { return true; }
  virtual bool baseClassOf(const BitsRecTy   *RHS) const { return true; }
  virtual bool baseClassOf(const IntRecTy    *RHS) const { return true; }
  virtual bool baseClassOf(const StringRecTy *RHS) const { return false; }
  virtual bool baseClassOf(const ListRecTy   *RHS) const { return false; }
  virtual bool baseClassOf(const CodeRecTy   *RHS) const { return false; }
  virtual bool baseClassOf(const DagRecTy    *RHS) const { return false; }
  virtual bool baseClassOf(const RecordRecTy *RHS) const { return false; }

};

/// StringRecTy - 'string' - Represent an string value
///
class StringRecTy : public RecTy {
public:
  virtual const Init *convertValue(const  UnsetInit *UI) {
    return (const Init*)UI;
  }
  virtual const Init *convertValue(const    BitInit *BI) { return 0; }
  virtual const Init *convertValue(const   BitsInit *BI) { return 0; }
  virtual const Init *convertValue(const    IntInit *II) { return 0; }
  virtual const Init *convertValue(const StringInit *SI) {
    return (const Init*)SI;
  }
  virtual const Init *convertValue(const   ListInit *LI) { return 0; }
  virtual const Init *convertValue(const   UnOpInit *BO);
  virtual const Init *convertValue(const  BinOpInit *BO);
  virtual const Init *convertValue(const TernOpInit *BO) {
    return RecTy::convertValue(BO);
  }

  virtual const Init *convertValue(const   CodeInit *CI) { return 0; }
  virtual const Init *convertValue(const VarBitInit *VB) { return 0; }
  virtual const Init *convertValue(const    DefInit *DI) { return 0; }
  virtual const Init *convertValue(const    DagInit *DI) { return 0; }
  virtual const Init *convertValue(const  TypedInit *TI);
  virtual const Init *convertValue(const    VarInit *VI) {
    return RecTy::convertValue(VI);
  }
  virtual const Init *convertValue(const  FieldInit *FI) {
    return RecTy::convertValue(FI);
  }

  std::string getAsString() const { return "string"; }

  bool typeIsConvertibleTo(const RecTy *RHS) const {
    return RHS->baseClassOf(this);
  }

  virtual bool baseClassOf(const BitRecTy    *RHS) const { return false; }
  virtual bool baseClassOf(const BitsRecTy   *RHS) const { return false; }
  virtual bool baseClassOf(const IntRecTy    *RHS) const { return false; }
  virtual bool baseClassOf(const StringRecTy *RHS) const { return true; }
  virtual bool baseClassOf(const ListRecTy   *RHS) const { return false; }
  virtual bool baseClassOf(const CodeRecTy   *RHS) const { return false; }
  virtual bool baseClassOf(const DagRecTy    *RHS) const { return false; }
  virtual bool baseClassOf(const RecordRecTy *RHS) const { return false; }
};

// ListRecTy - 'list<Ty>' - Represent a list of values, all of which must be of
// the specified type.
/// ListRecTy - 'list&lt;Ty&gt;' - Represent a list of values, all of which must
/// be of the specified type.
///
class ListRecTy : public RecTy {
  RecTy *Ty;
public:
  explicit ListRecTy(RecTy *T) : Ty(T) {}

  RecTy *getElementType() const { return Ty; }

  virtual const Init *convertValue(const  UnsetInit *UI) {
    return (const Init*)UI;
  }
  virtual const Init *convertValue(const    BitInit *BI) { return 0; }
  virtual const Init *convertValue(const   BitsInit *BI) { return 0; }
  virtual const Init *convertValue(const    IntInit *II) { return 0; }
  virtual const Init *convertValue(const StringInit *SI) { return 0; }
  virtual const Init *convertValue(const   ListInit *LI);
  virtual const Init *convertValue(const   CodeInit *CI) { return 0; }
  virtual const Init *convertValue(const VarBitInit *VB) { return 0; }
  virtual const Init *convertValue(const    DefInit *DI) { return 0; }
  virtual const Init *convertValue(const    DagInit *DI) { return 0; }
  virtual const Init *convertValue(const  UnOpInit *UI) {
    return RecTy::convertValue(UI);
  }
  virtual const Init *convertValue(const  BinOpInit *UI) {
    return RecTy::convertValue(UI);
  }
  virtual const Init *convertValue(const  TernOpInit *UI) {
    return RecTy::convertValue(UI);
  }
  virtual const Init *convertValue(const  TypedInit *TI);
  virtual const Init *convertValue(const    VarInit *VI) {
    return RecTy::convertValue(VI);
  }
  virtual const Init *convertValue(const  FieldInit *FI) {
    return RecTy::convertValue(FI);
  }

  std::string getAsString() const;

  bool typeIsConvertibleTo(const RecTy *RHS) const {
    return RHS->baseClassOf(this);
  }

  virtual bool baseClassOf(const BitRecTy    *RHS) const { return false; }
  virtual bool baseClassOf(const BitsRecTy   *RHS) const { return false; }
  virtual bool baseClassOf(const IntRecTy    *RHS) const { return false; }
  virtual bool baseClassOf(const StringRecTy *RHS) const { return false; }
  virtual bool baseClassOf(const ListRecTy   *RHS) const {
    return RHS->getElementType()->typeIsConvertibleTo(Ty);
  }
  virtual bool baseClassOf(const CodeRecTy   *RHS) const { return false; }
  virtual bool baseClassOf(const DagRecTy    *RHS) const { return false; }
  virtual bool baseClassOf(const RecordRecTy *RHS) const { return false; }
};

/// CodeRecTy - 'code' - Represent an code fragment, function or method.
///
class CodeRecTy : public RecTy {
public:
  virtual const Init *convertValue(const  UnsetInit *UI) {
    return (const Init*)UI;
  }
  virtual const Init *convertValue(const    BitInit *BI) { return 0; }
  virtual const Init *convertValue(const   BitsInit *BI) { return 0; }
  virtual const Init *convertValue(const    IntInit *II) { return 0; }
  virtual const Init *convertValue(const StringInit *SI) { return 0; }
  virtual const Init *convertValue(const   ListInit *LI) { return 0; }
  virtual const Init *convertValue(const   CodeInit *CI) {
    return (const Init*)CI;
  }
  virtual const Init *convertValue(const VarBitInit *VB) { return 0; }
  virtual const Init *convertValue(const    DefInit *DI) { return 0; }
  virtual const Init *convertValue(const    DagInit *DI) { return 0; }
  virtual const Init *convertValue(const  UnOpInit *UI) {
    return RecTy::convertValue(UI);
  }
  virtual const Init *convertValue(const  BinOpInit *UI) {
    return RecTy::convertValue(UI);
  }
  virtual const Init *convertValue(const  TernOpInit *UI) {
    return RecTy::convertValue(UI);
  }
  virtual const Init *convertValue(const  TypedInit *TI);
  virtual const Init *convertValue(const    VarInit *VI) {
    return RecTy::convertValue(VI);
  }
  virtual const Init *convertValue(const  FieldInit *FI) {
    return RecTy::convertValue(FI);
  }

  std::string getAsString() const { return "code"; }

  bool typeIsConvertibleTo(const RecTy *RHS) const {
    return RHS->baseClassOf(this);
  }
  virtual bool baseClassOf(const BitRecTy    *RHS) const { return false; }
  virtual bool baseClassOf(const BitsRecTy   *RHS) const { return false; }
  virtual bool baseClassOf(const IntRecTy    *RHS) const { return false; }
  virtual bool baseClassOf(const StringRecTy *RHS) const { return false; }
  virtual bool baseClassOf(const ListRecTy   *RHS) const { return false; }
  virtual bool baseClassOf(const CodeRecTy   *RHS) const { return true; }
  virtual bool baseClassOf(const DagRecTy    *RHS) const { return false; }
  virtual bool baseClassOf(const RecordRecTy *RHS) const { return false; }
};

/// DagRecTy - 'dag' - Represent a dag fragment
///
class DagRecTy : public RecTy {
public:
  virtual const Init *convertValue(const  UnsetInit *UI) {
    return (const Init*)UI;
  }
  virtual const Init *convertValue(const    BitInit *BI) { return 0; }
  virtual const Init *convertValue(const   BitsInit *BI) { return 0; }
  virtual const Init *convertValue(const    IntInit *II) { return 0; }
  virtual const Init *convertValue(const StringInit *SI) { return 0; }
  virtual const Init *convertValue(const   ListInit *LI) { return 0; }
  virtual const Init *convertValue(const   CodeInit *CI) { return 0; }
  virtual const Init *convertValue(const VarBitInit *VB) { return 0; }
  virtual const Init *convertValue(const    DefInit *DI) { return 0; }
  virtual const Init *convertValue(const  UnOpInit *BO);
  virtual const Init *convertValue(const  BinOpInit *BO);
  virtual const Init *convertValue(const  TernOpInit *BO) {
    return RecTy::convertValue(BO);
  }
  virtual const Init *convertValue(const    DagInit *CI) {
    return (const Init*)CI;
  }
  virtual const Init *convertValue(const  TypedInit *TI);
  virtual const Init *convertValue(const    VarInit *VI) {
    return RecTy::convertValue(VI);
  }
  virtual const Init *convertValue(const  FieldInit *FI) {
    return RecTy::convertValue(FI);
  }

  std::string getAsString() const { return "dag"; }

  bool typeIsConvertibleTo(const RecTy *RHS) const {
    return RHS->baseClassOf(this);
  }

  virtual bool baseClassOf(const BitRecTy    *RHS) const { return false; }
  virtual bool baseClassOf(const BitsRecTy   *RHS) const { return false; }
  virtual bool baseClassOf(const IntRecTy    *RHS) const { return false; }
  virtual bool baseClassOf(const StringRecTy *RHS) const { return false; }
  virtual bool baseClassOf(const ListRecTy   *RHS) const { return false; }
  virtual bool baseClassOf(const CodeRecTy   *RHS) const { return false; }
  virtual bool baseClassOf(const DagRecTy    *RHS) const { return true; }
  virtual bool baseClassOf(const RecordRecTy *RHS) const { return false; }
};


/// RecordRecTy - '[classname]' - Represent an instance of a class, such as:
/// (R32 X = EAX).
///
class RecordRecTy : public RecTy {
  Record *Rec;
public:
  explicit RecordRecTy(Record *R) : Rec(R) {}

  Record *getRecord() const { return Rec; }

  virtual const Init *convertValue(const  UnsetInit *UI) {
    return (const Init*)UI;
  }
  virtual const Init *convertValue(const    BitInit *BI) { return 0; }
  virtual const Init *convertValue(const   BitsInit *BI) { return 0; }
  virtual const Init *convertValue(const    IntInit *II) { return 0; }
  virtual const Init *convertValue(const StringInit *SI) { return 0; }
  virtual const Init *convertValue(const   ListInit *LI) { return 0; }
  virtual const Init *convertValue(const   CodeInit *CI) { return 0; }
  virtual const Init *convertValue(const VarBitInit *VB) { return 0; }
  virtual const Init *convertValue(const  UnOpInit *UI) {
    return RecTy::convertValue(UI);
  }
  virtual const Init *convertValue(const  BinOpInit *UI) {
    return RecTy::convertValue(UI);
  }
  virtual const Init *convertValue(const  TernOpInit *UI) {
    return RecTy::convertValue(UI);
  }
  virtual const Init *convertValue(const    DefInit *DI);
  virtual const Init *convertValue(const    DagInit *DI) { return 0; }
  virtual const Init *convertValue(const  TypedInit *VI);
  virtual const Init *convertValue(const    VarInit *VI) {
    return RecTy::convertValue(VI);
  }
  virtual const Init *convertValue(const  FieldInit *FI) {
    return RecTy::convertValue(FI);
  }

  std::string getAsString() const;

  bool typeIsConvertibleTo(const RecTy *RHS) const {
    return RHS->baseClassOf(this);
  }
  virtual bool baseClassOf(const BitRecTy    *RHS) const { return false; }
  virtual bool baseClassOf(const BitsRecTy   *RHS) const { return false; }
  virtual bool baseClassOf(const IntRecTy    *RHS) const { return false; }
  virtual bool baseClassOf(const StringRecTy *RHS) const { return false; }
  virtual bool baseClassOf(const ListRecTy   *RHS) const { return false; }
  virtual bool baseClassOf(const CodeRecTy   *RHS) const { return false; }
  virtual bool baseClassOf(const DagRecTy    *RHS) const { return false; }
  virtual bool baseClassOf(const RecordRecTy *RHS) const;
};

/// resolveTypes - Find a common type that T1 and T2 convert to.
/// Return 0 if no such type exists.
///
RecTy *resolveTypes(RecTy *T1, RecTy *T2);

//===----------------------------------------------------------------------===//
//  Initializer Classes
//===----------------------------------------------------------------------===//

class Init : public FastFoldingSetNode {
  Init(const Init &);  // Do not define.
  Init &operator=(const Init &);  // Do not define.

protected:
  Init(const FoldingSetNodeID &ID) : FastFoldingSetNode(ID) {}

  static FoldingSet<Init> UniqueInits;
  static BumpPtrAllocator InitAllocator;

  enum Type {
    initUnset,
    initBit,
    initBits,
    initInt,
    initString,
    initCode,
    initList,
    initUnOp,
    initBinOp,
    initTernOp,
    initQuadOp,
    initVar,
    initVarBit,
    initVarListElement,
    initDef,
    initField,
    initDag
  };

public:
  virtual ~Init() {}

  static void ReleaseMemory() {
    InitAllocator.Reset();
  }

  /// isComplete - This virtual method should be overridden by values that may
  /// not be completely specified yet.
  virtual bool isComplete() const { return true; }

  /// print - Print out this value.
  void print(raw_ostream &OS) const { OS << getAsString(); }

  /// getAsString - Convert this value to a string form.
  virtual std::string getAsString() const = 0;

  /// dump - Debugging method that may be called through a debugger, just
  /// invokes print on stderr.
  void dump() const;

  /// convertInitializerTo - This virtual function is a simple call-back
  /// function that should be overridden to call the appropriate
  /// RecTy::convertValue method.
  ///
  virtual const Init *convertInitializerTo(RecTy *Ty) const = 0;

  /// convertInitializerBitRange - This method is used to implement the bitrange
  /// selection operator.  Given an initializer, it selects the specified bits
  /// out, returning them as a new init of bits type.  If it is not legal to use
  /// the bit subscript operator on this initializer, return null.
  ///
  virtual const Init *
  convertInitializerBitRange(const std::vector<unsigned> &Bits) const {
    return 0;
  }

  /// convertInitListSlice - This method is used to implement the list slice
  /// selection operator.  Given an initializer, it selects the specified list
  /// elements, returning them as a new init of list type.  If it is not legal
  /// to take a slice of this, return null.
  ///
  virtual const Init *
  convertInitListSlice(const std::vector<unsigned> &Elements) const {
    return 0;
  }

  /// getFieldType - This method is used to implement the FieldInit class.
  /// Implementors of this method should return the type of the named field if
  /// they are of record type.
  ///
  virtual RecTy *getFieldType(const std::string &FieldName) const { return 0; }

  /// getFieldInit - This method complements getFieldType to return the
  /// initializer for the specified field.  If getFieldType returns non-null
  /// this method should return non-null, otherwise it returns null.
  ///
  virtual const Init *getFieldInit(Record &R, const RecordVal *RV,
                                   const std::string &FieldName) const {
    return 0;
  }

  /// resolveReferences - This method is used by classes that refer to other
  /// variables which may not be defined at the time the expression is formed.
  /// If a value is set for the variable later, this method will be called on
  /// users of the value to allow the value to propagate out.
  ///
  virtual const Init *resolveReferences(Record &R,
                                        const RecordVal *RV) const {
    return this;
  }
};

inline raw_ostream &operator<<(raw_ostream &OS, const Init &I) {
  I.print(OS); return OS;
}

/// TypedInit - This is the common super-class of types that have a specific,
/// explicit, type.
///
class TypedInit : public Init {
  RecTy *Ty;

  TypedInit(const TypedInit &Other);  // Do not define.
  TypedInit &operator=(const TypedInit &Other);  // Do not define.

protected:
  explicit TypedInit(const FoldingSetNodeID &ID, RecTy *T) : Init(ID), Ty(T) {}

public:
  RecTy *getType() const { return Ty; }

  virtual const Init *
  convertInitializerBitRange(const std::vector<unsigned> &Bits) const;
  virtual const Init *
  convertInitListSlice(const std::vector<unsigned> &Elements) const;

  /// getFieldType - This method is used to implement the FieldInit class.
  /// Implementors of this method should return the type of the named field if
  /// they are of record type.
  ///
  virtual RecTy *getFieldType(const std::string &FieldName) const;

  /// resolveBitReference - This method is used to implement
  /// VarBitInit::resolveReferences.  If the bit is able to be resolved, we
  /// simply return the resolved value, otherwise we return null.
  ///
  virtual const Init *resolveBitReference(Record &R, const RecordVal *RV,
                                          unsigned Bit) const = 0;

  /// resolveListElementReference - This method is used to implement
  /// VarListElementInit::resolveReferences.  If the list element is resolvable
  /// now, we return the resolved value, otherwise we return null.
  virtual const Init *resolveListElementReference(Record &R,
                                                  const RecordVal *RV,
                                                  unsigned Elt) const = 0;
};


/// UnsetInit - ? - Represents an uninitialized value
///
class UnsetInit : public Init {
  UnsetInit(const FoldingSetNodeID &ID) : Init(ID) {}
  UnsetInit(const UnsetInit &);  // Do not define.
  UnsetInit &operator=(const UnsetInit &Other);  // Do not define.

public:
  static const UnsetInit *Create();

  virtual const Init *convertInitializerTo(RecTy *Ty) const {
    return Ty->convertValue(this);
  }

  virtual bool isComplete() const { return false; }
  virtual std::string getAsString() const { return "?"; }
};


/// BitInit - true/false - Represent a concrete initializer for a bit.
///
class BitInit : public Init {
  bool Value;

  explicit BitInit(const FoldingSetNodeID &ID, bool V) : Init(ID), Value(V) {}
  BitInit(const BitInit &Other);  // Do not define.
  BitInit &operator=(BitInit &Other);  // Do not define.

public:
  static const BitInit *Create(bool V);

  bool getValue() const { return Value; }

  virtual const Init *convertInitializerTo(RecTy *Ty) const {
    return Ty->convertValue(this);
  }

  virtual std::string getAsString() const { return Value ? "1" : "0"; }
};

/// BitsInit - { a, b, c } - Represents an initializer for a BitsRecTy value.
/// It contains a vector of bits, whose size is determined by the type.
///
class BitsInit : public Init {
  std::vector<const Init*> Bits;

  BitsInit(const FoldingSetNodeID &ID, unsigned Size)
      : Init(ID), Bits(Size) {}

  template<typename InputIterator>
  BitsInit(const FoldingSetNodeID &ID, InputIterator start, InputIterator end) 
      : Init(ID), Bits(start, end) {}

  BitsInit(const BitsInit &Other);  // Do not define.
  BitsInit &operator=(const BitsInit &Other);  // Do not define.

public:
  template<typename InputIterator>
  static const BitsInit *Create(InputIterator Start, InputIterator End) {
    FoldingSetNodeID ID;
    ID.AddInteger(initBits);
    ID.AddInteger(std::distance(Start, End));

    InputIterator S = Start;
    while (S != End)
      ID.AddPointer(*S++);

    void *IP = 0;
    if (const Init *I = UniqueInits.FindNodeOrInsertPos(ID, IP))
      return static_cast<const BitsInit *>(I);

    BitsInit *I = InitAllocator.Allocate<BitsInit>();
    new (I) BitsInit(ID, Start, End);
    UniqueInits.InsertNode(I, IP);
    return I;
  }

  unsigned getNumBits() const { return Bits.size(); }

  const Init *getBit(unsigned Bit) const {
    assert(Bit < Bits.size() && "Bit index out of range!");
    return Bits[Bit];
  }
  void setBit(unsigned Bit, const Init *V) {
    assert(Bit < Bits.size() && "Bit index out of range!");
    assert(Bits[Bit] == 0 && "Bit already set!");
    Bits[Bit] = V;
  }

  virtual const Init *convertInitializerTo(RecTy *Ty) const {
    return Ty->convertValue(this);
  }
  virtual const Init *
  convertInitializerBitRange(const std::vector<unsigned> &Bits) const;

  virtual bool isComplete() const {
    for (unsigned i = 0; i != getNumBits(); ++i)
      if (!getBit(i)->isComplete()) return false;
    return true;
  }
  bool allInComplete() const {
    for (unsigned i = 0; i != getNumBits(); ++i)
      if (getBit(i)->isComplete()) return false;
    return true;
  }
  virtual std::string getAsString() const;

  virtual const Init *resolveReferences(Record &R,
                                        const RecordVal *RV) const;
};


/// IntInit - 7 - Represent an initalization by a literal integer value.
///
class IntInit : public TypedInit {
  int64_t Value;

  explicit IntInit(const FoldingSetNodeID &ID, int64_t V)
      : TypedInit(ID, new IntRecTy), Value(V) {}

  IntInit(const IntInit &Other);  // Do not define.
  IntInit &operator=(const IntInit &Other);  // Do note define.

public:
  static const IntInit *Create(int64_t V);

  int64_t getValue() const { return Value; }

  virtual const Init *convertInitializerTo(RecTy *Ty) const {
    return Ty->convertValue(this);
  }
  virtual const Init *
  convertInitializerBitRange(const std::vector<unsigned> &Bits) const;

  virtual std::string getAsString() const;

  /// resolveBitReference - This method is used to implement
  /// VarBitInit::resolveReferences.  If the bit is able to be resolved, we
  /// simply return the resolved value, otherwise we return null.
  ///
  virtual const Init *resolveBitReference(Record &R, const RecordVal *RV,
                                          unsigned Bit) const {
    assert(0 && "Illegal bit reference off int");
    return 0;
  }

  /// resolveListElementReference - This method is used to implement
  /// VarListElementInit::resolveReferences.  If the list element is resolvable
  /// now, we return the resolved value, otherwise we return null.
  virtual const Init *resolveListElementReference(Record &R,
                                                  const RecordVal *RV,
                                                  unsigned Elt) const {
    assert(0 && "Illegal element reference off int");
    return 0;
  }
};


/// StringInit - "foo" - Represent an initialization by a string value.
///
class StringInit : public TypedInit {
  std::string Value;

  explicit StringInit(const FoldingSetNodeID &ID, const std::string &V)
      : TypedInit(ID, new StringRecTy), Value(V) {}

  StringInit(const StringInit &Other);  // Do not define.
  StringInit &operator=(const StringInit &Other);  // Do not define.

public:
  static const StringInit *Create(const std::string &V);

  const std::string &getValue() const { return Value; }

  virtual const Init *convertInitializerTo(RecTy *Ty) const {
    return Ty->convertValue(this);
  }

  virtual std::string getAsString() const { return "\"" + Value + "\""; }

  /// resolveBitReference - This method is used to implement
  /// VarBitInit::resolveReferences.  If the bit is able to be resolved, we
  /// simply return the resolved value, otherwise we return null.
  ///
  virtual const Init *resolveBitReference(Record &R, const RecordVal *RV,
                                          unsigned Bit) const {
    assert(0 && "Illegal bit reference off string");
    return 0;
  }

  /// resolveListElementReference - This method is used to implement
  /// VarListElementInit::resolveReferences.  If the list element is resolvable
  /// now, we return the resolved value, otherwise we return null.
  virtual const Init *resolveListElementReference(Record &R,
                                                  const RecordVal *RV,
                                                  unsigned Elt) const {
    assert(0 && "Illegal element reference off string");
    return 0;
  }
};

/// CodeInit - "[{...}]" - Represent a code fragment.
///
class CodeInit : public Init {
  std::string Value;

  explicit CodeInit(const FoldingSetNodeID &ID, const std::string &V)
      : Init(ID), Value(V) {}

  CodeInit(const CodeInit &Other);  // Do not define.
  CodeInit &operator=(const CodeInit &Other);  // Do not define.

public:
  static const CodeInit *Create(const std::string &V);

  const std::string &getValue() const { return Value; }

  virtual const Init *convertInitializerTo(RecTy *Ty) const {
    return Ty->convertValue(this);
  }

  virtual std::string getAsString() const { return "[{" + Value + "}]"; }
};

/// ListInit - [AL, AH, CL] - Represent a list of defs
///
class ListInit : public TypedInit {
  std::vector<const Init*> Values;

public:
  typedef std::vector<const Init*>::const_iterator const_iterator;

private:
  ListInit(const FoldingSetNodeID &ID, std::vector<const Init*> &Vs,
           RecTy *EltTy)
      : TypedInit(ID, new ListRecTy(EltTy)) {
    Values.swap(Vs);
  }

  template<typename InputIterator>
  ListInit(const FoldingSetNodeID &ID, InputIterator Start, InputIterator End,
           RecTy *EltTy)
      : TypedInit(ID, new ListRecTy(EltTy)), Values(Start, End) {}

  ListInit(const ListInit &Other);  // Do not define.
  ListInit &operator=(const ListInit &Other);  // Do not define.

public:
  static const ListInit *Create(std::vector<const Init*> &Vs, RecTy *EltTy);

  template<typename InputIterator>
  static const ListInit *Create(InputIterator Start, InputIterator End,
                                RecTy *EltTy) {
    FoldingSetNodeID ID;
    ID.AddInteger(initList);
    ID.AddString(EltTy->getAsString());

    InputIterator S = Start;
    while (S != End)
      ID.AddPointer(*S++); 

    void *IP = 0;
    if (const Init *I = UniqueInits.FindNodeOrInsertPos(ID, IP))
      return static_cast<const ListInit *>(I);

    ListInit *I = InitAllocator.Allocate<ListInit>();
    new (I) ListInit(ID, Start, End, EltTy);
    UniqueInits.InsertNode(I, IP);
    return I;
  }

  unsigned getSize() const { return Values.size(); }
  const Init *getElement(unsigned i) const {
    assert(i < Values.size() && "List element index out of range!");
    return Values[i];
  }

  Record *getElementAsRecord(unsigned i) const;

  const Init *convertInitListSlice(const std::vector<unsigned> &Elements) const;

  virtual const Init *convertInitializerTo(RecTy *Ty) const {
    return Ty->convertValue(this);
  }

  /// resolveReferences - This method is used by classes that refer to other
  /// variables which may not be defined at the time they expression is formed.
  /// If a value is set for the variable later, this method will be called on
  /// users of the value to allow the value to propagate out.
  ///
  virtual const Init *resolveReferences(Record &R,
                                        const RecordVal *RV) const;

  virtual std::string getAsString() const;

  inline const_iterator begin() const { return Values.begin(); }
  inline const_iterator end  () const { return Values.end();   }

  inline size_t         size () const { return Values.size();  }
  inline bool           empty() const { return Values.empty(); }

  /// resolveBitReference - This method is used to implement
  /// VarBitInit::resolveReferences.  If the bit is able to be resolved, we
  /// simply return the resolved value, otherwise we return null.
  ///
  virtual const Init *resolveBitReference(Record &R, const RecordVal *RV,
                                          unsigned Bit) const {
    assert(0 && "Illegal bit reference off list");
    return 0;
  }

  /// resolveListElementReference - This method is used to implement
  /// VarListElementInit::resolveReferences.  If the list element is resolvable
  /// now, we return the resolved value, otherwise we return null.
  virtual const Init *resolveListElementReference(Record &R,
                                                  const RecordVal *RV,
                                                  unsigned Elt) const;
};


/// OpInit - Base class for operators
///
class OpInit : public TypedInit {
  OpInit(const OpInit &Other);  // Do not define.
  OpInit &operator=(OpInit &Other);  // Do not define.

protected:
  explicit OpInit(const FoldingSetNodeID &ID, RecTy *Type)
      : TypedInit(ID, Type) {}

public:
  // Clone - Clone this operator, replacing arguments with the new list
  virtual const OpInit *clone(std::vector<const Init *> &Operands) const = 0;

  virtual int getNumOperands() const = 0;
  virtual const Init *getOperand(int i) const = 0;

  // Fold - If possible, fold this to a simpler init.  Return this if not
  // possible to fold.
  virtual const Init *Fold(Record *CurRec, MultiClass *CurMultiClass) const = 0;

  virtual const Init *convertInitializerTo(RecTy *Ty) const {
    return Ty->convertValue(this);
  }

  virtual const Init *resolveBitReference(Record &R, const RecordVal *RV,
                                          unsigned Bit) const;
  virtual const Init *resolveListElementReference(Record &R,
                                                  const RecordVal *RV,
                                                  unsigned Elt) const;
};


/// UnOpInit - !op (X) - Transform an init.
///
class UnOpInit : public OpInit {
public:
  enum UnaryOp { CAST, HEAD, TAIL, EMPTY };
private:
  UnaryOp Opc;
  const Init *LHS;

  UnOpInit(const FoldingSetNodeID &ID, UnaryOp opc, const Init *lhs,
           RecTy *Type)
      : OpInit(ID, Type), Opc(opc), LHS(lhs) {}

  UnOpInit(const UnOpInit &Other);  // Do not define.
  UnOpInit &operator=(const UnOpInit &Other);  // Do not define.

public:
  static const UnOpInit *Create(UnaryOp opc, const Init *lhs, RecTy *Type);

  // Clone - Clone this operator, replacing arguments with the new list
  virtual const OpInit *clone(std::vector<const Init *> &Operands) const {
    assert(Operands.size() == 1 &&
           "Wrong number of operands for unary operation");
    return UnOpInit::Create(getOpcode(), *Operands.begin(), getType());
  }

  int getNumOperands() const { return 1; }
  const Init *getOperand(int i) const {
    assert(i == 0 && "Invalid operand id for unary operator");
    return getOperand();
  }

  UnaryOp getOpcode() const { return Opc; }
  const Init *getOperand() const { return LHS; }

  // Fold - If possible, fold this to a simpler init.  Return this if not
  // possible to fold.
  const Init *Fold(Record *CurRec, MultiClass *CurMultiClass)const ;

  virtual const Init *resolveReferences(Record &R,
                                        const RecordVal *RV) const;

  virtual std::string getAsString() const;
};

/// BinOpInit - !op (X, Y) - Combine two inits.
///
class BinOpInit : public OpInit {
public:
  enum BinaryOp { SHL, SRA, SRL, STRCONCAT, CONCAT, EQ };
private:
  BinaryOp Opc;
  const Init *LHS, *RHS;

  BinOpInit(const FoldingSetNodeID &ID, BinaryOp opc, const Init *lhs,
            const Init *rhs, RecTy *Type) :
      OpInit(ID, Type), Opc(opc), LHS(lhs), RHS(rhs) {}

  BinOpInit(const BinOpInit &Other);  // Do not define.
  BinOpInit &operator=(const BinOpInit &Other);  // Do not define.

public:
  static const BinOpInit *Create(BinaryOp opc, const Init *lhs, const Init *rhs,
                                 RecTy *Type);

  // Clone - Clone this operator, replacing arguments with the new list
  virtual const OpInit *clone(std::vector<const Init *> &Operands) const {
    assert(Operands.size() == 2 &&
           "Wrong number of operands for binary operation");
    return BinOpInit::Create(getOpcode(), Operands[0], Operands[1], getType());
  }

  int getNumOperands() const { return 2; }
  const Init *getOperand(int i) const {
    assert((i == 0 || i == 1) && "Invalid operand id for binary operator");
    if (i == 0) {
      return getLHS();
    } else {
      return getRHS();
    }
  }

  BinaryOp getOpcode() const { return Opc; }
  const Init *getLHS() const { return LHS; }
  const Init *getRHS() const { return RHS; }

  // Fold - If possible, fold this to a simpler init.  Return this if not
  // possible to fold.
  const Init *Fold(Record *CurRec, MultiClass *CurMultiClass) const;

  virtual const Init *resolveReferences(Record &R,
                                        const RecordVal *RV) const;

  virtual std::string getAsString() const;
};

/// TernOpInit - !op (X, Y, Z) - Combine two inits.
///
class TernOpInit : public OpInit {
public:
  enum TernaryOp { SUBST, FOREACH, IF };
private:
  TernaryOp Opc;
  const Init *LHS, *MHS, *RHS;

  TernOpInit(const FoldingSetNodeID &ID, TernaryOp opc, const Init *lhs,
             const Init *mhs, const Init *rhs, RecTy *Type) :
      OpInit(ID, Type), Opc(opc), LHS(lhs), MHS(mhs), RHS(rhs) {}

  TernOpInit(const TernOpInit &Other);  // Do not define.
  TernOpInit &operator=(const TernOpInit &Other);  // Do not define.

public:
  static const TernOpInit *Create(TernaryOp opc, const Init *lhs,
                                  const Init *mhs, const Init *rhs,
                                  RecTy *Type);

  // Clone - Clone this operator, replacing arguments with the new list
  virtual const OpInit *clone(std::vector<const Init *> &Operands) const {
    assert(Operands.size() == 3 &&
           "Wrong number of operands for ternary operation");
    return TernOpInit::Create(getOpcode(), Operands[0], Operands[1],
                              Operands[2], getType());
  }

  int getNumOperands() const { return 3; }
  const Init *getOperand(int i) const {
    assert((i == 0 || i == 1 || i == 2) &&
           "Invalid operand id for ternary operator");
    if (i == 0) {
      return getLHS();
    } else if (i == 1) {
      return getMHS();
    } else {
      return getRHS();
    }
  }

  TernaryOp getOpcode() const { return Opc; }
  const Init *getLHS() const { return LHS; }
  const Init *getMHS() const { return MHS; }
  const Init *getRHS() const { return RHS; }

  // Fold - If possible, fold this to a simpler init.  Return this if not
  // possible to fold.
  const Init *Fold(Record *CurRec, MultiClass *CurMultiClass) const;

  virtual bool isComplete() const { return false; }

  virtual const Init *resolveReferences(Record &R,
                                        const RecordVal *RV) const;

  virtual std::string getAsString() const;
};


/// VarInit - 'Opcode' - Represent a reference to an entire variable object.
///
class VarInit : public TypedInit {
  std::string VarName;

  explicit VarInit(const FoldingSetNodeID &ID, const std::string &VN, RecTy *T)
      : TypedInit(ID, T), VarName(VN) {}

  VarInit(const VarInit &Other);  // Do not define.
  VarInit &operator=(const VarInit &Other);  // Do not define.

public:
  static const VarInit *Create(const std::string &VN, RecTy *T);
  static const VarInit *Create(const Init *VN, RecTy *T);

  virtual const Init *convertInitializerTo(RecTy *Ty) const {
    return Ty->convertValue(this);
  }

  const std::string &getName() const { return VarName; }

  virtual const Init *resolveBitReference(Record &R, const RecordVal *RV,
                                          unsigned Bit) const;
  virtual const Init *resolveListElementReference(Record &R,
                                                  const RecordVal *RV,
                                                  unsigned Elt) const;

  virtual RecTy *getFieldType(const std::string &FieldName) const;
  virtual const Init *getFieldInit(Record &R, const RecordVal *RV,
                             const std::string &FieldName) const;

  /// resolveReferences - This method is used by classes that refer to other
  /// variables which may not be defined at the time they expression is formed.
  /// If a value is set for the variable later, this method will be called on
  /// users of the value to allow the value to propagate out.
  ///
  virtual const Init *resolveReferences(Record &R,
                                        const RecordVal *RV) const;

  virtual std::string getAsString() const { return VarName; }
};


/// VarBitInit - Opcode{0} - Represent access to one bit of a variable or field.
///
class VarBitInit : public Init {
  const TypedInit *TI;
  unsigned Bit;

  VarBitInit(const FoldingSetNodeID &ID, const TypedInit *T, unsigned B)
      : Init(ID), TI(T), Bit(B) {
    assert(T->getType() && dynamic_cast<BitsRecTy*>(T->getType()) &&
           ((BitsRecTy*)T->getType())->getNumBits() > B &&
           "Illegal VarBitInit expression!");
  }

  VarBitInit(const VarBitInit &Other);  // Do not define.
  VarBitInit &operator=(const VarBitInit &Other);  // Do not define.

public:
  static const VarBitInit *Create(const TypedInit *T, unsigned B);

  virtual const Init *convertInitializerTo(RecTy *Ty) const {
    return Ty->convertValue(this);
  }

  const TypedInit *getVariable() const { return TI; }
  unsigned getBitNum() const { return Bit; }

  virtual std::string getAsString() const;
  virtual const Init *resolveReferences(Record &R,
                                        const RecordVal *RV) const;
};

/// VarListElementInit - List[4] - Represent access to one element of a var or
/// field.
class VarListElementInit : public TypedInit {
  const TypedInit *TI;
  unsigned Element;

  VarListElementInit(const FoldingSetNodeID &ID, const TypedInit *T, unsigned E)
      : TypedInit(ID, dynamic_cast<ListRecTy*>(T->getType())->getElementType()),
                TI(T), Element(E) {
    assert(T->getType() && dynamic_cast<ListRecTy*>(T->getType()) &&
           "Illegal VarBitInit expression!");
  }

  VarListElementInit(const VarListElementInit &Other);  // Do not define.
  VarListElementInit &operator=(const VarListElementInit &Other);  // Do
                                                                   // not
                                                                   // define.

public:
  static const VarListElementInit *Create(const TypedInit *T, unsigned E);

  virtual const Init *convertInitializerTo(RecTy *Ty) const {
    return Ty->convertValue(this);
  }

  const TypedInit *getVariable() const { return TI; }
  unsigned getElementNum() const { return Element; }

  virtual const Init *resolveBitReference(Record &R, const RecordVal *RV,
                                          unsigned Bit) const;

  /// resolveListElementReference - This method is used to implement
  /// VarListElementInit::resolveReferences.  If the list element is resolvable
  /// now, we return the resolved value, otherwise we return null.
  virtual const Init *resolveListElementReference(Record &R, const RecordVal *RV,
                                            unsigned Elt) const;

  virtual std::string getAsString() const;
  virtual const Init *resolveReferences(Record &R,
                                        const RecordVal *RV) const;
};

/// DefInit - AL - Represent a reference to a 'def' in the description
///
class DefInit : public TypedInit {
  Record *Def;

  explicit DefInit(const FoldingSetNodeID &ID, Record *D)
      : TypedInit(ID, new RecordRecTy(D)), Def(D) {}

  DefInit(const DefInit &Other);  // Do not define.
  DefInit &operator=(const DefInit &Other);  // Do not define.

public:
  static const DefInit *Create(Record *D);

  virtual const Init *convertInitializerTo(RecTy *Ty) const {
    return Ty->convertValue(this);
  }

  Record *getDef() const { return Def; }

  //virtual const Init *
  //convertInitializerBitRange(const std::vector<unsigned> &Bits) const;

  virtual RecTy *getFieldType(const std::string &FieldName) const;
  virtual const Init *getFieldInit(Record &R, const RecordVal *RV,
                             const std::string &FieldName) const;

  virtual std::string getAsString() const;

  /// resolveBitReference - This method is used to implement
  /// VarBitInit::resolveReferences.  If the bit is able to be resolved, we
  /// simply return the resolved value, otherwise we return null.
  ///
  virtual const Init *resolveBitReference(Record &R, const RecordVal *RV,
                                          unsigned Bit) const {
    assert(0 && "Illegal bit reference off def");
    return 0;
  }

  /// resolveListElementReference - This method is used to implement
  /// VarListElementInit::resolveReferences.  If the list element is resolvable
  /// now, we return the resolved value, otherwise we return null.
  virtual const Init *resolveListElementReference(Record &R,
                                                  const RecordVal *RV,
                                                  unsigned Elt) const {
    assert(0 && "Illegal element reference off def");
    return 0;
  }
};


/// FieldInit - X.Y - Represent a reference to a subfield of a variable
///
class FieldInit : public TypedInit {
  const Init *Rec;                // Record we are referring to
  std::string FieldName;    // Field we are accessing

  FieldInit(const FoldingSetNodeID &ID, const Init *R, const std::string &FN)
      : TypedInit(ID, R->getFieldType(FN)), Rec(R), FieldName(FN) {
    assert(getType() && "FieldInit with non-record type!");
  }

  FieldInit(const FieldInit &Other);  // Do not define.
  FieldInit &operator=(const FieldInit &Other);  // Do not define.

public:
  static const FieldInit *Create(const Init *R, const std::string &FN);
  static const FieldInit *Create(const Init *R, const Init *FN);

  virtual const Init *convertInitializerTo(RecTy *Ty) const {
    return Ty->convertValue(this);
  }

  virtual const Init *resolveBitReference(Record &R, const RecordVal *RV,
                                          unsigned Bit) const;
  virtual const Init *resolveListElementReference(Record &R,
                                                  const RecordVal *RV,
                                                  unsigned Elt) const;

  virtual const Init *resolveReferences(Record &R,
                                        const RecordVal *RV) const;

  virtual std::string getAsString() const {
    return Rec->getAsString() + "." + FieldName;
  }
};

/// DagInit - (v a, b) - Represent a DAG tree value.  DAG inits are required
/// to have at least one value then a (possibly empty) list of arguments.  Each
/// argument can have a name associated with it.
///
class DagInit : public TypedInit {
  const Init *Val;
  std::string ValName;
  std::vector<const Init*> Args;
  std::vector<std::string> ArgNames;

  DagInit(const FoldingSetNodeID &ID, const Init *V, const std::string &VN,
          const std::vector<std::pair<const Init*, std::string> > &args)
      : TypedInit(ID, new DagRecTy), Val(V), ValName(VN) {
    Args.reserve(args.size());
    ArgNames.reserve(args.size());
    for (unsigned i = 0, e = args.size(); i != e; ++i) {
      Args.push_back(args[i].first);
      ArgNames.push_back(args[i].second);
    }
  }
  DagInit(const FoldingSetNodeID &ID, const Init *V, const std::string &VN,
          const std::vector<const Init*> &args,
          const std::vector<std::string> &argNames)
      : TypedInit(ID, new DagRecTy), Val(V), ValName(VN), Args(args),
      ArgNames(argNames) { }

  DagInit(const DagInit &Other);  // Do not define.
  DagInit &operator=(const DagInit &Other);  // Do not define.

public:
  static const DagInit *Create(const Init *V, const std::string &VN,
                               const std::vector<
                                 std::pair<const Init*, std::string> > &args);
  static const DagInit *Create(const Init *V, const std::string &VN,
                               const std::vector<const Init*> &args,
                               const std::vector<std::string> &argNames);

  virtual const Init *convertInitializerTo(RecTy *Ty) const {
    return Ty->convertValue(this);
  }

  const Init *getOperator() const { return Val; }

  const std::string &getName() const { return ValName; }

  unsigned getNumArgs() const { return Args.size(); }
  const Init *getArg(unsigned Num) const {
    assert(Num < Args.size() && "Arg number out of range!");
    return Args[Num];
  }
  const std::string &getArgName(unsigned Num) const {
    assert(Num < ArgNames.size() && "Arg number out of range!");
    return ArgNames[Num];
  }

  void setArg(unsigned Num, const Init *I) {
    assert(Num < Args.size() && "Arg number out of range!");
    Args[Num] = I;
  }

  virtual const Init *resolveReferences(Record &R,
                                        const RecordVal *RV) const;

  virtual std::string getAsString() const;

  typedef std::vector<const Init*>::iterator             arg_iterator;
  typedef std::vector<const Init*>::const_iterator       const_arg_iterator;
  typedef std::vector<std::string>::iterator       name_iterator;
  typedef std::vector<std::string>::const_iterator const_name_iterator;

  inline arg_iterator        arg_begin()       { return Args.begin(); }
  inline const_arg_iterator  arg_begin() const { return Args.begin(); }
  inline arg_iterator        arg_end  ()       { return Args.end();   }
  inline const_arg_iterator  arg_end  () const { return Args.end();   }

  inline size_t              arg_size () const { return Args.size();  }
  inline bool                arg_empty() const { return Args.empty(); }

  inline name_iterator       name_begin()       { return ArgNames.begin(); }
  inline const_name_iterator name_begin() const { return ArgNames.begin(); }
  inline name_iterator       name_end  ()       { return ArgNames.end();   }
  inline const_name_iterator name_end  () const { return ArgNames.end();   }

  inline size_t              name_size () const { return ArgNames.size();  }
  inline bool                name_empty() const { return ArgNames.empty(); }

  virtual const Init *resolveBitReference(Record &R, const RecordVal *RV,
                                          unsigned Bit) const {
    assert(0 && "Illegal bit reference off dag");
    return 0;
  }

  virtual const Init *resolveListElementReference(Record &R,
                                                  const RecordVal *RV,
                                                  unsigned Elt) const {
    assert(0 && "Illegal element reference off dag");
    return 0;
  }
};

//===----------------------------------------------------------------------===//
//  High-Level Classes
//===----------------------------------------------------------------------===//

class RecordVal {
  std::string Name;
  RecTy *Ty;
  unsigned Prefix;
  const Init *Value;
public:
  RecordVal(const std::string &N, RecTy *T, unsigned P);

  const std::string &getName() const { return Name; }

  unsigned getPrefix() const { return Prefix; }
  RecTy *getType() const { return Ty; }
  const Init *getValue() const { return Value; }

  bool setValue(const Init *V) {
    if (V) {
      Value = V->convertInitializerTo(Ty);
      return Value == 0;
    }
    Value = 0;
    return false;
  }

  void dump() const;
  void print(raw_ostream &OS, bool PrintSem = true) const;
};

inline raw_ostream &operator<<(raw_ostream &OS, const RecordVal &RV) {
  RV.print(OS << "  ");
  return OS;
}

class Record {
  static unsigned LastID;

  // Unique record ID.
  unsigned ID;
  std::string Name;
  SMLoc Loc;
  std::vector<std::string> TemplateArgs;
  std::vector<RecordVal> Values;
  std::vector<Record*> SuperClasses;

  // Tracks Record instances. Not owned by Record.
  RecordKeeper &TrackedRecords;

public:

  // Constructs a record.
  explicit Record(const std::string &N, SMLoc loc, RecordKeeper &records) :
    ID(LastID++), Name(N), Loc(loc), TrackedRecords(records) {}
  ~Record() {}


  static unsigned getNewUID() { return LastID++; }


  unsigned getID() const { return ID; }

  const std::string &getName() const { return Name; }
  void setName(const std::string &Name);  // Also updates RecordKeeper.

  SMLoc getLoc() const { return Loc; }

  const std::vector<std::string> &getTemplateArgs() const {
    return TemplateArgs;
  }
  const std::vector<RecordVal> &getValues() const { return Values; }
  const std::vector<Record*>   &getSuperClasses() const { return SuperClasses; }

  bool isTemplateArg(StringRef Name) const {
    for (unsigned i = 0, e = TemplateArgs.size(); i != e; ++i)
      if (TemplateArgs[i] == Name) return true;
    return false;
  }

  const RecordVal *getValue(StringRef Name) const {
    for (unsigned i = 0, e = Values.size(); i != e; ++i)
      if (Values[i].getName() == Name) return &Values[i];
    return 0;
  }
  RecordVal *getValue(StringRef Name) {
    for (unsigned i = 0, e = Values.size(); i != e; ++i)
      if (Values[i].getName() == Name) return &Values[i];
    return 0;
  }

  void addTemplateArg(StringRef Name) {
    assert(!isTemplateArg(Name) && "Template arg already defined!");
    TemplateArgs.push_back(Name);
  }

  void addValue(const RecordVal &RV) {
    assert(getValue(RV.getName()) == 0 && "Value already added!");
    Values.push_back(RV);
  }

  void removeValue(StringRef Name) {
    for (unsigned i = 0, e = Values.size(); i != e; ++i)
      if (Values[i].getName() == Name) {
        Values.erase(Values.begin()+i);
        return;
      }
    assert(0 && "Cannot remove an entry that does not exist!");
  }

  bool isSubClassOf(const Record *R) const {
    for (unsigned i = 0, e = SuperClasses.size(); i != e; ++i)
      if (SuperClasses[i] == R)
        return true;
    return false;
  }

  bool isSubClassOf(StringRef Name) const {
    for (unsigned i = 0, e = SuperClasses.size(); i != e; ++i)
      if (SuperClasses[i]->getName() == Name)
        return true;
    return false;
  }

  void addSuperClass(Record *R) {
    assert(!isSubClassOf(R) && "Already subclassing record!");
    SuperClasses.push_back(R);
  }

  /// resolveReferences - If there are any field references that refer to fields
  /// that have been filled in, we can propagate the values now.
  ///
  void resolveReferences() { resolveReferencesTo(0); }

  /// resolveReferencesTo - If anything in this record refers to RV, replace the
  /// reference to RV with the RHS of RV.  If RV is null, we resolve all
  /// possible references.
  void resolveReferencesTo(const RecordVal *RV);

  RecordKeeper &getRecords() const {
    return TrackedRecords;
  }

  void dump() const;

  //===--------------------------------------------------------------------===//
  // High-level methods useful to tablegen back-ends
  //

  /// getValueInit - Return the initializer for a value with the specified name,
  /// or throw an exception if the field does not exist.
  ///
  const Init *getValueInit(StringRef FieldName) const;

  /// getValueAsString - This method looks up the specified field and returns
  /// its value as a string, throwing an exception if the field does not exist
  /// or if the value is not a string.
  ///
  std::string getValueAsString(StringRef FieldName) const;

  /// getValueAsBitsInit - This method looks up the specified field and returns
  /// its value as a BitsInit, throwing an exception if the field does not exist
  /// or if the value is not the right type.
  ///
  const BitsInit *getValueAsBitsInit(StringRef FieldName) const;

  /// getValueAsListInit - This method looks up the specified field and returns
  /// its value as a ListInit, throwing an exception if the field does not exist
  /// or if the value is not the right type.
  ///
  const ListInit *getValueAsListInit(StringRef FieldName) const;

  /// getValueAsListOfDefs - This method looks up the specified field and
  /// returns its value as a vector of records, throwing an exception if the
  /// field does not exist or if the value is not the right type.
  ///
  std::vector<Record*> getValueAsListOfDefs(StringRef FieldName) const;

  /// getValueAsListOfInts - This method looks up the specified field and
  /// returns its value as a vector of integers, throwing an exception if the
  /// field does not exist or if the value is not the right type.
  ///
  std::vector<int64_t> getValueAsListOfInts(StringRef FieldName) const;

  /// getValueAsListOfStrings - This method looks up the specified field and
  /// returns its value as a vector of strings, throwing an exception if the
  /// field does not exist or if the value is not the right type.
  ///
  std::vector<std::string> getValueAsListOfStrings(StringRef FieldName) const;

  /// getValueAsDef - This method looks up the specified field and returns its
  /// value as a Record, throwing an exception if the field does not exist or if
  /// the value is not the right type.
  ///
  Record *getValueAsDef(StringRef FieldName) const;

  /// getValueAsBit - This method looks up the specified field and returns its
  /// value as a bit, throwing an exception if the field does not exist or if
  /// the value is not the right type.
  ///
  bool getValueAsBit(StringRef FieldName) const;

  /// getValueAsInt - This method looks up the specified field and returns its
  /// value as an int64_t, throwing an exception if the field does not exist or
  /// if the value is not the right type.
  ///
  int64_t getValueAsInt(StringRef FieldName) const;

  /// getValueAsDag - This method looks up the specified field and returns its
  /// value as an Dag, throwing an exception if the field does not exist or if
  /// the value is not the right type.
  ///
  const DagInit *getValueAsDag(StringRef FieldName) const;

  /// getValueAsCode - This method looks up the specified field and returns
  /// its value as the string data in a CodeInit, throwing an exception if the
  /// field does not exist or if the value is not a code object.
  ///
  std::string getValueAsCode(StringRef FieldName) const;
};

raw_ostream &operator<<(raw_ostream &OS, const Record &R);

struct MultiClass {
  Record Rec;  // Placeholder for template args and Name.
  typedef std::vector<Record*> RecordVector;
  RecordVector DefPrototypes;

  void dump() const;

  MultiClass(const std::string &Name, SMLoc Loc, RecordKeeper &Records) : 
    Rec(Name, Loc, Records) {}
};

class RecordKeeper {
  std::map<std::string, Record*> Classes, Defs;
public:
  ~RecordKeeper() {
    for (std::map<std::string, Record*>::iterator I = Classes.begin(),
           E = Classes.end(); I != E; ++I)
      delete I->second;
    for (std::map<std::string, Record*>::iterator I = Defs.begin(),
           E = Defs.end(); I != E; ++I)
      delete I->second;
  }

  const std::map<std::string, Record*> &getClasses() const { return Classes; }
  const std::map<std::string, Record*> &getDefs() const { return Defs; }

  Record *getClass(const std::string &Name) const {
    std::map<std::string, Record*>::const_iterator I = Classes.find(Name);
    return I == Classes.end() ? 0 : I->second;
  }
  Record *getDef(const std::string &Name) const {
    std::map<std::string, Record*>::const_iterator I = Defs.find(Name);
    return I == Defs.end() ? 0 : I->second;
  }
  void addClass(Record *R) {
    assert(getClass(R->getName()) == 0 && "Class already exists!");
    Classes.insert(std::make_pair(R->getName(), R));
  }
  void addDef(Record *R) {
    assert(getDef(R->getName()) == 0 && "Def already exists!");
    Defs.insert(std::make_pair(R->getName(), R));
  }

  /// removeClass - Remove, but do not delete, the specified record.
  ///
  void removeClass(const std::string &Name) {
    assert(Classes.count(Name) && "Class does not exist!");
    Classes.erase(Name);
  }
  /// removeDef - Remove, but do not delete, the specified record.
  ///
  void removeDef(const std::string &Name) {
    assert(Defs.count(Name) && "Def does not exist!");
    Defs.erase(Name);
  }

  //===--------------------------------------------------------------------===//
  // High-level helper methods, useful for tablegen backends...

  /// getAllDerivedDefinitions - This method returns all concrete definitions
  /// that derive from the specified class name.  If a class with the specified
  /// name does not exist, an exception is thrown.
  std::vector<Record*>
  getAllDerivedDefinitions(const std::string &ClassName) const;

  void dump() const;
};

/// LessRecord - Sorting predicate to sort record pointers by name.
///
struct LessRecord {
  bool operator()(const Record *Rec1, const Record *Rec2) const {
    return StringRef(Rec1->getName()).compare_numeric(Rec2->getName()) < 0;
  }
};

/// LessRecordFieldName - Sorting predicate to sort record pointers by their
/// name field.
///
struct LessRecordFieldName {
  bool operator()(const Record *Rec1, const Record *Rec2) const {
    return Rec1->getValueAsString("Name") < Rec2->getValueAsString("Name");
  }
};

raw_ostream &operator<<(raw_ostream &OS, const RecordKeeper &RK);

} // End llvm namespace

#endif
