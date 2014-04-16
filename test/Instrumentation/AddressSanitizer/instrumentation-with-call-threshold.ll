; Test asan internal compiler flags:
;   -asan-instrumentation-with-call-threshold
;   -asan-memory-access-callback-prefix

; RUN: opt < %s -asan -asan-module -asan-instrumentation-with-call-threshold=1 -S | FileCheck %s --check-prefix=CHECK-CALL
; RUN: opt < %s -asan -asan-module -asan-instrumentation-with-call-threshold=0 -S | FileCheck %s --check-prefix=CHECK-CALL
; RUN: opt < %s -asan -asan-module -asan-instrumentation-with-call-threshold=0 -asan-memory-access-callback-prefix=__foo_ -S | FileCheck %s --check-prefix=CHECK-CUSTOM-PREFIX
; RUN: opt < %s -asan -asan-module -asan-instrumentation-with-call-threshold=5 -S | FileCheck %s --check-prefix=CHECK-INLINE
; RUN: opt < %s -asan -asan-module  -S | FileCheck %s --check-prefix=CHECK-INLINE
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64"
target triple = "x86_64-unknown-linux-gnu"

define void @test_load(i32* %a, i64* %b) sanitize_address {
entry:
; CHECK-CALL: call void @__asan_load4
; CHECK-CALL: call void @__asan_load8
; CHECK-CUSTOM-PREFIX: call void @__foo_load4
; CHECK-CUSTOM-PREFIX: call void @__foo_load8
; CHECK-INLINE-NOT: call void @__asan_load
  %tmp1 = load i32* %a
  %tmp2 = load i64* %b
  ret void
}


