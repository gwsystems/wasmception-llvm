; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mcpu=generic -mtriple=x86_64-linux | FileCheck %s

@c = external local_unnamed_addr global i32, align 4
@b = external local_unnamed_addr global i32, align 4
@d = external local_unnamed_addr global i32, align 4

define void @fn1() {
; CHECK-LABEL: fn1:
; CHECK:       # %bb.0:
; CHECK-NEXT:    cmpl $1, {{.*}}(%rip)
; CHECK-NEXT:    sbbl %eax, %eax
; CHECK-NEXT:    andl $1, %eax
; CHECK-NEXT:    movl %eax, {{.*}}(%rip)
; CHECK-NEXT:    retq
  %t0 = load i32, i32* @c, align 4
  %tobool1 = icmp eq i32 %t0, 0
  %xor = zext i1 %tobool1 to i32
  %t1 = load i32, i32* @b, align 4
  %tobool2 = icmp ne i32 %t1, 0
  %t2 = load i32, i32* @d, align 4
  %tobool4 = icmp ne i32 %t2, 0
  %t3 = and i1 %tobool4, %tobool2
  %sub = sext i1 %t3 to i32
  %div = sdiv i32 %sub, 2
  %add = add nsw i32 %div, %xor
  store i32 %add, i32* @d, align 4
  ret void
}
