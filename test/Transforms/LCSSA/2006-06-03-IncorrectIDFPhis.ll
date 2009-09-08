; RUN: opt %s -lcssa | llvm-dis | \
; RUN:   grep {%%SJE.0.0.lcssa = phi .struct.SetJmpMapEntry}
; RUN: opt %s -lcssa | llvm-dis | \
; RUN:   grep {%%SJE.0.0.lcssa1 = phi .struct.SetJmpMapEntry}

        %struct.SetJmpMapEntry = type { i8*, i32, %struct.SetJmpMapEntry* }

define void @__llvm_sjljeh_try_catching_longjmp_exception() {
entry:
        br i1 false, label %UnifiedReturnBlock, label %no_exit
no_exit:                ; preds = %endif, %entry
        %SJE.0.0 = phi %struct.SetJmpMapEntry* [ %tmp.24, %endif ], [ null, %entry ]            ; <%struct.SetJmpMapEntry*> [#uses=1]
        br i1 false, label %then, label %endif
then:           ; preds = %no_exit
        %tmp.20 = getelementptr %struct.SetJmpMapEntry* %SJE.0.0, i32 0, i32 1          ; <i32*> [#uses=0]
        ret void
endif:          ; preds = %no_exit
        %tmp.24 = load %struct.SetJmpMapEntry** null            ; <%struct.SetJmpMapEntry*> [#uses=1]
        br i1 false, label %UnifiedReturnBlock, label %no_exit
UnifiedReturnBlock:             ; preds = %endif, %entry
        ret void
}

