; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=mips-unknwon-linux-gnu -mcpu=mips32r2 \
; RUN:   -mattr=+use-indirect-jump-hazard,+long-calls,+noabicalls %s -o - \
; RUN:   -verify-machineinstrs | FileCheck -check-prefix=O32 %s

; RUN: llc -mtriple=mips64-unknown-linux-gnu -mcpu=mips64r2 -target-abi n32 \
; RUN:   -mattr=+use-indirect-jump-hazard,+long-calls,+noabicalls %s -o - \
; RUN:   -verify-machineinstrs | FileCheck -check-prefix=N32 %s

; RUN: llc -mtriple=mips64-unknown-linux-gnu -mcpu=mips64r2 -target-abi n64 \
; RUN:   -mattr=+use-indirect-jump-hazard,+long-calls,+noabicalls %s -o - \
; RUN:   -verify-machineinstrs | FileCheck -check-prefix=N64 %s

declare void @callee()
declare void @llvm.memset.p0i8.i32(i8* nocapture writeonly, i8, i32, i1)

@val = internal unnamed_addr global [20 x i32] zeroinitializer, align 4

; Test that the long call sequence uses the hazard barrier instruction variant.
define void @caller() {
; O32-LABEL: caller:
; O32:       # %bb.0:
; O32-NEXT:    addiu $sp, $sp, -24
; O32-NEXT:    .cfi_def_cfa_offset 24
; O32-NEXT:    sw $ra, 20($sp) # 4-byte Folded Spill
; O32-NEXT:    .cfi_offset 31, -4
; O32-NEXT:    lui $1, %hi(callee)
; O32-NEXT:    addiu $25, $1, %lo(callee)
; O32-NEXT:    jalr.hb $25
; O32-NEXT:    nop
; O32-NEXT:    lui $1, %hi(val)
; O32-NEXT:    addiu $4, $1, %lo(val)
; O32-NEXT:    lui $1, %hi(memset)
; O32-NEXT:    addiu $25, $1, %lo(memset)
; O32-NEXT:    addiu $5, $zero, 0
; O32-NEXT:    jalr.hb $25
; O32-NEXT:    addiu $6, $zero, 80
; O32-NEXT:    lw $ra, 20($sp) # 4-byte Folded Reload
; O32-NEXT:    jr $ra
; O32-NEXT:    addiu $sp, $sp, 24
;
; N32-LABEL: caller:
; N32:       # %bb.0:
; N32-NEXT:    addiu $sp, $sp, -16
; N32-NEXT:    .cfi_def_cfa_offset 16
; N32-NEXT:    sd $ra, 8($sp) # 8-byte Folded Spill
; N32-NEXT:    .cfi_offset 31, -8
; N32-NEXT:    lui $1, %hi(callee)
; N32-NEXT:    addiu $25, $1, %lo(callee)
; N32-NEXT:    jalr.hb $25
; N32-NEXT:    nop
; N32-NEXT:    lui $1, %hi(val)
; N32-NEXT:    addiu $4, $1, %lo(val)
; N32-NEXT:    lui $1, %hi(memset)
; N32-NEXT:    addiu $25, $1, %lo(memset)
; N32-NEXT:    daddiu $5, $zero, 0
; N32-NEXT:    jalr.hb $25
; N32-NEXT:    daddiu $6, $zero, 80
; N32-NEXT:    ld $ra, 8($sp) # 8-byte Folded Reload
; N32-NEXT:    jr $ra
; N32-NEXT:    addiu $sp, $sp, 16
;
; N64-LABEL: caller:
; N64:       # %bb.0:
; N64-NEXT:    daddiu $sp, $sp, -16
; N64-NEXT:    .cfi_def_cfa_offset 16
; N64-NEXT:    sd $ra, 8($sp) # 8-byte Folded Spill
; N64-NEXT:    .cfi_offset 31, -8
; N64-NEXT:    lui $1, %highest(callee)
; N64-NEXT:    daddiu $1, $1, %higher(callee)
; N64-NEXT:    dsll $1, $1, 16
; N64-NEXT:    daddiu $1, $1, %hi(callee)
; N64-NEXT:    dsll $1, $1, 16
; N64-NEXT:    daddiu $25, $1, %lo(callee)
; N64-NEXT:    jalr.hb $25
; N64-NEXT:    nop
; N64-NEXT:    lui $1, %highest(val)
; N64-NEXT:    daddiu $1, $1, %higher(val)
; N64-NEXT:    dsll $1, $1, 16
; N64-NEXT:    daddiu $1, $1, %hi(val)
; N64-NEXT:    dsll $1, $1, 16
; N64-NEXT:    lui $2, %highest(memset)
; N64-NEXT:    daddiu $4, $1, %lo(val)
; N64-NEXT:    daddiu $1, $2, %higher(memset)
; N64-NEXT:    dsll $1, $1, 16
; N64-NEXT:    daddiu $1, $1, %hi(memset)
; N64-NEXT:    dsll $1, $1, 16
; N64-NEXT:    daddiu $25, $1, %lo(memset)
; N64-NEXT:    daddiu $5, $zero, 0
; N64-NEXT:    jalr.hb $25
; N64-NEXT:    daddiu $6, $zero, 80
; N64-NEXT:    ld $ra, 8($sp) # 8-byte Folded Reload
; N64-NEXT:    jr $ra
; N64-NEXT:    daddiu $sp, $sp, 16
  call void @callee()
  call void @llvm.memset.p0i8.i32(i8* align 4 bitcast ([20 x i32]* @val to i8*), i8 0, i32 80, i1 false)
  ret  void
}

