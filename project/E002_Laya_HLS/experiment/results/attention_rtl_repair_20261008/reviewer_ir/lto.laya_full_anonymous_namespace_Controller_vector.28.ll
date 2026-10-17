define internal fastcc void @"laya::full::(anonymous namespace)::Controller::vector.28"(i16* noalias nocapture align 512 %agg.result_code, i32* noalias nocapture align 512 %agg.result_detail, i64* noalias nocapture align 512 %agg.result_bad_element, i8 addrspace(1)* noalias nocapture %embedding, i64 %this_memory.0, i64* noalias nocapture align 512 %this_memory.1, i8 addrspace(1)* noalias nocapture %io, i64 %this_memory.2, i64* noalias nocapture align 512 %this_memory.3, i8 addrspace(1)* noalias nocapture %w_q0, i64 %this_memory.4, i64* noalias nocapture align 512 %this_memory.5, i8 addrspace(1)* noalias nocapture %w_q1, i64 %this_memory.6, i64* noalias nocapture align 512 %this_memory.7, i8 addrspace(1)* noalias nocapture %w_scale, i64 %this_memory.8, i64* noalias nocapture align 512 %this_memory.9, i8 addrspace(1)* noalias nocapture %aux, i64 %this_memory.10, i64* noalias nocapture align 512 %this_memory.11, i8 addrspace(1)* noalias nocapture %state0, i64 %this_memory.12, i64* noalias nocapture align 512 %this_memory.13, i8 addrspace(1)* noalias nocapture %state1, i64 %this_memory.14, i64* noalias nocapture align 512 %this_memory.15, i8 addrspace(1)* noalias nocapture %qkv0, i64 %this_memory.16, i64* noalias nocapture align 512 %this_memory.17, i8 addrspace(1)* noalias nocapture %qkv1, i64 %this_memory.18, i64* noalias nocapture align 512 %this_memory.19, i8 addrspace(1)* noalias nocapture %ff0, i64 %this_memory.20, i64* noalias nocapture align 512 %this_memory.21, i8 addrspace(1)* noalias nocapture %ff1, i64 %this_memory.22, i64* noalias nocapture align 512 %this_memory.23, i8 addrspace(1)* noalias nocapture %att_out, i64 %this_memory.24, i64* noalias nocapture align 512 %this_memory.25, i8* noalias nocapture align 512 %this_error_stage, i8* noalias nocapture align 512 %this_error_op, i32* noalias nocapture align 512 %this_error_task_id, i8* noalias nocapture align 512 %this_current_stage, i8* noalias nocapture align 512 %this_current_op, i8 %src0_ref_id.val, i8 %src0_ref_bank.val, i32 %src0_ref_epoch.val, i8 %src0_region.val, i8 %src0_stage.val, i8 %src0_layer.val, i8 %src0_batch.val, i8 %src0_row_space.val, i16 %src0_row0.val, i16 %src0_rows.val, i16 %src0_width.val, i8 %src0_content.val, [23 x i192]* noalias align 512 %hidden, i8 zeroext %stage, i8 zeroext %layer, i8 %dst_ref_bank, i32 %dst_ref_epoch, i8* noalias nocapture align 512 %output_ref_id, i8* noalias nocapture align 512 %output_ref_bank, i32* noalias nocapture align 512 %output_ref_epoch, i8* noalias nocapture align 512 %output_region, i8* noalias nocapture align 512 %output_stage, i8* noalias nocapture align 512 %output_layer, i8* noalias nocapture align 512 %output_batch, i8* noalias nocapture align 512 %output_row_space, i16* noalias nocapture align 512 %output_row0, i16* noalias nocapture align 512 %output_rows, i16* noalias nocapture align 512 %output_width, i8* noalias nocapture align 512 %output_content) unnamed_addr #0 {
entry:
  call void (...) @_ssdm_op_SpecBRAMWithByteEnable([23 x i192]* %hidden)
  %ref.tmp48.057 = alloca i16, align 512
  %ref.tmp48.158 = alloca i32, align 512
  %ref.tmp48.259 = alloca i64, align 512
  %ref.tmp63.051 = alloca i16, align 512
  %ref.tmp63.152 = alloca i32, align 512
  %ref.tmp63.253 = alloca i64, align 512
  store i8 %stage, i8* %this_current_stage, align 512, !alias.scope !14270, !noalias !14273
  store i8 98, i8* %this_current_op, align 512, !alias.scope !14273, !noalias !14270
  %cmp.i = icmp eq i8 %src0_row_space.val, 0
  %0 = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.S", align 512
  %cmp6.i = icmp eq i8 %src0_row_space.val, 1
  %cond.i = select i1 %cmp6.i, i16 16, i16 1
  %cond7.i = select i1 %cmp.i, i16 %0, i16 %cond.i
  store i8 1, i8* %output_ref_id, align 512
  store i8 %dst_ref_bank, i8* %output_ref_bank, align 512
  store i32 %dst_ref_epoch, i32* %output_ref_epoch, align 512
  store i8 0, i8* %output_region, align 512
  store i8 %stage, i8* %output_stage, align 512
  store i8 %layer, i8* %output_layer, align 512
  store i8 -1, i8* %output_batch, align 512
  store i8 %src0_row_space.val, i8* %output_row_space, align 512
  store i16 0, i16* %output_row0, align 512
  store i16 %cond7.i, i16* %output_rows, align 512
  store i16 1024, i16* %output_width, align 512
  store i8 1, i8* %output_content, align 512
  call fastcc void @"laya::full::full_claim_owner"(i16* %agg.result_code, i32* %agg.result_detail, i64* %agg.result_bad_element, i8 1, i8 %dst_ref_bank, i32 %dst_ref_epoch, i8 0, i8 %stage, i8 %layer, i8 -1, i8 %src0_row_space.val, i16 0, i16 %cond7.i, i16 1024, i8 1)
  %1 = load i16, i16* %agg.result_code, align 512, !alias.scope !14275
  %cmp.i6 = icmp eq i16 %1, 0
  br i1 %cmp.i6, label %if.end, label %return

if.end:                                           ; preds = %entry
  %conv = zext i16 %cond7.i to i32
  %cmp84 = icmp ne i16 %cond7.i, 0
  %conv1.i.i.i.i = zext i8 %src0_ref_id.val to i32
  %shl2.i.i.i.i = shl nuw nsw i32 %conv1.i.i.i.i, 16
  %or4.i.i.i.i = or i32 %shl2.i.i.i.i, 67108873
  %cmp.i.i = icmp eq i8 %src0_ref_id.val, 0
  br label %for.cond

for.cond:                                         ; preds = %for.inc58, %if.end
  %2 = phi i16 [ 0, %if.end ], [ %10, %for.inc58 ]
  %b.0 = phi i32 [ 0, %if.end ], [ %inc, %for.inc58 ]
  %3 = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.B", align 512
  %conv4 = zext i16 %3 to i32
  %cmp5 = icmp uge i32 %b.0, %conv4
  %cmp.i52 = icmp eq i16 %2, 0
  %cmp.i52.not = xor i1 %cmp.i52, true
  %brmerge58 = or i1 %cmp5, %cmp.i52.not
  br i1 %brmerge58, label %for.end60, label %VITIS_LOOP_176_2

VITIS_LOOP_176_2:                                 ; preds = %for.cond
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @201)
  %conv12 = trunc i32 %b.0 to i8
  br i1 %cmp84, label %for.body10.lr.ph, label %for.inc58

for.body10.lr.ph:                                 ; preds = %VITIS_LOOP_176_2
  br label %for.body10

for.body10:                                       ; preds = %if.end53, %for.body10.lr.ph
  %row.05 = phi i32 [ 0, %for.body10.lr.ph ], [ %add, %if.end53 ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 0, i64 4096, i64 2048), !fpga.pragma.source !33
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @200)
  %conv14 = trunc i32 %row.05 to i16
  %sub = sub nsw i32 %conv, %row.05
  %cmp15 = icmp ult i32 %sub, 16
  %cond20 = select i1 %cmp15, i32 %sub, i32 16
  %conv21 = trunc i32 %cond20 to i8
  %4 = load i32, i32* @"(anonymous namespace)::runtime.last_task_id", align 512, !alias.scope !14278, !noalias !14281
  %add.i = add i32 %4, 1
  %5 = load i1, i1* @"(anonymous namespace)::runtime.request_valid", align 512, !alias.scope !14290, !noalias !14295
  br i1 %5, label %lor.lhs.false.i.i, label %if.then.i.i

lor.lhs.false.i.i:                                ; preds = %for.body10
  %6 = load i1, i1* @"(anonymous namespace)::runtime.model_header_valid", align 512, !alias.scope !14290, !noalias !14295
  br i1 %6, label %lor.lhs.false1.i.i, label %if.then.i.i

lor.lhs.false1.i.i:                               ; preds = %lor.lhs.false.i.i
  %7 = call fastcc i1 @"laya::full::(anonymous namespace)::legal_spec"(i8 %src0_ref_id.val, i8 %src0_ref_bank.val, i32 %src0_ref_epoch.val, i8 %src0_region.val, i8 %src0_stage.val, i8 %src0_batch.val, i8 %src0_row_space.val, i16 %src0_row0.val, i16 %src0_rows.val, i16 %src0_width.val)
  %call.i.i.not = xor i1 %7, true
  %or.cond = or i1 %cmp.i.i, %call.i.i.not
  br i1 %or.cond, label %if.then.i.i, label %lor.lhs.false3.i.i

lor.lhs.false3.i.i:                               ; preds = %lor.lhs.false1.i.i
  %8 = load i8, i8* @"(anonymous namespace)::runtime.expected_task_source_count", align 512, !alias.scope !14290, !noalias !14295
  %cmp4.i.i = icmp ugt i8 %8, 3
  br i1 %cmp4.i.i, label %if.then.i.i, label %if.end.i.i

if.then.i.i:                                      ; preds = %lor.lhs.false3.i.i, %lor.lhs.false1.i.i, %lor.lhs.false.i.i, %for.body10
  br label %if.end45

if.end.i.i:                                       ; preds = %lor.lhs.false3.i.i
  %inc.i.i = add nuw nsw i8 %8, 1
  store i8 %inc.i.i, i8* @"(anonymous namespace)::runtime.expected_task_source_count", align 512, !alias.scope !14290, !noalias !14295
  %idxprom.i.i = zext i8 %8 to i64
  %arrayidx3.0.01.i.i = getelementptr [4 x i8], [4 x i8]* @"(anonymous namespace)::runtime.expected_task_source.ref.id", i64 0, i64 %idxprom.i.i
  store i8 %src0_ref_id.val, i8* %arrayidx3.0.01.i.i, align 4, !alias.scope !14290, !noalias !14295
  %arrayidx3.0.12.i.i = getelementptr [4 x i8], [4 x i8]* @"(anonymous namespace)::runtime.expected_task_source.ref.bank", i64 0, i64 %idxprom.i.i
  store i8 %src0_ref_bank.val, i8* %arrayidx3.0.12.i.i, align 1, !alias.scope !14290, !noalias !14295
  %arrayidx3.0.23.i.i = getelementptr [4 x i32], [4 x i32]* @"(anonymous namespace)::runtime.expected_task_source.ref.epoch", i64 0, i64 %idxprom.i.i
  store i32 %src0_ref_epoch.val, i32* %arrayidx3.0.23.i.i, align 8, !alias.scope !14290, !noalias !14295
  %arrayidx3.14.i.i = getelementptr [4 x i8], [4 x i8]* @"(anonymous namespace)::runtime.expected_task_source.region", i64 0, i64 %idxprom.i.i
  store i8 %src0_region.val, i8* %arrayidx3.14.i.i, align 4, !alias.scope !14290, !noalias !14295
  %arrayidx3.25.i.i = getelementptr [4 x i8], [4 x i8]* @"(anonymous namespace)::runtime.expected_task_source.stage", i64 0, i64 %idxprom.i.i
  store i8 %src0_stage.val, i8* %arrayidx3.25.i.i, align 1, !alias.scope !14290, !noalias !14295
  %arrayidx3.36.i.i = getelementptr [4 x i8], [4 x i8]* @"(anonymous namespace)::runtime.expected_task_source.layer", i64 0, i64 %idxprom.i.i
  store i8 %src0_layer.val, i8* %arrayidx3.36.i.i, align 2, !alias.scope !14290, !noalias !14295
  %arrayidx3.47.i.i = getelementptr [4 x i8], [4 x i8]* @"(anonymous namespace)::runtime.expected_task_source.batch", i64 0, i64 %idxprom.i.i
  store i8 %src0_batch.val, i8* %arrayidx3.47.i.i, align 1, !alias.scope !14290, !noalias !14295
  %arrayidx3.58.i.i = getelementptr [4 x i8], [4 x i8]* @"(anonymous namespace)::runtime.expected_task_source.row_space", i64 0, i64 %idxprom.i.i
  store i8 %src0_row_space.val, i8* %arrayidx3.58.i.i, align 8, !alias.scope !14290, !noalias !14295
  %arrayidx3.69.i.i = getelementptr [4 x i16], [4 x i16]* @"(anonymous namespace)::runtime.expected_task_source.row0", i64 0, i64 %idxprom.i.i
  store i16 %src0_row0.val, i16* %arrayidx3.69.i.i, align 2, !alias.scope !14290, !noalias !14295
  %arrayidx3.710.i.i = getelementptr [4 x i16], [4 x i16]* @"(anonymous namespace)::runtime.expected_task_source.rows", i64 0, i64 %idxprom.i.i
  store i16 %src0_rows.val, i16* %arrayidx3.710.i.i, align 4, !alias.scope !14290, !noalias !14295
  %arrayidx3.811.i.i = getelementptr [4 x i16], [4 x i16]* @"(anonymous namespace)::runtime.expected_task_source.width", i64 0, i64 %idxprom.i.i
  store i16 %src0_width.val, i16* %arrayidx3.811.i.i, align 2, !alias.scope !14290, !noalias !14295
  %arrayidx3.912.i.i = getelementptr [4 x i8], [4 x i8]* @"(anonymous namespace)::runtime.expected_task_source.content", i64 0, i64 %idxprom.i.i
  store i8 %src0_content.val, i8* %arrayidx3.912.i.i, align 8, !alias.scope !14290, !noalias !14295
  br label %if.end45

if.end45:                                         ; preds = %if.end.i.i, %if.then.i.i
  %ref.tmp40.069.0 = phi i16 [ 5, %if.then.i.i ], [ 0, %if.end.i.i ]
  %ref.tmp40.170.0 = phi i32 [ %or4.i.i.i.i, %if.then.i.i ], [ 0, %if.end.i.i ]
  %cmp.i50 = icmp eq i16 %ref.tmp40.069.0, 0
  br i1 %cmp.i50, label %if.then47, label %if.end53

if.then47:                                        ; preds = %if.end45
  %conv51 = zext i8 %conv21 to i32
  %mul = mul nuw nsw i32 %conv51, 1024
  call fastcc void @"laya::full::(anonymous namespace)::Controller::issue<laya::VectorTask>"(i16* %ref.tmp48.057, i32* %ref.tmp48.158, i64* %ref.tmp48.259, i8 addrspace(1)* %embedding, i64 %this_memory.0, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i64* %this_memory.5, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i64* %this_memory.7, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i64* %this_memory.9, i8 addrspace(1)* %aux, i64 %this_memory.10, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i32 %add.i, i8 98, i8 %stage, i8 %layer, i8 %conv12, i8 %src0_row_space.val, i16 %conv14, i8 %conv21, i8 %src0_ref_id.val, i8 %src0_ref_bank.val, i32 %src0_ref_epoch.val, i8 0, i8 0, i32 0, i8 1, i8 %dst_ref_bank, i32 %dst_ref_epoch, i16 1024, i8 %src0_region.val, i8 0, i8 0, i16 -1, i32 %mul)
  %.05 = load i16, i16* %ref.tmp48.057, align 512
  %.17 = load i32, i32* %ref.tmp48.158, align 512
  %.29 = load i64, i64* %ref.tmp48.259, align 512
  br label %if.end53

if.end53:                                         ; preds = %if.then47, %if.end45
  %.2963 = phi i64 [ %.29, %if.then47 ], [ -1, %if.end45 ]
  %.1761 = phi i32 [ %.17, %if.then47 ], [ %ref.tmp40.170.0, %if.end45 ]
  %9 = phi i16 [ %.05, %if.then47 ], [ %ref.tmp40.069.0, %if.end45 ]
  %cmp.i51 = icmp eq i16 %9, 0
  %cleanup.dest.slot.0 = select i1 %cmp.i51, i1 true, i1 false
  %add = add nuw nsw i32 %row.05, 16
  %cmp8 = icmp ult i32 %add, %conv
  %or.cond59 = and i1 %cleanup.dest.slot.0, %cmp8
  br i1 %or.cond59, label %for.body10, label %for.inc58.loopexit, !llvm.loop !14326

for.inc58.loopexit:                               ; preds = %if.end53
  store i16 %9, i16* %agg.result_code, align 512
  store i32 %.1761, i32* %agg.result_detail, align 512
  store i64 %.2963, i64* %agg.result_bad_element, align 512
  br label %for.inc58

for.inc58:                                        ; preds = %for.inc58.loopexit, %VITIS_LOOP_176_2
  %10 = phi i16 [ 0, %VITIS_LOOP_176_2 ], [ %9, %for.inc58.loopexit ]
  %inc = add nuw nsw i32 %b.0, 1
  br label %for.cond, !llvm.loop !14454

for.end60:                                        ; preds = %for.cond
  br i1 %cmp.i52, label %if.then62, label %if.end65

if.then62:                                        ; preds = %for.end60
  call fastcc void @"laya::full::full_publish_owner"(i16* %ref.tmp63.051, i32* %ref.tmp63.152, i64* %ref.tmp63.253, i8 1, i8 %dst_ref_bank, i32 %dst_ref_epoch, i8 0, i8 %stage, i8 %layer, i8 -1, i8 %src0_row_space.val, i16 0, i16 %cond7.i, i16 1024, i8 1)
  %.0 = load i16, i16* %ref.tmp63.051, align 512
  %.1 = load i32, i32* %ref.tmp63.152, align 512
  %.2 = load i64, i64* %ref.tmp63.253, align 512
  store i16 %.0, i16* %agg.result_code, align 512
  store i32 %.1, i32* %agg.result_detail, align 512
  store i64 %.2, i64* %agg.result_bad_element, align 512
  br label %if.end65

if.end65:                                         ; preds = %if.then62, %for.end60
  br label %return

return:                                           ; preds = %if.end65, %entry
  ret void
}
