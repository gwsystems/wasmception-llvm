; RUN: llc < %s -mtriple=i386-pc-mingw32 | FileCheck %s

declare dllimport void @foo()

define void @bar() nounwind {
; CHECK: calll	*__imp__foo
  call void @foo()
  ret void
}
