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
#include <iostream>
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
    SDOperand SelectDIV(SDOperand Op);
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

SDOperand IA64DAGToDAGISel::SelectDIV(SDOperand Op) {
  SDNode *N = Op.Val;
  SDOperand Chain = Select(N->getOperand(0));

  SDOperand Tmp1 = Select(N->getOperand(0));
  SDOperand Tmp2 = Select(N->getOperand(1));

  bool isFP=false;

  if(MVT::isFloatingPoint(Tmp1.getValueType()))
    isFP=true;
    
  bool isModulus=false; // is it a division or a modulus?
  bool isSigned=false;

  switch(N->getOpcode()) {
    case ISD::FDIV:
    case ISD::SDIV:  isModulus=false; isSigned=true;  break;
    case ISD::UDIV:  isModulus=false; isSigned=false; break;
    case ISD::FREM:
    case ISD::SREM:  isModulus=true;  isSigned=true;  break;
    case ISD::UREM:  isModulus=true;  isSigned=false; break;
  }

  // TODO: check for integer divides by powers of 2 (or other simple patterns?)

    SDOperand TmpPR, TmpPR2;
    SDOperand TmpF1, TmpF2, TmpF3, TmpF4, TmpF5, TmpF6, TmpF7, TmpF8;
    SDOperand TmpF9, TmpF10,TmpF11,TmpF12,TmpF13,TmpF14,TmpF15;
    SDOperand Result;

    // we'll need copies of F0 and F1
    SDOperand F0 = CurDAG->getRegister(IA64::F0, MVT::f64);
    SDOperand F1 = CurDAG->getRegister(IA64::F1, MVT::f64);
    
    // OK, emit some code:

    if(!isFP) {
      // first, load the inputs into FP regs.
      TmpF1 = CurDAG->getTargetNode(IA64::SETFSIG, MVT::f64, Tmp1);
      Chain = TmpF1.getValue(1);
      TmpF2 = CurDAG->getTargetNode(IA64::SETFSIG, MVT::f64, Tmp2);
      Chain = TmpF2.getValue(1);
      
      // next, convert the inputs to FP
      if(isSigned) {
        TmpF3 = CurDAG->getTargetNode(IA64::FCVTXF, MVT::f64, TmpF1);
        Chain = TmpF3.getValue(1);
        TmpF4 = CurDAG->getTargetNode(IA64::FCVTXF, MVT::f64, TmpF2);
        Chain = TmpF4.getValue(1);
      } else { // is unsigned
        TmpF3 = CurDAG->getTargetNode(IA64::FCVTXUFS1, MVT::f64, TmpF1);
        Chain = TmpF3.getValue(1);
        TmpF4 = CurDAG->getTargetNode(IA64::FCVTXUFS1, MVT::f64, TmpF2);
        Chain = TmpF4.getValue(1);
      }

    } else { // this is an FP divide/remainder, so we 'leak' some temp
             // regs and assign TmpF3=Tmp1, TmpF4=Tmp2
      TmpF3=Tmp1;
      TmpF4=Tmp2;
    }

    // we start by computing an approximate reciprocal (good to 9 bits?)
    // note, this instruction writes _both_ TmpF5 (answer) and TmpPR (predicate)
    if(isFP)
      TmpF5 = CurDAG->getTargetNode(IA64::FRCPAS0, MVT::f64, MVT::i1,
	                          TmpF3, TmpF4);
    else
      TmpF5 = CurDAG->getTargetNode(IA64::FRCPAS1, MVT::f64, MVT::i1,
                                  TmpF3, TmpF4);
                                  
    TmpPR = TmpF5.getValue(1);
    Chain = TmpF5.getValue(2);

    SDOperand minusB;
    if(isModulus) { // for remainders, it'll be handy to have
                             // copies of -input_b
      minusB = CurDAG->getTargetNode(IA64::SUB, MVT::i64,
                  CurDAG->getRegister(IA64::r0, MVT::i64), Tmp2);
      Chain = minusB.getValue(1);
    }
    
    SDOperand TmpE0, TmpY1, TmpE1, TmpY2;
    
    TmpE0 = CurDAG->getTargetNode(IA64::CFNMAS1, MVT::f64,
      TmpF4, TmpF5, F1, TmpPR);
    Chain = TmpE0.getValue(1);
    TmpY1 = CurDAG->getTargetNode(IA64::CFMAS1, MVT::f64,
      TmpF5, TmpE0, TmpF5, TmpPR);
    Chain = TmpY1.getValue(1);
    TmpE1 = CurDAG->getTargetNode(IA64::CFMAS1, MVT::f64,
      TmpE0, TmpE0, F0, TmpPR);
    Chain = TmpE1.getValue(1);
    TmpY2 = CurDAG->getTargetNode(IA64::CFMAS1, MVT::f64,
      TmpY1, TmpE1, TmpY1, TmpPR);
    Chain = TmpY2.getValue(1);
    
    if(isFP) { // if this is an FP divide, we finish up here and exit early
      if(isModulus)
        assert(0 && "Sorry, try another FORTRAN compiler.");
 
      SDOperand TmpE2, TmpY3, TmpQ0, TmpR0;
      
      TmpE2 = CurDAG->getTargetNode(IA64::CFMAS1, MVT::f64,
        TmpE1, TmpE1, F0, TmpPR);
      Chain = TmpE2.getValue(1);
      TmpY3 = CurDAG->getTargetNode(IA64::CFMAS1, MVT::f64,
        TmpY2, TmpE2, TmpY2, TmpPR);
      Chain = TmpY3.getValue(1);
      TmpQ0 = CurDAG->getTargetNode(IA64::CFMADS1, MVT::f64, // double prec!
        Tmp1, TmpY3, F0, TmpPR);
      Chain = TmpQ0.getValue(1);
      TmpR0 = CurDAG->getTargetNode(IA64::CFNMADS1, MVT::f64, // double prec!
        Tmp2, TmpQ0, Tmp1, TmpPR);
      Chain = TmpR0.getValue(1);

// we want Result to have the same target register as the frcpa, so
// we two-address hack it. See the comment "for this to work..." on
// page 48 of Intel application note #245415
      Result = CurDAG->getTargetNode(IA64::TCFMADS0, MVT::f64, // d.p. s0 rndg!
        TmpF5, TmpY3, TmpR0, TmpQ0, TmpPR);
      Chain = Result.getValue(1);
      return Result; // XXX: early exit!
    } else { // this is *not* an FP divide, so there's a bit left to do:
    
      SDOperand TmpQ2, TmpR2, TmpQ3, TmpQ;
      
      TmpQ2 = CurDAG->getTargetNode(IA64::CFMAS1, MVT::f64,
        TmpF3, TmpY2, F0, TmpPR);
      Chain = TmpQ2.getValue(1);
      TmpR2 = CurDAG->getTargetNode(IA64::CFNMAS1, MVT::f64,
        TmpF4, TmpQ2, TmpF3, TmpPR);
      Chain = TmpR2.getValue(1);
      
// we want TmpQ3 to have the same target register as the frcpa? maybe we
// should two-address hack it. See the comment "for this to work..." on page
// 48 of Intel application note #245415
      TmpQ3 = CurDAG->getTargetNode(IA64::TCFMAS1, MVT::f64,
        TmpF5, TmpR2, TmpY2, TmpQ2, TmpPR);
      Chain = TmpQ3.getValue(1);

      // STORY: without these two-address instructions (TCFMAS1 and TCFMADS0)
      // the FPSWA won't be able to help out in the case of large/tiny
      // arguments. Other fun bugs may also appear, e.g. 0/x = x, not 0.
      
      if(isSigned)
        TmpQ = CurDAG->getTargetNode(IA64::FCVTFXTRUNCS1, MVT::f64, TmpQ3);
      else
        TmpQ = CurDAG->getTargetNode(IA64::FCVTFXUTRUNCS1, MVT::f64, TmpQ3);
      
      Chain = TmpQ.getValue(1);

      if(isModulus) {
        SDOperand FPminusB = CurDAG->getTargetNode(IA64::SETFSIG, MVT::f64,
          minusB);
        Chain = FPminusB.getValue(1);
        SDOperand Remainder = CurDAG->getTargetNode(IA64::XMAL, MVT::f64,
          TmpQ, FPminusB, TmpF1);
        Chain = Remainder.getValue(1);
        Result = CurDAG->getTargetNode(IA64::GETFSIG, MVT::i64, Remainder);
        Chain = Result.getValue(1);
      } else { // just an integer divide
        Result = CurDAG->getTargetNode(IA64::GETFSIG, MVT::i64, TmpQ);
        Chain = Result.getValue(1);
      }

      return Result;
    } // wasn't an FP divide
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

  case IA64ISD::BRCALL: { // XXX: this is also a hack!
    SDOperand Chain = Select(N->getOperand(0));
    SDOperand InFlag;  // Null incoming flag value.

    if(N->getNumOperands()==3) // we have an incoming chain, callee and flag
      InFlag = Select(N->getOperand(2));

    unsigned CallOpcode;
    SDOperand CallOperand;
    
    // if we can call directly, do so
    if (GlobalAddressSDNode *GASD =
      dyn_cast<GlobalAddressSDNode>(N->getOperand(1))) {
      CallOpcode = IA64::BRCALL_IPREL_GA;
      CallOperand = CurDAG->getTargetGlobalAddress(GASD->getGlobal(), MVT::i64);
    } else if (ExternalSymbolSDNode *ESSDN = // FIXME: we currently NEED this
		                         // case for correctness, to avoid
					 // "non-pic code with imm reloc.n
					 // against dynamic symbol" errors
             dyn_cast<ExternalSymbolSDNode>(N->getOperand(1))) {
    CallOpcode = IA64::BRCALL_IPREL_ES;
    CallOperand = N->getOperand(1);
  } else {
    // otherwise we need to load the function descriptor,
    // load the branch target (function)'s entry point and GP,
    // branch (call) then restore the GP
    SDOperand FnDescriptor = Select(N->getOperand(1));
   
    // load the branch target's entry point [mem] and 
    // GP value [mem+8]
    SDOperand targetEntryPoint=CurDAG->getTargetNode(IA64::LD8, MVT::i64,
		    FnDescriptor);
    Chain = targetEntryPoint.getValue(1);
    SDOperand targetGPAddr=CurDAG->getTargetNode(IA64::ADDS, MVT::i64, 
		    FnDescriptor, CurDAG->getConstant(8, MVT::i64));
    Chain = targetGPAddr.getValue(1);
    SDOperand targetGP=CurDAG->getTargetNode(IA64::LD8, MVT::i64,
		    targetGPAddr);
    Chain = targetGP.getValue(1);

    Chain = CurDAG->getCopyToReg(Chain, IA64::r1, targetGP, InFlag);
    InFlag = Chain.getValue(1);
    Chain = CurDAG->getCopyToReg(Chain, IA64::B6, targetEntryPoint, InFlag); // FLAG these?
    InFlag = Chain.getValue(1);
    
    CallOperand = CurDAG->getRegister(IA64::B6, MVT::i64);
    CallOpcode = IA64::BRCALL_INDIRECT;
  }
 
   // Finally, once everything is setup, emit the call itself
   if(InFlag.Val)
     Chain = CurDAG->getTargetNode(CallOpcode, MVT::Other, MVT::Flag, CallOperand, InFlag);
   else // there might be no arguments
     Chain = CurDAG->getTargetNode(CallOpcode, MVT::Other, MVT::Flag, CallOperand, Chain);
   InFlag = Chain.getValue(1);

   std::vector<SDOperand> CallResults;

   CallResults.push_back(Chain);
   CallResults.push_back(InFlag);

   for (unsigned i = 0, e = CallResults.size(); i != e; ++i)
     CodeGenMap[Op.getValue(i)] = CallResults[i];
   return CallResults[Op.ResNo];
  }
  
  case IA64ISD::GETFD: {
    SDOperand Input = Select(N->getOperand(0));
    SDOperand Result = CurDAG->getTargetNode(IA64::GETFD, MVT::i64, Input);
    CodeGenMap[Op] = Result;
    return Result;
  } 
  
  case ISD::FDIV:
  case ISD::SDIV:
  case ISD::UDIV:
  case ISD::SREM:
  case ISD::UREM: return SelectDIV(Op);
 
  case ISD::TargetConstantFP: {
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
    if (N->hasOneUse())
      return CurDAG->SelectNodeTo(N, IA64::MOV, MVT::i64,
                                  CurDAG->getTargetFrameIndex(FI, MVT::i64));
    else
      return CodeGenMap[Op] = CurDAG->getTargetNode(IA64::MOV, MVT::i64,
                                CurDAG->getTargetFrameIndex(FI, MVT::i64));
  }

  case ISD::ConstantPool: { // TODO: nuke the constant pool
			    //       (ia64 doesn't need one)
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
  
/* XXX  case ISD::ExternalSymbol: {
    SDOperand EA = CurDAG->getTargetExternalSymbol(cast<ExternalSymbolSDNode>(N)->getSymbol(),
	  MVT::i64);
    SDOperand Tmp = CurDAG->getTargetNode(IA64::ADDL_EA, MVT::i64, 
	                          CurDAG->getRegister(IA64::r1, MVT::i64), EA);
    return CurDAG->getTargetNode(IA64::LD8, MVT::i64, Tmp);
 }
*/

  case ISD::LOAD:
  case ISD::EXTLOAD: // FIXME: load -1, not 1, for bools?
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
      if(N->getValueType(0) == MVT::i1) // XXX: early exit!
        return CurDAG->SelectNodeTo(N, IA64::CMPNE, MVT::i1, MVT::Other, 
                                  CurDAG->getTargetNode(Opc, MVT::i64, Address),
                                  CurDAG->getRegister(IA64::r0, MVT::i64), 
                                  Chain).getValue(Op.ResNo);
      /* otherwise, we want to load a bool into something bigger: LD1
         will do that for us, so we just fall through */
    }
    case MVT::i8:  Opc = IA64::LD1; break;
    case MVT::i16: Opc = IA64::LD2; break;
    case MVT::i32: Opc = IA64::LD4; break;
    case MVT::i64: Opc = IA64::LD8; break;
    
    case MVT::f32: Opc = IA64::LDF4; break;
    case MVT::f64: Opc = IA64::LDF8; break;
    }

    // TODO: comment this
    return CurDAG->SelectNodeTo(N, Opc, N->getValueType(0), MVT::Other,
                                Address, Chain).getValue(Op.ResNo);
  }
  
  case ISD::TRUNCSTORE:
  case ISD::STORE: {
    SDOperand Address = Select(N->getOperand(2));
    SDOperand Chain = Select(N->getOperand(0));
   
    unsigned Opc;
    if (N->getOpcode() == ISD::STORE) {
      switch (N->getOperand(1).getValueType()) {
      default: assert(0 && "unknown type in store");
      case MVT::i1: { // this is a bool
        Opc = IA64::ST1; // we store either 0 or 1 as a byte 
	// first load zero!
	SDOperand Initial = CurDAG->getCopyFromReg(Chain, IA64::r0, MVT::i64);
	Chain = Initial.getValue(1);
	// then load 1 into the same reg iff the predicate to store is 1
        SDOperand Tmp = 
          CurDAG->getTargetNode(IA64::TPCADDS, MVT::i64, Initial,
                                CurDAG->getConstant(1, MVT::i64),
                                Select(N->getOperand(1)));
        return CurDAG->SelectNodeTo(N, Opc, MVT::Other, Address, Tmp, Chain);
      }
      case MVT::i64: Opc = IA64::ST8;  break;
      case MVT::f64: Opc = IA64::STF8; break;
      }
    } else { //ISD::TRUNCSTORE
      switch(cast<VTSDNode>(N->getOperand(4))->getVT()) {
      default: assert(0 && "unknown type in truncstore");
      case MVT::i8:  Opc = IA64::ST1;  break;
      case MVT::i16: Opc = IA64::ST2;  break;
      case MVT::i32: Opc = IA64::ST4;  break;
      case MVT::f32: Opc = IA64::STF4; break;
      }
    }
    
    return CurDAG->SelectNodeTo(N, Opc, MVT::Other, Select(N->getOperand(2)),
                                Select(N->getOperand(1)), Chain);
  }

  case ISD::BRCOND: {
    SDOperand Chain = Select(N->getOperand(0));
    SDOperand CC = Select(N->getOperand(1));
    MachineBasicBlock *Dest =
      cast<BasicBlockSDNode>(N->getOperand(2))->getBasicBlock();
    //FIXME - we do NOT need long branches all the time
    return CurDAG->SelectNodeTo(N, IA64::BRLCOND_NOTCALL, MVT::Other, CC, 
                                CurDAG->getBasicBlock(Dest), Chain);
  }

  case ISD::CALLSEQ_START:
  case ISD::CALLSEQ_END: {
    int64_t Amt = cast<ConstantSDNode>(N->getOperand(1))->getValue();
    unsigned Opc = N->getOpcode() == ISD::CALLSEQ_START ?
                       IA64::ADJUSTCALLSTACKDOWN : IA64::ADJUSTCALLSTACKUP;
    return CurDAG->SelectNodeTo(N, Opc, MVT::Other,
                                getI64Imm(Amt), Select(N->getOperand(0)));
  }

  case ISD::BR:
		 // FIXME: we don't need long branches all the time!
    return CurDAG->SelectNodeTo(N, IA64::BRL_NOTCALL, MVT::Other, 
                                N->getOperand(1), Select(N->getOperand(0)));
  }
  
  return SelectCode(Op);
}


/// createIA64DAGToDAGInstructionSelector - This pass converts a legalized DAG
/// into an IA64-specific DAG, ready for instruction scheduling.
///
FunctionPass *llvm::createIA64DAGToDAGInstructionSelector(TargetMachine &TM) {
  return new IA64DAGToDAGISel(TM);
}

