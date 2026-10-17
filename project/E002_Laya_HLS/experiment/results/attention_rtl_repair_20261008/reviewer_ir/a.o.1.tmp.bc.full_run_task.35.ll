define internal fastcc { i16, i32, i64, i32, i16, i32, i64, i32, i8 } @"laya::full::full_run_task.35"(i8 addrspace(1)* noalias nocapture %io, i64 %memory_io, i8 addrspace(1)* noalias nocapture %state0, i64 %memory_state0, i8 addrspace(1)* noalias nocapture %state1, i64 %memory_state1, i8 addrspace(1)* noalias nocapture %qkv0, i64 %memory_qkv0, i8 addrspace(1)* noalias nocapture %qkv1, i64 %memory_qkv1, i8 addrspace(1)* noalias nocapture %ff0, i64 %memory_ff0, i8 addrspace(1)* noalias nocapture %ff1, i64 %memory_ff1, i8 addrspace(1)* noalias nocapture %att_out, i64 %memory_att_out, i32 %t_ctx_task_id.val, i8 %t_ctx_stage.val, i8 %t_ctx_layer.val, i8 %t_ctx_batch.val, i16 %t_ctx_row0.val, i8 %t_prob_id.val, i8 %t_prob_bank.val, i32 %t_prob_epoch.val, i8 %t_kv_id.val, i8 %t_kv_bank.val, i32 %t_kv_epoch.val, i8 %t_partial_id.val, i8 %t_partial_bank.val, i32 %t_partial_epoch.val, i8 %t_dst_id.val, i8 %t_dst_bank.val, i32 %t_dst_epoch.val, i8 %t_head.val, i16 %t_S.val) #1 {
entry:
  %cond = icmp ugt i8 %t_ctx_stage.val, 1
  %cond20 = icmp ult i8 %t_ctx_stage.val, 5
  %cond21 = and i1 %cond20, %cond
  call void (...) @_ssdm_Assume(i1 %cond21) #1
  %cond22 = icmp ult i8 %t_ctx_layer.val, 28
  call void (...) @_ssdm_Assume(i1 %cond22) #1
  %cond23 = icmp ult i16 %t_ctx_row0.val, -15
  call void (...) @_ssdm_Assume(i1 %cond23) #1
  %cond24 = icmp ult i8 %t_head.val, 16
  call void (...) @_ssdm_Assume(i1 %cond24) #1
  call void (...) @_ssdm_Assume(i1 true) #1
  call void (...) @_ssdm_Assume(i1 true) #1
  call void (...) @_ssdm_Assume(i1 true) #1
  call void (...) @_ssdm_Assume(i1 true) #1
  call void (...) @_ssdm_Assume(i1 true) #1
  call void (...) @_ssdm_Assume(i1 true) #1
  call void (...) @_ssdm_Assume(i1 true) #1
  call void (...) @_ssdm_op_SpecInterface(i8 addrspace(1)* %att_out, [6 x i8]* @31, i32 0, i32 0, [1 x i8]* @43, i32 0, i32 0, [8 x i8]* @179, [6 x i8]* @117, [1 x i8]* @43, i32 1, i32 1, i32 16, i32 16, [1 x i8]* @43, [1 x i8]* @43, i32 -1, i32 0, i32 0, i32 1)
  call void (...) @_ssdm_op_SpecInterface(i8 addrspace(1)* %ff1, [6 x i8]* @31, i32 0, i32 0, [1 x i8]* @43, i32 0, i32 0, [4 x i8]* @119, [6 x i8]* @117, [1 x i8]* @43, i32 1, i32 1, i32 16, i32 16, [1 x i8]* @43, [1 x i8]* @43, i32 -1, i32 0, i32 0, i32 1)
  call void (...) @_ssdm_op_SpecInterface(i8 addrspace(1)* %ff0, [6 x i8]* @31, i32 0, i32 0, [1 x i8]* @43, i32 0, i32 0, [4 x i8]* @239, [6 x i8]* @117, [1 x i8]* @43, i32 1, i32 1, i32 16, i32 16, [1 x i8]* @43, [1 x i8]* @43, i32 -1, i32 0, i32 0, i32 1)
  call void (...) @_ssdm_op_SpecInterface(i8 addrspace(1)* %qkv1, [6 x i8]* @31, i32 0, i32 0, [1 x i8]* @43, i32 0, i32 0, [5 x i8]* @116, [6 x i8]* @117, [1 x i8]* @43, i32 1, i32 1, i32 16, i32 16, [1 x i8]* @43, [1 x i8]* @43, i32 -1, i32 0, i32 0, i32 1)
  call void (...) @_ssdm_op_SpecInterface(i8 addrspace(1)* %qkv0, [6 x i8]* @31, i32 0, i32 0, [1 x i8]* @43, i32 0, i32 0, [5 x i8]* @125, [6 x i8]* @117, [1 x i8]* @43, i32 1, i32 1, i32 16, i32 16, [1 x i8]* @43, [1 x i8]* @43, i32 -1, i32 0, i32 0, i32 1)
  call void (...) @_ssdm_op_SpecInterface(i8 addrspace(1)* %state1, [6 x i8]* @31, i32 0, i32 0, [1 x i8]* @43, i32 0, i32 0, [7 x i8]* @131, [6 x i8]* @117, [1 x i8]* @43, i32 1, i32 1, i32 16, i32 16, [1 x i8]* @43, [1 x i8]* @43, i32 -1, i32 0, i32 0, i32 1)
  call void (...) @_ssdm_op_SpecInterface(i8 addrspace(1)* %state0, [6 x i8]* @31, i32 0, i32 0, [1 x i8]* @43, i32 0, i32 0, [7 x i8]* @130, [6 x i8]* @117, [1 x i8]* @43, i32 1, i32 1, i32 16, i32 16, [1 x i8]* @43, [1 x i8]* @43, i32 -1, i32 0, i32 0, i32 1)
  call void (...) @_ssdm_op_SpecInterface(i8 addrspace(1)* %io, [6 x i8]* @31, i32 0, i32 0, [1 x i8]* @43, i32 0, i32 0, [3 x i8]* @118, [6 x i8]* @117, [1 x i8]* @43, i32 1, i32 1, i32 16, i32 16, [1 x i8]* @43, [1 x i8]* @43, i32 -1, i32 0, i32 0, i32 1)
  %raw = alloca [4 x i8], i64 1, align 512
  %"(anonymous namespace)::runtime.request_valid.load" = load i1, i1* @"(anonymous namespace)::runtime.request_valid", align 512, !alias.scope !2829, !noalias !2832
  br i1 %"(anonymous namespace)::runtime.request_valid.load", label %lor.lhs.false.i, label %if.then.i

lor.lhs.false.i:                                  ; preds = %entry
  %"(anonymous namespace)::runtime.model_header_valid.load" = load i1, i1* @"(anonymous namespace)::runtime.model_header_valid", align 512, !alias.scope !2829, !noalias !2832
  br i1 %"(anonymous namespace)::runtime.model_header_valid.load", label %lor.lhs.false1.i, label %if.then.i

lor.lhs.false1.i:                                 ; preds = %lor.lhs.false.i
  %"(anonymous namespace)::runtime.last_task_id.load" = load i32, i32* @"(anonymous namespace)::runtime.last_task_id", align 512, !alias.scope !2829, !noalias !2832
  %add.ln22 = add i32 %"(anonymous namespace)::runtime.last_task_id.load", 1
  %icmp.ln22 = icmp ne i32 %add.ln22, %t_ctx_task_id.val
  %icmp.ln22.8 = icmp eq i32 %t_ctx_task_id.val, -1
  %or.ln22 = or i1 %icmp.ln22, %icmp.ln22.8
  br i1 %or.ln22, label %if.then.i, label %if.end.i

if.then.i:                                        ; preds = %lor.lhs.false1.i, %lor.lhs.false.i, %entry
  br label %_ZN4laya4full4task7contextERKNS0_11FullRuntimeERKNS_11TaskContextE.302.355.exit

if.end.i:                                         ; preds = %lor.lhs.false1.i
  %"(anonymous namespace)::runtime.inputs.identity.B.load" = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.B", align 512, !alias.scope !2829, !noalias !2832
  %"(anonymous namespace)::runtime.inputs.identity.S.load" = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.S", align 512, !alias.scope !2829, !noalias !2832
  %call.ret96 = call fastcc { i16, i32 } @"laya::check_context"(i32 %t_ctx_task_id.val, i8 82, i8 %t_ctx_stage.val, i8 %t_ctx_layer.val, i8 %t_ctx_batch.val, i8 0, i16 %t_ctx_row0.val, i8 16, i16 %"(anonymous namespace)::runtime.inputs.identity.B.load", i16 %"(anonymous namespace)::runtime.inputs.identity.S.load")
  %c.code = extractvalue { i16, i32 } %call.ret96, 0
  %c.detail = extractvalue { i16, i32 } %call.ret96, 1
  br label %_ZN4laya4full4task7contextERKNS0_11FullRuntimeERKNS_11TaskContextE.302.355.exit

_ZN4laya4full4task7contextERKNS0_11FullRuntimeERKNS_11TaskContextE.302.355.exit: ; preds = %if.end.i, %if.then.i
  %c.detail.199.0 = phi i32 [ 122814468, %if.then.i ], [ %c.detail, %if.end.i ]
  %0 = phi i16 [ 7, %if.then.i ], [ %c.code, %if.end.i ]
  %icmp.ln9 = icmp eq i16 %0, 0
  br i1 %icmp.ln9, label %lor.lhs.false, label %if.then

if.then:                                          ; preds = %_ZN4laya4full4task7contextERKNS0_11FullRuntimeERKNS_11TaskContextE.302.355.exit
  %call.ret93 = call fastcc { i16, i32, i64, i32, i16, i32, i64, i32, i8 } @"laya::full::task::finish"(i32 %t_ctx_task_id.val, i8 82, i16 %0, i32 %c.detail.199.0, i64 -1, i32 0, i16 0, i8 0)
  %newret = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret93, 0
  %newret1 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret93, 1
  %newret3 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret93, 2
  %newret5 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret93, 3
  %newret7 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret93, 4
  %newret9 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret93, 5
  %newret11 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret93, 6
  %newret13 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret93, 7
  %newret15 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret93, 8
  br label %cleanup370

lor.lhs.false:                                    ; preds = %_ZN4laya4full4task7contextERKNS0_11FullRuntimeERKNS_11TaskContextE.302.355.exit
  %icmp.ln310 = icmp eq i8 %t_ctx_stage.val, 4
  br i1 %icmp.ln310, label %lor.lhs.false12, label %if.then96

lor.lhs.false12:                                  ; preds = %lor.lhs.false
  %"(anonymous namespace)::runtime.inputs.identity.S.load.6" = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.S", align 512
  %icmp.ln311 = icmp eq i16 %"(anonymous namespace)::runtime.inputs.identity.S.load.6", %t_S.val
  %icmp.ln312 = icmp eq i8 %t_prob_id.val, 38
  %and.ln312 = and i1 %icmp.ln311, %icmp.ln312
  br i1 %and.ln312, label %lor.lhs.false22, label %if.then96

lor.lhs.false22:                                  ; preds = %lor.lhs.false12
  %b.id = load i8, i8* @"(anonymous namespace)::runtime.loaded_kv_ref.id", align 512
  %b.epoch = load i32, i32* @"(anonymous namespace)::runtime.loaded_kv_ref.epoch", align 512
  %icmp.ln20 = icmp eq i8 %b.id, %t_kv_id.val
  %icmp.ln20.18 = icmp eq i8 %t_kv_bank.val, 0
  %and.ln20 = and i1 %icmp.ln20, %icmp.ln20.18
  br i1 %and.ln20, label %land.rhs.i.i, label %_ZN4layaneENS_9BufferRefES0_.exit

land.rhs.i.i:                                     ; preds = %lor.lhs.false22
  %phitmp = icmp ne i32 %b.epoch, %t_kv_epoch.val
  br label %_ZN4layaneENS_9BufferRefES0_.exit

_ZN4layaneENS_9BufferRefES0_.exit:                ; preds = %land.rhs.i.i, %lor.lhs.false22
  %phi.ln21 = phi i1 [ %phitmp, %land.rhs.i.i ], [ true, %lor.lhs.false22 ]
  %"(anonymous namespace)::runtime.load" = load i8, i8* @"(anonymous namespace)::runtime.loaded_kv_head", align 512
  %icmp.ln313 = icmp ne i8 %"(anonymous namespace)::runtime.load", %t_head.val
  %or.ln313 = or i1 %icmp.ln313, %phi.ln21
  br i1 %or.ln313, label %if.then96, label %lor.lhs.false31

lor.lhs.false31:                                  ; preds = %_ZN4layaneENS_9BufferRefES0_.exit
  %icmp.ln314 = icmp ne i8 %t_partial_id.val, 40
  %icmp.ln314.1 = icmp ne i8 %t_partial_bank.val, 0
  %or.ln314 = or i1 %icmp.ln314, %icmp.ln314.1
  %icmp.ln315 = icmp ne i8 %t_dst_id.val, 8
  %or.ln314.1 = or i1 %or.ln314, %icmp.ln315
  br i1 %or.ln314.1, label %if.then96, label %lor.lhs.false41

lor.lhs.false41:                                  ; preds = %lor.lhs.false31
  %"(anonymous namespace)::runtime.score_valid.load" = load i1, i1* @"(anonymous namespace)::runtime.score_valid", align 512
  br i1 %"(anonymous namespace)::runtime.score_valid.load", label %lor.lhs.false42, label %if.then96

lor.lhs.false42:                                  ; preds = %lor.lhs.false41
  %a.id = load i8, i8* @"(anonymous namespace)::runtime.score_ref.id", align 512
  %a.epoch = load i32, i32* @"(anonymous namespace)::runtime.score_ref.epoch", align 512
  %icmp.ln20.19 = icmp ne i8 %a.id, 38
  %icmp.ln20.20 = icmp ne i8 %t_prob_bank.val, 0
  %or.ln20 = or i1 %icmp.ln20.20, %icmp.ln20.19
  %phitmp1 = icmp ne i32 %a.epoch, %t_prob_epoch.val
  %or.ln316 = or i1 %or.ln20, %phitmp1
  br i1 %or.ln316, label %if.then96, label %lor.lhs.false47

lor.lhs.false47:                                  ; preds = %lor.lhs.false42
  %a.id.1 = load i8, i8* @"(anonymous namespace)::runtime.score_kv_ref.id", align 512
  %a.bank = load i8, i8* @"(anonymous namespace)::runtime.score_kv_ref.bank", align 512
  %a.epoch.1 = load i32, i32* @"(anonymous namespace)::runtime.score_kv_ref.epoch", align 512
  %icmp.ln20.21 = icmp eq i8 %a.id.1, %t_kv_id.val
  %icmp.ln20.22 = icmp eq i8 %a.bank, %t_kv_bank.val
  %and.ln20.7 = and i1 %icmp.ln20.21, %icmp.ln20.22
  br i1 %and.ln20.7, label %land.rhs.i.i88, label %_ZN4layaneENS_9BufferRefES0_.exit90

land.rhs.i.i88:                                   ; preds = %lor.lhs.false47
  %phitmp2 = icmp ne i32 %a.epoch.1, %t_kv_epoch.val
  br label %_ZN4layaneENS_9BufferRefES0_.exit90

_ZN4layaneENS_9BufferRefES0_.exit90:              ; preds = %land.rhs.i.i88, %lor.lhs.false47
  %phi.ln21.1 = phi i1 [ %phitmp2, %land.rhs.i.i88 ], [ true, %lor.lhs.false47 ]
  %"(anonymous namespace)::runtime.score_head.load" = load i8, i8* @"(anonymous namespace)::runtime.score_head", align 512
  %icmp.ln317 = icmp ne i8 %"(anonymous namespace)::runtime.score_head.load", %t_head.val
  %or.ln317 = or i1 %icmp.ln317, %phi.ln21.1
  br i1 %or.ln317, label %if.then96, label %lor.lhs.false57

lor.lhs.false57:                                  ; preds = %_ZN4layaneENS_9BufferRefES0_.exit90
  %a.id.2 = load i8, i8* @"(anonymous namespace)runtime.score_qkv_ref.id_0", align 512
  %a.epoch.2 = load i32, i32* @"(anonymous namespace)runtime.score_qkv_ref.epoch_0", align 512
  %b.id.1 = load i8, i8* getelementptr inbounds ([2 x i8], [2 x i8]* @"(anonymous namespace)::runtime.final_qkv_ref.id", i64 0, i64 0), align 512
  %b.bank = load i8, i8* getelementptr inbounds ([2 x i8], [2 x i8]* @"(anonymous namespace)::runtime.final_qkv_ref.bank", i64 0, i64 0), align 512
  %b.epoch.1 = load i32, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"(anonymous namespace)::runtime.final_qkv_ref.epoch", i64 0, i64 0), align 512
  %icmp.ln20.23 = icmp ne i8 %a.id.2, %b.id.1
  %icmp.ln20.24 = icmp ne i8 %b.bank, 0
  %or.ln20.7 = or i1 %icmp.ln20.24, %icmp.ln20.23
  %phitmp3 = icmp ne i32 %a.epoch.2, %b.epoch.1
  %or.ln318 = or i1 %or.ln20.7, %phitmp3
  br i1 %or.ln318, label %if.then96, label %lor.lhs.false62

lor.lhs.false62:                                  ; preds = %lor.lhs.false57
  %a.id.3 = load i8, i8* @"(anonymous namespace)runtime.score_qkv_ref.id_1", align 512
  %a.bank.1 = load i8, i8* @"(anonymous namespace)runtime.score_qkv_ref.bank_1", align 512
  %a.epoch.3 = load i32, i32* @"(anonymous namespace)runtime.score_qkv_ref.epoch_1", align 512
  %b.id.2 = load i8, i8* getelementptr inbounds ([2 x i8], [2 x i8]* @"(anonymous namespace)::runtime.final_qkv_ref.id", i64 0, i64 1), align 8
  %b.bank.1 = load i8, i8* getelementptr inbounds ([2 x i8], [2 x i8]* @"(anonymous namespace)::runtime.final_qkv_ref.bank", i64 0, i64 1), align 1
  %b.epoch.2 = load i32, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"(anonymous namespace)::runtime.final_qkv_ref.epoch", i64 0, i64 1), align 4
  %icmp.ln20.25 = icmp eq i8 %a.id.3, %b.id.2
  %icmp.ln20.26 = icmp eq i8 %a.bank.1, %b.bank.1
  %and.ln20.8 = and i1 %icmp.ln20.25, %icmp.ln20.26
  br i1 %and.ln20.8, label %land.rhs.i.i108, label %_ZN4layaneENS_9BufferRefES0_.exit110

land.rhs.i.i108:                                  ; preds = %lor.lhs.false62
  %phitmp4 = icmp ne i32 %a.epoch.3, %b.epoch.2
  br label %_ZN4layaneENS_9BufferRefES0_.exit110

_ZN4layaneENS_9BufferRefES0_.exit110:             ; preds = %land.rhs.i.i108, %lor.lhs.false62
  %phi.ln21.2 = phi i1 [ %phitmp4, %land.rhs.i.i108 ], [ true, %lor.lhs.false62 ]
  %"(anonymous namespace)::runtime.score_stage.load" = load i8, i8* @"(anonymous namespace)::runtime.score_stage", align 512
  %icmp.ln320 = icmp ne i8 %"(anonymous namespace)::runtime.score_stage.load", 4
  %or.ln319 = or i1 %icmp.ln320, %phi.ln21.2
  br i1 %or.ln319, label %if.then96, label %lor.lhs.false76

lor.lhs.false76:                                  ; preds = %_ZN4layaneENS_9BufferRefES0_.exit110
  %prob.layer = load i8, i8* @"(anonymous namespace)::runtime.score_layer", align 512
  %icmp.ln320.1 = icmp ne i8 %prob.layer, %t_ctx_layer.val
  %"(anonymous namespace)::runtime.score_batch.load" = load i8, i8* @"(anonymous namespace)::runtime.score_batch", align 512
  %icmp.ln321 = icmp ne i8 %"(anonymous namespace)::runtime.score_batch.load", %t_ctx_batch.val
  %or.ln320 = or i1 %icmp.ln320.1, %icmp.ln321
  %"(anonymous namespace)::runtime.score_row0.load" = load i16, i16* @"(anonymous namespace)::runtime.score_row0", align 512
  %icmp.ln321.1 = icmp ne i16 %"(anonymous namespace)::runtime.score_row0.load", %t_ctx_row0.val
  %or.ln320.1 = or i1 %or.ln320, %icmp.ln321.1
  %"(anonymous namespace)::runtime.score_rows.load" = load i8, i8* @"(anonymous namespace)::runtime.score_rows", align 512
  %icmp.ln322 = icmp ne i8 %"(anonymous namespace)::runtime.score_rows.load", 16
  %or.ln320.2 = or i1 %or.ln320.1, %icmp.ln322
  br i1 %or.ln320.2, label %if.then96, label %if.end101

if.then96:                                        ; preds = %lor.lhs.false76, %_ZN4layaneENS_9BufferRefES0_.exit110, %lor.lhs.false57, %_ZN4layaneENS_9BufferRefES0_.exit90, %lor.lhs.false42, %lor.lhs.false41, %lor.lhs.false31, %_ZN4layaneENS_9BufferRefES0_.exit, %lor.lhs.false12, %lor.lhs.false
  %call.ret105 = call fastcc { i16, i32, i64, i32, i16, i32, i64, i32, i8 } @"laya::full::task::finish"(i32 %t_ctx_task_id.val, i8 82, i16 3, i32 122814469, i64 -1, i32 0, i16 0, i8 0)
  %newret17 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret105, 0
  %newret19 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret105, 1
  %newret21 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret105, 2
  %newret23 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret105, 3
  %newret25 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret105, 4
  %newret27 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret105, 5
  %newret29 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret105, 6
  %newret31 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret105, 7
  %newret33 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret105, 8
  br label %cleanup370

if.end101:                                        ; preds = %lor.lhs.false76
  %call.ret14 = call fastcc { i16, i32 } @"laya::full::full_require_owner.6"(i8 38, i8 0, i32 %t_prob_epoch.val, i8 0, i8 4, i8 %t_ctx_layer.val, i8 %t_ctx_batch.val, i8 0, i16 %t_ctx_row0.val, i16 16, i16 %t_S.val, i8 7, i8 %t_ctx_batch.val, i16 %t_ctx_row0.val, i16 16)
  %c.code.128 = extractvalue { i16, i32 } %call.ret14, 0
  %c.detail.137 = extractvalue { i16, i32 } %call.ret14, 1
  %icmp.ln9.141 = icmp eq i16 %c.code.128, 0
  br i1 %icmp.ln9.141, label %if.then127, label %if.end132

if.then127:                                       ; preds = %if.end101
  %call.ret18 = call fastcc { i16, i32 } @"laya::full::full_require_owner.6"(i8 %t_kv_id.val, i8 %t_kv_bank.val, i32 %t_kv_epoch.val, i8 0, i8 4, i8 %t_ctx_layer.val, i8 -1, i8 0, i16 0, i16 %t_S.val, i16 64, i8 1, i8 %t_ctx_batch.val, i16 0, i16 %t_S.val)
  %c.code.129 = extractvalue { i16, i32 } %call.ret18, 0
  %c.detail.138 = extractvalue { i16, i32 } %call.ret18, 1
  br label %if.end132

if.end132:                                        ; preds = %if.then127, %if.end101
  %.116228 = phi i32 [ %c.detail.138, %if.then127 ], [ %c.detail.137, %if.end101 ]
  %1 = phi i16 [ %c.code.129, %if.then127 ], [ %c.code.128, %if.end101 ]
  %icmp.ln9.142 = icmp eq i16 %1, 0
  br i1 %icmp.ln9.142, label %if.then134, label %if.end136

if.then134:                                       ; preds = %if.end132
  %call.ret74 = call fastcc { i16, i32 } @"laya::full::full_check_fill_owner.8"(i8 8, i8 %t_dst_bank.val, i32 %t_dst_epoch.val, i8 0, i8 4, i8 %t_ctx_layer.val, i8 0, i16 %t_S.val, i16 1024)
  %c.code.130 = extractvalue { i16, i32 } %call.ret74, 0
  %c.detail.139 = extractvalue { i16, i32 } %call.ret74, 1
  br label %if.end136

if.end136:                                        ; preds = %if.then134, %if.end132
  %.1162 = phi i32 [ %c.detail.139, %if.then134 ], [ %.116228, %if.end132 ]
  %2 = phi i16 [ %c.code.130, %if.then134 ], [ %1, %if.end132 ]
  %icmp.ln9.143 = icmp eq i16 %2, 0
  br i1 %icmp.ln9.143, label %VITIS_LOOP_334_1, label %if.then138

if.then138:                                       ; preds = %if.end136
  %call.ret117 = call fastcc { i16, i32, i64, i32, i16, i32, i64, i32, i8 } @"laya::full::task::finish"(i32 %t_ctx_task_id.val, i8 82, i16 %2, i32 %.1162, i64 -1, i32 0, i16 0, i8 0)
  %newret35 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret117, 0
  %newret37 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret117, 1
  %newret39 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret117, 2
  %newret41 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret117, 3
  %newret43 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret117, 4
  %newret45 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret117, 5
  %newret47 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret117, 6
  %newret49 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret117, 7
  %newret51 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret117, 8
  br label %cleanup370

VITIS_LOOP_334_1:                                 ; preds = %if.end136
  %zext.ln336 = zext i8 %t_head.val to i64
  %zext.ln336.1 = zext i8 %t_ctx_batch.val to i64
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %VITIS_LOOP_334_1
  %r = phi i32 [ 0, %VITIS_LOOP_334_1 ], [ %r.6, %for.inc ]
  %icmp.ln334 = icmp eq i32 %r, 16
  br i1 %icmp.ln334, label %for.end.critedge, label %for.body

for.body:                                         ; preds = %for.cond
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 0, i64 255, i64 127), !fpga.pragma.source !169
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @1)
  %trunc.ln335 = trunc i32 %r to i16
  %row = add i16 %trunc.ln335, %t_ctx_row0.val
  %zext.ln336.2 = zext i16 %row to i32
  %lshr.ln336 = lshr i32 %zext.ln336.2, 5
  %zext.ln336.3 = zext i32 %lshr.ln336 to i64
  %"(anonymous namespace)::runtime.owners.att_head_rows.addr" = getelementptr [16 x [2 x [32 x i32]]], [16 x [2 x [32 x i32]]]* @"(anonymous namespace)::runtime.owners.att_head_rows", i64 0, i64 %zext.ln336, i64 %zext.ln336.1, i64 %zext.ln336.3
  %"(anonymous namespace)::runtime.owners.att_head_rows.load" = load i32, i32* %"(anonymous namespace)::runtime.owners.att_head_rows.addr", align 4
  %and.ln337 = and i32 %zext.ln336.2, 31
  %shl.ln337 = shl nuw i32 1, %and.ln337
  %and.ln336 = and i32 %"(anonymous namespace)::runtime.owners.att_head_rows.load", %shl.ln337
  %icmp.ln336 = icmp eq i32 %and.ln336, 0
  br i1 %icmp.ln336, label %for.inc, label %if.then160

if.then160:                                       ; preds = %for.body
  %call.ret129 = call fastcc { i16, i32, i64, i32, i16, i32, i64, i32, i8 } @"laya::full::task::finish"(i32 %t_ctx_task_id.val, i8 82, i16 5, i32 67633161, i64 -1, i32 0, i16 0, i8 0)
  %newret53 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret129, 0
  %newret55 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret129, 1
  %newret57 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret129, 2
  %newret59 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret129, 3
  %newret61 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret129, 4
  %newret63 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret129, 5
  %newret65 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret129, 6
  %newret67 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret129, 7
  %newret69 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret129, 8
  br label %cleanup370

for.inc:                                          ; preds = %for.body
  %r.6 = add nuw nsw i32 %r, 1
  br label %for.cond, !llvm.loop !2844

for.end.critedge:                                 ; preds = %for.cond
  %call.ret70 = call fastcc { i16, i32 } @"laya::full::full_claim_owner"(i8 40, i8 0, i32 %t_partial_epoch.val, i8 0, i8 4, i8 %t_ctx_layer.val, i8 %t_ctx_batch.val, i8 0, i16 %t_ctx_row0.val, i16 16, i16 64, i8 1)
  %c.code.131 = extractvalue { i16, i32 } %call.ret70, 0
  %c.detail.140 = extractvalue { i16, i32 } %call.ret70, 1
  %icmp.ln9.144 = icmp eq i16 %c.code.131, 0
  br i1 %icmp.ln9.144, label %if.end190, label %if.then187

if.then187:                                       ; preds = %for.end.critedge
  %call.ret141 = call fastcc { i16, i32, i64, i32, i16, i32, i64, i32, i8 } @"laya::full::task::finish"(i32 %t_ctx_task_id.val, i8 82, i16 %c.code.131, i32 %c.detail.140, i64 -1, i32 0, i16 0, i8 0)
  %newret71 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret141, 0
  %newret73 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret141, 1
  %newret75 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret141, 2
  %newret77 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret141, 3
  %newret79 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret141, 4
  %newret81 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret141, 5
  %newret83 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret141, 6
  %newret85 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret141, 7
  %newret87 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret141, 8
  br label %cleanup370

if.end190:                                        ; preds = %for.end.critedge
  %call.ret80 = call fastcc { i16, i32 } @"laya::full::full_acquire_owner"(i8 38, i8 0, i32 %t_prob_epoch.val, i8 0, i8 4, i8 %t_ctx_layer.val, i8 %t_ctx_batch.val, i8 0, i16 %t_ctx_row0.val, i16 16, i16 %t_S.val, i8 7, i8 %t_ctx_batch.val, i16 %t_ctx_row0.val, i16 16)
  %c.code.132 = extractvalue { i16, i32 } %call.ret80, 0
  %c.detail.141 = extractvalue { i16, i32 } %call.ret80, 1
  %icmp.ln9.145 = icmp eq i16 %c.code.132, 0
  br i1 %icmp.ln9.145, label %if.then200, label %VITIS_LOOP_353_2

if.then200:                                       ; preds = %if.end190
  %call.ret84 = call fastcc { i16, i32 } @"laya::full::full_acquire_owner"(i8 %t_kv_id.val, i8 %t_kv_bank.val, i32 %t_kv_epoch.val, i8 0, i8 4, i8 %t_ctx_layer.val, i8 -1, i8 0, i16 0, i16 %t_S.val, i16 64, i8 1, i8 %t_ctx_batch.val, i16 0, i16 %t_S.val)
  %c.code.133 = extractvalue { i16, i32 } %call.ret84, 0
  %c.detail.142 = extractvalue { i16, i32 } %call.ret84, 1
  %kv_read = icmp eq i16 %c.code.133, 0
  br label %VITIS_LOOP_353_2

VITIS_LOOP_353_2:                                 ; preds = %if.then200, %if.end190
  %c.code.206.0 = phi i16 [ %c.code.133, %if.then200 ], [ %c.code.132, %if.end190 ]
  %.152 = phi i32 [ %c.detail.142, %if.then200 ], [ %c.detail.141, %if.end190 ]
  %p_read = phi i1 [ true, %if.then200 ], [ false, %if.end190 ]
  %kv_read.1 = phi i1 [ %kv_read, %if.then200 ], [ false, %if.end190 ]
  br label %for.cond210

for.cond210:                                      ; preds = %for.inc238, %VITIS_LOOP_353_2
  %c.code.206.1 = phi i16 [ %c.code.206.0, %VITIS_LOOP_353_2 ], [ %c.code.134, %for.inc238 ]
  %r.7 = phi i64 [ 0, %VITIS_LOOP_353_2 ], [ %add.ln353, %for.inc238 ]
  %.262 = phi i64 [ -1, %VITIS_LOOP_353_2 ], [ %c.bad_element, %for.inc238 ]
  %.151 = phi i32 [ %.152, %VITIS_LOOP_353_2 ], [ %c.detail.143, %for.inc238 ]
  %icmp.ln353 = icmp eq i64 %r.7, 16
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 1, i64 16, i64 8)
  br i1 %icmp.ln353, label %for.end241, label %land.rhs

land.rhs:                                         ; preds = %for.cond210
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @222)
  %icmp.ln9.147 = icmp eq i16 %c.code.206.1, 0
  br i1 %icmp.ln9.147, label %for.inc238, label %for.end241

for.inc238:                                       ; preds = %land.rhs
  %tmp = call fastcc { i16, i32, i64 } @"laya::full::av_row"([2 x [16 x [1024 x float]]]* noalias nocapture align 512 @"laya::full::g_full_cache_score", i64 %zext.ln336.1, i64 %r.7, [2 x [2 x [1024 x [64 x float]]]]* noalias nocapture align 512 @"laya::full::g_full_cache_kv", i16 zeroext %t_S.val, [16 x [64 x float]]* noalias nocapture align 256 @"laya::full::g_full_cache_av_partial") #1
  %c.code.134 = extractvalue { i16, i32, i64 } %tmp, 0
  %c.detail.143 = extractvalue { i16, i32, i64 } %tmp, 1
  %c.bad_element = extractvalue { i16, i32, i64 } %tmp, 2
  %add.ln353 = add nuw nsw i64 %r.7, 1
  br label %for.cond210, !llvm.loop !2914

for.end241:                                       ; preds = %land.rhs, %for.cond210
  %.151.lcssa = phi i32 [ %.151, %land.rhs ], [ %.151, %for.cond210 ]
  %.262.lcssa = phi i64 [ %.262, %land.rhs ], [ %.262, %for.cond210 ]
  %c.code.206.1.lcssa = phi i16 [ %c.code.206.1, %land.rhs ], [ %c.code.206.1, %for.cond210 ]
  br i1 %kv_read.1, label %if.then242, label %if.end243

if.then242:                                       ; preds = %for.end241
  %3 = call fastcc { i16, i32 } @"laya::full::full_release_read_owner"(i8 %t_kv_id.val, i8 %t_kv_bank.val, i32 %t_kv_epoch.val, i8 0, i8 4, i8 %t_ctx_layer.val, i8 -1, i8 0, i16 0, i16 %t_S.val, i16 64, i8 1)
  br label %if.end243

if.end243:                                        ; preds = %if.then242, %for.end241
  br i1 %p_read, label %if.then244, label %if.end246

if.then244:                                       ; preds = %if.end243
  %4 = call fastcc { i16, i32 } @"laya::full::full_release_read_owner"(i8 38, i8 0, i32 %t_prob_epoch.val, i8 0, i8 4, i8 %t_ctx_layer.val, i8 %t_ctx_batch.val, i8 0, i16 %t_ctx_row0.val, i16 16, i16 %t_S.val, i8 7)
  br label %if.end246

if.end246:                                        ; preds = %if.then244, %if.end243
  %icmp.ln9.148 = icmp eq i16 %c.code.206.1.lcssa, 0
  br i1 %icmp.ln9.148, label %if.then248, label %if.end257

if.then248:                                       ; preds = %if.end246
  %call.ret62 = call fastcc { i16, i32 } @"laya::full::full_cover_owner"(i8 40, i8 0, i32 %t_partial_epoch.val, i8 0, i8 4, i8 %t_ctx_layer.val, i8 %t_ctx_batch.val, i8 0, i16 %t_ctx_row0.val, i16 16, i16 64, i8 1, i8 %t_ctx_batch.val, i16 %t_ctx_row0.val, i16 16)
  %c.code.135 = extractvalue { i16, i32 } %call.ret62, 0
  %c.detail.144 = extractvalue { i16, i32 } %call.ret62, 1
  br label %if.end257

if.end257:                                        ; preds = %if.then248, %if.end246
  %c.code.206.2 = phi i16 [ %c.code.135, %if.then248 ], [ %c.code.206.1.lcssa, %if.end246 ]
  %.261 = phi i64 [ -1, %if.then248 ], [ %.262.lcssa, %if.end246 ]
  %.150 = phi i32 [ %c.detail.144, %if.then248 ], [ %.151.lcssa, %if.end246 ]
  %icmp.ln9.149 = icmp eq i16 %c.code.206.2, 0
  br i1 %icmp.ln9.149, label %if.then259, label %if.end261

if.then259:                                       ; preds = %if.end257
  %call.ret42 = call fastcc { i16, i32 } @"laya::full::full_publish_owner"(i8 40, i8 0, i32 %t_partial_epoch.val, i8 0, i8 4, i8 %t_ctx_layer.val, i8 %t_ctx_batch.val, i8 0, i16 %t_ctx_row0.val, i16 16, i16 64, i8 1)
  %c.code.136 = extractvalue { i16, i32 } %call.ret42, 0
  %c.detail.145 = extractvalue { i16, i32 } %call.ret42, 1
  br label %if.end261

if.end261:                                        ; preds = %if.then259, %if.end257
  %c.code.206.3 = phi i16 [ %c.code.136, %if.then259 ], [ %c.code.206.2, %if.end257 ]
  %.260 = phi i64 [ -1, %if.then259 ], [ %.261, %if.end257 ]
  %.149 = phi i32 [ %c.detail.145, %if.then259 ], [ %.150, %if.end257 ]
  %icmp.ln9.150 = icmp eq i16 %c.code.206.3, 0
  br i1 %icmp.ln9.150, label %if.then263, label %VITIS_LOOP_368_3

if.then263:                                       ; preds = %if.end261
  %call.ret88 = call fastcc { i16, i32 } @"laya::full::full_acquire_owner"(i8 40, i8 0, i32 %t_partial_epoch.val, i8 0, i8 4, i8 %t_ctx_layer.val, i8 %t_ctx_batch.val, i8 0, i16 %t_ctx_row0.val, i16 16, i16 64, i8 1, i8 %t_ctx_batch.val, i16 %t_ctx_row0.val, i16 16)
  %c.code.137 = extractvalue { i16, i32 } %call.ret88, 0
  %c.detail.146 = extractvalue { i16, i32 } %call.ret88, 1
  %partial_read = icmp eq i16 %c.code.137, 0
  br label %VITIS_LOOP_368_3

VITIS_LOOP_368_3:                                 ; preds = %if.then263, %if.end261
  %c.code.206.4 = phi i16 [ %c.code.137, %if.then263 ], [ %c.code.206.3, %if.end261 ]
  %.259 = phi i64 [ -1, %if.then263 ], [ %.260, %if.end261 ]
  %.148 = phi i32 [ %c.detail.146, %if.then263 ], [ %.149, %if.end261 ]
  %partial_read.1 = phi i1 [ %partial_read, %if.then263 ], [ false, %if.end261 ]
  %zext.ln372 = zext i8 %t_head.val to i16
  %shl.ln372 = shl nuw nsw i16 %zext.ln372, 6
  %raw.addr = getelementptr inbounds [4 x i8], [4 x i8]* %raw, i64 0, i64 0
  %raw.addr.24 = getelementptr inbounds [4 x i8], [4 x i8]* %raw, i64 0, i64 1
  %raw.addr.25 = getelementptr inbounds [4 x i8], [4 x i8]* %raw, i64 0, i64 2
  %raw.addr.26 = getelementptr inbounds [4 x i8], [4 x i8]* %raw, i64 0, i64 3
  br label %for.cond275

for.cond275:                                      ; preds = %for.inc315, %VITIS_LOOP_368_3
  %c.code.206.5 = phi i16 [ %c.code.206.4, %VITIS_LOOP_368_3 ], [ %c.code.142.lcssa, %for.inc315 ]
  %r.8 = phi i64 [ 0, %VITIS_LOOP_368_3 ], [ %add.ln368, %for.inc315 ]
  %.258 = phi i64 [ %.259, %VITIS_LOOP_368_3 ], [ -1, %for.inc315 ]
  %.147 = phi i32 [ %.148, %VITIS_LOOP_368_3 ], [ %c.detail.151.lcssa, %for.inc315 ]
  %r274.0 = phi i32 [ 0, %VITIS_LOOP_368_3 ], [ %r.9, %for.inc315 ]
  %icmp.ln368 = icmp ult i64 %r.8, 16
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 1, i64 16, i64 8)
  br i1 %icmp.ln368, label %land.rhs280, label %for.end318

land.rhs280:                                      ; preds = %for.cond275
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @34)
  %icmp.ln9.152 = icmp eq i16 %c.code.206.5, 0
  br i1 %icmp.ln9.152, label %VITIS_LOOP_369_4, label %for.end318

VITIS_LOOP_369_4:                                 ; preds = %land.rhs280
  %trunc.ln371 = trunc i32 %r274.0 to i16
  %row.2 = add i16 %trunc.ln371, %t_ctx_row0.val
  br label %for.body288

for.body288:                                      ; preds = %_ZN4laya4full4task5writeERNS0_11FullRuntimeERNS0_10FullMemoryENS_9BufferRefEhhttf.2796.3042.3267.3492.3717.3942.4167.4392.4617.4842.5067.5292.5517.5742.exit, %VITIS_LOOP_369_4
  %d = phi i64 [ 0, %VITIS_LOOP_369_4 ], [ %add.ln369, %_ZN4laya4full4task5writeERNS0_11FullRuntimeERNS0_10FullMemoryENS_9BufferRefEhhttf.2796.3042.3267.3492.3717.3942.4167.4392.4617.4842.5067.5292.5517.5742.exit ]
  %d.022 = phi i32 [ 0, %VITIS_LOOP_369_4 ], [ %d.2, %_ZN4laya4full4task5writeERNS0_11FullRuntimeERNS0_10FullMemoryENS_9BufferRefEhhttf.2796.3042.3267.3492.3717.3942.4167.4392.4617.4842.5067.5292.5517.5742.exit ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 0, i64 64, i64 32), !fpga.pragma.source !169
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @16)
  %trunc.ln372 = trunc i32 %d.022 to i16
  %col = add i16 %trunc.ln372, %shl.ln372
  %"laya::full::g_full_cache_av_partial.addr" = getelementptr inbounds [16 x [64 x float]], [16 x [64 x float]]* @"laya::full::g_full_cache_av_partial", i64 0, i64 %r.8, i64 %d
  %value = load float, float* %"laya::full::g_full_cache_av_partial.addr", align 4
  %call.ret13 = call fastcc { i16, i32, i8, i32 } @"laya::full::full_f32_address"(i8 8, i8 %t_dst_bank.val, i32 %t_dst_epoch.val, i8 0, i8 %t_ctx_batch.val, i16 %row.2, i16 %col)
  %c.code.139 = extractvalue { i16, i32, i8, i32 } %call.ret13, 0
  %c.detail.148 = extractvalue { i16, i32, i8, i32 } %call.ret13, 1
  %address.bo = extractvalue { i16, i32, i8, i32 } %call.ret13, 2
  %address.offset = extractvalue { i16, i32, i8, i32 } %call.ret13, 3
  %icmp.ln9.155 = icmp eq i16 %c.code.139, 0
  br i1 %icmp.ln9.155, label %if.end.i130, label %_ZN4laya4full4task5writeERNS0_11FullRuntimeERNS0_10FullMemoryENS_9BufferRefEhhttf.2796.3042.3267.3492.3717.3942.4167.4392.4617.4842.5067.5292.5517.5742.exit

if.end.i130:                                      ; preds = %for.body288
  %bits = bitcast float %value to i32
  %trunc.ln101 = trunc i32 %bits to i8
  store i8 %trunc.ln101, i8* %raw.addr, align 512, !noalias !2919
  %lshr.ln101 = lshr i32 %bits, 8
  %trunc.ln101.8 = trunc i32 %lshr.ln101 to i8
  store i8 %trunc.ln101.8, i8* %raw.addr.24, align 1, !noalias !2919
  %lshr.ln102 = lshr i32 %bits, 16
  %trunc.ln102 = trunc i32 %lshr.ln102 to i8
  store i8 %trunc.ln102, i8* %raw.addr.25, align 2, !noalias !2919
  %lshr.ln102.8 = lshr i32 %bits, 24
  %trunc.ln102.8 = trunc i32 %lshr.ln102.8 to i8
  store i8 %trunc.ln102.8, i8* %raw.addr.26, align 1, !noalias !2919
  %zext.ln103 = zext i32 %address.offset to i64
  %call.ret154 = call fastcc { i16, i32 } @"laya::full::full_write.44"(i8 addrspace(1)* %io, i64 %memory_io, i8 addrspace(1)* %state0, i64 %memory_state0, i8 addrspace(1)* %state1, i64 %memory_state1, i8 addrspace(1)* %qkv0, i64 %memory_qkv0, i8 addrspace(1)* %qkv1, i64 %memory_qkv1, i8 addrspace(1)* %ff0, i64 %memory_ff0, i8 addrspace(1)* %ff1, i64 %memory_ff1, i8 addrspace(1)* %att_out, i64 %memory_att_out, i8 %address.bo, i64 %zext.ln103, [4 x i8]* %raw)
  %newret107 = extractvalue { i16, i32 } %call.ret154, 0
  %newret109 = extractvalue { i16, i32 } %call.ret154, 1
  br label %_ZN4laya4full4task5writeERNS0_11FullRuntimeERNS0_10FullMemoryENS_9BufferRefEhhttf.2796.3042.3267.3492.3717.3942.4167.4392.4617.4842.5067.5292.5517.5742.exit

_ZN4laya4full4task5writeERNS0_11FullRuntimeERNS0_10FullMemoryENS_9BufferRefEhhttf.2796.3042.3267.3492.3717.3942.4167.4392.4617.4842.5067.5292.5517.5742.exit: ; preds = %if.end.i130, %for.body288
  %c.detail.151 = phi i32 [ %newret109, %if.end.i130 ], [ %c.detail.148, %for.body288 ]
  %c.code.142 = phi i16 [ %newret107, %if.end.i130 ], [ %c.code.139, %for.body288 ]
  %icmp.ln9.157 = icmp eq i16 %c.code.142, 0
  %add.ln369 = add nuw nsw i64 %d, 1
  %d.2 = add nuw nsw i32 %d.022, 1
  %icmp.ln369 = icmp ult i64 %add.ln369, 64
  %and.ln374 = and i1 %icmp.ln9.157, %icmp.ln369
  br i1 %and.ln374, label %for.body288, label %for.inc315, !llvm.loop !2951

for.inc315:                                       ; preds = %_ZN4laya4full4task5writeERNS0_11FullRuntimeERNS0_10FullMemoryENS_9BufferRefEhhttf.2796.3042.3267.3492.3717.3942.4167.4392.4617.4842.5067.5292.5517.5742.exit
  %c.code.142.lcssa = phi i16 [ %c.code.142, %_ZN4laya4full4task5writeERNS0_11FullRuntimeERNS0_10FullMemoryENS_9BufferRefEhhttf.2796.3042.3267.3492.3717.3942.4167.4392.4617.4842.5067.5292.5517.5742.exit ]
  %c.detail.151.lcssa = phi i32 [ %c.detail.151, %_ZN4laya4full4task5writeERNS0_11FullRuntimeERNS0_10FullMemoryENS_9BufferRefEhhttf.2796.3042.3267.3492.3717.3942.4167.4392.4617.4842.5067.5292.5517.5742.exit ]
  %add.ln368 = add nuw nsw i64 %r.8, 1
  %r.9 = add nuw nsw i32 %r274.0, 1
  br label %for.cond275, !llvm.loop !2958

for.end318:                                       ; preds = %land.rhs280, %for.cond275
  %.147.lcssa = phi i32 [ %.147, %land.rhs280 ], [ %.147, %for.cond275 ]
  %.258.lcssa = phi i64 [ %.258, %land.rhs280 ], [ %.258, %for.cond275 ]
  %c.code.206.5.lcssa = phi i16 [ %c.code.206.5, %land.rhs280 ], [ %c.code.206.5, %for.cond275 ]
  br i1 %partial_read.1, label %if.then319, label %if.end323

if.then319:                                       ; preds = %for.end318
  %call.ret30 = call fastcc { i16, i32 } @"laya::full::full_release_read_owner"(i8 40, i8 0, i32 %t_partial_epoch.val, i8 0, i8 4, i8 %t_ctx_layer.val, i8 %t_ctx_batch.val, i8 0, i16 %t_ctx_row0.val, i16 16, i16 64, i8 1)
  %c.code.144 = extractvalue { i16, i32 } %call.ret30, 0
  %c.detail.153 = extractvalue { i16, i32 } %call.ret30, 1
  %icmp.ln9.153 = icmp eq i16 %c.code.206.5.lcssa, 0
  %select.ln378 = select i1 %icmp.ln9.153, i16 %c.code.144, i16 %c.code.206.5.lcssa
  %select.ln378.1 = select i1 %icmp.ln9.153, i64 -1, i64 %.258.lcssa
  %select.ln378.2 = select i1 %icmp.ln9.153, i32 %c.detail.153, i32 %.147.lcssa
  br label %if.end323

if.end323:                                        ; preds = %if.then319, %for.end318
  %5 = phi i16 [ %c.code.206.5.lcssa, %for.end318 ], [ %select.ln378, %if.then319 ]
  %.256 = phi i64 [ %.258.lcssa, %for.end318 ], [ %select.ln378.1, %if.then319 ]
  %.145 = phi i32 [ %.147.lcssa, %for.end318 ], [ %select.ln378.2, %if.then319 ]
  %icmp.ln9.154 = icmp eq i16 %5, 0
  br i1 %icmp.ln9.154, label %if.then325, label %if.end335

if.then325:                                       ; preds = %if.end323
  %call.ret66 = call fastcc { i16, i32 } @"laya::full::full_cover_att_head"(i8 %t_dst_bank.val, i32 %t_dst_epoch.val, i8 %t_ctx_layer.val, i16 %t_S.val, i8 %t_head.val, i8 %t_ctx_batch.val, i16 %t_ctx_row0.val)
  %c.code.140 = extractvalue { i16, i32 } %call.ret66, 0
  %c.detail.149 = extractvalue { i16, i32 } %call.ret66, 1
  br label %if.end335

if.end335:                                        ; preds = %if.then325, %if.end323
  %6 = phi i16 [ %c.code.140, %if.then325 ], [ %5, %if.end323 ]
  %.255 = phi i64 [ -1, %if.then325 ], [ %.256, %if.end323 ]
  %.144 = phi i32 [ %c.detail.149, %if.then325 ], [ %.145, %if.end323 ]
  %icmp.ln9.156 = icmp eq i16 %6, 0
  br i1 %icmp.ln9.156, label %if.then337, label %if.end339

if.then337:                                       ; preds = %if.end335
  %call.ret34 = call fastcc { i16, i32 } @"laya::full::full_release_owner"(i8 40, i8 0, i32 %t_partial_epoch.val, i8 0, i8 4, i8 %t_ctx_layer.val, i8 %t_ctx_batch.val, i8 0, i16 %t_ctx_row0.val, i16 16, i16 64, i8 1)
  %c.code.141 = extractvalue { i16, i32 } %call.ret34, 0
  %c.detail.150 = extractvalue { i16, i32 } %call.ret34, 1
  br label %if.end339

if.end339:                                        ; preds = %if.then337, %if.end335
  %7 = phi i16 [ %c.code.141, %if.then337 ], [ %6, %if.end335 ]
  %.254 = phi i64 [ -1, %if.then337 ], [ %.255, %if.end335 ]
  %.143 = phi i32 [ %c.detail.150, %if.then337 ], [ %.144, %if.end335 ]
  %icmp.ln9.158 = icmp eq i16 %7, 0
  br i1 %icmp.ln9.158, label %if.then341, label %if.end343

if.then341:                                       ; preds = %if.end339
  %call.ret38 = call fastcc { i16, i32 } @"laya::full::full_release_owner"(i8 38, i8 0, i32 %t_prob_epoch.val, i8 0, i8 4, i8 %t_ctx_layer.val, i8 %t_ctx_batch.val, i8 0, i16 %t_ctx_row0.val, i16 16, i16 %t_S.val, i8 7)
  %c.code.143 = extractvalue { i16, i32 } %call.ret38, 0
  %c.detail.152 = extractvalue { i16, i32 } %call.ret38, 1
  br label %if.end343

if.end343:                                        ; preds = %if.then341, %if.end339
  %8 = phi i16 [ %c.code.143, %if.then341 ], [ %7, %if.end339 ]
  %.2 = phi i64 [ -1, %if.then341 ], [ %.254, %if.end339 ]
  %.1 = phi i32 [ %c.detail.152, %if.then341 ], [ %.143, %if.end339 ]
  %icmp.ln9.159 = icmp eq i16 %8, 0
  br i1 %icmp.ln9.159, label %if.end355, label %if.then345

if.then345:                                       ; preds = %if.end343
  %9 = call fastcc i16 @"laya::full::full_invalidate_owner"(i8 40, i8 0, i32 %t_partial_epoch.val, i8 0)
  %10 = call fastcc i16 @"laya::full::full_invalidate_owner"(i8 8, i8 %t_dst_bank.val, i32 %t_dst_epoch.val, i8 0)
  %11 = call fastcc i16 @"laya::full::full_invalidate_owner"(i8 38, i8 0, i32 %t_prob_epoch.val, i8 0)
  br label %if.end355

if.end355:                                        ; preds = %if.then345, %if.end343
  store i1 false, i1* @"(anonymous namespace)::runtime.score_valid", align 512
  %call.ret = call fastcc { i16, i32, i64, i32, i16, i32, i64, i32, i8 } @"laya::full::task::finish"(i32 %t_ctx_task_id.val, i8 82, i16 %8, i32 %.1, i64 %.2, i32 1024, i16 0, i8 0)
  %newret89 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret, 0
  %newret91 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret, 1
  %newret93 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret, 2
  %newret95 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret, 3
  %newret97 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret, 4
  %newret99 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret, 5
  %newret101 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret, 6
  %newret103 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret, 7
  %newret105 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret, 8
  br label %cleanup370

cleanup370:                                       ; preds = %if.end355, %if.then187, %if.then160, %if.then138, %if.then96, %if.then
  %agg.result.0.2 = phi i16 [ %newret17, %if.then96 ], [ %newret, %if.then ], [ %newret53, %if.then160 ], [ %newret35, %if.then138 ], [ %newret89, %if.end355 ], [ %newret71, %if.then187 ]
  %agg.result.1.2 = phi i32 [ %newret19, %if.then96 ], [ %newret1, %if.then ], [ %newret55, %if.then160 ], [ %newret37, %if.then138 ], [ %newret91, %if.end355 ], [ %newret73, %if.then187 ]
  %agg.result.2.2 = phi i64 [ %newret21, %if.then96 ], [ %newret3, %if.then ], [ %newret57, %if.then160 ], [ %newret39, %if.then138 ], [ %newret93, %if.end355 ], [ %newret75, %if.then187 ]
  %done_task_id.2 = phi i32 [ %newret23, %if.then96 ], [ %newret5, %if.then ], [ %newret59, %if.then160 ], [ %newret41, %if.then138 ], [ %newret95, %if.end355 ], [ %newret77, %if.then187 ]
  %done_status.2 = phi i16 [ %newret25, %if.then96 ], [ %newret7, %if.then ], [ %newret61, %if.then160 ], [ %newret43, %if.then138 ], [ %newret97, %if.end355 ], [ %newret79, %if.then187 ]
  %done_error_detail.2 = phi i32 [ %newret27, %if.then96 ], [ %newret9, %if.then ], [ %newret63, %if.then160 ], [ %newret45, %if.then138 ], [ %newret99, %if.end355 ], [ %newret81, %if.then187 ]
  %done_bad_element.2 = phi i64 [ %newret29, %if.then96 ], [ %newret11, %if.then ], [ %newret65, %if.then160 ], [ %newret47, %if.then138 ], [ %newret101, %if.end355 ], [ %newret83, %if.then187 ]
  %done_output_elements.2 = phi i32 [ %newret31, %if.then96 ], [ %newret13, %if.then ], [ %newret67, %if.then160 ], [ %newret49, %if.then138 ], [ %newret103, %if.end355 ], [ %newret85, %if.then187 ]
  %done_output_unit.2 = phi i8 [ %newret33, %if.then96 ], [ %newret15, %if.then ], [ %newret69, %if.then160 ], [ %newret51, %if.then138 ], [ %newret105, %if.end355 ], [ %newret87, %if.then187 ]
  %newret2 = insertvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } undef, i16 %agg.result.0.2, 0
  %newret4 = insertvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %newret2, i32 %agg.result.1.2, 1
  %newret6 = insertvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %newret4, i64 %agg.result.2.2, 2
  %newret8 = insertvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %newret6, i32 %done_task_id.2, 3
  %newret10 = insertvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %newret8, i16 %done_status.2, 4
  %newret12 = insertvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %newret10, i32 %done_error_detail.2, 5
  %newret14 = insertvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %newret12, i64 %done_bad_element.2, 6
  %newret16 = insertvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %newret14, i32 %done_output_elements.2, 7
  %newret18 = insertvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %newret16, i8 %done_output_unit.2, 8
  ret { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %newret18
}
