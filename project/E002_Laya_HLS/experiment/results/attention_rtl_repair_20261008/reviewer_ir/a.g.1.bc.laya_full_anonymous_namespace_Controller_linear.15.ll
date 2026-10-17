define internal fastcc void @"laya::full::(anonymous namespace)::Controller::linear.15"(i16* noalias nocapture align 512 %agg.result.01, i32* noalias nocapture align 512 %agg.result.12, i64* noalias nocapture align 512 %agg.result.23, i8 addrspace(1)* noalias nocapture %embedding, i64 %this_memory.0, i8 addrspace(1)* noalias nocapture %io, i64 %this_memory.2, i8 addrspace(1)* noalias nocapture %w_q0, i64 %this_memory.4, i8 addrspace(1)* noalias nocapture %w_q1, i64 %this_memory.6, i8 addrspace(1)* noalias nocapture %w_scale, i64 %this_memory.8, i8 addrspace(1)* noalias nocapture %aux, i64 %this_memory.10, i8 addrspace(1)* noalias nocapture %state0, i64 %this_memory.12, i8 addrspace(1)* noalias nocapture %state1, i64 %this_memory.14, i8 addrspace(1)* noalias nocapture %qkv0, i64 %this_memory.16, i8 addrspace(1)* noalias nocapture %qkv1, i64 %this_memory.18, i8 addrspace(1)* noalias nocapture %ff0, i64 %this_memory.20, i8 addrspace(1)* noalias nocapture %ff1, i64 %this_memory.22, i8 addrspace(1)* noalias nocapture %att_out, i64 %this_memory.24, i8* noalias nocapture align 512 %this_error_stage, i8* noalias nocapture align 512 %this_error_op, i32* noalias nocapture align 512 %this_error_task_id, i8* noalias nocapture align 512 %this_current_stage, i8* noalias nocapture align 512 %this_current_op, i8 zeroext %op, i8 %key_family.val, i8 %key_layer.val, i8 %source_ref_id.val, i8 %source_ref_bank.val, i32 %source_ref_epoch.val, i8 %source_region.val, i8 %source_stage.val, i8 %source_layer.val, i8 %source_batch.val, i8 %source_row_space.val, i16 %source_row0.val, i16 %source_rows.val, i16 %source_width.val, i8 %source_content.val, i8 zeroext %stage, i8 zeroext %layer, i8 %dst_ref_id, i8 %dst_ref_bank, i32 %dst_ref_epoch, i8 zeroext %dst_region, i8* noalias nocapture align 512 %output_ref_id, i8* noalias nocapture align 512 %output_ref_bank, i32* noalias nocapture align 512 %output_ref_epoch, i8* noalias nocapture align 512 %output_region, i8* noalias nocapture align 512 %output_stage, i8* noalias nocapture align 512 %output_layer, i8* noalias nocapture align 512 %output_batch, i8* noalias nocapture align 512 %output_row_space, i16* noalias nocapture align 512 %output_row0, i16* noalias nocapture align 512 %output_rows, i16* noalias nocapture align 512 %output_width, i8* noalias nocapture align 512 %output_content) unnamed_addr #1 {
entry:
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
  %c.code.316 = alloca i16, i64 1, align 512
  %c.detail.312 = alloca i32, i64 1, align 512
  %c.bad_element.287 = alloca i64, i64 1, align 512
  %ref.tmp23.0265 = alloca i16, i64 1, align 512
  %ref.tmp23.1266 = alloca i32, i64 1, align 512
  %ref.tmp23.2267 = alloca i64, i64 1, align 512
  %ref.tmp52.0243 = alloca i8, i64 1, align 512
  %ref.tmp52.1244 = alloca i8, i64 1, align 512
  %ref.tmp52.2245 = alloca i32, i64 1, align 512
  %ref.tmp58.0231 = alloca i16, i64 1, align 512
  %ref.tmp58.1232 = alloca i32, i64 1, align 512
  %ref.tmp58.2233 = alloca i64, i64 1, align 512
  %ref.tmp73.0203 = alloca i8, i64 1, align 512
  %ref.tmp73.1204 = alloca i8, i64 1, align 512
  %ref.tmp73.2205 = alloca i32, i64 1, align 512
  %ref.tmp81.0197 = alloca i16, i64 1, align 512
  %ref.tmp81.1198 = alloca i32, i64 1, align 512
  %ref.tmp81.2199 = alloca i64, i64 1, align 512
  %ref.tmp103.0185 = alloca i16, i64 1, align 512
  %ref.tmp103.1186 = alloca i32, i64 1, align 512
  %ref.tmp103.2187 = alloca i64, i64 1, align 512
  store i8 %stage, i8* %this_current_stage, align 512, !alias.scope !15995, !noalias !15998
  store i8 %op, i8* %this_current_op, align 512, !alias.scope !15998, !noalias !15995
  br label %arrayinit.body.i

arrayinit.body.i:                                 ; preds = %arrayinit.body.i, %entry
  %arrayinit.curidx.i = phi i64 [ 0, %entry ], [ %add.ln52, %arrayinit.body.i ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 48, i64 48, i64 48), !fpga.pragma.source !33
  %this.name.addr = getelementptr [48 x i8], [48 x i8]* %descriptor.name, i64 0, i64 %arrayinit.curidx.i
  %add.ln52 = add nuw nsw i64 %arrayinit.curidx.i, 1
  store i8 0, i8* %this.name.addr, align 1, !alias.scope !16000, !noalias !16003
  %icmp.ln52 = icmp eq i64 %arrayinit.curidx.i, 47
  br i1 %icmp.ln52, label %arrayinit.end.i, label %arrayinit.body.i, !llvm.loop !16020

arrayinit.end.i:                                  ; preds = %arrayinit.body.i
  store i8 0, i8* @descriptor.key.family.constprop159, align 512, !alias.scope !16021, !noalias !16024
  store i8 0, i8* @descriptor.key.family.constprop182, align 512, !alias.scope !16021, !noalias !16024
  store i8 0, i8* @descriptor.key.family.constprop205, align 512, !alias.scope !16021, !noalias !16024
  store i8 0, i8* %descriptor.key.family, align 512, !alias.scope !16021, !noalias !16024
  store i8 -1, i8* @descriptor.key.layer.constprop160, align 512, !alias.scope !16026, !noalias !16027
  store i8 -1, i8* @descriptor.key.layer.constprop183, align 512, !alias.scope !16026, !noalias !16027
  store i8 -1, i8* @descriptor.key.layer.constprop206, align 512, !alias.scope !16026, !noalias !16027
  store i8 -1, i8* %descriptor.key.layer, align 512, !alias.scope !16026, !noalias !16027
  store i16 0, i16* %descriptor.K, align 512, !alias.scope !16028, !noalias !16029
  store i16 0, i16* %descriptor.N, align 512, !alias.scope !16030, !noalias !16031
  store i8 0, i8* @descriptor.dtype.constprop161, align 512, !alias.scope !16032, !noalias !16033
  store i8 0, i8* @descriptor.dtype.constprop184, align 512, !alias.scope !16032, !noalias !16033
  store i8 0, i8* @descriptor.dtype.constprop207, align 512, !alias.scope !16032, !noalias !16033
  store i8 0, i8* %descriptor.dtype, align 512, !alias.scope !16032, !noalias !16033
  store i8 0, i8* %descriptor.bias_kind, align 512, !alias.scope !16034, !noalias !16035
  br label %arrayinit.body3.i

arrayinit.body3.i:                                ; preds = %arrayinit.body3.i, %arrayinit.end.i
  %arrayinit.curidx4.i = phi i64 [ 0, %arrayinit.end.i ], [ %add.ln56, %arrayinit.body3.i ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 2, i64 2, i64 2), !fpga.pragma.source !33
  %this.q_base.addr = getelementptr [2 x i32], [2 x i32]* %descriptor.q_base, i64 0, i64 %arrayinit.curidx4.i
  %add.ln56 = add nuw nsw i64 %arrayinit.curidx4.i, 1
  store i32 0, i32* %this.q_base.addr, align 4, !alias.scope !16036, !noalias !16037
  %icmp.ln56 = icmp eq i64 %arrayinit.curidx4.i, 1
  br i1 %icmp.ln56, label %arrayinit.body10.i.preheader, label %arrayinit.body3.i, !llvm.loop !16038

arrayinit.body10.i.preheader:                     ; preds = %arrayinit.body3.i
  br label %arrayinit.body10.i

arrayinit.body10.i:                               ; preds = %arrayinit.body10.i, %arrayinit.body10.i.preheader
  %arrayinit.curidx11.i = phi i64 [ %add.ln56.8, %arrayinit.body10.i ], [ 0, %arrayinit.body10.i.preheader ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 2, i64 2, i64 2), !fpga.pragma.source !33
  %this.q_span.addr = getelementptr [2 x i32], [2 x i32]* %descriptor.q_span, i64 0, i64 %arrayinit.curidx11.i
  %add.ln56.8 = add nuw nsw i64 %arrayinit.curidx11.i, 1
  store i32 0, i32* %this.q_span.addr, align 4, !alias.scope !16039, !noalias !16040
  %icmp.ln56.14 = icmp eq i64 %arrayinit.curidx11.i, 1
  br i1 %icmp.ln56.14, label %arrayinit.end15.i, label %arrayinit.body10.i, !llvm.loop !16041

arrayinit.end15.i:                                ; preds = %arrayinit.body10.i
  store i32 0, i32* @descriptor.scale_base.constprop162, align 512, !alias.scope !16042, !noalias !16043
  store i32 0, i32* @descriptor.scale_base.constprop185, align 512, !alias.scope !16042, !noalias !16043
  store i32 0, i32* @descriptor.scale_base.constprop208, align 512, !alias.scope !16042, !noalias !16043
  store i32 0, i32* %descriptor.scale_base, align 512, !alias.scope !16042, !noalias !16043
  store i32 0, i32* @descriptor.scale_span.constprop163, align 512, !alias.scope !16044, !noalias !16045
  store i32 0, i32* @descriptor.scale_span.constprop186, align 512, !alias.scope !16044, !noalias !16045
  store i32 0, i32* @descriptor.scale_span.constprop209, align 512, !alias.scope !16044, !noalias !16045
  store i32 0, i32* %descriptor.scale_span, align 512, !alias.scope !16044, !noalias !16045
  store i32 0, i32* @descriptor.aux_base.constprop164, align 512, !alias.scope !16046, !noalias !16047
  store i32 0, i32* @descriptor.aux_base.constprop187, align 512, !alias.scope !16046, !noalias !16047
  store i32 0, i32* @descriptor.aux_base.constprop210, align 512, !alias.scope !16046, !noalias !16047
  store i32 0, i32* %descriptor.aux_base, align 512, !alias.scope !16046, !noalias !16047
  store i32 0, i32* @descriptor.aux_span.constprop165, align 512, !alias.scope !16048, !noalias !16049
  store i32 0, i32* @descriptor.aux_span.constprop188, align 512, !alias.scope !16048, !noalias !16049
  store i32 0, i32* @descriptor.aux_span.constprop211, align 512, !alias.scope !16048, !noalias !16049
  store i32 0, i32* %descriptor.aux_span, align 512, !alias.scope !16048, !noalias !16049
  store i32 0, i32* @descriptor.bias_base.constprop166, align 512, !alias.scope !16050, !noalias !16051
  store i32 0, i32* @descriptor.bias_base.constprop189, align 512, !alias.scope !16050, !noalias !16051
  store i32 0, i32* @descriptor.bias_base.constprop212, align 512, !alias.scope !16050, !noalias !16051
  store i32 0, i32* %descriptor.bias_base, align 512, !alias.scope !16050, !noalias !16051
  store i32 0, i32* @descriptor.bias_span.constprop167, align 512, !alias.scope !16052, !noalias !16053
  store i32 0, i32* @descriptor.bias_span.constprop190, align 512, !alias.scope !16052, !noalias !16053
  store i32 0, i32* @descriptor.bias_span.constprop213, align 512, !alias.scope !16052, !noalias !16053
  store i32 0, i32* %descriptor.bias_span, align 512, !alias.scope !16052, !noalias !16053
  br label %arrayinit.body17.i

arrayinit.body17.i:                               ; preds = %arrayinit.body17.i, %arrayinit.end15.i
  %arrayinit.curidx18.i = phi i64 [ 0, %arrayinit.end15.i ], [ %add.ln60, %arrayinit.body17.i ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 32, i64 32, i64 32), !fpga.pragma.source !33
  %this.source_sha256.addr = getelementptr [32 x i8], [32 x i8]* %descriptor.source_sha256, i64 0, i64 %arrayinit.curidx18.i
  %add.ln60 = add nuw nsw i64 %arrayinit.curidx18.i, 1
  store i8 0, i8* %this.source_sha256.addr, align 1, !alias.scope !16054, !noalias !16055
  %icmp.ln60 = icmp eq i64 %arrayinit.curidx18.i, 31
  br i1 %icmp.ln60, label %arrayinit.body24.i.preheader, label %arrayinit.body17.i, !llvm.loop !16056

arrayinit.body24.i.preheader:                     ; preds = %arrayinit.body17.i
  br label %arrayinit.body24.i

arrayinit.body24.i:                               ; preds = %arrayinit.body24.i, %arrayinit.body24.i.preheader
  %arrayinit.curidx25.i = phi i64 [ %add.ln61, %arrayinit.body24.i ], [ 0, %arrayinit.body24.i.preheader ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 32, i64 32, i64 32), !fpga.pragma.source !33
  %this.bias_sha256.addr = getelementptr [32 x i8], [32 x i8]* %descriptor.bias_sha256, i64 0, i64 %arrayinit.curidx25.i
  %add.ln61 = add nuw nsw i64 %arrayinit.curidx25.i, 1
  store i8 0, i8* %this.bias_sha256.addr, align 1, !alias.scope !16057, !noalias !16058
  %icmp.ln61 = icmp eq i64 %arrayinit.curidx25.i, 31
  br i1 %icmp.ln61, label %_ZN4laya4full20FullWeightDescriptorC2Ev.exit, label %arrayinit.body24.i, !llvm.loop !16059

_ZN4laya4full20FullWeightDescriptorC2Ev.exit:     ; preds = %arrayinit.body24.i
  call fastcc void @"laya::full::(anonymous namespace)::Controller::load_weight"(i16* %c.code.316, i32* %c.detail.312, i64* %c.bad_element.287, i8 addrspace(1)* %embedding, i64 %this_memory.0, i8 addrspace(1)* %io, i64 %this_memory.2, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i8 addrspace(1)* %aux, i64 %this_memory.10, i8 addrspace(1)* %state0, i64 %this_memory.12, i8 addrspace(1)* %state1, i64 %this_memory.14, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i8 addrspace(1)* %ff0, i64 %this_memory.20, i8 addrspace(1)* %ff1, i64 %this_memory.22, i8 addrspace(1)* %att_out, i64 %this_memory.24, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i8 %key_family.val, i8 %key_layer.val, i8 %stage, i8 %layer, [48 x i8]* %descriptor.name, i8* %descriptor.key.family, i8* %descriptor.key.layer, i16* %descriptor.K, i16* %descriptor.N, i8* %descriptor.dtype, i8* %descriptor.bias_kind, [2 x i32]* %descriptor.q_base, [2 x i32]* %descriptor.q_span, i32* %descriptor.scale_base, i32* %descriptor.scale_span, i32* %descriptor.aux_base, i32* %descriptor.aux_span, i32* %descriptor.bias_base, i32* %descriptor.bias_span, [32 x i8]* %descriptor.source_sha256, [32 x i8]* %descriptor.bias_sha256)
  %c.code.load = load i16, i16* %c.code.316, align 512, !alias.scope !16060
  %icmp.ln9 = icmp eq i16 %c.code.load, 0
  br i1 %icmp.ln9, label %if.end, label %if.then

if.then:                                          ; preds = %_ZN4laya4full20FullWeightDescriptorC2Ev.exit
  %c.detail.load = load i32, i32* %c.detail.312, align 512
  %c.bad_element.load = load i64, i64* %c.bad_element.287, align 512
  br label %cleanup119

if.end:                                           ; preds = %_ZN4laya4full20FullWeightDescriptorC2Ev.exit
  store i8 %stage, i8* %this_current_stage, align 512, !alias.scope !16063, !noalias !16066
  store i8 %op, i8* %this_current_op, align 512, !alias.scope !16066, !noalias !16063
  %width = load i16, i16* %descriptor.N, align 512
  %icmp.ln63 = icmp eq i8 %source_row_space.val, 0
  %"(anonymous namespace)::runtime.inputs.identity.S.load" = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.S", align 512
  %icmp.ln64 = icmp eq i8 %source_row_space.val, 1
  %select.ln64 = select i1 %icmp.ln64, i16 16, i16 1
  %select.ln63 = select i1 %icmp.ln63, i16 %"(anonymous namespace)::runtime.inputs.identity.S.load", i16 %select.ln64
  store i8 %dst_ref_id, i8* %output_ref_id, align 512
  store i8 %dst_ref_bank, i8* %output_ref_bank, align 512
  store i32 %dst_ref_epoch, i32* %output_ref_epoch, align 512
  store i8 %dst_region, i8* %output_region, align 512
  store i8 %stage, i8* %output_stage, align 512
  store i8 %layer, i8* %output_layer, align 512
  store i8 -1, i8* %output_batch, align 512
  store i8 %source_row_space.val, i8* %output_row_space, align 512
  store i16 0, i16* %output_row0, align 512
  store i16 %select.ln63, i16* %output_rows, align 512
  store i16 %width, i16* %output_width, align 512
  store i8 1, i8* %output_content, align 512
  %scorer_lease = icmp eq i8 %op, 54
  br i1 %scorer_lease, label %if.end26, label %if.then22

if.then22:                                        ; preds = %if.end
  call fastcc void @"laya::full::full_claim_owner"(i16* %ref.tmp23.0265, i32* %ref.tmp23.1266, i64* %ref.tmp23.2267, i8 %dst_ref_id, i8 %dst_ref_bank, i32 %dst_ref_epoch, i8 %dst_region, i8 %stage, i8 %layer, i8 -1, i8 %source_row_space.val, i16 0, i16 %select.ln63, i16 %width, i8 1)
  %c.code.314 = load i16, i16* %ref.tmp23.0265, align 512
  %c.detail.308 = load i32, i32* %ref.tmp23.1266, align 512
  %c.bad_element.283 = load i64, i64* %ref.tmp23.2267, align 512
  store i16 %c.code.314, i16* %c.code.316, align 512
  store i32 %c.detail.308, i32* %c.detail.312, align 512
  store i64 %c.bad_element.283, i64* %c.bad_element.287, align 512
  br label %if.end26

if.end26:                                         ; preds = %if.then22, %if.end
  %.086 = phi i16 [ %c.code.314, %if.then22 ], [ 0, %if.end ]
  %icmp.ln9.282 = icmp eq i16 %.086, 0
  br i1 %icmp.ln9.282, label %if.end29, label %if.then28

if.then28:                                        ; preds = %if.end26
  %c.detail.load.3 = load i32, i32* %c.detail.312, align 512
  %c.bad_element.load.3 = load i64, i64* %c.bad_element.287, align 512
  br label %cleanup119

if.end29:                                         ; preds = %if.end26
  %rows = zext i16 %source_rows.val to i32
  %quant.K = load i16, i16* %descriptor.K, align 512
  %zext.ln230 = zext i16 %quant.K to i32
  %t.bias_kind = load i8, i8* %descriptor.bias_kind, align 512
  %icmp.ln220 = icmp eq i16 %source_rows.val, 0
  %zext.ln244 = zext i16 %width to i32
  %icmp.ln730 = icmp ne i8 %source_content.val, 1
  %zext.ln11 = zext i8 %source_ref_id.val to i32
  %shl.ln11 = shl nuw nsw i32 %zext.ln11, 16
  %or.ln11 = or i32 %shl.ln11, 67108873
  %icmp.ln731 = icmp eq i8 %source_ref_id.val, 0
  %or.ln730 = or i1 %icmp.ln731, %icmp.ln730
  br label %for.cond

for.cond:                                         ; preds = %for.inc92, %if.end29
  %b = phi i32 [ 0, %if.end29 ], [ %b.21, %for.inc92 ]
  %"(anonymous namespace)::runtime.inputs.identity.B.load" = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.B", align 512
  %zext.ln219 = zext i16 %"(anonymous namespace)::runtime.inputs.identity.B.load" to i32
  %icmp.ln219 = icmp uge i32 %b, %zext.ln219
  %c.code.load.13 = load i16, i16* %c.code.316, align 512, !alias.scope !16068
  %icmp.ln9.283 = icmp ne i16 %c.code.load.13, 0
  %or.ln219 = or i1 %icmp.ln219, %icmp.ln9.283
  br i1 %or.ln219, label %if.else99, label %VITIS_LOOP_220_2

VITIS_LOOP_220_2:                                 ; preds = %for.cond
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @86)
  %batch = trunc i32 %b to i8
  br i1 %icmp.ln220, label %for.cond.cleanup38, label %for.body39.preheader

for.body39.preheader:                             ; preds = %VITIS_LOOP_220_2
  br label %for.body39

for.cond36:                                       ; preds = %if.end65
  br label %for.body39, !llvm.loop !16073

for.cond.cleanup38.loopexit:                      ; preds = %for.body39
  %.235.phi.lcssa = phi i64 [ %c.bad_element.285, %for.body39 ]
  %.133.phi.lcssa = phi i32 [ %c.detail.310, %for.body39 ]
  store i16 0, i16* %c.code.316, align 512
  store i32 %.133.phi.lcssa, i32* %c.detail.312, align 512
  store i64 %.235.phi.lcssa, i64* %c.bad_element.287, align 512
  br label %for.cond.cleanup38

for.cond.cleanup38:                               ; preds = %for.cond.cleanup38.loopexit, %VITIS_LOOP_220_2
  br label %for.inc92

for.body39:                                       ; preds = %for.cond36, %for.body39.preheader
  %row.017 = phi i32 [ %add.ln220, %for.cond36 ], [ 0, %for.body39.preheader ]
  %c.detail.310 = phi i32 [ %ref.tmp81.1198.load, %for.cond36 ], [ undef, %for.body39.preheader ]
  %c.bad_element.285 = phi i64 [ %ref.tmp81.2199.load, %for.cond36 ], [ undef, %for.body39.preheader ]
  %icmp.ln220.5 = icmp ult i32 %row.017, %rows
  br i1 %icmp.ln220.5, label %for.body39.split, label %for.cond.cleanup38.loopexit, !llvm.loop !16073

for.body39.split:                                 ; preds = %for.body39
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 0, i64 4096, i64 2048), !fpga.pragma.source !33
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @87)
  %sub.ln221 = sub nsw i32 %rows, %row.017
  %icmp.ln221 = icmp ult i32 %sub.ln221, 16
  %trunc.ln221 = trunc i32 %sub.ln221 to i8
  %count = select i1 %icmp.ln221, i8 %trunc.ln221, i8 16
  %row0 = trunc i32 %row.017 to i16
  %"(anonymous namespace)::runtime.last_task_id.load" = load i32, i32* @"(anonymous namespace)::runtime.last_task_id", align 512, !alias.scope !16201, !noalias !16204
  %quant.ctx.task_id = add i32 %"(anonymous namespace)::runtime.last_task_id.load", 1
  call fastcc void @"laya::full::(anonymous namespace)::Controller::fresh"(i8* %ref.tmp52.0243, i8* %ref.tmp52.1244, i32* %ref.tmp52.2245, i8 34, i8 0, i8 0)
  %quant.a_dst.id = load i8, i8* %ref.tmp52.0243, align 512
  %quant.a_dst.bank = load i8, i8* %ref.tmp52.1244, align 512
  %quant.a_dst.epoch = load i32, i32* %ref.tmp52.2245, align 512
  %"(anonymous namespace)::runtime.request_valid.load" = load i1, i1* @"(anonymous namespace)::runtime.request_valid", align 512, !alias.scope !16213, !noalias !16216
  br i1 %"(anonymous namespace)::runtime.request_valid.load", label %lor.lhs.false.i, label %_ZN4laya4full22full_bind_quant_sourceERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE.2108.2114.exit

lor.lhs.false.i:                                  ; preds = %for.body39.split
  %"(anonymous namespace)::runtime.model_header_valid.load" = load i1, i1* @"(anonymous namespace)::runtime.model_header_valid", align 512, !alias.scope !16213, !noalias !16216
  br i1 %"(anonymous namespace)::runtime.model_header_valid.load", label %lor.lhs.false1.i, label %_ZN4laya4full22full_bind_quant_sourceERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE.2108.2114.exit

lor.lhs.false1.i:                                 ; preds = %lor.lhs.false.i
  %tmp = call fastcc i1 @"laya::full::(anonymous namespace)::legal_spec"(i8 %source_ref_id.val, i8 %source_ref_bank.val, i32 %source_ref_epoch.val, i8 %source_region.val, i8 %source_stage.val, i8 %source_batch.val, i8 %source_row_space.val, i16 %source_row0.val, i16 %source_rows.val, i16 %source_width.val)
  %xor.ln730 = xor i1 %tmp, true
  %or.ln730.1 = or i1 %or.ln730, %xor.ln730
  br i1 %or.ln730.1, label %_ZN4laya4full22full_bind_quant_sourceERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE.2108.2114.exit, label %if.then57

_ZN4laya4full22full_bind_quant_sourceERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE.2108.2114.exit: ; preds = %lor.lhs.false1.i, %lor.lhs.false.i, %for.body39.split
  br label %if.end62

if.then57:                                        ; preds = %lor.lhs.false1.i
  store i8 %source_ref_id.val, i8* @"(anonymous namespace)::runtime.expected_quant_source.ref.id", align 512, !alias.scope !16213, !noalias !16216
  store i8 %source_ref_bank.val, i8* @"(anonymous namespace)::runtime.expected_quant_source.ref.bank", align 512, !alias.scope !16213, !noalias !16216
  store i32 %source_ref_epoch.val, i32* @"(anonymous namespace)::runtime.expected_quant_source.ref.epoch", align 512, !alias.scope !16213, !noalias !16216
  store i8 %source_region.val, i8* @"(anonymous namespace)::runtime.expected_quant_source.region", align 512, !alias.scope !16213, !noalias !16216
  store i8 %source_stage.val, i8* @"(anonymous namespace)::runtime.expected_quant_source.stage", align 512, !alias.scope !16213, !noalias !16216
  store i8 %source_layer.val, i8* @"(anonymous namespace)::runtime.expected_quant_source.layer", align 512, !alias.scope !16213, !noalias !16216
  store i8 %source_batch.val, i8* @"(anonymous namespace)::runtime.expected_quant_source.batch", align 512, !alias.scope !16213, !noalias !16216
  store i8 %source_row_space.val, i8* @"(anonymous namespace)::runtime.expected_quant_source.row_space", align 512, !alias.scope !16213, !noalias !16216
  store i16 %source_row0.val, i16* @"(anonymous namespace)::runtime.expected_quant_source.row0", align 512, !alias.scope !16213, !noalias !16216
  store i16 %source_rows.val, i16* @"(anonymous namespace)::runtime.expected_quant_source.rows", align 512, !alias.scope !16213, !noalias !16216
  store i16 %source_width.val, i16* @"(anonymous namespace)::runtime.expected_quant_source.width", align 512, !alias.scope !16213, !noalias !16216
  store i8 1, i8* @"(anonymous namespace)::runtime.expected_quant_source.content", align 512, !alias.scope !16213, !noalias !16216
  store i1 true, i1* @"(anonymous namespace)::runtime.expected_quant_source_valid", align 512, !alias.scope !16213, !noalias !16216
  %zext.ln230.2 = zext i8 %count to i32
  %mul.ln230 = mul nuw nsw i32 %zext.ln230.2, %zext.ln230
  %lshr.ln230 = lshr i32 %mul.ln230, 5
  call fastcc void @"laya::full::(anonymous namespace)::Controller::issue<laya::QuantTask>"(i16* %ref.tmp58.0231, i32* %ref.tmp58.1232, i64* %ref.tmp58.2233, i8 addrspace(1)* %embedding, i64 %this_memory.0, i8 addrspace(1)* %io, i64 %this_memory.2, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i8 addrspace(1)* %aux, i64 %this_memory.10, i8 addrspace(1)* %state0, i64 %this_memory.12, i8 addrspace(1)* %state1, i64 %this_memory.14, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i8 addrspace(1)* %ff0, i64 %this_memory.20, i8 addrspace(1)* %ff1, i64 %this_memory.22, i8 addrspace(1)* %att_out, i64 %this_memory.24, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i32 %quant.ctx.task_id, i8 %stage, i8 %layer, i8 %batch, i8 %source_row_space.val, i16 %row0, i8 %count, i8 %source_ref_id.val, i8 %source_ref_bank.val, i32 %source_ref_epoch.val, i8 %quant.a_dst.id, i8 %quant.a_dst.bank, i32 %quant.a_dst.epoch, i16 %quant.K, i8 %source_region.val, i32 %lshr.ln230)
  %ref.tmp58.0231.load = load i16, i16* %ref.tmp58.0231, align 512
  %ref.tmp58.1232.load = load i32, i32* %ref.tmp58.1232, align 512
  %ref.tmp58.2233.load = load i64, i64* %ref.tmp58.2233, align 512
  br label %if.end62

if.end62:                                         ; preds = %if.then57, %_ZN4laya4full22full_bind_quant_sourceERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE.2108.2114.exit
  %.23559 = phi i64 [ %ref.tmp58.2233.load, %if.then57 ], [ -1, %_ZN4laya4full22full_bind_quant_sourceERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE.2108.2114.exit ]
  %.13356 = phi i32 [ %ref.tmp58.1232.load, %if.then57 ], [ %or.ln11, %_ZN4laya4full22full_bind_quant_sourceERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE.2108.2114.exit ]
  %0 = phi i16 [ %ref.tmp58.0231.load, %if.then57 ], [ 5, %_ZN4laya4full22full_bind_quant_sourceERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE.2108.2114.exit ]
  %icmp.ln9.284 = icmp eq i16 %0, 0
  br i1 %icmp.ln9.284, label %if.end65, label %for.inc92.loopexit

if.end65:                                         ; preds = %if.end62
  %"(anonymous namespace)::runtime.last_task_id.load.2" = load i32, i32* @"(anonymous namespace)::runtime.last_task_id", align 512, !alias.scope !16232, !noalias !16235
  %t.ctx.task_id = add i32 %"(anonymous namespace)::runtime.last_task_id.load.2", 1
  %t.w.id = load i8, i8* @"(anonymous namespace)::runtime.current_weight_ref.id", align 512
  %t.w.epoch = load i32, i32* @"(anonymous namespace)::runtime.current_weight_ref.epoch", align 512
  call fastcc void @"laya::full::(anonymous namespace)::Controller::fresh"(i8* %ref.tmp73.0203, i8* %ref.tmp73.1204, i32* %ref.tmp73.2205, i8 36, i8 0, i8 0)
  %t.ps.id = load i8, i8* %ref.tmp73.0203, align 512
  %t.ps.bank = load i8, i8* %ref.tmp73.1204, align 512
  %t.ps.epoch = load i32, i32* %ref.tmp73.2205, align 512
  %zext.ln244.4 = zext i8 %count to i32
  %mul.ln244 = mul nuw nsw i32 %zext.ln244.4, %zext.ln244
  call fastcc void @"laya::full::(anonymous namespace)::Controller::issue<laya::LinearTask>"(i16* %ref.tmp81.0197, i32* %ref.tmp81.1198, i64* %ref.tmp81.2199, i8 addrspace(1)* %io, i64 %this_memory.2, i8 addrspace(1)* %state0, i64 %this_memory.12, i8 addrspace(1)* %state1, i64 %this_memory.14, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i8 addrspace(1)* %ff0, i64 %this_memory.20, i8 addrspace(1)* %ff1, i64 %this_memory.22, i8 addrspace(1)* %att_out, i64 %this_memory.24, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i32 %t.ctx.task_id, i8 %op, i8 %stage, i8 %layer, i8 %batch, i8 %source_row_space.val, i16 %row0, i8 %count, i8 %quant.a_dst.id, i8 %quant.a_dst.bank, i32 %quant.a_dst.epoch, i8 %t.w.id, i32 %t.w.epoch, i8 %t.ps.id, i8 %t.ps.bank, i32 %t.ps.epoch, i8 %dst_ref_id, i8 %dst_ref_bank, i32 %dst_ref_epoch, i8 %key_family.val, i8 %key_layer.val, i16 %quant.K, i16 %width, i8 %dst_region, i8 %t.bias_kind, i32 %mul.ln244)
  %ref.tmp81.0197.load = load i16, i16* %ref.tmp81.0197, align 512
  %ref.tmp81.1198.load = load i32, i32* %ref.tmp81.1198, align 512
  %ref.tmp81.2199.load = load i64, i64* %ref.tmp81.2199, align 512
  %icmp.ln9.285 = icmp eq i16 %ref.tmp81.0197.load, 0
  %add.ln220 = add nuw nsw i32 %row.017, 16
  br i1 %icmp.ln9.285, label %for.cond36, label %for.inc92.loopexit

for.inc92.loopexit:                               ; preds = %if.end65, %if.end62
  %c.code.315 = phi i16 [ %0, %if.end62 ], [ %ref.tmp81.0197.load, %if.end65 ]
  %c.detail.311 = phi i32 [ %.13356, %if.end62 ], [ %ref.tmp81.1198.load, %if.end65 ]
  %c.bad_element.286 = phi i64 [ %.23559, %if.end62 ], [ %ref.tmp81.2199.load, %if.end65 ]
  store i16 %c.code.315, i16* %c.code.316, align 512
  store i32 %c.detail.311, i32* %c.detail.312, align 512
  store i64 %c.bad_element.286, i64* %c.bad_element.287, align 512
  br label %for.inc92

for.inc92:                                        ; preds = %for.inc92.loopexit, %for.cond.cleanup38
  %b.21 = add nuw nsw i32 %b, 1
  br label %for.cond, !llvm.loop !16244

if.else99:                                        ; preds = %for.cond
  %cmp.i40.lcssa = phi i1 [ %icmp.ln9.283, %for.cond ]
  %.lcssa = phi i16 [ %c.code.load.13, %for.cond ]
  %or.ln248 = or i1 %scorer_lease, %cmp.i40.lcssa
  br i1 %or.ln248, label %if.end106, label %if.then102

if.then102:                                       ; preds = %if.else99
  call fastcc void @"laya::full::full_publish_owner"(i16* %ref.tmp103.0185, i32* %ref.tmp103.1186, i64* %ref.tmp103.2187, i8 %dst_ref_id, i8 %dst_ref_bank, i32 %dst_ref_epoch, i8 %dst_region, i8 %stage, i8 %layer, i8 -1, i8 %source_row_space.val, i16 0, i16 %select.ln63, i16 %width, i8 1)
  %c.code = load i16, i16* %ref.tmp103.0185, align 512
  %c.detail = load i32, i32* %ref.tmp103.1186, align 512
  %c.bad_element = load i64, i64* %ref.tmp103.2187, align 512
  store i16 %c.code, i16* %c.code.316, align 512
  store i32 %c.detail, i32* %c.detail.312, align 512
  store i64 %c.bad_element, i64* %c.bad_element.287, align 512
  br label %if.end106

if.end106:                                        ; preds = %if.then102, %if.else99
  %.0 = phi i16 [ %c.code, %if.then102 ], [ %.lcssa, %if.else99 ]
  %c.detail.309.load = load i32, i32* %c.detail.312, align 512
  %c.bad_element.284.load = load i64, i64* %c.bad_element.287, align 512
  br label %cleanup119

cleanup119:                                       ; preds = %if.end106, %if.then28, %if.then
  %storemerge19 = phi i16 [ %c.code.load, %if.then ], [ %.086, %if.then28 ], [ %.0, %if.end106 ]
  %storemerge17 = phi i32 [ %c.detail.load, %if.then ], [ %c.detail.load.3, %if.then28 ], [ %c.detail.309.load, %if.end106 ]
  %storemerge15 = phi i64 [ %c.bad_element.load, %if.then ], [ %c.bad_element.load.3, %if.then28 ], [ %c.bad_element.284.load, %if.end106 ]
  store i16 %storemerge19, i16* %agg.result.01, align 512
  store i32 %storemerge17, i32* %agg.result.12, align 512
  store i64 %storemerge15, i64* %agg.result.23, align 512
  ret void
}
