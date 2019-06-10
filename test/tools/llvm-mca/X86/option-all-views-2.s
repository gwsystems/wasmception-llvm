# NOTE: Assertions have been autogenerated by utils/update_mca_test_checks.py
# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=btver2 -all-views                          < %s | FileCheck %s -check-prefix=ALL -check-prefix=FULLREPORT
# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=btver2 -all-views -resource-pressure       < %s | FileCheck %s -check-prefix=ALL -check-prefix=FULLREPORT
# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=btver2 -resource-pressure -all-views       < %s | FileCheck %s -check-prefix=ALL -check-prefix=FULLREPORT
# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=btver2 -resource-pressure=false -all-views < %s | FileCheck %s -check-prefix=ALL -check-prefix=FULLREPORT
# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=btver2 -all-views -resource-pressure=false < %s | FileCheck %s -check-prefix=ALL

add %eax, %eax

# ALL:             Iterations:        100
# ALL-NEXT:        Instructions:      100
# ALL-NEXT:        Total Cycles:      103
# ALL-NEXT:        Total uOps:        100

# ALL:             Dispatch Width:    2
# ALL-NEXT:        uOps Per Cycle:    0.97
# ALL-NEXT:        IPC:               0.97
# ALL-NEXT:        Block RThroughput: 0.5

# ALL:             Cycles with backend pressure increase [ 76.70% ]
# ALL-NEXT:        Throughput Bottlenecks:
# ALL-NEXT:          Resource Pressure       [ 0.00% ]
# ALL-NEXT:          Data Dependencies:      [ 76.70% ]
# ALL-NEXT:          - Register Dependencies [ 76.70% ]
# ALL-NEXT:          - Memory Dependencies   [ 0.00% ]

# ALL:             Instruction Info:
# ALL-NEXT:        [1]: #uOps
# ALL-NEXT:        [2]: Latency
# ALL-NEXT:        [3]: RThroughput
# ALL-NEXT:        [4]: MayLoad
# ALL-NEXT:        [5]: MayStore
# ALL-NEXT:        [6]: HasSideEffects (U)

# ALL:             [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# ALL-NEXT:         1      1     0.50                        addl	%eax, %eax

# ALL:             Dynamic Dispatch Stall Cycles:
# ALL-NEXT:        RAT     - Register unavailable:                      0
# ALL-NEXT:        RCU     - Retire tokens unavailable:                 0
# ALL-NEXT:        SCHEDQ  - Scheduler full:                            61  (59.2%)
# ALL-NEXT:        LQ      - Load queue full:                           0
# ALL-NEXT:        SQ      - Store queue full:                          0
# ALL-NEXT:        GROUP   - Static restrictions on the dispatch group: 0

# ALL:             Dispatch Logic - number of cycles where we saw N micro opcodes dispatched:
# ALL-NEXT:        [# dispatched], [# cycles]
# ALL-NEXT:         0,              22  (21.4%)
# ALL-NEXT:         1,              62  (60.2%)
# ALL-NEXT:         2,              19  (18.4%)

# ALL:             Schedulers - number of cycles where we saw N micro opcodes issued:
# ALL-NEXT:        [# issued], [# cycles]
# ALL-NEXT:         0,          3  (2.9%)
# ALL-NEXT:         1,          100  (97.1%)

# ALL:             Scheduler's queue usage:
# ALL-NEXT:        [1] Resource name.
# ALL-NEXT:        [2] Average number of used buffer entries.
# ALL-NEXT:        [3] Maximum number of used buffer entries.
# ALL-NEXT:        [4] Total number of buffer entries.

# ALL:              [1]            [2]        [3]        [4]
# ALL-NEXT:        JALU01           15         20         20
# ALL-NEXT:        JFPU01           0          0          18
# ALL-NEXT:        JLSAGU           0          0          12

# ALL:             Retire Control Unit - number of cycles where we saw N instructions retired:
# ALL-NEXT:        [# retired], [# cycles]
# ALL-NEXT:         0,           3  (2.9%)
# ALL-NEXT:         1,           100  (97.1%)

# ALL:             Total ROB Entries:                64
# ALL-NEXT:        Max Used ROB Entries:             22  ( 34.4% )
# ALL-NEXT:        Average Used ROB Entries per cy:  17  ( 26.6% )

# ALL:             Register File statistics:
# ALL-NEXT:        Total number of mappings created:    200
# ALL-NEXT:        Max number of mappings used:         44

# ALL:             *  Register File #1 -- JFpuPRF:
# ALL-NEXT:           Number of physical registers:     72
# ALL-NEXT:           Total number of mappings created: 0
# ALL-NEXT:           Max number of mappings used:      0

# ALL:             *  Register File #2 -- JIntegerPRF:
# ALL-NEXT:           Number of physical registers:     64
# ALL-NEXT:           Total number of mappings created: 200
# ALL-NEXT:           Max number of mappings used:      44

# FULLREPORT:      Resources:
# FULLREPORT-NEXT: [0]   - JALU0
# FULLREPORT-NEXT: [1]   - JALU1
# FULLREPORT-NEXT: [2]   - JDiv
# FULLREPORT-NEXT: [3]   - JFPA
# FULLREPORT-NEXT: [4]   - JFPM
# FULLREPORT-NEXT: [5]   - JFPU0
# FULLREPORT-NEXT: [6]   - JFPU1
# FULLREPORT-NEXT: [7]   - JLAGU
# FULLREPORT-NEXT: [8]   - JMul
# FULLREPORT-NEXT: [9]   - JSAGU
# FULLREPORT-NEXT: [10]  - JSTC
# FULLREPORT-NEXT: [11]  - JVALU0
# FULLREPORT-NEXT: [12]  - JVALU1
# FULLREPORT-NEXT: [13]  - JVIMUL

# FULLREPORT:      Resource pressure per iteration:
# FULLREPORT-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    [10]   [11]   [12]   [13]
# FULLREPORT-NEXT: 0.50   0.50    -      -      -      -      -      -      -      -      -      -      -      -

# FULLREPORT:      Resource pressure by instruction:
# FULLREPORT-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    [10]   [11]   [12]   [13]   Instructions:
# FULLREPORT-NEXT: 0.50   0.50    -      -      -      -      -      -      -      -      -      -      -      -     addl	%eax, %eax

# ALL:             Timeline view:
# ALL-NEXT:                            012
# ALL-NEXT:        Index     0123456789

# ALL:             [0,0]     DeER .    . .   addl	%eax, %eax
# ALL-NEXT:        [1,0]     D=eER.    . .   addl	%eax, %eax
# ALL-NEXT:        [2,0]     .D=eER    . .   addl	%eax, %eax
# ALL-NEXT:        [3,0]     .D==eER   . .   addl	%eax, %eax
# ALL-NEXT:        [4,0]     . D==eER  . .   addl	%eax, %eax
# ALL-NEXT:        [5,0]     . D===eER . .   addl	%eax, %eax
# ALL-NEXT:        [6,0]     .  D===eER. .   addl	%eax, %eax
# ALL-NEXT:        [7,0]     .  D====eER .   addl	%eax, %eax
# ALL-NEXT:        [8,0]     .   D====eER.   addl	%eax, %eax
# ALL-NEXT:        [9,0]     .   D=====eER   addl	%eax, %eax

# ALL:             Average Wait times (based on the timeline view):
# ALL-NEXT:        [0]: Executions
# ALL-NEXT:        [1]: Average time spent waiting in a scheduler's queue
# ALL-NEXT:        [2]: Average time spent waiting in a scheduler's queue while ready
# ALL-NEXT:        [3]: Average time elapsed from WB until retire stage

# ALL:                   [0]    [1]    [2]    [3]
# ALL-NEXT:        0.     10    3.5    0.1    0.0       addl	%eax, %eax
