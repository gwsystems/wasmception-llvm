; RUN: llvm-dis < %s.bc| FileCheck %s

; vectorOperations.3.2.ll.bc was generated by passing this file to llvm-as-3.2.
; The test checks that LLVM does not misread vector operations of
; older bitcode files.

define void @extractelement(<2 x i8> %x1){
entry:
; CHECK: %res1 = extractelement <2 x i8> %x1, i32 0
  %res1 = extractelement <2 x i8> %x1, i32 0

  ret void
}

define void @insertelement(<2 x i8> %x1){
entry:
; CHECK: %res1 = insertelement <2 x i8> %x1, i8 0, i32 0
  %res1 = insertelement <2 x i8> %x1, i8 0, i32 0

  ret void
}

define void @shufflevector(<2 x i8> %x1){
entry:
; CHECK: %res1 = shufflevector <2 x i8> %x1, <2 x i8> %x1, <2 x i32> <i32 0, i32 1>
  %res1 = shufflevector <2 x i8> %x1, <2 x i8> %x1, <2 x i32> <i32 0, i32 1>

; CHECK-NEXT: %res2 = shufflevector <2 x i8> %x1, <2 x i8> undef, <2 x i32> <i32 0, i32 1>
  %res2 = shufflevector <2 x i8> %x1, <2 x i8> undef, <2 x i32> <i32 0, i32 1>

  ret void
}
