; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt %s -instcombine -S | FileCheck %s

; If we have:
;   (data & (-1 << nbits)) outer>> nbits
; Or
;   ((data inner>> nbits) << nbits) outer>> nbits
; The mask is redundant, and can be dropped:
;   data outer>> nbits
; This is valid for both lshr and ashr in both positions and any combination.

define i32 @t0_lshr(i32 %data, i32 %nbits) {
; CHECK-LABEL: @t0_lshr(
; CHECK-NEXT:    [[T0:%.*]] = shl i32 -1, [[NBITS:%.*]]
; CHECK-NEXT:    [[T1:%.*]] = and i32 [[T0]], [[DATA:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = lshr i32 [[T1]], [[NBITS]]
; CHECK-NEXT:    ret i32 [[T2]]
;
  %t0 = shl i32 -1, %nbits
  %t1 = and i32 %t0, %data
  %t2 = lshr i32 %t1, %nbits
  ret i32 %t2
}
define i32 @t1_sshr(i32 %data, i32 %nbits) {
; CHECK-LABEL: @t1_sshr(
; CHECK-NEXT:    [[T0:%.*]] = shl i32 -1, [[NBITS:%.*]]
; CHECK-NEXT:    [[T1:%.*]] = and i32 [[T0]], [[DATA:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = ashr i32 [[T1]], [[NBITS]]
; CHECK-NEXT:    ret i32 [[T2]]
;
  %t0 = shl i32 -1, %nbits
  %t1 = and i32 %t0, %data
  %t2 = ashr i32 %t1, %nbits
  ret i32 %t2
}

; Vectors

define <4 x i32> @t2_vec(<4 x i32> %data, <4 x i32> %nbits) {
; CHECK-LABEL: @t2_vec(
; CHECK-NEXT:    [[T0:%.*]] = shl <4 x i32> <i32 -1, i32 -1, i32 -1, i32 -1>, [[NBITS:%.*]]
; CHECK-NEXT:    [[T1:%.*]] = and <4 x i32> [[T0]], [[DATA:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = lshr <4 x i32> [[T1]], [[NBITS]]
; CHECK-NEXT:    ret <4 x i32> [[T2]]
;
  %t0 = shl <4 x i32> <i32 -1, i32 -1, i32 -1, i32 -1>, %nbits
  %t1 = and <4 x i32> %t0, %data
  %t2 = lshr <4 x i32> %t1, %nbits
  ret <4 x i32> %t2
}

define <4 x i32> @t3_vec_undef(<4 x i32> %data, <4 x i32> %nbits) {
; CHECK-LABEL: @t3_vec_undef(
; CHECK-NEXT:    [[T0:%.*]] = shl <4 x i32> <i32 -1, i32 -1, i32 undef, i32 -1>, [[NBITS:%.*]]
; CHECK-NEXT:    [[T1:%.*]] = and <4 x i32> [[T0]], [[DATA:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = lshr <4 x i32> [[T1]], [[NBITS]]
; CHECK-NEXT:    ret <4 x i32> [[T2]]
;
  %t0 = shl <4 x i32> <i32 -1, i32 -1, i32 undef, i32 -1>, %nbits
  %t1 = and <4 x i32> %t0, %data
  %t2 = lshr <4 x i32> %t1, %nbits
  ret <4 x i32> %t2
}

; Extra uses

declare void @use32(i32)

define i32 @t4_extrause0(i32 %data, i32 %nbits) {
; CHECK-LABEL: @t4_extrause0(
; CHECK-NEXT:    [[T0:%.*]] = shl i32 -1, [[NBITS:%.*]]
; CHECK-NEXT:    call void @use32(i32 [[T0]])
; CHECK-NEXT:    [[T1:%.*]] = and i32 [[T0]], [[DATA:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = lshr i32 [[T1]], [[NBITS]]
; CHECK-NEXT:    ret i32 [[T2]]
;
  %t0 = shl i32 -1, %nbits
  call void @use32(i32 %t0)
  %t1 = and i32 %t0, %data
  %t2 = lshr i32 %t1, %nbits
  ret i32 %t2
}

define i32 @t5_extrause1(i32 %data, i32 %nbits) {
; CHECK-LABEL: @t5_extrause1(
; CHECK-NEXT:    [[T0:%.*]] = shl i32 -1, [[NBITS:%.*]]
; CHECK-NEXT:    [[T1:%.*]] = and i32 [[T0]], [[DATA:%.*]]
; CHECK-NEXT:    call void @use32(i32 [[T1]])
; CHECK-NEXT:    [[T2:%.*]] = lshr i32 [[T1]], [[NBITS]]
; CHECK-NEXT:    ret i32 [[T2]]
;
  %t0 = shl i32 -1, %nbits
  %t1 = and i32 %t0, %data
  call void @use32(i32 %t1)
  %t2 = lshr i32 %t1, %nbits
  ret i32 %t2
}

define i32 @t6_extrause2(i32 %data, i32 %nbits) {
; CHECK-LABEL: @t6_extrause2(
; CHECK-NEXT:    [[T0:%.*]] = shl i32 -1, [[NBITS:%.*]]
; CHECK-NEXT:    call void @use32(i32 [[T0]])
; CHECK-NEXT:    [[T1:%.*]] = and i32 [[T0]], [[DATA:%.*]]
; CHECK-NEXT:    call void @use32(i32 [[T1]])
; CHECK-NEXT:    [[T2:%.*]] = lshr i32 [[T1]], [[NBITS]]
; CHECK-NEXT:    ret i32 [[T2]]
;
  %t0 = shl i32 -1, %nbits
  call void @use32(i32 %t0)
  %t1 = and i32 %t0, %data
  call void @use32(i32 %t1)
  %t2 = lshr i32 %t1, %nbits
  ret i32 %t2
}

; Non-canonical mask pattern. Let's just test a single case with all-extra uses.

define i32 @t7_noncanonical_lshr_lshr_extrauses(i32 %data, i32 %nbits) {
; CHECK-LABEL: @t7_noncanonical_lshr_lshr_extrauses(
; CHECK-NEXT:    [[T0:%.*]] = lshr i32 [[DATA:%.*]], [[NBITS:%.*]]
; CHECK-NEXT:    call void @use32(i32 [[T0]])
; CHECK-NEXT:    [[T1:%.*]] = shl i32 [[T0]], [[NBITS]]
; CHECK-NEXT:    call void @use32(i32 [[T1]])
; CHECK-NEXT:    [[T2:%.*]] = lshr i32 [[T1]], [[NBITS]]
; CHECK-NEXT:    ret i32 [[T2]]
;
  %t0 = lshr i32 %data, %nbits
  call void @use32(i32 %t0)
  %t1 = shl i32 %t0, %nbits
  call void @use32(i32 %t1)
  %t2 = lshr i32 %t1, %nbits
  ret i32 %t2
}

define i32 @t8_noncanonical_lshr_ashr_extrauses(i32 %data, i32 %nbits) {
; CHECK-LABEL: @t8_noncanonical_lshr_ashr_extrauses(
; CHECK-NEXT:    [[T0:%.*]] = lshr i32 [[DATA:%.*]], [[NBITS:%.*]]
; CHECK-NEXT:    call void @use32(i32 [[T0]])
; CHECK-NEXT:    [[T1:%.*]] = shl i32 [[T0]], [[NBITS]]
; CHECK-NEXT:    call void @use32(i32 [[T1]])
; CHECK-NEXT:    [[T2:%.*]] = ashr i32 [[T1]], [[NBITS]]
; CHECK-NEXT:    ret i32 [[T2]]
;
  %t0 = lshr i32 %data, %nbits
  call void @use32(i32 %t0)
  %t1 = shl i32 %t0, %nbits
  call void @use32(i32 %t1)
  %t2 = ashr i32 %t1, %nbits
  ret i32 %t2
}

define i32 @t9_noncanonical_ashr_lshr_extrauses(i32 %data, i32 %nbits) {
; CHECK-LABEL: @t9_noncanonical_ashr_lshr_extrauses(
; CHECK-NEXT:    [[T0:%.*]] = ashr i32 [[DATA:%.*]], [[NBITS:%.*]]
; CHECK-NEXT:    call void @use32(i32 [[T0]])
; CHECK-NEXT:    [[T1:%.*]] = shl i32 [[T0]], [[NBITS]]
; CHECK-NEXT:    call void @use32(i32 [[T1]])
; CHECK-NEXT:    [[T2:%.*]] = lshr i32 [[T1]], [[NBITS]]
; CHECK-NEXT:    ret i32 [[T2]]
;
  %t0 = ashr i32 %data, %nbits
  call void @use32(i32 %t0)
  %t1 = shl i32 %t0, %nbits
  call void @use32(i32 %t1)
  %t2 = lshr i32 %t1, %nbits
  ret i32 %t2
}

define i32 @t10_noncanonical_ashr_ashr_extrauses(i32 %data, i32 %nbits) {
; CHECK-LABEL: @t10_noncanonical_ashr_ashr_extrauses(
; CHECK-NEXT:    [[T0:%.*]] = ashr i32 [[DATA:%.*]], [[NBITS:%.*]]
; CHECK-NEXT:    call void @use32(i32 [[T0]])
; CHECK-NEXT:    [[T1:%.*]] = shl i32 [[T0]], [[NBITS]]
; CHECK-NEXT:    call void @use32(i32 [[T1]])
; CHECK-NEXT:    [[T2:%.*]] = ashr i32 [[T1]], [[NBITS]]
; CHECK-NEXT:    ret i32 [[T2]]
;
  %t0 = ashr i32 %data, %nbits
  call void @use32(i32 %t0)
  %t1 = shl i32 %t0, %nbits
  call void @use32(i32 %t1)
  %t2 = ashr i32 %t1, %nbits
  ret i32 %t2
}

; Negative tests

define i32 @n11(i32 %data, i32 %nbits) {
; CHECK-LABEL: @n11(
; CHECK-NEXT:    [[T0:%.*]] = shl i32 2147483647, [[NBITS:%.*]]
; CHECK-NEXT:    [[T1:%.*]] = and i32 [[T0]], [[DATA:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = lshr i32 [[T1]], [[NBITS]]
; CHECK-NEXT:    ret i32 [[T2]]
;
  %t0 = shl i32 2147483647, %nbits ; must be shifting -1
  %t1 = and i32 %t0, %data
  %t2 = lshr i32 %t1, %nbits
  ret i32 %t2
}

define i32 @n12(i32 %data, i32 %nbits0, i32 %nbits1) {
; CHECK-LABEL: @n12(
; CHECK-NEXT:    [[T0:%.*]] = shl i32 -1, [[NBITS0:%.*]]
; CHECK-NEXT:    [[T1:%.*]] = and i32 [[T0]], [[DATA:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = lshr i32 [[T1]], [[NBITS1:%.*]]
; CHECK-NEXT:    ret i32 [[T2]]
;
  %t0 = shl i32 -1, %nbits0
  %t1 = and i32 %t0, %data
  %t2 = lshr i32 %t1, %nbits1 ; different shift amounts
  ret i32 %t2
}

define i32 @n13(i32 %data, i32 %nbits0, i32 %nbits1, i32 %nbits2) {
; CHECK-LABEL: @n13(
; CHECK-NEXT:    [[T0:%.*]] = lshr i32 [[DATA:%.*]], [[NBITS0:%.*]]
; CHECK-NEXT:    call void @use32(i32 [[T0]])
; CHECK-NEXT:    [[T1:%.*]] = shl i32 [[T0]], [[NBITS1:%.*]]
; CHECK-NEXT:    call void @use32(i32 [[T1]])
; CHECK-NEXT:    [[T2:%.*]] = lshr i32 [[T1]], [[NBITS2:%.*]]
; CHECK-NEXT:    ret i32 [[T2]]
;
  %t0 = lshr i32 %data, %nbits0
  call void @use32(i32 %t0)
  %t1 = shl i32 %t0, %nbits1 ; different shift amounts
  call void @use32(i32 %t1)
  %t2 = lshr i32 %t1, %nbits2 ; different shift amounts
  ret i32 %t2
}
