; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=thumbv6m-none-eabi | FileCheck %s --check-prefix=CHECK-T1
; RUN: llc < %s -mtriple=thumbv7m-none-eabi | FileCheck %s --check-prefix=CHECK-T2 --check-prefix=CHECK-T2NODSP
; RUN: llc < %s -mtriple=thumbv7em-none-eabi | FileCheck %s --check-prefix=CHECK-T2 --check-prefix=CHECK-T2DSP
; RUN: llc < %s -mtriple=armv5t-none-eabi | FileCheck %s --check-prefix=CHECK-ARM --check-prefix=CHECK-ARMNODPS
; RUN: llc < %s -mtriple=armv5te-none-eabi | FileCheck %s --check-prefix=CHECK-ARM --check-prefix=CHECK-ARMBASEDSP
; RUN: llc < %s -mtriple=armv6-none-eabi | FileCheck %s --check-prefix=CHECK-ARM --check-prefix=CHECK-ARMDSP

declare i4 @llvm.sadd.sat.i4(i4, i4)
declare i8 @llvm.sadd.sat.i8(i8, i8)
declare i16 @llvm.sadd.sat.i16(i16, i16)
declare i32 @llvm.sadd.sat.i32(i32, i32)
declare i64 @llvm.sadd.sat.i64(i64, i64)

define i32 @func(i32 %x, i32 %y) nounwind {
; CHECK-T1-LABEL: func:
; CHECK-T1:       @ %bb.0:
; CHECK-T1-NEXT:    mov r2, r0
; CHECK-T1-NEXT:    movs r3, #1
; CHECK-T1-NEXT:    adds r0, r0, r1
; CHECK-T1-NEXT:    mov r1, r3
; CHECK-T1-NEXT:    bmi .LBB0_2
; CHECK-T1-NEXT:  @ %bb.1:
; CHECK-T1-NEXT:    movs r1, #0
; CHECK-T1-NEXT:  .LBB0_2:
; CHECK-T1-NEXT:    cmp r1, #0
; CHECK-T1-NEXT:    bne .LBB0_4
; CHECK-T1-NEXT:  @ %bb.3:
; CHECK-T1-NEXT:    lsls r1, r3, #31
; CHECK-T1-NEXT:    cmp r0, r2
; CHECK-T1-NEXT:    bvs .LBB0_5
; CHECK-T1-NEXT:    b .LBB0_6
; CHECK-T1-NEXT:  .LBB0_4:
; CHECK-T1-NEXT:    ldr r1, .LCPI0_0
; CHECK-T1-NEXT:    cmp r0, r2
; CHECK-T1-NEXT:    bvc .LBB0_6
; CHECK-T1-NEXT:  .LBB0_5:
; CHECK-T1-NEXT:    mov r0, r1
; CHECK-T1-NEXT:  .LBB0_6:
; CHECK-T1-NEXT:    bx lr
; CHECK-T1-NEXT:    .p2align 2
; CHECK-T1-NEXT:  @ %bb.7:
; CHECK-T1-NEXT:  .LCPI0_0:
; CHECK-T1-NEXT:    .long 2147483647 @ 0x7fffffff
;
; CHECK-T2NODSP-LABEL: func:
; CHECK-T2NODSP:       @ %bb.0:
; CHECK-T2NODSP-NEXT:    adds r2, r0, r1
; CHECK-T2NODSP-NEXT:    mov.w r3, #0
; CHECK-T2NODSP-NEXT:    mov.w r1, #-2147483648
; CHECK-T2NODSP-NEXT:    it mi
; CHECK-T2NODSP-NEXT:    movmi r3, #1
; CHECK-T2NODSP-NEXT:    cmp r3, #0
; CHECK-T2NODSP-NEXT:    it ne
; CHECK-T2NODSP-NEXT:    mvnne r1, #-2147483648
; CHECK-T2NODSP-NEXT:    cmp r2, r0
; CHECK-T2NODSP-NEXT:    it vc
; CHECK-T2NODSP-NEXT:    movvc r1, r2
; CHECK-T2NODSP-NEXT:    mov r0, r1
; CHECK-T2NODSP-NEXT:    bx lr
;
; CHECK-T2DSP-LABEL: func:
; CHECK-T2DSP:       @ %bb.0:
; CHECK-T2DSP-NEXT:    qadd r0, r0, r1
; CHECK-T2DSP-NEXT:    bx lr
;
; CHECK-ARMNODPS-LABEL: func:
; CHECK-ARMNODPS:       @ %bb.0:
; CHECK-ARMNODPS-NEXT:    adds r2, r0, r1
; CHECK-ARMNODPS-NEXT:    mov r3, #0
; CHECK-ARMNODPS-NEXT:    movmi r3, #1
; CHECK-ARMNODPS-NEXT:    mov r1, #-2147483648
; CHECK-ARMNODPS-NEXT:    cmp r3, #0
; CHECK-ARMNODPS-NEXT:    mvnne r1, #-2147483648
; CHECK-ARMNODPS-NEXT:    cmp r2, r0
; CHECK-ARMNODPS-NEXT:    movvc r1, r2
; CHECK-ARMNODPS-NEXT:    mov r0, r1
; CHECK-ARMNODPS-NEXT:    bx lr
;
; CHECK-ARMBASEDSP-LABEL: func:
; CHECK-ARMBASEDSP:       @ %bb.0:
; CHECK-ARMBASEDSP-NEXT:    qadd r0, r0, r1
; CHECK-ARMBASEDSP-NEXT:    bx lr
;
; CHECK-ARMDSP-LABEL: func:
; CHECK-ARMDSP:       @ %bb.0:
; CHECK-ARMDSP-NEXT:    qadd r0, r0, r1
; CHECK-ARMDSP-NEXT:    bx lr
  %tmp = call i32 @llvm.sadd.sat.i32(i32 %x, i32 %y)
  ret i32 %tmp
}

define i64 @func2(i64 %x, i64 %y) nounwind {
; CHECK-T1-LABEL: func2:
; CHECK-T1:       @ %bb.0:
; CHECK-T1-NEXT:    .save {r4, r5, r6, r7, lr}
; CHECK-T1-NEXT:    push {r4, r5, r6, r7, lr}
; CHECK-T1-NEXT:    .pad #4
; CHECK-T1-NEXT:    sub sp, #4
; CHECK-T1-NEXT:    str r2, [sp] @ 4-byte Spill
; CHECK-T1-NEXT:    mov r2, r0
; CHECK-T1-NEXT:    movs r4, #1
; CHECK-T1-NEXT:    movs r0, #0
; CHECK-T1-NEXT:    cmp r3, #0
; CHECK-T1-NEXT:    mov r5, r4
; CHECK-T1-NEXT:    bge .LBB1_2
; CHECK-T1-NEXT:  @ %bb.1:
; CHECK-T1-NEXT:    mov r5, r0
; CHECK-T1-NEXT:  .LBB1_2:
; CHECK-T1-NEXT:    cmp r1, #0
; CHECK-T1-NEXT:    mov r7, r4
; CHECK-T1-NEXT:    bge .LBB1_4
; CHECK-T1-NEXT:  @ %bb.3:
; CHECK-T1-NEXT:    mov r7, r0
; CHECK-T1-NEXT:  .LBB1_4:
; CHECK-T1-NEXT:    subs r6, r7, r5
; CHECK-T1-NEXT:    rsbs r5, r6, #0
; CHECK-T1-NEXT:    adcs r5, r6
; CHECK-T1-NEXT:    ldr r6, [sp] @ 4-byte Reload
; CHECK-T1-NEXT:    adds r6, r2, r6
; CHECK-T1-NEXT:    adcs r1, r3
; CHECK-T1-NEXT:    cmp r1, #0
; CHECK-T1-NEXT:    mov r2, r4
; CHECK-T1-NEXT:    bge .LBB1_6
; CHECK-T1-NEXT:  @ %bb.5:
; CHECK-T1-NEXT:    mov r2, r0
; CHECK-T1-NEXT:  .LBB1_6:
; CHECK-T1-NEXT:    subs r0, r7, r2
; CHECK-T1-NEXT:    subs r2, r0, #1
; CHECK-T1-NEXT:    sbcs r0, r2
; CHECK-T1-NEXT:    ands r5, r0
; CHECK-T1-NEXT:    beq .LBB1_8
; CHECK-T1-NEXT:  @ %bb.7:
; CHECK-T1-NEXT:    asrs r6, r1, #31
; CHECK-T1-NEXT:  .LBB1_8:
; CHECK-T1-NEXT:    cmp r1, #0
; CHECK-T1-NEXT:    bmi .LBB1_10
; CHECK-T1-NEXT:  @ %bb.9:
; CHECK-T1-NEXT:    lsls r2, r4, #31
; CHECK-T1-NEXT:    cmp r5, #0
; CHECK-T1-NEXT:    beq .LBB1_11
; CHECK-T1-NEXT:    b .LBB1_12
; CHECK-T1-NEXT:  .LBB1_10:
; CHECK-T1-NEXT:    ldr r2, .LCPI1_0
; CHECK-T1-NEXT:    cmp r5, #0
; CHECK-T1-NEXT:    bne .LBB1_12
; CHECK-T1-NEXT:  .LBB1_11:
; CHECK-T1-NEXT:    mov r2, r1
; CHECK-T1-NEXT:  .LBB1_12:
; CHECK-T1-NEXT:    mov r0, r6
; CHECK-T1-NEXT:    mov r1, r2
; CHECK-T1-NEXT:    add sp, #4
; CHECK-T1-NEXT:    pop {r4, r5, r6, r7, pc}
; CHECK-T1-NEXT:    .p2align 2
; CHECK-T1-NEXT:  @ %bb.13:
; CHECK-T1-NEXT:  .LCPI1_0:
; CHECK-T1-NEXT:    .long 2147483647 @ 0x7fffffff
;
; CHECK-T2-LABEL: func2:
; CHECK-T2:       @ %bb.0:
; CHECK-T2-NEXT:    .save {r7, lr}
; CHECK-T2-NEXT:    push {r7, lr}
; CHECK-T2-NEXT:    cmp.w r1, #-1
; CHECK-T2-NEXT:    mov.w lr, #0
; CHECK-T2-NEXT:    it gt
; CHECK-T2-NEXT:    movgt.w lr, #1
; CHECK-T2-NEXT:    adds r0, r0, r2
; CHECK-T2-NEXT:    adc.w r2, r1, r3
; CHECK-T2-NEXT:    movs r1, #0
; CHECK-T2-NEXT:    cmp.w r2, #-1
; CHECK-T2-NEXT:    it gt
; CHECK-T2-NEXT:    movgt r1, #1
; CHECK-T2-NEXT:    subs.w r1, lr, r1
; CHECK-T2-NEXT:    mov.w r12, #0
; CHECK-T2-NEXT:    it ne
; CHECK-T2-NEXT:    movne r1, #1
; CHECK-T2-NEXT:    cmp.w r3, #-1
; CHECK-T2-NEXT:    it gt
; CHECK-T2-NEXT:    movgt.w r12, #1
; CHECK-T2-NEXT:    sub.w r3, lr, r12
; CHECK-T2-NEXT:    clz r3, r3
; CHECK-T2-NEXT:    lsrs r3, r3, #5
; CHECK-T2-NEXT:    ands r3, r1
; CHECK-T2-NEXT:    mov.w r1, #-2147483648
; CHECK-T2-NEXT:    it ne
; CHECK-T2-NEXT:    asrne r0, r2, #31
; CHECK-T2-NEXT:    cmp r2, #0
; CHECK-T2-NEXT:    it mi
; CHECK-T2-NEXT:    mvnmi r1, #-2147483648
; CHECK-T2-NEXT:    cmp r3, #0
; CHECK-T2-NEXT:    it eq
; CHECK-T2-NEXT:    moveq r1, r2
; CHECK-T2-NEXT:    pop {r7, pc}
;
; CHECK-ARM-LABEL: func2:
; CHECK-ARM:       @ %bb.0:
; CHECK-ARM-NEXT:    .save {r11, lr}
; CHECK-ARM-NEXT:    push {r11, lr}
; CHECK-ARM-NEXT:    cmn r1, #1
; CHECK-ARM-NEXT:    mov lr, #0
; CHECK-ARM-NEXT:    movgt lr, #1
; CHECK-ARM-NEXT:    adds r0, r0, r2
; CHECK-ARM-NEXT:    adc r2, r1, r3
; CHECK-ARM-NEXT:    mov r1, #0
; CHECK-ARM-NEXT:    cmn r2, #1
; CHECK-ARM-NEXT:    mov r12, #0
; CHECK-ARM-NEXT:    movgt r1, #1
; CHECK-ARM-NEXT:    subs r1, lr, r1
; CHECK-ARM-NEXT:    movne r1, #1
; CHECK-ARM-NEXT:    cmn r3, #1
; CHECK-ARM-NEXT:    movgt r12, #1
; CHECK-ARM-NEXT:    sub r3, lr, r12
; CHECK-ARM-NEXT:    clz r3, r3
; CHECK-ARM-NEXT:    lsr r3, r3, #5
; CHECK-ARM-NEXT:    ands r3, r3, r1
; CHECK-ARM-NEXT:    mov r1, #-2147483648
; CHECK-ARM-NEXT:    asrne r0, r2, #31
; CHECK-ARM-NEXT:    cmp r2, #0
; CHECK-ARM-NEXT:    mvnmi r1, #-2147483648
; CHECK-ARM-NEXT:    cmp r3, #0
; CHECK-ARM-NEXT:    moveq r1, r2
; CHECK-ARM-NEXT:    pop {r11, pc}
  %tmp = call i64 @llvm.sadd.sat.i64(i64 %x, i64 %y)
  ret i64 %tmp
}

define signext i16 @func16(i16 signext %x, i16 signext %y) nounwind {
; CHECK-T1-LABEL: func16:
; CHECK-T1:       @ %bb.0:
; CHECK-T1-NEXT:    adds r0, r0, r1
; CHECK-T1-NEXT:    ldr r1, .LCPI2_0
; CHECK-T1-NEXT:    cmp r0, r1
; CHECK-T1-NEXT:    blt .LBB2_2
; CHECK-T1-NEXT:  @ %bb.1:
; CHECK-T1-NEXT:    mov r0, r1
; CHECK-T1-NEXT:  .LBB2_2:
; CHECK-T1-NEXT:    ldr r1, .LCPI2_1
; CHECK-T1-NEXT:    cmp r0, r1
; CHECK-T1-NEXT:    bgt .LBB2_4
; CHECK-T1-NEXT:  @ %bb.3:
; CHECK-T1-NEXT:    mov r0, r1
; CHECK-T1-NEXT:  .LBB2_4:
; CHECK-T1-NEXT:    bx lr
; CHECK-T1-NEXT:    .p2align 2
; CHECK-T1-NEXT:  @ %bb.5:
; CHECK-T1-NEXT:  .LCPI2_0:
; CHECK-T1-NEXT:    .long 32767 @ 0x7fff
; CHECK-T1-NEXT:  .LCPI2_1:
; CHECK-T1-NEXT:    .long 4294934528 @ 0xffff8000
;
; CHECK-T2NODSP-LABEL: func16:
; CHECK-T2NODSP:       @ %bb.0:
; CHECK-T2NODSP-NEXT:    add r0, r1
; CHECK-T2NODSP-NEXT:    movw r1, #32767
; CHECK-T2NODSP-NEXT:    cmp r0, r1
; CHECK-T2NODSP-NEXT:    it lt
; CHECK-T2NODSP-NEXT:    movlt r1, r0
; CHECK-T2NODSP-NEXT:    movw r0, #32768
; CHECK-T2NODSP-NEXT:    cmn.w r1, #32768
; CHECK-T2NODSP-NEXT:    movt r0, #65535
; CHECK-T2NODSP-NEXT:    it gt
; CHECK-T2NODSP-NEXT:    movgt r0, r1
; CHECK-T2NODSP-NEXT:    bx lr
;
; CHECK-T2DSP-LABEL: func16:
; CHECK-T2DSP:       @ %bb.0:
; CHECK-T2DSP-NEXT:    qadd16 r0, r0, r1
; CHECK-T2DSP-NEXT:    sxth r0, r0
; CHECK-T2DSP-NEXT:    bx lr
;
; CHECK-ARMNODPS-LABEL: func16:
; CHECK-ARMNODPS:       @ %bb.0:
; CHECK-ARMNODPS-NEXT:    add r0, r0, r1
; CHECK-ARMNODPS-NEXT:    mov r1, #255
; CHECK-ARMNODPS-NEXT:    orr r1, r1, #32512
; CHECK-ARMNODPS-NEXT:    cmp r0, r1
; CHECK-ARMNODPS-NEXT:    movlt r1, r0
; CHECK-ARMNODPS-NEXT:    ldr r0, .LCPI2_0
; CHECK-ARMNODPS-NEXT:    cmn r1, #32768
; CHECK-ARMNODPS-NEXT:    movgt r0, r1
; CHECK-ARMNODPS-NEXT:    bx lr
; CHECK-ARMNODPS-NEXT:    .p2align 2
; CHECK-ARMNODPS-NEXT:  @ %bb.1:
; CHECK-ARMNODPS-NEXT:  .LCPI2_0:
; CHECK-ARMNODPS-NEXT:    .long 4294934528 @ 0xffff8000
;
; CHECK-ARMBASEDSP-LABEL: func16:
; CHECK-ARMBASEDSP:       @ %bb.0:
; CHECK-ARMBASEDSP-NEXT:    lsl r0, r0, #16
; CHECK-ARMBASEDSP-NEXT:    lsl r1, r1, #16
; CHECK-ARMBASEDSP-NEXT:    qadd r0, r0, r1
; CHECK-ARMBASEDSP-NEXT:    asr r0, r0, #16
; CHECK-ARMBASEDSP-NEXT:    bx lr
;
; CHECK-ARMDSP-LABEL: func16:
; CHECK-ARMDSP:       @ %bb.0:
; CHECK-ARMDSP-NEXT:    qadd16 r0, r0, r1
; CHECK-ARMDSP-NEXT:    sxth r0, r0
; CHECK-ARMDSP-NEXT:    bx lr
  %tmp = call i16 @llvm.sadd.sat.i16(i16 %x, i16 %y)
  ret i16 %tmp
}

define signext i8 @func8(i8 signext %x, i8 signext %y) nounwind {
; CHECK-T1-LABEL: func8:
; CHECK-T1:       @ %bb.0:
; CHECK-T1-NEXT:    adds r0, r0, r1
; CHECK-T1-NEXT:    movs r1, #127
; CHECK-T1-NEXT:    cmp r0, #127
; CHECK-T1-NEXT:    blt .LBB3_2
; CHECK-T1-NEXT:  @ %bb.1:
; CHECK-T1-NEXT:    mov r0, r1
; CHECK-T1-NEXT:  .LBB3_2:
; CHECK-T1-NEXT:    mvns r1, r1
; CHECK-T1-NEXT:    cmp r0, r1
; CHECK-T1-NEXT:    bgt .LBB3_4
; CHECK-T1-NEXT:  @ %bb.3:
; CHECK-T1-NEXT:    mov r0, r1
; CHECK-T1-NEXT:  .LBB3_4:
; CHECK-T1-NEXT:    bx lr
;
; CHECK-T2NODSP-LABEL: func8:
; CHECK-T2NODSP:       @ %bb.0:
; CHECK-T2NODSP-NEXT:    add r0, r1
; CHECK-T2NODSP-NEXT:    cmp r0, #127
; CHECK-T2NODSP-NEXT:    it ge
; CHECK-T2NODSP-NEXT:    movge r0, #127
; CHECK-T2NODSP-NEXT:    cmn.w r0, #128
; CHECK-T2NODSP-NEXT:    it le
; CHECK-T2NODSP-NEXT:    mvnle r0, #127
; CHECK-T2NODSP-NEXT:    bx lr
;
; CHECK-T2DSP-LABEL: func8:
; CHECK-T2DSP:       @ %bb.0:
; CHECK-T2DSP-NEXT:    qadd8 r0, r0, r1
; CHECK-T2DSP-NEXT:    sxtb r0, r0
; CHECK-T2DSP-NEXT:    bx lr
;
; CHECK-ARMNODPS-LABEL: func8:
; CHECK-ARMNODPS:       @ %bb.0:
; CHECK-ARMNODPS-NEXT:    add r0, r0, r1
; CHECK-ARMNODPS-NEXT:    cmp r0, #127
; CHECK-ARMNODPS-NEXT:    movge r0, #127
; CHECK-ARMNODPS-NEXT:    cmn r0, #128
; CHECK-ARMNODPS-NEXT:    mvnle r0, #127
; CHECK-ARMNODPS-NEXT:    bx lr
;
; CHECK-ARMBASEDSP-LABEL: func8:
; CHECK-ARMBASEDSP:       @ %bb.0:
; CHECK-ARMBASEDSP-NEXT:    lsl r0, r0, #24
; CHECK-ARMBASEDSP-NEXT:    lsl r1, r1, #24
; CHECK-ARMBASEDSP-NEXT:    qadd r0, r0, r1
; CHECK-ARMBASEDSP-NEXT:    asr r0, r0, #24
; CHECK-ARMBASEDSP-NEXT:    bx lr
;
; CHECK-ARMDSP-LABEL: func8:
; CHECK-ARMDSP:       @ %bb.0:
; CHECK-ARMDSP-NEXT:    qadd8 r0, r0, r1
; CHECK-ARMDSP-NEXT:    sxtb r0, r0
; CHECK-ARMDSP-NEXT:    bx lr
  %tmp = call i8 @llvm.sadd.sat.i8(i8 %x, i8 %y)
  ret i8 %tmp
}

define signext i4 @func3(i4 signext %x, i4 signext %y) nounwind {
; CHECK-T1-LABEL: func3:
; CHECK-T1:       @ %bb.0:
; CHECK-T1-NEXT:    adds r0, r0, r1
; CHECK-T1-NEXT:    movs r1, #7
; CHECK-T1-NEXT:    cmp r0, #7
; CHECK-T1-NEXT:    blt .LBB4_2
; CHECK-T1-NEXT:  @ %bb.1:
; CHECK-T1-NEXT:    mov r0, r1
; CHECK-T1-NEXT:  .LBB4_2:
; CHECK-T1-NEXT:    mvns r1, r1
; CHECK-T1-NEXT:    cmp r0, r1
; CHECK-T1-NEXT:    bgt .LBB4_4
; CHECK-T1-NEXT:  @ %bb.3:
; CHECK-T1-NEXT:    mov r0, r1
; CHECK-T1-NEXT:  .LBB4_4:
; CHECK-T1-NEXT:    bx lr
;
; CHECK-T2NODSP-LABEL: func3:
; CHECK-T2NODSP:       @ %bb.0:
; CHECK-T2NODSP-NEXT:    add r0, r1
; CHECK-T2NODSP-NEXT:    cmp r0, #7
; CHECK-T2NODSP-NEXT:    it ge
; CHECK-T2NODSP-NEXT:    movge r0, #7
; CHECK-T2NODSP-NEXT:    cmn.w r0, #8
; CHECK-T2NODSP-NEXT:    it le
; CHECK-T2NODSP-NEXT:    mvnle r0, #7
; CHECK-T2NODSP-NEXT:    bx lr
;
; CHECK-T2DSP-LABEL: func3:
; CHECK-T2DSP:       @ %bb.0:
; CHECK-T2DSP-NEXT:    lsls r1, r1, #28
; CHECK-T2DSP-NEXT:    lsls r0, r0, #28
; CHECK-T2DSP-NEXT:    qadd r0, r0, r1
; CHECK-T2DSP-NEXT:    asrs r0, r0, #28
; CHECK-T2DSP-NEXT:    bx lr
;
; CHECK-ARMNODPS-LABEL: func3:
; CHECK-ARMNODPS:       @ %bb.0:
; CHECK-ARMNODPS-NEXT:    add r0, r0, r1
; CHECK-ARMNODPS-NEXT:    cmp r0, #7
; CHECK-ARMNODPS-NEXT:    movge r0, #7
; CHECK-ARMNODPS-NEXT:    cmn r0, #8
; CHECK-ARMNODPS-NEXT:    mvnle r0, #7
; CHECK-ARMNODPS-NEXT:    bx lr
;
; CHECK-ARMBASEDSP-LABEL: func3:
; CHECK-ARMBASEDSP:       @ %bb.0:
; CHECK-ARMBASEDSP-NEXT:    lsl r0, r0, #28
; CHECK-ARMBASEDSP-NEXT:    lsl r1, r1, #28
; CHECK-ARMBASEDSP-NEXT:    qadd r0, r0, r1
; CHECK-ARMBASEDSP-NEXT:    asr r0, r0, #28
; CHECK-ARMBASEDSP-NEXT:    bx lr
;
; CHECK-ARMDSP-LABEL: func3:
; CHECK-ARMDSP:       @ %bb.0:
; CHECK-ARMDSP-NEXT:    lsl r0, r0, #28
; CHECK-ARMDSP-NEXT:    lsl r1, r1, #28
; CHECK-ARMDSP-NEXT:    qadd r0, r0, r1
; CHECK-ARMDSP-NEXT:    asr r0, r0, #28
; CHECK-ARMDSP-NEXT:    bx lr
  %tmp = call i4 @llvm.sadd.sat.i4(i4 %x, i4 %y)
  ret i4 %tmp
}
