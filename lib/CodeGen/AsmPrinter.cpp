//===-- AsmPrinter.cpp - Common AsmPrinter code ---------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file was developed by the LLVM research group and is distributed under
// the University of Illinois Open Source License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the AsmPrinter class.
//
//===----------------------------------------------------------------------===//

#include "llvm/CodeGen/AsmPrinter.h"
#include "llvm/Constants.h"
#include "llvm/Instruction.h"
#include "llvm/Support/Mangler.h"
#include "llvm/Target/TargetMachine.h"
using namespace llvm;

bool AsmPrinter::doInitialization(Module &M) {
  Mang = new Mangler(M, GlobalPrefix);
  return false;
}

bool AsmPrinter::doFinalization(Module &M) {
  delete Mang; Mang = 0;
  return false;
}

void AsmPrinter::setupMachineFunction(MachineFunction &MF) {
  // What's my mangled name?
  CurrentFnName = Mang->getValueName((Value*)MF.getFunction());
}

// Print out the specified constant, without a storage class.  Only the
// constants valid in constant expressions can occur here.
void AsmPrinter::emitConstantValueOnly(const Constant *CV) {
  if (CV->isNullValue())
    O << "0";
  else if (const ConstantBool *CB = dyn_cast<ConstantBool>(CV)) {
    assert(CB == ConstantBool::True);
    O << "1";
  } else if (const ConstantSInt *CI = dyn_cast<ConstantSInt>(CV))
    if (((CI->getValue() << 32) >> 32) == CI->getValue())
      O << CI->getValue();
    else
      O << (unsigned long long)CI->getValue();
  else if (const ConstantUInt *CI = dyn_cast<ConstantUInt>(CV))
    O << CI->getValue();
  else if (isa<GlobalValue>((Value*)CV))
    // This is a constant address for a global variable or function.  Use the
    // name of the variable or function as the address value.
    O << Mang->getValueName(CV);
  else if (const ConstantExpr *CE = dyn_cast<ConstantExpr>(CV)) {
    const TargetData &TD = TM.getTargetData();
    switch(CE->getOpcode()) {
    case Instruction::GetElementPtr: {
      // generate a symbolic expression for the byte address
      const Constant *ptrVal = CE->getOperand(0);
      std::vector<Value*> idxVec(CE->op_begin()+1, CE->op_end());
      if (unsigned Offset = TD.getIndexedOffset(ptrVal->getType(), idxVec)) {
        O << "(";
        emitConstantValueOnly(ptrVal);
        O << ") + " << Offset;
      } else {
        emitConstantValueOnly(ptrVal);
      }
      break;
    }
    case Instruction::Cast: {
      // Support only non-converting or widening casts for now, that is, ones
      // that do not involve a change in value.  This assertion is really gross,
      // and may not even be a complete check.
      Constant *Op = CE->getOperand(0);
      const Type *OpTy = Op->getType(), *Ty = CE->getType();

      // Remember, kids, pointers can be losslessly converted back and forth
      // into 32-bit or wider integers, regardless of signedness. :-P
      assert(((isa<PointerType>(OpTy)
               && (Ty == Type::LongTy || Ty == Type::ULongTy
                   || Ty == Type::IntTy || Ty == Type::UIntTy))
              || (isa<PointerType>(Ty)
                  && (OpTy == Type::LongTy || OpTy == Type::ULongTy
                      || OpTy == Type::IntTy || OpTy == Type::UIntTy))
              || (((TD.getTypeSize(Ty) >= TD.getTypeSize(OpTy))
                   && OpTy->isLosslesslyConvertibleTo(Ty))))
             && "FIXME: Don't yet support this kind of constant cast expr");
      O << "(";
      emitConstantValueOnly(Op);
      O << ")";
      break;
    }
    case Instruction::Add:
      O << "(";
      emitConstantValueOnly(CE->getOperand(0));
      O << ") + (";
      emitConstantValueOnly(CE->getOperand(1));
      O << ")";
      break;
    default:
      assert(0 && "Unsupported operator!");
    }
  } else {
    assert(0 && "Unknown constant value!");
  }
}

/// toOctal - Convert the low order bits of X into an octal digit.
///
static inline char toOctal(int X) {
  return (X&7)+'0';
}

/// getAsCString - Return the specified array as a C compatible string, only if
/// the predicate isString is true.
///
static void printAsCString(std::ostream &O, const ConstantArray *CVA) {
  assert(CVA->isString() && "Array is not string compatible!");

  O << "\"";
  for (unsigned i = 0; i != CVA->getNumOperands(); ++i) {
    unsigned char C = cast<ConstantInt>(CVA->getOperand(i))->getRawValue();

    if (C == '"') {
      O << "\\\"";
    } else if (C == '\\') {
      O << "\\\\";
    } else if (isprint(C)) {
      O << C;
    } else {
      switch(C) {
      case '\b': O << "\\b"; break;
      case '\f': O << "\\f"; break;
      case '\n': O << "\\n"; break;
      case '\r': O << "\\r"; break;
      case '\t': O << "\\t"; break;
      default:
        O << '\\';
        O << toOctal(C >> 6);
        O << toOctal(C >> 3);
        O << toOctal(C >> 0);
        break;
      }
    }
  }
  O << "\"";
}

/// emitGlobalConstant - Print a general LLVM constant to the .s file.
///
void AsmPrinter::emitGlobalConstant(const Constant *CV) {  
  const TargetData &TD = TM.getTargetData();

  if (CV->isNullValue()) {
    O << ZeroDirective << TD.getTypeSize(CV->getType()) << "\n";
    return;
  } else if (const ConstantArray *CVA = dyn_cast<ConstantArray>(CV)) {
    if (CVA->isString()) {
      O << AsciiDirective;
      printAsCString(O, CVA);
      O << "\n";
    } else { // Not a string.  Print the values in successive locations
      for (unsigned i = 0, e = CVA->getNumOperands(); i != e; ++i)
        emitGlobalConstant(CVA->getOperand(i));
    }
    return;
  } else if (const ConstantStruct *CVS = dyn_cast<ConstantStruct>(CV)) {
    // Print the fields in successive locations. Pad to align if needed!
    const StructLayout *cvsLayout = TD.getStructLayout(CVS->getType());
    unsigned sizeSoFar = 0;
    for (unsigned i = 0, e = CVS->getNumOperands(); i != e; ++i) {
      const Constant* field = CVS->getOperand(i);

      // Check if padding is needed and insert one or more 0s.
      unsigned fieldSize = TD.getTypeSize(field->getType());
      unsigned padSize = ((i == e-1? cvsLayout->StructSize
                           : cvsLayout->MemberOffsets[i+1])
                          - cvsLayout->MemberOffsets[i]) - fieldSize;
      sizeSoFar += fieldSize + padSize;

      // Now print the actual field value
      emitGlobalConstant(field);

      // Insert the field padding unless it's zero bytes...
      if (padSize)
        O << ZeroDirective << padSize << "\n";      
    }
    assert(sizeSoFar == cvsLayout->StructSize &&
           "Layout of constant struct may be incorrect!");
    return;
  } else if (const ConstantFP *CFP = dyn_cast<ConstantFP>(CV)) {
    // FP Constants are printed as integer constants to avoid losing
    // precision...
    double Val = CFP->getValue();
    if (CFP->getType() == Type::DoubleTy) {
      union DU {                            // Abide by C TBAA rules
        double FVal;
        uint64_t UVal;
      } U;
      U.FVal = Val;

      if (Data64bitsDirective)
        O << Data64bitsDirective << U.UVal << "\n";
      else if (TD.isBigEndian()) {
        O << Data32bitsDirective << unsigned(U.UVal >> 32)
          << "\t" << CommentChar << " double most significant word "
          << Val << "\n";
        O << Data32bitsDirective << unsigned(U.UVal)
          << "\t" << CommentChar << " double least significant word "
          << Val << "\n";
      } else {
        O << Data32bitsDirective << unsigned(U.UVal)
          << "\t" << CommentChar << " double least significant word " << Val
          << "\n";
        O << Data32bitsDirective << unsigned(U.UVal >> 32)
          << "\t" << CommentChar << " double most significant word " << Val
          << "\n";
      }
      return;
    } else {
      union FU {                            // Abide by C TBAA rules
        float FVal;
        int32_t UVal;
      } U;
      U.FVal = Val;
      
      O << Data32bitsDirective << U.UVal << "\t" << CommentChar
        << " float " << Val << "\n";
      return;
    }
  } else if (CV->getType() == Type::ULongTy || CV->getType() == Type::LongTy) {
    if (const ConstantInt *CI = dyn_cast<ConstantInt>(CV)) {
      uint64_t Val = CI->getRawValue();
        
      if (Data64bitsDirective)
        O << Data64bitsDirective << Val << "\n";
      else if (TD.isBigEndian()) {
        O << Data32bitsDirective << unsigned(Val >> 32)
          << "\t" << CommentChar << " Double-word most significant word "
          << Val << "\n";
        O << Data32bitsDirective << unsigned(Val)
          << "\t" << CommentChar << " Double-word least significant word "
          << Val << "\n";
      } else {
        O << Data32bitsDirective << unsigned(Val)
          << "\t" << CommentChar << " Double-word least significant word "
          << Val << "\n";
        O << Data32bitsDirective << unsigned(Val >> 32)
          << "\t" << CommentChar << " Double-word most significant word "
          << Val << "\n";
      }
      return;
    }
  }

  const Type *type = CV->getType();
  switch (type->getTypeID()) {
  case Type::UByteTyID: case Type::SByteTyID:
    O << Data8bitsDirective;
    break;
  case Type::UShortTyID: case Type::ShortTyID:
    O << Data16bitsDirective;
    break;
  case Type::BoolTyID: 
  case Type::PointerTyID:
  case Type::UIntTyID: case Type::IntTyID:
    O << Data32bitsDirective;
    break;
  case Type::ULongTyID: case Type::LongTyID:    
    assert (0 && "Should have already output double-word constant.");
  case Type::FloatTyID: case Type::DoubleTyID:
    assert (0 && "Should have already output floating point constant.");
  default:
    assert (0 && "Can't handle printing this type of thing");
    break;
  }
  emitConstantValueOnly(CV);
  O << "\n";
}
