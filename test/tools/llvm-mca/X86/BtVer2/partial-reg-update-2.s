# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=btver2 -iterations=1 -resource-pressure=false -timeline < %s | FileCheck %s

imul   %rax, %rbx
lzcnt  %ax,  %bx
add    %ecx, %ebx

# CHECK:      Iterations:        1
# CHECK-NEXT: Instructions:      3
# CHECK-NEXT: Total Cycles:      10
# CHECK-NEXT: Dispatch Width:    2
# CHECK-NEXT: IPC:               0.30
# CHECK-NEXT: Block RThroughput: 4.0

# CHECK:      Instruction Info:
# CHECK-NEXT: [1]: #uOps
# CHECK-NEXT: [2]: Latency
# CHECK-NEXT: [3]: RThroughput
# CHECK-NEXT: [4]: MayLoad
# CHECK-NEXT: [5]: MayStore
# CHECK-NEXT: [6]: HasSideEffects

# CHECK:      [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT:  2      6     4.00                        imulq	%rax, %rbx
# CHECK-NEXT:  1      1     0.50                        lzcntw	%ax, %bx
# CHECK-NEXT:  1      1     0.50                        addl	%ecx, %ebx

# CHECK:      Timeline view:
# CHECK-NEXT: Index     0123456789

# CHECK:      [0,0]     DeeeeeeER.   imulq	%rax, %rbx
# CHECK-NEXT: [0,1]     .DeE----R.   lzcntw	%ax, %bx
# CHECK-NEXT: [0,2]     .D=====eER   addl	%ecx, %ebx

# CHECK:      Average Wait times (based on the timeline view):
# CHECK-NEXT: [0]: Executions
# CHECK-NEXT: [1]: Average time spent waiting in a scheduler's queue
# CHECK-NEXT: [2]: Average time spent waiting in a scheduler's queue while ready
# CHECK-NEXT: [3]: Average time elapsed from WB until retire stage

# CHECK:            [0]    [1]    [2]    [3]
# CHECK-NEXT: 0.     1     1.0    1.0    0.0       imulq	%rax, %rbx
# CHECK-NEXT: 1.     1     1.0    1.0    4.0       lzcntw	%ax, %bx
# CHECK-NEXT: 2.     1     6.0    0.0    0.0       addl	%ecx, %ebx
