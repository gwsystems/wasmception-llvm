# RUN: llvm-mc -triple s390x-linux-gnu -show-encoding %s | FileCheck %s

#CHECK: agfi	%r0, -2147483648        # encoding: [0xc2,0x08,0x80,0x00,0x00,0x00]
#CHECK: agfi	%r0, -1                 # encoding: [0xc2,0x08,0xff,0xff,0xff,0xff]
#CHECK: agfi	%r0, 0                  # encoding: [0xc2,0x08,0x00,0x00,0x00,0x00]
#CHECK: agfi	%r0, 1                  # encoding: [0xc2,0x08,0x00,0x00,0x00,0x01]
#CHECK: agfi	%r0, 2147483647         # encoding: [0xc2,0x08,0x7f,0xff,0xff,0xff]
#CHECK: agfi	%r15, 0                 # encoding: [0xc2,0xf8,0x00,0x00,0x00,0x00]

	agfi	%r0, -1 << 31
	agfi	%r0, -1
	agfi	%r0, 0
	agfi	%r0, 1
	agfi	%r0, (1 << 31) - 1
	agfi	%r15, 0
