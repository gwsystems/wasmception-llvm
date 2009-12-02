//===-- MachineSSAUpdater.h - Unstructured SSA Update Tool ------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file declares the MachineSSAUpdater class.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_CODEGEN_MACHINESSAUPDATER_H
#define LLVM_CODEGEN_MACHINESSAUPDATER_H

namespace llvm {
  class MachineBasicBlock;
  class MachineInstr;
  template<typename T> class SmallVectorImpl;

/// SSAUpdater - This class updates SSA form for a set of values defined in
/// multiple blocks.  This is used when code duplication or another unstructured
/// transformation wants to rewrite a set of uses of one value with uses of a
/// set of values.
class MachineSSAUpdater {
  /// AvailableVals - This keeps track of which value to use on a per-block
  /// basis.  When we insert PHI nodes, we keep track of them here.
  //typedef DenseMap<MachineBasicBlock*, unsigned > AvailableValsTy;
  void *AV;

  /// IncomingPredInfo - We use this as scratch space when doing our recursive
  /// walk.  This should only be used in GetValueInBlockInternal, normally it
  /// should be empty.
  //std::vector<std::pair<MachineBasicBlock*, unsigned > > IncomingPredInfo;
  void *IPI;

  /// InsertedPHIs - If this is non-null, the MachineSSAUpdater adds all PHI
  /// nodes that it creates to the vector.
  SmallVectorImpl<MachineInstr*> *InsertedPHIs;
public:
  /// MachineSSAUpdater constructor.  If InsertedPHIs is specified, it will be
  /// filled in with all PHI Nodes created by rewriting.
  explicit MachineSSAUpdater(SmallVectorImpl<MachineInstr*> *InsertedPHIs = 0);
  ~MachineSSAUpdater();

  /// Initialize - Reset this object to get ready for a new set of SSA
  /// updates.
  void Initialize();

  /// AddAvailableValue - Indicate that a rewritten value is available at the
  /// end of the specified block with the specified value.
  void AddAvailableValue(MachineBasicBlock *BB, unsigned V);

  /// HasValueForBlock - Return true if the MachineSSAUpdater already has a
  /// value for the specified block.
  bool HasValueForBlock(MachineBasicBlock *BB) const;

  /// GetValueAtEndOfBlock - Construct SSA form, materializing a value that is
  /// live at the end of the specified block.
  unsigned GetValueAtEndOfBlock(MachineBasicBlock *BB);

  /// GetValueInMiddleOfBlock - Construct SSA form, materializing a value that
  /// is live in the middle of the specified block.
  ///
  /// GetValueInMiddleOfBlock is the same as GetValueAtEndOfBlock except in one
  /// important case: if there is a definition of the rewritten value after the
  /// 'use' in BB.  Consider code like this:
  ///
  ///      X1 = ...
  ///   SomeBB:
  ///      use(X)
  ///      X2 = ...
  ///      br Cond, SomeBB, OutBB
  ///
  /// In this case, there are two values (X1 and X2) added to the AvailableVals
  /// set by the client of the rewriter, and those values are both live out of
  /// their respective blocks.  However, the use of X happens in the *middle* of
  /// a block.  Because of this, we need to insert a new PHI node in SomeBB to
  /// merge the appropriate values, and this value isn't live out of the block.
  ///
  unsigned GetValueInMiddleOfBlock(MachineBasicBlock *BB);

  /// RewriteUse - Rewrite a use of the symbolic value.  This handles PHI nodes,
  /// which use their value in the corresponding predecessor.  Note that this
  /// will not work if the use is supposed to be rewritten to a value defined in
  /// the same block as the use, but above it.  Any 'AddAvailableValue's added
  /// for the use's block will be considered to be below it.
  void RewriteUse(unsigned &U);

private:
  unsigned GetValueAtEndOfBlockInternal(MachineBasicBlock *BB);
  void operator=(const MachineSSAUpdater&); // DO NOT IMPLEMENT
  MachineSSAUpdater(const MachineSSAUpdater&);     // DO NOT IMPLEMENT
};

} // End llvm namespace

#endif
