; RUN: llc < %s -mtriple=x86_64-unknown-unknown -march=x86-64 -mcpu=nehalem | FileCheck %s

define <4 x float> @a(<4 x float>* %y) nounwind {
; CHECK-LABEL: a:
; CHECK:       # BB#0:
; CHECK-NEXT:    movups (%rdi), %xmm0
; CHECK-NEXT:    shufps {{.*#+}} xmm0 = xmm0[3,2,1,0]
; CHECK-NEXT:    retq
  %x = load <4 x float>* %y, align 4
  %a = extractelement <4 x float> %x, i32 0
  %b = extractelement <4 x float> %x, i32 1
  %c = extractelement <4 x float> %x, i32 2
  %d = extractelement <4 x float> %x, i32 3
  %p = insertelement <4 x float> undef, float %d, i32 0
  %q = insertelement <4 x float> %p, float %c, i32 1
  %r = insertelement <4 x float> %q, float %b, i32 2
  %s = insertelement <4 x float> %r, float %a, i32 3
  ret <4 x float> %s
}

define <4 x float> @b(<4 x float>* %y, <4 x float> %z) nounwind {
; CHECK-LABEL: b:
; CHECK:       # BB#0:
; CHECK-NEXT:    movups (%rdi), %xmm1
; CHECK-NEXT:    unpckhps {{.*#+}} xmm0 = xmm0[2],xmm1[2],xmm0[3],xmm1[3]
; CHECK-NEXT:    retq
  %x = load <4 x float>* %y, align 4
  %a = extractelement <4 x float> %x, i32 2
  %b = extractelement <4 x float> %x, i32 3
  %c = extractelement <4 x float> %z, i32 2
  %d = extractelement <4 x float> %z, i32 3
  %p = insertelement <4 x float> undef, float %c, i32 0
  %q = insertelement <4 x float> %p, float %a, i32 1
  %r = insertelement <4 x float> %q, float %d, i32 2
  %s = insertelement <4 x float> %r, float %b, i32 3
  ret <4 x float> %s
}

define <2 x double> @c(<2 x double>* %y) nounwind {
; CHECK-LABEL: c:
; CHECK:       # BB#0:
; CHECK-NEXT:    movupd (%rdi), %xmm0
; CHECK-NEXT:    shufpd {{.*#+}} xmm0 = xmm0[1,0]
; CHECK-NEXT:    retq
  %x = load <2 x double>* %y, align 8
  %a = extractelement <2 x double> %x, i32 0
  %c = extractelement <2 x double> %x, i32 1
  %p = insertelement <2 x double> undef, double %c, i32 0
  %r = insertelement <2 x double> %p, double %a, i32 1
  ret <2 x double> %r
}

define <2 x double> @d(<2 x double>* %y, <2 x double> %z) nounwind {
; CHECK-LABEL: d:
; CHECK:       # BB#0:
; CHECK-NEXT:    movupd (%rdi), %xmm1
; CHECK-NEXT:    unpckhpd {{.*#+}} xmm0 = xmm0[1],xmm1[1]
; CHECK-NEXT:    retq
  %x = load <2 x double>* %y, align 8
  %a = extractelement <2 x double> %x, i32 1
  %c = extractelement <2 x double> %z, i32 1
  %p = insertelement <2 x double> undef, double %c, i32 0
  %r = insertelement <2 x double> %p, double %a, i32 1
  ret <2 x double> %r
}
