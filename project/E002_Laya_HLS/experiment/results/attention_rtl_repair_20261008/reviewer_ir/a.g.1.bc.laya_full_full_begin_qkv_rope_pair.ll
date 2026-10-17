define internal fastcc void @"laya::full::full_begin_qkv_rope_pair"(i16* noalias nocapture align 512 %agg.result.0, i32* noalias nocapture align 512 %agg.result.1, i64* noalias nocapture align 512 %agg.result.2, i8 %old_s_ref_id.0.0.val, i8 %old_s_ref_id.0.1.val, i8 %old_s_ref_bank.0.0.val, i8 %old_s_ref_bank.0.1.val, [2 x i32]* noalias nocapture align 512 %old_s_ref_epoch, [2 x i8]* noalias nocapture align 512 %old_s_region, [2 x i8]* noalias nocapture align 512 %old_s_stage, [2 x i8]* noalias nocapture align 512 %old_s_layer, [2 x i8]* noalias nocapture align 512 %old_s_batch, [2 x i8]* noalias nocapture align 512 %old_s_row_space, [2 x i16]* noalias nocapture align 512 %old_s_row0, [2 x i16]* noalias nocapture align 512 %old_s_rows, [2 x i16]* noalias nocapture align 512 %old_s_width, i8 %old_s_content.0.0.val, i8 %old_s_content.0.1.val, [2 x i8]* noalias nocapture align 512 %next_s_ref_id, [2 x i8]* noalias nocapture align 512 %next_s_ref_bank, [2 x i32]* noalias nocapture align 512 %next_s_ref_epoch, [2 x i8]* noalias nocapture align 512 %next_s_region, [2 x i8]* noalias nocapture align 512 %next_s_stage, [2 x i8]* noalias nocapture align 512 %next_s_layer, [2 x i8]* noalias nocapture align 512 %next_s_batch, [2 x i8]* noalias nocapture align 512 %next_s_row_space, [2 x i16]* noalias nocapture align 512 %next_s_row0, [2 x i16]* noalias nocapture align 512 %next_s_rows, [2 x i16]* noalias nocapture align 512 %next_s_width, [2 x i8]* noalias nocapture align 512 %next_s_content) unnamed_addr #1 {
entry:
  %"(anonymous namespace)::runtime.request_valid.load" = load i1, i1* @"(anonymous namespace)::runtime.request_valid", align 512
  br i1 %"(anonymous namespace)::runtime.request_valid.load", label %lor.lhs.false, label %if.then

lor.lhs.false:                                    ; preds = %entry
  %"(anonymous namespace)::runtime.model_header_valid.load" = load i1, i1* @"(anonymous namespace)::runtime.model_header_valid", align 512
  br i1 %"(anonymous namespace)::runtime.model_header_valid.load", label %lor.lhs.false1, label %if.then

lor.lhs.false1:                                   ; preds = %lor.lhs.false
  %tmp = call fastcc i1 @"laya::full::(anonymous namespace)::qkv_rope_specs"(i8 %old_s_ref_id.0.0.val, i8 %old_s_ref_id.0.1.val, i8 %old_s_ref_bank.0.0.val, i8 %old_s_ref_bank.0.1.val, [2 x i32]* %old_s_ref_epoch, [2 x i8]* %old_s_region, [2 x i8]* %old_s_stage, [2 x i8]* %old_s_layer, [2 x i8]* %old_s_batch, [2 x i8]* %old_s_row_space, [2 x i16]* %old_s_row0, [2 x i16]* %old_s_rows, [2 x i16]* %old_s_width, i8 %old_s_content.0.0.val, i8 %old_s_content.0.1.val, [2 x i8]* %next_s_ref_id, [2 x i8]* %next_s_ref_bank, [2 x i32]* %next_s_ref_epoch, [2 x i8]* %next_s_region, [2 x i8]* %next_s_stage, [2 x i8]* %next_s_layer, [2 x i8]* %next_s_batch, [2 x i8]* %next_s_row_space, [2 x i16]* %next_s_row0, [2 x i16]* %next_s_rows, [2 x i16]* %next_s_width, [2 x i8]* %next_s_content)
  br i1 %tmp, label %if.end, label %if.then

if.then:                                          ; preds = %lor.lhs.false1, %lor.lhs.false, %entry
  br label %return

if.end:                                           ; preds = %lor.lhs.false1
  %old_s_ref_epoch.addr = getelementptr [2 x i32], [2 x i32]* %old_s_ref_epoch, i64 0, i64 0
  %ref.epoch = load i32, i32* %old_s_ref_epoch.addr, align 512
  call void (...) @_ssdm_SpecKeepArrayLoad(i32 %ref.epoch) #1
  %icmp.ln13 = icmp eq i8 %old_s_ref_id.0.0.val, 43
  %icmp.ln17 = icmp eq i8 %old_s_ref_id.0.0.val, 9
  %icmp.ln18 = icmp eq i8 %old_s_ref_id.0.0.val, 6
  br label %for.body.i

for.cond.i:                                       ; preds = %_ZN4laya4full12_GLOBAL__N_113same_physicalENS_9BufferRefEhS2_h.exit.i, %lor.rhs.i.i, %for.body.i.split
  br label %for.body.i, !llvm.loop !11389

for.body.i:                                       ; preds = %for.cond.i, %if.end
  %i = phi i64 [ 0, %if.end ], [ %add.ln116, %for.cond.i ]
  %icmp.ln116 = icmp eq i64 %i, 32
  br i1 %icmp.ln116, label %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit.loopexit, label %for.body.i.split, !llvm.loop !11389

for.body.i.split:                                 ; preds = %for.body.i
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 0, i64 32, i64 16), !fpga.pragma.source !33
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @267)
  %"(anonymous namespace)::runtime.owners.record.ref.id.addr" = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.ref.id", i64 0, i64 %i
  %a.id = load i8, i8* %"(anonymous namespace)::runtime.owners.record.ref.id.addr", align 8, !alias.scope !11396, !noalias !11399
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %a.id) #1
  %icmp.ln118 = icmp eq i8 %a.id, 0
  %add.ln116 = add nuw nsw i64 %i, 1
  br i1 %icmp.ln118, label %for.cond.i, label %land.lhs.true.i

land.lhs.true.i:                                  ; preds = %for.body.i.split
  %"(anonymous namespace)::runtime.owners.record.ref.bank.addr" = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.ref.bank", i64 0, i64 %i
  %a.bank = load i8, i8* %"(anonymous namespace)::runtime.owners.record.ref.bank.addr", align 1, !alias.scope !11396, !noalias !11399
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %a.bank) #1
  %"(anonymous namespace)::runtime.owners.record.region.addr" = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.region", i64 0, i64 %i
  %ar = load i8, i8* %"(anonymous namespace)::runtime.owners.record.region.addr", align 4, !alias.scope !11396, !noalias !11399
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %ar) #1
  %icmp.ln12 = icmp eq i8 %ar, 0
  br i1 %icmp.ln12, label %if.end.i.i, label %_ZN4laya4full12_GLOBAL__N_113same_physicalENS_9BufferRefEhS2_h.exit.i

if.end.i.i:                                       ; preds = %land.lhs.true.i
  %icmp.ln13.28 = icmp eq i8 %a.id, 43
  %and.ln13 = and i1 %icmp.ln13.28, %icmp.ln13
  br i1 %and.ln13, label %_ZN4laya4full12_GLOBAL__N_113same_physicalENS_9BufferRefEhS2_h.exit.i.thread, label %if.end6.i.i

if.end6.i.i:                                      ; preds = %if.end.i.i
  %icmp.ln15 = icmp eq i8 %a.bank, %old_s_ref_bank.0.0.val
  br i1 %icmp.ln15, label %if.end12.i.i, label %_ZN4laya4full12_GLOBAL__N_113same_physicalENS_9BufferRefEhS2_h.exit.i

if.end12.i.i:                                     ; preds = %if.end6.i.i
  %icmp.ln16 = icmp eq i8 %a.id, %old_s_ref_id.0.0.val
  %icmp.ln17.25 = icmp eq i8 %a.id, 6
  %and.ln17 = and i1 %icmp.ln17.25, %icmp.ln17
  %or.ln16 = or i1 %icmp.ln16, %and.ln17
  br i1 %or.ln16, label %_ZN4laya4full12_GLOBAL__N_113same_physicalENS_9BufferRefEhS2_h.exit.i.thread, label %lor.rhs.i.i

lor.rhs.i.i:                                      ; preds = %if.end12.i.i
  %icmp.ln18.25 = icmp eq i8 %a.id, 9
  %and.ln18 = and i1 %icmp.ln18.25, %icmp.ln18
  br i1 %and.ln18, label %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit.loopexit.split.loop.exit11, label %for.cond.i

_ZN4laya4full12_GLOBAL__N_113same_physicalENS_9BufferRefEhS2_h.exit.i.thread: ; preds = %if.end12.i.i, %if.end.i.i
  %indvars.iv.i.lcssa23 = phi i64 [ %i, %if.end12.i.i ], [ %i, %if.end.i.i ]
  %trunc.ln118 = trunc i64 %indvars.iv.i.lcssa23 to i32
  br label %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit

_ZN4laya4full12_GLOBAL__N_113same_physicalENS_9BufferRefEhS2_h.exit.i: ; preds = %if.end6.i.i, %land.lhs.true.i
  br label %for.cond.i

_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit.loopexit.split.loop.exit11: ; preds = %lor.rhs.i.i
  %indvars.iv.i.lcssa24 = phi i64 [ %i, %lor.rhs.i.i ]
  %trunc.ln118.25 = trunc i64 %indvars.iv.i.lcssa24 to i32
  br label %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit

_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit.loopexit: ; preds = %for.body.i
  br label %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit

_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit: ; preds = %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit.loopexit, %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit.loopexit.split.loop.exit11, %_ZN4laya4full12_GLOBAL__N_113same_physicalENS_9BufferRefEhS2_h.exit.i.thread
  %first_index = phi i32 [ %trunc.ln118, %_ZN4laya4full12_GLOBAL__N_113same_physicalENS_9BufferRefEhS2_h.exit.i.thread ], [ %trunc.ln118.25, %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit.loopexit.split.loop.exit11 ], [ 32, %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit.loopexit ]
  %old_s_ref_epoch.addr.1 = getelementptr [2 x i32], [2 x i32]* %old_s_ref_epoch, i64 0, i64 1
  %ref.epoch.1 = load i32, i32* %old_s_ref_epoch.addr.1, align 4
  call void (...) @_ssdm_SpecKeepArrayLoad(i32 %ref.epoch.1) #1
  %icmp.ln13.29 = icmp eq i8 %old_s_ref_id.0.1.val, 43
  %icmp.ln17.26 = icmp eq i8 %old_s_ref_id.0.1.val, 9
  %icmp.ln18.26 = icmp eq i8 %old_s_ref_id.0.1.val, 6
  br label %for.body.i31

for.cond.i26:                                     ; preds = %_ZN4laya4full12_GLOBAL__N_113same_physicalENS_9BufferRefEhS2_h.exit.i59, %lor.rhs.i.i57, %for.body.i31.split
  br label %for.body.i31, !llvm.loop !11403

for.body.i31:                                     ; preds = %for.cond.i26, %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit
  %i.199 = phi i64 [ 0, %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit ], [ %add.ln116.2, %for.cond.i26 ]
  %icmp.ln116.5 = icmp eq i64 %i.199, 32
  br i1 %icmp.ln116.5, label %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit69.loopexit, label %for.body.i31.split, !llvm.loop !11403

for.body.i31.split:                               ; preds = %for.body.i31
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 0, i64 32, i64 16), !fpga.pragma.source !33
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @267)
  %"(anonymous namespace)::runtime.owners.record.ref.id.addr.31" = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.ref.id", i64 0, i64 %i.199
  %a.id.33 = load i8, i8* %"(anonymous namespace)::runtime.owners.record.ref.id.addr.31", align 8, !alias.scope !11407, !noalias !11410
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %a.id.33) #1
  %icmp.ln118.2 = icmp eq i8 %a.id.33, 0
  %add.ln116.2 = add nuw nsw i64 %i.199, 1
  br i1 %icmp.ln118.2, label %for.cond.i26, label %land.lhs.true.i41

land.lhs.true.i41:                                ; preds = %for.body.i31.split
  %"(anonymous namespace)::runtime.owners.record.ref.bank.addr.29" = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.ref.bank", i64 0, i64 %i.199
  %a.bank.29 = load i8, i8* %"(anonymous namespace)::runtime.owners.record.ref.bank.addr.29", align 1, !alias.scope !11407, !noalias !11410
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %a.bank.29) #1
  %"(anonymous namespace)::runtime.owners.record.region.addr.27" = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.region", i64 0, i64 %i.199
  %ar.2 = load i8, i8* %"(anonymous namespace)::runtime.owners.record.region.addr.27", align 4, !alias.scope !11407, !noalias !11410
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %ar.2) #1
  %icmp.ln12.33 = icmp eq i8 %ar.2, 0
  br i1 %icmp.ln12.33, label %if.end.i.i45, label %_ZN4laya4full12_GLOBAL__N_113same_physicalENS_9BufferRefEhS2_h.exit.i59

if.end.i.i45:                                     ; preds = %land.lhs.true.i41
  %icmp.ln13.30 = icmp eq i8 %a.id.33, 43
  %and.ln13.1 = and i1 %icmp.ln13.30, %icmp.ln13.29
  br i1 %and.ln13.1, label %_ZN4laya4full12_GLOBAL__N_113same_physicalENS_9BufferRefEhS2_h.exit.i59.thread, label %if.end6.i.i47

if.end6.i.i47:                                    ; preds = %if.end.i.i45
  %icmp.ln15.2 = icmp eq i8 %a.bank.29, %old_s_ref_bank.0.1.val
  br i1 %icmp.ln15.2, label %if.end12.i.i49, label %_ZN4laya4full12_GLOBAL__N_113same_physicalENS_9BufferRefEhS2_h.exit.i59

if.end12.i.i49:                                   ; preds = %if.end6.i.i47
  %icmp.ln16.4 = icmp eq i8 %a.id.33, %old_s_ref_id.0.1.val
  %icmp.ln17.27 = icmp eq i8 %a.id.33, 6
  %and.ln17.1 = and i1 %icmp.ln17.27, %icmp.ln17.26
  %or.ln16.1 = or i1 %icmp.ln16.4, %and.ln17.1
  br i1 %or.ln16.1, label %_ZN4laya4full12_GLOBAL__N_113same_physicalENS_9BufferRefEhS2_h.exit.i59.thread, label %lor.rhs.i.i57

lor.rhs.i.i57:                                    ; preds = %if.end12.i.i49
  %icmp.ln18.27 = icmp eq i8 %a.id.33, 9
  %and.ln18.2 = and i1 %icmp.ln18.27, %icmp.ln18.26
  br i1 %and.ln18.2, label %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit69.loopexit.split.loop.exit7, label %for.cond.i26

_ZN4laya4full12_GLOBAL__N_113same_physicalENS_9BufferRefEhS2_h.exit.i59.thread: ; preds = %if.end12.i.i49, %if.end.i.i45
  %indvars.iv.i27.lcssa21 = phi i64 [ %i.199, %if.end12.i.i49 ], [ %i.199, %if.end.i.i45 ]
  %trunc.ln118.26 = trunc i64 %indvars.iv.i27.lcssa21 to i32
  br label %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit69

_ZN4laya4full12_GLOBAL__N_113same_physicalENS_9BufferRefEhS2_h.exit.i59: ; preds = %if.end6.i.i47, %land.lhs.true.i41
  br label %for.cond.i26

_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit69.loopexit.split.loop.exit7: ; preds = %lor.rhs.i.i57
  %indvars.iv.i27.lcssa22 = phi i64 [ %i.199, %lor.rhs.i.i57 ]
  %trunc.ln118.27 = trunc i64 %indvars.iv.i27.lcssa22 to i32
  br label %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit69

_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit69.loopexit: ; preds = %for.body.i31
  br label %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit69

_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit69: ; preds = %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit69.loopexit, %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit69.loopexit.split.loop.exit7, %_ZN4laya4full12_GLOBAL__N_113same_physicalENS_9BufferRefEhS2_h.exit.i59.thread
  %second_index = phi i32 [ %trunc.ln118.26, %_ZN4laya4full12_GLOBAL__N_113same_physicalENS_9BufferRefEhS2_h.exit.i59.thread ], [ %trunc.ln118.27, %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit69.loopexit.split.loop.exit7 ], [ 32, %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit69.loopexit ]
  %icmp.ln351 = icmp eq i32 %first_index, 32
  %icmp.ln351.1 = icmp eq i32 %second_index, 32
  %or.ln351 = or i1 %icmp.ln351, %icmp.ln351.1
  br i1 %or.ln351, label %return, label %if.end10

if.end10:                                         ; preds = %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit69
  %zext.ln353 = zext i32 %first_index to i64
  %"(anonymous namespace)::runtime.owners.record.identity.request_id.addr" = getelementptr [32 x i64], [32 x i64]* @"(anonymous namespace)::runtime.owners.record.identity.request_id", i64 0, i64 %zext.ln353
  %"(anonymous namespace)::runtime.owners.record.identity.generation.addr" = getelementptr [32 x i64], [32 x i64]* @"(anonymous namespace)::runtime.owners.record.identity.generation", i64 0, i64 %zext.ln353
  %"(anonymous namespace)::runtime.owners.record.identity.B.addr" = getelementptr [32 x i16], [32 x i16]* @"(anonymous namespace)::runtime.owners.record.identity.B", i64 0, i64 %zext.ln353
  %"(anonymous namespace)::runtime.owners.record.identity.S.addr" = getelementptr [32 x i16], [32 x i16]* @"(anonymous namespace)::runtime.owners.record.identity.S", i64 0, i64 %zext.ln353
  %"(anonymous namespace)::runtime.owners.record.identity.model_tag.addr" = getelementptr [32 x [16 x i8]], [32 x [16 x i8]]* @"(anonymous namespace)::runtime.owners.record.identity.model_tag", i64 0, i64 %zext.ln353
  %"(anonymous namespace)::runtime.owners.record.identity.numeric_tag.addr" = getelementptr [32 x [16 x i8]], [32 x [16 x i8]]* @"(anonymous namespace)::runtime.owners.record.identity.numeric_tag", i64 0, i64 %zext.ln353
  %"(anonymous namespace)::runtime.owners.record.identity.layout_tag.addr" = getelementptr [32 x [16 x i8]], [32 x [16 x i8]]* @"(anonymous namespace)::runtime.owners.record.identity.layout_tag", i64 0, i64 %zext.ln353
  %"(anonymous namespace)::runtime.owners.record.identity.build_tag.addr" = getelementptr [32 x [16 x i8]], [32 x [16 x i8]]* @"(anonymous namespace)::runtime.owners.record.identity.build_tag", i64 0, i64 %zext.ln353
  %"(anonymous namespace)::runtime.owners.record.ref.id.addr.32" = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.ref.id", i64 0, i64 %zext.ln353
  %"(anonymous namespace)::runtime.owners.record.ref.bank.addr.30" = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.ref.bank", i64 0, i64 %zext.ln353
  %"(anonymous namespace)::runtime.owners.record.ref.epoch.addr" = getelementptr [32 x i32], [32 x i32]* @"(anonymous namespace)::runtime.owners.record.ref.epoch", i64 0, i64 %zext.ln353
  %"(anonymous namespace)::runtime.owners.record.lease_old_ref.id.addr" = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.lease_old_ref.id", i64 0, i64 %zext.ln353
  %"(anonymous namespace)::runtime.owners.record.lease_old_ref.bank.addr" = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.lease_old_ref.bank", i64 0, i64 %zext.ln353
  %"(anonymous namespace)::runtime.owners.record.lease_old_ref.epoch.addr" = getelementptr [32 x i32], [32 x i32]* @"(anonymous namespace)::runtime.owners.record.lease_old_ref.epoch", i64 0, i64 %zext.ln353
  %"(anonymous namespace)::runtime.owners.record.max_claimed_epoch.addr" = getelementptr [32 x i32], [32 x i32]* @"(anonymous namespace)::runtime.owners.record.max_claimed_epoch", i64 0, i64 %zext.ln353
  %"(anonymous namespace)::runtime.owners.record.region.addr.28" = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.region", i64 0, i64 %zext.ln353
  %"(anonymous namespace)::runtime.owners.record.stage.addr" = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.stage", i64 0, i64 %zext.ln353
  %"(anonymous namespace)::runtime.owners.record.layer.addr" = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.layer", i64 0, i64 %zext.ln353
  %"(anonymous namespace)::runtime.owners.record.batch.addr" = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.batch", i64 0, i64 %zext.ln353
  %"(anonymous namespace)::runtime.owners.record.row_space.addr" = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.row_space", i64 0, i64 %zext.ln353
  %"(anonymous namespace)::runtime.owners.record.row0.addr" = getelementptr [32 x i16], [32 x i16]* @"(anonymous namespace)::runtime.owners.record.row0", i64 0, i64 %zext.ln353
  %"(anonymous namespace)::runtime.owners.record.rows.addr" = getelementptr [32 x i16], [32 x i16]* @"(anonymous namespace)::runtime.owners.record.rows", i64 0, i64 %zext.ln353
  %"(anonymous namespace)::runtime.owners.record.width.addr" = getelementptr [32 x i16], [32 x i16]* @"(anonymous namespace)::runtime.owners.record.width", i64 0, i64 %zext.ln353
  %"(anonymous namespace)::runtime.owners.record.content.addr" = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.content", i64 0, i64 %zext.ln353
  %"(anonymous namespace)::runtime.owners.record.state.addr" = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.state", i64 0, i64 %zext.ln353
  %"(anonymous namespace)::runtime.owners.record.readers.addr" = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.readers", i64 0, i64 %zext.ln353
  %"(anonymous namespace)::runtime.owners.record.covered_rows.addr" = getelementptr [32 x [64 x i32]], [32 x [64 x i32]]* @"(anonymous namespace)::runtime.owners.record.covered_rows", i64 0, i64 %zext.ln353
  %"(anonymous namespace)::runtime.owners.record.valid.addr" = getelementptr [32 x i1], [32 x i1]* @"(anonymous namespace)::runtime.owners.record.valid", i64 0, i64 %zext.ln353
  %zext.ln354 = zext i32 %second_index to i64
  %"(anonymous namespace)::runtime.owners.record.identity.request_id.addr.2" = getelementptr [32 x i64], [32 x i64]* @"(anonymous namespace)::runtime.owners.record.identity.request_id", i64 0, i64 %zext.ln354
  %"(anonymous namespace)::runtime.owners.record.identity.generation.addr.2" = getelementptr [32 x i64], [32 x i64]* @"(anonymous namespace)::runtime.owners.record.identity.generation", i64 0, i64 %zext.ln354
  %"(anonymous namespace)::runtime.owners.record.identity.B.addr.2" = getelementptr [32 x i16], [32 x i16]* @"(anonymous namespace)::runtime.owners.record.identity.B", i64 0, i64 %zext.ln354
  %"(anonymous namespace)::runtime.owners.record.identity.S.addr.2" = getelementptr [32 x i16], [32 x i16]* @"(anonymous namespace)::runtime.owners.record.identity.S", i64 0, i64 %zext.ln354
  %"(anonymous namespace)::runtime.owners.record.identity.model_tag.addr.17" = getelementptr [32 x [16 x i8]], [32 x [16 x i8]]* @"(anonymous namespace)::runtime.owners.record.identity.model_tag", i64 0, i64 %zext.ln354
  %"(anonymous namespace)::runtime.owners.record.identity.numeric_tag.addr.17" = getelementptr [32 x [16 x i8]], [32 x [16 x i8]]* @"(anonymous namespace)::runtime.owners.record.identity.numeric_tag", i64 0, i64 %zext.ln354
  %"(anonymous namespace)::runtime.owners.record.identity.layout_tag.addr.17" = getelementptr [32 x [16 x i8]], [32 x [16 x i8]]* @"(anonymous namespace)::runtime.owners.record.identity.layout_tag", i64 0, i64 %zext.ln354
  %"(anonymous namespace)::runtime.owners.record.identity.build_tag.addr.17" = getelementptr [32 x [16 x i8]], [32 x [16 x i8]]* @"(anonymous namespace)::runtime.owners.record.identity.build_tag", i64 0, i64 %zext.ln354
  %"(anonymous namespace)::runtime.owners.record.ref.id.addr.33" = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.ref.id", i64 0, i64 %zext.ln354
  %"(anonymous namespace)::runtime.owners.record.ref.bank.addr.31" = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.ref.bank", i64 0, i64 %zext.ln354
  %"(anonymous namespace)::runtime.owners.record.ref.epoch.addr.3" = getelementptr [32 x i32], [32 x i32]* @"(anonymous namespace)::runtime.owners.record.ref.epoch", i64 0, i64 %zext.ln354
  %"(anonymous namespace)::runtime.owners.record.lease_old_ref.id.addr.3" = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.lease_old_ref.id", i64 0, i64 %zext.ln354
  %"(anonymous namespace)::runtime.owners.record.lease_old_ref.bank.addr.3" = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.lease_old_ref.bank", i64 0, i64 %zext.ln354
  %"(anonymous namespace)::runtime.owners.record.lease_old_ref.epoch.addr.3" = getelementptr [32 x i32], [32 x i32]* @"(anonymous namespace)::runtime.owners.record.lease_old_ref.epoch", i64 0, i64 %zext.ln354
  %"(anonymous namespace)::runtime.owners.record.max_claimed_epoch.addr.2" = getelementptr [32 x i32], [32 x i32]* @"(anonymous namespace)::runtime.owners.record.max_claimed_epoch", i64 0, i64 %zext.ln354
  %"(anonymous namespace)::runtime.owners.record.region.addr.29" = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.region", i64 0, i64 %zext.ln354
  %"(anonymous namespace)::runtime.owners.record.stage.addr.2" = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.stage", i64 0, i64 %zext.ln354
  %"(anonymous namespace)::runtime.owners.record.layer.addr.2" = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.layer", i64 0, i64 %zext.ln354
  %"(anonymous namespace)::runtime.owners.record.batch.addr.2" = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.batch", i64 0, i64 %zext.ln354
  %"(anonymous namespace)::runtime.owners.record.row_space.addr.2" = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.row_space", i64 0, i64 %zext.ln354
  %"(anonymous namespace)::runtime.owners.record.row0.addr.2" = getelementptr [32 x i16], [32 x i16]* @"(anonymous namespace)::runtime.owners.record.row0", i64 0, i64 %zext.ln354
  %"(anonymous namespace)::runtime.owners.record.rows.addr.2" = getelementptr [32 x i16], [32 x i16]* @"(anonymous namespace)::runtime.owners.record.rows", i64 0, i64 %zext.ln354
  %"(anonymous namespace)::runtime.owners.record.width.addr.2" = getelementptr [32 x i16], [32 x i16]* @"(anonymous namespace)::runtime.owners.record.width", i64 0, i64 %zext.ln354
  %"(anonymous namespace)::runtime.owners.record.content.addr.2" = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.content", i64 0, i64 %zext.ln354
  %"(anonymous namespace)::runtime.owners.record.state.addr.5" = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.state", i64 0, i64 %zext.ln354
  %"(anonymous namespace)::runtime.owners.record.readers.addr.2" = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.readers", i64 0, i64 %zext.ln354
  %"(anonymous namespace)::runtime.owners.record.covered_rows.addr.69" = getelementptr [32 x [64 x i32]], [32 x [64 x i32]]* @"(anonymous namespace)::runtime.owners.record.covered_rows", i64 0, i64 %zext.ln354
  %"(anonymous namespace)::runtime.owners.record.valid.addr.2" = getelementptr [32 x i1], [32 x i1]* @"(anonymous namespace)::runtime.owners.record.valid", i64 0, i64 %zext.ln354
  %old_s_region.addr = getelementptr [2 x i8], [2 x i8]* %old_s_region, i64 0, i64 0
  %old_s_stage.addr = getelementptr [2 x i8], [2 x i8]* %old_s_stage, i64 0, i64 0
  %old_s_layer.addr = getelementptr [2 x i8], [2 x i8]* %old_s_layer, i64 0, i64 0
  %old_s_batch.addr = getelementptr [2 x i8], [2 x i8]* %old_s_batch, i64 0, i64 0
  %old_s_row_space.addr = getelementptr [2 x i8], [2 x i8]* %old_s_row_space, i64 0, i64 0
  %old_s_row0.addr = getelementptr [2 x i16], [2 x i16]* %old_s_row0, i64 0, i64 0
  %old_s_rows.addr = getelementptr [2 x i16], [2 x i16]* %old_s_rows, i64 0, i64 0
  %old_s_width.addr = getelementptr [2 x i16], [2 x i16]* %old_s_width, i64 0, i64 0
  %old_s_region.load = load i8, i8* %old_s_region.addr, align 512
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %old_s_region.load) #1
  %old_s_stage.load = load i8, i8* %old_s_stage.addr, align 512
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %old_s_stage.load) #1
  %old_s_layer.load = load i8, i8* %old_s_layer.addr, align 512
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %old_s_layer.load) #1
  %old_s_batch.load = load i8, i8* %old_s_batch.addr, align 512
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %old_s_batch.load) #1
  %old_s_row_space.load = load i8, i8* %old_s_row_space.addr, align 512
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %old_s_row_space.load) #1
  %old_s_row0.load = load i16, i16* %old_s_row0.addr, align 512
  call void (...) @_ssdm_SpecKeepArrayLoad(i16 %old_s_row0.load) #1
  %old_s_rows.load = load i16, i16* %old_s_rows.addr, align 512
  call void (...) @_ssdm_SpecKeepArrayLoad(i16 %old_s_rows.load) #1
  %old_s_width.load = load i16, i16* %old_s_width.addr, align 512
  call void (...) @_ssdm_SpecKeepArrayLoad(i16 %old_s_width.load) #1
  %tmp.65 = call fastcc i1 @"laya::full::(anonymous namespace)::same_spec"(i8* %"(anonymous namespace)::runtime.owners.record.ref.id.addr.32", i8* %"(anonymous namespace)::runtime.owners.record.ref.bank.addr.30", i32* %"(anonymous namespace)::runtime.owners.record.ref.epoch.addr", i8* %"(anonymous namespace)::runtime.owners.record.region.addr.28", i8* %"(anonymous namespace)::runtime.owners.record.stage.addr", i8* %"(anonymous namespace)::runtime.owners.record.layer.addr", i8* %"(anonymous namespace)::runtime.owners.record.batch.addr", i8* %"(anonymous namespace)::runtime.owners.record.row_space.addr", i16* %"(anonymous namespace)::runtime.owners.record.row0.addr", i16* %"(anonymous namespace)::runtime.owners.record.rows.addr", i16* %"(anonymous namespace)::runtime.owners.record.width.addr", i8* %"(anonymous namespace)::runtime.owners.record.content.addr", i8 %old_s_ref_id.0.0.val, i8 %old_s_ref_bank.0.0.val, i32 %ref.epoch, i8 %old_s_region.load, i8 %old_s_stage.load, i8 %old_s_layer.load, i8 %old_s_batch.load, i8 %old_s_row_space.load, i16 %old_s_row0.load, i16 %old_s_rows.load, i16 %old_s_width.load, i8 %old_s_content.0.0.val)
  br i1 %tmp.65, label %lor.lhs.false18, label %if.then54

lor.lhs.false18:                                  ; preds = %if.end10
  %old_s_region.addr.1 = getelementptr [2 x i8], [2 x i8]* %old_s_region, i64 0, i64 1
  %old_s_stage.addr.1 = getelementptr [2 x i8], [2 x i8]* %old_s_stage, i64 0, i64 1
  %old_s_layer.addr.1 = getelementptr [2 x i8], [2 x i8]* %old_s_layer, i64 0, i64 1
  %old_s_batch.addr.1 = getelementptr [2 x i8], [2 x i8]* %old_s_batch, i64 0, i64 1
  %old_s_row_space.addr.1 = getelementptr [2 x i8], [2 x i8]* %old_s_row_space, i64 0, i64 1
  %old_s_row0.addr.1 = getelementptr [2 x i16], [2 x i16]* %old_s_row0, i64 0, i64 1
  %old_s_rows.addr.1 = getelementptr [2 x i16], [2 x i16]* %old_s_rows, i64 0, i64 1
  %old_s_width.addr.1 = getelementptr [2 x i16], [2 x i16]* %old_s_width, i64 0, i64 1
  %old_s_region.load.1 = load i8, i8* %old_s_region.addr.1, align 4
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %old_s_region.load.1) #1
  %old_s_stage.load.1 = load i8, i8* %old_s_stage.addr.1, align 1
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %old_s_stage.load.1) #1
  %old_s_layer.load.1 = load i8, i8* %old_s_layer.addr.1, align 2
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %old_s_layer.load.1) #1
  %old_s_batch.load.1 = load i8, i8* %old_s_batch.addr.1, align 1
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %old_s_batch.load.1) #1
  %old_s_row_space.load.1 = load i8, i8* %old_s_row_space.addr.1, align 4
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %old_s_row_space.load.1) #1
  %old_s_row0.load.1 = load i16, i16* %old_s_row0.addr.1, align 2
  call void (...) @_ssdm_SpecKeepArrayLoad(i16 %old_s_row0.load.1) #1
  %old_s_rows.load.1 = load i16, i16* %old_s_rows.addr.1, align 4
  call void (...) @_ssdm_SpecKeepArrayLoad(i16 %old_s_rows.load.1) #1
  %old_s_width.load.1 = load i16, i16* %old_s_width.addr.1, align 2
  call void (...) @_ssdm_SpecKeepArrayLoad(i16 %old_s_width.load.1) #1
  %tmp.66 = call fastcc i1 @"laya::full::(anonymous namespace)::same_spec"(i8* %"(anonymous namespace)::runtime.owners.record.ref.id.addr.33", i8* %"(anonymous namespace)::runtime.owners.record.ref.bank.addr.31", i32* %"(anonymous namespace)::runtime.owners.record.ref.epoch.addr.3", i8* %"(anonymous namespace)::runtime.owners.record.region.addr.29", i8* %"(anonymous namespace)::runtime.owners.record.stage.addr.2", i8* %"(anonymous namespace)::runtime.owners.record.layer.addr.2", i8* %"(anonymous namespace)::runtime.owners.record.batch.addr.2", i8* %"(anonymous namespace)::runtime.owners.record.row_space.addr.2", i16* %"(anonymous namespace)::runtime.owners.record.row0.addr.2", i16* %"(anonymous namespace)::runtime.owners.record.rows.addr.2", i16* %"(anonymous namespace)::runtime.owners.record.width.addr.2", i8* %"(anonymous namespace)::runtime.owners.record.content.addr.2", i8 %old_s_ref_id.0.1.val, i8 %old_s_ref_bank.0.1.val, i32 %ref.epoch.1, i8 %old_s_region.load.1, i8 %old_s_stage.load.1, i8 %old_s_layer.load.1, i8 %old_s_batch.load.1, i8 %old_s_row_space.load.1, i16 %old_s_row0.load.1, i16 %old_s_rows.load.1, i16 %old_s_width.load.1, i8 %old_s_content.0.1.val)
  br i1 %tmp.66, label %lor.lhs.false21, label %if.then54

lor.lhs.false21:                                  ; preds = %lor.lhs.false18
  %"(anonymous namespace)::runtime.owners.record.valid.load" = load i1, i1* %"(anonymous namespace)::runtime.owners.record.valid.addr", align 4
  call void (...) @_ssdm_SpecKeepArrayLoad(i1 %"(anonymous namespace)::runtime.owners.record.valid.load") #1
  br i1 %"(anonymous namespace)::runtime.owners.record.valid.load", label %lor.lhs.false22, label %if.then54

lor.lhs.false22:                                  ; preds = %lor.lhs.false21
  %"(anonymous namespace)::runtime.owners.record.valid.load.1" = load i1, i1* %"(anonymous namespace)::runtime.owners.record.valid.addr.2", align 4
  call void (...) @_ssdm_SpecKeepArrayLoad(i1 %"(anonymous namespace)::runtime.owners.record.valid.load.1") #1
  br i1 %"(anonymous namespace)::runtime.owners.record.valid.load.1", label %lor.lhs.false24, label %if.then54

lor.lhs.false24:                                  ; preds = %lor.lhs.false22
  %"(anonymous namespace)::runtime.owners.record.state.load" = load i8, i8* %"(anonymous namespace)::runtime.owners.record.state.addr", align 1
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %"(anonymous namespace)::runtime.owners.record.state.load") #1
  %icmp.ln357 = icmp eq i8 %"(anonymous namespace)::runtime.owners.record.state.load", 2
  br i1 %icmp.ln357, label %lor.lhs.false26, label %if.then54

lor.lhs.false26:                                  ; preds = %lor.lhs.false24
  %"(anonymous namespace)::runtime.owners.record.state.load.3" = load i8, i8* %"(anonymous namespace)::runtime.owners.record.state.addr.5", align 1
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %"(anonymous namespace)::runtime.owners.record.state.load.3") #1
  %icmp.ln357.1 = icmp eq i8 %"(anonymous namespace)::runtime.owners.record.state.load.3", 2
  br i1 %icmp.ln357.1, label %lor.lhs.false29, label %if.then54

lor.lhs.false29:                                  ; preds = %lor.lhs.false26
  %"(anonymous namespace)::runtime.owners.record.readers.load" = load i8, i8* %"(anonymous namespace)::runtime.owners.record.readers.addr", align 2
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %"(anonymous namespace)::runtime.owners.record.readers.load") #1
  %icmp.ln358 = icmp eq i8 %"(anonymous namespace)::runtime.owners.record.readers.load", 0
  br i1 %icmp.ln358, label %lor.lhs.false30, label %if.then54

lor.lhs.false30:                                  ; preds = %lor.lhs.false29
  %"(anonymous namespace)::runtime.owners.record.readers.load.1" = load i8, i8* %"(anonymous namespace)::runtime.owners.record.readers.addr.2", align 2
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %"(anonymous namespace)::runtime.owners.record.readers.load.1") #1
  %icmp.ln358.1 = icmp eq i8 %"(anonymous namespace)::runtime.owners.record.readers.load.1", 0
  br i1 %icmp.ln358.1, label %lor.lhs.false33, label %if.then54

lor.lhs.false33:                                  ; preds = %lor.lhs.false30
  %"(anonymous namespace)::runtime.owners.record.max_claimed_epoch.load" = load i32, i32* %"(anonymous namespace)::runtime.owners.record.max_claimed_epoch.addr", align 8
  call void (...) @_ssdm_SpecKeepArrayLoad(i32 %"(anonymous namespace)::runtime.owners.record.max_claimed_epoch.load") #1
  %icmp.ln359 = icmp ugt i32 %"(anonymous namespace)::runtime.owners.record.max_claimed_epoch.load", -3
  br i1 %icmp.ln359, label %if.then54, label %lor.lhs.false35

lor.lhs.false35:                                  ; preds = %lor.lhs.false33
  %"(anonymous namespace)::runtime.owners.record.max_claimed_epoch.load.1" = load i32, i32* %"(anonymous namespace)::runtime.owners.record.max_claimed_epoch.addr.2", align 8
  call void (...) @_ssdm_SpecKeepArrayLoad(i32 %"(anonymous namespace)::runtime.owners.record.max_claimed_epoch.load.1") #1
  %icmp.ln360 = icmp ugt i32 %"(anonymous namespace)::runtime.owners.record.max_claimed_epoch.load.1", -3
  br i1 %icmp.ln360, label %if.then54, label %lor.lhs.false38

lor.lhs.false38:                                  ; preds = %lor.lhs.false35
  %tmp.67 = call fastcc i1 @"laya::numeric_identity_equal"(i64* %"(anonymous namespace)::runtime.owners.record.identity.request_id.addr", i64* %"(anonymous namespace)::runtime.owners.record.identity.generation.addr", i16* %"(anonymous namespace)::runtime.owners.record.identity.B.addr", i16* %"(anonymous namespace)::runtime.owners.record.identity.S.addr", [16 x i8]* %"(anonymous namespace)::runtime.owners.record.identity.model_tag.addr", [16 x i8]* %"(anonymous namespace)::runtime.owners.record.identity.numeric_tag.addr", [16 x i8]* %"(anonymous namespace)::runtime.owners.record.identity.layout_tag.addr", [16 x i8]* %"(anonymous namespace)::runtime.owners.record.identity.build_tag.addr")
  br i1 %tmp.67, label %lor.lhs.false41, label %if.then54

lor.lhs.false41:                                  ; preds = %lor.lhs.false38
  %tmp.68 = call fastcc i1 @"laya::numeric_identity_equal"(i64* %"(anonymous namespace)::runtime.owners.record.identity.request_id.addr.2", i64* %"(anonymous namespace)::runtime.owners.record.identity.generation.addr.2", i16* %"(anonymous namespace)::runtime.owners.record.identity.B.addr.2", i16* %"(anonymous namespace)::runtime.owners.record.identity.S.addr.2", [16 x i8]* %"(anonymous namespace)::runtime.owners.record.identity.model_tag.addr.17", [16 x i8]* %"(anonymous namespace)::runtime.owners.record.identity.numeric_tag.addr.17", [16 x i8]* %"(anonymous namespace)::runtime.owners.record.identity.layout_tag.addr.17", [16 x i8]* %"(anonymous namespace)::runtime.owners.record.identity.build_tag.addr.17")
  br i1 %tmp.68, label %lor.lhs.false46, label %if.then54

lor.lhs.false46:                                  ; preds = %lor.lhs.false41
  %tmp.69 = call fastcc i1 @"laya::full::(anonymous namespace)::covered.11"(i8 %old_s_ref_id.0.0.val, i8 %old_s_batch.load, i8 %old_s_row_space.load, i16 %old_s_row0.load, i16 %old_s_rows.load, [64 x i32]* %"(anonymous namespace)::runtime.owners.record.covered_rows.addr")
  br i1 %tmp.69, label %lor.lhs.false49, label %if.then54

lor.lhs.false49:                                  ; preds = %lor.lhs.false46
  %tmp.70 = call fastcc i1 @"laya::full::(anonymous namespace)::covered.11"(i8 %old_s_ref_id.0.1.val, i8 %old_s_batch.load.1, i8 %old_s_row_space.load.1, i16 %old_s_row0.load.1, i16 %old_s_rows.load.1, [64 x i32]* %"(anonymous namespace)::runtime.owners.record.covered_rows.addr.69")
  br i1 %tmp.70, label %if.end55, label %if.then54

if.then54:                                        ; preds = %lor.lhs.false49, %lor.lhs.false46, %lor.lhs.false41, %lor.lhs.false38, %lor.lhs.false35, %lor.lhs.false33, %lor.lhs.false30, %lor.lhs.false29, %lor.lhs.false26, %lor.lhs.false24, %lor.lhs.false22, %lor.lhs.false21, %lor.lhs.false18, %if.end10
  br label %return

if.end55:                                         ; preds = %lor.lhs.false49
  store i8 %old_s_ref_id.0.0.val, i8* %"(anonymous namespace)::runtime.owners.record.lease_old_ref.id.addr", align 32
  store i8 %old_s_ref_bank.0.0.val, i8* %"(anonymous namespace)::runtime.owners.record.lease_old_ref.bank.addr", align 1
  store i32 %ref.epoch, i32* %"(anonymous namespace)::runtime.owners.record.lease_old_ref.epoch.addr", align 4
  %next_s_ref_id.addr = getelementptr [2 x i8], [2 x i8]* %next_s_ref_id, i64 0, i64 0
  %next_s_ref_bank.addr = getelementptr [2 x i8], [2 x i8]* %next_s_ref_bank, i64 0, i64 0
  %next_s_ref_epoch.addr = getelementptr [2 x i32], [2 x i32]* %next_s_ref_epoch, i64 0, i64 0
  %next_s_ref_id.load = load i8, i8* %next_s_ref_id.addr, align 512
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %next_s_ref_id.load) #1
  %next_s_ref_bank.load = load i8, i8* %next_s_ref_bank.addr, align 512
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %next_s_ref_bank.load) #1
  %next_s_ref_epoch.load = load i32, i32* %next_s_ref_epoch.addr, align 512
  call void (...) @_ssdm_SpecKeepArrayLoad(i32 %next_s_ref_epoch.load) #1
  store i8 %next_s_ref_id.load, i8* %"(anonymous namespace)::runtime.owners.record.ref.id.addr.32", align 8
  store i8 %next_s_ref_bank.load, i8* %"(anonymous namespace)::runtime.owners.record.ref.bank.addr.30", align 1
  store i32 %next_s_ref_epoch.load, i32* %"(anonymous namespace)::runtime.owners.record.ref.epoch.addr", align 4
  store i32 %next_s_ref_epoch.load, i32* %"(anonymous namespace)::runtime.owners.record.max_claimed_epoch.addr", align 8
  store i8 3, i8* %"(anonymous namespace)::runtime.owners.record.content.addr", align 8
  store i8 4, i8* %"(anonymous namespace)::runtime.owners.record.state.addr", align 1
  store i1 false, i1* %"(anonymous namespace)::runtime.owners.record.valid.addr", align 4
  br label %for.inc.i

for.inc.i:                                        ; preds = %for.inc.i.split, %if.end55
  %i.200 = phi i64 [ 0, %if.end55 ], [ %add.ln129, %for.inc.i.split ]
  %icmp.ln129 = icmp eq i64 %i.200, 64
  br i1 %icmp.ln129, label %for.inc.i76.preheader, label %for.inc.i.split, !llvm.loop !11414

for.inc.i76.preheader:                            ; preds = %for.inc.i
  br label %for.inc.i76

for.inc.i.split:                                  ; preds = %for.inc.i
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 64, i64 64, i64 64), !fpga.pragma.source !33
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @261)
  %"(anonymous namespace)::runtime.owners.record.covered_rows.addr.70" = getelementptr [32 x [64 x i32]], [32 x [64 x i32]]* @"(anonymous namespace)::runtime.owners.record.covered_rows", i64 0, i64 %zext.ln353, i64 %i.200
  store i32 0, i32* %"(anonymous namespace)::runtime.owners.record.covered_rows.addr.70", align 4, !alias.scope !11418
  %add.ln129 = add nuw nsw i64 %i.200, 1
  br label %for.inc.i, !llvm.loop !11414

for.inc.i76:                                      ; preds = %for.inc.i76.split, %for.inc.i76.preheader
  %i.201 = phi i64 [ %add.ln129.3, %for.inc.i76.split ], [ 0, %for.inc.i76.preheader ]
  %icmp.ln129.9 = icmp eq i64 %i.201, 64
  br i1 %icmp.ln129.9, label %_ZN4laya4full12_GLOBAL__N_110clear_bitsEPj.exit77, label %for.inc.i76.split, !llvm.loop !11421

for.inc.i76.split:                                ; preds = %for.inc.i76
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 64, i64 64, i64 64), !fpga.pragma.source !33
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @261)
  %"(anonymous namespace)::runtime.owners.record.old_consumed_rows.addr" = getelementptr [32 x [64 x i32]], [32 x [64 x i32]]* @"(anonymous namespace)::runtime.owners.record.old_consumed_rows", i64 0, i64 %zext.ln353, i64 %i.201
  store i32 0, i32* %"(anonymous namespace)::runtime.owners.record.old_consumed_rows.addr", align 4, !alias.scope !11425
  %add.ln129.3 = add nuw nsw i64 %i.201, 1
  br label %for.inc.i76, !llvm.loop !11421

_ZN4laya4full12_GLOBAL__N_110clear_bitsEPj.exit77: ; preds = %for.inc.i76
  store i8 %old_s_ref_id.0.1.val, i8* %"(anonymous namespace)::runtime.owners.record.lease_old_ref.id.addr.3", align 32
  store i8 %old_s_ref_bank.0.1.val, i8* %"(anonymous namespace)::runtime.owners.record.lease_old_ref.bank.addr.3", align 1
  store i32 %ref.epoch.1, i32* %"(anonymous namespace)::runtime.owners.record.lease_old_ref.epoch.addr.3", align 4
  %next_s_ref_id.addr.1 = getelementptr [2 x i8], [2 x i8]* %next_s_ref_id, i64 0, i64 1
  %next_s_ref_bank.addr.2 = getelementptr [2 x i8], [2 x i8]* %next_s_ref_bank, i64 0, i64 1
  %next_s_ref_epoch.addr.1 = getelementptr [2 x i32], [2 x i32]* %next_s_ref_epoch, i64 0, i64 1
  %next_s_ref_id.load.1 = load i8, i8* %next_s_ref_id.addr.1, align 1
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %next_s_ref_id.load.1) #1
  %next_s_ref_bank.load.2 = load i8, i8* %next_s_ref_bank.addr.2, align 1
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %next_s_ref_bank.load.2) #1
  %next_s_ref_epoch.load.1 = load i32, i32* %next_s_ref_epoch.addr.1, align 4
  call void (...) @_ssdm_SpecKeepArrayLoad(i32 %next_s_ref_epoch.load.1) #1
  store i8 %next_s_ref_id.load.1, i8* %"(anonymous namespace)::runtime.owners.record.ref.id.addr.33", align 8
  store i8 %next_s_ref_bank.load.2, i8* %"(anonymous namespace)::runtime.owners.record.ref.bank.addr.31", align 1
  store i32 %next_s_ref_epoch.load.1, i32* %"(anonymous namespace)::runtime.owners.record.ref.epoch.addr.3", align 4
  store i32 %next_s_ref_epoch.load.1, i32* %"(anonymous namespace)::runtime.owners.record.max_claimed_epoch.addr.2", align 8
  store i8 3, i8* %"(anonymous namespace)::runtime.owners.record.content.addr.2", align 8
  store i8 4, i8* %"(anonymous namespace)::runtime.owners.record.state.addr.5", align 1
  store i1 false, i1* %"(anonymous namespace)::runtime.owners.record.valid.addr.2", align 4
  br label %for.inc.i82

for.inc.i82:                                      ; preds = %for.inc.i82.split, %_ZN4laya4full12_GLOBAL__N_110clear_bitsEPj.exit77
  %i.202 = phi i64 [ 0, %_ZN4laya4full12_GLOBAL__N_110clear_bitsEPj.exit77 ], [ %add.ln129.4, %for.inc.i82.split ]
  %icmp.ln129.10 = icmp eq i64 %i.202, 64
  br i1 %icmp.ln129.10, label %for.inc.i88.preheader, label %for.inc.i82.split, !llvm.loop !11428

for.inc.i88.preheader:                            ; preds = %for.inc.i82
  br label %for.inc.i88

for.inc.i82.split:                                ; preds = %for.inc.i82
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 64, i64 64, i64 64), !fpga.pragma.source !33
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @261)
  %"(anonymous namespace)::runtime.owners.record.covered_rows.addr.71" = getelementptr [32 x [64 x i32]], [32 x [64 x i32]]* @"(anonymous namespace)::runtime.owners.record.covered_rows", i64 0, i64 %zext.ln354, i64 %i.202
  store i32 0, i32* %"(anonymous namespace)::runtime.owners.record.covered_rows.addr.71", align 4, !alias.scope !11432
  %add.ln129.4 = add nuw nsw i64 %i.202, 1
  br label %for.inc.i82, !llvm.loop !11428

for.inc.i88:                                      ; preds = %for.inc.i88.split, %for.inc.i88.preheader
  %i.203 = phi i64 [ %add.ln129.5, %for.inc.i88.split ], [ 0, %for.inc.i88.preheader ]
  %icmp.ln129.11 = icmp eq i64 %i.203, 64
  br i1 %icmp.ln129.11, label %_ZN4laya4full12_GLOBAL__N_110clear_bitsEPj.exit89, label %for.inc.i88.split, !llvm.loop !11435

for.inc.i88.split:                                ; preds = %for.inc.i88
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 64, i64 64, i64 64), !fpga.pragma.source !33
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @261)
  %"(anonymous namespace)::runtime.owners.record.old_consumed_rows.addr.65" = getelementptr [32 x [64 x i32]], [32 x [64 x i32]]* @"(anonymous namespace)::runtime.owners.record.old_consumed_rows", i64 0, i64 %zext.ln354, i64 %i.203
  store i32 0, i32* %"(anonymous namespace)::runtime.owners.record.old_consumed_rows.addr.65", align 4, !alias.scope !11439
  %add.ln129.5 = add nuw nsw i64 %i.203, 1
  br label %for.inc.i88, !llvm.loop !11435

_ZN4laya4full12_GLOBAL__N_110clear_bitsEPj.exit89: ; preds = %for.inc.i88
  %"(anonymous namespace)::runtime.owner_leases.load" = load i32, i32* @"(anonymous namespace)::runtime.owner_leases", align 512
  %add.ln382 = add i32 %"(anonymous namespace)::runtime.owner_leases.load", 2
  store i32 %add.ln382, i32* @"(anonymous namespace)::runtime.owner_leases", align 512
  br label %for.cond

for.cond:                                         ; preds = %for.inc127, %_ZN4laya4full12_GLOBAL__N_110clear_bitsEPj.exit89
  %idx = phi i64 [ 0, %_ZN4laya4full12_GLOBAL__N_110clear_bitsEPj.exit89 ], [ %add.ln383, %for.inc127 ]
  %icmp.ln383 = icmp eq i64 %idx, 2
  br i1 %icmp.ln383, label %return.loopexit, label %VITIS_LOOP_384_2

VITIS_LOOP_384_2:                                 ; preds = %for.cond
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 2, i64 2, i64 2), !fpga.pragma.source !33
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @251)
  br label %for.cond93

for.cond93:                                       ; preds = %for.inc124, %VITIS_LOOP_384_2
  %idx101 = phi i64 [ 0, %VITIS_LOOP_384_2 ], [ %add.ln384, %for.inc124 ]
  %icmp.ln384 = icmp eq i64 %idx101, 2
  br i1 %icmp.ln384, label %for.inc127, label %VITIS_LOOP_385_3

VITIS_LOOP_385_3:                                 ; preds = %for.cond93
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 2, i64 2, i64 2), !fpga.pragma.source !33
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @250)
  br label %for.cond100

for.cond100:                                      ; preds = %for.inc121, %VITIS_LOOP_385_3
  %idx103 = phi i64 [ 0, %VITIS_LOOP_385_3 ], [ %add.ln385, %for.inc121 ]
  %icmp.ln385 = icmp eq i64 %idx103, 16
  br i1 %icmp.ln385, label %for.inc124, label %VITIS_LOOP_386_4

VITIS_LOOP_386_4:                                 ; preds = %for.cond100
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 16, i64 16, i64 16), !fpga.pragma.source !33
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @249)
  br label %for.cond107

for.cond107:                                      ; preds = %for.inc118, %VITIS_LOOP_386_4
  %idx105 = phi i64 [ 0, %VITIS_LOOP_386_4 ], [ %add.ln386, %for.inc118 ]
  %icmp.ln386 = icmp eq i64 %idx105, 2
  br i1 %icmp.ln386, label %for.inc121, label %VITIS_LOOP_387_5

VITIS_LOOP_387_5:                                 ; preds = %for.cond107
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 2, i64 2, i64 2), !fpga.pragma.source !33
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @248)
  br label %for.cond114

for.cond114:                                      ; preds = %for.inc, %VITIS_LOOP_387_5
  %idx107 = phi i64 [ 0, %VITIS_LOOP_387_5 ], [ %add.ln387, %for.inc ]
  %__begin6 = getelementptr [2 x [2 x [16 x [2 x [32 x i32]]]]], [2 x [2 x [16 x [2 x [32 x i32]]]]]* @"(anonymous namespace)::runtime.owners.qkv_rope_rows", i64 0, i64 %idx, i64 %idx101, i64 %idx103, i64 %idx105, i64 %idx107
  %icmp.ln387 = icmp eq i64 %idx107, 32
  br i1 %icmp.ln387, label %for.inc118, label %for.inc

for.inc:                                          ; preds = %for.cond114
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 32, i64 32, i64 32), !fpga.pragma.source !33
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @247)
  store i32 0, i32* %__begin6, align 4
  %add.ln387 = add nuw nsw i64 %idx107, 1
  br label %for.cond114, !llvm.loop !11442

for.inc118:                                       ; preds = %for.cond114
  %add.ln386 = add nuw nsw i64 %idx105, 1
  br label %for.cond107, !llvm.loop !11455

for.inc121:                                       ; preds = %for.cond107
  %add.ln385 = add nuw nsw i64 %idx103, 1
  br label %for.cond100, !llvm.loop !11459

for.inc124:                                       ; preds = %for.cond100
  %add.ln384 = add nuw nsw i64 %idx101, 1
  br label %for.cond93, !llvm.loop !11463

for.inc127:                                       ; preds = %for.cond93
  %add.ln383 = add nuw nsw i64 %idx, 1
  br label %for.cond, !llvm.loop !11467

return.loopexit:                                  ; preds = %for.cond
  br label %return

return:                                           ; preds = %return.loopexit, %if.then54, %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit69, %if.then
  %storemerge98 = phi i16 [ 5, %if.then ], [ 5, %if.then54 ], [ 5, %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit69 ], [ 0, %return.loopexit ]
  %storemerge95 = phi i32 [ 67436549, %if.then ], [ 67436553, %if.then54 ], [ 67436553, %_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh.exit69 ], [ 0, %return.loopexit ]
  store i16 %storemerge98, i16* %agg.result.0, align 512, !alias.scope !11471, !noalias !2
  store i32 %storemerge95, i32* %agg.result.1, align 512, !alias.scope !11480, !noalias !2
  store i64 -1, i64* %agg.result.2, align 512, !alias.scope !11485, !noalias !2
  ret void
}
