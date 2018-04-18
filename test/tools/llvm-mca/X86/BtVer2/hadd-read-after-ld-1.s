# NOTE: Assertions have been autogenerated by utils/update_mca_test_checks.py
# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=btver2 -iterations=1 -timeline -resource-pressure=false < %s | FileCheck %s

vshufps $0, %xmm0, %xmm1, %xmm1
vhaddps (%rdi), %xmm1, %xmm2

# CHECK:      Iterations:     1
# CHECK-NEXT: Instructions:   2
# CHECK-NEXT: Total Cycles:   11
# CHECK-NEXT: Dispatch Width: 2
# CHECK-NEXT: IPC:            0.18

# CHECK:      Instruction Info:
# CHECK-NEXT: [1]: #uOps
# CHECK-NEXT: [2]: Latency
# CHECK-NEXT: [3]: RThroughput
# CHECK-NEXT: [4]: MayLoad
# CHECK-NEXT: [5]: MayStore
# CHECK-NEXT: [6]: HasSideEffects

# CHECK:      [1]    [2]    [3]    [4]    [5]    [6]	Instructions:
# CHECK-NEXT:  1      1     0.50                    	vshufps	$0, %xmm0, %xmm1, %xmm1
# CHECK-NEXT:  1      8     1.00    *               	vhaddps	(%rdi), %xmm1, %xmm2

# CHECK:      Timeline view:
# CHECK-NEXT:      	          0
# CHECK-NEXT: Index	0123456789

# CHECK:      [0,0]	DeER .    .	vshufps	$0, %xmm0, %xmm1, %xmm1
# CHECK-NEXT: [0,1]	DeeeeeeeeER	vhaddps	(%rdi), %xmm1, %xmm2

# CHECK:      Average Wait times (based on the timeline view):
# CHECK-NEXT: [0]: Executions
# CHECK-NEXT: [1]: Average time spent waiting in a scheduler's queue
# CHECK-NEXT: [2]: Average time spent waiting in a scheduler's queue while ready
# CHECK-NEXT: [3]: Average time elapsed from WB until retire stage

# CHECK:            [0]    [1]    [2]    [3]
# CHECK-NEXT: 0.     1     1.0    1.0    0.0    	vshufps	$0, %xmm0, %xmm1, %xmm1
# CHECK-NEXT: 1.     1     1.0    0.0    0.0    	vhaddps	(%rdi), %xmm1, %xmm2

