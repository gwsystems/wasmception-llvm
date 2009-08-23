//===-- ScheduleDAGPrinter.cpp - Implement ScheduleDAG::viewGraph() -------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This implements the ScheduleDAG::viewGraph method.
//
//===----------------------------------------------------------------------===//

#include "llvm/Constants.h"
#include "llvm/Function.h"
#include "llvm/Assembly/Writer.h"
#include "llvm/CodeGen/ScheduleDAG.h"
#include "llvm/CodeGen/MachineConstantPool.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineModuleInfo.h"
#include "llvm/CodeGen/PseudoSourceValue.h"
#include "llvm/Target/TargetRegisterInfo.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/GraphWriter.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/ADT/DenseSet.h"
#include "llvm/ADT/StringExtras.h"
#include "llvm/Config/config.h"
#include <fstream>
using namespace llvm;

namespace llvm {
  template<>
  struct DOTGraphTraits<ScheduleDAG*> : public DefaultDOTGraphTraits {
    static std::string getGraphName(const ScheduleDAG *G) {
      return G->MF.getFunction()->getName();
    }

    static bool renderGraphFromBottomUp() {
      return true;
    }
    
    static bool hasNodeAddressLabel(const SUnit *Node,
                                    const ScheduleDAG *Graph) {
      return true;
    }
    
    /// If you want to override the dot attributes printed for a particular
    /// edge, override this method.
    static std::string getEdgeAttributes(const SUnit *Node,
                                         SUnitIterator EI) {
      if (EI.isArtificialDep())
        return "color=cyan,style=dashed";
      if (EI.isCtrlDep())
        return "color=blue,style=dashed";
      return "";
    }
    

    static std::string getNodeLabel(const SUnit *Node,
                                    const ScheduleDAG *Graph,
                                    bool ShortNames);
    static std::string getNodeAttributes(const SUnit *N,
                                         const ScheduleDAG *Graph) {
      return "shape=Mrecord";
    }

    static void addCustomGraphFeatures(ScheduleDAG *G,
                                       GraphWriter<ScheduleDAG*> &GW) {
      return G->addCustomGraphFeatures(GW);
    }
  };
}

std::string DOTGraphTraits<ScheduleDAG*>::getNodeLabel(const SUnit *SU,
                                                       const ScheduleDAG *G,
                                                       bool ShortNames) {
  return G->getGraphNodeLabel(SU);
}

/// viewGraph - Pop up a ghostview window with the reachable parts of the DAG
/// rendered using 'dot'.
///
void ScheduleDAG::viewGraph() {
// This code is only for debugging!
#ifndef NDEBUG
  if (BB->getBasicBlock())
    ViewGraph(this, "dag." + MF.getFunction()->getNameStr(), false,
              "Scheduling-Units Graph for " + MF.getFunction()->getNameStr() + 
              ":" + BB->getBasicBlock()->getNameStr());
  else
    ViewGraph(this, "dag." + MF.getFunction()->getNameStr(), false,
              "Scheduling-Units Graph for " + MF.getFunction()->getNameStr());
#else
  errs() << "ScheduleDAG::viewGraph is only available in debug builds on "
         << "systems with Graphviz or gv!\n";
#endif  // NDEBUG
}
