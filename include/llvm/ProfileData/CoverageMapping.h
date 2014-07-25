//=-- CoverageMapping.h - Code coverage mapping support ---------*- C++ -*-=//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// Code coverage mapping data is generated by clang and read by
// llvm-cov to show code coverage statistics for a file.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_PROFILEDATA_COVERAGEMAPPING_H_
#define LLVM_PROFILEDATA_COVERAGEMAPPING_H_

#include "llvm/ADT/ArrayRef.h"
#include "llvm/Support/raw_ostream.h"
#include <system_error>

namespace llvm {
namespace coverage {

struct CounterExpressions;

enum CoverageMappingVersion { CoverageMappingVersion1 };

/// \brief A Counter is an abstract value that describes how to compute the
/// execution count for a region of code using the collected profile count data.
struct Counter {
  enum CounterKind { Zero, CounterValueReference, Expression };
  static const unsigned EncodingTagBits = 2;
  static const unsigned EncodingTagMask = 0x3;
  static const unsigned EncodingCounterTagAndExpansionRegionTagBits =
      EncodingTagBits + 1;

private:
  CounterKind Kind;
  unsigned ID;

  Counter(CounterKind Kind, unsigned ID) : Kind(Kind), ID(ID) {}

public:
  Counter() : Kind(Zero), ID(0) {}

  CounterKind getKind() const { return Kind; }

  bool isZero() const { return Kind == Zero; }

  bool isExpression() const { return Kind == Expression; }

  unsigned getCounterID() const { return ID; }

  unsigned getExpressionID() const { return ID; }

  bool operator==(const Counter &Other) const {
    return Kind == Other.Kind && ID == Other.ID;
  }

  /// \brief Return the counter that represents the number zero.
  static Counter getZero() { return Counter(); }

  /// \brief Return the counter that corresponds to a specific profile counter.
  static Counter getCounter(unsigned CounterId) {
    return Counter(CounterValueReference, CounterId);
  }

  /// \brief Return the counter that corresponds to a specific
  /// addition counter expression.
  static Counter getExpression(unsigned ExpressionId) {
    return Counter(Expression, ExpressionId);
  }
};

/// \brief A Counter expression is a value that represents an arithmetic
/// operation with two counters.
struct CounterExpression {
  enum ExprKind { Subtract, Add };
  ExprKind Kind;
  Counter LHS, RHS;

  CounterExpression(ExprKind Kind, Counter LHS, Counter RHS)
      : Kind(Kind), LHS(LHS), RHS(RHS) {}

  bool operator==(const CounterExpression &Other) const {
    return Kind == Other.Kind && LHS == Other.LHS && RHS == Other.RHS;
  }
};

/// \brief A Counter expression builder is used to construct the
/// counter expressions. It avoids unecessary duplication
/// and simplifies algebraic expressions.
class CounterExpressionBuilder {
  /// \brief A list of all the counter expressions
  llvm::SmallVector<CounterExpression, 16> Expressions;
  /// \brief An array of terms used in expression simplification.
  llvm::SmallVector<int, 16> Terms;

  /// \brief Return the counter which corresponds to the given expression.
  ///
  /// If the given expression is already stored in the builder, a counter
  /// that references that expression is returned. Otherwise, the given
  /// expression is added to the builder's collection of expressions.
  Counter get(const CounterExpression &E);

  /// \brief Convert the expression tree represented by a counter
  /// into a polynomial in the form of K1Counter1 + .. + KNCounterN
  /// where K1 .. KN are integer constants that are stored in the Terms array.
  void extractTerms(Counter C, int Sign = 1);

  /// \brief Simplifies the given expression tree
  /// by getting rid of algebraically redundant operations.
  Counter simplify(Counter ExpressionTree);

public:
  CounterExpressionBuilder(unsigned NumCounterValues);

  ArrayRef<CounterExpression> getExpressions() const { return Expressions; }

  /// \brief Return a counter that represents the expression
  /// that adds LHS and RHS.
  Counter add(Counter LHS, Counter RHS);

  /// \brief Return a counter that represents the expression
  /// that subtracts RHS from LHS.
  Counter subtract(Counter LHS, Counter RHS);
};

/// \brief A Counter mapping region associates a source range with
/// a specific counter.
struct CounterMappingRegion {
  enum RegionKind {
    /// \brief A CodeRegion associates some code with a counter
    CodeRegion,

    /// \brief An ExpansionRegion represents a file expansion region that
    /// associates a source range with the expansion of a virtual source file,
    /// such as for a macro instantiation or #include file.
    ExpansionRegion,

    /// \brief A SkippedRegion represents a source range with code that
    /// was skipped by a preprocessor or similar means.
    SkippedRegion
  };

  Counter Count;
  unsigned FileID, ExpandedFileID;
  unsigned LineStart, ColumnStart, LineEnd, ColumnEnd;
  RegionKind Kind;

  CounterMappingRegion(Counter Count, unsigned FileID, unsigned LineStart,
                       unsigned ColumnStart, unsigned LineEnd,
                       unsigned ColumnEnd, RegionKind Kind = CodeRegion)
      : Count(Count), FileID(FileID), ExpandedFileID(0), LineStart(LineStart),
        ColumnStart(ColumnStart), LineEnd(LineEnd), ColumnEnd(ColumnEnd),
        Kind(Kind) {}

  bool operator<(const CounterMappingRegion &Other) const {
    if (FileID != Other.FileID)
      return FileID < Other.FileID;
    if (LineStart == Other.LineStart)
      return ColumnStart < Other.ColumnStart;
    return LineStart < Other.LineStart;
  }
};

/// \brief A Counter mapping context is used to connect the counters,
/// expressions and the obtained counter values.
class CounterMappingContext {
  ArrayRef<CounterExpression> Expressions;
  ArrayRef<uint64_t> CounterValues;

public:
  CounterMappingContext(ArrayRef<CounterExpression> Expressions,
                        ArrayRef<uint64_t> CounterValues = ArrayRef<uint64_t>())
      : Expressions(Expressions), CounterValues(CounterValues) {}

  void dump(const Counter &C, llvm::raw_ostream &OS) const;
  void dump(const Counter &C) const { dump(C, llvm::outs()); }

  /// \brief Return the number of times that a region of code
  /// associated with this counter was executed.
  int64_t evaluate(const Counter &C, std::error_code *Error) const;
  int64_t evaluate(const Counter &C, std::error_code &Error) const {
    Error.clear();
    return evaluate(C, &Error);
  }
};

} // end namespace coverage
} // end namespace llvm

#endif // LLVM_PROFILEDATA_COVERAGEMAPPING_H_
