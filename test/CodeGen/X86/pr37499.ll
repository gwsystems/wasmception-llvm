; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-- -mattr=avx512vl | FileCheck %s

define <2 x i64> @foo() {
; CHECK-LABEL: foo:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vmovdqa {{.*#+}} xmm0 = [1,1,1,1,1,1,1,1]
; CHECK-NEXT:    movb $1, %al
; CHECK-NEXT:    kmovw %eax, %k1
; CHECK-NEXT:    vpcmpeqd %ymm1, %ymm1, %ymm1
; CHECK-NEXT:    vmovdqa32 %ymm1, %ymm1 {%k1} {z}
; CHECK-NEXT:    vpmovdw %ymm1, %xmm1
; CHECK-NEXT:    vpblendvb %xmm1, %xmm0, %xmm0, %xmm0
; CHECK-NEXT:    vzeroupper
; CHECK-NEXT:    retq
  %1 = tail call <8 x i16> @llvm.x86.avx512.mask.pmov.qw.512(<8 x i64> undef, <8 x i16> <i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1>, i8 1) #3
  %2 = bitcast <8 x i16> %1 to <2 x i64>
  ret <2 x i64> %2
}

define <4 x i64> @goo() {
; CHECK-LABEL: goo:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vmovdqa {{.*#+}} ymm0 = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
; CHECK-NEXT:    movw $1, %ax
; CHECK-NEXT:    kmovw %eax, %k1
; CHECK-NEXT:    vpternlogd $255, %zmm1, %zmm1, %zmm1 {%k1} {z}
; CHECK-NEXT:    vpmovdw %zmm1, %ymm1
; CHECK-NEXT:    vpblendvb %ymm1, %ymm0, %ymm0, %ymm0
; CHECK-NEXT:    retq
  %1 = tail call <16 x i16> @llvm.x86.avx512.mask.pmov.dw.512(<16 x i32> undef, <16 x i16> <i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1>, i16 1) #3
  %2 = bitcast <16 x i16> %1 to <4 x i64>
  ret <4 x i64> %2
}

declare <8 x i16> @llvm.x86.avx512.mask.pmov.qw.512(<8 x i64>, <8 x i16>, i8)
declare <16 x i16> @llvm.x86.avx512.mask.pmov.dw.512(<16 x i32>, <16 x i16>, i16)
