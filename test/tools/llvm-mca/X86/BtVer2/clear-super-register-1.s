# NOTE: Assertions have been autogenerated by utils/update_mca_test_checks.py
# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=btver2 -iterations=100 -resource-pressure=false -timeline -timeline-max-iterations=2 < %s | FileCheck %s

## Sets register RAX.
imulq $5, %rcx, %rax
  
## Kills the previous definition of RAX.
## The upper portion of RAX is cleared.
lzcnt %ecx, %eax

## The AND can start immediately after the LZCNT.
## It doesn't need to wait for the IMUL.
and   %rcx, %rax
bsf   %rax, %rcx

# CHECK:      Iterations:        100
# CHECK-NEXT: Instructions:      400
# CHECK-NEXT: Total Cycles:      1203
# CHECK-NEXT: Dispatch Width:    2
# CHECK-NEXT: IPC:               0.33
# CHECK-NEXT: Block RThroughput: 6.0

# CHECK:      Instruction Info:
# CHECK-NEXT: [1]: #uOps
# CHECK-NEXT: [2]: Latency
# CHECK-NEXT: [3]: RThroughput
# CHECK-NEXT: [4]: MayLoad
# CHECK-NEXT: [5]: MayStore
# CHECK-NEXT: [6]: HasSideEffects

# CHECK:      [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT:  2      6     4.00                        imulq	$5, %rcx, %rax
# CHECK-NEXT:  1      1     0.50                        lzcntl	%ecx, %eax
# CHECK-NEXT:  1      1     0.50                        andq	%rcx, %rax
# CHECK-NEXT:  8      5     2.00                        bsfq	%rax, %rcx

# CHECK:      Timeline view:
# CHECK-NEXT:                     0123456789
# CHECK-NEXT: Index     0123456789          0123456

# CHECK:      [0,0]     DeeeeeeER .    .    .    ..   imulq	$5, %rcx, %rax
# CHECK-NEXT: [0,1]     .DeE----R .    .    .    ..   lzcntl	%ecx, %eax
# CHECK-NEXT: [0,2]     .D=====eER.    .    .    ..   andq	%rcx, %rax
# CHECK-NEXT: [0,3]     . D=====eeeeeER.    .    ..   bsfq	%rax, %rcx
# CHECK-NEXT: [1,0]     .    .D======eeeeeeER    ..   imulq	$5, %rcx, %rax
# CHECK-NEXT: [1,1]     .    . D=====eE-----R    ..   lzcntl	%ecx, %eax
# CHECK-NEXT: [1,2]     .    . D===========eER   ..   andq	%rcx, %rax
# CHECK-NEXT: [1,3]     .    .  D===========eeeeeER   bsfq	%rax, %rcx

# CHECK:      Average Wait times (based on the timeline view):
# CHECK-NEXT: [0]: Executions
# CHECK-NEXT: [1]: Average time spent waiting in a scheduler's queue
# CHECK-NEXT: [2]: Average time spent waiting in a scheduler's queue while ready
# CHECK-NEXT: [3]: Average time elapsed from WB until retire stage

# CHECK:            [0]    [1]    [2]    [3]
# CHECK-NEXT: 0.     2     4.0    0.5    0.0       imulq	$5, %rcx, %rax
# CHECK-NEXT: 1.     2     3.5    0.5    4.5       lzcntl	%ecx, %eax
# CHECK-NEXT: 2.     2     9.0    0.0    0.0       andq	%rcx, %rax
# CHECK-NEXT: 3.     2     9.0    0.0    0.0       bsfq	%rax, %rcx
