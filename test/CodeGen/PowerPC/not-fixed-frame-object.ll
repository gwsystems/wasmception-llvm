; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mcpu=pwr9 -mtriple=powerpc64le-unknown-unknown \
; RUN:   -ppc-vsr-nums-as-vr -ppc-asm-full-reg-names < %s | FileCheck %s

define dso_local signext i32 @caller(i32 signext %a, i32 signext %b, i32 signext %c) local_unnamed_addr {
; CHECK-LABEL: caller:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    mflr r0
; CHECK-NEXT:    .cfi_def_cfa_offset 192
; CHECK-NEXT:    .cfi_offset lr, 16
; CHECK-NEXT:    .cfi_offset r14, -144
; CHECK-NEXT:    .cfi_offset r15, -136
; CHECK-NEXT:    .cfi_offset r16, -128
; CHECK-NEXT:    .cfi_offset r17, -120
; CHECK-NEXT:    .cfi_offset r18, -112
; CHECK-NEXT:    .cfi_offset r19, -104
; CHECK-NEXT:    .cfi_offset r20, -96
; CHECK-NEXT:    .cfi_offset r21, -88
; CHECK-NEXT:    .cfi_offset r22, -80
; CHECK-NEXT:    .cfi_offset r23, -72
; CHECK-NEXT:    .cfi_offset r24, -64
; CHECK-NEXT:    .cfi_offset r25, -56
; CHECK-NEXT:    .cfi_offset r26, -48
; CHECK-NEXT:    .cfi_offset r27, -40
; CHECK-NEXT:    .cfi_offset r28, -32
; CHECK-NEXT:    .cfi_offset r29, -24
; CHECK-NEXT:    .cfi_offset r30, -16
; CHECK-NEXT:    .cfi_offset r31, -8
; CHECK-NEXT:    std r14, -144(r1) # 8-byte Folded Spill
; CHECK-NEXT:    std r15, -136(r1) # 8-byte Folded Spill
; CHECK-NEXT:    std r16, -128(r1) # 8-byte Folded Spill
; CHECK-NEXT:    std r17, -120(r1) # 8-byte Folded Spill
; CHECK-NEXT:    std r18, -112(r1) # 8-byte Folded Spill
; CHECK-NEXT:    std r19, -104(r1) # 8-byte Folded Spill
; CHECK-NEXT:    std r20, -96(r1) # 8-byte Folded Spill
; CHECK-NEXT:    std r21, -88(r1) # 8-byte Folded Spill
; CHECK-NEXT:    std r22, -80(r1) # 8-byte Folded Spill
; CHECK-NEXT:    std r23, -72(r1) # 8-byte Folded Spill
; CHECK-NEXT:    std r24, -64(r1) # 8-byte Folded Spill
; CHECK-NEXT:    std r25, -56(r1) # 8-byte Folded Spill
; CHECK-NEXT:    std r26, -48(r1) # 8-byte Folded Spill
; CHECK-NEXT:    std r27, -40(r1) # 8-byte Folded Spill
; CHECK-NEXT:    std r28, -32(r1) # 8-byte Folded Spill
; CHECK-NEXT:    std r29, -24(r1) # 8-byte Folded Spill
; CHECK-NEXT:    std r30, -16(r1) # 8-byte Folded Spill
; CHECK-NEXT:    std r31, -8(r1) # 8-byte Folded Spill
; CHECK-NEXT:    std r0, 16(r1)
; CHECK-NEXT:    stdu r1, -192(r1)
; CHECK-NEXT:    std r5, 32(r1) # 8-byte Folded Spill
; CHECK-NEXT:    std r3, 40(r1) # 8-byte Folded Spill
; CHECK-NEXT:    mr r0, r4
; CHECK-NEXT:    ld r3, 40(r1) # 8-byte Folded Reload
; CHECK-NEXT:    #APP
; CHECK-NEXT:    add r3, r3, r0
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    ld r4, 40(r1) # 8-byte Folded Reload
; CHECK-NEXT:    ld r6, 32(r1) # 8-byte Folded Reload
; CHECK-NEXT:    extsw r3, r3
; CHECK-NEXT:    mr r5, r0
; CHECK-NEXT:    bl callee
; CHECK-NEXT:    nop
; CHECK-NEXT:    addi r1, r1, 192
; CHECK-NEXT:    ld r0, 16(r1)
; CHECK-NEXT:    mtlr r0
; CHECK-NEXT:    ld r31, -8(r1) # 8-byte Folded Reload
; CHECK-NEXT:    ld r30, -16(r1) # 8-byte Folded Reload
; CHECK-NEXT:    ld r29, -24(r1) # 8-byte Folded Reload
; CHECK-NEXT:    ld r28, -32(r1) # 8-byte Folded Reload
; CHECK-NEXT:    ld r27, -40(r1) # 8-byte Folded Reload
; CHECK-NEXT:    ld r26, -48(r1) # 8-byte Folded Reload
; CHECK-NEXT:    ld r25, -56(r1) # 8-byte Folded Reload
; CHECK-NEXT:    ld r24, -64(r1) # 8-byte Folded Reload
; CHECK-NEXT:    ld r23, -72(r1) # 8-byte Folded Reload
; CHECK-NEXT:    ld r22, -80(r1) # 8-byte Folded Reload
; CHECK-NEXT:    ld r21, -88(r1) # 8-byte Folded Reload
; CHECK-NEXT:    ld r20, -96(r1) # 8-byte Folded Reload
; CHECK-NEXT:    ld r19, -104(r1) # 8-byte Folded Reload
; CHECK-NEXT:    ld r18, -112(r1) # 8-byte Folded Reload
; CHECK-NEXT:    ld r17, -120(r1) # 8-byte Folded Reload
; CHECK-NEXT:    ld r16, -128(r1) # 8-byte Folded Reload
; CHECK-NEXT:    ld r15, -136(r1) # 8-byte Folded Reload
; CHECK-NEXT:    ld r14, -144(r1) # 8-byte Folded Reload
; CHECK-NEXT:    blr
entry:
  %0 = tail call i32 asm "add $0, $1, $2", "=r,r,r,~{r14},~{r15},~{r16},~{r17},~{r18},~{r19},~{r20},~{r21},~{r22},~{r23},~{r24},~{r25},~{r26},~{r27},~{r28},~{r29},~{r30},~{r31},~{r4},~{r5},~{r6},~{r7},~{r8},~{r9},~{r10},~{r11},~{r12},~{r13}"(i32 %a, i32 %b)
  %call = tail call signext i32 @callee(i32 signext %0, i32 signext %a, i32 signext %b, i32 signext %c)
  ret i32 %call
}

declare signext i32 @callee(i32 signext, i32 signext, i32 signext, i32 signext) local_unnamed_addr

