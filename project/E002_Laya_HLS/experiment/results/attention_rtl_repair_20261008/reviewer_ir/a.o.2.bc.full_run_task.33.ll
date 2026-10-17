define internal fastcc { i16, i32, i64, i32, i16, i32, i64, i32, i8 } @"laya::full::full_run_task.33"(i8 addrspace(1)* noalias nocapture %embedding, i64 %memory_embedding, i8 addrspace(1)* noalias nocapture %io, i64 %memory_io, i8 addrspace(1)* noalias nocapture %w_q0, i64 %memory_w_q0, i8 addrspace(1)* noalias nocapture %w_q1, i64 %memory_w_q1, i8 addrspace(1)* noalias nocapture %w_scale, i64 %memory_w_scale, i8 addrspace(1)* noalias nocapture %aux, i64 %memory_aux, i8 addrspace(1)* noalias nocapture %state0, i64 %memory_state0, i8 addrspace(1)* noalias nocapture %state1, i64 %memory_state1, i8 addrspace(1)* noalias nocapture %qkv0, i64 %memory_qkv0, i8 addrspace(1)* noalias nocapture %qkv1, i64 %memory_qkv1, i8 addrspace(1)* noalias nocapture %ff0, i64 %memory_ff0, i8 addrspace(1)* noalias nocapture %ff1, i64 %memory_ff1, i8 addrspace(1)* noalias nocapture %att_out, i64 %memory_att_out, i32 %t_ctx_task_id.val, i3 %t_ctx_stage.val, i5 %t_ctx_layer.val, i8 %t_ctx_batch.val, i16 %t_ctx_row0.val, [2 x i1]* noalias nocapture align 512 %t_qkv_ref_id, [2 x i1]* noalias nocapture align 512 %t_qkv_ref_bank, [2 x i1]* noalias nocapture align 512 %t_qkv_ref_epoch, i8 %t_kv_id.val, i8 %t_kv_bank.val, i32 %t_kv_epoch.val, i8 %t_score_id.val, i8 %t_score_bank.val, i32 %t_score_epoch.val, i4 %t_head.val, i16 %t_S.val) #1 {
entry:
  %t_ctx_layer.val.cast = zext i5 %t_ctx_layer.val to i8
  %t_ctx_stage.val.cast = zext i3 %t_ctx_stage.val to i8
  %cond1 = icmp ugt i3 %t_ctx_stage.val, 2
  %cond2 = icmp ult i3 %t_ctx_stage.val, -3
  %cond3 = and i1 %cond2, %cond1
  call void (...) @_ssdm_Assume(i1 %cond3) #1
  %cond = icmp ugt i3 %t_ctx_stage.val, 1
  %cond34 = and i1 %cond2, %cond
  call void (...) @_ssdm_Assume(i1 %cond34) #1
  %cond35 = icmp ult i5 %t_ctx_layer.val, -4
  call void (...) @_ssdm_Assume(i1 %cond35) #1
  %cond36 = icmp ult i16 %t_ctx_row0.val, -15
  call void (...) @_ssdm_Assume(i1 %cond36) #1
  call void (...) @_ssdm_Assume(i1 true) #1
  call void (...) @_ssdm_Assume(i1 true) #1
  call void (...) @_ssdm_Assume(i1 true) #1
  call void (...) @_ssdm_Assume(i1 true) #1
  call void (...) @_ssdm_Assume(i1 true) #1
  call void (...) @_ssdm_Assume(i1 true) #1
  call void (...) @_ssdm_Assume(i1 true) #1
  call void (...) @_ssdm_Assume(i1 true) #1
  call void (...) @_ssdm_Assume(i1 true) #1
  call void (...) @_ssdm_op_SpecInterface(i8 addrspace(1)* %att_out, [6 x i8]* @26, i32 0, i32 0, [1 x i8]* @38, i32 0, i32 0, [8 x i8]* @163, [6 x i8]* @100, [1 x i8]* @38, i32 1, i32 1, i32 16, i32 16, [1 x i8]* @38, [1 x i8]* @38, i32 -1, i32 0, i32 0, i32 1)
  call void (...) @_ssdm_op_SpecInterface(i8 addrspace(1)* %ff1, [6 x i8]* @26, i32 0, i32 0, [1 x i8]* @38, i32 0, i32 0, [4 x i8]* @117, [6 x i8]* @100, [1 x i8]* @38, i32 1, i32 1, i32 16, i32 16, [1 x i8]* @38, [1 x i8]* @38, i32 -1, i32 0, i32 0, i32 1)
  call void (...) @_ssdm_op_SpecInterface(i8 addrspace(1)* %ff0, [6 x i8]* @26, i32 0, i32 0, [1 x i8]* @38, i32 0, i32 0, [4 x i8]* @218, [6 x i8]* @100, [1 x i8]* @38, i32 1, i32 1, i32 16, i32 16, [1 x i8]* @38, [1 x i8]* @38, i32 -1, i32 0, i32 0, i32 1)
  call void (...) @_ssdm_op_SpecInterface(i8 addrspace(1)* %qkv1, [6 x i8]* @26, i32 0, i32 0, [1 x i8]* @38, i32 0, i32 0, [5 x i8]* @99, [6 x i8]* @100, [1 x i8]* @38, i32 1, i32 1, i32 16, i32 16, [1 x i8]* @38, [1 x i8]* @38, i32 -1, i32 0, i32 0, i32 1)
  call void (...) @_ssdm_op_SpecInterface(i8 addrspace(1)* %qkv0, [6 x i8]* @26, i32 0, i32 0, [1 x i8]* @38, i32 0, i32 0, [5 x i8]* @108, [6 x i8]* @100, [1 x i8]* @38, i32 1, i32 1, i32 16, i32 16, [1 x i8]* @38, [1 x i8]* @38, i32 -1, i32 0, i32 0, i32 1)
  call void (...) @_ssdm_op_SpecInterface(i8 addrspace(1)* %state1, [6 x i8]* @26, i32 0, i32 0, [1 x i8]* @38, i32 0, i32 0, [7 x i8]* @114, [6 x i8]* @100, [1 x i8]* @38, i32 1, i32 1, i32 16, i32 16, [1 x i8]* @38, [1 x i8]* @38, i32 -1, i32 0, i32 0, i32 1)
  call void (...) @_ssdm_op_SpecInterface(i8 addrspace(1)* %state0, [6 x i8]* @26, i32 0, i32 0, [1 x i8]* @38, i32 0, i32 0, [7 x i8]* @113, [6 x i8]* @100, [1 x i8]* @38, i32 1, i32 1, i32 16, i32 16, [1 x i8]* @38, [1 x i8]* @38, i32 -1, i32 0, i32 0, i32 1)
  call void (...) @_ssdm_op_SpecInterface(i8 addrspace(1)* %aux, [6 x i8]* @26, i32 0, i32 0, [1 x i8]* @38, i32 0, i32 0, [4 x i8]* @105, [6 x i8]* @100, [1 x i8]* @38, i32 1, i32 16, i32 16, i32 16, [1 x i8]* @38, [1 x i8]* @38, i32 -1, i32 0, i32 0, i32 1)
  call void (...) @_ssdm_op_SpecInterface(i8 addrspace(1)* %w_scale, [6 x i8]* @26, i32 0, i32 0, [1 x i8]* @38, i32 0, i32 0, [8 x i8]* @50, [6 x i8]* @100, [1 x i8]* @38, i32 1, i32 16, i32 16, i32 16, [1 x i8]* @38, [1 x i8]* @38, i32 -1, i32 0, i32 0, i32 1)
  call void (...) @_ssdm_op_SpecInterface(i8 addrspace(1)* %w_q1, [6 x i8]* @26, i32 0, i32 0, [1 x i8]* @38, i32 0, i32 0, [5 x i8]* @103, [6 x i8]* @100, [1 x i8]* @38, i32 1, i32 16, i32 16, i32 16, [1 x i8]* @38, [1 x i8]* @38, i32 -1, i32 0, i32 0, i32 1)
  call void (...) @_ssdm_op_SpecInterface(i8 addrspace(1)* %w_q0, [6 x i8]* @26, i32 0, i32 0, [1 x i8]* @38, i32 0, i32 0, [5 x i8]* @159, [6 x i8]* @100, [1 x i8]* @38, i32 1, i32 16, i32 16, i32 16, [1 x i8]* @38, [1 x i8]* @38, i32 -1, i32 0, i32 0, i32 1)
  call void (...) @_ssdm_op_SpecInterface(i8 addrspace(1)* %io, [6 x i8]* @26, i32 0, i32 0, [1 x i8]* @38, i32 0, i32 0, [3 x i8]* @116, [6 x i8]* @100, [1 x i8]* @38, i32 1, i32 1, i32 16, i32 16, [1 x i8]* @38, [1 x i8]* @38, i32 -1, i32 0, i32 0, i32 1)
  call void (...) @_ssdm_op_SpecInterface(i8 addrspace(1)* %embedding, [6 x i8]* @26, i32 0, i32 0, [1 x i8]* @38, i32 0, i32 0, [10 x i8]* @160, [6 x i8]* @100, [1 x i8]* @38, i32 1, i32 16, i32 16, i32 16, [1 x i8]* @38, [1 x i8]* @38, i32 -1, i32 0, i32 0, i32 1)
  %"(anonymous namespace)::runtime.request_valid.load" = load i1, i1* @"(anonymous namespace)::runtime.request_valid", align 512, !alias.scope !2965, !noalias !2968
  br i1 %"(anonymous namespace)::runtime.request_valid.load", label %lor.lhs.false.i, label %if.then.i

lor.lhs.false.i:                                  ; preds = %entry
  %"(anonymous namespace)::runtime.model_header_valid.load" = load i1, i1* @"(anonymous namespace)::runtime.model_header_valid", align 512, !alias.scope !2965, !noalias !2968
  br i1 %"(anonymous namespace)::runtime.model_header_valid.load", label %lor.lhs.false1.i, label %if.then.i

lor.lhs.false1.i:                                 ; preds = %lor.lhs.false.i
  %"(anonymous namespace)::runtime.last_task_id.load" = load i32, i32* @"(anonymous namespace)::runtime.last_task_id", align 512, !alias.scope !2965, !noalias !2968
  %add.ln22 = add i32 %"(anonymous namespace)::runtime.last_task_id.load", 1
  %icmp.ln22 = icmp ne i32 %add.ln22, %t_ctx_task_id.val
  %icmp.ln22.10 = icmp eq i32 %t_ctx_task_id.val, -1
  %or.ln22 = or i1 %icmp.ln22, %icmp.ln22.10
  br i1 %or.ln22, label %if.then.i, label %if.end.i

if.then.i:                                        ; preds = %lor.lhs.false1.i, %lor.lhs.false.i, %entry
  br label %_ZN4laya4full4task7contextERKNS0_11FullRuntimeERKNS_11TaskContextE.302.355.exit

if.end.i:                                         ; preds = %lor.lhs.false1.i
  %"(anonymous namespace)::runtime.inputs.identity.B.load" = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.B", align 512, !alias.scope !2965, !noalias !2968
  %"(anonymous namespace)::runtime.inputs.identity.S.load" = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.S", align 512, !alias.scope !2965, !noalias !2968
  %call.ret71 = call fastcc { i16, i32 } @"laya::check_context"(i32 %t_ctx_task_id.val, i8 80, i8 %t_ctx_stage.val.cast, i8 %t_ctx_layer.val.cast, i8 %t_ctx_batch.val, i8 0, i16 %t_ctx_row0.val, i8 16, i16 %"(anonymous namespace)::runtime.inputs.identity.B.load", i16 %"(anonymous namespace)::runtime.inputs.identity.S.load")
  %c.code = extractvalue { i16, i32 } %call.ret71, 0
  %c.detail = extractvalue { i16, i32 } %call.ret71, 1
  br label %_ZN4laya4full4task7contextERKNS0_11FullRuntimeERKNS_11TaskContextE.302.355.exit

_ZN4laya4full4task7contextERKNS0_11FullRuntimeERKNS_11TaskContextE.302.355.exit: ; preds = %if.end.i, %if.then.i
  %c.detail.228.0 = phi i32 [ 122683396, %if.then.i ], [ %c.detail, %if.end.i ]
  %0 = phi i16 [ 7, %if.then.i ], [ %c.code, %if.end.i ]
  %trunc.ln9 = trunc i16 %0 to i4
  %icmp.ln9 = icmp eq i16 %0, 0
  br i1 %icmp.ln9, label %lor.lhs.false, label %if.then

if.then:                                          ; preds = %_ZN4laya4full4task7contextERKNS0_11FullRuntimeERKNS_11TaskContextE.302.355.exit
  %call.ret117 = call fastcc { i16, i32, i64, i32, i16, i32, i64, i32, i8 } @"laya::full::task::finish"(i32 %t_ctx_task_id.val, i7 -48, i4 %trunc.ln9, i32 %c.detail.228.0, i64 -1, i20 0, i4 0, i2 0)
  %newret = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret117, 0
  %newret5 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret117, 1
  %newret7 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret117, 2
  %newret9 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret117, 3
  %newret11 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret117, 4
  %newret13 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret117, 5
  %newret15 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret117, 6
  %newret17 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret117, 7
  %newret19 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret117, 8
  br label %cleanup291

lor.lhs.false:                                    ; preds = %_ZN4laya4full4task7contextERKNS0_11FullRuntimeERKNS_11TaskContextE.302.355.exit
  %icmp.ln143 = icmp eq i3 %t_ctx_stage.val, -4
  %"(anonymous namespace)::runtime.inputs.identity.S.load.6" = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.S", align 512
  %icmp.ln145 = icmp eq i16 %"(anonymous namespace)::runtime.inputs.identity.S.load.6", %t_S.val
  %and.ln145 = and i1 %icmp.ln143, %icmp.ln145
  %call.ret129 = call fastcc { i16, i32, i64, i32, i16, i32, i64, i32, i8 } @"laya::full::task::finish"(i32 %t_ctx_task_id.val, i7 -48, i4 3, i32 122683397, i64 -1, i20 0, i4 0, i2 0)
  %newret21 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret129, 0
  %newret23 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret129, 1
  %newret25 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret129, 2
  %newret27 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret129, 3
  %newret29 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret129, 4
  %newret31 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret129, 5
  %newret33 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret129, 6
  %newret35 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret129, 7
  %newret37 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret129, 8
  br label %cleanup291

cleanup291:                                       ; preds = %lor.lhs.false, %if.then
  %agg.result.0.5 = phi i16 [ %newret, %if.then ], [ %newret21, %lor.lhs.false ]
  %agg.result.1.5 = phi i32 [ %newret5, %if.then ], [ %newret23, %lor.lhs.false ]
  %agg.result.2.5 = phi i64 [ %newret7, %if.then ], [ %newret25, %lor.lhs.false ]
  %done_task_id.5 = phi i32 [ %newret9, %if.then ], [ %newret27, %lor.lhs.false ]
  %done_status.5 = phi i16 [ %newret11, %if.then ], [ %newret29, %lor.lhs.false ]
  %done_error_detail.5 = phi i32 [ %newret13, %if.then ], [ %newret31, %lor.lhs.false ]
  %done_bad_element.5 = phi i64 [ %newret15, %if.then ], [ %newret33, %lor.lhs.false ]
  %done_output_elements.5 = phi i32 [ %newret17, %if.then ], [ %newret35, %lor.lhs.false ]
  %done_output_unit.5 = phi i8 [ %newret19, %if.then ], [ %newret37, %lor.lhs.false ]
  %newret2 = insertvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } undef, i16 %agg.result.0.5, 0
  %newret4 = insertvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %newret2, i32 %agg.result.1.5, 1
  %newret6 = insertvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %newret4, i64 %agg.result.2.5, 2
  %newret8 = insertvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %newret6, i32 %done_task_id.5, 3
  %newret10 = insertvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %newret8, i16 %done_status.5, 4
  %newret12 = insertvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %newret10, i32 %done_error_detail.5, 5
  %newret14 = insertvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %newret12, i64 %done_bad_element.5, 6
  %newret16 = insertvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %newret14, i32 %done_output_elements.5, 7
  %newret18 = insertvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %newret16, i8 %done_output_unit.5, 8
  ret { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %newret18
}
