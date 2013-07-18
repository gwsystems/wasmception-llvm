@ RUN: llvm-mc -triple armv8 -mattr=+neon -show-encoding < %s | FileCheck %s

vmaxnm.f32 d4, d5, d1
@ CHECK: vmaxnm.f32 d4, d5, d1 @ encoding: [0x11,0x4f,0x05,0xf3]
vmaxnm.f32 q2, q4, q6
@ CHECK: vmaxnm.f32 q2, q4, q6 @ encoding: [0x5c,0x4f,0x08,0xf3]
vminnm.f32 d5, d4, d30
@ CHECK: vminnm.f32 d5, d4, d30 @ encoding: [0x3e,0x5f,0x24,0xf3]
vminnm.f32 q0, q13, q2
@ CHECK: vminnm.f32 q0, q13, q2 @ encoding: [0xd4,0x0f,0x2a,0xf3]

vcvta.s32.f32	d4, d6
@ CHECK: vcvta.s32.f32	d4, d6 @ encoding: [0x06,0x40,0xbb,0xf3]
vcvta.u32.f32	d12, d10
@ CHECK: vcvta.u32.f32	d12, d10 @ encoding: [0x8a,0xc0,0xbb,0xf3]
vcvta.s32.f32	q4, q6
@ CHECK: vcvta.s32.f32	q4, q6 @ encoding: [0x4c,0x80,0xbb,0xf3]
vcvta.u32.f32	q4, q10
@ CHECK: vcvta.u32.f32	q4, q10 @ encoding: [0xe4,0x80,0xbb,0xf3]

vcvtm.s32.f32	d1, d30
@ CHECK: vcvtm.s32.f32	d1, d30 @ encoding: [0x2e,0x13,0xbb,0xf3]
vcvtm.u32.f32	d12, d10
@ CHECK: vcvtm.u32.f32	d12, d10 @ encoding: [0x8a,0xc3,0xbb,0xf3]
vcvtm.s32.f32	q1, q10
@ CHECK: vcvtm.s32.f32	q1, q10 @ encoding: [0x64,0x23,0xbb,0xf3]
vcvtm.u32.f32	q13, q1
@ CHECK: vcvtm.u32.f32	q13, q1 @ encoding: [0xc2,0xa3,0xfb,0xf3]

vcvtn.s32.f32	d15, d17
@ CHECK: vcvtn.s32.f32	d15, d17 @ encoding: [0x21,0xf1,0xbb,0xf3]
vcvtn.u32.f32	d5, d3
@ CHECK: vcvtn.u32.f32	d5, d3 @ encoding: [0x83,0x51,0xbb,0xf3]
vcvtn.s32.f32	q3, q8
@ CHECK: vcvtn.s32.f32	q3, q8 @ encoding: [0x60,0x61,0xbb,0xf3]
vcvtn.u32.f32	q5, q3
@ CHECK: vcvtn.u32.f32	q5, q3 @ encoding: [0xc6,0xa1,0xbb,0xf3]

vcvtp.s32.f32	d11, d21
@ CHECK: vcvtp.s32.f32	d11, d21 @ encoding: [0x25,0xb2,0xbb,0xf3]
vcvtp.u32.f32	d14, d23
@ CHECK: vcvtp.u32.f32	d14, d23 @ encoding: [0xa7,0xe2,0xbb,0xf3]
vcvtp.s32.f32	q4, q15
@ CHECK: vcvtp.s32.f32	q4, q15 @ encoding: [0x6e,0x82,0xbb,0xf3]
vcvtp.u32.f32	q9, q8
@ CHECK: vcvtp.u32.f32	q9, q8 @ encoding: [0xe0,0x22,0xfb,0xf3]
