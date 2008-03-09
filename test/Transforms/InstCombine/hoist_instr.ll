; RUN: llvm-as < %s | opt -instcombine | llvm-dis | \
; RUN:   %prcontext div 1 | grep then:

;; This tests that the div is hoisted into the then block.
define i32 @foo(i1 %C, i32 %A, i32 %B) {
entry:
        br i1 %C, label %then, label %endif

then:           ; preds = %entry
        br label %endif

endif:          ; preds = %then, %entry
        %X = phi i32 [ %A, %then ], [ 15, %entry ]              ; <i32> [#uses=1]
        %Y = sdiv i32 %X, 42            ; <i32> [#uses=1]
        ret i32 %Y
}

