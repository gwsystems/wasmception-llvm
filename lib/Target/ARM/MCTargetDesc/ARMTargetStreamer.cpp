//===- ARMTargetStreamer.cpp - ARMTargetStreamer class --*- C++ -*---------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the ARMTargetStreamer class.
//
//===----------------------------------------------------------------------===//

#include "ARMTargetMachine.h"
#include "llvm/MC/ConstantPools.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/Support/ARMBuildAttributes.h"
#include "llvm/Support/TargetParser.h"

using namespace llvm;

//
// ARMTargetStreamer Implemenation
//

ARMTargetStreamer::ARMTargetStreamer(MCStreamer &S)
    : MCTargetStreamer(S), ConstantPools(new AssemblerConstantPools()) {}

ARMTargetStreamer::~ARMTargetStreamer() = default;

// The constant pool handling is shared by all ARMTargetStreamer
// implementations.
const MCExpr *ARMTargetStreamer::addConstantPoolEntry(const MCExpr *Expr, SMLoc Loc) {
  return ConstantPools->addEntry(Streamer, Expr, 4, Loc);
}

void ARMTargetStreamer::emitCurrentConstantPool() {
  ConstantPools->emitForCurrentSection(Streamer);
  ConstantPools->clearCacheForCurrentSection(Streamer);
}

// finish() - write out any non-empty assembler constant pools.
void ARMTargetStreamer::finish() { ConstantPools->emitAll(Streamer); }

// reset() - Reset any state
void ARMTargetStreamer::reset() {}

// The remaining callbacks should be handled separately by each
// streamer.
void ARMTargetStreamer::emitFnStart() {}
void ARMTargetStreamer::emitFnEnd() {}
void ARMTargetStreamer::emitCantUnwind() {}
void ARMTargetStreamer::emitPersonality(const MCSymbol *Personality) {}
void ARMTargetStreamer::emitPersonalityIndex(unsigned Index) {}
void ARMTargetStreamer::emitHandlerData() {}
void ARMTargetStreamer::emitSetFP(unsigned FpReg, unsigned SpReg,
                                  int64_t Offset) {}
void ARMTargetStreamer::emitMovSP(unsigned Reg, int64_t Offset) {}
void ARMTargetStreamer::emitPad(int64_t Offset) {}
void ARMTargetStreamer::emitRegSave(const SmallVectorImpl<unsigned> &RegList,
                                    bool isVector) {}
void ARMTargetStreamer::emitUnwindRaw(int64_t StackOffset,
                                      const SmallVectorImpl<uint8_t> &Opcodes) {
}
void ARMTargetStreamer::switchVendor(StringRef Vendor) {}
void ARMTargetStreamer::emitAttribute(unsigned Attribute, unsigned Value) {}
void ARMTargetStreamer::emitTextAttribute(unsigned Attribute,
                                          StringRef String) {}
void ARMTargetStreamer::emitIntTextAttribute(unsigned Attribute,
                                             unsigned IntValue,
                                             StringRef StringValue) {}
void ARMTargetStreamer::emitArch(ARM::ArchKind Arch) {}
void ARMTargetStreamer::emitArchExtension(unsigned ArchExt) {}
void ARMTargetStreamer::emitObjectArch(ARM::ArchKind Arch) {}
void ARMTargetStreamer::emitFPU(unsigned FPU) {}
void ARMTargetStreamer::finishAttributeSection() {}
void ARMTargetStreamer::emitInst(uint32_t Inst, char Suffix) {}
void
ARMTargetStreamer::AnnotateTLSDescriptorSequence(const MCSymbolRefExpr *SRE) {}
void ARMTargetStreamer::emitThumbSet(MCSymbol *Symbol, const MCExpr *Value) {}

static ARMBuildAttrs::CPUArch getArchForCPU(const MCSubtargetInfo &STI) {
  if (STI.getCPU() == "xscale")
    return ARMBuildAttrs::v5TEJ;

  if (STI.hasFeature(ARM::HasV8Ops)) {
    if (STI.hasFeature(ARM::FeatureRClass))
      return ARMBuildAttrs::v8_R;
    return ARMBuildAttrs::v8_A;
  } else if (STI.hasFeature(ARM::HasV8MMainlineOps))
    return ARMBuildAttrs::v8_M_Main;
  else if (STI.hasFeature(ARM::HasV7Ops)) {
    if (STI.hasFeature(ARM::FeatureMClass) && STI.hasFeature(ARM::FeatureDSP))
      return ARMBuildAttrs::v7E_M;
    return ARMBuildAttrs::v7;
  } else if (STI.hasFeature(ARM::HasV6T2Ops))
    return ARMBuildAttrs::v6T2;
  else if (STI.hasFeature(ARM::HasV8MBaselineOps))
    return ARMBuildAttrs::v8_M_Base;
  else if (STI.hasFeature(ARM::HasV6MOps))
    return ARMBuildAttrs::v6S_M;
  else if (STI.hasFeature(ARM::HasV6Ops))
    return ARMBuildAttrs::v6;
  else if (STI.hasFeature(ARM::HasV5TEOps))
    return ARMBuildAttrs::v5TE;
  else if (STI.hasFeature(ARM::HasV5TOps))
    return ARMBuildAttrs::v5T;
  else if (STI.hasFeature(ARM::HasV4TOps))
    return ARMBuildAttrs::v4T;
  else
    return ARMBuildAttrs::v4;
}

static bool isV8M(const MCSubtargetInfo &STI) {
  // Note that v8M Baseline is a subset of v6T2!
  return (STI.hasFeature(ARM::HasV8MBaselineOps) &&
          !STI.hasFeature(ARM::HasV6T2Ops)) ||
         STI.hasFeature(ARM::HasV8MMainlineOps);
}

/// Emit the build attributes that only depend on the hardware that we expect
// /to be available, and not on the ABI, or any source-language choices.
void ARMTargetStreamer::emitTargetAttributes(const MCSubtargetInfo &STI) {
  switchVendor("aeabi");

  const StringRef CPUString = STI.getCPU();
  if (!CPUString.empty() && !CPUString.startswith("generic")) {
    // FIXME: remove krait check when GNU tools support krait cpu
    if (STI.hasFeature(ARM::ProcKrait)) {
      emitTextAttribute(ARMBuildAttrs::CPU_name, "cortex-a9");
      // We consider krait as a "cortex-a9" + hwdiv CPU
      // Enable hwdiv through ".arch_extension idiv"
      if (STI.hasFeature(ARM::FeatureHWDivThumb) ||
          STI.hasFeature(ARM::FeatureHWDivARM))
        emitArchExtension(ARM::AEK_HWDIVTHUMB | ARM::AEK_HWDIVARM);
    } else {
      emitTextAttribute(ARMBuildAttrs::CPU_name, CPUString);
    }
  }

  emitAttribute(ARMBuildAttrs::CPU_arch, getArchForCPU(STI));

  if (STI.hasFeature(ARM::FeatureAClass)) {
    emitAttribute(ARMBuildAttrs::CPU_arch_profile,
                      ARMBuildAttrs::ApplicationProfile);
  } else if (STI.hasFeature(ARM::FeatureRClass)) {
    emitAttribute(ARMBuildAttrs::CPU_arch_profile,
                      ARMBuildAttrs::RealTimeProfile);
  } else if (STI.hasFeature(ARM::FeatureMClass)) {
    emitAttribute(ARMBuildAttrs::CPU_arch_profile,
                      ARMBuildAttrs::MicroControllerProfile);
  }

  emitAttribute(ARMBuildAttrs::ARM_ISA_use, STI.hasFeature(ARM::FeatureNoARM)
                                                ? ARMBuildAttrs::Not_Allowed
                                                : ARMBuildAttrs::Allowed);

  if (isV8M(STI)) {
    emitAttribute(ARMBuildAttrs::THUMB_ISA_use,
                      ARMBuildAttrs::AllowThumbDerived);
  } else if (STI.hasFeature(ARM::FeatureThumb2)) {
    emitAttribute(ARMBuildAttrs::THUMB_ISA_use,
                      ARMBuildAttrs::AllowThumb32);
  } else if (STI.hasFeature(ARM::HasV4TOps)) {
    emitAttribute(ARMBuildAttrs::THUMB_ISA_use, ARMBuildAttrs::Allowed);
  }

  if (STI.hasFeature(ARM::FeatureNEON)) {
    /* NEON is not exactly a VFP architecture, but GAS emit one of
     * neon/neon-fp-armv8/neon-vfpv4/vfpv3/vfpv2 for .fpu parameters */
    if (STI.hasFeature(ARM::FeatureFPARMv8)) {
      if (STI.hasFeature(ARM::FeatureCrypto))
        emitFPU(ARM::FK_CRYPTO_NEON_FP_ARMV8);
      else
        emitFPU(ARM::FK_NEON_FP_ARMV8);
    } else if (STI.hasFeature(ARM::FeatureVFP4))
      emitFPU(ARM::FK_NEON_VFPV4);
    else
      emitFPU(STI.hasFeature(ARM::FeatureFP16) ? ARM::FK_NEON_FP16
                                               : ARM::FK_NEON);
    // Emit Tag_Advanced_SIMD_arch for ARMv8 architecture
    if (STI.hasFeature(ARM::HasV8Ops))
      emitAttribute(ARMBuildAttrs::Advanced_SIMD_arch,
                    STI.hasFeature(ARM::HasV8_1aOps)
                        ? ARMBuildAttrs::AllowNeonARMv8_1a
                        : ARMBuildAttrs::AllowNeonARMv8);
  } else {
    if (STI.hasFeature(ARM::FeatureFPARMv8))
      // FPv5 and FP-ARMv8 have the same instructions, so are modeled as one
      // FPU, but there are two different names for it depending on the CPU.
      emitFPU(STI.hasFeature(ARM::FeatureD16)
                  ? (STI.hasFeature(ARM::FeatureVFPOnlySP) ? ARM::FK_FPV5_SP_D16
                                                           : ARM::FK_FPV5_D16)
                  : ARM::FK_FP_ARMV8);
    else if (STI.hasFeature(ARM::FeatureVFP4))
      emitFPU(STI.hasFeature(ARM::FeatureD16)
                  ? (STI.hasFeature(ARM::FeatureVFPOnlySP) ? ARM::FK_FPV4_SP_D16
                                                           : ARM::FK_VFPV4_D16)
                  : ARM::FK_VFPV4);
    else if (STI.hasFeature(ARM::FeatureVFP3))
      emitFPU(
          STI.hasFeature(ARM::FeatureD16)
              // +d16
              ? (STI.hasFeature(ARM::FeatureVFPOnlySP)
                     ? (STI.hasFeature(ARM::FeatureFP16) ? ARM::FK_VFPV3XD_FP16
                                                         : ARM::FK_VFPV3XD)
                     : (STI.hasFeature(ARM::FeatureFP16)
                            ? ARM::FK_VFPV3_D16_FP16
                            : ARM::FK_VFPV3_D16))
              // -d16
              : (STI.hasFeature(ARM::FeatureFP16) ? ARM::FK_VFPV3_FP16
                                                  : ARM::FK_VFPV3));
    else if (STI.hasFeature(ARM::FeatureVFP2))
      emitFPU(ARM::FK_VFPV2);
  }

  // ABI_HardFP_use attribute to indicate single precision FP.
  if (STI.hasFeature(ARM::FeatureVFPOnlySP))
    emitAttribute(ARMBuildAttrs::ABI_HardFP_use,
                  ARMBuildAttrs::HardFPSinglePrecision);

  if (STI.hasFeature(ARM::FeatureFP16))
    emitAttribute(ARMBuildAttrs::FP_HP_extension, ARMBuildAttrs::AllowHPFP);

  if (STI.hasFeature(ARM::FeatureMP))
    emitAttribute(ARMBuildAttrs::MPextension_use, ARMBuildAttrs::AllowMP);

  // Hardware divide in ARM mode is part of base arch, starting from ARMv8.
  // If only Thumb hwdiv is present, it must also be in base arch (ARMv7-R/M).
  // It is not possible to produce DisallowDIV: if hwdiv is present in the base
  // arch, supplying -hwdiv downgrades the effective arch, via ClearImpliedBits.
  // AllowDIVExt is only emitted if hwdiv isn't available in the base arch;
  // otherwise, the default value (AllowDIVIfExists) applies.
  if (STI.hasFeature(ARM::FeatureHWDivARM) && !STI.hasFeature(ARM::HasV8Ops))
    emitAttribute(ARMBuildAttrs::DIV_use, ARMBuildAttrs::AllowDIVExt);

  if (STI.hasFeature(ARM::FeatureDSP) && isV8M(STI))
    emitAttribute(ARMBuildAttrs::DSP_extension, ARMBuildAttrs::Allowed);

  if (STI.hasFeature(ARM::FeatureStrictAlign))
    emitAttribute(ARMBuildAttrs::CPU_unaligned_access,
                  ARMBuildAttrs::Not_Allowed);
  else
    emitAttribute(ARMBuildAttrs::CPU_unaligned_access,
                  ARMBuildAttrs::Allowed);

  if (STI.hasFeature(ARM::FeatureTrustZone) &&
      STI.hasFeature(ARM::FeatureVirtualization))
    emitAttribute(ARMBuildAttrs::Virtualization_use,
                  ARMBuildAttrs::AllowTZVirtualization);
  else if (STI.hasFeature(ARM::FeatureTrustZone))
    emitAttribute(ARMBuildAttrs::Virtualization_use, ARMBuildAttrs::AllowTZ);
  else if (STI.hasFeature(ARM::FeatureVirtualization))
    emitAttribute(ARMBuildAttrs::Virtualization_use,
                  ARMBuildAttrs::AllowVirtualization);
}
