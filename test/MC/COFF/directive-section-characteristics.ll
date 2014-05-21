; RUN: llc -mtriple i686-windows -filetype obj -o - %s | llvm-readobj -sections \
; RUN:    | FileCheck %s

define dllexport void @function() {
entry:
  ret void
}

; CHECK: Section {
; CHECK:   Name: .drectve
; CHECK:   Characteristics [
; CHECK:     IMAGE_SCN_ALIGN_1BYTES
; CHECK:     IMAGE_SCN_LNK_INFO
; CHECK:     IMAGE_SCN_LNK_REMOVE
; CHECK:   ]
; CHECK: }

