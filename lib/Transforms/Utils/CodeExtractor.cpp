//===- CodeExtractor.cpp - Pull code region into a new function -----------===//
// 
//                     The LLVM Compiler Infrastructure
//
// This file was developed by the LLVM research group and is distributed under
// the University of Illinois Open Source License. See LICENSE.TXT for details.
// 
//===----------------------------------------------------------------------===//
//
// This file implements the interface to tear out a code region, such as an
// individual loop or a parallel section, into a new function, replacing it with
// a call to the new function.
//
//===----------------------------------------------------------------------===//

#include "llvm/Transforms/Utils/FunctionUtils.h"
#include "llvm/Constants.h"
#include "llvm/DerivedTypes.h"
#include "llvm/Instructions.h"
#include "llvm/Module.h"
#include "llvm/Pass.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Analysis/Verifier.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "Support/Debug.h"
#include "Support/StringExtras.h"
#include <algorithm>
#include <set>
using namespace llvm;

namespace {

  /// getFunctionArg - Return a pointer to F's ARGNOth argument.
  ///
  Argument *getFunctionArg(Function *F, unsigned argno) {
    Function::aiterator I = F->abegin();
    std::advance(I, argno);
    return I;
  }

  struct CodeExtractor {
    typedef std::vector<Value*> Values;
    typedef std::vector<std::pair<unsigned, unsigned> > PhiValChangesTy;
    typedef std::map<PHINode*, PhiValChangesTy> PhiVal2ArgTy;
    PhiVal2ArgTy PhiVal2Arg;
    std::set<BasicBlock*> BlocksToExtract;
  public:
    Function *ExtractCodeRegion(const std::vector<BasicBlock*> &code);

  private:
    void findInputsOutputs(Values &inputs, Values &outputs,
                           BasicBlock *newHeader,
                           BasicBlock *newRootNode);

    void processPhiNodeInputs(PHINode *Phi,
                              Values &inputs,
                              BasicBlock *newHeader,
                              BasicBlock *newRootNode);

    void rewritePhiNodes(Function *F, BasicBlock *newFuncRoot);

    Function *constructFunction(const Values &inputs,
                                const Values &outputs,
                                BasicBlock *newRootNode, BasicBlock *newHeader,
                                Function *oldFunction, Module *M);

    void moveCodeToFunction(Function *newFunction);

    void emitCallAndSwitchStatement(Function *newFunction,
                                    BasicBlock *newHeader,
                                    Values &inputs,
                                    Values &outputs);

  };
}

void CodeExtractor::processPhiNodeInputs(PHINode *Phi,
                                         Values &inputs,
                                         BasicBlock *codeReplacer,
                                         BasicBlock *newFuncRoot) {
  // Separate incoming values and BasicBlocks as internal/external. We ignore
  // the case where both the value and BasicBlock are internal, because we don't
  // need to do a thing.
  std::vector<unsigned> EValEBB;
  std::vector<unsigned> EValIBB;
  std::vector<unsigned> IValEBB;

  for (unsigned i = 0, e = Phi->getNumIncomingValues(); i != e; ++i) {
    Value *phiVal = Phi->getIncomingValue(i);
    if (Instruction *Inst = dyn_cast<Instruction>(phiVal)) {
      if (BlocksToExtract.count(Inst->getParent())) {
        if (!BlocksToExtract.count(Phi->getIncomingBlock(i)))
          IValEBB.push_back(i);
      } else {
        if (BlocksToExtract.count(Phi->getIncomingBlock(i)))
          EValIBB.push_back(i);
        else
          EValEBB.push_back(i);
      }
    } else if (Argument *Arg = dyn_cast<Argument>(phiVal)) {
      // arguments are external
      if (BlocksToExtract.count(Phi->getIncomingBlock(i)))
        EValIBB.push_back(i);
      else
        EValEBB.push_back(i);
    } else {
      // Globals/Constants are internal, but considered `external' if they are
      // coming from an external block.
      if (!BlocksToExtract.count(Phi->getIncomingBlock(i)))
        EValEBB.push_back(i);
    }
  }

  // Both value and block are external. Need to group all of these, have an
  // external phi, pass the result as an argument, and have THIS phi use that
  // result.
  if (EValEBB.size() > 0) {
    if (EValEBB.size() == 1) {
      // Now if it's coming from the newFuncRoot, it's that funky input
      unsigned phiIdx = EValEBB[0];
      if (!isa<Constant>(Phi->getIncomingValue(phiIdx))) {
        PhiVal2Arg[Phi].push_back(std::make_pair(phiIdx, inputs.size()));
        // We can just pass this value in as argument
        inputs.push_back(Phi->getIncomingValue(phiIdx));
      }
      Phi->setIncomingBlock(phiIdx, newFuncRoot);
    } else {
      PHINode *externalPhi = new PHINode(Phi->getType(), "extPhi");
      codeReplacer->getInstList().insert(codeReplacer->begin(), externalPhi);
      for (std::vector<unsigned>::iterator i = EValEBB.begin(),
             e = EValEBB.end(); i != e; ++i) {
        externalPhi->addIncoming(Phi->getIncomingValue(*i),
                                 Phi->getIncomingBlock(*i));

        // We make these values invalid instead of deleting them because that
        // would shift the indices of other values... The fixPhiNodes should
        // clean these phi nodes up later.
        Phi->setIncomingValue(*i, 0);
        Phi->setIncomingBlock(*i, 0);
      }
      PhiVal2Arg[Phi].push_back(std::make_pair(Phi->getNumIncomingValues(),
                                               inputs.size()));
      // We can just pass this value in as argument
      inputs.push_back(externalPhi);
    }
  }

  // When the value is external, but block internal...  just pass it in as
  // argument, no change to phi node
  for (std::vector<unsigned>::iterator i = EValIBB.begin(),
         e = EValIBB.end(); i != e; ++i) {
    // rewrite the phi input node to be an argument
    PhiVal2Arg[Phi].push_back(std::make_pair(*i, inputs.size()));
    inputs.push_back(Phi->getIncomingValue(*i));
  }

  // Value internal, block external this can happen if we are extracting a part
  // of a loop.
  for (std::vector<unsigned>::iterator i = IValEBB.begin(),
         e = IValEBB.end(); i != e; ++i) {
    assert(0 && "Cannot (YET) handle internal values via external blocks");
  }
}


void CodeExtractor::findInputsOutputs(Values &inputs, Values &outputs,
                                      BasicBlock *newHeader,
                                      BasicBlock *newRootNode) {
  for (std::set<BasicBlock*>::const_iterator ci = BlocksToExtract.begin(), 
       ce = BlocksToExtract.end(); ci != ce; ++ci) {
    BasicBlock *BB = *ci;
    for (BasicBlock::iterator I = BB->begin(), E = BB->end(); I != E; ++I) {
      // If a used value is defined outside the region, it's an input.  If an
      // instruction is used outside the region, it's an output.
      if (PHINode *Phi = dyn_cast<PHINode>(I)) {
        processPhiNodeInputs(Phi, inputs, newHeader, newRootNode);
      } else {
        // All other instructions go through the generic input finder
        // Loop over the operands of each instruction (inputs)
        for (User::op_iterator op = I->op_begin(), opE = I->op_end();
             op != opE; ++op)
          if (Instruction *opI = dyn_cast<Instruction>(*op)) {
            // Check if definition of this operand is within the loop
            if (!BlocksToExtract.count(opI->getParent()))
              inputs.push_back(opI);
          } else if (isa<Argument>(*op)) {
            inputs.push_back(*op);
          }
      }
      
      // Consider uses of this instruction (outputs)
      for (Value::use_iterator UI = I->use_begin(), E = I->use_end();
           UI != E; ++UI)
        if (!BlocksToExtract.count(cast<Instruction>(*UI)->getParent()))
          outputs.push_back(*UI);
    } // for: insts
  } // for: basic blocks
}

void CodeExtractor::rewritePhiNodes(Function *F,
                                    BasicBlock *newFuncRoot) {
  // Write any changes that were saved before: use function arguments as inputs
  for (PhiVal2ArgTy::iterator i = PhiVal2Arg.begin(), e = PhiVal2Arg.end();
       i != e; ++i) {
    PHINode *phi = i->first;
    PhiValChangesTy &values = i->second;
    for (unsigned cIdx = 0, ce = values.size(); cIdx != ce; ++cIdx)
    {
      unsigned phiValueIdx = values[cIdx].first, argNum = values[cIdx].second;
      if (phiValueIdx < phi->getNumIncomingValues())
        phi->setIncomingValue(phiValueIdx, getFunctionArg(F, argNum));
      else
        phi->addIncoming(getFunctionArg(F, argNum), newFuncRoot);
    }
  }

  // Delete any invalid Phi node inputs that were marked as NULL previously
  for (PhiVal2ArgTy::iterator i = PhiVal2Arg.begin(), e = PhiVal2Arg.end();
       i != e; ++i) {
    PHINode *phi = i->first;
    for (unsigned idx = 0, end = phi->getNumIncomingValues(); idx != end; ++idx)
    {
      if (phi->getIncomingValue(idx) == 0 && phi->getIncomingBlock(idx) == 0) {
        phi->removeIncomingValue(idx);
        --idx;
        --end;
      }
    }
  }

  // We are done with the saved values
  PhiVal2Arg.clear();
}


/// constructFunction - make a function based on inputs and outputs, as follows:
/// f(in0, ..., inN, out0, ..., outN)
///
Function *CodeExtractor::constructFunction(const Values &inputs,
                                           const Values &outputs,
                                           BasicBlock *newRootNode,
                                           BasicBlock *newHeader,
                                           Function *oldFunction, Module *M) {
  DEBUG(std::cerr << "inputs: " << inputs.size() << "\n");
  DEBUG(std::cerr << "outputs: " << outputs.size() << "\n");
  BasicBlock *header = *BlocksToExtract.begin();

  // This function returns unsigned, outputs will go back by reference.
  Type *retTy = Type::UShortTy;
  std::vector<const Type*> paramTy;

  // Add the types of the input values to the function's argument list
  for (Values::const_iterator i = inputs.begin(),
         e = inputs.end(); i != e; ++i) {
    const Value *value = *i;
    DEBUG(std::cerr << "value used in func: " << value << "\n");
    paramTy.push_back(value->getType());
  }

  // Add the types of the output values to the function's argument list, but
  // make them pointer types for scalars
  for (Values::const_iterator i = outputs.begin(),
         e = outputs.end(); i != e; ++i) {
    const Value *value = *i;
    DEBUG(std::cerr << "instr used in func: " << value << "\n");
    const Type *valueType = value->getType();
    // Convert scalar types into a pointer of that type
    if (valueType->isPrimitiveType()) {
      valueType = PointerType::get(valueType);
    }
    paramTy.push_back(valueType);
  }

  DEBUG(std::cerr << "Function type: " << retTy << " f(");
  for (std::vector<const Type*>::iterator i = paramTy.begin(),
         e = paramTy.end(); i != e; ++i)
    DEBUG(std::cerr << *i << ", ");
  DEBUG(std::cerr << ")\n");

  const FunctionType *funcType = FunctionType::get(retTy, paramTy, false);

  // Create the new function
  Function *newFunction = new Function(funcType,
                                       GlobalValue::InternalLinkage,
                                       oldFunction->getName() + "_code", M);
  newFunction->getBasicBlockList().push_back(newRootNode);

  for (unsigned i = 0, e = inputs.size(); i != e; ++i) {
    std::vector<User*> Users(inputs[i]->use_begin(), inputs[i]->use_end());
    for (std::vector<User*>::iterator use = Users.begin(), useE = Users.end();
         use != useE; ++use)
      if (Instruction* inst = dyn_cast<Instruction>(*use))
        if (BlocksToExtract.count(inst->getParent()))
          inst->replaceUsesOfWith(inputs[i], getFunctionArg(newFunction, i));
  }

  // Rewrite branches to basic blocks outside of the loop to new dummy blocks
  // within the new function. This must be done before we lose track of which
  // blocks were originally in the code region.
  std::vector<User*> Users(header->use_begin(), header->use_end());
  for (std::vector<User*>::iterator i = Users.begin(), e = Users.end();
       i != e; ++i) {
    if (BranchInst *inst = dyn_cast<BranchInst>(*i)) {
      BasicBlock *BB = inst->getParent();
      if (!BlocksToExtract.count(BB) && BB->getParent() == oldFunction) {
        // The BasicBlock which contains the branch is not in the region
        // modify the branch target to a new block
        inst->replaceUsesOfWith(header, newHeader);
      }
    }
  }

  return newFunction;
}

void CodeExtractor::moveCodeToFunction(Function *newFunction) {
  Function *oldFunc = (*BlocksToExtract.begin())->getParent();
  Function::BasicBlockListType &oldBlocks = oldFunc->getBasicBlockList();
  Function::BasicBlockListType &newBlocks = newFunction->getBasicBlockList();

  for (std::set<BasicBlock*>::const_iterator i = BlocksToExtract.begin(),
         e = BlocksToExtract.end(); i != e; ++i) {
    // Delete the basic block from the old function, and the list of blocks
    oldBlocks.remove(*i);

    // Insert this basic block into the new function
    newBlocks.push_back(*i);
  }
}

void
CodeExtractor::emitCallAndSwitchStatement(Function *newFunction,
                                          BasicBlock *codeReplacer,
                                          Values &inputs,
                                          Values &outputs)
{
  // Emit a call to the new function, passing allocated memory for outputs and
  // just plain inputs for non-scalars
  std::vector<Value*> params(inputs);

  for (Values::const_iterator i = outputs.begin(), e = outputs.end(); i != e;
       ++i) {
    Value *Output = *i;
    // Create allocas for scalar outputs
    if (Output->getType()->isPrimitiveType()) {
      AllocaInst *alloca =
        new AllocaInst((*i)->getType(), 0, Output->getName()+".loc",
                       codeReplacer->getParent()->begin()->begin());
      params.push_back(alloca);

      LoadInst *load = new LoadInst(alloca, Output->getName()+".reload");
      codeReplacer->getInstList().push_back(load);
      std::vector<User*> Users((*i)->use_begin(), (*i)->use_end());
      for (std::vector<User*>::iterator use = Users.begin(), useE =Users.end();
           use != useE; ++use) {
        if (Instruction* inst = dyn_cast<Instruction>(*use)) {
          if (!BlocksToExtract.count(inst->getParent()))
            inst->replaceUsesOfWith(*i, load);
        }
      }
    } else {
      params.push_back(*i);
    }
  }

  CallInst *call = new CallInst(newFunction, params, "targetBlock");
  codeReplacer->getInstList().push_front(call);

  // Now we can emit a switch statement using the call as a value.
  SwitchInst *TheSwitch = new SwitchInst(call, codeReplacer, codeReplacer);

  // Since there may be multiple exits from the original region, make the new
  // function return an unsigned, switch on that number.  This loop iterates
  // over all of the blocks in the extracted region, updating any terminator
  // instructions in the to-be-extracted region that branch to blocks that are
  // not in the region to be extracted.
  std::map<BasicBlock*, BasicBlock*> ExitBlockMap;

  unsigned switchVal = 0;
  for (std::set<BasicBlock*>::const_iterator i = BlocksToExtract.begin(),
         e = BlocksToExtract.end(); i != e; ++i) {
    TerminatorInst *TI = (*i)->getTerminator();
    for (unsigned i = 0, e = TI->getNumSuccessors(); i != e; ++i)
      if (!BlocksToExtract.count(TI->getSuccessor(i))) {
        BasicBlock *OldTarget = TI->getSuccessor(i);
        // add a new basic block which returns the appropriate value
        BasicBlock *&NewTarget = ExitBlockMap[OldTarget];
        if (!NewTarget) {
          // If we don't already have an exit stub for this non-extracted
          // destination, create one now!
          NewTarget = new BasicBlock(OldTarget->getName() + ".exitStub",
                                     newFunction);

          ConstantUInt *brVal = ConstantUInt::get(Type::UShortTy, switchVal++);
          ReturnInst *NTRet = new ReturnInst(brVal, NewTarget);

          // Update the switch instruction.
          TheSwitch->addCase(brVal, OldTarget);

          // Restore values just before we exit
          // FIXME: Use a GetElementPtr to bunch the outputs in a struct
          for (unsigned out = 0, e = outputs.size(); out != e; ++out)
            new StoreInst(outputs[out], getFunctionArg(newFunction, out),NTRet);
        }

        // rewrite the original branch instruction with this new target
        TI->setSuccessor(i, NewTarget);
      }
  }

  // Now that we've done the deed, make the default destination of the switch
  // instruction be one of the exit blocks of the region.
  if (TheSwitch->getNumSuccessors() > 1) {
    // FIXME: this is broken w.r.t. PHI nodes, but the old code was more broken.
    // This edge is not traversable.
    TheSwitch->setSuccessor(0, TheSwitch->getSuccessor(1));
  }
}


/// ExtractRegion - Removes a loop from a function, replaces it with a call to
/// new function. Returns pointer to the new function.
///
/// algorithm:
///
/// find inputs and outputs for the region
///
/// for inputs: add to function as args, map input instr* to arg# 
/// for outputs: add allocas for scalars, 
///             add to func as args, map output instr* to arg#
///
/// rewrite func to use argument #s instead of instr*
///
/// for each scalar output in the function: at every exit, store intermediate 
/// computed result back into memory.
///
Function *CodeExtractor::ExtractCodeRegion(const std::vector<BasicBlock*> &code)
{
  // 1) Find inputs, outputs
  // 2) Construct new function
  //  * Add allocas for defs, pass as args by reference
  //  * Pass in uses as args
  // 3) Move code region, add call instr to func
  //
  BlocksToExtract.insert(code.begin(), code.end());

  Values inputs, outputs;

  // Assumption: this is a single-entry code region, and the header is the first
  // block in the region.
  BasicBlock *header = code[0];
  for (unsigned i = 1, e = code.size(); i != e; ++i)
    for (pred_iterator PI = pred_begin(code[i]), E = pred_end(code[i]);
         PI != E; ++PI)
      assert(BlocksToExtract.count(*PI) &&
             "No blocks in this region may have entries from outside the region"
             " except for the first block!");
  
  Function *oldFunction = header->getParent();

  // This takes place of the original loop
  BasicBlock *codeReplacer = new BasicBlock("codeRepl", oldFunction);

  // The new function needs a root node because other nodes can branch to the
  // head of the loop, and the root cannot have predecessors
  BasicBlock *newFuncRoot = new BasicBlock("newFuncRoot");
  newFuncRoot->getInstList().push_back(new BranchInst(header));

  // Find inputs to, outputs from the code region
  //
  // If one of the inputs is coming from a different basic block and it's in a
  // phi node, we need to rewrite the phi node:
  //
  // * All the inputs which involve basic blocks OUTSIDE of this region go into
  //   a NEW phi node that takes care of finding which value really came in.
  //   The result of this phi is passed to the function as an argument. 
  //
  // * All the other phi values stay.
  //
  // FIXME: PHI nodes' incoming blocks aren't being rewritten to accomodate for
  // blocks moving to a new function.
  // SOLUTION: move Phi nodes out of the loop header into the codeReplacer, pass
  // the values as parameters to the function
  findInputsOutputs(inputs, outputs, codeReplacer, newFuncRoot);

  // Step 2: Construct new function based on inputs/outputs,
  // Add allocas for all defs
  Function *newFunction = constructFunction(inputs, outputs, newFuncRoot, 
                                            codeReplacer, oldFunction,
                                            oldFunction->getParent());

  rewritePhiNodes(newFunction, newFuncRoot);

  emitCallAndSwitchStatement(newFunction, codeReplacer, inputs, outputs);

  moveCodeToFunction(newFunction);

  DEBUG(if (verifyFunction(*newFunction)) abort());
  return newFunction;
}

/// ExtractCodeRegion - slurp a sequence of basic blocks into a brand new
/// function
///
Function* llvm::ExtractCodeRegion(const std::vector<BasicBlock*> &code) {
  return CodeExtractor().ExtractCodeRegion(code);
}

/// ExtractBasicBlock - slurp a natural loop into a brand new function
///
Function* llvm::ExtractLoop(Loop *L) {
  return CodeExtractor().ExtractCodeRegion(L->getBlocks());
}

/// ExtractBasicBlock - slurp a basic block into a brand new function
///
Function* llvm::ExtractBasicBlock(BasicBlock *BB) {
  std::vector<BasicBlock*> Blocks;
  Blocks.push_back(BB);
  return CodeExtractor().ExtractCodeRegion(Blocks);  
}
