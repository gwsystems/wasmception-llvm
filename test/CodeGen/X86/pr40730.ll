; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx | FileCheck %s

define <8 x i32> @shuffle_v8i32_0dcd3f14(<8 x i32> %a, <8 x i32> %b) {
; CHECK-LABEL: shuffle_v8i32_0dcd3f14:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vextractf128 $1, %ymm0, %xmm2
; CHECK-NEXT:    vblendps {{.*#+}} xmm2 = xmm2[0],xmm0[1,2,3]
; CHECK-NEXT:    vpermilps {{.*#+}} xmm2 = xmm2[3,1,1,0]
; CHECK-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; CHECK-NEXT:    vperm2f128 {{.*#+}} ymm1 = ymm1[2,3,2,3]
; CHECK-NEXT:    vpermilpd {{.*#+}} ymm1 = ymm1[0,0,3,2]
; CHECK-NEXT:    vblendps {{.*#+}} ymm0 = ymm0[0],ymm1[1,2,3],ymm0[4],ymm1[5],ymm0[6,7]
; CHECK-NEXT:    retq
  %shuffle = shufflevector <8 x i32> %a, <8 x i32> %b, <8 x i32> <i32 0, i32 13, i32 12, i32 13, i32 3, i32 15, i32 1, i32 4>
  ret <8 x i32> %shuffle
}

; CHECK:      .LCPI1_0:
; CHECK-NEXT: .quad   60129542157
; CHECK-NEXT: .quad   60129542157
; CHECK-NEXT: .zero   8
; CHECK-NEXT: .quad   60129542157

define <8 x i32> @shuffle_v8i32_0dcd3f14_constant(<8 x i32> %a0)  {
; CHECK-LABEL: shuffle_v8i32_0dcd3f14_constant:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vextractf128 $1, %ymm0, %xmm1
; CHECK-NEXT:    vblendps {{.*#+}} xmm1 = xmm1[0],xmm0[1,2,3]
; CHECK-NEXT:    vpermilps {{.*#+}} xmm1 = xmm1[3,1,1,0]
; CHECK-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; CHECK-NEXT:    vblendps {{.*#+}} ymm0 = ymm0[0],mem[1,2,3],ymm0[4],mem[5],ymm0[6,7]
; CHECK-NEXT:    retq
  %res = shufflevector <8 x i32> %a0, <8 x i32> <i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 16>, <8 x i32> <i32 0, i32 13, i32 12, i32 13, i32 3, i32 15, i32 1, i32 4>
  ret <8 x i32> %res
}
