; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-apple-darwin -mcpu=knl | FileCheck %s -check-prefix=X32 -check-prefix=X32-KNL
; RUN: llc < %s -mtriple=i686-apple-darwin -mcpu=skx | FileCheck %s -check-prefix=X32 -check-prefix=X32-SKX
; RUN: llc < %s -mtriple=i386-pc-win32 -mcpu=knl | FileCheck %s -check-prefix=WIN32 -check-prefix=WIN32-KNL
; RUN: llc < %s -mtriple=i386-pc-win32 -mcpu=skx | FileCheck %s -check-prefix=WIN32 -check-prefix=WIN32-SKX
; RUN: llc < %s -mtriple=x86_64-win32 -mcpu=knl | FileCheck %s -check-prefix=WIN64 -check-prefix=WIN64-KNL
; RUN: llc < %s -mtriple=x86_64-win32 -mcpu=skx | FileCheck %s -check-prefix=WIN64 -check-prefix=WIN64-SKX
; RUN: llc < %s -mtriple=x86_64-apple-darwin -mcpu=knl | FileCheck %s -check-prefix=X64 -check-prefix=X64-KNL
; RUN: llc < %s -mtriple=x86_64-apple-darwin -mcpu=skx | FileCheck %s -check-prefix=X64 -check-prefix=X64-SKX

declare <16 x float> @func_float16_ptr(<16 x float>, <16 x float> *)
declare <16 x float> @func_float16(<16 x float>, <16 x float>)
declare i32 @func_int(i32, i32)

;test calling conventions - input parameters
define <16 x float> @testf16_inp(<16 x float> %a, <16 x float> %b) nounwind {
; X32-LABEL: testf16_inp:
; X32:       ## %bb.0:
; X32-NEXT:    pushl %ebp
; X32-NEXT:    movl %esp, %ebp
; X32-NEXT:    andl $-64, %esp
; X32-NEXT:    subl $192, %esp
; X32-NEXT:    vaddps %zmm1, %zmm0, %zmm0
; X32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X32-NEXT:    movl %eax, (%esp)
; X32-NEXT:    calll _func_float16_ptr
; X32-NEXT:    vaddps {{[0-9]+}}(%esp), %zmm0, %zmm0
; X32-NEXT:    movl %ebp, %esp
; X32-NEXT:    popl %ebp
; X32-NEXT:    retl
;
; WIN32-LABEL: testf16_inp:
; WIN32:       # %bb.0:
; WIN32-NEXT:    pushl %ebp
; WIN32-NEXT:    movl %esp, %ebp
; WIN32-NEXT:    andl $-64, %esp
; WIN32-NEXT:    subl $128, %esp
; WIN32-NEXT:    vaddps %zmm1, %zmm0, %zmm0
; WIN32-NEXT:    movl %esp, %eax
; WIN32-NEXT:    pushl %eax
; WIN32-NEXT:    calll _func_float16_ptr
; WIN32-NEXT:    addl $4, %esp
; WIN32-NEXT:    vaddps (%esp), %zmm0, %zmm0
; WIN32-NEXT:    movl %ebp, %esp
; WIN32-NEXT:    popl %ebp
; WIN32-NEXT:    retl
;
; WIN64-LABEL: testf16_inp:
; WIN64:       # %bb.0:
; WIN64-NEXT:    pushq %rbp
; WIN64-NEXT:    subq $176, %rsp
; WIN64-NEXT:    leaq {{[0-9]+}}(%rsp), %rbp
; WIN64-NEXT:    andq $-64, %rsp
; WIN64-NEXT:    vmovaps (%rcx), %zmm0
; WIN64-NEXT:    vaddps (%rdx), %zmm0, %zmm0
; WIN64-NEXT:    leaq {{[0-9]+}}(%rsp), %rcx
; WIN64-NEXT:    callq func_float16_ptr
; WIN64-NEXT:    vaddps {{[0-9]+}}(%rsp), %zmm0, %zmm0
; WIN64-NEXT:    leaq 48(%rbp), %rsp
; WIN64-NEXT:    popq %rbp
; WIN64-NEXT:    retq
;
; X64-LABEL: testf16_inp:
; X64:       ## %bb.0:
; X64-NEXT:    pushq %rbp
; X64-NEXT:    movq %rsp, %rbp
; X64-NEXT:    pushq %r13
; X64-NEXT:    pushq %r12
; X64-NEXT:    andq $-64, %rsp
; X64-NEXT:    subq $128, %rsp
; X64-NEXT:    vaddps %zmm1, %zmm0, %zmm0
; X64-NEXT:    movq %rsp, %rdi
; X64-NEXT:    callq _func_float16_ptr
; X64-NEXT:    vaddps (%rsp), %zmm0, %zmm0
; X64-NEXT:    leaq -16(%rbp), %rsp
; X64-NEXT:    popq %r12
; X64-NEXT:    popq %r13
; X64-NEXT:    popq %rbp
; X64-NEXT:    retq
  %y = alloca <16 x float>, align 16
  %x = fadd <16 x float> %a, %b
  %1 = call intel_ocl_bicc <16 x float> @func_float16_ptr(<16 x float> %x, <16 x float>* %y)
  %2 = load <16 x float>, <16 x float>* %y, align 16
  %3 = fadd <16 x float> %2, %1
  ret <16 x float> %3
}

;test calling conventions - preserved registers

define <16 x float> @testf16_regs(<16 x float> %a, <16 x float> %b) nounwind {
; X32-LABEL: testf16_regs:
; X32:       ## %bb.0:
; X32-NEXT:    pushl %ebp
; X32-NEXT:    movl %esp, %ebp
; X32-NEXT:    andl $-64, %esp
; X32-NEXT:    subl $256, %esp ## imm = 0x100
; X32-NEXT:    vmovaps %zmm1, {{[-0-9]+}}(%e{{[sb]}}p) ## 64-byte Spill
; X32-NEXT:    vaddps %zmm1, %zmm0, %zmm0
; X32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X32-NEXT:    movl %eax, (%esp)
; X32-NEXT:    calll _func_float16_ptr
; X32-NEXT:    vaddps {{[-0-9]+}}(%e{{[sb]}}p), %zmm0, %zmm0 ## 64-byte Folded Reload
; X32-NEXT:    vaddps {{[0-9]+}}(%esp), %zmm0, %zmm0
; X32-NEXT:    movl %ebp, %esp
; X32-NEXT:    popl %ebp
; X32-NEXT:    retl
;
; WIN32-LABEL: testf16_regs:
; WIN32:       # %bb.0:
; WIN32-NEXT:    pushl %ebp
; WIN32-NEXT:    movl %esp, %ebp
; WIN32-NEXT:    andl $-64, %esp
; WIN32-NEXT:    subl $192, %esp
; WIN32-NEXT:    vmovaps %zmm1, (%esp) # 64-byte Spill
; WIN32-NEXT:    vaddps %zmm1, %zmm0, %zmm0
; WIN32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; WIN32-NEXT:    pushl %eax
; WIN32-NEXT:    calll _func_float16_ptr
; WIN32-NEXT:    addl $4, %esp
; WIN32-NEXT:    vaddps (%esp), %zmm0, %zmm0 # 64-byte Folded Reload
; WIN32-NEXT:    vaddps {{[0-9]+}}(%esp), %zmm0, %zmm0
; WIN32-NEXT:    movl %ebp, %esp
; WIN32-NEXT:    popl %ebp
; WIN32-NEXT:    retl
;
; WIN64-LABEL: testf16_regs:
; WIN64:       # %bb.0:
; WIN64-NEXT:    pushq %rbp
; WIN64-NEXT:    subq $176, %rsp
; WIN64-NEXT:    leaq {{[0-9]+}}(%rsp), %rbp
; WIN64-NEXT:    andq $-64, %rsp
; WIN64-NEXT:    vmovaps (%rdx), %zmm16
; WIN64-NEXT:    vaddps (%rcx), %zmm16, %zmm0
; WIN64-NEXT:    leaq {{[0-9]+}}(%rsp), %rcx
; WIN64-NEXT:    callq func_float16_ptr
; WIN64-NEXT:    vaddps %zmm16, %zmm0, %zmm0
; WIN64-NEXT:    vaddps {{[0-9]+}}(%rsp), %zmm0, %zmm0
; WIN64-NEXT:    leaq 48(%rbp), %rsp
; WIN64-NEXT:    popq %rbp
; WIN64-NEXT:    retq
;
; X64-LABEL: testf16_regs:
; X64:       ## %bb.0:
; X64-NEXT:    pushq %rbp
; X64-NEXT:    movq %rsp, %rbp
; X64-NEXT:    pushq %r13
; X64-NEXT:    pushq %r12
; X64-NEXT:    andq $-64, %rsp
; X64-NEXT:    subq $128, %rsp
; X64-NEXT:    vmovaps %zmm1, %zmm16
; X64-NEXT:    vaddps %zmm1, %zmm0, %zmm0
; X64-NEXT:    movq %rsp, %rdi
; X64-NEXT:    callq _func_float16_ptr
; X64-NEXT:    vaddps %zmm16, %zmm0, %zmm0
; X64-NEXT:    vaddps (%rsp), %zmm0, %zmm0
; X64-NEXT:    leaq -16(%rbp), %rsp
; X64-NEXT:    popq %r12
; X64-NEXT:    popq %r13
; X64-NEXT:    popq %rbp
; X64-NEXT:    retq
  %y = alloca <16 x float>, align 16
  %x = fadd <16 x float> %a, %b
  %1 = call intel_ocl_bicc <16 x float> @func_float16_ptr(<16 x float> %x, <16 x float>* %y)
  %2 = load <16 x float>, <16 x float>* %y, align 16
  %3 = fadd <16 x float> %1, %b
  %4 = fadd <16 x float> %2, %3
  ret <16 x float> %4
}

; test calling conventions - prolog and epilog
define intel_ocl_bicc <16 x float> @test_prolog_epilog(<16 x float> %a, <16 x float> %b) nounwind {
; X32-LABEL: test_prolog_epilog:
; X32:       ## %bb.0:
; X32-NEXT:    subl $12, %esp
; X32-NEXT:    calll _func_float16
; X32-NEXT:    addl $12, %esp
; X32-NEXT:    retl
;
; WIN32-LABEL: test_prolog_epilog:
; WIN32:       # %bb.0:
; WIN32-NEXT:    calll _func_float16
; WIN32-NEXT:    retl
;
; WIN64-KNL-LABEL: test_prolog_epilog:
; WIN64-KNL:       # %bb.0:
; WIN64-KNL-NEXT:    pushq %rbp
; WIN64-KNL-NEXT:    subq $1264, %rsp # imm = 0x4F0
; WIN64-KNL-NEXT:    leaq {{[0-9]+}}(%rsp), %rbp
; WIN64-KNL-NEXT:    kmovw %k7, {{[-0-9]+}}(%r{{[sb]}}p) # 2-byte Spill
; WIN64-KNL-NEXT:    kmovw %k6, {{[-0-9]+}}(%r{{[sb]}}p) # 2-byte Spill
; WIN64-KNL-NEXT:    kmovw %k5, {{[-0-9]+}}(%r{{[sb]}}p) # 2-byte Spill
; WIN64-KNL-NEXT:    kmovw %k4, {{[-0-9]+}}(%r{{[sb]}}p) # 2-byte Spill
; WIN64-KNL-NEXT:    vmovaps %zmm21, {{[-0-9]+}}(%r{{[sb]}}p) # 64-byte Spill
; WIN64-KNL-NEXT:    vmovaps %zmm20, {{[-0-9]+}}(%r{{[sb]}}p) # 64-byte Spill
; WIN64-KNL-NEXT:    vmovaps %zmm19, {{[-0-9]+}}(%r{{[sb]}}p) # 64-byte Spill
; WIN64-KNL-NEXT:    vmovaps %zmm18, {{[-0-9]+}}(%r{{[sb]}}p) # 64-byte Spill
; WIN64-KNL-NEXT:    vmovaps %zmm17, {{[-0-9]+}}(%r{{[sb]}}p) # 64-byte Spill
; WIN64-KNL-NEXT:    vmovaps %zmm16, {{[-0-9]+}}(%r{{[sb]}}p) # 64-byte Spill
; WIN64-KNL-NEXT:    vmovaps %zmm15, {{[-0-9]+}}(%r{{[sb]}}p) # 64-byte Spill
; WIN64-KNL-NEXT:    vmovaps %zmm14, {{[-0-9]+}}(%r{{[sb]}}p) # 64-byte Spill
; WIN64-KNL-NEXT:    vmovaps %zmm13, {{[-0-9]+}}(%r{{[sb]}}p) # 64-byte Spill
; WIN64-KNL-NEXT:    vmovaps %zmm12, {{[-0-9]+}}(%r{{[sb]}}p) # 64-byte Spill
; WIN64-KNL-NEXT:    vmovaps %zmm11, {{[-0-9]+}}(%r{{[sb]}}p) # 64-byte Spill
; WIN64-KNL-NEXT:    vmovaps %zmm10, {{[-0-9]+}}(%r{{[sb]}}p) # 64-byte Spill
; WIN64-KNL-NEXT:    vmovaps %zmm9, {{[-0-9]+}}(%r{{[sb]}}p) # 64-byte Spill
; WIN64-KNL-NEXT:    vmovaps %zmm8, {{[-0-9]+}}(%r{{[sb]}}p) # 64-byte Spill
; WIN64-KNL-NEXT:    vmovaps %zmm7, {{[-0-9]+}}(%r{{[sb]}}p) # 64-byte Spill
; WIN64-KNL-NEXT:    vmovaps %zmm6, {{[-0-9]+}}(%r{{[sb]}}p) # 64-byte Spill
; WIN64-KNL-NEXT:    andq $-64, %rsp
; WIN64-KNL-NEXT:    vmovaps %zmm1, {{[0-9]+}}(%rsp)
; WIN64-KNL-NEXT:    vmovaps %zmm0, {{[0-9]+}}(%rsp)
; WIN64-KNL-NEXT:    leaq {{[0-9]+}}(%rsp), %rcx
; WIN64-KNL-NEXT:    leaq {{[0-9]+}}(%rsp), %rdx
; WIN64-KNL-NEXT:    callq func_float16
; WIN64-KNL-NEXT:    vmovaps {{[-0-9]+}}(%r{{[sb]}}p), %zmm6 # 64-byte Reload
; WIN64-KNL-NEXT:    vmovaps {{[-0-9]+}}(%r{{[sb]}}p), %zmm7 # 64-byte Reload
; WIN64-KNL-NEXT:    vmovaps {{[-0-9]+}}(%r{{[sb]}}p), %zmm8 # 64-byte Reload
; WIN64-KNL-NEXT:    vmovaps {{[-0-9]+}}(%r{{[sb]}}p), %zmm9 # 64-byte Reload
; WIN64-KNL-NEXT:    vmovaps {{[-0-9]+}}(%r{{[sb]}}p), %zmm10 # 64-byte Reload
; WIN64-KNL-NEXT:    vmovaps {{[-0-9]+}}(%r{{[sb]}}p), %zmm11 # 64-byte Reload
; WIN64-KNL-NEXT:    vmovaps {{[-0-9]+}}(%r{{[sb]}}p), %zmm12 # 64-byte Reload
; WIN64-KNL-NEXT:    vmovaps {{[-0-9]+}}(%r{{[sb]}}p), %zmm13 # 64-byte Reload
; WIN64-KNL-NEXT:    vmovaps {{[-0-9]+}}(%r{{[sb]}}p), %zmm14 # 64-byte Reload
; WIN64-KNL-NEXT:    vmovaps {{[-0-9]+}}(%r{{[sb]}}p), %zmm15 # 64-byte Reload
; WIN64-KNL-NEXT:    vmovaps {{[-0-9]+}}(%r{{[sb]}}p), %zmm16 # 64-byte Reload
; WIN64-KNL-NEXT:    vmovaps {{[-0-9]+}}(%r{{[sb]}}p), %zmm17 # 64-byte Reload
; WIN64-KNL-NEXT:    vmovaps {{[-0-9]+}}(%r{{[sb]}}p), %zmm18 # 64-byte Reload
; WIN64-KNL-NEXT:    vmovaps {{[-0-9]+}}(%r{{[sb]}}p), %zmm19 # 64-byte Reload
; WIN64-KNL-NEXT:    vmovaps {{[-0-9]+}}(%r{{[sb]}}p), %zmm20 # 64-byte Reload
; WIN64-KNL-NEXT:    vmovaps {{[-0-9]+}}(%r{{[sb]}}p), %zmm21 # 64-byte Reload
; WIN64-KNL-NEXT:    kmovw {{[-0-9]+}}(%r{{[sb]}}p), %k4 # 2-byte Reload
; WIN64-KNL-NEXT:    kmovw {{[-0-9]+}}(%r{{[sb]}}p), %k5 # 2-byte Reload
; WIN64-KNL-NEXT:    kmovw {{[-0-9]+}}(%r{{[sb]}}p), %k6 # 2-byte Reload
; WIN64-KNL-NEXT:    kmovw {{[-0-9]+}}(%r{{[sb]}}p), %k7 # 2-byte Reload
; WIN64-KNL-NEXT:    leaq 1136(%rbp), %rsp
; WIN64-KNL-NEXT:    popq %rbp
; WIN64-KNL-NEXT:    retq
;
; WIN64-SKX-LABEL: test_prolog_epilog:
; WIN64-SKX:       # %bb.0:
; WIN64-SKX-NEXT:    pushq %rbp
; WIN64-SKX-NEXT:    subq $1264, %rsp # imm = 0x4F0
; WIN64-SKX-NEXT:    leaq {{[0-9]+}}(%rsp), %rbp
; WIN64-SKX-NEXT:    kmovq %k7, {{[-0-9]+}}(%r{{[sb]}}p) # 8-byte Spill
; WIN64-SKX-NEXT:    kmovq %k6, {{[-0-9]+}}(%r{{[sb]}}p) # 8-byte Spill
; WIN64-SKX-NEXT:    kmovq %k5, {{[-0-9]+}}(%r{{[sb]}}p) # 8-byte Spill
; WIN64-SKX-NEXT:    kmovq %k4, {{[-0-9]+}}(%r{{[sb]}}p) # 8-byte Spill
; WIN64-SKX-NEXT:    vmovaps %zmm21, {{[-0-9]+}}(%r{{[sb]}}p) # 64-byte Spill
; WIN64-SKX-NEXT:    vmovaps %zmm20, {{[-0-9]+}}(%r{{[sb]}}p) # 64-byte Spill
; WIN64-SKX-NEXT:    vmovaps %zmm19, {{[-0-9]+}}(%r{{[sb]}}p) # 64-byte Spill
; WIN64-SKX-NEXT:    vmovaps %zmm18, {{[-0-9]+}}(%r{{[sb]}}p) # 64-byte Spill
; WIN64-SKX-NEXT:    vmovaps %zmm17, {{[-0-9]+}}(%r{{[sb]}}p) # 64-byte Spill
; WIN64-SKX-NEXT:    vmovaps %zmm16, {{[-0-9]+}}(%r{{[sb]}}p) # 64-byte Spill
; WIN64-SKX-NEXT:    vmovaps %zmm15, {{[-0-9]+}}(%r{{[sb]}}p) # 64-byte Spill
; WIN64-SKX-NEXT:    vmovaps %zmm14, {{[-0-9]+}}(%r{{[sb]}}p) # 64-byte Spill
; WIN64-SKX-NEXT:    vmovaps %zmm13, {{[-0-9]+}}(%r{{[sb]}}p) # 64-byte Spill
; WIN64-SKX-NEXT:    vmovaps %zmm12, {{[-0-9]+}}(%r{{[sb]}}p) # 64-byte Spill
; WIN64-SKX-NEXT:    vmovaps %zmm11, {{[-0-9]+}}(%r{{[sb]}}p) # 64-byte Spill
; WIN64-SKX-NEXT:    vmovaps %zmm10, {{[-0-9]+}}(%r{{[sb]}}p) # 64-byte Spill
; WIN64-SKX-NEXT:    vmovaps %zmm9, {{[-0-9]+}}(%r{{[sb]}}p) # 64-byte Spill
; WIN64-SKX-NEXT:    vmovaps %zmm8, {{[-0-9]+}}(%r{{[sb]}}p) # 64-byte Spill
; WIN64-SKX-NEXT:    vmovaps %zmm7, {{[-0-9]+}}(%r{{[sb]}}p) # 64-byte Spill
; WIN64-SKX-NEXT:    vmovaps %zmm6, {{[-0-9]+}}(%r{{[sb]}}p) # 64-byte Spill
; WIN64-SKX-NEXT:    andq $-64, %rsp
; WIN64-SKX-NEXT:    vmovaps %zmm1, {{[0-9]+}}(%rsp)
; WIN64-SKX-NEXT:    vmovaps %zmm0, {{[0-9]+}}(%rsp)
; WIN64-SKX-NEXT:    leaq {{[0-9]+}}(%rsp), %rcx
; WIN64-SKX-NEXT:    leaq {{[0-9]+}}(%rsp), %rdx
; WIN64-SKX-NEXT:    callq func_float16
; WIN64-SKX-NEXT:    vmovaps {{[-0-9]+}}(%r{{[sb]}}p), %zmm6 # 64-byte Reload
; WIN64-SKX-NEXT:    vmovaps {{[-0-9]+}}(%r{{[sb]}}p), %zmm7 # 64-byte Reload
; WIN64-SKX-NEXT:    vmovaps {{[-0-9]+}}(%r{{[sb]}}p), %zmm8 # 64-byte Reload
; WIN64-SKX-NEXT:    vmovaps {{[-0-9]+}}(%r{{[sb]}}p), %zmm9 # 64-byte Reload
; WIN64-SKX-NEXT:    vmovaps {{[-0-9]+}}(%r{{[sb]}}p), %zmm10 # 64-byte Reload
; WIN64-SKX-NEXT:    vmovaps {{[-0-9]+}}(%r{{[sb]}}p), %zmm11 # 64-byte Reload
; WIN64-SKX-NEXT:    vmovaps {{[-0-9]+}}(%r{{[sb]}}p), %zmm12 # 64-byte Reload
; WIN64-SKX-NEXT:    vmovaps {{[-0-9]+}}(%r{{[sb]}}p), %zmm13 # 64-byte Reload
; WIN64-SKX-NEXT:    vmovaps {{[-0-9]+}}(%r{{[sb]}}p), %zmm14 # 64-byte Reload
; WIN64-SKX-NEXT:    vmovaps {{[-0-9]+}}(%r{{[sb]}}p), %zmm15 # 64-byte Reload
; WIN64-SKX-NEXT:    vmovaps {{[-0-9]+}}(%r{{[sb]}}p), %zmm16 # 64-byte Reload
; WIN64-SKX-NEXT:    vmovaps {{[-0-9]+}}(%r{{[sb]}}p), %zmm17 # 64-byte Reload
; WIN64-SKX-NEXT:    vmovaps {{[-0-9]+}}(%r{{[sb]}}p), %zmm18 # 64-byte Reload
; WIN64-SKX-NEXT:    vmovaps {{[-0-9]+}}(%r{{[sb]}}p), %zmm19 # 64-byte Reload
; WIN64-SKX-NEXT:    vmovaps {{[-0-9]+}}(%r{{[sb]}}p), %zmm20 # 64-byte Reload
; WIN64-SKX-NEXT:    vmovaps {{[-0-9]+}}(%r{{[sb]}}p), %zmm21 # 64-byte Reload
; WIN64-SKX-NEXT:    kmovq {{[-0-9]+}}(%r{{[sb]}}p), %k4 # 8-byte Reload
; WIN64-SKX-NEXT:    kmovq {{[-0-9]+}}(%r{{[sb]}}p), %k5 # 8-byte Reload
; WIN64-SKX-NEXT:    kmovq {{[-0-9]+}}(%r{{[sb]}}p), %k6 # 8-byte Reload
; WIN64-SKX-NEXT:    kmovq {{[-0-9]+}}(%r{{[sb]}}p), %k7 # 8-byte Reload
; WIN64-SKX-NEXT:    leaq 1136(%rbp), %rsp
; WIN64-SKX-NEXT:    popq %rbp
; WIN64-SKX-NEXT:    retq
;
; X64-KNL-LABEL: test_prolog_epilog:
; X64-KNL:       ## %bb.0:
; X64-KNL-NEXT:    pushq %rsi
; X64-KNL-NEXT:    pushq %rdi
; X64-KNL-NEXT:    subq $1064, %rsp ## imm = 0x428
; X64-KNL-NEXT:    kmovw %k7, {{[-0-9]+}}(%r{{[sb]}}p) ## 2-byte Spill
; X64-KNL-NEXT:    kmovw %k6, {{[-0-9]+}}(%r{{[sb]}}p) ## 2-byte Spill
; X64-KNL-NEXT:    kmovw %k5, {{[-0-9]+}}(%r{{[sb]}}p) ## 2-byte Spill
; X64-KNL-NEXT:    kmovw %k4, {{[-0-9]+}}(%r{{[sb]}}p) ## 2-byte Spill
; X64-KNL-NEXT:    vmovups %zmm31, {{[-0-9]+}}(%r{{[sb]}}p) ## 64-byte Spill
; X64-KNL-NEXT:    vmovups %zmm30, {{[-0-9]+}}(%r{{[sb]}}p) ## 64-byte Spill
; X64-KNL-NEXT:    vmovups %zmm29, {{[-0-9]+}}(%r{{[sb]}}p) ## 64-byte Spill
; X64-KNL-NEXT:    vmovups %zmm28, {{[-0-9]+}}(%r{{[sb]}}p) ## 64-byte Spill
; X64-KNL-NEXT:    vmovups %zmm27, {{[-0-9]+}}(%r{{[sb]}}p) ## 64-byte Spill
; X64-KNL-NEXT:    vmovups %zmm26, {{[-0-9]+}}(%r{{[sb]}}p) ## 64-byte Spill
; X64-KNL-NEXT:    vmovups %zmm25, {{[-0-9]+}}(%r{{[sb]}}p) ## 64-byte Spill
; X64-KNL-NEXT:    vmovups %zmm24, {{[-0-9]+}}(%r{{[sb]}}p) ## 64-byte Spill
; X64-KNL-NEXT:    vmovups %zmm23, {{[-0-9]+}}(%r{{[sb]}}p) ## 64-byte Spill
; X64-KNL-NEXT:    vmovups %zmm22, {{[-0-9]+}}(%r{{[sb]}}p) ## 64-byte Spill
; X64-KNL-NEXT:    vmovups %zmm21, {{[-0-9]+}}(%r{{[sb]}}p) ## 64-byte Spill
; X64-KNL-NEXT:    vmovups %zmm20, {{[-0-9]+}}(%r{{[sb]}}p) ## 64-byte Spill
; X64-KNL-NEXT:    vmovups %zmm19, {{[-0-9]+}}(%r{{[sb]}}p) ## 64-byte Spill
; X64-KNL-NEXT:    vmovups %zmm18, {{[-0-9]+}}(%r{{[sb]}}p) ## 64-byte Spill
; X64-KNL-NEXT:    vmovups %zmm17, {{[-0-9]+}}(%r{{[sb]}}p) ## 64-byte Spill
; X64-KNL-NEXT:    vmovups %zmm16, (%rsp) ## 64-byte Spill
; X64-KNL-NEXT:    callq _func_float16
; X64-KNL-NEXT:    vmovups (%rsp), %zmm16 ## 64-byte Reload
; X64-KNL-NEXT:    vmovups {{[-0-9]+}}(%r{{[sb]}}p), %zmm17 ## 64-byte Reload
; X64-KNL-NEXT:    vmovups {{[-0-9]+}}(%r{{[sb]}}p), %zmm18 ## 64-byte Reload
; X64-KNL-NEXT:    vmovups {{[-0-9]+}}(%r{{[sb]}}p), %zmm19 ## 64-byte Reload
; X64-KNL-NEXT:    vmovups {{[-0-9]+}}(%r{{[sb]}}p), %zmm20 ## 64-byte Reload
; X64-KNL-NEXT:    vmovups {{[-0-9]+}}(%r{{[sb]}}p), %zmm21 ## 64-byte Reload
; X64-KNL-NEXT:    vmovups {{[-0-9]+}}(%r{{[sb]}}p), %zmm22 ## 64-byte Reload
; X64-KNL-NEXT:    vmovups {{[-0-9]+}}(%r{{[sb]}}p), %zmm23 ## 64-byte Reload
; X64-KNL-NEXT:    vmovups {{[-0-9]+}}(%r{{[sb]}}p), %zmm24 ## 64-byte Reload
; X64-KNL-NEXT:    vmovups {{[-0-9]+}}(%r{{[sb]}}p), %zmm25 ## 64-byte Reload
; X64-KNL-NEXT:    vmovups {{[-0-9]+}}(%r{{[sb]}}p), %zmm26 ## 64-byte Reload
; X64-KNL-NEXT:    vmovups {{[-0-9]+}}(%r{{[sb]}}p), %zmm27 ## 64-byte Reload
; X64-KNL-NEXT:    vmovups {{[-0-9]+}}(%r{{[sb]}}p), %zmm28 ## 64-byte Reload
; X64-KNL-NEXT:    vmovups {{[-0-9]+}}(%r{{[sb]}}p), %zmm29 ## 64-byte Reload
; X64-KNL-NEXT:    vmovups {{[-0-9]+}}(%r{{[sb]}}p), %zmm30 ## 64-byte Reload
; X64-KNL-NEXT:    vmovups {{[-0-9]+}}(%r{{[sb]}}p), %zmm31 ## 64-byte Reload
; X64-KNL-NEXT:    kmovw {{[-0-9]+}}(%r{{[sb]}}p), %k4 ## 2-byte Reload
; X64-KNL-NEXT:    kmovw {{[-0-9]+}}(%r{{[sb]}}p), %k5 ## 2-byte Reload
; X64-KNL-NEXT:    kmovw {{[-0-9]+}}(%r{{[sb]}}p), %k6 ## 2-byte Reload
; X64-KNL-NEXT:    kmovw {{[-0-9]+}}(%r{{[sb]}}p), %k7 ## 2-byte Reload
; X64-KNL-NEXT:    addq $1064, %rsp ## imm = 0x428
; X64-KNL-NEXT:    popq %rdi
; X64-KNL-NEXT:    popq %rsi
; X64-KNL-NEXT:    retq
;
; X64-SKX-LABEL: test_prolog_epilog:
; X64-SKX:       ## %bb.0:
; X64-SKX-NEXT:    pushq %rsi
; X64-SKX-NEXT:    pushq %rdi
; X64-SKX-NEXT:    subq $1064, %rsp ## imm = 0x428
; X64-SKX-NEXT:    kmovq %k7, {{[-0-9]+}}(%r{{[sb]}}p) ## 8-byte Spill
; X64-SKX-NEXT:    kmovq %k6, {{[-0-9]+}}(%r{{[sb]}}p) ## 8-byte Spill
; X64-SKX-NEXT:    kmovq %k5, {{[-0-9]+}}(%r{{[sb]}}p) ## 8-byte Spill
; X64-SKX-NEXT:    kmovq %k4, {{[-0-9]+}}(%r{{[sb]}}p) ## 8-byte Spill
; X64-SKX-NEXT:    vmovups %zmm31, {{[-0-9]+}}(%r{{[sb]}}p) ## 64-byte Spill
; X64-SKX-NEXT:    vmovups %zmm30, {{[-0-9]+}}(%r{{[sb]}}p) ## 64-byte Spill
; X64-SKX-NEXT:    vmovups %zmm29, {{[-0-9]+}}(%r{{[sb]}}p) ## 64-byte Spill
; X64-SKX-NEXT:    vmovups %zmm28, {{[-0-9]+}}(%r{{[sb]}}p) ## 64-byte Spill
; X64-SKX-NEXT:    vmovups %zmm27, {{[-0-9]+}}(%r{{[sb]}}p) ## 64-byte Spill
; X64-SKX-NEXT:    vmovups %zmm26, {{[-0-9]+}}(%r{{[sb]}}p) ## 64-byte Spill
; X64-SKX-NEXT:    vmovups %zmm25, {{[-0-9]+}}(%r{{[sb]}}p) ## 64-byte Spill
; X64-SKX-NEXT:    vmovups %zmm24, {{[-0-9]+}}(%r{{[sb]}}p) ## 64-byte Spill
; X64-SKX-NEXT:    vmovups %zmm23, {{[-0-9]+}}(%r{{[sb]}}p) ## 64-byte Spill
; X64-SKX-NEXT:    vmovups %zmm22, {{[-0-9]+}}(%r{{[sb]}}p) ## 64-byte Spill
; X64-SKX-NEXT:    vmovups %zmm21, {{[-0-9]+}}(%r{{[sb]}}p) ## 64-byte Spill
; X64-SKX-NEXT:    vmovups %zmm20, {{[-0-9]+}}(%r{{[sb]}}p) ## 64-byte Spill
; X64-SKX-NEXT:    vmovups %zmm19, {{[-0-9]+}}(%r{{[sb]}}p) ## 64-byte Spill
; X64-SKX-NEXT:    vmovups %zmm18, {{[-0-9]+}}(%r{{[sb]}}p) ## 64-byte Spill
; X64-SKX-NEXT:    vmovups %zmm17, {{[-0-9]+}}(%r{{[sb]}}p) ## 64-byte Spill
; X64-SKX-NEXT:    vmovups %zmm16, (%rsp) ## 64-byte Spill
; X64-SKX-NEXT:    callq _func_float16
; X64-SKX-NEXT:    vmovups (%rsp), %zmm16 ## 64-byte Reload
; X64-SKX-NEXT:    vmovups {{[-0-9]+}}(%r{{[sb]}}p), %zmm17 ## 64-byte Reload
; X64-SKX-NEXT:    vmovups {{[-0-9]+}}(%r{{[sb]}}p), %zmm18 ## 64-byte Reload
; X64-SKX-NEXT:    vmovups {{[-0-9]+}}(%r{{[sb]}}p), %zmm19 ## 64-byte Reload
; X64-SKX-NEXT:    vmovups {{[-0-9]+}}(%r{{[sb]}}p), %zmm20 ## 64-byte Reload
; X64-SKX-NEXT:    vmovups {{[-0-9]+}}(%r{{[sb]}}p), %zmm21 ## 64-byte Reload
; X64-SKX-NEXT:    vmovups {{[-0-9]+}}(%r{{[sb]}}p), %zmm22 ## 64-byte Reload
; X64-SKX-NEXT:    vmovups {{[-0-9]+}}(%r{{[sb]}}p), %zmm23 ## 64-byte Reload
; X64-SKX-NEXT:    vmovups {{[-0-9]+}}(%r{{[sb]}}p), %zmm24 ## 64-byte Reload
; X64-SKX-NEXT:    vmovups {{[-0-9]+}}(%r{{[sb]}}p), %zmm25 ## 64-byte Reload
; X64-SKX-NEXT:    vmovups {{[-0-9]+}}(%r{{[sb]}}p), %zmm26 ## 64-byte Reload
; X64-SKX-NEXT:    vmovups {{[-0-9]+}}(%r{{[sb]}}p), %zmm27 ## 64-byte Reload
; X64-SKX-NEXT:    vmovups {{[-0-9]+}}(%r{{[sb]}}p), %zmm28 ## 64-byte Reload
; X64-SKX-NEXT:    vmovups {{[-0-9]+}}(%r{{[sb]}}p), %zmm29 ## 64-byte Reload
; X64-SKX-NEXT:    vmovups {{[-0-9]+}}(%r{{[sb]}}p), %zmm30 ## 64-byte Reload
; X64-SKX-NEXT:    vmovups {{[-0-9]+}}(%r{{[sb]}}p), %zmm31 ## 64-byte Reload
; X64-SKX-NEXT:    kmovq {{[-0-9]+}}(%r{{[sb]}}p), %k4 ## 8-byte Reload
; X64-SKX-NEXT:    kmovq {{[-0-9]+}}(%r{{[sb]}}p), %k5 ## 8-byte Reload
; X64-SKX-NEXT:    kmovq {{[-0-9]+}}(%r{{[sb]}}p), %k6 ## 8-byte Reload
; X64-SKX-NEXT:    kmovq {{[-0-9]+}}(%r{{[sb]}}p), %k7 ## 8-byte Reload
; X64-SKX-NEXT:    addq $1064, %rsp ## imm = 0x428
; X64-SKX-NEXT:    popq %rdi
; X64-SKX-NEXT:    popq %rsi
; X64-SKX-NEXT:    retq
   %c = call <16 x float> @func_float16(<16 x float> %a, <16 x float> %b)
   ret <16 x float> %c
}


declare <16 x float> @func_float16_mask(<16 x float>, <16 x i1>)

define <16 x float> @testf16_inp_mask(<16 x float> %a, i16 %mask)  {
; X32-LABEL: testf16_inp_mask:
; X32:       ## %bb.0:
; X32-NEXT:    subl $12, %esp
; X32-NEXT:    .cfi_def_cfa_offset 16
; X32-NEXT:    kmovw {{[0-9]+}}(%esp), %k1
; X32-NEXT:    calll _func_float16_mask
; X32-NEXT:    addl $12, %esp
; X32-NEXT:    retl
;
; WIN32-LABEL: testf16_inp_mask:
; WIN32:       # %bb.0:
; WIN32-NEXT:    kmovw {{[0-9]+}}(%esp), %k1
; WIN32-NEXT:    calll _func_float16_mask
; WIN32-NEXT:    retl
;
; WIN64-KNL-LABEL: testf16_inp_mask:
; WIN64-KNL:       # %bb.0:
; WIN64-KNL-NEXT:    subq $40, %rsp
; WIN64-KNL-NEXT:    .seh_stackalloc 40
; WIN64-KNL-NEXT:    .seh_endprologue
; WIN64-KNL-NEXT:    # kill: def $dx killed $dx def $edx
; WIN64-KNL-NEXT:    vmovaps (%rcx), %zmm0
; WIN64-KNL-NEXT:    kmovw %edx, %k1
; WIN64-KNL-NEXT:    callq func_float16_mask
; WIN64-KNL-NEXT:    nop
; WIN64-KNL-NEXT:    addq $40, %rsp
; WIN64-KNL-NEXT:    retq
; WIN64-KNL-NEXT:    .seh_handlerdata
; WIN64-KNL-NEXT:    .text
; WIN64-KNL-NEXT:    .seh_endproc
;
; WIN64-SKX-LABEL: testf16_inp_mask:
; WIN64-SKX:       # %bb.0:
; WIN64-SKX-NEXT:    subq $40, %rsp
; WIN64-SKX-NEXT:    .seh_stackalloc 40
; WIN64-SKX-NEXT:    .seh_endprologue
; WIN64-SKX-NEXT:    # kill: def $dx killed $dx def $edx
; WIN64-SKX-NEXT:    vmovaps (%rcx), %zmm0
; WIN64-SKX-NEXT:    kmovd %edx, %k1
; WIN64-SKX-NEXT:    callq func_float16_mask
; WIN64-SKX-NEXT:    nop
; WIN64-SKX-NEXT:    addq $40, %rsp
; WIN64-SKX-NEXT:    retq
; WIN64-SKX-NEXT:    .seh_handlerdata
; WIN64-SKX-NEXT:    .text
; WIN64-SKX-NEXT:    .seh_endproc
;
; X64-KNL-LABEL: testf16_inp_mask:
; X64-KNL:       ## %bb.0:
; X64-KNL-NEXT:    pushq %rbp
; X64-KNL-NEXT:    .cfi_def_cfa_offset 16
; X64-KNL-NEXT:    pushq %r13
; X64-KNL-NEXT:    .cfi_def_cfa_offset 24
; X64-KNL-NEXT:    pushq %r12
; X64-KNL-NEXT:    .cfi_def_cfa_offset 32
; X64-KNL-NEXT:    .cfi_offset %r12, -32
; X64-KNL-NEXT:    .cfi_offset %r13, -24
; X64-KNL-NEXT:    .cfi_offset %rbp, -16
; X64-KNL-NEXT:    kmovw %edi, %k1
; X64-KNL-NEXT:    callq _func_float16_mask
; X64-KNL-NEXT:    popq %r12
; X64-KNL-NEXT:    popq %r13
; X64-KNL-NEXT:    popq %rbp
; X64-KNL-NEXT:    retq
;
; X64-SKX-LABEL: testf16_inp_mask:
; X64-SKX:       ## %bb.0:
; X64-SKX-NEXT:    pushq %rbp
; X64-SKX-NEXT:    .cfi_def_cfa_offset 16
; X64-SKX-NEXT:    pushq %r13
; X64-SKX-NEXT:    .cfi_def_cfa_offset 24
; X64-SKX-NEXT:    pushq %r12
; X64-SKX-NEXT:    .cfi_def_cfa_offset 32
; X64-SKX-NEXT:    .cfi_offset %r12, -32
; X64-SKX-NEXT:    .cfi_offset %r13, -24
; X64-SKX-NEXT:    .cfi_offset %rbp, -16
; X64-SKX-NEXT:    kmovd %edi, %k1
; X64-SKX-NEXT:    callq _func_float16_mask
; X64-SKX-NEXT:    popq %r12
; X64-SKX-NEXT:    popq %r13
; X64-SKX-NEXT:    popq %rbp
; X64-SKX-NEXT:    retq
  %imask = bitcast i16 %mask to <16 x i1>
  %1 = call intel_ocl_bicc <16 x float> @func_float16_mask(<16 x float> %a, <16 x i1> %imask)
  ret <16 x float> %1
}

define intel_ocl_bicc <16 x float> @test_prolog_epilog_with_mask(<16 x float> %a, <16 x i32> %x1, <16 x i32>%x2, <16 x i1> %mask) nounwind {
; X32-LABEL: test_prolog_epilog_with_mask:
; X32:       ## %bb.0:
; X32-NEXT:    subl $12, %esp
; X32-NEXT:    vpcmpeqd %zmm2, %zmm1, %k0
; X32-NEXT:    kxorw %k1, %k0, %k1
; X32-NEXT:    calll _func_float16_mask
; X32-NEXT:    addl $12, %esp
; X32-NEXT:    retl
;
; WIN32-LABEL: test_prolog_epilog_with_mask:
; WIN32:       # %bb.0:
; WIN32-NEXT:    vpcmpeqd %zmm2, %zmm1, %k0
; WIN32-NEXT:    kxorw %k1, %k0, %k1
; WIN32-NEXT:    calll _func_float16_mask
; WIN32-NEXT:    retl
;
; WIN64-LABEL: test_prolog_epilog_with_mask:
; WIN64:       # %bb.0:
; WIN64-NEXT:    subq $40, %rsp
; WIN64-NEXT:    vpcmpeqd %zmm2, %zmm1, %k0
; WIN64-NEXT:    kxorw %k1, %k0, %k1
; WIN64-NEXT:    callq func_float16_mask
; WIN64-NEXT:    addq $40, %rsp
; WIN64-NEXT:    retq
;
; X64-LABEL: test_prolog_epilog_with_mask:
; X64:       ## %bb.0:
; X64-NEXT:    pushq %rax
; X64-NEXT:    vpcmpeqd %zmm2, %zmm1, %k0
; X64-NEXT:    kxorw %k1, %k0, %k1
; X64-NEXT:    callq _func_float16_mask
; X64-NEXT:    popq %rax
; X64-NEXT:    retq
   %cmp_res = icmp eq <16 x i32>%x1, %x2
   %mask1 = xor <16 x i1> %cmp_res, %mask
   %c = call intel_ocl_bicc <16 x float> @func_float16_mask(<16 x float> %a, <16 x i1>%mask1)
   ret <16 x float> %c
}
