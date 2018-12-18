; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc  -O0 -mtriple=mipsel-linux-gnu -global-isel  -verify-machineinstrs %s -o -| FileCheck %s -check-prefixes=MIPS32

define i1 @and_i1(i1 %a, i1 %b) {
; MIPS32-LABEL: and_i1:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    and $2, $5, $4
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %and = and i1 %b, %a
  ret i1 %and
}

define i8 @and_i8(i8 %a, i8 %b) {
; MIPS32-LABEL: and_i8:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    and $2, $5, $4
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %and = and i8 %b, %a
  ret i8 %and
}

define i16 @and_i16(i16 %a, i16 %b) {
; MIPS32-LABEL: and_i16:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    and $2, $5, $4
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %and = and i16 %b, %a
  ret i16 %and
}

define i32 @and_i32(i32 %a, i32 %b) {
; MIPS32-LABEL: and_i32:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    and $2, $5, $4
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %and = and i32 %b, %a
  ret i32 %and
}

define i64 @and_i64(i64 %a, i64 %b) {
; MIPS32-LABEL: and_i64:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    and $2, $6, $4
; MIPS32-NEXT:    and $3, $7, $5
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %and = and i64 %b, %a
  ret i64 %and
}

define i1 @or_i1(i1 %a, i1 %b) {
; MIPS32-LABEL: or_i1:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    or $2, $5, $4
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %or = or i1 %b, %a
  ret i1 %or
}

define i8 @or_i8(i8 %a, i8 %b) {
; MIPS32-LABEL: or_i8:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    or $2, $5, $4
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %or = or i8 %b, %a
  ret i8 %or
}

define i16 @or_i16(i16 %a, i16 %b) {
; MIPS32-LABEL: or_i16:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    or $2, $5, $4
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %or = or i16 %b, %a
  ret i16 %or
}

define i32 @or_i32(i32 %a, i32 %b) {
; MIPS32-LABEL: or_i32:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    or $2, $5, $4
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %or = or i32 %b, %a
  ret i32 %or
}

define i64 @or_i64(i64 %a, i64 %b) {
; MIPS32-LABEL: or_i64:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    or $2, $6, $4
; MIPS32-NEXT:    or $3, $7, $5
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %or = or i64 %b, %a
  ret i64 %or
}

define i1 @xor_i1(i1 %a, i1 %b) {
; MIPS32-LABEL: xor_i1:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    xor $2, $5, $4
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %xor = xor i1 %b, %a
  ret i1 %xor
}

define i8 @xor_i8(i8 %a, i8 %b) {
; MIPS32-LABEL: xor_i8:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    xor $2, $5, $4
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %xor = xor i8 %b, %a
  ret i8 %xor
}

define i16 @xor_i16(i16 %a, i16 %b) {
; MIPS32-LABEL: xor_i16:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    xor $2, $5, $4
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %xor = xor i16 %b, %a
  ret i16 %xor
}

define i32 @xor_i32(i32 %a, i32 %b) {
; MIPS32-LABEL: xor_i32:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    xor $2, $5, $4
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %xor = xor i32 %b, %a
  ret i32 %xor
}

define i64 @xor_i64(i64 %a, i64 %b) {
; MIPS32-LABEL: xor_i64:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    xor $2, $6, $4
; MIPS32-NEXT:    xor $3, $7, $5
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %xor = xor i64 %b, %a
  ret i64 %xor
}

define i32 @shl(i32 %a) {
; MIPS32-LABEL: shl:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    sll $2, $4, 1
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %shl = shl i32 %a, 1
  ret i32 %shl
}

define i32 @ashr(i32 %a) {
; MIPS32-LABEL: ashr:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    sra $2, $4, 1
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %shr = ashr i32 %a, 1
  ret i32 %shr
}

define i32 @lshr(i32 %a) {
; MIPS32-LABEL: lshr:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    srl $2, $4, 1
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %shr = lshr i32 %a, 1
  ret i32 %shr
}

define i32 @shlv(i32 %a, i32 %b) {
; MIPS32-LABEL: shlv:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    sllv $2, $4, $5
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %shl = shl i32 %a, %b
  ret i32 %shl
}

define i32 @ashrv(i32 %a, i32 %b) {
; MIPS32-LABEL: ashrv:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    srav $2, $4, $5
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %shr = ashr i32 %a, %b
  ret i32 %shr
}

define i32 @lshrv(i32 %a, i32 %b) {
; MIPS32-LABEL: lshrv:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    srlv $2, $4, $5
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %shr = lshr i32 %a, %b
  ret i32 %shr
}

