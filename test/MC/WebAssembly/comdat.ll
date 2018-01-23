; RUN: llc -mtriple wasm32-unknown-unknown-wasm -filetype=obj %s -o - | obj2yaml | FileCheck %s

; Import a function just so we can check the index arithmetic for
; WASM_COMDAT_FUNCTION entries is performed correctly
declare i32 @funcImport()
define i32 @callImport() {
entry:
  %call = call i32 @funcImport()
  ret i32 %call
}

; Function in its own COMDAT
$basicInlineFn = comdat any
define linkonce_odr i32 @basicInlineFn() #1 comdat {
  ret i32 0
}

; Global, data, and function in same COMDAT
$sharedComdat = comdat any
@constantData = weak_odr constant [3 x i8] c"abc", comdat($sharedComdat)
define linkonce_odr i32 @sharedFn() #1 comdat($sharedComdat) {
  ret i32 0
}

; CHECK:      Sections:        
; CHECK-NEXT:   - Type:            TYPE
; CHECK-NEXT:     Signatures:      
; CHECK-NEXT:       - Index:           0
; CHECK-NEXT:         ReturnType:      I32
; CHECK-NEXT:         ParamTypes:      
; CHECK-NEXT:   - Type:            IMPORT
; CHECK-NEXT:     Imports:         
; CHECK-NEXT:       - Module:          env
; CHECK-NEXT:         Field:           __linear_memory
; CHECK-NEXT:         Kind:            MEMORY
; CHECK-NEXT:         Memory:          
; CHECK-NEXT:           Initial:         0x00000001
; CHECK-NEXT:       - Module:          env
; CHECK-NEXT:         Field:           __indirect_function_table
; CHECK-NEXT:         Kind:            TABLE
; CHECK-NEXT:         Table:           
; CHECK-NEXT:           ElemType:        ANYFUNC
; CHECK-NEXT:           Limits:          
; CHECK-NEXT:             Initial:         0x00000000
; CHECK-NEXT:       - Module:          env
; CHECK-NEXT:         Field:           funcImport
; CHECK-NEXT:         Kind:            FUNCTION
; CHECK-NEXT:         SigIndex:        0
; CHECK-NEXT:   - Type:            FUNCTION
; CHECK-NEXT:     FunctionTypes:   [ 0, 0, 0 ]
; CHECK-NEXT:   - Type:            GLOBAL
; CHECK-NEXT:     Globals:         
; CHECK-NEXT:       - Index:           0
; CHECK-NEXT:         Type:            I32
; CHECK-NEXT:         Mutable:         false
; CHECK-NEXT:         InitExpr:        
; CHECK-NEXT:           Opcode:          I32_CONST
; CHECK-NEXT:           Value:           0
; CHECK-NEXT:  - Type:            EXPORT
; CHECK-NEXT:    Exports:
; CHECK-NEXT:      - Name:            callImport
; CHECK-NEXT:        Kind:            FUNCTION
; CHECK-NEXT:        Index:           1
; CHECK-NEXT:      - Name:            basicInlineFn
; CHECK-NEXT:        Kind:            FUNCTION
; CHECK-NEXT:        Index:           2
; CHECK-NEXT:      - Name:            sharedFn
; CHECK-NEXT:        Kind:            FUNCTION
; CHECK-NEXT:        Index:           3
; CHECK-NEXT:      - Name:            constantData
; CHECK-NEXT:        Kind:            GLOBAL
; CHECK-NEXT:        Index:           0
; CHECK-NEXT:  - Type:            CODE
; CHECK-NEXT:    Relocations:
; CHECK-NEXT:      - Type:            R_WEBASSEMBLY_FUNCTION_INDEX_LEB
; CHECK-NEXT:        Index:           0
; CHECK-NEXT:        Offset:          0x00000004
; CHECK-NEXT:    Functions:
; CHECK-NEXT:      - Index:           1
; CHECK-NEXT:        Locals:
; CHECK-NEXT:        Body:            1080808080000B
; CHECK-NEXT:      - Index:           2
; CHECK-NEXT:        Locals:
; CHECK-NEXT:        Body:            41000B
; CHECK-NEXT:      - Index:           3
; CHECK-NEXT:        Locals:
; CHECK-NEXT:        Body:            41000B
; CHECK-NEXT:  - Type:            DATA
; CHECK-NEXT:    Segments:
; CHECK-NEXT:      - SectionOffset:   6
; CHECK-NEXT:        MemoryIndex:     0
; CHECK-NEXT:        Offset:
; CHECK-NEXT:          Opcode:          I32_CONST
; CHECK-NEXT:          Value:           0
; CHECK-NEXT:        Content:         '616263'
; CHECK-NEXT:  - Type:            CUSTOM
; CHECK-NEXT:    Name:            linking
; CHECK-NEXT:    DataSize:        3
; CHECK-NEXT:    SymbolInfo:
; CHECK-NEXT:      - Name:            basicInlineFn
; CHECK-NEXT:        Flags:           [ BINDING_WEAK ]
; CHECK-NEXT:      - Name:            sharedFn
; CHECK-NEXT:        Flags:           [ BINDING_WEAK ]
; CHECK-NEXT:      - Name:            constantData
; CHECK-NEXT:        Flags:           [ BINDING_WEAK ]
; CHECK-NEXT:    SegmentInfo:
; CHECK-NEXT:      - Index:           0
; CHECK-NEXT:        Name:            .rodata.constantData
; CHECK-NEXT:        Alignment:       1
; CHECK-NEXT:        Flags:           [  ]
; CHECK-NEXT:    Comdats:
; CHECK-NEXT:      - Name:            basicInlineFn
; CHECK-NEXT:        Entries:
; CHECK-NEXT:          - Kind:            FUNCTION
; CHECK-NEXT:            Index:           2
; CHECK-NEXT:      - Name:            sharedComdat
; CHECK-NEXT:        Entries:
; CHECK-NEXT:          - Kind:            FUNCTION
; CHECK-NEXT:            Index:           3
; CHECK-NEXT:          - Kind:            DATA
; CHECK-NEXT:            Index:           0
; CHECK-NEXT: ...
