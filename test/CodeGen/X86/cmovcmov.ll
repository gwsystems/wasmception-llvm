; RUN: llc < %s -asm-verbose=false -mtriple=x86_64-unknown-linux | FileCheck %s --check-prefix=CHECK --check-prefix=CMOV
; RUN: llc < %s -asm-verbose=false -mtriple=i686-unknown-linux | FileCheck %s --check-prefix=CHECK --check-prefix=NOCMOV

target datalayout = "e-m:o-i64:64-f80:128-n8:16:32:64-S128"

; Test 2xCMOV patterns exposed after legalization.
; One way to do that is with (select (fcmp une/oeq)), which gets
; legalized to setp/setne.

; CHECK-LABEL: test_select_fcmp_oeq_i32:

; CMOV-NEXT: ucomiss  %xmm1, %xmm0
; CMOV-NEXT: cmovnel  %esi, %edi
; CMOV-NEXT: cmovpl  %esi, %edi
; CMOV-NEXT: movl  %edi, %eax
; CMOV-NEXT: retq

; NOCMOV-NEXT:   flds  8(%esp)
; NOCMOV-NEXT:   flds  4(%esp)
; NOCMOV-NEXT:   fucompp
; NOCMOV-NEXT:   fnstsw  %ax
; NOCMOV-NEXT:   sahf
; NOCMOV-NEXT:   leal  16(%esp), %eax
; NOCMOV-NEXT:   movl  %eax, %ecx
; NOCMOV-NEXT:   jne  [[TBB1:.LBB[0-9_]+]]
; NOCMOV-NEXT:   leal  12(%esp), %ecx
; NOCMOV-NEXT: [[TBB1]]:
; NOCMOV-NEXT:   jp  [[TBB2:.LBB[0-9_]+]]
; NOCMOV-NEXT:   movl  %ecx, %eax
; NOCMOV-NEXT: [[TBB2]]:
; NOCMOV-NEXT:   movl  (%eax), %eax
; NOCMOV-NEXT:   retl
define i32 @test_select_fcmp_oeq_i32(float %a, float %b, i32 %c, i32 %d) #0 {
entry:
  %cmp = fcmp oeq float %a, %b
  %r = select i1 %cmp, i32 %c, i32 %d
  ret i32 %r
}

; CHECK-LABEL: test_select_fcmp_oeq_i64:

; CMOV-NEXT:   ucomiss  %xmm1, %xmm0
; CMOV-NEXT:   cmovneq  %rsi, %rdi
; CMOV-NEXT:   cmovpq  %rsi, %rdi
; CMOV-NEXT:   movq  %rdi, %rax
; CMOV-NEXT:   retq

; NOCMOV-NEXT:   flds  8(%esp)
; NOCMOV-NEXT:   flds  4(%esp)
; NOCMOV-NEXT:   fucompp
; NOCMOV-NEXT:   fnstsw  %ax
; NOCMOV-NEXT:   sahf
; NOCMOV-NEXT:   leal  20(%esp), %ecx
; NOCMOV-NEXT:   movl  %ecx, %eax
; NOCMOV-NEXT:   jne  [[TBB1:.LBB[0-9_]+]]
; NOCMOV-NEXT:   leal  12(%esp), %eax
; NOCMOV-NEXT: [[TBB1]]:
; NOCMOV-NEXT:   jp  [[TBB2:.LBB[0-9_]+]]
; NOCMOV-NEXT:   movl  %eax, %ecx
; NOCMOV-NEXT: [[TBB2]]:
; NOCMOV-NEXT:   movl  (%ecx), %eax
; NOCMOV-NEXT:   orl  $4, %ecx
; NOCMOV-NEXT:   movl  (%ecx), %edx
; NOCMOV-NEXT:   retl
define i64 @test_select_fcmp_oeq_i64(float %a, float %b, i64 %c, i64 %d) #0 {
entry:
  %cmp = fcmp oeq float %a, %b
  %r = select i1 %cmp, i64 %c, i64 %d
  ret i64 %r
}

; CHECK-LABEL: test_select_fcmp_une_i64:

; CMOV-NEXT:   ucomiss  %xmm1, %xmm0
; CMOV-NEXT:   cmovneq  %rdi, %rsi
; CMOV-NEXT:   cmovpq  %rdi, %rsi
; CMOV-NEXT:   movq  %rsi, %rax
; CMOV-NEXT:   retq

; NOCMOV-NEXT:   flds  8(%esp)
; NOCMOV-NEXT:   flds  4(%esp)
; NOCMOV-NEXT:   fucompp
; NOCMOV-NEXT:   fnstsw  %ax
; NOCMOV-NEXT:   sahf
; NOCMOV-NEXT:   leal  12(%esp), %ecx
; NOCMOV-NEXT:   movl  %ecx, %eax
; NOCMOV-NEXT:   jne  [[TBB1:.LBB[0-9_]+]]
; NOCMOV-NEXT:   leal  20(%esp), %eax
; NOCMOV-NEXT: [[TBB1]]:
; NOCMOV-NEXT:   jp  [[TBB2:.LBB[0-9_]+]]
; NOCMOV-NEXT:   movl  %eax, %ecx
; NOCMOV-NEXT: [[TBB2]]:
; NOCMOV-NEXT:   movl  (%ecx), %eax
; NOCMOV-NEXT:   orl  $4, %ecx
; NOCMOV-NEXT:   movl  (%ecx), %edx
; NOCMOV-NEXT:   retl
define i64 @test_select_fcmp_une_i64(float %a, float %b, i64 %c, i64 %d) #0 {
entry:
  %cmp = fcmp une float %a, %b
  %r = select i1 %cmp, i64 %c, i64 %d
  ret i64 %r
}

; CHECK-LABEL: test_select_fcmp_oeq_f64:

; CMOV-NEXT:   ucomiss  %xmm1, %xmm0
; CMOV-NEXT:   movaps  %xmm3, %xmm0
; CMOV-NEXT:   jne  [[TBB1:.LBB[0-9_]+]]
; CMOV-NEXT:   movaps  %xmm2, %xmm0
; CMOV-NEXT: [[TBB1]]:
; CMOV-NEXT:   jp  [[TBB2:.LBB[0-9_]+]]
; CMOV-NEXT:   movaps  %xmm0, %xmm3
; CMOV-NEXT: [[TBB2]]:
; CMOV-NEXT:   movaps  %xmm3, %xmm0
; CMOV-NEXT:   retq

; NOCMOV-NEXT:   flds  8(%esp)
; NOCMOV-NEXT:   flds  4(%esp)
; NOCMOV-NEXT:   fucompp
; NOCMOV-NEXT:   fnstsw  %ax
; NOCMOV-NEXT:   sahf
; NOCMOV-NEXT:   leal  20(%esp), %eax
; NOCMOV-NEXT:   movl  %eax, %ecx
; NOCMOV-NEXT:   jne  [[TBB1:.LBB[0-9_]+]]
; NOCMOV-NEXT:   leal  12(%esp), %ecx
; NOCMOV-NEXT: [[TBB1]]:
; NOCMOV-NEXT:   jp  [[TBB2:.LBB[0-9_]+]]
; NOCMOV-NEXT:   movl  %ecx, %eax
; NOCMOV-NEXT: [[TBB2]]:
; NOCMOV-NEXT:   fldl  (%eax)
; NOCMOV-NEXT:   retl
define double @test_select_fcmp_oeq_f64(float %a, float %b, double %c, double %d) #0 {
entry:
  %cmp = fcmp oeq float %a, %b
  %r = select i1 %cmp, double %c, double %d
  ret double %r
}

; CHECK-LABEL: test_select_fcmp_oeq_v4i32:

; CMOV-NEXT:   ucomiss  %xmm1, %xmm0
; CMOV-NEXT:   movaps  %xmm3, %xmm0
; CMOV-NEXT:   jne  [[TBB1:.LBB[0-9_]+]]
; CMOV-NEXT:   movaps  %xmm2, %xmm0
; CMOV-NEXT: [[TBB1]]:
; CMOV-NEXT:   jp  [[TBB2:.LBB[0-9_]+]]
; CMOV-NEXT:   movaps  %xmm0, %xmm3
; CMOV-NEXT: [[TBB2]]:
; CMOV-NEXT:   movaps  %xmm3, %xmm0
; CMOV-NEXT:   retq

; NOCMOV-NEXT:   pushl  %ebx
; NOCMOV-NEXT:   pushl  %edi
; NOCMOV-NEXT:   pushl  %esi
; NOCMOV-NEXT:   flds  24(%esp)
; NOCMOV-NEXT:   flds  20(%esp)
; NOCMOV-NEXT:   fucompp
; NOCMOV-NEXT:   fnstsw  %ax
; NOCMOV-NEXT:   sahf
; NOCMOV-NEXT:   leal  44(%esp), %eax
; NOCMOV-NEXT:   movl  %eax, %ecx
; NOCMOV-NEXT:   jne  [[TBB1:.LBB[0-9_]+]]
; NOCMOV-NEXT:   leal  28(%esp), %ecx
; NOCMOV-NEXT: [[TBB1]]:
; NOCMOV-NEXT:   jp  [[TBB2:.LBB[0-9_]+]]
; NOCMOV-NEXT:   movl  %ecx, %eax
; NOCMOV-NEXT: [[TBB2]]:
; NOCMOV-NEXT:   movl  (%eax), %eax
; NOCMOV-NEXT:   leal  48(%esp), %ecx
; NOCMOV-NEXT:   movl  %ecx, %edx
; NOCMOV-NEXT:   jne  [[TBB1:.LBB[0-9_]+]]
; NOCMOV-NEXT:   leal  32(%esp), %edx
; NOCMOV-NEXT: [[TBB1]]:
; NOCMOV-NEXT:   jp  [[TBB2:.LBB[0-9_]+]]
; NOCMOV-NEXT:   movl  %edx, %ecx
; NOCMOV-NEXT: [[TBB2]]:
; NOCMOV-NEXT:   movl  (%ecx), %ecx
; NOCMOV-NEXT:   leal  52(%esp), %edx
; NOCMOV-NEXT:   movl  %edx, %esi
; NOCMOV-NEXT:   jne  [[TBB1:.LBB[0-9_]+]]
; NOCMOV-NEXT:   leal  36(%esp), %esi
; NOCMOV-NEXT: [[TBB1]]:
; NOCMOV-NEXT:   jp  [[TBB2:.LBB[0-9_]+]]
; NOCMOV-NEXT:   movl  %esi, %edx
; NOCMOV-NEXT: [[TBB2]]:
; NOCMOV-NEXT:   movl  (%edx), %edx
; NOCMOV-NEXT:   leal  56(%esp), %esi
; NOCMOV-NEXT:   movl  %esi, %ebx
; NOCMOV-NEXT:   jne  [[TBB1:.LBB[0-9_]+]]
; NOCMOV-NEXT:   leal  40(%esp), %ebx
; NOCMOV-NEXT: [[TBB1]]:
; NOCMOV-NEXT:   movl  16(%esp), %edi
; NOCMOV-NEXT:   jp  [[TBB2:.LBB[0-9_]+]]
; NOCMOV-NEXT:   movl  %ebx, %esi
; NOCMOV-NEXT: [[TBB2]]:
; NOCMOV-NEXT:   movl  (%esi), %esi
; NOCMOV-NEXT:   movl  %esi, 12(%edi)
; NOCMOV-NEXT:   movl  %edx, 8(%edi)
; NOCMOV-NEXT:   movl  %ecx, 4(%edi)
; NOCMOV-NEXT:   movl  %eax, (%edi)
; NOCMOV-NEXT:   popl  %esi
; NOCMOV-NEXT:   popl  %edi
; NOCMOV-NEXT:   popl  %ebx
; NOCMOV-NEXT:   retl  $4
define <4 x i32> @test_select_fcmp_oeq_v4i32(float %a, float %b, <4 x i32> %c, <4 x i32> %d) #0 {
entry:
  %cmp = fcmp oeq float %a, %b
  %r = select i1 %cmp, <4 x i32> %c, <4 x i32> %d
  ret <4 x i32> %r
}

; Also make sure we catch the original code-sequence of interest:

; CMOV: [[ONE_F32_LCPI:.LCPI.*]]:
; CMOV-NEXT:   .long  1065353216

; CHECK-LABEL: test_zext_fcmp_une:
; CMOV-NEXT:   ucomiss  %xmm1, %xmm0
; CMOV-NEXT:   movss  [[ONE_F32_LCPI]](%rip), %xmm0
; CMOV-NEXT:   movaps  %xmm0, %xmm1
; CMOV-NEXT:   jne  [[TBB1:.LBB[0-9_]+]]
; CMOV-NEXT:   xorps  %xmm1, %xmm1
; CMOV-NEXT: [[TBB1]]:
; CMOV-NEXT:   jp  [[TBB2:.LBB[0-9_]+]]
; CMOV-NEXT:   movaps  %xmm1, %xmm0
; CMOV-NEXT: [[TBB2]]:
; CMOV-NEXT:   retq

; NOCMOV:     jne
; NOCMOV:     jp
define float @test_zext_fcmp_une(float %a, float %b) #0 {
entry:
  %cmp = fcmp une float %a, %b
  %conv1 = zext i1 %cmp to i32
  %conv2 = sitofp i32 %conv1 to float
  ret float %conv2
}

; CMOV: [[ONE_F32_LCPI:.LCPI.*]]:
; CMOV-NEXT:   .long  1065353216

; CHECK-LABEL: test_zext_fcmp_oeq:
; CMOV-NEXT:   ucomiss  %xmm1, %xmm0
; CMOV-NEXT:   xorps  %xmm0, %xmm0
; CMOV-NEXT:   xorps  %xmm1, %xmm1
; CMOV-NEXT:   jne  [[TBB1:.LBB[0-9_]+]]
; CMOV-NEXT:   movss  [[ONE_F32_LCPI]](%rip), %xmm1
; CMOV-NEXT: [[TBB1]]:
; CMOV-NEXT:   jp  [[TBB2:.LBB[0-9_]+]]
; CMOV-NEXT:   movaps  %xmm1, %xmm0
; CMOV-NEXT: [[TBB2]]:
; CMOV-NEXT:   retq

; NOCMOV:   jne
; NOCMOV:   jp
define float @test_zext_fcmp_oeq(float %a, float %b) #0 {
entry:
  %cmp = fcmp oeq float %a, %b
  %conv1 = zext i1 %cmp to i32
  %conv2 = sitofp i32 %conv1 to float
  ret float %conv2
}

attributes #0 = { nounwind }
