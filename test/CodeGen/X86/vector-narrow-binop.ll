; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+sse2 | FileCheck %s --check-prefix=ALL --check-prefix=SSE --check-prefix=SSE2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx | FileCheck %s --check-prefix=ALL --check-prefix=AVX --check-prefix=AVX1
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx2 | FileCheck %s --check-prefix=ALL --check-prefix=AVX --check-prefix=AVX2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512f | FileCheck %s --check-prefix=ALL --check-prefix=AVX --check-prefix=AVX512 --check-prefix=AVX512F
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512bw | FileCheck %s --check-prefix=ALL --check-prefix=AVX --check-prefix=AVX512 --check-prefix=AVX512BW
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512dq | FileCheck %s --check-prefix=ALL --check-prefix=AVX --check-prefix=AVX512 --check-prefix=AVX512DQ

; AVX1 has support for 256-bit bitwise logic because the FP variants were included.
; If using those ops requires extra insert/extract though, it's probably not worth it.

define <8 x i32> @PR32790(<8 x i32> %a, <8 x i32> %b, <8 x i32> %c, <8 x i32> %d) {
; SSE-LABEL: PR32790:
; SSE:       # %bb.0:
; SSE-NEXT:    paddd %xmm2, %xmm0
; SSE-NEXT:    paddd %xmm3, %xmm1
; SSE-NEXT:    pand %xmm5, %xmm1
; SSE-NEXT:    pand %xmm4, %xmm0
; SSE-NEXT:    psubd %xmm6, %xmm0
; SSE-NEXT:    psubd %xmm7, %xmm1
; SSE-NEXT:    retq
;
; AVX1-LABEL: PR32790:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vpaddd %xmm1, %xmm0, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm1
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm0
; AVX1-NEXT:    vpaddd %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm1
; AVX1-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm1
; AVX1-NEXT:    vpsubd %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vpand %xmm2, %xmm4, %xmm1
; AVX1-NEXT:    vpsubd %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm1, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: PR32790:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpaddd %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vpand %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpsubd %ymm3, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512-LABEL: PR32790:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpaddd %ymm1, %ymm0, %ymm0
; AVX512-NEXT:    vpand %ymm2, %ymm0, %ymm0
; AVX512-NEXT:    vpsubd %ymm3, %ymm0, %ymm0
; AVX512-NEXT:    retq
  %add = add <8 x i32> %a, %b
  %and = and <8 x i32> %add, %c
  %sub = sub <8 x i32> %and, %d
  ret <8 x i32> %sub
}

; In a more extreme case, even the later AVX targets should avoid extract/insert just
; because 256-bit ops are supported.

define <4 x i32> @do_not_use_256bit_op(<4 x i32> %a, <4 x i32> %b, <4 x i32> %c, <4 x i32> %d) {
; SSE-LABEL: do_not_use_256bit_op:
; SSE:       # %bb.0:
; SSE-NEXT:    pand %xmm2, %xmm0
; SSE-NEXT:    pand %xmm3, %xmm1
; SSE-NEXT:    psubd %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: do_not_use_256bit_op:
; AVX:       # %bb.0:
; AVX-NEXT:    vpand %xmm2, %xmm0, %xmm0
; AVX-NEXT:    vpand %xmm3, %xmm1, %xmm1
; AVX-NEXT:    vpsubd %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
  %concat1 = shufflevector <4 x i32> %a, <4 x i32> %b, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %concat2 = shufflevector <4 x i32> %c, <4 x i32> %d, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %and = and <8 x i32> %concat1, %concat2
  %extract1 = shufflevector <8 x i32> %and, <8 x i32> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %extract2 = shufflevector <8 x i32> %and, <8 x i32> undef, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %sub = sub <4 x i32> %extract1, %extract2
  ret <4 x i32> %sub
}

; When extracting from a vector binop, the source width should be a multiple of the destination width.
; https://bugs.llvm.org/show_bug.cgi?id=39511

define <3 x float> @PR39511(<4 x float> %t0, <3 x float>* %b) {
; SSE-LABEL: PR39511:
; SSE:       # %bb.0:
; SSE-NEXT:    addps {{.*}}(%rip), %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: PR39511:
; AVX:       # %bb.0:
; AVX-NEXT:    vaddps {{.*}}(%rip), %xmm0, %xmm0
; AVX-NEXT:    retq
  %add = fadd <4 x float> %t0, <float 1.0, float 2.0, float 3.0, float 4.0>
  %ext = shufflevector <4 x float> %add, <4 x float> undef, <3 x i32> <i32 0, i32 1, i32 2>
  ret <3 x float> %ext
}

; When extracting from a vector binop, we need to be extracting
; by a width of at least 1 of the original vector elements.
; https://bugs.llvm.org/show_bug.cgi?id=39893

define <2 x i8> @PR39893(<2 x i32> %x, <8 x i8> %y) {
; SSE-LABEL: PR39893:
; SSE:       # %bb.0:
; SSE-NEXT:    pxor %xmm2, %xmm2
; SSE-NEXT:    psubd %xmm0, %xmm2
; SSE-NEXT:    punpcklbw {{.*#+}} xmm2 = xmm2[0],xmm0[0],xmm2[1],xmm0[1],xmm2[2],xmm0[2],xmm2[3],xmm0[3],xmm2[4],xmm0[4],xmm2[5],xmm0[5],xmm2[6],xmm0[6],xmm2[7],xmm0[7]
; SSE-NEXT:    shufps {{.*#+}} xmm2 = xmm2[1,1],xmm1[2,3]
; SSE-NEXT:    movaps %xmm2, %xmm0
; SSE-NEXT:    retq
;
; AVX1-LABEL: PR39893:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vpxor %xmm2, %xmm2, %xmm2
; AVX1-NEXT:    vpsubd %xmm0, %xmm2, %xmm0
; AVX1-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[2],zero,xmm0[3],zero,xmm0[2],zero,xmm0[3],zero,xmm0[8],zero,xmm0[9],zero,xmm0[10],zero,xmm0[11],zero
; AVX1-NEXT:    vpblendw {{.*#+}} xmm0 = xmm0[0,1,2,3],xmm1[4,5,6,7]
; AVX1-NEXT:    retq
;
; AVX2-LABEL: PR39893:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpxor %xmm2, %xmm2, %xmm2
; AVX2-NEXT:    vpsubd %xmm0, %xmm2, %xmm0
; AVX2-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[2],zero,xmm0[3],zero,xmm0[2],zero,xmm0[3],zero,xmm0[8],zero,xmm0[9],zero,xmm0[10],zero,xmm0[11],zero
; AVX2-NEXT:    vpblendd {{.*#+}} xmm0 = xmm0[0,1],xmm1[2,3]
; AVX2-NEXT:    retq
;
; AVX512-LABEL: PR39893:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpxor %xmm2, %xmm2, %xmm2
; AVX512-NEXT:    vpsubd %xmm0, %xmm2, %xmm0
; AVX512-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[2],zero,xmm0[3],zero,xmm0[2],zero,xmm0[3],zero,xmm0[8],zero,xmm0[9],zero,xmm0[10],zero,xmm0[11],zero
; AVX512-NEXT:    vpblendd {{.*#+}} xmm0 = xmm0[0,1],xmm1[2,3]
; AVX512-NEXT:    retq
  %sub = sub <2 x i32> <i32 0, i32 undef>, %x
  %bc = bitcast <2 x i32> %sub to <8 x i8>
  %shuffle = shufflevector <8 x i8> %y, <8 x i8> %bc, <2 x i32> <i32 10, i32 4>
  ret <2 x i8> %shuffle
}

define <2 x i8> @PR39893_2(<2 x float> %x) {
; SSE-LABEL: PR39893_2:
; SSE:       # %bb.0:
; SSE-NEXT:    xorps %xmm1, %xmm1
; SSE-NEXT:    subps %xmm0, %xmm1
; SSE-NEXT:    punpcklbw {{.*#+}} xmm1 = xmm1[0],xmm0[0],xmm1[1],xmm0[1],xmm1[2],xmm0[2],xmm1[3],xmm0[3],xmm1[4],xmm0[4],xmm1[5],xmm0[5],xmm1[6],xmm0[6],xmm1[7],xmm0[7]
; SSE-NEXT:    pshufd {{.*#+}} xmm0 = xmm1[0,1,0,3]
; SSE-NEXT:    pshufhw {{.*#+}} xmm0 = xmm0[0,1,2,3,5,5,6,7]
; SSE-NEXT:    retq
;
; AVX-LABEL: PR39893_2:
; AVX:       # %bb.0:
; AVX-NEXT:    vxorps %xmm1, %xmm1, %xmm1
; AVX-NEXT:    vsubps %xmm0, %xmm1, %xmm0
; AVX-NEXT:    vpmovzxbw {{.*#+}} xmm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero,xmm0[4],zero,xmm0[5],zero,xmm0[6],zero,xmm0[7],zero
; AVX-NEXT:    vpmovzxwq {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,xmm0[1],zero,zero,zero
; AVX-NEXT:    retq
  %fsub = fsub <2 x float> zeroinitializer, %x
  %bc = bitcast <2 x float> %fsub to <8 x i8>
  %shuffle = shufflevector <8 x i8> %bc, <8 x i8> undef, <2 x i32> <i32 0, i32 1>
  ret <2 x i8> %shuffle
}

