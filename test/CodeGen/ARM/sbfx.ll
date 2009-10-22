; RUN: llc < %s -march=arm -mattr=+v6t2 | FileCheck %s

define i32 @f1(i32 %a) {
entry:
; CHECK: f1:
; CHECK: sbfx r0, r0, #0, #20
    %tmp = shl i32 %a, 12
    %tmp2 = ashr i32 %tmp, 12
    ret i32 %tmp2
}

define i32 @f2(i32 %a) {
entry:
; CHECK: f2:
; CHECK: ubfx r0, r0, #0, #20
    %tmp = shl i32 %a, 12
    %tmp2 = lshr i32 %tmp, 12
    ret i32 %tmp2
}

define i32 @f3(i32 %a) {
entry:
; CHECK: f3:
; CHECK: sbfx r0, r0, #5, #3
    %tmp = shl i32 %a, 24
    %tmp2 = ashr i32 %tmp, 29
    ret i32 %tmp2
}

define i32 @f4(i32 %a) {
entry:
; CHECK: f4:
; CHECK: ubfx r0, r0, #5, #3
    %tmp = shl i32 %a, 24
    %tmp2 = lshr i32 %tmp, 29
    ret i32 %tmp2
}

define i32 @f5(i32 %a) {
entry:
; CHECK: f5:
; CHECK-NOT: sbfx
; CHECK: bx
    %tmp = shl i32 %a, 3
    %tmp2 = ashr i32 %tmp, 1
    ret i32 %tmp2
}
