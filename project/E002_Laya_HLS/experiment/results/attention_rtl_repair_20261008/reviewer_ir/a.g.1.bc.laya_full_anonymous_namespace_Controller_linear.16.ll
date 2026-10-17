define internal fastcc void @"laya::full::(anonymous namespace)::Controller::linear.16"(i16* noalias nocapture align 512 %agg.result.01, i32* noalias nocapture align 512 %agg.result.12, i64* noalias nocapture align 512 %agg.result.23, i8 addrspace(1)* noalias nocapture %embedding, i64 %this_memory.0, i8 addrspace(1)* noalias nocapture %io, i64 %this_memory.2, i8 addrspace(1)* noalias nocapture %w_q0, i64 %this_memory.4, i8 addrspace(1)* noalias nocapture %w_q1, i64 %this_memory.6, i8 addrspace(1)* noalias nocapture %w_scale, i64 %this_memory.8, i8 addrspace(1)* noalias nocapture %aux, i64 %this_memory.10, i8 addrspace(1)* noalias nocapture %state0, i64 %this_memory.12, i8 addrspace(1)* noalias nocapture %state1, i64 %this_memory.14, i8 addrspace(1)* noalias nocapture %qkv0, i64 %this_memory.16, i8 addrspace(1)* noalias nocapture %qkv1, i64 %this_memory.18, i8 addrspace(1)* noalias nocapture %ff0, i64 %this_memory.20, i8 addrspace(1)* noalias nocapture %ff1, i64 %this_memory.22, i8 addrspace(1)* noalias nocapture %att_out, i64 %this_memory.24, i8* noalias nocapture align 512 %this_error_stage, i8* noalias nocapture align 512 %this_error_op, i32* noalias nocapture align 512 %this_error_task_id, i8* noalias nocapture align 512 %this_current_stage, i8* noalias nocapture align 512 %this_current_op, i8 %key_layer.val, [23 x i192]* noalias align 512 %hidden, i8 zeroext %layer, i8 %dst_ref_id, i8 %dst_ref_bank, i32 %dst_ref_epoch, i8* noalias nocapture align 512 %output_ref_id, i8* noalias nocapture align 512 %output_ref_bank, i32* noalias nocapture align 512 %output_ref_epoch, i8* noalias nocapture align 512 %output_region, i8* noalias nocapture align 512 %output_stage, i8* noalias nocapture align 512 %output_layer, i8* noalias nocapture align 512 %output_batch, i8* noalias nocapture align 512 %output_row_space, i16* noalias nocapture align 512 %output_row0, i16* noalias nocapture align 512 %output_rows, i16* noalias nocapture align 512 %output_width, i8* noalias nocapture align 512 %output_content) unnamed_addr #1 {
entry:
  call void (...) @_ssdm_op_SpecBRAMWithByteEnable([23 x i192]* %hidden)
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
  %c.code.313 = alloca i16, i64 1, align 512
  %c.detail.307 = alloca i32, i64 1, align 512
  %c.bad_element.282 = alloca i64, i64 1, align 512
  %ref.tmp23.0265 = alloca i16, i64 1, align 512
  %ref.tmp23.1266 = alloca i32, i64 1, align 512
  %ref.tmp23.2267 = alloca i64, i64 1, align 512
  %ref.tmp52.0243 = alloca i8, i64 1, align 512
  %ref.tmp52.1244 = alloca i8, i64 1, align 512
  %ref.tmp52.2245 = alloca i32, i64 1, align 512
  %ref.tmp58.0231 = alloca i16, i64 1, align 512
  %ref.tmp58.1232 = alloca i32, i64 1, align 512
  %ref.tmp58.2233 = alloca i64, i64 1, align 512
  %ref.tmp73.0203 = alloca i8, i64 1, align 512
  %ref.tmp73.1204 = alloca i8, i64 1, align 512
  %ref.tmp73.2205 = alloca i32, i64 1, align 512
  %ref.tmp81.0197 = alloca i16, i64 1, align 512
  %ref.tmp81.1198 = alloca i32, i64 1, align 512
  %ref.tmp81.2199 = alloca i64, i64 1, align 512
  %ref.tmp103.0185 = alloca i16, i64 1, align 512
  %ref.tmp103.1186 = alloca i32, i64 1, align 512
  %ref.tmp103.2187 = alloca i64, i64 1, align 512
  store i8 2, i8* %this_current_stage, align 512, !alias.scope !15752, !noalias !15755
  store i8 50, i8* %this_current_op, align 512, !alias.scope !15755, !noalias !15752
  br label %arrayinit.body.i

arrayinit.body.i:                                 ; preds = %arrayinit.body.i, %entry
  %arrayinit.curidx.i = phi i64 [ 0, %entry ], [ %add.ln52, %arrayinit.body.i ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 48, i64 48, i64 48), !fpga.pragma.source !33
  %this.name.addr = getelementptr [48 x i8], [48 x i8]* %descriptor.name, i64 0, i64 %arrayinit.curidx.i
  %add.ln52 = add nuw nsw i64 %arrayinit.curidx.i, 1
  store i8 0, i8* %this.name.addr, align 1, !alias.scope !15757, !noalias !15760
  %icmp.ln52 = icmp eq i64 %arrayinit.curidx.i, 47
  br i1 %icmp.ln52, label %arrayinit.end.i, label %arrayinit.body.i, !llvm.loop !15777

arrayinit.end.i:                                  ; preds = %arrayinit.body.i
  store i8 0, i8* %descriptor.key.family, align 512, !alias.scope !15778, !noalias !15781
  store i8 -1, i8* %descriptor.key.layer, align 512, !alias.scope !15783, !noalias !15784
  store i16 0, i16* %descriptor.K, align 512, !alias.scope !15785, !noalias !15786
  store i16 0, i16* %descriptor.N, align 512, !alias.scope !15787, !noalias !15788
  store i8 0, i8* %descriptor.dtype, align 512, !alias.scope !15789, !noalias !15790
  store i8 0, i8* %descriptor.bias_kind, align 512, !alias.scope !15791, !noalias !15792
  br label %arrayinit.body3.i

arrayinit.body3.i:                                ; preds = %arrayinit.body3.i, %arrayinit.end.i
  %arrayinit.curidx4.i = phi i64 [ 0, %arrayinit.end.i ], [ %add.ln56, %arrayinit.body3.i ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 2, i64 2, i64 2), !fpga.pragma.source !33
  %this.q_base.addr = getelementptr [2 x i32], [2 x i32]* %descriptor.q_base, i64 0, i64 %arrayinit.curidx4.i
  %add.ln56 = add nuw nsw i64 %arrayinit.curidx4.i, 1
  store i32 0, i32* %this.q_base.addr, align 4, !alias.scope !15793, !noalias !15794
  %icmp.ln56 = icmp eq i64 %arrayinit.curidx4.i, 1
  br i1 %icmp.ln56, label %arrayinit.body10.i.preheader, label %arrayinit.body3.i, !llvm.loop !15795

arrayinit.body10.i.preheader:                     ; preds = %arrayinit.body3.i
  br label %arrayinit.body10.i

arrayinit.body10.i:                               ; preds = %arrayinit.body10.i, %arrayinit.body10.i.preheader
  %arrayinit.curidx11.i = phi i64 [ %add.ln56.7, %arrayinit.body10.i ], [ 0, %arrayinit.body10.i.preheader ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 2, i64 2, i64 2), !fpga.pragma.source !33
  %this.q_span.addr = getelementptr [2 x i32], [2 x i32]* %descriptor.q_span, i64 0, i64 %arrayinit.curidx11.i
  %add.ln56.7 = add nuw nsw i64 %arrayinit.curidx11.i, 1
  store i32 0, i32* %this.q_span.addr, align 4, !alias.scope !15796, !noalias !15797
  %icmp.ln56.13 = icmp eq i64 %arrayinit.curidx11.i, 1
  br i1 %icmp.ln56.13, label %arrayinit.end15.i, label %arrayinit.body10.i, !llvm.loop !15798

arrayinit.end15.i:                                ; preds = %arrayinit.body10.i
  store i32 0, i32* %descriptor.scale_base, align 512, !alias.scope !15799, !noalias !15800
  store i32 0, i32* %descriptor.scale_span, align 512, !alias.scope !15801, !noalias !15802
  store i32 0, i32* %descriptor.aux_base, align 512, !alias.scope !15803, !noalias !15804
  store i32 0, i32* %descriptor.aux_span, align 512, !alias.scope !15805, !noalias !15806
  store i32 0, i32* %descriptor.bias_base, align 512, !alias.scope !15807, !noalias !15808
  store i32 0, i32* %descriptor.bias_span, align 512, !alias.scope !15809, !noalias !15810
  br label %arrayinit.body17.i

arrayinit.body17.i:                               ; preds = %arrayinit.body17.i, %arrayinit.end15.i
  %arrayinit.curidx18.i = phi i64 [ 0, %arrayinit.end15.i ], [ %add.ln60, %arrayinit.body17.i ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 32, i64 32, i64 32), !fpga.pragma.source !33
  %this.source_sha256.addr = getelementptr [32 x i8], [32 x i8]* %descriptor.source_sha256, i64 0, i64 %arrayinit.curidx18.i
  %add.ln60 = add nuw nsw i64 %arrayinit.curidx18.i, 1
  store i8 0, i8* %this.source_sha256.addr, align 1, !alias.scope !15811, !noalias !15812
  %icmp.ln60 = icmp eq i64 %arrayinit.curidx18.i, 31
  br i1 %icmp.ln60, label %arrayinit.body24.i.preheader, label %arrayinit.body17.i, !llvm.loop !15813

arrayinit.body24.i.preheader:                     ; preds = %arrayinit.body17.i
  br label %arrayinit.body24.i

arrayinit.body24.i:                               ; preds = %arrayinit.body24.i, %arrayinit.body24.i.preheader
  %arrayinit.curidx25.i = phi i64 [ %add.ln61, %arrayinit.body24.i ], [ 0, %arrayinit.body24.i.preheader ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 32, i64 32, i64 32), !fpga.pragma.source !33
  %this.bias_sha256.addr = getelementptr [32 x i8], [32 x i8]* %descriptor.bias_sha256, i64 0, i64 %arrayinit.curidx25.i
  %add.ln61 = add nuw nsw i64 %arrayinit.curidx25.i, 1
  store i8 0, i8* %this.bias_sha256.addr, align 1, !alias.scope !15814, !noalias !15815
  %icmp.ln61 = icmp eq i64 %arrayinit.curidx25.i, 31
  br i1 %icmp.ln61, label %_ZN4laya4full20FullWeightDescriptorC2Ev.exit, label %arrayinit.body24.i, !llvm.loop !15816

_ZN4laya4full20FullWeightDescriptorC2Ev.exit:     ; preds = %arrayinit.body24.i
  call fastcc void @"laya::full::(anonymous namespace)::Controller::load_weight"(i16* %c.code.313, i32* %c.detail.307, i64* %c.bad_element.282, i8 addrspace(1)* %embedding, i64 %this_memory.0, i8 addrspace(1)* %io, i64 %this_memory.2, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i8 addrspace(1)* %aux, i64 %this_memory.10, i8 addrspace(1)* %state0, i64 %this_memory.12, i8 addrspace(1)* %state1, i64 %this_memory.14, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i8 addrspace(1)* %ff0, i64 %this_memory.20, i8 addrspace(1)* %ff1, i64 %this_memory.22, i8 addrspace(1)* %att_out, i64 %this_memory.24, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i8 3, i8 %key_layer.val, i8 2, i8 %layer, [48 x i8]* %descriptor.name, i8* %descriptor.key.family, i8* %descriptor.key.layer, i16* %descriptor.K, i16* %descriptor.N, i8* %descriptor.dtype, i8* %descriptor.bias_kind, [2 x i32]* %descriptor.q_base, [2 x i32]* %descriptor.q_span, i32* %descriptor.scale_base, i32* %descriptor.scale_span, i32* %descriptor.aux_base, i32* %descriptor.aux_span, i32* %descriptor.bias_base, i32* %descriptor.bias_span, [32 x i8]* %descriptor.source_sha256, [32 x i8]* %descriptor.bias_sha256)
  %c.code.load = load i16, i16* %c.code.313, align 512, !alias.scope !15817
  %icmp.ln9 = icmp eq i16 %c.code.load, 0
  br i1 %icmp.ln9, label %if.end, label %if.then

if.then:                                          ; preds = %_ZN4laya4full20FullWeightDescriptorC2Ev.exit
  %c.detail.303.load = load i32, i32* %c.detail.307, align 512
  %c.bad_element.278.load = load i64, i64* %c.bad_element.282, align 512
  br label %cleanup119

if.end:                                           ; preds = %_ZN4laya4full20FullWeightDescriptorC2Ev.exit
  store i8 2, i8* %this_current_stage, align 512, !alias.scope !15820, !noalias !15823
  store i8 50, i8* %this_current_op, align 512, !alias.scope !15823, !noalias !15820
  %hidden.addr = getelementptr [23 x i192], [23 x i192]* %hidden, i64 0, i64 21
  %hidden.load = load i192, i192* %hidden.addr, align 32
  call void (...) @_ssdm_SpecKeepArrayLoad(i192 %hidden.load) #1
  %lshr.ln205 = lshr i192 %hidden.load, 160
  %space = trunc i192 %lshr.ln205 to i8
  %width = load i16, i16* %descriptor.N, align 512
  %icmp.ln63 = icmp eq i8 %space, 0
  %"(anonymous namespace)::runtime.inputs.identity.S.load" = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.S", align 512
  %icmp.ln64 = icmp eq i8 %space, 1
  %select.ln64 = select i1 %icmp.ln64, i16 16, i16 1
  %select.ln63 = select i1 %icmp.ln63, i16 %"(anonymous namespace)::runtime.inputs.identity.S.load", i16 %select.ln64
  store i8 %dst_ref_id, i8* %output_ref_id, align 512
  store i8 %dst_ref_bank, i8* %output_ref_bank, align 512
  store i32 %dst_ref_epoch, i32* %output_ref_epoch, align 512
  store i8 0, i8* %output_region, align 512
  store i8 2, i8* %output_stage, align 512
  store i8 %layer, i8* %output_layer, align 512
  store i8 -1, i8* %output_batch, align 512
  store i8 %space, i8* %output_row_space, align 512
  store i16 0, i16* %output_row0, align 512
  store i16 %select.ln63, i16* %output_rows, align 512
  store i16 %width, i16* %output_width, align 512
  store i8 1, i8* %output_content, align 512
  call fastcc void @"laya::full::full_claim_owner"(i16* %ref.tmp23.0265, i32* %ref.tmp23.1266, i64* %ref.tmp23.2267, i8 %dst_ref_id, i8 %dst_ref_bank, i32 %dst_ref_epoch, i8 0, i8 2, i8 %layer, i8 -1, i8 %space, i16 0, i16 %select.ln63, i16 %width, i8 1)
  %c.code.311 = load i16, i16* %ref.tmp23.0265, align 512
  %c.detail = load i32, i32* %ref.tmp23.1266, align 512
  %c.bad_element = load i64, i64* %ref.tmp23.2267, align 512
  store i16 %c.code.311, i16* %c.code.313, align 512
  store i32 %c.detail, i32* %c.detail.307, align 512
  store i64 %c.bad_element, i64* %c.bad_element.282, align 512
  %icmp.ln9.278 = icmp eq i16 %c.code.311, 0
  br i1 %icmp.ln9.278, label %if.end29, label %cleanup119

if.end29:                                         ; preds = %if.end
  %hidden.addr.9 = getelementptr [23 x i192], [23 x i192]* %hidden, i64 0, i64 22
  %hidden.load.11 = load i192, i192* %hidden.addr.9, align 32
  call void (...) @_ssdm_SpecKeepArrayLoad(i192 %hidden.load.11) #1
  %trunc.ln218 = trunc i192 %hidden.load.11 to i16
  %rows = zext i16 %trunc.ln218 to i32
  %quant.K = load i16, i16* %descriptor.K, align 512
  %zext.ln230 = zext i16 %quant.K to i32
  %t.bias_kind = load i8, i8* %descriptor.bias_kind, align 512
  %icmp.ln220 = icmp ne i16 %trunc.ln218, 0
  %zext.ln244 = zext i16 %width to i32
  br label %for.cond

for.cond:                                         ; preds = %for.inc92, %if.end29
  %.27 = phi i64 [ %c.bad_element, %if.end29 ], [ %.28, %for.inc92 ]
  %.13 = phi i32 [ %c.detail, %if.end29 ], [ %.14, %for.inc92 ]
  %b = phi i32 [ 0, %if.end29 ], [ %b.20, %for.inc92 ]
  %"(anonymous namespace)::runtime.inputs.identity.B.load" = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.B", align 512
  %zext.ln219 = zext i16 %"(anonymous namespace)::runtime.inputs.identity.B.load" to i32
  %icmp.ln219 = icmp uge i32 %b, %zext.ln219
  %c.code.load.12 = load i16, i16* %c.code.313, align 512, !alias.scope !15825
  %icmp.ln9.279 = icmp ne i16 %c.code.load.12, 0
  %or.ln219 = or i1 %icmp.ln219, %icmp.ln9.279
  br i1 %or.ln219, label %if.else99, label %VITIS_LOOP_220_2

VITIS_LOOP_220_2:                                 ; preds = %for.cond
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @86)
  %batch = trunc i32 %b to i8
  br label %for.body39

for.cond36:                                       ; preds = %if.end65
  br label %for.body39, !llvm.loop !15830

for.cond.cleanup38.loopexit:                      ; preds = %for.body39
  %.235.phi.lcssa = phi i64 [ %c.bad_element.280, %for.body39 ]
  %.133.phi.lcssa = phi i32 [ %c.detail.305, %for.body39 ]
  br i1 %icmp.ln220, label %for.cond.cleanup38.loopexit.split, label %for.inc92

for.cond.cleanup38.loopexit.split:                ; preds = %for.cond.cleanup38.loopexit
  store i16 0, i16* %c.code.313, align 512
  store i32 %.133.phi.lcssa, i32* %c.detail.307, align 512
  store i64 %.235.phi.lcssa, i64* %c.bad_element.282, align 512
  br label %for.inc92

for.body39:                                       ; preds = %for.cond36, %VITIS_LOOP_220_2
  %row.020 = phi i32 [ 0, %VITIS_LOOP_220_2 ], [ %add.ln220, %for.cond36 ]
  %c.detail.305 = phi i32 [ %.13, %VITIS_LOOP_220_2 ], [ %ref.tmp81.1198.load, %for.cond36 ]
  %c.bad_element.280 = phi i64 [ %.27, %VITIS_LOOP_220_2 ], [ %ref.tmp81.2199.load, %for.cond36 ]
  %icmp.ln220.4 = icmp ult i32 %row.020, %rows
  br i1 %icmp.ln220.4, label %for.body39.split, label %for.cond.cleanup38.loopexit, !llvm.loop !15830

for.body39.split:                                 ; preds = %for.body39
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 0, i64 4096, i64 2048), !fpga.pragma.source !33
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @87)
  %sub.ln221 = sub nsw i32 %rows, %row.020
  %icmp.ln221 = icmp ult i32 %sub.ln221, 16
  %trunc.ln221 = trunc i32 %sub.ln221 to i8
  %count = select i1 %icmp.ln221, i8 %trunc.ln221, i8 16
  %hidden.load.12 = load i192, i192* %hidden.addr, align 32
  call void (...) @_ssdm_SpecKeepArrayLoad(i192 %hidden.load.12) #1
  %lshr.ln224 = lshr i192 %hidden.load.12, 160
  %space.5 = trunc i192 %lshr.ln224 to i8
  %row0 = trunc i32 %row.020 to i16
  %"(anonymous namespace)::runtime.last_task_id.load" = load i32, i32* @"(anonymous namespace)::runtime.last_task_id", align 512, !alias.scope !15959, !noalias !15962
  %quant.ctx.task_id = add i32 %"(anonymous namespace)::runtime.last_task_id.load", 1
  %lshr.ln225 = lshr i192 %hidden.load.12, 64
  %quant.src.id = trunc i192 %lshr.ln225 to i8
  %lshr.ln225.1 = lshr i192 %hidden.load.12, 72
  %quant.src.bank = trunc i192 %lshr.ln225.1 to i8
  %lshr.ln225.2 = lshr i192 %hidden.load.12, 96
  %quant.src.epoch = trunc i192 %lshr.ln225.2 to i32
  %lshr.ln226 = lshr i192 %hidden.load.12, 128
  %quant.src_region = trunc i192 %lshr.ln226 to i8
  call fastcc void @"laya::full::(anonymous namespace)::Controller::fresh"(i8* %ref.tmp52.0243, i8* %ref.tmp52.1244, i32* %ref.tmp52.2245, i8 34, i8 0, i8 0)
  %quant.a_dst.id = load i8, i8* %ref.tmp52.0243, align 512
  %quant.a_dst.bank = load i8, i8* %ref.tmp52.1244, align 512
  %quant.a_dst.epoch = load i32, i32* %ref.tmp52.2245, align 512
  %"(anonymous namespace)::runtime.request_valid.load" = load i1, i1* @"(anonymous namespace)::runtime.request_valid", align 512, !alias.scope !15971, !noalias !15974
  br i1 %"(anonymous namespace)::runtime.request_valid.load", label %lor.lhs.false.i, label %_ZN4laya4full22full_bind_quant_sourceERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE.exit

lor.lhs.false.i:                                  ; preds = %for.body39.split
  %"(anonymous namespace)::runtime.model_header_valid.load" = load i1, i1* @"(anonymous namespace)::runtime.model_header_valid", align 512, !alias.scope !15971, !noalias !15974
  br i1 %"(anonymous namespace)::runtime.model_header_valid.load", label %lor.lhs.false1.i, label %_ZN4laya4full22full_bind_quant_sourceERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE.exit

lor.lhs.false1.i:                                 ; preds = %lor.lhs.false.i
  %tmp = call fastcc i1 @"laya::full::(anonymous namespace)::legal_spec.24"([23 x i192]* %hidden)
  br i1 %tmp, label %lor.lhs.false2.i, label %_ZN4laya4full22full_bind_quant_sourceERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE.exit

lor.lhs.false2.i:                                 ; preds = %lor.lhs.false1.i
  %hidden.load.13 = load i192, i192* %hidden.addr.9, align 32
  call void (...) @_ssdm_SpecKeepArrayLoad(i192 %hidden.load.13) #1
  %lshr.ln730 = lshr i192 %hidden.load.13, 32
  %trunc.ln730 = trunc i192 %lshr.ln730 to i8
  %icmp.ln730 = icmp ne i8 %trunc.ln730, 1
  %icmp.ln731 = icmp eq i8 %quant.src.id, 0
  %or.ln730 = or i1 %icmp.ln730, %icmp.ln731
  br i1 %or.ln730, label %_ZN4laya4full22full_bind_quant_sourceERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE.exit, label %if.then57

_ZN4laya4full22full_bind_quant_sourceERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE.exit: ; preds = %lor.lhs.false2.i, %lor.lhs.false1.i, %lor.lhs.false.i, %for.body39.split
  %zext.ln11 = zext i8 %quant.src.id to i32
  %shl.ln11 = shl nuw nsw i32 %zext.ln11, 16
  %or.ln11 = or i32 %shl.ln11, 67108873
  br label %if.end62

if.then57:                                        ; preds = %lor.lhs.false2.i
  %hidden.load.14 = load i192, i192* %hidden.addr, align 32
  call void (...) @_ssdm_SpecKeepArrayLoad(i192 %hidden.load.14) #1
  %lshr.ln732 = lshr i192 %hidden.load.14, 136
  %trunc.ln732 = trunc i192 %lshr.ln732 to i8
  %lshr.ln732.1 = lshr i192 %hidden.load.14, 144
  %trunc.ln732.1 = trunc i192 %lshr.ln732.1 to i8
  %lshr.ln732.2 = lshr i192 %hidden.load.14, 152
  %trunc.ln732.2 = trunc i192 %lshr.ln732.2 to i8
  %lshr.ln732.3 = lshr i192 %hidden.load.14, 176
  %trunc.ln732.3 = trunc i192 %lshr.ln732.3 to i16
  %trunc.ln732.4 = trunc i192 %hidden.load.13 to i16
  %lshr.ln732.4 = lshr i192 %hidden.load.13, 16
  %trunc.ln732.5 = trunc i192 %lshr.ln732.4 to i16
  store i8 %quant.src.id, i8* @"(anonymous namespace)::runtime.expected_quant_source.ref.id", align 512, !alias.scope !15971, !noalias !15974
  store i8 %quant.src.bank, i8* @"(anonymous namespace)::runtime.expected_quant_source.ref.bank", align 512, !alias.scope !15971, !noalias !15974
  store i32 %quant.src.epoch, i32* @"(anonymous namespace)::runtime.expected_quant_source.ref.epoch", align 512, !alias.scope !15971, !noalias !15974
  store i8 %quant.src_region, i8* @"(anonymous namespace)::runtime.expected_quant_source.region", align 512, !alias.scope !15971, !noalias !15974
  store i8 %trunc.ln732, i8* @"(anonymous namespace)::runtime.expected_quant_source.stage", align 512, !alias.scope !15971, !noalias !15974
  store i8 %trunc.ln732.1, i8* @"(anonymous namespace)::runtime.expected_quant_source.layer", align 512, !alias.scope !15971, !noalias !15974
  store i8 %trunc.ln732.2, i8* @"(anonymous namespace)::runtime.expected_quant_source.batch", align 512, !alias.scope !15971, !noalias !15974
  store i8 %space.5, i8* @"(anonymous namespace)::runtime.expected_quant_source.row_space", align 512, !alias.scope !15971, !noalias !15974
  store i16 %trunc.ln732.3, i16* @"(anonymous namespace)::runtime.expected_quant_source.row0", align 512, !alias.scope !15971, !noalias !15974
  store i16 %trunc.ln732.4, i16* @"(anonymous namespace)::runtime.expected_quant_source.rows", align 512, !alias.scope !15971, !noalias !15974
  store i16 %trunc.ln732.5, i16* @"(anonymous namespace)::runtime.expected_quant_source.width", align 512, !alias.scope !15971, !noalias !15974
  store i8 1, i8* @"(anonymous namespace)::runtime.expected_quant_source.content", align 512, !alias.scope !15971, !noalias !15974
  store i1 true, i1* @"(anonymous namespace)::runtime.expected_quant_source_valid", align 512, !alias.scope !15971, !noalias !15974
  %zext.ln230.1 = zext i8 %count to i32
  %mul.ln230 = mul nuw nsw i32 %zext.ln230.1, %zext.ln230
  %lshr.ln230 = lshr i32 %mul.ln230, 5
  call fastcc void @"laya::full::(anonymous namespace)::Controller::issue<laya::QuantTask>"(i16* %ref.tmp58.0231, i32* %ref.tmp58.1232, i64* %ref.tmp58.2233, i8 addrspace(1)* %embedding, i64 %this_memory.0, i8 addrspace(1)* %io, i64 %this_memory.2, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i8 addrspace(1)* %aux, i64 %this_memory.10, i8 addrspace(1)* %state0, i64 %this_memory.12, i8 addrspace(1)* %state1, i64 %this_memory.14, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i8 addrspace(1)* %ff0, i64 %this_memory.20, i8 addrspace(1)* %ff1, i64 %this_memory.22, i8 addrspace(1)* %att_out, i64 %this_memory.24, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i32 %quant.ctx.task_id, i8 2, i8 %layer, i8 %batch, i8 %space.5, i16 %row0, i8 %count, i8 %quant.src.id, i8 %quant.src.bank, i32 %quant.src.epoch, i8 %quant.a_dst.id, i8 %quant.a_dst.bank, i32 %quant.a_dst.epoch, i16 %quant.K, i8 %quant.src_region, i32 %lshr.ln230)
  %ref.tmp58.0231.load = load i16, i16* %ref.tmp58.0231, align 512
  %ref.tmp58.1232.load = load i32, i32* %ref.tmp58.1232, align 512
  %ref.tmp58.2233.load = load i64, i64* %ref.tmp58.2233, align 512
  br label %if.end62

if.end62:                                         ; preds = %if.then57, %_ZN4laya4full22full_bind_quant_sourceERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE.exit
  %.23552 = phi i64 [ %ref.tmp58.2233.load, %if.then57 ], [ -1, %_ZN4laya4full22full_bind_quant_sourceERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE.exit ]
  %.13349 = phi i32 [ %ref.tmp58.1232.load, %if.then57 ], [ %or.ln11, %_ZN4laya4full22full_bind_quant_sourceERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE.exit ]
  %0 = phi i16 [ %ref.tmp58.0231.load, %if.then57 ], [ 5, %_ZN4laya4full22full_bind_quant_sourceERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE.exit ]
  %icmp.ln9.280 = icmp eq i16 %0, 0
  br i1 %icmp.ln9.280, label %if.end65, label %for.inc92.loopexit

if.end65:                                         ; preds = %if.end62
  %hidden.load.15 = load i192, i192* %hidden.addr, align 32
  call void (...) @_ssdm_SpecKeepArrayLoad(i192 %hidden.load.15) #1
  %lshr.ln234 = lshr i192 %hidden.load.15, 160
  %space.6 = trunc i192 %lshr.ln234 to i8
  %"(anonymous namespace)::runtime.last_task_id.load.1" = load i32, i32* @"(anonymous namespace)::runtime.last_task_id", align 512, !alias.scope !15979, !noalias !15982
  %t.ctx.task_id = add i32 %"(anonymous namespace)::runtime.last_task_id.load.1", 1
  %t.w.id = load i8, i8* @"(anonymous namespace)::runtime.current_weight_ref.id", align 512
  %t.w.epoch = load i32, i32* @"(anonymous namespace)::runtime.current_weight_ref.epoch", align 512
  call fastcc void @"laya::full::(anonymous namespace)::Controller::fresh"(i8* %ref.tmp73.0203, i8* %ref.tmp73.1204, i32* %ref.tmp73.2205, i8 36, i8 0, i8 0)
  %t.ps.id = load i8, i8* %ref.tmp73.0203, align 512
  %t.ps.bank = load i8, i8* %ref.tmp73.1204, align 512
  %t.ps.epoch = load i32, i32* %ref.tmp73.2205, align 512
  %zext.ln244.3 = zext i8 %count to i32
  %mul.ln244 = mul nuw nsw i32 %zext.ln244.3, %zext.ln244
  call fastcc void @"laya::full::(anonymous namespace)::Controller::issue<laya::LinearTask>"(i16* %ref.tmp81.0197, i32* %ref.tmp81.1198, i64* %ref.tmp81.2199, i8 addrspace(1)* %io, i64 %this_memory.2, i8 addrspace(1)* %state0, i64 %this_memory.12, i8 addrspace(1)* %state1, i64 %this_memory.14, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i8 addrspace(1)* %ff0, i64 %this_memory.20, i8 addrspace(1)* %ff1, i64 %this_memory.22, i8 addrspace(1)* %att_out, i64 %this_memory.24, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i32 %t.ctx.task_id, i8 50, i8 2, i8 %layer, i8 %batch, i8 %space.6, i16 %row0, i8 %count, i8 %quant.a_dst.id, i8 %quant.a_dst.bank, i32 %quant.a_dst.epoch, i8 %t.w.id, i32 %t.w.epoch, i8 %t.ps.id, i8 %t.ps.bank, i32 %t.ps.epoch, i8 %dst_ref_id, i8 %dst_ref_bank, i32 %dst_ref_epoch, i8 3, i8 %key_layer.val, i16 %quant.K, i16 %width, i8 0, i8 %t.bias_kind, i32 %mul.ln244)
  %ref.tmp81.0197.load = load i16, i16* %ref.tmp81.0197, align 512
  %ref.tmp81.1198.load = load i32, i32* %ref.tmp81.1198, align 512
  %ref.tmp81.2199.load = load i64, i64* %ref.tmp81.2199, align 512
  %icmp.ln9.281 = icmp eq i16 %ref.tmp81.0197.load, 0
  %add.ln220 = add nuw nsw i32 %row.020, 16
  br i1 %icmp.ln9.281, label %for.cond36, label %for.inc92.loopexit

for.inc92.loopexit:                               ; preds = %if.end65, %if.end62
  %c.code.312 = phi i16 [ %0, %if.end62 ], [ %ref.tmp81.0197.load, %if.end65 ]
  %c.detail.306 = phi i32 [ %.13349, %if.end62 ], [ %ref.tmp81.1198.load, %if.end65 ]
  %c.bad_element.281 = phi i64 [ %.23552, %if.end62 ], [ %ref.tmp81.2199.load, %if.end65 ]
  br i1 %icmp.ln220, label %for.inc92.loopexit.split, label %for.inc92

for.inc92.loopexit.split:                         ; preds = %for.inc92.loopexit
  store i16 %c.code.312, i16* %c.code.313, align 512
  store i32 %c.detail.306, i32* %c.detail.307, align 512
  store i64 %c.bad_element.281, i64* %c.bad_element.282, align 512
  br label %for.inc92

for.inc92:                                        ; preds = %for.inc92.loopexit.split, %for.inc92.loopexit, %for.cond.cleanup38.loopexit.split, %for.cond.cleanup38.loopexit
  %.28 = phi i64 [ %c.bad_element.281, %for.inc92.loopexit.split ], [ %.235.phi.lcssa, %for.cond.cleanup38.loopexit.split ], [ %.235.phi.lcssa, %for.cond.cleanup38.loopexit ], [ %c.bad_element.281, %for.inc92.loopexit ]
  %.14 = phi i32 [ %c.detail.306, %for.inc92.loopexit.split ], [ %.133.phi.lcssa, %for.cond.cleanup38.loopexit.split ], [ %.133.phi.lcssa, %for.cond.cleanup38.loopexit ], [ %c.detail.306, %for.inc92.loopexit ]
  %b.20 = add nuw nsw i32 %b, 1
  br label %for.cond, !llvm.loop !15991

if.else99:                                        ; preds = %for.cond
  %cmp.i43.lcssa = phi i1 [ %icmp.ln9.279, %for.cond ]
  %.lcssa = phi i16 [ %c.code.load.12, %for.cond ]
  %.13.lcssa = phi i32 [ %.13, %for.cond ]
  %.27.lcssa = phi i64 [ %.27, %for.cond ]
  br i1 %cmp.i43.lcssa, label %cleanup119, label %if.then102

if.then102:                                       ; preds = %if.else99
  call fastcc void @"laya::full::full_publish_owner"(i16* %ref.tmp103.0185, i32* %ref.tmp103.1186, i64* %ref.tmp103.2187, i8 %dst_ref_id, i8 %dst_ref_bank, i32 %dst_ref_epoch, i8 0, i8 2, i8 %layer, i8 -1, i8 %space, i16 0, i16 %select.ln63, i16 %width, i8 1)
  %c.code = load i16, i16* %ref.tmp103.0185, align 512
  %c.detail.304 = load i32, i32* %ref.tmp103.1186, align 512
  %c.bad_element.279 = load i64, i64* %ref.tmp103.2187, align 512
  store i16 %c.code, i16* %c.code.313, align 512
  store i32 %c.detail.304, i32* %c.detail.307, align 512
  store i64 %c.bad_element.279, i64* %c.bad_element.282, align 512
  br label %cleanup119

cleanup119:                                       ; preds = %if.then102, %if.else99, %if.end, %if.then
  %storemerge72 = phi i16 [ %c.code.load, %if.then ], [ %c.code, %if.then102 ], [ %c.code.311, %if.end ], [ %.lcssa, %if.else99 ]
  %storemerge70 = phi i32 [ %c.detail.303.load, %if.then ], [ %c.detail.304, %if.then102 ], [ %c.detail, %if.end ], [ %.13.lcssa, %if.else99 ]
  %storemerge68 = phi i64 [ %c.bad_element.278.load, %if.then ], [ %c.bad_element.279, %if.then102 ], [ %c.bad_element, %if.end ], [ %.27.lcssa, %if.else99 ]
  store i16 %storemerge72, i16* %agg.result.01, align 512
  store i32 %storemerge70, i32* %agg.result.12, align 512
  store i64 %storemerge68, i64* %agg.result.23, align 512
  ret void
}
