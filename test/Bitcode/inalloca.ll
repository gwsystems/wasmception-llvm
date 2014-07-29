; RUN: llvm-as < %s | llvm-dis | FileCheck %s
; RUN: llvm-uselistorder < %s -preserve-bc-use-list-order -num-shuffles=5

; inalloca should roundtrip.

define void @foo(i32* inalloca %args) {
  ret void
}
; CHECK-LABEL: define void @foo(i32* inalloca %args)

define void @bar() {
  ; Use the maximum alignment, since we stuff our bit with alignment.
  %args = alloca inalloca i32, align 536870912
  call void @foo(i32* inalloca %args)
  ret void
}
; CHECK-LABEL: define void @bar() {
; CHECK: %args = alloca inalloca i32, align 536870912
; CHECK: call void @foo(i32* inalloca %args)
