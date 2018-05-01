; RUN: opt < %s -slp-vectorizer -instcombine -S | FileCheck %s

target datalayout = "e-m:e-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128"
target triple = "aarch64--linux-gnu"

define <2 x i64> @build_vec_v2i64(<2 x i64> %v0, <2 x i64> %v1) {
; CHECK-LABEL: @build_vec_v2i64(
; CHECK-NEXT:    [[V0_0:%.*]] = extractelement <2 x i64> %v0, i32 0
; CHECK-NEXT:    [[V0_1:%.*]] = extractelement <2 x i64> %v0, i32 1
; CHECK-NEXT:    [[V1_0:%.*]] = extractelement <2 x i64> %v1, i32 0
; CHECK-NEXT:    [[V1_1:%.*]] = extractelement <2 x i64> %v1, i32 1
; CHECK-NEXT:    [[TMP0_0:%.*]] = add i64 [[V0_0]], [[V1_0]]
; CHECK-NEXT:    [[TMP0_1:%.*]] = add i64 [[V0_1]], [[V1_1]]
; CHECK-NEXT:    [[TMP1_0:%.*]] = sub i64 [[V0_0]], [[V1_0]]
; CHECK-NEXT:    [[TMP1_1:%.*]] = sub i64 [[V0_1]], [[V1_1]]
; CHECK-NEXT:    [[TMP2_0:%.*]] = add i64 [[TMP0_0]], [[TMP0_1]]
; CHECK-NEXT:    [[TMP2_1:%.*]] = add i64 [[TMP1_0]], [[TMP1_1]]
; CHECK-NEXT:    [[TMP3_0:%.*]] = insertelement <2 x i64> undef, i64 [[TMP2_0]], i32 0
; CHECK-NEXT:    [[TMP3_1:%.*]] = insertelement <2 x i64> [[TMP3_0]], i64 [[TMP2_1]], i32 1
; CHECK-NEXT:    ret <2 x i64> [[TMP3_1]]
;
  %v0.0 = extractelement <2 x i64> %v0, i32 0
  %v0.1 = extractelement <2 x i64> %v0, i32 1
  %v1.0 = extractelement <2 x i64> %v1, i32 0
  %v1.1 = extractelement <2 x i64> %v1, i32 1
  %tmp0.0 = add i64 %v0.0, %v1.0
  %tmp0.1 = add i64 %v0.1, %v1.1
  %tmp1.0 = sub i64 %v0.0, %v1.0
  %tmp1.1 = sub i64 %v0.1, %v1.1
  %tmp2.0 = add i64 %tmp0.0, %tmp0.1
  %tmp2.1 = add i64 %tmp1.0, %tmp1.1
  %tmp3.0 = insertelement <2 x i64> undef, i64 %tmp2.0, i32 0
  %tmp3.1 = insertelement <2 x i64> %tmp3.0, i64 %tmp2.1, i32 1
  ret <2 x i64> %tmp3.1
}

define void @store_chain_v2i64(i64* %a, i64* %b, i64* %c) {
; CHECK-LABEL: @store_chain_v2i64(
; CHECK-NEXT:    [[A_1:%.*]] = getelementptr i64, i64* %a, i64 1
; CHECK-NEXT:    [[B_1:%.*]] = getelementptr i64, i64* %b, i64 1
; CHECK-NEXT:    [[C_1:%.*]] = getelementptr i64, i64* %c, i64 1
; CHECK-NEXT:    [[V0_0:%.*]] = load i64, i64* %a, align 8
; CHECK-NEXT:    [[V0_1:%.*]] = load i64, i64* [[A_1]], align 8
; CHECK-NEXT:    [[V1_0:%.*]] = load i64, i64* %b, align 8
; CHECK-NEXT:    [[V1_1:%.*]] = load i64, i64* [[B_1]], align 8
; CHECK-NEXT:    [[TMP0_0:%.*]] = add i64 [[V0_0]], [[V1_0]]
; CHECK-NEXT:    [[TMP0_1:%.*]] = add i64 [[V0_1]], [[V1_1]]
; CHECK-NEXT:    [[TMP1_0:%.*]] = sub i64 [[V0_0]], [[V1_0]]
; CHECK-NEXT:    [[TMP1_1:%.*]] = sub i64 [[V0_1]], [[V1_1]]
; CHECK-NEXT:    [[TMP2_0:%.*]] = add i64 [[TMP0_0]], [[TMP0_1]]
; CHECK-NEXT:    [[TMP2_1:%.*]] = add i64 [[TMP1_0]], [[TMP1_1]]
; CHECK-NEXT:    store i64 [[TMP2_0]], i64* %c, align 8
; CHECK-NEXT:    store i64 [[TMP2_1]], i64* [[C_1]], align 8
; CHECK-NEXT:    ret void
;
  %a.0 = getelementptr i64, i64* %a, i64 0
  %a.1 = getelementptr i64, i64* %a, i64 1
  %b.0 = getelementptr i64, i64* %b, i64 0
  %b.1 = getelementptr i64, i64* %b, i64 1
  %c.0 = getelementptr i64, i64* %c, i64 0
  %c.1 = getelementptr i64, i64* %c, i64 1
  %v0.0 = load i64, i64* %a.0, align 8
  %v0.1 = load i64, i64* %a.1, align 8
  %v1.0 = load i64, i64* %b.0, align 8
  %v1.1 = load i64, i64* %b.1, align 8
  %tmp0.0 = add i64 %v0.0, %v1.0
  %tmp0.1 = add i64 %v0.1, %v1.1
  %tmp1.0 = sub i64 %v0.0, %v1.0
  %tmp1.1 = sub i64 %v0.1, %v1.1
  %tmp2.0 = add i64 %tmp0.0, %tmp0.1
  %tmp2.1 = add i64 %tmp1.0, %tmp1.1
  store i64 %tmp2.0, i64* %c.0, align 8
  store i64 %tmp2.1, i64* %c.1, align 8
  ret void
}

define <4 x i32> @build_vec_v4i32(<4 x i32> %v0, <4 x i32> %v1) {
; CHECK-LABEL: @build_vec_v4i32(
; CHECK-NEXT:    [[V0_0:%.*]] = extractelement <4 x i32> %v0, i32 0
; CHECK-NEXT:    [[V0_1:%.*]] = extractelement <4 x i32> %v0, i32 1
; CHECK-NEXT:    [[V0_2:%.*]] = extractelement <4 x i32> %v0, i32 2
; CHECK-NEXT:    [[V0_3:%.*]] = extractelement <4 x i32> %v0, i32 3
; CHECK-NEXT:    [[V1_0:%.*]] = extractelement <4 x i32> %v1, i32 0
; CHECK-NEXT:    [[V1_1:%.*]] = extractelement <4 x i32> %v1, i32 1
; CHECK-NEXT:    [[V1_2:%.*]] = extractelement <4 x i32> %v1, i32 2
; CHECK-NEXT:    [[V1_3:%.*]] = extractelement <4 x i32> %v1, i32 3
; CHECK-NEXT:    [[TMP0_0:%.*]] = add i32 [[V0_0]], [[V1_0]]
; CHECK-NEXT:    [[TMP0_1:%.*]] = add i32 [[V0_1]], [[V1_1]]
; CHECK-NEXT:    [[TMP0_2:%.*]] = add i32 [[V0_2]], [[V1_2]]
; CHECK-NEXT:    [[TMP0_3:%.*]] = add i32 [[V0_3]], [[V1_3]]
; CHECK-NEXT:    [[TMP1_0:%.*]] = sub i32 [[V0_0]], [[V1_0]]
; CHECK-NEXT:    [[TMP1_1:%.*]] = sub i32 [[V0_1]], [[V1_1]]
; CHECK-NEXT:    [[TMP1_2:%.*]] = sub i32 [[V0_2]], [[V1_2]]
; CHECK-NEXT:    [[TMP1_3:%.*]] = sub i32 [[V0_3]], [[V1_3]]
; CHECK-NEXT:    [[TMP2_0:%.*]] = add i32 [[TMP0_0]], [[TMP0_1]]
; CHECK-NEXT:    [[TMP2_1:%.*]] = add i32 [[TMP1_0]], [[TMP1_1]]
; CHECK-NEXT:    [[TMP2_2:%.*]] = add i32 [[TMP0_2]], [[TMP0_3]]
; CHECK-NEXT:    [[TMP2_3:%.*]] = add i32 [[TMP1_2]], [[TMP1_3]]
; CHECK-NEXT:    [[TMP3_0:%.*]] = insertelement <4 x i32> undef, i32 [[TMP2_0]], i32 0
; CHECK-NEXT:    [[TMP3_1:%.*]] = insertelement <4 x i32> [[TMP3_0]], i32 [[TMP2_1]], i32 1
; CHECK-NEXT:    [[TMP3_2:%.*]] = insertelement <4 x i32> [[TMP3_1]], i32 [[TMP2_2]], i32 2
; CHECK-NEXT:    [[TMP3_3:%.*]] = insertelement <4 x i32> [[TMP3_2]], i32 [[TMP2_3]], i32 3
; CHECK-NEXT:    ret <4 x i32> [[TMP3_3]]
;
  %v0.0 = extractelement <4 x i32> %v0, i32 0
  %v0.1 = extractelement <4 x i32> %v0, i32 1
  %v0.2 = extractelement <4 x i32> %v0, i32 2
  %v0.3 = extractelement <4 x i32> %v0, i32 3
  %v1.0 = extractelement <4 x i32> %v1, i32 0
  %v1.1 = extractelement <4 x i32> %v1, i32 1
  %v1.2 = extractelement <4 x i32> %v1, i32 2
  %v1.3 = extractelement <4 x i32> %v1, i32 3
  %tmp0.0 = add i32 %v0.0, %v1.0
  %tmp0.1 = add i32 %v0.1, %v1.1
  %tmp0.2 = add i32 %v0.2, %v1.2
  %tmp0.3 = add i32 %v0.3, %v1.3
  %tmp1.0 = sub i32 %v0.0, %v1.0
  %tmp1.1 = sub i32 %v0.1, %v1.1
  %tmp1.2 = sub i32 %v0.2, %v1.2
  %tmp1.3 = sub i32 %v0.3, %v1.3
  %tmp2.0 = add i32 %tmp0.0, %tmp0.1
  %tmp2.1 = add i32 %tmp1.0, %tmp1.1
  %tmp2.2 = add i32 %tmp0.2, %tmp0.3
  %tmp2.3 = add i32 %tmp1.2, %tmp1.3
  %tmp3.0 = insertelement <4 x i32> undef, i32 %tmp2.0, i32 0
  %tmp3.1 = insertelement <4 x i32> %tmp3.0, i32 %tmp2.1, i32 1
  %tmp3.2 = insertelement <4 x i32> %tmp3.1, i32 %tmp2.2, i32 2
  %tmp3.3 = insertelement <4 x i32> %tmp3.2, i32 %tmp2.3, i32 3
  ret <4 x i32> %tmp3.3
}

define <4 x i32> @build_vec_v4i32_reuse_0(<2 x i32> %v0, <2 x i32> %v1) {
; CHECK-LABEL: @build_vec_v4i32_reuse_0(
; CHECK-NEXT:    [[V0_0:%.*]] = extractelement <2 x i32> %v0, i32 0
; CHECK-NEXT:    [[V0_1:%.*]] = extractelement <2 x i32> %v0, i32 1
; CHECK-NEXT:    [[V1_0:%.*]] = extractelement <2 x i32> %v1, i32 0
; CHECK-NEXT:    [[V1_1:%.*]] = extractelement <2 x i32> %v1, i32 1
; CHECK-NEXT:    [[TMP0_0:%.*]] = add i32 [[V0_0]], [[V1_0]]
; CHECK-NEXT:    [[TMP0_1:%.*]] = add i32 [[V0_1]], [[V1_1]]
; CHECK-NEXT:    [[TMP1_0:%.*]] = sub i32 [[V0_0]], [[V1_0]]
; CHECK-NEXT:    [[TMP1_1:%.*]] = sub i32 [[V0_1]], [[V1_1]]
; CHECK-NEXT:    [[TMP2_0:%.*]] = add i32 [[TMP0_0]], [[TMP0_1]]
; CHECK-NEXT:    [[TMP2_1:%.*]] = add i32 [[TMP1_0]], [[TMP1_1]]
; CHECK-NEXT:    [[TMP3_0:%.*]] = insertelement <4 x i32> undef, i32 [[TMP2_0]], i32 0
; CHECK-NEXT:    [[TMP3_1:%.*]] = insertelement <4 x i32> [[TMP3_0]], i32 [[TMP2_1]], i32 1
; CHECK-NEXT:    [[TMP3_2:%.*]] = insertelement <4 x i32> [[TMP3_1]], i32 [[TMP2_0]], i32 2
; CHECK-NEXT:    [[TMP3_3:%.*]] = insertelement <4 x i32> [[TMP3_2]], i32 [[TMP2_1]], i32 3
; CHECK-NEXT:    ret <4 x i32> [[TMP3_3]]
;
  %v0.0 = extractelement <2 x i32> %v0, i32 0
  %v0.1 = extractelement <2 x i32> %v0, i32 1
  %v1.0 = extractelement <2 x i32> %v1, i32 0
  %v1.1 = extractelement <2 x i32> %v1, i32 1
  %tmp0.0 = add i32 %v0.0, %v1.0
  %tmp0.1 = add i32 %v0.1, %v1.1
  %tmp1.0 = sub i32 %v0.0, %v1.0
  %tmp1.1 = sub i32 %v0.1, %v1.1
  %tmp2.0 = add i32 %tmp0.0, %tmp0.1
  %tmp2.1 = add i32 %tmp1.0, %tmp1.1
  %tmp3.0 = insertelement <4 x i32> undef, i32 %tmp2.0, i32 0
  %tmp3.1 = insertelement <4 x i32> %tmp3.0, i32 %tmp2.1, i32 1
  %tmp3.2 = insertelement <4 x i32> %tmp3.1, i32 %tmp2.0, i32 2
  %tmp3.3 = insertelement <4 x i32> %tmp3.2, i32 %tmp2.1, i32 3
  ret <4 x i32> %tmp3.3
}

define <4 x i32> @build_vec_v4i32_reuse_1(<2 x i32> %v0, <2 x i32> %v1) {
; CHECK-LABEL: @build_vec_v4i32_reuse_1(
; CHECK-NEXT:    [[V0_0:%.*]] = extractelement <2 x i32> %v0, i32 0
; CHECK-NEXT:    [[V0_1:%.*]] = extractelement <2 x i32> %v0, i32 1
; CHECK-NEXT:    [[V1_0:%.*]] = extractelement <2 x i32> %v1, i32 0
; CHECK-NEXT:    [[V1_1:%.*]] = extractelement <2 x i32> %v1, i32 1
; CHECK-NEXT:    [[TMP0_0:%.*]] = add i32 [[V0_0]], [[V1_0]]
; CHECK-NEXT:    [[TMP0_1:%.*]] = add i32 [[V0_1]], [[V1_1]]
; CHECK-NEXT:    [[TMP0_2:%.*]] = xor i32 [[V0_0]], [[V1_0]]
; CHECK-NEXT:    [[TMP0_3:%.*]] = xor i32 [[V0_1]], [[V1_1]]
; CHECK-NEXT:    [[TMP1:%.*]] = insertelement <2 x i32> undef, i32 [[TMP0_0]], i32 0
; CHECK-NEXT:    [[TMP2:%.*]] = insertelement <2 x i32> undef, i32 [[TMP0_1]], i32 0
; CHECK-NEXT:    [[TMP3:%.*]] = sub <2 x i32> [[TMP1]], [[TMP2]]
; CHECK-NEXT:    [[TMP1_2:%.*]] = sub i32 [[TMP0_2]], [[TMP0_3]]
; CHECK-NEXT:    [[TMP1_3:%.*]] = sub i32 [[TMP0_3]], [[TMP0_2]]
; CHECK-NEXT:    [[TMP4:%.*]] = extractelement <2 x i32> [[TMP3]], i32 0
; CHECK-NEXT:    [[TMP2_0:%.*]] = insertelement <4 x i32> undef, i32 [[TMP4]], i32 0
; CHECK-NEXT:    [[TMP5:%.*]] = extractelement <2 x i32> [[TMP3]], i32 0
; CHECK-NEXT:    [[TMP2_1:%.*]] = insertelement <4 x i32> [[TMP2_0]], i32 [[TMP5]], i32 1
; CHECK-NEXT:    [[TMP2_2:%.*]] = insertelement <4 x i32> [[TMP2_1]], i32 [[TMP1_2]], i32 2
; CHECK-NEXT:    [[TMP2_3:%.*]] = insertelement <4 x i32> [[TMP2_2]], i32 [[TMP1_3]], i32 3
; CHECK-NEXT:    ret <4 x i32> [[TMP2_3]]
;
  %v0.0 = extractelement <2 x i32> %v0, i32 0
  %v0.1 = extractelement <2 x i32> %v0, i32 1
  %v1.0 = extractelement <2 x i32> %v1, i32 0
  %v1.1 = extractelement <2 x i32> %v1, i32 1
  %tmp0.0 = add i32 %v0.0, %v1.0
  %tmp0.1 = add i32 %v0.1, %v1.1
  %tmp0.2 = xor i32 %v0.0, %v1.0
  %tmp0.3 = xor i32 %v0.1, %v1.1
  %tmp1.0 = sub i32 %tmp0.0, %tmp0.1
  %tmp1.1 = sub i32 %tmp0.0, %tmp0.1
  %tmp1.2 = sub i32 %tmp0.2, %tmp0.3
  %tmp1.3 = sub i32 %tmp0.3, %tmp0.2
  %tmp2.0 = insertelement <4 x i32> undef, i32 %tmp1.0, i32 0
  %tmp2.1 = insertelement <4 x i32> %tmp2.0, i32 %tmp1.1, i32 1
  %tmp2.2 = insertelement <4 x i32> %tmp2.1, i32 %tmp1.2, i32 2
  %tmp2.3 = insertelement <4 x i32> %tmp2.2, i32 %tmp1.3, i32 3
  ret <4 x i32> %tmp2.3
}

define <4 x i32> @build_vec_v4i32_3_binops(<2 x i32> %v0, <2 x i32> %v1) {
; CHECK-LABEL: @build_vec_v4i32_3_binops(
; CHECK-NEXT:    [[V0_0:%.*]] = extractelement <2 x i32> %v0, i32 0
; CHECK-NEXT:    [[V0_1:%.*]] = extractelement <2 x i32> %v0, i32 1
; CHECK-NEXT:    [[V1_0:%.*]] = extractelement <2 x i32> %v1, i32 0
; CHECK-NEXT:    [[V1_1:%.*]] = extractelement <2 x i32> %v1, i32 1
; CHECK-NEXT:    [[TMP0_0:%.*]] = add i32 [[V0_0]], [[V1_0]]
; CHECK-NEXT:    [[TMP0_1:%.*]] = add i32 [[V0_1]], [[V1_1]]
; CHECK-NEXT:    [[TMP1_0:%.*]] = mul i32 [[V0_0]], [[V1_0]]
; CHECK-NEXT:    [[TMP1_1:%.*]] = mul i32 [[V0_1]], [[V1_1]]
; CHECK-NEXT:    [[TMP1:%.*]] = xor <2 x i32> %v0, %v1
; CHECK-NEXT:    [[TMP2:%.*]] = shufflevector <2 x i32> [[TMP1]], <2 x i32> undef, <2 x i32> zeroinitializer
; CHECK-NEXT:    [[TMP3:%.*]] = xor <2 x i32> %v0, %v1
; CHECK-NEXT:    [[TMP4:%.*]] = shufflevector <2 x i32> [[TMP3]], <2 x i32> undef, <2 x i32> <i32 1, i32 1>
; CHECK-NEXT:    [[TMP5:%.*]] = insertelement <2 x i32> undef, i32 [[TMP0_0]], i32 0
; CHECK-NEXT:    [[TMP6:%.*]] = insertelement <2 x i32> [[TMP5]], i32 [[TMP1_0]], i32 1
; CHECK-NEXT:    [[TMP7:%.*]] = insertelement <2 x i32> undef, i32 [[TMP0_1]], i32 0
; CHECK-NEXT:    [[TMP8:%.*]] = insertelement <2 x i32> [[TMP7]], i32 [[TMP1_1]], i32 1
; CHECK-NEXT:    [[TMP9:%.*]] = add <2 x i32> [[TMP6]], [[TMP8]]
; CHECK-NEXT:    [[TMP10:%.*]] = add <2 x i32> [[TMP2]], [[TMP4]]
; CHECK-NEXT:    [[TMP3_3:%.*]] = shufflevector <2 x i32> [[TMP9]], <2 x i32> [[TMP10]], <4 x i32> <i32 0, i32 1, i32 2, i32 3>
; CHECK-NEXT:    ret <4 x i32> [[TMP3_3]]
;
  %v0.0 = extractelement <2 x i32> %v0, i32 0
  %v0.1 = extractelement <2 x i32> %v0, i32 1
  %v1.0 = extractelement <2 x i32> %v1, i32 0
  %v1.1 = extractelement <2 x i32> %v1, i32 1
  %tmp0.0 = add i32 %v0.0, %v1.0
  %tmp0.1 = add i32 %v0.1, %v1.1
  %tmp0.2 = xor i32 %v0.0, %v1.0
  %tmp0.3 = xor i32 %v0.1, %v1.1
  %tmp1.0 = mul i32 %v0.0, %v1.0
  %tmp1.1 = mul i32 %v0.1, %v1.1
  %tmp1.2 = xor i32 %v0.0, %v1.0
  %tmp1.3 = xor i32 %v0.1, %v1.1
  %tmp2.0 = add i32 %tmp0.0, %tmp0.1
  %tmp2.1 = add i32 %tmp1.0, %tmp1.1
  %tmp2.2 = add i32 %tmp0.2, %tmp0.3
  %tmp2.3 = add i32 %tmp1.2, %tmp1.3
  %tmp3.0 = insertelement <4 x i32> undef, i32 %tmp2.0, i32 0
  %tmp3.1 = insertelement <4 x i32> %tmp3.0, i32 %tmp2.1, i32 1
  %tmp3.2 = insertelement <4 x i32> %tmp3.1, i32 %tmp2.2, i32 2
  %tmp3.3 = insertelement <4 x i32> %tmp3.2, i32 %tmp2.3, i32 3
  ret <4 x i32> %tmp3.3
}

define i32 @reduction_v4i32(<4 x i32> %v0, <4 x i32> %v1) {
; CHECK-LABEL: @reduction_v4i32(
; CHECK-NEXT:    [[V0_0:%.*]] = extractelement <4 x i32> %v0, i32 0
; CHECK-NEXT:    [[V0_1:%.*]] = extractelement <4 x i32> %v0, i32 1
; CHECK-NEXT:    [[V0_2:%.*]] = extractelement <4 x i32> %v0, i32 2
; CHECK-NEXT:    [[V0_3:%.*]] = extractelement <4 x i32> %v0, i32 3
; CHECK-NEXT:    [[V1_0:%.*]] = extractelement <4 x i32> %v1, i32 0
; CHECK-NEXT:    [[V1_1:%.*]] = extractelement <4 x i32> %v1, i32 1
; CHECK-NEXT:    [[V1_2:%.*]] = extractelement <4 x i32> %v1, i32 2
; CHECK-NEXT:    [[V1_3:%.*]] = extractelement <4 x i32> %v1, i32 3
; CHECK-NEXT:    [[TMP0_0:%.*]] = add i32 [[V0_0]], [[V1_0]]
; CHECK-NEXT:    [[TMP0_1:%.*]] = add i32 [[V0_1]], [[V1_1]]
; CHECK-NEXT:    [[TMP0_2:%.*]] = add i32 [[V0_2]], [[V1_2]]
; CHECK-NEXT:    [[TMP0_3:%.*]] = add i32 [[V0_3]], [[V1_3]]
; CHECK-NEXT:    [[TMP1_0:%.*]] = sub i32 [[V0_0]], [[V1_0]]
; CHECK-NEXT:    [[TMP1_1:%.*]] = sub i32 [[V0_1]], [[V1_1]]
; CHECK-NEXT:    [[TMP1_2:%.*]] = sub i32 [[V0_2]], [[V1_2]]
; CHECK-NEXT:    [[TMP1_3:%.*]] = sub i32 [[V0_3]], [[V1_3]]
; CHECK-NEXT:    [[TMP1:%.*]] = insertelement <4 x i32> undef, i32 [[TMP1_0]], i32 0
; CHECK-NEXT:    [[TMP2:%.*]] = insertelement <4 x i32> [[TMP1]], i32 [[TMP0_0]], i32 1
; CHECK-NEXT:    [[TMP3:%.*]] = insertelement <4 x i32> [[TMP2]], i32 [[TMP0_2]], i32 2
; CHECK-NEXT:    [[TMP4:%.*]] = insertelement <4 x i32> [[TMP3]], i32 [[TMP1_2]], i32 3
; CHECK-NEXT:    [[TMP5:%.*]] = insertelement <4 x i32> undef, i32 [[TMP1_1]], i32 0
; CHECK-NEXT:    [[TMP6:%.*]] = insertelement <4 x i32> [[TMP5]], i32 [[TMP0_1]], i32 1
; CHECK-NEXT:    [[TMP7:%.*]] = insertelement <4 x i32> [[TMP6]], i32 [[TMP0_3]], i32 2
; CHECK-NEXT:    [[TMP8:%.*]] = insertelement <4 x i32> [[TMP7]], i32 [[TMP1_3]], i32 3
; CHECK-NEXT:    [[TMP9:%.*]] = add <4 x i32> [[TMP4]], [[TMP8]]
; CHECK-NEXT:    [[TMP10:%.*]] = lshr <4 x i32> [[TMP9]], <i32 15, i32 15, i32 15, i32 15>
; CHECK-NEXT:    [[TMP11:%.*]] = and <4 x i32> [[TMP10]], <i32 65537, i32 65537, i32 65537, i32 65537>
; CHECK-NEXT:    [[TMP12:%.*]] = mul nuw <4 x i32> [[TMP11]], <i32 65535, i32 65535, i32 65535, i32 65535>
; CHECK-NEXT:    [[TMP13:%.*]] = add <4 x i32> [[TMP12]], [[TMP9]]
; CHECK-NEXT:    [[TMP14:%.*]] = xor <4 x i32> [[TMP13]], [[TMP12]]
; CHECK-NEXT:    [[TMP15:%.*]] = call i32 @llvm.experimental.vector.reduce.add.i32.v4i32(<4 x i32> [[TMP14]])
; CHECK-NEXT:    ret i32 [[TMP15]]
;
  %v0.0 = extractelement <4 x i32> %v0, i32 0
  %v0.1 = extractelement <4 x i32> %v0, i32 1
  %v0.2 = extractelement <4 x i32> %v0, i32 2
  %v0.3 = extractelement <4 x i32> %v0, i32 3
  %v1.0 = extractelement <4 x i32> %v1, i32 0
  %v1.1 = extractelement <4 x i32> %v1, i32 1
  %v1.2 = extractelement <4 x i32> %v1, i32 2
  %v1.3 = extractelement <4 x i32> %v1, i32 3
  %tmp0.0 = add i32 %v0.0, %v1.0
  %tmp0.1 = add i32 %v0.1, %v1.1
  %tmp0.2 = add i32 %v0.2, %v1.2
  %tmp0.3 = add i32 %v0.3, %v1.3
  %tmp1.0 = sub i32 %v0.0, %v1.0
  %tmp1.1 = sub i32 %v0.1, %v1.1
  %tmp1.2 = sub i32 %v0.2, %v1.2
  %tmp1.3 = sub i32 %v0.3, %v1.3
  %tmp2.0 = add i32 %tmp0.0, %tmp0.1
  %tmp2.1 = add i32 %tmp1.0, %tmp1.1
  %tmp2.2 = add i32 %tmp0.2, %tmp0.3
  %tmp2.3 = add i32 %tmp1.2, %tmp1.3
  %tmp3.0 = lshr i32 %tmp2.0, 15
  %tmp3.1 = lshr i32 %tmp2.1, 15
  %tmp3.2 = lshr i32 %tmp2.2, 15
  %tmp3.3 = lshr i32 %tmp2.3, 15
  %tmp4.0 = and i32 %tmp3.0, 65537
  %tmp4.1 = and i32 %tmp3.1, 65537
  %tmp4.2 = and i32 %tmp3.2, 65537
  %tmp4.3 = and i32 %tmp3.3, 65537
  %tmp5.0 = mul nuw i32 %tmp4.0, 65535
  %tmp5.1 = mul nuw i32 %tmp4.1, 65535
  %tmp5.2 = mul nuw i32 %tmp4.2, 65535
  %tmp5.3 = mul nuw i32 %tmp4.3, 65535
  %tmp6.0 = add i32 %tmp5.0, %tmp2.0
  %tmp6.1 = add i32 %tmp5.1, %tmp2.1
  %tmp6.2 = add i32 %tmp5.2, %tmp2.2
  %tmp6.3 = add i32 %tmp5.3, %tmp2.3
  %tmp7.0 = xor i32 %tmp6.0, %tmp5.0
  %tmp7.1 = xor i32 %tmp6.1, %tmp5.1
  %tmp7.2 = xor i32 %tmp6.2, %tmp5.2
  %tmp7.3 = xor i32 %tmp6.3, %tmp5.3
  %reduce.0 = add i32 %tmp7.1, %tmp7.0
  %reduce.1 = add i32 %reduce.0, %tmp7.2
  %reduce.2 = add i32 %reduce.1, %tmp7.3
  ret i32 %reduce.2
}
