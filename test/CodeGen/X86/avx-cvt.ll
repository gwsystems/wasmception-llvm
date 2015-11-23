; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx | FileCheck %s

define <8 x float> @sitofp00(<8 x i32> %a) nounwind {
; CHECK-LABEL: sitofp00:
; CHECK:       # BB#0:
; CHECK-NEXT:    vcvtdq2ps %ymm0, %ymm0
; CHECK-NEXT:    retq
  %b = sitofp <8 x i32> %a to <8 x float>
  ret <8 x float> %b
}

define <8 x i32> @fptosi00(<8 x float> %a) nounwind {
; CHECK-LABEL: fptosi00:
; CHECK:       # BB#0:
; CHECK-NEXT:    vcvttps2dq %ymm0, %ymm0
; CHECK-NEXT:    retq
  %b = fptosi <8 x float> %a to <8 x i32>
  ret <8 x i32> %b
}

define <4 x double> @sitofp01(<4 x i32> %a) {
; CHECK-LABEL: sitofp01:
; CHECK:       # BB#0:
; CHECK-NEXT:    vcvtdq2pd %xmm0, %ymm0
; CHECK-NEXT:    retq
  %b = sitofp <4 x i32> %a to <4 x double>
  ret <4 x double> %b
}

define <8 x float> @sitofp02(<8 x i16> %a) {
; CHECK-LABEL: sitofp02:
; CHECK:       # BB#0:
; CHECK-NEXT:    vpmovsxwd %xmm0, %xmm1
; CHECK-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[2,3,0,1]
; CHECK-NEXT:    vpmovsxwd %xmm0, %xmm0
; CHECK-NEXT:    vinsertf128 $1, %xmm0, %ymm1, %ymm0
; CHECK-NEXT:    vcvtdq2ps %ymm0, %ymm0
; CHECK-NEXT:    retq
  %b = sitofp <8 x i16> %a to <8 x float>
  ret <8 x float> %b
}

define <4 x i32> @fptosi01(<4 x double> %a) {
; CHECK-LABEL: fptosi01:
; CHECK:       # BB#0:
; CHECK-NEXT:    vcvttpd2dqy %ymm0, %xmm0
; CHECK-NEXT:    vzeroupper
; CHECK-NEXT:    retq
  %b = fptosi <4 x double> %a to <4 x i32>
  ret <4 x i32> %b
}

define <8 x float> @fptrunc00(<8 x double> %b) nounwind {
; CHECK-LABEL: fptrunc00:
; CHECK:       # BB#0:
; CHECK-NEXT:    vcvtpd2psy %ymm0, %xmm0
; CHECK-NEXT:    vcvtpd2psy %ymm1, %xmm1
; CHECK-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; CHECK-NEXT:    retq
  %a = fptrunc <8 x double> %b to <8 x float>
  ret <8 x float> %a
}

define <4 x double> @fpext00(<4 x float> %b) nounwind {
; CHECK-LABEL: fpext00:
; CHECK:       # BB#0:
; CHECK-NEXT:    vcvtps2pd %xmm0, %ymm0
; CHECK-NEXT:    retq
  %a = fpext <4 x float> %b to <4 x double>
  ret <4 x double> %a
}

define double @funcA(i64* nocapture %e) nounwind uwtable readonly ssp {
; CHECK-LABEL: funcA:
; CHECK:       # BB#0:
; CHECK-NEXT:    vcvtsi2sdq (%rdi), %xmm0, %xmm0
; CHECK-NEXT:    retq
  %tmp1 = load i64, i64* %e, align 8
  %conv = sitofp i64 %tmp1 to double
  ret double %conv
}

define double @funcB(i32* nocapture %e) nounwind uwtable readonly ssp {
; CHECK-LABEL: funcB:
; CHECK:       # BB#0:
; CHECK-NEXT:    vcvtsi2sdl (%rdi), %xmm0, %xmm0
; CHECK-NEXT:    retq
  %tmp1 = load i32, i32* %e, align 4
  %conv = sitofp i32 %tmp1 to double
  ret double %conv
}

define float @funcC(i32* nocapture %e) nounwind uwtable readonly ssp {
; CHECK-LABEL: funcC:
; CHECK:       # BB#0:
; CHECK-NEXT:    vcvtsi2ssl (%rdi), %xmm0, %xmm0
; CHECK-NEXT:    retq
  %tmp1 = load i32, i32* %e, align 4
  %conv = sitofp i32 %tmp1 to float
  ret float %conv
}

define float @funcD(i64* nocapture %e) nounwind uwtable readonly ssp {
; CHECK-LABEL: funcD:
; CHECK:       # BB#0:
; CHECK-NEXT:    vcvtsi2ssq (%rdi), %xmm0, %xmm0
; CHECK-NEXT:    retq
  %tmp1 = load i64, i64* %e, align 8
  %conv = sitofp i64 %tmp1 to float
  ret float %conv
}

define void @fpext() nounwind uwtable {
; CHECK-LABEL: fpext:
; CHECK:       # BB#0:
; CHECK-NEXT:    vcvtss2sd -{{[0-9]+}}(%rsp), %xmm0, %xmm0
; CHECK-NEXT:    vmovsd %xmm0, -{{[0-9]+}}(%rsp)
; CHECK-NEXT:    retq
  %f = alloca float, align 4
  %d = alloca double, align 8
  %tmp = load float, float* %f, align 4
  %conv = fpext float %tmp to double
  store double %conv, double* %d, align 8
  ret void
}

define double @nearbyint_f64(double %a) {
; CHECK-LABEL: nearbyint_f64:
; CHECK:       # BB#0:
; CHECK-NEXT:    vroundsd $12, %xmm0, %xmm0, %xmm0
; CHECK-NEXT:    retq
  %res = call double @llvm.nearbyint.f64(double %a)
  ret double %res
}
declare double @llvm.nearbyint.f64(double %p)

define float @floor_f32(float %a) {
; CHECK-LABEL: floor_f32:
; CHECK:       # BB#0:
; CHECK-NEXT:    vroundss $9, %xmm0, %xmm0, %xmm0
; CHECK-NEXT:    retq
  %res = call float @llvm.floor.f32(float %a)
  ret float %res
}
declare float @llvm.floor.f32(float %p)


