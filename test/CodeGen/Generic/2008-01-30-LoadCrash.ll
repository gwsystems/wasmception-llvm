; RUN: llvm-as < %s | llc

target datalayout = "e-p:32:32:32-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:32:64-f32:32:32-f64:32:64-v64:64:64-v128:128:128-a0:0:64-f80:32:32"
target triple = "i686-pc-linux-gnu"
@letters.3100 = external constant [63 x i8]		; <[63 x i8]*> [#uses=2]

define i32 @mkstemps(i8* %pattern, i32 %suffix_len, i64 %tmp42.rle) nounwind  {
bb20:
	br label %bb41

bb41:		; preds = %bb20
	%tmp8182 = trunc i64 %tmp42.rle to i32		; <i32> [#uses=1]
	%tmp83 = getelementptr [63 x i8]* @letters.3100, i32 0, i32 %tmp8182		; <i8*> [#uses=1]
	%tmp84 = load i8* %tmp83, align 1		; <i8> [#uses=1]
	store i8 %tmp84, i8* null, align 1
	%tmp90 = urem i64 %tmp42.rle, 62		; <i64> [#uses=1]
	%tmp9091 = trunc i64 %tmp90 to i32		; <i32> [#uses=1]
	%tmp92 = getelementptr [63 x i8]* @letters.3100, i32 0, i32 %tmp9091		; <i8*> [#uses=1]
	store i8* %tmp92, i8** null, align 1
	ret i32 -1
}
