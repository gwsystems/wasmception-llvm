; FIXME: We should not require -O2 to simplify this to return false.
; RUN: opt -S -lowertypetests -O2 < %s | FileCheck %s

target datalayout = "e-p:32:32"

declare i1 @llvm.type.test(i8* %ptr, metadata %bitset) nounwind readnone

define i1 @foo(i8* %p) {
  %x = call i1 @llvm.type.test(i8* %p, metadata !"typeid1")
  ; CHECK: ret i1 false
  ret i1 %x
}
