//===- SjLjEHPass.cpp - Eliminate Invoke & Unwind instructions -----------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This transformation is designed for use by code generators which use SjLj
// based exception handling.
//
//===----------------------------------------------------------------------===//

#define DEBUG_TYPE "sjljehprepare"
#include "llvm/Transforms/Scalar.h"
#include "llvm/Constants.h"
#include "llvm/DerivedTypes.h"
#include "llvm/Instructions.h"
#include "llvm/Intrinsics.h"
#include "llvm/LLVMContext.h"
#include "llvm/Module.h"
#include "llvm/Pass.h"
#include "llvm/Analysis/Verifier.h"
#include "llvm/CodeGen/Passes.h"
#include "llvm/Target/TargetData.h"
#include "llvm/Target/TargetLowering.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Transforms/Utils/Local.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/IRBuilder.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/SetVector.h"
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/ADT/Statistic.h"
#include <set>
using namespace llvm;

STATISTIC(NumInvokes, "Number of invokes replaced");
STATISTIC(NumSpilled, "Number of registers live across unwind edges");

namespace {
  class SjLjEHPass : public FunctionPass {
    const TargetLowering *TLI;
    Type *FunctionContextTy;
    Constant *RegisterFn;
    Constant *UnregisterFn;
    Constant *BuiltinSetjmpFn;
    Constant *FrameAddrFn;
    Constant *StackAddrFn;
    Constant *StackRestoreFn;
    Constant *LSDAAddrFn;
    Value *PersonalityFn;
    Constant *CallSiteFn;
    Constant *FuncCtxFn;
    AllocaInst *FuncCtx;
  public:
    static char ID; // Pass identification, replacement for typeid
    explicit SjLjEHPass(const TargetLowering *tli = NULL)
      : FunctionPass(ID), TLI(tli) { }
    bool doInitialization(Module &M);
    bool runOnFunction(Function &F);

    virtual void getAnalysisUsage(AnalysisUsage &AU) const {}
    const char *getPassName() const {
      return "SJLJ Exception Handling preparation";
    }

  private:
    bool setupEntryBlockAndCallSites(Function &F);
    void substituteLPadValues(LandingPadInst *LPI, Value *ExnVal,
                              Value *SelVal);
    Value *setupFunctionContext(Function &F, ArrayRef<LandingPadInst*> LPads);
    void lowerIncomingArguments(Function &F);
    void lowerAcrossUnwindEdges(Function &F, ArrayRef<InvokeInst*> Invokes);
    void insertCallSiteStore(Instruction *I, int Number);
  };
} // end anonymous namespace

char SjLjEHPass::ID = 0;

// Public Interface To the SjLjEHPass pass.
FunctionPass *llvm::createSjLjEHPass(const TargetLowering *TLI) {
  return new SjLjEHPass(TLI);
}
// doInitialization - Set up decalarations and types needed to process
// exceptions.
bool SjLjEHPass::doInitialization(Module &M) {
  // Build the function context structure.
  // builtin_setjmp uses a five word jbuf
  Type *VoidPtrTy = Type::getInt8PtrTy(M.getContext());
  Type *Int32Ty = Type::getInt32Ty(M.getContext());
  FunctionContextTy =
    StructType::get(VoidPtrTy,                        // __prev
                    Int32Ty,                          // call_site
                    ArrayType::get(Int32Ty, 4),       // __data
                    VoidPtrTy,                        // __personality
                    VoidPtrTy,                        // __lsda
                    ArrayType::get(VoidPtrTy, 5),     // __jbuf
                    NULL);
  RegisterFn = M.getOrInsertFunction("_Unwind_SjLj_Register",
                                     Type::getVoidTy(M.getContext()),
                                     PointerType::getUnqual(FunctionContextTy),
                                     (Type *)0);
  UnregisterFn =
    M.getOrInsertFunction("_Unwind_SjLj_Unregister",
                          Type::getVoidTy(M.getContext()),
                          PointerType::getUnqual(FunctionContextTy),
                          (Type *)0);
  FrameAddrFn = Intrinsic::getDeclaration(&M, Intrinsic::frameaddress);
  StackAddrFn = Intrinsic::getDeclaration(&M, Intrinsic::stacksave);
  StackRestoreFn = Intrinsic::getDeclaration(&M, Intrinsic::stackrestore);
  BuiltinSetjmpFn = Intrinsic::getDeclaration(&M, Intrinsic::eh_sjlj_setjmp);
  LSDAAddrFn = Intrinsic::getDeclaration(&M, Intrinsic::eh_sjlj_lsda);
  CallSiteFn = Intrinsic::getDeclaration(&M, Intrinsic::eh_sjlj_callsite);
  FuncCtxFn = Intrinsic::getDeclaration(&M, Intrinsic::eh_sjlj_functioncontext);
  PersonalityFn = 0;

  return true;
}

/// insertCallSiteStore - Insert a store of the call-site value to the
/// function context
void SjLjEHPass::insertCallSiteStore(Instruction *I, int Number) {
  IRBuilder<> Builder(I);

  // Get a reference to the call_site field.
  Type *Int32Ty = Type::getInt32Ty(I->getContext());
  Value *Zero = ConstantInt::get(Int32Ty, 0);
  Value *One = ConstantInt::get(Int32Ty, 1);
  Value *Idxs[2] = { Zero, One };
  Value *CallSite = Builder.CreateGEP(FuncCtx, Idxs, "call_site");

  // Insert a store of the call-site number
  ConstantInt *CallSiteNoC = ConstantInt::get(Type::getInt32Ty(I->getContext()),
                                              Number);
  Builder.CreateStore(CallSiteNoC, CallSite, true/*volatile*/);
}

/// markBlocksLiveIn - Insert BB and all of its predescessors into LiveBBs until
/// we reach blocks we've already seen.
static void markBlocksLiveIn(BasicBlock *BB, Instruction *Inst,
                             SmallPtrSet<BasicBlock*, 64> &LiveBBs,
                             SmallPtrSet<BasicBlock*, 4> &InvokesCrossed) {
  if (!LiveBBs.insert(BB)) return; // already been here.

  for (pred_iterator PI = pred_begin(BB), E = pred_end(BB); PI != E; ++PI) {
    BasicBlock *Pred = *PI;
    if (BB->isLandingPad() && BB != Inst->getParent())
      InvokesCrossed.insert(Pred);
    markBlocksLiveIn(Pred, Inst, LiveBBs, InvokesCrossed);
  }
}

/// substituteLPadValues - Substitute the values returned by the landingpad
/// instruction with those returned by the personality function.
void SjLjEHPass::substituteLPadValues(LandingPadInst *LPI, Value *ExnVal,
                                      Value *SelVal) {
  SmallVector<Value*, 8> UseWorkList(LPI->use_begin(), LPI->use_end());
  while (!UseWorkList.empty()) {
    Value *Val = UseWorkList.pop_back_val();
    ExtractValueInst *EVI = dyn_cast<ExtractValueInst>(Val);
    if (!EVI) continue;
    if (EVI->getNumIndices() != 1) continue;
    if (*EVI->idx_begin() == 0)
      EVI->replaceAllUsesWith(ExnVal);
    else if (*EVI->idx_begin() == 1)
      EVI->replaceAllUsesWith(SelVal);
    if (EVI->getNumUses() == 0)
      EVI->eraseFromParent();
  }

  if (LPI->getNumUses() == 0)  return;

  // There are still some uses of LPI. Construct an aggregate with the exception
  // values and replace the LPI with that aggregate.
  Type *LPadType = LPI->getType();
  Value *LPadVal = UndefValue::get(LPadType);
  IRBuilder<>
    Builder(llvm::next(BasicBlock::iterator(cast<Instruction>(SelVal))));
  LPadVal = Builder.CreateInsertValue(LPadVal, ExnVal, 0, "lpad.val");
  LPadVal = Builder.CreateInsertValue(LPadVal, SelVal, 1, "lpad.val");

  LPI->replaceAllUsesWith(LPadVal);
}

/// setupFunctionContext - Allocate the function context on the stack and fill
/// it with all of the data that we know at this point.
Value *SjLjEHPass::
setupFunctionContext(Function &F, ArrayRef<LandingPadInst*> LPads) {
  BasicBlock *EntryBB = F.begin();

  // Create an alloca for the incoming jump buffer ptr and the new jump buffer
  // that needs to be restored on all exits from the function. This is an alloca
  // because the value needs to be added to the global context list.
  unsigned Align =
    TLI->getTargetData()->getPrefTypeAlignment(FunctionContextTy);
  FuncCtx =
    new AllocaInst(FunctionContextTy, 0, Align, "fn_context", EntryBB->begin());

  // Fill in the function context structure.
  Type *Int32Ty = Type::getInt32Ty(F.getContext());
  Value *Zero = ConstantInt::get(Int32Ty, 0);
  Value *One = ConstantInt::get(Int32Ty, 1);
  Value *Two = ConstantInt::get(Int32Ty, 2);
  Value *Three = ConstantInt::get(Int32Ty, 3);
  Value *Four = ConstantInt::get(Int32Ty, 4);

  Value *Idxs[2] = { Zero, 0 };

  for (unsigned I = 0, E = LPads.size(); I != E; ++I) {
    LandingPadInst *LPI = LPads[I];
    IRBuilder<> Builder(LPI->getParent()->getFirstInsertionPt());

    // Reference the __data field.
    Idxs[1] = Two;
    Value *FCData = Builder.CreateGEP(FuncCtx, Idxs, "__data");

    // The exception values come back in context->__data[0].
    Idxs[1] = Zero;
    Value *ExceptionAddr = Builder.CreateGEP(FCData, Idxs, "exception_gep");
    Value *ExnVal = Builder.CreateLoad(ExceptionAddr, true, "exn_val");
    ExnVal = Builder.CreateIntToPtr(ExnVal, Type::getInt8PtrTy(F.getContext()));

    Idxs[1] = One;
    Value *SelectorAddr = Builder.CreateGEP(FCData, Idxs, "exn_selector_gep");
    Value *SelVal = Builder.CreateLoad(SelectorAddr, true, "exn_selector_val");

    substituteLPadValues(LPI, ExnVal, SelVal);
  }

  // Personality function
  Idxs[1] = Three;
  if (!PersonalityFn)
    PersonalityFn = LPads[0]->getPersonalityFn();
  Value *PersonalityFieldPtr =
    GetElementPtrInst::Create(FuncCtx, Idxs, "pers_fn_gep",
                              EntryBB->getTerminator());
  new StoreInst(PersonalityFn, PersonalityFieldPtr, true,
                EntryBB->getTerminator());

  // LSDA address
  Value *LSDA = CallInst::Create(LSDAAddrFn, "lsda_addr",
                                 EntryBB->getTerminator());
  Idxs[1] = Four;
  Value *LSDAFieldPtr = GetElementPtrInst::Create(FuncCtx, Idxs, "lsda_gep",
                                                  EntryBB->getTerminator());
  new StoreInst(LSDA, LSDAFieldPtr, true, EntryBB->getTerminator());

  return FuncCtx;
}

/// lowerIncomingArguments - To avoid having to handle incoming arguments
/// specially, we lower each arg to a copy instruction in the entry block. This
/// ensures that the argument value itself cannot be live out of the entry
/// block.
void SjLjEHPass::lowerIncomingArguments(Function &F) {
  BasicBlock::iterator AfterAllocaInsPt = F.begin()->begin();
  while (isa<AllocaInst>(AfterAllocaInsPt) &&
         isa<ConstantInt>(cast<AllocaInst>(AfterAllocaInsPt)->getArraySize()))
    ++AfterAllocaInsPt;

  for (Function::arg_iterator
         AI = F.arg_begin(), AE = F.arg_end(); AI != AE; ++AI) {
    Type *Ty = AI->getType();

    // Aggregate types can't be cast, but are legal argument types, so we have
    // to handle them differently. We use an extract/insert pair as a
    // lightweight method to achieve the same goal.
    if (isa<StructType>(Ty) || isa<ArrayType>(Ty) || isa<VectorType>(Ty)) {
      Instruction *EI = ExtractValueInst::Create(AI, 0, "", AfterAllocaInsPt);
      Instruction *NI = InsertValueInst::Create(AI, EI, 0);
      NI->insertAfter(EI);
      AI->replaceAllUsesWith(NI);

      // Set the operand of the instructions back to the AllocaInst.
      EI->setOperand(0, AI);
      NI->setOperand(0, AI);
    } else {
      // This is always a no-op cast because we're casting AI to AI->getType()
      // so src and destination types are identical. BitCast is the only
      // possibility.
      CastInst *NC =
        new BitCastInst(AI, AI->getType(), AI->getName() + ".tmp",
                        AfterAllocaInsPt);
      AI->replaceAllUsesWith(NC);

      // Set the operand of the cast instruction back to the AllocaInst.
      // Normally it's forbidden to replace a CastInst's operand because it
      // could cause the opcode to reflect an illegal conversion. However, we're
      // replacing it here with the same value it was constructed with.  We do
      // this because the above replaceAllUsesWith() clobbered the operand, but
      // we want this one to remain.
      NC->setOperand(0, AI);
    }
  }
}

/// lowerAcrossUnwindEdges - Find all variables which are alive across an unwind
/// edge and spill them.
void SjLjEHPass::lowerAcrossUnwindEdges(Function &F,
                                        ArrayRef<InvokeInst*> Invokes) {
  SmallVector<std::pair<Instruction*, Instruction*>, 32> ReloadUsers;
  DenseMap<std::pair<Instruction*, Instruction*>, AllocaInst*> AllocaMap;

  // Finally, scan the code looking for instructions with bad live ranges.
  for (Function::iterator
         BB = F.begin(), BBE = F.end(); BB != BBE; ++BB) {
    for (BasicBlock::iterator
           II = BB->begin(), IIE = BB->end(); II != IIE; ++II) {
      // Ignore obvious cases we don't have to handle. In particular, most
      // instructions either have no uses or only have a single use inside the
      // current block. Ignore them quickly.
      Instruction *Inst = II;
      if (Inst->use_empty()) continue;
      if (Inst->hasOneUse() &&
          cast<Instruction>(Inst->use_back())->getParent() == BB &&
          !isa<PHINode>(Inst->use_back())) continue;

      // If this is an alloca in the entry block, it's not a real register
      // value.
      if (AllocaInst *AI = dyn_cast<AllocaInst>(Inst))
        if (isa<ConstantInt>(AI->getArraySize()) && BB == F.begin())
          continue;

      // Avoid iterator invalidation by copying users to a temporary vector.
      SmallVector<Instruction*, 16> Users;
      for (Value::use_iterator
             UI = Inst->use_begin(), E = Inst->use_end(); UI != E; ++UI) {
        Instruction *User = cast<Instruction>(*UI);
        if (User->getParent() != BB || isa<PHINode>(User))
          Users.push_back(User);
      }

      // Find all of the blocks that this value is live in.
      std::map<Instruction*, SmallPtrSet<BasicBlock*, 4> > InvokesCrossed;
      std::map<Instruction*, SmallPtrSet<BasicBlock*, 64> > LiveBBs;
      while (!Users.empty()) {
        Instruction *U = Users.pop_back_val();
        LiveBBs[U].insert(Inst->getParent());

        if (PHINode *PN = dyn_cast<PHINode>(U)) {
          // Uses for a PHI node occur in their predecessor block.
          for (unsigned i = 0, e = PN->getNumIncomingValues(); i != e; ++i)
            if (PN->getIncomingValue(i) == Inst)
              markBlocksLiveIn(PN->getIncomingBlock(i), Inst, LiveBBs[U],
                               InvokesCrossed[U]);
        } else {
          markBlocksLiveIn(U->getParent(), Inst, LiveBBs[U], InvokesCrossed[U]);
        }
      }

      // Go through the invokes the value crosses and insert a spill right
      // before the invoke.
      for (std::map<Instruction*, SmallPtrSet<BasicBlock*, 4> >::iterator
             MI = InvokesCrossed.begin(), ME = InvokesCrossed.end();
           MI != ME; ++MI) {
        Instruction *User = MI->first;
        SmallPtrSet<BasicBlock*, 4> &Crossings = MI->second;
        if (Crossings.empty()) continue;

        ReloadUsers.push_back(std::make_pair(Inst, User));

        AllocaInst *&Slot = AllocaMap[std::make_pair(Inst, User)];
        if (!Slot)
          Slot = new AllocaInst(Inst->getType(), 0,
                                Inst->getName() + ".reg2mem",
                                F.getEntryBlock().begin());

        for (SmallPtrSet<BasicBlock*, 4>::iterator
               CI = Crossings.begin(), CE = Crossings.end(); CI != CE; ++CI) {
          new StoreInst(Inst, Slot, (*CI)->getTerminator());
          ++NumSpilled;
        }
      }
    }
  }

  // Now go through the instructions which were spilled and replace their uses
  // after a crossed invoke with a reload instruction.
  for (SmallVectorImpl<std::pair<Instruction*, Instruction*> >::iterator
         I = ReloadUsers.begin(), E = ReloadUsers.end(); I != E; ++I) {
    Instruction *User = I->second;
    AllocaInst *Slot = AllocaMap[*I];
    assert(Slot && "A spill slot hasn't been allocated yet!");

    if (PHINode *PN = dyn_cast<PHINode>(User)) {
      // If this is a PHI node, we can't insert a load of the value before the
      // use. Instead insert the load in the predecessor block corresponding to
      // the incoming value.
      //
      // Note that if there are multiple edges from a basic block to this PHI
      // node that we cannot have multiple loads. The problem is that the
      // resulting PHI node will have multiple values (from each load) coming in
      // from the same block, which is illegal SSA form. For this reason, we
      // keep track of and reuse loads we insert.
      DenseMap<BasicBlock*, Value*> Loads;
      for (unsigned i = 0, e = PN->getNumIncomingValues(); i != e; ++i)
        if (PN->getIncomingValue(i) == I->first) {
          Value *&V = Loads[PN->getIncomingBlock(i)];
          if (V == 0)
            // Insert the load into the predecessor block
            V = new LoadInst(Slot, I->first->getName() + ".reload", true,
                             PN->getIncomingBlock(i)->getTerminator());

          PN->setIncomingValue(i, V);
        }
    } else {
      LoadInst *Reload = new LoadInst(Slot, Slot->getName() + ".reload", User);
      User->replaceUsesOfWith(I->first, Reload);
    }
  }

  // Go through the landing pads and remove any PHIs there.
  for (unsigned i = 0, e = Invokes.size(); i != e; ++i) {
    BasicBlock *UnwindBlock = Invokes[i]->getUnwindDest();
    LandingPadInst *LPI = UnwindBlock->getLandingPadInst();

    // Place PHIs into a set to avoid invalidating the iterator.
    SmallPtrSet<PHINode*, 8> PHIsToDemote;
    for (BasicBlock::iterator
           PN = UnwindBlock->begin(); isa<PHINode>(PN); ++PN)
      PHIsToDemote.insert(cast<PHINode>(PN));
    if (PHIsToDemote.empty()) continue;

    // Demote the PHIs to the stack.
    for (SmallPtrSet<PHINode*, 8>::iterator
           I = PHIsToDemote.begin(), E = PHIsToDemote.end(); I != E; ++I)
      DemotePHIToStack(*I);

    // Move the landingpad instruction back to the top of the landing pad block.
    LPI->moveBefore(UnwindBlock->begin());
  }
}

/// setupEntryBlockAndCallSites - Setup the entry block by creating and filling
/// the function context and marking the call sites with the appropriate
/// values. These values are used by the DWARF EH emitter.
bool SjLjEHPass::setupEntryBlockAndCallSites(Function &F) {
  SmallVector<ReturnInst*,     16> Returns;
  SmallVector<InvokeInst*,     16> Invokes;
  SmallSetVector<LandingPadInst*, 16> LPads;

  // Look through the terminators of the basic blocks to find invokes.
  for (Function::iterator BB = F.begin(), E = F.end(); BB != E; ++BB)
    if (InvokeInst *II = dyn_cast<InvokeInst>(BB->getTerminator())) {
      Invokes.push_back(II);
      LPads.insert(II->getUnwindDest()->getLandingPadInst());
    } else if (ReturnInst *RI = dyn_cast<ReturnInst>(BB->getTerminator())) {
      Returns.push_back(RI);
    }

  if (Invokes.empty()) return false;

  NumInvokes += Invokes.size();

  lowerIncomingArguments(F);
  lowerAcrossUnwindEdges(F, Invokes);

  Value *FuncCtx =
    setupFunctionContext(F, makeArrayRef(LPads.begin(), LPads.end()));
  BasicBlock *EntryBB = F.begin();
  Type *Int32Ty = Type::getInt32Ty(F.getContext());

  Value *Idxs[2] = {
    ConstantInt::get(Int32Ty, 0), 0
  };

  // Get a reference to the jump buffer.
  Idxs[1] = ConstantInt::get(Int32Ty, 5);
  Value *JBufPtr = GetElementPtrInst::Create(FuncCtx, Idxs, "jbuf_gep",
                                             EntryBB->getTerminator());

  // Save the frame pointer.
  Idxs[1] = ConstantInt::get(Int32Ty, 0);
  Value *FramePtr = GetElementPtrInst::Create(JBufPtr, Idxs, "jbuf_fp_gep",
                                              EntryBB->getTerminator());

  Value *Val = CallInst::Create(FrameAddrFn,
                                ConstantInt::get(Int32Ty, 0),
                                "fp",
                                EntryBB->getTerminator());
  new StoreInst(Val, FramePtr, true, EntryBB->getTerminator());

  // Save the stack pointer.
  Idxs[1] = ConstantInt::get(Int32Ty, 2);
  Value *StackPtr = GetElementPtrInst::Create(JBufPtr, Idxs, "jbuf_sp_gep",
                                              EntryBB->getTerminator());

  Val = CallInst::Create(StackAddrFn, "sp", EntryBB->getTerminator());
  new StoreInst(Val, StackPtr, true, EntryBB->getTerminator());

  // Call the setjmp instrinsic. It fills in the rest of the jmpbuf.
  Value *SetjmpArg = CastInst::Create(Instruction::BitCast, JBufPtr,
                                      Type::getInt8PtrTy(F.getContext()), "",
                                      EntryBB->getTerminator());
  CallInst::Create(BuiltinSetjmpFn, SetjmpArg, "", EntryBB->getTerminator());

  // Store a pointer to the function context so that the back-end will know
  // where to look for it.
  Value *FuncCtxArg = CastInst::Create(Instruction::BitCast, FuncCtx,
                                       Type::getInt8PtrTy(F.getContext()), "",
                                       EntryBB->getTerminator());
  CallInst::Create(FuncCtxFn, FuncCtxArg, "", EntryBB->getTerminator());

  // At this point, we are all set up, update the invoke instructions to mark
  // their call_site values.
  for (unsigned I = 0, E = Invokes.size(); I != E; ++I) {
    insertCallSiteStore(Invokes[I], I + 1);

    ConstantInt *CallSiteNum =
      ConstantInt::get(Type::getInt32Ty(F.getContext()), I + 1);

    // Record the call site value for the back end so it stays associated with
    // the invoke.
    CallInst::Create(CallSiteFn, CallSiteNum, "", Invokes[I]);
  }

  // Mark call instructions that aren't nounwind as no-action (call_site ==
  // -1). Skip the entry block, as prior to then, no function context has been
  // created for this function and any unexpected exceptions thrown will go
  // directly to the caller's context, which is what we want anyway, so no need
  // to do anything here.
  for (Function::iterator BB = F.begin(), E = F.end(); ++BB != E;)
    for (BasicBlock::iterator I = BB->begin(), end = BB->end(); I != end; ++I)
      if (CallInst *CI = dyn_cast<CallInst>(I)) {
        if (!CI->doesNotThrow())
          insertCallSiteStore(CI, -1);
      } else if (ResumeInst *RI = dyn_cast<ResumeInst>(I)) {
        insertCallSiteStore(RI, -1);
      }

  // Register the function context and make sure it's known to not throw
  CallInst *Register = CallInst::Create(RegisterFn, FuncCtx, "",
                                        EntryBB->getTerminator());
  Register->setDoesNotThrow();

  // Following any allocas not in the entry block, update the saved SP in the
  // jmpbuf to the new value.
  for (Function::iterator BB = F.begin(), E = F.end(); BB != E; ++BB) {
    if (BB == F.begin())
      continue;
    for (BasicBlock::iterator I = BB->begin(), E = BB->end(); I != E; ++I) {
      if (CallInst *CI = dyn_cast<CallInst>(I)) {
        if (CI->getCalledFunction() != StackRestoreFn)
          continue;
      } else if (!isa<AllocaInst>(I)) {
        continue;
      }
      Instruction *StackAddr = CallInst::Create(StackAddrFn, "sp");
      StackAddr->insertAfter(I);
      Instruction *StoreStackAddr = new StoreInst(StackAddr, StackPtr, true);
      StoreStackAddr->insertAfter(StackAddr);
    }
  }

  // Finally, for any returns from this function, if this function contains an
  // invoke, add a call to unregister the function context.
  for (unsigned I = 0, E = Returns.size(); I != E; ++I)
    CallInst::Create(UnregisterFn, FuncCtx, "", Returns[I]);

  return true;
}

bool SjLjEHPass::runOnFunction(Function &F) {
  bool Res = setupEntryBlockAndCallSites(F);
  DEBUG({
      if (verifyFunction(F))
        report_fatal_error("verifyFunction failed!");
    });
  return Res;
}
