define internal fastcc void @"laya::full::(anonymous namespace)::Controller::linear.17"(i16* noalias nocapture align 512 %agg.result.01, i32* noalias nocapture align 512 %agg.result.12, i64* noalias nocapture align 512 %agg.result.23, i8 addrspace(1)* noalias nocapture %embedding, i64 %this_memory.0, i8 addrspace(1)* noalias nocapture %io, i64 %this_memory.2, i8 addrspace(1)* noalias nocapture %w_q0, i64 %this_memory.4, i8 addrspace(1)* noalias nocapture %w_q1, i64 %this_memory.6, i8 addrspace(1)* noalias nocapture %w_scale, i64 %this_memory.8, i8 addrspace(1)* noalias nocapture %aux, i64 %this_memory.10, i8 addrspace(1)* noalias nocapture %state0, i64 %this_memory.12, i8 addrspace(1)* noalias nocapture %state1, i64 %this_memory.14, i8 addrspace(1)* noalias nocapture %qkv0, i64 %this_memory.16, i8 addrspace(1)* noalias nocapture %qkv1, i64 %this_memory.18, i8 addrspace(1)* noalias nocapture %ff0, i64 %this_memory.20, i8 addrspace(1)* noalias nocapture %ff1, i64 %this_memory.22, i8 addrspace(1)* noalias nocapture %att_out, i64 %this_memory.24, i8* noalias nocapture align 512 %this_error_stage, i8* noalias nocapture align 512 %this_error_op, i32* noalias nocapture align 512 %this_error_task_id, i8* noalias nocapture align 512 %this_current_stage, i8* noalias nocapture align 512 %this_current_op, i8 %key_layer.val, i8 %source_row_space.val, i8 zeroext %layer, i8 %dst_ref_id, i8 %dst_ref_bank, i32 %dst_ref_epoch, i8* noalias nocapture align 512 %output_ref_id, i8* noalias nocapture align 512 %output_ref_bank, i32* noalias nocapture align 512 %output_ref_epoch, i8* noalias nocapture align 512 %output_region, i8* noalias nocapture align 512 %output_stage, i8* noalias nocapture align 512 %output_layer, i8* noalias nocapture align 512 %output_batch, i8* noalias nocapture align 512 %output_row_space, i16* noalias nocapture align 512 %output_row0, i16* noalias nocapture align 512 %output_rows, i16* noalias nocapture align 512 %output_width, i8* noalias nocapture align 512 %output_content) unnamed_addr #1 {
entry:
  %descriptor.name = alloca [48 x i8], i64 1, align 512
  %descriptor.key.family = alloca i8, i64 1, align 512
  %descriptor.key.layer = alloca i8, i64 1, align 512
  %descriptor.K = alloca i16, i64 1, align 512
  %descriptor.N = alloca i16, i64 1, align 512
  %descriptor.dtype = alloca i8, i64 1, align 512
  %descriptor.bias_kind = alloca i8, i64 1, align 512
  %descriptor.q_base = alloca [2 x i32], i64 1, align 512
  %descriptor.q_span = alloca [2 x i32], i64 1, align 512
  %descriptor.scale_base = alloca i32, i64 1, align 512
  %descriptor.scale_span = alloca i32, i64 1, align 512
  %descriptor.aux_base = alloca i32, i64 1, align 512
  %descriptor.aux_span = alloca i32, i64 1, align 512
  %descriptor.bias_base = alloca i32, i64 1, align 512
  %descriptor.bias_span = alloca i32, i64 1, align 512
  %descriptor.source_sha256 = alloca [32 x i8], i64 1, align 512
  %descriptor.bias_sha256 = alloca [32 x i8], i64 1, align 512
  %c.code = alloca i16, i64 1, align 512
  %c.detail = alloca i32, i64 1, align 512
  %c.bad_element = alloca i64, i64 1, align 512
  store i8 4, i8* %this_current_stage, align 512, !alias.scope !15679, !noalias !15682
  store i8 48, i8* %this_current_op, align 512, !alias.scope !15682, !noalias !15679
  br label %arrayinit.body.i

arrayinit.body.i:                                 ; preds = %arrayinit.body.i, %entry
  %arrayinit.curidx.i = phi i64 [ 0, %entry ], [ %add.ln52, %arrayinit.body.i ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 48, i64 48, i64 48), !fpga.pragma.source !33
  %this.name.addr = getelementptr [48 x i8], [48 x i8]* %descriptor.name, i64 0, i64 %arrayinit.curidx.i
  %add.ln52 = add nuw nsw i64 %arrayinit.curidx.i, 1
  store i8 0, i8* %this.name.addr, align 1, !alias.scope !15684, !noalias !15687
  %icmp.ln52 = icmp eq i64 %arrayinit.curidx.i, 47
  br i1 %icmp.ln52, label %arrayinit.end.i, label %arrayinit.body.i, !llvm.loop !15704

arrayinit.end.i:                                  ; preds = %arrayinit.body.i
  store i8 0, i8* %descriptor.key.family, align 512, !alias.scope !15705, !noalias !15708
  store i8 -1, i8* %descriptor.key.layer, align 512, !alias.scope !15710, !noalias !15711
  store i16 0, i16* %descriptor.K, align 512, !alias.scope !15712, !noalias !15713
  store i16 0, i16* %descriptor.N, align 512, !alias.scope !15714, !noalias !15715
  store i8 0, i8* %descriptor.dtype, align 512, !alias.scope !15716, !noalias !15717
  store i8 0, i8* %descriptor.bias_kind, align 512, !alias.scope !15718, !noalias !15719
  br label %arrayinit.body3.i

arrayinit.body3.i:                                ; preds = %arrayinit.body3.i, %arrayinit.end.i
  %arrayinit.curidx4.i = phi i64 [ 0, %arrayinit.end.i ], [ %add.ln56, %arrayinit.body3.i ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 2, i64 2, i64 2), !fpga.pragma.source !33
  %this.q_base.addr = getelementptr [2 x i32], [2 x i32]* %descriptor.q_base, i64 0, i64 %arrayinit.curidx4.i
  %add.ln56 = add nuw nsw i64 %arrayinit.curidx4.i, 1
  store i32 0, i32* %this.q_base.addr, align 4, !alias.scope !15720, !noalias !15721
  %icmp.ln56 = icmp eq i64 %arrayinit.curidx4.i, 1
  br i1 %icmp.ln56, label %arrayinit.body10.i.preheader, label %arrayinit.body3.i, !llvm.loop !15722

arrayinit.body10.i.preheader:                     ; preds = %arrayinit.body3.i
  br label %arrayinit.body10.i

arrayinit.body10.i:                               ; preds = %arrayinit.body10.i, %arrayinit.body10.i.preheader
  %arrayinit.curidx11.i = phi i64 [ %add.ln56.6, %arrayinit.body10.i ], [ 0, %arrayinit.body10.i.preheader ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 2, i64 2, i64 2), !fpga.pragma.source !33
  %this.q_span.addr = getelementptr [2 x i32], [2 x i32]* %descriptor.q_span, i64 0, i64 %arrayinit.curidx11.i
  %add.ln56.6 = add nuw nsw i64 %arrayinit.curidx11.i, 1
  store i32 0, i32* %this.q_span.addr, align 4, !alias.scope !15723, !noalias !15724
  %icmp.ln56.12 = icmp eq i64 %arrayinit.curidx11.i, 1
  br i1 %icmp.ln56.12, label %arrayinit.end15.i, label %arrayinit.body10.i, !llvm.loop !15725

arrayinit.end15.i:                                ; preds = %arrayinit.body10.i
  store i32 0, i32* %descriptor.scale_base, align 512, !alias.scope !15726, !noalias !15727
  store i32 0, i32* %descriptor.scale_span, align 512, !alias.scope !15728, !noalias !15729
  store i32 0, i32* %descriptor.aux_base, align 512, !alias.scope !15730, !noalias !15731
  store i32 0, i32* %descriptor.aux_span, align 512, !alias.scope !15732, !noalias !15733
  store i32 0, i32* %descriptor.bias_base, align 512, !alias.scope !15734, !noalias !15735
  store i32 0, i32* %descriptor.bias_span, align 512, !alias.scope !15736, !noalias !15737
  br label %arrayinit.body17.i

arrayinit.body17.i:                               ; preds = %arrayinit.body17.i, %arrayinit.end15.i
  %arrayinit.curidx18.i = phi i64 [ 0, %arrayinit.end15.i ], [ %add.ln60, %arrayinit.body17.i ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 32, i64 32, i64 32), !fpga.pragma.source !33
  %this.source_sha256.addr = getelementptr [32 x i8], [32 x i8]* %descriptor.source_sha256, i64 0, i64 %arrayinit.curidx18.i
  %add.ln60 = add nuw nsw i64 %arrayinit.curidx18.i, 1
  store i8 0, i8* %this.source_sha256.addr, align 1, !alias.scope !15738, !noalias !15739
  %icmp.ln60 = icmp eq i64 %arrayinit.curidx18.i, 31
  br i1 %icmp.ln60, label %arrayinit.body24.i.preheader, label %arrayinit.body17.i, !llvm.loop !15740

arrayinit.body24.i.preheader:                     ; preds = %arrayinit.body17.i
  br label %arrayinit.body24.i

arrayinit.body24.i:                               ; preds = %arrayinit.body24.i, %arrayinit.body24.i.preheader
  %arrayinit.curidx25.i = phi i64 [ %add.ln61, %arrayinit.body24.i ], [ 0, %arrayinit.body24.i.preheader ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 32, i64 32, i64 32), !fpga.pragma.source !33
  %this.bias_sha256.addr = getelementptr [32 x i8], [32 x i8]* %descriptor.bias_sha256, i64 0, i64 %arrayinit.curidx25.i
  %add.ln61 = add nuw nsw i64 %arrayinit.curidx25.i, 1
  store i8 0, i8* %this.bias_sha256.addr, align 1, !alias.scope !15741, !noalias !15742
  %icmp.ln61 = icmp eq i64 %arrayinit.curidx25.i, 31
  br i1 %icmp.ln61, label %_ZN4laya4full20FullWeightDescriptorC2Ev.exit, label %arrayinit.body24.i, !llvm.loop !15743

_ZN4laya4full20FullWeightDescriptorC2Ev.exit:     ; preds = %arrayinit.body24.i
  call fastcc void @"laya::full::(anonymous namespace)::Controller::load_weight"(i16* %c.code, i32* %c.detail, i64* %c.bad_element, i8 addrspace(1)* %embedding, i64 %this_memory.0, i8 addrspace(1)* %io, i64 %this_memory.2, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i8 addrspace(1)* %aux, i64 %this_memory.10, i8 addrspace(1)* %state0, i64 %this_memory.12, i8 addrspace(1)* %state1, i64 %this_memory.14, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i8 addrspace(1)* %ff0, i64 %this_memory.20, i8 addrspace(1)* %ff1, i64 %this_memory.22, i8 addrspace(1)* %att_out, i64 %this_memory.24, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i8 5, i8 %key_layer.val, i8 4, i8 %layer, [48 x i8]* %descriptor.name, i8* %descriptor.key.family, i8* %descriptor.key.layer, i16* %descriptor.K, i16* %descriptor.N, i8* %descriptor.dtype, i8* %descriptor.bias_kind, [2 x i32]* %descriptor.q_base, [2 x i32]* %descriptor.q_span, i32* %descriptor.scale_base, i32* %descriptor.scale_span, i32* %descriptor.aux_base, i32* %descriptor.aux_span, i32* %descriptor.bias_base, i32* %descriptor.bias_span, [32 x i8]* %descriptor.source_sha256, [32 x i8]* %descriptor.bias_sha256)
  %c.code.load = load i16, i16* %c.code, align 512, !alias.scope !15744
  %icmp.ln9 = icmp eq i16 %c.code.load, 0
  br i1 %icmp.ln9, label %if.end, label %if.then

if.then:                                          ; preds = %_ZN4laya4full20FullWeightDescriptorC2Ev.exit
  %c.detail.load = load i32, i32* %c.detail, align 512
  %c.bad_element.load = load i64, i64* %c.bad_element, align 512
  br label %cleanup119

if.end:                                           ; preds = %_ZN4laya4full20FullWeightDescriptorC2Ev.exit
  store i8 4, i8* %this_current_stage, align 512, !alias.scope !15747, !noalias !15750
  store i8 48, i8* %this_current_op, align 512, !alias.scope !15750, !noalias !15747
  %icmp.ln63 = icmp eq i8 %source_row_space.val, 0
  %"(anonymous namespace)::runtime.inputs.identity.S.load" = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.S", align 512
  %icmp.ln64 = icmp eq i8 %source_row_space.val, 1
  %select.ln64 = select i1 %icmp.ln64, i16 16, i16 1
  %select.ln63 = select i1 %icmp.ln63, i16 %"(anonymous namespace)::runtime.inputs.identity.S.load", i16 %select.ln64
  store i8 %dst_ref_id, i8* %output_ref_id, align 512
  store i8 %dst_ref_bank, i8* %output_ref_bank, align 512
  store i32 %dst_ref_epoch, i32* %output_ref_epoch, align 512
  store i8 0, i8* %output_region, align 512
  store i8 4, i8* %output_stage, align 512
  store i8 %layer, i8* %output_layer, align 512
  store i8 -1, i8* %output_batch, align 512
  store i8 %source_row_space.val, i8* %output_row_space, align 512
  store i16 0, i16* %output_row0, align 512
  store i16 %select.ln63, i16* %output_rows, align 512
  store i16 64, i16* %output_width, align 512
  store i8 3, i8* %output_content, align 512
  br label %cleanup119

cleanup119:                                       ; preds = %if.end, %if.then
  %storemerge2 = phi i16 [ %c.code.load, %if.then ], [ 8, %if.end ]
  %storemerge1 = phi i32 [ %c.detail.load, %if.then ], [ 117440516, %if.end ]
  %storemerge = phi i64 [ %c.bad_element.load, %if.then ], [ -1, %if.end ]
  store i16 %storemerge2, i16* %agg.result.01, align 512
  store i32 %storemerge1, i32* %agg.result.12, align 512
  store i64 %storemerge, i64* %agg.result.23, align 512
  ret void
}
