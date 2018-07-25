; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=thumbv6-eabi %s -o - | FileCheck %s

define i32 @test1(i32 %x) {
; CHECK-LABEL: test1:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    lsls r0, r0, #20
; CHECK-NEXT:    lsrs r0, r0, #22
; CHECK-NEXT:    bx lr
entry:
  %0 = lshr i32 %x, 2
  %shr = and i32 %0, 1023
  ret i32 %shr
}

define i32 @test2(i32 %x) {
; CHECK-LABEL: test2:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    lsrs r1, r0, #2
; CHECK-NEXT:    ldr r0, .LCPI1_0
; CHECK-NEXT:    ands r0, r1
; CHECK-NEXT:    bx lr
; CHECK-NEXT:    .p2align 2
; CHECK-NEXT:  @ %bb.1:
; CHECK-NEXT:  .LCPI1_0:
; CHECK-NEXT:    .long 1022 @ 0x3fe
entry:
  %0 = lshr i32 %x, 2
  %shr = and i32 %0, 1022
  ret i32 %shr
}

define i32 @test3(i32 %x) {
; CHECK-LABEL: test3:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    lsrs r0, r0, #2
; CHECK-NEXT:    uxtb r0, r0
; CHECK-NEXT:    bx lr
entry:
  %0 = lshr i32 %x, 2
  %shr = and i32 %0, 255
  ret i32 %shr
}

define i32 @test4(i32 %x) {
; CHECK-LABEL: test4:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    lsls r0, r0, #4
; CHECK-NEXT:    movs r1, #127
; CHECK-NEXT:    bics r0, r1
; CHECK-NEXT:    bx lr
entry:
  %0 = shl i32 %x, 4
  %shr = and i32 %0, -128
  ret i32 %shr
}

define i32 @test5(i32 %x) {
; CHECK-LABEL: test5:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    lsls r0, r0, #31
; CHECK-NEXT:    lsrs r0, r0, #2
; CHECK-NEXT:    bx lr
entry:
  %0 = shl i32 %x, 29
  %shr = and i32 %0, 536870912
  ret i32 %shr
}

define i32 @test6(i32 %x) {
; CHECK-LABEL: test6:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    movs r1, #5
; CHECK-NEXT:    lsls r1, r1, #29
; CHECK-NEXT:    lsls r0, r0, #29
; CHECK-NEXT:    ands r0, r1
; CHECK-NEXT:    bx lr
entry:
  %0 = shl i32 %x, 29
  %shr = and i32 %0, 2684354560
  ret i32 %shr
}

define i32 @test7(i32 %x) {
; CHECK-LABEL: test7:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    lsrs r1, r0, #29
; CHECK-NEXT:    movs r0, #4
; CHECK-NEXT:    ands r0, r1
; CHECK-NEXT:    bx lr
entry:
  %0 = lshr i32 %x, 29
  %shr = and i32 %0, 4
  ret i32 %shr
}

define i32 @test8(i32 %x) {
; CHECK-LABEL: test8:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    lsrs r1, r0, #29
; CHECK-NEXT:    movs r0, #5
; CHECK-NEXT:    ands r0, r1
; CHECK-NEXT:    bx lr
entry:
  %0 = lshr i32 %x, 29
  %shr = and i32 %0, 5
  ret i32 %shr
}

define i32 @test9(i32 %x) {
; CHECK-LABEL: test9:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    lsrs r1, r0, #2
; CHECK-NEXT:    ldr r0, .LCPI8_0
; CHECK-NEXT:    ands r0, r1
; CHECK-NEXT:    bx lr
; CHECK-NEXT:    .p2align 2
; CHECK-NEXT:  @ %bb.1:
; CHECK-NEXT:  .LCPI8_0:
; CHECK-NEXT:    .long 1073741822 @ 0x3ffffffe
entry:
  %and = lshr i32 %x, 2
  %shr = and i32 %and, 1073741822
  ret i32 %shr
}
