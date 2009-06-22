//===- llvm/Analysis/ScalarEvolution.h - Scalar Evolution -------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// The ScalarEvolution class is an LLVM pass which can be used to analyze and
// catagorize scalar expressions in loops.  It specializes in recognizing
// general induction variables, representing them with the abstract and opaque
// SCEV class.  Given this analysis, trip counts of loops and other important
// properties can be obtained.
//
// This analysis is primarily useful for induction variable substitution and
// strength reduction.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_ANALYSIS_SCALAREVOLUTION_H
#define LLVM_ANALYSIS_SCALAREVOLUTION_H

#include "llvm/Pass.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Support/DataTypes.h"
#include "llvm/Support/ValueHandle.h"
#include "llvm/ADT/DenseMap.h"
#include <iosfwd>

namespace llvm {
  class APInt;
  class ConstantInt;
  class Type;
  class ScalarEvolution;
  class TargetData;
  class SCEVConstant;
  class SCEVTruncateExpr;
  class SCEVZeroExtendExpr;
  class SCEVCommutativeExpr;
  class SCEVUDivExpr;
  class SCEVSignExtendExpr;
  class SCEVAddRecExpr;
  class SCEVUnknown;

  /// SCEV - This class represents an analyzed expression in the program.  These
  /// are reference-counted opaque objects that the client is not allowed to
  /// do much with directly.
  ///
  class SCEV {
    const unsigned SCEVType;      // The SCEV baseclass this node corresponds to

    SCEV(const SCEV &);            // DO NOT IMPLEMENT
    void operator=(const SCEV &);  // DO NOT IMPLEMENT
  protected:
    virtual ~SCEV();
  public:
    explicit SCEV(unsigned SCEVTy) : 
      SCEVType(SCEVTy) {}

    unsigned getSCEVType() const { return SCEVType; }

    /// isLoopInvariant - Return true if the value of this SCEV is unchanging in
    /// the specified loop.
    virtual bool isLoopInvariant(const Loop *L) const = 0;

    /// hasComputableLoopEvolution - Return true if this SCEV changes value in a
    /// known way in the specified loop.  This property being true implies that
    /// the value is variant in the loop AND that we can emit an expression to
    /// compute the value of the expression at any particular loop iteration.
    virtual bool hasComputableLoopEvolution(const Loop *L) const = 0;

    /// getType - Return the LLVM type of this SCEV expression.
    ///
    virtual const Type *getType() const = 0;

    /// isZero - Return true if the expression is a constant zero.
    ///
    bool isZero() const;

    /// isOne - Return true if the expression is a constant one.
    ///
    bool isOne() const;

    /// replaceSymbolicValuesWithConcrete - If this SCEV internally references
    /// the symbolic value "Sym", construct and return a new SCEV that produces
    /// the same value, but which uses the concrete value Conc instead of the
    /// symbolic value.  If this SCEV does not use the symbolic value, it
    /// returns itself.
    virtual const SCEV*
    replaceSymbolicValuesWithConcrete(const SCEV* Sym,
                                      const SCEV* Conc,
                                      ScalarEvolution &SE) const = 0;

    /// dominates - Return true if elements that makes up this SCEV dominates
    /// the specified basic block.
    virtual bool dominates(BasicBlock *BB, DominatorTree *DT) const = 0;

    /// print - Print out the internal representation of this scalar to the
    /// specified stream.  This should really only be used for debugging
    /// purposes.
    virtual void print(raw_ostream &OS) const = 0;
    void print(std::ostream &OS) const;
    void print(std::ostream *OS) const { if (OS) print(*OS); }

    /// dump - This method is used for debugging.
    ///
    void dump() const;
  };

  inline raw_ostream &operator<<(raw_ostream &OS, const SCEV &S) {
    S.print(OS);
    return OS;
  }

  inline std::ostream &operator<<(std::ostream &OS, const SCEV &S) {
    S.print(OS);
    return OS;
  }

  /// SCEVCouldNotCompute - An object of this class is returned by queries that
  /// could not be answered.  For example, if you ask for the number of
  /// iterations of a linked-list traversal loop, you will get one of these.
  /// None of the standard SCEV operations are valid on this class, it is just a
  /// marker.
  struct SCEVCouldNotCompute : public SCEV {
    SCEVCouldNotCompute();

    // None of these methods are valid for this object.
    virtual bool isLoopInvariant(const Loop *L) const;
    virtual const Type *getType() const;
    virtual bool hasComputableLoopEvolution(const Loop *L) const;
    virtual void print(raw_ostream &OS) const;
    virtual const SCEV*
    replaceSymbolicValuesWithConcrete(const SCEV* Sym,
                                      const SCEV* Conc,
                                      ScalarEvolution &SE) const;

    virtual bool dominates(BasicBlock *BB, DominatorTree *DT) const {
      return true;
    }

    /// Methods for support type inquiry through isa, cast, and dyn_cast:
    static inline bool classof(const SCEVCouldNotCompute *S) { return true; }
    static bool classof(const SCEV *S);
  };

  /// ScalarEvolution - This class is the main scalar evolution driver.  Because
  /// client code (intentionally) can't do much with the SCEV objects directly,
  /// they must ask this class for services.
  ///
  class ScalarEvolution : public FunctionPass {
    /// SCEVCallbackVH - A CallbackVH to arrange for ScalarEvolution to be
    /// notified whenever a Value is deleted.
    class SCEVCallbackVH : public CallbackVH {
      ScalarEvolution *SE;
      virtual void deleted();
      virtual void allUsesReplacedWith(Value *New);
    public:
      SCEVCallbackVH(Value *V, ScalarEvolution *SE = 0);
    };

    friend class SCEVCallbackVH;
    friend class SCEVExpander;

    /// F - The function we are analyzing.
    ///
    Function *F;

    /// LI - The loop information for the function we are currently analyzing.
    ///
    LoopInfo *LI;

    /// TD - The target data information for the target we are targetting.
    ///
    TargetData *TD;

    /// CouldNotCompute - This SCEV is used to represent unknown trip
    /// counts and things.
    const SCEV* CouldNotCompute;

    /// Scalars - This is a cache of the scalars we have analyzed so far.
    ///
    std::map<SCEVCallbackVH, const SCEV*> Scalars;

    /// BackedgeTakenInfo - Information about the backedge-taken count
    /// of a loop. This currently inclues an exact count and a maximum count.
    ///
    struct BackedgeTakenInfo {
      /// Exact - An expression indicating the exact backedge-taken count of
      /// the loop if it is known, or a SCEVCouldNotCompute otherwise.
      const SCEV* Exact;

      /// Exact - An expression indicating the least maximum backedge-taken
      /// count of the loop that is known, or a SCEVCouldNotCompute.
      const SCEV* Max;

      /*implicit*/ BackedgeTakenInfo(const SCEV* exact) :
        Exact(exact), Max(exact) {}

      BackedgeTakenInfo(const SCEV* exact, const SCEV* max) :
        Exact(exact), Max(max) {}

      /// hasAnyInfo - Test whether this BackedgeTakenInfo contains any
      /// computed information, or whether it's all SCEVCouldNotCompute
      /// values.
      bool hasAnyInfo() const {
        return !isa<SCEVCouldNotCompute>(Exact) ||
               !isa<SCEVCouldNotCompute>(Max);
      }
    };

    /// BackedgeTakenCounts - Cache the backedge-taken count of the loops for
    /// this function as they are computed.
    std::map<const Loop*, BackedgeTakenInfo> BackedgeTakenCounts;

    /// ConstantEvolutionLoopExitValue - This map contains entries for all of
    /// the PHI instructions that we attempt to compute constant evolutions for.
    /// This allows us to avoid potentially expensive recomputation of these
    /// properties.  An instruction maps to null if we are unable to compute its
    /// exit value.
    std::map<PHINode*, Constant*> ConstantEvolutionLoopExitValue;

    /// ValuesAtScopes - This map contains entries for all the instructions
    /// that we attempt to compute getSCEVAtScope information for without
    /// using SCEV techniques, which can be expensive.
    std::map<Instruction *, std::map<const Loop *, Constant *> > ValuesAtScopes;

    /// createSCEV - We know that there is no SCEV for the specified value.
    /// Analyze the expression.
    const SCEV* createSCEV(Value *V);

    /// createNodeForPHI - Provide the special handling we need to analyze PHI
    /// SCEVs.
    const SCEV* createNodeForPHI(PHINode *PN);

    /// createNodeForGEP - Provide the special handling we need to analyze GEP
    /// SCEVs.
    const SCEV* createNodeForGEP(User *GEP);

    /// ReplaceSymbolicValueWithConcrete - This looks up the computed SCEV value
    /// for the specified instruction and replaces any references to the
    /// symbolic value SymName with the specified value.  This is used during
    /// PHI resolution.
    void ReplaceSymbolicValueWithConcrete(Instruction *I,
                                          const SCEV* SymName,
                                          const SCEV* NewVal);

    /// getBECount - Subtract the end and start values and divide by the step,
    /// rounding up, to get the number of times the backedge is executed. Return
    /// CouldNotCompute if an intermediate computation overflows.
    const SCEV* getBECount(const SCEV* Start,
                          const SCEV* End,
                          const SCEV* Step);

    /// getBackedgeTakenInfo - Return the BackedgeTakenInfo for the given
    /// loop, lazily computing new values if the loop hasn't been analyzed
    /// yet.
    const BackedgeTakenInfo &getBackedgeTakenInfo(const Loop *L);

    /// ComputeBackedgeTakenCount - Compute the number of times the specified
    /// loop will iterate.
    BackedgeTakenInfo ComputeBackedgeTakenCount(const Loop *L);

    /// ComputeBackedgeTakenCountFromExit - Compute the number of times the
    /// backedge of the specified loop will execute if it exits via the
    /// specified block.
    BackedgeTakenInfo ComputeBackedgeTakenCountFromExit(const Loop *L,
                                                      BasicBlock *ExitingBlock);

    /// ComputeBackedgeTakenCountFromExitCond - Compute the number of times the
    /// backedge of the specified loop will execute if its exit condition
    /// were a conditional branch of ExitCond, TBB, and FBB.
    BackedgeTakenInfo
      ComputeBackedgeTakenCountFromExitCond(const Loop *L,
                                            Value *ExitCond,
                                            BasicBlock *TBB,
                                            BasicBlock *FBB);

    /// ComputeBackedgeTakenCountFromExitCondICmp - Compute the number of
    /// times the backedge of the specified loop will execute if its exit
    /// condition were a conditional branch of the ICmpInst ExitCond, TBB,
    /// and FBB.
    BackedgeTakenInfo
      ComputeBackedgeTakenCountFromExitCondICmp(const Loop *L,
                                                ICmpInst *ExitCond,
                                                BasicBlock *TBB,
                                                BasicBlock *FBB);

    /// ComputeLoadConstantCompareBackedgeTakenCount - Given an exit condition
    /// of 'icmp op load X, cst', try to see if we can compute the trip count.
    const SCEV*
      ComputeLoadConstantCompareBackedgeTakenCount(LoadInst *LI,
                                                   Constant *RHS,
                                                   const Loop *L,
                                                   ICmpInst::Predicate p);

    /// ComputeBackedgeTakenCountExhaustively - If the trip is known to execute
    /// a constant number of times (the condition evolves only from constants),
    /// try to evaluate a few iterations of the loop until we get the exit
    /// condition gets a value of ExitWhen (true or false).  If we cannot
    /// evaluate the trip count of the loop, return CouldNotCompute.
    const SCEV* ComputeBackedgeTakenCountExhaustively(const Loop *L, Value *Cond,
                                                     bool ExitWhen);

    /// HowFarToZero - Return the number of times a backedge comparing the
    /// specified value to zero will execute.  If not computable, return
    /// CouldNotCompute.
    const SCEV* HowFarToZero(const SCEV *V, const Loop *L);

    /// HowFarToNonZero - Return the number of times a backedge checking the
    /// specified value for nonzero will execute.  If not computable, return
    /// CouldNotCompute.
    const SCEV* HowFarToNonZero(const SCEV *V, const Loop *L);

    /// HowManyLessThans - Return the number of times a backedge containing the
    /// specified less-than comparison will execute.  If not computable, return
    /// CouldNotCompute. isSigned specifies whether the less-than is signed.
    BackedgeTakenInfo HowManyLessThans(const SCEV *LHS, const SCEV *RHS,
                                       const Loop *L, bool isSigned);

    /// getLoopPredecessor - If the given loop's header has exactly one unique
    /// predecessor outside the loop, return it. Otherwise return null.
    BasicBlock *getLoopPredecessor(const Loop *L);

    /// getPredecessorWithUniqueSuccessorForBB - Return a predecessor of BB
    /// (which may not be an immediate predecessor) which has exactly one
    /// successor from which BB is reachable, or null if no such block is
    /// found.
    BasicBlock* getPredecessorWithUniqueSuccessorForBB(BasicBlock *BB);

    /// getConstantEvolutionLoopExitValue - If we know that the specified Phi is
    /// in the header of its containing loop, we know the loop executes a
    /// constant number of times, and the PHI node is just a recurrence
    /// involving constants, fold it.
    Constant *getConstantEvolutionLoopExitValue(PHINode *PN, const APInt& BEs,
                                                const Loop *L);

    /// forgetLoopPHIs - Delete the memoized SCEVs associated with the
    /// PHI nodes in the given loop. This is used when the trip count of
    /// the loop may have changed.
    void forgetLoopPHIs(const Loop *L);

  public:
    static char ID; // Pass identification, replacement for typeid
    ScalarEvolution();

    /// isSCEVable - Test if values of the given type are analyzable within
    /// the SCEV framework. This primarily includes integer types, and it
    /// can optionally include pointer types if the ScalarEvolution class
    /// has access to target-specific information.
    bool isSCEVable(const Type *Ty) const;

    /// getTypeSizeInBits - Return the size in bits of the specified type,
    /// for which isSCEVable must return true.
    uint64_t getTypeSizeInBits(const Type *Ty) const;

    /// getEffectiveSCEVType - Return a type with the same bitwidth as
    /// the given type and which represents how SCEV will treat the given
    /// type, for which isSCEVable must return true. For pointer types,
    /// this is the pointer-sized integer type.
    const Type *getEffectiveSCEVType(const Type *Ty) const;

    /// getSCEV - Return a SCEV expression handle for the full generality of the
    /// specified expression.
    const SCEV* getSCEV(Value *V);

    const SCEV* getConstant(ConstantInt *V);
    const SCEV* getConstant(const APInt& Val);
    const SCEV* getConstant(const Type *Ty, uint64_t V, bool isSigned = false);
    const SCEV* getTruncateExpr(const SCEV* Op, const Type *Ty);
    const SCEV* getZeroExtendExpr(const SCEV* Op, const Type *Ty);
    const SCEV* getSignExtendExpr(const SCEV* Op, const Type *Ty);
    const SCEV* getAnyExtendExpr(const SCEV* Op, const Type *Ty);
    const SCEV* getAddExpr(SmallVectorImpl<const SCEV*> &Ops);
    const SCEV* getAddExpr(const SCEV* LHS, const SCEV* RHS) {
      SmallVector<const SCEV*, 2> Ops;
      Ops.push_back(LHS);
      Ops.push_back(RHS);
      return getAddExpr(Ops);
    }
    const SCEV* getAddExpr(const SCEV* Op0, const SCEV* Op1,
                          const SCEV* Op2) {
      SmallVector<const SCEV*, 3> Ops;
      Ops.push_back(Op0);
      Ops.push_back(Op1);
      Ops.push_back(Op2);
      return getAddExpr(Ops);
    }
    const SCEV* getMulExpr(SmallVectorImpl<const SCEV*> &Ops);
    const SCEV* getMulExpr(const SCEV* LHS, const SCEV* RHS) {
      SmallVector<const SCEV*, 2> Ops;
      Ops.push_back(LHS);
      Ops.push_back(RHS);
      return getMulExpr(Ops);
    }
    const SCEV* getUDivExpr(const SCEV* LHS, const SCEV* RHS);
    const SCEV* getAddRecExpr(const SCEV* Start, const SCEV* Step,
                             const Loop *L);
    const SCEV* getAddRecExpr(SmallVectorImpl<const SCEV*> &Operands,
                             const Loop *L);
    const SCEV* getAddRecExpr(const SmallVectorImpl<const SCEV*> &Operands,
                             const Loop *L) {
      SmallVector<const SCEV*, 4> NewOp(Operands.begin(), Operands.end());
      return getAddRecExpr(NewOp, L);
    }
    const SCEV* getSMaxExpr(const SCEV* LHS, const SCEV* RHS);
    const SCEV* getSMaxExpr(SmallVectorImpl<const SCEV*> &Operands);
    const SCEV* getUMaxExpr(const SCEV* LHS, const SCEV* RHS);
    const SCEV* getUMaxExpr(SmallVectorImpl<const SCEV*> &Operands);
    const SCEV* getSMinExpr(const SCEV* LHS, const SCEV* RHS);
    const SCEV* getUMinExpr(const SCEV* LHS, const SCEV* RHS);
    const SCEV* getUnknown(Value *V);
    const SCEV* getCouldNotCompute();

    /// getNegativeSCEV - Return the SCEV object corresponding to -V.
    ///
    const SCEV* getNegativeSCEV(const SCEV* V);

    /// getNotSCEV - Return the SCEV object corresponding to ~V.
    ///
    const SCEV* getNotSCEV(const SCEV* V);

    /// getMinusSCEV - Return LHS-RHS.
    ///
    const SCEV* getMinusSCEV(const SCEV* LHS,
                            const SCEV* RHS);

    /// getTruncateOrZeroExtend - Return a SCEV corresponding to a conversion
    /// of the input value to the specified type.  If the type must be
    /// extended, it is zero extended.
    const SCEV* getTruncateOrZeroExtend(const SCEV* V, const Type *Ty);

    /// getTruncateOrSignExtend - Return a SCEV corresponding to a conversion
    /// of the input value to the specified type.  If the type must be
    /// extended, it is sign extended.
    const SCEV* getTruncateOrSignExtend(const SCEV* V, const Type *Ty);

    /// getNoopOrZeroExtend - Return a SCEV corresponding to a conversion of
    /// the input value to the specified type.  If the type must be extended,
    /// it is zero extended.  The conversion must not be narrowing.
    const SCEV* getNoopOrZeroExtend(const SCEV* V, const Type *Ty);

    /// getNoopOrSignExtend - Return a SCEV corresponding to a conversion of
    /// the input value to the specified type.  If the type must be extended,
    /// it is sign extended.  The conversion must not be narrowing.
    const SCEV* getNoopOrSignExtend(const SCEV* V, const Type *Ty);

    /// getNoopOrAnyExtend - Return a SCEV corresponding to a conversion of
    /// the input value to the specified type. If the type must be extended,
    /// it is extended with unspecified bits. The conversion must not be
    /// narrowing.
    const SCEV* getNoopOrAnyExtend(const SCEV* V, const Type *Ty);

    /// getTruncateOrNoop - Return a SCEV corresponding to a conversion of the
    /// input value to the specified type.  The conversion must not be
    /// widening.
    const SCEV* getTruncateOrNoop(const SCEV* V, const Type *Ty);

    /// getIntegerSCEV - Given an integer or FP type, create a constant for the
    /// specified signed integer value and return a SCEV for the constant.
    const SCEV* getIntegerSCEV(int Val, const Type *Ty);

    /// getUMaxFromMismatchedTypes - Promote the operands to the wider of
    /// the types using zero-extension, and then perform a umax operation
    /// with them.
    const SCEV* getUMaxFromMismatchedTypes(const SCEV* LHS,
                                          const SCEV* RHS);

    /// getUMinFromMismatchedTypes - Promote the operands to the wider of
    /// the types using zero-extension, and then perform a umin operation
    /// with them.
    const SCEV* getUMinFromMismatchedTypes(const SCEV* LHS,
                                           const SCEV* RHS);

    /// hasSCEV - Return true if the SCEV for this value has already been
    /// computed.
    bool hasSCEV(Value *V) const;

    /// setSCEV - Insert the specified SCEV into the map of current SCEVs for
    /// the specified value.
    void setSCEV(Value *V, const SCEV* H);

    /// getSCEVAtScope - Return a SCEV expression handle for the specified value
    /// at the specified scope in the program.  The L value specifies a loop
    /// nest to evaluate the expression at, where null is the top-level or a
    /// specified loop is immediately inside of the loop.
    ///
    /// This method can be used to compute the exit value for a variable defined
    /// in a loop by querying what the value will hold in the parent loop.
    ///
    /// In the case that a relevant loop exit value cannot be computed, the
    /// original value V is returned.
    const SCEV* getSCEVAtScope(const SCEV *S, const Loop *L);

    /// getSCEVAtScope - This is a convenience function which does
    /// getSCEVAtScope(getSCEV(V), L).
    const SCEV* getSCEVAtScope(Value *V, const Loop *L);

    /// isLoopGuardedByCond - Test whether entry to the loop is protected by
    /// a conditional between LHS and RHS.  This is used to help avoid max
    /// expressions in loop trip counts.
    bool isLoopGuardedByCond(const Loop *L, ICmpInst::Predicate Pred,
                             const SCEV *LHS, const SCEV *RHS);

    /// getBackedgeTakenCount - If the specified loop has a predictable
    /// backedge-taken count, return it, otherwise return a SCEVCouldNotCompute
    /// object. The backedge-taken count is the number of times the loop header
    /// will be branched to from within the loop. This is one less than the
    /// trip count of the loop, since it doesn't count the first iteration,
    /// when the header is branched to from outside the loop.
    ///
    /// Note that it is not valid to call this method on a loop without a
    /// loop-invariant backedge-taken count (see
    /// hasLoopInvariantBackedgeTakenCount).
    ///
    const SCEV* getBackedgeTakenCount(const Loop *L);

    /// getMaxBackedgeTakenCount - Similar to getBackedgeTakenCount, except
    /// return the least SCEV value that is known never to be less than the
    /// actual backedge taken count.
    const SCEV* getMaxBackedgeTakenCount(const Loop *L);

    /// hasLoopInvariantBackedgeTakenCount - Return true if the specified loop
    /// has an analyzable loop-invariant backedge-taken count.
    bool hasLoopInvariantBackedgeTakenCount(const Loop *L);

    /// forgetLoopBackedgeTakenCount - This method should be called by the
    /// client when it has changed a loop in a way that may effect
    /// ScalarEvolution's ability to compute a trip count, or if the loop
    /// is deleted.
    void forgetLoopBackedgeTakenCount(const Loop *L);

    /// GetMinTrailingZeros - Determine the minimum number of zero bits that S is
    /// guaranteed to end in (at every loop iteration).  It is, at the same time,
    /// the minimum number of times S is divisible by 2.  For example, given {4,+,8}
    /// it returns 2.  If S is guaranteed to be 0, it returns the bitwidth of S.
    uint32_t GetMinTrailingZeros(const SCEV* S);

    /// GetMinLeadingZeros - Determine the minimum number of zero bits that S is
    /// guaranteed to begin with (at every loop iteration).
    uint32_t GetMinLeadingZeros(const SCEV* S);

    /// GetMinSignBits - Determine the minimum number of sign bits that S is
    /// guaranteed to begin with.
    uint32_t GetMinSignBits(const SCEV* S);

    virtual bool runOnFunction(Function &F);
    virtual void releaseMemory();
    virtual void getAnalysisUsage(AnalysisUsage &AU) const;
    void print(raw_ostream &OS, const Module* = 0) const;
    virtual void print(std::ostream &OS, const Module* = 0) const;
    void print(std::ostream *OS, const Module* M = 0) const {
      if (OS) print(*OS, M);
    }
    
  private:
    // Uniquing tables.
    std::map<ConstantInt*, SCEVConstant*> SCEVConstants;
    std::map<std::pair<const SCEV*, const Type*>,
             SCEVTruncateExpr*> SCEVTruncates;
    std::map<std::pair<const SCEV*, const Type*>,
             SCEVZeroExtendExpr*> SCEVZeroExtends;
    std::map<std::pair<unsigned, std::vector<const SCEV*> >,
             SCEVCommutativeExpr*> SCEVCommExprs;
    std::map<std::pair<const SCEV*, const SCEV*>,
             SCEVUDivExpr*> SCEVUDivs;
    std::map<std::pair<const SCEV*, const Type*>,
             SCEVSignExtendExpr*> SCEVSignExtends;
    std::map<std::pair<const Loop *, std::vector<const SCEV*> >,
             SCEVAddRecExpr*> SCEVAddRecExprs;
    std::map<Value*, SCEVUnknown*> SCEVUnknowns;
  };
}

#endif
