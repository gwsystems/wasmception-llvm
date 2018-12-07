# NOTE: Assertions have been autogenerated by utils/update_mca_test_checks.py
# RUN: llvm-mca -march=aarch64 -mcpu=exynos-m1 -resource-pressure=false < %s | FileCheck %s -check-prefixes=ALL,M1
# RUN: llvm-mca -march=aarch64 -mcpu=exynos-m3 -resource-pressure=false < %s | FileCheck %s -check-prefixes=ALL,M3

1:
  b	1b

# ALL:      Iterations:        100
# ALL-NEXT: Instructions:      100

# M1-NEXT:  Total Cycles:      26
# M3-NEXT:  Total Cycles:      18

# ALL-NEXT: Total uOps:        100

# M1:       Dispatch Width:    4
# M1-NEXT:  uOps Per Cycle:    3.85
# M1-NEXT:  IPC:               3.85
# M1-NEXT:  Block RThroughput: 0.3

# M3:       Dispatch Width:    6
# M3-NEXT:  uOps Per Cycle:    5.56
# M3-NEXT:  IPC:               5.56
# M3-NEXT:  Block RThroughput: 0.2

# ALL:      Instruction Info:
# ALL-NEXT: [1]: #uOps
# ALL-NEXT: [2]: Latency
# ALL-NEXT: [3]: RThroughput
# ALL-NEXT: [4]: MayLoad
# ALL-NEXT: [5]: MayStore
# ALL-NEXT: [6]: HasSideEffects (U)

# ALL:      [1]    [2]    [3]    [4]    [5]    [6]    Instructions:

# M1-NEXT:   1      0     0.25                        b	.Ltmp0
# M3-NEXT:   1      0     0.17                        b	.Ltmp0
