; RUN: llc < %s -march=x86 | FileCheck %s

define i32 @t1() nounwind {
entry:
  %0 = tail call i32 asm sideeffect inteldialect "mov eax, $1\0A\09mov $0, eax", "=r,r,~{eax},~{dirflag},~{fpsr},~{flags}"(i32 1) nounwind
  ret i32 %0
; CHECK: t1
; CHECK: {{## InlineAsm Start|#APP}}
; CHECK: .intel_syntax
; CHECK: mov eax, ecx
; CHECK: mov ecx, eax
; CHECK: .att_syntax
; CHECK: {{## InlineAsm End|#NO_APP}}
}

define void @t2() nounwind {
entry:
  call void asm sideeffect inteldialect "mov eax, $$1", "~{eax},~{dirflag},~{fpsr},~{flags}"() nounwind
  ret void
; CHECK: t2
; CHECK: {{## InlineAsm Start|#APP}}
; CHECK: .intel_syntax
; CHECK: mov eax, 1
; CHECK: .att_syntax
; CHECK: {{## InlineAsm End|#NO_APP}}
}

define void @t3(i32 %V) nounwind {
entry:
  %V.addr = alloca i32, align 4
  store i32 %V, i32* %V.addr, align 4
  call void asm sideeffect inteldialect "mov eax, DWORD PTR [$0]", "*m,~{eax},~{dirflag},~{fpsr},~{flags}"(i32* %V.addr) nounwind
  ret void
; CHECK: t3
; CHECK: {{## InlineAsm Start|#APP}}
; CHECK: .intel_syntax
; CHECK: mov eax, DWORD PTR {{[[esp]}}
; CHECK: .att_syntax
; CHECK: {{## InlineAsm End|#NO_APP}}
}
