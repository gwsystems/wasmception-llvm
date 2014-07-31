; RUN: llvm-as < %s | llvm-dis | not grep getelementptr
; RUN: verify-uselistorder %s -preserve-bc-use-list-order

@A = external global { float }          ; <{ float }*> [#uses=2]
global i32* bitcast ({ float }* @A to i32*)             ; <i32**>:0 [#uses=0]
