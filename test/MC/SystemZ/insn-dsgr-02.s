# RUN: not llvm-mc -triple s390x-linux-gnu < %s 2> %t
# RUN: FileCheck < %t %s

#CHECK: error: invalid register
#CHECK: dsgr	%r1, %r0
#CHECK: error: invalid register
#CHECK: dsgr	%r15, %r0

	dsgr	%r1, %r0
	dsgr	%r15, %r0
