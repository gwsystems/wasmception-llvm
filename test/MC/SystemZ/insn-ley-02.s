# RUN: not llvm-mc -triple s390x-linux-gnu < %s 2> %t
# RUN: FileCheck < %t %s

#CHECK: error: invalid operand
#CHECK: ley	%f0, -524289
#CHECK: error: invalid operand
#CHECK: ley	%f0, 524288

	ley	%f0, -524289
	ley	%f0, 524288
