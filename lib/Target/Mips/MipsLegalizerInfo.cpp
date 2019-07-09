//===- MipsLegalizerInfo.cpp ------------------------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
/// \file
/// This file implements the targeting of the Machinelegalizer class for Mips.
/// \todo This should be generated by TableGen.
//===----------------------------------------------------------------------===//

#include "MipsLegalizerInfo.h"
#include "MipsTargetMachine.h"
#include "llvm/CodeGen/GlobalISel/LegalizerHelper.h"

using namespace llvm;

MipsLegalizerInfo::MipsLegalizerInfo(const MipsSubtarget &ST) {
  using namespace TargetOpcode;

  const LLT s1 = LLT::scalar(1);
  const LLT s32 = LLT::scalar(32);
  const LLT s64 = LLT::scalar(64);
  const LLT p0 = LLT::pointer(0, 32);

  getActionDefinitionsBuilder({G_ADD, G_SUB, G_MUL})
      .legalFor({s32})
      .clampScalar(0, s32, s32);

  getActionDefinitionsBuilder({G_UADDO, G_UADDE, G_USUBO, G_USUBE, G_UMULO})
      .lowerFor({{s32, s1}});

  getActionDefinitionsBuilder(G_UMULH)
      .legalFor({s32})
      .maxScalar(0, s32);

  getActionDefinitionsBuilder({G_LOAD, G_STORE})
      .legalForTypesWithMemDesc({{s32, p0, 8, 8},
                                 {s32, p0, 16, 8},
                                 {s32, p0, 32, 8},
                                 {s64, p0, 64, 8},
                                 {p0, p0, 32, 8}})
      .minScalar(0, s32);

  getActionDefinitionsBuilder(G_UNMERGE_VALUES)
     .legalFor({{s32, s64}});

  getActionDefinitionsBuilder(G_MERGE_VALUES)
     .legalFor({{s64, s32}});

  getActionDefinitionsBuilder({G_ZEXTLOAD, G_SEXTLOAD})
    .legalForTypesWithMemDesc({{s32, p0, 8, 8},
                               {s32, p0, 16, 8}})
      .minScalar(0, s32);

  getActionDefinitionsBuilder(G_SELECT)
      .legalForCartesianProduct({p0, s32, s64}, {s32})
      .minScalar(0, s32)
      .minScalar(1, s32);

  getActionDefinitionsBuilder(G_BRCOND)
      .legalFor({s32})
      .minScalar(0, s32);

  getActionDefinitionsBuilder(G_PHI)
      .legalFor({p0, s32, s64})
      .minScalar(0, s32);

  getActionDefinitionsBuilder({G_AND, G_OR, G_XOR})
      .legalFor({s32})
      .clampScalar(0, s32, s32);

  getActionDefinitionsBuilder({G_SDIV, G_SREM, G_UREM, G_UDIV})
      .legalFor({s32})
      .minScalar(0, s32)
      .libcallFor({s64});

  getActionDefinitionsBuilder({G_SHL, G_ASHR, G_LSHR})
    .legalFor({s32, s32})
    .minScalar(1, s32);

  getActionDefinitionsBuilder(G_ICMP)
      .legalFor({{s32, s32}})
      .minScalar(0, s32);

  getActionDefinitionsBuilder(G_CONSTANT)
      .legalFor({s32})
      .clampScalar(0, s32, s32);

  getActionDefinitionsBuilder(G_GEP)
      .legalFor({{p0, s32}});

  getActionDefinitionsBuilder(G_FRAME_INDEX)
      .legalFor({p0});

  getActionDefinitionsBuilder(G_GLOBAL_VALUE)
      .legalFor({p0});

  // FP instructions
  getActionDefinitionsBuilder(G_FCONSTANT)
      .legalFor({s32, s64});

  getActionDefinitionsBuilder({G_FADD, G_FSUB, G_FMUL, G_FDIV, G_FABS, G_FSQRT})
      .legalFor({s32, s64});

  getActionDefinitionsBuilder(G_FCMP)
      .legalFor({{s32, s32}, {s32, s64}})
      .minScalar(0, s32);

  getActionDefinitionsBuilder({G_FCEIL, G_FFLOOR})
      .libcallFor({s32, s64});

  getActionDefinitionsBuilder(G_FPEXT)
      .legalFor({{s64, s32}});

  getActionDefinitionsBuilder(G_FPTRUNC)
      .legalFor({{s32, s64}});

  // FP to int conversion instructions
  getActionDefinitionsBuilder(G_FPTOSI)
      .legalForCartesianProduct({s32}, {s64, s32})
      .libcallForCartesianProduct({s64}, {s64, s32})
      .minScalar(0, s32);

  getActionDefinitionsBuilder(G_FPTOUI)
      .libcallForCartesianProduct({s64}, {s64, s32})
      .minScalar(0, s32);

  // Int to FP conversion instructions
  getActionDefinitionsBuilder(G_SITOFP)
      .legalForCartesianProduct({s64, s32}, {s32})
      .libcallForCartesianProduct({s64, s32}, {s64})
      .minScalar(1, s32);

  getActionDefinitionsBuilder(G_UITOFP)
      .libcallForCartesianProduct({s64, s32}, {s64})
      .minScalar(1, s32);

  computeTables();
  verify(*ST.getInstrInfo());
}

bool MipsLegalizerInfo::legalizeCustom(MachineInstr &MI,
                                       MachineRegisterInfo &MRI,
                                       MachineIRBuilder &MIRBuilder,
                                       GISelChangeObserver &Observer) const {

  using namespace TargetOpcode;

  MIRBuilder.setInstr(MI);

  return false;
}
