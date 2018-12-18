# NOTE: Assertions have been autogenerated by utils/update_mca_test_checks.py
# RUN: llvm-mca -march=aarch64 -mcpu=exynos-m1 -resource-pressure=false < %s | FileCheck %s -check-prefixes=ALL,EM1
# RUN: llvm-mca -march=aarch64 -mcpu=exynos-m3 -resource-pressure=false < %s | FileCheck %s -check-prefixes=ALL,EM3

  ldrb	w0, [x1, x2, lsl #0]
  ldrh	w3, [x4, x5, sxtx #1]
  ldr	w6, [x7, w8, uxtw #2]
  ldr	x9, [x10, w11, sxtw #3]
  ldr	b12, [x13, w14, sxtw #0]
  ldr	h15, [x16, w17, uxtw #1]
  ldr	s18, [x19, x20, sxtx #2]
  ldr	d21, [x22, x23, lsl #3]
  ldr	q24, [x25, x26, lsl #4]

  strb	w0, [x1, x2, lsl #0]
  strh	w3, [x4, x5, sxtx #1]
  str	w6, [x7, w8, uxtw #2]
  str	x9, [x10, w11, sxtw #3]
  str	b12, [x13, w14, sxtw #0]
  str	h15, [x16, w17, uxtw #1]
  str	s18, [x19, x20, sxtx #2]
  str	d21, [x22, x23, lsl #3]
  str	q24, [x25, x26, lsl #4]

# ALL:      Iterations:        100
# ALL-NEXT: Instructions:      1800

# EM1-NEXT: Total Cycles:      1719
# EM3-NEXT: Total Cycles:      1713

# ALL-NEXT: Total uOps:        2800

# EM1:      Dispatch Width:    4
# EM1-NEXT: uOps Per Cycle:    1.63
# EM1-NEXT: IPC:               1.05
# EM1-NEXT: Block RThroughput: 12.0

# EM3:      Dispatch Width:    6
# EM3-NEXT: uOps Per Cycle:    1.63
# EM3-NEXT: IPC:               1.05
# EM3-NEXT: Block RThroughput: 9.0

# ALL:      Instruction Info:
# ALL-NEXT: [1]: #uOps
# ALL-NEXT: [2]: Latency
# ALL-NEXT: [3]: RThroughput
# ALL-NEXT: [4]: MayLoad
# ALL-NEXT: [5]: MayStore
# ALL-NEXT: [6]: HasSideEffects (U)

# ALL:      [1]    [2]    [3]    [4]    [5]    [6]    Instructions:

# EM1-NEXT:  1      5     1.00    *                   ldrb	w0, [x1, x2, lsl #0]
# EM1-NEXT:  1      5     1.00    *                   ldrh	w3, [x4, x5, sxtx #1]
# EM1-NEXT:  2      5     1.00    *                   ldr	w6, [x7, w8, uxtw #2]
# EM1-NEXT:  2      5     1.00    *                   ldr	x9, [x10, w11, sxtw #3]
# EM1-NEXT:  2      6     2.00    *                   ldr	b12, [x13, w14, sxtw #0]
# EM1-NEXT:  2      6     2.00    *                   ldr	h15, [x16, w17, uxtw #1]
# EM1-NEXT:  1      5     1.00    *                   ldr	s18, [x19, x20, sxtx #2]
# EM1-NEXT:  1      5     1.00    *                   ldr	d21, [x22, x23, lsl #3]
# EM1-NEXT:  2      6     2.00    *                   ldr	q24, [x25, x26, lsl #4]

# EM3-NEXT:  1      5     0.50    *                   ldrb	w0, [x1, x2, lsl #0]
# EM3-NEXT:  1      5     0.50    *                   ldrh	w3, [x4, x5, sxtx #1]
# EM3-NEXT:  2      5     0.50    *                   ldr	w6, [x7, w8, uxtw #2]
# EM3-NEXT:  2      5     0.50    *                   ldr	x9, [x10, w11, sxtw #3]
# EM3-NEXT:  2      6     0.50    *                   ldr	b12, [x13, w14, sxtw #0]
# EM3-NEXT:  2      6     0.50    *                   ldr	h15, [x16, w17, uxtw #1]
# EM3-NEXT:  1      5     0.50    *                   ldr	s18, [x19, x20, sxtx #2]
# EM3-NEXT:  1      5     0.50    *                   ldr	d21, [x22, x23, lsl #3]
# EM3-NEXT:  2      6     0.50    *                   ldr	q24, [x25, x26, lsl #4]

# ALL-NEXT:  1      1     1.00           *            strb	w0, [x1, x2, lsl #0]
# ALL-NEXT:  1      1     1.00           *            strh	w3, [x4, x5, sxtx #1]
# ALL-NEXT:  2      2     1.00           *            str	w6, [x7, w8, uxtw #2]
# ALL-NEXT:  2      2     1.00           *            str	x9, [x10, w11, sxtw #3]
# ALL-NEXT:  2      3     1.00           *            str	b12, [x13, w14, sxtw #0]
# ALL-NEXT:  2      3     1.00           *            str	h15, [x16, w17, uxtw #1]
# ALL-NEXT:  1      1     1.00           *            str	s18, [x19, x20, sxtx #2]
# ALL-NEXT:  1      1     1.00           *            str	d21, [x22, x23, lsl #3]
# ALL-NEXT:  2      3     1.00           *            str	q24, [x25, x26, lsl #4]
