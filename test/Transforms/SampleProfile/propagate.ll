; RUN: opt < %s -sample-profile -sample-profile-file=%S/Inputs/propagate.prof | opt -analyze -branch-prob | FileCheck %s

; Original C++ code for this test case:
;
; #include <stdio.h>
;
; long foo(int x, int y, long N) {
;   if (x < y) {
;     return y - x;
;   } else {
;     for (long i = 0; i < N; i++) {
;       if (i > N / 3)
;         x--;
;       if (i > N / 4) {
;         y++;
;         x += 3;
;       } else {
;         for (unsigned j = 0; j < i; j++) {
;           x += j;
;           y -= 3;
;         }
;       }
;     }
;   }
;   return y * x;
; }
;
; int main() {
;   int x = 5678;
;   int y = 1234;
;   long N = 999999;
;   printf("foo(%d, %d, %ld) = %ld\n", x, y, N, foo(x, y, N));
;   return 0;
; }

; ModuleID = 'propagate.cc'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@.str = private unnamed_addr constant [24 x i8] c"foo(%d, %d, %ld) = %ld\0A\00", align 1

; Function Attrs: nounwind uwtable
define i64 @_Z3fooiil(i32 %x, i32 %y, i64 %N) #0 {
entry:
  %retval = alloca i64, align 8
  %x.addr = alloca i32, align 4
  %y.addr = alloca i32, align 4
  %N.addr = alloca i64, align 8
  %i = alloca i64, align 8
  %j = alloca i32, align 4
  store i32 %x, i32* %x.addr, align 4
  store i32 %y, i32* %y.addr, align 4
  store i64 %N, i64* %N.addr, align 8
  %0 = load i32* %x.addr, align 4, !dbg !11
  %1 = load i32* %y.addr, align 4, !dbg !11
  %cmp = icmp slt i32 %0, %1, !dbg !11
  br i1 %cmp, label %if.then, label %if.else, !dbg !11

if.then:                                          ; preds = %entry
  %2 = load i32* %y.addr, align 4, !dbg !13
  %3 = load i32* %x.addr, align 4, !dbg !13
  %sub = sub nsw i32 %2, %3, !dbg !13
  %conv = sext i32 %sub to i64, !dbg !13
  store i64 %conv, i64* %retval, !dbg !13
  br label %return, !dbg !13

if.else:                                          ; preds = %entry
  store i64 0, i64* %i, align 8, !dbg !15
  br label %for.cond, !dbg !15

for.cond:                                         ; preds = %for.inc16, %if.else
  %4 = load i64* %i, align 8, !dbg !15
  %5 = load i64* %N.addr, align 8, !dbg !15
  %cmp1 = icmp slt i64 %4, %5, !dbg !15
  br i1 %cmp1, label %for.body, label %for.end18, !dbg !15
; CHECK: edge for.cond -> for.body probability is 10 / 11 = 90.9091% [HOT edge]
; CHECK: edge for.cond -> for.end18 probability is 1 / 11 = 9.09091%

for.body:                                         ; preds = %for.cond
  %6 = load i64* %i, align 8, !dbg !18
  %7 = load i64* %N.addr, align 8, !dbg !18
  %div = sdiv i64 %7, 3, !dbg !18
  %cmp2 = icmp sgt i64 %6, %div, !dbg !18
  br i1 %cmp2, label %if.then3, label %if.end, !dbg !18
; CHECK: edge for.body -> if.then3 probability is 1 / 5 = 20%
; CHECK: edge for.body -> if.end probability is 4 / 5 = 80%

if.then3:                                         ; preds = %for.body
  %8 = load i32* %x.addr, align 4, !dbg !21
  %dec = add nsw i32 %8, -1, !dbg !21
  store i32 %dec, i32* %x.addr, align 4, !dbg !21
  br label %if.end, !dbg !21

if.end:                                           ; preds = %if.then3, %for.body
  %9 = load i64* %i, align 8, !dbg !22
  %10 = load i64* %N.addr, align 8, !dbg !22
  %div4 = sdiv i64 %10, 4, !dbg !22
  %cmp5 = icmp sgt i64 %9, %div4, !dbg !22
  br i1 %cmp5, label %if.then6, label %if.else7, !dbg !22
; CHECK: edge if.end -> if.then6 probability is 3 / 6342 = 0.0473037%
; CHECK: edge if.end -> if.else7 probability is 6339 / 6342 = 99.9527% [HOT edge]

if.then6:                                         ; preds = %if.end
  %11 = load i32* %y.addr, align 4, !dbg !24
  %inc = add nsw i32 %11, 1, !dbg !24
  store i32 %inc, i32* %y.addr, align 4, !dbg !24
  %12 = load i32* %x.addr, align 4, !dbg !26
  %add = add nsw i32 %12, 3, !dbg !26
  store i32 %add, i32* %x.addr, align 4, !dbg !26
  br label %if.end15, !dbg !27

if.else7:                                         ; preds = %if.end
  store i32 0, i32* %j, align 4, !dbg !28
  br label %for.cond8, !dbg !28

for.cond8:                                        ; preds = %for.inc, %if.else7
  %13 = load i32* %j, align 4, !dbg !28
  %conv9 = zext i32 %13 to i64, !dbg !28
  %14 = load i64* %i, align 8, !dbg !28
  %cmp10 = icmp slt i64 %conv9, %14, !dbg !28
  br i1 %cmp10, label %for.body11, label %for.end, !dbg !28
; CHECK: edge for.cond8 -> for.body11 probability is 16191 / 16192 = 99.9938% [HOT edge]
; CHECK: edge for.cond8 -> for.end probability is 1 / 16192 = 0.00617589%

for.body11:                                       ; preds = %for.cond8
  %15 = load i32* %j, align 4, !dbg !31
  %16 = load i32* %x.addr, align 4, !dbg !31
  %add12 = add i32 %16, %15, !dbg !31
  store i32 %add12, i32* %x.addr, align 4, !dbg !31
  %17 = load i32* %y.addr, align 4, !dbg !33
  %sub13 = sub nsw i32 %17, 3, !dbg !33
  store i32 %sub13, i32* %y.addr, align 4, !dbg !33
  br label %for.inc, !dbg !34

for.inc:                                          ; preds = %for.body11
  %18 = load i32* %j, align 4, !dbg !28
  %inc14 = add i32 %18, 1, !dbg !28
  store i32 %inc14, i32* %j, align 4, !dbg !28
  br label %for.cond8, !dbg !28

for.end:                                          ; preds = %for.cond8
  br label %if.end15

if.end15:                                         ; preds = %for.end, %if.then6
  br label %for.inc16, !dbg !35

for.inc16:                                        ; preds = %if.end15
  %19 = load i64* %i, align 8, !dbg !15
  %inc17 = add nsw i64 %19, 1, !dbg !15
  store i64 %inc17, i64* %i, align 8, !dbg !15
  br label %for.cond, !dbg !15

for.end18:                                        ; preds = %for.cond
  br label %if.end19

if.end19:                                         ; preds = %for.end18
  %20 = load i32* %y.addr, align 4, !dbg !36
  %21 = load i32* %x.addr, align 4, !dbg !36
  %mul = mul nsw i32 %20, %21, !dbg !36
  %conv20 = sext i32 %mul to i64, !dbg !36
  store i64 %conv20, i64* %retval, !dbg !36
  br label %return, !dbg !36

return:                                           ; preds = %if.end19, %if.then
  %22 = load i64* %retval, !dbg !37
  ret i64 %22, !dbg !37
}

; Function Attrs: uwtable
define i32 @main() #1 {
entry:
  %retval = alloca i32, align 4
  %x = alloca i32, align 4
  %y = alloca i32, align 4
  %N = alloca i64, align 8
  store i32 0, i32* %retval
  store i32 5678, i32* %x, align 4, !dbg !38
  store i32 1234, i32* %y, align 4, !dbg !39
  store i64 999999, i64* %N, align 8, !dbg !40
  %0 = load i32* %x, align 4, !dbg !41
  %1 = load i32* %y, align 4, !dbg !41
  %2 = load i64* %N, align 8, !dbg !41
  %3 = load i32* %x, align 4, !dbg !41
  %4 = load i32* %y, align 4, !dbg !41
  %5 = load i64* %N, align 8, !dbg !41
  %call = call i64 @_Z3fooiil(i32 %3, i32 %4, i64 %5), !dbg !41
  %call1 = call i32 (i8*, ...)* @printf(i8* getelementptr inbounds ([24 x i8]* @.str, i32 0, i32 0), i32 %0, i32 %1, i64 %2, i64 %call), !dbg !41
  ret i32 0, !dbg !42
}

declare i32 @printf(i8*, ...) #2

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!8, !9}
!llvm.ident = !{!10}

!0 = metadata !{i32 786449, metadata !1, i32 4, metadata !"clang version 3.5 ", i1 false, metadata !"", i32 0, metadata !2, metadata !2, metadata !3, metadata !2, metadata !2, metadata !""} ; [ DW_TAG_compile_unit ] [propagate.cc] [DW_LANG_C_plus_plus]
!1 = metadata !{metadata !"propagate.cc", metadata !"."}
!2 = metadata !{i32 0}
!3 = metadata !{metadata !4, metadata !7}
!4 = metadata !{i32 786478, metadata !1, metadata !5, metadata !"foo", metadata !"foo", metadata !"", i32 3, metadata !6, i1 false, i1 true, i32 0, i32 0, null, i32 256, i1 false, i64 (i32, i32, i64)* @_Z3fooiil, null, null, metadata !2, i32 3} ; [ DW_TAG_subprogram ] [line 3] [def] [foo]
!5 = metadata !{i32 786473, metadata !1}          ; [ DW_TAG_file_type ] [propagate.cc]
!6 = metadata !{i32 786453, i32 0, null, metadata !"", i32 0, i64 0, i64 0, i64 0, i32 0, null, metadata !2, i32 0, null, null, null} ; [ DW_TAG_subroutine_type ] [line 0, size 0, align 0, offset 0] [from ]
!7 = metadata !{i32 786478, metadata !1, metadata !5, metadata !"main", metadata !"main", metadata !"", i32 24, metadata !6, i1 false, i1 true, i32 0, i32 0, null, i32 256, i1 false, i32 ()* @main, null, null, metadata !2, i32 24} ; [ DW_TAG_subprogram ] [line 24] [def] [main]
!8 = metadata !{i32 2, metadata !"Dwarf Version", i32 4}
!9 = metadata !{i32 1, metadata !"Debug Info Version", i32 1}
!10 = metadata !{metadata !"clang version 3.5 "}
!11 = metadata !{i32 4, i32 0, metadata !12, null}
!12 = metadata !{i32 786443, metadata !1, metadata !4, i32 4, i32 0, i32 0, i32 0} ; [ DW_TAG_lexical_block ] [propagate.cc]
!13 = metadata !{i32 5, i32 0, metadata !14, null}
!14 = metadata !{i32 786443, metadata !1, metadata !12, i32 4, i32 0, i32 0, i32 1} ; [ DW_TAG_lexical_block ] [propagate.cc]
!15 = metadata !{i32 7, i32 0, metadata !16, null}
!16 = metadata !{i32 786443, metadata !1, metadata !17, i32 7, i32 0, i32 0, i32 3} ; [ DW_TAG_lexical_block ] [propagate.cc]
!17 = metadata !{i32 786443, metadata !1, metadata !12, i32 6, i32 0, i32 0, i32 2} ; [ DW_TAG_lexical_block ] [propagate.cc]
!18 = metadata !{i32 8, i32 0, metadata !19, null} ; [ DW_TAG_imported_declaration ]
!19 = metadata !{i32 786443, metadata !1, metadata !20, i32 8, i32 0, i32 0, i32 5} ; [ DW_TAG_lexical_block ] [propagate.cc]
!20 = metadata !{i32 786443, metadata !1, metadata !16, i32 7, i32 0, i32 0, i32 4} ; [ DW_TAG_lexical_block ] [propagate.cc]
!21 = metadata !{i32 9, i32 0, metadata !19, null}
!22 = metadata !{i32 10, i32 0, metadata !23, null}
!23 = metadata !{i32 786443, metadata !1, metadata !20, i32 10, i32 0, i32 0, i32 6} ; [ DW_TAG_lexical_block ] [propagate.cc]
!24 = metadata !{i32 11, i32 0, metadata !25, null}
!25 = metadata !{i32 786443, metadata !1, metadata !23, i32 10, i32 0, i32 0, i32 7} ; [ DW_TAG_lexical_block ] [propagate.cc]
!26 = metadata !{i32 12, i32 0, metadata !25, null}
!27 = metadata !{i32 13, i32 0, metadata !25, null}
!28 = metadata !{i32 14, i32 0, metadata !29, null}
!29 = metadata !{i32 786443, metadata !1, metadata !30, i32 14, i32 0, i32 0, i32 9} ; [ DW_TAG_lexical_block ] [propagate.cc]
!30 = metadata !{i32 786443, metadata !1, metadata !23, i32 13, i32 0, i32 0, i32 8} ; [ DW_TAG_lexical_block ] [propagate.cc]
!31 = metadata !{i32 15, i32 0, metadata !32, null}
!32 = metadata !{i32 786443, metadata !1, metadata !29, i32 14, i32 0, i32 0, i32 10} ; [ DW_TAG_lexical_block ] [propagate.cc]
!33 = metadata !{i32 16, i32 0, metadata !32, null}
!34 = metadata !{i32 17, i32 0, metadata !32, null}
!35 = metadata !{i32 19, i32 0, metadata !20, null}
!36 = metadata !{i32 21, i32 0, metadata !4, null}
!37 = metadata !{i32 22, i32 0, metadata !4, null}
!38 = metadata !{i32 25, i32 0, metadata !7, null}
!39 = metadata !{i32 26, i32 0, metadata !7, null}
!40 = metadata !{i32 27, i32 0, metadata !7, null}
!41 = metadata !{i32 28, i32 0, metadata !7, null}
!42 = metadata !{i32 29, i32 0, metadata !7, null}
