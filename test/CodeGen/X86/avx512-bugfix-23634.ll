; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -march=x86-64 -mtriple=x86_64-apple-darwin -mcpu=knl | FileCheck %s

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define void @f_fu(float* %ret, float*  %aa, float %b) {
; CHECK-LABEL: f_fu:
; CHECK:       ## BB#0: ## %allocas
; CHECK-NEXT:    vcvttss2si %xmm0, %eax
; CHECK-NEXT:    vpbroadcastd %eax, %zmm0
; CHECK-NEXT:    vcvttps2dq (%rsi), %zmm1
; CHECK-NEXT:    vpsrld $31, %zmm0, %zmm2
; CHECK-NEXT:    vpaddd %zmm2, %zmm0, %zmm2
; CHECK-NEXT:    vpsrad $1, %zmm2, %zmm2
; CHECK-NEXT:    movw $-21846, %ax ## imm = 0xAAAA
; CHECK-NEXT:    kmovw %eax, %k1
; CHECK-NEXT:    vmovdqa32 {{.*}}(%rip), %zmm1 {%k1}
; CHECK-NEXT:    vpaddd %zmm0, %zmm2, %zmm0
; CHECK-NEXT:    vpaddd %zmm1, %zmm0, %zmm0
; CHECK-NEXT:    vcvtdq2ps %zmm0, %zmm0
; CHECK-NEXT:    vmovups %zmm0, (%rdi)
; CHECK-NEXT:    retq
allocas:
  %ptr_cast_for_load = bitcast float* %aa to <16 x float>*
  %ptr_masked_load.39 = load <16 x float>, <16 x float>* %ptr_cast_for_load, align 4
  %b_load_to_int32 = fptosi float %b to i32
  %b_load_to_int32_broadcast_init = insertelement <16 x i32> undef, i32 %b_load_to_int32, i32 0
  %b_load_to_int32_broadcast = shufflevector <16 x i32> %b_load_to_int32_broadcast_init, <16 x i32> undef, <16 x i32> zeroinitializer
  %b_to_int32 = fptosi float %b to i32
  %b_to_int32_broadcast_init = insertelement <16 x i32> undef, i32 %b_to_int32, i32 0
  %b_to_int32_broadcast = shufflevector <16 x i32> %b_to_int32_broadcast_init, <16 x i32> undef, <16 x i32> zeroinitializer

  %a_load_to_int32 = fptosi <16 x float> %ptr_masked_load.39 to <16 x i32>
  %div_v019_load_ = sdiv <16 x i32> %b_to_int32_broadcast, <i32 2, i32 2, i32 2, i32 2, i32 2, i32 2, i32 2, i32 2, i32 2, i32 2, i32 2, i32 2, i32 2, i32 2, i32 2, i32 2>

  %v1.i = select <16 x i1> <i1 false, i1 true, i1 false, i1 true, i1 false, i1 true, i1 false, i1 true, i1 false, i1 true, i1 false, i1 true, i1 false, i1 true, i1 false, i1 true>, <16 x i32> <i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 16, i32 17>, <16 x i32> %a_load_to_int32

  %foo_test = add <16 x i32> %div_v019_load_, %b_load_to_int32_broadcast


  %add_struct_offset_y_struct_offset33_x = add <16 x i32> %foo_test, %v1.i

  %val = sitofp <16 x i32> %add_struct_offset_y_struct_offset33_x to <16 x float>
  %ptrcast = bitcast float* %ret to <16 x float>*
  store <16 x float> %val, <16 x float>* %ptrcast, align 4
  ret void
}
