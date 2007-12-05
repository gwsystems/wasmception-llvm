//=====-- SPUSubtarget.h - Define Subtarget for the Cell SPU -----*- C++ -*--=//
//
//                     The LLVM Compiler Infrastructure
//
// This file was developed by a team from the Computer Systems Research
// Department at The Aerospace Corporation and is distributed under the
// University of Illinois Open Source License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file declares the Cell SPU-specific subclass of TargetSubtarget.
//
//===----------------------------------------------------------------------===//

#ifndef POWERPCSUBTARGET_H
#define POWERPCSUBTARGET_H

#include "llvm/Target/TargetInstrItineraries.h"
#include "llvm/Target/TargetSubtarget.h"

#include <string>

namespace llvm {
  class Module;
  class GlobalValue;
  class TargetMachine;

  namespace SPU {
    enum {
      DEFAULT_PROC
    };
  }
    
  class SPUSubtarget : public TargetSubtarget {
  protected:
    const TargetMachine &TM;
    
    /// stackAlignment - The minimum alignment known to hold of the stack frame
    /// on entry to the function and which must be maintained by every function.
    unsigned StackAlignment;
    
    /// Selected instruction itineraries (one entry per itinerary class.)
    InstrItineraryData InstrItins;

    /// Which SPU processor (this isn't really used, but it's there to keep
    /// the C compiler happy)
    unsigned ProcDirective;

    /// Use (assume) large memory -- effectively disables the LQA/STQA
    /// instructions that assume 259K local store.
    bool UseLargeMem;
    
  public:
    /// This constructor initializes the data members to match that
    /// of the specified module.
    ///
    SPUSubtarget(const TargetMachine &TM, const Module &M,
                 const std::string &FS);
    
    /// ParseSubtargetFeatures - Parses features string setting specified 
    /// subtarget options.  Definition of function is auto generated by tblgen.
    void ParseSubtargetFeatures(const std::string &FS, const std::string &CPU);
    
    /// SetJITMode - This is called to inform the subtarget info that we are
    /// producing code for the JIT.
    void SetJITMode();

    /// getStackAlignment - Returns the minimum alignment known to hold of the
    /// stack frame on entry to the function and which must be maintained by
    /// every function for this subtarget.
    unsigned getStackAlignment() const { return StackAlignment; }
    
    /// getInstrItins - Return the instruction itineraies based on subtarget 
    /// selection.
    const InstrItineraryData &getInstrItineraryData() const {
      return InstrItins;
    }

    /// Use large memory addressing predicate
    bool usingLargeMem() const {
      return UseLargeMem;
    }

    /// getTargetDataString - Return the pointer size and type alignment
    /// properties of this subtarget.
    const char *getTargetDataString() const {
      return "E-p:32:32:128-f64:64:128-f32:32:128-i64:32:128-i32:32:128"
	     "-i16:16:128-i8:8:128-i1:8:128-a:0:128-v128:128:128"
             "-s:128:128";
    }
  };
} // End llvm namespace

#endif
