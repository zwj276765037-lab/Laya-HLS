`timescale 1ns/1ps
// Compatibility shell: one pure layer and one physical instance of every service.
module laya_attention_layer_v1(
 input logic clk,rst_n,
 input logic prepare_valid,output logic prepare_ready,input logic[63:0]prepare_request_id,input logic[127:0]prepare_model_id,input logic[31:0]prepare_generation,prepare_epoch,input logic[127:0]prepare_numeric_id,input logic[127:0]prepare_table_key,input logic[1:0]prepare_kind,input logic[4:0]prepare_layer,input logic[127:0]prepare_mask,
 input logic qkv_wr_valid,output logic qkv_wr_ready,input logic[63:0]qkv_wr_request_id,input logic[31:0]qkv_wr_generation,qkv_wr_epoch,input logic[1:0]qkv_wr_plane,input logic[3:0]qkv_wr_head,input logic[6:0]qkv_wr_token,input logic qkv_wr_half,input logic[31:0][31:0]qkv_wr_data,
 input logic start_valid,output logic start_ready,input logic[63:0]start_request_id,input logic[31:0]start_generation,
 output logic reject_valid,output logic[3:0]reject_code,
 input logic abort_valid,output logic abort_ready,input logic[2:0]qkv_read_grant,input logic ps_grant,g_grant,context_grant,fp_grant,sfu_grant,exp_grant,div_grant,rope_write_grant,
 output logic done_valid,input logic done_ready,output logic[63:0]done_request_id,output logic[31:0]done_generation,output logic[7:0]done_status,output logic[31:0]done_cycles,rope_cycles,output logic[15:0]head_completed,head_context_valid,output logic[3:0]active_head,
 output logic error_valid,output logic[95:0]error_tuple,output logic[25:0][15:0]check_completed,check_unreachable,check_dominated,output logic[2047:0]av_check_completed,av_check_unreachable,av_check_dominated,
 input logic result_rd_valid,output logic result_rd_ready,input logic[31:0]result_rd_generation,result_rd_tag,input logic[3:0]result_rd_head,input logic[6:0]result_rd_query,input logic result_rd_half,output logic result_rsp_valid,input logic result_rsp_ready,output logic[31:0]result_rsp_tag,output logic[31:0][31:0]result_rsp_data,
 input logic result_discard_valid,output logic result_discard_ready,input logic[31:0]result_discard_generation,output logic context_discarded,output logic[31:0]producer_done_cycles,context_release_cycles,
 input logic coeff_bind_valid,
 output logic coeff_bind_ready,
 input logic[127:0] coeff_bind_model_id,
 input logic[127:0] coeff_bind_numeric_id,
 input logic[127:0] coeff_bind_table_key,
 output logic coeff_bound_valid,
 output logic[127:0] coeff_bound_model_id,
 output logic[127:0] coeff_bound_numeric_id,
 output logic[127:0] coeff_bound_table_key,
 output logic[1:0] coeff_family_complete,
 input logic coeff_wr_valid,
 output logic coeff_wr_ready,
 input logic[127:0] coeff_wr_model_id,
 input logic[127:0] coeff_wr_numeric_id,
 input logic[127:0] coeff_wr_table_key,
 input logic[1:0] coeff_wr_table,
 input logic[6:0] coeff_wr_row,
 input logic coeff_wr_half,
 input logic[31:0][31:0] coeff_wr_data,
 output logic coeff_wr_reject_valid,
 output logic[2:0] coeff_wr_reject_code,
 output logic[4:0] coeff_wr_nonfinite_lane,
 input logic prepare_cancel_valid,output logic prepare_cancel_ready,input logic[63:0]prepare_cancel_request_id,input logic[31:0]prepare_cancel_generation,prepare_cancel_epoch,
 output logic prepare_cancel_rsp_valid,input logic prepare_cancel_rsp_ready,output logic[63:0]prepare_cancel_rsp_request_id,output logic[31:0]prepare_cancel_rsp_generation,prepare_cancel_rsp_epoch,output logic[7:0]prepare_cancel_rsp_status,
 output logic layer_idle,check_coverage_fault,output logic[31:0]check_first_conflict
);
 logic res_qkv_wr_valid;
 logic res_qkv_wr_ready;
 logic[1:0] res_qkv_wr_plane;
 logic[3:0] res_qkv_wr_head;
 logic[6:0] res_qkv_wr_token;
 logic res_qkv_wr_half;
 logic[31:0][31:0] res_qkv_wr_data;
 logic[2:0] res_qkv_rd_valid;
 logic[2:0] res_qkv_rd_ready;
 logic[2:0][3:0] res_qkv_rd_head;
 logic[2:0][6:0] res_qkv_rd_token;
 logic[2:0][31:0] res_qkv_rd_tag;
 logic[2:0] res_qkv_rd_rsp_valid;
 logic[2:0] res_qkv_rd_rsp_ready;
 logic[2:0][3:0] res_qkv_rd_rsp_head;
 logic[2:0][6:0] res_qkv_rd_rsp_token;
 logic[2:0][31:0] res_qkv_rd_rsp_tag;
 logic[2:0][63:0][31:0] res_qkv_rd_rsp_data;
 logic res_st_bind_valid;
 logic res_st_bind_ready;
 logic[63:0] res_st_bind_request_id;
 logic[31:0] res_st_bind_generation;
 logic[31:0] res_st_bind_epoch;
 logic[3:0] res_st_bind_head;
 logic[2:0] res_st_bind_phase;
 logic[63:0] res_st_op_request_id;
 logic[31:0] res_st_op_generation;
 logic[31:0] res_st_op_epoch;
 logic[2:0] res_st_op_phase;
 logic[63:0] res_st_rsp_request_id;
 logic[31:0] res_st_rsp_generation;
 logic[31:0] res_st_rsp_epoch;
 logic[3:0] res_st_rsp_head;
 logic[2:0] res_st_rsp_phase;
 logic res_st_ps_wr_valid;
 logic res_st_ps_wr_ready;
 logic[1023:0] res_st_ps_wr_mask;
 logic[1023:0][3:0] res_st_ps_wr_addr;
 logic[1023:0][31:0] res_st_ps_wr_data;
 logic[95:0] res_st_ps_wr_tag;
 logic res_st_ps_wr_rsp_valid;
 logic res_st_ps_wr_rsp_ready;
 logic[95:0] res_st_ps_wr_rsp_tag;
 logic res_st_ps_rd_valid;
 logic res_st_ps_rd_ready;
 logic[1023:0] res_st_ps_rd_mask;
 logic[1023:0][3:0] res_st_ps_rd_addr;
 logic[95:0] res_st_ps_rd_tag;
 logic res_st_ps_rd_rsp_valid;
 logic res_st_ps_rd_rsp_ready;
 logic[1023:0][31:0] res_st_ps_rd_rsp_data;
 logic[1023:0] res_st_ps_rd_rsp_mask;
 logic[95:0] res_st_ps_rd_rsp_tag;
 logic res_st_g_wr_valid;
 logic res_st_g_wr_ready;
 logic[255:0] res_st_g_wr_mask;
 logic[255:0][5:0] res_st_g_wr_addr;
 logic[255:0][31:0] res_st_g_wr_data;
 logic[95:0] res_st_g_wr_tag;
 logic res_st_g_wr_rsp_valid;
 logic res_st_g_wr_rsp_ready;
 logic[95:0] res_st_g_wr_rsp_tag;
 logic res_st_g_rd_valid;
 logic res_st_g_rd_ready;
 logic[255:0] res_st_g_rd_mask;
 logic[255:0][5:0] res_st_g_rd_addr;
 logic[95:0] res_st_g_rd_tag;
 logic res_st_g_rd_rsp_valid;
 logic res_st_g_rd_rsp_ready;
 logic[255:0][31:0] res_st_g_rd_rsp_data;
 logic[255:0] res_st_g_rd_rsp_mask;
 logic[95:0] res_st_g_rd_rsp_tag;
 logic res_st_context_wr_valid;
 logic res_st_context_wr_ready;
 logic[63:0] res_st_context_wr_mask;
 logic[63:0][10:0] res_st_context_wr_addr;
 logic[63:0][31:0] res_st_context_wr_data;
 logic[95:0] res_st_context_wr_tag;
 logic res_st_context_wr_rsp_valid;
 logic res_st_context_wr_rsp_ready;
 logic[95:0] res_st_context_wr_rsp_tag;
 logic res_st_context_rd_valid;
 logic res_st_context_rd_ready;
 logic[63:0] res_st_context_rd_mask;
 logic[63:0][10:0] res_st_context_rd_addr;
 logic[95:0] res_st_context_rd_tag;
 logic res_st_context_rd_rsp_valid;
 logic res_st_context_rd_rsp_ready;
 logic[63:0][31:0] res_st_context_rd_rsp_data;
 logic[63:0] res_st_context_rd_rsp_mask;
 logic[95:0] res_st_context_rd_rsp_tag;
 logic res_st_idle;
 logic res_fp_lease_valid;
 logic res_fp_lease_ready;
 logic[63:0] res_fp_lease_request_id;
 logic[31:0] res_fp_lease_generation;
 logic[31:0] res_fp_lease_epoch;
 logic[3:0] res_fp_lease_head;
 logic[2:0] res_fp_lease_phase;
 logic res_fp_release_valid;
 logic res_fp_release_ready;
 logic[2:0] res_fp_release_phase;
 logic[31:0] res_fp_release_epoch;
 logic res_fp_phase_debt_clear;
 logic res_fp_lease_active;
 logic res_fp_draining;
 logic[63:0] res_fp_rsp_request_id;
 logic[31:0] res_fp_rsp_generation;
 logic[31:0] res_fp_rsp_epoch;
 logic[3:0] res_fp_rsp_head;
 logic[2:0] res_fp_rsp_phase;
 logic res_fp_mul_req_valid;
 logic res_fp_mul_req_ready;
 logic[2:0] res_fp_mul_req_phase;
 logic[31:0] res_fp_mul_req_epoch;
 logic[95:0] res_fp_mul_req_tag;
 logic[255:0][31:0] res_fp_mul_a;
 logic[255:0][31:0] res_fp_mul_b;
 logic res_fp_mul_rsp_valid;
 logic res_fp_mul_rsp_ready;
 logic[95:0] res_fp_mul_rsp_tag;
 logic[255:0][31:0] res_fp_mul_rsp_data;
 logic[6:0] res_fp_add_req_valid;
 logic[6:0] res_fp_add_req_is_root;
 logic[6:0] res_fp_add_req_ready;
 logic[6:0][2:0] res_fp_add_req_phase;
 logic[6:0][31:0] res_fp_add_req_epoch;
 logic[6:0][95:0] res_fp_add_req_tag;
 logic[255:0][31:0] res_fp_add_a;
 logic[255:0][31:0] res_fp_add_b;
 logic[6:0] res_fp_add_rsp_valid;
 logic[6:0] res_fp_add_rsp_ready;
 logic[6:0][95:0] res_fp_add_rsp_tag;
 logic[255:0][31:0] res_fp_add_rsp_data;
 logic[6:0] res_fp_mul_pending;
 logic[6:0][6:0] res_fp_add_pending;
 logic res_fp_protocol_fault;
 logic res_ln_bind_valid;
 logic res_ln_bind_ready;
 logic[63:0] res_ln_bind_request_id;
 logic[31:0] res_ln_bind_generation;
 logic[31:0] res_ln_bind_epoch;
 logic[3:0] res_ln_bind_head;
 logic[2:0] res_ln_bind_phase;
 logic[63:0] res_ln_op_request_id;
 logic[31:0] res_ln_op_generation;
 logic[31:0] res_ln_op_epoch;
 logic[2:0] res_ln_op_phase;
 logic[63:0] res_ln_rsp_request_id;
 logic[31:0] res_ln_rsp_generation;
 logic[31:0] res_ln_rsp_epoch;
 logic[3:0] res_ln_rsp_head;
 logic[2:0] res_ln_rsp_phase;
 logic res_ln_wr_valid;
 logic res_ln_wr_ready;
 logic[255:0] res_ln_wr_mask;
 logic[255:0][4:0] res_ln_wr_addr;
 logic[255:0][31:0] res_ln_wr_data;
 logic[95:0] res_ln_wr_tag;
 logic res_ln_wr_rsp_valid;
 logic res_ln_wr_rsp_ready;
 logic[95:0] res_ln_wr_rsp_tag;
 logic res_ln_rd_valid;
 logic res_ln_rd_ready;
 logic[255:0] res_ln_rd_mask;
 logic[255:0][4:0] res_ln_rd_addr;
 logic[95:0] res_ln_rd_tag;
 logic res_ln_rd_rsp_valid;
 logic res_ln_rd_rsp_ready;
 logic[255:0][31:0] res_ln_rd_rsp_data;
 logic[255:0] res_ln_rd_rsp_mask;
 logic[95:0] res_ln_rd_rsp_tag;
 logic res_ln_idle;
 logic res_sfu_lease_valid;
 logic res_sfu_lease_ready;
 logic[63:0] res_sfu_lease_request_id;
 logic[31:0] res_sfu_lease_generation;
 logic[31:0] res_sfu_lease_epoch;
 logic[3:0] res_sfu_lease_head;
 logic[2:0] res_sfu_lease_phase;
 logic res_sfu_release_valid;
 logic[2:0] res_sfu_release_phase;
 logic[31:0] res_sfu_release_epoch;
 logic res_sfu_phase_debt_clear;
 logic res_sfu_lease_active;
 logic[63:0] res_sfu_context_valid;
 logic[63:0] res_sfu_context_row_hi;
 logic res_sfu_req_valid;
 logic res_sfu_req_ready;
 logic[1:0] res_sfu_req_mode;
 logic[31:0] res_sfu_req_generation;
 logic[31:0] res_sfu_req_epoch;
 logic[2:0] res_sfu_req_phase;
 logic[10:0] res_sfu_req_tag;
 logic[7:0][31:0] res_sfu_req_x;
 logic res_sfu_reject_valid;
 logic res_sfu_rsp_valid;
 logic res_sfu_rsp_ready;
 logic[10:0] res_sfu_rsp_tag;
 logic[7:0][31:0] res_sfu_rsp_data;
 logic[8:0] res_sfu_pending_vectors;
 logic[8:0] res_sfu_in_flight_vectors;
 logic res_sfu_protocol_fault;
 logic res_div_lease_valid;
 logic res_div_lease_ready;
 logic[63:0] res_div_lease_request_id;
 logic[31:0] res_div_lease_generation;
 logic[31:0] res_div_lease_epoch;
 logic[3:0] res_div_lease_head;
 logic[2:0] res_div_lease_phase;
 logic res_div_release_valid;
 logic[2:0] res_div_release_phase;
 logic[31:0] res_div_release_epoch;
 logic res_div_phase_debt_clear;
 logic res_div_lease_active;
 logic res_div_req_valid;
 logic res_div_req_ready;
 logic[31:0] res_div_req_generation;
 logic[31:0] res_div_req_epoch;
 logic[2:0] res_div_req_phase;
 logic[7:0] res_div_req_lane_mask;
 logic[95:0] res_div_req_tag;
 logic[7:0][31:0] res_div_req_a;
 logic[7:0][31:0] res_div_req_b;
 logic res_div_protocol_reject_valid;
 logic res_div_rsp_valid;
 logic res_div_rsp_ready;
 logic[95:0] res_div_rsp_tag;
 logic[7:0] res_div_rsp_numeric_error;
 logic[7:0][31:0] res_div_rsp_data;
 logic[5:0] res_div_pending_vectors;
 logic[5:0] res_div_in_flight_vectors;
 logic[8:0] res_div_in_flight_scalars;
 logic res_div_protocol_fault;
 logic res_scale_valid;
 logic res_scale_ready;
 logic[95:0] res_scale_tag;
 logic[3:0][31:0] res_scale_input;
 logic res_scale_rsp_valid;
 logic res_scale_rsp_ready;
 logic[95:0] res_scale_rsp_tag;
 logic[3:0][31:0] res_scale_data;
 logic[6:0] res_scale_pending;
 logic res_scale_fault;
 logic rope_owner_valid;
 logic[63:0] rope_owner_request_id;
 logic[31:0] rope_owner_generation;
 logic[31:0] rope_owner_epoch;
 logic rope_wr_valid;
 logic rope_wr_ready;
 logic[63:0] rope_wr_request_id;
 logic[31:0] rope_wr_generation;
 logic[31:0] rope_wr_epoch;
 logic[3:0] rope_wr_head;
 logic[6:0] rope_wr_token;
 logic[95:0] rope_wr_tag;
 logic[63:0][31:0] rope_wr_q;
 logic[63:0][31:0] rope_wr_k;
 logic rope_wr_commit_valid;
 logic[95:0] rope_wr_commit_tag;
 logic rope_reject_valid;
 logic[2:0] rope_reject_code;
 logic cache_owner_valid;
 logic[63:0] cache_owner_request_id;
 logic[31:0] cache_owner_generation;
 logic[31:0] cache_owner_epoch;
 logic cache_rd_valid;
 logic cache_rd_ready;
 logic cache_rd_family;
 logic[6:0] cache_rd_row;
 logic[95:0] cache_rd_tag;
 logic[63:0] cache_rd_request_id;
 logic[31:0] cache_rd_generation;
 logic[31:0] cache_rd_epoch;
 logic cache_rd_reject_valid;
 logic[2:0] cache_rd_reject_code;
 logic cache_rsp_valid;
 logic cache_rsp_ready;
 logic cache_rsp_family;
 logic[6:0] cache_rsp_row;
 logic[95:0] cache_rsp_tag;
 logic[127:0][31:0] cache_rsp_data;
 laya_attention_layer_engine_v1 engine(
  .clk(clk),
  .rst_n(rst_n),
  .prepare_valid(prepare_valid),
  .prepare_ready(prepare_ready),
  .logicprepare_request_id(logicprepare_request_id),
  .logicprepare_model_id(logicprepare_model_id),
  .logicprepare_generation(logicprepare_generation),
  .prepare_epoch(prepare_epoch),
  .logicprepare_numeric_id(logicprepare_numeric_id),
  .logicprepare_table_key(logicprepare_table_key),
  .logicprepare_kind(logicprepare_kind),
  .logicprepare_layer(logicprepare_layer),
  .logicprepare_mask(logicprepare_mask),
  .qkv_wr_valid(qkv_wr_valid),
  .qkv_wr_ready(qkv_wr_ready),
  .logicqkv_wr_request_id(logicqkv_wr_request_id),
  .logicqkv_wr_generation(logicqkv_wr_generation),
  .qkv_wr_epoch(qkv_wr_epoch),
  .logicqkv_wr_plane(logicqkv_wr_plane),
  .logicqkv_wr_head(logicqkv_wr_head),
  .logicqkv_wr_token(logicqkv_wr_token),
  .qkv_wr_half(qkv_wr_half),
  .logicqkv_wr_data(logicqkv_wr_data),
  .start_valid(start_valid),
  .start_ready(start_ready),
  .logicstart_request_id(logicstart_request_id),
  .logicstart_generation(logicstart_generation),
  .reject_valid(reject_valid),
  .logicreject_code(logicreject_code),
  .abort_valid(abort_valid),
  .abort_ready(abort_ready),
  .logicqkv_read_grant(logicqkv_read_grant),
  .ps_grant(ps_grant),
  .g_grant(g_grant),
  .context_grant(context_grant),
  .fp_grant(fp_grant),
  .sfu_grant(sfu_grant),
  .exp_grant(exp_grant),
  .div_grant(div_grant),
  .rope_write_grant(rope_write_grant),
  .done_valid(done_valid),
  .done_ready(done_ready),
  .logicdone_request_id(logicdone_request_id),
  .logicdone_generation(logicdone_generation),
  .logicdone_status(logicdone_status),
  .logicdone_cycles(logicdone_cycles),
  .rope_cycles(rope_cycles),
  .logichead_completed(logichead_completed),
  .head_context_valid(head_context_valid),
  .logicactive_head(logicactive_head),
  .error_valid(error_valid),
  .logicerror_tuple(logicerror_tuple),
  .logiccheck_completed(logiccheck_completed),
  .check_unreachable(check_unreachable),
  .check_dominated(check_dominated),
  .logicav_check_completed(logicav_check_completed),
  .av_check_unreachable(av_check_unreachable),
  .av_check_dominated(av_check_dominated),
  .result_rd_valid(result_rd_valid),
  .result_rd_ready(result_rd_ready),
  .logicresult_rd_generation(logicresult_rd_generation),
  .result_rd_tag(result_rd_tag),
  .logicresult_rd_head(logicresult_rd_head),
  .logicresult_rd_query(logicresult_rd_query),
  .result_rd_half(result_rd_half),
  .result_rsp_valid(result_rsp_valid),
  .result_rsp_ready(result_rsp_ready),
  .logicresult_rsp_tag(logicresult_rsp_tag),
  .logicresult_rsp_data(logicresult_rsp_data),
  .result_discard_valid(result_discard_valid),
  .result_discard_ready(result_discard_ready),
  .logicresult_discard_generation(logicresult_discard_generation),
  .context_discarded(context_discarded),
  .logicproducer_done_cycles(logicproducer_done_cycles),
  .context_release_cycles(context_release_cycles),
  .prepare_cancel_valid(prepare_cancel_valid),
  .prepare_cancel_ready(prepare_cancel_ready),
  .logicprepare_cancel_request_id(logicprepare_cancel_request_id),
  .logicprepare_cancel_generation(logicprepare_cancel_generation),
  .prepare_cancel_epoch(prepare_cancel_epoch),
  .prepare_cancel_rsp_valid(prepare_cancel_rsp_valid),
  .prepare_cancel_rsp_ready(prepare_cancel_rsp_ready),
  .logicprepare_cancel_rsp_request_id(logicprepare_cancel_rsp_request_id),
  .logicprepare_cancel_rsp_generation(logicprepare_cancel_rsp_generation),
  .prepare_cancel_rsp_epoch(prepare_cancel_rsp_epoch),
  .logicprepare_cancel_rsp_status(logicprepare_cancel_rsp_status),
  .layer_idle(layer_idle),
  .check_coverage_fault(check_coverage_fault),
  .logiccheck_first_conflict(logiccheck_first_conflict),
  .res_qkv_wr_valid(res_qkv_wr_valid),
  .res_qkv_wr_ready(res_qkv_wr_ready),
  .res_qkv_wr_plane(res_qkv_wr_plane),
  .res_qkv_wr_head(res_qkv_wr_head),
  .res_qkv_wr_token(res_qkv_wr_token),
  .res_qkv_wr_half(res_qkv_wr_half),
  .res_qkv_wr_data(res_qkv_wr_data),
  .res_qkv_rd_valid(res_qkv_rd_valid),
  .res_qkv_rd_ready(res_qkv_rd_ready),
  .res_qkv_rd_head(res_qkv_rd_head),
  .res_qkv_rd_token(res_qkv_rd_token),
  .res_qkv_rd_tag(res_qkv_rd_tag),
  .res_qkv_rd_rsp_valid(res_qkv_rd_rsp_valid),
  .res_qkv_rd_rsp_ready(res_qkv_rd_rsp_ready),
  .res_qkv_rd_rsp_head(res_qkv_rd_rsp_head),
  .res_qkv_rd_rsp_token(res_qkv_rd_rsp_token),
  .res_qkv_rd_rsp_tag(res_qkv_rd_rsp_tag),
  .res_qkv_rd_rsp_data(res_qkv_rd_rsp_data),
  .res_st_bind_valid(res_st_bind_valid),
  .res_st_bind_ready(res_st_bind_ready),
  .res_st_bind_request_id(res_st_bind_request_id),
  .res_st_bind_generation(res_st_bind_generation),
  .res_st_bind_epoch(res_st_bind_epoch),
  .res_st_bind_head(res_st_bind_head),
  .res_st_bind_phase(res_st_bind_phase),
  .res_st_op_request_id(res_st_op_request_id),
  .res_st_op_generation(res_st_op_generation),
  .res_st_op_epoch(res_st_op_epoch),
  .res_st_op_phase(res_st_op_phase),
  .res_st_rsp_request_id(res_st_rsp_request_id),
  .res_st_rsp_generation(res_st_rsp_generation),
  .res_st_rsp_epoch(res_st_rsp_epoch),
  .res_st_rsp_head(res_st_rsp_head),
  .res_st_rsp_phase(res_st_rsp_phase),
  .res_st_ps_wr_valid(res_st_ps_wr_valid),
  .res_st_ps_wr_ready(res_st_ps_wr_ready),
  .res_st_ps_wr_mask(res_st_ps_wr_mask),
  .res_st_ps_wr_addr(res_st_ps_wr_addr),
  .res_st_ps_wr_data(res_st_ps_wr_data),
  .res_st_ps_wr_tag(res_st_ps_wr_tag),
  .res_st_ps_wr_rsp_valid(res_st_ps_wr_rsp_valid),
  .res_st_ps_wr_rsp_ready(res_st_ps_wr_rsp_ready),
  .res_st_ps_wr_rsp_tag(res_st_ps_wr_rsp_tag),
  .res_st_ps_rd_valid(res_st_ps_rd_valid),
  .res_st_ps_rd_ready(res_st_ps_rd_ready),
  .res_st_ps_rd_mask(res_st_ps_rd_mask),
  .res_st_ps_rd_addr(res_st_ps_rd_addr),
  .res_st_ps_rd_tag(res_st_ps_rd_tag),
  .res_st_ps_rd_rsp_valid(res_st_ps_rd_rsp_valid),
  .res_st_ps_rd_rsp_ready(res_st_ps_rd_rsp_ready),
  .res_st_ps_rd_rsp_data(res_st_ps_rd_rsp_data),
  .res_st_ps_rd_rsp_mask(res_st_ps_rd_rsp_mask),
  .res_st_ps_rd_rsp_tag(res_st_ps_rd_rsp_tag),
  .res_st_g_wr_valid(res_st_g_wr_valid),
  .res_st_g_wr_ready(res_st_g_wr_ready),
  .res_st_g_wr_mask(res_st_g_wr_mask),
  .res_st_g_wr_addr(res_st_g_wr_addr),
  .res_st_g_wr_data(res_st_g_wr_data),
  .res_st_g_wr_tag(res_st_g_wr_tag),
  .res_st_g_wr_rsp_valid(res_st_g_wr_rsp_valid),
  .res_st_g_wr_rsp_ready(res_st_g_wr_rsp_ready),
  .res_st_g_wr_rsp_tag(res_st_g_wr_rsp_tag),
  .res_st_g_rd_valid(res_st_g_rd_valid),
  .res_st_g_rd_ready(res_st_g_rd_ready),
  .res_st_g_rd_mask(res_st_g_rd_mask),
  .res_st_g_rd_addr(res_st_g_rd_addr),
  .res_st_g_rd_tag(res_st_g_rd_tag),
  .res_st_g_rd_rsp_valid(res_st_g_rd_rsp_valid),
  .res_st_g_rd_rsp_ready(res_st_g_rd_rsp_ready),
  .res_st_g_rd_rsp_data(res_st_g_rd_rsp_data),
  .res_st_g_rd_rsp_mask(res_st_g_rd_rsp_mask),
  .res_st_g_rd_rsp_tag(res_st_g_rd_rsp_tag),
  .res_st_context_wr_valid(res_st_context_wr_valid),
  .res_st_context_wr_ready(res_st_context_wr_ready),
  .res_st_context_wr_mask(res_st_context_wr_mask),
  .res_st_context_wr_addr(res_st_context_wr_addr),
  .res_st_context_wr_data(res_st_context_wr_data),
  .res_st_context_wr_tag(res_st_context_wr_tag),
  .res_st_context_wr_rsp_valid(res_st_context_wr_rsp_valid),
  .res_st_context_wr_rsp_ready(res_st_context_wr_rsp_ready),
  .res_st_context_wr_rsp_tag(res_st_context_wr_rsp_tag),
  .res_st_context_rd_valid(res_st_context_rd_valid),
  .res_st_context_rd_ready(res_st_context_rd_ready),
  .res_st_context_rd_mask(res_st_context_rd_mask),
  .res_st_context_rd_addr(res_st_context_rd_addr),
  .res_st_context_rd_tag(res_st_context_rd_tag),
  .res_st_context_rd_rsp_valid(res_st_context_rd_rsp_valid),
  .res_st_context_rd_rsp_ready(res_st_context_rd_rsp_ready),
  .res_st_context_rd_rsp_data(res_st_context_rd_rsp_data),
  .res_st_context_rd_rsp_mask(res_st_context_rd_rsp_mask),
  .res_st_context_rd_rsp_tag(res_st_context_rd_rsp_tag),
  .res_st_idle(res_st_idle),
  .res_fp_lease_valid(res_fp_lease_valid),
  .res_fp_lease_ready(res_fp_lease_ready),
  .res_fp_lease_request_id(res_fp_lease_request_id),
  .res_fp_lease_generation(res_fp_lease_generation),
  .res_fp_lease_epoch(res_fp_lease_epoch),
  .res_fp_lease_head(res_fp_lease_head),
  .res_fp_lease_phase(res_fp_lease_phase),
  .res_fp_release_valid(res_fp_release_valid),
  .res_fp_release_ready(res_fp_release_ready),
  .res_fp_release_phase(res_fp_release_phase),
  .res_fp_release_epoch(res_fp_release_epoch),
  .res_fp_phase_debt_clear(res_fp_phase_debt_clear),
  .res_fp_lease_active(res_fp_lease_active),
  .res_fp_draining(res_fp_draining),
  .res_fp_rsp_request_id(res_fp_rsp_request_id),
  .res_fp_rsp_generation(res_fp_rsp_generation),
  .res_fp_rsp_epoch(res_fp_rsp_epoch),
  .res_fp_rsp_head(res_fp_rsp_head),
  .res_fp_rsp_phase(res_fp_rsp_phase),
  .res_fp_mul_req_valid(res_fp_mul_req_valid),
  .res_fp_mul_req_ready(res_fp_mul_req_ready),
  .res_fp_mul_req_phase(res_fp_mul_req_phase),
  .res_fp_mul_req_epoch(res_fp_mul_req_epoch),
  .res_fp_mul_req_tag(res_fp_mul_req_tag),
  .res_fp_mul_a(res_fp_mul_a),
  .res_fp_mul_b(res_fp_mul_b),
  .res_fp_mul_rsp_valid(res_fp_mul_rsp_valid),
  .res_fp_mul_rsp_ready(res_fp_mul_rsp_ready),
  .res_fp_mul_rsp_tag(res_fp_mul_rsp_tag),
  .res_fp_mul_rsp_data(res_fp_mul_rsp_data),
  .res_fp_add_req_valid(res_fp_add_req_valid),
  .res_fp_add_req_is_root(res_fp_add_req_is_root),
  .res_fp_add_req_ready(res_fp_add_req_ready),
  .res_fp_add_req_phase(res_fp_add_req_phase),
  .res_fp_add_req_epoch(res_fp_add_req_epoch),
  .res_fp_add_req_tag(res_fp_add_req_tag),
  .res_fp_add_a(res_fp_add_a),
  .res_fp_add_b(res_fp_add_b),
  .res_fp_add_rsp_valid(res_fp_add_rsp_valid),
  .res_fp_add_rsp_ready(res_fp_add_rsp_ready),
  .res_fp_add_rsp_tag(res_fp_add_rsp_tag),
  .res_fp_add_rsp_data(res_fp_add_rsp_data),
  .res_fp_mul_pending(res_fp_mul_pending),
  .res_fp_add_pending(res_fp_add_pending),
  .res_fp_protocol_fault(res_fp_protocol_fault),
  .res_ln_bind_valid(res_ln_bind_valid),
  .res_ln_bind_ready(res_ln_bind_ready),
  .res_ln_bind_request_id(res_ln_bind_request_id),
  .res_ln_bind_generation(res_ln_bind_generation),
  .res_ln_bind_epoch(res_ln_bind_epoch),
  .res_ln_bind_head(res_ln_bind_head),
  .res_ln_bind_phase(res_ln_bind_phase),
  .res_ln_op_request_id(res_ln_op_request_id),
  .res_ln_op_generation(res_ln_op_generation),
  .res_ln_op_epoch(res_ln_op_epoch),
  .res_ln_op_phase(res_ln_op_phase),
  .res_ln_rsp_request_id(res_ln_rsp_request_id),
  .res_ln_rsp_generation(res_ln_rsp_generation),
  .res_ln_rsp_epoch(res_ln_rsp_epoch),
  .res_ln_rsp_head(res_ln_rsp_head),
  .res_ln_rsp_phase(res_ln_rsp_phase),
  .res_ln_wr_valid(res_ln_wr_valid),
  .res_ln_wr_ready(res_ln_wr_ready),
  .res_ln_wr_mask(res_ln_wr_mask),
  .res_ln_wr_addr(res_ln_wr_addr),
  .res_ln_wr_data(res_ln_wr_data),
  .res_ln_wr_tag(res_ln_wr_tag),
  .res_ln_wr_rsp_valid(res_ln_wr_rsp_valid),
  .res_ln_wr_rsp_ready(res_ln_wr_rsp_ready),
  .res_ln_wr_rsp_tag(res_ln_wr_rsp_tag),
  .res_ln_rd_valid(res_ln_rd_valid),
  .res_ln_rd_ready(res_ln_rd_ready),
  .res_ln_rd_mask(res_ln_rd_mask),
  .res_ln_rd_addr(res_ln_rd_addr),
  .res_ln_rd_tag(res_ln_rd_tag),
  .res_ln_rd_rsp_valid(res_ln_rd_rsp_valid),
  .res_ln_rd_rsp_ready(res_ln_rd_rsp_ready),
  .res_ln_rd_rsp_data(res_ln_rd_rsp_data),
  .res_ln_rd_rsp_mask(res_ln_rd_rsp_mask),
  .res_ln_rd_rsp_tag(res_ln_rd_rsp_tag),
  .res_ln_idle(res_ln_idle),
  .res_sfu_lease_valid(res_sfu_lease_valid),
  .res_sfu_lease_ready(res_sfu_lease_ready),
  .res_sfu_lease_request_id(res_sfu_lease_request_id),
  .res_sfu_lease_generation(res_sfu_lease_generation),
  .res_sfu_lease_epoch(res_sfu_lease_epoch),
  .res_sfu_lease_head(res_sfu_lease_head),
  .res_sfu_lease_phase(res_sfu_lease_phase),
  .res_sfu_release_valid(res_sfu_release_valid),
  .res_sfu_release_phase(res_sfu_release_phase),
  .res_sfu_release_epoch(res_sfu_release_epoch),
  .res_sfu_phase_debt_clear(res_sfu_phase_debt_clear),
  .res_sfu_lease_active(res_sfu_lease_active),
  .res_sfu_context_valid(res_sfu_context_valid),
  .res_sfu_context_row_hi(res_sfu_context_row_hi),
  .res_sfu_req_valid(res_sfu_req_valid),
  .res_sfu_req_ready(res_sfu_req_ready),
  .res_sfu_req_mode(res_sfu_req_mode),
  .res_sfu_req_generation(res_sfu_req_generation),
  .res_sfu_req_epoch(res_sfu_req_epoch),
  .res_sfu_req_phase(res_sfu_req_phase),
  .res_sfu_req_tag(res_sfu_req_tag),
  .res_sfu_req_x(res_sfu_req_x),
  .res_sfu_reject_valid(res_sfu_reject_valid),
  .res_sfu_rsp_valid(res_sfu_rsp_valid),
  .res_sfu_rsp_ready(res_sfu_rsp_ready),
  .res_sfu_rsp_tag(res_sfu_rsp_tag),
  .res_sfu_rsp_data(res_sfu_rsp_data),
  .res_sfu_pending_vectors(res_sfu_pending_vectors),
  .res_sfu_in_flight_vectors(res_sfu_in_flight_vectors),
  .res_sfu_protocol_fault(res_sfu_protocol_fault),
  .res_div_lease_valid(res_div_lease_valid),
  .res_div_lease_ready(res_div_lease_ready),
  .res_div_lease_request_id(res_div_lease_request_id),
  .res_div_lease_generation(res_div_lease_generation),
  .res_div_lease_epoch(res_div_lease_epoch),
  .res_div_lease_head(res_div_lease_head),
  .res_div_lease_phase(res_div_lease_phase),
  .res_div_release_valid(res_div_release_valid),
  .res_div_release_phase(res_div_release_phase),
  .res_div_release_epoch(res_div_release_epoch),
  .res_div_phase_debt_clear(res_div_phase_debt_clear),
  .res_div_lease_active(res_div_lease_active),
  .res_div_req_valid(res_div_req_valid),
  .res_div_req_ready(res_div_req_ready),
  .res_div_req_generation(res_div_req_generation),
  .res_div_req_epoch(res_div_req_epoch),
  .res_div_req_phase(res_div_req_phase),
  .res_div_req_lane_mask(res_div_req_lane_mask),
  .res_div_req_tag(res_div_req_tag),
  .res_div_req_a(res_div_req_a),
  .res_div_req_b(res_div_req_b),
  .res_div_protocol_reject_valid(res_div_protocol_reject_valid),
  .res_div_rsp_valid(res_div_rsp_valid),
  .res_div_rsp_ready(res_div_rsp_ready),
  .res_div_rsp_tag(res_div_rsp_tag),
  .res_div_rsp_numeric_error(res_div_rsp_numeric_error),
  .res_div_rsp_data(res_div_rsp_data),
  .res_div_pending_vectors(res_div_pending_vectors),
  .res_div_in_flight_vectors(res_div_in_flight_vectors),
  .res_div_in_flight_scalars(res_div_in_flight_scalars),
  .res_div_protocol_fault(res_div_protocol_fault),
  .res_scale_valid(res_scale_valid),
  .res_scale_ready(res_scale_ready),
  .res_scale_tag(res_scale_tag),
  .res_scale_input(res_scale_input),
  .res_scale_rsp_valid(res_scale_rsp_valid),
  .res_scale_rsp_ready(res_scale_rsp_ready),
  .res_scale_rsp_tag(res_scale_rsp_tag),
  .res_scale_data(res_scale_data),
  .res_scale_pending(res_scale_pending),
  .res_scale_fault(res_scale_fault),
  .rope_owner_valid(rope_owner_valid),
  .rope_owner_request_id(rope_owner_request_id),
  .rope_owner_generation(rope_owner_generation),
  .rope_owner_epoch(rope_owner_epoch),
  .rope_wr_valid(rope_wr_valid),
  .rope_wr_ready(rope_wr_ready),
  .rope_wr_request_id(rope_wr_request_id),
  .rope_wr_generation(rope_wr_generation),
  .rope_wr_epoch(rope_wr_epoch),
  .rope_wr_head(rope_wr_head),
  .rope_wr_token(rope_wr_token),
  .rope_wr_tag(rope_wr_tag),
  .rope_wr_q(rope_wr_q),
  .rope_wr_k(rope_wr_k),
  .rope_wr_commit_valid(rope_wr_commit_valid),
  .rope_wr_commit_tag(rope_wr_commit_tag),
  .rope_reject_valid(rope_reject_valid),
  .rope_reject_code(rope_reject_code),
  .cache_bound_valid(coeff_bound_valid),
  .cache_bound_model_id(coeff_bound_model_id),
  .cache_bound_numeric_id(coeff_bound_numeric_id),
  .cache_bound_table_key(coeff_bound_table_key),
  .cache_family_complete(coeff_family_complete),
  .cache_owner_valid(cache_owner_valid),
  .cache_owner_request_id(cache_owner_request_id),
  .cache_owner_generation(cache_owner_generation),
  .cache_owner_epoch(cache_owner_epoch),
  .cache_rd_valid(cache_rd_valid),
  .cache_rd_ready(cache_rd_ready),
  .cache_rd_family(cache_rd_family),
  .cache_rd_row(cache_rd_row),
  .cache_rd_tag(cache_rd_tag),
  .cache_rd_request_id(cache_rd_request_id),
  .cache_rd_generation(cache_rd_generation),
  .cache_rd_epoch(cache_rd_epoch),
  .cache_rd_reject_valid(cache_rd_reject_valid),
  .cache_rd_reject_code(cache_rd_reject_code),
  .cache_rsp_valid(cache_rsp_valid),
  .cache_rsp_ready(cache_rsp_ready),
  .cache_rsp_family(cache_rsp_family),
  .cache_rsp_row(cache_rsp_row),
  .cache_rsp_tag(cache_rsp_tag),
  .cache_rsp_data(cache_rsp_data)
 );
 laya_attention_resources_v1 resources(.clk,.rst_n,.res_qkv_wr_valid(res_qkv_wr_valid),.res_qkv_wr_ready(res_qkv_wr_ready),.res_qkv_wr_plane(res_qkv_wr_plane),.res_qkv_wr_head(res_qkv_wr_head),.res_qkv_wr_token(res_qkv_wr_token),.res_qkv_wr_half(res_qkv_wr_half),.res_qkv_wr_data(res_qkv_wr_data),.res_qkv_rd_valid(res_qkv_rd_valid),.res_qkv_rd_ready(res_qkv_rd_ready),.res_qkv_rd_head(res_qkv_rd_head),.res_qkv_rd_token(res_qkv_rd_token),.res_qkv_rd_tag(res_qkv_rd_tag),.res_qkv_rd_rsp_valid(res_qkv_rd_rsp_valid),.res_qkv_rd_rsp_ready(res_qkv_rd_rsp_ready),.res_qkv_rd_rsp_head(res_qkv_rd_rsp_head),.res_qkv_rd_rsp_token(res_qkv_rd_rsp_token),.res_qkv_rd_rsp_tag(res_qkv_rd_rsp_tag),.res_qkv_rd_rsp_data(res_qkv_rd_rsp_data),.res_st_bind_valid(res_st_bind_valid),.res_st_bind_ready(res_st_bind_ready),.res_st_bind_request_id(res_st_bind_request_id),.res_st_bind_generation(res_st_bind_generation),.res_st_bind_epoch(res_st_bind_epoch),.res_st_bind_head(res_st_bind_head),.res_st_bind_phase(res_st_bind_phase),.res_st_op_request_id(res_st_op_request_id),.res_st_op_generation(res_st_op_generation),.res_st_op_epoch(res_st_op_epoch),.res_st_op_phase(res_st_op_phase),.res_st_rsp_request_id(res_st_rsp_request_id),.res_st_rsp_generation(res_st_rsp_generation),.res_st_rsp_epoch(res_st_rsp_epoch),.res_st_rsp_head(res_st_rsp_head),.res_st_rsp_phase(res_st_rsp_phase),.res_st_ps_wr_valid(res_st_ps_wr_valid),.res_st_ps_wr_ready(res_st_ps_wr_ready),.res_st_ps_wr_mask(res_st_ps_wr_mask),.res_st_ps_wr_addr(res_st_ps_wr_addr),.res_st_ps_wr_data(res_st_ps_wr_data),.res_st_ps_wr_tag(res_st_ps_wr_tag),.res_st_ps_wr_rsp_valid(res_st_ps_wr_rsp_valid),.res_st_ps_wr_rsp_ready(res_st_ps_wr_rsp_ready),.res_st_ps_wr_rsp_tag(res_st_ps_wr_rsp_tag),.res_st_ps_rd_valid(res_st_ps_rd_valid),.res_st_ps_rd_ready(res_st_ps_rd_ready),.res_st_ps_rd_mask(res_st_ps_rd_mask),.res_st_ps_rd_addr(res_st_ps_rd_addr),.res_st_ps_rd_tag(res_st_ps_rd_tag),.res_st_ps_rd_rsp_valid(res_st_ps_rd_rsp_valid),.res_st_ps_rd_rsp_ready(res_st_ps_rd_rsp_ready),.res_st_ps_rd_rsp_data(res_st_ps_rd_rsp_data),.res_st_ps_rd_rsp_mask(res_st_ps_rd_rsp_mask),.res_st_ps_rd_rsp_tag(res_st_ps_rd_rsp_tag),.res_st_g_wr_valid(res_st_g_wr_valid),.res_st_g_wr_ready(res_st_g_wr_ready),.res_st_g_wr_mask(res_st_g_wr_mask),.res_st_g_wr_addr(res_st_g_wr_addr),.res_st_g_wr_data(res_st_g_wr_data),.res_st_g_wr_tag(res_st_g_wr_tag),.res_st_g_wr_rsp_valid(res_st_g_wr_rsp_valid),.res_st_g_wr_rsp_ready(res_st_g_wr_rsp_ready),.res_st_g_wr_rsp_tag(res_st_g_wr_rsp_tag),.res_st_g_rd_valid(res_st_g_rd_valid),.res_st_g_rd_ready(res_st_g_rd_ready),.res_st_g_rd_mask(res_st_g_rd_mask),.res_st_g_rd_addr(res_st_g_rd_addr),.res_st_g_rd_tag(res_st_g_rd_tag),.res_st_g_rd_rsp_valid(res_st_g_rd_rsp_valid),.res_st_g_rd_rsp_ready(res_st_g_rd_rsp_ready),.res_st_g_rd_rsp_data(res_st_g_rd_rsp_data),.res_st_g_rd_rsp_mask(res_st_g_rd_rsp_mask),.res_st_g_rd_rsp_tag(res_st_g_rd_rsp_tag),.res_st_context_wr_valid(res_st_context_wr_valid),.res_st_context_wr_ready(res_st_context_wr_ready),.res_st_context_wr_mask(res_st_context_wr_mask),.res_st_context_wr_addr(res_st_context_wr_addr),.res_st_context_wr_data(res_st_context_wr_data),.res_st_context_wr_tag(res_st_context_wr_tag),.res_st_context_wr_rsp_valid(res_st_context_wr_rsp_valid),.res_st_context_wr_rsp_ready(res_st_context_wr_rsp_ready),.res_st_context_wr_rsp_tag(res_st_context_wr_rsp_tag),.res_st_context_rd_valid(res_st_context_rd_valid),.res_st_context_rd_ready(res_st_context_rd_ready),.res_st_context_rd_mask(res_st_context_rd_mask),.res_st_context_rd_addr(res_st_context_rd_addr),.res_st_context_rd_tag(res_st_context_rd_tag),.res_st_context_rd_rsp_valid(res_st_context_rd_rsp_valid),.res_st_context_rd_rsp_ready(res_st_context_rd_rsp_ready),.res_st_context_rd_rsp_data(res_st_context_rd_rsp_data),.res_st_context_rd_rsp_mask(res_st_context_rd_rsp_mask),.res_st_context_rd_rsp_tag(res_st_context_rd_rsp_tag),.res_st_idle(res_st_idle),.res_fp_lease_valid(res_fp_lease_valid),.res_fp_lease_ready(res_fp_lease_ready),.res_fp_lease_request_id(res_fp_lease_request_id),.res_fp_lease_generation(res_fp_lease_generation),.res_fp_lease_epoch(res_fp_lease_epoch),.res_fp_lease_head(res_fp_lease_head),.res_fp_lease_phase(res_fp_lease_phase),.res_fp_release_valid(res_fp_release_valid),.res_fp_release_ready(res_fp_release_ready),.res_fp_release_phase(res_fp_release_phase),.res_fp_release_epoch(res_fp_release_epoch),.res_fp_phase_debt_clear(res_fp_phase_debt_clear),.res_fp_lease_active(res_fp_lease_active),.res_fp_draining(res_fp_draining),.res_fp_rsp_request_id(res_fp_rsp_request_id),.res_fp_rsp_generation(res_fp_rsp_generation),.res_fp_rsp_epoch(res_fp_rsp_epoch),.res_fp_rsp_head(res_fp_rsp_head),.res_fp_rsp_phase(res_fp_rsp_phase),.res_fp_mul_req_valid(res_fp_mul_req_valid),.res_fp_mul_req_ready(res_fp_mul_req_ready),.res_fp_mul_req_phase(res_fp_mul_req_phase),.res_fp_mul_req_epoch(res_fp_mul_req_epoch),.res_fp_mul_req_tag(res_fp_mul_req_tag),.res_fp_mul_a(res_fp_mul_a),.res_fp_mul_b(res_fp_mul_b),.res_fp_mul_rsp_valid(res_fp_mul_rsp_valid),.res_fp_mul_rsp_ready(res_fp_mul_rsp_ready),.res_fp_mul_rsp_tag(res_fp_mul_rsp_tag),.res_fp_mul_rsp_data(res_fp_mul_rsp_data),.res_fp_add_req_valid(res_fp_add_req_valid),.res_fp_add_req_is_root(res_fp_add_req_is_root),.res_fp_add_req_ready(res_fp_add_req_ready),.res_fp_add_req_phase(res_fp_add_req_phase),.res_fp_add_req_epoch(res_fp_add_req_epoch),.res_fp_add_req_tag(res_fp_add_req_tag),.res_fp_add_a(res_fp_add_a),.res_fp_add_b(res_fp_add_b),.res_fp_add_rsp_valid(res_fp_add_rsp_valid),.res_fp_add_rsp_ready(res_fp_add_rsp_ready),.res_fp_add_rsp_tag(res_fp_add_rsp_tag),.res_fp_add_rsp_data(res_fp_add_rsp_data),.res_fp_mul_pending(res_fp_mul_pending),.res_fp_add_pending(res_fp_add_pending),.res_fp_protocol_fault(res_fp_protocol_fault),.res_ln_bind_valid(res_ln_bind_valid),.res_ln_bind_ready(res_ln_bind_ready),.res_ln_bind_request_id(res_ln_bind_request_id),.res_ln_bind_generation(res_ln_bind_generation),.res_ln_bind_epoch(res_ln_bind_epoch),.res_ln_bind_head(res_ln_bind_head),.res_ln_bind_phase(res_ln_bind_phase),.res_ln_op_request_id(res_ln_op_request_id),.res_ln_op_generation(res_ln_op_generation),.res_ln_op_epoch(res_ln_op_epoch),.res_ln_op_phase(res_ln_op_phase),.res_ln_rsp_request_id(res_ln_rsp_request_id),.res_ln_rsp_generation(res_ln_rsp_generation),.res_ln_rsp_epoch(res_ln_rsp_epoch),.res_ln_rsp_head(res_ln_rsp_head),.res_ln_rsp_phase(res_ln_rsp_phase),.res_ln_wr_valid(res_ln_wr_valid),.res_ln_wr_ready(res_ln_wr_ready),.res_ln_wr_mask(res_ln_wr_mask),.res_ln_wr_addr(res_ln_wr_addr),.res_ln_wr_data(res_ln_wr_data),.res_ln_wr_tag(res_ln_wr_tag),.res_ln_wr_rsp_valid(res_ln_wr_rsp_valid),.res_ln_wr_rsp_ready(res_ln_wr_rsp_ready),.res_ln_wr_rsp_tag(res_ln_wr_rsp_tag),.res_ln_rd_valid(res_ln_rd_valid),.res_ln_rd_ready(res_ln_rd_ready),.res_ln_rd_mask(res_ln_rd_mask),.res_ln_rd_addr(res_ln_rd_addr),.res_ln_rd_tag(res_ln_rd_tag),.res_ln_rd_rsp_valid(res_ln_rd_rsp_valid),.res_ln_rd_rsp_ready(res_ln_rd_rsp_ready),.res_ln_rd_rsp_data(res_ln_rd_rsp_data),.res_ln_rd_rsp_mask(res_ln_rd_rsp_mask),.res_ln_rd_rsp_tag(res_ln_rd_rsp_tag),.res_ln_idle(res_ln_idle),.res_sfu_lease_valid(res_sfu_lease_valid),.res_sfu_lease_ready(res_sfu_lease_ready),.res_sfu_lease_request_id(res_sfu_lease_request_id),.res_sfu_lease_generation(res_sfu_lease_generation),.res_sfu_lease_epoch(res_sfu_lease_epoch),.res_sfu_lease_head(res_sfu_lease_head),.res_sfu_lease_phase(res_sfu_lease_phase),.res_sfu_release_valid(res_sfu_release_valid),.res_sfu_release_phase(res_sfu_release_phase),.res_sfu_release_epoch(res_sfu_release_epoch),.res_sfu_phase_debt_clear(res_sfu_phase_debt_clear),.res_sfu_lease_active(res_sfu_lease_active),.res_sfu_context_valid(res_sfu_context_valid),.res_sfu_context_row_hi(res_sfu_context_row_hi),.res_sfu_req_valid(res_sfu_req_valid),.res_sfu_req_ready(res_sfu_req_ready),.res_sfu_req_mode(res_sfu_req_mode),.res_sfu_req_generation(res_sfu_req_generation),.res_sfu_req_epoch(res_sfu_req_epoch),.res_sfu_req_phase(res_sfu_req_phase),.res_sfu_req_tag(res_sfu_req_tag),.res_sfu_req_x(res_sfu_req_x),.res_sfu_reject_valid(res_sfu_reject_valid),.res_sfu_rsp_valid(res_sfu_rsp_valid),.res_sfu_rsp_ready(res_sfu_rsp_ready),.res_sfu_rsp_tag(res_sfu_rsp_tag),.res_sfu_rsp_data(res_sfu_rsp_data),.res_sfu_pending_vectors(res_sfu_pending_vectors),.res_sfu_in_flight_vectors(res_sfu_in_flight_vectors),.res_sfu_protocol_fault(res_sfu_protocol_fault),.res_div_lease_valid(res_div_lease_valid),.res_div_lease_ready(res_div_lease_ready),.res_div_lease_request_id(res_div_lease_request_id),.res_div_lease_generation(res_div_lease_generation),.res_div_lease_epoch(res_div_lease_epoch),.res_div_lease_head(res_div_lease_head),.res_div_lease_phase(res_div_lease_phase),.res_div_release_valid(res_div_release_valid),.res_div_release_phase(res_div_release_phase),.res_div_release_epoch(res_div_release_epoch),.res_div_phase_debt_clear(res_div_phase_debt_clear),.res_div_lease_active(res_div_lease_active),.res_div_req_valid(res_div_req_valid),.res_div_req_ready(res_div_req_ready),.res_div_req_generation(res_div_req_generation),.res_div_req_epoch(res_div_req_epoch),.res_div_req_phase(res_div_req_phase),.res_div_req_lane_mask(res_div_req_lane_mask),.res_div_req_tag(res_div_req_tag),.res_div_req_a(res_div_req_a),.res_div_req_b(res_div_req_b),.res_div_protocol_reject_valid(res_div_protocol_reject_valid),.res_div_rsp_valid(res_div_rsp_valid),.res_div_rsp_ready(res_div_rsp_ready),.res_div_rsp_tag(res_div_rsp_tag),.res_div_rsp_numeric_error(res_div_rsp_numeric_error),.res_div_rsp_data(res_div_rsp_data),.res_div_pending_vectors(res_div_pending_vectors),.res_div_in_flight_vectors(res_div_in_flight_vectors),.res_div_in_flight_scalars(res_div_in_flight_scalars),.res_div_protocol_fault(res_div_protocol_fault),.res_scale_valid(res_scale_valid),.res_scale_ready(res_scale_ready),.res_scale_tag(res_scale_tag),.res_scale_input(res_scale_input),.res_scale_rsp_valid(res_scale_rsp_valid),.res_scale_rsp_ready(res_scale_rsp_ready),.res_scale_rsp_tag(res_scale_rsp_tag),.res_scale_data(res_scale_data),.res_scale_pending(res_scale_pending),.res_scale_fault(res_scale_fault),.rope_owner_valid(rope_owner_valid),.rope_owner_request_id(rope_owner_request_id),.rope_owner_generation(rope_owner_generation),.rope_owner_epoch(rope_owner_epoch),.rope_wr_valid(rope_wr_valid),.rope_wr_ready(rope_wr_ready),.rope_wr_request_id(rope_wr_request_id),.rope_wr_generation(rope_wr_generation),.rope_wr_epoch(rope_wr_epoch),.rope_wr_head(rope_wr_head),.rope_wr_token(rope_wr_token),.rope_wr_tag(rope_wr_tag),.rope_wr_q(rope_wr_q),.rope_wr_k(rope_wr_k),.rope_wr_commit_valid(rope_wr_commit_valid),.rope_wr_commit_tag(rope_wr_commit_tag),.rope_reject_valid(rope_reject_valid),.rope_reject_code(rope_reject_code));
 laya_rope_coeff_cache_v1 coeff(.clk(clk),.rst_n(rst_n),.bind_valid(coeff_bind_valid),.bind_ready(coeff_bind_ready),.bind_model_id(coeff_bind_model_id),.bind_numeric_id(coeff_bind_numeric_id),.bind_table_key(coeff_bind_table_key),.bound_valid(coeff_bound_valid),.bound_model_id(coeff_bound_model_id),.bound_numeric_id(coeff_bound_numeric_id),.bound_table_key(coeff_bound_table_key),.family_complete(coeff_family_complete),.wr_valid(coeff_wr_valid),.wr_ready(coeff_wr_ready),.wr_model_id(coeff_wr_model_id),.wr_numeric_id(coeff_wr_numeric_id),.wr_table_key(coeff_wr_table_key),.wr_table(coeff_wr_table),.wr_row(coeff_wr_row),.wr_half(coeff_wr_half),.wr_data(coeff_wr_data),.wr_reject_valid(coeff_wr_reject_valid),.wr_reject_code(coeff_wr_reject_code),.wr_nonfinite_lane(coeff_wr_nonfinite_lane),.owner_valid(cache_owner_valid),.owner_request_id(cache_owner_request_id),.owner_generation(cache_owner_generation),.owner_epoch(cache_owner_epoch),.rd_valid(cache_rd_valid),.rd_ready(cache_rd_ready),.rd_family(cache_rd_family),.rd_row(cache_rd_row),.rd_tag(cache_rd_tag),.rd_request_id(cache_rd_request_id),.rd_generation(cache_rd_generation),.rd_epoch(cache_rd_epoch),.rd_reject_valid(cache_rd_reject_valid),.rd_reject_code(cache_rd_reject_code),.rsp_valid(cache_rsp_valid),.rsp_ready(cache_rsp_ready),.rsp_family(cache_rsp_family),.rsp_row(cache_rsp_row),.rsp_tag(cache_rsp_tag),.rsp_data(cache_rsp_data));
endmodule
