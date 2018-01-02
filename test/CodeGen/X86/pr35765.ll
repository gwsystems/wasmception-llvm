; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=x86_64-unknown-linux-gnu %s -o - | FileCheck %s

@ll = local_unnamed_addr global i64 0, align 8
@x = local_unnamed_addr global i64 2651237805702985558, align 8
@s1 = local_unnamed_addr global { i8, i8 } { i8 123, i8 5 }, align 2
@s2 = local_unnamed_addr global { i8, i8 } { i8 -122, i8 3 }, align 2

define void @PR35765() {
; CHECK-LABEL: PR35765:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    movzwl {{.*}}(%rip), %ecx
; CHECK-NEXT:    addl $-1398, %ecx # imm = 0xFA8A
; CHECK-NEXT:    movl $4, %eax
; CHECK-NEXT:    # kill: def %cl killed %cl killed %ecx
; CHECK-NEXT:    shll %cl, %eax
; CHECK-NEXT:    movzwl {{.*}}(%rip), %ecx
; CHECK-NEXT:    movzwl {{.*}}(%rip), %edx
; CHECK-NEXT:    notl %edx
; CHECK-NEXT:    orl %ecx, %edx
; CHECK-NEXT:    orl $-2048, %edx # imm = 0xF800
; CHECK-NEXT:    xorl %eax, %edx
; CHECK-NEXT:    movslq %edx, %rax
; CHECK-NEXT:    movq %rax, {{.*}}(%rip)
; CHECK-NEXT:    retq
entry:
  %bf.load.i = load i16, i16* bitcast ({ i8, i8 }* @s1 to i16*), align 2
  %bf.clear.i = and i16 %bf.load.i, 2047
  %conv.i = zext i16 %bf.clear.i to i32
  %sub.i = add nsw i32 %conv.i, -1398
  %shl.i = shl i32 4, %sub.i
  %0 = load i64, i64* @x, align 8
  %bf.load1.i = load i16, i16* bitcast ({ i8, i8 }* @s2 to i16*), align 2
  %bf.clear2.i = and i16 %bf.load1.i, 2047
  %1 = xor i16 %bf.clear2.i, -1
  %neg.i = zext i16 %1 to i64
  %or.i = or i64 %0, %neg.i
  %conv5.i = trunc i64 %or.i to i32
  %conv6.i = and i32 %conv5.i, 65535
  %xor.i = xor i32 %conv6.i, %shl.i
  %conv7.i = sext i32 %xor.i to i64
  store i64 %conv7.i, i64* @ll, align 8
  ret void
}
