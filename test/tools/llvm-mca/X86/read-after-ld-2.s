# NOTE: Assertions have been autogenerated by utils/update_mca_test_checks.py
# RUN: llvm-mca -mtriple=x86_64-unknown-unknown  -mcpu=haswell -iterations=100 -resource-pressure=false -instruction-info=false -timeline < %s | FileCheck %s -check-prefix=ALL -check-prefix=HASWELL

# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=broadwell -iterations=100 -resource-pressure=false -instruction-info=false -timeline < %s | FileCheck %s -check-prefix=ALL -check-prefix=BDWELL

# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=skylake -iterations=100 -resource-pressure=false -instruction-info=false -timeline < %s | FileCheck %s -check-prefix=ALL -check-prefix=SKYLAKE

# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=znver1 -iterations=100 -resource-pressure=false -instruction-info=false -timeline < %s | FileCheck %s -check-prefix=ALL -check-prefix=ZNVER1

# Code Snippet from "Ithemal: Accurate, Portable and Fast Basic Block Throughput Estimation using Deep Neural Networks"
# Charith Mendis, Saman Amarasinghe, Michael Carbin
add     $1, %edx
vpaddd (%r8), %ymm0, %ymm0
add     $32, %r8
cmp     %edi, %edx

# ALL:          Iterations:        100
# ALL-NEXT:     Instructions:      400

# BDWELL-NEXT:  Total Cycles:      208
# BDWELL-NEXT:  Total uOps:        500

# HASWELL-NEXT: Total Cycles:      308
# HASWELL-NEXT: Total uOps:        500

# SKYLAKE-NEXT: Total Cycles:      803
# SKYLAKE-NEXT: Total uOps:        500

# ZNVER1-NEXT:  Total Cycles:      407
# ZNVER1-NEXT:  Total uOps:        400

# ZNVER1:       Dispatch Width:    4
# ZNVER1-NEXT:  uOps Per Cycle:    0.98
# ZNVER1-NEXT:  IPC:               0.98
# ZNVER1-NEXT:  Block RThroughput: 1.0

# HASWELL:      Dispatch Width:    4
# HASWELL-NEXT: uOps Per Cycle:    1.62
# HASWELL-NEXT: IPC:               1.30
# HASWELL-NEXT: Block RThroughput: 1.3

# BDWELL:       Dispatch Width:    4
# BDWELL-NEXT:  uOps Per Cycle:    2.40
# BDWELL-NEXT:  IPC:               1.92
# BDWELL-NEXT:  Block RThroughput: 1.3

# SKYLAKE:      Dispatch Width:    6
# SKYLAKE-NEXT: uOps Per Cycle:    0.62
# SKYLAKE-NEXT: IPC:               0.50
# SKYLAKE-NEXT: Block RThroughput: 0.8

# ALL:          Timeline view:

# BDWELL-NEXT:                      0123456789
# BDWELL-NEXT:  Index     0123456789          01234567

# HASWELL-NEXT:                     0123456789          01234567
# HASWELL-NEXT: Index     0123456789          0123456789

# SKYLAKE-NEXT:                     0123456789          0123456789          0123456789          01234
# SKYLAKE-NEXT: Index     0123456789          0123456789          0123456789          0123456789

# ZNVER1-NEXT:                      0123456789          0123456789
# ZNVER1-NEXT:  Index     0123456789          0123456789          0123456

# SKYLAKE:      [0,0]     DeER .    .    .    .    .    .    .    .    .    .    .    .    .    .   .   addl	$1, %edx
# SKYLAKE-NEXT: [0,1]     DeeeeeeeeER    .    .    .    .    .    .    .    .    .    .    .    .   .   vpaddd	(%r8), %ymm0, %ymm0
# SKYLAKE-NEXT: [0,2]     DeE-------R    .    .    .    .    .    .    .    .    .    .    .    .   .   addq	$32, %r8
# SKYLAKE-NEXT: [0,3]     D=eE------R    .    .    .    .    .    .    .    .    .    .    .    .   .   cmpl	%edi, %edx
# SKYLAKE-NEXT: [1,0]     D=eE------R    .    .    .    .    .    .    .    .    .    .    .    .   .   addl	$1, %edx
# SKYLAKE-NEXT: [1,1]     .D=======eeeeeeeeER .    .    .    .    .    .    .    .    .    .    .   .   vpaddd	(%r8), %ymm0, %ymm0
# SKYLAKE-NEXT: [1,2]     .DeE--------------R .    .    .    .    .    .    .    .    .    .    .   .   addq	$32, %r8
# SKYLAKE-NEXT: [1,3]     .D=eE-------------R .    .    .    .    .    .    .    .    .    .    .   .   cmpl	%edi, %edx
# SKYLAKE-NEXT: [2,0]     .D=eE-------------R .    .    .    .    .    .    .    .    .    .    .   .   addl	$1, %edx
# SKYLAKE-NEXT: [2,1]     . D==============eeeeeeeeER   .    .    .    .    .    .    .    .    .   .   vpaddd	(%r8), %ymm0, %ymm0
# SKYLAKE-NEXT: [2,2]     . DeE---------------------R   .    .    .    .    .    .    .    .    .   .   addq	$32, %r8
# SKYLAKE-NEXT: [2,3]     . D=eE--------------------R   .    .    .    .    .    .    .    .    .   .   cmpl	%edi, %edx
# SKYLAKE-NEXT: [3,0]     . D=eE--------------------R   .    .    .    .    .    .    .    .    .   .   addl	$1, %edx
# SKYLAKE-NEXT: [3,1]     .  D=====================eeeeeeeeER.    .    .    .    .    .    .    .   .   vpaddd	(%r8), %ymm0, %ymm0
# SKYLAKE-NEXT: [3,2]     .  DeE----------------------------R.    .    .    .    .    .    .    .   .   addq	$32, %r8
# SKYLAKE-NEXT: [3,3]     .  D=eE---------------------------R.    .    .    .    .    .    .    .   .   cmpl	%edi, %edx
# SKYLAKE-NEXT: [4,0]     .  D=eE---------------------------R.    .    .    .    .    .    .    .   .   addl	$1, %edx
# SKYLAKE-NEXT: [4,1]     .   D============================eeeeeeeeER  .    .    .    .    .    .   .   vpaddd	(%r8), %ymm0, %ymm0
# SKYLAKE-NEXT: [4,2]     .   DeE-----------------------------------R  .    .    .    .    .    .   .   addq	$32, %r8
# SKYLAKE-NEXT: [4,3]     .   D=eE----------------------------------R  .    .    .    .    .    .   .   cmpl	%edi, %edx
# SKYLAKE-NEXT: [5,0]     .   D=eE----------------------------------R  .    .    .    .    .    .   .   addl	$1, %edx
# SKYLAKE-NEXT: [5,1]     .    D===================================eeeeeeeeER    .    .    .    .   .   vpaddd	(%r8), %ymm0, %ymm0
# SKYLAKE-NEXT: [5,2]     .    DeE------------------------------------------R    .    .    .    .   .   addq	$32, %r8
# SKYLAKE-NEXT: [5,3]     .    D=eE-----------------------------------------R    .    .    .    .   .   cmpl	%edi, %edx
# SKYLAKE-NEXT: [6,0]     .    D=eE-----------------------------------------R    .    .    .    .   .   addl	$1, %edx
# SKYLAKE-NEXT: [6,1]     .    .D==========================================eeeeeeeeER .    .    .   .   vpaddd	(%r8), %ymm0, %ymm0
# SKYLAKE-NEXT: [6,2]     .    .DeE-------------------------------------------------R .    .    .   .   addq	$32, %r8
# SKYLAKE-NEXT: [6,3]     .    .D=eE------------------------------------------------R .    .    .   .   cmpl	%edi, %edx
# SKYLAKE-NEXT: [7,0]     .    .D=eE------------------------------------------------R .    .    .   .   addl	$1, %edx
# SKYLAKE-NEXT: [7,1]     .    . D=================================================eeeeeeeeER   .   .   vpaddd	(%r8), %ymm0, %ymm0
# SKYLAKE-NEXT: [7,2]     .    . DeE--------------------------------------------------------R   .   .   addq	$32, %r8
# SKYLAKE-NEXT: [7,3]     .    . D=eE-------------------------------------------------------R   .   .   cmpl	%edi, %edx
# SKYLAKE-NEXT: [8,0]     .    . D=eE-------------------------------------------------------R   .   .   addl	$1, %edx
# SKYLAKE-NEXT: [8,1]     .    .  D========================================================eeeeeeeeER   vpaddd	(%r8), %ymm0, %ymm0
# SKYLAKE-NEXT: [8,2]     .    .  DeE---------------------------------------------------------------R   addq	$32, %r8
# SKYLAKE-NEXT: [8,3]     .    .  D=eE--------------------------------------------------------------R   cmpl	%edi, %edx
# SKYLAKE-NEXT: [9,0]     .    .  D=eE--------------------------------------------------------------R   addl	$1, %edx

# ZNVER1:       [0,0]     DeER .    .    .    .    .    .    .    .    ..   addl	$1, %edx
# ZNVER1-NEXT:  [0,1]     DeeeeeeeeER    .    .    .    .    .    .    ..   vpaddd	(%r8), %ymm0, %ymm0
# ZNVER1-NEXT:  [0,2]     DeE-------R    .    .    .    .    .    .    ..   addq	$32, %r8
# ZNVER1-NEXT:  [0,3]     D=eE------R    .    .    .    .    .    .    ..   cmpl	%edi, %edx
# ZNVER1-NEXT:  [1,0]     .DeE------R    .    .    .    .    .    .    ..   addl	$1, %edx
# ZNVER1-NEXT:  [1,1]     .D===eeeeeeeeER.    .    .    .    .    .    ..   vpaddd	(%r8), %ymm0, %ymm0
# ZNVER1-NEXT:  [1,2]     .DeE----------R.    .    .    .    .    .    ..   addq	$32, %r8
# ZNVER1-NEXT:  [1,3]     .D=eE---------R.    .    .    .    .    .    ..   cmpl	%edi, %edx
# ZNVER1-NEXT:  [2,0]     . DeE---------R.    .    .    .    .    .    ..   addl	$1, %edx
# ZNVER1-NEXT:  [2,1]     . D======eeeeeeeeER .    .    .    .    .    ..   vpaddd	(%r8), %ymm0, %ymm0
# ZNVER1-NEXT:  [2,2]     . DeE-------------R .    .    .    .    .    ..   addq	$32, %r8
# ZNVER1-NEXT:  [2,3]     . D=eE------------R .    .    .    .    .    ..   cmpl	%edi, %edx
# ZNVER1-NEXT:  [3,0]     .  DeE------------R .    .    .    .    .    ..   addl	$1, %edx
# ZNVER1-NEXT:  [3,1]     .  D=========eeeeeeeeER  .    .    .    .    ..   vpaddd	(%r8), %ymm0, %ymm0
# ZNVER1-NEXT:  [3,2]     .  DeE----------------R  .    .    .    .    ..   addq	$32, %r8
# ZNVER1-NEXT:  [3,3]     .  D=eE---------------R  .    .    .    .    ..   cmpl	%edi, %edx
# ZNVER1-NEXT:  [4,0]     .   DeE---------------R  .    .    .    .    ..   addl	$1, %edx
# ZNVER1-NEXT:  [4,1]     .   D============eeeeeeeeER   .    .    .    ..   vpaddd	(%r8), %ymm0, %ymm0
# ZNVER1-NEXT:  [4,2]     .   DeE-------------------R   .    .    .    ..   addq	$32, %r8
# ZNVER1-NEXT:  [4,3]     .   D=eE------------------R   .    .    .    ..   cmpl	%edi, %edx
# ZNVER1-NEXT:  [5,0]     .    DeE------------------R   .    .    .    ..   addl	$1, %edx
# ZNVER1-NEXT:  [5,1]     .    D===============eeeeeeeeER    .    .    ..   vpaddd	(%r8), %ymm0, %ymm0
# ZNVER1-NEXT:  [5,2]     .    DeE----------------------R    .    .    ..   addq	$32, %r8
# ZNVER1-NEXT:  [5,3]     .    D=eE---------------------R    .    .    ..   cmpl	%edi, %edx
# ZNVER1-NEXT:  [6,0]     .    .DeE---------------------R    .    .    ..   addl	$1, %edx
# ZNVER1-NEXT:  [6,1]     .    .D==================eeeeeeeeER.    .    ..   vpaddd	(%r8), %ymm0, %ymm0
# ZNVER1-NEXT:  [6,2]     .    .DeE-------------------------R.    .    ..   addq	$32, %r8
# ZNVER1-NEXT:  [6,3]     .    .D=eE------------------------R.    .    ..   cmpl	%edi, %edx
# ZNVER1-NEXT:  [7,0]     .    . DeE------------------------R.    .    ..   addl	$1, %edx
# ZNVER1-NEXT:  [7,1]     .    . D=====================eeeeeeeeER .    ..   vpaddd	(%r8), %ymm0, %ymm0
# ZNVER1-NEXT:  [7,2]     .    . DeE----------------------------R .    ..   addq	$32, %r8
# ZNVER1-NEXT:  [7,3]     .    . D=eE---------------------------R .    ..   cmpl	%edi, %edx
# ZNVER1-NEXT:  [8,0]     .    .  DeE---------------------------R .    ..   addl	$1, %edx
# ZNVER1-NEXT:  [8,1]     .    .  D========================eeeeeeeeER  ..   vpaddd	(%r8), %ymm0, %ymm0
# ZNVER1-NEXT:  [8,2]     .    .  DeE-------------------------------R  ..   addq	$32, %r8
# ZNVER1-NEXT:  [8,3]     .    .  D=eE------------------------------R  ..   cmpl	%edi, %edx
# ZNVER1-NEXT:  [9,0]     .    .   DeE------------------------------R  ..   addl	$1, %edx
# ZNVER1-NEXT:  [9,1]     .    .   D===========================eeeeeeeeER   vpaddd	(%r8), %ymm0, %ymm0
# ZNVER1-NEXT:  [9,2]     .    .   DeE----------------------------------R   addq	$32, %r8
# ZNVER1-NEXT:  [9,3]     .    .   D=eE---------------------------------R   cmpl	%edi, %edx

# HASWELL:      [0,0]     DeER .    .    .    .    .    .    . .   addl	$1, %edx
# HASWELL-NEXT: [0,1]     DeeeeeeeeER    .    .    .    .    . .   vpaddd	(%r8), %ymm0, %ymm0
# HASWELL-NEXT: [0,2]     DeE-------R    .    .    .    .    . .   addq	$32, %r8
# HASWELL-NEXT: [0,3]     .DeE------R    .    .    .    .    . .   cmpl	%edi, %edx
# HASWELL-NEXT: [1,0]     .DeE------R    .    .    .    .    . .   addl	$1, %edx
# HASWELL-NEXT: [1,1]     .D==eeeeeeeeER .    .    .    .    . .   vpaddd	(%r8), %ymm0, %ymm0
# HASWELL-NEXT: [1,2]     . DeE--------R .    .    .    .    . .   addq	$32, %r8
# HASWELL-NEXT: [1,3]     . DeE--------R .    .    .    .    . .   cmpl	%edi, %edx
# HASWELL-NEXT: [2,0]     . DeE--------R .    .    .    .    . .   addl	$1, %edx
# HASWELL-NEXT: [2,1]     .  D===eeeeeeeeER   .    .    .    . .   vpaddd	(%r8), %ymm0, %ymm0
# HASWELL-NEXT: [2,2]     .  DeE----------R   .    .    .    . .   addq	$32, %r8
# HASWELL-NEXT: [2,3]     .  DeE----------R   .    .    .    . .   cmpl	%edi, %edx
# HASWELL-NEXT: [3,0]     .   DeE---------R   .    .    .    . .   addl	$1, %edx
# HASWELL-NEXT: [3,1]     .   D=====eeeeeeeeER.    .    .    . .   vpaddd	(%r8), %ymm0, %ymm0
# HASWELL-NEXT: [3,2]     .   DeE------------R.    .    .    . .   addq	$32, %r8
# HASWELL-NEXT: [3,3]     .    DeE-----------R.    .    .    . .   cmpl	%edi, %edx
# HASWELL-NEXT: [4,0]     .    DeE-----------R.    .    .    . .   addl	$1, %edx
# HASWELL-NEXT: [4,1]     .    D=======eeeeeeeeER  .    .    . .   vpaddd	(%r8), %ymm0, %ymm0
# HASWELL-NEXT: [4,2]     .    .DeE-------------R  .    .    . .   addq	$32, %r8
# HASWELL-NEXT: [4,3]     .    .DeE-------------R  .    .    . .   cmpl	%edi, %edx
# HASWELL-NEXT: [5,0]     .    .DeE-------------R  .    .    . .   addl	$1, %edx
# HASWELL-NEXT: [5,1]     .    . D========eeeeeeeeER    .    . .   vpaddd	(%r8), %ymm0, %ymm0
# HASWELL-NEXT: [5,2]     .    . DeE---------------R    .    . .   addq	$32, %r8
# HASWELL-NEXT: [5,3]     .    . DeE---------------R    .    . .   cmpl	%edi, %edx
# HASWELL-NEXT: [6,0]     .    .  DeE--------------R    .    . .   addl	$1, %edx
# HASWELL-NEXT: [6,1]     .    .  D==========eeeeeeeeER .    . .   vpaddd	(%r8), %ymm0, %ymm0
# HASWELL-NEXT: [6,2]     .    .  DeE-----------------R .    . .   addq	$32, %r8
# HASWELL-NEXT: [6,3]     .    .   DeE----------------R .    . .   cmpl	%edi, %edx
# HASWELL-NEXT: [7,0]     .    .   DeE----------------R .    . .   addl	$1, %edx
# HASWELL-NEXT: [7,1]     .    .   D============eeeeeeeeER   . .   vpaddd	(%r8), %ymm0, %ymm0
# HASWELL-NEXT: [7,2]     .    .    DeE------------------R   . .   addq	$32, %r8
# HASWELL-NEXT: [7,3]     .    .    DeE------------------R   . .   cmpl	%edi, %edx
# HASWELL-NEXT: [8,0]     .    .    DeE------------------R   . .   addl	$1, %edx
# HASWELL-NEXT: [8,1]     .    .    .D=============eeeeeeeeER. .   vpaddd	(%r8), %ymm0, %ymm0
# HASWELL-NEXT: [8,2]     .    .    .DeE--------------------R. .   addq	$32, %r8
# HASWELL-NEXT: [8,3]     .    .    .DeE--------------------R. .   cmpl	%edi, %edx
# HASWELL-NEXT: [9,0]     .    .    . DeE-------------------R. .   addl	$1, %edx
# HASWELL-NEXT: [9,1]     .    .    . D===============eeeeeeeeER   vpaddd	(%r8), %ymm0, %ymm0
# HASWELL-NEXT: [9,2]     .    .    . DeE----------------------R   addq	$32, %r8
# HASWELL-NEXT: [9,3]     .    .    .  DeE---------------------R   cmpl	%edi, %edx

# BDWELL:       [0,0]     DeER .    .    .    .    . .   addl	$1, %edx
# BDWELL-NEXT:  [0,1]     DeeeeeeeER.    .    .    . .   vpaddd	(%r8), %ymm0, %ymm0
# BDWELL-NEXT:  [0,2]     DeE------R.    .    .    . .   addq	$32, %r8
# BDWELL-NEXT:  [0,3]     .DeE-----R.    .    .    . .   cmpl	%edi, %edx
# BDWELL-NEXT:  [1,0]     .DeE-----R.    .    .    . .   addl	$1, %edx
# BDWELL-NEXT:  [1,1]     .D=eeeeeeeER   .    .    . .   vpaddd	(%r8), %ymm0, %ymm0
# BDWELL-NEXT:  [1,2]     . DeE------R   .    .    . .   addq	$32, %r8
# BDWELL-NEXT:  [1,3]     . DeE------R   .    .    . .   cmpl	%edi, %edx
# BDWELL-NEXT:  [2,0]     . DeE------R   .    .    . .   addl	$1, %edx
# BDWELL-NEXT:  [2,1]     .  D=eeeeeeeER .    .    . .   vpaddd	(%r8), %ymm0, %ymm0
# BDWELL-NEXT:  [2,2]     .  DeE-------R .    .    . .   addq	$32, %r8
# BDWELL-NEXT:  [2,3]     .  DeE-------R .    .    . .   cmpl	%edi, %edx
# BDWELL-NEXT:  [3,0]     .   DeE------R .    .    . .   addl	$1, %edx
# BDWELL-NEXT:  [3,1]     .   D==eeeeeeeER    .    . .   vpaddd	(%r8), %ymm0, %ymm0
# BDWELL-NEXT:  [3,2]     .   DeE--------R    .    . .   addq	$32, %r8
# BDWELL-NEXT:  [3,3]     .    DeE-------R    .    . .   cmpl	%edi, %edx
# BDWELL-NEXT:  [4,0]     .    DeE-------R    .    . .   addl	$1, %edx
# BDWELL-NEXT:  [4,1]     .    D===eeeeeeeER  .    . .   vpaddd	(%r8), %ymm0, %ymm0
# BDWELL-NEXT:  [4,2]     .    .DeE--------R  .    . .   addq	$32, %r8
# BDWELL-NEXT:  [4,3]     .    .DeE--------R  .    . .   cmpl	%edi, %edx
# BDWELL-NEXT:  [5,0]     .    .DeE--------R  .    . .   addl	$1, %edx
# BDWELL-NEXT:  [5,1]     .    . D===eeeeeeeER.    . .   vpaddd	(%r8), %ymm0, %ymm0
# BDWELL-NEXT:  [5,2]     .    . DeE---------R.    . .   addq	$32, %r8
# BDWELL-NEXT:  [5,3]     .    . DeE---------R.    . .   cmpl	%edi, %edx
# BDWELL-NEXT:  [6,0]     .    .  DeE--------R.    . .   addl	$1, %edx
# BDWELL-NEXT:  [6,1]     .    .  D====eeeeeeeER   . .   vpaddd	(%r8), %ymm0, %ymm0
# BDWELL-NEXT:  [6,2]     .    .  DeE----------R   . .   addq	$32, %r8
# BDWELL-NEXT:  [6,3]     .    .   DeE---------R   . .   cmpl	%edi, %edx
# BDWELL-NEXT:  [7,0]     .    .   DeE---------R   . .   addl	$1, %edx
# BDWELL-NEXT:  [7,1]     .    .   D=====eeeeeeeER . .   vpaddd	(%r8), %ymm0, %ymm0
# BDWELL-NEXT:  [7,2]     .    .    DeE----------R . .   addq	$32, %r8
# BDWELL-NEXT:  [7,3]     .    .    DeE----------R . .   cmpl	%edi, %edx
# BDWELL-NEXT:  [8,0]     .    .    DeE----------R . .   addl	$1, %edx
# BDWELL-NEXT:  [8,1]     .    .    .D=====eeeeeeeER .   vpaddd	(%r8), %ymm0, %ymm0
# BDWELL-NEXT:  [8,2]     .    .    .DeE-----------R .   addq	$32, %r8
# BDWELL-NEXT:  [8,3]     .    .    .DeE-----------R .   cmpl	%edi, %edx
# BDWELL-NEXT:  [9,0]     .    .    . DeE----------R .   addl	$1, %edx
# BDWELL-NEXT:  [9,1]     .    .    . D======eeeeeeeER   vpaddd	(%r8), %ymm0, %ymm0
# BDWELL-NEXT:  [9,2]     .    .    . DeE------------R   addq	$32, %r8
# BDWELL-NEXT:  [9,3]     .    .    .  DeE-----------R   cmpl	%edi, %edx

# ALL:          Average Wait times (based on the timeline view):
# ALL-NEXT:     [0]: Executions
# ALL-NEXT:     [1]: Average time spent waiting in a scheduler's queue
# ALL-NEXT:     [2]: Average time spent waiting in a scheduler's queue while ready
# ALL-NEXT:     [3]: Average time elapsed from WB until retire stage

# ALL:                [0]    [1]    [2]    [3]

# BDWELL-NEXT:  0.     10    1.0    0.4    6.9       addl	$1, %edx
# BDWELL-NEXT:  1.     10    4.0    0.1    0.0       vpaddd	(%r8), %ymm0, %ymm0
# BDWELL-NEXT:  2.     10    1.0    0.4    8.7       addq	$32, %r8
# BDWELL-NEXT:  3.     10    1.0    0.0    8.3       cmpl	%edi, %edx

# HASWELL-NEXT: 0.     10    1.0    0.4    11.4      addl	$1, %edx
# HASWELL-NEXT: 1.     10    8.5    0.1    0.0       vpaddd	(%r8), %ymm0, %ymm0
# HASWELL-NEXT: 2.     10    1.0    0.4    14.2      addq	$32, %r8
# HASWELL-NEXT: 3.     10    1.0    0.0    13.8      cmpl	%edi, %edx

# SKYLAKE-NEXT: 0.     10    1.9    0.1    30.6      addl	$1, %edx
# SKYLAKE-NEXT: 1.     10    32.5   0.1    0.0       vpaddd	(%r8), %ymm0, %ymm0
# SKYLAKE-NEXT: 2.     10    1.0    0.1    38.5      addq	$32, %r8
# SKYLAKE-NEXT: 3.     10    2.0    0.0    37.5      cmpl	%edi, %edx

# ZNVER1-NEXT:  0.     10    1.0    0.1    16.2      addl	$1, %edx
# ZNVER1-NEXT:  1.     10    14.5   0.1    0.0       vpaddd	(%r8), %ymm0, %ymm0
# ZNVER1-NEXT:  2.     10    1.0    0.1    20.5      addq	$32, %r8
# ZNVER1-NEXT:  3.     10    2.0    0.0    19.5      cmpl	%edi, %edx
