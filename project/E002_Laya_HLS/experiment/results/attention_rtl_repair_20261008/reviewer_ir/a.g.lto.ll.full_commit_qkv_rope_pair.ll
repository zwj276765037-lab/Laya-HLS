define internal fastcc void @"laya::full::full_commit_qkv_rope_pair"(i16* noalias nocapture align 512 %agg.result.0, i32* noalias nocapture align 512 %agg.result.1, i64* noalias nocapture align 512 %agg.result.2, i8 %next_s_ref_id.0.0.val, i8 %next_s_ref_id.0.1.val, i8 %next_s_ref_bank.0.0.val, i8 %next_s_ref_bank.0.1.val, i32 %next_s_ref_epoch.0.0.val, i32 %next_s_ref_epoch.0.1.val, i8 %next_s_region.0.0.val, i8 %next_s_region.0.1.val, i8 %next_s_stage.0.0.val, i8 %next_s_stage.0.1.val, i8 %next_s_layer.0.0.val, i8 %next_s_layer.0.1.val, i8 %next_s_batch.0.0.val, i8 %next_s_batch.0.1.val, i8 %next_s_row_space.0.0.val, i8 %next_s_row_space.0.1.val, i16 %next_s_row0.0.0.val, i16 %next_s_row0.0.1.val, i16 %next_s_rows.0.0.val, i16 %next_s_rows.0.1.val, i16 %next_s_width.0.0.val, i16 %next_s_width.0.1.val, i8 %next_s_content.0.0.val, i8 %next_s_content.0.1.val) unnamed_addr #0 {
entry:
  %0 = load i1, i1* @"(anonymous namespace)::runtime.request_valid", align 512
  br i1 %0, label %lor.lhs.false, label %if.then

lor.lhs.false:                                    ; preds = %entry
  %1 = load i1, i1* @"(anonymous namespace)::runtime.model_header_valid", align 512
  %cmp = icmp ne i8 %next_s_ref_id.0.0.val, 5
  %cmp6 = icmp ne i8 %next_s_ref_id.0.1.val, 5
  %cmp10 = icmp ne i8 %next_s_ref_bank.0.0.val, 0
  %cmp16 = icmp ne i8 %next_s_ref_bank.0.1.val, 1
  %cmp19 = icmp ne i8 %next_s_content.0.0.val, 3
  %cmp23 = icmp ne i8 %next_s_content.0.1.val, 3
  %thr.or = or i1 %cmp6, %cmp
  %thr.or9 = or i1 %cmp16, %cmp10
  %thr.or10 = or i1 %cmp23, %cmp19
  %thr.xor = xor i1 %1, true
  %thr.or11 = or i1 %thr.or, %thr.or9
  %thr.or12 = or i1 %thr.or10, %thr.xor
  %thr.or13 = or i1 %thr.or11, %thr.or12
  br i1 %thr.or13, label %if.then, label %if.end

if.then:                                          ; preds = %lor.lhs.false, %entry
  store i16 5, i16* %agg.result.0, align 512, !alias.scope !95, !noalias !98
  store i32 67436549, i32* %agg.result.1, align 512, !alias.scope !101, !noalias !102
  store i64 -1, i64* %agg.result.2, align 512, !alias.scope !103, !noalias !104
  br label %return

if.end:                                           ; preds = %lor.lhs.false
  br label %for.body.i

for.cond.i:                                       ; preds = %if.end12.i.i, %land.lhs.true.i, %for.body.i.split
  br label %for.body.i, !llvm.loop !105

for.body.i:                                       ; preds = %for.cond.i, %if.end
  %indvars.iv.i = phi i64 [ 0, %if.end ], [ %indvars.iv.next.i, %for.cond.i ]
  %cmp.i5 = icmp ult i64 %indvars.iv.i, 32
  br i1 %cmp.i5, label %for.body.i.split, label %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit.loopexit, !llvm.loop !105

for.body.i.split:                                 ; preds = %for.body.i
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 0, i64 32, i64 16), !fpga.pragma.source !33
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @42)
  %id4.i = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.ref.id", i64 0, i64 %indvars.iv.i
  %2 = load i8, i8* %id4.i, align 8, !alias.scope !439, !noalias !442
  %cmp2.i = icmp ne i8 %2, 0
  %indvars.iv.next.i = add nuw nsw i64 %indvars.iv.i, 1
  br i1 %cmp2.i, label %land.lhs.true.i, label %for.cond.i

land.lhs.true.i:                                  ; preds = %for.body.i.split
  %ref35.12.i = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.ref.bank", i64 0, i64 %indvars.iv.i
  %.18.i = load i8, i8* %ref35.12.i, align 1, !alias.scope !439, !noalias !442
  %region46.i = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.region", i64 0, i64 %indvars.iv.i
  %3 = load i8, i8* %region46.i, align 4, !alias.scope !439, !noalias !442
  %4 = or i8 %3, %.18.i
  %5 = icmp ne i8 %4, 0
  br i1 %5, label %for.cond.i, label %if.end12.i.i

if.end12.i.i:                                     ; preds = %land.lhs.true.i
  %cmp15.i.i = icmp eq i8 %2, 5
  %spec.select = select i1 %cmp15.i.i, i1 true, i1 false
  br i1 %spec.select, label %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit.split.loop.exit, label %for.cond.i

_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit.split.loop.exit: ; preds = %if.end12.i.i
  %6 = trunc i64 %indvars.iv.i to i32
  br label %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit

_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit.loopexit: ; preds = %for.body.i
  br label %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit

_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit: ; preds = %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit.loopexit, %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit.split.loop.exit
  %retval.1.i117 = phi i32 [ %6, %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit.split.loop.exit ], [ undef, %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit.loopexit ]
  %cleanup.dest.slot.1.i = phi i32 [ 1, %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit.split.loop.exit ], [ 3, %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit.loopexit ]
  %cleanup.dest.slot.1.off.i = add nsw i32 %cleanup.dest.slot.1.i, -3
  %switch.i = icmp ult i32 %cleanup.dest.slot.1.off.i, 1
  %spec.select.i = select i1 %switch.i, i32 32, i32 %retval.1.i117
  br label %for.body.i44

for.cond.i39:                                     ; preds = %if.end12.i.i62, %land.lhs.true.i54, %for.body.i44.split
  br label %for.body.i44, !llvm.loop !446

for.body.i44:                                     ; preds = %for.cond.i39, %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit
  %indvars.iv.i40 = phi i64 [ 0, %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit ], [ %indvars.iv.next.i76, %for.cond.i39 ]
  %cmp.i386 = icmp ult i64 %indvars.iv.i40, 32
  br i1 %cmp.i386, label %for.body.i44.split, label %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit82.loopexit, !llvm.loop !446

for.body.i44.split:                               ; preds = %for.body.i44
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 0, i64 32, i64 16), !fpga.pragma.source !33
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @42)
  %id4.i42 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.ref.id", i64 0, i64 %indvars.iv.i40
  %7 = load i8, i8* %id4.i42, align 8, !alias.scope !450, !noalias !453
  %cmp2.i43 = icmp ne i8 %7, 0
  %indvars.iv.next.i76 = add nuw nsw i64 %indvars.iv.i40, 1
  br i1 %cmp2.i43, label %land.lhs.true.i54, label %for.cond.i39

land.lhs.true.i54:                                ; preds = %for.body.i44.split
  %ref35.12.i45 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.ref.bank", i64 0, i64 %indvars.iv.i40
  %.18.i46 = load i8, i8* %ref35.12.i45, align 1, !alias.scope !450, !noalias !453
  %region46.i49 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.region", i64 0, i64 %indvars.iv.i40
  %8 = load i8, i8* %region46.i49, align 4, !alias.scope !450, !noalias !453
  %cmp.i.i53 = icmp ne i8 %8, 0
  %cmp10.i.i59 = icmp ne i8 %.18.i46, 1
  %or.cond114 = or i1 %cmp.i.i53, %cmp10.i.i59
  br i1 %or.cond114, label %for.cond.i39, label %if.end12.i.i62

if.end12.i.i62:                                   ; preds = %land.lhs.true.i54
  %cmp15.i.i61 = icmp eq i8 %7, 5
  %spec.select115 = select i1 %cmp15.i.i61, i1 true, i1 false
  br i1 %spec.select115, label %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit82.split.loop.exit, label %for.cond.i39

_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit82.split.loop.exit: ; preds = %if.end12.i.i62
  %9 = trunc i64 %indvars.iv.i40 to i32
  br label %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit82

_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit82.loopexit: ; preds = %for.body.i44
  br label %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit82

_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit82: ; preds = %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit82.loopexit, %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit82.split.loop.exit
  %retval.1.i75119 = phi i32 [ %9, %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit82.split.loop.exit ], [ undef, %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit82.loopexit ]
  %cleanup.dest.slot.1.i78 = phi i32 [ 1, %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit82.split.loop.exit ], [ 3, %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit82.loopexit ]
  %cleanup.dest.slot.1.off.i79 = add nsw i32 %cleanup.dest.slot.1.i78, -3
  %switch.i80 = icmp ult i32 %cleanup.dest.slot.1.off.i79, 1
  %spec.select.i81 = select i1 %switch.i80, i32 32, i32 %retval.1.i75119
  %cmp30 = icmp eq i32 %spec.select.i, 32
  %cmp32 = icmp eq i32 %spec.select.i81, 32
  %or.cond = or i1 %cmp30, %cmp32
  br i1 %or.cond, label %if.then33, label %if.end34

if.then33:                                        ; preds = %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit82
  store i16 5, i16* %agg.result.0, align 512, !alias.scope !457, !noalias !460
  store i32 67436553, i32* %agg.result.1, align 512, !alias.scope !463, !noalias !464
  store i64 -1, i64* %agg.result.2, align 512, !alias.scope !465, !noalias !466
  br label %cleanup148

if.end34:                                         ; preds = %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit82
  %idxprom = zext i32 %spec.select.i to i64
  %arrayidx3514.0.0 = getelementptr [32 x i64], [32 x i64]* @"(anonymous namespace)::runtime.owners.record.identity.request_id", i64 0, i64 %idxprom
  %arrayidx3514.0.1 = getelementptr [32 x i64], [32 x i64]* @"(anonymous namespace)::runtime.owners.record.identity.generation", i64 0, i64 %idxprom
  %arrayidx3514.0.2 = getelementptr [32 x i16], [32 x i16]* @"(anonymous namespace)::runtime.owners.record.identity.B", i64 0, i64 %idxprom
  %arrayidx3514.0.3 = getelementptr [32 x i16], [32 x i16]* @"(anonymous namespace)::runtime.owners.record.identity.S", i64 0, i64 %idxprom
  %arrayidx3514.0.4 = getelementptr [32 x [16 x i8]], [32 x [16 x i8]]* @"(anonymous namespace)::runtime.owners.record.identity.model_tag", i64 0, i64 %idxprom
  %arrayidx3514.0.5 = getelementptr [32 x [16 x i8]], [32 x [16 x i8]]* @"(anonymous namespace)::runtime.owners.record.identity.numeric_tag", i64 0, i64 %idxprom
  %arrayidx3514.0.6 = getelementptr [32 x [16 x i8]], [32 x [16 x i8]]* @"(anonymous namespace)::runtime.owners.record.identity.layout_tag", i64 0, i64 %idxprom
  %arrayidx3514.0.7 = getelementptr [32 x [16 x i8]], [32 x [16 x i8]]* @"(anonymous namespace)::runtime.owners.record.identity.build_tag", i64 0, i64 %idxprom
  %arrayidx3514.1.0 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.ref.id", i64 0, i64 %idxprom
  %arrayidx3514.1.1 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.ref.bank", i64 0, i64 %idxprom
  %arrayidx3514.1.2 = getelementptr [32 x i32], [32 x i32]* @"(anonymous namespace)::runtime.owners.record.ref.epoch", i64 0, i64 %idxprom
  %arrayidx3514.2.0 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.lease_old_ref.id", i64 0, i64 %idxprom
  %arrayidx3514.2.1 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.lease_old_ref.bank", i64 0, i64 %idxprom
  %arrayidx3514.2.2 = getelementptr [32 x i32], [32 x i32]* @"(anonymous namespace)::runtime.owners.record.lease_old_ref.epoch", i64 0, i64 %idxprom
  %arrayidx3514.4 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.region", i64 0, i64 %idxprom
  %arrayidx3514.5 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.stage", i64 0, i64 %idxprom
  %arrayidx3514.6 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.layer", i64 0, i64 %idxprom
  %arrayidx3514.7 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.batch", i64 0, i64 %idxprom
  %arrayidx3514.8 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.row_space", i64 0, i64 %idxprom
  %arrayidx3514.9 = getelementptr [32 x i16], [32 x i16]* @"(anonymous namespace)::runtime.owners.record.row0", i64 0, i64 %idxprom
  %arrayidx3514.10 = getelementptr [32 x i16], [32 x i16]* @"(anonymous namespace)::runtime.owners.record.rows", i64 0, i64 %idxprom
  %arrayidx3514.11 = getelementptr [32 x i16], [32 x i16]* @"(anonymous namespace)::runtime.owners.record.width", i64 0, i64 %idxprom
  %arrayidx3514.12 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.content", i64 0, i64 %idxprom
  %arrayidx3514.13 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.state", i64 0, i64 %idxprom
  %arrayidx3514.17 = getelementptr [32 x i1], [32 x i1]* @"(anonymous namespace)::runtime.owners.record.valid", i64 0, i64 %idxprom
  %idxprom38 = zext i32 %spec.select.i81 to i64
  %arrayidx3916.0.0 = getelementptr [32 x i64], [32 x i64]* @"(anonymous namespace)::runtime.owners.record.identity.request_id", i64 0, i64 %idxprom38
  %arrayidx3916.0.1 = getelementptr [32 x i64], [32 x i64]* @"(anonymous namespace)::runtime.owners.record.identity.generation", i64 0, i64 %idxprom38
  %arrayidx3916.0.2 = getelementptr [32 x i16], [32 x i16]* @"(anonymous namespace)::runtime.owners.record.identity.B", i64 0, i64 %idxprom38
  %arrayidx3916.0.3 = getelementptr [32 x i16], [32 x i16]* @"(anonymous namespace)::runtime.owners.record.identity.S", i64 0, i64 %idxprom38
  %arrayidx3916.0.4 = getelementptr [32 x [16 x i8]], [32 x [16 x i8]]* @"(anonymous namespace)::runtime.owners.record.identity.model_tag", i64 0, i64 %idxprom38
  %arrayidx3916.0.5 = getelementptr [32 x [16 x i8]], [32 x [16 x i8]]* @"(anonymous namespace)::runtime.owners.record.identity.numeric_tag", i64 0, i64 %idxprom38
  %arrayidx3916.0.6 = getelementptr [32 x [16 x i8]], [32 x [16 x i8]]* @"(anonymous namespace)::runtime.owners.record.identity.layout_tag", i64 0, i64 %idxprom38
  %arrayidx3916.0.7 = getelementptr [32 x [16 x i8]], [32 x [16 x i8]]* @"(anonymous namespace)::runtime.owners.record.identity.build_tag", i64 0, i64 %idxprom38
  %arrayidx3916.1.0 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.ref.id", i64 0, i64 %idxprom38
  %arrayidx3916.1.1 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.ref.bank", i64 0, i64 %idxprom38
  %arrayidx3916.1.2 = getelementptr [32 x i32], [32 x i32]* @"(anonymous namespace)::runtime.owners.record.ref.epoch", i64 0, i64 %idxprom38
  %arrayidx3916.2.0 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.lease_old_ref.id", i64 0, i64 %idxprom38
  %arrayidx3916.2.1 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.lease_old_ref.bank", i64 0, i64 %idxprom38
  %arrayidx3916.2.2 = getelementptr [32 x i32], [32 x i32]* @"(anonymous namespace)::runtime.owners.record.lease_old_ref.epoch", i64 0, i64 %idxprom38
  %arrayidx3916.4 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.region", i64 0, i64 %idxprom38
  %arrayidx3916.5 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.stage", i64 0, i64 %idxprom38
  %arrayidx3916.6 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.layer", i64 0, i64 %idxprom38
  %arrayidx3916.7 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.batch", i64 0, i64 %idxprom38
  %arrayidx3916.8 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.row_space", i64 0, i64 %idxprom38
  %arrayidx3916.9 = getelementptr [32 x i16], [32 x i16]* @"(anonymous namespace)::runtime.owners.record.row0", i64 0, i64 %idxprom38
  %arrayidx3916.10 = getelementptr [32 x i16], [32 x i16]* @"(anonymous namespace)::runtime.owners.record.rows", i64 0, i64 %idxprom38
  %arrayidx3916.11 = getelementptr [32 x i16], [32 x i16]* @"(anonymous namespace)::runtime.owners.record.width", i64 0, i64 %idxprom38
  %arrayidx3916.12 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.content", i64 0, i64 %idxprom38
  %arrayidx3916.13 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.state", i64 0, i64 %idxprom38
  %arrayidx3916.17 = getelementptr [32 x i1], [32 x i1]* @"(anonymous namespace)::runtime.owners.record.valid", i64 0, i64 %idxprom38
  %10 = call fastcc i1 @"laya::full::(anonymous namespace)::same_spec"(i8* %arrayidx3514.1.0, i8* %arrayidx3514.1.1, i32* %arrayidx3514.1.2, i8* %arrayidx3514.4, i8* %arrayidx3514.5, i8* %arrayidx3514.6, i8* %arrayidx3514.7, i8* %arrayidx3514.8, i16* %arrayidx3514.9, i16* %arrayidx3514.10, i16* %arrayidx3514.11, i8* %arrayidx3514.12, i8 5, i8 0, i32 %next_s_ref_epoch.0.0.val, i8 %next_s_region.0.0.val, i8 %next_s_stage.0.0.val, i8 %next_s_layer.0.0.val, i8 %next_s_batch.0.0.val, i8 %next_s_row_space.0.0.val, i16 %next_s_row0.0.0.val, i16 %next_s_rows.0.0.val, i16 %next_s_width.0.0.val, i8 3)
  br i1 %10, label %lor.lhs.false42, label %if.then65

lor.lhs.false42:                                  ; preds = %if.end34
  %11 = call fastcc i1 @"laya::full::(anonymous namespace)::same_spec"(i8* %arrayidx3916.1.0, i8* %arrayidx3916.1.1, i32* %arrayidx3916.1.2, i8* %arrayidx3916.4, i8* %arrayidx3916.5, i8* %arrayidx3916.6, i8* %arrayidx3916.7, i8* %arrayidx3916.8, i16* %arrayidx3916.9, i16* %arrayidx3916.10, i16* %arrayidx3916.11, i8* %arrayidx3916.12, i8 5, i8 1, i32 %next_s_ref_epoch.0.1.val, i8 %next_s_region.0.1.val, i8 %next_s_stage.0.1.val, i8 %next_s_layer.0.1.val, i8 %next_s_batch.0.1.val, i8 %next_s_row_space.0.1.val, i16 %next_s_row0.0.1.val, i16 %next_s_rows.0.1.val, i16 %next_s_width.0.1.val, i8 3)
  br i1 %11, label %lor.lhs.false45, label %if.then65

lor.lhs.false45:                                  ; preds = %lor.lhs.false42
  %12 = load i8, i8* %arrayidx3514.13, align 1
  %cmp46 = icmp ne i8 %12, 4
  br i1 %cmp46, label %if.then65, label %lor.lhs.false47

lor.lhs.false47:                                  ; preds = %lor.lhs.false45
  %13 = load i8, i8* %arrayidx3916.13, align 1
  %cmp49 = icmp ne i8 %13, 4
  br i1 %cmp49, label %if.then65, label %lor.lhs.false50

lor.lhs.false50:                                  ; preds = %lor.lhs.false47
  %14 = load i8, i8* %arrayidx3514.2.0, align 32
  %cmp52 = icmp ne i8 %14, 5
  br i1 %cmp52, label %if.then65, label %lor.lhs.false53

lor.lhs.false53:                                  ; preds = %lor.lhs.false50
  %15 = load i8, i8* %arrayidx3916.2.0, align 32
  %cmp56 = icmp ne i8 %15, 5
  br i1 %cmp56, label %if.then65, label %lor.lhs.false57

lor.lhs.false57:                                  ; preds = %lor.lhs.false53
  %16 = call fastcc i1 @"laya::numeric_identity_equal"(i64* %arrayidx3514.0.0, i64* %arrayidx3514.0.1, i16* %arrayidx3514.0.2, i16* %arrayidx3514.0.3, [16 x i8]* %arrayidx3514.0.4, [16 x i8]* %arrayidx3514.0.5, [16 x i8]* %arrayidx3514.0.6, [16 x i8]* %arrayidx3514.0.7)
  br i1 %16, label %lor.lhs.false60, label %if.then65

lor.lhs.false60:                                  ; preds = %lor.lhs.false57
  %17 = call fastcc i1 @"laya::numeric_identity_equal"(i64* %arrayidx3916.0.0, i64* %arrayidx3916.0.1, i16* %arrayidx3916.0.2, i16* %arrayidx3916.0.3, [16 x i8]* %arrayidx3916.0.4, [16 x i8]* %arrayidx3916.0.5, [16 x i8]* %arrayidx3916.0.6, [16 x i8]* %arrayidx3916.0.7)
  br i1 %17, label %VITIS_LOOP_450_1, label %if.then65

if.then65:                                        ; preds = %lor.lhs.false60, %lor.lhs.false57, %lor.lhs.false53, %lor.lhs.false50, %lor.lhs.false47, %lor.lhs.false45, %lor.lhs.false42, %if.end34
  store i16 5, i16* %agg.result.0, align 512, !alias.scope !467, !noalias !470
  store i32 67436553, i32* %agg.result.1, align 512, !alias.scope !473, !noalias !474
  store i64 -1, i64* %agg.result.2, align 512, !alias.scope !475, !noalias !476
  br label %cleanup146

VITIS_LOOP_450_1:                                 ; preds = %lor.lhs.false60
  %18 = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.B", align 512
  %conv75 = zext i16 %18 to i32
  %19 = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.S", align 512
  %cmp7629 = icmp ne i16 %18, 0
  %20 = zext i32 %conv75 to i64
  %cmp1.i = icmp ugt i16 %19, 0
  %21 = zext i16 %19 to i32
  br label %VITIS_LOOP_451_2

for.cond:                                         ; preds = %VITIS_LOOP_452_3
  br label %VITIS_LOOP_451_2, !llvm.loop !477

VITIS_LOOP_451_2:                                 ; preds = %for.cond, %VITIS_LOOP_450_1
  %indvars.iv36 = phi i64 [ 0, %VITIS_LOOP_450_1 ], [ %indvars.iv.next37, %for.cond ]
  %cmp6710 = icmp ult i64 %indvars.iv36, 2
  br i1 %cmp6710, label %VITIS_LOOP_451_2.split, label %VITIS_LOOP_456_5.lr.ph, !llvm.loop !477

VITIS_LOOP_451_2.split:                           ; preds = %VITIS_LOOP_451_2
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 0, i64 2, i64 1), !fpga.pragma.source !33
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @41)
  %indvars.iv.next37 = add nuw nsw i64 %indvars.iv36, 1
  br label %VITIS_LOOP_452_3

for.cond68.loopexit:                              ; preds = %for.body78
  br label %for.cond68

for.cond68:                                       ; preds = %VITIS_LOOP_452_3.split, %for.cond68.loopexit
  br label %VITIS_LOOP_452_3, !llvm.loop !483

VITIS_LOOP_452_3:                                 ; preds = %for.cond68, %VITIS_LOOP_451_2.split
  %indvars.iv34 = phi i64 [ 0, %VITIS_LOOP_451_2.split ], [ %indvars.iv.next35, %for.cond68 ]
  %cmp699 = icmp ult i64 %indvars.iv34, 16
  br i1 %cmp699, label %VITIS_LOOP_452_3.split, label %for.cond, !llvm.loop !483

VITIS_LOOP_452_3.split:                           ; preds = %VITIS_LOOP_452_3
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 0, i64 16, i64 8), !fpga.pragma.source !33
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @40)
  %22 = trunc i64 %indvars.iv34 to i32
  %rem = urem i32 %22, 2
  %idxprom80 = zext i32 %rem to i64
  %indvars.iv.next35 = add nuw nsw i64 %indvars.iv34, 1
  br i1 %cmp7629, label %for.body78.lr.ph, label %for.cond68

for.body78.lr.ph:                                 ; preds = %VITIS_LOOP_452_3.split
  br label %for.body78

for.cond72.loopexit:                              ; preds = %for.body.i87
  br label %for.cond72

for.cond72:                                       ; preds = %for.body78.split, %for.cond72.loopexit
  br label %for.body78, !llvm.loop !491

for.body78:                                       ; preds = %for.cond72, %for.body78.lr.ph
  %indvars.iv = phi i64 [ 0, %for.body78.lr.ph ], [ %indvars.iv.next, %for.cond72 ]
  %cmp768 = icmp ult i64 %indvars.iv, %20
  br i1 %cmp768, label %for.body78.split, label %for.cond68.loopexit, !llvm.loop !491

for.body78.split:                                 ; preds = %for.body78
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 0, i64 65535, i64 32767), !fpga.pragma.source !33
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @39)
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  br i1 %cmp1.i, label %for.body.lr.ph.i, label %for.cond72

for.body.lr.ph.i:                                 ; preds = %for.body78.split
  br label %for.body.i87

for.cond.i84:                                     ; preds = %for.body.i87.split
  br label %for.body.i87, !llvm.loop !498

for.body.i87:                                     ; preds = %for.cond.i84, %for.body.lr.ph.i
  %indvars.iv.i85 = phi i32 [ 0, %for.body.lr.ph.i ], [ %indvars.iv.next.i86, %for.cond.i84 ]
  %cmp.i837 = icmp ult i32 %indvars.iv.i85, %21
  br i1 %cmp.i837, label %for.body.i87.split, label %for.cond72.loopexit, !llvm.loop !498

for.body.i87.split:                               ; preds = %for.body.i87
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 0, i64 65535, i64 32767), !fpga.pragma.source !33
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @38)
  %div.i = udiv i32 %indvars.iv.i85, 32
  %idxprom.i = sext i32 %div.i to i64
  %arrayidx.i112 = getelementptr [2 x [2 x [16 x [2 x [32 x i32]]]]], [2 x [2 x [16 x [2 x [32 x i32]]]]]* @"(anonymous namespace)::runtime.owners.qkv_rope_rows", i64 0, i64 %idxprom80, i64 %indvars.iv36, i64 %indvars.iv34, i64 %indvars.iv, i64 %idxprom.i
  %23 = load i32, i32* %arrayidx.i112, align 4, !alias.scope !512
  %rem.i = urem i32 %indvars.iv.i85, 32
  %shl.i = shl nuw i32 1, %rem.i
  %and.i = and i32 %23, %shl.i
  %tobool.i = icmp ne i32 %and.i, 0
  %indvars.iv.next.i86 = add nuw nsw i32 %indvars.iv.i85, 1
  br i1 %tobool.i, label %for.cond.i84, label %cleanup100

cleanup100:                                       ; preds = %for.body.i87.split
  store i16 5, i16* %agg.result.0, align 512, !alias.scope !515, !noalias !518
  store i32 67436553, i32* %agg.result.1, align 512, !alias.scope !521, !noalias !522
  store i64 -1, i64* %agg.result.2, align 512, !alias.scope !523, !noalias !524
  br label %cleanup146

VITIS_LOOP_456_5.lr.ph:                           ; preds = %VITIS_LOOP_451_2
  br label %VITIS_LOOP_456_5

VITIS_LOOP_456_5:                                 ; preds = %for.inc129, %VITIS_LOOP_456_5.lr.ph
  %batch103.028 = phi i32 [ 0, %VITIS_LOOP_456_5.lr.ph ], [ %inc130, %for.inc129 ]
  %exitcond3312 = icmp ne i32 %batch103.028, %conv75
  br i1 %exitcond3312, label %for.inc125.lr.ph, label %for.end132, !llvm.loop !525

for.inc125.lr.ph:                                 ; preds = %VITIS_LOOP_456_5
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 0, i64 65535, i64 32767), !fpga.pragma.source !33
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @37)
  %mul.udiv105 = mul nuw nsw i32 %batch103.028, 32
  br label %for.inc125

for.inc125:                                       ; preds = %for.inc125.split, %for.inc125.lr.ph
  %row.026 = phi i32 [ 0, %for.inc125.lr.ph ], [ %inc126, %for.inc125.split ]
  %exitcond11 = icmp ne i32 %row.026, %21
  br i1 %exitcond11, label %for.inc125.split, label %for.inc129, !llvm.loop !530

for.inc125.split:                                 ; preds = %for.inc125
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 0, i64 65535, i64 32767), !fpga.pragma.source !33
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @36)
  %rem.i92103 = urem i32 %row.026, 32
  %shl.i93 = shl nuw i32 1, %rem.i92103
  %row.026.udiv = udiv i32 %row.026, 32
  %div.i94104 = add nuw i32 %mul.udiv105, %row.026.udiv
  %idxprom.i95 = zext i32 %div.i94104 to i64
  %arrayidx.i96106 = getelementptr [32 x [64 x i32]], [32 x [64 x i32]]* @"(anonymous namespace)::runtime.owners.record.covered_rows", i64 0, i64 %idxprom, i64 %idxprom.i95
  %24 = load i32, i32* %arrayidx.i96106, align 4, !alias.scope !537
  %or.i = or i32 %24, %shl.i93
  store i32 %or.i, i32* %arrayidx.i96106, align 4, !alias.scope !537
  %arrayidx.i101111 = getelementptr [32 x [64 x i32]], [32 x [64 x i32]]* @"(anonymous namespace)::runtime.owners.record.covered_rows", i64 0, i64 %idxprom38, i64 %idxprom.i95
  %25 = load i32, i32* %arrayidx.i101111, align 4, !alias.scope !540
  %or.i102 = or i32 %25, %shl.i93
  store i32 %or.i102, i32* %arrayidx.i101111, align 4, !alias.scope !540
  %inc126 = add nuw nsw i32 %row.026, 1
  br label %for.inc125, !llvm.loop !530

for.inc129:                                       ; preds = %for.inc125
  %inc130 = add nuw nsw i32 %batch103.028, 1
  br label %VITIS_LOOP_456_5, !llvm.loop !525

for.end132:                                       ; preds = %VITIS_LOOP_456_5
  store i8 2, i8* %arrayidx3514.13, align 1
  store i1 true, i1* %arrayidx3514.17, align 4
  store i8 0, i8* %arrayidx3514.2.0, align 32
  store i8 0, i8* %arrayidx3514.2.1, align 1
  store i32 0, i32* %arrayidx3514.2.2, align 4
  store i8 2, i8* %arrayidx3916.13, align 1
  store i1 true, i1* %arrayidx3916.17, align 4
  store i8 0, i8* %arrayidx3916.2.0, align 32
  store i8 0, i8* %arrayidx3916.2.1, align 1
  store i32 0, i32* %arrayidx3916.2.2, align 4
  store i8 5, i8* getelementptr inbounds ([2 x i8], [2 x i8]* @"(anonymous namespace)::runtime.final_qkv_ref.id", i64 0, i64 0), align 512
  store i8 0, i8* getelementptr inbounds ([2 x i8], [2 x i8]* @"(anonymous namespace)::runtime.final_qkv_ref.bank", i64 0, i64 0), align 512
  store i32 %next_s_ref_epoch.0.0.val, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"(anonymous namespace)::runtime.final_qkv_ref.epoch", i64 0, i64 0), align 512
  store i8 5, i8* getelementptr inbounds ([2 x i8], [2 x i8]* @"(anonymous namespace)::runtime.final_qkv_ref.id", i64 0, i64 1), align 8
  store i8 1, i8* getelementptr inbounds ([2 x i8], [2 x i8]* @"(anonymous namespace)::runtime.final_qkv_ref.bank", i64 0, i64 1), align 1
  store i32 %next_s_ref_epoch.0.1.val, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"(anonymous namespace)::runtime.final_qkv_ref.epoch", i64 0, i64 1), align 4
  store i16 0, i16* %agg.result.0, align 512, !alias.scope !543, !noalias !546
  store i32 0, i32* %agg.result.1, align 512, !alias.scope !549, !noalias !550
  store i64 -1, i64* %agg.result.2, align 512, !alias.scope !551, !noalias !552
  br label %cleanup146

cleanup146:                                       ; preds = %for.end132, %cleanup100, %if.then65
  br label %cleanup148

cleanup148:                                       ; preds = %cleanup146, %if.then33
  br label %return

return:                                           ; preds = %cleanup148, %if.then
  ret void
}
