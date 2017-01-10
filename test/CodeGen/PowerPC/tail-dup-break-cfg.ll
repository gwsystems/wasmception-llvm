; RUN: llc -O2 -o - %s | FileCheck %s
target datalayout = "e-m:e-i64:64-n32:64"
target triple = "powerpc64le-grtev4-linux-gnu"

; Intended layout:
; The code for tail-duplication during layout will produce the layout:
; test1
; test2
; body1 (with copy of test2)
; body2
; exit

;CHECK-LABEL: tail_dup_break_cfg:
;CHECK: mr [[TAGREG:[0-9]+]], 3
;CHECK: andi. {{[0-9]+}}, [[TAGREG]], 1
;CHECK-NEXT: bc 12, 1, [[BODY1LABEL:[._0-9A-Za-z]+]]
;CHECK-NEXT: [[TEST2LABEL:[._0-9A-Za-z]+]]: # %test2
;CHECK-NEXT: rlwinm. {{[0-9]+}}, [[TAGREG]], 0, 30, 30
;CHECK-NEXT: bne 0, [[BODY2LABEL:[._0-9A-Za-z]+]]
;CHECK-NEXT: b [[EXITLABEL:[._0-9A-Za-z]+]]
;CHECK-NEXT: [[BODY1LABEL]]
;CHECK: rlwinm. {{[0-9]+}}, [[TAGREG]], 0, 30, 30
;CHECK-NEXT: beq 0, [[EXITLABEL]]
;CHECK-NEXT: [[BODY2LABEL]]
;CHECK: [[EXITLABEL:[._0-9A-Za-z]+]]: # %exit
;CHECK: blr
define void @tail_dup_break_cfg(i32 %tag) {
entry:
  br label %test1
test1:
  %tagbit1 = and i32 %tag, 1
  %tagbit1eq0 = icmp eq i32 %tagbit1, 0
  br i1 %tagbit1eq0, label %test2, label %body1, !prof !1 ; %test2 more likely
body1:
  call void @a()
  call void @a()
  call void @a()
  call void @a()
  br label %test2
test2:
  %tagbit2 = and i32 %tag, 2
  %tagbit2eq0 = icmp eq i32 %tagbit2, 0
  br i1 %tagbit2eq0, label %exit, label %body2
body2:
  call void @b()
  call void @b()
  call void @b()
  call void @b()
  br label %exit
exit:
  ret void
}

declare void @a()
declare void @b()
declare void @c()
declare void @d()

!1 = !{!"branch_weights", i32 2, i32 1}
