; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -instsimplify -S | FileCheck %s

; add nsw (xor X, signbit), signbit --> X

define <2 x i32> @add_nsw_signbit(<2 x i32> %x) {
; CHECK-LABEL: @add_nsw_signbit(
; CHECK-NEXT:    ret <2 x i32> %x
;
  %y = xor <2 x i32> %x, <i32 -2147483648, i32 -2147483648>
  %z = add nsw <2 x i32> %y, <i32 -2147483648, i32 -2147483648>
  ret <2 x i32> %z
}

; add nuw (xor X, signbit), signbit --> X

define <2 x i5> @add_nuw_signbit(<2 x i5> %x) {
; CHECK-LABEL: @add_nuw_signbit(
; CHECK-NEXT:    ret <2 x i5> %x
;
  %y = xor <2 x i5> %x, <i5 -16, i5 -16>
  %z = add nuw <2 x i5> %y, <i5 -16, i5 -16>
  ret <2 x i5> %z
}

define i64 @pow2(i32 %x) {
; CHECK-LABEL: @pow2(
; CHECK-NEXT:    [[NEGX:%.*]] = sub i32 0, %x
; CHECK-NEXT:    [[X2:%.*]] = and i32 %x, [[NEGX]]
; CHECK-NEXT:    [[E:%.*]] = zext i32 [[X2]] to i64
; CHECK-NEXT:    ret i64 [[E]]
;
  %negx = sub i32 0, %x
  %x2 = and i32 %x, %negx
  %e = zext i32 %x2 to i64
  %nege = sub i64 0, %e
  %e2 = and i64 %e, %nege
  ret i64 %e2
}

define i64 @pow2b(i32 %x) {
; CHECK-LABEL: @pow2b(
; CHECK-NEXT:    [[SH:%.*]] = shl i32 2, %x
; CHECK-NEXT:    [[E:%.*]] = zext i32 [[SH]] to i64
; CHECK-NEXT:    ret i64 [[E]]
;
  %sh = shl i32 2, %x
  %e = zext i32 %sh to i64
  %nege = sub i64 0, %e
  %e2 = and i64 %e, %nege
  ret i64 %e2
}

define i1 @and_of_icmps0(i32 %b) {
; CHECK-LABEL: @and_of_icmps0(
; CHECK-NEXT:    ret i1 false
;
  %1 = add i32 %b, 2
  %2 = icmp ult i32 %1, 4
  %cmp3 = icmp sgt i32 %b, 2
  %cmp = and i1 %2, %cmp3
  ret i1 %cmp
}

define <2 x i1> @and_of_icmps0_vec(<2 x i32> %b) {
; CHECK-LABEL: @and_of_icmps0_vec(
; CHECK-NEXT:    ret <2 x i1> zeroinitializer
;
  %1 = add <2 x i32> %b, <i32 2, i32 2>
  %2 = icmp ult <2 x i32> %1, <i32 4, i32 4>
  %cmp3 = icmp sgt <2 x i32> %b, <i32 2, i32 2>
  %cmp = and <2 x i1> %2, %cmp3
  ret <2 x i1> %cmp
}

define i1 @and_of_icmps1(i32 %b) {
; CHECK-LABEL: @and_of_icmps1(
; CHECK-NEXT:    ret i1 false
;
  %1 = add nsw i32 %b, 2
  %2 = icmp slt i32 %1, 4
  %cmp3 = icmp sgt i32 %b, 2
  %cmp = and i1 %2, %cmp3
  ret i1 %cmp
}

define <2 x i1> @and_of_icmps1_vec(<2 x i32> %b) {
; CHECK-LABEL: @and_of_icmps1_vec(
; CHECK-NEXT:    ret <2 x i1> zeroinitializer
;
  %1 = add nsw <2 x i32> %b, <i32 2, i32 2>
  %2 = icmp slt <2 x i32> %1, <i32 4, i32 4>
  %cmp3 = icmp sgt <2 x i32> %b, <i32 2, i32 2>
  %cmp = and <2 x i1> %2, %cmp3
  ret <2 x i1> %cmp
}

define i1 @and_of_icmps2(i32 %b) {
; CHECK-LABEL: @and_of_icmps2(
; CHECK-NEXT:    ret i1 false
;
  %1 = add i32 %b, 2
  %2 = icmp ule i32 %1, 3
  %cmp3 = icmp sgt i32 %b, 2
  %cmp = and i1 %2, %cmp3
  ret i1 %cmp
}

define <2 x i1> @and_of_icmps2_vec(<2 x i32> %b) {
; CHECK-LABEL: @and_of_icmps2_vec(
; CHECK-NEXT:    ret <2 x i1> zeroinitializer
;
  %1 = add <2 x i32> %b, <i32 2, i32 2>
  %2 = icmp ule <2 x i32> %1, <i32 3, i32 3>
  %cmp3 = icmp sgt <2 x i32> %b, <i32 2, i32 2>
  %cmp = and <2 x i1> %2, %cmp3
  ret <2 x i1> %cmp
}

define i1 @and_of_icmps3(i32 %b) {
; CHECK-LABEL: @and_of_icmps3(
; CHECK-NEXT:    ret i1 false
;
  %1 = add nsw i32 %b, 2
  %2 = icmp sle i32 %1, 3
  %cmp3 = icmp sgt i32 %b, 2
  %cmp = and i1 %2, %cmp3
  ret i1 %cmp
}

define <2 x i1> @and_of_icmps3_vec(<2 x i32> %b) {
; CHECK-LABEL: @and_of_icmps3_vec(
; CHECK-NEXT:    ret <2 x i1> zeroinitializer
;
  %1 = add nsw <2 x i32> %b, <i32 2, i32 2>
  %2 = icmp sle <2 x i32> %1, <i32 3, i32 3>
  %cmp3 = icmp sgt <2 x i32> %b, <i32 2, i32 2>
  %cmp = and <2 x i1> %2, %cmp3
  ret <2 x i1> %cmp
}

define i1 @and_of_icmps4(i32 %b) {
; CHECK-LABEL: @and_of_icmps4(
; CHECK-NEXT:    ret i1 false
;
  %1 = add nuw i32 %b, 2
  %2 = icmp ult i32 %1, 4
  %cmp3 = icmp ugt i32 %b, 2
  %cmp = and i1 %2, %cmp3
  ret i1 %cmp
}

define <2 x i1> @and_of_icmps4_vec(<2 x i32> %b) {
; CHECK-LABEL: @and_of_icmps4_vec(
; CHECK-NEXT:    ret <2 x i1> zeroinitializer
;
  %1 = add nuw <2 x i32> %b, <i32 2, i32 2>
  %2 = icmp ult <2 x i32> %1, <i32 4, i32 4>
  %cmp3 = icmp ugt <2 x i32> %b, <i32 2, i32 2>
  %cmp = and <2 x i1> %2, %cmp3
  ret <2 x i1> %cmp
}

define i1 @and_of_icmps5(i32 %b) {
; CHECK-LABEL: @and_of_icmps5(
; CHECK-NEXT:    ret i1 false
;
  %1 = add nuw i32 %b, 2
  %2 = icmp ule i32 %1, 3
  %cmp3 = icmp ugt i32 %b, 2
  %cmp = and i1 %2, %cmp3
  ret i1 %cmp
}

define <2 x i1> @and_of_icmps5_vec(<2 x i32> %b) {
; CHECK-LABEL: @and_of_icmps5_vec(
; CHECK-NEXT:    ret <2 x i1> zeroinitializer
;
  %1 = add nuw <2 x i32> %b, <i32 2, i32 2>
  %2 = icmp ule <2 x i32> %1, <i32 3, i32 3>
  %cmp3 = icmp ugt <2 x i32> %b, <i32 2, i32 2>
  %cmp = and <2 x i1> %2, %cmp3
  ret <2 x i1> %cmp
}

define i1 @or_of_icmps0(i32 %b) {
; CHECK-LABEL: @or_of_icmps0(
; CHECK-NEXT:    ret i1 true
;
  %1 = add i32 %b, 2
  %2 = icmp uge i32 %1, 4
  %cmp3 = icmp sle i32 %b, 2
  %cmp = or i1 %2, %cmp3
  ret i1 %cmp
}

define <2 x i1> @or_of_icmps0_vec(<2 x i32> %b) {
; CHECK-LABEL: @or_of_icmps0_vec(
; CHECK-NEXT:    ret <2 x i1> <i1 true, i1 true>
;
  %1 = add <2 x i32> %b, <i32 2, i32 2>
  %2 = icmp uge <2 x i32> %1, <i32 4, i32 4>
  %cmp3 = icmp sle <2 x i32> %b, <i32 2, i32 2>
  %cmp = or <2 x i1> %2, %cmp3
  ret <2 x i1> %cmp
}

define i1 @or_of_icmps1(i32 %b) {
; CHECK-LABEL: @or_of_icmps1(
; CHECK-NEXT:    ret i1 true
;
  %1 = add nsw i32 %b, 2
  %2 = icmp sge i32 %1, 4
  %cmp3 = icmp sle i32 %b, 2
  %cmp = or i1 %2, %cmp3
  ret i1 %cmp
}

define <2 x i1> @or_of_icmps1_vec(<2 x i32> %b) {
; CHECK-LABEL: @or_of_icmps1_vec(
; CHECK-NEXT:    ret <2 x i1> <i1 true, i1 true>
;
  %1 = add nsw <2 x i32> %b, <i32 2, i32 2>
  %2 = icmp sge <2 x i32> %1, <i32 4, i32 4>
  %cmp3 = icmp sle <2 x i32> %b, <i32 2, i32 2>
  %cmp = or <2 x i1> %2, %cmp3
  ret <2 x i1> %cmp
}

define i1 @or_of_icmps2(i32 %b) {
; CHECK-LABEL: @or_of_icmps2(
; CHECK-NEXT:    ret i1 true
;
  %1 = add i32 %b, 2
  %2 = icmp ugt i32 %1, 3
  %cmp3 = icmp sle i32 %b, 2
  %cmp = or i1 %2, %cmp3
  ret i1 %cmp
}

define <2 x i1> @or_of_icmps2_vec(<2 x i32> %b) {
; CHECK-LABEL: @or_of_icmps2_vec(
; CHECK-NEXT:    ret <2 x i1> <i1 true, i1 true>
;
  %1 = add <2 x i32> %b, <i32 2, i32 2>
  %2 = icmp ugt <2 x i32> %1, <i32 3, i32 3>
  %cmp3 = icmp sle <2 x i32> %b, <i32 2, i32 2>
  %cmp = or <2 x i1> %2, %cmp3
  ret <2 x i1> %cmp
}

define i1 @or_of_icmps3(i32 %b) {
; CHECK-LABEL: @or_of_icmps3(
; CHECK-NEXT:    ret i1 true
;
  %1 = add nsw i32 %b, 2
  %2 = icmp sgt i32 %1, 3
  %cmp3 = icmp sle i32 %b, 2
  %cmp = or i1 %2, %cmp3
  ret i1 %cmp
}

define <2 x i1> @or_of_icmps3_vec(<2 x i32> %b) {
; CHECK-LABEL: @or_of_icmps3_vec(
; CHECK-NEXT:    ret <2 x i1> <i1 true, i1 true>
;
  %1 = add nsw <2 x i32> %b, <i32 2, i32 2>
  %2 = icmp sgt <2 x i32> %1, <i32 3, i32 3>
  %cmp3 = icmp sle <2 x i32> %b, <i32 2, i32 2>
  %cmp = or <2 x i1> %2, %cmp3
  ret <2 x i1> %cmp
}

define i1 @or_of_icmps4(i32 %b) {
; CHECK-LABEL: @or_of_icmps4(
; CHECK-NEXT:    ret i1 true
;
  %1 = add nuw i32 %b, 2
  %2 = icmp uge i32 %1, 4
  %cmp3 = icmp ule i32 %b, 2
  %cmp = or i1 %2, %cmp3
  ret i1 %cmp
}

define <2 x i1> @or_of_icmps4_vec(<2 x i32> %b) {
; CHECK-LABEL: @or_of_icmps4_vec(
; CHECK-NEXT:    ret <2 x i1> <i1 true, i1 true>
;
  %1 = add nuw <2 x i32> %b, <i32 2, i32 2>
  %2 = icmp uge <2 x i32> %1, <i32 4, i32 4>
  %cmp3 = icmp ule <2 x i32> %b, <i32 2, i32 2>
  %cmp = or <2 x i1> %2, %cmp3
  ret <2 x i1> %cmp
}

define i1 @or_of_icmps5(i32 %b) {
; CHECK-LABEL: @or_of_icmps5(
; CHECK-NEXT:    ret i1 true
;
  %1 = add nuw i32 %b, 2
  %2 = icmp ugt i32 %1, 3
  %cmp3 = icmp ule i32 %b, 2
  %cmp = or i1 %2, %cmp3
  ret i1 %cmp
}

define <2 x i1> @or_of_icmps5_vec(<2 x i32> %b) {
; CHECK-LABEL: @or_of_icmps5_vec(
; CHECK-NEXT:    ret <2 x i1> <i1 true, i1 true>
;
  %1 = add nuw <2 x i32> %b, <i32 2, i32 2>
  %2 = icmp ugt <2 x i32> %1, <i32 3, i32 3>
  %cmp3 = icmp ule <2 x i32> %b, <i32 2, i32 2>
  %cmp = or <2 x i1> %2, %cmp3
  ret <2 x i1> %cmp
}

define i32 @neg_nuw(i32 %x) {
; CHECK-LABEL: @neg_nuw(
; CHECK-NEXT:    ret i32 0
;
  %neg = sub nuw i32 0, %x
  ret i32 %neg
}

define i1 @and_icmp1(i32 %x, i32 %y) {
; CHECK-LABEL: @and_icmp1(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ult i32 %x, %y
; CHECK-NEXT:    ret i1 [[TMP1]]
;
  %1 = icmp ult i32 %x, %y
  %2 = icmp ne i32 %y, 0
  %3 = and i1 %1, %2
  ret i1 %3
}

define i1 @and_icmp2(i32 %x, i32 %y) {
; CHECK-LABEL: @and_icmp2(
; CHECK-NEXT:    ret i1 false
;
  %1 = icmp ult i32 %x, %y
  %2 = icmp eq i32 %y, 0
  %3 = and i1 %1, %2
  ret i1 %3
}

define i1 @or_icmp1(i32 %x, i32 %y) {
; CHECK-LABEL: @or_icmp1(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ne i32 %y, 0
; CHECK-NEXT:    ret i1 [[TMP1]]
;
  %1 = icmp ult i32 %x, %y
  %2 = icmp ne i32 %y, 0
  %3 = or i1 %1, %2
  ret i1 %3
}

define i1 @or_icmp2(i32 %x, i32 %y) {
; CHECK-LABEL: @or_icmp2(
; CHECK-NEXT:    ret i1 true
;
  %1 = icmp uge i32 %x, %y
  %2 = icmp ne i32 %y, 0
  %3 = or i1 %1, %2
  ret i1 %3
}

define i1 @or_icmp3(i32 %x, i32 %y) {
; CHECK-LABEL: @or_icmp3(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp uge i32 %x, %y
; CHECK-NEXT:    ret i1 [[TMP1]]
;
  %1 = icmp uge i32 %x, %y
  %2 = icmp eq i32 %y, 0
  %3 = or i1 %1, %2
  ret i1 %3
}

; PR27869 - Look through casts to eliminate cmps and bitwise logic.

define i32 @and_of_zexted_icmps(i32 %i) {
; CHECK-LABEL: @and_of_zexted_icmps(
; CHECK-NEXT:    ret i32 0
;
  %cmp0 = icmp eq i32 %i, 0
  %conv0 = zext i1 %cmp0 to i32
  %cmp1 = icmp ugt i32 %i, 4
  %conv1 = zext i1 %cmp1 to i32
  %and = and i32 %conv0, %conv1
  ret i32 %and
}

; Make sure vectors work too.

define <4 x i32> @and_of_zexted_icmps_vec(<4 x i32> %i) {
; CHECK-LABEL: @and_of_zexted_icmps_vec(
; CHECK-NEXT:    ret <4 x i32> zeroinitializer
;
  %cmp0 = icmp eq <4 x i32> %i, zeroinitializer
  %conv0 = zext <4 x i1> %cmp0 to <4 x i32>
  %cmp1 = icmp slt <4 x i32> %i, zeroinitializer
  %conv1 = zext <4 x i1> %cmp1 to <4 x i32>
  %and = and <4 x i32> %conv0, %conv1
  ret <4 x i32> %and
}

; Try a different cast and weird types.

define i5 @and_of_sexted_icmps(i3 %i) {
; CHECK-LABEL: @and_of_sexted_icmps(
; CHECK-NEXT:    ret i5 0
;
  %cmp0 = icmp eq i3 %i, 0
  %conv0 = sext i1 %cmp0 to i5
  %cmp1 = icmp ugt i3 %i, 1
  %conv1 = sext i1 %cmp1 to i5
  %and = and i5 %conv0, %conv1
  ret i5 %and
}

; Try a different cast and weird vector types.

define i3 @and_of_bitcast_icmps_vec(<3 x i65> %i) {
; CHECK-LABEL: @and_of_bitcast_icmps_vec(
; CHECK-NEXT:    ret i3 0
;
  %cmp0 = icmp sgt <3 x i65> %i, zeroinitializer
  %conv0 = bitcast <3 x i1> %cmp0 to i3
  %cmp1 = icmp slt <3 x i65> %i, zeroinitializer
  %conv1 = bitcast <3 x i1> %cmp1 to i3
  %and = and i3 %conv0, %conv1
  ret i3 %and
}

; We can't do this if the casts are different.

define i16 @and_of_different_cast_icmps(i8 %i) {
; CHECK-LABEL: @and_of_different_cast_icmps(
; CHECK-NEXT:    [[CMP0:%.*]] = icmp eq i8 %i, 0
; CHECK-NEXT:    [[CONV0:%.*]] = zext i1 [[CMP0]] to i16
; CHECK-NEXT:    [[CMP1:%.*]] = icmp eq i8 %i, 1
; CHECK-NEXT:    [[CONV1:%.*]] = sext i1 [[CMP1]] to i16
; CHECK-NEXT:    [[AND:%.*]] = and i16 [[CONV0]], [[CONV1]]
; CHECK-NEXT:    ret i16 [[AND]]
;
  %cmp0 = icmp eq i8 %i, 0
  %conv0 = zext i1 %cmp0 to i16
  %cmp1 = icmp eq i8 %i, 1
  %conv1 = sext i1 %cmp1 to i16
  %and = and i16 %conv0, %conv1
  ret i16 %and
}

define <2 x i3> @and_of_different_cast_icmps_vec(<2 x i8> %i, <2 x i16> %j) {
; CHECK-LABEL: @and_of_different_cast_icmps_vec(
; CHECK-NEXT:    [[CMP0:%.*]] = icmp eq <2 x i8> %i, zeroinitializer
; CHECK-NEXT:    [[CONV0:%.*]] = zext <2 x i1> [[CMP0]] to <2 x i3>
; CHECK-NEXT:    [[CMP1:%.*]] = icmp ugt <2 x i16> %j, <i16 1, i16 1>
; CHECK-NEXT:    [[CONV1:%.*]] = zext <2 x i1> [[CMP1]] to <2 x i3>
; CHECK-NEXT:    [[AND:%.*]] = and <2 x i3> [[CONV0]], [[CONV1]]
; CHECK-NEXT:    ret <2 x i3> [[AND]]
;
  %cmp0 = icmp eq <2 x i8> %i, zeroinitializer
  %conv0 = zext <2 x i1> %cmp0 to <2 x i3>
  %cmp1 = icmp ugt <2 x i16> %j, <i16 1, i16 1>
  %conv1 = zext <2 x i1> %cmp1 to <2 x i3>
  %and = and <2 x i3> %conv0, %conv1
  ret <2 x i3> %and
}

define i32 @or_of_zexted_icmps(i32 %i) {
; CHECK-LABEL: @or_of_zexted_icmps(
; CHECK-NEXT:    ret i32 1
;
  %cmp0 = icmp ne i32 %i, 0
  %conv0 = zext i1 %cmp0 to i32
  %cmp1 = icmp uge i32 4, %i
  %conv1 = zext i1 %cmp1 to i32
  %or = or i32 %conv0, %conv1
  ret i32 %or
}

; Try a different cast and weird vector types.

define i3 @or_of_bitcast_icmps_vec(<3 x i65> %i) {
; CHECK-LABEL: @or_of_bitcast_icmps_vec(
; CHECK-NEXT:    ret i3 bitcast (<3 x i1> <i1 true, i1 true, i1 true> to i3)
;
  %cmp0 = icmp sge <3 x i65> %i, zeroinitializer
  %conv0 = bitcast <3 x i1> %cmp0 to i3
  %cmp1 = icmp slt <3 x i65> %i, zeroinitializer
  %conv1 = bitcast <3 x i1> %cmp1 to i3
  %or = or i3 %conv0, %conv1
  ret i3 %or
}

; We can't simplify if the casts are different.

define i16 @or_of_different_cast_icmps(i8 %i) {
; CHECK-LABEL: @or_of_different_cast_icmps(
; CHECK-NEXT:    [[CMP0:%.*]] = icmp ne i8 %i, 0
; CHECK-NEXT:    [[CONV0:%.*]] = zext i1 [[CMP0]] to i16
; CHECK-NEXT:    [[CMP1:%.*]] = icmp ne i8 %i, 1
; CHECK-NEXT:    [[CONV1:%.*]] = sext i1 [[CMP1]] to i16
; CHECK-NEXT:    [[OR:%.*]] = or i16 [[CONV0]], [[CONV1]]
; CHECK-NEXT:    ret i16 [[OR]]
;
  %cmp0 = icmp ne i8 %i, 0
  %conv0 = zext i1 %cmp0 to i16
  %cmp1 = icmp ne i8 %i, 1
  %conv1 = sext i1 %cmp1 to i16
  %or = or i16 %conv0, %conv1
  ret i16 %or
}

; (A & ~B) | (A ^ B) -> A ^ B

define i32 @test43(i32 %a, i32 %b) {
; CHECK-LABEL: @test43(
; CHECK-NEXT:    [[OR:%.*]] = xor i32 %a, %b
; CHECK-NEXT:    ret i32 [[OR]]
;
  %neg = xor i32 %b, -1
  %and = and i32 %a, %neg
  %xor = xor i32 %a, %b
  %or = or i32 %and, %xor
  ret i32 %or
}

define i32 @test43_commuted_and(i32 %a, i32 %b) {
; CHECK-LABEL: @test43_commuted_and(
; CHECK-NEXT:    [[OR:%.*]] = xor i32 %a, %b
; CHECK-NEXT:    ret i32 [[OR]]
;
  %neg = xor i32 %b, -1
  %and = and i32 %neg, %a
  %xor = xor i32 %a, %b
  %or = or i32 %and, %xor
  ret i32 %or
}

; Commute operands of the 'or'.
; (A ^ B) | (A & ~B) -> A ^ B

define i32 @test44(i32 %a, i32 %b) {
; CHECK-LABEL: @test44(
; CHECK-NEXT:    [[OR:%.*]] = xor i32 %a, %b
; CHECK-NEXT:    ret i32 [[OR]]
;
  %xor = xor i32 %a, %b
  %neg = xor i32 %b, -1
  %and = and i32 %a, %neg
  %or = or i32 %xor, %and
  ret i32 %or
}

define i32 @test44_commuted_and(i32 %a, i32 %b) {
; CHECK-LABEL: @test44_commuted_and(
; CHECK-NEXT:    [[OR:%.*]] = xor i32 %a, %b
; CHECK-NEXT:    ret i32 [[OR]]
;
  %xor = xor i32 %a, %b
  %neg = xor i32 %b, -1
  %and = and i32 %neg, %a
  %or = or i32 %xor, %and
  ret i32 %or
}

; (~A & ~B) | (~A ^ B) -> ~A ^ B

define i32 @test45(i32 %a, i32 %b) {
; CHECK-LABEL: @test45(
; CHECK-NEXT:    [[NEGB:%.*]] = xor i32 [[B:%.*]], -1
; CHECK-NEXT:    [[XOR:%.*]] = xor i32 [[A:%.*]], [[NEGB]]
; CHECK-NEXT:    ret i32 [[XOR]]
;
  %nega = xor i32 %a, -1
  %negb = xor i32 %b, -1
  %and = and i32 %nega, %negb
  %xor = xor i32 %a, %negb
  %or = or i32 %and, %xor
  ret i32 %or
}

define i32 @test45_commuted_and(i32 %a, i32 %b) {
; CHECK-LABEL: @test45_commuted_and(
; CHECK-NEXT:    [[NEGB:%.*]] = xor i32 [[B:%.*]], -1
; CHECK-NEXT:    [[XOR:%.*]] = xor i32 [[A:%.*]], [[NEGB]]
; CHECK-NEXT:    ret i32 [[XOR]]
;
  %nega = xor i32 %a, -1
  %negb = xor i32 %b, -1
  %and = and i32 %negb, %nega
  %xor = xor i32 %a, %negb
  %or = or i32 %and, %xor
  ret i32 %or
}

; Commute operands of the 'or'.
; (~A ^ B) | (~A & ~B) -> ~A ^ B

define i32 @test46(i32 %a, i32 %b) {
; CHECK-LABEL: @test46(
; CHECK-NEXT:    [[NEGB:%.*]] = xor i32 [[B:%.*]], -1
; CHECK-NEXT:    [[XOR:%.*]] = xor i32 [[A:%.*]], [[NEGB]]
; CHECK-NEXT:    ret i32 [[XOR]]
;
  %nega = xor i32 %a, -1
  %negb = xor i32 %b, -1
  %and = and i32 %nega, %negb
  %xor = xor i32 %a, %negb
  %or = or i32 %xor, %and
  ret i32 %or
}

; (~A & ~B) | (~A ^ B) -> ~A ^ B

define i32 @test46_commuted_and(i32 %a, i32 %b) {
; CHECK-LABEL: @test46_commuted_and(
; CHECK-NEXT:    [[NEGB:%.*]] = xor i32 [[B:%.*]], -1
; CHECK-NEXT:    [[XOR:%.*]] = xor i32 [[A:%.*]], [[NEGB]]
; CHECK-NEXT:    ret i32 [[XOR]]
;
  %nega = xor i32 %a, -1
  %negb = xor i32 %b, -1
  %and = and i32 %negb, %nega
  %xor = xor i32 %a, %negb
  %or = or i32 %xor, %and
  ret i32 %or
}

; (~A ^ B) | (A & B) -> ~A ^ B

define i32 @test47(i32 %a, i32 %b) {
; CHECK-LABEL: @test47(
; CHECK-NEXT:    [[NEGA:%.*]] = xor i32 [[A:%.*]], -1
; CHECK-NEXT:    [[XOR:%.*]] = xor i32 [[NEGA]], [[B:%.*]]
; CHECK-NEXT:    ret i32 [[XOR]]
;
  %nega = xor i32 %a, -1
  %and = and i32 %a, %b
  %xor = xor i32 %nega, %b
  %or = or i32 %xor, %and
  ret i32 %or
}

define i32 @test48(i32 %a, i32 %b) {
; CHECK-LABEL: @test48(
; CHECK-NEXT:    [[NEGA:%.*]] = xor i32 [[A:%.*]], -1
; CHECK-NEXT:    [[XOR:%.*]] = xor i32 [[B:%.*]], [[NEGA]]
; CHECK-NEXT:    ret i32 [[XOR]]
;
  %nega = xor i32 %a, -1
  %and = and i32 %a, %b
  %xor = xor i32 %b, %nega
  %or = or i32 %xor, %and
  ret i32 %or
}

define i32 @test49(i32 %a, i32 %b) {
; CHECK-LABEL: @test49(
; CHECK-NEXT:    [[NEGA:%.*]] = xor i32 [[A:%.*]], -1
; CHECK-NEXT:    [[XOR:%.*]] = xor i32 [[B:%.*]], [[NEGA]]
; CHECK-NEXT:    ret i32 [[XOR]]
;
  %nega = xor i32 %a, -1
  %and = and i32 %b, %a
  %xor = xor i32 %b, %nega
  %or = or i32 %xor, %and
  ret i32 %or
}

define i32 @test50(i32 %a, i32 %b) {
; CHECK-LABEL: @test50(
; CHECK-NEXT:    [[NEGA:%.*]] = xor i32 [[A:%.*]], -1
; CHECK-NEXT:    [[XOR:%.*]] = xor i32 [[NEGA]], [[B:%.*]]
; CHECK-NEXT:    ret i32 [[XOR]]
;
  %nega = xor i32 %a, -1
  %and = and i32 %b, %a
  %xor = xor i32 %nega, %b
  %or = or i32 %xor, %and
  ret i32 %or
}

define i32 @test51(i32 %a, i32 %b) {
; CHECK-LABEL: @test51(
; CHECK-NEXT:    [[NEGA:%.*]] = xor i32 [[A:%.*]], -1
; CHECK-NEXT:    [[XOR:%.*]] = xor i32 [[NEGA]], [[B:%.*]]
; CHECK-NEXT:    ret i32 [[XOR]]
;
  %nega = xor i32 %a, -1
  %and = and i32 %a, %b
  %xor = xor i32 %nega, %b
  %or = or i32 %and, %xor
  ret i32 %or
}

define i32 @test52(i32 %a, i32 %b) {
; CHECK-LABEL: @test52(
; CHECK-NEXT:    [[NEGA:%.*]] = xor i32 [[A:%.*]], -1
; CHECK-NEXT:    [[XOR:%.*]] = xor i32 [[B:%.*]], [[NEGA]]
; CHECK-NEXT:    ret i32 [[XOR]]
;
  %nega = xor i32 %a, -1
  %and = and i32 %a, %b
  %xor = xor i32 %b, %nega
  %or = or i32 %and, %xor
  ret i32 %or
}

define i32 @test53(i32 %a, i32 %b) {
; CHECK-LABEL: @test53(
; CHECK-NEXT:    [[NEGA:%.*]] = xor i32 [[A:%.*]], -1
; CHECK-NEXT:    [[XOR:%.*]] = xor i32 [[B:%.*]], [[NEGA]]
; CHECK-NEXT:    ret i32 [[XOR]]
;
  %nega = xor i32 %a, -1
  %and = and i32 %b, %a
  %xor = xor i32 %b, %nega
  %or = or i32 %and, %xor
  ret i32 %or
}

define i32 @test54(i32 %a, i32 %b) {
; CHECK-LABEL: @test54(
; CHECK-NEXT:    [[NEGA:%.*]] = xor i32 [[A:%.*]], -1
; CHECK-NEXT:    [[XOR:%.*]] = xor i32 [[NEGA]], [[B:%.*]]
; CHECK-NEXT:    ret i32 [[XOR]]
;
  %nega = xor i32 %a, -1
  %and = and i32 %b, %a
  %xor = xor i32 %nega, %b
  %or = or i32 %and, %xor
  ret i32 %or
}

define i8 @lshr_perfect_mask(i8 %x) {
; CHECK-LABEL: @lshr_perfect_mask(
; CHECK-NEXT:    [[SH:%.*]] = lshr i8 %x, 5
; CHECK-NEXT:    ret i8 [[SH]]
;
  %sh = lshr i8 %x, 5
  %mask = and i8 %sh, 7  ; 0x07
  ret i8 %mask
}

define <2 x i8> @lshr_oversized_mask_splat(<2 x i8> %x) {
; CHECK-LABEL: @lshr_oversized_mask_splat(
; CHECK-NEXT:    [[SH:%.*]] = lshr <2 x i8> %x, <i8 5, i8 5>
; CHECK-NEXT:    ret <2 x i8> [[SH]]
;
  %sh = lshr <2 x i8> %x, <i8 5, i8 5>
  %mask = and <2 x i8> %sh, <i8 135, i8 135>  ; 0x87
  ret <2 x i8> %mask
}

define i8 @lshr_undersized_mask(i8 %x) {
; CHECK-LABEL: @lshr_undersized_mask(
; CHECK-NEXT:    [[SH:%.*]] = lshr i8 %x, 5
; CHECK-NEXT:    [[MASK:%.*]] = and i8 [[SH]], -2
; CHECK-NEXT:    ret i8 [[MASK]]
;
  %sh = lshr i8 %x, 5
  %mask = and i8 %sh, -2  ; 0xFE
  ret i8 %mask
}

define <2 x i8> @shl_perfect_mask_splat(<2 x i8> %x) {
; CHECK-LABEL: @shl_perfect_mask_splat(
; CHECK-NEXT:    [[SH:%.*]] = shl <2 x i8> %x, <i8 6, i8 6>
; CHECK-NEXT:    ret <2 x i8> [[SH]]
;
  %sh = shl <2 x i8> %x, <i8 6, i8 6>
  %mask = and <2 x i8> %sh, <i8 192, i8 192>  ; 0xC0
  ret <2 x i8> %mask
}

define i8 @shl_oversized_mask(i8 %x) {
; CHECK-LABEL: @shl_oversized_mask(
; CHECK-NEXT:    [[SH:%.*]] = shl i8 %x, 6
; CHECK-NEXT:    ret i8 [[SH]]
;
  %sh = shl i8 %x, 6
  %mask = and i8 %sh, 195  ; 0xC3
  ret i8 %mask
}

define <2 x i8> @shl_undersized_mask_splat(<2 x i8> %x) {
; CHECK-LABEL: @shl_undersized_mask_splat(
; CHECK-NEXT:    [[SH:%.*]] = shl <2 x i8> [[X:%.*]], <i8 6, i8 6>
; CHECK-NEXT:    [[MASK:%.*]] = and <2 x i8> [[SH]], <i8 -120, i8 -120>
; CHECK-NEXT:    ret <2 x i8> [[MASK]]
;
  %sh = shl <2 x i8> %x, <i8 6, i8 6>
  %mask = and <2 x i8> %sh, <i8 136, i8 136>  ; 0x88
  ret <2 x i8> %mask
}

