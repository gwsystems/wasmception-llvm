# NOTE: Assertions have been autogenerated by utils/update_mca_test_checks.py
# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=btver2 -all-stats -dispatch-stats=false < %s | FileCheck %s -check-prefix=ALL
# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=btver2 -all-stats                       < %s | FileCheck %s -check-prefix=ALL -check-prefix=FULL
# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=btver2 -all-stats -dispatch-stats       < %s | FileCheck %s -check-prefix=ALL -check-prefix=FULL
# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=btver2 -dispatch-stats -all-stats       < %s | FileCheck %s -check-prefix=ALL -check-prefix=FULL
# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=btver2 -dispatch-stats=false -all-stats < %s | FileCheck %s -check-prefix=ALL -check-prefix=FULL

add %eax, %eax

# ALL:       Iterations:        100
# ALL-NEXT:  Instructions:      100
# ALL-NEXT:  Total Cycles:      103
# ALL-NEXT:  Dispatch Width:    2
# ALL-NEXT:  IPC:               0.97
# ALL-NEXT:  Block RThroughput: 0.5

# ALL:       Instruction Info:
# ALL-NEXT:  [1]: #uOps
# ALL-NEXT:  [2]: Latency
# ALL-NEXT:  [3]: RThroughput
# ALL-NEXT:  [4]: MayLoad
# ALL-NEXT:  [5]: MayStore
# ALL-NEXT:  [6]: HasSideEffects

# ALL:       [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# ALL-NEXT:   1      1     0.50                        addl	%eax, %eax

# FULL:      Dynamic Dispatch Stall Cycles:
# FULL-NEXT: RAT     - Register unavailable:                      0
# FULL-NEXT: RCU     - Retire tokens unavailable:                 0
# FULL-NEXT: SCHEDQ  - Scheduler full:                            61
# FULL-NEXT: LQ      - Load queue full:                           0
# FULL-NEXT: SQ      - Store queue full:                          0
# FULL-NEXT: GROUP   - Static restrictions on the dispatch group: 0

# FULL:      Dispatch Logic - number of cycles where we saw N instructions dispatched:
# FULL-NEXT: [# dispatched], [# cycles]
# FULL-NEXT:  0,              22  (21.4%)
# FULL-NEXT:  2,              19  (18.4%)
# FULL-NEXT:  1,              62  (60.2%)

# FULL:      Schedulers - number of cycles where we saw N instructions issued:
# FULL-NEXT: [# issued], [# cycles]
# FULL-NEXT:  0,          3  (2.9%)
# FULL-NEXT:  1,          100  (97.1%)

# FULL:      Scheduler's queue usage:
# FULL-NEXT: JALU01,  20/20
# FULL-NEXT: JFPU01,  0/18
# FULL-NEXT: JLSAGU,  0/12

# FULL:      Retire Control Unit - number of cycles where we saw N instructions retired:
# FULL-NEXT: [# retired], [# cycles]
# FULL-NEXT:  0,           3  (2.9%)
# FULL-NEXT:  1,           100  (97.1%)

# FULL:      Register File statistics:
# FULL-NEXT: Total number of mappings created:    200
# FULL-NEXT: Max number of mappings used:         44

# FULL:      *  Register File #1 -- JFpuPRF:
# FULL-NEXT:    Number of physical registers:     72
# FULL-NEXT:    Total number of mappings created: 0
# FULL-NEXT:    Max number of mappings used:      0

# FULL:      *  Register File #2 -- JIntegerPRF:
# FULL-NEXT:    Number of physical registers:     64
# FULL-NEXT:    Total number of mappings created: 200
# FULL-NEXT:    Max number of mappings used:      44

# FULL:      Resources:
# FULL-NEXT: [0]   - JALU0
# FULL-NEXT: [1]   - JALU1
# FULL-NEXT: [2]   - JDiv
# FULL-NEXT: [3]   - JFPA
# FULL-NEXT: [4]   - JFPM
# FULL-NEXT: [5]   - JFPU0
# FULL-NEXT: [6]   - JFPU1
# FULL-NEXT: [7]   - JLAGU
# FULL-NEXT: [8]   - JMul
# FULL-NEXT: [9]   - JSAGU
# FULL-NEXT: [10]  - JSTC
# FULL-NEXT: [11]  - JVALU0
# FULL-NEXT: [12]  - JVALU1
# FULL-NEXT: [13]  - JVIMUL

# FULL:      Resource pressure per iteration:
# FULL-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    [10]   [11]   [12]   [13]
# FULL-NEXT: 0.50   0.50    -      -      -      -      -      -      -      -      -      -      -      -

# FULL:      Resource pressure by instruction:
# FULL-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    [10]   [11]   [12]   [13]   Instructions:
# FULL-NEXT: 0.50   0.50    -      -      -      -      -      -      -      -      -      -      -      -     addl	%eax, %eax

