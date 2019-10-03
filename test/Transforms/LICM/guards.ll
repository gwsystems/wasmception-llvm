; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; REQUIRES: asserts
; RUN: opt -licm -basicaa -enable-mssa-loop-dependency=false -ipt-expensive-asserts=true < %s -S | FileCheck %s
; RUN: opt -licm -basicaa -enable-mssa-loop-dependency=true -ipt-expensive-asserts=true < %s -S | FileCheck %s --check-prefixes=CHECK,MSSA
; RUN: opt -aa-pipeline=basic-aa -passes='require<aa>,require<targetir>,require<scalar-evolution>,require<opt-remark-emit>,loop(licm)' -ipt-expensive-asserts=true < %s -S | FileCheck %s
; RUN: opt -aa-pipeline=basic-aa -passes='require<aa>,require<targetir>,require<scalar-evolution>,require<opt-remark-emit>,loop-mssa(licm)' -ipt-expensive-asserts=true < %s -S | FileCheck %s --check-prefixes=CHECK,MSSA

; Hoist guard and load.
define void @test1(i1 %cond, i32* %ptr) {
; CHECK-LABEL: @test1(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    call void (i1, ...) @llvm.experimental.guard(i1 [[COND:%.*]]) [ "deopt"(i32 0) ]
; CHECK-NEXT:    [[VAL:%.*]] = load i32, i32* [[PTR:%.*]]
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[X:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[X_INC:%.*]], [[LOOP]] ]
; CHECK-NEXT:    [[X_INC]] = add i32 [[X]], [[VAL]]
; CHECK-NEXT:    br label [[LOOP]]
;

entry:
  br label %loop

loop:
  %x = phi i32 [ 0, %entry ], [ %x.inc, %loop ]
  call void (i1, ...) @llvm.experimental.guard(i1 %cond) ["deopt" (i32 0)]
  %val = load i32, i32* %ptr
  %x.inc = add i32 %x, %val
  br label %loop
}

; Can't hoist over a side effect
define void @test2(i1 %cond, i32* %ptr) {
; CHECK-LABEL: @test2(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[X:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[X_INC:%.*]], [[LOOP]] ]
; CHECK-NEXT:    store i32 0, i32* [[PTR:%.*]]
; CHECK-NEXT:    call void (i1, ...) @llvm.experimental.guard(i1 [[COND:%.*]]) [ "deopt"(i32 0) ]
; CHECK-NEXT:    [[VAL:%.*]] = load i32, i32* [[PTR]]
; CHECK-NEXT:    [[X_INC]] = add i32 [[X]], [[VAL]]
; CHECK-NEXT:    br label [[LOOP]]
;

entry:
  br label %loop

loop:
  %x = phi i32 [ 0, %entry ], [ %x.inc, %loop ]
  store i32 0, i32* %ptr
  call void (i1, ...) @llvm.experimental.guard(i1 %cond) ["deopt" (i32 0)]
  %val = load i32, i32* %ptr
  %x.inc = add i32 %x, %val
  br label %loop
}

; Can't hoist over a side effect
define void @test2b(i1 %cond, i32* %ptr) {
; CHECK-LABEL: @test2b(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[P2:%.*]] = getelementptr i32, i32* [[PTR:%.*]], i32 1
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[X:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[X_INC:%.*]], [[LOOP]] ]
; CHECK-NEXT:    store i32 [[X]], i32* [[P2]]
; CHECK-NEXT:    call void (i1, ...) @llvm.experimental.guard(i1 [[COND:%.*]]) [ "deopt"(i32 0) ]
; CHECK-NEXT:    [[VAL:%.*]] = load i32, i32* [[PTR]]
; CHECK-NEXT:    [[X_INC]] = add i32 [[X]], [[VAL]]
; CHECK-NEXT:    br label [[LOOP]]
;

entry:
  br label %loop

loop:
  %x = phi i32 [ 0, %entry ], [ %x.inc, %loop ]
  %p2 = getelementptr i32, i32* %ptr, i32 1
  store i32 %x, i32* %p2
  call void (i1, ...) @llvm.experimental.guard(i1 %cond) ["deopt" (i32 0)]
  %val = load i32, i32* %ptr
  %x.inc = add i32 %x, %val
  br label %loop
}

; But can hoist if the side effect is hoisted with MSSA
define void @test2b_prime(i1 %cond, i32* noalias %ptr) {
; MSSA-LABEL: @test2b_prime(
; MSSA-NEXT:  entry:
; MSSA-NEXT:    [[P2:%.*]] = getelementptr i32, i32* [[PTR:%.*]], i32 1
; MSSA-NEXT:    store i32 0, i32* [[P2]]
; MSSA-NEXT:    call void (i1, ...) @llvm.experimental.guard(i1 [[COND:%.*]]) [ "deopt"(i32 0) ]
; MSSA-NEXT:    [[VAL:%.*]] = load i32, i32* [[PTR]]
; MSSA-NEXT:    br label [[LOOP:%.*]]
; MSSA:       loop:
; MSSA-NEXT:    [[X:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[X_INC:%.*]], [[LOOP]] ]
; MSSA-NEXT:    [[X_INC]] = add i32 [[X]], [[VAL]]
; MSSA-NEXT:    br label [[LOOP]]

entry:
  br label %loop

loop:
  %x = phi i32 [ 0, %entry ], [ %x.inc, %loop ]
  %p2 = getelementptr i32, i32* %ptr, i32 1
  store i32 0, i32* %p2
  call void (i1, ...) @llvm.experimental.guard(i1 %cond) ["deopt" (i32 0)]
  %val = load i32, i32* %ptr
  %x.inc = add i32 %x, %val
  br label %loop
}

; Hoist guard. Cannot hoist load because of aliasing.
define void @test3(i1 %cond, i32* %ptr) {
; CHECK-LABEL: @test3(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    call void (i1, ...) @llvm.experimental.guard(i1 [[COND:%.*]]) [ "deopt"(i32 0) ]
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[X:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[X_INC:%.*]], [[LOOP]] ]
; CHECK-NEXT:    [[VAL:%.*]] = load i32, i32* [[PTR:%.*]]
; CHECK-NEXT:    store i32 0, i32* [[PTR]]
; CHECK-NEXT:    [[X_INC]] = add i32 [[X]], [[VAL]]
; CHECK-NEXT:    br label [[LOOP]]
;

entry:
  br label %loop

loop:
  %x = phi i32 [ 0, %entry ], [ %x.inc, %loop ]
  call void (i1, ...) @llvm.experimental.guard(i1 %cond) ["deopt" (i32 0)]
  %val = load i32, i32* %ptr
  store i32 0, i32* %ptr
  %x.inc = add i32 %x, %val
  br label %loop
}

; Hoist load and guard.
define void @test4(i1 %c, i32* %p) {
; CHECK-LABEL: @test4(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[A:%.*]] = load i32, i32* [[P:%.*]]
; CHECK-NEXT:    [[INVARIANT_COND:%.*]] = icmp ne i32 [[A]], 100
; CHECK-NEXT:    call void (i1, ...) @llvm.experimental.guard(i1 [[INVARIANT_COND]]) [ "deopt"() ]
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[IV_NEXT:%.*]], [[BACKEDGE:%.*]] ]
; CHECK-NEXT:    [[IV_NEXT]] = add i32 [[IV]], 1
; CHECK-NEXT:    br i1 [[C:%.*]], label [[IF_TRUE:%.*]], label [[IF_FALSE:%.*]]
; CHECK:       if.true:
; CHECK-NEXT:    br label [[BACKEDGE]]
; CHECK:       if.false:
; CHECK-NEXT:    br label [[BACKEDGE]]
; CHECK:       backedge:
; CHECK-NEXT:    [[LOOP_COND:%.*]] = icmp slt i32 [[IV_NEXT]], 1000
; CHECK-NEXT:    br i1 [[LOOP_COND]], label [[LOOP]], label [[EXIT:%.*]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;

entry:
  br label %loop

loop:
  %iv = phi i32 [ 0, %entry ], [ %iv.next, %backedge ]
  %iv.next = add i32 %iv, 1
  br i1 %c, label %if.true, label %if.false

if.true:
  br label %backedge

if.false:
  br label %backedge

backedge:
  %a = load i32, i32* %p
  %invariant_cond = icmp ne i32 %a, 100
  call void (i1, ...) @llvm.experimental.guard(i1 %invariant_cond) [ "deopt"() ]
  %loop_cond = icmp slt i32 %iv.next, 1000
  br i1 %loop_cond, label %loop, label %exit

exit:
  ret void
}

; Do not hoist across a conditionally executed side effect.
define void @test4a(i1 %c, i32* %p, i32* %q) {
; CHECK-LABEL: @test4a(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[IV_NEXT:%.*]], [[BACKEDGE:%.*]] ]
; CHECK-NEXT:    [[IV_NEXT]] = add i32 [[IV]], 1
; CHECK-NEXT:    br i1 [[C:%.*]], label [[IF_TRUE:%.*]], label [[IF_FALSE:%.*]]
; CHECK:       if.true:
; CHECK-NEXT:    store i32 123, i32* [[Q:%.*]]
; CHECK-NEXT:    br label [[BACKEDGE]]
; CHECK:       if.false:
; CHECK-NEXT:    br label [[BACKEDGE]]
; CHECK:       backedge:
; CHECK-NEXT:    [[A:%.*]] = load i32, i32* [[P:%.*]]
; CHECK-NEXT:    [[INVARIANT_COND:%.*]] = icmp ne i32 [[A]], 100
; CHECK-NEXT:    call void (i1, ...) @llvm.experimental.guard(i1 [[INVARIANT_COND]]) [ "deopt"() ]
; CHECK-NEXT:    [[LOOP_COND:%.*]] = icmp slt i32 [[IV_NEXT]], 1000
; CHECK-NEXT:    br i1 [[LOOP_COND]], label [[LOOP]], label [[EXIT:%.*]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;

entry:
  br label %loop

loop:
  %iv = phi i32 [ 0, %entry ], [ %iv.next, %backedge ]
  %iv.next = add i32 %iv, 1
  br i1 %c, label %if.true, label %if.false

if.true:
  store i32 123, i32* %q
  br label %backedge

if.false:
  br label %backedge

backedge:
  %a = load i32, i32* %p
  %invariant_cond = icmp ne i32 %a, 100
  call void (i1, ...) @llvm.experimental.guard(i1 %invariant_cond) [ "deopt"() ]
  %loop_cond = icmp slt i32 %iv.next, 1000
  br i1 %loop_cond, label %loop, label %exit

exit:
  ret void
}

; Do not hoist a conditionally executed guard.
define void @test4b(i1 %c, i32* %p, i32* %q) {
; CHECK-LABEL: @test4b(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[IV_NEXT:%.*]], [[BACKEDGE:%.*]] ]
; CHECK-NEXT:    [[IV_NEXT]] = add i32 [[IV]], 1
; CHECK-NEXT:    br i1 [[C:%.*]], label [[IF_TRUE:%.*]], label [[IF_FALSE:%.*]]
; CHECK:       if.true:
; CHECK-NEXT:    [[A:%.*]] = load i32, i32* [[P:%.*]]
; CHECK-NEXT:    [[INVARIANT_COND:%.*]] = icmp ne i32 [[A]], 100
; CHECK-NEXT:    call void (i1, ...) @llvm.experimental.guard(i1 [[INVARIANT_COND]]) [ "deopt"() ]
; CHECK-NEXT:    br label [[BACKEDGE]]
; CHECK:       if.false:
; CHECK-NEXT:    br label [[BACKEDGE]]
; CHECK:       backedge:
; CHECK-NEXT:    [[LOOP_COND:%.*]] = icmp slt i32 [[IV_NEXT]], 1000
; CHECK-NEXT:    br i1 [[LOOP_COND]], label [[LOOP]], label [[EXIT:%.*]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;

entry:
  br label %loop

loop:
  %iv = phi i32 [ 0, %entry ], [ %iv.next, %backedge ]
  %iv.next = add i32 %iv, 1
  br i1 %c, label %if.true, label %if.false

if.true:
  %a = load i32, i32* %p
  %invariant_cond = icmp ne i32 %a, 100
  call void (i1, ...) @llvm.experimental.guard(i1 %invariant_cond) [ "deopt"() ]
  br label %backedge

if.false:
  br label %backedge

backedge:
  %loop_cond = icmp slt i32 %iv.next, 1000
  br i1 %loop_cond, label %loop, label %exit

exit:
  ret void
}

; Hoist store, load and guard.
define void @test4c(i1 %c, i32* %p, i8* noalias %s) {
; CHECK-LABEL: @test4c(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    store i8 0, i8* [[S:%.*]]
; CHECK-NEXT:    [[A:%.*]] = load i32, i32* [[P:%.*]]
; CHECK-NEXT:    [[INVARIANT_COND:%.*]] = icmp ne i32 [[A]], 100
; CHECK-NEXT:    call void (i1, ...) @llvm.experimental.guard(i1 [[INVARIANT_COND]]) [ "deopt"() ]
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[IV_NEXT:%.*]], [[BACKEDGE:%.*]] ]
; CHECK-NEXT:    [[IV_NEXT]] = add i32 [[IV]], 1
; CHECK-NEXT:    br i1 [[C:%.*]], label [[IF_TRUE:%.*]], label [[IF_FALSE:%.*]]
; CHECK:       if.true:
; CHECK-NEXT:    br label [[BACKEDGE]]
; CHECK:       if.false:
; CHECK-NEXT:    br label [[BACKEDGE]]
; CHECK:       backedge:
; CHECK-NEXT:    [[LOOP_COND:%.*]] = icmp slt i32 [[IV_NEXT]], 1000
; CHECK-NEXT:    br i1 [[LOOP_COND]], label [[LOOP]], label [[EXIT:%.*]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;

entry:
  br label %loop

loop:
  %iv = phi i32 [ 0, %entry ], [ %iv.next, %backedge ]
  %iv.next = add i32 %iv, 1
  store i8 0, i8* %s
  br i1 %c, label %if.true, label %if.false

if.true:
  br label %backedge

if.false:
  br label %backedge

backedge:
  %a = load i32, i32* %p
  %invariant_cond = icmp ne i32 %a, 100
  call void (i1, ...) @llvm.experimental.guard(i1 %invariant_cond) [ "deopt"() ]
  %loop_cond = icmp slt i32 %iv.next, 1000
  br i1 %loop_cond, label %loop, label %exit

exit:
  ret void
}

; Check that we don't hoist across a store in a conditionally executed block.
define void @test4d(i1 %c, i32* %p, i8* noalias %s) {
; CHECK-LABEL: @test4d(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[A:%.*]] = load i32, i32* [[P:%.*]]
; CHECK-NEXT:    [[INVARIANT_COND:%.*]] = icmp ne i32 [[A]], 100
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[IV_NEXT:%.*]], [[BACKEDGE:%.*]] ]
; CHECK-NEXT:    [[IV_NEXT]] = add i32 [[IV]], 1
; CHECK-NEXT:    br i1 [[C:%.*]], label [[IF_TRUE:%.*]], label [[IF_FALSE:%.*]]
; CHECK:       if.true:
; CHECK-NEXT:    store i8 0, i8* [[S:%.*]]
; CHECK-NEXT:    br label [[BACKEDGE]]
; CHECK:       if.false:
; CHECK-NEXT:    br label [[BACKEDGE]]
; CHECK:       backedge:
; CHECK-NEXT:    call void (i1, ...) @llvm.experimental.guard(i1 [[INVARIANT_COND]]) [ "deopt"() ]
; CHECK-NEXT:    [[LOOP_COND:%.*]] = icmp slt i32 [[IV_NEXT]], 1000
; CHECK-NEXT:    br i1 [[LOOP_COND]], label [[LOOP]], label [[EXIT:%.*]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;

entry:
  br label %loop

loop:
  %iv = phi i32 [ 0, %entry ], [ %iv.next, %backedge ]
  %iv.next = add i32 %iv, 1
  br i1 %c, label %if.true, label %if.false

if.true:
  store i8 0, i8* %s
  br label %backedge

if.false:
  br label %backedge

backedge:
  %a = load i32, i32* %p
  %invariant_cond = icmp ne i32 %a, 100
  call void (i1, ...) @llvm.experimental.guard(i1 %invariant_cond) [ "deopt"() ]
  %loop_cond = icmp slt i32 %iv.next, 1000
  br i1 %loop_cond, label %loop, label %exit

exit:
  ret void
}

; Check that we don't hoist across a store before the guard in the backedge.
define void @test4e(i1 %c, i32* %p, i8* noalias %s) {
; CHECK-LABEL: @test4e(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[A:%.*]] = load i32, i32* [[P:%.*]]
; CHECK-NEXT:    [[INVARIANT_COND:%.*]] = icmp ne i32 [[A]], 100
; CHECK-NEXT:    store i8 0, i8* [[S:%.*]]
; CHECK-NEXT:    call void (i1, ...) @llvm.experimental.guard(i1 [[INVARIANT_COND]]) [ "deopt"() ]
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[IV_NEXT:%.*]], [[BACKEDGE:%.*]] ]
; CHECK-NEXT:    [[IV_NEXT]] = add i32 [[IV]], 1
; CHECK-NEXT:    br i1 [[C:%.*]], label [[IF_TRUE:%.*]], label [[IF_FALSE:%.*]]
; CHECK:       if.true:
; CHECK-NEXT:    br label [[BACKEDGE]]
; CHECK:       if.false:
; CHECK-NEXT:    br label [[BACKEDGE]]
; CHECK:       backedge:
; CHECK-NEXT:    [[LOOP_COND:%.*]] = icmp slt i32 [[IV_NEXT]], 1000
; CHECK-NEXT:    br i1 [[LOOP_COND]], label [[LOOP]], label [[EXIT:%.*]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;

entry:
  br label %loop

loop:
  %iv = phi i32 [ 0, %entry ], [ %iv.next, %backedge ]
  %iv.next = add i32 %iv, 1
  br i1 %c, label %if.true, label %if.false

if.true:
  br label %backedge

if.false:
  br label %backedge

backedge:
  %a = load i32, i32* %p
  %invariant_cond = icmp ne i32 %a, 100
  store i8 0, i8* %s
  call void (i1, ...) @llvm.experimental.guard(i1 %invariant_cond) [ "deopt"() ]
  %loop_cond = icmp slt i32 %iv.next, 1000
  br i1 %loop_cond, label %loop, label %exit

exit:
  ret void
}

; Check that we can hoist the guard in spite of store which happens after.
define void @test4f(i1 %c, i32* %p, i8* noalias %s) {
; CHECK-LABEL: @test4f(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[A:%.*]] = load i32, i32* [[P:%.*]]
; CHECK-NEXT:    [[INVARIANT_COND:%.*]] = icmp ne i32 [[A]], 100
; CHECK-NEXT:    call void (i1, ...) @llvm.experimental.guard(i1 [[INVARIANT_COND]]) [ "deopt"() ]
; CHECK-NEXT:    store i8 0, i8* [[S:%.*]]
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[IV_NEXT:%.*]], [[BACKEDGE:%.*]] ]
; CHECK-NEXT:    [[IV_NEXT]] = add i32 [[IV]], 1
; CHECK-NEXT:    br i1 [[C:%.*]], label [[IF_TRUE:%.*]], label [[IF_FALSE:%.*]]
; CHECK:       if.true:
; CHECK-NEXT:    br label [[BACKEDGE]]
; CHECK:       if.false:
; CHECK-NEXT:    br label [[BACKEDGE]]
; CHECK:       backedge:
; CHECK-NEXT:    [[LOOP_COND:%.*]] = icmp slt i32 [[IV_NEXT]], 1000
; CHECK-NEXT:    br i1 [[LOOP_COND]], label [[LOOP]], label [[EXIT:%.*]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;

entry:
  br label %loop

loop:
  %iv = phi i32 [ 0, %entry ], [ %iv.next, %backedge ]
  %iv.next = add i32 %iv, 1
  br i1 %c, label %if.true, label %if.false

if.true:
  br label %backedge

if.false:
  br label %backedge

backedge:
  %a = load i32, i32* %p
  %invariant_cond = icmp ne i32 %a, 100
  call void (i1, ...) @llvm.experimental.guard(i1 %invariant_cond) [ "deopt"() ]
  store i8 0, i8* %s
  %loop_cond = icmp slt i32 %iv.next, 1000
  br i1 %loop_cond, label %loop, label %exit

exit:
  ret void
}

; Do not hoist an invariant guard across a variant guard.
define void @test5(i1 %c, i32* %p, i32* %q) {
; CHECK-LABEL: @test5(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[A:%.*]] = load i32, i32* [[P:%.*]]
; CHECK-NEXT:    [[INVARIANT_COND:%.*]] = icmp ne i32 [[A]], 100
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[IV_NEXT:%.*]], [[BACKEDGE:%.*]] ]
; CHECK-NEXT:    [[IV_NEXT]] = add i32 [[IV]], 1
; CHECK-NEXT:    [[VARIANT_COND:%.*]] = icmp ne i32 [[A]], [[IV]]
; CHECK-NEXT:    call void (i1, ...) @llvm.experimental.guard(i1 [[VARIANT_COND]]) [ "deopt"() ]
; CHECK-NEXT:    call void (i1, ...) @llvm.experimental.guard(i1 [[INVARIANT_COND]]) [ "deopt"() ]
; CHECK-NEXT:    br label [[BACKEDGE]]
; CHECK:       backedge:
; CHECK-NEXT:    [[LOOP_COND:%.*]] = icmp slt i32 [[IV_NEXT]], 1000
; CHECK-NEXT:    br i1 [[LOOP_COND]], label [[LOOP]], label [[EXIT:%.*]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;

entry:
  br label %loop

loop:
  %iv = phi i32 [ 0, %entry ], [ %iv.next, %backedge ]
  %iv.next = add i32 %iv, 1
  %a = load i32, i32* %p
  %invariant_cond = icmp ne i32 %a, 100
  %variant_cond = icmp ne i32 %a, %iv
  call void (i1, ...) @llvm.experimental.guard(i1 %variant_cond) [ "deopt"() ]
  call void (i1, ...) @llvm.experimental.guard(i1 %invariant_cond) [ "deopt"() ]
  br label %backedge

backedge:
  %loop_cond = icmp slt i32 %iv.next, 1000
  br i1 %loop_cond, label %loop, label %exit

exit:
  ret void
}

; Hoist an invariant guard, leave the following variant guard in the loop.
define void @test5a(i1 %c, i32* %p, i32* %q) {
; CHECK-LABEL: @test5a(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[A:%.*]] = load i32, i32* [[P:%.*]]
; CHECK-NEXT:    [[INVARIANT_COND:%.*]] = icmp ne i32 [[A]], 100
; CHECK-NEXT:    call void (i1, ...) @llvm.experimental.guard(i1 [[INVARIANT_COND]]) [ "deopt"() ]
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[IV_NEXT:%.*]], [[BACKEDGE:%.*]] ]
; CHECK-NEXT:    [[IV_NEXT]] = add i32 [[IV]], 1
; CHECK-NEXT:    [[VARIANT_COND:%.*]] = icmp ne i32 [[A]], [[IV]]
; CHECK-NEXT:    call void (i1, ...) @llvm.experimental.guard(i1 [[VARIANT_COND]]) [ "deopt"() ]
; CHECK-NEXT:    br label [[BACKEDGE]]
; CHECK:       backedge:
; CHECK-NEXT:    [[LOOP_COND:%.*]] = icmp slt i32 [[IV_NEXT]], 1000
; CHECK-NEXT:    br i1 [[LOOP_COND]], label [[LOOP]], label [[EXIT:%.*]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;

entry:
  br label %loop

loop:
  %iv = phi i32 [ 0, %entry ], [ %iv.next, %backedge ]
  %iv.next = add i32 %iv, 1
  %a = load i32, i32* %p
  %invariant_cond = icmp ne i32 %a, 100
  %variant_cond = icmp ne i32 %a, %iv
  call void (i1, ...) @llvm.experimental.guard(i1 %invariant_cond) [ "deopt"() ]
  call void (i1, ...) @llvm.experimental.guard(i1 %variant_cond) [ "deopt"() ]
  br label %backedge

backedge:
  %loop_cond = icmp slt i32 %iv.next, 1000
  br i1 %loop_cond, label %loop, label %exit

exit:
  ret void
}

declare void @llvm.experimental.guard(i1, ...)
