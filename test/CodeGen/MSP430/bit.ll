; RUN: llc < %s -march=msp430 | FileCheck %s
target datalayout = "e-p:16:16:16-i1:8:8-i8:8:8-i16:16:16-i32:16:32"
target triple = "msp430-generic-generic"

@foo8 = external global i8
@bar8 = external global i8

define i8 @bitbrr(i8 %a, i8 %b) nounwind {
	%t1 = and i8 %a, %b
	%t2 = icmp ne i8 %t1, 0
	%t3 = zext i1 %t2 to i8
	ret i8 %t3
}
; CHECK: bitbrr:
; CHECK: bit.b	r14, r15

define i8 @bitbri(i8 %a) nounwind {
	%t1 = and i8 %a, 15
	%t2 = icmp ne i8 %t1, 0
	%t3 = zext i1 %t2 to i8
	ret i8 %t3
}
; CHECK: bitbri:
; CHECK: bit.b	#15, r15

define i8 @bitbir(i8 %a) nounwind {
	%t1 = and i8 15, %a
	%t2 = icmp ne i8 %t1, 0
	%t3 = zext i1 %t2 to i8
	ret i8 %t3
}
; CHECK: bitbir:
; CHECK: bit.b	#15, r15

define i8 @bitbmi() nounwind {
	%t1 = load i8* @foo8
	%t2 = and i8 %t1, 15
	%t3 = icmp ne i8 %t2, 0
	%t4 = zext i1 %t3 to i8
	ret i8 %t4
}
; CHECK: bitbmi:
; CHECK: bit.b	#15, &foo8

define i8 @bitbim() nounwind {
	%t1 = load i8* @foo8
	%t2 = and i8 15, %t1
	%t3 = icmp ne i8 %t2, 0
	%t4 = zext i1 %t3 to i8
	ret i8 %t4
}
; CHECK: bitbim:
; CHECK: bit.b	#15, &foo8

define i8 @bitbrm(i8 %a) nounwind {
	%t1 = load i8* @foo8
	%t2 = and i8 %a, %t1
	%t3 = icmp ne i8 %t2, 0
	%t4 = zext i1 %t3 to i8
	ret i8 %t4
}
; CHECK: bitbrm:
; CHECK: bit.b	&foo8, r15

define i8 @bitbmr(i8 %a) nounwind {
	%t1 = load i8* @foo8
	%t2 = and i8 %t1, %a
	%t3 = icmp ne i8 %t2, 0
	%t4 = zext i1 %t3 to i8
	ret i8 %t4
}
; CHECK: bitbmr:
; CHECK: bit.b	r15, &foo8

define i8 @bitbmm() nounwind {
	%t1 = load i8* @foo8
	%t2 = load i8* @bar8
	%t3 = and i8 %t1, %t2
	%t4 = icmp ne i8 %t3, 0
	%t5 = zext i1 %t4 to i8
	ret i8 %t5
}
; CHECK: bitbmm:
; CHECK: bit.b	&bar8, &foo8

@foo16 = external global i16
@bar16 = external global i16

define i16 @bitwrr(i16 %a, i16 %b) nounwind {
	%t1 = and i16 %a, %b
	%t2 = icmp ne i16 %t1, 0
	%t3 = zext i1 %t2 to i16
	ret i16 %t3
}
; CHECK: bitwrr:
; CHECK: bit.w	r14, r15

define i16 @bitwri(i16 %a) nounwind {
	%t1 = and i16 %a, 4080
	%t2 = icmp ne i16 %t1, 0
	%t3 = zext i1 %t2 to i16
	ret i16 %t3
}
; CHECK: bitwri:
; CHECK: bit.w	#4080, r15

define i16 @bitwir(i16 %a) nounwind {
	%t1 = and i16 4080, %a
	%t2 = icmp ne i16 %t1, 0
	%t3 = zext i1 %t2 to i16
	ret i16 %t3
}
; CHECK: bitwir:
; CHECK: bit.w	#4080, r15

define i16 @bitwmi() nounwind {
	%t1 = load i16* @foo16
	%t2 = and i16 %t1, 4080
	%t3 = icmp ne i16 %t2, 0
	%t4 = zext i1 %t3 to i16
	ret i16 %t4
}
; CHECK: bitwmi:
; CHECK: bit.w	#4080, &foo16

define i16 @bitwim() nounwind {
	%t1 = load i16* @foo16
	%t2 = and i16 4080, %t1
	%t3 = icmp ne i16 %t2, 0
	%t4 = zext i1 %t3 to i16
	ret i16 %t4
}
; CHECK: bitwim:
; CHECK: bit.w	#4080, &foo16

define i16 @bitwrm(i16 %a) nounwind {
	%t1 = load i16* @foo16
	%t2 = and i16 %a, %t1
	%t3 = icmp ne i16 %t2, 0
	%t4 = zext i1 %t3 to i16
	ret i16 %t4
}
; CHECK: bitwrm:
; CHECK: bit.w	&foo16, r15

define i16 @bitwmr(i16 %a) nounwind {
	%t1 = load i16* @foo16
	%t2 = and i16 %t1, %a
	%t3 = icmp ne i16 %t2, 0
	%t4 = zext i1 %t3 to i16
	ret i16 %t4
}
; CHECK: bitwmr:
; CHECK: bit.w	r15, &foo16

define i16 @bitwmm() nounwind {
	%t1 = load i16* @foo16
	%t2 = load i16* @bar16
	%t3 = and i16 %t1, %t2
	%t4 = icmp ne i16 %t3, 0
	%t5 = zext i1 %t4 to i16
	ret i16 %t5
}
; CHECK: bitwmm:
; CHECK: bit.w	&bar16, &foo16

