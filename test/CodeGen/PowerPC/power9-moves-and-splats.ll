; RUN: llc -mcpu=pwr9 -mtriple=powerpc64le-unknown-linux-gnu -ppc-vsr-nums-as-vr \
; RUN:   -ppc-asm-full-reg-names < %s | FileCheck %s
; RUN: llc -mcpu=pwr9 -mtriple=powerpc64-unknown-linux-gnu -ppc-vsr-nums-as-vr \
; RUN:   -ppc-asm-full-reg-names < %s | FileCheck %s --check-prefix=CHECK-BE

@Globi = external global i32, align 4
@Globf = external global float, align 4

define <2 x i64> @test1(i64 %a, i64 %b) {
; CHECK-LABEL: test1:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    mtvsrdd v2, r4, r3
; CHECK-NEXT:    blr

; CHECK-BE-LABEL: test1:
; CHECK-BE:       # %bb.0: # %entry
; CHECK-BE-NEXT:    mtvsrdd v2, r3, r4
; CHECK-BE-NEXT:    blr
entry:
; The FIXME below is due to the lowering for BUILD_VECTOR needing a re-vamp
; which will happen in a subsequent patch.
  %vecins = insertelement <2 x i64> undef, i64 %a, i32 0
  %vecins1 = insertelement <2 x i64> %vecins, i64 %b, i32 1
  ret <2 x i64> %vecins1
}

define i64 @test2(<2 x i64> %a) {
; CHECK-LABEL: test2:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    mfvsrld r3, v2
; CHECK-NEXT:    blr

; CHECK-BE-LABEL: test2:
; CHECK-BE:       # %bb.0: # %entry
; CHECK-BE-NEXT:    mfvsrd r3, v2
; CHECK-BE-NEXT:    blr
entry:
  %0 = extractelement <2 x i64> %a, i32 0
  ret i64 %0
}

define i64 @test3(<2 x i64> %a) {
; CHECK-LABEL: test3:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    mfvsrd r3, v2
; CHECK-NEXT:    blr

; CHECK-BE-LABEL: test3:
; CHECK-BE:       # %bb.0: # %entry
; CHECK-BE-NEXT:    mfvsrld r3, v2
; CHECK-BE-NEXT:    blr
entry:
  %0 = extractelement <2 x i64> %a, i32 1
  ret i64 %0
}

define <4 x i32> @test4(i32* nocapture readonly %in) {
; CHECK-LABEL: test4:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lfiwzx f0, 0, r3
; CHECK-NEXT:    xxpermdi vs0, f0, f0, 2
; CHECK-NEXT:    xxspltw v2, vs0, 3
; CHECK-NEXT:    blr

; CHECK-BE-LABEL: test4:
; CHECK-BE:       # %bb.0: # %entry
; CHECK-BE-NEXT:    lfiwzx f0, 0, r3
; CHECK-BE-NEXT:    xxsldwi vs0, f0, f0, 1
; CHECK-BE-NEXT:    xxspltw v2, vs0, 0
; CHECK-BE-NEXT:    blr
entry:
  %0 = load i32, i32* %in, align 4
  %splat.splatinsert = insertelement <4 x i32> undef, i32 %0, i32 0
  %splat.splat = shufflevector <4 x i32> %splat.splatinsert, <4 x i32> undef, <4 x i32> zeroinitializer
  ret <4 x i32> %splat.splat
}

define <4 x float> @test5(float* nocapture readonly %in) {
; CHECK-LABEL: test5:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lfiwzx f0, 0, r3
; CHECK-NEXT:    xxpermdi vs0, f0, f0, 2
; CHECK-NEXT:    xxspltw v2, vs0, 3
; CHECK-NEXT:    blr

; CHECK-BE-LABEL: test5:
; CHECK-BE:       # %bb.0: # %entry
; CHECK-BE-NEXT:    lfiwzx f0, 0, r3
; CHECK-BE-NEXT:    xxsldwi vs0, f0, f0, 1
; CHECK-BE-NEXT:    xxspltw v2, vs0, 0
; CHECK-BE-NEXT:    blr
entry:
  %0 = load float, float* %in, align 4
  %splat.splatinsert = insertelement <4 x float> undef, float %0, i32 0
  %splat.splat = shufflevector <4 x float> %splat.splatinsert, <4 x float> undef, <4 x i32> zeroinitializer
  ret <4 x float> %splat.splat
}

define <4 x i32> @test6() {
; CHECK-LABEL: test6:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addis r3, r2, .LC0@toc@ha
; CHECK-NEXT:    ld r3, .LC0@toc@l(r3)
; CHECK-NEXT:    lfiwzx f0, 0, r3
; CHECK-NEXT:    xxpermdi vs0, f0, f0, 2
; CHECK-NEXT:    xxspltw v2, vs0, 3
; CHECK-NEXT:    blr

; CHECK-BE-LABEL: test6:
; CHECK-BE:       # %bb.0: # %entry
; CHECK-BE-NEXT:    addis r3, r2, .LC0@toc@ha
; CHECK-BE-NEXT:    ld r3, .LC0@toc@l(r3)
; CHECK-BE-NEXT:    lfiwzx f0, 0, r3
; CHECK-BE-NEXT:    xxsldwi vs0, f0, f0, 1
; CHECK-BE-NEXT:    xxspltw v2, vs0, 0
; CHECK-BE-NEXT:    blr
entry:
  %0 = load i32, i32* @Globi, align 4
  %splat.splatinsert = insertelement <4 x i32> undef, i32 %0, i32 0
  %splat.splat = shufflevector <4 x i32> %splat.splatinsert, <4 x i32> undef, <4 x i32> zeroinitializer
  ret <4 x i32> %splat.splat
}

define <4 x float> @test7() {
; CHECK-LABEL: test7:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addis r3, r2, .LC1@toc@ha
; CHECK-NEXT:    ld r3, .LC1@toc@l(r3)
; CHECK-NEXT:    lfiwzx f0, 0, r3
; CHECK-NEXT:    xxpermdi vs0, f0, f0, 2
; CHECK-NEXT:    xxspltw v2, vs0, 3
; CHECK-NEXT:    blr

; CHECK-BE-LABEL: test7:
; CHECK-BE:       # %bb.0: # %entry
; CHECK-BE-NEXT:    addis r3, r2, .LC1@toc@ha
; CHECK-BE-NEXT:    ld r3, .LC1@toc@l(r3)
; CHECK-BE-NEXT:    lfiwzx f0, 0, r3
; CHECK-BE-NEXT:    xxsldwi vs0, f0, f0, 1
; CHECK-BE-NEXT:    xxspltw v2, vs0, 0
; CHECK-BE-NEXT:    blr
entry:
  %0 = load float, float* @Globf, align 4
  %splat.splatinsert = insertelement <4 x float> undef, float %0, i32 0
  %splat.splat = shufflevector <4 x float> %splat.splatinsert, <4 x float> undef, <4 x i32> zeroinitializer
  ret <4 x float> %splat.splat
}

define <16 x i8> @test8() {
; CHECK-LABEL: test8:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xxlxor v2, v2, v2
; CHECK-NEXT:    blr

; CHECK-BE-LABEL: test8:
; CHECK-BE:       # %bb.0: # %entry
; CHECK-BE-NEXT:    xxlxor v2, v2, v2
; CHECK-BE-NEXT:    blr
entry:
  ret <16 x i8> zeroinitializer
}

define <16 x i8> @test9() {
; CHECK-LABEL: test9:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xxspltib v2, 1
; CHECK-NEXT:    blr

; CHECK-BE-LABEL: test9:
; CHECK-BE:       # %bb.0: # %entry
; CHECK-BE-NEXT:    xxspltib v2, 1
; CHECK-BE-NEXT:    blr
entry:
  ret <16 x i8> <i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1>
}

define <16 x i8> @test10() {
; CHECK-LABEL: test10:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xxspltib v2, 127
; CHECK-NEXT:    blr

; CHECK-BE-LABEL: test10:
; CHECK-BE:       # %bb.0: # %entry
; CHECK-BE-NEXT:    xxspltib v2, 127
; CHECK-BE-NEXT:    blr
entry:
  ret <16 x i8> <i8 127, i8 127, i8 127, i8 127, i8 127, i8 127, i8 127, i8 127, i8 127, i8 127, i8 127, i8 127, i8 127, i8 127, i8 127, i8 127>
}

define <16 x i8> @test11() {
; CHECK-LABEL: test11:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xxspltib v2, 128
; CHECK-NEXT:    blr

; CHECK-BE-LABEL: test11:
; CHECK-BE:       # %bb.0: # %entry
; CHECK-BE-NEXT:    xxspltib v2, 128
; CHECK-BE-NEXT:    blr
entry:
  ret <16 x i8> <i8 -128, i8 -128, i8 -128, i8 -128, i8 -128, i8 -128, i8 -128, i8 -128, i8 -128, i8 -128, i8 -128, i8 -128, i8 -128, i8 -128, i8 -128, i8 -128>
}

define <16 x i8> @test12() {
; CHECK-LABEL: test12:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xxspltib v2, 255
; CHECK-NEXT:    blr

; CHECK-BE-LABEL: test12:
; CHECK-BE:       # %bb.0: # %entry
; CHECK-BE-NEXT:    xxspltib v2, 255
; CHECK-BE-NEXT:    blr
entry:
  ret <16 x i8> <i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1>
}

define <16 x i8> @test13() {
; CHECK-LABEL: test13:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xxspltib v2, 129
; CHECK-NEXT:    blr

; CHECK-BE-LABEL: test13:
; CHECK-BE:       # %bb.0: # %entry
; CHECK-BE-NEXT:    xxspltib v2, 129
; CHECK-BE-NEXT:    blr
entry:
  ret <16 x i8> <i8 -127, i8 -127, i8 -127, i8 -127, i8 -127, i8 -127, i8 -127, i8 -127, i8 -127, i8 -127, i8 -127, i8 -127, i8 -127, i8 -127, i8 -127, i8 -127>
}

define <16 x i8> @test13E127() {
; CHECK-LABEL: test13E127:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xxspltib v2, 200
; CHECK-NEXT:    blr

; CHECK-BE-LABEL: test13E127:
; CHECK-BE:       # %bb.0: # %entry
; CHECK-BE-NEXT:    xxspltib v2, 200
; CHECK-BE-NEXT:    blr
entry:
  ret <16 x i8> <i8 200, i8 200, i8 200, i8 200, i8 200, i8 200, i8 200, i8 200, i8 200, i8 200, i8 200, i8 200, i8 200, i8 200, i8 200, i8 200>
}

define <4 x i32> @test14(<4 x i32> %a, i32* nocapture readonly %b) {
; CHECK-LABEL: test14:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lwz r3, 0(r5)
; CHECK-NEXT:    mtvsrws v2, r3
; CHECK-NEXT:    addi r3, r3, 5
; CHECK-NEXT:    stw r3, 0(r5)
; CHECK-NEXT:    blr

; CHECK-BE-LABEL: test14:
; CHECK-BE:       # %bb.0: # %entry
; CHECK-BE-NEXT:    lwz r3, 0(r5)
; CHECK-BE-NEXT:    mtvsrws v2, r3
; CHECK-BE-NEXT:    addi r3, r3, 5
; CHECK-BE-NEXT:    stw r3, 0(r5)
; CHECK-BE-NEXT:    blr
entry:
  %0 = load i32, i32* %b, align 4
  %splat.splatinsert = insertelement <4 x i32> undef, i32 %0, i32 0
  %splat.splat = shufflevector <4 x i32> %splat.splatinsert, <4 x i32> undef, <4 x i32> zeroinitializer
  %1 = add i32 %0, 5
  store i32 %1, i32* %b, align 4
  ret <4 x i32> %splat.splat
}
