; RUN: llc < %s -march=arm64 | FileCheck %s

define void @caller(i32* nocapture %p, i32 %a, i32 %b) nounwind optsize ssp {
; CHECK-NOT: stp
; CHECK: b       {{_callee|callee}}
; CHECK-NOT: ldp
; CHECK: ret
  %1 = icmp eq i32 %b, 0
  br i1 %1, label %3, label %2

  tail call fastcc void @callee(i32* %p, i32 %a) optsize
  br label %3

  ret void
}

define internal fastcc void @callee(i32* nocapture %p, i32 %a) nounwind optsize noinline ssp {
  store volatile i32 %a, i32* %p, align 4, !tbaa !0
  ret void
}

!0 = metadata !{metadata !"int", metadata !1}
!1 = metadata !{metadata !"omnipotent char", metadata !2}
!2 = metadata !{metadata !"Simple C/C++ TBAA"}
