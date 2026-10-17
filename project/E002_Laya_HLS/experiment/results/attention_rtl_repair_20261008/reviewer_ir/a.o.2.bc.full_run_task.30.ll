define internal fastcc { i16, i32, i64, i32, i16, i32, i64, i32, i8, i1 } @"laya::full::full_run_task.30"(i8 addrspace(1)* noalias nocapture %embedding, i64 %memory_embedding, i8 addrspace(1)* noalias nocapture %io, i64 %memory_io, i8 addrspace(1)* noalias nocapture %w_q0, i64 %memory_w_q0, i8 addrspace(1)* noalias nocapture %w_q1, i64 %memory_w_q1, i8 addrspace(1)* noalias nocapture %w_scale, i64 %memory_w_scale, i8 addrspace(1)* noalias nocapture %aux, i64 %memory_aux, i8 addrspace(1)* noalias nocapture %state0, i64 %memory_state0, i8 addrspace(1)* noalias nocapture %state1, i64 %memory_state1, i8 addrspace(1)* noalias nocapture %qkv0, i64 %memory_qkv0, i8 addrspace(1)* noalias nocapture %qkv1, i64 %memory_qkv1, i8 addrspace(1)* noalias nocapture %ff0, i64 %memory_ff0, i8 addrspace(1)* noalias nocapture %ff1, i64 %memory_ff1, i8 addrspace(1)* noalias nocapture %att_out, i64 %memory_att_out, i32 %t.ctx.task_id.read, i8 %t.ctx.op.read, i3 %t_ctx_stage.val, i6 %t_ctx_layer.val, i2 %t_kind.val, i8 %t_dst_id.val, i8 %t_dst_bank.val, i32 %t_dst_epoch.val, i4 %t_weight_family.val, i6 %t_weight_layer.val, i5 %t_head.val, i1 %t_planes.val, i32 %t.byte_count.read) #1 {
entry:
  %t_dst_bank.val.cast = trunc i8 %t_dst_bank.val to i1
  %t_weight_family.val.cast = zext i4 %t_weight_family.val to i5
  %t_ctx_layer.val.cast = sext i6 %t_ctx_layer.val to i8
  %t_ctx_stage.val.cast = zext i3 %t_ctx_stage.val to i8
  %cond = icmp slt i8 %t.ctx.op.read, 0
  %cond148 = icmp ult i8 %t.ctx.op.read, -124
  %cond149 = and i1 %cond148, %cond
  call void (...) @_ssdm_Assume(i1 %cond149) #1
  %cond150 = icmp ne i3 %t_ctx_stage.val, 0
  %cond151 = icmp ne i3 %t_ctx_stage.val, -1
  %cond152 = and i1 %cond151, %cond150
  call void (...) @_ssdm_Assume(i1 %cond152) #1
  %cond153 = icmp sgt i6 %t_ctx_layer.val, -2
  %cond154 = icmp slt i6 %t_ctx_layer.val, 28
  %cond155 = and i1 %cond154, %cond153
  call void (...) @_ssdm_Assume(i1 %cond155) #1
  call void (...) @_ssdm_Assume(i1 true) #1
  %cond157 = icmp ult i4 %t_weight_family.val, -3
  call void (...) @_ssdm_Assume(i1 %cond157) #1
  %cond158 = icmp sgt i6 %t_weight_layer.val, -2
  %cond159 = icmp slt i6 %t_weight_layer.val, 28
  %cond160 = and i1 %cond159, %cond158
  call void (...) @_ssdm_Assume(i1 %cond160) #1
  %cond161 = icmp sgt i5 %t_head.val, -2
  call void (...) @_ssdm_Assume(i1 %cond161) #1
  call void (...) @_ssdm_Assume(i1 true) #1
  %cond165 = icmp ult i32 %t.byte_count.read, -15
  call void (...) @_ssdm_Assume(i1 %cond165) #1
  call void (...) @_ssdm_Assume(i1 true) #1
  call void (...) @_ssdm_Assume(i1 true) #1
  call void (...) @_ssdm_Assume(i1 true) #1
  call void (...) @_ssdm_Assume(i1 true) #1
  call void (...) @_ssdm_Assume(i1 true) #1
  call void (...) @_ssdm_Assume(i1 true) #1
  call void (...) @_ssdm_Assume(i1 true) #1
  call void (...) @_ssdm_op_SpecInterface(i8 addrspace(1)* %att_out, [6 x i8]* @26, i32 0, i32 0, [1 x i8]* @38, i32 0, i32 0, [8 x i8]* @163, [6 x i8]* @100, [1 x i8]* @38, i32 1, i32 1, i32 16, i32 16, [1 x i8]* @38, [1 x i8]* @38, i32 -1, i32 0, i32 0, i32 1)
  call void (...) @_ssdm_op_SpecInterface(i8 addrspace(1)* %ff1, [6 x i8]* @26, i32 0, i32 0, [1 x i8]* @38, i32 0, i32 0, [4 x i8]* @117, [6 x i8]* @100, [1 x i8]* @38, i32 1, i32 1, i32 16, i32 16, [1 x i8]* @38, [1 x i8]* @38, i32 -1, i32 0, i32 0, i32 1)
  call void (...) @_ssdm_op_SpecInterface(i8 addrspace(1)* %ff0, [6 x i8]* @26, i32 0, i32 0, [1 x i8]* @38, i32 0, i32 0, [4 x i8]* @218, [6 x i8]* @100, [1 x i8]* @38, i32 1, i32 1, i32 16, i32 16, [1 x i8]* @38, [1 x i8]* @38, i32 -1, i32 0, i32 0, i32 1)
  call void (...) @_ssdm_op_SpecInterface(i8 addrspace(1)* %qkv1, [6 x i8]* @26, i32 0, i32 0, [1 x i8]* @38, i32 0, i32 0, [5 x i8]* @99, [6 x i8]* @100, [1 x i8]* @38, i32 1, i32 1, i32 16, i32 16, [1 x i8]* @38, [1 x i8]* @38, i32 -1, i32 0, i32 0, i32 1)
  call void (...) @_ssdm_op_SpecInterface(i8 addrspace(1)* %qkv0, [6 x i8]* @26, i32 0, i32 0, [1 x i8]* @38, i32 0, i32 0, [5 x i8]* @108, [6 x i8]* @100, [1 x i8]* @38, i32 1, i32 1, i32 16, i32 16, [1 x i8]* @38, [1 x i8]* @38, i32 -1, i32 0, i32 0, i32 1)
  call void (...) @_ssdm_op_SpecInterface(i8 addrspace(1)* %state1, [6 x i8]* @26, i32 0, i32 0, [1 x i8]* @38, i32 0, i32 0, [7 x i8]* @114, [6 x i8]* @100, [1 x i8]* @38, i32 1, i32 1, i32 16, i32 16, [1 x i8]* @38, [1 x i8]* @38, i32 -1, i32 0, i32 0, i32 1)
  call void (...) @_ssdm_op_SpecInterface(i8 addrspace(1)* %state0, [6 x i8]* @26, i32 0, i32 0, [1 x i8]* @38, i32 0, i32 0, [7 x i8]* @113, [6 x i8]* @100, [1 x i8]* @38, i32 1, i32 1, i32 16, i32 16, [1 x i8]* @38, [1 x i8]* @38, i32 -1, i32 0, i32 0, i32 1)
  call void (...) @_ssdm_op_SpecInterface(i8 addrspace(1)* %aux, [6 x i8]* @26, i32 0, i32 0, [1 x i8]* @38, i32 0, i32 0, [4 x i8]* @105, [6 x i8]* @100, [1 x i8]* @38, i32 1, i32 16, i32 16, i32 16, [1 x i8]* @38, [1 x i8]* @38, i32 -1, i32 0, i32 0, i32 1)
  call void (...) @_ssdm_op_SpecInterface(i8 addrspace(1)* %w_scale, [6 x i8]* @26, i32 0, i32 0, [1 x i8]* @38, i32 0, i32 0, [8 x i8]* @50, [6 x i8]* @100, [1 x i8]* @38, i32 1, i32 16, i32 16, i32 16, [1 x i8]* @38, [1 x i8]* @38, i32 -1, i32 0, i32 0, i32 1)
  call void (...) @_ssdm_op_SpecInterface(i8 addrspace(1)* %w_q1, [6 x i8]* @26, i32 0, i32 0, [1 x i8]* @38, i32 0, i32 0, [5 x i8]* @103, [6 x i8]* @100, [1 x i8]* @38, i32 1, i32 16, i32 16, i32 16, [1 x i8]* @38, [1 x i8]* @38, i32 -1, i32 0, i32 0, i32 1)
  call void (...) @_ssdm_op_SpecInterface(i8 addrspace(1)* %w_q0, [6 x i8]* @26, i32 0, i32 0, [1 x i8]* @38, i32 0, i32 0, [5 x i8]* @159, [6 x i8]* @100, [1 x i8]* @38, i32 1, i32 16, i32 16, i32 16, [1 x i8]* @38, [1 x i8]* @38, i32 -1, i32 0, i32 0, i32 1)
  call void (...) @_ssdm_op_SpecInterface(i8 addrspace(1)* %io, [6 x i8]* @26, i32 0, i32 0, [1 x i8]* @38, i32 0, i32 0, [3 x i8]* @116, [6 x i8]* @100, [1 x i8]* @38, i32 1, i32 1, i32 16, i32 16, [1 x i8]* @38, [1 x i8]* @38, i32 -1, i32 0, i32 0, i32 1)
  call void (...) @_ssdm_op_SpecInterface(i8 addrspace(1)* %embedding, [6 x i8]* @26, i32 0, i32 0, [1 x i8]* @38, i32 0, i32 0, [10 x i8]* @160, [6 x i8]* @100, [1 x i8]* @38, i32 1, i32 16, i32 16, i32 16, [1 x i8]* @38, [1 x i8]* @38, i32 -1, i32 0, i32 0, i32 1)
  %raw = alloca [4 x i8], i64 1, align 512
  %raw.8 = alloca [4 x i8], i64 1, align 512
  %d.name = alloca [48 x i7], i64 1, align 1
  %d.q_base = alloca [2 x i28], i64 1, align 4
  %d.q_span = alloca [2 x i22], i64 1, align 4
  %d.source_sha256 = alloca [32 x i8], i64 1, align 512
  %d.bias_sha256 = alloca [32 x i8], i64 1, align 512
  %d.name.1 = alloca [48 x i7], i64 1, align 1
  %d.ne = alloca [4 x i15], i64 1, align 2
  %d.source_sha256.1 = alloca [32 x i8], i64 1, align 512
  %d.name.2 = alloca [2 x [48 x i7]], i64 1, align 1
  %d.ggml_type_id = alloca [2 x i8], i64 1, align 512
  %d.bo = alloca [2 x i8], i64 1, align 512
  %d.omitted = alloca [2 x i8], i64 1, align 512
  %d.reserved = alloca [2 x i8], i64 1, align 512
  %d.ne.1 = alloca [2 x [4 x i15]], i64 1, align 2
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
  %"(anonymous namespace)::runtime.request_valid.load" = load i1, i1* @"(anonymous namespace)::runtime.request_valid", align 512, !alias.scope !3112, !noalias !3115
  %icmp.ln259 = icmp ne i8 %t_dst_bank.val, 0
  br i1 %"(anonymous namespace)::runtime.request_valid.load", label %land.lhs.true.i, label %cond.false

land.lhs.true.i:                                  ; preds = %entry
  %"(anonymous namespace)::runtime.model_header_valid.load" = load i1, i1* @"(anonymous namespace)::runtime.model_header_valid", align 512, !alias.scope !3112, !noalias !3115
  br i1 %"(anonymous namespace)::runtime.model_header_valid.load", label %land.lhs.true1.i, label %cond.false

land.lhs.true1.i:                                 ; preds = %land.lhs.true.i
  %"(anonymous namespace)::runtime.last_task_id.load" = load i32, i32* @"(anonymous namespace)::runtime.last_task_id", align 512, !alias.scope !3112, !noalias !3115
  %add.ln239 = add i32 %"(anonymous namespace)::runtime.last_task_id.load", 1
  %icmp.ln239 = icmp eq i32 %add.ln239, %t.ctx.task_id.read
  %icmp.ln240 = icmp ne i32 %t.ctx.task_id.read, -1
  %and.ln239 = and i1 %icmp.ln239, %icmp.ln240
  br i1 %and.ln239, label %cond.true, label %cond.false

cond.true:                                        ; preds = %land.lhs.true1.i
  %"(anonymous namespace)::runtime.inputs.identity.B.load" = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.B", align 512
  %"(anonymous namespace)::runtime.inputs.identity.S.load" = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.S", align 512
  %call.ret = call fastcc { i16, i32 } @"laya::check_context"(i32 %t.ctx.task_id.read, i8 %t.ctx.op.read, i8 %t_ctx_stage.val.cast, i8 %t_ctx_layer.val.cast, i8 0, i8 2, i16 0, i8 1, i16 %"(anonymous namespace)::runtime.inputs.identity.B.load", i16 %"(anonymous namespace)::runtime.inputs.identity.S.load")
  %c.code = extractvalue { i16, i32 } %call.ret, 0
  %c.detail = extractvalue { i16, i32 } %call.ret, 1
  br label %cond.end

cond.false:                                       ; preds = %land.lhs.true1.i, %land.lhs.true.i, %entry
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %c.detail.0 = phi i32 [ %c.detail, %cond.true ], [ 67108868, %cond.false ]
  %c.code.0 = phi i16 [ %c.code, %cond.true ], [ 5, %cond.false ]
  %trunc.ln9 = trunc i16 %c.code.0 to i4
  %icmp.ln9.157 = icmp eq i16 %c.code.0, 0
  br i1 %icmp.ln9.157, label %lor.lhs.false4, label %if.end

lor.lhs.false4:                                   ; preds = %cond.end
  %zext.ln249 = zext i2 %t_kind.val to i8
  %or.ln249 = or i8 %zext.ln249, -128
  %icmp.ln249 = icmp eq i8 %or.ln249, %t.ctx.op.read
  br i1 %icmp.ln249, label %lor.rhs_ifconv, label %if.then25

lor.rhs_ifconv:                                   ; preds = %lor.lhs.false4
  %icmp.ln35 = icmp eq i8 %t_dst_id.val, 0
  %icmp.ln35.3 = icmp eq i32 %t_dst_epoch.val, 0
  %icmp.ln35.4 = icmp eq i8 %t_dst_bank.val, 0
  %and.ln35 = and i1 %icmp.ln35.4, %icmp.ln35.3
  %select.ln35 = select i1 %and.ln35, i3 0, i3 -3
  %add.ln39 = add i8 %t_dst_id.val, -32
  %icmp.ln39 = icmp ult i8 %add.ln39, 12
  %icmp.ln39.2 = icmp ne i8 %t_dst_id.val, 42
  %icmp.ln39.3 = icmp ne i8 %t_dst_id.val, 43
  %and.ln39 = and i1 %icmp.ln39.2, %icmp.ln39.3
  %and.ln39.1 = and i1 %and.ln39, %icmp.ln39
  %icmp.ln39.4 = icmp eq i8 %t_dst_id.val, 1
  %icmp.ln39.5 = icmp eq i8 %t_dst_id.val, 5
  %or.ln39 = or i1 %icmp.ln39.4, %icmp.ln39.5
  %dual = or i1 %or.ln39, %and.ln39.1
  %add.ln40 = add i8 %t_dst_id.val, -42
  %icmp.ln40 = icmp ult i8 %add.ln40, 2
  %dual.1 = or i1 %icmp.ln40, %dual
  %zext.ln41 = zext i1 %dual.1 to i8
  %icmp.ln41 = icmp ult i8 %zext.ln41, %t_dst_bank.val
  %select.ln41 = select i1 %icmp.ln41, i3 -3, i3 0
  %icmp.ln36 = icmp eq i32 %t_dst_epoch.val, -1
  %icmp.ln37 = icmp ugt i8 %t_dst_id.val, 11
  %icmp.ln37.2 = icmp ult i8 %t_dst_id.val, 32
  %icmp.ln37.3 = icmp ugt i8 %t_dst_id.val, 43
  %or.ln37 = or i1 %icmp.ln37.3, %icmp.ln37.2
  %and.ln37 = and i1 %icmp.ln37, %or.ln37
  %or.ln37.1 = or i1 %icmp.ln35.3, %and.ln37
  %or.ln37.2 = or i1 %or.ln37.1, %icmp.ln36
  %xor.ln35 = xor i1 %icmp.ln35, true
  %and.ln37.1 = and i1 %or.ln37.2, %xor.ln35
  %sel_tmp = call i2 @_ssdm_op_BitConcatenate.i2.i1.i1(i1 %icmp.ln35, i1 %and.ln37.1)
  %ref.tmp.0.1 = call i3 @_ssdm_op_SparseMux.ap_auto.3i3.i3.i2(i2 -2, i3 %select.ln35, i2 1, i3 -3, i2 0, i3 %select.ln41, i3 undef, i2 %sel_tmp)
  %icmp.ln9.158 = icmp eq i3 %ref.tmp.0.1, 0
  br i1 %icmp.ln9.158, label %if.end29, label %if.then25

if.then25:                                        ; preds = %lor.rhs_ifconv, %lor.lhs.false4
  %zext.ln11 = zext i8 %t_dst_id.val to i24
  %shl.ln11 = shl nuw i24 %zext.ln11, 16
  %zext.ln11.102 = zext i24 %shl.ln11 to i27
  %c.detail.189 = or i27 %zext.ln11.102, -67108859
  %zext.ln252 = zext i27 %c.detail.189 to i32
  br label %if.end

if.end:                                           ; preds = %if.then25, %cond.end
  %c.detail.1 = phi i32 [ %zext.ln252, %if.then25 ], [ %c.detail.0, %cond.end ]
  %.0430 = phi i4 [ 5, %if.then25 ], [ %trunc.ln9, %cond.end ]
  %call.ret153 = call fastcc { i16, i32, i32, i16, i32, i32, i8 } @"laya::full::(anonymous namespace)::finish_load"(i32 %t.ctx.task_id.read, i8 %t.ctx.op.read, i32 %t.byte_count.read, i4 %.0430, i32 %c.detail.1)
  %newret = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret153, 0
  %newret277 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret153, 1
  %newret279 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret153, 2
  %newret281 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret153, 3
  %newret283 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret153, 4
  %newret285 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret153, 5
  %newret287 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret153, 6
  br label %cleanup773

if.end29:                                         ; preds = %lor.rhs_ifconv
  %icmp.ln255 = icmp eq i2 %t_kind.val, 0
  br i1 %icmp.ln255, label %arrayinit.body.i.preheader, label %if.end79

arrayinit.body.i.preheader:                       ; preds = %if.end29
  br label %arrayinit.body.i

arrayinit.body.i:                                 ; preds = %arrayinit.body.i, %arrayinit.body.i.preheader
  %arrayinit.curidx.i = phi i6 [ %add.ln52, %arrayinit.body.i ], [ 0, %arrayinit.body.i.preheader ]
  %zext.ln52 = zext i6 %arrayinit.curidx.i to i64
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 48, i64 48, i64 48), !fpga.pragma.source !169
  %d.name.addr = getelementptr [48 x i7], [48 x i7]* %d.name, i64 0, i64 %zext.ln52
  %add.ln52 = add nuw i6 %arrayinit.curidx.i, 1
  store i7 0, i7* %d.name.addr, align 1, !alias.scope !3117, !noalias !3120
  %icmp.ln52 = icmp eq i6 %arrayinit.curidx.i, -17
  br i1 %icmp.ln52, label %arrayinit.body3.i.preheader, label %arrayinit.body.i, !llvm.loop !3137

arrayinit.body3.i.preheader:                      ; preds = %arrayinit.body.i
  br label %arrayinit.body3.i

arrayinit.body3.i:                                ; preds = %arrayinit.body3.i, %arrayinit.body3.i.preheader
  %arrayinit.curidx4.i = phi i1 [ %xor.ln56, %arrayinit.body3.i ], [ false, %arrayinit.body3.i.preheader ]
  %zext.ln56 = zext i1 %arrayinit.curidx4.i to i64
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 2, i64 2, i64 2), !fpga.pragma.source !169
  %d.q_base.addr = getelementptr [2 x i28], [2 x i28]* %d.q_base, i64 0, i64 %zext.ln56
  %xor.ln56 = xor i1 %arrayinit.curidx4.i, true
  store i28 0, i28* %d.q_base.addr, align 4, !alias.scope !3138, !noalias !3139
  br i1 %arrayinit.curidx4.i, label %arrayinit.body10.i.preheader, label %arrayinit.body3.i, !llvm.loop !3140

arrayinit.body10.i.preheader:                     ; preds = %arrayinit.body3.i
  br label %arrayinit.body10.i

arrayinit.body10.i:                               ; preds = %arrayinit.body10.i, %arrayinit.body10.i.preheader
  %arrayinit.curidx11.i = phi i1 [ %xor.ln56.3, %arrayinit.body10.i ], [ false, %arrayinit.body10.i.preheader ]
  %zext.ln56.4 = zext i1 %arrayinit.curidx11.i to i64
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 2, i64 2, i64 2), !fpga.pragma.source !169
  %d.q_span.addr = getelementptr [2 x i22], [2 x i22]* %d.q_span, i64 0, i64 %zext.ln56.4
  %xor.ln56.3 = xor i1 %arrayinit.curidx11.i, true
  store i22 0, i22* %d.q_span.addr, align 4, !alias.scope !3141, !noalias !3142
  br i1 %arrayinit.curidx11.i, label %arrayinit.body17.i.preheader, label %arrayinit.body10.i, !llvm.loop !3143

arrayinit.body17.i.preheader:                     ; preds = %arrayinit.body10.i
  br label %arrayinit.body17.i

arrayinit.body17.i:                               ; preds = %arrayinit.body17.i, %arrayinit.body17.i.preheader
  %arrayinit.curidx18.i = phi i5 [ %add.ln60, %arrayinit.body17.i ], [ 0, %arrayinit.body17.i.preheader ]
  %zext.ln60 = zext i5 %arrayinit.curidx18.i to i64
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 32, i64 32, i64 32), !fpga.pragma.source !169
  %d.source_sha256.addr = getelementptr [32 x i8], [32 x i8]* %d.source_sha256, i64 0, i64 %zext.ln60
  %add.ln60 = add i5 %arrayinit.curidx18.i, 1
  store i8 0, i8* %d.source_sha256.addr, align 1, !alias.scope !3144, !noalias !3145
  %icmp.ln60 = icmp eq i5 %arrayinit.curidx18.i, -1
  br i1 %icmp.ln60, label %arrayinit.body24.i.preheader, label %arrayinit.body17.i, !llvm.loop !3146

arrayinit.body24.i.preheader:                     ; preds = %arrayinit.body17.i
  br label %arrayinit.body24.i

arrayinit.body24.i:                               ; preds = %arrayinit.body24.i, %arrayinit.body24.i.preheader
  %arrayinit.curidx25.i = phi i5 [ %add.ln61, %arrayinit.body24.i ], [ 0, %arrayinit.body24.i.preheader ]
  %zext.ln61 = zext i5 %arrayinit.curidx25.i to i64
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 32, i64 32, i64 32), !fpga.pragma.source !169
  %d.bias_sha256.addr = getelementptr [32 x i8], [32 x i8]* %d.bias_sha256, i64 0, i64 %zext.ln61
  %add.ln61 = add i5 %arrayinit.curidx25.i, 1
  store i8 0, i8* %d.bias_sha256.addr, align 1, !alias.scope !3147, !noalias !3148
  %icmp.ln61 = icmp eq i5 %arrayinit.curidx25.i, -1
  br i1 %icmp.ln61, label %_ZN4laya4full20FullWeightDescriptorC2Ev.exit, label %arrayinit.body24.i, !llvm.loop !3149

_ZN4laya4full20FullWeightDescriptorC2Ev.exit:     ; preds = %arrayinit.body24.i
  %call.ret158 = call fastcc { i16, i32, i8, i8, i16, i16, i8, i8, i32, i32, i32, i32, i32, i32 } @"laya::full::full_lookup_weight"(i4 %t_weight_family.val, i6 %t_weight_layer.val, [48 x i7]* %d.name, [2 x i28]* %d.q_base, [2 x i22]* %d.q_span, [32 x i8]* %d.source_sha256, [32 x i8]* %d.bias_sha256)
  %c.code.175 = extractvalue { i16, i32, i8, i8, i16, i16, i8, i8, i32, i32, i32, i32, i32, i32 } %call.ret158, 0
  %d.K = extractvalue { i16, i32, i8, i8, i16, i16, i8, i8, i32, i32, i32, i32, i32, i32 } %call.ret158, 4
  %d.N = extractvalue { i16, i32, i8, i8, i16, i16, i8, i8, i32, i32, i32, i32, i32, i32 } %call.ret158, 5
  %d.dtype = extractvalue { i16, i32, i8, i8, i16, i16, i8, i8, i32, i32, i32, i32, i32, i32 } %call.ret158, 6
  %icmp.ln258.2 = icmp ne i16 %c.code.175, 0
  %icmp.ln258 = icmp ne i8 %d.dtype, 8
  %or.ln258 = or i1 %icmp.ln258, %icmp.ln258.2
  br i1 %or.ln258, label %if.then71, label %lor.lhs.false40

lor.lhs.false40:                                  ; preds = %_ZN4laya4full20FullWeightDescriptorC2Ev.exit
  %icmp.ln258.1 = icmp ne i8 %t_dst_id.val, 35
  %or.ln258.1 = or i1 %icmp.ln258.1, %icmp.ln259
  br i1 %or.ln258.1, label %if.then71, label %lor.lhs.false48

lor.lhs.false48:                                  ; preds = %lor.lhs.false40
  %icmp.ln259.1 = icmp ne i5 %t_head.val, -1
  %or.ln259 = or i1 %icmp.ln259.1, %t_planes.val
  br i1 %or.ln259, label %if.then71, label %lor.lhs.false54

lor.lhs.false54:                                  ; preds = %lor.lhs.false48
  %zext.ln261 = zext i16 %d.N to i17
  %lshr.ln261 = lshr i16 %d.K, 5
  %zext.ln260 = zext i16 %lshr.ln261 to i32
  %add.ln260 = add nuw i17 %zext.ln261, 7
  %and.ln260 = and i17 %add.ln260, -8
  %zext.ln261.1 = zext i17 %and.ln260 to i23
  %mul.ln261.1 = mul i23 %zext.ln261.1, 34
  %zext.ln261.2 = zext i23 %mul.ln261.1 to i32
  %mul.ln261 = mul i32 %zext.ln261.2, %zext.ln260
  %icmp.ln260 = icmp eq i32 %mul.ln261, %t.byte_count.read
  br i1 %icmp.ln260, label %lor.rhs60, label %if.then71

lor.rhs60:                                        ; preds = %lor.lhs.false54
  %add.ln48 = add i5 %t_weight_family.val.cast, -1
  %icmp.ln48 = icmp ugt i5 %add.ln48, 11
  br i1 %icmp.ln48, label %_ZN4laya12check_weightENS_9WeightKeyEhhttb.exit, label %if.end.i180

if.end.i180:                                      ; preds = %lor.rhs60
  switch i4 %t_weight_family.val, label %sw.epilog.i [
    i4 1, label %sw.bb.i
    i4 5, label %sw.bb.i
    i4 2, label %sw.bb4.i
    i4 6, label %sw.bb4.i
    i4 3, label %sw.bb5.i
    i4 4, label %sw.bb6.i
    i4 7, label %sw.bb7.i
    i4 -8, label %sw.bb8.i
    i4 -7, label %sw.bb9.i
    i4 -6, label %sw.bb10.i
    i4 -5, label %sw.bb11.i
    i4 -4, label %sw.bb12.i
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
  %ek = phi i13 [ 256, %sw.bb12.i ], [ 1028, %sw.bb11.i ], [ 1024, %sw.bb10.i ], [ 1024, %sw.bb9.i ], [ -4096, %sw.bb8.i ], [ 1024, %sw.bb7.i ], [ 2624, %sw.bb6.i ], [ 1024, %sw.bb5.i ], [ 1024, %sw.bb4.i ], [ 1024, %sw.bb.i ], [ 0, %if.end.i180 ]
  %en = phi i13 [ 2, %sw.bb12.i ], [ 256, %sw.bb11.i ], [ 1, %sw.bb10.i ], [ 1024, %sw.bb9.i ], [ 1024, %sw.bb8.i ], [ -4096, %sw.bb7.i ], [ 1024, %sw.bb6.i ], [ -2944, %sw.bb5.i ], [ 1024, %sw.bb4.i ], [ 3072, %sw.bb.i ], [ 0, %if.end.i180 ]
  %zext.ln49 = zext i13 %en to i16
  %zext.ln49.1 = zext i13 %ek to i16
  %icmp.ln51 = icmp ne i16 %d.K, %zext.ln49.1
  %icmp.ln51.5 = icmp ne i16 %d.N, %zext.ln49
  %or.ln51 = or i1 %icmp.ln51, %icmp.ln51.5
  br i1 %or.ln51, label %if.then71.critedge, label %lor.lhs.false20.i

lor.lhs.false20.i:                                ; preds = %sw.epilog.i
  %icmp.ln51.6 = icmp eq i4 %t_weight_family.val, -6
  %add.ln51 = add i5 %t_weight_family.val.cast, -10
  %icmp.ln51.7 = icmp ult i5 %add.ln51, 2
  br i1 %icmp.ln51.7, label %if.then71.critedge, label %if.end33.i187

if.end33.i187:                                    ; preds = %lor.lhs.false20.i
  %icmp.ln52.9 = icmp ult i4 %t_weight_family.val, 5
  br i1 %icmp.ln52.9, label %if.then36.i, label %if.else.i192

if.then36.i:                                      ; preds = %if.end33.i187
  %icmp.ln52.10 = icmp ne i3 %t_ctx_stage.val, 2
  %icmp.ln52.11 = icmp ugt i6 %t_ctx_layer.val, 27
  %icmp.ln52.12 = icmp ne i6 %t_weight_layer.val, %t_ctx_layer.val
  %or.ln52 = or i1 %icmp.ln52.11, %icmp.ln52.12
  %or.ln52.2 = or i1 %or.ln52, %icmp.ln52.10
  br i1 %or.ln52.2, label %_ZN4laya12check_weightENS_9WeightKeyEhhttb.exit, label %if.end95.i

if.else.i192:                                     ; preds = %if.end33.i187
  %icmp.ln53 = icmp ult i4 %t_weight_family.val, -7
  br i1 %icmp.ln53, label %if.then55.i, label %if.else72.i

if.then55.i:                                      ; preds = %if.else.i192
  %icmp.ln53.8 = icmp ne i3 %t_ctx_stage.val, -4
  %icmp.ln53.9 = icmp ugt i6 %t_ctx_layer.val, 1
  %icmp.ln53.10 = icmp ne i6 %t_weight_layer.val, %t_ctx_layer.val
  %or.ln53 = or i1 %icmp.ln53.9, %icmp.ln53.10
  %or.ln53.2 = or i1 %or.ln53, %icmp.ln53.8
  br i1 %or.ln53.2, label %_ZN4laya12check_weightENS_9WeightKeyEhhttb.exit, label %if.end94.i

if.else72.i:                                      ; preds = %if.else.i192
  %icmp.ln54 = icmp eq i6 %t_weight_layer.val, -1
  br i1 %icmp.ln54, label %lor.lhs.false76.i, label %if.then88.i

lor.lhs.false76.i:                                ; preds = %if.else72.i
  %icmp.ln54.4 = icmp eq i4 %t_weight_family.val, -7
  %or.ln54 = or i1 %icmp.ln54.4, %icmp.ln51.6
  %select.ln54 = select i1 %or.ln54, i3 -3, i3 -2
  %icmp.ln54.5 = icmp ne i3 %select.ln54, %t_ctx_stage.val
  %icmp.ln54.6 = icmp ne i6 %t_ctx_layer.val, -1
  %or.ln54.2 = or i1 %icmp.ln54.5, %icmp.ln54.6
  br i1 %or.ln54.2, label %if.then88.i, label %if.end94.i

if.then88.i:                                      ; preds = %lor.lhs.false76.i, %if.else72.i
  br label %_ZN4laya12check_weightENS_9WeightKeyEhhttb.exit

if.end94.i:                                       ; preds = %lor.lhs.false76.i, %if.then55.i
  br label %if.end95.i

if.end95.i:                                       ; preds = %if.end94.i, %if.then36.i
  %call.ret168 = call fastcc { i16, i32, i64, i32, i16, i32, i64, i32, i8, i1 } @"laya::full::full_load_weight"(i8 addrspace(1)* %embedding, i64 %memory_embedding, i8 addrspace(1)* %io, i64 %memory_io, i8 addrspace(1)* %w_q0, i64 %memory_w_q0, i8 addrspace(1)* %w_q1, i64 %memory_w_q1, i8 addrspace(1)* %w_scale, i64 %memory_w_scale, i8 addrspace(1)* %aux, i64 %memory_aux, i8 addrspace(1)* %state0, i64 %memory_state0, i8 addrspace(1)* %state1, i64 %memory_state1, i8 addrspace(1)* %qkv0, i64 %memory_qkv0, i8 addrspace(1)* %qkv1, i64 %memory_qkv1, i8 addrspace(1)* %ff0, i64 %memory_ff0, i8 addrspace(1)* %ff1, i64 %memory_ff1, i8 addrspace(1)* %att_out, i64 %memory_att_out, i4 %t_weight_family.val, i6 %t_weight_layer.val, i32 %t_dst_epoch.val)
  %agg.result.0.ret = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8, i1 } %call.ret168, 0
  %agg.result.1.ret = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8, i1 } %call.ret168, 1
  %agg.result.2.ret = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8, i1 } %call.ret168, 2
  %done_task_id.ret = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8, i1 } %call.ret168, 3
  %done_status.ret = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8, i1 } %call.ret168, 4
  %done_error_detail.ret = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8, i1 } %call.ret168, 5
  %done_bad_element.ret = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8, i1 } %call.ret168, 6
  %done_output_elements.ret = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8, i1 } %call.ret168, 7
  %done_output_unit.ret = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8, i1 } %call.ret168, 8
  %done_drained.ret = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8, i1 } %call.ret168, 9
  br label %cleanup773

_ZN4laya12check_weightENS_9WeightKeyEhhttb.exit:  ; preds = %if.then88.i, %if.then55.i, %if.then36.i, %lor.rhs60
  br label %if.then71

if.then71.critedge:                               ; preds = %lor.lhs.false20.i, %sw.epilog.i
  br label %if.then71

if.then71:                                        ; preds = %if.then71.critedge, %_ZN4laya12check_weightENS_9WeightKeyEhhttb.exit, %lor.lhs.false54, %lor.lhs.false48, %lor.lhs.false40, %_ZN4laya4full20FullWeightDescriptorC2Ev.exit
  %call.ret169 = call fastcc { i16, i32, i32, i16, i32, i32, i8 } @"laya::full::(anonymous namespace)::finish_load"(i32 %t.ctx.task_id.read, i8 %t.ctx.op.read, i32 %t.byte_count.read, i4 5, i32 69402629)
  %newret296 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret169, 0
  %newret304 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret169, 1
  %newret307 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret169, 2
  %newret309 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret169, 3
  %newret310 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret169, 4
  %newret311 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret169, 5
  %newret312 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret169, 6
  br label %cleanup773

if.end79:                                         ; preds = %if.end29
  %icmp.ln269 = icmp ne i4 %t_weight_family.val, 0
  %icmp.ln269.1 = icmp ne i6 %t_weight_layer.val, -1
  %or.ln269 = or i1 %icmp.ln269, %icmp.ln269.1
  br i1 %or.ln269, label %if.then87, label %if.end92

if.then87:                                        ; preds = %if.end79
  %zext.ln11.103 = zext i8 %t_dst_id.val to i24
  %shl.ln11.28 = shl nuw i24 %zext.ln11.103, 16
  %zext.ln11.104 = zext i24 %shl.ln11.28 to i27
  %c.detail.190 = or i27 %zext.ln11.104, -67108859
  %zext.ln270 = zext i27 %c.detail.190 to i32
  %call.ret154 = call fastcc { i16, i32, i32, i16, i32, i32, i8 } @"laya::full::(anonymous namespace)::finish_load"(i32 %t.ctx.task_id.read, i8 %t.ctx.op.read, i32 %t.byte_count.read, i4 5, i32 %zext.ln270)
  %newret278 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret154, 0
  %newret280 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret154, 1
  %newret282 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret154, 2
  %newret284 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret154, 3
  %newret286 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret154, 4
  %newret288 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret154, 5
  %newret289 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret154, 6
  br label %cleanup773

if.end92:                                         ; preds = %if.end79
  switch i2 %t_kind.val, label %if.end431 [
    i2 -2, label %if.then96
    i2 -1, label %if.then213
  ]

if.then96:                                        ; preds = %if.end92
  %bank = icmp ne i3 %t_ctx_stage.val, 1
  %zext.ln274 = zext i1 %bank to i8
  switch i3 %t_ctx_stage.val, label %if.then131 [
    i3 3, label %lor.lhs.false111
    i3 1, label %lor.lhs.false111
  ]

lor.lhs.false111:                                 ; preds = %if.then96, %if.then96
  %icmp.ln276 = icmp ne i8 %zext.ln274, %t_dst_bank.val
  %or.ln276 = or i1 %icmp.ln39.2, %icmp.ln276
  br i1 %or.ln276, label %if.then131, label %lor.lhs.false121

lor.lhs.false121:                                 ; preds = %lor.lhs.false111
  %icmp.ln277 = icmp ne i5 %t_head.val, -1
  %icmp.ln277.1 = icmp ne i32 %t.byte_count.read, 4096
  %or.ln277 = or i1 %icmp.ln277.1, %t_planes.val
  %or.ln277.1 = or i1 %or.ln277, %icmp.ln277
  br i1 %or.ln277.1, label %if.then131, label %arrayinit.body.i207.preheader

arrayinit.body.i207.preheader:                    ; preds = %lor.lhs.false121
  br label %arrayinit.body.i207

if.then131:                                       ; preds = %lor.lhs.false121, %lor.lhs.false111, %if.then96
  %call.ret156 = call fastcc { i16, i32, i32, i16, i32, i32, i8 } @"laya::full::(anonymous namespace)::finish_load"(i32 %t.ctx.task_id.read, i8 %t.ctx.op.read, i32 %t.byte_count.read, i4 5, i32 69861381)
  %newret264 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret156, 0
  %newret266 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret156, 1
  %newret268 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret156, 2
  %newret270 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret156, 3
  %newret272 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret156, 4
  %newret274 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret156, 5
  %newret276 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret156, 6
  br label %cleanup773

arrayinit.body.i207:                              ; preds = %arrayinit.body.i207, %arrayinit.body.i207.preheader
  %arrayinit.curidx.i203 = phi i6 [ %add.ln41, %arrayinit.body.i207 ], [ 0, %arrayinit.body.i207.preheader ]
  %zext.ln41.1 = zext i6 %arrayinit.curidx.i203 to i64
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 48, i64 48, i64 48), !fpga.pragma.source !169
  %d.name.1.addr = getelementptr [48 x i7], [48 x i7]* %d.name.1, i64 0, i64 %zext.ln41.1
  %add.ln41 = add nuw i6 %arrayinit.curidx.i203, 1
  store i7 0, i7* %d.name.1.addr, align 1, !alias.scope !3150, !noalias !3153
  %icmp.ln41.1 = icmp eq i6 %arrayinit.curidx.i203, -17
  br i1 %icmp.ln41.1, label %arrayinit.body3.i213.preheader, label %arrayinit.body.i207, !llvm.loop !3164

arrayinit.body3.i213.preheader:                   ; preds = %arrayinit.body.i207
  br label %arrayinit.body3.i213

arrayinit.body3.i213:                             ; preds = %arrayinit.body3.i213, %arrayinit.body3.i213.preheader
  %arrayinit.curidx4.i209 = phi i2 [ %add.ln43, %arrayinit.body3.i213 ], [ 0, %arrayinit.body3.i213.preheader ]
  %zext.ln43 = zext i2 %arrayinit.curidx4.i209 to i64
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 4, i64 4, i64 4), !fpga.pragma.source !169
  %d.ne.addr = getelementptr [4 x i15], [4 x i15]* %d.ne, i64 0, i64 %zext.ln43
  %add.ln43 = add i2 %arrayinit.curidx4.i209, 1
  store i15 0, i15* %d.ne.addr, align 2, !alias.scope !3165, !noalias !3166
  %icmp.ln43 = icmp eq i2 %arrayinit.curidx4.i209, -1
  br i1 %icmp.ln43, label %arrayinit.body10.i219.preheader, label %arrayinit.body3.i213, !llvm.loop !3167

arrayinit.body10.i219.preheader:                  ; preds = %arrayinit.body3.i213
  br label %arrayinit.body10.i219

arrayinit.body10.i219:                            ; preds = %arrayinit.body10.i219, %arrayinit.body10.i219.preheader
  %arrayinit.curidx11.i215 = phi i5 [ %add.ln46, %arrayinit.body10.i219 ], [ 0, %arrayinit.body10.i219.preheader ]
  %zext.ln46 = zext i5 %arrayinit.curidx11.i215 to i64
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 32, i64 32, i64 32), !fpga.pragma.source !169
  %d.source_sha256.1.addr = getelementptr [32 x i8], [32 x i8]* %d.source_sha256.1, i64 0, i64 %zext.ln46
  %add.ln46 = add i5 %arrayinit.curidx11.i215, 1
  store i8 0, i8* %d.source_sha256.1.addr, align 1, !alias.scope !3168, !noalias !3169
  %icmp.ln46 = icmp eq i5 %arrayinit.curidx11.i215, -1
  br i1 %icmp.ln46, label %_ZN4laya4full20FullTensorDescriptorC2Ev.exit_ifconv, label %arrayinit.body10.i219, !llvm.loop !3170

_ZN4laya4full20FullTensorDescriptorC2Ev.exit_ifconv: ; preds = %arrayinit.body10.i219
  %select.ln282 = select i1 %icmp.ln259, i10 0, i10 -512
  %call.ret159 = call fastcc { i16, i32, i8, i8, i32, i32 } @"laya::full::(anonymous namespace)::tensor_named.45"(i10 %select.ln282, [48 x i7]* %d.name.1, [4 x i15]* %d.ne, [32 x i8]* %d.source_sha256.1)
  %c.code.176 = extractvalue { i16, i32, i8, i8, i32, i32 } %call.ret159, 0
  %c.detail.191 = extractvalue { i16, i32, i8, i8, i32, i32 } %call.ret159, 1
  %d.ggml_type_id.1 = extractvalue { i16, i32, i8, i8, i32, i32 } %call.ret159, 2
  %d.bo.1 = extractvalue { i16, i32, i8, i8, i32, i32 } %call.ret159, 3
  %d.base.2 = extractvalue { i16, i32, i8, i8, i32, i32 } %call.ret159, 4
  %d.span.2 = extractvalue { i16, i32, i8, i8, i32, i32 } %call.ret159, 5
  %icmp.ln9.159 = icmp eq i16 %c.code.176, 0
  %icmp.ln283 = icmp ne i8 %d.bo.1, 5
  %icmp.ln283.1 = icmp ne i32 %d.span.2, 4096
  %icmp.ln284 = icmp ne i8 %d.ggml_type_id.1, 0
  %or.ln283 = or i1 %icmp.ln283.1, %icmp.ln284
  %or.ln283.1 = or i1 %or.ln283, %icmp.ln283
  %select.ln283 = select i1 %or.ln283.1, i32 67108868, i32 %c.detail.191
  %select.ln283.1.cast = select i1 %or.ln283.1, i16 2, i16 0
  %.1363136 = select i1 %icmp.ln9.159, i32 %select.ln283, i32 %c.detail.191
  %c.code.val51 = select i1 %icmp.ln9.159, i16 %select.ln283.1.cast, i16 %c.code.176
  %icmp.ln9.160 = icmp eq i16 %c.code.val51, 0
  %zext.ln285 = zext i32 %d.base.2 to i33
  %zext.ln114 = zext i32 %d.span.2 to i33
  %icmp.ln117 = icmp ugt i32 %d.base.2, 1671872
  %sub.ln117 = sub i33 1671872, %zext.ln285
  %icmp.ln117.5 = icmp ult i33 %sub.ln117, %zext.ln114
  %add.ln118 = add nuw i33 %zext.ln114, %zext.ln285
  %icmp.ln118 = icmp ugt i33 %add.ln118, -4294967296
  %or.ln116 = or i1 %icmp.ln117, %icmp.ln118
  %or.ln116.5 = or i1 %or.ln116, %icmp.ln117.5
  %select.ln116.4 = select i1 %or.ln116.5, i16 5, i16 0
  %select.ln285 = select i1 %or.ln116.5, i32 67436553, i32 0
  %.1363 = select i1 %icmp.ln9.160, i32 %select.ln285, i32 %.1363136
  %c.code.val52 = select i1 %icmp.ln9.160, i16 %select.ln116.4, i16 %c.code.val51
  %trunc.ln9.20 = trunc i16 %c.code.val52 to i4
  %icmp.ln9.161 = icmp eq i16 %c.code.val52, 0
  br i1 %icmp.ln9.161, label %if.end162, label %if.then160

if.then160:                                       ; preds = %_ZN4laya4full20FullTensorDescriptorC2Ev.exit_ifconv
  %call.ret161 = call fastcc { i16, i32, i32, i16, i32, i32, i8 } @"laya::full::(anonymous namespace)::finish_load"(i32 %t.ctx.task_id.read, i8 %t.ctx.op.read, i32 4096, i4 %trunc.ln9.20, i32 %.1363)
  %newret250 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret161, 0
  %newret252 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret161, 1
  %newret254 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret161, 2
  %newret256 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret161, 3
  %newret258 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret161, 4
  %newret260 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret161, 5
  %newret262 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret161, 6
  br label %cleanup773

if.end162:                                        ; preds = %_ZN4laya4full20FullTensorDescriptorC2Ev.exit_ifconv
  %call.ret160 = call fastcc { i16, i32 } @"laya::full::full_claim_owner"(i8 42, i8 %t_dst_bank.val, i32 %t_dst_epoch.val, i3 0, i3 %t_ctx_stage.val, i6 -1, i8 0, i8 2, i16 0, i16 1, i16 1024, i3 1)
  %c.code.177 = extractvalue { i16, i32 } %call.ret160, 0
  %c.code.185.cast = trunc i16 %c.code.177 to i4
  %c.detail.192 = extractvalue { i16, i32 } %call.ret160, 1
  %icmp.ln9.162 = icmp eq i16 %c.code.177, 0
  br i1 %icmp.ln9.162, label %VITIS_LOOP_291_1, label %if.then174

if.then174:                                       ; preds = %if.end162
  %call.ret162 = call fastcc { i16, i32, i32, i16, i32, i32, i8 } @"laya::full::(anonymous namespace)::finish_load"(i32 %t.ctx.task_id.read, i8 %t.ctx.op.read, i32 4096, i4 %c.code.185.cast, i32 %c.detail.192)
  %newret236 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret162, 0
  %newret238 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret162, 1
  %newret240 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret162, 2
  %newret242 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret162, 3
  %newret244 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret162, 4
  %newret246 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret162, 5
  %newret248 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret162, 6
  br label %cleanup773

VITIS_LOOP_291_1:                                 ; preds = %if.end162
  %zext.ln293 = zext i8 %t_dst_bank.val to i64
  %raw.8.addr = getelementptr inbounds [4 x i8], [4 x i8]* %raw.8, i64 0, i64 0
  %raw.8.addr.1 = getelementptr inbounds [4 x i8], [4 x i8]* %raw.8, i64 0, i64 1
  %raw.8.addr.2 = getelementptr inbounds [4 x i8], [4 x i8]* %raw.8, i64 0, i64 2
  %raw.8.addr.3 = getelementptr inbounds [4 x i8], [4 x i8]* %raw.8, i64 0, i64 3
  br label %for.body

for.body:                                         ; preds = %_ZN4laya4full12_GLOBAL__N_112read_aux_f32ERKNS0_11FullRuntimeERKNS0_10FullMemoryEjNS_2OpERf.2878.3063.3288.3513.3738.3963.4188.4413.4638.4863.5088.5313.5538.5763.exit, %VITIS_LOOP_291_1
  %i.95 = phi i10 [ 0, %VITIS_LOOP_291_1 ], [ %trunc.ln291, %_ZN4laya4full12_GLOBAL__N_112read_aux_f32ERKNS0_11FullRuntimeERKNS0_10FullMemoryEjNS_2OpERf.2878.3063.3288.3513.3738.3963.4188.4413.4638.4863.5088.5313.5538.5763.exit ]
  %zext.ln291 = zext i10 %i.95 to i64
  %zext.ln291.1 = zext i10 %i.95 to i11
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 0, i64 1024, i64 512), !fpga.pragma.source !169
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @47)
  %zext.ln292 = zext i10 %i.95 to i12
  %shl.ln292 = shl nuw i12 %zext.ln292, 2
  %zext.ln292.1 = zext i12 %shl.ln292 to i32
  %offset = add i32 %zext.ln292.1, %d.base.2
  %output = getelementptr inbounds [2 x [1024 x float]], [2 x [1024 x float]]* @"laya::full::g_full_cache_gamma", i64 0, i64 %zext.ln293, i64 %zext.ln291
  %zext.ln196 = zext i32 %offset to i33
  %call.ret163 = call fastcc { i16, i32 } @"laya::full::full_read"(i8 addrspace(1)* %embedding, i64 %memory_embedding, i8 addrspace(1)* %io, i64 %memory_io, i8 addrspace(1)* %w_q0, i64 %memory_w_q0, i8 addrspace(1)* %w_q1, i64 %memory_w_q1, i8 addrspace(1)* %w_scale, i64 %memory_w_scale, i8 addrspace(1)* %aux, i64 %memory_aux, i8 addrspace(1)* %state0, i64 %memory_state0, i8 addrspace(1)* %state1, i64 %memory_state1, i8 addrspace(1)* %qkv0, i64 %memory_qkv0, i8 addrspace(1)* %qkv1, i64 %memory_qkv1, i8 addrspace(1)* %ff0, i64 %memory_ff0, i8 addrspace(1)* %ff1, i64 %memory_ff1, i8 addrspace(1)* %att_out, i64 %memory_att_out, i8 5, i33 %zext.ln196, [4 x i8]* %raw.8)
  %c.code.179 = extractvalue { i16, i32 } %call.ret163, 0
  %c.detail.194 = extractvalue { i16, i32 } %call.ret163, 1
  %icmp.ln9 = icmp eq i16 %c.code.179, 0
  br i1 %icmp.ln9, label %if.end.i224, label %_ZN4laya4full12_GLOBAL__N_112read_aux_f32ERKNS0_11FullRuntimeERKNS0_10FullMemoryEjNS_2OpERf.2878.3063.3288.3513.3738.3963.4188.4413.4638.4863.5088.5313.5538.5763.exit

if.end.i224:                                      ; preds = %for.body
  %raw.8.load = load i8, i8* %raw.8.addr, align 512, !noalias !3171
  %raw.8.load.1 = load i8, i8* %raw.8.addr.1, align 1, !noalias !3171
  %raw.8.load.2 = load i8, i8* %raw.8.addr.2, align 2, !noalias !3171
  %raw.8.load.3 = load i8, i8* %raw.8.addr.3, align 1, !noalias !3171
  %trunc.ln199 = trunc i8 %raw.8.load.3 to i7
  %bits = call i32 @_ssdm_op_BitConcatenate.i32.i8.i8.i8.i8(i8 %raw.8.load.3, i8 %raw.8.load.2, i8 %raw.8.load.1, i8 %raw.8.load)
  %bits.cast = call i31 @_ssdm_op_BitConcatenate.i31.i7.i8.i8.i8(i7 %trunc.ln199, i8 %raw.8.load.2, i8 %raw.8.load.1, i8 %raw.8.load)
  %and.ln200 = and i31 %bits.cast, -8388608
  %icmp.ln200 = icmp eq i31 %and.ln200, -8388608
  br i1 %icmp.ln200, label %_ZN4laya4full12_GLOBAL__N_112read_aux_f32ERKNS0_11FullRuntimeERKNS0_10FullMemoryEjNS_2OpERf.2878.3063.3288.3513.3738.3963.4188.4413.4638.4863.5088.5313.5538.5763.exit, label %if.end14.i

if.end14.i:                                       ; preds = %if.end.i224
  %0 = bitcast i32 %bits to float
  store float %0, float* %output, align 4, !alias.scope !3203, !noalias !3204
  br label %_ZN4laya4full12_GLOBAL__N_112read_aux_f32ERKNS0_11FullRuntimeERKNS0_10FullMemoryEjNS_2OpERf.2878.3063.3288.3513.3738.3963.4188.4413.4638.4863.5088.5313.5538.5763.exit

_ZN4laya4full12_GLOBAL__N_112read_aux_f32ERKNS0_11FullRuntimeERKNS0_10FullMemoryEjNS_2OpERf.2878.3063.3288.3513.3738.3963.4188.4413.4638.4863.5088.5313.5538.5763.exit: ; preds = %if.end14.i, %if.end.i224, %for.body
  %c.code.182 = phi i16 [ 0, %if.end14.i ], [ 6, %if.end.i224 ], [ %c.code.179, %for.body ]
  %c.detail.197 = phi i32 [ 0, %if.end14.i ], [ 125960207, %if.end.i224 ], [ %c.detail.194, %for.body ]
  %icmp.ln9.165 = icmp eq i16 %c.code.182, 0
  %add.ln291 = add nuw i11 %zext.ln291.1, 1
  %trunc.ln291 = trunc i11 %add.ln291 to i10
  %icmp.ln291 = icmp sgt i11 %add.ln291, -1
  %and.ln294 = and i1 %icmp.ln9.165, %icmp.ln291
  br i1 %and.ln294, label %for.body, label %for.end, !llvm.loop !3205

for.end:                                          ; preds = %_ZN4laya4full12_GLOBAL__N_112read_aux_f32ERKNS0_11FullRuntimeERKNS0_10FullMemoryEjNS_2OpERf.2878.3063.3288.3513.3738.3963.4188.4413.4638.4863.5088.5313.5538.5763.exit
  br i1 %icmp.ln9.165, label %if.then190, label %if.end192

if.then190:                                       ; preds = %for.end
  %call.ret165 = call fastcc { i16, i32 } @"laya::full::full_cover_owner"(i8 42, i8 %t_dst_bank.val, i32 %t_dst_epoch.val, i8 0, i8 %t_ctx_stage.val.cast, i8 -1, i8 0, i8 2, i16 0, i16 1, i16 1024, i3 1, i8 0, i16 0, i16 1)
  %c.code.183 = extractvalue { i16, i32 } %call.ret165, 0
  %c.detail.198 = extractvalue { i16, i32 } %call.ret165, 1
  br label %if.end192

if.end192:                                        ; preds = %if.then190, %for.end
  %.1318142 = phi i32 [ %c.detail.198, %if.then190 ], [ %c.detail.197, %for.end ]
  %c.code.val55 = phi i16 [ %c.code.183, %if.then190 ], [ %c.code.182, %for.end ]
  %icmp.ln9.166 = icmp eq i16 %c.code.val55, 0
  br i1 %icmp.ln9.166, label %if.then194, label %if.end196

if.then194:                                       ; preds = %if.end192
  %call.ret166 = call fastcc { i16, i32 } @"laya::full::full_publish_owner"(i8 42, i8 %t_dst_bank.val, i32 %t_dst_epoch.val, i3 0, i3 %t_ctx_stage.val, i6 -1, i8 0, i8 2, i16 0, i16 1, i16 1024, i3 1)
  %c.code.184 = extractvalue { i16, i32 } %call.ret166, 0
  %c.detail.199 = extractvalue { i16, i32 } %call.ret166, 1
  br label %if.end196

if.end196:                                        ; preds = %if.then194, %if.end192
  %.1318 = phi i32 [ %c.detail.199, %if.then194 ], [ %.1318142, %if.end192 ]
  %c.code.val56 = phi i16 [ %c.code.184, %if.then194 ], [ %c.code.val55, %if.end192 ]
  %trunc.ln9.21 = trunc i16 %c.code.val56 to i4
  %icmp.ln9.167 = icmp eq i16 %c.code.val56, 0
  br i1 %icmp.ln9.167, label %if.else, label %if.then198

if.then198:                                       ; preds = %if.end196
  %1 = call fastcc i3 @"laya::full::full_invalidate_owner"(i8 42, i8 %t_dst_bank.val, i32 %t_dst_epoch.val, i8 0)
  br label %if.end204

if.else:                                          ; preds = %if.end196
  %"(anonymous namespace)::runtime.loaded_gamma_ref.id.addr" = getelementptr [2 x i6], [2 x i6]* @"(anonymous namespace)::runtime.loaded_gamma_ref.id", i64 0, i64 %zext.ln293
  store i6 -22, i6* %"(anonymous namespace)::runtime.loaded_gamma_ref.id.addr", align 1
  %"(anonymous namespace)::runtime.loaded_gamma_ref.bank.addr" = getelementptr [2 x i8], [2 x i8]* @"(anonymous namespace)::runtime.loaded_gamma_ref.bank", i64 0, i64 %zext.ln293
  store i8 %t_dst_bank.val, i8* %"(anonymous namespace)::runtime.loaded_gamma_ref.bank.addr", align 1
  %"(anonymous namespace)::runtime.loaded_gamma_ref.epoch.addr" = getelementptr [2 x i32], [2 x i32]* @"(anonymous namespace)::runtime.loaded_gamma_ref.epoch", i64 0, i64 %zext.ln293
  store i32 %t_dst_epoch.val, i32* %"(anonymous namespace)::runtime.loaded_gamma_ref.epoch.addr", align 4
  br label %if.end204

if.end204:                                        ; preds = %if.else, %if.then198
  %call.ret167 = call fastcc { i16, i32, i32, i16, i32, i32, i8 } @"laya::full::(anonymous namespace)::finish_load"(i32 %t.ctx.task_id.read, i8 %t.ctx.op.read, i32 4096, i4 %trunc.ln9.21, i32 %.1318)
  %newret222 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret167, 0
  %newret224 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret167, 1
  %newret226 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret167, 2
  %newret228 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret167, 3
  %newret230 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret167, 4
  %newret232 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret167, 5
  %newret234 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret167, 6
  br label %cleanup773

if.then213:                                       ; preds = %if.end92
  %urem.ln303 = urem i8 %t_ctx_layer.val.cast, 3
  %trunc.ln303 = trunc i8 %urem.ln303 to i2
  %mode = icmp ne i2 %trunc.ln303, 0
  %zext.ln303 = zext i1 %mode to i8
  %icmp.ln304 = icmp ne i3 %t_ctx_stage.val, 2
  %icmp.ln304.1 = icmp ugt i6 %t_ctx_layer.val, 27
  %or.ln304 = or i1 %icmp.ln304, %icmp.ln304.1
  br i1 %or.ln304, label %if.then249, label %lor.lhs.false229

lor.lhs.false229:                                 ; preds = %if.then213
  %icmp.ln305 = icmp ne i8 %zext.ln303, %t_dst_bank.val
  %or.ln305 = or i1 %icmp.ln39.3, %icmp.ln305
  br i1 %or.ln305, label %if.then249, label %lor.lhs.false239

lor.lhs.false239:                                 ; preds = %lor.lhs.false229
  %icmp.ln306 = icmp ne i5 %t_head.val, -1
  %icmp.ln306.1 = icmp ne i32 %t.byte_count.read, 524800
  %or.ln306 = or i1 %icmp.ln306.1, %t_planes.val
  %or.ln306.1 = or i1 %or.ln306, %icmp.ln306
  br i1 %or.ln306.1, label %if.then249, label %if.end252

if.then249:                                       ; preds = %lor.lhs.false239, %lor.lhs.false229, %if.then213
  %call.ret157 = call fastcc { i16, i32, i32, i16, i32, i32, i8 } @"laya::full::(anonymous namespace)::finish_load"(i32 %t.ctx.task_id.read, i8 %t.ctx.op.read, i32 %t.byte_count.read, i4 5, i32 69926917)
  %newret208 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret157, 0
  %newret210 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret157, 1
  %newret212 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret157, 2
  %newret214 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret157, 3
  %newret216 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret157, 4
  %newret218 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret157, 5
  %newret220 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret157, 6
  br label %cleanup773

if.end252:                                        ; preds = %lor.lhs.false239
  %d.ggml_type_id.addr = getelementptr [2 x i8], [2 x i8]* %d.ggml_type_id, i64 0, i64 0
  %d.omitted.addr = getelementptr [2 x i8], [2 x i8]* %d.omitted, i64 0, i64 0
  br label %arrayctor.loop

arrayctor.loop:                                   ; preds = %_ZN4laya4full20FullTensorDescriptorC2Ev.5980.exit, %if.end252
  %indvars.iv170 = phi i1 [ %xor.ln310, %_ZN4laya4full20FullTensorDescriptorC2Ev.5980.exit ], [ false, %if.end252 ]
  %zext.ln0 = zext i1 %indvars.iv170 to i64
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 2, i64 2, i64 2), !fpga.pragma.source !169
  br label %arrayinit.body.i230

arrayinit.body.i230:                              ; preds = %arrayinit.body.i230, %arrayctor.loop
  %arrayinit.curidx.i226 = phi i6 [ 0, %arrayctor.loop ], [ %add.ln41.1, %arrayinit.body.i230 ]
  %zext.ln41.2 = zext i6 %arrayinit.curidx.i226 to i64
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 48, i64 48, i64 48), !fpga.pragma.source !169
  %d.name.2.addr = getelementptr [2 x [48 x i7]], [2 x [48 x i7]]* %d.name.2, i64 0, i64 %zext.ln0, i64 %zext.ln41.2
  %add.ln41.1 = add nuw i6 %arrayinit.curidx.i226, 1
  store i7 0, i7* %d.name.2.addr, align 1, !alias.scope !3277, !noalias !3280
  %icmp.ln41.2 = icmp eq i6 %arrayinit.curidx.i226, -17
  br i1 %icmp.ln41.2, label %arrayinit.end.i231, label %arrayinit.body.i230, !llvm.loop !3291

arrayinit.end.i231:                               ; preds = %arrayinit.body.i230
  %this.ggml_type_id = getelementptr [2 x i8], [2 x i8]* %d.ggml_type_id, i64 0, i64 %zext.ln0
  %this.omitted = getelementptr [2 x i8], [2 x i8]* %d.omitted, i64 0, i64 %zext.ln0
  %this.bo = getelementptr [2 x i8], [2 x i8]* %d.bo, i64 0, i64 %zext.ln0
  %this.reserved = getelementptr [2 x i8], [2 x i8]* %d.reserved, i64 0, i64 %zext.ln0
  store i8 0, i8* %this.ggml_type_id, align 4, !alias.scope !3293, !noalias !3294
  store i8 -1, i8* %this.bo, align 1, !alias.scope !3295, !noalias !3296
  store i8 0, i8* %this.omitted, align 2, !alias.scope !3297, !noalias !3298
  store i8 0, i8* %this.reserved, align 1, !alias.scope !3299, !noalias !3300
  br label %arrayinit.body3.i236

arrayinit.body3.i236:                             ; preds = %arrayinit.body3.i236, %arrayinit.end.i231
  %arrayinit.curidx4.i232 = phi i2 [ 0, %arrayinit.end.i231 ], [ %add.ln43.1, %arrayinit.body3.i236 ]
  %zext.ln43.1 = zext i2 %arrayinit.curidx4.i232 to i64
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 4, i64 4, i64 4), !fpga.pragma.source !169
  %d.ne.1.addr = getelementptr [2 x [4 x i15]], [2 x [4 x i15]]* %d.ne.1, i64 0, i64 %zext.ln0, i64 %zext.ln43.1
  %add.ln43.1 = add i2 %arrayinit.curidx4.i232, 1
  store i15 0, i15* %d.ne.1.addr, align 2, !alias.scope !3301, !noalias !3302
  %icmp.ln43.1 = icmp eq i2 %arrayinit.curidx4.i232, -1
  br i1 %icmp.ln43.1, label %arrayinit.end8.i237, label %arrayinit.body3.i236, !llvm.loop !3303

arrayinit.end8.i237:                              ; preds = %arrayinit.body3.i236
  %this.source_offset = getelementptr [2 x i32], [2 x i32]* %d.source_offset, i64 0, i64 %zext.ln0
  %this.base = getelementptr [2 x i32], [2 x i32]* %d.base, i64 0, i64 %zext.ln0
  %this.source_bytes = getelementptr [2 x i32], [2 x i32]* %d.source_bytes, i64 0, i64 %zext.ln0
  %this.span = getelementptr [2 x i32], [2 x i32]* %d.span, i64 0, i64 %zext.ln0
  store i32 0, i32* %this.source_offset, align 4, !alias.scope !3305, !noalias !3306
  store i32 0, i32* %this.source_bytes, align 4, !alias.scope !3307, !noalias !3308
  store i32 0, i32* %this.base, align 4, !alias.scope !3309, !noalias !3310
  store i32 0, i32* %this.span, align 4, !alias.scope !3311, !noalias !3312
  br label %arrayinit.body10.i242

arrayinit.body10.i242:                            ; preds = %arrayinit.body10.i242, %arrayinit.end8.i237
  %arrayinit.curidx11.i238 = phi i5 [ 0, %arrayinit.end8.i237 ], [ %add.ln46.1, %arrayinit.body10.i242 ]
  %zext.ln46.1 = zext i5 %arrayinit.curidx11.i238 to i64
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 32, i64 32, i64 32), !fpga.pragma.source !169
  %d.source_sha256.2.addr = getelementptr [2 x [32 x i8]], [2 x [32 x i8]]* %d.source_sha256.2, i64 0, i64 %zext.ln0, i64 %zext.ln46.1
  %add.ln46.1 = add i5 %arrayinit.curidx11.i238, 1
  store i8 0, i8* %d.source_sha256.2.addr, align 1, !alias.scope !3313, !noalias !3314
  %icmp.ln46.11 = icmp eq i5 %arrayinit.curidx11.i238, -1
  br i1 %icmp.ln46.11, label %_ZN4laya4full20FullTensorDescriptorC2Ev.5980.exit, label %arrayinit.body10.i242, !llvm.loop !3315

_ZN4laya4full20FullTensorDescriptorC2Ev.5980.exit: ; preds = %arrayinit.body10.i242
  %xor.ln310 = xor i1 %indvars.iv170, true
  br i1 %indvars.iv170, label %if.end252254, label %arrayctor.loop, !llvm.loop !3317

if.end252254:                                     ; preds = %_ZN4laya4full20FullTensorDescriptorC2Ev.5980.exit
  %d.bo.addr.1 = getelementptr [2 x i8], [2 x i8]* %d.bo, i64 0, i64 0
  %d.reserved.addr.1 = getelementptr [2 x i8], [2 x i8]* %d.reserved, i64 0, i64 0
  %select.ln311 = select i1 %icmp.ln259, i10 0, i10 -512
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
  %tmp.2 = call fastcc { i16, i32, i8, i8, i8, i8, i32, i32, i32, i32 } @"laya::full::(anonymous namespace)::tensor_named"([521 x i8]* noalias nocapture align 512 @.str.2.97, i10 %select.ln311, [2 x [48 x i7]]* noalias nocapture align 16 %d.name.2, i1 false, i8 %d.ggml_type_id.load.2, i8 %d.bo.load, i8 %d.omitted.load.1, i8 %d.reserved.load, [2 x [4 x i15]]* noalias nocapture align 16 %d.ne.1, i1 false, i32 %d.source_offset.load, i32 %d.source_bytes.load, i32 %d.base.load, i32 %d.span.load, [2 x [32 x i8]]* noalias nocapture align 32 %d.source_sha256.2, i1 false) #1
  %c.code.178 = extractvalue { i16, i32, i8, i8, i8, i8, i32, i32, i32, i32 } %tmp.2, 0
  %c.detail.193 = extractvalue { i16, i32, i8, i8, i8, i8, i32, i32, i32, i32 } %tmp.2, 1
  %newret290 = extractvalue { i16, i32, i8, i8, i8, i8, i32, i32, i32, i32 } %tmp.2, 2
  %newret291 = extractvalue { i16, i32, i8, i8, i8, i8, i32, i32, i32, i32 } %tmp.2, 3
  %newret292 = extractvalue { i16, i32, i8, i8, i8, i8, i32, i32, i32, i32 } %tmp.2, 4
  %newret293 = extractvalue { i16, i32, i8, i8, i8, i8, i32, i32, i32, i32 } %tmp.2, 5
  %newret294 = extractvalue { i16, i32, i8, i8, i8, i8, i32, i32, i32, i32 } %tmp.2, 6
  %newret295 = extractvalue { i16, i32, i8, i8, i8, i8, i32, i32, i32, i32 } %tmp.2, 7
  %newret297 = extractvalue { i16, i32, i8, i8, i8, i8, i32, i32, i32, i32 } %tmp.2, 8
  %newret298 = extractvalue { i16, i32, i8, i8, i8, i8, i32, i32, i32, i32 } %tmp.2, 9
  store i8 %newret290, i8* %d.ggml_type_id.addr, align 512
  store i8 %newret291, i8* %d.bo.addr.1, align 512
  store i8 %newret292, i8* %d.omitted.addr, align 512
  store i8 %newret293, i8* %d.reserved.addr.1, align 512
  store i32 %newret294, i32* %d.source_offset.addr.1, align 512
  store i32 %newret295, i32* %d.source_bytes.addr.1, align 512
  store i32 %newret297, i32* %d.base.addr.1, align 512
  store i32 %newret298, i32* %d.span.addr.1, align 512
  %icmp.ln9.163 = icmp eq i16 %c.code.178, 0
  br i1 %icmp.ln9.163, label %if.then261, label %for.cond268.preheader

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
  %tmp. = call fastcc { i16, i32, i8, i8, i8, i8, i32, i32, i32, i32 } @"laya::full::(anonymous namespace)::tensor_named"([521 x i8]* noalias nocapture align 512 @.str.4.99, i10 %select.ln311, [2 x [48 x i7]]* noalias nocapture align 16 %d.name.2, i1 true, i8 %d.ggml_type_id.load, i8 %d.bo.load.1, i8 %d.omitted.load, i8 %d.reserved.load.1, [2 x [4 x i15]]* noalias nocapture align 16 %d.ne.1, i1 true, i32 %d.source_offset.load.1, i32 %d.source_bytes.load.1, i32 %d.base.load.1, i32 %d.span.load.1, [2 x [32 x i8]]* noalias nocapture align 32 %d.source_sha256.2, i1 true) #1
  %c.code.180 = extractvalue { i16, i32, i8, i8, i8, i8, i32, i32, i32, i32 } %tmp., 0
  %c.detail.195 = extractvalue { i16, i32, i8, i8, i8, i8, i32, i32, i32, i32 } %tmp., 1
  %newret299 = extractvalue { i16, i32, i8, i8, i8, i8, i32, i32, i32, i32 } %tmp., 2
  %newret300 = extractvalue { i16, i32, i8, i8, i8, i8, i32, i32, i32, i32 } %tmp., 3
  %newret301 = extractvalue { i16, i32, i8, i8, i8, i8, i32, i32, i32, i32 } %tmp., 4
  %newret302 = extractvalue { i16, i32, i8, i8, i8, i8, i32, i32, i32, i32 } %tmp., 5
  %newret303 = extractvalue { i16, i32, i8, i8, i8, i8, i32, i32, i32, i32 } %tmp., 6
  %newret305 = extractvalue { i16, i32, i8, i8, i8, i8, i32, i32, i32, i32 } %tmp., 7
  %newret306 = extractvalue { i16, i32, i8, i8, i8, i8, i32, i32, i32, i32 } %tmp., 8
  %newret308 = extractvalue { i16, i32, i8, i8, i8, i8, i32, i32, i32, i32 } %tmp., 9
  store i8 %newret299, i8* %d.ggml_type_id.addr.1, align 1
  store i8 %newret300, i8* %d.bo.addr.2, align 1
  store i8 %newret301, i8* %d.omitted.addr.1, align 1
  store i8 %newret302, i8* %d.reserved.addr.2, align 1
  store i32 %newret303, i32* %d.source_offset.addr.2, align 4
  store i32 %newret305, i32* %d.source_bytes.addr.2, align 4
  store i32 %newret306, i32* %d.base.addr.2, align 4
  store i32 %newret308, i32* %d.span.addr.2, align 4
  br label %for.cond268.preheader

for.cond268.preheader:                            ; preds = %if.then261, %if.end252254
  %c.code.1.ph = phi i16 [ %c.code.178, %if.end252254 ], [ %c.code.180, %if.then261 ]
  %.1279.ph = phi i32 [ %c.detail.193, %if.end252254 ], [ %c.detail.195, %if.then261 ]
  br label %for.cond268

for.cond268:                                      ; preds = %for.body272_ifconv, %for.cond268.preheader
  %c.code.1 = phi i16 [ %c.code.189.cast, %for.body272_ifconv ], [ %c.code.1.ph, %for.cond268.preheader ]
  %.1279 = phi i32 [ %zext.ln245, %for.body272_ifconv ], [ %.1279.ph, %for.cond268.preheader ]
  %i = phi i2 [ %i.97, %for.body272_ifconv ], [ 0, %for.cond268.preheader ]
  %trunc.ln313 = trunc i16 %c.code.1 to i4
  %icmp.ln9.164 = icmp eq i16 %c.code.1, 0
  %icmp.ln313 = icmp sgt i2 %i, -1
  %and.ln313 = and i1 %icmp.ln9.164, %icmp.ln313
  br i1 %and.ln313, label %for.body272_ifconv, label %for.end309

for.body272_ifconv:                               ; preds = %for.cond268
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @2)
  %zext.ln314 = zext i2 %i to i64
  %d.bo.addr.3 = getelementptr [2 x i8], [2 x i8]* %d.bo, i64 0, i64 %zext.ln314
  %d.bo.load.2 = load i8, i8* %d.bo.addr.3, align 1
  %icmp.ln314 = icmp eq i8 %d.bo.load.2, 5
  %d.span.addr.3 = getelementptr [2 x i32], [2 x i32]* %d.span, i64 0, i64 %zext.ln314
  %d.span.load.2 = load i32, i32* %d.span.addr.3, align 4
  %icmp.ln314.1 = icmp eq i32 %d.span.load.2, 262400
  %d.ggml_type_id.addr.2 = getelementptr [2 x i8], [2 x i8]* %d.ggml_type_id, i64 0, i64 %zext.ln314
  %d.ggml_type_id.load.1 = load i8, i8* %d.ggml_type_id.addr.2, align 4
  %icmp.ln315 = icmp eq i8 %d.ggml_type_id.load.1, 0
  %d.base.addr.3 = getelementptr [2 x i32], [2 x i32]* %d.base, i64 0, i64 %zext.ln314
  %offset.4 = load i32, i32* %d.base.addr.3, align 4
  %zext.ln114.2 = zext i32 %offset.4 to i33
  %icmp.ln117.6 = icmp ugt i32 %offset.4, 1671872
  %sub.ln117.2 = sub i33 1671872, %zext.ln114.2
  %icmp.ln117.7 = icmp ult i33 %sub.ln117.2, 262400
  %add.ln118.2 = add nuw i33 %zext.ln114.2, 262400
  %icmp.ln118.2 = icmp ugt i33 %add.ln118.2, -4294967296
  %or.ln116.6 = or i1 %icmp.ln117.6, %icmp.ln118.2
  %or.ln116.7 = or i1 %or.ln116.6, %icmp.ln117.7
  %select.ln116 = select i1 %or.ln116.7, i3 -3, i3 0
  %select.ln116.5 = select i1 %or.ln116.7, i27 -66781175, i27 0
  %and.ln315 = and i1 %icmp.ln314.1, %icmp.ln315
  %and.ln315.1 = and i1 %and.ln315, %icmp.ln314
  %c.code.181 = select i1 %and.ln315.1, i3 %select.ln116, i3 2
  %c.code.189.cast = zext i3 %c.code.181 to i16
  %c.detail.196 = select i1 %and.ln315.1, i27 %select.ln116.5, i27 -67108860
  %zext.ln245 = zext i27 %c.detail.196 to i32
  %i.97 = add i2 %i, 1
  br label %for.cond268, !llvm.loop !3318

for.end309:                                       ; preds = %for.cond268
  br i1 %icmp.ln9.164, label %if.end313, label %if.then311

if.then311:                                       ; preds = %for.end309
  %call.ret164 = call fastcc { i16, i32, i32, i16, i32, i32, i8 } @"laya::full::(anonymous namespace)::finish_load"(i32 %t.ctx.task_id.read, i8 %t.ctx.op.read, i32 524800, i4 %trunc.ln313, i32 %.1279)
  %newret194 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret164, 0
  %newret196 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret164, 1
  %newret198 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret164, 2
  %newret200 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret164, 3
  %newret202 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret164, 4
  %newret204 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret164, 5
  %newret206 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret164, 6
  br label %cleanup773

if.end313:                                        ; preds = %for.end309
  %"(anonymous namespace)::runtime.load" = load i6, i6* @"(anonymous namespace)::runtime.loaded_rope_ref.id", align 1
  %icmp.ln320 = icmp eq i6 %"(anonymous namespace)::runtime.load", 0
  br i1 %icmp.ln320, label %if.end339, label %arrayinit.body.i.i.preheader

arrayinit.body.i.i.preheader:                     ; preds = %if.end313
  br label %arrayinit.body.i.i

arrayinit.body.i.i:                               ; preds = %arrayinit.body.i.i, %arrayinit.body.i.i.preheader
  %arrayinit.curidx.i.i = phi i4 [ %add.ln14, %arrayinit.body.i.i ], [ 0, %arrayinit.body.i.i.preheader ]
  %zext.ln14 = zext i4 %arrayinit.curidx.i.i to i64
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 16, i64 16, i64 16), !fpga.pragma.source !169
  %old.identity.model_tag.addr = getelementptr [16 x i8], [16 x i8]* %old.identity.model_tag, i64 0, i64 %zext.ln14
  %add.ln14 = add i4 %arrayinit.curidx.i.i, 1
  store i8 0, i8* %old.identity.model_tag.addr, align 1, !alias.scope !3325, !noalias !3330
  %icmp.ln14 = icmp eq i4 %arrayinit.curidx.i.i, -1
  br i1 %icmp.ln14, label %arrayinit.body3.i.i.preheader, label %arrayinit.body.i.i, !llvm.loop !3366

arrayinit.body3.i.i.preheader:                    ; preds = %arrayinit.body.i.i
  br label %arrayinit.body3.i.i

arrayinit.body3.i.i:                              ; preds = %arrayinit.body3.i.i, %arrayinit.body3.i.i.preheader
  %arrayinit.curidx4.i.i = phi i4 [ %add.ln15, %arrayinit.body3.i.i ], [ 0, %arrayinit.body3.i.i.preheader ]
  %zext.ln15 = zext i4 %arrayinit.curidx4.i.i to i64
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 16, i64 16, i64 16), !fpga.pragma.source !169
  %old.identity.numeric_tag.addr = getelementptr [16 x i8], [16 x i8]* %old.identity.numeric_tag, i64 0, i64 %zext.ln15
  %add.ln15 = add i4 %arrayinit.curidx4.i.i, 1
  store i8 0, i8* %old.identity.numeric_tag.addr, align 1, !alias.scope !3367, !noalias !3368
  %icmp.ln15 = icmp eq i4 %arrayinit.curidx4.i.i, -1
  br i1 %icmp.ln15, label %arrayinit.body10.i.i.preheader, label %arrayinit.body3.i.i, !llvm.loop !3369

arrayinit.body10.i.i.preheader:                   ; preds = %arrayinit.body3.i.i
  br label %arrayinit.body10.i.i

arrayinit.body10.i.i:                             ; preds = %arrayinit.body10.i.i, %arrayinit.body10.i.i.preheader
  %arrayinit.curidx11.i.i = phi i4 [ %add.ln16, %arrayinit.body10.i.i ], [ 0, %arrayinit.body10.i.i.preheader ]
  %zext.ln16 = zext i4 %arrayinit.curidx11.i.i to i64
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 16, i64 16, i64 16), !fpga.pragma.source !169
  %old.identity.layout_tag.addr = getelementptr [16 x i8], [16 x i8]* %old.identity.layout_tag, i64 0, i64 %zext.ln16
  %add.ln16 = add i4 %arrayinit.curidx11.i.i, 1
  store i8 0, i8* %old.identity.layout_tag.addr, align 1, !alias.scope !3370, !noalias !3371
  %icmp.ln16 = icmp eq i4 %arrayinit.curidx11.i.i, -1
  br i1 %icmp.ln16, label %arrayinit.body17.i.i.preheader, label %arrayinit.body10.i.i, !llvm.loop !3372

arrayinit.body17.i.i.preheader:                   ; preds = %arrayinit.body10.i.i
  br label %arrayinit.body17.i.i

arrayinit.body17.i.i:                             ; preds = %arrayinit.body17.i.i, %arrayinit.body17.i.i.preheader
  %arrayinit.curidx18.i.i = phi i4 [ %add.ln17, %arrayinit.body17.i.i ], [ 0, %arrayinit.body17.i.i.preheader ]
  %zext.ln17 = zext i4 %arrayinit.curidx18.i.i to i64
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 16, i64 16, i64 16), !fpga.pragma.source !169
  %old.identity.build_tag.addr = getelementptr [16 x i8], [16 x i8]* %old.identity.build_tag, i64 0, i64 %zext.ln17
  %add.ln17 = add i4 %arrayinit.curidx18.i.i, 1
  store i8 0, i8* %old.identity.build_tag.addr, align 1, !alias.scope !3373, !noalias !3374
  %icmp.ln17 = icmp eq i4 %arrayinit.curidx18.i.i, -1
  br i1 %icmp.ln17, label %arrayinit.body.i248.preheader, label %arrayinit.body17.i.i, !llvm.loop !3375

arrayinit.body.i248.preheader:                    ; preds = %arrayinit.body17.i.i
  br label %arrayinit.body.i248

arrayinit.body.i248:                              ; preds = %arrayinit.body.i248, %arrayinit.body.i248.preheader
  %arrayinit.curidx.i244 = phi i6 [ %add.ln75, %arrayinit.body.i248 ], [ 0, %arrayinit.body.i248.preheader ]
  %zext.ln75 = zext i6 %arrayinit.curidx.i244 to i64
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 64, i64 64, i64 64), !fpga.pragma.source !169
  %old.covered_rows.addr = getelementptr [64 x i32], [64 x i32]* %old.covered_rows, i64 0, i64 %zext.ln75
  %add.ln75 = add i6 %arrayinit.curidx.i244, 1
  store i32 0, i32* %old.covered_rows.addr, align 4, !alias.scope !3376, !noalias !3377
  %icmp.ln75 = icmp eq i6 %arrayinit.curidx.i244, -1
  br i1 %icmp.ln75, label %arrayinit.body3.i254.preheader, label %arrayinit.body.i248, !llvm.loop !3378

arrayinit.body3.i254.preheader:                   ; preds = %arrayinit.body.i248
  br label %arrayinit.body3.i254

arrayinit.body3.i254:                             ; preds = %arrayinit.body3.i254, %arrayinit.body3.i254.preheader
  %arrayinit.curidx4.i250 = phi i6 [ %add.ln76, %arrayinit.body3.i254 ], [ 0, %arrayinit.body3.i254.preheader ]
  %zext.ln76 = zext i6 %arrayinit.curidx4.i250 to i64
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 64, i64 64, i64 64), !fpga.pragma.source !169
  %old.old_consumed_rows.addr = getelementptr [64 x i32], [64 x i32]* %old.old_consumed_rows, i64 0, i64 %zext.ln76
  %add.ln76 = add i6 %arrayinit.curidx4.i250, 1
  store i32 0, i32* %old.old_consumed_rows.addr, align 4, !alias.scope !3380, !noalias !3381
  %icmp.ln76 = icmp eq i6 %arrayinit.curidx4.i250, -1
  br i1 %icmp.ln76, label %_ZN4laya4full15FullOwnerRecordC2Ev.exit, label %arrayinit.body3.i254, !llvm.loop !3382

_ZN4laya4full15FullOwnerRecordC2Ev.exit:          ; preds = %arrayinit.body3.i254
  %"(anonymous namespace)::runtime.load.3" = load i1, i1* @"(anonymous namespace)::runtime.loaded_rope_ref.bank", align 1
  %zext.ln322 = zext i1 %"(anonymous namespace)::runtime.load.3" to i8
  %"(anonymous namespace)::runtime.load.4" = load i32, i32* @"(anonymous namespace)::runtime.loaded_rope_ref.epoch", align 512
  %call.ret170 = call fastcc { i16, i32, i64, i64, i16, i16, i8, i8, i32, i8, i8, i32, i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i1 } @"laya::full::full_owner_snapshot"(i6 %"(anonymous namespace)::runtime.load", i8 %zext.ln322, i32 %"(anonymous namespace)::runtime.load.4", i8 0, [16 x i8]* %old.identity.model_tag, [16 x i8]* %old.identity.numeric_tag, [16 x i8]* %old.identity.layout_tag, [16 x i8]* %old.identity.build_tag, [64 x i32]* %old.covered_rows, [64 x i32]* %old.old_consumed_rows)
  %c.code.185 = extractvalue { i16, i32, i64, i64, i16, i16, i8, i8, i32, i8, i8, i32, i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i1 } %call.ret170, 0
  %old.ref.id = extractvalue { i16, i32, i64, i64, i16, i16, i8, i8, i32, i8, i8, i32, i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i1 } %call.ret170, 6
  %old.ref.bank = extractvalue { i16, i32, i64, i64, i16, i16, i8, i8, i32, i8, i8, i32, i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i1 } %call.ret170, 7
  %old.ref.epoch = extractvalue { i16, i32, i64, i64, i16, i16, i8, i8, i32, i8, i8, i32, i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i1 } %call.ret170, 8
  %old.max_claimed_epoch = extractvalue { i16, i32, i64, i64, i16, i16, i8, i8, i32, i8, i8, i32, i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i1 } %call.ret170, 12
  %old.region = extractvalue { i16, i32, i64, i64, i16, i16, i8, i8, i32, i8, i8, i32, i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i1 } %call.ret170, 13
  %old.stage = extractvalue { i16, i32, i64, i64, i16, i16, i8, i8, i32, i8, i8, i32, i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i1 } %call.ret170, 14
  %old.layer = extractvalue { i16, i32, i64, i64, i16, i16, i8, i8, i32, i8, i8, i32, i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i1 } %call.ret170, 15
  %old.batch = extractvalue { i16, i32, i64, i64, i16, i16, i8, i8, i32, i8, i8, i32, i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i1 } %call.ret170, 16
  %old.row_space = extractvalue { i16, i32, i64, i64, i16, i16, i8, i8, i32, i8, i8, i32, i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i1 } %call.ret170, 17
  %old.row0 = extractvalue { i16, i32, i64, i64, i16, i16, i8, i8, i32, i8, i8, i32, i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i1 } %call.ret170, 18
  %old.rows = extractvalue { i16, i32, i64, i64, i16, i16, i8, i8, i32, i8, i8, i32, i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i1 } %call.ret170, 19
  %old.width = extractvalue { i16, i32, i64, i64, i16, i16, i8, i8, i32, i8, i8, i32, i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i1 } %call.ret170, 20
  %old.content = extractvalue { i16, i32, i64, i64, i16, i16, i8, i8, i32, i8, i8, i32, i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i1 } %call.ret170, 21
  %old.state = extractvalue { i16, i32, i64, i64, i16, i16, i8, i8, i32, i8, i8, i32, i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i1 } %call.ret170, 22
  %old.valid = extractvalue { i16, i32, i64, i64, i16, i16, i8, i8, i32, i8, i8, i32, i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i1 } %call.ret170, 23
  %icmp.ln9.168 = icmp eq i16 %c.code.185, 0
  br i1 %icmp.ln9.168, label %lor.lhs.false321, label %if.then328

lor.lhs.false321:                                 ; preds = %_ZN4laya4full15FullOwnerRecordC2Ev.exit
  %icmp.ln323 = icmp eq i8 %old.state, 2
  %and.ln323 = and i1 %old.valid, %icmp.ln323
  br i1 %and.ln323, label %lor.lhs.false324, label %if.then328

lor.lhs.false324:                                 ; preds = %lor.lhs.false321
  %add.ln324 = add i32 %old.max_claimed_epoch, 1
  %icmp.ln324 = icmp eq i32 %add.ln324, %t_dst_epoch.val
  br i1 %icmp.ln324, label %if.end331, label %if.then328

if.then328:                                       ; preds = %lor.lhs.false324, %lor.lhs.false321, %_ZN4laya4full15FullOwnerRecordC2Ev.exit
  %call.ret171 = call fastcc { i16, i32, i32, i16, i32, i32, i8 } @"laya::full::(anonymous namespace)::finish_load"(i32 %t.ctx.task_id.read, i8 %t.ctx.op.read, i32 524800, i4 5, i32 69926916)
  %newret180 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret171, 0
  %newret182 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret171, 1
  %newret184 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret171, 2
  %newret186 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret171, 3
  %newret188 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret171, 4
  %newret190 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret171, 5
  %newret192 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret171, 6
  br label %cleanup773

if.end331:                                        ; preds = %lor.lhs.false324
  %call.ret172 = call fastcc { i16, i32 } @"laya::full::full_release_owner"(i8 %old.ref.id, i8 %old.ref.bank, i32 %old.ref.epoch, i8 %old.region, i8 %old.stage, i8 %old.layer, i8 %old.batch, i8 %old.row_space, i16 %old.row0, i16 %old.rows, i16 %old.width, i8 %old.content)
  %c.code.186 = extractvalue { i16, i32 } %call.ret172, 0
  %c.code.199.cast = trunc i16 %c.code.186 to i4
  %c.detail.200 = extractvalue { i16, i32 } %call.ret172, 1
  %icmp.ln9.169 = icmp eq i16 %c.code.186, 0
  br i1 %icmp.ln9.169, label %if.end339, label %if.then335

if.then335:                                       ; preds = %if.end331
  %call.ret174 = call fastcc { i16, i32, i32, i16, i32, i32, i8 } @"laya::full::(anonymous namespace)::finish_load"(i32 %t.ctx.task_id.read, i8 %t.ctx.op.read, i32 524800, i4 %c.code.199.cast, i32 %c.detail.200)
  %newret166 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret174, 0
  %newret168 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret174, 1
  %newret170 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret174, 2
  %newret172 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret174, 3
  %newret174 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret174, 4
  %newret176 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret174, 5
  %newret178 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret174, 6
  br label %cleanup773

if.end339:                                        ; preds = %if.end331, %if.end313
  %call.ret173 = call fastcc { i16, i32 } @"laya::full::full_claim_owner"(i8 43, i8 %t_dst_bank.val, i32 %t_dst_epoch.val, i3 0, i3 2, i6 %t_ctx_layer.val, i8 0, i8 2, i16 0, i16 1, i16 64, i3 1)
  %c.code.187 = extractvalue { i16, i32 } %call.ret173, 0
  %c.code.200.cast = trunc i16 %c.code.187 to i4
  %c.detail.201 = extractvalue { i16, i32 } %call.ret173, 1
  %icmp.ln9.170 = icmp eq i16 %c.code.187, 0
  br i1 %icmp.ln9.170, label %VITIS_LOOP_335_3, label %if.then356

if.then356:                                       ; preds = %if.end339
  %call.ret175 = call fastcc { i16, i32, i32, i16, i32, i32, i8 } @"laya::full::(anonymous namespace)::finish_load"(i32 %t.ctx.task_id.read, i8 %t.ctx.op.read, i32 524800, i4 %c.code.200.cast, i32 %c.detail.201)
  %newret152 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret175, 0
  %newret154 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret175, 1
  %newret156 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret175, 2
  %newret158 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret175, 3
  %newret160 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret175, 4
  %newret162 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret175, 5
  %newret164 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret175, 6
  br label %cleanup773

VITIS_LOOP_335_3:                                 ; preds = %if.end339
  %raw.addr = getelementptr inbounds [4 x i8], [4 x i8]* %raw, i64 0, i64 0
  %raw.addr.30 = getelementptr inbounds [4 x i8], [4 x i8]* %raw, i64 0, i64 1
  %raw.addr.31 = getelementptr inbounds [4 x i8], [4 x i8]* %raw, i64 0, i64 2
  %raw.addr.32 = getelementptr inbounds [4 x i8], [4 x i8]* %raw, i64 0, i64 3
  br label %for.cond359

for.cond359:                                      ; preds = %for.inc403, %VITIS_LOOP_335_3
  %c.code.2 = phi i16 [ 0, %VITIS_LOOP_335_3 ], [ %c.code.3.lcssa, %for.inc403 ]
  %table = phi i2 [ 0, %VITIS_LOOP_335_3 ], [ %add.ln335, %for.inc403 ]
  %.1204127 = phi i32 [ %c.detail.201, %VITIS_LOOP_335_3 ], [ %.1204128.lcssa, %for.inc403 ]
  %.0202123 = phi i16 [ 0, %VITIS_LOOP_335_3 ], [ %.0202124.lcssa, %for.inc403 ]
  %zext.ln335 = zext i2 %table to i64
  %icmp.ln335 = icmp sgt i2 %table, -1
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 1, i64 2, i64 1)
  br i1 %icmp.ln335, label %land.rhs361, label %for.end406

land.rhs361:                                      ; preds = %for.cond359
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @3)
  %icmp.ln9.171 = icmp eq i16 %c.code.2, 0
  br i1 %icmp.ln9.171, label %VITIS_LOOP_336_4, label %for.end406

VITIS_LOOP_336_4:                                 ; preds = %land.rhs361
  %d.base.addr.4 = getelementptr [2 x i32], [2 x i32]* %d.base, i64 0, i64 %zext.ln335
  %d.base.load.3 = load i32, i32* %d.base.addr.4, align 4
  br label %for.cond366

for.cond366:                                      ; preds = %for.inc399, %VITIS_LOOP_336_4
  %c.code.3 = phi i16 [ 0, %VITIS_LOOP_336_4 ], [ %c.code.207.lcssa, %for.inc399 ]
  %pos = phi i11 [ 0, %VITIS_LOOP_336_4 ], [ %add.ln336, %for.inc399 ]
  %.1204128 = phi i32 [ %.1204127, %VITIS_LOOP_336_4 ], [ %c.detail.218.lcssa, %for.inc399 ]
  %.0202124 = phi i16 [ %.0202123, %VITIS_LOOP_336_4 ], [ %c.code.207.lcssa, %for.inc399 ]
  %icmp.ln336 = icmp ult i11 %pos, -1023
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 1, i64 1025, i64 513)
  br i1 %icmp.ln336, label %land.rhs368, label %for.inc403

land.rhs368:                                      ; preds = %for.cond366
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @25)
  %icmp.ln9.175 = icmp eq i16 %c.code.3, 0
  br i1 %icmp.ln9.175, label %for.body376_ifconv.preheader, label %for.inc403

for.body376_ifconv.preheader:                     ; preds = %land.rhs368
  br label %for.body376_ifconv

for.body376_ifconv:                               ; preds = %for.body376_ifconv, %for.body376_ifconv.preheader
  %j = phi i6 [ %trunc.ln337, %for.body376_ifconv ], [ 0, %for.body376_ifconv.preheader ]
  %zext.ln337 = zext i6 %j to i7
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 0, i64 64, i64 32), !fpga.pragma.source !169
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @0)
  %add.ln = call i17 @_ssdm_op_BitConcatenate.i17.i11.i6(i11 %pos, i6 %j)
  %zext.ln338 = zext i17 %add.ln to i19
  %shl.ln338 = shl nuw i19 %zext.ln338, 2
  %zext.ln338.1 = zext i19 %shl.ln338 to i32
  %offset.5 = add i32 %d.base.load.3, %zext.ln338.1
  %zext.ln196.1 = zext i32 %offset.5 to i33
  %call.ret179 = call fastcc { i16, i32 } @"laya::full::full_read"(i8 addrspace(1)* %embedding, i64 %memory_embedding, i8 addrspace(1)* %io, i64 %memory_io, i8 addrspace(1)* %w_q0, i64 %memory_w_q0, i8 addrspace(1)* %w_q1, i64 %memory_w_q1, i8 addrspace(1)* %w_scale, i64 %memory_w_scale, i8 addrspace(1)* %aux, i64 %memory_aux, i8 addrspace(1)* %state0, i64 %memory_state0, i8 addrspace(1)* %state1, i64 %memory_state1, i8 addrspace(1)* %qkv0, i64 %memory_qkv0, i8 addrspace(1)* %qkv1, i64 %memory_qkv1, i8 addrspace(1)* %ff0, i64 %memory_ff0, i8 addrspace(1)* %ff1, i64 %memory_ff1, i8 addrspace(1)* %att_out, i64 %memory_att_out, i8 5, i33 %zext.ln196.1, [4 x i8]* %raw)
  %c.code.190 = extractvalue { i16, i32 } %call.ret179, 0
  %c.detail.204 = extractvalue { i16, i32 } %call.ret179, 1
  %icmp.ln9.176 = icmp eq i16 %c.code.190, 0
  %raw.load = load i8, i8* %raw.addr, align 512, !noalias !3383
  %raw.load.11 = load i8, i8* %raw.addr.30, align 1, !noalias !3383
  %raw.load.12 = load i8, i8* %raw.addr.31, align 2, !noalias !3383
  %raw.load.13 = load i8, i8* %raw.addr.32, align 1, !noalias !3383
  %trunc.ln199.1 = trunc i8 %raw.load.13 to i7
  %bits.2 = call i31 @_ssdm_op_BitConcatenate.i31.i7.i8.i8.i8(i7 %trunc.ln199.1, i8 %raw.load.12, i8 %raw.load.11, i8 %raw.load)
  %and.ln200.1 = and i31 %bits.2, -8388608
  %icmp.ln200.1 = icmp eq i31 %and.ln200.1, -8388608
  %select.ln200 = select i1 %icmp.ln200.1, i16 6, i16 0
  %select.ln200.1.cast.cast = select i1 %icmp.ln200.1, i32 126025743, i32 0
  %c.code.191 = select i1 %icmp.ln9.176, i16 %select.ln200, i16 %c.code.190
  %c.detail.205 = select i1 %icmp.ln9.176, i32 %select.ln200.1.cast.cast, i32 %c.detail.204
  %icmp.ln9.177 = icmp eq i16 %c.code.191, 0
  %add.ln337 = add nuw i7 %zext.ln337, 1
  %trunc.ln337 = trunc i7 %add.ln337 to i6
  %icmp.ln337 = icmp sgt i7 %add.ln337, -1
  %and.ln341 = and i1 %icmp.ln9.177, %icmp.ln337
  br i1 %and.ln341, label %for.body376_ifconv, label %for.inc399, !llvm.loop !3415

for.inc399:                                       ; preds = %for.body376_ifconv
  %c.detail.218.lcssa = phi i32 [ %c.detail.205, %for.body376_ifconv ]
  %c.code.207.lcssa = phi i16 [ %c.code.191, %for.body376_ifconv ]
  %add.ln336 = add nuw i11 %pos, 1
  br label %for.cond366, !llvm.loop !3425

for.inc403:                                       ; preds = %land.rhs368, %for.cond366
  %.0202124.lcssa = phi i16 [ %.0202124, %land.rhs368 ], [ %.0202124, %for.cond366 ]
  %.1204128.lcssa = phi i32 [ %.1204128, %land.rhs368 ], [ %.1204128, %for.cond366 ]
  %c.code.3.lcssa = phi i16 [ %c.code.3, %land.rhs368 ], [ %c.code.3, %for.cond366 ]
  %add.ln335 = add nuw i2 %table, 1
  br label %for.cond359, !llvm.loop !3429

for.end406:                                       ; preds = %land.rhs361, %for.cond359
  %.0202123.lcssa = phi i16 [ %.0202123, %land.rhs361 ], [ %.0202123, %for.cond359 ]
  %.1204127.lcssa = phi i32 [ %.1204127, %land.rhs361 ], [ %.1204127, %for.cond359 ]
  %c.code.2.lcssa = phi i16 [ %c.code.2, %land.rhs361 ], [ %c.code.2, %for.cond359 ]
  %icmp.ln9.172 = icmp eq i16 %c.code.2.lcssa, 0
  br i1 %icmp.ln9.172, label %if.then408, label %if.end410

if.then408:                                       ; preds = %for.end406
  %call.ret176 = call fastcc { i16, i32 } @"laya::full::full_cover_owner"(i8 43, i8 %t_dst_bank.val, i32 %t_dst_epoch.val, i8 0, i8 2, i8 %t_ctx_layer.val.cast, i8 0, i8 2, i16 0, i16 1, i16 64, i3 1, i8 0, i16 0, i16 1)
  %c.code.188 = extractvalue { i16, i32 } %call.ret176, 0
  %c.detail.202 = extractvalue { i16, i32 } %call.ret176, 1
  br label %if.end410

if.end410:                                        ; preds = %if.then408, %for.end406
  %c.code.val66 = phi i16 [ %c.code.188, %if.then408 ], [ %c.code.2.lcssa, %for.end406 ]
  %.1204126 = phi i32 [ %c.detail.202, %if.then408 ], [ %.1204127.lcssa, %for.end406 ]
  %.0202122.in = phi i16 [ %c.code.188, %if.then408 ], [ %.0202123.lcssa, %for.end406 ]
  %icmp.ln9.173 = icmp eq i16 %c.code.val66, 0
  br i1 %icmp.ln9.173, label %if.then412, label %if.end414

if.then412:                                       ; preds = %if.end410
  %call.ret177 = call fastcc { i16, i32 } @"laya::full::full_publish_owner"(i8 43, i8 %t_dst_bank.val, i32 %t_dst_epoch.val, i3 0, i3 2, i6 %t_ctx_layer.val, i8 0, i8 2, i16 0, i16 1, i16 64, i3 1)
  %c.code.189 = extractvalue { i16, i32 } %call.ret177, 0
  %c.detail.203 = extractvalue { i16, i32 } %call.ret177, 1
  br label %if.end414

if.end414:                                        ; preds = %if.then412, %if.end410
  %c.code.val67 = phi i16 [ %c.code.189, %if.then412 ], [ %c.code.val66, %if.end410 ]
  %.1204 = phi i32 [ %c.detail.203, %if.then412 ], [ %.1204126, %if.end410 ]
  %.0202.in = phi i16 [ %c.code.189, %if.then412 ], [ %.0202122.in, %if.end410 ]
  %trunc.ln335 = trunc i16 %.0202.in to i4
  %icmp.ln9.174 = icmp eq i16 %c.code.val67, 0
  br i1 %icmp.ln9.174, label %if.end426, label %if.then416

if.then416:                                       ; preds = %if.end414
  %2 = call fastcc i3 @"laya::full::full_invalidate_owner"(i8 43, i8 %t_dst_bank.val, i32 %t_dst_epoch.val, i8 0)
  br label %if.end426

if.end426:                                        ; preds = %if.then416, %if.end414
  %storemerge5 = phi i6 [ 0, %if.then416 ], [ -21, %if.end414 ]
  %storemerge2 = phi i1 [ false, %if.then416 ], [ %t_dst_bank.val.cast, %if.end414 ]
  %storemerge1 = phi i32 [ 0, %if.then416 ], [ %t_dst_epoch.val, %if.end414 ]
  store i6 %storemerge5, i6* @"(anonymous namespace)::runtime.loaded_rope_ref.id", align 1
  store i1 %storemerge2, i1* @"(anonymous namespace)::runtime.loaded_rope_ref.bank", align 1
  store i32 %storemerge1, i32* @"(anonymous namespace)::runtime.loaded_rope_ref.epoch", align 512
  %call.ret178 = call fastcc { i16, i32, i32, i16, i32, i32, i8 } @"laya::full::(anonymous namespace)::finish_load"(i32 %t.ctx.task_id.read, i8 %t.ctx.op.read, i32 524800, i4 %trunc.ln335, i32 %.1204)
  %newret138 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret178, 0
  %newret140 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret178, 1
  %newret142 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret178, 2
  %newret144 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret178, 3
  %newret146 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret178, 4
  %newret148 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret178, 5
  %newret150 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret178, 6
  br label %cleanup773

if.end431:                                        ; preds = %if.end92
  switch i3 %t_ctx_stage.val, label %if.then482 [
    i3 -4, label %lor.lhs.false441
    i3 2, label %lor.lhs.false441
  ]

lor.lhs.false441:                                 ; preds = %if.end431, %if.end431
  br label %if.then482

if.then482:                                       ; preds = %lor.lhs.false441, %if.end431
  %call.ret155 = call fastcc { i16, i32, i32, i16, i32, i32, i8 } @"laya::full::(anonymous namespace)::finish_load"(i32 %t.ctx.task_id.read, i8 %t.ctx.op.read, i32 %t.byte_count.read, i4 5, i32 69533701)
  %newret124 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret155, 0
  %newret126 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret155, 1
  %newret128 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret155, 2
  %newret130 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret155, 3
  %newret132 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret155, 4
  %newret134 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret155, 5
  %newret136 = extractvalue { i16, i32, i32, i16, i32, i32, i8 } %call.ret155, 6
  br label %cleanup773

cleanup773:                                       ; preds = %if.then482, %if.end426, %if.then356, %if.then335, %if.then328, %if.then311, %if.then249, %if.end204, %if.then174, %if.then160, %if.then131, %if.then87, %if.then71, %if.end95.i, %if.end
  %agg.result.0.10 = phi i16 [ %newret, %if.end ], [ %newret278, %if.then87 ], [ %newret124, %if.then482 ], [ %newret296, %if.then71 ], [ %agg.result.0.ret, %if.end95.i ], [ %newret264, %if.then131 ], [ %newret250, %if.then160 ], [ %newret222, %if.end204 ], [ %newret236, %if.then174 ], [ %newret208, %if.then249 ], [ %newret180, %if.then328 ], [ %newret166, %if.then335 ], [ %newret194, %if.then311 ], [ %newret138, %if.end426 ], [ %newret152, %if.then356 ]
  %agg.result.1.10 = phi i32 [ %newret277, %if.end ], [ %newret280, %if.then87 ], [ %newret126, %if.then482 ], [ %newret304, %if.then71 ], [ %agg.result.1.ret, %if.end95.i ], [ %newret266, %if.then131 ], [ %newret252, %if.then160 ], [ %newret224, %if.end204 ], [ %newret238, %if.then174 ], [ %newret210, %if.then249 ], [ %newret182, %if.then328 ], [ %newret168, %if.then335 ], [ %newret196, %if.then311 ], [ %newret140, %if.end426 ], [ %newret154, %if.then356 ]
  %agg.result.2.10 = phi i64 [ -1, %if.end ], [ -1, %if.then87 ], [ -1, %if.then482 ], [ -1, %if.then71 ], [ %agg.result.2.ret, %if.end95.i ], [ -1, %if.then131 ], [ -1, %if.then160 ], [ -1, %if.end204 ], [ -1, %if.then174 ], [ -1, %if.then249 ], [ -1, %if.then328 ], [ -1, %if.then335 ], [ -1, %if.then311 ], [ -1, %if.end426 ], [ -1, %if.then356 ]
  %done_task_id.10 = phi i32 [ %newret279, %if.end ], [ %newret282, %if.then87 ], [ %newret128, %if.then482 ], [ %newret307, %if.then71 ], [ %done_task_id.ret, %if.end95.i ], [ %newret268, %if.then131 ], [ %newret254, %if.then160 ], [ %newret226, %if.end204 ], [ %newret240, %if.then174 ], [ %newret212, %if.then249 ], [ %newret184, %if.then328 ], [ %newret170, %if.then335 ], [ %newret198, %if.then311 ], [ %newret142, %if.end426 ], [ %newret156, %if.then356 ]
  %done_status.10 = phi i16 [ %newret281, %if.end ], [ %newret284, %if.then87 ], [ %newret130, %if.then482 ], [ %newret309, %if.then71 ], [ %done_status.ret, %if.end95.i ], [ %newret270, %if.then131 ], [ %newret256, %if.then160 ], [ %newret228, %if.end204 ], [ %newret242, %if.then174 ], [ %newret214, %if.then249 ], [ %newret186, %if.then328 ], [ %newret172, %if.then335 ], [ %newret200, %if.then311 ], [ %newret144, %if.end426 ], [ %newret158, %if.then356 ]
  %done_error_detail.10 = phi i32 [ %newret283, %if.end ], [ %newret286, %if.then87 ], [ %newret132, %if.then482 ], [ %newret310, %if.then71 ], [ %done_error_detail.ret, %if.end95.i ], [ %newret272, %if.then131 ], [ %newret258, %if.then160 ], [ %newret230, %if.end204 ], [ %newret244, %if.then174 ], [ %newret216, %if.then249 ], [ %newret188, %if.then328 ], [ %newret174, %if.then335 ], [ %newret202, %if.then311 ], [ %newret146, %if.end426 ], [ %newret160, %if.then356 ]
  %done_bad_element.10 = phi i64 [ -1, %if.end ], [ -1, %if.then87 ], [ -1, %if.then482 ], [ -1, %if.then71 ], [ %done_bad_element.ret, %if.end95.i ], [ -1, %if.then131 ], [ -1, %if.then160 ], [ -1, %if.end204 ], [ -1, %if.then174 ], [ -1, %if.then249 ], [ -1, %if.then328 ], [ -1, %if.then335 ], [ -1, %if.then311 ], [ -1, %if.end426 ], [ -1, %if.then356 ]
  %done_output_elements.10 = phi i32 [ %newret285, %if.end ], [ %newret288, %if.then87 ], [ %newret134, %if.then482 ], [ %newret311, %if.then71 ], [ %done_output_elements.ret, %if.end95.i ], [ %newret274, %if.then131 ], [ %newret260, %if.then160 ], [ %newret232, %if.end204 ], [ %newret246, %if.then174 ], [ %newret218, %if.then249 ], [ %newret190, %if.then328 ], [ %newret176, %if.then335 ], [ %newret204, %if.then311 ], [ %newret148, %if.end426 ], [ %newret162, %if.then356 ]
  %done_output_unit.10 = phi i8 [ %newret287, %if.end ], [ %newret289, %if.then87 ], [ %newret136, %if.then482 ], [ %newret312, %if.then71 ], [ %done_output_unit.ret, %if.end95.i ], [ %newret276, %if.then131 ], [ %newret262, %if.then160 ], [ %newret234, %if.end204 ], [ %newret248, %if.then174 ], [ %newret220, %if.then249 ], [ %newret192, %if.then328 ], [ %newret178, %if.then335 ], [ %newret206, %if.then311 ], [ %newret150, %if.end426 ], [ %newret164, %if.then356 ]
  %done_drained.10 = phi i1 [ true, %if.end ], [ true, %if.then87 ], [ true, %if.then482 ], [ true, %if.then71 ], [ %done_drained.ret, %if.end95.i ], [ true, %if.then131 ], [ true, %if.then160 ], [ true, %if.end204 ], [ true, %if.then174 ], [ true, %if.then249 ], [ true, %if.then328 ], [ true, %if.then335 ], [ true, %if.then311 ], [ true, %if.end426 ], [ true, %if.then356 ]
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
