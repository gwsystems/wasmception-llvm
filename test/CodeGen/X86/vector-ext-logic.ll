; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-- -mattr=+sse2 | FileCheck %s --check-prefixes=ALL,SSE2
; RUN: llc < %s -mtriple=x86_64-- -mattr=+avx2 | FileCheck %s --check-prefixes=ALL,AVX2

define <8 x i32> @zext_and_v8i32(<8 x i16> %x, <8 x i16> %y) {
; SSE2-LABEL: zext_and_v8i32:
; SSE2:       # %bb.0:
; SSE2-NEXT:    movdqa %xmm0, %xmm2
; SSE2-NEXT:    pand %xmm1, %xmm2
; SSE2-NEXT:    pxor %xmm1, %xmm1
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3]
; SSE2-NEXT:    punpckhwd {{.*#+}} xmm2 = xmm2[4],xmm1[4],xmm2[5],xmm1[5],xmm2[6],xmm1[6],xmm2[7],xmm1[7]
; SSE2-NEXT:    movdqa %xmm2, %xmm1
; SSE2-NEXT:    retq
;
; AVX2-LABEL: zext_and_v8i32:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vpmovzxwd {{.*#+}} ymm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero,xmm0[4],zero,xmm0[5],zero,xmm0[6],zero,xmm0[7],zero
; AVX2-NEXT:    retq
  %xz = zext <8 x i16> %x to <8 x i32>
  %yz = zext <8 x i16> %y to <8 x i32>
  %r = and <8 x i32> %xz, %yz
  ret <8 x i32> %r
}

define <8 x i32> @zext_or_v8i32(<8 x i16> %x, <8 x i16> %y) {
; SSE2-LABEL: zext_or_v8i32:
; SSE2:       # %bb.0:
; SSE2-NEXT:    movdqa %xmm0, %xmm2
; SSE2-NEXT:    por %xmm1, %xmm2
; SSE2-NEXT:    pxor %xmm1, %xmm1
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3]
; SSE2-NEXT:    punpckhwd {{.*#+}} xmm2 = xmm2[4],xmm1[4],xmm2[5],xmm1[5],xmm2[6],xmm1[6],xmm2[7],xmm1[7]
; SSE2-NEXT:    movdqa %xmm2, %xmm1
; SSE2-NEXT:    retq
;
; AVX2-LABEL: zext_or_v8i32:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpor %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vpmovzxwd {{.*#+}} ymm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero,xmm0[4],zero,xmm0[5],zero,xmm0[6],zero,xmm0[7],zero
; AVX2-NEXT:    retq
  %xz = zext <8 x i16> %x to <8 x i32>
  %yz = zext <8 x i16> %y to <8 x i32>
  %r = or <8 x i32> %xz, %yz
  ret <8 x i32> %r
}

define <8 x i32> @zext_xor_v8i32(<8 x i16> %x, <8 x i16> %y) {
; SSE2-LABEL: zext_xor_v8i32:
; SSE2:       # %bb.0:
; SSE2-NEXT:    movdqa %xmm0, %xmm2
; SSE2-NEXT:    pxor %xmm1, %xmm2
; SSE2-NEXT:    pxor %xmm1, %xmm1
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3]
; SSE2-NEXT:    punpckhwd {{.*#+}} xmm2 = xmm2[4],xmm1[4],xmm2[5],xmm1[5],xmm2[6],xmm1[6],xmm2[7],xmm1[7]
; SSE2-NEXT:    movdqa %xmm2, %xmm1
; SSE2-NEXT:    retq
;
; AVX2-LABEL: zext_xor_v8i32:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpxor %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vpmovzxwd {{.*#+}} ymm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero,xmm0[4],zero,xmm0[5],zero,xmm0[6],zero,xmm0[7],zero
; AVX2-NEXT:    retq
  %xz = zext <8 x i16> %x to <8 x i32>
  %yz = zext <8 x i16> %y to <8 x i32>
  %r = xor <8 x i32> %xz, %yz
  ret <8 x i32> %r
}

define <8 x i32> @sext_and_v8i32(<8 x i16> %x, <8 x i16> %y) {
; SSE2-LABEL: sext_and_v8i32:
; SSE2:       # %bb.0:
; SSE2-NEXT:    pand %xmm1, %xmm0
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm2 = xmm2[0],xmm0[0],xmm2[1],xmm0[1],xmm2[2],xmm0[2],xmm2[3],xmm0[3]
; SSE2-NEXT:    psrad $16, %xmm2
; SSE2-NEXT:    punpckhwd {{.*#+}} xmm1 = xmm1[4],xmm0[4],xmm1[5],xmm0[5],xmm1[6],xmm0[6],xmm1[7],xmm0[7]
; SSE2-NEXT:    psrad $16, %xmm1
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; AVX2-LABEL: sext_and_v8i32:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vpmovsxwd %xmm0, %ymm0
; AVX2-NEXT:    retq
  %xs = sext <8 x i16> %x to <8 x i32>
  %ys = sext <8 x i16> %y to <8 x i32>
  %r = and <8 x i32> %xs, %ys
  ret <8 x i32> %r
}

define <8 x i32> @sext_or_v8i32(<8 x i16> %x, <8 x i16> %y) {
; SSE2-LABEL: sext_or_v8i32:
; SSE2:       # %bb.0:
; SSE2-NEXT:    por %xmm1, %xmm0
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm2 = xmm2[0],xmm0[0],xmm2[1],xmm0[1],xmm2[2],xmm0[2],xmm2[3],xmm0[3]
; SSE2-NEXT:    psrad $16, %xmm2
; SSE2-NEXT:    punpckhwd {{.*#+}} xmm1 = xmm1[4],xmm0[4],xmm1[5],xmm0[5],xmm1[6],xmm0[6],xmm1[7],xmm0[7]
; SSE2-NEXT:    psrad $16, %xmm1
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; AVX2-LABEL: sext_or_v8i32:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpor %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vpmovsxwd %xmm0, %ymm0
; AVX2-NEXT:    retq
  %xs = sext <8 x i16> %x to <8 x i32>
  %ys = sext <8 x i16> %y to <8 x i32>
  %r = or <8 x i32> %xs, %ys
  ret <8 x i32> %r
}

define <8 x i32> @sext_xor_v8i32(<8 x i16> %x, <8 x i16> %y) {
; SSE2-LABEL: sext_xor_v8i32:
; SSE2:       # %bb.0:
; SSE2-NEXT:    pxor %xmm1, %xmm0
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm2 = xmm2[0],xmm0[0],xmm2[1],xmm0[1],xmm2[2],xmm0[2],xmm2[3],xmm0[3]
; SSE2-NEXT:    psrad $16, %xmm2
; SSE2-NEXT:    punpckhwd {{.*#+}} xmm1 = xmm1[4],xmm0[4],xmm1[5],xmm0[5],xmm1[6],xmm0[6],xmm1[7],xmm0[7]
; SSE2-NEXT:    psrad $16, %xmm1
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; AVX2-LABEL: sext_xor_v8i32:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpxor %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vpmovsxwd %xmm0, %ymm0
; AVX2-NEXT:    retq
  %xs = sext <8 x i16> %x to <8 x i32>
  %ys = sext <8 x i16> %y to <8 x i32>
  %r = xor <8 x i32> %xs, %ys
  ret <8 x i32> %r
}

define <8 x i16> @zext_and_v8i16(<8 x i8> %x, <8 x i8> %y) {
; SSE2-LABEL: zext_and_v8i16:
; SSE2:       # %bb.0:
; SSE2-NEXT:    andps %xmm1, %xmm0
; SSE2-NEXT:    andps {{.*}}(%rip), %xmm0
; SSE2-NEXT:    retq
;
; AVX2-LABEL: zext_and_v8i16:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vandps %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vandps {{.*}}(%rip), %xmm0, %xmm0
; AVX2-NEXT:    retq
  %xz = zext <8 x i8> %x to <8 x i16>
  %yz = zext <8 x i8> %y to <8 x i16>
  %r = and <8 x i16> %xz, %yz
  ret <8 x i16> %r
}

define <8 x i16> @zext_or_v8i16(<8 x i8> %x, <8 x i8> %y) {
; SSE2-LABEL: zext_or_v8i16:
; SSE2:       # %bb.0:
; SSE2-NEXT:    orps %xmm1, %xmm0
; SSE2-NEXT:    andps {{.*}}(%rip), %xmm0
; SSE2-NEXT:    retq
;
; AVX2-LABEL: zext_or_v8i16:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vorps %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vandps {{.*}}(%rip), %xmm0, %xmm0
; AVX2-NEXT:    retq
  %xz = zext <8 x i8> %x to <8 x i16>
  %yz = zext <8 x i8> %y to <8 x i16>
  %r = or <8 x i16> %xz, %yz
  ret <8 x i16> %r
}

define <8 x i16> @zext_xor_v8i16(<8 x i8> %x, <8 x i8> %y) {
; SSE2-LABEL: zext_xor_v8i16:
; SSE2:       # %bb.0:
; SSE2-NEXT:    xorps %xmm1, %xmm0
; SSE2-NEXT:    andps {{.*}}(%rip), %xmm0
; SSE2-NEXT:    retq
;
; AVX2-LABEL: zext_xor_v8i16:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vxorps %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vandps {{.*}}(%rip), %xmm0, %xmm0
; AVX2-NEXT:    retq
  %xz = zext <8 x i8> %x to <8 x i16>
  %yz = zext <8 x i8> %y to <8 x i16>
  %r = xor <8 x i16> %xz, %yz
  ret <8 x i16> %r
}

define <8 x i16> @sext_and_v8i16(<8 x i8> %x, <8 x i8> %y) {
; SSE2-LABEL: sext_and_v8i16:
; SSE2:       # %bb.0:
; SSE2-NEXT:    psllw $8, %xmm0
; SSE2-NEXT:    psraw $8, %xmm0
; SSE2-NEXT:    psllw $8, %xmm1
; SSE2-NEXT:    psraw $8, %xmm1
; SSE2-NEXT:    pand %xmm1, %xmm0
; SSE2-NEXT:    retq
;
; AVX2-LABEL: sext_and_v8i16:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpsllw $8, %xmm0, %xmm0
; AVX2-NEXT:    vpsraw $8, %xmm0, %xmm0
; AVX2-NEXT:    vpsllw $8, %xmm1, %xmm1
; AVX2-NEXT:    vpsraw $8, %xmm1, %xmm1
; AVX2-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    retq
  %xs = sext <8 x i8> %x to <8 x i16>
  %ys = sext <8 x i8> %y to <8 x i16>
  %r = and <8 x i16> %xs, %ys
  ret <8 x i16> %r
}

define <8 x i16> @sext_or_v8i16(<8 x i8> %x, <8 x i8> %y) {
; SSE2-LABEL: sext_or_v8i16:
; SSE2:       # %bb.0:
; SSE2-NEXT:    psllw $8, %xmm0
; SSE2-NEXT:    psraw $8, %xmm0
; SSE2-NEXT:    psllw $8, %xmm1
; SSE2-NEXT:    psraw $8, %xmm1
; SSE2-NEXT:    por %xmm1, %xmm0
; SSE2-NEXT:    retq
;
; AVX2-LABEL: sext_or_v8i16:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpsllw $8, %xmm0, %xmm0
; AVX2-NEXT:    vpsraw $8, %xmm0, %xmm0
; AVX2-NEXT:    vpsllw $8, %xmm1, %xmm1
; AVX2-NEXT:    vpsraw $8, %xmm1, %xmm1
; AVX2-NEXT:    vpor %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    retq
  %xs = sext <8 x i8> %x to <8 x i16>
  %ys = sext <8 x i8> %y to <8 x i16>
  %r = or <8 x i16> %xs, %ys
  ret <8 x i16> %r
}

define <8 x i16> @sext_xor_v8i16(<8 x i8> %x, <8 x i8> %y) {
; SSE2-LABEL: sext_xor_v8i16:
; SSE2:       # %bb.0:
; SSE2-NEXT:    psllw $8, %xmm0
; SSE2-NEXT:    psraw $8, %xmm0
; SSE2-NEXT:    psllw $8, %xmm1
; SSE2-NEXT:    psraw $8, %xmm1
; SSE2-NEXT:    pxor %xmm1, %xmm0
; SSE2-NEXT:    retq
;
; AVX2-LABEL: sext_xor_v8i16:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpsllw $8, %xmm0, %xmm0
; AVX2-NEXT:    vpsraw $8, %xmm0, %xmm0
; AVX2-NEXT:    vpsllw $8, %xmm1, %xmm1
; AVX2-NEXT:    vpsraw $8, %xmm1, %xmm1
; AVX2-NEXT:    vpxor %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    retq
  %xs = sext <8 x i8> %x to <8 x i16>
  %ys = sext <8 x i8> %y to <8 x i16>
  %r = xor <8 x i16> %xs, %ys
  ret <8 x i16> %r
}

define <8 x i32> @bool_zext_and(<8 x i1> %x, <8 x i1> %y) {
; SSE2-LABEL: bool_zext_and:
; SSE2:       # %bb.0:
; SSE2-NEXT:    movdqa %xmm0, %xmm3
; SSE2-NEXT:    punpckhwd {{.*#+}} xmm3 = xmm3[4],xmm0[4],xmm3[5],xmm0[5],xmm3[6],xmm0[6],xmm3[7],xmm0[7]
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3]
; SSE2-NEXT:    pand {{.*}}(%rip), %xmm1
; SSE2-NEXT:    pxor %xmm4, %xmm4
; SSE2-NEXT:    movdqa %xmm1, %xmm2
; SSE2-NEXT:    punpckhwd {{.*#+}} xmm2 = xmm2[4],xmm4[4],xmm2[5],xmm4[5],xmm2[6],xmm4[6],xmm2[7],xmm4[7]
; SSE2-NEXT:    pand %xmm3, %xmm2
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm1 = xmm1[0],xmm4[0],xmm1[1],xmm4[1],xmm1[2],xmm4[2],xmm1[3],xmm4[3]
; SSE2-NEXT:    pand %xmm1, %xmm0
; SSE2-NEXT:    movdqa %xmm2, %xmm1
; SSE2-NEXT:    retq
;
; AVX2-LABEL: bool_zext_and:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpmovzxwd {{.*#+}} ymm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero,xmm0[4],zero,xmm0[5],zero,xmm0[6],zero,xmm0[7],zero
; AVX2-NEXT:    vpand {{.*}}(%rip), %xmm1, %xmm1
; AVX2-NEXT:    vpmovzxwd {{.*#+}} ymm1 = xmm1[0],zero,xmm1[1],zero,xmm1[2],zero,xmm1[3],zero,xmm1[4],zero,xmm1[5],zero,xmm1[6],zero,xmm1[7],zero
; AVX2-NEXT:    vpand %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
  %xz = zext <8 x i1> %x to <8 x i32>
  %yz = zext <8 x i1> %y to <8 x i32>
  %r = and <8 x i32> %xz, %yz
  ret <8 x i32> %r
}

define <8 x i32> @bool_zext_or(<8 x i1> %x, <8 x i1> %y) {
; SSE2-LABEL: bool_zext_or:
; SSE2:       # %bb.0:
; SSE2-NEXT:    movdqa {{.*#+}} xmm2 = [1,1,1,1,1,1,1,1]
; SSE2-NEXT:    pand %xmm2, %xmm0
; SSE2-NEXT:    pxor %xmm3, %xmm3
; SSE2-NEXT:    movdqa %xmm0, %xmm4
; SSE2-NEXT:    punpckhwd {{.*#+}} xmm4 = xmm4[4],xmm3[4],xmm4[5],xmm3[5],xmm4[6],xmm3[6],xmm4[7],xmm3[7]
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm3[0],xmm0[1],xmm3[1],xmm0[2],xmm3[2],xmm0[3],xmm3[3]
; SSE2-NEXT:    pand %xmm2, %xmm1
; SSE2-NEXT:    movdqa %xmm1, %xmm2
; SSE2-NEXT:    punpckhwd {{.*#+}} xmm2 = xmm2[4],xmm3[4],xmm2[5],xmm3[5],xmm2[6],xmm3[6],xmm2[7],xmm3[7]
; SSE2-NEXT:    por %xmm4, %xmm2
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm1 = xmm1[0],xmm3[0],xmm1[1],xmm3[1],xmm1[2],xmm3[2],xmm1[3],xmm3[3]
; SSE2-NEXT:    por %xmm1, %xmm0
; SSE2-NEXT:    movdqa %xmm2, %xmm1
; SSE2-NEXT:    retq
;
; AVX2-LABEL: bool_zext_or:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpor %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vpand {{.*}}(%rip), %xmm0, %xmm0
; AVX2-NEXT:    vpmovzxwd {{.*#+}} ymm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero,xmm0[4],zero,xmm0[5],zero,xmm0[6],zero,xmm0[7],zero
; AVX2-NEXT:    retq
  %xz = zext <8 x i1> %x to <8 x i32>
  %yz = zext <8 x i1> %y to <8 x i32>
  %r = or <8 x i32> %xz, %yz
  ret <8 x i32> %r
}

define <8 x i32> @bool_zext_xor(<8 x i1> %x, <8 x i1> %y) {
; SSE2-LABEL: bool_zext_xor:
; SSE2:       # %bb.0:
; SSE2-NEXT:    movdqa {{.*#+}} xmm2 = [1,1,1,1,1,1,1,1]
; SSE2-NEXT:    pand %xmm2, %xmm0
; SSE2-NEXT:    pxor %xmm3, %xmm3
; SSE2-NEXT:    movdqa %xmm0, %xmm4
; SSE2-NEXT:    punpckhwd {{.*#+}} xmm4 = xmm4[4],xmm3[4],xmm4[5],xmm3[5],xmm4[6],xmm3[6],xmm4[7],xmm3[7]
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm3[0],xmm0[1],xmm3[1],xmm0[2],xmm3[2],xmm0[3],xmm3[3]
; SSE2-NEXT:    pand %xmm2, %xmm1
; SSE2-NEXT:    movdqa %xmm1, %xmm2
; SSE2-NEXT:    punpckhwd {{.*#+}} xmm2 = xmm2[4],xmm3[4],xmm2[5],xmm3[5],xmm2[6],xmm3[6],xmm2[7],xmm3[7]
; SSE2-NEXT:    pxor %xmm4, %xmm2
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm1 = xmm1[0],xmm3[0],xmm1[1],xmm3[1],xmm1[2],xmm3[2],xmm1[3],xmm3[3]
; SSE2-NEXT:    pxor %xmm1, %xmm0
; SSE2-NEXT:    movdqa %xmm2, %xmm1
; SSE2-NEXT:    retq
;
; AVX2-LABEL: bool_zext_xor:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpxor %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vpand {{.*}}(%rip), %xmm0, %xmm0
; AVX2-NEXT:    vpmovzxwd {{.*#+}} ymm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero,xmm0[4],zero,xmm0[5],zero,xmm0[6],zero,xmm0[7],zero
; AVX2-NEXT:    retq
  %xz = zext <8 x i1> %x to <8 x i32>
  %yz = zext <8 x i1> %y to <8 x i32>
  %r = xor <8 x i32> %xz, %yz
  ret <8 x i32> %r
}

define <8 x i32> @bool_sext_and(<8 x i1> %x, <8 x i1> %y) {
; SSE2-LABEL: bool_sext_and:
; SSE2:       # %bb.0:
; SSE2-NEXT:    movdqa %xmm1, %xmm3
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm3 = xmm3[0],xmm0[0],xmm3[1],xmm0[1],xmm3[2],xmm0[2],xmm3[3],xmm0[3]
; SSE2-NEXT:    punpckhwd {{.*#+}} xmm1 = xmm1[4],xmm0[4],xmm1[5],xmm0[5],xmm1[6],xmm0[6],xmm1[7],xmm0[7]
; SSE2-NEXT:    movdqa %xmm0, %xmm2
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm2 = xmm2[0],xmm0[0],xmm2[1],xmm0[1],xmm2[2],xmm0[2],xmm2[3],xmm0[3]
; SSE2-NEXT:    punpckhwd {{.*#+}} xmm0 = xmm0[4,4,5,5,6,6,7,7]
; SSE2-NEXT:    pslld $31, %xmm0
; SSE2-NEXT:    psrad $31, %xmm0
; SSE2-NEXT:    pslld $31, %xmm2
; SSE2-NEXT:    psrad $31, %xmm2
; SSE2-NEXT:    pslld $31, %xmm1
; SSE2-NEXT:    psrad $31, %xmm1
; SSE2-NEXT:    pand %xmm0, %xmm1
; SSE2-NEXT:    pslld $31, %xmm3
; SSE2-NEXT:    psrad $31, %xmm3
; SSE2-NEXT:    pand %xmm3, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; AVX2-LABEL: bool_sext_and:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpmovzxwd {{.*#+}} ymm1 = xmm1[0],zero,xmm1[1],zero,xmm1[2],zero,xmm1[3],zero,xmm1[4],zero,xmm1[5],zero,xmm1[6],zero,xmm1[7],zero
; AVX2-NEXT:    vpmovzxwd {{.*#+}} ymm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero,xmm0[4],zero,xmm0[5],zero,xmm0[6],zero,xmm0[7],zero
; AVX2-NEXT:    vpslld $31, %ymm0, %ymm0
; AVX2-NEXT:    vpsrad $31, %ymm0, %ymm0
; AVX2-NEXT:    vpslld $31, %ymm1, %ymm1
; AVX2-NEXT:    vpsrad $31, %ymm1, %ymm1
; AVX2-NEXT:    vpand %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
  %xs = sext <8 x i1> %x to <8 x i32>
  %ys = sext <8 x i1> %y to <8 x i32>
  %r = and <8 x i32> %xs, %ys
  ret <8 x i32> %r
}

define <8 x i32> @bool_sext_or(<8 x i1> %x, <8 x i1> %y) {
; SSE2-LABEL: bool_sext_or:
; SSE2:       # %bb.0:
; SSE2-NEXT:    movdqa %xmm1, %xmm3
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm3 = xmm3[0],xmm0[0],xmm3[1],xmm0[1],xmm3[2],xmm0[2],xmm3[3],xmm0[3]
; SSE2-NEXT:    punpckhwd {{.*#+}} xmm1 = xmm1[4],xmm0[4],xmm1[5],xmm0[5],xmm1[6],xmm0[6],xmm1[7],xmm0[7]
; SSE2-NEXT:    movdqa %xmm0, %xmm2
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm2 = xmm2[0],xmm0[0],xmm2[1],xmm0[1],xmm2[2],xmm0[2],xmm2[3],xmm0[3]
; SSE2-NEXT:    punpckhwd {{.*#+}} xmm0 = xmm0[4,4,5,5,6,6,7,7]
; SSE2-NEXT:    pslld $31, %xmm0
; SSE2-NEXT:    psrad $31, %xmm0
; SSE2-NEXT:    pslld $31, %xmm2
; SSE2-NEXT:    psrad $31, %xmm2
; SSE2-NEXT:    pslld $31, %xmm1
; SSE2-NEXT:    psrad $31, %xmm1
; SSE2-NEXT:    por %xmm0, %xmm1
; SSE2-NEXT:    pslld $31, %xmm3
; SSE2-NEXT:    psrad $31, %xmm3
; SSE2-NEXT:    por %xmm3, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; AVX2-LABEL: bool_sext_or:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpmovzxwd {{.*#+}} ymm1 = xmm1[0],zero,xmm1[1],zero,xmm1[2],zero,xmm1[3],zero,xmm1[4],zero,xmm1[5],zero,xmm1[6],zero,xmm1[7],zero
; AVX2-NEXT:    vpmovzxwd {{.*#+}} ymm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero,xmm0[4],zero,xmm0[5],zero,xmm0[6],zero,xmm0[7],zero
; AVX2-NEXT:    vpslld $31, %ymm0, %ymm0
; AVX2-NEXT:    vpsrad $31, %ymm0, %ymm0
; AVX2-NEXT:    vpslld $31, %ymm1, %ymm1
; AVX2-NEXT:    vpsrad $31, %ymm1, %ymm1
; AVX2-NEXT:    vpor %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
  %xs = sext <8 x i1> %x to <8 x i32>
  %ys = sext <8 x i1> %y to <8 x i32>
  %r = or <8 x i32> %xs, %ys
  ret <8 x i32> %r
}

define <8 x i32> @bool_sext_xor(<8 x i1> %x, <8 x i1> %y) {
; SSE2-LABEL: bool_sext_xor:
; SSE2:       # %bb.0:
; SSE2-NEXT:    movdqa %xmm1, %xmm3
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm3 = xmm3[0],xmm0[0],xmm3[1],xmm0[1],xmm3[2],xmm0[2],xmm3[3],xmm0[3]
; SSE2-NEXT:    punpckhwd {{.*#+}} xmm1 = xmm1[4],xmm0[4],xmm1[5],xmm0[5],xmm1[6],xmm0[6],xmm1[7],xmm0[7]
; SSE2-NEXT:    movdqa %xmm0, %xmm2
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm2 = xmm2[0],xmm0[0],xmm2[1],xmm0[1],xmm2[2],xmm0[2],xmm2[3],xmm0[3]
; SSE2-NEXT:    punpckhwd {{.*#+}} xmm0 = xmm0[4,4,5,5,6,6,7,7]
; SSE2-NEXT:    pslld $31, %xmm0
; SSE2-NEXT:    psrad $31, %xmm0
; SSE2-NEXT:    pslld $31, %xmm2
; SSE2-NEXT:    psrad $31, %xmm2
; SSE2-NEXT:    pslld $31, %xmm1
; SSE2-NEXT:    psrad $31, %xmm1
; SSE2-NEXT:    pxor %xmm0, %xmm1
; SSE2-NEXT:    pslld $31, %xmm3
; SSE2-NEXT:    psrad $31, %xmm3
; SSE2-NEXT:    pxor %xmm3, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; AVX2-LABEL: bool_sext_xor:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpmovzxwd {{.*#+}} ymm1 = xmm1[0],zero,xmm1[1],zero,xmm1[2],zero,xmm1[3],zero,xmm1[4],zero,xmm1[5],zero,xmm1[6],zero,xmm1[7],zero
; AVX2-NEXT:    vpmovzxwd {{.*#+}} ymm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero,xmm0[4],zero,xmm0[5],zero,xmm0[6],zero,xmm0[7],zero
; AVX2-NEXT:    vpslld $31, %ymm0, %ymm0
; AVX2-NEXT:    vpsrad $31, %ymm0, %ymm0
; AVX2-NEXT:    vpslld $31, %ymm1, %ymm1
; AVX2-NEXT:    vpsrad $31, %ymm1, %ymm1
; AVX2-NEXT:    vpxor %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
  %xs = sext <8 x i1> %x to <8 x i32>
  %ys = sext <8 x i1> %y to <8 x i32>
  %r = xor <8 x i32> %xs, %ys
  ret <8 x i32> %r
}

