; RUN: llc < %s -fast-isel -mtriple=i386-unknown-unknown -mattr=ssse3 | FileCheck %s --check-prefix=ALL  --check-prefix=X32
; RUN: llc < %s -fast-isel -mtriple=x86_64-unknown-unknown -mattr=ssse3 | FileCheck %s --check-prefix=ALL  --check-prefix=X64

; NOTE: This should use IR equivalent to what is generated by clang/test/CodeGen/ssse3-builtins.c

define <2 x i64> @test_mm_abs_epi8(<2 x i64> %a0) {
; X32-LABEL: test_mm_abs_epi8:
; X32:       # BB#0:
; X32-NEXT:    pabsb %xmm0, %xmm0
; X32-NEXT:    retl
;
; X64-LABEL: test_mm_abs_epi8:
; X64:       # BB#0:
; X64-NEXT:    pabsb %xmm0, %xmm0
; X64-NEXT:    retq
  %arg = bitcast <2 x i64> %a0 to <16 x i8>
  %call = call <16 x i8> @llvm.x86.ssse3.pabs.b.128(<16 x i8> %arg)
  %res = bitcast <16 x i8> %call to <2 x i64>
  ret <2 x i64> %res
}
declare <16 x i8> @llvm.x86.ssse3.pabs.b.128(<16 x i8>) nounwind readnone

define <2 x i64> @test_mm_abs_epi16(<2 x i64> %a0) {
; X32-LABEL: test_mm_abs_epi16:
; X32:       # BB#0:
; X32-NEXT:    pabsw %xmm0, %xmm0
; X32-NEXT:    retl
;
; X64-LABEL: test_mm_abs_epi16:
; X64:       # BB#0:
; X64-NEXT:    pabsw %xmm0, %xmm0
; X64-NEXT:    retq
  %arg = bitcast <2 x i64> %a0 to <8 x i16>
  %call = call <8 x i16> @llvm.x86.ssse3.pabs.w.128(<8 x i16> %arg)
  %res = bitcast <8 x i16> %call to <2 x i64>
  ret <2 x i64> %res
}
declare <8 x i16> @llvm.x86.ssse3.pabs.w.128(<8 x i16>) nounwind readnone

define <2 x i64> @test_mm_abs_epi32(<2 x i64> %a0) {
; X32-LABEL: test_mm_abs_epi32:
; X32:       # BB#0:
; X32-NEXT:    pabsd %xmm0, %xmm0
; X32-NEXT:    retl
;
; X64-LABEL: test_mm_abs_epi32:
; X64:       # BB#0:
; X64-NEXT:    pabsd %xmm0, %xmm0
; X64-NEXT:    retq
  %arg = bitcast <2 x i64> %a0 to <4 x i32>
  %call = call <4 x i32> @llvm.x86.ssse3.pabs.d.128(<4 x i32> %arg)
  %res = bitcast <4 x i32> %call to <2 x i64>
  ret <2 x i64> %res
}
declare <4 x i32> @llvm.x86.ssse3.pabs.d.128(<4 x i32>) nounwind readnone

define <2 x i64> @test_mm_alignr_epi8(<2 x i64> %a0, <2 x i64> %a1) {
; X32-LABEL: test_mm_alignr_epi8:
; X32:       # BB#0:
; X32-NEXT:    palignr {{.*#}} xmm1 = xmm0[2,3,4,5,6,7,8,9,10,11,12,13,14,15],xmm1[0,1]
; X32-NEXT:    movdqa %xmm1, %xmm0
; X32-NEXT:    retl
;
; X64-LABEL: test_mm_alignr_epi8:
; X64:       # BB#0:
; X64-NEXT:    palignr {{.*#}} xmm1 = xmm0[2,3,4,5,6,7,8,9,10,11,12,13,14,15],xmm1[0,1]
; X64-NEXT:    movdqa %xmm1, %xmm0
; X64-NEXT:    retq
  %arg0 = bitcast <2 x i64> %a0 to <16 x i8>
  %arg1 = bitcast <2 x i64> %a1 to <16 x i8>
  %shuf = shufflevector <16 x i8> %arg0, <16 x i8> %arg1, <16 x i32> <i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 16, i32 17>
  %res = bitcast <16 x i8> %shuf to <2 x i64>
  ret <2 x i64> %res
}

define <2 x i64> @test_mm_hadd_epi16(<2 x i64> %a0, <2 x i64> %a1) {
; X32-LABEL: test_mm_hadd_epi16:
; X32:       # BB#0:
; X32-NEXT:    phaddw %xmm1, %xmm0
; X32-NEXT:    retl
;
; X64-LABEL: test_mm_hadd_epi16:
; X64:       # BB#0:
; X64-NEXT:    phaddw %xmm1, %xmm0
; X64-NEXT:    retq
  %arg0 = bitcast <2 x i64> %a0 to <8 x i16>
  %arg1 = bitcast <2 x i64> %a1 to <8 x i16>
  %call = call <8 x i16> @llvm.x86.ssse3.phadd.w.128(<8 x i16> %arg0, <8 x i16> %arg1)
  %res = bitcast <8 x i16> %call to <2 x i64>
  ret <2 x i64> %res
}
declare <8 x i16> @llvm.x86.ssse3.phadd.w.128(<8 x i16>, <8 x i16>) nounwind readnone

define <2 x i64> @test_mm_hadd_epi32(<2 x i64> %a0, <2 x i64> %a1) {
; X32-LABEL: test_mm_hadd_epi32:
; X32:       # BB#0:
; X32-NEXT:    phaddd %xmm1, %xmm0
; X32-NEXT:    retl
;
; X64-LABEL: test_mm_hadd_epi32:
; X64:       # BB#0:
; X64-NEXT:    phaddd %xmm1, %xmm0
; X64-NEXT:    retq
  %arg0 = bitcast <2 x i64> %a0 to <4 x i32>
  %arg1 = bitcast <2 x i64> %a1 to <4 x i32>
  %call = call <4 x i32> @llvm.x86.ssse3.phadd.d.128(<4 x i32> %arg0, <4 x i32> %arg1)
  %res = bitcast <4 x i32> %call to <2 x i64>
  ret <2 x i64> %res
}
declare <4 x i32> @llvm.x86.ssse3.phadd.d.128(<4 x i32>, <4 x i32>) nounwind readnone

define <2 x i64> @test_mm_hadds_epi16(<2 x i64> %a0, <2 x i64> %a1) {
; X32-LABEL: test_mm_hadds_epi16:
; X32:       # BB#0:
; X32-NEXT:    phaddsw %xmm1, %xmm0
; X32-NEXT:    retl
;
; X64-LABEL: test_mm_hadds_epi16:
; X64:       # BB#0:
; X64-NEXT:    phaddsw %xmm1, %xmm0
; X64-NEXT:    retq
  %arg0 = bitcast <2 x i64> %a0 to <8 x i16>
  %arg1 = bitcast <2 x i64> %a1 to <8 x i16>
  %call = call <8 x i16> @llvm.x86.ssse3.phadd.sw.128(<8 x i16> %arg0, <8 x i16> %arg1)
  %res = bitcast <8 x i16> %call to <2 x i64>
  ret <2 x i64> %res
}
declare <8 x i16> @llvm.x86.ssse3.phadd.sw.128(<8 x i16>, <8 x i16>) nounwind readnone

define <2 x i64> @test_mm_hsub_epi16(<2 x i64> %a0, <2 x i64> %a1) {
; X32-LABEL: test_mm_hsub_epi16:
; X32:       # BB#0:
; X32-NEXT:    phsubw %xmm1, %xmm0
; X32-NEXT:    retl
;
; X64-LABEL: test_mm_hsub_epi16:
; X64:       # BB#0:
; X64-NEXT:    phsubw %xmm1, %xmm0
; X64-NEXT:    retq
  %arg0 = bitcast <2 x i64> %a0 to <8 x i16>
  %arg1 = bitcast <2 x i64> %a1 to <8 x i16>
  %call = call <8 x i16> @llvm.x86.ssse3.phsub.w.128(<8 x i16> %arg0, <8 x i16> %arg1)
  %res = bitcast <8 x i16> %call to <2 x i64>
  ret <2 x i64> %res
}
declare <8 x i16> @llvm.x86.ssse3.phsub.w.128(<8 x i16>, <8 x i16>) nounwind readnone

define <2 x i64> @test_mm_hsub_epi32(<2 x i64> %a0, <2 x i64> %a1) {
; X32-LABEL: test_mm_hsub_epi32:
; X32:       # BB#0:
; X32-NEXT:    phsubd %xmm1, %xmm0
; X32-NEXT:    retl
;
; X64-LABEL: test_mm_hsub_epi32:
; X64:       # BB#0:
; X64-NEXT:    phsubd %xmm1, %xmm0
; X64-NEXT:    retq
  %arg0 = bitcast <2 x i64> %a0 to <4 x i32>
  %arg1 = bitcast <2 x i64> %a1 to <4 x i32>
  %call = call <4 x i32> @llvm.x86.ssse3.phsub.d.128(<4 x i32> %arg0, <4 x i32> %arg1)
  %res = bitcast <4 x i32> %call to <2 x i64>
  ret <2 x i64> %res
}
declare <4 x i32> @llvm.x86.ssse3.phsub.d.128(<4 x i32>, <4 x i32>) nounwind readnone

define <2 x i64> @test_mm_hsubs_epi16(<2 x i64> %a0, <2 x i64> %a1) {
; X32-LABEL: test_mm_hsubs_epi16:
; X32:       # BB#0:
; X32-NEXT:    phsubsw %xmm1, %xmm0
; X32-NEXT:    retl
;
; X64-LABEL: test_mm_hsubs_epi16:
; X64:       # BB#0:
; X64-NEXT:    phsubsw %xmm1, %xmm0
; X64-NEXT:    retq
  %arg0 = bitcast <2 x i64> %a0 to <8 x i16>
  %arg1 = bitcast <2 x i64> %a1 to <8 x i16>
  %call = call <8 x i16> @llvm.x86.ssse3.phsub.sw.128(<8 x i16> %arg0, <8 x i16> %arg1)
  %res = bitcast <8 x i16> %call to <2 x i64>
  ret <2 x i64> %res
}
declare <8 x i16> @llvm.x86.ssse3.phsub.sw.128(<8 x i16>, <8 x i16>) nounwind readnone

define <2 x i64> @test_mm_maddubs_epi16(<2 x i64> %a0, <2 x i64> %a1) {
; X32-LABEL: test_mm_maddubs_epi16:
; X32:       # BB#0:
; X32-NEXT:    pmaddubsw %xmm1, %xmm0
; X32-NEXT:    retl
;
; X64-LABEL: test_mm_maddubs_epi16:
; X64:       # BB#0:
; X64-NEXT:    pmaddubsw %xmm1, %xmm0
; X64-NEXT:    retq
  %arg0 = bitcast <2 x i64> %a0 to <16 x i8>
  %arg1 = bitcast <2 x i64> %a1 to <16 x i8>
  %call = call <8 x i16> @llvm.x86.ssse3.pmadd.ub.sw.128(<16 x i8> %arg0, <16 x i8> %arg1)
  %res = bitcast <8 x i16> %call to <2 x i64>
  ret <2 x i64> %res
}
declare <8 x i16> @llvm.x86.ssse3.pmadd.ub.sw.128(<16 x i8>, <16 x i8>) nounwind readnone

define <2 x i64> @test_mm_mulhrs_epi16(<2 x i64> %a0, <2 x i64> %a1) {
; X32-LABEL: test_mm_mulhrs_epi16:
; X32:       # BB#0:
; X32-NEXT:    pmulhrsw %xmm1, %xmm0
; X32-NEXT:    retl
;
; X64-LABEL: test_mm_mulhrs_epi16:
; X64:       # BB#0:
; X64-NEXT:    pmulhrsw %xmm1, %xmm0
; X64-NEXT:    retq
  %arg0 = bitcast <2 x i64> %a0 to <8 x i16>
  %arg1 = bitcast <2 x i64> %a1 to <8 x i16>
  %call = call <8 x i16> @llvm.x86.ssse3.pmul.hr.sw.128(<8 x i16> %arg0, <8 x i16> %arg1)
  %res = bitcast <8 x i16> %call to <2 x i64>
  ret <2 x i64> %res
}
declare <8 x i16> @llvm.x86.ssse3.pmul.hr.sw.128(<8 x i16>, <8 x i16>) nounwind readnone

define <2 x i64> @test_mm_shuffle_epi8(<2 x i64> %a0, <2 x i64> %a1) {
; X32-LABEL: test_mm_shuffle_epi8:
; X32:       # BB#0:
; X32-NEXT:    pshufb %xmm1, %xmm0
; X32-NEXT:    retl
;
; X64-LABEL: test_mm_shuffle_epi8:
; X64:       # BB#0:
; X64-NEXT:    pshufb %xmm1, %xmm0
; X64-NEXT:    retq
  %arg0 = bitcast <2 x i64> %a0 to <16 x i8>
  %arg1 = bitcast <2 x i64> %a1 to <16 x i8>
  %call = call <16 x i8> @llvm.x86.ssse3.pshuf.b.128(<16 x i8> %arg0, <16 x i8> %arg1)
  %res = bitcast <16 x i8> %call to <2 x i64>
  ret <2 x i64> %res
}
declare <16 x i8> @llvm.x86.ssse3.pshuf.b.128(<16 x i8>, <16 x i8>) nounwind readnone

define <2 x i64> @test_mm_sign_epi8(<2 x i64> %a0, <2 x i64> %a1) {
; X32-LABEL: test_mm_sign_epi8:
; X32:       # BB#0:
; X32-NEXT:    psignb %xmm1, %xmm0
; X32-NEXT:    retl
;
; X64-LABEL: test_mm_sign_epi8:
; X64:       # BB#0:
; X64-NEXT:    psignb %xmm1, %xmm0
; X64-NEXT:    retq
  %arg0 = bitcast <2 x i64> %a0 to <16 x i8>
  %arg1 = bitcast <2 x i64> %a1 to <16 x i8>
  %call = call <16 x i8> @llvm.x86.ssse3.psign.b.128(<16 x i8> %arg0, <16 x i8> %arg1)
  %res = bitcast <16 x i8> %call to <2 x i64>
  ret <2 x i64> %res
}
declare <16 x i8> @llvm.x86.ssse3.psign.b.128(<16 x i8>, <16 x i8>) nounwind readnone

define <2 x i64> @test_mm_sign_epi16(<2 x i64> %a0, <2 x i64> %a1) {
; X32-LABEL: test_mm_sign_epi16:
; X32:       # BB#0:
; X32-NEXT:    psignw %xmm1, %xmm0
; X32-NEXT:    retl
;
; X64-LABEL: test_mm_sign_epi16:
; X64:       # BB#0:
; X64-NEXT:    psignw %xmm1, %xmm0
; X64-NEXT:    retq
  %arg0 = bitcast <2 x i64> %a0 to <8 x i16>
  %arg1 = bitcast <2 x i64> %a1 to <8 x i16>
  %call = call <8 x i16> @llvm.x86.ssse3.psign.w.128(<8 x i16> %arg0, <8 x i16> %arg1)
  %res = bitcast <8 x i16> %call to <2 x i64>
  ret <2 x i64> %res
}
declare <8 x i16> @llvm.x86.ssse3.psign.w.128(<8 x i16>, <8 x i16>) nounwind readnone

define <2 x i64> @test_mm_sign_epi32(<2 x i64> %a0, <2 x i64> %a1) {
; X32-LABEL: test_mm_sign_epi32:
; X32:       # BB#0:
; X32-NEXT:    psignd %xmm1, %xmm0
; X32-NEXT:    retl
;
; X64-LABEL: test_mm_sign_epi32:
; X64:       # BB#0:
; X64-NEXT:    psignd %xmm1, %xmm0
; X64-NEXT:    retq
  %arg0 = bitcast <2 x i64> %a0 to <4 x i32>
  %arg1 = bitcast <2 x i64> %a1 to <4 x i32>
  %call = call <4 x i32> @llvm.x86.ssse3.psign.d.128(<4 x i32> %arg0, <4 x i32> %arg1)
  %res = bitcast <4 x i32> %call to <2 x i64>
  ret <2 x i64> %res
}
declare <4 x i32> @llvm.x86.ssse3.psign.d.128(<4 x i32>, <4 x i32>) nounwind readnone
