define internal fastcc zeroext i1 @"laya::full::(anonymous namespace)::qkv_rope_specs"(i8 %old_s_ref_id.0.0.val, i8 %old_s_ref_id.0.1.val, i8 %old_s_ref_bank.0.0.val, i8 %old_s_ref_bank.0.1.val, [2 x i32]* noalias nocapture align 512 %old_s_ref_epoch, [2 x i8]* noalias nocapture align 512 %old_s_region, [2 x i8]* noalias nocapture align 512 %old_s_stage, [2 x i8]* noalias nocapture align 512 %old_s_layer, [2 x i8]* noalias nocapture align 512 %old_s_batch, [2 x i8]* noalias nocapture align 512 %old_s_row_space, [2 x i16]* noalias nocapture align 512 %old_s_row0, [2 x i16]* noalias nocapture align 512 %old_s_rows, [2 x i16]* noalias nocapture align 512 %old_s_width, i8 %old_s_content.0.0.val, i8 %old_s_content.0.1.val, [2 x i8]* noalias nocapture align 512 %next_s_ref_id, [2 x i8]* noalias nocapture align 512 %next_s_ref_bank, [2 x i32]* noalias nocapture align 512 %next_s_ref_epoch, [2 x i8]* noalias nocapture align 512 %next_s_region, [2 x i8]* noalias nocapture align 512 %next_s_stage, [2 x i8]* noalias nocapture align 512 %next_s_layer, [2 x i8]* noalias nocapture align 512 %next_s_batch, [2 x i8]* noalias nocapture align 512 %next_s_row_space, [2 x i16]* noalias nocapture align 512 %next_s_row0, [2 x i16]* noalias nocapture align 512 %next_s_rows, [2 x i16]* noalias nocapture align 512 %next_s_width, [2 x i8]* noalias nocapture align 512 %next_s_content) unnamed_addr #2 {
entry:
  %arrayidx.0.2.i = getelementptr [2 x i32], [2 x i32]* %old_s_ref_epoch, i64 0, i64 0
  %arrayidx.1.i = getelementptr [2 x i8], [2 x i8]* %old_s_region, i64 0, i64 0
  %arrayidx.2.i = getelementptr [2 x i8], [2 x i8]* %old_s_stage, i64 0, i64 0
  %arrayidx.3.i = getelementptr [2 x i8], [2 x i8]* %old_s_layer, i64 0, i64 0
  %arrayidx.4.i = getelementptr [2 x i8], [2 x i8]* %old_s_batch, i64 0, i64 0
  %arrayidx.5.i = getelementptr [2 x i8], [2 x i8]* %old_s_row_space, i64 0, i64 0
  %arrayidx.6.i = getelementptr [2 x i16], [2 x i16]* %old_s_row0, i64 0, i64 0
  %arrayidx.7.i = getelementptr [2 x i16], [2 x i16]* %old_s_rows, i64 0, i64 0
  %arrayidx.8.i = getelementptr [2 x i16], [2 x i16]* %old_s_width, i64 0, i64 0
  %arrayidx.0.2.i.val = load i32, i32* %arrayidx.0.2.i, align 512
  %arrayidx.1.i.val = load i8, i8* %arrayidx.1.i, align 512
  %0 = call fastcc i1 @"laya::full::(anonymous namespace)::legal_spec.9"(i8 %old_s_ref_id.0.0.val, i8 %old_s_ref_bank.0.0.val, i32 %arrayidx.0.2.i.val, i8 %arrayidx.1.i.val, i8* %arrayidx.2.i, i8* %arrayidx.4.i, i8* %arrayidx.5.i, i16* %arrayidx.6.i, i16* %arrayidx.7.i, i16* %arrayidx.8.i)
  br i1 %0, label %land.lhs.true.i, label %if.then

land.lhs.true.i:                                  ; preds = %entry
  %arrayidx1.0.2.i = getelementptr [2 x i32], [2 x i32]* %old_s_ref_epoch, i64 0, i64 1
  %arrayidx1.1.i = getelementptr [2 x i8], [2 x i8]* %old_s_region, i64 0, i64 1
  %arrayidx1.2.i = getelementptr [2 x i8], [2 x i8]* %old_s_stage, i64 0, i64 1
  %arrayidx1.3.i = getelementptr [2 x i8], [2 x i8]* %old_s_layer, i64 0, i64 1
  %arrayidx1.4.i = getelementptr [2 x i8], [2 x i8]* %old_s_batch, i64 0, i64 1
  %arrayidx1.5.i = getelementptr [2 x i8], [2 x i8]* %old_s_row_space, i64 0, i64 1
  %arrayidx1.6.i = getelementptr [2 x i16], [2 x i16]* %old_s_row0, i64 0, i64 1
  %arrayidx1.7.i = getelementptr [2 x i16], [2 x i16]* %old_s_rows, i64 0, i64 1
  %arrayidx1.8.i = getelementptr [2 x i16], [2 x i16]* %old_s_width, i64 0, i64 1
  %arrayidx1.0.2.i.val = load i32, i32* %arrayidx1.0.2.i, align 4
  %arrayidx1.1.i.val = load i8, i8* %arrayidx1.1.i, align 4
  %1 = call fastcc i1 @"laya::full::(anonymous namespace)::legal_spec.9"(i8 %old_s_ref_id.0.1.val, i8 %old_s_ref_bank.0.1.val, i32 %arrayidx1.0.2.i.val, i8 %arrayidx1.1.i.val, i8* %arrayidx1.2.i, i8* %arrayidx1.4.i, i8* %arrayidx1.5.i, i16* %arrayidx1.6.i, i16* %arrayidx1.7.i, i16* %arrayidx1.8.i)
  %cmp.i = icmp eq i8 %old_s_ref_id.0.0.val, 5
  %or.cond9.i = and i1 %1, %cmp.i
  br i1 %or.cond9.i, label %land.lhs.true5.i, label %if.then

land.lhs.true5.i:                                 ; preds = %land.lhs.true.i
  %cmp9.i = icmp eq i8 %old_s_ref_id.0.1.val, 5
  %cmp13.i = icmp eq i8 %old_s_ref_bank.0.0.val, 0
  %cmp19.i = icmp eq i8 %old_s_ref_bank.0.1.val, 1
  %cmp23.i = icmp eq i8 %arrayidx.1.i.val, 0
  %thr.and3 = and i1 %cmp23.i, %cmp19.i
  %thr.and4 = and i1 %cmp9.i, %cmp13.i
  %thr.and5 = and i1 %thr.and3, %thr.and4
  br i1 %thr.and5, label %land.lhs.true24.i, label %if.then

land.lhs.true24.i:                                ; preds = %land.lhs.true5.i
  %2 = load i8, i8* %arrayidx.4.i, align 512, !alias.scope !4152, !noalias !4155
  %3 = load i8, i8* %arrayidx1.4.i, align 1, !alias.scope !4152, !noalias !4155
  %4 = and i8 %2, %3
  %5 = icmp eq i8 %4, -1
  %6 = load i8, i8* %arrayidx.5.i, align 512, !alias.scope !4168, !noalias !4169
  %7 = or i8 %arrayidx1.1.i.val, %6
  %8 = icmp eq i8 %7, 0
  %9 = and i1 %8, %5
  br i1 %9, label %land.lhs.true41.i, label %if.then

land.lhs.true41.i:                                ; preds = %land.lhs.true24.i
  %10 = load i8, i8* %arrayidx1.5.i, align 4, !alias.scope !4168, !noalias !4169
  %cmp44.i = icmp eq i8 %10, 0
  %11 = load i16, i16* %arrayidx.6.i, align 512, !alias.scope !4170, !noalias !4171
  %12 = load i16, i16* %arrayidx1.6.i, align 2, !alias.scope !4170, !noalias !4171
  %13 = or i16 %11, %12
  %14 = icmp eq i16 %13, 0
  %15 = and i1 %14, %cmp44.i
  br i1 %15, label %land.lhs.true54.i, label %if.then

land.lhs.true54.i:                                ; preds = %land.lhs.true41.i
  %16 = load i16, i16* %arrayidx.7.i, align 512, !alias.scope !4172, !noalias !4173
  %17 = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.S", align 512, !alias.scope !4174, !noalias !4175
  %cmp58.i = icmp eq i16 %16, %17
  br i1 %cmp58.i, label %land.lhs.true59.i, label %if.then

land.lhs.true59.i:                                ; preds = %land.lhs.true54.i
  %18 = load i16, i16* %arrayidx1.7.i, align 4, !alias.scope !4172, !noalias !4173
  %cmp67.i = icmp eq i16 %18, %16
  br i1 %cmp67.i, label %land.lhs.true68.i, label %if.then

land.lhs.true68.i:                                ; preds = %land.lhs.true59.i
  %19 = load i8, i8* %arrayidx.2.i, align 512, !alias.scope !4176, !noalias !4177
  %20 = load i8, i8* %arrayidx1.2.i, align 1, !alias.scope !4176, !noalias !4177
  %cmp74.i = icmp eq i8 %19, %20
  br i1 %cmp74.i, label %land.lhs.true75.i, label %if.then

land.lhs.true75.i:                                ; preds = %land.lhs.true68.i
  %21 = load i8, i8* %arrayidx.3.i, align 512, !alias.scope !4178, !noalias !4179
  %22 = load i8, i8* %arrayidx1.3.i, align 2, !alias.scope !4178, !noalias !4179
  %cmp81.i = icmp eq i8 %21, %22
  %23 = load i16, i16* %arrayidx.8.i, align 512, !alias.scope !4180, !noalias !4181
  %cmp85.i = icmp eq i16 %23, 64
  %24 = load i16, i16* %arrayidx1.8.i, align 2, !alias.scope !4180, !noalias !4181
  %cmp90.i = icmp eq i16 %24, 64
  %cmp95.i = icmp eq i8 %old_s_content.0.0.val, %old_s_content.0.1.val
  %thr.and = and i1 %cmp81.i, %cmp85.i
  %thr.and6 = and i1 %cmp95.i, %cmp90.i
  %thr.and7 = and i1 %thr.and, %thr.and6
  br i1 %thr.and7, label %land.rhs.i, label %if.then

land.rhs.i:                                       ; preds = %land.lhs.true75.i
  %cmp99.i = icmp eq i8 %19, 2
  %cmp103.i = icmp eq i8 %old_s_content.0.0.val, 2
  %or.cond8.i = and i1 %cmp99.i, %cmp103.i
  br i1 %or.cond8.i, label %VITIS_LOOP_183_1, label %lor.rhs.i

lor.rhs.i:                                        ; preds = %land.rhs.i
  %cmp107.i = icmp eq i8 %19, 4
  %cmp111.i = icmp eq i8 %old_s_content.0.0.val, 3
  %spec.select.i = select i1 %cmp107.i, i1 %cmp111.i, i1 false
  %cmp = icmp ne i8 %19, 2
  %cmp3 = icmp ne i8 %old_s_content.0.0.val, 2
  %thr.or8 = or i1 %cmp3, %cmp
  %thr.xor9 = xor i1 %spec.select.i, true
  %thr.or10 = or i1 %thr.or8, %thr.xor9
  br i1 %thr.or10, label %if.then, label %VITIS_LOOP_183_1

if.then:                                          ; preds = %lor.rhs.i, %land.lhs.true75.i, %land.lhs.true68.i, %land.lhs.true59.i, %land.lhs.true54.i, %land.lhs.true41.i, %land.lhs.true24.i, %land.lhs.true5.i, %land.lhs.true.i, %entry
  br label %return

VITIS_LOOP_183_1:                                 ; preds = %lor.rhs.i, %land.rhs.i
  br label %for.body

for.cond:                                         ; preds = %lor.lhs.false59
  %cmp4 = icmp ult i32 %inc, 2
  br i1 %cmp4, label %for.body, label %cleanup65.loopexit, !llvm.loop !4182

for.body:                                         ; preds = %for.cond, %VITIS_LOOP_183_1
  %shard.01 = phi i32 [ 0, %VITIS_LOOP_183_1 ], [ 1, %for.cond ]
  %idxprom = zext i32 %shard.01 to i64
  %arrayidx7.0.0 = getelementptr [2 x i8], [2 x i8]* %next_s_ref_id, i64 0, i64 %idxprom
  %arrayidx7.0.1 = getelementptr [2 x i8], [2 x i8]* %next_s_ref_bank, i64 0, i64 %idxprom
  %arrayidx7.0.2 = getelementptr [2 x i32], [2 x i32]* %next_s_ref_epoch, i64 0, i64 %idxprom
  %arrayidx7.1 = getelementptr [2 x i8], [2 x i8]* %next_s_region, i64 0, i64 %idxprom
  %arrayidx7.2 = getelementptr [2 x i8], [2 x i8]* %next_s_stage, i64 0, i64 %idxprom
  %arrayidx7.3 = getelementptr [2 x i8], [2 x i8]* %next_s_layer, i64 0, i64 %idxprom
  %arrayidx7.4 = getelementptr [2 x i8], [2 x i8]* %next_s_batch, i64 0, i64 %idxprom
  %arrayidx7.5 = getelementptr [2 x i8], [2 x i8]* %next_s_row_space, i64 0, i64 %idxprom
  %arrayidx7.6 = getelementptr [2 x i16], [2 x i16]* %next_s_row0, i64 0, i64 %idxprom
  %arrayidx7.7 = getelementptr [2 x i16], [2 x i16]* %next_s_rows, i64 0, i64 %idxprom
  %arrayidx7.8 = getelementptr [2 x i16], [2 x i16]* %next_s_width, i64 0, i64 %idxprom
  %arrayidx7.9 = getelementptr [2 x i8], [2 x i8]* %next_s_content, i64 0, i64 %idxprom
  %arrayidx7.0.0.val = load i8, i8* %arrayidx7.0.0, align 1
  %arrayidx7.0.1.val = load i8, i8* %arrayidx7.0.1, align 1
  %arrayidx7.0.2.val = load i32, i32* %arrayidx7.0.2, align 4
  %arrayidx7.1.val = load i8, i8* %arrayidx7.1, align 4
  %25 = call fastcc i1 @"laya::full::(anonymous namespace)::legal_spec.9"(i8 %arrayidx7.0.0.val, i8 %arrayidx7.0.1.val, i32 %arrayidx7.0.2.val, i8 %arrayidx7.1.val, i8* %arrayidx7.2, i8* %arrayidx7.4, i8* %arrayidx7.5, i16* %arrayidx7.6, i16* %arrayidx7.7, i16* %arrayidx7.8)
  %inc = add nuw nsw i32 %shard.01, 1
  %cmp10 = icmp ne i8 %arrayidx7.0.0.val, 5
  %conv13 = zext i8 %arrayidx7.0.1.val to i32
  %cmp14 = icmp ne i32 %shard.01, %conv13
  %thr.or = or i1 %cmp14, %cmp10
  %thr.xor = xor i1 %25, true
  %thr.or11 = or i1 %thr.or, %thr.xor
  br i1 %thr.or11, label %cleanup, label %lor.lhs.false15

lor.lhs.false15:                                  ; preds = %for.body
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 0, i64 2, i64 1), !fpga.pragma.source !33
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @122)
  %epoch1810 = getelementptr [2 x i32], [2 x i32]* %old_s_ref_epoch, i64 0, i64 %idxprom
  %26 = load i32, i32* %epoch1810, align 4
  %add = add i32 %26, 1
  %cmp19 = icmp ne i32 %arrayidx7.0.2.val, %add
  br i1 %cmp19, label %cleanup, label %lor.lhs.false20

lor.lhs.false20:                                  ; preds = %lor.lhs.false15
  %region2212 = getelementptr [2 x i8], [2 x i8]* %old_s_region, i64 0, i64 %idxprom
  %27 = load i8, i8* %region2212, align 4
  %cmp24 = icmp ne i8 %arrayidx7.1.val, %27
  br i1 %cmp24, label %cleanup, label %lor.lhs.false25

lor.lhs.false25:                                  ; preds = %lor.lhs.false20
  %28 = load i8, i8* %arrayidx7.2, align 1
  %stage2814 = getelementptr [2 x i8], [2 x i8]* %old_s_stage, i64 0, i64 %idxprom
  %29 = load i8, i8* %stage2814, align 1
  %cmp30 = icmp ne i8 %28, %29
  br i1 %cmp30, label %cleanup, label %lor.lhs.false31

lor.lhs.false31:                                  ; preds = %lor.lhs.false25
  %30 = load i8, i8* %arrayidx7.3, align 2
  %layer3316 = getelementptr [2 x i8], [2 x i8]* %old_s_layer, i64 0, i64 %idxprom
  %31 = load i8, i8* %layer3316, align 2
  %cmp35 = icmp ne i8 %30, %31
  br i1 %cmp35, label %cleanup, label %lor.lhs.false36

lor.lhs.false36:                                  ; preds = %lor.lhs.false31
  %32 = load i8, i8* %arrayidx7.4, align 1
  %batch3818 = getelementptr [2 x i8], [2 x i8]* %old_s_batch, i64 0, i64 %idxprom
  %33 = load i8, i8* %batch3818, align 1
  %cmp40 = icmp ne i8 %32, %33
  br i1 %cmp40, label %cleanup, label %lor.lhs.false41

lor.lhs.false41:                                  ; preds = %lor.lhs.false36
  %34 = load i8, i8* %arrayidx7.5, align 4
  %row_space4220 = getelementptr [2 x i8], [2 x i8]* %old_s_row_space, i64 0, i64 %idxprom
  %35 = load i8, i8* %row_space4220, align 4
  %cmp43 = icmp ne i8 %34, %35
  br i1 %cmp43, label %cleanup, label %lor.lhs.false44

lor.lhs.false44:                                  ; preds = %lor.lhs.false41
  %36 = load i16, i16* %arrayidx7.6, align 2
  %row04622 = getelementptr [2 x i16], [2 x i16]* %old_s_row0, i64 0, i64 %idxprom
  %37 = load i16, i16* %row04622, align 2
  %cmp48 = icmp ne i16 %36, %37
  br i1 %cmp48, label %cleanup, label %lor.lhs.false49

lor.lhs.false49:                                  ; preds = %lor.lhs.false44
  %38 = load i16, i16* %arrayidx7.7, align 4
  %rows5124 = getelementptr [2 x i16], [2 x i16]* %old_s_rows, i64 0, i64 %idxprom
  %39 = load i16, i16* %rows5124, align 4
  %cmp53 = icmp ne i16 %38, %39
  br i1 %cmp53, label %cleanup, label %lor.lhs.false54

lor.lhs.false54:                                  ; preds = %lor.lhs.false49
  %40 = load i16, i16* %arrayidx7.8, align 2
  %width5626 = getelementptr [2 x i16], [2 x i16]* %old_s_width, i64 0, i64 %idxprom
  %41 = load i16, i16* %width5626, align 2
  %cmp58 = icmp ne i16 %40, %41
  br i1 %cmp58, label %cleanup, label %lor.lhs.false59

lor.lhs.false59:                                  ; preds = %lor.lhs.false54
  %42 = load i8, i8* %arrayidx7.9, align 4
  %cmp61 = icmp ne i8 %42, 3
  br i1 %cmp61, label %cleanup, label %for.cond

cleanup:                                          ; preds = %lor.lhs.false59, %lor.lhs.false54, %lor.lhs.false49, %lor.lhs.false44, %lor.lhs.false41, %lor.lhs.false36, %lor.lhs.false31, %lor.lhs.false25, %lor.lhs.false20, %lor.lhs.false15, %for.body
  br label %cleanup65

cleanup65.loopexit:                               ; preds = %for.cond
  br label %cleanup65

cleanup65:                                        ; preds = %cleanup65.loopexit, %cleanup
  %cleanup.dest.slot.1 = phi i32 [ 1, %cleanup ], [ 3, %cleanup65.loopexit ]
  %cleanup.dest.slot.1.off = add nsw i32 %cleanup.dest.slot.1, -3
  %switch = icmp ult i32 %cleanup.dest.slot.1.off, 1
  %spec.select = select i1 %switch, i1 true, i1 false
  br label %return

return:                                           ; preds = %cleanup65, %if.then
  %retval.3 = phi i1 [ false, %if.then ], [ %spec.select, %cleanup65 ]
  ret i1 %retval.3
}
