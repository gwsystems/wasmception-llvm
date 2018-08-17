//===-- llvm/lib/CodeGen/AsmPrinter/DebugHandlerBase.cpp -------*- C++ -*--===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// Common functionality for different debug information format backends.
// LLVM currently supports DWARF and CodeView.
//
//===----------------------------------------------------------------------===//

#include "DebugHandlerBase.h"
#include "llvm/ADT/Optional.h"
#include "llvm/ADT/Twine.h"
#include "llvm/CodeGen/AsmPrinter.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/CodeGen/MachineModuleInfo.h"
#include "llvm/CodeGen/TargetSubtargetInfo.h"
#include "llvm/IR/DebugInfo.h"
#include "llvm/MC/MCStreamer.h"

using namespace llvm;

#define DEBUG_TYPE "dwarfdebug"

Optional<DbgVariableLocation>
DbgVariableLocation::extractFromMachineInstruction(
    const MachineInstr &Instruction) {
  DbgVariableLocation Location;
  if (!Instruction.isDebugValue())
    return None;
  if (!Instruction.getOperand(0).isReg())
    return None;
  Location.Register = Instruction.getOperand(0).getReg();
  Location.FragmentInfo.reset();
  // We only handle expressions generated by DIExpression::appendOffset,
  // which doesn't require a full stack machine.
  int64_t Offset = 0;
  const DIExpression *DIExpr = Instruction.getDebugExpression();
  auto Op = DIExpr->expr_op_begin();
  while (Op != DIExpr->expr_op_end()) {
    switch (Op->getOp()) {
    case dwarf::DW_OP_constu: {
      int Value = Op->getArg(0);
      ++Op;
      if (Op != DIExpr->expr_op_end()) {
        switch (Op->getOp()) {
        case dwarf::DW_OP_minus:
          Offset -= Value;
          break;
        case dwarf::DW_OP_plus:
          Offset += Value;
          break;
        default:
          continue;
        }
      }
    } break;
    case dwarf::DW_OP_plus_uconst:
      Offset += Op->getArg(0);
      break;
    case dwarf::DW_OP_LLVM_fragment:
      Location.FragmentInfo = {Op->getArg(1), Op->getArg(0)};
      break;
    case dwarf::DW_OP_deref:
      Location.LoadChain.push_back(Offset);
      Offset = 0;
      break;
    default:
      return None;
    }
    ++Op;
  }

  // Do one final implicit DW_OP_deref if this was an indirect DBG_VALUE
  // instruction.
  // FIXME: Replace these with DIExpression.
  if (Instruction.isIndirectDebugValue())
    Location.LoadChain.push_back(Offset);

  return Location;
}

DebugHandlerBase::DebugHandlerBase(AsmPrinter *A) : Asm(A), MMI(Asm->MMI) {}

// Each LexicalScope has first instruction and last instruction to mark
// beginning and end of a scope respectively. Create an inverse map that list
// scopes starts (and ends) with an instruction. One instruction may start (or
// end) multiple scopes. Ignore scopes that are not reachable.
void DebugHandlerBase::identifyScopeMarkers() {
  SmallVector<LexicalScope *, 4> WorkList;
  WorkList.push_back(LScopes.getCurrentFunctionScope());
  while (!WorkList.empty()) {
    LexicalScope *S = WorkList.pop_back_val();

    const SmallVectorImpl<LexicalScope *> &Children = S->getChildren();
    if (!Children.empty())
      WorkList.append(Children.begin(), Children.end());

    if (S->isAbstractScope())
      continue;

    for (const InsnRange &R : S->getRanges()) {
      assert(R.first && "InsnRange does not have first instruction!");
      assert(R.second && "InsnRange does not have second instruction!");
      requestLabelBeforeInsn(R.first);
      requestLabelAfterInsn(R.second);
    }
  }
}

// Return Label preceding the instruction.
MCSymbol *DebugHandlerBase::getLabelBeforeInsn(const MachineInstr *MI) {
  MCSymbol *Label = LabelsBeforeInsn.lookup(MI);
  assert(Label && "Didn't insert label before instruction");
  return Label;
}

// Return Label immediately following the instruction.
MCSymbol *DebugHandlerBase::getLabelAfterInsn(const MachineInstr *MI) {
  return LabelsAfterInsn.lookup(MI);
}

/// If this type is derived from a base type then return base type size.
uint64_t DebugHandlerBase::getBaseTypeSize(const DITypeRef TyRef) {
  DIType *Ty = TyRef.resolve();
  assert(Ty);
  DIDerivedType *DDTy = dyn_cast<DIDerivedType>(Ty);
  if (!DDTy)
    return Ty->getSizeInBits();

  unsigned Tag = DDTy->getTag();

  if (Tag != dwarf::DW_TAG_member && Tag != dwarf::DW_TAG_typedef &&
      Tag != dwarf::DW_TAG_const_type && Tag != dwarf::DW_TAG_volatile_type &&
      Tag != dwarf::DW_TAG_restrict_type && Tag != dwarf::DW_TAG_atomic_type)
    return DDTy->getSizeInBits();

  DIType *BaseType = DDTy->getBaseType().resolve();

  if (!BaseType)
    return 0;

  // If this is a derived type, go ahead and get the base type, unless it's a
  // reference then it's just the size of the field. Pointer types have no need
  // of this since they're a different type of qualification on the type.
  if (BaseType->getTag() == dwarf::DW_TAG_reference_type ||
      BaseType->getTag() == dwarf::DW_TAG_rvalue_reference_type)
    return Ty->getSizeInBits();

  return getBaseTypeSize(BaseType);
}

static bool hasDebugInfo(const MachineModuleInfo *MMI,
                         const MachineFunction *MF) {
  if (!MMI->hasDebugInfo())
    return false;
  auto *SP = MF->getFunction().getSubprogram();
  if (!SP)
    return false;
  assert(SP->getUnit());
  auto EK = SP->getUnit()->getEmissionKind();
  if (EK == DICompileUnit::NoDebug)
    return false;
  return true;
}

void DebugHandlerBase::beginFunction(const MachineFunction *MF) {
  PrevInstBB = nullptr;

  if (!Asm || !hasDebugInfo(MMI, MF)) {
    skippedNonDebugFunction();
    return;
  }

  // Grab the lexical scopes for the function, if we don't have any of those
  // then we're not going to be able to do anything.
  LScopes.initialize(*MF);
  if (LScopes.empty()) {
    beginFunctionImpl(MF);
    return;
  }

  // Make sure that each lexical scope will have a begin/end label.
  identifyScopeMarkers();

  // Calculate history for local variables.
  assert(DbgValues.empty() && "DbgValues map wasn't cleaned!");
  assert(DbgLabels.empty() && "DbgLabels map wasn't cleaned!");
  calculateDbgEntityHistory(MF, Asm->MF->getSubtarget().getRegisterInfo(),
                            DbgValues, DbgLabels);
  LLVM_DEBUG(DbgValues.dump());

  // Request labels for the full history.
  for (const auto &I : DbgValues) {
    const auto &Ranges = I.second;
    if (Ranges.empty())
      continue;

    // The first mention of a function argument gets the CurrentFnBegin
    // label, so arguments are visible when breaking at function entry.
    const DILocalVariable *DIVar = Ranges.front().first->getDebugVariable();
    if (DIVar->isParameter() &&
        getDISubprogram(DIVar->getScope())->describes(&MF->getFunction())) {
      LabelsBeforeInsn[Ranges.front().first] = Asm->getFunctionBegin();
      if (Ranges.front().first->getDebugExpression()->isFragment()) {
        // Mark all non-overlapping initial fragments.
        for (auto I = Ranges.begin(); I != Ranges.end(); ++I) {
          const DIExpression *Fragment = I->first->getDebugExpression();
          if (std::all_of(Ranges.begin(), I,
                          [&](DbgValueHistoryMap::InstrRange Pred) {
                            return !Fragment->fragmentsOverlap(
                                Pred.first->getDebugExpression());
                          }))
            LabelsBeforeInsn[I->first] = Asm->getFunctionBegin();
          else
            break;
        }
      }
    }

    for (const auto &Range : Ranges) {
      requestLabelBeforeInsn(Range.first);
      if (Range.second)
        requestLabelAfterInsn(Range.second);
    }
  }

  // Ensure there is a symbol before DBG_LABEL.
  for (const auto &I : DbgLabels) {
    const MachineInstr *MI = I.second;
    requestLabelBeforeInsn(MI);
  }

  PrevInstLoc = DebugLoc();
  PrevLabel = Asm->getFunctionBegin();
  beginFunctionImpl(MF);
}

void DebugHandlerBase::beginInstruction(const MachineInstr *MI) {
  if (!MMI->hasDebugInfo())
    return;

  assert(CurMI == nullptr);
  CurMI = MI;

  // Insert labels where requested.
  DenseMap<const MachineInstr *, MCSymbol *>::iterator I =
      LabelsBeforeInsn.find(MI);

  // No label needed.
  if (I == LabelsBeforeInsn.end())
    return;

  // Label already assigned.
  if (I->second)
    return;

  if (!PrevLabel) {
    PrevLabel = MMI->getContext().createTempSymbol();
    Asm->OutStreamer->EmitLabel(PrevLabel);
  }
  I->second = PrevLabel;
}

void DebugHandlerBase::endInstruction() {
  if (!MMI->hasDebugInfo())
    return;

  assert(CurMI != nullptr);
  // Don't create a new label after DBG_VALUE and other instructions that don't
  // generate code.
  if (!CurMI->isMetaInstruction()) {
    PrevLabel = nullptr;
    PrevInstBB = CurMI->getParent();
  }

  DenseMap<const MachineInstr *, MCSymbol *>::iterator I =
      LabelsAfterInsn.find(CurMI);
  CurMI = nullptr;

  // No label needed.
  if (I == LabelsAfterInsn.end())
    return;

  // Label already assigned.
  if (I->second)
    return;

  // We need a label after this instruction.
  if (!PrevLabel) {
    PrevLabel = MMI->getContext().createTempSymbol();
    Asm->OutStreamer->EmitLabel(PrevLabel);
  }
  I->second = PrevLabel;
}

void DebugHandlerBase::endFunction(const MachineFunction *MF) {
  if (hasDebugInfo(MMI, MF))
    endFunctionImpl(MF);
  DbgValues.clear();
  DbgLabels.clear();
  LabelsBeforeInsn.clear();
  LabelsAfterInsn.clear();
}
