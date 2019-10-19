; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=msp430-- < %s | FileCheck %s

define i16 @testSimplifySetCC_0(i16 %a) {
; CHECK-LABEL: testSimplifySetCC_0:
; CHECK:       ; %bb.0: ; %entry
; CHECK-NEXT:    bit #32, r12
; CHECK-NEXT:    mov r2, r12
; CHECK-NEXT:    and #1, r12
; CHECK-NEXT:    ret
entry:
  %and = and i16 %a, 32
  %cmp = icmp ne i16 %and, 0
  %conv = zext i1 %cmp to i16
  ret i16 %conv
}

define i16 @testSimplifySetCC_1(i16 %a) {
; CHECK-LABEL: testSimplifySetCC_1:
; CHECK:       ; %bb.0: ; %entry
; CHECK-NEXT:    bit #32, r12
; CHECK-NEXT:    mov r2, r12
; CHECK-NEXT:    and #1, r12
; CHECK-NEXT:    ret
entry:
  %and = and i16 %a, 32
  %cmp = icmp eq i16 %and, 32
  %conv = zext i1 %cmp to i16
  ret i16 %conv
}

define i16 @testSiymplifySelect(i16 %a) {
; CHECK-LABEL: testSiymplifySelect:
; CHECK:       ; %bb.0: ; %entry
; CHECK-NEXT:    mov r12, r13
; CHECK-NEXT:    clr r12
; CHECK-NEXT:    bit #2048, r13
; CHECK-NEXT:    jeq .LBB2_2
; CHECK-NEXT:  ; %bb.1: ; %entry
; CHECK-NEXT:    mov #3, r12
; CHECK-NEXT:  .LBB2_2: ; %entry
; CHECK-NEXT:    ret
entry:
  %and = and i16 %a, 2048
  %cmp = icmp eq i16 %and, 0
  %cond = select i1 %cmp, i16 0, i16 3
  ret i16 %cond
}

define i16 @testExtendSignBit(i16 %a) {
; CHECK-LABEL: testExtendSignBit:
; CHECK:       ; %bb.0: ; %entry
; CHECK-NEXT:    inv r12
; CHECK-NEXT:    swpb r12
; CHECK-NEXT:    mov.b r12, r12
; CHECK-NEXT:    clrc
; CHECK-NEXT:    rrc r12
; CHECK-NEXT:    rra r12
; CHECK-NEXT:    rra r12
; CHECK-NEXT:    rra r12
; CHECK-NEXT:    rra r12
; CHECK-NEXT:    rra r12
; CHECK-NEXT:    rra r12
; CHECK-NEXT:    ret
entry:
  %cmp = icmp sgt i16 %a, -1
  %cond = select i1 %cmp, i16 1, i16 0
  ret i16 %cond
}

define i16 @testShiftAnd_0(i16 %a) {
; CHECK-LABEL: testShiftAnd_0:
; CHECK:       ; %bb.0: ; %entry
; CHECK-NEXT:    swpb r12
; CHECK-NEXT:    sxt r12
; CHECK-NEXT:    rra r12
; CHECK-NEXT:    rra r12
; CHECK-NEXT:    rra r12
; CHECK-NEXT:    rra r12
; CHECK-NEXT:    rra r12
; CHECK-NEXT:    rra r12
; CHECK-NEXT:    rra r12
; CHECK-NEXT:    ret
entry:
  %cmp = icmp slt i16 %a, 0
  %cond = select i1 %cmp, i16 -1, i16 0
  ret i16 %cond
}

define i16 @testShiftAnd_1(i16 %a) {
; CHECK-LABEL: testShiftAnd_1:
; CHECK:       ; %bb.0: ; %entry
; CHECK-NEXT:    swpb r12
; CHECK-NEXT:    mov.b r12, r12
; CHECK-NEXT:    clrc
; CHECK-NEXT:    rrc r12
; CHECK-NEXT:    rra r12
; CHECK-NEXT:    rra r12
; CHECK-NEXT:    rra r12
; CHECK-NEXT:    rra r12
; CHECK-NEXT:    rra r12
; CHECK-NEXT:    rra r12
; CHECK-NEXT:    ret
entry:
  %cmp = icmp slt i16 %a, 0
  %cond = select i1 %cmp, i16 1, i16 0
  ret i16 %cond
}

define i16 @testShiftAnd_2(i16 %a) {
; CHECK-LABEL: testShiftAnd_2:
; CHECK:       ; %bb.0: ; %entry
; CHECK-NEXT:    swpb r12
; CHECK-NEXT:    mov.b r12, r12
; CHECK-NEXT:    clrc
; CHECK-NEXT:    rrc r12
; CHECK-NEXT:    rra r12
; CHECK-NEXT:    rra r12
; CHECK-NEXT:    rra r12
; CHECK-NEXT:    rra r12
; CHECK-NEXT:    rra r12
; CHECK-NEXT:    and #2, r12
; CHECK-NEXT:    ret
entry:
  %cmp = icmp slt i16 %a, 0
  %cond = select i1 %cmp, i16 2, i16 0
  ret i16 %cond
}

define i16 @testShiftAnd_3(i16 %a) {
; CHECK-LABEL: testShiftAnd_3:
; CHECK:       ; %bb.0: ; %entry
; CHECK-NEXT:    swpb r12
; CHECK-NEXT:    sxt r12
; CHECK-NEXT:    rra r12
; CHECK-NEXT:    rra r12
; CHECK-NEXT:    rra r12
; CHECK-NEXT:    rra r12
; CHECK-NEXT:    rra r12
; CHECK-NEXT:    rra r12
; CHECK-NEXT:    rra r12
; CHECK-NEXT:    and #3, r12
; CHECK-NEXT:    ret
entry:
  %cmp = icmp slt i16 %a, 0
  %cond = select i1 %cmp, i16 3, i16 0
  ret i16 %cond
}

define i16 @testShiftAnd_4(i16 %a, i16 %b) {
; CHECK-LABEL: testShiftAnd_4:
; CHECK:       ; %bb.0: ; %entry
; CHECK-NEXT:    mov r12, r14
; CHECK-NEXT:    mov #1, r12
; CHECK-NEXT:    cmp r14, r13
; CHECK-NEXT:    jl .LBB8_2
; CHECK-NEXT:  ; %bb.1: ; %entry
; CHECK-NEXT:    clr r12
; CHECK-NEXT:  .LBB8_2: ; %entry
; CHECK-NEXT:    add r12, r12
; CHECK-NEXT:    add r12, r12
; CHECK-NEXT:    add r12, r12
; CHECK-NEXT:    add r12, r12
; CHECK-NEXT:    add r12, r12
; CHECK-NEXT:    ret
entry:
  %cmp = icmp sgt i16 %a, %b
  %cond = select i1 %cmp, i16 32, i16 0
  ret i16 %cond
}
