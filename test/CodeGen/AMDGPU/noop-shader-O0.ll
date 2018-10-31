; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -O0 -mtriple=amdgcn-amd-amdpal -mcpu=gfx900 -verify-machineinstrs < %s | FileCheck -check-prefix=GCN %s

; Ensure NOOP shaders compile at OptNone.

; Confirm registers reserved in SIMachineFunctionInfo are those expected during
; lowering, even when e.g. spilling is required due to being at OptNone.

target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5"
target triple = "amdgcn-amd-amdpal"

define amdgpu_vs void @noop_vs() {
; GCN-LABEL: noop_vs:
; GCN:       ; %bb.0: ; %entry
; GCN-NEXT:    s_endpgm
entry:
  ret void
}

define amdgpu_ls void @noop_ls() {
; GCN-LABEL: noop_ls:
; GCN:       ; %bb.0: ; %entry
; GCN-NEXT:    s_endpgm
entry:
  ret void
}

define amdgpu_hs void @noop_hs() {
; GCN-LABEL: noop_hs:
; GCN:       ; %bb.0: ; %entry
; GCN-NEXT:    s_endpgm
entry:
  ret void
}

define amdgpu_es void @noop_es() {
; GCN-LABEL: noop_es:
; GCN:       ; %bb.0: ; %entry
; GCN-NEXT:    s_endpgm
entry:
  ret void
}

define amdgpu_gs void @noop_gs() {
; GCN-LABEL: noop_gs:
; GCN:       ; %bb.0: ; %entry
; GCN-NEXT:    s_endpgm
entry:
  ret void
}

define amdgpu_ps void @noop_ps() {
; GCN-LABEL: noop_ps:
; GCN:       ; %bb.0: ; %entry
; GCN-NEXT:    s_endpgm
entry:
  ret void
}

define amdgpu_cs void @noop_cs() {
; GCN-LABEL: noop_cs:
; GCN:       ; %bb.0: ; %entry
; GCN-NEXT:    s_endpgm
entry:
  ret void
}
