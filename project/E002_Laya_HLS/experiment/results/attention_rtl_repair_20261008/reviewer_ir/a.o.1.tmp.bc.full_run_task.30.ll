define internal fastcc { i16, i32, i64, i32, i16, i32, i64, i32, i8, i1 } @"laya::full::full_run_task.30"(i8 addrspace(1)* noalias nocapture %embedding, i64 %memory_embedding, i8 addrspace(1)* noalias nocapture %io, i64 %memory_io, i8 addrspace(1)* noalias nocapture %w_q0, i64 %memory_w_q0, i8 addrspace(1)* noalias nocapture %w_q1, i64 %memory_w_q1, i8 addrspace(1)* noalias nocapture %w_scale, i64 %memory_w_scale, i8 addrspace(1)* noalias nocapture %aux, i64 %memory_aux, i8 addrspace(1)* noalias nocapture %state0, i64 %memory_state0, i8 addrspace(1)* noalias nocapture %state1, i64 %memory_state1, i8 addrspace(1)* noalias nocapture %qkv0, i64 %memory_qkv0, i8 addrspace(1)* noalias nocapture %qkv1, i64 %memory_qkv1, i8 addrspace(1)* noalias nocapture %ff0, i64 %memory_ff0, i8 addrspace(1)* noalias nocapture %ff1, i64 %memory_ff1, i8 addrspace(1)* noalias nocapture %att_out, i64 %memory_att_out, i32 %t.ctx.task_id.read, i8 %t.ctx.op.read, i8 %t_ctx_stage.val, i8 %t_ctx_layer.val, i8 %t_kind.val, i8 %t_dst_id.val, i8 %t_dst_bank.val, i32 %t_dst_epoch.val, i8 %t_weight_family.val, i8 %t_weight_layer.val, i8 %t_head.val, i8 %t_planes.val, i32 %t.byte_count.read) #1 {
entry:
  %cond = icmp slt i8 %t.ctx.op.read, 0
  %cond148 = icmp ult i8 %t.ctx.op.read, -124
  %cond149 = and i1 %cond148, %cond
  call void (...) @_ssdm_Assume(i1 %cond149) #1
  %cond150 = icmp ne i8 %t_ctx_stage.val, 0
  %cond151 = icmp ult i8 %t_ctx_stage.val, 7
  %cond152 = and i1 %cond151, %cond150
  call void (...) @_ssdm_Assume(i1 %cond152) #1
  %cond153 = icmp sgt i8 %t_ctx_layer.val, -2
  %cond154 = icmp slt i8 %t_ctx_layer.val, 28
  %cond155 = and i1 %cond154, %cond153
  call void (...) @_ssdm_Assume(i1 %cond155) #1
  %cond156 = icmp ult i8 %t_kind.val, 4
  call void (...) @_ssdm_Assume(i1 %cond156) #1
  %cond157 = icmp ult i8 %t_weight_family.val, 13
  call void (...) @_ssdm_Assume(i1 %cond157) #1
  %cond158 = icmp sgt i8 %t_weight_layer.val, -2
  %cond159 = icmp slt i8 %t_weight_layer.val, 28
  %cond160 = and i1 %cond159, %cond158
  call void (...) @_ssdm_Assume(i1 %cond160) #1
  %cond161 = icmp sgt i8 %t_head.val, -2
  %cond162 = icmp slt i8 %t_head.val, 16
  %cond163 = and i1 %cond162, %cond161
  call void (...) @_ssdm_Assume(i1 %cond163) #1
  %cond164 = icmp ult i8 %t_planes.val, 4
  call void (...) @_ssdm_Assume(i1 %cond164) #1
  %cond165 = icmp ult i32 %t.byte_count.read, -15
  call void (...) @_ssdm_Assume(i1 %cond165) #1
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
  %raw = alloca [4 x i8], i64 1, align 512
  %raw.8 = alloca [4 x i8], i64 1, align 512
  %d.name = alloca [48 x i8], i64 1, align 512
  %d.q_base = alloca [2 x i32], i64 1, align 512
  %d.q_span = alloca [2 x i32], i64 1, align 512
  %d.source_sha256 = alloca [32 x i8], i64 1, align 512
  %d.bias_sha256 = alloca [32 x i8], i64 1, align 512
  %d.name.1 = alloca [48 x i8], i64 1, align 512
  %d.ne = alloca [4 x i32], i64 1, align 512
  %d.source_sha256.1 = alloca [32 x i8], i64 1, align 512
  %d.name.2 = alloca [2 x [48 x i8]], i64 1, align 512
  %d.ggml_type_id = alloca [2 x i8], i64 1, align 512
  %d.bo = alloca [2 x i8], i64 1, align 512
  %d.omitted = alloca [2 x i8], i64 1, align 512
  %d.reserved = alloca [2 x i8], i64 1, align 512
  %d.ne.1 = alloca [2 x [4 x i32]], i64 1, align 512
  %d.source_offset = alloca [2 x i32], i64 1, align 512
  %d.source_bytes = alloca [2 x i32], i64 1, align 512
  %d.base = alloca [2 x i32], i64 1, align 512
  %d.span = alloca [2 x i32], i64 1, align 512
  %d.source_sha256.2 = alloca [2 x [32 x i8]], i64 1, align 512
  %old.identity.model_tag = alloca [16 x i8], i64 1, align 512
  %old.identity.numeric_tag = alloca [16 x i8], i64 1, align 512
  %old.identity.layout_tag = alloca [16 x i8], i64 1, align 512
  %old.identity.build_tag = alloca [16 x i8], i64 1, align 512
  %old.covered_rows = alloca [64 x i32], i64 1, align 512
  %old.old_consumed_rows = alloca [64 x i32], i64 1, align 512
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
  %old.identity.model_tag.2 = alloca [16 x i8], i64 1, align 512
  %old.identity.numeric_tag.2 = alloca [16 x i8], i64 1, align 512
  %old.identity.layout_tag.2 = alloca [16 x i8], i64 1, align 512
  %old.identity.build_tag.2 = alloca [16 x i8], i64 1, align 512
  %old.covered_rows.2 = alloca [64 x i32], i64 1, align 512
  %old.old_consumed_rows.2 = alloca [64 x i32], i64 1, align 512
  %"(anonymous namespace)::runtime.request_valid.load" = load i1, i1* @"(anonymous namespace)::runtime.request_valid", align 512, !alias.scope !3711, !noalias !3714
  br i1 %"(anonymous namespace)::runtime.request_valid.load", label %land.lhs.true.i, label %cond.false

land.lhs.true.i:                                  ; preds = %entry
  %"(anonymous namespace)::runtime.model_header_valid.load" = load i1, i1* @"(anonymous namespace)::runtime.model_header_valid", align 512, !alias.scope !3711, !noalias !3714
  br i1 %"(anonymous namespace)::runtime.model_header_valid.load", label %land.lhs.true1.i, label %cond.false

land.lhs.true1.i:                                 ; preds = %land.lhs.true.i
  %"(anonymous namespace)::runtime.last_task_id.load" = load i32, i32* @"(anonymous namespace)::runtime.last_task_id", align 512, !alias.scope !3711, !noalias !3714
  %add.ln239 = add i32 %"(anonymous namespace)::runtime.last_task_id.load", 1
  %icmp.ln239 = icmp eq i32 %add.ln239, %t.ctx.task_id.read
  %icmp.ln240 = icmp ne i32 %t.ctx.task_id.read, -1
  %and.ln239 = and i1 %icmp.ln239, %icmp.ln240
  br i1 %and.ln239, label %cond.true, label %cond.false

cond.true:                                        ; preds = %land.lhs.true1.i
  %"(anonymous namespace)::runtime.inputs.identity.B.load" = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.B", align 512
  %"(anonymous namespace)::runtime.inputs.identity.S.load" = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.S", align 512
  %call.ret = call fastcc { i16, i32 } @"laya::check_context"(i32 %t.ctx.task_id.read, i8 %t.ctx.op.read, i8 %t_ctx_stage.val, i8 %t_ctx_layer.val, i8 0, i8 2, i16 0, i8 1, i16 %"(anonymous namespace)::runtime.inputs.identity.B.load", i16 %"(anonymous namespace)::runtime.inputs.identity.S.load")
  %c.code = extractvalue { i16, i32 } %call.ret, 0
  %c.detail = extractvalue { i16, i32 } %call.ret, 1
  br label %cond.end

cond.false:                                       ; preds = %land.lhs.true1.i, %land.lhs.true.i, %entry
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %c.detail.0 = phi i32 [ %c.detail, %cond.true ], [ 67108868, %cond.false ]
  %c.code.0 = phi i16 [ %c.code, %cond.true ], [ 5, %cond.false ]
  %icmp.ln9.196 = icmp eq i16 %c.code.0, 0
  br i1 %icmp.ln9.196, label %lor.lhs.false4, label %if.end

lor.lhs.false4:                                   ; preds = %cond.end
  %zext.ln249 = zext i8 %t.ctx.op.read to i32
  %zext.ln249.1 = zext i8 %t_kind.val to i32
  %add.ln249 = add nuw nsw i32 %zext.ln249.1, 128
  %icmp.ln249 = icmp eq i32 %add.ln249, %zext.ln249
  br i1 %icmp.ln249, label %lor.rhs, label %if.then25

lor.rhs:                                          ; preds = %lor.lhs.false4
  %icmp.ln35 = icmp eq i8 %t_dst_id.val, 0
  br i1 %icmp.ln35, label %if.then.i, label %if.end.i

if.then.i:                                        ; preds = %lor.rhs
  %icmp.ln35.3 = icmp eq i32 %t_dst_epoch.val, 0
  %icmp.ln35.4 = icmp eq i8 %t_dst_bank.val, 0
  %and.ln35 = and i1 %icmp.ln35.4, %icmp.ln35.3
  %select.ln35 = select i1 %and.ln35, i16 0, i16 5
  br label %_ZN4laya9check_refENS_9BufferRefEh.exit

if.end.i:                                         ; preds = %lor.rhs
  switch i32 %t_dst_epoch.val, label %land.lhs.true21.i [
    i32 -1, label %if.then10.i
    i32 0, label %if.then10.i
  ]

if.then10.i:                                      ; preds = %if.end.i, %if.end.i
  br label %_ZN4laya9check_refENS_9BufferRefEh.exit

land.lhs.true21.i:                                ; preds = %if.end.i
  %icmp.ln37 = icmp ult i8 %t_dst_id.val, 12
  br i1 %icmp.ln37, label %if.end33.i, label %lor.rhs.i

lor.rhs.i:                                        ; preds = %land.lhs.true21.i
  %icmp.ln37.2 = icmp ugt i8 %t_dst_id.val, 31
  %icmp.ln37.3 = icmp ult i8 %t_dst_id.val, 44
  %valid = and i1 %icmp.ln37.2, %icmp.ln37.3
  br i1 %valid, label %if.end33.i, label %_ZN4laya9check_refENS_9BufferRefEh.exit

if.end33.i:                                       ; preds = %lor.rhs.i, %land.lhs.true21.i
  switch i8 %t_dst_id.val, label %lor.rhs39.i [
    i8 1, label %lor.end52.i
    i8 5, label %lor.end52.i
  ]

lor.rhs39.i:                                      ; preds = %if.end33.i
  %add.ln39 = add i8 %t_dst_id.val, -32
  %icmp.ln39 = icmp ult i8 %add.ln39, 12
  %icmp.ln39.2 = icmp ne i8 %t_dst_id.val, 42
  %and.ln39 = and i1 %icmp.ln39, %icmp.ln39.2
  %icmp.ln39.3 = icmp ne i8 %t_dst_id.val, 43
  %and.ln39.1 = and i1 %and.ln39, %icmp.ln39.3
  br label %lor.end52.i

lor.end52.i:                                      ; preds = %lor.rhs39.i, %if.end33.i, %if.end33.i
  %dual = phi i1 [ %and.ln39.1, %lor.rhs39.i ], [ true, %if.end33.i ], [ true, %if.end33.i ]
  %add.ln40 = add i8 %t_dst_id.val, -42
  %icmp.ln40 = icmp ult i8 %add.ln40, 2
  %dual.1 = or i1 %icmp.ln40, %dual
  %zext.ln41 = zext i8 %t_dst_bank.val to i32
  %zext.ln41.2 = zext i1 %dual.1 to i32
  %icmp.ln41 = icmp ult i32 %zext.ln41.2, %zext.ln41
  %select.ln41 = select i1 %icmp.ln41, i16 5, i16 0
  br label %_ZN4laya9check_refENS_9BufferRefEh.exit

_ZN4laya9check_refENS_9BufferRefEh.exit:          ; preds = %lor.end52.i, %lor.rhs.i, %if.then10.i, %if.then.i
  %ref.tmp.0.1 = phi i16 [ %select.ln35, %if.then.i ], [ 5, %if.then10.i ], [ %select.ln41, %lor.end52.i ], [ 5, %lor.rhs.i ]
  %icmp.ln9.198 = icmp eq i16 %ref.tmp.0.1, 0
  br i1 %icmp.ln9.198, label %if.end29, label %if.then25

if.then25:                                        ; preds = %_ZN4laya9check_refENS_9BufferRefEh.exit, %lor.lhs.false4
  %zext.ln11 = zext i8 %t_dst_id.val to i32
  %shl.ln11 = shl nuw nsw i32 %zext.ln11, 16
  %c.detail.193 = or i32 %shl.ln11, 67108869
  br label %if.end

if.end:                                           ; preds = %if.then25, %cond.end
  %c.detail.1 = phi i32 [ %c.detail.193, %if.then25 ], [ %c.detail.0, %cond.end ]
  %.0430 = phi i16 [ 5, %if.then25 ], [ %c.code.0, %cond.end ]
  %call.ret163 = call fastcc { i16, i32, i64, i32, i16, i32, i64, i32, i8 } @"laya::full::(anonymous namespace)::finish_load"(i32 %t.ctx.task_id.read, i8 %t.ctx.op.read, i32 %t.byte_count.read, i16 %.0430, i32 %c.detail.1, i64 -1)
  %newret195 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret163, 0
  %newret197 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret163, 1
  %newret199 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret163, 2
  %newret201 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret163, 3
  %newret203 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret163, 4
  %newret205 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret163, 5
  %newret207 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret163, 6
  %newret209 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret163, 7
  %newret211 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret163, 8
  br label %cleanup773

if.end29:                                         ; preds = %_ZN4laya9check_refENS_9BufferRefEh.exit
  %icmp.ln255 = icmp eq i8 %t_kind.val, 0
  br i1 %icmp.ln255, label %arrayinit.body.i.preheader, label %if.end79

arrayinit.body.i.preheader:                       ; preds = %if.end29
  br label %arrayinit.body.i

arrayinit.body.i:                                 ; preds = %arrayinit.body.i, %arrayinit.body.i.preheader
  %arrayinit.curidx.i = phi i64 [ %add.ln52, %arrayinit.body.i ], [ 0, %arrayinit.body.i.preheader ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 48, i64 48, i64 48), !fpga.pragma.source !169
  %d.name.addr = getelementptr [48 x i8], [48 x i8]* %d.name, i64 0, i64 %arrayinit.curidx.i
  %add.ln52 = add nuw nsw i64 %arrayinit.curidx.i, 1
  store i8 0, i8* %d.name.addr, align 1, !alias.scope !3716, !noalias !3719
  %icmp.ln52 = icmp eq i64 %arrayinit.curidx.i, 47
  br i1 %icmp.ln52, label %arrayinit.body3.i.preheader, label %arrayinit.body.i, !llvm.loop !3736

arrayinit.body3.i.preheader:                      ; preds = %arrayinit.body.i
  br label %arrayinit.body3.i

arrayinit.body3.i:                                ; preds = %arrayinit.body3.i, %arrayinit.body3.i.preheader
  %arrayinit.curidx4.i = phi i64 [ %add.ln56, %arrayinit.body3.i ], [ 0, %arrayinit.body3.i.preheader ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 2, i64 2, i64 2), !fpga.pragma.source !169
  %d.q_base.addr = getelementptr [2 x i32], [2 x i32]* %d.q_base, i64 0, i64 %arrayinit.curidx4.i
  %add.ln56 = add nuw nsw i64 %arrayinit.curidx4.i, 1
  store i32 0, i32* %d.q_base.addr, align 4, !alias.scope !3737, !noalias !3738
  %icmp.ln56 = icmp eq i64 %arrayinit.curidx4.i, 1
  br i1 %icmp.ln56, label %arrayinit.body10.i.preheader, label %arrayinit.body3.i, !llvm.loop !3739

arrayinit.body10.i.preheader:                     ; preds = %arrayinit.body3.i
  br label %arrayinit.body10.i

arrayinit.body10.i:                               ; preds = %arrayinit.body10.i, %arrayinit.body10.i.preheader
  %arrayinit.curidx11.i = phi i64 [ %add.ln56.3, %arrayinit.body10.i ], [ 0, %arrayinit.body10.i.preheader ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 2, i64 2, i64 2), !fpga.pragma.source !169
  %d.q_span.addr = getelementptr [2 x i32], [2 x i32]* %d.q_span, i64 0, i64 %arrayinit.curidx11.i
  %add.ln56.3 = add nuw nsw i64 %arrayinit.curidx11.i, 1
  store i32 0, i32* %d.q_span.addr, align 4, !alias.scope !3740, !noalias !3741
  %icmp.ln56.3 = icmp eq i64 %arrayinit.curidx11.i, 1
  br i1 %icmp.ln56.3, label %arrayinit.body17.i.preheader, label %arrayinit.body10.i, !llvm.loop !3742

arrayinit.body17.i.preheader:                     ; preds = %arrayinit.body10.i
  br label %arrayinit.body17.i

arrayinit.body17.i:                               ; preds = %arrayinit.body17.i, %arrayinit.body17.i.preheader
  %arrayinit.curidx18.i = phi i64 [ %add.ln60, %arrayinit.body17.i ], [ 0, %arrayinit.body17.i.preheader ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 32, i64 32, i64 32), !fpga.pragma.source !169
  %d.source_sha256.addr = getelementptr [32 x i8], [32 x i8]* %d.source_sha256, i64 0, i64 %arrayinit.curidx18.i
  %add.ln60 = add nuw nsw i64 %arrayinit.curidx18.i, 1
  store i8 0, i8* %d.source_sha256.addr, align 1, !alias.scope !3743, !noalias !3744
  %icmp.ln60 = icmp eq i64 %arrayinit.curidx18.i, 31
  br i1 %icmp.ln60, label %arrayinit.body24.i.preheader, label %arrayinit.body17.i, !llvm.loop !3745

arrayinit.body24.i.preheader:                     ; preds = %arrayinit.body17.i
  br label %arrayinit.body24.i

arrayinit.body24.i:                               ; preds = %arrayinit.body24.i, %arrayinit.body24.i.preheader
  %arrayinit.curidx25.i = phi i64 [ %add.ln61, %arrayinit.body24.i ], [ 0, %arrayinit.body24.i.preheader ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 32, i64 32, i64 32), !fpga.pragma.source !169
  %d.bias_sha256.addr = getelementptr [32 x i8], [32 x i8]* %d.bias_sha256, i64 0, i64 %arrayinit.curidx25.i
  %add.ln61 = add nuw nsw i64 %arrayinit.curidx25.i, 1
  store i8 0, i8* %d.bias_sha256.addr, align 1, !alias.scope !3746, !noalias !3747
  %icmp.ln61 = icmp eq i64 %arrayinit.curidx25.i, 31
  br i1 %icmp.ln61, label %_ZN4laya4full20FullWeightDescriptorC2Ev.exit, label %arrayinit.body24.i, !llvm.loop !3748

_ZN4laya4full20FullWeightDescriptorC2Ev.exit:     ; preds = %arrayinit.body24.i
  %call.ret169 = call fastcc { i16, i32, i8, i8, i16, i16, i8, i8, i32, i32, i32, i32, i32, i32 } @"laya::full::full_lookup_weight"(i8 %t_weight_family.val, i8 %t_weight_layer.val, [48 x i8]* %d.name, [2 x i32]* %d.q_base, [2 x i32]* %d.q_span, [32 x i8]* %d.source_sha256, [32 x i8]* %d.bias_sha256)
  %c.code.181 = extractvalue { i16, i32, i8, i8, i16, i16, i8, i8, i32, i32, i32, i32, i32, i32 } %call.ret169, 0
  %d.K = extractvalue { i16, i32, i8, i8, i16, i16, i8, i8, i32, i32, i32, i32, i32, i32 } %call.ret169, 4
  %d.N = extractvalue { i16, i32, i8, i8, i16, i16, i8, i8, i32, i32, i32, i32, i32, i32 } %call.ret169, 5
  %d.dtype = extractvalue { i16, i32, i8, i8, i16, i16, i8, i8, i32, i32, i32, i32, i32, i32 } %call.ret169, 6
  %icmp.ln258.2 = icmp ne i16 %c.code.181, 0
  %icmp.ln258 = icmp ne i8 %d.dtype, 8
  %or.ln258 = or i1 %icmp.ln258, %icmp.ln258.2
  br i1 %or.ln258, label %if.then71, label %lor.lhs.false40

lor.lhs.false40:                                  ; preds = %_ZN4laya4full20FullWeightDescriptorC2Ev.exit
  %icmp.ln258.1 = icmp ne i8 %t_dst_id.val, 35
  %icmp.ln259 = icmp ne i8 %t_dst_bank.val, 0
  %or.ln258.1 = or i1 %icmp.ln258.1, %icmp.ln259
  br i1 %or.ln258.1, label %if.then71, label %lor.lhs.false48

lor.lhs.false48:                                  ; preds = %lor.lhs.false40
  %icmp.ln259.1 = icmp ne i8 %t_head.val, -1
  %icmp.ln259.2 = icmp ne i8 %t_planes.val, 0
  %or.ln259 = or i1 %icmp.ln259.1, %icmp.ln259.2
  br i1 %or.ln259, label %if.then71, label %lor.lhs.false54

lor.lhs.false54:                                  ; preds = %lor.lhs.false48
  %zext.ln260 = zext i16 %d.N to i32
  %zext.ln261 = zext i16 %d.K to i32
  %lshr.ln261 = lshr i32 %zext.ln261, 5
  %add.ln260 = add nuw nsw i32 %zext.ln260, 7
  %and.ln260 = and i32 %add.ln260, 131064
  %mul.ln260 = mul i32 %lshr.ln261, 34
  %mul.ln261 = mul i32 %mul.ln260, %and.ln260
  %icmp.ln260 = icmp eq i32 %mul.ln261, %t.byte_count.read
  br i1 %icmp.ln260, label %lor.rhs60, label %if.then71

lor.rhs60:                                        ; preds = %lor.lhs.false54
  %add.ln48 = add i8 %t_weight_family.val, -1
  %icmp.ln48 = icmp ugt i8 %add.ln48, 11
  br i1 %icmp.ln48, label %_ZN4laya12check_weightENS_9WeightKeyEhhttb.exit, label %if.end.i180

if.end.i180:                                      ; preds = %lor.rhs60
  switch i8 %t_weight_family.val, label %sw.epilog.i [
    i8 1, label %sw.bb.i
    i8 5, label %sw.bb.i
    i8 2, label %sw.bb4.i
    i8 6, label %sw.bb4.i
    i8 3, label %sw.bb5.i
    i8 4, label %sw.bb6.i
    i8 7, label %sw.bb7.i
    i8 8, label %sw.bb8.i
    i8 9, label %sw.bb9.i
    i8 10, label %sw.bb10.i
    i8 11, label %sw.bb11.i
    i8 12, label %sw.bb12.i
  ]

sw.bb.i:                                          ; preds = %if.end.i180, %if.end.i180
  br label %sw.epilog.i

sw.bb4.i:                                         ; preds = %if.end.i180, %if.end.i180
  br label %sw.epilog.i

sw.bb5.i:                                         ; preds = %if.end.i180
  br label %sw.epilog.i

sw.bb6.i:                                         ; preds = %if.end.i180
  br label %sw.epilog.i

sw.bb7.i:                                         ; preds = %if.end.i180
  br label %sw.epilog.i

sw.bb8.i:                                         ; preds = %if.end.i180
  br label %sw.epilog.i

sw.bb9.i:                                         ; preds = %if.end.i180
  br label %sw.epilog.i

sw.bb10.i:                                        ; preds = %if.end.i180
  br label %sw.epilog.i

sw.bb11.i:                                        ; preds = %if.end.i180
  br label %sw.epilog.i

sw.bb12.i:                                        ; preds = %if.end.i180
  br label %sw.epilog.i

sw.epilog.i:                                      ; preds = %sw.bb12.i, %sw.bb11.i, %sw.bb10.i, %sw.bb9.i, %sw.bb8.i, %sw.bb7.i, %sw.bb6.i, %sw.bb5.i, %sw.bb4.i, %sw.bb.i, %if.end.i180
  %ek = phi i16 [ 256, %sw.bb12.i ], [ 1028, %sw.bb11.i ], [ 1024, %sw.bb10.i ], [ 1024, %sw.bb9.i ], [ 4096, %sw.bb8.i ], [ 1024, %sw.bb7.i ], [ 2624, %sw.bb6.i ], [ 1024, %sw.bb5.i ], [ 1024, %sw.bb4.i ], [ 1024, %sw.bb.i ], [ 0, %if.end.i180 ]
  %en = phi i16 [ 2, %sw.bb12.i ], [ 256, %sw.bb11.i ], [ 1, %sw.bb10.i ], [ 1024, %sw.bb9.i ], [ 1024, %sw.bb8.i ], [ 4096, %sw.bb7.i ], [ 1024, %sw.bb6.i ], [ 5248, %sw.bb5.i ], [ 1024, %sw.bb4.i ], [ 3072, %sw.bb.i ], [ 0, %if.end.i180 ]
  %icmp.ln51 = icmp ne i16 %d.K, %ek
  %icmp.ln51.5 = icmp ne i16 %d.N, %en
  %or.ln51 = or i1 %icmp.ln51, %icmp.ln51.5
  br i1 %or.ln51, label %if.then71.critedge, label %lor.lhs.false20.i

lor.lhs.false20.i:                                ; preds = %sw.epilog.i
  %icmp.ln51.6 = icmp eq i8 %t_weight_family.val, 10
  %add.ln51 = add i8 %t_weight_family.val, -10
  %icmp.ln51.7 = icmp ult i8 %add.ln51, 2
  br i1 %icmp.ln51.7, label %if.then71.critedge, label %if.end33.i187

if.end33.i187:                                    ; preds = %lor.lhs.false20.i
  %icmp.ln52.10 = icmp ult i8 %t_weight_family.val, 5
  br i1 %icmp.ln52.10, label %if.then36.i, label %if.else.i192

if.then36.i:                                      ; preds = %if.end33.i187
  %icmp.ln52.11 = icmp ne i8 %t_ctx_stage.val, 2
  %icmp.ln52.12 = icmp ugt i8 %t_ctx_layer.val, 27
  %or.ln52 = or i1 %icmp.ln52.11, %icmp.ln52.12
  %icmp.ln52.13 = icmp ne i8 %t_weight_layer.val, %t_ctx_layer.val
  %or.ln52.2 = or i1 %or.ln52, %icmp.ln52.13
  br i1 %or.ln52.2, label %_ZN4laya12check_weightENS_9WeightKeyEhhttb.exit, label %if.end95.i

if.else.i192:                                     ; preds = %if.end33.i187
  %icmp.ln53 = icmp ult i8 %t_weight_family.val, 9
  br i1 %icmp.ln53, label %if.then55.i, label %if.else72.i

if.then55.i:                                      ; preds = %if.else.i192
  %icmp.ln53.9 = icmp ne i8 %t_ctx_stage.val, 4
  %icmp.ln53.10 = icmp ugt i8 %t_ctx_layer.val, 1
  %or.ln53 = or i1 %icmp.ln53.9, %icmp.ln53.10
  %icmp.ln53.11 = icmp ne i8 %t_weight_layer.val, %t_ctx_layer.val
  %or.ln53.2 = or i1 %or.ln53, %icmp.ln53.11
  br i1 %or.ln53.2, label %_ZN4laya12check_weightENS_9WeightKeyEhhttb.exit, label %if.end94.i

if.else72.i:                                      ; preds = %if.else.i192
  %icmp.ln54 = icmp eq i8 %t_weight_layer.val, -1
  br i1 %icmp.ln54, label %lor.lhs.false76.i, label %if.then88.i

lor.lhs.false76.i:                                ; preds = %if.else72.i
  %zext.ln54 = zext i8 %t_ctx_stage.val to i32
  %icmp.ln54.4 = icmp eq i8 %t_weight_family.val, 9
  %or.ln54 = or i1 %icmp.ln54.4, %icmp.ln51.6
  %select.ln54 = select i1 %or.ln54, i32 5, i32 6
  %icmp.ln54.5 = icmp ne i32 %select.ln54, %zext.ln54
  %icmp.ln54.6 = icmp ne i8 %t_ctx_layer.val, -1
  %or.ln54.2 = or i1 %icmp.ln54.5, %icmp.ln54.6
  br i1 %or.ln54.2, label %if.then88.i, label %if.end94.i

if.then88.i:                                      ; preds = %lor.lhs.false76.i, %if.else72.i
  br label %_ZN4laya12check_weightENS_9WeightKeyEhhttb.exit

if.end94.i:                                       ; preds = %lor.lhs.false76.i, %if.then55.i
  br label %if.end95.i

if.end95.i:                                       ; preds = %if.end94.i, %if.then36.i
  %call.ret180 = call fastcc { i16, i32, i64, i32, i16, i32, i64, i32, i8, i1 } @"laya::full::full_load_weight"(i8 addrspace(1)* %embedding, i64 %memory_embedding, i8 addrspace(1)* %io, i64 %memory_io, i8 addrspace(1)* %w_q0, i64 %memory_w_q0, i8 addrspace(1)* %w_q1, i64 %memory_w_q1, i8 addrspace(1)* %w_scale, i64 %memory_w_scale, i8 addrspace(1)* %aux, i64 %memory_aux, i8 addrspace(1)* %state0, i64 %memory_state0, i8 addrspace(1)* %state1, i64 %memory_state1, i8 addrspace(1)* %qkv0, i64 %memory_qkv0, i8 addrspace(1)* %qkv1, i64 %memory_qkv1, i8 addrspace(1)* %ff0, i64 %memory_ff0, i8 addrspace(1)* %ff1, i64 %memory_ff1, i8 addrspace(1)* %att_out, i64 %memory_att_out, i8 %t_weight_family.val, i8 %t_weight_layer.val, i32 %t_dst_epoch.val)
  %agg.result.0.ret = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8, i1 } %call.ret180, 0
  %agg.result.1.ret = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8, i1 } %call.ret180, 1
  %agg.result.2.ret = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8, i1 } %call.ret180, 2
  %done_task_id.ret = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8, i1 } %call.ret180, 3
  %done_status.ret = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8, i1 } %call.ret180, 4
  %done_error_detail.ret = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8, i1 } %call.ret180, 5
  %done_bad_element.ret = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8, i1 } %call.ret180, 6
  %done_output_elements.ret = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8, i1 } %call.ret180, 7
  %done_output_unit.ret = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8, i1 } %call.ret180, 8
  %done_drained.ret = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8, i1 } %call.ret180, 9
  br label %cleanup773

_ZN4laya12check_weightENS_9WeightKeyEhhttb.exit:  ; preds = %if.then88.i, %if.then55.i, %if.then36.i, %lor.rhs60
  br label %if.then71

if.then71.critedge:                               ; preds = %lor.lhs.false20.i, %sw.epilog.i
  br label %if.then71

if.then71:                                        ; preds = %if.then71.critedge, %_ZN4laya12check_weightENS_9WeightKeyEhhttb.exit, %lor.lhs.false54, %lor.lhs.false48, %lor.lhs.false40, %_ZN4laya4full20FullWeightDescriptorC2Ev.exit
  %call.ret181 = call fastcc { i16, i32, i64, i32, i16, i32, i64, i32, i8 } @"laya::full::(anonymous namespace)::finish_load"(i32 %t.ctx.task_id.read, i8 %t.ctx.op.read, i32 %t.byte_count.read, i16 5, i32 69402629, i64 -1)
  %newret213 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret181, 0
  %newret215 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret181, 1
  %newret217 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret181, 2
  %newret219 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret181, 3
  %newret221 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret181, 4
  %newret223 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret181, 5
  %newret225 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret181, 6
  %newret227 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret181, 7
  %newret229 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret181, 8
  br label %cleanup773

if.end79:                                         ; preds = %if.end29
  %icmp.ln269 = icmp ne i8 %t_weight_family.val, 0
  %icmp.ln269.1 = icmp ne i8 %t_weight_layer.val, -1
  %or.ln269 = or i1 %icmp.ln269, %icmp.ln269.1
  br i1 %or.ln269, label %if.then87, label %if.end92

if.then87:                                        ; preds = %if.end79
  %zext.ln11.22 = zext i8 %t_dst_id.val to i32
  %shl.ln11.28 = shl nuw nsw i32 %zext.ln11.22, 16
  %c.detail.194 = or i32 %shl.ln11.28, 67108869
  %call.ret164 = call fastcc { i16, i32, i64, i32, i16, i32, i64, i32, i8 } @"laya::full::(anonymous namespace)::finish_load"(i32 %t.ctx.task_id.read, i8 %t.ctx.op.read, i32 %t.byte_count.read, i16 5, i32 %c.detail.194, i64 -1)
  %newret231 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret164, 0
  %newret233 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret164, 1
  %newret235 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret164, 2
  %newret237 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret164, 3
  %newret239 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret164, 4
  %newret241 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret164, 5
  %newret243 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret164, 6
  %newret245 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret164, 7
  %newret247 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret164, 8
  br label %cleanup773

if.end92:                                         ; preds = %if.end79
  switch i8 %t_kind.val, label %if.end431 [
    i8 2, label %if.then96
    i8 3, label %if.then213
  ]

if.then96:                                        ; preds = %if.end92
  %icmp.ln274 = icmp eq i8 %t_ctx_stage.val, 1
  %bank = select i1 %icmp.ln274, i8 0, i8 1
  switch i8 %t_ctx_stage.val, label %if.then131 [
    i8 3, label %lor.lhs.false111
    i8 1, label %lor.lhs.false111
  ]

lor.lhs.false111:                                 ; preds = %if.then96, %if.then96
  %icmp.ln276 = icmp ne i8 %t_dst_id.val, 42
  %icmp.ln276.1 = icmp ne i8 %bank, %t_dst_bank.val
  %or.ln276 = or i1 %icmp.ln276, %icmp.ln276.1
  br i1 %or.ln276, label %if.then131, label %lor.lhs.false121

lor.lhs.false121:                                 ; preds = %lor.lhs.false111
  %icmp.ln277 = icmp ne i8 %t_head.val, -1
  %icmp.ln277.1 = icmp ne i8 %t_planes.val, 0
  %or.ln277 = or i1 %icmp.ln277, %icmp.ln277.1
  %icmp.ln277.2 = icmp ne i32 %t.byte_count.read, 4096
  %or.ln277.1 = or i1 %or.ln277, %icmp.ln277.2
  br i1 %or.ln277.1, label %if.then131, label %arrayinit.body.i207.preheader

arrayinit.body.i207.preheader:                    ; preds = %lor.lhs.false121
  br label %arrayinit.body.i207

if.then131:                                       ; preds = %lor.lhs.false121, %lor.lhs.false111, %if.then96
  %call.ret165 = call fastcc { i16, i32, i64, i32, i16, i32, i64, i32, i8 } @"laya::full::(anonymous namespace)::finish_load"(i32 %t.ctx.task_id.read, i8 %t.ctx.op.read, i32 %t.byte_count.read, i16 5, i32 69861381, i64 -1)
  %newret249 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret165, 0
  %newret251 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret165, 1
  %newret253 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret165, 2
  %newret255 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret165, 3
  %newret257 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret165, 4
  %newret259 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret165, 5
  %newret261 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret165, 6
  %newret263 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret165, 7
  %newret265 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret165, 8
  br label %cleanup773

arrayinit.body.i207:                              ; preds = %arrayinit.body.i207, %arrayinit.body.i207.preheader
  %arrayinit.curidx.i203 = phi i64 [ %add.ln41, %arrayinit.body.i207 ], [ 0, %arrayinit.body.i207.preheader ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 48, i64 48, i64 48), !fpga.pragma.source !169
  %d.name.1.addr = getelementptr [48 x i8], [48 x i8]* %d.name.1, i64 0, i64 %arrayinit.curidx.i203
  %add.ln41 = add nuw nsw i64 %arrayinit.curidx.i203, 1
  store i8 0, i8* %d.name.1.addr, align 1, !alias.scope !3749, !noalias !3752
  %icmp.ln41.1 = icmp eq i64 %arrayinit.curidx.i203, 47
  br i1 %icmp.ln41.1, label %arrayinit.body3.i213.preheader, label %arrayinit.body.i207, !llvm.loop !3763

arrayinit.body3.i213.preheader:                   ; preds = %arrayinit.body.i207
  br label %arrayinit.body3.i213

arrayinit.body3.i213:                             ; preds = %arrayinit.body3.i213, %arrayinit.body3.i213.preheader
  %arrayinit.curidx4.i209 = phi i64 [ %add.ln43, %arrayinit.body3.i213 ], [ 0, %arrayinit.body3.i213.preheader ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 4, i64 4, i64 4), !fpga.pragma.source !169
  %d.ne.addr = getelementptr [4 x i32], [4 x i32]* %d.ne, i64 0, i64 %arrayinit.curidx4.i209
  %add.ln43 = add nuw nsw i64 %arrayinit.curidx4.i209, 1
  store i32 0, i32* %d.ne.addr, align 4, !alias.scope !3764, !noalias !3765
  %icmp.ln43 = icmp eq i64 %arrayinit.curidx4.i209, 3
  br i1 %icmp.ln43, label %arrayinit.body10.i219.preheader, label %arrayinit.body3.i213, !llvm.loop !3766

arrayinit.body10.i219.preheader:                  ; preds = %arrayinit.body3.i213
  br label %arrayinit.body10.i219

arrayinit.body10.i219:                            ; preds = %arrayinit.body10.i219, %arrayinit.body10.i219.preheader
  %arrayinit.curidx11.i215 = phi i64 [ %add.ln46, %arrayinit.body10.i219 ], [ 0, %arrayinit.body10.i219.preheader ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 32, i64 32, i64 32), !fpga.pragma.source !169
  %d.source_sha256.1.addr = getelementptr [32 x i8], [32 x i8]* %d.source_sha256.1, i64 0, i64 %arrayinit.curidx11.i215
  %add.ln46 = add nuw nsw i64 %arrayinit.curidx11.i215, 1
  store i8 0, i8* %d.source_sha256.1.addr, align 1, !alias.scope !3767, !noalias !3768
  %icmp.ln46 = icmp eq i64 %arrayinit.curidx11.i215, 31
  br i1 %icmp.ln46, label %_ZN4laya4full20FullTensorDescriptorC2Ev.exit, label %arrayinit.body10.i219, !llvm.loop !3769

_ZN4laya4full20FullTensorDescriptorC2Ev.exit:     ; preds = %arrayinit.body10.i219
  %icmp.ln282 = icmp ne i8 %t_dst_bank.val, 0
  %select.ln282 = select i1 %icmp.ln282, i64 0, i64 512
  %call.ret170 = call fastcc { i16, i32, i8, i8, i32, i32 } @"laya::full::(anonymous namespace)::tensor_named.45"(i64 %select.ln282, [48 x i8]* %d.name.1, [4 x i32]* %d.ne, [32 x i8]* %d.source_sha256.1)
  %c.code.182 = extractvalue { i16, i32, i8, i8, i32, i32 } %call.ret170, 0
  %c.detail.195 = extractvalue { i16, i32, i8, i8, i32, i32 } %call.ret170, 1
  %d.ggml_type_id.1 = extractvalue { i16, i32, i8, i8, i32, i32 } %call.ret170, 2
  %d.bo.1 = extractvalue { i16, i32, i8, i8, i32, i32 } %call.ret170, 3
  %d.base.1 = extractvalue { i16, i32, i8, i8, i32, i32 } %call.ret170, 4
  %d.span.1 = extractvalue { i16, i32, i8, i8, i32, i32 } %call.ret170, 5
  %icmp.ln9.199 = icmp eq i16 %c.code.182, 0
  br i1 %icmp.ln9.199, label %land.lhs.true140, label %if.end151

land.lhs.true140:                                 ; preds = %_ZN4laya4full20FullTensorDescriptorC2Ev.exit
  %icmp.ln283 = icmp ne i8 %d.bo.1, 5
  %icmp.ln283.1 = icmp ne i32 %d.span.1, 4096
  %or.ln283 = or i1 %icmp.ln283, %icmp.ln283.1
  %icmp.ln284 = icmp ne i8 %d.ggml_type_id.1, 0
  %or.ln283.1 = or i1 %or.ln283, %icmp.ln284
  %select.ln283 = select i1 %or.ln283.1, i32 67108868, i32 %c.detail.195
  %select.ln283.1 = select i1 %or.ln283.1, i16 2, i16 0
  br label %if.end151

if.end151:                                        ; preds = %land.lhs.true140, %_ZN4laya4full20FullTensorDescriptorC2Ev.exit
  %.1363136 = phi i32 [ %c.detail.195, %_ZN4laya4full20FullTensorDescriptorC2Ev.exit ], [ %select.ln283, %land.lhs.true140 ]
  %c.code.val51 = phi i16 [ %c.code.182, %_ZN4laya4full20FullTensorDescriptorC2Ev.exit ], [ %select.ln283.1, %land.lhs.true140 ]
  %icmp.ln9.200 = icmp eq i16 %c.code.val51, 0
  br i1 %icmp.ln9.200, label %if.then153, label %if.end158

if.then153:                                       ; preds = %if.end151
  %offset.4 = zext i32 %d.base.1 to i64
  %bytes = zext i32 %d.span.1 to i64
  call void (...) @_ssdm_Assume(i1 true) #1
  call void (...) @_ssdm_Assume(i1 true) #1
  call void (...) @_ssdm_Assume(i1 true) #1
  %icmp.ln117 = icmp ugt i32 %d.base.1, 1671872
  %sub.ln117 = sub i64 1671872, %offset.4
  %icmp.ln117.6 = icmp ult i64 %sub.ln117, %bytes
  %add.ln118 = add nuw nsw i64 %bytes, %offset.4
  %icmp.ln118 = icmp ugt i64 %add.ln118, 4294967296
  %or.ln116 = or i1 %icmp.ln117.6, %icmp.ln117
  %or.ln116.6 = or i1 %or.ln116, %icmp.ln118
  %c.code.183 = select i1 %or.ln116.6, i16 5, i16 0
  %c.detail.196 = select i1 %or.ln116.6, i32 67436553, i32 0
  br label %if.end158

if.end158:                                        ; preds = %if.then153, %if.end151
  %.1363 = phi i32 [ %c.detail.196, %if.then153 ], [ %.1363136, %if.end151 ]
  %c.code.val52 = phi i16 [ %c.code.183, %if.then153 ], [ %c.code.val51, %if.end151 ]
  %icmp.ln9.203 = icmp eq i16 %c.code.val52, 0
  br i1 %icmp.ln9.203, label %if.end162, label %if.then160

if.then160:                                       ; preds = %if.end158
  %call.ret173 = call fastcc { i16, i32, i64, i32, i16, i32, i64, i32, i8 } @"laya::full::(anonymous namespace)::finish_load"(i32 %t.ctx.task_id.read, i8 %t.ctx.op.read, i32 4096, i16 %c.code.val52, i32 %.1363, i64 -1)
  %newret267 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret173, 0
  %newret269 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret173, 1
  %newret271 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret173, 2
  %newret273 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret173, 3
  %newret275 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret173, 4
  %newret277 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret173, 5
  %newret279 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret173, 6
  %newret281 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret173, 7
  %newret283 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret173, 8
  br label %cleanup773

if.end162:                                        ; preds = %if.end158
  %call.ret172 = call fastcc { i16, i32 } @"laya::full::full_claim_owner"(i8 42, i8 %t_dst_bank.val, i32 %t_dst_epoch.val, i8 0, i8 %t_ctx_stage.val, i8 -1, i8 0, i8 2, i16 0, i16 1, i16 1024, i8 1)
  %c.code.185 = extractvalue { i16, i32 } %call.ret172, 0
  %c.detail.198 = extractvalue { i16, i32 } %call.ret172, 1
  %icmp.ln9.205 = icmp eq i16 %c.code.185, 0
  br i1 %icmp.ln9.205, label %VITIS_LOOP_291_1, label %if.then174

if.then174:                                       ; preds = %if.end162
  %call.ret174 = call fastcc { i16, i32, i64, i32, i16, i32, i64, i32, i8 } @"laya::full::(anonymous namespace)::finish_load"(i32 %t.ctx.task_id.read, i8 %t.ctx.op.read, i32 4096, i16 %c.code.185, i32 %c.detail.198, i64 -1)
  %newret285 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret174, 0
  %newret287 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret174, 1
  %newret289 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret174, 2
  %newret291 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret174, 3
  %newret293 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret174, 4
  %newret295 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret174, 5
  %newret297 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret174, 6
  %newret299 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret174, 7
  %newret301 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret174, 8
  br label %cleanup773

VITIS_LOOP_291_1:                                 ; preds = %if.end162
  %zext.ln293 = zext i8 %t_dst_bank.val to i64
  %raw.8.addr = getelementptr inbounds [4 x i8], [4 x i8]* %raw.8, i64 0, i64 0
  %raw.8.addr.1 = getelementptr inbounds [4 x i8], [4 x i8]* %raw.8, i64 0, i64 1
  %raw.8.addr.2 = getelementptr inbounds [4 x i8], [4 x i8]* %raw.8, i64 0, i64 2
  %raw.8.addr.3 = getelementptr inbounds [4 x i8], [4 x i8]* %raw.8, i64 0, i64 3
  br label %for.body

for.body:                                         ; preds = %_ZN4laya4full12_GLOBAL__N_112read_aux_f32ERKNS0_11FullRuntimeERKNS0_10FullMemoryEjNS_2OpERf.2878.3063.3288.3513.3738.3963.4188.4413.4638.4863.5088.5313.5538.5763.exit, %VITIS_LOOP_291_1
  %i.95 = phi i64 [ 0, %VITIS_LOOP_291_1 ], [ %add.ln291, %_ZN4laya4full12_GLOBAL__N_112read_aux_f32ERKNS0_11FullRuntimeERKNS0_10FullMemoryEjNS_2OpERf.2878.3063.3288.3513.3738.3963.4188.4413.4638.4863.5088.5313.5538.5763.exit ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 0, i64 1024, i64 512), !fpga.pragma.source !169
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @61)
  %trunc.ln292 = trunc i64 %i.95 to i32
  %shl.ln292 = shl i32 %trunc.ln292, 2
  %offset = add i32 %shl.ln292, %d.base.1
  %output = getelementptr inbounds [2 x [1024 x float]], [2 x [1024 x float]]* @"laya::full::g_full_cache_gamma", i64 0, i64 %zext.ln293, i64 %i.95
  %zext.ln196 = zext i32 %offset to i64
  %call.ret175 = call fastcc { i16, i32 } @"laya::full::full_read"(i8 addrspace(1)* %embedding, i64 %memory_embedding, i8 addrspace(1)* %io, i64 %memory_io, i8 addrspace(1)* %w_q0, i64 %memory_w_q0, i8 addrspace(1)* %w_q1, i64 %memory_w_q1, i8 addrspace(1)* %w_scale, i64 %memory_w_scale, i8 addrspace(1)* %aux, i64 %memory_aux, i8 addrspace(1)* %state0, i64 %memory_state0, i8 addrspace(1)* %state1, i64 %memory_state1, i8 addrspace(1)* %qkv0, i64 %memory_qkv0, i8 addrspace(1)* %qkv1, i64 %memory_qkv1, i8 addrspace(1)* %ff0, i64 %memory_ff0, i8 addrspace(1)* %ff1, i64 %memory_ff1, i8 addrspace(1)* %att_out, i64 %memory_att_out, i8 5, i64 %zext.ln196, [4 x i8]* %raw.8)
  %c.code.187 = extractvalue { i16, i32 } %call.ret175, 0
  %c.detail.200 = extractvalue { i16, i32 } %call.ret175, 1
  %icmp.ln9 = icmp eq i16 %c.code.187, 0
  br i1 %icmp.ln9, label %if.end.i224, label %_ZN4laya4full12_GLOBAL__N_112read_aux_f32ERKNS0_11FullRuntimeERKNS0_10FullMemoryEjNS_2OpERf.2878.3063.3288.3513.3738.3963.4188.4413.4638.4863.5088.5313.5538.5763.exit

if.end.i224:                                      ; preds = %for.body
  %raw.8.load = load i8, i8* %raw.8.addr, align 512, !noalias !3770
  %raw.8.load.1 = load i8, i8* %raw.8.addr.1, align 1, !noalias !3770
  %raw.8.load.2 = load i8, i8* %raw.8.addr.2, align 2, !noalias !3770
  %raw.8.load.3 = load i8, i8* %raw.8.addr.3, align 1, !noalias !3770
  %bits = call i32 @_ssdm_op_BitConcatenate.i32.i8.i8.i8.i8(i8 %raw.8.load.3, i8 %raw.8.load.2, i8 %raw.8.load.1, i8 %raw.8.load)
  %and.ln200 = and i32 %bits, 2139095040
  %icmp.ln200 = icmp eq i32 %and.ln200, 2139095040
  br i1 %icmp.ln200, label %_ZN4laya4full12_GLOBAL__N_112read_aux_f32ERKNS0_11FullRuntimeERKNS0_10FullMemoryEjNS_2OpERf.2878.3063.3288.3513.3738.3963.4188.4413.4638.4863.5088.5313.5538.5763.exit, label %if.end14.i

if.end14.i:                                       ; preds = %if.end.i224
  %0 = bitcast i32 %bits to float
  store float %0, float* %output, align 4, !alias.scope !3802, !noalias !3803
  br label %_ZN4laya4full12_GLOBAL__N_112read_aux_f32ERKNS0_11FullRuntimeERKNS0_10FullMemoryEjNS_2OpERf.2878.3063.3288.3513.3738.3963.4188.4413.4638.4863.5088.5313.5538.5763.exit

_ZN4laya4full12_GLOBAL__N_112read_aux_f32ERKNS0_11FullRuntimeERKNS0_10FullMemoryEjNS_2OpERf.2878.3063.3288.3513.3738.3963.4188.4413.4638.4863.5088.5313.5538.5763.exit: ; preds = %if.end14.i, %if.end.i224, %for.body
  %c.code.190 = phi i16 [ 0, %if.end14.i ], [ 6, %if.end.i224 ], [ %c.code.187, %for.body ]
  %c.detail.203 = phi i32 [ 0, %if.end14.i ], [ 125960207, %if.end.i224 ], [ %c.detail.200, %for.body ]
  %icmp.ln9.208 = icmp eq i16 %c.code.190, 0
  %add.ln291 = add nuw nsw i64 %i.95, 1
  %icmp.ln291 = icmp ult i64 %add.ln291, 1024
  %and.ln294 = and i1 %icmp.ln9.208, %icmp.ln291
  br i1 %and.ln294, label %for.body, label %for.end, !llvm.loop !3804

for.end:                                          ; preds = %_ZN4laya4full12_GLOBAL__N_112read_aux_f32ERKNS0_11FullRuntimeERKNS0_10FullMemoryEjNS_2OpERf.2878.3063.3288.3513.3738.3963.4188.4413.4638.4863.5088.5313.5538.5763.exit
  %icmp.ln9.i626.lcssa = phi i1 [ %icmp.ln9.208, %_ZN4laya4full12_GLOBAL__N_112read_aux_f32ERKNS0_11FullRuntimeERKNS0_10FullMemoryEjNS_2OpERf.2878.3063.3288.3513.3738.3963.4188.4413.4638.4863.5088.5313.5538.5763.exit ]
  %c.detail.203.lcssa = phi i32 [ %c.detail.203, %_ZN4laya4full12_GLOBAL__N_112read_aux_f32ERKNS0_11FullRuntimeERKNS0_10FullMemoryEjNS_2OpERf.2878.3063.3288.3513.3738.3963.4188.4413.4638.4863.5088.5313.5538.5763.exit ]
  %c.code.190.lcssa = phi i16 [ %c.code.190, %_ZN4laya4full12_GLOBAL__N_112read_aux_f32ERKNS0_11FullRuntimeERKNS0_10FullMemoryEjNS_2OpERf.2878.3063.3288.3513.3738.3963.4188.4413.4638.4863.5088.5313.5538.5763.exit ]
  br i1 %icmp.ln9.i626.lcssa, label %if.then190, label %if.end192

if.then190:                                       ; preds = %for.end
  %call.ret178 = call fastcc { i16, i32 } @"laya::full::full_cover_owner"(i8 42, i8 %t_dst_bank.val, i32 %t_dst_epoch.val, i8 0, i8 %t_ctx_stage.val, i8 -1, i8 0, i8 2, i16 0, i16 1, i16 1024, i8 1, i8 0, i16 0, i16 1)
  %c.code.191 = extractvalue { i16, i32 } %call.ret178, 0
  %c.detail.204 = extractvalue { i16, i32 } %call.ret178, 1
  br label %if.end192

if.end192:                                        ; preds = %if.then190, %for.end
  %.1318142 = phi i32 [ %c.detail.204, %if.then190 ], [ %c.detail.203.lcssa, %for.end ]
  %c.code.val55 = phi i16 [ %c.code.191, %if.then190 ], [ %c.code.190.lcssa, %for.end ]
  %icmp.ln9.209 = icmp eq i16 %c.code.val55, 0
  br i1 %icmp.ln9.209, label %if.then194, label %if.end196

if.then194:                                       ; preds = %if.end192
  %call.ret179 = call fastcc { i16, i32 } @"laya::full::full_publish_owner"(i8 42, i8 %t_dst_bank.val, i32 %t_dst_epoch.val, i8 0, i8 %t_ctx_stage.val, i8 -1, i8 0, i8 2, i16 0, i16 1, i16 1024, i8 1)
  %c.code.192 = extractvalue { i16, i32 } %call.ret179, 0
  %c.detail.205 = extractvalue { i16, i32 } %call.ret179, 1
  br label %if.end196

if.end196:                                        ; preds = %if.then194, %if.end192
  %.1318 = phi i32 [ %c.detail.205, %if.then194 ], [ %.1318142, %if.end192 ]
  %c.code.val56 = phi i16 [ %c.code.192, %if.then194 ], [ %c.code.val55, %if.end192 ]
  %icmp.ln9.210 = icmp eq i16 %c.code.val56, 0
  br i1 %icmp.ln9.210, label %if.else, label %if.then198

if.then198:                                       ; preds = %if.end196
  %1 = call fastcc i16 @"laya::full::full_invalidate_owner"(i8 42, i8 %t_dst_bank.val, i32 %t_dst_epoch.val, i8 0)
  br label %if.end204

if.else:                                          ; preds = %if.end196
  %"(anonymous namespace)::runtime.loaded_gamma_ref.id.addr" = getelementptr [2 x i8], [2 x i8]* @"(anonymous namespace)::runtime.loaded_gamma_ref.id", i64 0, i64 %zext.ln293
  store i8 42, i8* %"(anonymous namespace)::runtime.loaded_gamma_ref.id.addr", align 8
  %"(anonymous namespace)::runtime.loaded_gamma_ref.bank.addr" = getelementptr [2 x i8], [2 x i8]* @"(anonymous namespace)::runtime.loaded_gamma_ref.bank", i64 0, i64 %zext.ln293
  store i8 %t_dst_bank.val, i8* %"(anonymous namespace)::runtime.loaded_gamma_ref.bank.addr", align 1
  %"(anonymous namespace)::runtime.loaded_gamma_ref.epoch.addr" = getelementptr [2 x i32], [2 x i32]* @"(anonymous namespace)::runtime.loaded_gamma_ref.epoch", i64 0, i64 %zext.ln293
  store i32 %t_dst_epoch.val, i32* %"(anonymous namespace)::runtime.loaded_gamma_ref.epoch.addr", align 4
  br label %if.end204

if.end204:                                        ; preds = %if.else, %if.then198
  %call.ret182 = call fastcc { i16, i32, i64, i32, i16, i32, i64, i32, i8 } @"laya::full::(anonymous namespace)::finish_load"(i32 %t.ctx.task_id.read, i8 %t.ctx.op.read, i32 4096, i16 %c.code.val56, i32 %.1318, i64 -1)
  %newret303 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret182, 0
  %newret305 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret182, 1
  %newret307 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret182, 2
  %newret309 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret182, 3
  %newret311 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret182, 4
  %newret313 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret182, 5
  %newret315 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret182, 6
  %newret317 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret182, 7
  %newret319 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret182, 8
  br label %cleanup773

if.then213:                                       ; preds = %if.end92
  %urem.ln303 = urem i8 %t_ctx_layer.val, 3
  %icmp.ln303 = icmp eq i8 %urem.ln303, 0
  %mode = select i1 %icmp.ln303, i8 0, i8 1
  %icmp.ln304 = icmp ne i8 %t_ctx_stage.val, 2
  %icmp.ln304.1 = icmp ugt i8 %t_ctx_layer.val, 27
  %or.ln304 = or i1 %icmp.ln304, %icmp.ln304.1
  br i1 %or.ln304, label %if.then249, label %lor.lhs.false229

lor.lhs.false229:                                 ; preds = %if.then213
  %icmp.ln305 = icmp ne i8 %t_dst_id.val, 43
  %icmp.ln305.1 = icmp ne i8 %mode, %t_dst_bank.val
  %or.ln305 = or i1 %icmp.ln305, %icmp.ln305.1
  br i1 %or.ln305, label %if.then249, label %lor.lhs.false239

lor.lhs.false239:                                 ; preds = %lor.lhs.false229
  %icmp.ln306 = icmp ne i8 %t_head.val, -1
  %icmp.ln306.1 = icmp ne i8 %t_planes.val, 0
  %or.ln306 = or i1 %icmp.ln306, %icmp.ln306.1
  %icmp.ln306.2 = icmp ne i32 %t.byte_count.read, 524800
  %or.ln306.1 = or i1 %or.ln306, %icmp.ln306.2
  br i1 %or.ln306.1, label %if.then249, label %if.end252

if.then249:                                       ; preds = %lor.lhs.false239, %lor.lhs.false229, %if.then213
  %call.ret166 = call fastcc { i16, i32, i64, i32, i16, i32, i64, i32, i8 } @"laya::full::(anonymous namespace)::finish_load"(i32 %t.ctx.task_id.read, i8 %t.ctx.op.read, i32 %t.byte_count.read, i16 5, i32 69926917, i64 -1)
  %newret292 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret166, 0
  %newret294 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret166, 1
  %newret296 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret166, 2
  %newret298 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret166, 3
  %newret300 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret166, 4
  %newret302 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret166, 5
  %newret304 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret166, 6
  %newret306 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret166, 7
  %newret308 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret166, 8
  br label %cleanup773

if.end252:                                        ; preds = %lor.lhs.false239
  %d.ggml_type_id.addr = getelementptr [2 x i8], [2 x i8]* %d.ggml_type_id, i64 0, i64 0
  %d.omitted.addr = getelementptr [2 x i8], [2 x i8]* %d.omitted, i64 0, i64 0
  br label %arrayctor.loop

arrayctor.loop:                                   ; preds = %_ZN4laya4full20FullTensorDescriptorC2Ev.5980.exit, %if.end252
  %indvars.iv170 = phi i64 [ %add.ln310, %_ZN4laya4full20FullTensorDescriptorC2Ev.5980.exit ], [ 0, %if.end252 ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 2, i64 2, i64 2), !fpga.pragma.source !169
  br label %arrayinit.body.i230

arrayinit.body.i230:                              ; preds = %arrayinit.body.i230, %arrayctor.loop
  %arrayinit.curidx.i226 = phi i64 [ 0, %arrayctor.loop ], [ %add.ln41.1, %arrayinit.body.i230 ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 48, i64 48, i64 48), !fpga.pragma.source !169
  %d.name.2.addr = getelementptr [2 x [48 x i8]], [2 x [48 x i8]]* %d.name.2, i64 0, i64 %indvars.iv170, i64 %arrayinit.curidx.i226
  %add.ln41.1 = add nuw nsw i64 %arrayinit.curidx.i226, 1
  store i8 0, i8* %d.name.2.addr, align 1, !alias.scope !3876, !noalias !3879
  %icmp.ln41.2 = icmp eq i64 %arrayinit.curidx.i226, 47
  br i1 %icmp.ln41.2, label %arrayinit.end.i231, label %arrayinit.body.i230, !llvm.loop !3890

arrayinit.end.i231:                               ; preds = %arrayinit.body.i230
  %this.ggml_type_id = getelementptr [2 x i8], [2 x i8]* %d.ggml_type_id, i64 0, i64 %indvars.iv170
  %this.omitted = getelementptr [2 x i8], [2 x i8]* %d.omitted, i64 0, i64 %indvars.iv170
  %this.bo = getelementptr [2 x i8], [2 x i8]* %d.bo, i64 0, i64 %indvars.iv170
  %this.reserved = getelementptr [2 x i8], [2 x i8]* %d.reserved, i64 0, i64 %indvars.iv170
  store i8 0, i8* %this.ggml_type_id, align 4, !alias.scope !3892, !noalias !3893
  store i8 -1, i8* %this.bo, align 1, !alias.scope !3894, !noalias !3895
  store i8 0, i8* %this.omitted, align 2, !alias.scope !3896, !noalias !3897
  store i8 0, i8* %this.reserved, align 1, !alias.scope !3898, !noalias !3899
  br label %arrayinit.body3.i236

arrayinit.body3.i236:                             ; preds = %arrayinit.body3.i236, %arrayinit.end.i231
  %arrayinit.curidx4.i232 = phi i64 [ 0, %arrayinit.end.i231 ], [ %add.ln43.1, %arrayinit.body3.i236 ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 4, i64 4, i64 4), !fpga.pragma.source !169
  %d.ne.1.addr = getelementptr [2 x [4 x i32]], [2 x [4 x i32]]* %d.ne.1, i64 0, i64 %indvars.iv170, i64 %arrayinit.curidx4.i232
  %add.ln43.1 = add nuw nsw i64 %arrayinit.curidx4.i232, 1
  store i32 0, i32* %d.ne.1.addr, align 4, !alias.scope !3900, !noalias !3901
  %icmp.ln43.1 = icmp eq i64 %arrayinit.curidx4.i232, 3
  br i1 %icmp.ln43.1, label %arrayinit.end8.i237, label %arrayinit.body3.i236, !llvm.loop !3902

arrayinit.end8.i237:                              ; preds = %arrayinit.body3.i236
  %this.source_offset = getelementptr [2 x i32], [2 x i32]* %d.source_offset, i64 0, i64 %indvars.iv170
  %this.base = getelementptr [2 x i32], [2 x i32]* %d.base, i64 0, i64 %indvars.iv170
  %this.source_bytes = getelementptr [2 x i32], [2 x i32]* %d.source_bytes, i64 0, i64 %indvars.iv170
  %this.span = getelementptr [2 x i32], [2 x i32]* %d.span, i64 0, i64 %indvars.iv170
  store i32 0, i32* %this.source_offset, align 4, !alias.scope !3904, !noalias !3905
  store i32 0, i32* %this.source_bytes, align 4, !alias.scope !3906, !noalias !3907
  store i32 0, i32* %this.base, align 4, !alias.scope !3908, !noalias !3909
  store i32 0, i32* %this.span, align 4, !alias.scope !3910, !noalias !3911
  br label %arrayinit.body10.i242

arrayinit.body10.i242:                            ; preds = %arrayinit.body10.i242, %arrayinit.end8.i237
  %arrayinit.curidx11.i238 = phi i64 [ 0, %arrayinit.end8.i237 ], [ %add.ln46.1, %arrayinit.body10.i242 ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 32, i64 32, i64 32), !fpga.pragma.source !169
  %d.source_sha256.2.addr = getelementptr [2 x [32 x i8]], [2 x [32 x i8]]* %d.source_sha256.2, i64 0, i64 %indvars.iv170, i64 %arrayinit.curidx11.i238
  %add.ln46.1 = add nuw nsw i64 %arrayinit.curidx11.i238, 1
  store i8 0, i8* %d.source_sha256.2.addr, align 1, !alias.scope !3912, !noalias !3913
  %icmp.ln46.11 = icmp eq i64 %arrayinit.curidx11.i238, 31
  br i1 %icmp.ln46.11, label %_ZN4laya4full20FullTensorDescriptorC2Ev.5980.exit, label %arrayinit.body10.i242, !llvm.loop !3914

_ZN4laya4full20FullTensorDescriptorC2Ev.5980.exit: ; preds = %arrayinit.body10.i242
  %add.ln310 = add nuw nsw i64 %indvars.iv170, 1
  %icmp.ln310 = icmp eq i64 %indvars.iv170, 1
  br i1 %icmp.ln310, label %if.end252254, label %arrayctor.loop, !llvm.loop !3916

if.end252254:                                     ; preds = %_ZN4laya4full20FullTensorDescriptorC2Ev.5980.exit
  %d.bo.addr.1 = getelementptr [2 x i8], [2 x i8]* %d.bo, i64 0, i64 0
  %d.reserved.addr.1 = getelementptr [2 x i8], [2 x i8]* %d.reserved, i64 0, i64 0
  %icmp.ln311 = icmp ne i8 %t_dst_bank.val, 0
  %select.ln311 = select i1 %icmp.ln311, i64 0, i64 512
  %d.source_offset.addr.1 = getelementptr [2 x i32], [2 x i32]* %d.source_offset, i64 0, i64 0
  %d.source_bytes.addr.1 = getelementptr [2 x i32], [2 x i32]* %d.source_bytes, i64 0, i64 0
  %d.base.addr.1 = getelementptr [2 x i32], [2 x i32]* %d.base, i64 0, i64 0
  %d.span.addr.1 = getelementptr [2 x i32], [2 x i32]* %d.span, i64 0, i64 0
  %d.ggml_type_id.load.2 = load i8, i8* %d.ggml_type_id.addr, align 512
  %d.bo.load = load i8, i8* %d.bo.addr.1, align 512
  %d.omitted.load.1 = load i8, i8* %d.omitted.addr, align 512
  %d.reserved.load = load i8, i8* %d.reserved.addr.1, align 512
  %d.source_offset.load = load i32, i32* %d.source_offset.addr.1, align 512
  %d.source_bytes.load = load i32, i32* %d.source_bytes.addr.1, align 512
  %d.base.load = load i32, i32* %d.base.addr.1, align 512
  %d.span.load = load i32, i32* %d.span.addr.1, align 512
  %tmp.2 = call fastcc { i16, i32, i8, i8, i8, i8, i32, i32, i32, i32 } @"laya::full::(anonymous namespace)::tensor_named"([521 x i8]* noalias nocapture align 512 @.str.2.97, i64 %select.ln311, [2 x [48 x i8]]* noalias nocapture align 16 %d.name.2, i64 0, i8 %d.ggml_type_id.load.2, i8 %d.bo.load, i8 %d.omitted.load.1, i8 %d.reserved.load, [2 x [4 x i32]]* noalias nocapture align 16 %d.ne.1, i64 0, i32 %d.source_offset.load, i32 %d.source_bytes.load, i32 %d.base.load, i32 %d.span.load, [2 x [32 x i8]]* noalias nocapture align 32 %d.source_sha256.2, i64 0) #1
  %c.code.184 = extractvalue { i16, i32, i8, i8, i8, i8, i32, i32, i32, i32 } %tmp.2, 0
  %c.detail.197 = extractvalue { i16, i32, i8, i8, i8, i8, i32, i32, i32, i32 } %tmp.2, 1
  %newret335 = extractvalue { i16, i32, i8, i8, i8, i8, i32, i32, i32, i32 } %tmp.2, 2
  %newret336 = extractvalue { i16, i32, i8, i8, i8, i8, i32, i32, i32, i32 } %tmp.2, 3
  %newret337 = extractvalue { i16, i32, i8, i8, i8, i8, i32, i32, i32, i32 } %tmp.2, 4
  %newret338 = extractvalue { i16, i32, i8, i8, i8, i8, i32, i32, i32, i32 } %tmp.2, 5
  %newret340 = extractvalue { i16, i32, i8, i8, i8, i8, i32, i32, i32, i32 } %tmp.2, 6
  %newret342 = extractvalue { i16, i32, i8, i8, i8, i8, i32, i32, i32, i32 } %tmp.2, 7
  %newret344 = extractvalue { i16, i32, i8, i8, i8, i8, i32, i32, i32, i32 } %tmp.2, 8
  %newret346 = extractvalue { i16, i32, i8, i8, i8, i8, i32, i32, i32, i32 } %tmp.2, 9
  store i8 %newret335, i8* %d.ggml_type_id.addr, align 512
  store i8 %newret336, i8* %d.bo.addr.1, align 512
  store i8 %newret337, i8* %d.omitted.addr, align 512
  store i8 %newret338, i8* %d.reserved.addr.1, align 512
  store i32 %newret340, i32* %d.source_offset.addr.1, align 512
  store i32 %newret342, i32* %d.source_bytes.addr.1, align 512
  store i32 %newret344, i32* %d.base.addr.1, align 512
  store i32 %newret346, i32* %d.span.addr.1, align 512
  %icmp.ln9.204 = icmp eq i16 %c.code.184, 0
  br i1 %icmp.ln9.204, label %if.then261, label %for.cond268.preheader

if.then261:                                       ; preds = %if.end252254
  %d.ggml_type_id.addr.1 = getelementptr [2 x i8], [2 x i8]* %d.ggml_type_id, i64 0, i64 1
  %d.bo.addr.2 = getelementptr [2 x i8], [2 x i8]* %d.bo, i64 0, i64 1
  %d.omitted.addr.1 = getelementptr [2 x i8], [2 x i8]* %d.omitted, i64 0, i64 1
  %d.reserved.addr.2 = getelementptr [2 x i8], [2 x i8]* %d.reserved, i64 0, i64 1
  %d.source_offset.addr.2 = getelementptr [2 x i32], [2 x i32]* %d.source_offset, i64 0, i64 1
  %d.source_bytes.addr.2 = getelementptr [2 x i32], [2 x i32]* %d.source_bytes, i64 0, i64 1
  %d.base.addr.2 = getelementptr [2 x i32], [2 x i32]* %d.base, i64 0, i64 1
  %d.span.addr.2 = getelementptr [2 x i32], [2 x i32]* %d.span, i64 0, i64 1
  %d.ggml_type_id.load = load i8, i8* %d.ggml_type_id.addr.1, align 1
  %d.bo.load.1 = load i8, i8* %d.bo.addr.2, align 1
  %d.omitted.load = load i8, i8* %d.omitted.addr.1, align 1
  %d.reserved.load.1 = load i8, i8* %d.reserved.addr.2, align 1
  %d.source_offset.load.1 = load i32, i32* %d.source_offset.addr.2, align 4
  %d.source_bytes.load.1 = load i32, i32* %d.source_bytes.addr.2, align 4
  %d.base.load.1 = load i32, i32* %d.base.addr.2, align 4
  %d.span.load.1 = load i32, i32* %d.span.addr.2, align 4
  %tmp. = call fastcc { i16, i32, i8, i8, i8, i8, i32, i32, i32, i32 } @"laya::full::(anonymous namespace)::tensor_named"([521 x i8]* noalias nocapture align 512 @.str.4.99, i64 %select.ln311, [2 x [48 x i8]]* noalias nocapture align 16 %d.name.2, i64 1, i8 %d.ggml_type_id.load, i8 %d.bo.load.1, i8 %d.omitted.load, i8 %d.reserved.load.1, [2 x [4 x i32]]* noalias nocapture align 16 %d.ne.1, i64 1, i32 %d.source_offset.load.1, i32 %d.source_bytes.load.1, i32 %d.base.load.1, i32 %d.span.load.1, [2 x [32 x i8]]* noalias nocapture align 32 %d.source_sha256.2, i64 1) #1
  %c.code.186 = extractvalue { i16, i32, i8, i8, i8, i8, i32, i32, i32, i32 } %tmp., 0
  %c.detail.199 = extractvalue { i16, i32, i8, i8, i8, i8, i32, i32, i32, i32 } %tmp., 1
  %newret370 = extractvalue { i16, i32, i8, i8, i8, i8, i32, i32, i32, i32 } %tmp., 2
  %newret372 = extractvalue { i16, i32, i8, i8, i8, i8, i32, i32, i32, i32 } %tmp., 3
  %newret374 = extractvalue { i16, i32, i8, i8, i8, i8, i32, i32, i32, i32 } %tmp., 4
  %newret376 = extractvalue { i16, i32, i8, i8, i8, i8, i32, i32, i32, i32 } %tmp., 5
  %newret378 = extractvalue { i16, i32, i8, i8, i8, i8, i32, i32, i32, i32 } %tmp., 6
  %newret380 = extractvalue { i16, i32, i8, i8, i8, i8, i32, i32, i32, i32 } %tmp., 7
  %newret382 = extractvalue { i16, i32, i8, i8, i8, i8, i32, i32, i32, i32 } %tmp., 8
  %newret384 = extractvalue { i16, i32, i8, i8, i8, i8, i32, i32, i32, i32 } %tmp., 9
  store i8 %newret370, i8* %d.ggml_type_id.addr.1, align 1
  store i8 %newret372, i8* %d.bo.addr.2, align 1
  store i8 %newret374, i8* %d.omitted.addr.1, align 1
  store i8 %newret376, i8* %d.reserved.addr.2, align 1
  store i32 %newret378, i32* %d.source_offset.addr.2, align 4
  store i32 %newret380, i32* %d.source_bytes.addr.2, align 4
  store i32 %newret382, i32* %d.base.addr.2, align 4
  store i32 %newret384, i32* %d.span.addr.2, align 4
  br label %for.cond268.preheader

for.cond268.preheader:                            ; preds = %if.then261, %if.end252254
  %c.code.1.ph = phi i16 [ %c.code.184, %if.end252254 ], [ %c.code.186, %if.then261 ]
  %.1279.ph = phi i32 [ %c.detail.197, %if.end252254 ], [ %c.detail.199, %if.then261 ]
  br label %for.cond268

for.cond268:                                      ; preds = %for.inc306, %for.cond268.preheader
  %c.code.1 = phi i16 [ %c.code.189, %for.inc306 ], [ %c.code.1.ph, %for.cond268.preheader ]
  %.1279 = phi i32 [ %c.detail.202, %for.inc306 ], [ %.1279.ph, %for.cond268.preheader ]
  %i = phi i32 [ %i.96, %for.inc306 ], [ 0, %for.cond268.preheader ]
  %icmp.ln9.206 = icmp eq i16 %c.code.1, 0
  %icmp.ln313 = icmp ult i32 %i, 2
  %and.ln313 = and i1 %icmp.ln9.206, %icmp.ln313
  br i1 %and.ln313, label %for.body272, label %for.end309

for.body272:                                      ; preds = %for.cond268
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @4)
  %zext.ln314 = zext i32 %i to i64
  %d.bo.addr.3 = getelementptr [2 x i8], [2 x i8]* %d.bo, i64 0, i64 %zext.ln314
  %d.bo.load.2 = load i8, i8* %d.bo.addr.3, align 1
  %icmp.ln314 = icmp eq i8 %d.bo.load.2, 5
  br i1 %icmp.ln314, label %lor.lhs.false278, label %if.then289

lor.lhs.false278:                                 ; preds = %for.body272
  %d.span.addr.3 = getelementptr [2 x i32], [2 x i32]* %d.span, i64 0, i64 %zext.ln314
  %d.span.load.2 = load i32, i32* %d.span.addr.3, align 4
  %icmp.ln314.2 = icmp eq i32 %d.span.load.2, 262400
  br i1 %icmp.ln314.2, label %lor.lhs.false283, label %if.then289

lor.lhs.false283:                                 ; preds = %lor.lhs.false278
  %d.ggml_type_id.addr.2 = getelementptr [2 x i8], [2 x i8]* %d.ggml_type_id, i64 0, i64 %zext.ln314
  %d.ggml_type_id.load.1 = load i8, i8* %d.ggml_type_id.addr.2, align 4
  %icmp.ln315 = icmp eq i8 %d.ggml_type_id.load.1, 0
  br i1 %icmp.ln315, label %if.else295, label %if.then289

if.then289:                                       ; preds = %lor.lhs.false283, %lor.lhs.false278, %for.body272
  br label %for.inc306

if.else295:                                       ; preds = %lor.lhs.false283
  %d.base.addr.3 = getelementptr [2 x i32], [2 x i32]* %d.base, i64 0, i64 %zext.ln314
  %d.base.load.2 = load i32, i32* %d.base.addr.3, align 4
  %offset.5 = zext i32 %d.base.load.2 to i64
  call void (...) @_ssdm_Assume(i1 true) #1
  call void (...) @_ssdm_Assume(i1 true) #1
  call void (...) @_ssdm_Assume(i1 true) #1
  %icmp.ln117.7 = icmp ugt i32 %d.base.load.2, 1671872
  %sub.ln117.2 = sub i64 1671872, %offset.5
  %icmp.ln117.8 = icmp ult i64 %sub.ln117.2, 262400
  %add.ln118.2 = add nuw nsw i64 %offset.5, 262400
  %icmp.ln118.2 = icmp ugt i64 %add.ln118.2, 4294967296
  %or.ln116.7 = or i1 %icmp.ln117.8, %icmp.ln117.7
  %or.ln116.8 = or i1 %or.ln116.7, %icmp.ln118.2
  %select.ln116 = select i1 %or.ln116.8, i16 5, i16 0
  %select.ln116.5 = select i1 %or.ln116.8, i32 67436553, i32 0
  br label %for.inc306

for.inc306:                                       ; preds = %if.else295, %if.then289
  %c.code.189 = phi i16 [ %select.ln116, %if.else295 ], [ 2, %if.then289 ]
  %c.detail.202 = phi i32 [ %select.ln116.5, %if.else295 ], [ 67108868, %if.then289 ]
  %i.96 = add i32 %i, 1
  br label %for.cond268, !llvm.loop !3917

for.end309:                                       ; preds = %for.cond268
  %icmp.ln9.i630.lcssa = phi i1 [ %icmp.ln9.206, %for.cond268 ]
  %.1279.lcssa = phi i32 [ %.1279, %for.cond268 ]
  %c.code.1.lcssa = phi i16 [ %c.code.1, %for.cond268 ]
  br i1 %icmp.ln9.i630.lcssa, label %if.end313, label %if.then311

if.then311:                                       ; preds = %for.end309
  %call.ret177 = call fastcc { i16, i32, i64, i32, i16, i32, i64, i32, i8 } @"laya::full::(anonymous namespace)::finish_load"(i32 %t.ctx.task_id.read, i8 %t.ctx.op.read, i32 524800, i16 %c.code.1.lcssa, i32 %.1279.lcssa, i64 -1)
  %newret339 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret177, 0
  %newret341 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret177, 1
  %newret343 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret177, 2
  %newret345 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret177, 3
  %newret347 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret177, 4
  %newret349 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret177, 5
  %newret351 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret177, 6
  %newret353 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret177, 7
  %newret355 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret177, 8
  br label %cleanup773

if.end313:                                        ; preds = %for.end309
  %"(anonymous namespace)::runtime.load.9" = load i8, i8* @"(anonymous namespace)::runtime.loaded_rope_ref.id", align 512
  %icmp.ln320 = icmp eq i8 %"(anonymous namespace)::runtime.load.9", 0
  br i1 %icmp.ln320, label %if.end339, label %arrayinit.body.i.i.preheader

arrayinit.body.i.i.preheader:                     ; preds = %if.end313
  br label %arrayinit.body.i.i

arrayinit.body.i.i:                               ; preds = %arrayinit.body.i.i, %arrayinit.body.i.i.preheader
  %arrayinit.curidx.i.i = phi i64 [ %add.ln14.12, %arrayinit.body.i.i ], [ 0, %arrayinit.body.i.i.preheader ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 16, i64 16, i64 16), !fpga.pragma.source !169
  %old.identity.model_tag.addr = getelementptr [16 x i8], [16 x i8]* %old.identity.model_tag, i64 0, i64 %arrayinit.curidx.i.i
  %add.ln14.12 = add nuw nsw i64 %arrayinit.curidx.i.i, 1
  store i8 0, i8* %old.identity.model_tag.addr, align 1, !alias.scope !3924, !noalias !3929
  %icmp.ln14.6 = icmp eq i64 %arrayinit.curidx.i.i, 15
  br i1 %icmp.ln14.6, label %arrayinit.body3.i.i.preheader, label %arrayinit.body.i.i, !llvm.loop !3965

arrayinit.body3.i.i.preheader:                    ; preds = %arrayinit.body.i.i
  br label %arrayinit.body3.i.i

arrayinit.body3.i.i:                              ; preds = %arrayinit.body3.i.i, %arrayinit.body3.i.i.preheader
  %arrayinit.curidx4.i.i = phi i64 [ %add.ln15.1, %arrayinit.body3.i.i ], [ 0, %arrayinit.body3.i.i.preheader ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 16, i64 16, i64 16), !fpga.pragma.source !169
  %old.identity.numeric_tag.addr = getelementptr [16 x i8], [16 x i8]* %old.identity.numeric_tag, i64 0, i64 %arrayinit.curidx4.i.i
  %add.ln15.1 = add nuw nsw i64 %arrayinit.curidx4.i.i, 1
  store i8 0, i8* %old.identity.numeric_tag.addr, align 1, !alias.scope !3966, !noalias !3967
  %icmp.ln15.1 = icmp eq i64 %arrayinit.curidx4.i.i, 15
  br i1 %icmp.ln15.1, label %arrayinit.body10.i.i.preheader, label %arrayinit.body3.i.i, !llvm.loop !3968

arrayinit.body10.i.i.preheader:                   ; preds = %arrayinit.body3.i.i
  br label %arrayinit.body10.i.i

arrayinit.body10.i.i:                             ; preds = %arrayinit.body10.i.i, %arrayinit.body10.i.i.preheader
  %arrayinit.curidx11.i.i = phi i64 [ %add.ln16.1, %arrayinit.body10.i.i ], [ 0, %arrayinit.body10.i.i.preheader ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 16, i64 16, i64 16), !fpga.pragma.source !169
  %old.identity.layout_tag.addr = getelementptr [16 x i8], [16 x i8]* %old.identity.layout_tag, i64 0, i64 %arrayinit.curidx11.i.i
  %add.ln16.1 = add nuw nsw i64 %arrayinit.curidx11.i.i, 1
  store i8 0, i8* %old.identity.layout_tag.addr, align 1, !alias.scope !3969, !noalias !3970
  %icmp.ln16.1 = icmp eq i64 %arrayinit.curidx11.i.i, 15
  br i1 %icmp.ln16.1, label %arrayinit.body17.i.i.preheader, label %arrayinit.body10.i.i, !llvm.loop !3971

arrayinit.body17.i.i.preheader:                   ; preds = %arrayinit.body10.i.i
  br label %arrayinit.body17.i.i

arrayinit.body17.i.i:                             ; preds = %arrayinit.body17.i.i, %arrayinit.body17.i.i.preheader
  %arrayinit.curidx18.i.i = phi i64 [ %add.ln17.1, %arrayinit.body17.i.i ], [ 0, %arrayinit.body17.i.i.preheader ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 16, i64 16, i64 16), !fpga.pragma.source !169
  %old.identity.build_tag.addr = getelementptr [16 x i8], [16 x i8]* %old.identity.build_tag, i64 0, i64 %arrayinit.curidx18.i.i
  %add.ln17.1 = add nuw nsw i64 %arrayinit.curidx18.i.i, 1
  store i8 0, i8* %old.identity.build_tag.addr, align 1, !alias.scope !3972, !noalias !3973
  %icmp.ln17.1 = icmp eq i64 %arrayinit.curidx18.i.i, 15
  br i1 %icmp.ln17.1, label %arrayinit.body.i248.preheader, label %arrayinit.body17.i.i, !llvm.loop !3974

arrayinit.body.i248.preheader:                    ; preds = %arrayinit.body17.i.i
  br label %arrayinit.body.i248

arrayinit.body.i248:                              ; preds = %arrayinit.body.i248, %arrayinit.body.i248.preheader
  %arrayinit.curidx.i244 = phi i64 [ %add.ln75.1, %arrayinit.body.i248 ], [ 0, %arrayinit.body.i248.preheader ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 64, i64 64, i64 64), !fpga.pragma.source !169
  %old.covered_rows.addr = getelementptr [64 x i32], [64 x i32]* %old.covered_rows, i64 0, i64 %arrayinit.curidx.i244
  %add.ln75.1 = add nuw nsw i64 %arrayinit.curidx.i244, 1
  store i32 0, i32* %old.covered_rows.addr, align 4, !alias.scope !3975, !noalias !3976
  %icmp.ln75.1 = icmp eq i64 %arrayinit.curidx.i244, 63
  br i1 %icmp.ln75.1, label %arrayinit.body3.i254.preheader, label %arrayinit.body.i248, !llvm.loop !3977

arrayinit.body3.i254.preheader:                   ; preds = %arrayinit.body.i248
  br label %arrayinit.body3.i254

arrayinit.body3.i254:                             ; preds = %arrayinit.body3.i254, %arrayinit.body3.i254.preheader
  %arrayinit.curidx4.i250 = phi i64 [ %add.ln76.1, %arrayinit.body3.i254 ], [ 0, %arrayinit.body3.i254.preheader ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 64, i64 64, i64 64), !fpga.pragma.source !169
  %old.old_consumed_rows.addr = getelementptr [64 x i32], [64 x i32]* %old.old_consumed_rows, i64 0, i64 %arrayinit.curidx4.i250
  %add.ln76.1 = add nuw nsw i64 %arrayinit.curidx4.i250, 1
  store i32 0, i32* %old.old_consumed_rows.addr, align 4, !alias.scope !3978, !noalias !3979
  %icmp.ln76.2 = icmp eq i64 %arrayinit.curidx4.i250, 63
  br i1 %icmp.ln76.2, label %_ZN4laya4full15FullOwnerRecordC2Ev.exit, label %arrayinit.body3.i254, !llvm.loop !3980

_ZN4laya4full15FullOwnerRecordC2Ev.exit:          ; preds = %arrayinit.body3.i254
  %"(anonymous namespace)::runtime.load.11" = load i8, i8* @"(anonymous namespace)::runtime.loaded_rope_ref.bank", align 512
  %"(anonymous namespace)::runtime.load.12" = load i32, i32* @"(anonymous namespace)::runtime.loaded_rope_ref.epoch", align 512
  %call.ret186 = call fastcc { i16, i32, i64, i64, i16, i16, i8, i8, i32, i8, i8, i32, i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i1 } @"laya::full::full_owner_snapshot"(i8 %"(anonymous namespace)::runtime.load.9", i8 %"(anonymous namespace)::runtime.load.11", i32 %"(anonymous namespace)::runtime.load.12", i8 0, [16 x i8]* %old.identity.model_tag, [16 x i8]* %old.identity.numeric_tag, [16 x i8]* %old.identity.layout_tag, [16 x i8]* %old.identity.build_tag, [64 x i32]* %old.covered_rows, [64 x i32]* %old.old_consumed_rows)
  %c.code.195 = extractvalue { i16, i32, i64, i64, i16, i16, i8, i8, i32, i8, i8, i32, i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i1 } %call.ret186, 0
  %old.ref.id = extractvalue { i16, i32, i64, i64, i16, i16, i8, i8, i32, i8, i8, i32, i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i1 } %call.ret186, 6
  %old.ref.bank = extractvalue { i16, i32, i64, i64, i16, i16, i8, i8, i32, i8, i8, i32, i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i1 } %call.ret186, 7
  %old.ref.epoch = extractvalue { i16, i32, i64, i64, i16, i16, i8, i8, i32, i8, i8, i32, i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i1 } %call.ret186, 8
  %old.max_claimed_epoch.1 = extractvalue { i16, i32, i64, i64, i16, i16, i8, i8, i32, i8, i8, i32, i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i1 } %call.ret186, 12
  %old.region = extractvalue { i16, i32, i64, i64, i16, i16, i8, i8, i32, i8, i8, i32, i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i1 } %call.ret186, 13
  %old.stage = extractvalue { i16, i32, i64, i64, i16, i16, i8, i8, i32, i8, i8, i32, i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i1 } %call.ret186, 14
  %old.layer = extractvalue { i16, i32, i64, i64, i16, i16, i8, i8, i32, i8, i8, i32, i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i1 } %call.ret186, 15
  %old.batch = extractvalue { i16, i32, i64, i64, i16, i16, i8, i8, i32, i8, i8, i32, i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i1 } %call.ret186, 16
  %old.row_space = extractvalue { i16, i32, i64, i64, i16, i16, i8, i8, i32, i8, i8, i32, i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i1 } %call.ret186, 17
  %old.row0 = extractvalue { i16, i32, i64, i64, i16, i16, i8, i8, i32, i8, i8, i32, i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i1 } %call.ret186, 18
  %old.rows = extractvalue { i16, i32, i64, i64, i16, i16, i8, i8, i32, i8, i8, i32, i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i1 } %call.ret186, 19
  %old.width = extractvalue { i16, i32, i64, i64, i16, i16, i8, i8, i32, i8, i8, i32, i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i1 } %call.ret186, 20
  %old.content = extractvalue { i16, i32, i64, i64, i16, i16, i8, i8, i32, i8, i8, i32, i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i1 } %call.ret186, 21
  %old.state.1 = extractvalue { i16, i32, i64, i64, i16, i16, i8, i8, i32, i8, i8, i32, i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i1 } %call.ret186, 22
  %old.valid.1 = extractvalue { i16, i32, i64, i64, i16, i16, i8, i8, i32, i8, i8, i32, i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i1 } %call.ret186, 23
  %icmp.ln9.213 = icmp eq i16 %c.code.195, 0
  br i1 %icmp.ln9.213, label %lor.lhs.false321, label %if.then328

lor.lhs.false321:                                 ; preds = %_ZN4laya4full15FullOwnerRecordC2Ev.exit
  %xor.ln323 = xor i1 %old.valid.1, true
  %icmp.ln323 = icmp ne i8 %old.state.1, 2
  %or.ln323 = or i1 %icmp.ln323, %xor.ln323
  br i1 %or.ln323, label %if.then328, label %lor.lhs.false324

lor.lhs.false324:                                 ; preds = %lor.lhs.false321
  %add.ln324 = add i32 %old.max_claimed_epoch.1, 1
  %icmp.ln324 = icmp eq i32 %add.ln324, %t_dst_epoch.val
  br i1 %icmp.ln324, label %if.end331, label %if.then328

if.then328:                                       ; preds = %lor.lhs.false324, %lor.lhs.false321, %_ZN4laya4full15FullOwnerRecordC2Ev.exit
  %call.ret193 = call fastcc { i16, i32, i64, i32, i16, i32, i64, i32, i8 } @"laya::full::(anonymous namespace)::finish_load"(i32 %t.ctx.task_id.read, i8 %t.ctx.op.read, i32 524800, i16 5, i32 69926916, i64 -1)
  %newret357 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret193, 0
  %newret359 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret193, 1
  %newret361 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret193, 2
  %newret363 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret193, 3
  %newret365 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret193, 4
  %newret367 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret193, 5
  %newret369 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret193, 6
  %newret371 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret193, 7
  %newret373 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret193, 8
  br label %cleanup773

if.end331:                                        ; preds = %lor.lhs.false324
  %call.ret192 = call fastcc { i16, i32 } @"laya::full::full_release_owner"(i8 %old.ref.id, i8 %old.ref.bank, i32 %old.ref.epoch, i8 %old.region, i8 %old.stage, i8 %old.layer, i8 %old.batch, i8 %old.row_space, i16 %old.row0, i16 %old.rows, i16 %old.width, i8 %old.content)
  %c.code.199 = extractvalue { i16, i32 } %call.ret192, 0
  %c.detail.210 = extractvalue { i16, i32 } %call.ret192, 1
  %icmp.ln9.218 = icmp eq i16 %c.code.199, 0
  br i1 %icmp.ln9.218, label %if.end339, label %if.then335

if.then335:                                       ; preds = %if.end331
  %call.ret195 = call fastcc { i16, i32, i64, i32, i16, i32, i64, i32, i8 } @"laya::full::(anonymous namespace)::finish_load"(i32 %t.ctx.task_id.read, i8 %t.ctx.op.read, i32 524800, i16 %c.code.199, i32 %c.detail.210, i64 -1)
  %newret375 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret195, 0
  %newret377 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret195, 1
  %newret379 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret195, 2
  %newret381 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret195, 3
  %newret383 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret195, 4
  %newret385 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret195, 5
  %newret387 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret195, 6
  %newret389 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret195, 7
  %newret391 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret195, 8
  br label %cleanup773

if.end339:                                        ; preds = %if.end331, %if.end313
  %call.ret194 = call fastcc { i16, i32 } @"laya::full::full_claim_owner"(i8 43, i8 %t_dst_bank.val, i32 %t_dst_epoch.val, i8 0, i8 2, i8 %t_ctx_layer.val, i8 0, i8 2, i16 0, i16 1, i16 64, i8 1)
  %c.code.200 = extractvalue { i16, i32 } %call.ret194, 0
  %c.detail.211 = extractvalue { i16, i32 } %call.ret194, 1
  %icmp.ln9.219 = icmp eq i16 %c.code.200, 0
  br i1 %icmp.ln9.219, label %VITIS_LOOP_335_3, label %if.then356

if.then356:                                       ; preds = %if.end339
  %call.ret196 = call fastcc { i16, i32, i64, i32, i16, i32, i64, i32, i8 } @"laya::full::(anonymous namespace)::finish_load"(i32 %t.ctx.task_id.read, i8 %t.ctx.op.read, i32 524800, i16 %c.code.200, i32 %c.detail.211, i64 -1)
  %newret393 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret196, 0
  %newret395 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret196, 1
  %newret397 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret196, 2
  %newret399 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret196, 3
  %newret401 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret196, 4
  %newret403 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret196, 5
  %newret405 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret196, 6
  %newret407 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret196, 7
  %newret409 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret196, 8
  br label %cleanup773

VITIS_LOOP_335_3:                                 ; preds = %if.end339
  %raw.addr = getelementptr inbounds [4 x i8], [4 x i8]* %raw, i64 0, i64 0
  %raw.addr.33 = getelementptr inbounds [4 x i8], [4 x i8]* %raw, i64 0, i64 1
  %raw.addr.34 = getelementptr inbounds [4 x i8], [4 x i8]* %raw, i64 0, i64 2
  %raw.addr.35 = getelementptr inbounds [4 x i8], [4 x i8]* %raw, i64 0, i64 3
  br label %for.cond359

for.cond359:                                      ; preds = %for.inc403, %VITIS_LOOP_335_3
  %c.code.2 = phi i16 [ 0, %VITIS_LOOP_335_3 ], [ %c.code.3.lcssa, %for.inc403 ]
  %table = phi i64 [ 0, %VITIS_LOOP_335_3 ], [ %add.ln335, %for.inc403 ]
  %.1204127 = phi i32 [ %c.detail.211, %VITIS_LOOP_335_3 ], [ %.1204128.lcssa, %for.inc403 ]
  %.0202123 = phi i16 [ 0, %VITIS_LOOP_335_3 ], [ %.0202124.lcssa, %for.inc403 ]
  %icmp.ln335 = icmp ult i64 %table, 2
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 1, i64 2, i64 1)
  br i1 %icmp.ln335, label %land.rhs361, label %for.end406

land.rhs361:                                      ; preds = %for.cond359
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @5)
  %icmp.ln9.221 = icmp eq i16 %c.code.2, 0
  br i1 %icmp.ln9.221, label %VITIS_LOOP_336_4, label %for.end406

VITIS_LOOP_336_4:                                 ; preds = %land.rhs361
  %d.base.addr.4 = getelementptr [2 x i32], [2 x i32]* %d.base, i64 0, i64 %table
  %d.base.load.3 = load i32, i32* %d.base.addr.4, align 4
  br label %for.cond366

for.cond366:                                      ; preds = %for.inc399, %VITIS_LOOP_336_4
  %c.code.3 = phi i16 [ 0, %VITIS_LOOP_336_4 ], [ %c.code.207.lcssa, %for.inc399 ]
  %pos = phi i64 [ 0, %VITIS_LOOP_336_4 ], [ %add.ln336, %for.inc399 ]
  %.1204128 = phi i32 [ %.1204127, %VITIS_LOOP_336_4 ], [ %c.detail.218.lcssa, %for.inc399 ]
  %.0202124 = phi i16 [ %.0202123, %VITIS_LOOP_336_4 ], [ %c.code.207.lcssa, %for.inc399 ]
  %icmp.ln336 = icmp ult i64 %pos, 1025
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 1, i64 1025, i64 513)
  br i1 %icmp.ln336, label %land.rhs368, label %for.inc403

land.rhs368:                                      ; preds = %for.cond366
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @30)
  %icmp.ln9.227 = icmp eq i16 %c.code.3, 0
  br i1 %icmp.ln9.227, label %VITIS_LOOP_337_5, label %for.inc403

VITIS_LOOP_337_5:                                 ; preds = %land.rhs368
  %trunc.ln338 = trunc i64 %pos to i30
  %shl.ln338 = shl i30 %trunc.ln338, 6
  br label %for.body376

for.body376:                                      ; preds = %_ZN4laya4full12_GLOBAL__N_112read_aux_f32ERKNS0_11FullRuntimeERKNS0_10FullMemoryEjNS_2OpERf.2878.3063.3288.3513.3738.3963.4188.4413.4638.4863.5088.5313.5538.5763.exit289, %VITIS_LOOP_337_5
  %j = phi i64 [ 0, %VITIS_LOOP_337_5 ], [ %add.ln337, %_ZN4laya4full12_GLOBAL__N_112read_aux_f32ERKNS0_11FullRuntimeERKNS0_10FullMemoryEjNS_2OpERf.2878.3063.3288.3513.3738.3963.4188.4413.4638.4863.5088.5313.5538.5763.exit289 ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 0, i64 64, i64 32), !fpga.pragma.source !169
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @0)
  %trunc.ln338.1 = trunc i64 %j to i30
  %add.ln338 = add i30 %trunc.ln338.1, %shl.ln338
  %zext.ln338 = zext i30 %add.ln338 to i32
  %shl.ln338.1 = shl nuw i32 %zext.ln338, 2
  %offset.6 = add i32 %shl.ln338.1, %d.base.load.3
  %zext.ln196.1 = zext i32 %offset.6 to i64
  %call.ret201 = call fastcc { i16, i32 } @"laya::full::full_read"(i8 addrspace(1)* %embedding, i64 %memory_embedding, i8 addrspace(1)* %io, i64 %memory_io, i8 addrspace(1)* %w_q0, i64 %memory_w_q0, i8 addrspace(1)* %w_q1, i64 %memory_w_q1, i8 addrspace(1)* %w_scale, i64 %memory_w_scale, i8 addrspace(1)* %aux, i64 %memory_aux, i8 addrspace(1)* %state0, i64 %memory_state0, i8 addrspace(1)* %state1, i64 %memory_state1, i8 addrspace(1)* %qkv0, i64 %memory_qkv0, i8 addrspace(1)* %qkv1, i64 %memory_qkv1, i8 addrspace(1)* %ff0, i64 %memory_ff0, i8 addrspace(1)* %ff1, i64 %memory_ff1, i8 addrspace(1)* %att_out, i64 %memory_att_out, i8 5, i64 %zext.ln196.1, [4 x i8]* %raw)
  %c.code.204 = extractvalue { i16, i32 } %call.ret201, 0
  %c.detail.215 = extractvalue { i16, i32 } %call.ret201, 1
  %icmp.ln9.197 = icmp eq i16 %c.code.204, 0
  br i1 %icmp.ln9.197, label %if.end.i285, label %_ZN4laya4full12_GLOBAL__N_112read_aux_f32ERKNS0_11FullRuntimeERKNS0_10FullMemoryEjNS_2OpERf.2878.3063.3288.3513.3738.3963.4188.4413.4638.4863.5088.5313.5538.5763.exit289

if.end.i285:                                      ; preds = %for.body376
  %raw.load = load i8, i8* %raw.addr, align 512, !noalias !3981
  %raw.load.11 = load i8, i8* %raw.addr.33, align 1, !noalias !3981
  %raw.load.12 = load i8, i8* %raw.addr.34, align 2, !noalias !3981
  %raw.load.13 = load i8, i8* %raw.addr.35, align 1, !noalias !3981
  %bits.2 = call i32 @_ssdm_op_BitConcatenate.i32.i8.i8.i8.i8(i8 %raw.load.13, i8 %raw.load.12, i8 %raw.load.11, i8 %raw.load)
  %and.ln200.1 = and i32 %bits.2, 2139095040
  %icmp.ln200.1 = icmp eq i32 %and.ln200.1, 2139095040
  %select.ln200 = select i1 %icmp.ln200.1, i16 6, i16 0
  %select.ln200.1 = select i1 %icmp.ln200.1, i32 126025743, i32 0
  br label %_ZN4laya4full12_GLOBAL__N_112read_aux_f32ERKNS0_11FullRuntimeERKNS0_10FullMemoryEjNS_2OpERf.2878.3063.3288.3513.3738.3963.4188.4413.4638.4863.5088.5313.5538.5763.exit289

_ZN4laya4full12_GLOBAL__N_112read_aux_f32ERKNS0_11FullRuntimeERKNS0_10FullMemoryEjNS_2OpERf.2878.3063.3288.3513.3738.3963.4188.4413.4638.4863.5088.5313.5538.5763.exit289: ; preds = %if.end.i285, %for.body376
  %c.code.207 = phi i16 [ %c.code.204, %for.body376 ], [ %select.ln200, %if.end.i285 ]
  %c.detail.218 = phi i32 [ %c.detail.215, %for.body376 ], [ %select.ln200.1, %if.end.i285 ]
  %icmp.ln9.232 = icmp eq i16 %c.code.207, 0
  %add.ln337 = add nuw nsw i64 %j, 1
  %icmp.ln337 = icmp ult i64 %add.ln337, 64
  %and.ln341 = and i1 %icmp.ln9.232, %icmp.ln337
  br i1 %and.ln341, label %for.body376, label %for.inc399, !llvm.loop !4013

for.inc399:                                       ; preds = %_ZN4laya4full12_GLOBAL__N_112read_aux_f32ERKNS0_11FullRuntimeERKNS0_10FullMemoryEjNS_2OpERf.2878.3063.3288.3513.3738.3963.4188.4413.4638.4863.5088.5313.5538.5763.exit289
  %c.detail.218.lcssa = phi i32 [ %c.detail.218, %_ZN4laya4full12_GLOBAL__N_112read_aux_f32ERKNS0_11FullRuntimeERKNS0_10FullMemoryEjNS_2OpERf.2878.3063.3288.3513.3738.3963.4188.4413.4638.4863.5088.5313.5538.5763.exit289 ]
  %c.code.207.lcssa = phi i16 [ %c.code.207, %_ZN4laya4full12_GLOBAL__N_112read_aux_f32ERKNS0_11FullRuntimeERKNS0_10FullMemoryEjNS_2OpERf.2878.3063.3288.3513.3738.3963.4188.4413.4638.4863.5088.5313.5538.5763.exit289 ]
  %add.ln336 = add nuw nsw i64 %pos, 1
  br label %for.cond366, !llvm.loop !4022

for.inc403:                                       ; preds = %land.rhs368, %for.cond366
  %.0202124.lcssa = phi i16 [ %.0202124, %land.rhs368 ], [ %.0202124, %for.cond366 ]
  %.1204128.lcssa = phi i32 [ %.1204128, %land.rhs368 ], [ %.1204128, %for.cond366 ]
  %c.code.3.lcssa = phi i16 [ %c.code.3, %land.rhs368 ], [ %c.code.3, %for.cond366 ]
  %add.ln335 = add nuw nsw i64 %table, 1
  br label %for.cond359, !llvm.loop !4026

for.end406:                                       ; preds = %land.rhs361, %for.cond359
  %.0202123.lcssa = phi i16 [ %.0202123, %land.rhs361 ], [ %.0202123, %for.cond359 ]
  %.1204127.lcssa = phi i32 [ %.1204127, %land.rhs361 ], [ %.1204127, %for.cond359 ]
  %c.code.2.lcssa = phi i16 [ %c.code.2, %land.rhs361 ], [ %c.code.2, %for.cond359 ]
  %icmp.ln9.222 = icmp eq i16 %c.code.2.lcssa, 0
  br i1 %icmp.ln9.222, label %if.then408, label %if.end410

if.then408:                                       ; preds = %for.end406
  %call.ret197 = call fastcc { i16, i32 } @"laya::full::full_cover_owner"(i8 43, i8 %t_dst_bank.val, i32 %t_dst_epoch.val, i8 0, i8 2, i8 %t_ctx_layer.val, i8 0, i8 2, i16 0, i16 1, i16 64, i8 1, i8 0, i16 0, i16 1)
  %c.code.201 = extractvalue { i16, i32 } %call.ret197, 0
  %c.detail.212 = extractvalue { i16, i32 } %call.ret197, 1
  br label %if.end410

if.end410:                                        ; preds = %if.then408, %for.end406
  %c.code.val66 = phi i16 [ %c.code.201, %if.then408 ], [ %c.code.2.lcssa, %for.end406 ]
  %.1204126 = phi i32 [ %c.detail.212, %if.then408 ], [ %.1204127.lcssa, %for.end406 ]
  %.0202122 = phi i16 [ %c.code.201, %if.then408 ], [ %.0202123.lcssa, %for.end406 ]
  %icmp.ln9.224 = icmp eq i16 %c.code.val66, 0
  br i1 %icmp.ln9.224, label %if.then412, label %if.end414

if.then412:                                       ; preds = %if.end410
  %call.ret198 = call fastcc { i16, i32 } @"laya::full::full_publish_owner"(i8 43, i8 %t_dst_bank.val, i32 %t_dst_epoch.val, i8 0, i8 2, i8 %t_ctx_layer.val, i8 0, i8 2, i16 0, i16 1, i16 64, i8 1)
  %c.code.202 = extractvalue { i16, i32 } %call.ret198, 0
  %c.detail.213 = extractvalue { i16, i32 } %call.ret198, 1
  br label %if.end414

if.end414:                                        ; preds = %if.then412, %if.end410
  %c.code.val67 = phi i16 [ %c.code.202, %if.then412 ], [ %c.code.val66, %if.end410 ]
  %.1204 = phi i32 [ %c.detail.213, %if.then412 ], [ %.1204126, %if.end410 ]
  %.0202 = phi i16 [ %c.code.202, %if.then412 ], [ %.0202122, %if.end410 ]
  %icmp.ln9.226 = icmp eq i16 %c.code.val67, 0
  br i1 %icmp.ln9.226, label %if.end426, label %if.then416

if.then416:                                       ; preds = %if.end414
  %2 = call fastcc i16 @"laya::full::full_invalidate_owner"(i8 43, i8 %t_dst_bank.val, i32 %t_dst_epoch.val, i8 0)
  br label %if.end426

if.end426:                                        ; preds = %if.then416, %if.end414
  %storemerge5 = phi i8 [ 0, %if.then416 ], [ 43, %if.end414 ]
  %storemerge2 = phi i8 [ 0, %if.then416 ], [ %t_dst_bank.val, %if.end414 ]
  %storemerge1 = phi i32 [ 0, %if.then416 ], [ %t_dst_epoch.val, %if.end414 ]
  store i8 %storemerge5, i8* @"(anonymous namespace)::runtime.loaded_rope_ref.id", align 512
  store i8 %storemerge2, i8* @"(anonymous namespace)::runtime.loaded_rope_ref.bank", align 512
  store i32 %storemerge1, i32* @"(anonymous namespace)::runtime.loaded_rope_ref.epoch", align 512
  %call.ret199 = call fastcc { i16, i32, i64, i32, i16, i32, i64, i32, i8 } @"laya::full::(anonymous namespace)::finish_load"(i32 %t.ctx.task_id.read, i8 %t.ctx.op.read, i32 524800, i16 %.0202, i32 %.1204, i64 -1)
  %newret411 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret199, 0
  %newret413 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret199, 1
  %newret415 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret199, 2
  %newret417 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret199, 3
  %newret419 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret199, 4
  %newret421 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret199, 5
  %newret423 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret199, 6
  %newret425 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret199, 7
  %newret427 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret199, 8
  br label %cleanup773

if.end431:                                        ; preds = %if.end92
  switch i8 %t_ctx_stage.val, label %if.then482 [
    i8 4, label %lor.lhs.false441
    i8 2, label %lor.lhs.false441
  ]

lor.lhs.false441:                                 ; preds = %if.end431, %if.end431
  %icmp.ln355 = icmp ne i8 %t_dst_id.val, 37
  %icmp.ln355.1 = icmp ne i8 %t_dst_bank.val, 0
  %or.ln355 = or i1 %icmp.ln355, %icmp.ln355.1
  br i1 %or.ln355, label %if.then482, label %lor.lhs.false450

lor.lhs.false450:                                 ; preds = %lor.lhs.false441
  %icmp.ln356 = icmp ugt i8 %t_head.val, 15
  %icmp.ln356.1 = icmp ne i8 %t_planes.val, 3
  %or.ln356 = or i1 %icmp.ln356, %icmp.ln356.1
  br i1 %or.ln356, label %if.then482, label %lor.lhs.false458

lor.lhs.false458:                                 ; preds = %lor.lhs.false450
  %"(anonymous namespace)::runtime.inputs.identity.B.load.5" = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.B", align 512
  %zext.ln358.1 = zext i16 %"(anonymous namespace)::runtime.inputs.identity.B.load.5" to i23
  %"(anonymous namespace)::runtime.inputs.identity.S.load.12" = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.S", align 512
  %zext.ln358 = zext i16 %"(anonymous namespace)::runtime.inputs.identity.S.load.12" to i23
  %mul.ln358 = mul i23 %zext.ln358.1, %zext.ln358
  %zext.ln358.2 = zext i23 %mul.ln358 to i32
  %shl.ln358 = shl nuw i32 %zext.ln358.2, 9
  %icmp.ln357 = icmp ne i32 %shl.ln358, %t.byte_count.read
  %"(anonymous namespace)::runtime.final_qkv_ref.id.load" = load i8, i8* getelementptr inbounds ([2 x i8], [2 x i8]* @"(anonymous namespace)::runtime.final_qkv_ref.id", i64 0, i64 0), align 512
  %icmp.ln359 = icmp ne i8 %"(anonymous namespace)::runtime.final_qkv_ref.id.load", 5
  %or.ln358 = or i1 %icmp.ln357, %icmp.ln359
  %"(anonymous namespace)::runtime.final_qkv_ref.id.load.1" = load i8, i8* getelementptr inbounds ([2 x i8], [2 x i8]* @"(anonymous namespace)::runtime.final_qkv_ref.id", i64 0, i64 1), align 8
  %icmp.ln360 = icmp ne i8 %"(anonymous namespace)::runtime.final_qkv_ref.id.load.1", 5
  %or.ln358.1 = or i1 %or.ln358, %icmp.ln360
  br i1 %or.ln358.1, label %if.then482, label %if.end485

if.then482:                                       ; preds = %lor.lhs.false458, %lor.lhs.false450, %lor.lhs.false441, %if.end431
  %call.ret167 = call fastcc { i16, i32, i64, i32, i16, i32, i64, i32, i8 } @"laya::full::(anonymous namespace)::finish_load"(i32 %t.ctx.task_id.read, i8 %t.ctx.op.read, i32 %t.byte_count.read, i16 5, i32 69533701, i64 -1)
  %newret310 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret167, 0
  %newret312 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret167, 1
  %newret314 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret167, 2
  %newret316 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret167, 3
  %newret318 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret167, 4
  %newret320 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret167, 5
  %newret321 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret167, 6
  %newret322 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret167, 7
  %newret323 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret167, 8
  br label %cleanup773

if.end485:                                        ; preds = %lor.lhs.false458
  %"(anonymous namespace)::runtime.score_valid.load" = load i1, i1* @"(anonymous namespace)::runtime.score_valid", align 512
  br i1 %"(anonymous namespace)::runtime.score_valid.load", label %if.then486, label %if.end489

if.then486:                                       ; preds = %if.end485
  %call.ret168 = call fastcc { i16, i32, i64, i32, i16, i32, i64, i32, i8 } @"laya::full::(anonymous namespace)::finish_load"(i32 %t.ctx.task_id.read, i8 %t.ctx.op.read, i32 %t.byte_count.read, i16 5, i32 69599236, i64 -1)
  %newret324 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret168, 0
  %newret325 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret168, 1
  %newret326 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret168, 2
  %newret327 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret168, 3
  %newret328 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret168, 4
  %newret329 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret168, 5
  %newret330 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret168, 6
  %newret331 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret168, 7
  %newret332 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret168, 8
  br label %cleanup773

if.end489:                                        ; preds = %if.end485
  %qkv.ref.id.addr = getelementptr [2 x i8], [2 x i8]* %qkv.ref.id, i64 0, i64 0
  %qkv.stage.addr = getelementptr [2 x i8], [2 x i8]* %qkv.stage, i64 0, i64 0
  %qkv.batch.addr = getelementptr [2 x i8], [2 x i8]* %qkv.batch, i64 0, i64 0
  br label %arrayctor.loop493

arrayctor.loop493:                                ; preds = %arrayctor.loop493, %if.end489
  %indvars.iv156 = phi i64 [ %add.ln368, %arrayctor.loop493 ], [ 0, %if.end489 ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 2, i64 2, i64 2), !fpga.pragma.source !169
  %add.ln368 = add nuw nsw i64 %indvars.iv156, 1
  %this.ref.id = getelementptr [2 x i8], [2 x i8]* %qkv.ref.id, i64 0, i64 %indvars.iv156
  %this.ref.bank = getelementptr [2 x i8], [2 x i8]* %qkv.ref.bank, i64 0, i64 %indvars.iv156
  %this.ref.epoch = getelementptr [2 x i32], [2 x i32]* %qkv.ref.epoch, i64 0, i64 %indvars.iv156
  %this.region = getelementptr [2 x i8], [2 x i8]* %qkv.region, i64 0, i64 %indvars.iv156
  %this.stage = getelementptr [2 x i8], [2 x i8]* %qkv.stage, i64 0, i64 %indvars.iv156
  %this.layer = getelementptr [2 x i8], [2 x i8]* %qkv.layer, i64 0, i64 %indvars.iv156
  %this.batch = getelementptr [2 x i8], [2 x i8]* %qkv.batch, i64 0, i64 %indvars.iv156
  %this.row_space = getelementptr [2 x i8], [2 x i8]* %qkv.row_space, i64 0, i64 %indvars.iv156
  %this.row0 = getelementptr [2 x i16], [2 x i16]* %qkv.row0, i64 0, i64 %indvars.iv156
  %this.rows = getelementptr [2 x i16], [2 x i16]* %qkv.rows, i64 0, i64 %indvars.iv156
  %this.width = getelementptr [2 x i16], [2 x i16]* %qkv.width, i64 0, i64 %indvars.iv156
  %this.content = getelementptr [2 x i8], [2 x i8]* %qkv.content, i64 0, i64 %indvars.iv156
  store i8 0, i8* %this.ref.id, align 4, !alias.scope !4030, !noalias !4035
  store i8 0, i8* %this.ref.bank, align 1, !alias.scope !4049, !noalias !4050
  store i32 0, i32* %this.ref.epoch, align 4, !alias.scope !4051, !noalias !4052
  store i8 0, i8* %this.region, align 4, !alias.scope !4053, !noalias !4054
  store i8 0, i8* %this.stage, align 1, !alias.scope !4055, !noalias !4056
  store i8 -1, i8* %this.layer, align 2, !alias.scope !4057, !noalias !4058
  store i8 -1, i8* %this.batch, align 1, !alias.scope !4059, !noalias !4060
  store i8 0, i8* %this.row_space, align 4, !alias.scope !4061, !noalias !4062
  store i16 0, i16* %this.row0, align 2, !alias.scope !4063, !noalias !4064
  store i16 0, i16* %this.rows, align 4, !alias.scope !4065, !noalias !4066
  store i16 0, i16* %this.width, align 2, !alias.scope !4067, !noalias !4068
  store i8 0, i8* %this.content, align 4, !alias.scope !4069, !noalias !4070
  %icmp.ln368 = icmp eq i64 %indvars.iv156, 1
  br i1 %icmp.ln368, label %VITIS_LOOP_369_6, label %arrayctor.loop493, !llvm.loop !4071

VITIS_LOOP_369_6:                                 ; preds = %arrayctor.loop493
  %qkv.ref.bank.addr = getelementptr [2 x i8], [2 x i8]* %qkv.ref.bank, i64 0, i64 0
  %qkv.region.addr = getelementptr [2 x i8], [2 x i8]* %qkv.region, i64 0, i64 0
  %qkv.layer.addr = getelementptr [2 x i8], [2 x i8]* %qkv.layer, i64 0, i64 0
  %qkv.row_space.addr = getelementptr [2 x i8], [2 x i8]* %qkv.row_space, i64 0, i64 0
  %qkv.content.addr = getelementptr [2 x i8], [2 x i8]* %qkv.content, i64 0, i64 0
  br label %for.inc524

for.inc524:                                       ; preds = %for.inc524.split, %VITIS_LOOP_369_6
  %shard = phi i64 [ 0, %VITIS_LOOP_369_6 ], [ %add.ln369, %for.inc524.split ]
  %icmp.ln369 = icmp eq i64 %shard, 2
  br i1 %icmp.ln369, label %for.cond529.preheader, label %for.inc524.split, !llvm.loop !4072

for.cond529.preheader:                            ; preds = %for.inc524
  %"(anonymous namespace)::runtime.inputs.identity.B.load.6" = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.B", align 512
  %zext.ln374 = zext i16 %"(anonymous namespace)::runtime.inputs.identity.B.load.6" to i32
  %"(anonymous namespace)::runtime.inputs.identity.S.load.13" = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.S", align 512
  br label %for.cond529

for.inc524.split:                                 ; preds = %for.inc524
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 2, i64 2, i64 2), !fpga.pragma.source !169
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @29)
  %"(anonymous namespace)::runtime.final_qkv_ref.id.addr" = getelementptr [2 x i8], [2 x i8]* @"(anonymous namespace)::runtime.final_qkv_ref.id", i64 0, i64 %shard
  %"(anonymous namespace)::runtime.final_qkv_ref.id.load.2" = load i8, i8* %"(anonymous namespace)::runtime.final_qkv_ref.id.addr", align 8
  %"(anonymous namespace)::runtime.final_qkv_ref.bank.addr" = getelementptr [2 x i8], [2 x i8]* @"(anonymous namespace)::runtime.final_qkv_ref.bank", i64 0, i64 %shard
  %"(anonymous namespace)::runtime.final_qkv_ref.bank.load" = load i8, i8* %"(anonymous namespace)::runtime.final_qkv_ref.bank.addr", align 1
  %"(anonymous namespace)::runtime.final_qkv_ref.epoch.addr" = getelementptr [2 x i32], [2 x i32]* @"(anonymous namespace)::runtime.final_qkv_ref.epoch", i64 0, i64 %shard
  %"(anonymous namespace)::runtime.final_qkv_ref.epoch.load" = load i32, i32* %"(anonymous namespace)::runtime.final_qkv_ref.epoch.addr", align 4
  %qkv.ref.id.addr.5 = getelementptr [2 x i8], [2 x i8]* %qkv.ref.id, i64 0, i64 %shard
  %qkv.ref.bank.addr.4 = getelementptr [2 x i8], [2 x i8]* %qkv.ref.bank, i64 0, i64 %shard
  %qkv.ref.epoch.addr = getelementptr [2 x i32], [2 x i32]* %qkv.ref.epoch, i64 0, i64 %shard
  %qkv.region.addr.4 = getelementptr [2 x i8], [2 x i8]* %qkv.region, i64 0, i64 %shard
  %qkv.stage.addr.5 = getelementptr [2 x i8], [2 x i8]* %qkv.stage, i64 0, i64 %shard
  %qkv.layer.addr.4 = getelementptr [2 x i8], [2 x i8]* %qkv.layer, i64 0, i64 %shard
  %qkv.batch.addr.5 = getelementptr [2 x i8], [2 x i8]* %qkv.batch, i64 0, i64 %shard
  %qkv.row_space.addr.4 = getelementptr [2 x i8], [2 x i8]* %qkv.row_space, i64 0, i64 %shard
  %qkv.row0.addr = getelementptr [2 x i16], [2 x i16]* %qkv.row0, i64 0, i64 %shard
  %qkv.rows.addr = getelementptr [2 x i16], [2 x i16]* %qkv.rows, i64 0, i64 %shard
  %qkv.width.addr = getelementptr [2 x i16], [2 x i16]* %qkv.width, i64 0, i64 %shard
  %qkv.content.addr.4 = getelementptr [2 x i8], [2 x i8]* %qkv.content, i64 0, i64 %shard
  store i8 %"(anonymous namespace)::runtime.final_qkv_ref.id.load.2", i8* %qkv.ref.id.addr.5, align 1
  store i8 %"(anonymous namespace)::runtime.final_qkv_ref.bank.load", i8* %qkv.ref.bank.addr.4, align 1
  store i32 %"(anonymous namespace)::runtime.final_qkv_ref.epoch.load", i32* %qkv.ref.epoch.addr, align 4
  store i8 0, i8* %qkv.region.addr.4, align 1
  store i8 %t_ctx_stage.val, i8* %qkv.stage.addr.5, align 1
  store i8 %t_ctx_layer.val, i8* %qkv.layer.addr.4, align 1
  store i8 -1, i8* %qkv.batch.addr.5, align 1
  store i8 0, i8* %qkv.row_space.addr.4, align 1
  store i16 0, i16* %qkv.row0.addr, align 2
  store i16 %"(anonymous namespace)::runtime.inputs.identity.S.load.12", i16* %qkv.rows.addr, align 2
  store i16 64, i16* %qkv.width.addr, align 2
  store i8 3, i8* %qkv.content.addr.4, align 1
  %add.ln369 = add nuw nsw i64 %shard, 1
  br label %for.inc524, !llvm.loop !4072

for.cond529:                                      ; preds = %for.inc558, %for.cond529.preheader
  %c.detail.2 = phi i32 [ %c.detail.3.lcssa, %for.inc558 ], [ %c.detail.0, %for.cond529.preheader ]
  %c.code.4 = phi i16 [ %c.code.5.lcssa, %for.inc558 ], [ 0, %for.cond529.preheader ]
  %shard.2 = phi i64 [ %add.ln373, %for.inc558 ], [ 0, %for.cond529.preheader ]
  %icmp.ln373 = icmp ult i64 %shard.2, 2
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 1, i64 2, i64 1)
  br i1 %icmp.ln373, label %land.rhs531, label %for.end561

land.rhs531:                                      ; preds = %for.cond529
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @23)
  %icmp.ln9.201 = icmp eq i16 %c.code.4, 0
  br i1 %icmp.ln9.201, label %VITIS_LOOP_374_8, label %for.end561

VITIS_LOOP_374_8:                                 ; preds = %land.rhs531
  %qkv.ref.id.addr.6 = getelementptr [2 x i8], [2 x i8]* %qkv.ref.id, i64 0, i64 %shard.2
  %qkv.ref.bank.addr.5 = getelementptr [2 x i8], [2 x i8]* %qkv.ref.bank, i64 0, i64 %shard.2
  %qkv.ref.epoch.addr.4 = getelementptr [2 x i32], [2 x i32]* %qkv.ref.epoch, i64 0, i64 %shard.2
  %qkv.region.addr.5 = getelementptr [2 x i8], [2 x i8]* %qkv.region, i64 0, i64 %shard.2
  %qkv.stage.addr.6 = getelementptr [2 x i8], [2 x i8]* %qkv.stage, i64 0, i64 %shard.2
  %qkv.layer.addr.5 = getelementptr [2 x i8], [2 x i8]* %qkv.layer, i64 0, i64 %shard.2
  %qkv.batch.addr.6 = getelementptr [2 x i8], [2 x i8]* %qkv.batch, i64 0, i64 %shard.2
  %qkv.row_space.addr.5 = getelementptr [2 x i8], [2 x i8]* %qkv.row_space, i64 0, i64 %shard.2
  %qkv.row0.addr.4 = getelementptr [2 x i16], [2 x i16]* %qkv.row0, i64 0, i64 %shard.2
  %qkv.rows.addr.4 = getelementptr [2 x i16], [2 x i16]* %qkv.rows, i64 0, i64 %shard.2
  %qkv.width.addr.4 = getelementptr [2 x i16], [2 x i16]* %qkv.width, i64 0, i64 %shard.2
  %qkv.content.addr.5 = getelementptr [2 x i8], [2 x i8]* %qkv.content, i64 0, i64 %shard.2
  %qkv.ref.id.load.3 = load i8, i8* %qkv.ref.id.addr.6, align 1
  %qkv.ref.bank.load.3 = load i8, i8* %qkv.ref.bank.addr.5, align 1
  %qkv.ref.epoch.load = load i32, i32* %qkv.ref.epoch.addr.4, align 4
  %qkv.region.load.3 = load i8, i8* %qkv.region.addr.5, align 1
  %qkv.layer.load = load i8, i8* %qkv.layer.addr.5, align 1
  %qkv.content.load = load i8, i8* %qkv.content.addr.5, align 1
  %qkv.stage.load = load i8, i8* %qkv.stage.addr.6, align 1
  %qkv.batch.load = load i8, i8* %qkv.batch.addr.6, align 1
  %qkv.row_space.load = load i8, i8* %qkv.row_space.addr.5, align 1
  %qkv.row0.load = load i16, i16* %qkv.row0.addr.4, align 2
  %qkv.rows.load = load i16, i16* %qkv.rows.addr.4, align 2
  %qkv.width.load = load i16, i16* %qkv.width.addr.4, align 2
  br label %for.cond536

for.cond536:                                      ; preds = %for.inc554, %VITIS_LOOP_374_8
  %c.detail.3 = phi i32 [ %c.detail.2, %VITIS_LOOP_374_8 ], [ %c.detail.201, %for.inc554 ]
  %c.code.5 = phi i16 [ 0, %VITIS_LOOP_374_8 ], [ %c.code.188, %for.inc554 ]
  %b = phi i32 [ 0, %VITIS_LOOP_374_8 ], [ %b.3, %for.inc554 ]
  %icmp.ln374 = icmp ult i32 %b, %zext.ln374
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 0, i64 65535, i64 0)
  br i1 %icmp.ln374, label %land.rhs542, label %for.inc558

land.rhs542:                                      ; preds = %for.cond536
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @18)
  %icmp.ln9.207 = icmp eq i16 %c.code.5, 0
  br i1 %icmp.ln9.207, label %for.inc554, label %for.inc558

for.inc554:                                       ; preds = %land.rhs542
  %trunc.ln375 = trunc i32 %b to i8
  %call.ret176 = call fastcc { i16, i32 } @"laya::full::full_require_owner"(i8 %qkv.ref.id.load.3, i8 %qkv.ref.bank.load.3, i32 %qkv.ref.epoch.load, i8 %qkv.region.load.3, i8 %qkv.stage.load, i8 %qkv.layer.load, i8 %qkv.batch.load, i8 %qkv.row_space.load, i16 %qkv.row0.load, i16 %qkv.rows.load, i16 %qkv.width.load, i8 %qkv.content.load, i8 %trunc.ln375, i16 0, i16 %"(anonymous namespace)::runtime.inputs.identity.S.load.13")
  %c.code.188 = extractvalue { i16, i32 } %call.ret176, 0
  %c.detail.201 = extractvalue { i16, i32 } %call.ret176, 1
  %b.3 = add nuw nsw i32 %b, 1
  br label %for.cond536, !llvm.loop !4077

for.inc558:                                       ; preds = %land.rhs542, %for.cond536
  %c.code.5.lcssa = phi i16 [ %c.code.5, %land.rhs542 ], [ %c.code.5, %for.cond536 ]
  %c.detail.3.lcssa = phi i32 [ %c.detail.3, %land.rhs542 ], [ %c.detail.3, %for.cond536 ]
  %add.ln373 = add nuw nsw i64 %shard.2, 1
  br label %for.cond529, !llvm.loop !4084

for.end561:                                       ; preds = %land.rhs531, %for.cond529
  %c.code.4.lcssa = phi i16 [ %c.code.4, %land.rhs531 ], [ %c.code.4, %for.cond529 ]
  %c.detail.2.lcssa = phi i32 [ %c.detail.2, %land.rhs531 ], [ %c.detail.2, %for.cond529 ]
  %icmp.ln9.202 = icmp eq i16 %c.code.4.lcssa, 0
  br i1 %icmp.ln9.202, label %if.end565, label %if.then563

if.then563:                                       ; preds = %for.end561
  %call.ret171 = call fastcc { i16, i32, i64, i32, i16, i32, i64, i32, i8 } @"laya::full::(anonymous namespace)::finish_load"(i32 %t.ctx.task_id.read, i8 %t.ctx.op.read, i32 %t.byte_count.read, i16 %c.code.4.lcssa, i32 %c.detail.2.lcssa, i64 -1)
  %newret348 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret171, 0
  %newret350 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret171, 1
  %newret352 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret171, 2
  %newret354 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret171, 3
  %newret356 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret171, 4
  %newret358 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret171, 5
  %newret360 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret171, 6
  %newret362 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret171, 7
  %newret364 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret171, 8
  br label %cleanup773

if.end565:                                        ; preds = %for.end561
  %"(anonymous namespace)::runtime.load" = load i8, i8* @"(anonymous namespace)::runtime.loaded_kv_ref.id", align 512
  %icmp.ln378 = icmp eq i8 %"(anonymous namespace)::runtime.load", 0
  br i1 %icmp.ln378, label %if.end598, label %arrayinit.body.i.i294.preheader

arrayinit.body.i.i294.preheader:                  ; preds = %if.end565
  br label %arrayinit.body.i.i294

arrayinit.body.i.i294:                            ; preds = %arrayinit.body.i.i294, %arrayinit.body.i.i294.preheader
  %arrayinit.curidx.i.i290 = phi i64 [ %add.ln14, %arrayinit.body.i.i294 ], [ 0, %arrayinit.body.i.i294.preheader ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 16, i64 16, i64 16), !fpga.pragma.source !169
  %old.identity.model_tag.1.addr = getelementptr [16 x i8], [16 x i8]* %old.identity.model_tag.2, i64 0, i64 %arrayinit.curidx.i.i290
  %add.ln14 = add nuw nsw i64 %arrayinit.curidx.i.i290, 1
  store i8 0, i8* %old.identity.model_tag.1.addr, align 1, !alias.scope !4088, !noalias !4093
  %icmp.ln14 = icmp eq i64 %arrayinit.curidx.i.i290, 15
  br i1 %icmp.ln14, label %arrayinit.body3.i.i300.preheader, label %arrayinit.body.i.i294, !llvm.loop !4129

arrayinit.body3.i.i300.preheader:                 ; preds = %arrayinit.body.i.i294
  br label %arrayinit.body3.i.i300

arrayinit.body3.i.i300:                           ; preds = %arrayinit.body3.i.i300, %arrayinit.body3.i.i300.preheader
  %arrayinit.curidx4.i.i296 = phi i64 [ %add.ln15, %arrayinit.body3.i.i300 ], [ 0, %arrayinit.body3.i.i300.preheader ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 16, i64 16, i64 16), !fpga.pragma.source !169
  %old.identity.numeric_tag.1.addr = getelementptr [16 x i8], [16 x i8]* %old.identity.numeric_tag.2, i64 0, i64 %arrayinit.curidx4.i.i296
  %add.ln15 = add nuw nsw i64 %arrayinit.curidx4.i.i296, 1
  store i8 0, i8* %old.identity.numeric_tag.1.addr, align 1, !alias.scope !4130, !noalias !4131
  %icmp.ln15 = icmp eq i64 %arrayinit.curidx4.i.i296, 15
  br i1 %icmp.ln15, label %arrayinit.body10.i.i306.preheader, label %arrayinit.body3.i.i300, !llvm.loop !4132

arrayinit.body10.i.i306.preheader:                ; preds = %arrayinit.body3.i.i300
  br label %arrayinit.body10.i.i306

arrayinit.body10.i.i306:                          ; preds = %arrayinit.body10.i.i306, %arrayinit.body10.i.i306.preheader
  %arrayinit.curidx11.i.i302 = phi i64 [ %add.ln16, %arrayinit.body10.i.i306 ], [ 0, %arrayinit.body10.i.i306.preheader ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 16, i64 16, i64 16), !fpga.pragma.source !169
  %old.identity.layout_tag.1.addr = getelementptr [16 x i8], [16 x i8]* %old.identity.layout_tag.2, i64 0, i64 %arrayinit.curidx11.i.i302
  %add.ln16 = add nuw nsw i64 %arrayinit.curidx11.i.i302, 1
  store i8 0, i8* %old.identity.layout_tag.1.addr, align 1, !alias.scope !4133, !noalias !4134
  %icmp.ln16 = icmp eq i64 %arrayinit.curidx11.i.i302, 15
  br i1 %icmp.ln16, label %arrayinit.body17.i.i312.preheader, label %arrayinit.body10.i.i306, !llvm.loop !4135

arrayinit.body17.i.i312.preheader:                ; preds = %arrayinit.body10.i.i306
  br label %arrayinit.body17.i.i312

arrayinit.body17.i.i312:                          ; preds = %arrayinit.body17.i.i312, %arrayinit.body17.i.i312.preheader
  %arrayinit.curidx18.i.i308 = phi i64 [ %add.ln17, %arrayinit.body17.i.i312 ], [ 0, %arrayinit.body17.i.i312.preheader ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 16, i64 16, i64 16), !fpga.pragma.source !169
  %old.identity.build_tag.1.addr = getelementptr [16 x i8], [16 x i8]* %old.identity.build_tag.2, i64 0, i64 %arrayinit.curidx18.i.i308
  %add.ln17 = add nuw nsw i64 %arrayinit.curidx18.i.i308, 1
  store i8 0, i8* %old.identity.build_tag.1.addr, align 1, !alias.scope !4136, !noalias !4137
  %icmp.ln17 = icmp eq i64 %arrayinit.curidx18.i.i308, 15
  br i1 %icmp.ln17, label %arrayinit.body.i318.preheader, label %arrayinit.body17.i.i312, !llvm.loop !4138

arrayinit.body.i318.preheader:                    ; preds = %arrayinit.body17.i.i312
  br label %arrayinit.body.i318

arrayinit.body.i318:                              ; preds = %arrayinit.body.i318, %arrayinit.body.i318.preheader
  %arrayinit.curidx.i314 = phi i64 [ %add.ln75, %arrayinit.body.i318 ], [ 0, %arrayinit.body.i318.preheader ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 64, i64 64, i64 64), !fpga.pragma.source !169
  %old.covered_rows.1.addr = getelementptr [64 x i32], [64 x i32]* %old.covered_rows.2, i64 0, i64 %arrayinit.curidx.i314
  %add.ln75 = add nuw nsw i64 %arrayinit.curidx.i314, 1
  store i32 0, i32* %old.covered_rows.1.addr, align 4, !alias.scope !4139, !noalias !4140
  %icmp.ln75 = icmp eq i64 %arrayinit.curidx.i314, 63
  br i1 %icmp.ln75, label %arrayinit.body3.i324.preheader, label %arrayinit.body.i318, !llvm.loop !4141

arrayinit.body3.i324.preheader:                   ; preds = %arrayinit.body.i318
  br label %arrayinit.body3.i324

arrayinit.body3.i324:                             ; preds = %arrayinit.body3.i324, %arrayinit.body3.i324.preheader
  %arrayinit.curidx4.i320 = phi i64 [ %add.ln76, %arrayinit.body3.i324 ], [ 0, %arrayinit.body3.i324.preheader ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 64, i64 64, i64 64), !fpga.pragma.source !169
  %old.old_consumed_rows.1.addr = getelementptr [64 x i32], [64 x i32]* %old.old_consumed_rows.2, i64 0, i64 %arrayinit.curidx4.i320
  %add.ln76 = add nuw nsw i64 %arrayinit.curidx4.i320, 1
  store i32 0, i32* %old.old_consumed_rows.1.addr, align 4, !alias.scope !4142, !noalias !4143
  %icmp.ln76 = icmp eq i64 %arrayinit.curidx4.i320, 63
  br i1 %icmp.ln76, label %_ZN4laya4full15FullOwnerRecordC2Ev.exit326, label %arrayinit.body3.i324, !llvm.loop !4144

_ZN4laya4full15FullOwnerRecordC2Ev.exit326:       ; preds = %arrayinit.body3.i324
  %"(anonymous namespace)::runtime.load.10" = load i32, i32* @"(anonymous namespace)::runtime.loaded_kv_ref.epoch", align 512
  %call.ret183 = call fastcc { i16, i32, i64, i64, i16, i16, i8, i8, i32, i8, i8, i32, i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i1 } @"laya::full::full_owner_snapshot"(i8 %"(anonymous namespace)::runtime.load", i8 0, i32 %"(anonymous namespace)::runtime.load.10", i8 0, [16 x i8]* %old.identity.model_tag.2, [16 x i8]* %old.identity.numeric_tag.2, [16 x i8]* %old.identity.layout_tag.2, [16 x i8]* %old.identity.build_tag.2, [64 x i32]* %old.covered_rows.2, [64 x i32]* %old.old_consumed_rows.2)
  %c.code.193 = extractvalue { i16, i32, i64, i64, i16, i16, i8, i8, i32, i8, i8, i32, i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i1 } %call.ret183, 0
  %old.ref.id.1 = extractvalue { i16, i32, i64, i64, i16, i16, i8, i8, i32, i8, i8, i32, i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i1 } %call.ret183, 6
  %old.ref.bank.1 = extractvalue { i16, i32, i64, i64, i16, i16, i8, i8, i32, i8, i8, i32, i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i1 } %call.ret183, 7
  %old.ref.epoch.1 = extractvalue { i16, i32, i64, i64, i16, i16, i8, i8, i32, i8, i8, i32, i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i1 } %call.ret183, 8
  %old.max_claimed_epoch = extractvalue { i16, i32, i64, i64, i16, i16, i8, i8, i32, i8, i8, i32, i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i1 } %call.ret183, 12
  %old.region.1 = extractvalue { i16, i32, i64, i64, i16, i16, i8, i8, i32, i8, i8, i32, i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i1 } %call.ret183, 13
  %old.stage.1 = extractvalue { i16, i32, i64, i64, i16, i16, i8, i8, i32, i8, i8, i32, i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i1 } %call.ret183, 14
  %old.layer.1 = extractvalue { i16, i32, i64, i64, i16, i16, i8, i8, i32, i8, i8, i32, i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i1 } %call.ret183, 15
  %old.batch.1 = extractvalue { i16, i32, i64, i64, i16, i16, i8, i8, i32, i8, i8, i32, i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i1 } %call.ret183, 16
  %old.row_space.1 = extractvalue { i16, i32, i64, i64, i16, i16, i8, i8, i32, i8, i8, i32, i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i1 } %call.ret183, 17
  %old.row0.1 = extractvalue { i16, i32, i64, i64, i16, i16, i8, i8, i32, i8, i8, i32, i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i1 } %call.ret183, 18
  %old.rows.1 = extractvalue { i16, i32, i64, i64, i16, i16, i8, i8, i32, i8, i8, i32, i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i1 } %call.ret183, 19
  %old.width.1 = extractvalue { i16, i32, i64, i64, i16, i16, i8, i8, i32, i8, i8, i32, i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i1 } %call.ret183, 20
  %old.content.1 = extractvalue { i16, i32, i64, i64, i16, i16, i8, i8, i32, i8, i8, i32, i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i1 } %call.ret183, 21
  %old.state = extractvalue { i16, i32, i64, i64, i16, i16, i8, i8, i32, i8, i8, i32, i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i1 } %call.ret183, 22
  %old.valid = extractvalue { i16, i32, i64, i64, i16, i16, i8, i8, i32, i8, i8, i32, i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i1 } %call.ret183, 23
  %icmp.ln9.211 = icmp eq i16 %c.code.193, 0
  br i1 %icmp.ln9.211, label %lor.lhs.false574, label %if.then585

lor.lhs.false574:                                 ; preds = %_ZN4laya4full15FullOwnerRecordC2Ev.exit326
  %xor.ln381 = xor i1 %old.valid, true
  %icmp.ln381 = icmp ne i8 %old.state, 2
  %or.ln381 = or i1 %icmp.ln381, %xor.ln381
  br i1 %or.ln381, label %if.then585, label %lor.lhs.false579

lor.lhs.false579:                                 ; preds = %lor.lhs.false574
  %add.ln382 = add i32 %old.max_claimed_epoch, 1
  %icmp.ln382 = icmp eq i32 %add.ln382, %t_dst_epoch.val
  br i1 %icmp.ln382, label %if.end588, label %if.then585

if.then585:                                       ; preds = %lor.lhs.false579, %lor.lhs.false574, %_ZN4laya4full15FullOwnerRecordC2Ev.exit326
  %call.ret185 = call fastcc { i16, i32, i64, i32, i16, i32, i64, i32, i8 } @"laya::full::(anonymous namespace)::finish_load"(i32 %t.ctx.task_id.read, i8 %t.ctx.op.read, i32 %t.byte_count.read, i16 5, i32 69533700, i64 -1)
  %newret = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret185, 0
  %newret386 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret185, 1
  %newret388 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret185, 2
  %newret390 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret185, 3
  %newret392 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret185, 4
  %newret394 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret185, 5
  %newret396 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret185, 6
  %newret398 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret185, 7
  %newret400 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret185, 8
  br label %cleanup773

if.end588:                                        ; preds = %lor.lhs.false579
  %call.ret184 = call fastcc { i16, i32 } @"laya::full::full_release_owner"(i8 %old.ref.id.1, i8 %old.ref.bank.1, i32 %old.ref.epoch.1, i8 %old.region.1, i8 %old.stage.1, i8 %old.layer.1, i8 %old.batch.1, i8 %old.row_space.1, i16 %old.row0.1, i16 %old.rows.1, i16 %old.width.1, i8 %old.content.1)
  %c.code.194 = extractvalue { i16, i32 } %call.ret184, 0
  %c.detail.206 = extractvalue { i16, i32 } %call.ret184, 1
  %icmp.ln9.212 = icmp eq i16 %c.code.194, 0
  br i1 %icmp.ln9.212, label %if.end598, label %if.then592

if.then592:                                       ; preds = %if.end588
  %call.ret188 = call fastcc { i16, i32, i64, i32, i16, i32, i64, i32, i8 } @"laya::full::(anonymous namespace)::finish_load"(i32 %t.ctx.task_id.read, i8 %t.ctx.op.read, i32 %t.byte_count.read, i16 %c.code.194, i32 %c.detail.206, i64 -1)
  %newret402 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret188, 0
  %newret404 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret188, 1
  %newret406 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret188, 2
  %newret408 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret188, 3
  %newret410 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret188, 4
  %newret412 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret188, 5
  %newret414 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret188, 6
  %newret416 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret188, 7
  %newret418 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret188, 8
  br label %cleanup773

if.end598:                                        ; preds = %if.end588, %if.end565
  %kv.rows = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.S", align 512
  %call.ret187 = call fastcc { i16, i32 } @"laya::full::full_claim_owner"(i8 37, i8 0, i32 %t_dst_epoch.val, i8 0, i8 %t_ctx_stage.val, i8 %t_ctx_layer.val, i8 -1, i8 0, i16 0, i16 %kv.rows, i16 64, i8 1)
  %c.code.196 = extractvalue { i16, i32 } %call.ret187, 0
  %c.detail.207 = extractvalue { i16, i32 } %call.ret187, 1
  %icmp.ln9.214 = icmp eq i16 %c.code.196, 0
  br i1 %icmp.ln9.214, label %if.end621, label %if.then619

if.then619:                                       ; preds = %if.end598
  %call.ret190 = call fastcc { i16, i32, i64, i32, i16, i32, i64, i32, i8 } @"laya::full::(anonymous namespace)::finish_load"(i32 %t.ctx.task_id.read, i8 %t.ctx.op.read, i32 %t.byte_count.read, i16 %c.code.196, i32 %c.detail.207, i64 -1)
  %newret420 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret190, 0
  %newret422 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret190, 1
  %newret424 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret190, 2
  %newret426 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret190, 3
  %newret428 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret190, 4
  %newret429 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret190, 5
  %newret430 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret190, 6
  %newret431 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret190, 7
  %newret432 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret190, 8
  br label %cleanup773

if.end621:                                        ; preds = %if.end598
  %qkv.ref.epoch.addr.5 = getelementptr [2 x i32], [2 x i32]* %qkv.ref.epoch, i64 0, i64 0
  %qkv.row0.addr.5 = getelementptr [2 x i16], [2 x i16]* %qkv.row0, i64 0, i64 0
  %qkv.rows.addr.5 = getelementptr [2 x i16], [2 x i16]* %qkv.rows, i64 0, i64 0
  %qkv.width.addr.5 = getelementptr [2 x i16], [2 x i16]* %qkv.width, i64 0, i64 0
  %"(anonymous namespace)::runtime.inputs.identity.S.load.15" = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.S", align 512
  %qkv.ref.id.load.4 = load i8, i8* %qkv.ref.id.addr, align 512
  %qkv.ref.bank.load.4 = load i8, i8* %qkv.ref.bank.addr, align 512
  %qkv.ref.epoch.load.2 = load i32, i32* %qkv.ref.epoch.addr.5, align 512
  %qkv.region.load.4 = load i8, i8* %qkv.region.addr, align 512
  %qkv.layer.load.2 = load i8, i8* %qkv.layer.addr, align 512
  %qkv.content.load.2 = load i8, i8* %qkv.content.addr, align 512
  %qkv.stage.load.2 = load i8, i8* %qkv.stage.addr, align 512
  %qkv.batch.load.2 = load i8, i8* %qkv.batch.addr, align 512
  %qkv.row_space.load.2 = load i8, i8* %qkv.row_space.addr, align 512
  %qkv.row0.load.2 = load i16, i16* %qkv.row0.addr.5, align 512
  %qkv.rows.load.2 = load i16, i16* %qkv.rows.addr.5, align 512
  %qkv.width.load.2 = load i16, i16* %qkv.width.addr.5, align 512
  %call.ret189 = call fastcc { i16, i32 } @"laya::full::full_acquire_owner.5"(i8 %qkv.ref.id.load.4, i8 %qkv.ref.bank.load.4, i32 %qkv.ref.epoch.load.2, i8 %qkv.region.load.4, i8 %qkv.stage.load.2, i8 %qkv.layer.load.2, i8 %qkv.batch.load.2, i8 %qkv.row_space.load.2, i16 %qkv.row0.load.2, i16 %qkv.rows.load.2, i16 %qkv.width.load.2, i8 %qkv.content.load.2, i8 0, i16 0, i16 %"(anonymous namespace)::runtime.inputs.identity.S.load.15")
  %c.code.197 = extractvalue { i16, i32 } %call.ret189, 0
  %c.detail.208 = extractvalue { i16, i32 } %call.ret189, 1
  %icmp.ln9.215 = icmp eq i16 %c.code.197, 0
  br i1 %icmp.ln9.215, label %if.then628, label %if.end637

if.then628:                                       ; preds = %if.end621
  %qkv.ref.id.addr.7 = getelementptr [2 x i8], [2 x i8]* %qkv.ref.id, i64 0, i64 1
  %qkv.ref.bank.addr.6 = getelementptr [2 x i8], [2 x i8]* %qkv.ref.bank, i64 0, i64 1
  %qkv.ref.epoch.addr.6 = getelementptr [2 x i32], [2 x i32]* %qkv.ref.epoch, i64 0, i64 1
  %qkv.region.addr.6 = getelementptr [2 x i8], [2 x i8]* %qkv.region, i64 0, i64 1
  %qkv.stage.addr.7 = getelementptr [2 x i8], [2 x i8]* %qkv.stage, i64 0, i64 1
  %qkv.layer.addr.6 = getelementptr [2 x i8], [2 x i8]* %qkv.layer, i64 0, i64 1
  %qkv.batch.addr.7 = getelementptr [2 x i8], [2 x i8]* %qkv.batch, i64 0, i64 1
  %qkv.row_space.addr.6 = getelementptr [2 x i8], [2 x i8]* %qkv.row_space, i64 0, i64 1
  %qkv.row0.addr.6 = getelementptr [2 x i16], [2 x i16]* %qkv.row0, i64 0, i64 1
  %qkv.rows.addr.6 = getelementptr [2 x i16], [2 x i16]* %qkv.rows, i64 0, i64 1
  %qkv.width.addr.6 = getelementptr [2 x i16], [2 x i16]* %qkv.width, i64 0, i64 1
  %qkv.content.addr.6 = getelementptr [2 x i8], [2 x i8]* %qkv.content, i64 0, i64 1
  %"(anonymous namespace)::runtime.inputs.identity.S.load.16" = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.S", align 512
  %qkv.ref.id.load.5 = load i8, i8* %qkv.ref.id.addr.7, align 1
  %qkv.ref.bank.load.5 = load i8, i8* %qkv.ref.bank.addr.6, align 1
  %qkv.ref.epoch.load.3 = load i32, i32* %qkv.ref.epoch.addr.6, align 4
  %qkv.region.load.5 = load i8, i8* %qkv.region.addr.6, align 1
  %qkv.layer.load.3 = load i8, i8* %qkv.layer.addr.6, align 1
  %qkv.content.load.3 = load i8, i8* %qkv.content.addr.6, align 1
  %qkv.stage.load.3 = load i8, i8* %qkv.stage.addr.7, align 1
  %qkv.batch.load.3 = load i8, i8* %qkv.batch.addr.7, align 1
  %qkv.row_space.load.3 = load i8, i8* %qkv.row_space.addr.6, align 1
  %qkv.row0.load.3 = load i16, i16* %qkv.row0.addr.6, align 2
  %qkv.rows.load.3 = load i16, i16* %qkv.rows.addr.6, align 2
  %qkv.width.load.3 = load i16, i16* %qkv.width.addr.6, align 2
  %call.ret191 = call fastcc { i16, i32 } @"laya::full::full_acquire_owner.5"(i8 %qkv.ref.id.load.5, i8 %qkv.ref.bank.load.5, i32 %qkv.ref.epoch.load.3, i8 %qkv.region.load.5, i8 %qkv.stage.load.3, i8 %qkv.layer.load.3, i8 %qkv.batch.load.3, i8 %qkv.row_space.load.3, i16 %qkv.row0.load.3, i16 %qkv.rows.load.3, i16 %qkv.width.load.3, i8 %qkv.content.load.3, i8 0, i16 0, i16 %"(anonymous namespace)::runtime.inputs.identity.S.load.16")
  %c.code.198 = extractvalue { i16, i32 } %call.ret191, 0
  %c.detail.209 = extractvalue { i16, i32 } %call.ret191, 1
  %read1 = icmp eq i16 %c.code.198, 0
  br label %if.end637

if.end637:                                        ; preds = %if.then628, %if.end621
  %c.code.6 = phi i16 [ %c.code.198, %if.then628 ], [ %c.code.197, %if.end621 ]
  %.1102 = phi i32 [ %c.detail.209, %if.then628 ], [ %c.detail.208, %if.end621 ]
  %read0 = phi i1 [ true, %if.then628 ], [ false, %if.end621 ]
  %read1.1 = phi i1 [ %read1, %if.then628 ], [ false, %if.end621 ]
  %icmp.ln9.217 = icmp eq i16 %c.code.6, 0
  br i1 %icmp.ln9.217, label %for.cond641.preheader, label %kv_fail

for.cond641.preheader:                            ; preds = %if.end637
  br label %for.cond641

for.cond641:                                      ; preds = %for.inc707, %for.cond641.preheader
  %c.code.7 = phi i16 [ %c.code.8.lcssa, %for.inc707 ], [ 0, %for.cond641.preheader ]
  %plane = phi i64 [ %add.ln402, %for.inc707 ], [ 0, %for.cond641.preheader ]
  %.198 = phi i32 [ %.1100.lcssa, %for.inc707 ], [ %.1102, %for.cond641.preheader ]
  %.087 = phi i16 [ %.089.lcssa, %for.inc707 ], [ 0, %for.cond641.preheader ]
  %plane.0 = phi i32 [ %plane.1, %for.inc707 ], [ 0, %for.cond641.preheader ]
  %icmp.ln402 = icmp ult i64 %plane, 2
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 1, i64 2, i64 1)
  br i1 %icmp.ln402, label %land.rhs643, label %for.end710

land.rhs643:                                      ; preds = %for.cond641
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @59)
  %icmp.ln9.220 = icmp eq i16 %c.code.7, 0
  br i1 %icmp.ln9.220, label %VITIS_LOOP_403_10, label %for.end710

VITIS_LOOP_403_10:                                ; preds = %land.rhs643
  %trunc.ln406 = trunc i32 %plane.0 to i8
  %add.ln406 = add nuw nsw i8 %trunc.ln406, 1
  br label %for.cond649

for.cond649:                                      ; preds = %for.inc703, %VITIS_LOOP_403_10
  %c.code.8 = phi i16 [ 0, %VITIS_LOOP_403_10 ], [ %c.code.9.lcssa, %for.inc703 ]
  %b.4 = phi i64 [ 0, %VITIS_LOOP_403_10 ], [ %add.ln403, %for.inc703 ]
  %.1100 = phi i32 [ %.198, %VITIS_LOOP_403_10 ], [ %.1101.lcssa, %for.inc703 ]
  %.089 = phi i16 [ %.087, %VITIS_LOOP_403_10 ], [ %.090.lcssa, %for.inc703 ]
  %"(anonymous namespace)::runtime.inputs.identity.B.load.7" = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.B", align 512
  %zext.ln403 = zext i16 %"(anonymous namespace)::runtime.inputs.identity.B.load.7" to i64
  %icmp.ln403 = icmp ult i64 %b.4, %zext.ln403
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 0, i64 65535, i64 0)
  br i1 %icmp.ln403, label %land.rhs655, label %for.inc707

land.rhs655:                                      ; preds = %for.cond649
  call void (...) @_ssdm_op_SpecLoopName([18 x i8]* @58)
  %icmp.ln9.225 = icmp eq i16 %c.code.8, 0
  br i1 %icmp.ln9.225, label %VITIS_LOOP_404_11, label %for.inc707

VITIS_LOOP_404_11:                                ; preds = %land.rhs655
  %trunc.ln406.1 = trunc i64 %b.4 to i8
  br label %for.cond660

for.cond660:                                      ; preds = %for.inc699, %VITIS_LOOP_404_11
  %c.code.9 = phi i16 [ 0, %VITIS_LOOP_404_11 ], [ %newret686.lcssa, %for.inc699 ]
  %row = phi i64 [ 0, %VITIS_LOOP_404_11 ], [ %add.ln404, %for.inc699 ]
  %.1101 = phi i32 [ %.1100, %VITIS_LOOP_404_11 ], [ %newret688.lcssa, %for.inc699 ]
  %.090 = phi i16 [ %.089, %VITIS_LOOP_404_11 ], [ %newret686.lcssa, %for.inc699 ]
  %row.0 = phi i32 [ 0, %VITIS_LOOP_404_11 ], [ %row.3, %for.inc699 ]
  %"(anonymous namespace)::runtime.inputs.identity.S.load.17" = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.S", align 512
  %zext.ln404 = zext i16 %"(anonymous namespace)::runtime.inputs.identity.S.load.17" to i64
  %icmp.ln404 = icmp ult i64 %row, %zext.ln404
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 0, i64 65535, i64 0)
  br i1 %icmp.ln404, label %land.rhs666, label %for.inc703

land.rhs666:                                      ; preds = %for.cond660
  call void (...) @_ssdm_op_SpecLoopName([18 x i8]* @57)
  %icmp.ln9.229 = icmp eq i16 %c.code.9, 0
  br i1 %icmp.ln9.229, label %VITIS_LOOP_405_12, label %for.inc703

VITIS_LOOP_405_12:                                ; preds = %land.rhs666
  %trunc.ln407 = trunc i32 %row.0 to i16
  br label %for.body675

for.body675:                                      ; preds = %for.body675, %VITIS_LOOP_405_12
  %j.1 = phi i64 [ 0, %VITIS_LOOP_405_12 ], [ %add.ln405, %for.body675 ]
  %j671.027 = phi i32 [ 0, %VITIS_LOOP_405_12 ], [ %j.2, %for.body675 ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 0, i64 64, i64 32), !fpga.pragma.source !169
  call void (...) @_ssdm_op_SpecLoopName([18 x i8]* @54)
  %trunc.ln407.1 = trunc i32 %j671.027 to i8
  %"laya::full::g_full_cache_kv.addr" = getelementptr inbounds [2 x [2 x [1024 x [64 x float]]]], [2 x [2 x [1024 x [64 x float]]]]* @"laya::full::g_full_cache_kv", i64 0, i64 %plane, i64 %b.4, i64 %row, i64 %j.1
  %"laya::full::g_full_cache_kv.load" = load float, float* %"laya::full::g_full_cache_kv.addr", align 4
  %call.ret203 = call fastcc { i16, i32, float } @"laya::full::(anonymous namespace)::read_qkv_f32"(i8 addrspace(1)* %embedding, i64 %memory_embedding, i8 addrspace(1)* %io, i64 %memory_io, i8 addrspace(1)* %w_q0, i64 %memory_w_q0, i8 addrspace(1)* %w_q1, i64 %memory_w_q1, i8 addrspace(1)* %w_scale, i64 %memory_w_scale, i8 addrspace(1)* %aux, i64 %memory_aux, i8 addrspace(1)* %state0, i64 %memory_state0, i8 addrspace(1)* %state1, i64 %memory_state1, i8 addrspace(1)* %qkv0, i64 %memory_qkv0, i8 addrspace(1)* %qkv1, i64 %memory_qkv1, i8 addrspace(1)* %ff0, i64 %memory_ff0, i8 addrspace(1)* %ff1, i64 %memory_ff1, i8 addrspace(1)* %att_out, i64 %memory_att_out, i8 %add.ln406, i8 %trunc.ln406.1, i8 %t_head.val, i16 %trunc.ln407, i8 %trunc.ln407.1, float %"laya::full::g_full_cache_kv.load")
  %c.code.206 = extractvalue { i16, i32, float } %call.ret203, 0
  %c.detail.217 = extractvalue { i16, i32, float } %call.ret203, 1
  %newret457 = extractvalue { i16, i32, float } %call.ret203, 2
  store float %newret457, float* %"laya::full::g_full_cache_kv.addr", align 4
  %icmp.ln9.233 = icmp eq i16 %c.code.206, 0
  %add.ln405 = add nuw nsw i64 %j.1, 1
  %j.2 = add nuw nsw i32 %j671.027, 1
  %icmp.ln405 = icmp ult i64 %add.ln405, 64
  %and.ln409 = and i1 %icmp.ln9.233, %icmp.ln405
  br i1 %and.ln409, label %for.body675, label %for.inc699, !llvm.loop !4145

for.inc699:                                       ; preds = %for.body675
  %newret688.lcssa = phi i32 [ %c.detail.217, %for.body675 ]
  %newret686.lcssa = phi i16 [ %c.code.206, %for.body675 ]
  %add.ln404 = add nuw nsw i64 %row, 1
  %row.3 = add nuw nsw i32 %row.0, 1
  br label %for.cond660, !llvm.loop !4156

for.inc703:                                       ; preds = %land.rhs666, %for.cond660
  %.090.lcssa = phi i16 [ %.090, %land.rhs666 ], [ %.090, %for.cond660 ]
  %.1101.lcssa = phi i32 [ %.1101, %land.rhs666 ], [ %.1101, %for.cond660 ]
  %c.code.9.lcssa = phi i16 [ %c.code.9, %land.rhs666 ], [ %c.code.9, %for.cond660 ]
  %add.ln403 = add nuw nsw i64 %b.4, 1
  br label %for.cond649, !llvm.loop !4160

for.inc707:                                       ; preds = %land.rhs655, %for.cond649
  %.089.lcssa = phi i16 [ %.089, %land.rhs655 ], [ %.089, %for.cond649 ]
  %.1100.lcssa = phi i32 [ %.1100, %land.rhs655 ], [ %.1100, %for.cond649 ]
  %c.code.8.lcssa = phi i16 [ %c.code.8, %land.rhs655 ], [ %c.code.8, %for.cond649 ]
  %add.ln402 = add nuw nsw i64 %plane, 1
  %plane.1 = add nuw nsw i32 %plane.0, 1
  br label %for.cond641, !llvm.loop !4164

for.end710:                                       ; preds = %land.rhs643, %for.cond641
  %.087.lcssa = phi i16 [ %.087, %land.rhs643 ], [ %.087, %for.cond641 ]
  %.198.lcssa = phi i32 [ %.198, %land.rhs643 ], [ %.198, %for.cond641 ]
  %c.code.7.lcssa = phi i16 [ %c.code.7, %land.rhs643 ], [ %c.code.7, %for.cond641 ]
  br i1 %read1.1, label %if.then711, label %if.end714

if.then711:                                       ; preds = %for.end710
  %qkv.ref.id.addr.8 = getelementptr [2 x i8], [2 x i8]* %qkv.ref.id, i64 0, i64 1
  %qkv.ref.bank.addr.7 = getelementptr [2 x i8], [2 x i8]* %qkv.ref.bank, i64 0, i64 1
  %qkv.ref.epoch.addr.7 = getelementptr [2 x i32], [2 x i32]* %qkv.ref.epoch, i64 0, i64 1
  %qkv.region.addr.7 = getelementptr [2 x i8], [2 x i8]* %qkv.region, i64 0, i64 1
  %qkv.stage.addr.8 = getelementptr [2 x i8], [2 x i8]* %qkv.stage, i64 0, i64 1
  %qkv.layer.addr.7 = getelementptr [2 x i8], [2 x i8]* %qkv.layer, i64 0, i64 1
  %qkv.batch.addr.8 = getelementptr [2 x i8], [2 x i8]* %qkv.batch, i64 0, i64 1
  %qkv.row_space.addr.7 = getelementptr [2 x i8], [2 x i8]* %qkv.row_space, i64 0, i64 1
  %qkv.row0.addr.7 = getelementptr [2 x i16], [2 x i16]* %qkv.row0, i64 0, i64 1
  %qkv.rows.addr.7 = getelementptr [2 x i16], [2 x i16]* %qkv.rows, i64 0, i64 1
  %qkv.width.addr.7 = getelementptr [2 x i16], [2 x i16]* %qkv.width, i64 0, i64 1
  %qkv.content.addr.7 = getelementptr [2 x i8], [2 x i8]* %qkv.content, i64 0, i64 1
  %qkv.ref.id.load = load i8, i8* %qkv.ref.id.addr.8, align 512
  %qkv.ref.bank.load = load i8, i8* %qkv.ref.bank.addr.7, align 512
  %qkv.region.load = load i8, i8* %qkv.region.addr.7, align 512
  %qkv.ref.epoch.load.4 = load i32, i32* %qkv.ref.epoch.addr.7, align 4
  %qkv.stage.load.4 = load i8, i8* %qkv.stage.addr.8, align 1
  %qkv.layer.load.4 = load i8, i8* %qkv.layer.addr.7, align 1
  %qkv.batch.load.4 = load i8, i8* %qkv.batch.addr.8, align 1
  %qkv.row_space.load.4 = load i8, i8* %qkv.row_space.addr.7, align 1
  %qkv.row0.load.4 = load i16, i16* %qkv.row0.addr.7, align 2
  %qkv.rows.load.4 = load i16, i16* %qkv.rows.addr.7, align 2
  %qkv.width.load.4 = load i16, i16* %qkv.width.addr.7, align 2
  %qkv.content.load.4 = load i8, i8* %qkv.content.addr.7, align 1
  call fastcc void @"laya::full::full_release_read_owner.4"(i8 %qkv.ref.id.load, i8 %qkv.ref.bank.load, i32 %qkv.ref.epoch.load.4, i8 %qkv.region.load, i8 %qkv.stage.load.4, i8 %qkv.layer.load.4, i8 %qkv.batch.load.4, i8 %qkv.row_space.load.4, i16 %qkv.row0.load.4, i16 %qkv.rows.load.4, i16 %qkv.width.load.4, i8 %qkv.content.load.4)
  br label %if.end714

if.end714:                                        ; preds = %if.then711, %for.end710
  br i1 %read0, label %if.then715, label %if.end718

if.then715:                                       ; preds = %if.end714
  call fastcc void @"laya::full::full_release_read_owner.4"(i8 %qkv.ref.id.load.4, i8 %qkv.ref.bank.load.4, i32 %qkv.ref.epoch.load.2, i8 %qkv.region.load.4, i8 %qkv.stage.load.2, i8 %qkv.layer.load.2, i8 %qkv.batch.load.2, i8 %qkv.row_space.load.2, i16 %qkv.row0.load.2, i16 %qkv.rows.load.2, i16 %qkv.width.load.2, i8 %qkv.content.load.2)
  br label %if.end718

if.end718:                                        ; preds = %if.then715, %if.end714
  %icmp.ln9.223 = icmp eq i16 %c.code.7.lcssa, 0
  br i1 %icmp.ln9.223, label %for.cond722.preheader, label %if.end742

for.cond722.preheader:                            ; preds = %if.end718
  br label %for.cond722

for.cond722:                                      ; preds = %for.inc738, %for.cond722.preheader
  %c.code.10 = phi i16 [ %c.code.203, %for.inc738 ], [ 0, %for.cond722.preheader ]
  %.197 = phi i32 [ %c.detail.214, %for.inc738 ], [ %.198.lcssa, %for.cond722.preheader ]
  %.086 = phi i16 [ %c.code.203, %for.inc738 ], [ %.087.lcssa, %for.cond722.preheader ]
  %b.5 = phi i32 [ %b.6, %for.inc738 ], [ 0, %for.cond722.preheader ]
  %"(anonymous namespace)::runtime.inputs.identity.B.load.8" = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.B", align 512
  %zext.ln414 = zext i16 %"(anonymous namespace)::runtime.inputs.identity.B.load.8" to i32
  %icmp.ln414 = icmp ult i32 %b.5, %zext.ln414
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 0, i64 65535, i64 0)
  br i1 %icmp.ln414, label %land.rhs728, label %if.end742.loopexit

land.rhs728:                                      ; preds = %for.cond722
  call void (...) @_ssdm_op_SpecLoopName([18 x i8]* @56)
  %icmp.ln9.228 = icmp eq i16 %c.code.10, 0
  br i1 %icmp.ln9.228, label %for.inc738, label %if.end742.loopexit

for.inc738:                                       ; preds = %land.rhs728
  %trunc.ln415 = trunc i32 %b.5 to i8
  %"(anonymous namespace)::runtime.inputs.identity.S.load.18" = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.S", align 512
  %call.ret200 = call fastcc { i16, i32 } @"laya::full::full_cover_owner"(i8 37, i8 0, i32 %t_dst_epoch.val, i8 0, i8 %t_ctx_stage.val, i8 %t_ctx_layer.val, i8 -1, i8 0, i16 0, i16 %kv.rows, i16 64, i8 1, i8 %trunc.ln415, i16 0, i16 %"(anonymous namespace)::runtime.inputs.identity.S.load.18")
  %c.code.203 = extractvalue { i16, i32 } %call.ret200, 0
  %c.detail.214 = extractvalue { i16, i32 } %call.ret200, 1
  %b.6 = add nuw nsw i32 %b.5, 1
  br label %for.cond722, !llvm.loop !4168

if.end742.loopexit:                               ; preds = %land.rhs728, %for.cond722
  %.086.lcssa = phi i16 [ %.086, %land.rhs728 ], [ %.086, %for.cond722 ]
  %.197.lcssa = phi i32 [ %.197, %land.rhs728 ], [ %.197, %for.cond722 ]
  %c.code.10.lcssa = phi i16 [ %c.code.10, %land.rhs728 ], [ %c.code.10, %for.cond722 ]
  br label %if.end742

if.end742:                                        ; preds = %if.end742.loopexit, %if.end718
  %c.code.val83 = phi i16 [ %c.code.7.lcssa, %if.end718 ], [ %c.code.10.lcssa, %if.end742.loopexit ]
  %.196 = phi i32 [ %.198.lcssa, %if.end718 ], [ %.197.lcssa, %if.end742.loopexit ]
  %.085 = phi i16 [ %.087.lcssa, %if.end718 ], [ %.086.lcssa, %if.end742.loopexit ]
  %icmp.ln9.230 = icmp eq i16 %c.code.val83, 0
  br i1 %icmp.ln9.230, label %if.then744, label %if.end746

if.then744:                                       ; preds = %if.end742
  %call.ret202 = call fastcc { i16, i32 } @"laya::full::full_publish_owner"(i8 37, i8 0, i32 %t_dst_epoch.val, i8 0, i8 %t_ctx_stage.val, i8 %t_ctx_layer.val, i8 -1, i8 0, i16 0, i16 %kv.rows, i16 64, i8 1)
  %c.code.205 = extractvalue { i16, i32 } %call.ret202, 0
  %c.detail.216 = extractvalue { i16, i32 } %call.ret202, 1
  br label %if.end746

if.end746:                                        ; preds = %if.then744, %if.end742
  %c.code.val84 = phi i16 [ %c.code.205, %if.then744 ], [ %c.code.val83, %if.end742 ]
  %.195 = phi i32 [ %c.detail.216, %if.then744 ], [ %.196, %if.end742 ]
  %.084 = phi i16 [ %c.code.205, %if.then744 ], [ %.085, %if.end742 ]
  %icmp.ln9.231 = icmp eq i16 %c.code.val84, 0
  br i1 %icmp.ln9.231, label %if.then748, label %kv_fail

if.then748:                                       ; preds = %if.end746
  store i8 37, i8* @"(anonymous namespace)::runtime.loaded_kv_ref.id", align 512
  store i32 %t_dst_epoch.val, i32* @"(anonymous namespace)::runtime.loaded_kv_ref.epoch", align 512
  store i8 %t_head.val, i8* @"(anonymous namespace)::runtime.loaded_kv_head", align 512
  %call.ret204 = call fastcc { i16, i32, i64, i32, i16, i32, i64, i32, i8 } @"laya::full::(anonymous namespace)::finish_load"(i32 %t.ctx.task_id.read, i8 %t.ctx.op.read, i32 %t.byte_count.read, i16 0, i32 0, i64 -1)
  %newret433 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret204, 0
  %newret434 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret204, 1
  %newret435 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret204, 2
  %newret436 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret204, 3
  %newret437 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret204, 4
  %newret438 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret204, 5
  %newret439 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret204, 6
  %newret440 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret204, 7
  %newret441 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret204, 8
  br label %cleanup773

kv_fail:                                          ; preds = %if.end746, %if.end637
  %.1 = phi i32 [ %.1102, %if.end637 ], [ %.195, %if.end746 ]
  %.0 = phi i16 [ %c.code.6, %if.end637 ], [ %.084, %if.end746 ]
  %read0.1 = phi i1 [ %read0, %if.end637 ], [ false, %if.end746 ]
  %read1.2 = phi i1 [ %read1.1, %if.end637 ], [ false, %if.end746 ]
  br i1 %read1.2, label %if.then754, label %if.end757

if.then754:                                       ; preds = %kv_fail
  %qkv.ref.id.addr.9 = getelementptr [2 x i8], [2 x i8]* %qkv.ref.id, i64 0, i64 1
  %qkv.ref.bank.addr.8 = getelementptr [2 x i8], [2 x i8]* %qkv.ref.bank, i64 0, i64 1
  %qkv.ref.epoch.addr.8 = getelementptr [2 x i32], [2 x i32]* %qkv.ref.epoch, i64 0, i64 1
  %qkv.region.addr.8 = getelementptr [2 x i8], [2 x i8]* %qkv.region, i64 0, i64 1
  %qkv.stage.addr.9 = getelementptr [2 x i8], [2 x i8]* %qkv.stage, i64 0, i64 1
  %qkv.layer.addr.8 = getelementptr [2 x i8], [2 x i8]* %qkv.layer, i64 0, i64 1
  %qkv.batch.addr.9 = getelementptr [2 x i8], [2 x i8]* %qkv.batch, i64 0, i64 1
  %qkv.row_space.addr.8 = getelementptr [2 x i8], [2 x i8]* %qkv.row_space, i64 0, i64 1
  %qkv.row0.addr.8 = getelementptr [2 x i16], [2 x i16]* %qkv.row0, i64 0, i64 1
  %qkv.rows.addr.8 = getelementptr [2 x i16], [2 x i16]* %qkv.rows, i64 0, i64 1
  %qkv.width.addr.8 = getelementptr [2 x i16], [2 x i16]* %qkv.width, i64 0, i64 1
  %qkv.content.addr.8 = getelementptr [2 x i8], [2 x i8]* %qkv.content, i64 0, i64 1
  %qkv.ref.id.load.2 = load i8, i8* %qkv.ref.id.addr.9, align 512
  %qkv.ref.bank.load.2 = load i8, i8* %qkv.ref.bank.addr.8, align 512
  %qkv.region.load.2 = load i8, i8* %qkv.region.addr.8, align 512
  %qkv.ref.epoch.load.5 = load i32, i32* %qkv.ref.epoch.addr.8, align 4
  %qkv.stage.load.5 = load i8, i8* %qkv.stage.addr.9, align 1
  %qkv.layer.load.5 = load i8, i8* %qkv.layer.addr.8, align 1
  %qkv.batch.load.5 = load i8, i8* %qkv.batch.addr.9, align 1
  %qkv.row_space.load.5 = load i8, i8* %qkv.row_space.addr.8, align 1
  %qkv.row0.load.5 = load i16, i16* %qkv.row0.addr.8, align 2
  %qkv.rows.load.5 = load i16, i16* %qkv.rows.addr.8, align 2
  %qkv.width.load.5 = load i16, i16* %qkv.width.addr.8, align 2
  %qkv.content.load.5 = load i8, i8* %qkv.content.addr.8, align 1
  call fastcc void @"laya::full::full_release_read_owner.4"(i8 %qkv.ref.id.load.2, i8 %qkv.ref.bank.load.2, i32 %qkv.ref.epoch.load.5, i8 %qkv.region.load.2, i8 %qkv.stage.load.5, i8 %qkv.layer.load.5, i8 %qkv.batch.load.5, i8 %qkv.row_space.load.5, i16 %qkv.row0.load.5, i16 %qkv.rows.load.5, i16 %qkv.width.load.5, i8 %qkv.content.load.5)
  br label %if.end757

if.end757:                                        ; preds = %if.then754, %kv_fail
  br i1 %read0.1, label %if.then758, label %if.end761

if.then758:                                       ; preds = %if.end757
  call fastcc void @"laya::full::full_release_read_owner.4"(i8 %qkv.ref.id.load.4, i8 %qkv.ref.bank.load.4, i32 %qkv.ref.epoch.load.2, i8 %qkv.region.load.4, i8 %qkv.stage.load.2, i8 %qkv.layer.load.2, i8 %qkv.batch.load.2, i8 %qkv.row_space.load.2, i16 %qkv.row0.load.2, i16 %qkv.rows.load.2, i16 %qkv.width.load.2, i8 %qkv.content.load.2)
  br label %if.end761

if.end761:                                        ; preds = %if.then758, %if.end757
  %3 = call fastcc i16 @"laya::full::full_invalidate_owner"(i8 37, i8 0, i32 %t_dst_epoch.val, i8 0)
  store i8 0, i8* @"(anonymous namespace)::runtime.loaded_kv_ref.id", align 512
  store i32 0, i32* @"(anonymous namespace)::runtime.loaded_kv_ref.epoch", align 512
  store i8 -1, i8* @"(anonymous namespace)::runtime.loaded_kv_head", align 512
  %call.ret205 = call fastcc { i16, i32, i64, i32, i16, i32, i64, i32, i8 } @"laya::full::(anonymous namespace)::finish_load"(i32 %t.ctx.task_id.read, i8 %t.ctx.op.read, i32 %t.byte_count.read, i16 %.0, i32 %.1, i64 -1)
  %newret442 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret205, 0
  %newret443 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret205, 1
  %newret444 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret205, 2
  %newret445 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret205, 3
  %newret446 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret205, 4
  %newret447 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret205, 5
  %newret448 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret205, 6
  %newret449 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret205, 7
  %newret450 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret205, 8
  br label %cleanup773

cleanup773:                                       ; preds = %if.end761, %if.then748, %if.then619, %if.then592, %if.then585, %if.then563, %if.then486, %if.then482, %if.end426, %if.then356, %if.then335, %if.then328, %if.then311, %if.then249, %if.end204, %if.then174, %if.then160, %if.then131, %if.then87, %if.then71, %if.end95.i, %if.end
  %agg.result.0.10 = phi i16 [ %newret195, %if.end ], [ %newret231, %if.then87 ], [ %newret310, %if.then482 ], [ %newret324, %if.then486 ], [ %newret213, %if.then71 ], [ %agg.result.0.ret, %if.end95.i ], [ %newret249, %if.then131 ], [ %newret267, %if.then160 ], [ %newret303, %if.end204 ], [ %newret285, %if.then174 ], [ %newret292, %if.then249 ], [ %newret357, %if.then328 ], [ %newret375, %if.then335 ], [ %newret339, %if.then311 ], [ %newret411, %if.end426 ], [ %newret393, %if.then356 ], [ %newret, %if.then585 ], [ %newret402, %if.then592 ], [ %newret348, %if.then563 ], [ %newret420, %if.then619 ], [ %newret433, %if.then748 ], [ %newret442, %if.end761 ]
  %agg.result.1.10 = phi i32 [ %newret197, %if.end ], [ %newret233, %if.then87 ], [ %newret312, %if.then482 ], [ %newret325, %if.then486 ], [ %newret215, %if.then71 ], [ %agg.result.1.ret, %if.end95.i ], [ %newret251, %if.then131 ], [ %newret269, %if.then160 ], [ %newret305, %if.end204 ], [ %newret287, %if.then174 ], [ %newret294, %if.then249 ], [ %newret359, %if.then328 ], [ %newret377, %if.then335 ], [ %newret341, %if.then311 ], [ %newret413, %if.end426 ], [ %newret395, %if.then356 ], [ %newret386, %if.then585 ], [ %newret404, %if.then592 ], [ %newret350, %if.then563 ], [ %newret422, %if.then619 ], [ %newret434, %if.then748 ], [ %newret443, %if.end761 ]
  %agg.result.2.10 = phi i64 [ %newret199, %if.end ], [ %newret235, %if.then87 ], [ %newret314, %if.then482 ], [ %newret326, %if.then486 ], [ %newret217, %if.then71 ], [ %agg.result.2.ret, %if.end95.i ], [ %newret253, %if.then131 ], [ %newret271, %if.then160 ], [ %newret307, %if.end204 ], [ %newret289, %if.then174 ], [ %newret296, %if.then249 ], [ %newret361, %if.then328 ], [ %newret379, %if.then335 ], [ %newret343, %if.then311 ], [ %newret415, %if.end426 ], [ %newret397, %if.then356 ], [ %newret388, %if.then585 ], [ %newret406, %if.then592 ], [ %newret352, %if.then563 ], [ %newret424, %if.then619 ], [ %newret435, %if.then748 ], [ %newret444, %if.end761 ]
  %done_task_id.10 = phi i32 [ %newret201, %if.end ], [ %newret237, %if.then87 ], [ %newret316, %if.then482 ], [ %newret327, %if.then486 ], [ %newret219, %if.then71 ], [ %done_task_id.ret, %if.end95.i ], [ %newret255, %if.then131 ], [ %newret273, %if.then160 ], [ %newret309, %if.end204 ], [ %newret291, %if.then174 ], [ %newret298, %if.then249 ], [ %newret363, %if.then328 ], [ %newret381, %if.then335 ], [ %newret345, %if.then311 ], [ %newret417, %if.end426 ], [ %newret399, %if.then356 ], [ %newret390, %if.then585 ], [ %newret408, %if.then592 ], [ %newret354, %if.then563 ], [ %newret426, %if.then619 ], [ %newret436, %if.then748 ], [ %newret445, %if.end761 ]
  %done_status.10 = phi i16 [ %newret203, %if.end ], [ %newret239, %if.then87 ], [ %newret318, %if.then482 ], [ %newret328, %if.then486 ], [ %newret221, %if.then71 ], [ %done_status.ret, %if.end95.i ], [ %newret257, %if.then131 ], [ %newret275, %if.then160 ], [ %newret311, %if.end204 ], [ %newret293, %if.then174 ], [ %newret300, %if.then249 ], [ %newret365, %if.then328 ], [ %newret383, %if.then335 ], [ %newret347, %if.then311 ], [ %newret419, %if.end426 ], [ %newret401, %if.then356 ], [ %newret392, %if.then585 ], [ %newret410, %if.then592 ], [ %newret356, %if.then563 ], [ %newret428, %if.then619 ], [ %newret437, %if.then748 ], [ %newret446, %if.end761 ]
  %done_error_detail.10 = phi i32 [ %newret205, %if.end ], [ %newret241, %if.then87 ], [ %newret320, %if.then482 ], [ %newret329, %if.then486 ], [ %newret223, %if.then71 ], [ %done_error_detail.ret, %if.end95.i ], [ %newret259, %if.then131 ], [ %newret277, %if.then160 ], [ %newret313, %if.end204 ], [ %newret295, %if.then174 ], [ %newret302, %if.then249 ], [ %newret367, %if.then328 ], [ %newret385, %if.then335 ], [ %newret349, %if.then311 ], [ %newret421, %if.end426 ], [ %newret403, %if.then356 ], [ %newret394, %if.then585 ], [ %newret412, %if.then592 ], [ %newret358, %if.then563 ], [ %newret429, %if.then619 ], [ %newret438, %if.then748 ], [ %newret447, %if.end761 ]
  %done_bad_element.10 = phi i64 [ %newret207, %if.end ], [ %newret243, %if.then87 ], [ %newret321, %if.then482 ], [ %newret330, %if.then486 ], [ %newret225, %if.then71 ], [ %done_bad_element.ret, %if.end95.i ], [ %newret261, %if.then131 ], [ %newret279, %if.then160 ], [ %newret315, %if.end204 ], [ %newret297, %if.then174 ], [ %newret304, %if.then249 ], [ %newret369, %if.then328 ], [ %newret387, %if.then335 ], [ %newret351, %if.then311 ], [ %newret423, %if.end426 ], [ %newret405, %if.then356 ], [ %newret396, %if.then585 ], [ %newret414, %if.then592 ], [ %newret360, %if.then563 ], [ %newret430, %if.then619 ], [ %newret439, %if.then748 ], [ %newret448, %if.end761 ]
  %done_output_elements.10 = phi i32 [ %newret209, %if.end ], [ %newret245, %if.then87 ], [ %newret322, %if.then482 ], [ %newret331, %if.then486 ], [ %newret227, %if.then71 ], [ %done_output_elements.ret, %if.end95.i ], [ %newret263, %if.then131 ], [ %newret281, %if.then160 ], [ %newret317, %if.end204 ], [ %newret299, %if.then174 ], [ %newret306, %if.then249 ], [ %newret371, %if.then328 ], [ %newret389, %if.then335 ], [ %newret353, %if.then311 ], [ %newret425, %if.end426 ], [ %newret407, %if.then356 ], [ %newret398, %if.then585 ], [ %newret416, %if.then592 ], [ %newret362, %if.then563 ], [ %newret431, %if.then619 ], [ %newret440, %if.then748 ], [ %newret449, %if.end761 ]
  %done_output_unit.10 = phi i8 [ %newret211, %if.end ], [ %newret247, %if.then87 ], [ %newret323, %if.then482 ], [ %newret332, %if.then486 ], [ %newret229, %if.then71 ], [ %done_output_unit.ret, %if.end95.i ], [ %newret265, %if.then131 ], [ %newret283, %if.then160 ], [ %newret319, %if.end204 ], [ %newret301, %if.then174 ], [ %newret308, %if.then249 ], [ %newret373, %if.then328 ], [ %newret391, %if.then335 ], [ %newret355, %if.then311 ], [ %newret427, %if.end426 ], [ %newret409, %if.then356 ], [ %newret400, %if.then585 ], [ %newret418, %if.then592 ], [ %newret364, %if.then563 ], [ %newret432, %if.then619 ], [ %newret441, %if.then748 ], [ %newret450, %if.end761 ]
  %done_drained.10 = phi i1 [ true, %if.end ], [ true, %if.then87 ], [ true, %if.then482 ], [ true, %if.then486 ], [ true, %if.then71 ], [ %done_drained.ret, %if.end95.i ], [ true, %if.then131 ], [ true, %if.then160 ], [ true, %if.end204 ], [ true, %if.then174 ], [ true, %if.then249 ], [ true, %if.then328 ], [ true, %if.then335 ], [ true, %if.then311 ], [ true, %if.end426 ], [ true, %if.then356 ], [ true, %if.then585 ], [ true, %if.then592 ], [ true, %if.then563 ], [ true, %if.then619 ], [ true, %if.then748 ], [ true, %if.end761 ]
  %mrv = insertvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8, i1 } undef, i16 %agg.result.0.10, 0
  %mrv.1 = insertvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8, i1 } %mrv, i32 %agg.result.1.10, 1
  %mrv.2 = insertvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8, i1 } %mrv.1, i64 %agg.result.2.10, 2
  %mrv.3 = insertvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8, i1 } %mrv.2, i32 %done_task_id.10, 3
  %mrv.4 = insertvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8, i1 } %mrv.3, i16 %done_status.10, 4
  %mrv.5 = insertvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8, i1 } %mrv.4, i32 %done_error_detail.10, 5
  %mrv.6 = insertvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8, i1 } %mrv.5, i64 %done_bad_element.10, 6
  %mrv.7 = insertvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8, i1 } %mrv.6, i32 %done_output_elements.10, 7
  %mrv.8 = insertvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8, i1 } %mrv.7, i8 %done_output_unit.10, 8
  %mrv.9 = insertvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8, i1 } %mrv.8, i1 %done_drained.10, 9
  ret { i16, i32, i64, i32, i16, i32, i64, i32, i8, i1 } %mrv.9
}
