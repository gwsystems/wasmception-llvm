; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=riscv32 -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefix=RV32I

define void @jt(i32 %in, i32* %out) {
; RV32I-LABEL: jt:
; RV32I:       # %bb.0: # %entry
; RV32I-NEXT:    addi a2, zero, 2
; RV32I-NEXT:    blt a2, a0, .LBB0_3
; RV32I-NEXT:    jal zero, .LBB0_1
; RV32I-NEXT:  .LBB0_1: # %entry
; RV32I-NEXT:    addi a3, zero, 1
; RV32I-NEXT:    beq a0, a3, .LBB0_5
; RV32I-NEXT:    jal zero, .LBB0_2
; RV32I-NEXT:  .LBB0_2: # %entry
; RV32I-NEXT:    beq a0, a2, .LBB0_6
; RV32I-NEXT:    jal zero, .LBB0_9
; RV32I-NEXT:  .LBB0_6: # %bb2
; RV32I-NEXT:    addi a0, zero, 3
; RV32I-NEXT:    sw a0, 0(a1)
; RV32I-NEXT:    jal zero, .LBB0_9
; RV32I-NEXT:  .LBB0_3: # %entry
; RV32I-NEXT:    addi a3, zero, 3
; RV32I-NEXT:    beq a0, a3, .LBB0_7
; RV32I-NEXT:    jal zero, .LBB0_4
; RV32I-NEXT:  .LBB0_4: # %entry
; RV32I-NEXT:    addi a2, zero, 4
; RV32I-NEXT:    beq a0, a2, .LBB0_8
; RV32I-NEXT:    jal zero, .LBB0_9
; RV32I-NEXT:  .LBB0_8: # %bb4
; RV32I-NEXT:    addi a0, zero, 1
; RV32I-NEXT:    sw a0, 0(a1)
; RV32I-NEXT:  .LBB0_9: # %exit
; RV32I-NEXT:    jalr zero, ra, 0
; RV32I-NEXT:  .LBB0_5: # %bb1
; RV32I-NEXT:    addi a0, zero, 4
; RV32I-NEXT:    sw a0, 0(a1)
; RV32I-NEXT:    jal zero, .LBB0_9
; RV32I-NEXT:  .LBB0_7: # %bb3
; RV32I-NEXT:    sw a2, 0(a1)
; RV32I-NEXT:    jal zero, .LBB0_9
entry:
  switch i32 %in, label %exit [
    i32 1, label %bb1
    i32 2, label %bb2
    i32 3, label %bb3
    i32 4, label %bb4
  ]
bb1:
  store i32 4, i32* %out
  br label %exit
bb2:
  store i32 3, i32* %out
  br label %exit
bb3:
  store i32 2, i32* %out
  br label %exit
bb4:
  store i32 1, i32* %out
  br label %exit
exit:
  ret void
}
