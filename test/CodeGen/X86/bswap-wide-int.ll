; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-unknown-unknown | FileCheck %s --check-prefix=X86
; RUN: llc < %s -mtriple=i686-unknown-unknown -mattr=+movbe | FileCheck %s --check-prefix=X86-MOVBE
; RUN: llc < %s -mtriple=x86_64-unknown-unknown | FileCheck %s --check-prefix=X64
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+movbe | FileCheck %s --check-prefix=X64-MOVBE

declare i64  @llvm.bswap.i64(i64)
declare i128 @llvm.bswap.i128(i128)
declare i256 @llvm.bswap.i256(i256)

define i64 @bswap_i64(i64 %a0) nounwind {
; X86-LABEL: bswap_i64:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    bswapl %eax
; X86-NEXT:    bswapl %edx
; X86-NEXT:    retl
;
; X86-MOVBE-LABEL: bswap_i64:
; X86-MOVBE:       # %bb.0:
; X86-MOVBE-NEXT:    movbel {{[0-9]+}}(%esp), %eax
; X86-MOVBE-NEXT:    movbel {{[0-9]+}}(%esp), %edx
; X86-MOVBE-NEXT:    retl
;
; X64-LABEL: bswap_i64:
; X64:       # %bb.0:
; X64-NEXT:    movq %rdi, %rax
; X64-NEXT:    bswapq %rax
; X64-NEXT:    retq
;
; X64-MOVBE-LABEL: bswap_i64:
; X64-MOVBE:       # %bb.0:
; X64-MOVBE-NEXT:    movq %rdi, %rax
; X64-MOVBE-NEXT:    bswapq %rax
; X64-MOVBE-NEXT:    retq
  %1 = call i64 @llvm.bswap.i64(i64 %a0)
  ret i64 %1
}

define i128 @bswap_i128(i128 %a0) nounwind {
; X86-LABEL: bswap_i128:
; X86:       # %bb.0:
; X86-NEXT:    pushl %edi
; X86-NEXT:    pushl %esi
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %esi
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edi
; X86-NEXT:    bswapl %edi
; X86-NEXT:    bswapl %esi
; X86-NEXT:    bswapl %edx
; X86-NEXT:    bswapl %ecx
; X86-NEXT:    movl %ecx, 12(%eax)
; X86-NEXT:    movl %edx, 8(%eax)
; X86-NEXT:    movl %esi, 4(%eax)
; X86-NEXT:    movl %edi, (%eax)
; X86-NEXT:    popl %esi
; X86-NEXT:    popl %edi
; X86-NEXT:    retl $4
;
; X86-MOVBE-LABEL: bswap_i128:
; X86-MOVBE:       # %bb.0:
; X86-MOVBE-NEXT:    pushl %edi
; X86-MOVBE-NEXT:    pushl %esi
; X86-MOVBE-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-MOVBE-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-MOVBE-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-MOVBE-NEXT:    movl {{[0-9]+}}(%esp), %esi
; X86-MOVBE-NEXT:    movl {{[0-9]+}}(%esp), %edi
; X86-MOVBE-NEXT:    movbel %esi, 12(%eax)
; X86-MOVBE-NEXT:    movbel %edi, 8(%eax)
; X86-MOVBE-NEXT:    movbel %edx, 4(%eax)
; X86-MOVBE-NEXT:    movbel %ecx, (%eax)
; X86-MOVBE-NEXT:    popl %esi
; X86-MOVBE-NEXT:    popl %edi
; X86-MOVBE-NEXT:    retl $4
;
; X64-LABEL: bswap_i128:
; X64:       # %bb.0:
; X64-NEXT:    movq %rsi, %rax
; X64-NEXT:    bswapq %rax
; X64-NEXT:    bswapq %rdi
; X64-NEXT:    movq %rdi, %rdx
; X64-NEXT:    retq
;
; X64-MOVBE-LABEL: bswap_i128:
; X64-MOVBE:       # %bb.0:
; X64-MOVBE-NEXT:    movq %rsi, %rax
; X64-MOVBE-NEXT:    bswapq %rax
; X64-MOVBE-NEXT:    bswapq %rdi
; X64-MOVBE-NEXT:    movq %rdi, %rdx
; X64-MOVBE-NEXT:    retq
  %1 = call i128 @llvm.bswap.i128(i128 %a0)
  ret i128 %1
}

define i256 @bswap_i256(i256 %a0) nounwind {
; X86-LABEL: bswap_i256:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    bswapl %ecx
; X86-NEXT:    movl %ecx, 28(%eax)
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    bswapl %ecx
; X86-NEXT:    movl %ecx, 24(%eax)
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    bswapl %ecx
; X86-NEXT:    movl %ecx, 20(%eax)
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    bswapl %ecx
; X86-NEXT:    movl %ecx, 16(%eax)
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    bswapl %ecx
; X86-NEXT:    movl %ecx, 12(%eax)
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    bswapl %ecx
; X86-NEXT:    movl %ecx, 8(%eax)
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    bswapl %ecx
; X86-NEXT:    movl %ecx, 4(%eax)
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    bswapl %ecx
; X86-NEXT:    movl %ecx, (%eax)
; X86-NEXT:    retl $4
;
; X86-MOVBE-LABEL: bswap_i256:
; X86-MOVBE:       # %bb.0:
; X86-MOVBE-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-MOVBE-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-MOVBE-NEXT:    movbel %ecx, 28(%eax)
; X86-MOVBE-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-MOVBE-NEXT:    movbel %ecx, 24(%eax)
; X86-MOVBE-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-MOVBE-NEXT:    movbel %ecx, 20(%eax)
; X86-MOVBE-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-MOVBE-NEXT:    movbel %ecx, 16(%eax)
; X86-MOVBE-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-MOVBE-NEXT:    movbel %ecx, 12(%eax)
; X86-MOVBE-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-MOVBE-NEXT:    movbel %ecx, 8(%eax)
; X86-MOVBE-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-MOVBE-NEXT:    movbel %ecx, 4(%eax)
; X86-MOVBE-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-MOVBE-NEXT:    movbel %ecx, (%eax)
; X86-MOVBE-NEXT:    retl $4
;
; X64-LABEL: bswap_i256:
; X64:       # %bb.0:
; X64-NEXT:    movq %rdi, %rax
; X64-NEXT:    bswapq %r8
; X64-NEXT:    bswapq %rcx
; X64-NEXT:    bswapq %rdx
; X64-NEXT:    bswapq %rsi
; X64-NEXT:    movq %rsi, 24(%rdi)
; X64-NEXT:    movq %rdx, 16(%rdi)
; X64-NEXT:    movq %rcx, 8(%rdi)
; X64-NEXT:    movq %r8, (%rdi)
; X64-NEXT:    retq
;
; X64-MOVBE-LABEL: bswap_i256:
; X64-MOVBE:       # %bb.0:
; X64-MOVBE-NEXT:    movq %rdi, %rax
; X64-MOVBE-NEXT:    movbeq %rsi, 24(%rdi)
; X64-MOVBE-NEXT:    movbeq %rdx, 16(%rdi)
; X64-MOVBE-NEXT:    movbeq %rcx, 8(%rdi)
; X64-MOVBE-NEXT:    movbeq %r8, (%rdi)
; X64-MOVBE-NEXT:    retq
  %1 = call i256 @llvm.bswap.i256(i256 %a0)
  ret i256 %1
}
