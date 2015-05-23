//===-- CommandFlags.h - Command Line Flags Interface -----------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains codegen-specific flags that are shared between different
// command line tools. The tools "llc" and "opt" both use this file to prevent
// flag duplication.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_CODEGEN_COMMANDFLAGS_H
#define LLVM_CODEGEN_COMMANDFLAGS_H

#include "llvm/IR/Module.h"
#include "llvm/MC/MCTargetOptionsCommandFlags.h"
#include "llvm//MC/SubtargetFeature.h"
#include "llvm/Support/CodeGen.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Host.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/Target/TargetOptions.h"
#include <string>
using namespace llvm;

cl::opt<std::string>
MArch("march", cl::desc("Architecture to generate code for (see --version)"));

cl::opt<std::string>
MCPU("mcpu",
     cl::desc("Target a specific cpu type (-mcpu=help for details)"),
     cl::value_desc("cpu-name"),
     cl::init(""));

cl::list<std::string>
MAttrs("mattr",
       cl::CommaSeparated,
       cl::desc("Target specific attributes (-mattr=help for details)"),
       cl::value_desc("a1,+a2,-a3,..."));

cl::opt<Reloc::Model>
RelocModel("relocation-model",
           cl::desc("Choose relocation model"),
           cl::init(Reloc::Default),
           cl::values(
              clEnumValN(Reloc::Default, "default",
                      "Target default relocation model"),
              clEnumValN(Reloc::Static, "static",
                      "Non-relocatable code"),
              clEnumValN(Reloc::PIC_, "pic",
                      "Fully relocatable, position independent code"),
              clEnumValN(Reloc::DynamicNoPIC, "dynamic-no-pic",
                      "Relocatable external references, non-relocatable code"),
              clEnumValEnd));

cl::opt<ThreadModel::Model>
TMModel("thread-model",
        cl::desc("Choose threading model"),
        cl::init(ThreadModel::POSIX),
        cl::values(clEnumValN(ThreadModel::POSIX, "posix",
                              "POSIX thread model"),
                   clEnumValN(ThreadModel::Single, "single",
                              "Single thread model"),
                   clEnumValEnd));

cl::opt<llvm::CodeModel::Model>
CMModel("code-model",
        cl::desc("Choose code model"),
        cl::init(CodeModel::Default),
        cl::values(clEnumValN(CodeModel::Default, "default",
                              "Target default code model"),
                   clEnumValN(CodeModel::Small, "small",
                              "Small code model"),
                   clEnumValN(CodeModel::Kernel, "kernel",
                              "Kernel code model"),
                   clEnumValN(CodeModel::Medium, "medium",
                              "Medium code model"),
                   clEnumValN(CodeModel::Large, "large",
                              "Large code model"),
                   clEnumValEnd));

cl::opt<TargetMachine::CodeGenFileType>
FileType("filetype", cl::init(TargetMachine::CGFT_AssemblyFile),
  cl::desc("Choose a file type (not all types are supported by all targets):"),
  cl::values(
             clEnumValN(TargetMachine::CGFT_AssemblyFile, "asm",
                        "Emit an assembly ('.s') file"),
             clEnumValN(TargetMachine::CGFT_ObjectFile, "obj",
                        "Emit a native object ('.o') file"),
             clEnumValN(TargetMachine::CGFT_Null, "null",
                        "Emit nothing, for performance testing"),
             clEnumValEnd));

cl::opt<bool>
EnableFPMAD("enable-fp-mad",
            cl::desc("Enable less precise MAD instructions to be generated"),
            cl::init(false));

cl::opt<bool>
DisableFPElim("disable-fp-elim",
              cl::desc("Disable frame pointer elimination optimization"),
              cl::init(false));

cl::opt<bool>
EnableUnsafeFPMath("enable-unsafe-fp-math",
                cl::desc("Enable optimizations that may decrease FP precision"),
                cl::init(false));

cl::opt<bool>
EnableNoInfsFPMath("enable-no-infs-fp-math",
                cl::desc("Enable FP math optimizations that assume no +-Infs"),
                cl::init(false));

cl::opt<bool>
EnableNoNaNsFPMath("enable-no-nans-fp-math",
                   cl::desc("Enable FP math optimizations that assume no NaNs"),
                   cl::init(false));

cl::opt<bool>
EnableHonorSignDependentRoundingFPMath("enable-sign-dependent-rounding-fp-math",
      cl::Hidden,
      cl::desc("Force codegen to assume rounding mode can change dynamically"),
      cl::init(false));

cl::opt<llvm::FloatABI::ABIType>
FloatABIForCalls("float-abi",
                 cl::desc("Choose float ABI type"),
                 cl::init(FloatABI::Default),
                 cl::values(
                     clEnumValN(FloatABI::Default, "default",
                                "Target default float ABI type"),
                     clEnumValN(FloatABI::Soft, "soft",
                                "Soft float ABI (implied by -soft-float)"),
                     clEnumValN(FloatABI::Hard, "hard",
                                "Hard float ABI (uses FP registers)"),
                     clEnumValEnd));

cl::opt<llvm::FPOpFusion::FPOpFusionMode>
FuseFPOps("fp-contract",
          cl::desc("Enable aggressive formation of fused FP ops"),
          cl::init(FPOpFusion::Standard),
          cl::values(
              clEnumValN(FPOpFusion::Fast, "fast",
                         "Fuse FP ops whenever profitable"),
              clEnumValN(FPOpFusion::Standard, "on",
                         "Only fuse 'blessed' FP ops."),
              clEnumValN(FPOpFusion::Strict, "off",
                         "Only fuse FP ops when the result won't be effected."),
              clEnumValEnd));

cl::opt<bool>
DontPlaceZerosInBSS("nozero-initialized-in-bss",
              cl::desc("Don't place zero-initialized symbols into bss section"),
              cl::init(false));

cl::opt<bool>
EnableGuaranteedTailCallOpt("tailcallopt",
  cl::desc("Turn fastcc calls into tail calls by (potentially) changing ABI."),
  cl::init(false));

cl::opt<bool>
DisableTailCalls("disable-tail-calls",
                 cl::desc("Never emit tail calls"),
                 cl::init(false));

cl::opt<unsigned>
OverrideStackAlignment("stack-alignment",
                       cl::desc("Override default stack alignment"),
                       cl::init(0));

cl::opt<std::string>
TrapFuncName("trap-func", cl::Hidden,
        cl::desc("Emit a call to trap function rather than a trap instruction"),
        cl::init(""));

cl::opt<bool>
EnablePIE("enable-pie",
          cl::desc("Assume the creation of a position independent executable."),
          cl::init(false));

cl::opt<bool>
UseCtors("use-ctors",
             cl::desc("Use .ctors instead of .init_array."),
             cl::init(false));

cl::opt<std::string> StopAfter("stop-after",
                            cl::desc("Stop compilation after a specific pass"),
                            cl::value_desc("pass-name"),
                                      cl::init(""));
cl::opt<std::string> StartAfter("start-after",
                          cl::desc("Resume compilation after a specific pass"),
                          cl::value_desc("pass-name"),
                          cl::init(""));

cl::opt<bool> DataSections("data-sections",
                           cl::desc("Emit data into separate sections"),
                           cl::init(false));

cl::opt<bool>
FunctionSections("function-sections",
                 cl::desc("Emit functions into separate sections"),
                 cl::init(false));

cl::opt<bool> UniqueSectionNames("unique-section-names",
                                 cl::desc("Give unique names to every section"),
                                 cl::init(true));

cl::opt<llvm::JumpTable::JumpTableType>
JTableType("jump-table-type",
          cl::desc("Choose the type of Jump-Instruction Table for jumptable."),
          cl::init(JumpTable::Single),
          cl::values(
              clEnumValN(JumpTable::Single, "single",
                         "Create a single table for all jumptable functions"),
              clEnumValN(JumpTable::Arity, "arity",
                         "Create one table per number of parameters."),
              clEnumValN(JumpTable::Simplified, "simplified",
                         "Create one table per simplified function type."),
              clEnumValN(JumpTable::Full, "full",
                         "Create one table per unique function type."),
              clEnumValEnd));

// Common utility function tightly tied to the options listed here. Initializes
// a TargetOptions object with CodeGen flags and returns it.
static inline TargetOptions InitTargetOptionsFromCodeGenFlags() {
  TargetOptions Options;
  Options.LessPreciseFPMADOption = EnableFPMAD;
  Options.NoFramePointerElim = DisableFPElim;
  Options.AllowFPOpFusion = FuseFPOps;
  Options.UnsafeFPMath = EnableUnsafeFPMath;
  Options.NoInfsFPMath = EnableNoInfsFPMath;
  Options.NoNaNsFPMath = EnableNoNaNsFPMath;
  Options.HonorSignDependentRoundingFPMathOption =
      EnableHonorSignDependentRoundingFPMath;
  if (FloatABIForCalls != FloatABI::Default)
    Options.FloatABIType = FloatABIForCalls;
  Options.NoZerosInBSS = DontPlaceZerosInBSS;
  Options.GuaranteedTailCallOpt = EnableGuaranteedTailCallOpt;
  Options.DisableTailCalls = DisableTailCalls;
  Options.StackAlignmentOverride = OverrideStackAlignment;
  Options.TrapFuncName = TrapFuncName;
  Options.PositionIndependentExecutable = EnablePIE;
  Options.UseInitArray = !UseCtors;
  Options.DataSections = DataSections;
  Options.FunctionSections = FunctionSections;
  Options.UniqueSectionNames = UniqueSectionNames;

  Options.MCOptions = InitMCTargetOptionsFromFlags();
  Options.JTType = JTableType;

  Options.ThreadModel = TMModel;

  return Options;
}

static inline std::string getCPUStr() {
  // If user asked for the 'native' CPU, autodetect here. If autodection fails,
  // this will set the CPU to an empty string which tells the target to
  // pick a basic default.
  if (MCPU == "native")
    return sys::getHostCPUName();

  return MCPU;
}

static inline std::string getFeaturesStr() {
  SubtargetFeatures Features;

  // If user asked for the 'native' CPU, we need to autodetect features.
  // This is necessary for x86 where the CPU might not support all the
  // features the autodetected CPU name lists in the target. For example,
  // not all Sandybridge processors support AVX.
  if (MCPU == "native") {
    StringMap<bool> HostFeatures;
    if (sys::getHostCPUFeatures(HostFeatures))
      for (auto &F : HostFeatures)
        Features.AddFeature(F.first(), F.second);
  }

  for (unsigned i = 0; i != MAttrs.size(); ++i)
    Features.AddFeature(MAttrs[i]);

  return Features.getString();
}

#endif
