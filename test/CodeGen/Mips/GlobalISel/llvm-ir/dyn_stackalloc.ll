; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc  -O0 -mtriple=mipsel-linux-gnu -global-isel  -verify-machineinstrs %s -o -| FileCheck %s -check-prefixes=MIPS32

declare i32 @puts(i8*)
declare void @llvm.memset.p0i8.i32(i8*, i8, i32, i1)

define void @Print_c_N_times(i8 %c, i32 %N) {
; MIPS32-LABEL: Print_c_N_times:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    addiu $sp, $sp, -32
; MIPS32-NEXT:    .cfi_def_cfa_offset 32
; MIPS32-NEXT:    sw $ra, 28($sp) # 4-byte Folded Spill
; MIPS32-NEXT:    sw $fp, 24($sp) # 4-byte Folded Spill
; MIPS32-NEXT:    .cfi_offset 31, -4
; MIPS32-NEXT:    .cfi_offset 30, -8
; MIPS32-NEXT:    move $fp, $sp
; MIPS32-NEXT:    .cfi_def_cfa_register 30
; MIPS32-NEXT:    ori $1, $zero, 1
; MIPS32-NEXT:    ori $2, $zero, 0
; MIPS32-NEXT:    addu $3, $5, $1
; MIPS32-NEXT:    mul $1, $3, $1
; MIPS32-NEXT:    ori $3, $zero, 7
; MIPS32-NEXT:    addu $1, $1, $3
; MIPS32-NEXT:    addiu $3, $zero, 65528
; MIPS32-NEXT:    and $1, $1, $3
; MIPS32-NEXT:    move $3, $sp
; MIPS32-NEXT:    subu $1, $3, $1
; MIPS32-NEXT:    move $sp, $1
; MIPS32-NEXT:    addiu $sp, $sp, -16
; MIPS32-NEXT:    sw $4, 20($fp) # 4-byte Folded Spill
; MIPS32-NEXT:    move $4, $1
; MIPS32-NEXT:    lw $3, 20($fp) # 4-byte Folded Reload
; MIPS32-NEXT:    sw $5, 16($fp) # 4-byte Folded Spill
; MIPS32-NEXT:    move $5, $3
; MIPS32-NEXT:    lw $6, 16($fp) # 4-byte Folded Reload
; MIPS32-NEXT:    sw $2, 12($fp) # 4-byte Folded Spill
; MIPS32-NEXT:    sw $1, 8($fp) # 4-byte Folded Spill
; MIPS32-NEXT:    jal memset
; MIPS32-NEXT:    nop
; MIPS32-NEXT:    addiu $sp, $sp, 16
; MIPS32-NEXT:    lw $1, 8($fp) # 4-byte Folded Reload
; MIPS32-NEXT:    lw $2, 16($fp) # 4-byte Folded Reload
; MIPS32-NEXT:    addu $3, $1, $2
; MIPS32-NEXT:    lw $4, 12($fp) # 4-byte Folded Reload
; MIPS32-NEXT:    sb $4, 0($3)
; MIPS32-NEXT:    addiu $sp, $sp, -16
; MIPS32-NEXT:    move $4, $1
; MIPS32-NEXT:    jal puts
; MIPS32-NEXT:    nop
; MIPS32-NEXT:    addiu $sp, $sp, 16
; MIPS32-NEXT:    move $sp, $fp
; MIPS32-NEXT:    lw $fp, 24($sp) # 4-byte Folded Reload
; MIPS32-NEXT:    lw $ra, 28($sp) # 4-byte Folded Reload
; MIPS32-NEXT:    addiu $sp, $sp, 32
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %add = add i32 %N, 1
  %vla = alloca i8, i32 %add, align 1
  call void @llvm.memset.p0i8.i32(i8* align 1 %vla, i8 %c, i32 %N, i1 false)
  %arrayidx = getelementptr inbounds i8, i8* %vla, i32 %N
  store i8 0, i8* %arrayidx, align 1
  %call = call i32 @puts(i8* %vla)
  ret void
}
