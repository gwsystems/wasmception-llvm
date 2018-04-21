# NOTE: Assertions have been autogenerated by utils/update_mca_test_checks.py
# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=znver1 -instruction-tables < %s | FileCheck %s

f2xm1

fabs

fadd %st(0), %st(1)
fadd %st(2)
fadds (%ecx)
faddl (%ecx)
faddp %st(1)
faddp %st(2)
fiadds (%ecx)
fiaddl (%ecx)

fbld (%ecx)
fbstp (%eax)

fchs

fnclex

fcmovb %st(1), %st(0)
fcmovbe %st(1), %st(0)
fcmove %st(1), %st(0)
fcmovnb %st(1), %st(0)
fcmovnbe %st(1), %st(0)
fcmovne %st(1), %st(0)
fcmovnu %st(1), %st(0)
fcmovu %st(1), %st(0)

fcom %st(1)
fcom %st(3)
fcoms (%ecx)
fcoml (%eax)
fcomp %st(1)
fcomp %st(3)
fcomps (%ecx)
fcompl (%eax)
fcompp

fcomi %st(3)
fcompi %st(3)

fcos

fdecstp

fdiv %st(0), %st(1)
fdiv %st(2)
fdivs (%ecx)
fdivl (%eax)
fdivp %st(1)
fdivp %st(2)
fidivs (%ecx)
fidivl (%eax)

fdivr %st(0), %st(1)
fdivr %st(2)
fdivrs (%ecx)
fdivrl (%eax)
fdivrp %st(1)
fdivrp %st(2)
fidivrs (%ecx)
fidivrl (%eax)

ffree %st(0)

ficoms (%ecx)
ficoml (%eax)
ficomps (%ecx)
ficompl (%eax)

filds (%edx)
fildl (%ecx)
fildll (%eax)

fincstp

fninit

fists (%edx)
fistl (%ecx)
fistps (%edx)
fistpl (%ecx)
fistpll (%eax)

fisttps (%edx)
fisttpl (%ecx)
fisttpll (%eax)

fld %st(0)
flds (%edx)
fldl (%ecx)
fldt (%eax)

fldcw (%eax)
fldenv (%eax)

fld1
fldl2e
fldl2t
fldlg2
fldln2
fldpi
fldz

fmul %st(0), %st(1)
fmul %st(2)
fmuls (%ecx)
fmull (%eax)
fmulp %st(1)
fmulp %st(2)
fimuls (%ecx)
fimull (%eax)

fnop

fpatan

fprem
fprem1

fptan

frndint

frstor (%eax)

fnsave (%eax)

fscale

fsin

fsincos

fsqrt

fst %st(0)
fsts (%edx)
fstl (%ecx)
fstp %st(0)
fstpl (%edx)
fstpl (%ecx)
fstpt (%eax)

fnstcw (%eax)
fnstenv (%eax)
fnstsw (%eax)

frstor (%eax)
fsave (%eax)

fsub %st(0), %st(1)
fsub %st(2)
fsubs (%ecx)
fsubl (%eax)
fsubp %st(1)
fsubp %st(2)
fisubs (%ecx)
fisubl (%eax)

fsubr %st(0), %st(1)
fsubr %st(2)
fsubrs (%ecx)
fsubrl (%eax)
fsubrp %st(1)
fsubrp %st(2)
fisubrs (%ecx)
fisubrl (%eax)

ftst

fucom %st(1)
fucom %st(3)
fucomp %st(1)
fucomp %st(3)
fucompp

fucomi %st(3)
fucompi %st(3)

fwait

fxam

fxch %st(1)
fxch %st(3)

fxrstor (%eax)
fxsave (%eax)

fxtract

fyl2x
fyl2xp1

# CHECK:      Instruction Info:
# CHECK-NEXT: [1]: #uOps
# CHECK-NEXT: [2]: Latency
# CHECK-NEXT: [3]: RThroughput
# CHECK-NEXT: [4]: MayLoad
# CHECK-NEXT: [5]: MayStore
# CHECK-NEXT: [6]: HasSideEffects

# CHECK:      [1]    [2]    [3]    [4]    [5]    [6]	Instructions:
# CHECK-NEXT:  1      100    -                    * 	f2xm1
# CHECK-NEXT:  1      2     1.00                  * 	fabs
# CHECK-NEXT:  1      3     1.00                  * 	fadd	%st(0), %st(1)
# CHECK-NEXT:  1      3     1.00                  * 	fadd	%st(2)
# CHECK-NEXT:  1      10    1.00    *             * 	fadds	(%ecx)
# CHECK-NEXT:  1      10    1.00    *             * 	faddl	(%ecx)
# CHECK-NEXT:  1      3     1.00                  * 	faddp	%st(1)
# CHECK-NEXT:  1      3     1.00                  * 	faddp	%st(2)
# CHECK-NEXT:  1      10    1.00    *             * 	fiadds	(%ecx)
# CHECK-NEXT:  1      10    1.00    *             * 	fiaddl	(%ecx)
# CHECK-NEXT:  1      100    -                    * 	fbld	(%ecx)
# CHECK-NEXT:  1      100    -                    * 	fbstp	(%eax)
# CHECK-NEXT:  1      1     1.00                  * 	fchs
# CHECK-NEXT:  1      100    -                    * 	fnclex
# CHECK-NEXT:  1      100    -                    * 	fcmovb	%st(1), %st(0)
# CHECK-NEXT:  1      100    -                    * 	fcmovbe	%st(1), %st(0)
# CHECK-NEXT:  1      100    -                    * 	fcmove	%st(1), %st(0)
# CHECK-NEXT:  1      100    -                    * 	fcmovnb	%st(1), %st(0)
# CHECK-NEXT:  1      100    -                    * 	fcmovnbe	%st(1), %st(0)
# CHECK-NEXT:  1      100    -                    * 	fcmovne	%st(1), %st(0)
# CHECK-NEXT:  1      100    -                    * 	fcmovnu	%st(1), %st(0)
# CHECK-NEXT:  1      100    -                    * 	fcmovu	%st(1), %st(0)
# CHECK-NEXT:  1      1     1.00                  * 	fcom	%st(1)
# CHECK-NEXT:  1      1     1.00                  * 	fcom	%st(3)
# CHECK-NEXT:  1      8     1.00                  * 	fcoms	(%ecx)
# CHECK-NEXT:  1      8     1.00                  * 	fcoml	(%eax)
# CHECK-NEXT:  1      1     1.00                  * 	fcomp	%st(1)
# CHECK-NEXT:  1      1     1.00                  * 	fcomp	%st(3)
# CHECK-NEXT:  1      8     1.00                  * 	fcomps	(%ecx)
# CHECK-NEXT:  1      8     1.00                  * 	fcompl	(%eax)
# CHECK-NEXT:  1      1     1.00                  * 	fcompp
# CHECK-NEXT:  1      9     0.50                  * 	fcomi	%st(3)
# CHECK-NEXT:  1      9     0.50                  * 	fcompi	%st(3)
# CHECK-NEXT:  1      100    -                    * 	fcos
# CHECK-NEXT:  1      11    1.00                  * 	fdecstp
# CHECK-NEXT:  1      15    1.00                  * 	fdiv	%st(0), %st(1)
# CHECK-NEXT:  1      15    1.00                  * 	fdiv	%st(2)
# CHECK-NEXT:  1      22    1.00    *             * 	fdivs	(%ecx)
# CHECK-NEXT:  1      22    1.00    *             * 	fdivl	(%eax)
# CHECK-NEXT:  1      15    1.00                  * 	fdivp	%st(1)
# CHECK-NEXT:  1      15    1.00                  * 	fdivp	%st(2)
# CHECK-NEXT:  1      22    1.00    *             * 	fidivs	(%ecx)
# CHECK-NEXT:  1      22    1.00    *             * 	fidivl	(%eax)
# CHECK-NEXT:  1      15    1.00                  * 	fdivr	%st(0), %st(1)
# CHECK-NEXT:  1      15    1.00                  * 	fdivr	%st(2)
# CHECK-NEXT:  1      22    1.00    *             * 	fdivrs	(%ecx)
# CHECK-NEXT:  1      22    1.00    *             * 	fdivrl	(%eax)
# CHECK-NEXT:  1      15    1.00                  * 	fdivrp	%st(1)
# CHECK-NEXT:  1      15    1.00                  * 	fdivrp	%st(2)
# CHECK-NEXT:  1      22    1.00    *             * 	fidivrs	(%ecx)
# CHECK-NEXT:  1      22    1.00    *             * 	fidivrl	(%eax)
# CHECK-NEXT:  1      11    1.00                  * 	ffree	%st(0)
# CHECK-NEXT:  2      12    1.50                  * 	ficoms	(%ecx)
# CHECK-NEXT:  2      12    1.50                  * 	ficoml	(%eax)
# CHECK-NEXT:  2      12    1.50                  * 	ficomps	(%ecx)
# CHECK-NEXT:  2      12    1.50                  * 	ficompl	(%eax)
# CHECK-NEXT:  2      11    1.00    *             * 	filds	(%edx)
# CHECK-NEXT:  2      11    1.00    *             * 	fildl	(%ecx)
# CHECK-NEXT:  2      11    1.00    *             * 	fildll	(%eax)
# CHECK-NEXT:  1      11    1.00                  * 	fincstp
# CHECK-NEXT:  1      100    -                    * 	fninit
# CHECK-NEXT:  1      12    0.50           *      * 	fists	(%edx)
# CHECK-NEXT:  1      12    0.50           *      * 	fistl	(%ecx)
# CHECK-NEXT:  1      12    0.50           *      * 	fistps	(%edx)
# CHECK-NEXT:  1      12    0.50           *      * 	fistpl	(%ecx)
# CHECK-NEXT:  1      12    0.50           *      * 	fistpll	(%eax)
# CHECK-NEXT:  1      12    0.50           *      * 	fisttps	(%edx)
# CHECK-NEXT:  1      12    0.50           *      * 	fisttpl	(%ecx)
# CHECK-NEXT:  1      12    0.50           *      * 	fisttpll	(%eax)
# CHECK-NEXT:  1      1     0.50                  * 	fld	%st(0)
# CHECK-NEXT:  1      8     0.50    *             * 	flds	(%edx)
# CHECK-NEXT:  1      8     0.50    *             * 	fldl	(%ecx)
# CHECK-NEXT:  2      1     0.50    *             * 	fldt	(%eax)
# CHECK-NEXT:  1      100    -      *             * 	fldcw	(%eax)
# CHECK-NEXT:  1      100    -                    * 	fldenv	(%eax)
# CHECK-NEXT:  1      11    1.00                  * 	fld1
# CHECK-NEXT:  1      11    1.00                  * 	fldl2e
# CHECK-NEXT:  1      11    1.00                  * 	fldl2t
# CHECK-NEXT:  1      11    1.00                  * 	fldlg2
# CHECK-NEXT:  1      11    1.00                  * 	fldln2
# CHECK-NEXT:  1      11    1.00                  * 	fldpi
# CHECK-NEXT:  1      8     0.50                  * 	fldz
# CHECK-NEXT:  1      5     1.00                  * 	fmul	%st(0), %st(1)
# CHECK-NEXT:  1      5     1.00                  * 	fmul	%st(2)
# CHECK-NEXT:  1      12    1.00    *             * 	fmuls	(%ecx)
# CHECK-NEXT:  1      12    1.00    *             * 	fmull	(%eax)
# CHECK-NEXT:  1      5     1.00                  * 	fmulp	%st(1)
# CHECK-NEXT:  1      5     1.00                  * 	fmulp	%st(2)
# CHECK-NEXT:  1      12    1.00    *             * 	fimuls	(%ecx)
# CHECK-NEXT:  1      12    1.00    *             * 	fimull	(%eax)
# CHECK-NEXT:  1      1     1.00                  * 	fnop
# CHECK-NEXT:  1      100    -                    * 	fpatan
# CHECK-NEXT:  1      100    -                    * 	fprem
# CHECK-NEXT:  1      100    -                    * 	fprem1
# CHECK-NEXT:  1      100    -                    * 	fptan
# CHECK-NEXT:  1      100    -                    * 	frndint
# CHECK-NEXT:  1      100    -                    * 	frstor	(%eax)
# CHECK-NEXT:  1      100    -                    * 	fnsave	(%eax)
# CHECK-NEXT:  1      100    -                    * 	fscale
# CHECK-NEXT:  1      100    -                    * 	fsin
# CHECK-NEXT:  1      100    -                    * 	fsincos
# CHECK-NEXT:  1      20    1.00                  * 	fsqrt
# CHECK-NEXT:  2      5     0.50                  * 	fst	%st(0)
# CHECK-NEXT:  1      1     0.50           *      * 	fsts	(%edx)
# CHECK-NEXT:  1      1     0.50           *      * 	fstl	(%ecx)
# CHECK-NEXT:  2      5     0.50                  * 	fstp	%st(0)
# CHECK-NEXT:  1      1     0.50           *      * 	fstpl	(%edx)
# CHECK-NEXT:  1      1     0.50           *      * 	fstpl	(%ecx)
# CHECK-NEXT:  1      5     0.50           *      * 	fstpt	(%eax)
# CHECK-NEXT:  1      100    -             *      * 	fnstcw	(%eax)
# CHECK-NEXT:  1      100    -                    * 	fnstenv	(%eax)
# CHECK-NEXT:  1      100    -                    * 	fnstsw	(%eax)
# CHECK-NEXT:  1      100    -                    * 	frstor	(%eax)
# CHECK-NEXT:  1      1     1.00                  * 	wait
# CHECK-NEXT:  1      100    -                    * 	fnsave	(%eax)
# CHECK-NEXT:  1      3     1.00                  * 	fsub	%st(0), %st(1)
# CHECK-NEXT:  1      3     1.00                  * 	fsub	%st(2)
# CHECK-NEXT:  1      10    1.00    *             * 	fsubs	(%ecx)
# CHECK-NEXT:  1      10    1.00    *             * 	fsubl	(%eax)
# CHECK-NEXT:  1      3     1.00                  * 	fsubp	%st(1)
# CHECK-NEXT:  1      3     1.00                  * 	fsubp	%st(2)
# CHECK-NEXT:  1      10    1.00    *             * 	fisubs	(%ecx)
# CHECK-NEXT:  1      10    1.00    *             * 	fisubl	(%eax)
# CHECK-NEXT:  1      3     1.00                  * 	fsubr	%st(0), %st(1)
# CHECK-NEXT:  1      3     1.00                  * 	fsubr	%st(2)
# CHECK-NEXT:  1      10    1.00    *             * 	fsubrs	(%ecx)
# CHECK-NEXT:  1      10    1.00    *             * 	fsubrl	(%eax)
# CHECK-NEXT:  1      3     1.00                  * 	fsubrp	%st(1)
# CHECK-NEXT:  1      3     1.00                  * 	fsubrp	%st(2)
# CHECK-NEXT:  1      10    1.00    *             * 	fisubrs	(%ecx)
# CHECK-NEXT:  1      10    1.00    *             * 	fisubrl	(%eax)
# CHECK-NEXT:  1      1     1.00                  * 	ftst
# CHECK-NEXT:  1      1     1.00                  * 	fucom	%st(1)
# CHECK-NEXT:  1      1     1.00                  * 	fucom	%st(3)
# CHECK-NEXT:  1      1     1.00                  * 	fucomp	%st(1)
# CHECK-NEXT:  1      1     1.00                  * 	fucomp	%st(3)
# CHECK-NEXT:  1      1     1.00                  * 	fucompp
# CHECK-NEXT:  1      9     0.50                  * 	fucomi	%st(3)
# CHECK-NEXT:  1      9     0.50                  * 	fucompi	%st(3)
# CHECK-NEXT:  1      1     1.00                  * 	wait
# CHECK-NEXT:  1      1     1.00                  * 	fxam
# CHECK-NEXT:  1      1     0.25                  * 	fxch	%st(1)
# CHECK-NEXT:  1      1     0.25                  * 	fxch	%st(3)
# CHECK-NEXT:  1      100    -      *      *      * 	fxrstor	(%eax)
# CHECK-NEXT:  1      100    -      *      *      * 	fxsave	(%eax)
# CHECK-NEXT:  1      100    -                    * 	fxtract
# CHECK-NEXT:  1      100    -                    * 	fyl2x
# CHECK-NEXT:  1      100    -                    * 	fyl2xp1

# CHECK:      Resources:
# CHECK-NEXT: [0] - ZnAGU0
# CHECK-NEXT: [1] - ZnAGU1
# CHECK-NEXT: [2] - ZnALU0
# CHECK-NEXT: [3] - ZnALU1
# CHECK-NEXT: [4] - ZnALU2
# CHECK-NEXT: [5] - ZnALU3
# CHECK-NEXT: [6] - ZnDivider
# CHECK-NEXT: [7] - ZnFPU0
# CHECK-NEXT: [8] - ZnFPU1
# CHECK-NEXT: [9] - ZnFPU2
# CHECK-NEXT: [10] - ZnFPU3
# CHECK-NEXT: [11] - ZnMultiplier

# CHECK:      Resource pressure per iteration:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    [10]   [11]
# CHECK-NEXT: 32.50  32.50   -      -      -      -      -     58.50  2.00   8.00   45.50   -

# CHECK:      Resource pressure by instruction:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    [10]   [11]   	Instructions:
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -     	f2xm1
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -     1.00    -     	fabs
# CHECK-NEXT:  -      -      -      -      -      -      -     1.00    -      -      -      -     	fadd	%st(0), %st(1)
# CHECK-NEXT:  -      -      -      -      -      -      -     1.00    -      -      -      -     	fadd	%st(2)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -     1.00    -      -      -      -     	fadds	(%ecx)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -     1.00    -      -      -      -     	faddl	(%ecx)
# CHECK-NEXT:  -      -      -      -      -      -      -     1.00    -      -      -      -     	faddp	%st(1)
# CHECK-NEXT:  -      -      -      -      -      -      -     1.00    -      -      -      -     	faddp	%st(2)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -     1.00    -      -      -      -     	fiadds	(%ecx)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -     1.00    -      -      -      -     	fiaddl	(%ecx)
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -     	fbld	(%ecx)
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -     	fbstp	(%eax)
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -     1.00    -     	fchs
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -     	fnclex
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -     	fcmovb	%st(1), %st(0)
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -     	fcmovbe	%st(1), %st(0)
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -     	fcmove	%st(1), %st(0)
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -     	fcmovnb	%st(1), %st(0)
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -     	fcmovnbe	%st(1), %st(0)
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -     	fcmovne	%st(1), %st(0)
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -     	fcmovnu	%st(1), %st(0)
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -     	fcmovu	%st(1), %st(0)
# CHECK-NEXT:  -      -      -      -      -      -      -     1.00    -      -      -      -     	fcom	%st(1)
# CHECK-NEXT:  -      -      -      -      -      -      -     1.00    -      -      -      -     	fcom	%st(3)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -     1.00    -      -      -      -     	fcoms	(%ecx)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -     1.00    -      -      -      -     	fcoml	(%eax)
# CHECK-NEXT:  -      -      -      -      -      -      -     1.00    -      -      -      -     	fcomp	%st(1)
# CHECK-NEXT:  -      -      -      -      -      -      -     1.00    -      -      -      -     	fcomp	%st(3)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -     1.00    -      -      -      -     	fcomps	(%ecx)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -     1.00    -      -      -      -     	fcompl	(%eax)
# CHECK-NEXT:  -      -      -      -      -      -      -     1.00    -      -      -      -     	fcompp
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -     0.50    -     0.50    -      -     	fcomi	%st(3)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -     0.50    -     0.50    -      -     	fcompi	%st(3)
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -     	fcos
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -      -      -      -     1.00    -     	fdecstp
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -     1.00    -     	fdiv	%st(0), %st(1)
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -     1.00    -     	fdiv	%st(2)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -      -      -      -     1.00    -     	fdivs	(%ecx)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -      -      -      -     1.00    -     	fdivl	(%eax)
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -     1.00    -     	fdivp	%st(1)
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -     1.00    -     	fdivp	%st(2)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -      -      -      -     1.00    -     	fidivs	(%ecx)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -      -      -      -     1.00    -     	fidivl	(%eax)
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -     1.00    -     	fdivr	%st(0), %st(1)
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -     1.00    -     	fdivr	%st(2)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -      -      -      -     1.00    -     	fdivrs	(%ecx)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -      -      -      -     1.00    -     	fdivrl	(%eax)
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -     1.00    -     	fdivrp	%st(1)
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -     1.00    -     	fdivrp	%st(2)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -      -      -      -     1.00    -     	fidivrs	(%ecx)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -      -      -      -     1.00    -     	fidivrl	(%eax)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -      -      -      -     1.00    -     	ffree	%st(0)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -     1.50    -      -     1.50    -     	ficoms	(%ecx)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -     1.50    -      -     1.50    -     	ficoml	(%eax)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -     1.50    -      -     1.50    -     	ficomps	(%ecx)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -     1.50    -      -     1.50    -     	ficompl	(%eax)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -      -      -      -     1.00    -     	filds	(%edx)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -      -      -      -     1.00    -     	fildl	(%ecx)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -      -      -      -     1.00    -     	fildll	(%eax)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -      -      -      -     1.00    -     	fincstp
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -     	fninit
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -      -      -     0.50   0.50    -     	fists	(%edx)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -      -      -     0.50   0.50    -     	fistl	(%ecx)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -      -      -     0.50   0.50    -     	fistps	(%edx)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -      -      -     0.50   0.50    -     	fistpl	(%ecx)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -      -      -     0.50   0.50    -     	fistpll	(%eax)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -      -      -     0.50   0.50    -     	fisttps	(%edx)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -      -      -     0.50   0.50    -     	fisttpl	(%ecx)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -      -      -     0.50   0.50    -     	fisttpll	(%eax)
# CHECK-NEXT:  -      -      -      -      -      -      -      -     0.50    -     0.50    -     	fld	%st(0)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -      -      -      -      -      -     	flds	(%edx)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -      -      -      -      -      -     	fldl	(%ecx)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -      -     0.50    -     0.50    -     	fldt	(%eax)
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -     	fldcw	(%eax)
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -     	fldenv	(%eax)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -      -      -      -     1.00    -     	fld1
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -      -      -      -     1.00    -     	fldl2e
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -      -      -      -     1.00    -     	fldl2t
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -      -      -      -     1.00    -     	fldlg2
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -      -      -      -     1.00    -     	fldln2
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -      -      -      -     1.00    -     	fldpi
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -      -     0.50    -     0.50    -     	fldz
# CHECK-NEXT:  -      -      -      -      -      -      -     1.00    -      -      -      -     	fmul	%st(0), %st(1)
# CHECK-NEXT:  -      -      -      -      -      -      -     1.00    -      -      -      -     	fmul	%st(2)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -     1.00    -      -      -      -     	fmuls	(%ecx)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -     1.00    -      -      -      -     	fmull	(%eax)
# CHECK-NEXT:  -      -      -      -      -      -      -     1.00    -      -      -      -     	fmulp	%st(1)
# CHECK-NEXT:  -      -      -      -      -      -      -     1.00    -      -      -      -     	fmulp	%st(2)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -     1.00    -      -      -      -     	fimuls	(%ecx)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -     1.00    -      -      -      -     	fimull	(%eax)
# CHECK-NEXT:  -      -      -      -      -      -      -     1.00    -      -      -      -     	fnop
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -     	fpatan
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -     	fprem
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -     	fprem1
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -     	fptan
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -     	frndint
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -     	frstor	(%eax)
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -     	fnsave	(%eax)
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -     	fscale
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -     	fsin
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -     	fsincos
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -     1.00    -     	fsqrt
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -     0.50   0.50    -     	fst	%st(0)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -      -      -      -      -      -     	fsts	(%edx)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -      -      -      -      -      -     	fstl	(%ecx)
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -     0.50   0.50    -     	fstp	%st(0)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -      -      -      -      -      -     	fstpl	(%edx)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -      -      -      -      -      -     	fstpl	(%ecx)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -      -      -     0.50   0.50    -     	fstpt	(%eax)
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -     	fnstcw	(%eax)
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -     	fnstenv	(%eax)
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -     	fnstsw	(%eax)
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -     	frstor	(%eax)
# CHECK-NEXT:  -      -      -      -      -      -      -     1.00    -      -      -      -     	wait
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -     	fnsave	(%eax)
# CHECK-NEXT:  -      -      -      -      -      -      -     1.00    -      -      -      -     	fsub	%st(0), %st(1)
# CHECK-NEXT:  -      -      -      -      -      -      -     1.00    -      -      -      -     	fsub	%st(2)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -     1.00    -      -      -      -     	fsubs	(%ecx)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -     1.00    -      -      -      -     	fsubl	(%eax)
# CHECK-NEXT:  -      -      -      -      -      -      -     1.00    -      -      -      -     	fsubp	%st(1)
# CHECK-NEXT:  -      -      -      -      -      -      -     1.00    -      -      -      -     	fsubp	%st(2)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -     1.00    -      -      -      -     	fisubs	(%ecx)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -     1.00    -      -      -      -     	fisubl	(%eax)
# CHECK-NEXT:  -      -      -      -      -      -      -     1.00    -      -      -      -     	fsubr	%st(0), %st(1)
# CHECK-NEXT:  -      -      -      -      -      -      -     1.00    -      -      -      -     	fsubr	%st(2)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -     1.00    -      -      -      -     	fsubrs	(%ecx)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -     1.00    -      -      -      -     	fsubrl	(%eax)
# CHECK-NEXT:  -      -      -      -      -      -      -     1.00    -      -      -      -     	fsubrp	%st(1)
# CHECK-NEXT:  -      -      -      -      -      -      -     1.00    -      -      -      -     	fsubrp	%st(2)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -     1.00    -      -      -      -     	fisubrs	(%ecx)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -     1.00    -      -      -      -     	fisubrl	(%eax)
# CHECK-NEXT:  -      -      -      -      -      -      -     1.00    -      -      -      -     	ftst
# CHECK-NEXT:  -      -      -      -      -      -      -     1.00    -      -      -      -     	fucom	%st(1)
# CHECK-NEXT:  -      -      -      -      -      -      -     1.00    -      -      -      -     	fucom	%st(3)
# CHECK-NEXT:  -      -      -      -      -      -      -     1.00    -      -      -      -     	fucomp	%st(1)
# CHECK-NEXT:  -      -      -      -      -      -      -     1.00    -      -      -      -     	fucomp	%st(3)
# CHECK-NEXT:  -      -      -      -      -      -      -     1.00    -      -      -      -     	fucompp
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -     0.50    -     0.50    -      -     	fucomi	%st(3)
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -     0.50    -     0.50    -      -     	fucompi	%st(3)
# CHECK-NEXT:  -      -      -      -      -      -      -     1.00    -      -      -      -     	wait
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -     1.00    -     	fxam
# CHECK-NEXT:  -      -      -      -      -      -      -     0.25   0.25   0.25   0.25    -     	fxch	%st(1)
# CHECK-NEXT:  -      -      -      -      -      -      -     0.25   0.25   0.25   0.25    -     	fxch	%st(3)
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -     	fxrstor	(%eax)
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -     	fxsave	(%eax)
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -     	fxtract
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -     	fyl2x
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -     	fyl2xp1

