; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -simplifycfg -S < %s | FileCheck %s --check-prefixes=ALL,SIMPLIFYCFG
; RUN: opt -instcombine -S < %s | FileCheck %s --check-prefixes=ALL,INSTCOMBINE,INSTCOMBINEONLY
; RUN: opt -instcombine -simplifycfg -S < %s | FileCheck %s --check-prefixes=ALL,INSTCOMBINE,INSTCOMBINESIMPLIFYCFG,INSTCOMBINESIMPLIFYCFGDEFAULT,INSTCOMBINESIMPLIFYCFGONLY
; RUN: opt -instcombine -simplifycfg -instcombine -S < %s | FileCheck %s --check-prefixes=ALL,INSTCOMBINE,INSTCOMBINESIMPLIFYCFG,INSTCOMBINESIMPLIFYCFGDEFAULT,INSTCOMBINESIMPLIFYCFGINSTCOMBINE
; RUN: opt -instcombine -simplifycfg -phi-node-folding-threshold=3 -S < %s | FileCheck %s --check-prefixes=ALL,INSTCOMBINE,INSTCOMBINESIMPLIFYCFG,INSTCOMBINESIMPLIFYCFGCOSTLY,INSTCOMBINESIMPLIFYCFGCOSTLYONLY
; RUN: opt -instcombine -simplifycfg -instcombine -phi-node-folding-threshold=3 -S < %s | FileCheck %s --check-prefixes=ALL,INSTCOMBINE,INSTCOMBINESIMPLIFYCFG,INSTCOMBINESIMPLIFYCFGCOSTLY,INSTCOMBINESIMPLIFYCFGCOSTLYINSTCOMBINE

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; #include <limits>
; #include <cstdint>
;
; using size_type = std::size_t;
; bool will_not_overflow(size_type size, size_type nmemb) {
;   return (size != 0 && (nmemb > std::numeric_limits<size_type>::max() / size));
; }

define i1 @will_not_overflow(i64 %arg, i64 %arg1) {
; SIMPLIFYCFG-LABEL: @will_not_overflow(
; SIMPLIFYCFG-NEXT:  bb:
; SIMPLIFYCFG-NEXT:    [[T0:%.*]] = icmp eq i64 [[ARG:%.*]], 0
; SIMPLIFYCFG-NEXT:    br i1 [[T0]], label [[BB5:%.*]], label [[BB2:%.*]]
; SIMPLIFYCFG:       bb2:
; SIMPLIFYCFG-NEXT:    [[T3:%.*]] = udiv i64 -1, [[ARG]]
; SIMPLIFYCFG-NEXT:    [[T4:%.*]] = icmp ult i64 [[T3]], [[ARG1:%.*]]
; SIMPLIFYCFG-NEXT:    br label [[BB5]]
; SIMPLIFYCFG:       bb5:
; SIMPLIFYCFG-NEXT:    [[T6:%.*]] = phi i1 [ false, [[BB:%.*]] ], [ [[T4]], [[BB2]] ]
; SIMPLIFYCFG-NEXT:    ret i1 [[T6]]
;
; INSTCOMBINEONLY-LABEL: @will_not_overflow(
; INSTCOMBINEONLY-NEXT:  bb:
; INSTCOMBINEONLY-NEXT:    [[T0:%.*]] = icmp eq i64 [[ARG:%.*]], 0
; INSTCOMBINEONLY-NEXT:    br i1 [[T0]], label [[BB5:%.*]], label [[BB2:%.*]]
; INSTCOMBINEONLY:       bb2:
; INSTCOMBINEONLY-NEXT:    [[UMUL:%.*]] = call { i64, i1 } @llvm.umul.with.overflow.i64(i64 [[ARG]], i64 [[ARG1:%.*]])
; INSTCOMBINEONLY-NEXT:    [[UMUL_OV:%.*]] = extractvalue { i64, i1 } [[UMUL]], 1
; INSTCOMBINEONLY-NEXT:    br label [[BB5]]
; INSTCOMBINEONLY:       bb5:
; INSTCOMBINEONLY-NEXT:    [[T6:%.*]] = phi i1 [ false, [[BB:%.*]] ], [ [[UMUL_OV]], [[BB2]] ]
; INSTCOMBINEONLY-NEXT:    ret i1 [[T6]]
;
; INSTCOMBINESIMPLIFYCFGONLY-LABEL: @will_not_overflow(
; INSTCOMBINESIMPLIFYCFGONLY-NEXT:  bb:
; INSTCOMBINESIMPLIFYCFGONLY-NEXT:    [[T0:%.*]] = icmp eq i64 [[ARG:%.*]], 0
; INSTCOMBINESIMPLIFYCFGONLY-NEXT:    [[UMUL:%.*]] = call { i64, i1 } @llvm.umul.with.overflow.i64(i64 [[ARG]], i64 [[ARG1:%.*]])
; INSTCOMBINESIMPLIFYCFGONLY-NEXT:    [[UMUL_OV:%.*]] = extractvalue { i64, i1 } [[UMUL]], 1
; INSTCOMBINESIMPLIFYCFGONLY-NEXT:    [[T6:%.*]] = select i1 [[T0]], i1 false, i1 [[UMUL_OV]]
; INSTCOMBINESIMPLIFYCFGONLY-NEXT:    ret i1 [[T6]]
;
; INSTCOMBINESIMPLIFYCFGINSTCOMBINE-LABEL: @will_not_overflow(
; INSTCOMBINESIMPLIFYCFGINSTCOMBINE-NEXT:  bb:
; INSTCOMBINESIMPLIFYCFGINSTCOMBINE-NEXT:    [[T0:%.*]] = icmp ne i64 [[ARG:%.*]], 0
; INSTCOMBINESIMPLIFYCFGINSTCOMBINE-NEXT:    [[UMUL:%.*]] = call { i64, i1 } @llvm.umul.with.overflow.i64(i64 [[ARG]], i64 [[ARG1:%.*]])
; INSTCOMBINESIMPLIFYCFGINSTCOMBINE-NEXT:    [[UMUL_OV:%.*]] = extractvalue { i64, i1 } [[UMUL]], 1
; INSTCOMBINESIMPLIFYCFGINSTCOMBINE-NEXT:    [[T6:%.*]] = and i1 [[UMUL_OV]], [[T0]]
; INSTCOMBINESIMPLIFYCFGINSTCOMBINE-NEXT:    ret i1 [[T6]]
;
; INSTCOMBINESIMPLIFYCFGCOSTLYONLY-LABEL: @will_not_overflow(
; INSTCOMBINESIMPLIFYCFGCOSTLYONLY-NEXT:  bb:
; INSTCOMBINESIMPLIFYCFGCOSTLYONLY-NEXT:    [[T0:%.*]] = icmp eq i64 [[ARG:%.*]], 0
; INSTCOMBINESIMPLIFYCFGCOSTLYONLY-NEXT:    [[UMUL:%.*]] = call { i64, i1 } @llvm.umul.with.overflow.i64(i64 [[ARG]], i64 [[ARG1:%.*]])
; INSTCOMBINESIMPLIFYCFGCOSTLYONLY-NEXT:    [[UMUL_OV:%.*]] = extractvalue { i64, i1 } [[UMUL]], 1
; INSTCOMBINESIMPLIFYCFGCOSTLYONLY-NEXT:    [[T6:%.*]] = select i1 [[T0]], i1 false, i1 [[UMUL_OV]]
; INSTCOMBINESIMPLIFYCFGCOSTLYONLY-NEXT:    ret i1 [[T6]]
;
; INSTCOMBINESIMPLIFYCFGCOSTLYINSTCOMBINE-LABEL: @will_not_overflow(
; INSTCOMBINESIMPLIFYCFGCOSTLYINSTCOMBINE-NEXT:  bb:
; INSTCOMBINESIMPLIFYCFGCOSTLYINSTCOMBINE-NEXT:    [[T0:%.*]] = icmp ne i64 [[ARG:%.*]], 0
; INSTCOMBINESIMPLIFYCFGCOSTLYINSTCOMBINE-NEXT:    [[UMUL:%.*]] = call { i64, i1 } @llvm.umul.with.overflow.i64(i64 [[ARG]], i64 [[ARG1:%.*]])
; INSTCOMBINESIMPLIFYCFGCOSTLYINSTCOMBINE-NEXT:    [[UMUL_OV:%.*]] = extractvalue { i64, i1 } [[UMUL]], 1
; INSTCOMBINESIMPLIFYCFGCOSTLYINSTCOMBINE-NEXT:    [[T6:%.*]] = and i1 [[UMUL_OV]], [[T0]]
; INSTCOMBINESIMPLIFYCFGCOSTLYINSTCOMBINE-NEXT:    ret i1 [[T6]]
;
bb:
  %t0 = icmp eq i64 %arg, 0
  br i1 %t0, label %bb5, label %bb2

bb2:                                              ; preds = %bb
  %t3 = udiv i64 -1, %arg
  %t4 = icmp ult i64 %t3, %arg1
  br label %bb5

bb5:                                              ; preds = %bb2, %bb
  %t6 = phi i1 [ false, %bb ], [ %t4, %bb2 ]
  ret i1 %t6
}

; Same as @will_not_overflow, but inverting return value.

define i1 @will_overflow(i64 %arg, i64 %arg1) {
; SIMPLIFYCFG-LABEL: @will_overflow(
; SIMPLIFYCFG-NEXT:  bb:
; SIMPLIFYCFG-NEXT:    [[T0:%.*]] = icmp eq i64 [[ARG:%.*]], 0
; SIMPLIFYCFG-NEXT:    br i1 [[T0]], label [[BB5:%.*]], label [[BB2:%.*]]
; SIMPLIFYCFG:       bb2:
; SIMPLIFYCFG-NEXT:    [[T3:%.*]] = udiv i64 -1, [[ARG]]
; SIMPLIFYCFG-NEXT:    [[T4:%.*]] = icmp ult i64 [[T3]], [[ARG1:%.*]]
; SIMPLIFYCFG-NEXT:    br label [[BB5]]
; SIMPLIFYCFG:       bb5:
; SIMPLIFYCFG-NEXT:    [[T6:%.*]] = phi i1 [ false, [[BB:%.*]] ], [ [[T4]], [[BB2]] ]
; SIMPLIFYCFG-NEXT:    [[T7:%.*]] = xor i1 [[T6]], true
; SIMPLIFYCFG-NEXT:    ret i1 [[T7]]
;
; INSTCOMBINE-LABEL: @will_overflow(
; INSTCOMBINE-NEXT:  bb:
; INSTCOMBINE-NEXT:    [[T0:%.*]] = icmp eq i64 [[ARG:%.*]], 0
; INSTCOMBINE-NEXT:    br i1 [[T0]], label [[BB5:%.*]], label [[BB2:%.*]]
; INSTCOMBINE:       bb2:
; INSTCOMBINE-NEXT:    [[UMUL:%.*]] = call { i64, i1 } @llvm.umul.with.overflow.i64(i64 [[ARG]], i64 [[ARG1:%.*]])
; INSTCOMBINE-NEXT:    [[UMUL_OV:%.*]] = extractvalue { i64, i1 } [[UMUL]], 1
; INSTCOMBINE-NEXT:    [[PHITMP:%.*]] = xor i1 [[UMUL_OV]], true
; INSTCOMBINE-NEXT:    br label [[BB5]]
; INSTCOMBINE:       bb5:
; INSTCOMBINE-NEXT:    [[T6:%.*]] = phi i1 [ true, [[BB:%.*]] ], [ [[PHITMP]], [[BB2]] ]
; INSTCOMBINE-NEXT:    ret i1 [[T6]]
;
bb:
  %t0 = icmp eq i64 %arg, 0
  br i1 %t0, label %bb5, label %bb2

bb2:                                              ; preds = %bb
  %t3 = udiv i64 -1, %arg
  %t4 = icmp ult i64 %t3, %arg1
  br label %bb5

bb5:                                              ; preds = %bb2, %bb
  %t6 = phi i1 [ false, %bb ], [ %t4, %bb2 ]
  %t7 = xor i1 %t6, true
  ret i1 %t7
}
