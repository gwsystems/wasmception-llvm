; RUN: llc -O0 < %s | FileCheck %s

target datalayout = "e-p:16:16:16-i8:8:8-i16:16:16-i32:16:32-n8:16"
target triple = "msp430---elf"

; Function Attrs: nounwind
define i16 @test(i16 %i) #0 {
entry:
; CHECK: test:
  %retval = alloca i16, align 2
  %i.addr = alloca i16, align 2
  store i16 %i, i16* %i.addr, align 2
  %0 = load i16* %i.addr, align 2
; CHECK: add.w #.LJTI0_0, [[REG1:r[0-9]+]]
; CHECK: mov.w 0([[REG1]]), [[REG2:r[0-9]+]]
; CHECK: br [[REG2]]
  switch i16 %0, label %sw.default [
    i16 0, label %sw.bb
    i16 1, label %sw.bb1
    i16 2, label %sw.bb2
    i16 3, label %sw.bb3
  ]

sw.bb:                                            ; preds = %entry
  store i16 0, i16* %retval
  br label %return

sw.bb1:                                           ; preds = %entry
  store i16 1, i16* %retval
  br label %return

sw.bb2:                                           ; preds = %entry
  store i16 2, i16* %retval
  br label %return

sw.bb3:                                           ; preds = %entry
  store i16 3, i16* %retval
  br label %return

sw.default:                                       ; preds = %entry
  store i16 2, i16* %retval
  br label %return

return:                                           ; preds = %sw.default, %sw.bb3, %sw.bb2, %sw.bb1, %sw.bb
  %1 = load i16* %retval
  ret i16 %1
; CHECK: ret
}

; CHECK: .LJTI0_0:
; CHECK-NEXT: .short .LBB0_2
; CHECK-NEXT: .short .LBB0_3
; CHECK-NEXT: .short .LBB0_4
; CHECK-NEXT: .short .LBB0_5
