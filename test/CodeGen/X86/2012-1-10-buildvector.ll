; RUN: llc < %s -mattr=+avx -mtriple=i686-unknown-unknown | FileCheck %s

define void @bad_cast() {
; CHECK-LABEL: bad_cast:
; CHECK:       # BB#0:
; CHECK-NEXT:    vxorps %xmm0, %xmm0, %xmm0
; CHECK-NEXT:    vmovaps %xmm0, (%eax)
; CHECK-NEXT:    movl $0, (%eax)
; CHECK-NEXT:    vzeroupper
; CHECK-NEXT:    retl
  %vext.i = shufflevector <2 x i64> undef, <2 x i64> undef, <3 x i32> <i32 0, i32 1, i32 undef>
  %vecinit8.i = shufflevector <3 x i64> zeroinitializer, <3 x i64> %vext.i, <3 x i32> <i32 0, i32 3, i32 4>
  store <3 x i64> %vecinit8.i, <3 x i64>* undef, align 32
  ret void
}

define void @bad_insert(i32 %t) {
; CHECK-LABEL: bad_insert:
; CHECK:       # BB#0:
; CHECK-NEXT:    vmovd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-NEXT:    vmovaps %ymm0, (%eax)
; CHECK-NEXT:    vzeroupper
; CHECK-NEXT:    retl
  %v2 = insertelement <8 x i32> zeroinitializer, i32 %t, i32 0
  store <8 x i32> %v2, <8 x i32> addrspace(1)* undef, align 32
  ret void
}

