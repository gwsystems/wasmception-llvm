; RUN: llvm-jitlistener %s | FileCheck %s

; CHECK: Method load [1]: main, Size = 164
; CHECK: Method unload [1]

; ModuleID = '<stdin>'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@zero_int = common global i32 0, align 4
@zero_arr = common global [10 x i32] zeroinitializer, align 16
@zero_double = common global double 0.000000e+00, align 8

define i32 @main() nounwind uwtable {
entry:
  %retval = alloca i32, align 4
  %i = alloca i32, align 4
  store i32 0, i32* %retval
  %0 = load i32* @zero_int, align 4, !dbg !21
  %add = add nsw i32 %0, 5, !dbg !21
  %idxprom = sext i32 %add to i64, !dbg !21
  %arrayidx = getelementptr inbounds [10 x i32]* @zero_arr, i32 0, i64 %idxprom, !dbg !21
  store i32 40, i32* %arrayidx, align 4, !dbg !21
  %1 = load double* @zero_double, align 8, !dbg !23
  %cmp = fcmp olt double %1, 1.000000e+00, !dbg !23
  br i1 %cmp, label %if.then, label %if.end, !dbg !23

if.then:                                          ; preds = %entry
  %2 = load i32* @zero_int, align 4, !dbg !24
  %add1 = add nsw i32 %2, 2, !dbg !24
  %idxprom2 = sext i32 %add1 to i64, !dbg !24
  %arrayidx3 = getelementptr inbounds [10 x i32]* @zero_arr, i32 0, i64 %idxprom2, !dbg !24
  store i32 70, i32* %arrayidx3, align 4, !dbg !24
  br label %if.end, !dbg !24

if.end:                                           ; preds = %if.then, %entry
  call void @llvm.dbg.declare(metadata i32* %i, metadata !25, metadata !{!"0x102"}), !dbg !27
  store i32 1, i32* %i, align 4, !dbg !28
  br label %for.cond, !dbg !28

for.cond:                                         ; preds = %for.inc, %if.end
  %3 = load i32* %i, align 4, !dbg !28
  %cmp4 = icmp slt i32 %3, 10, !dbg !28
  br i1 %cmp4, label %for.body, label %for.end, !dbg !28

for.body:                                         ; preds = %for.cond
  %4 = load i32* %i, align 4, !dbg !29
  %sub = sub nsw i32 %4, 1, !dbg !29
  %idxprom5 = sext i32 %sub to i64, !dbg !29
  %arrayidx6 = getelementptr inbounds [10 x i32]* @zero_arr, i32 0, i64 %idxprom5, !dbg !29
  %5 = load i32* %arrayidx6, align 4, !dbg !29
  %6 = load i32* %i, align 4, !dbg !29
  %idxprom7 = sext i32 %6 to i64, !dbg !29
  %arrayidx8 = getelementptr inbounds [10 x i32]* @zero_arr, i32 0, i64 %idxprom7, !dbg !29
  %7 = load i32* %arrayidx8, align 4, !dbg !29
  %add9 = add nsw i32 %5, %7, !dbg !29
  %8 = load i32* %i, align 4, !dbg !29
  %idxprom10 = sext i32 %8 to i64, !dbg !29
  %arrayidx11 = getelementptr inbounds [10 x i32]* @zero_arr, i32 0, i64 %idxprom10, !dbg !29
  store i32 %add9, i32* %arrayidx11, align 4, !dbg !29
  br label %for.inc, !dbg !31

for.inc:                                          ; preds = %for.body
  %9 = load i32* %i, align 4, !dbg !32
  %inc = add nsw i32 %9, 1, !dbg !32
  store i32 %inc, i32* %i, align 4, !dbg !32
  br label %for.cond, !dbg !32

for.end:                                          ; preds = %for.cond
  %10 = load i32* getelementptr inbounds ([10 x i32]* @zero_arr, i32 0, i64 9), align 4, !dbg !33
  %cmp12 = icmp eq i32 %10, 110, !dbg !33
  %cond = select i1 %cmp12, i32 0, i32 -1, !dbg !33
  ret i32 %cond, !dbg !33
}

declare void @llvm.dbg.declare(metadata, metadata, metadata) nounwind readnone

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!35}

!0 = !{!"0x11\0012\00clang version 3.1 ()\001\00\000\00\000", !34, !1, !1, !3, !12, null} ; [ DW_TAG_compile_unit ]
!1 = !{i32 0}
!3 = !{!5}
!5 = !{!"0x2e\00main\00main\00\006\000\001\000\006\000\000\000", !34, !6, !7, null, i32 ()* @main, null, null, !10} ; [ DW_TAG_subprogram ]
!6 = !{!"0x29", !34} ; [ DW_TAG_file_type ]
!7 = !{!"0x15\00\000\000\000\000\000\000", i32 0, !"", null, !8, null, null, null} ; [ DW_TAG_subroutine_type ] [line 0, size 0, align 0, offset 0] [from ]
!8 = !{!9}
!9 = !{!"0x24\00int\000\0032\0032\000\000\005", null, null} ; [ DW_TAG_base_type ]
!10 = !{!11}
!11 = !{!"0x24"}                      ; [ DW_TAG_base_type ]
!12 = !{!14, !15, !17}
!14 = !{!"0x34\00zero_int\00zero_int\00\001\000\001", null, !6, !9, i32* @zero_int, null} ; [ DW_TAG_variable ]
!15 = !{!"0x34\00zero_double\00zero_double\00\002\000\001", null, !6, !16, double* @zero_double, null} ; [ DW_TAG_variable ]
!16 = !{!"0x24\00double\000\0064\0064\000\000\004", null, null} ; [ DW_TAG_base_type ]
!17 = !{!"0x34\00zero_arr\00zero_arr\00\003\000\001", null, !6, !18, [10 x i32]* @zero_arr, null} ; [ DW_TAG_variable ]
!18 = !{!"0x1\00\000\00320\0032\000\000", null, !"", !9, !19, i32 0, null, null, null} ; [ DW_TAG_array_type ] [line 0, size 320, align 32, offset 0] [from int]
!19 = !{!20}
!20 = !{!"0x21\000\0010"}        ; [ DW_TAG_subrange_type ]
!21 = !{i32 7, i32 5, !22, null}
!22 = !{!"0xb\006\001\000", !34, !5} ; [ DW_TAG_lexical_block ]
!23 = !{i32 9, i32 5, !22, null}
!24 = !{i32 10, i32 9, !22, null}
!25 = !{!"0x100\00i\0012\000", !26, !6, !9} ; [ DW_TAG_auto_variable ]
!26 = !{!"0xb\0012\005\001", !34, !22} ; [ DW_TAG_lexical_block ]
!27 = !{i32 12, i32 14, !26, null}
!28 = !{i32 12, i32 19, !26, null}
!29 = !{i32 13, i32 9, !30, null}
!30 = !{!"0xb\0012\0034\002", !34, !26} ; [ DW_TAG_lexical_block ]
!31 = !{i32 14, i32 5, !30, null}
!32 = !{i32 12, i32 29, !26, null}
!33 = !{i32 15, i32 5, !22, null}
!34 = !{!"test-common-symbols.c", !"/store/store/llvm/build"}
!35 = !{i32 1, !"Debug Info Version", i32 2}
