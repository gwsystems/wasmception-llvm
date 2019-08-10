; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i386-pc-windows-msvc | FileCheck %s

target datalayout = "e-m:x-p:32:32-i64:64-f80:32-n8:16:32-a:0:32-S32"
target triple = "i386-pc-windows-msvc"

%struct._param_str = type { i32, i32, [4096 x i32], i32 }

@g_d = common dso_local local_unnamed_addr global i32 0, align 4
@g_c = common dso_local local_unnamed_addr global i32 0, align 4
@g_b = common dso_local local_unnamed_addr global i32 0, align 4
@g_a = common dso_local local_unnamed_addr global i32 0, align 4
@g_param = common dso_local global %struct._param_str zeroinitializer, align 4

; Function Attrs: nounwind
define dso_local i32 @test() local_unnamed_addr {
; CHECK-LABEL: test:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    pushl %edi
; CHECK-NEXT:    pushl %esi
; CHECK-NEXT:    movl $16396, %eax # imm = 0x400C
; CHECK-NEXT:    calll __chkstk
; CHECK-NEXT:    movl _g_d, %eax
; CHECK-NEXT:    movl _g_c, %ecx
; CHECK-NEXT:    movl _g_b, %edx
; CHECK-NEXT:    movl _g_a, %esi
; CHECK-NEXT:    movl %eax, {{[0-9]+}}(%esp)
; CHECK-NEXT:    movl %ecx, {{[0-9]+}}(%esp)
; CHECK-NEXT:    movl %edx, {{[0-9]+}}(%esp)
; CHECK-NEXT:    movl %esi, (%esp)
; CHECK-NEXT:    calll _bar
; CHECK-NEXT:    movl $4099, %ecx # imm = 0x1003
; CHECK-NEXT:    movl %esp, %edi
; CHECK-NEXT:    movl $_g_param, %esi
; CHECK-NEXT:    rep;movsl (%esi), %es:(%edi)
; CHECK-NEXT:    calll _foo
; CHECK-NEXT:    xorl %eax, %eax
; CHECK-NEXT:    addl $16396, %esp # imm = 0x400C
; CHECK-NEXT:    popl %esi
; CHECK-NEXT:    popl %edi
; CHECK-NEXT:    retl
entry:
  %0 = load i32, i32* @g_d, align 4, !tbaa !3
  %1 = load i32, i32* @g_c, align 4, !tbaa !3
  %2 = load i32, i32* @g_b, align 4, !tbaa !3
  %3 = load i32, i32* @g_a, align 4, !tbaa !3
  %call = tail call i32 @bar(i32 %3, i32 %2, i32 %1, i32 %0) #2
  tail call void @foo(%struct._param_str* byval nonnull align 4 @g_param) #2
  ret i32 0
}

declare dso_local i32 @bar(i32, i32, i32, i32) local_unnamed_addr

declare dso_local void @foo(%struct._param_str* byval align 4) local_unnamed_addr

!3 = !{!4, !4, i64 0}
!4 = !{!"int", !5, i64 0}
!5 = !{!"omnipotent char", !6, i64 0}
!6 = !{!"Simple C/C++ TBAA"}
