; The CGSCC pass manager includes an SCC iteration utility that tracks indirect
; calls that are turned into direct calls (devirtualization) and re-visits the
; SCC to expose those calls to the SCC-based IPO passes. We trigger
; devirtualization here with GVN which forwards a store through a load and to
; an indirect call.
;
; RUN: opt -aa-pipeline=basic-aa -passes='cgscc(function-attrs,function(gvn,instcombine))' -S < %s | FileCheck %s --check-prefix=CHECK --check-prefix=BEFORE
; RUN: opt -aa-pipeline=basic-aa -passes='cgscc(devirt<1>(function-attrs,function(gvn,instcombine)))' -S < %s | FileCheck %s --check-prefix=CHECK --check-prefix=AFTER --check-prefix=AFTER1
; RUN: opt -aa-pipeline=basic-aa -passes='cgscc(devirt<2>(function-attrs,function(gvn,instcombine)))' -S < %s | FileCheck %s --check-prefix=CHECK --check-prefix=AFTER --check-prefix=AFTER2

declare void @readnone() readnone
; CHECK: Function Attrs: readnone
; CHECK: declare void @readnone()

declare void @unknown()
; CHECK-NOT: Function Attrs
; CHECK: declare void @unknown()

; The @test1 function checks that when we refine an indirect call to a direct
; call we revisit the SCC passes to reflect the more precise information. This
; is the basic functionality.

define void @test1() {
; BEFORE-NOT: Function Attrs
; AFTER: Function Attrs: readnone
; CHECK: define void @test1()
entry:
  %fptr = alloca void ()*
  store void ()* @readnone, void ()** %fptr
  %f = load void ()*, void ()** %fptr
  call void %f()
  ret void
}

; The @test2_* functions check that when we need multiple (in this case 2)
; repetitions to compute some state that is incrementally exposed with each
; one, the limit on repetitions is enforced. So we make progress with
; one repetition but not as much as with three.
;
; This is somewhat awkward to test because we have to contrive to have a state
; repetition triggered and observed with very few passes. The technique here
; is to have one indirect call that can only be resolved when the entire SCC is
; deduced as readonly, and mark that indirect call at the call site as readonly
; to make that possible. This forces us to first deduce readonly, then
; devirtualize again, and then deduce readnone.

declare void @readnone_with_arg(void ()**) readnone
; CHECK: Function Attrs: readnone
; CHECK: declare void @readnone_with_arg(void ()**)

define void @test2_a(void ()** %ignore) {
; BEFORE-NOT: Function Attrs
; AFTER1: Function Attrs: readonly
; AFTER2: Function Attrs: readnone
; BEFORE: define void @test2_a(void ()** %ignore)
; AFTER: define void @test2_a(void ()** readnone %ignore)
entry:
  %f1ptr = alloca void (void ()**)*
  store void (void ()**)* @readnone_with_arg, void (void ()**)** %f1ptr
  %f1 = load void (void ()**)*, void (void ()**)** %f1ptr
  ; This indirect call is the first to be resolved, allowing us to deduce
  ; readonly but not (yet) readnone.
  call void %f1(void ()** %ignore)
; CHECK: call void @readnone_with_arg(void ()** %ignore)

  ; Bogus call to test2_b to make this a cycle.
  call void @test2_b()

  ret void
}

define void @test2_b() {
; BEFORE-NOT: Function Attrs
; AFTER1: Function Attrs: readonly
; AFTER2: Function Attrs: readnone
; CHECK: define void @test2_b()
entry:
  %f2ptr = alloca void ()*
  store void ()* @readnone, void ()** %f2ptr
  ; Call the other function here to prevent forwarding until the SCC has had
  ; function attrs deduced.
  call void @test2_a(void ()** %f2ptr)

  %f2 = load void ()*, void ()** %f2ptr
  ; This is the second indirect call to be resolved, and can only be resolved
  ; after we deduce 'readonly' for the rest of the SCC. Once it is
  ; devirtualized, we can deduce readnone for the SCC.
  call void %f2() readonly
; BEFORE: call void %f2()
; AFTER: call void @readnone()

  ret void
}

declare i8* @memcpy(i8*, i8*, i64)
; CHECK-NOT: Function Attrs
; CHECK: declare i8* @memcpy(i8*, i8*, i64)

; The @test3 function checks that when we refine an indirect call to an
; intrinsic we still revisit the SCC pass. This also covers cases where the
; value handle itself doesn't persist due to the nature of how instcombine
; creates the memcpy intrinsic call, and we rely on the count of indirect calls
; decreasing and the count of direct calls increasing.
define void @test3(i8* %src, i8* %dest, i64 %size) {
; CHECK-NOT: Function Attrs
; BEFORE: define void @test3(i8* %src, i8* %dest, i64 %size)
; AFTER: define void @test3(i8* nocapture readonly %src, i8* nocapture %dest, i64 %size)
  %fptr = alloca i8* (i8*, i8*, i64)*
  store i8* (i8*, i8*, i64)* @memcpy, i8* (i8*, i8*, i64)** %fptr
  %f = load i8* (i8*, i8*, i64)*, i8* (i8*, i8*, i64)** %fptr
  call i8* %f(i8* %dest, i8* %src, i64 %size)
; CHECK: call void @llvm.memcpy
  ret void
}
