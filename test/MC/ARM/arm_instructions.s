@ RUN: llvm-mc -mcpu=cortex-a8 -triple arm-unknown-unknown -show-encoding %s | FileCheck %s

@ CHECK: nop
@ CHECK: encoding: [0x00,0xf0,0x20,0xe3]
        nop

@ CHECK: nopeq
@ CHECK: encoding: [0x00,0xf0,0x20,0x03]
        nopeq

@ CHECK: bx	lr
@ CHECK: encoding: [0x1e,0xff,0x2f,0xe1]
bx lr

@ CHECK: vqdmull.s32	q8, d17, d16
@ CHECK: encoding: [0xa0,0x0d,0xe1,0xf2]
vqdmull.s32     q8, d17, d16

@ CHECK: vldr.64	d17, [r0]
@ CHECK: encoding: [0x00,0x0b,0x10,0xed]
vldr.64	d17, [r0]

