//===- SetTheory.cpp - Generate ordered sets from DAG expressions ---------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the SetTheory class that computes ordered sets of
// Records from DAG expressions.
//
//===----------------------------------------------------------------------===//

#include "llvm/Support/Format.h"
#include "llvm/TableGen/Error.h"
#include "llvm/TableGen/Record.h"
#include "llvm/TableGen/SetTheory.h"

using namespace llvm;

// Define the standard operators.
namespace {

typedef SetTheory::RecSet RecSet;
typedef SetTheory::RecVec RecVec;

// (add a, b, ...) Evaluate and union all arguments.
struct AddOp : public SetTheory::Operator {
  void apply(SetTheory &ST, DagInit *Expr, RecSet &Elts,
             ArrayRef<SMLoc> Loc) override {
    ST.evaluate(Expr->arg_begin(), Expr->arg_end(), Elts, Loc);
  }
};

// (sub Add, Sub, ...) Set difference.
struct SubOp : public SetTheory::Operator {
  void apply(SetTheory &ST, DagInit *Expr, RecSet &Elts,
             ArrayRef<SMLoc> Loc) override {
    if (Expr->arg_size() < 2)
      PrintFatalError(Loc, "Set difference needs at least two arguments: " +
        Expr->getAsString());
    RecSet Add, Sub;
    ST.evaluate(*Expr->arg_begin(), Add, Loc);
    ST.evaluate(Expr->arg_begin() + 1, Expr->arg_end(), Sub, Loc);
    for (RecSet::iterator I = Add.begin(), E = Add.end(); I != E; ++I)
      if (!Sub.count(*I))
        Elts.insert(*I);
  }
};

// (and S1, S2) Set intersection.
struct AndOp : public SetTheory::Operator {
  void apply(SetTheory &ST, DagInit *Expr, RecSet &Elts,
             ArrayRef<SMLoc> Loc) override {
    if (Expr->arg_size() != 2)
      PrintFatalError(Loc, "Set intersection requires two arguments: " +
        Expr->getAsString());
    RecSet S1, S2;
    ST.evaluate(Expr->arg_begin()[0], S1, Loc);
    ST.evaluate(Expr->arg_begin()[1], S2, Loc);
    for (RecSet::iterator I = S1.begin(), E = S1.end(); I != E; ++I)
      if (S2.count(*I))
        Elts.insert(*I);
  }
};

// SetIntBinOp - Abstract base class for (Op S, N) operators.
struct SetIntBinOp : public SetTheory::Operator {
  virtual void apply2(SetTheory &ST, DagInit *Expr, RecSet &Set, int64_t N,
                      RecSet &Elts, ArrayRef<SMLoc> Loc) = 0;

  void apply(SetTheory &ST, DagInit *Expr, RecSet &Elts,
             ArrayRef<SMLoc> Loc) override {
    if (Expr->arg_size() != 2)
      PrintFatalError(Loc, "Operator requires (Op Set, Int) arguments: " +
        Expr->getAsString());
    RecSet Set;
    ST.evaluate(Expr->arg_begin()[0], Set, Loc);
    IntInit *II = dyn_cast<IntInit>(Expr->arg_begin()[1]);
    if (!II)
      PrintFatalError(Loc, "Second argument must be an integer: " +
        Expr->getAsString());
    apply2(ST, Expr, Set, II->getValue(), Elts, Loc);
  }
};

// (shl S, N) Shift left, remove the first N elements.
struct ShlOp : public SetIntBinOp {
  void apply2(SetTheory &ST, DagInit *Expr, RecSet &Set, int64_t N,
              RecSet &Elts, ArrayRef<SMLoc> Loc) override {
    if (N < 0)
      PrintFatalError(Loc, "Positive shift required: " +
        Expr->getAsString());
    if (unsigned(N) < Set.size())
      Elts.insert(Set.begin() + N, Set.end());
  }
};

// (trunc S, N) Truncate after the first N elements.
struct TruncOp : public SetIntBinOp {
  void apply2(SetTheory &ST, DagInit *Expr, RecSet &Set, int64_t N,
              RecSet &Elts, ArrayRef<SMLoc> Loc) override {
    if (N < 0)
      PrintFatalError(Loc, "Positive length required: " +
        Expr->getAsString());
    if (unsigned(N) > Set.size())
      N = Set.size();
    Elts.insert(Set.begin(), Set.begin() + N);
  }
};

// Left/right rotation.
struct RotOp : public SetIntBinOp {
  const bool Reverse;

  RotOp(bool Rev) : Reverse(Rev) {}

  void apply2(SetTheory &ST, DagInit *Expr, RecSet &Set, int64_t N,
              RecSet &Elts, ArrayRef<SMLoc> Loc) override {
    if (Reverse)
      N = -N;
    // N > 0 -> rotate left, N < 0 -> rotate right.
    if (Set.empty())
      return;
    if (N < 0)
      N = Set.size() - (-N % Set.size());
    else
      N %= Set.size();
    Elts.insert(Set.begin() + N, Set.end());
    Elts.insert(Set.begin(), Set.begin() + N);
  }
};

// (decimate S, N) Pick every N'th element of S.
struct DecimateOp : public SetIntBinOp {
  void apply2(SetTheory &ST, DagInit *Expr, RecSet &Set, int64_t N,
              RecSet &Elts, ArrayRef<SMLoc> Loc) override {
    if (N <= 0)
      PrintFatalError(Loc, "Positive stride required: " +
        Expr->getAsString());
    for (unsigned I = 0; I < Set.size(); I += N)
      Elts.insert(Set[I]);
  }
};

// (interleave S1, S2, ...) Interleave elements of the arguments.
struct InterleaveOp : public SetTheory::Operator {
  void apply(SetTheory &ST, DagInit *Expr, RecSet &Elts,
             ArrayRef<SMLoc> Loc) override {
    // Evaluate the arguments individually.
    SmallVector<RecSet, 4> Args(Expr->getNumArgs());
    unsigned MaxSize = 0;
    for (unsigned i = 0, e = Expr->getNumArgs(); i != e; ++i) {
      ST.evaluate(Expr->getArg(i), Args[i], Loc);
      MaxSize = std::max(MaxSize, unsigned(Args[i].size()));
    }
    // Interleave arguments into Elts.
    for (unsigned n = 0; n != MaxSize; ++n)
      for (unsigned i = 0, e = Expr->getNumArgs(); i != e; ++i)
        if (n < Args[i].size())
          Elts.insert(Args[i][n]);
  }
};

// (sequence "Format", From, To) Generate a sequence of records by name.
struct SequenceOp : public SetTheory::Operator {
  void apply(SetTheory &ST, DagInit *Expr, RecSet &Elts,
             ArrayRef<SMLoc> Loc) override {
    int Step = 1;
    if (Expr->arg_size() > 4)
      PrintFatalError(Loc, "Bad args to (sequence \"Format\", From, To): " +
        Expr->getAsString());
    else if (Expr->arg_size() == 4) {
      if (IntInit *II = dyn_cast<IntInit>(Expr->arg_begin()[3])) {
        Step = II->getValue();
      } else
        PrintFatalError(Loc, "Stride must be an integer: " +
          Expr->getAsString());
    }

    std::string Format;
    if (StringInit *SI = dyn_cast<StringInit>(Expr->arg_begin()[0]))
      Format = SI->getValue();
    else
      PrintFatalError(Loc,  "Format must be a string: " + Expr->getAsString());

    int64_t From, To;
    if (IntInit *II = dyn_cast<IntInit>(Expr->arg_begin()[1]))
      From = II->getValue();
    else
      PrintFatalError(Loc, "From must be an integer: " + Expr->getAsString());
    if (From < 0 || From >= (1 << 30))
      PrintFatalError(Loc, "From out of range");

    if (IntInit *II = dyn_cast<IntInit>(Expr->arg_begin()[2]))
      To = II->getValue();
    else
      PrintFatalError(Loc, "From must be an integer: " + Expr->getAsString());
    if (To < 0 || To >= (1 << 30))
      PrintFatalError(Loc, "To out of range");

    RecordKeeper &Records =
      cast<DefInit>(Expr->getOperator())->getDef()->getRecords();

    Step *= From <= To ? 1 : -1;
    while (true) {
      if (Step > 0 && From > To)
        break;
      else if (Step < 0 && From < To)
        break;
      std::string Name;
      raw_string_ostream OS(Name);
      OS << format(Format.c_str(), unsigned(From));
      Record *Rec = Records.getDef(OS.str());
      if (!Rec)
        PrintFatalError(Loc, "No def named '" + Name + "': " +
          Expr->getAsString());
      // Try to reevaluate Rec in case it is a set.
      if (const RecVec *Result = ST.expand(Rec))
        Elts.insert(Result->begin(), Result->end());
      else
        Elts.insert(Rec);

      From += Step;
    }
  }
};

// Expand a Def into a set by evaluating one of its fields.
struct FieldExpander : public SetTheory::Expander {
  StringRef FieldName;

  FieldExpander(StringRef fn) : FieldName(fn) {}

  void expand(SetTheory &ST, Record *Def, RecSet &Elts) override {
    ST.evaluate(Def->getValueInit(FieldName), Elts, Def->getLoc());
  }
};
} // end anonymous namespace

// Pin the vtables to this file.
void SetTheory::Operator::anchor() {}
void SetTheory::Expander::anchor() {}


SetTheory::SetTheory() {
  addOperator("add", new AddOp);
  addOperator("sub", new SubOp);
  addOperator("and", new AndOp);
  addOperator("shl", new ShlOp);
  addOperator("trunc", new TruncOp);
  addOperator("rotl", new RotOp(false));
  addOperator("rotr", new RotOp(true));
  addOperator("decimate", new DecimateOp);
  addOperator("interleave", new InterleaveOp);
  addOperator("sequence", new SequenceOp);
}

void SetTheory::addOperator(StringRef Name, Operator *Op) {
  Operators[Name] = Op;
}

void SetTheory::addExpander(StringRef ClassName, Expander *E) {
  Expanders[ClassName] = E;
}

void SetTheory::addFieldExpander(StringRef ClassName, StringRef FieldName) {
  addExpander(ClassName, new FieldExpander(FieldName));
}

void SetTheory::evaluate(Init *Expr, RecSet &Elts, ArrayRef<SMLoc> Loc) {
  // A def in a list can be a just an element, or it may expand.
  if (DefInit *Def = dyn_cast<DefInit>(Expr)) {
    if (const RecVec *Result = expand(Def->getDef()))
      return Elts.insert(Result->begin(), Result->end());
    Elts.insert(Def->getDef());
    return;
  }

  // Lists simply expand.
  if (ListInit *LI = dyn_cast<ListInit>(Expr))
    return evaluate(LI->begin(), LI->end(), Elts, Loc);

  // Anything else must be a DAG.
  DagInit *DagExpr = dyn_cast<DagInit>(Expr);
  if (!DagExpr)
    PrintFatalError(Loc, "Invalid set element: " + Expr->getAsString());
  DefInit *OpInit = dyn_cast<DefInit>(DagExpr->getOperator());
  if (!OpInit)
    PrintFatalError(Loc, "Bad set expression: " + Expr->getAsString());
  Operator *Op = Operators.lookup(OpInit->getDef()->getName());
  if (!Op)
    PrintFatalError(Loc, "Unknown set operator: " + Expr->getAsString());
  Op->apply(*this, DagExpr, Elts, Loc);
}

const RecVec *SetTheory::expand(Record *Set) {
  // Check existing entries for Set and return early.
  ExpandMap::iterator I = Expansions.find(Set);
  if (I != Expansions.end())
    return &I->second;

  // This is the first time we see Set. Find a suitable expander.
  const std::vector<Record*> &SC = Set->getSuperClasses();
  for (unsigned i = 0, e = SC.size(); i != e; ++i) {
    // Skip unnamed superclasses.
    if (!dyn_cast<StringInit>(SC[i]->getNameInit()))
      continue;
    if (Expander *Exp = Expanders.lookup(SC[i]->getName())) {
      // This breaks recursive definitions.
      RecVec &EltVec = Expansions[Set];
      RecSet Elts;
      Exp->expand(*this, Set, Elts);
      EltVec.assign(Elts.begin(), Elts.end());
      return &EltVec;
    }
  }

  // Set is not expandable.
  return nullptr;
}

