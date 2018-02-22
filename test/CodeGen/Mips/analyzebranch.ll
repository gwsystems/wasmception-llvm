; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=mips-unknown-linux-gnu -mcpu=mips32   < %s | FileCheck %s -check-prefixes=MIPS32
; RUN: llc -mtriple=mips-unknown-linux-gnu -mcpu=mips32r2 < %s | FileCheck %s -check-prefixes=MIPS32R2
; RUN: llc -mtriple=mips-unknown-linux-gnu -mcpu=mips32r6 < %s | FileCheck %s -check-prefixes=MIPS32r6
; RUN: llc -mtriple=mips64-unknown-linux-gnu -mcpu=mips4    < %s | FileCheck %s -check-prefixes=MIPS4
; RUN: llc -mtriple=mips64-unknown-linux-gnu -mcpu=mips64   < %s | FileCheck %s -check-prefixes=MIPS64
; RUN: llc -mtriple=mips64-unknown-linux-gnu -mcpu=mips64r2 < %s | FileCheck %s -check-prefixes=MIPS64R2
; RUN: llc -mtriple=mips64-unknown-linux-gnu -mcpu=mips64r6 < %s | FileCheck %s -check-prefixes=MIPS64R6

define double @foo(double %a, double %b) nounwind readnone {
; MIPS32-LABEL: foo:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    mtc1 $zero, $f0
; MIPS32-NEXT:    mtc1 $zero, $f1
; MIPS32-NEXT:    c.ule.d $f12, $f0
; MIPS32-NEXT:    bc1f $BB0_2
; MIPS32-NEXT:    nop
; MIPS32-NEXT:  # %bb.1: # %if.else
; MIPS32-NEXT:    mtc1 $zero, $f12
; MIPS32-NEXT:    mtc1 $zero, $f13
; MIPS32-NEXT:    c.ule.d $f14, $f12
; MIPS32-NEXT:    bc1t $BB0_3
; MIPS32-NEXT:    nop
; MIPS32-NEXT:  $BB0_2: # %if.end6
; MIPS32-NEXT:    sub.d $f0, $f14, $f12
; MIPS32-NEXT:    add.d $f12, $f0, $f0
; MIPS32-NEXT:  $BB0_3: # %return
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    mov.d $f0, $f12
;
; MIPS32R2-LABEL: foo:
; MIPS32R2:       # %bb.0: # %entry
; MIPS32R2-NEXT:    mtc1 $zero, $f0
; MIPS32R2-NEXT:    mthc1 $zero, $f0
; MIPS32R2-NEXT:    c.ule.d $f12, $f0
; MIPS32R2-NEXT:    bc1f $BB0_2
; MIPS32R2-NEXT:    nop
; MIPS32R2-NEXT:  # %bb.1: # %if.else
; MIPS32R2-NEXT:    mtc1 $zero, $f12
; MIPS32R2-NEXT:    mthc1 $zero, $f12
; MIPS32R2-NEXT:    c.ule.d $f14, $f12
; MIPS32R2-NEXT:    bc1t $BB0_3
; MIPS32R2-NEXT:    nop
; MIPS32R2-NEXT:  $BB0_2: # %if.end6
; MIPS32R2-NEXT:    sub.d $f0, $f14, $f12
; MIPS32R2-NEXT:    add.d $f12, $f0, $f0
; MIPS32R2-NEXT:  $BB0_3: # %return
; MIPS32R2-NEXT:    jr $ra
; MIPS32R2-NEXT:    mov.d $f0, $f12
;
; MIPS32r6-LABEL: foo:
; MIPS32r6:       # %bb.0: # %entry
; MIPS32r6-NEXT:    mtc1 $zero, $f0
; MIPS32r6-NEXT:    mthc1 $zero, $f0
; MIPS32r6-NEXT:    cmp.lt.d $f0, $f0, $f12
; MIPS32r6-NEXT:    mfc1 $1, $f0
; MIPS32r6-NEXT:    andi $1, $1, 1
; MIPS32r6-NEXT:    bnezc $1, $BB0_2
; MIPS32r6-NEXT:  # %bb.1: # %if.else
; MIPS32r6-NEXT:    mtc1 $zero, $f12
; MIPS32r6-NEXT:    mthc1 $zero, $f12
; MIPS32r6-NEXT:    cmp.ule.d $f0, $f14, $f12
; MIPS32r6-NEXT:    mfc1 $1, $f0
; MIPS32r6-NEXT:    andi $1, $1, 1
; MIPS32r6-NEXT:    bnezc $1, $BB0_3
; MIPS32r6-NEXT:  $BB0_2: # %if.end6
; MIPS32r6-NEXT:    sub.d $f0, $f14, $f12
; MIPS32r6-NEXT:    add.d $f12, $f0, $f0
; MIPS32r6-NEXT:  $BB0_3: # %return
; MIPS32r6-NEXT:    jr $ra
; MIPS32r6-NEXT:    mov.d $f0, $f12
;
; MIPS4-LABEL: foo:
; MIPS4:       # %bb.0: # %entry
; MIPS4-NEXT:    dmtc1 $zero, $f0
; MIPS4-NEXT:    c.ule.d $f12, $f0
; MIPS4-NEXT:    bc1f .LBB0_2
; MIPS4-NEXT:    nop
; MIPS4-NEXT:  # %bb.1: # %if.else
; MIPS4-NEXT:    dmtc1 $zero, $f12
; MIPS4-NEXT:    c.ule.d $f13, $f12
; MIPS4-NEXT:    bc1t .LBB0_3
; MIPS4-NEXT:    nop
; MIPS4-NEXT:  .LBB0_2: # %if.end6
; MIPS4-NEXT:    sub.d $f0, $f13, $f12
; MIPS4-NEXT:    add.d $f12, $f0, $f0
; MIPS4-NEXT:  .LBB0_3: # %return
; MIPS4-NEXT:    jr $ra
; MIPS4-NEXT:    mov.d $f0, $f12
;
; MIPS64-LABEL: foo:
; MIPS64:       # %bb.0: # %entry
; MIPS64-NEXT:    dmtc1 $zero, $f0
; MIPS64-NEXT:    c.ule.d $f12, $f0
; MIPS64-NEXT:    bc1f .LBB0_2
; MIPS64-NEXT:    nop
; MIPS64-NEXT:  # %bb.1: # %if.else
; MIPS64-NEXT:    dmtc1 $zero, $f12
; MIPS64-NEXT:    c.ule.d $f13, $f12
; MIPS64-NEXT:    bc1t .LBB0_3
; MIPS64-NEXT:    nop
; MIPS64-NEXT:  .LBB0_2: # %if.end6
; MIPS64-NEXT:    sub.d $f0, $f13, $f12
; MIPS64-NEXT:    add.d $f12, $f0, $f0
; MIPS64-NEXT:  .LBB0_3: # %return
; MIPS64-NEXT:    jr $ra
; MIPS64-NEXT:    mov.d $f0, $f12
;
; MIPS64R2-LABEL: foo:
; MIPS64R2:       # %bb.0: # %entry
; MIPS64R2-NEXT:    dmtc1 $zero, $f0
; MIPS64R2-NEXT:    c.ule.d $f12, $f0
; MIPS64R2-NEXT:    bc1f .LBB0_2
; MIPS64R2-NEXT:    nop
; MIPS64R2-NEXT:  # %bb.1: # %if.else
; MIPS64R2-NEXT:    dmtc1 $zero, $f12
; MIPS64R2-NEXT:    c.ule.d $f13, $f12
; MIPS64R2-NEXT:    bc1t .LBB0_3
; MIPS64R2-NEXT:    nop
; MIPS64R2-NEXT:  .LBB0_2: # %if.end6
; MIPS64R2-NEXT:    sub.d $f0, $f13, $f12
; MIPS64R2-NEXT:    add.d $f12, $f0, $f0
; MIPS64R2-NEXT:  .LBB0_3: # %return
; MIPS64R2-NEXT:    jr $ra
; MIPS64R2-NEXT:    mov.d $f0, $f12
;
; MIPS64R6-LABEL: foo:
; MIPS64R6:       # %bb.0: # %entry
; MIPS64R6-NEXT:    dmtc1 $zero, $f0
; MIPS64R6-NEXT:    cmp.lt.d $f0, $f0, $f12
; MIPS64R6-NEXT:    mfc1 $1, $f0
; MIPS64R6-NEXT:    andi $1, $1, 1
; MIPS64R6-NEXT:    bnezc $1, .LBB0_2
; MIPS64R6-NEXT:  # %bb.1: # %if.else
; MIPS64R6-NEXT:    dmtc1 $zero, $f12
; MIPS64R6-NEXT:    cmp.ule.d $f0, $f13, $f12
; MIPS64R6-NEXT:    mfc1 $1, $f0
; MIPS64R6-NEXT:    andi $1, $1, 1
; MIPS64R6-NEXT:    bnezc $1, .LBB0_3
; MIPS64R6-NEXT:  .LBB0_2: # %if.end6
; MIPS64R6-NEXT:    sub.d $f0, $f13, $f12
; MIPS64R6-NEXT:    add.d $f12, $f0, $f0
; MIPS64R6-NEXT:  .LBB0_3: # %return
; MIPS64R6-NEXT:    jr $ra
; MIPS64R6-NEXT:    mov.d $f0, $f12
entry:
  %cmp = fcmp ogt double %a, 0.000000e+00
  br i1 %cmp, label %if.end6, label %if.else

if.else:                                          ; preds = %entry
  %cmp3 = fcmp ogt double %b, 0.000000e+00
  br i1 %cmp3, label %if.end6, label %return

if.end6:                                          ; preds = %if.else, %entry
  %c.0 = phi double [ %a, %entry ], [ 0.000000e+00, %if.else ]
  %sub = fsub double %b, %c.0
  %mul = fmul double %sub, 2.000000e+00
  br label %return

return:                                           ; preds = %if.else, %if.end6
  %retval.0 = phi double [ %mul, %if.end6 ], [ 0.000000e+00, %if.else ]
  ret double %retval.0
}

define void @f1(float %f) nounwind {
; MIPS32-LABEL: f1:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    addiu $sp, $sp, -24
; MIPS32-NEXT:    sw $ra, 20($sp) # 4-byte Folded Spill
; MIPS32-NEXT:    mtc1 $zero, $f0
; MIPS32-NEXT:    c.eq.s $f12, $f0
; MIPS32-NEXT:    bc1f $BB1_2
; MIPS32-NEXT:    nop
; MIPS32-NEXT:  # %bb.1: # %if.end
; MIPS32-NEXT:    jal f2
; MIPS32-NEXT:    nop
; MIPS32-NEXT:    lw $ra, 20($sp) # 4-byte Folded Reload
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    addiu $sp, $sp, 24
; MIPS32-NEXT:  $BB1_2: # %if.then
; MIPS32-NEXT:    jal abort
; MIPS32-NEXT:    nop
;
; MIPS32R2-LABEL: f1:
; MIPS32R2:       # %bb.0: # %entry
; MIPS32R2-NEXT:    addiu $sp, $sp, -24
; MIPS32R2-NEXT:    sw $ra, 20($sp) # 4-byte Folded Spill
; MIPS32R2-NEXT:    mtc1 $zero, $f0
; MIPS32R2-NEXT:    c.eq.s $f12, $f0
; MIPS32R2-NEXT:    bc1f $BB1_2
; MIPS32R2-NEXT:    nop
; MIPS32R2-NEXT:  # %bb.1: # %if.end
; MIPS32R2-NEXT:    jal f2
; MIPS32R2-NEXT:    nop
; MIPS32R2-NEXT:    lw $ra, 20($sp) # 4-byte Folded Reload
; MIPS32R2-NEXT:    jr $ra
; MIPS32R2-NEXT:    addiu $sp, $sp, 24
; MIPS32R2-NEXT:  $BB1_2: # %if.then
; MIPS32R2-NEXT:    jal abort
; MIPS32R2-NEXT:    nop
;
; MIPS32r6-LABEL: f1:
; MIPS32r6:       # %bb.0: # %entry
; MIPS32r6-NEXT:    addiu $sp, $sp, -24
; MIPS32r6-NEXT:    sw $ra, 20($sp) # 4-byte Folded Spill
; MIPS32r6-NEXT:    mtc1 $zero, $f0
; MIPS32r6-NEXT:    cmp.eq.s $f0, $f12, $f0
; MIPS32r6-NEXT:    mfc1 $1, $f0
; MIPS32r6-NEXT:    andi $1, $1, 1
; MIPS32r6-NEXT:    beqzc $1, $BB1_2
; MIPS32r6-NEXT:    nop
; MIPS32r6-NEXT:  # %bb.1: # %if.end
; MIPS32r6-NEXT:    jal f2
; MIPS32r6-NEXT:    nop
; MIPS32r6-NEXT:    lw $ra, 20($sp) # 4-byte Folded Reload
; MIPS32r6-NEXT:    jr $ra
; MIPS32r6-NEXT:    addiu $sp, $sp, 24
; MIPS32r6-NEXT:  $BB1_2: # %if.then
; MIPS32r6-NEXT:    jal abort
; MIPS32r6-NEXT:    nop
;
; MIPS4-LABEL: f1:
; MIPS4:       # %bb.0: # %entry
; MIPS4-NEXT:    daddiu $sp, $sp, -16
; MIPS4-NEXT:    sd $ra, 8($sp) # 8-byte Folded Spill
; MIPS4-NEXT:    mtc1 $zero, $f0
; MIPS4-NEXT:    c.eq.s $f12, $f0
; MIPS4-NEXT:    bc1f .LBB1_2
; MIPS4-NEXT:    nop
; MIPS4-NEXT:  # %bb.1: # %if.end
; MIPS4-NEXT:    jal f2
; MIPS4-NEXT:    nop
; MIPS4-NEXT:    ld $ra, 8($sp) # 8-byte Folded Reload
; MIPS4-NEXT:    jr $ra
; MIPS4-NEXT:    daddiu $sp, $sp, 16
; MIPS4-NEXT:  .LBB1_2: # %if.then
; MIPS4-NEXT:    jal abort
; MIPS4-NEXT:    nop
;
; MIPS64-LABEL: f1:
; MIPS64:       # %bb.0: # %entry
; MIPS64-NEXT:    daddiu $sp, $sp, -16
; MIPS64-NEXT:    sd $ra, 8($sp) # 8-byte Folded Spill
; MIPS64-NEXT:    mtc1 $zero, $f0
; MIPS64-NEXT:    c.eq.s $f12, $f0
; MIPS64-NEXT:    bc1f .LBB1_2
; MIPS64-NEXT:    nop
; MIPS64-NEXT:  # %bb.1: # %if.end
; MIPS64-NEXT:    jal f2
; MIPS64-NEXT:    nop
; MIPS64-NEXT:    ld $ra, 8($sp) # 8-byte Folded Reload
; MIPS64-NEXT:    jr $ra
; MIPS64-NEXT:    daddiu $sp, $sp, 16
; MIPS64-NEXT:  .LBB1_2: # %if.then
; MIPS64-NEXT:    jal abort
; MIPS64-NEXT:    nop
;
; MIPS64R2-LABEL: f1:
; MIPS64R2:       # %bb.0: # %entry
; MIPS64R2-NEXT:    daddiu $sp, $sp, -16
; MIPS64R2-NEXT:    sd $ra, 8($sp) # 8-byte Folded Spill
; MIPS64R2-NEXT:    mtc1 $zero, $f0
; MIPS64R2-NEXT:    c.eq.s $f12, $f0
; MIPS64R2-NEXT:    bc1f .LBB1_2
; MIPS64R2-NEXT:    nop
; MIPS64R2-NEXT:  # %bb.1: # %if.end
; MIPS64R2-NEXT:    jal f2
; MIPS64R2-NEXT:    nop
; MIPS64R2-NEXT:    ld $ra, 8($sp) # 8-byte Folded Reload
; MIPS64R2-NEXT:    jr $ra
; MIPS64R2-NEXT:    daddiu $sp, $sp, 16
; MIPS64R2-NEXT:  .LBB1_2: # %if.then
; MIPS64R2-NEXT:    jal abort
; MIPS64R2-NEXT:    nop
;
; MIPS64R6-LABEL: f1:
; MIPS64R6:       # %bb.0: # %entry
; MIPS64R6-NEXT:    daddiu $sp, $sp, -16
; MIPS64R6-NEXT:    sd $ra, 8($sp) # 8-byte Folded Spill
; MIPS64R6-NEXT:    mtc1 $zero, $f0
; MIPS64R6-NEXT:    cmp.eq.s $f0, $f12, $f0
; MIPS64R6-NEXT:    mfc1 $1, $f0
; MIPS64R6-NEXT:    andi $1, $1, 1
; MIPS64R6-NEXT:    beqzc $1, .LBB1_2
; MIPS64R6-NEXT:    nop
; MIPS64R6-NEXT:  # %bb.1: # %if.end
; MIPS64R6-NEXT:    jal f2
; MIPS64R6-NEXT:    nop
; MIPS64R6-NEXT:    ld $ra, 8($sp) # 8-byte Folded Reload
; MIPS64R6-NEXT:    jr $ra
; MIPS64R6-NEXT:    daddiu $sp, $sp, 16
; MIPS64R6-NEXT:  .LBB1_2: # %if.then
; MIPS64R6-NEXT:    jal abort
; MIPS64R6-NEXT:    nop
entry:
  %cmp = fcmp une float %f, 0.000000e+00
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  tail call void @abort() noreturn
  unreachable

if.end:                                           ; preds = %entry
  tail call void (...) @f2() nounwind
  ret void
}

declare void @abort() noreturn nounwind

declare void @f2(...)
