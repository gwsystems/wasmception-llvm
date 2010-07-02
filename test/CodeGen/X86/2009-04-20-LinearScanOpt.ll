; RUN: llc < %s -mtriple=x86_64-apple-darwin10.0 -relocation-model=pic -disable-fp-elim -stats |& grep asm-printer | grep 82
; rdar://6802189

; Test if linearscan is unfavoring registers for allocation to allow more reuse
; of reloads from stack slots.

	%struct.SHA_CTX = type { i32, i32, i32, i32, i32, i32, i32, [16 x i32], i32 }

define fastcc void @sha1_block_data_order(%struct.SHA_CTX* nocapture %c, i8* %p, i64 %num) nounwind {
entry:
	br label %bb

bb:		; preds = %bb, %entry
	%asmtmp511 = tail call i32 asm "roll $1,$0", "=r,I,0,~{dirflag},~{fpsr},~{flags},~{cc}"(i32 1, i32 0) nounwind		; <i32> [#uses=3]
	%asmtmp513 = tail call i32 asm "roll $1,$0", "=r,I,0,~{dirflag},~{fpsr},~{flags},~{cc}"(i32 30, i32 0) nounwind		; <i32> [#uses=2]
	%asmtmp516 = tail call i32 asm "roll $1,$0", "=r,I,0,~{dirflag},~{fpsr},~{flags},~{cc}"(i32 30, i32 0) nounwind		; <i32> [#uses=1]
	%asmtmp517 = tail call i32 asm "roll $1,$0", "=r,I,0,~{dirflag},~{fpsr},~{flags},~{cc}"(i32 1, i32 0) nounwind		; <i32> [#uses=2]
	%0 = xor i32 0, %asmtmp513		; <i32> [#uses=0]
	%1 = add i32 0, %asmtmp517		; <i32> [#uses=1]
	%2 = add i32 %1, 0		; <i32> [#uses=1]
	%3 = add i32 %2, 0		; <i32> [#uses=1]
	%asmtmp519 = tail call i32 asm "roll $1,$0", "=r,I,0,~{dirflag},~{fpsr},~{flags},~{cc}"(i32 30, i32 0) nounwind		; <i32> [#uses=1]
	%4 = xor i32 0, %asmtmp511		; <i32> [#uses=1]
	%asmtmp520 = tail call i32 asm "roll $1,$0", "=r,I,0,~{dirflag},~{fpsr},~{flags},~{cc}"(i32 1, i32 %4) nounwind		; <i32> [#uses=2]
	%5 = xor i32 0, %asmtmp516		; <i32> [#uses=1]
	%6 = xor i32 %5, %asmtmp519		; <i32> [#uses=1]
	%7 = add i32 %asmtmp513, -899497514		; <i32> [#uses=1]
	%8 = add i32 %7, %asmtmp520		; <i32> [#uses=1]
	%9 = add i32 %8, %6		; <i32> [#uses=1]
	%10 = add i32 %9, 0		; <i32> [#uses=1]
	%asmtmp523 = tail call i32 asm "roll $1,$0", "=r,I,0,~{dirflag},~{fpsr},~{flags},~{cc}"(i32 1, i32 0) nounwind		; <i32> [#uses=1]
	%asmtmp525 = tail call i32 asm "roll $1,$0", "=r,I,0,~{dirflag},~{fpsr},~{flags},~{cc}"(i32 30, i32 %3) nounwind		; <i32> [#uses=2]
	%11 = xor i32 0, %asmtmp525		; <i32> [#uses=1]
	%12 = add i32 0, %11		; <i32> [#uses=1]
	%13 = add i32 %12, 0		; <i32> [#uses=2]
	%asmtmp528 = tail call i32 asm "roll $1,$0", "=r,I,0,~{dirflag},~{fpsr},~{flags},~{cc}"(i32 30, i32 %10) nounwind		; <i32> [#uses=1]
	%14 = xor i32 0, %asmtmp520		; <i32> [#uses=1]
	%asmtmp529 = tail call i32 asm "roll $1,$0", "=r,I,0,~{dirflag},~{fpsr},~{flags},~{cc}"(i32 1, i32 %14) nounwind		; <i32> [#uses=1]
	%asmtmp530 = tail call i32 asm "roll $1,$0", "=r,I,0,~{dirflag},~{fpsr},~{flags},~{cc}"(i32 5, i32 %13) nounwind		; <i32> [#uses=1]
	%15 = add i32 0, %asmtmp530		; <i32> [#uses=1]
	%16 = xor i32 0, %asmtmp523		; <i32> [#uses=1]
	%asmtmp532 = tail call i32 asm "roll $1,$0", "=r,I,0,~{dirflag},~{fpsr},~{flags},~{cc}"(i32 1, i32 %16) nounwind		; <i32> [#uses=2]
	%asmtmp533 = tail call i32 asm "roll $1,$0", "=r,I,0,~{dirflag},~{fpsr},~{flags},~{cc}"(i32 5, i32 %15) nounwind		; <i32> [#uses=1]
	%17 = xor i32 %13, %asmtmp528		; <i32> [#uses=1]
	%18 = xor i32 %17, 0		; <i32> [#uses=1]
	%19 = add i32 %asmtmp525, -899497514		; <i32> [#uses=1]
	%20 = add i32 %19, %asmtmp532		; <i32> [#uses=1]
	%21 = add i32 %20, %18		; <i32> [#uses=1]
	%22 = add i32 %21, %asmtmp533		; <i32> [#uses=1]
	%23 = xor i32 0, %asmtmp511		; <i32> [#uses=1]
	%24 = xor i32 %23, 0		; <i32> [#uses=1]
	%asmtmp535 = tail call i32 asm "roll $1,$0", "=r,I,0,~{dirflag},~{fpsr},~{flags},~{cc}"(i32 1, i32 %24) nounwind		; <i32> [#uses=3]
	%25 = add i32 0, %asmtmp535		; <i32> [#uses=1]
	%26 = add i32 %25, 0		; <i32> [#uses=1]
	%27 = add i32 %26, 0		; <i32> [#uses=1]
	%28 = xor i32 0, %asmtmp529		; <i32> [#uses=0]
	%29 = xor i32 %22, 0		; <i32> [#uses=1]
	%30 = xor i32 %29, 0		; <i32> [#uses=1]
	%31 = add i32 0, %30		; <i32> [#uses=1]
	%32 = add i32 %31, 0		; <i32> [#uses=3]
	%asmtmp541 = tail call i32 asm "roll $1,$0", "=r,I,0,~{dirflag},~{fpsr},~{flags},~{cc}"(i32 1, i32 0) nounwind		; <i32> [#uses=2]
	%asmtmp542 = tail call i32 asm "roll $1,$0", "=r,I,0,~{dirflag},~{fpsr},~{flags},~{cc}"(i32 5, i32 %32) nounwind		; <i32> [#uses=1]
	%33 = add i32 0, %asmtmp541		; <i32> [#uses=1]
	%34 = add i32 %33, 0		; <i32> [#uses=1]
	%35 = add i32 %34, %asmtmp542		; <i32> [#uses=1]
	%asmtmp543 = tail call i32 asm "roll $1,$0", "=r,I,0,~{dirflag},~{fpsr},~{flags},~{cc}"(i32 30, i32 %27) nounwind		; <i32> [#uses=2]
	%36 = xor i32 0, %asmtmp535		; <i32> [#uses=0]
	%37 = xor i32 %32, 0		; <i32> [#uses=1]
	%38 = xor i32 %37, %asmtmp543		; <i32> [#uses=1]
	%39 = add i32 0, %38		; <i32> [#uses=1]
	%40 = add i32 %39, 0		; <i32> [#uses=2]
	%asmtmp546 = tail call i32 asm "roll $1,$0", "=r,I,0,~{dirflag},~{fpsr},~{flags},~{cc}"(i32 30, i32 %32) nounwind		; <i32> [#uses=1]
	%asmtmp547 = tail call i32 asm "roll $1,$0", "=r,I,0,~{dirflag},~{fpsr},~{flags},~{cc}"(i32 1, i32 0) nounwind		; <i32> [#uses=2]
	%41 = add i32 0, -899497514		; <i32> [#uses=1]
	%42 = add i32 %41, %asmtmp547		; <i32> [#uses=1]
	%43 = add i32 %42, 0		; <i32> [#uses=1]
	%44 = add i32 %43, 0		; <i32> [#uses=3]
	%asmtmp549 = tail call i32 asm "roll $1,$0", "=r,I,0,~{dirflag},~{fpsr},~{flags},~{cc}"(i32 30, i32 %35) nounwind		; <i32> [#uses=2]
	%45 = xor i32 0, %asmtmp541		; <i32> [#uses=1]
	%asmtmp550 = tail call i32 asm "roll $1,$0", "=r,I,0,~{dirflag},~{fpsr},~{flags},~{cc}"(i32 1, i32 %45) nounwind		; <i32> [#uses=2]
	%asmtmp551 = tail call i32 asm "roll $1,$0", "=r,I,0,~{dirflag},~{fpsr},~{flags},~{cc}"(i32 5, i32 %44) nounwind		; <i32> [#uses=1]
	%46 = xor i32 %40, %asmtmp546		; <i32> [#uses=1]
	%47 = xor i32 %46, %asmtmp549		; <i32> [#uses=1]
	%48 = add i32 %asmtmp543, -899497514		; <i32> [#uses=1]
	%49 = add i32 %48, %asmtmp550		; <i32> [#uses=1]
	%50 = add i32 %49, %47		; <i32> [#uses=1]
	%51 = add i32 %50, %asmtmp551		; <i32> [#uses=1]
	%asmtmp552 = tail call i32 asm "roll $1,$0", "=r,I,0,~{dirflag},~{fpsr},~{flags},~{cc}"(i32 30, i32 %40) nounwind		; <i32> [#uses=2]
	%52 = xor i32 %44, %asmtmp549		; <i32> [#uses=1]
	%53 = xor i32 %52, %asmtmp552		; <i32> [#uses=1]
	%54 = add i32 0, %53		; <i32> [#uses=1]
	%55 = add i32 %54, 0		; <i32> [#uses=2]
	%asmtmp555 = tail call i32 asm "roll $1,$0", "=r,I,0,~{dirflag},~{fpsr},~{flags},~{cc}"(i32 30, i32 %44) nounwind		; <i32> [#uses=2]
	%56 = xor i32 0, %asmtmp532		; <i32> [#uses=1]
	%57 = xor i32 %56, %asmtmp547		; <i32> [#uses=1]
	%asmtmp556 = tail call i32 asm "roll $1,$0", "=r,I,0,~{dirflag},~{fpsr},~{flags},~{cc}"(i32 1, i32 %57) nounwind		; <i32> [#uses=1]
	%58 = add i32 0, %asmtmp556		; <i32> [#uses=1]
	%59 = add i32 %58, 0		; <i32> [#uses=1]
	%60 = add i32 %59, 0		; <i32> [#uses=1]
	%asmtmp558 = tail call i32 asm "roll $1,$0", "=r,I,0,~{dirflag},~{fpsr},~{flags},~{cc}"(i32 30, i32 %51) nounwind		; <i32> [#uses=1]
	%61 = xor i32 %asmtmp517, %asmtmp511		; <i32> [#uses=1]
	%62 = xor i32 %61, %asmtmp535		; <i32> [#uses=1]
	%63 = xor i32 %62, %asmtmp550		; <i32> [#uses=1]
	%asmtmp559 = tail call i32 asm "roll $1,$0", "=r,I,0,~{dirflag},~{fpsr},~{flags},~{cc}"(i32 1, i32 %63) nounwind		; <i32> [#uses=1]
	%64 = xor i32 %55, %asmtmp555		; <i32> [#uses=1]
	%65 = xor i32 %64, %asmtmp558		; <i32> [#uses=1]
	%asmtmp561 = tail call i32 asm "roll $1,$0", "=r,I,0,~{dirflag},~{fpsr},~{flags},~{cc}"(i32 30, i32 %55) nounwind		; <i32> [#uses=1]
	%66 = add i32 %asmtmp552, -899497514		; <i32> [#uses=1]
	%67 = add i32 %66, %65		; <i32> [#uses=1]
	%68 = add i32 %67, %asmtmp559		; <i32> [#uses=1]
	%69 = add i32 %68, 0		; <i32> [#uses=1]
	%70 = add i32 %69, 0		; <i32> [#uses=1]
	store i32 %70, i32* null, align 4
	%71 = add i32 0, %60		; <i32> [#uses=1]
	store i32 %71, i32* null, align 4
	%72 = add i32 0, %asmtmp561		; <i32> [#uses=1]
	store i32 %72, i32* null, align 4
	%73 = add i32 0, %asmtmp555		; <i32> [#uses=1]
	store i32 %73, i32* null, align 4
	br label %bb
}
