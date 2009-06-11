//===-- lib/CodeGen/ELF.h - ELF constants and data structures ---*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This header contains common, non-processor-specific data structures and
// constants for the ELF file format.
//
// The details of the ELF32 bits in this file are largely based on
// the Tool Interface Standard (TIS) Executable and Linking Format
// (ELF) Specification Version 1.2, May 1995. The ELF64 stuff is not
// standardized, as far as I can tell. It was largely based on information
// I found in OpenBSD header files.
//
//===----------------------------------------------------------------------===//

#ifndef CODEGEN_ELF_H
#define CODEGEN_ELF_H

#include "llvm/GlobalVariable.h"
#include "llvm/CodeGen/MachineRelocation.h"
#include "llvm/Support/DataTypes.h"
#include <cstring>

namespace llvm {

  // Identification Indexes
  enum {
    EI_MAG0 = 0,
    EI_MAG1 = 1,
    EI_MAG2 = 2,
    EI_MAG3 = 3
  };

  // File types
  enum {
    ET_NONE   = 0,      // No file type
    ET_REL    = 1,      // Relocatable file
    ET_EXEC   = 2,      // Executable file
    ET_DYN    = 3,      // Shared object file
    ET_CORE   = 4,      // Core file
    ET_LOPROC = 0xff00, // Beginning of processor-specific codes
    ET_HIPROC = 0xffff  // Processor-specific
  };

  // Object file classes.
  enum {
    ELFCLASS32 = 1, // 32-bit object file
    ELFCLASS64 = 2  // 64-bit object file
  };

  // Object file byte orderings.
  enum {
    ELFDATA2LSB = 1, // Little-endian object file
    ELFDATA2MSB = 2  // Big-endian object file
  };

  // Versioning
  enum {
    EV_NONE = 0,
    EV_CURRENT = 1
  };

  struct ELFHeader {
    // e_machine - This field is the target specific value to emit as the
    // e_machine member of the ELF header.
    unsigned short e_machine;

    // e_flags - The machine flags for the target.  This defaults to zero.
    unsigned e_flags;

    // e_size - Holds the ELF header's size in bytes
    unsigned e_ehsize;

    // Endianess and ELF Class (64 or 32 bits)
    unsigned ByteOrder;
    unsigned ElfClass;

    unsigned getByteOrder() const { return ByteOrder; }
    unsigned getElfClass() const { return ElfClass; }
    unsigned getSize() const { return e_ehsize; }
    unsigned getMachine() const { return e_machine; }
    unsigned getFlags() const { return e_flags; }

    ELFHeader(unsigned short machine, unsigned flags,
              bool is64Bit, bool isLittleEndian)
      : e_machine(machine), e_flags(flags) {
        ElfClass  = is64Bit ? ELFCLASS64 : ELFCLASS32;
        ByteOrder = isLittleEndian ? ELFDATA2LSB : ELFDATA2MSB;
        e_ehsize  = is64Bit ? 64 : 52;
      }
  };

  /// ELFSection - This struct contains information about each section that is
  /// emitted to the file.  This is eventually turned into the section header
  /// table at the end of the file.
  struct ELFSection {

    // Name of the section
    std::string Name;

    // ELF specific fields
    unsigned NameIdx;   // sh_name - .shstrtab idx of name, once emitted.
    unsigned Type;      // sh_type - Section contents & semantics 
    unsigned Flags;     // sh_flags - Section flags.
    uint64_t Addr;      // sh_addr - The mem addr this section is in.
    unsigned Offset;    // sh_offset - Offset from the file start
    unsigned Size;      // sh_size - The section size.
    unsigned Link;      // sh_link - Section header table index link.
    unsigned Info;      // sh_info - Auxillary information.
    unsigned Align;     // sh_addralign - Alignment of section.
    unsigned EntSize;   // sh_entsize - Size of entries in the section e

    // Section Header Flags
    enum {
      SHF_WRITE            = 1 << 0, // Writable
      SHF_ALLOC            = 1 << 1, // Mapped into the process addr space
      SHF_EXECINSTR        = 1 << 2, // Executable
      SHF_MERGE            = 1 << 4, // Might be merged if equal
      SHF_STRINGS          = 1 << 5, // Contains null-terminated strings
      SHF_INFO_LINK        = 1 << 6, // 'sh_info' contains SHT index
      SHF_LINK_ORDER       = 1 << 7, // Preserve order after combining
      SHF_OS_NONCONFORMING = 1 << 8, // nonstandard OS support required
      SHF_GROUP            = 1 << 9, // Section is a member of a group
      SHF_TLS              = 1 << 10 // Section holds thread-local data
    };

    // Section Types
    enum {
      SHT_NULL     = 0,  // No associated section (inactive entry).
      SHT_PROGBITS = 1,  // Program-defined contents.
      SHT_SYMTAB   = 2,  // Symbol table.
      SHT_STRTAB   = 3,  // String table.
      SHT_RELA     = 4,  // Relocation entries; explicit addends.
      SHT_HASH     = 5,  // Symbol hash table.
      SHT_DYNAMIC  = 6,  // Information for dynamic linking.
      SHT_NOTE     = 7,  // Information about the file.
      SHT_NOBITS   = 8,  // Data occupies no space in the file.
      SHT_REL      = 9,  // Relocation entries; no explicit addends.
      SHT_SHLIB    = 10, // Reserved.
      SHT_DYNSYM   = 11, // Symbol table.
      SHT_LOPROC   = 0x70000000, // Lowest processor architecture-specific type.
      SHT_HIPROC   = 0x7fffffff, // Highest processor architecture-specific type.
      SHT_LOUSER   = 0x80000000, // Lowest type reserved for applications.
      SHT_HIUSER   = 0xffffffff  // Highest type reserved for applications.
    };

    // Special section indices.
    enum {
      SHN_UNDEF     = 0,      // Undefined, missing, irrelevant
      SHN_LORESERVE = 0xff00, // Lowest reserved index
      SHN_LOPROC    = 0xff00, // Lowest processor-specific index
      SHN_HIPROC    = 0xff1f, // Highest processor-specific index
      SHN_ABS       = 0xfff1, // Symbol has absolute value; no relocation
      SHN_COMMON    = 0xfff2, // FORTRAN COMMON or C external global variables
      SHN_HIRESERVE = 0xffff  // Highest reserved index
    };

    /// SectionIdx - The number of the section in the Section Table.
    unsigned short SectionIdx;

    /// SectionData - The actual data for this section which we are building
    /// up for emission to the file.
    std::vector<unsigned char> SectionData;

    /// Relocations - The relocations that we have encountered so far in this 
    /// section that we will need to convert to Elf relocation entries when
    /// the file is written.
    std::vector<MachineRelocation> Relocations;

    /// Section Header Size 
    static unsigned getSectionHdrSize(bool is64Bit)
      { return is64Bit ? 64 : 40; }

    ELFSection(const std::string &name)
      : Name(name), Type(0), Flags(0), Addr(0), Offset(0), Size(0),
        Link(0), Info(0), Align(0), EntSize(0) {}
  };

  /// ELFSym - This struct contains information about each symbol that is
  /// added to logical symbol table for the module.  This is eventually
  /// turned into a real symbol table in the file.
  struct ELFSym {
    const GlobalValue *GV;    // The global value this corresponds to.

    // ELF specific fields
    unsigned NameIdx;         // Index in .strtab of name, once emitted.
    uint64_t Value;
    unsigned Size;
    uint8_t Info;
    uint8_t Other;
    unsigned short SectionIdx;

    enum { 
      STB_LOCAL = 0,
      STB_GLOBAL = 1,
      STB_WEAK = 2 
    };

    enum { 
      STT_NOTYPE = 0,
      STT_OBJECT = 1,
      STT_FUNC = 2,
      STT_SECTION = 3,
      STT_FILE = 4 
    };

    enum {
      STV_DEFAULT = 0,  // Visibility is specified by binding type
      STV_INTERNAL = 1, // Defined by processor supplements
      STV_HIDDEN = 2,   // Not visible to other components
      STV_PROTECTED = 3 // Visible in other components but not preemptable
    };

    ELFSym(const GlobalValue *gv) : GV(gv), NameIdx(0), Value(0),
                                    Size(0), Info(0), Other(0),
                                    SectionIdx(ELFSection::SHN_UNDEF) {
      if (!GV)
        return;

      switch (GV->getVisibility()) {
      default:
        assert(0 && "unknown visibility type");
      case GlobalValue::DefaultVisibility:
        Other = STV_DEFAULT;
        break;
      case GlobalValue::HiddenVisibility:
        Other = STV_HIDDEN;
        break;
      case GlobalValue::ProtectedVisibility:
        Other = STV_PROTECTED;
        break;
      }
    }

    void SetBind(unsigned X) {
      assert(X == (X & 0xF) && "Bind value out of range!");
      Info = (Info & 0x0F) | (X << 4);
    }
    void SetType(unsigned X) {
      assert(X == (X & 0xF) && "Type value out of range!");
      Info = (Info & 0xF0) | X;
    }

    static unsigned getEntrySize(bool is64Bit)
      { return is64Bit ? 24 : 16; }
  };

} // end namespace llvm

#endif
