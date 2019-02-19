; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i386-unknown-unknown -mattr=+sse2 | FileCheck %s --check-prefixes=CHECK,X86,SSE,X86-SSE
; RUN: llc < %s -mtriple=i386-unknown-unknown -mattr=+avx | FileCheck %s --check-prefixes=CHECK,X86,AVX,X86-AVX,AVX1,X86-AVX1
; RUN: llc < %s -mtriple=i386-unknown-unknown -mattr=+avx512f,+avx512bw,+avx512dq,+avx512vl | FileCheck %s --check-prefixes=CHECK,X86,AVX,X86-AVX,AVX512,X86-AVX512
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+sse2 | FileCheck %s --check-prefixes=CHECK,X64,SSE,X64-SSE
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx | FileCheck %s --check-prefixes=CHECK,X64,AVX,X64-AVX,AVX1,X64-AVX1
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512f,+avx512bw,+avx512dq,+avx512vl | FileCheck %s --check-prefixes=CHECK,X64,AVX,X64-AVX,AVX512,X64-AVX512

; Tests for SSE2 and below, without SSE3+.

define void @test1(<2 x double>* %r, <2 x double>* %A, double %B) nounwind  {
; X86-SSE-LABEL: test1:
; X86-SSE:       # %bb.0:
; X86-SSE-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-SSE-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-SSE-NEXT:    movapd (%ecx), %xmm0
; X86-SSE-NEXT:    movlpd {{.*#+}} xmm0 = mem[0],xmm0[1]
; X86-SSE-NEXT:    movapd %xmm0, (%eax)
; X86-SSE-NEXT:    retl
;
; X86-AVX-LABEL: test1:
; X86-AVX:       # %bb.0:
; X86-AVX-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-AVX-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-AVX-NEXT:    vmovapd (%ecx), %xmm0
; X86-AVX-NEXT:    vmovlpd {{.*#+}} xmm0 = mem[0],xmm0[1]
; X86-AVX-NEXT:    vmovapd %xmm0, (%eax)
; X86-AVX-NEXT:    retl
;
; X64-SSE-LABEL: test1:
; X64-SSE:       # %bb.0:
; X64-SSE-NEXT:    movapd (%rsi), %xmm1
; X64-SSE-NEXT:    movsd {{.*#+}} xmm1 = xmm0[0],xmm1[1]
; X64-SSE-NEXT:    movapd %xmm1, (%rdi)
; X64-SSE-NEXT:    retq
;
; X64-AVX-LABEL: test1:
; X64-AVX:       # %bb.0:
; X64-AVX-NEXT:    vblendps {{.*#+}} xmm0 = xmm0[0,1],mem[2,3]
; X64-AVX-NEXT:    vmovaps %xmm0, (%rdi)
; X64-AVX-NEXT:    retq
	%tmp3 = load <2 x double>, <2 x double>* %A, align 16
	%tmp7 = insertelement <2 x double> undef, double %B, i32 0
	%tmp9 = shufflevector <2 x double> %tmp3, <2 x double> %tmp7, <2 x i32> < i32 2, i32 1 >
	store <2 x double> %tmp9, <2 x double>* %r, align 16
	ret void
}

define void @test2(<2 x double>* %r, <2 x double>* %A, double %B) nounwind  {
; X86-SSE-LABEL: test2:
; X86-SSE:       # %bb.0:
; X86-SSE-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-SSE-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-SSE-NEXT:    movapd (%ecx), %xmm0
; X86-SSE-NEXT:    movhpd {{.*#+}} xmm0 = xmm0[0],mem[0]
; X86-SSE-NEXT:    movapd %xmm0, (%eax)
; X86-SSE-NEXT:    retl
;
; X86-AVX-LABEL: test2:
; X86-AVX:       # %bb.0:
; X86-AVX-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-AVX-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-AVX-NEXT:    vmovapd (%ecx), %xmm0
; X86-AVX-NEXT:    vmovhpd {{.*#+}} xmm0 = xmm0[0],mem[0]
; X86-AVX-NEXT:    vmovapd %xmm0, (%eax)
; X86-AVX-NEXT:    retl
;
; X64-SSE-LABEL: test2:
; X64-SSE:       # %bb.0:
; X64-SSE-NEXT:    movaps (%rsi), %xmm1
; X64-SSE-NEXT:    movlhps {{.*#+}} xmm1 = xmm1[0],xmm0[0]
; X64-SSE-NEXT:    movaps %xmm1, (%rdi)
; X64-SSE-NEXT:    retq
;
; X64-AVX-LABEL: test2:
; X64-AVX:       # %bb.0:
; X64-AVX-NEXT:    vmovaps (%rsi), %xmm1
; X64-AVX-NEXT:    vmovlhps {{.*#+}} xmm0 = xmm1[0],xmm0[0]
; X64-AVX-NEXT:    vmovaps %xmm0, (%rdi)
; X64-AVX-NEXT:    retq
	%tmp3 = load <2 x double>, <2 x double>* %A, align 16
	%tmp7 = insertelement <2 x double> undef, double %B, i32 0
	%tmp9 = shufflevector <2 x double> %tmp3, <2 x double> %tmp7, <2 x i32> < i32 0, i32 2 >
	store <2 x double> %tmp9, <2 x double>* %r, align 16
	ret void
}


define void @test3(<4 x float>* %res, <4 x float>* %A, <4 x float>* %B) nounwind {
; X86-SSE-LABEL: test3:
; X86-SSE:       # %bb.0:
; X86-SSE-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-SSE-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-SSE-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-SSE-NEXT:    movaps (%edx), %xmm0
; X86-SSE-NEXT:    unpcklps {{.*#+}} xmm0 = xmm0[0],mem[0],xmm0[1],mem[1]
; X86-SSE-NEXT:    movaps %xmm0, (%eax)
; X86-SSE-NEXT:    retl
;
; X86-AVX-LABEL: test3:
; X86-AVX:       # %bb.0:
; X86-AVX-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-AVX-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-AVX-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-AVX-NEXT:    vmovaps (%edx), %xmm0
; X86-AVX-NEXT:    vunpcklps {{.*#+}} xmm0 = xmm0[0],mem[0],xmm0[1],mem[1]
; X86-AVX-NEXT:    vmovaps %xmm0, (%eax)
; X86-AVX-NEXT:    retl
;
; X64-SSE-LABEL: test3:
; X64-SSE:       # %bb.0:
; X64-SSE-NEXT:    movaps (%rsi), %xmm0
; X64-SSE-NEXT:    unpcklps {{.*#+}} xmm0 = xmm0[0],mem[0],xmm0[1],mem[1]
; X64-SSE-NEXT:    movaps %xmm0, (%rdi)
; X64-SSE-NEXT:    retq
;
; X64-AVX-LABEL: test3:
; X64-AVX:       # %bb.0:
; X64-AVX-NEXT:    vmovaps (%rsi), %xmm0
; X64-AVX-NEXT:    vunpcklps {{.*#+}} xmm0 = xmm0[0],mem[0],xmm0[1],mem[1]
; X64-AVX-NEXT:    vmovaps %xmm0, (%rdi)
; X64-AVX-NEXT:    retq
	%tmp = load <4 x float>, <4 x float>* %B		; <<4 x float>> [#uses=2]
	%tmp3 = load <4 x float>, <4 x float>* %A		; <<4 x float>> [#uses=2]
	%tmp.upgrd.1 = extractelement <4 x float> %tmp3, i32 0		; <float> [#uses=1]
	%tmp7 = extractelement <4 x float> %tmp, i32 0		; <float> [#uses=1]
	%tmp8 = extractelement <4 x float> %tmp3, i32 1		; <float> [#uses=1]
	%tmp9 = extractelement <4 x float> %tmp, i32 1		; <float> [#uses=1]
	%tmp10 = insertelement <4 x float> undef, float %tmp.upgrd.1, i32 0		; <<4 x float>> [#uses=1]
	%tmp11 = insertelement <4 x float> %tmp10, float %tmp7, i32 1		; <<4 x float>> [#uses=1]
	%tmp12 = insertelement <4 x float> %tmp11, float %tmp8, i32 2		; <<4 x float>> [#uses=1]
	%tmp13 = insertelement <4 x float> %tmp12, float %tmp9, i32 3		; <<4 x float>> [#uses=1]
	store <4 x float> %tmp13, <4 x float>* %res
	ret void
}

define void @test4(<4 x float> %X, <4 x float>* %res) nounwind {
; X86-SSE-LABEL: test4:
; X86-SSE:       # %bb.0:
; X86-SSE-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-SSE-NEXT:    shufps {{.*#+}} xmm0 = xmm0[2,1,3,3]
; X86-SSE-NEXT:    movaps %xmm0, (%eax)
; X86-SSE-NEXT:    retl
;
; X86-AVX-LABEL: test4:
; X86-AVX:       # %bb.0:
; X86-AVX-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-AVX-NEXT:    vpermilps {{.*#+}} xmm0 = xmm0[2,1,3,3]
; X86-AVX-NEXT:    vmovaps %xmm0, (%eax)
; X86-AVX-NEXT:    retl
;
; X64-SSE-LABEL: test4:
; X64-SSE:       # %bb.0:
; X64-SSE-NEXT:    shufps {{.*#+}} xmm0 = xmm0[2,1,3,3]
; X64-SSE-NEXT:    movaps %xmm0, (%rdi)
; X64-SSE-NEXT:    retq
;
; X64-AVX-LABEL: test4:
; X64-AVX:       # %bb.0:
; X64-AVX-NEXT:    vpermilps {{.*#+}} xmm0 = xmm0[2,1,3,3]
; X64-AVX-NEXT:    vmovaps %xmm0, (%rdi)
; X64-AVX-NEXT:    retq
	%tmp5 = shufflevector <4 x float> %X, <4 x float> undef, <4 x i32> < i32 2, i32 6, i32 3, i32 7 >		; <<4 x float>> [#uses=1]
	store <4 x float> %tmp5, <4 x float>* %res
	ret void
}

define <4 x i32> @test5(i8** %ptr) nounwind {
; X86-SSE-LABEL: test5:
; X86-SSE:       # %bb.0:
; X86-SSE-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-SSE-NEXT:    movl (%eax), %eax
; X86-SSE-NEXT:    movd {{.*#+}} xmm1 = mem[0],zero,zero,zero
; X86-SSE-NEXT:    pxor %xmm0, %xmm0
; X86-SSE-NEXT:    punpcklbw {{.*#+}} xmm1 = xmm1[0],xmm0[0],xmm1[1],xmm0[1],xmm1[2],xmm0[2],xmm1[3],xmm0[3],xmm1[4],xmm0[4],xmm1[5],xmm0[5],xmm1[6],xmm0[6],xmm1[7],xmm0[7]
; X86-SSE-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3]
; X86-SSE-NEXT:    retl
;
; X86-AVX-LABEL: test5:
; X86-AVX:       # %bb.0:
; X86-AVX-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-AVX-NEXT:    movl (%eax), %eax
; X86-AVX-NEXT:    vmovd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; X86-AVX-NEXT:    vpmovzxbw {{.*#+}} xmm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero,xmm0[4],zero,xmm0[5],zero,xmm0[6],zero,xmm0[7],zero
; X86-AVX-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; X86-AVX-NEXT:    vpunpcklwd {{.*#+}} xmm0 = xmm1[0],xmm0[0],xmm1[1],xmm0[1],xmm1[2],xmm0[2],xmm1[3],xmm0[3]
; X86-AVX-NEXT:    retl
;
; X64-SSE-LABEL: test5:
; X64-SSE:       # %bb.0:
; X64-SSE-NEXT:    movq (%rdi), %rax
; X64-SSE-NEXT:    movd {{.*#+}} xmm1 = mem[0],zero,zero,zero
; X64-SSE-NEXT:    pxor %xmm0, %xmm0
; X64-SSE-NEXT:    punpcklbw {{.*#+}} xmm1 = xmm1[0],xmm0[0],xmm1[1],xmm0[1],xmm1[2],xmm0[2],xmm1[3],xmm0[3],xmm1[4],xmm0[4],xmm1[5],xmm0[5],xmm1[6],xmm0[6],xmm1[7],xmm0[7]
; X64-SSE-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3]
; X64-SSE-NEXT:    retq
;
; X64-AVX-LABEL: test5:
; X64-AVX:       # %bb.0:
; X64-AVX-NEXT:    movq (%rdi), %rax
; X64-AVX-NEXT:    vmovd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; X64-AVX-NEXT:    vpmovzxbw {{.*#+}} xmm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero,xmm0[4],zero,xmm0[5],zero,xmm0[6],zero,xmm0[7],zero
; X64-AVX-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; X64-AVX-NEXT:    vpunpcklwd {{.*#+}} xmm0 = xmm1[0],xmm0[0],xmm1[1],xmm0[1],xmm1[2],xmm0[2],xmm1[3],xmm0[3]
; X64-AVX-NEXT:    retq
	%tmp = load i8*, i8** %ptr		; <i8*> [#uses=1]
	%tmp.upgrd.1 = bitcast i8* %tmp to float*		; <float*> [#uses=1]
	%tmp.upgrd.2 = load float, float* %tmp.upgrd.1		; <float> [#uses=1]
	%tmp.upgrd.3 = insertelement <4 x float> undef, float %tmp.upgrd.2, i32 0		; <<4 x float>> [#uses=1]
	%tmp9 = insertelement <4 x float> %tmp.upgrd.3, float 0.000000e+00, i32 1		; <<4 x float>> [#uses=1]
	%tmp10 = insertelement <4 x float> %tmp9, float 0.000000e+00, i32 2		; <<4 x float>> [#uses=1]
	%tmp11 = insertelement <4 x float> %tmp10, float 0.000000e+00, i32 3		; <<4 x float>> [#uses=1]
	%tmp21 = bitcast <4 x float> %tmp11 to <16 x i8>		; <<16 x i8>> [#uses=1]
	%tmp22 = shufflevector <16 x i8> %tmp21, <16 x i8> zeroinitializer, <16 x i32> < i32 0, i32 16, i32 1, i32 17, i32 2, i32 18, i32 3, i32 19, i32 4, i32 20, i32 5, i32 21, i32 6, i32 22, i32 7, i32 23 >		; <<16 x i8>> [#uses=1]
	%tmp31 = bitcast <16 x i8> %tmp22 to <8 x i16>		; <<8 x i16>> [#uses=1]
	%tmp.upgrd.4 = shufflevector <8 x i16> zeroinitializer, <8 x i16> %tmp31, <8 x i32> < i32 0, i32 8, i32 1, i32 9, i32 2, i32 10, i32 3, i32 11 >		; <<8 x i16>> [#uses=1]
	%tmp36 = bitcast <8 x i16> %tmp.upgrd.4 to <4 x i32>		; <<4 x i32>> [#uses=1]
	ret <4 x i32> %tmp36
}

define void @test6(<4 x float>* %res, <4 x float>* %A) nounwind {
; X86-SSE-LABEL: test6:
; X86-SSE:       # %bb.0:
; X86-SSE-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-SSE-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-SSE-NEXT:    movaps (%ecx), %xmm0
; X86-SSE-NEXT:    movaps %xmm0, (%eax)
; X86-SSE-NEXT:    retl
;
; X86-AVX-LABEL: test6:
; X86-AVX:       # %bb.0:
; X86-AVX-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-AVX-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-AVX-NEXT:    vmovaps (%ecx), %xmm0
; X86-AVX-NEXT:    vmovaps %xmm0, (%eax)
; X86-AVX-NEXT:    retl
;
; X64-SSE-LABEL: test6:
; X64-SSE:       # %bb.0:
; X64-SSE-NEXT:    movaps (%rsi), %xmm0
; X64-SSE-NEXT:    movaps %xmm0, (%rdi)
; X64-SSE-NEXT:    retq
;
; X64-AVX-LABEL: test6:
; X64-AVX:       # %bb.0:
; X64-AVX-NEXT:    vmovaps (%rsi), %xmm0
; X64-AVX-NEXT:    vmovaps %xmm0, (%rdi)
; X64-AVX-NEXT:    retq
  %tmp1 = load <4 x float>, <4 x float>* %A            ; <<4 x float>> [#uses=1]
  %tmp2 = shufflevector <4 x float> %tmp1, <4 x float> undef, <4 x i32> < i32 0, i32 5, i32 6, i32 7 >          ; <<4 x float>> [#uses=1]
  store <4 x float> %tmp2, <4 x float>* %res
  ret void
}

define void @test7() nounwind {
; SSE-LABEL: test7:
; SSE:       # %bb.0:
; SSE-NEXT:    xorps %xmm0, %xmm0
; SSE-NEXT:    movaps %xmm0, 0
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test7:
; AVX:       # %bb.0:
; AVX-NEXT:    vxorps %xmm0, %xmm0, %xmm0
; AVX-NEXT:    vmovaps %xmm0, 0
; AVX-NEXT:    ret{{[l|q]}}
  bitcast <4 x i32> zeroinitializer to <4 x float>                ; <<4 x float>>:1 [#uses=1]
  shufflevector <4 x float> %1, <4 x float> zeroinitializer, <4 x i32> zeroinitializer         ; <<4 x float>>:2 [#uses=1]
  store <4 x float> %2, <4 x float>* null
  ret void
}

@x = external global [4 x i32]

define <2 x i64> @test8() nounwind {
; X86-SSE-LABEL: test8:
; X86-SSE:       # %bb.0:
; X86-SSE-NEXT:    movups x, %xmm0
; X86-SSE-NEXT:    retl
;
; X86-AVX-LABEL: test8:
; X86-AVX:       # %bb.0:
; X86-AVX-NEXT:    vmovups x, %xmm0
; X86-AVX-NEXT:    retl
;
; X64-SSE-LABEL: test8:
; X64-SSE:       # %bb.0:
; X64-SSE-NEXT:    movups {{.*}}(%rip), %xmm0
; X64-SSE-NEXT:    retq
;
; X64-AVX-LABEL: test8:
; X64-AVX:       # %bb.0:
; X64-AVX-NEXT:    vmovups {{.*}}(%rip), %xmm0
; X64-AVX-NEXT:    retq
	%tmp = load i32, i32* getelementptr ([4 x i32], [4 x i32]* @x, i32 0, i32 0)		; <i32> [#uses=1]
	%tmp3 = load i32, i32* getelementptr ([4 x i32], [4 x i32]* @x, i32 0, i32 1)		; <i32> [#uses=1]
	%tmp5 = load i32, i32* getelementptr ([4 x i32], [4 x i32]* @x, i32 0, i32 2)		; <i32> [#uses=1]
	%tmp7 = load i32, i32* getelementptr ([4 x i32], [4 x i32]* @x, i32 0, i32 3)		; <i32> [#uses=1]
	%tmp.upgrd.1 = insertelement <4 x i32> undef, i32 %tmp, i32 0		; <<4 x i32>> [#uses=1]
	%tmp13 = insertelement <4 x i32> %tmp.upgrd.1, i32 %tmp3, i32 1		; <<4 x i32>> [#uses=1]
	%tmp14 = insertelement <4 x i32> %tmp13, i32 %tmp5, i32 2		; <<4 x i32>> [#uses=1]
	%tmp15 = insertelement <4 x i32> %tmp14, i32 %tmp7, i32 3		; <<4 x i32>> [#uses=1]
	%tmp16 = bitcast <4 x i32> %tmp15 to <2 x i64>		; <<2 x i64>> [#uses=1]
	ret <2 x i64> %tmp16
}

define <4 x float> @test9(i32 %dummy, float %a, float %b, float %c, float %d) nounwind {
; X86-SSE-LABEL: test9:
; X86-SSE:       # %bb.0:
; X86-SSE-NEXT:    movups {{[0-9]+}}(%esp), %xmm0
; X86-SSE-NEXT:    retl
;
; X86-AVX-LABEL: test9:
; X86-AVX:       # %bb.0:
; X86-AVX-NEXT:    vmovups {{[0-9]+}}(%esp), %xmm0
; X86-AVX-NEXT:    retl
;
; X64-SSE-LABEL: test9:
; X64-SSE:       # %bb.0:
; X64-SSE-NEXT:    unpcklps {{.*#+}} xmm2 = xmm2[0],xmm3[0],xmm2[1],xmm3[1]
; X64-SSE-NEXT:    unpcklps {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1]
; X64-SSE-NEXT:    movlhps {{.*#+}} xmm0 = xmm0[0],xmm2[0]
; X64-SSE-NEXT:    retq
;
; X64-AVX-LABEL: test9:
; X64-AVX:       # %bb.0:
; X64-AVX-NEXT:    vinsertps {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[2,3]
; X64-AVX-NEXT:    vinsertps {{.*#+}} xmm0 = xmm0[0,1],xmm2[0],xmm0[3]
; X64-AVX-NEXT:    vinsertps {{.*#+}} xmm0 = xmm0[0,1,2],xmm3[0]
; X64-AVX-NEXT:    retq
	%tmp = insertelement <4 x float> undef, float %a, i32 0		; <<4 x float>> [#uses=1]
	%tmp11 = insertelement <4 x float> %tmp, float %b, i32 1		; <<4 x float>> [#uses=1]
	%tmp12 = insertelement <4 x float> %tmp11, float %c, i32 2		; <<4 x float>> [#uses=1]
	%tmp13 = insertelement <4 x float> %tmp12, float %d, i32 3		; <<4 x float>> [#uses=1]
	ret <4 x float> %tmp13
}

define <4 x float> @test10(float %a, float %b, float %c, float %d) nounwind {
; X86-SSE-LABEL: test10:
; X86-SSE:       # %bb.0:
; X86-SSE-NEXT:    movups {{[0-9]+}}(%esp), %xmm0
; X86-SSE-NEXT:    retl
;
; X86-AVX-LABEL: test10:
; X86-AVX:       # %bb.0:
; X86-AVX-NEXT:    vmovups {{[0-9]+}}(%esp), %xmm0
; X86-AVX-NEXT:    retl
;
; X64-SSE-LABEL: test10:
; X64-SSE:       # %bb.0:
; X64-SSE-NEXT:    unpcklps {{.*#+}} xmm2 = xmm2[0],xmm3[0],xmm2[1],xmm3[1]
; X64-SSE-NEXT:    unpcklps {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1]
; X64-SSE-NEXT:    movlhps {{.*#+}} xmm0 = xmm0[0],xmm2[0]
; X64-SSE-NEXT:    retq
;
; X64-AVX-LABEL: test10:
; X64-AVX:       # %bb.0:
; X64-AVX-NEXT:    vinsertps {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[2,3]
; X64-AVX-NEXT:    vinsertps {{.*#+}} xmm0 = xmm0[0,1],xmm2[0],xmm0[3]
; X64-AVX-NEXT:    vinsertps {{.*#+}} xmm0 = xmm0[0,1,2],xmm3[0]
; X64-AVX-NEXT:    retq
	%tmp = insertelement <4 x float> undef, float %a, i32 0		; <<4 x float>> [#uses=1]
	%tmp11 = insertelement <4 x float> %tmp, float %b, i32 1		; <<4 x float>> [#uses=1]
	%tmp12 = insertelement <4 x float> %tmp11, float %c, i32 2		; <<4 x float>> [#uses=1]
	%tmp13 = insertelement <4 x float> %tmp12, float %d, i32 3		; <<4 x float>> [#uses=1]
	ret <4 x float> %tmp13
}

define <2 x double> @test11(double %a, double %b) nounwind {
; X86-SSE-LABEL: test11:
; X86-SSE:       # %bb.0:
; X86-SSE-NEXT:    movups {{[0-9]+}}(%esp), %xmm0
; X86-SSE-NEXT:    retl
;
; X86-AVX-LABEL: test11:
; X86-AVX:       # %bb.0:
; X86-AVX-NEXT:    vmovups {{[0-9]+}}(%esp), %xmm0
; X86-AVX-NEXT:    retl
;
; X64-SSE-LABEL: test11:
; X64-SSE:       # %bb.0:
; X64-SSE-NEXT:    movlhps {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; X64-SSE-NEXT:    retq
;
; X64-AVX-LABEL: test11:
; X64-AVX:       # %bb.0:
; X64-AVX-NEXT:    vmovlhps {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; X64-AVX-NEXT:    retq
	%tmp = insertelement <2 x double> undef, double %a, i32 0		; <<2 x double>> [#uses=1]
	%tmp7 = insertelement <2 x double> %tmp, double %b, i32 1		; <<2 x double>> [#uses=1]
	ret <2 x double> %tmp7
}

define void @test12() nounwind {
; SSE-LABEL: test12:
; SSE:       # %bb.0:
; SSE-NEXT:    movapd 0, %xmm0
; SSE-NEXT:    movapd {{.*#+}} xmm1 = [1.0E+0,1.0E+0,1.0E+0,1.0E+0]
; SSE-NEXT:    movsd {{.*#+}} xmm1 = xmm0[0],xmm1[1]
; SSE-NEXT:    xorps %xmm2, %xmm2
; SSE-NEXT:    movhlps {{.*#+}} xmm2 = xmm0[1],xmm2[1]
; SSE-NEXT:    addps %xmm1, %xmm2
; SSE-NEXT:    movaps %xmm2, 0
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX1-LABEL: test12:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vmovaps 0, %xmm0
; AVX1-NEXT:    vblendps {{.*#+}} xmm1 = xmm0[0,1],mem[2,3]
; AVX1-NEXT:    vxorps %xmm2, %xmm2, %xmm2
; AVX1-NEXT:    vunpckhpd {{.*#+}} xmm0 = xmm0[1],xmm2[1]
; AVX1-NEXT:    vaddps %xmm0, %xmm1, %xmm0
; AVX1-NEXT:    vmovaps %xmm0, 0
; AVX1-NEXT:    ret{{[l|q]}}
;
; AVX512-LABEL: test12:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vmovaps 0, %xmm0
; AVX512-NEXT:    vbroadcastss {{.*#+}} xmm1 = [1.0E+0,1.0E+0,1.0E+0,1.0E+0]
; AVX512-NEXT:    vblendps {{.*#+}} xmm1 = xmm0[0,1],xmm1[2,3]
; AVX512-NEXT:    vxorps %xmm2, %xmm2, %xmm2
; AVX512-NEXT:    vunpckhpd {{.*#+}} xmm0 = xmm0[1],xmm2[1]
; AVX512-NEXT:    vaddps %xmm0, %xmm1, %xmm0
; AVX512-NEXT:    vmovaps %xmm0, 0
; AVX512-NEXT:    ret{{[l|q]}}
  %tmp1 = load <4 x float>, <4 x float>* null          ; <<4 x float>> [#uses=2]
  %tmp2 = shufflevector <4 x float> %tmp1, <4 x float> < float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00 >, <4 x i32> < i32 0, i32 1, i32 6, i32 7 >             ; <<4 x float>> [#uses=1]
  %tmp3 = shufflevector <4 x float> %tmp1, <4 x float> zeroinitializer, <4 x i32> < i32 2, i32 3, i32 6, i32 7 >                ; <<4 x float>> [#uses=1]
  %tmp4 = fadd <4 x float> %tmp2, %tmp3            ; <<4 x float>> [#uses=1]
  store <4 x float> %tmp4, <4 x float>* null
  ret void
}

define void @test13(<4 x float>* %res, <4 x float>* %A, <4 x float>* %B, <4 x float>* %C) nounwind {
; X86-SSE-LABEL: test13:
; X86-SSE:       # %bb.0:
; X86-SSE-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-SSE-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-SSE-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-SSE-NEXT:    movaps (%edx), %xmm0
; X86-SSE-NEXT:    shufps {{.*#+}} xmm0 = xmm0[1,1],mem[0,1]
; X86-SSE-NEXT:    shufps {{.*#+}} xmm0 = xmm0[0,2,1,3]
; X86-SSE-NEXT:    movaps %xmm0, (%eax)
; X86-SSE-NEXT:    retl
;
; X86-AVX-LABEL: test13:
; X86-AVX:       # %bb.0:
; X86-AVX-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-AVX-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-AVX-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-AVX-NEXT:    vmovaps (%edx), %xmm0
; X86-AVX-NEXT:    vshufps {{.*#+}} xmm0 = xmm0[1,1],mem[0,1]
; X86-AVX-NEXT:    vpermilps {{.*#+}} xmm0 = xmm0[0,2,1,3]
; X86-AVX-NEXT:    vmovaps %xmm0, (%eax)
; X86-AVX-NEXT:    retl
;
; X64-SSE-LABEL: test13:
; X64-SSE:       # %bb.0:
; X64-SSE-NEXT:    movaps (%rdx), %xmm0
; X64-SSE-NEXT:    shufps {{.*#+}} xmm0 = xmm0[1,1],mem[0,1]
; X64-SSE-NEXT:    shufps {{.*#+}} xmm0 = xmm0[0,2,1,3]
; X64-SSE-NEXT:    movaps %xmm0, (%rdi)
; X64-SSE-NEXT:    retq
;
; X64-AVX-LABEL: test13:
; X64-AVX:       # %bb.0:
; X64-AVX-NEXT:    vmovaps (%rdx), %xmm0
; X64-AVX-NEXT:    vshufps {{.*#+}} xmm0 = xmm0[1,1],mem[0,1]
; X64-AVX-NEXT:    vpermilps {{.*#+}} xmm0 = xmm0[0,2,1,3]
; X64-AVX-NEXT:    vmovaps %xmm0, (%rdi)
; X64-AVX-NEXT:    retq
  %tmp3 = load <4 x float>, <4 x float>* %B            ; <<4 x float>> [#uses=1]
  %tmp5 = load <4 x float>, <4 x float>* %C            ; <<4 x float>> [#uses=1]
  %tmp11 = shufflevector <4 x float> %tmp3, <4 x float> %tmp5, <4 x i32> < i32 1, i32 4, i32 1, i32 5 >         ; <<4 x float>> [#uses=1]
  store <4 x float> %tmp11, <4 x float>* %res
  ret void
}

define <4 x float> @test14(<4 x float>* %x, <4 x float>* %y) nounwind {
; X86-SSE-LABEL: test14:
; X86-SSE:       # %bb.0:
; X86-SSE-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-SSE-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-SSE-NEXT:    movaps (%ecx), %xmm1
; X86-SSE-NEXT:    movaps (%eax), %xmm2
; X86-SSE-NEXT:    movaps %xmm2, %xmm0
; X86-SSE-NEXT:    addps %xmm1, %xmm0
; X86-SSE-NEXT:    subps %xmm1, %xmm2
; X86-SSE-NEXT:    movlhps {{.*#+}} xmm0 = xmm0[0],xmm2[0]
; X86-SSE-NEXT:    retl
;
; X86-AVX-LABEL: test14:
; X86-AVX:       # %bb.0:
; X86-AVX-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-AVX-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-AVX-NEXT:    vmovaps (%ecx), %xmm0
; X86-AVX-NEXT:    vmovaps (%eax), %xmm1
; X86-AVX-NEXT:    vaddps %xmm0, %xmm1, %xmm2
; X86-AVX-NEXT:    vsubps %xmm0, %xmm1, %xmm0
; X86-AVX-NEXT:    vmovlhps {{.*#+}} xmm0 = xmm2[0],xmm0[0]
; X86-AVX-NEXT:    retl
;
; X64-SSE-LABEL: test14:
; X64-SSE:       # %bb.0:
; X64-SSE-NEXT:    movaps (%rsi), %xmm1
; X64-SSE-NEXT:    movaps (%rdi), %xmm2
; X64-SSE-NEXT:    movaps %xmm2, %xmm0
; X64-SSE-NEXT:    addps %xmm1, %xmm0
; X64-SSE-NEXT:    subps %xmm1, %xmm2
; X64-SSE-NEXT:    movlhps {{.*#+}} xmm0 = xmm0[0],xmm2[0]
; X64-SSE-NEXT:    retq
;
; X64-AVX-LABEL: test14:
; X64-AVX:       # %bb.0:
; X64-AVX-NEXT:    vmovaps (%rsi), %xmm0
; X64-AVX-NEXT:    vmovaps (%rdi), %xmm1
; X64-AVX-NEXT:    vaddps %xmm0, %xmm1, %xmm2
; X64-AVX-NEXT:    vsubps %xmm0, %xmm1, %xmm0
; X64-AVX-NEXT:    vmovlhps {{.*#+}} xmm0 = xmm2[0],xmm0[0]
; X64-AVX-NEXT:    retq
  %tmp = load <4 x float>, <4 x float>* %y             ; <<4 x float>> [#uses=2]
  %tmp5 = load <4 x float>, <4 x float>* %x            ; <<4 x float>> [#uses=2]
  %tmp9 = fadd <4 x float> %tmp5, %tmp             ; <<4 x float>> [#uses=1]
  %tmp21 = fsub <4 x float> %tmp5, %tmp            ; <<4 x float>> [#uses=1]
  %tmp27 = shufflevector <4 x float> %tmp9, <4 x float> %tmp21, <4 x i32> < i32 0, i32 1, i32 4, i32 5 >                ; <<4 x float>> [#uses=1]
  ret <4 x float> %tmp27
}

define <4 x float> @test15(<4 x float>* %x, <4 x float>* %y) nounwind {
; X86-SSE-LABEL: test15:
; X86-SSE:       # %bb.0: # %entry
; X86-SSE-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-SSE-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-SSE-NEXT:    movaps (%ecx), %xmm0
; X86-SSE-NEXT:    unpckhpd {{.*#+}} xmm0 = xmm0[1],mem[1]
; X86-SSE-NEXT:    retl
;
; X86-AVX-LABEL: test15:
; X86-AVX:       # %bb.0: # %entry
; X86-AVX-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-AVX-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-AVX-NEXT:    vmovaps (%ecx), %xmm0
; X86-AVX-NEXT:    vunpckhpd {{.*#+}} xmm0 = xmm0[1],mem[1]
; X86-AVX-NEXT:    retl
;
; X64-SSE-LABEL: test15:
; X64-SSE:       # %bb.0: # %entry
; X64-SSE-NEXT:    movaps (%rdi), %xmm0
; X64-SSE-NEXT:    unpckhpd {{.*#+}} xmm0 = xmm0[1],mem[1]
; X64-SSE-NEXT:    retq
;
; X64-AVX-LABEL: test15:
; X64-AVX:       # %bb.0: # %entry
; X64-AVX-NEXT:    vmovaps (%rdi), %xmm0
; X64-AVX-NEXT:    vunpckhpd {{.*#+}} xmm0 = xmm0[1],mem[1]
; X64-AVX-NEXT:    retq
entry:
  %tmp = load <4 x float>, <4 x float>* %y             ; <<4 x float>> [#uses=1]
  %tmp3 = load <4 x float>, <4 x float>* %x            ; <<4 x float>> [#uses=1]
  %tmp4 = shufflevector <4 x float> %tmp3, <4 x float> %tmp, <4 x i32> < i32 2, i32 3, i32 6, i32 7 >           ; <<4 x float>> [#uses=1]
  ret <4 x float> %tmp4
}

; PR8900

define  <2 x double> @test16(<4 x double> * nocapture %srcA, <2 x double>* nocapture %dst) {
; X86-SSE-LABEL: test16:
; X86-SSE:       # %bb.0:
; X86-SSE-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-SSE-NEXT:    movaps 96(%eax), %xmm0
; X86-SSE-NEXT:    unpcklpd {{.*#+}} xmm0 = xmm0[0],mem[0]
; X86-SSE-NEXT:    retl
;
; X86-AVX-LABEL: test16:
; X86-AVX:       # %bb.0:
; X86-AVX-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-AVX-NEXT:    vmovaps 96(%eax), %xmm0
; X86-AVX-NEXT:    vunpcklpd {{.*#+}} xmm0 = xmm0[0],mem[0]
; X86-AVX-NEXT:    retl
;
; X64-SSE-LABEL: test16:
; X64-SSE:       # %bb.0:
; X64-SSE-NEXT:    movaps 96(%rdi), %xmm0
; X64-SSE-NEXT:    unpcklpd {{.*#+}} xmm0 = xmm0[0],mem[0]
; X64-SSE-NEXT:    retq
;
; X64-AVX-LABEL: test16:
; X64-AVX:       # %bb.0:
; X64-AVX-NEXT:    vmovaps 96(%rdi), %xmm0
; X64-AVX-NEXT:    vunpcklpd {{.*#+}} xmm0 = xmm0[0],mem[0]
; X64-AVX-NEXT:    retq
  %i5 = getelementptr inbounds <4 x double>, <4 x double>* %srcA, i32 3
  %i6 = load <4 x double>, <4 x double>* %i5, align 32
  %i7 = shufflevector <4 x double> %i6, <4 x double> undef, <2 x i32> <i32 0, i32 2>
  ret <2 x double> %i7
}

; PR9009
define fastcc void @test17() nounwind {
; X86-SSE-LABEL: test17:
; X86-SSE:       # %bb.0: # %entry
; X86-SSE-NEXT:    movaps {{.*#+}} xmm0 = <u,u,32768,32768>
; X86-SSE-NEXT:    movaps %xmm0, (%eax)
; X86-SSE-NEXT:    retl
;
; X86-AVX1-LABEL: test17:
; X86-AVX1:       # %bb.0: # %entry
; X86-AVX1-NEXT:    vmovaps {{.*#+}} xmm0 = <u,u,32768,32768>
; X86-AVX1-NEXT:    vmovaps %xmm0, (%eax)
; X86-AVX1-NEXT:    retl
;
; X86-AVX512-LABEL: test17:
; X86-AVX512:       # %bb.0: # %entry
; X86-AVX512-NEXT:    vbroadcastss {{.*#+}} xmm0 = [32768,32768,32768,32768]
; X86-AVX512-NEXT:    vmovaps %xmm0, (%eax)
; X86-AVX512-NEXT:    retl
;
; X64-SSE-LABEL: test17:
; X64-SSE:       # %bb.0: # %entry
; X64-SSE-NEXT:    movaps {{.*#+}} xmm0 = <u,u,32768,32768>
; X64-SSE-NEXT:    movaps %xmm0, (%rax)
; X64-SSE-NEXT:    retq
;
; X64-AVX1-LABEL: test17:
; X64-AVX1:       # %bb.0: # %entry
; X64-AVX1-NEXT:    vmovaps {{.*#+}} xmm0 = <u,u,32768,32768>
; X64-AVX1-NEXT:    vmovaps %xmm0, (%rax)
; X64-AVX1-NEXT:    retq
;
; X64-AVX512-LABEL: test17:
; X64-AVX512:       # %bb.0: # %entry
; X64-AVX512-NEXT:    vbroadcastss {{.*#+}} xmm0 = [32768,32768,32768,32768]
; X64-AVX512-NEXT:    vmovaps %xmm0, (%rax)
; X64-AVX512-NEXT:    retq
entry:
  %0 = insertelement <4 x i32> undef, i32 undef, i32 1
  %1 = shufflevector <4 x i32> <i32 undef, i32 undef, i32 32768, i32 32768>, <4 x i32> %0, <4 x i32> <i32 4, i32 5, i32 2, i32 3>
  %2 = bitcast <4 x i32> %1 to <4 x float>
  store <4 x float> %2, <4 x float> * undef
  ret void
}

; PR9210
define <4 x float> @f(<4 x double>) nounwind {
; SSE-LABEL: f:
; SSE:       # %bb.0: # %entry
; SSE-NEXT:    cvtpd2ps %xmm1, %xmm1
; SSE-NEXT:    cvtpd2ps %xmm0, %xmm0
; SSE-NEXT:    unpcklpd {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: f:
; AVX:       # %bb.0: # %entry
; AVX-NEXT:    vcvtpd2ps %ymm0, %xmm0
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    ret{{[l|q]}}
entry:
 %double2float.i = fptrunc <4 x double> %0 to <4 x float>
 ret <4 x float> %double2float.i
}

define <2 x i64> @test_insert_64_zext(<2 x i64> %i) {
; SSE-LABEL: test_insert_64_zext:
; SSE:       # %bb.0:
; SSE-NEXT:    movq {{.*#+}} xmm0 = xmm0[0],zero
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_insert_64_zext:
; AVX:       # %bb.0:
; AVX-NEXT:    vmovq {{.*#+}} xmm0 = xmm0[0],zero
; AVX-NEXT:    ret{{[l|q]}}
  %1 = shufflevector <2 x i64> %i, <2 x i64> <i64 0, i64 undef>, <2 x i32> <i32 0, i32 2>
  ret <2 x i64> %1
}

define <4 x i32> @PR19721(<4 x i32> %i) {
; X86-SSE-LABEL: PR19721:
; X86-SSE:       # %bb.0:
; X86-SSE-NEXT:    andps {{\.LCPI.*}}, %xmm0
; X86-SSE-NEXT:    retl
;
; X86-AVX-LABEL: PR19721:
; X86-AVX:       # %bb.0:
; X86-AVX-NEXT:    vxorps %xmm1, %xmm1, %xmm1
; X86-AVX-NEXT:    vblendps {{.*#+}} xmm0 = xmm1[0],xmm0[1,2,3]
; X86-AVX-NEXT:    retl
;
; X64-SSE-LABEL: PR19721:
; X64-SSE:       # %bb.0:
; X64-SSE-NEXT:    movq %xmm0, %rax
; X64-SSE-NEXT:    movabsq $-4294967296, %rcx # imm = 0xFFFFFFFF00000000
; X64-SSE-NEXT:    andq %rax, %rcx
; X64-SSE-NEXT:    movq %rcx, %xmm1
; X64-SSE-NEXT:    movsd {{.*#+}} xmm0 = xmm1[0],xmm0[1]
; X64-SSE-NEXT:    retq
;
; X64-AVX1-LABEL: PR19721:
; X64-AVX1:       # %bb.0:
; X64-AVX1-NEXT:    vmovq %xmm0, %rax
; X64-AVX1-NEXT:    movabsq $-4294967296, %rcx # imm = 0xFFFFFFFF00000000
; X64-AVX1-NEXT:    andq %rax, %rcx
; X64-AVX1-NEXT:    vmovq %rcx, %xmm1
; X64-AVX1-NEXT:    vpblendw {{.*#+}} xmm0 = xmm1[0,1,2,3],xmm0[4,5,6,7]
; X64-AVX1-NEXT:    retq
;
; X64-AVX512-LABEL: PR19721:
; X64-AVX512:       # %bb.0:
; X64-AVX512-NEXT:    vmovq %xmm0, %rax
; X64-AVX512-NEXT:    movabsq $-4294967296, %rcx # imm = 0xFFFFFFFF00000000
; X64-AVX512-NEXT:    andq %rax, %rcx
; X64-AVX512-NEXT:    vmovq %rcx, %xmm1
; X64-AVX512-NEXT:    vpblendd {{.*#+}} xmm0 = xmm1[0,1],xmm0[2,3]
; X64-AVX512-NEXT:    retq
  %bc = bitcast <4 x i32> %i to i128
  %insert = and i128 %bc, -4294967296
  %bc2 = bitcast i128 %insert to <4 x i32>
  ret <4 x i32> %bc2
}

define <4 x i32> @test_mul(<4 x i32> %x, <4 x i32> %y) {
; SSE-LABEL: test_mul:
; SSE:       # %bb.0:
; SSE-NEXT:    pshufd {{.*#+}} xmm2 = xmm0[1,1,3,3]
; SSE-NEXT:    pmuludq %xmm1, %xmm0
; SSE-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,2,2,3]
; SSE-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[1,1,3,3]
; SSE-NEXT:    pmuludq %xmm2, %xmm1
; SSE-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[0,2,2,3]
; SSE-NEXT:    punpckldq {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1]
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mul:
; AVX:       # %bb.0:
; AVX-NEXT:    vpmulld %xmm1, %xmm0, %xmm0
; AVX-NEXT:    ret{{[l|q]}}
  %m = mul <4 x i32> %x, %y
  ret <4 x i32> %m
}
