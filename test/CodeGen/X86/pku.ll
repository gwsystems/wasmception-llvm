; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-apple-darwin -mcpu=knl --show-mc-encoding -verify-machineinstrs | FileCheck %s --check-prefixes=CHECK,X86
; RUN: llc < %s -mtriple=x86_64-apple-darwin -mcpu=knl --show-mc-encoding -verify-machineinstrs | FileCheck %s --check-prefixes=CHECK,X64

declare i32 @llvm.x86.rdpkru()
declare void @llvm.x86.wrpkru(i32)

define void @test_x86_wrpkru(i32 %src) {
; X86-LABEL: test_x86_wrpkru:
; X86:       ## %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax ## encoding: [0x8b,0x44,0x24,0x04]
; X86-NEXT:    xorl %edx, %edx ## encoding: [0x31,0xd2]
; X86-NEXT:    xorl %ecx, %ecx ## encoding: [0x31,0xc9]
; X86-NEXT:    wrpkru ## encoding: [0x0f,0x01,0xef]
; X86-NEXT:    retl ## encoding: [0xc3]
;
; X64-LABEL: test_x86_wrpkru:
; X64:       ## %bb.0:
; X64-NEXT:    movl %edi, %eax ## encoding: [0x89,0xf8]
; X64-NEXT:    xorl %edx, %edx ## encoding: [0x31,0xd2]
; X64-NEXT:    xorl %ecx, %ecx ## encoding: [0x31,0xc9]
; X64-NEXT:    wrpkru ## encoding: [0x0f,0x01,0xef]
; X64-NEXT:    retq ## encoding: [0xc3]
  call void @llvm.x86.wrpkru(i32 %src)
  ret void
}

define i32 @test_x86_rdpkru() {
; CHECK-LABEL: test_x86_rdpkru:
; CHECK:       ## %bb.0:
; CHECK-NEXT:    xorl %ecx, %ecx ## encoding: [0x31,0xc9]
; CHECK-NEXT:    rdpkru ## encoding: [0x0f,0x01,0xee]
; CHECK-NEXT:    ret{{[l|q]}} ## encoding: [0xc3]
  %res = call i32 @llvm.x86.rdpkru()
  ret i32 %res
}
