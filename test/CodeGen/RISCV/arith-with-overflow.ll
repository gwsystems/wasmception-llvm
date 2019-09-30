; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=riscv32 -verify-machineinstrs < %s \
; RUN:   | FileCheck -check-prefix=RV32I %s

declare {i32, i1} @llvm.sadd.with.overflow.i32(i32 %a, i32 %b)
declare {i32, i1} @llvm.ssub.with.overflow.i32(i32 %a, i32 %b)
declare {i32, i1} @llvm.uadd.with.overflow.i32(i32 %a, i32 %b)
declare {i32, i1} @llvm.usub.with.overflow.i32(i32 %a, i32 %b)

define i1 @sadd(i32 %a, i32 %b, i32* %c) nounwind {
; RV32I-LABEL: sadd:
; RV32I:       # %bb.0: # %entry
; RV32I-NEXT:    add a3, a0, a1
; RV32I-NEXT:    slt a0, a3, a0
; RV32I-NEXT:    slti a1, a1, 0
; RV32I-NEXT:    xor a0, a1, a0
; RV32I-NEXT:    sw a3, 0(a2)
; RV32I-NEXT:    ret
entry:
  %x = call {i32, i1} @llvm.sadd.with.overflow.i32(i32 %a, i32 %b)
  %calc = extractvalue {i32, i1} %x, 0
  %ovf = extractvalue {i32, i1} %x, 1
  store i32 %calc, i32* %c
  ret i1 %ovf
}

define i1 @ssub(i32 %a, i32 %b, i32* %c) nounwind {
; RV32I-LABEL: ssub:
; RV32I:       # %bb.0: # %entry
; RV32I-NEXT:    sgtz a3, a1
; RV32I-NEXT:    sub a1, a0, a1
; RV32I-NEXT:    slt a0, a1, a0
; RV32I-NEXT:    xor a0, a3, a0
; RV32I-NEXT:    sw a1, 0(a2)
; RV32I-NEXT:    ret
entry:
  %x = call {i32, i1} @llvm.ssub.with.overflow.i32(i32 %a, i32 %b)
  %calc = extractvalue {i32, i1} %x, 0
  %ovf = extractvalue {i32, i1} %x, 1
  store i32 %calc, i32* %c
  ret i1 %ovf
}

define i1 @uadd(i32 %a, i32 %b, i32* %c) nounwind {
; RV32I-LABEL: uadd:
; RV32I:       # %bb.0: # %entry
; RV32I-NEXT:    add a1, a0, a1
; RV32I-NEXT:    sltu a0, a1, a0
; RV32I-NEXT:    sw a1, 0(a2)
; RV32I-NEXT:    ret
entry:
  %x = call {i32, i1} @llvm.uadd.with.overflow.i32(i32 %a, i32 %b)
  %calc = extractvalue {i32, i1} %x, 0
  %ovf = extractvalue {i32, i1} %x, 1
  store i32 %calc, i32* %c
  ret i1 %ovf
}

define i1 @usub(i32 %a, i32 %b, i32* %c) nounwind {
; RV32I-LABEL: usub:
; RV32I:       # %bb.0: # %entry
; RV32I-NEXT:    sub a1, a0, a1
; RV32I-NEXT:    sltu a0, a0, a1
; RV32I-NEXT:    sw a1, 0(a2)
; RV32I-NEXT:    ret
entry:
  %x = call {i32, i1} @llvm.usub.with.overflow.i32(i32 %a, i32 %b)
  %calc = extractvalue {i32, i1} %x, 0
  %ovf = extractvalue {i32, i1} %x, 1
  store i32 %calc, i32* %c
  ret i1 %ovf
}
