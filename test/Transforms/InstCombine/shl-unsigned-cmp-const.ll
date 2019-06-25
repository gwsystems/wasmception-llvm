; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -instcombine -S | FileCheck %s

; Simplify 'shl' inequality test into 'and' equality test.
;   (X l<< C2) u</u>= C1 iff C1 is power of 2 -> X & (-C1 l>> C2) ==/!= 0

; Scalar tests

; C2 Shift amount smaller than C1 trailing zeros.
define i1 @scalar_i8_shl_ult_const_1(i8 %x) {
; CHECK-LABEL: @scalar_i8_shl_ult_const_1(
; CHECK-NEXT:    [[SHL:%.*]] = shl i8 [[X:%.*]], 5
; CHECK-NEXT:    [[CMP:%.*]] = icmp ult i8 [[SHL]], 64
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %shl = shl i8 %x, 5
  %cmp = icmp ult i8 %shl, 64
  ret i1 %cmp
}

; C2 Shift amount equal to C1 trailing zeros.
define i1 @scalar_i8_shl_ult_const_2(i8 %x) {
; CHECK-LABEL: @scalar_i8_shl_ult_const_2(
; CHECK-NEXT:    [[SHL_MASK:%.*]] = and i8 [[X:%.*]], 3
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i8 [[SHL_MASK]], 0
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %shl = shl i8 %x, 6
  %cmp = icmp ult i8 %shl, 64
  ret i1 %cmp
}

; C2 Shift amount greater than C1 trailing zeros.
define i1 @scalar_i8_shl_ult_const_3(i8 %x) {
; CHECK-LABEL: @scalar_i8_shl_ult_const_3(
; CHECK-NEXT:    [[SHL_MASK:%.*]] = and i8 [[X:%.*]], 1
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i8 [[SHL_MASK]], 0
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %shl = shl i8 %x, 7
  %cmp = icmp ult i8 %shl, 64
  ret i1 %cmp
}

; C2 Shift amount smaller than C1 trailing zeros.
define i1 @scalar_i16_shl_ult_const(i16 %x) {
; CHECK-LABEL: @scalar_i16_shl_ult_const(
; CHECK-NEXT:    [[SHL:%.*]] = shl i16 [[X:%.*]], 8
; CHECK-NEXT:    [[CMP:%.*]] = icmp ult i16 [[SHL]], 1024
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %shl = shl i16 %x, 8
  %cmp = icmp ult i16 %shl, 1024
  ret i1 %cmp
}

define i1 @scalar_i32_shl_ult_const(i32 %x) {
; CHECK-LABEL: @scalar_i32_shl_ult_const(
; CHECK-NEXT:    [[SHL:%.*]] = shl i32 [[X:%.*]], 11
; CHECK-NEXT:    [[CMP:%.*]] = icmp ult i32 [[SHL]], 131072
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %shl = shl i32 %x, 11
  %cmp = icmp ult i32 %shl, 131072
  ret i1 %cmp
}

define i1 @scalar_i64_shl_ult_const(i64 %x) {
; CHECK-LABEL: @scalar_i64_shl_ult_const(
; CHECK-NEXT:    [[SHL:%.*]] = shl i64 [[X:%.*]], 25
; CHECK-NEXT:    [[CMP:%.*]] = icmp ult i64 [[SHL]], 8589934592
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %shl = shl i64 %x, 25
  %cmp = icmp ult i64 %shl, 8589934592
  ret i1 %cmp
}

; Check 'uge' predicate
define i1 @scalar_i8_shl_uge_const(i8 %x) {
; CHECK-LABEL: @scalar_i8_shl_uge_const(
; CHECK-NEXT:    [[SHL:%.*]] = shl i8 [[X:%.*]], 5
; CHECK-NEXT:    [[CMP:%.*]] = icmp ugt i8 [[SHL]], 63
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %shl = shl i8 %x, 5
  %cmp = icmp uge i8 %shl, 64
  ret i1 %cmp
}

; Check 'ule' predicate
define i1 @scalar_i8_shl_ule_const(i8 %x) {
; CHECK-LABEL: @scalar_i8_shl_ule_const(
; CHECK-NEXT:    [[SHL:%.*]] = shl i8 [[X:%.*]], 5
; CHECK-NEXT:    [[CMP:%.*]] = icmp ult i8 [[SHL]], 64
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %shl = shl i8 %x, 5
  %cmp = icmp ule i8 %shl, 63
  ret i1 %cmp
}

; Check 'ugt' predicate
define i1 @scalar_i8_shl_ugt_const(i8 %x) {
; CHECK-LABEL: @scalar_i8_shl_ugt_const(
; CHECK-NEXT:    [[SHL:%.*]] = shl i8 [[X:%.*]], 5
; CHECK-NEXT:    [[CMP:%.*]] = icmp ugt i8 [[SHL]], 63
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %shl = shl i8 %x, 5
  %cmp = icmp ugt i8 %shl, 63
  ret i1 %cmp
}

; Vector tests

define <4 x i1> @vector_4xi32_shl_ult_const(<4 x i32> %x) {
; CHECK-LABEL: @vector_4xi32_shl_ult_const(
; CHECK-NEXT:    [[SHL:%.*]] = shl <4 x i32> [[X:%.*]], <i32 11, i32 11, i32 11, i32 11>
; CHECK-NEXT:    [[CMP:%.*]] = icmp ult <4 x i32> [[SHL]], <i32 131072, i32 131072, i32 131072, i32 131072>
; CHECK-NEXT:    ret <4 x i1> [[CMP]]
;
  %shl = shl <4 x i32> %x, <i32 11, i32 11, i32 11, i32 11>
  %cmp = icmp ult <4 x i32> %shl, <i32 131072, i32 131072, i32 131072, i32 131072>
  ret <4 x i1> %cmp
}

define <4 x i1> @vector_4xi32_shl_ult_const_undef1(<4 x i32> %x) {
; CHECK-LABEL: @vector_4xi32_shl_ult_const_undef1(
; CHECK-NEXT:    [[SHL:%.*]] = shl <4 x i32> [[X:%.*]], <i32 11, i32 11, i32 undef, i32 11>
; CHECK-NEXT:    [[CMP:%.*]] = icmp ult <4 x i32> [[SHL]], <i32 131072, i32 131072, i32 131072, i32 131072>
; CHECK-NEXT:    ret <4 x i1> [[CMP]]
;
  %shl = shl <4 x i32> %x, <i32 11, i32 11, i32 undef, i32 11>
  %cmp = icmp ult <4 x i32> %shl, <i32 131072, i32 131072, i32 131072, i32 131072>
  ret <4 x i1> %cmp
}

define <4 x i1> @vector_4xi32_shl_ult_const_undef2(<4 x i32> %x) {
; CHECK-LABEL: @vector_4xi32_shl_ult_const_undef2(
; CHECK-NEXT:    [[SHL:%.*]] = shl <4 x i32> [[X:%.*]], <i32 11, i32 11, i32 11, i32 11>
; CHECK-NEXT:    [[CMP:%.*]] = icmp ult <4 x i32> [[SHL]], <i32 131072, i32 131072, i32 131072, i32 undef>
; CHECK-NEXT:    ret <4 x i1> [[CMP]]
;
  %shl = shl <4 x i32> %x, <i32 11, i32 11, i32 11, i32 11>
  %cmp = icmp ult <4 x i32> %shl, <i32 131072, i32 131072, i32 131072, i32 undef>
  ret <4 x i1> %cmp
}

define <4 x i1> @vector_4xi32_shl_ult_const_undef3(<4 x i32> %x) {
; CHECK-LABEL: @vector_4xi32_shl_ult_const_undef3(
; CHECK-NEXT:    [[SHL:%.*]] = shl <4 x i32> [[X:%.*]], <i32 11, i32 11, i32 undef, i32 11>
; CHECK-NEXT:    [[CMP:%.*]] = icmp ult <4 x i32> [[SHL]], <i32 undef, i32 131072, i32 131072, i32 131072>
; CHECK-NEXT:    ret <4 x i1> [[CMP]]
;
  %shl = shl <4 x i32> %x, <i32 11, i32 11, i32 undef, i32 11>
  %cmp = icmp ult <4 x i32> %shl, <i32 undef, i32 131072, i32 131072, i32 131072>
  ret <4 x i1> %cmp
}

; Check 'uge' predicate
define <4 x i1> @vector_4xi32_shl_uge_const(<4 x i32> %x) {
; CHECK-LABEL: @vector_4xi32_shl_uge_const(
; CHECK-NEXT:    [[SHL:%.*]] = shl <4 x i32> [[X:%.*]], <i32 11, i32 11, i32 11, i32 11>
; CHECK-NEXT:    [[CMP:%.*]] = icmp ugt <4 x i32> [[SHL]], <i32 131071, i32 131071, i32 131071, i32 131071>
; CHECK-NEXT:    ret <4 x i1> [[CMP]]
;
  %shl = shl <4 x i32> %x, <i32 11, i32 11, i32 11, i32 11>
  %cmp = icmp uge <4 x i32> %shl, <i32 131072, i32 131072, i32 131072, i32 131072>
  ret <4 x i1> %cmp
}

; Check 'ule' predicate
define <4 x i1> @vector_4xi32_shl_ule_const(<4 x i32> %x) {
; CHECK-LABEL: @vector_4xi32_shl_ule_const(
; CHECK-NEXT:    [[SHL:%.*]] = shl <4 x i32> [[X:%.*]], <i32 11, i32 11, i32 11, i32 11>
; CHECK-NEXT:    [[CMP:%.*]] = icmp ult <4 x i32> [[SHL]], <i32 131072, i32 131072, i32 131072, i32 131072>
; CHECK-NEXT:    ret <4 x i1> [[CMP]]
;
  %shl = shl <4 x i32> %x, <i32 11, i32 11, i32 11, i32 11>
  %cmp = icmp ule <4 x i32> %shl, <i32 131071, i32 131071, i32 131071, i32 131071>
  ret <4 x i1> %cmp
}

; Check 'ugt' predicate
define <4 x i1> @vector_4xi32_shl_ugt_const(<4 x i32> %x) {
; CHECK-LABEL: @vector_4xi32_shl_ugt_const(
; CHECK-NEXT:    [[SHL:%.*]] = shl <4 x i32> [[X:%.*]], <i32 11, i32 11, i32 11, i32 11>
; CHECK-NEXT:    [[CMP:%.*]] = icmp ugt <4 x i32> [[SHL]], <i32 131071, i32 131071, i32 131071, i32 131071>
; CHECK-NEXT:    ret <4 x i1> [[CMP]]
;
  %shl = shl <4 x i32> %x, <i32 11, i32 11, i32 11, i32 11>
  %cmp = icmp ugt <4 x i32> %shl, <i32 131071, i32 131071, i32 131071, i32 131071>
  ret <4 x i1> %cmp
}

; Extra use

; Not simplified
define i1 @scalar_i8_shl_ult_const_extra_use_shl(i8 %x, i8* %p) {
; CHECK-LABEL: @scalar_i8_shl_ult_const_extra_use_shl(
; CHECK-NEXT:    [[SHL:%.*]] = shl i8 [[X:%.*]], 5
; CHECK-NEXT:    store i8 [[SHL]], i8* [[P:%.*]], align 1
; CHECK-NEXT:    [[CMP:%.*]] = icmp ult i8 [[SHL]], 64
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %shl = shl i8 %x, 5
  store i8 %shl, i8* %p
  %cmp = icmp ult i8 %shl, 64
  ret i1 %cmp
}

; Negative tests

; Check 'slt' predicate
define i1 @scalar_i8_shl_slt_const(i8 %x) {
; CHECK-LABEL: @scalar_i8_shl_slt_const(
; CHECK-NEXT:    [[SHL:%.*]] = shl i8 [[X:%.*]], 5
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt i8 [[SHL]], 64
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %shl = shl i8 %x, 5
  %cmp = icmp slt i8 %shl, 64
  ret i1 %cmp
}

define i1 @scalar_i8_shl_ugt_const_not_power_of_2(i8 %x) {
; CHECK-LABEL: @scalar_i8_shl_ugt_const_not_power_of_2(
; CHECK-NEXT:    [[SHL:%.*]] = shl i8 [[X:%.*]], 5
; CHECK-NEXT:    [[CMP:%.*]] = icmp ugt i8 [[SHL]], 66
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %shl = shl i8 %x, 5
  %cmp = icmp ugt i8 %shl, 66
  ret i1 %cmp
}
