; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=i386-unknown-linux-gnu -mattr=-slow-incdec < %s | FileCheck -check-prefix=CHECK -check-prefix=INCDEC %s
; RUN: llc -mtriple=i386-unknown-linux-gnu -mattr=+slow-incdec < %s | FileCheck -check-prefix=CHECK -check-prefix=ADD %s

define i32 @inc(i32 %x) {
; INCDEC-LABEL: inc:
; INCDEC:       # BB#0:
; INCDEC-NEXT:    movl {{[0-9]+}}(%esp), %eax
; INCDEC-NEXT:    incl %eax
; INCDEC-NEXT:    retl
;
; ADD-LABEL: inc:
; ADD:       # BB#0:
; ADD-NEXT:    movl {{[0-9]+}}(%esp), %eax
; ADD-NEXT:    addl $1, %eax
; ADD-NEXT:    retl
  %r = add i32 %x, 1
  ret i32 %r
}

define i32 @dec(i32 %x) {
; INCDEC-LABEL: dec:
; INCDEC:       # BB#0:
; INCDEC-NEXT:    movl {{[0-9]+}}(%esp), %eax
; INCDEC-NEXT:    decl %eax
; INCDEC-NEXT:    retl
;
; ADD-LABEL: dec:
; ADD:       # BB#0:
; ADD-NEXT:    movl {{[0-9]+}}(%esp), %eax
; ADD-NEXT:    addl $-1, %eax
; ADD-NEXT:    retl
  %r = add i32 %x, -1
  ret i32 %r
}

define i32 @inc_size(i32 %x) optsize {
; CHECK-LABEL: inc_size:
; CHECK:       # BB#0:
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    incl %eax
; CHECK-NEXT:    retl
  %r = add i32 %x, 1
  ret i32 %r
}

define i32 @dec_size(i32 %x) optsize {
; CHECK-LABEL: dec_size:
; CHECK:       # BB#0:
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    decl %eax
; CHECK-NEXT:    retl
  %r = add i32 %x, -1
  ret i32 %r
}
