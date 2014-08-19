; RUN:  llvm-dis < %s.bc| FileCheck %s
; RUN:  verify-uselistorder < %s.bc

; calling-conventions.3.2.ll.bc was generated by passing this file to llvm-as-3.2.
; The test checks that LLVM does not silently misread calling conventions of
; older bitcode files.

declare ccc void @ccc()
; CHECK: declare void @ccc

declare fastcc void @fastcc()
; CHECK: declare fastcc void @fastcc

declare coldcc void @coldcc()
; CHECK: declare coldcc void @coldcc

declare cc10 void @cc10()
; CHECK: declare cc10 void @cc10

declare spir_kernel void @spir_kernel()
; CHECK: declare spir_kernel void @spir_kernel

declare spir_func void @spir_func()
; CHECK: declare spir_func void @spir_func

declare intel_ocl_bicc void @intel_ocl_bicc()
; CHECK: declare intel_ocl_bicc void @intel_ocl_bicc

declare x86_stdcallcc void @x86_stdcallcc()
; CHECK: declare x86_stdcallcc void @x86_stdcallcc 

declare x86_fastcallcc void @x86_fastcallcc()
; CHECK: declare x86_fastcallcc void @x86_fastcallcc 

declare x86_thiscallcc void @x86_thiscallcc()
; CHECK: declare x86_thiscallcc void @x86_thiscallcc

declare arm_apcscc void @arm_apcscc()
; CHECK: declare arm_apcscc void @arm_apcscc

declare arm_aapcscc void @arm_aapcscc()
; CHECK: declare arm_aapcscc void @arm_aapcscc

declare arm_aapcs_vfpcc void @arm_aapcs_vfpcc()
; CHECK: declare arm_aapcs_vfpcc void @arm_aapcs_vfpcc

declare msp430_intrcc void @msp430_intrcc()
; CHECK: declare msp430_intrcc void @msp430_intrcc

declare ptx_kernel void @ptx_kernel()
; CHECK: declare ptx_kernel void @ptx_kernel

declare ptx_device void @ptx_device()
; CHECK: declare ptx_device void @ptx_device

define void @call_ccc() { 
; CHECK: call void @ccc
  call ccc void @ccc()
  ret void
}

define void @call_fastcc() { 
; CHECK: call fastcc void @fastcc
  call fastcc void @fastcc()
  ret void
}

define void @call_coldcc() { 
; CHECK: call coldcc void @coldcc
  call coldcc void @coldcc()
  ret void
}

define void @call_cc10 () { 
; CHECK: call cc10 void @cc10 
  call cc10 void @cc10 ()
  ret void
}

define void @call_spir_kernel() { 
; CHECK: call spir_kernel void @spir_kernel
  call spir_kernel void @spir_kernel()
  ret void
}

define void @call_spir_func() { 
; CHECK: call spir_func void @spir_func
  call spir_func void @spir_func()
  ret void
}

define void @call_intel_ocl_bicc() { 
; CHECK: call intel_ocl_bicc void @intel_ocl_bicc 
  call intel_ocl_bicc void @intel_ocl_bicc()
  ret void
}

define void @call_x86_stdcallcc() { 
; CHECK: call x86_stdcallcc void @x86_stdcallcc
  call x86_stdcallcc void @x86_stdcallcc()
  ret void
}

define void @call_x86_fastcallcc() { 
; CHECK: call x86_fastcallcc void @x86_fastcallcc
  call x86_fastcallcc void @x86_fastcallcc()
  ret void
}

define void @call_x86_thiscallcc() { 
; CHECK: call x86_thiscallcc void @x86_thiscallcc 
  call x86_thiscallcc void @x86_thiscallcc()
  ret void
}

define void @call_arm_apcscc() { 
; CHECK: call arm_apcscc void @arm_apcscc
  call arm_apcscc void @arm_apcscc()
  ret void
}

define void @call_arm_aapcscc() { 
; CHECK: call arm_aapcscc void @arm_aapcscc
  call arm_aapcscc void @arm_aapcscc()
  ret void
}

define void @call_arm_aapcs_vfpcc() { 
; CHECK: call arm_aapcs_vfpcc void @arm_aapcs_vfpcc
  call arm_aapcs_vfpcc void @arm_aapcs_vfpcc()
  ret void
}

define void @call_msp430_intrcc() { 
; CHECK: call msp430_intrcc void @msp430_intrcc
  call msp430_intrcc void @msp430_intrcc()
  ret void
}

define void @call_ptx_kernel() { 
; CHECK: call ptx_kernel void @ptx_kernel
  call ptx_kernel void @ptx_kernel()
  ret void
}

define void @call_ptx_device() { 
; CHECK: call ptx_device void @ptx_device
  call ptx_device void @ptx_device()
  ret void
}

