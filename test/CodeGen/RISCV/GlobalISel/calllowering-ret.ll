; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=riscv32 -global-isel -verify-machineinstrs < %s \
; RUN:   | FileCheck -check-prefix=RV32I %s
; RUN: llc -mtriple=riscv64 -global-isel -verify-machineinstrs < %s \
; RUN:   | FileCheck -check-prefix=RV64I %s

define void @foo() {
  ; RV32I-LABEL: foo
  ; RV32I:       # %bb.0: # %entry
  ; RV32I:         ret

  ; RV64I-LABEL: foo
  ; RV64I:       # %bb.0: # %entry
  ; RV64I:         ret
entry:
  ret void
}
