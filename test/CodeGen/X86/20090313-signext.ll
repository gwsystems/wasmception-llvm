; RUN: llvm-as < %s | llc -march=x86-64 > %t
; RUN: grep {movswl	%ax, %edi} %t
; RUN: grep {movw	x(%rip), %ax} %t

@x = common global i16 0

define signext i16 @f() nounwind {
entry:
	%0 = tail call signext i16 @h() nounwind
	%1 = sext i16 %0 to i32
	tail call void @g(i32 %1) nounwind
	%2 = load i16* @x, align 2
	ret i16 %2
}

declare signext i16 @h()

declare void @g(i32)
