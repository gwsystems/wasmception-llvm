//===-- llvm/CodeGen/SelectionDAGISel.h - Common Base Class------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the SelectionDAGISel class, which is used as the common
// base class for SelectionDAG-based instruction selectors.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_CODEGEN_SELECTIONDAG_ISEL_H
#define LLVM_CODEGEN_SELECTIONDAG_ISEL_H

#include "llvm/BasicBlock.h"
#include "llvm/Pass.h"
#include "llvm/Constant.h"
#include "llvm/CodeGen/SelectionDAG.h"
#include "llvm/CodeGen/MachineFunctionPass.h"

namespace llvm {
  class FastISel;
  class SelectionDAGLowering;
  class SDValue;
  class MachineRegisterInfo;
  class MachineBasicBlock;
  class MachineFunction;
  class MachineInstr;
  class MachineModuleInfo;
  class DwarfWriter;
  class TargetLowering;
  class TargetInstrInfo;
  class FunctionLoweringInfo;
  class ScheduleHazardRecognizer;
  class GCFunctionInfo;
  class ScheduleDAGSDNodes;
 
/// SelectionDAGISel - This is the common base class used for SelectionDAG-based
/// pattern-matching instruction selectors.
class SelectionDAGISel : public MachineFunctionPass {
public:
  const TargetMachine &TM;
  TargetLowering &TLI;
  FunctionLoweringInfo *FuncInfo;
  MachineFunction *MF;
  MachineRegisterInfo *RegInfo;
  SelectionDAG *CurDAG;
  SelectionDAGLowering *SDL;
  MachineBasicBlock *BB;
  AliasAnalysis *AA;
  GCFunctionInfo *GFI;
  CodeGenOpt::Level OptLevel;
  static char ID;

  explicit SelectionDAGISel(TargetMachine &tm,
                            CodeGenOpt::Level OL = CodeGenOpt::Default);
  virtual ~SelectionDAGISel();
  
  TargetLowering &getTargetLowering() { return TLI; }

  virtual void getAnalysisUsage(AnalysisUsage &AU) const;

  virtual bool runOnMachineFunction(MachineFunction &MF);

  unsigned MakeReg(EVT VT);

  virtual void EmitFunctionEntryCode(Function &Fn, MachineFunction &MF) {}
  virtual void InstructionSelect() = 0;
  
  void SelectRootInit() {
    DAGSize = CurDAG->AssignTopologicalOrder();
  }

  /// SelectInlineAsmMemoryOperand - Select the specified address as a target
  /// addressing mode, according to the specified constraint code.  If this does
  /// not match or is not implemented, return true.  The resultant operands
  /// (which will appear in the machine instruction) should be added to the
  /// OutOps vector.
  virtual bool SelectInlineAsmMemoryOperand(const SDValue &Op,
                                            char ConstraintCode,
                                            std::vector<SDValue> &OutOps) {
    return true;
  }

  /// IsLegalAndProfitableToFold - Returns true if the specific operand node N of
  /// U can be folded during instruction selection that starts at Root and
  /// folding N is profitable.
  virtual
  bool IsLegalAndProfitableToFold(SDNode *N, SDNode *U, SDNode *Root) const;

  /// CreateTargetHazardRecognizer - Return a newly allocated hazard recognizer
  /// to use for this target when scheduling the DAG.
  virtual ScheduleHazardRecognizer *CreateTargetHazardRecognizer();
  
protected:
  /// DAGSize - Size of DAG being instruction selected.
  ///
  unsigned DAGSize;

  /// SelectInlineAsmMemoryOperands - Calls to this are automatically generated
  /// by tblgen.  Others should not call it.
  void SelectInlineAsmMemoryOperands(std::vector<SDValue> &Ops);

  // Calls to these predicates are generated by tblgen.
  bool CheckAndMask(SDValue LHS, ConstantSDNode *RHS,
                    int64_t DesiredMaskS) const;
  bool CheckOrMask(SDValue LHS, ConstantSDNode *RHS,
                    int64_t DesiredMaskS) const;
  
  // Calls to these functions are generated by tblgen.
  SDNode *Select_INLINEASM(SDValue N);
  SDNode *Select_UNDEF(const SDValue &N);
  SDNode *Select_DBG_LABEL(const SDValue &N);
  SDNode *Select_EH_LABEL(const SDValue &N);
  void CannotYetSelect(SDValue N);
  void CannotYetSelectIntrinsic(SDValue N);

private:
  void SelectAllBasicBlocks(Function &Fn, MachineFunction &MF,
                            MachineModuleInfo *MMI,
                            DwarfWriter *DW,
                            const TargetInstrInfo &TII);
  void FinishBasicBlock();

  void SelectBasicBlock(BasicBlock *LLVMBB,
                        BasicBlock::iterator Begin,
                        BasicBlock::iterator End,
                        bool &HadTailCall);
  void CodeGenAndEmitDAG();
  void LowerArguments(BasicBlock *BB);
  
  void ComputeLiveOutVRegInfo();

  void HandlePHINodesInSuccessorBlocks(BasicBlock *LLVMBB);

  bool HandlePHINodesInSuccessorBlocksFast(BasicBlock *LLVMBB, FastISel *F);

  /// Create the scheduler. If a specific scheduler was specified
  /// via the SchedulerRegistry, use it, otherwise select the
  /// one preferred by the target.
  ///
  ScheduleDAGSDNodes *CreateScheduler();
};

}

#endif /* LLVM_CODEGEN_SELECTIONDAG_ISEL_H */
