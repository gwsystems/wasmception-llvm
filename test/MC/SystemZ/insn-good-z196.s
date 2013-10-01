# For z196 and above.
# RUN: llvm-mc -triple s390x-linux-gnu -mcpu=z196 -show-encoding %s | FileCheck %s

#CHECK: aghik	%r0, %r0, -32768        # encoding: [0xec,0x00,0x80,0x00,0x00,0xd9]
#CHECK: aghik	%r0, %r0, -1            # encoding: [0xec,0x00,0xff,0xff,0x00,0xd9]
#CHECK: aghik	%r0, %r0, 0             # encoding: [0xec,0x00,0x00,0x00,0x00,0xd9]
#CHECK: aghik	%r0, %r0, 1             # encoding: [0xec,0x00,0x00,0x01,0x00,0xd9]
#CHECK: aghik	%r0, %r0, 32767         # encoding: [0xec,0x00,0x7f,0xff,0x00,0xd9]
#CHECK: aghik	%r0, %r15, 0            # encoding: [0xec,0x0f,0x00,0x00,0x00,0xd9]
#CHECK: aghik	%r15, %r0, 0            # encoding: [0xec,0xf0,0x00,0x00,0x00,0xd9]
#CHECK: aghik	%r7, %r8, -16           # encoding: [0xec,0x78,0xff,0xf0,0x00,0xd9]

	aghik	%r0, %r0, -32768
	aghik	%r0, %r0, -1
	aghik	%r0, %r0, 0
	aghik	%r0, %r0, 1
	aghik	%r0, %r0, 32767
	aghik	%r0, %r15, 0
	aghik	%r15, %r0, 0
	aghik	%r7, %r8, -16

#CHECK: agrk	%r0, %r0, %r0           # encoding: [0xb9,0xe8,0x00,0x00]
#CHECK: agrk	%r0, %r0, %r15          # encoding: [0xb9,0xe8,0xf0,0x00]
#CHECK: agrk	%r0, %r15, %r0          # encoding: [0xb9,0xe8,0x00,0x0f]
#CHECK: agrk	%r15, %r0, %r0          # encoding: [0xb9,0xe8,0x00,0xf0]
#CHECK: agrk	%r7, %r8, %r9           # encoding: [0xb9,0xe8,0x90,0x78]

	agrk	%r0,%r0,%r0
	agrk	%r0,%r0,%r15
	agrk	%r0,%r15,%r0
	agrk	%r15,%r0,%r0
	agrk	%r7,%r8,%r9

#CHECK: ahik	%r0, %r0, -32768        # encoding: [0xec,0x00,0x80,0x00,0x00,0xd8]
#CHECK: ahik	%r0, %r0, -1            # encoding: [0xec,0x00,0xff,0xff,0x00,0xd8]
#CHECK: ahik	%r0, %r0, 0             # encoding: [0xec,0x00,0x00,0x00,0x00,0xd8]
#CHECK: ahik	%r0, %r0, 1             # encoding: [0xec,0x00,0x00,0x01,0x00,0xd8]
#CHECK: ahik	%r0, %r0, 32767         # encoding: [0xec,0x00,0x7f,0xff,0x00,0xd8]
#CHECK: ahik	%r0, %r15, 0            # encoding: [0xec,0x0f,0x00,0x00,0x00,0xd8]
#CHECK: ahik	%r15, %r0, 0            # encoding: [0xec,0xf0,0x00,0x00,0x00,0xd8]
#CHECK: ahik	%r7, %r8, -16           # encoding: [0xec,0x78,0xff,0xf0,0x00,0xd8]

	ahik	%r0, %r0, -32768
	ahik	%r0, %r0, -1
	ahik	%r0, %r0, 0
	ahik	%r0, %r0, 1
	ahik	%r0, %r0, 32767
	ahik	%r0, %r15, 0
	ahik	%r15, %r0, 0
	ahik	%r7, %r8, -16

#CHECK: alghsik	%r0, %r0, -32768        # encoding: [0xec,0x00,0x80,0x00,0x00,0xdb]
#CHECK: alghsik	%r0, %r0, -1            # encoding: [0xec,0x00,0xff,0xff,0x00,0xdb]
#CHECK: alghsik	%r0, %r0, 0             # encoding: [0xec,0x00,0x00,0x00,0x00,0xdb]
#CHECK: alghsik	%r0, %r0, 1             # encoding: [0xec,0x00,0x00,0x01,0x00,0xdb]
#CHECK: alghsik	%r0, %r0, 32767         # encoding: [0xec,0x00,0x7f,0xff,0x00,0xdb]
#CHECK: alghsik	%r0, %r15, 0            # encoding: [0xec,0x0f,0x00,0x00,0x00,0xdb]
#CHECK: alghsik	%r15, %r0, 0            # encoding: [0xec,0xf0,0x00,0x00,0x00,0xdb]
#CHECK: alghsik	%r7, %r8, -16           # encoding: [0xec,0x78,0xff,0xf0,0x00,0xdb]

	alghsik	%r0, %r0, -32768
	alghsik	%r0, %r0, -1
	alghsik	%r0, %r0, 0
	alghsik	%r0, %r0, 1
	alghsik	%r0, %r0, 32767
	alghsik	%r0, %r15, 0
	alghsik	%r15, %r0, 0
	alghsik	%r7, %r8, -16

#CHECK: algrk	%r0, %r0, %r0           # encoding: [0xb9,0xea,0x00,0x00]
#CHECK: algrk	%r0, %r0, %r15          # encoding: [0xb9,0xea,0xf0,0x00]
#CHECK: algrk	%r0, %r15, %r0          # encoding: [0xb9,0xea,0x00,0x0f]
#CHECK: algrk	%r15, %r0, %r0          # encoding: [0xb9,0xea,0x00,0xf0]
#CHECK: algrk	%r7, %r8, %r9           # encoding: [0xb9,0xea,0x90,0x78]

	algrk	%r0,%r0,%r0
	algrk	%r0,%r0,%r15
	algrk	%r0,%r15,%r0
	algrk	%r15,%r0,%r0
	algrk	%r7,%r8,%r9

#CHECK: alhsik	%r0, %r0, -32768        # encoding: [0xec,0x00,0x80,0x00,0x00,0xda]
#CHECK: alhsik	%r0, %r0, -1            # encoding: [0xec,0x00,0xff,0xff,0x00,0xda]
#CHECK: alhsik	%r0, %r0, 0             # encoding: [0xec,0x00,0x00,0x00,0x00,0xda]
#CHECK: alhsik	%r0, %r0, 1             # encoding: [0xec,0x00,0x00,0x01,0x00,0xda]
#CHECK: alhsik	%r0, %r0, 32767         # encoding: [0xec,0x00,0x7f,0xff,0x00,0xda]
#CHECK: alhsik	%r0, %r15, 0            # encoding: [0xec,0x0f,0x00,0x00,0x00,0xda]
#CHECK: alhsik	%r15, %r0, 0            # encoding: [0xec,0xf0,0x00,0x00,0x00,0xda]
#CHECK: alhsik	%r7, %r8, -16           # encoding: [0xec,0x78,0xff,0xf0,0x00,0xda]

	alhsik	%r0, %r0, -32768
	alhsik	%r0, %r0, -1
	alhsik	%r0, %r0, 0
	alhsik	%r0, %r0, 1
	alhsik	%r0, %r0, 32767
	alhsik	%r0, %r15, 0
	alhsik	%r15, %r0, 0
	alhsik	%r7, %r8, -16

#CHECK: alrk	%r0, %r0, %r0           # encoding: [0xb9,0xfa,0x00,0x00]
#CHECK: alrk	%r0, %r0, %r15          # encoding: [0xb9,0xfa,0xf0,0x00]
#CHECK: alrk	%r0, %r15, %r0          # encoding: [0xb9,0xfa,0x00,0x0f]
#CHECK: alrk	%r15, %r0, %r0          # encoding: [0xb9,0xfa,0x00,0xf0]
#CHECK: alrk	%r7, %r8, %r9           # encoding: [0xb9,0xfa,0x90,0x78]

	alrk	%r0,%r0,%r0
	alrk	%r0,%r0,%r15
	alrk	%r0,%r15,%r0
	alrk	%r15,%r0,%r0
	alrk	%r7,%r8,%r9

#CHECK: ark	%r0, %r0, %r0           # encoding: [0xb9,0xf8,0x00,0x00]
#CHECK: ark	%r0, %r0, %r15          # encoding: [0xb9,0xf8,0xf0,0x00]
#CHECK: ark	%r0, %r15, %r0          # encoding: [0xb9,0xf8,0x00,0x0f]
#CHECK: ark	%r15, %r0, %r0          # encoding: [0xb9,0xf8,0x00,0xf0]
#CHECK: ark	%r7, %r8, %r9           # encoding: [0xb9,0xf8,0x90,0x78]

	ark	%r0,%r0,%r0
	ark	%r0,%r0,%r15
	ark	%r0,%r15,%r0
	ark	%r15,%r0,%r0
	ark	%r7,%r8,%r9

#CHECK: fidbra	%f0, 0, %f0, 0          # encoding: [0xb3,0x5f,0x00,0x00]
#CHECK: fidbra	%f0, 0, %f0, 15         # encoding: [0xb3,0x5f,0x0f,0x00]
#CHECK: fidbra	%f0, 0, %f15, 0         # encoding: [0xb3,0x5f,0x00,0x0f]
#CHECK: fidbra	%f0, 15, %f0, 0         # encoding: [0xb3,0x5f,0xf0,0x00]
#CHECK: fidbra	%f4, 5, %f6, 7          # encoding: [0xb3,0x5f,0x57,0x46]
#CHECK: fidbra	%f15, 0, %f0, 0         # encoding: [0xb3,0x5f,0x00,0xf0]

	fidbra	%f0, 0, %f0, 0
	fidbra	%f0, 0, %f0, 15
	fidbra	%f0, 0, %f15, 0
	fidbra	%f0, 15, %f0, 0
	fidbra	%f4, 5, %f6, 7
	fidbra	%f15, 0, %f0, 0

#CHECK: fiebra	%f0, 0, %f0, 0          # encoding: [0xb3,0x57,0x00,0x00]
#CHECK: fiebra	%f0, 0, %f0, 15         # encoding: [0xb3,0x57,0x0f,0x00]
#CHECK: fiebra	%f0, 0, %f15, 0         # encoding: [0xb3,0x57,0x00,0x0f]
#CHECK: fiebra	%f0, 15, %f0, 0         # encoding: [0xb3,0x57,0xf0,0x00]
#CHECK: fiebra	%f4, 5, %f6, 7          # encoding: [0xb3,0x57,0x57,0x46]
#CHECK: fiebra	%f15, 0, %f0, 0         # encoding: [0xb3,0x57,0x00,0xf0]

	fiebra	%f0, 0, %f0, 0
	fiebra	%f0, 0, %f0, 15
	fiebra	%f0, 0, %f15, 0
	fiebra	%f0, 15, %f0, 0
	fiebra	%f4, 5, %f6, 7
	fiebra	%f15, 0, %f0, 0

#CHECK: fixbra	%f0, 0, %f0, 0          # encoding: [0xb3,0x47,0x00,0x00]
#CHECK: fixbra	%f0, 0, %f0, 15         # encoding: [0xb3,0x47,0x0f,0x00]
#CHECK: fixbra	%f0, 0, %f13, 0         # encoding: [0xb3,0x47,0x00,0x0d]
#CHECK: fixbra	%f0, 15, %f0, 0         # encoding: [0xb3,0x47,0xf0,0x00]
#CHECK: fixbra	%f4, 5, %f8, 9          # encoding: [0xb3,0x47,0x59,0x48]
#CHECK: fixbra	%f13, 0, %f0, 0         # encoding: [0xb3,0x47,0x00,0xd0]

	fixbra	%f0, 0, %f0, 0
	fixbra	%f0, 0, %f0, 15
	fixbra	%f0, 0, %f13, 0
	fixbra	%f0, 15, %f0, 0
	fixbra	%f4, 5, %f8, 9
	fixbra	%f13, 0, %f0, 0

#CHECK: lbh	%r0, -524288            # encoding: [0xe3,0x00,0x00,0x00,0x80,0xc0]
#CHECK: lbh	%r0, -1                 # encoding: [0xe3,0x00,0x0f,0xff,0xff,0xc0]
#CHECK: lbh	%r0, 0                  # encoding: [0xe3,0x00,0x00,0x00,0x00,0xc0]
#CHECK: lbh	%r0, 1                  # encoding: [0xe3,0x00,0x00,0x01,0x00,0xc0]
#CHECK: lbh	%r0, 524287             # encoding: [0xe3,0x00,0x0f,0xff,0x7f,0xc0]
#CHECK: lbh	%r0, 0(%r1)             # encoding: [0xe3,0x00,0x10,0x00,0x00,0xc0]
#CHECK: lbh	%r0, 0(%r15)            # encoding: [0xe3,0x00,0xf0,0x00,0x00,0xc0]
#CHECK: lbh	%r0, 524287(%r1,%r15)   # encoding: [0xe3,0x01,0xff,0xff,0x7f,0xc0]
#CHECK: lbh	%r0, 524287(%r15,%r1)   # encoding: [0xe3,0x0f,0x1f,0xff,0x7f,0xc0]
#CHECK: lbh	%r15, 0                 # encoding: [0xe3,0xf0,0x00,0x00,0x00,0xc0]

	lbh	%r0, -524288
	lbh	%r0, -1
	lbh	%r0, 0
	lbh	%r0, 1
	lbh	%r0, 524287
	lbh	%r0, 0(%r1)
	lbh	%r0, 0(%r15)
	lbh	%r0, 524287(%r1,%r15)
	lbh	%r0, 524287(%r15,%r1)
	lbh	%r15, 0

#CHECK: lfh	%r0, -524288            # encoding: [0xe3,0x00,0x00,0x00,0x80,0xca]
#CHECK: lfh	%r0, -1                 # encoding: [0xe3,0x00,0x0f,0xff,0xff,0xca]
#CHECK: lfh	%r0, 0                  # encoding: [0xe3,0x00,0x00,0x00,0x00,0xca]
#CHECK: lfh	%r0, 1                  # encoding: [0xe3,0x00,0x00,0x01,0x00,0xca]
#CHECK: lfh	%r0, 524287             # encoding: [0xe3,0x00,0x0f,0xff,0x7f,0xca]
#CHECK: lfh	%r0, 0(%r1)             # encoding: [0xe3,0x00,0x10,0x00,0x00,0xca]
#CHECK: lfh	%r0, 0(%r15)            # encoding: [0xe3,0x00,0xf0,0x00,0x00,0xca]
#CHECK: lfh	%r0, 524287(%r1,%r15)   # encoding: [0xe3,0x01,0xff,0xff,0x7f,0xca]
#CHECK: lfh	%r0, 524287(%r15,%r1)   # encoding: [0xe3,0x0f,0x1f,0xff,0x7f,0xca]
#CHECK: lfh	%r15, 0                 # encoding: [0xe3,0xf0,0x00,0x00,0x00,0xca]

	lfh	%r0, -524288
	lfh	%r0, -1
	lfh	%r0, 0
	lfh	%r0, 1
	lfh	%r0, 524287
	lfh	%r0, 0(%r1)
	lfh	%r0, 0(%r15)
	lfh	%r0, 524287(%r1,%r15)
	lfh	%r0, 524287(%r15,%r1)
	lfh	%r15, 0

#CHECK: lhh	%r0, -524288            # encoding: [0xe3,0x00,0x00,0x00,0x80,0xc4]
#CHECK: lhh	%r0, -1                 # encoding: [0xe3,0x00,0x0f,0xff,0xff,0xc4]
#CHECK: lhh	%r0, 0                  # encoding: [0xe3,0x00,0x00,0x00,0x00,0xc4]
#CHECK: lhh	%r0, 1                  # encoding: [0xe3,0x00,0x00,0x01,0x00,0xc4]
#CHECK: lhh	%r0, 524287             # encoding: [0xe3,0x00,0x0f,0xff,0x7f,0xc4]
#CHECK: lhh	%r0, 0(%r1)             # encoding: [0xe3,0x00,0x10,0x00,0x00,0xc4]
#CHECK: lhh	%r0, 0(%r15)            # encoding: [0xe3,0x00,0xf0,0x00,0x00,0xc4]
#CHECK: lhh	%r0, 524287(%r1,%r15)   # encoding: [0xe3,0x01,0xff,0xff,0x7f,0xc4]
#CHECK: lhh	%r0, 524287(%r15,%r1)   # encoding: [0xe3,0x0f,0x1f,0xff,0x7f,0xc4]
#CHECK: lhh	%r15, 0                 # encoding: [0xe3,0xf0,0x00,0x00,0x00,0xc4]

	lhh	%r0, -524288
	lhh	%r0, -1
	lhh	%r0, 0
	lhh	%r0, 1
	lhh	%r0, 524287
	lhh	%r0, 0(%r1)
	lhh	%r0, 0(%r15)
	lhh	%r0, 524287(%r1,%r15)
	lhh	%r0, 524287(%r15,%r1)
	lhh	%r15, 0

#CHECK: loc	%r0, 0, 0               # encoding: [0xeb,0x00,0x00,0x00,0x00,0xf2]
#CHECK: loc	%r0, 0, 15              # encoding: [0xeb,0x0f,0x00,0x00,0x00,0xf2]
#CHECK: loc	%r0, -524288, 0         # encoding: [0xeb,0x00,0x00,0x00,0x80,0xf2]
#CHECK: loc	%r0, 524287, 0          # encoding: [0xeb,0x00,0x0f,0xff,0x7f,0xf2]
#CHECK: loc	%r0, 0(%r1), 0          # encoding: [0xeb,0x00,0x10,0x00,0x00,0xf2]
#CHECK: loc	%r0, 0(%r15), 0         # encoding: [0xeb,0x00,0xf0,0x00,0x00,0xf2]
#CHECK: loc	%r15, 0, 0              # encoding: [0xeb,0xf0,0x00,0x00,0x00,0xf2]
#CHECK: loc	%r1, 4095(%r2), 3       # encoding: [0xeb,0x13,0x2f,0xff,0x00,0xf2]

	loc	%r0,0,0
	loc	%r0,0,15
	loc	%r0,-524288,0
	loc	%r0,524287,0
	loc	%r0,0(%r1),0
	loc	%r0,0(%r15),0
	loc	%r15,0,0
	loc	%r1,4095(%r2),3

#CHECK: loco   %r1, 2(%r3)              # encoding: [0xeb,0x11,0x30,0x02,0x00,0xf2]
#CHECK: loch   %r1, 2(%r3)              # encoding: [0xeb,0x12,0x30,0x02,0x00,0xf2]
#CHECK: locnle %r1, 2(%r3)              # encoding: [0xeb,0x13,0x30,0x02,0x00,0xf2]
#CHECK: locl   %r1, 2(%r3)              # encoding: [0xeb,0x14,0x30,0x02,0x00,0xf2]
#CHECK: locnhe %r1, 2(%r3)              # encoding: [0xeb,0x15,0x30,0x02,0x00,0xf2]
#CHECK: loclh  %r1, 2(%r3)              # encoding: [0xeb,0x16,0x30,0x02,0x00,0xf2]
#CHECK: locne  %r1, 2(%r3)              # encoding: [0xeb,0x17,0x30,0x02,0x00,0xf2]
#CHECK: loce   %r1, 2(%r3)              # encoding: [0xeb,0x18,0x30,0x02,0x00,0xf2]
#CHECK: locnlh %r1, 2(%r3)              # encoding: [0xeb,0x19,0x30,0x02,0x00,0xf2]
#CHECK: loche  %r1, 2(%r3)              # encoding: [0xeb,0x1a,0x30,0x02,0x00,0xf2]
#CHECK: locnl  %r1, 2(%r3)              # encoding: [0xeb,0x1b,0x30,0x02,0x00,0xf2]
#CHECK: locle  %r1, 2(%r3)              # encoding: [0xeb,0x1c,0x30,0x02,0x00,0xf2]
#CHECK: locnh  %r1, 2(%r3)              # encoding: [0xeb,0x1d,0x30,0x02,0x00,0xf2]
#CHECK: locno  %r1, 2(%r3)              # encoding: [0xeb,0x1e,0x30,0x02,0x00,0xf2]

	loco   %r1,2(%r3)
	loch   %r1,2(%r3)
	locnle %r1,2(%r3)
	locl   %r1,2(%r3)
	locnhe %r1,2(%r3)
	loclh  %r1,2(%r3)
	locne  %r1,2(%r3)
	loce   %r1,2(%r3)
	locnlh %r1,2(%r3)
	loche  %r1,2(%r3)
	locnl  %r1,2(%r3)
	locle  %r1,2(%r3)
	locnh  %r1,2(%r3)
	locno  %r1,2(%r3)

#CHECK: locg	%r0, 0, 0               # encoding: [0xeb,0x00,0x00,0x00,0x00,0xe2]
#CHECK: locg	%r0, 0, 15              # encoding: [0xeb,0x0f,0x00,0x00,0x00,0xe2]
#CHECK: locg	%r0, -524288, 0         # encoding: [0xeb,0x00,0x00,0x00,0x80,0xe2]
#CHECK: locg	%r0, 524287, 0          # encoding: [0xeb,0x00,0x0f,0xff,0x7f,0xe2]
#CHECK: locg	%r0, 0(%r1), 0          # encoding: [0xeb,0x00,0x10,0x00,0x00,0xe2]
#CHECK: locg	%r0, 0(%r15), 0         # encoding: [0xeb,0x00,0xf0,0x00,0x00,0xe2]
#CHECK: locg	%r15, 0, 0              # encoding: [0xeb,0xf0,0x00,0x00,0x00,0xe2]
#CHECK: locg	%r1, 4095(%r2), 3       # encoding: [0xeb,0x13,0x2f,0xff,0x00,0xe2]

	locg	%r0,0,0
	locg	%r0,0,15
	locg	%r0,-524288,0
	locg	%r0,524287,0
	locg	%r0,0(%r1),0
	locg	%r0,0(%r15),0
	locg	%r15,0,0
	locg	%r1,4095(%r2),3

#CHECK: locgo   %r1, 2(%r3)             # encoding: [0xeb,0x11,0x30,0x02,0x00,0xe2]
#CHECK: locgh   %r1, 2(%r3)             # encoding: [0xeb,0x12,0x30,0x02,0x00,0xe2]
#CHECK: locgnle %r1, 2(%r3)             # encoding: [0xeb,0x13,0x30,0x02,0x00,0xe2]
#CHECK: locgl   %r1, 2(%r3)             # encoding: [0xeb,0x14,0x30,0x02,0x00,0xe2]
#CHECK: locgnhe %r1, 2(%r3)             # encoding: [0xeb,0x15,0x30,0x02,0x00,0xe2]
#CHECK: locglh  %r1, 2(%r3)             # encoding: [0xeb,0x16,0x30,0x02,0x00,0xe2]
#CHECK: locgne  %r1, 2(%r3)             # encoding: [0xeb,0x17,0x30,0x02,0x00,0xe2]
#CHECK: locge   %r1, 2(%r3)             # encoding: [0xeb,0x18,0x30,0x02,0x00,0xe2]
#CHECK: locgnlh %r1, 2(%r3)             # encoding: [0xeb,0x19,0x30,0x02,0x00,0xe2]
#CHECK: locghe  %r1, 2(%r3)             # encoding: [0xeb,0x1a,0x30,0x02,0x00,0xe2]
#CHECK: locgnl  %r1, 2(%r3)             # encoding: [0xeb,0x1b,0x30,0x02,0x00,0xe2]
#CHECK: locgle  %r1, 2(%r3)             # encoding: [0xeb,0x1c,0x30,0x02,0x00,0xe2]
#CHECK: locgnh  %r1, 2(%r3)             # encoding: [0xeb,0x1d,0x30,0x02,0x00,0xe2]
#CHECK: locgno  %r1, 2(%r3)             # encoding: [0xeb,0x1e,0x30,0x02,0x00,0xe2]

	locgo   %r1,2(%r3)
	locgh   %r1,2(%r3)
	locgnle %r1,2(%r3)
	locgl   %r1,2(%r3)
	locgnhe %r1,2(%r3)
	locglh  %r1,2(%r3)
	locgne  %r1,2(%r3)
	locge   %r1,2(%r3)
	locgnlh %r1,2(%r3)
	locghe  %r1,2(%r3)
	locgnl  %r1,2(%r3)
	locgle  %r1,2(%r3)
	locgnh  %r1,2(%r3)
	locgno  %r1,2(%r3)

#CHECK: locgr	%r1, %r2, 0             # encoding: [0xb9,0xe2,0x00,0x12]
#CHECK: locgr	%r1, %r2, 15            # encoding: [0xb9,0xe2,0xf0,0x12]

	locgr	%r1,%r2,0
	locgr	%r1,%r2,15

#CHECK: locgro   %r1, %r3               # encoding: [0xb9,0xe2,0x10,0x13]
#CHECK: locgrh   %r1, %r3               # encoding: [0xb9,0xe2,0x20,0x13]
#CHECK: locgrnle %r1, %r3               # encoding: [0xb9,0xe2,0x30,0x13]
#CHECK: locgrl   %r1, %r3               # encoding: [0xb9,0xe2,0x40,0x13]
#CHECK: locgrnhe %r1, %r3               # encoding: [0xb9,0xe2,0x50,0x13]
#CHECK: locgrlh  %r1, %r3               # encoding: [0xb9,0xe2,0x60,0x13]
#CHECK: locgrne  %r1, %r3               # encoding: [0xb9,0xe2,0x70,0x13]
#CHECK: locgre   %r1, %r3               # encoding: [0xb9,0xe2,0x80,0x13]
#CHECK: locgrnlh %r1, %r3               # encoding: [0xb9,0xe2,0x90,0x13]
#CHECK: locgrhe  %r1, %r3               # encoding: [0xb9,0xe2,0xa0,0x13]
#CHECK: locgrnl  %r1, %r3               # encoding: [0xb9,0xe2,0xb0,0x13]
#CHECK: locgrle  %r1, %r3               # encoding: [0xb9,0xe2,0xc0,0x13]
#CHECK: locgrnh  %r1, %r3               # encoding: [0xb9,0xe2,0xd0,0x13]
#CHECK: locgrno  %r1, %r3               # encoding: [0xb9,0xe2,0xe0,0x13]

	locgro   %r1,%r3
	locgrh   %r1,%r3
	locgrnle %r1,%r3
	locgrl   %r1,%r3
	locgrnhe %r1,%r3
	locgrlh  %r1,%r3
	locgrne  %r1,%r3
	locgre   %r1,%r3
	locgrnlh %r1,%r3
	locgrhe  %r1,%r3
	locgrnl  %r1,%r3
	locgrle  %r1,%r3
	locgrnh  %r1,%r3
	locgrno  %r1,%r3

#CHECK: locr	%r1, %r2, 0             # encoding: [0xb9,0xf2,0x00,0x12]
#CHECK: locr	%r1, %r2, 15            # encoding: [0xb9,0xf2,0xf0,0x12]

	locr	%r1,%r2,0
	locr	%r1,%r2,15

#CHECK: locro   %r1, %r3                # encoding: [0xb9,0xf2,0x10,0x13]
#CHECK: locrh   %r1, %r3                # encoding: [0xb9,0xf2,0x20,0x13]
#CHECK: locrnle %r1, %r3                # encoding: [0xb9,0xf2,0x30,0x13]
#CHECK: locrl   %r1, %r3                # encoding: [0xb9,0xf2,0x40,0x13]
#CHECK: locrnhe %r1, %r3                # encoding: [0xb9,0xf2,0x50,0x13]
#CHECK: locrlh  %r1, %r3                # encoding: [0xb9,0xf2,0x60,0x13]
#CHECK: locrne  %r1, %r3                # encoding: [0xb9,0xf2,0x70,0x13]
#CHECK: locre   %r1, %r3                # encoding: [0xb9,0xf2,0x80,0x13]
#CHECK: locrnlh %r1, %r3                # encoding: [0xb9,0xf2,0x90,0x13]
#CHECK: locrhe  %r1, %r3                # encoding: [0xb9,0xf2,0xa0,0x13]
#CHECK: locrnl  %r1, %r3                # encoding: [0xb9,0xf2,0xb0,0x13]
#CHECK: locrle  %r1, %r3                # encoding: [0xb9,0xf2,0xc0,0x13]
#CHECK: locrnh  %r1, %r3                # encoding: [0xb9,0xf2,0xd0,0x13]
#CHECK: locrno  %r1, %r3                # encoding: [0xb9,0xf2,0xe0,0x13]

	locro   %r1,%r3
	locrh   %r1,%r3
	locrnle %r1,%r3
	locrl   %r1,%r3
	locrnhe %r1,%r3
	locrlh  %r1,%r3
	locrne  %r1,%r3
	locre   %r1,%r3
	locrnlh %r1,%r3
	locrhe  %r1,%r3
	locrnl  %r1,%r3
	locrle  %r1,%r3
	locrnh  %r1,%r3
	locrno  %r1,%r3

#CHECK: ngrk	%r0, %r0, %r0           # encoding: [0xb9,0xe4,0x00,0x00]
#CHECK: ngrk	%r0, %r0, %r15          # encoding: [0xb9,0xe4,0xf0,0x00]
#CHECK: ngrk	%r0, %r15, %r0          # encoding: [0xb9,0xe4,0x00,0x0f]
#CHECK: ngrk	%r15, %r0, %r0          # encoding: [0xb9,0xe4,0x00,0xf0]
#CHECK: ngrk	%r7, %r8, %r9           # encoding: [0xb9,0xe4,0x90,0x78]

	ngrk	%r0,%r0,%r0
	ngrk	%r0,%r0,%r15
	ngrk	%r0,%r15,%r0
	ngrk	%r15,%r0,%r0
	ngrk	%r7,%r8,%r9

#CHECK: nrk	%r0, %r0, %r0           # encoding: [0xb9,0xf4,0x00,0x00]
#CHECK: nrk	%r0, %r0, %r15          # encoding: [0xb9,0xf4,0xf0,0x00]
#CHECK: nrk	%r0, %r15, %r0          # encoding: [0xb9,0xf4,0x00,0x0f]
#CHECK: nrk	%r15, %r0, %r0          # encoding: [0xb9,0xf4,0x00,0xf0]
#CHECK: nrk	%r7, %r8, %r9           # encoding: [0xb9,0xf4,0x90,0x78]

	nrk	%r0,%r0,%r0
	nrk	%r0,%r0,%r15
	nrk	%r0,%r15,%r0
	nrk	%r15,%r0,%r0
	nrk	%r7,%r8,%r9

#CHECK: ogrk	%r0, %r0, %r0           # encoding: [0xb9,0xe6,0x00,0x00]
#CHECK: ogrk	%r0, %r0, %r15          # encoding: [0xb9,0xe6,0xf0,0x00]
#CHECK: ogrk	%r0, %r15, %r0          # encoding: [0xb9,0xe6,0x00,0x0f]
#CHECK: ogrk	%r15, %r0, %r0          # encoding: [0xb9,0xe6,0x00,0xf0]
#CHECK: ogrk	%r7, %r8, %r9           # encoding: [0xb9,0xe6,0x90,0x78]

	ogrk	%r0,%r0,%r0
	ogrk	%r0,%r0,%r15
	ogrk	%r0,%r15,%r0
	ogrk	%r15,%r0,%r0
	ogrk	%r7,%r8,%r9

#CHECK: ork	%r0, %r0, %r0           # encoding: [0xb9,0xf6,0x00,0x00]
#CHECK: ork	%r0, %r0, %r15          # encoding: [0xb9,0xf6,0xf0,0x00]
#CHECK: ork	%r0, %r15, %r0          # encoding: [0xb9,0xf6,0x00,0x0f]
#CHECK: ork	%r15, %r0, %r0          # encoding: [0xb9,0xf6,0x00,0xf0]
#CHECK: ork	%r7, %r8, %r9           # encoding: [0xb9,0xf6,0x90,0x78]

	ork	%r0,%r0,%r0
	ork	%r0,%r0,%r15
	ork	%r0,%r15,%r0
	ork	%r15,%r0,%r0
	ork	%r7,%r8,%r9

#CHECK: risbhg	%r0, %r0, 0, 0, 0       # encoding: [0xec,0x00,0x00,0x00,0x00,0x5d]
#CHECK: risbhg	%r0, %r0, 0, 0, 63      # encoding: [0xec,0x00,0x00,0x00,0x3f,0x5d]
#CHECK: risbhg	%r0, %r0, 0, 255, 0     # encoding: [0xec,0x00,0x00,0xff,0x00,0x5d]
#CHECK: risbhg	%r0, %r0, 255, 0, 0     # encoding: [0xec,0x00,0xff,0x00,0x00,0x5d]
#CHECK: risbhg	%r0, %r15, 0, 0, 0      # encoding: [0xec,0x0f,0x00,0x00,0x00,0x5d]
#CHECK: risbhg	%r15, %r0, 0, 0, 0      # encoding: [0xec,0xf0,0x00,0x00,0x00,0x5d]
#CHECK: risbhg	%r4, %r5, 6, 7, 8       # encoding: [0xec,0x45,0x06,0x07,0x08,0x5d]

	risbhg	%r0,%r0,0,0,0
	risbhg	%r0,%r0,0,0,63
	risbhg	%r0,%r0,0,255,0
	risbhg	%r0,%r0,255,0,0
	risbhg	%r0,%r15,0,0,0
	risbhg	%r15,%r0,0,0,0
	risbhg	%r4,%r5,6,7,8

#CHECK: risblg	%r0, %r0, 0, 0, 0       # encoding: [0xec,0x00,0x00,0x00,0x00,0x51]
#CHECK: risblg	%r0, %r0, 0, 0, 63      # encoding: [0xec,0x00,0x00,0x00,0x3f,0x51]
#CHECK: risblg	%r0, %r0, 0, 255, 0     # encoding: [0xec,0x00,0x00,0xff,0x00,0x51]
#CHECK: risblg	%r0, %r0, 255, 0, 0     # encoding: [0xec,0x00,0xff,0x00,0x00,0x51]
#CHECK: risblg	%r0, %r15, 0, 0, 0      # encoding: [0xec,0x0f,0x00,0x00,0x00,0x51]
#CHECK: risblg	%r15, %r0, 0, 0, 0      # encoding: [0xec,0xf0,0x00,0x00,0x00,0x51]
#CHECK: risblg	%r4, %r5, 6, 7, 8       # encoding: [0xec,0x45,0x06,0x07,0x08,0x51]

	risblg	%r0,%r0,0,0,0
	risblg	%r0,%r0,0,0,63
	risblg	%r0,%r0,0,255,0
	risblg	%r0,%r0,255,0,0
	risblg	%r0,%r15,0,0,0
	risblg	%r15,%r0,0,0,0
	risblg	%r4,%r5,6,7,8

#CHECK: sgrk	%r0, %r0, %r0           # encoding: [0xb9,0xe9,0x00,0x00]
#CHECK: sgrk	%r0, %r0, %r15          # encoding: [0xb9,0xe9,0xf0,0x00]
#CHECK: sgrk	%r0, %r15, %r0          # encoding: [0xb9,0xe9,0x00,0x0f]
#CHECK: sgrk	%r15, %r0, %r0          # encoding: [0xb9,0xe9,0x00,0xf0]
#CHECK: sgrk	%r7, %r8, %r9           # encoding: [0xb9,0xe9,0x90,0x78]

	sgrk	%r0,%r0,%r0
	sgrk	%r0,%r0,%r15
	sgrk	%r0,%r15,%r0
	sgrk	%r15,%r0,%r0
	sgrk	%r7,%r8,%r9

#CHECK: slgrk	%r0, %r0, %r0           # encoding: [0xb9,0xeb,0x00,0x00]
#CHECK: slgrk	%r0, %r0, %r15          # encoding: [0xb9,0xeb,0xf0,0x00]
#CHECK: slgrk	%r0, %r15, %r0          # encoding: [0xb9,0xeb,0x00,0x0f]
#CHECK: slgrk	%r15, %r0, %r0          # encoding: [0xb9,0xeb,0x00,0xf0]
#CHECK: slgrk	%r7, %r8, %r9           # encoding: [0xb9,0xeb,0x90,0x78]

	slgrk	%r0,%r0,%r0
	slgrk	%r0,%r0,%r15
	slgrk	%r0,%r15,%r0
	slgrk	%r15,%r0,%r0
	slgrk	%r7,%r8,%r9

#CHECK: slrk	%r0, %r0, %r0           # encoding: [0xb9,0xfb,0x00,0x00]
#CHECK: slrk	%r0, %r0, %r15          # encoding: [0xb9,0xfb,0xf0,0x00]
#CHECK: slrk	%r0, %r15, %r0          # encoding: [0xb9,0xfb,0x00,0x0f]
#CHECK: slrk	%r15, %r0, %r0          # encoding: [0xb9,0xfb,0x00,0xf0]
#CHECK: slrk	%r7, %r8, %r9           # encoding: [0xb9,0xfb,0x90,0x78]

	slrk	%r0,%r0,%r0
	slrk	%r0,%r0,%r15
	slrk	%r0,%r15,%r0
	slrk	%r15,%r0,%r0
	slrk	%r7,%r8,%r9

#CHECK: sllk	%r0, %r0, 0             # encoding: [0xeb,0x00,0x00,0x00,0x00,0xdf]
#CHECK: sllk	%r15, %r1, 0            # encoding: [0xeb,0xf1,0x00,0x00,0x00,0xdf]
#CHECK: sllk	%r1, %r15, 0            # encoding: [0xeb,0x1f,0x00,0x00,0x00,0xdf]
#CHECK: sllk	%r15, %r15, 0           # encoding: [0xeb,0xff,0x00,0x00,0x00,0xdf]
#CHECK: sllk	%r0, %r0, -524288       # encoding: [0xeb,0x00,0x00,0x00,0x80,0xdf]
#CHECK: sllk	%r0, %r0, -1            # encoding: [0xeb,0x00,0x0f,0xff,0xff,0xdf]
#CHECK: sllk	%r0, %r0, 1             # encoding: [0xeb,0x00,0x00,0x01,0x00,0xdf]
#CHECK: sllk	%r0, %r0, 524287        # encoding: [0xeb,0x00,0x0f,0xff,0x7f,0xdf]
#CHECK: sllk	%r0, %r0, 0(%r1)        # encoding: [0xeb,0x00,0x10,0x00,0x00,0xdf]
#CHECK: sllk	%r0, %r0, 0(%r15)       # encoding: [0xeb,0x00,0xf0,0x00,0x00,0xdf]
#CHECK: sllk	%r0, %r0, 524287(%r1)   # encoding: [0xeb,0x00,0x1f,0xff,0x7f,0xdf]
#CHECK: sllk	%r0, %r0, 524287(%r15)  # encoding: [0xeb,0x00,0xff,0xff,0x7f,0xdf]

	sllk	%r0,%r0,0
	sllk	%r15,%r1,0
	sllk	%r1,%r15,0
	sllk	%r15,%r15,0
	sllk	%r0,%r0,-524288
	sllk	%r0,%r0,-1
	sllk	%r0,%r0,1
	sllk	%r0,%r0,524287
	sllk	%r0,%r0,0(%r1)
	sllk	%r0,%r0,0(%r15)
	sllk	%r0,%r0,524287(%r1)
	sllk	%r0,%r0,524287(%r15)

#CHECK: srak	%r0, %r0, 0             # encoding: [0xeb,0x00,0x00,0x00,0x00,0xdc]
#CHECK: srak	%r15, %r1, 0            # encoding: [0xeb,0xf1,0x00,0x00,0x00,0xdc]
#CHECK: srak	%r1, %r15, 0            # encoding: [0xeb,0x1f,0x00,0x00,0x00,0xdc]
#CHECK: srak	%r15, %r15, 0           # encoding: [0xeb,0xff,0x00,0x00,0x00,0xdc]
#CHECK: srak	%r0, %r0, -524288       # encoding: [0xeb,0x00,0x00,0x00,0x80,0xdc]
#CHECK: srak	%r0, %r0, -1            # encoding: [0xeb,0x00,0x0f,0xff,0xff,0xdc]
#CHECK: srak	%r0, %r0, 1             # encoding: [0xeb,0x00,0x00,0x01,0x00,0xdc]
#CHECK: srak	%r0, %r0, 524287        # encoding: [0xeb,0x00,0x0f,0xff,0x7f,0xdc]
#CHECK: srak	%r0, %r0, 0(%r1)        # encoding: [0xeb,0x00,0x10,0x00,0x00,0xdc]
#CHECK: srak	%r0, %r0, 0(%r15)       # encoding: [0xeb,0x00,0xf0,0x00,0x00,0xdc]
#CHECK: srak	%r0, %r0, 524287(%r1)   # encoding: [0xeb,0x00,0x1f,0xff,0x7f,0xdc]
#CHECK: srak	%r0, %r0, 524287(%r15)  # encoding: [0xeb,0x00,0xff,0xff,0x7f,0xdc]

	srak	%r0,%r0,0
	srak	%r15,%r1,0
	srak	%r1,%r15,0
	srak	%r15,%r15,0
	srak	%r0,%r0,-524288
	srak	%r0,%r0,-1
	srak	%r0,%r0,1
	srak	%r0,%r0,524287
	srak	%r0,%r0,0(%r1)
	srak	%r0,%r0,0(%r15)
	srak	%r0,%r0,524287(%r1)
	srak	%r0,%r0,524287(%r15)

#CHECK: srk	%r0, %r0, %r0           # encoding: [0xb9,0xf9,0x00,0x00]
#CHECK: srk	%r0, %r0, %r15          # encoding: [0xb9,0xf9,0xf0,0x00]
#CHECK: srk	%r0, %r15, %r0          # encoding: [0xb9,0xf9,0x00,0x0f]
#CHECK: srk	%r15, %r0, %r0          # encoding: [0xb9,0xf9,0x00,0xf0]
#CHECK: srk	%r7, %r8, %r9           # encoding: [0xb9,0xf9,0x90,0x78]

	srk	%r0,%r0,%r0
	srk	%r0,%r0,%r15
	srk	%r0,%r15,%r0
	srk	%r15,%r0,%r0
	srk	%r7,%r8,%r9

#CHECK: srlk	%r0, %r0, 0             # encoding: [0xeb,0x00,0x00,0x00,0x00,0xde]
#CHECK: srlk	%r15, %r1, 0            # encoding: [0xeb,0xf1,0x00,0x00,0x00,0xde]
#CHECK: srlk	%r1, %r15, 0            # encoding: [0xeb,0x1f,0x00,0x00,0x00,0xde]
#CHECK: srlk	%r15, %r15, 0           # encoding: [0xeb,0xff,0x00,0x00,0x00,0xde]
#CHECK: srlk	%r0, %r0, -524288       # encoding: [0xeb,0x00,0x00,0x00,0x80,0xde]
#CHECK: srlk	%r0, %r0, -1            # encoding: [0xeb,0x00,0x0f,0xff,0xff,0xde]
#CHECK: srlk	%r0, %r0, 1             # encoding: [0xeb,0x00,0x00,0x01,0x00,0xde]
#CHECK: srlk	%r0, %r0, 524287        # encoding: [0xeb,0x00,0x0f,0xff,0x7f,0xde]
#CHECK: srlk	%r0, %r0, 0(%r1)        # encoding: [0xeb,0x00,0x10,0x00,0x00,0xde]
#CHECK: srlk	%r0, %r0, 0(%r15)       # encoding: [0xeb,0x00,0xf0,0x00,0x00,0xde]
#CHECK: srlk	%r0, %r0, 524287(%r1)   # encoding: [0xeb,0x00,0x1f,0xff,0x7f,0xde]
#CHECK: srlk	%r0, %r0, 524287(%r15)  # encoding: [0xeb,0x00,0xff,0xff,0x7f,0xde]

	srlk	%r0,%r0,0
	srlk	%r15,%r1,0
	srlk	%r1,%r15,0
	srlk	%r15,%r15,0
	srlk	%r0,%r0,-524288
	srlk	%r0,%r0,-1
	srlk	%r0,%r0,1
	srlk	%r0,%r0,524287
	srlk	%r0,%r0,0(%r1)
	srlk	%r0,%r0,0(%r15)
	srlk	%r0,%r0,524287(%r1)
	srlk	%r0,%r0,524287(%r15)

#CHECK: stfh	%r0, -524288            # encoding: [0xe3,0x00,0x00,0x00,0x80,0xcb]
#CHECK: stfh	%r0, -1                 # encoding: [0xe3,0x00,0x0f,0xff,0xff,0xcb]
#CHECK: stfh	%r0, 0                  # encoding: [0xe3,0x00,0x00,0x00,0x00,0xcb]
#CHECK: stfh	%r0, 1                  # encoding: [0xe3,0x00,0x00,0x01,0x00,0xcb]
#CHECK: stfh	%r0, 524287             # encoding: [0xe3,0x00,0x0f,0xff,0x7f,0xcb]
#CHECK: stfh	%r0, 0(%r1)             # encoding: [0xe3,0x00,0x10,0x00,0x00,0xcb]
#CHECK: stfh	%r0, 0(%r15)            # encoding: [0xe3,0x00,0xf0,0x00,0x00,0xcb]
#CHECK: stfh	%r0, 524287(%r1,%r15)   # encoding: [0xe3,0x01,0xff,0xff,0x7f,0xcb]
#CHECK: stfh	%r0, 524287(%r15,%r1)   # encoding: [0xe3,0x0f,0x1f,0xff,0x7f,0xcb]
#CHECK: stfh	%r15, 0                 # encoding: [0xe3,0xf0,0x00,0x00,0x00,0xcb]

	stfh	%r0, -524288
	stfh	%r0, -1
	stfh	%r0, 0
	stfh	%r0, 1
	stfh	%r0, 524287
	stfh	%r0, 0(%r1)
	stfh	%r0, 0(%r15)
	stfh	%r0, 524287(%r1,%r15)
	stfh	%r0, 524287(%r15,%r1)
	stfh	%r15, 0

#CHECK: stoc	%r0, 0, 0               # encoding: [0xeb,0x00,0x00,0x00,0x00,0xf3]
#CHECK: stoc	%r0, 0, 15              # encoding: [0xeb,0x0f,0x00,0x00,0x00,0xf3]
#CHECK: stoc	%r0, -524288, 0         # encoding: [0xeb,0x00,0x00,0x00,0x80,0xf3]
#CHECK: stoc	%r0, 524287, 0          # encoding: [0xeb,0x00,0x0f,0xff,0x7f,0xf3]
#CHECK: stoc	%r0, 0(%r1), 0          # encoding: [0xeb,0x00,0x10,0x00,0x00,0xf3]
#CHECK: stoc	%r0, 0(%r15), 0         # encoding: [0xeb,0x00,0xf0,0x00,0x00,0xf3]
#CHECK: stoc	%r15, 0, 0              # encoding: [0xeb,0xf0,0x00,0x00,0x00,0xf3]
#CHECK: stoc	%r1, 4095(%r2), 3       # encoding: [0xeb,0x13,0x2f,0xff,0x00,0xf3]

	stoc	%r0,0,0
	stoc	%r0,0,15
	stoc	%r0,-524288,0
	stoc	%r0,524287,0
	stoc	%r0,0(%r1),0
	stoc	%r0,0(%r15),0
	stoc	%r15,0,0
	stoc	%r1,4095(%r2),3

#CHECK: stoco   %r1, 2(%r3)             # encoding: [0xeb,0x11,0x30,0x02,0x00,0xf3]
#CHECK: stoch   %r1, 2(%r3)             # encoding: [0xeb,0x12,0x30,0x02,0x00,0xf3]
#CHECK: stocnle %r1, 2(%r3)             # encoding: [0xeb,0x13,0x30,0x02,0x00,0xf3]
#CHECK: stocl   %r1, 2(%r3)             # encoding: [0xeb,0x14,0x30,0x02,0x00,0xf3]
#CHECK: stocnhe %r1, 2(%r3)             # encoding: [0xeb,0x15,0x30,0x02,0x00,0xf3]
#CHECK: stoclh  %r1, 2(%r3)             # encoding: [0xeb,0x16,0x30,0x02,0x00,0xf3]
#CHECK: stocne  %r1, 2(%r3)             # encoding: [0xeb,0x17,0x30,0x02,0x00,0xf3]
#CHECK: stoce   %r1, 2(%r3)             # encoding: [0xeb,0x18,0x30,0x02,0x00,0xf3]
#CHECK: stocnlh %r1, 2(%r3)             # encoding: [0xeb,0x19,0x30,0x02,0x00,0xf3]
#CHECK: stoche  %r1, 2(%r3)             # encoding: [0xeb,0x1a,0x30,0x02,0x00,0xf3]
#CHECK: stocnl  %r1, 2(%r3)             # encoding: [0xeb,0x1b,0x30,0x02,0x00,0xf3]
#CHECK: stocle  %r1, 2(%r3)             # encoding: [0xeb,0x1c,0x30,0x02,0x00,0xf3]
#CHECK: stocnh  %r1, 2(%r3)             # encoding: [0xeb,0x1d,0x30,0x02,0x00,0xf3]
#CHECK: stocno  %r1, 2(%r3)             # encoding: [0xeb,0x1e,0x30,0x02,0x00,0xf3]

	stoco   %r1,2(%r3)
	stoch   %r1,2(%r3)
	stocnle %r1,2(%r3)
	stocl   %r1,2(%r3)
	stocnhe %r1,2(%r3)
	stoclh  %r1,2(%r3)
	stocne  %r1,2(%r3)
	stoce   %r1,2(%r3)
	stocnlh %r1,2(%r3)
	stoche  %r1,2(%r3)
	stocnl  %r1,2(%r3)
	stocle  %r1,2(%r3)
	stocnh  %r1,2(%r3)
	stocno  %r1,2(%r3)

#CHECK: stocg	%r0, 0, 0               # encoding: [0xeb,0x00,0x00,0x00,0x00,0xe3]
#CHECK: stocg	%r0, 0, 15              # encoding: [0xeb,0x0f,0x00,0x00,0x00,0xe3]
#CHECK: stocg	%r0, -524288, 0         # encoding: [0xeb,0x00,0x00,0x00,0x80,0xe3]
#CHECK: stocg	%r0, 524287, 0          # encoding: [0xeb,0x00,0x0f,0xff,0x7f,0xe3]
#CHECK: stocg	%r0, 0(%r1), 0          # encoding: [0xeb,0x00,0x10,0x00,0x00,0xe3]
#CHECK: stocg	%r0, 0(%r15), 0         # encoding: [0xeb,0x00,0xf0,0x00,0x00,0xe3]
#CHECK: stocg	%r15, 0, 0              # encoding: [0xeb,0xf0,0x00,0x00,0x00,0xe3]
#CHECK: stocg	%r1, 4095(%r2), 3       # encoding: [0xeb,0x13,0x2f,0xff,0x00,0xe3]

	stocg	%r0,0,0
	stocg	%r0,0,15
	stocg	%r0,-524288,0
	stocg	%r0,524287,0
	stocg	%r0,0(%r1),0
	stocg	%r0,0(%r15),0
	stocg	%r15,0,0
	stocg	%r1,4095(%r2),3

#CHECK: stocgo   %r1, 2(%r3)            # encoding: [0xeb,0x11,0x30,0x02,0x00,0xe3]
#CHECK: stocgh   %r1, 2(%r3)            # encoding: [0xeb,0x12,0x30,0x02,0x00,0xe3]
#CHECK: stocgnle %r1, 2(%r3)            # encoding: [0xeb,0x13,0x30,0x02,0x00,0xe3]
#CHECK: stocgl   %r1, 2(%r3)            # encoding: [0xeb,0x14,0x30,0x02,0x00,0xe3]
#CHECK: stocgnhe %r1, 2(%r3)            # encoding: [0xeb,0x15,0x30,0x02,0x00,0xe3]
#CHECK: stocglh  %r1, 2(%r3)            # encoding: [0xeb,0x16,0x30,0x02,0x00,0xe3]
#CHECK: stocgne  %r1, 2(%r3)            # encoding: [0xeb,0x17,0x30,0x02,0x00,0xe3]
#CHECK: stocge   %r1, 2(%r3)            # encoding: [0xeb,0x18,0x30,0x02,0x00,0xe3]
#CHECK: stocgnlh %r1, 2(%r3)            # encoding: [0xeb,0x19,0x30,0x02,0x00,0xe3]
#CHECK: stocghe  %r1, 2(%r3)            # encoding: [0xeb,0x1a,0x30,0x02,0x00,0xe3]
#CHECK: stocgnl  %r1, 2(%r3)            # encoding: [0xeb,0x1b,0x30,0x02,0x00,0xe3]
#CHECK: stocgle  %r1, 2(%r3)            # encoding: [0xeb,0x1c,0x30,0x02,0x00,0xe3]
#CHECK: stocgnh  %r1, 2(%r3)            # encoding: [0xeb,0x1d,0x30,0x02,0x00,0xe3]
#CHECK: stocgno  %r1, 2(%r3)            # encoding: [0xeb,0x1e,0x30,0x02,0x00,0xe3]

	stocgo   %r1,2(%r3)
	stocgh   %r1,2(%r3)
	stocgnle %r1,2(%r3)
	stocgl   %r1,2(%r3)
	stocgnhe %r1,2(%r3)
	stocglh  %r1,2(%r3)
	stocgne  %r1,2(%r3)
	stocge   %r1,2(%r3)
	stocgnlh %r1,2(%r3)
	stocghe  %r1,2(%r3)
	stocgnl  %r1,2(%r3)
	stocgle  %r1,2(%r3)
	stocgnh  %r1,2(%r3)
	stocgno  %r1,2(%r3)

#CHECK: xgrk	%r0, %r0, %r0           # encoding: [0xb9,0xe7,0x00,0x00]
#CHECK: xgrk	%r0, %r0, %r15          # encoding: [0xb9,0xe7,0xf0,0x00]
#CHECK: xgrk	%r0, %r15, %r0          # encoding: [0xb9,0xe7,0x00,0x0f]
#CHECK: xgrk	%r15, %r0, %r0          # encoding: [0xb9,0xe7,0x00,0xf0]
#CHECK: xgrk	%r7, %r8, %r9           # encoding: [0xb9,0xe7,0x90,0x78]

	xgrk	%r0,%r0,%r0
	xgrk	%r0,%r0,%r15
	xgrk	%r0,%r15,%r0
	xgrk	%r15,%r0,%r0
	xgrk	%r7,%r8,%r9

#CHECK: xrk	%r0, %r0, %r0           # encoding: [0xb9,0xf7,0x00,0x00]
#CHECK: xrk	%r0, %r0, %r15          # encoding: [0xb9,0xf7,0xf0,0x00]
#CHECK: xrk	%r0, %r15, %r0          # encoding: [0xb9,0xf7,0x00,0x0f]
#CHECK: xrk	%r15, %r0, %r0          # encoding: [0xb9,0xf7,0x00,0xf0]
#CHECK: xrk	%r7, %r8, %r9           # encoding: [0xb9,0xf7,0x90,0x78]

	xrk	%r0,%r0,%r0
	xrk	%r0,%r0,%r15
	xrk	%r0,%r15,%r0
	xrk	%r15,%r0,%r0
	xrk	%r7,%r8,%r9
