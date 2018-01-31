; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown -mattr=+avx512f -O0 | FileCheck %s

define <16 x float> @makefloat(float %f1, float %f2, float %f3, float %f4, float %f5, float %f6, float %f7, float %f8, float %f9, float %f10, float %f11, float %f12, float %f13, float %f14, float %f15, float %f16) #0 {
; CHECK-LABEL: makefloat:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    pushq %rbp
; CHECK-NEXT:    .cfi_def_cfa_offset 16
; CHECK-NEXT:    .cfi_offset %rbp, -16
; CHECK-NEXT:    movq %rsp, %rbp
; CHECK-NEXT:    .cfi_def_cfa_register %rbp
; CHECK-NEXT:    andq $-64, %rsp
; CHECK-NEXT:    subq $256, %rsp # imm = 0x100
; CHECK-NEXT:    vmovss {{.*#+}} xmm8 = mem[0],zero,zero,zero
; CHECK-NEXT:    vmovss {{.*#+}} xmm9 = mem[0],zero,zero,zero
; CHECK-NEXT:    vmovss {{.*#+}} xmm10 = mem[0],zero,zero,zero
; CHECK-NEXT:    vmovss {{.*#+}} xmm11 = mem[0],zero,zero,zero
; CHECK-NEXT:    vmovss {{.*#+}} xmm12 = mem[0],zero,zero,zero
; CHECK-NEXT:    vmovss {{.*#+}} xmm13 = mem[0],zero,zero,zero
; CHECK-NEXT:    vmovss {{.*#+}} xmm14 = mem[0],zero,zero,zero
; CHECK-NEXT:    vmovss {{.*#+}} xmm15 = mem[0],zero,zero,zero
; CHECK-NEXT:    vmovss %xmm0, {{[0-9]+}}(%rsp)
; CHECK-NEXT:    vmovss %xmm1, {{[0-9]+}}(%rsp)
; CHECK-NEXT:    vmovss %xmm2, {{[0-9]+}}(%rsp)
; CHECK-NEXT:    vmovss %xmm3, {{[0-9]+}}(%rsp)
; CHECK-NEXT:    vmovss %xmm4, {{[0-9]+}}(%rsp)
; CHECK-NEXT:    vmovss %xmm5, {{[0-9]+}}(%rsp)
; CHECK-NEXT:    vmovss %xmm6, {{[0-9]+}}(%rsp)
; CHECK-NEXT:    vmovss %xmm7, {{[0-9]+}}(%rsp)
; CHECK-NEXT:    vmovss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-NEXT:    vmovss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; CHECK-NEXT:    vmovss {{.*#+}} xmm2 = mem[0],zero,zero,zero
; CHECK-NEXT:    vmovss {{.*#+}} xmm3 = mem[0],zero,zero,zero
; CHECK-NEXT:    vmovss {{.*#+}} xmm4 = mem[0],zero,zero,zero
; CHECK-NEXT:    vmovss {{.*#+}} xmm5 = mem[0],zero,zero,zero
; CHECK-NEXT:    vmovss {{.*#+}} xmm6 = mem[0],zero,zero,zero
; CHECK-NEXT:    vmovss {{.*#+}} xmm7 = mem[0],zero,zero,zero
; CHECK-NEXT:    vmovss {{.*#+}} xmm16 = mem[0],zero,zero,zero
; CHECK-NEXT:    vmovss {{.*#+}} xmm17 = mem[0],zero,zero,zero
; CHECK-NEXT:    vmovss {{.*#+}} xmm18 = mem[0],zero,zero,zero
; CHECK-NEXT:    vmovss {{.*#+}} xmm19 = mem[0],zero,zero,zero
; CHECK-NEXT:    vmovss {{.*#+}} xmm20 = mem[0],zero,zero,zero
; CHECK-NEXT:    vmovss {{.*#+}} xmm21 = mem[0],zero,zero,zero
; CHECK-NEXT:    vmovss {{.*#+}} xmm22 = mem[0],zero,zero,zero
; CHECK-NEXT:    vmovss {{.*#+}} xmm23 = mem[0],zero,zero,zero
; CHECK-NEXT:    vmovss %xmm0, {{[0-9]+}}(%rsp)
; CHECK-NEXT:    vmovss %xmm1, {{[0-9]+}}(%rsp)
; CHECK-NEXT:    vmovss %xmm2, {{[0-9]+}}(%rsp)
; CHECK-NEXT:    vmovss %xmm3, {{[0-9]+}}(%rsp)
; CHECK-NEXT:    vmovss %xmm4, {{[0-9]+}}(%rsp)
; CHECK-NEXT:    vmovss %xmm5, {{[0-9]+}}(%rsp)
; CHECK-NEXT:    vmovss %xmm6, {{[0-9]+}}(%rsp)
; CHECK-NEXT:    vmovss %xmm7, {{[0-9]+}}(%rsp)
; CHECK-NEXT:    vmovss %xmm16, {{[0-9]+}}(%rsp)
; CHECK-NEXT:    vmovss %xmm17, {{[0-9]+}}(%rsp)
; CHECK-NEXT:    vmovss %xmm18, {{[0-9]+}}(%rsp)
; CHECK-NEXT:    vmovss %xmm19, {{[0-9]+}}(%rsp)
; CHECK-NEXT:    vmovss %xmm20, {{[0-9]+}}(%rsp)
; CHECK-NEXT:    vmovss %xmm21, {{[0-9]+}}(%rsp)
; CHECK-NEXT:    vmovss %xmm22, {{[0-9]+}}(%rsp)
; CHECK-NEXT:    vmovss %xmm23, {{[0-9]+}}(%rsp)
; CHECK-NEXT:    vmovss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-NEXT:    vmovss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; CHECK-NEXT:    vinsertps {{.*#+}} xmm0 = xmm1[0],xmm0[0],xmm1[2,3]
; CHECK-NEXT:    vmovss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; CHECK-NEXT:    vinsertps {{.*#+}} xmm0 = xmm0[0,1],xmm1[0],xmm0[3]
; CHECK-NEXT:    vmovss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; CHECK-NEXT:    vinsertps {{.*#+}} xmm0 = xmm0[0,1,2],xmm1[0]
; CHECK-NEXT:    vmovss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; CHECK-NEXT:    vmovss {{.*#+}} xmm2 = mem[0],zero,zero,zero
; CHECK-NEXT:    vinsertps {{.*#+}} xmm1 = xmm2[0],xmm1[0],xmm2[2,3]
; CHECK-NEXT:    vmovss {{.*#+}} xmm2 = mem[0],zero,zero,zero
; CHECK-NEXT:    vinsertps {{.*#+}} xmm1 = xmm1[0,1],xmm2[0],xmm1[3]
; CHECK-NEXT:    vmovss {{.*#+}} xmm2 = mem[0],zero,zero,zero
; CHECK-NEXT:    vinsertps {{.*#+}} xmm1 = xmm1[0,1,2],xmm2[0]
; CHECK-NEXT:    # implicit-def: $ymm2
; CHECK-NEXT:    vmovaps %xmm1, %xmm2
; CHECK-NEXT:    vinsertf128 $1, %xmm0, %ymm2, %ymm2
; CHECK-NEXT:    vmovss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-NEXT:    vmovss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; CHECK-NEXT:    vinsertps {{.*#+}} xmm0 = xmm1[0],xmm0[0],xmm1[2,3]
; CHECK-NEXT:    vmovss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; CHECK-NEXT:    vinsertps {{.*#+}} xmm0 = xmm0[0,1],xmm1[0],xmm0[3]
; CHECK-NEXT:    vmovss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; CHECK-NEXT:    vinsertps {{.*#+}} xmm0 = xmm0[0,1,2],xmm1[0]
; CHECK-NEXT:    vmovss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; CHECK-NEXT:    vmovss {{.*#+}} xmm3 = mem[0],zero,zero,zero
; CHECK-NEXT:    vinsertps {{.*#+}} xmm1 = xmm3[0],xmm1[0],xmm3[2,3]
; CHECK-NEXT:    vmovss {{.*#+}} xmm3 = mem[0],zero,zero,zero
; CHECK-NEXT:    vinsertps {{.*#+}} xmm1 = xmm1[0,1],xmm3[0],xmm1[3]
; CHECK-NEXT:    vmovss {{.*#+}} xmm3 = mem[0],zero,zero,zero
; CHECK-NEXT:    vinsertps {{.*#+}} xmm1 = xmm1[0,1,2],xmm3[0]
; CHECK-NEXT:    # implicit-def: $ymm3
; CHECK-NEXT:    vmovaps %xmm1, %xmm3
; CHECK-NEXT:    vinsertf128 $1, %xmm0, %ymm3, %ymm3
; CHECK-NEXT:    # implicit-def: $zmm24
; CHECK-NEXT:    vmovaps %zmm3, %zmm24
; CHECK-NEXT:    vinsertf64x4 $1, %ymm2, %zmm24, %zmm24
; CHECK-NEXT:    vmovaps %zmm24, {{[0-9]+}}(%rsp)
; CHECK-NEXT:    vmovaps {{[0-9]+}}(%rsp), %zmm0
; CHECK-NEXT:    vmovss %xmm15, {{[0-9]+}}(%rsp) # 4-byte Spill
; CHECK-NEXT:    vmovss %xmm8, {{[0-9]+}}(%rsp) # 4-byte Spill
; CHECK-NEXT:    vmovss %xmm9, {{[0-9]+}}(%rsp) # 4-byte Spill
; CHECK-NEXT:    vmovss %xmm10, {{[0-9]+}}(%rsp) # 4-byte Spill
; CHECK-NEXT:    vmovss %xmm11, {{[0-9]+}}(%rsp) # 4-byte Spill
; CHECK-NEXT:    vmovss %xmm12, {{[0-9]+}}(%rsp) # 4-byte Spill
; CHECK-NEXT:    vmovss %xmm13, {{[0-9]+}}(%rsp) # 4-byte Spill
; CHECK-NEXT:    vmovss %xmm14, (%rsp) # 4-byte Spill
; CHECK-NEXT:    movq %rbp, %rsp
; CHECK-NEXT:    popq %rbp
; CHECK-NEXT:    retq
entry:
  %__A.addr.i = alloca float, align 4
  %__B.addr.i = alloca float, align 4
  %__C.addr.i = alloca float, align 4
  %__D.addr.i = alloca float, align 4
  %__E.addr.i = alloca float, align 4
  %__F.addr.i = alloca float, align 4
  %__G.addr.i = alloca float, align 4
  %__H.addr.i = alloca float, align 4
  %__I.addr.i = alloca float, align 4
  %__J.addr.i = alloca float, align 4
  %__K.addr.i = alloca float, align 4
  %__L.addr.i = alloca float, align 4
  %__M.addr.i = alloca float, align 4
  %__N.addr.i = alloca float, align 4
  %__O.addr.i = alloca float, align 4
  %__P.addr.i = alloca float, align 4
  %.compoundliteral.i = alloca <16 x float>, align 64
  %f1.addr = alloca float, align 4
  %f2.addr = alloca float, align 4
  %f3.addr = alloca float, align 4
  %f4.addr = alloca float, align 4
  %f5.addr = alloca float, align 4
  %f6.addr = alloca float, align 4
  %f7.addr = alloca float, align 4
  %f8.addr = alloca float, align 4
  %f9.addr = alloca float, align 4
  %f10.addr = alloca float, align 4
  %f11.addr = alloca float, align 4
  %f12.addr = alloca float, align 4
  %f13.addr = alloca float, align 4
  %f14.addr = alloca float, align 4
  %f15.addr = alloca float, align 4
  %f16.addr = alloca float, align 4
  store float %f1, float* %f1.addr, align 4
  store float %f2, float* %f2.addr, align 4
  store float %f3, float* %f3.addr, align 4
  store float %f4, float* %f4.addr, align 4
  store float %f5, float* %f5.addr, align 4
  store float %f6, float* %f6.addr, align 4
  store float %f7, float* %f7.addr, align 4
  store float %f8, float* %f8.addr, align 4
  store float %f9, float* %f9.addr, align 4
  store float %f10, float* %f10.addr, align 4
  store float %f11, float* %f11.addr, align 4
  store float %f12, float* %f12.addr, align 4
  store float %f13, float* %f13.addr, align 4
  store float %f14, float* %f14.addr, align 4
  store float %f15, float* %f15.addr, align 4
  store float %f16, float* %f16.addr, align 4
  %0 = load float, float* %f16.addr, align 4
  %1 = load float, float* %f15.addr, align 4
  %2 = load float, float* %f14.addr, align 4
  %3 = load float, float* %f13.addr, align 4
  %4 = load float, float* %f12.addr, align 4
  %5 = load float, float* %f11.addr, align 4
  %6 = load float, float* %f10.addr, align 4
  %7 = load float, float* %f9.addr, align 4
  %8 = load float, float* %f8.addr, align 4
  %9 = load float, float* %f7.addr, align 4
  %10 = load float, float* %f6.addr, align 4
  %11 = load float, float* %f5.addr, align 4
  %12 = load float, float* %f4.addr, align 4
  %13 = load float, float* %f3.addr, align 4
  %14 = load float, float* %f2.addr, align 4
  %15 = load float, float* %f1.addr, align 4
  store float %0, float* %__A.addr.i, align 4
  store float %1, float* %__B.addr.i, align 4
  store float %2, float* %__C.addr.i, align 4
  store float %3, float* %__D.addr.i, align 4
  store float %4, float* %__E.addr.i, align 4
  store float %5, float* %__F.addr.i, align 4
  store float %6, float* %__G.addr.i, align 4
  store float %7, float* %__H.addr.i, align 4
  store float %8, float* %__I.addr.i, align 4
  store float %9, float* %__J.addr.i, align 4
  store float %10, float* %__K.addr.i, align 4
  store float %11, float* %__L.addr.i, align 4
  store float %12, float* %__M.addr.i, align 4
  store float %13, float* %__N.addr.i, align 4
  store float %14, float* %__O.addr.i, align 4
  store float %15, float* %__P.addr.i, align 4
  %16 = load float, float* %__P.addr.i, align 4
  %vecinit.i = insertelement <16 x float> undef, float %16, i32 0
  %17 = load float, float* %__O.addr.i, align 4
  %vecinit1.i = insertelement <16 x float> %vecinit.i, float %17, i32 1
  %18 = load float, float* %__N.addr.i, align 4
  %vecinit2.i = insertelement <16 x float> %vecinit1.i, float %18, i32 2
  %19 = load float, float* %__M.addr.i, align 4
  %vecinit3.i = insertelement <16 x float> %vecinit2.i, float %19, i32 3
  %20 = load float, float* %__L.addr.i, align 4
  %vecinit4.i = insertelement <16 x float> %vecinit3.i, float %20, i32 4
  %21 = load float, float* %__K.addr.i, align 4
  %vecinit5.i = insertelement <16 x float> %vecinit4.i, float %21, i32 5
  %22 = load float, float* %__J.addr.i, align 4
  %vecinit6.i = insertelement <16 x float> %vecinit5.i, float %22, i32 6
  %23 = load float, float* %__I.addr.i, align 4
  %vecinit7.i = insertelement <16 x float> %vecinit6.i, float %23, i32 7
  %24 = load float, float* %__H.addr.i, align 4
  %vecinit8.i = insertelement <16 x float> %vecinit7.i, float %24, i32 8
  %25 = load float, float* %__G.addr.i, align 4
  %vecinit9.i = insertelement <16 x float> %vecinit8.i, float %25, i32 9
  %26 = load float, float* %__F.addr.i, align 4
  %vecinit10.i = insertelement <16 x float> %vecinit9.i, float %26, i32 10
  %27 = load float, float* %__E.addr.i, align 4
  %vecinit11.i = insertelement <16 x float> %vecinit10.i, float %27, i32 11
  %28 = load float, float* %__D.addr.i, align 4
  %vecinit12.i = insertelement <16 x float> %vecinit11.i, float %28, i32 12
  %29 = load float, float* %__C.addr.i, align 4
  %vecinit13.i = insertelement <16 x float> %vecinit12.i, float %29, i32 13
  %30 = load float, float* %__B.addr.i, align 4
  %vecinit14.i = insertelement <16 x float> %vecinit13.i, float %30, i32 14
  %31 = load float, float* %__A.addr.i, align 4
  %vecinit15.i = insertelement <16 x float> %vecinit14.i, float %31, i32 15
  store <16 x float> %vecinit15.i, <16 x float>* %.compoundliteral.i, align 64
  %32 = load <16 x float>, <16 x float>* %.compoundliteral.i, align 64
  ret <16 x float> %32
}
