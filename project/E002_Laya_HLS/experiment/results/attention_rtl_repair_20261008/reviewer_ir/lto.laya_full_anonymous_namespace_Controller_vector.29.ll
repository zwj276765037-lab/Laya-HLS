define internal fastcc void @"laya::full::(anonymous namespace)::Controller::vector.29"(i16* noalias nocapture align 512 %agg.result_code, i32* noalias nocapture align 512 %agg.result_detail, i64* noalias nocapture align 512 %agg.result_bad_element, i8 addrspace(1)* noalias nocapture %embedding, i64 %this_memory.0, i64* noalias nocapture align 512 %this_memory.1, i8 addrspace(1)* noalias nocapture %io, i64 %this_memory.2, i64* noalias nocapture align 512 %this_memory.3, i8 addrspace(1)* noalias nocapture %w_q0, i64 %this_memory.4, i64* noalias nocapture align 512 %this_memory.5, i8 addrspace(1)* noalias nocapture %w_q1, i64 %this_memory.6, i64* noalias nocapture align 512 %this_memory.7, i8 addrspace(1)* noalias nocapture %w_scale, i64 %this_memory.8, i64* noalias nocapture align 512 %this_memory.9, i8 addrspace(1)* noalias nocapture %aux, i64 %this_memory.10, i64* noalias nocapture align 512 %this_memory.11, i8 addrspace(1)* noalias nocapture %state0, i64 %this_memory.12, i64* noalias nocapture align 512 %this_memory.13, i8 addrspace(1)* noalias nocapture %state1, i64 %this_memory.14, i64* noalias nocapture align 512 %this_memory.15, i8 addrspace(1)* noalias nocapture %qkv0, i64 %this_memory.16, i64* noalias nocapture align 512 %this_memory.17, i8 addrspace(1)* noalias nocapture %qkv1, i64 %this_memory.18, i64* noalias nocapture align 512 %this_memory.19, i8 addrspace(1)* noalias nocapture %ff0, i64 %this_memory.20, i64* noalias nocapture align 512 %this_memory.21, i8 addrspace(1)* noalias nocapture %ff1, i64 %this_memory.22, i64* noalias nocapture align 512 %this_memory.23, i8 addrspace(1)* noalias nocapture %att_out, i64 %this_memory.24, i64* noalias nocapture align 512 %this_memory.25, i8* noalias nocapture align 512 %this_error_stage, i8* noalias nocapture align 512 %this_error_op, i32* noalias nocapture align 512 %this_error_task_id, i8* noalias nocapture align 512 %this_current_stage, i8* noalias nocapture align 512 %this_current_op, [23 x i192]* noalias align 512 %hidden, i8 %dst_ref_id, i8 %dst_ref_bank, i32 %dst_ref_epoch, i8* noalias nocapture align 512 %output_ref_id, i8* noalias nocapture align 512 %output_ref_bank, i32* noalias nocapture align 512 %output_ref_epoch, i8* noalias nocapture align 512 %output_region, i8* noalias nocapture align 512 %output_stage, i8* noalias nocapture align 512 %output_layer, i8* noalias nocapture align 512 %output_batch, i8* noalias nocapture align 512 %output_row_space, i16* noalias nocapture align 512 %output_row0, i16* noalias nocapture align 512 %output_rows, i16* noalias nocapture align 512 %output_width, i8* noalias nocapture align 512 %output_content) unnamed_addr #0 {
entry:
  call void (...) @_ssdm_op_SpecBRAMWithByteEnable([23 x i192]* %hidden)
  %ref.tmp48.057 = alloca i16, align 512
  %ref.tmp48.158 = alloca i32, align 512
  %ref.tmp48.259 = alloca i64, align 512
  %ref.tmp63.051 = alloca i16, align 512
  %ref.tmp63.152 = alloca i32, align 512
  %ref.tmp63.253 = alloca i64, align 512
  store i8 3, i8* %this_current_stage, align 512, !alias.scope !14510, !noalias !14513
  store i8 99, i8* %this_current_op, align 512, !alias.scope !14513, !noalias !14510
  %0 = getelementptr [23 x i192], [23 x i192]* %hidden, i64 0, i64 0
  %1 = load i192, i192* %0
  %2 = lshr i192 %1, 96
  %3 = trunc i192 %2 to i8
  %cmp.i = icmp eq i8 %3, 0
  %4 = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.S", align 512
  %cmp6.i = icmp eq i8 %3, 1
  %cond.i = select i1 %cmp6.i, i16 16, i16 1
  %cond7.i = select i1 %cmp.i, i16 %4, i16 %cond.i
  store i8 %dst_ref_id, i8* %output_ref_id, align 512
  store i8 %dst_ref_bank, i8* %output_ref_bank, align 512
  store i32 %dst_ref_epoch, i32* %output_ref_epoch, align 512
  store i8 0, i8* %output_region, align 512
  store i8 3, i8* %output_stage, align 512
  store i8 -1, i8* %output_layer, align 512
  store i8 -1, i8* %output_batch, align 512
  store i8 %3, i8* %output_row_space, align 512
  store i16 0, i16* %output_row0, align 512
  store i16 %cond7.i, i16* %output_rows, align 512
  store i16 1024, i16* %output_width, align 512
  store i8 1, i8* %output_content, align 512
  call fastcc void @"laya::full::full_claim_owner"(i16* %agg.result_code, i32* %agg.result_detail, i64* %agg.result_bad_element, i8 %dst_ref_id, i8 %dst_ref_bank, i32 %dst_ref_epoch, i8 0, i8 3, i8 -1, i8 -1, i8 %3, i16 0, i16 %cond7.i, i16 1024, i8 1)
  %5 = load i16, i16* %agg.result_code, align 512, !alias.scope !14515
  %cmp.i6 = icmp eq i16 %5, 0
  br i1 %cmp.i6, label %if.end, label %return

if.end:                                           ; preds = %entry
  %conv = zext i16 %cond7.i to i32
  %cmp84 = icmp ne i16 %cond7.i, 0
  br label %for.cond

for.cond:                                         ; preds = %for.inc58, %if.end
  %6 = phi i16 [ 0, %if.end ], [ %38, %for.inc58 ]
  %b.0 = phi i32 [ 0, %if.end ], [ %inc, %for.inc58 ]
  %7 = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.B", align 512
  %conv4 = zext i16 %7 to i32
  %cmp5 = icmp uge i32 %b.0, %conv4
  %cmp.i10 = icmp eq i16 %6, 0
  %cmp.i10.not = xor i1 %cmp.i10, true
  %brmerge = or i1 %cmp5, %cmp.i10.not
  br i1 %brmerge, label %for.end60, label %VITIS_LOOP_176_2

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
  %8 = load i32, i32* @"(anonymous namespace)::runtime.last_task_id", align 512, !alias.scope !14518, !noalias !14521
  %add.i = add i32 %8, 1
  %9 = load i192, i192* %0
  %10 = trunc i192 %9 to i8
  %11 = lshr i192 %9, 8
  %12 = trunc i192 %11 to i8
  %13 = lshr i192 %9, 32
  %14 = trunc i192 %13 to i32
  %15 = lshr i192 %9, 64
  %16 = trunc i192 %15 to i8
  %17 = load i1, i1* @"(anonymous namespace)::runtime.request_valid", align 512, !alias.scope !14530, !noalias !14535
  br i1 %17, label %lor.lhs.false.i.i, label %_ZN4laya4full12_GLOBAL__N_110Controller4bindERKNS0_13FullOwnerSpecE.2441.2565.2685.2836.3084.3309.3534.3759.3984.4209.4434.4659.4884.5109.5334.5559.5784.exit

lor.lhs.false.i.i:                                ; preds = %for.body10
  %18 = load i1, i1* @"(anonymous namespace)::runtime.model_header_valid", align 512, !alias.scope !14530, !noalias !14535
  br i1 %18, label %lor.lhs.false1.i.i, label %_ZN4laya4full12_GLOBAL__N_110Controller4bindERKNS0_13FullOwnerSpecE.2441.2565.2685.2836.3084.3309.3534.3759.3984.4209.4434.4659.4884.5109.5334.5559.5784.exit

lor.lhs.false1.i.i:                               ; preds = %lor.lhs.false.i.i
  %19 = call fastcc i1 @"laya::full::(anonymous namespace)::legal_spec.21"([23 x i192]* %hidden)
  %call.i.i.not = xor i1 %19, true
  %cmp.i.i = icmp eq i8 %10, 0
  %or.cond = or i1 %cmp.i.i, %call.i.i.not
  br i1 %or.cond, label %_ZN4laya4full12_GLOBAL__N_110Controller4bindERKNS0_13FullOwnerSpecE.2441.2565.2685.2836.3084.3309.3534.3759.3984.4209.4434.4659.4884.5109.5334.5559.5784.exit, label %lor.lhs.false3.i.i

lor.lhs.false3.i.i:                               ; preds = %lor.lhs.false1.i.i
  %20 = load i8, i8* @"(anonymous namespace)::runtime.expected_task_source_count", align 512, !alias.scope !14530, !noalias !14535
  %cmp4.i.i = icmp ugt i8 %20, 3
  br i1 %cmp4.i.i, label %_ZN4laya4full12_GLOBAL__N_110Controller4bindERKNS0_13FullOwnerSpecE.2441.2565.2685.2836.3084.3309.3534.3759.3984.4209.4434.4659.4884.5109.5334.5559.5784.exit, label %if.then47

_ZN4laya4full12_GLOBAL__N_110Controller4bindERKNS0_13FullOwnerSpecE.2441.2565.2685.2836.3084.3309.3534.3759.3984.4209.4434.4659.4884.5109.5334.5559.5784.exit: ; preds = %lor.lhs.false3.i.i, %lor.lhs.false1.i.i, %lor.lhs.false.i.i, %for.body10
  %conv1.i.i.i.i = zext i8 %10 to i32
  %shl2.i.i.i.i = shl nuw nsw i32 %conv1.i.i.i.i, 16
  %or4.i.i.i.i = or i32 %shl2.i.i.i.i, 67108873
  br label %if.end53

if.then47:                                        ; preds = %lor.lhs.false3.i.i
  %inc.i.i = add nuw nsw i8 %20, 1
  store i8 %inc.i.i, i8* @"(anonymous namespace)::runtime.expected_task_source_count", align 512, !alias.scope !14530, !noalias !14535
  %idxprom.i.i = zext i8 %20 to i64
  %21 = lshr i192 %9, 72
  %22 = trunc i192 %21 to i8
  %23 = lshr i192 %9, 80
  %24 = trunc i192 %23 to i8
  %25 = lshr i192 %9, 88
  %26 = trunc i192 %25 to i8
  %27 = lshr i192 %9, 96
  %28 = trunc i192 %27 to i8
  %29 = lshr i192 %9, 112
  %30 = trunc i192 %29 to i16
  %31 = lshr i192 %9, 128
  %32 = trunc i192 %31 to i16
  %33 = lshr i192 %9, 144
  %34 = trunc i192 %33 to i16
  %35 = lshr i192 %9, 160
  %36 = trunc i192 %35 to i8
  %arrayidx3.0.01.i.i = getelementptr [4 x i8], [4 x i8]* @"(anonymous namespace)::runtime.expected_task_source.ref.id", i64 0, i64 %idxprom.i.i
  store i8 %10, i8* %arrayidx3.0.01.i.i, align 4, !alias.scope !14530, !noalias !14535
  %arrayidx3.0.12.i.i = getelementptr [4 x i8], [4 x i8]* @"(anonymous namespace)::runtime.expected_task_source.ref.bank", i64 0, i64 %idxprom.i.i
  store i8 %12, i8* %arrayidx3.0.12.i.i, align 1, !alias.scope !14530, !noalias !14535
  %arrayidx3.0.23.i.i = getelementptr [4 x i32], [4 x i32]* @"(anonymous namespace)::runtime.expected_task_source.ref.epoch", i64 0, i64 %idxprom.i.i
  store i32 %14, i32* %arrayidx3.0.23.i.i, align 8, !alias.scope !14530, !noalias !14535
  %arrayidx3.14.i.i = getelementptr [4 x i8], [4 x i8]* @"(anonymous namespace)::runtime.expected_task_source.region", i64 0, i64 %idxprom.i.i
  store i8 %16, i8* %arrayidx3.14.i.i, align 4, !alias.scope !14530, !noalias !14535
  %arrayidx3.25.i.i = getelementptr [4 x i8], [4 x i8]* @"(anonymous namespace)::runtime.expected_task_source.stage", i64 0, i64 %idxprom.i.i
  store i8 %22, i8* %arrayidx3.25.i.i, align 1, !alias.scope !14530, !noalias !14535
  %arrayidx3.36.i.i = getelementptr [4 x i8], [4 x i8]* @"(anonymous namespace)::runtime.expected_task_source.layer", i64 0, i64 %idxprom.i.i
  store i8 %24, i8* %arrayidx3.36.i.i, align 2, !alias.scope !14530, !noalias !14535
  %arrayidx3.47.i.i = getelementptr [4 x i8], [4 x i8]* @"(anonymous namespace)::runtime.expected_task_source.batch", i64 0, i64 %idxprom.i.i
  store i8 %26, i8* %arrayidx3.47.i.i, align 1, !alias.scope !14530, !noalias !14535
  %arrayidx3.58.i.i = getelementptr [4 x i8], [4 x i8]* @"(anonymous namespace)::runtime.expected_task_source.row_space", i64 0, i64 %idxprom.i.i
  store i8 %28, i8* %arrayidx3.58.i.i, align 8, !alias.scope !14530, !noalias !14535
  %arrayidx3.69.i.i = getelementptr [4 x i16], [4 x i16]* @"(anonymous namespace)::runtime.expected_task_source.row0", i64 0, i64 %idxprom.i.i
  store i16 %30, i16* %arrayidx3.69.i.i, align 2, !alias.scope !14530, !noalias !14535
  %arrayidx3.710.i.i = getelementptr [4 x i16], [4 x i16]* @"(anonymous namespace)::runtime.expected_task_source.rows", i64 0, i64 %idxprom.i.i
  store i16 %32, i16* %arrayidx3.710.i.i, align 4, !alias.scope !14530, !noalias !14535
  %arrayidx3.811.i.i = getelementptr [4 x i16], [4 x i16]* @"(anonymous namespace)::runtime.expected_task_source.width", i64 0, i64 %idxprom.i.i
  store i16 %34, i16* %arrayidx3.811.i.i, align 2, !alias.scope !14530, !noalias !14535
  %arrayidx3.912.i.i = getelementptr [4 x i8], [4 x i8]* @"(anonymous namespace)::runtime.expected_task_source.content", i64 0, i64 %idxprom.i.i
  store i8 %36, i8* %arrayidx3.912.i.i, align 8, !alias.scope !14530, !noalias !14535
  %conv51 = zext i8 %conv21 to i32
  %mul = mul nuw nsw i32 %conv51, 1024
  call fastcc void @"laya::full::(anonymous namespace)::Controller::issue<laya::VectorTask>"(i16* %ref.tmp48.057, i32* %ref.tmp48.158, i64* %ref.tmp48.259, i8 addrspace(1)* %embedding, i64 %this_memory.0, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i64* %this_memory.5, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i64* %this_memory.7, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i64* %this_memory.9, i8 addrspace(1)* %aux, i64 %this_memory.10, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i32 %add.i, i8 99, i8 3, i8 -1, i8 %conv12, i8 %3, i16 %conv14, i8 %conv21, i8 %10, i8 %12, i32 %14, i8 0, i8 0, i32 0, i8 %dst_ref_id, i8 %dst_ref_bank, i32 %dst_ref_epoch, i16 1024, i8 %16, i8 0, i8 0, i16 -1, i32 %mul)
  %.05 = load i16, i16* %ref.tmp48.057, align 512
  %.17 = load i32, i32* %ref.tmp48.158, align 512
  %.29 = load i64, i64* %ref.tmp48.259, align 512
  br label %if.end53

if.end53:                                         ; preds = %if.then47, %_ZN4laya4full12_GLOBAL__N_110Controller4bindERKNS0_13FullOwnerSpecE.2441.2565.2685.2836.3084.3309.3534.3759.3984.4209.4434.4659.4884.5109.5334.5559.5784.exit
  %.2914 = phi i64 [ %.29, %if.then47 ], [ -1, %_ZN4laya4full12_GLOBAL__N_110Controller4bindERKNS0_13FullOwnerSpecE.2441.2565.2685.2836.3084.3309.3534.3759.3984.4209.4434.4659.4884.5109.5334.5559.5784.exit ]
  %.1713 = phi i32 [ %.17, %if.then47 ], [ %or4.i.i.i.i, %_ZN4laya4full12_GLOBAL__N_110Controller4bindERKNS0_13FullOwnerSpecE.2441.2565.2685.2836.3084.3309.3534.3759.3984.4209.4434.4659.4884.5109.5334.5559.5784.exit ]
  %37 = phi i16 [ %.05, %if.then47 ], [ 5, %_ZN4laya4full12_GLOBAL__N_110Controller4bindERKNS0_13FullOwnerSpecE.2441.2565.2685.2836.3084.3309.3534.3759.3984.4209.4434.4659.4884.5109.5334.5559.5784.exit ]
  %cmp.i9 = icmp eq i16 %37, 0
  %spec.select = select i1 %cmp.i9, i1 true, i1 false
  %add = add nuw nsw i32 %row.05, 16
  %cmp8 = icmp ult i32 %add, %conv
  %or.cond11 = and i1 %spec.select, %cmp8
  br i1 %or.cond11, label %for.body10, label %for.inc58.loopexit, !llvm.loop !14544

for.inc58.loopexit:                               ; preds = %if.end53
  store i16 %37, i16* %agg.result_code, align 512
  store i32 %.1713, i32* %agg.result_detail, align 512
  store i64 %.2914, i64* %agg.result_bad_element, align 512
  br label %for.inc58

for.inc58:                                        ; preds = %for.inc58.loopexit, %VITIS_LOOP_176_2
  %38 = phi i16 [ 0, %VITIS_LOOP_176_2 ], [ %37, %for.inc58.loopexit ]
  %inc = add nuw nsw i32 %b.0, 1
  br label %for.cond, !llvm.loop !14672

for.end60:                                        ; preds = %for.cond
  br i1 %cmp.i10, label %if.then62, label %if.end65

if.then62:                                        ; preds = %for.end60
  call fastcc void @"laya::full::full_publish_owner"(i16* %ref.tmp63.051, i32* %ref.tmp63.152, i64* %ref.tmp63.253, i8 %dst_ref_id, i8 %dst_ref_bank, i32 %dst_ref_epoch, i8 0, i8 3, i8 -1, i8 -1, i8 %3, i16 0, i16 %cond7.i, i16 1024, i8 1)
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
