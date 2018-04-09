# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=btver2 -iterations=1 -resource-pressure=false < %s | FileCheck %s

  add %esi, %edi
# LLVM-MCA-BEGIN foo
  add %edi, %eax

# CHECK:      [0] Code Region -  foo

# CHECK:      Iterations:     1
# CHECK-NEXT: Instructions:   1
# CHECK-NEXT: Total Cycles:   4
# CHECK-NEXT: Dispatch Width: 2
# CHECK-NEXT: IPC:            0.25

# CHECK:      Instruction Info:
# CHECK-NEXT: [1]: #uOps
# CHECK-NEXT: [2]: Latency
# CHECK-NEXT: [3]: RThroughput
# CHECK-NEXT: [4]: MayLoad
# CHECK-NEXT: [5]: MayStore
# CHECK-NEXT: [6]: HasSideEffects

# CHECK:      [1]    [2]    [3]    [4]    [5]    [6]	Instructions:
# CHECK-NEXT:  1      1     0.50                    	addl	%edi, %eax

