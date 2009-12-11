//===-- Function.cpp - Implement the Global object classes ----------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the Function class for the VMCore library.
//
//===----------------------------------------------------------------------===//

#include "llvm/Module.h"
#include "llvm/DerivedTypes.h"
#include "llvm/IntrinsicInst.h"
#include "llvm/LLVMContext.h"
#include "llvm/CodeGen/ValueTypes.h"
#include "llvm/Support/LeakDetector.h"
#include "llvm/Support/ManagedStatic.h"
#include "llvm/Support/StringPool.h"
#include "llvm/System/RWMutex.h"
#include "llvm/System/Threading.h"
#include "SymbolTableListTraitsImpl.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/StringExtras.h"
using namespace llvm;


// Explicit instantiations of SymbolTableListTraits since some of the methods
// are not in the public header file...
template class SymbolTableListTraits<Argument, Function>;
template class SymbolTableListTraits<BasicBlock, Function>;

//===----------------------------------------------------------------------===//
// Argument Implementation
//===----------------------------------------------------------------------===//

Argument::Argument(const Type *Ty, const Twine &Name, Function *Par)
  : Value(Ty, Value::ArgumentVal) {
  Parent = 0;

  // Make sure that we get added to a function
  LeakDetector::addGarbageObject(this);

  if (Par)
    Par->getArgumentList().push_back(this);
  setName(Name);
}

void Argument::setParent(Function *parent) {
  if (getParent())
    LeakDetector::addGarbageObject(this);
  Parent = parent;
  if (getParent())
    LeakDetector::removeGarbageObject(this);
}

/// getArgNo - Return the index of this formal argument in its containing
/// function.  For example in "void foo(int a, float b)" a is 0 and b is 1. 
unsigned Argument::getArgNo() const {
  const Function *F = getParent();
  assert(F && "Argument is not in a function");
  
  Function::const_arg_iterator AI = F->arg_begin();
  unsigned ArgIdx = 0;
  for (; &*AI != this; ++AI)
    ++ArgIdx;

  return ArgIdx;
}

/// hasByValAttr - Return true if this argument has the byval attribute on it
/// in its containing function.
bool Argument::hasByValAttr() const {
  if (!isa<PointerType>(getType())) return false;
  return getParent()->paramHasAttr(getArgNo()+1, Attribute::ByVal);
}

/// hasNestAttr - Return true if this argument has the nest attribute on
/// it in its containing function.
bool Argument::hasNestAttr() const {
  if (!isa<PointerType>(getType())) return false;
  return getParent()->paramHasAttr(getArgNo()+1, Attribute::Nest);
}

/// hasNoAliasAttr - Return true if this argument has the noalias attribute on
/// it in its containing function.
bool Argument::hasNoAliasAttr() const {
  if (!isa<PointerType>(getType())) return false;
  return getParent()->paramHasAttr(getArgNo()+1, Attribute::NoAlias);
}

/// hasNoCaptureAttr - Return true if this argument has the nocapture attribute
/// on it in its containing function.
bool Argument::hasNoCaptureAttr() const {
  if (!isa<PointerType>(getType())) return false;
  return getParent()->paramHasAttr(getArgNo()+1, Attribute::NoCapture);
}

/// hasSRetAttr - Return true if this argument has the sret attribute on
/// it in its containing function.
bool Argument::hasStructRetAttr() const {
  if (!isa<PointerType>(getType())) return false;
  if (this != getParent()->arg_begin())
    return false; // StructRet param must be first param
  return getParent()->paramHasAttr(1, Attribute::StructRet);
}

/// addAttr - Add a Attribute to an argument
void Argument::addAttr(Attributes attr) {
  getParent()->addAttribute(getArgNo() + 1, attr);
}

/// removeAttr - Remove a Attribute from an argument
void Argument::removeAttr(Attributes attr) {
  getParent()->removeAttribute(getArgNo() + 1, attr);
}


//===----------------------------------------------------------------------===//
// Helper Methods in Function
//===----------------------------------------------------------------------===//

LLVMContext &Function::getContext() const {
  return getType()->getContext();
}

const FunctionType *Function::getFunctionType() const {
  return cast<FunctionType>(getType()->getElementType());
}

bool Function::isVarArg() const {
  return getFunctionType()->isVarArg();
}

const Type *Function::getReturnType() const {
  return getFunctionType()->getReturnType();
}

void Function::removeFromParent() {
  getParent()->getFunctionList().remove(this);
}

void Function::eraseFromParent() {
  getParent()->getFunctionList().erase(this);
}

//===----------------------------------------------------------------------===//
// Function Implementation
//===----------------------------------------------------------------------===//

Function::Function(const FunctionType *Ty, LinkageTypes Linkage,
                   const Twine &name, Module *ParentModule)
  : GlobalValue(PointerType::getUnqual(Ty), 
                Value::FunctionVal, 0, 0, Linkage, name) {
  assert(FunctionType::isValidReturnType(getReturnType()) &&
         !isa<OpaqueType>(getReturnType()) && "invalid return type");
  SymTab = new ValueSymbolTable();

  // If the function has arguments, mark them as lazily built.
  if (Ty->getNumParams())
    SubclassData = 1;   // Set the "has lazy arguments" bit.
  
  // Make sure that we get added to a function
  LeakDetector::addGarbageObject(this);

  if (ParentModule)
    ParentModule->getFunctionList().push_back(this);

  // Ensure intrinsics have the right parameter attributes.
  if (unsigned IID = getIntrinsicID())
    setAttributes(Intrinsic::getAttributes(Intrinsic::ID(IID)));

}

Function::~Function() {
  dropAllReferences();    // After this it is safe to delete instructions.

  // Delete all of the method arguments and unlink from symbol table...
  ArgumentList.clear();
  delete SymTab;

  // Remove the function from the on-the-side GC table.
  clearGC();
}

void Function::BuildLazyArguments() const {
  // Create the arguments vector, all arguments start out unnamed.
  const FunctionType *FT = getFunctionType();
  for (unsigned i = 0, e = FT->getNumParams(); i != e; ++i) {
    assert(FT->getParamType(i) != Type::getVoidTy(FT->getContext()) &&
           "Cannot have void typed arguments!");
    ArgumentList.push_back(new Argument(FT->getParamType(i)));
  }
  
  // Clear the lazy arguments bit.
  const_cast<Function*>(this)->SubclassData &= ~1;
}

size_t Function::arg_size() const {
  return getFunctionType()->getNumParams();
}
bool Function::arg_empty() const {
  return getFunctionType()->getNumParams() == 0;
}

void Function::setParent(Module *parent) {
  if (getParent())
    LeakDetector::addGarbageObject(this);
  Parent = parent;
  if (getParent())
    LeakDetector::removeGarbageObject(this);
}

// dropAllReferences() - This function causes all the subinstructions to "let
// go" of all references that they are maintaining.  This allows one to
// 'delete' a whole class at a time, even though there may be circular
// references... first all references are dropped, and all use counts go to
// zero.  Then everything is deleted for real.  Note that no operations are
// valid on an object that has "dropped all references", except operator
// delete.
//
void Function::dropAllReferences() {
  for (iterator I = begin(), E = end(); I != E; ++I)
    I->dropAllReferences();
  
  // Delete all basic blocks.
  while (!BasicBlocks.empty()) {
    // If there is still a reference to the block, it must be a 'blockaddress'
    // constant pointing to it.  Just replace the BlockAddress with undef.
    BasicBlock *BB = BasicBlocks.begin();
    if (!BB->use_empty()) {
      BlockAddress *BA = cast<BlockAddress>(BB->use_back());
      BA->replaceAllUsesWith(UndefValue::get(BA->getType()));
      BA->destroyConstant();
    }
    
    BB->eraseFromParent();
  }
}

void Function::addAttribute(unsigned i, Attributes attr) {
  AttrListPtr PAL = getAttributes();
  PAL = PAL.addAttr(i, attr);
  setAttributes(PAL);
}

void Function::removeAttribute(unsigned i, Attributes attr) {
  AttrListPtr PAL = getAttributes();
  PAL = PAL.removeAttr(i, attr);
  setAttributes(PAL);
}

// Maintain the GC name for each function in an on-the-side table. This saves
// allocating an additional word in Function for programs which do not use GC
// (i.e., most programs) at the cost of increased overhead for clients which do
// use GC.
static DenseMap<const Function*,PooledStringPtr> *GCNames;
static StringPool *GCNamePool;
static ManagedStatic<sys::SmartRWMutex<true> > GCLock;

bool Function::hasGC() const {
  sys::SmartScopedReader<true> Reader(*GCLock);
  return GCNames && GCNames->count(this);
}

const char *Function::getGC() const {
  assert(hasGC() && "Function has no collector");
  sys::SmartScopedReader<true> Reader(*GCLock);
  return *(*GCNames)[this];
}

void Function::setGC(const char *Str) {
  sys::SmartScopedWriter<true> Writer(*GCLock);
  if (!GCNamePool)
    GCNamePool = new StringPool();
  if (!GCNames)
    GCNames = new DenseMap<const Function*,PooledStringPtr>();
  (*GCNames)[this] = GCNamePool->intern(Str);
}

void Function::clearGC() {
  sys::SmartScopedWriter<true> Writer(*GCLock);
  if (GCNames) {
    GCNames->erase(this);
    if (GCNames->empty()) {
      delete GCNames;
      GCNames = 0;
      if (GCNamePool->empty()) {
        delete GCNamePool;
        GCNamePool = 0;
      }
    }
  }
}

/// copyAttributesFrom - copy all additional attributes (those not needed to
/// create a Function) from the Function Src to this one.
void Function::copyAttributesFrom(const GlobalValue *Src) {
  assert(isa<Function>(Src) && "Expected a Function!");
  GlobalValue::copyAttributesFrom(Src);
  const Function *SrcF = cast<Function>(Src);
  setCallingConv(SrcF->getCallingConv());
  setAttributes(SrcF->getAttributes());
  if (SrcF->hasGC())
    setGC(SrcF->getGC());
  else
    clearGC();
}

/// getIntrinsicID - This method returns the ID number of the specified
/// function, or Intrinsic::not_intrinsic if the function is not an
/// intrinsic, or if the pointer is null.  This value is always defined to be
/// zero to allow easy checking for whether a function is intrinsic or not.  The
/// particular intrinsic functions which correspond to this value are defined in
/// llvm/Intrinsics.h.
///
unsigned Function::getIntrinsicID() const {
  const ValueName *ValName = this->getValueName();
  if (!ValName)
    return 0;
  unsigned Len = ValName->getKeyLength();
  const char *Name = ValName->getKeyData();
  
  if (Len < 5 || Name[4] != '.' || Name[0] != 'l' || Name[1] != 'l'
      || Name[2] != 'v' || Name[3] != 'm')
    return 0;  // All intrinsics start with 'llvm.'

#define GET_FUNCTION_RECOGNIZER
#include "llvm/Intrinsics.gen"
#undef GET_FUNCTION_RECOGNIZER
  return 0;
}

std::string Intrinsic::getName(ID id, const Type **Tys, unsigned numTys) { 
  assert(id < num_intrinsics && "Invalid intrinsic ID!");
  const char * const Table[] = {
    "not_intrinsic",
#define GET_INTRINSIC_NAME_TABLE
#include "llvm/Intrinsics.gen"
#undef GET_INTRINSIC_NAME_TABLE
  };
  if (numTys == 0)
    return Table[id];
  std::string Result(Table[id]);
  for (unsigned i = 0; i < numTys; ++i) {
    if (const PointerType* PTyp = dyn_cast<PointerType>(Tys[i])) {
      Result += ".p" + llvm::utostr(PTyp->getAddressSpace()) + 
                EVT::getEVT(PTyp->getElementType()).getEVTString();
    }
    else if (Tys[i])
      Result += "." + EVT::getEVT(Tys[i]).getEVTString();
  }
  return Result;
}

const FunctionType *Intrinsic::getType(LLVMContext &Context,
                                       ID id, const Type **Tys, 
                                       unsigned numTys) {
  const Type *ResultTy = NULL;
  std::vector<const Type*> ArgTys;
  bool IsVarArg = false;
  
#define GET_INTRINSIC_GENERATOR
#include "llvm/Intrinsics.gen"
#undef GET_INTRINSIC_GENERATOR

  return FunctionType::get(ResultTy, ArgTys, IsVarArg); 
}

bool Intrinsic::isOverloaded(ID id) {
  const bool OTable[] = {
    false,
#define GET_INTRINSIC_OVERLOAD_TABLE
#include "llvm/Intrinsics.gen"
#undef GET_INTRINSIC_OVERLOAD_TABLE
  };
  return OTable[id];
}

/// This defines the "Intrinsic::getAttributes(ID id)" method.
#define GET_INTRINSIC_ATTRIBUTES
#include "llvm/Intrinsics.gen"
#undef GET_INTRINSIC_ATTRIBUTES

Function *Intrinsic::getDeclaration(Module *M, ID id, const Type **Tys, 
                                    unsigned numTys) {
  // There can never be multiple globals with the same name of different types,
  // because intrinsics must be a specific type.
  return
    cast<Function>(M->getOrInsertFunction(getName(id, Tys, numTys),
                                          getType(M->getContext(),
                                                  id, Tys, numTys)));
}

// This defines the "Intrinsic::getIntrinsicForGCCBuiltin()" method.
#define GET_LLVM_INTRINSIC_FOR_GCC_BUILTIN
#include "llvm/Intrinsics.gen"
#undef GET_LLVM_INTRINSIC_FOR_GCC_BUILTIN

  /// hasAddressTaken - returns true if there are any uses of this function
  /// other than direct calls or invokes to it.
bool Function::hasAddressTaken() const {
  for (Value::use_const_iterator I = use_begin(), E = use_end(); I != E; ++I) {
    if (I.getOperandNo() != 0 ||
        (!isa<CallInst>(*I) && !isa<InvokeInst>(*I)))
      return true;
  }
  return false;
}

// vim: sw=2 ai
