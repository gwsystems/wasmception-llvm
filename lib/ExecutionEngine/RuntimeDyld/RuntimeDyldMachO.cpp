//===-- RuntimeDyldMachO.cpp - Run-time dynamic linker for MC-JIT -*- C++ -*-=//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// Implementation of the MC-JIT runtime dynamic linker.
//
//===----------------------------------------------------------------------===//

#include "RuntimeDyldMachO.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/StringRef.h"
using namespace llvm;
using namespace llvm::object;

#define DEBUG_TYPE "dyld"

namespace llvm {

static unsigned char *processFDE(unsigned char *P, intptr_t DeltaForText,
                                 intptr_t DeltaForEH) {
  uint32_t Length = *((uint32_t *)P);
  P += 4;
  unsigned char *Ret = P + Length;
  uint32_t Offset = *((uint32_t *)P);
  if (Offset == 0) // is a CIE
    return Ret;

  P += 4;
  intptr_t FDELocation = *((intptr_t *)P);
  intptr_t NewLocation = FDELocation - DeltaForText;
  *((intptr_t *)P) = NewLocation;
  P += sizeof(intptr_t);

  // Skip the FDE address range
  P += sizeof(intptr_t);

  uint8_t Augmentationsize = *P;
  P += 1;
  if (Augmentationsize != 0) {
    intptr_t LSDA = *((intptr_t *)P);
    intptr_t NewLSDA = LSDA - DeltaForEH;
    *((intptr_t *)P) = NewLSDA;
  }

  return Ret;
}

static intptr_t computeDelta(SectionEntry *A, SectionEntry *B) {
  intptr_t ObjDistance = A->ObjAddress - B->ObjAddress;
  intptr_t MemDistance = A->LoadAddress - B->LoadAddress;
  return ObjDistance - MemDistance;
}

void RuntimeDyldMachO::registerEHFrames() {

  if (!MemMgr)
    return;
  for (int i = 0, e = UnregisteredEHFrameSections.size(); i != e; ++i) {
    EHFrameRelatedSections &SectionInfo = UnregisteredEHFrameSections[i];
    if (SectionInfo.EHFrameSID == RTDYLD_INVALID_SECTION_ID ||
        SectionInfo.TextSID == RTDYLD_INVALID_SECTION_ID)
      continue;
    SectionEntry *Text = &Sections[SectionInfo.TextSID];
    SectionEntry *EHFrame = &Sections[SectionInfo.EHFrameSID];
    SectionEntry *ExceptTab = nullptr;
    if (SectionInfo.ExceptTabSID != RTDYLD_INVALID_SECTION_ID)
      ExceptTab = &Sections[SectionInfo.ExceptTabSID];

    intptr_t DeltaForText = computeDelta(Text, EHFrame);
    intptr_t DeltaForEH = 0;
    if (ExceptTab)
      DeltaForEH = computeDelta(ExceptTab, EHFrame);

    unsigned char *P = EHFrame->Address;
    unsigned char *End = P + EHFrame->Size;
    do {
      P = processFDE(P, DeltaForText, DeltaForEH);
    } while (P != End);

    MemMgr->registerEHFrames(EHFrame->Address, EHFrame->LoadAddress,
                             EHFrame->Size);
  }
  UnregisteredEHFrameSections.clear();
}

void RuntimeDyldMachO::finalizeLoad(ObjSectionToIDMap &SectionMap) {
  unsigned EHFrameSID = RTDYLD_INVALID_SECTION_ID;
  unsigned TextSID = RTDYLD_INVALID_SECTION_ID;
  unsigned ExceptTabSID = RTDYLD_INVALID_SECTION_ID;
  ObjSectionToIDMap::iterator i, e;
  for (i = SectionMap.begin(), e = SectionMap.end(); i != e; ++i) {
    const SectionRef &Section = i->first;
    StringRef Name;
    Section.getName(Name);
    if (Name == "__eh_frame")
      EHFrameSID = i->second;
    else if (Name == "__text")
      TextSID = i->second;
    else if (Name == "__gcc_except_tab")
      ExceptTabSID = i->second;
  }
  UnregisteredEHFrameSections.push_back(
      EHFrameRelatedSections(EHFrameSID, TextSID, ExceptTabSID));
}

// The target location for the relocation is described by RE.SectionID and
// RE.Offset.  RE.SectionID can be used to find the SectionEntry.  Each
// SectionEntry has three members describing its location.
// SectionEntry::Address is the address at which the section has been loaded
// into memory in the current (host) process.  SectionEntry::LoadAddress is the
// address that the section will have in the target process.
// SectionEntry::ObjAddress is the address of the bits for this section in the
// original emitted object image (also in the current address space).
//
// Relocations will be applied as if the section were loaded at
// SectionEntry::LoadAddress, but they will be applied at an address based
// on SectionEntry::Address.  SectionEntry::ObjAddress will be used to refer to
// Target memory contents if they are required for value calculations.
//
// The Value parameter here is the load address of the symbol for the
// relocation to be applied.  For relocations which refer to symbols in the
// current object Value will be the LoadAddress of the section in which
// the symbol resides (RE.Addend provides additional information about the
// symbol location).  For external symbols, Value will be the address of the
// symbol in the target address space.
void RuntimeDyldMachO::resolveRelocation(const RelocationEntry &RE,
                                         uint64_t Value) {
  DEBUG (
    const SectionEntry &Section = Sections[RE.SectionID];
    uint8_t* LocalAddress = Section.Address + RE.Offset;
    uint64_t FinalAddress = Section.LoadAddress + RE.Offset;

    dbgs() << "resolveRelocation Section: " << RE.SectionID
           << " LocalAddress: " << format("%p", LocalAddress)
           << " FinalAddress: " << format("%p", FinalAddress)
           << " Value: " << format("%p", Value)
           << " Addend: " << RE.Addend
           << " isPCRel: " << RE.IsPCRel
           << " MachoType: " << RE.RelType
           << " Size: " << (1 << RE.Size) << "\n";
  );

  // This just dispatches to the proper target specific routine.
  switch (Arch) {
  default:
    llvm_unreachable("Unsupported CPU type!");
  case Triple::x86_64:
    resolveX86_64Relocation(RE, Value);
    break;
  case Triple::x86:
    resolveI386Relocation(RE, Value);
    break;
  case Triple::arm: // Fall through.
  case Triple::thumb:
    resolveARMRelocation(RE, Value);
    break;
  case Triple::arm64:
    resolveARM64Relocation(RE, Value);
    break;
  }
}

bool RuntimeDyldMachO::resolveI386Relocation(const RelocationEntry &RE,
                                             uint64_t Value) {
  const SectionEntry &Section = Sections[RE.SectionID];
  uint8_t* LocalAddress = Section.Address + RE.Offset;

  if (RE.IsPCRel) {
    uint64_t FinalAddress = Section.LoadAddress + RE.Offset;
    Value -= FinalAddress + 4; // see MachOX86_64::resolveRelocation.
  }

  switch (RE.RelType) {
    default:
      llvm_unreachable("Invalid relocation type!");
    case MachO::GENERIC_RELOC_VANILLA:
      return applyRelocationValue(LocalAddress, Value + RE.Addend,
                                  1 << RE.Size);
    case MachO::GENERIC_RELOC_SECTDIFF:
    case MachO::GENERIC_RELOC_LOCAL_SECTDIFF:
    case MachO::GENERIC_RELOC_PB_LA_PTR:
      return Error("Relocation type not implemented yet!");
  }
}

bool RuntimeDyldMachO::resolveX86_64Relocation(const RelocationEntry &RE,
                                               uint64_t Value) {
  const SectionEntry &Section = Sections[RE.SectionID];
  uint8_t* LocalAddress = Section.Address + RE.Offset;

  // If the relocation is PC-relative, the value to be encoded is the
  // pointer difference.
  if (RE.IsPCRel) {
    // FIXME: It seems this value needs to be adjusted by 4 for an effective PC
    // address. Is that expected? Only for branches, perhaps?
    uint64_t FinalAddress = Section.LoadAddress + RE.Offset;
    Value -= FinalAddress + 4; // see MachOX86_64::resolveRelocation.
  }

  switch (RE.RelType) {
  default:
    llvm_unreachable("Invalid relocation type!");
  case MachO::X86_64_RELOC_SIGNED_1:
  case MachO::X86_64_RELOC_SIGNED_2:
  case MachO::X86_64_RELOC_SIGNED_4:
  case MachO::X86_64_RELOC_SIGNED:
  case MachO::X86_64_RELOC_UNSIGNED:
  case MachO::X86_64_RELOC_BRANCH:
    return applyRelocationValue(LocalAddress, Value + RE.Addend, 1 << RE.Size);
  case MachO::X86_64_RELOC_GOT_LOAD:
  case MachO::X86_64_RELOC_GOT:
  case MachO::X86_64_RELOC_SUBTRACTOR:
  case MachO::X86_64_RELOC_TLV:
    return Error("Relocation type not implemented yet!");
  }
}

bool RuntimeDyldMachO::resolveARMRelocation(const RelocationEntry &RE,
                                            uint64_t Value) {
  const SectionEntry &Section = Sections[RE.SectionID];
  uint8_t* LocalAddress = Section.Address + RE.Offset;

  // If the relocation is PC-relative, the value to be encoded is the
  // pointer difference.
  if (RE.IsPCRel) {
    uint64_t FinalAddress = Section.LoadAddress + RE.Offset;
    Value -= FinalAddress;
    // ARM PCRel relocations have an effective-PC offset of two instructions
    // (four bytes in Thumb mode, 8 bytes in ARM mode).
    // FIXME: For now, assume ARM mode.
    Value -= 8;
  }

  switch (RE.RelType) {
  default:
    llvm_unreachable("Invalid relocation type!");
  case MachO::ARM_RELOC_VANILLA:
    return applyRelocationValue(LocalAddress, Value, 1 << RE.Size);
  case MachO::ARM_RELOC_BR24: {
    // Mask the value into the target address. We know instructions are
    // 32-bit aligned, so we can do it all at once.
    uint32_t *p = (uint32_t *)LocalAddress;
    // The low two bits of the value are not encoded.
    Value >>= 2;
    // Mask the value to 24 bits.
    uint64_t FinalValue = Value & 0xffffff;
    // Check for overflow.
    if (Value != FinalValue)
      return Error("ARM BR24 relocation out of range.");
    // FIXME: If the destination is a Thumb function (and the instruction
    // is a non-predicated BL instruction), we need to change it to a BLX
    // instruction instead.

    // Insert the value into the instruction.
    *p = (*p & ~0xffffff) | FinalValue;
    break;
  }
  case MachO::ARM_THUMB_RELOC_BR22:
  case MachO::ARM_THUMB_32BIT_BRANCH:
  case MachO::ARM_RELOC_HALF:
  case MachO::ARM_RELOC_HALF_SECTDIFF:
  case MachO::ARM_RELOC_PAIR:
  case MachO::ARM_RELOC_SECTDIFF:
  case MachO::ARM_RELOC_LOCAL_SECTDIFF:
  case MachO::ARM_RELOC_PB_LA_PTR:
    return Error("Relocation type not implemented yet!");
  }
  return false;
}

bool RuntimeDyldMachO::resolveARM64Relocation(const RelocationEntry &RE,
                                              uint64_t Value) {
  const SectionEntry &Section = Sections[RE.SectionID];
  uint8_t* LocalAddress = Section.Address + RE.Offset;

  // If the relocation is PC-relative, the value to be encoded is the
  // pointer difference.
  if (RE.IsPCRel) {
    uint64_t FinalAddress = Section.LoadAddress + RE.Offset;
    Value -= FinalAddress;
  }

  switch (RE.RelType) {
  default:
    llvm_unreachable("Invalid relocation type!");
  case MachO::ARM64_RELOC_UNSIGNED:
    return applyRelocationValue(LocalAddress, Value, 1 << RE.Size);
  case MachO::ARM64_RELOC_BRANCH26: {
    // Mask the value into the target address. We know instructions are
    // 32-bit aligned, so we can do it all at once.
    uint32_t *p = (uint32_t *)LocalAddress;
    // The low two bits of the value are not encoded.
    Value >>= 2;
    // Mask the value to 26 bits.
    uint64_t FinalValue = Value & 0x3ffffff;
    // Check for overflow.
    if (FinalValue != Value)
      return Error("ARM64 BRANCH26 relocation out of range.");
    // Insert the value into the instruction.
    *p = (*p & ~0x3ffffff) | FinalValue;
    break;
  }
  case MachO::ARM64_RELOC_SUBTRACTOR:
  case MachO::ARM64_RELOC_PAGE21:
  case MachO::ARM64_RELOC_PAGEOFF12:
  case MachO::ARM64_RELOC_GOT_LOAD_PAGE21:
  case MachO::ARM64_RELOC_GOT_LOAD_PAGEOFF12:
  case MachO::ARM64_RELOC_POINTER_TO_GOT:
  case MachO::ARM64_RELOC_TLVP_LOAD_PAGE21:
  case MachO::ARM64_RELOC_TLVP_LOAD_PAGEOFF12:
  case MachO::ARM64_RELOC_ADDEND:
    return Error("Relocation type not implemented yet!");
  }
  return false;
}

relocation_iterator RuntimeDyldMachO::processRelocationRef(
    unsigned SectionID, relocation_iterator RelI, ObjectImage &Obj,
    ObjSectionToIDMap &ObjSectionToID, const SymbolTableMap &Symbols,
    StubMap &Stubs) {
  const ObjectFile *OF = Obj.getObjectFile();
  const MachOObjectFile *MachO = static_cast<const MachOObjectFile *>(OF);
  MachO::any_relocation_info RE =
      MachO->getRelocation(RelI->getRawDataRefImpl());

  uint32_t RelType = MachO->getAnyRelocationType(RE);

  // FIXME: Properly handle scattered relocations.
  //        For now, optimistically skip these: they can often be ignored, as
  //        the static linker will already have applied the relocation, and it
  //        only needs to be reapplied if symbols move relative to one another.
  //        Note: This will fail horribly where the relocations *do* need to be
  //        applied, but that was already the case.
  if (MachO->isRelocationScattered(RE))
    return ++RelI;

  RelocationValueRef Value;
  SectionEntry &Section = Sections[SectionID];

  bool IsExtern = MachO->getPlainRelocationExternal(RE);
  bool IsPCRel = MachO->getAnyRelocationPCRel(RE);
  unsigned Size = MachO->getAnyRelocationLength(RE);
  uint64_t Offset;
  RelI->getOffset(Offset);
  uint8_t *LocalAddress = Section.Address + Offset;
  unsigned NumBytes = 1 << Size;
  uint64_t Addend = 0;
  memcpy(&Addend, LocalAddress, NumBytes);

  if (IsExtern) {
    // Obtain the symbol name which is referenced in the relocation
    symbol_iterator Symbol = RelI->getSymbol();
    StringRef TargetName;
    Symbol->getName(TargetName);
    // First search for the symbol in the local symbol table
    SymbolTableMap::const_iterator lsi = Symbols.find(TargetName.data());
    if (lsi != Symbols.end()) {
      Value.SectionID = lsi->second.first;
      Value.Addend = lsi->second.second + Addend;
    } else {
      // Search for the symbol in the global symbol table
      SymbolTableMap::const_iterator gsi =
          GlobalSymbolTable.find(TargetName.data());
      if (gsi != GlobalSymbolTable.end()) {
        Value.SectionID = gsi->second.first;
        Value.Addend = gsi->second.second + Addend;
      } else {
        Value.SymbolName = TargetName.data();
        Value.Addend = Addend;
      }
    }
  } else {
    SectionRef Sec = MachO->getRelocationSection(RE);
    bool IsCode = false;
    Sec.isText(IsCode);
    Value.SectionID = findOrEmitSection(Obj, Sec, IsCode, ObjSectionToID);
    uint64_t Addr;
    Sec.getAddress(Addr);
    Value.Addend = Addend - Addr;
    if (IsPCRel)
      Value.Addend += Offset + NumBytes;
  }

  if (Arch == Triple::x86_64 && (RelType == MachO::X86_64_RELOC_GOT ||
                                 RelType == MachO::X86_64_RELOC_GOT_LOAD)) {
    assert(IsPCRel);
    assert(Size == 2);
    StubMap::const_iterator i = Stubs.find(Value);
    uint8_t *Addr;
    if (i != Stubs.end()) {
      Addr = Section.Address + i->second;
    } else {
      Stubs[Value] = Section.StubOffset;
      uint8_t *GOTEntry = Section.Address + Section.StubOffset;
      RelocationEntry GOTRE(SectionID, Section.StubOffset,
                            MachO::X86_64_RELOC_UNSIGNED, 0, false, 3);
      if (Value.SymbolName)
        addRelocationForSymbol(GOTRE, Value.SymbolName);
      else
        addRelocationForSection(GOTRE, Value.SectionID);
      Section.StubOffset += 8;
      Addr = GOTEntry;
    }
    RelocationEntry TargetRE(SectionID, Offset,
                             MachO::X86_64_RELOC_UNSIGNED, Value.Addend, true,
                             2);
    resolveRelocation(TargetRE, (uint64_t)Addr);
  } else if (Arch == Triple::arm && (RelType & 0xf) == MachO::ARM_RELOC_BR24) {
    // This is an ARM branch relocation, need to use a stub function.

    //  Look up for existing stub.
    StubMap::const_iterator i = Stubs.find(Value);
    uint8_t *Addr;
    if (i != Stubs.end()) {
      Addr = Section.Address + i->second;
    } else {
      // Create a new stub function.
      Stubs[Value] = Section.StubOffset;
      uint8_t *StubTargetAddr =
          createStubFunction(Section.Address + Section.StubOffset);
      RelocationEntry StubRE(SectionID, StubTargetAddr - Section.Address,
                             MachO::GENERIC_RELOC_VANILLA, Value.Addend);
      if (Value.SymbolName)
        addRelocationForSymbol(StubRE, Value.SymbolName);
      else
        addRelocationForSection(StubRE, Value.SectionID);
      Addr = Section.Address + Section.StubOffset;
      Section.StubOffset += getMaxStubSize();
    }
    RelocationEntry TargetRE(Value.SectionID, Offset, RelType, 0, IsPCRel,
                             Size);
    resolveRelocation(TargetRE, (uint64_t)Addr);
  } else {
    RelocationEntry RE(SectionID, Offset, RelType, Value.Addend, IsPCRel, Size);
    if (Value.SymbolName)
      addRelocationForSymbol(RE, Value.SymbolName);
    else
      addRelocationForSection(RE, Value.SectionID);
  }
  return ++RelI;
}

bool
RuntimeDyldMachO::isCompatibleFormat(const ObjectBuffer *InputBuffer) const {
  if (InputBuffer->getBufferSize() < 4)
    return false;
  StringRef Magic(InputBuffer->getBufferStart(), 4);
  if (Magic == "\xFE\xED\xFA\xCE")
    return true;
  if (Magic == "\xCE\xFA\xED\xFE")
    return true;
  if (Magic == "\xFE\xED\xFA\xCF")
    return true;
  if (Magic == "\xCF\xFA\xED\xFE")
    return true;
  return false;
}

bool RuntimeDyldMachO::isCompatibleFile(const object::ObjectFile *Obj) const {
  return Obj->isMachO();
}

} // end namespace llvm
