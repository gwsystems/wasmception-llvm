; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -instcombine -S | FileCheck %s

; https://bugs.llvm.org/show_bug.cgi?id=37603
; https://reviews.llvm.org/D46760#1123713

; Pattern:
;   x >> y << y
; Should be transformed into:
;   x & (-1 << y)

; ============================================================================ ;
; Basic positive tests
; ============================================================================ ;

define i32 @positive_samevar(i32 %x, i32 %y) {
; CHECK-LABEL: @positive_samevar(
; CHECK-NEXT:    [[TMP0:%.*]] = lshr i32 [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[RET:%.*]] = shl i32 [[TMP0]], [[Y]]
; CHECK-NEXT:    ret i32 [[RET]]
;
  %tmp0 = lshr i32 %x, %y
  %ret = shl i32 %tmp0, %y
  ret i32 %ret
}

define i32 @positive_sameconst(i32 %x) {
; CHECK-LABEL: @positive_sameconst(
; CHECK-NEXT:    [[TMP0:%.*]] = and i32 [[X:%.*]], -32
; CHECK-NEXT:    ret i32 [[TMP0]]
;
  %tmp0 = lshr i32 %x, 5
  %ret = shl i32 %tmp0, 5
  ret i32 %ret
}

define i32 @positive_biggerlshr(i32 %x) {
; CHECK-LABEL: @positive_biggerlshr(
; CHECK-NEXT:    [[TMP0:%.*]] = lshr i32 [[X:%.*]], 10
; CHECK-NEXT:    [[RET:%.*]] = shl nuw nsw i32 [[TMP0]], 5
; CHECK-NEXT:    ret i32 [[RET]]
;
  %tmp0 = lshr i32 %x, 10
  %ret = shl i32 %tmp0, 5
  ret i32 %ret
}

define i32 @positive_biggershl(i32 %x) {
; CHECK-LABEL: @positive_biggershl(
; CHECK-NEXT:    [[TMP0:%.*]] = lshr i32 [[X:%.*]], 5
; CHECK-NEXT:    [[RET:%.*]] = shl i32 [[TMP0]], 10
; CHECK-NEXT:    ret i32 [[RET]]
;
  %tmp0 = lshr i32 %x, 5
  %ret = shl i32 %tmp0, 10
  ret i32 %ret
}

; ============================================================================ ;
; EXACT on the first shift
; ============================================================================ ;

define i32 @positive_samevar_lshrexact(i32 %x, i32 %y) {
; CHECK-LABEL: @positive_samevar_lshrexact(
; CHECK-NEXT:    ret i32 [[X:%.*]]
;
  %tmp0 = lshr exact i32 %x, %y
  %ret = shl i32 %tmp0, %y ; this one is obviously 'nuw'.
  ret i32 %ret
}

define i32 @positive_sameconst_lshrexact(i32 %x) {
; CHECK-LABEL: @positive_sameconst_lshrexact(
; CHECK-NEXT:    ret i32 [[X:%.*]]
;
  %tmp0 = lshr exact i32 %x, 5
  %ret = shl i32 %tmp0, 5 ; this one is obviously 'nuw'.
  ret i32 %ret
}

define i32 @positive_biggerlshr_lshrexact(i32 %x) {
; CHECK-LABEL: @positive_biggerlshr_lshrexact(
; CHECK-NEXT:    [[RET:%.*]] = lshr exact i32 [[X:%.*]], 5
; CHECK-NEXT:    ret i32 [[RET]]
;
  %tmp0 = lshr exact i32 %x, 10
  %ret = shl i32 %tmp0, 5 ; this one is obviously 'nuw'.
  ret i32 %ret
}

define i32 @positive_biggershl_lshrexact(i32 %x) {
; CHECK-LABEL: @positive_biggershl_lshrexact(
; CHECK-NEXT:    [[RET:%.*]] = shl i32 [[X:%.*]], 5
; CHECK-NEXT:    ret i32 [[RET]]
;
  %tmp0 = lshr exact i32 %x, 5
  %ret = shl i32 %tmp0, 10
  ret i32 %ret
}

define i32 @positive_biggershl_lshrexact_shlexact(i32 %x) {
; CHECK-LABEL: @positive_biggershl_lshrexact_shlexact(
; CHECK-NEXT:    [[RET:%.*]] = shl nuw i32 [[X:%.*]], 5
; CHECK-NEXT:    ret i32 [[RET]]
;
  %tmp0 = lshr exact i32 %x, 5
  %ret = shl nuw i32 %tmp0, 10
  ret i32 %ret
}

; ============================================================================ ;
; Vector
; ============================================================================ ;

define <2 x i32> @positive_samevar_vec(<2 x i32> %x, <2 x i32> %y) {
; CHECK-LABEL: @positive_samevar_vec(
; CHECK-NEXT:    [[TMP0:%.*]] = lshr <2 x i32> [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[RET:%.*]] = shl <2 x i32> [[TMP0]], [[Y]]
; CHECK-NEXT:    ret <2 x i32> [[RET]]
;
  %tmp0 = lshr <2 x i32> %x, %y
  %ret = shl <2 x i32> %tmp0, %y
  ret <2 x i32> %ret
}

; ============================================================================ ;
; Constant Vectors
; ============================================================================ ;

define <2 x i32> @positive_sameconst_vec(<2 x i32> %x) {
; CHECK-LABEL: @positive_sameconst_vec(
; CHECK-NEXT:    [[TMP0:%.*]] = and <2 x i32> [[X:%.*]], <i32 -32, i32 -32>
; CHECK-NEXT:    ret <2 x i32> [[TMP0]]
;
  %tmp0 = lshr <2 x i32> %x, <i32 5, i32 5>
  %ret = shl <2 x i32> %tmp0, <i32 5, i32 5>
  ret <2 x i32> %ret
}

define <3 x i32> @positive_sameconst_vec_undef0(<3 x i32> %x) {
; CHECK-LABEL: @positive_sameconst_vec_undef0(
; CHECK-NEXT:    [[TMP0:%.*]] = lshr <3 x i32> [[X:%.*]], <i32 5, i32 undef, i32 5>
; CHECK-NEXT:    [[RET:%.*]] = shl <3 x i32> [[TMP0]], <i32 5, i32 5, i32 5>
; CHECK-NEXT:    ret <3 x i32> [[RET]]
;
  %tmp0 = lshr <3 x i32> %x, <i32 5, i32 undef, i32 5>
  %ret = shl <3 x i32> %tmp0, <i32 5, i32 5, i32 5>
  ret <3 x i32> %ret
}

define <3 x i32> @positive_sameconst_vec_undef1(<3 x i32> %x) {
; CHECK-LABEL: @positive_sameconst_vec_undef1(
; CHECK-NEXT:    [[TMP0:%.*]] = lshr <3 x i32> [[X:%.*]], <i32 5, i32 5, i32 5>
; CHECK-NEXT:    [[RET:%.*]] = shl <3 x i32> [[TMP0]], <i32 5, i32 undef, i32 5>
; CHECK-NEXT:    ret <3 x i32> [[RET]]
;
  %tmp0 = lshr <3 x i32> %x, <i32 5, i32 5, i32 5>
  %ret = shl <3 x i32> %tmp0, <i32 5, i32 undef, i32 5>
  ret <3 x i32> %ret
}

define <3 x i32> @positive_sameconst_vec_undef2(<3 x i32> %x) {
; CHECK-LABEL: @positive_sameconst_vec_undef2(
; CHECK-NEXT:    [[TMP0:%.*]] = lshr <3 x i32> [[X:%.*]], <i32 5, i32 undef, i32 5>
; CHECK-NEXT:    [[RET:%.*]] = shl <3 x i32> [[TMP0]], <i32 5, i32 undef, i32 5>
; CHECK-NEXT:    ret <3 x i32> [[RET]]
;
  %tmp0 = lshr <3 x i32> %x, <i32 5, i32 undef, i32 5>
  %ret = shl <3 x i32> %tmp0, <i32 5, i32 undef, i32 5>
  ret <3 x i32> %ret
}

define <2 x i32> @positive_biggerlshr_vec(<2 x i32> %x) {
; CHECK-LABEL: @positive_biggerlshr_vec(
; CHECK-NEXT:    [[TMP0:%.*]] = lshr <2 x i32> [[X:%.*]], <i32 10, i32 10>
; CHECK-NEXT:    [[RET:%.*]] = shl nuw nsw <2 x i32> [[TMP0]], <i32 5, i32 5>
; CHECK-NEXT:    ret <2 x i32> [[RET]]
;
  %tmp0 = lshr <2 x i32> %x, <i32 10, i32 10>
  %ret = shl <2 x i32> %tmp0, <i32 5, i32 5>
  ret <2 x i32> %ret
}

define <3 x i32> @positive_biggerlshr_vec_undef0(<3 x i32> %x) {
; CHECK-LABEL: @positive_biggerlshr_vec_undef0(
; CHECK-NEXT:    [[TMP0:%.*]] = lshr <3 x i32> [[X:%.*]], <i32 10, i32 undef, i32 10>
; CHECK-NEXT:    [[RET:%.*]] = shl <3 x i32> [[TMP0]], <i32 5, i32 5, i32 5>
; CHECK-NEXT:    ret <3 x i32> [[RET]]
;
  %tmp0 = lshr <3 x i32> %x, <i32 10, i32 undef, i32 10>
  %ret = shl <3 x i32> %tmp0, <i32 5, i32 5, i32 5>
  ret <3 x i32> %ret
}

define <3 x i32> @positive_biggerlshr_vec_undef1(<3 x i32> %x) {
; CHECK-LABEL: @positive_biggerlshr_vec_undef1(
; CHECK-NEXT:    [[TMP0:%.*]] = lshr <3 x i32> [[X:%.*]], <i32 10, i32 10, i32 10>
; CHECK-NEXT:    [[RET:%.*]] = shl <3 x i32> [[TMP0]], <i32 5, i32 undef, i32 5>
; CHECK-NEXT:    ret <3 x i32> [[RET]]
;
  %tmp0 = lshr <3 x i32> %x, <i32 10, i32 10, i32 10>
  %ret = shl <3 x i32> %tmp0, <i32 5, i32 undef, i32 5>
  ret <3 x i32> %ret
}

define <3 x i32> @positive_biggerlshr_vec_undef2(<3 x i32> %x) {
; CHECK-LABEL: @positive_biggerlshr_vec_undef2(
; CHECK-NEXT:    [[TMP0:%.*]] = lshr <3 x i32> [[X:%.*]], <i32 10, i32 undef, i32 10>
; CHECK-NEXT:    [[RET:%.*]] = shl <3 x i32> [[TMP0]], <i32 5, i32 undef, i32 5>
; CHECK-NEXT:    ret <3 x i32> [[RET]]
;
  %tmp0 = lshr <3 x i32> %x, <i32 10, i32 undef, i32 10>
  %ret = shl <3 x i32> %tmp0, <i32 5, i32 undef, i32 5>
  ret <3 x i32> %ret
}

define <2 x i32> @positive_biggershl_vec(<2 x i32> %x) {
; CHECK-LABEL: @positive_biggershl_vec(
; CHECK-NEXT:    [[TMP0:%.*]] = lshr <2 x i32> [[X:%.*]], <i32 5, i32 5>
; CHECK-NEXT:    [[RET:%.*]] = shl <2 x i32> [[TMP0]], <i32 10, i32 10>
; CHECK-NEXT:    ret <2 x i32> [[RET]]
;
  %tmp0 = lshr <2 x i32> %x, <i32 5, i32 5>
  %ret = shl <2 x i32> %tmp0, <i32 10, i32 10>
  ret <2 x i32> %ret
}

define <3 x i32> @positive_biggershl_vec_undef0(<3 x i32> %x) {
; CHECK-LABEL: @positive_biggershl_vec_undef0(
; CHECK-NEXT:    [[TMP0:%.*]] = lshr <3 x i32> [[X:%.*]], <i32 5, i32 undef, i32 5>
; CHECK-NEXT:    [[RET:%.*]] = shl <3 x i32> [[TMP0]], <i32 10, i32 10, i32 10>
; CHECK-NEXT:    ret <3 x i32> [[RET]]
;
  %tmp0 = lshr <3 x i32> %x, <i32 5, i32 undef, i32 5>
  %ret = shl <3 x i32> %tmp0, <i32 10, i32 10, i32 10>
  ret <3 x i32> %ret
}

define <3 x i32> @positive_biggershl_vec_undef1(<3 x i32> %x) {
; CHECK-LABEL: @positive_biggershl_vec_undef1(
; CHECK-NEXT:    [[TMP0:%.*]] = lshr <3 x i32> [[X:%.*]], <i32 5, i32 5, i32 5>
; CHECK-NEXT:    [[RET:%.*]] = shl <3 x i32> [[TMP0]], <i32 10, i32 undef, i32 10>
; CHECK-NEXT:    ret <3 x i32> [[RET]]
;
  %tmp0 = lshr <3 x i32> %x, <i32 5, i32 5, i32 5>
  %ret = shl <3 x i32> %tmp0, <i32 10, i32 undef, i32 10>
  ret <3 x i32> %ret
}

define <3 x i32> @positive_biggershl_vec_undef2(<3 x i32> %x) {
; CHECK-LABEL: @positive_biggershl_vec_undef2(
; CHECK-NEXT:    [[TMP0:%.*]] = lshr <3 x i32> [[X:%.*]], <i32 5, i32 undef, i32 5>
; CHECK-NEXT:    [[RET:%.*]] = shl <3 x i32> [[TMP0]], <i32 10, i32 undef, i32 10>
; CHECK-NEXT:    ret <3 x i32> [[RET]]
;
  %tmp0 = lshr <3 x i32> %x, <i32 5, i32 undef, i32 5>
  %ret = shl <3 x i32> %tmp0, <i32 10, i32 undef, i32 10>
  ret <3 x i32> %ret
}

; ============================================================================ ;
; Constant Non-Splat Vectors
; ============================================================================ ;

define <2 x i32> @positive_biggerlshr_vec_nonsplat(<2 x i32> %x) {
; CHECK-LABEL: @positive_biggerlshr_vec_nonsplat(
; CHECK-NEXT:    [[TMP0:%.*]] = lshr <2 x i32> [[X:%.*]], <i32 5, i32 5>
; CHECK-NEXT:    [[RET:%.*]] = shl <2 x i32> [[TMP0]], <i32 5, i32 10>
; CHECK-NEXT:    ret <2 x i32> [[RET]]
;
  %tmp0 = lshr <2 x i32> %x, <i32 5, i32 5>
  %ret = shl <2 x i32> %tmp0, <i32 5, i32 10>
  ret <2 x i32> %ret
}

define <2 x i32> @positive_biggerLlshr_vec_nonsplat(<2 x i32> %x) {
; CHECK-LABEL: @positive_biggerLlshr_vec_nonsplat(
; CHECK-NEXT:    [[TMP0:%.*]] = lshr <2 x i32> [[X:%.*]], <i32 5, i32 10>
; CHECK-NEXT:    [[RET:%.*]] = shl <2 x i32> [[TMP0]], <i32 5, i32 5>
; CHECK-NEXT:    ret <2 x i32> [[RET]]
;
  %tmp0 = lshr <2 x i32> %x, <i32 5, i32 10>
  %ret = shl <2 x i32> %tmp0, <i32 5, i32 5>
  ret <2 x i32> %ret
}

; ============================================================================ ;
; Negative tests. Should not be folded.
; ============================================================================ ;

define i32 @negative_twovars(i32 %x, i32 %y, i32 %z) {
; CHECK-LABEL: @negative_twovars(
; CHECK-NEXT:    [[TMP0:%.*]] = lshr i32 [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[RET:%.*]] = shl i32 [[TMP0]], [[Z:%.*]]
; CHECK-NEXT:    ret i32 [[RET]]
;
  %tmp0 = lshr i32 %x, %y
  %ret = shl i32 %tmp0, %z ; $z, not %y
  ret i32 %ret
}

declare void @use32(i32)

; One use only.
define i32 @negative_oneuse(i32 %x, i32 %y) {
; CHECK-LABEL: @negative_oneuse(
; CHECK-NEXT:    [[TMP0:%.*]] = lshr i32 [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    call void @use32(i32 [[TMP0]])
; CHECK-NEXT:    [[RET:%.*]] = shl i32 [[TMP0]], [[Y]]
; CHECK-NEXT:    ret i32 [[RET]]
;
  %tmp0 = lshr i32 %x, %y
  call void @use32(i32 %tmp0)
  %ret = shl i32 %tmp0, %y
  ret i32 %ret
}
