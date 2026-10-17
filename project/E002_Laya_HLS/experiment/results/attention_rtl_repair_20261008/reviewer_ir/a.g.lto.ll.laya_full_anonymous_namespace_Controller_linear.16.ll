define internal fastcc void @"laya::full::(anonymous namespace)::Controller::linear.16"(i16* noalias nocapture align 512 %agg.result.01, i32* noalias nocapture align 512 %agg.result.12, i64* noalias nocapture align 512 %agg.result.23, i8 addrspace(1)* noalias nocapture %embedding, i64 %this_memory.0, i64* noalias nocapture align 512 %this_memory.1, i8 addrspace(1)* noalias nocapture %io, i64 %this_memory.2, i64* noalias nocapture align 512 %this_memory.3, i8 addrspace(1)* noalias nocapture %w_q0, i64 %this_memory.4, i64* noalias nocapture align 512 %this_memory.5, i8 addrspace(1)* noalias nocapture %w_q1, i64 %this_memory.6, i64* noalias nocapture align 512 %this_memory.7, i8 addrspace(1)* noalias nocapture %w_scale, i64 %this_memory.8, i64* noalias nocapture align 512 %this_memory.9, i8 addrspace(1)* noalias nocapture %aux, i64 %this_memory.10, i64* noalias nocapture align 512 %this_memory.11, i8 addrspace(1)* noalias nocapture %state0, i64 %this_memory.12, i64* noalias nocapture align 512 %this_memory.13, i8 addrspace(1)* noalias nocapture %state1, i64 %this_memory.14, i64* noalias nocapture align 512 %this_memory.15, i8 addrspace(1)* noalias nocapture %qkv0, i64 %this_memory.16, i64* noalias nocapture align 512 %this_memory.17, i8 addrspace(1)* noalias nocapture %qkv1, i64 %this_memory.18, i64* noalias nocapture align 512 %this_memory.19, i8 addrspace(1)* noalias nocapture %ff0, i64 %this_memory.20, i64* noalias nocapture align 512 %this_memory.21, i8 addrspace(1)* noalias nocapture %ff1, i64 %this_memory.22, i64* noalias nocapture align 512 %this_memory.23, i8 addrspace(1)* noalias nocapture %att_out, i64 %this_memory.24, i64* noalias nocapture align 512 %this_memory.25, i8* noalias nocapture align 512 %this_error_stage, i8* noalias nocapture align 512 %this_error_op, i32* noalias nocapture align 512 %this_error_task_id, i8* noalias nocapture align 512 %this_current_stage, i8* noalias nocapture align 512 %this_current_op, i8 %key_layer.val, [23 x i192]* noalias align 512 %hidden, i8 zeroext %layer, i8 %dst_ref_id, i8 %dst_ref_bank, i32 %dst_ref_epoch, i8* noalias nocapture align 512 %output_ref_id, i8* noalias nocapture align 512 %output_ref_bank, i32* noalias nocapture align 512 %output_ref_epoch, i8* noalias nocapture align 512 %output_region, i8* noalias nocapture align 512 %output_stage, i8* noalias nocapture align 512 %output_layer, i8* noalias nocapture align 512 %output_batch, i8* noalias nocapture align 512 %output_row_space, i16* noalias nocapture align 512 %output_row0, i16* noalias nocapture align 512 %output_rows, i16* noalias nocapture align 512 %output_width, i8* noalias nocapture align 512 %output_content) unnamed_addr #0 {
entry:
  call void (...) @_ssdm_op_SpecBRAMWithByteEnable([23 x i192]* %hidden)
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
  store i8 2, i8* %this_current_stage, align 512, !alias.scope !11078, !noalias !11081
  store i8 50, i8* %this_current_op, align 512, !alias.scope !11081, !noalias !11078
  br label %arrayinit.body.i

arrayinit.body.i:                                 ; preds = %arrayinit.body.i, %entry
  %arrayinit.curidx.i = phi i64 [ 0, %entry ], [ %arrayinit.nextidx.i, %arrayinit.body.i ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 48, i64 48, i64 48), !fpga.pragma.source !33
  %arrayinit.cur1.i = getelementptr [48 x i8], [48 x i8]* %descriptor.name, i64 0, i64 %arrayinit.curidx.i
  %arrayinit.nextidx.i = add nuw nsw i64 %arrayinit.curidx.i, 1
  store i8 0, i8* %arrayinit.cur1.i, align 1, !alias.scope !11083, !noalias !11086
  %arrayinit.done.i = icmp eq i64 %arrayinit.curidx.i, 47
  br i1 %arrayinit.done.i, label %arrayinit.end.i, label %arrayinit.body.i, !llvm.loop !11103

arrayinit.end.i:                                  ; preds = %arrayinit.body.i
  store i8 0, i8* %descriptor.key.family, align 512, !alias.scope !11104, !noalias !11107
  store i8 -1, i8* %descriptor.key.layer, align 512, !alias.scope !11109, !noalias !11110
  store i16 0, i16* %descriptor.K, align 512, !alias.scope !11111, !noalias !11112
  store i16 0, i16* %descriptor.N, align 512, !alias.scope !11113, !noalias !11114
  store i8 0, i8* %descriptor.dtype, align 512, !alias.scope !11115, !noalias !11116
  store i8 0, i8* %descriptor.bias_kind, align 512, !alias.scope !11117, !noalias !11118
  br label %arrayinit.body3.i

arrayinit.body3.i:                                ; preds = %arrayinit.body3.i, %arrayinit.end.i
  %arrayinit.curidx4.i = phi i64 [ 0, %arrayinit.end.i ], [ %arrayinit.nextidx6.i, %arrayinit.body3.i ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 2, i64 2, i64 2), !fpga.pragma.source !33
  %arrayinit.cur52.i = getelementptr [2 x i32], [2 x i32]* %descriptor.q_base, i64 0, i64 %arrayinit.curidx4.i
  %arrayinit.nextidx6.i = add nuw nsw i64 %arrayinit.curidx4.i, 1
  store i32 0, i32* %arrayinit.cur52.i, align 4, !alias.scope !11119, !noalias !11120
  %arrayinit.done7.i = icmp eq i64 %arrayinit.curidx4.i, 1
  br i1 %arrayinit.done7.i, label %arrayinit.end8.i, label %arrayinit.body3.i, !llvm.loop !11121

arrayinit.end8.i:                                 ; preds = %arrayinit.body3.i
  br label %arrayinit.body10.i

arrayinit.body10.i:                               ; preds = %arrayinit.body10.i, %arrayinit.end8.i
  %arrayinit.curidx11.i = phi i64 [ 0, %arrayinit.end8.i ], [ %arrayinit.nextidx13.i, %arrayinit.body10.i ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 2, i64 2, i64 2), !fpga.pragma.source !33
  %arrayinit.cur123.i = getelementptr [2 x i32], [2 x i32]* %descriptor.q_span, i64 0, i64 %arrayinit.curidx11.i
  %arrayinit.nextidx13.i = add nuw nsw i64 %arrayinit.curidx11.i, 1
  store i32 0, i32* %arrayinit.cur123.i, align 4, !alias.scope !11122, !noalias !11123
  %arrayinit.done14.i = icmp eq i64 %arrayinit.curidx11.i, 1
  br i1 %arrayinit.done14.i, label %arrayinit.end15.i, label %arrayinit.body10.i, !llvm.loop !11124

arrayinit.end15.i:                                ; preds = %arrayinit.body10.i
  store i32 0, i32* %descriptor.scale_base, align 512, !alias.scope !11125, !noalias !11126
  store i32 0, i32* %descriptor.scale_span, align 512, !alias.scope !11127, !noalias !11128
  store i32 0, i32* %descriptor.aux_base, align 512, !alias.scope !11129, !noalias !11130
  store i32 0, i32* %descriptor.aux_span, align 512, !alias.scope !11131, !noalias !11132
  store i32 0, i32* %descriptor.bias_base, align 512, !alias.scope !11133, !noalias !11134
  store i32 0, i32* %descriptor.bias_span, align 512, !alias.scope !11135, !noalias !11136
  br label %arrayinit.body17.i

arrayinit.body17.i:                               ; preds = %arrayinit.body17.i, %arrayinit.end15.i
  %arrayinit.curidx18.i = phi i64 [ 0, %arrayinit.end15.i ], [ %arrayinit.nextidx20.i, %arrayinit.body17.i ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 32, i64 32, i64 32), !fpga.pragma.source !33
  %arrayinit.cur194.i = getelementptr [32 x i8], [32 x i8]* %descriptor.source_sha256, i64 0, i64 %arrayinit.curidx18.i
  %arrayinit.nextidx20.i = add nuw nsw i64 %arrayinit.curidx18.i, 1
  store i8 0, i8* %arrayinit.cur194.i, align 1, !alias.scope !11137, !noalias !11138
  %arrayinit.done21.i = icmp eq i64 %arrayinit.curidx18.i, 31
  br i1 %arrayinit.done21.i, label %arrayinit.end22.i, label %arrayinit.body17.i, !llvm.loop !11139

arrayinit.end22.i:                                ; preds = %arrayinit.body17.i
  br label %arrayinit.body24.i

arrayinit.body24.i:                               ; preds = %arrayinit.body24.i, %arrayinit.end22.i
  %arrayinit.curidx25.i = phi i64 [ 0, %arrayinit.end22.i ], [ %arrayinit.nextidx27.i, %arrayinit.body24.i ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 32, i64 32, i64 32), !fpga.pragma.source !33
  %arrayinit.cur265.i = getelementptr [32 x i8], [32 x i8]* %descriptor.bias_sha256, i64 0, i64 %arrayinit.curidx25.i
  %arrayinit.nextidx27.i = add nuw nsw i64 %arrayinit.curidx25.i, 1
  store i8 0, i8* %arrayinit.cur265.i, align 1, !alias.scope !11140, !noalias !11141
  %arrayinit.done28.i = icmp eq i64 %arrayinit.curidx25.i, 31
  br i1 %arrayinit.done28.i, label %_ZN4laya4full20FullWeightDescriptorC2Ev.exit, label %arrayinit.body24.i, !llvm.loop !11142

_ZN4laya4full20FullWeightDescriptorC2Ev.exit:     ; preds = %arrayinit.body24.i
  call fastcc void @"laya::full::(anonymous namespace)::Controller::load_weight"(i16* %c.code, i32* %c.detail, i64* %c.bad_element, i8 addrspace(1)* %embedding, i64 %this_memory.0, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i64* %this_memory.5, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i64* %this_memory.7, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i64* %this_memory.9, i8 addrspace(1)* %aux, i64 %this_memory.10, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i8 3, i8 %key_layer.val, i8 2, i8 %layer, [48 x i8]* %descriptor.name, i8* %descriptor.key.family, i8* %descriptor.key.layer, i16* %descriptor.K, i16* %descriptor.N, i8* %descriptor.dtype, i8* %descriptor.bias_kind, [2 x i32]* %descriptor.q_base, [2 x i32]* %descriptor.q_span, i32* %descriptor.scale_base, i32* %descriptor.scale_span, i32* %descriptor.aux_base, i32* %descriptor.aux_span, i32* %descriptor.bias_base, i32* %descriptor.bias_span, [32 x i8]* %descriptor.source_sha256, [32 x i8]* %descriptor.bias_sha256)
  %0 = load i16, i16* %c.code, align 512, !alias.scope !11143
  %cmp.i = icmp eq i16 %0, 0
  br i1 %cmp.i, label %if.end, label %if.then

if.then:                                          ; preds = %_ZN4laya4full20FullWeightDescriptorC2Ev.exit
  %.1176 = load i32, i32* %c.detail, align 512
  %.2179 = load i64, i64* %c.bad_element, align 512
  br label %cleanup119

if.end:                                           ; preds = %_ZN4laya4full20FullWeightDescriptorC2Ev.exit
  store i8 2, i8* %this_current_stage, align 512, !alias.scope !11146, !noalias !11149
  store i8 50, i8* %this_current_op, align 512, !alias.scope !11149, !noalias !11146
  %1 = getelementptr [23 x i192], [23 x i192]* %hidden, i64 0, i64 21
  %2 = load i192, i192* %1
  %3 = lshr i192 %2, 160
  %4 = trunc i192 %3 to i8
  %5 = load i16, i16* %descriptor.N, align 512
  %cmp.i34 = icmp eq i8 %4, 0
  %6 = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.S", align 512
  %cmp6.i = icmp eq i8 %4, 1
  %cond.i = select i1 %cmp6.i, i16 16, i16 1
  %cond7.i = select i1 %cmp.i34, i16 %6, i16 %cond.i
  store i8 %dst_ref_id, i8* %output_ref_id, align 512
  store i8 %dst_ref_bank, i8* %output_ref_bank, align 512
  store i32 %dst_ref_epoch, i32* %output_ref_epoch, align 512
  store i8 0, i8* %output_region, align 512
  store i8 2, i8* %output_stage, align 512
  store i8 %layer, i8* %output_layer, align 512
  store i8 -1, i8* %output_batch, align 512
  store i8 %4, i8* %output_row_space, align 512
  store i16 0, i16* %output_row0, align 512
  store i16 %cond7.i, i16* %output_rows, align 512
  store i16 %5, i16* %output_width, align 512
  store i8 1, i8* %output_content, align 512
  call fastcc void @"laya::full::full_claim_owner"(i16* %ref.tmp23.0265, i32* %ref.tmp23.1266, i64* %ref.tmp23.2267, i8 %dst_ref_id, i8 %dst_ref_bank, i32 %dst_ref_epoch, i8 0, i8 2, i8 %layer, i8 -1, i8 %4, i16 0, i16 %cond7.i, i16 %5, i8 1)
  %.094 = load i16, i16* %ref.tmp23.0265, align 512
  %.196 = load i32, i32* %ref.tmp23.1266, align 512
  %.298 = load i64, i64* %ref.tmp23.2267, align 512
  store i16 %.094, i16* %c.code, align 512
  store i32 %.196, i32* %c.detail, align 512
  store i64 %.298, i64* %c.bad_element, align 512
  %cmp.i35 = icmp eq i16 %.094, 0
  br i1 %cmp.i35, label %if.end29, label %cleanup119

if.end29:                                         ; preds = %if.end
  %7 = getelementptr [23 x i192], [23 x i192]* %hidden, i64 0, i64 22
  %8 = load i192, i192* %7
  %9 = trunc i192 %8 to i16
  %conv31 = zext i16 %9 to i32
  %10 = load i16, i16* %descriptor.K, align 512
  %conv61 = zext i16 %10 to i32
  %11 = load i8, i8* %descriptor.bias_kind, align 512
  %cmp3719 = icmp ne i16 %9, 0
  %conv84 = zext i16 %5 to i32
  br label %for.cond

for.cond:                                         ; preds = %for.inc92, %if.end29
  %.27 = phi i64 [ %.298, %if.end29 ], [ %.28, %for.inc92 ]
  %.13 = phi i32 [ %.196, %if.end29 ], [ %.14, %for.inc92 ]
  %b.0 = phi i32 [ 0, %if.end29 ], [ %inc, %for.inc92 ]
  %12 = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.B", align 512
  %conv33 = zext i16 %12 to i32
  %cmp34 = icmp uge i32 %b.0, %conv33
  %13 = load i16, i16* %c.code, align 512, !alias.scope !11151
  %cmp.i43 = icmp ne i16 %13, 0
  %brmerge45 = or i1 %cmp34, %cmp.i43
  br i1 %brmerge45, label %if.else99, label %VITIS_LOOP_220_2

VITIS_LOOP_220_2:                                 ; preds = %for.cond
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @199)
  %conv48 = trunc i32 %b.0 to i8
  br label %for.body39

for.cond36:                                       ; preds = %if.end65
  br label %for.body39, !llvm.loop !11156

for.cond.cleanup38.loopexit:                      ; preds = %for.body39
  br i1 %cmp3719, label %for.cond.cleanup38.loopexit.split, label %for.inc92

for.cond.cleanup38.loopexit.split:                ; preds = %for.cond.cleanup38.loopexit
  store i16 %.031.phi, i16* %c.code, align 512
  store i32 %.133.phi, i32* %c.detail, align 512
  store i64 %.235.phi, i64* %c.bad_element, align 512
  br label %for.inc92

for.body39:                                       ; preds = %for.cond36, %VITIS_LOOP_220_2
  %row.020 = phi i32 [ 0, %VITIS_LOOP_220_2 ], [ %add5, %for.cond36 ]
  %.031.phi = phi i16 [ undef, %VITIS_LOOP_220_2 ], [ %.031, %for.cond36 ]
  %.133.phi = phi i32 [ %.13, %VITIS_LOOP_220_2 ], [ %.133, %for.cond36 ]
  %.235.phi = phi i64 [ %.27, %VITIS_LOOP_220_2 ], [ %.235, %for.cond36 ]
  %cmp371 = icmp ult i32 %row.020, %conv31
  br i1 %cmp371, label %for.body39.split, label %for.cond.cleanup38.loopexit, !llvm.loop !11156

for.body39.split:                                 ; preds = %for.body39
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 0, i64 4096, i64 2048), !fpga.pragma.source !33
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @198)
  %sub = sub nsw i32 %conv31, %row.020
  %cmp40 = icmp ult i32 %sub, 16
  %cond45 = select i1 %cmp40, i32 %sub, i32 16
  %conv46 = trunc i32 %cond45 to i8
  %14 = load i192, i192* %1
  %15 = lshr i192 %14, 160
  %16 = trunc i192 %15 to i8
  %conv50 = trunc i32 %row.020 to i16
  %17 = load i32, i32* @"(anonymous namespace)::runtime.last_task_id", align 512, !alias.scope !11284, !noalias !11287
  %add.i = add i32 %17, 1
  %18 = lshr i192 %14, 64
  %19 = trunc i192 %18 to i8
  %20 = lshr i192 %14, 72
  %21 = trunc i192 %20 to i8
  %22 = lshr i192 %14, 96
  %23 = trunc i192 %22 to i32
  %24 = lshr i192 %14, 128
  %25 = trunc i192 %24 to i8
  call fastcc void @"laya::full::(anonymous namespace)::Controller::fresh"(i8* %ref.tmp52.0243, i8* %ref.tmp52.1244, i32* %ref.tmp52.2245, i8 34, i8 0, i8 0)
  %.071 = load i8, i8* %ref.tmp52.0243, align 512
  %.172 = load i8, i8* %ref.tmp52.1244, align 512
  %.273 = load i32, i32* %ref.tmp52.2245, align 512
  %26 = load i1, i1* @"(anonymous namespace)::runtime.request_valid", align 512, !alias.scope !11296, !noalias !11299
  br i1 %26, label %lor.lhs.false.i, label %_ZN4laya4full22full_bind_quant_sourceERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE.exit

lor.lhs.false.i:                                  ; preds = %for.body39.split
  %27 = load i1, i1* @"(anonymous namespace)::runtime.model_header_valid", align 512, !alias.scope !11296, !noalias !11299
  br i1 %27, label %lor.lhs.false1.i, label %_ZN4laya4full22full_bind_quant_sourceERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE.exit

lor.lhs.false1.i:                                 ; preds = %lor.lhs.false.i
  %28 = call fastcc i1 @"laya::full::(anonymous namespace)::legal_spec.24"([23 x i192]* %hidden)
  br i1 %28, label %lor.lhs.false2.i, label %_ZN4laya4full22full_bind_quant_sourceERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE.exit

lor.lhs.false2.i:                                 ; preds = %lor.lhs.false1.i
  %29 = load i192, i192* %7
  %30 = lshr i192 %29, 32
  %31 = trunc i192 %30 to i8
  %cmp.i37 = icmp ne i8 %31, 1
  %cmp4.i = icmp eq i8 %19, 0
  %or.cond = or i1 %cmp.i37, %cmp4.i
  br i1 %or.cond, label %_ZN4laya4full22full_bind_quant_sourceERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE.exit, label %if.then57

_ZN4laya4full22full_bind_quant_sourceERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE.exit: ; preds = %lor.lhs.false2.i, %lor.lhs.false1.i, %lor.lhs.false.i, %for.body39.split
  %conv1.i.i.i = zext i8 %19 to i32
  %shl2.i.i.i = shl nuw nsw i32 %conv1.i.i.i, 16
  %or4.i.i.i = or i32 %shl2.i.i.i, 67108873
  br label %if.end62

if.then57:                                        ; preds = %lor.lhs.false2.i
  %32 = load i192, i192* %1
  %33 = lshr i192 %32, 136
  %34 = trunc i192 %33 to i8
  %35 = lshr i192 %32, 144
  %36 = trunc i192 %35 to i8
  %37 = lshr i192 %32, 152
  %38 = trunc i192 %37 to i8
  %39 = lshr i192 %32, 176
  %40 = trunc i192 %39 to i16
  %41 = trunc i192 %29 to i16
  %42 = lshr i192 %29, 16
  %43 = trunc i192 %42 to i16
  store i8 %19, i8* @"(anonymous namespace)::runtime.expected_quant_source.ref.id", align 512, !alias.scope !11296, !noalias !11299
  store i8 %21, i8* @"(anonymous namespace)::runtime.expected_quant_source.ref.bank", align 512, !alias.scope !11296, !noalias !11299
  store i32 %23, i32* @"(anonymous namespace)::runtime.expected_quant_source.ref.epoch", align 512, !alias.scope !11296, !noalias !11299
  store i8 %25, i8* @"(anonymous namespace)::runtime.expected_quant_source.region", align 512, !alias.scope !11296, !noalias !11299
  store i8 %34, i8* @"(anonymous namespace)::runtime.expected_quant_source.stage", align 512, !alias.scope !11296, !noalias !11299
  store i8 %36, i8* @"(anonymous namespace)::runtime.expected_quant_source.layer", align 512, !alias.scope !11296, !noalias !11299
  store i8 %38, i8* @"(anonymous namespace)::runtime.expected_quant_source.batch", align 512, !alias.scope !11296, !noalias !11299
  store i8 %16, i8* @"(anonymous namespace)::runtime.expected_quant_source.row_space", align 512, !alias.scope !11296, !noalias !11299
  store i16 %40, i16* @"(anonymous namespace)::runtime.expected_quant_source.row0", align 512, !alias.scope !11296, !noalias !11299
  store i16 %41, i16* @"(anonymous namespace)::runtime.expected_quant_source.rows", align 512, !alias.scope !11296, !noalias !11299
  store i16 %43, i16* @"(anonymous namespace)::runtime.expected_quant_source.width", align 512, !alias.scope !11296, !noalias !11299
  store i8 1, i8* @"(anonymous namespace)::runtime.expected_quant_source.content", align 512, !alias.scope !11296, !noalias !11299
  store i1 true, i1* @"(anonymous namespace)::runtime.expected_quant_source_valid", align 512, !alias.scope !11296, !noalias !11299
  %conv59 = zext i8 %conv46 to i32
  %mul = mul nuw nsw i32 %conv59, %conv61
  %div = udiv i32 %mul, 32
  call fastcc void @"laya::full::(anonymous namespace)::Controller::issue<laya::QuantTask>"(i16* %ref.tmp58.0231, i32* %ref.tmp58.1232, i64* %ref.tmp58.2233, i8 addrspace(1)* %embedding, i64 %this_memory.0, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i64* %this_memory.5, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i64* %this_memory.7, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i64* %this_memory.9, i8 addrspace(1)* %aux, i64 %this_memory.10, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i32 %add.i, i8 2, i8 %layer, i8 %conv48, i8 %16, i16 %conv50, i8 %conv46, i8 %19, i8 %21, i32 %23, i8 %.071, i8 %.172, i32 %.273, i16 %10, i8 %25, i32 %div)
  %.059 = load i16, i16* %ref.tmp58.0231, align 512
  %.161 = load i32, i32* %ref.tmp58.1232, align 512
  %.263 = load i64, i64* %ref.tmp58.2233, align 512
  br label %if.end62

if.end62:                                         ; preds = %if.then57, %_ZN4laya4full22full_bind_quant_sourceERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE.exit
  %.23552 = phi i64 [ %.263, %if.then57 ], [ -1, %_ZN4laya4full22full_bind_quant_sourceERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE.exit ]
  %.13349 = phi i32 [ %.161, %if.then57 ], [ %or4.i.i.i, %_ZN4laya4full22full_bind_quant_sourceERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE.exit ]
  %44 = phi i16 [ %.059, %if.then57 ], [ 5, %_ZN4laya4full22full_bind_quant_sourceERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE.exit ]
  %cmp.i39 = icmp eq i16 %44, 0
  br i1 %cmp.i39, label %if.end65, label %for.inc92.loopexit

if.end65:                                         ; preds = %if.end62
  %45 = load i192, i192* %1
  %46 = lshr i192 %45, 160
  %47 = trunc i192 %46 to i8
  %48 = load i32, i32* @"(anonymous namespace)::runtime.last_task_id", align 512, !alias.scope !11304, !noalias !11307
  %add.i41 = add i32 %48, 1
  %.045 = load i8, i8* @"(anonymous namespace)::runtime.current_weight_ref.id", align 512
  %.146 = load i8, i8* @"(anonymous namespace)::runtime.current_weight_ref.bank", align 512
  %.247 = load i32, i32* @"(anonymous namespace)::runtime.current_weight_ref.epoch", align 512
  call fastcc void @"laya::full::(anonymous namespace)::Controller::fresh"(i8* %ref.tmp73.0203, i8* %ref.tmp73.1204, i32* %ref.tmp73.2205, i8 36, i8 0, i8 0)
  %.042 = load i8, i8* %ref.tmp73.0203, align 512
  %.143 = load i8, i8* %ref.tmp73.1204, align 512
  %.244 = load i32, i32* %ref.tmp73.2205, align 512
  %conv82 = zext i8 %conv46 to i32
  %mul85 = mul nuw nsw i32 %conv82, %conv84
  call fastcc void @"laya::full::(anonymous namespace)::Controller::issue<laya::LinearTask>"(i16* %ref.tmp81.0197, i32* %ref.tmp81.1198, i64* %ref.tmp81.2199, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i64* %this_memory.5, i64* %this_memory.7, i64* %this_memory.9, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i32 %add.i41, i8 50, i8 2, i8 %layer, i8 %conv48, i8 %47, i16 %conv50, i8 %conv46, i8 %.071, i8 %.172, i32 %.273, i8 %.045, i8 %.146, i32 %.247, i8 %.042, i8 %.143, i32 %.244, i8 %dst_ref_id, i8 %dst_ref_bank, i32 %dst_ref_epoch, i8 3, i8 %key_layer.val, i16 %10, i16 %5, i8 0, i8 %11, i32 %mul85)
  %.031 = load i16, i16* %ref.tmp81.0197, align 512
  %.133 = load i32, i32* %ref.tmp81.1198, align 512
  %.235 = load i64, i64* %ref.tmp81.2199, align 512
  %cmp.i42 = icmp eq i16 %.031, 0
  %spec.select9 = select i1 %cmp.i42, i1 true, i1 false
  %add5 = add nuw nsw i32 %row.020, 16
  br i1 %spec.select9, label %for.cond36, label %for.inc92.loopexit

for.inc92.loopexit:                               ; preds = %if.end65, %if.end62
  %49 = phi i16 [ %.031, %if.end65 ], [ %44, %if.end62 ]
  %.133488 = phi i32 [ %.133, %if.end65 ], [ %.13349, %if.end62 ]
  %.235516 = phi i64 [ %.235, %if.end65 ], [ %.23552, %if.end62 ]
  br i1 %cmp3719, label %for.inc92.loopexit.split, label %for.inc92

for.inc92.loopexit.split:                         ; preds = %for.inc92.loopexit
  store i16 %49, i16* %c.code, align 512
  store i32 %.133488, i32* %c.detail, align 512
  store i64 %.235516, i64* %c.bad_element, align 512
  br label %for.inc92

for.inc92:                                        ; preds = %for.inc92.loopexit.split, %for.inc92.loopexit, %for.cond.cleanup38.loopexit.split, %for.cond.cleanup38.loopexit
  %.28 = phi i64 [ %.235516, %for.inc92.loopexit.split ], [ %.235.phi, %for.cond.cleanup38.loopexit.split ], [ %.235.phi, %for.cond.cleanup38.loopexit ], [ %.235516, %for.inc92.loopexit ]
  %.14 = phi i32 [ %.133488, %for.inc92.loopexit.split ], [ %.133.phi, %for.cond.cleanup38.loopexit.split ], [ %.133.phi, %for.cond.cleanup38.loopexit ], [ %.133488, %for.inc92.loopexit ]
  %inc = add nuw nsw i32 %b.0, 1
  br label %for.cond, !llvm.loop !11316

if.else99:                                        ; preds = %for.cond
  br i1 %cmp.i43, label %cleanup119, label %if.then102

if.then102:                                       ; preds = %if.else99
  call fastcc void @"laya::full::full_publish_owner"(i16* %ref.tmp103.0185, i32* %ref.tmp103.1186, i64* %ref.tmp103.2187, i8 %dst_ref_id, i8 %dst_ref_bank, i32 %dst_ref_epoch, i8 0, i8 2, i8 %layer, i8 -1, i8 %4, i16 0, i16 %cond7.i, i16 %5, i8 1)
  %.019 = load i16, i16* %ref.tmp103.0185, align 512
  %.121 = load i32, i32* %ref.tmp103.1186, align 512
  %.223 = load i64, i64* %ref.tmp103.2187, align 512
  store i16 %.019, i16* %c.code, align 512
  store i32 %.121, i32* %c.detail, align 512
  store i64 %.223, i64* %c.bad_element, align 512
  br label %cleanup119

cleanup119:                                       ; preds = %if.then102, %if.else99, %if.end, %if.then
  %storemerge72 = phi i16 [ %0, %if.then ], [ %.094, %if.end ], [ %13, %if.else99 ], [ %.019, %if.then102 ]
  %storemerge70 = phi i32 [ %.1176, %if.then ], [ %.196, %if.end ], [ %.13, %if.else99 ], [ %.121, %if.then102 ]
  %storemerge68 = phi i64 [ %.2179, %if.then ], [ %.298, %if.end ], [ %.27, %if.else99 ], [ %.223, %if.then102 ]
  store i16 %storemerge72, i16* %agg.result.01, align 512
  store i32 %storemerge70, i32* %agg.result.12, align 512
  store i64 %storemerge68, i64* %agg.result.23, align 512
  ret void
}
