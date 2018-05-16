# NOTE: Assertions have been autogenerated by utils/update_mca_test_checks.py
# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=slm -instruction-tables < %s | FileCheck %s

popcntw     %cx, %cx
popcntw     (%rax), %cx

popcntl     %eax, %ecx
popcntl     (%rax), %ecx

popcntq     %rax, %rcx
popcntq     (%rax), %rcx

# CHECK:      Instruction Info:
# CHECK-NEXT: [1]: #uOps
# CHECK-NEXT: [2]: Latency
# CHECK-NEXT: [3]: RThroughput
# CHECK-NEXT: [4]: MayLoad
# CHECK-NEXT: [5]: MayStore
# CHECK-NEXT: [6]: HasSideEffects

# CHECK:      [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT:  1      3     1.00                        popcntw	%cx, %cx
# CHECK-NEXT:  1      6     1.00    *                   popcntw	(%rax), %cx
# CHECK-NEXT:  1      3     1.00                        popcntl	%eax, %ecx
# CHECK-NEXT:  1      6     1.00    *                   popcntl	(%rax), %ecx
# CHECK-NEXT:  1      3     1.00                        popcntq	%rax, %rcx
# CHECK-NEXT:  1      6     1.00    *                   popcntq	(%rax), %rcx

# CHECK:      Resources:
# CHECK-NEXT: [0]   - SLMDivider
# CHECK-NEXT: [1]   - SLMFPDivider
# CHECK-NEXT: [2]   - SLMFPMultiplier
# CHECK-NEXT: [3]   - SLM_FPC_RSV0
# CHECK-NEXT: [4]   - SLM_FPC_RSV1
# CHECK-NEXT: [5]   - SLM_IEC_RSV0
# CHECK-NEXT: [6]   - SLM_IEC_RSV1
# CHECK-NEXT: [7]   - SLM_MEC_RSV

# CHECK:      Resource pressure per iteration:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]
# CHECK-NEXT:  -      -      -      -      -     6.00    -     3.00

# CHECK:      Resource pressure by instruction:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    Instructions:
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -     popcntw	%cx, %cx
# CHECK-NEXT:  -      -      -      -      -     1.00    -     1.00   popcntw	(%rax), %cx
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -     popcntl	%eax, %ecx
# CHECK-NEXT:  -      -      -      -      -     1.00    -     1.00   popcntl	(%rax), %ecx
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -     popcntq	%rax, %rcx
# CHECK-NEXT:  -      -      -      -      -     1.00    -     1.00   popcntq	(%rax), %rcx

