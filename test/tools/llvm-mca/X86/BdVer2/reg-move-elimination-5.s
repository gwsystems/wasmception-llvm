# NOTE: Assertions have been autogenerated by utils/update_mca_test_checks.py
# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=bdver2 -iterations=3 -timeline -register-file-stats < %s | FileCheck %s

xor %rax, %rax
mov %rax, %rbx
mov %rbx, %rcx
mov %rcx, %rdx
mov %rdx, %rax

# CHECK:      Iterations:        3
# CHECK-NEXT: Instructions:      15
# CHECK-NEXT: Total Cycles:      15
# CHECK-NEXT: Total uOps:        15

# CHECK:      Dispatch Width:    4
# CHECK-NEXT: uOps Per Cycle:    1.00
# CHECK-NEXT: IPC:               1.00
# CHECK-NEXT: Block RThroughput: 4.0

# CHECK:      Instruction Info:
# CHECK-NEXT: [1]: #uOps
# CHECK-NEXT: [2]: Latency
# CHECK-NEXT: [3]: RThroughput
# CHECK-NEXT: [4]: MayLoad
# CHECK-NEXT: [5]: MayStore
# CHECK-NEXT: [6]: HasSideEffects (U)

# CHECK:      [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT:  1      0     0.25                        xorq	%rax, %rax
# CHECK-NEXT:  1      1     1.00                        movq	%rax, %rbx
# CHECK-NEXT:  1      1     1.00                        movq	%rbx, %rcx
# CHECK-NEXT:  1      1     1.00                        movq	%rcx, %rdx
# CHECK-NEXT:  1      1     1.00                        movq	%rdx, %rax

# CHECK:      Register File statistics:
# CHECK-NEXT: Total number of mappings created:    12
# CHECK-NEXT: Max number of mappings used:         11

# CHECK:      *  Register File #1 -- PdFpuPRF:
# CHECK-NEXT:    Number of physical registers:     160
# CHECK-NEXT:    Total number of mappings created: 0
# CHECK-NEXT:    Max number of mappings used:      0

# CHECK:      *  Register File #2 -- PdIntegerPRF:
# CHECK-NEXT:    Number of physical registers:     96
# CHECK-NEXT:    Total number of mappings created: 12
# CHECK-NEXT:    Max number of mappings used:      11

# CHECK:      Resources:
# CHECK-NEXT: [0.0] - PdAGLU01
# CHECK-NEXT: [0.1] - PdAGLU01
# CHECK-NEXT: [1]   - PdBranch
# CHECK-NEXT: [2]   - PdCount
# CHECK-NEXT: [3]   - PdDiv
# CHECK-NEXT: [4]   - PdEX0
# CHECK-NEXT: [5]   - PdEX1
# CHECK-NEXT: [6]   - PdFPCVT
# CHECK-NEXT: [7.0] - PdFPFMA
# CHECK-NEXT: [7.1] - PdFPFMA
# CHECK-NEXT: [8.0] - PdFPMAL
# CHECK-NEXT: [8.1] - PdFPMAL
# CHECK-NEXT: [9]   - PdFPMMA
# CHECK-NEXT: [10]  - PdFPSTO
# CHECK-NEXT: [11]  - PdFPU0
# CHECK-NEXT: [12]  - PdFPU1
# CHECK-NEXT: [13]  - PdFPU2
# CHECK-NEXT: [14]  - PdFPU3
# CHECK-NEXT: [15]  - PdFPXBR
# CHECK-NEXT: [16.0] - PdLoad
# CHECK-NEXT: [16.1] - PdLoad
# CHECK-NEXT: [17]  - PdMul
# CHECK-NEXT: [18]  - PdStore

# CHECK:      Resource pressure per iteration:
# CHECK-NEXT: [0.0]  [0.1]  [1]    [2]    [3]    [4]    [5]    [6]    [7.0]  [7.1]  [8.0]  [8.1]  [9]    [10]   [11]   [12]   [13]   [14]   [15]   [16.0] [16.1] [17]   [18]
# CHECK-NEXT:  -      -      -      -      -     4.00   4.00    -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -

# CHECK:      Resource pressure by instruction:
# CHECK-NEXT: [0.0]  [0.1]  [1]    [2]    [3]    [4]    [5]    [6]    [7.0]  [7.1]  [8.0]  [8.1]  [9]    [10]   [11]   [12]   [13]   [14]   [15]   [16.0] [16.1] [17]   [18]   Instructions:
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -     xorq	%rax, %rax
# CHECK-NEXT:  -      -      -      -      -      -     2.00    -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -     movq	%rax, %rbx
# CHECK-NEXT:  -      -      -      -      -     2.00    -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -     movq	%rbx, %rcx
# CHECK-NEXT:  -      -      -      -      -      -     2.00    -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -     movq	%rcx, %rdx
# CHECK-NEXT:  -      -      -      -      -     2.00    -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -     movq	%rdx, %rax

# CHECK:      Timeline view:
# CHECK-NEXT:                     01234
# CHECK-NEXT: Index     0123456789

# CHECK:      [0,0]     DR   .    .   .   xorq	%rax, %rax
# CHECK-NEXT: [0,1]     DeER .    .   .   movq	%rax, %rbx
# CHECK-NEXT: [0,2]     D=eER.    .   .   movq	%rbx, %rcx
# CHECK-NEXT: [0,3]     D==eER    .   .   movq	%rcx, %rdx
# CHECK-NEXT: [0,4]     .D==eER   .   .   movq	%rdx, %rax
# CHECK-NEXT: [1,0]     .D----R   .   .   xorq	%rax, %rax
# CHECK-NEXT: [1,1]     .D===eER  .   .   movq	%rax, %rbx
# CHECK-NEXT: [1,2]     .D====eER .   .   movq	%rbx, %rcx
# CHECK-NEXT: [1,3]     . D====eER.   .   movq	%rcx, %rdx
# CHECK-NEXT: [1,4]     . D=====eER   .   movq	%rdx, %rax
# CHECK-NEXT: [2,0]     . D-------R   .   xorq	%rax, %rax
# CHECK-NEXT: [2,1]     . D======eER  .   movq	%rax, %rbx
# CHECK-NEXT: [2,2]     .  D======eER .   movq	%rbx, %rcx
# CHECK-NEXT: [2,3]     .  D=======eER.   movq	%rcx, %rdx
# CHECK-NEXT: [2,4]     .  D========eER   movq	%rdx, %rax

# CHECK:      Average Wait times (based on the timeline view):
# CHECK-NEXT: [0]: Executions
# CHECK-NEXT: [1]: Average time spent waiting in a scheduler's queue
# CHECK-NEXT: [2]: Average time spent waiting in a scheduler's queue while ready
# CHECK-NEXT: [3]: Average time elapsed from WB until retire stage

# CHECK:            [0]    [1]    [2]    [3]
# CHECK-NEXT: 0.     3     0.0    0.0    3.7       xorq	%rax, %rax
# CHECK-NEXT: 1.     3     4.0    4.0    0.0       movq	%rax, %rbx
# CHECK-NEXT: 2.     3     4.7    0.0    0.0       movq	%rbx, %rcx
# CHECK-NEXT: 3.     3     5.3    0.0    0.0       movq	%rcx, %rdx
# CHECK-NEXT: 4.     3     6.0    0.0    0.0       movq	%rdx, %rax
# CHECK-NEXT:        3     4.0    0.8    0.7       <total>
