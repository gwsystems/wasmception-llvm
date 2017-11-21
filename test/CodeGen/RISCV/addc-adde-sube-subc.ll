; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=riscv32 -verify-machineinstrs < %s \
; RUN:   | FileCheck -check-prefix=RV32I %s

; Ensure that the ISDOpcodes ADDC, ADDE, SUBC, SUBE are handled correctly

define i64 @addc_adde(i64 %a, i64 %b) {
; RV32I-LABEL: addc_adde:
; RV32I:       # BB#0:
; RV32I-NEXT:    add a1, a1, a3
; RV32I-NEXT:    add a2, a0, a2
; RV32I-NEXT:    sltu a0, a2, a0
; RV32I-NEXT:    add a1, a1, a0
; RV32I-NEXT:    addi a0, a2, 0
; RV32I-NEXT:    jalr zero, ra, 0
  %1 = add i64 %a, %b
  ret i64 %1
}

define i64 @subc_sube(i64 %a, i64 %b) {
; RV32I-LABEL: subc_sube:
; RV32I:       # BB#0:
; RV32I-NEXT:    sub a1, a1, a3
; RV32I-NEXT:    sltu a3, a0, a2
; RV32I-NEXT:    sub a1, a1, a3
; RV32I-NEXT:    sub a0, a0, a2
; RV32I-NEXT:    jalr zero, ra, 0
  %1 = sub i64 %a, %b
  ret i64 %1
}
