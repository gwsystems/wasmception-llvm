; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=thumbv8.1m.main-arm-none-eabi -mattr=+mve.fp -verify-machineinstrs %s -o - | FileCheck %s

define arm_aapcs_vfpcc <4 x i32> @sext_v4i1_v4i32(<4 x i32> %src) {
; CHECK-LABEL: sext_v4i1_v4i32:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vmov.i32 q1, #0x0
; CHECK-NEXT:    vmov.i8 q2, #0xff
; CHECK-NEXT:    vcmp.s32 gt, q0, zr
; CHECK-NEXT:    vpsel q0, q2, q1
; CHECK-NEXT:    bx lr
entry:
  %c = icmp sgt <4 x i32> %src, zeroinitializer
  %0 = sext <4 x i1> %c to <4 x i32>
  ret <4 x i32> %0
}

define arm_aapcs_vfpcc <8 x i16> @sext_v8i1_v8i16(<8 x i16> %src) {
; CHECK-LABEL: sext_v8i1_v8i16:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vmov.i16 q1, #0x0
; CHECK-NEXT:    vmov.i8 q2, #0xff
; CHECK-NEXT:    vcmp.s16 gt, q0, zr
; CHECK-NEXT:    vpsel q0, q2, q1
; CHECK-NEXT:    bx lr
entry:
  %c = icmp sgt <8 x i16> %src, zeroinitializer
  %0 = sext <8 x i1> %c to <8 x i16>
  ret <8 x i16> %0
}

define arm_aapcs_vfpcc <16 x i8> @sext_v16i1_v16i8(<16 x i8> %src) {
; CHECK-LABEL: sext_v16i1_v16i8:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vmov.i8 q1, #0x0
; CHECK-NEXT:    vmov.i8 q2, #0xff
; CHECK-NEXT:    vcmp.s8 gt, q0, zr
; CHECK-NEXT:    vpsel q0, q2, q1
; CHECK-NEXT:    bx lr
entry:
  %c = icmp sgt <16 x i8> %src, zeroinitializer
  %0 = sext <16 x i1> %c to <16 x i8>
  ret <16 x i8> %0
}

define arm_aapcs_vfpcc <2 x i64> @sext_v2i1_v2i64(<2 x i64> %src) {
; CHECK-LABEL: sext_v2i1_v2i64:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vmov r1, s2
; CHECK-NEXT:    movs r2, #0
; CHECK-NEXT:    vmov r0, s3
; CHECK-NEXT:    vmov r3, s0
; CHECK-NEXT:    rsbs r1, r1, #0
; CHECK-NEXT:    vmov r1, s1
; CHECK-NEXT:    sbcs.w r0, r2, r0
; CHECK-NEXT:    mov.w r0, #0
; CHECK-NEXT:    it lt
; CHECK-NEXT:    movlt r0, #1
; CHECK-NEXT:    cmp r0, #0
; CHECK-NEXT:    it ne
; CHECK-NEXT:    movne.w r0, #-1
; CHECK-NEXT:    rsbs r3, r3, #0
; CHECK-NEXT:    sbcs.w r1, r2, r1
; CHECK-NEXT:    it lt
; CHECK-NEXT:    movlt r2, #1
; CHECK-NEXT:    cmp r2, #0
; CHECK-NEXT:    it ne
; CHECK-NEXT:    movne.w r2, #-1
; CHECK-NEXT:    vmov.32 q0[0], r2
; CHECK-NEXT:    vmov.32 q0[1], r2
; CHECK-NEXT:    vmov.32 q0[2], r0
; CHECK-NEXT:    vmov.32 q0[3], r0
; CHECK-NEXT:    bx lr
entry:
  %c = icmp sgt <2 x i64> %src, zeroinitializer
  %0 = sext <2 x i1> %c to <2 x i64>
  ret <2 x i64> %0
}


define arm_aapcs_vfpcc <4 x i32> @zext_v4i1_v4i32(<4 x i32> %src) {
; CHECK-LABEL: zext_v4i1_v4i32:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vmov.i32 q1, #0x0
; CHECK-NEXT:    vmov.i32 q2, #0x1
; CHECK-NEXT:    vcmp.s32 gt, q0, zr
; CHECK-NEXT:    vpsel q0, q2, q1
; CHECK-NEXT:    bx lr
entry:
  %c = icmp sgt <4 x i32> %src, zeroinitializer
  %0 = zext <4 x i1> %c to <4 x i32>
  ret <4 x i32> %0
}

define arm_aapcs_vfpcc <8 x i16> @zext_v8i1_v8i16(<8 x i16> %src) {
; CHECK-LABEL: zext_v8i1_v8i16:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vmov.i16 q1, #0x0
; CHECK-NEXT:    vmov.i16 q2, #0x1
; CHECK-NEXT:    vcmp.s16 gt, q0, zr
; CHECK-NEXT:    vpsel q0, q2, q1
; CHECK-NEXT:    bx lr
entry:
  %c = icmp sgt <8 x i16> %src, zeroinitializer
  %0 = zext <8 x i1> %c to <8 x i16>
  ret <8 x i16> %0
}

define arm_aapcs_vfpcc <16 x i8> @zext_v16i1_v16i8(<16 x i8> %src) {
; CHECK-LABEL: zext_v16i1_v16i8:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vmov.i8 q1, #0x0
; CHECK-NEXT:    vmov.i8 q2, #0x1
; CHECK-NEXT:    vcmp.s8 gt, q0, zr
; CHECK-NEXT:    vpsel q0, q2, q1
; CHECK-NEXT:    bx lr
entry:
  %c = icmp sgt <16 x i8> %src, zeroinitializer
  %0 = zext <16 x i1> %c to <16 x i8>
  ret <16 x i8> %0
}

define arm_aapcs_vfpcc <2 x i64> @zext_v2i1_v2i64(<2 x i64> %src) {
; CHECK-LABEL: zext_v2i1_v2i64:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vmov r2, s2
; CHECK-NEXT:    adr r1, .LCPI7_0
; CHECK-NEXT:    vldrw.u32 q1, [r1]
; CHECK-NEXT:    vmov r1, s3
; CHECK-NEXT:    vmov r3, s0
; CHECK-NEXT:    movs r0, #0
; CHECK-NEXT:    rsbs r2, r2, #0
; CHECK-NEXT:    vmov r2, s1
; CHECK-NEXT:    sbcs.w r1, r0, r1
; CHECK-NEXT:    mov.w r1, #0
; CHECK-NEXT:    it lt
; CHECK-NEXT:    movlt r1, #1
; CHECK-NEXT:    cmp r1, #0
; CHECK-NEXT:    it ne
; CHECK-NEXT:    movne.w r1, #-1
; CHECK-NEXT:    rsbs r3, r3, #0
; CHECK-NEXT:    sbcs.w r2, r0, r2
; CHECK-NEXT:    it lt
; CHECK-NEXT:    movlt r0, #1
; CHECK-NEXT:    cmp r0, #0
; CHECK-NEXT:    it ne
; CHECK-NEXT:    movne.w r0, #-1
; CHECK-NEXT:    vmov.32 q0[0], r0
; CHECK-NEXT:    vmov.32 q0[2], r1
; CHECK-NEXT:    vand q0, q0, q1
; CHECK-NEXT:    bx lr
; CHECK-NEXT:    .p2align 4
; CHECK-NEXT:  @ %bb.1:
; CHECK-NEXT:  .LCPI7_0:
; CHECK-NEXT:    .long 1 @ 0x1
; CHECK-NEXT:    .long 0 @ 0x0
; CHECK-NEXT:    .long 1 @ 0x1
; CHECK-NEXT:    .long 0 @ 0x0
entry:
  %c = icmp sgt <2 x i64> %src, zeroinitializer
  %0 = zext <2 x i1> %c to <2 x i64>
  ret <2 x i64> %0
}


define arm_aapcs_vfpcc <4 x float> @uitofp_v4i1_v4f32(<4 x i32> %src) {
; CHECK-LABEL: uitofp_v4i1_v4f32:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.s32 gt, q0, zr
; CHECK-NEXT:    vmrs r0, p0
; CHECK-NEXT:    ubfx r1, r0, #8, #1
; CHECK-NEXT:    ubfx r2, r0, #12, #1
; CHECK-NEXT:    vmov s0, r2
; CHECK-NEXT:    vmov s4, r1
; CHECK-NEXT:    vcvt.f32.u32 s3, s0
; CHECK-NEXT:    ubfx r2, r0, #4, #1
; CHECK-NEXT:    vcvt.f32.u32 s2, s4
; CHECK-NEXT:    and r0, r0, #1
; CHECK-NEXT:    vmov s4, r2
; CHECK-NEXT:    vcvt.f32.u32 s1, s4
; CHECK-NEXT:    vmov s4, r0
; CHECK-NEXT:    vcvt.f32.u32 s0, s4
; CHECK-NEXT:    bx lr
entry:
  %c = icmp sgt <4 x i32> %src, zeroinitializer
  %0 = uitofp <4 x i1> %c to <4 x float>
  ret <4 x float> %0
}

define arm_aapcs_vfpcc <4 x float> @sitofp_v4i1_v4f32(<4 x i32> %src) {
; CHECK-LABEL: sitofp_v4i1_v4f32:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.s32 gt, q0, zr
; CHECK-NEXT:    vmrs r0, p0
; CHECK-NEXT:    and r1, r0, #1
; CHECK-NEXT:    ubfx r2, r0, #8, #1
; CHECK-NEXT:    ubfx r3, r0, #4, #1
; CHECK-NEXT:    ubfx r0, r0, #12, #1
; CHECK-NEXT:    rsbs r2, r2, #0
; CHECK-NEXT:    rsbs r0, r0, #0
; CHECK-NEXT:    vmov s4, r2
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    rsbs r0, r3, #0
; CHECK-NEXT:    vcvt.f32.s32 s3, s0
; CHECK-NEXT:    vcvt.f32.s32 s2, s4
; CHECK-NEXT:    vmov s4, r0
; CHECK-NEXT:    rsbs r0, r1, #0
; CHECK-NEXT:    vcvt.f32.s32 s1, s4
; CHECK-NEXT:    vmov s4, r0
; CHECK-NEXT:    vcvt.f32.s32 s0, s4
; CHECK-NEXT:    bx lr
entry:
  %c = icmp sgt <4 x i32> %src, zeroinitializer
  %0 = sitofp <4 x i1> %c to <4 x float>
  ret <4 x float> %0
}

define arm_aapcs_vfpcc <4 x float> @fptoui_v4i1_v4f32(<4 x float> %src) {
; CHECK-LABEL: fptoui_v4i1_v4f32:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcvt.s32.f32 s4, s0
; CHECK-NEXT:    movs r0, #0
; CHECK-NEXT:    vmov.f32 q2, #1.000000e+00
; CHECK-NEXT:    vmov r1, s4
; CHECK-NEXT:    vcvt.s32.f32 s4, s1
; CHECK-NEXT:    rsbs r1, r1, #0
; CHECK-NEXT:    bfi r0, r1, #0, #4
; CHECK-NEXT:    vmov r1, s4
; CHECK-NEXT:    vcvt.s32.f32 s4, s2
; CHECK-NEXT:    vcvt.s32.f32 s0, s3
; CHECK-NEXT:    rsbs r1, r1, #0
; CHECK-NEXT:    bfi r0, r1, #4, #4
; CHECK-NEXT:    vmov r1, s4
; CHECK-NEXT:    vmov.i32 q1, #0x0
; CHECK-NEXT:    rsbs r1, r1, #0
; CHECK-NEXT:    bfi r0, r1, #8, #4
; CHECK-NEXT:    vmov r1, s0
; CHECK-NEXT:    rsbs r1, r1, #0
; CHECK-NEXT:    bfi r0, r1, #12, #4
; CHECK-NEXT:    vmsr p0, r0
; CHECK-NEXT:    vpsel q0, q2, q1
; CHECK-NEXT:    bx lr
entry:
  %0 = fptoui <4 x float> %src to <4 x i1>
  %s = select <4 x i1> %0, <4 x float> <float 1.0, float 1.0, float 1.0, float 1.0>, <4 x float> zeroinitializer
  ret <4 x float> %s
}

define arm_aapcs_vfpcc <4 x float> @fptosi_v4i1_v4f32(<4 x float> %src) {
; CHECK-LABEL: fptosi_v4i1_v4f32:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcvt.s32.f32 s4, s0
; CHECK-NEXT:    movs r0, #0
; CHECK-NEXT:    vmov.f32 q2, #1.000000e+00
; CHECK-NEXT:    vmov r1, s4
; CHECK-NEXT:    vcvt.s32.f32 s4, s1
; CHECK-NEXT:    bfi r0, r1, #0, #4
; CHECK-NEXT:    vmov r1, s4
; CHECK-NEXT:    vcvt.s32.f32 s4, s2
; CHECK-NEXT:    bfi r0, r1, #4, #4
; CHECK-NEXT:    vcvt.s32.f32 s0, s3
; CHECK-NEXT:    vmov r1, s4
; CHECK-NEXT:    vmov.i32 q1, #0x0
; CHECK-NEXT:    bfi r0, r1, #8, #4
; CHECK-NEXT:    vmov r1, s0
; CHECK-NEXT:    bfi r0, r1, #12, #4
; CHECK-NEXT:    vmsr p0, r0
; CHECK-NEXT:    vpsel q0, q2, q1
; CHECK-NEXT:    bx lr
entry:
  %0 = fptosi <4 x float> %src to <4 x i1>
  %s = select <4 x i1> %0, <4 x float> <float 1.0, float 1.0, float 1.0, float 1.0>, <4 x float> zeroinitializer
  ret <4 x float> %s
}

