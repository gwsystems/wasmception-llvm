; RUN: llc -mtriple=x86_64-unknown-unknown -mattr=+sse2 < %s | FileCheck %s --check-prefix=SSE
; RUN: llc -mtriple=x86_64-unknown-unknown -mattr=+avx < %s | FileCheck %s --check-prefix=AVX

; Verify that we're folding the load into the math instruction.
; This pattern is generated out of the simplest intrinsics usage:
;  _mm_add_ss(a, _mm_load_ss(b));

define <4 x float> @addss(<4 x float> %va, float* %pb) {
; SSE-LABEL: addss:
; SSE:       # BB#0:
; SSE-NEXT:    addss (%rdi), %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: addss:
; AVX:       # BB#0:
; AVX-NEXT:    vaddss (%rdi), %xmm0, %xmm0
; AVX-NEXT:    retq
    %a = extractelement <4 x float> %va, i32 0
    %b = load float, float* %pb
    %r = fadd float %a, %b
    %vr = insertelement <4 x float> %va, float %r, i32 0
    ret <4 x float> %vr
}

define <2 x double> @addsd(<2 x double> %va, double* %pb) {
; SSE-LABEL: addsd:
; SSE:       # BB#0:
; SSE-NEXT:    addsd (%rdi), %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: addsd:
; AVX:       # BB#0:
; AVX-NEXT:    vaddsd (%rdi), %xmm0, %xmm0
; AVX-NEXT:    retq
    %a = extractelement <2 x double> %va, i32 0
    %b = load double, double* %pb
    %r = fadd double %a, %b
    %vr = insertelement <2 x double> %va, double %r, i32 0
    ret <2 x double> %vr
}

define <4 x float> @subss(<4 x float> %va, float* %pb) {
; SSE-LABEL: subss:
; SSE:       # BB#0:
; SSE-NEXT:    subss (%rdi), %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: subss:
; AVX:       # BB#0:
; AVX-NEXT:    vsubss (%rdi), %xmm0, %xmm0
; AVX-NEXT:    retq
    %a = extractelement <4 x float> %va, i32 0
    %b = load float, float* %pb
    %r = fsub float %a, %b
    %vr = insertelement <4 x float> %va, float %r, i32 0
    ret <4 x float> %vr
}

define <2 x double> @subsd(<2 x double> %va, double* %pb) {
; SSE-LABEL: subsd:
; SSE:       # BB#0:
; SSE-NEXT:    subsd (%rdi), %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: subsd:
; AVX:       # BB#0:
; AVX-NEXT:    vsubsd (%rdi), %xmm0, %xmm0
; AVX-NEXT:    retq
    %a = extractelement <2 x double> %va, i32 0
    %b = load double, double* %pb
    %r = fsub double %a, %b
    %vr = insertelement <2 x double> %va, double %r, i32 0
    ret <2 x double> %vr
}

define <4 x float> @mulss(<4 x float> %va, float* %pb) {
; SSE-LABEL: mulss:
; SSE:       # BB#0:
; SSE-NEXT:    mulss (%rdi), %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: mulss:
; AVX:       # BB#0:
; AVX-NEXT:    vmulss (%rdi), %xmm0, %xmm0
; AVX-NEXT:    retq
    %a = extractelement <4 x float> %va, i32 0
    %b = load float, float* %pb
    %r = fmul float %a, %b
    %vr = insertelement <4 x float> %va, float %r, i32 0
    ret <4 x float> %vr
}

define <2 x double> @mulsd(<2 x double> %va, double* %pb) {
; SSE-LABEL: mulsd:
; SSE:       # BB#0:
; SSE-NEXT:    mulsd (%rdi), %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: mulsd:
; AVX:       # BB#0:
; AVX-NEXT:    vmulsd (%rdi), %xmm0, %xmm0
; AVX-NEXT:    retq
    %a = extractelement <2 x double> %va, i32 0
    %b = load double, double* %pb
    %r = fmul double %a, %b
    %vr = insertelement <2 x double> %va, double %r, i32 0
    ret <2 x double> %vr
}

define <4 x float> @divss(<4 x float> %va, float* %pb) {
; SSE-LABEL: divss:
; SSE:       # BB#0:
; SSE-NEXT:    divss (%rdi), %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: divss:
; AVX:       # BB#0:
; AVX-NEXT:    vdivss (%rdi), %xmm0, %xmm0
; AVX-NEXT:    retq
    %a = extractelement <4 x float> %va, i32 0
    %b = load float, float* %pb
    %r = fdiv float %a, %b
    %vr = insertelement <4 x float> %va, float %r, i32 0
    ret <4 x float> %vr
}

define <2 x double> @divsd(<2 x double> %va, double* %pb) {
; SSE-LABEL: divsd:
; SSE:       # BB#0:
; SSE-NEXT:    divsd (%rdi), %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: divsd:
; AVX:       # BB#0:
; AVX-NEXT:    vdivsd (%rdi), %xmm0, %xmm0
; AVX-NEXT:    retq
    %a = extractelement <2 x double> %va, i32 0
    %b = load double, double* %pb
    %r = fdiv double %a, %b
    %vr = insertelement <2 x double> %va, double %r, i32 0
    ret <2 x double> %vr
}
