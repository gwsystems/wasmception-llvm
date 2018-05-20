; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; and enhanced to include metadata checking.

; RUN: opt < %s -instcombine -S | FileCheck %s

define i32 @foo(i32) local_unnamed_addr #0  {
; CHECK-LABEL: @foo(
; CHECK-NEXT:    [[TMP2:%.*]] = icmp sgt i32 %0, 2
; CHECK-NEXT:    [[DOTV:%.*]] = select i1 [[TMP2]], i32 20, i32 -20, !prof ![[$MD1:[0-9]+]]
; CHECK-NEXT:    [[TMP3:%.*]] = add i32 [[DOTV]], %0
; CHECK-NEXT:    ret i32 [[TMP3]]
;
  %2 = icmp sgt i32 %0, 2
  %3 = add nsw i32 %0, 20
  %4 = add nsw i32 %0, -20
  select i1 %2, i32 %3, i32 %4, !prof !1
  ret i32 %5
}

define i8 @shrink_select(i1 %cond, i32 %x) {
; CHECK-LABEL: @shrink_select(
; CHECK-NEXT:    [[TMP1:%.*]] = trunc i32 %x to i8
; CHECK-NEXT:    [[TRUNC:%.*]] = select i1 %cond, i8 [[TMP1]], i8 42, !prof ![[$MD1]]
; CHECK-NEXT:    ret i8 [[TRUNC]]
;
  %sel = select i1 %cond, i32 %x, i32 42, !prof !1
  %trunc = trunc i32 %sel to i8
  ret i8 %trunc
}

define void @min_max_bitcast(<4 x float> %a, <4 x float> %b, <4 x i32>* %ptr1, <4 x i32>* %ptr2) {
; CHECK-LABEL: @min_max_bitcast(
; CHECK-NEXT:    [[CMP:%.*]] = fcmp olt <4 x float> %a, %b
; CHECK-NEXT:    [[SEL1_V:%.*]] = select <4 x i1> [[CMP]], <4 x float> %a, <4 x float> %b, !prof ![[$MD1]]
; CHECK-NEXT:    [[SEL2_V:%.*]] = select <4 x i1> [[CMP]], <4 x float> %b, <4 x float> %a, !prof ![[$MD1]]
; CHECK-NEXT:    [[TMP1:%.*]] = bitcast <4 x i32>* %ptr1 to <4 x float>*
; CHECK-NEXT:    store <4 x float> [[SEL1_V]], <4 x float>* [[TMP1]], align 16
; CHECK-NEXT:    [[TMP2:%.*]] = bitcast <4 x i32>* %ptr2 to <4 x float>*
; CHECK-NEXT:    store <4 x float> [[SEL2_V]], <4 x float>* [[TMP2]], align 16
; CHECK-NEXT:    ret void
;
  %cmp = fcmp olt <4 x float> %a, %b
  %bc1 = bitcast <4 x float> %a to <4 x i32>
  %bc2 = bitcast <4 x float> %b to <4 x i32>
  %sel1 = select <4 x i1> %cmp, <4 x i32> %bc1, <4 x i32> %bc2, !prof !1
  %sel2 = select <4 x i1> %cmp, <4 x i32> %bc2, <4 x i32> %bc1, !prof !1
  store <4 x i32> %sel1, <4 x i32>* %ptr1
  store <4 x i32> %sel2, <4 x i32>* %ptr2
  ret void
}

define i32 @foo2(i32, i32) local_unnamed_addr #0  {
; CHECK-LABEL: @foo2(
; CHECK-NEXT:    [[TMP3:%.*]] = icmp sgt i32 %0, 2
; CHECK-NEXT:    [[TMP4:%.*]] = sub i32 0, %1
; CHECK-NEXT:    [[DOTP:%.*]] = select i1 [[TMP3]], i32 %1, i32 [[TMP4]], !prof ![[$MD1]]
; CHECK-NEXT:    [[TMP5:%.*]] = add i32 [[DOTP]], %0
; CHECK-NEXT:    ret i32 [[TMP5]]
;
  %3 = icmp sgt i32 %0, 2
  %4 = add nsw i32 %0, %1
  %5 = sub nsw i32 %0, %1
  select i1 %3, i32 %4, i32 %5, !prof !1
  ret i32 %6
}

define i64 @test43(i32 %a) nounwind {
; CHECK-LABEL: @test43(
; CHECK-NEXT:    [[A_EXT:%.*]] = sext i32 %a to i64
; CHECK-NEXT:    [[TMP1:%.*]] = icmp sgt i64 [[A_EXT]], 0
; CHECK-NEXT:    [[MAX:%.*]] = select i1 [[TMP1]], i64 [[A_EXT]], i64 0, !prof ![[$MD1]]
; CHECK-NEXT:    ret i64 [[MAX]]
;
  %a_ext = sext i32 %a to i64
  %is_a_nonnegative = icmp sgt i32 %a, -1
  %max = select i1 %is_a_nonnegative, i64 %a_ext, i64 0, !prof !1
  ret i64 %max
}

define <2 x i32> @scalar_select_of_vectors_sext(<2 x i1> %cca, i1 %ccb) {
; CHECK-LABEL: @scalar_select_of_vectors_sext(
; CHECK-NEXT:    [[NARROW:%.*]] = select i1 %ccb, <2 x i1> %cca, <2 x i1> zeroinitializer, !prof ![[$MD1]]
; CHECK-NEXT:    [[R:%.*]] = sext <2 x i1> [[NARROW]] to <2 x i32>
; CHECK-NEXT:    ret <2 x i32> [[R]]
;
  %ccax = sext <2 x i1> %cca to <2 x i32>
  %r = select i1 %ccb, <2 x i32> %ccax, <2 x i32> <i32 0, i32 0>, !prof !1
  ret <2 x i32> %r
}


define i16 @t7(i32 %a) {
; CHECK-LABEL: @t7(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp slt i32 %a, -32768
; CHECK-NEXT:    [[TMP2:%.*]] = select i1 [[TMP1]], i32 %a, i32 -32768, !prof ![[$MD1]]
; CHECK-NEXT:    [[TMP3:%.*]] = trunc i32 [[TMP2]] to i16
; CHECK-NEXT:    ret i16 [[TMP3]]
;
  %1 = icmp slt i32 %a, -32768
  %2 = trunc i32 %a to i16
  %3 = select i1 %1, i16 %2, i16 -32768, !prof !1
  ret i16 %3
}

define i32 @abs_nabs_x01(i32 %x) {
; CHECK-LABEL: @abs_nabs_x01(
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt i32 %x, 0
; CHECK-NEXT:    [[SUB:%.*]] = sub nsw i32 0, %x
; CHECK-NEXT:    [[COND1:%.*]] = select i1 [[CMP]], i32 [[SUB]], i32 %x, !prof ![[$MD3:[0-9]+]]
; CHECK-NEXT:    ret i32 [[COND1]]
;
  %cmp = icmp sgt i32 %x, -1
  %sub = sub nsw i32 0, %x
  %cond = select i1 %cmp, i32 %sub, i32 %x, !prof !1
  %cmp1 = icmp sgt i32 %cond, -1
  %sub16 = sub nsw i32 0, %cond
  %cond18 = select i1 %cmp1, i32 %cond, i32 %sub16, !prof !2
  ret i32 %cond18
}

; Swap predicate / metadata order

define <2 x i32> @abs_nabs_x01_vec(<2 x i32> %x) {
; CHECK-LABEL: @abs_nabs_x01_vec(
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt <2 x i32> %x, zeroinitializer
; CHECK-NEXT:    [[SUB:%.*]] = sub nsw <2 x i32> zeroinitializer, %x
; CHECK-NEXT:    [[COND1:%.*]] = select <2 x i1> [[CMP]], <2 x i32> [[SUB]], <2 x i32> %x, !prof ![[$MD3]]
; CHECK-NEXT:    ret <2 x i32> [[COND1]]
;
  %cmp = icmp sgt <2 x i32> %x, <i32 -1, i32 -1>
  %sub = sub nsw <2 x i32> zeroinitializer, %x
  %cond = select <2 x i1> %cmp, <2 x i32> %sub, <2 x i32> %x, !prof !1
  %cmp1 = icmp sgt <2 x i32> %cond, <i32 -1, i32 -1>
  %sub16 = sub nsw <2 x i32> zeroinitializer, %cond
  %cond18 = select <2 x i1> %cmp1, <2 x i32> %cond, <2 x i32> %sub16, !prof !2
  ret <2 x i32> %cond18
}

; SMAX(SMAX(x, y), x) -> SMAX(x, y)
define i32 @test30(i32 %x, i32 %y) {
; CHECK-LABEL: @test30(
; CHECK-NEXT:    [[CMP:%.*]] = icmp sgt i32 %x, %y
; CHECK-NEXT:    [[COND:%.*]] = select i1 [[CMP]], i32 %x, i32 %y, !prof ![[$MD1]]
; CHECK-NEXT:    ret i32 [[COND]]
;
  %cmp = icmp sgt i32 %x, %y
  %cond = select i1 %cmp, i32 %x, i32 %y, !prof !1
  %cmp5 = icmp sgt i32 %cond, %x
  %retval = select i1 %cmp5, i32 %cond, i32 %x, !prof !2
  ret i32 %retval
}

; SMAX(SMAX(75, X), 36) -> SMAX(X, 75)
define i32 @test70(i32 %x) {
; CHECK-LABEL: @test70(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp sgt i32 %x, 75
; CHECK-NEXT:    [[COND:%.*]] = select i1 [[TMP1]], i32 %x, i32 75, !prof ![[$MD3]]
; CHECK-NEXT:    ret i32 [[COND]]
;
  %cmp = icmp slt i32 %x, 75
  %cond = select i1 %cmp, i32 75, i32 %x, !prof !1
  %cmp3 = icmp slt i32 %cond, 36
  %retval = select i1 %cmp3, i32 36, i32 %cond, !prof !2
  ret i32 %retval
}

; Swap predicate / metadata order
; SMIN(SMIN(X, 92), 11) -> SMIN(X, 11)
define i32 @test72(i32 %x) {
; CHECK-LABEL: @test72(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp slt i32 %x, 11
; CHECK-NEXT:    [[RETVAL:%.*]] = select i1 [[TMP1]], i32 %x, i32 11, !prof ![[$MD4:[0-9]+]]
; CHECK-NEXT:    ret i32 [[RETVAL]]
;
  %cmp = icmp sgt i32 %x, 92
  %cond = select i1 %cmp, i32 92, i32 %x, !prof !1
  %cmp3 = icmp sgt i32 %cond, 11
  %retval = select i1 %cmp3, i32 11, i32 %cond, !prof !2
  ret i32 %retval
}

; Swap predicate / metadata order
; SMAX(SMAX(X, 36), 75) -> SMAX(X, 75)
define i32 @test74(i32 %x) {
; CHECK-LABEL: @test74(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp sgt i32 %x, 75
; CHECK-NEXT:    [[RETVAL:%.*]] = select i1 [[TMP1]], i32 %x, i32 75, !prof ![[$MD4]]
; CHECK-NEXT:    ret i32 [[RETVAL]]
;
  %cmp = icmp slt i32 %x, 36
  %cond = select i1 %cmp, i32 36, i32 %x, !prof !1
  %cmp3 = icmp slt i32 %cond, 75
  %retval = select i1 %cmp3, i32 75, i32 %cond, !prof !2
  ret i32 %retval
}

; The compare should change, but the metadata remains the same because the select operands are not swapped.
define i32 @smin1(i32 %x) {
; CHECK-LABEL: @smin1(
; CHECK-NEXT:    [[NOT_X:%.*]] = xor i32 %x, -1
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt i32 [[NOT_X]], -1
; CHECK-NEXT:    [[SEL:%.*]] = select i1 [[CMP]], i32 [[NOT_X]], i32 -1, !prof ![[$MD1]]
; CHECK-NEXT:    ret i32 [[SEL]]
;
  %not_x = xor i32 %x, -1
  %cmp = icmp sgt i32 %x, 0
  %sel = select i1 %cmp, i32 %not_x, i32 -1, !prof !1
  ret i32 %sel
}

; The compare should change, and the metadata is swapped because the select operands are swapped.
define i32 @smin2(i32 %x) {
; CHECK-LABEL: @smin2(
; CHECK-NEXT:    [[NOT_X:%.*]] = xor i32 %x, -1
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt i32 [[NOT_X]], -1
; CHECK-NEXT:    [[SEL:%.*]] = select i1 [[CMP]], i32 [[NOT_X]], i32 -1, !prof ![[$MD3]]
; CHECK-NEXT:    ret i32 [[SEL]]
;
  %not_x = xor i32 %x, -1
  %cmp = icmp slt i32 %x, 0
  %sel = select i1 %cmp, i32 -1, i32 %not_x, !prof !1
  ret i32 %sel
}

; The compare should change, but the metadata remains the same because the select operands are not swapped.
define i32 @smax1(i32 %x) {
; CHECK-LABEL: @smax1(
; CHECK-NEXT:    [[NOT_X:%.*]] = xor i32 %x, -1
; CHECK-NEXT:    [[CMP:%.*]] = icmp sgt i32 [[NOT_X]], -1
; CHECK-NEXT:    [[SEL:%.*]] = select i1 [[CMP]], i32 [[NOT_X]], i32 -1, !prof ![[$MD1]]
; CHECK-NEXT:    ret i32 [[SEL]]
;
  %not_x = xor i32 %x, -1
  %cmp = icmp slt i32 %x, 0
  %sel = select i1 %cmp, i32 %not_x, i32 -1, !prof !1
  ret i32 %sel
}

; The compare should change, and the metadata is swapped because the select operands are swapped.
define i32 @smax2(i32 %x) {
; CHECK-LABEL: @smax2(
; CHECK-NEXT:    [[NOT_X:%.*]] = xor i32 %x, -1
; CHECK-NEXT:    [[CMP:%.*]] = icmp sgt i32 [[NOT_X]], -1
; CHECK-NEXT:    [[SEL:%.*]] = select i1 [[CMP]], i32 [[NOT_X]], i32 -1, !prof ![[$MD3]]
; CHECK-NEXT:    ret i32 [[SEL]]
;
  %not_x = xor i32 %x, -1
  %cmp = icmp sgt i32 %x, 0
  %sel = select i1 %cmp, i32 -1, i32 %not_x, !prof !1
  ret i32 %sel
}

; The compare should change, but the metadata remains the same because the select operands are not swapped.
define i32 @umin1(i32 %x) {
; CHECK-LABEL: @umin1(
; CHECK-NEXT:    [[CMP:%.*]] = icmp ult i32 %x, -2147483648
; CHECK-NEXT:    [[SEL:%.*]] = select i1 [[CMP]], i32 %x, i32 -2147483648, !prof ![[$MD1]]
; CHECK-NEXT:    ret i32 [[SEL]]
;
  %cmp = icmp sgt i32 %x, -1
  %sel = select i1 %cmp, i32 %x, i32 -2147483648, !prof !1
  ret i32 %sel
}

; The compare should change, and the metadata is swapped because the select operands are swapped.
define i32 @umin2(i32 %x) {
; CHECK-LABEL: @umin2(
; CHECK-NEXT:    [[CMP:%.*]] = icmp ult i32 %x, 2147483647
; CHECK-NEXT:    [[SEL:%.*]] = select i1 [[CMP]], i32 %x, i32 2147483647, !prof ![[$MD3]]
; CHECK-NEXT:    ret i32 [[SEL]]
;
  %cmp = icmp slt i32 %x, 0
  %sel = select i1 %cmp, i32 2147483647, i32 %x, !prof !1
  ret i32 %sel
}

; The compare should change, but the metadata remains the same because the select operands are not swapped.
define i32 @umax1(i32 %x) {
; CHECK-LABEL: @umax1(
; CHECK-NEXT:    [[CMP:%.*]] = icmp ugt i32 %x, 2147483647
; CHECK-NEXT:    [[SEL:%.*]] = select i1 [[CMP]], i32 %x, i32 2147483647, !prof ![[$MD1]]
; CHECK-NEXT:    ret i32 [[SEL]]
;
  %cmp = icmp slt i32 %x, 0
  %sel = select i1 %cmp, i32 %x, i32 2147483647, !prof !1
  ret i32 %sel
}

; The compare should change, and the metadata is swapped because the select operands are swapped.
define i32 @umax2(i32 %x) {
; CHECK-LABEL: @umax2(
; CHECK-NEXT:    [[CMP:%.*]] = icmp ugt i32 %x, -2147483648
; CHECK-NEXT:    [[SEL:%.*]] = select i1 [[CMP]], i32 %x, i32 -2147483648, !prof ![[$MD3]]
; CHECK-NEXT:    ret i32 [[SEL]]
;
  %cmp = icmp sgt i32 %x, -1
  %sel = select i1 %cmp, i32 -2147483648, i32 %x, !prof !1
  ret i32 %sel
}

!1 = !{!"branch_weights", i32 2, i32 10}
!2 = !{!"branch_weights", i32 3, i32 10}

; CHECK-DAG: ![[$MD1]] = !{!"branch_weights", i32 2, i32 10}
; CHECK-DAG: ![[$MD3]] = !{!"branch_weights", i32 10, i32 2}
; CHECK-DAG: ![[$MD4]] = !{!"branch_weights", i32 10, i32 3}

