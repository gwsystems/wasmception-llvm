//===- FunctionInlining.cpp - Code to perform function inlining -----------===//
//
// This file implements inlining of functions.
//
// Specifically, this:
//   * Exports functionality to inline any function call
//   * Inlines functions that consist of a single basic block
//   * Is able to inline ANY function call
//   . Has a smart heuristic for when to inline a function
//
// Notice that:
//   * This pass opens up a lot of opportunities for constant propogation.  It
//     is a good idea to to run a constant propogation pass, then a DCE pass 
//     sometime after running this pass.
//
// FIXME: This pass should transform alloca instructions in the called function
//        into malloc/free pairs!
//
//===----------------------------------------------------------------------===//

#include "llvm/Transforms/FunctionInlining.h"
#include "llvm/Module.h"
#include "llvm/Pass.h"
#include "llvm/iTerminators.h"
#include "llvm/iPHINode.h"
#include "llvm/iOther.h"
#include "llvm/Type.h"
#include "Support/StatisticReporter.h"
#include <algorithm>
#include <iostream>

static Statistic<> NumInlined("inline\t\t- Number of functions inlined");
using std::cerr;

// RemapInstruction - Convert the instruction operands from referencing the 
// current values into those specified by ValueMap.
//
static inline void RemapInstruction(Instruction *I, 
				    std::map<const Value *, Value*> &ValueMap) {

  for (unsigned op = 0, E = I->getNumOperands(); op != E; ++op) {
    const Value *Op = I->getOperand(op);
    Value *V = ValueMap[Op];
    if (!V && (isa<GlobalValue>(Op) || isa<Constant>(Op)))
      continue;  // Globals and constants don't get relocated

    if (!V) {
      cerr << "Val = \n" << Op << "Addr = " << (void*)Op;
      cerr << "\nInst = " << I;
    }
    assert(V && "Referenced value not in value map!");
    I->setOperand(op, V);
  }
}

// InlineFunction - This function forcibly inlines the called function into the
// basic block of the caller.  This returns false if it is not possible to
// inline this call.  The program is still in a well defined state if this 
// occurs though.
//
// Note that this only does one level of inlining.  For example, if the 
// instruction 'call B' is inlined, and 'B' calls 'C', then the call to 'C' now 
// exists in the instruction stream.  Similiarly this will inline a recursive
// function by one level.
//
bool InlineFunction(CallInst *CI) {
  assert(isa<CallInst>(CI) && "InlineFunction only works on CallInst nodes");
  assert(CI->getParent() && "Instruction not embedded in basic block!");
  assert(CI->getParent()->getParent() && "Instruction not in function!");

  const Function *CalledFunc = CI->getCalledFunction();
  if (CalledFunc == 0 ||   // Can't inline external function or indirect call!
      CalledFunc->isExternal()) return false;

  //cerr << "Inlining " << CalledFunc->getName() << " into " 
  //     << CurrentMeth->getName() << "\n";

  BasicBlock *OrigBB = CI->getParent();

  // Call splitBasicBlock - The original basic block now ends at the instruction
  // immediately before the call.  The original basic block now ends with an
  // unconditional branch to NewBB, and NewBB starts with the call instruction.
  //
  BasicBlock *NewBB = OrigBB->splitBasicBlock(CI);
  NewBB->setName("InlinedFunctionReturnNode");

  // Remove (unlink) the CallInst from the start of the new basic block.  
  NewBB->getInstList().remove(CI);

  // If we have a return value generated by this call, convert it into a PHI 
  // node that gets values from each of the old RET instructions in the original
  // function.
  //
  PHINode *PHI = 0;
  if (CalledFunc->getReturnType() != Type::VoidTy) {
    PHI = new PHINode(CalledFunc->getReturnType(), CI->getName());

    // The PHI node should go at the front of the new basic block to merge all 
    // possible incoming values.
    //
    NewBB->getInstList().push_front(PHI);

    // Anything that used the result of the function call should now use the PHI
    // node as their operand.
    //
    CI->replaceAllUsesWith(PHI);
  }

  // Keep a mapping between the original function's values and the new
  // duplicated code's values.  This includes all of: Function arguments,
  // instruction values, constant pool entries, and basic blocks.
  //
  std::map<const Value *, Value*> ValueMap;

  // Add the function arguments to the mapping: (start counting at 1 to skip the
  // function reference itself)
  //
  Function::const_aiterator PTI = CalledFunc->abegin();
  for (unsigned a = 1, E = CI->getNumOperands(); a != E; ++a, ++PTI)
    ValueMap[PTI] = CI->getOperand(a);
  
  ValueMap[NewBB] = NewBB;  // Returns get converted to reference NewBB

  // Loop over all of the basic blocks in the function, inlining them as 
  // appropriate.  Keep track of the first basic block of the function...
  //
  for (Function::const_iterator BB = CalledFunc->begin(); 
       BB != CalledFunc->end(); ++BB) {
    assert(BB->getTerminator() && "BasicBlock doesn't have terminator!?!?");
    
    // Create a new basic block to copy instructions into!
    BasicBlock *IBB = new BasicBlock("", NewBB->getParent());
    if (BB->hasName()) IBB->setName(BB->getName()+".i");  // .i = inlined once

    ValueMap[BB] = IBB;                       // Add basic block mapping.

    // Make sure to capture the mapping that a return will use...
    // TODO: This assumes that the RET is returning a value computed in the same
    //       basic block as the return was issued from!
    //
    const TerminatorInst *TI = BB->getTerminator();
   
    // Loop over all instructions copying them over...
    Instruction *NewInst;
    for (BasicBlock::const_iterator II = BB->begin();
	 II != --BB->end(); ++II) {
      IBB->getInstList().push_back((NewInst = II->clone()));
      ValueMap[II] = NewInst;                  // Add instruction map to value.
      if (II->hasName())
        NewInst->setName(II->getName()+".i");  // .i = inlined once
    }

    // Copy over the terminator now...
    switch (TI->getOpcode()) {
    case Instruction::Ret: {
      const ReturnInst *RI = cast<ReturnInst>(TI);

      if (PHI) {   // The PHI node should include this value!
	assert(RI->getReturnValue() && "Ret should have value!");
	assert(RI->getReturnValue()->getType() == PHI->getType() && 
	       "Ret value not consistent in function!");
	PHI->addIncoming((Value*)RI->getReturnValue(),
                         (BasicBlock*)cast<BasicBlock>(&*BB));
      }

      // Add a branch to the code that was after the original Call.
      IBB->getInstList().push_back(new BranchInst(NewBB));
      break;
    }
    case Instruction::Br:
      IBB->getInstList().push_back(TI->clone());
      break;

    default:
      cerr << "FunctionInlining: Don't know how to handle terminator: " << TI;
      abort();
    }
  }


  // Loop over all of the instructions in the function, fixing up operand 
  // references as we go.  This uses ValueMap to do all the hard work.
  //
  for (Function::const_iterator BB = CalledFunc->begin(); 
       BB != CalledFunc->end(); ++BB) {
    BasicBlock *NBB = (BasicBlock*)ValueMap[BB];

    // Loop over all instructions, fixing each one as we find it...
    //
    for (BasicBlock::iterator II = NBB->begin(); II != NBB->end(); ++II)
      RemapInstruction(II, ValueMap);
  }

  if (PHI) RemapInstruction(PHI, ValueMap);  // Fix the PHI node also...

  // Change the branch that used to go to NewBB to branch to the first basic 
  // block of the inlined function.
  //
  TerminatorInst *Br = OrigBB->getTerminator();
  assert(Br && Br->getOpcode() == Instruction::Br && 
	 "splitBasicBlock broken!");
  Br->setOperand(0, ValueMap[&CalledFunc->front()]);

  // Since we are now done with the CallInst, we can finally delete it.
  delete CI;
  return true;
}

static inline bool ShouldInlineFunction(const CallInst *CI, const Function *F) {
  assert(CI->getParent() && CI->getParent()->getParent() && 
	 "Call not embedded into a function!");

  // Don't inline a recursive call.
  if (CI->getParent()->getParent() == F) return false;

  // Don't inline something too big.  This is a really crappy heuristic
  if (F->size() > 3) return false;

  // Don't inline into something too big. This is a **really** crappy heuristic
  if (CI->getParent()->getParent()->size() > 10) return false;

  // Go ahead and try just about anything else.
  return true;
}


static inline bool DoFunctionInlining(BasicBlock *BB) {
  for (BasicBlock::iterator I = BB->begin(); I != BB->end(); ++I) {
    if (CallInst *CI = dyn_cast<CallInst>(&*I)) {
      // Check to see if we should inline this function
      Function *F = CI->getCalledFunction();
      if (F && ShouldInlineFunction(CI, F)) {
	return InlineFunction(CI);
      }
    }
  }
  return false;
}

// doFunctionInlining - Use a heuristic based approach to inline functions that
// seem to look good.
//
static bool doFunctionInlining(Function &F) {
  bool Changed = false;

  // Loop through now and inline instructions a basic block at a time...
  for (Function::iterator I = F.begin(); I != F.end(); )
    if (DoFunctionInlining(I)) {
      ++NumInlined;
      Changed = true;
    } else {
      ++I;
    }

  return Changed;
}

namespace {
  struct FunctionInlining : public FunctionPass {
    virtual bool runOnFunction(Function &F) {
      return doFunctionInlining(F);
    }
  };
  RegisterOpt<FunctionInlining> X("inline", "Function Integration/Inlining");
}

Pass *createFunctionInliningPass() { return new FunctionInlining(); }
