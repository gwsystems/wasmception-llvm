//===- AsmWriterEmitter.cpp - Generate an assembly writer -----------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file was developed by the LLVM research group and is distributed under
// the University of Illinois Open Source License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This tablegen backend is emits an assembly printer for the current target.
// Note that this is currently fairly skeletal, but will grow over time.
//
//===----------------------------------------------------------------------===//

#include "AsmWriterEmitter.h"
#include "CodeGenTarget.h"
#include "Record.h"
#include <algorithm>
#include <ostream>
using namespace llvm;

static bool isIdentChar(char C) {
  return (C >= 'a' && C <= 'z') ||
         (C >= 'A' && C <= 'Z') ||
         (C >= '0' && C <= '9') ||
         C == '_';
}

namespace {
  struct AsmWriterOperand {
    enum { isLiteralTextOperand, isMachineInstrOperand } OperandType;

    /// Str - For isLiteralTextOperand, this IS the literal text.  For
    /// isMachineInstrOperand, this is the PrinterMethodName for the operand.
    std::string Str;

    /// MiOpNo - For isMachineInstrOperand, this is the operand number of the
    /// machine instruction.
    unsigned MIOpNo;

    /// OpVT - For isMachineInstrOperand, this is the value type for the
    /// operand.
    MVT::ValueType OpVT;

    AsmWriterOperand(const std::string &LitStr)
      : OperandType(isLiteralTextOperand),  Str(LitStr) {}

    AsmWriterOperand(const std::string &Printer, unsigned OpNo,
                     MVT::ValueType VT) : OperandType(isMachineInstrOperand),
                                          Str(Printer), MIOpNo(OpNo), OpVT(VT){}

    bool operator!=(const AsmWriterOperand &Other) const {
      if (OperandType != Other.OperandType || Str != Other.Str) return true;
      if (OperandType == isMachineInstrOperand)
        return MIOpNo != Other.MIOpNo || OpVT != Other.OpVT;
      return false;
    }
    bool operator==(const AsmWriterOperand &Other) const {
      return !operator!=(Other);
    }
    void EmitCode(std::ostream &OS) const;
  };

  struct AsmWriterInst {
    std::vector<AsmWriterOperand> Operands;
    const CodeGenInstruction *CGI;

    AsmWriterInst(const CodeGenInstruction &CGI, unsigned Variant);

    /// MatchesAllButOneOp - If this instruction is exactly identical to the
    /// specified instruction except for one differing operand, return the
    /// differing operand number.  Otherwise return ~0.
    unsigned MatchesAllButOneOp(const AsmWriterInst &Other) const;

  private:
    void AddLiteralString(const std::string &Str) {
      // If the last operand was already a literal text string, append this to
      // it, otherwise add a new operand.
      if (!Operands.empty() &&
          Operands.back().OperandType == AsmWriterOperand::isLiteralTextOperand)
        Operands.back().Str.append(Str);
      else
        Operands.push_back(AsmWriterOperand(Str));
    }
  };
}


void AsmWriterOperand::EmitCode(std::ostream &OS) const {
  if (OperandType == isLiteralTextOperand)
    OS << "O << \"" << Str << "\"; ";
  else
    OS << Str << "(MI, " << MIOpNo << ", MVT::" << getEnumName(OpVT) << "); ";
}


/// ParseAsmString - Parse the specified Instruction's AsmString into this
/// AsmWriterInst.
///
AsmWriterInst::AsmWriterInst(const CodeGenInstruction &CGI, unsigned Variant) {
  this->CGI = &CGI;
  bool inVariant = false;  // True if we are inside a {.|.|.} region.

  const std::string &AsmString = CGI.AsmString;
  std::string::size_type LastEmitted = 0;
  while (LastEmitted != AsmString.size()) {
    std::string::size_type DollarPos =
      AsmString.find_first_of("${|}", LastEmitted);
    if (DollarPos == std::string::npos) DollarPos = AsmString.size();

    // Emit a constant string fragment.
    if (DollarPos != LastEmitted) {
      // TODO: this should eventually handle escaping.
      AddLiteralString(std::string(AsmString.begin()+LastEmitted,
                                   AsmString.begin()+DollarPos));
      LastEmitted = DollarPos;
    } else if (AsmString[DollarPos] == '{') {
      if (inVariant)
        throw "Nested variants found for instruction '" + CGI.Name + "'!";
      LastEmitted = DollarPos+1;
      inVariant = true;   // We are now inside of the variant!
      for (unsigned i = 0; i != Variant; ++i) {
        // Skip over all of the text for an irrelevant variant here.  The
        // next variant starts at |, or there may not be text for this
        // variant if we see a }.
        std::string::size_type NP =
          AsmString.find_first_of("|}", LastEmitted);
        if (NP == std::string::npos)
          throw "Incomplete variant for instruction '" + CGI.Name + "'!";
        LastEmitted = NP+1;
        if (AsmString[NP] == '}') {
          inVariant = false;        // No text for this variant.
          break;
        }
      }
    } else if (AsmString[DollarPos] == '|') {
      if (!inVariant)
        throw "'|' character found outside of a variant in instruction '"
          + CGI.Name + "'!";
      // Move to the end of variant list.
      std::string::size_type NP = AsmString.find('}', LastEmitted);
      if (NP == std::string::npos)
        throw "Incomplete variant for instruction '" + CGI.Name + "'!";
      LastEmitted = NP+1;
      inVariant = false;
    } else if (AsmString[DollarPos] == '}') {
      if (!inVariant)
        throw "'}' character found outside of a variant in instruction '"
          + CGI.Name + "'!";
      LastEmitted = DollarPos+1;
      inVariant = false;
    } else if (DollarPos+1 != AsmString.size() &&
               AsmString[DollarPos+1] == '$') {
      AddLiteralString("$");  // "$$" -> $
      LastEmitted = DollarPos+2;
    } else {
      // Get the name of the variable.
      // TODO: should eventually handle ${foo}bar as $foo
      std::string::size_type VarEnd = DollarPos+1;
      while (VarEnd < AsmString.size() && isIdentChar(AsmString[VarEnd]))
        ++VarEnd;
      std::string VarName(AsmString.begin()+DollarPos+1,
                          AsmString.begin()+VarEnd);
      if (VarName.empty())
        throw "Stray '$' in '" + CGI.Name + "' asm string, maybe you want $$?";

      unsigned OpNo = CGI.getOperandNamed(VarName);
      CodeGenInstruction::OperandInfo OpInfo = CGI.OperandList[OpNo];

      // If this is a two-address instruction and we are not accessing the
      // 0th operand, remove an operand.
      unsigned MIOp = OpInfo.MIOperandNo;
      if (CGI.isTwoAddress && MIOp != 0) {
        if (MIOp == 1)
          throw "Should refer to operand #0 instead of #1 for two-address"
            " instruction '" + CGI.Name + "'!";
        --MIOp;
      }

      Operands.push_back(AsmWriterOperand(OpInfo.PrinterMethodName,
                                          MIOp, OpInfo.Ty));
      LastEmitted = VarEnd;
    }
  }

  AddLiteralString("\\n");
}

/// MatchesAllButOneOp - If this instruction is exactly identical to the
/// specified instruction except for one differing operand, return the differing
/// operand number.  If more than one operand mismatches, return ~1, otherwise
/// if the instructions are identical return ~0.
unsigned AsmWriterInst::MatchesAllButOneOp(const AsmWriterInst &Other)const{
  if (Operands.size() != Other.Operands.size()) return ~1;

  unsigned MismatchOperand = ~0U;
  for (unsigned i = 0, e = Operands.size(); i != e; ++i) {
    if (Operands[i] != Other.Operands[i])
      if (MismatchOperand != ~0U)  // Already have one mismatch?
        return ~1U;
      else
        MismatchOperand = i;
  }
  return MismatchOperand;
}

static void PrintCases(std::vector<std::pair<std::string,
                       AsmWriterOperand> > &OpsToPrint, std::ostream &O) {
  O << "    case " << OpsToPrint.back().first << ": ";
  AsmWriterOperand TheOp = OpsToPrint.back().second;
  OpsToPrint.pop_back();

  // Check to see if any other operands are identical in this list, and if so,
  // emit a case label for them.
  for (unsigned i = OpsToPrint.size(); i != 0; --i)
    if (OpsToPrint[i-1].second == TheOp) {
      O << "\n    case " << OpsToPrint[i-1].first << ": ";
      OpsToPrint.erase(OpsToPrint.begin()+i-1);
    }

  // Finally, emit the code.
  TheOp.EmitCode(O);
  O << "break;\n";
}


/// EmitInstructions - Emit the last instruction in the vector and any other
/// instructions that are suitably similar to it.
static void EmitInstructions(std::vector<AsmWriterInst> &Insts,
                             std::ostream &O) {
  AsmWriterInst FirstInst = Insts.back();
  Insts.pop_back();

  std::vector<AsmWriterInst> SimilarInsts;
  unsigned DifferingOperand = ~0;
  for (unsigned i = Insts.size(); i != 0; --i) {
    unsigned DiffOp = Insts[i-1].MatchesAllButOneOp(FirstInst);
    if (DiffOp != ~1U) {
      if (DifferingOperand == ~0U)  // First match!
        DifferingOperand = DiffOp;

      // If this differs in the same operand as the rest of the instructions in
      // this class, move it to the SimilarInsts list.
      if (DifferingOperand == DiffOp || DiffOp == ~0U) {
        SimilarInsts.push_back(Insts[i-1]);
        Insts.erase(Insts.begin()+i-1);
      }
    }
  }

  std::string Namespace = FirstInst.CGI->Namespace;

  O << "  case " << Namespace << "::"
    << FirstInst.CGI->TheDef->getName() << ":\n";
  for (unsigned i = 0, e = SimilarInsts.size(); i != e; ++i)
    O << "  case " << Namespace << "::"
      << SimilarInsts[i].CGI->TheDef->getName() << ":\n";
  for (unsigned i = 0, e = FirstInst.Operands.size(); i != e; ++i) {
    if (i != DifferingOperand) {
      // If the operand is the same for all instructions, just print it.
      O << "    ";
      FirstInst.Operands[i].EmitCode(O);
    } else {
      // If this is the operand that varies between all of the instructions,
      // emit a switch for just this operand now.
      O << "    switch (MI->getOpcode()) {\n";
      std::vector<std::pair<std::string, AsmWriterOperand> > OpsToPrint;
      OpsToPrint.push_back(std::make_pair(Namespace+"::"+
                                          FirstInst.CGI->TheDef->getName(),
                                          FirstInst.Operands[i]));

      for (unsigned si = 0, e = SimilarInsts.size(); si != e; ++si) {
        AsmWriterInst &AWI = SimilarInsts[si];
        OpsToPrint.push_back(std::make_pair(Namespace+"::"+
                                            AWI.CGI->TheDef->getName(),
                                            AWI.Operands[i]));
      }
      std::reverse(OpsToPrint.begin(), OpsToPrint.end());
      while (!OpsToPrint.empty())
        PrintCases(OpsToPrint, O);
      O << "    }";
    }
    O << "\n";
  }

  O << "    break;\n";
}

void AsmWriterEmitter::run(std::ostream &O) {
  EmitSourceFileHeader("Assembly Writer Source Fragment", O);

  CodeGenTarget Target;
  Record *AsmWriter = Target.getAsmWriter();
  std::string ClassName = AsmWriter->getValueAsString("AsmWriterClassName");
  unsigned Variant = AsmWriter->getValueAsInt("Variant");

  O <<
  "/// printInstruction - This method is automatically generated by tablegen\n"
  "/// from the instruction set description.  This method returns true if the\n"
  "/// machine instruction was sufficiently described to print it, otherwise\n"
  "/// it returns false.\n"
    "bool " << Target.getName() << ClassName
            << "::printInstruction(const MachineInstr *MI) {\n";

  std::string Namespace = Target.inst_begin()->second.Namespace;

  std::vector<AsmWriterInst> Instructions;

  for (CodeGenTarget::inst_iterator I = Target.inst_begin(),
         E = Target.inst_end(); I != E; ++I)
    if (!I->second.AsmString.empty())
      Instructions.push_back(AsmWriterInst(I->second, Variant));

  // If all of the instructions start with a constant string (a very very common
  // occurance), emit all of the constant strings as a big table lookup instead
  // of requiring a switch for them.
  bool AllStartWithString = true;

  for (unsigned i = 0, e = Instructions.size(); i != e; ++i)
    if (Instructions[i].Operands.empty() ||
        Instructions[i].Operands[0].OperandType !=
                          AsmWriterOperand::isLiteralTextOperand) {
      AllStartWithString = false;
      break;
    }

  if (AllStartWithString) {
    // Compute the CodeGenInstruction -> AsmWriterInst mapping.  Note that not
    // all machine instructions are necessarily being printed, so there may be
    // target instructions not in this map.
    std::map<const CodeGenInstruction*, AsmWriterInst*> CGIAWIMap;
    for (unsigned i = 0, e = Instructions.size(); i != e; ++i)
      CGIAWIMap.insert(std::make_pair(Instructions[i].CGI, &Instructions[i]));

    // Emit a table of constant strings.
    std::vector<const CodeGenInstruction*> NumberedInstructions;
    Target.getInstructionsByEnumValue(NumberedInstructions);

    O << "  static const char * const OpStrs[] = {\n";
    for (unsigned i = 0, e = NumberedInstructions.size(); i != e; ++i) {
      AsmWriterInst *AWI = CGIAWIMap[NumberedInstructions[i]];
      if (AWI == 0) {
        // Something not handled by the asmwriter printer.
        O << "    0,\t// ";
      } else {
        O << "    \"" << AWI->Operands[0].Str << "\",\t// ";
        // Nuke the string from the operand list.  It is now handled!
        AWI->Operands.erase(AWI->Operands.begin());
      }
      O << NumberedInstructions[i]->TheDef->getName() << "\n";
    }
    O << "  };\n\n"
      << "  // Emit the opcode for the instruction.\n"
      << "  if (const char *AsmStr = OpStrs[MI->getOpcode()])\n"
      << "    O << AsmStr;\n\n";
  }

  // Because this is a vector we want to emit from the end.  Reverse all of the
  // elements in the vector.
  std::reverse(Instructions.begin(), Instructions.end());

  O << "  switch (MI->getOpcode()) {\n"
       "  default: return false;\n";

  while (!Instructions.empty())
    EmitInstructions(Instructions, O);

  O << "  }\n"
       "  return true;\n"
       "}\n";
}
