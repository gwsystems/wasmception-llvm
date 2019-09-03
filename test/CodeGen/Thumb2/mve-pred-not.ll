; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=thumbv8.1m.main-arm-none-eabi -mattr=+mve -verify-machineinstrs %s -o - | FileCheck %s

define arm_aapcs_vfpcc <4 x i32> @cmpeqz_v4i1(<4 x i32> %a, <4 x i32> %b) {
; CHECK-LABEL: cmpeqz_v4i1:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.i32 eq, q0, zr
; CHECK-NEXT:    vpsel q0, q1, q0
; CHECK-NEXT:    bx lr
entry:
  %c1 = icmp eq <4 x i32> %a, zeroinitializer
  %o = xor <4 x i1> %c1, <i1 -1, i1 -1, i1 -1, i1 -1>
  %s = select <4 x i1> %o, <4 x i32> %a, <4 x i32> %b
  ret <4 x i32> %s
}

define arm_aapcs_vfpcc <4 x i32> @cmpnez_v4i1(<4 x i32> %a, <4 x i32> %b) {
; CHECK-LABEL: cmpnez_v4i1:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.i32 eq, q0, zr
; CHECK-NEXT:    vpsel q0, q1, q0
; CHECK-NEXT:    bx lr
entry:
  %c1 = icmp eq <4 x i32> %a, zeroinitializer
  %o = xor <4 x i1> %c1, <i1 -1, i1 -1, i1 -1, i1 -1>
  %s = select <4 x i1> %o, <4 x i32> %a, <4 x i32> %b
  ret <4 x i32> %s
}

define arm_aapcs_vfpcc <4 x i32> @cmpsltz_v4i1(<4 x i32> %a, <4 x i32> %b) {
; CHECK-LABEL: cmpsltz_v4i1:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.i32 eq, q0, zr
; CHECK-NEXT:    vpsel q0, q1, q0
; CHECK-NEXT:    bx lr
entry:
  %c1 = icmp eq <4 x i32> %a, zeroinitializer
  %o = xor <4 x i1> %c1, <i1 -1, i1 -1, i1 -1, i1 -1>
  %s = select <4 x i1> %o, <4 x i32> %a, <4 x i32> %b
  ret <4 x i32> %s
}

define arm_aapcs_vfpcc <4 x i32> @cmpsgtz_v4i1(<4 x i32> %a, <4 x i32> %b) {
; CHECK-LABEL: cmpsgtz_v4i1:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.i32 eq, q0, zr
; CHECK-NEXT:    vpsel q0, q1, q0
; CHECK-NEXT:    bx lr
entry:
  %c1 = icmp eq <4 x i32> %a, zeroinitializer
  %o = xor <4 x i1> %c1, <i1 -1, i1 -1, i1 -1, i1 -1>
  %s = select <4 x i1> %o, <4 x i32> %a, <4 x i32> %b
  ret <4 x i32> %s
}

define arm_aapcs_vfpcc <4 x i32> @cmpslez_v4i1(<4 x i32> %a, <4 x i32> %b) {
; CHECK-LABEL: cmpslez_v4i1:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.i32 eq, q0, zr
; CHECK-NEXT:    vpsel q0, q1, q0
; CHECK-NEXT:    bx lr
entry:
  %c1 = icmp eq <4 x i32> %a, zeroinitializer
  %o = xor <4 x i1> %c1, <i1 -1, i1 -1, i1 -1, i1 -1>
  %s = select <4 x i1> %o, <4 x i32> %a, <4 x i32> %b
  ret <4 x i32> %s
}

define arm_aapcs_vfpcc <4 x i32> @cmpsgez_v4i1(<4 x i32> %a, <4 x i32> %b) {
; CHECK-LABEL: cmpsgez_v4i1:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.i32 eq, q0, zr
; CHECK-NEXT:    vpsel q0, q1, q0
; CHECK-NEXT:    bx lr
entry:
  %c1 = icmp eq <4 x i32> %a, zeroinitializer
  %o = xor <4 x i1> %c1, <i1 -1, i1 -1, i1 -1, i1 -1>
  %s = select <4 x i1> %o, <4 x i32> %a, <4 x i32> %b
  ret <4 x i32> %s
}

define arm_aapcs_vfpcc <4 x i32> @cmpultz_v4i1(<4 x i32> %a, <4 x i32> %b) {
; CHECK-LABEL: cmpultz_v4i1:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.i32 eq, q0, zr
; CHECK-NEXT:    vpsel q0, q1, q0
; CHECK-NEXT:    bx lr
entry:
  %c1 = icmp eq <4 x i32> %a, zeroinitializer
  %o = xor <4 x i1> %c1, <i1 -1, i1 -1, i1 -1, i1 -1>
  %s = select <4 x i1> %o, <4 x i32> %a, <4 x i32> %b
  ret <4 x i32> %s
}

define arm_aapcs_vfpcc <4 x i32> @cmpugtz_v4i1(<4 x i32> %a, <4 x i32> %b) {
; CHECK-LABEL: cmpugtz_v4i1:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.i32 eq, q0, zr
; CHECK-NEXT:    vpsel q0, q1, q0
; CHECK-NEXT:    bx lr
entry:
  %c1 = icmp eq <4 x i32> %a, zeroinitializer
  %o = xor <4 x i1> %c1, <i1 -1, i1 -1, i1 -1, i1 -1>
  %s = select <4 x i1> %o, <4 x i32> %a, <4 x i32> %b
  ret <4 x i32> %s
}

define arm_aapcs_vfpcc <4 x i32> @cmpulez_v4i1(<4 x i32> %a, <4 x i32> %b) {
; CHECK-LABEL: cmpulez_v4i1:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.i32 eq, q0, zr
; CHECK-NEXT:    vpsel q0, q1, q0
; CHECK-NEXT:    bx lr
entry:
  %c1 = icmp eq <4 x i32> %a, zeroinitializer
  %o = xor <4 x i1> %c1, <i1 -1, i1 -1, i1 -1, i1 -1>
  %s = select <4 x i1> %o, <4 x i32> %a, <4 x i32> %b
  ret <4 x i32> %s
}

define arm_aapcs_vfpcc <4 x i32> @cmpugez_v4i1(<4 x i32> %a, <4 x i32> %b) {
; CHECK-LABEL: cmpugez_v4i1:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.i32 eq, q0, zr
; CHECK-NEXT:    vpsel q0, q1, q0
; CHECK-NEXT:    bx lr
entry:
  %c1 = icmp eq <4 x i32> %a, zeroinitializer
  %o = xor <4 x i1> %c1, <i1 -1, i1 -1, i1 -1, i1 -1>
  %s = select <4 x i1> %o, <4 x i32> %a, <4 x i32> %b
  ret <4 x i32> %s
}



define arm_aapcs_vfpcc <4 x i32> @cmpeq_v4i1(<4 x i32> %a, <4 x i32> %b, <4 x i32> %c) {
; CHECK-LABEL: cmpeq_v4i1:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.i32 eq, q0, zr
; CHECK-NEXT:    vpsel q0, q1, q0
; CHECK-NEXT:    bx lr
entry:
  %c1 = icmp eq <4 x i32> %a, zeroinitializer
  %o = xor <4 x i1> %c1, <i1 -1, i1 -1, i1 -1, i1 -1>
  %s = select <4 x i1> %o, <4 x i32> %a, <4 x i32> %b
  ret <4 x i32> %s
}

define arm_aapcs_vfpcc <4 x i32> @cmpne_v4i1(<4 x i32> %a, <4 x i32> %b, <4 x i32> %c) {
; CHECK-LABEL: cmpne_v4i1:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.i32 eq, q0, zr
; CHECK-NEXT:    vpsel q0, q1, q0
; CHECK-NEXT:    bx lr
entry:
  %c1 = icmp eq <4 x i32> %a, zeroinitializer
  %o = xor <4 x i1> %c1, <i1 -1, i1 -1, i1 -1, i1 -1>
  %s = select <4 x i1> %o, <4 x i32> %a, <4 x i32> %b
  ret <4 x i32> %s
}

define arm_aapcs_vfpcc <4 x i32> @cmpslt_v4i1(<4 x i32> %a, <4 x i32> %b, <4 x i32> %c) {
; CHECK-LABEL: cmpslt_v4i1:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.i32 eq, q0, zr
; CHECK-NEXT:    vpsel q0, q1, q0
; CHECK-NEXT:    bx lr
entry:
  %c1 = icmp eq <4 x i32> %a, zeroinitializer
  %o = xor <4 x i1> %c1, <i1 -1, i1 -1, i1 -1, i1 -1>
  %s = select <4 x i1> %o, <4 x i32> %a, <4 x i32> %b
  ret <4 x i32> %s
}

define arm_aapcs_vfpcc <4 x i32> @cmpsgt_v4i1(<4 x i32> %a, <4 x i32> %b, <4 x i32> %c) {
; CHECK-LABEL: cmpsgt_v4i1:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.i32 eq, q0, zr
; CHECK-NEXT:    vpsel q0, q1, q0
; CHECK-NEXT:    bx lr
entry:
  %c1 = icmp eq <4 x i32> %a, zeroinitializer
  %o = xor <4 x i1> %c1, <i1 -1, i1 -1, i1 -1, i1 -1>
  %s = select <4 x i1> %o, <4 x i32> %a, <4 x i32> %b
  ret <4 x i32> %s
}

define arm_aapcs_vfpcc <4 x i32> @cmpsle_v4i1(<4 x i32> %a, <4 x i32> %b, <4 x i32> %c) {
; CHECK-LABEL: cmpsle_v4i1:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.i32 eq, q0, zr
; CHECK-NEXT:    vpsel q0, q1, q0
; CHECK-NEXT:    bx lr
entry:
  %c1 = icmp eq <4 x i32> %a, zeroinitializer
  %o = xor <4 x i1> %c1, <i1 -1, i1 -1, i1 -1, i1 -1>
  %s = select <4 x i1> %o, <4 x i32> %a, <4 x i32> %b
  ret <4 x i32> %s
}

define arm_aapcs_vfpcc <4 x i32> @cmpsge_v4i1(<4 x i32> %a, <4 x i32> %b, <4 x i32> %c) {
; CHECK-LABEL: cmpsge_v4i1:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.i32 eq, q0, zr
; CHECK-NEXT:    vpsel q0, q1, q0
; CHECK-NEXT:    bx lr
entry:
  %c1 = icmp eq <4 x i32> %a, zeroinitializer
  %o = xor <4 x i1> %c1, <i1 -1, i1 -1, i1 -1, i1 -1>
  %s = select <4 x i1> %o, <4 x i32> %a, <4 x i32> %b
  ret <4 x i32> %s
}

define arm_aapcs_vfpcc <4 x i32> @cmpult_v4i1(<4 x i32> %a, <4 x i32> %b, <4 x i32> %c) {
; CHECK-LABEL: cmpult_v4i1:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.i32 eq, q0, zr
; CHECK-NEXT:    vpsel q0, q1, q0
; CHECK-NEXT:    bx lr
entry:
  %c1 = icmp eq <4 x i32> %a, zeroinitializer
  %o = xor <4 x i1> %c1, <i1 -1, i1 -1, i1 -1, i1 -1>
  %s = select <4 x i1> %o, <4 x i32> %a, <4 x i32> %b
  ret <4 x i32> %s
}

define arm_aapcs_vfpcc <4 x i32> @cmpugt_v4i1(<4 x i32> %a, <4 x i32> %b, <4 x i32> %c) {
; CHECK-LABEL: cmpugt_v4i1:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.i32 eq, q0, zr
; CHECK-NEXT:    vpsel q0, q1, q0
; CHECK-NEXT:    bx lr
entry:
  %c1 = icmp eq <4 x i32> %a, zeroinitializer
  %o = xor <4 x i1> %c1, <i1 -1, i1 -1, i1 -1, i1 -1>
  %s = select <4 x i1> %o, <4 x i32> %a, <4 x i32> %b
  ret <4 x i32> %s
}

define arm_aapcs_vfpcc <4 x i32> @cmpule_v4i1(<4 x i32> %a, <4 x i32> %b, <4 x i32> %c) {
; CHECK-LABEL: cmpule_v4i1:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.i32 eq, q0, zr
; CHECK-NEXT:    vpsel q0, q1, q0
; CHECK-NEXT:    bx lr
entry:
  %c1 = icmp eq <4 x i32> %a, zeroinitializer
  %o = xor <4 x i1> %c1, <i1 -1, i1 -1, i1 -1, i1 -1>
  %s = select <4 x i1> %o, <4 x i32> %a, <4 x i32> %b
  ret <4 x i32> %s
}

define arm_aapcs_vfpcc <4 x i32> @cmpuge_v4i1(<4 x i32> %a, <4 x i32> %b, <4 x i32> %c) {
; CHECK-LABEL: cmpuge_v4i1:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.i32 eq, q0, zr
; CHECK-NEXT:    vpsel q0, q1, q0
; CHECK-NEXT:    bx lr
entry:
  %c1 = icmp eq <4 x i32> %a, zeroinitializer
  %o = xor <4 x i1> %c1, <i1 -1, i1 -1, i1 -1, i1 -1>
  %s = select <4 x i1> %o, <4 x i32> %a, <4 x i32> %b
  ret <4 x i32> %s
}




define arm_aapcs_vfpcc <8 x i16> @cmpeqz_v8i1(<8 x i16> %a, <8 x i16> %b) {
; CHECK-LABEL: cmpeqz_v8i1:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.i16 eq, q0, zr
; CHECK-NEXT:    vpsel q0, q1, q0
; CHECK-NEXT:    bx lr
entry:
  %c1 = icmp eq <8 x i16> %a, zeroinitializer
  %o = xor <8 x i1> %c1, <i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1>
  %s = select <8 x i1> %o, <8 x i16> %a, <8 x i16> %b
  ret <8 x i16> %s
}

define arm_aapcs_vfpcc <8 x i16> @cmpeq_v8i1(<8 x i16> %a, <8 x i16> %b, <8 x i16> %c) {
; CHECK-LABEL: cmpeq_v8i1:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.i16 eq, q0, zr
; CHECK-NEXT:    vpsel q0, q1, q0
; CHECK-NEXT:    bx lr
entry:
  %c1 = icmp eq <8 x i16> %a, zeroinitializer
  %o = xor <8 x i1> %c1, <i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1>
  %s = select <8 x i1> %o, <8 x i16> %a, <8 x i16> %b
  ret <8 x i16> %s
}


define arm_aapcs_vfpcc <16 x i8> @cmpeqz_v16i1(<16 x i8> %a, <16 x i8> %b) {
; CHECK-LABEL: cmpeqz_v16i1:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.i8 eq, q0, zr
; CHECK-NEXT:    vpsel q0, q1, q0
; CHECK-NEXT:    bx lr
entry:
  %c1 = icmp eq <16 x i8> %a, zeroinitializer
  %o = xor <16 x i1> %c1, <i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1>
  %s = select <16 x i1> %o, <16 x i8> %a, <16 x i8> %b
  ret <16 x i8> %s
}

define arm_aapcs_vfpcc <16 x i8> @cmpeq_v16i1(<16 x i8> %a, <16 x i8> %b, <16 x i8> %c) {
; CHECK-LABEL: cmpeq_v16i1:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.i8 eq, q0, zr
; CHECK-NEXT:    vpsel q0, q1, q0
; CHECK-NEXT:    bx lr
entry:
  %c1 = icmp eq <16 x i8> %a, zeroinitializer
  %o = xor <16 x i1> %c1, <i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1>
  %s = select <16 x i1> %o, <16 x i8> %a, <16 x i8> %b
  ret <16 x i8> %s
}


define arm_aapcs_vfpcc <2 x i64> @cmpeqz_v2i1(<2 x i64> %a, <2 x i64> %b) {
; CHECK-LABEL: cmpeqz_v2i1:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vmov r0, s1
; CHECK-NEXT:    vmov r1, s0
; CHECK-NEXT:    orrs r0, r1
; CHECK-NEXT:    vmov r1, s2
; CHECK-NEXT:    cset r0, eq
; CHECK-NEXT:    tst.w r0, #1
; CHECK-NEXT:    csetm r0, ne
; CHECK-NEXT:    vmov.32 q2[0], r0
; CHECK-NEXT:    vmov.32 q2[1], r0
; CHECK-NEXT:    vmov r0, s3
; CHECK-NEXT:    orrs r0, r1
; CHECK-NEXT:    cset r0, eq
; CHECK-NEXT:    tst.w r0, #1
; CHECK-NEXT:    csetm r0, ne
; CHECK-NEXT:    vmov.32 q2[2], r0
; CHECK-NEXT:    vmov.32 q2[3], r0
; CHECK-NEXT:    vbic q0, q0, q2
; CHECK-NEXT:    vand q1, q1, q2
; CHECK-NEXT:    vorr q0, q1, q0
; CHECK-NEXT:    bx lr
entry:
  %c1 = icmp eq <2 x i64> %a, zeroinitializer
  %o = xor <2 x i1> %c1, <i1 -1, i1 -1>
  %s = select <2 x i1> %o, <2 x i64> %a, <2 x i64> %b
  ret <2 x i64> %s
}

define arm_aapcs_vfpcc <2 x i64> @cmpeq_v2i1(<2 x i64> %a, <2 x i64> %b, <2 x i64> %c) {
; CHECK-LABEL: cmpeq_v2i1:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vmov r0, s1
; CHECK-NEXT:    vmov r1, s0
; CHECK-NEXT:    orrs r0, r1
; CHECK-NEXT:    vmov r1, s2
; CHECK-NEXT:    cset r0, eq
; CHECK-NEXT:    tst.w r0, #1
; CHECK-NEXT:    csetm r0, ne
; CHECK-NEXT:    vmov.32 q2[0], r0
; CHECK-NEXT:    vmov.32 q2[1], r0
; CHECK-NEXT:    vmov r0, s3
; CHECK-NEXT:    orrs r0, r1
; CHECK-NEXT:    cset r0, eq
; CHECK-NEXT:    tst.w r0, #1
; CHECK-NEXT:    csetm r0, ne
; CHECK-NEXT:    vmov.32 q2[2], r0
; CHECK-NEXT:    vmov.32 q2[3], r0
; CHECK-NEXT:    vbic q0, q0, q2
; CHECK-NEXT:    vand q1, q1, q2
; CHECK-NEXT:    vorr q0, q1, q0
; CHECK-NEXT:    bx lr
entry:
  %c1 = icmp eq <2 x i64> %a, zeroinitializer
  %o = xor <2 x i1> %c1, <i1 -1, i1 -1>
  %s = select <2 x i1> %o, <2 x i64> %a, <2 x i64> %b
  ret <2 x i64> %s
}

define arm_aapcs_vfpcc <4 x i32> @vpnot_v4i1(<4 x i32> %a, <4 x i32> %b, <4 x i32> %c) {
; CHECK-LABEL: vpnot_v4i1:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.s32 lt, q0, zr
; CHECK-NEXT:    vpst
; CHECK-NEXT:    vcmpt.s32 gt, q1, zr
; CHECK-NEXT:    vpnot
; CHECK-NEXT:    vpst
; CHECK-NEXT:    vcmpt.i32 eq, q2, zr
; CHECK-NEXT:    vpsel q0, q0, q1
; CHECK-NEXT:    bx lr
entry:
  %c1 = icmp slt <4 x i32> %a, zeroinitializer
  %c2 = icmp sgt <4 x i32> %b, zeroinitializer
  %c3 = icmp eq <4 x i32> %c, zeroinitializer
  %o1 = and <4 x i1> %c1, %c2
  %o2 = xor <4 x i1> %o1, <i1 -1, i1 -1, i1 -1, i1 -1>
  %o = and <4 x i1> %c3, %o2
  %s = select <4 x i1> %o, <4 x i32> %a, <4 x i32> %b
  ret <4 x i32> %s
}
