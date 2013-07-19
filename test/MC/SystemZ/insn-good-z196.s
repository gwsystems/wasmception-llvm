# For z196 and above.
# RUN: llvm-mc -triple s390x-linux-gnu -mcpu=z196 -show-encoding %s | FileCheck %s

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
