define internal fastcc void @"(anonymous namespace)::vector_impl"(i16* noalias nocapture align 512 %agg.result_code, i32* noalias nocapture align 512 %agg.result_detail, i64* noalias nocapture align 512 %agg.result_bad_element, i8 zeroext %op, i8 %src0_ref_bank.val, i32 %src0_ref_epoch.val, i1 zeroext %src1_present, i8 %src1_ref_id.val, i8 %src1_ref_bank.val, i32 %src1_ref_epoch.val, i8 %src1_region.val, i8 zeroext %layer, i32* noalias nocapture align 512 %probe_issued_ctx_task_id, i8* noalias nocapture align 512 %probe_issued_ctx_op, i8* noalias nocapture align 512 %probe_issued_ctx_stage, i8* noalias nocapture align 512 %probe_issued_ctx_layer, i8* noalias nocapture align 512 %probe_issued_ctx_batch, i8* noalias nocapture align 512 %probe_issued_ctx_row_space, i16* noalias nocapture align 512 %probe_issued_ctx_row0, i8* noalias nocapture align 512 %probe_issued_ctx_rows, i8* noalias nocapture align 512 %probe_issued_src0_id, i8* noalias nocapture align 512 %probe_issued_src0_bank, i32* noalias nocapture align 512 %probe_issued_src0_epoch, i8* noalias nocapture align 512 %probe_issued_src1_id, i8* noalias nocapture align 512 %probe_issued_src1_bank, i32* noalias nocapture align 512 %probe_issued_src1_epoch, i8* noalias nocapture align 512 %probe_issued_dst_id, i8* noalias nocapture align 512 %probe_issued_dst_bank, i32* noalias nocapture align 512 %probe_issued_dst_epoch, i16* noalias nocapture align 512 %probe_issued_length, i8* noalias nocapture align 512 %probe_issued_src0_region, i8* noalias nocapture align 512 %probe_issued_src1_region, i8* noalias nocapture align 512 %probe_issued_dst_region, i16* noalias nocapture align 512 %probe_issued_bias_id, i8* noalias nocapture align 512 %probe_second_bound_id, i8* noalias nocapture align 512 %probe_second_bound_bank, i32* noalias nocapture align 512 %probe_second_bound_epoch, i8* noalias nocapture align 512 %probe_second_bound_region, i8* noalias nocapture align 512 %probe_second_bind_count) unnamed_addr #0 {
entry:
  call void (...) @_ssdm_InlineSelf(i64 2, [1 x i8]* @1), !fpga.pragma.source !7
  %spec.select1 = select i1 %src1_present, i8 %src1_ref_id.val, i8 0
  %spec.select2 = select i1 %src1_present, i8 %src1_ref_bank.val, i8 0
  %spec.select3 = select i1 %src1_present, i32 %src1_ref_epoch.val, i32 0
  %spec.select = select i1 %src1_present, i8 %src1_region.val, i8 0
  %add = add i32 %src0_ref_epoch.val, 1
  store i16 0, i16* %agg.result_code, align 512, !alias.scope !8, !noalias !13
  store i32 0, i32* %agg.result_detail, align 512, !alias.scope !17, !noalias !19
  store i64 -1, i64* %agg.result_bad_element, align 512, !alias.scope !20, !noalias !22
  %brmerge = xor i1 %src1_present, true
  br i1 %brmerge, label %if.end, label %if.then

if.then:                                          ; preds = %entry
  %cmp.i2 = icmp eq i8 %src1_ref_id.val, 0
  %ref.tmp17.035.0 = select i1 %cmp.i2, i16 5, i16 0
  %ref.tmp17.136.0 = select i1 %cmp.i2, i32 67108870, i32 0
  store i16 %ref.tmp17.035.0, i16* %agg.result_code, align 512
  store i32 %ref.tmp17.136.0, i32* %agg.result_detail, align 512
  store i64 -1, i64* %agg.result_bad_element, align 512
  store i8 %src1_ref_id.val, i8* %probe_second_bound_id, align 512
  store i8 %src1_ref_bank.val, i8* %probe_second_bound_bank, align 512
  store i32 %src1_ref_epoch.val, i32* %probe_second_bound_epoch, align 512
  store i8 %src1_region.val, i8* %probe_second_bound_region, align 512
  %0 = load i8, i8* %probe_second_bind_count, align 512
  %inc = add i8 %0, 1
  store i8 %inc, i8* %probe_second_bind_count, align 512
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  %1 = phi i16 [ 0, %entry ], [ %ref.tmp17.035.0, %if.then ]
  store i32 0, i32* %probe_issued_ctx_task_id, align 512
  store i8 %op, i8* %probe_issued_ctx_op, align 512
  store i8 2, i8* %probe_issued_ctx_stage, align 512
  store i8 %layer, i8* %probe_issued_ctx_layer, align 512
  store i8 0, i8* %probe_issued_ctx_batch, align 512
  store i8 0, i8* %probe_issued_ctx_row_space, align 512
  store i16 0, i16* %probe_issued_ctx_row0, align 512
  store i8 0, i8* %probe_issued_ctx_rows, align 512
  store i8 1, i8* %probe_issued_src0_id, align 512
  store i8 %src0_ref_bank.val, i8* %probe_issued_src0_bank, align 512
  store i32 %src0_ref_epoch.val, i32* %probe_issued_src0_epoch, align 512
  store i8 %spec.select1, i8* %probe_issued_src1_id, align 512
  store i8 %spec.select2, i8* %probe_issued_src1_bank, align 512
  store i32 %spec.select3, i32* %probe_issued_src1_epoch, align 512
  store i8 1, i8* %probe_issued_dst_id, align 512
  store i8 1, i8* %probe_issued_dst_bank, align 512
  store i32 %add, i32* %probe_issued_dst_epoch, align 512
  store i16 1024, i16* %probe_issued_length, align 512
  store i8 0, i8* %probe_issued_src0_region, align 512
  store i8 %spec.select, i8* %probe_issued_src1_region, align 512
  store i8 0, i8* %probe_issued_dst_region, align 512
  store i16 -1, i16* %probe_issued_bias_id, align 512
  %cmp.i6 = icmp eq i16 %1, 0
  br i1 %cmp.i6, label %if.then21, label %if.end23

if.then21:                                        ; preds = %if.end
  %.off.i = add i8 %op, -98
  %switch.i = icmp ult i8 %.off.i, 2
  %cmp4.i = icmp eq i8 %spec.select1, 0
  %or.cond.i = and i1 %switch.i, %cmp4.i
  %ref.tmp22.029.0 = select i1 %or.cond.i, i16 3, i16 0
  %ref.tmp22.130.0 = select i1 %or.cond.i, i32 117637121, i32 0
  store i16 %ref.tmp22.029.0, i16* %agg.result_code, align 512
  store i32 %ref.tmp22.130.0, i32* %agg.result_detail, align 512
  store i64 -1, i64* %agg.result_bad_element, align 512
  br label %if.end23

if.end23:                                         ; preds = %if.then21, %if.end
  ret void
}
