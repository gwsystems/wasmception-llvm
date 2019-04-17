; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -instcombine -S | FileCheck %s

; Canonicalize vector ge/le comparisons with constants to gt/lt.

; Normal types are ConstantDataVectors. Test the constant values adjacent to the
; min/max values that we're not allowed to transform.

define <2 x i1> @sge(<2 x i8> %x) {
; CHECK-LABEL: @sge(
; CHECK-NEXT:    [[CMP:%.*]] = icmp sgt <2 x i8> [[X:%.*]], <i8 -128, i8 126>
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %cmp = icmp sge <2 x i8> %x, <i8 -127, i8 -129>
  ret <2 x i1> %cmp
}

define <2 x i1> @uge(<2 x i8> %x) {
; CHECK-LABEL: @uge(
; CHECK-NEXT:    [[CMP:%.*]] = icmp ugt <2 x i8> [[X:%.*]], <i8 -2, i8 0>
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %cmp = icmp uge <2 x i8> %x, <i8 -1, i8 1>
  ret <2 x i1> %cmp
}

define <2 x i1> @sle(<2 x i8> %x) {
; CHECK-LABEL: @sle(
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt <2 x i8> [[X:%.*]], <i8 127, i8 -127>
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %cmp = icmp sle <2 x i8> %x, <i8 126, i8 128>
  ret <2 x i1> %cmp
}

define <2 x i1> @ule(<2 x i8> %x) {
; CHECK-LABEL: @ule(
; CHECK-NEXT:    [[CMP:%.*]] = icmp ult <2 x i8> [[X:%.*]], <i8 -1, i8 1>
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %cmp = icmp ule <2 x i8> %x, <i8 254, i8 0>
  ret <2 x i1> %cmp
}

define <2 x i1> @ult_min_signed_value(<2 x i8> %x) {
; CHECK-LABEL: @ult_min_signed_value(
; CHECK-NEXT:    [[CMP:%.*]] = icmp sgt <2 x i8> [[X:%.*]], <i8 -1, i8 -1>
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %cmp = icmp ult <2 x i8> %x, <i8 128, i8 128>
  ret <2 x i1> %cmp
}

; Zeros are special: they're ConstantAggregateZero.

define <2 x i1> @sge_zero(<2 x i8> %x) {
; CHECK-LABEL: @sge_zero(
; CHECK-NEXT:    [[CMP:%.*]] = icmp sgt <2 x i8> [[X:%.*]], <i8 -1, i8 -1>
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %cmp = icmp sge <2 x i8> %x, <i8 0, i8 0>
  ret <2 x i1> %cmp
}

define <2 x i1> @uge_zero(<2 x i8> %x) {
; CHECK-LABEL: @uge_zero(
; CHECK-NEXT:    ret <2 x i1> <i1 true, i1 true>
;
  %cmp = icmp uge <2 x i8> %x, <i8 0, i8 0>
  ret <2 x i1> %cmp
}

define <2 x i1> @sle_zero(<2 x i8> %x) {
; CHECK-LABEL: @sle_zero(
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt <2 x i8> [[X:%.*]], <i8 1, i8 1>
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %cmp = icmp sle <2 x i8> %x, <i8 0, i8 0>
  ret <2 x i1> %cmp
}

define <2 x i1> @ule_zero(<2 x i8> %x) {
; CHECK-LABEL: @ule_zero(
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq <2 x i8> [[X:%.*]], zeroinitializer
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %cmp = icmp ule <2 x i8> %x, <i8 0, i8 0>
  ret <2 x i1> %cmp
}

; Weird types are ConstantVectors, not ConstantDataVectors. For an i3 type:
; Signed min = -4
; Unsigned min = 0
; Signed max = 3
; Unsigned max = 7

define <3 x i1> @sge_weird(<3 x i3> %x) {
; CHECK-LABEL: @sge_weird(
; CHECK-NEXT:    [[CMP:%.*]] = icmp sgt <3 x i3> [[X:%.*]], <i3 -4, i3 2, i3 -1>
; CHECK-NEXT:    ret <3 x i1> [[CMP]]
;
  %cmp = icmp sge <3 x i3> %x, <i3 -3, i3 -5, i3 0>
  ret <3 x i1> %cmp
}

define <3 x i1> @uge_weird(<3 x i3> %x) {
; CHECK-LABEL: @uge_weird(
; CHECK-NEXT:    [[CMP:%.*]] = icmp ugt <3 x i3> [[X:%.*]], <i3 -2, i3 0, i3 1>
; CHECK-NEXT:    ret <3 x i1> [[CMP]]
;
  %cmp = icmp uge <3 x i3> %x, <i3 -1, i3 1, i3 2>
  ret <3 x i1> %cmp
}

define <3 x i1> @sle_weird(<3 x i3> %x) {
; CHECK-LABEL: @sle_weird(
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt <3 x i3> [[X:%.*]], <i3 3, i3 -3, i3 1>
; CHECK-NEXT:    ret <3 x i1> [[CMP]]
;
  %cmp = icmp sle <3 x i3> %x, <i3 2, i3 4, i3 0>
  ret <3 x i1> %cmp
}

define <3 x i1> @ule_weird(<3 x i3> %x) {
; CHECK-LABEL: @ule_weird(
; CHECK-NEXT:    [[CMP:%.*]] = icmp ult <3 x i3> [[X:%.*]], <i3 -1, i3 1, i3 2>
; CHECK-NEXT:    ret <3 x i1> [[CMP]]
;
  %cmp = icmp ule <3 x i3> %x, <i3 6, i3 0, i3 1>
  ret <3 x i1> %cmp
}

; We can't do the transform if any constants are already at the limits.

define <2 x i1> @sge_min(<2 x i3> %x) {
; CHECK-LABEL: @sge_min(
; CHECK-NEXT:    [[CMP:%.*]] = icmp sge <2 x i3> [[X:%.*]], <i3 -4, i3 1>
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %cmp = icmp sge <2 x i3> %x, <i3 -4, i3 1>
  ret <2 x i1> %cmp
}

define <2 x i1> @uge_min(<2 x i3> %x) {
; CHECK-LABEL: @uge_min(
; CHECK-NEXT:    [[CMP:%.*]] = icmp uge <2 x i3> [[X:%.*]], <i3 1, i3 0>
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %cmp = icmp uge <2 x i3> %x, <i3 1, i3 0>
  ret <2 x i1> %cmp
}

define <2 x i1> @sle_max(<2 x i3> %x) {
; CHECK-LABEL: @sle_max(
; CHECK-NEXT:    [[CMP:%.*]] = icmp sle <2 x i3> [[X:%.*]], <i3 1, i3 3>
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %cmp = icmp sle <2 x i3> %x, <i3 1, i3 3>
  ret <2 x i1> %cmp
}

define <2 x i1> @ule_max(<2 x i3> %x) {
; CHECK-LABEL: @ule_max(
; CHECK-NEXT:    [[CMP:%.*]] = icmp ule <2 x i3> [[X:%.*]], <i3 -1, i3 1>
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %cmp = icmp ule <2 x i3> %x, <i3 7, i3 1>
  ret <2 x i1> %cmp
}

define <2 x i1> @PR27756_1(<2 x i8> %a) {
; CHECK-LABEL: @PR27756_1(
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt <2 x i8> [[A:%.*]], <i8 34, i8 1>
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %cmp = icmp sle <2 x i8> %a, <i8 bitcast (<2 x i4> <i4 1, i4 2> to i8), i8 0>
  ret <2 x i1> %cmp
}

; Undef elements don't prevent the transform of the comparison.

define <2 x i1> @PR27756_2(<2 x i8> %a) {
; CHECK-LABEL: @PR27756_2(
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt <2 x i8> [[A:%.*]], <i8 undef, i8 1>
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %cmp = icmp sle <2 x i8> %a, <i8 undef, i8 0>
  ret <2 x i1> %cmp
}

@someglobal = global i32 0

define <2 x i1> @PR27786(<2 x i8> %a) {
; CHECK-LABEL: @PR27786(
; CHECK-NEXT:    [[CMP:%.*]] = icmp sle <2 x i8> [[A:%.*]], bitcast (i16 ptrtoint (i32* @someglobal to i16) to <2 x i8>)
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %cmp = icmp sle <2 x i8> %a, bitcast (i16 ptrtoint (i32* @someglobal to i16) to <2 x i8>)
  ret <2 x i1> %cmp
}

; This is similar to a transform for shuffled binops: compare first, shuffle after.

define <4 x i1> @same_shuffle_inputs_icmp(<4 x i8> %x, <4 x i8> %y) {
; CHECK-LABEL: @same_shuffle_inputs_icmp(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp sgt <4 x i8> [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[CMP:%.*]] = shufflevector <4 x i1> [[TMP1]], <4 x i1> undef, <4 x i32> <i32 3, i32 3, i32 2, i32 0>
; CHECK-NEXT:    ret <4 x i1> [[CMP]]
;
  %shufx = shufflevector <4 x i8> %x, <4 x i8> undef, <4 x i32> < i32 3, i32 3, i32 2, i32 0 >
  %shufy = shufflevector <4 x i8> %y, <4 x i8> undef, <4 x i32> < i32 3, i32 3, i32 2, i32 0 >
  %cmp = icmp sgt <4 x i8> %shufx, %shufy
  ret <4 x i1> %cmp
}

; fcmp and size-changing shuffles are ok too.

define <5 x i1> @same_shuffle_inputs_fcmp(<4 x float> %x, <4 x float> %y) {
; CHECK-LABEL: @same_shuffle_inputs_fcmp(
; CHECK-NEXT:    [[TMP1:%.*]] = fcmp oeq <4 x float> [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[CMP:%.*]] = shufflevector <4 x i1> [[TMP1]], <4 x i1> undef, <5 x i32> <i32 0, i32 1, i32 3, i32 2, i32 0>
; CHECK-NEXT:    ret <5 x i1> [[CMP]]
;
  %shufx = shufflevector <4 x float> %x, <4 x float> undef, <5 x i32> < i32 0, i32 1, i32 3, i32 2, i32 0 >
  %shufy = shufflevector <4 x float> %y, <4 x float> undef, <5 x i32> < i32 0, i32 1, i32 3, i32 2, i32 0 >
  %cmp = fcmp oeq <5 x float> %shufx, %shufy
  ret <5 x i1> %cmp
}

declare void @use_v4i8(<4 x i8>)

define <4 x i1> @same_shuffle_inputs_icmp_extra_use1(<4 x i8> %x, <4 x i8> %y) {
; CHECK-LABEL: @same_shuffle_inputs_icmp_extra_use1(
; CHECK-NEXT:    [[SHUFX:%.*]] = shufflevector <4 x i8> [[X:%.*]], <4 x i8> undef, <4 x i32> <i32 3, i32 3, i32 3, i32 3>
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ugt <4 x i8> [[X]], [[Y:%.*]]
; CHECK-NEXT:    [[CMP:%.*]] = shufflevector <4 x i1> [[TMP1]], <4 x i1> undef, <4 x i32> <i32 3, i32 3, i32 3, i32 3>
; CHECK-NEXT:    call void @use_v4i8(<4 x i8> [[SHUFX]])
; CHECK-NEXT:    ret <4 x i1> [[CMP]]
;
  %shufx = shufflevector <4 x i8> %x, <4 x i8> undef, <4 x i32> < i32 3, i32 3, i32 3, i32 3 >
  %shufy = shufflevector <4 x i8> %y, <4 x i8> undef, <4 x i32> < i32 3, i32 3, i32 3, i32 3 >
  %cmp = icmp ugt <4 x i8> %shufx, %shufy
  call void @use_v4i8(<4 x i8> %shufx)
  ret <4 x i1> %cmp
}

declare void @use_v2i8(<2 x i8>)

define <2 x i1> @same_shuffle_inputs_icmp_extra_use2(<4 x i8> %x, <4 x i8> %y) {
; CHECK-LABEL: @same_shuffle_inputs_icmp_extra_use2(
; CHECK-NEXT:    [[SHUFY:%.*]] = shufflevector <4 x i8> [[Y:%.*]], <4 x i8> undef, <2 x i32> <i32 3, i32 2>
; CHECK-NEXT:    [[TMP1:%.*]] = icmp eq <4 x i8> [[X:%.*]], [[Y]]
; CHECK-NEXT:    [[CMP:%.*]] = shufflevector <4 x i1> [[TMP1]], <4 x i1> undef, <2 x i32> <i32 3, i32 2>
; CHECK-NEXT:    call void @use_v2i8(<2 x i8> [[SHUFY]])
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %shufx = shufflevector <4 x i8> %x, <4 x i8> undef, <2 x i32> < i32 3, i32 2 >
  %shufy = shufflevector <4 x i8> %y, <4 x i8> undef, <2 x i32> < i32 3, i32 2 >
  %cmp = icmp eq <2 x i8> %shufx, %shufy
  call void @use_v2i8(<2 x i8> %shufy)
  ret <2 x i1> %cmp
}

; Negative test: if both shuffles have extra uses, don't transform because that would increase instruction count.

define <2 x i1> @same_shuffle_inputs_icmp_extra_use3(<4 x i8> %x, <4 x i8> %y) {
; CHECK-LABEL: @same_shuffle_inputs_icmp_extra_use3(
; CHECK-NEXT:    [[SHUFX:%.*]] = shufflevector <4 x i8> [[X:%.*]], <4 x i8> undef, <2 x i32> zeroinitializer
; CHECK-NEXT:    [[SHUFY:%.*]] = shufflevector <4 x i8> [[Y:%.*]], <4 x i8> undef, <2 x i32> zeroinitializer
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq <2 x i8> [[SHUFX]], [[SHUFY]]
; CHECK-NEXT:    call void @use_v2i8(<2 x i8> [[SHUFX]])
; CHECK-NEXT:    call void @use_v2i8(<2 x i8> [[SHUFY]])
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %shufx = shufflevector <4 x i8> %x, <4 x i8> undef, <2 x i32> < i32 0, i32 0 >
  %shufy = shufflevector <4 x i8> %y, <4 x i8> undef, <2 x i32> < i32 0, i32 0 >
  %cmp = icmp eq <2 x i8> %shufx, %shufy
  call void @use_v2i8(<2 x i8> %shufx)
  call void @use_v2i8(<2 x i8> %shufy)
  ret <2 x i1> %cmp
}

