; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=riscv32 -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefix=RV32I

; Check load/store operations on values wider than what is natively supported

define i64 @load_i64(i64 *%a) nounwind {
; RV32I-LABEL: load_i64:
; RV32I:       # %bb.0:
; RV32I-NEXT:    lw a2, 0(a0)
; RV32I-NEXT:    lw a1, 4(a0)
; RV32I-NEXT:    mv a0, a2
; RV32I-NEXT:    ret
  %1 = load i64, i64* %a
  ret i64 %1
}

@val64 = local_unnamed_addr global i64 2863311530, align 8

define i64 @load_i64_global() nounwind {
; RV32I-LABEL: load_i64_global:
; RV32I:       # %bb.0:
; RV32I-NEXT:    lui a0, %hi(val64)
; RV32I-NEXT:    lw a0, %lo(val64)(a0)
; RV32I-NEXT:    lui a1, %hi(val64+4)
; RV32I-NEXT:    lw a1, %lo(val64+4)(a1)
; RV32I-NEXT:    ret
  %1 = load i64, i64* @val64
  ret i64 %1
}
