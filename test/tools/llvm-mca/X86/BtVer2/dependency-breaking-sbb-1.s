# NOTE: Assertions have been autogenerated by utils/update_mca_test_checks.py
# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=btver2 -timeline -timeline-max-iterations=3 -iterations=1500 < %s | FileCheck %s

# perf stat reports an IPC of 1.00 for this code block.

# Although both SBB are dependency breaking instructions, there is still an
# implicit dependency on EFLAGS which limits the ILP. So, the hardware backend
# can only execute one instruction per cycle.

sbb %edx, %edx
sbb %eax, %eax

# CHECK:      Iterations:        1500
# CHECK-NEXT: Instructions:      3000
# CHECK-NEXT: Total Cycles:      3003
# CHECK-NEXT: Dispatch Width:    2
# CHECK-NEXT: IPC:               1.00
# CHECK-NEXT: Block RThroughput: 2.0

# CHECK:      Instruction Info:
# CHECK-NEXT: [1]: #uOps
# CHECK-NEXT: [2]: Latency
# CHECK-NEXT: [3]: RThroughput
# CHECK-NEXT: [4]: MayLoad
# CHECK-NEXT: [5]: MayStore
# CHECK-NEXT: [6]: HasSideEffects (U)

# CHECK:      [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT:  1      1     1.00                        sbbl	%edx, %edx
# CHECK-NEXT:  1      1     1.00                        sbbl	%eax, %eax

# CHECK:      Resources:
# CHECK-NEXT: [0]   - JALU0
# CHECK-NEXT: [1]   - JALU1
# CHECK-NEXT: [2]   - JDiv
# CHECK-NEXT: [3]   - JFPA
# CHECK-NEXT: [4]   - JFPM
# CHECK-NEXT: [5]   - JFPU0
# CHECK-NEXT: [6]   - JFPU1
# CHECK-NEXT: [7]   - JLAGU
# CHECK-NEXT: [8]   - JMul
# CHECK-NEXT: [9]   - JSAGU
# CHECK-NEXT: [10]  - JSTC
# CHECK-NEXT: [11]  - JVALU0
# CHECK-NEXT: [12]  - JVALU1
# CHECK-NEXT: [13]  - JVIMUL

# CHECK:      Resource pressure per iteration:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    [10]   [11]   [12]   [13]
# CHECK-NEXT: 2.00   2.00    -      -      -      -      -      -      -      -      -      -      -      -

# CHECK:      Resource pressure by instruction:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    [10]   [11]   [12]   [13]   Instructions:
# CHECK-NEXT:  -     2.00    -      -      -      -      -      -      -      -      -      -      -      -     sbbl	%edx, %edx
# CHECK-NEXT: 2.00    -      -      -      -      -      -      -      -      -      -      -      -      -     sbbl	%eax, %eax

# CHECK:      Timeline view:
# CHECK-NEXT: Index     012345678

# CHECK:      [0,0]     DeER .  .   sbbl	%edx, %edx
# CHECK-NEXT: [0,1]     D=eER.  .   sbbl	%eax, %eax
# CHECK-NEXT: [1,0]     .D=eER  .   sbbl	%edx, %edx
# CHECK-NEXT: [1,1]     .D==eER .   sbbl	%eax, %eax
# CHECK-NEXT: [2,0]     . D==eER.   sbbl	%edx, %edx
# CHECK-NEXT: [2,1]     . D===eER   sbbl	%eax, %eax

# CHECK:      Average Wait times (based on the timeline view):
# CHECK-NEXT: [0]: Executions
# CHECK-NEXT: [1]: Average time spent waiting in a scheduler's queue
# CHECK-NEXT: [2]: Average time spent waiting in a scheduler's queue while ready
# CHECK-NEXT: [3]: Average time elapsed from WB until retire stage

# CHECK:            [0]    [1]    [2]    [3]
# CHECK-NEXT: 0.     3     2.0    0.3    0.0       sbbl	%edx, %edx
# CHECK-NEXT: 1.     3     3.0    0.0    0.0       sbbl	%eax, %eax
