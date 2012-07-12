; RUN: llc < %s -march=x86-64 -mattr=+rdrand | FileCheck %s
declare {i16, i32} @llvm.x86.rdrand.16()
declare {i32, i32} @llvm.x86.rdrand.32()
declare {i64, i32} @llvm.x86.rdrand.64()

define i32 @_rdrand16_step(i16* %random_val) {
  %call = call {i16, i32} @llvm.x86.rdrand.16()
  %randval = extractvalue {i16, i32} %call, 0
  store i16 %randval, i16* %random_val
  %isvalid = extractvalue {i16, i32} %call, 1
  ret i32 %isvalid
; CHECK: _rdrand16_step:
; CHECK: rdrandw	%ax
; CHECK: movw	%ax, (%r[[A0:di|cx]])
; CHECK: movzwl	%ax, %ecx
; CHECK: movl	$1, %eax
; CHECK: cmovael	%ecx, %eax
; CHECK: ret
}

define i32 @_rdrand32_step(i32* %random_val) {
  %call = call {i32, i32} @llvm.x86.rdrand.32()
  %randval = extractvalue {i32, i32} %call, 0
  store i32 %randval, i32* %random_val
  %isvalid = extractvalue {i32, i32} %call, 1
  ret i32 %isvalid
; CHECK: _rdrand32_step:
; CHECK: rdrandl	%e[[T0:[a-z]+]]
; CHECK: movl	%e[[T0]], (%r[[A0]])
; CHECK: movl	$1, %eax
; CHECK: cmovael	%e[[T0]], %eax
; CHECK: ret
}

define i32 @_rdrand64_step(i64* %random_val) {
  %call = call {i64, i32} @llvm.x86.rdrand.64()
  %randval = extractvalue {i64, i32} %call, 0
  store i64 %randval, i64* %random_val
  %isvalid = extractvalue {i64, i32} %call, 1
  ret i32 %isvalid
; CHECK: _rdrand64_step:
; CHECK: rdrandq	%r[[T1:[[a-z]+]]
; CHECK: movq	%r[[T1]], (%r[[A0]])
; CHECK: movl	$1, %eax
; CHECK: cmovael	%e[[T1]], %eax
; CHECK: ret
}
