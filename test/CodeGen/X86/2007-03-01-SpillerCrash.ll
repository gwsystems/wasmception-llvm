; RUN: llc < %s -mtriple=x86_64-apple-darwin8 -mattr=+sse2
; RUN: llc < %s -mtriple=x86_64-apple-darwin8 -mattr=+sse2 | not grep movhlps

define void @test() nounwind {
test.exit:
	fmul <4 x float> zeroinitializer, zeroinitializer		; <<4 x float>>:0 [#uses=4]
	load <4 x float>, <4 x float>* null		; <<4 x float>>:1 [#uses=1]
	shufflevector <4 x float> %1, <4 x float> undef, <4 x i32> < i32 3, i32 3, i32 3, i32 3 >		; <<4 x float>>:2 [#uses=1]
	fmul <4 x float> %0, %2		; <<4 x float>>:3 [#uses=1]
	fsub <4 x float> zeroinitializer, %3		; <<4 x float>>:4 [#uses=1]
	fmul <4 x float> %4, zeroinitializer		; <<4 x float>>:5 [#uses=2]
	bitcast <4 x float> zeroinitializer to <4 x i32>		; <<4 x i32>>:6 [#uses=1]
	and <4 x i32> %6, < i32 2147483647, i32 2147483647, i32 2147483647, i32 2147483647 >		; <<4 x i32>>:7 [#uses=1]
	bitcast <4 x i32> %7 to <4 x float>		; <<4 x float>>:8 [#uses=2]
	extractelement <4 x float> %8, i32 0		; <float>:9 [#uses=1]
	extractelement <4 x float> %8, i32 1		; <float>:10 [#uses=2]
	br i1 false, label %11, label %19

; <label>:11		; preds = %test.exit
	br i1 false, label %17, label %12

; <label>:12		; preds = %11
	br i1 false, label %19, label %13

; <label>:13		; preds = %12
	fsub float -0.000000e+00, 0.000000e+00		; <float>:14 [#uses=1]
	%tmp207 = extractelement <4 x float> zeroinitializer, i32 0		; <float> [#uses=1]
	%tmp208 = extractelement <4 x float> zeroinitializer, i32 2		; <float> [#uses=1]
	fsub float -0.000000e+00, %tmp208		; <float>:15 [#uses=1]
	%tmp155 = extractelement <4 x float> zeroinitializer, i32 0		; <float> [#uses=1]
	%tmp156 = extractelement <4 x float> zeroinitializer, i32 2		; <float> [#uses=1]
	fsub float -0.000000e+00, %tmp156		; <float>:16 [#uses=1]
	br label %19

; <label>:17		; preds = %11
	br i1 false, label %19, label %18

; <label>:18		; preds = %17
	br label %19

; <label>:19		; preds = %18, %17, %13, %12, %test.exit
	phi i32 [ 5, %18 ], [ 3, %13 ], [ 1, %test.exit ], [ 2, %12 ], [ 4, %17 ]		; <i32>:20 [#uses=0]
	phi float [ 0.000000e+00, %18 ], [ %16, %13 ], [ 0.000000e+00, %test.exit ], [ 0.000000e+00, %12 ], [ 0.000000e+00, %17 ]		; <float>:21 [#uses=1]
	phi float [ 0.000000e+00, %18 ], [ %tmp155, %13 ], [ 0.000000e+00, %test.exit ], [ 0.000000e+00, %12 ], [ 0.000000e+00, %17 ]		; <float>:22 [#uses=1]
	phi float [ 0.000000e+00, %18 ], [ %15, %13 ], [ 0.000000e+00, %test.exit ], [ 0.000000e+00, %12 ], [ 0.000000e+00, %17 ]		; <float>:23 [#uses=1]
	phi float [ 0.000000e+00, %18 ], [ %tmp207, %13 ], [ 0.000000e+00, %test.exit ], [ 0.000000e+00, %12 ], [ 0.000000e+00, %17 ]		; <float>:24 [#uses=1]
	phi float [ 0.000000e+00, %18 ], [ %10, %13 ], [ %9, %test.exit ], [ %10, %12 ], [ 0.000000e+00, %17 ]		; <float>:25 [#uses=2]
	phi float [ 0.000000e+00, %18 ], [ %14, %13 ], [ 0.000000e+00, %test.exit ], [ 0.000000e+00, %12 ], [ 0.000000e+00, %17 ]		; <float>:26 [#uses=1]
	phi float [ 0.000000e+00, %18 ], [ 0.000000e+00, %13 ], [ 0.000000e+00, %test.exit ], [ 0.000000e+00, %12 ], [ 0.000000e+00, %17 ]		; <float>:27 [#uses=1]
	insertelement <4 x float> undef, float %27, i32 0		; <<4 x float>>:28 [#uses=1]
	insertelement <4 x float> %28, float %26, i32 1		; <<4 x float>>:29 [#uses=0]
	insertelement <4 x float> undef, float %24, i32 0		; <<4 x float>>:30 [#uses=1]
	insertelement <4 x float> %30, float %23, i32 1		; <<4 x float>>:31 [#uses=1]
	insertelement <4 x float> %31, float %25, i32 2		; <<4 x float>>:32 [#uses=1]
	insertelement <4 x float> %32, float %25, i32 3		; <<4 x float>>:33 [#uses=1]
	fdiv <4 x float> %33, zeroinitializer		; <<4 x float>>:34 [#uses=1]
	fmul <4 x float> %34, < float 5.000000e-01, float 5.000000e-01, float 5.000000e-01, float 5.000000e-01 >		; <<4 x float>>:35 [#uses=1]
	insertelement <4 x float> undef, float %22, i32 0		; <<4 x float>>:36 [#uses=1]
	insertelement <4 x float> %36, float %21, i32 1		; <<4 x float>>:37 [#uses=0]
	br i1 false, label %foo.exit, label %38

; <label>:38		; preds = %19
	extractelement <4 x float> %0, i32 0		; <float>:39 [#uses=1]
	fcmp ogt float %39, 0.000000e+00		; <i1>:40 [#uses=1]
	extractelement <4 x float> %0, i32 2		; <float>:41 [#uses=1]
	extractelement <4 x float> %0, i32 1		; <float>:42 [#uses=1]
	fsub float -0.000000e+00, %42		; <float>:43 [#uses=2]
	%tmp189 = extractelement <4 x float> %5, i32 2		; <float> [#uses=1]
	br i1 %40, label %44, label %46

; <label>:44		; preds = %38
	fsub float -0.000000e+00, %tmp189		; <float>:45 [#uses=0]
	br label %foo.exit

; <label>:46		; preds = %38
	%tmp192 = extractelement <4 x float> %5, i32 1		; <float> [#uses=1]
	fsub float -0.000000e+00, %tmp192		; <float>:47 [#uses=1]
	br label %foo.exit

foo.exit:		; preds = %46, %44, %19
	phi float [ 0.000000e+00, %44 ], [ %47, %46 ], [ 0.000000e+00, %19 ]		; <float>:48 [#uses=0]
	phi float [ %43, %44 ], [ %43, %46 ], [ 0.000000e+00, %19 ]		; <float>:49 [#uses=0]
	phi float [ 0.000000e+00, %44 ], [ %41, %46 ], [ 0.000000e+00, %19 ]		; <float>:50 [#uses=0]
	shufflevector <4 x float> %35, <4 x float> zeroinitializer, <4 x i32> < i32 0, i32 4, i32 1, i32 5 >		; <<4 x float>>:51 [#uses=0]
	unreachable
}
