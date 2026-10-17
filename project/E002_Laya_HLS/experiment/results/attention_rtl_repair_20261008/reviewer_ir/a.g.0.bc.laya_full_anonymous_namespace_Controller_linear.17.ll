define internal fastcc void @"laya::full::(anonymous namespace)::Controller::linear.17"(i16* noalias nocapture align 512 %agg.result.01, i32* noalias nocapture align 512 %agg.result.12, i64* noalias nocapture align 512 %agg.result.23, i8 addrspace(1)* noalias nocapture %embedding, i64 %this_memory.0, i64* noalias nocapture align 512 %this_memory.1, i8 addrspace(1)* noalias nocapture %io, i64 %this_memory.2, i64* noalias nocapture align 512 %this_memory.3, i8 addrspace(1)* noalias nocapture %w_q0, i64 %this_memory.4, i64* noalias nocapture align 512 %this_memory.5, i8 addrspace(1)* noalias nocapture %w_q1, i64 %this_memory.6, i64* noalias nocapture align 512 %this_memory.7, i8 addrspace(1)* noalias nocapture %w_scale, i64 %this_memory.8, i64* noalias nocapture align 512 %this_memory.9, i8 addrspace(1)* noalias nocapture %aux, i64 %this_memory.10, i64* noalias nocapture align 512 %this_memory.11, i8 addrspace(1)* noalias nocapture %state0, i64 %this_memory.12, i64* noalias nocapture align 512 %this_memory.13, i8 addrspace(1)* noalias nocapture %state1, i64 %this_memory.14, i64* noalias nocapture align 512 %this_memory.15, i8 addrspace(1)* noalias nocapture %qkv0, i64 %this_memory.16, i64* noalias nocapture align 512 %this_memory.17, i8 addrspace(1)* noalias nocapture %qkv1, i64 %this_memory.18, i64* noalias nocapture align 512 %this_memory.19, i8 addrspace(1)* noalias nocapture %ff0, i64 %this_memory.20, i64* noalias nocapture align 512 %this_memory.21, i8 addrspace(1)* noalias nocapture %ff1, i64 %this_memory.22, i64* noalias nocapture align 512 %this_memory.23, i8 addrspace(1)* noalias nocapture %att_out, i64 %this_memory.24, i64* noalias nocapture align 512 %this_memory.25, i8* noalias nocapture align 512 %this_error_stage, i8* noalias nocapture align 512 %this_error_op, i32* noalias nocapture align 512 %this_error_task_id, i8* noalias nocapture align 512 %this_current_stage, i8* noalias nocapture align 512 %this_current_op, i8 %key_layer.val, i8 %source_row_space.val, i8 zeroext %layer, i8 %dst_ref_id, i8 %dst_ref_bank, i32 %dst_ref_epoch, i8* noalias nocapture align 512 %output_ref_id, i8* noalias nocapture align 512 %output_ref_bank, i32* noalias nocapture align 512 %output_ref_epoch, i8* noalias nocapture align 512 %output_region, i8* noalias nocapture align 512 %output_stage, i8* noalias nocapture align 512 %output_layer, i8* noalias nocapture align 512 %output_batch, i8* noalias nocapture align 512 %output_row_space, i16* noalias nocapture align 512 %output_row0, i16* noalias nocapture align 512 %output_rows, i16* noalias nocapture align 512 %output_width, i8* noalias nocapture align 512 %output_content) unnamed_addr #0 {
entry:
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
  store i8 4, i8* %this_current_stage, align 512, !alias.scope !11715, !noalias !11718
  store i8 48, i8* %this_current_op, align 512, !alias.scope !11718, !noalias !11715
  br label %arrayinit.body.i

arrayinit.body.i:                                 ; preds = %arrayinit.body.i, %entry
  %arrayinit.curidx.i = phi i64 [ 0, %entry ], [ %arrayinit.nextidx.i, %arrayinit.body.i ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 48, i64 48, i64 48), !fpga.pragma.source !33
  %arrayinit.cur1.i = getelementptr [48 x i8], [48 x i8]* %descriptor.name, i64 0, i64 %arrayinit.curidx.i
  %arrayinit.nextidx.i = add nuw nsw i64 %arrayinit.curidx.i, 1
  store i8 0, i8* %arrayinit.cur1.i, align 1, !alias.scope !11720, !noalias !11723
  %arrayinit.done.i = icmp eq i64 %arrayinit.curidx.i, 47
  br i1 %arrayinit.done.i, label %arrayinit.end.i, label %arrayinit.body.i, !llvm.loop !11740

arrayinit.end.i:                                  ; preds = %arrayinit.body.i
  store i8 0, i8* %descriptor.key.family, align 512, !alias.scope !11741, !noalias !11744
  store i8 -1, i8* %descriptor.key.layer, align 512, !alias.scope !11746, !noalias !11747
  store i16 0, i16* %descriptor.K, align 512, !alias.scope !11748, !noalias !11749
  store i16 0, i16* %descriptor.N, align 512, !alias.scope !11750, !noalias !11751
  store i8 0, i8* %descriptor.dtype, align 512, !alias.scope !11752, !noalias !11753
  store i8 0, i8* %descriptor.bias_kind, align 512, !alias.scope !11754, !noalias !11755
  br label %arrayinit.body3.i

arrayinit.body3.i:                                ; preds = %arrayinit.body3.i, %arrayinit.end.i
  %arrayinit.curidx4.i = phi i64 [ 0, %arrayinit.end.i ], [ %arrayinit.nextidx6.i, %arrayinit.body3.i ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 2, i64 2, i64 2), !fpga.pragma.source !33
  %arrayinit.cur52.i = getelementptr [2 x i32], [2 x i32]* %descriptor.q_base, i64 0, i64 %arrayinit.curidx4.i
  %arrayinit.nextidx6.i = add nuw nsw i64 %arrayinit.curidx4.i, 1
  store i32 0, i32* %arrayinit.cur52.i, align 4, !alias.scope !11756, !noalias !11757
  %arrayinit.done7.i = icmp eq i64 %arrayinit.curidx4.i, 1
  br i1 %arrayinit.done7.i, label %arrayinit.end8.i, label %arrayinit.body3.i, !llvm.loop !11758

arrayinit.end8.i:                                 ; preds = %arrayinit.body3.i
  br label %arrayinit.body10.i

arrayinit.body10.i:                               ; preds = %arrayinit.body10.i, %arrayinit.end8.i
  %arrayinit.curidx11.i = phi i64 [ 0, %arrayinit.end8.i ], [ %arrayinit.nextidx13.i, %arrayinit.body10.i ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 2, i64 2, i64 2), !fpga.pragma.source !33
  %arrayinit.cur123.i = getelementptr [2 x i32], [2 x i32]* %descriptor.q_span, i64 0, i64 %arrayinit.curidx11.i
  %arrayinit.nextidx13.i = add nuw nsw i64 %arrayinit.curidx11.i, 1
  store i32 0, i32* %arrayinit.cur123.i, align 4, !alias.scope !11759, !noalias !11760
  %arrayinit.done14.i = icmp eq i64 %arrayinit.curidx11.i, 1
  br i1 %arrayinit.done14.i, label %arrayinit.end15.i, label %arrayinit.body10.i, !llvm.loop !11761

arrayinit.end15.i:                                ; preds = %arrayinit.body10.i
  store i32 0, i32* %descriptor.scale_base, align 512, !alias.scope !11762, !noalias !11763
  store i32 0, i32* %descriptor.scale_span, align 512, !alias.scope !11764, !noalias !11765
  store i32 0, i32* %descriptor.aux_base, align 512, !alias.scope !11766, !noalias !11767
  store i32 0, i32* %descriptor.aux_span, align 512, !alias.scope !11768, !noalias !11769
  store i32 0, i32* %descriptor.bias_base, align 512, !alias.scope !11770, !noalias !11771
  store i32 0, i32* %descriptor.bias_span, align 512, !alias.scope !11772, !noalias !11773
  br label %arrayinit.body17.i

arrayinit.body17.i:                               ; preds = %arrayinit.body17.i, %arrayinit.end15.i
  %arrayinit.curidx18.i = phi i64 [ 0, %arrayinit.end15.i ], [ %arrayinit.nextidx20.i, %arrayinit.body17.i ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 32, i64 32, i64 32), !fpga.pragma.source !33
  %arrayinit.cur194.i = getelementptr [32 x i8], [32 x i8]* %descriptor.source_sha256, i64 0, i64 %arrayinit.curidx18.i
  %arrayinit.nextidx20.i = add nuw nsw i64 %arrayinit.curidx18.i, 1
  store i8 0, i8* %arrayinit.cur194.i, align 1, !alias.scope !11774, !noalias !11775
  %arrayinit.done21.i = icmp eq i64 %arrayinit.curidx18.i, 31
  br i1 %arrayinit.done21.i, label %arrayinit.end22.i, label %arrayinit.body17.i, !llvm.loop !11776

arrayinit.end22.i:                                ; preds = %arrayinit.body17.i
  br label %arrayinit.body24.i

arrayinit.body24.i:                               ; preds = %arrayinit.body24.i, %arrayinit.end22.i
  %arrayinit.curidx25.i = phi i64 [ 0, %arrayinit.end22.i ], [ %arrayinit.nextidx27.i, %arrayinit.body24.i ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 32, i64 32, i64 32), !fpga.pragma.source !33
  %arrayinit.cur265.i = getelementptr [32 x i8], [32 x i8]* %descriptor.bias_sha256, i64 0, i64 %arrayinit.curidx25.i
  %arrayinit.nextidx27.i = add nuw nsw i64 %arrayinit.curidx25.i, 1
  store i8 0, i8* %arrayinit.cur265.i, align 1, !alias.scope !11777, !noalias !11778
  %arrayinit.done28.i = icmp eq i64 %arrayinit.curidx25.i, 31
  br i1 %arrayinit.done28.i, label %_ZN4laya4full20FullWeightDescriptorC2Ev.exit, label %arrayinit.body24.i, !llvm.loop !11779

_ZN4laya4full20FullWeightDescriptorC2Ev.exit:     ; preds = %arrayinit.body24.i
  call fastcc void @"laya::full::(anonymous namespace)::Controller::load_weight"(i16* %c.code, i32* %c.detail, i64* %c.bad_element, i8 addrspace(1)* %embedding, i64 %this_memory.0, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i64* %this_memory.5, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i64* %this_memory.7, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i64* %this_memory.9, i8 addrspace(1)* %aux, i64 %this_memory.10, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i8 5, i8 %key_layer.val, i8 4, i8 %layer, [48 x i8]* %descriptor.name, i8* %descriptor.key.family, i8* %descriptor.key.layer, i16* %descriptor.K, i16* %descriptor.N, i8* %descriptor.dtype, i8* %descriptor.bias_kind, [2 x i32]* %descriptor.q_base, [2 x i32]* %descriptor.q_span, i32* %descriptor.scale_base, i32* %descriptor.scale_span, i32* %descriptor.aux_base, i32* %descriptor.aux_span, i32* %descriptor.bias_base, i32* %descriptor.bias_span, [32 x i8]* %descriptor.source_sha256, [32 x i8]* %descriptor.bias_sha256)
  %0 = load i16, i16* %c.code, align 512, !alias.scope !11780
  %cmp.i = icmp eq i16 %0, 0
  br i1 %cmp.i, label %if.end, label %if.then

if.then:                                          ; preds = %_ZN4laya4full20FullWeightDescriptorC2Ev.exit
  %.1176 = load i32, i32* %c.detail, align 512
  %.2179 = load i64, i64* %c.bad_element, align 512
  br label %cleanup119

if.end:                                           ; preds = %_ZN4laya4full20FullWeightDescriptorC2Ev.exit
  store i8 4, i8* %this_current_stage, align 512, !alias.scope !11783, !noalias !11786
  store i8 48, i8* %this_current_op, align 512, !alias.scope !11786, !noalias !11783
  %cmp.i19 = icmp eq i8 %source_row_space.val, 0
  %1 = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.S", align 512
  %cmp6.i = icmp eq i8 %source_row_space.val, 1
  %cond.i = select i1 %cmp6.i, i16 16, i16 1
  %cond7.i = select i1 %cmp.i19, i16 %1, i16 %cond.i
  store i8 %dst_ref_id, i8* %output_ref_id, align 512
  store i8 %dst_ref_bank, i8* %output_ref_bank, align 512
  store i32 %dst_ref_epoch, i32* %output_ref_epoch, align 512
  store i8 0, i8* %output_region, align 512
  store i8 4, i8* %output_stage, align 512
  store i8 %layer, i8* %output_layer, align 512
  store i8 -1, i8* %output_batch, align 512
  store i8 %source_row_space.val, i8* %output_row_space, align 512
  store i16 0, i16* %output_row0, align 512
  store i16 %cond7.i, i16* %output_rows, align 512
  store i16 64, i16* %output_width, align 512
  store i8 3, i8* %output_content, align 512
  br label %cleanup119

cleanup119:                                       ; preds = %if.end, %if.then
  %storemerge2 = phi i16 [ %0, %if.then ], [ 8, %if.end ]
  %storemerge1 = phi i32 [ 117440516, %if.end ], [ %.1176, %if.then ]
  %storemerge = phi i64 [ %.2179, %if.then ], [ -1, %if.end ]
  store i16 %storemerge2, i16* %agg.result.01, align 512
  store i32 %storemerge1, i32* %agg.result.12, align 512
  store i64 %storemerge, i64* %agg.result.23, align 512
  ret void
}
