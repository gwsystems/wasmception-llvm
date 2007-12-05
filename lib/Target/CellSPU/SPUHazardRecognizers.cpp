//===-- SPUHazardRecognizers.cpp - Cell Hazard Recognizer Impls -----------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file was developed by a team from the Computer Systems Research
// Department at The Aerospace Corporation and is distributed under the
// University of Illinois Open Source License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements hazard recognizers for scheduling on Cell SPU
// processors.
//
//===----------------------------------------------------------------------===//

#define DEBUG_TYPE "sched"

#include "SPUHazardRecognizers.h"
#include "SPU.h"
#include "SPUInstrInfo.h"
#include "llvm/Support/Debug.h"

using namespace llvm;

//===----------------------------------------------------------------------===//
// Cell SPU hazard recognizer
//
// This is the pipeline hazard recognizer for the Cell SPU processor. It does
// very little right now.
//===----------------------------------------------------------------------===//

SPUHazardRecognizer::SPUHazardRecognizer(const TargetInstrInfo &tii) :
  TII(tii),
  EvenOdd(0)
{
}

/// Return the pipeline hazard type encountered or generated by this
/// instruction. Currently returns NoHazard.
///
/// \return NoHazard
HazardRecognizer::HazardType
SPUHazardRecognizer::getHazardType(SDNode *Node)
{
  // Initial thoughts on how to do this, but this code cannot work unless the
  // function's prolog and epilog code are also being scheduled so that we can
  // accurately determine which pipeline is being scheduled.
#if 0
  HazardRecognizer::HazardType retval = NoHazard;
  bool mustBeOdd = false;

  switch (Node->getOpcode()) {
  case SPU::LQDv16i8:
  case SPU::LQDv8i16:
  case SPU::LQDv4i32:
  case SPU::LQDv4f32:
  case SPU::LQDv2f64:
  case SPU::LQDr128:
  case SPU::LQDr64:
  case SPU::LQDr32:
  case SPU::LQDr16:
  case SPU::LQAv16i8:
  case SPU::LQAv8i16:
  case SPU::LQAv4i32:
  case SPU::LQAv4f32:
  case SPU::LQAv2f64:
  case SPU::LQAr128:
  case SPU::LQAr64:
  case SPU::LQAr32:
  case SPU::LQXv4i32:
  case SPU::LQXr128:
  case SPU::LQXr64:
  case SPU::LQXr32:
  case SPU::LQXr16:
  case SPU::STQDv16i8:
  case SPU::STQDv8i16:
  case SPU::STQDv4i32:
  case SPU::STQDv4f32:
  case SPU::STQDv2f64:
  case SPU::STQDr128:
  case SPU::STQDr64:
  case SPU::STQDr32:
  case SPU::STQDr16:
  case SPU::STQDr8:
  case SPU::STQAv16i8:
  case SPU::STQAv8i16:
  case SPU::STQAv4i32:
  case SPU::STQAv4f32:
  case SPU::STQAv2f64:
  case SPU::STQAr128:
  case SPU::STQAr64:
  case SPU::STQAr32:
  case SPU::STQAr16:
  case SPU::STQAr8:
  case SPU::STQXv16i8:
  case SPU::STQXv8i16:
  case SPU::STQXv4i32:
  case SPU::STQXv4f32:
  case SPU::STQXv2f64:
  case SPU::STQXr128:
  case SPU::STQXr64:
  case SPU::STQXr32:
  case SPU::STQXr16:
  case SPU::STQXr8:
  case SPU::RET:
    mustBeOdd = true;
    break;
  default:
    // Assume that this instruction can be on the even pipe
    break;
  }

  if (mustBeOdd && !EvenOdd)
    retval = Hazard;

  DOUT << "SPUHazardRecognizer EvenOdd " << EvenOdd << " Hazard " << retval << "\n";
  EvenOdd ^= 1;
  return retval;
#else
  return NoHazard;
#endif
}

void SPUHazardRecognizer::EmitInstruction(SDNode *Node)
{
}

void SPUHazardRecognizer::AdvanceCycle()
{
  DOUT << "SPUHazardRecognizer::AdvanceCycle\n";
}

void SPUHazardRecognizer::EmitNoop()
{
  AdvanceCycle();
}
