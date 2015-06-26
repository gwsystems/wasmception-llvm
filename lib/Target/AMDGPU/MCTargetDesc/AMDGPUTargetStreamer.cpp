//===-- AMDGPUTargetStreamer.cpp - Mips Target Streamer Methods -----------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file provides AMDGPU specific target streamer methods.
//
//===----------------------------------------------------------------------===//

#include "AMDGPUTargetStreamer.h"
#include "llvm/ADT/Twine.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCELFStreamer.h"
#include "llvm/MC/MCSectionELF.h"
#include "llvm/Support/ELF.h"
#include "llvm/Support/FormattedStream.h"

using namespace llvm;

AMDGPUTargetStreamer::AMDGPUTargetStreamer(MCStreamer &S)
    : MCTargetStreamer(S) { }

//===----------------------------------------------------------------------===//
// AMDGPUTargetAsmStreamer
//===----------------------------------------------------------------------===//

AMDGPUTargetAsmStreamer::AMDGPUTargetAsmStreamer(MCStreamer &S,
                                                 formatted_raw_ostream &OS)
    : AMDGPUTargetStreamer(S), OS(OS) { }

void
AMDGPUTargetAsmStreamer::EmitDirectiveHSACodeObjectVersion(uint32_t Major,
                                                           uint32_t Minor) {
  OS << "\t.hsa_code_object_version " <<
        Twine(Major) << "," << Twine(Minor) << '\n';
}

void
AMDGPUTargetAsmStreamer::EmitDirectiveHSACodeObjectISA(uint32_t Major,
                                                       uint32_t Minor,
                                                       uint32_t Stepping,
                                                       StringRef VendorName,
                                                       StringRef ArchName) {
  OS << "\t.hsa_code_object_isa " <<
        Twine(Major) << "," << Twine(Minor) << "," << Twine(Stepping) <<
        ",\"" << VendorName << "\",\"" << ArchName << "\"\n";

}

//===----------------------------------------------------------------------===//
// AMDGPUTargetELFStreamer
//===----------------------------------------------------------------------===//

AMDGPUTargetELFStreamer::AMDGPUTargetELFStreamer(MCStreamer &S)
    : AMDGPUTargetStreamer(S), Streamer(S) { }

MCELFStreamer &AMDGPUTargetELFStreamer::getStreamer() {
  return static_cast<MCELFStreamer &>(Streamer);
}

void
AMDGPUTargetELFStreamer::EmitDirectiveHSACodeObjectVersion(uint32_t Major,
                                                           uint32_t Minor) {
  MCStreamer &OS = getStreamer();
  MCSectionELF *Note = OS.getContext().getELFSection(".note", ELF::SHT_NOTE, 0);

  unsigned NameSZ = 4;

  OS.PushSection();
  OS.SwitchSection(Note);
  OS.EmitIntValue(NameSZ, 4);                            // namesz
  OS.EmitIntValue(8, 4);                                 // descz
  OS.EmitIntValue(NT_AMDGPU_HSA_CODE_OBJECT_VERSION, 4); // type
  OS.EmitBytes(StringRef("AMD", NameSZ));                // name
  OS.EmitIntValue(Major, 4);                             // desc
  OS.EmitIntValue(Minor, 4);
  OS.EmitValueToAlignment(4);
  OS.PopSection();
}

void
AMDGPUTargetELFStreamer::EmitDirectiveHSACodeObjectISA(uint32_t Major,
                                                       uint32_t Minor,
                                                       uint32_t Stepping,
                                                       StringRef VendorName,
                                                       StringRef ArchName) {
  MCStreamer &OS = getStreamer();
  MCSectionELF *Note = OS.getContext().getELFSection(".note", ELF::SHT_NOTE, 0);

  unsigned NameSZ = 4;
  uint16_t VendorNameSize = VendorName.size() + 1;
  uint16_t ArchNameSize = ArchName.size() + 1;
  unsigned DescSZ = sizeof(VendorNameSize) + sizeof(ArchNameSize) +
                    sizeof(Major) + sizeof(Minor) + sizeof(Stepping) +
                    VendorNameSize + ArchNameSize;

  OS.PushSection();
  OS.SwitchSection(Note);
  OS.EmitIntValue(NameSZ, 4);                            // namesz
  OS.EmitIntValue(DescSZ, 4);                            // descsz
  OS.EmitIntValue(NT_AMDGPU_HSA_ISA, 4);                 // type
  OS.EmitBytes(StringRef("AMD", 4));                     // name
  OS.EmitIntValue(VendorNameSize, 2);                    // desc
  OS.EmitIntValue(ArchNameSize, 2);
  OS.EmitIntValue(Major, 4);
  OS.EmitIntValue(Minor, 4);
  OS.EmitIntValue(Stepping, 4);
  OS.EmitBytes(VendorName);
  OS.EmitIntValue(0, 1); // NULL terminate VendorName
  OS.EmitBytes(ArchName);
  OS.EmitIntValue(0, 1); // NULL terminte ArchName
  OS.EmitValueToAlignment(4);
  OS.PopSection();
}
