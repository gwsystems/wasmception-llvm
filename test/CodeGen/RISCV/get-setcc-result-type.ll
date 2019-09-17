; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=riscv32 -verify-machineinstrs < %s \
; RUN:   | FileCheck -check-prefix=RV32I %s

define void @getSetCCResultType(<4 x i32>* %p, <4 x i32>* %q) nounwind {
; RV32I-LABEL: getSetCCResultType:
; RV32I:       # %bb.0: # %entry
; RV32I-NEXT:    lw a1, 12(a0)
; RV32I-NEXT:    lw a2, 8(a0)
; RV32I-NEXT:    lw a3, 4(a0)
; RV32I-NEXT:    lw a4, 0(a0)
; RV32I-NEXT:    seqz a1, a1
; RV32I-NEXT:    seqz a2, a2
; RV32I-NEXT:    seqz a3, a3
; RV32I-NEXT:    seqz a4, a4
; RV32I-NEXT:    neg a4, a4
; RV32I-NEXT:    neg a3, a3
; RV32I-NEXT:    neg a2, a2
; RV32I-NEXT:    neg a1, a1
; RV32I-NEXT:    sw a1, 12(a0)
; RV32I-NEXT:    sw a2, 8(a0)
; RV32I-NEXT:    sw a3, 4(a0)
; RV32I-NEXT:    sw a4, 0(a0)
; RV32I-NEXT:    ret
entry:
  %0 = load <4 x i32>, <4 x i32>* %p, align 16
  %cmp = icmp eq <4 x i32> %0, zeroinitializer
  %sext = sext <4 x i1> %cmp to <4 x i32>
  store <4 x i32> %sext, <4 x i32>* %p, align 16
  ret void
}
