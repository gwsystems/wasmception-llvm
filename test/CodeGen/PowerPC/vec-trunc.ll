; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -verify-machineinstrs -mtriple=powerpc64le-unknown-linux-gnu \
; RUN:     -mattr=+vsx -ppc-asm-full-reg-names -ppc-vsr-nums-as-vr < %s | \
; RUN: FileCheck %s
; RUN: llc -verify-machineinstrs -mtriple=powerpc64-unknown-linux-gnu \
; RUN:     -mattr=+vsx -ppc-asm-full-reg-names -ppc-vsr-nums-as-vr < %s | \
; RUN: FileCheck %s --check-prefix=CHECK-BE

define void @test8i8(<8 x i8>* nocapture %Sink, <8 x i16>* nocapture readonly %SrcPtr) {
; CHECK-LABEL: test8i8:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lvx v2, 0, r4
; CHECK-NEXT:    vpkuhum v2, v2, v2
; CHECK-NEXT:    xxswapd vs0, v2
; CHECK-NEXT:    stfdx f0, 0, r3
; CHECK-NEXT:    blr
;
; CHECK-BE-LABEL: test8i8:
; CHECK-BE:       # %bb.0: # %entry
; CHECK-BE-NEXT:    lxvw4x v2, 0, r4
; CHECK-BE-NEXT:    addi r5, r1, -16
; CHECK-BE-NEXT:    vpkuhum v2, v2, v2
; CHECK-BE-NEXT:    stxvd2x v2, 0, r5
; CHECK-BE-NEXT:    ld r4, -16(r1)
; CHECK-BE-NEXT:    std r4, 0(r3)
; CHECK-BE-NEXT:    blr
entry:
  %0 = load <8 x i16>, <8 x i16>* %SrcPtr, align 16
  %1 = trunc <8 x i16> %0 to <8 x i8>
  store <8 x i8> %1, <8 x i8>* %Sink, align 16
  ret void
}

define void @test4i8(<4 x i8>* nocapture %Sink, <4 x i16>* nocapture readonly %SrcPtr) {
; CHECK-LABEL: test4i8:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lvx v2, 0, r4
; CHECK-NEXT:    vpkuhum v2, v2, v2
; CHECK-NEXT:    xxsldwi vs0, v2, v2, 2
; CHECK-NEXT:    stfiwx f0, 0, r3
; CHECK-NEXT:    blr
;
; CHECK-BE-LABEL: test4i8:
; CHECK-BE:       # %bb.0: # %entry
; CHECK-BE-NEXT:    lxvw4x v2, 0, r4
; CHECK-BE-NEXT:    addi r5, r1, -16
; CHECK-BE-NEXT:    vpkuhum v2, v2, v2
; CHECK-BE-NEXT:    stxvw4x v2, 0, r5
; CHECK-BE-NEXT:    lwz r4, -16(r1)
; CHECK-BE-NEXT:    stw r4, 0(r3)
; CHECK-BE-NEXT:    blr
entry:
  %0 = load <4 x i16>, <4 x i16>* %SrcPtr, align 16
  %1 = trunc <4 x i16> %0 to <4 x i8>
  store <4 x i8> %1, <4 x i8>* %Sink, align 16
  ret void
}

define void @test4i8w(<4 x i8>* nocapture %Sink, <4 x i32>* nocapture readonly %SrcPtr) {
; CHECK-LABEL: test4i8w:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addis r5, r2, .LCPI2_0@toc@ha
; CHECK-NEXT:    lvx v3, 0, r4
; CHECK-NEXT:    addi r5, r5, .LCPI2_0@toc@l
; CHECK-NEXT:    lvx v2, 0, r5
; CHECK-NEXT:    vperm v2, v3, v3, v2
; CHECK-NEXT:    xxsldwi vs0, v2, v2, 2
; CHECK-NEXT:    stfiwx f0, 0, r3
; CHECK-NEXT:    blr
;
; CHECK-BE-LABEL: test4i8w:
; CHECK-BE:       # %bb.0: # %entry
; CHECK-BE-NEXT:    addis r5, r2, .LCPI2_0@toc@ha
; CHECK-BE-NEXT:    lxvw4x v2, 0, r4
; CHECK-BE-NEXT:    addi r4, r5, .LCPI2_0@toc@l
; CHECK-BE-NEXT:    lxvw4x v3, 0, r4
; CHECK-BE-NEXT:    addi r4, r1, -16
; CHECK-BE-NEXT:    vperm v2, v2, v2, v3
; CHECK-BE-NEXT:    stxvw4x v2, 0, r4
; CHECK-BE-NEXT:    lwz r4, -16(r1)
; CHECK-BE-NEXT:    stw r4, 0(r3)
; CHECK-BE-NEXT:    blr
entry:
  %0 = load <4 x i32>, <4 x i32>* %SrcPtr, align 16
  %1 = trunc <4 x i32> %0 to <4 x i8>
  store <4 x i8> %1, <4 x i8>* %Sink, align 16
  ret void
}

define void @test2i8(<2 x i8>* nocapture %Sink, <2 x i16>* nocapture readonly %SrcPtr) {
; CHECK-LABEL: test2i8:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lvx v2, 0, r4
; CHECK-NEXT:    vpkuhum v2, v2, v2
; CHECK-NEXT:    xxswapd vs0, v2
; CHECK-NEXT:    mfvsrd r4, f0
; CHECK-NEXT:    clrldi r4, r4, 48
; CHECK-NEXT:    sth r4, 0(r3)
; CHECK-NEXT:    blr
;
; CHECK-BE-LABEL: test2i8:
; CHECK-BE:       # %bb.0: # %entry
; CHECK-BE-NEXT:    lxvw4x v2, 0, r4
; CHECK-BE-NEXT:    addi r5, r1, -16
; CHECK-BE-NEXT:    vpkuhum v2, v2, v2
; CHECK-BE-NEXT:    stxvw4x v2, 0, r5
; CHECK-BE-NEXT:    lhz r4, -16(r1)
; CHECK-BE-NEXT:    sth r4, 0(r3)
; CHECK-BE-NEXT:    blr
entry:
  %0 = load <2 x i16>, <2 x i16>* %SrcPtr, align 16
  %1 = trunc <2 x i16> %0 to <2 x i8>
  store <2 x i8> %1, <2 x i8>* %Sink, align 16
  ret void
}

define void @test4i16(<4 x i16>* nocapture %Sink, <4 x i32>* nocapture readonly %SrcPtr) {
; CHECK-LABEL: test4i16:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lvx v2, 0, r4
; CHECK-NEXT:    vpkuwum v2, v2, v2
; CHECK-NEXT:    xxswapd vs0, v2
; CHECK-NEXT:    stfdx f0, 0, r3
; CHECK-NEXT:    blr
;
; CHECK-BE-LABEL: test4i16:
; CHECK-BE:       # %bb.0: # %entry
; CHECK-BE-NEXT:    lxvw4x v2, 0, r4
; CHECK-BE-NEXT:    addi r5, r1, -16
; CHECK-BE-NEXT:    vpkuwum v2, v2, v2
; CHECK-BE-NEXT:    stxvd2x v2, 0, r5
; CHECK-BE-NEXT:    ld r4, -16(r1)
; CHECK-BE-NEXT:    std r4, 0(r3)
; CHECK-BE-NEXT:    blr
entry:
  %0 = load <4 x i32>, <4 x i32>* %SrcPtr, align 16
  %1 = trunc <4 x i32> %0 to <4 x i16>
  store <4 x i16> %1, <4 x i16>* %Sink, align 16
  ret void
}

define void @test2i16(<2 x i16>* nocapture %Sink, <2 x i32>* nocapture readonly %SrcPtr) {
; CHECK-LABEL: test2i16:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lvx v2, 0, r4
; CHECK-NEXT:    vpkuwum v2, v2, v2
; CHECK-NEXT:    xxsldwi vs0, v2, v2, 2
; CHECK-NEXT:    stfiwx f0, 0, r3
; CHECK-NEXT:    blr
;
; CHECK-BE-LABEL: test2i16:
; CHECK-BE:       # %bb.0: # %entry
; CHECK-BE-NEXT:    lxvw4x v2, 0, r4
; CHECK-BE-NEXT:    addi r5, r1, -16
; CHECK-BE-NEXT:    vpkuwum v2, v2, v2
; CHECK-BE-NEXT:    stxvw4x v2, 0, r5
; CHECK-BE-NEXT:    lwz r4, -16(r1)
; CHECK-BE-NEXT:    stw r4, 0(r3)
; CHECK-BE-NEXT:    blr
entry:
  %0 = load <2 x i32>, <2 x i32>* %SrcPtr, align 16
  %1 = trunc <2 x i32> %0 to <2 x i16>
  store <2 x i16> %1, <2 x i16>* %Sink, align 16
  ret void
}

define void @test2i16d(<2 x i16>* nocapture %Sink, <2 x i64>* nocapture readonly %SrcPtr) {
; CHECK-LABEL: test2i16d:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lxvd2x vs0, 0, r4
; CHECK-NEXT:    addis r5, r2, .LCPI6_0@toc@ha
; CHECK-NEXT:    addi r4, r5, .LCPI6_0@toc@l
; CHECK-NEXT:    lvx v3, 0, r4
; CHECK-NEXT:    xxswapd v2, vs0
; CHECK-NEXT:    vperm v2, v2, v2, v3
; CHECK-NEXT:    xxsldwi vs0, v2, v2, 2
; CHECK-NEXT:    stfiwx f0, 0, r3
; CHECK-NEXT:    blr
;
; CHECK-BE-LABEL: test2i16d:
; CHECK-BE:       # %bb.0: # %entry
; CHECK-BE-NEXT:    addis r5, r2, .LCPI6_0@toc@ha
; CHECK-BE-NEXT:    lxvw4x v2, 0, r4
; CHECK-BE-NEXT:    addi r4, r5, .LCPI6_0@toc@l
; CHECK-BE-NEXT:    lxvw4x v3, 0, r4
; CHECK-BE-NEXT:    addi r4, r1, -16
; CHECK-BE-NEXT:    vperm v2, v2, v2, v3
; CHECK-BE-NEXT:    stxvw4x v2, 0, r4
; CHECK-BE-NEXT:    lwz r4, -16(r1)
; CHECK-BE-NEXT:    stw r4, 0(r3)
; CHECK-BE-NEXT:    blr
entry:
  %0 = load <2 x i64>, <2 x i64>* %SrcPtr, align 16
  %1 = trunc <2 x i64> %0 to <2 x i16>
  store <2 x i16> %1, <2 x i16>* %Sink, align 16
  ret void
}
