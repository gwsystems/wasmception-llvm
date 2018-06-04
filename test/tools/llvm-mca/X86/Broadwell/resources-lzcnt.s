# NOTE: Assertions have been autogenerated by utils/update_mca_test_checks.py
# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=broadwell -instruction-tables < %s | FileCheck %s

lzcntw      %cx, %cx
lzcntw      (%rax), %cx

lzcntl      %eax, %ecx
lzcntl      (%rax), %ecx

lzcntq      %rax, %rcx
lzcntq      (%rax), %rcx

# CHECK:      Instruction Info:
# CHECK-NEXT: [1]: #uOps
# CHECK-NEXT: [2]: Latency
# CHECK-NEXT: [3]: RThroughput
# CHECK-NEXT: [4]: MayLoad
# CHECK-NEXT: [5]: MayStore
# CHECK-NEXT: [6]: HasSideEffects

# CHECK:      [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT:  1      3     1.00                        lzcntw	%cx, %cx
# CHECK-NEXT:  2      8     1.00    *                   lzcntw	(%rax), %cx
# CHECK-NEXT:  1      3     1.00                        lzcntl	%eax, %ecx
# CHECK-NEXT:  2      8     1.00    *                   lzcntl	(%rax), %ecx
# CHECK-NEXT:  1      3     1.00                        lzcntq	%rax, %rcx
# CHECK-NEXT:  2      8     1.00    *                   lzcntq	(%rax), %rcx

# CHECK:      Resources:
# CHECK-NEXT: [0]   - BWDivider
# CHECK-NEXT: [1]   - BWFPDivider
# CHECK-NEXT: [2]   - BWPort0
# CHECK-NEXT: [3]   - BWPort1
# CHECK-NEXT: [4]   - BWPort2
# CHECK-NEXT: [5]   - BWPort3
# CHECK-NEXT: [6]   - BWPort4
# CHECK-NEXT: [7]   - BWPort5
# CHECK-NEXT: [8]   - BWPort6
# CHECK-NEXT: [9]   - BWPort7

# CHECK:      Resource pressure per iteration:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]
# CHECK-NEXT:  -      -      -     6.00   1.50   1.50    -      -      -      -

# CHECK:      Resource pressure by instruction:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    Instructions:
# CHECK-NEXT:  -      -      -     1.00    -      -      -      -      -      -     lzcntw	%cx, %cx
# CHECK-NEXT:  -      -      -     1.00   0.50   0.50    -      -      -      -     lzcntw	(%rax), %cx
# CHECK-NEXT:  -      -      -     1.00    -      -      -      -      -      -     lzcntl	%eax, %ecx
# CHECK-NEXT:  -      -      -     1.00   0.50   0.50    -      -      -      -     lzcntl	(%rax), %ecx
# CHECK-NEXT:  -      -      -     1.00    -      -      -      -      -      -     lzcntq	%rax, %rcx
# CHECK-NEXT:  -      -      -     1.00   0.50   0.50    -      -      -      -     lzcntq	(%rax), %rcx
