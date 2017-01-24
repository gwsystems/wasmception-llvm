; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=avx2 | FileCheck %s

define <16 x i16> @foo(<16 x i1> %mask, <16 x i16> %x, <16 x i16> %y) {
; CHECK-LABEL: foo:
; CHECK:       # BB#0:
; CHECK-NEXT:    vpmovzxbw {{.*#+}} ymm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero,xmm0[4],zero,xmm0[5],zero,xmm0[6],zero,xmm0[7],zero,xmm0[8],zero,xmm0[9],zero,xmm0[10],zero,xmm0[11],zero,xmm0[12],zero,xmm0[13],zero,xmm0[14],zero,xmm0[15],zero
; CHECK-NEXT:    vpsllw $15, %ymm0, %ymm0
; CHECK-NEXT:    vpsraw $15, %ymm0, %ymm0
; CHECK-NEXT:    vpblendvb %ymm0, %ymm1, %ymm2, %ymm0
; CHECK-NEXT:    retq
  %ret = select <16 x i1> %mask, <16 x i16> %x, <16 x i16> %y
  ret <16 x i16> %ret
}

