; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=riscv32 -mattr=+f -verify-machineinstrs < %s \
; RUN:   | FileCheck -check-prefix=RV32F %s
; RUN: llc -mtriple=riscv64 -mattr=+f -verify-machineinstrs < %s \
; RUN:   | FileCheck -check-prefix=RV64F %s

@gf = external global float

define float @constraint_f_float(float %a) nounwind {
; RV32F-LABEL: constraint_f_float:
; RV32F:       # %bb.0:
; RV32F-NEXT:    lui a1, %hi(gf)
; RV32F-NEXT:    flw ft0, %lo(gf)(a1)
; RV32F-NEXT:    fmv.w.x ft1, a0
; RV32F-NEXT:    #APP
; RV32F-NEXT:    fadd.s ft0, ft1, ft0
; RV32F-NEXT:    #NO_APP
; RV32F-NEXT:    fmv.x.w a0, ft0
; RV32F-NEXT:    ret
;
; RV64F-LABEL: constraint_f_float:
; RV64F:       # %bb.0:
; RV64F-NEXT:    lui a1, %hi(gf)
; RV64F-NEXT:    flw ft0, %lo(gf)(a1)
; RV64F-NEXT:    fmv.w.x ft1, a0
; RV64F-NEXT:    #APP
; RV64F-NEXT:    fadd.s ft0, ft1, ft0
; RV64F-NEXT:    #NO_APP
; RV64F-NEXT:    fmv.x.w a0, ft0
; RV64F-NEXT:    ret
  %1 = load float, float* @gf
  %2 = tail call float asm "fadd.s $0, $1, $2", "=f,f,f"(float %a, float %1)
  ret float %2
}

define float @constraint_f_float_abi_name(float %a) nounwind {
; RV32F-LABEL: constraint_f_float_abi_name:
; RV32F:       # %bb.0:
; RV32F-NEXT:    lui a1, %hi(gf)
; RV32F-NEXT:    flw fs0, %lo(gf)(a1)
; RV32F-NEXT:    fmv.w.x fa0, a0
; RV32F-NEXT:    #APP
; RV32F-NEXT:    fadd.s ft0, fa0, fs0
; RV32F-NEXT:    #NO_APP
; RV32F-NEXT:    fmv.x.w a0, ft0
; RV32F-NEXT:    ret
;
; RV64F-LABEL: constraint_f_float_abi_name:
; RV64F:       # %bb.0:
; RV64F-NEXT:    lui a1, %hi(gf)
; RV64F-NEXT:    flw fs0, %lo(gf)(a1)
; RV64F-NEXT:    fmv.w.x fa0, a0
; RV64F-NEXT:    #APP
; RV64F-NEXT:    fadd.s ft0, fa0, fs0
; RV64F-NEXT:    #NO_APP
; RV64F-NEXT:    fmv.x.w a0, ft0
; RV64F-NEXT:    ret
  %1 = load float, float* @gf
  %2 = tail call float asm "fadd.s $0, $1, $2", "={ft0},{fa0},{fs0}"(float %a, float %1)
  ret float %2
}
