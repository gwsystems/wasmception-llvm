//===- DeadStoreElimination.cpp - Fast Dead Store Elimination -------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements a trivial dead store elimination that only considers
// basic-block local redundant stores.
//
// FIXME: This should eventually be extended to be a post-dominator tree
// traversal.  Doing so would be pretty trivial.
//
//===----------------------------------------------------------------------===//

#define DEBUG_TYPE "dse"
#include "llvm/Transforms/Scalar.h"
#include "llvm/Constants.h"
#include "llvm/Function.h"
#include "llvm/Instructions.h"
#include "llvm/IntrinsicInst.h"
#include "llvm/Pass.h"
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/Analysis/AliasAnalysis.h"
#include "llvm/Analysis/Dominators.h"
#include "llvm/Analysis/MemoryBuiltins.h"
#include "llvm/Analysis/MemoryDependenceAnalysis.h"
#include "llvm/Target/TargetData.h"
#include "llvm/Transforms/Utils/Local.h"
using namespace llvm;

STATISTIC(NumFastStores, "Number of stores deleted");
STATISTIC(NumFastOther , "Number of other instrs removed");

namespace {
  struct DSE : public FunctionPass {
    AliasAnalysis *AA;
    MemoryDependenceAnalysis *MD;

    static char ID; // Pass identification, replacement for typeid
    DSE() : FunctionPass(ID), AA(0), MD(0) {
      initializeDSEPass(*PassRegistry::getPassRegistry());
    }

    virtual bool runOnFunction(Function &F) {
      AA = &getAnalysis<AliasAnalysis>();
      MD = &getAnalysis<MemoryDependenceAnalysis>();
      DominatorTree &DT = getAnalysis<DominatorTree>();
      
      bool Changed = false;
      for (Function::iterator I = F.begin(), E = F.end(); I != E; ++I)
        // Only check non-dead blocks.  Dead blocks may have strange pointer
        // cycles that will confuse alias analysis.
        if (DT.isReachableFromEntry(I))
          Changed |= runOnBasicBlock(*I);
      
      AA = 0; MD = 0;
      return Changed;
    }
    
    bool runOnBasicBlock(BasicBlock &BB);
    bool HandleFree(CallInst *F);
    bool handleEndBlock(BasicBlock &BB);
    bool RemoveUndeadPointers(Value *Ptr, uint64_t killPointerSize,
                              BasicBlock::iterator &BBI,
                              SmallPtrSet<Value*, 64> &deadPointers);
    void DeleteDeadInstruction(Instruction *I,
                               SmallPtrSet<Value*, 64> *deadPointers = 0);
    

    // getAnalysisUsage - We require post dominance frontiers (aka Control
    // Dependence Graph)
    virtual void getAnalysisUsage(AnalysisUsage &AU) const {
      AU.setPreservesCFG();
      AU.addRequired<DominatorTree>();
      AU.addRequired<AliasAnalysis>();
      AU.addRequired<MemoryDependenceAnalysis>();
      AU.addPreserved<AliasAnalysis>();
      AU.addPreserved<DominatorTree>();
      AU.addPreserved<MemoryDependenceAnalysis>();
    }
  };
}

char DSE::ID = 0;
INITIALIZE_PASS_BEGIN(DSE, "dse", "Dead Store Elimination", false, false)
INITIALIZE_PASS_DEPENDENCY(DominatorTree)
INITIALIZE_PASS_DEPENDENCY(MemoryDependenceAnalysis)
INITIALIZE_AG_DEPENDENCY(AliasAnalysis)
INITIALIZE_PASS_END(DSE, "dse", "Dead Store Elimination", false, false)

FunctionPass *llvm::createDeadStoreEliminationPass() { return new DSE(); }

/// hasMemoryWrite - Does this instruction write some memory?  This only returns
/// true for things that we can analyze with other helpers below.
static bool hasMemoryWrite(Instruction *I) {
  if (isa<StoreInst>(I))
    return true;
  if (IntrinsicInst *II = dyn_cast<IntrinsicInst>(I)) {
    switch (II->getIntrinsicID()) {
    default:
      return false;
    case Intrinsic::memset:
    case Intrinsic::memmove:
    case Intrinsic::memcpy:
    case Intrinsic::init_trampoline:
    case Intrinsic::lifetime_end:
      return true;
    }
  }
  return false;
}

/// getLocForWrite - Return a Location stored to by the specified instruction.
static AliasAnalysis::Location
getLocForWrite(Instruction *Inst, AliasAnalysis &AA) {
  if (StoreInst *SI = dyn_cast<StoreInst>(Inst))
    return AA.getLocation(SI);
  
  if (MemIntrinsic *MI = dyn_cast<MemIntrinsic>(Inst)) {
    // memcpy/memmove/memset.
    AliasAnalysis::Location Loc = AA.getLocationForDest(MI);
    // If we don't have target data around, an unknown size in Location means
    // that we should use the size of the pointee type.  This isn't valid for
    // memset/memcpy, which writes more than an i8.
    if (Loc.Size == AliasAnalysis::UnknownSize && AA.getTargetData() == 0)
      return AliasAnalysis::Location();
    return Loc;
  }
  
  IntrinsicInst *II = dyn_cast<IntrinsicInst>(Inst);
  if (II == 0) return AliasAnalysis::Location();
  
  switch (II->getIntrinsicID()) {
  default: return AliasAnalysis::Location(); // Unhandled intrinsic.
  case Intrinsic::init_trampoline:
    // If we don't have target data around, an unknown size in Location means
    // that we should use the size of the pointee type.  This isn't valid for
    // init.trampoline, which writes more than an i8.
    if (AA.getTargetData() == 0) return AliasAnalysis::Location();
      
    // FIXME: We don't know the size of the trampoline, so we can't really
    // handle it here.
    return AliasAnalysis::Location(II->getArgOperand(0));
  case Intrinsic::lifetime_end: {
    uint64_t Len = cast<ConstantInt>(II->getArgOperand(0))->getZExtValue();
    return AliasAnalysis::Location(II->getArgOperand(1), Len);
  }
  }
}

/// isRemovable - If the value of this instruction and the memory it writes to
/// is unused, may we delete this instruction?
static bool isRemovable(Instruction *I) {
  // Don't remove volatile stores.
  if (StoreInst *SI = dyn_cast<StoreInst>(I))
    return !SI->isVolatile();
  
  IntrinsicInst *II = cast<IntrinsicInst>(I);
  switch (II->getIntrinsicID()) {
  default: assert(0 && "doesn't pass 'hasMemoryWrite' predicate");
  case Intrinsic::lifetime_end:
    // Never remove dead lifetime_end's, e.g. because it is followed by a
    // free.
    return false;
  case Intrinsic::init_trampoline:
    // Always safe to remove init_trampoline.
    return true;
    
  case Intrinsic::memset:
  case Intrinsic::memmove:
  case Intrinsic::memcpy:
    // Don't remove volatile memory intrinsics.
    return !cast<MemIntrinsic>(II)->isVolatile();
  }
}

/// getPointerOperand - Return the pointer that is being written to.
static Value *getPointerOperand(Instruction *I) {
  assert(hasMemoryWrite(I));
  if (StoreInst *SI = dyn_cast<StoreInst>(I))
    return SI->getPointerOperand();
  if (MemIntrinsic *MI = dyn_cast<MemIntrinsic>(I))
    return MI->getArgOperand(0);

  IntrinsicInst *II = cast<IntrinsicInst>(I);
  switch (II->getIntrinsicID()) {
  default: assert(false && "Unexpected intrinsic!");
  case Intrinsic::init_trampoline:
    return II->getArgOperand(0);
  case Intrinsic::lifetime_end:
    return II->getArgOperand(1);
  }
}

static uint64_t getPointerSize(Value *V, AliasAnalysis &AA) {
  const TargetData *TD = AA.getTargetData();
  if (TD == 0)
    return AliasAnalysis::UnknownSize;
  
  if (AllocaInst *A = dyn_cast<AllocaInst>(V)) {
    // Get size information for the alloca
    if (ConstantInt *C = dyn_cast<ConstantInt>(A->getArraySize()))
      return C->getZExtValue() * TD->getTypeAllocSize(A->getAllocatedType());
    return AliasAnalysis::UnknownSize;
  }
  
  assert(isa<Argument>(V) && "Expected AllocaInst or Argument!");
  const PointerType *PT = cast<PointerType>(V->getType());
  return TD->getTypeAllocSize(PT->getElementType());
}


/// isCompleteOverwrite - Return true if a store to the 'Later' location
/// completely overwrites a store to the 'Earlier' location.
static bool isCompleteOverwrite(const AliasAnalysis::Location &Later,
                                const AliasAnalysis::Location &Earlier,
                                AliasAnalysis &AA) {
  const Value *P1 = Later.Ptr->stripPointerCasts();
  const Value *P2 = Earlier.Ptr->stripPointerCasts();
  
  // Make sure that the start pointers are the same.
  if (P1 != P2)
    return false;

  // If we don't know the sizes of either access, then we can't do a comparison.
  if (Later.Size == AliasAnalysis::UnknownSize ||
      Earlier.Size == AliasAnalysis::UnknownSize) {
    // If we have no TargetData information around, then the size of the store
    // is inferrable from the pointee type.  If they are the same type, then we
    // know that the store is safe.
    if (AA.getTargetData() == 0)
      return Later.Ptr->getType() == Earlier.Ptr->getType();
    return false;
  }
  
  // Make sure that the Later size is >= the Earlier size.
  if (Later.Size < Earlier.Size)
    return false;
  
  return true;
}

bool DSE::runOnBasicBlock(BasicBlock &BB) {
  bool MadeChange = false;
  
  // Do a top-down walk on the BB.
  for (BasicBlock::iterator BBI = BB.begin(), BBE = BB.end(); BBI != BBE; ) {
    Instruction *Inst = BBI++;
    
    // Handle 'free' calls specially.
    if (CallInst *F = isFreeCall(Inst)) {
      MadeChange |= HandleFree(F);
      continue;
    }
    
    // If we find something that writes memory, get its memory dependence.
    if (!hasMemoryWrite(Inst))
      continue;

    MemDepResult InstDep = MD->getDependency(Inst);
    
    // Ignore non-local store liveness.
    // FIXME: cross-block DSE would be fun. :)
    if (InstDep.isNonLocal() || 
        // Ignore self dependence, which happens in the entry block of the
        // function.
        InstDep.getInst() == Inst)
      continue;
     
    // If we're storing the same value back to a pointer that we just
    // loaded from, then the store can be removed.
    if (StoreInst *SI = dyn_cast<StoreInst>(Inst)) {
      if (LoadInst *DepLoad = dyn_cast<LoadInst>(InstDep.getInst())) {
        if (SI->getPointerOperand() == DepLoad->getPointerOperand() &&
            SI->getOperand(0) == DepLoad && !SI->isVolatile()) {
          // DeleteDeadInstruction can delete the current instruction.  Save BBI
          // in case we need it.
          WeakVH NextInst(BBI);
          
          DeleteDeadInstruction(SI);
          
          if (NextInst == 0)  // Next instruction deleted.
            BBI = BB.begin();
          else if (BBI != BB.begin())  // Revisit this instruction if possible.
            --BBI;
          ++NumFastStores;
          MadeChange = true;
          continue;
        }
      }
    }
    
    // Figure out what location is being stored to.
    AliasAnalysis::Location Loc = getLocForWrite(Inst, *AA);

    // If we didn't get a useful location, fail.
    if (Loc.Ptr == 0)
      continue;
    
    while (!InstDep.isNonLocal()) {
      // Get the memory clobbered by the instruction we depend on.  MemDep will
      // skip any instructions that 'Loc' clearly doesn't interact with.  If we
      // end up depending on a may- or must-aliased load, then we can't optimize
      // away the store and we bail out.  However, if we depend on on something
      // that overwrites the memory location we *can* potentially optimize it.
      //
      // Find out what memory location the dependant instruction stores.
      Instruction *DepWrite = InstDep.getInst();
      AliasAnalysis::Location DepLoc = getLocForWrite(DepWrite, *AA);
      // If we didn't get a useful location, or if it isn't a size, bail out.
      if (DepLoc.Ptr == 0)
        break;

      // If we find a removable write that is completely obliterated by the
      // store to 'Loc' then we can remove it.
      if (isRemovable(DepWrite) && isCompleteOverwrite(Loc, DepLoc, *AA)) {
        // Delete the store and now-dead instructions that feed it.
        DeleteDeadInstruction(DepWrite);
        ++NumFastStores;
        MadeChange = true;
        
        // DeleteDeadInstruction can delete the current instruction in loop
        // cases, reset BBI.
        BBI = Inst;
        if (BBI != BB.begin())
          --BBI;
        break;
      }
      
      // If this is a may-aliased store that is clobbering the store value, we
      // can keep searching past it for another must-aliased pointer that stores
      // to the same location.  For example, in:
      //   store -> P
      //   store -> Q
      //   store -> P
      // we can remove the first store to P even though we don't know if P and Q
      // alias.
      if (DepWrite == &BB.front()) break;
      
      // Can't look past this instruction if it might read 'Loc'.
      if (AA->getModRefInfo(DepWrite, Loc) & AliasAnalysis::Ref)
        break;
        
      InstDep = MD->getPointerDependencyFrom(Loc, false, DepWrite, &BB);
    }
  }
  
  // If this block ends in a return, unwind, or unreachable, all allocas are
  // dead at its end, which means stores to them are also dead.
  if (BB.getTerminator()->getNumSuccessors() == 0)
    MadeChange |= handleEndBlock(BB);
  
  return MadeChange;
}

/// HandleFree - Handle frees of entire structures whose dependency is a store
/// to a field of that structure.
bool DSE::HandleFree(CallInst *F) {
  MemDepResult Dep = MD->getDependency(F);
  do {
    if (Dep.isNonLocal()) return false;
    
    Instruction *Dependency = Dep.getInst();
    if (!hasMemoryWrite(Dependency) || !isRemovable(Dependency))
      return false;
  
    Value *DepPointer = getPointerOperand(Dependency)->getUnderlyingObject();

    // Check for aliasing.
    if (AA->alias(F->getArgOperand(0), 1, DepPointer, 1) !=
          AliasAnalysis::MustAlias)
      return false;
  
    // DCE instructions only used to calculate that store
    DeleteDeadInstruction(Dependency);
    ++NumFastStores;

    // Inst's old Dependency is now deleted. Compute the next dependency,
    // which may also be dead, as in
    //    s[0] = 0;
    //    s[1] = 0; // This has just been deleted.
    //    free(s);
    Dep = MD->getDependency(F);
  } while (!Dep.isNonLocal());
  
  return true;
}

/// handleEndBlock - Remove dead stores to stack-allocated locations in the
/// function end block.  Ex:
/// %A = alloca i32
/// ...
/// store i32 1, i32* %A
/// ret void
bool DSE::handleEndBlock(BasicBlock &BB) {
  bool MadeChange = false;
  
  // Pointers alloca'd in this function are dead in the end block
  SmallPtrSet<Value*, 64> deadPointers;
  
  // Find all of the alloca'd pointers in the entry block.
  BasicBlock *Entry = BB.getParent()->begin();
  for (BasicBlock::iterator I = Entry->begin(), E = Entry->end(); I != E; ++I)
    if (AllocaInst *AI = dyn_cast<AllocaInst>(I))
      deadPointers.insert(AI);
  
  // Treat byval arguments the same, stores to them are dead at the end of the
  // function.
  for (Function::arg_iterator AI = BB.getParent()->arg_begin(),
       AE = BB.getParent()->arg_end(); AI != AE; ++AI)
    if (AI->hasByValAttr())
      deadPointers.insert(AI);
  
  // Scan the basic block backwards
  for (BasicBlock::iterator BBI = BB.end(); BBI != BB.begin(); ){
    --BBI;
    
    // If we find a store whose pointer is dead.
    if (hasMemoryWrite(BBI)) {
      if (isRemovable(BBI)) {
        // See through pointer-to-pointer bitcasts
        Value *pointerOperand = getPointerOperand(BBI)->getUnderlyingObject();

        // Alloca'd pointers or byval arguments (which are functionally like
        // alloca's) are valid candidates for removal.
        if (deadPointers.count(pointerOperand)) {
          // DCE instructions only used to calculate that store.
          Instruction *Dead = BBI;
          ++BBI;
          DeleteDeadInstruction(Dead, &deadPointers);
          ++NumFastStores;
          MadeChange = true;
          continue;
        }
      }
      
      // Because a memcpy or memmove is also a load, we can't skip it if we
      // didn't remove it.
      if (!isa<MemTransferInst>(BBI))
        continue;
    }
    
    Value *killPointer = 0;
    uint64_t killPointerSize = AliasAnalysis::UnknownSize;
    
    // If we encounter a use of the pointer, it is no longer considered dead
    if (LoadInst *L = dyn_cast<LoadInst>(BBI)) {
      // However, if this load is unused and not volatile, we can go ahead and
      // remove it, and not have to worry about it making our pointer undead!
      if (L->use_empty() && !L->isVolatile()) {
        ++BBI;
        DeleteDeadInstruction(L, &deadPointers);
        ++NumFastOther;
        MadeChange = true;
        continue;
      }
      
      killPointer = L->getPointerOperand();
    } else if (VAArgInst *V = dyn_cast<VAArgInst>(BBI)) {
      killPointer = V->getOperand(0);
    } else if (isa<MemTransferInst>(BBI) &&
               isa<ConstantInt>(cast<MemTransferInst>(BBI)->getLength())) {
      killPointer = cast<MemTransferInst>(BBI)->getSource();
      killPointerSize = cast<ConstantInt>(
                       cast<MemTransferInst>(BBI)->getLength())->getZExtValue();
    } else if (AllocaInst *A = dyn_cast<AllocaInst>(BBI)) {
      deadPointers.erase(A);
      
      // Dead alloca's can be DCE'd when we reach them
      if (A->use_empty()) {
        ++BBI;
        DeleteDeadInstruction(A, &deadPointers);
        ++NumFastOther;
        MadeChange = true;
      }
      
      continue;
    } else if (CallSite CS = cast<Value>(BBI)) {
      // If this call does not access memory, it can't
      // be undeadifying any of our pointers.
      if (AA->doesNotAccessMemory(CS))
        continue;
      
      unsigned modRef = 0;
      unsigned other = 0;
      
      // Remove any pointers made undead by the call from the dead set
      std::vector<Value*> dead;
      for (SmallPtrSet<Value*, 64>::iterator I = deadPointers.begin(),
           E = deadPointers.end(); I != E; ++I) {
        // HACK: if we detect that our AA is imprecise, it's not
        // worth it to scan the rest of the deadPointers set.  Just
        // assume that the AA will return ModRef for everything, and
        // go ahead and bail.
        if (modRef >= 16 && other == 0) {
          deadPointers.clear();
          return MadeChange;
        }
        
        // See if the call site touches it
        AliasAnalysis::ModRefResult A = 
          AA->getModRefInfo(CS, *I, getPointerSize(*I, *AA));
        
        if (A == AliasAnalysis::ModRef)
          ++modRef;
        else
          ++other;
        
        if (A == AliasAnalysis::ModRef || A == AliasAnalysis::Ref)
          dead.push_back(*I);
      }

      for (std::vector<Value*>::iterator I = dead.begin(), E = dead.end();
           I != E; ++I)
        deadPointers.erase(*I);
      
      continue;
    } else if (isInstructionTriviallyDead(BBI)) {
      // For any non-memory-affecting non-terminators, DCE them as we reach them
      Instruction *Inst = BBI;
      ++BBI;
      DeleteDeadInstruction(Inst, &deadPointers);
      ++NumFastOther;
      MadeChange = true;
      continue;
    }
    
    if (!killPointer)
      continue;

    killPointer = killPointer->getUnderlyingObject();

    // Deal with undead pointers
    MadeChange |= RemoveUndeadPointers(killPointer, killPointerSize, BBI,
                                       deadPointers);
  }
  
  return MadeChange;
}

/// RemoveUndeadPointers - check for uses of a pointer that make it
/// undead when scanning for dead stores to alloca's.
bool DSE::RemoveUndeadPointers(Value *killPointer, uint64_t killPointerSize,
                               BasicBlock::iterator &BBI,
                               SmallPtrSet<Value*, 64> &deadPointers) {
  // If the kill pointer can be easily reduced to an alloca,
  // don't bother doing extraneous AA queries.
  if (deadPointers.count(killPointer)) {
    deadPointers.erase(killPointer);
    return false;
  }
  
  // A global can't be in the dead pointer set.
  if (isa<GlobalValue>(killPointer))
    return false;
  
  bool MadeChange = false;
  
  SmallVector<Value*, 16> undead;
  
  for (SmallPtrSet<Value*, 64>::iterator I = deadPointers.begin(),
       E = deadPointers.end(); I != E; ++I) {
    // See if this pointer could alias it
    AliasAnalysis::AliasResult A = AA->alias(*I, getPointerSize(*I, *AA),
                                             killPointer, killPointerSize);

    // If it must-alias and a store, we can delete it
    if (isa<StoreInst>(BBI) && A == AliasAnalysis::MustAlias) {
      StoreInst *S = cast<StoreInst>(BBI);

      // Remove it!
      ++BBI;
      DeleteDeadInstruction(S, &deadPointers);
      ++NumFastStores;
      MadeChange = true;

      continue;

      // Otherwise, it is undead
    } else if (A != AliasAnalysis::NoAlias)
      undead.push_back(*I);
  }

  for (SmallVector<Value*, 16>::iterator I = undead.begin(), E = undead.end();
       I != E; ++I)
    deadPointers.erase(*I);
  
  return MadeChange;
}

/// DeleteDeadInstruction - Delete this instruction.  Before we do, go through
/// and zero out all the operands of this instruction.  If any of them become
/// dead, delete them and the computation tree that feeds them.
///
/// If ValueSet is non-null, remove any deleted instructions from it as well.
///
void DSE::DeleteDeadInstruction(Instruction *I,
                                SmallPtrSet<Value*, 64> *ValueSet) {
  SmallVector<Instruction*, 32> NowDeadInsts;
  
  NowDeadInsts.push_back(I);
  --NumFastOther;

  // Before we touch this instruction, remove it from memdep!
  do {
    Instruction *DeadInst = NowDeadInsts.pop_back_val();
    
    ++NumFastOther;
    
    // This instruction is dead, zap it, in stages.  Start by removing it from
    // MemDep, which needs to know the operands and needs it to be in the
    // function.
    MD->removeInstruction(DeadInst);
    
    for (unsigned op = 0, e = DeadInst->getNumOperands(); op != e; ++op) {
      Value *Op = DeadInst->getOperand(op);
      DeadInst->setOperand(op, 0);
      
      // If this operand just became dead, add it to the NowDeadInsts list.
      if (!Op->use_empty()) continue;
      
      if (Instruction *OpI = dyn_cast<Instruction>(Op))
        if (isInstructionTriviallyDead(OpI))
          NowDeadInsts.push_back(OpI);
    }
    
    DeadInst->eraseFromParent();
    
    if (ValueSet) ValueSet->erase(DeadInst);
  } while (!NowDeadInsts.empty());
}

