; This test checks to make sure that 'br X, Dest, Dest' is folded into 
; 'br Dest'

; RUN: opt %s -simplifycfg | llvm-dis | \
; RUN:   not grep {br i1 %c2}

declare void @noop()

define i32 @test(i1 %c1, i1 %c2) {
	call void @noop( )
	br i1 %c1, label %A, label %Y
A:		; preds = %0
	call void @noop( )
	br i1 %c2, label %X, label %X
X:		; preds = %Y, %A, %A
	call void @noop( )
	ret i32 0
Y:		; preds = %0
	call void @noop( )
	br label %X
}

