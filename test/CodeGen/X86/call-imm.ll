; RUN: llvm-as < %s | llc -mtriple=i386-darwin-apple -relocation-model=static | grep {call.*12345678}
; RUN: llvm-as < %s | llc -mtriple=i386-pc-linux -relocation-model=dynamic-no-pic | grep {call.*12345678}
; RUN: llvm-as < %s | llc -march=x86 -relocation-model=pic | not grep {call.*12345678}

; Call to immediate is not safe on x86-64 unless we *know* that the
; call will be within 32-bits pcrel from the dest immediate.

; RUN: llvm-as < %s | llc -march=x86-64 | grep {call.*\*%rax}

; PR3666
; PR3773
; rdar://6904453

define i32 @main() nounwind {
entry:
	%0 = call i32 inttoptr (i32 12345678 to i32 (i32)*)(i32 0) nounwind		; <i32> [#uses=1]
	ret i32 %0
}
