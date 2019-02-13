; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mcpu=pwr8 -mtriple=powerpc64le-unknown-unknown \
; RUN:   -ppc-vsr-nums-as-vr -ppc-asm-full-reg-names < %s | FileCheck %s

define dso_local signext i32 @caller(i32 signext %a, i32 signext %b) local_unnamed_addr {
; CHECK-LABEL: caller:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    mflr r0
; CHECK-NEXT:    std r0, 16(r1)
; CHECK-NEXT:    stdu r1, -240(r1)
; CHECK-NEXT:    .cfi_def_cfa_offset 240
; CHECK-NEXT:    .cfi_offset lr, 16
; CHECK-NEXT:    .cfi_offset v20, -192
; CHECK-NEXT:    li r5, 48
; CHECK-NEXT:    stxvd2x v20, r1, r5 # 16-byte Folded Spill
; CHECK-NEXT:    #APP
; CHECK-NEXT:    add r3, r3, r4
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    extsw r3, r3
; CHECK-NEXT:    bl callee
; CHECK-NEXT:    nop
; CHECK-NEXT:    li r4, 48
; CHECK-NEXT:    lxvd2x v20, r1, r4 # 16-byte Folded Reload
; CHECK-NEXT:    addi r1, r1, 240
; CHECK-NEXT:    ld r0, 16(r1)
; CHECK-NEXT:    mtlr r0
; CHECK-NEXT:    blr
entry:
  %0 = tail call i32 asm "add $0, $1, $2", "=r,r,r,~{v20}"(i32 %a, i32 %b)
  %call = tail call signext i32 @callee(i32 signext %0)
  ret i32 %call
}

declare signext i32 @callee(i32 signext) local_unnamed_addr

