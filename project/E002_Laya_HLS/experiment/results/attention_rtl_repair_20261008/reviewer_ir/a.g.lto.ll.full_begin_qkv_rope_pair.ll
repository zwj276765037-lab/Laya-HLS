define internal fastcc void @"laya::full::full_begin_qkv_rope_pair"(i16* noalias nocapture align 512 %agg.result.0, i32* noalias nocapture align 512 %agg.result.1, i64* noalias nocapture align 512 %agg.result.2, i8 %old_s_ref_id.0.0.val, i8 %old_s_ref_id.0.1.val, i8 %old_s_ref_bank.0.0.val, i8 %old_s_ref_bank.0.1.val, [2 x i32]* noalias nocapture align 512 %old_s_ref_epoch, [2 x i8]* noalias nocapture align 512 %old_s_region, [2 x i8]* noalias nocapture align 512 %old_s_stage, [2 x i8]* noalias nocapture align 512 %old_s_layer, [2 x i8]* noalias nocapture align 512 %old_s_batch, [2 x i8]* noalias nocapture align 512 %old_s_row_space, [2 x i16]* noalias nocapture align 512 %old_s_row0, [2 x i16]* noalias nocapture align 512 %old_s_rows, [2 x i16]* noalias nocapture align 512 %old_s_width, i8 %old_s_content.0.0.val, i8 %old_s_content.0.1.val, [2 x i8]* noalias nocapture align 512 %next_s_ref_id, [2 x i8]* noalias nocapture align 512 %next_s_ref_bank, [2 x i32]* noalias nocapture align 512 %next_s_ref_epoch, [2 x i8]* noalias nocapture align 512 %next_s_region, [2 x i8]* noalias nocapture align 512 %next_s_stage, [2 x i8]* noalias nocapture align 512 %next_s_layer, [2 x i8]* noalias nocapture align 512 %next_s_batch, [2 x i8]* noalias nocapture align 512 %next_s_row_space, [2 x i16]* noalias nocapture align 512 %next_s_row0, [2 x i16]* noalias nocapture align 512 %next_s_rows, [2 x i16]* noalias nocapture align 512 %next_s_width, [2 x i8]* noalias nocapture align 512 %next_s_content) unnamed_addr #0 {
entry:
  %0 = load i1, i1* @"(anonymous namespace)::runtime.request_valid", align 512
  br i1 %0, label %lor.lhs.false, label %if.then

lor.lhs.false:                                    ; preds = %entry
  %1 = load i1, i1* @"(anonymous namespace)::runtime.model_header_valid", align 512
  br i1 %1, label %lor.lhs.false1, label %if.then

lor.lhs.false1:                                   ; preds = %lor.lhs.false
  %2 = call fastcc i1 @"laya::full::(anonymous namespace)::qkv_rope_specs"(i8 %old_s_ref_id.0.0.val, i8 %old_s_ref_id.0.1.val, i8 %old_s_ref_bank.0.0.val, i8 %old_s_ref_bank.0.1.val, [2 x i32]* %old_s_ref_epoch, [2 x i8]* %old_s_region, [2 x i8]* %old_s_stage, [2 x i8]* %old_s_layer, [2 x i8]* %old_s_batch, [2 x i8]* %old_s_row_space, [2 x i16]* %old_s_row0, [2 x i16]* %old_s_rows, [2 x i16]* %old_s_width, i8 %old_s_content.0.0.val, i8 %old_s_content.0.1.val, [2 x i8]* %next_s_ref_id, [2 x i8]* %next_s_ref_bank, [2 x i32]* %next_s_ref_epoch, [2 x i8]* %next_s_region, [2 x i8]* %next_s_stage, [2 x i8]* %next_s_layer, [2 x i8]* %next_s_batch, [2 x i8]* %next_s_row_space, [2 x i16]* %next_s_row0, [2 x i16]* %next_s_rows, [2 x i16]* %next_s_width, [2 x i8]* %next_s_content)
  br i1 %2, label %if.end, label %if.then

if.then:                                          ; preds = %lor.lhs.false1, %lor.lhs.false, %entry
  br label %return

if.end:                                           ; preds = %lor.lhs.false1
  %ref1.212 = getelementptr [2 x i32], [2 x i32]* %old_s_ref_epoch, i64 0, i64 0
  %.273 = load i32, i32* %ref1.212, align 512
  %cmp4.i.i = icmp eq i8 %old_s_ref_id.0.0.val, 43
  %cmp22.i.i = icmp eq i8 %old_s_ref_id.0.0.val, 9
  %cmp26.i.i = icmp eq i8 %old_s_ref_id.0.0.val, 6
  br label %for.body.i

for.cond.i:                                       ; preds = %_ZN4laya4full12_GLOBAL__N_113same_physicalENS_9BufferRefEhS2_h.exit.i, %lor.rhs.i.i, %for.body.i.split
  br label %for.body.i, !llvm.loop !4051

for.body.i:                                       ; preds = %for.cond.i, %if.end
  %indvars.iv.i = phi i64 [ 0, %if.end ], [ %indvars.iv.next.i, %for.cond.i ]
  %cmp.i11 = icmp ult i64 %indvars.iv.i, 32
  br i1 %cmp.i11, label %for.body.i.split, label %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit.loopexit, !llvm.loop !4051

for.body.i.split:                                 ; preds = %for.body.i
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 0, i64 32, i64 16), !fpga.pragma.source !33
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @42)
  %id4.i = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.ref.id", i64 0, i64 %indvars.iv.i
  %3 = load i8, i8* %id4.i, align 8, !alias.scope !4058, !noalias !4061
  %cmp2.i = icmp ne i8 %3, 0
  %indvars.iv.next.i = add nuw nsw i64 %indvars.iv.i, 1
  br i1 %cmp2.i, label %land.lhs.true.i, label %for.cond.i

land.lhs.true.i:                                  ; preds = %for.body.i.split
  %ref35.12.i = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.ref.bank", i64 0, i64 %indvars.iv.i
  %.18.i = load i8, i8* %ref35.12.i, align 1, !alias.scope !4058, !noalias !4061
  %region46.i = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.region", i64 0, i64 %indvars.iv.i
  %4 = load i8, i8* %region46.i, align 4, !alias.scope !4058, !noalias !4061
  %cmp.i.i = icmp ne i8 %4, 0
  br i1 %cmp.i.i, label %_ZN4laya4full12_GLOBAL__N_113same_physicalENS_9BufferRefEhS2_h.exit.i, label %if.end.i.i

if.end.i.i:                                       ; preds = %land.lhs.true.i
  %cmp2.i.i = icmp eq i8 %3, 43
  %or.cond.i.i = and i1 %cmp2.i.i, %cmp4.i.i
  br i1 %or.cond.i.i, label %_ZN4laya4full12_GLOBAL__N_113same_physicalENS_9BufferRefEhS2_h.exit.i.thread, label %if.end6.i.i

if.end6.i.i:                                      ; preds = %if.end.i.i
  %cmp10.i.i = icmp ne i8 %.18.i, %old_s_ref_bank.0.0.val
  br i1 %cmp10.i.i, label %_ZN4laya4full12_GLOBAL__N_113same_physicalENS_9BufferRefEhS2_h.exit.i, label %if.end12.i.i

if.end12.i.i:                                     ; preds = %if.end6.i.i
  %cmp15.i.i = icmp eq i8 %3, %old_s_ref_id.0.0.val
  %cmp19.i.i = icmp eq i8 %3, 6
  %or.cond1.i.i = and i1 %cmp19.i.i, %cmp22.i.i
  %or.cond99 = or i1 %cmp15.i.i, %or.cond1.i.i
  br i1 %or.cond99, label %_ZN4laya4full12_GLOBAL__N_113same_physicalENS_9BufferRefEhS2_h.exit.i.thread, label %lor.rhs.i.i

lor.rhs.i.i:                                      ; preds = %if.end12.i.i
  %cmp24.i.i = icmp eq i8 %3, 9
  %spec.select.i.i = select i1 %cmp24.i.i, i1 %cmp26.i.i, i1 false
  br i1 %spec.select.i.i, label %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit.loopexit.split.loop.exit11, label %for.cond.i

_ZN4laya4full12_GLOBAL__N_113same_physicalENS_9BufferRefEhS2_h.exit.i.thread: ; preds = %if.end12.i.i, %if.end.i.i
  %5 = trunc i64 %indvars.iv.i to i32
  br label %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit

_ZN4laya4full12_GLOBAL__N_113same_physicalENS_9BufferRefEhS2_h.exit.i: ; preds = %if.end6.i.i, %land.lhs.true.i
  br label %for.cond.i

_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit.loopexit.split.loop.exit11: ; preds = %lor.rhs.i.i
  %6 = trunc i64 %indvars.iv.i to i32
  br label %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit

_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit.loopexit: ; preds = %for.body.i
  br label %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit

_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit: ; preds = %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit.loopexit, %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit.loopexit.split.loop.exit11, %_ZN4laya4full12_GLOBAL__N_113same_physicalENS_9BufferRefEhS2_h.exit.i.thread
  %retval.1.i109 = phi i32 [ %5, %_ZN4laya4full12_GLOBAL__N_113same_physicalENS_9BufferRefEhS2_h.exit.i.thread ], [ %6, %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit.loopexit.split.loop.exit11 ], [ undef, %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit.loopexit ]
  %cleanup.dest.slot.1.i = phi i32 [ 1, %_ZN4laya4full12_GLOBAL__N_113same_physicalENS_9BufferRefEhS2_h.exit.i.thread ], [ 1, %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit.loopexit.split.loop.exit11 ], [ 3, %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit.loopexit ]
  %cleanup.dest.slot.1.off.i = add nsw i32 %cleanup.dest.slot.1.i, -3
  %switch.i = icmp ult i32 %cleanup.dest.slot.1.off.i, 1
  %spec.select.i = select i1 %switch.i, i32 32, i32 %retval.1.i109
  %ref52.29 = getelementptr [2 x i32], [2 x i32]* %old_s_ref_epoch, i64 0, i64 1
  %.270 = load i32, i32* %ref52.29, align 4
  %cmp4.i.i43 = icmp eq i8 %old_s_ref_id.0.1.val, 43
  %cmp22.i.i51 = icmp eq i8 %old_s_ref_id.0.1.val, 9
  %cmp26.i.i55 = icmp eq i8 %old_s_ref_id.0.1.val, 6
  br label %for.body.i31

for.cond.i26:                                     ; preds = %_ZN4laya4full12_GLOBAL__N_113same_physicalENS_9BufferRefEhS2_h.exit.i59, %lor.rhs.i.i57, %for.body.i31.split
  br label %for.body.i31, !llvm.loop !4065

for.body.i31:                                     ; preds = %for.cond.i26, %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit
  %indvars.iv.i27 = phi i64 [ 0, %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit ], [ %indvars.iv.next.i63, %for.cond.i26 ]
  %cmp.i2512 = icmp ult i64 %indvars.iv.i27, 32
  br i1 %cmp.i2512, label %for.body.i31.split, label %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit69.loopexit, !llvm.loop !4065

for.body.i31.split:                               ; preds = %for.body.i31
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 0, i64 32, i64 16), !fpga.pragma.source !33
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @42)
  %id4.i29 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.ref.id", i64 0, i64 %indvars.iv.i27
  %7 = load i8, i8* %id4.i29, align 8, !alias.scope !4069, !noalias !4072
  %cmp2.i30 = icmp ne i8 %7, 0
  %indvars.iv.next.i63 = add nuw nsw i64 %indvars.iv.i27, 1
  br i1 %cmp2.i30, label %land.lhs.true.i41, label %for.cond.i26

land.lhs.true.i41:                                ; preds = %for.body.i31.split
  %ref35.12.i32 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.ref.bank", i64 0, i64 %indvars.iv.i27
  %.18.i33 = load i8, i8* %ref35.12.i32, align 1, !alias.scope !4069, !noalias !4072
  %region46.i36 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.region", i64 0, i64 %indvars.iv.i27
  %8 = load i8, i8* %region46.i36, align 4, !alias.scope !4069, !noalias !4072
  %cmp.i.i40 = icmp ne i8 %8, 0
  br i1 %cmp.i.i40, label %_ZN4laya4full12_GLOBAL__N_113same_physicalENS_9BufferRefEhS2_h.exit.i59, label %if.end.i.i45

if.end.i.i45:                                     ; preds = %land.lhs.true.i41
  %cmp2.i.i42 = icmp eq i8 %7, 43
  %or.cond.i.i44 = and i1 %cmp2.i.i42, %cmp4.i.i43
  br i1 %or.cond.i.i44, label %_ZN4laya4full12_GLOBAL__N_113same_physicalENS_9BufferRefEhS2_h.exit.i59.thread, label %if.end6.i.i47

if.end6.i.i47:                                    ; preds = %if.end.i.i45
  %cmp10.i.i46 = icmp ne i8 %.18.i33, %old_s_ref_bank.0.1.val
  br i1 %cmp10.i.i46, label %_ZN4laya4full12_GLOBAL__N_113same_physicalENS_9BufferRefEhS2_h.exit.i59, label %if.end12.i.i49

if.end12.i.i49:                                   ; preds = %if.end6.i.i47
  %cmp15.i.i48 = icmp eq i8 %7, %old_s_ref_id.0.1.val
  %cmp19.i.i50 = icmp eq i8 %7, 6
  %or.cond1.i.i52 = and i1 %cmp19.i.i50, %cmp22.i.i51
  %or.cond100 = or i1 %cmp15.i.i48, %or.cond1.i.i52
  br i1 %or.cond100, label %_ZN4laya4full12_GLOBAL__N_113same_physicalENS_9BufferRefEhS2_h.exit.i59.thread, label %lor.rhs.i.i57

lor.rhs.i.i57:                                    ; preds = %if.end12.i.i49
  %cmp24.i.i54 = icmp eq i8 %7, 9
  %spec.select.i.i56 = select i1 %cmp24.i.i54, i1 %cmp26.i.i55, i1 false
  br i1 %spec.select.i.i56, label %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit69.loopexit.split.loop.exit7, label %for.cond.i26

_ZN4laya4full12_GLOBAL__N_113same_physicalENS_9BufferRefEhS2_h.exit.i59.thread: ; preds = %if.end12.i.i49, %if.end.i.i45
  %9 = trunc i64 %indvars.iv.i27 to i32
  br label %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit69

_ZN4laya4full12_GLOBAL__N_113same_physicalENS_9BufferRefEhS2_h.exit.i59: ; preds = %if.end6.i.i47, %land.lhs.true.i41
  br label %for.cond.i26

_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit69.loopexit.split.loop.exit7: ; preds = %lor.rhs.i.i57
  %10 = trunc i64 %indvars.iv.i27 to i32
  br label %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit69

_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit69.loopexit: ; preds = %for.body.i31
  br label %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit69

_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit69: ; preds = %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit69.loopexit, %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit69.loopexit.split.loop.exit7, %_ZN4laya4full12_GLOBAL__N_113same_physicalENS_9BufferRefEhS2_h.exit.i59.thread
  %retval.1.i62110 = phi i32 [ %9, %_ZN4laya4full12_GLOBAL__N_113same_physicalENS_9BufferRefEhS2_h.exit.i59.thread ], [ %10, %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit69.loopexit.split.loop.exit7 ], [ undef, %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit69.loopexit ]
  %cleanup.dest.slot.1.i65 = phi i32 [ 1, %_ZN4laya4full12_GLOBAL__N_113same_physicalENS_9BufferRefEhS2_h.exit.i59.thread ], [ 1, %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit69.loopexit.split.loop.exit7 ], [ 3, %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit69.loopexit ]
  %cleanup.dest.slot.1.off.i66 = add nsw i32 %cleanup.dest.slot.1.i65, -3
  %switch.i67 = icmp ult i32 %cleanup.dest.slot.1.off.i66, 1
  %spec.select.i68 = select i1 %switch.i67, i32 32, i32 %retval.1.i62110
  %cmp = icmp eq i32 %spec.select.i, 32
  %cmp8 = icmp eq i32 %spec.select.i68, 32
  %or.cond = or i1 %cmp, %cmp8
  br i1 %or.cond, label %return, label %if.end10

if.end10:                                         ; preds = %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit69
  %idxprom = zext i32 %spec.select.i to i64
  %arrayidx114.0.0 = getelementptr [32 x i64], [32 x i64]* @"(anonymous namespace)::runtime.owners.record.identity.request_id", i64 0, i64 %idxprom
  %arrayidx114.0.1 = getelementptr [32 x i64], [32 x i64]* @"(anonymous namespace)::runtime.owners.record.identity.generation", i64 0, i64 %idxprom
  %arrayidx114.0.2 = getelementptr [32 x i16], [32 x i16]* @"(anonymous namespace)::runtime.owners.record.identity.B", i64 0, i64 %idxprom
  %arrayidx114.0.3 = getelementptr [32 x i16], [32 x i16]* @"(anonymous namespace)::runtime.owners.record.identity.S", i64 0, i64 %idxprom
  %arrayidx114.0.4 = getelementptr [32 x [16 x i8]], [32 x [16 x i8]]* @"(anonymous namespace)::runtime.owners.record.identity.model_tag", i64 0, i64 %idxprom
  %arrayidx114.0.5 = getelementptr [32 x [16 x i8]], [32 x [16 x i8]]* @"(anonymous namespace)::runtime.owners.record.identity.numeric_tag", i64 0, i64 %idxprom
  %arrayidx114.0.6 = getelementptr [32 x [16 x i8]], [32 x [16 x i8]]* @"(anonymous namespace)::runtime.owners.record.identity.layout_tag", i64 0, i64 %idxprom
  %arrayidx114.0.7 = getelementptr [32 x [16 x i8]], [32 x [16 x i8]]* @"(anonymous namespace)::runtime.owners.record.identity.build_tag", i64 0, i64 %idxprom
  %arrayidx114.1.0 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.ref.id", i64 0, i64 %idxprom
  %arrayidx114.1.1 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.ref.bank", i64 0, i64 %idxprom
  %arrayidx114.1.2 = getelementptr [32 x i32], [32 x i32]* @"(anonymous namespace)::runtime.owners.record.ref.epoch", i64 0, i64 %idxprom
  %arrayidx114.2.0 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.lease_old_ref.id", i64 0, i64 %idxprom
  %arrayidx114.2.1 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.lease_old_ref.bank", i64 0, i64 %idxprom
  %arrayidx114.2.2 = getelementptr [32 x i32], [32 x i32]* @"(anonymous namespace)::runtime.owners.record.lease_old_ref.epoch", i64 0, i64 %idxprom
  %arrayidx114.3 = getelementptr [32 x i32], [32 x i32]* @"(anonymous namespace)::runtime.owners.record.max_claimed_epoch", i64 0, i64 %idxprom
  %arrayidx114.4 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.region", i64 0, i64 %idxprom
  %arrayidx114.5 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.stage", i64 0, i64 %idxprom
  %arrayidx114.6 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.layer", i64 0, i64 %idxprom
  %arrayidx114.7 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.batch", i64 0, i64 %idxprom
  %arrayidx114.8 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.row_space", i64 0, i64 %idxprom
  %arrayidx114.9 = getelementptr [32 x i16], [32 x i16]* @"(anonymous namespace)::runtime.owners.record.row0", i64 0, i64 %idxprom
  %arrayidx114.10 = getelementptr [32 x i16], [32 x i16]* @"(anonymous namespace)::runtime.owners.record.rows", i64 0, i64 %idxprom
  %arrayidx114.11 = getelementptr [32 x i16], [32 x i16]* @"(anonymous namespace)::runtime.owners.record.width", i64 0, i64 %idxprom
  %arrayidx114.12 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.content", i64 0, i64 %idxprom
  %arrayidx114.13 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.state", i64 0, i64 %idxprom
  %arrayidx114.14 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.readers", i64 0, i64 %idxprom
  %arrayidx114.15 = getelementptr [32 x [64 x i32]], [32 x [64 x i32]]* @"(anonymous namespace)::runtime.owners.record.covered_rows", i64 0, i64 %idxprom
  %arrayidx114.17 = getelementptr [32 x i1], [32 x i1]* @"(anonymous namespace)::runtime.owners.record.valid", i64 0, i64 %idxprom
  %idxprom14 = zext i32 %spec.select.i68 to i64
  %arrayidx156.0.0 = getelementptr [32 x i64], [32 x i64]* @"(anonymous namespace)::runtime.owners.record.identity.request_id", i64 0, i64 %idxprom14
  %arrayidx156.0.1 = getelementptr [32 x i64], [32 x i64]* @"(anonymous namespace)::runtime.owners.record.identity.generation", i64 0, i64 %idxprom14
  %arrayidx156.0.2 = getelementptr [32 x i16], [32 x i16]* @"(anonymous namespace)::runtime.owners.record.identity.B", i64 0, i64 %idxprom14
  %arrayidx156.0.3 = getelementptr [32 x i16], [32 x i16]* @"(anonymous namespace)::runtime.owners.record.identity.S", i64 0, i64 %idxprom14
  %arrayidx156.0.4 = getelementptr [32 x [16 x i8]], [32 x [16 x i8]]* @"(anonymous namespace)::runtime.owners.record.identity.model_tag", i64 0, i64 %idxprom14
  %arrayidx156.0.5 = getelementptr [32 x [16 x i8]], [32 x [16 x i8]]* @"(anonymous namespace)::runtime.owners.record.identity.numeric_tag", i64 0, i64 %idxprom14
  %arrayidx156.0.6 = getelementptr [32 x [16 x i8]], [32 x [16 x i8]]* @"(anonymous namespace)::runtime.owners.record.identity.layout_tag", i64 0, i64 %idxprom14
  %arrayidx156.0.7 = getelementptr [32 x [16 x i8]], [32 x [16 x i8]]* @"(anonymous namespace)::runtime.owners.record.identity.build_tag", i64 0, i64 %idxprom14
  %arrayidx156.1.0 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.ref.id", i64 0, i64 %idxprom14
  %arrayidx156.1.1 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.ref.bank", i64 0, i64 %idxprom14
  %arrayidx156.1.2 = getelementptr [32 x i32], [32 x i32]* @"(anonymous namespace)::runtime.owners.record.ref.epoch", i64 0, i64 %idxprom14
  %arrayidx156.2.0 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.lease_old_ref.id", i64 0, i64 %idxprom14
  %arrayidx156.2.1 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.lease_old_ref.bank", i64 0, i64 %idxprom14
  %arrayidx156.2.2 = getelementptr [32 x i32], [32 x i32]* @"(anonymous namespace)::runtime.owners.record.lease_old_ref.epoch", i64 0, i64 %idxprom14
  %arrayidx156.3 = getelementptr [32 x i32], [32 x i32]* @"(anonymous namespace)::runtime.owners.record.max_claimed_epoch", i64 0, i64 %idxprom14
  %arrayidx156.4 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.region", i64 0, i64 %idxprom14
  %arrayidx156.5 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.stage", i64 0, i64 %idxprom14
  %arrayidx156.6 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.layer", i64 0, i64 %idxprom14
  %arrayidx156.7 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.batch", i64 0, i64 %idxprom14
  %arrayidx156.8 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.row_space", i64 0, i64 %idxprom14
  %arrayidx156.9 = getelementptr [32 x i16], [32 x i16]* @"(anonymous namespace)::runtime.owners.record.row0", i64 0, i64 %idxprom14
  %arrayidx156.10 = getelementptr [32 x i16], [32 x i16]* @"(anonymous namespace)::runtime.owners.record.rows", i64 0, i64 %idxprom14
  %arrayidx156.11 = getelementptr [32 x i16], [32 x i16]* @"(anonymous namespace)::runtime.owners.record.width", i64 0, i64 %idxprom14
  %arrayidx156.12 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.content", i64 0, i64 %idxprom14
  %arrayidx156.13 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.state", i64 0, i64 %idxprom14
  %arrayidx156.14 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.readers", i64 0, i64 %idxprom14
  %arrayidx156.15 = getelementptr [32 x [64 x i32]], [32 x [64 x i32]]* @"(anonymous namespace)::runtime.owners.record.covered_rows", i64 0, i64 %idxprom14
  %arrayidx156.17 = getelementptr [32 x i1], [32 x i1]* @"(anonymous namespace)::runtime.owners.record.valid", i64 0, i64 %idxprom14
  %arrayidx16.1 = getelementptr [2 x i8], [2 x i8]* %old_s_region, i64 0, i64 0
  %arrayidx16.2 = getelementptr [2 x i8], [2 x i8]* %old_s_stage, i64 0, i64 0
  %arrayidx16.3 = getelementptr [2 x i8], [2 x i8]* %old_s_layer, i64 0, i64 0
  %arrayidx16.4 = getelementptr [2 x i8], [2 x i8]* %old_s_batch, i64 0, i64 0
  %arrayidx16.5 = getelementptr [2 x i8], [2 x i8]* %old_s_row_space, i64 0, i64 0
  %arrayidx16.6 = getelementptr [2 x i16], [2 x i16]* %old_s_row0, i64 0, i64 0
  %arrayidx16.7 = getelementptr [2 x i16], [2 x i16]* %old_s_rows, i64 0, i64 0
  %arrayidx16.8 = getelementptr [2 x i16], [2 x i16]* %old_s_width, i64 0, i64 0
  %arrayidx16.1.val = load i8, i8* %arrayidx16.1, align 512
  %arrayidx16.2.val = load i8, i8* %arrayidx16.2, align 512
  %arrayidx16.3.val = load i8, i8* %arrayidx16.3, align 512
  %arrayidx16.4.val = load i8, i8* %arrayidx16.4, align 512
  %arrayidx16.5.val = load i8, i8* %arrayidx16.5, align 512
  %arrayidx16.6.val = load i16, i16* %arrayidx16.6, align 512
  %arrayidx16.7.val = load i16, i16* %arrayidx16.7, align 512
  %arrayidx16.8.val = load i16, i16* %arrayidx16.8, align 512
  %11 = call fastcc i1 @"laya::full::(anonymous namespace)::same_spec"(i8* %arrayidx114.1.0, i8* %arrayidx114.1.1, i32* %arrayidx114.1.2, i8* %arrayidx114.4, i8* %arrayidx114.5, i8* %arrayidx114.6, i8* %arrayidx114.7, i8* %arrayidx114.8, i16* %arrayidx114.9, i16* %arrayidx114.10, i16* %arrayidx114.11, i8* %arrayidx114.12, i8 %old_s_ref_id.0.0.val, i8 %old_s_ref_bank.0.0.val, i32 %.273, i8 %arrayidx16.1.val, i8 %arrayidx16.2.val, i8 %arrayidx16.3.val, i8 %arrayidx16.4.val, i8 %arrayidx16.5.val, i16 %arrayidx16.6.val, i16 %arrayidx16.7.val, i16 %arrayidx16.8.val, i8 %old_s_content.0.0.val)
  br i1 %11, label %lor.lhs.false18, label %if.then54

lor.lhs.false18:                                  ; preds = %if.end10
  %arrayidx19.1 = getelementptr [2 x i8], [2 x i8]* %old_s_region, i64 0, i64 1
  %arrayidx19.2 = getelementptr [2 x i8], [2 x i8]* %old_s_stage, i64 0, i64 1
  %arrayidx19.3 = getelementptr [2 x i8], [2 x i8]* %old_s_layer, i64 0, i64 1
  %arrayidx19.4 = getelementptr [2 x i8], [2 x i8]* %old_s_batch, i64 0, i64 1
  %arrayidx19.5 = getelementptr [2 x i8], [2 x i8]* %old_s_row_space, i64 0, i64 1
  %arrayidx19.6 = getelementptr [2 x i16], [2 x i16]* %old_s_row0, i64 0, i64 1
  %arrayidx19.7 = getelementptr [2 x i16], [2 x i16]* %old_s_rows, i64 0, i64 1
  %arrayidx19.8 = getelementptr [2 x i16], [2 x i16]* %old_s_width, i64 0, i64 1
  %arrayidx19.1.val = load i8, i8* %arrayidx19.1, align 4
  %arrayidx19.2.val = load i8, i8* %arrayidx19.2, align 1
  %arrayidx19.3.val = load i8, i8* %arrayidx19.3, align 2
  %arrayidx19.4.val = load i8, i8* %arrayidx19.4, align 1
  %arrayidx19.5.val = load i8, i8* %arrayidx19.5, align 4
  %arrayidx19.6.val = load i16, i16* %arrayidx19.6, align 2
  %arrayidx19.7.val = load i16, i16* %arrayidx19.7, align 4
  %arrayidx19.8.val = load i16, i16* %arrayidx19.8, align 2
  %12 = call fastcc i1 @"laya::full::(anonymous namespace)::same_spec"(i8* %arrayidx156.1.0, i8* %arrayidx156.1.1, i32* %arrayidx156.1.2, i8* %arrayidx156.4, i8* %arrayidx156.5, i8* %arrayidx156.6, i8* %arrayidx156.7, i8* %arrayidx156.8, i16* %arrayidx156.9, i16* %arrayidx156.10, i16* %arrayidx156.11, i8* %arrayidx156.12, i8 %old_s_ref_id.0.1.val, i8 %old_s_ref_bank.0.1.val, i32 %.270, i8 %arrayidx19.1.val, i8 %arrayidx19.2.val, i8 %arrayidx19.3.val, i8 %arrayidx19.4.val, i8 %arrayidx19.5.val, i16 %arrayidx19.6.val, i16 %arrayidx19.7.val, i16 %arrayidx19.8.val, i8 %old_s_content.0.1.val)
  br i1 %12, label %lor.lhs.false21, label %if.then54

lor.lhs.false21:                                  ; preds = %lor.lhs.false18
  %13 = load i1, i1* %arrayidx114.17, align 4
  br i1 %13, label %lor.lhs.false22, label %if.then54

lor.lhs.false22:                                  ; preds = %lor.lhs.false21
  %14 = load i1, i1* %arrayidx156.17, align 4
  br i1 %14, label %lor.lhs.false24, label %if.then54

lor.lhs.false24:                                  ; preds = %lor.lhs.false22
  %15 = load i8, i8* %arrayidx114.13, align 1
  %cmp25 = icmp ne i8 %15, 2
  br i1 %cmp25, label %if.then54, label %lor.lhs.false26

lor.lhs.false26:                                  ; preds = %lor.lhs.false24
  %16 = load i8, i8* %arrayidx156.13, align 1
  %cmp28 = icmp ne i8 %16, 2
  br i1 %cmp28, label %if.then54, label %lor.lhs.false29

lor.lhs.false29:                                  ; preds = %lor.lhs.false26
  %17 = load i8, i8* %arrayidx114.14, align 2
  %tobool = icmp ne i8 %17, 0
  br i1 %tobool, label %if.then54, label %lor.lhs.false30

lor.lhs.false30:                                  ; preds = %lor.lhs.false29
  %18 = load i8, i8* %arrayidx156.14, align 2
  %tobool32 = icmp ne i8 %18, 0
  br i1 %tobool32, label %if.then54, label %lor.lhs.false33

lor.lhs.false33:                                  ; preds = %lor.lhs.false30
  %19 = load i32, i32* %arrayidx114.3, align 8
  %cmp34 = icmp uge i32 %19, -2
  br i1 %cmp34, label %if.then54, label %lor.lhs.false35

lor.lhs.false35:                                  ; preds = %lor.lhs.false33
  %20 = load i32, i32* %arrayidx156.3, align 8
  %cmp37 = icmp uge i32 %20, -2
  br i1 %cmp37, label %if.then54, label %lor.lhs.false38

lor.lhs.false38:                                  ; preds = %lor.lhs.false35
  %21 = call fastcc i1 @"laya::numeric_identity_equal"(i64* %arrayidx114.0.0, i64* %arrayidx114.0.1, i16* %arrayidx114.0.2, i16* %arrayidx114.0.3, [16 x i8]* %arrayidx114.0.4, [16 x i8]* %arrayidx114.0.5, [16 x i8]* %arrayidx114.0.6, [16 x i8]* %arrayidx114.0.7)
  br i1 %21, label %lor.lhs.false41, label %if.then54

lor.lhs.false41:                                  ; preds = %lor.lhs.false38
  %22 = call fastcc i1 @"laya::numeric_identity_equal"(i64* %arrayidx156.0.0, i64* %arrayidx156.0.1, i16* %arrayidx156.0.2, i16* %arrayidx156.0.3, [16 x i8]* %arrayidx156.0.4, [16 x i8]* %arrayidx156.0.5, [16 x i8]* %arrayidx156.0.6, [16 x i8]* %arrayidx156.0.7)
  br i1 %22, label %lor.lhs.false46, label %if.then54

lor.lhs.false46:                                  ; preds = %lor.lhs.false41
  %23 = call fastcc i1 @"laya::full::(anonymous namespace)::covered.11"(i8 %old_s_ref_id.0.0.val, i8 %arrayidx16.4.val, i8 %arrayidx16.5.val, i16 %arrayidx16.6.val, i16 %arrayidx16.7.val, [64 x i32]* %arrayidx114.15)
  br i1 %23, label %lor.lhs.false49, label %if.then54

lor.lhs.false49:                                  ; preds = %lor.lhs.false46
  %24 = call fastcc i1 @"laya::full::(anonymous namespace)::covered.11"(i8 %old_s_ref_id.0.1.val, i8 %arrayidx19.4.val, i8 %arrayidx19.5.val, i16 %arrayidx19.6.val, i16 %arrayidx19.7.val, [64 x i32]* %arrayidx156.15)
  br i1 %24, label %if.end55, label %if.then54

if.then54:                                        ; preds = %lor.lhs.false49, %lor.lhs.false46, %lor.lhs.false41, %lor.lhs.false38, %lor.lhs.false35, %lor.lhs.false33, %lor.lhs.false30, %lor.lhs.false29, %lor.lhs.false26, %lor.lhs.false24, %lor.lhs.false22, %lor.lhs.false21, %lor.lhs.false18, %if.end10
  br label %return

if.end55:                                         ; preds = %lor.lhs.false49
  store i8 %old_s_ref_id.0.0.val, i8* %arrayidx114.2.0, align 32
  store i8 %old_s_ref_bank.0.0.val, i8* %arrayidx114.2.1, align 1
  store i32 %.273, i32* %arrayidx114.2.2, align 4
  %ref5925.04 = getelementptr [2 x i8], [2 x i8]* %next_s_ref_id, i64 0, i64 0
  %ref5925.15 = getelementptr [2 x i8], [2 x i8]* %next_s_ref_bank, i64 0, i64 0
  %ref5925.26 = getelementptr [2 x i32], [2 x i32]* %next_s_ref_epoch, i64 0, i64 0
  %.062 = load i8, i8* %ref5925.04, align 512
  %.163 = load i8, i8* %ref5925.15, align 512
  %.264 = load i32, i32* %ref5925.26, align 512
  store i8 %.062, i8* %arrayidx114.1.0, align 8
  store i8 %.163, i8* %arrayidx114.1.1, align 1
  store i32 %.264, i32* %arrayidx114.1.2, align 4
  store i32 %.264, i32* %arrayidx114.3, align 8
  store i8 3, i8* %arrayidx114.12, align 8
  store i8 4, i8* %arrayidx114.13, align 1
  store i1 false, i1* %arrayidx114.17, align 4
  br label %for.inc.i

for.inc.i:                                        ; preds = %for.inc.i.split, %if.end55
  %indvars.iv.i70 = phi i64 [ 0, %if.end55 ], [ %indvars.iv.next.i71, %for.inc.i.split ]
  %exitcond.i13 = icmp ne i64 %indvars.iv.i70, 64
  br i1 %exitcond.i13, label %for.inc.i.split, label %_ZN4laya4full12_GLOBAL__N_110clear_bitsEPj.exit, !llvm.loop !4076

for.inc.i.split:                                  ; preds = %for.inc.i
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 64, i64 64, i64 64), !fpga.pragma.source !33
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @95)
  %arrayidx.i90 = getelementptr [32 x [64 x i32]], [32 x [64 x i32]]* @"(anonymous namespace)::runtime.owners.record.covered_rows", i64 0, i64 %idxprom, i64 %indvars.iv.i70
  store i32 0, i32* %arrayidx.i90, align 4, !alias.scope !4080
  %indvars.iv.next.i71 = add nuw nsw i64 %indvars.iv.i70, 1
  br label %for.inc.i, !llvm.loop !4076

_ZN4laya4full12_GLOBAL__N_110clear_bitsEPj.exit:  ; preds = %for.inc.i
  br label %for.inc.i76

for.inc.i76:                                      ; preds = %for.inc.i76.split, %_ZN4laya4full12_GLOBAL__N_110clear_bitsEPj.exit
  %indvars.iv.i72 = phi i64 [ 0, %_ZN4laya4full12_GLOBAL__N_110clear_bitsEPj.exit ], [ %indvars.iv.next.i74, %for.inc.i76.split ]
  %exitcond.i7514 = icmp ne i64 %indvars.iv.i72, 64
  br i1 %exitcond.i7514, label %for.inc.i76.split, label %_ZN4laya4full12_GLOBAL__N_110clear_bitsEPj.exit77, !llvm.loop !4083

for.inc.i76.split:                                ; preds = %for.inc.i76
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 64, i64 64, i64 64), !fpga.pragma.source !33
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @95)
  %arrayidx.i7391 = getelementptr [32 x [64 x i32]], [32 x [64 x i32]]* @"(anonymous namespace)::runtime.owners.record.old_consumed_rows", i64 0, i64 %idxprom, i64 %indvars.iv.i72
  store i32 0, i32* %arrayidx.i7391, align 4, !alias.scope !4087
  %indvars.iv.next.i74 = add nuw nsw i64 %indvars.iv.i72, 1
  br label %for.inc.i76, !llvm.loop !4083

_ZN4laya4full12_GLOBAL__N_110clear_bitsEPj.exit77: ; preds = %for.inc.i76
  store i8 %old_s_ref_id.0.1.val, i8* %arrayidx156.2.0, align 32
  store i8 %old_s_ref_bank.0.1.val, i8* %arrayidx156.2.1, align 1
  store i32 %.270, i32* %arrayidx156.2.2, align 4
  %ref7339.01 = getelementptr [2 x i8], [2 x i8]* %next_s_ref_id, i64 0, i64 1
  %ref7339.12 = getelementptr [2 x i8], [2 x i8]* %next_s_ref_bank, i64 0, i64 1
  %ref7339.23 = getelementptr [2 x i32], [2 x i32]* %next_s_ref_epoch, i64 0, i64 1
  %.0 = load i8, i8* %ref7339.01, align 1
  %.1 = load i8, i8* %ref7339.12, align 1
  %.2 = load i32, i32* %ref7339.23, align 4
  store i8 %.0, i8* %arrayidx156.1.0, align 8
  store i8 %.1, i8* %arrayidx156.1.1, align 1
  store i32 %.2, i32* %arrayidx156.1.2, align 4
  store i32 %.2, i32* %arrayidx156.3, align 8
  store i8 3, i8* %arrayidx156.12, align 8
  store i8 4, i8* %arrayidx156.13, align 1
  store i1 false, i1* %arrayidx156.17, align 4
  br label %for.inc.i82

for.inc.i82:                                      ; preds = %for.inc.i82.split, %_ZN4laya4full12_GLOBAL__N_110clear_bitsEPj.exit77
  %indvars.iv.i78 = phi i64 [ 0, %_ZN4laya4full12_GLOBAL__N_110clear_bitsEPj.exit77 ], [ %indvars.iv.next.i80, %for.inc.i82.split ]
  %exitcond.i8115 = icmp ne i64 %indvars.iv.i78, 64
  br i1 %exitcond.i8115, label %for.inc.i82.split, label %_ZN4laya4full12_GLOBAL__N_110clear_bitsEPj.exit83, !llvm.loop !4090

for.inc.i82.split:                                ; preds = %for.inc.i82
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 64, i64 64, i64 64), !fpga.pragma.source !33
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @95)
  %arrayidx.i7992 = getelementptr [32 x [64 x i32]], [32 x [64 x i32]]* @"(anonymous namespace)::runtime.owners.record.covered_rows", i64 0, i64 %idxprom14, i64 %indvars.iv.i78
  store i32 0, i32* %arrayidx.i7992, align 4, !alias.scope !4094
  %indvars.iv.next.i80 = add nuw nsw i64 %indvars.iv.i78, 1
  br label %for.inc.i82, !llvm.loop !4090

_ZN4laya4full12_GLOBAL__N_110clear_bitsEPj.exit83: ; preds = %for.inc.i82
  br label %for.inc.i88

for.inc.i88:                                      ; preds = %for.inc.i88.split, %_ZN4laya4full12_GLOBAL__N_110clear_bitsEPj.exit83
  %indvars.iv.i84 = phi i64 [ 0, %_ZN4laya4full12_GLOBAL__N_110clear_bitsEPj.exit83 ], [ %indvars.iv.next.i86, %for.inc.i88.split ]
  %exitcond.i8716 = icmp ne i64 %indvars.iv.i84, 64
  br i1 %exitcond.i8716, label %for.inc.i88.split, label %_ZN4laya4full12_GLOBAL__N_110clear_bitsEPj.exit89, !llvm.loop !4097

for.inc.i88.split:                                ; preds = %for.inc.i88
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 64, i64 64, i64 64), !fpga.pragma.source !33
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @95)
  %arrayidx.i8593 = getelementptr [32 x [64 x i32]], [32 x [64 x i32]]* @"(anonymous namespace)::runtime.owners.record.old_consumed_rows", i64 0, i64 %idxprom14, i64 %indvars.iv.i84
  store i32 0, i32* %arrayidx.i8593, align 4, !alias.scope !4101
  %indvars.iv.next.i86 = add nuw nsw i64 %indvars.iv.i84, 1
  br label %for.inc.i88, !llvm.loop !4097

_ZN4laya4full12_GLOBAL__N_110clear_bitsEPj.exit89: ; preds = %for.inc.i88
  %25 = load i32, i32* @"(anonymous namespace)::runtime.owner_leases", align 512
  %add = add i32 %25, 2
  store i32 %add, i32* @"(anonymous namespace)::runtime.owner_leases", align 512
  br label %for.cond

for.cond:                                         ; preds = %for.inc127, %_ZN4laya4full12_GLOBAL__N_110clear_bitsEPj.exit89
  %idx = phi i64 [ 0, %_ZN4laya4full12_GLOBAL__N_110clear_bitsEPj.exit89 ], [ %inc, %for.inc127 ]
  %exitcond116 = icmp ne i64 %idx, 2
  br i1 %exitcond116, label %VITIS_LOOP_384_2, label %return.loopexit

VITIS_LOOP_384_2:                                 ; preds = %for.cond
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 2, i64 2, i64 2), !fpga.pragma.source !33
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @121)
  br label %for.cond93

for.cond93:                                       ; preds = %for.inc124, %VITIS_LOOP_384_2
  %idx101 = phi i64 [ 0, %VITIS_LOOP_384_2 ], [ %inc102, %for.inc124 ]
  %exitcond115 = icmp ne i64 %idx101, 2
  br i1 %exitcond115, label %VITIS_LOOP_385_3, label %for.inc127

VITIS_LOOP_385_3:                                 ; preds = %for.cond93
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 2, i64 2, i64 2), !fpga.pragma.source !33
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @120)
  br label %for.cond100

for.cond100:                                      ; preds = %for.inc121, %VITIS_LOOP_385_3
  %idx103 = phi i64 [ 0, %VITIS_LOOP_385_3 ], [ %inc104, %for.inc121 ]
  %exitcond114 = icmp ne i64 %idx103, 16
  br i1 %exitcond114, label %VITIS_LOOP_386_4, label %for.inc124

VITIS_LOOP_386_4:                                 ; preds = %for.cond100
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 16, i64 16, i64 16), !fpga.pragma.source !33
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @119)
  br label %for.cond107

for.cond107:                                      ; preds = %for.inc118, %VITIS_LOOP_386_4
  %idx105 = phi i64 [ 0, %VITIS_LOOP_386_4 ], [ %inc106, %for.inc118 ]
  %exitcond113 = icmp ne i64 %idx105, 2
  br i1 %exitcond113, label %VITIS_LOOP_387_5, label %for.inc121

VITIS_LOOP_387_5:                                 ; preds = %for.cond107
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 2, i64 2, i64 2), !fpga.pragma.source !33
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @118)
  br label %for.cond114

for.cond114:                                      ; preds = %for.inc, %VITIS_LOOP_387_5
  %idx107 = phi i64 [ 0, %VITIS_LOOP_387_5 ], [ %inc108, %for.inc ]
  %arraydecay111.gep125 = getelementptr [2 x [2 x [16 x [2 x [32 x i32]]]]], [2 x [2 x [16 x [2 x [32 x i32]]]]]* @"(anonymous namespace)::runtime.owners.qkv_rope_rows", i64 0, i64 %idx, i64 %idx101, i64 %idx103, i64 %idx105, i64 %idx107
  %exitcond = icmp ne i64 %idx107, 32
  br i1 %exitcond, label %for.inc, label %for.inc118

for.inc:                                          ; preds = %for.cond114
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 32, i64 32, i64 32), !fpga.pragma.source !33
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @117)
  store i32 0, i32* %arraydecay111.gep125, align 4
  %inc108 = add nuw nsw i64 %idx107, 1
  br label %for.cond114, !llvm.loop !4104

for.inc118:                                       ; preds = %for.cond114
  %inc106 = add nuw nsw i64 %idx105, 1
  br label %for.cond107, !llvm.loop !4117

for.inc121:                                       ; preds = %for.cond107
  %inc104 = add nuw nsw i64 %idx103, 1
  br label %for.cond100, !llvm.loop !4121

for.inc124:                                       ; preds = %for.cond100
  %inc102 = add nuw nsw i64 %idx101, 1
  br label %for.cond93, !llvm.loop !4125

for.inc127:                                       ; preds = %for.cond93
  %inc = add nuw nsw i64 %idx, 1
  br label %for.cond, !llvm.loop !4129

return.loopexit:                                  ; preds = %for.cond
  br label %return

return:                                           ; preds = %return.loopexit, %if.then54, %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit69, %if.then
  %storemerge98 = phi i16 [ 5, %if.then ], [ 5, %if.then54 ], [ 5, %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit69 ], [ 0, %return.loopexit ]
  %storemerge95 = phi i32 [ 67436549, %if.then ], [ 67436553, %if.then54 ], [ 67436553, %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit69 ], [ 0, %return.loopexit ]
  store i16 %storemerge98, i16* %agg.result.0, align 512, !alias.scope !4133, !noalias !2
  store i32 %storemerge95, i32* %agg.result.1, align 512, !alias.scope !4142, !noalias !2
  store i64 -1, i64* %agg.result.2, align 512, !alias.scope !4147, !noalias !2
  ret void
}
