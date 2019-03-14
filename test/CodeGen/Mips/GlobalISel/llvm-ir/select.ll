; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc  -O0 -mtriple=mipsel-linux-gnu -global-isel  -verify-machineinstrs %s -o -| FileCheck %s -check-prefixes=MIPS32

define i8 @select_i8(i1 %test, i8 %a, i8 %b) {
; MIPS32-LABEL: select_i8:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    lui $1, 0
; MIPS32-NEXT:    ori $1, $1, 1
; MIPS32-NEXT:    and $1, $4, $1
; MIPS32-NEXT:    movn $6, $5, $1
; MIPS32-NEXT:    move $2, $6
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %cond = select i1 %test, i8 %a, i8 %b
  ret i8 %cond
}

define i16 @select_i16(i1 %test, i16 %a, i16 %b) {
; MIPS32-LABEL: select_i16:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    lui $1, 0
; MIPS32-NEXT:    ori $1, $1, 1
; MIPS32-NEXT:    and $1, $4, $1
; MIPS32-NEXT:    movn $6, $5, $1
; MIPS32-NEXT:    move $2, $6
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %cond = select i1 %test, i16 %a, i16 %b
  ret i16 %cond
}

define i32 @select_i32(i1 %test, i32 %a, i32 %b) {
; MIPS32-LABEL: select_i32:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    lui $1, 0
; MIPS32-NEXT:    ori $1, $1, 1
; MIPS32-NEXT:    and $1, $4, $1
; MIPS32-NEXT:    movn $6, $5, $1
; MIPS32-NEXT:    move $2, $6
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %cond = select i1 %test, i32 %a, i32 %b
  ret i32 %cond
}

define i32* @select_ptr(i1 %test, i32* %a, i32* %b) {
; MIPS32-LABEL: select_ptr:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    lui $1, 0
; MIPS32-NEXT:    ori $1, $1, 1
; MIPS32-NEXT:    and $1, $4, $1
; MIPS32-NEXT:    movn $6, $5, $1
; MIPS32-NEXT:    move $2, $6
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %cond = select i1 %test, i32* %a, i32* %b
  ret i32* %cond
}

define i32 @select_with_negation(i32 %a, i32 %b, i32 %x, i32 %y) {
; MIPS32-LABEL: select_with_negation:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    slt $4, $4, $5
; MIPS32-NEXT:    not $4, $4
; MIPS32-NEXT:    lui $5, 0
; MIPS32-NEXT:    ori $5, $5, 1
; MIPS32-NEXT:    and $4, $4, $5
; MIPS32-NEXT:    movn $7, $6, $4
; MIPS32-NEXT:    move $2, $7
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %cmp = icmp slt i32 %a, %b
  %lneg = xor i1 %cmp, true
  %cond = select i1 %lneg, i32 %x, i32 %y
  ret i32 %cond
}
