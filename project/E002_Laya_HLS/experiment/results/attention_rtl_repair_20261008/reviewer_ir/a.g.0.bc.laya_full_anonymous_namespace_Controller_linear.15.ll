define internal fastcc void @"laya::full::(anonymous namespace)::Controller::linear.15"(i16* noalias nocapture align 512 %agg.result.01, i32* noalias nocapture align 512 %agg.result.12, i64* noalias nocapture align 512 %agg.result.23, i8 addrspace(1)* noalias nocapture %embedding, i64 %this_memory.0, i64* noalias nocapture align 512 %this_memory.1, i8 addrspace(1)* noalias nocapture %io, i64 %this_memory.2, i64* noalias nocapture align 512 %this_memory.3, i8 addrspace(1)* noalias nocapture %w_q0, i64 %this_memory.4, i64* noalias nocapture align 512 %this_memory.5, i8 addrspace(1)* noalias nocapture %w_q1, i64 %this_memory.6, i64* noalias nocapture align 512 %this_memory.7, i8 addrspace(1)* noalias nocapture %w_scale, i64 %this_memory.8, i64* noalias nocapture align 512 %this_memory.9, i8 addrspace(1)* noalias nocapture %aux, i64 %this_memory.10, i64* noalias nocapture align 512 %this_memory.11, i8 addrspace(1)* noalias nocapture %state0, i64 %this_memory.12, i64* noalias nocapture align 512 %this_memory.13, i8 addrspace(1)* noalias nocapture %state1, i64 %this_memory.14, i64* noalias nocapture align 512 %this_memory.15, i8 addrspace(1)* noalias nocapture %qkv0, i64 %this_memory.16, i64* noalias nocapture align 512 %this_memory.17, i8 addrspace(1)* noalias nocapture %qkv1, i64 %this_memory.18, i64* noalias nocapture align 512 %this_memory.19, i8 addrspace(1)* noalias nocapture %ff0, i64 %this_memory.20, i64* noalias nocapture align 512 %this_memory.21, i8 addrspace(1)* noalias nocapture %ff1, i64 %this_memory.22, i64* noalias nocapture align 512 %this_memory.23, i8 addrspace(1)* noalias nocapture %att_out, i64 %this_memory.24, i64* noalias nocapture align 512 %this_memory.25, i8* noalias nocapture align 512 %this_error_stage, i8* noalias nocapture align 512 %this_error_op, i32* noalias nocapture align 512 %this_error_task_id, i8* noalias nocapture align 512 %this_current_stage, i8* noalias nocapture align 512 %this_current_op, i8 zeroext %op, i8 %key_family.val, i8 %key_layer.val, i8 %source_ref_id.val, i8 %source_ref_bank.val, i32 %source_ref_epoch.val, i8 %source_region.val, i8 %source_stage.val, i8 %source_layer.val, i8 %source_batch.val, i8 %source_row_space.val, i16 %source_row0.val, i16 %source_rows.val, i16 %source_width.val, i8 %source_content.val, i8 zeroext %stage, i8 zeroext %layer, i8 %dst_ref_id, i8 %dst_ref_bank, i32 %dst_ref_epoch, i8 zeroext %dst_region, i8* noalias nocapture align 512 %output_ref_id, i8* noalias nocapture align 512 %output_ref_bank, i32* noalias nocapture align 512 %output_ref_epoch, i8* noalias nocapture align 512 %output_region, i8* noalias nocapture align 512 %output_stage, i8* noalias nocapture align 512 %output_layer, i8* noalias nocapture align 512 %output_batch, i8* noalias nocapture align 512 %output_row_space, i16* noalias nocapture align 512 %output_row0, i16* noalias nocapture align 512 %output_rows, i16* noalias nocapture align 512 %output_width, i8* noalias nocapture align 512 %output_content) unnamed_addr #0 {
entry:
  %descriptor.name = alloca [48 x i8], align 512
  %descriptor.key.family = alloca i8, align 512
  %descriptor.key.layer = alloca i8, align 512
  %descriptor.K = alloca i16, align 512
  %descriptor.N = alloca i16, align 512
  %descriptor.dtype = alloca i8, align 512
  %descriptor.bias_kind = alloca i8, align 512
  %descriptor.q_base = alloca [2 x i32], align 512
  %descriptor.q_span = alloca [2 x i32], align 512
  %descriptor.scale_base = alloca i32, align 512
  %descriptor.scale_span = alloca i32, align 512
  %descriptor.aux_base = alloca i32, align 512
  %descriptor.aux_span = alloca i32, align 512
  %descriptor.bias_base = alloca i32, align 512
  %descriptor.bias_span = alloca i32, align 512
  %descriptor.source_sha256 = alloca [32 x i8], align 512
  %descriptor.bias_sha256 = alloca [32 x i8], align 512
  %c.code = alloca i16, align 512
  %c.detail = alloca i32, align 512
  %c.bad_element = alloca i64, align 512
  %ref.tmp23.0265 = alloca i16, align 512
  %ref.tmp23.1266 = alloca i32, align 512
  %ref.tmp23.2267 = alloca i64, align 512
  %ref.tmp52.0243 = alloca i8, align 512
  %ref.tmp52.1244 = alloca i8, align 512
  %ref.tmp52.2245 = alloca i32, align 512
  %ref.tmp58.0231 = alloca i16, align 512
  %ref.tmp58.1232 = alloca i32, align 512
  %ref.tmp58.2233 = alloca i64, align 512
  %ref.tmp73.0203 = alloca i8, align 512
  %ref.tmp73.1204 = alloca i8, align 512
  %ref.tmp73.2205 = alloca i32, align 512
  %ref.tmp81.0197 = alloca i16, align 512
  %ref.tmp81.1198 = alloca i32, align 512
  %ref.tmp81.2199 = alloca i64, align 512
  %ref.tmp103.0185 = alloca i16, align 512
  %ref.tmp103.1186 = alloca i32, align 512
  %ref.tmp103.2187 = alloca i64, align 512
  store i8 %stage, i8* %this_current_stage, align 512, !alias.scope !10637, !noalias !10640
  store i8 %op, i8* %this_current_op, align 512, !alias.scope !10640, !noalias !10637
  br label %arrayinit.body.i

arrayinit.body.i:                                 ; preds = %arrayinit.body.i, %entry
  %arrayinit.curidx.i = phi i64 [ 0, %entry ], [ %arrayinit.nextidx.i, %arrayinit.body.i ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 48, i64 48, i64 48), !fpga.pragma.source !33
  %arrayinit.cur1.i = getelementptr [48 x i8], [48 x i8]* %descriptor.name, i64 0, i64 %arrayinit.curidx.i
  %arrayinit.nextidx.i = add nuw nsw i64 %arrayinit.curidx.i, 1
  store i8 0, i8* %arrayinit.cur1.i, align 1, !alias.scope !10642, !noalias !10645
  %arrayinit.done.i = icmp eq i64 %arrayinit.curidx.i, 47
  br i1 %arrayinit.done.i, label %arrayinit.end.i, label %arrayinit.body.i, !llvm.loop !10662

arrayinit.end.i:                                  ; preds = %arrayinit.body.i
  store i8 0, i8* %descriptor.key.family, align 512, !alias.scope !10663, !noalias !10666
  store i8 -1, i8* %descriptor.key.layer, align 512, !alias.scope !10668, !noalias !10669
  store i16 0, i16* %descriptor.K, align 512, !alias.scope !10670, !noalias !10671
  store i16 0, i16* %descriptor.N, align 512, !alias.scope !10672, !noalias !10673
  store i8 0, i8* %descriptor.dtype, align 512, !alias.scope !10674, !noalias !10675
  store i8 0, i8* %descriptor.bias_kind, align 512, !alias.scope !10676, !noalias !10677
  br label %arrayinit.body3.i

arrayinit.body3.i:                                ; preds = %arrayinit.body3.i, %arrayinit.end.i
  %arrayinit.curidx4.i = phi i64 [ 0, %arrayinit.end.i ], [ %arrayinit.nextidx6.i, %arrayinit.body3.i ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 2, i64 2, i64 2), !fpga.pragma.source !33
  %arrayinit.cur52.i = getelementptr [2 x i32], [2 x i32]* %descriptor.q_base, i64 0, i64 %arrayinit.curidx4.i
  %arrayinit.nextidx6.i = add nuw nsw i64 %arrayinit.curidx4.i, 1
  store i32 0, i32* %arrayinit.cur52.i, align 4, !alias.scope !10678, !noalias !10679
  %arrayinit.done7.i = icmp eq i64 %arrayinit.curidx4.i, 1
  br i1 %arrayinit.done7.i, label %arrayinit.end8.i, label %arrayinit.body3.i, !llvm.loop !10680

arrayinit.end8.i:                                 ; preds = %arrayinit.body3.i
  br label %arrayinit.body10.i

arrayinit.body10.i:                               ; preds = %arrayinit.body10.i, %arrayinit.end8.i
  %arrayinit.curidx11.i = phi i64 [ 0, %arrayinit.end8.i ], [ %arrayinit.nextidx13.i, %arrayinit.body10.i ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 2, i64 2, i64 2), !fpga.pragma.source !33
  %arrayinit.cur123.i = getelementptr [2 x i32], [2 x i32]* %descriptor.q_span, i64 0, i64 %arrayinit.curidx11.i
  %arrayinit.nextidx13.i = add nuw nsw i64 %arrayinit.curidx11.i, 1
  store i32 0, i32* %arrayinit.cur123.i, align 4, !alias.scope !10681, !noalias !10682
  %arrayinit.done14.i = icmp eq i64 %arrayinit.curidx11.i, 1
  br i1 %arrayinit.done14.i, label %arrayinit.end15.i, label %arrayinit.body10.i, !llvm.loop !10683

arrayinit.end15.i:                                ; preds = %arrayinit.body10.i
  store i32 0, i32* %descriptor.scale_base, align 512, !alias.scope !10684, !noalias !10685
  store i32 0, i32* %descriptor.scale_span, align 512, !alias.scope !10686, !noalias !10687
  store i32 0, i32* %descriptor.aux_base, align 512, !alias.scope !10688, !noalias !10689
  store i32 0, i32* %descriptor.aux_span, align 512, !alias.scope !10690, !noalias !10691
  store i32 0, i32* %descriptor.bias_base, align 512, !alias.scope !10692, !noalias !10693
  store i32 0, i32* %descriptor.bias_span, align 512, !alias.scope !10694, !noalias !10695
  br label %arrayinit.body17.i

arrayinit.body17.i:                               ; preds = %arrayinit.body17.i, %arrayinit.end15.i
  %arrayinit.curidx18.i = phi i64 [ 0, %arrayinit.end15.i ], [ %arrayinit.nextidx20.i, %arrayinit.body17.i ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 32, i64 32, i64 32), !fpga.pragma.source !33
  %arrayinit.cur194.i = getelementptr [32 x i8], [32 x i8]* %descriptor.source_sha256, i64 0, i64 %arrayinit.curidx18.i
  %arrayinit.nextidx20.i = add nuw nsw i64 %arrayinit.curidx18.i, 1
  store i8 0, i8* %arrayinit.cur194.i, align 1, !alias.scope !10696, !noalias !10697
  %arrayinit.done21.i = icmp eq i64 %arrayinit.curidx18.i, 31
  br i1 %arrayinit.done21.i, label %arrayinit.end22.i, label %arrayinit.body17.i, !llvm.loop !10698

arrayinit.end22.i:                                ; preds = %arrayinit.body17.i
  br label %arrayinit.body24.i

arrayinit.body24.i:                               ; preds = %arrayinit.body24.i, %arrayinit.end22.i
  %arrayinit.curidx25.i = phi i64 [ 0, %arrayinit.end22.i ], [ %arrayinit.nextidx27.i, %arrayinit.body24.i ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 32, i64 32, i64 32), !fpga.pragma.source !33
  %arrayinit.cur265.i = getelementptr [32 x i8], [32 x i8]* %descriptor.bias_sha256, i64 0, i64 %arrayinit.curidx25.i
  %arrayinit.nextidx27.i = add nuw nsw i64 %arrayinit.curidx25.i, 1
  store i8 0, i8* %arrayinit.cur265.i, align 1, !alias.scope !10699, !noalias !10700
  %arrayinit.done28.i = icmp eq i64 %arrayinit.curidx25.i, 31
  br i1 %arrayinit.done28.i, label %_ZN4laya4full20FullWeightDescriptorC2Ev.exit, label %arrayinit.body24.i, !llvm.loop !10701

_ZN4laya4full20FullWeightDescriptorC2Ev.exit:     ; preds = %arrayinit.body24.i
  call fastcc void @"laya::full::(anonymous namespace)::Controller::load_weight"(i16* %c.code, i32* %c.detail, i64* %c.bad_element, i8 addrspace(1)* %embedding, i64 %this_memory.0, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i64* %this_memory.5, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i64* %this_memory.7, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i64* %this_memory.9, i8 addrspace(1)* %aux, i64 %this_memory.10, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i8 %key_family.val, i8 %key_layer.val, i8 %stage, i8 %layer, [48 x i8]* %descriptor.name, i8* %descriptor.key.family, i8* %descriptor.key.layer, i16* %descriptor.K, i16* %descriptor.N, i8* %descriptor.dtype, i8* %descriptor.bias_kind, [2 x i32]* %descriptor.q_base, [2 x i32]* %descriptor.q_span, i32* %descriptor.scale_base, i32* %descriptor.scale_span, i32* %descriptor.aux_base, i32* %descriptor.aux_span, i32* %descriptor.bias_base, i32* %descriptor.bias_span, [32 x i8]* %descriptor.source_sha256, [32 x i8]* %descriptor.bias_sha256)
  %0 = load i16, i16* %c.code, align 512, !alias.scope !10702
  %cmp.i = icmp eq i16 %0, 0
  br i1 %cmp.i, label %if.end, label %if.then

if.then:                                          ; preds = %_ZN4laya4full20FullWeightDescriptorC2Ev.exit
  %.1176 = load i32, i32* %c.detail, align 512
  %.2179 = load i64, i64* %c.bad_element, align 512
  br label %cleanup119

if.end:                                           ; preds = %_ZN4laya4full20FullWeightDescriptorC2Ev.exit
  store i8 %stage, i8* %this_current_stage, align 512, !alias.scope !10705, !noalias !10708
  store i8 %op, i8* %this_current_op, align 512, !alias.scope !10708, !noalias !10705
  %1 = load i16, i16* %descriptor.N, align 512
  %cmp.i31 = icmp eq i8 %source_row_space.val, 0
  %2 = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.S", align 512
  %cmp6.i = icmp eq i8 %source_row_space.val, 1
  %cond.i = select i1 %cmp6.i, i16 16, i16 1
  %cond7.i = select i1 %cmp.i31, i16 %2, i16 %cond.i
  store i8 %dst_ref_id, i8* %output_ref_id, align 512
  store i8 %dst_ref_bank, i8* %output_ref_bank, align 512
  store i32 %dst_ref_epoch, i32* %output_ref_epoch, align 512
  store i8 %dst_region, i8* %output_region, align 512
  store i8 %stage, i8* %output_stage, align 512
  store i8 %layer, i8* %output_layer, align 512
  store i8 -1, i8* %output_batch, align 512
  store i8 %source_row_space.val, i8* %output_row_space, align 512
  store i16 0, i16* %output_row0, align 512
  store i16 %cond7.i, i16* %output_rows, align 512
  store i16 %1, i16* %output_width, align 512
  store i8 1, i8* %output_content, align 512
  %cmp13 = icmp eq i8 %op, 54
  br i1 %cmp13, label %if.end26, label %if.then22

if.then22:                                        ; preds = %if.end
  call fastcc void @"laya::full::full_claim_owner"(i16* %ref.tmp23.0265, i32* %ref.tmp23.1266, i64* %ref.tmp23.2267, i8 %dst_ref_id, i8 %dst_ref_bank, i32 %dst_ref_epoch, i8 %dst_region, i8 %stage, i8 %layer, i8 -1, i8 %source_row_space.val, i16 0, i16 %cond7.i, i16 %1, i8 1)
  %.094 = load i16, i16* %ref.tmp23.0265, align 512
  %.196 = load i32, i32* %ref.tmp23.1266, align 512
  %.298 = load i64, i64* %ref.tmp23.2267, align 512
  store i16 %.094, i16* %c.code, align 512
  store i32 %.196, i32* %c.detail, align 512
  store i64 %.298, i64* %c.bad_element, align 512
  br label %if.end26

if.end26:                                         ; preds = %if.then22, %if.end
  %.086 = phi i16 [ %.094, %if.then22 ], [ 0, %if.end ]
  %cmp.i32 = icmp eq i16 %.086, 0
  br i1 %cmp.i32, label %if.end29, label %if.then28

if.then28:                                        ; preds = %if.end26
  %.189 = load i32, i32* %c.detail, align 512
  %.292 = load i64, i64* %c.bad_element, align 512
  br label %cleanup119

if.end29:                                         ; preds = %if.end26
  %conv31 = zext i16 %source_rows.val to i32
  %3 = load i16, i16* %descriptor.K, align 512
  %conv61 = zext i16 %3 to i32
  %4 = load i8, i8* %descriptor.bias_kind, align 512
  %cmp3716 = icmp ne i16 %source_rows.val, 0
  %conv84 = zext i16 %1 to i32
  %cmp.i34 = icmp ne i8 %source_content.val, 1
  %conv1.i.i.i = zext i8 %source_ref_id.val to i32
  %shl2.i.i.i = shl nuw nsw i32 %conv1.i.i.i, 16
  %or4.i.i.i = or i32 %shl2.i.i.i, 67108873
  %cmp4.i = icmp eq i8 %source_ref_id.val, 0
  %thr.or = or i1 %cmp4.i, %cmp.i34
  br label %for.cond

for.cond:                                         ; preds = %for.inc92, %if.end29
  %b.0 = phi i32 [ 0, %if.end29 ], [ %inc, %for.inc92 ]
  %5 = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.B", align 512
  %conv33 = zext i16 %5 to i32
  %cmp34 = icmp uge i32 %b.0, %conv33
  %6 = load i16, i16* %c.code, align 512, !alias.scope !10710
  %cmp.i40 = icmp ne i16 %6, 0
  %brmerge52 = or i1 %cmp34, %cmp.i40
  br i1 %brmerge52, label %if.else99, label %VITIS_LOOP_220_2

VITIS_LOOP_220_2:                                 ; preds = %for.cond
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @199)
  %conv48 = trunc i32 %b.0 to i8
  br i1 %cmp3716, label %for.body39.lr.ph, label %for.cond.cleanup38

for.body39.lr.ph:                                 ; preds = %VITIS_LOOP_220_2
  br label %for.body39

for.cond36:                                       ; preds = %if.end65
  br label %for.body39, !llvm.loop !10715

for.cond.cleanup38.loopexit:                      ; preds = %for.body39
  store i16 %.031.phi, i16* %c.code, align 512
  store i32 %.133.phi, i32* %c.detail, align 512
  store i64 %.235.phi, i64* %c.bad_element, align 512
  br label %for.cond.cleanup38

for.cond.cleanup38:                               ; preds = %for.cond.cleanup38.loopexit, %VITIS_LOOP_220_2
  br label %for.inc92

for.body39:                                       ; preds = %for.cond36, %for.body39.lr.ph
  %row.017 = phi i32 [ 0, %for.body39.lr.ph ], [ %add15, %for.cond36 ]
  %.031.phi = phi i16 [ undef, %for.body39.lr.ph ], [ %.031, %for.cond36 ]
  %.133.phi = phi i32 [ undef, %for.body39.lr.ph ], [ %.133, %for.cond36 ]
  %.235.phi = phi i64 [ undef, %for.body39.lr.ph ], [ %.235, %for.cond36 ]
  %cmp371 = icmp ult i32 %row.017, %conv31
  br i1 %cmp371, label %for.body39.split, label %for.cond.cleanup38.loopexit, !llvm.loop !10715

for.body39.split:                                 ; preds = %for.body39
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 0, i64 4096, i64 2048), !fpga.pragma.source !33
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @198)
  %sub = sub nsw i32 %conv31, %row.017
  %cmp40 = icmp ult i32 %sub, 16
  %cond45 = select i1 %cmp40, i32 %sub, i32 16
  %conv46 = trunc i32 %cond45 to i8
  %conv50 = trunc i32 %row.017 to i16
  %7 = load i32, i32* @"(anonymous namespace)::runtime.last_task_id", align 512, !alias.scope !10844, !noalias !10847
  %add.i = add i32 %7, 1
  call fastcc void @"laya::full::(anonymous namespace)::Controller::fresh"(i8* %ref.tmp52.0243, i8* %ref.tmp52.1244, i32* %ref.tmp52.2245, i8 34, i8 0, i8 0)
  %.071 = load i8, i8* %ref.tmp52.0243, align 512
  %.172 = load i8, i8* %ref.tmp52.1244, align 512
  %.273 = load i32, i32* %ref.tmp52.2245, align 512
  %8 = load i1, i1* @"(anonymous namespace)::runtime.request_valid", align 512, !alias.scope !10856, !noalias !10859
  br i1 %8, label %lor.lhs.false.i, label %_ZN4laya4full22full_bind_quant_sourceERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE.2108.2114.exit

lor.lhs.false.i:                                  ; preds = %for.body39.split
  %9 = load i1, i1* @"(anonymous namespace)::runtime.model_header_valid", align 512, !alias.scope !10856, !noalias !10859
  br i1 %9, label %lor.lhs.false1.i, label %_ZN4laya4full22full_bind_quant_sourceERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE.2108.2114.exit

lor.lhs.false1.i:                                 ; preds = %lor.lhs.false.i
  %10 = call fastcc i1 @"laya::full::(anonymous namespace)::legal_spec"(i8 %source_ref_id.val, i8 %source_ref_bank.val, i32 %source_ref_epoch.val, i8 %source_region.val, i8 %source_stage.val, i8 %source_batch.val, i8 %source_row_space.val, i16 %source_row0.val, i16 %source_rows.val, i16 %source_width.val)
  %thr.xor = xor i1 %10, true
  %thr.or20 = or i1 %thr.or, %thr.xor
  br i1 %thr.or20, label %_ZN4laya4full22full_bind_quant_sourceERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE.2108.2114.exit, label %if.then57

_ZN4laya4full22full_bind_quant_sourceERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE.2108.2114.exit: ; preds = %lor.lhs.false1.i, %lor.lhs.false.i, %for.body39.split
  br label %if.end62

if.then57:                                        ; preds = %lor.lhs.false1.i
  store i8 %source_ref_id.val, i8* @"(anonymous namespace)::runtime.expected_quant_source.ref.id", align 512, !alias.scope !10856, !noalias !10859
  store i8 %source_ref_bank.val, i8* @"(anonymous namespace)::runtime.expected_quant_source.ref.bank", align 512, !alias.scope !10856, !noalias !10859
  store i32 %source_ref_epoch.val, i32* @"(anonymous namespace)::runtime.expected_quant_source.ref.epoch", align 512, !alias.scope !10856, !noalias !10859
  store i8 %source_region.val, i8* @"(anonymous namespace)::runtime.expected_quant_source.region", align 512, !alias.scope !10856, !noalias !10859
  store i8 %source_stage.val, i8* @"(anonymous namespace)::runtime.expected_quant_source.stage", align 512, !alias.scope !10856, !noalias !10859
  store i8 %source_layer.val, i8* @"(anonymous namespace)::runtime.expected_quant_source.layer", align 512, !alias.scope !10856, !noalias !10859
  store i8 %source_batch.val, i8* @"(anonymous namespace)::runtime.expected_quant_source.batch", align 512, !alias.scope !10856, !noalias !10859
  store i8 %source_row_space.val, i8* @"(anonymous namespace)::runtime.expected_quant_source.row_space", align 512, !alias.scope !10856, !noalias !10859
  store i16 %source_row0.val, i16* @"(anonymous namespace)::runtime.expected_quant_source.row0", align 512, !alias.scope !10856, !noalias !10859
  store i16 %source_rows.val, i16* @"(anonymous namespace)::runtime.expected_quant_source.rows", align 512, !alias.scope !10856, !noalias !10859
  store i16 %source_width.val, i16* @"(anonymous namespace)::runtime.expected_quant_source.width", align 512, !alias.scope !10856, !noalias !10859
  store i8 1, i8* @"(anonymous namespace)::runtime.expected_quant_source.content", align 512, !alias.scope !10856, !noalias !10859
  store i1 true, i1* @"(anonymous namespace)::runtime.expected_quant_source_valid", align 512, !alias.scope !10856, !noalias !10859
  %conv59 = zext i8 %conv46 to i32
  %mul = mul nuw nsw i32 %conv59, %conv61
  %div = udiv i32 %mul, 32
  call fastcc void @"laya::full::(anonymous namespace)::Controller::issue<laya::QuantTask>"(i16* %ref.tmp58.0231, i32* %ref.tmp58.1232, i64* %ref.tmp58.2233, i8 addrspace(1)* %embedding, i64 %this_memory.0, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i64* %this_memory.5, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i64* %this_memory.7, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i64* %this_memory.9, i8 addrspace(1)* %aux, i64 %this_memory.10, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i32 %add.i, i8 %stage, i8 %layer, i8 %conv48, i8 %source_row_space.val, i16 %conv50, i8 %conv46, i8 %source_ref_id.val, i8 %source_ref_bank.val, i32 %source_ref_epoch.val, i8 %.071, i8 %.172, i32 %.273, i16 %3, i8 %source_region.val, i32 %div)
  %.059 = load i16, i16* %ref.tmp58.0231, align 512
  %.161 = load i32, i32* %ref.tmp58.1232, align 512
  %.263 = load i64, i64* %ref.tmp58.2233, align 512
  br label %if.end62

if.end62:                                         ; preds = %if.then57, %_ZN4laya4full22full_bind_quant_sourceERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE.2108.2114.exit
  %.23559 = phi i64 [ %.263, %if.then57 ], [ -1, %_ZN4laya4full22full_bind_quant_sourceERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE.2108.2114.exit ]
  %.13356 = phi i32 [ %.161, %if.then57 ], [ %or4.i.i.i, %_ZN4laya4full22full_bind_quant_sourceERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE.2108.2114.exit ]
  %11 = phi i16 [ %.059, %if.then57 ], [ 5, %_ZN4laya4full22full_bind_quant_sourceERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE.2108.2114.exit ]
  %cmp.i36 = icmp eq i16 %11, 0
  br i1 %cmp.i36, label %if.end65, label %for.inc92.loopexit

if.end65:                                         ; preds = %if.end62
  %12 = load i32, i32* @"(anonymous namespace)::runtime.last_task_id", align 512, !alias.scope !10875, !noalias !10878
  %add.i38 = add i32 %12, 1
  %.045 = load i8, i8* @"(anonymous namespace)::runtime.current_weight_ref.id", align 512
  %.146 = load i8, i8* @"(anonymous namespace)::runtime.current_weight_ref.bank", align 512
  %.247 = load i32, i32* @"(anonymous namespace)::runtime.current_weight_ref.epoch", align 512
  call fastcc void @"laya::full::(anonymous namespace)::Controller::fresh"(i8* %ref.tmp73.0203, i8* %ref.tmp73.1204, i32* %ref.tmp73.2205, i8 36, i8 0, i8 0)
  %.042 = load i8, i8* %ref.tmp73.0203, align 512
  %.143 = load i8, i8* %ref.tmp73.1204, align 512
  %.244 = load i32, i32* %ref.tmp73.2205, align 512
  %conv82 = zext i8 %conv46 to i32
  %mul85 = mul nuw nsw i32 %conv82, %conv84
  call fastcc void @"laya::full::(anonymous namespace)::Controller::issue<laya::LinearTask>"(i16* %ref.tmp81.0197, i32* %ref.tmp81.1198, i64* %ref.tmp81.2199, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i64* %this_memory.5, i64* %this_memory.7, i64* %this_memory.9, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i32 %add.i38, i8 %op, i8 %stage, i8 %layer, i8 %conv48, i8 %source_row_space.val, i16 %conv50, i8 %conv46, i8 %.071, i8 %.172, i32 %.273, i8 %.045, i8 %.146, i32 %.247, i8 %.042, i8 %.143, i32 %.244, i8 %dst_ref_id, i8 %dst_ref_bank, i32 %dst_ref_epoch, i8 %key_family.val, i8 %key_layer.val, i16 %3, i16 %1, i8 %dst_region, i8 %4, i32 %mul85)
  %.031 = load i16, i16* %ref.tmp81.0197, align 512
  %.133 = load i32, i32* %ref.tmp81.1198, align 512
  %.235 = load i64, i64* %ref.tmp81.2199, align 512
  %cmp.i39 = icmp eq i16 %.031, 0
  %spec.select2 = select i1 %cmp.i39, i1 true, i1 false
  %add15 = add nuw nsw i32 %row.017, 16
  br i1 %spec.select2, label %for.cond36, label %for.inc92.loopexit

for.inc92.loopexit:                               ; preds = %if.end65, %if.end62
  %13 = phi i16 [ %.031, %if.end65 ], [ %11, %if.end62 ]
  %.1335518 = phi i32 [ %.133, %if.end65 ], [ %.13356, %if.end62 ]
  %.2355816 = phi i64 [ %.235, %if.end65 ], [ %.23559, %if.end62 ]
  store i16 %13, i16* %c.code, align 512
  store i32 %.1335518, i32* %c.detail, align 512
  store i64 %.2355816, i64* %c.bad_element, align 512
  br label %for.inc92

for.inc92:                                        ; preds = %for.inc92.loopexit, %for.cond.cleanup38
  %inc = add nuw nsw i32 %b.0, 1
  br label %for.cond, !llvm.loop !10887

if.else99:                                        ; preds = %for.cond
  %brmerge18 = or i1 %cmp13, %cmp.i40
  br i1 %brmerge18, label %if.end106, label %if.then102

if.then102:                                       ; preds = %if.else99
  call fastcc void @"laya::full::full_publish_owner"(i16* %ref.tmp103.0185, i32* %ref.tmp103.1186, i64* %ref.tmp103.2187, i8 %dst_ref_id, i8 %dst_ref_bank, i32 %dst_ref_epoch, i8 %dst_region, i8 %stage, i8 %layer, i8 -1, i8 %source_row_space.val, i16 0, i16 %cond7.i, i16 %1, i8 1)
  %.019 = load i16, i16* %ref.tmp103.0185, align 512
  %.121 = load i32, i32* %ref.tmp103.1186, align 512
  %.223 = load i64, i64* %ref.tmp103.2187, align 512
  store i16 %.019, i16* %c.code, align 512
  store i32 %.121, i32* %c.detail, align 512
  store i64 %.223, i64* %c.bad_element, align 512
  br label %if.end106

if.end106:                                        ; preds = %if.then102, %if.else99
  %.0 = phi i16 [ %6, %if.else99 ], [ %.019, %if.then102 ]
  %.1 = load i32, i32* %c.detail, align 512
  %.2 = load i64, i64* %c.bad_element, align 512
  br label %cleanup119

cleanup119:                                       ; preds = %if.end106, %if.then28, %if.then
  %storemerge19 = phi i16 [ %0, %if.then ], [ %.086, %if.then28 ], [ %.0, %if.end106 ]
  %storemerge17 = phi i32 [ %.1176, %if.then ], [ %.1, %if.end106 ], [ %.189, %if.then28 ]
  %storemerge15 = phi i64 [ %.2179, %if.then ], [ %.292, %if.then28 ], [ %.2, %if.end106 ]
  store i16 %storemerge19, i16* %agg.result.01, align 512
  store i32 %storemerge17, i32* %agg.result.12, align 512
  store i64 %storemerge15, i64* %agg.result.23, align 512
  ret void
}
