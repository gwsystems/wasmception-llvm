; Test the use of TEST UNDER MASK for 64-bit operations.
;
; RUN: llc < %s -mtriple=s390x-linux-gnu -mcpu=z196 | FileCheck %s

@g = global i32 0

; Check the lowest useful TMLL value.
define void @f1(i64 %a) {
; CHECK-LABEL: f1:
; CHECK: tmll %r2, 1
; CHECK: je {{\.L.*}}
; CHECK: br %r14
entry:
  %and = and i64 %a, 1
  %cmp = icmp eq i64 %and, 0
  br i1 %cmp, label %exit, label %store

store:
  store i32 1, i32 *@g
  br label %exit

exit:
  ret void
}

; Check the high end of the TMLL range.
define void @f2(i64 %a) {
; CHECK-LABEL: f2:
; CHECK: tmll %r2, 65535
; CHECK: jne {{\.L.*}}
; CHECK: br %r14
entry:
  %and = and i64 %a, 65535
  %cmp = icmp ne i64 %and, 0
  br i1 %cmp, label %exit, label %store

store:
  store i32 1, i32 *@g
  br label %exit

exit:
  ret void
}

; Check the lowest useful TMLH value, which is the next value up.
define void @f3(i64 %a) {
; CHECK-LABEL: f3:
; CHECK: tmlh %r2, 1
; CHECK: jne {{\.L.*}}
; CHECK: br %r14
entry:
  %and = and i64 %a, 65536
  %cmp = icmp ne i64 %and, 0
  br i1 %cmp, label %exit, label %store

store:
  store i32 1, i32 *@g
  br label %exit

exit:
  ret void
}

; Check the next value up again, which cannot use TM.
define void @f4(i64 %a) {
; CHECK-LABEL: f4:
; CHECK-NOT: {{tm[lh].}}
; CHECK: br %r14
entry:
  %and = and i64 %a, 4294901759
  %cmp = icmp eq i64 %and, 0
  br i1 %cmp, label %exit, label %store

store:
  store i32 1, i32 *@g
  br label %exit

exit:
  ret void
}

; Check the high end of the TMLH range.
define void @f5(i64 %a) {
; CHECK-LABEL: f5:
; CHECK: tmlh %r2, 65535
; CHECK: je {{\.L.*}}
; CHECK: br %r14
entry:
  %and = and i64 %a, 4294901760
  %cmp = icmp eq i64 %and, 0
  br i1 %cmp, label %exit, label %store

store:
  store i32 1, i32 *@g
  br label %exit

exit:
  ret void
}

; Check the lowest useful TMHL value.
define void @f6(i64 %a) {
; CHECK-LABEL: f6:
; CHECK: tmhl %r2, 1
; CHECK: je {{\.L.*}}
; CHECK: br %r14
entry:
  %and = and i64 %a, 4294967296
  %cmp = icmp eq i64 %and, 0
  br i1 %cmp, label %exit, label %store

store:
  store i32 1, i32 *@g
  br label %exit

exit:
  ret void
}

; Check the next value up again, which cannot use TM.
define void @f7(i64 %a) {
; CHECK-LABEL: f7:
; CHECK-NOT: {{tm[lh].}}
; CHECK: br %r14
entry:
  %and = and i64 %a, 4294967297
  %cmp = icmp ne i64 %and, 0
  br i1 %cmp, label %exit, label %store

store:
  store i32 1, i32 *@g
  br label %exit

exit:
  ret void
}

; Check the high end of the TMHL range.
define void @f8(i64 %a) {
; CHECK-LABEL: f8:
; CHECK: tmhl %r2, 65535
; CHECK: jne {{\.L.*}}
; CHECK: br %r14
entry:
  %and = and i64 %a, 281470681743360
  %cmp = icmp ne i64 %and, 0
  br i1 %cmp, label %exit, label %store

store:
  store i32 1, i32 *@g
  br label %exit

exit:
  ret void
}

; Check the lowest useful TMHH value.
define void @f9(i64 %a) {
; CHECK-LABEL: f9:
; CHECK: tmhh %r2, 1
; CHECK: jne {{\.L.*}}
; CHECK: br %r14
entry:
  %and = and i64 %a, 281474976710656
  %cmp = icmp ne i64 %and, 0
  br i1 %cmp, label %exit, label %store

store:
  store i32 1, i32 *@g
  br label %exit

exit:
  ret void
}

; Check the high end of the TMHH range.
define void @f10(i64 %a) {
; CHECK-LABEL: f10:
; CHECK: tmhh %r2, 65535
; CHECK: je {{\.L.*}}
; CHECK: br %r14
entry:
  %and = and i64 %a, 18446462598732840960
  %cmp = icmp eq i64 %and, 0
  br i1 %cmp, label %exit, label %store

store:
  store i32 1, i32 *@g
  br label %exit

exit:
  ret void
}
