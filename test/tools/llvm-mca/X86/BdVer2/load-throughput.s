# NOTE: Assertions have been autogenerated by utils/update_mca_test_checks.py
# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=bdver2 -scheduler-stats -dispatch-stats -iterations=100 -timeline -timeline-max-iterations=1 < %s | FileCheck %s

# LLVM-MCA-BEGIN
movb (%rax), %spl
movb (%rcx), %bpl
movb (%rdx), %sil
movb (%rbx), %dil
# LLVM-MCA-END

# LLVM-MCA-BEGIN
movw (%rax), %sp
movw (%rcx), %bp
movw (%rdx), %si
movw (%rbx), %di
# LLVM-MCA-END

# LLVM-MCA-BEGIN
movl (%rax), %esp
movl (%rcx), %ebp
movl (%rdx), %esi
movl (%rbx), %edi
# LLVM-MCA-END

# LLVM-MCA-BEGIN
movq (%rax), %rsp
movq (%rcx), %rbp
movq (%rdx), %rsi
movq (%rbx), %rdi
# LLVM-MCA-END

# LLVM-MCA-BEGIN
movd (%rax), %mm0
movd (%rcx), %mm1
movd (%rdx), %mm2
movd (%rbx), %mm3
# LLVM-MCA-END

# LLVM-MCA-BEGIN
movaps (%rax), %xmm0
movaps (%rcx), %xmm1
movaps (%rdx), %xmm2
movaps (%rbx), %xmm3
# LLVM-MCA-END

# LLVM-MCA-BEGIN
vmovaps (%rax), %ymm0
vmovaps (%rcx), %ymm1
vmovaps (%rdx), %ymm2
vmovaps (%rbx), %ymm3
# LLVM-MCA-END

# CHECK:      [0] Code Region

# CHECK:      Iterations:        100
# CHECK-NEXT: Instructions:      400
# CHECK-NEXT: Total Cycles:      406
# CHECK-NEXT: Total uOps:        400

# CHECK:      Dispatch Width:    4
# CHECK-NEXT: uOps Per Cycle:    0.99
# CHECK-NEXT: IPC:               0.99
# CHECK-NEXT: Block RThroughput: 4.0

# CHECK:      Instruction Info:
# CHECK-NEXT: [1]: #uOps
# CHECK-NEXT: [2]: Latency
# CHECK-NEXT: [3]: RThroughput
# CHECK-NEXT: [4]: MayLoad
# CHECK-NEXT: [5]: MayStore
# CHECK-NEXT: [6]: HasSideEffects (U)

# CHECK:      [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT:  1      5     1.00    *                   movb	(%rax), %spl
# CHECK-NEXT:  1      5     1.00    *                   movb	(%rcx), %bpl
# CHECK-NEXT:  1      5     1.00    *                   movb	(%rdx), %sil
# CHECK-NEXT:  1      5     1.00    *                   movb	(%rbx), %dil

# CHECK:      Dynamic Dispatch Stall Cycles:
# CHECK-NEXT: RAT     - Register unavailable:                      0
# CHECK-NEXT: RCU     - Retire tokens unavailable:                 0
# CHECK-NEXT: SCHEDQ  - Scheduler full:                            0
# CHECK-NEXT: LQ      - Load queue full:                           353  (86.9%)
# CHECK-NEXT: SQ      - Store queue full:                          0
# CHECK-NEXT: GROUP   - Static restrictions on the dispatch group: 0

# CHECK:      Dispatch Logic - number of cycles where we saw N micro opcodes dispatched:
# CHECK-NEXT: [# dispatched], [# cycles]
# CHECK-NEXT:  0,              217  (53.4%)
# CHECK-NEXT:  2,              178  (43.8%)
# CHECK-NEXT:  4,              11  (2.7%)

# CHECK:      Schedulers - number of cycles where we saw N micro opcodes issued:
# CHECK-NEXT: [# issued], [# cycles]
# CHECK-NEXT:  0,          206  (50.7%)
# CHECK-NEXT:  2,          200  (49.3%)

# CHECK:      Scheduler's queue usage:
# CHECK-NEXT: [1] Resource name.
# CHECK-NEXT: [2] Average number of used buffer entries.
# CHECK-NEXT: [3] Maximum number of used buffer entries.
# CHECK-NEXT: [4] Total number of buffer entries.

# CHECK:       [1]            [2]        [3]        [4]
# CHECK-NEXT: PdEX             32         36         40
# CHECK-NEXT: PdFPU            0          0          64
# CHECK-NEXT: PdLoad           37         40         40
# CHECK-NEXT: PdStore          0          0          24

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
# CHECK-NEXT: 4.00   4.00    -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -     4.00   4.00    -      -

# CHECK:      Resource pressure by instruction:
# CHECK-NEXT: [0.0]  [0.1]  [1]    [2]    [3]    [4]    [5]    [6]    [7.0]  [7.1]  [8.0]  [8.1]  [9]    [10]   [11]   [12]   [13]   [14]   [15]   [16.0] [16.1] [17]   [18]   Instructions:
# CHECK-NEXT:  -     2.00    -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -     2.00    -      -     movb	(%rax), %spl
# CHECK-NEXT: 2.00    -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -     2.00    -      -      -     movb	(%rcx), %bpl
# CHECK-NEXT:  -     2.00    -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -     2.00    -      -     movb	(%rdx), %sil
# CHECK-NEXT: 2.00    -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -     2.00    -      -      -     movb	(%rbx), %dil

# CHECK:      Timeline view:
# CHECK-NEXT: Index     0123456789

# CHECK:      [0,0]     DeeeeeER .   movb	(%rax), %spl
# CHECK-NEXT: [0,1]     DeeeeeER .   movb	(%rcx), %bpl
# CHECK-NEXT: [0,2]     D==eeeeeER   movb	(%rdx), %sil
# CHECK-NEXT: [0,3]     D==eeeeeER   movb	(%rbx), %dil

# CHECK:      Average Wait times (based on the timeline view):
# CHECK-NEXT: [0]: Executions
# CHECK-NEXT: [1]: Average time spent waiting in a scheduler's queue
# CHECK-NEXT: [2]: Average time spent waiting in a scheduler's queue while ready
# CHECK-NEXT: [3]: Average time elapsed from WB until retire stage

# CHECK:            [0]    [1]    [2]    [3]
# CHECK-NEXT: 0.     1     1.0    1.0    0.0       movb	(%rax), %spl
# CHECK-NEXT: 1.     1     1.0    1.0    0.0       movb	(%rcx), %bpl
# CHECK-NEXT: 2.     1     3.0    3.0    0.0       movb	(%rdx), %sil
# CHECK-NEXT: 3.     1     3.0    3.0    0.0       movb	(%rbx), %dil

# CHECK:      [1] Code Region

# CHECK:      Iterations:        100
# CHECK-NEXT: Instructions:      400
# CHECK-NEXT: Total Cycles:      406
# CHECK-NEXT: Total uOps:        400

# CHECK:      Dispatch Width:    4
# CHECK-NEXT: uOps Per Cycle:    0.99
# CHECK-NEXT: IPC:               0.99
# CHECK-NEXT: Block RThroughput: 4.0

# CHECK:      Instruction Info:
# CHECK-NEXT: [1]: #uOps
# CHECK-NEXT: [2]: Latency
# CHECK-NEXT: [3]: RThroughput
# CHECK-NEXT: [4]: MayLoad
# CHECK-NEXT: [5]: MayStore
# CHECK-NEXT: [6]: HasSideEffects (U)

# CHECK:      [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT:  1      5     1.00    *                   movw	(%rax), %sp
# CHECK-NEXT:  1      5     1.00    *                   movw	(%rcx), %bp
# CHECK-NEXT:  1      5     1.00    *                   movw	(%rdx), %si
# CHECK-NEXT:  1      5     1.00    *                   movw	(%rbx), %di

# CHECK:      Dynamic Dispatch Stall Cycles:
# CHECK-NEXT: RAT     - Register unavailable:                      0
# CHECK-NEXT: RCU     - Retire tokens unavailable:                 0
# CHECK-NEXT: SCHEDQ  - Scheduler full:                            0
# CHECK-NEXT: LQ      - Load queue full:                           353  (86.9%)
# CHECK-NEXT: SQ      - Store queue full:                          0
# CHECK-NEXT: GROUP   - Static restrictions on the dispatch group: 0

# CHECK:      Dispatch Logic - number of cycles where we saw N micro opcodes dispatched:
# CHECK-NEXT: [# dispatched], [# cycles]
# CHECK-NEXT:  0,              217  (53.4%)
# CHECK-NEXT:  2,              178  (43.8%)
# CHECK-NEXT:  4,              11  (2.7%)

# CHECK:      Schedulers - number of cycles where we saw N micro opcodes issued:
# CHECK-NEXT: [# issued], [# cycles]
# CHECK-NEXT:  0,          206  (50.7%)
# CHECK-NEXT:  2,          200  (49.3%)

# CHECK:      Scheduler's queue usage:
# CHECK-NEXT: [1] Resource name.
# CHECK-NEXT: [2] Average number of used buffer entries.
# CHECK-NEXT: [3] Maximum number of used buffer entries.
# CHECK-NEXT: [4] Total number of buffer entries.

# CHECK:       [1]            [2]        [3]        [4]
# CHECK-NEXT: PdEX             32         36         40
# CHECK-NEXT: PdFPU            0          0          64
# CHECK-NEXT: PdLoad           37         40         40
# CHECK-NEXT: PdStore          0          0          24

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
# CHECK-NEXT: 4.00   4.00    -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -     4.00   4.00    -      -

# CHECK:      Resource pressure by instruction:
# CHECK-NEXT: [0.0]  [0.1]  [1]    [2]    [3]    [4]    [5]    [6]    [7.0]  [7.1]  [8.0]  [8.1]  [9]    [10]   [11]   [12]   [13]   [14]   [15]   [16.0] [16.1] [17]   [18]   Instructions:
# CHECK-NEXT:  -     2.00    -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -     2.00    -      -     movw	(%rax), %sp
# CHECK-NEXT: 2.00    -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -     2.00    -      -      -     movw	(%rcx), %bp
# CHECK-NEXT:  -     2.00    -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -     2.00    -      -     movw	(%rdx), %si
# CHECK-NEXT: 2.00    -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -     2.00    -      -      -     movw	(%rbx), %di

# CHECK:      Timeline view:
# CHECK-NEXT: Index     0123456789

# CHECK:      [0,0]     DeeeeeER .   movw	(%rax), %sp
# CHECK-NEXT: [0,1]     DeeeeeER .   movw	(%rcx), %bp
# CHECK-NEXT: [0,2]     D==eeeeeER   movw	(%rdx), %si
# CHECK-NEXT: [0,3]     D==eeeeeER   movw	(%rbx), %di

# CHECK:      Average Wait times (based on the timeline view):
# CHECK-NEXT: [0]: Executions
# CHECK-NEXT: [1]: Average time spent waiting in a scheduler's queue
# CHECK-NEXT: [2]: Average time spent waiting in a scheduler's queue while ready
# CHECK-NEXT: [3]: Average time elapsed from WB until retire stage

# CHECK:            [0]    [1]    [2]    [3]
# CHECK-NEXT: 0.     1     1.0    1.0    0.0       movw	(%rax), %sp
# CHECK-NEXT: 1.     1     1.0    1.0    0.0       movw	(%rcx), %bp
# CHECK-NEXT: 2.     1     3.0    3.0    0.0       movw	(%rdx), %si
# CHECK-NEXT: 3.     1     3.0    3.0    0.0       movw	(%rbx), %di

# CHECK:      [2] Code Region

# CHECK:      Iterations:        100
# CHECK-NEXT: Instructions:      400
# CHECK-NEXT: Total Cycles:      406
# CHECK-NEXT: Total uOps:        400

# CHECK:      Dispatch Width:    4
# CHECK-NEXT: uOps Per Cycle:    0.99
# CHECK-NEXT: IPC:               0.99
# CHECK-NEXT: Block RThroughput: 4.0

# CHECK:      Instruction Info:
# CHECK-NEXT: [1]: #uOps
# CHECK-NEXT: [2]: Latency
# CHECK-NEXT: [3]: RThroughput
# CHECK-NEXT: [4]: MayLoad
# CHECK-NEXT: [5]: MayStore
# CHECK-NEXT: [6]: HasSideEffects (U)

# CHECK:      [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT:  1      5     1.00    *                   movl	(%rax), %esp
# CHECK-NEXT:  1      5     1.00    *                   movl	(%rcx), %ebp
# CHECK-NEXT:  1      5     1.00    *                   movl	(%rdx), %esi
# CHECK-NEXT:  1      5     1.00    *                   movl	(%rbx), %edi

# CHECK:      Dynamic Dispatch Stall Cycles:
# CHECK-NEXT: RAT     - Register unavailable:                      0
# CHECK-NEXT: RCU     - Retire tokens unavailable:                 0
# CHECK-NEXT: SCHEDQ  - Scheduler full:                            0
# CHECK-NEXT: LQ      - Load queue full:                           353  (86.9%)
# CHECK-NEXT: SQ      - Store queue full:                          0
# CHECK-NEXT: GROUP   - Static restrictions on the dispatch group: 0

# CHECK:      Dispatch Logic - number of cycles where we saw N micro opcodes dispatched:
# CHECK-NEXT: [# dispatched], [# cycles]
# CHECK-NEXT:  0,              217  (53.4%)
# CHECK-NEXT:  2,              178  (43.8%)
# CHECK-NEXT:  4,              11  (2.7%)

# CHECK:      Schedulers - number of cycles where we saw N micro opcodes issued:
# CHECK-NEXT: [# issued], [# cycles]
# CHECK-NEXT:  0,          206  (50.7%)
# CHECK-NEXT:  2,          200  (49.3%)

# CHECK:      Scheduler's queue usage:
# CHECK-NEXT: [1] Resource name.
# CHECK-NEXT: [2] Average number of used buffer entries.
# CHECK-NEXT: [3] Maximum number of used buffer entries.
# CHECK-NEXT: [4] Total number of buffer entries.

# CHECK:       [1]            [2]        [3]        [4]
# CHECK-NEXT: PdEX             32         36         40
# CHECK-NEXT: PdFPU            0          0          64
# CHECK-NEXT: PdLoad           37         40         40
# CHECK-NEXT: PdStore          0          0          24

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
# CHECK-NEXT: 4.00   4.00    -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -     4.00   4.00    -      -

# CHECK:      Resource pressure by instruction:
# CHECK-NEXT: [0.0]  [0.1]  [1]    [2]    [3]    [4]    [5]    [6]    [7.0]  [7.1]  [8.0]  [8.1]  [9]    [10]   [11]   [12]   [13]   [14]   [15]   [16.0] [16.1] [17]   [18]   Instructions:
# CHECK-NEXT:  -     2.00    -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -     2.00    -      -     movl	(%rax), %esp
# CHECK-NEXT: 2.00    -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -     2.00    -      -      -     movl	(%rcx), %ebp
# CHECK-NEXT:  -     2.00    -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -     2.00    -      -     movl	(%rdx), %esi
# CHECK-NEXT: 2.00    -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -     2.00    -      -      -     movl	(%rbx), %edi

# CHECK:      Timeline view:
# CHECK-NEXT: Index     0123456789

# CHECK:      [0,0]     DeeeeeER .   movl	(%rax), %esp
# CHECK-NEXT: [0,1]     DeeeeeER .   movl	(%rcx), %ebp
# CHECK-NEXT: [0,2]     D==eeeeeER   movl	(%rdx), %esi
# CHECK-NEXT: [0,3]     D==eeeeeER   movl	(%rbx), %edi

# CHECK:      Average Wait times (based on the timeline view):
# CHECK-NEXT: [0]: Executions
# CHECK-NEXT: [1]: Average time spent waiting in a scheduler's queue
# CHECK-NEXT: [2]: Average time spent waiting in a scheduler's queue while ready
# CHECK-NEXT: [3]: Average time elapsed from WB until retire stage

# CHECK:            [0]    [1]    [2]    [3]
# CHECK-NEXT: 0.     1     1.0    1.0    0.0       movl	(%rax), %esp
# CHECK-NEXT: 1.     1     1.0    1.0    0.0       movl	(%rcx), %ebp
# CHECK-NEXT: 2.     1     3.0    3.0    0.0       movl	(%rdx), %esi
# CHECK-NEXT: 3.     1     3.0    3.0    0.0       movl	(%rbx), %edi

# CHECK:      [3] Code Region

# CHECK:      Iterations:        100
# CHECK-NEXT: Instructions:      400
# CHECK-NEXT: Total Cycles:      406
# CHECK-NEXT: Total uOps:        400

# CHECK:      Dispatch Width:    4
# CHECK-NEXT: uOps Per Cycle:    0.99
# CHECK-NEXT: IPC:               0.99
# CHECK-NEXT: Block RThroughput: 4.0

# CHECK:      Instruction Info:
# CHECK-NEXT: [1]: #uOps
# CHECK-NEXT: [2]: Latency
# CHECK-NEXT: [3]: RThroughput
# CHECK-NEXT: [4]: MayLoad
# CHECK-NEXT: [5]: MayStore
# CHECK-NEXT: [6]: HasSideEffects (U)

# CHECK:      [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT:  1      5     1.00    *                   movq	(%rax), %rsp
# CHECK-NEXT:  1      5     1.00    *                   movq	(%rcx), %rbp
# CHECK-NEXT:  1      5     1.00    *                   movq	(%rdx), %rsi
# CHECK-NEXT:  1      5     1.00    *                   movq	(%rbx), %rdi

# CHECK:      Dynamic Dispatch Stall Cycles:
# CHECK-NEXT: RAT     - Register unavailable:                      0
# CHECK-NEXT: RCU     - Retire tokens unavailable:                 0
# CHECK-NEXT: SCHEDQ  - Scheduler full:                            0
# CHECK-NEXT: LQ      - Load queue full:                           353  (86.9%)
# CHECK-NEXT: SQ      - Store queue full:                          0
# CHECK-NEXT: GROUP   - Static restrictions on the dispatch group: 0

# CHECK:      Dispatch Logic - number of cycles where we saw N micro opcodes dispatched:
# CHECK-NEXT: [# dispatched], [# cycles]
# CHECK-NEXT:  0,              217  (53.4%)
# CHECK-NEXT:  2,              178  (43.8%)
# CHECK-NEXT:  4,              11  (2.7%)

# CHECK:      Schedulers - number of cycles where we saw N micro opcodes issued:
# CHECK-NEXT: [# issued], [# cycles]
# CHECK-NEXT:  0,          206  (50.7%)
# CHECK-NEXT:  2,          200  (49.3%)

# CHECK:      Scheduler's queue usage:
# CHECK-NEXT: [1] Resource name.
# CHECK-NEXT: [2] Average number of used buffer entries.
# CHECK-NEXT: [3] Maximum number of used buffer entries.
# CHECK-NEXT: [4] Total number of buffer entries.

# CHECK:       [1]            [2]        [3]        [4]
# CHECK-NEXT: PdEX             32         36         40
# CHECK-NEXT: PdFPU            0          0          64
# CHECK-NEXT: PdLoad           37         40         40
# CHECK-NEXT: PdStore          0          0          24

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
# CHECK-NEXT: 4.00   4.00    -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -     4.00   4.00    -      -

# CHECK:      Resource pressure by instruction:
# CHECK-NEXT: [0.0]  [0.1]  [1]    [2]    [3]    [4]    [5]    [6]    [7.0]  [7.1]  [8.0]  [8.1]  [9]    [10]   [11]   [12]   [13]   [14]   [15]   [16.0] [16.1] [17]   [18]   Instructions:
# CHECK-NEXT:  -     2.00    -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -     2.00    -      -     movq	(%rax), %rsp
# CHECK-NEXT: 2.00    -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -     2.00    -      -      -     movq	(%rcx), %rbp
# CHECK-NEXT:  -     2.00    -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -     2.00    -      -     movq	(%rdx), %rsi
# CHECK-NEXT: 2.00    -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -     2.00    -      -      -     movq	(%rbx), %rdi

# CHECK:      Timeline view:
# CHECK-NEXT: Index     0123456789

# CHECK:      [0,0]     DeeeeeER .   movq	(%rax), %rsp
# CHECK-NEXT: [0,1]     DeeeeeER .   movq	(%rcx), %rbp
# CHECK-NEXT: [0,2]     D==eeeeeER   movq	(%rdx), %rsi
# CHECK-NEXT: [0,3]     D==eeeeeER   movq	(%rbx), %rdi

# CHECK:      Average Wait times (based on the timeline view):
# CHECK-NEXT: [0]: Executions
# CHECK-NEXT: [1]: Average time spent waiting in a scheduler's queue
# CHECK-NEXT: [2]: Average time spent waiting in a scheduler's queue while ready
# CHECK-NEXT: [3]: Average time elapsed from WB until retire stage

# CHECK:            [0]    [1]    [2]    [3]
# CHECK-NEXT: 0.     1     1.0    1.0    0.0       movq	(%rax), %rsp
# CHECK-NEXT: 1.     1     1.0    1.0    0.0       movq	(%rcx), %rbp
# CHECK-NEXT: 2.     1     3.0    3.0    0.0       movq	(%rdx), %rsi
# CHECK-NEXT: 3.     1     3.0    3.0    0.0       movq	(%rbx), %rdi

# CHECK:      [4] Code Region

# CHECK:      Iterations:        100
# CHECK-NEXT: Instructions:      400
# CHECK-NEXT: Total Cycles:      605
# CHECK-NEXT: Total uOps:        400

# CHECK:      Dispatch Width:    4
# CHECK-NEXT: uOps Per Cycle:    0.66
# CHECK-NEXT: IPC:               0.66
# CHECK-NEXT: Block RThroughput: 6.0

# CHECK:      Instruction Info:
# CHECK-NEXT: [1]: #uOps
# CHECK-NEXT: [2]: Latency
# CHECK-NEXT: [3]: RThroughput
# CHECK-NEXT: [4]: MayLoad
# CHECK-NEXT: [5]: MayStore
# CHECK-NEXT: [6]: HasSideEffects (U)

# CHECK:      [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT:  1      5     1.50    *                   movd	(%rax), %mm0
# CHECK-NEXT:  1      5     1.50    *                   movd	(%rcx), %mm1
# CHECK-NEXT:  1      5     1.50    *                   movd	(%rdx), %mm2
# CHECK-NEXT:  1      5     1.50    *                   movd	(%rbx), %mm3

# CHECK:      Dynamic Dispatch Stall Cycles:
# CHECK-NEXT: RAT     - Register unavailable:                      0
# CHECK-NEXT: RCU     - Retire tokens unavailable:                 0
# CHECK-NEXT: SCHEDQ  - Scheduler full:                            0
# CHECK-NEXT: LQ      - Load queue full:                           532  (87.9%)
# CHECK-NEXT: SQ      - Store queue full:                          0
# CHECK-NEXT: GROUP   - Static restrictions on the dispatch group: 0

# CHECK:      Dispatch Logic - number of cycles where we saw N micro opcodes dispatched:
# CHECK-NEXT: [# dispatched], [# cycles]
# CHECK-NEXT:  0,              416  (68.8%)
# CHECK-NEXT:  2,              178  (29.4%)
# CHECK-NEXT:  4,              11  (1.8%)

# CHECK:      Schedulers - number of cycles where we saw N micro opcodes issued:
# CHECK-NEXT: [# issued], [# cycles]
# CHECK-NEXT:  0,          405  (66.9%)
# CHECK-NEXT:  2,          200  (33.1%)

# CHECK:      Scheduler's queue usage:
# CHECK-NEXT: [1] Resource name.
# CHECK-NEXT: [2] Average number of used buffer entries.
# CHECK-NEXT: [3] Maximum number of used buffer entries.
# CHECK-NEXT: [4] Total number of buffer entries.

# CHECK:       [1]            [2]        [3]        [4]
# CHECK-NEXT: PdEX             34         38         40
# CHECK-NEXT: PdFPU            34         38         64
# CHECK-NEXT: PdLoad           37         40         40
# CHECK-NEXT: PdStore          0          0          24

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
# CHECK-NEXT: 6.00   6.00    -      -      -      -      -      -      -      -     6.00   6.00    -      -     2.00   2.00    -      -      -     6.00   6.00    -      -

# CHECK:      Resource pressure by instruction:
# CHECK-NEXT: [0.0]  [0.1]  [1]    [2]    [3]    [4]    [5]    [6]    [7.0]  [7.1]  [8.0]  [8.1]  [9]    [10]   [11]   [12]   [13]   [14]   [15]   [16.0] [16.1] [17]   [18]   Instructions:
# CHECK-NEXT:  -     3.00    -      -      -      -      -      -      -      -      -     3.00    -      -      -     1.00    -      -      -      -     3.00    -      -     movd	(%rax), %mm0
# CHECK-NEXT: 3.00    -      -      -      -      -      -      -      -      -     3.00    -      -      -     1.00    -      -      -      -     3.00    -      -      -     movd	(%rcx), %mm1
# CHECK-NEXT:  -     3.00    -      -      -      -      -      -      -      -      -     3.00    -      -      -     1.00    -      -      -      -     3.00    -      -     movd	(%rdx), %mm2
# CHECK-NEXT: 3.00    -      -      -      -      -      -      -      -      -     3.00    -      -      -     1.00    -      -      -      -     3.00    -      -      -     movd	(%rbx), %mm3

# CHECK:      Timeline view:
# CHECK-NEXT:                     0
# CHECK-NEXT: Index     0123456789

# CHECK:      [0,0]     DeeeeeER  .   movd	(%rax), %mm0
# CHECK-NEXT: [0,1]     DeeeeeER  .   movd	(%rcx), %mm1
# CHECK-NEXT: [0,2]     D===eeeeeER   movd	(%rdx), %mm2
# CHECK-NEXT: [0,3]     D===eeeeeER   movd	(%rbx), %mm3

# CHECK:      Average Wait times (based on the timeline view):
# CHECK-NEXT: [0]: Executions
# CHECK-NEXT: [1]: Average time spent waiting in a scheduler's queue
# CHECK-NEXT: [2]: Average time spent waiting in a scheduler's queue while ready
# CHECK-NEXT: [3]: Average time elapsed from WB until retire stage

# CHECK:            [0]    [1]    [2]    [3]
# CHECK-NEXT: 0.     1     1.0    1.0    0.0       movd	(%rax), %mm0
# CHECK-NEXT: 1.     1     1.0    1.0    0.0       movd	(%rcx), %mm1
# CHECK-NEXT: 2.     1     4.0    4.0    0.0       movd	(%rdx), %mm2
# CHECK-NEXT: 3.     1     4.0    4.0    0.0       movd	(%rbx), %mm3

# CHECK:      [5] Code Region

# CHECK:      Iterations:        100
# CHECK-NEXT: Instructions:      400
# CHECK-NEXT: Total Cycles:      605
# CHECK-NEXT: Total uOps:        400

# CHECK:      Dispatch Width:    4
# CHECK-NEXT: uOps Per Cycle:    0.66
# CHECK-NEXT: IPC:               0.66
# CHECK-NEXT: Block RThroughput: 6.0

# CHECK:      Instruction Info:
# CHECK-NEXT: [1]: #uOps
# CHECK-NEXT: [2]: Latency
# CHECK-NEXT: [3]: RThroughput
# CHECK-NEXT: [4]: MayLoad
# CHECK-NEXT: [5]: MayStore
# CHECK-NEXT: [6]: HasSideEffects (U)

# CHECK:      [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT:  1      5     1.50    *                   movaps	(%rax), %xmm0
# CHECK-NEXT:  1      5     1.50    *                   movaps	(%rcx), %xmm1
# CHECK-NEXT:  1      5     1.50    *                   movaps	(%rdx), %xmm2
# CHECK-NEXT:  1      5     1.50    *                   movaps	(%rbx), %xmm3

# CHECK:      Dynamic Dispatch Stall Cycles:
# CHECK-NEXT: RAT     - Register unavailable:                      0
# CHECK-NEXT: RCU     - Retire tokens unavailable:                 0
# CHECK-NEXT: SCHEDQ  - Scheduler full:                            0
# CHECK-NEXT: LQ      - Load queue full:                           532  (87.9%)
# CHECK-NEXT: SQ      - Store queue full:                          0
# CHECK-NEXT: GROUP   - Static restrictions on the dispatch group: 0

# CHECK:      Dispatch Logic - number of cycles where we saw N micro opcodes dispatched:
# CHECK-NEXT: [# dispatched], [# cycles]
# CHECK-NEXT:  0,              416  (68.8%)
# CHECK-NEXT:  2,              178  (29.4%)
# CHECK-NEXT:  4,              11  (1.8%)

# CHECK:      Schedulers - number of cycles where we saw N micro opcodes issued:
# CHECK-NEXT: [# issued], [# cycles]
# CHECK-NEXT:  0,          405  (66.9%)
# CHECK-NEXT:  2,          200  (33.1%)

# CHECK:      Scheduler's queue usage:
# CHECK-NEXT: [1] Resource name.
# CHECK-NEXT: [2] Average number of used buffer entries.
# CHECK-NEXT: [3] Maximum number of used buffer entries.
# CHECK-NEXT: [4] Total number of buffer entries.

# CHECK:       [1]            [2]        [3]        [4]
# CHECK-NEXT: PdEX             34         38         40
# CHECK-NEXT: PdFPU            34         38         64
# CHECK-NEXT: PdLoad           37         40         40
# CHECK-NEXT: PdStore          0          0          24

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
# CHECK-NEXT: 6.00   6.00    -      -      -      -      -      -     6.00   6.00    -      -      -      -     2.00   2.00    -      -      -     6.00   6.00    -      -

# CHECK:      Resource pressure by instruction:
# CHECK-NEXT: [0.0]  [0.1]  [1]    [2]    [3]    [4]    [5]    [6]    [7.0]  [7.1]  [8.0]  [8.1]  [9]    [10]   [11]   [12]   [13]   [14]   [15]   [16.0] [16.1] [17]   [18]   Instructions:
# CHECK-NEXT:  -     3.00    -      -      -      -      -      -      -     3.00    -      -      -      -      -     1.00    -      -      -      -     3.00    -      -     movaps	(%rax), %xmm0
# CHECK-NEXT: 3.00    -      -      -      -      -      -      -     3.00    -      -      -      -      -     1.00    -      -      -      -     3.00    -      -      -     movaps	(%rcx), %xmm1
# CHECK-NEXT:  -     3.00    -      -      -      -      -      -      -     3.00    -      -      -      -      -     1.00    -      -      -      -     3.00    -      -     movaps	(%rdx), %xmm2
# CHECK-NEXT: 3.00    -      -      -      -      -      -      -     3.00    -      -      -      -      -     1.00    -      -      -      -     3.00    -      -      -     movaps	(%rbx), %xmm3

# CHECK:      Timeline view:
# CHECK-NEXT:                     0
# CHECK-NEXT: Index     0123456789

# CHECK:      [0,0]     DeeeeeER  .   movaps	(%rax), %xmm0
# CHECK-NEXT: [0,1]     DeeeeeER  .   movaps	(%rcx), %xmm1
# CHECK-NEXT: [0,2]     D===eeeeeER   movaps	(%rdx), %xmm2
# CHECK-NEXT: [0,3]     D===eeeeeER   movaps	(%rbx), %xmm3

# CHECK:      Average Wait times (based on the timeline view):
# CHECK-NEXT: [0]: Executions
# CHECK-NEXT: [1]: Average time spent waiting in a scheduler's queue
# CHECK-NEXT: [2]: Average time spent waiting in a scheduler's queue while ready
# CHECK-NEXT: [3]: Average time elapsed from WB until retire stage

# CHECK:            [0]    [1]    [2]    [3]
# CHECK-NEXT: 0.     1     1.0    1.0    0.0       movaps	(%rax), %xmm0
# CHECK-NEXT: 1.     1     1.0    1.0    0.0       movaps	(%rcx), %xmm1
# CHECK-NEXT: 2.     1     4.0    4.0    0.0       movaps	(%rdx), %xmm2
# CHECK-NEXT: 3.     1     4.0    4.0    0.0       movaps	(%rbx), %xmm3

# CHECK:      [6] Code Region

# CHECK:      Iterations:        100
# CHECK-NEXT: Instructions:      400
# CHECK-NEXT: Total Cycles:      605
# CHECK-NEXT: Total uOps:        800

# CHECK:      Dispatch Width:    4
# CHECK-NEXT: uOps Per Cycle:    1.32
# CHECK-NEXT: IPC:               0.66
# CHECK-NEXT: Block RThroughput: 6.0

# CHECK:      Instruction Info:
# CHECK-NEXT: [1]: #uOps
# CHECK-NEXT: [2]: Latency
# CHECK-NEXT: [3]: RThroughput
# CHECK-NEXT: [4]: MayLoad
# CHECK-NEXT: [5]: MayStore
# CHECK-NEXT: [6]: HasSideEffects (U)

# CHECK:      [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT:  2      5     1.50    *                   vmovaps	(%rax), %ymm0
# CHECK-NEXT:  2      5     1.50    *                   vmovaps	(%rcx), %ymm1
# CHECK-NEXT:  2      5     1.50    *                   vmovaps	(%rdx), %ymm2
# CHECK-NEXT:  2      5     1.50    *                   vmovaps	(%rbx), %ymm3

# CHECK:      Dynamic Dispatch Stall Cycles:
# CHECK-NEXT: RAT     - Register unavailable:                      0
# CHECK-NEXT: RCU     - Retire tokens unavailable:                 0
# CHECK-NEXT: SCHEDQ  - Scheduler full:                            0
# CHECK-NEXT: LQ      - Load queue full:                           344  (56.9%)
# CHECK-NEXT: SQ      - Store queue full:                          0
# CHECK-NEXT: GROUP   - Static restrictions on the dispatch group: 0

# CHECK:      Dispatch Logic - number of cycles where we saw N micro opcodes dispatched:
# CHECK-NEXT: [# dispatched], [# cycles]
# CHECK-NEXT:  0,              405  (66.9%)
# CHECK-NEXT:  4,              200  (33.1%)

# CHECK:      Schedulers - number of cycles where we saw N micro opcodes issued:
# CHECK-NEXT: [# issued], [# cycles]
# CHECK-NEXT:  0,          405  (66.9%)
# CHECK-NEXT:  4,          200  (33.1%)

# CHECK:      Scheduler's queue usage:
# CHECK-NEXT: [1] Resource name.
# CHECK-NEXT: [2] Average number of used buffer entries.
# CHECK-NEXT: [3] Maximum number of used buffer entries.
# CHECK-NEXT: [4] Total number of buffer entries.

# CHECK:       [1]            [2]        [3]        [4]
# CHECK-NEXT: PdEX             33         38         40
# CHECK-NEXT: PdFPU            33         38         64
# CHECK-NEXT: PdLoad           37         40         40
# CHECK-NEXT: PdStore          0          0          24

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
# CHECK-NEXT: 6.00   6.00    -      -      -      -      -      -     6.00   6.00    -      -      -      -     2.00   2.00    -      -      -     6.00   6.00    -      -

# CHECK:      Resource pressure by instruction:
# CHECK-NEXT: [0.0]  [0.1]  [1]    [2]    [3]    [4]    [5]    [6]    [7.0]  [7.1]  [8.0]  [8.1]  [9]    [10]   [11]   [12]   [13]   [14]   [15]   [16.0] [16.1] [17]   [18]   Instructions:
# CHECK-NEXT:  -     3.00    -      -      -      -      -      -      -     3.00    -      -      -      -      -     1.00    -      -      -      -     3.00    -      -     vmovaps	(%rax), %ymm0
# CHECK-NEXT: 3.00    -      -      -      -      -      -      -     3.00    -      -      -      -      -     1.00    -      -      -      -     3.00    -      -      -     vmovaps	(%rcx), %ymm1
# CHECK-NEXT:  -     3.00    -      -      -      -      -      -      -     3.00    -      -      -      -      -     1.00    -      -      -      -     3.00    -      -     vmovaps	(%rdx), %ymm2
# CHECK-NEXT: 3.00    -      -      -      -      -      -      -     3.00    -      -      -      -      -     1.00    -      -      -      -     3.00    -      -      -     vmovaps	(%rbx), %ymm3

# CHECK:      Timeline view:
# CHECK-NEXT:                     0
# CHECK-NEXT: Index     0123456789

# CHECK:      [0,0]     DeeeeeER  .   vmovaps	(%rax), %ymm0
# CHECK-NEXT: [0,1]     DeeeeeER  .   vmovaps	(%rcx), %ymm1
# CHECK-NEXT: [0,2]     .D==eeeeeER   vmovaps	(%rdx), %ymm2
# CHECK-NEXT: [0,3]     .D==eeeeeER   vmovaps	(%rbx), %ymm3

# CHECK:      Average Wait times (based on the timeline view):
# CHECK-NEXT: [0]: Executions
# CHECK-NEXT: [1]: Average time spent waiting in a scheduler's queue
# CHECK-NEXT: [2]: Average time spent waiting in a scheduler's queue while ready
# CHECK-NEXT: [3]: Average time elapsed from WB until retire stage

# CHECK:            [0]    [1]    [2]    [3]
# CHECK-NEXT: 0.     1     1.0    1.0    0.0       vmovaps	(%rax), %ymm0
# CHECK-NEXT: 1.     1     1.0    1.0    0.0       vmovaps	(%rcx), %ymm1
# CHECK-NEXT: 2.     1     3.0    3.0    0.0       vmovaps	(%rdx), %ymm2
# CHECK-NEXT: 3.     1     3.0    3.0    0.0       vmovaps	(%rbx), %ymm3
