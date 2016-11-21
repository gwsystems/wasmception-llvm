; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -instcombine < %s | FileCheck %s

; This is the canonical form for a type-changing min/max.
define i64 @t1(i32 %a) {
; CHECK-LABEL: @t1(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp slt i32 %a, 5
; CHECK-NEXT:    [[TMP2:%.*]] = select i1 [[TMP1]], i32 %a, i32 5
; CHECK-NEXT:    [[TMP3:%.*]] = sext i32 [[TMP2]] to i64
; CHECK-NEXT:    ret i64 [[TMP3]]
;
  %1 = icmp slt i32 %a, 5
  %2 = select i1 %1, i32 %a, i32 5
  %3 = sext i32 %2 to i64
  ret i64 %3
}

; Check this is converted into canonical form, as above.
define i64 @t2(i32 %a) {
; CHECK-LABEL: @t2(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp slt i32 %a, 5
; CHECK-NEXT:    [[TMP2:%.*]] = select i1 [[TMP1]], i32 %a, i32 5
; CHECK-NEXT:    [[TMP3:%.*]] = sext i32 [[TMP2]] to i64
; CHECK-NEXT:    ret i64 [[TMP3]]
;
  %1 = icmp slt i32 %a, 5
  %2 = sext i32 %a to i64
  %3 = select i1 %1, i64 %2, i64 5
  ret i64 %3
}

; Same as @t2, with flipped operands and zext instead of sext.
define i64 @t3(i32 %a) {
; CHECK-LABEL: @t3(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ugt i32 %a, 5
; CHECK-NEXT:    [[TMP2:%.*]] = select i1 [[TMP1]], i32 %a, i32 5
; CHECK-NEXT:    [[TMP3:%.*]] = zext i32 [[TMP2]] to i64
; CHECK-NEXT:    ret i64 [[TMP3]]
;
  %1 = icmp ult i32 %a, 5
  %2 = zext i32 %a to i64
  %3 = select i1 %1, i64 5, i64 %2
  ret i64 %3
}

; Same again, with trunc.
define i32 @t4(i64 %a) {
; CHECK-LABEL: @t4(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp slt i64 %a, 5
; CHECK-NEXT:    [[TMP2:%.*]] = select i1 [[TMP1]], i64 %a, i64 5
; CHECK-NEXT:    [[TMP3:%.*]] = trunc i64 [[TMP2]] to i32
; CHECK-NEXT:    ret i32 [[TMP3]]
;
  %1 = icmp slt i64 %a, 5
  %2 = trunc i64 %a to i32
  %3 = select i1 %1, i32 %2, i32 5
  ret i32 %3
}

; Same as @t3, but with mismatched signedness between icmp and zext.
; InstCombine should leave this alone.
define i64 @t5(i32 %a) {
; CHECK-LABEL: @t5(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp slt i32 %a, 5
; CHECK-NEXT:    [[TMP2:%.*]] = zext i32 %a to i64
; CHECK-NEXT:    [[TMP3:%.*]] = select i1 [[TMP1]], i64 5, i64 [[TMP2]]
; CHECK-NEXT:    ret i64 [[TMP3]]
;
  %1 = icmp slt i32 %a, 5
  %2 = zext i32 %a to i64
  %3 = select i1 %1, i64 5, i64 %2
  ret i64 %3
}

define float @t6(i32 %a) {
; CHECK-LABEL: @t6(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp slt i32 %a, 0
; CHECK-NEXT:    [[TMP2:%.*]] = select i1 [[TMP1]], i32 %a, i32 0
; CHECK-NEXT:    [[TMP3:%.*]] = sitofp i32 [[TMP2]] to float
; CHECK-NEXT:    ret float [[TMP3]]
;
  %1 = icmp slt i32 %a, 0
  %2 = select i1 %1, i32 %a, i32 0
  %3 = sitofp i32 %2 to float
  ret float %3
}

define i16 @t7(i32 %a) {
; CHECK-LABEL: @t7(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp slt i32 %a, -32768
; CHECK-NEXT:    [[TMP2:%.*]] = select i1 [[TMP1]], i32 %a, i32 -32768
; CHECK-NEXT:    [[TMP3:%.*]] = trunc i32 [[TMP2]] to i16
; CHECK-NEXT:    ret i16 [[TMP3]]
;
  %1 = icmp slt i32 %a, -32768
  %2 = trunc i32 %a to i16
  %3 = select i1 %1, i16 %2, i16 -32768
  ret i16 %3
}

; Just check for no infinite loop. InstSimplify liked to
; "simplify" -32767 by removing all the sign bits,
; which led to a canonicalization fight between different
; parts of instcombine.
define i32 @t8(i64 %a, i32 %b) {
; CHECK-LABEL: @t8(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp slt i64 %a, -32767
; CHECK-NEXT:    [[TMP2:%.*]] = select i1 [[TMP1]], i64 %a, i64 -32767
; CHECK-NEXT:    [[TMP3:%.*]] = trunc i64 [[TMP2]] to i32
; CHECK-NEXT:    [[TMP4:%.*]] = icmp slt i32 %b, 42
; CHECK-NEXT:    [[TMP5:%.*]] = select i1 [[TMP4]], i32 42, i32 [[TMP3]]
; CHECK-NEXT:    [[TMP6:%.*]] = icmp ne i32 [[TMP5]], %b
; CHECK-NEXT:    [[TMP7:%.*]] = zext i1 [[TMP6]] to i32
; CHECK-NEXT:    ret i32 [[TMP7]]
;
  %1 = icmp slt i64 %a, -32767
  %2 = select i1 %1, i64 %a, i64 -32767
  %3 = trunc i64 %2 to i32
  %4 = icmp slt i32 %b, 42
  %5 = select i1 %4, i32 42, i32 %3
  %6 = icmp ne i32 %5, %b
  %7 = zext i1 %6 to i32
  ret i32 %7
}

; Ensure this doesn't get converted to a min/max.
define i64 @t9(i32 %a) {
; CHECK-LABEL: @t9(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp sgt i32 %a, -1
; CHECK-NEXT:    [[TMP2:%.*]] = sext i32 %a to i64
; CHECK-NEXT:    [[TMP3:%.*]] = select i1 [[TMP1]], i64 [[TMP2]], i64 4294967295
; CHECK-NEXT:    ret i64 [[TMP3]]
;
  %1 = icmp sgt i32 %a, -1
  %2 = sext i32 %a to i64
  %3 = select i1 %1, i64 %2, i64 4294967295
  ret i64 %3
}

; Reuse the first 2 bitcasts as the select operands.

define <4 x i32> @bitcasts_fcmp_1(<2 x i64> %a, <2 x i64> %b) {
; CHECK-LABEL: @bitcasts_fcmp_1(
; CHECK-NEXT:    [[T0:%.*]] = bitcast <2 x i64> %a to <4 x float>
; CHECK-NEXT:    [[T1:%.*]] = bitcast <2 x i64> %b to <4 x float>
; CHECK-NEXT:    [[T2:%.*]] = fcmp olt <4 x float> [[T1]], [[T0]]
; CHECK-NEXT:    [[TMP1:%.*]] = select <4 x i1> [[T2]], <4 x float> [[T0]], <4 x float> [[T1]]
; CHECK-NEXT:    [[T5:%.*]] = bitcast <4 x float> [[TMP1]] to <4 x i32>
; CHECK-NEXT:    ret <4 x i32> [[T5]]
;
  %t0 = bitcast <2 x i64> %a to <4 x float>
  %t1 = bitcast <2 x i64> %b to <4 x float>
  %t2 = fcmp olt <4 x float> %t1, %t0
  %t3 = bitcast <2 x i64> %a to <4 x i32>
  %t4 = bitcast <2 x i64> %b to <4 x i32>
  %t5 = select <4 x i1> %t2, <4 x i32> %t3, <4 x i32> %t4
  ret <4 x i32> %t5
}

; Switch cmp operand order.

define <4 x i32> @bitcasts_fcmp_2(<2 x i64> %a, <2 x i64> %b) {
; CHECK-LABEL: @bitcasts_fcmp_2(
; CHECK-NEXT:    [[T0:%.*]] = bitcast <2 x i64> %a to <4 x float>
; CHECK-NEXT:    [[T1:%.*]] = bitcast <2 x i64> %b to <4 x float>
; CHECK-NEXT:    [[T2:%.*]] = fcmp olt <4 x float> [[T0]], [[T1]]
; CHECK-NEXT:    [[TMP1:%.*]] = select <4 x i1> [[T2]], <4 x float> [[T0]], <4 x float> [[T1]]
; CHECK-NEXT:    [[T5:%.*]] = bitcast <4 x float> [[TMP1]] to <4 x i32>
; CHECK-NEXT:    ret <4 x i32> [[T5]]
;
  %t0 = bitcast <2 x i64> %a to <4 x float>
  %t1 = bitcast <2 x i64> %b to <4 x float>
  %t2 = fcmp olt <4 x float> %t0, %t1
  %t3 = bitcast <2 x i64> %a to <4 x i32>
  %t4 = bitcast <2 x i64> %b to <4 x i32>
  %t5 = select <4 x i1> %t2, <4 x i32> %t3, <4 x i32> %t4
  ret <4 x i32> %t5
}

; Integer cmp should have the same transforms.

define <4 x float> @bitcasts_icmp(<2 x i64> %a, <2 x i64> %b) {
; CHECK-LABEL: @bitcasts_icmp(
; CHECK-NEXT:    [[T0:%.*]] = bitcast <2 x i64> %a to <4 x i32>
; CHECK-NEXT:    [[T1:%.*]] = bitcast <2 x i64> %b to <4 x i32>
; CHECK-NEXT:    [[T2:%.*]] = icmp slt <4 x i32> [[T1]], [[T0]]
; CHECK-NEXT:    [[TMP1:%.*]] = select <4 x i1> [[T2]], <4 x i32> [[T0]], <4 x i32> [[T1]]
; CHECK-NEXT:    [[T5:%.*]] = bitcast <4 x i32> [[TMP1]] to <4 x float>
; CHECK-NEXT:    ret <4 x float> [[T5]]
;
  %t0 = bitcast <2 x i64> %a to <4 x i32>
  %t1 = bitcast <2 x i64> %b to <4 x i32>
  %t2 = icmp slt <4 x i32> %t1, %t0
  %t3 = bitcast <2 x i64> %a to <4 x float>
  %t4 = bitcast <2 x i64> %b to <4 x float>
  %t5 = select <4 x i1> %t2, <4 x float> %t3, <4 x float> %t4
  ret <4 x float> %t5
}

; SMIN(SMIN(X, 11), 92) -> SMIN(X, 11)
define i32 @test68(i32 %x) {
; CHECK-LABEL: @test68(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp slt i32 %x, 11
; CHECK-NEXT:    [[COND:%.*]] = select i1 [[TMP1]], i32 %x, i32 11
; CHECK-NEXT:    ret i32 [[COND]]
;
  %cmp = icmp slt i32 11, %x
  %cond = select i1 %cmp, i32 11, i32 %x
  %cmp3 = icmp slt i32 92, %cond
  %retval = select i1 %cmp3, i32 92, i32 %cond
  ret i32 %retval
}

define <2 x i32> @test68vec(<2 x i32> %x) {
; CHECK-LABEL: @test68vec(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp slt <2 x i32> %x, <i32 11, i32 11>
; CHECK-NEXT:    [[COND:%.*]] = select <2 x i1> [[TMP1]], <2 x i32> %x, <2 x i32> <i32 11, i32 11>
; CHECK-NEXT:    ret <2 x i32> [[COND]]
;
  %cmp = icmp slt <2 x i32> <i32 11, i32 11>, %x
  %cond = select <2 x i1> %cmp, <2 x i32> <i32 11, i32 11>, <2 x i32> %x
  %cmp3 = icmp slt <2 x i32> <i32 92, i32 92>, %cond
  %retval = select <2 x i1> %cmp3, <2 x i32> <i32 92, i32 92>, <2 x i32> %cond
  ret <2 x i32> %retval
}

; MIN(MIN(X, 24), 83) -> MIN(X, 24)
define i32 @test69(i32 %x) {
; CHECK-LABEL: @test69(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ult i32 %x, 24
; CHECK-NEXT:    [[COND:%.*]] = select i1 [[TMP1]], i32 %x, i32 24
; CHECK-NEXT:    ret i32 [[COND]]
;
  %cmp = icmp ult i32 24, %x
  %cond = select i1 %cmp, i32 24, i32 %x
  %cmp3 = icmp ult i32 83, %cond
  %retval = select i1 %cmp3, i32 83, i32 %cond
  ret i32 %retval
}

; SMAX(SMAX(X, 75), 36) -> SMAX(X, 75)
define i32 @test70(i32 %x) {
; CHECK-LABEL: @test70(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp sgt i32 %x, 75
; CHECK-NEXT:    [[COND:%.*]] = select i1 [[TMP1]], i32 %x, i32 75
; CHECK-NEXT:    ret i32 [[COND]]
;
  %cmp = icmp slt i32 %x, 75
  %cond = select i1 %cmp, i32 75, i32 %x
  %cmp3 = icmp slt i32 %cond, 36
  %retval = select i1 %cmp3, i32 36, i32 %cond
  ret i32 %retval
}

; MAX(MAX(X, 68), 47) -> MAX(X, 68)
define i32 @test71(i32 %x) {
; CHECK-LABEL: @test71(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ugt i32 %x, 68
; CHECK-NEXT:    [[COND:%.*]] = select i1 [[TMP1]], i32 %x, i32 68
; CHECK-NEXT:    ret i32 [[COND]]
;
  %cmp = icmp ult i32 %x, 68
  %cond = select i1 %cmp, i32 68, i32 %x
  %cmp3 = icmp ult i32 %cond, 47
  %retval = select i1 %cmp3, i32 47, i32 %cond
  ret i32 %retval
}

; SMIN(SMIN(X, 92), 11) -> SMIN(X, 11)
define i32 @test72(i32 %x) {
; CHECK-LABEL: @test72(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp slt i32 %x, 11
; CHECK-NEXT:    [[RETVAL:%.*]] = select i1 [[TMP1]], i32 %x, i32 11
; CHECK-NEXT:    ret i32 [[RETVAL]]
;
  %cmp = icmp sgt i32 %x, 92
  %cond = select i1 %cmp, i32 92, i32 %x
  %cmp3 = icmp sgt i32 %cond, 11
  %retval = select i1 %cmp3, i32 11, i32 %cond
  ret i32 %retval
}

; FIXME - vector neglect: FoldAndOfICmps() / FoldOrOfICmps()

define <2 x i32> @test72vec(<2 x i32> %x) {
; CHECK-LABEL: @test72vec(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp slt <2 x i32> %x, <i32 92, i32 92>
; CHECK-NEXT:    [[TMP2:%.*]] = icmp slt <2 x i32> %x, <i32 11, i32 11>
; CHECK-NEXT:    [[TMP3:%.*]] = and <2 x i1> [[TMP1]], [[TMP2]]
; CHECK-NEXT:    [[RETVAL:%.*]] = select <2 x i1> [[TMP3]], <2 x i32> %x, <2 x i32> <i32 11, i32 11>
; CHECK-NEXT:    ret <2 x i32> [[RETVAL]]
;
  %cmp = icmp sgt <2 x i32> %x, <i32 92, i32 92>
  %cond = select <2 x i1> %cmp, <2 x i32> <i32 92, i32 92>, <2 x i32> %x
  %cmp3 = icmp sgt <2 x i32> %cond, <i32 11, i32 11>
  %retval = select <2 x i1> %cmp3, <2 x i32> <i32 11, i32 11>, <2 x i32> %cond
  ret <2 x i32> %retval
}

; MIN(MIN(X, 83), 24) -> MIN(X, 24)
define i32 @test73(i32 %x) {
; CHECK-LABEL: @test73(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ult i32 %x, 24
; CHECK-NEXT:    [[RETVAL:%.*]] = select i1 [[TMP1]], i32 %x, i32 24
; CHECK-NEXT:    ret i32 [[RETVAL]]
;
  %cmp = icmp ugt i32 %x, 83
  %cond = select i1 %cmp, i32 83, i32 %x
  %cmp3 = icmp ugt i32 %cond, 24
  %retval = select i1 %cmp3, i32 24, i32 %cond
  ret i32 %retval
}

; SMAX(SMAX(X, 36), 75) -> SMAX(X, 75)
define i32 @test74(i32 %x) {
; CHECK-LABEL: @test74(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp sgt i32 %x, 75
; CHECK-NEXT:    [[RETVAL:%.*]] = select i1 [[TMP1]], i32 %x, i32 75
; CHECK-NEXT:    ret i32 [[RETVAL]]
;
  %cmp = icmp slt i32 %x, 36
  %cond = select i1 %cmp, i32 36, i32 %x
  %cmp3 = icmp slt i32 %cond, 75
  %retval = select i1 %cmp3, i32 75, i32 %cond
  ret i32 %retval
}

; MAX(MAX(X, 47), 68) -> MAX(X, 68)
define i32 @test75(i32 %x) {
; CHECK-LABEL: @test75(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ugt i32 %x, 68
; CHECK-NEXT:    [[RETVAL:%.*]] = select i1 [[TMP1]], i32 %x, i32 68
; CHECK-NEXT:    ret i32 [[RETVAL]]
;
  %cmp = icmp ult i32 %x, 47
  %cond = select i1 %cmp, i32 47, i32 %x
  %cmp3 = icmp ult i32 %cond, 68
  %retval = select i1 %cmp3, i32 68, i32 %cond
  ret i32 %retval
}

