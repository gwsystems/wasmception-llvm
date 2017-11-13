; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=x86_64-unknown-unknown -mattr=+sse2 < %s | FileCheck %s --check-prefix=SSE
; RUN: llc -mtriple=x86_64-unknown-unknown -mattr=+avx < %s | FileCheck %s --check-prefix=AVX
; RUN: llc -mtriple=x86_64-unknown-unknown -mattr=+avx512f < %s | FileCheck %s --check-prefix=AVX

; Verify we fold loads into unary sse intrinsics only when optimizing for size

define float @rcpss(float* %a) {
; SSE-LABEL: rcpss:
; SSE:       # BB#0:
; SSE-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; SSE-NEXT:    rcpss %xmm0, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: rcpss:
; AVX:       # BB#0:
; AVX-NEXT:    vmovss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; AVX-NEXT:    vrcpss %xmm0, %xmm0, %xmm0
; AVX-NEXT:    retq
    %ld = load float, float* %a
    %ins = insertelement <4 x float> undef, float %ld, i32 0
    %res = tail call <4 x float> @llvm.x86.sse.rcp.ss(<4 x float> %ins)
    %ext = extractelement <4 x float> %res, i32 0
    ret float %ext
}

define float @rsqrtss(float* %a) {
; SSE-LABEL: rsqrtss:
; SSE:       # BB#0:
; SSE-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; SSE-NEXT:    rsqrtss %xmm0, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: rsqrtss:
; AVX:       # BB#0:
; AVX-NEXT:    vmovss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; AVX-NEXT:    vrsqrtss %xmm0, %xmm0, %xmm0
; AVX-NEXT:    retq
    %ld = load float, float* %a
    %ins = insertelement <4 x float> undef, float %ld, i32 0
    %res = tail call <4 x float> @llvm.x86.sse.rsqrt.ss(<4 x float> %ins)
    %ext = extractelement <4 x float> %res, i32 0
    ret float %ext
}

define float @sqrtss(float* %a) {
; SSE-LABEL: sqrtss:
; SSE:       # BB#0:
; SSE-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; SSE-NEXT:    sqrtss %xmm0, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: sqrtss:
; AVX:       # BB#0:
; AVX-NEXT:    vmovss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; AVX-NEXT:    vsqrtss %xmm0, %xmm0, %xmm0
; AVX-NEXT:    retq
    %ld = load float, float* %a
    %ins = insertelement <4 x float> undef, float %ld, i32 0
    %res = tail call <4 x float> @llvm.x86.sse.sqrt.ss(<4 x float> %ins)
    %ext = extractelement <4 x float> %res, i32 0
    ret float %ext
}

define double @sqrtsd(double* %a) {
; SSE-LABEL: sqrtsd:
; SSE:       # BB#0:
; SSE-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; SSE-NEXT:    sqrtsd %xmm0, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: sqrtsd:
; AVX:       # BB#0:
; AVX-NEXT:    vmovsd {{.*#+}} xmm0 = mem[0],zero
; AVX-NEXT:    vsqrtsd %xmm0, %xmm0, %xmm0
; AVX-NEXT:    retq
    %ld = load double, double* %a
    %ins = insertelement <2 x double> undef, double %ld, i32 0
    %res = tail call <2 x double> @llvm.x86.sse2.sqrt.sd(<2 x double> %ins)
    %ext = extractelement <2 x double> %res, i32 0
    ret double %ext
}

define float @rcpss_size(float* %a) optsize {
; SSE-LABEL: rcpss_size:
; SSE:       # BB#0:
; SSE-NEXT:    rcpss (%rdi), %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: rcpss_size:
; AVX:       # BB#0:
; AVX-NEXT:    vrcpss (%rdi), %xmm0, %xmm0
; AVX-NEXT:    retq
    %ld = load float, float* %a
    %ins = insertelement <4 x float> undef, float %ld, i32 0
    %res = tail call <4 x float> @llvm.x86.sse.rcp.ss(<4 x float> %ins)
    %ext = extractelement <4 x float> %res, i32 0
    ret float %ext
}

define <4 x float> @rcpss_full_size(<4 x float>* %a) optsize {
; SSE-LABEL: rcpss_full_size:
; SSE:       # BB#0:
; SSE-NEXT:    movaps (%rdi), %xmm0
; SSE-NEXT:    rcpss %xmm0, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: rcpss_full_size:
; AVX:       # BB#0:
; AVX-NEXT:    vmovaps (%rdi), %xmm0
; AVX-NEXT:    vrcpss %xmm0, %xmm0, %xmm0
; AVX-NEXT:    retq
    %ld = load <4 x float>, <4 x float>* %a
    %res = tail call <4 x float> @llvm.x86.sse.rcp.ss(<4 x float> %ld)
    ret <4 x float> %res
}

define float @rsqrtss_size(float* %a) optsize {
; SSE-LABEL: rsqrtss_size:
; SSE:       # BB#0:
; SSE-NEXT:    rsqrtss (%rdi), %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: rsqrtss_size:
; AVX:       # BB#0:
; AVX-NEXT:    vrsqrtss (%rdi), %xmm0, %xmm0
; AVX-NEXT:    retq
    %ld = load float, float* %a
    %ins = insertelement <4 x float> undef, float %ld, i32 0
    %res = tail call <4 x float> @llvm.x86.sse.rsqrt.ss(<4 x float> %ins)
    %ext = extractelement <4 x float> %res, i32 0
    ret float %ext
}

define <4 x float> @rsqrtss_full_size(<4 x float>* %a) optsize {
; SSE-LABEL: rsqrtss_full_size:
; SSE:       # BB#0:
; SSE-NEXT:    movaps (%rdi), %xmm0
; SSE-NEXT:    rsqrtss %xmm0, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: rsqrtss_full_size:
; AVX:       # BB#0:
; AVX-NEXT:    vmovaps (%rdi), %xmm0
; AVX-NEXT:    vrsqrtss %xmm0, %xmm0, %xmm0
; AVX-NEXT:    retq
    %ld = load <4 x float>, <4 x float>* %a
    %res = tail call <4 x float> @llvm.x86.sse.rsqrt.ss(<4 x float> %ld)
    ret <4 x float> %res
}

define float @sqrtss_size(float* %a) optsize{
; SSE-LABEL: sqrtss_size:
; SSE:       # BB#0:
; SSE-NEXT:    sqrtss (%rdi), %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: sqrtss_size:
; AVX:       # BB#0:
; AVX-NEXT:    vsqrtss (%rdi), %xmm0, %xmm0
; AVX-NEXT:    retq
    %ld = load float, float* %a
    %ins = insertelement <4 x float> undef, float %ld, i32 0
    %res = tail call <4 x float> @llvm.x86.sse.sqrt.ss(<4 x float> %ins)
    %ext = extractelement <4 x float> %res, i32 0
    ret float %ext
}

define <4 x float> @sqrtss_full_size(<4 x float>* %a) optsize{
; SSE-LABEL: sqrtss_full_size:
; SSE:       # BB#0:
; SSE-NEXT:    movaps (%rdi), %xmm0
; SSE-NEXT:    sqrtss %xmm0, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: sqrtss_full_size:
; AVX:       # BB#0:
; AVX-NEXT:    vmovaps (%rdi), %xmm0
; AVX-NEXT:    vsqrtss %xmm0, %xmm0, %xmm0
; AVX-NEXT:    retq
    %ld = load <4 x float>, <4 x float>* %a
    %res = tail call <4 x float> @llvm.x86.sse.sqrt.ss(<4 x float> %ld)
    ret <4 x float> %res
}

define double @sqrtsd_size(double* %a) optsize {
; SSE-LABEL: sqrtsd_size:
; SSE:       # BB#0:
; SSE-NEXT:    sqrtsd (%rdi), %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: sqrtsd_size:
; AVX:       # BB#0:
; AVX-NEXT:    vsqrtsd (%rdi), %xmm0, %xmm0
; AVX-NEXT:    retq
    %ld = load double, double* %a
    %ins = insertelement <2 x double> undef, double %ld, i32 0
    %res = tail call <2 x double> @llvm.x86.sse2.sqrt.sd(<2 x double> %ins)
    %ext = extractelement <2 x double> %res, i32 0
    ret double %ext
}

define <2 x double> @sqrtsd_full_size(<2 x double>* %a) optsize {
; SSE-LABEL: sqrtsd_full_size:
; SSE:       # BB#0:
; SSE-NEXT:    movapd (%rdi), %xmm0
; SSE-NEXT:    sqrtsd %xmm0, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: sqrtsd_full_size:
; AVX:       # BB#0:
; AVX-NEXT:    vmovapd (%rdi), %xmm0
; AVX-NEXT:    vsqrtsd %xmm0, %xmm0, %xmm0
; AVX-NEXT:    retq
    %ld = load <2 x double>, <2 x double>* %a
    %res = tail call <2 x double> @llvm.x86.sse2.sqrt.sd(<2 x double> %ld)
    ret <2 x double> %res
}

declare <4 x float> @llvm.x86.sse.rcp.ss(<4 x float>) nounwind readnone
declare <4 x float> @llvm.x86.sse.rsqrt.ss(<4 x float>) nounwind readnone
declare <4 x float> @llvm.x86.sse.sqrt.ss(<4 x float>) nounwind readnone
declare <2 x double> @llvm.x86.sse2.sqrt.sd(<2 x double>) nounwind readnone
