//===- DIAInjectedSource.h - DIA impl for IPDBInjectedSource ----*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_DEBUGINFO_PDB_DIA_DIAINJECTEDSOURCE_H
#define LLVM_DEBUGINFO_PDB_DIA_DIAINJECTEDSOURCE_H

#include "DIASupport.h"
#include "llvm/DebugInfo/PDB/IPDBInjectedSource.h"

namespace llvm {
namespace pdb {
class DIASession;

class DIAInjectedSource : public IPDBInjectedSource {
public:
  explicit DIAInjectedSource(const DIASession &Session,
                             CComPtr<IDiaInjectedSource> DiaSourceFile);

  uint32_t getCrc32() const override;
  uint64_t getCodeByteSize() const override;
  std::string getFileName() const override;
  std::string getObjectFileName() const override;
  std::string getVirtualFileName() const override;
  PDB_SourceCompression getCompression() const override;
  std::string getCode() const override;

private:
  const DIASession &Session;
  CComPtr<IDiaInjectedSource> SourceFile;
};
} // namespace pdb
} // namespace llvm

#endif // LLVM_DEBUGINFO_PDB_DIA_DIAINJECTEDSOURCE_H
