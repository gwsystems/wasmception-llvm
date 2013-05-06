# RUN: llvm-mc -triple s390x-linux-gnu -show-encoding %s | FileCheck %s

#CHECK: nilf	%r0, 0                  # encoding: [0xc0,0x0b,0x00,0x00,0x00,0x00]
#CHECK: nilf	%r0, 4294967295         # encoding: [0xc0,0x0b,0xff,0xff,0xff,0xff]
#CHECK: nilf	%r15, 0                 # encoding: [0xc0,0xfb,0x00,0x00,0x00,0x00]

	nilf	%r0, 0
	nilf	%r0, 0xffffffff
	nilf	%r15, 0
