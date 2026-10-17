define internal fastcc { i16, i32, i64 } @"laya::full::full_begin_qkv_rope_pair"(i8 %old_s_ref_id.0.0.val, i8 %old_s_ref_id.0.1.val, i8 %old_s_ref_bank.0.0.val, i8 %old_s_ref_bank.0.1.val, [2 x i32]* noalias nocapture align 512 %old_s_ref_epoch, [2 x i8]* noalias nocapture align 512 %old_s_region, [2 x i8]* noalias nocapture align 512 %old_s_stage, [2 x i8]* noalias nocapture align 512 %old_s_batch, [2 x i8]* noalias nocapture align 512 %old_s_row_space, [2 x i16]* noalias nocapture align 512 %old_s_row0, [2 x i16]* noalias nocapture align 512 %old_s_rows, [2 x i16]* noalias nocapture align 512 %old_s_width) #1 {
entry:
  %"(anonymous namespace)::runtime.request_valid.load" = load i1, i1* @"(anonymous namespace)::runtime.request_valid", align 512
  br i1 %"(anonymous namespace)::runtime.request_valid.load", label %lor.lhs.false, label %return

lor.lhs.false:                                    ; preds = %entry
  %"(anonymous namespace)::runtime.model_header_valid.load" = load i1, i1* @"(anonymous namespace)::runtime.model_header_valid", align 512
  br i1 %"(anonymous namespace)::runtime.model_header_valid.load", label %lor.lhs.false1, label %return

lor.lhs.false1:                                   ; preds = %lor.lhs.false
  %old_s_ref_epoch.addr = getelementptr [2 x i32], [2 x i32]* %old_s_ref_epoch, i64 0, i64 0
  %old_s_region.addr = getelementptr [2 x i8], [2 x i8]* %old_s_region, i64 0, i64 0
  %old_s_ref_epoch.load = load i32, i32* %old_s_ref_epoch.addr, align 512
  call void (...) @_ssdm_SpecKeepArrayLoad(i32 %old_s_ref_epoch.load) #1
  %old_s_region.load = load i8, i8* %old_s_region.addr, align 512
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %old_s_region.load) #1
  %tmp = call fastcc zeroext i1 @"laya::full::(anonymous namespace)::legal_spec.9"(i8 %old_s_ref_id.0.0.val, i8 %old_s_ref_bank.0.0.val, i32 %old_s_ref_epoch.load, i8 %old_s_region.load, [2 x i8]* noalias nocapture %old_s_stage, i64 0, [2 x i8]* noalias nocapture %old_s_batch, i64 0, [2 x i8]* noalias nocapture %old_s_row_space, i64 0, [2 x i16]* noalias nocapture %old_s_row0, i64 0, [2 x i16]* noalias nocapture %old_s_rows, i64 0, [2 x i16]* noalias nocapture %old_s_width, i64 0) #1
  br i1 %tmp, label %land.lhs.true.i.i, label %"(anonymous namespace)qkv_rope_specs.exit"

land.lhs.true.i.i:                                ; preds = %lor.lhs.false1
  %old_s_ref_epoch.addr.1 = getelementptr [2 x i32], [2 x i32]* %old_s_ref_epoch, i64 0, i64 1
  %old_s_region.addr.1 = getelementptr [2 x i8], [2 x i8]* %old_s_region, i64 0, i64 1
  %old_s_ref_epoch.load.1 = load i32, i32* %old_s_ref_epoch.addr.1, align 4
  call void (...) @_ssdm_SpecKeepArrayLoad(i32 %old_s_ref_epoch.load.1) #1
  %old_s_region.load.1 = load i8, i8* %old_s_region.addr.1, align 4
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %old_s_region.load.1) #1
  %0 = call fastcc zeroext i1 @"laya::full::(anonymous namespace)::legal_spec.9"(i8 %old_s_ref_id.0.1.val, i8 %old_s_ref_bank.0.1.val, i32 %old_s_ref_epoch.load.1, i8 %old_s_region.load.1, [2 x i8]* noalias nocapture %old_s_stage, i64 1, [2 x i8]* noalias nocapture %old_s_batch, i64 1, [2 x i8]* noalias nocapture %old_s_row_space, i64 1, [2 x i16]* noalias nocapture %old_s_row0, i64 1, [2 x i16]* noalias nocapture %old_s_rows, i64 1, [2 x i16]* noalias nocapture %old_s_width, i64 1) #1
  br label %"(anonymous namespace)qkv_rope_specs.exit"

"(anonymous namespace)qkv_rope_specs.exit":       ; preds = %land.lhs.true.i.i, %lor.lhs.false1
  br label %return

return:                                           ; preds = %"(anonymous namespace)qkv_rope_specs.exit", %lor.lhs.false, %entry
  %mrv = insertvalue { i16, i32, i64 } undef, i16 5, 0
  %mrv.1 = insertvalue { i16, i32, i64 } %mrv, i32 67436549, 1
  %mrv.2 = insertvalue { i16, i32, i64 } %mrv.1, i64 -1, 2
  ret { i16, i32, i64 } %mrv.2
}
