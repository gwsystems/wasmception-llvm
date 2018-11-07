; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=armv7-unknown-linux < %s -verify-machineinstrs | FileCheck --check-prefix=CHECK-ARM %s
; RUN: llc -mtriple=thumb-eabi < %s  -verify-machineinstrs | FileCheck --check-prefix=CHECK-THUMB1-NOMOV %s
; RUN: llc -mtriple=thumbv6-unknown-linux < %s -verify-machineinstrs | FileCheck --check-prefix=CHECK-THUMB1 %s
; RUN: llc -mtriple=thumbv7-unknown-linux < %s -verify-machineinstrs | FileCheck --check-prefix=CHECK-THUMB2 %s

define i32 @test_slt1(i64 %a, i64 %b) {
; CHECK-ARM-LABEL: test_slt1:
; CHECK-ARM:       @ %bb.0: @ %entry
; CHECK-ARM-NEXT:    subs r0, r0, r2
; CHECK-ARM-NEXT:    mov r12, #2
; CHECK-ARM-NEXT:    sbcs r0, r1, r3
; CHECK-ARM-NEXT:    movwlt r12, #1
; CHECK-ARM-NEXT:    mov r0, r12
; CHECK-ARM-NEXT:    bx lr
;
; CHECK-THUMB1-NOMOV-LABEL: test_slt1:
; CHECK-THUMB1-NOMOV:       @ %bb.0: @ %entry
; CHECK-THUMB1-NOMOV-NEXT:    subs r0, r0, r2
; CHECK-THUMB1-NOMOV-NEXT:    sbcs r1, r3
; CHECK-THUMB1-NOMOV-NEXT:    bge .LBB0_2
; CHECK-THUMB1-NOMOV-NEXT:  @ %bb.1: @ %bb1
; CHECK-THUMB1-NOMOV-NEXT:    movs r0, #1
; CHECK-THUMB1-NOMOV-NEXT:    bx lr
; CHECK-THUMB1-NOMOV-NEXT:  .LBB0_2: @ %bb2
; CHECK-THUMB1-NOMOV-NEXT:    movs r0, #2
; CHECK-THUMB1-NOMOV-NEXT:    bx lr
;
; CHECK-THUMB1-LABEL: test_slt1:
; CHECK-THUMB1:       @ %bb.0: @ %entry
; CHECK-THUMB1-NEXT:    subs r0, r0, r2
; CHECK-THUMB1-NEXT:    sbcs r1, r3
; CHECK-THUMB1-NEXT:    bge .LBB0_2
; CHECK-THUMB1-NEXT:  @ %bb.1: @ %bb1
; CHECK-THUMB1-NEXT:    movs r0, #1
; CHECK-THUMB1-NEXT:    bx lr
; CHECK-THUMB1-NEXT:  .LBB0_2: @ %bb2
; CHECK-THUMB1-NEXT:    movs r0, #2
; CHECK-THUMB1-NEXT:    bx lr
;
; CHECK-THUMB2-LABEL: test_slt1:
; CHECK-THUMB2:       @ %bb.0: @ %entry
; CHECK-THUMB2-NEXT:    subs r0, r0, r2
; CHECK-THUMB2-NEXT:    mov.w r12, #2
; CHECK-THUMB2-NEXT:    sbcs.w r0, r1, r3
; CHECK-THUMB2-NEXT:    it lt
; CHECK-THUMB2-NEXT:    movlt.w r12, #1
; CHECK-THUMB2-NEXT:    mov r0, r12
; CHECK-THUMB2-NEXT:    bx lr
entry:
  %cmp = icmp slt i64 %a, %b
  br i1 %cmp, label %bb1, label %bb2
bb1:
  ret i32 1
bb2:
  ret i32 2
}

define void @test_slt2(i64 %a, i64 %b) {
; CHECK-ARM-LABEL: test_slt2:
; CHECK-ARM:       @ %bb.0: @ %entry
; CHECK-ARM-NEXT:    push {r11, lr}
; CHECK-ARM-NEXT:    subs r0, r0, r2
; CHECK-ARM-NEXT:    sbcs r0, r1, r3
; CHECK-ARM-NEXT:    bge .LBB1_2
; CHECK-ARM-NEXT:  @ %bb.1: @ %bb1
; CHECK-ARM-NEXT:    bl f
; CHECK-ARM-NEXT:    pop {r11, pc}
; CHECK-ARM-NEXT:  .LBB1_2: @ %bb2
; CHECK-ARM-NEXT:    bl g
; CHECK-ARM-NEXT:    pop {r11, pc}
;
; CHECK-THUMB1-NOMOV-LABEL: test_slt2:
; CHECK-THUMB1-NOMOV:       @ %bb.0: @ %entry
; CHECK-THUMB1-NOMOV-NEXT:    .save {r7, lr}
; CHECK-THUMB1-NOMOV-NEXT:    push {r7, lr}
; CHECK-THUMB1-NOMOV-NEXT:    subs r0, r0, r2
; CHECK-THUMB1-NOMOV-NEXT:    sbcs r1, r3
; CHECK-THUMB1-NOMOV-NEXT:    bge .LBB1_2
; CHECK-THUMB1-NOMOV-NEXT:  @ %bb.1: @ %bb1
; CHECK-THUMB1-NOMOV-NEXT:    bl f
; CHECK-THUMB1-NOMOV-NEXT:    b .LBB1_3
; CHECK-THUMB1-NOMOV-NEXT:  .LBB1_2: @ %bb2
; CHECK-THUMB1-NOMOV-NEXT:    bl g
; CHECK-THUMB1-NOMOV-NEXT:  .LBB1_3: @ %bb1
; CHECK-THUMB1-NOMOV-NEXT:    pop {r7}
; CHECK-THUMB1-NOMOV-NEXT:    pop {r0}
; CHECK-THUMB1-NOMOV-NEXT:    bx r0
;
; CHECK-THUMB1-LABEL: test_slt2:
; CHECK-THUMB1:       @ %bb.0: @ %entry
; CHECK-THUMB1-NEXT:    push {r7, lr}
; CHECK-THUMB1-NEXT:    subs r0, r0, r2
; CHECK-THUMB1-NEXT:    sbcs r1, r3
; CHECK-THUMB1-NEXT:    bge .LBB1_2
; CHECK-THUMB1-NEXT:  @ %bb.1: @ %bb1
; CHECK-THUMB1-NEXT:    bl f
; CHECK-THUMB1-NEXT:    pop {r7, pc}
; CHECK-THUMB1-NEXT:  .LBB1_2: @ %bb2
; CHECK-THUMB1-NEXT:    bl g
; CHECK-THUMB1-NEXT:    pop {r7, pc}
;
; CHECK-THUMB2-LABEL: test_slt2:
; CHECK-THUMB2:       @ %bb.0: @ %entry
; CHECK-THUMB2-NEXT:    push {r7, lr}
; CHECK-THUMB2-NEXT:    subs r0, r0, r2
; CHECK-THUMB2-NEXT:    sbcs.w r0, r1, r3
; CHECK-THUMB2-NEXT:    bge .LBB1_2
; CHECK-THUMB2-NEXT:  @ %bb.1: @ %bb1
; CHECK-THUMB2-NEXT:    bl f
; CHECK-THUMB2-NEXT:    pop {r7, pc}
; CHECK-THUMB2-NEXT:  .LBB1_2: @ %bb2
; CHECK-THUMB2-NEXT:    bl g
; CHECK-THUMB2-NEXT:    pop {r7, pc}
entry:
  %cmp = icmp slt i64 %a, %b
  br i1 %cmp, label %bb1, label %bb2
bb1:
  call void @f()
  ret void
bb2:
  call void @g()
  ret void
}

declare void @f()
declare void @g()

define i64 @test_slt_select(i64 %c, i64 %d, i64 %a, i64 %b) {
; CHECK-ARM-LABEL: test_slt_select:
; CHECK-ARM:       @ %bb.0: @ %entry
; CHECK-ARM-NEXT:    push {r4, r5, r6, r7, r11, lr}
; CHECK-ARM-NEXT:    ldr r12, [sp, #32]
; CHECK-ARM-NEXT:    mov r6, #0
; CHECK-ARM-NEXT:    ldr lr, [sp, #24]
; CHECK-ARM-NEXT:    ldr r7, [sp, #36]
; CHECK-ARM-NEXT:    ldr r5, [sp, #28]
; CHECK-ARM-NEXT:    subs r4, lr, r12
; CHECK-ARM-NEXT:    sbcs r7, r5, r7
; CHECK-ARM-NEXT:    movwlo r6, #1
; CHECK-ARM-NEXT:    cmp r6, #0
; CHECK-ARM-NEXT:    moveq r0, r2
; CHECK-ARM-NEXT:    moveq r1, r3
; CHECK-ARM-NEXT:    pop {r4, r5, r6, r7, r11, pc}
;
; CHECK-THUMB1-NOMOV-LABEL: test_slt_select:
; CHECK-THUMB1-NOMOV:       @ %bb.0: @ %entry
; CHECK-THUMB1-NOMOV-NEXT:    .save {r4, r5, r6, r7, lr}
; CHECK-THUMB1-NOMOV-NEXT:    push {r4, r5, r6, r7, lr}
; CHECK-THUMB1-NOMOV-NEXT:    .pad #4
; CHECK-THUMB1-NOMOV-NEXT:    sub sp, #4
; CHECK-THUMB1-NOMOV-NEXT:    ldr r4, [sp, #36]
; CHECK-THUMB1-NOMOV-NEXT:    ldr r5, [sp, #28]
; CHECK-THUMB1-NOMOV-NEXT:    ldr r6, [sp, #32]
; CHECK-THUMB1-NOMOV-NEXT:    ldr r7, [sp, #24]
; CHECK-THUMB1-NOMOV-NEXT:    subs r6, r7, r6
; CHECK-THUMB1-NOMOV-NEXT:    sbcs r5, r4
; CHECK-THUMB1-NOMOV-NEXT:    blo .LBB2_2
; CHECK-THUMB1-NOMOV-NEXT:  @ %bb.1: @ %entry
; CHECK-THUMB1-NOMOV-NEXT:    movs r4, #0
; CHECK-THUMB1-NOMOV-NEXT:    cmp r4, #0
; CHECK-THUMB1-NOMOV-NEXT:    beq .LBB2_3
; CHECK-THUMB1-NOMOV-NEXT:    b .LBB2_4
; CHECK-THUMB1-NOMOV-NEXT:  .LBB2_2:
; CHECK-THUMB1-NOMOV-NEXT:    movs r4, #1
; CHECK-THUMB1-NOMOV-NEXT:    cmp r4, #0
; CHECK-THUMB1-NOMOV-NEXT:    bne .LBB2_4
; CHECK-THUMB1-NOMOV-NEXT:  .LBB2_3: @ %entry
; CHECK-THUMB1-NOMOV-NEXT:    movs r0, r2
; CHECK-THUMB1-NOMOV-NEXT:  .LBB2_4: @ %entry
; CHECK-THUMB1-NOMOV-NEXT:    cmp r4, #0
; CHECK-THUMB1-NOMOV-NEXT:    bne .LBB2_6
; CHECK-THUMB1-NOMOV-NEXT:  @ %bb.5: @ %entry
; CHECK-THUMB1-NOMOV-NEXT:    movs r1, r3
; CHECK-THUMB1-NOMOV-NEXT:  .LBB2_6: @ %entry
; CHECK-THUMB1-NOMOV-NEXT:    add sp, #4
; CHECK-THUMB1-NOMOV-NEXT:    pop {r4, r5, r6, r7}
; CHECK-THUMB1-NOMOV-NEXT:    pop {r2}
; CHECK-THUMB1-NOMOV-NEXT:    bx r2
;
; CHECK-THUMB1-LABEL: test_slt_select:
; CHECK-THUMB1:       @ %bb.0: @ %entry
; CHECK-THUMB1-NEXT:    push {r4, r5, r6, r7, lr}
; CHECK-THUMB1-NEXT:    sub sp, #4
; CHECK-THUMB1-NEXT:    ldr r4, [sp, #36]
; CHECK-THUMB1-NEXT:    ldr r5, [sp, #28]
; CHECK-THUMB1-NEXT:    ldr r6, [sp, #32]
; CHECK-THUMB1-NEXT:    ldr r7, [sp, #24]
; CHECK-THUMB1-NEXT:    subs r6, r7, r6
; CHECK-THUMB1-NEXT:    sbcs r5, r4
; CHECK-THUMB1-NEXT:    blo .LBB2_2
; CHECK-THUMB1-NEXT:  @ %bb.1: @ %entry
; CHECK-THUMB1-NEXT:    movs r4, #0
; CHECK-THUMB1-NEXT:    cmp r4, #0
; CHECK-THUMB1-NEXT:    beq .LBB2_3
; CHECK-THUMB1-NEXT:    b .LBB2_4
; CHECK-THUMB1-NEXT:  .LBB2_2:
; CHECK-THUMB1-NEXT:    movs r4, #1
; CHECK-THUMB1-NEXT:    cmp r4, #0
; CHECK-THUMB1-NEXT:    bne .LBB2_4
; CHECK-THUMB1-NEXT:  .LBB2_3: @ %entry
; CHECK-THUMB1-NEXT:    mov r0, r2
; CHECK-THUMB1-NEXT:  .LBB2_4: @ %entry
; CHECK-THUMB1-NEXT:    cmp r4, #0
; CHECK-THUMB1-NEXT:    beq .LBB2_6
; CHECK-THUMB1-NEXT:  @ %bb.5: @ %entry
; CHECK-THUMB1-NEXT:    add sp, #4
; CHECK-THUMB1-NEXT:    pop {r4, r5, r6, r7, pc}
; CHECK-THUMB1-NEXT:  .LBB2_6: @ %entry
; CHECK-THUMB1-NEXT:    mov r1, r3
; CHECK-THUMB1-NEXT:    add sp, #4
; CHECK-THUMB1-NEXT:    pop {r4, r5, r6, r7, pc}
;
; CHECK-THUMB2-LABEL: test_slt_select:
; CHECK-THUMB2:       @ %bb.0: @ %entry
; CHECK-THUMB2-NEXT:    push {r4, r5, r6, r7, lr}
; CHECK-THUMB2-NEXT:    sub sp, #4
; CHECK-THUMB2-NEXT:    ldrd r12, r7, [sp, #32]
; CHECK-THUMB2-NEXT:    movs r6, #0
; CHECK-THUMB2-NEXT:    ldrd lr, r5, [sp, #24]
; CHECK-THUMB2-NEXT:    subs.w r4, lr, r12
; CHECK-THUMB2-NEXT:    sbcs.w r7, r5, r7
; CHECK-THUMB2-NEXT:    it lo
; CHECK-THUMB2-NEXT:    movlo r6, #1
; CHECK-THUMB2-NEXT:    cmp r6, #0
; CHECK-THUMB2-NEXT:    itt eq
; CHECK-THUMB2-NEXT:    moveq r0, r2
; CHECK-THUMB2-NEXT:    moveq r1, r3
; CHECK-THUMB2-NEXT:    add sp, #4
; CHECK-THUMB2-NEXT:    pop {r4, r5, r6, r7, pc}
entry:
    %cmp = icmp ult i64 %a, %b
    %r1 = select i1 %cmp, i64 %c, i64 %d
    ret i64 %r1
}

define {i32, i32} @test_slt_not(i32 %c, i32 %d, i64 %a, i64 %b) {
; CHECK-ARM-LABEL: test_slt_not:
; CHECK-ARM:       @ %bb.0: @ %entry
; CHECK-ARM-NEXT:    ldr r12, [sp]
; CHECK-ARM-NEXT:    mov r1, #0
; CHECK-ARM-NEXT:    ldr r0, [sp, #4]
; CHECK-ARM-NEXT:    subs r2, r2, r12
; CHECK-ARM-NEXT:    sbcs r0, r3, r0
; CHECK-ARM-NEXT:    mov r0, #0
; CHECK-ARM-NEXT:    movwge r1, #1
; CHECK-ARM-NEXT:    movwlt r0, #1
; CHECK-ARM-NEXT:    bx lr
;
; CHECK-THUMB1-NOMOV-LABEL: test_slt_not:
; CHECK-THUMB1-NOMOV:       @ %bb.0: @ %entry
; CHECK-THUMB1-NOMOV-NEXT:    .save {r4, r5, r7, lr}
; CHECK-THUMB1-NOMOV-NEXT:    push {r4, r5, r7, lr}
; CHECK-THUMB1-NOMOV-NEXT:    movs r1, #1
; CHECK-THUMB1-NOMOV-NEXT:    movs r4, #0
; CHECK-THUMB1-NOMOV-NEXT:    ldr r0, [sp, #20]
; CHECK-THUMB1-NOMOV-NEXT:    ldr r5, [sp, #16]
; CHECK-THUMB1-NOMOV-NEXT:    subs r2, r2, r5
; CHECK-THUMB1-NOMOV-NEXT:    sbcs r3, r0
; CHECK-THUMB1-NOMOV-NEXT:    push {r1}
; CHECK-THUMB1-NOMOV-NEXT:    pop {r0}
; CHECK-THUMB1-NOMOV-NEXT:    blt .LBB3_2
; CHECK-THUMB1-NOMOV-NEXT:  @ %bb.1: @ %entry
; CHECK-THUMB1-NOMOV-NEXT:    push {r4}
; CHECK-THUMB1-NOMOV-NEXT:    pop {r0}
; CHECK-THUMB1-NOMOV-NEXT:  .LBB3_2: @ %entry
; CHECK-THUMB1-NOMOV-NEXT:    bge .LBB3_4
; CHECK-THUMB1-NOMOV-NEXT:  @ %bb.3: @ %entry
; CHECK-THUMB1-NOMOV-NEXT:    movs r1, r4
; CHECK-THUMB1-NOMOV-NEXT:  .LBB3_4: @ %entry
; CHECK-THUMB1-NOMOV-NEXT:    pop {r4, r5, r7}
; CHECK-THUMB1-NOMOV-NEXT:    pop {r2}
; CHECK-THUMB1-NOMOV-NEXT:    bx r2
;
; CHECK-THUMB1-LABEL: test_slt_not:
; CHECK-THUMB1:       @ %bb.0: @ %entry
; CHECK-THUMB1-NEXT:    push {r4, r5, r7, lr}
; CHECK-THUMB1-NEXT:    movs r1, #1
; CHECK-THUMB1-NEXT:    movs r4, #0
; CHECK-THUMB1-NEXT:    ldr r0, [sp, #20]
; CHECK-THUMB1-NEXT:    ldr r5, [sp, #16]
; CHECK-THUMB1-NEXT:    subs r2, r2, r5
; CHECK-THUMB1-NEXT:    sbcs r3, r0
; CHECK-THUMB1-NEXT:    mov r0, r1
; CHECK-THUMB1-NEXT:    bge .LBB3_3
; CHECK-THUMB1-NEXT:  @ %bb.1: @ %entry
; CHECK-THUMB1-NEXT:    blt .LBB3_4
; CHECK-THUMB1-NEXT:  .LBB3_2: @ %entry
; CHECK-THUMB1-NEXT:    pop {r4, r5, r7, pc}
; CHECK-THUMB1-NEXT:  .LBB3_3: @ %entry
; CHECK-THUMB1-NEXT:    mov r0, r4
; CHECK-THUMB1-NEXT:    bge .LBB3_2
; CHECK-THUMB1-NEXT:  .LBB3_4: @ %entry
; CHECK-THUMB1-NEXT:    mov r1, r4
; CHECK-THUMB1-NEXT:    pop {r4, r5, r7, pc}
;
; CHECK-THUMB2-LABEL: test_slt_not:
; CHECK-THUMB2:       @ %bb.0: @ %entry
; CHECK-THUMB2-NEXT:    ldr.w r12, [sp]
; CHECK-THUMB2-NEXT:    movs r1, #0
; CHECK-THUMB2-NEXT:    ldr r0, [sp, #4]
; CHECK-THUMB2-NEXT:    subs.w r2, r2, r12
; CHECK-THUMB2-NEXT:    sbcs.w r0, r3, r0
; CHECK-THUMB2-NEXT:    mov.w r0, #0
; CHECK-THUMB2-NEXT:    ite lt
; CHECK-THUMB2-NEXT:    movlt r0, #1
; CHECK-THUMB2-NEXT:    movge r1, #1
; CHECK-THUMB2-NEXT:    bx lr
entry:
    %cmp = icmp slt i64 %a, %b
    %not = xor i1 %cmp, true
    %r1 = zext i1 %cmp to i32
    %r2 = zext i1 %not to i32
    %z = insertvalue { i32, i32 } undef, i32 %r1, 0
    %z2 = insertvalue { i32, i32 } %z, i32 %r2, 1
    ret { i32, i32 } %z2
}
