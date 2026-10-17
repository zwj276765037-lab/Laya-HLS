define internal fastcc { i16, i32, i64, i32, i16, i32, i64, i32, i8 } @"laya::full::full_run_task.33"(i8 addrspace(1)* noalias nocapture %embedding, i64 %memory_embedding, i8 addrspace(1)* noalias nocapture %io, i64 %memory_io, i8 addrspace(1)* noalias nocapture %w_q0, i64 %memory_w_q0, i8 addrspace(1)* noalias nocapture %w_q1, i64 %memory_w_q1, i8 addrspace(1)* noalias nocapture %w_scale, i64 %memory_w_scale, i8 addrspace(1)* noalias nocapture %aux, i64 %memory_aux, i8 addrspace(1)* noalias nocapture %state0, i64 %memory_state0, i8 addrspace(1)* noalias nocapture %state1, i64 %memory_state1, i8 addrspace(1)* noalias nocapture %qkv0, i64 %memory_qkv0, i8 addrspace(1)* noalias nocapture %qkv1, i64 %memory_qkv1, i8 addrspace(1)* noalias nocapture %ff0, i64 %memory_ff0, i8 addrspace(1)* noalias nocapture %ff1, i64 %memory_ff1, i8 addrspace(1)* noalias nocapture %att_out, i64 %memory_att_out, i32 %t_ctx_task_id.val, i8 %t_ctx_stage.val, i8 %t_ctx_layer.val, i8 %t_ctx_batch.val, i16 %t_ctx_row0.val, [2 x i8]* noalias nocapture align 512 %t_qkv_ref_id, [2 x i8]* noalias nocapture align 512 %t_qkv_ref_bank, [2 x i32]* noalias nocapture align 512 %t_qkv_ref_epoch, i8 %t_kv_id.val, i8 %t_kv_bank.val, i32 %t_kv_epoch.val, i8 %t_score_id.val, i8 %t_score_bank.val, i32 %t_score_epoch.val, i8 %t_head.val, i16 %t_S.val) #1 {
entry:
  %cond = icmp ugt i8 %t_ctx_stage.val, 1
  %cond33 = icmp ult i8 %t_ctx_stage.val, 5
  %cond34 = and i1 %cond33, %cond
  call void (...) @_ssdm_Assume(i1 %cond34) #1
  %cond35 = icmp ult i8 %t_ctx_layer.val, 28
  call void (...) @_ssdm_Assume(i1 %cond35) #1
  %cond36 = icmp ult i16 %t_ctx_row0.val, -15
  call void (...) @_ssdm_Assume(i1 %cond36) #1
  %cond37 = icmp ult i8 %t_head.val, 16
  call void (...) @_ssdm_Assume(i1 %cond37) #1
  call void (...) @_ssdm_Assume(i1 true) #1
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
  call void (...) @_ssdm_op_SpecInterface(i8 addrspace(1)* %aux, [6 x i8]* @31, i32 0, i32 0, [1 x i8]* @43, i32 0, i32 0, [4 x i8]* @122, [6 x i8]* @117, [1 x i8]* @43, i32 1, i32 16, i32 16, i32 16, [1 x i8]* @43, [1 x i8]* @43, i32 -1, i32 0, i32 0, i32 1)
  call void (...) @_ssdm_op_SpecInterface(i8 addrspace(1)* %w_scale, [6 x i8]* @31, i32 0, i32 0, [1 x i8]* @43, i32 0, i32 0, [8 x i8]* @64, [6 x i8]* @117, [1 x i8]* @43, i32 1, i32 16, i32 16, i32 16, [1 x i8]* @43, [1 x i8]* @43, i32 -1, i32 0, i32 0, i32 1)
  call void (...) @_ssdm_op_SpecInterface(i8 addrspace(1)* %w_q1, [6 x i8]* @31, i32 0, i32 0, [1 x i8]* @43, i32 0, i32 0, [5 x i8]* @120, [6 x i8]* @117, [1 x i8]* @43, i32 1, i32 16, i32 16, i32 16, [1 x i8]* @43, [1 x i8]* @43, i32 -1, i32 0, i32 0, i32 1)
  call void (...) @_ssdm_op_SpecInterface(i8 addrspace(1)* %w_q0, [6 x i8]* @31, i32 0, i32 0, [1 x i8]* @43, i32 0, i32 0, [5 x i8]* @175, [6 x i8]* @117, [1 x i8]* @43, i32 1, i32 16, i32 16, i32 16, [1 x i8]* @43, [1 x i8]* @43, i32 -1, i32 0, i32 0, i32 1)
  call void (...) @_ssdm_op_SpecInterface(i8 addrspace(1)* %io, [6 x i8]* @31, i32 0, i32 0, [1 x i8]* @43, i32 0, i32 0, [3 x i8]* @118, [6 x i8]* @117, [1 x i8]* @43, i32 1, i32 1, i32 16, i32 16, [1 x i8]* @43, [1 x i8]* @43, i32 -1, i32 0, i32 0, i32 1)
  call void (...) @_ssdm_op_SpecInterface(i8 addrspace(1)* %embedding, [6 x i8]* @31, i32 0, i32 0, [1 x i8]* @43, i32 0, i32 0, [10 x i8]* @176, [6 x i8]* @117, [1 x i8]* @43, i32 1, i32 16, i32 16, i32 16, [1 x i8]* @43, [1 x i8]* @43, i32 -1, i32 0, i32 0, i32 1)
  %refs.id = alloca [2 x i8], i64 1, align 512
  %refs.bank = alloca [2 x i8], i64 1, align 512
  %refs.epoch = alloca [2 x i32], i64 1, align 512
  %qkv.ref.id = alloca [2 x i8], i64 1, align 512
  %qkv.ref.bank = alloca [2 x i8], i64 1, align 512
  %qkv.ref.epoch = alloca [2 x i32], i64 1, align 512
  %qkv.region = alloca [2 x i8], i64 1, align 512
  %qkv.stage = alloca [2 x i8], i64 1, align 512
  %qkv.layer = alloca [2 x i8], i64 1, align 512
  %qkv.batch = alloca [2 x i8], i64 1, align 512
  %qkv.row_space = alloca [2 x i8], i64 1, align 512
  %qkv.row0 = alloca [2 x i16], i64 1, align 512
  %qkv.rows = alloca [2 x i16], i64 1, align 512
  %qkv.width = alloca [2 x i16], i64 1, align 512
  %qkv.content = alloca [2 x i8], i64 1, align 512
  %qk_mask = alloca [1024 x i8], i64 1, align 512
  %q = alloca [64 x float], i64 1, align 512
  %"(anonymous namespace)::runtime.request_valid.load" = load i1, i1* @"(anonymous namespace)::runtime.request_valid", align 512, !alias.scope !3241, !noalias !3244
  br i1 %"(anonymous namespace)::runtime.request_valid.load", label %lor.lhs.false.i, label %if.then.i

lor.lhs.false.i:                                  ; preds = %entry
  %"(anonymous namespace)::runtime.model_header_valid.load" = load i1, i1* @"(anonymous namespace)::runtime.model_header_valid", align 512, !alias.scope !3241, !noalias !3244
  br i1 %"(anonymous namespace)::runtime.model_header_valid.load", label %lor.lhs.false1.i, label %if.then.i

lor.lhs.false1.i:                                 ; preds = %lor.lhs.false.i
  %"(anonymous namespace)::runtime.last_task_id.load" = load i32, i32* @"(anonymous namespace)::runtime.last_task_id", align 512, !alias.scope !3241, !noalias !3244
  %add.ln22 = add i32 %"(anonymous namespace)::runtime.last_task_id.load", 1
  %icmp.ln22 = icmp ne i32 %add.ln22, %t_ctx_task_id.val
  %icmp.ln22.10 = icmp eq i32 %t_ctx_task_id.val, -1
  %or.ln22 = or i1 %icmp.ln22, %icmp.ln22.10
  br i1 %or.ln22, label %if.then.i, label %if.end.i

if.then.i:                                        ; preds = %lor.lhs.false1.i, %lor.lhs.false.i, %entry
  br label %_ZN4laya4full4task7contextERKNS0_11FullRuntimeERKNS_11TaskContextE.302.355.exit

if.end.i:                                         ; preds = %lor.lhs.false1.i
  %"(anonymous namespace)::runtime.inputs.identity.B.load" = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.B", align 512, !alias.scope !3241, !noalias !3244
  %"(anonymous namespace)::runtime.inputs.identity.S.load" = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.S", align 512, !alias.scope !3241, !noalias !3244
  %call.ret71 = call fastcc { i16, i32 } @"laya::check_context"(i32 %t_ctx_task_id.val, i8 80, i8 %t_ctx_stage.val, i8 %t_ctx_layer.val, i8 %t_ctx_batch.val, i8 0, i16 %t_ctx_row0.val, i8 16, i16 %"(anonymous namespace)::runtime.inputs.identity.B.load", i16 %"(anonymous namespace)::runtime.inputs.identity.S.load")
  %c.code = extractvalue { i16, i32 } %call.ret71, 0
  %c.detail = extractvalue { i16, i32 } %call.ret71, 1
  br label %_ZN4laya4full4task7contextERKNS0_11FullRuntimeERKNS_11TaskContextE.302.355.exit

_ZN4laya4full4task7contextERKNS0_11FullRuntimeERKNS_11TaskContextE.302.355.exit: ; preds = %if.end.i, %if.then.i
  %c.detail.228.0 = phi i32 [ 122683396, %if.then.i ], [ %c.detail, %if.end.i ]
  %0 = phi i16 [ 7, %if.then.i ], [ %c.code, %if.end.i ]
  %icmp.ln9 = icmp eq i16 %0, 0
  br i1 %icmp.ln9, label %lor.lhs.false, label %if.then

if.then:                                          ; preds = %_ZN4laya4full4task7contextERKNS0_11FullRuntimeERKNS_11TaskContextE.302.355.exit
  %call.ret117 = call fastcc { i16, i32, i64, i32, i16, i32, i64, i32, i8 } @"laya::full::task::finish"(i32 %t_ctx_task_id.val, i8 80, i16 %0, i32 %c.detail.228.0, i64 -1, i32 0, i16 0, i8 0)
  %newret = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret117, 0
  %newret5 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret117, 1
  %newret7 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret117, 2
  %newret9 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret117, 3
  %newret11 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret117, 4
  %newret13 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret117, 5
  %newret15 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret117, 6
  %newret17 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret117, 7
  %newret19 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret117, 8
  br label %cleanup291

lor.lhs.false:                                    ; preds = %_ZN4laya4full4task7contextERKNS0_11FullRuntimeERKNS_11TaskContextE.302.355.exit
  %icmp.ln143 = icmp eq i8 %t_ctx_stage.val, 4
  %"(anonymous namespace)::runtime.inputs.identity.S.load.8" = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.S", align 512
  %icmp.ln145 = icmp eq i16 %"(anonymous namespace)::runtime.inputs.identity.S.load.8", %t_S.val
  %and.ln145 = and i1 %icmp.ln143, %icmp.ln145
  br i1 %and.ln145, label %lor.lhs.false34, label %if.then49

lor.lhs.false34:                                  ; preds = %lor.lhs.false
  %b.id = load i8, i8* @"(anonymous namespace)::runtime.loaded_kv_ref.id", align 512
  %b.epoch = load i32, i32* @"(anonymous namespace)::runtime.loaded_kv_ref.epoch", align 512
  %icmp.ln20 = icmp eq i8 %b.id, %t_kv_id.val
  %icmp.ln20.36 = icmp eq i8 %t_kv_bank.val, 0
  %and.ln20 = and i1 %icmp.ln20, %icmp.ln20.36
  br i1 %and.ln20, label %land.rhs.i.i, label %_ZN4layaneENS_9BufferRefES0_.exit

land.rhs.i.i:                                     ; preds = %lor.lhs.false34
  %phitmp = icmp ne i32 %b.epoch, %t_kv_epoch.val
  br label %_ZN4layaneENS_9BufferRefES0_.exit

_ZN4layaneENS_9BufferRefES0_.exit:                ; preds = %land.rhs.i.i, %lor.lhs.false34
  %phi.ln21 = phi i1 [ %phitmp, %land.rhs.i.i ], [ true, %lor.lhs.false34 ]
  %"(anonymous namespace)::runtime.load" = load i8, i8* @"(anonymous namespace)::runtime.loaded_kv_head", align 512
  %icmp.ln147 = icmp ne i8 %"(anonymous namespace)::runtime.load", %t_head.val
  %or.ln147 = or i1 %icmp.ln147, %phi.ln21
  br i1 %or.ln147, label %if.then49, label %lor.lhs.false43

lor.lhs.false43:                                  ; preds = %_ZN4layaneENS_9BufferRefES0_.exit
  %icmp.ln148 = icmp ne i8 %t_score_id.val, 38
  %icmp.ln148.1 = icmp ne i8 %t_score_bank.val, 0
  %or.ln148 = or i1 %icmp.ln148, %icmp.ln148.1
  br i1 %or.ln148, label %if.then49, label %if.end54

if.then49:                                        ; preds = %lor.lhs.false43, %_ZN4layaneENS_9BufferRefES0_.exit, %lor.lhs.false
  %call.ret129 = call fastcc { i16, i32, i64, i32, i16, i32, i64, i32, i8 } @"laya::full::task::finish"(i32 %t_ctx_task_id.val, i8 80, i16 3, i32 122683397, i64 -1, i32 0, i16 0, i8 0)
  %newret21 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret129, 0
  %newret23 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret129, 1
  %newret25 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret129, 2
  %newret27 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret129, 3
  %newret29 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret129, 4
  %newret31 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret129, 5
  %newret33 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret129, 6
  %newret35 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret129, 7
  %newret37 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret129, 8
  br label %cleanup291

if.end54:                                         ; preds = %lor.lhs.false43
  %refs.id.addr = getelementptr [2 x i8], [2 x i8]* %refs.id, i64 0, i64 0
  %refs.bank.addr = getelementptr [2 x i8], [2 x i8]* %refs.bank, i64 0, i64 0
  %refs.epoch.addr = getelementptr [2 x i32], [2 x i32]* %refs.epoch, i64 0, i64 0
  %t_qkv_ref_id.addr = getelementptr [2 x i8], [2 x i8]* %t_qkv_ref_id, i64 0, i64 0
  %t_qkv_ref_id.load = load i8, i8* %t_qkv_ref_id.addr, align 512
  %t_qkv_ref_bank.addr = getelementptr [2 x i8], [2 x i8]* %t_qkv_ref_bank, i64 0, i64 0
  %t_qkv_ref_bank.load = load i8, i8* %t_qkv_ref_bank.addr, align 512
  %t_qkv_ref_epoch.addr = getelementptr [2 x i32], [2 x i32]* %t_qkv_ref_epoch, i64 0, i64 0
  %a.epoch = load i32, i32* %t_qkv_ref_epoch.addr, align 512
  store i8 %t_qkv_ref_id.load, i8* %refs.id.addr, align 512
  store i8 %t_qkv_ref_bank.load, i8* %refs.bank.addr, align 512
  store i32 %a.epoch, i32* %refs.epoch.addr, align 512
  %refs.id.addr.1 = getelementptr [2 x i8], [2 x i8]* %refs.id, i64 0, i64 1
  %refs.bank.addr.1 = getelementptr [2 x i8], [2 x i8]* %refs.bank, i64 0, i64 1
  %refs.epoch.addr.1 = getelementptr [2 x i32], [2 x i32]* %refs.epoch, i64 0, i64 1
  %t_qkv_ref_id.addr.1 = getelementptr [2 x i8], [2 x i8]* %t_qkv_ref_id, i64 0, i64 1
  %t_qkv_ref_id.load.1 = load i8, i8* %t_qkv_ref_id.addr.1, align 8
  %t_qkv_ref_bank.addr.1 = getelementptr [2 x i8], [2 x i8]* %t_qkv_ref_bank, i64 0, i64 1
  %t_qkv_ref_bank.load.1 = load i8, i8* %t_qkv_ref_bank.addr.1, align 1
  %t_qkv_ref_epoch.addr.1 = getelementptr [2 x i32], [2 x i32]* %t_qkv_ref_epoch, i64 0, i64 1
  %a.epoch.8 = load i32, i32* %t_qkv_ref_epoch.addr.1, align 4
  store i8 %t_qkv_ref_id.load.1, i8* %refs.id.addr.1, align 1
  store i8 %t_qkv_ref_bank.load.1, i8* %refs.bank.addr.1, align 1
  store i32 %a.epoch.8, i32* %refs.epoch.addr.1, align 4
  %icmp.ln152 = icmp ne i8 %t_qkv_ref_id.load, 5
  %icmp.ln152.3 = icmp ne i8 %t_qkv_ref_bank.load, 0
  %icmp.ln153 = icmp ne i8 %t_qkv_ref_id.load.1, 5
  %icmp.ln153.1 = icmp ne i8 %t_qkv_ref_bank.load.1, 1
  %or.ln152 = or i1 %icmp.ln153.1, %icmp.ln153
  %or.ln152.1 = or i1 %icmp.ln152, %icmp.ln152.3
  %or.ln152.2 = or i1 %or.ln152, %or.ln152.1
  br i1 %or.ln152.2, label %if.then87, label %lor.lhs.false74

lor.lhs.false74:                                  ; preds = %if.end54
  %b.id.5 = load i8, i8* getelementptr inbounds ([2 x i8], [2 x i8]* @"(anonymous namespace)::runtime.final_qkv_ref.id", i64 0, i64 0), align 512
  %b.bank = load i8, i8* getelementptr inbounds ([2 x i8], [2 x i8]* @"(anonymous namespace)::runtime.final_qkv_ref.bank", i64 0, i64 0), align 512
  %b.epoch.5 = load i32, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"(anonymous namespace)::runtime.final_qkv_ref.epoch", i64 0, i64 0), align 512
  %icmp.ln20.37 = icmp ne i8 %b.id.5, 5
  %icmp.ln20.38 = icmp ne i8 %b.bank, 0
  %or.ln20 = or i1 %icmp.ln20.38, %icmp.ln20.37
  %phitmp1 = icmp ne i32 %a.epoch, %b.epoch.5
  %or.ln154 = or i1 %or.ln20, %phitmp1
  br i1 %or.ln154, label %if.then87, label %lor.lhs.false80

lor.lhs.false80:                                  ; preds = %lor.lhs.false74
  %b.id.6 = load i8, i8* getelementptr inbounds ([2 x i8], [2 x i8]* @"(anonymous namespace)::runtime.final_qkv_ref.id", i64 0, i64 1), align 8
  %b.bank.3 = load i8, i8* getelementptr inbounds ([2 x i8], [2 x i8]* @"(anonymous namespace)::runtime.final_qkv_ref.bank", i64 0, i64 1), align 1
  %b.epoch.6 = load i32, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"(anonymous namespace)::runtime.final_qkv_ref.epoch", i64 0, i64 1), align 4
  %icmp.ln20.39 = icmp ne i8 %b.id.6, 5
  %icmp.ln20.40 = icmp ne i8 %b.bank.3, 1
  %or.ln20.10 = or i1 %icmp.ln20.40, %icmp.ln20.39
  %phitmp2 = icmp ne i32 %a.epoch.8, %b.epoch.6
  %or.ln152.3 = or i1 %or.ln20.10, %phitmp2
  br i1 %or.ln152.3, label %if.then87, label %arrayctor.loop.preheader

arrayctor.loop.preheader:                         ; preds = %lor.lhs.false80
  br label %arrayctor.loop

if.then87:                                        ; preds = %lor.lhs.false80, %lor.lhs.false74, %if.end54
  %call.ret141 = call fastcc { i16, i32, i64, i32, i16, i32, i64, i32, i8 } @"laya::full::task::finish"(i32 %t_ctx_task_id.val, i8 80, i16 5, i32 67436553, i64 -1, i32 0, i16 0, i8 0)
  %newret39 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret141, 0
  %newret41 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret141, 1
  %newret43 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret141, 2
  %newret45 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret141, 3
  %newret47 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret141, 4
  %newret49 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret141, 5
  %newret51 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret141, 6
  %newret53 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret141, 7
  %newret55 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret141, 8
  br label %cleanup291

arrayctor.loop:                                   ; preds = %arrayctor.loop, %arrayctor.loop.preheader
  %indvars.iv50 = phi i64 [ %add.ln158, %arrayctor.loop ], [ 0, %arrayctor.loop.preheader ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 2, i64 2, i64 2), !fpga.pragma.source !169
  %add.ln158 = add nuw nsw i64 %indvars.iv50, 1
  %this.ref.id = getelementptr [2 x i8], [2 x i8]* %qkv.ref.id, i64 0, i64 %indvars.iv50
  %this.ref.bank = getelementptr [2 x i8], [2 x i8]* %qkv.ref.bank, i64 0, i64 %indvars.iv50
  %this.ref.epoch = getelementptr [2 x i32], [2 x i32]* %qkv.ref.epoch, i64 0, i64 %indvars.iv50
  %this.region = getelementptr [2 x i8], [2 x i8]* %qkv.region, i64 0, i64 %indvars.iv50
  %this.stage = getelementptr [2 x i8], [2 x i8]* %qkv.stage, i64 0, i64 %indvars.iv50
  %this.layer = getelementptr [2 x i8], [2 x i8]* %qkv.layer, i64 0, i64 %indvars.iv50
  %this.batch = getelementptr [2 x i8], [2 x i8]* %qkv.batch, i64 0, i64 %indvars.iv50
  %this.row_space = getelementptr [2 x i8], [2 x i8]* %qkv.row_space, i64 0, i64 %indvars.iv50
  %this.row0 = getelementptr [2 x i16], [2 x i16]* %qkv.row0, i64 0, i64 %indvars.iv50
  %this.rows = getelementptr [2 x i16], [2 x i16]* %qkv.rows, i64 0, i64 %indvars.iv50
  %this.width = getelementptr [2 x i16], [2 x i16]* %qkv.width, i64 0, i64 %indvars.iv50
  %this.content = getelementptr [2 x i8], [2 x i8]* %qkv.content, i64 0, i64 %indvars.iv50
  store i8 0, i8* %this.ref.id, align 4, !alias.scope !3256, !noalias !3261
  store i8 0, i8* %this.ref.bank, align 1, !alias.scope !3275, !noalias !3276
  store i32 0, i32* %this.ref.epoch, align 4, !alias.scope !3277, !noalias !3278
  store i8 0, i8* %this.region, align 4, !alias.scope !3279, !noalias !3280
  store i8 0, i8* %this.stage, align 1, !alias.scope !3281, !noalias !3282
  store i8 -1, i8* %this.layer, align 2, !alias.scope !3283, !noalias !3284
  store i8 -1, i8* %this.batch, align 1, !alias.scope !3285, !noalias !3286
  store i8 0, i8* %this.row_space, align 4, !alias.scope !3287, !noalias !3288
  store i16 0, i16* %this.row0, align 2, !alias.scope !3289, !noalias !3290
  store i16 0, i16* %this.rows, align 4, !alias.scope !3291, !noalias !3292
  store i16 0, i16* %this.width, align 2, !alias.scope !3293, !noalias !3294
  store i8 0, i8* %this.content, align 4, !alias.scope !3295, !noalias !3296
  %icmp.ln158 = icmp eq i64 %indvars.iv50, 1
  br i1 %icmp.ln158, label %for.inc.i.preheader, label %arrayctor.loop, !llvm.loop !3297

for.inc.i.preheader:                              ; preds = %arrayctor.loop
  br label %for.inc.i

for.inc.i:                                        ; preds = %for.inc.i.split, %for.inc.i.preheader
  %shard = phi i64 [ %add.ln33, %for.inc.i.split ], [ 0, %for.inc.i.preheader ]
  %icmp.ln33 = icmp eq i64 %shard, 2
  br i1 %icmp.ln33, label %VITIS_LOOP_40_2.i.preheader, label %for.inc.i.split, !llvm.loop !3298

VITIS_LOOP_40_2.i.preheader:                      ; preds = %for.inc.i
  %"(anonymous namespace)::runtime.inputs.identity.B.load.4" = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.B", align 512, !alias.scope !3477, !noalias !3480
  %zext.ln40 = zext i16 %"(anonymous namespace)::runtime.inputs.identity.B.load.4" to i32
  %"(anonymous namespace)::runtime.inputs.identity.S.load.9" = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.S", align 512, !alias.scope !3477, !noalias !3480
  br label %VITIS_LOOP_40_2.i

for.inc.i.split:                                  ; preds = %for.inc.i
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 2, i64 2, i64 2), !fpga.pragma.source !169
  call void (...) @_ssdm_op_SpecLoopName([16 x i8]* @2)
  %refs.id.addr.2 = getelementptr [2 x i8], [2 x i8]* %refs.id, i64 0, i64 %shard
  %refs.bank.addr.2 = getelementptr [2 x i8], [2 x i8]* %refs.bank, i64 0, i64 %shard
  %refs.epoch.addr.2 = getelementptr [2 x i32], [2 x i32]* %refs.epoch, i64 0, i64 %shard
  %refs.id.load = load i8, i8* %refs.id.addr.2, align 1, !alias.scope !3496, !noalias !3499
  %refs.bank.load = load i8, i8* %refs.bank.addr.2, align 1, !alias.scope !3515, !noalias !3516
  %refs.epoch.load = load i32, i32* %refs.epoch.addr.2, align 4, !alias.scope !3517, !noalias !3518
  %qkv.ref.id.addr = getelementptr [2 x i8], [2 x i8]* %qkv.ref.id, i64 0, i64 %shard
  %qkv.ref.bank.addr = getelementptr [2 x i8], [2 x i8]* %qkv.ref.bank, i64 0, i64 %shard
  %qkv.ref.epoch.addr = getelementptr [2 x i32], [2 x i32]* %qkv.ref.epoch, i64 0, i64 %shard
  %qkv.region.addr = getelementptr [2 x i8], [2 x i8]* %qkv.region, i64 0, i64 %shard
  %qkv.stage.addr = getelementptr [2 x i8], [2 x i8]* %qkv.stage, i64 0, i64 %shard
  %qkv.layer.addr = getelementptr [2 x i8], [2 x i8]* %qkv.layer, i64 0, i64 %shard
  %qkv.batch.addr = getelementptr [2 x i8], [2 x i8]* %qkv.batch, i64 0, i64 %shard
  %qkv.row_space.addr = getelementptr [2 x i8], [2 x i8]* %qkv.row_space, i64 0, i64 %shard
  %qkv.row0.addr = getelementptr [2 x i16], [2 x i16]* %qkv.row0, i64 0, i64 %shard
  %qkv.rows.addr = getelementptr [2 x i16], [2 x i16]* %qkv.rows, i64 0, i64 %shard
  %qkv.width.addr = getelementptr [2 x i16], [2 x i16]* %qkv.width, i64 0, i64 %shard
  %qkv.content.addr = getelementptr [2 x i8], [2 x i8]* %qkv.content, i64 0, i64 %shard
  store i8 %refs.id.load, i8* %qkv.ref.id.addr, align 1, !alias.scope !3519, !noalias !3520
  store i8 %refs.bank.load, i8* %qkv.ref.bank.addr, align 1, !alias.scope !3521, !noalias !3522
  store i32 %refs.epoch.load, i32* %qkv.ref.epoch.addr, align 4, !alias.scope !3523, !noalias !3524
  store i8 0, i8* %qkv.region.addr, align 1, !alias.scope !3525, !noalias !3526
  store i8 4, i8* %qkv.stage.addr, align 1, !alias.scope !3527, !noalias !3528
  store i8 %t_ctx_layer.val, i8* %qkv.layer.addr, align 1, !alias.scope !3529, !noalias !3530
  store i8 -1, i8* %qkv.batch.addr, align 1, !alias.scope !3531, !noalias !3532
  store i8 0, i8* %qkv.row_space.addr, align 1, !alias.scope !3533, !noalias !3534
  store i16 0, i16* %qkv.row0.addr, align 2, !alias.scope !3535, !noalias !3536
  store i16 %t_S.val, i16* %qkv.rows.addr, align 2, !alias.scope !3537, !noalias !3538
  store i16 64, i16* %qkv.width.addr, align 2, !alias.scope !3539, !noalias !3540
  store i8 3, i8* %qkv.content.addr, align 1, !alias.scope !3541, !noalias !3542
  %add.ln33 = add nuw nsw i64 %shard, 1
  br label %for.inc.i, !llvm.loop !3298

for.cond.i:                                       ; preds = %for.cond1.i
  %kv.rows.lcssa = phi i16 [ %kv.rows, %for.cond1.i ]
  br label %VITIS_LOOP_40_2.i, !llvm.loop !3543

VITIS_LOOP_40_2.i:                                ; preds = %for.cond.i, %VITIS_LOOP_40_2.i.preheader
  %1 = phi i16 [ %kv.rows.lcssa, %for.cond.i ], [ %t_S.val, %VITIS_LOOP_40_2.i.preheader ]
  %shard.1 = phi i64 [ %add.ln39, %for.cond.i ], [ 0, %VITIS_LOOP_40_2.i.preheader ]
  %icmp.ln39 = icmp ult i64 %shard.1, 2
  br i1 %icmp.ln39, label %VITIS_LOOP_40_2.i.split, label %if.end101, !llvm.loop !3543

VITIS_LOOP_40_2.i.split:                          ; preds = %VITIS_LOOP_40_2.i
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 0, i64 2, i64 1), !fpga.pragma.source !169
  call void (...) @_ssdm_op_SpecLoopName([16 x i8]* @49)
  %qkv.ref.id.addr.2 = getelementptr [2 x i8], [2 x i8]* %qkv.ref.id, i64 0, i64 %shard.1
  %qkv.ref.bank.addr.2 = getelementptr [2 x i8], [2 x i8]* %qkv.ref.bank, i64 0, i64 %shard.1
  %qkv.ref.epoch.addr.2 = getelementptr [2 x i32], [2 x i32]* %qkv.ref.epoch, i64 0, i64 %shard.1
  %qkv.region.addr.2 = getelementptr [2 x i8], [2 x i8]* %qkv.region, i64 0, i64 %shard.1
  %qkv.stage.addr.2 = getelementptr [2 x i8], [2 x i8]* %qkv.stage, i64 0, i64 %shard.1
  %qkv.layer.addr.2 = getelementptr [2 x i8], [2 x i8]* %qkv.layer, i64 0, i64 %shard.1
  %qkv.batch.addr.2 = getelementptr [2 x i8], [2 x i8]* %qkv.batch, i64 0, i64 %shard.1
  %qkv.row_space.addr.2 = getelementptr [2 x i8], [2 x i8]* %qkv.row_space, i64 0, i64 %shard.1
  %qkv.row0.addr.2 = getelementptr [2 x i16], [2 x i16]* %qkv.row0, i64 0, i64 %shard.1
  %qkv.rows.addr.2 = getelementptr [2 x i16], [2 x i16]* %qkv.rows, i64 0, i64 %shard.1
  %qkv.width.addr.2 = getelementptr [2 x i16], [2 x i16]* %qkv.width, i64 0, i64 %shard.1
  %qkv.content.addr.2 = getelementptr [2 x i8], [2 x i8]* %qkv.content, i64 0, i64 %shard.1
  %add.ln39 = add nuw nsw i64 %shard.1, 1
  %qkv.ref.id.load = load i8, i8* %qkv.ref.id.addr.2, align 1
  %qkv.ref.bank.load = load i8, i8* %qkv.ref.bank.addr.2, align 1
  %qkv.ref.epoch.load = load i32, i32* %qkv.ref.epoch.addr.2, align 4
  %qkv.region.load = load i8, i8* %qkv.region.addr.2, align 1
  %qkv.layer.load = load i8, i8* %qkv.layer.addr.2, align 1
  %qkv.content.load = load i8, i8* %qkv.content.addr.2, align 1
  %qkv.stage.load = load i8, i8* %qkv.stage.addr.2, align 1
  %qkv.batch.load = load i8, i8* %qkv.batch.addr.2, align 1
  %qkv.row_space.load = load i8, i8* %qkv.row_space.addr.2, align 1
  %qkv.row0.load = load i16, i16* %qkv.row0.addr.2, align 2
  %qkv.rows.load = load i16, i16* %qkv.rows.addr.2, align 2
  %qkv.width.load = load i16, i16* %qkv.width.addr.2, align 2
  br label %for.cond1.i

for.cond1.i:                                      ; preds = %for.inc.i83, %VITIS_LOOP_40_2.i.split
  %kv.rows = phi i16 [ %1, %VITIS_LOOP_40_2.i.split ], [ %"(anonymous namespace)::runtime.inputs.identity.S.load.9", %for.inc.i83 ]
  %batch = phi i32 [ 0, %VITIS_LOOP_40_2.i.split ], [ %batch.1, %for.inc.i83 ]
  %icmp.ln40 = icmp ult i32 %batch, %zext.ln40
  br i1 %icmp.ln40, label %for.body4.i, label %for.cond.i

for.body4.i:                                      ; preds = %for.cond1.i
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 0, i64 65535, i64 32767), !fpga.pragma.source !169
  call void (...) @_ssdm_op_SpecLoopName([16 x i8]* @48)
  %trunc.ln41 = trunc i32 %batch to i8
  %call.ret24 = call fastcc { i16, i32 } @"laya::full::full_require_owner"(i8 %qkv.ref.id.load, i8 %qkv.ref.bank.load, i32 %qkv.ref.epoch.load, i8 %qkv.region.load, i8 %qkv.stage.load, i8 %qkv.layer.load, i8 %qkv.batch.load, i8 %qkv.row_space.load, i16 %qkv.row0.load, i16 %qkv.rows.load, i16 %qkv.width.load, i8 %qkv.content.load, i8 %trunc.ln41, i16 0, i16 %"(anonymous namespace)::runtime.inputs.identity.S.load.9")
  %c.code.164 = extractvalue { i16, i32 } %call.ret24, 0
  %c.detail.175 = extractvalue { i16, i32 } %call.ret24, 1
  %icmp.ln9.178 = icmp eq i16 %c.code.164, 0
  br i1 %icmp.ln9.178, label %for.inc.i83, label %if.then98

for.inc.i83:                                      ; preds = %for.body4.i
  %batch.1 = add nuw nsw i32 %batch, 1
  br label %for.cond1.i, !llvm.loop !3555

if.then98:                                        ; preds = %for.body4.i
  %newret26.lcssa = phi i32 [ %c.detail.175, %for.body4.i ]
  %newret24.lcssa = phi i16 [ %c.code.164, %for.body4.i ]
  %call.ret153 = call fastcc { i16, i32, i64, i32, i16, i32, i64, i32, i8 } @"laya::full::task::finish"(i32 %t_ctx_task_id.val, i8 80, i16 %newret24.lcssa, i32 %newret26.lcssa, i64 -1, i32 0, i16 0, i8 0)
  %newret57 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret153, 0
  %newret59 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret153, 1
  %newret61 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret153, 2
  %newret63 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret153, 3
  %newret65 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret153, 4
  %newret67 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret153, 5
  %newret69 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret153, 6
  %newret71 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret153, 7
  %newret73 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret153, 8
  br label %cleanup291

if.end101:                                        ; preds = %VITIS_LOOP_40_2.i
  %.lcssa = phi i16 [ %1, %VITIS_LOOP_40_2.i ]
  %call.ret14 = call fastcc { i16, i32 } @"laya::full::full_require_owner.6"(i8 %t_kv_id.val, i8 %t_kv_bank.val, i32 %t_kv_epoch.val, i8 0, i8 4, i8 %t_ctx_layer.val, i8 -1, i8 0, i16 0, i16 %.lcssa, i16 64, i8 1, i8 %t_ctx_batch.val, i16 0, i16 %t_S.val)
  %c.code.162 = extractvalue { i16, i32 } %call.ret14, 0
  %c.detail.173 = extractvalue { i16, i32 } %call.ret14, 1
  %icmp.ln9.176 = icmp eq i16 %c.code.162, 0
  br i1 %icmp.ln9.176, label %if.end115, label %if.then112

if.then112:                                       ; preds = %if.end101
  %call.ret160 = call fastcc { i16, i32, i64, i32, i16, i32, i64, i32, i8 } @"laya::full::task::finish"(i32 %t_ctx_task_id.val, i8 80, i16 %c.code.162, i32 %c.detail.173, i64 -1, i32 0, i16 0, i8 0)
  %newret75 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret160, 0
  %newret77 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret160, 1
  %newret79 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret160, 2
  %newret81 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret160, 3
  %newret83 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret160, 4
  %newret85 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret160, 5
  %newret87 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret160, 6
  %newret89 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret160, 7
  %newret91 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret160, 8
  br label %cleanup291

if.end115:                                        ; preds = %if.end101
  %call.ret48 = call fastcc { i16, i32 } @"laya::full::full_claim_owner"(i8 38, i8 0, i32 %t_score_epoch.val, i8 0, i8 4, i8 %t_ctx_layer.val, i8 %t_ctx_batch.val, i8 0, i16 %t_ctx_row0.val, i16 16, i16 %t_S.val, i8 6)
  %c.code.163 = extractvalue { i16, i32 } %call.ret48, 0
  %c.detail.174 = extractvalue { i16, i32 } %call.ret48, 1
  %icmp.ln9.177 = icmp eq i16 %c.code.163, 0
  br i1 %icmp.ln9.177, label %if.end126, label %if.then123

if.then123:                                       ; preds = %if.end115
  %call.ret161 = call fastcc { i16, i32, i64, i32, i16, i32, i64, i32, i8 } @"laya::full::task::finish"(i32 %t_ctx_task_id.val, i8 80, i16 %c.code.163, i32 %c.detail.174, i64 -1, i32 0, i16 0, i8 0)
  %newret93 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret161, 0
  %newret95 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret161, 1
  %newret97 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret161, 2
  %newret99 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret161, 3
  %newret101 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret161, 4
  %newret103 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret161, 5
  %newret105 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret161, 6
  %newret107 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret161, 7
  %newret109 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret161, 8
  br label %cleanup291

if.end126:                                        ; preds = %if.end115
  %zext.ln171 = zext i8 %t_head.val to i32
  %and.ln171 = and i32 %zext.ln171, 1
  %zext.ln171.1 = zext i32 %and.ln171 to i64
  %qkv.ref.id.addr.3 = getelementptr [2 x i8], [2 x i8]* %qkv.ref.id, i64 0, i64 %zext.ln171.1
  %qkv.ref.bank.addr.3 = getelementptr [2 x i8], [2 x i8]* %qkv.ref.bank, i64 0, i64 %zext.ln171.1
  %qkv.ref.epoch.addr.3 = getelementptr [2 x i32], [2 x i32]* %qkv.ref.epoch, i64 0, i64 %zext.ln171.1
  %qkv.region.addr.3 = getelementptr [2 x i8], [2 x i8]* %qkv.region, i64 0, i64 %zext.ln171.1
  %qkv.stage.addr.3 = getelementptr [2 x i8], [2 x i8]* %qkv.stage, i64 0, i64 %zext.ln171.1
  %qkv.layer.addr.3 = getelementptr [2 x i8], [2 x i8]* %qkv.layer, i64 0, i64 %zext.ln171.1
  %qkv.batch.addr.3 = getelementptr [2 x i8], [2 x i8]* %qkv.batch, i64 0, i64 %zext.ln171.1
  %qkv.row_space.addr.3 = getelementptr [2 x i8], [2 x i8]* %qkv.row_space, i64 0, i64 %zext.ln171.1
  %qkv.row0.addr.3 = getelementptr [2 x i16], [2 x i16]* %qkv.row0, i64 0, i64 %zext.ln171.1
  %qkv.rows.addr.3 = getelementptr [2 x i16], [2 x i16]* %qkv.rows, i64 0, i64 %zext.ln171.1
  %qkv.width.addr.3 = getelementptr [2 x i16], [2 x i16]* %qkv.width, i64 0, i64 %zext.ln171.1
  %qkv.content.addr.3 = getelementptr [2 x i8], [2 x i8]* %qkv.content, i64 0, i64 %zext.ln171.1
  %qkv.ref.id.load.1 = load i8, i8* %qkv.ref.id.addr.3, align 1
  %qkv.ref.bank.load.1 = load i8, i8* %qkv.ref.bank.addr.3, align 1
  %qkv.ref.epoch.load.1 = load i32, i32* %qkv.ref.epoch.addr.3, align 4
  %qkv.region.load.1 = load i8, i8* %qkv.region.addr.3, align 1
  %qkv.layer.load.1 = load i8, i8* %qkv.layer.addr.3, align 1
  %qkv.content.load.1 = load i8, i8* %qkv.content.addr.3, align 1
  %qkv.stage.load.1 = load i8, i8* %qkv.stage.addr.3, align 1
  %qkv.batch.load.1 = load i8, i8* %qkv.batch.addr.3, align 1
  %qkv.row_space.load.1 = load i8, i8* %qkv.row_space.addr.3, align 1
  %qkv.row0.load.1 = load i16, i16* %qkv.row0.addr.3, align 2
  %qkv.rows.load.1 = load i16, i16* %qkv.rows.addr.3, align 2
  %qkv.width.load.1 = load i16, i16* %qkv.width.addr.3, align 2
  %call.ret58 = call fastcc { i16, i32 } @"laya::full::full_acquire_owner.5"(i8 %qkv.ref.id.load.1, i8 %qkv.ref.bank.load.1, i32 %qkv.ref.epoch.load.1, i8 %qkv.region.load.1, i8 %qkv.stage.load.1, i8 %qkv.layer.load.1, i8 %qkv.batch.load.1, i8 %qkv.row_space.load.1, i16 %qkv.row0.load.1, i16 %qkv.rows.load.1, i16 %qkv.width.load.1, i8 %qkv.content.load.1, i8 %t_ctx_batch.val, i16 %t_ctx_row0.val, i16 16)
  %c.code.165 = extractvalue { i16, i32 } %call.ret58, 0
  %c.detail.176 = extractvalue { i16, i32 } %call.ret58, 1
  %icmp.ln9.179 = icmp eq i16 %c.code.165, 0
  br i1 %icmp.ln9.179, label %if.then138, label %if.end148

if.then138:                                       ; preds = %if.end126
  %"(anonymous namespace)::runtime.inputs.identity.S.load.10" = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.S", align 512
  %call.ret62 = call fastcc { i16, i32 } @"laya::full::full_acquire_owner"(i8 %t_kv_id.val, i8 %t_kv_bank.val, i32 %t_kv_epoch.val, i8 0, i8 4, i8 %t_ctx_layer.val, i8 -1, i8 0, i16 0, i16 %.lcssa, i16 64, i8 1, i8 %t_ctx_batch.val, i16 0, i16 %"(anonymous namespace)::runtime.inputs.identity.S.load.10")
  %c.code.166 = extractvalue { i16, i32 } %call.ret62, 0
  %c.detail.177 = extractvalue { i16, i32 } %call.ret62, 1
  %kv_read = icmp eq i16 %c.code.166, 0
  br label %if.end148

if.end148:                                        ; preds = %if.then138, %if.end126
  %c.code.237.0 = phi i16 [ %c.code.166, %if.then138 ], [ %c.code.165, %if.end126 ]
  %.138 = phi i32 [ %c.detail.177, %if.then138 ], [ %c.detail.176, %if.end126 ]
  %q_read = phi i1 [ true, %if.then138 ], [ false, %if.end126 ]
  %kv_read.1 = phi i1 [ %kv_read, %if.then138 ], [ false, %if.end126 ]
  %icmp.ln9.181 = icmp eq i16 %c.code.237.0, 0
  %zext.ln190 = zext i8 %t_ctx_batch.val to i64
  br i1 %icmp.ln9.181, label %VITIS_LOOP_181_1, label %VITIS_LOOP_183_2

VITIS_LOOP_181_1:                                 ; preds = %if.end148
  %zext.ln181 = zext i16 %t_S.val to i64
  br label %for.inc

for.inc:                                          ; preds = %for.inc.split, %VITIS_LOOP_181_1
  %key = phi i64 [ 0, %VITIS_LOOP_181_1 ], [ %add.ln181, %for.inc.split ]
  %icmp.ln181 = icmp eq i64 %key, %zext.ln181
  br i1 %icmp.ln181, label %VITIS_LOOP_183_2.loopexit, label %for.inc.split, !llvm.loop !3561

for.inc.split:                                    ; preds = %for.inc
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 0, i64 65535, i64 32767), !fpga.pragma.source !169
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @110)
  %"(anonymous namespace)::runtime.inputs.attention_mask.addr" = getelementptr [2 x [1024 x i8]], [2 x [1024 x i8]]* @"(anonymous namespace)::runtime.inputs.attention_mask", i64 0, i64 %zext.ln190, i64 %key
  %"(anonymous namespace)::runtime.inputs.attention_mask.load" = load i8, i8* %"(anonymous namespace)::runtime.inputs.attention_mask.addr", align 1
  %qk_mask.addr = getelementptr inbounds [1024 x i8], [1024 x i8]* %qk_mask, i64 0, i64 %key
  store i8 %"(anonymous namespace)::runtime.inputs.attention_mask.load", i8* %qk_mask.addr, align 1
  %add.ln181 = add nuw nsw i64 %key, 1
  br label %for.inc, !llvm.loop !3561

VITIS_LOOP_183_2.loopexit:                        ; preds = %for.inc
  br label %VITIS_LOOP_183_2

VITIS_LOOP_183_2:                                 ; preds = %VITIS_LOOP_183_2.loopexit, %if.end148
  br label %for.cond164

for.cond164:                                      ; preds = %for.inc223, %VITIS_LOOP_183_2
  %c.code.237.1 = phi i16 [ %c.code.237.0, %VITIS_LOOP_183_2 ], [ %c.code.237.2, %for.inc223 ]
  %r = phi i64 [ 0, %VITIS_LOOP_183_2 ], [ %add.ln183, %for.inc223 ]
  %.241 = phi i64 [ -1, %VITIS_LOOP_183_2 ], [ %.242, %for.inc223 ]
  %.136 = phi i32 [ %.138, %VITIS_LOOP_183_2 ], [ %.137, %for.inc223 ]
  %r.0 = phi i32 [ 0, %VITIS_LOOP_183_2 ], [ %r.11, %for.inc223 ]
  call void (...) @_ssdm_SpecDependence([64 x float]* %q, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false) #1
  %icmp.ln183 = icmp ult i64 %r, 16
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 1, i64 16, i64 8)
  br i1 %icmp.ln183, label %land.rhs169, label %for.end226

land.rhs169:                                      ; preds = %for.cond164
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @55)
  %icmp.ln9.182 = icmp eq i16 %c.code.237.1, 0
  br i1 %icmp.ln9.182, label %VITIS_LOOP_185_3, label %for.end226

VITIS_LOOP_185_3:                                 ; preds = %land.rhs169
  %trunc.ln187 = trunc i32 %r.0 to i16
  %add.ln187 = add i16 %trunc.ln187, %t_ctx_row0.val
  br label %for.body177

for.body177:                                      ; preds = %for.body177, %VITIS_LOOP_185_3
  %d = phi i64 [ 0, %VITIS_LOOP_185_3 ], [ %add.ln185, %for.body177 ]
  %d.022 = phi i32 [ 0, %VITIS_LOOP_185_3 ], [ %d.3, %for.body177 ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 0, i64 64, i64 32), !fpga.pragma.source !169
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @47)
  %trunc.ln187.1 = trunc i32 %d.022 to i8
  %q.addr = getelementptr inbounds [64 x float], [64 x float]* %q, i64 0, i64 %d
  %q.load = load float, float* %q.addr, align 4
  %call.ret67 = call fastcc { i16, i32, float } @"laya::full::(anonymous namespace)::read_qkv"(i8 addrspace(1)* %embedding, i64 %memory_embedding, i8 addrspace(1)* %io, i64 %memory_io, i8 addrspace(1)* %w_q0, i64 %memory_w_q0, i8 addrspace(1)* %w_q1, i64 %memory_w_q1, i8 addrspace(1)* %w_scale, i64 %memory_w_scale, i8 addrspace(1)* %aux, i64 %memory_aux, i8 addrspace(1)* %state0, i64 %memory_state0, i8 addrspace(1)* %state1, i64 %memory_state1, i8 addrspace(1)* %qkv0, i64 %memory_qkv0, i8 addrspace(1)* %qkv1, i64 %memory_qkv1, i8 addrspace(1)* %ff0, i64 %memory_ff0, i8 addrspace(1)* %ff1, i64 %memory_ff1, i8 addrspace(1)* %att_out, i64 %memory_att_out, i8 %t_ctx_batch.val, i8 %t_head.val, i16 %add.ln187, i8 %trunc.ln187.1, float %q.load)
  %c.code.167 = extractvalue { i16, i32, float } %call.ret67, 0
  %c.detail.178 = extractvalue { i16, i32, float } %call.ret67, 1
  %newret52 = extractvalue { i16, i32, float } %call.ret67, 2
  store float %newret52, float* %q.addr, align 4
  %icmp.ln9.183 = icmp eq i16 %c.code.167, 0
  %add.ln185 = add nuw nsw i64 %d, 1
  %d.3 = add nuw nsw i32 %d.022, 1
  %icmp.ln185 = icmp ult i64 %add.ln185, 64
  %and.ln188 = and i1 %icmp.ln9.183, %icmp.ln185
  br i1 %and.ln188, label %for.body177, label %for.end194, !llvm.loop !3567

for.end194:                                       ; preds = %for.body177
  %icmp.ln9.184.lcssa = phi i1 [ %icmp.ln9.183, %for.body177 ]
  %newret50.lcssa = phi i32 [ %c.detail.178, %for.body177 ]
  %newret48.lcssa = phi i16 [ %c.code.167, %for.body177 ]
  br i1 %icmp.ln9.184.lcssa, label %if.then196, label %for.inc223

if.then196:                                       ; preds = %for.end194
  %tmp = call fastcc { i16, i32, i64 } @"laya::full::qk_row"([64 x float]* noalias nocapture align 512 %q, [2 x [2 x [1024 x [64 x float]]]]* noalias nocapture align 512 @"laya::full::g_full_cache_kv", i64 %zext.ln190, [1024 x i8]* noalias nocapture align 512 %qk_mask, i16 zeroext %t_S.val, i16 zeroext %add.ln187, [2 x [16 x [1024 x float]]]* noalias nocapture align 512 @"laya::full::g_full_cache_score", i64 %r) #1
  %c.code.169 = extractvalue { i16, i32, i64 } %tmp, 0
  %c.detail.180 = extractvalue { i16, i32, i64 } %tmp, 1
  %c.bad_element = extractvalue { i16, i32, i64 } %tmp, 2
  br label %for.inc223

for.inc223:                                       ; preds = %if.then196, %for.end194
  %c.code.237.2 = phi i16 [ %c.code.169, %if.then196 ], [ %newret48.lcssa, %for.end194 ]
  %.242 = phi i64 [ %c.bad_element, %if.then196 ], [ -1, %for.end194 ]
  %.137 = phi i32 [ %c.detail.180, %if.then196 ], [ %newret50.lcssa, %for.end194 ]
  %add.ln183 = add nuw nsw i64 %r, 1
  %r.11 = add nuw nsw i32 %r.0, 1
  br label %for.cond164, !llvm.loop !3576

for.end226:                                       ; preds = %land.rhs169, %for.cond164
  %.136.lcssa = phi i32 [ %.136, %land.rhs169 ], [ %.136, %for.cond164 ]
  %.241.lcssa = phi i64 [ %.241, %land.rhs169 ], [ %.241, %for.cond164 ]
  %c.code.237.1.lcssa = phi i16 [ %c.code.237.1, %land.rhs169 ], [ %c.code.237.1, %for.cond164 ]
  br i1 %kv_read.1, label %if.then227, label %if.end228

if.then227:                                       ; preds = %for.end226
  %2 = call fastcc { i16, i32 } @"laya::full::full_release_read_owner"(i8 %t_kv_id.val, i8 %t_kv_bank.val, i32 %t_kv_epoch.val, i8 0, i8 4, i8 %t_ctx_layer.val, i8 -1, i8 0, i16 0, i16 %.lcssa, i16 64, i8 1)
  br label %if.end228

if.end228:                                        ; preds = %if.then227, %for.end226
  br i1 %q_read, label %if.then229, label %if.end236

if.then229:                                       ; preds = %if.end228
  call fastcc void @"laya::full::full_release_read_owner.4"(i8 %qkv.ref.id.load.1, i8 %qkv.ref.bank.load.1, i32 %qkv.ref.epoch.load.1, i8 %qkv.region.load.1, i8 %qkv.stage.load.1, i8 %qkv.layer.load.1, i8 %qkv.batch.load.1, i8 %qkv.row_space.load.1, i16 %qkv.row0.load.1, i16 %qkv.rows.load.1, i16 %qkv.width.load.1, i8 %qkv.content.load.1)
  br label %if.end236

if.end236:                                        ; preds = %if.then229, %if.end228
  %icmp.ln9.184 = icmp eq i16 %c.code.237.1.lcssa, 0
  br i1 %icmp.ln9.184, label %if.then238, label %if.end247

if.then238:                                       ; preds = %if.end236
  %call.ret44 = call fastcc { i16, i32 } @"laya::full::full_cover_owner"(i8 38, i8 0, i32 %t_score_epoch.val, i8 0, i8 4, i8 %t_ctx_layer.val, i8 %t_ctx_batch.val, i8 0, i16 %t_ctx_row0.val, i16 16, i16 %t_S.val, i8 6, i8 %t_ctx_batch.val, i16 %t_ctx_row0.val, i16 16)
  %c.code.168 = extractvalue { i16, i32 } %call.ret44, 0
  %c.detail.179 = extractvalue { i16, i32 } %call.ret44, 1
  br label %if.end247

if.end247:                                        ; preds = %if.then238, %if.end236
  %3 = phi i16 [ %c.code.168, %if.then238 ], [ %c.code.237.1.lcssa, %if.end236 ]
  %.240 = phi i64 [ -1, %if.then238 ], [ %.241.lcssa, %if.end236 ]
  %.135 = phi i32 [ %c.detail.179, %if.then238 ], [ %.136.lcssa, %if.end236 ]
  %icmp.ln9.185 = icmp eq i16 %3, 0
  br i1 %icmp.ln9.185, label %if.then249, label %if.end251

if.then249:                                       ; preds = %if.end247
  %call.ret36 = call fastcc { i16, i32 } @"laya::full::full_publish_owner"(i8 38, i8 0, i32 %t_score_epoch.val, i8 0, i8 4, i8 %t_ctx_layer.val, i8 %t_ctx_batch.val, i8 0, i16 %t_ctx_row0.val, i16 16, i16 %t_S.val, i8 6)
  %c.code.170 = extractvalue { i16, i32 } %call.ret36, 0
  %c.detail.181 = extractvalue { i16, i32 } %call.ret36, 1
  br label %if.end251

if.end251:                                        ; preds = %if.then249, %if.end247
  %4 = phi i16 [ %c.code.170, %if.then249 ], [ %3, %if.end247 ]
  %.2 = phi i64 [ -1, %if.then249 ], [ %.240, %if.end247 ]
  %.1 = phi i32 [ %c.detail.181, %if.then249 ], [ %.135, %if.end247 ]
  %icmp.ln9.186 = icmp eq i16 %4, 0
  br i1 %icmp.ln9.186, label %if.else, label %if.then253

if.then253:                                       ; preds = %if.end251
  %5 = call fastcc i16 @"laya::full::full_invalidate_owner"(i8 38, i8 0, i32 %t_score_epoch.val, i8 0)
  br label %if.end275

if.else:                                          ; preds = %if.end251
  store i8 38, i8* @"(anonymous namespace)::runtime.score_ref.id", align 512
  store i32 %t_score_epoch.val, i32* @"(anonymous namespace)::runtime.score_ref.epoch", align 512
  store i8 %t_kv_id.val, i8* @"(anonymous namespace)::runtime.score_kv_ref.id", align 512
  store i8 %t_kv_bank.val, i8* @"(anonymous namespace)::runtime.score_kv_ref.bank", align 512
  store i32 %t_kv_epoch.val, i32* @"(anonymous namespace)::runtime.score_kv_ref.epoch", align 512
  store i8 5, i8* @"(anonymous namespace)runtime.score_qkv_ref.id_0", align 512
  store i8 5, i8* @"(anonymous namespace)runtime.score_qkv_ref.id_1", align 512
  store i8 1, i8* @"(anonymous namespace)runtime.score_qkv_ref.bank_1", align 512
  store i32 %a.epoch, i32* @"(anonymous namespace)runtime.score_qkv_ref.epoch_0", align 512
  store i32 %a.epoch.8, i32* @"(anonymous namespace)runtime.score_qkv_ref.epoch_1", align 512
  store i8 %t_head.val, i8* @"(anonymous namespace)::runtime.score_head", align 512
  store i8 4, i8* @"(anonymous namespace)::runtime.score_stage", align 512
  store i8 %t_ctx_layer.val, i8* @"(anonymous namespace)::runtime.score_layer", align 512
  store i8 %t_ctx_batch.val, i8* @"(anonymous namespace)::runtime.score_batch", align 512
  store i16 %t_ctx_row0.val, i16* @"(anonymous namespace)::runtime.score_row0", align 512
  store i8 16, i8* @"(anonymous namespace)::runtime.score_rows", align 512
  store i1 true, i1* @"(anonymous namespace)::runtime.score_valid", align 512
  br label %if.end275

if.end275:                                        ; preds = %if.else, %if.then253
  %zext.ln215 = zext i16 %t_S.val to i32
  %shl.ln215 = shl nuw nsw i32 %zext.ln215, 4
  %call.ret = call fastcc { i16, i32, i64, i32, i16, i32, i64, i32, i8 } @"laya::full::task::finish"(i32 %t_ctx_task_id.val, i8 80, i16 %4, i32 %.1, i64 %.2, i32 %shl.ln215, i16 0, i8 0)
  %newret111 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret, 0
  %newret113 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret, 1
  %newret115 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret, 2
  %newret117 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret, 3
  %newret119 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret, 4
  %newret121 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret, 5
  %newret123 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret, 6
  %newret125 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret, 7
  %newret127 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret, 8
  br label %cleanup291

cleanup291:                                       ; preds = %if.end275, %if.then123, %if.then112, %if.then98, %if.then87, %if.then49, %if.then
  %agg.result.0.5 = phi i16 [ %newret, %if.then ], [ %newret21, %if.then49 ], [ %newret39, %if.then87 ], [ %newret57, %if.then98 ], [ %newret75, %if.then112 ], [ %newret111, %if.end275 ], [ %newret93, %if.then123 ]
  %agg.result.1.5 = phi i32 [ %newret5, %if.then ], [ %newret23, %if.then49 ], [ %newret41, %if.then87 ], [ %newret59, %if.then98 ], [ %newret77, %if.then112 ], [ %newret113, %if.end275 ], [ %newret95, %if.then123 ]
  %agg.result.2.5 = phi i64 [ %newret7, %if.then ], [ %newret25, %if.then49 ], [ %newret43, %if.then87 ], [ %newret61, %if.then98 ], [ %newret79, %if.then112 ], [ %newret115, %if.end275 ], [ %newret97, %if.then123 ]
  %done_task_id.5 = phi i32 [ %newret9, %if.then ], [ %newret27, %if.then49 ], [ %newret45, %if.then87 ], [ %newret63, %if.then98 ], [ %newret81, %if.then112 ], [ %newret117, %if.end275 ], [ %newret99, %if.then123 ]
  %done_status.5 = phi i16 [ %newret11, %if.then ], [ %newret29, %if.then49 ], [ %newret47, %if.then87 ], [ %newret65, %if.then98 ], [ %newret83, %if.then112 ], [ %newret119, %if.end275 ], [ %newret101, %if.then123 ]
  %done_error_detail.5 = phi i32 [ %newret13, %if.then ], [ %newret31, %if.then49 ], [ %newret49, %if.then87 ], [ %newret67, %if.then98 ], [ %newret85, %if.then112 ], [ %newret121, %if.end275 ], [ %newret103, %if.then123 ]
  %done_bad_element.5 = phi i64 [ %newret15, %if.then ], [ %newret33, %if.then49 ], [ %newret51, %if.then87 ], [ %newret69, %if.then98 ], [ %newret87, %if.then112 ], [ %newret123, %if.end275 ], [ %newret105, %if.then123 ]
  %done_output_elements.5 = phi i32 [ %newret17, %if.then ], [ %newret35, %if.then49 ], [ %newret53, %if.then87 ], [ %newret71, %if.then98 ], [ %newret89, %if.then112 ], [ %newret125, %if.end275 ], [ %newret107, %if.then123 ]
  %done_output_unit.5 = phi i8 [ %newret19, %if.then ], [ %newret37, %if.then49 ], [ %newret55, %if.then87 ], [ %newret73, %if.then98 ], [ %newret91, %if.then112 ], [ %newret127, %if.end275 ], [ %newret109, %if.then123 ]
  %newret2 = insertvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } undef, i16 %agg.result.0.5, 0
  %newret4 = insertvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %newret2, i32 %agg.result.1.5, 1
  %newret6 = insertvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %newret4, i64 %agg.result.2.5, 2
  %newret8 = insertvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %newret6, i32 %done_task_id.5, 3
  %newret10 = insertvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %newret8, i16 %done_status.5, 4
  %newret12 = insertvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %newret10, i32 %done_error_detail.5, 5
  %newret14 = insertvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %newret12, i64 %done_bad_element.5, 6
  %newret16 = insertvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %newret14, i32 %done_output_elements.5, 7
  %newret18 = insertvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %newret16, i8 %done_output_unit.5, 8
  ret { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %newret18
}
