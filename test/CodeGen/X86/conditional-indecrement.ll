; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=x86_64-unknown-unknown < %s | FileCheck %s

define i32 @test1(i32 %a, i32 %b) nounwind readnone {
; CHECK-LABEL: test1:
; CHECK:       # BB#0:
; CHECK-NEXT:    cmpl $1, %edi
; CHECK-NEXT:    sbbl $-1, %esi
; CHECK-NEXT:    movl %esi, %eax
; CHECK-NEXT:    retq
  %not.cmp = icmp ne i32 %a, 0
  %inc = zext i1 %not.cmp to i32
  %retval.0 = add i32 %inc, %b
  ret i32 %retval.0
}

define i32 @test2(i32 %a, i32 %b) nounwind readnone {
; CHECK-LABEL: test2:
; CHECK:       # BB#0:
; CHECK-NEXT:    cmpl $1, %edi
; CHECK-NEXT:    adcl $0, %esi
; CHECK-NEXT:    movl %esi, %eax
; CHECK-NEXT:    retq
  %cmp = icmp eq i32 %a, 0
  %inc = zext i1 %cmp to i32
  %retval.0 = add i32 %inc, %b
  ret i32 %retval.0
}

define i32 @test3(i32 %a, i32 %b) nounwind readnone {
; CHECK-LABEL: test3:
; CHECK:       # BB#0:
; CHECK-NEXT:    cmpl $1, %edi
; CHECK-NEXT:    adcl $0, %esi
; CHECK-NEXT:    movl %esi, %eax
; CHECK-NEXT:    retq
  %cmp = icmp eq i32 %a, 0
  %inc = zext i1 %cmp to i32
  %retval.0 = add i32 %inc, %b
  ret i32 %retval.0
}

define i32 @test4(i32 %a, i32 %b) nounwind readnone {
; CHECK-LABEL: test4:
; CHECK:       # BB#0:
; CHECK-NEXT:    cmpl $1, %edi
; CHECK-NEXT:    sbbl $-1, %esi
; CHECK-NEXT:    movl %esi, %eax
; CHECK-NEXT:    retq
  %not.cmp = icmp ne i32 %a, 0
  %inc = zext i1 %not.cmp to i32
  %retval.0 = add i32 %inc, %b
  ret i32 %retval.0
}

define i32 @test5(i32 %a, i32 %b) nounwind readnone {
; CHECK-LABEL: test5:
; CHECK:       # BB#0:
; CHECK-NEXT:    cmpl $1, %edi
; CHECK-NEXT:    adcl $-1, %esi
; CHECK-NEXT:    movl %esi, %eax
; CHECK-NEXT:    retq
  %not.cmp = icmp ne i32 %a, 0
  %inc = zext i1 %not.cmp to i32
  %retval.0 = sub i32 %b, %inc
  ret i32 %retval.0
}

define i32 @test6(i32 %a, i32 %b) nounwind readnone {
; CHECK-LABEL: test6:
; CHECK:       # BB#0:
; CHECK-NEXT:    cmpl $1, %edi
; CHECK-NEXT:    sbbl $0, %esi
; CHECK-NEXT:    movl %esi, %eax
; CHECK-NEXT:    retq
  %cmp = icmp eq i32 %a, 0
  %inc = zext i1 %cmp to i32
  %retval.0 = sub i32 %b, %inc
  ret i32 %retval.0
}

define i32 @test7(i32 %a, i32 %b) nounwind readnone {
; CHECK-LABEL: test7:
; CHECK:       # BB#0:
; CHECK-NEXT:    cmpl $1, %edi
; CHECK-NEXT:    sbbl $0, %esi
; CHECK-NEXT:    movl %esi, %eax
; CHECK-NEXT:    retq
  %cmp = icmp eq i32 %a, 0
  %inc = zext i1 %cmp to i32
  %retval.0 = sub i32 %b, %inc
  ret i32 %retval.0
}

define i32 @test8(i32 %a, i32 %b) nounwind readnone {
; CHECK-LABEL: test8:
; CHECK:       # BB#0:
; CHECK-NEXT:    cmpl $1, %edi
; CHECK-NEXT:    adcl $-1, %esi
; CHECK-NEXT:    movl %esi, %eax
; CHECK-NEXT:    retq
  %not.cmp = icmp ne i32 %a, 0
  %inc = zext i1 %not.cmp to i32
  %retval.0 = sub i32 %b, %inc
  ret i32 %retval.0
}
