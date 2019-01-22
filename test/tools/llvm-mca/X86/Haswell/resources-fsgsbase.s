# NOTE: Assertions have been autogenerated by utils/update_mca_test_checks.py
# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=haswell -instruction-tables < %s | FileCheck %s

rdfsbase %eax
rdfsbase %rax

rdgsbase %eax
rdgsbase %rax

wrfsbase %edi
wrfsbase %rdi

wrgsbase %edi
wrgsbase %rdi

# CHECK:      Instruction Info:
# CHECK-NEXT: [1]: #uOps
# CHECK-NEXT: [2]: Latency
# CHECK-NEXT: [3]: RThroughput
# CHECK-NEXT: [4]: MayLoad
# CHECK-NEXT: [5]: MayStore
# CHECK-NEXT: [6]: HasSideEffects (U)

# CHECK:      [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT:  1      100   0.25    *      *      U     rdfsbasel	%eax
# CHECK-NEXT:  1      100   0.25    *      *      U     rdfsbaseq	%rax
# CHECK-NEXT:  1      100   0.25    *      *      U     rdgsbasel	%eax
# CHECK-NEXT:  1      100   0.25    *      *      U     rdgsbaseq	%rax
# CHECK-NEXT:  1      100   0.25    *      *      U     wrfsbasel	%edi
# CHECK-NEXT:  1      100   0.25    *      *      U     wrfsbaseq	%rdi
# CHECK-NEXT:  1      100   0.25    *      *      U     wrgsbasel	%edi
# CHECK-NEXT:  1      100   0.25    *      *      U     wrgsbaseq	%rdi

# CHECK:      Resources:
# CHECK-NEXT: [0]   - HWDivider
# CHECK-NEXT: [1]   - HWFPDivider
# CHECK-NEXT: [2]   - HWPort0
# CHECK-NEXT: [3]   - HWPort1
# CHECK-NEXT: [4]   - HWPort2
# CHECK-NEXT: [5]   - HWPort3
# CHECK-NEXT: [6]   - HWPort4
# CHECK-NEXT: [7]   - HWPort5
# CHECK-NEXT: [8]   - HWPort6
# CHECK-NEXT: [9]   - HWPort7

# CHECK:      Resource pressure per iteration:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]
# CHECK-NEXT:  -      -     2.00   2.00    -      -      -     2.00   2.00    -

# CHECK:      Resource pressure by instruction:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    Instructions:
# CHECK-NEXT:  -      -     0.25   0.25    -      -      -     0.25   0.25    -     rdfsbasel	%eax
# CHECK-NEXT:  -      -     0.25   0.25    -      -      -     0.25   0.25    -     rdfsbaseq	%rax
# CHECK-NEXT:  -      -     0.25   0.25    -      -      -     0.25   0.25    -     rdgsbasel	%eax
# CHECK-NEXT:  -      -     0.25   0.25    -      -      -     0.25   0.25    -     rdgsbaseq	%rax
# CHECK-NEXT:  -      -     0.25   0.25    -      -      -     0.25   0.25    -     wrfsbasel	%edi
# CHECK-NEXT:  -      -     0.25   0.25    -      -      -     0.25   0.25    -     wrfsbaseq	%rdi
# CHECK-NEXT:  -      -     0.25   0.25    -      -      -     0.25   0.25    -     wrgsbasel	%edi
# CHECK-NEXT:  -      -     0.25   0.25    -      -      -     0.25   0.25    -     wrgsbaseq	%rdi
