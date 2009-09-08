; This testcase consists of alias relations which should be completely
; resolvable by basicaa, but require analysis of getelementptr constant exprs.

; RUN: opt %s -aa-eval -print-may-aliases -disable-output \
; RUN: |& not grep May:

%T = type { i32, [10 x i8] }

@G = external global %T

define void @test() {
  %D = getelementptr %T* @G, i64 0, i32 0
  %E = getelementptr %T* @G, i64 0, i32 1, i64 5
  %F = getelementptr i32* getelementptr (%T* @G, i64 0, i32 0), i64 0
  %X = getelementptr [10 x i8]* getelementptr (%T* @G, i64 0, i32 1), i64 0, i64 5

  ret void
}
