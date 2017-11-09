; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-unknown-unknown -print-schedule -mcpu=i686 | FileCheck %s --check-prefix=CHECK --check-prefix=GENERIC
; RUN: llc < %s -mtriple=i686-unknown-unknown -print-schedule -mcpu=atom | FileCheck %s --check-prefix=CHECK --check-prefix=ATOM
; RUN: llc < %s -mtriple=i686-unknown-unknown -print-schedule -mcpu=slm | FileCheck %s --check-prefix=CHECK --check-prefix=SLM
; RUN: llc < %s -mtriple=i686-unknown-unknown -print-schedule -mcpu=sandybridge | FileCheck %s --check-prefix=CHECK --check-prefix=SANDY
; RUN: llc < %s -mtriple=i686-unknown-unknown -print-schedule -mcpu=ivybridge | FileCheck %s --check-prefix=CHECK --check-prefix=SANDY
; RUN: llc < %s -mtriple=i686-unknown-unknown -print-schedule -mcpu=haswell | FileCheck %s --check-prefix=CHECK --check-prefix=HASWELL
; RUN: llc < %s -mtriple=i686-unknown-unknown -print-schedule -mcpu=broadwell | FileCheck %s --check-prefix=CHECK --check-prefix=BROADWELL
; RUN: llc < %s -mtriple=i686-unknown-unknown -print-schedule -mcpu=skylake | FileCheck %s --check-prefix=CHECK --check-prefix=SKYLAKE
; RUN: llc < %s -mtriple=i686-unknown-unknown -print-schedule -mcpu=skx | FileCheck %s --check-prefix=CHECK --check-prefix=SKX
; RUN: llc < %s -mtriple=i686-unknown-unknown -print-schedule -mcpu=btver2 | FileCheck %s --check-prefix=CHECK --check-prefix=BTVER2
; RUN: llc < %s -mtriple=i686-unknown-unknown -print-schedule -mcpu=znver1 | FileCheck %s --check-prefix=CHECK --check-prefix=ZNVER1

define i8 @test_aaa(i8 %a0) optsize {
; GENERIC-LABEL: test_aaa:
; GENERIC:       # BB#0:
; GENERIC-NEXT:    movb {{[0-9]+}}(%esp), %al
; GENERIC-NEXT:    #APP
; GENERIC-NEXT:    aaa
; GENERIC-NEXT:    #NO_APP
; GENERIC-NEXT:    retl
;
; ATOM-LABEL: test_aaa:
; ATOM:       # BB#0:
; ATOM-NEXT:    movb {{[0-9]+}}(%esp), %al # sched: [1:1.00]
; ATOM-NEXT:    #APP
; ATOM-NEXT:    aaa # sched: [13:6.50]
; ATOM-NEXT:    #NO_APP
; ATOM-NEXT:    retl # sched: [79:39.50]
;
; SLM-LABEL: test_aaa:
; SLM:       # BB#0:
; SLM-NEXT:    movb {{[0-9]+}}(%esp), %al # sched: [3:1.00]
; SLM-NEXT:    #APP
; SLM-NEXT:    aaa # sched: [100:1.00]
; SLM-NEXT:    #NO_APP
; SLM-NEXT:    retl # sched: [4:1.00]
;
; SANDY-LABEL: test_aaa:
; SANDY:       # BB#0:
; SANDY-NEXT:    movb {{[0-9]+}}(%esp), %al # sched: [5:0.50]
; SANDY-NEXT:    #APP
; SANDY-NEXT:    aaa # sched: [100:0.33]
; SANDY-NEXT:    #NO_APP
; SANDY-NEXT:    retl # sched: [5:1.00]
;
; HASWELL-LABEL: test_aaa:
; HASWELL:       # BB#0:
; HASWELL-NEXT:    movb {{[0-9]+}}(%esp), %al # sched: [1:0.50]
; HASWELL-NEXT:    #APP
; HASWELL-NEXT:    aaa # sched: [100:0.25]
; HASWELL-NEXT:    #NO_APP
; HASWELL-NEXT:    retl # sched: [5:0.50]
;
; BROADWELL-LABEL: test_aaa:
; BROADWELL:       # BB#0:
; BROADWELL-NEXT:    movb {{[0-9]+}}(%esp), %al # sched: [5:0.50]
; BROADWELL-NEXT:    #APP
; BROADWELL-NEXT:    aaa # sched: [100:0.25]
; BROADWELL-NEXT:    #NO_APP
; BROADWELL-NEXT:    retl # sched: [6:0.50]
;
; SKYLAKE-LABEL: test_aaa:
; SKYLAKE:       # BB#0:
; SKYLAKE-NEXT:    movb {{[0-9]+}}(%esp), %al # sched: [5:0.50]
; SKYLAKE-NEXT:    #APP
; SKYLAKE-NEXT:    aaa # sched: [100:0.25]
; SKYLAKE-NEXT:    #NO_APP
; SKYLAKE-NEXT:    retl # sched: [6:0.50]
;
; SKX-LABEL: test_aaa:
; SKX:       # BB#0:
; SKX-NEXT:    movb {{[0-9]+}}(%esp), %al # sched: [5:0.50]
; SKX-NEXT:    #APP
; SKX-NEXT:    aaa # sched: [100:0.25]
; SKX-NEXT:    #NO_APP
; SKX-NEXT:    retl # sched: [6:0.50]
;
; BTVER2-LABEL: test_aaa:
; BTVER2:       # BB#0:
; BTVER2-NEXT:    movb {{[0-9]+}}(%esp), %al # sched: [5:1.00]
; BTVER2-NEXT:    #APP
; BTVER2-NEXT:    aaa # sched: [100:0.17]
; BTVER2-NEXT:    #NO_APP
; BTVER2-NEXT:    retl # sched: [4:1.00]
;
; ZNVER1-LABEL: test_aaa:
; ZNVER1:       # BB#0:
; ZNVER1-NEXT:    movb {{[0-9]+}}(%esp), %al # sched: [8:0.50]
; ZNVER1-NEXT:    #APP
; ZNVER1-NEXT:    aaa # sched: [100:?]
; ZNVER1-NEXT:    #NO_APP
; ZNVER1-NEXT:    retl # sched: [1:0.50]
  %1 = tail call i8 asm "aaa", "=r,r"(i8 %a0) nounwind
  ret i8 %1
}

define i8 @test_aad(i16 %a0) optsize {
; GENERIC-LABEL: test_aad:
; GENERIC:       # BB#0:
; GENERIC-NEXT:    movzwl {{[0-9]+}}(%esp), %eax
; GENERIC-NEXT:    #APP
; GENERIC-NEXT:    aad
; GENERIC-NEXT:    #NO_APP
; GENERIC-NEXT:    retl
;
; ATOM-LABEL: test_aad:
; ATOM:       # BB#0:
; ATOM-NEXT:    movzwl {{[0-9]+}}(%esp), %eax # sched: [1:1.00]
; ATOM-NEXT:    #APP
; ATOM-NEXT:    aad # sched: [7:3.50]
; ATOM-NEXT:    #NO_APP
; ATOM-NEXT:    retl # sched: [79:39.50]
;
; SLM-LABEL: test_aad:
; SLM:       # BB#0:
; SLM-NEXT:    movzwl {{[0-9]+}}(%esp), %eax # sched: [4:1.00]
; SLM-NEXT:    #APP
; SLM-NEXT:    aad # sched: [100:1.00]
; SLM-NEXT:    #NO_APP
; SLM-NEXT:    retl # sched: [4:1.00]
;
; SANDY-LABEL: test_aad:
; SANDY:       # BB#0:
; SANDY-NEXT:    movzwl {{[0-9]+}}(%esp), %eax # sched: [5:0.50]
; SANDY-NEXT:    #APP
; SANDY-NEXT:    aad # sched: [100:0.33]
; SANDY-NEXT:    #NO_APP
; SANDY-NEXT:    retl # sched: [5:1.00]
;
; HASWELL-LABEL: test_aad:
; HASWELL:       # BB#0:
; HASWELL-NEXT:    movzwl {{[0-9]+}}(%esp), %eax # sched: [4:0.50]
; HASWELL-NEXT:    #APP
; HASWELL-NEXT:    aad # sched: [100:0.25]
; HASWELL-NEXT:    #NO_APP
; HASWELL-NEXT:    retl # sched: [5:0.50]
;
; BROADWELL-LABEL: test_aad:
; BROADWELL:       # BB#0:
; BROADWELL-NEXT:    movzwl {{[0-9]+}}(%esp), %eax # sched: [5:0.50]
; BROADWELL-NEXT:    #APP
; BROADWELL-NEXT:    aad # sched: [100:0.25]
; BROADWELL-NEXT:    #NO_APP
; BROADWELL-NEXT:    retl # sched: [6:0.50]
;
; SKYLAKE-LABEL: test_aad:
; SKYLAKE:       # BB#0:
; SKYLAKE-NEXT:    movzwl {{[0-9]+}}(%esp), %eax # sched: [5:0.50]
; SKYLAKE-NEXT:    #APP
; SKYLAKE-NEXT:    aad # sched: [100:0.25]
; SKYLAKE-NEXT:    #NO_APP
; SKYLAKE-NEXT:    retl # sched: [6:0.50]
;
; SKX-LABEL: test_aad:
; SKX:       # BB#0:
; SKX-NEXT:    movzwl {{[0-9]+}}(%esp), %eax # sched: [5:0.50]
; SKX-NEXT:    #APP
; SKX-NEXT:    aad # sched: [100:0.25]
; SKX-NEXT:    #NO_APP
; SKX-NEXT:    retl # sched: [6:0.50]
;
; BTVER2-LABEL: test_aad:
; BTVER2:       # BB#0:
; BTVER2-NEXT:    movzwl {{[0-9]+}}(%esp), %eax # sched: [4:1.00]
; BTVER2-NEXT:    #APP
; BTVER2-NEXT:    aad # sched: [100:0.17]
; BTVER2-NEXT:    #NO_APP
; BTVER2-NEXT:    retl # sched: [4:1.00]
;
; ZNVER1-LABEL: test_aad:
; ZNVER1:       # BB#0:
; ZNVER1-NEXT:    movzwl {{[0-9]+}}(%esp), %eax # sched: [8:0.50]
; ZNVER1-NEXT:    #APP
; ZNVER1-NEXT:    aad # sched: [100:?]
; ZNVER1-NEXT:    #NO_APP
; ZNVER1-NEXT:    retl # sched: [1:0.50]
  %1 = tail call i8 asm "aad", "=r,r"(i16 %a0) nounwind
  ret i8 %1
}

define i16 @test_aam(i8 %a0) optsize {
; GENERIC-LABEL: test_aam:
; GENERIC:       # BB#0:
; GENERIC-NEXT:    movb {{[0-9]+}}(%esp), %al
; GENERIC-NEXT:    #APP
; GENERIC-NEXT:    aam
; GENERIC-NEXT:    #NO_APP
; GENERIC-NEXT:    retl
;
; ATOM-LABEL: test_aam:
; ATOM:       # BB#0:
; ATOM-NEXT:    movb {{[0-9]+}}(%esp), %al # sched: [1:1.00]
; ATOM-NEXT:    #APP
; ATOM-NEXT:    aam # sched: [21:10.50]
; ATOM-NEXT:    #NO_APP
; ATOM-NEXT:    retl # sched: [79:39.50]
;
; SLM-LABEL: test_aam:
; SLM:       # BB#0:
; SLM-NEXT:    movb {{[0-9]+}}(%esp), %al # sched: [3:1.00]
; SLM-NEXT:    #APP
; SLM-NEXT:    aam # sched: [100:1.00]
; SLM-NEXT:    #NO_APP
; SLM-NEXT:    retl # sched: [4:1.00]
;
; SANDY-LABEL: test_aam:
; SANDY:       # BB#0:
; SANDY-NEXT:    movb {{[0-9]+}}(%esp), %al # sched: [5:0.50]
; SANDY-NEXT:    #APP
; SANDY-NEXT:    aam # sched: [100:0.33]
; SANDY-NEXT:    #NO_APP
; SANDY-NEXT:    retl # sched: [5:1.00]
;
; HASWELL-LABEL: test_aam:
; HASWELL:       # BB#0:
; HASWELL-NEXT:    movb {{[0-9]+}}(%esp), %al # sched: [1:0.50]
; HASWELL-NEXT:    #APP
; HASWELL-NEXT:    aam # sched: [100:0.25]
; HASWELL-NEXT:    #NO_APP
; HASWELL-NEXT:    retl # sched: [5:0.50]
;
; BROADWELL-LABEL: test_aam:
; BROADWELL:       # BB#0:
; BROADWELL-NEXT:    movb {{[0-9]+}}(%esp), %al # sched: [5:0.50]
; BROADWELL-NEXT:    #APP
; BROADWELL-NEXT:    aam # sched: [100:0.25]
; BROADWELL-NEXT:    #NO_APP
; BROADWELL-NEXT:    retl # sched: [6:0.50]
;
; SKYLAKE-LABEL: test_aam:
; SKYLAKE:       # BB#0:
; SKYLAKE-NEXT:    movb {{[0-9]+}}(%esp), %al # sched: [5:0.50]
; SKYLAKE-NEXT:    #APP
; SKYLAKE-NEXT:    aam # sched: [100:0.25]
; SKYLAKE-NEXT:    #NO_APP
; SKYLAKE-NEXT:    retl # sched: [6:0.50]
;
; SKX-LABEL: test_aam:
; SKX:       # BB#0:
; SKX-NEXT:    movb {{[0-9]+}}(%esp), %al # sched: [5:0.50]
; SKX-NEXT:    #APP
; SKX-NEXT:    aam # sched: [100:0.25]
; SKX-NEXT:    #NO_APP
; SKX-NEXT:    retl # sched: [6:0.50]
;
; BTVER2-LABEL: test_aam:
; BTVER2:       # BB#0:
; BTVER2-NEXT:    movb {{[0-9]+}}(%esp), %al # sched: [5:1.00]
; BTVER2-NEXT:    #APP
; BTVER2-NEXT:    aam # sched: [100:0.17]
; BTVER2-NEXT:    #NO_APP
; BTVER2-NEXT:    retl # sched: [4:1.00]
;
; ZNVER1-LABEL: test_aam:
; ZNVER1:       # BB#0:
; ZNVER1-NEXT:    movb {{[0-9]+}}(%esp), %al # sched: [8:0.50]
; ZNVER1-NEXT:    #APP
; ZNVER1-NEXT:    aam # sched: [100:?]
; ZNVER1-NEXT:    #NO_APP
; ZNVER1-NEXT:    retl # sched: [1:0.50]
  %1 = tail call i16 asm "aam", "=r,r"(i8 %a0) nounwind
  ret i16 %1
}

define i8 @test_aas(i8 %a0) optsize {
; GENERIC-LABEL: test_aas:
; GENERIC:       # BB#0:
; GENERIC-NEXT:    movb {{[0-9]+}}(%esp), %al
; GENERIC-NEXT:    #APP
; GENERIC-NEXT:    aas
; GENERIC-NEXT:    #NO_APP
; GENERIC-NEXT:    retl
;
; ATOM-LABEL: test_aas:
; ATOM:       # BB#0:
; ATOM-NEXT:    movb {{[0-9]+}}(%esp), %al # sched: [1:1.00]
; ATOM-NEXT:    #APP
; ATOM-NEXT:    aas # sched: [13:6.50]
; ATOM-NEXT:    #NO_APP
; ATOM-NEXT:    retl # sched: [79:39.50]
;
; SLM-LABEL: test_aas:
; SLM:       # BB#0:
; SLM-NEXT:    movb {{[0-9]+}}(%esp), %al # sched: [3:1.00]
; SLM-NEXT:    #APP
; SLM-NEXT:    aas # sched: [100:1.00]
; SLM-NEXT:    #NO_APP
; SLM-NEXT:    retl # sched: [4:1.00]
;
; SANDY-LABEL: test_aas:
; SANDY:       # BB#0:
; SANDY-NEXT:    movb {{[0-9]+}}(%esp), %al # sched: [5:0.50]
; SANDY-NEXT:    #APP
; SANDY-NEXT:    aas # sched: [100:0.33]
; SANDY-NEXT:    #NO_APP
; SANDY-NEXT:    retl # sched: [5:1.00]
;
; HASWELL-LABEL: test_aas:
; HASWELL:       # BB#0:
; HASWELL-NEXT:    movb {{[0-9]+}}(%esp), %al # sched: [1:0.50]
; HASWELL-NEXT:    #APP
; HASWELL-NEXT:    aas # sched: [100:0.25]
; HASWELL-NEXT:    #NO_APP
; HASWELL-NEXT:    retl # sched: [5:0.50]
;
; BROADWELL-LABEL: test_aas:
; BROADWELL:       # BB#0:
; BROADWELL-NEXT:    movb {{[0-9]+}}(%esp), %al # sched: [5:0.50]
; BROADWELL-NEXT:    #APP
; BROADWELL-NEXT:    aas # sched: [100:0.25]
; BROADWELL-NEXT:    #NO_APP
; BROADWELL-NEXT:    retl # sched: [6:0.50]
;
; SKYLAKE-LABEL: test_aas:
; SKYLAKE:       # BB#0:
; SKYLAKE-NEXT:    movb {{[0-9]+}}(%esp), %al # sched: [5:0.50]
; SKYLAKE-NEXT:    #APP
; SKYLAKE-NEXT:    aas # sched: [100:0.25]
; SKYLAKE-NEXT:    #NO_APP
; SKYLAKE-NEXT:    retl # sched: [6:0.50]
;
; SKX-LABEL: test_aas:
; SKX:       # BB#0:
; SKX-NEXT:    movb {{[0-9]+}}(%esp), %al # sched: [5:0.50]
; SKX-NEXT:    #APP
; SKX-NEXT:    aas # sched: [100:0.25]
; SKX-NEXT:    #NO_APP
; SKX-NEXT:    retl # sched: [6:0.50]
;
; BTVER2-LABEL: test_aas:
; BTVER2:       # BB#0:
; BTVER2-NEXT:    movb {{[0-9]+}}(%esp), %al # sched: [5:1.00]
; BTVER2-NEXT:    #APP
; BTVER2-NEXT:    aas # sched: [100:0.17]
; BTVER2-NEXT:    #NO_APP
; BTVER2-NEXT:    retl # sched: [4:1.00]
;
; ZNVER1-LABEL: test_aas:
; ZNVER1:       # BB#0:
; ZNVER1-NEXT:    movb {{[0-9]+}}(%esp), %al # sched: [8:0.50]
; ZNVER1-NEXT:    #APP
; ZNVER1-NEXT:    aas # sched: [100:?]
; ZNVER1-NEXT:    #NO_APP
; ZNVER1-NEXT:    retl # sched: [1:0.50]
  %1 = tail call i8 asm "aas", "=r,r"(i8 %a0) nounwind
  ret i8 %1
}
