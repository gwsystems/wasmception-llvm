; RUN: llc < %s -mtriple=x86_64-apple-darwin -mattr=+avx | FileCheck %s --check-prefix=ALL --check-prefix=AVX1
; RUN: llc < %s -mtriple=x86_64-apple-darwin -mattr=+avx2 | FileCheck %s --check-prefix=ALL --check-prefix=AVX2

define <8 x float> @A(<8 x float> %a, <8 x float> %b) nounwind uwtable readnone ssp {
; ALL-LABEL: A:
; ALL:       ## BB#0: ## %entry
; ALL-NEXT:    vperm2f128 {{.*#+}} ymm0 = ymm0[2,3,0,1]
; ALL-NEXT:    retq
entry:
  %shuffle = shufflevector <8 x float> %a, <8 x float> %b, <8 x i32> <i32 4, i32 5, i32 6, i32 7, i32 0, i32 1, i32 2, i32 3>
  ret <8 x float> %shuffle
}

define <8 x float> @B(<8 x float> %a, <8 x float> %b) nounwind uwtable readnone ssp {
; ALL-LABEL: B:
; ALL:       ## BB#0: ## %entry
; ALL-NEXT:    vblendpd {{.*#+}} ymm0 = ymm0[0,1],ymm1[2,3]
; ALL-NEXT:    retq
entry:
  %shuffle = shufflevector <8 x float> %a, <8 x float> %b, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 12, i32 13, i32 14, i32 15>
  ret <8 x float> %shuffle
}

define <8 x float> @C(<8 x float> %a, <8 x float> %b) nounwind uwtable readnone ssp {
; ALL-LABEL: C:
; ALL:       ## BB#0: ## %entry
; ALL-NEXT:    vinsertf128 $1, %xmm0, %ymm0, %ymm0
; ALL-NEXT:    retq
entry:
  %shuffle = shufflevector <8 x float> %a, <8 x float> %b, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 0, i32 1, i32 2, i32 3>
  ret <8 x float> %shuffle
}

define <8 x float> @D(<8 x float> %a, <8 x float> %b) nounwind uwtable readnone ssp {
; ALL-LABEL: D:
; ALL:       ## BB#0: ## %entry
; ALL-NEXT:    vperm2f128 {{.*#+}} ymm0 = ymm0[2,3,2,3]
; ALL-NEXT:    retq
entry:
  %shuffle = shufflevector <8 x float> %a, <8 x float> %b, <8 x i32> <i32 4, i32 5, i32 6, i32 7, i32 4, i32 5, i32 6, i32 7>
  ret <8 x float> %shuffle
}

define <32 x i8> @E(<32 x i8> %a, <32 x i8> %b) nounwind uwtable readnone ssp {
; ALL-LABEL: E:
; ALL:       ## BB#0: ## %entry
; ALL-NEXT:    vperm2f128 {{.*#+}} ymm0 = ymm0[2,3,2,3]
; ALL-NEXT:    retq
entry:
  %shuffle = shufflevector <32 x i8> %a, <32 x i8> %b, <32 x i32> <i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 31, i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 31>
  ret <32 x i8> %shuffle
}

define <4 x i64> @E2(<4 x i64> %a, <4 x i64> %b) nounwind uwtable readnone ssp {
; ALL-LABEL: E2:
; ALL:       ## BB#0: ## %entry
; ALL-NEXT:    vperm2f128 {{.*#+}} ymm0 = ymm1[2,3],ymm0[0,1]
; ALL-NEXT:    retq
entry:
  %shuffle = shufflevector <4 x i64> %a, <4 x i64> %b, <4 x i32> <i32 6, i32 7, i32 0, i32 1>
  ret <4 x i64> %shuffle
}

define <32 x i8> @Ei(<32 x i8> %a, <32 x i8> %b) nounwind uwtable readnone ssp {
; AVX1-LABEL: Ei:
; AVX1:       ## BB#0: ## %entry
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm0
; AVX1-NEXT:    vpaddb {{.*}}(%rip), %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm0, %ymm0
; AVX1-NEXT:    vperm2f128 {{.*#+}} ymm0 = ymm0[2,3,2,3]
; AVX1-NEXT:    retq
;
; AVX2-LABEL: Ei:
; AVX2:       ## BB#0: ## %entry
; AVX2-NEXT:    vpaddb {{.*}}(%rip), %ymm0, %ymm0
; AVX2-NEXT:    vperm2i128 {{.*#+}} ymm0 = ymm0[2,3,2,3]
; AVX2-NEXT:    retq
entry:
  ; add forces execution domain
  %a2 = add <32 x i8> %a, <i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1>
  %shuffle = shufflevector <32 x i8> %a2, <32 x i8> %b, <32 x i32> <i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 31, i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 31>
  ret <32 x i8> %shuffle
}

define <4 x i64> @E2i(<4 x i64> %a, <4 x i64> %b) nounwind uwtable readnone ssp {
; AVX1-LABEL: E2i:
; AVX1:       ## BB#0: ## %entry
; AVX1-NEXT:    vpaddq {{.*}}(%rip), %xmm0, %xmm0
; AVX1-NEXT:    vperm2f128 {{.*#+}} ymm0 = ymm1[2,3],ymm0[0,1]
; AVX1-NEXT:    retq
;
; AVX2-LABEL: E2i:
; AVX2:       ## BB#0: ## %entry
; AVX2-NEXT:    vpbroadcastq {{.*}}(%rip), %ymm2
; AVX2-NEXT:    vpaddq %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vperm2i128 {{.*#+}} ymm0 = ymm1[2,3],ymm0[0,1]
; AVX2-NEXT:    retq
entry:
  ; add forces execution domain
  %a2 = add <4 x i64> %a, <i64 1, i64 1, i64 1, i64 1>
  %shuffle = shufflevector <4 x i64> %a2, <4 x i64> %b, <4 x i32> <i32 6, i32 7, i32 0, i32 1>
  ret <4 x i64> %shuffle
}

define <8 x i32> @E3i(<8 x i32> %a, <8 x i32> %b) nounwind uwtable readnone ssp {
; AVX1-LABEL: E3i:
; AVX1:       ## BB#0: ## %entry
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm0
; AVX1-NEXT:    vpaddd {{.*}}(%rip), %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm0, %ymm0
; AVX1-NEXT:    vperm2f128 {{.*#+}} ymm0 = ymm0[2,3],ymm1[2,3]
; AVX1-NEXT:    retq
;
; AVX2-LABEL: E3i:
; AVX2:       ## BB#0: ## %entry
; AVX2-NEXT:    vpbroadcastd {{.*}}(%rip), %ymm2
; AVX2-NEXT:    vpaddd %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vperm2i128 {{.*#+}} ymm0 = ymm0[2,3],ymm1[2,3]
; AVX2-NEXT:    retq
entry:
  ; add forces execution domain
  %a2 = add <8 x i32> %a, <i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1>
  %shuffle = shufflevector <8 x i32> %a2, <8 x i32> %b, <8 x i32> <i32 undef, i32 5, i32 undef, i32 7, i32 12, i32 13, i32 14, i32 15>
  ret <8 x i32> %shuffle
}

define <16 x i16> @E4i(<16 x i16> %a, <16 x i16> %b) nounwind uwtable readnone ssp {
; AVX1-LABEL: E4i:
; AVX1:       ## BB#0: ## %entry
; AVX1-NEXT:    vpaddw {{.*}}(%rip), %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm1, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: E4i:
; AVX2:       ## BB#0: ## %entry
; AVX2-NEXT:    vpaddw {{.*}}(%rip), %ymm0, %ymm0
; AVX2-NEXT:    vinserti128 $1, %xmm0, %ymm1, %ymm0
; AVX2-NEXT:    retq
entry:
  ; add forces execution domain
  %a2 = add <16 x i16> %a, <i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1>
  %shuffle = shufflevector <16 x i16> %a2, <16 x i16> %b, <16 x i32> <i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  ret <16 x i16> %shuffle
}

define <16 x i16> @E5i(<16 x i16>* %a, <16 x i16>* %b) nounwind uwtable readnone ssp {
; AVX1-LABEL: E5i:
; AVX1:       ## BB#0: ## %entry
; AVX1-NEXT:    vmovdqa (%rdi), %ymm0
; AVX1-NEXT:    vmovaps (%rsi), %ymm1
; AVX1-NEXT:    vpaddw {{.*}}(%rip), %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm1, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: E5i:
; AVX2:       ## BB#0: ## %entry
; AVX2-NEXT:    vmovdqa (%rdi), %ymm0
; AVX2-NEXT:    vmovdqa (%rsi), %ymm1
; AVX2-NEXT:    vpaddw {{.*}}(%rip), %ymm0, %ymm0
; AVX2-NEXT:    vinserti128 $1, %xmm0, %ymm1, %ymm0
; AVX2-NEXT:    retq
entry:
  %c = load <16 x i16>, <16 x i16>* %a
  %d = load <16 x i16>, <16 x i16>* %b
  %c2 = add <16 x i16> %c, <i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1>
  %shuffle = shufflevector <16 x i16> %c2, <16 x i16> %d, <16 x i32> <i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  ret <16 x i16> %shuffle
}

;;;; Cases with undef indicies mixed in the mask

define <8 x float> @F(<8 x float> %a, <8 x float> %b) nounwind uwtable readnone ssp {
; ALL-LABEL: F:
; ALL:       ## BB#0: ## %entry
; ALL-NEXT:    vperm2f128 {{.*#+}} ymm0 = ymm0[2,3],ymm1[0,1]
; ALL-NEXT:    retq
entry:
  %shuffle = shufflevector <8 x float> %a, <8 x float> %b, <8 x i32> <i32 undef, i32 undef, i32 6, i32 7, i32 undef, i32 9, i32 undef, i32 11>
  ret <8 x float> %shuffle
}

define <8 x float> @F2(<8 x float> %a, <8 x float> %b) nounwind uwtable readnone ssp {
; ALL-LABEL: F2:
; ALL:       ## BB#0: ## %entry
; ALL-NEXT:    vperm2f128 {{.*#+}} ymm0 = ymm0[2,3,2,3]
; ALL-NEXT:    retq
entry:
  %shuffle = shufflevector <8 x float> %a, <8 x float> %b, <8 x i32> <i32 undef, i32 undef, i32 6, i32 7, i32 undef, i32 undef, i32 6, i32 7>
  ret <8 x float> %shuffle
}

define <8 x float> @F3(<8 x float> %a, <8 x float> %b) nounwind uwtable readnone ssp {
; ALL-LABEL: F3:
; ALL:       ## BB#0: ## %entry
; ALL-NEXT:    vperm2f128 {{.*#+}} ymm0 = ymm0[2,3],ymm1[0,1]
; ALL-NEXT:    retq
entry:
  %shuffle = shufflevector <8 x float> %a, <8 x float> %b, <8 x i32> <i32 undef, i32 undef, i32 6, i32 7, i32 undef, i32 undef, i32 10, i32 11>
  ret <8 x float> %shuffle
}

define <8 x float> @F4(<8 x float> %a, <8 x float> %b) nounwind uwtable readnone ssp {
; ALL-LABEL: F4:
; ALL:       ## BB#0: ## %entry
; ALL-NEXT:    vperm2f128 {{.*#+}} ymm0 = ymm0[2,3],ymm1[2,3]
; ALL-NEXT:    retq
entry:
  %shuffle = shufflevector <8 x float> %a, <8 x float> %b, <8 x i32> <i32 undef, i32 undef, i32 6, i32 7, i32 undef, i32 undef, i32 14, i32 15>
  ret <8 x float> %shuffle
}

define <8 x float> @F5(<8 x float> %a, <8 x float> %b) nounwind uwtable readnone ssp {
; ALL-LABEL: F5:
; ALL:       ## BB#0: ## %entry
; ALL-NEXT:    vperm2f128 {{.*#+}} ymm0 = ymm0[2,3,2,3]
; ALL-NEXT:    retq
entry:
  %shuffle = shufflevector <8 x float> %a, <8 x float> %b, <8 x i32> <i32 undef, i32 undef, i32 6, i32 7, i32 4, i32 5, i32 6, i32 7>
  ret <8 x float> %shuffle
}

define <8 x float> @F6(<8 x float> %a, <8 x float> %b) nounwind uwtable readnone ssp {
; ALL-LABEL: F6:
; ALL:       ## BB#0: ## %entry
; ALL-NEXT:    vperm2f128 {{.*#+}} ymm0 = ymm0[2,3],ymm1[0,1]
; ALL-NEXT:    retq
entry:
  %shuffle = shufflevector <8 x float> %a, <8 x float> %b, <8 x i32> <i32 undef, i32 undef, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11>
  ret <8 x float> %shuffle
}

define <8 x float> @F7(<8 x float> %a, <8 x float> %b) nounwind uwtable readnone ssp {
; ALL-LABEL: F7:
; ALL:       ## BB#0: ## %entry
; ALL-NEXT:    vperm2f128 {{.*#+}} ymm0 = ymm0[2,3,2,3]
; ALL-NEXT:    retq
entry:
  %shuffle = shufflevector <8 x float> %a, <8 x float> %b, <8 x i32> <i32 4, i32 5, i32 6, i32 7, i32 undef, i32 undef, i32 6, i32 7>
  ret <8 x float> %shuffle
}

define <8 x float> @F8(<8 x float> %a, <8 x float> %b) nounwind uwtable readnone ssp {
; ALL-LABEL: F8:
; ALL:       ## BB#0: ## %entry
; ALL-NEXT:    vperm2f128 {{.*#+}} ymm0 = ymm0[2,3],ymm1[2,3]
; ALL-NEXT:    retq
entry:
  %shuffle = shufflevector <8 x float> %a, <8 x float> %b, <8 x i32> <i32 4, i32 5, i32 6, i32 7, i32 undef, i32 undef, i32 14, i32 15>
  ret <8 x float> %shuffle
}

;;;; Cases we must not select vperm2f128

define <8 x float> @G(<8 x float> %a, <8 x float> %b) nounwind uwtable readnone ssp {
; ALL-LABEL: G:
; ALL:       ## BB#0: ## %entry
; ALL-NEXT:    vperm2f128 {{.*#+}} ymm0 = ymm0[2,3],ymm1[2,3]
; ALL-NEXT:    vpermilps {{.*#+}} ymm0 = ymm0[0,0,2,3,4,4,6,7]
; ALL-NEXT:    retq
entry:
  %shuffle = shufflevector <8 x float> %a, <8 x float> %b, <8 x i32> <i32 undef, i32 undef, i32 6, i32 7, i32 undef, i32 12, i32 undef, i32 15>
  ret <8 x float> %shuffle
}

;; Test zero mask generation. 
;; PR22984: https://llvm.org/bugs/show_bug.cgi?id=22984
;; Prefer xor+vblendpd over vperm2f128 because that has better performance.

define <4 x double> @vperm2z_0x08(<4 x double> %a) {
; ALL-LABEL: vperm2z_0x08:
; ALL:       # BB#0:
; ALL-NEXT:    vperm2f128 {{.*#+}} ymm0 = zero,zero,ymm0[0,1]
; ALL-NEXT:    retq
  %s = shufflevector <4 x double> %a, <4 x double> <double 0.0, double 0.0, double undef, double undef>, <4 x i32> <i32 4, i32 5, i32 0, i32 1>
  ret <4 x double> %s
}

define <4 x double> @vperm2z_0x18(<4 x double> %a) {
; ALL-LABEL: vperm2z_0x18:
; ALL:       # BB#0:
; ALL-NEXT:    vxorpd %ymm1, %ymm1, %ymm1
; ALL-NEXT:    vblendpd {{.*#+}} ymm0 = ymm1[0,1],ymm0[2,3]
; ALL-NEXT:    retq
  %s = shufflevector <4 x double> %a, <4 x double> <double 0.0, double 0.0, double undef, double undef>, <4 x i32> <i32 4, i32 5, i32 2, i32 3>
  ret <4 x double> %s
}

define <4 x double> @vperm2z_0x28(<4 x double> %a) {
; ALL-LABEL: vperm2z_0x28:
; ALL:       # BB#0:
; ALL-NEXT:    vperm2f128 {{.*#+}} ymm0 = zero,zero,ymm0[0,1]
; ALL-NEXT:    retq
  %s = shufflevector <4 x double> <double 0.0, double 0.0, double undef, double undef>, <4 x double> %a, <4 x i32> <i32 0, i32 1, i32 4, i32 5>
  ret <4 x double> %s
}

define <4 x double> @vperm2z_0x38(<4 x double> %a) {
; ALL-LABEL: vperm2z_0x38:
; ALL:       # BB#0:
; ALL-NEXT:    vxorpd %ymm1, %ymm1, %ymm1
; ALL-NEXT:    vblendpd {{.*#+}} ymm0 = ymm1[0,1],ymm0[2,3]
; ALL-NEXT:    retq
  %s = shufflevector <4 x double> <double 0.0, double 0.0, double undef, double undef>, <4 x double> %a, <4 x i32> <i32 0, i32 1, i32 6, i32 7>
  ret <4 x double> %s
}

define <4 x double> @vperm2z_0x80(<4 x double> %a) {
; ALL-LABEL: vperm2z_0x80:
; ALL:       # BB#0:
; ALL-NEXT:    vperm2f128 {{.*#+}} ymm0 = ymm0[0,1],zero,zero
; ALL-NEXT:    retq
  %s = shufflevector <4 x double> %a, <4 x double> <double 0.0, double 0.0, double undef, double undef>, <4 x i32> <i32 0, i32 1, i32 4, i32 5>
  ret <4 x double> %s
}

define <4 x double> @vperm2z_0x81(<4 x double> %a) {
; ALL-LABEL: vperm2z_0x81:
; ALL:       # BB#0:
; ALL-NEXT:    vperm2f128 {{.*#+}} ymm0 = ymm0[2,3],zero,zero
; ALL-NEXT:    retq
  %s = shufflevector <4 x double> %a, <4 x double> <double 0.0, double 0.0, double undef, double undef>, <4 x i32> <i32 2, i32 3, i32 4, i32 5>
  ret <4 x double> %s
}

define <4 x double> @vperm2z_0x82(<4 x double> %a) {
; ALL-LABEL: vperm2z_0x82:
; ALL:       # BB#0:
; ALL-NEXT:    vperm2f128 {{.*#+}} ymm0 = ymm0[0,1],zero,zero
; ALL-NEXT:    retq
  %s = shufflevector <4 x double> <double 0.0, double 0.0, double undef, double undef>, <4 x double> %a, <4 x i32> <i32 4, i32 5, i32 0, i32 1>
  ret <4 x double> %s
}

define <4 x double> @vperm2z_0x83(<4 x double> %a) {
; ALL-LABEL: vperm2z_0x83:
; ALL:       # BB#0:
; ALL-NEXT:    vperm2f128 {{.*#+}} ymm0 = ymm0[2,3],zero,zero
; ALL-NEXT:    retq
  %s = shufflevector <4 x double> <double 0.0, double 0.0, double undef, double undef>, <4 x double> %a, <4 x i32> <i32 6, i32 7, i32 0, i32 1>
  ret <4 x double> %s
}

;; With AVX2 select the integer version of the instruction. Use an add to force the domain selection.

define <4 x i64> @vperm2z_int_0x83(<4 x i64> %a, <4 x i64> %b) {
; ALL-LABEL: vperm2z_int_0x83:
; ALL:       # BB#0:
; AVX1:    vperm2f128 {{.*#+}} ymm0 = ymm0[2,3],zero,zero
; AVX2:    vperm2i128 {{.*#+}} ymm0 = ymm0[2,3],zero,zero
  %s = shufflevector <4 x i64> <i64 0, i64 0, i64 undef, i64 undef>, <4 x i64> %a, <4 x i32> <i32 6, i32 7, i32 0, i32 1>
  %c = add <4 x i64> %b, %s
  ret <4 x i64> %c
}

