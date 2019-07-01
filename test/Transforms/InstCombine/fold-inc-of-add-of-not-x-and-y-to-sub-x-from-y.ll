; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -instcombine -S < %s | FileCheck %s

; Given:
;   add (add (xor %x, -1), %y), 1
; Transform it to:
;   sub %y, %x

;------------------------------------------------------------------------------;
; Scalar tests
;------------------------------------------------------------------------------;

define i32 @t0(i32 %x, i32 %y) {
; CHECK-LABEL: @t0(
; CHECK-NEXT:    [[T2:%.*]] = sub i32 [[Y:%.*]], [[X:%.*]]
; CHECK-NEXT:    ret i32 [[T2]]
;
  %t0 = xor i32 %x, -1
  %t1 = add i32 %t0, %y
  %t2 = add i32 %t1, 1
  ret i32 %t2
}

;------------------------------------------------------------------------------;
; Vector tests
;------------------------------------------------------------------------------;

define <4 x i32> @t1_vec_splat(<4 x i32> %x, <4 x i32> %y) {
; CHECK-LABEL: @t1_vec_splat(
; CHECK-NEXT:    [[T2:%.*]] = sub <4 x i32> [[Y:%.*]], [[X:%.*]]
; CHECK-NEXT:    ret <4 x i32> [[T2]]
;
  %t0 = xor <4 x i32> %x, <i32 -1, i32 -1, i32 -1, i32 -1>
  %t1 = add <4 x i32> %t0, %y
  %t2 = add <4 x i32> %t1, <i32 1, i32 1, i32 1, i32 1>
  ret <4 x i32> %t2
}

define <4 x i32> @t2_vec_undef0(<4 x i32> %x, <4 x i32> %y) {
; CHECK-LABEL: @t2_vec_undef0(
; CHECK-NEXT:    [[T2:%.*]] = sub <4 x i32> [[Y:%.*]], [[X:%.*]]
; CHECK-NEXT:    ret <4 x i32> [[T2]]
;
  %t0 = xor <4 x i32> %x, <i32 -1, i32 -1, i32 undef, i32 -1>
  %t1 = add <4 x i32> %t0, %y
  %t2 = add <4 x i32> %t1, <i32 1, i32 1, i32 1, i32 1>
  ret <4 x i32> %t2
}

define <4 x i32> @t3_vec_undef1(<4 x i32> %x, <4 x i32> %y) {
; CHECK-LABEL: @t3_vec_undef1(
; CHECK-NEXT:    [[T2:%.*]] = sub <4 x i32> [[Y:%.*]], [[X:%.*]]
; CHECK-NEXT:    ret <4 x i32> [[T2]]
;
  %t0 = xor <4 x i32> %x, <i32 -1, i32 -1, i32 -1, i32 -1>
  %t1 = add <4 x i32> %t0, %y
  %t2 = add <4 x i32> %t1, <i32 1, i32 1, i32 undef, i32 1>
  ret <4 x i32> %t2
}

define <4 x i32> @t4_vec_undef2(<4 x i32> %x, <4 x i32> %y) {
; CHECK-LABEL: @t4_vec_undef2(
; CHECK-NEXT:    [[T2:%.*]] = sub <4 x i32> [[Y:%.*]], [[X:%.*]]
; CHECK-NEXT:    ret <4 x i32> [[T2]]
;
  %t0 = xor <4 x i32> %x, <i32 -1, i32 -1, i32 undef, i32 -1>
  %t1 = add <4 x i32> %t0, %y
  %t2 = add <4 x i32> %t1, <i32 1, i32 1, i32 undef, i32 1>
  ret <4 x i32> %t2
}

;------------------------------------------------------------------------------;
; One-use tests
;------------------------------------------------------------------------------;

declare void @use32(i32)

define i32 @t5(i32 %x, i32 %y) {
; CHECK-LABEL: @t5(
; CHECK-NEXT:    [[T0:%.*]] = xor i32 [[X:%.*]], -1
; CHECK-NEXT:    call void @use32(i32 [[T0]])
; CHECK-NEXT:    [[T2:%.*]] = sub i32 [[Y:%.*]], [[X]]
; CHECK-NEXT:    ret i32 [[T2]]
;
  %t0 = xor i32 %x, -1
  call void @use32(i32 %t0)
  %t1 = add i32 %t0, %y
  %t2 = add i32 %t1, 1
  ret i32 %t2
}

define i32 @t6(i32 %x, i32 %y) {
; CHECK-LABEL: @t6(
; CHECK-NEXT:    [[T0:%.*]] = xor i32 [[X:%.*]], -1
; CHECK-NEXT:    [[T1:%.*]] = add i32 [[T0]], [[Y:%.*]]
; CHECK-NEXT:    call void @use32(i32 [[T1]])
; CHECK-NEXT:    [[T2:%.*]] = sub i32 [[Y]], [[X]]
; CHECK-NEXT:    ret i32 [[T2]]
;
  %t0 = xor i32 %x, -1
  %t1 = add i32 %t0, %y
  call void @use32(i32 %t1)
  %t2 = add i32 %t1, 1
  ret i32 %t2
}

define i32 @t7(i32 %x, i32 %y) {
; CHECK-LABEL: @t7(
; CHECK-NEXT:    [[T0:%.*]] = xor i32 [[X:%.*]], -1
; CHECK-NEXT:    call void @use32(i32 [[T0]])
; CHECK-NEXT:    [[T1:%.*]] = add i32 [[T0]], [[Y:%.*]]
; CHECK-NEXT:    call void @use32(i32 [[T1]])
; CHECK-NEXT:    [[T2:%.*]] = sub i32 [[Y]], [[X]]
; CHECK-NEXT:    ret i32 [[T2]]
;
  %t0 = xor i32 %x, -1
  call void @use32(i32 %t0)
  %t1 = add i32 %t0, %y
  call void @use32(i32 %t1)
  %t2 = add i32 %t1, 1
  ret i32 %t2
}

;------------------------------------------------------------------------------;
; Commutativity
;------------------------------------------------------------------------------;

declare i32 @gen32()

define i32 @t8_commutative0(i32 %x) {
; CHECK-LABEL: @t8_commutative0(
; CHECK-NEXT:    [[Y:%.*]] = call i32 @gen32()
; CHECK-NEXT:    [[T0:%.*]] = xor i32 [[X:%.*]], -1
; CHECK-NEXT:    call void @use32(i32 [[T0]])
; CHECK-NEXT:    [[T1:%.*]] = add i32 [[Y]], [[T0]]
; CHECK-NEXT:    call void @use32(i32 [[T1]])
; CHECK-NEXT:    [[T2:%.*]] = sub i32 [[Y]], [[X]]
; CHECK-NEXT:    ret i32 [[T2]]
;
  %y = call i32 @gen32()
  %t0 = xor i32 %x, -1
  call void @use32(i32 %t0)
  %t1 = add i32 %y, %t0 ; swapped
  call void @use32(i32 %t1)
  %t2 = add i32 %t1, 1
  ret i32 %t2
}

define i32 @t9_commutative1(i32 %x, i32 %y) {
; CHECK-LABEL: @t9_commutative1(
; CHECK-NEXT:    [[T0:%.*]] = xor i32 [[X:%.*]], -1
; CHECK-NEXT:    call void @use32(i32 [[T0]])
; CHECK-NEXT:    [[T1:%.*]] = sub i32 0, [[X]]
; CHECK-NEXT:    call void @use32(i32 [[T1]])
; CHECK-NEXT:    [[T2:%.*]] = sub i32 [[Y:%.*]], [[X]]
; CHECK-NEXT:    ret i32 [[T2]]
;
  %t0 = xor i32 %x, -1
  call void @use32(i32 %t0)
  %t1 = add i32 %t0, 1  ; +1 is not last
  call void @use32(i32 %t1)
  %t2 = add i32 %t1, %y ;
  ret i32 %t2
}

define i32 @t10_commutative2(i32 %x) {
; CHECK-LABEL: @t10_commutative2(
; CHECK-NEXT:    [[Y:%.*]] = call i32 @gen32()
; CHECK-NEXT:    [[T0:%.*]] = xor i32 [[X:%.*]], -1
; CHECK-NEXT:    call void @use32(i32 [[T0]])
; CHECK-NEXT:    [[T1:%.*]] = sub i32 0, [[X]]
; CHECK-NEXT:    call void @use32(i32 [[T1]])
; CHECK-NEXT:    [[T2:%.*]] = sub i32 [[Y]], [[X]]
; CHECK-NEXT:    ret i32 [[T2]]
;
  %y = call i32 @gen32()
  %t0 = xor i32 %x, -1
  call void @use32(i32 %t0)
  %t1 = add i32 %t0, 1  ; +1 is not last
  call void @use32(i32 %t1)
  %t2 = add i32 %y, %t1 ; swapped
  ret i32 %t2
}

;------------------------------------------------------------------------------;
; Basic negative tests
;------------------------------------------------------------------------------;

define i32 @n11(i32 %x, i32 %y) {
; CHECK-LABEL: @n11(
; CHECK-NEXT:    [[T0:%.*]] = xor i32 [[X:%.*]], 2147483647
; CHECK-NEXT:    [[T1:%.*]] = add i32 [[T0]], [[Y:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = add i32 [[T1]], 1
; CHECK-NEXT:    ret i32 [[T2]]
;
  %t0 = xor i32 %x, 2147483647 ; not -1
  %t1 = add i32 %t0, %y
  %t2 = add i32 %t1, 1
  ret i32 %t2
}

define i32 @n12(i32 %x, i32 %y) {
; CHECK-LABEL: @n12(
; CHECK-NEXT:    [[T0:%.*]] = xor i32 [[X:%.*]], -1
; CHECK-NEXT:    [[T1:%.*]] = add i32 [[T0]], [[Y:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = add i32 [[T1]], 2
; CHECK-NEXT:    ret i32 [[T2]]
;
  %t0 = xor i32 %x, -1
  %t1 = add i32 %t0, %y
  %t2 = add i32 %t1, 2 ; not +1
  ret i32 %t2
}
