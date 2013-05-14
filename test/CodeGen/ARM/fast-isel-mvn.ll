; RUN: llc < %s -O0 -verify-machineinstrs -fast-isel-abort -relocation-model=dynamic-no-pic -mtriple=armv7-apple-ios | FileCheck %s --check-prefix=ARM
; RUN: llc < %s -O0 -verify-machineinstrs -fast-isel-abort -relocation-model=dynamic-no-pic -mtriple=thumbv7-apple-ios | FileCheck %s --check-prefix=THUMB
; rdar://10412592

; Note: The Thumb code is being generated by the target-independent selector.

define void @t1() nounwind {
entry:
; ARM: t1
; THUMB: t1
; ARM: mvn r0, #0
; THUMB: movw r0, #65535
; THUMB: movt r0, #65535
  call void @foo(i32 -1)
  ret void
}

declare void @foo(i32)

define void @t2() nounwind {
entry:
; ARM: t2
; THUMB: t2
; ARM: mvn r0, #233
; THUMB: movw r0, #65302
; THUMB: movt r0, #65535
  call void @foo(i32 -234)
  ret void
}

define void @t3() nounwind {
entry:
; ARM: t3
; THUMB: t3
; ARM: mvn	r0, #256
; THUMB: movw r0, #65279
; THUMB: movt r0, #65535
  call void @foo(i32 -257)
  ret void
}

; Load from constant pool
define void @t4() nounwind {
entry:
; ARM: t4
; THUMB: t4
; ARM: ldr	r0
; THUMB: movw r0, #65278
; THUMB: movt r0, #65535
  call void @foo(i32 -258)
  ret void
}

define void @t5() nounwind {
entry:
; ARM: t5
; THUMB: t5
; ARM: mvn r0, #65280
; THUMB: movs r0, #255
; THUMB: movt r0, #65535
  call void @foo(i32 -65281)
  ret void
}

define void @t6() nounwind {
entry:
; ARM: t6
; THUMB: t6
; ARM: mvn r0, #978944
; THUMB: movw r0, #4095
; THUMB: movt r0, #65521
  call void @foo(i32 -978945)
  ret void
}

define void @t7() nounwind {
entry:
; ARM: t7
; THUMB: t7
; ARM: mvn r0, #267386880
; THUMB: movw r0, #65535
; THUMB: movt r0, #61455
  call void @foo(i32 -267386881)
  ret void
}

define void @t8() nounwind {
entry:
; ARM: t8
; THUMB: t8
; ARM: mvn r0, #65280
; THUMB: movs r0, #255
; THUMB: movt r0, #65535
  call void @foo(i32 -65281)
  ret void
}

define void @t9() nounwind {
entry:
; ARM: t9
; THUMB: t9
; ARM: mvn r0, #2130706432
; THUMB: movw r0, #65535
; THUMB: movt r0, #33023
  call void @foo(i32 -2130706433)
  ret void
}
