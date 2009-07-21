; RUN: llvm-as < %s | llc -march=arm | FileCheck %s

define i32 @t1(i32 %v) nounwind readnone {
entry:
; CHECK: t1:
; CHECK: add r0, r0, r0, lsl #3
	%0 = mul i32 %v, 9
	ret i32 %0
}

define i32 @t2(i32 %v) nounwind readnone {
entry:
; CHECK: t2:
; CHECK: rsb r0, r0, r0, lsl #3
	%0 = mul i32 %v, 7
	ret i32 %0
}
