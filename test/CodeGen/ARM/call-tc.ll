; RUN: llc < %s -mtriple=armv6-apple-ios -mattr=+vfp2 -arm-tail-calls | FileCheck %s -check-prefix=CHECKV6
; RUN: llc < %s -mtriple=armv6-linux-gnueabi -relocation-model=pic -mattr=+vfp2 -arm-tail-calls | FileCheck %s -check-prefix=CHECKELF
; RUN: llc < %s -mtriple=thumbv7-apple-ios -arm-tail-calls | FileCheck %s -check-prefix=CHECKT2D
; RUN: llc < %s -mtriple=thumbv7-apple-ios5.0 | FileCheck %s -check-prefix=CHECKT2D

; Enable tailcall optimization for iOS 5.0
; rdar://9120031

@t = weak global i32 ()* null           ; <i32 ()**> [#uses=1]

declare void @g(i32, i32, i32, i32)

define void @t1() {
; CHECKELF: t1:
; CHECKELF: bl g(PLT)
        call void @g( i32 1, i32 2, i32 3, i32 4 )
        ret void
}

define void @t2() {
; CHECKV6: t2:
; CHECKV6: bx r0
; CHECKT2D: t2:
; CHECKT2D: ldr
; CHECKT2D-NEXT: ldr
; CHECKT2D-NEXT: bx r0
        %tmp = load i32 ()** @t         ; <i32 ()*> [#uses=1]
        %tmp.upgrd.2 = tail call i32 %tmp( )            ; <i32> [#uses=0]
        ret void
}

define void @t3() {
; CHECKV6: t3:
; CHECKV6: b _t2
; CHECKELF: t3:
; CHECKELF: b t2(PLT)
; CHECKT2D: t3:
; CHECKT2D: b.w _t2

        tail call void @t2( )            ; <i32> [#uses=0]
        ret void
}

; Sibcall optimization of expanded libcalls. rdar://8707777
define double @t4(double %a) nounwind readonly ssp {
entry:
; CHECKV6: t4:
; CHECKV6: b _sin
; CHECKELF: t4:
; CHECKELF: b sin(PLT)
  %0 = tail call double @sin(double %a) nounwind readonly ; <double> [#uses=1]
  ret double %0
}

define float @t5(float %a) nounwind readonly ssp {
entry:
; CHECKV6: t5:
; CHECKV6: b _sinf
; CHECKELF: t5:
; CHECKELF: b sinf(PLT)
  %0 = tail call float @sinf(float %a) nounwind readonly ; <float> [#uses=1]
  ret float %0
}

declare float @sinf(float) nounwind readonly

declare double @sin(double) nounwind readonly

define i32 @t6(i32 %a, i32 %b) nounwind readnone {
entry:
; CHECKV6: t6:
; CHECKV6: b ___divsi3
; CHECKELF: t6:
; CHECKELF: b __aeabi_idiv(PLT)
  %0 = sdiv i32 %a, %b
  ret i32 %0
}

; Make sure the tail call instruction isn't deleted
; rdar://8309338
declare void @foo() nounwind

define void @t7() nounwind {
entry:
; CHECKT2D: t7:
; CHECKT2D: blxeq _foo
; CHECKT2D-NEXT: pop.w
; CHECKT2D-NEXT: b.w _foo
  br i1 undef, label %bb, label %bb1.lr.ph

bb1.lr.ph:
  tail call void @foo() nounwind
  unreachable

bb:
  tail call void @foo() nounwind
  ret void
}

; Make sure codegenprep is duplicating ret instructions to enable tail calls.
; rdar://11140249
define i32 @t8(i32 %x) nounwind ssp {
entry:
; CHECKT2D: t8:
; CHECKT2D-NOT: push
  %and = and i32 %x, 1
  %tobool = icmp eq i32 %and, 0
  br i1 %tobool, label %if.end, label %if.then

if.then:                                          ; preds = %entry
; CHECKT2D: bne.w _a
  %call = tail call i32 @a(i32 %x) nounwind
  br label %return

if.end:                                           ; preds = %entry
  %and1 = and i32 %x, 2
  %tobool2 = icmp eq i32 %and1, 0
  br i1 %tobool2, label %if.end5, label %if.then3

if.then3:                                         ; preds = %if.end
; CHECKT2D: bne.w _b
  %call4 = tail call i32 @b(i32 %x) nounwind
  br label %return

if.end5:                                          ; preds = %if.end
; CHECKT2D: b.w _c
  %call6 = tail call i32 @c(i32 %x) nounwind
  br label %return

return:                                           ; preds = %if.end5, %if.then3, %if.then
  %retval.0 = phi i32 [ %call, %if.then ], [ %call4, %if.then3 ], [ %call6, %if.end5 ]
  ret i32 %retval.0
}

declare i32 @a(i32)

declare i32 @b(i32)

declare i32 @c(i32)

; PR12419
; rdar://11195178
; Use the correct input chain for the tailcall node or else the call to
; _ZN9MutexLockD1Ev would be lost.
%class.MutexLock = type { i8 }

@x = external global i32, align 4

define i32 @t9() nounwind {
; CHECKT2D: t9:
; CHECKT2D: blx __ZN9MutexLockC1Ev
; CHECKT2D: blx __ZN9MutexLockD1Ev
; CHECKT2D: b.w ___divsi3
  %lock = alloca %class.MutexLock, align 1
  %1 = call %class.MutexLock* @_ZN9MutexLockC1Ev(%class.MutexLock* %lock)
  %2 = load i32* @x, align 4
  %3 = sdiv i32 1000, %2
  %4 = call %class.MutexLock* @_ZN9MutexLockD1Ev(%class.MutexLock* %lock)
  ret i32 %3
}

declare %class.MutexLock* @_ZN9MutexLockC1Ev(%class.MutexLock*) unnamed_addr nounwind align 2

declare %class.MutexLock* @_ZN9MutexLockD1Ev(%class.MutexLock*) unnamed_addr nounwind align 2
