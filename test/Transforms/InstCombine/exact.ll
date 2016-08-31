; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -instcombine -S | FileCheck %s

define i32 @sdiv1(i32 %x) {
; CHECK-LABEL: @sdiv1(
; CHECK-NEXT:    [[Y:%.*]] = sdiv i32 %x, 8
; CHECK-NEXT:    ret i32 [[Y]]
;
  %y = sdiv i32 %x, 8
  ret i32 %y
}

define i32 @sdiv2(i32 %x) {
; CHECK-LABEL: @sdiv2(
; CHECK-NEXT:    [[Y:%.*]] = ashr exact i32 %x, 3
; CHECK-NEXT:    ret i32 [[Y]]
;
  %y = sdiv exact i32 %x, 8
  ret i32 %y
}

define <2 x i32> @sdiv2_vec(<2 x i32> %x) {
; CHECK-LABEL: @sdiv2_vec(
; CHECK-NEXT:    [[Y:%.*]] = ashr exact <2 x i32> %x, <i32 7, i32 7>
; CHECK-NEXT:    ret <2 x i32> [[Y]]
;
  %y = sdiv exact <2 x i32> %x, <i32 128, i32 128>
  ret <2 x i32> %y
}

define i32 @sdiv3(i32 %x) {
; CHECK-LABEL: @sdiv3(
; CHECK-NEXT:    [[Y:%.*]] = srem i32 %x, 3
; CHECK-NEXT:    [[Z:%.*]] = sub i32 %x, [[Y]]
; CHECK-NEXT:    ret i32 [[Z]]
;
  %y = sdiv i32 %x, 3
  %z = mul i32 %y, 3
  ret i32 %z
}

define i32 @sdiv4(i32 %x) {
; CHECK-LABEL: @sdiv4(
; CHECK-NEXT:    ret i32 %x
;
  %y = sdiv exact i32 %x, 3
  %z = mul i32 %y, 3
  ret i32 %z
}

define i32 @sdiv5(i32 %x) {
; CHECK-LABEL: @sdiv5(
; CHECK-NEXT:    [[Y:%.*]] = srem i32 %x, 3
; CHECK-NEXT:    [[Z:%.*]] = sub i32 [[Y]], %x
; CHECK-NEXT:    ret i32 [[Z]]
;
  %y = sdiv i32 %x, 3
  %z = mul i32 %y, -3
  ret i32 %z
}

define i32 @sdiv6(i32 %x) {
; CHECK-LABEL: @sdiv6(
; CHECK-NEXT:    [[Z:%.*]] = sub i32 0, %x
; CHECK-NEXT:    ret i32 [[Z]]
;
  %y = sdiv exact i32 %x, 3
  %z = mul i32 %y, -3
  ret i32 %z
}

define i32 @udiv1(i32 %x, i32 %w) {
; CHECK-LABEL: @udiv1(
; CHECK-NEXT:    ret i32 %x
;
  %y = udiv exact i32 %x, %w
  %z = mul i32 %y, %w
  ret i32 %z
}

define i32 @udiv2(i32 %x, i32 %w) {
; CHECK-LABEL: @udiv2(
; CHECK-NEXT:    [[Z:%.*]] = lshr exact i32 %x, %w
; CHECK-NEXT:    ret i32 [[Z]]
;
  %y = shl i32 1, %w
  %z = udiv exact i32 %x, %y
  ret i32 %z
}

define i64 @ashr1(i64 %X) nounwind {
; CHECK-LABEL: @ashr1(
; CHECK-NEXT:    [[A:%.*]] = shl i64 %X, 8
; CHECK-NEXT:    [[B:%.*]] = ashr exact i64 [[A]], 2
; CHECK-NEXT:    ret i64 [[B]]
;
  %A = shl i64 %X, 8
  %B = ashr i64 %A, 2   ; X/4
  ret i64 %B
}

; PR9120
define i1 @ashr_icmp1(i64 %X) nounwind {
; CHECK-LABEL: @ashr_icmp1(
; CHECK-NEXT:    [[B:%.*]] = icmp eq i64 %X, 0
; CHECK-NEXT:    ret i1 [[B]]
;
  %A = ashr exact i64 %X, 2   ; X/4
  %B = icmp eq i64 %A, 0
  ret i1 %B
}

define i1 @ashr_icmp2(i64 %X) {
; CHECK-LABEL: @ashr_icmp2(
; CHECK-NEXT:    [[Z:%.*]] = icmp slt i64 %X, 16
; CHECK-NEXT:    ret i1 [[Z]]
;
  %Y = ashr exact i64 %X, 2  ; x / 4
  %Z = icmp slt i64 %Y, 4    ; x < 16
  ret i1 %Z
}

; FIXME: Vectors should fold the same way.
define <2 x i1> @ashr_icmp2_vec(<2 x i64> %X) {
; CHECK-LABEL: @ashr_icmp2_vec(
; CHECK-NEXT:    [[Y:%.*]] = ashr exact <2 x i64> %X, <i64 2, i64 2>
; CHECK-NEXT:    [[Z:%.*]] = icmp slt <2 x i64> [[Y]], <i64 4, i64 4>
; CHECK-NEXT:    ret <2 x i1> [[Z]]
;
  %Y = ashr exact <2 x i64> %X, <i64 2, i64 2>
  %Z = icmp slt <2 x i64> %Y, <i64 4, i64 4>
  ret <2 x i1> %Z
}

; PR9998
; Make sure we don't transform the ashr here into an sdiv
define i1 @pr9998(i32 %V) nounwind {
; CHECK-LABEL: @pr9998(
; CHECK-NEXT:    [[W_MASK:%.*]] = and i32 %V, 1
; CHECK-NEXT:    [[Z:%.*]] = icmp ne i32 [[W_MASK]], 0
; CHECK-NEXT:    ret i1 [[Z]]
;
  %W = shl i32 %V, 31
  %X = ashr exact i32 %W, 31
  %Y = sext i32 %X to i64
  %Z = icmp ugt i64 %Y, 7297771788697658747
  ret i1 %Z
}

define i1 @udiv_icmp1(i64 %X) {
; CHECK-LABEL: @udiv_icmp1(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ne i64 %X, 0
; CHECK-NEXT:    ret i1 [[TMP1]]
;
  %A = udiv exact i64 %X, 5   ; X/5
  %B = icmp ne i64 %A, 0
  ret i1 %B
}

define <2 x i1> @udiv_icmp1_vec(<2 x i64> %X) {
; CHECK-LABEL: @udiv_icmp1_vec(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ne <2 x i64> %X, zeroinitializer
; CHECK-NEXT:    ret <2 x i1> [[TMP1]]
;
  %A = udiv exact <2 x i64> %X, <i64 5, i64 5>
  %B = icmp ne <2 x i64> %A, zeroinitializer
  ret <2 x i1> %B
}

define i1 @udiv_icmp2(i64 %X) {
; CHECK-LABEL: @udiv_icmp2(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp eq i64 %X, 0
; CHECK-NEXT:    ret i1 [[TMP1]]
;
  %A = udiv exact i64 %X, 5   ; X/5 == 0 --> x == 0
  %B = icmp eq i64 %A, 0
  ret i1 %B
}

; FIXME: missing vector fold for ult 1 -> eq 0
define <2 x i1> @udiv_icmp2_vec(<2 x i64> %X) {
; CHECK-LABEL: @udiv_icmp2_vec(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ult <2 x i64> %X, <i64 1, i64 1>
; CHECK-NEXT:    ret <2 x i1> [[TMP1]]
;
  %A = udiv exact <2 x i64> %X, <i64 5, i64 5>
  %B = icmp eq <2 x i64> %A, zeroinitializer
  ret <2 x i1> %B
}

define i1 @sdiv_icmp1(i64 %X) {
; CHECK-LABEL: @sdiv_icmp1(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp eq i64 %X, 0
; CHECK-NEXT:    ret i1 [[TMP1]]
;
  %A = sdiv exact i64 %X, 5   ; X/5 == 0 --> x == 0
  %B = icmp eq i64 %A, 0
  ret i1 %B
}

; FIXME: missing vector fold for ult 1 -> eq 0
define <2 x i1> @sdiv_icmp1_vec(<2 x i64> %X) {
; CHECK-LABEL: @sdiv_icmp1_vec(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ult <2 x i64> %X, <i64 1, i64 1>
; CHECK-NEXT:    ret <2 x i1> [[TMP1]]
;
  %A = sdiv exact <2 x i64> %X, <i64 5, i64 5>
  %B = icmp eq <2 x i64> %A, zeroinitializer
  ret <2 x i1> %B
}

define i1 @sdiv_icmp2(i64 %X) {
; CHECK-LABEL: @sdiv_icmp2(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp eq i64 %X, 5
; CHECK-NEXT:    ret i1 [[TMP1]]
;
  %A = sdiv exact i64 %X, 5   ; X/5 == 1 --> x == 5
  %B = icmp eq i64 %A, 1
  ret i1 %B
}

define <2 x i1> @sdiv_icmp2_vec(<2 x i64> %X) {
; CHECK-LABEL: @sdiv_icmp2_vec(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp eq <2 x i64> %X, <i64 5, i64 5>
; CHECK-NEXT:    ret <2 x i1> [[TMP1]]
;
  %A = sdiv exact <2 x i64> %X, <i64 5, i64 5>
  %B = icmp eq <2 x i64> %A, <i64 1, i64 1>
  ret <2 x i1> %B
}

define i1 @sdiv_icmp3(i64 %X) {
; CHECK-LABEL: @sdiv_icmp3(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp eq i64 %X, -5
; CHECK-NEXT:    ret i1 [[TMP1]]
;
  %A = sdiv exact i64 %X, 5   ; X/5 == -1 --> x == -5
  %B = icmp eq i64 %A, -1
  ret i1 %B
}

define <2 x i1> @sdiv_icmp3_vec(<2 x i64> %X) {
; CHECK-LABEL: @sdiv_icmp3_vec(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp eq <2 x i64> %X, <i64 -5, i64 -5>
; CHECK-NEXT:    ret <2 x i1> [[TMP1]]
;
  %A = sdiv exact <2 x i64> %X, <i64 5, i64 5>
  %B = icmp eq <2 x i64> %A, <i64 -1, i64 -1>
  ret <2 x i1> %B
}

define i1 @sdiv_icmp4(i64 %X) {
; CHECK-LABEL: @sdiv_icmp4(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp eq i64 %X, 0
; CHECK-NEXT:    ret i1 [[TMP1]]
;
  %A = sdiv exact i64 %X, -5   ; X/-5 == 0 --> x == 0
  %B = icmp eq i64 %A, 0
  ret i1 %B
}

; FIXME: missing vector fold for ult 1 -> eq 0
define <2 x i1> @sdiv_icmp4_vec(<2 x i64> %X) {
; CHECK-LABEL: @sdiv_icmp4_vec(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ult <2 x i64> %X, <i64 1, i64 1>
; CHECK-NEXT:    ret <2 x i1> [[TMP1]]
;
  %A = sdiv exact <2 x i64> %X, <i64 -5, i64 -5>
  %B = icmp eq <2 x i64> %A, zeroinitializer
  ret <2 x i1> %B
}

define i1 @sdiv_icmp5(i64 %X) {
; CHECK-LABEL: @sdiv_icmp5(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp eq i64 %X, -5
; CHECK-NEXT:    ret i1 [[TMP1]]
;
  %A = sdiv exact i64 %X, -5   ; X/-5 == 1 --> x == -5
  %B = icmp eq i64 %A, 1
  ret i1 %B
}

define <2 x i1> @sdiv_icmp5_vec(<2 x i64> %X) {
; CHECK-LABEL: @sdiv_icmp5_vec(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp eq <2 x i64> %X, <i64 -5, i64 -5>
; CHECK-NEXT:    ret <2 x i1> [[TMP1]]
;
  %A = sdiv exact <2 x i64> %X, <i64 -5, i64 -5>
  %B = icmp eq <2 x i64> %A, <i64 1, i64 1>
  ret <2 x i1> %B
}

define i1 @sdiv_icmp6(i64 %X) {
; CHECK-LABEL: @sdiv_icmp6(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp eq i64 %X, 5
; CHECK-NEXT:    ret i1 [[TMP1]]
;
  %A = sdiv exact i64 %X, -5   ; X/-5 == -1 --> x == 5
  %B = icmp eq i64 %A, -1
  ret i1 %B
}

define <2 x i1> @sdiv_icmp6_vec(<2 x i64> %X) {
; CHECK-LABEL: @sdiv_icmp6_vec(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp eq <2 x i64> %X, <i64 5, i64 5>
; CHECK-NEXT:    ret <2 x i1> [[TMP1]]
;
  %A = sdiv exact <2 x i64> %X, <i64 -5, i64 -5>
  %B = icmp eq <2 x i64> %A, <i64 -1, i64 -1>
  ret <2 x i1> %B
}

