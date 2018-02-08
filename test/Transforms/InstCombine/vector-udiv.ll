; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -instcombine -S | FileCheck %s

define <4 x i32> @test_v4i32_splatconst_pow2(<4 x i32> %a0) {
; CHECK-LABEL: @test_v4i32_splatconst_pow2(
; CHECK-NEXT:    [[TMP1:%.*]] = lshr <4 x i32> [[A0:%.*]], <i32 1, i32 1, i32 1, i32 1>
; CHECK-NEXT:    ret <4 x i32> [[TMP1]]
;
  %1 = udiv <4 x i32> %a0, <i32 2, i32 2, i32 2, i32 2>
  ret <4 x i32> %1
}

define <4 x i32> @test_v4i32_const_pow2(<4 x i32> %a0) {
; CHECK-LABEL: @test_v4i32_const_pow2(
; CHECK-NEXT:    [[TMP1:%.*]] = lshr <4 x i32> [[A0:%.*]], <i32 0, i32 1, i32 2, i32 3>
; CHECK-NEXT:    ret <4 x i32> [[TMP1]]
;
  %1 = udiv <4 x i32> %a0, <i32 1, i32 2, i32 4, i32 8>
  ret <4 x i32> %1
}

; X udiv C, where C >= signbit
define <4 x i32> @test_v4i32_negconstsplat(<4 x i32> %a0) {
; CHECK-LABEL: @test_v4i32_negconstsplat(
; CHECK-NEXT:    [[TMP1:%.*]] = udiv <4 x i32> [[A0:%.*]], <i32 -3, i32 -3, i32 -3, i32 -3>
; CHECK-NEXT:    ret <4 x i32> [[TMP1]]
;
  %1 = udiv <4 x i32> %a0, <i32 -3, i32 -3, i32 -3, i32 -3>
  ret <4 x i32> %1
}

define <4 x i32> @test_v4i32_negconst(<4 x i32> %a0) {
; CHECK-LABEL: @test_v4i32_negconst(
; CHECK-NEXT:    [[TMP1:%.*]] = udiv <4 x i32> [[A0:%.*]], <i32 -3, i32 -5, i32 -7, i32 -9>
; CHECK-NEXT:    ret <4 x i32> [[TMP1]]
;
  %1 = udiv <4 x i32> %a0, <i32 -3, i32 -5, i32 -7, i32 -9>
  ret <4 x i32> %1
}

define <4 x i32> @test_v4i32_negconst_undef(<4 x i32> %a0) {
; CHECK-LABEL: @test_v4i32_negconst_undef(
; CHECK-NEXT:    ret <4 x i32> undef
;
  %1 = udiv <4 x i32> %a0, <i32 -3, i32 -5, i32 -7, i32 undef>
  ret <4 x i32> %1
}

; X udiv (C1 << N), where C1 is "1<<C2"  -->  X >> (N+C2)
define <4 x i32> @test_v4i32_shl_splatconst_pow2(<4 x i32> %a0, <4 x i32> %a1) {
; CHECK-LABEL: @test_v4i32_shl_splatconst_pow2(
; CHECK-NEXT:    [[TMP1:%.*]] = add <4 x i32> [[A1:%.*]], <i32 2, i32 2, i32 2, i32 2>
; CHECK-NEXT:    [[TMP2:%.*]] = lshr <4 x i32> [[A0:%.*]], [[TMP1]]
; CHECK-NEXT:    ret <4 x i32> [[TMP2]]
;
  %1 = shl <4 x i32> <i32 4, i32 4, i32 4, i32 4>, %a1
  %2 = udiv <4 x i32> %a0, %1
  ret <4 x i32> %2
}

define <4 x i32> @test_v4i32_shl_const_pow2(<4 x i32> %a0, <4 x i32> %a1) {
; CHECK-LABEL: @test_v4i32_shl_const_pow2(
; CHECK-NEXT:    [[TMP1:%.*]] = add <4 x i32> [[A1:%.*]], <i32 2, i32 3, i32 4, i32 5>
; CHECK-NEXT:    [[TMP2:%.*]] = lshr <4 x i32> [[A0:%.*]], [[TMP1]]
; CHECK-NEXT:    ret <4 x i32> [[TMP2]]
;
  %1 = shl <4 x i32> <i32 4, i32 8, i32 16, i32 32>, %a1
  %2 = udiv <4 x i32> %a0, %1
  ret <4 x i32> %2
}

; X udiv (zext (C1 << N)), where C1 is "1<<C2"  -->  X >> (N+C2)
define <4 x i32> @test_v4i32_zext_shl_splatconst_pow2(<4 x i32> %a0, <4 x i16> %a1) {
; CHECK-LABEL: @test_v4i32_zext_shl_splatconst_pow2(
; CHECK-NEXT:    [[TMP1:%.*]] = add <4 x i16> [[A1:%.*]], <i16 2, i16 2, i16 2, i16 2>
; CHECK-NEXT:    [[TMP2:%.*]] = zext <4 x i16> [[TMP1]] to <4 x i32>
; CHECK-NEXT:    [[TMP3:%.*]] = lshr <4 x i32> [[A0:%.*]], [[TMP2]]
; CHECK-NEXT:    ret <4 x i32> [[TMP3]]
;
  %1 = shl <4 x i16> <i16 4, i16 4, i16 4, i16 4>, %a1
  %2 = zext <4 x i16> %1 to <4 x i32>
  %3 = udiv <4 x i32> %a0, %2
  ret <4 x i32> %3
}

define <4 x i32> @test_v4i32_zext_shl_const_pow2(<4 x i32> %a0, <4 x i16> %a1) {
; CHECK-LABEL: @test_v4i32_zext_shl_const_pow2(
; CHECK-NEXT:    [[TMP1:%.*]] = add <4 x i16> [[A1:%.*]], <i16 2, i16 3, i16 4, i16 5>
; CHECK-NEXT:    [[TMP2:%.*]] = zext <4 x i16> [[TMP1]] to <4 x i32>
; CHECK-NEXT:    [[TMP3:%.*]] = lshr <4 x i32> [[A0:%.*]], [[TMP2]]
; CHECK-NEXT:    ret <4 x i32> [[TMP3]]
;
  %1 = shl <4 x i16> <i16 4, i16 8, i16 16, i16 32>, %a1
  %2 = zext <4 x i16> %1 to <4 x i32>
  %3 = udiv <4 x i32> %a0, %2
  ret <4 x i32> %3
}
