; RUN:  llvm-dis < %s.bc| FileCheck %s

; case-ranges.ll.bc was generated by passing this file to llvm-as from the 3.3
; release of LLVM. This tests that the bitcode for switches from that release
; can still be read.

define i32 @foo(i32 %x) nounwind ssp uwtable {
; CHECK: define i32 @foo
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  store i32 %x, i32* %2, align 4
  %3 = load i32* %2, align 4
  switch i32 %3, label %9 [
; CHECK: switch i32 %3, label %9
    i32 -3, label %4
; CHECK-NEXT: i32 -3, label %4
    i32 -2, label %4
; CHECK-NEXT: i32 -2, label %4
    i32 -1, label %4
; CHECK-NEXT: i32 -1, label %4
    i32 0, label %4
; CHECK-NEXT: i32 0, label %4
    i32 1, label %4
; CHECK-NEXT: i32 1, label %4
    i32 2, label %4
; CHECK-NEXT: i32 2, label %4
    i32 4, label %5
; CHECK-NEXT: i32 4, label %5
    i32 5, label %6
; CHECK-NEXT: i32 5, label %6
    i32 6, label %7
; CHECK-NEXT: i32 6, label %7
    i32 7, label %8
; CHECK-NEXT: i32 7, label %8
  ]

; <label>:4
  store i32 -1, i32* %1
  br label %11

; <label>:5
  store i32 2, i32* %1
  br label %11

; <label>:6
  store i32 1, i32* %1
  br label %11

; <label>:7
  store i32 4, i32* %1
  br label %11

; <label>:8
  store i32 3, i32* %1
  br label %11

; <label>:9
  br label %10

; <label>:10
  store i32 0, i32* %1
  br label %11

; <label>:11
  %12 = load i32* %1
  ret i32 %12
}
