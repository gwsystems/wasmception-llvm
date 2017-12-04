; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=riscv32 -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefix=RV32I

define i32 @urem(i32 %a, i32 %b) nounwind {
; RV32I-LABEL: urem:
; RV32I:       # %bb.0:
; RV32I-NEXT:    sw ra, 12(s0)
; RV32I-NEXT:    lui a2, %hi(__umodsi3)
; RV32I-NEXT:    addi a2, a2, %lo(__umodsi3)
; RV32I-NEXT:    jalr ra, a2, 0
; RV32I-NEXT:    lw ra, 12(s0)
; RV32I-NEXT:    jalr zero, ra, 0
  %1 = urem i32 %a, %b
  ret i32 %1
}

define i32 @srem(i32 %a, i32 %b) nounwind {
; RV32I-LABEL: srem:
; RV32I:       # %bb.0:
; RV32I-NEXT:    sw ra, 12(s0)
; RV32I-NEXT:    lui a2, %hi(__modsi3)
; RV32I-NEXT:    addi a2, a2, %lo(__modsi3)
; RV32I-NEXT:    jalr ra, a2, 0
; RV32I-NEXT:    lw ra, 12(s0)
; RV32I-NEXT:    jalr zero, ra, 0
  %1 = srem i32 %a, %b
  ret i32 %1
}
