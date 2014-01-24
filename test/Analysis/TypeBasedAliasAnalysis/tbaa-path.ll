; RUN: opt < %s -tbaa -basicaa -aa-eval -evaluate-tbaa -print-no-aliases -print-may-aliases -disable-output 2>&1 | FileCheck %s
; RUN: opt < %s -tbaa -basicaa -gvn -S | FileCheck %s --check-prefix=OPT
; Generated from clang/test/CodeGen/tbaa.cpp with "-O1 -struct-path-tbaa -disable-llvm-optzns".

%struct.StructA = type { i16, i32, i16, i32 }
%struct.StructB = type { i16, %struct.StructA, i32 }
%struct.StructS = type { i16, i32 }
%struct.StructS2 = type { i16, i32 }
%struct.StructC = type { i16, %struct.StructB, i32 }
%struct.StructD = type { i16, %struct.StructB, i32, i8 }

define i32 @_Z1gPjP7StructAy(i32* %s, %struct.StructA* %A, i64 %count) #0 {
entry:
; Access to i32* and &(A->f32).
; CHECK: Function
; CHECK: MayAlias:   store i32 4, i32* %f32, align 4, !tbaa !8 <->   store i32 1, i32* %0, align 4, !tbaa !6
; OPT: define
; OPT: store i32 1
; OPT: store i32 4
; OPT: %[[RET:.*]] = load i32*
; OPT: ret i32 %[[RET]]
  %s.addr = alloca i32*, align 8
  %A.addr = alloca %struct.StructA*, align 8
  %count.addr = alloca i64, align 8
  store i32* %s, i32** %s.addr, align 8, !tbaa !0
  store %struct.StructA* %A, %struct.StructA** %A.addr, align 8, !tbaa !0
  store i64 %count, i64* %count.addr, align 8, !tbaa !4
  %0 = load i32** %s.addr, align 8, !tbaa !0
  store i32 1, i32* %0, align 4, !tbaa !6
  %1 = load %struct.StructA** %A.addr, align 8, !tbaa !0
  %f32 = getelementptr inbounds %struct.StructA* %1, i32 0, i32 1
  store i32 4, i32* %f32, align 4, !tbaa !8
  %2 = load i32** %s.addr, align 8, !tbaa !0
  %3 = load i32* %2, align 4, !tbaa !6
  ret i32 %3
}

define i32 @_Z2g2PjP7StructAy(i32* %s, %struct.StructA* %A, i64 %count) #0 {
entry:
; Access to i32* and &(A->f16).
; CHECK: Function
; CHECK: NoAlias:   store i16 4, i16* %f16, align 2, !tbaa !8 <->   store i32 1, i32* %0, align 4, !tbaa !6
; OPT: define
; OPT: store i32 1
; OPT: store i16 4
; Remove a load and propagate the value from store.
; OPT: ret i32 1
  %s.addr = alloca i32*, align 8
  %A.addr = alloca %struct.StructA*, align 8
  %count.addr = alloca i64, align 8
  store i32* %s, i32** %s.addr, align 8, !tbaa !0
  store %struct.StructA* %A, %struct.StructA** %A.addr, align 8, !tbaa !0
  store i64 %count, i64* %count.addr, align 8, !tbaa !4
  %0 = load i32** %s.addr, align 8, !tbaa !0
  store i32 1, i32* %0, align 4, !tbaa !6
  %1 = load %struct.StructA** %A.addr, align 8, !tbaa !0
  %f16 = getelementptr inbounds %struct.StructA* %1, i32 0, i32 0
  store i16 4, i16* %f16, align 2, !tbaa !11
  %2 = load i32** %s.addr, align 8, !tbaa !0
  %3 = load i32* %2, align 4, !tbaa !6
  ret i32 %3
}

define i32 @_Z2g3P7StructAP7StructBy(%struct.StructA* %A, %struct.StructB* %B, i64 %count) #0 {
entry:
; Access to &(A->f32) and &(B->a.f32).
; CHECK: Function
; CHECK: MayAlias:   store i32 4, i32* %f321, align 4, !tbaa !10 <->   store i32 1, i32* %f32, align 4, !tbaa !6
; OPT: define
; OPT: store i32 1
; OPT: store i32 4
; OPT: %[[RET:.*]] = load i32*
; OPT: ret i32 %[[RET]]
  %A.addr = alloca %struct.StructA*, align 8
  %B.addr = alloca %struct.StructB*, align 8
  %count.addr = alloca i64, align 8
  store %struct.StructA* %A, %struct.StructA** %A.addr, align 8, !tbaa !0
  store %struct.StructB* %B, %struct.StructB** %B.addr, align 8, !tbaa !0
  store i64 %count, i64* %count.addr, align 8, !tbaa !4
  %0 = load %struct.StructA** %A.addr, align 8, !tbaa !0
  %f32 = getelementptr inbounds %struct.StructA* %0, i32 0, i32 1
  store i32 1, i32* %f32, align 4, !tbaa !8
  %1 = load %struct.StructB** %B.addr, align 8, !tbaa !0
  %a = getelementptr inbounds %struct.StructB* %1, i32 0, i32 1
  %f321 = getelementptr inbounds %struct.StructA* %a, i32 0, i32 1
  store i32 4, i32* %f321, align 4, !tbaa !12
  %2 = load %struct.StructA** %A.addr, align 8, !tbaa !0
  %f322 = getelementptr inbounds %struct.StructA* %2, i32 0, i32 1
  %3 = load i32* %f322, align 4, !tbaa !8
  ret i32 %3
}

define i32 @_Z2g4P7StructAP7StructBy(%struct.StructA* %A, %struct.StructB* %B, i64 %count) #0 {
entry:
; Access to &(A->f32) and &(B->a.f16).
; CHECK: Function
; CHECK: NoAlias:   store i16 4, i16* %f16, align 2, !tbaa !10 <->   store i32 1, i32* %f32, align 4, !tbaa !6
; OPT: define
; OPT: store i32 1
; OPT: store i16 4
; Remove a load and propagate the value from store.
; OPT: ret i32 1
  %A.addr = alloca %struct.StructA*, align 8
  %B.addr = alloca %struct.StructB*, align 8
  %count.addr = alloca i64, align 8
  store %struct.StructA* %A, %struct.StructA** %A.addr, align 8, !tbaa !0
  store %struct.StructB* %B, %struct.StructB** %B.addr, align 8, !tbaa !0
  store i64 %count, i64* %count.addr, align 8, !tbaa !4
  %0 = load %struct.StructA** %A.addr, align 8, !tbaa !0
  %f32 = getelementptr inbounds %struct.StructA* %0, i32 0, i32 1
  store i32 1, i32* %f32, align 4, !tbaa !8
  %1 = load %struct.StructB** %B.addr, align 8, !tbaa !0
  %a = getelementptr inbounds %struct.StructB* %1, i32 0, i32 1
  %f16 = getelementptr inbounds %struct.StructA* %a, i32 0, i32 0
  store i16 4, i16* %f16, align 2, !tbaa !14
  %2 = load %struct.StructA** %A.addr, align 8, !tbaa !0
  %f321 = getelementptr inbounds %struct.StructA* %2, i32 0, i32 1
  %3 = load i32* %f321, align 4, !tbaa !8
  ret i32 %3
}

define i32 @_Z2g5P7StructAP7StructBy(%struct.StructA* %A, %struct.StructB* %B, i64 %count) #0 {
entry:
; Access to &(A->f32) and &(B->f32).
; CHECK: Function
; CHECK: NoAlias:   store i32 4, i32* %f321, align 4, !tbaa !10 <->   store i32 1, i32* %f32, align 4, !tbaa !6
; OPT: define
; OPT: store i32 1
; OPT: store i32 4
; Remove a load and propagate the value from store.
; OPT: ret i32 1
  %A.addr = alloca %struct.StructA*, align 8
  %B.addr = alloca %struct.StructB*, align 8
  %count.addr = alloca i64, align 8
  store %struct.StructA* %A, %struct.StructA** %A.addr, align 8, !tbaa !0
  store %struct.StructB* %B, %struct.StructB** %B.addr, align 8, !tbaa !0
  store i64 %count, i64* %count.addr, align 8, !tbaa !4
  %0 = load %struct.StructA** %A.addr, align 8, !tbaa !0
  %f32 = getelementptr inbounds %struct.StructA* %0, i32 0, i32 1
  store i32 1, i32* %f32, align 4, !tbaa !8
  %1 = load %struct.StructB** %B.addr, align 8, !tbaa !0
  %f321 = getelementptr inbounds %struct.StructB* %1, i32 0, i32 2
  store i32 4, i32* %f321, align 4, !tbaa !15
  %2 = load %struct.StructA** %A.addr, align 8, !tbaa !0
  %f322 = getelementptr inbounds %struct.StructA* %2, i32 0, i32 1
  %3 = load i32* %f322, align 4, !tbaa !8
  ret i32 %3
}

define i32 @_Z2g6P7StructAP7StructBy(%struct.StructA* %A, %struct.StructB* %B, i64 %count) #0 {
entry:
; Access to &(A->f32) and &(B->a.f32_2).
; CHECK: Function
; CHECK: NoAlias:   store i32 4, i32* %f32_2, align 4, !tbaa !10 <->   store i32 1, i32* %f32, align 4, !tbaa !6
; OPT: define
; OPT: store i32 1
; OPT: store i32 4
; Remove a load and propagate the value from store.
; OPT: ret i32 1
  %A.addr = alloca %struct.StructA*, align 8
  %B.addr = alloca %struct.StructB*, align 8
  %count.addr = alloca i64, align 8
  store %struct.StructA* %A, %struct.StructA** %A.addr, align 8, !tbaa !0
  store %struct.StructB* %B, %struct.StructB** %B.addr, align 8, !tbaa !0
  store i64 %count, i64* %count.addr, align 8, !tbaa !4
  %0 = load %struct.StructA** %A.addr, align 8, !tbaa !0
  %f32 = getelementptr inbounds %struct.StructA* %0, i32 0, i32 1
  store i32 1, i32* %f32, align 4, !tbaa !8
  %1 = load %struct.StructB** %B.addr, align 8, !tbaa !0
  %a = getelementptr inbounds %struct.StructB* %1, i32 0, i32 1
  %f32_2 = getelementptr inbounds %struct.StructA* %a, i32 0, i32 3
  store i32 4, i32* %f32_2, align 4, !tbaa !16
  %2 = load %struct.StructA** %A.addr, align 8, !tbaa !0
  %f321 = getelementptr inbounds %struct.StructA* %2, i32 0, i32 1
  %3 = load i32* %f321, align 4, !tbaa !8
  ret i32 %3
}

define i32 @_Z2g7P7StructAP7StructSy(%struct.StructA* %A, %struct.StructS* %S, i64 %count) #0 {
entry:
; Access to &(A->f32) and &(S->f32).
; CHECK: Function
; CHECK: NoAlias:   store i32 4, i32* %f321, align 4, !tbaa !10 <->   store i32 1, i32* %f32, align 4, !tbaa !6
; OPT: define
; OPT: store i32 1
; OPT: store i32 4
; Remove a load and propagate the value from store.
; OPT: ret i32 1
  %A.addr = alloca %struct.StructA*, align 8
  %S.addr = alloca %struct.StructS*, align 8
  %count.addr = alloca i64, align 8
  store %struct.StructA* %A, %struct.StructA** %A.addr, align 8, !tbaa !0
  store %struct.StructS* %S, %struct.StructS** %S.addr, align 8, !tbaa !0
  store i64 %count, i64* %count.addr, align 8, !tbaa !4
  %0 = load %struct.StructA** %A.addr, align 8, !tbaa !0
  %f32 = getelementptr inbounds %struct.StructA* %0, i32 0, i32 1
  store i32 1, i32* %f32, align 4, !tbaa !8
  %1 = load %struct.StructS** %S.addr, align 8, !tbaa !0
  %f321 = getelementptr inbounds %struct.StructS* %1, i32 0, i32 1
  store i32 4, i32* %f321, align 4, !tbaa !17
  %2 = load %struct.StructA** %A.addr, align 8, !tbaa !0
  %f322 = getelementptr inbounds %struct.StructA* %2, i32 0, i32 1
  %3 = load i32* %f322, align 4, !tbaa !8
  ret i32 %3
}

define i32 @_Z2g8P7StructAP7StructSy(%struct.StructA* %A, %struct.StructS* %S, i64 %count) #0 {
entry:
; Access to &(A->f32) and &(S->f16).
; CHECK: Function
; CHECK: NoAlias:   store i16 4, i16* %f16, align 2, !tbaa !10 <->   store i32 1, i32* %f32, align 4, !tbaa !6
; OPT: define
; OPT: store i32 1
; OPT: store i16 4
; Remove a load and propagate the value from store.
; OPT: ret i32 1
  %A.addr = alloca %struct.StructA*, align 8
  %S.addr = alloca %struct.StructS*, align 8
  %count.addr = alloca i64, align 8
  store %struct.StructA* %A, %struct.StructA** %A.addr, align 8, !tbaa !0
  store %struct.StructS* %S, %struct.StructS** %S.addr, align 8, !tbaa !0
  store i64 %count, i64* %count.addr, align 8, !tbaa !4
  %0 = load %struct.StructA** %A.addr, align 8, !tbaa !0
  %f32 = getelementptr inbounds %struct.StructA* %0, i32 0, i32 1
  store i32 1, i32* %f32, align 4, !tbaa !8
  %1 = load %struct.StructS** %S.addr, align 8, !tbaa !0
  %f16 = getelementptr inbounds %struct.StructS* %1, i32 0, i32 0
  store i16 4, i16* %f16, align 2, !tbaa !19
  %2 = load %struct.StructA** %A.addr, align 8, !tbaa !0
  %f321 = getelementptr inbounds %struct.StructA* %2, i32 0, i32 1
  %3 = load i32* %f321, align 4, !tbaa !8
  ret i32 %3
}

define i32 @_Z2g9P7StructSP8StructS2y(%struct.StructS* %S, %struct.StructS2* %S2, i64 %count) #0 {
entry:
; Access to &(S->f32) and &(S2->f32).
; CHECK: Function
; CHECK: NoAlias:   store i32 4, i32* %f321, align 4, !tbaa !10 <->   store i32 1, i32* %f32, align 4, !tbaa !6
; OPT: define
; OPT: store i32 1
; OPT: store i32 4
; Remove a load and propagate the value from store.
; OPT: ret i32 1
  %S.addr = alloca %struct.StructS*, align 8
  %S2.addr = alloca %struct.StructS2*, align 8
  %count.addr = alloca i64, align 8
  store %struct.StructS* %S, %struct.StructS** %S.addr, align 8, !tbaa !0
  store %struct.StructS2* %S2, %struct.StructS2** %S2.addr, align 8, !tbaa !0
  store i64 %count, i64* %count.addr, align 8, !tbaa !4
  %0 = load %struct.StructS** %S.addr, align 8, !tbaa !0
  %f32 = getelementptr inbounds %struct.StructS* %0, i32 0, i32 1
  store i32 1, i32* %f32, align 4, !tbaa !17
  %1 = load %struct.StructS2** %S2.addr, align 8, !tbaa !0
  %f321 = getelementptr inbounds %struct.StructS2* %1, i32 0, i32 1
  store i32 4, i32* %f321, align 4, !tbaa !20
  %2 = load %struct.StructS** %S.addr, align 8, !tbaa !0
  %f322 = getelementptr inbounds %struct.StructS* %2, i32 0, i32 1
  %3 = load i32* %f322, align 4, !tbaa !17
  ret i32 %3
}

define i32 @_Z3g10P7StructSP8StructS2y(%struct.StructS* %S, %struct.StructS2* %S2, i64 %count) #0 {
entry:
; Access to &(S->f32) and &(S2->f16).
; CHECK: Function
; CHECK: NoAlias:   store i16 4, i16* %f16, align 2, !tbaa !10 <->   store i32 1, i32* %f32, align 4, !tbaa !6
; OPT: define
; OPT: store i32 1
; OPT: store i16 4
; Remove a load and propagate the value from store.
; OPT: ret i32 1
  %S.addr = alloca %struct.StructS*, align 8
  %S2.addr = alloca %struct.StructS2*, align 8
  %count.addr = alloca i64, align 8
  store %struct.StructS* %S, %struct.StructS** %S.addr, align 8, !tbaa !0
  store %struct.StructS2* %S2, %struct.StructS2** %S2.addr, align 8, !tbaa !0
  store i64 %count, i64* %count.addr, align 8, !tbaa !4
  %0 = load %struct.StructS** %S.addr, align 8, !tbaa !0
  %f32 = getelementptr inbounds %struct.StructS* %0, i32 0, i32 1
  store i32 1, i32* %f32, align 4, !tbaa !17
  %1 = load %struct.StructS2** %S2.addr, align 8, !tbaa !0
  %f16 = getelementptr inbounds %struct.StructS2* %1, i32 0, i32 0
  store i16 4, i16* %f16, align 2, !tbaa !22
  %2 = load %struct.StructS** %S.addr, align 8, !tbaa !0
  %f321 = getelementptr inbounds %struct.StructS* %2, i32 0, i32 1
  %3 = load i32* %f321, align 4, !tbaa !17
  ret i32 %3
}

define i32 @_Z3g11P7StructCP7StructDy(%struct.StructC* %C, %struct.StructD* %D, i64 %count) #0 {
entry:
; Access to &(C->b.a.f32) and &(D->b.a.f32).
; CHECK: Function
; CHECK: NoAlias:   store i32 4, i32* %f323, align 4, !tbaa !12 <->   store i32 1, i32* %f32, align 4, !tbaa !6
; OPT: define
; OPT: store i32 1
; OPT: store i32 4
; Remove a load and propagate the value from store.
; OPT: ret i32 1
  %C.addr = alloca %struct.StructC*, align 8
  %D.addr = alloca %struct.StructD*, align 8
  %count.addr = alloca i64, align 8
  store %struct.StructC* %C, %struct.StructC** %C.addr, align 8, !tbaa !0
  store %struct.StructD* %D, %struct.StructD** %D.addr, align 8, !tbaa !0
  store i64 %count, i64* %count.addr, align 8, !tbaa !4
  %0 = load %struct.StructC** %C.addr, align 8, !tbaa !0
  %b = getelementptr inbounds %struct.StructC* %0, i32 0, i32 1
  %a = getelementptr inbounds %struct.StructB* %b, i32 0, i32 1
  %f32 = getelementptr inbounds %struct.StructA* %a, i32 0, i32 1
  store i32 1, i32* %f32, align 4, !tbaa !23
  %1 = load %struct.StructD** %D.addr, align 8, !tbaa !0
  %b1 = getelementptr inbounds %struct.StructD* %1, i32 0, i32 1
  %a2 = getelementptr inbounds %struct.StructB* %b1, i32 0, i32 1
  %f323 = getelementptr inbounds %struct.StructA* %a2, i32 0, i32 1
  store i32 4, i32* %f323, align 4, !tbaa !25
  %2 = load %struct.StructC** %C.addr, align 8, !tbaa !0
  %b4 = getelementptr inbounds %struct.StructC* %2, i32 0, i32 1
  %a5 = getelementptr inbounds %struct.StructB* %b4, i32 0, i32 1
  %f326 = getelementptr inbounds %struct.StructA* %a5, i32 0, i32 1
  %3 = load i32* %f326, align 4, !tbaa !23
  ret i32 %3
}

define i32 @_Z3g12P7StructCP7StructDy(%struct.StructC* %C, %struct.StructD* %D, i64 %count) #0 {
entry:
; Access to &(b1->a.f32) and &(b2->a.f32).
; CHECK: Function
; CHECK: MayAlias:   store i32 4, i32* %f325, align 4, !tbaa !6 <->   store i32 1, i32* %f32, align 4, !tbaa !6
; OPT: define
; OPT: store i32 1
; OPT: store i32 4
; OPT: %[[RET:.*]] = load i32*
; OPT: ret i32 %[[RET]]
  %C.addr = alloca %struct.StructC*, align 8
  %D.addr = alloca %struct.StructD*, align 8
  %count.addr = alloca i64, align 8
  %b1 = alloca %struct.StructB*, align 8
  %b2 = alloca %struct.StructB*, align 8
  store %struct.StructC* %C, %struct.StructC** %C.addr, align 8, !tbaa !0
  store %struct.StructD* %D, %struct.StructD** %D.addr, align 8, !tbaa !0
  store i64 %count, i64* %count.addr, align 8, !tbaa !4
  %0 = load %struct.StructC** %C.addr, align 8, !tbaa !0
  %b = getelementptr inbounds %struct.StructC* %0, i32 0, i32 1
  store %struct.StructB* %b, %struct.StructB** %b1, align 8, !tbaa !0
  %1 = load %struct.StructD** %D.addr, align 8, !tbaa !0
  %b3 = getelementptr inbounds %struct.StructD* %1, i32 0, i32 1
  store %struct.StructB* %b3, %struct.StructB** %b2, align 8, !tbaa !0
  %2 = load %struct.StructB** %b1, align 8, !tbaa !0
  %a = getelementptr inbounds %struct.StructB* %2, i32 0, i32 1
  %f32 = getelementptr inbounds %struct.StructA* %a, i32 0, i32 1
  store i32 1, i32* %f32, align 4, !tbaa !12
  %3 = load %struct.StructB** %b2, align 8, !tbaa !0
  %a4 = getelementptr inbounds %struct.StructB* %3, i32 0, i32 1
  %f325 = getelementptr inbounds %struct.StructA* %a4, i32 0, i32 1
  store i32 4, i32* %f325, align 4, !tbaa !12
  %4 = load %struct.StructB** %b1, align 8, !tbaa !0
  %a6 = getelementptr inbounds %struct.StructB* %4, i32 0, i32 1
  %f327 = getelementptr inbounds %struct.StructA* %a6, i32 0, i32 1
  %5 = load i32* %f327, align 4, !tbaa !12
  ret i32 %5
}

attributes #0 = { nounwind "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-frame-pointer-elim-non-leaf"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }

!0 = metadata !{metadata !1, metadata !1, i64 0}
!1 = metadata !{metadata !"any pointer", metadata !2}
!2 = metadata !{metadata !"omnipotent char", metadata !3}
!3 = metadata !{metadata !"Simple C/C++ TBAA"}
!4 = metadata !{metadata !5, metadata !5, i64 0}
!5 = metadata !{metadata !"long long", metadata !2}
!6 = metadata !{metadata !7, metadata !7, i64 0}
!7 = metadata !{metadata !"int", metadata !2}
!8 = metadata !{metadata !9, metadata !7, i64 4}
!9 = metadata !{metadata !"_ZTS7StructA", metadata !10, i64 0, metadata !7, i64 4, metadata !10, i64 8, metadata !7, i64 12}
!10 = metadata !{metadata !"short", metadata !2}
!11 = metadata !{metadata !9, metadata !10, i64 0}
!12 = metadata !{metadata !13, metadata !7, i64 8}
!13 = metadata !{metadata !"_ZTS7StructB", metadata !10, i64 0, metadata !9, i64 4, metadata !7, i64 20}
!14 = metadata !{metadata !13, metadata !10, i64 4}
!15 = metadata !{metadata !13, metadata !7, i64 20}
!16 = metadata !{metadata !13, metadata !7, i64 16}
!17 = metadata !{metadata !18, metadata !7, i64 4}
!18 = metadata !{metadata !"_ZTS7StructS", metadata !10, i64 0, metadata !7, i64 4}
!19 = metadata !{metadata !18, metadata !10, i64 0}
!20 = metadata !{metadata !21, metadata !7, i64 4}
!21 = metadata !{metadata !"_ZTS8StructS2", metadata !10, i64 0, metadata !7, i64 4}
!22 = metadata !{metadata !21, metadata !10, i64 0}
!23 = metadata !{metadata !24, metadata !7, i64 12}
!24 = metadata !{metadata !"_ZTS7StructC", metadata !10, i64 0, metadata !13, i64 4, metadata !7, i64 28}
!25 = metadata !{metadata !26, metadata !7, i64 12}
!26 = metadata !{metadata !"_ZTS7StructD", metadata !10, i64 0, metadata !13, i64 4, metadata !7, i64 28, metadata !2, i64 32}
