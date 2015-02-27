; RUN: llc < %s -mtriple=x86_64-pc-win32 | FileCheck %s

%struct.A = type { i8 }
%struct.B = type { i32 }
%struct.C = type { %struct.B }
%struct.D = type { %struct.B }
%struct.E = type { %struct.B }

declare %struct.A* @A_ctor(%struct.A* returned)
declare %struct.B* @B_ctor(%struct.B* returned, i32)

declare %struct.A* @A_ctor_nothisret(%struct.A*)
declare %struct.B* @B_ctor_nothisret(%struct.B*, i32)

define %struct.C* @C_ctor(%struct.C* %this, i32 %y) {
entry:
; CHECK-LABEL: C_ctor:
; CHECK: jmp     B_ctor                  # TAILCALL
  %0 = getelementptr inbounds %struct.C, %struct.C* %this, i64 0, i32 0
  %call = tail call %struct.B* @B_ctor(%struct.B* %0, i32 %y)
  ret %struct.C* %this
}

define %struct.C* @C_ctor_nothisret(%struct.C* %this, i32 %y) {
entry:
; CHECK-LABEL: C_ctor_nothisret:
; CHECK-NOT: jmp     B_ctor_nothisret
  %0 = getelementptr inbounds %struct.C, %struct.C* %this, i64 0, i32 0
  %call = tail call %struct.B* @B_ctor_nothisret(%struct.B* %0, i32 %y)
  ret %struct.C* %this
}

define %struct.D* @D_ctor(%struct.D* %this, i32 %y) {
entry:
; CHECK-LABEL: D_ctor:
; CHECK: movq    %rcx, [[SAVETHIS:%r[0-9a-z]+]]
; CHECK: callq   A_ctor
; CHECK: movq    [[SAVETHIS]], %rcx
; CHECK: jmp     B_ctor                  # TAILCALL
  %0 = bitcast %struct.D* %this to %struct.A*
  %call = tail call %struct.A* @A_ctor(%struct.A* %0)
  %1 = getelementptr inbounds %struct.D, %struct.D* %this, i64 0, i32 0
  %call2 = tail call %struct.B* @B_ctor(%struct.B* %1, i32 %y)
; (this next line would never be generated by Clang, actually)
  %2 = bitcast %struct.A* %call to %struct.D*
  ret %struct.D* %2
}

define %struct.D* @D_ctor_nothisret(%struct.D* %this, i32 %y) {
entry:
; CHECK-LABEL: D_ctor_nothisret:
; CHECK: movq    %rcx, [[SAVETHIS:%r[0-9a-z]+]]
; CHECK: callq   A_ctor_nothisret
; CHECK: movq    [[SAVETHIS]], %rcx
; CHECK-NOT: jmp     B_ctor_nothisret
  %0 = bitcast %struct.D* %this to %struct.A*
  %call = tail call %struct.A* @A_ctor_nothisret(%struct.A* %0)
  %1 = getelementptr inbounds %struct.D, %struct.D* %this, i64 0, i32 0
  %call2 = tail call %struct.B* @B_ctor_nothisret(%struct.B* %1, i32 %y)
; (this next line would never be generated by Clang, actually)
  %2 = bitcast %struct.A* %call to %struct.D*
  ret %struct.D* %2
}

define %struct.E* @E_ctor(%struct.E* %this, i32 %x) {
entry:
; CHECK-LABEL: E_ctor:
; CHECK: movq    %rcx, [[SAVETHIS:%r[0-9a-z]+]]
; CHECK: callq   B_ctor
; CHECK: movq    [[SAVETHIS]], %rcx
; CHECK: jmp     B_ctor                  # TAILCALL
  %b = getelementptr inbounds %struct.E, %struct.E* %this, i64 0, i32 0
  %call = tail call %struct.B* @B_ctor(%struct.B* %b, i32 %x)
  %call4 = tail call %struct.B* @B_ctor(%struct.B* %b, i32 %x)
  ret %struct.E* %this
}

define %struct.E* @E_ctor_nothisret(%struct.E* %this, i32 %x) {
entry:
; CHECK-LABEL: E_ctor_nothisret:
; CHECK: movq    %rcx, [[SAVETHIS:%r[0-9a-z]+]]
; CHECK: callq   B_ctor_nothisret
; CHECK: movq    [[SAVETHIS]], %rcx
; CHECK-NOT: jmp     B_ctor_nothisret
  %b = getelementptr inbounds %struct.E, %struct.E* %this, i64 0, i32 0
  %call = tail call %struct.B* @B_ctor_nothisret(%struct.B* %b, i32 %x)
  %call4 = tail call %struct.B* @B_ctor_nothisret(%struct.B* %b, i32 %x)
  ret %struct.E* %this
}
