; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-unknown -mattr=+avx | FileCheck %s --check-prefix=X32
; RUN: llc < %s -mtriple=x86_64-unknown -mattr=+avx | FileCheck %s --check-prefix=X64

define <4 x i64> @autogen_SD88863() {
; X32-LABEL: autogen_SD88863:
; X32:       # %bb.0: # %BB
; X32-NEXT:    vpermilps {{.*#+}} xmm0 = xmm0[2,3,0,1]
; X32-NEXT:    vinsertf128 $1, %xmm0, %ymm0, %ymm0
; X32-NEXT:    vxorpd %xmm1, %xmm1, %xmm1
; X32-NEXT:    vblendpd {{.*#+}} ymm0 = ymm1[0,1],ymm0[2],ymm1[3]
; X32-NEXT:    movb $1, %al
; X32-NEXT:    .p2align 4, 0x90
; X32-NEXT:  .LBB0_1: # %CF
; X32-NEXT:    # =>This Inner Loop Header: Depth=1
; X32-NEXT:    testb %al, %al
; X32-NEXT:    jne .LBB0_1
; X32-NEXT:  # %bb.2: # %CF240
; X32-NEXT:    retl
;
; X64-LABEL: autogen_SD88863:
; X64:       # %bb.0: # %BB
; X64-NEXT:    vpermilps {{.*#+}} xmm0 = xmm0[2,3,0,1]
; X64-NEXT:    vinsertf128 $1, %xmm0, %ymm0, %ymm0
; X64-NEXT:    vxorpd %xmm1, %xmm1, %xmm1
; X64-NEXT:    vblendpd {{.*#+}} ymm0 = ymm1[0,1],ymm0[2],ymm1[3]
; X64-NEXT:    movb $1, %al
; X64-NEXT:    .p2align 4, 0x90
; X64-NEXT:  .LBB0_1: # %CF
; X64-NEXT:    # =>This Inner Loop Header: Depth=1
; X64-NEXT:    testb %al, %al
; X64-NEXT:    jne .LBB0_1
; X64-NEXT:  # %bb.2: # %CF240
; X64-NEXT:    retq
BB:
  %I26 = insertelement <4 x i64> undef, i64 undef, i32 2
  br label %CF

CF:
  %E66 = extractelement <4 x i64> %I26, i32 1
  %I68 = insertelement <4 x i64> zeroinitializer, i64 %E66, i32 2
  %Cmp72 = icmp eq i32 0, 0
  br i1 %Cmp72, label %CF, label %CF240

CF240:
  ret <4 x i64> %I68
}
