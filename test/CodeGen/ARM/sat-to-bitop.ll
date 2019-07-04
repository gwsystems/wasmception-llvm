; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=arm %s -o - | FileCheck %s --check-prefix=CHECK --check-prefix=CHECK-ARM
; RUN: llc -mtriple=thumb-eabi %s -o - | FileCheck %s --check-prefix=CHECK --check-prefix=CHECK-T
; RUN: llc -mtriple=thumb-eabi -mcpu=arm1156t2-s -mattr=+thumb2 %s -o - | FileCheck %s --check-prefix=CHECK --check-prefix=CHECK-T2

; Check for clipping against 0 that should result in bic
;
; Base tests with different bit widths

; x < 0 ? 0 : x
; 32-bit base test
define i32 @sat0_base_32bit(i32 %x) #0 {
; CHECK-ARM-LABEL: sat0_base_32bit:
; CHECK-ARM:       @ %bb.0: @ %entry
; CHECK-ARM-NEXT:    bic r0, r0, r0, asr #31
; CHECK-ARM-NEXT:    mov pc, lr
;
; CHECK-T-LABEL: sat0_base_32bit:
; CHECK-T:       @ %bb.0: @ %entry
; CHECK-T-NEXT:    asrs r1, r0, #31
; CHECK-T-NEXT:    bics r0, r1
; CHECK-T-NEXT:    bx lr
;
; CHECK-T2-LABEL: sat0_base_32bit:
; CHECK-T2:       @ %bb.0: @ %entry
; CHECK-T2-NEXT:    bic.w r0, r0, r0, asr #31
; CHECK-T2-NEXT:    bx lr
entry:
  %cmpLow = icmp slt i32 %x, 0
  %saturateLow = select i1 %cmpLow, i32 0, i32 %x
  ret i32 %saturateLow
}

; x < 0 ? 0 : x
; 16-bit base test
define i16 @sat0_base_16bit(i16 %x) #0 {
; CHECK-ARM-LABEL: sat0_base_16bit:
; CHECK-ARM:       @ %bb.0: @ %entry
; CHECK-ARM-NEXT:    lsl r1, r0, #16
; CHECK-ARM-NEXT:    asr r1, r1, #16
; CHECK-ARM-NEXT:    cmp r1, #0
; CHECK-ARM-NEXT:    movmi r0, #0
; CHECK-ARM-NEXT:    mov pc, lr
;
; CHECK-T-LABEL: sat0_base_16bit:
; CHECK-T:       @ %bb.0: @ %entry
; CHECK-T-NEXT:    lsls r1, r0, #16
; CHECK-T-NEXT:    asrs r1, r1, #16
; CHECK-T-NEXT:    bpl .LBB1_2
; CHECK-T-NEXT:  @ %bb.1:
; CHECK-T-NEXT:    movs r0, #0
; CHECK-T-NEXT:  .LBB1_2: @ %entry
; CHECK-T-NEXT:    bx lr
;
; CHECK-T2-LABEL: sat0_base_16bit:
; CHECK-T2:       @ %bb.0: @ %entry
; CHECK-T2-NEXT:    sxth r1, r0
; CHECK-T2-NEXT:    cmp r1, #0
; CHECK-T2-NEXT:    it mi
; CHECK-T2-NEXT:    movmi r0, #0
; CHECK-T2-NEXT:    bx lr
entry:
  %cmpLow = icmp slt i16 %x, 0
  %saturateLow = select i1 %cmpLow, i16 0, i16 %x
  ret i16 %saturateLow
}

; x < 0 ? 0 : x
; 8-bit base test
define i8 @sat0_base_8bit(i8 %x) #0 {
; CHECK-ARM-LABEL: sat0_base_8bit:
; CHECK-ARM:       @ %bb.0: @ %entry
; CHECK-ARM-NEXT:    lsl r1, r0, #24
; CHECK-ARM-NEXT:    asr r1, r1, #24
; CHECK-ARM-NEXT:    cmp r1, #0
; CHECK-ARM-NEXT:    movmi r0, #0
; CHECK-ARM-NEXT:    mov pc, lr
;
; CHECK-T-LABEL: sat0_base_8bit:
; CHECK-T:       @ %bb.0: @ %entry
; CHECK-T-NEXT:    lsls r1, r0, #24
; CHECK-T-NEXT:    asrs r1, r1, #24
; CHECK-T-NEXT:    bpl .LBB2_2
; CHECK-T-NEXT:  @ %bb.1:
; CHECK-T-NEXT:    movs r0, #0
; CHECK-T-NEXT:  .LBB2_2: @ %entry
; CHECK-T-NEXT:    bx lr
;
; CHECK-T2-LABEL: sat0_base_8bit:
; CHECK-T2:       @ %bb.0: @ %entry
; CHECK-T2-NEXT:    sxtb r1, r0
; CHECK-T2-NEXT:    cmp r1, #0
; CHECK-T2-NEXT:    it mi
; CHECK-T2-NEXT:    movmi r0, #0
; CHECK-T2-NEXT:    bx lr
entry:
  %cmpLow = icmp slt i8 %x, 0
  %saturateLow = select i1 %cmpLow, i8 0, i8 %x
  ret i8 %saturateLow
}

; Test where the conditional is formed in a different way

; x > 0 ? x : 0
define i32 @sat0_lower_1(i32 %x) #0 {
; CHECK-ARM-LABEL: sat0_lower_1:
; CHECK-ARM:       @ %bb.0: @ %entry
; CHECK-ARM-NEXT:    bic r0, r0, r0, asr #31
; CHECK-ARM-NEXT:    mov pc, lr
;
; CHECK-T-LABEL: sat0_lower_1:
; CHECK-T:       @ %bb.0: @ %entry
; CHECK-T-NEXT:    asrs r1, r0, #31
; CHECK-T-NEXT:    bics r0, r1
; CHECK-T-NEXT:    bx lr
;
; CHECK-T2-LABEL: sat0_lower_1:
; CHECK-T2:       @ %bb.0: @ %entry
; CHECK-T2-NEXT:    bic.w r0, r0, r0, asr #31
; CHECK-T2-NEXT:    bx lr
entry:
  %cmpGt = icmp sgt i32 %x, 0
  %saturateLow = select i1 %cmpGt, i32 %x, i32 0
  ret i32 %saturateLow
}


; Check for clipping against -1 that should result in orr
;
; Base tests with different bit widths
;

; x < -1 ? -1 : x
; 32-bit base test
define i32 @sat1_base_32bit(i32 %x) #0 {
; CHECK-ARM-LABEL: sat1_base_32bit:
; CHECK-ARM:       @ %bb.0: @ %entry
; CHECK-ARM-NEXT:    orr r0, r0, r0, asr #31
; CHECK-ARM-NEXT:    mov pc, lr
;
; CHECK-T-LABEL: sat1_base_32bit:
; CHECK-T:       @ %bb.0: @ %entry
; CHECK-T-NEXT:    asrs r1, r0, #31
; CHECK-T-NEXT:    orrs r0, r1
; CHECK-T-NEXT:    bx lr
;
; CHECK-T2-LABEL: sat1_base_32bit:
; CHECK-T2:       @ %bb.0: @ %entry
; CHECK-T2-NEXT:    orr.w r0, r0, r0, asr #31
; CHECK-T2-NEXT:    bx lr
entry:
  %cmpLow = icmp slt i32 %x, -1
  %saturateLow = select i1 %cmpLow, i32 -1, i32 %x
  ret i32 %saturateLow
}

; x < -1 ? -1 : x
; 16-bit base test
define i16 @sat1_base_16bit(i16 %x) #0 {
; CHECK-ARM-LABEL: sat1_base_16bit:
; CHECK-ARM:       @ %bb.0: @ %entry
; CHECK-ARM-NEXT:    lsl r1, r0, #16
; CHECK-ARM-NEXT:    asr r1, r1, #16
; CHECK-ARM-NEXT:    cmn r1, #1
; CHECK-ARM-NEXT:    mvnlt r0, #0
; CHECK-ARM-NEXT:    mov pc, lr
;
; CHECK-T-LABEL: sat1_base_16bit:
; CHECK-T:       @ %bb.0: @ %entry
; CHECK-T-NEXT:    movs r1, #0
; CHECK-T-NEXT:    mvns r1, r1
; CHECK-T-NEXT:    lsls r2, r0, #16
; CHECK-T-NEXT:    asrs r2, r2, #16
; CHECK-T-NEXT:    cmp r2, r1
; CHECK-T-NEXT:    blt .LBB5_2
; CHECK-T-NEXT:  @ %bb.1: @ %entry
; CHECK-T-NEXT:    movs r1, r0
; CHECK-T-NEXT:  .LBB5_2: @ %entry
; CHECK-T-NEXT:    movs r0, r1
; CHECK-T-NEXT:    bx lr
;
; CHECK-T2-LABEL: sat1_base_16bit:
; CHECK-T2:       @ %bb.0: @ %entry
; CHECK-T2-NEXT:    sxth r1, r0
; CHECK-T2-NEXT:    cmp.w r1, #-1
; CHECK-T2-NEXT:    it lt
; CHECK-T2-NEXT:    movlt.w r0, #-1
; CHECK-T2-NEXT:    bx lr
entry:
  %cmpLow = icmp slt i16 %x, -1
  %saturateLow = select i1 %cmpLow, i16 -1, i16 %x
  ret i16 %saturateLow
}

; x < -1 ? -1 : x
; 8-bit base test
define i8 @sat1_base_8bit(i8 %x) #0 {
; CHECK-ARM-LABEL: sat1_base_8bit:
; CHECK-ARM:       @ %bb.0: @ %entry
; CHECK-ARM-NEXT:    lsl r1, r0, #24
; CHECK-ARM-NEXT:    asr r1, r1, #24
; CHECK-ARM-NEXT:    cmn r1, #1
; CHECK-ARM-NEXT:    mvnlt r0, #0
; CHECK-ARM-NEXT:    mov pc, lr
;
; CHECK-T-LABEL: sat1_base_8bit:
; CHECK-T:       @ %bb.0: @ %entry
; CHECK-T-NEXT:    movs r1, #0
; CHECK-T-NEXT:    mvns r1, r1
; CHECK-T-NEXT:    lsls r2, r0, #24
; CHECK-T-NEXT:    asrs r2, r2, #24
; CHECK-T-NEXT:    cmp r2, r1
; CHECK-T-NEXT:    blt .LBB6_2
; CHECK-T-NEXT:  @ %bb.1: @ %entry
; CHECK-T-NEXT:    movs r1, r0
; CHECK-T-NEXT:  .LBB6_2: @ %entry
; CHECK-T-NEXT:    movs r0, r1
; CHECK-T-NEXT:    bx lr
;
; CHECK-T2-LABEL: sat1_base_8bit:
; CHECK-T2:       @ %bb.0: @ %entry
; CHECK-T2-NEXT:    sxtb r1, r0
; CHECK-T2-NEXT:    cmp.w r1, #-1
; CHECK-T2-NEXT:    it lt
; CHECK-T2-NEXT:    movlt.w r0, #-1
; CHECK-T2-NEXT:    bx lr
entry:
  %cmpLow = icmp slt i8 %x, -1
  %saturateLow = select i1 %cmpLow, i8 -1, i8 %x
  ret i8 %saturateLow
}

; Test where the conditional is formed in a different way

; x > -1 ? x : -1
define i32 @sat1_lower_1(i32 %x) #0 {
; CHECK-ARM-LABEL: sat1_lower_1:
; CHECK-ARM:       @ %bb.0: @ %entry
; CHECK-ARM-NEXT:    orr r0, r0, r0, asr #31
; CHECK-ARM-NEXT:    mov pc, lr
;
; CHECK-T-LABEL: sat1_lower_1:
; CHECK-T:       @ %bb.0: @ %entry
; CHECK-T-NEXT:    asrs r1, r0, #31
; CHECK-T-NEXT:    orrs r0, r1
; CHECK-T-NEXT:    bx lr
;
; CHECK-T2-LABEL: sat1_lower_1:
; CHECK-T2:       @ %bb.0: @ %entry
; CHECK-T2-NEXT:    orr.w r0, r0, r0, asr #31
; CHECK-T2-NEXT:    bx lr
entry:
  %cmpGt = icmp sgt i32 %x, -1
  %saturateLow = select i1 %cmpGt, i32 %x, i32 -1
  ret i32 %saturateLow
}

; The following tests for patterns that should not transform into bitops
; but that are similar enough that could confuse the selector.

; x < 0 ? 0 : y where x and y does not properly match
define i32 @no_sat0_incorrect_variable(i32 %x, i32 %y) #0 {
; CHECK-ARM-LABEL: no_sat0_incorrect_variable:
; CHECK-ARM:       @ %bb.0: @ %entry
; CHECK-ARM-NEXT:    cmp r0, #0
; CHECK-ARM-NEXT:    movmi r1, #0
; CHECK-ARM-NEXT:    mov r0, r1
; CHECK-ARM-NEXT:    mov pc, lr
;
; CHECK-T-LABEL: no_sat0_incorrect_variable:
; CHECK-T:       @ %bb.0: @ %entry
; CHECK-T-NEXT:    cmp r0, #0
; CHECK-T-NEXT:    bpl .LBB8_2
; CHECK-T-NEXT:  @ %bb.1:
; CHECK-T-NEXT:    movs r1, #0
; CHECK-T-NEXT:  .LBB8_2: @ %entry
; CHECK-T-NEXT:    movs r0, r1
; CHECK-T-NEXT:    bx lr
;
; CHECK-T2-LABEL: no_sat0_incorrect_variable:
; CHECK-T2:       @ %bb.0: @ %entry
; CHECK-T2-NEXT:    cmp r0, #0
; CHECK-T2-NEXT:    it mi
; CHECK-T2-NEXT:    movmi r1, #0
; CHECK-T2-NEXT:    mov r0, r1
; CHECK-T2-NEXT:    bx lr
entry:
  %cmpLow = icmp slt i32 %x, 0
  %saturateLow = select i1 %cmpLow, i32 0, i32 %y
  ret i32 %saturateLow
}

; x < 0 ? -1 : x
define i32 @no_sat0_incorrect_constant(i32 %x) {
; CHECK-ARM-LABEL: no_sat0_incorrect_constant:
; CHECK-ARM:       @ %bb.0: @ %entry
; CHECK-ARM-NEXT:    cmp r0, #0
; CHECK-ARM-NEXT:    mvnmi r0, #0
; CHECK-ARM-NEXT:    mov pc, lr
;
; CHECK-T-LABEL: no_sat0_incorrect_constant:
; CHECK-T:       @ %bb.0: @ %entry
; CHECK-T-NEXT:    cmp r0, #0
; CHECK-T-NEXT:    bpl .LBB9_2
; CHECK-T-NEXT:  @ %bb.1:
; CHECK-T-NEXT:    movs r0, #0
; CHECK-T-NEXT:    mvns r0, r0
; CHECK-T-NEXT:  .LBB9_2: @ %entry
; CHECK-T-NEXT:    bx lr
;
; CHECK-T2-LABEL: no_sat0_incorrect_constant:
; CHECK-T2:       @ %bb.0: @ %entry
; CHECK-T2-NEXT:    cmp r0, #0
; CHECK-T2-NEXT:    it mi
; CHECK-T2-NEXT:    movmi.w r0, #-1
; CHECK-T2-NEXT:    bx lr
entry:
  %cmpLow = icmp slt i32 %x, 0
  %saturateLow = select i1 %cmpLow, i32 -1, i32 %x
  ret i32 %saturateLow
}
