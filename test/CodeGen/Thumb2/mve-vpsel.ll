; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -O3 -mtriple=thumbv8.1m.main-arm-none-eabi -mattr=+mve.fp %s -o - | FileCheck %s

define arm_aapcs_vfpcc <16 x i8> @vpsel_i8(<16 x i1> *%mask, <16 x i8> %src1, <16 x i8> %src2) {
; CHECK-LABEL: vpsel_i8:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vldr p0, [r0]
; CHECK-NEXT:    vpsel q0, q0, q1
; CHECK-NEXT:    bx lr
entry:
  %0 = load <16 x i1>, <16 x i1>* %mask, align 4
  %1 = select <16 x i1> %0, <16 x i8> %src1, <16 x i8> %src2
  ret <16 x i8> %1
}

define arm_aapcs_vfpcc <8 x i16> @vpsel_i16(<8 x i1> *%mask, <8 x i16> %src1, <8 x i16> %src2) {
; CHECK-LABEL: vpsel_i16:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vldr p0, [r0]
; CHECK-NEXT:    vpsel q0, q0, q1
; CHECK-NEXT:    bx lr
entry:
  %0 = load <8 x i1>, <8 x i1>* %mask, align 4
  %1 = select <8 x i1> %0, <8 x i16> %src1, <8 x i16> %src2
  ret <8 x i16> %1
}

define arm_aapcs_vfpcc <4 x i32> @vpsel_i32(<4 x i1> *%mask, <4 x i32> %src1, <4 x i32> %src2) {
; CHECK-LABEL: vpsel_i32:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vldr p0, [r0]
; CHECK-NEXT:    vpsel q0, q0, q1
; CHECK-NEXT:    bx lr
entry:
  %0 = load <4 x i1>, <4 x i1>* %mask, align 4
  %1 = select <4 x i1> %0, <4 x i32> %src1, <4 x i32> %src2
  ret <4 x i32> %1
}

define arm_aapcs_vfpcc <4 x i32> @foo(<4 x i32> %vec.ind) {
; CHECK-LABEL: foo:
; CHECK:       @ %bb.0:
; CHECK-NEXT:    vmov.i32 q2, #0x1
; CHECK-NEXT:    vmov.i32 q1, #0x0
; CHECK-NEXT:    vand q2, q0, q2
; CHECK-NEXT:    vcmp.i32 eq, q2, zr
; CHECK-NEXT:    vpsel q0, q0, q1
; CHECK-NEXT:    bx lr
  %tmp = and <4 x i32> %vec.ind, <i32 1, i32 1, i32 1, i32 1>
  %tmp1 = icmp eq <4 x i32> %tmp, zeroinitializer
  %tmp2 = select <4 x i1> %tmp1, <4 x i32> %vec.ind, <4 x i32> zeroinitializer
  ret <4 x i32> %tmp2
}
