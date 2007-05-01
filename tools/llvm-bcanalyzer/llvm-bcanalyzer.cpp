//===-- llvm-bcanalyzer.cpp - Byte Code Analyzer --------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file was developed by Reid Spencer and is distributed under the
// University of Illinois Open Source License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This tool may be invoked in the following manner:
//  llvm-bcanalyzer [options]      - Read LLVM bytecode from stdin
//  llvm-bcanalyzer [options] x.bc - Read LLVM bytecode from the x.bc file
//
//  Options:
//      --help      - Output information about command line switches
//      --nodetails - Don't print out detailed informaton about individual
//                    blocks and functions
//      --dump      - Dump low-level bytecode structure in readable format
//
// This tool provides analytical information about a bytecode file. It is
// intended as an aid to developers of bytecode reading and writing software. It
// produces on std::out a summary of the bytecode file that shows various
// statistics about the contents of the file. By default this information is
// detailed and contains information about individual bytecode blocks and the
// functions in the module. To avoid this more detailed output, use the
// -nodetails option to limit the output to just module level information.
// The tool is also able to print a bytecode file in a straight forward text
// format that shows the containment and relationships of the information in
// the bytecode file (-dump option).
//
//===----------------------------------------------------------------------===//

#include "llvm/Analysis/Verifier.h"
#include "llvm/Bitcode/BitstreamReader.h"
#include "llvm/Bitcode/LLVMBitCodes.h"
#include "llvm/Bytecode/Analyzer.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Compressor.h"
#include "llvm/Support/ManagedStatic.h"
#include "llvm/Support/MemoryBuffer.h"
#include "llvm/System/Signals.h"
#include <fstream>
#include <iostream>
using namespace llvm;

static cl::opt<std::string>
  InputFilename(cl::Positional, cl::desc("<input bytecode>"), cl::init("-"));

static cl::opt<std::string>
  OutputFilename("-o", cl::init("-"), cl::desc("<output file>"));

static cl::opt<bool> NoDetails("nodetails", cl::desc("Skip detailed output"));
static cl::opt<bool> Dump("dump", cl::desc("Dump low level bytecode trace"));
static cl::opt<bool> Verify("verify", cl::desc("Progressively verify module"));

//===----------------------------------------------------------------------===//
// Bitcode specific analysis.
//===----------------------------------------------------------------------===//

static cl::opt<bool> Bitcode("bitcode", cl::desc("Read a bitcode file"));

static cl::opt<bool>
NonSymbolic("non-symbolic",
            cl::desc("Emit numberic info in dump even if"
                     " symbolic info is available"));

/// CurStreamType - If we can sniff the flavor of this stream, we can produce 
/// better dump info.
static enum {
  UnknownBitstream,
  LLVMIRBitstream
} CurStreamType;


/// GetBlockName - Return a symbolic block name if known, otherwise return
/// null.
static const char *GetBlockName(unsigned BlockID) {
  if (CurStreamType != LLVMIRBitstream) return 0;
  
  switch (BlockID) {
  default:                          return 0;
  case bitc::MODULE_BLOCK_ID:       return "MODULE_BLOCK";
  case bitc::TYPE_BLOCK_ID:         return "TYPE_BLOCK";
  case bitc::CONSTANTS_BLOCK_ID:    return "CONSTANTS_BLOCK";
  case bitc::FUNCTION_BLOCK_ID:     return "FUNCTION_BLOCK";
  case bitc::TYPE_SYMTAB_BLOCK_ID:  return "TYPE_SYMTAB";
  case bitc::VALUE_SYMTAB_BLOCK_ID: return "VALUE_SYMTAB";
  }
}

/// GetCodeName - Return a symbolic code name if known, otherwise return
/// null.
static const char *GetCodeName(unsigned CodeID, unsigned BlockID) {
  if (CurStreamType != LLVMIRBitstream) return 0;
  
  switch (BlockID) {
  default: return 0;
  case bitc::MODULE_BLOCK_ID:
    switch (CodeID) {
    default: return 0;
    case bitc::MODULE_CODE_VERSION:     return "VERSION";
    case bitc::MODULE_CODE_TRIPLE:      return "TRIPLE";
    case bitc::MODULE_CODE_DATALAYOUT:  return "DATALAYOUT";
    case bitc::MODULE_CODE_ASM:         return "ASM";
    case bitc::MODULE_CODE_SECTIONNAME: return "SECTIONNAME";
    case bitc::MODULE_CODE_DEPLIB:      return "DEPLIB";
    case bitc::MODULE_CODE_GLOBALVAR:   return "GLOBALVAR";
    case bitc::MODULE_CODE_FUNCTION:    return "FUNCTION";
    case bitc::MODULE_CODE_ALIAS:       return "ALIAS";
    case bitc::MODULE_CODE_PURGEVALS:   return "PURGEVALS";
    }
  case bitc::TYPE_BLOCK_ID:
    switch (CodeID) {
    default: return 0;
    case bitc::TYPE_CODE_NUMENTRY: return "NUMENTRY";
    case bitc::TYPE_CODE_META:     return "META";
    case bitc::TYPE_CODE_VOID:     return "VOID";
    case bitc::TYPE_CODE_FLOAT:    return "FLOAT";
    case bitc::TYPE_CODE_DOUBLE:   return "DOUBLE";
    case bitc::TYPE_CODE_LABEL:    return "LABEL";
    case bitc::TYPE_CODE_OPAQUE:   return "OPAQUE";
    case bitc::TYPE_CODE_INTEGER:  return "INTEGER";
    case bitc::TYPE_CODE_POINTER:  return "POINTER";
    case bitc::TYPE_CODE_FUNCTION: return "FUNCTION";
    case bitc::TYPE_CODE_STRUCT:   return "STRUCT";
    case bitc::TYPE_CODE_ARRAY:    return "ARRAY";
    case bitc::TYPE_CODE_VECTOR:   return "VECTOR";
    }
    
  case bitc::CONSTANTS_BLOCK_ID:
    switch (CodeID) {
    default: return 0;
    case bitc::CST_CODE_SETTYPE:       return "SETTYPE";
    case bitc::CST_CODE_NULL:          return "NULL";
    case bitc::CST_CODE_UNDEF:         return "UNDEF";
    case bitc::CST_CODE_INTEGER:       return "INTEGER";
    case bitc::CST_CODE_WIDE_INTEGER:  return "WIDE_INTEGER";
    case bitc::CST_CODE_FLOAT:         return "FLOAT";
    case bitc::CST_CODE_AGGREGATE:     return "AGGREGATE";
    case bitc::CST_CODE_CE_BINOP:      return "CE_BINOP";
    case bitc::CST_CODE_CE_CAST:       return "CE_CAST";
    case bitc::CST_CODE_CE_GEP:        return "CE_GEP";
    case bitc::CST_CODE_CE_SELECT:     return "CE_SELECT";
    case bitc::CST_CODE_CE_EXTRACTELT: return "CE_EXTRACTELT";
    case bitc::CST_CODE_CE_INSERTELT:  return "CE_INSERTELT";
    case bitc::CST_CODE_CE_SHUFFLEVEC: return "CE_SHUFFLEVEC";
    case bitc::CST_CODE_CE_CMP:        return "CE_CMP";
    }        
  case bitc::FUNCTION_BLOCK_ID:
    switch (CodeID) {
    default: return 0;
    case bitc::FUNC_CODE_DECLAREBLOCKS: return "DECLAREBLOCKS";
    
    case bitc::FUNC_CODE_INST_BINOP:       return "INST_BINOP";
    case bitc::FUNC_CODE_INST_CAST:        return "INST_CAST";
    case bitc::FUNC_CODE_INST_GEP:         return "INST_GEP";
    case bitc::FUNC_CODE_INST_SELECT:      return "INST_SELECT";
    case bitc::FUNC_CODE_INST_EXTRACTELT:  return "INST_EXTRACTELT";
    case bitc::FUNC_CODE_INST_INSERTELT:   return "INST_INSERTELT";
    case bitc::FUNC_CODE_INST_SHUFFLEVEC:  return "INST_SHUFFLEVEC";
    case bitc::FUNC_CODE_INST_CMP:         return "INST_CMP";
    
    case bitc::FUNC_CODE_INST_RET:         return "INST_RET";
    case bitc::FUNC_CODE_INST_BR:          return "INST_BR";
    case bitc::FUNC_CODE_INST_SWITCH:      return "INST_SWITCH";
    case bitc::FUNC_CODE_INST_INVOKE:      return "INST_INVOKE";
    case bitc::FUNC_CODE_INST_UNWIND:      return "INST_UNWIND";
    case bitc::FUNC_CODE_INST_UNREACHABLE: return "INST_UNREACHABLE";
    
    case bitc::FUNC_CODE_INST_PHI:         return "INST_PHI";
    case bitc::FUNC_CODE_INST_MALLOC:      return "INST_MALLOC";
    case bitc::FUNC_CODE_INST_FREE:        return "INST_FREE";
    case bitc::FUNC_CODE_INST_ALLOCA:      return "INST_ALLOCA";
    case bitc::FUNC_CODE_INST_LOAD:        return "INST_LOAD";
    case bitc::FUNC_CODE_INST_STORE:       return "INST_STORE";
    case bitc::FUNC_CODE_INST_CALL:        return "INST_CALL";
    case bitc::FUNC_CODE_INST_VAARG:       return "INST_VAARG";
    }
  case bitc::TYPE_SYMTAB_BLOCK_ID:
    switch (CodeID) {
    default: return 0;
    case bitc::TST_CODE_ENTRY: return "ENTRY";
    }
  case bitc::VALUE_SYMTAB_BLOCK_ID:
    switch (CodeID) {
    default: return 0;
    case bitc::VST_CODE_ENTRY: return "ENTRY";
    }
  }
}


struct PerBlockIDStats {
  /// NumInstances - This the number of times this block ID has been seen.
  unsigned NumInstances;
  
  /// NumBits - The total size in bits of all of these blocks.
  uint64_t NumBits;
  
  /// NumSubBlocks - The total number of blocks these blocks contain.
  unsigned NumSubBlocks;
  
  /// NumAbbrevs - The total number of abbreviations.
  unsigned NumAbbrevs;
  
  /// NumRecords - The total number of records these blocks contain, and the 
  /// number that are abbreviated.
  unsigned NumRecords, NumAbbreviatedRecords;
  
  PerBlockIDStats()
    : NumInstances(0), NumBits(0),
      NumSubBlocks(0), NumAbbrevs(0), NumRecords(0), NumAbbreviatedRecords(0) {}
};

static std::map<unsigned, PerBlockIDStats> BlockIDStats;



/// Error - All bitcode analysis errors go through this function, making this a
/// good place to breakpoint if debugging.
static bool Error(const std::string &Err) {
  std::cerr << Err << "\n";
  return true;
}

/// ParseBlock - Read a block, updating statistics, etc.
static bool ParseBlock(BitstreamReader &Stream, unsigned IndentLevel) {
  uint64_t BlockBitStart = Stream.GetCurrentBitNo();
  unsigned BlockID = Stream.ReadSubBlockID();

  // Get the statistics for this BlockID.
  PerBlockIDStats &BlockStats = BlockIDStats[BlockID];
  
  BlockStats.NumInstances++;
  
  unsigned NumWords = 0;
  if (Stream.EnterSubBlock(&NumWords))
    return Error("Malformed block record");

  std::string Indent(IndentLevel*2, ' ');
  const char *BlockName = 0;
  if (Dump) {
    std::cerr << Indent << "<";
    if ((BlockName = GetBlockName(BlockID)))
      std::cerr << BlockName;
    else
      std::cerr << "UnknownBlock" << BlockID;
    
    if (NonSymbolic && BlockName)
      std::cerr << " BlockID=" << BlockID;
    
    std::cerr << " NumWords=" << NumWords
              << " BlockCodeSize=" << Stream.GetAbbrevIDWidth() << ">\n";
  }
  
  SmallVector<uint64_t, 64> Record;

  // Read all the records for this block.
  while (1) {
    if (Stream.AtEndOfStream())
      return Error("Premature end of bitstream");

    // Read the code for this record.
    unsigned AbbrevID = Stream.ReadCode();
    switch (AbbrevID) {
    case bitc::END_BLOCK: {
      if (Stream.ReadBlockEnd())
        return Error("Error at end of block");
      uint64_t BlockBitEnd = Stream.GetCurrentBitNo();
      BlockStats.NumBits += BlockBitEnd-BlockBitStart;
      if (Dump) {
        std::cerr << Indent << "</";
        if (BlockName)
          std::cerr << BlockName << ">\n";
        else
          std::cerr << "UnknownBlock" << BlockID << ">\n";
      }
      return false;
    } 
    case bitc::ENTER_SUBBLOCK:
      if (ParseBlock(Stream, IndentLevel+1))
        return true;
      ++BlockStats.NumSubBlocks;
      break;
    case bitc::DEFINE_ABBREV:
      Stream.ReadAbbrevRecord();
      ++BlockStats.NumAbbrevs;
      break;
    default:
      ++BlockStats.NumRecords;
      if (AbbrevID != bitc::UNABBREV_RECORD)
        ++BlockStats.NumAbbreviatedRecords;
      
      Record.clear();
      unsigned Code = Stream.ReadRecord(AbbrevID, Record);
      // TODO: Compute per-blockid/code stats.
      
      if (Dump) {
        std::cerr << Indent << "  <";
        if (const char *CodeName = GetCodeName(Code, BlockID))
          std::cerr << CodeName;
        else
          std::cerr << "UnknownCode" << Code;
        if (NonSymbolic && GetCodeName(Code, BlockID))
          std::cerr << " codeid=" << Code;
        if (AbbrevID != bitc::UNABBREV_RECORD)
          std::cerr << " abbrevid=" << AbbrevID;

        for (unsigned i = 0, e = Record.size(); i != e; ++i)
          std::cerr << " op" << i << "=" << (int64_t)Record[i];
        
        std::cerr << ">\n";
      }
      
      break;
    }
  }
}

static void PrintSize(double Bits) {
  std::cerr << Bits << "b/" << Bits/8 << "B/" << Bits/32 << "W";
}


/// AnalyzeBitcode - Analyze the bitcode file specified by InputFilename.
static int AnalyzeBitcode() {
  // Read the input file.
  MemoryBuffer *Buffer;
  if (InputFilename == "-")
    Buffer = MemoryBuffer::getSTDIN();
  else
    Buffer = MemoryBuffer::getFile(&InputFilename[0], InputFilename.size());

  if (Buffer == 0)
    return Error("Error reading '" + InputFilename + "'.");
  
  if (Buffer->getBufferSize() & 3)
    return Error("Bitcode stream should be a multiple of 4 bytes in length");
  
  unsigned char *BufPtr = (unsigned char *)Buffer->getBufferStart();
  BitstreamReader Stream(BufPtr, BufPtr+Buffer->getBufferSize());

  
  // Read the stream signature.
  char Signature[6];
  Signature[0] = Stream.Read(8);
  Signature[1] = Stream.Read(8);
  Signature[2] = Stream.Read(4);
  Signature[3] = Stream.Read(4);
  Signature[4] = Stream.Read(4);
  Signature[5] = Stream.Read(4);
  
  // Autodetect the file contents, if it is one we know.
  CurStreamType = UnknownBitstream;
  if (Signature[0] == 'B' && Signature[1] == 'C' &&
      Signature[2] == 0x0 && Signature[3] == 0xC &&
      Signature[4] == 0xE && Signature[5] == 0xD)
    CurStreamType = LLVMIRBitstream;

  unsigned NumTopBlocks = 0;
  
  // Parse the top-level structure.  We only allow blocks at the top-level.
  while (!Stream.AtEndOfStream()) {
    unsigned Code = Stream.ReadCode();
    if (Code != bitc::ENTER_SUBBLOCK)
      return Error("Invalid record at top-level");
    
    if (ParseBlock(Stream, 0))
      return true;
    ++NumTopBlocks;
  }
  
  if (Dump) std::cerr << "\n\n";
  
  uint64_t BufferSizeBits = Buffer->getBufferSize()*8;
  // Print a summary of the read file.
  std::cerr << "Summary of " << InputFilename << ":\n";
  std::cerr << "         Total size: ";
  PrintSize(BufferSizeBits);
  std::cerr << "\n";
  std::cerr << "        Stream type: ";
  switch (CurStreamType) {
  default: assert(0 && "Unknown bitstream type");
  case UnknownBitstream: std::cerr << "unknown\n"; break;
  case LLVMIRBitstream:  std::cerr << "LLVM IR\n"; break;
  }
  std::cerr << "  # Toplevel Blocks: " << NumTopBlocks << "\n";
  std::cerr << "\n";

  // Emit per-block stats.
  std::cerr << "Per-block Summary:\n";
  for (std::map<unsigned, PerBlockIDStats>::iterator I = BlockIDStats.begin(),
       E = BlockIDStats.end(); I != E; ++I) {
    std::cerr << "  Block ID #" << I->first;
    if (const char *BlockName = GetBlockName(I->first))
      std::cerr << " (" << BlockName << ")";
    std::cerr << ":\n";
    
    const PerBlockIDStats &Stats = I->second;
    std::cerr << "      Num Instances: " << Stats.NumInstances << "\n";
    std::cerr << "         Total Size: ";
    PrintSize(Stats.NumBits);
    std::cerr << "\n";
    std::cerr << "       Average Size: ";
    PrintSize(Stats.NumBits/(double)Stats.NumInstances);
    std::cerr << "\n";
    std::cerr << "          % of file: "
              << Stats.NumBits/(double)BufferSizeBits*100 << "\n";
    std::cerr << "  Tot/Avg SubBlocks: " << Stats.NumSubBlocks << "/"
              << Stats.NumSubBlocks/(double)Stats.NumInstances << "\n";
    std::cerr << "    Tot/Avg Abbrevs: " << Stats.NumAbbrevs << "/"
              << Stats.NumAbbrevs/(double)Stats.NumInstances << "\n";
    std::cerr << "    Tot/Avg Records: " << Stats.NumRecords << "/"
              << Stats.NumRecords/(double)Stats.NumInstances << "\n";
    std::cerr << "      % Abbrev Recs: " << (Stats.NumAbbreviatedRecords/
                 (double)Stats.NumRecords)*100 << "\n";
    std::cerr << "\n";
  }
  return 0;
}


//===----------------------------------------------------------------------===//
// Bytecode specific analysis.
//===----------------------------------------------------------------------===//

int main(int argc, char **argv) {
  llvm_shutdown_obj X;  // Call llvm_shutdown() on exit.
  cl::ParseCommandLineOptions(argc, argv, " llvm-bcanalyzer file analyzer\n");
  
  sys::PrintStackTraceOnErrorSignal();
  
  if (Bitcode)
    return AnalyzeBitcode();
    
  try {
    std::ostream *Out = &std::cout;  // Default to printing to stdout...
    std::string ErrorMessage;
    BytecodeAnalysis bca;

    /// Determine what to generate
    bca.detailedResults = !NoDetails;
    bca.progressiveVerify = Verify;

    /// Analyze the bytecode file
    Module* M = AnalyzeBytecodeFile(InputFilename, bca, 
                                    Compressor::decompressToNewBuffer,
                                    &ErrorMessage, (Dump?Out:0));

    // All that bcanalyzer does is write the gathered statistics to the output
    PrintBytecodeAnalysis(bca,*Out);

    if (M && Verify) {
      std::string verificationMsg;
      if (verifyModule(*M, ReturnStatusAction, &verificationMsg))
        std::cerr << "Final Verification Message: " << verificationMsg << "\n";
    }

    if (Out != &std::cout) {
      ((std::ofstream*)Out)->close();
      delete Out;
    }
    return 0;
  } catch (const std::string& msg) {
    std::cerr << argv[0] << ": " << msg << "\n";
  } catch (...) {
    std::cerr << argv[0] << ": Unexpected unknown exception occurred.\n";
  }
  return 1;
}
