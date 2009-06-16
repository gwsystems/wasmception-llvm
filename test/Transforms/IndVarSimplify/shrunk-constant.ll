; RUN: llvm-as < %s | opt -iv-users -analyze | grep store

define fastcc void @foo() nounwind {
entry:
	br label %loop

loop:
	%i = phi i32 [ 0, %entry ], [ %t2, %loop ]
	%t0 = add i32 %i, 9
	%t1 = and i32 %t0, 9
        store i32 %t1, i32* null
	%t2 = add i32 %i, 8
	br label %loop
}
