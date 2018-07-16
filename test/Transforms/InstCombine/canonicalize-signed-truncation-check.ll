; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -instcombine -S | FileCheck %s

; https://bugs.llvm.org/show_bug.cgi?id=38149

; Pattern:
;   ((%x << MaskedBits) a>> MaskedBits) != %x
; Should be transformed into:
;   (add %x, (1 << (KeptBits-1))) u>= (1 << KeptBits)
; Where  KeptBits = bitwidth(%x) - MaskedBits

; ============================================================================ ;
; Basic positive tests
; ============================================================================ ;

define i1 @p0(i8 %x) {
; CHECK-LABEL: @p0(
; CHECK-NEXT:    [[TMP1:%.*]] = add i8 [[X:%.*]], 8
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ugt i8 [[TMP1]], 15
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %tmp0 = shl i8 %x, 4
  %tmp1 = ashr exact i8 %tmp0, 4
  %tmp2 = icmp ne i8 %tmp1, %x
  ret i1 %tmp2
}

; ============================================================================ ;
; Vector tests
; ============================================================================ ;

define <2 x i1> @p1_vec_splat(<2 x i8> %x) {
; CHECK-LABEL: @p1_vec_splat(
; CHECK-NEXT:    [[TMP1:%.*]] = add <2 x i8> [[X:%.*]], <i8 8, i8 8>
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ugt <2 x i8> [[TMP1]], <i8 15, i8 15>
; CHECK-NEXT:    ret <2 x i1> [[TMP2]]
;
  %tmp0 = shl <2 x i8> %x, <i8 4, i8 4>
  %tmp1 = ashr exact <2 x i8> %tmp0, <i8 4, i8 4>
  %tmp2 = icmp ne <2 x i8> %tmp1, %x
  ret <2 x i1> %tmp2
}

define <2 x i1> @p2_vec_nonsplat(<2 x i8> %x) {
; CHECK-LABEL: @p2_vec_nonsplat(
; CHECK-NEXT:    [[TMP0:%.*]] = shl <2 x i8> [[X:%.*]], <i8 4, i8 5>
; CHECK-NEXT:    [[TMP1:%.*]] = ashr exact <2 x i8> [[TMP0]], <i8 4, i8 5>
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ne <2 x i8> [[TMP1]], [[X]]
; CHECK-NEXT:    ret <2 x i1> [[TMP2]]
;
  %tmp0 = shl <2 x i8> %x, <i8 4, i8 5>
  %tmp1 = ashr exact <2 x i8> %tmp0, <i8 4, i8 5>
  %tmp2 = icmp ne <2 x i8> %tmp1, %x
  ret <2 x i1> %tmp2
}

define <3 x i1> @p3_vec_undef0(<3 x i8> %x) {
; CHECK-LABEL: @p3_vec_undef0(
; CHECK-NEXT:    [[TMP0:%.*]] = shl <3 x i8> [[X:%.*]], <i8 4, i8 undef, i8 4>
; CHECK-NEXT:    [[TMP1:%.*]] = ashr exact <3 x i8> [[TMP0]], <i8 4, i8 4, i8 4>
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ne <3 x i8> [[TMP1]], [[X]]
; CHECK-NEXT:    ret <3 x i1> [[TMP2]]
;
  %tmp0 = shl <3 x i8> %x, <i8 4, i8 undef, i8 4>
  %tmp1 = ashr exact <3 x i8> %tmp0, <i8 4, i8 4, i8 4>
  %tmp2 = icmp ne <3 x i8> %tmp1, %x
  ret <3 x i1> %tmp2
}

define <3 x i1> @p4_vec_undef1(<3 x i8> %x) {
; CHECK-LABEL: @p4_vec_undef1(
; CHECK-NEXT:    [[TMP0:%.*]] = shl <3 x i8> [[X:%.*]], <i8 4, i8 4, i8 4>
; CHECK-NEXT:    [[TMP1:%.*]] = ashr exact <3 x i8> [[TMP0]], <i8 4, i8 undef, i8 4>
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ne <3 x i8> [[TMP1]], [[X]]
; CHECK-NEXT:    ret <3 x i1> [[TMP2]]
;
  %tmp0 = shl <3 x i8> %x, <i8 4, i8 4, i8 4>
  %tmp1 = ashr exact <3 x i8> %tmp0, <i8 4, i8 undef, i8 4>
  %tmp2 = icmp ne <3 x i8> %tmp1, %x
  ret <3 x i1> %tmp2
}

define <3 x i1> @p5_vec_undef2(<3 x i8> %x) {
; CHECK-LABEL: @p5_vec_undef2(
; CHECK-NEXT:    [[TMP0:%.*]] = shl <3 x i8> [[X:%.*]], <i8 4, i8 undef, i8 4>
; CHECK-NEXT:    [[TMP1:%.*]] = ashr exact <3 x i8> [[TMP0]], <i8 4, i8 undef, i8 4>
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ne <3 x i8> [[TMP1]], [[X]]
; CHECK-NEXT:    ret <3 x i1> [[TMP2]]
;
  %tmp0 = shl <3 x i8> %x, <i8 4, i8 undef, i8 4>
  %tmp1 = ashr exact <3 x i8> %tmp0, <i8 4, i8 undef, i8 4>
  %tmp2 = icmp ne <3 x i8> %tmp1, %x
  ret <3 x i1> %tmp2
}

; ============================================================================ ;
; Commutativity tests.
; ============================================================================ ;

declare i8 @gen8()

define i1 @c0() {
; CHECK-LABEL: @c0(
; CHECK-NEXT:    [[X:%.*]] = call i8 @gen8()
; CHECK-NEXT:    [[TMP1:%.*]] = add i8 [[X]], 8
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ugt i8 [[TMP1]], 15
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %x = call i8 @gen8()
  %tmp0 = shl i8 %x, 4
  %tmp1 = ashr exact i8 %tmp0, 4
  %tmp2 = icmp ne i8 %x, %tmp1 ; swapped order
  ret i1 %tmp2
}

; ============================================================================ ;
; One-use tests.
; ============================================================================ ;

declare void @use8(i8)

define i1 @n_oneuse0(i8 %x) {
; CHECK-LABEL: @n_oneuse0(
; CHECK-NEXT:    [[TMP0:%.*]] = shl i8 [[X:%.*]], 4
; CHECK-NEXT:    call void @use8(i8 [[TMP0]])
; CHECK-NEXT:    [[TMP1:%.*]] = add i8 [[X]], 8
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ugt i8 [[TMP1]], 15
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %tmp0 = shl i8 %x, 4
  call void @use8(i8 %tmp0)
  %tmp1 = ashr exact i8 %tmp0, 4
  %tmp2 = icmp ne i8 %tmp1, %x
  ret i1 %tmp2
}

define i1 @n_oneuse1(i8 %x) {
; CHECK-LABEL: @n_oneuse1(
; CHECK-NEXT:    [[TMP0:%.*]] = shl i8 [[X:%.*]], 4
; CHECK-NEXT:    [[TMP1:%.*]] = ashr exact i8 [[TMP0]], 4
; CHECK-NEXT:    call void @use8(i8 [[TMP1]])
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ne i8 [[TMP1]], [[X]]
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %tmp0 = shl i8 %x, 4
  %tmp1 = ashr exact i8 %tmp0, 4
  call void @use8(i8 %tmp1)
  %tmp2 = icmp ne i8 %tmp1, %x
  ret i1 %tmp2
}

define i1 @n_oneuse2(i8 %x) {
; CHECK-LABEL: @n_oneuse2(
; CHECK-NEXT:    [[TMP0:%.*]] = shl i8 [[X:%.*]], 4
; CHECK-NEXT:    call void @use8(i8 [[TMP0]])
; CHECK-NEXT:    [[TMP1:%.*]] = ashr exact i8 [[TMP0]], 4
; CHECK-NEXT:    call void @use8(i8 [[TMP1]])
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ne i8 [[TMP1]], [[X]]
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %tmp0 = shl i8 %x, 4
  call void @use8(i8 %tmp0)
  %tmp1 = ashr exact i8 %tmp0, 4
  call void @use8(i8 %tmp1)
  %tmp2 = icmp ne i8 %tmp1, %x
  ret i1 %tmp2
}

; ============================================================================ ;
; Negative tests
; ============================================================================ ;

define i1 @n0(i8 %x) {
; CHECK-LABEL: @n0(
; CHECK-NEXT:    [[TMP0:%.*]] = shl i8 [[X:%.*]], 4
; CHECK-NEXT:    [[TMP1:%.*]] = ashr exact i8 [[TMP0]], 3
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ne i8 [[TMP1]], [[X]]
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %tmp0 = shl i8 %x, 4
  %tmp1 = ashr exact i8 %tmp0, 3 ; not 4
  %tmp2 = icmp ne i8 %tmp1, %x
  ret i1 %tmp2
}

define i1 @n1(i8 %x) {
; CHECK-LABEL: @n1(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ugt i8 [[X:%.*]], 15
; CHECK-NEXT:    ret i1 [[TMP1]]
;
  %tmp0 = shl i8 %x, 4
  %tmp1 = lshr exact i8 %tmp0, 4 ; not ashr
  %tmp2 = icmp ne i8 %tmp1, %x
  ret i1 %tmp2
}

define i1 @n2(i8 %x, i8 %y) {
; CHECK-LABEL: @n2(
; CHECK-NEXT:    [[TMP0:%.*]] = shl i8 [[X:%.*]], 4
; CHECK-NEXT:    [[TMP1:%.*]] = ashr exact i8 [[TMP0]], 4
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ne i8 [[TMP1]], [[Y:%.*]]
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %tmp0 = shl i8 %x, 4
  %tmp1 = ashr exact i8 %tmp0, 4
  %tmp2 = icmp ne i8 %tmp1, %y ; not %x
  ret i1 %tmp2
}

define <2 x i1> @n3_vec_nonsplat(<2 x i8> %x) {
; CHECK-LABEL: @n3_vec_nonsplat(
; CHECK-NEXT:    [[TMP0:%.*]] = shl <2 x i8> [[X:%.*]], <i8 4, i8 4>
; CHECK-NEXT:    [[TMP1:%.*]] = ashr exact <2 x i8> [[TMP0]], <i8 4, i8 3>
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ne <2 x i8> [[TMP1]], [[X]]
; CHECK-NEXT:    ret <2 x i1> [[TMP2]]
;
  %tmp0 = shl <2 x i8> %x, <i8 4, i8 4>
  %tmp1 = ashr exact <2 x i8> %tmp0, <i8 4, i8 3> ; 3 instead of 4
  %tmp2 = icmp ne <2 x i8> %tmp1, %x
  ret <2 x i1> %tmp2
}
