; RUN: llc < %s -enable-tail-merge | FileCheck %s
; Check that calls to baz and quux are tail-merged.
; PR1628

; CHECK: bl _baz
; CHECK-NOT: bl _baz
; CHECK: bl _quux
; CHECK-NOT: bl _quux

; ModuleID = 'tail.c'
target triple = "arm-apple-darwin8"

define i32 @f(i32 %i, i32 %q) {
entry:
	%i_addr = alloca i32		; <i32*> [#uses=2]
	%q_addr = alloca i32		; <i32*> [#uses=2]
	%retval = alloca i32, align 4		; <i32*> [#uses=1]
	store i32 %i, i32* %i_addr
	store i32 %q, i32* %q_addr
	%tmp = load i32, i32* %i_addr		; <i32> [#uses=1]
	%tmp1 = icmp ne i32 %tmp, 0		; <i1> [#uses=1]
	%tmp12 = zext i1 %tmp1 to i8		; <i8> [#uses=1]
	%toBool = icmp ne i8 %tmp12, 0		; <i1> [#uses=1]
	br i1 %toBool, label %cond_true, label %cond_false

cond_true:		; preds = %entry
	%tmp3 = call i32 (...) @bar( )		; <i32> [#uses=0]
	%tmp4 = call i32 (...) @baz( i32 5, i32 6 )		; <i32> [#uses=0]
	br label %cond_next

cond_false:		; preds = %entry
	%tmp5 = call i32 (...) @foo( )		; <i32> [#uses=0]
	%tmp6 = call i32 (...) @baz( i32 5, i32 6 )		; <i32> [#uses=0]
	br label %cond_next

cond_next:		; preds = %cond_false, %cond_true
	%tmp7 = load i32, i32* %q_addr		; <i32> [#uses=1]
	%tmp8 = icmp ne i32 %tmp7, 0		; <i1> [#uses=1]
	%tmp89 = zext i1 %tmp8 to i8		; <i8> [#uses=1]
	%toBool10 = icmp ne i8 %tmp89, 0		; <i1> [#uses=1]
	br i1 %toBool10, label %cond_true11, label %cond_false15

cond_true11:		; preds = %cond_next
	%tmp13 = call i32 (...) @foo( )		; <i32> [#uses=0]
	%tmp14 = call i32 (...) @quux( i32 3, i32 4 )		; <i32> [#uses=0]
	br label %cond_next18

cond_false15:		; preds = %cond_next
	%tmp16 = call i32 (...) @bar( )		; <i32> [#uses=0]
	%tmp17 = call i32 (...) @quux( i32 3, i32 4 )		; <i32> [#uses=0]
	br label %cond_next18

cond_next18:		; preds = %cond_false15, %cond_true11
	%tmp19 = call i32 (...) @bar( )		; <i32> [#uses=0]
	br label %return

return:		; preds = %cond_next18
	%retval20 = load i32, i32* %retval		; <i32> [#uses=1]
	ret i32 %retval20
}

declare i32 @bar(...)

declare i32 @baz(...)

declare i32 @foo(...)

declare i32 @quux(...)
