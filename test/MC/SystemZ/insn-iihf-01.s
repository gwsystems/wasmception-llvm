# RUN: llvm-mc -triple s390x-linux-gnu -show-encoding %s | FileCheck %s

#CHECK: iihf	%r0, 0                  # encoding: [0xc0,0x08,0x00,0x00,0x00,0x00]
#CHECK: iihf	%r0, 4294967295         # encoding: [0xc0,0x08,0xff,0xff,0xff,0xff]
#CHECK: iihf	%r15, 0                 # encoding: [0xc0,0xf8,0x00,0x00,0x00,0x00]

	iihf	%r0, 0
	iihf	%r0, 0xffffffff
	iihf	%r15, 0
