//===- LowerSetJmp.cpp - Code pertaining to lowering set/long jumps -------===//
//
//  This file implements the lowering of setjmp and longjmp to use the
//  LLVM invoke and unwind instructions as necessary.
//
//  Lowering of longjmp is fairly trivial. We replace the call with a
//  call to the LLVM library function "__llvm_sjljeh_throw_longjmp()".
//  This unwinds the stack for us calling all of the destructors for
//  objects allocated on the stack.
//
//  At a setjmp call, the basic block is split and the setjmp removed.
//  The calls in a function that have a setjmp are converted to invoke
//  where the except part checks to see if it's a longjmp exception and,
//  if so, if it's handled in the function. If it is, then it gets the
//  value returned by the longjmp and goes to where the basic block was
//  split. Invoke instructions are handled in a similar fashion with the
//  original except block being executed if it isn't a longjmp except
//  that is handled by that function.
//
// This pass was contributed to LLVM by Bill Wendling.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// FIXME: This pass doesn't deal with PHI statements just yet. That is,
// we expect this to occur before SSAification is done. This would seem
// to make sense, but in general, it might be a good idea to make this
// pass invokable via the "opt" command at will.
//===----------------------------------------------------------------------===//

#include "llvm/Constants.h"
#include "llvm/DerivedTypes.h"
#include "llvm/Instructions.h"
#include "llvm/Intrinsics.h"
#include "llvm/Module.h"
#include "llvm/Pass.h"
#include "llvm/Support/InstIterator.h"
#include "llvm/Support/InstVisitor.h"
#include "Support/Statistic.h"
#include "Support/StringExtras.h"
#include "Support/VectorExtras.h"

#include <set>

namespace {
  Statistic<> LongJmpsTransformed("lowersetjmp",
                                  "Number of longjmps transformed");
  Statistic<> SetJmpsTransformed("lowersetjmp",
                                 "Number of setjmps transformed");

  //===--------------------------------------------------------------------===//
  // LowerSetJmp pass implementation. This is subclassed from the "Pass"
  // class because it works on a module as a whole, not a function at a
  // time.

  class LowerSetJmp : public Pass,
                      public InstVisitor<LowerSetJmp> {
    // LLVM library functions...
    Function* InitSJMap;        // __llvm_sjljeh_init_setjmpmap
    Function* DestroySJMap;     // __llvm_sjljeh_destroy_setjmpmap
    Function* AddSJToMap;       // __llvm_sjljeh_add_setjmp_to_map
    Function* ThrowLongJmp;     // __llvm_sjljeh_throw_longjmp
    Function* TryCatchLJ;       // __llvm_sjljeh_try_catching_longjmp_exception
    Function* IsLJException;    // __llvm_sjljeh_is_longjmp_exception
    Function* GetLJValue;       // __llvm_sjljeh_get_longjmp_value

    typedef std::pair<SwitchInst*, CallInst*> SwitchValuePair;

    // The setjmp map is going to hold information about which setjmps
    // were called (each setjmp gets its own number) and with which
    // buffer it was called.
    std::map<Function*, AllocaInst*>            SJMap;

    // The rethrow basic block map holds the basic block to branch to if
    // the exception isn't handled in the current function and needs to
    // be rethrown.
    std::map<const Function*, BasicBlock*>      RethrowBBMap;

    // The preliminary basic block map holds a basic block that grabs the
    // exception and determines if it's handled by the current function.
    std::map<const Function*, BasicBlock*>      PrelimBBMap;

    // The switch/value map holds a switch inst/call inst pair. The
    // switch inst controls which handler (if any) gets called and the
    // value is the value returned to that handler by the call to
    // __llvm_sjljeh_get_longjmp_value.
    std::map<const Function*, SwitchValuePair>  SwitchValMap;

    // A map of which setjmps we've seen so far in a function.
    std::map<const Function*, unsigned>         SetJmpIDMap;

    AllocaInst*     GetSetJmpMap(Function* Func);
    BasicBlock*     GetRethrowBB(Function* Func);
    SwitchValuePair GetSJSwitch(Function* Func, BasicBlock* Rethrow);

    void TransformLongJmpCall(CallInst* Inst);
    void TransformSetJmpCall(CallInst* Inst);

    bool IsTransformableFunction(const std::string& Name);
  public:
    void visitCallInst(CallInst& CI);
    void visitInvokeInst(InvokeInst& II);
    void visitReturnInst(ReturnInst& RI);
    void visitUnwindInst(UnwindInst& UI);

    bool run(Module& M);
    bool doInitialization(Module& M);
  };

  RegisterOpt<LowerSetJmp> X("lowersetjmp", "Lower Set Jump");
} // end anonymous namespace

// run - Run the transformation on the program. We grab the function
// prototypes for longjmp and setjmp. If they are used in the program,
// then we can go directly to the places they're at and transform them.
bool LowerSetJmp::run(Module& M)
{
  bool Changed = false;

  // These are what the functions are called.
  Function* SetJmp = M.getNamedFunction("llvm.setjmp");
  Function* LongJmp = M.getNamedFunction("llvm.longjmp");

  // This program doesn't have longjmp and setjmp calls.
  if ((!LongJmp || LongJmp->use_empty()) &&
        (!SetJmp || SetJmp->use_empty())) return false;

  // Initialize some values and functions we'll need to transform the
  // setjmp/longjmp functions.
  doInitialization(M);

  if (SetJmp)
    while (!SetJmp->use_empty()) {
      assert(isa<CallInst>(SetJmp->use_back()) &&
             "User of setjmp intrinsic not a call?");
      TransformSetJmpCall(cast<CallInst>(SetJmp->use_back()));
      Changed = true;
    }

  if (LongJmp)
    while (!LongJmp->use_empty()) {
      assert(isa<CallInst>(LongJmp->use_back()) &&
             "User of longjmp intrinsic not a call?");
      TransformLongJmpCall(cast<CallInst>(LongJmp->use_back()));
      Changed = true;
    }

  // Now go through the affected functions and convert calls and invokes
  // to new invokes...
  for (std::map<Function*, AllocaInst*>::iterator
      B = SJMap.begin(), E = SJMap.end(); B != E; ++B) {
    Function* F = B->first;
    for (Function::iterator BB = F->begin(), BE = F->end(); BB != BE; ++BB)
      for (BasicBlock::iterator IB = BB->begin(), IE = BB->end(); IB != IE; ) {
        visit(*IB++);
        if (IB != BB->end() && IB->getParent() != BB)
          break;  // The next instruction got moved to a different block!
      }
  }

  SJMap.clear();
  RethrowBBMap.clear();
  PrelimBBMap.clear();
  SwitchValMap.clear();
  SetJmpIDMap.clear();

  return Changed;
}

// doInitialization - For the lower long/setjmp pass, this ensures that a
// module contains a declaration for the intrisic functions we are going
// to call to convert longjmp and setjmp calls.
//
// This function is always successful, unless it isn't.
bool LowerSetJmp::doInitialization(Module& M)
{
  const Type *SBPTy = PointerType::get(Type::SByteTy);
  const Type *SBPPTy = PointerType::get(SBPTy);

  // N.B. See llvm/runtime/GCCLibraries/libexception/SJLJ-Exception.h for
  // a description of the following library functions.

  // void __llvm_sjljeh_init_setjmpmap(void**)
  InitSJMap = M.getOrInsertFunction("__llvm_sjljeh_init_setjmpmap",
                                    Type::VoidTy, SBPPTy, 0); 
  // void __llvm_sjljeh_destroy_setjmpmap(void**)
  DestroySJMap = M.getOrInsertFunction("__llvm_sjljeh_destroy_setjmpmap",
                                       Type::VoidTy, SBPPTy, 0);

  // void __llvm_sjljeh_add_setjmp_to_map(void**, void*, unsigned)
  AddSJToMap = M.getOrInsertFunction("__llvm_sjljeh_add_setjmp_to_map",
                                     Type::VoidTy, SBPPTy, SBPTy,
                                     Type::UIntTy, 0);

  // void __llvm_sjljeh_throw_longjmp(int*, int)
  ThrowLongJmp = M.getOrInsertFunction("__llvm_sjljeh_throw_longjmp",
                                       Type::VoidTy, SBPTy, Type::IntTy, 0);

  // unsigned __llvm_sjljeh_try_catching_longjmp_exception(void **)
  TryCatchLJ =
    M.getOrInsertFunction("__llvm_sjljeh_try_catching_longjmp_exception",
                          Type::UIntTy, SBPPTy, 0);

  // bool __llvm_sjljeh_is_longjmp_exception()
  IsLJException = M.getOrInsertFunction("__llvm_sjljeh_is_longjmp_exception",
                                        Type::BoolTy, 0);

  // int __llvm_sjljeh_get_longjmp_value()
  GetLJValue = M.getOrInsertFunction("__llvm_sjljeh_get_longjmp_value",
                                     Type::IntTy, 0);
  return true;
}

// IsTransformableFunction - Return true if the function name isn't one
// of the ones we don't want transformed. Currently, don't transform any
// "llvm.{setjmp,longjmp}" functions and none of the setjmp/longjmp error
// handling functions (beginning with __llvm_sjljeh_...they don't throw
// exceptions).
bool LowerSetJmp::IsTransformableFunction(const std::string& Name)
{
  std::string SJLJEh("__llvm_sjljeh");

  if (Name.size() > SJLJEh.size())
    return std::string(Name.begin(), Name.begin() + SJLJEh.size()) != SJLJEh;

  return true;
}

// TransformLongJmpCall - Transform a longjmp call into a call to the
// internal __llvm_sjljeh_throw_longjmp function. It then takes care of
// throwing the exception for us.
void LowerSetJmp::TransformLongJmpCall(CallInst* Inst)
{
  const Type* SBPTy = PointerType::get(Type::SByteTy);

  // Create the call to "__llvm_sjljeh_throw_longjmp". This takes the
  // same parameters as "longjmp", except that the buffer is cast to a
  // char*. It returns "void", so it doesn't need to replace any of
  // Inst's uses and doesn't get a name.
  CastInst* CI = new CastInst(Inst->getOperand(1), SBPTy, "LJBuf", Inst);
  new CallInst(ThrowLongJmp, make_vector<Value*>(CI, Inst->getOperand(2), 0),
               "", Inst);

  SwitchValuePair& SVP = SwitchValMap[Inst->getParent()->getParent()];

  // If the function has a setjmp call in it (they are transformed first)
  // we should branch to the basic block that determines if this longjmp
  // is applicable here. Otherwise, issue an unwind.
  if (SVP.first)
    new BranchInst(SVP.first->getParent(), Inst);
  else
    new UnwindInst(Inst);

  // Remove all insts after the branch/unwind inst.
  Inst->getParent()->getInstList().erase(Inst,
                                       Inst->getParent()->getInstList().end());

  ++LongJmpsTransformed;
}

// GetSetJmpMap - Retrieve (create and initialize, if necessary) the
// setjmp map. This map is going to hold information about which setjmps
// were called (each setjmp gets its own number) and with which buffer it
// was called. There can be only one!
AllocaInst* LowerSetJmp::GetSetJmpMap(Function* Func)
{
  if (SJMap[Func]) return SJMap[Func];

  // Insert the setjmp map initialization before the first instruction in
  // the function.
  Instruction* Inst = Func->getEntryNode().begin();
  assert(Inst && "Couldn't find even ONE instruction in entry block!");

  // Fill in the alloca and call to initialize the SJ map.
  const Type *SBPTy = PointerType::get(Type::SByteTy);
  AllocaInst* Map = new AllocaInst(SBPTy, 0, "SJMap", Inst);
  new CallInst(InitSJMap, make_vector<Value*>(Map, 0), "", Inst);
  return SJMap[Func] = Map;
}

// GetRethrowBB - Only one rethrow basic block is needed per function.
// If this is a longjmp exception but not handled in this block, this BB
// performs the rethrow.
BasicBlock* LowerSetJmp::GetRethrowBB(Function* Func)
{
  if (RethrowBBMap[Func]) return RethrowBBMap[Func];

  // The basic block we're going to jump to if we need to rethrow the
  // exception.
  BasicBlock* Rethrow = new BasicBlock("RethrowExcept", Func);
  BasicBlock::InstListType& RethrowBlkIL = Rethrow->getInstList();

  // Fill in the "Rethrow" BB with a call to rethrow the exception. This
  // is the last instruction in the BB since at this point the runtime
  // should exit this function and go to the next function.
  RethrowBlkIL.push_back(new UnwindInst());
  return RethrowBBMap[Func] = Rethrow;
}

// GetSJSwitch - Return the switch statement that controls which handler
// (if any) gets called and the value returned to that handler.
LowerSetJmp::SwitchValuePair LowerSetJmp::GetSJSwitch(Function* Func,
                                                      BasicBlock* Rethrow)
{
  if (SwitchValMap[Func].first) return SwitchValMap[Func];

  BasicBlock* LongJmpPre = new BasicBlock("LongJmpBlkPre", Func);
  BasicBlock::InstListType& LongJmpPreIL = LongJmpPre->getInstList();

  // Keep track of the preliminary basic block for some of the other
  // transformations.
  PrelimBBMap[Func] = LongJmpPre;

  // Grab the exception.
  CallInst* Cond = new
    CallInst(IsLJException, std::vector<Value*>(), "IsLJExcept");
  LongJmpPreIL.push_back(Cond);

  // The "decision basic block" gets the number associated with the
  // setjmp call returning to switch on and the value returned by
  // longjmp.
  BasicBlock* DecisionBB = new BasicBlock("LJDecisionBB", Func);
  BasicBlock::InstListType& DecisionBBIL = DecisionBB->getInstList();

  LongJmpPreIL.push_back(new BranchInst(DecisionBB, Rethrow, Cond));

  // Fill in the "decision" basic block.
  CallInst* LJVal = new CallInst(GetLJValue, std::vector<Value*>(), "LJVal");
  DecisionBBIL.push_back(LJVal);
  CallInst* SJNum = new
    CallInst(TryCatchLJ, make_vector<Value*>(GetSetJmpMap(Func), 0), "SJNum");
  DecisionBBIL.push_back(SJNum);

  SwitchInst* SI = new SwitchInst(SJNum, Rethrow);
  DecisionBBIL.push_back(SI);
  return SwitchValMap[Func] = SwitchValuePair(SI, LJVal);
}

// TransformSetJmpCall - The setjmp call is a bit trickier to transform.
// We're going to convert all setjmp calls to nops. Then all "call" and
// "invoke" instructions in the function are converted to "invoke" where
// the "except" branch is used when returning from a longjmp call.
void LowerSetJmp::TransformSetJmpCall(CallInst* Inst)
{
  BasicBlock* ABlock = Inst->getParent();
  Function* Func = ABlock->getParent();

  // Add this setjmp to the setjmp map.
  const Type* SBPTy = PointerType::get(Type::SByteTy);
  CastInst* BufPtr = new CastInst(Inst->getOperand(1), SBPTy, "SBJmpBuf", Inst);
  new CallInst(AddSJToMap,
               make_vector<Value*>(GetSetJmpMap(Func), BufPtr,
                                   ConstantUInt::get(Type::UIntTy,
                                                     SetJmpIDMap[Func]++), 0),
               "", Inst);

  // Change the setjmp call into a branch statement. We'll remove the
  // setjmp call in a little bit. No worries.
  BasicBlock* SetJmpContBlock = ABlock->splitBasicBlock(Inst);
  assert(SetJmpContBlock && "Couldn't split setjmp BB!!");

  SetJmpContBlock->setName("SetJmpContBlock");

  // Reposition the split BB in the BB list to make things tidier.
  Func->getBasicBlockList().remove(SetJmpContBlock);
  Func->getBasicBlockList().insert(++Function::iterator(ABlock),
                                   SetJmpContBlock);

  // This PHI node will be in the new block created from the
  // splitBasicBlock call.
  PHINode* PHI = new PHINode(Type::IntTy, "SetJmpReturn", Inst);

  // Coming from a call to setjmp, the return is 0.
  PHI->addIncoming(ConstantInt::getNullValue(Type::IntTy), ABlock);

  // Add the case for this setjmp's number...
  SwitchValuePair SVP = GetSJSwitch(Func, GetRethrowBB(Func));
  SVP.first->addCase(ConstantUInt::get(Type::UIntTy, SetJmpIDMap[Func] - 1),
                     SetJmpContBlock);

  // Value coming from the handling of the exception.
  PHI->addIncoming(SVP.second, SVP.second->getParent());

  // Replace all uses of this instruction with the PHI node created by
  // the eradication of setjmp.
  Inst->replaceAllUsesWith(PHI);
  Inst->getParent()->getInstList().erase(Inst);

  ++SetJmpsTransformed;
}

// visitCallInst - This converts all LLVM call instructions into invoke
// instructions. The except part of the invoke goes to the "LongJmpBlkPre"
// that grabs the exception and proceeds to determine if it's a longjmp
// exception or not.
void LowerSetJmp::visitCallInst(CallInst& CI)
{
  if (CI.getCalledFunction())
    if (!IsTransformableFunction(CI.getCalledFunction()->getName()) ||
        CI.getCalledFunction()->isIntrinsic()) return;

  BasicBlock* OldBB = CI.getParent();
  BasicBlock* NewBB = OldBB->splitBasicBlock(CI);
  assert(NewBB && "Couldn't split BB of \"call\" instruction!!");
  NewBB->setName("Call2Invoke");

  // Reposition the split BB in the BB list to make things tidier.
  Function* Func = OldBB->getParent();
  Func->getBasicBlockList().remove(NewBB);
  Func->getBasicBlockList().insert(++Function::iterator(OldBB), NewBB);

  // Construct the new "invoke" instruction.
  TerminatorInst* Term = OldBB->getTerminator();
  std::vector<Value*> Params(CI.op_begin() + 1, CI.op_end());
  InvokeInst* II = new
    InvokeInst(CI.getCalledValue(), NewBB, PrelimBBMap[Func],
               Params, CI.getName(), Term); 

  // Replace the old call inst with the invoke inst and remove the call.
  CI.replaceAllUsesWith(II);
  CI.getParent()->getInstList().erase(&CI);

  // The old terminator is useless now that we have the invoke inst.
  Term->getParent()->getInstList().erase(Term);
}

// visitInvokeInst - Converting the "invoke" instruction is fairly
// straight-forward. The old exception part is replaced by a query asking
// if this is a longjmp exception. If it is, then it goes to the longjmp
// exception blocks. Otherwise, control is passed the old exception.
void LowerSetJmp::visitInvokeInst(InvokeInst& II)
{
  if (II.getCalledFunction())
    if (!IsTransformableFunction(II.getCalledFunction()->getName()) ||
        II.getCalledFunction()->isIntrinsic()) return;

  Function* Func = II.getParent()->getParent();

  BasicBlock* NormalBB = II.getNormalDest();
  BasicBlock* ExceptBB = II.getExceptionalDest();

  BasicBlock* NewExceptBB = new BasicBlock("InvokeExcept", Func);
  BasicBlock::InstListType& InstList = NewExceptBB->getInstList();

  // If this is a longjmp exception, then branch to the preliminary BB of
  // the longjmp exception handling. Otherwise, go to the old exception.
  CallInst* IsLJExcept = new
    CallInst(IsLJException, std::vector<Value*>(), "IsLJExcept");
  InstList.push_back(IsLJExcept);

  BranchInst* BR = new BranchInst(PrelimBBMap[Func], ExceptBB, IsLJExcept);
  InstList.push_back(BR);

  II.setExceptionalDest(NewExceptBB);
}

// visitReturnInst - We want to destroy the setjmp map upon exit from the
// function.
void LowerSetJmp::visitReturnInst(ReturnInst& RI)
{
  Function* Func = RI.getParent()->getParent();
  new CallInst(DestroySJMap, make_vector<Value*>(GetSetJmpMap(Func), 0),
               "", &RI);
}

// visitUnwindInst - We want to destroy the setjmp map upon exit from the
// function.
void LowerSetJmp::visitUnwindInst(UnwindInst& UI)
{
  Function* Func = UI.getParent()->getParent();
  new CallInst(DestroySJMap, make_vector<Value*>(GetSetJmpMap(Func), 0),
               "", &UI);
}

Pass* createLowerSetJmpPass()
{
  return new LowerSetJmp();
}
