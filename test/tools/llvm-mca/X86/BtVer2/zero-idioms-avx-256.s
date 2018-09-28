# NOTE: Assertions have been autogenerated by utils/update_mca_test_checks.py
# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=btver2 -timeline -timeline-max-iterations=3 < %s | FileCheck %s

# TODO: Fix the processor resource usage for zero-idiom YMM XOR instructions.
#       Those vector XOR instructions should only consume 1cy of JFPU1 (instead
#       of 2cy).

# LLVM-MCA-BEGIN ZERO-IDIOM-1

vaddps %ymm0, %ymm0, %ymm1
vxorps %ymm1, %ymm1, %ymm1
vblendps $2, %ymm1, %ymm2, %ymm3

# LLVM-MCA-END

# LLVM-MCA-BEGIN ZERO-IDIOM-2

vaddpd %ymm0, %ymm0, %ymm1
vxorpd %ymm1, %ymm1, %ymm1
vblendpd $2, %ymm1, %ymm2, %ymm3

# LLVM-MCA-END

# LLVM-MCA-BEGIN ZERO-IDIOM-3
vaddps %ymm0, %ymm1, %ymm2
vandnps %ymm2, %ymm2, %ymm3
# LLVM-MCA-END

# LLVM-MCA-BEGIN ZERO-IDIOM-4
vaddps %ymm0, %ymm1, %ymm2
vandnps %ymm2, %ymm2, %ymm3
# LLVM-MCA-END

# LLVM-MCA-BEGIN ZERO-IDIOM-5
vperm2f128 $136, %ymm0, %ymm0, %ymm1
vaddps  %ymm1, %ymm1, %ymm0
# LLVM-MCA-END

# CHECK:      [0] Code Region - ZERO-IDIOM-1

# CHECK:      Iterations:        100
# CHECK-NEXT: Instructions:      300
# CHECK-NEXT: Total Cycles:      304
# CHECK-NEXT: Total uOps:        600

# CHECK:      Dispatch Width:    2
# CHECK-NEXT: uOps Per Cycle:    1.97
# CHECK-NEXT: IPC:               0.99
# CHECK-NEXT: Block RThroughput: 3.0

# CHECK:      Instruction Info:
# CHECK-NEXT: [1]: #uOps
# CHECK-NEXT: [2]: Latency
# CHECK-NEXT: [3]: RThroughput
# CHECK-NEXT: [4]: MayLoad
# CHECK-NEXT: [5]: MayStore
# CHECK-NEXT: [6]: HasSideEffects (U)

# CHECK:      [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT:  2      3     2.00                        vaddps	%ymm0, %ymm0, %ymm1
# CHECK-NEXT:  2      1     0.50                        vxorps	%ymm1, %ymm1, %ymm1
# CHECK-NEXT:  2      1     1.00                        vblendps	$2, %ymm1, %ymm2, %ymm3

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
# CHECK-NEXT:  -      -      -     3.00   2.00   3.00   2.00    -      -      -      -      -      -      -

# CHECK:      Resource pressure by instruction:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    [10]   [11]   [12]   [13]   Instructions:
# CHECK-NEXT:  -      -      -     2.00    -     2.00    -      -      -      -      -      -      -      -     vaddps	%ymm0, %ymm0, %ymm1
# CHECK-NEXT:  -      -      -      -     1.00    -     1.00    -      -      -      -      -      -      -     vxorps	%ymm1, %ymm1, %ymm1
# CHECK-NEXT:  -      -      -     1.00   1.00   1.00   1.00    -      -      -      -      -      -      -     vblendps	$2, %ymm1, %ymm2, %ymm3

# CHECK:      Timeline view:
# CHECK-NEXT:                     0123
# CHECK-NEXT: Index     0123456789

# CHECK:      [0,0]     DeeeER    .  .   vaddps	%ymm0, %ymm0, %ymm1
# CHECK-NEXT: [0,1]     .DeE-R    .  .   vxorps	%ymm1, %ymm1, %ymm1
# CHECK-NEXT: [0,2]     . DeE-R   .  .   vblendps	$2, %ymm1, %ymm2, %ymm3
# CHECK-NEXT: [1,0]     .  DeeeER .  .   vaddps	%ymm0, %ymm0, %ymm1
# CHECK-NEXT: [1,1]     .   DeE-R .  .   vxorps	%ymm1, %ymm1, %ymm1
# CHECK-NEXT: [1,2]     .    DeE-R.  .   vblendps	$2, %ymm1, %ymm2, %ymm3
# CHECK-NEXT: [2,0]     .    .D=eeeER.   vaddps	%ymm0, %ymm0, %ymm1
# CHECK-NEXT: [2,1]     .    . DeE--R.   vxorps	%ymm1, %ymm1, %ymm1
# CHECK-NEXT: [2,2]     .    .  DeE--R   vblendps	$2, %ymm1, %ymm2, %ymm3

# CHECK:      Average Wait times (based on the timeline view):
# CHECK-NEXT: [0]: Executions
# CHECK-NEXT: [1]: Average time spent waiting in a scheduler's queue
# CHECK-NEXT: [2]: Average time spent waiting in a scheduler's queue while ready
# CHECK-NEXT: [3]: Average time elapsed from WB until retire stage

# CHECK:            [0]    [1]    [2]    [3]
# CHECK-NEXT: 0.     3     1.3    1.3    0.0       vaddps	%ymm0, %ymm0, %ymm1
# CHECK-NEXT: 1.     3     1.0    1.0    1.3       vxorps	%ymm1, %ymm1, %ymm1
# CHECK-NEXT: 2.     3     1.0    0.0    1.3       vblendps	$2, %ymm1, %ymm2, %ymm3

# CHECK:      [1] Code Region - ZERO-IDIOM-2

# CHECK:      Iterations:        100
# CHECK-NEXT: Instructions:      300
# CHECK-NEXT: Total Cycles:      304
# CHECK-NEXT: Total uOps:        600

# CHECK:      Dispatch Width:    2
# CHECK-NEXT: uOps Per Cycle:    1.97
# CHECK-NEXT: IPC:               0.99
# CHECK-NEXT: Block RThroughput: 3.0

# CHECK:      Instruction Info:
# CHECK-NEXT: [1]: #uOps
# CHECK-NEXT: [2]: Latency
# CHECK-NEXT: [3]: RThroughput
# CHECK-NEXT: [4]: MayLoad
# CHECK-NEXT: [5]: MayStore
# CHECK-NEXT: [6]: HasSideEffects (U)

# CHECK:      [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT:  2      3     2.00                        vaddpd	%ymm0, %ymm0, %ymm1
# CHECK-NEXT:  2      1     0.50                        vxorpd	%ymm1, %ymm1, %ymm1
# CHECK-NEXT:  2      1     1.00                        vblendpd	$2, %ymm1, %ymm2, %ymm3

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
# CHECK-NEXT:  -      -      -     3.00   2.00   3.00   2.00    -      -      -      -      -      -      -

# CHECK:      Resource pressure by instruction:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    [10]   [11]   [12]   [13]   Instructions:
# CHECK-NEXT:  -      -      -     2.00    -     2.00    -      -      -      -      -      -      -      -     vaddpd	%ymm0, %ymm0, %ymm1
# CHECK-NEXT:  -      -      -      -     1.00    -     1.00    -      -      -      -      -      -      -     vxorpd	%ymm1, %ymm1, %ymm1
# CHECK-NEXT:  -      -      -     1.00   1.00   1.00   1.00    -      -      -      -      -      -      -     vblendpd	$2, %ymm1, %ymm2, %ymm3

# CHECK:      Timeline view:
# CHECK-NEXT:                     0123
# CHECK-NEXT: Index     0123456789

# CHECK:      [0,0]     DeeeER    .  .   vaddpd	%ymm0, %ymm0, %ymm1
# CHECK-NEXT: [0,1]     .DeE-R    .  .   vxorpd	%ymm1, %ymm1, %ymm1
# CHECK-NEXT: [0,2]     . DeE-R   .  .   vblendpd	$2, %ymm1, %ymm2, %ymm3
# CHECK-NEXT: [1,0]     .  DeeeER .  .   vaddpd	%ymm0, %ymm0, %ymm1
# CHECK-NEXT: [1,1]     .   DeE-R .  .   vxorpd	%ymm1, %ymm1, %ymm1
# CHECK-NEXT: [1,2]     .    DeE-R.  .   vblendpd	$2, %ymm1, %ymm2, %ymm3
# CHECK-NEXT: [2,0]     .    .D=eeeER.   vaddpd	%ymm0, %ymm0, %ymm1
# CHECK-NEXT: [2,1]     .    . DeE--R.   vxorpd	%ymm1, %ymm1, %ymm1
# CHECK-NEXT: [2,2]     .    .  DeE--R   vblendpd	$2, %ymm1, %ymm2, %ymm3

# CHECK:      Average Wait times (based on the timeline view):
# CHECK-NEXT: [0]: Executions
# CHECK-NEXT: [1]: Average time spent waiting in a scheduler's queue
# CHECK-NEXT: [2]: Average time spent waiting in a scheduler's queue while ready
# CHECK-NEXT: [3]: Average time elapsed from WB until retire stage

# CHECK:            [0]    [1]    [2]    [3]
# CHECK-NEXT: 0.     3     1.3    1.3    0.0       vaddpd	%ymm0, %ymm0, %ymm1
# CHECK-NEXT: 1.     3     1.0    1.0    1.3       vxorpd	%ymm1, %ymm1, %ymm1
# CHECK-NEXT: 2.     3     1.0    0.0    1.3       vblendpd	$2, %ymm1, %ymm2, %ymm3

# CHECK:      [2] Code Region - ZERO-IDIOM-3

# CHECK:      Iterations:        100
# CHECK-NEXT: Instructions:      200
# CHECK-NEXT: Total Cycles:      204
# CHECK-NEXT: Total uOps:        400

# CHECK:      Dispatch Width:    2
# CHECK-NEXT: uOps Per Cycle:    1.96
# CHECK-NEXT: IPC:               0.98
# CHECK-NEXT: Block RThroughput: 2.0

# CHECK:      Instruction Info:
# CHECK-NEXT: [1]: #uOps
# CHECK-NEXT: [2]: Latency
# CHECK-NEXT: [3]: RThroughput
# CHECK-NEXT: [4]: MayLoad
# CHECK-NEXT: [5]: MayStore
# CHECK-NEXT: [6]: HasSideEffects (U)

# CHECK:      [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT:  2      3     2.00                        vaddps	%ymm0, %ymm1, %ymm2
# CHECK-NEXT:  2      1     0.50                        vandnps	%ymm2, %ymm2, %ymm3

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
# CHECK-NEXT:  -      -      -     2.00   1.00   2.00   1.00    -      -      -      -      -      -      -

# CHECK:      Resource pressure by instruction:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    [10]   [11]   [12]   [13]   Instructions:
# CHECK-NEXT:  -      -      -     2.00    -     2.00    -      -      -      -      -      -      -      -     vaddps	%ymm0, %ymm1, %ymm2
# CHECK-NEXT:  -      -      -      -     1.00    -     1.00    -      -      -      -      -      -      -     vandnps	%ymm2, %ymm2, %ymm3

# CHECK:      Timeline view:
# CHECK-NEXT: Index     0123456789

# CHECK:      [0,0]     DeeeER   .   vaddps	%ymm0, %ymm1, %ymm2
# CHECK-NEXT: [0,1]     .DeE-R   .   vandnps	%ymm2, %ymm2, %ymm3
# CHECK-NEXT: [1,0]     . DeeeER .   vaddps	%ymm0, %ymm1, %ymm2
# CHECK-NEXT: [1,1]     .  DeE-R .   vandnps	%ymm2, %ymm2, %ymm3
# CHECK-NEXT: [2,0]     .   DeeeER   vaddps	%ymm0, %ymm1, %ymm2
# CHECK-NEXT: [2,1]     .    DeE-R   vandnps	%ymm2, %ymm2, %ymm3

# CHECK:      Average Wait times (based on the timeline view):
# CHECK-NEXT: [0]: Executions
# CHECK-NEXT: [1]: Average time spent waiting in a scheduler's queue
# CHECK-NEXT: [2]: Average time spent waiting in a scheduler's queue while ready
# CHECK-NEXT: [3]: Average time elapsed from WB until retire stage

# CHECK:            [0]    [1]    [2]    [3]
# CHECK-NEXT: 0.     3     1.0    1.0    0.0       vaddps	%ymm0, %ymm1, %ymm2
# CHECK-NEXT: 1.     3     1.0    1.0    1.0       vandnps	%ymm2, %ymm2, %ymm3

# CHECK:      [3] Code Region - ZERO-IDIOM-4

# CHECK:      Iterations:        100
# CHECK-NEXT: Instructions:      200
# CHECK-NEXT: Total Cycles:      204
# CHECK-NEXT: Total uOps:        400

# CHECK:      Dispatch Width:    2
# CHECK-NEXT: uOps Per Cycle:    1.96
# CHECK-NEXT: IPC:               0.98
# CHECK-NEXT: Block RThroughput: 2.0

# CHECK:      Instruction Info:
# CHECK-NEXT: [1]: #uOps
# CHECK-NEXT: [2]: Latency
# CHECK-NEXT: [3]: RThroughput
# CHECK-NEXT: [4]: MayLoad
# CHECK-NEXT: [5]: MayStore
# CHECK-NEXT: [6]: HasSideEffects (U)

# CHECK:      [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT:  2      3     2.00                        vaddps	%ymm0, %ymm1, %ymm2
# CHECK-NEXT:  2      1     0.50                        vandnps	%ymm2, %ymm2, %ymm3

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
# CHECK-NEXT:  -      -      -     2.00   1.00   2.00   1.00    -      -      -      -      -      -      -

# CHECK:      Resource pressure by instruction:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    [10]   [11]   [12]   [13]   Instructions:
# CHECK-NEXT:  -      -      -     2.00    -     2.00    -      -      -      -      -      -      -      -     vaddps	%ymm0, %ymm1, %ymm2
# CHECK-NEXT:  -      -      -      -     1.00    -     1.00    -      -      -      -      -      -      -     vandnps	%ymm2, %ymm2, %ymm3

# CHECK:      Timeline view:
# CHECK-NEXT: Index     0123456789

# CHECK:      [0,0]     DeeeER   .   vaddps	%ymm0, %ymm1, %ymm2
# CHECK-NEXT: [0,1]     .DeE-R   .   vandnps	%ymm2, %ymm2, %ymm3
# CHECK-NEXT: [1,0]     . DeeeER .   vaddps	%ymm0, %ymm1, %ymm2
# CHECK-NEXT: [1,1]     .  DeE-R .   vandnps	%ymm2, %ymm2, %ymm3
# CHECK-NEXT: [2,0]     .   DeeeER   vaddps	%ymm0, %ymm1, %ymm2
# CHECK-NEXT: [2,1]     .    DeE-R   vandnps	%ymm2, %ymm2, %ymm3

# CHECK:      Average Wait times (based on the timeline view):
# CHECK-NEXT: [0]: Executions
# CHECK-NEXT: [1]: Average time spent waiting in a scheduler's queue
# CHECK-NEXT: [2]: Average time spent waiting in a scheduler's queue while ready
# CHECK-NEXT: [3]: Average time elapsed from WB until retire stage

# CHECK:            [0]    [1]    [2]    [3]
# CHECK-NEXT: 0.     3     1.0    1.0    0.0       vaddps	%ymm0, %ymm1, %ymm2
# CHECK-NEXT: 1.     3     1.0    1.0    1.0       vandnps	%ymm2, %ymm2, %ymm3

# CHECK:      [4] Code Region - ZERO-IDIOM-5

# CHECK:      Iterations:        100
# CHECK-NEXT: Instructions:      200
# CHECK-NEXT: Total Cycles:      403
# CHECK-NEXT: Total uOps:        400

# CHECK:      Dispatch Width:    2
# CHECK-NEXT: uOps Per Cycle:    0.99
# CHECK-NEXT: IPC:               0.50
# CHECK-NEXT: Block RThroughput: 2.0

# CHECK:      Instruction Info:
# CHECK-NEXT: [1]: #uOps
# CHECK-NEXT: [2]: Latency
# CHECK-NEXT: [3]: RThroughput
# CHECK-NEXT: [4]: MayLoad
# CHECK-NEXT: [5]: MayStore
# CHECK-NEXT: [6]: HasSideEffects (U)

# CHECK:      [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT:  2      1     1.00                        vperm2f128	$136, %ymm0, %ymm0, %ymm1
# CHECK-NEXT:  2      3     2.00                        vaddps	%ymm1, %ymm1, %ymm0

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
# CHECK-NEXT:  -      -      -     2.00   2.00   2.00   2.00    -      -      -      -      -      -      -

# CHECK:      Resource pressure by instruction:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    [10]   [11]   [12]   [13]   Instructions:
# CHECK-NEXT:  -      -      -      -     2.00    -     2.00    -      -      -      -      -      -      -     vperm2f128	$136, %ymm0, %ymm0, %ymm1
# CHECK-NEXT:  -      -      -     2.00    -     2.00    -      -      -      -      -      -      -      -     vaddps	%ymm1, %ymm1, %ymm0

# CHECK:      Timeline view:
# CHECK-NEXT:                     01234
# CHECK-NEXT: Index     0123456789

# CHECK:      [0,0]     DeER .    .   .   vperm2f128	$136, %ymm0, %ymm0, %ymm1
# CHECK-NEXT: [0,1]     .DeeeER   .   .   vaddps	%ymm1, %ymm1, %ymm0
# CHECK-NEXT: [1,0]     . D==eER  .   .   vperm2f128	$136, %ymm0, %ymm0, %ymm1
# CHECK-NEXT: [1,1]     .  D==eeeER   .   vaddps	%ymm1, %ymm1, %ymm0
# CHECK-NEXT: [2,0]     .   D====eER  .   vperm2f128	$136, %ymm0, %ymm0, %ymm1
# CHECK-NEXT: [2,1]     .    D====eeeER   vaddps	%ymm1, %ymm1, %ymm0

# CHECK:      Average Wait times (based on the timeline view):
# CHECK-NEXT: [0]: Executions
# CHECK-NEXT: [1]: Average time spent waiting in a scheduler's queue
# CHECK-NEXT: [2]: Average time spent waiting in a scheduler's queue while ready
# CHECK-NEXT: [3]: Average time elapsed from WB until retire stage

# CHECK:            [0]    [1]    [2]    [3]
# CHECK-NEXT: 0.     3     3.0    0.3    0.0       vperm2f128	$136, %ymm0, %ymm0, %ymm1
# CHECK-NEXT: 1.     3     3.0    0.0    0.0       vaddps	%ymm1, %ymm1, %ymm0
