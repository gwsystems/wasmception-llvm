//===- CoverageReport.cpp - Code coverage report -------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This class implements rendering of a code coverage report.
//
//===----------------------------------------------------------------------===//

#include "CoverageReport.h"
#include "CoverageSummary.h"
#include "RenderingSupport.h"
#include "llvm/Support/Format.h"
#include "llvm/Support/FileSystem.h"

using namespace llvm;
namespace {
/// \brief Helper struct which prints trimmed and aligned columns.
struct Column {
  enum TrimKind { NoTrim, LeftTrim, RightTrim };

  enum AlignmentKind { LeftAlignment, RightAlignment };

  StringRef Str;
  unsigned Width;
  TrimKind Trim;
  AlignmentKind Alignment;

  Column(StringRef Str, unsigned Width)
      : Str(Str), Width(Width), Trim(NoTrim), Alignment(LeftAlignment) {}

  Column &set(TrimKind Value) {
    Trim = Value;
    return *this;
  }

  Column &set(AlignmentKind Value) {
    Alignment = Value;
    return *this;
  }

  void render(raw_ostream &OS) const;
};
raw_ostream &operator<<(raw_ostream &OS, const Column &Value) {
  Value.render(OS);
  return OS;
}
}

void Column::render(raw_ostream &OS) const {
  if (Str.size() <= Width) {
    if (Alignment == RightAlignment) {
      OS.indent(Width - Str.size());
      OS << Str;
      return;
    }
    OS << Str;
    OS.indent(Width - Str.size());
    return;
  }

  switch (Trim) {
  case NoTrim:
    OS << Str.substr(0, Width);
    break;
  case LeftTrim:
    OS << "..." << Str.substr(Str.size() - Width + 3);
    break;
  case RightTrim:
    OS << Str.substr(0, Width - 3) << "...";
    break;
  }
}

static Column column(StringRef Str, unsigned Width) {
  return Column(Str, Width);
}

template <typename T>
static Column column(StringRef Str, unsigned Width, const T &Value) {
  return Column(Str, Width).set(Value);
}

static const unsigned FileReportColumns[] = {25, 10, 8, 8, 10, 8};
static const unsigned FunctionReportColumns[] = {25, 10, 8, 8, 10, 8, 8};

/// \brief Prints a horizontal divider which spans across the given columns.
template <typename T, size_t N>
static void renderDivider(T (&Columns)[N], raw_ostream &OS) {
  unsigned Length = 0;
  for (unsigned I = 0; I < N; ++I)
    Length += Columns[I];
  for (unsigned I = 0; I < Length; ++I)
    OS << '-';
}

/// \brief Return the color which correponds to the coverage
/// percentage of a certain metric.
template <typename T>
static raw_ostream::Colors determineCoveragePercentageColor(const T &Info) {
  if (Info.isFullyCovered())
    return raw_ostream::GREEN;
  return Info.getPercentCovered() >= 80.0 ? raw_ostream::YELLOW
                                          : raw_ostream::RED;
}

void CoverageReport::render(const FileCoverageSummary &File, raw_ostream &OS) {
  OS << column(File.Name, FileReportColumns[0], Column::LeftTrim)
     << format("%*zd", FileReportColumns[1], File.RegionCoverage.NumRegions);
  Options.colored_ostream(OS, File.RegionCoverage.isFullyCovered()
                                  ? raw_ostream::GREEN
                                  : raw_ostream::RED)
      << format("%*zd", FileReportColumns[2], File.RegionCoverage.NotCovered);
  Options.colored_ostream(OS,
                          determineCoveragePercentageColor(File.RegionCoverage))
      << format("%*.2f", FileReportColumns[3] - 1,
                File.RegionCoverage.getPercentCovered()) << '%';
  OS << format("%*zd", FileReportColumns[4],
               File.FunctionCoverage.NumFunctions);
  Options.colored_ostream(
      OS, determineCoveragePercentageColor(File.FunctionCoverage))
      << format("%*.2f", FileReportColumns[5] - 1,
                File.FunctionCoverage.getPercentCovered()) << '%';
  OS << "\n";
}

void CoverageReport::render(const FunctionCoverageSummary &Function,
                            raw_ostream &OS) {
  OS << column(Function.Name, FunctionReportColumns[0], Column::RightTrim)
     << format("%*zd", FunctionReportColumns[1],
               Function.RegionCoverage.NumRegions);
  Options.colored_ostream(OS, Function.RegionCoverage.isFullyCovered()
                                  ? raw_ostream::GREEN
                                  : raw_ostream::RED)
      << format("%*zd", FunctionReportColumns[2],
                Function.RegionCoverage.NotCovered);
  Options.colored_ostream(
      OS, determineCoveragePercentageColor(Function.RegionCoverage))
      << format("%*.2f", FunctionReportColumns[3] - 1,
                Function.RegionCoverage.getPercentCovered()) << '%';
  OS << format("%*zd", FunctionReportColumns[4],
               Function.LineCoverage.NumLines);
  Options.colored_ostream(OS, Function.LineCoverage.isFullyCovered()
                                  ? raw_ostream::GREEN
                                  : raw_ostream::RED)
      << format("%*zd", FunctionReportColumns[5],
                Function.LineCoverage.NotCovered);
  Options.colored_ostream(
      OS, determineCoveragePercentageColor(Function.LineCoverage))
      << format("%*.2f", FunctionReportColumns[6] - 1,
                Function.LineCoverage.getPercentCovered()) << '%';
  OS << "\n";
}

void CoverageReport::renderFunctionReports(raw_ostream &OS) {
  bool isFirst = true;
  for (const auto &File : Summary.getFileSummaries()) {
    if (isFirst)
      isFirst = false;
    else
      OS << "\n";
    OS << "File '" << File.Name << "':\n";
    OS << column("Name", FunctionReportColumns[0])
       << column("Regions", FunctionReportColumns[1], Column::RightAlignment)
       << column("Miss", FunctionReportColumns[2], Column::RightAlignment)
       << column("Cover", FunctionReportColumns[3], Column::RightAlignment)
       << column("Lines", FunctionReportColumns[4], Column::RightAlignment)
       << column("Miss", FunctionReportColumns[5], Column::RightAlignment)
       << column("Cover", FunctionReportColumns[6], Column::RightAlignment);
    OS << "\n";
    renderDivider(FunctionReportColumns, OS);
    OS << "\n";
    for (const auto &Function : File.FunctionSummaries)
      render(Function, OS);
    renderDivider(FunctionReportColumns, OS);
    OS << "\n";
    render(FunctionCoverageSummary("TOTAL", File.RegionCoverage,
                                   File.LineCoverage),
           OS);
  }
}

void CoverageReport::renderFileReports(raw_ostream &OS) {
  OS << column("Filename", FileReportColumns[0])
     << column("Regions", FileReportColumns[1], Column::RightAlignment)
     << column("Miss", FileReportColumns[2], Column::RightAlignment)
     << column("Cover", FileReportColumns[3], Column::RightAlignment)
     << column("Functions", FileReportColumns[4], Column::RightAlignment)
     << column("Cover", FileReportColumns[5], Column::RightAlignment) << "\n";
  renderDivider(FileReportColumns, OS);
  OS << "\n";
  for (const auto &File : Summary.getFileSummaries())
    render(File, OS);
  renderDivider(FileReportColumns, OS);
  OS << "\n";
  render(Summary.getCombinedFileSummaries(), OS);
}
