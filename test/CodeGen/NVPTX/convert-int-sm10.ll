; RUN: llc < %s -march=nvptx -mcpu=sm_10 | FileCheck %s
; RUN: llc < %s -march=nvptx64 -mcpu=sm_10 | FileCheck %s


; i16

define i16 @cvt_i16_i32(i32 %x) {
; CHECK: cvt.u16.u32 %rs{{[0-9]+}}, %r{{[0-9]+}}
; CHECK: ret
  %a = trunc i32 %x to i16
  ret i16 %a
}

define i16 @cvt_i16_i64(i64 %x) {
; CHECK: cvt.u16.u64 %rs{{[0-9]+}}, %rl{{[0-9]+}}
; CHECK: ret
  %a = trunc i64 %x to i16
  ret i16 %a
}



; i32

define i32 @cvt_i32_i16(i16 %x) {
; CHECK: cvt.u32.u16 %r{{[0-9]+}}, %rs{{[0-9]+}}
; CHECK: ret
  %a = zext i16 %x to i32
  ret i32 %a
}

define i32 @cvt_i32_i64(i64 %x) {
; CHECK: cvt.u32.u64 %r{{[0-9]+}}, %rl{{[0-9]+}}
; CHECK: ret
  %a = trunc i64 %x to i32
  ret i32 %a
}



; i64

define i64 @cvt_i64_i16(i16 %x) {
; CHECK: cvt.u64.u16 %rl{{[0-9]+}}, %rs{{[0-9]+}}
; CHECK: ret
  %a = zext i16 %x to i64
  ret i64 %a
}

define i64 @cvt_i64_i32(i32 %x) {
; CHECK: cvt.u64.u32 %rl{{[0-9]+}}, %r{{[0-9]+}}
; CHECK: ret
  %a = zext i32 %x to i64
  ret i64 %a
}
