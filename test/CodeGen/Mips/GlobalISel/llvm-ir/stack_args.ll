; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc  -O0 -mtriple=mipsel-linux-gnu -global-isel  -verify-machineinstrs %s -o -| FileCheck %s -check-prefixes=MIPS32

declare i32 @f(i32, i32, i32, i32, i32)

define  i32 @g(i32  %x1, i32 %x2, i32 %x3, i32 %x4, i32 %x5){
; MIPS32-LABEL: g:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    addiu $sp, $sp, -32
; MIPS32-NEXT:    .cfi_def_cfa_offset 32
; MIPS32-NEXT:    sw $ra, 28($sp) # 4-byte Folded Spill
; MIPS32-NEXT:    .cfi_offset 31, -4
; MIPS32-NEXT:    addiu $1, $sp, 48
; MIPS32-NEXT:    lw $1, 0($1)
; MIPS32-NEXT:    move $2, $sp
; MIPS32-NEXT:    ori $3, $zero, 1
; MIPS32-NEXT:    addu $2, $2, $3
; MIPS32-NEXT:    sw $1, 0($2)
; MIPS32-NEXT:    jal f
; MIPS32-NEXT:    nop
; MIPS32-NEXT:    lw $ra, 28($sp) # 4-byte Folded Reload
; MIPS32-NEXT:    addiu $sp, $sp, 32
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %call = call i32 @f(i32 %x1, i32 %x2, i32 %x3, i32 %x4, i32 %x5)
  ret i32 %call
}
