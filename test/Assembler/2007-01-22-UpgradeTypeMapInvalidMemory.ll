; RUN: not llvm-upgrade < %s -o /dev/null -f |& grep {Reference to an undef}
; END.

%d_reduction_0_dparser_gram = global { int (sbyte*, sbyte**, int, int, { %struct.Grammar*, void (\4, %struct.d_loc_t*, sbyte**)*, %struct.D_Scope*, void (\4)*, { int, %struct.d_loc_t, sbyte*, sbyte*, %struct.D_Scope*, void (\8, %struct.d_loc_t*, sbyte**)*, %struct.Grammar*, %struct.ParseNode_User }* (\4, int, { int, %struct.d_loc_t, sbyte*, sbyte*, %struct.D_Scope*, void (\9, %struct.d_loc_t*, sbyte**)*, %struct.Grammar*, %struct.ParseNode_User }**)*, void ({ int, %struct.d_loc_t, sbyte*, sbyte*, %struct.D_Scope*, void (\8, %struct.d_loc_t*, sbyte**)*, %struct.Grammar*, %struct.ParseNode_User }*)*, %struct.d_loc_t, int, int, int, int, int, int, int, int, int, int, int, int }*)*, int (sbyte*, sbyte**, int, int, { %struct.Grammar*, void (\4, %struct.d_loc_t*, sbyte**)*, %struct.D_Scope*, void (\4)*, { int, %struct.d_loc_t, sbyte*, sbyte*, %struct.D_Scope*, void (\8, %struct.d_loc_t*, sbyte**)*, %struct.Grammar*, %struct.ParseNode_User }* (\4, int, { int, %struct.d_loc_t, sbyte*, sbyte*, %struct.D_Scope*, void (\9, %struct.d_loc_t*, sbyte**)*, %struct.Grammar*, %struct.ParseNode_User }**)*, void ({ int, %struct.d_loc_t, sbyte*, sbyte*, %struct.D_Scope*, void (\8, %struct.d_loc_t*, sbyte**)*, %struct.Grammar*, %struct.ParseNode_User }*)*, %struct.d_loc_t, int, int, int, int, int, int, int, int, int, int, int, int }*)** } { int (sbyte*, sbyte**, int, int, { %struct.Grammar*, void (\4, %struct.d_loc_t*, sbyte**)*, %struct.D_Scope*, void (\4)*, { int, %struct.d_loc_t, sbyte*, sbyte*, %struct.D_Scope*, void (\8, %struct.d_loc_t*, sbyte**)*, %struct.Grammar*, %struct.ParseNode_User }* (\4, int, { int, %struct.d_loc_t, sbyte*, sbyte*, %struct.D_Scope*, void (\9, %struct.d_loc_t*, sbyte**)*, %struct.Grammar*, %struct.ParseNode_User }**)*, void ({ int, %struct.d_loc_t, sbyte*, sbyte*, %struct.D_Scope*, void (\8, %struct.d_loc_t*, sbyte**)*, %struct.Grammar*, %struct.ParseNode_User }*)*, %struct.d_loc_t, int, int, int, int, int, int, int, int, int, int, int, int }*)* null, int (sbyte*, sbyte**, int, int, { %struct.Grammar*, void (\4, %struct.d_loc_t*, sbyte**)*, %struct.D_Scope*, void (\4)*, { int, %struct.d_loc_t, sbyte*, sbyte*, %struct.D_Scope*, void (\8, %struct.d_loc_t*, sbyte**)*, %struct.Grammar*, %struct.ParseNode_User }* (\4, int, { int, %struct.d_loc_t, sbyte*, sbyte*, %struct.D_Scope*, void (\9, %struct.d_loc_t*, sbyte**)*, %struct.Grammar*, %struct.ParseNode_User }**)*, void ({ int, %struct.d_loc_t, sbyte*, sbyte*, %struct.D_Scope*, void (\8, %struct.d_loc_t*, sbyte**)*, %struct.Grammar*, %struct.ParseNode_User }*)*, %struct.d_loc_t, int, int, int, int, int, int, int, int, int, int, int, int }*)** null }

implementation
