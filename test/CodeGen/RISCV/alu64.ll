; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=riscv64 -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefix=RV64I
; RUN: llc -mtriple=riscv32 -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefix=RV32I

; These tests are each targeted at a particular RISC-V ALU instruction. Other
; files in this folder exercise LLVM IR instructions that don't directly match a
; RISC-V instruction. This file contains tests for the instructions common
; between RV32I and RV64I as well as the *W instructions introduced in RV64I.

; Register-immediate instructions

define i64 @addi(i64 %a) nounwind {
; RV64I-LABEL: addi:
; RV64I:       # %bb.0:
; RV64I-NEXT:    addi a0, a0, 1
; RV64I-NEXT:    ret
;
; RV32I-LABEL: addi:
; RV32I:       # %bb.0:
; RV32I-NEXT:    addi a2, a0, 1
; RV32I-NEXT:    sltu a0, a2, a0
; RV32I-NEXT:    add a1, a1, a0
; RV32I-NEXT:    mv a0, a2
; RV32I-NEXT:    ret
  %1 = add i64 %a, 1
  ret i64 %1
}

define i64 @slti(i64 %a) nounwind {
; RV64I-LABEL: slti:
; RV64I:       # %bb.0:
; RV64I-NEXT:    slti a0, a0, 2
; RV64I-NEXT:    ret
;
; RV32I-LABEL: slti:
; RV32I:       # %bb.0:
; RV32I-NEXT:    beqz a1, .LBB1_2
; RV32I-NEXT:  # %bb.1:
; RV32I-NEXT:    slti a0, a1, 0
; RV32I-NEXT:    mv a1, zero
; RV32I-NEXT:    ret
; RV32I-NEXT:  .LBB1_2:
; RV32I-NEXT:    sltiu a0, a0, 2
; RV32I-NEXT:    mv a1, zero
; RV32I-NEXT:    ret
  %1 = icmp slt i64 %a, 2
  %2 = zext i1 %1 to i64
  ret i64 %2
}

define i64 @sltiu(i64 %a) nounwind {
; RV64I-LABEL: sltiu:
; RV64I:       # %bb.0:
; RV64I-NEXT:    sltiu a0, a0, 3
; RV64I-NEXT:    ret
;
; RV32I-LABEL: sltiu:
; RV32I:       # %bb.0:
; RV32I-NEXT:    beqz a1, .LBB2_2
; RV32I-NEXT:  # %bb.1:
; RV32I-NEXT:    mv a0, zero
; RV32I-NEXT:    mv a1, zero
; RV32I-NEXT:    ret
; RV32I-NEXT:  .LBB2_2:
; RV32I-NEXT:    sltiu a0, a0, 3
; RV32I-NEXT:    mv a1, zero
; RV32I-NEXT:    ret
  %1 = icmp ult i64 %a, 3
  %2 = zext i1 %1 to i64
  ret i64 %2
}

define i64 @xori(i64 %a) nounwind {
; RV64I-LABEL: xori:
; RV64I:       # %bb.0:
; RV64I-NEXT:    xori a0, a0, 4
; RV64I-NEXT:    ret
;
; RV32I-LABEL: xori:
; RV32I:       # %bb.0:
; RV32I-NEXT:    xori a0, a0, 4
; RV32I-NEXT:    ret
  %1 = xor i64 %a, 4
  ret i64 %1
}

define i64 @ori(i64 %a) nounwind {
; RV64I-LABEL: ori:
; RV64I:       # %bb.0:
; RV64I-NEXT:    ori a0, a0, 5
; RV64I-NEXT:    ret
;
; RV32I-LABEL: ori:
; RV32I:       # %bb.0:
; RV32I-NEXT:    ori a0, a0, 5
; RV32I-NEXT:    ret
  %1 = or i64 %a, 5
  ret i64 %1
}

define i64 @andi(i64 %a) nounwind {
; RV64I-LABEL: andi:
; RV64I:       # %bb.0:
; RV64I-NEXT:    andi a0, a0, 6
; RV64I-NEXT:    ret
;
; RV32I-LABEL: andi:
; RV32I:       # %bb.0:
; RV32I-NEXT:    andi a0, a0, 6
; RV32I-NEXT:    mv a1, zero
; RV32I-NEXT:    ret
  %1 = and i64 %a, 6
  ret i64 %1
}

define i64 @slli(i64 %a) nounwind {
; RV64I-LABEL: slli:
; RV64I:       # %bb.0:
; RV64I-NEXT:    slli a0, a0, 7
; RV64I-NEXT:    ret
;
; RV32I-LABEL: slli:
; RV32I:       # %bb.0:
; RV32I-NEXT:    slli a1, a1, 7
; RV32I-NEXT:    srli a2, a0, 25
; RV32I-NEXT:    or a1, a1, a2
; RV32I-NEXT:    slli a0, a0, 7
; RV32I-NEXT:    ret
  %1 = shl i64 %a, 7
  ret i64 %1
}

define i64 @srli(i64 %a) nounwind {
; RV64I-LABEL: srli:
; RV64I:       # %bb.0:
; RV64I-NEXT:    srli a0, a0, 8
; RV64I-NEXT:    ret
;
; RV32I-LABEL: srli:
; RV32I:       # %bb.0:
; RV32I-NEXT:    srli a0, a0, 8
; RV32I-NEXT:    slli a2, a1, 24
; RV32I-NEXT:    or a0, a0, a2
; RV32I-NEXT:    srli a1, a1, 8
; RV32I-NEXT:    ret
  %1 = lshr i64 %a, 8
  ret i64 %1
}

define i64 @srai(i64 %a) nounwind {
; RV64I-LABEL: srai:
; RV64I:       # %bb.0:
; RV64I-NEXT:    srai a0, a0, 9
; RV64I-NEXT:    ret
;
; RV32I-LABEL: srai:
; RV32I:       # %bb.0:
; RV32I-NEXT:    srli a0, a0, 9
; RV32I-NEXT:    slli a2, a1, 23
; RV32I-NEXT:    or a0, a0, a2
; RV32I-NEXT:    srai a1, a1, 9
; RV32I-NEXT:    ret
  %1 = ashr i64 %a, 9
  ret i64 %1
}

; Register-register instructions

define i64 @add(i64 %a, i64 %b) nounwind {
; RV64I-LABEL: add:
; RV64I:       # %bb.0:
; RV64I-NEXT:    add a0, a0, a1
; RV64I-NEXT:    ret
;
; RV32I-LABEL: add:
; RV32I:       # %bb.0:
; RV32I-NEXT:    add a1, a1, a3
; RV32I-NEXT:    add a2, a0, a2
; RV32I-NEXT:    sltu a0, a2, a0
; RV32I-NEXT:    add a1, a1, a0
; RV32I-NEXT:    mv a0, a2
; RV32I-NEXT:    ret
  %1 = add i64 %a, %b
  ret i64 %1
}

define i64 @sub(i64 %a, i64 %b) nounwind {
; RV64I-LABEL: sub:
; RV64I:       # %bb.0:
; RV64I-NEXT:    sub a0, a0, a1
; RV64I-NEXT:    ret
;
; RV32I-LABEL: sub:
; RV32I:       # %bb.0:
; RV32I-NEXT:    sub a1, a1, a3
; RV32I-NEXT:    sltu a3, a0, a2
; RV32I-NEXT:    sub a1, a1, a3
; RV32I-NEXT:    sub a0, a0, a2
; RV32I-NEXT:    ret
  %1 = sub i64 %a, %b
  ret i64 %1
}

define i64 @sll(i64 %a, i64 %b) nounwind {
; RV64I-LABEL: sll:
; RV64I:       # %bb.0:
; RV64I-NEXT:    sll a0, a0, a1
; RV64I-NEXT:    ret
;
; RV32I-LABEL: sll:
; RV32I:       # %bb.0:
; RV32I-NEXT:    addi sp, sp, -16
; RV32I-NEXT:    sw ra, 12(sp)
; RV32I-NEXT:    call __ashldi3
; RV32I-NEXT:    lw ra, 12(sp)
; RV32I-NEXT:    addi sp, sp, 16
; RV32I-NEXT:    ret
  %1 = shl i64 %a, %b
  ret i64 %1
}

define i64 @slt(i64 %a, i64 %b) nounwind {
; RV64I-LABEL: slt:
; RV64I:       # %bb.0:
; RV64I-NEXT:    slt a0, a0, a1
; RV64I-NEXT:    ret
;
; RV32I-LABEL: slt:
; RV32I:       # %bb.0:
; RV32I-NEXT:    beq a1, a3, .LBB12_2
; RV32I-NEXT:  # %bb.1:
; RV32I-NEXT:    slt a0, a1, a3
; RV32I-NEXT:    mv a1, zero
; RV32I-NEXT:    ret
; RV32I-NEXT:  .LBB12_2:
; RV32I-NEXT:    sltu a0, a0, a2
; RV32I-NEXT:    mv a1, zero
; RV32I-NEXT:    ret
  %1 = icmp slt i64 %a, %b
  %2 = zext i1 %1 to i64
  ret i64 %2
}

define i64 @sltu(i64 %a, i64 %b) nounwind {
; RV64I-LABEL: sltu:
; RV64I:       # %bb.0:
; RV64I-NEXT:    sltu a0, a0, a1
; RV64I-NEXT:    ret
;
; RV32I-LABEL: sltu:
; RV32I:       # %bb.0:
; RV32I-NEXT:    beq a1, a3, .LBB13_2
; RV32I-NEXT:  # %bb.1:
; RV32I-NEXT:    sltu a0, a1, a3
; RV32I-NEXT:    mv a1, zero
; RV32I-NEXT:    ret
; RV32I-NEXT:  .LBB13_2:
; RV32I-NEXT:    sltu a0, a0, a2
; RV32I-NEXT:    mv a1, zero
; RV32I-NEXT:    ret
  %1 = icmp ult i64 %a, %b
  %2 = zext i1 %1 to i64
  ret i64 %2
}

define i64 @xor(i64 %a, i64 %b) nounwind {
; RV64I-LABEL: xor:
; RV64I:       # %bb.0:
; RV64I-NEXT:    xor a0, a0, a1
; RV64I-NEXT:    ret
;
; RV32I-LABEL: xor:
; RV32I:       # %bb.0:
; RV32I-NEXT:    xor a0, a0, a2
; RV32I-NEXT:    xor a1, a1, a3
; RV32I-NEXT:    ret
  %1 = xor i64 %a, %b
  ret i64 %1
}

define i64 @srl(i64 %a, i64 %b) nounwind {
; RV64I-LABEL: srl:
; RV64I:       # %bb.0:
; RV64I-NEXT:    srl a0, a0, a1
; RV64I-NEXT:    ret
;
; RV32I-LABEL: srl:
; RV32I:       # %bb.0:
; RV32I-NEXT:    addi sp, sp, -16
; RV32I-NEXT:    sw ra, 12(sp)
; RV32I-NEXT:    call __lshrdi3
; RV32I-NEXT:    lw ra, 12(sp)
; RV32I-NEXT:    addi sp, sp, 16
; RV32I-NEXT:    ret
  %1 = lshr i64 %a, %b
  ret i64 %1
}

define i64 @sra(i64 %a, i64 %b) nounwind {
; RV64I-LABEL: sra:
; RV64I:       # %bb.0:
; RV64I-NEXT:    sra a0, a0, a1
; RV64I-NEXT:    ret
;
; RV32I-LABEL: sra:
; RV32I:       # %bb.0:
; RV32I-NEXT:    addi sp, sp, -16
; RV32I-NEXT:    sw ra, 12(sp)
; RV32I-NEXT:    call __ashrdi3
; RV32I-NEXT:    lw ra, 12(sp)
; RV32I-NEXT:    addi sp, sp, 16
; RV32I-NEXT:    ret
  %1 = ashr i64 %a, %b
  ret i64 %1
}

define i64 @or(i64 %a, i64 %b) nounwind {
; RV64I-LABEL: or:
; RV64I:       # %bb.0:
; RV64I-NEXT:    or a0, a0, a1
; RV64I-NEXT:    ret
;
; RV32I-LABEL: or:
; RV32I:       # %bb.0:
; RV32I-NEXT:    or a0, a0, a2
; RV32I-NEXT:    or a1, a1, a3
; RV32I-NEXT:    ret
  %1 = or i64 %a, %b
  ret i64 %1
}

define i64 @and(i64 %a, i64 %b) nounwind {
; RV64I-LABEL: and:
; RV64I:       # %bb.0:
; RV64I-NEXT:    and a0, a0, a1
; RV64I-NEXT:    ret
;
; RV32I-LABEL: and:
; RV32I:       # %bb.0:
; RV32I-NEXT:    and a0, a0, a2
; RV32I-NEXT:    and a1, a1, a3
; RV32I-NEXT:    ret
  %1 = and i64 %a, %b
  ret i64 %1
}

; RV64I-only instructions

define signext i32 @addiw(i32 signext %a) {
; RV64I-LABEL: addiw:
; RV64I:       # %bb.0:
; RV64I-NEXT:    addiw a0, a0, 123
; RV64I-NEXT:    ret
;
; RV32I-LABEL: addiw:
; RV32I:       # %bb.0:
; RV32I-NEXT:    addi a0, a0, 123
; RV32I-NEXT:    ret
  %1 = add i32 %a, 123
  ret i32 %1
}

define signext i32 @slliw(i32 signext %a) {
; RV64I-LABEL: slliw:
; RV64I:       # %bb.0:
; RV64I-NEXT:    slliw a0, a0, 17
; RV64I-NEXT:    ret
;
; RV32I-LABEL: slliw:
; RV32I:       # %bb.0:
; RV32I-NEXT:    slli a0, a0, 17
; RV32I-NEXT:    ret
  %1 = shl i32 %a, 17
  ret i32 %1
}

define signext i32 @srliw(i32 %a) {
; RV64I-LABEL: srliw:
; RV64I:       # %bb.0:
; RV64I-NEXT:    srliw a0, a0, 8
; RV64I-NEXT:    ret
;
; RV32I-LABEL: srliw:
; RV32I:       # %bb.0:
; RV32I-NEXT:    srli a0, a0, 8
; RV32I-NEXT:    ret
  %1 = lshr i32 %a, 8
  ret i32 %1
}

define signext i32 @sraiw(i32 %a) {
; RV64I-LABEL: sraiw:
; RV64I:       # %bb.0:
; RV64I-NEXT:    sraiw a0, a0, 9
; RV64I-NEXT:    ret
;
; RV32I-LABEL: sraiw:
; RV32I:       # %bb.0:
; RV32I-NEXT:    srai a0, a0, 9
; RV32I-NEXT:    ret
  %1 = ashr i32 %a, 9
  ret i32 %1
}

define signext i32 @sextw(i32 zeroext %a) {
; RV64I-LABEL: sextw:
; RV64I:       # %bb.0:
; RV64I-NEXT:    sext.w a0, a0
; RV64I-NEXT:    ret
;
; RV32I-LABEL: sextw:
; RV32I:       # %bb.0:
; RV32I-NEXT:    ret
  ret i32 %a
}

define signext i32 @addw(i32 signext %a, i32 signext %b) {
; RV64I-LABEL: addw:
; RV64I:       # %bb.0:
; RV64I-NEXT:    addw a0, a0, a1
; RV64I-NEXT:    ret
;
; RV32I-LABEL: addw:
; RV32I:       # %bb.0:
; RV32I-NEXT:    add a0, a0, a1
; RV32I-NEXT:    ret
  %1 = add i32 %a, %b
  ret i32 %1
}

define signext i32 @subw(i32 signext %a, i32 signext %b) {
; RV64I-LABEL: subw:
; RV64I:       # %bb.0:
; RV64I-NEXT:    subw a0, a0, a1
; RV64I-NEXT:    ret
;
; RV32I-LABEL: subw:
; RV32I:       # %bb.0:
; RV32I-NEXT:    sub a0, a0, a1
; RV32I-NEXT:    ret
  %1 = sub i32 %a, %b
  ret i32 %1
}

; TODO: should select sllw for RV64.

define signext i32 @sllw(i32 signext %a, i32 zeroext %b) {
; RV64I-LABEL: sllw:
; RV64I:       # %bb.0:
; RV64I-NEXT:    sll a0, a0, a1
; RV64I-NEXT:    sext.w a0, a0
; RV64I-NEXT:    ret
;
; RV32I-LABEL: sllw:
; RV32I:       # %bb.0:
; RV32I-NEXT:    sll a0, a0, a1
; RV32I-NEXT:    ret
  %1 = shl i32 %a, %b
  ret i32 %1
}

; TODO: should select srlw for RV64.

define signext i32 @srlw(i32 signext %a, i32 zeroext %b) {
; RV64I-LABEL: srlw:
; RV64I:       # %bb.0:
; RV64I-NEXT:    slli a0, a0, 32
; RV64I-NEXT:    srli a0, a0, 32
; RV64I-NEXT:    srl a0, a0, a1
; RV64I-NEXT:    sext.w a0, a0
; RV64I-NEXT:    ret
;
; RV32I-LABEL: srlw:
; RV32I:       # %bb.0:
; RV32I-NEXT:    srl a0, a0, a1
; RV32I-NEXT:    ret
  %1 = lshr i32 %a, %b
  ret i32 %1
}

; TODO: should select sraw for RV64.

define signext i32 @sraw(i64 %a, i32 zeroext %b) {
; RV64I-LABEL: sraw:
; RV64I:       # %bb.0:
; RV64I-NEXT:    sext.w a0, a0
; RV64I-NEXT:    sra a0, a0, a1
; RV64I-NEXT:    ret
;
; RV32I-LABEL: sraw:
; RV32I:       # %bb.0:
; RV32I-NEXT:    sra a0, a0, a2
; RV32I-NEXT:    ret
  %1 = trunc i64 %a to i32
  %2 = ashr i32 %1, %b
  ret i32 %2
}
