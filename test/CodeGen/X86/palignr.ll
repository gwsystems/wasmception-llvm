; RUN: llc < %s -march=x86 -mcpu=core2 -mattr=+ssse3 | FileCheck %s
; RUN: llc < %s -march=x86 -mcpu=yonah | FileCheck --check-prefix=CHECK-YONAH %s

define <4 x i32> @test1(<4 x i32> %A, <4 x i32> %B) nounwind {
; CHECK-LABEL: test1:
; CHECK:       # BB#0:
; CHECK-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[1,2,3,0]
; CHECK-NEXT:    retl
;
; CHECK-YONAH-LABEL: test1:
; CHECK-YONAH:       # BB#0:
; CHECK-YONAH-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[1,2,3,0]
; CHECK-YONAH-NEXT:    retl
  %C = shufflevector <4 x i32> %A, <4 x i32> undef, <4 x i32> < i32 1, i32 2, i32 3, i32 0 >
	ret <4 x i32> %C
}

define <4 x i32> @test2(<4 x i32> %A, <4 x i32> %B) nounwind {
; CHECK-LABEL: test2:
; CHECK:       # BB#0:
; CHECK-NEXT:    palignr {{.*#+}} xmm1 = xmm0[4,5,6,7,8,9,10,11,12,13,14,15],xmm1[0,1,2,3]
; CHECK-NEXT:    movdqa %xmm1, %xmm0
; CHECK-NEXT:    retl
;
; CHECK-YONAH-LABEL: test2:
; CHECK-YONAH:       # BB#0:
; CHECK-YONAH-NEXT:    shufps {{.*#+}} xmm1 = xmm1[0,0],xmm0[3,0]
; CHECK-YONAH-NEXT:    shufps {{.*#+}} xmm0 = xmm0[1,2],xmm1[2,0]
; CHECK-YONAH-NEXT:    retl
  %C = shufflevector <4 x i32> %A, <4 x i32> %B, <4 x i32> < i32 1, i32 2, i32 3, i32 4 >
	ret <4 x i32> %C
}

define <4 x i32> @test3(<4 x i32> %A, <4 x i32> %B) nounwind {
; CHECK-LABEL: test3:
; CHECK:       # BB#0:
; CHECK-NEXT:    palignr {{.*#+}} xmm1 = xmm0[4,5,6,7,8,9,10,11,12,13,14,15],xmm1[0,1,2,3]
; CHECK-NEXT:    movdqa %xmm1, %xmm0
; CHECK-NEXT:    retl
;
; CHECK-YONAH-LABEL: test3:
; CHECK-YONAH:       # BB#0:
; CHECK-YONAH-NEXT:    shufps {{.*#+}} xmm0 = xmm0[1,2],xmm1[0,0]
; CHECK-YONAH-NEXT:    retl
  %C = shufflevector <4 x i32> %A, <4 x i32> %B, <4 x i32> < i32 1, i32 2, i32 undef, i32 4 >
	ret <4 x i32> %C
}

define <4 x i32> @test4(<4 x i32> %A, <4 x i32> %B) nounwind {
; CHECK-LABEL: test4:
; CHECK:       # BB#0:
; CHECK-NEXT:    palignr {{.*#+}} xmm0 = xmm1[8,9,10,11,12,13,14,15],xmm0[0,1,2,3,4,5,6,7]
; CHECK-NEXT:    retl
;
; CHECK-YONAH-LABEL: test4:
; CHECK-YONAH:       # BB#0:
; CHECK-YONAH-NEXT:    shufps {{.*#+}} xmm1 = xmm1[2,3],xmm0[0,1]
; CHECK-YONAH-NEXT:    movaps %xmm1, %xmm0
; CHECK-YONAH-NEXT:    retl
  %C = shufflevector <4 x i32> %A, <4 x i32> %B, <4 x i32> < i32 6, i32 7, i32 undef, i32 1 >
	ret <4 x i32> %C
}

define <4 x float> @test5(<4 x float> %A, <4 x float> %B) nounwind {
; CHECK-LABEL: test5:
; CHECK:       # BB#0:
; CHECK-NEXT:    palignr {{.*#+}} xmm0 = xmm1[8,9,10,11,12,13,14,15],xmm0[0,1,2,3,4,5,6,7]
; CHECK-NEXT:    retl
;
; CHECK-YONAH-LABEL: test5:
; CHECK-YONAH:       # BB#0:
; CHECK-YONAH-NEXT:    shufps {{.*#+}} xmm1 = xmm1[2,3],xmm0[0,1]
; CHECK-YONAH-NEXT:    movaps %xmm1, %xmm0
; CHECK-YONAH-NEXT:    retl
  %C = shufflevector <4 x float> %A, <4 x float> %B, <4 x i32> < i32 6, i32 7, i32 undef, i32 1 >
	ret <4 x float> %C
}

define <8 x i16> @test6(<8 x i16> %A, <8 x i16> %B) nounwind {
; CHECK-LABEL: test6:
; CHECK:       # BB#0:
; CHECK-NEXT:    palignr {{.*#+}} xmm1 = xmm0[6,7,8,9,10,11,12,13,14,15],xmm1[0,1,2,3,4,5]
; CHECK-NEXT:    movdqa %xmm1, %xmm0
; CHECK-NEXT:    retl
;
; CHECK-YONAH-LABEL: test6:
; CHECK-YONAH:       # BB#0:
; CHECK-YONAH-NEXT:    movapd %xmm0, %xmm2
; CHECK-YONAH-NEXT:    shufpd {{.*#+}} xmm2 = xmm2[1],xmm1[0]
; CHECK-YONAH-NEXT:    pshuflw {{.*#+}} xmm1 = xmm2[0,0,0,2,4,5,6,7]
; CHECK-YONAH-NEXT:    pshufhw {{.*#+}} xmm1 = xmm1[0,1,2,3,4,4,5,6]
; CHECK-YONAH-NEXT:    pextrw $3, %xmm0, %eax
; CHECK-YONAH-NEXT:    pinsrw $0, %eax, %xmm1
; CHECK-YONAH-NEXT:    pextrw $7, %xmm0, %eax
; CHECK-YONAH-NEXT:    pinsrw $4, %eax, %xmm1
; CHECK-YONAH-NEXT:    movdqa %xmm1, %xmm0
; CHECK-YONAH-NEXT:    retl
  %C = shufflevector <8 x i16> %A, <8 x i16> %B, <8 x i32> < i32 3, i32 4, i32 undef, i32 6, i32 7, i32 8, i32 9, i32 10 >
	ret <8 x i16> %C
}

define <8 x i16> @test7(<8 x i16> %A, <8 x i16> %B) nounwind {
; CHECK-LABEL: test7:
; CHECK:       # BB#0:
; CHECK-NEXT:    palignr {{.*#+}} xmm1 = xmm0[10,11,12,13,14,15],xmm1[0,1,2,3,4,5,6,7,8,9]
; CHECK-NEXT:    movdqa %xmm1, %xmm0
; CHECK-NEXT:    retl
;
; CHECK-YONAH-LABEL: test7:
; CHECK-YONAH:       # BB#0:
; CHECK-YONAH-NEXT:    shufpd {{.*#+}} xmm0 = xmm0[1],xmm1[0]
; CHECK-YONAH-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[0,2,0,0,4,5,6,7]
; CHECK-YONAH-NEXT:    pshufhw {{.*#+}} xmm0 = xmm0[0,1,2,3,5,6,7,4]
; CHECK-YONAH-NEXT:    movd %xmm1, %eax
; CHECK-YONAH-NEXT:    pinsrw $3, %eax, %xmm0
; CHECK-YONAH-NEXT:    pextrw $4, %xmm1, %eax
; CHECK-YONAH-NEXT:    pinsrw $7, %eax, %xmm0
; CHECK-YONAH-NEXT:    retl
  %C = shufflevector <8 x i16> %A, <8 x i16> %B, <8 x i32> < i32 undef, i32 6, i32 undef, i32 8, i32 9, i32 10, i32 11, i32 12 >
	ret <8 x i16> %C
}

define <16 x i8> @test8(<16 x i8> %A, <16 x i8> %B) nounwind {
; CHECK-LABEL: test8:
; CHECK:       # BB#0:
; CHECK-NEXT:    palignr {{.*#+}} xmm1 = xmm0[5,6,7,8,9,10,11,12,13,14,15],xmm1[0,1,2,3,4]
; CHECK-NEXT:    movdqa %xmm1, %xmm0
; CHECK-NEXT:    retl
;
; CHECK-YONAH-LABEL: test8:
; CHECK-YONAH:       # BB#0:
; CHECK-YONAH-NEXT:    pushl %esi
; CHECK-YONAH-NEXT:    movdqa %xmm0, %xmm2
; CHECK-YONAH-NEXT:    pextrw $4, %xmm2, %eax
; CHECK-YONAH-NEXT:    pextrw $5, %xmm2, %ecx
; CHECK-YONAH-NEXT:    shrdw $8, %cx, %ax
; CHECK-YONAH-NEXT:    pextrw $2, %xmm2, %edx
; CHECK-YONAH-NEXT:    pextrw $3, %xmm2, %esi
; CHECK-YONAH-NEXT:    shrdw $8, %si, %dx
; CHECK-YONAH-NEXT:   # kill: XMM0<def> XMM2<kill>
; CHECK-YONAH-NEXT:    pinsrw $0, %edx, %xmm0
; CHECK-YONAH-NEXT:    shrl $8, %esi
; CHECK-YONAH-NEXT:    pinsrw $1, %esi, %xmm0
; CHECK-YONAH-NEXT:    pinsrw $2, %eax, %xmm0
; CHECK-YONAH-NEXT:    pextrw $6, %xmm2, %eax
; CHECK-YONAH-NEXT:    shrdw $8, %ax, %cx
; CHECK-YONAH-NEXT:    pinsrw $3, %ecx, %xmm0
; CHECK-YONAH-NEXT:    pextrw $7, %xmm2, %ecx
; CHECK-YONAH-NEXT:    shrdw $8, %cx, %ax
; CHECK-YONAH-NEXT:    pinsrw $4, %eax, %xmm0
; CHECK-YONAH-NEXT:    pextrw $8, %xmm1, %eax
; CHECK-YONAH-NEXT:    shrdw $8, %ax, %cx
; CHECK-YONAH-NEXT:    pinsrw $5, %ecx, %xmm0
; CHECK-YONAH-NEXT:    pextrw $9, %xmm1, %ecx
; CHECK-YONAH-NEXT:    shrdw $8, %cx, %ax
; CHECK-YONAH-NEXT:    pinsrw $6, %eax, %xmm0
; CHECK-YONAH-NEXT:    pextrw $10, %xmm1, %eax
; CHECK-YONAH-NEXT:    shldw $8, %cx, %ax
; CHECK-YONAH-NEXT:    pinsrw $7, %eax, %xmm0
; CHECK-YONAH-NEXT:    popl %esi
; CHECK-YONAH-NEXT:    retl
  %C = shufflevector <16 x i8> %A, <16 x i8> %B, <16 x i32> < i32 5, i32 6, i32 7, i32 undef, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 16, i32 17, i32 18, i32 19, i32 20 >
	ret <16 x i8> %C
}

; Check that we don't do unary (circular on single operand) palignr incorrectly.
; (It is possible, but before this testcase was committed, it was being done
; incorrectly.  In particular, one of the operands of the palignr node
; was an UNDEF.)
define <8 x i16> @test9(<8 x i16> %A, <8 x i16> %B) nounwind {
; CHECK-LABEL: test9:
; CHECK:       # BB#0:
; CHECK-NEXT:    pshufb {{.*#+}} xmm1 = zero,zero,xmm1[4,5,6,7,8,9,10,11,12,13,14,15,0,1]
; CHECK-NEXT:    movdqa %xmm1, %xmm0
; CHECK-NEXT:    retl
;
; CHECK-YONAH-LABEL: test9:
; CHECK-YONAH:       # BB#0:
; CHECK-YONAH-NEXT:    pextrw $4, %xmm1, %eax
; CHECK-YONAH-NEXT:    pshuflw {{.*#+}} xmm0 = xmm1[0,2,3,0,4,5,6,7]
; CHECK-YONAH-NEXT:    pshufhw {{.*#+}} xmm0 = xmm0[0,1,2,3,5,6,7,4]
; CHECK-YONAH-NEXT:    pinsrw $3, %eax, %xmm0
; CHECK-YONAH-NEXT:    movd %xmm1, %eax
; CHECK-YONAH-NEXT:    pinsrw $7, %eax, %xmm0
; CHECK-YONAH-NEXT:    retl
  %C = shufflevector <8 x i16> %B, <8 x i16> %A, <8 x i32> < i32 undef, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 0 >
	ret <8 x i16> %C
}

