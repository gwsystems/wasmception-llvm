; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-apple-darwin -mcpu=knl -mattr=+avx512vl | FileCheck %s

; 256-bit

define <8 x i32> @vpandd256(<8 x i32> %a, <8 x i32> %b) nounwind uwtable readnone ssp {
; CHECK-LABEL: vpandd256:
; CHECK:       ## BB#0: ## %entry
; CHECK-NEXT:    vpaddd {{.*}}(%rip){1to8}, %ymm0, %ymm0
; CHECK-NEXT:    vpandd %ymm1, %ymm0, %ymm0
; CHECK-NEXT:    retq
entry:
  ; Force the execution domain with an add.
  %a2 = add <8 x i32> %a, <i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1>
  %x = and <8 x i32> %a2, %b
  ret <8 x i32> %x
}

define <8 x i32> @vpandnd256(<8 x i32> %a, <8 x i32> %b) nounwind uwtable readnone ssp {
; CHECK-LABEL: vpandnd256:
; CHECK:       ## BB#0: ## %entry
; CHECK-NEXT:    vpaddd {{.*}}(%rip){1to8}, %ymm0, %ymm1
; CHECK-NEXT:    vpandnd %ymm1, %ymm0, %ymm0
; CHECK-NEXT:    retq
entry:
  ; Force the execution domain with an add.
  %a2 = add <8 x i32> %a, <i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1>
  %b2 = xor <8 x i32> %a, <i32 -1, i32 -1, i32 -1, i32 -1, i32 -1, i32 -1, i32 -1, i32 -1>
  %x = and <8 x i32> %a2, %b2
  ret <8 x i32> %x
}

define <8 x i32> @vpord256(<8 x i32> %a, <8 x i32> %b) nounwind uwtable readnone ssp {
; CHECK-LABEL: vpord256:
; CHECK:       ## BB#0: ## %entry
; CHECK-NEXT:    vpaddd {{.*}}(%rip){1to8}, %ymm0, %ymm0
; CHECK-NEXT:    vpord %ymm1, %ymm0, %ymm0
; CHECK-NEXT:    retq
entry:
  ; Force the execution domain with an add.
  %a2 = add <8 x i32> %a, <i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1>
  %x = or <8 x i32> %a2, %b
  ret <8 x i32> %x
}

define <8 x i32> @vpxord256(<8 x i32> %a, <8 x i32> %b) nounwind uwtable readnone ssp {
; CHECK-LABEL: vpxord256:
; CHECK:       ## BB#0: ## %entry
; CHECK-NEXT:    vpaddd {{.*}}(%rip){1to8}, %ymm0, %ymm0
; CHECK-NEXT:    vpxord %ymm1, %ymm0, %ymm0
; CHECK-NEXT:    retq
entry:
  ; Force the execution domain with an add.
  %a2 = add <8 x i32> %a, <i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1>
  %x = xor <8 x i32> %a2, %b
  ret <8 x i32> %x
}

define <4 x i64> @vpandq256(<4 x i64> %a, <4 x i64> %b) nounwind uwtable readnone ssp {
; CHECK-LABEL: vpandq256:
; CHECK:       ## BB#0: ## %entry
; CHECK-NEXT:    vpaddq {{.*}}(%rip){1to4}, %ymm0, %ymm0
; CHECK-NEXT:    vpandq %ymm1, %ymm0, %ymm0
; CHECK-NEXT:    retq
entry:
  ; Force the execution domain with an add.
  %a2 = add <4 x i64> %a, <i64 1, i64 1, i64 1, i64 1>
  %x = and <4 x i64> %a2, %b
  ret <4 x i64> %x
}

define <4 x i64> @vpandnq256(<4 x i64> %a, <4 x i64> %b) nounwind uwtable readnone ssp {
; CHECK-LABEL: vpandnq256:
; CHECK:       ## BB#0: ## %entry
; CHECK-NEXT:    vpaddq {{.*}}(%rip){1to4}, %ymm0, %ymm0
; CHECK-NEXT:    vpandnq %ymm0, %ymm1, %ymm0
; CHECK-NEXT:    retq
entry:
  ; Force the execution domain with an add.
  %a2 = add <4 x i64> %a, <i64 1, i64 1, i64 1, i64 1>
  %b2 = xor <4 x i64> %b, <i64 -1, i64 -1, i64 -1, i64 -1>
  %x = and <4 x i64> %a2, %b2
  ret <4 x i64> %x
}

define <4 x i64> @vporq256(<4 x i64> %a, <4 x i64> %b) nounwind uwtable readnone ssp {
; CHECK-LABEL: vporq256:
; CHECK:       ## BB#0: ## %entry
; CHECK-NEXT:    vpaddq {{.*}}(%rip){1to4}, %ymm0, %ymm0
; CHECK-NEXT:    vporq %ymm1, %ymm0, %ymm0
; CHECK-NEXT:    retq
entry:
  ; Force the execution domain with an add.
  %a2 = add <4 x i64> %a, <i64 1, i64 1, i64 1, i64 1>
  %x = or <4 x i64> %a2, %b
  ret <4 x i64> %x
}

define <4 x i64> @vpxorq256(<4 x i64> %a, <4 x i64> %b) nounwind uwtable readnone ssp {
; CHECK-LABEL: vpxorq256:
; CHECK:       ## BB#0: ## %entry
; CHECK-NEXT:    vpaddq {{.*}}(%rip){1to4}, %ymm0, %ymm0
; CHECK-NEXT:    vpxorq %ymm1, %ymm0, %ymm0
; CHECK-NEXT:    retq
entry:
  ; Force the execution domain with an add.
  %a2 = add <4 x i64> %a, <i64 1, i64 1, i64 1, i64 1>
  %x = xor <4 x i64> %a2, %b
  ret <4 x i64> %x
}

; 128-bit

define <4 x i32> @vpandd128(<4 x i32> %a, <4 x i32> %b) nounwind uwtable readnone ssp {
; CHECK-LABEL: vpandd128:
; CHECK:       ## BB#0: ## %entry
; CHECK-NEXT:    vpaddd {{.*}}(%rip){1to4}, %xmm0, %xmm0
; CHECK-NEXT:    vpandd %xmm1, %xmm0, %xmm0
; CHECK-NEXT:    retq
entry:
  ; Force the execution domain with an add.
  %a2 = add <4 x i32> %a, <i32 1, i32 1, i32 1, i32 1>
  %x = and <4 x i32> %a2, %b
  ret <4 x i32> %x
}

define <4 x i32> @vpandnd128(<4 x i32> %a, <4 x i32> %b) nounwind uwtable readnone ssp {
; CHECK-LABEL: vpandnd128:
; CHECK:       ## BB#0: ## %entry
; CHECK-NEXT:    vpaddd {{.*}}(%rip){1to4}, %xmm0, %xmm0
; CHECK-NEXT:    vpandnd %xmm0, %xmm1, %xmm0
; CHECK-NEXT:    retq
entry:
  ; Force the execution domain with an add.
  %a2 = add <4 x i32> %a, <i32 1, i32 1, i32 1, i32 1>
  %b2 = xor <4 x i32> %b, <i32 -1, i32 -1, i32 -1, i32 -1>
  %x = and <4 x i32> %a2, %b2
  ret <4 x i32> %x
}

define <4 x i32> @vpord128(<4 x i32> %a, <4 x i32> %b) nounwind uwtable readnone ssp {
; CHECK-LABEL: vpord128:
; CHECK:       ## BB#0: ## %entry
; CHECK-NEXT:    vpaddd {{.*}}(%rip){1to4}, %xmm0, %xmm0
; CHECK-NEXT:    vpord %xmm1, %xmm0, %xmm0
; CHECK-NEXT:    retq
entry:
  ; Force the execution domain with an add.
  %a2 = add <4 x i32> %a, <i32 1, i32 1, i32 1, i32 1>
  %x = or <4 x i32> %a2, %b
  ret <4 x i32> %x
}

define <4 x i32> @vpxord128(<4 x i32> %a, <4 x i32> %b) nounwind uwtable readnone ssp {
; CHECK-LABEL: vpxord128:
; CHECK:       ## BB#0: ## %entry
; CHECK-NEXT:    vpaddd {{.*}}(%rip){1to4}, %xmm0, %xmm0
; CHECK-NEXT:    vpxord %xmm1, %xmm0, %xmm0
; CHECK-NEXT:    retq
entry:
  ; Force the execution domain with an add.
  %a2 = add <4 x i32> %a, <i32 1, i32 1, i32 1, i32 1>
  %x = xor <4 x i32> %a2, %b
  ret <4 x i32> %x
}

define <2 x i64> @vpandq128(<2 x i64> %a, <2 x i64> %b) nounwind uwtable readnone ssp {
; CHECK-LABEL: vpandq128:
; CHECK:       ## BB#0: ## %entry
; CHECK-NEXT:    vpaddq {{.*}}(%rip), %xmm0, %xmm0
; CHECK-NEXT:    vpandq %xmm1, %xmm0, %xmm0
; CHECK-NEXT:    retq
entry:
  ; Force the execution domain with an add.
  %a2 = add <2 x i64> %a, <i64 1, i64 1>
  %x = and <2 x i64> %a2, %b
  ret <2 x i64> %x
}

define <2 x i64> @vpandnq128(<2 x i64> %a, <2 x i64> %b) nounwind uwtable readnone ssp {
; CHECK-LABEL: vpandnq128:
; CHECK:       ## BB#0: ## %entry
; CHECK-NEXT:    vpaddq {{.*}}(%rip), %xmm0, %xmm0
; CHECK-NEXT:    vpandnq %xmm0, %xmm1, %xmm0
; CHECK-NEXT:    retq
entry:
  ; Force the execution domain with an add.
  %a2 = add <2 x i64> %a, <i64 1, i64 1>
  %b2 = xor <2 x i64> %b, <i64 -1, i64 -1>
  %x = and <2 x i64> %a2, %b2
  ret <2 x i64> %x
}

define <2 x i64> @vporq128(<2 x i64> %a, <2 x i64> %b) nounwind uwtable readnone ssp {
; CHECK-LABEL: vporq128:
; CHECK:       ## BB#0: ## %entry
; CHECK-NEXT:    vpaddq {{.*}}(%rip), %xmm0, %xmm0
; CHECK-NEXT:    vporq %xmm1, %xmm0, %xmm0
; CHECK-NEXT:    retq
entry:
  ; Force the execution domain with an add.
  %a2 = add <2 x i64> %a, <i64 1, i64 1>
  %x = or <2 x i64> %a2, %b
  ret <2 x i64> %x
}

define <2 x i64> @vpxorq128(<2 x i64> %a, <2 x i64> %b) nounwind uwtable readnone ssp {
; CHECK-LABEL: vpxorq128:
; CHECK:       ## BB#0: ## %entry
; CHECK-NEXT:    vpaddq {{.*}}(%rip), %xmm0, %xmm0
; CHECK-NEXT:    vpxorq %xmm1, %xmm0, %xmm0
; CHECK-NEXT:    retq
entry:
  ; Force the execution domain with an add.
  %a2 = add <2 x i64> %a, <i64 1, i64 1>
  %x = xor <2 x i64> %a2, %b
  ret <2 x i64> %x
}
