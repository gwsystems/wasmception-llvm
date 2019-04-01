; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown | FileCheck %s

;
; fcmp oeq
;

define <2 x i64> @fcmp_oeq_v2f64() {
; CHECK-LABEL: fcmp_oeq_v2f64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    pcmpeqd %xmm0, %xmm0
; CHECK-NEXT:    retq
  %1 = fcmp oeq <2 x double> <double 0x3FF0000000000000, double 0xFFEFFFFFFFFFFFFF>, <double 0x3FF0000000000000, double 0xFFEFFFFFFFFFFFFF>
  %2 = sext <2 x i1> %1 to <2 x i64>
  ret <2 x i64> %2
}

define <2 x i64> @fcmp_oeq_v2f64_undef() {
; CHECK-LABEL: fcmp_oeq_v2f64_undef:
; CHECK:       # %bb.0:
; CHECK-NEXT:    cmpeqpd {{.*}}(%rip), %xmm0
; CHECK-NEXT:    retq
  %1 = fcmp oeq <2 x double> <double 0x3FF0000000000000, double 0xFFEFFFFFFFFFFFFF>, undef
  %2 = sext <2 x i1> %1 to <2 x i64>
  ret <2 x i64> %2
}

define <2 x i64> @fcmp_oeq_v2f64_undef_elt() {
; CHECK-LABEL: fcmp_oeq_v2f64_undef_elt:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movapd {{.*#+}} xmm0 = <u,1.0E+0>
; CHECK-NEXT:    cmpeqpd {{.*}}(%rip), %xmm0
; CHECK-NEXT:    retq
  %1 = fcmp oeq <2 x double> <double 0x3FF0000000000000, double 0xFFEFFFFFFFFFFFFF>, <double undef, double 0x3FF0000000000000>
  %2 = sext <2 x i1> %1 to <2 x i64>
  ret <2 x i64> %2
}

define <4 x i32> @fcmp_oeq_v4f32() {
; CHECK-LABEL: fcmp_oeq_v4f32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    pcmpeqd %xmm0, %xmm0
; CHECK-NEXT:    retq
  %1 = fcmp oeq <4 x float> <float -0.0, float 1.0, float -1.0, float +2.0>, <float +0.0, float 1.0, float -1.0, float +2.0>
  %2 = sext <4 x i1> %1 to <4 x i32>
  ret <4 x i32> %2
}

define <4 x i32> @fcmp_oeq_v4f32_undef() {
; CHECK-LABEL: fcmp_oeq_v4f32_undef:
; CHECK:       # %bb.0:
; CHECK-NEXT:    cmpeqps {{.*}}(%rip), %xmm0
; CHECK-NEXT:    retq
  %1 = fcmp oeq <4 x float> <float 1.0, float -1.0, float +2.0, float -0.0>, undef
  %2 = sext <4 x i1> %1 to <4 x i32>
  ret <4 x i32> %2
}

define <4 x i32> @fcmp_oeq_v4f32_undef_elt() {
; CHECK-LABEL: fcmp_oeq_v4f32_undef_elt:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movaps {{.*#+}} xmm0 = <u,1.0E+0,-1.0E+0,2.0E+0>
; CHECK-NEXT:    cmpeqps {{.*}}(%rip), %xmm0
; CHECK-NEXT:    retq
  %1 = fcmp oeq <4 x float> <float -0.0, float 1.0, float -1.0, float undef>, <float undef, float 1.0, float -1.0, float +2.0>
  %2 = sext <4 x i1> %1 to <4 x i32>
  ret <4 x i32> %2
}

;
; fcmp ueq
;

define <2 x i64> @fcmp_ueq_v2f64() {
; CHECK-LABEL: fcmp_ueq_v2f64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    pcmpeqd %xmm0, %xmm0
; CHECK-NEXT:    retq
  %1 = fcmp ueq <2 x double> <double 0x3FF0000000000000, double 0xFFEFFFFFFFFFFFFF>, <double 0x3FF0000000000000, double 0xFFEFFFFFFFFFFFFF>
  %2 = sext <2 x i1> %1 to <2 x i64>
  ret <2 x i64> %2
}

define <2 x i64> @fcmp_ueq_v2f64_undef() {
; CHECK-LABEL: fcmp_ueq_v2f64_undef:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movapd {{.*#+}} xmm0 = [1.0E+0,-1.7976931348623157E+308]
; CHECK-NEXT:    movapd %xmm0, %xmm1
; CHECK-NEXT:    cmpeqpd %xmm0, %xmm1
; CHECK-NEXT:    cmpunordpd %xmm0, %xmm0
; CHECK-NEXT:    orpd %xmm1, %xmm0
; CHECK-NEXT:    retq
  %1 = fcmp ueq <2 x double> <double 0x3FF0000000000000, double 0xFFEFFFFFFFFFFFFF>, undef
  %2 = sext <2 x i1> %1 to <2 x i64>
  ret <2 x i64> %2
}

define <2 x i64> @fcmp_ueq_v2f64_undef_elt() {
; CHECK-LABEL: fcmp_ueq_v2f64_undef_elt:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movapd {{.*#+}} xmm1 = <u,1.0E+0>
; CHECK-NEXT:    movapd {{.*#+}} xmm0 = [1.0E+0,-1.7976931348623157E+308]
; CHECK-NEXT:    movapd %xmm0, %xmm2
; CHECK-NEXT:    cmpeqpd %xmm1, %xmm2
; CHECK-NEXT:    cmpunordpd %xmm1, %xmm0
; CHECK-NEXT:    orpd %xmm2, %xmm0
; CHECK-NEXT:    retq
  %1 = fcmp ueq <2 x double> <double 0x3FF0000000000000, double 0xFFEFFFFFFFFFFFFF>, <double undef, double 0x3FF0000000000000>
  %2 = sext <2 x i1> %1 to <2 x i64>
  ret <2 x i64> %2
}

define <4 x i32> @fcmp_ueq_v4f32() {
; CHECK-LABEL: fcmp_ueq_v4f32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    pcmpeqd %xmm0, %xmm0
; CHECK-NEXT:    retq
  %1 = fcmp ueq <4 x float> <float -0.0, float 1.0, float -1.0, float +2.0>, <float +0.0, float 1.0, float -1.0, float +2.0>
  %2 = sext <4 x i1> %1 to <4 x i32>
  ret <4 x i32> %2
}

define <4 x i32> @fcmp_ueq_v4f32_undef() {
; CHECK-LABEL: fcmp_ueq_v4f32_undef:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movaps {{.*#+}} xmm0 = [1.0E+0,-1.0E+0,2.0E+0,-0.0E+0]
; CHECK-NEXT:    movaps %xmm0, %xmm1
; CHECK-NEXT:    cmpeqps %xmm0, %xmm1
; CHECK-NEXT:    cmpunordps %xmm0, %xmm0
; CHECK-NEXT:    orps %xmm1, %xmm0
; CHECK-NEXT:    retq
  %1 = fcmp ueq <4 x float> <float 1.0, float -1.0, float +2.0, float -0.0>, undef
  %2 = sext <4 x i1> %1 to <4 x i32>
  ret <4 x i32> %2
}

define <4 x i32> @fcmp_ueq_v4f32_undef_elt() {
; CHECK-LABEL: fcmp_ueq_v4f32_undef_elt:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movaps {{.*#+}} xmm1 = <u,1.0E+0,-1.0E+0,2.0E+0>
; CHECK-NEXT:    movaps {{.*#+}} xmm0 = <-0.0E+0,1.0E+0,-1.0E+0,u>
; CHECK-NEXT:    movaps %xmm0, %xmm2
; CHECK-NEXT:    cmpeqps %xmm1, %xmm2
; CHECK-NEXT:    cmpunordps %xmm1, %xmm0
; CHECK-NEXT:    orps %xmm2, %xmm0
; CHECK-NEXT:    retq
  %1 = fcmp ueq <4 x float> <float -0.0, float 1.0, float -1.0, float undef>, <float undef, float 1.0, float -1.0, float +2.0>
  %2 = sext <4 x i1> %1 to <4 x i32>
  ret <4 x i32> %2
}

;
; fcmp false
;

define <2 x i64> @fcmp_false_v2f64() {
; CHECK-LABEL: fcmp_false_v2f64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    xorps %xmm0, %xmm0
; CHECK-NEXT:    retq
  %1 = fcmp false <2 x double> <double 0x3FF0000000000000, double 0xFFEFFFFFFFFFFFFF>, <double 0x3FF0000000000000, double 0xFFEFFFFFFFFFFFFF>
  %2 = sext <2 x i1> %1 to <2 x i64>
  ret <2 x i64> %2
}

define <2 x i64> @fcmp_false_v2f64_undef() {
; CHECK-LABEL: fcmp_false_v2f64_undef:
; CHECK:       # %bb.0:
; CHECK-NEXT:    xorps %xmm0, %xmm0
; CHECK-NEXT:    retq
  %1 = fcmp false <2 x double> <double 0x3FF0000000000000, double 0xFFEFFFFFFFFFFFFF>, undef
  %2 = sext <2 x i1> %1 to <2 x i64>
  ret <2 x i64> %2
}

define <2 x i64> @fcmp_false_v2f64_undef_elt() {
; CHECK-LABEL: fcmp_false_v2f64_undef_elt:
; CHECK:       # %bb.0:
; CHECK-NEXT:    xorps %xmm0, %xmm0
; CHECK-NEXT:    retq
  %1 = fcmp false <2 x double> <double 0x3FF0000000000000, double 0xFFEFFFFFFFFFFFFF>, <double undef, double 0x3FF0000000000000>
  %2 = sext <2 x i1> %1 to <2 x i64>
  ret <2 x i64> %2
}

define <4 x i32> @fcmp_false_v4f32() {
; CHECK-LABEL: fcmp_false_v4f32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    xorps %xmm0, %xmm0
; CHECK-NEXT:    retq
  %1 = fcmp false <4 x float> <float -0.0, float 1.0, float -1.0, float +2.0>, <float +0.0, float 1.0, float -1.0, float +2.0>
  %2 = sext <4 x i1> %1 to <4 x i32>
  ret <4 x i32> %2
}

define <4 x i32> @fcmp_false_v4f32_undef() {
; CHECK-LABEL: fcmp_false_v4f32_undef:
; CHECK:       # %bb.0:
; CHECK-NEXT:    xorps %xmm0, %xmm0
; CHECK-NEXT:    retq
  %1 = fcmp false <4 x float> <float 1.0, float -1.0, float +2.0, float -0.0>, undef
  %2 = sext <4 x i1> %1 to <4 x i32>
  ret <4 x i32> %2
}

define <4 x i32> @fcmp_false_v4f32_undef_elt() {
; CHECK-LABEL: fcmp_false_v4f32_undef_elt:
; CHECK:       # %bb.0:
; CHECK-NEXT:    xorps %xmm0, %xmm0
; CHECK-NEXT:    retq
  %1 = fcmp false <4 x float> <float -0.0, float 1.0, float -1.0, float undef>, <float undef, float 1.0, float -1.0, float +2.0>
  %2 = sext <4 x i1> %1 to <4 x i32>
  ret <4 x i32> %2
}

;
; fcmp true
;

define <2 x i64> @fcmp_true_v2f64() {
; CHECK-LABEL: fcmp_true_v2f64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    pcmpeqd %xmm0, %xmm0
; CHECK-NEXT:    retq
  %1 = fcmp true <2 x double> <double 0x3FF0000000000000, double 0xFFEFFFFFFFFFFFFF>, <double 0x3FF0000000000000, double 0xFFEFFFFFFFFFFFFF>
  %2 = sext <2 x i1> %1 to <2 x i64>
  ret <2 x i64> %2
}

define <2 x i64> @fcmp_true_v2f64_undef() {
; CHECK-LABEL: fcmp_true_v2f64_undef:
; CHECK:       # %bb.0:
; CHECK-NEXT:    pcmpeqd %xmm0, %xmm0
; CHECK-NEXT:    retq
  %1 = fcmp true <2 x double> <double 0x3FF0000000000000, double 0xFFEFFFFFFFFFFFFF>, undef
  %2 = sext <2 x i1> %1 to <2 x i64>
  ret <2 x i64> %2
}

define <2 x i64> @fcmp_true_v2f64_undef_elt() {
; CHECK-LABEL: fcmp_true_v2f64_undef_elt:
; CHECK:       # %bb.0:
; CHECK-NEXT:    pcmpeqd %xmm0, %xmm0
; CHECK-NEXT:    retq
  %1 = fcmp true <2 x double> <double 0x3FF0000000000000, double 0xFFEFFFFFFFFFFFFF>, <double undef, double 0x3FF0000000000000>
  %2 = sext <2 x i1> %1 to <2 x i64>
  ret <2 x i64> %2
}

define <4 x i32> @fcmp_true_v4f32() {
; CHECK-LABEL: fcmp_true_v4f32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    pcmpeqd %xmm0, %xmm0
; CHECK-NEXT:    retq
  %1 = fcmp true <4 x float> <float -0.0, float 1.0, float -1.0, float +2.0>, <float +0.0, float 1.0, float -1.0, float +2.0>
  %2 = sext <4 x i1> %1 to <4 x i32>
  ret <4 x i32> %2
}

define <4 x i32> @fcmp_true_v4f32_undef() {
; CHECK-LABEL: fcmp_true_v4f32_undef:
; CHECK:       # %bb.0:
; CHECK-NEXT:    pcmpeqd %xmm0, %xmm0
; CHECK-NEXT:    retq
  %1 = fcmp true <4 x float> <float 1.0, float -1.0, float +2.0, float -0.0>, undef
  %2 = sext <4 x i1> %1 to <4 x i32>
  ret <4 x i32> %2
}

define <4 x i32> @fcmp_true_v4f32_undef_elt() {
; CHECK-LABEL: fcmp_true_v4f32_undef_elt:
; CHECK:       # %bb.0:
; CHECK-NEXT:    pcmpeqd %xmm0, %xmm0
; CHECK-NEXT:    retq
  %1 = fcmp true <4 x float> <float -0.0, float 1.0, float -1.0, float undef>, <float undef, float 1.0, float -1.0, float +2.0>
  %2 = sext <4 x i1> %1 to <4 x i32>
  ret <4 x i32> %2
}
