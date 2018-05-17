# NOTE: Assertions have been autogenerated by utils/update_mca_test_checks.py
# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=sandybridge -instruction-tables < %s | FileCheck %s

cmovow    %si, %di
cmovnow   %si, %di
cmovbw    %si, %di
cmovaew   %si, %di
cmovew    %si, %di
cmovnew   %si, %di
cmovbew   %si, %di
cmovaw    %si, %di
cmovsw    %si, %di
cmovnsw   %si, %di
cmovpw    %si, %di
cmovnpw   %si, %di
cmovlw    %si, %di
cmovgew   %si, %di
cmovlew   %si, %di
cmovgw    %si, %di

cmovow    (%rax), %di
cmovnow   (%rax), %di
cmovbw    (%rax), %di
cmovaew   (%rax), %di
cmovew    (%rax), %di
cmovnew   (%rax), %di
cmovbew   (%rax), %di
cmovaw    (%rax), %di
cmovsw    (%rax), %di
cmovnsw   (%rax), %di
cmovpw    (%rax), %di
cmovnpw   (%rax), %di
cmovlw    (%rax), %di
cmovgew   (%rax), %di
cmovlew   (%rax), %di
cmovgw    (%rax), %di

cmovol    %esi, %edi
cmovnol   %esi, %edi
cmovbl    %esi, %edi
cmovael   %esi, %edi
cmovel    %esi, %edi
cmovnel   %esi, %edi
cmovbel   %esi, %edi
cmoval    %esi, %edi
cmovsl    %esi, %edi
cmovnsl   %esi, %edi
cmovpl    %esi, %edi
cmovnpl   %esi, %edi
cmovll    %esi, %edi
cmovgel   %esi, %edi
cmovlel   %esi, %edi
cmovgl    %esi, %edi

cmovol    (%rax), %edi
cmovnol   (%rax), %edi
cmovbl    (%rax), %edi
cmovael   (%rax), %edi
cmovel    (%rax), %edi
cmovnel   (%rax), %edi
cmovbel   (%rax), %edi
cmoval    (%rax), %edi
cmovsl    (%rax), %edi
cmovnsl   (%rax), %edi
cmovpl    (%rax), %edi
cmovnpl   (%rax), %edi
cmovll    (%rax), %edi
cmovgel   (%rax), %edi
cmovlel   (%rax), %edi
cmovgl    (%rax), %edi

cmovoq    %rsi, %rdi
cmovnoq   %rsi, %rdi
cmovbq    %rsi, %rdi
cmovaeq   %rsi, %rdi
cmoveq    %rsi, %rdi
cmovneq   %rsi, %rdi
cmovbeq   %rsi, %rdi
cmovaq    %rsi, %rdi
cmovsq    %rsi, %rdi
cmovnsq   %rsi, %rdi
cmovpq    %rsi, %rdi
cmovnpq   %rsi, %rdi
cmovlq    %rsi, %rdi
cmovgeq   %rsi, %rdi
cmovleq   %rsi, %rdi
cmovgq    %rsi, %rdi

cmovoq    (%rax), %rdi
cmovnoq   (%rax), %rdi
cmovbq    (%rax), %rdi
cmovaeq   (%rax), %rdi
cmoveq    (%rax), %rdi
cmovneq   (%rax), %rdi
cmovbeq   (%rax), %rdi
cmovaq    (%rax), %rdi
cmovsq    (%rax), %rdi
cmovnsq   (%rax), %rdi
cmovpq    (%rax), %rdi
cmovnpq   (%rax), %rdi
cmovlq    (%rax), %rdi
cmovgeq   (%rax), %rdi
cmovleq   (%rax), %rdi
cmovgq    (%rax), %rdi

# CHECK:      Instruction Info:
# CHECK-NEXT: [1]: #uOps
# CHECK-NEXT: [2]: Latency
# CHECK-NEXT: [3]: RThroughput
# CHECK-NEXT: [4]: MayLoad
# CHECK-NEXT: [5]: MayStore
# CHECK-NEXT: [6]: HasSideEffects

# CHECK:      [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT:  2      2     0.67                        cmovow	%si, %di
# CHECK-NEXT:  2      2     0.67                        cmovnow	%si, %di
# CHECK-NEXT:  2      2     0.67                        cmovbw	%si, %di
# CHECK-NEXT:  2      2     0.67                        cmovaew	%si, %di
# CHECK-NEXT:  2      2     0.67                        cmovew	%si, %di
# CHECK-NEXT:  2      2     0.67                        cmovnew	%si, %di
# CHECK-NEXT:  3      3     1.00                        cmovbew	%si, %di
# CHECK-NEXT:  3      3     1.00                        cmovaw	%si, %di
# CHECK-NEXT:  2      2     0.67                        cmovsw	%si, %di
# CHECK-NEXT:  2      2     0.67                        cmovnsw	%si, %di
# CHECK-NEXT:  2      2     0.67                        cmovpw	%si, %di
# CHECK-NEXT:  2      2     0.67                        cmovnpw	%si, %di
# CHECK-NEXT:  2      2     0.67                        cmovlw	%si, %di
# CHECK-NEXT:  2      2     0.67                        cmovgew	%si, %di
# CHECK-NEXT:  2      2     0.67                        cmovlew	%si, %di
# CHECK-NEXT:  2      2     0.67                        cmovgw	%si, %di
# CHECK-NEXT:  3      7     0.67    *                   cmovow	(%rax), %di
# CHECK-NEXT:  3      7     0.67    *                   cmovnow	(%rax), %di
# CHECK-NEXT:  3      7     0.67    *                   cmovbw	(%rax), %di
# CHECK-NEXT:  3      7     0.67    *                   cmovaew	(%rax), %di
# CHECK-NEXT:  3      7     0.67    *                   cmovew	(%rax), %di
# CHECK-NEXT:  3      7     0.67    *                   cmovnew	(%rax), %di
# CHECK-NEXT:  4      8     1.00    *                   cmovbew	(%rax), %di
# CHECK-NEXT:  4      8     1.00    *                   cmovaw	(%rax), %di
# CHECK-NEXT:  3      7     0.67    *                   cmovsw	(%rax), %di
# CHECK-NEXT:  3      7     0.67    *                   cmovnsw	(%rax), %di
# CHECK-NEXT:  3      7     0.67    *                   cmovpw	(%rax), %di
# CHECK-NEXT:  3      7     0.67    *                   cmovnpw	(%rax), %di
# CHECK-NEXT:  3      7     0.67    *                   cmovlw	(%rax), %di
# CHECK-NEXT:  3      7     0.67    *                   cmovgew	(%rax), %di
# CHECK-NEXT:  3      7     0.67    *                   cmovlew	(%rax), %di
# CHECK-NEXT:  3      7     0.67    *                   cmovgw	(%rax), %di
# CHECK-NEXT:  2      2     0.67                        cmovol	%esi, %edi
# CHECK-NEXT:  2      2     0.67                        cmovnol	%esi, %edi
# CHECK-NEXT:  2      2     0.67                        cmovbl	%esi, %edi
# CHECK-NEXT:  2      2     0.67                        cmovael	%esi, %edi
# CHECK-NEXT:  2      2     0.67                        cmovel	%esi, %edi
# CHECK-NEXT:  2      2     0.67                        cmovnel	%esi, %edi
# CHECK-NEXT:  3      3     1.00                        cmovbel	%esi, %edi
# CHECK-NEXT:  3      3     1.00                        cmoval	%esi, %edi
# CHECK-NEXT:  2      2     0.67                        cmovsl	%esi, %edi
# CHECK-NEXT:  2      2     0.67                        cmovnsl	%esi, %edi
# CHECK-NEXT:  2      2     0.67                        cmovpl	%esi, %edi
# CHECK-NEXT:  2      2     0.67                        cmovnpl	%esi, %edi
# CHECK-NEXT:  2      2     0.67                        cmovll	%esi, %edi
# CHECK-NEXT:  2      2     0.67                        cmovgel	%esi, %edi
# CHECK-NEXT:  2      2     0.67                        cmovlel	%esi, %edi
# CHECK-NEXT:  2      2     0.67                        cmovgl	%esi, %edi
# CHECK-NEXT:  3      7     0.67    *                   cmovol	(%rax), %edi
# CHECK-NEXT:  3      7     0.67    *                   cmovnol	(%rax), %edi
# CHECK-NEXT:  3      7     0.67    *                   cmovbl	(%rax), %edi
# CHECK-NEXT:  3      7     0.67    *                   cmovael	(%rax), %edi
# CHECK-NEXT:  3      7     0.67    *                   cmovel	(%rax), %edi
# CHECK-NEXT:  3      7     0.67    *                   cmovnel	(%rax), %edi
# CHECK-NEXT:  4      8     1.00    *                   cmovbel	(%rax), %edi
# CHECK-NEXT:  4      8     1.00    *                   cmoval	(%rax), %edi
# CHECK-NEXT:  3      7     0.67    *                   cmovsl	(%rax), %edi
# CHECK-NEXT:  3      7     0.67    *                   cmovnsl	(%rax), %edi
# CHECK-NEXT:  3      7     0.67    *                   cmovpl	(%rax), %edi
# CHECK-NEXT:  3      7     0.67    *                   cmovnpl	(%rax), %edi
# CHECK-NEXT:  3      7     0.67    *                   cmovll	(%rax), %edi
# CHECK-NEXT:  3      7     0.67    *                   cmovgel	(%rax), %edi
# CHECK-NEXT:  3      7     0.67    *                   cmovlel	(%rax), %edi
# CHECK-NEXT:  3      7     0.67    *                   cmovgl	(%rax), %edi
# CHECK-NEXT:  2      2     0.67                        cmovoq	%rsi, %rdi
# CHECK-NEXT:  2      2     0.67                        cmovnoq	%rsi, %rdi
# CHECK-NEXT:  2      2     0.67                        cmovbq	%rsi, %rdi
# CHECK-NEXT:  2      2     0.67                        cmovaeq	%rsi, %rdi
# CHECK-NEXT:  2      2     0.67                        cmoveq	%rsi, %rdi
# CHECK-NEXT:  2      2     0.67                        cmovneq	%rsi, %rdi
# CHECK-NEXT:  3      3     1.00                        cmovbeq	%rsi, %rdi
# CHECK-NEXT:  3      3     1.00                        cmovaq	%rsi, %rdi
# CHECK-NEXT:  2      2     0.67                        cmovsq	%rsi, %rdi
# CHECK-NEXT:  2      2     0.67                        cmovnsq	%rsi, %rdi
# CHECK-NEXT:  2      2     0.67                        cmovpq	%rsi, %rdi
# CHECK-NEXT:  2      2     0.67                        cmovnpq	%rsi, %rdi
# CHECK-NEXT:  2      2     0.67                        cmovlq	%rsi, %rdi
# CHECK-NEXT:  2      2     0.67                        cmovgeq	%rsi, %rdi
# CHECK-NEXT:  2      2     0.67                        cmovleq	%rsi, %rdi
# CHECK-NEXT:  2      2     0.67                        cmovgq	%rsi, %rdi
# CHECK-NEXT:  3      7     0.67    *                   cmovoq	(%rax), %rdi
# CHECK-NEXT:  3      7     0.67    *                   cmovnoq	(%rax), %rdi
# CHECK-NEXT:  3      7     0.67    *                   cmovbq	(%rax), %rdi
# CHECK-NEXT:  3      7     0.67    *                   cmovaeq	(%rax), %rdi
# CHECK-NEXT:  3      7     0.67    *                   cmoveq	(%rax), %rdi
# CHECK-NEXT:  3      7     0.67    *                   cmovneq	(%rax), %rdi
# CHECK-NEXT:  4      8     1.00    *                   cmovbeq	(%rax), %rdi
# CHECK-NEXT:  4      8     1.00    *                   cmovaq	(%rax), %rdi
# CHECK-NEXT:  3      7     0.67    *                   cmovsq	(%rax), %rdi
# CHECK-NEXT:  3      7     0.67    *                   cmovnsq	(%rax), %rdi
# CHECK-NEXT:  3      7     0.67    *                   cmovpq	(%rax), %rdi
# CHECK-NEXT:  3      7     0.67    *                   cmovnpq	(%rax), %rdi
# CHECK-NEXT:  3      7     0.67    *                   cmovlq	(%rax), %rdi
# CHECK-NEXT:  3      7     0.67    *                   cmovgeq	(%rax), %rdi
# CHECK-NEXT:  3      7     0.67    *                   cmovleq	(%rax), %rdi
# CHECK-NEXT:  3      7     0.67    *                   cmovgq	(%rax), %rdi

# CHECK:      Resources:
# CHECK-NEXT: [0]   - SBDivider
# CHECK-NEXT: [1]   - SBFPDivider
# CHECK-NEXT: [2]   - SBPort0
# CHECK-NEXT: [3]   - SBPort1
# CHECK-NEXT: [4]   - SBPort4
# CHECK-NEXT: [5]   - SBPort5
# CHECK-NEXT: [6.0] - SBPort23
# CHECK-NEXT: [6.1] - SBPort23

# CHECK:      Resource pressure per iteration:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6.0]  [6.1]
# CHECK-NEXT:  -      -     86.00  32.00   -     86.00  24.00  24.00

# CHECK:      Resource pressure by instruction:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6.0]  [6.1]  Instructions:
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83    -      -     cmovow	%si, %di
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83    -      -     cmovnow	%si, %di
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83    -      -     cmovbw	%si, %di
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83    -      -     cmovaew	%si, %di
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83    -      -     cmovew	%si, %di
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83    -      -     cmovnew	%si, %di
# CHECK-NEXT:  -      -     1.33   0.33    -     1.33    -      -     cmovbew	%si, %di
# CHECK-NEXT:  -      -     1.33   0.33    -     1.33    -      -     cmovaw	%si, %di
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83    -      -     cmovsw	%si, %di
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83    -      -     cmovnsw	%si, %di
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83    -      -     cmovpw	%si, %di
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83    -      -     cmovnpw	%si, %di
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83    -      -     cmovlw	%si, %di
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83    -      -     cmovgew	%si, %di
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83    -      -     cmovlew	%si, %di
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83    -      -     cmovgw	%si, %di
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83   0.50   0.50   cmovow	(%rax), %di
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83   0.50   0.50   cmovnow	(%rax), %di
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83   0.50   0.50   cmovbw	(%rax), %di
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83   0.50   0.50   cmovaew	(%rax), %di
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83   0.50   0.50   cmovew	(%rax), %di
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83   0.50   0.50   cmovnew	(%rax), %di
# CHECK-NEXT:  -      -     1.33   0.33    -     1.33   0.50   0.50   cmovbew	(%rax), %di
# CHECK-NEXT:  -      -     1.33   0.33    -     1.33   0.50   0.50   cmovaw	(%rax), %di
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83   0.50   0.50   cmovsw	(%rax), %di
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83   0.50   0.50   cmovnsw	(%rax), %di
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83   0.50   0.50   cmovpw	(%rax), %di
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83   0.50   0.50   cmovnpw	(%rax), %di
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83   0.50   0.50   cmovlw	(%rax), %di
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83   0.50   0.50   cmovgew	(%rax), %di
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83   0.50   0.50   cmovlew	(%rax), %di
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83   0.50   0.50   cmovgw	(%rax), %di
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83    -      -     cmovol	%esi, %edi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83    -      -     cmovnol	%esi, %edi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83    -      -     cmovbl	%esi, %edi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83    -      -     cmovael	%esi, %edi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83    -      -     cmovel	%esi, %edi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83    -      -     cmovnel	%esi, %edi
# CHECK-NEXT:  -      -     1.33   0.33    -     1.33    -      -     cmovbel	%esi, %edi
# CHECK-NEXT:  -      -     1.33   0.33    -     1.33    -      -     cmoval	%esi, %edi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83    -      -     cmovsl	%esi, %edi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83    -      -     cmovnsl	%esi, %edi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83    -      -     cmovpl	%esi, %edi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83    -      -     cmovnpl	%esi, %edi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83    -      -     cmovll	%esi, %edi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83    -      -     cmovgel	%esi, %edi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83    -      -     cmovlel	%esi, %edi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83    -      -     cmovgl	%esi, %edi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83   0.50   0.50   cmovol	(%rax), %edi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83   0.50   0.50   cmovnol	(%rax), %edi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83   0.50   0.50   cmovbl	(%rax), %edi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83   0.50   0.50   cmovael	(%rax), %edi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83   0.50   0.50   cmovel	(%rax), %edi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83   0.50   0.50   cmovnel	(%rax), %edi
# CHECK-NEXT:  -      -     1.33   0.33    -     1.33   0.50   0.50   cmovbel	(%rax), %edi
# CHECK-NEXT:  -      -     1.33   0.33    -     1.33   0.50   0.50   cmoval	(%rax), %edi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83   0.50   0.50   cmovsl	(%rax), %edi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83   0.50   0.50   cmovnsl	(%rax), %edi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83   0.50   0.50   cmovpl	(%rax), %edi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83   0.50   0.50   cmovnpl	(%rax), %edi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83   0.50   0.50   cmovll	(%rax), %edi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83   0.50   0.50   cmovgel	(%rax), %edi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83   0.50   0.50   cmovlel	(%rax), %edi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83   0.50   0.50   cmovgl	(%rax), %edi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83    -      -     cmovoq	%rsi, %rdi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83    -      -     cmovnoq	%rsi, %rdi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83    -      -     cmovbq	%rsi, %rdi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83    -      -     cmovaeq	%rsi, %rdi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83    -      -     cmoveq	%rsi, %rdi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83    -      -     cmovneq	%rsi, %rdi
# CHECK-NEXT:  -      -     1.33   0.33    -     1.33    -      -     cmovbeq	%rsi, %rdi
# CHECK-NEXT:  -      -     1.33   0.33    -     1.33    -      -     cmovaq	%rsi, %rdi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83    -      -     cmovsq	%rsi, %rdi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83    -      -     cmovnsq	%rsi, %rdi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83    -      -     cmovpq	%rsi, %rdi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83    -      -     cmovnpq	%rsi, %rdi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83    -      -     cmovlq	%rsi, %rdi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83    -      -     cmovgeq	%rsi, %rdi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83    -      -     cmovleq	%rsi, %rdi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83    -      -     cmovgq	%rsi, %rdi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83   0.50   0.50   cmovoq	(%rax), %rdi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83   0.50   0.50   cmovnoq	(%rax), %rdi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83   0.50   0.50   cmovbq	(%rax), %rdi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83   0.50   0.50   cmovaeq	(%rax), %rdi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83   0.50   0.50   cmoveq	(%rax), %rdi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83   0.50   0.50   cmovneq	(%rax), %rdi
# CHECK-NEXT:  -      -     1.33   0.33    -     1.33   0.50   0.50   cmovbeq	(%rax), %rdi
# CHECK-NEXT:  -      -     1.33   0.33    -     1.33   0.50   0.50   cmovaq	(%rax), %rdi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83   0.50   0.50   cmovsq	(%rax), %rdi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83   0.50   0.50   cmovnsq	(%rax), %rdi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83   0.50   0.50   cmovpq	(%rax), %rdi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83   0.50   0.50   cmovnpq	(%rax), %rdi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83   0.50   0.50   cmovlq	(%rax), %rdi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83   0.50   0.50   cmovgeq	(%rax), %rdi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83   0.50   0.50   cmovleq	(%rax), %rdi
# CHECK-NEXT:  -      -     0.83   0.33    -     0.83   0.50   0.50   cmovgq	(%rax), %rdi

