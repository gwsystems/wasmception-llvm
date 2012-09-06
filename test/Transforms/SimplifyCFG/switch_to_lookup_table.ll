; RUN: opt < %s -simplifycfg -S | FileCheck %s

target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; The table for @f
; CHECK: @switch.table = private unnamed_addr constant [7 x i32] [i32 55, i32 123, i32 0, i32 -1, i32 27, i32 62, i32 1]

; The float table for @h
; CHECK: @switch.table1 = private unnamed_addr constant [4 x float] [float 0x40091EB860000000, float 0x3FF3BE76C0000000, float 0x4012449BA0000000, float 0x4001AE1480000000]

; The int table for @h
; CHECK: @switch.table2 = private unnamed_addr constant [4 x i8] c"*\09X\05"

; The table for @foostring
; CHECK: @switch.table3 = private unnamed_addr constant [4 x i8*] [i8* getelementptr inbounds ([4 x i8]* @.str, i64 0, i64 0), i8* getelementptr inbounds ([4 x i8]* @.str1, i64 0, i64 0), i8* getelementptr inbounds ([4 x i8]* @.str2, i64 0, i64 0), i8* getelementptr inbounds ([4 x i8]* @.str3, i64 0, i64 0)]

; A simple int-to-int selection switch.
; It is dense enough to be replaced by table lookup.
; The result is directly by a ret from an otherwise empty bb,
; so we return early, directly from the lookup bb.

define i32 @f(i32 %c) nounwind uwtable readnone {
entry:
  switch i32 %c, label %sw.default [
    i32 42, label %return
    i32 43, label %sw.bb1
    i32 44, label %sw.bb2
    i32 45, label %sw.bb3
    i32 46, label %sw.bb4
    i32 47, label %sw.bb5
    i32 48, label %sw.bb6
  ]

sw.bb1: br label %return
sw.bb2: br label %return
sw.bb3: br label %return
sw.bb4: br label %return
sw.bb5: br label %return
sw.bb6: br label %return
sw.default: br label %return
return:
  %retval.0 = phi i32 [ 15, %sw.default ], [ 1, %sw.bb6 ], [ 62, %sw.bb5 ], [ 27, %sw.bb4 ], [ -1, %sw.bb3 ], [ 0, %sw.bb2 ], [ 123, %sw.bb1 ], [ 55, %entry ]
  ret i32 %retval.0

; CHECK: @f
; CHECK: entry:
; CHECK-NEXT: %switch.tableidx = sub i32 %c, 42
; CHECK-NEXT: %0 = icmp ult i32 %switch.tableidx, 7
; CHECK-NEXT: br i1 %0, label %switch.lookup, label %return
; CHECK: switch.lookup:
; CHECK-NEXT: %switch.gep = getelementptr inbounds [7 x i32]* @switch.table, i32 0, i32 %switch.tableidx
; CHECK-NEXT: %switch.load = load i32* %switch.gep
; CHECK-NEXT: ret i32 %switch.load
; CHECK: return:
; CHECK-NEXT: ret i32 15
}

; A switch used to initialize two variables, an i8 and a float.

declare void @dummy(i8 signext, float)
define void @h(i32 %x) {
entry:
  switch i32 %x, label %sw.default [
    i32 0, label %sw.epilog
    i32 1, label %sw.bb1
    i32 2, label %sw.bb2
    i32 3, label %sw.bb3
  ]

sw.bb1: br label %sw.epilog
sw.bb2: br label %sw.epilog
sw.bb3: br label %sw.epilog
sw.default: br label %sw.epilog

sw.epilog:
  %a.0 = phi i8 [ 7, %sw.default ], [ 5, %sw.bb3 ], [ 88, %sw.bb2 ], [ 9, %sw.bb1 ], [ 42, %entry ]
  %b.0 = phi float [ 0x4023FAE140000000, %sw.default ], [ 0x4001AE1480000000, %sw.bb3 ], [ 0x4012449BA0000000, %sw.bb2 ], [ 0x3FF3BE76C0000000, %sw.bb1 ], [ 0x40091EB860000000, %entry ]
  call void @dummy(i8 signext %a.0, float %b.0)
  ret void

; CHECK: @h
; CHECK: entry:
; CHECK-NEXT: %switch.tableidx = sub i32 %x, 0
; CHECK-NEXT: %0 = icmp ult i32 %switch.tableidx, 4
; CHECK-NEXT: br i1 %0, label %switch.lookup, label %sw.epilog
; CHECK: switch.lookup:
; CHECK-NEXT: %switch.gep = getelementptr inbounds [4 x i8]* @switch.table2, i32 0, i32 %switch.tableidx
; CHECK-NEXT: %switch.load = load i8* %switch.gep
; CHECK-NEXT: %switch.gep1 = getelementptr inbounds [4 x float]* @switch.table1, i32 0, i32 %switch.tableidx
; CHECK-NEXT: %switch.load2 = load float* %switch.gep1
; CHECK-NEXT: br label %sw.epilog
; CHECK: sw.epilog:
; CHECK-NEXT: %a.0 = phi i8 [ %switch.load, %switch.lookup ], [ 7, %entry ]
; CHECK-NEXT: %b.0 = phi float [ %switch.load2, %switch.lookup ], [ 0x4023FAE140000000, %entry ]
; CHECK-NEXT: call void @dummy(i8 signext %a.0, float %b.0)
; CHECK-NEXT: ret void
}


; Switch used to return a string.

@.str = private unnamed_addr constant [4 x i8] c"foo\00", align 1
@.str1 = private unnamed_addr constant [4 x i8] c"bar\00", align 1
@.str2 = private unnamed_addr constant [4 x i8] c"baz\00", align 1
@.str3 = private unnamed_addr constant [4 x i8] c"qux\00", align 1
@.str4 = private unnamed_addr constant [6 x i8] c"error\00", align 1

define i8* @foostring(i32 %x)  {
entry:
  switch i32 %x, label %sw.default [
    i32 0, label %return
    i32 1, label %sw.bb1
    i32 2, label %sw.bb2
    i32 3, label %sw.bb3
  ]

sw.bb1: br label %return
sw.bb2: br label %return
sw.bb3: br label %return
sw.default: br label %return

return:
  %retval.0 = phi i8* [ getelementptr inbounds ([6 x i8]* @.str4, i64 0, i64 0), %sw.default ],
                      [ getelementptr inbounds ([4 x i8]* @.str3, i64 0, i64 0), %sw.bb3 ],
                      [ getelementptr inbounds ([4 x i8]* @.str2, i64 0, i64 0), %sw.bb2 ],
                      [ getelementptr inbounds ([4 x i8]* @.str1, i64 0, i64 0), %sw.bb1 ],
                      [ getelementptr inbounds ([4 x i8]* @.str, i64 0, i64 0), %entry ]
  ret i8* %retval.0

; CHECK: @foostring
; CHECK: entry:
; CHECK-NEXT: %switch.tableidx = sub i32 %x, 0
; CHECK-NEXT: %0 = icmp ult i32 %switch.tableidx, 4
; CHECK-NEXT: br i1 %0, label %switch.lookup, label %return
; CHECK: switch.lookup:
; CHECK-NEXT: %switch.gep = getelementptr inbounds [4 x i8*]* @switch.table3, i32 0, i32 %switch.tableidx
; CHECK-NEXT: %switch.load = load i8** %switch.gep
; CHECK-NEXT: ret i8* %switch.load
}
