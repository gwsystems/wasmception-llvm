; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=avx | FileCheck %s

; Check that we generate vector conversion from float to narrower int types

%f32vec_t = type <8 x float>
%i16vec_t = type <8 x i16>
%i8vec_t =  type <8 x i8>

define void @fptoui16(%f32vec_t %a, %i16vec_t *%p) {
; CHECK-LABEL: fptoui16:
; CHECK:       # BB#0:
; CHECK-NEXT:    vcvttps2dq %ymm0, %ymm0
; CHECK-NEXT:    vextractf128 $1, %ymm0, %xmm1
; CHECK-NEXT:    vmovdqa {{.*#+}} xmm2 = [0,1,4,5,8,9,12,13,8,9,12,13,12,13,14,15]
; CHECK-NEXT:    vpshufb %xmm2, %xmm1, %xmm1
; CHECK-NEXT:    vpshufb %xmm2, %xmm0, %xmm0
; CHECK-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; CHECK-NEXT:    vmovdqa %xmm0, (%rdi)
; CHECK-NEXT:    vzeroupper
; CHECK-NEXT:    retq
  %b = fptoui %f32vec_t %a to %i16vec_t
  store %i16vec_t %b, %i16vec_t * %p
  ret void
}

define void @fptosi16(%f32vec_t %a, %i16vec_t *%p) {
; CHECK-LABEL: fptosi16:
; CHECK:       # BB#0:
; CHECK-NEXT:    vcvttps2dq %ymm0, %ymm0
; CHECK-NEXT:    vextractf128 $1, %ymm0, %xmm1
; CHECK-NEXT:    vmovdqa {{.*#+}} xmm2 = [0,1,4,5,8,9,12,13,8,9,12,13,12,13,14,15]
; CHECK-NEXT:    vpshufb %xmm2, %xmm1, %xmm1
; CHECK-NEXT:    vpshufb %xmm2, %xmm0, %xmm0
; CHECK-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; CHECK-NEXT:    vmovdqa %xmm0, (%rdi)
; CHECK-NEXT:    vzeroupper
; CHECK-NEXT:    retq
  %b = fptosi %f32vec_t %a to %i16vec_t
  store %i16vec_t %b, %i16vec_t * %p
  ret void
}

define void @fptoui8(%f32vec_t %a, %i8vec_t *%p) {
; CHECK-LABEL: fptoui8:
; CHECK:       # BB#0:
; CHECK-NEXT:    vcvttps2dq %ymm0, %ymm0
; CHECK-NEXT:    vextractf128 $1, %ymm0, %xmm1
; CHECK-NEXT:    vmovdqa {{.*#+}} xmm2 = [0,1,4,5,8,9,12,13,8,9,12,13,12,13,14,15]
; CHECK-NEXT:    vpshufb %xmm2, %xmm1, %xmm1
; CHECK-NEXT:    vpshufb %xmm2, %xmm0, %xmm0
; CHECK-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; CHECK-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,2,4,6,8,10,12,14,u,u,u,u,u,u,u,u]
; CHECK-NEXT:    vmovq %xmm0, (%rdi)
; CHECK-NEXT:    vzeroupper
; CHECK-NEXT:    retq
  %b = fptoui %f32vec_t %a to %i8vec_t
  store %i8vec_t %b, %i8vec_t * %p
  ret void
}

define void @fptosi8(%f32vec_t %a, %i8vec_t *%p) {
; CHECK-LABEL: fptosi8:
; CHECK:       # BB#0:
; CHECK-NEXT:    vcvttps2dq %ymm0, %ymm0
; CHECK-NEXT:    vextractf128 $1, %ymm0, %xmm1
; CHECK-NEXT:    vmovdqa {{.*#+}} xmm2 = [0,1,4,5,8,9,12,13,8,9,12,13,12,13,14,15]
; CHECK-NEXT:    vpshufb %xmm2, %xmm1, %xmm1
; CHECK-NEXT:    vpshufb %xmm2, %xmm0, %xmm0
; CHECK-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; CHECK-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,2,4,6,8,10,12,14,u,u,u,u,u,u,u,u]
; CHECK-NEXT:    vmovq %xmm0, (%rdi)
; CHECK-NEXT:    vzeroupper
; CHECK-NEXT:    retq
  %b = fptosi %f32vec_t %a to %i8vec_t
  store %i8vec_t %b, %i8vec_t * %p
  ret void
}
