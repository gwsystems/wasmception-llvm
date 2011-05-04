; RUN: llc < %s -verify-machineinstrs
; <rdar://problem/9187612>
target datalayout = "e-p:32:32:32-i1:8:32-i8:8:32-i16:16:32-i32:32:32-i64:32:32-f32:32:32-f64:32:32-v64:64:64-v128:128:128-a0:0:32-n32"
target triple = "thumbv7-apple-darwin"

define void @func() unnamed_addr align 2 {
entry:
  br label %for.cond

for.cond:
  %tmp2 = phi i32 [ 0, %entry ], [ %add, %for.cond.backedge ]
  %cmp = icmp ult i32 %tmp2, 14
  br i1 %cmp, label %for.body, label %for.end

for.body:
  %add = add i32 %tmp2, 1
  switch i32 %tmp2, label %sw.default [
    i32 0, label %sw.bb
    i32 1, label %sw.bb
    i32 2, label %sw.bb
    i32 4, label %sw.bb
    i32 5, label %sw.bb
    i32 10, label %sw.bb
  ]

sw.bb:
  invoke void @foo()
          to label %invoke.cont17 unwind label %lpad

invoke.cont17:
  invoke void @foo()
          to label %for.cond.backedge unwind label %lpad26

for.cond.backedge:
  br label %for.cond

lpad:
  %exn = tail call i8* @llvm.eh.exception() nounwind
  %eh.selector = tail call i32 (i8*, i8*, ...)* @llvm.eh.selector(i8* %exn, i8* bitcast (i32 (...)* @__gxx_personality_sj0 to i8*), i8* null) nounwind
  invoke void @foo()
          to label %eh.resume unwind label %terminate.lpad

lpad26:
  %exn27 = tail call i8* @llvm.eh.exception() nounwind
  %eh.selector28 = tail call i32 (i8*, i8*, ...)* @llvm.eh.selector(i8* %exn27, i8* bitcast (i32 (...)* @__gxx_personality_sj0 to i8*), i8* null) nounwind
  invoke void @foo()
          to label %eh.resume unwind label %terminate.lpad

sw.default:
  br label %for.cond.backedge

for.end:
  invoke void @foo()
          to label %call8.i.i.i.noexc unwind label %lpad44

call8.i.i.i.noexc:
  ret void

lpad44:
  %exn45 = tail call i8* @llvm.eh.exception() nounwind
  %eh.selector46 = tail call i32 (i8*, i8*, ...)* @llvm.eh.selector(i8* %exn45, i8* bitcast (i32 (...)* @__gxx_personality_sj0 to i8*), i8* null) nounwind
  invoke void @foo()
          to label %eh.resume unwind label %terminate.lpad

eh.resume:
  %exn.slot.0 = phi i8* [ %exn27, %lpad26 ], [ %exn, %lpad ], [ %exn45, %lpad44 ]
  tail call void @_Unwind_SjLj_Resume_or_Rethrow(i8* %exn.slot.0) noreturn
  unreachable

terminate.lpad:
  %exn51 = tail call i8* @llvm.eh.exception() nounwind
  %eh.selector52 = tail call i32 (i8*, i8*, ...)* @llvm.eh.selector(i8* %exn51, i8* bitcast (i32 (...)* @__gxx_personality_sj0 to i8*), i8* null) nounwind
  tail call void @_ZSt9terminatev() noreturn nounwind
  unreachable
}

declare void @foo()

declare i8* @llvm.eh.exception() nounwind readonly

declare i32 @__gxx_personality_sj0(...)

declare i32 @llvm.eh.selector(i8*, i8*, ...) nounwind

declare void @_Unwind_SjLj_Resume_or_Rethrow(i8*)

declare void @_ZSt9terminatev()

!0 = metadata !{metadata !"any pointer", metadata !1}
!1 = metadata !{metadata !"omnipotent char", metadata !2}
!2 = metadata !{metadata !"Simple C/C++ TBAA", null}
!3 = metadata !{metadata !"bool", metadata !1}
!4 = metadata !{metadata !"int", metadata !1}
