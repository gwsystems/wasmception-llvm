; Test 64-bit atomic minimum and maximum.
;
; RUN: llc < %s -mtriple=s390x-linux-gnu | FileCheck %s

; Check signed minium.
define i64 @f1(i64 %dummy, i64 *%src, i64 %b) {
; CHECK: f1:
; CHECK: lg %r2, 0(%r3)
; CHECK: [[LOOP:\.[^:]*]]:
; CHECK: cgr %r2, %r4
; CHECK: lgr [[NEW:%r[0-9]+]], %r2
; CHECK: jle [[KEEP:\..*]]
; CHECK: lgr [[NEW]], %r4
; CHECK: csg %r2, [[NEW]], 0(%r3)
; CHECK: jlh [[LOOP]]
; CHECK: br %r14
  %res = atomicrmw min i64 *%src, i64 %b seq_cst
  ret i64 %res
}

; Check signed maximum.
define i64 @f2(i64 %dummy, i64 *%src, i64 %b) {
; CHECK: f2:
; CHECK: lg %r2, 0(%r3)
; CHECK: [[LOOP:\.[^:]*]]:
; CHECK: cgr %r2, %r4
; CHECK: lgr [[NEW:%r[0-9]+]], %r2
; CHECK: jhe [[KEEP:\..*]]
; CHECK: lgr [[NEW]], %r4
; CHECK: csg %r2, [[NEW]], 0(%r3)
; CHECK: jlh [[LOOP]]
; CHECK: br %r14
  %res = atomicrmw max i64 *%src, i64 %b seq_cst
  ret i64 %res
}

; Check unsigned minimum.
define i64 @f3(i64 %dummy, i64 *%src, i64 %b) {
; CHECK: f3:
; CHECK: lg %r2, 0(%r3)
; CHECK: [[LOOP:\.[^:]*]]:
; CHECK: clgr %r2, %r4
; CHECK: lgr [[NEW:%r[0-9]+]], %r2
; CHECK: jle [[KEEP:\..*]]
; CHECK: lgr [[NEW]], %r4
; CHECK: csg %r2, [[NEW]], 0(%r3)
; CHECK: jlh [[LOOP]]
; CHECK: br %r14
  %res = atomicrmw umin i64 *%src, i64 %b seq_cst
  ret i64 %res
}

; Check unsigned maximum.
define i64 @f4(i64 %dummy, i64 *%src, i64 %b) {
; CHECK: f4:
; CHECK: lg %r2, 0(%r3)
; CHECK: [[LOOP:\.[^:]*]]:
; CHECK: clgr %r2, %r4
; CHECK: lgr [[NEW:%r[0-9]+]], %r2
; CHECK: jhe [[KEEP:\..*]]
; CHECK: lgr [[NEW]], %r4
; CHECK: csg %r2, [[NEW]], 0(%r3)
; CHECK: jlh [[LOOP]]
; CHECK: br %r14
  %res = atomicrmw umax i64 *%src, i64 %b seq_cst
  ret i64 %res
}

; Check the high end of the aligned CSG range.
define i64 @f5(i64 %dummy, i64 *%src, i64 %b) {
; CHECK: f5:
; CHECK: lg %r2, 524280(%r3)
; CHECK: csg %r2, {{%r[0-9]+}}, 524280(%r3)
; CHECK: br %r14
  %ptr = getelementptr i64 *%src, i64 65535
  %res = atomicrmw min i64 *%ptr, i64 %b seq_cst
  ret i64 %res
}

; Check the next doubleword up, which requires separate address logic.
define i64 @f6(i64 %dummy, i64 *%src, i64 %b) {
; CHECK: f6:
; CHECK: agfi %r3, 524288
; CHECK: lg %r2, 0(%r3)
; CHECK: csg %r2, {{%r[0-9]+}}, 0(%r3)
; CHECK: br %r14
  %ptr = getelementptr i64 *%src, i64 65536
  %res = atomicrmw min i64 *%ptr, i64 %b seq_cst
  ret i64 %res
}

; Check the low end of the CSG range.
define i64 @f7(i64 %dummy, i64 *%src, i64 %b) {
; CHECK: f7:
; CHECK: lg %r2, -524288(%r3)
; CHECK: csg %r2, {{%r[0-9]+}}, -524288(%r3)
; CHECK: br %r14
  %ptr = getelementptr i64 *%src, i64 -65536
  %res = atomicrmw min i64 *%ptr, i64 %b seq_cst
  ret i64 %res
}

; Check the next doubleword down, which requires separate address logic.
define i64 @f8(i64 %dummy, i64 *%src, i64 %b) {
; CHECK: f8:
; CHECK: agfi %r3, -524296
; CHECK: lg %r2, 0(%r3)
; CHECK: csg %r2, {{%r[0-9]+}}, 0(%r3)
; CHECK: br %r14
  %ptr = getelementptr i64 *%src, i64 -65537
  %res = atomicrmw min i64 *%ptr, i64 %b seq_cst
  ret i64 %res
}

; Check that indexed addresses are not allowed.
define i64 @f9(i64 %dummy, i64 %base, i64 %index, i64 %b) {
; CHECK: f9:
; CHECK: agr %r3, %r4
; CHECK: lg %r2, 0(%r3)
; CHECK: csg %r2, {{%r[0-9]+}}, 0(%r3)
; CHECK: br %r14
  %add = add i64 %base, %index
  %ptr = inttoptr i64 %add to i64 *
  %res = atomicrmw min i64 *%ptr, i64 %b seq_cst
  ret i64 %res
}

; Check that constants are forced into a register.
define i64 @f10(i64 %dummy, i64 *%ptr) {
; CHECK: f10:
; CHECK: lghi [[LIMIT:%r[0-9]+]], 42
; CHECK: lg %r2, 0(%r3)
; CHECK: [[LOOP:\.[^:]*]]:
; CHECK: cgr %r2, [[LIMIT]]
; CHECK: lgr [[NEW:%r[0-9]+]], %r2
; CHECK: jle [[KEEP:\..*]]
; CHECK: lgr [[NEW]], [[LIMIT]]
; CHECK: csg %r2, [[NEW]], 0(%r3)
; CHECK: jlh [[LOOP]]
; CHECK: br %r14
  %res = atomicrmw min i64 *%ptr, i64 42 seq_cst
  ret i64 %res
}
