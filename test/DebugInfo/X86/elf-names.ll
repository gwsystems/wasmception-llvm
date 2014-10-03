; RUN: llc -mtriple=x86_64-unknown-linux-gnu %s -o %t -filetype=obj
; RUN: llvm-dwarfdump -debug-dump=info %t | FileCheck %s
; RUN: llvm-as < %s | llvm-dis | FileCheck --check-prefix=CHECK-DIS %s

; CHECK: 0x0000000b: DW_TAG_compile_unit
; CHECK:               DW_AT_name [DW_FORM_strp] ( .debug_str[0x00000035] = "foo.cpp")
; CHECK: 0x{{[0-9a-f]+}}:   DW_TAG_class_type
; CHECK:                 DW_AT_name [DW_FORM_strp]       ( .debug_str[0x{{[0-9a-f]+}}] = "D")
; CHECK: 0x{{[0-9a-f]+}}:     DW_TAG_member
; CHECK:                   DW_AT_name [DW_FORM_strp]     ( .debug_str[0x{{[0-9a-f]+}}] = "c1")
; CHECK: DW_TAG_subprogram
; CHECK-NEXT: DW_AT_name [DW_FORM_strp]     ( .debug_str[0x{{[0-9a-f]+}}] = "D")
; CHECK: DW_TAG_formal_parameter
; CHECK: DW_AT_artificial [DW_FORM_flag_present]       (true)

; CHECK-DIS: [artificial]

%class.D = type { i32, i32, i32, i32 }

@_ZN1DC1Ev = alias void (%class.D*)* @_ZN1DC2Ev
@_ZN1DC1ERKS_ = alias void (%class.D*, %class.D*)* @_ZN1DC2ERKS_

define void @_ZN1DC2Ev(%class.D* nocapture %this) unnamed_addr nounwind uwtable align 2 {
entry:
  tail call void @llvm.dbg.value(metadata !{%class.D* %this}, i64 0, metadata !29, metadata !{metadata !"0x102"}), !dbg !36
  %c1 = getelementptr inbounds %class.D* %this, i64 0, i32 0, !dbg !37
  store i32 1, i32* %c1, align 4, !dbg !37
  %c2 = getelementptr inbounds %class.D* %this, i64 0, i32 1, !dbg !42
  store i32 2, i32* %c2, align 4, !dbg !42
  %c3 = getelementptr inbounds %class.D* %this, i64 0, i32 2, !dbg !43
  store i32 3, i32* %c3, align 4, !dbg !43
  %c4 = getelementptr inbounds %class.D* %this, i64 0, i32 3, !dbg !44
  store i32 4, i32* %c4, align 4, !dbg !44
  ret void, !dbg !45
}

define void @_ZN1DC2ERKS_(%class.D* nocapture %this, %class.D* nocapture %d) unnamed_addr nounwind uwtable align 2 {
entry:
  tail call void @llvm.dbg.value(metadata !{%class.D* %this}, i64 0, metadata !34, metadata !{metadata !"0x102"}), !dbg !46
  tail call void @llvm.dbg.value(metadata !{%class.D* %d}, i64 0, metadata !35, metadata !{metadata !"0x102"}), !dbg !46
  %c1 = getelementptr inbounds %class.D* %d, i64 0, i32 0, !dbg !47
  %0 = load i32* %c1, align 4, !dbg !47
  %c12 = getelementptr inbounds %class.D* %this, i64 0, i32 0, !dbg !47
  store i32 %0, i32* %c12, align 4, !dbg !47
  %c2 = getelementptr inbounds %class.D* %d, i64 0, i32 1, !dbg !49
  %1 = load i32* %c2, align 4, !dbg !49
  %c23 = getelementptr inbounds %class.D* %this, i64 0, i32 1, !dbg !49
  store i32 %1, i32* %c23, align 4, !dbg !49
  %c3 = getelementptr inbounds %class.D* %d, i64 0, i32 2, !dbg !50
  %2 = load i32* %c3, align 4, !dbg !50
  %c34 = getelementptr inbounds %class.D* %this, i64 0, i32 2, !dbg !50
  store i32 %2, i32* %c34, align 4, !dbg !50
  %c4 = getelementptr inbounds %class.D* %d, i64 0, i32 3, !dbg !51
  %3 = load i32* %c4, align 4, !dbg !51
  %c45 = getelementptr inbounds %class.D* %this, i64 0, i32 3, !dbg !51
  store i32 %3, i32* %c45, align 4, !dbg !51
  ret void, !dbg !52
}

declare void @llvm.dbg.value(metadata, i64, metadata, metadata) nounwind readnone

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!54}

!0 = metadata !{metadata !"0x11\004\00clang version 3.2 (trunk 167506) (llvm/trunk 167505)\001\00\000\00\000", metadata !53, metadata !1, metadata !1, metadata !3, metadata !1,  metadata !1} ; [ DW_TAG_compile_unit ] [/usr/local/google/home/echristo/foo.cpp] [DW_LANG_C_plus_plus]
!1 = metadata !{}
!3 = metadata !{metadata !5, metadata !31}
!5 = metadata !{metadata !"0x2e\00D\00D\00_ZN1DC2Ev\0012\000\001\000\006\00256\001\0012", metadata !6, null, metadata !7, null, void (%class.D*)* @_ZN1DC2Ev, null, metadata !17, metadata !27} ; [ DW_TAG_subprogram ] [line 12] [def] [D]
!6 = metadata !{metadata !"0x29", metadata !53} ; [ DW_TAG_file_type ]
!7 = metadata !{metadata !"0x15\00\000\000\000\000\000\000", i32 0, null, null, metadata !8, null, null, null} ; [ DW_TAG_subroutine_type ] [line 0, size 0, align 0, offset 0] [from ]
!8 = metadata !{null, metadata !9}
!9 = metadata !{metadata !"0xf\00\000\0064\0064\000\001088", i32 0, null, metadata !10} ; [ DW_TAG_pointer_type ] [line 0, size 64, align 64, offset 0] [from D]
!10 = metadata !{metadata !"0x2\00D\001\00128\0032\000\000\000", metadata !53, null, null, metadata !11, null, null, null} ; [ DW_TAG_class_type ] [D] [line 1, size 128, align 32, offset 0] [def] [from ]
!11 = metadata !{metadata !12, metadata !14, metadata !15, metadata !16, metadata !17, metadata !20}
!12 = metadata !{metadata !"0xd\00c1\006\0032\0032\000\001", metadata !53, metadata !10, metadata !13} ; [ DW_TAG_member ] [c1] [line 6, size 32, align 32, offset 0] [private] [from int]
!13 = metadata !{metadata !"0x24\00int\000\0032\0032\000\000\005", null, null} ; [ DW_TAG_base_type ] [int] [line 0, size 32, align 32, offset 0, enc DW_ATE_signed]
!14 = metadata !{metadata !"0xd\00c2\007\0032\0032\0032\001", metadata !53, metadata !10, metadata !13} ; [ DW_TAG_member ] [c2] [line 7, size 32, align 32, offset 32] [private] [from int]
!15 = metadata !{metadata !"0xd\00c3\008\0032\0032\0064\001", metadata !53, metadata !10, metadata !13} ; [ DW_TAG_member ] [c3] [line 8, size 32, align 32, offset 64] [private] [from int]
!16 = metadata !{metadata !"0xd\00c4\009\0032\0032\0096\001", metadata !53, metadata !10, metadata !13} ; [ DW_TAG_member ] [c4] [line 9, size 32, align 32, offset 96] [private] [from int]
!17 = metadata !{metadata !"0x2e\00D\00D\00\003\000\000\000\006\00256\001\003", metadata !6, metadata !10, metadata !7, null, null, null, i32 0, metadata !18} ; [ DW_TAG_subprogram ] [line 3] [D]
!18 = metadata !{metadata !19}
!19 = metadata !{metadata !"0x24"}                      ; [ DW_TAG_base_type ] [line 0, size 0, align 0, offset 0]
!20 = metadata !{metadata !"0x2e\00D\00D\00\004\000\000\000\006\00256\001\004", metadata !6, metadata !10, metadata !21, null, null, null, i32 0, metadata !25} ; [ DW_TAG_subprogram ] [line 4] [D]
!21 = metadata !{metadata !"0x15\00\000\000\000\000\000\000", i32 0, null, null, metadata !22, null, null, null} ; [ DW_TAG_subroutine_type ] [line 0, size 0, align 0, offset 0] [from ]
!22 = metadata !{null, metadata !9, metadata !23}
!23 = metadata !{metadata !"0x10\00\000\000\000\000\000", null, null, metadata !24} ; [ DW_TAG_reference_type ] [line 0, size 0, align 0, offset 0] [from ]
!24 = metadata !{metadata !"0x26\00\000\000\000\000\000", null, null, metadata !10} ; [ DW_TAG_const_type ] [line 0, size 0, align 0, offset 0] [from D]
!25 = metadata !{metadata !26}
!26 = metadata !{metadata !"0x24"}                      ; [ DW_TAG_base_type ] [line 0, size 0, align 0, offset 0]
!27 = metadata !{metadata !29}
!29 = metadata !{metadata !"0x101\00this\0016777228\001088", metadata !5, metadata !6, metadata !30} ; [ DW_TAG_arg_variable ] [this] [line 12]
!30 = metadata !{metadata !"0xf\00\000\0064\0064\000\000", null, null, metadata !10} ; [ DW_TAG_pointer_type ] [line 0, size 64, align 64, offset 0] [from D]
!31 = metadata !{metadata !"0x2e\00D\00D\00_ZN1DC2ERKS_\0019\000\001\000\006\00256\001\0019", metadata !6, null, metadata !21, null, void (%class.D*, %class.D*)* @_ZN1DC2ERKS_, null, metadata !20, metadata !32} ; [ DW_TAG_subprogram ] [line 19] [def] [D]
!32 = metadata !{metadata !34, metadata !35}
!34 = metadata !{metadata !"0x101\00this\0016777235\001088", metadata !31, metadata !6, metadata !30} ; [ DW_TAG_arg_variable ] [this] [line 19]
!35 = metadata !{metadata !"0x101\00d\0033554451\000", metadata !31, metadata !6, metadata !23} ; [ DW_TAG_arg_variable ] [d] [line 19]
!36 = metadata !{i32 12, i32 0, metadata !5, null}
!37 = metadata !{i32 13, i32 0, metadata !38, null}
!38 = metadata !{metadata !"0xb\0012\000\000", metadata !6, metadata !5} ; [ DW_TAG_lexical_block ] [/usr/local/google/home/echristo/foo.cpp]
!42 = metadata !{i32 14, i32 0, metadata !38, null}
!43 = metadata !{i32 15, i32 0, metadata !38, null}
!44 = metadata !{i32 16, i32 0, metadata !38, null}
!45 = metadata !{i32 17, i32 0, metadata !38, null}
!46 = metadata !{i32 19, i32 0, metadata !31, null}
!47 = metadata !{i32 20, i32 0, metadata !48, null}
!48 = metadata !{metadata !"0xb\0019\000\001", metadata !6, metadata !31} ; [ DW_TAG_lexical_block ] [/usr/local/google/home/echristo/foo.cpp]
!49 = metadata !{i32 21, i32 0, metadata !48, null}
!50 = metadata !{i32 22, i32 0, metadata !48, null}
!51 = metadata !{i32 23, i32 0, metadata !48, null}
!52 = metadata !{i32 24, i32 0, metadata !48, null}
!53 = metadata !{metadata !"foo.cpp", metadata !"/usr/local/google/home/echristo"}
!54 = metadata !{i32 1, metadata !"Debug Info Version", i32 2}
