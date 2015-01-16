//===-- StatepointDefaultGC.cpp - The default statepoint GC strategy ------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains a GCStrategy which serves as an example for the usage
// of a statepoint based lowering strategy.  This GCStrategy is intended to
// suitable as a default implementation usable with any collector which can
// consume the standard stackmap format generated by statepoints, uses the
// default addrespace to distinguish between gc managed and non-gc managed
// pointers, and has reasonable relocation semantics.
//
//===----------------------------------------------------------------------===//

#include "llvm/IR/GCStrategy.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/Value.h"

using namespace llvm;

namespace {
class StatepointGC : public GCStrategy {
public:
  StatepointGC() {
    UseStatepoints = true;
    // These options are all gc.root specific, we specify them so that the
    // gc.root lowering code doesn't run.
    InitRoots = false;
    NeededSafePoints = 0;
    UsesMetadata = false;
    CustomRoots = false;
  }
  Optional<bool> isGCManagedPointer(const Value *V) const override {
    // Method is only valid on pointer typed values.
    PointerType *PT = cast<PointerType>(V->getType());
    // For the sake of this example GC, we arbitrarily pick addrspace(1) as our
    // GC managed heap.  We know that a pointer into this heap needs to be
    // updated and that no other pointer does.  Note that addrspace(1) is used
    // only as an example, it has no special meaning, and is not reserved for
    // GC usage.
    return (1 == PT->getAddressSpace());
  }
};
}

static GCRegistry::Add<StatepointGC> X("statepoint-example",
                                       "an example strategy for statepoint");

namespace llvm {
void linkStatepointExampleGC() {}
}
