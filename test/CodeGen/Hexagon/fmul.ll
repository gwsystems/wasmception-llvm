; RUN: llc -march=hexagon -mcpu=hexagonv5  < %s | FileCheck %s
; Check that we generate single precision floating point multiply in V5.

; CHECK: r{{[0-9]+}} = sfmpy(r{{[0-9]+}}, r{{[0-9]+}})


define i32 @main() nounwind {
entry:
  %a = alloca float, align 4
  %b = alloca float, align 4
  %c = alloca float, align 4
  store float 0x402ECCCCC0000000, float* %a, align 4
  store float 0x4022333340000000, float* %b, align 4
  %0 = load float* %b, align 4
  %1 = load float* %a, align 4
  %mul = fmul float %0, %1
  store float %mul, float* %c, align 4
  ret i32 0
}
