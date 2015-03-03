; RUN: llc -O0 -mtriple=x86_64-apple-darwin -filetype=asm %s -o - | FileCheck %s
; Ensure that we generate an indirect location for the variable length array a.
; CHECK: ##DEBUG_VALUE: vla:a <- RDX
; CHECK: DW_OP_breg1
; rdar://problem/13658587
;
; generated from:
;
; int vla(int n) {
;   int a[n];
;   a[0] = 42;
;   return a[n-1];
; }
;
; int main(int argc, char** argv) {
;    return vla(argc);
; }

; ModuleID = 'vla.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.8.0"

; Function Attrs: nounwind ssp uwtable
define i32 @vla(i32 %n) nounwind ssp uwtable {
entry:
  %n.addr = alloca i32, align 4
  %saved_stack = alloca i8*
  %cleanup.dest.slot = alloca i32
  store i32 %n, i32* %n.addr, align 4
  call void @llvm.dbg.declare(metadata i32* %n.addr, metadata !15, metadata !MDExpression()), !dbg !16
  %0 = load i32, i32* %n.addr, align 4, !dbg !17
  %1 = zext i32 %0 to i64, !dbg !17
  %2 = call i8* @llvm.stacksave(), !dbg !17
  store i8* %2, i8** %saved_stack, !dbg !17
  %vla = alloca i32, i64 %1, align 16, !dbg !17
  call void @llvm.dbg.declare(metadata i32* %vla, metadata !18, metadata !MDExpression(DW_OP_deref)), !dbg !17
  %arrayidx = getelementptr inbounds i32, i32* %vla, i64 0, !dbg !22
  store i32 42, i32* %arrayidx, align 4, !dbg !22
  %3 = load i32, i32* %n.addr, align 4, !dbg !23
  %sub = sub nsw i32 %3, 1, !dbg !23
  %idxprom = sext i32 %sub to i64, !dbg !23
  %arrayidx1 = getelementptr inbounds i32, i32* %vla, i64 %idxprom, !dbg !23
  %4 = load i32, i32* %arrayidx1, align 4, !dbg !23
  store i32 1, i32* %cleanup.dest.slot
  %5 = load i8*, i8** %saved_stack, !dbg !24
  call void @llvm.stackrestore(i8* %5), !dbg !24
  ret i32 %4, !dbg !23
}

; Function Attrs: nounwind readnone
declare void @llvm.dbg.declare(metadata, metadata, metadata) nounwind readnone

; Function Attrs: nounwind
declare i8* @llvm.stacksave() nounwind

; Function Attrs: nounwind
declare void @llvm.stackrestore(i8*) nounwind

; Function Attrs: nounwind ssp uwtable
define i32 @main(i32 %argc, i8** %argv) nounwind ssp uwtable {
entry:
  %retval = alloca i32, align 4
  %argc.addr = alloca i32, align 4
  %argv.addr = alloca i8**, align 8
  store i32 0, i32* %retval
  store i32 %argc, i32* %argc.addr, align 4
  call void @llvm.dbg.declare(metadata i32* %argc.addr, metadata !25, metadata !MDExpression()), !dbg !26
  store i8** %argv, i8*** %argv.addr, align 8
  call void @llvm.dbg.declare(metadata i8*** %argv.addr, metadata !27, metadata !MDExpression()), !dbg !26
  %0 = load i32, i32* %argc.addr, align 4, !dbg !28
  %call = call i32 @vla(i32 %0), !dbg !28
  ret i32 %call, !dbg !28
}

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!29}

!0 = !MDCompileUnit(language: DW_LANG_C99, producer: "clang version 3.3 ", isOptimized: false, emissionKind: 1, file: !1, enums: !2, retainedTypes: !2, subprograms: !3, globals: !2, imports: !2)
!1 = !MDFile(filename: "vla.c", directory: "")
!2 = !{}
!3 = !{!4, !9}
!4 = !MDSubprogram(name: "vla", line: 1, isLocal: false, isDefinition: true, virtualIndex: 6, flags: DIFlagPrototyped, isOptimized: false, scopeLine: 1, file: !1, scope: !5, type: !6, function: i32 (i32)* @vla, variables: !2)
!5 = !MDFile(filename: "vla.c", directory: "")
!6 = !MDSubroutineType(types: !7)
!7 = !{!8, !8}
!8 = !MDBasicType(tag: DW_TAG_base_type, name: "int", size: 32, align: 32, encoding: DW_ATE_signed)
!9 = !MDSubprogram(name: "main", line: 7, isLocal: false, isDefinition: true, virtualIndex: 6, flags: DIFlagPrototyped, isOptimized: false, scopeLine: 7, file: !1, scope: !5, type: !10, function: i32 (i32, i8**)* @main, variables: !2)
!10 = !MDSubroutineType(types: !11)
!11 = !{!8, !8, !12}
!12 = !MDDerivedType(tag: DW_TAG_pointer_type, size: 64, align: 64, baseType: !13)
!13 = !MDDerivedType(tag: DW_TAG_pointer_type, size: 64, align: 64, baseType: !14)
!14 = !MDBasicType(tag: DW_TAG_base_type, name: "char", size: 8, align: 8, encoding: DW_ATE_signed_char)
!15 = !MDLocalVariable(tag: DW_TAG_arg_variable, name: "n", line: 1, arg: 1, scope: !4, file: !5, type: !8)
!16 = !MDLocation(line: 1, scope: !4)
!17 = !MDLocation(line: 2, scope: !4)
!18 = !MDLocalVariable(tag: DW_TAG_auto_variable, name: "a", line: 2, scope: !4, file: !5, type: !19)
!19 = !MDCompositeType(tag: DW_TAG_array_type, align: 32, baseType: !8, elements: !20)
!20 = !{!21}
!21 = !MDSubrange(count: -1)
!22 = !MDLocation(line: 3, scope: !4)
!23 = !MDLocation(line: 4, scope: !4)
!24 = !MDLocation(line: 5, scope: !4)
!25 = !MDLocalVariable(tag: DW_TAG_arg_variable, name: "argc", line: 7, arg: 1, scope: !9, file: !5, type: !8)
!26 = !MDLocation(line: 7, scope: !9)
!27 = !MDLocalVariable(tag: DW_TAG_arg_variable, name: "argv", line: 7, arg: 2, scope: !9, file: !5, type: !12)
!28 = !MDLocation(line: 8, scope: !9)
!29 = !{i32 1, !"Debug Info Version", i32 3}
