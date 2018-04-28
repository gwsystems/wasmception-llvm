; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -instcombine -S | FileCheck %s

; If we have a masked merge, in the form of: (M is not constant)
;   ((x ^ y) & ~M) ^ y
; We can de-invert the M:
;   ((x ^ y) & M) ^ x

define <2 x i4> @vector (<2 x i4> %x, <2 x i4> %y, <2 x i4> %m) {
; CHECK-LABEL: @vector(
; CHECK-NEXT:    [[IM:%.*]] = xor <2 x i4> [[M:%.*]], <i4 -1, i4 -1>
; CHECK-NEXT:    [[N0:%.*]] = xor <2 x i4> [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[N1:%.*]] = and <2 x i4> [[N0]], [[IM]]
; CHECK-NEXT:    [[R:%.*]] = xor <2 x i4> [[N1]], [[Y]]
; CHECK-NEXT:    ret <2 x i4> [[R]]
;
  %im = xor <2 x i4> %m, <i4 -1, i4 -1>
  %n0 = xor <2 x i4> %x, %y
  %n1 = and <2 x i4> %n0, %im
  %r  = xor <2 x i4> %n1, %y
  ret <2 x i4> %r
}

define <3 x i4> @vector_undef (<3 x i4> %x, <3 x i4> %y, <3 x i4> %m) {
; CHECK-LABEL: @vector_undef(
; CHECK-NEXT:    [[IM:%.*]] = xor <3 x i4> [[M:%.*]], <i4 -1, i4 undef, i4 -1>
; CHECK-NEXT:    [[N0:%.*]] = xor <3 x i4> [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[N1:%.*]] = and <3 x i4> [[N0]], [[IM]]
; CHECK-NEXT:    [[R:%.*]] = xor <3 x i4> [[N1]], [[Y]]
; CHECK-NEXT:    ret <3 x i4> [[R]]
;
  %im = xor <3 x i4> %m, <i4 -1, i4 undef, i4 -1>
  %n0 = xor <3 x i4> %x, %y
  %n1 = and <3 x i4> %n0, %im
  %r  = xor <3 x i4> %n1, %y
  ret <3 x i4> %r
}

; ============================================================================ ;
; Various cases with %x and/or %y being a constant
; ============================================================================ ;

define <2 x i4> @in_constant_varx_mone_invmask(<2 x i4> %x, <2 x i4> %mask) {
; CHECK-LABEL: @in_constant_varx_mone_invmask(
; CHECK-NEXT:    [[N1_DEMORGAN:%.*]] = or <2 x i4> [[X:%.*]], [[MASK:%.*]]
; CHECK-NEXT:    ret <2 x i4> [[N1_DEMORGAN]]
;
  %notmask = xor <2 x i4> %mask, <i4 -1, i4 -1>
  %n0 = xor <2 x i4> %x, <i4 -1, i4 -1> ; %x
  %n1 = and <2 x i4> %n0, %notmask
  %r = xor <2 x i4> %n1, <i4 -1, i4 -1>
  ret <2 x i4> %r
}

define <2 x i4> @in_constant_varx_6_invmask(<2 x i4> %x, <2 x i4> %mask) {
; CHECK-LABEL: @in_constant_varx_6_invmask(
; CHECK-NEXT:    [[NOTMASK:%.*]] = xor <2 x i4> [[MASK:%.*]], <i4 -1, i4 -1>
; CHECK-NEXT:    [[N0:%.*]] = xor <2 x i4> [[X:%.*]], <i4 6, i4 6>
; CHECK-NEXT:    [[N1:%.*]] = and <2 x i4> [[N0]], [[NOTMASK]]
; CHECK-NEXT:    [[R:%.*]] = xor <2 x i4> [[N1]], <i4 6, i4 6>
; CHECK-NEXT:    ret <2 x i4> [[R]]
;
  %notmask = xor <2 x i4> %mask, <i4 -1, i4 -1>
  %n0 = xor <2 x i4> %x, <i4 6, i4 6> ; %x
  %n1 = and <2 x i4> %n0, %notmask
  %r = xor <2 x i4> %n1, <i4 6, i4 6>
  ret <2 x i4> %r
}

define <2 x i4> @in_constant_varx_6_invmask_nonsplat(<2 x i4> %x, <2 x i4> %mask) {
; CHECK-LABEL: @in_constant_varx_6_invmask_nonsplat(
; CHECK-NEXT:    [[NOTMASK:%.*]] = xor <2 x i4> [[MASK:%.*]], <i4 -1, i4 -1>
; CHECK-NEXT:    [[N0:%.*]] = xor <2 x i4> [[X:%.*]], <i4 6, i4 7>
; CHECK-NEXT:    [[N1:%.*]] = and <2 x i4> [[N0]], [[NOTMASK]]
; CHECK-NEXT:    [[R:%.*]] = xor <2 x i4> [[N1]], <i4 6, i4 7>
; CHECK-NEXT:    ret <2 x i4> [[R]]
;
  %notmask = xor <2 x i4> %mask, <i4 -1, i4 -1>
  %n0 = xor <2 x i4> %x, <i4 6, i4 7> ; %x
  %n1 = and <2 x i4> %n0, %notmask
  %r = xor <2 x i4> %n1, <i4 6, i4 7>
  ret <2 x i4> %r
}

define <3 x i4> @in_constant_varx_6_invmask_undef(<3 x i4> %x, <3 x i4> %mask) {
; CHECK-LABEL: @in_constant_varx_6_invmask_undef(
; CHECK-NEXT:    [[NOTMASK:%.*]] = xor <3 x i4> [[MASK:%.*]], <i4 -1, i4 undef, i4 -1>
; CHECK-NEXT:    [[N0:%.*]] = xor <3 x i4> [[X:%.*]], <i4 6, i4 undef, i4 7>
; CHECK-NEXT:    [[N1:%.*]] = and <3 x i4> [[N0]], [[NOTMASK]]
; CHECK-NEXT:    [[R:%.*]] = xor <3 x i4> [[N1]], <i4 6, i4 undef, i4 7>
; CHECK-NEXT:    ret <3 x i4> [[R]]
;
  %notmask = xor <3 x i4> %mask, <i4 -1, i4 undef, i4 -1>
  %n0 = xor <3 x i4> %x, <i4 6, i4 undef, i4 7> ; %x
  %n1 = and <3 x i4> %n0, %notmask
  %r = xor <3 x i4> %n1, <i4 6, i4 undef, i4 7>
  ret <3 x i4> %r
}

define <2 x i4> @in_constant_mone_vary_invmask(<2 x i4> %y, <2 x i4> %mask) {
; CHECK-LABEL: @in_constant_mone_vary_invmask(
; CHECK-NEXT:    [[N1_DEMORGAN:%.*]] = or <2 x i4> [[Y:%.*]], [[MASK:%.*]]
; CHECK-NEXT:    [[N1:%.*]] = xor <2 x i4> [[N1_DEMORGAN]], <i4 -1, i4 -1>
; CHECK-NEXT:    [[R:%.*]] = xor <2 x i4> [[N1]], [[Y]]
; CHECK-NEXT:    ret <2 x i4> [[R]]
;
  %notmask = xor <2 x i4> %mask, <i4 -1, i4 -1>
  %n0 = xor <2 x i4> <i4 -1, i4 -1>, %y ; %x
  %n1 = and <2 x i4> %n0, %notmask
  %r = xor <2 x i4> %n1, %y
  ret <2 x i4> %r
}

define <2 x i4> @in_constant_6_vary_invmask(<2 x i4> %y, <2 x i4> %mask) {
; CHECK-LABEL: @in_constant_6_vary_invmask(
; CHECK-NEXT:    [[NOTMASK:%.*]] = xor <2 x i4> [[MASK:%.*]], <i4 -1, i4 -1>
; CHECK-NEXT:    [[N0:%.*]] = xor <2 x i4> [[Y:%.*]], <i4 6, i4 6>
; CHECK-NEXT:    [[N1:%.*]] = and <2 x i4> [[N0]], [[NOTMASK]]
; CHECK-NEXT:    [[R:%.*]] = xor <2 x i4> [[N1]], [[Y]]
; CHECK-NEXT:    ret <2 x i4> [[R]]
;
  %notmask = xor <2 x i4> %mask, <i4 -1, i4 -1>
  %n0 = xor <2 x i4> %y, <i4 6, i4 6> ; %x
  %n1 = and <2 x i4> %n0, %notmask
  %r = xor <2 x i4> %n1, %y
  ret <2 x i4> %r
}

define <2 x i4> @in_constant_6_vary_invmask_nonsplat(<2 x i4> %y, <2 x i4> %mask) {
; CHECK-LABEL: @in_constant_6_vary_invmask_nonsplat(
; CHECK-NEXT:    [[NOTMASK:%.*]] = xor <2 x i4> [[MASK:%.*]], <i4 -1, i4 -1>
; CHECK-NEXT:    [[N0:%.*]] = xor <2 x i4> [[Y:%.*]], <i4 6, i4 7>
; CHECK-NEXT:    [[N1:%.*]] = and <2 x i4> [[N0]], [[NOTMASK]]
; CHECK-NEXT:    [[R:%.*]] = xor <2 x i4> [[N1]], [[Y]]
; CHECK-NEXT:    ret <2 x i4> [[R]]
;
  %notmask = xor <2 x i4> %mask, <i4 -1, i4 -1>
  %n0 = xor <2 x i4> %y, <i4 6, i4 7> ; %x
  %n1 = and <2 x i4> %n0, %notmask
  %r = xor <2 x i4> %n1, %y
  ret <2 x i4> %r
}

define <3 x i4> @in_constant_6_vary_invmask_undef(<3 x i4> %y, <3 x i4> %mask) {
; CHECK-LABEL: @in_constant_6_vary_invmask_undef(
; CHECK-NEXT:    [[NOTMASK:%.*]] = xor <3 x i4> [[MASK:%.*]], <i4 -1, i4 undef, i4 -1>
; CHECK-NEXT:    [[N0:%.*]] = xor <3 x i4> [[Y:%.*]], <i4 6, i4 undef, i4 6>
; CHECK-NEXT:    [[N1:%.*]] = and <3 x i4> [[N0]], [[NOTMASK]]
; CHECK-NEXT:    [[R:%.*]] = xor <3 x i4> [[N1]], [[Y]]
; CHECK-NEXT:    ret <3 x i4> [[R]]
;
  %notmask = xor <3 x i4> %mask, <i4 -1, i4 undef, i4 -1>
  %n0 = xor <3 x i4> %y, <i4 6, i4 undef, i4 6> ; %x
  %n1 = and <3 x i4> %n0, %notmask
  %r = xor <3 x i4> %n1, %y
  ret <3 x i4> %r
}

; ============================================================================ ;
; Commutativity
; ============================================================================ ;

; Used to make sure that the IR complexity sorting does not interfere.
declare <2 x i4> @gen4()

; FIXME: should  %n1 = and <2 x i4> %im, %n0  swapped order pattern be tested?

define <2 x i4> @c_1_0_0 (<2 x i4> %x, <2 x i4> %y, <2 x i4> %m) {
; CHECK-LABEL: @c_1_0_0(
; CHECK-NEXT:    [[IM:%.*]] = xor <2 x i4> [[M:%.*]], <i4 -1, i4 -1>
; CHECK-NEXT:    [[N0:%.*]] = xor <2 x i4> [[Y:%.*]], [[X:%.*]]
; CHECK-NEXT:    [[N1:%.*]] = and <2 x i4> [[N0]], [[IM]]
; CHECK-NEXT:    [[R:%.*]] = xor <2 x i4> [[N1]], [[Y]]
; CHECK-NEXT:    ret <2 x i4> [[R]]
;
  %im = xor <2 x i4> %m, <i4 -1, i4 -1>
  %n0 = xor <2 x i4> %y, %x ; swapped order
  %n1 = and <2 x i4> %n0, %im
  %r  = xor <2 x i4> %n1, %y
  ret <2 x i4> %r
}

define <2 x i4> @c_0_1_0 (<2 x i4> %x, <2 x i4> %y, <2 x i4> %m) {
; CHECK-LABEL: @c_0_1_0(
; CHECK-NEXT:    [[IM:%.*]] = xor <2 x i4> [[M:%.*]], <i4 -1, i4 -1>
; CHECK-NEXT:    [[N0:%.*]] = xor <2 x i4> [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[N1:%.*]] = and <2 x i4> [[N0]], [[IM]]
; CHECK-NEXT:    [[R:%.*]] = xor <2 x i4> [[N1]], [[X]]
; CHECK-NEXT:    ret <2 x i4> [[R]]
;
  %im = xor <2 x i4> %m, <i4 -1, i4 -1>
  %n0 = xor <2 x i4> %x, %y
  %n1 = and <2 x i4> %n0, %im
  %r  = xor <2 x i4> %n1, %x ; %x instead of %y
  ret <2 x i4> %r
}

define <2 x i4> @c_0_0_1 (<2 x i4> %m) {
; CHECK-LABEL: @c_0_0_1(
; CHECK-NEXT:    [[IM:%.*]] = xor <2 x i4> [[M:%.*]], <i4 -1, i4 -1>
; CHECK-NEXT:    [[X:%.*]] = call <2 x i4> @gen4()
; CHECK-NEXT:    [[Y:%.*]] = call <2 x i4> @gen4()
; CHECK-NEXT:    [[N0:%.*]] = xor <2 x i4> [[X]], [[Y]]
; CHECK-NEXT:    [[N1:%.*]] = and <2 x i4> [[N0]], [[IM]]
; CHECK-NEXT:    [[R:%.*]] = xor <2 x i4> [[Y]], [[N1]]
; CHECK-NEXT:    ret <2 x i4> [[R]]
;
  %im = xor <2 x i4> %m, <i4 -1, i4 -1>
  %x  = call <2 x i4> @gen4()
  %y  = call <2 x i4> @gen4()
  %n0 = xor <2 x i4> %x, %y
  %n1 = and <2 x i4> %n0, %im
  %r  = xor <2 x i4> %y, %n1 ; swapped order
  ret <2 x i4> %r
}

define <2 x i4> @c_1_1_0 (<2 x i4> %x, <2 x i4> %y, <2 x i4> %m) {
; CHECK-LABEL: @c_1_1_0(
; CHECK-NEXT:    [[IM:%.*]] = xor <2 x i4> [[M:%.*]], <i4 -1, i4 -1>
; CHECK-NEXT:    [[N0:%.*]] = xor <2 x i4> [[Y:%.*]], [[X:%.*]]
; CHECK-NEXT:    [[N1:%.*]] = and <2 x i4> [[N0]], [[IM]]
; CHECK-NEXT:    [[R:%.*]] = xor <2 x i4> [[N1]], [[X]]
; CHECK-NEXT:    ret <2 x i4> [[R]]
;
  %im = xor <2 x i4> %m, <i4 -1, i4 -1>
  %n0 = xor <2 x i4> %y, %x ; swapped order
  %n1 = and <2 x i4> %n0, %im
  %r  = xor <2 x i4> %n1, %x ; %x instead of %y
  ret <2 x i4> %r
}

define <2 x i4> @c_1_0_1 (<2 x i4> %x, <2 x i4> %m) {
; CHECK-LABEL: @c_1_0_1(
; CHECK-NEXT:    [[IM:%.*]] = xor <2 x i4> [[M:%.*]], <i4 -1, i4 -1>
; CHECK-NEXT:    [[Y:%.*]] = call <2 x i4> @gen4()
; CHECK-NEXT:    [[N0:%.*]] = xor <2 x i4> [[Y]], [[X:%.*]]
; CHECK-NEXT:    [[N1:%.*]] = and <2 x i4> [[N0]], [[IM]]
; CHECK-NEXT:    [[R:%.*]] = xor <2 x i4> [[Y]], [[N1]]
; CHECK-NEXT:    ret <2 x i4> [[R]]
;
  %im = xor <2 x i4> %m, <i4 -1, i4 -1>
  %y  = call <2 x i4> @gen4()
  %n0 = xor <2 x i4> %y, %x ; swapped order
  %n1 = and <2 x i4> %n0, %im
  %r  = xor <2 x i4> %y, %n1 ; swapped order
  ret <2 x i4> %r
}

define <2 x i4> @c_0_1_1 (<2 x i4> %y, <2 x i4> %m) {
; CHECK-LABEL: @c_0_1_1(
; CHECK-NEXT:    [[IM:%.*]] = xor <2 x i4> [[M:%.*]], <i4 -1, i4 -1>
; CHECK-NEXT:    [[X:%.*]] = call <2 x i4> @gen4()
; CHECK-NEXT:    [[N0:%.*]] = xor <2 x i4> [[X]], [[Y:%.*]]
; CHECK-NEXT:    [[N1:%.*]] = and <2 x i4> [[N0]], [[IM]]
; CHECK-NEXT:    [[R:%.*]] = xor <2 x i4> [[X]], [[N1]]
; CHECK-NEXT:    ret <2 x i4> [[R]]
;
  %im = xor <2 x i4> %m, <i4 -1, i4 -1>
  %x  = call <2 x i4> @gen4()
  %n0 = xor <2 x i4> %x, %y
  %n1 = and <2 x i4> %n0, %im
  %r  = xor <2 x i4> %x, %n1 ; swapped order, %x instead of %y
  ret <2 x i4> %r
}

define <2 x i4> @c_1_1_1 (<2 x i4> %m) {
; CHECK-LABEL: @c_1_1_1(
; CHECK-NEXT:    [[IM:%.*]] = xor <2 x i4> [[M:%.*]], <i4 -1, i4 -1>
; CHECK-NEXT:    [[X:%.*]] = call <2 x i4> @gen4()
; CHECK-NEXT:    [[Y:%.*]] = call <2 x i4> @gen4()
; CHECK-NEXT:    [[N0:%.*]] = xor <2 x i4> [[Y]], [[X]]
; CHECK-NEXT:    [[N1:%.*]] = and <2 x i4> [[N0]], [[IM]]
; CHECK-NEXT:    [[R:%.*]] = xor <2 x i4> [[X]], [[N1]]
; CHECK-NEXT:    ret <2 x i4> [[R]]
;
  %im = xor <2 x i4> %m, <i4 -1, i4 -1>
  %x  = call <2 x i4> @gen4()
  %y  = call <2 x i4> @gen4()
  %n0 = xor <2 x i4> %y, %x ; swapped order
  %n1 = and <2 x i4> %n0, %im
  %r  = xor <2 x i4> %x, %n1 ; swapped order, %x instead of %y
  ret <2 x i4> %r
}

define <2 x i4> @commutativity_constant_varx_6_invmask(<2 x i4> %x, <2 x i4> %mask) {
; CHECK-LABEL: @commutativity_constant_varx_6_invmask(
; CHECK-NEXT:    [[NOTMASK:%.*]] = xor <2 x i4> [[MASK:%.*]], <i4 -1, i4 -1>
; CHECK-NEXT:    [[N0:%.*]] = xor <2 x i4> [[X:%.*]], <i4 6, i4 6>
; CHECK-NEXT:    [[N1:%.*]] = and <2 x i4> [[N0]], [[NOTMASK]]
; CHECK-NEXT:    [[R:%.*]] = xor <2 x i4> [[N1]], <i4 6, i4 6>
; CHECK-NEXT:    ret <2 x i4> [[R]]
;
  %notmask = xor <2 x i4> %mask, <i4 -1, i4 -1>
  %n0 = xor <2 x i4> %x, <i4 6, i4 6> ; %x
  %n1 = and <2 x i4> %notmask, %n0 ; swapped
  %r = xor <2 x i4> %n1, <i4 6, i4 6>
  ret <2 x i4> %r
}

define <2 x i4> @commutativity_constant_6_vary_invmask(<2 x i4> %y, <2 x i4> %mask) {
; CHECK-LABEL: @commutativity_constant_6_vary_invmask(
; CHECK-NEXT:    [[NOTMASK:%.*]] = xor <2 x i4> [[MASK:%.*]], <i4 -1, i4 -1>
; CHECK-NEXT:    [[N0:%.*]] = xor <2 x i4> [[Y:%.*]], <i4 6, i4 6>
; CHECK-NEXT:    [[N1:%.*]] = and <2 x i4> [[N0]], [[NOTMASK]]
; CHECK-NEXT:    [[R:%.*]] = xor <2 x i4> [[N1]], [[Y]]
; CHECK-NEXT:    ret <2 x i4> [[R]]
;
  %notmask = xor <2 x i4> %mask, <i4 -1, i4 -1>
  %n0 = xor <2 x i4> %y, <i4 6, i4 6> ; %x
  %n1 = and <2 x i4> %notmask, %n0 ; swapped
  %r = xor <2 x i4> %n1, %y
  ret <2 x i4> %r
}

; ============================================================================ ;
; Negative tests. Should not be folded.
; ============================================================================ ;

; One use only.

declare void @use4(<2 x i4>)

define <2 x i4> @n_oneuse_D_is_ok (<2 x i4> %x, <2 x i4> %y, <2 x i4> %m) {
; CHECK-LABEL: @n_oneuse_D_is_ok(
; CHECK-NEXT:    [[IM:%.*]] = xor <2 x i4> [[M:%.*]], <i4 -1, i4 -1>
; CHECK-NEXT:    [[N0:%.*]] = xor <2 x i4> [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[N1:%.*]] = and <2 x i4> [[N0]], [[IM]]
; CHECK-NEXT:    [[R:%.*]] = xor <2 x i4> [[N1]], [[Y]]
; CHECK-NEXT:    call void @use4(<2 x i4> [[N0]])
; CHECK-NEXT:    ret <2 x i4> [[R]]
;
  %im = xor <2 x i4> %m, <i4 -1, i4 -1>
  %n0 = xor <2 x i4> %x, %y ; two uses of %n0, THIS IS OK!
  %n1 = and <2 x i4> %n0, %im
  %r  = xor <2 x i4> %n1, %y
  call void @use4(<2 x i4> %n0)
  ret <2 x i4> %r
}

define <2 x i4> @n_oneuse_A (<2 x i4> %x, <2 x i4> %y, <2 x i4> %m) {
; CHECK-LABEL: @n_oneuse_A(
; CHECK-NEXT:    [[IM:%.*]] = xor <2 x i4> [[M:%.*]], <i4 -1, i4 -1>
; CHECK-NEXT:    [[N0:%.*]] = xor <2 x i4> [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[N1:%.*]] = and <2 x i4> [[N0]], [[IM]]
; CHECK-NEXT:    [[R:%.*]] = xor <2 x i4> [[N1]], [[Y]]
; CHECK-NEXT:    call void @use4(<2 x i4> [[N1]])
; CHECK-NEXT:    ret <2 x i4> [[R]]
;
  %im = xor <2 x i4> %m, <i4 -1, i4 -1>
  %n0 = xor <2 x i4> %x, %y
  %n1 = and <2 x i4> %n0, %im ; two uses of %n1, which is going to be replaced
  %r  = xor <2 x i4> %n1, %y
  call void @use4(<2 x i4> %n1)
  ret <2 x i4> %r
}

define <2 x i4> @n_oneuse_AD (<2 x i4> %x, <2 x i4> %y, <2 x i4> %m) {
; CHECK-LABEL: @n_oneuse_AD(
; CHECK-NEXT:    [[IM:%.*]] = xor <2 x i4> [[M:%.*]], <i4 -1, i4 -1>
; CHECK-NEXT:    [[N0:%.*]] = xor <2 x i4> [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[N1:%.*]] = and <2 x i4> [[N0]], [[IM]]
; CHECK-NEXT:    [[R:%.*]] = xor <2 x i4> [[N1]], [[Y]]
; CHECK-NEXT:    call void @use4(<2 x i4> [[N0]])
; CHECK-NEXT:    call void @use4(<2 x i4> [[N1]])
; CHECK-NEXT:    ret <2 x i4> [[R]]
;
  %im = xor <2 x i4> %m, <i4 -1, i4 -1>
  %n0 = xor <2 x i4> %x, %y ; two uses of %n0 IS OK
  %n1 = and <2 x i4> %n0, %im ; two uses of %n1, which is going to be replaced
  %r  = xor <2 x i4> %n1, %y
  call void @use4(<2 x i4> %n0)
  call void @use4(<2 x i4> %n1)
  ret <2 x i4> %r
}

; Some third variable is used

define <2 x i4> @n_third_var (<2 x i4> %x, <2 x i4> %y, <2 x i4> %z, <2 x i4> %m) {
; CHECK-LABEL: @n_third_var(
; CHECK-NEXT:    [[IM:%.*]] = xor <2 x i4> [[M:%.*]], <i4 -1, i4 -1>
; CHECK-NEXT:    [[N0:%.*]] = xor <2 x i4> [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[N1:%.*]] = and <2 x i4> [[N0]], [[IM]]
; CHECK-NEXT:    [[R:%.*]] = xor <2 x i4> [[N1]], [[Z:%.*]]
; CHECK-NEXT:    ret <2 x i4> [[R]]
;
  %im = xor <2 x i4> %m, <i4 -1, i4 -1>
  %n0 = xor <2 x i4> %x, %y
  %n1 = and <2 x i4> %n0, %im
  %r  = xor <2 x i4> %n1, %z ; not %x or %y
  ret <2 x i4> %r
}


define <2 x i4> @n_third_var_const(<2 x i4> %x, <2 x i4> %y, <2 x i4> %mask) {
; CHECK-LABEL: @n_third_var_const(
; CHECK-NEXT:    [[NOTMASK:%.*]] = xor <2 x i4> [[MASK:%.*]], <i4 -1, i4 -1>
; CHECK-NEXT:    [[N0:%.*]] = xor <2 x i4> [[X:%.*]], <i4 6, i4 7>
; CHECK-NEXT:    [[N1:%.*]] = and <2 x i4> [[N0]], [[NOTMASK]]
; CHECK-NEXT:    [[R:%.*]] = xor <2 x i4> [[N1]], <i4 7, i4 6>
; CHECK-NEXT:    ret <2 x i4> [[R]]
;
  %notmask = xor <2 x i4> %mask, <i4 -1, i4 -1>
  %n0 = xor <2 x i4> %x, <i4 6, i4 7> ; %x
  %n1 = and <2 x i4> %n0, %notmask
  %r = xor <2 x i4> %n1, <i4 7, i4 6>
  ret <2 x i4> %r
}

; Bad xor

define <2 x i4> @n_badxor_splat (<2 x i4> %x, <2 x i4> %y, <2 x i4> %m) {
; CHECK-LABEL: @n_badxor_splat(
; CHECK-NEXT:    [[IM:%.*]] = xor <2 x i4> [[M:%.*]], <i4 1, i4 1>
; CHECK-NEXT:    [[N0:%.*]] = xor <2 x i4> [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[N1:%.*]] = and <2 x i4> [[N0]], [[IM]]
; CHECK-NEXT:    [[R:%.*]] = xor <2 x i4> [[N1]], [[Y]]
; CHECK-NEXT:    ret <2 x i4> [[R]]
;
  %im = xor <2 x i4> %m, <i4 1, i4 1> ; not -1
  %n0 = xor <2 x i4> %x, %y
  %n1 = and <2 x i4> %n0, %im ; two uses of %n1, which is going to be replaced
  %r  = xor <2 x i4> %n1, %y
  ret <2 x i4> %r
}

define <2 x i4> @n_badxor (<2 x i4> %x, <2 x i4> %y, <2 x i4> %m) {
; CHECK-LABEL: @n_badxor(
; CHECK-NEXT:    [[IM:%.*]] = xor <2 x i4> [[M:%.*]], <i4 -1, i4 1>
; CHECK-NEXT:    [[N0:%.*]] = xor <2 x i4> [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[N1:%.*]] = and <2 x i4> [[N0]], [[IM]]
; CHECK-NEXT:    [[R:%.*]] = xor <2 x i4> [[N1]], [[Y]]
; CHECK-NEXT:    ret <2 x i4> [[R]]
;
  %im = xor <2 x i4> %m, <i4 -1, i4 1> ; not -1
  %n0 = xor <2 x i4> %x, %y
  %n1 = and <2 x i4> %n0, %im ; two uses of %n1, which is going to be replaced
  %r  = xor <2 x i4> %n1, %y
  ret <2 x i4> %r
}
