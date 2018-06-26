// RUN: llvm-mc -triple aarch64-unknown-none-eabi -filetype asm -o - %s 2>&1 | FileCheck %s

	.cpu generic

	fminnm d0, d0, d1

	.cpu generic+fp

	fminnm d0, d0, d1

	.cpu generic+simd

	addp v0.4s, v0.4s, v0.4s

	.cpu generic+crc

	crc32cx w0, w1, x3

	.cpu generic+crypto+nocrc

	aesd v0.16b, v2.16b

	.cpu generic+lse
        casa  w5, w7, [x20]

// CHECK:	fminnm d0, d0, d1
// CHECK:	fminnm d0, d0, d1
// CHECK:	addp v0.4s, v0.4s, v0.4s
// CHECK:	crc32cx w0, w1, x3
// CHECK:	aesd v0.16b, v2.16b
// CHECK:       casa  w5, w7, [x20]
