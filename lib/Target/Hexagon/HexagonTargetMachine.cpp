//===-- HexagonTargetMachine.cpp - Define TargetMachine for Hexagon -------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// Implements the info about Hexagon target spec.
//
//===----------------------------------------------------------------------===//

#include "HexagonTargetMachine.h"
#include "Hexagon.h"
#include "HexagonISelLowering.h"
#include "HexagonMachineScheduler.h"
#include "HexagonTargetObjectFile.h"
#include "llvm/CodeGen/Passes.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/IR/Module.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/TargetRegistry.h"
#include "llvm/Transforms/IPO/PassManagerBuilder.h"
#include "llvm/Transforms/Scalar.h"

using namespace llvm;

static cl:: opt<bool> DisableHardwareLoops("disable-hexagon-hwloops",
  cl::Hidden, cl::desc("Disable Hardware Loops for Hexagon target"));

static cl::opt<bool> DisableHexagonCFGOpt("disable-hexagon-cfgopt",
  cl::Hidden, cl::ZeroOrMore, cl::init(false),
  cl::desc("Disable Hexagon CFG Optimization"));

static cl::opt<bool> EnableExpandCondsets("hexagon-expand-condsets",
  cl::init(true), cl::Hidden, cl::ZeroOrMore,
  cl::desc("Early expansion of MUX"));

static cl::opt<bool> EnableGenInsert("hexagon-insert", cl::init(true),
  cl::Hidden, cl::desc("Generate \"insert\" instructions"));

static cl::opt<bool> EnableCommGEP("hexagon-commgep", cl::init(true),
  cl::Hidden, cl::ZeroOrMore, cl::desc("Enable commoning of GEP instructions"));

static cl::opt<bool> EnableGenExtract("hexagon-extract", cl::init(true),
  cl::Hidden, cl::desc("Generate \"extract\" instructions"));

/// HexagonTargetMachineModule - Note that this is used on hosts that
/// cannot link in a library unless there are references into the
/// library.  In particular, it seems that it is not possible to get
/// things to work on Win32 without this.  Though it is unused, do not
/// remove it.
extern "C" int HexagonTargetMachineModule;
int HexagonTargetMachineModule = 0;

extern "C" void LLVMInitializeHexagonTarget() {
  // Register the target.
  RegisterTargetMachine<HexagonTargetMachine> X(TheHexagonTarget);
}

static ScheduleDAGInstrs *createVLIWMachineSched(MachineSchedContext *C) {
  return new VLIWMachineScheduler(C, make_unique<ConvergingVLIWScheduler>());
}

static MachineSchedRegistry
SchedCustomRegistry("hexagon", "Run Hexagon's custom scheduler",
                    createVLIWMachineSched);

namespace llvm {
  FunctionPass *createHexagonCFGOptimizer();
  FunctionPass *createHexagonCommonGEP();
  FunctionPass *createHexagonCopyToCombine();
  FunctionPass *createHexagonExpandCondsets();
  FunctionPass *createHexagonExpandPredSpillCode();
  FunctionPass *createHexagonFixupHwLoops();
  FunctionPass *createHexagonGenExtract();
  FunctionPass *createHexagonGenInsert();
  FunctionPass *createHexagonHardwareLoops();
  FunctionPass *createHexagonISelDag(HexagonTargetMachine &TM,
                                     CodeGenOpt::Level OptLevel);
  FunctionPass *createHexagonNewValueJump();
  FunctionPass *createHexagonPacketizer();
  FunctionPass *createHexagonPeephole();
  FunctionPass *createHexagonRemoveExtendArgs(const HexagonTargetMachine &TM);
  FunctionPass *createHexagonSplitConst32AndConst64();
} // end namespace llvm;

/// HexagonTargetMachine ctor - Create an ILP32 architecture model.
///

/// Hexagon_TODO: Do I need an aggregate alignment?
///
HexagonTargetMachine::HexagonTargetMachine(const Target &T, const Triple &TT,
                                           StringRef CPU, StringRef FS,
                                           const TargetOptions &Options,
                                           Reloc::Model RM, CodeModel::Model CM,
                                           CodeGenOpt::Level OL)
    : LLVMTargetMachine(T, "e-m:e-p:32:32-i1:32-i64:64-a:0-n32", TT, CPU, FS,
                        Options, RM, CM, OL),
      TLOF(make_unique<HexagonTargetObjectFile>()),
      Subtarget(TT, CPU, FS, *this) {
    initAsmInfo();
}

HexagonTargetMachine::~HexagonTargetMachine() {}

namespace {
/// Hexagon Code Generator Pass Configuration Options.
class HexagonPassConfig : public TargetPassConfig {
public:
  HexagonPassConfig(HexagonTargetMachine *TM, PassManagerBase &PM)
    : TargetPassConfig(TM, PM) {
    bool NoOpt = (TM->getOptLevel() == CodeGenOpt::None);
    if (!NoOpt) {
      if (EnableExpandCondsets) {
        Pass *Exp = createHexagonExpandCondsets();
        insertPass(&RegisterCoalescerID, IdentifyingPassPtr(Exp));
      }
    }
  }

  HexagonTargetMachine &getHexagonTargetMachine() const {
    return getTM<HexagonTargetMachine>();
  }

  ScheduleDAGInstrs *
  createMachineScheduler(MachineSchedContext *C) const override {
    return createVLIWMachineSched(C);
  }

  void addIRPasses() override;
  bool addInstSelector() override;
  void addPreRegAlloc() override;
  void addPostRegAlloc() override;
  void addPreSched2() override;
  void addPreEmitPass() override;
};
} // namespace

TargetPassConfig *HexagonTargetMachine::createPassConfig(PassManagerBase &PM) {
  return new HexagonPassConfig(this, PM);
}

void HexagonPassConfig::addIRPasses() {
  TargetPassConfig::addIRPasses();
  bool NoOpt = (getOptLevel() == CodeGenOpt::None);

  addPass(createAtomicExpandPass(TM));
  if (!NoOpt) {
    if (EnableCommGEP)
      addPass(createHexagonCommonGEP());
    // Replace certain combinations of shifts and ands with extracts.
    if (EnableGenExtract)
      addPass(createHexagonGenExtract());
  }
}

bool HexagonPassConfig::addInstSelector() {
  HexagonTargetMachine &TM = getHexagonTargetMachine();
  bool NoOpt = (getOptLevel() == CodeGenOpt::None);

  if (!NoOpt)
    addPass(createHexagonRemoveExtendArgs(TM));

  addPass(createHexagonISelDag(TM, getOptLevel()));

  if (!NoOpt) {
    addPass(createHexagonPeephole());
    printAndVerify("After hexagon peephole pass");
    if (EnableGenInsert)
      addPass(createHexagonGenInsert(), false);
  }

  return false;
}

void HexagonPassConfig::addPreRegAlloc() {
  if (getOptLevel() != CodeGenOpt::None)
    if (!DisableHardwareLoops)
      addPass(createHexagonHardwareLoops(), false);
}

void HexagonPassConfig::addPostRegAlloc() {
  if (getOptLevel() != CodeGenOpt::None)
    if (!DisableHexagonCFGOpt)
      addPass(createHexagonCFGOptimizer(), false);
}

void HexagonPassConfig::addPreSched2() {
  addPass(createHexagonCopyToCombine(), false);
  if (getOptLevel() != CodeGenOpt::None)
    addPass(&IfConverterID, false);
  addPass(createHexagonSplitConst32AndConst64());
}

void HexagonPassConfig::addPreEmitPass() {
  bool NoOpt = (getOptLevel() == CodeGenOpt::None);

  if (!NoOpt)
    addPass(createHexagonNewValueJump(), false);

  // Expand Spill code for predicate registers.
  addPass(createHexagonExpandPredSpillCode(), false);

  // Create Packets.
  if (!NoOpt) {
    if (!DisableHardwareLoops)
      addPass(createHexagonFixupHwLoops(), false);
    addPass(createHexagonPacketizer(), false);
  }
}
