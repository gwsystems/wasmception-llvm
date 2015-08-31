//===- BasicAliasAnalysis.h - Stateless, local Alias Analysis ---*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
/// \file
/// This is the interface for LLVM's primary stateless and local alias analysis.
///
//===----------------------------------------------------------------------===//

#ifndef LLVM_ANALYSIS_BASICALIASANALYSIS_H
#define LLVM_ANALYSIS_BASICALIASANALYSIS_H

#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/Analysis/AliasAnalysis.h"
#include "llvm/Analysis/AssumptionCache.h"
#include "llvm/Analysis/TargetLibraryInfo.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/GetElementPtrTypeIterator.h"
#include "llvm/IR/Instruction.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/Pass.h"
#include "llvm/Support/ErrorHandling.h"

namespace llvm {

/// This is the primary alias analysis implementation.
struct BasicAliasAnalysis : public ImmutablePass, public AliasAnalysis {
  static char ID; // Class identification, replacement for typeinfo

#ifndef NDEBUG
  static const Function *getParent(const Value *V) {
    if (const Instruction *inst = dyn_cast<Instruction>(V))
      return inst->getParent()->getParent();

    if (const Argument *arg = dyn_cast<Argument>(V))
      return arg->getParent();

    return nullptr;
  }

  static bool notDifferentParent(const Value *O1, const Value *O2) {

    const Function *F1 = getParent(O1);
    const Function *F2 = getParent(O2);

    return !F1 || !F2 || F1 == F2;
  }
#endif

  BasicAliasAnalysis() : ImmutablePass(ID) {
    initializeBasicAliasAnalysisPass(*PassRegistry::getPassRegistry());
  }

  bool doInitialization(Module &M) override;

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.addRequired<AliasAnalysis>();
    AU.addRequired<AssumptionCacheTracker>();
    AU.addRequired<TargetLibraryInfoWrapperPass>();
  }

  AliasResult alias(const MemoryLocation &LocA,
                    const MemoryLocation &LocB) override {
    assert(AliasCache.empty() && "AliasCache must be cleared after use!");
    assert(notDifferentParent(LocA.Ptr, LocB.Ptr) &&
           "BasicAliasAnalysis doesn't support interprocedural queries.");
    AliasResult Alias = aliasCheck(LocA.Ptr, LocA.Size, LocA.AATags, LocB.Ptr,
                                   LocB.Size, LocB.AATags);
    // AliasCache rarely has more than 1 or 2 elements, always use
    // shrink_and_clear so it quickly returns to the inline capacity of the
    // SmallDenseMap if it ever grows larger.
    // FIXME: This should really be shrink_to_inline_capacity_and_clear().
    AliasCache.shrink_and_clear();
    VisitedPhiBBs.clear();
    return Alias;
  }

  ModRefInfo getModRefInfo(ImmutableCallSite CS,
                           const MemoryLocation &Loc) override;

  ModRefInfo getModRefInfo(ImmutableCallSite CS1,
                           ImmutableCallSite CS2) override;

  /// Chases pointers until we find a (constant global) or not.
  bool pointsToConstantMemory(const MemoryLocation &Loc, bool OrLocal) override;

  /// Get the location associated with a pointer argument of a callsite.
  ModRefInfo getArgModRefInfo(ImmutableCallSite CS, unsigned ArgIdx) override;

  /// Returns the behavior when calling the given call site.
  FunctionModRefBehavior getModRefBehavior(ImmutableCallSite CS) override;

  /// Returns the behavior when calling the given function. For use when the
  /// call site is not known.
  FunctionModRefBehavior getModRefBehavior(const Function *F) override;

  /// This method is used when a pass implements an analysis interface through
  /// multiple inheritance.  If needed, it should override this to adjust the
  /// this pointer as needed for the specified pass info.
  void *getAdjustedAnalysisPointer(const void *ID) override {
    if (ID == &AliasAnalysis::ID)
      return (AliasAnalysis *)this;
    return this;
  }

private:
  // A linear transformation of a Value; this class represents ZExt(SExt(V,
  // SExtBits), ZExtBits) * Scale + Offset.
  struct VariableGEPIndex {

    // An opaque Value - we can't decompose this further.
    const Value *V;

    // We need to track what extensions we've done as we consider the same Value
    // with different extensions as different variables in a GEP's linear
    // expression;
    // e.g.: if V == -1, then sext(x) != zext(x).
    unsigned ZExtBits;
    unsigned SExtBits;

    int64_t Scale;

    bool operator==(const VariableGEPIndex &Other) const {
      return V == Other.V && ZExtBits == Other.ZExtBits &&
             SExtBits == Other.SExtBits && Scale == Other.Scale;
    }

    bool operator!=(const VariableGEPIndex &Other) const {
      return !operator==(Other);
    }
  };

  /// Track alias queries to guard against recursion.
  typedef std::pair<MemoryLocation, MemoryLocation> LocPair;
  typedef SmallDenseMap<LocPair, AliasResult, 8> AliasCacheTy;
  AliasCacheTy AliasCache;

  /// Tracks phi nodes we have visited.
  ///
  /// When interpret "Value" pointer equality as value equality we need to make
  /// sure that the "Value" is not part of a cycle. Otherwise, two uses could
  /// come from different "iterations" of a cycle and see different values for
  /// the same "Value" pointer.
  ///
  /// The following example shows the problem:
  ///   %p = phi(%alloca1, %addr2)
  ///   %l = load %ptr
  ///   %addr1 = gep, %alloca2, 0, %l
  ///   %addr2 = gep  %alloca2, 0, (%l + 1)
  ///      alias(%p, %addr1) -> MayAlias !
  ///   store %l, ...
  SmallPtrSet<const BasicBlock *, 8> VisitedPhiBBs;

  /// Tracks instructions visited by pointsToConstantMemory.
  SmallPtrSet<const Value *, 16> Visited;

  static const Value *
  GetLinearExpression(const Value *V, APInt &Scale, APInt &Offset,
                      unsigned &ZExtBits, unsigned &SExtBits,
                      const DataLayout &DL, unsigned Depth, AssumptionCache *AC,
                      DominatorTree *DT, bool &NSW, bool &NUW);

  static const Value *
  DecomposeGEPExpression(const Value *V, int64_t &BaseOffs,
                         SmallVectorImpl<VariableGEPIndex> &VarIndices,
                         bool &MaxLookupReached, const DataLayout &DL,
                         AssumptionCache *AC, DominatorTree *DT);
  /// \brief A Heuristic for aliasGEP that searches for a constant offset
  /// between the variables.
  ///
  /// GetLinearExpression has some limitations, as generally zext(%x + 1)
  /// != zext(%x) + zext(1) if the arithmetic overflows. GetLinearExpression
  /// will therefore conservatively refuse to decompose these expressions.
  /// However, we know that, for all %x, zext(%x) != zext(%x + 1), even if
  /// the addition overflows.
  bool
  constantOffsetHeuristic(const SmallVectorImpl<VariableGEPIndex> &VarIndices,
                          uint64_t V1Size, uint64_t V2Size, int64_t BaseOffset,
                          const DataLayout *DL, AssumptionCache *AC,
                          DominatorTree *DT);

  bool isValueEqualInPotentialCycles(const Value *V1, const Value *V2);

  void GetIndexDifference(SmallVectorImpl<VariableGEPIndex> &Dest,
                          const SmallVectorImpl<VariableGEPIndex> &Src);

  AliasResult aliasGEP(const GEPOperator *V1, uint64_t V1Size,
                       const AAMDNodes &V1AAInfo, const Value *V2,
                       uint64_t V2Size, const AAMDNodes &V2AAInfo,
                       const Value *UnderlyingV1, const Value *UnderlyingV2);

  AliasResult aliasPHI(const PHINode *PN, uint64_t PNSize,
                       const AAMDNodes &PNAAInfo, const Value *V2,
                       uint64_t V2Size, const AAMDNodes &V2AAInfo);

  AliasResult aliasSelect(const SelectInst *SI, uint64_t SISize,
                          const AAMDNodes &SIAAInfo, const Value *V2,
                          uint64_t V2Size, const AAMDNodes &V2AAInfo);

  AliasResult aliasCheck(const Value *V1, uint64_t V1Size, AAMDNodes V1AATag,
                         const Value *V2, uint64_t V2Size, AAMDNodes V2AATag);
};

//===--------------------------------------------------------------------===//
//
// createBasicAliasAnalysisPass - This pass implements the stateless alias
// analysis.
//
ImmutablePass *createBasicAliasAnalysisPass();

}

#endif
