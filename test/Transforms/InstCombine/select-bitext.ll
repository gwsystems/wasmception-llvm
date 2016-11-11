; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -instcombine -S | FileCheck %s

; FIXME: We should not grow the size of the select in the next 4 cases.

define i64 @sel_sext(i32 %a, i1 %cmp) {
; CHECK-LABEL: @sel_sext(
; CHECK-NEXT:    [[TMP1:%.*]] = sext i32 %a to i64
; CHECK-NEXT:    [[EXT:%.*]] = select i1 %cmp, i64 [[TMP1]], i64 42
; CHECK-NEXT:    ret i64 [[EXT]]
;
  %sel = select i1 %cmp, i32 %a, i32 42
  %ext = sext i32 %sel to i64
  ret i64 %ext
}

define <4 x i64> @sel_sext_vec(<4 x i32> %a, <4 x i1> %cmp) {
; CHECK-LABEL: @sel_sext_vec(
; CHECK-NEXT:    [[TMP1:%.*]] = sext <4 x i32> %a to <4 x i64>
; CHECK-NEXT:    [[EXT:%.*]] = select <4 x i1> %cmp, <4 x i64> [[TMP1]], <4 x i64> <i64 42, i64 42, i64 42, i64 42>
; CHECK-NEXT:    ret <4 x i64> [[EXT]]
;
  %sel = select <4 x i1> %cmp, <4 x i32> %a, <4 x i32> <i32 42, i32 42, i32 42, i32 42>
  %ext = sext <4 x i32> %sel to <4 x i64>
  ret <4 x i64> %ext
}

define i64 @sel_zext(i32 %a, i1 %cmp) {
; CHECK-LABEL: @sel_zext(
; CHECK-NEXT:    [[TMP1:%.*]] = zext i32 %a to i64
; CHECK-NEXT:    [[EXT:%.*]] = select i1 %cmp, i64 [[TMP1]], i64 42
; CHECK-NEXT:    ret i64 [[EXT]]
;
  %sel = select i1 %cmp, i32 %a, i32 42
  %ext = zext i32 %sel to i64
  ret i64 %ext
}

define <4 x i64> @sel_zext_vec(<4 x i32> %a, <4 x i1> %cmp) {
; CHECK-LABEL: @sel_zext_vec(
; CHECK-NEXT:    [[TMP1:%.*]] = zext <4 x i32> %a to <4 x i64>
; CHECK-NEXT:    [[EXT:%.*]] = select <4 x i1> %cmp, <4 x i64> [[TMP1]], <4 x i64> <i64 42, i64 42, i64 42, i64 42>
; CHECK-NEXT:    ret <4 x i64> [[EXT]]
;
  %sel = select <4 x i1> %cmp, <4 x i32> %a, <4 x i32> <i32 42, i32 42, i32 42, i32 42>
  %ext = zext <4 x i32> %sel to <4 x i64>
  ret <4 x i64> %ext
}

define i32 @test_sext1(i1 %cca, i1 %ccb) {
; CHECK-LABEL: @test_sext1(
; CHECK-NEXT:    [[FOLD_R:%.*]] = and i1 %ccb, %cca
; CHECK-NEXT:    [[R:%.*]] = sext i1 [[FOLD_R]] to i32
; CHECK-NEXT:    ret i32 [[R]]
;
  %ccax = sext i1 %cca to i32
  %r = select i1 %ccb, i32 %ccax, i32 0
  ret i32 %r
}

define i32 @test_sext2(i1 %cca, i1 %ccb) {
; CHECK-LABEL: @test_sext2(
; CHECK-NEXT:    [[FOLD_R:%.*]] = or i1 %ccb, %cca
; CHECK-NEXT:    [[R:%.*]] = sext i1 [[FOLD_R]] to i32
; CHECK-NEXT:    ret i32 [[R]]
;
  %ccax = sext i1 %cca to i32
  %r = select i1 %ccb, i32 -1, i32 %ccax
  ret i32 %r
}

define i32 @test_sext3(i1 %cca, i1 %ccb) {
; CHECK-LABEL: @test_sext3(
; CHECK-NEXT:    [[NOT_CCB:%.*]] = xor i1 %ccb, true
; CHECK-NEXT:    [[FOLD_R:%.*]] = and i1 [[NOT_CCB]], %cca
; CHECK-NEXT:    [[R:%.*]] = sext i1 [[FOLD_R]] to i32
; CHECK-NEXT:    ret i32 [[R]]
;
  %ccax = sext i1 %cca to i32
  %r = select i1 %ccb, i32 0, i32 %ccax
  ret i32 %r
}

define i32 @test_sext4(i1 %cca, i1 %ccb) {
; CHECK-LABEL: @test_sext4(
; CHECK-NEXT:    [[NOT_CCB:%.*]] = xor i1 %ccb, true
; CHECK-NEXT:    [[FOLD_R:%.*]] = or i1 [[NOT_CCB]], %cca
; CHECK-NEXT:    [[R:%.*]] = sext i1 [[FOLD_R]] to i32
; CHECK-NEXT:    ret i32 [[R]]
;
  %ccax = sext i1 %cca to i32
  %r = select i1 %ccb, i32 %ccax, i32 -1
  ret i32 %r
}

define i32 @test_zext1(i1 %cca, i1 %ccb) {
; CHECK-LABEL: @test_zext1(
; CHECK-NEXT:    [[FOLD_R:%.*]] = and i1 %ccb, %cca
; CHECK-NEXT:    [[R:%.*]] = zext i1 [[FOLD_R]] to i32
; CHECK-NEXT:    ret i32 [[R]]
;
  %ccax = zext i1 %cca to i32
  %r = select i1 %ccb, i32 %ccax, i32 0
  ret i32 %r
}

define i32 @test_zext2(i1 %cca, i1 %ccb) {
; CHECK-LABEL: @test_zext2(
; CHECK-NEXT:    [[FOLD_R:%.*]] = or i1 %ccb, %cca
; CHECK-NEXT:    [[R:%.*]] = zext i1 [[FOLD_R]] to i32
; CHECK-NEXT:    ret i32 [[R]]
;
  %ccax = zext i1 %cca to i32
  %r = select i1 %ccb, i32 1, i32 %ccax
  ret i32 %r
}

define i32 @test_zext3(i1 %cca, i1 %ccb) {
; CHECK-LABEL: @test_zext3(
; CHECK-NEXT:    [[NOT_CCB:%.*]] = xor i1 %ccb, true
; CHECK-NEXT:    [[FOLD_R:%.*]] = and i1 [[NOT_CCB]], %cca
; CHECK-NEXT:    [[R:%.*]] = zext i1 [[FOLD_R]] to i32
; CHECK-NEXT:    ret i32 [[R]]
;
  %ccax = zext i1 %cca to i32
  %r = select i1 %ccb, i32 0, i32 %ccax
  ret i32 %r
}

define i32 @test_zext4(i1 %cca, i1 %ccb) {
; CHECK-LABEL: @test_zext4(
; CHECK-NEXT:    [[NOT_CCB:%.*]] = xor i1 %ccb, true
; CHECK-NEXT:    [[FOLD_R:%.*]] = or i1 [[NOT_CCB]], %cca
; CHECK-NEXT:    [[R:%.*]] = zext i1 [[FOLD_R]] to i32
; CHECK-NEXT:    ret i32 [[R]]
;
  %ccax = zext i1 %cca to i32
  %r = select i1 %ccb, i32 %ccax, i32 1
  ret i32 %r
}

define i32 @test_negative_sext(i1 %a, i1 %cc) {
; CHECK-LABEL: @test_negative_sext(
; CHECK-NEXT:    [[A_EXT:%.*]] = sext i1 %a to i32
; CHECK-NEXT:    [[R:%.*]] = select i1 %cc, i32 [[A_EXT]], i32 1
; CHECK-NEXT:    ret i32 [[R]]
;
  %a.ext = sext i1 %a to i32
  %r = select i1 %cc, i32 %a.ext, i32 1
  ret i32 %r
}

define i32 @test_negative_zext(i1 %a, i1 %cc) {
; CHECK-LABEL: @test_negative_zext(
; CHECK-NEXT:    [[A_EXT:%.*]] = zext i1 %a to i32
; CHECK-NEXT:    [[R:%.*]] = select i1 %cc, i32 [[A_EXT]], i32 -1
; CHECK-NEXT:    ret i32 [[R]]
;
  %a.ext = zext i1 %a to i32
  %r = select i1 %cc, i32 %a.ext, i32 -1
  ret i32 %r
}

define i32 @test_bits_sext(i8 %a, i1 %cc) {
; CHECK-LABEL: @test_bits_sext(
; CHECK-NEXT:    [[A_EXT:%.*]] = sext i8 %a to i32
; CHECK-NEXT:    [[R:%.*]] = select i1 %cc, i32 [[A_EXT]], i32 -128
; CHECK-NEXT:    ret i32 [[R]]
;
  %a.ext = sext i8 %a to i32
  %r = select i1 %cc, i32 %a.ext, i32 -128
  ret i32 %r
}

define i32 @test_bits_zext(i8 %a, i1 %cc) {
; CHECK-LABEL: @test_bits_zext(
; CHECK-NEXT:    [[A_EXT:%.*]] = zext i8 %a to i32
; CHECK-NEXT:    [[R:%.*]] = select i1 %cc, i32 [[A_EXT]], i32 255
; CHECK-NEXT:    ret i32 [[R]]
;
  %a.ext = zext i8 %a to i32
  %r = select i1 %cc, i32 %a.ext, i32 255
  ret i32 %r
}

define i32 @test_op_op(i32 %a, i32 %b, i32 %c) {
; CHECK-LABEL: @test_op_op(
; CHECK-NEXT:    [[CCA:%.*]] = icmp sgt i32 %a, 0
; CHECK-NEXT:    [[CCB:%.*]] = icmp sgt i32 %b, 0
; CHECK-NEXT:    [[CCC:%.*]] = icmp sgt i32 %c, 0
; CHECK-NEXT:    [[R_V:%.*]] = select i1 [[CCC]], i1 [[CCA]], i1 [[CCB]]
; CHECK-NEXT:    [[R:%.*]] = sext i1 [[R:%.*]].v to i32
; CHECK-NEXT:    ret i32 [[R]]
;
  %cca = icmp sgt i32 %a, 0
  %ccax = sext i1 %cca to i32
  %ccb = icmp sgt i32 %b, 0
  %ccbx = sext i1 %ccb to i32
  %ccc = icmp sgt i32 %c, 0
  %r = select i1 %ccc, i32 %ccax, i32 %ccbx
  ret i32 %r
}

define <2 x i32> @test_vectors_sext(<2 x i1> %cca, <2 x i1> %ccb) {
; CHECK-LABEL: @test_vectors_sext(
; CHECK-NEXT:    [[FOLD_R:%.*]] = and <2 x i1> %ccb, %cca
; CHECK-NEXT:    [[R:%.*]] = sext <2 x i1> [[FOLD_R]] to <2 x i32>
; CHECK-NEXT:    ret <2 x i32> [[R]]
;
  %ccax = sext <2 x i1> %cca to <2 x i32>
  %r = select <2 x i1> %ccb, <2 x i32> %ccax, <2 x i32> <i32 0, i32 0>
  ret <2 x i32> %r
}

define <2 x i32> @test_vectors_sext_nonsplat(<2 x i1> %cca, <2 x i1> %ccb) {
; CHECK-LABEL: @test_vectors_sext_nonsplat(
; CHECK-NEXT:    [[NARROW:%.*]] = select <2 x i1> %ccb, <2 x i1> %cca, <2 x i1> <i1 false, i1 true>
; CHECK-NEXT:    [[R:%.*]] = sext <2 x i1> [[NARROW]] to <2 x i32>
; CHECK-NEXT:    ret <2 x i32> [[R]]
;
  %ccax = sext <2 x i1> %cca to <2 x i32>
  %r = select <2 x i1> %ccb, <2 x i32> %ccax, <2 x i32> <i32 0, i32 -1>
  ret <2 x i32> %r
}

define <2 x i32> @test_vectors_zext(<2 x i1> %cca, <2 x i1> %ccb) {
; CHECK-LABEL: @test_vectors_zext(
; CHECK-NEXT:    [[FOLD_R:%.*]] = and <2 x i1> %ccb, %cca
; CHECK-NEXT:    [[R:%.*]] = zext <2 x i1> [[FOLD_R]] to <2 x i32>
; CHECK-NEXT:    ret <2 x i32> [[R]]
;
  %ccax = zext <2 x i1> %cca to <2 x i32>
  %r = select <2 x i1> %ccb, <2 x i32> %ccax, <2 x i32> <i32 0, i32 0>
  ret <2 x i32> %r
}

define <2 x i32> @test_vectors_zext_nonsplat(<2 x i1> %cca, <2 x i1> %ccb) {
; CHECK-LABEL: @test_vectors_zext_nonsplat(
; CHECK-NEXT:    [[NARROW:%.*]] = select <2 x i1> %ccb, <2 x i1> %cca, <2 x i1> <i1 true, i1 false>
; CHECK-NEXT:    [[R:%.*]] = zext <2 x i1> [[NARROW]] to <2 x i32>
; CHECK-NEXT:    ret <2 x i32> [[R]]
;
  %ccax = zext <2 x i1> %cca to <2 x i32>
  %r = select <2 x i1> %ccb, <2 x i32> %ccax, <2 x i32> <i32 1, i32 0>
  ret <2 x i32> %r
}

define <2 x i32> @scalar_select_of_vectors_sext(<2 x i1> %cca, i1 %ccb) {
; CHECK-LABEL: @scalar_select_of_vectors_sext(
; CHECK-NEXT:    [[FOLD_R:%.*]] = select i1 %ccb, <2 x i1> %cca, <2 x i1> zeroinitializer
; CHECK-NEXT:    [[R:%.*]] = sext <2 x i1> [[FOLD_R]] to <2 x i32>
; CHECK-NEXT:    ret <2 x i32> [[R]]
;
  %ccax = sext <2 x i1> %cca to <2 x i32>
  %r = select i1 %ccb, <2 x i32> %ccax, <2 x i32> <i32 0, i32 0>
  ret <2 x i32> %r
}

define <2 x i32> @scalar_select_of_vectors_zext(<2 x i1> %cca, i1 %ccb) {
; CHECK-LABEL: @scalar_select_of_vectors_zext(
; CHECK-NEXT:    [[FOLD_R:%.*]] = select i1 %ccb, <2 x i1> %cca, <2 x i1> zeroinitializer
; CHECK-NEXT:    [[R:%.*]] = zext <2 x i1> [[FOLD_R]] to <2 x i32>
; CHECK-NEXT:    ret <2 x i32> [[R]]
;
  %ccax = zext <2 x i1> %cca to <2 x i32>
  %r = select i1 %ccb, <2 x i32> %ccax, <2 x i32> <i32 0, i32 0>
  ret <2 x i32> %r
}

define i32 @sext_true_val_must_be_all_ones(i1 %x) {
; CHECK-LABEL: @sext_true_val_must_be_all_ones(
; CHECK-NEXT:    [[SEL:%.*]] = select i1 %x, i32 -1, i32 42, !prof !0
; CHECK-NEXT:    ret i32 [[SEL]]
;
  %ext = sext i1 %x to i32
  %sel = select i1 %x, i32 %ext, i32 42, !prof !0
  ret i32 %sel
}

define <2 x i32> @sext_true_val_must_be_all_ones_vec(<2 x i1> %x) {
; CHECK-LABEL: @sext_true_val_must_be_all_ones_vec(
; CHECK-NEXT:    [[SEL:%.*]] = select <2 x i1> %x, <2 x i32> <i32 -1, i32 -1>, <2 x i32> <i32 42, i32 12>, !prof !0
; CHECK-NEXT:    ret <2 x i32> [[SEL]]
;
  %ext = sext <2 x i1> %x to <2 x i32>
  %sel = select <2 x i1> %x, <2 x i32> %ext, <2 x i32> <i32 42, i32 12>, !prof !0
  ret <2 x i32> %sel
}

define i32 @zext_true_val_must_be_one(i1 %x) {
; CHECK-LABEL: @zext_true_val_must_be_one(
; CHECK-NEXT:    [[SEL:%.*]] = select i1 %x, i32 1, i32 42, !prof !0
; CHECK-NEXT:    ret i32 [[SEL]]
;
  %ext = zext i1 %x to i32
  %sel = select i1 %x, i32 %ext, i32 42, !prof !0
  ret i32 %sel
}

define <2 x i32> @zext_true_val_must_be_one_vec(<2 x i1> %x) {
; CHECK-LABEL: @zext_true_val_must_be_one_vec(
; CHECK-NEXT:    [[SEL:%.*]] = select <2 x i1> %x, <2 x i32> <i32 1, i32 1>, <2 x i32> <i32 42, i32 12>, !prof !0
; CHECK-NEXT:    ret <2 x i32> [[SEL]]
;
  %ext = zext <2 x i1> %x to <2 x i32>
  %sel = select <2 x i1> %x, <2 x i32> %ext, <2 x i32> <i32 42, i32 12>, !prof !0
  ret <2 x i32> %sel
}

define i32 @sext_false_val_must_be_zero(i1 %x) {
; CHECK-LABEL: @sext_false_val_must_be_zero(
; CHECK-NEXT:    [[SEL:%.*]] = select i1 %x, i32 42, i32 0, !prof !0
; CHECK-NEXT:    ret i32 [[SEL]]
;
  %ext = sext i1 %x to i32
  %sel = select i1 %x, i32 42, i32 %ext, !prof !0
  ret i32 %sel
}

define <2 x i32> @sext_false_val_must_be_zero_vec(<2 x i1> %x) {
; CHECK-LABEL: @sext_false_val_must_be_zero_vec(
; CHECK-NEXT:    [[SEL:%.*]] = select <2 x i1> %x, <2 x i32> <i32 42, i32 12>, <2 x i32> zeroinitializer, !prof !0
; CHECK-NEXT:    ret <2 x i32> [[SEL]]
;
  %ext = sext <2 x i1> %x to <2 x i32>
  %sel = select <2 x i1> %x, <2 x i32> <i32 42, i32 12>, <2 x i32> %ext, !prof !0
  ret <2 x i32> %sel
}

define i32 @zext_false_val_must_be_zero(i1 %x) {
; CHECK-LABEL: @zext_false_val_must_be_zero(
; CHECK-NEXT:    [[SEL:%.*]] = select i1 %x, i32 42, i32 0, !prof !0
; CHECK-NEXT:    ret i32 [[SEL]]
;
  %ext = zext i1 %x to i32
  %sel = select i1 %x, i32 42, i32 %ext, !prof !0
  ret i32 %sel
}

define <2 x i32> @zext_false_val_must_be_zero_vec(<2 x i1> %x) {
; CHECK-LABEL: @zext_false_val_must_be_zero_vec(
; CHECK-NEXT:    [[SEL:%.*]] = select <2 x i1> %x, <2 x i32> <i32 42, i32 12>, <2 x i32> zeroinitializer, !prof !0
; CHECK-NEXT:    ret <2 x i32> [[SEL]]
;
  %ext = zext <2 x i1> %x to <2 x i32>
  %sel = select <2 x i1> %x, <2 x i32> <i32 42, i32 12>, <2 x i32> %ext, !prof !0
  ret <2 x i32> %sel
}

!0 = !{!"branch_weights", i32 3, i32 5}

