; Confirm that the line number for the for.body.preheader block
; branch is the the start of the loop.

; RUN: opt -simplifycfg -loop-simplify -S <%s | FileCheck %s
;
; CHECK: for.body.preheader:
; CHECK-NEXT: br label %for.body, !dbg ![[DL:[0-9]+]]
; CHECK: ![[DL]] = !DILocation(line: 8,

; This IR can be generated by running:
; clang  src.cpp -O0 -g -S -emit-llvm -Xclang -disable-O0-optnone -o - | \
; opt -O2 -S -opt-bisect-limit=27 -o -
;
; Where  src.cpp contains:
; int foo(int count, int *bar)
; {
;   if (count + 1 > 256)
;     return 0;
;
;   int ret = count;
;   int tmp;
;   for (int j = 0; j < count; j++) {
;     tmp = bar[j];
;     ret += tmp;
;   }
;
;   return ret;
; }

define dso_local i32 @"foo"(i32 %count, i32* nocapture readonly %bar) local_unnamed_addr !dbg !8 {
entry:
  %cmp = icmp sgt i32 %count, 255, !dbg !16
  br i1 %cmp, label %return, label %for.cond.preheader, !dbg !16

for.cond.preheader:                               ; preds = %entry
  %cmp16 = icmp slt i32 0, %count, !dbg !19
  br i1 %cmp16, label %for.body.lr.ph, label %return.loopexit, !dbg !19

for.body.lr.ph:                                   ; preds = %for.cond.preheader
  br label %for.body, !dbg !19

for.body:                                         ; preds = %for.body.lr.ph, %for.body
  %j.08 = phi i32 [ 0, %for.body.lr.ph ], [ %inc, %for.body ]
  %ret.07 = phi i32 [ %count, %for.body.lr.ph ], [ %add2, %for.body ]
  %0 = zext i32 %j.08 to i64, !dbg !22
  %arrayidx = getelementptr inbounds i32, i32* %bar, i64 %0, !dbg !22
  %1 = load i32, i32* %arrayidx, align 4, !dbg !22
  %add2 = add nsw i32 %1, %ret.07, !dbg !27
  %inc = add nuw nsw i32 %j.08, 1, !dbg !28
  %cmp1 = icmp slt i32 %inc, %count, !dbg !19
  br i1 %cmp1, label %for.body, label %for.cond.return.loopexit_crit_edge, !dbg !19, !llvm.loop !29

for.cond.return.loopexit_crit_edge:               ; preds = %for.body
  %split = phi i32 [ %add2, %for.body ]
  br label %return.loopexit, !dbg !19

return.loopexit:                                  ; preds = %for.cond.return.loopexit_crit_edge, %for.cond.preheader
  %ret.0.lcssa = phi i32 [ %split, %for.cond.return.loopexit_crit_edge ], [ %count, %for.cond.preheader ], !dbg !31
  br label %return, !dbg !32

return:                                           ; preds = %return.loopexit, %entry
  %retval.0 = phi i32 [ 0, %entry ], [ %ret.0.lcssa, %return.loopexit ], !dbg !31
  ret i32 %retval.0, !dbg !32
}

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!3, !4, !5, !6}
!llvm.ident = !{!7}

!0 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus, file: !1, producer: "", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !2, nameTableKind: None)
!1 = !DIFile(filename: "src.cpp", directory: "")
!2 = !{}
!3 = !{i32 2, !"CodeView", i32 1}
!4 = !{i32 2, !"Debug Info Version", i32 3}
!5 = !{i32 1, !"wchar_size", i32 2}
!6 = !{i32 7, !"PIC Level", i32 2}
!7 = !{!""}
!8 = distinct !DISubprogram(name: "foo", linkageName: "?foo@@YAHHPEAH@Z", scope: !1, file: !1, line: 1, type: !9, scopeLine: 2, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !0, retainedNodes: !2)
!9 = !DISubroutineType(types: !10)
!10 = !{!11, !11, !12}
!11 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!12 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !11, size: 64)
!13 = !DILocalVariable(name: "bar", arg: 2, scope: !8, file: !1, line: 1, type: !12)
!14 = !DILocation(line: 1, scope: !8)
!15 = !DILocalVariable(name: "count", arg: 1, scope: !8, file: !1, line: 1, type: !11)
!16 = !DILocation(line: 3, scope: !8)
!17 = !DILocalVariable(name: "j", scope: !18, file: !1, line: 8, type: !11)
!18 = distinct !DILexicalBlock(scope: !8, file: !1, line: 8)
!19 = !DILocation(line: 8, scope: !18)
!20 = !DILocalVariable(name: "ret", scope: !8, file: !1, line: 6, type: !11)
!21 = !DILocation(line: 6, scope: !8)
!22 = !DILocation(line: 9, scope: !23)
!23 = distinct !DILexicalBlock(scope: !24, file: !1, line: 8)
!24 = distinct !DILexicalBlock(scope: !18, file: !1, line: 8)
!25 = !DILocalVariable(name: "tmp", scope: !8, file: !1, line: 7, type: !11)
!26 = !DILocation(line: 7, scope: !8)
!27 = !DILocation(line: 10, scope: !23)
!28 = !DILocation(line: 8, scope: !24)
!29 = distinct !{!29, !19, !30}
!30 = !DILocation(line: 11, scope: !18)
!31 = !DILocation(line: 0, scope: !8)
!32 = !DILocation(line: 14, scope: !8)
