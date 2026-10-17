define internal fastcc void @"laya::full::(anonymous namespace)::Controller::linear"(i16* noalias nocapture align 512 %agg.result.01, i32* noalias nocapture align 512 %agg.result.12, i64* noalias nocapture align 512 %agg.result.23, i8 addrspace(1)* noalias nocapture %embedding, i64 %this_memory.0, i8 addrspace(1)* noalias nocapture %io, i64 %this_memory.2, i8 addrspace(1)* noalias nocapture %w_q0, i64 %this_memory.4, i8 addrspace(1)* noalias nocapture %w_q1, i64 %this_memory.6, i8 addrspace(1)* noalias nocapture %w_scale, i64 %this_memory.8, i8 addrspace(1)* noalias nocapture %aux, i64 %this_memory.10, i8 addrspace(1)* noalias nocapture %state0, i64 %this_memory.12, i8 addrspace(1)* noalias nocapture %state1, i64 %this_memory.14, i8 addrspace(1)* noalias nocapture %qkv0, i64 %this_memory.16, i8 addrspace(1)* noalias nocapture %qkv1, i64 %this_memory.18, i8 addrspace(1)* noalias nocapture %ff0, i64 %this_memory.20, i8 addrspace(1)* noalias nocapture %ff1, i64 %this_memory.22, i8 addrspace(1)* noalias nocapture %att_out, i64 %this_memory.24, i8* noalias nocapture align 512 %this_error_stage, i8* noalias nocapture align 512 %this_error_op, i32* noalias nocapture align 512 %this_error_task_id, i8* noalias nocapture align 512 %this_current_stage, i8* noalias nocapture align 512 %this_current_op, i8 %key_layer.val, [23 x i192]* noalias align 512 %hidden, i64 %source, i8 zeroext %layer, i8 %dst_ref_id, i8 %dst_ref_bank, i32 %dst_ref_epoch, i8* noalias nocapture align 512 %output_ref_id, i8* noalias nocapture align 512 %output_ref_bank, i32* noalias nocapture align 512 %output_ref_epoch, i8* noalias nocapture align 512 %output_region, i8* noalias nocapture align 512 %output_stage, i8* noalias nocapture align 512 %output_layer, i8* noalias nocapture align 512 %output_batch, i8* noalias nocapture align 512 %output_row_space, i16* noalias nocapture align 512 %output_row0, i16* noalias nocapture align 512 %output_rows, i16* noalias nocapture align 512 %output_width, i8* noalias nocapture align 512 %output_content) unnamed_addr #1 {
entry:
  call void (...) @_ssdm_op_SpecBRAMWithByteEnable([23 x i192]* %hidden)
  %descriptor.name = alloca [48 x i8], i64 1, align 512
  %descriptor.key.family = alloca i8, i64 1, align 512
  %descriptor.key.layer = alloca i8, i64 1, align 512
  %descriptor.K = alloca i16, i64 1, align 512
  %descriptor.N = alloca i16, i64 1, align 512
  %descriptor.dtype = alloca i8, i64 1, align 512
  %descriptor.bias_kind = alloca i8, i64 1, align 512
  %descriptor.q_base = alloca [2 x i32], i64 1, align 512
  %descriptor.q_span = alloca [2 x i32], i64 1, align 512
  %descriptor.scale_base = alloca i32, i64 1, align 512
  %descriptor.scale_span = alloca i32, i64 1, align 512
  %descriptor.aux_base = alloca i32, i64 1, align 512
  %descriptor.aux_span = alloca i32, i64 1, align 512
  %descriptor.bias_base = alloca i32, i64 1, align 512
  %descriptor.bias_span = alloca i32, i64 1, align 512
  %descriptor.source_sha256 = alloca [32 x i8], i64 1, align 512
  %descriptor.bias_sha256 = alloca [32 x i8], i64 1, align 512
  %c.code = alloca i16, i64 1, align 512
  %c.detail = alloca i32, i64 1, align 512
  %c.bad_element = alloca i64, i64 1, align 512
  store i8 2, i8* %this_current_stage, align 512, !alias.scope !16247, !noalias !16250
  store i8 48, i8* %this_current_op, align 512, !alias.scope !16250, !noalias !16247
  br label %arrayinit.body.i

arrayinit.body.i:                                 ; preds = %arrayinit.body.i, %entry
  %arrayinit.curidx.i = phi i64 [ 0, %entry ], [ %add.ln52, %arrayinit.body.i ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 48, i64 48, i64 48), !fpga.pragma.source !33
  %this.name.addr = getelementptr [48 x i8], [48 x i8]* %descriptor.name, i64 0, i64 %arrayinit.curidx.i
  %add.ln52 = add nuw nsw i64 %arrayinit.curidx.i, 1
  store i8 0, i8* %this.name.addr, align 1, !alias.scope !16252, !noalias !16255
  %icmp.ln52 = icmp eq i64 %arrayinit.curidx.i, 47
  br i1 %icmp.ln52, label %arrayinit.end.i, label %arrayinit.body.i, !llvm.loop !16272

arrayinit.end.i:                                  ; preds = %arrayinit.body.i
  store i8 0, i8* @descriptor.key.family.constprop, align 512, !alias.scope !16273, !noalias !16276
  store i8 0, i8* @descriptor.key.family.constprop170, align 512, !alias.scope !16273, !noalias !16276
  store i8 0, i8* @descriptor.key.family.constprop193, align 512, !alias.scope !16273, !noalias !16276
  store i8 0, i8* %descriptor.key.family, align 512, !alias.scope !16273, !noalias !16276
  store i8 -1, i8* @descriptor.key.layer.constprop, align 512, !alias.scope !16278, !noalias !16279
  store i8 -1, i8* @descriptor.key.layer.constprop171, align 512, !alias.scope !16278, !noalias !16279
  store i8 -1, i8* @descriptor.key.layer.constprop194, align 512, !alias.scope !16278, !noalias !16279
  store i8 -1, i8* %descriptor.key.layer, align 512, !alias.scope !16278, !noalias !16279
  store i16 0, i16* @descriptor.K.constprop, align 512, !alias.scope !16280, !noalias !16281
  store i16 0, i16* @descriptor.K.constprop172, align 512, !alias.scope !16280, !noalias !16281
  store i16 0, i16* @descriptor.K.constprop195, align 512, !alias.scope !16280, !noalias !16281
  store i16 0, i16* %descriptor.K, align 512, !alias.scope !16280, !noalias !16281
  store i16 0, i16* @descriptor.N.constprop, align 512, !alias.scope !16282, !noalias !16283
  store i16 0, i16* @descriptor.N.constprop173, align 512, !alias.scope !16282, !noalias !16283
  store i16 0, i16* @descriptor.N.constprop196, align 512, !alias.scope !16282, !noalias !16283
  store i16 0, i16* %descriptor.N, align 512, !alias.scope !16282, !noalias !16283
  store i8 0, i8* @descriptor.dtype.constprop, align 512, !alias.scope !16284, !noalias !16285
  store i8 0, i8* @descriptor.dtype.constprop174, align 512, !alias.scope !16284, !noalias !16285
  store i8 0, i8* @descriptor.dtype.constprop197, align 512, !alias.scope !16284, !noalias !16285
  store i8 0, i8* %descriptor.dtype, align 512, !alias.scope !16284, !noalias !16285
  store i8 0, i8* @descriptor.bias_kind.constprop, align 512, !alias.scope !16286, !noalias !16287
  store i8 0, i8* @descriptor.bias_kind.constprop175, align 512, !alias.scope !16286, !noalias !16287
  store i8 0, i8* @descriptor.bias_kind.constprop198, align 512, !alias.scope !16286, !noalias !16287
  store i8 0, i8* %descriptor.bias_kind, align 512, !alias.scope !16286, !noalias !16287
  br label %arrayinit.body3.i

arrayinit.body3.i:                                ; preds = %arrayinit.body3.i, %arrayinit.end.i
  %arrayinit.curidx4.i = phi i64 [ 0, %arrayinit.end.i ], [ %add.ln56, %arrayinit.body3.i ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 2, i64 2, i64 2), !fpga.pragma.source !33
  %this.q_base.addr = getelementptr [2 x i32], [2 x i32]* %descriptor.q_base, i64 0, i64 %arrayinit.curidx4.i
  %add.ln56 = add nuw nsw i64 %arrayinit.curidx4.i, 1
  store i32 0, i32* %this.q_base.addr, align 4, !alias.scope !16288, !noalias !16289
  %icmp.ln56 = icmp eq i64 %arrayinit.curidx4.i, 1
  br i1 %icmp.ln56, label %arrayinit.body10.i.preheader, label %arrayinit.body3.i, !llvm.loop !16290

arrayinit.body10.i.preheader:                     ; preds = %arrayinit.body3.i
  br label %arrayinit.body10.i

arrayinit.body10.i:                               ; preds = %arrayinit.body10.i, %arrayinit.body10.i.preheader
  %arrayinit.curidx11.i = phi i64 [ %add.ln56.9, %arrayinit.body10.i ], [ 0, %arrayinit.body10.i.preheader ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 2, i64 2, i64 2), !fpga.pragma.source !33
  %this.q_span.addr = getelementptr [2 x i32], [2 x i32]* %descriptor.q_span, i64 0, i64 %arrayinit.curidx11.i
  %add.ln56.9 = add nuw nsw i64 %arrayinit.curidx11.i, 1
  store i32 0, i32* %this.q_span.addr, align 4, !alias.scope !16291, !noalias !16292
  %icmp.ln56.15 = icmp eq i64 %arrayinit.curidx11.i, 1
  br i1 %icmp.ln56.15, label %arrayinit.end15.i, label %arrayinit.body10.i, !llvm.loop !16293

arrayinit.end15.i:                                ; preds = %arrayinit.body10.i
  store i32 0, i32* @descriptor.scale_base.constprop, align 512, !alias.scope !16294, !noalias !16295
  store i32 0, i32* @descriptor.scale_base.constprop176, align 512, !alias.scope !16294, !noalias !16295
  store i32 0, i32* @descriptor.scale_base.constprop199, align 512, !alias.scope !16294, !noalias !16295
  store i32 0, i32* %descriptor.scale_base, align 512, !alias.scope !16294, !noalias !16295
  store i32 0, i32* @descriptor.scale_span.constprop, align 512, !alias.scope !16296, !noalias !16297
  store i32 0, i32* @descriptor.scale_span.constprop177, align 512, !alias.scope !16296, !noalias !16297
  store i32 0, i32* @descriptor.scale_span.constprop200, align 512, !alias.scope !16296, !noalias !16297
  store i32 0, i32* %descriptor.scale_span, align 512, !alias.scope !16296, !noalias !16297
  store i32 0, i32* @descriptor.aux_base.constprop, align 512, !alias.scope !16298, !noalias !16299
  store i32 0, i32* @descriptor.aux_base.constprop178, align 512, !alias.scope !16298, !noalias !16299
  store i32 0, i32* @descriptor.aux_base.constprop201, align 512, !alias.scope !16298, !noalias !16299
  store i32 0, i32* %descriptor.aux_base, align 512, !alias.scope !16298, !noalias !16299
  store i32 0, i32* @descriptor.aux_span.constprop, align 512, !alias.scope !16300, !noalias !16301
  store i32 0, i32* @descriptor.aux_span.constprop179, align 512, !alias.scope !16300, !noalias !16301
  store i32 0, i32* @descriptor.aux_span.constprop202, align 512, !alias.scope !16300, !noalias !16301
  store i32 0, i32* %descriptor.aux_span, align 512, !alias.scope !16300, !noalias !16301
  store i32 0, i32* @descriptor.bias_base.constprop, align 512, !alias.scope !16302, !noalias !16303
  store i32 0, i32* @descriptor.bias_base.constprop180, align 512, !alias.scope !16302, !noalias !16303
  store i32 0, i32* @descriptor.bias_base.constprop203, align 512, !alias.scope !16302, !noalias !16303
  store i32 0, i32* %descriptor.bias_base, align 512, !alias.scope !16302, !noalias !16303
  store i32 0, i32* @descriptor.bias_span.constprop, align 512, !alias.scope !16304, !noalias !16305
  store i32 0, i32* @descriptor.bias_span.constprop181, align 512, !alias.scope !16304, !noalias !16305
  store i32 0, i32* @descriptor.bias_span.constprop204, align 512, !alias.scope !16304, !noalias !16305
  store i32 0, i32* %descriptor.bias_span, align 512, !alias.scope !16304, !noalias !16305
  br label %arrayinit.body17.i

arrayinit.body17.i:                               ; preds = %arrayinit.body17.i, %arrayinit.end15.i
  %arrayinit.curidx18.i = phi i64 [ 0, %arrayinit.end15.i ], [ %add.ln60, %arrayinit.body17.i ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 32, i64 32, i64 32), !fpga.pragma.source !33
  %this.source_sha256.addr = getelementptr [32 x i8], [32 x i8]* %descriptor.source_sha256, i64 0, i64 %arrayinit.curidx18.i
  %add.ln60 = add nuw nsw i64 %arrayinit.curidx18.i, 1
  store i8 0, i8* %this.source_sha256.addr, align 1, !alias.scope !16306, !noalias !16307
  %icmp.ln60 = icmp eq i64 %arrayinit.curidx18.i, 31
  br i1 %icmp.ln60, label %arrayinit.body24.i.preheader, label %arrayinit.body17.i, !llvm.loop !16308

arrayinit.body24.i.preheader:                     ; preds = %arrayinit.body17.i
  br label %arrayinit.body24.i

arrayinit.body24.i:                               ; preds = %arrayinit.body24.i, %arrayinit.body24.i.preheader
  %arrayinit.curidx25.i = phi i64 [ %add.ln61, %arrayinit.body24.i ], [ 0, %arrayinit.body24.i.preheader ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 32, i64 32, i64 32), !fpga.pragma.source !33
  %this.bias_sha256.addr = getelementptr [32 x i8], [32 x i8]* %descriptor.bias_sha256, i64 0, i64 %arrayinit.curidx25.i
  %add.ln61 = add nuw nsw i64 %arrayinit.curidx25.i, 1
  store i8 0, i8* %this.bias_sha256.addr, align 1, !alias.scope !16309, !noalias !16310
  %icmp.ln61 = icmp eq i64 %arrayinit.curidx25.i, 31
  br i1 %icmp.ln61, label %_ZN4laya4full20FullWeightDescriptorC2Ev.exit, label %arrayinit.body24.i, !llvm.loop !16311

_ZN4laya4full20FullWeightDescriptorC2Ev.exit:     ; preds = %arrayinit.body24.i
  call fastcc void @"laya::full::(anonymous namespace)::Controller::load_weight"(i16* %c.code, i32* %c.detail, i64* %c.bad_element, i8 addrspace(1)* %embedding, i64 %this_memory.0, i8 addrspace(1)* %io, i64 %this_memory.2, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i8 addrspace(1)* %aux, i64 %this_memory.10, i8 addrspace(1)* %state0, i64 %this_memory.12, i8 addrspace(1)* %state1, i64 %this_memory.14, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i8 addrspace(1)* %ff0, i64 %this_memory.20, i8 addrspace(1)* %ff1, i64 %this_memory.22, i8 addrspace(1)* %att_out, i64 %this_memory.24, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i8 1, i8 %key_layer.val, i8 2, i8 %layer, [48 x i8]* %descriptor.name, i8* %descriptor.key.family, i8* %descriptor.key.layer, i16* %descriptor.K, i16* %descriptor.N, i8* %descriptor.dtype, i8* %descriptor.bias_kind, [2 x i32]* %descriptor.q_base, [2 x i32]* %descriptor.q_span, i32* %descriptor.scale_base, i32* %descriptor.scale_span, i32* %descriptor.aux_base, i32* %descriptor.aux_span, i32* %descriptor.bias_base, i32* %descriptor.bias_span, [32 x i8]* %descriptor.source_sha256, [32 x i8]* %descriptor.bias_sha256)
  %c.code.load = load i16, i16* %c.code, align 512, !alias.scope !16312
  %icmp.ln9 = icmp eq i16 %c.code.load, 0
  br i1 %icmp.ln9, label %if.end, label %if.then

if.then:                                          ; preds = %_ZN4laya4full20FullWeightDescriptorC2Ev.exit
  %c.detail.load = load i32, i32* %c.detail, align 512
  %c.bad_element.load = load i64, i64* %c.bad_element, align 512
  br label %cleanup119

if.end:                                           ; preds = %_ZN4laya4full20FullWeightDescriptorC2Ev.exit
  store i8 2, i8* %this_current_stage, align 512, !alias.scope !16315, !noalias !16318
  store i8 48, i8* %this_current_op, align 512, !alias.scope !16318, !noalias !16315
  %add.ln205 = add nuw i64 %source, 12
  %udiv.ln205 = udiv i64 %add.ln205, 24
  %hidden.addr = getelementptr [23 x i192], [23 x i192]* %hidden, i64 0, i64 %udiv.ln205
  %hidden.load = load i192, i192* %hidden.addr, align 32
  call void (...) @_ssdm_SpecKeepArrayLoad(i192 %hidden.load) #1
  %mul.ln205 = mul i64 %udiv.ln205, -24
  %add.ln205.2 = add i64 %mul.ln205, %add.ln205
  %zext.ln205 = zext i64 %add.ln205.2 to i192
  %shl.ln205 = shl nuw nsw i192 %zext.ln205, 3
  %lshr.ln205 = lshr i192 %hidden.load, %shl.ln205
  %space = trunc i192 %lshr.ln205 to i8
  %icmp.ln63 = icmp eq i8 %space, 0
  %"(anonymous namespace)::runtime.inputs.identity.S.load" = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.S", align 512
  %icmp.ln64 = icmp eq i8 %space, 1
  %select.ln64 = select i1 %icmp.ln64, i16 16, i16 1
  %select.ln63 = select i1 %icmp.ln63, i16 %"(anonymous namespace)::runtime.inputs.identity.S.load", i16 %select.ln64
  store i8 %dst_ref_id, i8* %output_ref_id, align 512
  store i8 %dst_ref_bank, i8* %output_ref_bank, align 512
  store i32 %dst_ref_epoch, i32* %output_ref_epoch, align 512
  store i8 0, i8* %output_region, align 512
  store i8 2, i8* %output_stage, align 512
  store i8 %layer, i8* %output_layer, align 512
  store i8 -1, i8* %output_batch, align 512
  store i8 %space, i8* %output_row_space, align 512
  store i16 0, i16* %output_row0, align 512
  store i16 %select.ln63, i16* %output_rows, align 512
  store i16 64, i16* %output_width, align 512
  store i8 2, i8* %output_content, align 512
  br label %cleanup119

cleanup119:                                       ; preds = %if.end, %if.then
  %storemerge2 = phi i16 [ %c.code.load, %if.then ], [ 8, %if.end ]
  %storemerge1 = phi i32 [ %c.detail.load, %if.then ], [ 117440516, %if.end ]
  %storemerge = phi i64 [ %c.bad_element.load, %if.then ], [ -1, %if.end ]
  store i16 %storemerge2, i16* %agg.result.01, align 512
  store i32 %storemerge1, i32* %agg.result.12, align 512
  store i64 %storemerge, i64* %agg.result.23, align 512
  ret void
}
