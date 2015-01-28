//=====-- AMDGPUSubtarget.h - Define Subtarget for the AMDIL ---*- C++ -*-====//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//==-----------------------------------------------------------------------===//
//
/// \file
/// \brief AMDGPU specific subclass of TargetSubtarget.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_R600_AMDGPUSUBTARGET_H
#define LLVM_LIB_TARGET_R600_AMDGPUSUBTARGET_H
#include "AMDGPU.h"
#include "AMDGPUFrameLowering.h"
#include "AMDGPUInstrInfo.h"
#include "AMDGPUIntrinsicInfo.h"
#include "AMDGPUSubtarget.h"
#include "R600ISelLowering.h"
#include "llvm/ADT/StringExtras.h"
#include "llvm/ADT/StringRef.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/Target/TargetSubtargetInfo.h"

#define GET_SUBTARGETINFO_HEADER
#include "AMDGPUGenSubtargetInfo.inc"

namespace llvm {

class SIMachineFunctionInfo;

class AMDGPUSubtarget : public AMDGPUGenSubtargetInfo {

public:
  enum Generation {
    R600 = 0,
    R700,
    EVERGREEN,
    NORTHERN_ISLANDS,
    SOUTHERN_ISLANDS,
    SEA_ISLANDS,
    VOLCANIC_ISLANDS,
  };

private:
  std::string DevName;
  bool Is64bit;
  bool DumpCode;
  bool R600ALUInst;
  bool HasVertexCache;
  short TexVTXClauseSize;
  Generation Gen;
  bool FP64;
  bool FP64Denormals;
  bool FP32Denormals;
  bool CaymanISA;
  bool FlatAddressSpace;
  bool EnableIRStructurizer;
  bool EnablePromoteAlloca;
  bool EnableIfCvt;
  bool EnableLoadStoreOpt;
  unsigned WavefrontSize;
  bool CFALUBug;
  int LocalMemorySize;
  bool EnableVGPRSpilling;

  DataLayout DL;
  AMDGPUFrameLowering FrameLowering;
  std::unique_ptr<AMDGPUTargetLowering> TLInfo;
  std::unique_ptr<AMDGPUInstrInfo> InstrInfo;
  InstrItineraryData InstrItins;
  Triple TargetTriple;

public:
  AMDGPUSubtarget(StringRef TT, StringRef CPU, StringRef FS, TargetMachine &TM);
  AMDGPUSubtarget &initializeSubtargetDependencies(StringRef TT, StringRef GPU,
                                                   StringRef FS);

  // FIXME: This routine needs to go away. See comments in
  // AMDGPUTargetMachine.h.
  const DataLayout *getDataLayout() const { return &DL; }

  const AMDGPUFrameLowering *getFrameLowering() const override {
    return &FrameLowering;
  }
  const AMDGPUInstrInfo *getInstrInfo() const override {
    return InstrInfo.get();
  }
  const AMDGPURegisterInfo *getRegisterInfo() const override {
    return &InstrInfo->getRegisterInfo();
  }
  AMDGPUTargetLowering *getTargetLowering() const override {
    return TLInfo.get();
  }
  const InstrItineraryData *getInstrItineraryData() const override {
    return &InstrItins;
  }

  void ParseSubtargetFeatures(StringRef CPU, StringRef FS);

  bool is64bit() const {
    return Is64bit;
  }

  bool hasVertexCache() const {
    return HasVertexCache;
  }

  short getTexVTXClauseSize() const {
    return TexVTXClauseSize;
  }

  Generation getGeneration() const {
    return Gen;
  }

  bool hasHWFP64() const {
    return FP64;
  }

  bool hasCaymanISA() const {
    return CaymanISA;
  }

  bool hasFP32Denormals() const {
    return FP32Denormals;
  }

  bool hasFP64Denormals() const {
    return FP64Denormals;
  }

  bool hasFlatAddressSpace() const {
    return FlatAddressSpace;
  }

  bool hasBFE() const {
    return (getGeneration() >= EVERGREEN);
  }

  bool hasBFI() const {
    return (getGeneration() >= EVERGREEN);
  }

  bool hasBFM() const {
    return hasBFE();
  }

  bool hasBCNT(unsigned Size) const {
    if (Size == 32)
      return (getGeneration() >= EVERGREEN);

    if (Size == 64)
      return (getGeneration() >= SOUTHERN_ISLANDS);

    return false;
  }

  bool hasMulU24() const {
    return (getGeneration() >= EVERGREEN);
  }

  bool hasMulI24() const {
    return (getGeneration() >= SOUTHERN_ISLANDS ||
            hasCaymanISA());
  }

  bool hasFFBL() const {
    return (getGeneration() >= EVERGREEN);
  }

  bool hasFFBH() const {
    return (getGeneration() >= EVERGREEN);
  }

  bool IsIRStructurizerEnabled() const {
    return EnableIRStructurizer;
  }

  bool isPromoteAllocaEnabled() const {
    return EnablePromoteAlloca;
  }

  bool isIfCvtEnabled() const {
    return EnableIfCvt;
  }

  bool loadStoreOptEnabled() const {
    return EnableLoadStoreOpt;
  }

  unsigned getWavefrontSize() const {
    return WavefrontSize;
  }

  unsigned getStackEntrySize() const;

  bool hasCFAluBug() const {
    assert(getGeneration() <= NORTHERN_ISLANDS);
    return CFALUBug;
  }

  int getLocalMemorySize() const {
    return LocalMemorySize;
  }

  unsigned getAmdKernelCodeChipID() const;

  bool enableMachineScheduler() const override {
    return getGeneration() <= NORTHERN_ISLANDS;
  }

  // Helper functions to simplify if statements
  bool isTargetELF() const {
    return false;
  }

  StringRef getDeviceName() const {
    return DevName;
  }

  bool dumpCode() const {
    return DumpCode;
  }
  bool r600ALUEncoding() const {
    return R600ALUInst;
  }
  bool isAmdHsaOS() const {
    return TargetTriple.getOS() == Triple::AMDHSA;
  }
  bool isVGPRSpillingEnabled(const SIMachineFunctionInfo *MFI) const;
};

} // End namespace llvm

#endif
