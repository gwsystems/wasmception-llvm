@ RUN: llvm-mc -mcpu=cortex-a8 -triple arm-unknown-unkown -show-encoding < %s | FileCheck %s
@ XFAIL: *

@ CHECK: vmov.i8	d16, #0x8               @ encoding: [0x18,0x0e,0xc0,0xf2]
	vmov.i8	d16, #0x8
@ CHECK: vmov.i16	d16, #0x10      @ encoding: [0x10,0x08,0xc1,0xf2]
	vmov.i16	d16, #0x10
@ CHECK: vmov.i16	d16, #0x1000    @ encoding: [0x10,0x0a,0xc1,0xf2]
	vmov.i16	d16, #0x1000
@ CHECK: vmov.i32	d16, #0x20      @ encoding: [0x10,0x00,0xc2,0xf2]
	vmov.i32	d16, #0x20
@ CHECK: vmov.i32	d16, #0x2000    @ encoding: [0x10,0x02,0xc2,0xf2]
	vmov.i32	d16, #0x2000
@ CHECK: vmov.i32	d16, #0x200000  @ encoding: [0x10,0x04,0xc2,0xf2]
	vmov.i32	d16, #0x200000
@ CHECK: vmov.i32	d16, #0x20000000 @ encoding: [0x10,0x06,0xc2,0xf2]
	vmov.i32	d16, #0x20000000
@ CHECK: vmov.i32	d16, #0x20FF    @ encoding: [0x10,0x0c,0xc2,0xf2]
	vmov.i32	d16, #0x20FF
@ CHECK: vmov.i32	d16, #0x20FFFF  @ encoding: [0x10,0x0d,0xc2,0xf2]
	vmov.i32	d16, #0x20FFFF
@ CHECK: vmov.i64	d16, #0xFF0000FF0000FFFF @ encoding: [0x33,0x0e,0xc1,0xf3]
	vmov.i64	d16, #0xFF0000FF0000FFFF
@ CHECK: vmov.i8	q8, #0x8                @ encoding: [0x58,0x0e,0xc0,0xf2]
	vmov.i8	q8, #0x8
@ CHECK: vmov.i16	q8, #0x10       @ encoding: [0x50,0x08,0xc1,0xf2]
	vmov.i16	q8, #0x10
@ CHECK: vmov.i16	q8, #0x1000     @ encoding: [0x50,0x0a,0xc1,0xf2]
	vmov.i16	q8, #0x1000
@ CHECK: vmov.i32	q8, #0x20       @ encoding: [0x50,0x00,0xc2,0xf2]
	vmov.i32	q8, #0x20
@ CHECK: vmov.i32	q8, #0x2000     @ encoding: [0x50,0x02,0xc2,0xf2]
	vmov.i32	q8, #0x2000
@ CHECK: vmov.i32	q8, #0x200000   @ encoding: [0x50,0x04,0xc2,0xf2]
	vmov.i32	q8, #0x200000
@ CHECK: vmov.i32	q8, #0x20000000 @ encoding: [0x50,0x06,0xc2,0xf2]
	vmov.i32	q8, #0x20000000
@ CHECK: vmov.i32	q8, #0x20FF     @ encoding: [0x50,0x0c,0xc2,0xf2]
	vmov.i32	q8, #0x20FF
@ CHECK: vmov.i32	q8, #0x20FFFF   @ encoding: [0x50,0x0d,0xc2,0xf2]
	vmov.i32	q8, #0x20FFFF
@ CHECK: vmov.i64	q8, #0xFF0000FF0000FFFF @ encoding: [0x73,0x0e,0xc1,0xf3]
	vmov.i64	q8, #0xFF0000FF0000FFFF
@ CHECK: vmvn.i16	d16, #0x10      @ encoding: [0x30,0x08,0xc1,0xf2]
	vmvn.i16	d16, #0x10
@ CHECK: vmvn.i16	d16, #0x1000    @ encoding: [0x30,0x0a,0xc1,0xf2]
	vmvn.i16	d16, #0x1000
@ CHECK: vmvn.i32	d16, #0x20      @ encoding: [0x30,0x00,0xc2,0xf2]
	vmvn.i32	d16, #0x20
@ CHECK: vmvn.i32	d16, #0x2000    @ encoding: [0x30,0x02,0xc2,0xf2]
	vmvn.i32	d16, #0x2000
@ CHECK: vmvn.i32	d16, #0x200000  @ encoding: [0x30,0x04,0xc2,0xf2]
	vmvn.i32	d16, #0x200000
@ CHECK: vmvn.i32	d16, #0x20000000 @ encoding: [0x30,0x06,0xc2,0xf2]
	vmvn.i32	d16, #0x20000000
@ CHECK: vmvn.i32	d16, #0x20FF    @ encoding: [0x30,0x0c,0xc2,0xf2]
	vmvn.i32	d16, #0x20FF
@ CHECK: vmvn.i32	d16, #0x20FFFF  @ encoding: [0x30,0x0d,0xc2,0xf2]
	vmvn.i32	d16, #0x20FFFF
@ CHECK: vmovl.s8	q8, d16         @ encoding: [0x30,0x0a,0xc8,0xf2]
	vmovl.s8	q8, d16
@ CHECK: vmovl.s16	q8, d16         @ encoding: [0x30,0x0a,0xd0,0xf2]
	vmovl.s16	q8, d16
@ CHECK: vmovl.s32	q8, d16         @ encoding: [0x30,0x0a,0xe0,0xf2]
	vmovl.s32	q8, d16
@ CHECK: vmovl.u8	q8, d16         @ encoding: [0x30,0x0a,0xc8,0xf3]
	vmovl.u8	q8, d16
@ CHECK: vmovl.u16	q8, d16         @ encoding: [0x30,0x0a,0xd0,0xf3]
	vmovl.u16	q8, d16
@ CHECK: vmovl.u32	q8, d16         @ encoding: [0x30,0x0a,0xe0,0xf3]
	vmovl.u32	q8, d16
@ CHECK: vmovn.i16	d16, q8         @ encoding: [0x20,0x02,0xf2,0xf3]
	vmovn.i16	d16, q8
@ CHECK: vmovn.i32	d16, q8         @ encoding: [0x20,0x02,0xf6,0xf3]
	vmovn.i32	d16, q8
@ CHECK: vmovn.i64	d16, q8         @ encoding: [0x20,0x02,0xfa,0xf3]
	vmovn.i64	d16, q8
@ CHECK: vqmovn.s16	d16, q8         @ encoding: [0xa0,0x02,0xf2,0xf3]
	vqmovn.s16	d16, q8
@ CHECK: vqmovn.s32	d16, q8         @ encoding: [0xa0,0x02,0xf6,0xf3]
	vqmovn.s32	d16, q8
@ CHECK: vqmovn.s64	d16, q8         @ encoding: [0xa0,0x02,0xfa,0xf3]
	vqmovn.s64	d16, q8
@ CHECK: vqmovn.u16	d16, q8         @ encoding: [0xe0,0x02,0xf2,0xf3]
	vqmovn.u16	d16, q8
@ CHECK: vqmovn.u32	d16, q8         @ encoding: [0xe0,0x02,0xf6,0xf3]
	vqmovn.u32	d16, q8
@ CHECK: vqmovn.u64	d16, q8         @ encoding: [0xe0,0x02,0xfa,0xf3]
	vqmovn.u64	d16, q8
@ CHECK: vqmovun.s16	d16, q8         @ encoding: [0x60,0x02,0xf2,0xf3]
	vqmovun.s16	d16, q8
@ CHECK: vqmovun.s32	d16, q8         @ encoding: [0x60,0x02,0xf6,0xf3]
	vqmovun.s32	d16, q8
@ CHECK: vqmovun.s64	d16, q8         @ encoding: [0x60,0x02,0xfa,0xf3]
	vqmovun.s64	d16, q8
@ CHECK: vmov.s8	r0, d16[1]              @ encoding: [0xb0,0x0b,0x50,0xee]
	vmov.s8	r0, d16[1]
@ CHECK: vmov.s16	r0, d16[1]      @ encoding: [0xf0,0x0b,0x10,0xee]
	vmov.s16	r0, d16[1]
@ CHECK: vmov.u8	r0, d16[1]              @ encoding: [0xb0,0x0b,0xd0,0xee]
	vmov.u8	r0, d16[1]
@ CHECK: vmov.u16	r0, d16[1]      @ encoding: [0xf0,0x0b,0x90,0xee]
	vmov.u16	r0, d16[1]
@ CHECK: vmov.32	r0, d16[1]              @ encoding: [0x90,0x0b,0x30,0xee]
	vmov.32	r0, d16[1]
@ CHECK: vmov.8	d16[1], r1              @ encoding: [0xb0,0x1b,0x40,0xee]
	vmov.8	d16[1], r1
@ CHECK: vmov.16	d16[1], r1              @ encoding: [0xf0,0x1b,0x00,0xee]
	vmov.16	d16[1], r1
@ CHECK: vmov.32	d16[1], r1              @ encoding: [0x90,0x1b,0x20,0xee]
	vmov.32	d16[1], r1
@ CHECK: vmov.8	d18[1], r1              @ encoding: [0xb0,0x1b,0x42,0xee]
	vmov.8	d18[1], r1
@ CHECK: vmov.16	d18[1], r1              @ encoding: [0xf0,0x1b,0x02,0xee]
	vmov.16	d18[1], r1
@ CHECK: vmov.32	d18[1], r1              @ encoding: [0x90,0x1b,0x22,0xee]
	vmov.32	d18[1], r1
