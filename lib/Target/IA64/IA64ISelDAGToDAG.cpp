//===---- IA64ISelDAGToDAG.cpp - IA64 pattern matching inst selector ------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file was developed by Duraid Madina and is distributed under
// the University of Illinois Open Source License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines a pattern matching instruction selector for IA64,
// converting a legalized dag to an IA64 dag.
//
//===----------------------------------------------------------------------===//

#include "IA64.h"
#include "IA64TargetMachine.h"
#include "IA64ISelLowering.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/SSARegMap.h"
#include "llvm/CodeGen/SelectionDAG.h"
#include "llvm/CodeGen/SelectionDAGISel.h"
#include "llvm/Target/TargetOptions.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/Constants.h"
#include "llvm/GlobalValue.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/MathExtras.h"
using namespace llvm;

namespace {
  Statistic<> FusedFP ("ia64-codegen", "Number of fused fp operations");
  Statistic<> FrameOff("ia64-codegen", "Number of frame idx offsets collapsed");
    
  //===--------------------------------------------------------------------===//
  /// IA64DAGToDAGISel - IA64 specific code to select IA64 machine
  /// instructions for SelectionDAG operations.
  ///
  class IA64DAGToDAGISel : public SelectionDAGISel {
    IA64TargetLowering IA64Lowering;
    unsigned GlobalBaseReg;
  public:
    IA64DAGToDAGISel(TargetMachine &TM)
      : SelectionDAGISel(IA64Lowering), IA64Lowering(TM) {}
    
    virtual bool runOnFunction(Function &Fn) {
      // Make sure we re-emit a set of the global base reg if necessary
      GlobalBaseReg = 0;
      return SelectionDAGISel::runOnFunction(Fn);
    }
 
    /// getI64Imm - Return a target constant with the specified value, of type
    /// i64.
    inline SDOperand getI64Imm(uint64_t Imm) {
      return CurDAG->getTargetConstant(Imm, MVT::i64);
    }

    /// getGlobalBaseReg - insert code into the entry mbb to materialize the PIC
    /// base register.  Return the virtual register that holds this value.
    // SDOperand getGlobalBaseReg(); TODO: hmm
    
    // Select - Convert the specified operand from a target-independent to a
    // target-specific node if it hasn't already been changed.
    SDOperand Select(SDOperand Op);
    
    SDNode *SelectIntImmediateExpr(SDOperand LHS, SDOperand RHS,
                                   unsigned OCHi, unsigned OCLo,
                                   bool IsArithmetic = false,
                                   bool Negate = false);
    SDNode *SelectBitfieldInsert(SDNode *N);

    /// SelectCC - Select a comparison of the specified values with the
    /// specified condition code, returning the CR# of the expression.
    SDOperand SelectCC(SDOperand LHS, SDOperand RHS, ISD::CondCode CC);

    /// SelectAddr - Given the specified address, return the two operands for a
    /// load/store instruction, and return true if it should be an indexed [r+r]
    /// operation.
    bool SelectAddr(SDOperand Addr, SDOperand &Op1, SDOperand &Op2);

    SDOperand BuildSDIVSequence(SDNode *N);
    SDOperand BuildUDIVSequence(SDNode *N);
    
    /// InstructionSelectBasicBlock - This callback is invoked by
    /// SelectionDAGISel when it has created a SelectionDAG for us to codegen.
    virtual void InstructionSelectBasicBlock(SelectionDAG &DAG);
    
    virtual const char *getPassName() const {
      return "IA64 (Itanium) DAG->DAG Instruction Selector";
    } 

// Include the pieces autogenerated from the target description.
#include "IA64GenDAGISel.inc"
    
private:
    SDOperand SelectCALL(SDOperand Op);
  };
}

/// InstructionSelectBasicBlock - This callback is invoked by
/// SelectionDAGISel when it has created a SelectionDAG for us to codegen.
void IA64DAGToDAGISel::InstructionSelectBasicBlock(SelectionDAG &DAG) {
  DEBUG(BB->dump());
  
  // The selection process is inherently a bottom-up recursive process (users
  // select their uses before themselves).  Given infinite stack space, we
  // could just start selecting on the root and traverse the whole graph.  In
  // practice however, this causes us to run out of stack space on large basic
  // blocks.  To avoid this problem, select the entry node, then all its uses,
  // iteratively instead of recursively.
  std::vector<SDOperand> Worklist;
  Worklist.push_back(DAG.getEntryNode());
  
  // Note that we can do this in the IA64 target (scanning forward across token
  // chain edges) because no nodes ever get folded across these edges.  On a
  // target like X86 which supports load/modify/store operations, this would
  // have to be more careful.
  while (!Worklist.empty()) {
    SDOperand Node = Worklist.back();
    Worklist.pop_back();
    
    // Chose from the least deep of the top two nodes.
    if (!Worklist.empty() &&
        Worklist.back().Val->getNodeDepth() < Node.Val->getNodeDepth())
      std::swap(Worklist.back(), Node);
    
    if ((Node.Val->getOpcode() >= ISD::BUILTIN_OP_END &&
         Node.Val->getOpcode() < IA64ISD::FIRST_NUMBER) ||
        CodeGenMap.count(Node)) continue;
    
    for (SDNode::use_iterator UI = Node.Val->use_begin(),
         E = Node.Val->use_end(); UI != E; ++UI) {
      // Scan the values.  If this use has a value that is a token chain, add it
      // to the worklist.
      SDNode *User = *UI;
      for (unsigned i = 0, e = User->getNumValues(); i != e; ++i)
        if (User->getValueType(i) == MVT::Other) {
          Worklist.push_back(SDOperand(User, i));
          break; 
        }
    }

    // Finally, legalize this node.
    Select(Node);
  }
    
  // Select target instructions for the DAG.
  DAG.setRoot(Select(DAG.getRoot()));
  CodeGenMap.clear();
  DAG.RemoveDeadNodes();
  
  // Emit machine code to BB. 
  ScheduleAndEmitDAG(DAG);
}


SDOperand IA64DAGToDAGISel::SelectCALL(SDOperand Op) {
  SDNode *N = Op.Val;
  SDOperand Chain = Select(N->getOperand(0));
  
  unsigned CallOpcode;
  std::vector<SDOperand> CallOperands;

  // save the current GP, SP and RP : FIXME: do we need to do all 3 always?
  SDOperand GPBeforeCall = CurDAG->getCopyFromReg(Chain, IA64::r1, MVT::i64);
  Chain = GPBeforeCall.getValue(1);
  SDOperand SPBeforeCall = CurDAG->getCopyFromReg(Chain, IA64::r12, MVT::i64);
  Chain = SPBeforeCall.getValue(1);
  SDOperand RPBeforeCall = CurDAG->getCopyFromReg(Chain, IA64::rp, MVT::i64);
  Chain = RPBeforeCall.getValue(1);

  // if we can call directly, do so
  if (GlobalAddressSDNode *GASD =
      dyn_cast<GlobalAddressSDNode>(N->getOperand(1))) {
    CallOpcode = IA64::BRCALL_IPREL;
    CallOperands.push_back(CurDAG->getTargetGlobalAddress(GASD->getGlobal(),
                                                          MVT::i64));
  } else if (ExternalSymbolSDNode *ESSDN = // FIXME: we currently NEED this
		                         // case for correctness, to avoid
					 // "non-pic code with imm reloc.n
					 // against dynamic symbol" errors
             dyn_cast<ExternalSymbolSDNode>(N->getOperand(1))) {
    CallOpcode = IA64::BRCALL_IPREL;
    CallOperands.push_back(N->getOperand(1));
  } else {
    // otherwise we need to load the function descriptor,
    // load the branch target (function)'s entry point and GP,
    //  branch (call) then restore the
    // GP
    
    SDOperand FnDescriptor = Select(N->getOperand(1));
   
    // load the branch target's entry point [mem] and 
    // GP value [mem+8]
    SDOperand targetEntryPoint=CurDAG->getLoad(MVT::i64, Chain, FnDescriptor,
	                                CurDAG->getSrcValue(0));
    SDOperand targetGPAddr=CurDAG->getNode(ISD::ADD, MVT::i64, FnDescriptor, 
	                    CurDAG->getConstant(8, MVT::i64));
    SDOperand targetGP=CurDAG->getLoad(MVT::i64, Chain, targetGPAddr,
	                                CurDAG->getSrcValue(0));
    
    // Copy the callee address into the b6 branch register
    SDOperand B6 = CurDAG->getRegister(IA64::B6, MVT::i64);
    Chain = CurDAG->getNode(ISD::CopyToReg, MVT::Other, Chain, B6,
	             targetEntryPoint);
    
    CallOperands.push_back(B6);
    CallOpcode = IA64::BRCALL_INDIRECT;
  }
 
  // see section 8.5.8 of "Itanium Software Conventions and
  // Runtime Architecture Guide to see some examples of what's going
  // on here. (in short: int args get mapped 1:1 'slot-wise' to out0->out7,
  // while FP args get mapped to F8->F15 as needed)
  
  // TODO: support in-memory arguments
 
  unsigned used_FPArgs=0; // how many FP args have been used so far?

  unsigned intArgs[] = {IA64::out0, IA64::out1, IA64::out2, IA64::out3,
                        IA64::out4, IA64::out5, IA64::out6, IA64::out7 };
  unsigned FPArgs[] = {IA64::F8, IA64::F9, IA64::F10, IA64::F11,
                       IA64::F12, IA64::F13, IA64::F14, IA64::F15 };

  SDOperand InFlag;  // Null incoming flag value.
  
  for (unsigned i = 2, e = N->getNumOperands(); i != e; ++i) {
    unsigned DestReg = 0;
    MVT::ValueType RegTy = N->getOperand(i).getValueType();
    if (RegTy == MVT::i64) {
      assert((i-2) < 8 && "Too many int args");
      DestReg = intArgs[i-2];
    } else {
      assert(MVT::isFloatingPoint(N->getOperand(i).getValueType()) &&
             "Unpromoted integer arg?");
      assert(used_FPArgs < 8 && "Too many fp args");
      DestReg = FPArgs[used_FPArgs++];
    }
    
    if (N->getOperand(i).getOpcode() != ISD::UNDEF) {
      SDOperand Val = Select(N->getOperand(i));
      Chain = CurDAG->getCopyToReg(Chain, DestReg, Val, InFlag);
      InFlag = Chain.getValue(1);
      CallOperands.push_back(CurDAG->getRegister(DestReg, RegTy));
      // some functions (e.g. printf) want floating point arguments
      // *also* passed as in-memory representations in integer registers
      // this is FORTRAN legacy junk which we don't _always_ need
      // to do, but to be on the safe side, we do. 
      if(MVT::isFloatingPoint(N->getOperand(i).getValueType())) {
        assert((i-2) < 8 && "FP args alone would fit, but no int regs left");
	DestReg = intArgs[i-2]; // this FP arg goes in an int reg
        // GETFD takes an FP reg and writes a GP reg	
	Chain = CurDAG->getTargetNode(IA64::GETFD, MVT::i64, Val, InFlag);
        // FIXME: this next line is a bit unfortunate 
	Chain = CurDAG->getCopyToReg(Chain, DestReg, Chain, InFlag); 
        InFlag = Chain.getValue(1);
        CallOperands.push_back(CurDAG->getRegister(DestReg, MVT::i64));
      }
    }
  }
  
  // Finally, once everything is in registers to pass to the call, emit the
  // call itself.
  if (InFlag.Val)
    CallOperands.push_back(InFlag);   // Strong dep on register copies.
  else
    CallOperands.push_back(Chain);    // Weak dep on whatever occurs before
  Chain = CurDAG->getTargetNode(CallOpcode, MVT::Other, MVT::Flag,
                                CallOperands);
 
//  return Chain; // HACK: err, this means that functions never return anything. need to intergrate this with the code immediately below FIXME XXX

  std::vector<SDOperand> CallResults;
  
  // If the call has results, copy the values out of the ret val registers.
  switch (N->getValueType(0)) {
    default: assert(0 && "Unexpected ret value!");
    case MVT::Other: break;
    case MVT::i64:
        Chain = CurDAG->getCopyFromReg(Chain, IA64::r8, MVT::i64,
                                       Chain.getValue(1)).getValue(1);
        CallResults.push_back(Chain.getValue(0));
      break;
    case MVT::f64:
      Chain = CurDAG->getCopyFromReg(Chain, IA64::F8, N->getValueType(0),
                                     Chain.getValue(1)).getValue(1);
      CallResults.push_back(Chain.getValue(0));
      break;
  }
   // restore GP, SP and RP
  Chain = CurDAG->getCopyToReg(Chain, IA64::r1, GPBeforeCall);
  Chain = CurDAG->getCopyToReg(Chain, IA64::r12, SPBeforeCall);
  Chain = CurDAG->getCopyToReg(Chain, IA64::rp, RPBeforeCall);
 
  CallResults.push_back(Chain);

  for (unsigned i = 0, e = CallResults.size(); i != e; ++i)
    CodeGenMap[Op.getValue(i)] = CallResults[i];
 
  return CallResults[Op.ResNo];
}

// Select - Convert the specified operand from a target-independent to a
// target-specific node if it hasn't already been changed.
SDOperand IA64DAGToDAGISel::Select(SDOperand Op) {
  SDNode *N = Op.Val;
  if (N->getOpcode() >= ISD::BUILTIN_OP_END &&
      N->getOpcode() < IA64ISD::FIRST_NUMBER)
    return Op;   // Already selected.

  // If this has already been converted, use it.
  std::map<SDOperand, SDOperand>::iterator CGMI = CodeGenMap.find(Op);
  if (CGMI != CodeGenMap.end()) return CGMI->second;
  
  switch (N->getOpcode()) {
  default: break;

  case ISD::CALL:
  case ISD::TAILCALL: return SelectCALL(Op);
 
/* todo:
 * case ISD::DYNAMIC_STACKALLOC:
*/
  case ISD::ConstantFP: {
    SDOperand Chain = CurDAG->getEntryNode(); // this is a constant, so..

    if (cast<ConstantFPSDNode>(N)->isExactlyValue(+0.0))
      return CurDAG->getCopyFromReg(Chain, IA64::F0, MVT::f64);
    else if (cast<ConstantFPSDNode>(N)->isExactlyValue(+1.0))
      return CurDAG->getCopyFromReg(Chain, IA64::F1, MVT::f64);
    else
      assert(0 && "Unexpected FP constant!");
  }

  case ISD::FrameIndex: { // TODO: reduce creepyness
    int FI = cast<FrameIndexSDNode>(N)->getIndex();
    if (N->hasOneUse()) {
      CurDAG->SelectNodeTo(N, IA64::MOV, MVT::i64,
                           CurDAG->getTargetFrameIndex(FI, MVT::i64));
      return SDOperand(N, 0);
    }
    return CurDAG->getTargetNode(IA64::MOV, MVT::i64,
                                CurDAG->getTargetFrameIndex(FI, MVT::i64));
  }

  case ISD::ConstantPool: {
    Constant *C = cast<ConstantPoolSDNode>(N)->get();
    SDOperand CPI = CurDAG->getTargetConstantPool(C, MVT::i64);
    return CurDAG->getTargetNode(IA64::ADDL_GA, MVT::i64, // ?
	                      CurDAG->getRegister(IA64::r1, MVT::i64), CPI);
  }

  case ISD::GlobalAddress: {
    GlobalValue *GV = cast<GlobalAddressSDNode>(N)->getGlobal();
    SDOperand GA = CurDAG->getTargetGlobalAddress(GV, MVT::i64);
    SDOperand Tmp = CurDAG->getTargetNode(IA64::ADDL_GA, MVT::i64, 
	                          CurDAG->getRegister(IA64::r1, MVT::i64), GA);
    return CurDAG->getTargetNode(IA64::LD8, MVT::i64, Tmp);
  }
			   
  case ISD::LOAD:
  case ISD::EXTLOAD:
  case ISD::ZEXTLOAD: {
    SDOperand Chain = Select(N->getOperand(0));
    SDOperand Address = Select(N->getOperand(1));

    MVT::ValueType TypeBeingLoaded = (N->getOpcode() == ISD::LOAD) ?
      N->getValueType(0) : cast<VTSDNode>(N->getOperand(3))->getVT();
    unsigned Opc;
    switch (TypeBeingLoaded) {
    default: N->dump(); assert(0 && "Cannot load this type!");
    case MVT::i1: { // this is a bool
      Opc = IA64::LD1; // first we load a byte, then compare for != 0
      CurDAG->SelectNodeTo(N, IA64::CMPNE, MVT::i1, MVT::Other, 
	CurDAG->getTargetNode(Opc, MVT::i64, Address),
	CurDAG->getRegister(IA64::r0, MVT::i64), Chain);
      return SDOperand(N, Op.ResNo); // XXX: early exit
      }
    case MVT::i8:  Opc = IA64::LD1; break;
    case MVT::i16: Opc = IA64::LD2; break;
    case MVT::i32: Opc = IA64::LD4; break;
    case MVT::i64: Opc = IA64::LD8; break;
    
    case MVT::f32: Opc = IA64::LDF4; break;
    case MVT::f64: Opc = IA64::LDF8; break;
    }

    CurDAG->SelectNodeTo(N, Opc, N->getValueType(0), MVT::Other,
                             Address, Chain); // TODO: comment this
    
    return SDOperand(N, Op.ResNo);
  }
  
  case ISD::TRUNCSTORE:
  case ISD::STORE: {
    SDOperand Address = Select(N->getOperand(2));

    unsigned Opc;
    if (N->getOpcode() == ISD::STORE) {
      switch (N->getOperand(1).getValueType()) {
      default: assert(0 && "unknown Type in store");
      case MVT::i64: Opc = IA64::ST8;  break;
      case MVT::f64: Opc = IA64::STF8; break;
     }
    } else { //ISD::TRUNCSTORE
      switch(cast<VTSDNode>(N->getOperand(4))->getVT()) {
      default: assert(0 && "unknown Type in store");
      case MVT::i8:  Opc = IA64::ST1;  break;
      case MVT::i16: Opc = IA64::ST2;  break;
      case MVT::i32: Opc = IA64::ST4;  break;
      case MVT::f32: Opc = IA64::STF4; break;
      }
    }
    
    CurDAG->SelectNodeTo(N, Opc, MVT::Other, Select(N->getOperand(2)),
                         Select(N->getOperand(1)), Select(N->getOperand(0)));
    return SDOperand(N, 0);
  }

  case ISD::BRCOND: {
    SDOperand Chain = Select(N->getOperand(0));
    SDOperand CC = Select(N->getOperand(1));
    MachineBasicBlock *Dest =
      cast<BasicBlockSDNode>(N->getOperand(2))->getBasicBlock();
    //FIXME - we do NOT need long branches all the time
    CurDAG->SelectNodeTo(N, IA64::BRLCOND_NOTCALL, MVT::Other, CC, CurDAG->getBasicBlock(Dest), Chain);
    return SDOperand(N, 0);
  }

  case ISD::CALLSEQ_START:
  case ISD::CALLSEQ_END: {
    int64_t Amt = cast<ConstantSDNode>(N->getOperand(1))->getValue();
    unsigned Opc = N->getOpcode() == ISD::CALLSEQ_START ?
                       IA64::ADJUSTCALLSTACKDOWN : IA64::ADJUSTCALLSTACKUP;
    CurDAG->SelectNodeTo(N, Opc, MVT::Other,
                         getI64Imm(Amt), Select(N->getOperand(0)));
    return SDOperand(N, 0);
  }

  case ISD::RET: {
    SDOperand Chain = Select(N->getOperand(0));     // Token chain.

    switch (N->getNumOperands()) {
    default:
      assert(0 && "Unknown return instruction!");
    case 2: {
      SDOperand RetVal = Select(N->getOperand(1));
      switch (RetVal.getValueType()) {
      default: assert(0 && "I don't know how to return this type! (promote?)");
               // FIXME: do I need to add support for bools here?
               // (return '0' or '1' in r8, basically...)
               //
               // FIXME: need to round floats - 80 bits is bad, the tester
               // told me so
      case MVT::i64:
        // we mark r8 as live on exit up above in LowerArguments()
        // BuildMI(BB, IA64::MOV, 1, IA64::r8).addReg(Tmp1);
        Chain = CurDAG->getCopyToReg(Chain, IA64::r8, RetVal);
	break;
      case MVT::f64:
        // we mark F8 as live on exit up above in LowerArguments()
        // BuildMI(BB, IA64::FMOV, 1, IA64::F8).addReg(Tmp1);
        Chain = CurDAG->getCopyToReg(Chain, IA64::F8, RetVal);
        break;
      }
      break;
      }
    case 1:
      break;
    }

    // we need to copy VirtGPR (the vreg (to become a real reg)) that holds
    // the output of this function's alloc instruction back into ar.pfs
    // before we return. this copy must not float up above the last 
    // outgoing call in this function!!!
    SDOperand AR_PFSVal = CurDAG->getCopyFromReg(Chain, IA64Lowering.VirtGPR,
		                                  MVT::i64);
    Chain = AR_PFSVal.getValue(1);
    Chain = CurDAG->getCopyToReg(Chain, IA64::AR_PFS, AR_PFSVal);

    CurDAG->SelectNodeTo(N, IA64::RET, MVT::Other, Chain); // and then just emit a 'ret' instruction
    
    // before returning, restore the ar.pfs register (set by the 'alloc' up top)
    // BuildMI(BB, IA64::MOV, 1).addReg(IA64::AR_PFS).addReg(IA64Lowering.VirtGPR);
    //
    return SDOperand(N, 0);
  }
  
  case ISD::BR:
		 // FIXME: we don't need long branches all the time!
    CurDAG->SelectNodeTo(N, IA64::BRL_NOTCALL, MVT::Other, N->getOperand(1),
                         Select(N->getOperand(0)));
    return SDOperand(N, 0);
  
  }
  
  return SelectCode(Op);
}


/// createIA64DAGToDAGInstructionSelector - This pass converts a legalized DAG
/// into an IA64-specific DAG, ready for instruction scheduling.
///
FunctionPass *llvm::createIA64DAGToDAGInstructionSelector(TargetMachine &TM) {
  return new IA64DAGToDAGISel(TM);
}

