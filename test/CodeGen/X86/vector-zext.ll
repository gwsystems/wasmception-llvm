; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mcpu=x86-64 -mattr=+sse2 | FileCheck %s --check-prefix=SSE --check-prefix=SSE2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mcpu=x86-64 -mattr=+ssse3 | FileCheck %s --check-prefix=SSE --check-prefix=SSSE3
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mcpu=x86-64 -mattr=+sse4.1 | FileCheck %s --check-prefix=SSE --check-prefix=SSE41
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mcpu=x86-64 -mattr=+avx | FileCheck %s --check-prefix=AVX --check-prefix=AVX1
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mcpu=x86-64 -mattr=+avx2 | FileCheck %s --check-prefix=AVX --check-prefix=AVX2

define <8 x i16> @zext_16i8_to_8i16(<16 x i8> %A) nounwind uwtable readnone ssp {
; SSE2-LABEL: zext_16i8_to_8i16:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    pxor %xmm1, %xmm1
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3],xmm0[4],xmm1[4],xmm0[5],xmm1[5],xmm0[6],xmm1[6],xmm0[7],xmm1[7]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: zext_16i8_to_8i16:
; SSSE3:       # BB#0: # %entry
; SSSE3-NEXT:    pxor %xmm1, %xmm1
; SSSE3-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3],xmm0[4],xmm1[4],xmm0[5],xmm1[5],xmm0[6],xmm1[6],xmm0[7],xmm1[7]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: zext_16i8_to_8i16:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    pmovzxbw {{.*#+}} xmm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero,xmm0[4],zero,xmm0[5],zero,xmm0[6],zero,xmm0[7],zero
; SSE41-NEXT:    retq
;
; AVX-LABEL: zext_16i8_to_8i16:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpmovzxbw {{.*#+}} xmm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero,xmm0[4],zero,xmm0[5],zero,xmm0[6],zero,xmm0[7],zero
; AVX-NEXT:    retq
entry:
  %B = shufflevector <16 x i8> %A, <16 x i8> undef, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %C = zext <8 x i8> %B to <8 x i16>
  ret <8 x i16> %C
}

; PR17654
define <16 x i16> @zext_16i8_to_16i16(<16 x i8> %A) {
; SSE2-LABEL: zext_16i8_to_16i16:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm0, %xmm1
; SSE2-NEXT:    pxor %xmm2, %xmm2
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1],xmm0[2],xmm2[2],xmm0[3],xmm2[3],xmm0[4],xmm2[4],xmm0[5],xmm2[5],xmm0[6],xmm2[6],xmm0[7],xmm2[7]
; SSE2-NEXT:    punpckhbw {{.*#+}} xmm1 = xmm1[8],xmm2[8],xmm1[9],xmm2[9],xmm1[10],xmm2[10],xmm1[11],xmm2[11],xmm1[12],xmm2[12],xmm1[13],xmm2[13],xmm1[14],xmm2[14],xmm1[15],xmm2[15]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: zext_16i8_to_16i16:
; SSSE3:       # BB#0: # %entry
; SSSE3-NEXT:    movdqa %xmm0, %xmm1
; SSSE3-NEXT:    pxor %xmm2, %xmm2
; SSSE3-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1],xmm0[2],xmm2[2],xmm0[3],xmm2[3],xmm0[4],xmm2[4],xmm0[5],xmm2[5],xmm0[6],xmm2[6],xmm0[7],xmm2[7]
; SSSE3-NEXT:    punpckhbw {{.*#+}} xmm1 = xmm1[8],xmm2[8],xmm1[9],xmm2[9],xmm1[10],xmm2[10],xmm1[11],xmm2[11],xmm1[12],xmm2[12],xmm1[13],xmm2[13],xmm1[14],xmm2[14],xmm1[15],xmm2[15]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: zext_16i8_to_16i16:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    movdqa %xmm0, %xmm1
; SSE41-NEXT:    pxor %xmm2, %xmm2
; SSE41-NEXT:    pmovzxbw {{.*#+}} xmm0 = xmm1[0],zero,xmm1[1],zero,xmm1[2],zero,xmm1[3],zero,xmm1[4],zero,xmm1[5],zero,xmm1[6],zero,xmm1[7],zero
; SSE41-NEXT:    punpckhbw {{.*#+}} xmm1 = xmm1[8],xmm2[8],xmm1[9],xmm2[9],xmm1[10],xmm2[10],xmm1[11],xmm2[11],xmm1[12],xmm2[12],xmm1[13],xmm2[13],xmm1[14],xmm2[14],xmm1[15],xmm2[15]
; SSE41-NEXT:    retq
;
; AVX1-LABEL: zext_16i8_to_16i16:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX1-NEXT:    vpunpckhbw {{.*#+}} xmm1 = xmm0[8],xmm1[8],xmm0[9],xmm1[9],xmm0[10],xmm1[10],xmm0[11],xmm1[11],xmm0[12],xmm1[12],xmm0[13],xmm1[13],xmm0[14],xmm1[14],xmm0[15],xmm1[15]
; AVX1-NEXT:    vpmovzxbw {{.*#+}} xmm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero,xmm0[4],zero,xmm0[5],zero,xmm0[6],zero,xmm0[7],zero
; AVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: zext_16i8_to_16i16:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmovzxbw {{.*#+}} ymm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero,xmm0[4],zero,xmm0[5],zero,xmm0[6],zero,xmm0[7],zero,xmm0[8],zero,xmm0[9],zero,xmm0[10],zero,xmm0[11],zero,xmm0[12],zero,xmm0[13],zero,xmm0[14],zero,xmm0[15],zero
; AVX2-NEXT:    retq
entry:
  %B = zext <16 x i8> %A to <16 x i16>
  ret <16 x i16> %B
}

define <4 x i32> @zext_16i8_to_4i32(<16 x i8> %A) nounwind uwtable readnone ssp {
; SSE2-LABEL: zext_16i8_to_4i32:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    pxor %xmm1, %xmm1
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3],xmm0[4],xmm1[4],xmm0[5],xmm1[5],xmm0[6],xmm1[6],xmm0[7],xmm1[7]
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: zext_16i8_to_4i32:
; SSSE3:       # BB#0: # %entry
; SSSE3-NEXT:    pxor %xmm1, %xmm1
; SSSE3-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3],xmm0[4],xmm1[4],xmm0[5],xmm1[5],xmm0[6],xmm1[6],xmm0[7],xmm1[7]
; SSSE3-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: zext_16i8_to_4i32:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    pmovzxbd {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,xmm0[1],zero,zero,zero,xmm0[2],zero,zero,zero,xmm0[3],zero,zero,zero
; SSE41-NEXT:    retq
;
; AVX-LABEL: zext_16i8_to_4i32:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpmovzxbd {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,xmm0[1],zero,zero,zero,xmm0[2],zero,zero,zero,xmm0[3],zero,zero,zero
; AVX-NEXT:    retq
entry:
  %B = shufflevector <16 x i8> %A, <16 x i8> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %C = zext <4 x i8> %B to <4 x i32>
  ret <4 x i32> %C
}

define <8 x i32> @zext_16i8_to_8i32(<16 x i8> %A) nounwind uwtable readnone ssp {
; SSE2-LABEL: zext_16i8_to_8i32:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm0, %xmm1
; SSE2-NEXT:    pxor %xmm2, %xmm2
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1],xmm1[2],xmm2[2],xmm1[3],xmm2[3],xmm1[4],xmm2[4],xmm1[5],xmm2[5],xmm1[6],xmm2[6],xmm1[7],xmm2[7]
; SSE2-NEXT:    movdqa %xmm1, %xmm0
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1],xmm0[2],xmm2[2],xmm0[3],xmm2[3]
; SSE2-NEXT:    punpckhwd {{.*#+}} xmm1 = xmm1[4],xmm2[4],xmm1[5],xmm2[5],xmm1[6],xmm2[6],xmm1[7],xmm2[7]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: zext_16i8_to_8i32:
; SSSE3:       # BB#0: # %entry
; SSSE3-NEXT:    movdqa %xmm0, %xmm1
; SSSE3-NEXT:    pxor %xmm2, %xmm2
; SSSE3-NEXT:    punpcklbw {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1],xmm1[2],xmm2[2],xmm1[3],xmm2[3],xmm1[4],xmm2[4],xmm1[5],xmm2[5],xmm1[6],xmm2[6],xmm1[7],xmm2[7]
; SSSE3-NEXT:    movdqa %xmm1, %xmm0
; SSSE3-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1],xmm0[2],xmm2[2],xmm0[3],xmm2[3]
; SSSE3-NEXT:    punpckhwd {{.*#+}} xmm1 = xmm1[4],xmm2[4],xmm1[5],xmm2[5],xmm1[6],xmm2[6],xmm1[7],xmm2[7]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: zext_16i8_to_8i32:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    pmovzxbd {{.*#+}} xmm2 = xmm0[0],zero,zero,zero,xmm0[1],zero,zero,zero,xmm0[2],zero,zero,zero,xmm0[3],zero,zero,zero
; SSE41-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[1,1,2,3]
; SSE41-NEXT:    pmovzxbd {{.*#+}} xmm1 = xmm0[0],zero,zero,zero,xmm0[1],zero,zero,zero,xmm0[2],zero,zero,zero,xmm0[3],zero,zero,zero
; SSE41-NEXT:    movdqa %xmm2, %xmm0
; SSE41-NEXT:    retq
;
; AVX1-LABEL: zext_16i8_to_8i32:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vpmovzxbw {{.*#+}} xmm1 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero,xmm0[4],zero,xmm0[5],zero,xmm0[6],zero,xmm0[7],zero
; AVX1-NEXT:    vpunpckhwd {{.*#+}} xmm1 = xmm1[4,4,5,5,6,6,7,7]
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm2 = [255,0,0,0,255,0,0,0,255,0,0,0,255,0,0,0]
; AVX1-NEXT:    vpand %xmm2, %xmm1, %xmm1
; AVX1-NEXT:    vpmovzxbd {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,xmm0[1],zero,zero,zero,xmm0[2],zero,zero,zero,xmm0[3],zero,zero,zero
; AVX1-NEXT:    vpand %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: zext_16i8_to_8i32:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmovzxbd {{.*#+}} ymm0 = xmm0[0],zero,zero,zero,xmm0[1],zero,zero,zero,xmm0[2],zero,zero,zero,xmm0[3],zero,zero,zero,xmm0[4],zero,zero,zero,xmm0[5],zero,zero,zero,xmm0[6],zero,zero,zero,xmm0[7],zero,zero,zero
; AVX2-NEXT:    vpand {{.*}}(%rip), %ymm0, %ymm0
; AVX2-NEXT:    retq
entry:
  %B = shufflevector <16 x i8> %A, <16 x i8> undef, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %C = zext <8 x i8> %B to <8 x i32>
  ret <8 x i32> %C
}

define <2 x i64> @zext_16i8_to_2i64(<16 x i8> %A) nounwind uwtable readnone ssp {
; SSE2-LABEL: zext_16i8_to_2i64:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    pxor %xmm1, %xmm1
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3],xmm0[4],xmm1[4],xmm0[5],xmm1[5],xmm0[6],xmm1[6],xmm0[7],xmm1[7]
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3]
; SSE2-NEXT:    punpckldq {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: zext_16i8_to_2i64:
; SSSE3:       # BB#0: # %entry
; SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,zero,zero,zero,zero,xmm0[1],zero,zero,zero,zero,zero,zero,zero
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: zext_16i8_to_2i64:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    pmovzxbq {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,zero,zero,zero,zero,xmm0[1],zero,zero,zero,zero,zero,zero,zero
; SSE41-NEXT:    retq
;
; AVX-LABEL: zext_16i8_to_2i64:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpmovzxbq {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,zero,zero,zero,zero,xmm0[1],zero,zero,zero,zero,zero,zero,zero
; AVX-NEXT:    retq
entry:
  %B = shufflevector <16 x i8> %A, <16 x i8> undef, <2 x i32> <i32 0, i32 1>
  %C = zext <2 x i8> %B to <2 x i64>
  ret <2 x i64> %C
}

define <4 x i64> @zext_16i8_to_4i64(<16 x i8> %A) nounwind uwtable readnone ssp {
; SSE2-LABEL: zext_16i8_to_4i64:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm0, %xmm1
; SSE2-NEXT:    pxor %xmm2, %xmm2
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1],xmm1[2],xmm2[2],xmm1[3],xmm2[3],xmm1[4],xmm2[4],xmm1[5],xmm2[5],xmm1[6],xmm2[6],xmm1[7],xmm2[7]
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1],xmm1[2],xmm2[2],xmm1[3],xmm2[3]
; SSE2-NEXT:    movdqa %xmm1, %xmm0
; SSE2-NEXT:    punpckldq {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1]
; SSE2-NEXT:    punpckhdq {{.*#+}} xmm1 = xmm1[2],xmm2[2],xmm1[3],xmm2[3]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: zext_16i8_to_4i64:
; SSSE3:       # BB#0: # %entry
; SSSE3-NEXT:    movdqa %xmm0, %xmm1
; SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,zero,zero,zero,zero,xmm0[1],zero,zero,zero,zero,zero,zero,zero
; SSSE3-NEXT:    pshufb {{.*#+}} xmm1 = xmm1[2],zero,zero,zero,zero,zero,zero,zero,xmm1[3],zero,zero,zero,zero,zero,zero,zero
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: zext_16i8_to_4i64:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    pmovzxbq {{.*#+}} xmm2 = xmm0[0],zero,zero,zero,zero,zero,zero,zero,xmm0[1],zero,zero,zero,zero,zero,zero,zero
; SSE41-NEXT:    psrld $16, %xmm0
; SSE41-NEXT:    pmovzxbq {{.*#+}} xmm1 = xmm0[0],zero,zero,zero,zero,zero,zero,zero,xmm0[1],zero,zero,zero,zero,zero,zero,zero
; SSE41-NEXT:    movdqa %xmm2, %xmm0
; SSE41-NEXT:    retq
;
; AVX1-LABEL: zext_16i8_to_4i64:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vpmovzxbd {{.*#+}} xmm1 = xmm0[0],zero,zero,zero,xmm0[1],zero,zero,zero,xmm0[2],zero,zero,zero,xmm0[3],zero,zero,zero
; AVX1-NEXT:    vpshufd {{.*#+}} xmm1 = xmm1[2,2,3,3]
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm2 = [255,0,0,0,0,0,0,0,255,0,0,0,0,0,0,0]
; AVX1-NEXT:    vpand %xmm2, %xmm1, %xmm1
; AVX1-NEXT:    vpmovzxbq {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,zero,zero,zero,zero,xmm0[1],zero,zero,zero,zero,zero,zero,zero
; AVX1-NEXT:    vpand %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: zext_16i8_to_4i64:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmovzxbq {{.*#+}} ymm0 = xmm0[0],zero,zero,zero,zero,zero,zero,zero,xmm0[1],zero,zero,zero,zero,zero,zero,zero,xmm0[2],zero,zero,zero,zero,zero,zero,zero,xmm0[3],zero,zero,zero,zero,zero,zero,zero
; AVX2-NEXT:    vpand {{.*}}(%rip), %ymm0, %ymm0
; AVX2-NEXT:    retq
entry:
  %B = shufflevector <16 x i8> %A, <16 x i8> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %C = zext <4 x i8> %B to <4 x i64>
  ret <4 x i64> %C
}

define <4 x i32> @zext_8i16_to_4i32(<8 x i16> %A) nounwind uwtable readnone ssp {
; SSE2-LABEL: zext_8i16_to_4i32:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    pxor %xmm1, %xmm1
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: zext_8i16_to_4i32:
; SSSE3:       # BB#0: # %entry
; SSSE3-NEXT:    pxor %xmm1, %xmm1
; SSSE3-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: zext_8i16_to_4i32:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    pmovzxwd {{.*#+}} xmm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero
; SSE41-NEXT:    retq
;
; AVX-LABEL: zext_8i16_to_4i32:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpmovzxwd {{.*#+}} xmm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero
; AVX-NEXT:    retq
entry:
  %B = shufflevector <8 x i16> %A, <8 x i16> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %C = zext <4 x i16> %B to <4 x i32>
  ret <4 x i32> %C
}

define <8 x i32> @zext_8i16_to_8i32(<8 x i16> %A) nounwind uwtable readnone ssp {
; SSE2-LABEL: zext_8i16_to_8i32:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm0, %xmm1
; SSE2-NEXT:    pxor %xmm2, %xmm2
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1],xmm0[2],xmm2[2],xmm0[3],xmm2[3]
; SSE2-NEXT:    punpckhwd {{.*#+}} xmm1 = xmm1[4],xmm2[4],xmm1[5],xmm2[5],xmm1[6],xmm2[6],xmm1[7],xmm2[7]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: zext_8i16_to_8i32:
; SSSE3:       # BB#0: # %entry
; SSSE3-NEXT:    movdqa %xmm0, %xmm1
; SSSE3-NEXT:    pxor %xmm2, %xmm2
; SSSE3-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1],xmm0[2],xmm2[2],xmm0[3],xmm2[3]
; SSSE3-NEXT:    punpckhwd {{.*#+}} xmm1 = xmm1[4],xmm2[4],xmm1[5],xmm2[5],xmm1[6],xmm2[6],xmm1[7],xmm2[7]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: zext_8i16_to_8i32:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    movdqa %xmm0, %xmm1
; SSE41-NEXT:    pxor %xmm2, %xmm2
; SSE41-NEXT:    pmovzxwd {{.*#+}} xmm0 = xmm1[0],zero,xmm1[1],zero,xmm1[2],zero,xmm1[3],zero
; SSE41-NEXT:    punpckhwd {{.*#+}} xmm1 = xmm1[4],xmm2[4],xmm1[5],xmm2[5],xmm1[6],xmm2[6],xmm1[7],xmm2[7]
; SSE41-NEXT:    retq
;
; AVX1-LABEL: zext_8i16_to_8i32:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX1-NEXT:    vpunpckhwd {{.*#+}} xmm1 = xmm0[4],xmm1[4],xmm0[5],xmm1[5],xmm0[6],xmm1[6],xmm0[7],xmm1[7]
; AVX1-NEXT:    vpmovzxwd {{.*#+}} xmm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero
; AVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: zext_8i16_to_8i32:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmovzxwd {{.*#+}} ymm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero,xmm0[4],zero,xmm0[5],zero,xmm0[6],zero,xmm0[7],zero
; AVX2-NEXT:    retq
entry:
  %B = zext <8 x i16> %A to <8 x i32>
  ret <8 x i32>%B
}

define <2 x i64> @zext_8i16_to_2i64(<8 x i16> %A) nounwind uwtable readnone ssp {
; SSE2-LABEL: zext_8i16_to_2i64:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    pxor %xmm1, %xmm1
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3]
; SSE2-NEXT:    punpckldq {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: zext_8i16_to_2i64:
; SSSE3:       # BB#0: # %entry
; SSSE3-NEXT:    pxor %xmm1, %xmm1
; SSSE3-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3]
; SSSE3-NEXT:    punpckldq {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: zext_8i16_to_2i64:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    pmovzxwq {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,xmm0[1],zero,zero,zero
; SSE41-NEXT:    retq
;
; AVX-LABEL: zext_8i16_to_2i64:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpmovzxwq {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,xmm0[1],zero,zero,zero
; AVX-NEXT:    retq
entry:
  %B = shufflevector <8 x i16> %A, <8 x i16> undef, <2 x i32> <i32 0, i32 1>
  %C = zext <2 x i16> %B to <2 x i64>
  ret <2 x i64> %C
}

define <4 x i64> @zext_8i16_to_4i64(<8 x i16> %A) nounwind uwtable readnone ssp {
; SSE2-LABEL: zext_8i16_to_4i64:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm0, %xmm1
; SSE2-NEXT:    pxor %xmm2, %xmm2
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1],xmm1[2],xmm2[2],xmm1[3],xmm2[3]
; SSE2-NEXT:    movdqa %xmm1, %xmm0
; SSE2-NEXT:    punpckldq {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1]
; SSE2-NEXT:    punpckhdq {{.*#+}} xmm1 = xmm1[2],xmm2[2],xmm1[3],xmm2[3]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: zext_8i16_to_4i64:
; SSSE3:       # BB#0: # %entry
; SSSE3-NEXT:    movdqa %xmm0, %xmm1
; SSSE3-NEXT:    pxor %xmm2, %xmm2
; SSSE3-NEXT:    punpcklwd {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1],xmm1[2],xmm2[2],xmm1[3],xmm2[3]
; SSSE3-NEXT:    movdqa %xmm1, %xmm0
; SSSE3-NEXT:    punpckldq {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1]
; SSSE3-NEXT:    punpckhdq {{.*#+}} xmm1 = xmm1[2],xmm2[2],xmm1[3],xmm2[3]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: zext_8i16_to_4i64:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    pmovzxwq {{.*#+}} xmm2 = xmm0[0],zero,zero,zero,xmm0[1],zero,zero,zero
; SSE41-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[1,1,2,3]
; SSE41-NEXT:    pmovzxwq {{.*#+}} xmm1 = xmm0[0],zero,zero,zero,xmm0[1],zero,zero,zero
; SSE41-NEXT:    movdqa %xmm2, %xmm0
; SSE41-NEXT:    retq
;
; AVX1-LABEL: zext_8i16_to_4i64:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vpmovzxwd {{.*#+}} xmm1 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero
; AVX1-NEXT:    vpshufd {{.*#+}} xmm1 = xmm1[2,2,3,3]
; AVX1-NEXT:    vpxor %xmm2, %xmm2, %xmm2
; AVX1-NEXT:    vpblendw {{.*#+}} xmm1 = xmm1[0],xmm2[1,2,3],xmm1[4],xmm2[5,6,7]
; AVX1-NEXT:    vpmovzxwq {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,xmm0[1],zero,zero,zero
; AVX1-NEXT:    vpblendw {{.*#+}} xmm0 = xmm0[0],xmm2[1,2,3],xmm0[4],xmm2[5,6,7]
; AVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: zext_8i16_to_4i64:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmovzxwq {{.*#+}} ymm0 = xmm0[0],zero,zero,zero,xmm0[1],zero,zero,zero,xmm0[2],zero,zero,zero,xmm0[3],zero,zero,zero
; AVX2-NEXT:    vpxor %ymm1, %ymm1, %ymm1
; AVX2-NEXT:    vpblendw {{.*#+}} ymm0 = ymm0[0],ymm1[1,2,3],ymm0[4],ymm1[5,6,7],ymm0[8],ymm1[9,10,11],ymm0[12],ymm1[13,14,15]
; AVX2-NEXT:    retq
entry:
  %B = shufflevector <8 x i16> %A, <8 x i16> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %C = zext <4 x i16> %B to <4 x i64>
  ret <4 x i64> %C
}

define <2 x i64> @zext_4i32_to_2i64(<4 x i32> %A) nounwind uwtable readnone ssp {
; SSE2-LABEL: zext_4i32_to_2i64:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    pxor %xmm1, %xmm1
; SSE2-NEXT:    punpckldq {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: zext_4i32_to_2i64:
; SSSE3:       # BB#0: # %entry
; SSSE3-NEXT:    pxor %xmm1, %xmm1
; SSSE3-NEXT:    punpckldq {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: zext_4i32_to_2i64:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    pmovzxdq {{.*#+}} xmm0 = xmm0[0],zero,xmm0[1],zero
; SSE41-NEXT:    retq
;
; AVX-LABEL: zext_4i32_to_2i64:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpmovzxdq {{.*#+}} xmm0 = xmm0[0],zero,xmm0[1],zero
; AVX-NEXT:    retq
entry:
  %B = shufflevector <4 x i32> %A, <4 x i32> undef, <2 x i32> <i32 0, i32 1>
  %C = zext <2 x i32> %B to <2 x i64>
  ret <2 x i64> %C
}

define <4 x i64> @zext_4i32_to_4i64(<4 x i32> %A) nounwind uwtable readnone ssp {
; SSE2-LABEL: zext_4i32_to_4i64:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm0, %xmm1
; SSE2-NEXT:    pxor %xmm2, %xmm2
; SSE2-NEXT:    punpckldq {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1]
; SSE2-NEXT:    punpckhdq {{.*#+}} xmm1 = xmm1[2],xmm2[2],xmm1[3],xmm2[3]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: zext_4i32_to_4i64:
; SSSE3:       # BB#0: # %entry
; SSSE3-NEXT:    movdqa %xmm0, %xmm1
; SSSE3-NEXT:    pxor %xmm2, %xmm2
; SSSE3-NEXT:    punpckldq {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1]
; SSSE3-NEXT:    punpckhdq {{.*#+}} xmm1 = xmm1[2],xmm2[2],xmm1[3],xmm2[3]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: zext_4i32_to_4i64:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    movdqa %xmm0, %xmm1
; SSE41-NEXT:    pxor %xmm2, %xmm2
; SSE41-NEXT:    pmovzxdq {{.*#+}} xmm0 = xmm1[0],zero,xmm1[1],zero
; SSE41-NEXT:    punpckhdq {{.*#+}} xmm1 = xmm1[2],xmm2[2],xmm1[3],xmm2[3]
; SSE41-NEXT:    retq
;
; AVX1-LABEL: zext_4i32_to_4i64:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX1-NEXT:    vpunpckhdq {{.*#+}} xmm1 = xmm0[2],xmm1[2],xmm0[3],xmm1[3]
; AVX1-NEXT:    vpmovzxdq {{.*#+}} xmm0 = xmm0[0],zero,xmm0[1],zero
; AVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: zext_4i32_to_4i64:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmovzxdq {{.*#+}} ymm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero
; AVX2-NEXT:    retq
entry:
  %B = zext <4 x i32> %A to <4 x i64>
  ret <4 x i64>%B
}

define <2 x i64> @load_zext_2i8_to_2i64(<2 x i8> *%ptr) {
; SSE2-LABEL: load_zext_2i8_to_2i64:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movzwl (%rdi), %eax
; SSE2-NEXT:    movd %eax, %xmm0
; SSE2-NEXT:    pxor %xmm1, %xmm1
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3],xmm0[4],xmm1[4],xmm0[5],xmm1[5],xmm0[6],xmm1[6],xmm0[7],xmm1[7]
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3]
; SSE2-NEXT:    punpckldq {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: load_zext_2i8_to_2i64:
; SSSE3:       # BB#0: # %entry
; SSSE3-NEXT:    movzwl (%rdi), %eax
; SSSE3-NEXT:    movd %eax, %xmm0
; SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,zero,zero,zero,zero,xmm0[1],zero,zero,zero,zero,zero,zero,zero
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: load_zext_2i8_to_2i64:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    pmovzxbq {{.*#+}} xmm0 = mem[0],zero,zero,zero,zero,zero,zero,zero,mem[1],zero,zero,zero,zero,zero,zero,zero
; SSE41-NEXT:    retq
;
; AVX-LABEL: load_zext_2i8_to_2i64:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpmovzxbq {{.*#+}} xmm0 = mem[0],zero,zero,zero,zero,zero,zero,zero,mem[1],zero,zero,zero,zero,zero,zero,zero
; AVX-NEXT:    retq
entry:
 %X = load <2 x i8>, <2 x i8>* %ptr
 %Y = zext <2 x i8> %X to <2 x i64>
 ret <2 x i64> %Y
}

define <4 x i32> @load_zext_4i8_to_4i32(<4 x i8> *%ptr) {
; SSE2-LABEL: load_zext_4i8_to_4i32:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; SSE2-NEXT:    pxor %xmm1, %xmm1
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3],xmm0[4],xmm1[4],xmm0[5],xmm1[5],xmm0[6],xmm1[6],xmm0[7],xmm1[7]
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: load_zext_4i8_to_4i32:
; SSSE3:       # BB#0: # %entry
; SSSE3-NEXT:    movd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; SSSE3-NEXT:    pxor %xmm1, %xmm1
; SSSE3-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3],xmm0[4],xmm1[4],xmm0[5],xmm1[5],xmm0[6],xmm1[6],xmm0[7],xmm1[7]
; SSSE3-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: load_zext_4i8_to_4i32:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    pmovzxbd {{.*#+}} xmm0 = mem[0],zero,zero,zero,mem[1],zero,zero,zero,mem[2],zero,zero,zero,mem[3],zero,zero,zero
; SSE41-NEXT:    retq
;
; AVX-LABEL: load_zext_4i8_to_4i32:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpmovzxbd {{.*#+}} xmm0 = mem[0],zero,zero,zero,mem[1],zero,zero,zero,mem[2],zero,zero,zero,mem[3],zero,zero,zero
; AVX-NEXT:    retq
entry:
 %X = load <4 x i8>, <4 x i8>* %ptr
 %Y = zext <4 x i8> %X to <4 x i32>
 ret <4 x i32> %Y
}

define <4 x i64> @load_zext_4i8_to_4i64(<4 x i8> *%ptr) {
; SSE2-LABEL: load_zext_4i8_to_4i64:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movd {{.*#+}} xmm1 = mem[0],zero,zero,zero
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm1 = xmm1[0],xmm0[0],xmm1[1],xmm0[1],xmm1[2],xmm0[2],xmm1[3],xmm0[3],xmm1[4],xmm0[4],xmm1[5],xmm0[5],xmm1[6],xmm0[6],xmm1[7],xmm0[7]
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm1 = xmm1[0],xmm0[0],xmm1[1],xmm0[1],xmm1[2],xmm0[2],xmm1[3],xmm0[3]
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm1[0,1,1,3]
; SSE2-NEXT:    movdqa {{.*#+}} xmm2 = [255,0,0,0,0,0,0,0,255,0,0,0,0,0,0,0]
; SSE2-NEXT:    pand %xmm2, %xmm0
; SSE2-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[2,1,3,3]
; SSE2-NEXT:    pand %xmm2, %xmm1
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: load_zext_4i8_to_4i64:
; SSSE3:       # BB#0: # %entry
; SSSE3-NEXT:    movd {{.*#+}} xmm1 = mem[0],zero,zero,zero
; SSSE3-NEXT:    punpcklbw {{.*#+}} xmm1 = xmm1[0],xmm0[0],xmm1[1],xmm0[1],xmm1[2],xmm0[2],xmm1[3],xmm0[3],xmm1[4],xmm0[4],xmm1[5],xmm0[5],xmm1[6],xmm0[6],xmm1[7],xmm0[7]
; SSSE3-NEXT:    punpcklwd {{.*#+}} xmm1 = xmm1[0],xmm0[0],xmm1[1],xmm0[1],xmm1[2],xmm0[2],xmm1[3],xmm0[3]
; SSSE3-NEXT:    movdqa %xmm1, %xmm0
; SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,zero,zero,zero,zero,xmm0[4],zero,zero,zero,zero,zero,zero,zero
; SSSE3-NEXT:    pshufb {{.*#+}} xmm1 = xmm1[8],zero,zero,zero,zero,zero,zero,zero,xmm1[12],zero,zero,zero,zero,zero,zero,zero
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: load_zext_4i8_to_4i64:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    pmovzxbq {{.*#+}} xmm0 = mem[0],zero,zero,zero,zero,zero,zero,zero,mem[1],zero,zero,zero,zero,zero,zero,zero
; SSE41-NEXT:    pmovzxbq {{.*#+}} xmm1 = mem[0],zero,zero,zero,zero,zero,zero,zero,mem[1],zero,zero,zero,zero,zero,zero,zero
; SSE41-NEXT:    retq
;
; AVX1-LABEL: load_zext_4i8_to_4i64:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vpmovzxbq {{.*#+}} xmm0 = mem[0],zero,zero,zero,zero,zero,zero,zero,mem[1],zero,zero,zero,zero,zero,zero,zero
; AVX1-NEXT:    vpmovzxbq {{.*#+}} xmm1 = mem[0],zero,zero,zero,zero,zero,zero,zero,mem[1],zero,zero,zero,zero,zero,zero,zero
; AVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: load_zext_4i8_to_4i64:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmovzxbq {{.*#+}} ymm0 = mem[0],zero,zero,zero,zero,zero,zero,zero,mem[1],zero,zero,zero,zero,zero,zero,zero,mem[2],zero,zero,zero,zero,zero,zero,zero,mem[3],zero,zero,zero,zero,zero,zero,zero
; AVX2-NEXT:    retq
entry:
 %X = load <4 x i8>, <4 x i8>* %ptr
 %Y = zext <4 x i8> %X to <4 x i64>
 ret <4 x i64> %Y
}

define <8 x i16> @load_zext_8i8_to_8i16(<8 x i8> *%ptr) {
; SSE2-LABEL: load_zext_8i8_to_8i16:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movq {{.*#+}} xmm0 = mem[0],zero
; SSE2-NEXT:    pxor %xmm1, %xmm1
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3],xmm0[4],xmm1[4],xmm0[5],xmm1[5],xmm0[6],xmm1[6],xmm0[7],xmm1[7]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: load_zext_8i8_to_8i16:
; SSSE3:       # BB#0: # %entry
; SSSE3-NEXT:    movq {{.*#+}} xmm0 = mem[0],zero
; SSSE3-NEXT:    pxor %xmm1, %xmm1
; SSSE3-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3],xmm0[4],xmm1[4],xmm0[5],xmm1[5],xmm0[6],xmm1[6],xmm0[7],xmm1[7]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: load_zext_8i8_to_8i16:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    pmovzxbw {{.*#+}} xmm0 = mem[0],zero,mem[1],zero,mem[2],zero,mem[3],zero,mem[4],zero,mem[5],zero,mem[6],zero,mem[7],zero
; SSE41-NEXT:    retq
;
; AVX-LABEL: load_zext_8i8_to_8i16:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpmovzxbw {{.*#+}} xmm0 = mem[0],zero,mem[1],zero,mem[2],zero,mem[3],zero,mem[4],zero,mem[5],zero,mem[6],zero,mem[7],zero
; AVX-NEXT:    retq
entry:
 %X = load <8 x i8>, <8 x i8>* %ptr
 %Y = zext <8 x i8> %X to <8 x i16>
 ret <8 x i16> %Y
}

define <8 x i32> @load_zext_8i8_to_8i32(<8 x i8> *%ptr) {
; SSE2-LABEL: load_zext_8i8_to_8i32:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movq {{.*#+}} xmm1 = mem[0],zero
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm1 = xmm1[0],xmm0[0],xmm1[1],xmm0[1],xmm1[2],xmm0[2],xmm1[3],xmm0[3],xmm1[4],xmm0[4],xmm1[5],xmm0[5],xmm1[6],xmm0[6],xmm1[7],xmm0[7]
; SSE2-NEXT:    movdqa %xmm1, %xmm0
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3]
; SSE2-NEXT:    movdqa {{.*#+}} xmm2 = [255,0,0,0,255,0,0,0,255,0,0,0,255,0,0,0]
; SSE2-NEXT:    pand %xmm2, %xmm0
; SSE2-NEXT:    punpckhwd {{.*#+}} xmm1 = xmm1[4],xmm0[4],xmm1[5],xmm0[5],xmm1[6],xmm0[6],xmm1[7],xmm0[7]
; SSE2-NEXT:    pand %xmm2, %xmm1
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: load_zext_8i8_to_8i32:
; SSSE3:       # BB#0: # %entry
; SSSE3-NEXT:    movq {{.*#+}} xmm1 = mem[0],zero
; SSSE3-NEXT:    punpcklbw {{.*#+}} xmm1 = xmm1[0],xmm0[0],xmm1[1],xmm0[1],xmm1[2],xmm0[2],xmm1[3],xmm0[3],xmm1[4],xmm0[4],xmm1[5],xmm0[5],xmm1[6],xmm0[6],xmm1[7],xmm0[7]
; SSSE3-NEXT:    movdqa %xmm1, %xmm0
; SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,xmm0[2],zero,zero,zero,xmm0[4],zero,zero,zero,xmm0[6],zero,zero,zero
; SSSE3-NEXT:    pshufb {{.*#+}} xmm1 = xmm1[8],zero,zero,zero,xmm1[10],zero,zero,zero,xmm1[12],zero,zero,zero,xmm1[14],zero,zero,zero
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: load_zext_8i8_to_8i32:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    pmovzxbd {{.*#+}} xmm0 = mem[0],zero,zero,zero,mem[1],zero,zero,zero,mem[2],zero,zero,zero,mem[3],zero,zero,zero
; SSE41-NEXT:    pmovzxbd {{.*#+}} xmm1 = mem[0],zero,zero,zero,mem[1],zero,zero,zero,mem[2],zero,zero,zero,mem[3],zero,zero,zero
; SSE41-NEXT:    retq
;
; AVX1-LABEL: load_zext_8i8_to_8i32:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vpmovzxbd {{.*#+}} xmm0 = mem[0],zero,zero,zero,mem[1],zero,zero,zero,mem[2],zero,zero,zero,mem[3],zero,zero,zero
; AVX1-NEXT:    vpmovzxbd {{.*#+}} xmm1 = mem[0],zero,zero,zero,mem[1],zero,zero,zero,mem[2],zero,zero,zero,mem[3],zero,zero,zero
; AVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: load_zext_8i8_to_8i32:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmovzxbd {{.*#+}} ymm0 = mem[0],zero,zero,zero,mem[1],zero,zero,zero,mem[2],zero,zero,zero,mem[3],zero,zero,zero,mem[4],zero,zero,zero,mem[5],zero,zero,zero,mem[6],zero,zero,zero,mem[7],zero,zero,zero
; AVX2-NEXT:    retq
entry:
 %X = load <8 x i8>, <8 x i8>* %ptr
 %Y = zext <8 x i8> %X to <8 x i32>
 ret <8 x i32> %Y
}

define <16 x i16> @load_zext_16i8_to_16i16(<16 x i8> *%ptr) {
; SSE2-LABEL: load_zext_16i8_to_16i16:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa (%rdi), %xmm1
; SSE2-NEXT:    pxor %xmm2, %xmm2
; SSE2-NEXT:    movdqa %xmm1, %xmm0
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1],xmm0[2],xmm2[2],xmm0[3],xmm2[3],xmm0[4],xmm2[4],xmm0[5],xmm2[5],xmm0[6],xmm2[6],xmm0[7],xmm2[7]
; SSE2-NEXT:    punpckhbw {{.*#+}} xmm1 = xmm1[8],xmm2[8],xmm1[9],xmm2[9],xmm1[10],xmm2[10],xmm1[11],xmm2[11],xmm1[12],xmm2[12],xmm1[13],xmm2[13],xmm1[14],xmm2[14],xmm1[15],xmm2[15]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: load_zext_16i8_to_16i16:
; SSSE3:       # BB#0: # %entry
; SSSE3-NEXT:    movdqa (%rdi), %xmm1
; SSSE3-NEXT:    pxor %xmm2, %xmm2
; SSSE3-NEXT:    movdqa %xmm1, %xmm0
; SSSE3-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1],xmm0[2],xmm2[2],xmm0[3],xmm2[3],xmm0[4],xmm2[4],xmm0[5],xmm2[5],xmm0[6],xmm2[6],xmm0[7],xmm2[7]
; SSSE3-NEXT:    punpckhbw {{.*#+}} xmm1 = xmm1[8],xmm2[8],xmm1[9],xmm2[9],xmm1[10],xmm2[10],xmm1[11],xmm2[11],xmm1[12],xmm2[12],xmm1[13],xmm2[13],xmm1[14],xmm2[14],xmm1[15],xmm2[15]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: load_zext_16i8_to_16i16:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    pmovzxbw {{.*#+}} xmm0 = mem[0],zero,mem[1],zero,mem[2],zero,mem[3],zero,mem[4],zero,mem[5],zero,mem[6],zero,mem[7],zero
; SSE41-NEXT:    pmovzxbw {{.*#+}} xmm1 = mem[0],zero,mem[1],zero,mem[2],zero,mem[3],zero,mem[4],zero,mem[5],zero,mem[6],zero,mem[7],zero
; SSE41-NEXT:    retq
;
; AVX1-LABEL: load_zext_16i8_to_16i16:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vpmovzxbw {{.*#+}} xmm0 = mem[0],zero,mem[1],zero,mem[2],zero,mem[3],zero,mem[4],zero,mem[5],zero,mem[6],zero,mem[7],zero
; AVX1-NEXT:    vpmovzxbw {{.*#+}} xmm1 = mem[0],zero,mem[1],zero,mem[2],zero,mem[3],zero,mem[4],zero,mem[5],zero,mem[6],zero,mem[7],zero
; AVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: load_zext_16i8_to_16i16:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmovzxbw {{.*#+}} ymm0 = mem[0],zero,mem[1],zero,mem[2],zero,mem[3],zero,mem[4],zero,mem[5],zero,mem[6],zero,mem[7],zero,mem[8],zero,mem[9],zero,mem[10],zero,mem[11],zero,mem[12],zero,mem[13],zero,mem[14],zero,mem[15],zero
; AVX2-NEXT:    retq
entry:
 %X = load <16 x i8>, <16 x i8>* %ptr
 %Y = zext <16 x i8> %X to <16 x i16>
 ret <16 x i16> %Y
}

define <2 x i64> @load_zext_2i16_to_2i64(<2 x i16> *%ptr) {
; SSE2-LABEL: load_zext_2i16_to_2i64:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; SSE2-NEXT:    pxor %xmm1, %xmm1
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3]
; SSE2-NEXT:    punpckldq {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: load_zext_2i16_to_2i64:
; SSSE3:       # BB#0: # %entry
; SSSE3-NEXT:    movd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; SSSE3-NEXT:    pxor %xmm1, %xmm1
; SSSE3-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3]
; SSSE3-NEXT:    punpckldq {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: load_zext_2i16_to_2i64:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    pmovzxwq {{.*#+}} xmm0 = mem[0],zero,zero,zero,mem[1],zero,zero,zero
; SSE41-NEXT:    retq
;
; AVX-LABEL: load_zext_2i16_to_2i64:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpmovzxwq {{.*#+}} xmm0 = mem[0],zero,zero,zero,mem[1],zero,zero,zero
; AVX-NEXT:    retq
entry:
 %X = load <2 x i16>, <2 x i16>* %ptr
 %Y = zext <2 x i16> %X to <2 x i64>
 ret <2 x i64> %Y
}

define <4 x i32> @load_zext_4i16_to_4i32(<4 x i16> *%ptr) {
; SSE2-LABEL: load_zext_4i16_to_4i32:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movq {{.*#+}} xmm0 = mem[0],zero
; SSE2-NEXT:    pxor %xmm1, %xmm1
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: load_zext_4i16_to_4i32:
; SSSE3:       # BB#0: # %entry
; SSSE3-NEXT:    movq {{.*#+}} xmm0 = mem[0],zero
; SSSE3-NEXT:    pxor %xmm1, %xmm1
; SSSE3-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: load_zext_4i16_to_4i32:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    pmovzxwd {{.*#+}} xmm0 = mem[0],zero,mem[1],zero,mem[2],zero,mem[3],zero
; SSE41-NEXT:    retq
;
; AVX-LABEL: load_zext_4i16_to_4i32:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpmovzxwd {{.*#+}} xmm0 = mem[0],zero,mem[1],zero,mem[2],zero,mem[3],zero
; AVX-NEXT:    retq
entry:
 %X = load <4 x i16>, <4 x i16>* %ptr
 %Y = zext <4 x i16> %X to <4 x i32>
 ret <4 x i32> %Y
}

define <4 x i64> @load_zext_4i16_to_4i64(<4 x i16> *%ptr) {
; SSE2-LABEL: load_zext_4i16_to_4i64:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movq {{.*#+}} xmm1 = mem[0],zero
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm1 = xmm1[0],xmm0[0],xmm1[1],xmm0[1],xmm1[2],xmm0[2],xmm1[3],xmm0[3]
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm1[0,1,1,3]
; SSE2-NEXT:    movdqa {{.*#+}} xmm2 = [65535,0,0,0,65535,0,0,0]
; SSE2-NEXT:    pand %xmm2, %xmm0
; SSE2-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[2,1,3,3]
; SSE2-NEXT:    pand %xmm2, %xmm1
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: load_zext_4i16_to_4i64:
; SSSE3:       # BB#0: # %entry
; SSSE3-NEXT:    movq {{.*#+}} xmm1 = mem[0],zero
; SSSE3-NEXT:    punpcklwd {{.*#+}} xmm1 = xmm1[0],xmm0[0],xmm1[1],xmm0[1],xmm1[2],xmm0[2],xmm1[3],xmm0[3]
; SSSE3-NEXT:    movdqa %xmm1, %xmm0
; SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0,1],zero,zero,zero,zero,zero,zero,xmm0[4,5],zero,zero,zero,zero,zero,zero
; SSSE3-NEXT:    pshufb {{.*#+}} xmm1 = xmm1[8,9],zero,zero,zero,zero,zero,zero,xmm1[12,13],zero,zero,zero,zero,zero,zero
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: load_zext_4i16_to_4i64:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    pmovzxwq {{.*#+}} xmm0 = mem[0],zero,zero,zero,mem[1],zero,zero,zero
; SSE41-NEXT:    pmovzxwq {{.*#+}} xmm1 = mem[0],zero,zero,zero,mem[1],zero,zero,zero
; SSE41-NEXT:    retq
;
; AVX1-LABEL: load_zext_4i16_to_4i64:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vpmovzxwq {{.*#+}} xmm0 = mem[0],zero,zero,zero,mem[1],zero,zero,zero
; AVX1-NEXT:    vpmovzxwq {{.*#+}} xmm1 = mem[0],zero,zero,zero,mem[1],zero,zero,zero
; AVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: load_zext_4i16_to_4i64:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmovzxwq {{.*#+}} ymm0 = mem[0],zero,zero,zero,mem[1],zero,zero,zero,mem[2],zero,zero,zero,mem[3],zero,zero,zero
; AVX2-NEXT:    retq
entry:
 %X = load <4 x i16>, <4 x i16>* %ptr
 %Y = zext <4 x i16> %X to <4 x i64>
 ret <4 x i64> %Y
}

define <8 x i32> @load_zext_8i16_to_8i32(<8 x i16> *%ptr) {
; SSE2-LABEL: load_zext_8i16_to_8i32:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa (%rdi), %xmm1
; SSE2-NEXT:    pxor %xmm2, %xmm2
; SSE2-NEXT:    movdqa %xmm1, %xmm0
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1],xmm0[2],xmm2[2],xmm0[3],xmm2[3]
; SSE2-NEXT:    punpckhwd {{.*#+}} xmm1 = xmm1[4],xmm2[4],xmm1[5],xmm2[5],xmm1[6],xmm2[6],xmm1[7],xmm2[7]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: load_zext_8i16_to_8i32:
; SSSE3:       # BB#0: # %entry
; SSSE3-NEXT:    movdqa (%rdi), %xmm1
; SSSE3-NEXT:    pxor %xmm2, %xmm2
; SSSE3-NEXT:    movdqa %xmm1, %xmm0
; SSSE3-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1],xmm0[2],xmm2[2],xmm0[3],xmm2[3]
; SSSE3-NEXT:    punpckhwd {{.*#+}} xmm1 = xmm1[4],xmm2[4],xmm1[5],xmm2[5],xmm1[6],xmm2[6],xmm1[7],xmm2[7]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: load_zext_8i16_to_8i32:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    pmovzxwd {{.*#+}} xmm0 = mem[0],zero,mem[1],zero,mem[2],zero,mem[3],zero
; SSE41-NEXT:    pmovzxwd {{.*#+}} xmm1 = mem[0],zero,mem[1],zero,mem[2],zero,mem[3],zero
; SSE41-NEXT:    retq
;
; AVX1-LABEL: load_zext_8i16_to_8i32:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vpmovzxwd {{.*#+}} xmm0 = mem[0],zero,mem[1],zero,mem[2],zero,mem[3],zero
; AVX1-NEXT:    vpmovzxwd {{.*#+}} xmm1 = mem[0],zero,mem[1],zero,mem[2],zero,mem[3],zero
; AVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: load_zext_8i16_to_8i32:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmovzxwd {{.*#+}} ymm0 = mem[0],zero,mem[1],zero,mem[2],zero,mem[3],zero,mem[4],zero,mem[5],zero,mem[6],zero,mem[7],zero
; AVX2-NEXT:    retq
entry:
 %X = load <8 x i16>, <8 x i16>* %ptr
 %Y = zext <8 x i16> %X to <8 x i32>
 ret <8 x i32> %Y
}

define <2 x i64> @load_zext_2i32_to_2i64(<2 x i32> *%ptr) {
; SSE2-LABEL: load_zext_2i32_to_2i64:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movq {{.*#+}} xmm0 = mem[0],zero
; SSE2-NEXT:    pxor %xmm1, %xmm1
; SSE2-NEXT:    punpckldq {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: load_zext_2i32_to_2i64:
; SSSE3:       # BB#0: # %entry
; SSSE3-NEXT:    movq {{.*#+}} xmm0 = mem[0],zero
; SSSE3-NEXT:    pxor %xmm1, %xmm1
; SSSE3-NEXT:    punpckldq {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: load_zext_2i32_to_2i64:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    pmovzxdq {{.*#+}} xmm0 = mem[0],zero,mem[1],zero
; SSE41-NEXT:    retq
;
; AVX-LABEL: load_zext_2i32_to_2i64:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpmovzxdq {{.*#+}} xmm0 = mem[0],zero,mem[1],zero
; AVX-NEXT:    retq
entry:
 %X = load <2 x i32>, <2 x i32>* %ptr
 %Y = zext <2 x i32> %X to <2 x i64>
 ret <2 x i64> %Y
}

define <4 x i64> @load_zext_4i32_to_4i64(<4 x i32> *%ptr) {
; SSE2-LABEL: load_zext_4i32_to_4i64:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa (%rdi), %xmm1
; SSE2-NEXT:    pxor %xmm2, %xmm2
; SSE2-NEXT:    movdqa %xmm1, %xmm0
; SSE2-NEXT:    punpckldq {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1]
; SSE2-NEXT:    punpckhdq {{.*#+}} xmm1 = xmm1[2],xmm2[2],xmm1[3],xmm2[3]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: load_zext_4i32_to_4i64:
; SSSE3:       # BB#0: # %entry
; SSSE3-NEXT:    movdqa (%rdi), %xmm1
; SSSE3-NEXT:    pxor %xmm2, %xmm2
; SSSE3-NEXT:    movdqa %xmm1, %xmm0
; SSSE3-NEXT:    punpckldq {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1]
; SSSE3-NEXT:    punpckhdq {{.*#+}} xmm1 = xmm1[2],xmm2[2],xmm1[3],xmm2[3]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: load_zext_4i32_to_4i64:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    pmovzxdq {{.*#+}} xmm0 = mem[0],zero,mem[1],zero
; SSE41-NEXT:    pmovzxdq {{.*#+}} xmm1 = mem[0],zero,mem[1],zero
; SSE41-NEXT:    retq
;
; AVX1-LABEL: load_zext_4i32_to_4i64:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vpmovzxdq {{.*#+}} xmm0 = mem[0],zero,mem[1],zero
; AVX1-NEXT:    vpmovzxdq {{.*#+}} xmm1 = mem[0],zero,mem[1],zero
; AVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: load_zext_4i32_to_4i64:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmovzxdq {{.*#+}} ymm0 = mem[0],zero,mem[1],zero,mem[2],zero,mem[3],zero
; AVX2-NEXT:    retq
entry:
 %X = load <4 x i32>, <4 x i32>* %ptr
 %Y = zext <4 x i32> %X to <4 x i64>
 ret <4 x i64> %Y
}

define <8 x i32> @zext_8i8_to_8i32(<8 x i8> %z) {
; SSE2-LABEL: zext_8i8_to_8i32:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm0, %xmm1
; SSE2-NEXT:    pand {{.*}}(%rip), %xmm1
; SSE2-NEXT:    pxor %xmm2, %xmm2
; SSE2-NEXT:    movdqa %xmm1, %xmm0
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1],xmm0[2],xmm2[2],xmm0[3],xmm2[3]
; SSE2-NEXT:    punpckhwd {{.*#+}} xmm1 = xmm1[4],xmm2[4],xmm1[5],xmm2[5],xmm1[6],xmm2[6],xmm1[7],xmm2[7]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: zext_8i8_to_8i32:
; SSSE3:       # BB#0: # %entry
; SSSE3-NEXT:    movdqa %xmm0, %xmm1
; SSSE3-NEXT:    pand {{.*}}(%rip), %xmm1
; SSSE3-NEXT:    pxor %xmm2, %xmm2
; SSSE3-NEXT:    movdqa %xmm1, %xmm0
; SSSE3-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1],xmm0[2],xmm2[2],xmm0[3],xmm2[3]
; SSSE3-NEXT:    punpckhwd {{.*#+}} xmm1 = xmm1[4],xmm2[4],xmm1[5],xmm2[5],xmm1[6],xmm2[6],xmm1[7],xmm2[7]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: zext_8i8_to_8i32:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    movdqa %xmm0, %xmm1
; SSE41-NEXT:    pand {{.*}}(%rip), %xmm1
; SSE41-NEXT:    pxor %xmm2, %xmm2
; SSE41-NEXT:    pmovzxwd {{.*#+}} xmm0 = xmm1[0],zero,xmm1[1],zero,xmm1[2],zero,xmm1[3],zero
; SSE41-NEXT:    punpckhwd {{.*#+}} xmm1 = xmm1[4],xmm2[4],xmm1[5],xmm2[5],xmm1[6],xmm2[6],xmm1[7],xmm2[7]
; SSE41-NEXT:    retq
;
; AVX1-LABEL: zext_8i8_to_8i32:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vpand {{.*}}(%rip), %xmm0, %xmm0
; AVX1-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX1-NEXT:    vpunpckhwd {{.*#+}} xmm1 = xmm0[4],xmm1[4],xmm0[5],xmm1[5],xmm0[6],xmm1[6],xmm0[7],xmm1[7]
; AVX1-NEXT:    vpmovzxwd {{.*#+}} xmm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero
; AVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: zext_8i8_to_8i32:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpand {{.*}}(%rip), %xmm0, %xmm0
; AVX2-NEXT:    vpmovzxwd {{.*#+}} ymm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero,xmm0[4],zero,xmm0[5],zero,xmm0[6],zero,xmm0[7],zero
; AVX2-NEXT:    retq
entry:
  %t = zext <8 x i8> %z to <8 x i32>
  ret <8 x i32> %t
}

define <8 x i32> @shuf_zext_8i16_to_8i32(<8 x i16> %A) nounwind uwtable readnone ssp {
; SSE2-LABEL: shuf_zext_8i16_to_8i32:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm0, %xmm1
; SSE2-NEXT:    pxor %xmm2, %xmm2
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1],xmm0[2],xmm2[2],xmm0[3],xmm2[3]
; SSE2-NEXT:    punpckhwd {{.*#+}} xmm1 = xmm1[4],xmm2[4],xmm1[5],xmm2[5],xmm1[6],xmm2[6],xmm1[7],xmm2[7]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuf_zext_8i16_to_8i32:
; SSSE3:       # BB#0: # %entry
; SSSE3-NEXT:    movdqa %xmm0, %xmm1
; SSSE3-NEXT:    pxor %xmm2, %xmm2
; SSSE3-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1],xmm0[2],xmm2[2],xmm0[3],xmm2[3]
; SSSE3-NEXT:    punpckhwd {{.*#+}} xmm1 = xmm1[4],xmm2[4],xmm1[5],xmm2[5],xmm1[6],xmm2[6],xmm1[7],xmm2[7]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuf_zext_8i16_to_8i32:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    movdqa %xmm0, %xmm1
; SSE41-NEXT:    pxor %xmm2, %xmm2
; SSE41-NEXT:    pmovzxwd {{.*#+}} xmm0 = xmm1[0],zero,xmm1[1],zero,xmm1[2],zero,xmm1[3],zero
; SSE41-NEXT:    punpckhwd {{.*#+}} xmm1 = xmm1[4],xmm2[4],xmm1[5],xmm2[5],xmm1[6],xmm2[6],xmm1[7],xmm2[7]
; SSE41-NEXT:    retq
;
; AVX1-LABEL: shuf_zext_8i16_to_8i32:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX1-NEXT:    vpunpckhwd {{.*#+}} xmm1 = xmm0[4],xmm1[4],xmm0[5],xmm1[5],xmm0[6],xmm1[6],xmm0[7],xmm1[7]
; AVX1-NEXT:    vpmovzxwd {{.*#+}} xmm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero
; AVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: shuf_zext_8i16_to_8i32:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmovzxwd {{.*#+}} ymm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero,xmm0[4],zero,xmm0[5],zero,xmm0[6],zero,xmm0[7],zero
; AVX2-NEXT:    retq
entry:
  %B = shufflevector <8 x i16> %A, <8 x i16> zeroinitializer, <16 x i32> <i32 0, i32 8, i32 1, i32 8, i32 2, i32 8, i32 3, i32 8, i32 4, i32 8, i32 5, i32 8, i32 6, i32 8, i32 7, i32 8>
  %Z = bitcast <16 x i16> %B to <8 x i32>
  ret <8 x i32> %Z
}

define <4 x i64> @shuf_zext_4i32_to_4i64(<4 x i32> %A) nounwind uwtable readnone ssp {
; SSE2-LABEL: shuf_zext_4i32_to_4i64:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm0, %xmm1
; SSE2-NEXT:    pxor %xmm2, %xmm2
; SSE2-NEXT:    punpckldq {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1]
; SSE2-NEXT:    punpckhdq {{.*#+}} xmm1 = xmm1[2],xmm2[2],xmm1[3],xmm2[3]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuf_zext_4i32_to_4i64:
; SSSE3:       # BB#0: # %entry
; SSSE3-NEXT:    movdqa %xmm0, %xmm1
; SSSE3-NEXT:    pxor %xmm2, %xmm2
; SSSE3-NEXT:    punpckldq {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1]
; SSSE3-NEXT:    punpckhdq {{.*#+}} xmm1 = xmm1[2],xmm2[2],xmm1[3],xmm2[3]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuf_zext_4i32_to_4i64:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    movdqa %xmm0, %xmm1
; SSE41-NEXT:    pxor %xmm2, %xmm2
; SSE41-NEXT:    pmovzxdq {{.*#+}} xmm0 = xmm1[0],zero,xmm1[1],zero
; SSE41-NEXT:    punpckhdq {{.*#+}} xmm1 = xmm1[2],xmm2[2],xmm1[3],xmm2[3]
; SSE41-NEXT:    retq
;
; AVX1-LABEL: shuf_zext_4i32_to_4i64:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vinsertps {{.*#+}} xmm1 = xmm0[0],zero,xmm0[1],zero
; AVX1-NEXT:    vxorpd %xmm2, %xmm2, %xmm2
; AVX1-NEXT:    vblendpd {{.*#+}} xmm0 = xmm2[0],xmm0[1]
; AVX1-NEXT:    vpermilps {{.*#+}} xmm0 = xmm0[2,0,3,0]
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm1, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: shuf_zext_4i32_to_4i64:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmovzxdq {{.*#+}} ymm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero
; AVX2-NEXT:    retq
entry:
  %B = shufflevector <4 x i32> %A, <4 x i32> zeroinitializer, <8 x i32> <i32 0, i32 4, i32 1, i32 4, i32 2, i32 4, i32 3, i32 4>
  %Z = bitcast <8 x i32> %B to <4 x i64>
  ret <4 x i64> %Z
}

define <8 x i32> @shuf_zext_8i8_to_8i32(<8 x i8> %A) {
; SSE2-LABEL: shuf_zext_8i8_to_8i32:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm0, %xmm1
; SSE2-NEXT:    pand {{.*}}(%rip), %xmm1
; SSE2-NEXT:    packuswb %xmm1, %xmm1
; SSE2-NEXT:    pxor %xmm2, %xmm2
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1],xmm1[2],xmm2[2],xmm1[3],xmm2[3],xmm1[4],xmm2[4],xmm1[5],xmm2[5],xmm1[6],xmm2[6],xmm1[7],xmm2[7]
; SSE2-NEXT:    movdqa %xmm1, %xmm0
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1],xmm0[2],xmm2[2],xmm0[3],xmm2[3]
; SSE2-NEXT:    punpckhwd {{.*#+}} xmm1 = xmm1[4],xmm2[4],xmm1[5],xmm2[5],xmm1[6],xmm2[6],xmm1[7],xmm2[7]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuf_zext_8i8_to_8i32:
; SSSE3:       # BB#0: # %entry
; SSSE3-NEXT:    movdqa %xmm0, %xmm1
; SSSE3-NEXT:    pshufb {{.*#+}} xmm1 = xmm1[0,2,4,6,8,10,12,14,u,u,u,u,u,u,u,u]
; SSSE3-NEXT:    pxor %xmm2, %xmm2
; SSSE3-NEXT:    punpcklbw {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1],xmm1[2],xmm2[2],xmm1[3],xmm2[3],xmm1[4],xmm2[4],xmm1[5],xmm2[5],xmm1[6],xmm2[6],xmm1[7],xmm2[7]
; SSSE3-NEXT:    movdqa %xmm1, %xmm0
; SSSE3-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1],xmm0[2],xmm2[2],xmm0[3],xmm2[3]
; SSSE3-NEXT:    punpckhwd {{.*#+}} xmm1 = xmm1[4],xmm2[4],xmm1[5],xmm2[5],xmm1[6],xmm2[6],xmm1[7],xmm2[7]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuf_zext_8i8_to_8i32:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0,2,4,6,8,10,12,14,u,u,u,u,u,u,u,u]
; SSE41-NEXT:    pmovzxbd {{.*#+}} xmm2 = xmm0[0],zero,zero,zero,xmm0[1],zero,zero,zero,xmm0[2],zero,zero,zero,xmm0[3],zero,zero,zero
; SSE41-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[1,1,2,3]
; SSE41-NEXT:    pmovzxbd {{.*#+}} xmm1 = xmm0[0],zero,zero,zero,xmm0[1],zero,zero,zero,xmm0[2],zero,zero,zero,xmm0[3],zero,zero,zero
; SSE41-NEXT:    movdqa %xmm2, %xmm0
; SSE41-NEXT:    retq
;
; AVX1-LABEL: shuf_zext_8i8_to_8i32:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,2,4,6,8,10,12,14,u,u,u,u,u,u,u,u]
; AVX1-NEXT:    vpmovzxbd {{.*#+}} xmm1 = xmm0[0],zero,zero,zero,xmm0[1],zero,zero,zero,xmm0[2],zero,zero,zero,xmm0[3],zero,zero,zero
; AVX1-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[1,1,2,3]
; AVX1-NEXT:    vpmovzxbd {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,xmm0[1],zero,zero,zero,xmm0[2],zero,zero,zero,xmm0[3],zero,zero,zero
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm1, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: shuf_zext_8i8_to_8i32:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,2,4,6,8,10,12,14,u,u,u,u,u,u,u,u]
; AVX2-NEXT:    vpmovzxbd {{.*#+}} ymm0 = xmm0[0],zero,zero,zero,xmm0[1],zero,zero,zero,xmm0[2],zero,zero,zero,xmm0[3],zero,zero,zero,xmm0[4],zero,zero,zero,xmm0[5],zero,zero,zero,xmm0[6],zero,zero,zero,xmm0[7],zero,zero,zero
; AVX2-NEXT:    retq
entry:
  %B = shufflevector <8 x i8> %A, <8 x i8> zeroinitializer, <32 x i32> <i32 0, i32 8, i32 8, i32 8, i32 1, i32 8, i32 8, i32 8, i32 2, i32 8, i32 8, i32 8, i32 3, i32 8, i32 8, i32 8, i32 4, i32 8, i32 8, i32 8, i32 5, i32 8, i32 8, i32 8, i32 6, i32 8, i32 8, i32 8, i32 7, i32 8, i32 8, i32 8>
  %Z = bitcast <32 x i8> %B to <8 x i32>
  ret <8 x i32> %Z
}

define <2 x i64> @shuf_zext_16i8_to_2i64_offset6(<16 x i8> %A) nounwind uwtable readnone ssp {
; SSE2-LABEL: shuf_zext_16i8_to_2i64_offset6:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    pxor %xmm1, %xmm1
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3],xmm0[4],xmm1[4],xmm0[5],xmm1[5],xmm0[6],xmm1[6],xmm0[7],xmm1[7]
; SSE2-NEXT:    punpckhwd {{.*#+}} xmm0 = xmm0[4],xmm1[4],xmm0[5],xmm1[5],xmm0[6],xmm1[6],xmm0[7],xmm1[7]
; SSE2-NEXT:    punpckhdq {{.*#+}} xmm0 = xmm0[2],xmm1[2],xmm0[3],xmm1[3]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuf_zext_16i8_to_2i64_offset6:
; SSSE3:       # BB#0: # %entry
; SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[6],zero,zero,zero,zero,zero,zero,zero,xmm0[7],zero,zero,zero,zero,zero,zero,zero
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuf_zext_16i8_to_2i64_offset6:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    psrlq $48, %xmm0
; SSE41-NEXT:    pmovzxbq {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,zero,zero,zero,zero,xmm0[1],zero,zero,zero,zero,zero,zero,zero
; SSE41-NEXT:    retq
;
; AVX-LABEL: shuf_zext_16i8_to_2i64_offset6:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpsrlq $48, %xmm0, %xmm0
; AVX-NEXT:    vpmovzxbq {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,zero,zero,zero,zero,xmm0[1],zero,zero,zero,zero,zero,zero,zero
; AVX-NEXT:    retq
entry:
  %B = shufflevector <16 x i8> %A, <16 x i8> zeroinitializer, <16 x i32> <i32 6, i32 16, i32 16, i32 16, i32 16, i32 16, i32 16, i32 16, i32 7, i32 16, i32 16, i32 16, i32 16, i32 16, i32 16, i32 16>
  %Z = bitcast <16 x i8> %B to <2 x i64>
  ret <2 x i64> %Z
}

define <4 x i64> @shuf_zext_16i8_to_4i64_offset11(<16 x i8> %A) nounwind uwtable readnone ssp {
; SSE2-LABEL: shuf_zext_16i8_to_4i64_offset11:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm0, %xmm1
; SSE2-NEXT:    psrldq {{.*#+}} xmm1 = xmm1[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15],zero
; SSE2-NEXT:    pxor %xmm2, %xmm2
; SSE2-NEXT:    punpckhbw {{.*#+}} xmm1 = xmm1[8],xmm2[8],xmm1[9],xmm2[9],xmm1[10],xmm2[10],xmm1[11],xmm2[11],xmm1[12],xmm2[12],xmm1[13],xmm2[13],xmm1[14],xmm2[14],xmm1[15],xmm2[15]
; SSE2-NEXT:    movdqa %xmm1, %xmm0
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1],xmm0[2],xmm2[2],xmm0[3],xmm2[3]
; SSE2-NEXT:    punpckhdq {{.*#+}} xmm0 = xmm0[2],xmm2[2],xmm0[3],xmm2[3]
; SSE2-NEXT:    punpckhwd {{.*#+}} xmm1 = xmm1[4],xmm2[4],xmm1[5],xmm2[5],xmm1[6],xmm2[6],xmm1[7],xmm2[7]
; SSE2-NEXT:    punpckldq {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuf_zext_16i8_to_4i64_offset11:
; SSSE3:       # BB#0: # %entry
; SSSE3-NEXT:    movdqa %xmm0, %xmm1
; SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[11],zero,zero,zero,zero,zero,zero,zero,xmm0[12],zero,zero,zero,zero,zero,zero,zero
; SSSE3-NEXT:    pshufb {{.*#+}} xmm1 = xmm1[13],zero,zero,zero,zero,zero,zero,zero,xmm1[14],zero,zero,zero,zero,zero,zero,zero
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuf_zext_16i8_to_4i64_offset11:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    movdqa %xmm0, %xmm1
; SSE41-NEXT:    psrldq {{.*#+}} xmm1 = xmm1[11,12,13,14,15],zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero
; SSE41-NEXT:    pmovzxbq {{.*#+}} xmm2 = xmm1[0],zero,zero,zero,zero,zero,zero,zero,xmm1[1],zero,zero,zero,zero,zero,zero,zero
; SSE41-NEXT:    psrldq {{.*#+}} xmm0 = xmm0[13,14,15],zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero
; SSE41-NEXT:    pmovzxbq {{.*#+}} xmm1 = xmm0[0],zero,zero,zero,zero,zero,zero,zero,xmm0[1],zero,zero,zero,zero,zero,zero,zero
; SSE41-NEXT:    movdqa %xmm2, %xmm0
; SSE41-NEXT:    retq
;
; AVX1-LABEL: shuf_zext_16i8_to_4i64_offset11:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vpsrldq {{.*#+}} xmm1 = xmm0[11,12,13,14,15],zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero
; AVX1-NEXT:    vpmovzxbq {{.*#+}} xmm1 = xmm1[0],zero,zero,zero,zero,zero,zero,zero,xmm1[1],zero,zero,zero,zero,zero,zero,zero
; AVX1-NEXT:    vpsrldq {{.*#+}} xmm0 = xmm0[13,14,15],zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero
; AVX1-NEXT:    vpmovzxbq {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,zero,zero,zero,zero,xmm0[1],zero,zero,zero,zero,zero,zero,zero
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm1, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: shuf_zext_16i8_to_4i64_offset11:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpsrldq {{.*#+}} ymm0 = ymm0[11,12,13,14,15],zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,ymm0[27,28,29,30,31],zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero
; AVX2-NEXT:    vpmovzxbq {{.*#+}} ymm0 = xmm0[0],zero,zero,zero,zero,zero,zero,zero,xmm0[1],zero,zero,zero,zero,zero,zero,zero,xmm0[2],zero,zero,zero,zero,zero,zero,zero,xmm0[3],zero,zero,zero,zero,zero,zero,zero
; AVX2-NEXT:    retq
entry:
  %B = shufflevector <16 x i8> %A, <16 x i8> zeroinitializer, <32 x i32> <i32 11, i32 16, i32 16, i32 16, i32 16, i32 16, i32 16, i32 16, i32 12, i32 16, i32 16, i32 16, i32 16, i32 16, i32 16, i32 16, i32 13, i32 16, i32 16, i32 16, i32 16, i32 16, i32 16, i32 16, i32 14, i32 16, i32 16, i32 16, i32 16, i32 16, i32 16, i32 16>
  %Z = bitcast <32 x i8> %B to <4 x i64>
  ret <4 x i64> %Z
}

define <2 x i64> @shuf_zext_8i16_to_2i64_offset6(<8 x i16> %A) nounwind uwtable readnone ssp {
; SSE2-LABEL: shuf_zext_8i16_to_2i64_offset6:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    psrldq {{.*#+}} xmm0 = xmm0[2,3,4,5,6,7,8,9,10,11,12,13,14,15],zero,zero
; SSE2-NEXT:    pxor %xmm1, %xmm1
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3]
; SSE2-NEXT:    punpckhdq {{.*#+}} xmm0 = xmm0[2],xmm1[2],xmm0[3],xmm1[3]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuf_zext_8i16_to_2i64_offset6:
; SSSE3:       # BB#0: # %entry
; SSSE3-NEXT:    psrldq {{.*#+}} xmm0 = xmm0[2,3,4,5,6,7,8,9,10,11,12,13,14,15],zero,zero
; SSSE3-NEXT:    pxor %xmm1, %xmm1
; SSSE3-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3]
; SSSE3-NEXT:    punpckhdq {{.*#+}} xmm0 = xmm0[2],xmm1[2],xmm0[3],xmm1[3]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuf_zext_8i16_to_2i64_offset6:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    psrldq {{.*#+}} xmm0 = xmm0[6,7,8,9,10,11,12,13,14,15],zero,zero,zero,zero,zero,zero
; SSE41-NEXT:    pmovzxwq {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,xmm0[1],zero,zero,zero
; SSE41-NEXT:    retq
;
; AVX-LABEL: shuf_zext_8i16_to_2i64_offset6:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpsrldq {{.*#+}} xmm0 = xmm0[6,7,8,9,10,11,12,13,14,15],zero,zero,zero,zero,zero,zero
; AVX-NEXT:    vpmovzxwq {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,xmm0[1],zero,zero,zero
; AVX-NEXT:    retq
entry:
  %B = shufflevector <8 x i16> %A, <8 x i16> zeroinitializer, <8 x i32> <i32 3, i32 8, i32 8, i32 8, i32 4, i32 8, i32 8, i32 8>
  %Z = bitcast <8 x i16> %B to <2 x i64>
  ret <2 x i64> %Z
}

define <4 x i64> @shuf_zext_8i16_to_4i64_offset2(<8 x i16> %A) nounwind uwtable readnone ssp {
; SSE2-LABEL: shuf_zext_8i16_to_4i64_offset2:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm0, %xmm1
; SSE2-NEXT:    pxor %xmm2, %xmm2
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1],xmm0[2],xmm2[2],xmm0[3],xmm2[3]
; SSE2-NEXT:    punpckhdq {{.*#+}} xmm0 = xmm0[2],xmm2[2],xmm0[3],xmm2[3]
; SSE2-NEXT:    punpckhwd {{.*#+}} xmm1 = xmm1[4],xmm2[4],xmm1[5],xmm2[5],xmm1[6],xmm2[6],xmm1[7],xmm2[7]
; SSE2-NEXT:    punpckldq {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuf_zext_8i16_to_4i64_offset2:
; SSSE3:       # BB#0: # %entry
; SSSE3-NEXT:    movdqa %xmm0, %xmm1
; SSSE3-NEXT:    pxor %xmm2, %xmm2
; SSSE3-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1],xmm0[2],xmm2[2],xmm0[3],xmm2[3]
; SSSE3-NEXT:    punpckhdq {{.*#+}} xmm0 = xmm0[2],xmm2[2],xmm0[3],xmm2[3]
; SSSE3-NEXT:    punpckhwd {{.*#+}} xmm1 = xmm1[4],xmm2[4],xmm1[5],xmm2[5],xmm1[6],xmm2[6],xmm1[7],xmm2[7]
; SSSE3-NEXT:    punpckldq {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuf_zext_8i16_to_4i64_offset2:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    pshufd {{.*#+}} xmm1 = xmm0[1,1,2,3]
; SSE41-NEXT:    pmovzxwq {{.*#+}} xmm2 = xmm1[0],zero,zero,zero,xmm1[1],zero,zero,zero
; SSE41-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[2,3,0,1]
; SSE41-NEXT:    pmovzxwq {{.*#+}} xmm1 = xmm0[0],zero,zero,zero,xmm0[1],zero,zero,zero
; SSE41-NEXT:    movdqa %xmm2, %xmm0
; SSE41-NEXT:    retq
;
; AVX1-LABEL: shuf_zext_8i16_to_4i64_offset2:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vpshufd {{.*#+}} xmm1 = xmm0[1,1,2,3]
; AVX1-NEXT:    vpmovzxwq {{.*#+}} xmm1 = xmm1[0],zero,zero,zero,xmm1[1],zero,zero,zero
; AVX1-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[2,3,0,1]
; AVX1-NEXT:    vpmovzxwq {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,xmm0[1],zero,zero,zero
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm1, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: shuf_zext_8i16_to_4i64_offset2:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpshufd {{.*#+}} ymm0 = ymm0[1,2,2,3,5,6,6,7]
; AVX2-NEXT:    vpmovzxwq {{.*#+}} ymm0 = xmm0[0],zero,zero,zero,xmm0[1],zero,zero,zero,xmm0[2],zero,zero,zero,xmm0[3],zero,zero,zero
; AVX2-NEXT:    retq
entry:
  %B = shufflevector <8 x i16> %A, <8 x i16> zeroinitializer, <16 x i32> <i32 2, i32 8, i32 8, i32 8, i32 3, i32 8, i32 8, i32 8, i32 4, i32 8, i32 8, i32 8, i32 5, i32 8, i32 8, i32 8>
  %Z = bitcast <16 x i16> %B to <4 x i64>
  ret <4 x i64> %Z
}

define <4 x i32> @shuf_zext_8i16_to_4i32_offset1(<8 x i16> %A) nounwind uwtable readnone ssp {
; SSE-LABEL: shuf_zext_8i16_to_4i32_offset1:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    psrldq {{.*#+}} xmm0 = xmm0[2,3,4,5,6,7,8,9,10,11,12,13,14,15],zero,zero
; SSE-NEXT:    pxor %xmm1, %xmm1
; SSE-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3]
; SSE-NEXT:    retq
;
; AVX-LABEL: shuf_zext_8i16_to_4i32_offset1:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpsrldq {{.*#+}} xmm0 = xmm0[2,3,4,5,6,7,8,9,10,11,12,13,14,15],zero,zero
; AVX-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX-NEXT:    vpunpcklwd {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3]
; AVX-NEXT:    retq
entry:
  %B = shufflevector <8 x i16> %A, <8 x i16> zeroinitializer, <8 x i32> <i32 1, i32 8, i32 2, i32 8, i32 3, i32 8, i32 4, i32 8>
  %Z = bitcast <8 x i16> %B to <4 x i32>
  ret <4 x i32> %Z
}

define <8 x i32> @shuf_zext_8i16_to_8i32_offset3(<8 x i16> %A) nounwind uwtable readnone ssp {
; SSE2-LABEL: shuf_zext_8i16_to_8i32_offset3:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm0, %xmm1
; SSE2-NEXT:    psrldq {{.*#+}} xmm0 = xmm0[6,7,8,9,10,11,12,13,14,15],zero,zero,zero,zero,zero,zero
; SSE2-NEXT:    pxor %xmm2, %xmm2
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1],xmm0[2],xmm2[2],xmm0[3],xmm2[3]
; SSE2-NEXT:    psrldq {{.*#+}} xmm1 = xmm1[14,15],zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuf_zext_8i16_to_8i32_offset3:
; SSSE3:       # BB#0: # %entry
; SSSE3-NEXT:    movdqa %xmm0, %xmm1
; SSSE3-NEXT:    psrldq {{.*#+}} xmm0 = xmm0[6,7,8,9,10,11,12,13,14,15],zero,zero,zero,zero,zero,zero
; SSSE3-NEXT:    pxor %xmm2, %xmm2
; SSSE3-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1],xmm0[2],xmm2[2],xmm0[3],xmm2[3]
; SSSE3-NEXT:    psrldq {{.*#+}} xmm1 = xmm1[14,15],zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuf_zext_8i16_to_8i32_offset3:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    movdqa %xmm0, %xmm1
; SSE41-NEXT:    pslldq {{.*#+}} xmm0 = zero,zero,xmm0[0,1,2,3,4,5,6,7,8,9,10,11,12,13]
; SSE41-NEXT:    pxor %xmm2, %xmm2
; SSE41-NEXT:    punpckhwd {{.*#+}} xmm0 = xmm0[4],xmm2[4],xmm0[5],xmm2[5],xmm0[6],xmm2[6],xmm0[7],xmm2[7]
; SSE41-NEXT:    psrldq {{.*#+}} xmm1 = xmm1[14,15],zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero
; SSE41-NEXT:    retq
;
; AVX1-LABEL: shuf_zext_8i16_to_8i32_offset3:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vpslldq {{.*#+}} xmm1 = zero,zero,xmm0[0,1,2,3,4,5,6,7,8,9,10,11,12,13]
; AVX1-NEXT:    vpxor %xmm2, %xmm2, %xmm2
; AVX1-NEXT:    vpunpckhwd {{.*#+}} xmm1 = xmm1[4],xmm2[4],xmm1[5],xmm2[5],xmm1[6],xmm2[6],xmm1[7],xmm2[7]
; AVX1-NEXT:    vpsrldq {{.*#+}} xmm0 = xmm0[14,15],zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm1, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: shuf_zext_8i16_to_8i32_offset3:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpsrldq {{.*#+}} ymm0 = ymm0[6,7,8,9,10,11,12,13,14,15],zero,zero,zero,zero,zero,zero,ymm0[22,23,24,25,26,27,28,29,30,31],zero,zero,zero,zero,zero,zero
; AVX2-NEXT:    vpmovzxwd {{.*#+}} ymm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero,xmm0[4],zero,xmm0[5],zero,xmm0[6],zero,xmm0[7],zero
; AVX2-NEXT:    retq
entry:
  %B = shufflevector <8 x i16> %A, <8 x i16> zeroinitializer, <16 x i32> <i32 3, i32 8, i32 4, i32 8, i32 5, i32 8, i32 6, i32 8, i32 7, i32 8, i32 undef, i32 8, i32 undef, i32 8, i32 undef, i32 8>
  %Z = bitcast <16 x i16> %B to <8 x i32>
  ret <8 x i32> %Z
}

define <8 x i32> @shuf_zext_16i16_to_8i32_offset8(<16 x i16> %A) nounwind uwtable readnone ssp {
; SSE2-LABEL: shuf_zext_16i16_to_8i32_offset8:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    pxor %xmm2, %xmm2
; SSE2-NEXT:    movdqa %xmm1, %xmm0
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1],xmm0[2],xmm2[2],xmm0[3],xmm2[3]
; SSE2-NEXT:    punpckhwd {{.*#+}} xmm1 = xmm1[4],xmm2[4],xmm1[5],xmm2[5],xmm1[6],xmm2[6],xmm1[7],xmm2[7]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuf_zext_16i16_to_8i32_offset8:
; SSSE3:       # BB#0: # %entry
; SSSE3-NEXT:    pxor %xmm2, %xmm2
; SSSE3-NEXT:    movdqa %xmm1, %xmm0
; SSSE3-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1],xmm0[2],xmm2[2],xmm0[3],xmm2[3]
; SSSE3-NEXT:    punpckhwd {{.*#+}} xmm1 = xmm1[4],xmm2[4],xmm1[5],xmm2[5],xmm1[6],xmm2[6],xmm1[7],xmm2[7]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuf_zext_16i16_to_8i32_offset8:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    pshufd {{.*#+}} xmm0 = xmm1[2,2,3,3]
; SSE41-NEXT:    pxor %xmm2, %xmm2
; SSE41-NEXT:    pblendw {{.*#+}} xmm2 = xmm0[0],xmm2[1,2,3],xmm0[4],xmm2[5,6,7]
; SSE41-NEXT:    pmovzxwd {{.*#+}} xmm0 = xmm1[0],zero,xmm1[1],zero,xmm1[2],zero,xmm1[3],zero
; SSE41-NEXT:    movdqa %xmm2, %xmm1
; SSE41-NEXT:    retq
;
; AVX1-LABEL: shuf_zext_16i16_to_8i32_offset8:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm0
; AVX1-NEXT:    vpshufd {{.*#+}} xmm1 = xmm0[2,2,3,3]
; AVX1-NEXT:    vpxor %xmm2, %xmm2, %xmm2
; AVX1-NEXT:    vpblendw {{.*#+}} xmm1 = xmm1[0],xmm2[1,2,3],xmm1[4],xmm2[5,6,7]
; AVX1-NEXT:    vpmovzxwd {{.*#+}} xmm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero
; AVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: shuf_zext_16i16_to_8i32_offset8:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vperm2i128 {{.*#+}} ymm0 = ymm0[2,3,0,1]
; AVX2-NEXT:    vpmovzxwd {{.*#+}} ymm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero,xmm0[4],zero,xmm0[5],zero,xmm0[6],zero,xmm0[7],zero
; AVX2-NEXT:    retq
entry:
  %B = shufflevector <16 x i16> %A, <16 x i16> zeroinitializer, <16 x i32> <i32 8, i32 16, i32 9, i32 16, i32 10, i32 16, i32 11, i32 16, i32 12, i32 16, i32 undef, i32 16, i32 14, i32 16, i32 undef, i32 16>
  %Z = bitcast <16 x i16> %B to <8 x i32>
  ret <8 x i32> %Z
}

define <2 x i64> @shuf_zext_4i32_to_2i64_offset2(<4 x i32> %A) nounwind uwtable readnone ssp {
; SSE-LABEL: shuf_zext_4i32_to_2i64_offset2:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    pxor %xmm1, %xmm1
; SSE-NEXT:    punpckhdq {{.*#+}} xmm0 = xmm0[2],xmm1[2],xmm0[3],xmm1[3]
; SSE-NEXT:    retq
;
; AVX-LABEL: shuf_zext_4i32_to_2i64_offset2:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX-NEXT:    vpunpckhdq {{.*#+}} xmm0 = xmm0[2],xmm1[2],xmm0[3],xmm1[3]
; AVX-NEXT:    retq
entry:
  %B = shufflevector <4 x i32> %A, <4 x i32> zeroinitializer, <4 x i32> <i32 2, i32 4, i32 3, i32 4>
  %Z = bitcast <4 x i32> %B to <2 x i64>
  ret <2 x i64> %Z
}

define <4 x i64> @shuf_zext_4i32_to_4i64_offset1(<4 x i32> %A) nounwind uwtable readnone ssp {
; SSE2-LABEL: shuf_zext_4i32_to_4i64_offset1:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm0, %xmm1
; SSE2-NEXT:    movdqa {{.*#+}} xmm0 = [0,0,4294967295,0]
; SSE2-NEXT:    pand %xmm1, %xmm0
; SSE2-NEXT:    psrldq {{.*#+}} xmm1 = xmm1[12,13,14,15],zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuf_zext_4i32_to_4i64_offset1:
; SSSE3:       # BB#0: # %entry
; SSSE3-NEXT:    movdqa %xmm0, %xmm1
; SSSE3-NEXT:    movdqa {{.*#+}} xmm0 = [0,0,4294967295,0]
; SSSE3-NEXT:    pand %xmm1, %xmm0
; SSSE3-NEXT:    psrldq {{.*#+}} xmm1 = xmm1[12,13,14,15],zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuf_zext_4i32_to_4i64_offset1:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    movdqa %xmm0, %xmm1
; SSE41-NEXT:    pxor %xmm0, %xmm0
; SSE41-NEXT:    pblendw {{.*#+}} xmm0 = xmm0[0,1,2,3],xmm1[4,5],xmm0[6,7]
; SSE41-NEXT:    psrldq {{.*#+}} xmm1 = xmm1[12,13,14,15],zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero
; SSE41-NEXT:    retq
;
; AVX1-LABEL: shuf_zext_4i32_to_4i64_offset1:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vinsertps {{.*#+}} xmm1 = xmm0[3],zero,zero,zero
; AVX1-NEXT:    vxorps %xmm2, %xmm2, %xmm2
; AVX1-NEXT:    vblendps {{.*#+}} xmm0 = xmm2[0,1],xmm0[2],xmm2[3]
; AVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: shuf_zext_4i32_to_4i64_offset1:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpshufd {{.*#+}} ymm0 = ymm0[1,2,3,3,5,6,7,7]
; AVX2-NEXT:    vpmovzxdq {{.*#+}} ymm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero
; AVX2-NEXT:    retq
entry:
  %B = shufflevector <4 x i32> %A, <4 x i32> zeroinitializer, <8 x i32> <i32 undef, i32 4, i32 2, i32 4, i32 3, i32 4, i32 undef, i32 4>
  %Z = bitcast <8 x i32> %B to <4 x i64>
  ret <4 x i64> %Z
}
