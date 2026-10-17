define internal fastcc zeroext i1 @"laya::full::(anonymous namespace)::qkv_rope_specs"(i8 %old_s_ref_id.0.0.val, i8 %old_s_ref_id.0.1.val, i8 %old_s_ref_bank.0.0.val, i8 %old_s_ref_bank.0.1.val, [2 x i32]* noalias nocapture align 512 %old_s_ref_epoch, [2 x i8]* noalias nocapture align 512 %old_s_region, [2 x i8]* noalias nocapture align 512 %old_s_stage, [2 x i8]* noalias nocapture align 512 %old_s_layer, [2 x i8]* noalias nocapture align 512 %old_s_batch, [2 x i8]* noalias nocapture align 512 %old_s_row_space, [2 x i16]* noalias nocapture align 512 %old_s_row0, [2 x i16]* noalias nocapture align 512 %old_s_rows, [2 x i16]* noalias nocapture align 512 %old_s_width, i8 %old_s_content.0.0.val, i8 %old_s_content.0.1.val, [2 x i8]* noalias nocapture align 512 %next_s_ref_id, [2 x i8]* noalias nocapture align 512 %next_s_ref_bank, [2 x i32]* noalias nocapture align 512 %next_s_ref_epoch, [2 x i8]* noalias nocapture align 512 %next_s_region, [2 x i8]* noalias nocapture align 512 %next_s_stage, [2 x i8]* noalias nocapture align 512 %next_s_layer, [2 x i8]* noalias nocapture align 512 %next_s_batch, [2 x i8]* noalias nocapture align 512 %next_s_row_space, [2 x i16]* noalias nocapture align 512 %next_s_row0, [2 x i16]* noalias nocapture align 512 %next_s_rows, [2 x i16]* noalias nocapture align 512 %next_s_width, [2 x i8]* noalias nocapture align 512 %next_s_content) unnamed_addr #2 {
entry:
  %old_s_ref_epoch.addr = getelementptr [2 x i32], [2 x i32]* %old_s_ref_epoch, i64 0, i64 0
  %old_s_region.addr = getelementptr [2 x i8], [2 x i8]* %old_s_region, i64 0, i64 0
  %old_s_stage.addr = getelementptr [2 x i8], [2 x i8]* %old_s_stage, i64 0, i64 0
  %old_s_layer.addr = getelementptr [2 x i8], [2 x i8]* %old_s_layer, i64 0, i64 0
  %old_s_batch.addr = getelementptr [2 x i8], [2 x i8]* %old_s_batch, i64 0, i64 0
  %old_s_row_space.addr = getelementptr [2 x i8], [2 x i8]* %old_s_row_space, i64 0, i64 0
  %old_s_row0.addr = getelementptr [2 x i16], [2 x i16]* %old_s_row0, i64 0, i64 0
  %old_s_rows.addr = getelementptr [2 x i16], [2 x i16]* %old_s_rows, i64 0, i64 0
  %old_s_width.addr = getelementptr [2 x i16], [2 x i16]* %old_s_width, i64 0, i64 0
  %old_s_ref_epoch.load = load i32, i32* %old_s_ref_epoch.addr, align 512
  call void (...) @_ssdm_SpecKeepArrayLoad(i32 %old_s_ref_epoch.load) #1
  %old_s_region.load = load i8, i8* %old_s_region.addr, align 512
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %old_s_region.load) #1
  %tmp = call fastcc i1 @"laya::full::(anonymous namespace)::legal_spec.9"(i8 %old_s_ref_id.0.0.val, i8 %old_s_ref_bank.0.0.val, i32 %old_s_ref_epoch.load, i8 %old_s_region.load, i8* %old_s_stage.addr, i8* %old_s_batch.addr, i8* %old_s_row_space.addr, i16* %old_s_row0.addr, i16* %old_s_rows.addr, i16* %old_s_width.addr)
  br i1 %tmp, label %land.lhs.true.i, label %if.then

land.lhs.true.i:                                  ; preds = %entry
  %old_s_ref_epoch.addr.2 = getelementptr [2 x i32], [2 x i32]* %old_s_ref_epoch, i64 0, i64 1
  %old_s_region.addr.2 = getelementptr [2 x i8], [2 x i8]* %old_s_region, i64 0, i64 1
  %old_s_stage.addr.2 = getelementptr [2 x i8], [2 x i8]* %old_s_stage, i64 0, i64 1
  %old_s_layer.addr.2 = getelementptr [2 x i8], [2 x i8]* %old_s_layer, i64 0, i64 1
  %old_s_batch.addr.2 = getelementptr [2 x i8], [2 x i8]* %old_s_batch, i64 0, i64 1
  %old_s_row_space.addr.2 = getelementptr [2 x i8], [2 x i8]* %old_s_row_space, i64 0, i64 1
  %old_s_row0.addr.2 = getelementptr [2 x i16], [2 x i16]* %old_s_row0, i64 0, i64 1
  %old_s_rows.addr.2 = getelementptr [2 x i16], [2 x i16]* %old_s_rows, i64 0, i64 1
  %old_s_width.addr.2 = getelementptr [2 x i16], [2 x i16]* %old_s_width, i64 0, i64 1
  %old_s_ref_epoch.load.1 = load i32, i32* %old_s_ref_epoch.addr.2, align 4
  call void (...) @_ssdm_SpecKeepArrayLoad(i32 %old_s_ref_epoch.load.1) #1
  %old_s_region.load.2 = load i8, i8* %old_s_region.addr.2, align 4
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %old_s_region.load.2) #1
  %tmp.73 = call fastcc i1 @"laya::full::(anonymous namespace)::legal_spec.9"(i8 %old_s_ref_id.0.1.val, i8 %old_s_ref_bank.0.1.val, i32 %old_s_ref_epoch.load.1, i8 %old_s_region.load.2, i8* %old_s_stage.addr.2, i8* %old_s_batch.addr.2, i8* %old_s_row_space.addr.2, i16* %old_s_row0.addr.2, i16* %old_s_rows.addr.2, i16* %old_s_width.addr.2)
  %icmp.ln163 = icmp eq i8 %old_s_ref_id.0.0.val, 5
  %and.ln162 = and i1 %tmp.73, %icmp.ln163
  br i1 %and.ln162, label %land.lhs.true5.i, label %if.then

land.lhs.true5.i:                                 ; preds = %land.lhs.true.i
  %icmp.ln163.3 = icmp eq i8 %old_s_ref_id.0.1.val, 5
  %icmp.ln164 = icmp eq i8 %old_s_ref_bank.0.0.val, 0
  %icmp.ln164.3 = icmp eq i8 %old_s_ref_bank.0.1.val, 1
  %icmp.ln165 = icmp eq i8 %old_s_region.load, 0
  %and.ln163 = and i1 %icmp.ln165, %icmp.ln164.3
  %and.ln163.5 = and i1 %icmp.ln163.3, %icmp.ln164
  %and.ln163.6 = and i1 %and.ln163, %and.ln163.5
  br i1 %and.ln163.6, label %land.lhs.true24.i, label %if.then

land.lhs.true24.i:                                ; preds = %land.lhs.true5.i
  %old_s_batch.load = load i8, i8* %old_s_batch.addr, align 512, !alias.scope !12812, !noalias !12815
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %old_s_batch.load) #1
  %old_s_batch.load.2 = load i8, i8* %old_s_batch.addr.2, align 1, !alias.scope !12812, !noalias !12815
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %old_s_batch.load.2) #1
  %and.ln165 = and i8 %old_s_batch.load.2, %old_s_batch.load
  %icmp.ln165.9 = icmp eq i8 %and.ln165, -1
  %old_s_row_space.load = load i8, i8* %old_s_row_space.addr, align 512, !alias.scope !12828, !noalias !12829
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %old_s_row_space.load) #1
  %or.ln165 = or i8 %old_s_row_space.load, %old_s_region.load.2
  %icmp.ln165.10 = icmp eq i8 %or.ln165, 0
  %and.ln165.3 = and i1 %icmp.ln165.10, %icmp.ln165.9
  br i1 %and.ln165.3, label %land.lhs.true41.i, label %if.then

land.lhs.true41.i:                                ; preds = %land.lhs.true24.i
  %old_s_row_space.load.2 = load i8, i8* %old_s_row_space.addr.2, align 4, !alias.scope !12828, !noalias !12829
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %old_s_row_space.load.2) #1
  %icmp.ln168 = icmp eq i8 %old_s_row_space.load.2, 0
  %old_s_row0.load = load i16, i16* %old_s_row0.addr, align 512, !alias.scope !12830, !noalias !12831
  call void (...) @_ssdm_SpecKeepArrayLoad(i16 %old_s_row0.load) #1
  %old_s_row0.load.2 = load i16, i16* %old_s_row0.addr.2, align 2, !alias.scope !12830, !noalias !12831
  call void (...) @_ssdm_SpecKeepArrayLoad(i16 %old_s_row0.load.2) #1
  %or.ln168 = or i16 %old_s_row0.load.2, %old_s_row0.load
  %icmp.ln168.4 = icmp eq i16 %or.ln168, 0
  %and.ln168 = and i1 %icmp.ln168.4, %icmp.ln168
  br i1 %and.ln168, label %land.lhs.true54.i, label %if.then

land.lhs.true54.i:                                ; preds = %land.lhs.true41.i
  %old_s_rows.load = load i16, i16* %old_s_rows.addr, align 512, !alias.scope !12832, !noalias !12833
  call void (...) @_ssdm_SpecKeepArrayLoad(i16 %old_s_rows.load) #1
  %"(anonymous namespace)::runtime.inputs.identity.S.load" = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.S", align 512, !alias.scope !12834, !noalias !12835
  %icmp.ln170 = icmp eq i16 %old_s_rows.load, %"(anonymous namespace)::runtime.inputs.identity.S.load"
  br i1 %icmp.ln170, label %land.lhs.true59.i, label %if.then

land.lhs.true59.i:                                ; preds = %land.lhs.true54.i
  %old_s_rows.load.2 = load i16, i16* %old_s_rows.addr.2, align 4, !alias.scope !12832, !noalias !12833
  call void (...) @_ssdm_SpecKeepArrayLoad(i16 %old_s_rows.load.2) #1
  %icmp.ln171 = icmp eq i16 %old_s_rows.load.2, %old_s_rows.load
  br i1 %icmp.ln171, label %land.lhs.true68.i, label %if.then

land.lhs.true68.i:                                ; preds = %land.lhs.true59.i
  %old_s_stage.load = load i8, i8* %old_s_stage.addr, align 512, !alias.scope !12836, !noalias !12837
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %old_s_stage.load) #1
  %old_s_stage.load.2 = load i8, i8* %old_s_stage.addr.2, align 1, !alias.scope !12836, !noalias !12837
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %old_s_stage.load.2) #1
  %icmp.ln172 = icmp eq i8 %old_s_stage.load, %old_s_stage.load.2
  br i1 %icmp.ln172, label %land.lhs.true75.i, label %if.then

land.lhs.true75.i:                                ; preds = %land.lhs.true68.i
  %old_s_layer.load = load i8, i8* %old_s_layer.addr, align 512, !alias.scope !12838, !noalias !12839
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %old_s_layer.load) #1
  %old_s_layer.load.2 = load i8, i8* %old_s_layer.addr.2, align 2, !alias.scope !12838, !noalias !12839
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %old_s_layer.load.2) #1
  %icmp.ln172.3 = icmp eq i8 %old_s_layer.load, %old_s_layer.load.2
  %old_s_width.load = load i16, i16* %old_s_width.addr, align 512, !alias.scope !12840, !noalias !12841
  call void (...) @_ssdm_SpecKeepArrayLoad(i16 %old_s_width.load) #1
  %icmp.ln173 = icmp eq i16 %old_s_width.load, 64
  %old_s_width.load.2 = load i16, i16* %old_s_width.addr.2, align 2, !alias.scope !12840, !noalias !12841
  call void (...) @_ssdm_SpecKeepArrayLoad(i16 %old_s_width.load.2) #1
  %icmp.ln173.4 = icmp eq i16 %old_s_width.load.2, 64
  %icmp.ln174 = icmp eq i8 %old_s_content.0.0.val, %old_s_content.0.1.val
  %and.ln172 = and i1 %icmp.ln172.3, %icmp.ln173
  %and.ln172.4 = and i1 %icmp.ln174, %icmp.ln173.4
  %and.ln172.5 = and i1 %and.ln172, %and.ln172.4
  br i1 %and.ln172.5, label %land.rhs.i, label %if.then

land.rhs.i:                                       ; preds = %land.lhs.true75.i
  %icmp.ln175 = icmp eq i8 %old_s_stage.load, 2
  %icmp.ln175.3 = icmp eq i8 %old_s_content.0.0.val, 2
  %and.ln175 = and i1 %icmp.ln175, %icmp.ln175.3
  br i1 %and.ln175, label %VITIS_LOOP_183_1, label %lor.rhs.i

lor.rhs.i:                                        ; preds = %land.rhs.i
  %icmp.ln181 = icmp ne i8 %old_s_stage.load, 2
  %icmp.ln182 = icmp ne i8 %old_s_content.0.0.val, 2
  %or.ln181 = or i1 %icmp.ln182, %icmp.ln181
  %icmp.ln181.1 = icmp ne i8 %old_s_stage.load, 4
  %icmp.ln181.2 = icmp ne i8 %old_s_content.0.0.val, 3
  %or.ln181.2 = or i1 %icmp.ln181.2, %icmp.ln181.1
  %or.ln181.3 = or i1 %or.ln181, %or.ln181.2
  br i1 %or.ln181.3, label %if.then, label %VITIS_LOOP_183_1

if.then:                                          ; preds = %lor.rhs.i, %land.lhs.true75.i, %land.lhs.true68.i, %land.lhs.true59.i, %land.lhs.true54.i, %land.lhs.true41.i, %land.lhs.true24.i, %land.lhs.true5.i, %land.lhs.true.i, %entry
  br label %return

VITIS_LOOP_183_1:                                 ; preds = %lor.rhs.i, %land.rhs.i
  br label %for.body

for.cond:                                         ; preds = %lor.lhs.false59
  %icmp.ln183 = icmp ult i32 %shard, 2
  br i1 %icmp.ln183, label %for.body, label %return.loopexit, !llvm.loop !12842

for.body:                                         ; preds = %for.cond, %VITIS_LOOP_183_1
  %shard.01 = phi i32 [ 0, %VITIS_LOOP_183_1 ], [ 1, %for.cond ]
  %zext.ln184 = zext i32 %shard.01 to i64
  %next_s_ref_id.addr = getelementptr [2 x i8], [2 x i8]* %next_s_ref_id, i64 0, i64 %zext.ln184
  %next_s_ref_bank.addr = getelementptr [2 x i8], [2 x i8]* %next_s_ref_bank, i64 0, i64 %zext.ln184
  %next_s_ref_epoch.addr = getelementptr [2 x i32], [2 x i32]* %next_s_ref_epoch, i64 0, i64 %zext.ln184
  %next_s_region.addr = getelementptr [2 x i8], [2 x i8]* %next_s_region, i64 0, i64 %zext.ln184
  %next_s_stage.addr = getelementptr [2 x i8], [2 x i8]* %next_s_stage, i64 0, i64 %zext.ln184
  %next_s_layer.addr = getelementptr [2 x i8], [2 x i8]* %next_s_layer, i64 0, i64 %zext.ln184
  %next_s_batch.addr = getelementptr [2 x i8], [2 x i8]* %next_s_batch, i64 0, i64 %zext.ln184
  %next_s_row_space.addr = getelementptr [2 x i8], [2 x i8]* %next_s_row_space, i64 0, i64 %zext.ln184
  %next_s_row0.addr = getelementptr [2 x i16], [2 x i16]* %next_s_row0, i64 0, i64 %zext.ln184
  %next_s_rows.addr = getelementptr [2 x i16], [2 x i16]* %next_s_rows, i64 0, i64 %zext.ln184
  %next_s_width.addr = getelementptr [2 x i16], [2 x i16]* %next_s_width, i64 0, i64 %zext.ln184
  %next_s_content.addr = getelementptr [2 x i8], [2 x i8]* %next_s_content, i64 0, i64 %zext.ln184
  %next_s_ref_id.load = load i8, i8* %next_s_ref_id.addr, align 1
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %next_s_ref_id.load) #1
  %next_s_ref_bank.load = load i8, i8* %next_s_ref_bank.addr, align 1
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %next_s_ref_bank.load) #1
  %next_s_ref_epoch.load = load i32, i32* %next_s_ref_epoch.addr, align 4
  call void (...) @_ssdm_SpecKeepArrayLoad(i32 %next_s_ref_epoch.load) #1
  %next_s_region.load = load i8, i8* %next_s_region.addr, align 4
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %next_s_region.load) #1
  %tmp.74 = call fastcc i1 @"laya::full::(anonymous namespace)::legal_spec.9"(i8 %next_s_ref_id.load, i8 %next_s_ref_bank.load, i32 %next_s_ref_epoch.load, i8 %next_s_region.load, i8* %next_s_stage.addr, i8* %next_s_batch.addr, i8* %next_s_row_space.addr, i16* %next_s_row0.addr, i16* %next_s_rows.addr, i16* %next_s_width.addr)
  %shard = add nuw nsw i32 %shard.01, 1
  %icmp.ln186 = icmp ne i8 %next_s_ref_id.load, 5
  %zext.ln187 = zext i8 %next_s_ref_bank.load to i32
  %icmp.ln187 = icmp ne i32 %shard.01, %zext.ln187
  %or.ln186 = or i1 %icmp.ln187, %icmp.ln186
  %xor.ln186 = xor i1 %tmp.74, true
  %or.ln186.1 = or i1 %or.ln186, %xor.ln186
  br i1 %or.ln186.1, label %cleanup, label %lor.lhs.false15

lor.lhs.false15:                                  ; preds = %for.body
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 0, i64 2, i64 1), !fpga.pragma.source !33
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @252)
  %old_s_ref_epoch.addr.3 = getelementptr [2 x i32], [2 x i32]* %old_s_ref_epoch, i64 0, i64 %zext.ln184
  %old_s_ref_epoch.load.2 = load i32, i32* %old_s_ref_epoch.addr.3, align 4
  call void (...) @_ssdm_SpecKeepArrayLoad(i32 %old_s_ref_epoch.load.2) #1
  %add.ln187 = add i32 %old_s_ref_epoch.load.2, 1
  %icmp.ln187.1 = icmp eq i32 %next_s_ref_epoch.load, %add.ln187
  br i1 %icmp.ln187.1, label %lor.lhs.false20, label %cleanup

lor.lhs.false20:                                  ; preds = %lor.lhs.false15
  %old_s_region.addr.3 = getelementptr [2 x i8], [2 x i8]* %old_s_region, i64 0, i64 %zext.ln184
  %old_s_region.load.3 = load i8, i8* %old_s_region.addr.3, align 4
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %old_s_region.load.3) #1
  %icmp.ln188 = icmp eq i8 %next_s_region.load, %old_s_region.load.3
  br i1 %icmp.ln188, label %lor.lhs.false25, label %cleanup

lor.lhs.false25:                                  ; preds = %lor.lhs.false20
  %next_s_stage.load = load i8, i8* %next_s_stage.addr, align 1
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %next_s_stage.load) #1
  %old_s_stage.addr.3 = getelementptr [2 x i8], [2 x i8]* %old_s_stage, i64 0, i64 %zext.ln184
  %old_s_stage.load.3 = load i8, i8* %old_s_stage.addr.3, align 1
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %old_s_stage.load.3) #1
  %icmp.ln188.1 = icmp eq i8 %next_s_stage.load, %old_s_stage.load.3
  br i1 %icmp.ln188.1, label %lor.lhs.false31, label %cleanup

lor.lhs.false31:                                  ; preds = %lor.lhs.false25
  %next_s_layer.load = load i8, i8* %next_s_layer.addr, align 2
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %next_s_layer.load) #1
  %old_s_layer.addr.3 = getelementptr [2 x i8], [2 x i8]* %old_s_layer, i64 0, i64 %zext.ln184
  %old_s_layer.load.3 = load i8, i8* %old_s_layer.addr.3, align 2
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %old_s_layer.load.3) #1
  %icmp.ln188.2 = icmp eq i8 %next_s_layer.load, %old_s_layer.load.3
  br i1 %icmp.ln188.2, label %lor.lhs.false36, label %cleanup

lor.lhs.false36:                                  ; preds = %lor.lhs.false31
  %next_s_batch.load = load i8, i8* %next_s_batch.addr, align 1
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %next_s_batch.load) #1
  %old_s_batch.addr.3 = getelementptr [2 x i8], [2 x i8]* %old_s_batch, i64 0, i64 %zext.ln184
  %old_s_batch.load.3 = load i8, i8* %old_s_batch.addr.3, align 1
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %old_s_batch.load.3) #1
  %icmp.ln189 = icmp eq i8 %next_s_batch.load, %old_s_batch.load.3
  br i1 %icmp.ln189, label %lor.lhs.false41, label %cleanup

lor.lhs.false41:                                  ; preds = %lor.lhs.false36
  %next_s_row_space.load = load i8, i8* %next_s_row_space.addr, align 4
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %next_s_row_space.load) #1
  %old_s_row_space.addr.3 = getelementptr [2 x i8], [2 x i8]* %old_s_row_space, i64 0, i64 %zext.ln184
  %old_s_row_space.load.3 = load i8, i8* %old_s_row_space.addr.3, align 4
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %old_s_row_space.load.3) #1
  %icmp.ln189.1 = icmp eq i8 %next_s_row_space.load, %old_s_row_space.load.3
  br i1 %icmp.ln189.1, label %lor.lhs.false44, label %cleanup

lor.lhs.false44:                                  ; preds = %lor.lhs.false41
  %next_s_row0.load = load i16, i16* %next_s_row0.addr, align 2
  call void (...) @_ssdm_SpecKeepArrayLoad(i16 %next_s_row0.load) #1
  %old_s_row0.addr.3 = getelementptr [2 x i16], [2 x i16]* %old_s_row0, i64 0, i64 %zext.ln184
  %old_s_row0.load.3 = load i16, i16* %old_s_row0.addr.3, align 2
  call void (...) @_ssdm_SpecKeepArrayLoad(i16 %old_s_row0.load.3) #1
  %icmp.ln190 = icmp eq i16 %next_s_row0.load, %old_s_row0.load.3
  br i1 %icmp.ln190, label %lor.lhs.false49, label %cleanup

lor.lhs.false49:                                  ; preds = %lor.lhs.false44
  %next_s_rows.load = load i16, i16* %next_s_rows.addr, align 4
  call void (...) @_ssdm_SpecKeepArrayLoad(i16 %next_s_rows.load) #1
  %old_s_rows.addr.3 = getelementptr [2 x i16], [2 x i16]* %old_s_rows, i64 0, i64 %zext.ln184
  %old_s_rows.load.3 = load i16, i16* %old_s_rows.addr.3, align 4
  call void (...) @_ssdm_SpecKeepArrayLoad(i16 %old_s_rows.load.3) #1
  %icmp.ln190.1 = icmp eq i16 %next_s_rows.load, %old_s_rows.load.3
  br i1 %icmp.ln190.1, label %lor.lhs.false54, label %cleanup

lor.lhs.false54:                                  ; preds = %lor.lhs.false49
  %next_s_width.load = load i16, i16* %next_s_width.addr, align 2
  call void (...) @_ssdm_SpecKeepArrayLoad(i16 %next_s_width.load) #1
  %old_s_width.addr.3 = getelementptr [2 x i16], [2 x i16]* %old_s_width, i64 0, i64 %zext.ln184
  %old_s_width.load.3 = load i16, i16* %old_s_width.addr.3, align 2
  call void (...) @_ssdm_SpecKeepArrayLoad(i16 %old_s_width.load.3) #1
  %icmp.ln190.2 = icmp eq i16 %next_s_width.load, %old_s_width.load.3
  br i1 %icmp.ln190.2, label %lor.lhs.false59, label %cleanup

lor.lhs.false59:                                  ; preds = %lor.lhs.false54
  %next_s_content.load = load i8, i8* %next_s_content.addr, align 4
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %next_s_content.load) #1
  %icmp.ln191 = icmp eq i8 %next_s_content.load, 3
  br i1 %icmp.ln191, label %for.cond, label %cleanup

cleanup:                                          ; preds = %lor.lhs.false59, %lor.lhs.false54, %lor.lhs.false49, %lor.lhs.false44, %lor.lhs.false41, %lor.lhs.false36, %lor.lhs.false31, %lor.lhs.false25, %lor.lhs.false20, %lor.lhs.false15, %for.body
  br label %return

return.loopexit:                                  ; preds = %for.cond
  br label %return

return:                                           ; preds = %return.loopexit, %cleanup, %if.then
  %retval.3 = phi i1 [ false, %if.then ], [ false, %cleanup ], [ true, %return.loopexit ]
  ret i1 %retval.3
}
