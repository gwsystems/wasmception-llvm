; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-linux-gnu -mattr=+fma | FileCheck -check-prefix=FMA3 -check-prefix=FMA3_256 %s
; RUN: llc < %s -mtriple=x86_64-unknown-linux-gnu -mattr=+fma,+avx512f | FileCheck -check-prefix=FMA3 -check-prefix=FMA3_512 %s
; RUN: llc < %s -mtriple=x86_64-unknown-linux-gnu -mattr=+fma4 | FileCheck -check-prefix=FMA4 %s

; This test checks the fusing of MUL + SUB/ADD to FMSUBADD.

define <2 x double> @mul_subadd_pd128(<2 x double> %A, <2 x double> %B, <2 x double> %C) #0 {
; FMA3_256-LABEL: mul_subadd_pd128:
; FMA3_256:       # BB#0: # %entry
; FMA3_256-NEXT:    vmulpd %xmm1, %xmm0, %xmm0
; FMA3_256-NEXT:    vsubpd %xmm2, %xmm0, %xmm1
; FMA3_256-NEXT:    vaddpd %xmm2, %xmm0, %xmm0
; FMA3_256-NEXT:    vblendpd {{.*#+}} xmm0 = xmm0[0],xmm1[1]
; FMA3_256-NEXT:    retq
;
; FMA3_512-LABEL: mul_subadd_pd128:
; FMA3_512:       # BB#0: # %entry
; FMA3_512-NEXT:    vmulpd %xmm1, %xmm0, %xmm0
; FMA3_512-NEXT:    vsubpd %xmm2, %xmm0, %xmm1
; FMA3_512-NEXT:    vaddpd %xmm2, %xmm0, %xmm0
; FMA3_512-NEXT:    vmovsd {{.*#+}} xmm0 = xmm0[0],xmm1[1]
; FMA3_512-NEXT:    retq
;
; FMA4-LABEL: mul_subadd_pd128:
; FMA4:       # BB#0: # %entry
; FMA4-NEXT:    vmulpd %xmm1, %xmm0, %xmm0
; FMA4-NEXT:    vsubpd %xmm2, %xmm0, %xmm1
; FMA4-NEXT:    vaddpd %xmm2, %xmm0, %xmm0
; FMA4-NEXT:    vblendpd {{.*#+}} xmm0 = xmm0[0],xmm1[1]
; FMA4-NEXT:    retq
entry:
  %AB = fmul <2 x double> %A, %B
  %Sub = fsub <2 x double> %AB, %C
  %Add = fadd <2 x double> %AB, %C
  %subadd = shufflevector <2 x double> %Add, <2 x double> %Sub, <2 x i32> <i32 0, i32 3>
  ret <2 x double> %subadd
}

define <4 x float> @mul_subadd_ps128(<4 x float> %A, <4 x float> %B, <4 x float> %C) #0 {
; FMA3-LABEL: mul_subadd_ps128:
; FMA3:       # BB#0: # %entry
; FMA3-NEXT:    vmulps %xmm1, %xmm0, %xmm0
; FMA3-NEXT:    vsubps %xmm2, %xmm0, %xmm1
; FMA3-NEXT:    vaddps %xmm2, %xmm0, %xmm0
; FMA3-NEXT:    vblendps {{.*#+}} xmm0 = xmm0[0],xmm1[1],xmm0[2],xmm1[3]
; FMA3-NEXT:    retq
;
; FMA4-LABEL: mul_subadd_ps128:
; FMA4:       # BB#0: # %entry
; FMA4-NEXT:    vmulps %xmm1, %xmm0, %xmm0
; FMA4-NEXT:    vsubps %xmm2, %xmm0, %xmm1
; FMA4-NEXT:    vaddps %xmm2, %xmm0, %xmm0
; FMA4-NEXT:    vblendps {{.*#+}} xmm0 = xmm0[0],xmm1[1],xmm0[2],xmm1[3]
; FMA4-NEXT:    retq
entry:
  %AB = fmul <4 x float> %A, %B
  %Sub = fsub <4 x float> %AB, %C
  %Add = fadd <4 x float> %AB, %C
  %subadd = shufflevector <4 x float> %Add, <4 x float> %Sub, <4 x i32> <i32 0, i32 5, i32 2, i32 7>
  ret <4 x float> %subadd
}

define <4 x double> @mul_subadd_pd256(<4 x double> %A, <4 x double> %B, <4 x double> %C) #0 {
; FMA3-LABEL: mul_subadd_pd256:
; FMA3:       # BB#0: # %entry
; FMA3-NEXT:    vmulpd %ymm1, %ymm0, %ymm0
; FMA3-NEXT:    vsubpd %ymm2, %ymm0, %ymm1
; FMA3-NEXT:    vaddpd %ymm2, %ymm0, %ymm0
; FMA3-NEXT:    vblendpd {{.*#+}} ymm0 = ymm0[0],ymm1[1],ymm0[2],ymm1[3]
; FMA3-NEXT:    retq
;
; FMA4-LABEL: mul_subadd_pd256:
; FMA4:       # BB#0: # %entry
; FMA4-NEXT:    vmulpd %ymm1, %ymm0, %ymm0
; FMA4-NEXT:    vsubpd %ymm2, %ymm0, %ymm1
; FMA4-NEXT:    vaddpd %ymm2, %ymm0, %ymm0
; FMA4-NEXT:    vblendpd {{.*#+}} ymm0 = ymm0[0],ymm1[1],ymm0[2],ymm1[3]
; FMA4-NEXT:    retq
entry:
  %AB = fmul <4 x double> %A, %B
  %Sub = fsub <4 x double> %AB, %C
  %Add = fadd <4 x double> %AB, %C
  %subadd = shufflevector <4 x double> %Add, <4 x double> %Sub, <4 x i32> <i32 0, i32 5, i32 2, i32 7>
  ret <4 x double> %subadd
}

define <8 x float> @mul_subadd_ps256(<8 x float> %A, <8 x float> %B, <8 x float> %C) #0 {
; FMA3-LABEL: mul_subadd_ps256:
; FMA3:       # BB#0: # %entry
; FMA3-NEXT:    vmulps %ymm1, %ymm0, %ymm0
; FMA3-NEXT:    vsubps %ymm2, %ymm0, %ymm1
; FMA3-NEXT:    vaddps %ymm2, %ymm0, %ymm0
; FMA3-NEXT:    vblendps {{.*#+}} ymm0 = ymm0[0],ymm1[1],ymm0[2],ymm1[3],ymm0[4],ymm1[5],ymm0[6],ymm1[7]
; FMA3-NEXT:    retq
;
; FMA4-LABEL: mul_subadd_ps256:
; FMA4:       # BB#0: # %entry
; FMA4-NEXT:    vmulps %ymm1, %ymm0, %ymm0
; FMA4-NEXT:    vsubps %ymm2, %ymm0, %ymm1
; FMA4-NEXT:    vaddps %ymm2, %ymm0, %ymm0
; FMA4-NEXT:    vblendps {{.*#+}} ymm0 = ymm0[0],ymm1[1],ymm0[2],ymm1[3],ymm0[4],ymm1[5],ymm0[6],ymm1[7]
; FMA4-NEXT:    retq
entry:
  %AB = fmul <8 x float> %A, %B
  %Sub = fsub <8 x float> %AB, %C
  %Add = fadd <8 x float> %AB, %C
  %subadd = shufflevector <8 x float> %Add, <8 x float> %Sub, <8 x i32> <i32 0, i32 9, i32 2, i32 11, i32 4, i32 13, i32 6, i32 15>
  ret <8 x float> %subadd
}

define <8 x double> @mul_subadd_pd512(<8 x double> %A, <8 x double> %B, <8 x double> %C) #0 {
; FMA3_256-LABEL: mul_subadd_pd512:
; FMA3_256:       # BB#0: # %entry
; FMA3_256-NEXT:    vmulpd %ymm2, %ymm0, %ymm0
; FMA3_256-NEXT:    vmulpd %ymm3, %ymm1, %ymm1
; FMA3_256-NEXT:    vsubpd %ymm5, %ymm1, %ymm2
; FMA3_256-NEXT:    vsubpd %ymm4, %ymm0, %ymm3
; FMA3_256-NEXT:    vaddpd %ymm5, %ymm1, %ymm1
; FMA3_256-NEXT:    vaddpd %ymm4, %ymm0, %ymm0
; FMA3_256-NEXT:    vblendpd {{.*#+}} ymm0 = ymm0[0],ymm3[1],ymm0[2],ymm3[3]
; FMA3_256-NEXT:    vblendpd {{.*#+}} ymm1 = ymm1[0],ymm2[1],ymm1[2],ymm2[3]
; FMA3_256-NEXT:    retq
;
; FMA3_512-LABEL: mul_subadd_pd512:
; FMA3_512:       # BB#0: # %entry
; FMA3_512-NEXT:    vmulpd %zmm1, %zmm0, %zmm0
; FMA3_512-NEXT:    vsubpd %zmm2, %zmm0, %zmm1
; FMA3_512-NEXT:    vaddpd %zmm2, %zmm0, %zmm0
; FMA3_512-NEXT:    vshufpd {{.*#+}} zmm0 = zmm0[0],zmm1[1],zmm0[2],zmm1[3],zmm0[4],zmm1[5],zmm0[6],zmm1[7]
; FMA3_512-NEXT:    retq
;
; FMA4-LABEL: mul_subadd_pd512:
; FMA4:       # BB#0: # %entry
; FMA4-NEXT:    vmulpd %ymm2, %ymm0, %ymm0
; FMA4-NEXT:    vmulpd %ymm3, %ymm1, %ymm1
; FMA4-NEXT:    vsubpd %ymm5, %ymm1, %ymm2
; FMA4-NEXT:    vsubpd %ymm4, %ymm0, %ymm3
; FMA4-NEXT:    vaddpd %ymm5, %ymm1, %ymm1
; FMA4-NEXT:    vaddpd %ymm4, %ymm0, %ymm0
; FMA4-NEXT:    vblendpd {{.*#+}} ymm0 = ymm0[0],ymm3[1],ymm0[2],ymm3[3]
; FMA4-NEXT:    vblendpd {{.*#+}} ymm1 = ymm1[0],ymm2[1],ymm1[2],ymm2[3]
; FMA4-NEXT:    retq
entry:
  %AB = fmul <8 x double> %A, %B
  %Sub = fsub <8 x double> %AB, %C
  %Add = fadd <8 x double> %AB, %C
  %subadd = shufflevector <8 x double> %Add, <8 x double> %Sub, <8 x i32> <i32 0, i32 9, i32 2, i32 11, i32 4, i32 13, i32 6, i32 15>
  ret <8 x double> %subadd
}

define <16 x float> @mul_subadd_ps512(<16 x float> %A, <16 x float> %B, <16 x float> %C) #0 {
; FMA3_256-LABEL: mul_subadd_ps512:
; FMA3_256:       # BB#0: # %entry
; FMA3_256-NEXT:    vmulps %ymm2, %ymm0, %ymm0
; FMA3_256-NEXT:    vmulps %ymm3, %ymm1, %ymm1
; FMA3_256-NEXT:    vsubps %ymm5, %ymm1, %ymm2
; FMA3_256-NEXT:    vsubps %ymm4, %ymm0, %ymm3
; FMA3_256-NEXT:    vaddps %ymm5, %ymm1, %ymm1
; FMA3_256-NEXT:    vaddps %ymm4, %ymm0, %ymm0
; FMA3_256-NEXT:    vblendps {{.*#+}} ymm0 = ymm0[0],ymm3[1],ymm0[2],ymm3[3],ymm0[4],ymm3[5],ymm0[6],ymm3[7]
; FMA3_256-NEXT:    vblendps {{.*#+}} ymm1 = ymm1[0],ymm2[1],ymm1[2],ymm2[3],ymm1[4],ymm2[5],ymm1[6],ymm2[7]
; FMA3_256-NEXT:    retq
;
; FMA3_512-LABEL: mul_subadd_ps512:
; FMA3_512:       # BB#0: # %entry
; FMA3_512-NEXT:    vmulps %zmm1, %zmm0, %zmm1
; FMA3_512-NEXT:    vaddps %zmm2, %zmm1, %zmm0
; FMA3_512-NEXT:    movw $-21846, %ax # imm = 0xAAAA
; FMA3_512-NEXT:    kmovw %eax, %k1
; FMA3_512-NEXT:    vsubps %zmm2, %zmm1, %zmm0 {%k1}
; FMA3_512-NEXT:    retq
;
; FMA4-LABEL: mul_subadd_ps512:
; FMA4:       # BB#0: # %entry
; FMA4-NEXT:    vmulps %ymm2, %ymm0, %ymm0
; FMA4-NEXT:    vmulps %ymm3, %ymm1, %ymm1
; FMA4-NEXT:    vsubps %ymm5, %ymm1, %ymm2
; FMA4-NEXT:    vsubps %ymm4, %ymm0, %ymm3
; FMA4-NEXT:    vaddps %ymm5, %ymm1, %ymm1
; FMA4-NEXT:    vaddps %ymm4, %ymm0, %ymm0
; FMA4-NEXT:    vblendps {{.*#+}} ymm0 = ymm0[0],ymm3[1],ymm0[2],ymm3[3],ymm0[4],ymm3[5],ymm0[6],ymm3[7]
; FMA4-NEXT:    vblendps {{.*#+}} ymm1 = ymm1[0],ymm2[1],ymm1[2],ymm2[3],ymm1[4],ymm2[5],ymm1[6],ymm2[7]
; FMA4-NEXT:    retq
entry:
  %AB = fmul <16 x float> %A, %B
  %Sub = fsub <16 x float> %AB, %C
  %Add = fadd <16 x float> %AB, %C
  %subadd = shufflevector <16 x float> %Add, <16 x float> %Sub, <16 x i32> <i32 0, i32 17, i32 2, i32 19, i32 4, i32 21, i32 6, i32 23, i32 8, i32 25, i32 10, i32 27, i32 12, i32 29, i32 14, i32 31>
  ret <16 x float> %subadd
}

attributes #0 = { nounwind "unsafe-fp-math"="true" }
