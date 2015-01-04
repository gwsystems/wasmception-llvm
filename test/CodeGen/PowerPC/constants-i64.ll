; RUN: llc -mcpu=ppc64 < %s | FileCheck %s
target datalayout = "E-m:e-i64:64-n32:64"
target triple = "powerpc64-unknown-linux-gnu"

; Function Attrs: nounwind readnone
define i64 @cn1() #0 {
entry:
  ret i64 281474976710655

; CHECK-LABEL: @cn1
; CHECK: lis [[REG1:[0-9]+]], -1
; CHECK: rldicl 3, [[REG1]], 48, 0
; CHECK: blr
}

; Function Attrs: nounwind readnone
define i64 @cnb() #0 {
entry:
  ret i64 281474976710575

; CHECK-LABEL: @cnb
; CHECK: lis [[REG1:[0-9]+]], -81
; CHECK: rldicl 3, [[REG1]], 48, 0
; CHECK: blr
}

; Function Attrs: nounwind readnone
define i64 @f2n(i64 %x) #0 {
entry:
  ret i64 68719476735

; CHECK-LABEL: @f2n
; CHECK: lis [[REG1:[0-9]+]], -4096
; CHECK: rldicl 3, [[REG1]], 36, 0
; CHECK: blr
}

; Function Attrs: nounwind readnone
define i64 @f3(i64 %x) #0 {
entry:
  ret i64 8589934591

; CHECK-LABEL: @f3
; CHECK: lis [[REG1:[0-9]+]], -32768
; CHECK: rldicl 3, [[REG1]], 33, 0
; CHECK: blr
}

; Function Attrs: nounwind readnone
define i64 @cn2n() #0 {
entry:
  ret i64 -1407374887747585

; CHECK-LABEL: @cn2n
; CHECK: lis [[REG1:[0-9]+]], -5121
; CHECK: ori [[REG2:[0-9]+]], [[REG1]], 65534
; CHECK: rldicl 3, [[REG2]], 22, 0
; CHECK: blr
}


attributes #0 = { nounwind readnone }


