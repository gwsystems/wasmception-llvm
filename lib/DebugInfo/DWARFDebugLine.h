//===-- DWARFDebugLine.h ----------------------------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_DEBUGINFO_DWARFDEBUGLINE_H
#define LLVM_DEBUGINFO_DWARFDEBUGLINE_H

#include "DWARFRelocMap.h"
#include "llvm/Support/DataExtractor.h"
#include <map>
#include <string>
#include <vector>

namespace llvm {

class raw_ostream;

class DWARFDebugLine {
public:
  DWARFDebugLine(const RelocAddrMap* LineInfoRelocMap) : RelocMap(LineInfoRelocMap) {}
  struct FileNameEntry {
    FileNameEntry() : Name(nullptr), DirIdx(0), ModTime(0), Length(0) {}

    const char *Name;
    uint64_t DirIdx;
    uint64_t ModTime;
    uint64_t Length;
  };

  struct Prologue {
    Prologue()
        : TotalLength(0), Version(0), PrologueLength(0), MinInstLength(0),
          MaxOpsPerInst(0), DefaultIsStmt(0), LineBase(0), LineRange(0),
          OpcodeBase(0) {}

    // The size in bytes of the statement information for this compilation unit
    // (not including the total_length field itself).
    uint32_t TotalLength;
    // Version identifier for the statement information format.
    uint16_t Version;
    // The number of bytes following the prologue_length field to the beginning
    // of the first byte of the statement program itself.
    uint32_t PrologueLength;
    // The size in bytes of the smallest target machine instruction. Statement
    // program opcodes that alter the address register first multiply their
    // operands by this value.
    uint8_t MinInstLength;
    // The maximum number of individual operations that may be encoded in an
    // instruction.
    uint8_t MaxOpsPerInst;
    // The initial value of theis_stmtregister.
    uint8_t DefaultIsStmt;
    // This parameter affects the meaning of the special opcodes. See below.
    int8_t LineBase;
    // This parameter affects the meaning of the special opcodes. See below.
    uint8_t LineRange;
    // The number assigned to the first special opcode.
    uint8_t OpcodeBase;
    std::vector<uint8_t> StandardOpcodeLengths;
    std::vector<const char*> IncludeDirectories;
    std::vector<FileNameEntry> FileNames;

    // Length of the prologue in bytes.
    uint32_t getLength() const {
      return PrologueLength + sizeof(TotalLength) + sizeof(Version) +
             sizeof(PrologueLength);
    }
    // Length of the line table data in bytes (not including the prologue).
    uint32_t getStatementTableLength() const {
      return TotalLength + sizeof(TotalLength) - getLength();
    }
    int32_t getMaxLineIncrementForSpecialOpcode() const {
      return LineBase + (int8_t)LineRange - 1;
    }
    void dump(raw_ostream &OS) const;
    void clear() {
      TotalLength = Version = PrologueLength = 0;
      MinInstLength = LineBase = LineRange = OpcodeBase = 0;
      StandardOpcodeLengths.clear();
      IncludeDirectories.clear();
      FileNames.clear();
    }
  };

  // Standard .debug_line state machine structure.
  struct Row {
    Row(bool default_is_stmt = false) { reset(default_is_stmt); }
    /// Called after a row is appended to the matrix.
    void postAppend();
    void reset(bool default_is_stmt);
    void dump(raw_ostream &OS) const;

    static bool orderByAddress(const Row& LHS, const Row& RHS) {
      return LHS.Address < RHS.Address;
    }

    // The program-counter value corresponding to a machine instruction
    // generated by the compiler.
    uint64_t Address;
    // An unsigned integer indicating a source line number. Lines are numbered
    // beginning at 1. The compiler may emit the value 0 in cases where an
    // instruction cannot be attributed to any source line.
    uint32_t Line;
    // An unsigned integer indicating a column number within a source line.
    // Columns are numbered beginning at 1. The value 0 is reserved to indicate
    // that a statement begins at the 'left edge' of the line.
    uint16_t Column;
    // An unsigned integer indicating the identity of the source file
    // corresponding to a machine instruction.
    uint16_t File;
    // An unsigned integer whose value encodes the applicable instruction set
    // architecture for the current instruction.
    uint8_t Isa;
    // An unsigned integer representing the DWARF path discriminator value
    // for this location.
    uint32_t Discriminator;
    // A boolean indicating that the current instruction is the beginning of a
    // statement.
    uint8_t IsStmt:1,
            // A boolean indicating that the current instruction is the
            // beginning of a basic block.
            BasicBlock:1,
            // A boolean indicating that the current address is that of the
            // first byte after the end of a sequence of target machine
            // instructions.
            EndSequence:1,
            // A boolean indicating that the current address is one (of possibly
            // many) where execution should be suspended for an entry breakpoint
            // of a function.
            PrologueEnd:1,
            // A boolean indicating that the current address is one (of possibly
            // many) where execution should be suspended for an exit breakpoint
            // of a function.
            EpilogueBegin:1;
  };

  // Represents a series of contiguous machine instructions. Line table for each
  // compilation unit may consist of multiple sequences, which are not
  // guaranteed to be in the order of ascending instruction address.
  struct Sequence {
    // Sequence describes instructions at address range [LowPC, HighPC)
    // and is described by line table rows [FirstRowIndex, LastRowIndex).
    uint64_t LowPC;
    uint64_t HighPC;
    unsigned FirstRowIndex;
    unsigned LastRowIndex;
    bool Empty;

    Sequence() { reset(); }
    void reset() {
      LowPC = 0;
      HighPC = 0;
      FirstRowIndex = 0;
      LastRowIndex = 0;
      Empty = true;
    }
    static bool orderByLowPC(const Sequence& LHS, const Sequence& RHS) {
      return LHS.LowPC < RHS.LowPC;
    }
    bool isValid() const {
      return !Empty && (LowPC < HighPC) && (FirstRowIndex < LastRowIndex);
    }
    bool containsPC(uint64_t pc) const {
      return (LowPC <= pc && pc < HighPC);
    }
  };

  struct LineTable {
    void appendRow(const DWARFDebugLine::Row &state) { Rows.push_back(state); }
    void appendSequence(const DWARFDebugLine::Sequence &sequence) {
      Sequences.push_back(sequence);
    }
    void clear() {
      Prologue.clear();
      Rows.clear();
      Sequences.clear();
    }

    // Returns the index of the row with file/line info for a given address,
    // or -1 if there is no such row.
    uint32_t lookupAddress(uint64_t address) const;

    bool lookupAddressRange(uint64_t address,
                            uint64_t size, 
                            std::vector<uint32_t>& result) const;

    // Extracts filename by its index in filename table in prologue.
    // Returns true on success.
    bool getFileNameByIndex(uint64_t FileIndex,
                            bool NeedsAbsoluteFilePath,
                            std::string &Result) const;

    void dump(raw_ostream &OS) const;

    struct Prologue Prologue;
    typedef std::vector<Row> RowVector;
    typedef RowVector::const_iterator RowIter;
    typedef std::vector<Sequence> SequenceVector;
    typedef SequenceVector::const_iterator SequenceIter;
    RowVector Rows;
    SequenceVector Sequences;
  };

  struct State : public Row, public Sequence, public LineTable {
    // Special row codes.
    enum {
      StartParsingLineTable = 0,
      DoneParsingLineTable = -1
    };

    State() : row(StartParsingLineTable) {}
    virtual ~State();

    virtual void appendRowToMatrix(uint32_t offset);
    virtual void finalize();
    virtual void reset() {
      Row::reset(Prologue.DefaultIsStmt);
      Sequence::reset();
    }

    // The row number that starts at zero for the prologue, and increases for
    // each row added to the matrix.
    unsigned row;
  };

  struct DumpingState : public State {
    DumpingState(raw_ostream &OS) : OS(OS) {}
    virtual ~DumpingState();
    void finalize() override;
  private:
    raw_ostream &OS;
  };

  static bool parsePrologue(DataExtractor debug_line_data, uint32_t *offset_ptr,
                            Prologue *prologue);
  /// Parse a single line table (prologue and all rows).
  static bool parseStatementTable(DataExtractor debug_line_data,
                                  const RelocAddrMap *RMap,
                                  uint32_t *offset_ptr, State &state);

  const LineTable *getLineTable(uint32_t offset) const;
  const LineTable *getOrParseLineTable(DataExtractor debug_line_data,
                                       uint32_t offset);

private:
  typedef std::map<uint32_t, LineTable> LineTableMapTy;
  typedef LineTableMapTy::iterator LineTableIter;
  typedef LineTableMapTy::const_iterator LineTableConstIter;

  const RelocAddrMap *RelocMap;
  LineTableMapTy LineTableMap;
};

}

#endif
