`timescale 1ns/1ps
// Public production bundle v1, source preparation only; not yet compiled.
// Exactly one four-owner arena, one physical resource shell, H and Q alias.
module laya_m007_resident_joint_v2(
 input logic  clk,
 input logic  rst_n,
 input logic  owner_req_valid,
 input logic [1:0] owner_req,
 output logic  owner_req_ready,
 output logic [1:0] owner,
 output logic  rearm,
 output logic  a_enable,
 output logic  g_enable,
 output logic  ln_enable,
 output logic  vector_enable,
 input logic  resident_owner_valid,
 input logic [63:0] resident_owner_request_id,
 input logic [31:0] resident_owner_generation,
 input logic [31:0] resident_owner_epoch,
 input logic  resident_inputs_ready,
 input logic  parent_matrix_retired,
 input logic  parent_quant_retired,
 input logic [63:0] resident_access_request_id,
 input logic [31:0] resident_access_generation,
 input logic [31:0] resident_access_epoch,
 input logic  h_wr_valid,
 output logic  h_wr_ready,
 output logic  h_wr_commit,
 input logic [11:0] h_wr_addr,
 input logic [31:0][31:0] h_wr_data,
 input logic  h_rd_valid,
 output logic  h_rd_ready,
 input logic [11:0] h_rd_addr,
 output logic  h_rsp_valid,
 input logic  h_rsp_ready,
 output logic [11:0] h_rsp_addr,
 output logic [31:0][31:0] h_rsp_data,
 output logic  h_reject_valid,
 input logic  q_wr_valid,
 output logic  q_wr_ready,
 output logic  q_wr_commit,
 input logic [11:0] q_wr_addr,
 input logic [31:0][31:0] q_wr_data,
 input logic  q_rd_valid,
 output logic  q_rd_ready,
 input logic [11:0] q_rd_addr,
 output logic  q_rsp_valid,
 input logic  q_rsp_ready,
 output logic [11:0] q_rsp_addr,
 output logic [31:0][31:0] q_rsp_data,
 output logic  q_reject_valid,
 input logic  scratch_lease_valid,
 input logic  scratch_release_valid,
 output logic  scratch_lease_ready,
 output logic  scratch_release_ready,
 output logic  scratch_owner_active,
 output logic  scratch_retired,
 output logic  h_bank_idle,
 output logic  resident_bank_idle,
 output logic  shared_resources_idle,
 output logic  ln_provider_idle,
 input logic  a_prepare_valid,
 output logic  a_prepare_ready,
 input logic [63:0] a_prepare_request_id,
 input logic [127:0] a_prepare_model_id,
 input logic [31:0] a_prepare_generation,
 input logic [31:0] a_prepare_epoch,
 input logic [127:0] a_prepare_numeric_id,
 input logic [127:0] a_prepare_table_key,
 input logic [1:0] a_prepare_kind,
 input logic [4:0] a_prepare_layer,
 input logic [127:0] a_prepare_mask,
 input logic  a_qkv_wr_valid,
 output logic  a_qkv_wr_ready,
 input logic [63:0] a_qkv_wr_request_id,
 input logic [31:0] a_qkv_wr_generation,
 input logic [31:0] a_qkv_wr_epoch,
 input logic [1:0] a_qkv_wr_plane,
 input logic [3:0] a_qkv_wr_head,
 input logic [6:0] a_qkv_wr_token,
 input logic  a_qkv_wr_half,
 input logic [31:0][31:0] a_qkv_wr_data,
 input logic  a_start_valid,
 output logic  a_start_ready,
 input logic [63:0] a_start_request_id,
 input logic [31:0] a_start_generation,
 output logic  a_reject_valid,
 output logic [3:0] a_reject_code,
 input logic  a_abort_valid,
 output logic  a_abort_ready,
 input logic [2:0] a_qkv_read_grant,
 input logic  a_ps_grant,
 input logic  a_g_grant,
 input logic  a_context_grant,
 input logic  a_fp_grant,
 input logic  a_sfu_grant,
 input logic  a_exp_grant,
 input logic  a_div_grant,
 input logic  a_rope_write_grant,
 output logic  a_done_valid,
 input logic  a_done_ready,
 output logic [63:0] a_done_request_id,
 output logic [31:0] a_done_generation,
 output logic [7:0] a_done_status,
 output logic [31:0] a_done_cycles,
 output logic [31:0] a_rope_cycles,
 output logic [15:0] a_head_completed,
 output logic [15:0] a_head_context_valid,
 output logic [3:0] a_active_head,
 output logic  a_error_valid,
 output logic [95:0] a_error_tuple,
 output logic [25:0][15:0] a_check_completed,
 output logic [25:0][15:0] a_check_unreachable,
 output logic [25:0][15:0] a_check_dominated,
 output logic [2047:0] a_av_check_completed,
 output logic [2047:0] a_av_check_unreachable,
 output logic [2047:0] a_av_check_dominated,
 input logic  a_result_rd_valid,
 output logic  a_result_rd_ready,
 input logic [31:0] a_result_rd_generation,
 input logic [31:0] a_result_rd_tag,
 input logic [3:0] a_result_rd_head,
 input logic [6:0] a_result_rd_query,
 input logic  a_result_rd_half,
 output logic  a_result_rsp_valid,
 input logic  a_result_rsp_ready,
 output logic [31:0] a_result_rsp_tag,
 output logic [31:0][31:0] a_result_rsp_data,
 input logic  a_result_discard_valid,
 output logic  a_result_discard_ready,
 input logic [31:0] a_result_discard_generation,
 output logic  a_context_discarded,
 output logic [31:0] a_producer_done_cycles,
 output logic [31:0] a_context_release_cycles,
 input logic  a_prepare_cancel_valid,
 output logic  a_prepare_cancel_ready,
 input logic [63:0] a_prepare_cancel_request_id,
 input logic [31:0] a_prepare_cancel_generation,
 input logic [31:0] a_prepare_cancel_epoch,
 output logic  a_prepare_cancel_rsp_valid,
 input logic  a_prepare_cancel_rsp_ready,
 output logic [63:0] a_prepare_cancel_rsp_request_id,
 output logic [31:0] a_prepare_cancel_rsp_generation,
 output logic [31:0] a_prepare_cancel_rsp_epoch,
 output logic [7:0] a_prepare_cancel_rsp_status,
 output logic  a_layer_idle,
 output logic  a_check_coverage_fault,
 output logic [31:0] a_check_first_conflict,
 input logic  g_producer_cancel_valid,
 output logic  g_producer_cancel_ready,
 input logic [63:0] g_producer_cancel_request_id,
 input logic [31:0] g_producer_cancel_generation,
 input logic [31:0] g_producer_cancel_epoch,
 output logic  g_producer_cancel_reject_valid,
 input logic  g_cmd_valid,
 output logic  g_cmd_ready,
 input logic [63:0] g_cmd_request_id,
 input logic [31:0] g_cmd_generation,
 input logic [31:0] g_cmd_epoch,
 input logic  g_fill_valid,
 output logic  g_fill_ready,
 input logic [63:0] g_fill_request_id,
 input logic [31:0] g_fill_generation,
 input logic [31:0] g_fill_epoch,
 input logic  g_fill_slot,
 input logic  g_fill_half,
 input logic [6:0] g_fill_s,
 input logic [6:0] g_fill_row,
 input logic [31:0][31:0] g_fill_data,
 output logic  g_fill_reject_valid,
 output logic [1:0] g_fill_reject_code,
 output logic  g_out_valid,
 input logic  g_out_ready,
 output logic [7:0][31:0] g_out_data,
 output logic [7:0][31:0] g_out_status,
 output logic [95:0] g_out_tag,
 output logic [6:0] g_out_s,
 output logic [6:0] g_out_row,
 output logic [1:0] g_out_chunk,
 output logic  g_done_valid,
 input logic  g_done_ready,
 output logic  g_done_cancelled,
 output logic [31:0] g_done_status,
 output logic [2:0] g_done_error_rank,
 output logic [6:0] g_done_error_row,
 output logic [11:0] g_done_error_column,
 output logic [63:0] g_rsp_request_id,
 output logic [31:0] g_rsp_generation,
 output logic [31:0] g_rsp_epoch,
 input logic  g_discard_valid,
 output logic  g_discard_ready,
 input logic [63:0] g_discard_request_id,
 input logic [31:0] g_discard_generation,
 input logic [31:0] g_discard_epoch,
 output logic  g_discard_reject_valid,
 output logic  g_engine_idle,
 output logic  g_active,
 output logic  g_needs_discard,
 output logic  g_protocol_fault,
 output logic [1:0] g_slot_active,
 output logic [1:0] g_slot_ready,
 output logic [1:0][6:0] g_slot_s,
 output logic [1:0][9:0] g_slot_consumed_vectors,
 output logic [1:0][8:0] g_slot_math_pending,
 output logic [1:0][8:0] g_slot_sfu_debt,
 output logic [1:0][7:0] g_slot_fp_debt,
 output logic [7:0][18:0] g_covered,
 output logic [7:0][18:0] g_evaluated,
 input logic  ln_gamma_begin_valid,
 output logic  ln_gamma_begin_ready,
 input logic [63:0] ln_gamma_model,
 input logic [31:0] ln_gamma_key,
 input logic  ln_gamma_valid,
 output logic  ln_gamma_ready,
 input logic [4:0] ln_gamma_chunk,
 input logic [31:0][31:0] ln_gamma_data,
 output logic  ln_gamma_done_valid,
 input logic  ln_gamma_done_ready,
 output logic  ln_gamma_done_error,
 output logic  ln_gamma_loaded,
 output logic  ln_done_valid,
 output logic  ln_done_error,
 output logic [4:0] ln_error_stage,
 output logic [3:0] ln_error_level,
 output logic [6:0] ln_error_row,
 output logic [9:0] ln_error_node,
 output logic  ln_reject_valid,
 output logic [3:0] ln_reject_code,
 output logic  ln_active,
 output logic  ln_debt_clear,
 output logic  ln_trace_add_valid,
 output logic [175:0] ln_trace_add_meta,
 output logic  ln_trace_mul_valid,
 output logic [23:0] ln_trace_mul_meta,
 output logic [6:0] ln_trace_scalar_valid,
 output logic [6:0][1:0] ln_trace_scalar_ctx,
 output logic [6:0][31:0] ln_trace_scalar_data,
 output logic  ln_trace_row_start,
 output logic [6:0] ln_trace_row,
 output logic [3:0] ln_ctx_active,
 output logic [3:0][6:0] ln_ctx_row,
 output logic [3:0][31:0] ln_raw_coverage,
 output logic [3:0][31:0] ln_delta_coverage,
 output logic [31:0] ln_cycle_count,
 output logic [6:0] ln_peak_add_pending,
 output logic [6:0] ln_peak_mul_pending,
 input logic  ln_reject_ready,
 input logic  ln_cancel_valid,
 output logic  ln_cancel_ready,
 input logic [63:0] ln_cancel_request_id,
 input logic [31:0] ln_cancel_generation,
 input logic [31:0] ln_cancel_epoch,
 output logic [1:0] ln_done_kind,
 output logic  ln_cancel_rsp_valid,
 output logic  ln_protocol_fault,
 output logic [3:0] ln_protocol_code,
 output logic [7:0] ln_protocol_location,
 output logic [1:0] ln_error_class,
 output logic [3:0] ln_error_check,
 input logic  vector_start_valid,
 output logic  vector_start_ready,
 input logic [1:0] vector_start_op,
 input logic [63:0] vector_start_request_id,
 input logic [31:0] vector_start_generation,
 input logic [31:0] vector_start_epoch,
 output logic  vector_start_reject_valid,
 output logic  vector_done_valid,
 input logic  vector_done_ready,
 output logic [31:0] vector_done_status,
 output logic [6:0] vector_done_error_row,
 output logic [9:0] vector_done_error_column,
 output logic  vector_idle,
 output logic [12:0] vector_issued_vectors,
 output logic [12:0] vector_retired_vectors,
 input logic  coeff_bind_valid,
 output logic  coeff_bind_ready,
 input logic [127:0] coeff_bind_model_id,
 input logic [127:0] coeff_bind_numeric_id,
 input logic [127:0] coeff_bind_table_key,
 output logic  coeff_bound_valid,
 output logic [127:0] coeff_bound_model_id,
 output logic [127:0] coeff_bound_numeric_id,
 output logic [127:0] coeff_bound_table_key,
 output logic [1:0] coeff_family_complete,
 input logic  coeff_wr_valid,
 output logic  coeff_wr_ready,
 input logic [127:0] coeff_wr_model_id,
 input logic [127:0] coeff_wr_numeric_id,
 input logic [127:0] coeff_wr_table_key,
 input logic [1:0] coeff_wr_table,
 input logic [6:0] coeff_wr_row,
 input logic  coeff_wr_half,
 input logic [31:0][31:0] coeff_wr_data,
 output logic  coeff_wr_reject_valid,
 output logic [2:0] coeff_wr_reject_code,
 output logic [4:0] coeff_wr_nonfinite_lane,
 input logic  resident_ln_start_valid,
 output logic  resident_ln_start_ready,
 input logic [7:0] resident_ln_rows,
 input logic  resident_ln_use_gamma,
 input logic [63:0] resident_ln_model,
 input logic [31:0] resident_ln_key,
 output logic  resident_ln_done_valid,
 input logic  resident_ln_done_ready,
 output logic [31:0] resident_ln_done_status,
 output logic [1:0] resident_ln_done_kind,
 output logic  resident_ln_source_qualified,
 output logic [12:0] resident_ln_issued_vectors,
 output logic [12:0] resident_ln_written_vectors,
 input logic  ext_fp_select,
 input logic  ext_div_select,
 input logic  ext_bind_select,
 input logic  ext_ps_select,
 input logic  ext_context_select,
 input logic  ext_res_st_bind_valid,
 output logic  ext_res_st_bind_ready,
 input logic [63:0] ext_res_st_bind_request_id,
 input logic [31:0] ext_res_st_bind_generation,
 input logic [31:0] ext_res_st_bind_epoch,
 input logic [3:0] ext_res_st_bind_head,
 input logic [2:0] ext_res_st_bind_phase,
 input logic [63:0] ext_res_st_op_request_id,
 input logic [31:0] ext_res_st_op_generation,
 input logic [31:0] ext_res_st_op_epoch,
 input logic [2:0] ext_res_st_op_phase,
 output logic [63:0] ext_res_st_rsp_request_id,
 output logic [31:0] ext_res_st_rsp_generation,
 output logic [31:0] ext_res_st_rsp_epoch,
 output logic [3:0] ext_res_st_rsp_head,
 output logic [2:0] ext_res_st_rsp_phase,
 input logic  ext_res_st_ps_wr_valid,
 output logic  ext_res_st_ps_wr_ready,
 input logic [1023:0] ext_res_st_ps_wr_mask,
 input logic [1023:0][3:0] ext_res_st_ps_wr_addr,
 input logic [1023:0][31:0] ext_res_st_ps_wr_data,
 input logic [95:0] ext_res_st_ps_wr_tag,
 output logic  ext_res_st_ps_wr_rsp_valid,
 input logic  ext_res_st_ps_wr_rsp_ready,
 output logic [95:0] ext_res_st_ps_wr_rsp_tag,
 input logic  ext_res_st_ps_rd_valid,
 output logic  ext_res_st_ps_rd_ready,
 input logic [1023:0] ext_res_st_ps_rd_mask,
 input logic [1023:0][3:0] ext_res_st_ps_rd_addr,
 input logic [95:0] ext_res_st_ps_rd_tag,
 output logic  ext_res_st_ps_rd_rsp_valid,
 input logic  ext_res_st_ps_rd_rsp_ready,
 output logic [1023:0][31:0] ext_res_st_ps_rd_rsp_data,
 output logic [1023:0] ext_res_st_ps_rd_rsp_mask,
 output logic [95:0] ext_res_st_ps_rd_rsp_tag,
 input logic  ext_res_st_context_wr_valid,
 output logic  ext_res_st_context_wr_ready,
 input logic [63:0] ext_res_st_context_wr_mask,
 input logic [63:0][10:0] ext_res_st_context_wr_addr,
 input logic [63:0][31:0] ext_res_st_context_wr_data,
 input logic [95:0] ext_res_st_context_wr_tag,
 output logic  ext_res_st_context_wr_rsp_valid,
 input logic  ext_res_st_context_wr_rsp_ready,
 output logic [95:0] ext_res_st_context_wr_rsp_tag,
 input logic  ext_res_st_context_rd_valid,
 output logic  ext_res_st_context_rd_ready,
 input logic [63:0] ext_res_st_context_rd_mask,
 input logic [63:0][10:0] ext_res_st_context_rd_addr,
 input logic [95:0] ext_res_st_context_rd_tag,
 output logic  ext_res_st_context_rd_rsp_valid,
 input logic  ext_res_st_context_rd_rsp_ready,
 output logic [63:0][31:0] ext_res_st_context_rd_rsp_data,
 output logic [63:0] ext_res_st_context_rd_rsp_mask,
 output logic [95:0] ext_res_st_context_rd_rsp_tag,
 output logic  ext_res_st_idle,
 input logic  ext_res_fp_lease_valid,
 output logic  ext_res_fp_lease_ready,
 input logic [63:0] ext_res_fp_lease_request_id,
 input logic [31:0] ext_res_fp_lease_generation,
 input logic [31:0] ext_res_fp_lease_epoch,
 input logic [3:0] ext_res_fp_lease_head,
 input logic [2:0] ext_res_fp_lease_phase,
 input logic  ext_res_fp_release_valid,
 output logic  ext_res_fp_release_ready,
 input logic [2:0] ext_res_fp_release_phase,
 input logic [31:0] ext_res_fp_release_epoch,
 input logic  ext_res_fp_phase_debt_clear,
 output logic  ext_res_fp_lease_active,
 output logic  ext_res_fp_draining,
 output logic [63:0] ext_res_fp_rsp_request_id,
 output logic [31:0] ext_res_fp_rsp_generation,
 output logic [31:0] ext_res_fp_rsp_epoch,
 output logic [3:0] ext_res_fp_rsp_head,
 output logic [2:0] ext_res_fp_rsp_phase,
 input logic  ext_res_fp_mul_req_valid,
 output logic  ext_res_fp_mul_req_ready,
 input logic [2:0] ext_res_fp_mul_req_phase,
 input logic [31:0] ext_res_fp_mul_req_epoch,
 input logic [95:0] ext_res_fp_mul_req_tag,
 input logic [255:0][31:0] ext_res_fp_mul_a,
 input logic [255:0][31:0] ext_res_fp_mul_b,
 output logic  ext_res_fp_mul_rsp_valid,
 input logic  ext_res_fp_mul_rsp_ready,
 output logic [95:0] ext_res_fp_mul_rsp_tag,
 output logic [255:0][31:0] ext_res_fp_mul_rsp_data,
 input logic [6:0] ext_res_fp_add_req_valid,
 input logic [6:0] ext_res_fp_add_req_is_root,
 output logic [6:0] ext_res_fp_add_req_ready,
 input logic [6:0][2:0] ext_res_fp_add_req_phase,
 input logic [6:0][31:0] ext_res_fp_add_req_epoch,
 input logic [6:0][95:0] ext_res_fp_add_req_tag,
 input logic [255:0][31:0] ext_res_fp_add_a,
 input logic [255:0][31:0] ext_res_fp_add_b,
 output logic [6:0] ext_res_fp_add_rsp_valid,
 input logic [6:0] ext_res_fp_add_rsp_ready,
 output logic [6:0][95:0] ext_res_fp_add_rsp_tag,
 output logic [255:0][31:0] ext_res_fp_add_rsp_data,
 output logic [6:0] ext_res_fp_mul_pending,
 output logic [6:0][6:0] ext_res_fp_add_pending,
 output logic  ext_res_fp_protocol_fault,
 input logic  ext_res_div_lease_valid,
 output logic  ext_res_div_lease_ready,
 input logic [63:0] ext_res_div_lease_request_id,
 input logic [31:0] ext_res_div_lease_generation,
 input logic [31:0] ext_res_div_lease_epoch,
 input logic [3:0] ext_res_div_lease_head,
 input logic [2:0] ext_res_div_lease_phase,
 output logic  ext_res_div_release_ready,
 output logic  ext_res_div_draining,
 output logic [63:0] ext_res_div_rsp_request_id,
 output logic [31:0] ext_res_div_rsp_generation,
 output logic [31:0] ext_res_div_rsp_epoch,
 output logic [3:0] ext_res_div_rsp_head,
 output logic [2:0] ext_res_div_rsp_phase,
 output logic [3:0] ext_res_div_protocol_reject_code,
 output logic [7:0] ext_res_div_rsp_lane_mask,
 input logic  ext_res_div_release_valid,
 input logic [2:0] ext_res_div_release_phase,
 input logic [31:0] ext_res_div_release_epoch,
 input logic  ext_res_div_phase_debt_clear,
 output logic  ext_res_div_lease_active,
 input logic  ext_res_div_req_valid,
 output logic  ext_res_div_req_ready,
 input logic [31:0] ext_res_div_req_generation,
 input logic [31:0] ext_res_div_req_epoch,
 input logic [2:0] ext_res_div_req_phase,
 input logic [7:0] ext_res_div_req_lane_mask,
 input logic [95:0] ext_res_div_req_tag,
 input logic [7:0][31:0] ext_res_div_req_a,
 input logic [7:0][31:0] ext_res_div_req_b,
 output logic  ext_res_div_protocol_reject_valid,
 output logic  ext_res_div_rsp_valid,
 input logic  ext_res_div_rsp_ready,
 output logic [95:0] ext_res_div_rsp_tag,
 output logic [7:0] ext_res_div_rsp_numeric_error,
 output logic [7:0][31:0] ext_res_div_rsp_data,
 output logic [5:0] ext_res_div_pending_vectors,
 output logic [5:0] ext_res_div_in_flight_vectors,
 output logic [8:0] ext_res_div_in_flight_scalars,
 output logic  ext_res_div_protocol_fault,
 input logic  g_tanh_lease_valid,
 output logic  g_tanh_lease_ready,
 input logic [63:0] g_tanh_lease_request_id,
 input logic [31:0] g_tanh_lease_generation,
 input logic [31:0] g_tanh_lease_epoch,
 input logic [2:0] g_tanh_lease_phase,
 input logic  g_tanh_release_valid,
 output logic  g_tanh_release_ready,
 input logic [2:0] g_tanh_release_phase,
 input logic [31:0] g_tanh_release_epoch,
 input logic  g_tanh_phase_debt_clear,
 output logic  g_tanh_lease_active,
 output logic  g_tanh_draining,
 output logic [8:0] g_tanh_pending_vectors,
 output logic [8:0] g_tanh_in_flight_vectors
);
 parameter bit TANH_FORCE_CORE_CE=0;
 logic  j_a_prepare_valid;
 logic  j_a_prepare_ready;
 logic  j_a_qkv_wr_valid;
 logic  j_a_qkv_wr_ready;
 logic  j_a_start_valid;
 logic  j_a_start_ready;
 logic  j_a_result_rd_valid;
 logic  j_a_result_rd_ready;
 logic [3:0] outer_admission_quiet;
 logic  a_res_qkv_wr_valid;
 logic  a_res_qkv_wr_ready;
 logic [1:0] a_res_qkv_wr_plane;
 logic [3:0] a_res_qkv_wr_head;
 logic [6:0] a_res_qkv_wr_token;
 logic  a_res_qkv_wr_half;
 logic [31:0][31:0] a_res_qkv_wr_data;
 logic [2:0] a_res_qkv_rd_valid;
 logic [2:0] a_res_qkv_rd_ready;
 logic [2:0][3:0] a_res_qkv_rd_head;
 logic [2:0][6:0] a_res_qkv_rd_token;
 logic [2:0][31:0] a_res_qkv_rd_tag;
 logic [2:0] a_res_qkv_rd_rsp_valid;
 logic [2:0] a_res_qkv_rd_rsp_ready;
 logic [2:0][3:0] a_res_qkv_rd_rsp_head;
 logic [2:0][6:0] a_res_qkv_rd_rsp_token;
 logic [2:0][31:0] a_res_qkv_rd_rsp_tag;
 logic [2:0][63:0][31:0] a_res_qkv_rd_rsp_data;
 logic  a_res_st_bind_valid;
 logic  a_res_st_bind_ready;
 logic [63:0] a_res_st_bind_request_id;
 logic [31:0] a_res_st_bind_generation;
 logic [31:0] a_res_st_bind_epoch;
 logic [3:0] a_res_st_bind_head;
 logic [2:0] a_res_st_bind_phase;
 logic [63:0] a_res_st_op_request_id;
 logic [31:0] a_res_st_op_generation;
 logic [31:0] a_res_st_op_epoch;
 logic [2:0] a_res_st_op_phase;
 logic [63:0] a_res_st_rsp_request_id;
 logic [31:0] a_res_st_rsp_generation;
 logic [31:0] a_res_st_rsp_epoch;
 logic [3:0] a_res_st_rsp_head;
 logic [2:0] a_res_st_rsp_phase;
 logic  a_res_st_ps_wr_valid;
 logic  a_res_st_ps_wr_ready;
 logic [1023:0] a_res_st_ps_wr_mask;
 logic [1023:0][3:0] a_res_st_ps_wr_addr;
 logic [1023:0][31:0] a_res_st_ps_wr_data;
 logic [95:0] a_res_st_ps_wr_tag;
 logic  a_res_st_ps_wr_rsp_valid;
 logic  a_res_st_ps_wr_rsp_ready;
 logic [95:0] a_res_st_ps_wr_rsp_tag;
 logic  a_res_st_ps_rd_valid;
 logic  a_res_st_ps_rd_ready;
 logic [1023:0] a_res_st_ps_rd_mask;
 logic [1023:0][3:0] a_res_st_ps_rd_addr;
 logic [95:0] a_res_st_ps_rd_tag;
 logic  a_res_st_ps_rd_rsp_valid;
 logic  a_res_st_ps_rd_rsp_ready;
 logic [1023:0][31:0] a_res_st_ps_rd_rsp_data;
 logic [1023:0] a_res_st_ps_rd_rsp_mask;
 logic [95:0] a_res_st_ps_rd_rsp_tag;
 logic  a_res_st_g_wr_valid;
 logic  a_res_st_g_wr_ready;
 logic [255:0] a_res_st_g_wr_mask;
 logic [255:0][5:0] a_res_st_g_wr_addr;
 logic [255:0][31:0] a_res_st_g_wr_data;
 logic [95:0] a_res_st_g_wr_tag;
 logic  a_res_st_g_wr_rsp_valid;
 logic  a_res_st_g_wr_rsp_ready;
 logic [95:0] a_res_st_g_wr_rsp_tag;
 logic  a_res_st_g_rd_valid;
 logic  a_res_st_g_rd_ready;
 logic [255:0] a_res_st_g_rd_mask;
 logic [255:0][5:0] a_res_st_g_rd_addr;
 logic [95:0] a_res_st_g_rd_tag;
 logic  a_res_st_g_rd_rsp_valid;
 logic  a_res_st_g_rd_rsp_ready;
 logic [255:0][31:0] a_res_st_g_rd_rsp_data;
 logic [255:0] a_res_st_g_rd_rsp_mask;
 logic [95:0] a_res_st_g_rd_rsp_tag;
 logic  a_res_st_context_wr_valid;
 logic  a_res_st_context_wr_ready;
 logic [63:0] a_res_st_context_wr_mask;
 logic [63:0][10:0] a_res_st_context_wr_addr;
 logic [63:0][31:0] a_res_st_context_wr_data;
 logic [95:0] a_res_st_context_wr_tag;
 logic  a_res_st_context_wr_rsp_valid;
 logic  a_res_st_context_wr_rsp_ready;
 logic [95:0] a_res_st_context_wr_rsp_tag;
 logic  a_res_st_context_rd_valid;
 logic  a_res_st_context_rd_ready;
 logic [63:0] a_res_st_context_rd_mask;
 logic [63:0][10:0] a_res_st_context_rd_addr;
 logic [95:0] a_res_st_context_rd_tag;
 logic  a_res_st_context_rd_rsp_valid;
 logic  a_res_st_context_rd_rsp_ready;
 logic [63:0][31:0] a_res_st_context_rd_rsp_data;
 logic [63:0] a_res_st_context_rd_rsp_mask;
 logic [95:0] a_res_st_context_rd_rsp_tag;
 logic  a_res_st_idle;
 logic  a_res_fp_lease_valid;
 logic  a_res_fp_lease_ready;
 logic [63:0] a_res_fp_lease_request_id;
 logic [31:0] a_res_fp_lease_generation;
 logic [31:0] a_res_fp_lease_epoch;
 logic [3:0] a_res_fp_lease_head;
 logic [2:0] a_res_fp_lease_phase;
 logic  a_res_fp_release_valid;
 logic  a_res_fp_release_ready;
 logic [2:0] a_res_fp_release_phase;
 logic [31:0] a_res_fp_release_epoch;
 logic  a_res_fp_phase_debt_clear;
 logic  a_res_fp_lease_active;
 logic  a_res_fp_draining;
 logic [63:0] a_res_fp_rsp_request_id;
 logic [31:0] a_res_fp_rsp_generation;
 logic [31:0] a_res_fp_rsp_epoch;
 logic [3:0] a_res_fp_rsp_head;
 logic [2:0] a_res_fp_rsp_phase;
 logic  a_res_fp_mul_req_valid;
 logic  a_res_fp_mul_req_ready;
 logic [2:0] a_res_fp_mul_req_phase;
 logic [31:0] a_res_fp_mul_req_epoch;
 logic [95:0] a_res_fp_mul_req_tag;
 logic [255:0][31:0] a_res_fp_mul_a;
 logic [255:0][31:0] a_res_fp_mul_b;
 logic  a_res_fp_mul_rsp_valid;
 logic  a_res_fp_mul_rsp_ready;
 logic [95:0] a_res_fp_mul_rsp_tag;
 logic [255:0][31:0] a_res_fp_mul_rsp_data;
 logic [6:0] a_res_fp_add_req_valid;
 logic [6:0] a_res_fp_add_req_is_root;
 logic [6:0] a_res_fp_add_req_ready;
 logic [6:0][2:0] a_res_fp_add_req_phase;
 logic [6:0][31:0] a_res_fp_add_req_epoch;
 logic [6:0][95:0] a_res_fp_add_req_tag;
 logic [255:0][31:0] a_res_fp_add_a;
 logic [255:0][31:0] a_res_fp_add_b;
 logic [6:0] a_res_fp_add_rsp_valid;
 logic [6:0] a_res_fp_add_rsp_ready;
 logic [6:0][95:0] a_res_fp_add_rsp_tag;
 logic [255:0][31:0] a_res_fp_add_rsp_data;
 logic [6:0] a_res_fp_mul_pending;
 logic [6:0][6:0] a_res_fp_add_pending;
 logic  a_res_fp_protocol_fault;
 logic  a_res_ln_bind_valid;
 logic  a_res_ln_bind_ready;
 logic [63:0] a_res_ln_bind_request_id;
 logic [31:0] a_res_ln_bind_generation;
 logic [31:0] a_res_ln_bind_epoch;
 logic [3:0] a_res_ln_bind_head;
 logic [2:0] a_res_ln_bind_phase;
 logic [63:0] a_res_ln_op_request_id;
 logic [31:0] a_res_ln_op_generation;
 logic [31:0] a_res_ln_op_epoch;
 logic [2:0] a_res_ln_op_phase;
 logic [63:0] a_res_ln_rsp_request_id;
 logic [31:0] a_res_ln_rsp_generation;
 logic [31:0] a_res_ln_rsp_epoch;
 logic [3:0] a_res_ln_rsp_head;
 logic [2:0] a_res_ln_rsp_phase;
 logic  a_res_ln_wr_valid;
 logic  a_res_ln_wr_ready;
 logic [255:0] a_res_ln_wr_mask;
 logic [255:0][4:0] a_res_ln_wr_addr;
 logic [255:0][31:0] a_res_ln_wr_data;
 logic [95:0] a_res_ln_wr_tag;
 logic  a_res_ln_wr_rsp_valid;
 logic  a_res_ln_wr_rsp_ready;
 logic [95:0] a_res_ln_wr_rsp_tag;
 logic  a_res_ln_rd_valid;
 logic  a_res_ln_rd_ready;
 logic [255:0] a_res_ln_rd_mask;
 logic [255:0][4:0] a_res_ln_rd_addr;
 logic [95:0] a_res_ln_rd_tag;
 logic  a_res_ln_rd_rsp_valid;
 logic  a_res_ln_rd_rsp_ready;
 logic [255:0][31:0] a_res_ln_rd_rsp_data;
 logic [255:0] a_res_ln_rd_rsp_mask;
 logic [95:0] a_res_ln_rd_rsp_tag;
 logic  a_res_ln_idle;
 logic  a_res_sfu_lease_valid;
 logic  a_res_sfu_lease_ready;
 logic [63:0] a_res_sfu_lease_request_id;
 logic [31:0] a_res_sfu_lease_generation;
 logic [31:0] a_res_sfu_lease_epoch;
 logic [3:0] a_res_sfu_lease_head;
 logic [2:0] a_res_sfu_lease_phase;
 logic  a_res_sfu_release_valid;
 logic [2:0] a_res_sfu_release_phase;
 logic [31:0] a_res_sfu_release_epoch;
 logic  a_res_sfu_phase_debt_clear;
 logic  a_res_sfu_lease_active;
 logic [63:0] a_res_sfu_context_valid;
 logic [63:0] a_res_sfu_context_row_hi;
 logic  a_res_sfu_req_valid;
 logic  a_res_sfu_req_ready;
 logic [1:0] a_res_sfu_req_mode;
 logic [31:0] a_res_sfu_req_generation;
 logic [31:0] a_res_sfu_req_epoch;
 logic [2:0] a_res_sfu_req_phase;
 logic [10:0] a_res_sfu_req_tag;
 logic [7:0][31:0] a_res_sfu_req_x;
 logic  a_res_sfu_reject_valid;
 logic  a_res_sfu_rsp_valid;
 logic  a_res_sfu_rsp_ready;
 logic [10:0] a_res_sfu_rsp_tag;
 logic [7:0][31:0] a_res_sfu_rsp_data;
 logic [8:0] a_res_sfu_pending_vectors;
 logic [8:0] a_res_sfu_in_flight_vectors;
 logic  a_res_sfu_protocol_fault;
 logic  a_res_div_lease_valid;
 logic  a_res_div_lease_ready;
 logic [63:0] a_res_div_lease_request_id;
 logic [31:0] a_res_div_lease_generation;
 logic [31:0] a_res_div_lease_epoch;
 logic [3:0] a_res_div_lease_head;
 logic [2:0] a_res_div_lease_phase;
 logic  a_res_div_release_valid;
 logic [2:0] a_res_div_release_phase;
 logic [31:0] a_res_div_release_epoch;
 logic  a_res_div_phase_debt_clear;
 logic  a_res_div_lease_active;
 logic  a_res_div_req_valid;
 logic  a_res_div_req_ready;
 logic [31:0] a_res_div_req_generation;
 logic [31:0] a_res_div_req_epoch;
 logic [2:0] a_res_div_req_phase;
 logic [7:0] a_res_div_req_lane_mask;
 logic [95:0] a_res_div_req_tag;
 logic [7:0][31:0] a_res_div_req_a;
 logic [7:0][31:0] a_res_div_req_b;
 logic  a_res_div_protocol_reject_valid;
 logic  a_res_div_rsp_valid;
 logic  a_res_div_rsp_ready;
 logic [95:0] a_res_div_rsp_tag;
 logic [7:0] a_res_div_rsp_numeric_error;
 logic [7:0][31:0] a_res_div_rsp_data;
 logic [5:0] a_res_div_pending_vectors;
 logic [5:0] a_res_div_in_flight_vectors;
 logic [8:0] a_res_div_in_flight_scalars;
 logic  a_res_div_protocol_fault;
 logic  a_res_scale_valid;
 logic  a_res_scale_ready;
 logic [95:0] a_res_scale_tag;
 logic [3:0][31:0] a_res_scale_input;
 logic  a_res_scale_rsp_valid;
 logic  a_res_scale_rsp_ready;
 logic [95:0] a_res_scale_rsp_tag;
 logic [3:0][31:0] a_res_scale_data;
 logic [6:0] a_res_scale_pending;
 logic  a_res_scale_fault;
 logic  a_rope_owner_valid;
 logic [63:0] a_rope_owner_request_id;
 logic [31:0] a_rope_owner_generation;
 logic [31:0] a_rope_owner_epoch;
 logic  a_rope_wr_valid;
 logic  a_rope_wr_ready;
 logic [63:0] a_rope_wr_request_id;
 logic [31:0] a_rope_wr_generation;
 logic [31:0] a_rope_wr_epoch;
 logic [3:0] a_rope_wr_head;
 logic [6:0] a_rope_wr_token;
 logic [95:0] a_rope_wr_tag;
 logic [63:0][31:0] a_rope_wr_q;
 logic [63:0][31:0] a_rope_wr_k;
 logic  a_rope_wr_commit_valid;
 logic [95:0] a_rope_wr_commit_tag;
 logic  a_rope_reject_valid;
 logic [2:0] a_rope_reject_code;
 logic  a_cache_bound_valid;
 logic [127:0] a_cache_bound_model_id;
 logic [127:0] a_cache_bound_numeric_id;
 logic [127:0] a_cache_bound_table_key;
 logic [1:0] a_cache_family_complete;
 logic  a_cache_owner_valid;
 logic [63:0] a_cache_owner_request_id;
 logic [31:0] a_cache_owner_generation;
 logic [31:0] a_cache_owner_epoch;
 logic  a_cache_rd_valid;
 logic  a_cache_rd_ready;
 logic  a_cache_rd_family;
 logic [6:0] a_cache_rd_row;
 logic [95:0] a_cache_rd_tag;
 logic [63:0] a_cache_rd_request_id;
 logic [31:0] a_cache_rd_generation;
 logic [31:0] a_cache_rd_epoch;
 logic  a_cache_rd_reject_valid;
 logic [2:0] a_cache_rd_reject_code;
 logic  a_cache_rsp_valid;
 logic  a_cache_rsp_ready;
 logic  a_cache_rsp_family;
 logic [6:0] a_cache_rsp_row;
 logic [95:0] a_cache_rsp_tag;
 logic [127:0][31:0] a_cache_rsp_data;
 logic  g_storage_owner_valid;
 logic [63:0] g_storage_owner_request_id;
 logic [31:0] g_storage_owner_generation;
 logic [31:0] g_storage_owner_epoch;
 logic [2:0] g_storage_owner_phase;
 logic  g_sfu_owner_valid;
 logic [63:0] g_sfu_owner_request_id;
 logic [31:0] g_sfu_owner_generation;
 logic [31:0] g_sfu_owner_epoch;
 logic [2:0] g_sfu_owner_phase;
 logic  g_pool_reset_n;
 logic [8:0] g_fp_req_valid;
 logic [8:0] g_fp_req_ready;
 logic [8:0][95:0] g_fp_req_tag;
 logic [8:0][7:0][31:0] g_fp_req_a;
 logic [8:0][7:0][31:0] g_fp_req_b;
 logic [8:0] g_fp_rsp_valid;
 logic [8:0][95:0] g_fp_rsp_tag;
 logic [8:0][7:0][31:0] g_fp_rsp_data;
 logic [8:0][7:0][31:0] g_fp_rsp_status;
 logic  g_fp_pool_fault;
 logic  g_sfu_req_valid;
 logic  g_sfu_req_ready;
 logic [95:0] g_sfu_req_tag;
 logic [7:0] g_sfu_req_mask;
 logic [7:0][31:0] g_sfu_req_x;
 logic  g_sfu_rsp_valid;
 logic  g_sfu_rsp_ready;
 logic [95:0] g_sfu_rsp_tag;
 logic [7:0][31:0] g_sfu_rsp_data;
 logic [7:0][31:0] g_sfu_rsp_status;
 logic  g_sfu_protocol_fault;
 logic  g_sfu_reject_valid;
 logic  g_g_wr_valid;
 logic  g_g_wr_ready;
 logic [255:0] g_g_wr_mask;
 logic [255:0][5:0] g_g_wr_addr;
 logic [255:0][31:0] g_g_wr_data;
 logic [95:0] g_g_wr_tag;
 logic  g_g_wr_rsp_valid;
 logic  g_g_wr_rsp_ready;
 logic [95:0] g_g_wr_rsp_tag;
 logic  g_g_rd_valid;
 logic  g_g_rd_ready;
 logic [255:0] g_g_rd_mask;
 logic [255:0][5:0] g_g_rd_addr;
 logic [95:0] g_g_rd_tag;
 logic  g_g_rd_rsp_valid;
 logic  g_g_rd_rsp_ready;
 logic [255:0][31:0] g_g_rd_rsp_data;
 logic [255:0] g_g_rd_rsp_mask;
 logic [95:0] g_g_rd_rsp_tag;
 logic  ln_cmd_valid;
 logic  ln_cmd_ready;
 logic [63:0] ln_cmd_request_id;
 logic [31:0] ln_cmd_generation;
 logic [31:0] ln_cmd_epoch;
 logic [7:0] ln_cmd_rows;
 logic  ln_cmd_gamma;
 logic [63:0] ln_cmd_model;
 logic [31:0] ln_cmd_key;
 logic  ln_in_valid;
 logic  ln_in_ready;
 logic [63:0] ln_in_request_id;
 logic [31:0] ln_in_generation;
 logic [31:0] ln_in_epoch;
 logic [6:0] ln_in_row;
 logic [4:0] ln_in_chunk;
 logic [95:0] ln_in_tag;
 logic [31:0][31:0] ln_in_data;
 logic  ln_out_valid;
 logic  ln_out_ready;
 logic [63:0] ln_out_request_id;
 logic [31:0] ln_out_generation;
 logic [31:0] ln_out_epoch;
 logic [6:0] ln_out_row;
 logic [4:0] ln_out_chunk;
 logic [95:0] ln_out_tag;
 logic [31:0][31:0] ln_out_data;
 logic  ln_done_ready;
 logic [63:0] ln_op_request_id;
 logic [31:0] ln_op_generation;
 logic [31:0] ln_op_epoch;
 logic  ln_mul_req_valid;
 logic  ln_mul_req_ready;
 logic [95:0] ln_mul_req_tag;
 logic [255:0][31:0] ln_mul_a;
 logic [255:0][31:0] ln_mul_b;
 logic  ln_mul_rsp_valid;
 logic  ln_mul_rsp_ready;
 logic [95:0] ln_mul_rsp_tag;
 logic [255:0][31:0] ln_mul_rsp_data;
 logic [6:0] ln_mul_pending;
 logic  ln_add_req_valid;
 logic  ln_add_req_ready;
 logic [95:0] ln_add_req_tag;
 logic [255:0][31:0] ln_add_a;
 logic [255:0][31:0] ln_add_b;
 logic  ln_add_rsp_valid;
 logic  ln_add_rsp_ready;
 logic [95:0] ln_add_rsp_tag;
 logic [255:0][31:0] ln_add_rsp_data;
 logic [6:0] ln_add_pending;
 logic  ln_div_req_valid;
 logic  ln_div_req_ready;
 logic [95:0] ln_div_req_tag;
 logic [31:0] ln_div_a;
 logic [31:0] ln_div_b;
 logic  ln_div_rsp_valid;
 logic  ln_div_rsp_ready;
 logic [95:0] ln_div_rsp_tag;
 logic [31:0] ln_div_rsp_data;
 logic  ln_div_rsp_error;
 logic [5:0] ln_div_pending;
 logic  ln_wr_valid;
 logic  ln_wr_ready;
 logic [255:0] ln_wr_mask;
 logic [255:0][4:0] ln_wr_addr;
 logic [255:0][31:0] ln_wr_data;
 logic [95:0] ln_wr_tag;
 logic  ln_wr_rsp_valid;
 logic  ln_wr_rsp_ready;
 logic [95:0] ln_wr_rsp_tag;
 logic  ln_rd_valid;
 logic  ln_rd_ready;
 logic [255:0] ln_rd_mask;
 logic [255:0][4:0] ln_rd_addr;
 logic [95:0] ln_rd_tag;
 logic  ln_rd_rsp_valid;
 logic  ln_rd_rsp_ready;
 logic [255:0][31:0] ln_rd_rsp_data;
 logic [95:0] ln_rd_rsp_tag;
 logic  ln_bank_idle;
 logic  ln_control_clear;
 logic  j_ln_cancel_valid;
 logic  j_ln_cancel_ready;
 logic [63:0] j_ln_cancel_request_id;
 logic [31:0] j_ln_cancel_generation;
 logic [31:0] j_ln_cancel_epoch;
 logic  ln_cmd_source_finite_qualified;
 logic  ln_cmd_source_summary_valid;
 logic  ln_cmd_source_bad_valid;
 logic [6:0] ln_cmd_source_bad_row;
 logic [9:0] ln_cmd_source_bad_element;
 logic  vector_owner_valid;
 logic  vector_inputs_ready;
 logic [63:0] vector_owner_request_id;
 logic [31:0] vector_owner_generation;
 logic [31:0] vector_owner_epoch;
 logic  vector_h_rd_valid;
 logic  vector_h_rd_ready;
 logic [11:0] vector_h_rd_addr;
 logic  vector_h_rsp_valid;
 logic  vector_h_rsp_ready;
 logic [11:0] vector_h_rsp_addr;
 logic [31:0][31:0] vector_h_rsp_data;
 logic  vector_q_rd_valid;
 logic  vector_q_rd_ready;
 logic [11:0] vector_q_rd_addr;
 logic  vector_q_rsp_valid;
 logic  vector_q_rsp_ready;
 logic [11:0] vector_q_rsp_addr;
 logic [31:0][31:0] vector_q_rsp_data;
 logic  vector_h_wr_valid;
 logic  vector_h_wr_ready;
 logic [11:0] vector_h_wr_addr;
 logic [31:0][31:0] vector_h_wr_data;
 logic  vector_h_wr_commit;
 logic  vector_fp_lease_valid;
 logic  vector_fp_lease_ready;
 logic [63:0] vector_fp_lease_request_id;
 logic [31:0] vector_fp_lease_generation;
 logic [31:0] vector_fp_lease_epoch;
 logic [3:0] vector_fp_lease_head;
 logic [2:0] vector_fp_lease_phase;
 logic  vector_fp_release_valid;
 logic  vector_fp_release_ready;
 logic [2:0] vector_fp_release_phase;
 logic [31:0] vector_fp_release_epoch;
 logic  vector_fp_phase_debt_clear;
 logic  vector_fp_lease_active;
 logic [63:0] vector_fp_rsp_request_id;
 logic [31:0] vector_fp_rsp_generation;
 logic [31:0] vector_fp_rsp_epoch;
 logic [3:0] vector_fp_rsp_head;
 logic [2:0] vector_fp_rsp_phase;
 logic  vector_fp_protocol_fault;
 logic [6:0] vector_add_req_valid;
 logic [6:0] vector_add_req_is_root;
 logic [6:0] vector_add_req_ready;
 logic [6:0][2:0] vector_add_req_phase;
 logic [6:0][31:0] vector_add_req_epoch;
 logic [6:0][95:0] vector_add_req_tag;
 logic [255:0][31:0] vector_add_a;
 logic [255:0][31:0] vector_add_b;
 logic [6:0] vector_add_rsp_valid;
 logic [6:0] vector_add_rsp_ready;
 logic [6:0][95:0] vector_add_rsp_tag;
 logic [255:0][31:0] vector_add_rsp_data;
 logic  r_res_qkv_wr_valid;
 logic  r_res_qkv_wr_ready;
 logic [1:0] r_res_qkv_wr_plane;
 logic [3:0] r_res_qkv_wr_head;
 logic [6:0] r_res_qkv_wr_token;
 logic  r_res_qkv_wr_half;
 logic [31:0][31:0] r_res_qkv_wr_data;
 logic [2:0] r_res_qkv_rd_valid;
 logic [2:0] r_res_qkv_rd_ready;
 logic [2:0][3:0] r_res_qkv_rd_head;
 logic [2:0][6:0] r_res_qkv_rd_token;
 logic [2:0][31:0] r_res_qkv_rd_tag;
 logic [2:0] r_res_qkv_rd_rsp_valid;
 logic [2:0] r_res_qkv_rd_rsp_ready;
 logic [2:0][3:0] r_res_qkv_rd_rsp_head;
 logic [2:0][6:0] r_res_qkv_rd_rsp_token;
 logic [2:0][31:0] r_res_qkv_rd_rsp_tag;
 logic [2:0][63:0][31:0] r_res_qkv_rd_rsp_data;
 logic  r_res_st_bind_valid;
 logic  r_res_st_bind_ready;
 logic [63:0] r_res_st_bind_request_id;
 logic [31:0] r_res_st_bind_generation;
 logic [31:0] r_res_st_bind_epoch;
 logic [3:0] r_res_st_bind_head;
 logic [2:0] r_res_st_bind_phase;
 logic [63:0] r_res_st_op_request_id;
 logic [31:0] r_res_st_op_generation;
 logic [31:0] r_res_st_op_epoch;
 logic [2:0] r_res_st_op_phase;
 logic [63:0] r_res_st_rsp_request_id;
 logic [31:0] r_res_st_rsp_generation;
 logic [31:0] r_res_st_rsp_epoch;
 logic [3:0] r_res_st_rsp_head;
 logic [2:0] r_res_st_rsp_phase;
 logic  r_res_st_ps_wr_valid;
 logic  r_res_st_ps_wr_ready;
 logic [1023:0] r_res_st_ps_wr_mask;
 logic [1023:0][3:0] r_res_st_ps_wr_addr;
 logic [1023:0][31:0] r_res_st_ps_wr_data;
 logic [95:0] r_res_st_ps_wr_tag;
 logic  r_res_st_ps_wr_rsp_valid;
 logic  r_res_st_ps_wr_rsp_ready;
 logic [95:0] r_res_st_ps_wr_rsp_tag;
 logic  r_res_st_ps_rd_valid;
 logic  r_res_st_ps_rd_ready;
 logic [1023:0] r_res_st_ps_rd_mask;
 logic [1023:0][3:0] r_res_st_ps_rd_addr;
 logic [95:0] r_res_st_ps_rd_tag;
 logic  r_res_st_ps_rd_rsp_valid;
 logic  r_res_st_ps_rd_rsp_ready;
 logic [1023:0][31:0] r_res_st_ps_rd_rsp_data;
 logic [1023:0] r_res_st_ps_rd_rsp_mask;
 logic [95:0] r_res_st_ps_rd_rsp_tag;
 logic  r_res_st_g_wr_valid;
 logic  r_res_st_g_wr_ready;
 logic [255:0] r_res_st_g_wr_mask;
 logic [255:0][5:0] r_res_st_g_wr_addr;
 logic [255:0][31:0] r_res_st_g_wr_data;
 logic [95:0] r_res_st_g_wr_tag;
 logic  r_res_st_g_wr_rsp_valid;
 logic  r_res_st_g_wr_rsp_ready;
 logic [95:0] r_res_st_g_wr_rsp_tag;
 logic  r_res_st_g_rd_valid;
 logic  r_res_st_g_rd_ready;
 logic [255:0] r_res_st_g_rd_mask;
 logic [255:0][5:0] r_res_st_g_rd_addr;
 logic [95:0] r_res_st_g_rd_tag;
 logic  r_res_st_g_rd_rsp_valid;
 logic  r_res_st_g_rd_rsp_ready;
 logic [255:0][31:0] r_res_st_g_rd_rsp_data;
 logic [255:0] r_res_st_g_rd_rsp_mask;
 logic [95:0] r_res_st_g_rd_rsp_tag;
 logic  r_res_st_context_wr_valid;
 logic  r_res_st_context_wr_ready;
 logic [63:0] r_res_st_context_wr_mask;
 logic [63:0][10:0] r_res_st_context_wr_addr;
 logic [63:0][31:0] r_res_st_context_wr_data;
 logic [95:0] r_res_st_context_wr_tag;
 logic  r_res_st_context_wr_rsp_valid;
 logic  r_res_st_context_wr_rsp_ready;
 logic [95:0] r_res_st_context_wr_rsp_tag;
 logic  r_res_st_context_rd_valid;
 logic  r_res_st_context_rd_ready;
 logic [63:0] r_res_st_context_rd_mask;
 logic [63:0][10:0] r_res_st_context_rd_addr;
 logic [95:0] r_res_st_context_rd_tag;
 logic  r_res_st_context_rd_rsp_valid;
 logic  r_res_st_context_rd_rsp_ready;
 logic [63:0][31:0] r_res_st_context_rd_rsp_data;
 logic [63:0] r_res_st_context_rd_rsp_mask;
 logic [95:0] r_res_st_context_rd_rsp_tag;
 logic  r_res_st_idle;
 logic  r_res_fp_lease_valid;
 logic  r_res_fp_lease_ready;
 logic [63:0] r_res_fp_lease_request_id;
 logic [31:0] r_res_fp_lease_generation;
 logic [31:0] r_res_fp_lease_epoch;
 logic [3:0] r_res_fp_lease_head;
 logic [2:0] r_res_fp_lease_phase;
 logic  r_res_fp_release_valid;
 logic  r_res_fp_release_ready;
 logic [2:0] r_res_fp_release_phase;
 logic [31:0] r_res_fp_release_epoch;
 logic  r_res_fp_phase_debt_clear;
 logic  r_res_fp_lease_active;
 logic  r_res_fp_draining;
 logic [63:0] r_res_fp_rsp_request_id;
 logic [31:0] r_res_fp_rsp_generation;
 logic [31:0] r_res_fp_rsp_epoch;
 logic [3:0] r_res_fp_rsp_head;
 logic [2:0] r_res_fp_rsp_phase;
 logic  r_res_fp_mul_req_valid;
 logic  r_res_fp_mul_req_ready;
 logic [2:0] r_res_fp_mul_req_phase;
 logic [31:0] r_res_fp_mul_req_epoch;
 logic [95:0] r_res_fp_mul_req_tag;
 logic [255:0][31:0] r_res_fp_mul_a;
 logic [255:0][31:0] r_res_fp_mul_b;
 logic  r_res_fp_mul_rsp_valid;
 logic  r_res_fp_mul_rsp_ready;
 logic [95:0] r_res_fp_mul_rsp_tag;
 logic [255:0][31:0] r_res_fp_mul_rsp_data;
 logic [6:0] r_res_fp_add_req_valid;
 logic [6:0] r_res_fp_add_req_is_root;
 logic [6:0] r_res_fp_add_req_ready;
 logic [6:0][2:0] r_res_fp_add_req_phase;
 logic [6:0][31:0] r_res_fp_add_req_epoch;
 logic [6:0][95:0] r_res_fp_add_req_tag;
 logic [255:0][31:0] r_res_fp_add_a;
 logic [255:0][31:0] r_res_fp_add_b;
 logic [6:0] r_res_fp_add_rsp_valid;
 logic [6:0] r_res_fp_add_rsp_ready;
 logic [6:0][95:0] r_res_fp_add_rsp_tag;
 logic [255:0][31:0] r_res_fp_add_rsp_data;
 logic [6:0] r_res_fp_mul_pending;
 logic [6:0][6:0] r_res_fp_add_pending;
 logic  r_res_fp_protocol_fault;
 logic  r_res_ln_bind_valid;
 logic  r_res_ln_bind_ready;
 logic [63:0] r_res_ln_bind_request_id;
 logic [31:0] r_res_ln_bind_generation;
 logic [31:0] r_res_ln_bind_epoch;
 logic [3:0] r_res_ln_bind_head;
 logic [2:0] r_res_ln_bind_phase;
 logic [63:0] r_res_ln_op_request_id;
 logic [31:0] r_res_ln_op_generation;
 logic [31:0] r_res_ln_op_epoch;
 logic [2:0] r_res_ln_op_phase;
 logic [63:0] r_res_ln_rsp_request_id;
 logic [31:0] r_res_ln_rsp_generation;
 logic [31:0] r_res_ln_rsp_epoch;
 logic [3:0] r_res_ln_rsp_head;
 logic [2:0] r_res_ln_rsp_phase;
 logic  r_res_ln_wr_valid;
 logic  r_res_ln_wr_ready;
 logic [255:0] r_res_ln_wr_mask;
 logic [255:0][4:0] r_res_ln_wr_addr;
 logic [255:0][31:0] r_res_ln_wr_data;
 logic [95:0] r_res_ln_wr_tag;
 logic  r_res_ln_wr_rsp_valid;
 logic  r_res_ln_wr_rsp_ready;
 logic [95:0] r_res_ln_wr_rsp_tag;
 logic  r_res_ln_rd_valid;
 logic  r_res_ln_rd_ready;
 logic [255:0] r_res_ln_rd_mask;
 logic [255:0][4:0] r_res_ln_rd_addr;
 logic [95:0] r_res_ln_rd_tag;
 logic  r_res_ln_rd_rsp_valid;
 logic  r_res_ln_rd_rsp_ready;
 logic [255:0][31:0] r_res_ln_rd_rsp_data;
 logic [255:0] r_res_ln_rd_rsp_mask;
 logic [95:0] r_res_ln_rd_rsp_tag;
 logic  r_res_ln_idle;
 logic  r_res_sfu_lease_valid;
 logic  r_res_sfu_lease_ready;
 logic [63:0] r_res_sfu_lease_request_id;
 logic [31:0] r_res_sfu_lease_generation;
 logic [31:0] r_res_sfu_lease_epoch;
 logic [3:0] r_res_sfu_lease_head;
 logic [2:0] r_res_sfu_lease_phase;
 logic  r_res_sfu_release_valid;
 logic [2:0] r_res_sfu_release_phase;
 logic [31:0] r_res_sfu_release_epoch;
 logic  r_res_sfu_phase_debt_clear;
 logic  r_res_sfu_lease_active;
 logic [63:0] r_res_sfu_context_valid;
 logic [63:0] r_res_sfu_context_row_hi;
 logic  r_res_sfu_req_valid;
 logic  r_res_sfu_req_ready;
 logic [1:0] r_res_sfu_req_mode;
 logic [31:0] r_res_sfu_req_generation;
 logic [31:0] r_res_sfu_req_epoch;
 logic [2:0] r_res_sfu_req_phase;
 logic [10:0] r_res_sfu_req_tag;
 logic [7:0][31:0] r_res_sfu_req_x;
 logic  r_res_sfu_reject_valid;
 logic  r_res_sfu_rsp_valid;
 logic  r_res_sfu_rsp_ready;
 logic [10:0] r_res_sfu_rsp_tag;
 logic [7:0][31:0] r_res_sfu_rsp_data;
 logic [8:0] r_res_sfu_pending_vectors;
 logic [8:0] r_res_sfu_in_flight_vectors;
 logic  r_res_sfu_protocol_fault;
 logic  r_res_div_lease_valid;
 logic  r_res_div_lease_ready;
 logic [63:0] r_res_div_lease_request_id;
 logic [31:0] r_res_div_lease_generation;
 logic [31:0] r_res_div_lease_epoch;
 logic [3:0] r_res_div_lease_head;
 logic [2:0] r_res_div_lease_phase;
 logic  r_res_div_release_ready;
 logic  r_res_div_draining;
 logic [63:0] r_res_div_rsp_request_id;
 logic [31:0] r_res_div_rsp_generation;
 logic [31:0] r_res_div_rsp_epoch;
 logic [3:0] r_res_div_rsp_head;
 logic [2:0] r_res_div_rsp_phase;
 logic [3:0] r_res_div_protocol_reject_code;
 logic [7:0] r_res_div_rsp_lane_mask;
 logic  r_res_div_release_valid;
 logic [2:0] r_res_div_release_phase;
 logic [31:0] r_res_div_release_epoch;
 logic  r_res_div_phase_debt_clear;
 logic  r_res_div_lease_active;
 logic  r_res_div_req_valid;
 logic  r_res_div_req_ready;
 logic [31:0] r_res_div_req_generation;
 logic [31:0] r_res_div_req_epoch;
 logic [2:0] r_res_div_req_phase;
 logic [7:0] r_res_div_req_lane_mask;
 logic [95:0] r_res_div_req_tag;
 logic [7:0][31:0] r_res_div_req_a;
 logic [7:0][31:0] r_res_div_req_b;
 logic  r_res_div_protocol_reject_valid;
 logic  r_res_div_rsp_valid;
 logic  r_res_div_rsp_ready;
 logic [95:0] r_res_div_rsp_tag;
 logic [7:0] r_res_div_rsp_numeric_error;
 logic [7:0][31:0] r_res_div_rsp_data;
 logic [5:0] r_res_div_pending_vectors;
 logic [5:0] r_res_div_in_flight_vectors;
 logic [8:0] r_res_div_in_flight_scalars;
 logic  r_res_div_protocol_fault;
 logic  r_res_scale_valid;
 logic  r_res_scale_ready;
 logic [95:0] r_res_scale_tag;
 logic [3:0][31:0] r_res_scale_input;
 logic  r_res_scale_rsp_valid;
 logic  r_res_scale_rsp_ready;
 logic [95:0] r_res_scale_rsp_tag;
 logic [3:0][31:0] r_res_scale_data;
 logic [6:0] r_res_scale_pending;
 logic  r_res_scale_fault;
 logic  r_rope_owner_valid;
 logic [63:0] r_rope_owner_request_id;
 logic [31:0] r_rope_owner_generation;
 logic [31:0] r_rope_owner_epoch;
 logic  r_rope_wr_valid;
 logic  r_rope_wr_ready;
 logic [63:0] r_rope_wr_request_id;
 logic [31:0] r_rope_wr_generation;
 logic [31:0] r_rope_wr_epoch;
 logic [3:0] r_rope_wr_head;
 logic [6:0] r_rope_wr_token;
 logic [95:0] r_rope_wr_tag;
 logic [63:0][31:0] r_rope_wr_q;
 logic [63:0][31:0] r_rope_wr_k;
 logic  r_rope_wr_commit_valid;
 logic [95:0] r_rope_wr_commit_tag;
 logic  r_rope_reject_valid;
 logic [2:0] r_rope_reject_code;
 logic  p_control_enable;
 logic  p_source_success_valid;
 logic  p_source_invalidate;
 logic [63:0] p_owner_request_id;
 logic [31:0] p_owner_generation;
 logic [31:0] p_owner_epoch;
 logic  p_start_valid;
 logic  p_start_ready;
 logic [7:0] p_rows;
 logic  p_use_gamma;
 logic [63:0] p_model;
 logic [31:0] p_key;
 logic  p_done_valid;
 logic  p_done_ready;
 logic [31:0] p_done_status;
 logic [1:0] p_done_kind;
 logic  p_idle;
 logic  p_control_retired;
 logic  p_source_qualified;
 logic [12:0] p_issued_vectors;
 logic [12:0] p_written_vectors;
 logic  p_h_rd_valid;
 logic  p_h_rd_ready;
 logic [11:0] p_h_rd_addr;
 logic  p_h_rsp_valid;
 logic  p_h_rsp_ready;
 logic [11:0] p_h_rsp_addr;
 logic [31:0][31:0] p_h_rsp_data;
 logic  p_q_wr_valid;
 logic  p_q_wr_ready;
 logic [11:0] p_q_wr_addr;
 logic [31:0][31:0] p_q_wr_data;
 logic  p_q_wr_commit;
 logic  p_ln_cmd_valid;
 logic  p_ln_cmd_ready;
 logic [63:0] p_ln_cmd_request_id;
 logic [31:0] p_ln_cmd_generation;
 logic [31:0] p_ln_cmd_epoch;
 logic [7:0] p_ln_cmd_rows;
 logic  p_ln_cmd_gamma;
 logic [63:0] p_ln_cmd_model;
 logic [31:0] p_ln_cmd_key;
 logic  p_ln_source_finite_qualified;
 logic  p_ln_in_valid;
 logic  p_ln_in_ready;
 logic [63:0] p_ln_in_request_id;
 logic [31:0] p_ln_in_generation;
 logic [31:0] p_ln_in_epoch;
 logic [6:0] p_ln_in_row;
 logic [4:0] p_ln_in_chunk;
 logic [95:0] p_ln_in_tag;
 logic [31:0][31:0] p_ln_in_data;
 logic  p_ln_out_valid;
 logic  p_ln_out_ready;
 logic [63:0] p_ln_out_request_id;
 logic [31:0] p_ln_out_generation;
 logic [31:0] p_ln_out_epoch;
 logic [6:0] p_ln_out_row;
 logic [4:0] p_ln_out_chunk;
 logic [95:0] p_ln_out_tag;
 logic [31:0][31:0] p_ln_out_data;
 logic  p_ln_done_valid;
 logic  p_ln_done_ready;
 logic [1:0] p_ln_done_kind;
 logic  p_ln_debt_clear;
 logic  p_ln_cancel_accepted;
 logic  p_ln_reject_accepted;
 logic  p_protocol_cancel_valid;
 logic  p_protocol_cancel_ready;
 logic  p_fp_lease_valid;
 logic  p_fp_lease_ready;
 logic  p_div_lease_valid;
 logic  p_div_lease_ready;
 logic  p_bank_bind_valid;
 logic  p_bank_bind_ready;
 logic [63:0] p_lease_request_id;
 logic [31:0] p_lease_generation;
 logic [31:0] p_lease_epoch;
 logic [3:0] p_lease_head;
 logic [2:0] p_lease_phase;
 logic  p_fp_release_valid;
 logic  p_fp_release_ready;
 logic  p_div_release_valid;
 logic  p_div_release_ready;
 logic  p_phase_debt_clear;
 logic  p_fp_active;
 logic  p_div_active;
 logic  p_bank_idle;
 logic  scratch_normal_enable;
 logic  raw_scratch_lease_ready;
 logic  raw_g_tanh_lease_ready;
 logic  raw_g_tanh_release_ready;
 logic  scratch_wr_valid;
 logic  scratch_wr_ready;
 logic  scratch_wr_commit;
 logic [11:0] scratch_wr_addr;
 logic [31:0][31:0] scratch_wr_data;
 logic  scratch_rd_valid;
 logic  scratch_rd_ready;
 logic [11:0] scratch_rd_addr;
 logic  scratch_rsp_valid;
 logic  scratch_rsp_ready;
 logic [11:0] scratch_rsp_addr;
 logic [31:0][31:0] scratch_rsp_data;
 logic  scratch_adapter_reject;
 logic  raw_h_wr_valid;
 logic  raw_h_wr_ready;
 logic  raw_h_wr_commit;
 logic [11:0] raw_h_wr_addr;
 logic [31:0][31:0] raw_h_wr_data;
 logic  raw_h_rd_valid;
 logic  raw_h_rd_ready;
 logic [11:0] raw_h_rd_addr;
 logic  raw_h_rsp_valid;
 logic  raw_h_rsp_ready;
 logic [11:0] raw_h_rsp_addr;
 logic [31:0][31:0] raw_h_rsp_data;
 logic  sq_wr_valid;
 logic  sq_wr_ready;
 logic [1:0] sq_wr_plane;
 logic [3:0] sq_wr_head;
 logic [6:0] sq_wr_token;
 logic  sq_wr_half;
 logic [31:0][31:0] sq_wr_data;
 logic  sq_rd_valid;
 logic  sq_rd_ready;
 logic [3:0] sq_rd_head;
 logic [6:0] sq_rd_token;
 logic [31:0] sq_rd_tag;
 logic  sq_rsp_ready;
 logic [63:0] tanh_request;
 logic [31:0] tanh_generation;
 logic [31:0] tanh_epoch;
 logic [2:0] tanh_phase;
 logic [7:0] tanh_rsp_mask;
 logic [3:0] tanh_reject_code;
 logic  cfg_bind_valid;
 logic  cfg_bind_ready;
 logic  cfg_wr_valid;
 logic  cfg_wr_ready;
 assign j_a_prepare_valid=a_prepare_valid&&scratch_normal_enable;
 assign a_prepare_ready=j_a_prepare_ready&&scratch_normal_enable;
 assign j_a_qkv_wr_valid=a_qkv_wr_valid&&scratch_normal_enable;
 assign a_qkv_wr_ready=j_a_qkv_wr_ready&&scratch_normal_enable;
 assign j_a_start_valid=a_start_valid&&scratch_normal_enable;
 assign a_start_ready=j_a_start_ready&&scratch_normal_enable;
 assign j_a_result_rd_valid=a_result_rd_valid&&scratch_normal_enable;
 assign a_result_rd_ready=j_a_result_rd_ready&&scratch_normal_enable;
 wire ext_allowed=rst_n&&(a_enable||g_enable);
 wire external_identity=resident_access_request_id==resident_owner_request_id&&resident_access_generation==resident_owner_generation&&resident_access_epoch==resident_owner_epoch;
 wire vector_busy=vector_enable&&!vector_idle;
 wire ln_busy=!ln_provider_idle;
 wire public_bank_access=rst_n&&resident_owner_valid&&external_identity&&!vector_busy&&!ln_busy&&!vector_start_valid&&!resident_ln_start_valid;
 wire vsource=vector_enable&&vector_done_valid&&vector_done_ready&&vector_done_status==0&&vector_issued_vectors==4096&&vector_retired_vectors==4096&&h_bank_idle&&!raw_h_wr_valid;
 assign raw_h_wr_valid=vector_busy?vector_h_wr_valid:(public_bank_access&&h_wr_valid);
 assign raw_h_wr_addr=vector_busy?vector_h_wr_addr:h_wr_addr;
 assign raw_h_wr_data=vector_busy?vector_h_wr_data:h_wr_data;
 assign vector_h_wr_ready=vector_busy&&raw_h_wr_ready;
 assign vector_h_wr_commit=vector_busy&&raw_h_wr_commit;
 assign h_wr_ready=public_bank_access&&!vector_busy&&raw_h_wr_ready;
 assign h_wr_commit=h_wr_valid&&h_wr_ready;
 assign raw_h_rd_valid=vector_busy?vector_h_rd_valid:ln_busy?p_h_rd_valid:(public_bank_access&&h_rd_valid);
 assign raw_h_rd_addr=vector_busy?vector_h_rd_addr:ln_busy?p_h_rd_addr:h_rd_addr;
 assign vector_h_rd_ready=vector_busy&&raw_h_rd_ready;
 assign p_h_rd_ready=ln_busy&&raw_h_rd_ready;
 assign h_rd_ready=public_bank_access&&raw_h_rd_ready;
 assign vector_h_rsp_valid=vector_busy&&raw_h_rsp_valid;
 assign vector_h_rsp_addr=raw_h_rsp_addr;
 assign vector_h_rsp_data=raw_h_rsp_data;
 assign p_h_rsp_valid=ln_busy&&raw_h_rsp_valid;
 assign p_h_rsp_addr=raw_h_rsp_addr;
 assign p_h_rsp_data=raw_h_rsp_data;
 assign h_rsp_valid=!vector_busy&&!ln_busy&&raw_h_rsp_valid;
 assign h_rsp_addr=raw_h_rsp_addr;
 assign h_rsp_data=raw_h_rsp_data;
 assign raw_h_rsp_ready=vector_busy?vector_h_rsp_ready:ln_busy?p_h_rsp_ready:h_rsp_ready;
 assign h_reject_valid=rst_n&&(h_wr_valid||h_rd_valid)&&!public_bank_access;
 laya_m007_hidden32_v1 hidden(.clk,.rst_n,.enabled(resident_owner_valid),.wr_valid(raw_h_wr_valid),.wr_ready(raw_h_wr_ready),.wr_addr(raw_h_wr_addr),.wr_data(raw_h_wr_data),.wr_commit(raw_h_wr_commit),.rd_valid(raw_h_rd_valid),.rd_ready(raw_h_rd_ready),.rd_addr(raw_h_rd_addr),.rd_rsp_valid(raw_h_rsp_valid),.rd_rsp_ready(raw_h_rsp_ready),.rd_rsp_addr(raw_h_rsp_addr),.rd_rsp_data(raw_h_rsp_data),.bank_idle(h_bank_idle));
 assign scratch_wr_valid=ln_busy?p_q_wr_valid:(public_bank_access&&q_wr_valid);
 assign scratch_wr_addr=ln_busy?p_q_wr_addr:q_wr_addr;
 assign scratch_wr_data=ln_busy?p_q_wr_data:q_wr_data;
 assign p_q_wr_ready=ln_busy&&scratch_wr_ready;
 assign p_q_wr_commit=ln_busy&&scratch_wr_commit;
 assign q_wr_ready=public_bank_access&&scratch_wr_ready;
 assign q_wr_commit=q_wr_valid&&q_wr_ready;
 assign scratch_rd_valid=vector_busy?vector_q_rd_valid:(public_bank_access&&q_rd_valid);
 assign scratch_rd_addr=vector_busy?vector_q_rd_addr:q_rd_addr;
 assign vector_q_rd_ready=vector_busy&&scratch_rd_ready;
 assign q_rd_ready=public_bank_access&&scratch_rd_ready;
 assign vector_q_rsp_valid=vector_busy&&scratch_rsp_valid;
 assign vector_q_rsp_addr=scratch_rsp_addr;
 assign vector_q_rsp_data=scratch_rsp_data;
 assign q_rsp_valid=!vector_busy&&scratch_rsp_valid;
 assign q_rsp_addr=scratch_rsp_addr;
 assign q_rsp_data=scratch_rsp_data;
 assign scratch_rsp_ready=vector_busy?vector_q_rsp_ready:q_rsp_ready;
 assign q_reject_valid=scratch_adapter_reject||(rst_n&&(q_wr_valid||q_rd_valid)&&!public_bank_access);
 laya_m007_qscratch32_v1 scratch(.clk,.rst_n,.lease_valid(scratch_lease_valid&&resident_owner_valid),.lease_ready(raw_scratch_lease_ready),.release_valid(scratch_release_valid),.release_ready(scratch_release_ready),.layer_retired(a_layer_idle),.matrix_retired(parent_matrix_retired),.quant_retired(parent_quant_retired),.normal_requests_present(a_prepare_valid||a_qkv_wr_valid||a_start_valid||a_result_rd_valid||vector_start_valid||resident_ln_start_valid),.rope_owner_valid(a_rope_owner_valid),.qkv_rsp_valid(r_res_qkv_rd_rsp_valid),.owner_request_id(resident_owner_request_id),.owner_generation(resident_owner_generation),.owner_epoch(resident_owner_epoch),.owner_active(scratch_owner_active),.normal_enable(scratch_normal_enable),.access_request_id(resident_owner_request_id),.access_generation(resident_owner_generation),.access_epoch(resident_owner_epoch),.wr_valid(scratch_wr_valid),.wr_ready(scratch_wr_ready),.wr_addr(scratch_wr_addr),.wr_data(scratch_wr_data),.wr_commit(scratch_wr_commit),.rd_valid(scratch_rd_valid),.rd_ready(scratch_rd_ready),.rd_addr(scratch_rd_addr),.rd_rsp_valid(scratch_rsp_valid),.rd_rsp_ready(scratch_rsp_ready),.rd_rsp_addr(scratch_rsp_addr),.rd_rsp_data(scratch_rsp_data),.reject_valid(scratch_adapter_reject),.retired(scratch_retired),.q_wr_valid(sq_wr_valid),.q_wr_ready(sq_wr_ready),.q_wr_plane(sq_wr_plane),.q_wr_head(sq_wr_head),.q_wr_token(sq_wr_token),.q_wr_half(sq_wr_half),.q_wr_data(sq_wr_data),.q_rd_valid(sq_rd_valid),.q_rd_ready(sq_rd_ready),.q_rd_head(sq_rd_head),.q_rd_token(sq_rd_token),.q_rd_tag(sq_rd_tag),.q_rsp_valid(r_res_qkv_rd_rsp_valid[0]),.q_rsp_ready(sq_rsp_ready),.q_rsp_tag(r_res_qkv_rd_rsp_tag[0]),.q_rsp_data(r_res_qkv_rd_rsp_data[0]));
 assign scratch_lease_ready=resident_owner_valid&&raw_scratch_lease_ready;
 assign g_tanh_lease_ready=g_enable&&raw_g_tanh_lease_ready;
 assign g_tanh_release_ready=g_enable&&raw_g_tanh_release_ready;
 assign sq_wr_ready=scratch_owner_active&&r_res_qkv_wr_ready;
 assign sq_rd_ready=scratch_owner_active&&r_res_qkv_rd_ready[0];
 assign resident_bank_idle=h_bank_idle&&r_res_qkv_rd_rsp_valid==0&&!raw_h_wr_valid&&!raw_h_rd_valid&&!scratch_wr_valid&&!scratch_rd_valid;
 assign p_control_enable=ln_enable;
 assign p_source_success_valid=vsource;
 assign p_source_invalidate=h_wr_commit||(vector_start_valid&&vector_start_ready);
 assign p_owner_request_id=resident_owner_request_id;
 assign p_owner_generation=resident_owner_generation;
 assign p_owner_epoch=resident_owner_epoch;
 assign p_start_valid=resident_ln_start_valid&&resident_owner_valid&&scratch_owner_active;
 assign p_rows=resident_ln_rows;
 assign p_use_gamma=resident_ln_use_gamma;
 assign p_model=resident_ln_model;
 assign p_key=resident_ln_key;
 assign p_done_ready=resident_ln_done_ready;
 assign p_ln_debt_clear=ln_debt_clear;
 assign p_ln_cancel_accepted=j_ln_cancel_valid&&j_ln_cancel_ready;
 assign p_ln_reject_accepted=ln_reject_valid&&ln_reject_ready;
 assign p_protocol_cancel_ready=j_ln_cancel_ready;
 assign p_fp_active=r_res_fp_lease_active;
 assign p_div_active=r_res_div_lease_active;
 assign p_bank_idle=r_res_ln_idle;
 assign resident_ln_done_valid=p_done_valid;
 assign resident_ln_done_status=p_done_status;
 assign resident_ln_done_kind=p_done_kind;
 assign resident_ln_source_qualified=p_source_qualified;
 assign resident_ln_issued_vectors=p_issued_vectors;
 assign resident_ln_written_vectors=p_written_vectors;
 assign ln_provider_idle=p_idle;
 assign resident_ln_start_ready=resident_owner_valid&&scratch_owner_active&&p_start_ready;
 assign ln_cmd_valid=p_ln_cmd_valid;
 assign ln_cmd_request_id=p_ln_cmd_request_id;
 assign ln_cmd_generation=p_ln_cmd_generation;
 assign ln_cmd_epoch=p_ln_cmd_epoch;
 assign ln_cmd_rows=p_ln_cmd_rows;
 assign ln_cmd_gamma=p_ln_cmd_gamma;
 assign ln_cmd_model=p_ln_cmd_model;
 assign ln_cmd_key=p_ln_cmd_key;
 assign ln_in_valid=p_ln_in_valid;
 assign ln_in_request_id=p_ln_in_request_id;
 assign ln_in_generation=p_ln_in_generation;
 assign ln_in_epoch=p_ln_in_epoch;
 assign ln_in_row=p_ln_in_row;
 assign ln_in_chunk=p_ln_in_chunk;
 assign ln_in_tag=p_ln_in_tag;
 assign ln_in_data=p_ln_in_data;
 assign ln_out_ready=p_ln_out_ready;
 assign ln_done_ready=p_ln_done_ready;
 assign p_ln_cmd_ready=ln_cmd_ready;
 assign p_ln_in_ready=ln_in_ready;
 assign p_ln_out_valid=ln_out_valid;
 assign p_ln_out_request_id=ln_out_request_id;
 assign p_ln_out_generation=ln_out_generation;
 assign p_ln_out_epoch=ln_out_epoch;
 assign p_ln_out_row=ln_out_row;
 assign p_ln_out_chunk=ln_out_chunk;
 assign p_ln_out_tag=ln_out_tag;
 assign p_ln_out_data=ln_out_data;
 assign p_ln_done_valid=ln_done_valid;
 assign p_ln_done_kind=ln_done_kind;
 assign ln_cmd_source_finite_qualified=p_ln_source_finite_qualified;
 assign ln_cmd_source_summary_valid=1'b0;
 assign ln_cmd_source_bad_valid=1'b0;
 assign ln_cmd_source_bad_row=7'b0;
 assign ln_cmd_source_bad_element=10'b0;
 assign ln_control_clear=1'b0;
 assign j_ln_cancel_valid=p_protocol_cancel_valid||ln_cancel_valid;
 assign j_ln_cancel_request_id=p_protocol_cancel_valid?resident_owner_request_id:ln_cancel_request_id;
 assign j_ln_cancel_generation=p_protocol_cancel_valid?resident_owner_generation:ln_cancel_generation;
 assign j_ln_cancel_epoch=p_protocol_cancel_valid?resident_owner_epoch:ln_cancel_epoch;
 assign ln_cancel_ready=!p_protocol_cancel_valid&&j_ln_cancel_ready;
 laya_m007_resident_ln32_v1 ln_provider(
 .clk(clk),
 .rst_n(rst_n),
 .control_enable(p_control_enable),
 .source_success_valid(p_source_success_valid),
 .source_invalidate(p_source_invalidate),
 .owner_request_id(p_owner_request_id),
 .owner_generation(p_owner_generation),
 .owner_epoch(p_owner_epoch),
 .start_valid(p_start_valid),
 .start_ready(p_start_ready),
 .rows(p_rows),
 .use_gamma(p_use_gamma),
 .model(p_model),
 .key(p_key),
 .done_valid(p_done_valid),
 .done_ready(p_done_ready),
 .done_status(p_done_status),
 .done_kind(p_done_kind),
 .idle(p_idle),
 .control_retired(p_control_retired),
 .source_qualified(p_source_qualified),
 .issued_vectors(p_issued_vectors),
 .written_vectors(p_written_vectors),
 .h_rd_valid(p_h_rd_valid),
 .h_rd_ready(p_h_rd_ready),
 .h_rd_addr(p_h_rd_addr),
 .h_rsp_valid(p_h_rsp_valid),
 .h_rsp_ready(p_h_rsp_ready),
 .h_rsp_addr(p_h_rsp_addr),
 .h_rsp_data(p_h_rsp_data),
 .q_wr_valid(p_q_wr_valid),
 .q_wr_ready(p_q_wr_ready),
 .q_wr_addr(p_q_wr_addr),
 .q_wr_data(p_q_wr_data),
 .q_wr_commit(p_q_wr_commit),
 .ln_cmd_valid(p_ln_cmd_valid),
 .ln_cmd_ready(p_ln_cmd_ready),
 .ln_cmd_request_id(p_ln_cmd_request_id),
 .ln_cmd_generation(p_ln_cmd_generation),
 .ln_cmd_epoch(p_ln_cmd_epoch),
 .ln_cmd_rows(p_ln_cmd_rows),
 .ln_cmd_gamma(p_ln_cmd_gamma),
 .ln_cmd_model(p_ln_cmd_model),
 .ln_cmd_key(p_ln_cmd_key),
 .ln_source_finite_qualified(p_ln_source_finite_qualified),
 .ln_in_valid(p_ln_in_valid),
 .ln_in_ready(p_ln_in_ready),
 .ln_in_request_id(p_ln_in_request_id),
 .ln_in_generation(p_ln_in_generation),
 .ln_in_epoch(p_ln_in_epoch),
 .ln_in_row(p_ln_in_row),
 .ln_in_chunk(p_ln_in_chunk),
 .ln_in_tag(p_ln_in_tag),
 .ln_in_data(p_ln_in_data),
 .ln_out_valid(p_ln_out_valid),
 .ln_out_ready(p_ln_out_ready),
 .ln_out_request_id(p_ln_out_request_id),
 .ln_out_generation(p_ln_out_generation),
 .ln_out_epoch(p_ln_out_epoch),
 .ln_out_row(p_ln_out_row),
 .ln_out_chunk(p_ln_out_chunk),
 .ln_out_tag(p_ln_out_tag),
 .ln_out_data(p_ln_out_data),
 .ln_done_valid(p_ln_done_valid),
 .ln_done_ready(p_ln_done_ready),
 .ln_done_kind(p_ln_done_kind),
 .ln_debt_clear(p_ln_debt_clear),
 .ln_cancel_accepted(p_ln_cancel_accepted),
 .ln_reject_accepted(p_ln_reject_accepted),
 .protocol_cancel_valid(p_protocol_cancel_valid),
 .protocol_cancel_ready(p_protocol_cancel_ready),
 .fp_lease_valid(p_fp_lease_valid),
 .fp_lease_ready(p_fp_lease_ready),
 .div_lease_valid(p_div_lease_valid),
 .div_lease_ready(p_div_lease_ready),
 .bank_bind_valid(p_bank_bind_valid),
 .bank_bind_ready(p_bank_bind_ready),
 .lease_request_id(p_lease_request_id),
 .lease_generation(p_lease_generation),
 .lease_epoch(p_lease_epoch),
 .lease_head(p_lease_head),
 .lease_phase(p_lease_phase),
 .fp_release_valid(p_fp_release_valid),
 .fp_release_ready(p_fp_release_ready),
 .div_release_valid(p_div_release_valid),
 .div_release_ready(p_div_release_ready),
 .phase_debt_clear(p_phase_debt_clear),
 .fp_active(p_fp_active),
 .div_active(p_div_active),
 .bank_idle(p_bank_idle)
 );
 assign vector_owner_valid=resident_owner_valid&&scratch_owner_active;
 assign vector_inputs_ready=resident_inputs_ready&&scratch_owner_active;
 assign vector_owner_request_id=resident_owner_request_id;
 assign vector_owner_generation=resident_owner_generation;
 assign vector_owner_epoch=resident_owner_epoch;
 laya_m007_g_vector_pool_v1 g_pool(.clk,.rst_n(g_pool_reset_n),.req_valid(g_fp_req_valid),.req_ready(g_fp_req_ready),.req_tag(g_fp_req_tag),.req_a(g_fp_req_a),.req_b(g_fp_req_b),.rsp_valid(g_fp_rsp_valid),.rsp_tag(g_fp_rsp_tag),.rsp_data(g_fp_rsp_data),.rsp_status(g_fp_rsp_status),.protocol_fault(g_fp_pool_fault));
 laya_m007_tanh8_v2 #(.FORCE_CORE_CE(TANH_FORCE_CORE_CE)) g_tanh(.clk,.rst_n,.lease_valid(g_enable&&g_tanh_lease_valid),.lease_ready(raw_g_tanh_lease_ready),.lease_request_id(g_tanh_lease_request_id),.lease_generation(g_tanh_lease_generation),.lease_epoch(g_tanh_lease_epoch),.lease_phase(g_tanh_lease_phase),.release_valid(g_enable&&g_tanh_release_valid),.release_ready(raw_g_tanh_release_ready),.release_phase(g_tanh_release_phase),.release_epoch(g_tanh_release_epoch),.phase_debt_clear(g_tanh_phase_debt_clear),.lease_active(g_tanh_lease_active),.draining(g_tanh_draining),.rsp_request_id(tanh_request),.rsp_generation(tanh_generation),.rsp_epoch(tanh_epoch),.rsp_phase(tanh_phase),.req_valid(g_sfu_req_valid),.req_ready(g_sfu_req_ready),.req_mode(2'd1),.req_request_id(g_rsp_request_id),.req_generation(g_rsp_generation),.req_epoch(g_rsp_epoch),.req_phase(3'd1),.req_tag(g_sfu_req_tag),.req_mask(g_sfu_req_mask),.req_x(g_sfu_req_x),.reject_valid(g_sfu_reject_valid),.reject_code(tanh_reject_code),.rsp_valid(g_sfu_rsp_valid),.rsp_ready(g_sfu_rsp_ready),.rsp_tag(g_sfu_rsp_tag),.rsp_mask(tanh_rsp_mask),.rsp_data(g_sfu_rsp_data),.rsp_status(g_sfu_rsp_status),.pending_vectors(g_tanh_pending_vectors),.in_flight_vectors(g_tanh_in_flight_vectors),.protocol_fault(g_sfu_protocol_fault));
 assign g_storage_owner_valid=g_enable&&r_res_fp_lease_active&&r_res_fp_rsp_request_id==resident_owner_request_id&&r_res_fp_rsp_generation==resident_owner_generation&&r_res_fp_rsp_epoch==resident_owner_epoch;
 assign g_storage_owner_request_id=r_res_st_rsp_request_id;
 assign g_storage_owner_generation=r_res_st_rsp_generation;
 assign g_storage_owner_epoch=r_res_st_rsp_epoch;
 assign g_storage_owner_phase=r_res_st_rsp_phase;
 assign g_sfu_owner_valid=g_tanh_lease_active;
 assign g_sfu_owner_request_id=tanh_request;
 assign g_sfu_owner_generation=tanh_generation;
 assign g_sfu_owner_epoch=tanh_epoch;
 assign g_sfu_owner_phase=tanh_phase;
 assign r_res_qkv_wr_valid=scratch_owner_active?(sq_wr_valid):(a_res_qkv_wr_valid);
 assign a_res_qkv_wr_ready=(1'b1&&!scratch_owner_active)?r_res_qkv_wr_ready:'0;
 assign r_res_qkv_wr_plane=scratch_owner_active?(sq_wr_plane):(a_res_qkv_wr_plane);
 assign r_res_qkv_wr_head=scratch_owner_active?(sq_wr_head):(a_res_qkv_wr_head);
 assign r_res_qkv_wr_token=scratch_owner_active?(sq_wr_token):(a_res_qkv_wr_token);
 assign r_res_qkv_wr_half=scratch_owner_active?(sq_wr_half):(a_res_qkv_wr_half);
 assign r_res_qkv_wr_data=scratch_owner_active?(sq_wr_data):(a_res_qkv_wr_data);
 assign r_res_qkv_rd_valid=scratch_owner_active?({2'b0,sq_rd_valid}):(a_res_qkv_rd_valid);
 assign a_res_qkv_rd_ready=(1'b1&&!scratch_owner_active)?r_res_qkv_rd_ready:'0;
 assign r_res_qkv_rd_head=scratch_owner_active?({8'b0,sq_rd_head}):(a_res_qkv_rd_head);
 assign r_res_qkv_rd_token=scratch_owner_active?({14'b0,sq_rd_token}):(a_res_qkv_rd_token);
 assign r_res_qkv_rd_tag=scratch_owner_active?({64'b0,sq_rd_tag}):(a_res_qkv_rd_tag);
 assign a_res_qkv_rd_rsp_valid=(1'b1&&!scratch_owner_active)?r_res_qkv_rd_rsp_valid:'0;
 assign r_res_qkv_rd_rsp_ready=scratch_owner_active?({2'b0,sq_rsp_ready}):(a_res_qkv_rd_rsp_ready);
 assign a_res_qkv_rd_rsp_head=r_res_qkv_rd_rsp_head;
 assign a_res_qkv_rd_rsp_token=r_res_qkv_rd_rsp_token;
 assign a_res_qkv_rd_rsp_tag=r_res_qkv_rd_rsp_tag;
 assign a_res_qkv_rd_rsp_data=r_res_qkv_rd_rsp_data;
 assign r_res_st_bind_valid=ext_bind_select?(ext_allowed?ext_res_st_bind_valid:'0):(a_res_st_bind_valid);
 assign a_res_st_bind_ready=r_res_st_bind_ready;
 assign ext_res_st_bind_ready=ext_allowed&&ext_bind_select?r_res_st_bind_ready:'0;
 assign r_res_st_bind_request_id=ext_bind_select?(ext_allowed?ext_res_st_bind_request_id:'0):(a_res_st_bind_request_id);
 assign r_res_st_bind_generation=ext_bind_select?(ext_allowed?ext_res_st_bind_generation:'0):(a_res_st_bind_generation);
 assign r_res_st_bind_epoch=ext_bind_select?(ext_allowed?ext_res_st_bind_epoch:'0):(a_res_st_bind_epoch);
 assign r_res_st_bind_head=ext_bind_select?(ext_allowed?ext_res_st_bind_head:'0):(a_res_st_bind_head);
 assign r_res_st_bind_phase=ext_bind_select?(ext_allowed?ext_res_st_bind_phase:'0):(a_res_st_bind_phase);
 assign r_res_st_op_request_id=ext_bind_select?(ext_allowed?ext_res_st_op_request_id:'0):(a_res_st_op_request_id);
 assign r_res_st_op_generation=ext_bind_select?(ext_allowed?ext_res_st_op_generation:'0):(a_res_st_op_generation);
 assign r_res_st_op_epoch=ext_bind_select?(ext_allowed?ext_res_st_op_epoch:'0):(a_res_st_op_epoch);
 assign r_res_st_op_phase=ext_bind_select?(ext_allowed?ext_res_st_op_phase:'0):(a_res_st_op_phase);
 assign a_res_st_rsp_request_id=r_res_st_rsp_request_id;
 assign ext_res_st_rsp_request_id=r_res_st_rsp_request_id;
 assign a_res_st_rsp_generation=r_res_st_rsp_generation;
 assign ext_res_st_rsp_generation=r_res_st_rsp_generation;
 assign a_res_st_rsp_epoch=r_res_st_rsp_epoch;
 assign ext_res_st_rsp_epoch=r_res_st_rsp_epoch;
 assign a_res_st_rsp_head=r_res_st_rsp_head;
 assign ext_res_st_rsp_head=r_res_st_rsp_head;
 assign a_res_st_rsp_phase=r_res_st_rsp_phase;
 assign ext_res_st_rsp_phase=r_res_st_rsp_phase;
 assign r_res_st_ps_wr_valid=ext_ps_select?(ext_allowed?ext_res_st_ps_wr_valid:'0):(a_res_st_ps_wr_valid);
 assign a_res_st_ps_wr_ready=(!ext_ps_select)?r_res_st_ps_wr_ready:'0;
 assign ext_res_st_ps_wr_ready=ext_allowed&&ext_ps_select?r_res_st_ps_wr_ready:'0;
 assign r_res_st_ps_wr_mask=ext_ps_select?(ext_allowed?ext_res_st_ps_wr_mask:'0):(a_res_st_ps_wr_mask);
 assign r_res_st_ps_wr_addr=ext_ps_select?(ext_allowed?ext_res_st_ps_wr_addr:'0):(a_res_st_ps_wr_addr);
 assign r_res_st_ps_wr_data=ext_ps_select?(ext_allowed?ext_res_st_ps_wr_data:'0):(a_res_st_ps_wr_data);
 assign r_res_st_ps_wr_tag=ext_ps_select?(ext_allowed?ext_res_st_ps_wr_tag:'0):(a_res_st_ps_wr_tag);
 assign a_res_st_ps_wr_rsp_valid=(!ext_ps_select)?r_res_st_ps_wr_rsp_valid:'0;
 assign ext_res_st_ps_wr_rsp_valid=ext_allowed&&ext_ps_select?r_res_st_ps_wr_rsp_valid:'0;
 assign r_res_st_ps_wr_rsp_ready=ext_ps_select?(ext_allowed?ext_res_st_ps_wr_rsp_ready:'0):(a_res_st_ps_wr_rsp_ready);
 assign a_res_st_ps_wr_rsp_tag=r_res_st_ps_wr_rsp_tag;
 assign ext_res_st_ps_wr_rsp_tag=r_res_st_ps_wr_rsp_tag;
 assign r_res_st_ps_rd_valid=ext_ps_select?(ext_allowed?ext_res_st_ps_rd_valid:'0):(a_res_st_ps_rd_valid);
 assign a_res_st_ps_rd_ready=(!ext_ps_select)?r_res_st_ps_rd_ready:'0;
 assign ext_res_st_ps_rd_ready=ext_allowed&&ext_ps_select?r_res_st_ps_rd_ready:'0;
 assign r_res_st_ps_rd_mask=ext_ps_select?(ext_allowed?ext_res_st_ps_rd_mask:'0):(a_res_st_ps_rd_mask);
 assign r_res_st_ps_rd_addr=ext_ps_select?(ext_allowed?ext_res_st_ps_rd_addr:'0):(a_res_st_ps_rd_addr);
 assign r_res_st_ps_rd_tag=ext_ps_select?(ext_allowed?ext_res_st_ps_rd_tag:'0):(a_res_st_ps_rd_tag);
 assign a_res_st_ps_rd_rsp_valid=(!ext_ps_select)?r_res_st_ps_rd_rsp_valid:'0;
 assign ext_res_st_ps_rd_rsp_valid=ext_allowed&&ext_ps_select?r_res_st_ps_rd_rsp_valid:'0;
 assign r_res_st_ps_rd_rsp_ready=ext_ps_select?(ext_allowed?ext_res_st_ps_rd_rsp_ready:'0):(a_res_st_ps_rd_rsp_ready);
 assign a_res_st_ps_rd_rsp_data=r_res_st_ps_rd_rsp_data;
 assign ext_res_st_ps_rd_rsp_data=r_res_st_ps_rd_rsp_data;
 assign a_res_st_ps_rd_rsp_mask=r_res_st_ps_rd_rsp_mask;
 assign ext_res_st_ps_rd_rsp_mask=r_res_st_ps_rd_rsp_mask;
 assign a_res_st_ps_rd_rsp_tag=r_res_st_ps_rd_rsp_tag;
 assign ext_res_st_ps_rd_rsp_tag=r_res_st_ps_rd_rsp_tag;
 assign r_res_st_g_wr_valid=g_enable?g_g_wr_valid:(a_res_st_g_wr_valid);
 assign a_res_st_g_wr_ready=(1'b1&&!g_enable)?r_res_st_g_wr_ready:'0;
 assign r_res_st_g_wr_mask=g_enable?g_g_wr_mask:(a_res_st_g_wr_mask);
 assign r_res_st_g_wr_addr=g_enable?g_g_wr_addr:(a_res_st_g_wr_addr);
 assign r_res_st_g_wr_data=g_enable?g_g_wr_data:(a_res_st_g_wr_data);
 assign r_res_st_g_wr_tag=g_enable?g_g_wr_tag:(a_res_st_g_wr_tag);
 assign a_res_st_g_wr_rsp_valid=(1'b1&&!g_enable)?r_res_st_g_wr_rsp_valid:'0;
 assign r_res_st_g_wr_rsp_ready=g_enable?g_g_wr_rsp_ready:(a_res_st_g_wr_rsp_ready);
 assign a_res_st_g_wr_rsp_tag=r_res_st_g_wr_rsp_tag;
 assign r_res_st_g_rd_valid=g_enable?g_g_rd_valid:(a_res_st_g_rd_valid);
 assign a_res_st_g_rd_ready=(1'b1&&!g_enable)?r_res_st_g_rd_ready:'0;
 assign r_res_st_g_rd_mask=g_enable?g_g_rd_mask:(a_res_st_g_rd_mask);
 assign r_res_st_g_rd_addr=g_enable?g_g_rd_addr:(a_res_st_g_rd_addr);
 assign r_res_st_g_rd_tag=g_enable?g_g_rd_tag:(a_res_st_g_rd_tag);
 assign a_res_st_g_rd_rsp_valid=(1'b1&&!g_enable)?r_res_st_g_rd_rsp_valid:'0;
 assign r_res_st_g_rd_rsp_ready=g_enable?g_g_rd_rsp_ready:(a_res_st_g_rd_rsp_ready);
 assign a_res_st_g_rd_rsp_data=r_res_st_g_rd_rsp_data;
 assign a_res_st_g_rd_rsp_mask=r_res_st_g_rd_rsp_mask;
 assign a_res_st_g_rd_rsp_tag=r_res_st_g_rd_rsp_tag;
 assign r_res_st_context_wr_valid=ext_context_select?(ext_allowed?ext_res_st_context_wr_valid:'0):(a_res_st_context_wr_valid);
 assign a_res_st_context_wr_ready=(!ext_context_select)?r_res_st_context_wr_ready:'0;
 assign ext_res_st_context_wr_ready=ext_allowed&&ext_context_select?r_res_st_context_wr_ready:'0;
 assign r_res_st_context_wr_mask=ext_context_select?(ext_allowed?ext_res_st_context_wr_mask:'0):(a_res_st_context_wr_mask);
 assign r_res_st_context_wr_addr=ext_context_select?(ext_allowed?ext_res_st_context_wr_addr:'0):(a_res_st_context_wr_addr);
 assign r_res_st_context_wr_data=ext_context_select?(ext_allowed?ext_res_st_context_wr_data:'0):(a_res_st_context_wr_data);
 assign r_res_st_context_wr_tag=ext_context_select?(ext_allowed?ext_res_st_context_wr_tag:'0):(a_res_st_context_wr_tag);
 assign a_res_st_context_wr_rsp_valid=(!ext_context_select)?r_res_st_context_wr_rsp_valid:'0;
 assign ext_res_st_context_wr_rsp_valid=ext_allowed&&ext_context_select?r_res_st_context_wr_rsp_valid:'0;
 assign r_res_st_context_wr_rsp_ready=ext_context_select?(ext_allowed?ext_res_st_context_wr_rsp_ready:'0):(a_res_st_context_wr_rsp_ready);
 assign a_res_st_context_wr_rsp_tag=r_res_st_context_wr_rsp_tag;
 assign ext_res_st_context_wr_rsp_tag=r_res_st_context_wr_rsp_tag;
 assign r_res_st_context_rd_valid=ext_context_select?(ext_allowed?ext_res_st_context_rd_valid:'0):(a_res_st_context_rd_valid);
 assign a_res_st_context_rd_ready=(!ext_context_select)?r_res_st_context_rd_ready:'0;
 assign ext_res_st_context_rd_ready=ext_allowed&&ext_context_select?r_res_st_context_rd_ready:'0;
 assign r_res_st_context_rd_mask=ext_context_select?(ext_allowed?ext_res_st_context_rd_mask:'0):(a_res_st_context_rd_mask);
 assign r_res_st_context_rd_addr=ext_context_select?(ext_allowed?ext_res_st_context_rd_addr:'0):(a_res_st_context_rd_addr);
 assign r_res_st_context_rd_tag=ext_context_select?(ext_allowed?ext_res_st_context_rd_tag:'0):(a_res_st_context_rd_tag);
 assign a_res_st_context_rd_rsp_valid=(!ext_context_select)?r_res_st_context_rd_rsp_valid:'0;
 assign ext_res_st_context_rd_rsp_valid=ext_allowed&&ext_context_select?r_res_st_context_rd_rsp_valid:'0;
 assign r_res_st_context_rd_rsp_ready=ext_context_select?(ext_allowed?ext_res_st_context_rd_rsp_ready:'0):(a_res_st_context_rd_rsp_ready);
 assign a_res_st_context_rd_rsp_data=r_res_st_context_rd_rsp_data;
 assign ext_res_st_context_rd_rsp_data=r_res_st_context_rd_rsp_data;
 assign a_res_st_context_rd_rsp_mask=r_res_st_context_rd_rsp_mask;
 assign ext_res_st_context_rd_rsp_mask=r_res_st_context_rd_rsp_mask;
 assign a_res_st_context_rd_rsp_tag=r_res_st_context_rd_rsp_tag;
 assign ext_res_st_context_rd_rsp_tag=r_res_st_context_rd_rsp_tag;
 assign a_res_st_idle=r_res_st_idle;
 assign ext_res_st_idle=r_res_st_idle;
 assign r_res_fp_lease_valid=ext_fp_select?(ext_allowed?ext_res_fp_lease_valid:'0):(ln_enable?(p_fp_lease_valid):vector_enable?(vector_fp_lease_valid):(a_res_fp_lease_valid));
 assign a_res_fp_lease_ready=r_res_fp_lease_ready;
 assign ext_res_fp_lease_ready=ext_allowed&&ext_fp_select?r_res_fp_lease_ready:'0;
 assign r_res_fp_lease_request_id=ext_fp_select?(ext_allowed?ext_res_fp_lease_request_id:'0):(ln_enable?(p_lease_request_id):vector_enable?(vector_fp_lease_request_id):(a_res_fp_lease_request_id));
 assign r_res_fp_lease_generation=ext_fp_select?(ext_allowed?ext_res_fp_lease_generation:'0):(ln_enable?(p_lease_generation):vector_enable?(vector_fp_lease_generation):(a_res_fp_lease_generation));
 assign r_res_fp_lease_epoch=ext_fp_select?(ext_allowed?ext_res_fp_lease_epoch:'0):(ln_enable?(p_lease_epoch):vector_enable?(vector_fp_lease_epoch):(a_res_fp_lease_epoch));
 assign r_res_fp_lease_head=ext_fp_select?(ext_allowed?ext_res_fp_lease_head:'0):(ln_enable?(p_lease_head):vector_enable?(vector_fp_lease_head):(a_res_fp_lease_head));
 assign r_res_fp_lease_phase=ext_fp_select?(ext_allowed?ext_res_fp_lease_phase:'0):(ln_enable?(p_lease_phase):vector_enable?(vector_fp_lease_phase):(a_res_fp_lease_phase));
 assign r_res_fp_release_valid=ext_fp_select?(ext_allowed?ext_res_fp_release_valid:'0):(ln_enable?(p_fp_release_valid):vector_enable?(vector_fp_release_valid):(a_res_fp_release_valid));
 assign a_res_fp_release_ready=(!ext_fp_select&&!ln_enable&&!vector_enable)?r_res_fp_release_ready:'0;
 assign ext_res_fp_release_ready=ext_allowed&&ext_fp_select?r_res_fp_release_ready:'0;
 assign r_res_fp_release_phase=ext_fp_select?(ext_allowed?ext_res_fp_release_phase:'0):(ln_enable?(3'd6):vector_enable?(vector_fp_release_phase):(a_res_fp_release_phase));
 assign r_res_fp_release_epoch=ext_fp_select?(ext_allowed?ext_res_fp_release_epoch:'0):(ln_enable?(resident_owner_epoch):vector_enable?(vector_fp_release_epoch):(a_res_fp_release_epoch));
 assign r_res_fp_phase_debt_clear=ext_fp_select?(ext_allowed?ext_res_fp_phase_debt_clear:'0):(ln_enable?(p_phase_debt_clear):vector_enable?(vector_fp_phase_debt_clear):(a_res_fp_phase_debt_clear));
 assign a_res_fp_lease_active=r_res_fp_lease_active;
 assign ext_res_fp_lease_active=r_res_fp_lease_active;
 assign a_res_fp_draining=r_res_fp_draining;
 assign ext_res_fp_draining=r_res_fp_draining;
 assign a_res_fp_rsp_request_id=r_res_fp_rsp_request_id;
 assign ext_res_fp_rsp_request_id=r_res_fp_rsp_request_id;
 assign a_res_fp_rsp_generation=r_res_fp_rsp_generation;
 assign ext_res_fp_rsp_generation=r_res_fp_rsp_generation;
 assign a_res_fp_rsp_epoch=r_res_fp_rsp_epoch;
 assign ext_res_fp_rsp_epoch=r_res_fp_rsp_epoch;
 assign a_res_fp_rsp_head=r_res_fp_rsp_head;
 assign ext_res_fp_rsp_head=r_res_fp_rsp_head;
 assign a_res_fp_rsp_phase=r_res_fp_rsp_phase;
 assign ext_res_fp_rsp_phase=r_res_fp_rsp_phase;
 assign r_res_fp_mul_req_valid=ext_fp_select?(ext_allowed?ext_res_fp_mul_req_valid:'0):(ln_enable?(ln_mul_req_valid):vector_enable?('0):(a_res_fp_mul_req_valid));
 assign a_res_fp_mul_req_ready=(!ext_fp_select&&!ln_enable&&!vector_enable)?r_res_fp_mul_req_ready:'0;
 assign ext_res_fp_mul_req_ready=ext_allowed&&ext_fp_select?r_res_fp_mul_req_ready:'0;
 assign r_res_fp_mul_req_phase=ext_fp_select?(ext_allowed?ext_res_fp_mul_req_phase:'0):(ln_enable?(3'd6):vector_enable?('0):(a_res_fp_mul_req_phase));
 assign r_res_fp_mul_req_epoch=ext_fp_select?(ext_allowed?ext_res_fp_mul_req_epoch:'0):(ln_enable?(resident_owner_epoch):vector_enable?('0):(a_res_fp_mul_req_epoch));
 assign r_res_fp_mul_req_tag=ext_fp_select?(ext_allowed?ext_res_fp_mul_req_tag:'0):(ln_enable?(ln_mul_req_tag):vector_enable?('0):(a_res_fp_mul_req_tag));
 assign r_res_fp_mul_a=ext_fp_select?(ext_allowed?ext_res_fp_mul_a:'0):(ln_enable?(ln_mul_a):vector_enable?('0):(a_res_fp_mul_a));
 assign r_res_fp_mul_b=ext_fp_select?(ext_allowed?ext_res_fp_mul_b:'0):(ln_enable?(ln_mul_b):vector_enable?('0):(a_res_fp_mul_b));
 assign a_res_fp_mul_rsp_valid=(!ext_fp_select&&!ln_enable&&!vector_enable)?r_res_fp_mul_rsp_valid:'0;
 assign ext_res_fp_mul_rsp_valid=ext_allowed&&ext_fp_select?r_res_fp_mul_rsp_valid:'0;
 assign r_res_fp_mul_rsp_ready=ext_fp_select?(ext_allowed?ext_res_fp_mul_rsp_ready:'0):(ln_enable?(ln_mul_rsp_ready):vector_enable?('0):(a_res_fp_mul_rsp_ready));
 assign a_res_fp_mul_rsp_tag=r_res_fp_mul_rsp_tag;
 assign ext_res_fp_mul_rsp_tag=r_res_fp_mul_rsp_tag;
 assign a_res_fp_mul_rsp_data=r_res_fp_mul_rsp_data;
 assign ext_res_fp_mul_rsp_data=r_res_fp_mul_rsp_data;
 assign r_res_fp_add_req_valid=ext_fp_select?(ext_allowed?ext_res_fp_add_req_valid:'0):(ln_enable?({6'b0,ln_add_req_valid}):vector_enable?(vector_add_req_valid):(a_res_fp_add_req_valid));
 assign r_res_fp_add_req_is_root=ext_fp_select?(ext_allowed?ext_res_fp_add_req_is_root:'0):(ln_enable?(7'b0):vector_enable?(vector_add_req_is_root):(a_res_fp_add_req_is_root));
 assign a_res_fp_add_req_ready=(!ext_fp_select&&!ln_enable&&!vector_enable)?r_res_fp_add_req_ready:'0;
 assign ext_res_fp_add_req_ready=ext_allowed&&ext_fp_select?r_res_fp_add_req_ready:'0;
 assign r_res_fp_add_req_phase=ext_fp_select?(ext_allowed?ext_res_fp_add_req_phase:'0):(ln_enable?({7{3'd6}}):vector_enable?(vector_add_req_phase):(a_res_fp_add_req_phase));
 assign r_res_fp_add_req_epoch=ext_fp_select?(ext_allowed?ext_res_fp_add_req_epoch:'0):(ln_enable?({7{resident_owner_epoch}}):vector_enable?(vector_add_req_epoch):(a_res_fp_add_req_epoch));
 assign r_res_fp_add_req_tag=ext_fp_select?(ext_allowed?ext_res_fp_add_req_tag:'0):(ln_enable?({576'b0,ln_add_req_tag}):vector_enable?(vector_add_req_tag):(a_res_fp_add_req_tag));
 assign r_res_fp_add_a=ext_fp_select?(ext_allowed?ext_res_fp_add_a:'0):(ln_enable?(ln_add_a):vector_enable?(vector_add_a):(a_res_fp_add_a));
 assign r_res_fp_add_b=ext_fp_select?(ext_allowed?ext_res_fp_add_b:'0):(ln_enable?(ln_add_b):vector_enable?(vector_add_b):(a_res_fp_add_b));
 assign a_res_fp_add_rsp_valid=(!ext_fp_select&&!ln_enable&&!vector_enable)?r_res_fp_add_rsp_valid:'0;
 assign ext_res_fp_add_rsp_valid=ext_allowed&&ext_fp_select?r_res_fp_add_rsp_valid:'0;
 assign r_res_fp_add_rsp_ready=ext_fp_select?(ext_allowed?ext_res_fp_add_rsp_ready:'0):(ln_enable?({6'b0,ln_add_rsp_ready}):vector_enable?(vector_add_rsp_ready):(a_res_fp_add_rsp_ready));
 assign a_res_fp_add_rsp_tag=r_res_fp_add_rsp_tag;
 assign ext_res_fp_add_rsp_tag=r_res_fp_add_rsp_tag;
 assign a_res_fp_add_rsp_data=r_res_fp_add_rsp_data;
 assign ext_res_fp_add_rsp_data=r_res_fp_add_rsp_data;
 assign a_res_fp_mul_pending=r_res_fp_mul_pending;
 assign ext_res_fp_mul_pending=r_res_fp_mul_pending;
 assign a_res_fp_add_pending=r_res_fp_add_pending;
 assign ext_res_fp_add_pending=r_res_fp_add_pending;
 assign a_res_fp_protocol_fault=r_res_fp_protocol_fault;
 assign ext_res_fp_protocol_fault=r_res_fp_protocol_fault;
 assign r_res_ln_bind_valid=ln_enable?(p_bank_bind_valid):(a_res_ln_bind_valid);
 assign a_res_ln_bind_ready=(1'b1&&!ln_enable)?r_res_ln_bind_ready:'0;
 assign r_res_ln_bind_request_id=ln_enable?(resident_owner_request_id):(a_res_ln_bind_request_id);
 assign r_res_ln_bind_generation=ln_enable?(resident_owner_generation):(a_res_ln_bind_generation);
 assign r_res_ln_bind_epoch=ln_enable?(resident_owner_epoch):(a_res_ln_bind_epoch);
 assign r_res_ln_bind_head=ln_enable?(4'b0):(a_res_ln_bind_head);
 assign r_res_ln_bind_phase=ln_enable?(3'd6):(a_res_ln_bind_phase);
 assign r_res_ln_op_request_id=ln_enable?(ln_op_request_id):(a_res_ln_op_request_id);
 assign r_res_ln_op_generation=ln_enable?(ln_op_generation):(a_res_ln_op_generation);
 assign r_res_ln_op_epoch=ln_enable?(ln_op_epoch):(a_res_ln_op_epoch);
 assign r_res_ln_op_phase=ln_enable?(3'd6):(a_res_ln_op_phase);
 assign a_res_ln_rsp_request_id=r_res_ln_rsp_request_id;
 assign a_res_ln_rsp_generation=r_res_ln_rsp_generation;
 assign a_res_ln_rsp_epoch=r_res_ln_rsp_epoch;
 assign a_res_ln_rsp_head=r_res_ln_rsp_head;
 assign a_res_ln_rsp_phase=r_res_ln_rsp_phase;
 assign r_res_ln_wr_valid=ln_enable?(ln_wr_valid):(a_res_ln_wr_valid);
 assign a_res_ln_wr_ready=(1'b1&&!ln_enable)?r_res_ln_wr_ready:'0;
 assign r_res_ln_wr_mask=ln_enable?(ln_wr_mask):(a_res_ln_wr_mask);
 assign r_res_ln_wr_addr=ln_enable?(ln_wr_addr):(a_res_ln_wr_addr);
 assign r_res_ln_wr_data=ln_enable?(ln_wr_data):(a_res_ln_wr_data);
 assign r_res_ln_wr_tag=ln_enable?(ln_wr_tag):(a_res_ln_wr_tag);
 assign a_res_ln_wr_rsp_valid=(1'b1&&!ln_enable)?r_res_ln_wr_rsp_valid:'0;
 assign r_res_ln_wr_rsp_ready=ln_enable?(ln_wr_rsp_ready):(a_res_ln_wr_rsp_ready);
 assign a_res_ln_wr_rsp_tag=r_res_ln_wr_rsp_tag;
 assign r_res_ln_rd_valid=ln_enable?(ln_rd_valid):(a_res_ln_rd_valid);
 assign a_res_ln_rd_ready=(1'b1&&!ln_enable)?r_res_ln_rd_ready:'0;
 assign r_res_ln_rd_mask=ln_enable?(ln_rd_mask):(a_res_ln_rd_mask);
 assign r_res_ln_rd_addr=ln_enable?(ln_rd_addr):(a_res_ln_rd_addr);
 assign r_res_ln_rd_tag=ln_enable?(ln_rd_tag):(a_res_ln_rd_tag);
 assign a_res_ln_rd_rsp_valid=(1'b1&&!ln_enable)?r_res_ln_rd_rsp_valid:'0;
 assign r_res_ln_rd_rsp_ready=ln_enable?(ln_rd_rsp_ready):(a_res_ln_rd_rsp_ready);
 assign a_res_ln_rd_rsp_data=r_res_ln_rd_rsp_data;
 assign a_res_ln_rd_rsp_mask=r_res_ln_rd_rsp_mask;
 assign a_res_ln_rd_rsp_tag=r_res_ln_rd_rsp_tag;
 assign a_res_ln_idle=r_res_ln_idle;
 assign r_res_sfu_lease_valid=a_res_sfu_lease_valid;
 assign a_res_sfu_lease_ready=(1'b1)?r_res_sfu_lease_ready:'0;
 assign r_res_sfu_lease_request_id=a_res_sfu_lease_request_id;
 assign r_res_sfu_lease_generation=a_res_sfu_lease_generation;
 assign r_res_sfu_lease_epoch=a_res_sfu_lease_epoch;
 assign r_res_sfu_lease_head=a_res_sfu_lease_head;
 assign r_res_sfu_lease_phase=a_res_sfu_lease_phase;
 assign r_res_sfu_release_valid=a_res_sfu_release_valid;
 assign r_res_sfu_release_phase=a_res_sfu_release_phase;
 assign r_res_sfu_release_epoch=a_res_sfu_release_epoch;
 assign r_res_sfu_phase_debt_clear=a_res_sfu_phase_debt_clear;
 assign a_res_sfu_lease_active=r_res_sfu_lease_active;
 assign r_res_sfu_context_valid=a_res_sfu_context_valid;
 assign r_res_sfu_context_row_hi=a_res_sfu_context_row_hi;
 assign r_res_sfu_req_valid=a_res_sfu_req_valid;
 assign a_res_sfu_req_ready=(1'b1)?r_res_sfu_req_ready:'0;
 assign r_res_sfu_req_mode=a_res_sfu_req_mode;
 assign r_res_sfu_req_generation=a_res_sfu_req_generation;
 assign r_res_sfu_req_epoch=a_res_sfu_req_epoch;
 assign r_res_sfu_req_phase=a_res_sfu_req_phase;
 assign r_res_sfu_req_tag=a_res_sfu_req_tag;
 assign r_res_sfu_req_x=a_res_sfu_req_x;
 assign a_res_sfu_reject_valid=(1'b1)?r_res_sfu_reject_valid:'0;
 assign a_res_sfu_rsp_valid=(1'b1)?r_res_sfu_rsp_valid:'0;
 assign r_res_sfu_rsp_ready=a_res_sfu_rsp_ready;
 assign a_res_sfu_rsp_tag=r_res_sfu_rsp_tag;
 assign a_res_sfu_rsp_data=r_res_sfu_rsp_data;
 assign a_res_sfu_pending_vectors=r_res_sfu_pending_vectors;
 assign a_res_sfu_in_flight_vectors=r_res_sfu_in_flight_vectors;
 assign a_res_sfu_protocol_fault=r_res_sfu_protocol_fault;
 assign r_res_div_lease_valid=ext_div_select?(ext_allowed?ext_res_div_lease_valid:'0):(ln_enable?(p_div_lease_valid):(a_res_div_lease_valid));
 assign a_res_div_lease_ready=(!ext_div_select&&!ln_enable)?r_res_div_lease_ready:'0;
 assign ext_res_div_lease_ready=ext_allowed&&ext_div_select?r_res_div_lease_ready:'0;
 assign r_res_div_lease_request_id=ext_div_select?(ext_allowed?ext_res_div_lease_request_id:'0):(ln_enable?(p_lease_request_id):(a_res_div_lease_request_id));
 assign r_res_div_lease_generation=ext_div_select?(ext_allowed?ext_res_div_lease_generation:'0):(ln_enable?(p_lease_generation):(a_res_div_lease_generation));
 assign r_res_div_lease_epoch=ext_div_select?(ext_allowed?ext_res_div_lease_epoch:'0):(ln_enable?(p_lease_epoch):(a_res_div_lease_epoch));
 assign r_res_div_lease_head=ext_div_select?(ext_allowed?ext_res_div_lease_head:'0):(ln_enable?(p_lease_head):(a_res_div_lease_head));
 assign r_res_div_lease_phase=ext_div_select?(ext_allowed?ext_res_div_lease_phase:'0):(ln_enable?(p_lease_phase):(a_res_div_lease_phase));
 assign ext_res_div_release_ready=ext_allowed&&ext_div_select?r_res_div_release_ready:'0;
 assign ext_res_div_draining=r_res_div_draining;
 assign ext_res_div_rsp_request_id=r_res_div_rsp_request_id;
 assign ext_res_div_rsp_generation=r_res_div_rsp_generation;
 assign ext_res_div_rsp_epoch=r_res_div_rsp_epoch;
 assign ext_res_div_rsp_head=r_res_div_rsp_head;
 assign ext_res_div_rsp_phase=r_res_div_rsp_phase;
 assign ext_res_div_protocol_reject_code=r_res_div_protocol_reject_code;
 assign ext_res_div_rsp_lane_mask=r_res_div_rsp_lane_mask;
 assign r_res_div_release_valid=ext_div_select?(ext_allowed?ext_res_div_release_valid:'0):(ln_enable?(p_div_release_valid):(a_res_div_release_valid));
 assign r_res_div_release_phase=ext_div_select?(ext_allowed?ext_res_div_release_phase:'0):(ln_enable?(3'd6):(a_res_div_release_phase));
 assign r_res_div_release_epoch=ext_div_select?(ext_allowed?ext_res_div_release_epoch:'0):(ln_enable?(resident_owner_epoch):(a_res_div_release_epoch));
 assign r_res_div_phase_debt_clear=ext_div_select?(ext_allowed?ext_res_div_phase_debt_clear:'0):(ln_enable?(p_phase_debt_clear):(a_res_div_phase_debt_clear));
 assign a_res_div_lease_active=r_res_div_lease_active;
 assign ext_res_div_lease_active=r_res_div_lease_active;
 assign r_res_div_req_valid=ext_div_select?(ext_allowed?ext_res_div_req_valid:'0):(ln_enable?(ln_div_req_valid):(a_res_div_req_valid));
 assign a_res_div_req_ready=(!ext_div_select&&!ln_enable)?r_res_div_req_ready:'0;
 assign ext_res_div_req_ready=ext_allowed&&ext_div_select?r_res_div_req_ready:'0;
 assign r_res_div_req_generation=ext_div_select?(ext_allowed?ext_res_div_req_generation:'0):(ln_enable?(resident_owner_generation):(a_res_div_req_generation));
 assign r_res_div_req_epoch=ext_div_select?(ext_allowed?ext_res_div_req_epoch:'0):(ln_enable?(resident_owner_epoch):(a_res_div_req_epoch));
 assign r_res_div_req_phase=ext_div_select?(ext_allowed?ext_res_div_req_phase:'0):(ln_enable?(3'd6):(a_res_div_req_phase));
 assign r_res_div_req_lane_mask=ext_div_select?(ext_allowed?ext_res_div_req_lane_mask:'0):(ln_enable?(8'b1):(a_res_div_req_lane_mask));
 assign r_res_div_req_tag=ext_div_select?(ext_allowed?ext_res_div_req_tag:'0):(ln_enable?(ln_div_req_tag):(a_res_div_req_tag));
 assign r_res_div_req_a=ext_div_select?(ext_allowed?ext_res_div_req_a:'0):(ln_enable?({224'b0,ln_div_a}):(a_res_div_req_a));
 assign r_res_div_req_b=ext_div_select?(ext_allowed?ext_res_div_req_b:'0):(ln_enable?({224'b0,ln_div_b}):(a_res_div_req_b));
 assign a_res_div_protocol_reject_valid=(!ext_div_select&&!ln_enable)?r_res_div_protocol_reject_valid:'0;
 assign ext_res_div_protocol_reject_valid=ext_allowed&&ext_div_select?r_res_div_protocol_reject_valid:'0;
 assign a_res_div_rsp_valid=(!ext_div_select&&!ln_enable)?r_res_div_rsp_valid:'0;
 assign ext_res_div_rsp_valid=ext_allowed&&ext_div_select?r_res_div_rsp_valid:'0;
 assign r_res_div_rsp_ready=ext_div_select?(ext_allowed?ext_res_div_rsp_ready:'0):(ln_enable?(ln_div_rsp_ready):(a_res_div_rsp_ready));
 assign a_res_div_rsp_tag=r_res_div_rsp_tag;
 assign ext_res_div_rsp_tag=r_res_div_rsp_tag;
 assign a_res_div_rsp_numeric_error=r_res_div_rsp_numeric_error;
 assign ext_res_div_rsp_numeric_error=r_res_div_rsp_numeric_error;
 assign a_res_div_rsp_data=r_res_div_rsp_data;
 assign ext_res_div_rsp_data=r_res_div_rsp_data;
 assign a_res_div_pending_vectors=r_res_div_pending_vectors;
 assign ext_res_div_pending_vectors=r_res_div_pending_vectors;
 assign a_res_div_in_flight_vectors=r_res_div_in_flight_vectors;
 assign ext_res_div_in_flight_vectors=r_res_div_in_flight_vectors;
 assign a_res_div_in_flight_scalars=r_res_div_in_flight_scalars;
 assign ext_res_div_in_flight_scalars=r_res_div_in_flight_scalars;
 assign a_res_div_protocol_fault=r_res_div_protocol_fault;
 assign ext_res_div_protocol_fault=r_res_div_protocol_fault;
 assign r_res_scale_valid=a_res_scale_valid;
 assign a_res_scale_ready=(1'b1)?r_res_scale_ready:'0;
 assign r_res_scale_tag=a_res_scale_tag;
 assign r_res_scale_input=a_res_scale_input;
 assign a_res_scale_rsp_valid=(1'b1)?r_res_scale_rsp_valid:'0;
 assign r_res_scale_rsp_ready=a_res_scale_rsp_ready;
 assign a_res_scale_rsp_tag=r_res_scale_rsp_tag;
 assign a_res_scale_data=r_res_scale_data;
 assign a_res_scale_pending=r_res_scale_pending;
 assign a_res_scale_fault=r_res_scale_fault;
 assign r_rope_owner_valid=a_rope_owner_valid;
 assign r_rope_owner_request_id=a_rope_owner_request_id;
 assign r_rope_owner_generation=a_rope_owner_generation;
 assign r_rope_owner_epoch=a_rope_owner_epoch;
 assign r_rope_wr_valid=a_rope_wr_valid;
 assign a_rope_wr_ready=(1'b1)?r_rope_wr_ready:'0;
 assign r_rope_wr_request_id=a_rope_wr_request_id;
 assign r_rope_wr_generation=a_rope_wr_generation;
 assign r_rope_wr_epoch=a_rope_wr_epoch;
 assign r_rope_wr_head=a_rope_wr_head;
 assign r_rope_wr_token=a_rope_wr_token;
 assign r_rope_wr_tag=a_rope_wr_tag;
 assign r_rope_wr_q=a_rope_wr_q;
 assign r_rope_wr_k=a_rope_wr_k;
 assign a_rope_wr_commit_valid=r_rope_wr_commit_valid;
 assign a_rope_wr_commit_tag=r_rope_wr_commit_tag;
 assign a_rope_reject_valid=(1'b1)?r_rope_reject_valid:'0;
 assign a_rope_reject_code=r_rope_reject_code;
 assign vector_fp_lease_ready=vector_enable&&!ext_fp_select&&r_res_fp_lease_ready;
 assign vector_fp_release_ready=vector_enable&&!ext_fp_select&&r_res_fp_release_ready;
 assign vector_fp_lease_active=r_res_fp_lease_active;
 assign vector_fp_rsp_request_id=r_res_fp_rsp_request_id;
 assign vector_fp_rsp_generation=r_res_fp_rsp_generation;
 assign vector_fp_rsp_epoch=r_res_fp_rsp_epoch;
 assign vector_fp_rsp_head=r_res_fp_rsp_head;
 assign vector_fp_rsp_phase=r_res_fp_rsp_phase;
 assign vector_fp_protocol_fault=r_res_fp_protocol_fault;
 assign vector_add_req_ready=vector_enable&&!ext_fp_select?r_res_fp_add_req_ready:'0;
 assign vector_add_rsp_valid=vector_enable&&!ext_fp_select?r_res_fp_add_rsp_valid:'0;
 assign vector_add_rsp_tag=r_res_fp_add_rsp_tag;
 assign vector_add_rsp_data=r_res_fp_add_rsp_data;
 assign p_fp_lease_ready=ln_enable&&!ext_fp_select&&r_res_fp_lease_ready;
 assign p_fp_release_ready=ln_enable&&!ext_fp_select&&r_res_fp_release_ready;
 assign p_div_lease_ready=ln_enable&&!ext_div_select&&r_res_div_lease_ready;
 assign p_div_release_ready=ln_enable&&!ext_div_select&&r_res_div_release_ready;
 assign p_bank_bind_ready=ln_enable&&1'b1&&r_res_ln_bind_ready;
 assign ln_mul_req_ready=ln_enable&&!ext_fp_select?r_res_fp_mul_req_ready:'0;
 assign ln_mul_rsp_valid=ln_enable&&!ext_fp_select?r_res_fp_mul_rsp_valid:'0;
 assign ln_mul_rsp_tag=r_res_fp_mul_rsp_tag;
 assign ln_mul_rsp_data=r_res_fp_mul_rsp_data;
 assign ln_mul_pending=r_res_fp_mul_pending;
 assign ln_add_req_ready=ln_enable&&!ext_fp_select?r_res_fp_add_req_ready[0]:'0;
 assign ln_add_rsp_valid=ln_enable&&!ext_fp_select?r_res_fp_add_rsp_valid[0]:'0;
 assign ln_add_rsp_tag=r_res_fp_add_rsp_tag[0];
 assign ln_add_rsp_data=r_res_fp_add_rsp_data;
 assign ln_add_pending=r_res_fp_add_pending[0];
 assign ln_div_req_ready=ln_enable&&!ext_div_select?r_res_div_req_ready:'0;
 assign ln_div_rsp_valid=ln_enable&&!ext_div_select?r_res_div_rsp_valid:'0;
 assign ln_div_rsp_tag=r_res_div_rsp_tag;
 assign ln_div_rsp_data=r_res_div_rsp_data[0];
 assign ln_div_rsp_error=r_res_div_rsp_numeric_error[0];
 assign ln_div_pending=r_res_div_pending_vectors;
 assign ln_bank_idle=r_res_ln_idle;
 assign ln_wr_ready=ln_enable?r_res_ln_wr_ready:'0;
 assign ln_wr_rsp_valid=ln_enable?r_res_ln_wr_rsp_valid:'0;
 assign ln_wr_rsp_tag=r_res_ln_wr_rsp_tag;
 assign ln_rd_ready=ln_enable?r_res_ln_rd_ready:'0;
 assign ln_rd_rsp_valid=ln_enable?r_res_ln_rd_rsp_valid:'0;
 assign ln_rd_rsp_data=r_res_ln_rd_rsp_data;
 assign ln_rd_rsp_tag=r_res_ln_rd_rsp_tag;
 assign g_g_wr_ready=g_enable?r_res_st_g_wr_ready:'0;
 assign g_g_wr_rsp_valid=g_enable?r_res_st_g_wr_rsp_valid:'0;
 assign g_g_wr_rsp_tag=r_res_st_g_wr_rsp_tag;
 assign g_g_rd_ready=g_enable?r_res_st_g_rd_ready:'0;
 assign g_g_rd_rsp_valid=g_enable?r_res_st_g_rd_rsp_valid:'0;
 assign g_g_rd_rsp_data=r_res_st_g_rd_rsp_data;
 assign g_g_rd_rsp_mask=r_res_st_g_rd_rsp_mask;
 assign g_g_rd_rsp_tag=r_res_st_g_rd_rsp_tag;
 assign cfg_bind_valid=a_enable&&a_layer_idle&&scratch_normal_enable&&coeff_bind_valid;
 assign coeff_bind_ready=a_enable&&a_layer_idle&&scratch_normal_enable&&cfg_bind_ready;
 assign cfg_wr_valid=a_enable&&a_layer_idle&&scratch_normal_enable&&coeff_wr_valid;
 assign coeff_wr_ready=a_enable&&a_layer_idle&&scratch_normal_enable&&cfg_wr_ready;
 assign a_cache_bound_valid=coeff_bound_valid;
 assign a_cache_bound_model_id=coeff_bound_model_id;
 assign a_cache_bound_numeric_id=coeff_bound_numeric_id;
 assign a_cache_bound_table_key=coeff_bound_table_key;
 assign a_cache_family_complete=coeff_family_complete;
 laya_rope_coeff_cache_v1 coeff(
 .clk(clk),
 .rst_n(rst_n),
 .bind_valid(cfg_bind_valid),
 .bind_ready(cfg_bind_ready),
 .bind_model_id(coeff_bind_model_id),
 .bind_numeric_id(coeff_bind_numeric_id),
 .bind_table_key(coeff_bind_table_key),
 .bound_valid(coeff_bound_valid),
 .bound_model_id(coeff_bound_model_id),
 .bound_numeric_id(coeff_bound_numeric_id),
 .bound_table_key(coeff_bound_table_key),
 .family_complete(coeff_family_complete),
 .wr_valid(cfg_wr_valid),
 .wr_ready(cfg_wr_ready),
 .wr_model_id(coeff_wr_model_id),
 .wr_numeric_id(coeff_wr_numeric_id),
 .wr_table_key(coeff_wr_table_key),
 .wr_table(coeff_wr_table),
 .wr_row(coeff_wr_row),
 .wr_half(coeff_wr_half),
 .wr_data(coeff_wr_data),
 .wr_reject_valid(coeff_wr_reject_valid),
 .wr_reject_code(coeff_wr_reject_code),
 .wr_nonfinite_lane(coeff_wr_nonfinite_lane),
 .owner_valid(a_cache_owner_valid),
 .owner_request_id(a_cache_owner_request_id),
 .owner_generation(a_cache_owner_generation),
 .owner_epoch(a_cache_owner_epoch),
 .rd_valid(a_cache_rd_valid),
 .rd_ready(a_cache_rd_ready),
 .rd_family(a_cache_rd_family),
 .rd_row(a_cache_rd_row),
 .rd_tag(a_cache_rd_tag),
 .rd_request_id(a_cache_rd_request_id),
 .rd_generation(a_cache_rd_generation),
 .rd_epoch(a_cache_rd_epoch),
 .rd_reject_valid(a_cache_rd_reject_valid),
 .rd_reject_code(a_cache_rd_reject_code),
 .rsp_valid(a_cache_rsp_valid),
 .rsp_ready(a_cache_rsp_ready),
 .rsp_family(a_cache_rsp_family),
 .rsp_row(a_cache_rsp_row),
 .rsp_tag(a_cache_rsp_tag),
 .rsp_data(a_cache_rsp_data)
 );
 assign shared_resources_idle=!r_res_fp_lease_active&&!r_res_fp_draining&&r_res_fp_mul_pending==0&&r_res_fp_add_pending==0&&!r_res_div_lease_active&&!r_res_div_draining&&r_res_div_pending_vectors==0&&r_res_div_in_flight_vectors==0&&r_res_div_in_flight_scalars==0&&!r_res_sfu_lease_active&&r_res_sfu_pending_vectors==0&&r_res_sfu_in_flight_vectors==0&&r_res_scale_pending==0&&r_res_st_idle&&r_res_ln_idle&&!g_tanh_lease_active&&g_tanh_pending_vectors==0&&g_tanh_in_flight_vectors==0;
 wire external_new_work=ext_res_fp_lease_valid||ext_res_fp_mul_req_valid||(|ext_res_fp_add_req_valid)||ext_res_div_lease_valid||ext_res_div_req_valid||ext_res_st_bind_valid||ext_res_st_ps_wr_valid||ext_res_st_ps_rd_valid||ext_res_st_context_wr_valid||ext_res_st_context_rd_valid;
 wire resident_new_work=h_wr_valid||h_rd_valid||q_wr_valid||q_rd_valid||scratch_lease_valid||coeff_bind_valid||coeff_wr_valid;
 assign outer_admission_quiet[0]=!external_new_work&&!resident_new_work&&!a_prepare_valid&&!a_qkv_wr_valid&&!a_start_valid&&!a_result_rd_valid;
 assign outer_admission_quiet[1]=!external_new_work&&!resident_new_work&&!g_tanh_lease_valid&&!g_cmd_valid&&!g_fill_valid;
 assign outer_admission_quiet[2]=!resident_new_work&&!resident_ln_start_valid;
 assign outer_admission_quiet[3]=!resident_new_work&&!vector_start_valid;
 laya_m007_control_workspace_joint_v2 joint(
 .clk(clk),
 .rst_n(rst_n),
 .owner_req_valid(owner_req_valid),
 .owner_req(owner_req),
 .owner_req_ready(owner_req_ready),
 .owner(owner),
 .rearm(rearm),
 .a_enable(a_enable),
 .g_enable(g_enable),
 .ln_enable(ln_enable),
 .vector_enable(vector_enable),
 .shared_resources_idle(shared_resources_idle),
 .resident_bank_idle(resident_bank_idle),
 .ln_provider_idle(ln_provider_idle),
 .outer_admission_quiet(outer_admission_quiet),
 .a_prepare_valid(j_a_prepare_valid),
 .a_prepare_ready(j_a_prepare_ready),
 .a_prepare_request_id(a_prepare_request_id),
 .a_prepare_model_id(a_prepare_model_id),
 .a_prepare_generation(a_prepare_generation),
 .a_prepare_epoch(a_prepare_epoch),
 .a_prepare_numeric_id(a_prepare_numeric_id),
 .a_prepare_table_key(a_prepare_table_key),
 .a_prepare_kind(a_prepare_kind),
 .a_prepare_layer(a_prepare_layer),
 .a_prepare_mask(a_prepare_mask),
 .a_qkv_wr_valid(j_a_qkv_wr_valid),
 .a_qkv_wr_ready(j_a_qkv_wr_ready),
 .a_qkv_wr_request_id(a_qkv_wr_request_id),
 .a_qkv_wr_generation(a_qkv_wr_generation),
 .a_qkv_wr_epoch(a_qkv_wr_epoch),
 .a_qkv_wr_plane(a_qkv_wr_plane),
 .a_qkv_wr_head(a_qkv_wr_head),
 .a_qkv_wr_token(a_qkv_wr_token),
 .a_qkv_wr_half(a_qkv_wr_half),
 .a_qkv_wr_data(a_qkv_wr_data),
 .a_start_valid(j_a_start_valid),
 .a_start_ready(j_a_start_ready),
 .a_start_request_id(a_start_request_id),
 .a_start_generation(a_start_generation),
 .a_reject_valid(a_reject_valid),
 .a_reject_code(a_reject_code),
 .a_abort_valid(a_abort_valid),
 .a_abort_ready(a_abort_ready),
 .a_qkv_read_grant(a_qkv_read_grant),
 .a_ps_grant(a_ps_grant),
 .a_g_grant(a_g_grant),
 .a_context_grant(a_context_grant),
 .a_fp_grant(a_fp_grant),
 .a_sfu_grant(a_sfu_grant),
 .a_exp_grant(a_exp_grant),
 .a_div_grant(a_div_grant),
 .a_rope_write_grant(a_rope_write_grant),
 .a_done_valid(a_done_valid),
 .a_done_ready(a_done_ready),
 .a_done_request_id(a_done_request_id),
 .a_done_generation(a_done_generation),
 .a_done_status(a_done_status),
 .a_done_cycles(a_done_cycles),
 .a_rope_cycles(a_rope_cycles),
 .a_head_completed(a_head_completed),
 .a_head_context_valid(a_head_context_valid),
 .a_active_head(a_active_head),
 .a_error_valid(a_error_valid),
 .a_error_tuple(a_error_tuple),
 .a_check_completed(a_check_completed),
 .a_check_unreachable(a_check_unreachable),
 .a_check_dominated(a_check_dominated),
 .a_av_check_completed(a_av_check_completed),
 .a_av_check_unreachable(a_av_check_unreachable),
 .a_av_check_dominated(a_av_check_dominated),
 .a_result_rd_valid(j_a_result_rd_valid),
 .a_result_rd_ready(j_a_result_rd_ready),
 .a_result_rd_generation(a_result_rd_generation),
 .a_result_rd_tag(a_result_rd_tag),
 .a_result_rd_head(a_result_rd_head),
 .a_result_rd_query(a_result_rd_query),
 .a_result_rd_half(a_result_rd_half),
 .a_result_rsp_valid(a_result_rsp_valid),
 .a_result_rsp_ready(a_result_rsp_ready),
 .a_result_rsp_tag(a_result_rsp_tag),
 .a_result_rsp_data(a_result_rsp_data),
 .a_result_discard_valid(a_result_discard_valid),
 .a_result_discard_ready(a_result_discard_ready),
 .a_result_discard_generation(a_result_discard_generation),
 .a_context_discarded(a_context_discarded),
 .a_producer_done_cycles(a_producer_done_cycles),
 .a_context_release_cycles(a_context_release_cycles),
 .a_prepare_cancel_valid(a_prepare_cancel_valid),
 .a_prepare_cancel_ready(a_prepare_cancel_ready),
 .a_prepare_cancel_request_id(a_prepare_cancel_request_id),
 .a_prepare_cancel_generation(a_prepare_cancel_generation),
 .a_prepare_cancel_epoch(a_prepare_cancel_epoch),
 .a_prepare_cancel_rsp_valid(a_prepare_cancel_rsp_valid),
 .a_prepare_cancel_rsp_ready(a_prepare_cancel_rsp_ready),
 .a_prepare_cancel_rsp_request_id(a_prepare_cancel_rsp_request_id),
 .a_prepare_cancel_rsp_generation(a_prepare_cancel_rsp_generation),
 .a_prepare_cancel_rsp_epoch(a_prepare_cancel_rsp_epoch),
 .a_prepare_cancel_rsp_status(a_prepare_cancel_rsp_status),
 .a_layer_idle(a_layer_idle),
 .a_check_coverage_fault(a_check_coverage_fault),
 .a_check_first_conflict(a_check_first_conflict),
 .a_res_qkv_wr_valid(a_res_qkv_wr_valid),
 .a_res_qkv_wr_ready(a_res_qkv_wr_ready),
 .a_res_qkv_wr_plane(a_res_qkv_wr_plane),
 .a_res_qkv_wr_head(a_res_qkv_wr_head),
 .a_res_qkv_wr_token(a_res_qkv_wr_token),
 .a_res_qkv_wr_half(a_res_qkv_wr_half),
 .a_res_qkv_wr_data(a_res_qkv_wr_data),
 .a_res_qkv_rd_valid(a_res_qkv_rd_valid),
 .a_res_qkv_rd_ready(a_res_qkv_rd_ready),
 .a_res_qkv_rd_head(a_res_qkv_rd_head),
 .a_res_qkv_rd_token(a_res_qkv_rd_token),
 .a_res_qkv_rd_tag(a_res_qkv_rd_tag),
 .a_res_qkv_rd_rsp_valid(a_res_qkv_rd_rsp_valid),
 .a_res_qkv_rd_rsp_ready(a_res_qkv_rd_rsp_ready),
 .a_res_qkv_rd_rsp_head(a_res_qkv_rd_rsp_head),
 .a_res_qkv_rd_rsp_token(a_res_qkv_rd_rsp_token),
 .a_res_qkv_rd_rsp_tag(a_res_qkv_rd_rsp_tag),
 .a_res_qkv_rd_rsp_data(a_res_qkv_rd_rsp_data),
 .a_res_st_bind_valid(a_res_st_bind_valid),
 .a_res_st_bind_ready(a_res_st_bind_ready),
 .a_res_st_bind_request_id(a_res_st_bind_request_id),
 .a_res_st_bind_generation(a_res_st_bind_generation),
 .a_res_st_bind_epoch(a_res_st_bind_epoch),
 .a_res_st_bind_head(a_res_st_bind_head),
 .a_res_st_bind_phase(a_res_st_bind_phase),
 .a_res_st_op_request_id(a_res_st_op_request_id),
 .a_res_st_op_generation(a_res_st_op_generation),
 .a_res_st_op_epoch(a_res_st_op_epoch),
 .a_res_st_op_phase(a_res_st_op_phase),
 .a_res_st_rsp_request_id(a_res_st_rsp_request_id),
 .a_res_st_rsp_generation(a_res_st_rsp_generation),
 .a_res_st_rsp_epoch(a_res_st_rsp_epoch),
 .a_res_st_rsp_head(a_res_st_rsp_head),
 .a_res_st_rsp_phase(a_res_st_rsp_phase),
 .a_res_st_ps_wr_valid(a_res_st_ps_wr_valid),
 .a_res_st_ps_wr_ready(a_res_st_ps_wr_ready),
 .a_res_st_ps_wr_mask(a_res_st_ps_wr_mask),
 .a_res_st_ps_wr_addr(a_res_st_ps_wr_addr),
 .a_res_st_ps_wr_data(a_res_st_ps_wr_data),
 .a_res_st_ps_wr_tag(a_res_st_ps_wr_tag),
 .a_res_st_ps_wr_rsp_valid(a_res_st_ps_wr_rsp_valid),
 .a_res_st_ps_wr_rsp_ready(a_res_st_ps_wr_rsp_ready),
 .a_res_st_ps_wr_rsp_tag(a_res_st_ps_wr_rsp_tag),
 .a_res_st_ps_rd_valid(a_res_st_ps_rd_valid),
 .a_res_st_ps_rd_ready(a_res_st_ps_rd_ready),
 .a_res_st_ps_rd_mask(a_res_st_ps_rd_mask),
 .a_res_st_ps_rd_addr(a_res_st_ps_rd_addr),
 .a_res_st_ps_rd_tag(a_res_st_ps_rd_tag),
 .a_res_st_ps_rd_rsp_valid(a_res_st_ps_rd_rsp_valid),
 .a_res_st_ps_rd_rsp_ready(a_res_st_ps_rd_rsp_ready),
 .a_res_st_ps_rd_rsp_data(a_res_st_ps_rd_rsp_data),
 .a_res_st_ps_rd_rsp_mask(a_res_st_ps_rd_rsp_mask),
 .a_res_st_ps_rd_rsp_tag(a_res_st_ps_rd_rsp_tag),
 .a_res_st_g_wr_valid(a_res_st_g_wr_valid),
 .a_res_st_g_wr_ready(a_res_st_g_wr_ready),
 .a_res_st_g_wr_mask(a_res_st_g_wr_mask),
 .a_res_st_g_wr_addr(a_res_st_g_wr_addr),
 .a_res_st_g_wr_data(a_res_st_g_wr_data),
 .a_res_st_g_wr_tag(a_res_st_g_wr_tag),
 .a_res_st_g_wr_rsp_valid(a_res_st_g_wr_rsp_valid),
 .a_res_st_g_wr_rsp_ready(a_res_st_g_wr_rsp_ready),
 .a_res_st_g_wr_rsp_tag(a_res_st_g_wr_rsp_tag),
 .a_res_st_g_rd_valid(a_res_st_g_rd_valid),
 .a_res_st_g_rd_ready(a_res_st_g_rd_ready),
 .a_res_st_g_rd_mask(a_res_st_g_rd_mask),
 .a_res_st_g_rd_addr(a_res_st_g_rd_addr),
 .a_res_st_g_rd_tag(a_res_st_g_rd_tag),
 .a_res_st_g_rd_rsp_valid(a_res_st_g_rd_rsp_valid),
 .a_res_st_g_rd_rsp_ready(a_res_st_g_rd_rsp_ready),
 .a_res_st_g_rd_rsp_data(a_res_st_g_rd_rsp_data),
 .a_res_st_g_rd_rsp_mask(a_res_st_g_rd_rsp_mask),
 .a_res_st_g_rd_rsp_tag(a_res_st_g_rd_rsp_tag),
 .a_res_st_context_wr_valid(a_res_st_context_wr_valid),
 .a_res_st_context_wr_ready(a_res_st_context_wr_ready),
 .a_res_st_context_wr_mask(a_res_st_context_wr_mask),
 .a_res_st_context_wr_addr(a_res_st_context_wr_addr),
 .a_res_st_context_wr_data(a_res_st_context_wr_data),
 .a_res_st_context_wr_tag(a_res_st_context_wr_tag),
 .a_res_st_context_wr_rsp_valid(a_res_st_context_wr_rsp_valid),
 .a_res_st_context_wr_rsp_ready(a_res_st_context_wr_rsp_ready),
 .a_res_st_context_wr_rsp_tag(a_res_st_context_wr_rsp_tag),
 .a_res_st_context_rd_valid(a_res_st_context_rd_valid),
 .a_res_st_context_rd_ready(a_res_st_context_rd_ready),
 .a_res_st_context_rd_mask(a_res_st_context_rd_mask),
 .a_res_st_context_rd_addr(a_res_st_context_rd_addr),
 .a_res_st_context_rd_tag(a_res_st_context_rd_tag),
 .a_res_st_context_rd_rsp_valid(a_res_st_context_rd_rsp_valid),
 .a_res_st_context_rd_rsp_ready(a_res_st_context_rd_rsp_ready),
 .a_res_st_context_rd_rsp_data(a_res_st_context_rd_rsp_data),
 .a_res_st_context_rd_rsp_mask(a_res_st_context_rd_rsp_mask),
 .a_res_st_context_rd_rsp_tag(a_res_st_context_rd_rsp_tag),
 .a_res_st_idle(a_res_st_idle),
 .a_res_fp_lease_valid(a_res_fp_lease_valid),
 .a_res_fp_lease_ready(a_res_fp_lease_ready),
 .a_res_fp_lease_request_id(a_res_fp_lease_request_id),
 .a_res_fp_lease_generation(a_res_fp_lease_generation),
 .a_res_fp_lease_epoch(a_res_fp_lease_epoch),
 .a_res_fp_lease_head(a_res_fp_lease_head),
 .a_res_fp_lease_phase(a_res_fp_lease_phase),
 .a_res_fp_release_valid(a_res_fp_release_valid),
 .a_res_fp_release_ready(a_res_fp_release_ready),
 .a_res_fp_release_phase(a_res_fp_release_phase),
 .a_res_fp_release_epoch(a_res_fp_release_epoch),
 .a_res_fp_phase_debt_clear(a_res_fp_phase_debt_clear),
 .a_res_fp_lease_active(a_res_fp_lease_active),
 .a_res_fp_draining(a_res_fp_draining),
 .a_res_fp_rsp_request_id(a_res_fp_rsp_request_id),
 .a_res_fp_rsp_generation(a_res_fp_rsp_generation),
 .a_res_fp_rsp_epoch(a_res_fp_rsp_epoch),
 .a_res_fp_rsp_head(a_res_fp_rsp_head),
 .a_res_fp_rsp_phase(a_res_fp_rsp_phase),
 .a_res_fp_mul_req_valid(a_res_fp_mul_req_valid),
 .a_res_fp_mul_req_ready(a_res_fp_mul_req_ready),
 .a_res_fp_mul_req_phase(a_res_fp_mul_req_phase),
 .a_res_fp_mul_req_epoch(a_res_fp_mul_req_epoch),
 .a_res_fp_mul_req_tag(a_res_fp_mul_req_tag),
 .a_res_fp_mul_a(a_res_fp_mul_a),
 .a_res_fp_mul_b(a_res_fp_mul_b),
 .a_res_fp_mul_rsp_valid(a_res_fp_mul_rsp_valid),
 .a_res_fp_mul_rsp_ready(a_res_fp_mul_rsp_ready),
 .a_res_fp_mul_rsp_tag(a_res_fp_mul_rsp_tag),
 .a_res_fp_mul_rsp_data(a_res_fp_mul_rsp_data),
 .a_res_fp_add_req_valid(a_res_fp_add_req_valid),
 .a_res_fp_add_req_is_root(a_res_fp_add_req_is_root),
 .a_res_fp_add_req_ready(a_res_fp_add_req_ready),
 .a_res_fp_add_req_phase(a_res_fp_add_req_phase),
 .a_res_fp_add_req_epoch(a_res_fp_add_req_epoch),
 .a_res_fp_add_req_tag(a_res_fp_add_req_tag),
 .a_res_fp_add_a(a_res_fp_add_a),
 .a_res_fp_add_b(a_res_fp_add_b),
 .a_res_fp_add_rsp_valid(a_res_fp_add_rsp_valid),
 .a_res_fp_add_rsp_ready(a_res_fp_add_rsp_ready),
 .a_res_fp_add_rsp_tag(a_res_fp_add_rsp_tag),
 .a_res_fp_add_rsp_data(a_res_fp_add_rsp_data),
 .a_res_fp_mul_pending(a_res_fp_mul_pending),
 .a_res_fp_add_pending(a_res_fp_add_pending),
 .a_res_fp_protocol_fault(a_res_fp_protocol_fault),
 .a_res_ln_bind_valid(a_res_ln_bind_valid),
 .a_res_ln_bind_ready(a_res_ln_bind_ready),
 .a_res_ln_bind_request_id(a_res_ln_bind_request_id),
 .a_res_ln_bind_generation(a_res_ln_bind_generation),
 .a_res_ln_bind_epoch(a_res_ln_bind_epoch),
 .a_res_ln_bind_head(a_res_ln_bind_head),
 .a_res_ln_bind_phase(a_res_ln_bind_phase),
 .a_res_ln_op_request_id(a_res_ln_op_request_id),
 .a_res_ln_op_generation(a_res_ln_op_generation),
 .a_res_ln_op_epoch(a_res_ln_op_epoch),
 .a_res_ln_op_phase(a_res_ln_op_phase),
 .a_res_ln_rsp_request_id(a_res_ln_rsp_request_id),
 .a_res_ln_rsp_generation(a_res_ln_rsp_generation),
 .a_res_ln_rsp_epoch(a_res_ln_rsp_epoch),
 .a_res_ln_rsp_head(a_res_ln_rsp_head),
 .a_res_ln_rsp_phase(a_res_ln_rsp_phase),
 .a_res_ln_wr_valid(a_res_ln_wr_valid),
 .a_res_ln_wr_ready(a_res_ln_wr_ready),
 .a_res_ln_wr_mask(a_res_ln_wr_mask),
 .a_res_ln_wr_addr(a_res_ln_wr_addr),
 .a_res_ln_wr_data(a_res_ln_wr_data),
 .a_res_ln_wr_tag(a_res_ln_wr_tag),
 .a_res_ln_wr_rsp_valid(a_res_ln_wr_rsp_valid),
 .a_res_ln_wr_rsp_ready(a_res_ln_wr_rsp_ready),
 .a_res_ln_wr_rsp_tag(a_res_ln_wr_rsp_tag),
 .a_res_ln_rd_valid(a_res_ln_rd_valid),
 .a_res_ln_rd_ready(a_res_ln_rd_ready),
 .a_res_ln_rd_mask(a_res_ln_rd_mask),
 .a_res_ln_rd_addr(a_res_ln_rd_addr),
 .a_res_ln_rd_tag(a_res_ln_rd_tag),
 .a_res_ln_rd_rsp_valid(a_res_ln_rd_rsp_valid),
 .a_res_ln_rd_rsp_ready(a_res_ln_rd_rsp_ready),
 .a_res_ln_rd_rsp_data(a_res_ln_rd_rsp_data),
 .a_res_ln_rd_rsp_mask(a_res_ln_rd_rsp_mask),
 .a_res_ln_rd_rsp_tag(a_res_ln_rd_rsp_tag),
 .a_res_ln_idle(a_res_ln_idle),
 .a_res_sfu_lease_valid(a_res_sfu_lease_valid),
 .a_res_sfu_lease_ready(a_res_sfu_lease_ready),
 .a_res_sfu_lease_request_id(a_res_sfu_lease_request_id),
 .a_res_sfu_lease_generation(a_res_sfu_lease_generation),
 .a_res_sfu_lease_epoch(a_res_sfu_lease_epoch),
 .a_res_sfu_lease_head(a_res_sfu_lease_head),
 .a_res_sfu_lease_phase(a_res_sfu_lease_phase),
 .a_res_sfu_release_valid(a_res_sfu_release_valid),
 .a_res_sfu_release_phase(a_res_sfu_release_phase),
 .a_res_sfu_release_epoch(a_res_sfu_release_epoch),
 .a_res_sfu_phase_debt_clear(a_res_sfu_phase_debt_clear),
 .a_res_sfu_lease_active(a_res_sfu_lease_active),
 .a_res_sfu_context_valid(a_res_sfu_context_valid),
 .a_res_sfu_context_row_hi(a_res_sfu_context_row_hi),
 .a_res_sfu_req_valid(a_res_sfu_req_valid),
 .a_res_sfu_req_ready(a_res_sfu_req_ready),
 .a_res_sfu_req_mode(a_res_sfu_req_mode),
 .a_res_sfu_req_generation(a_res_sfu_req_generation),
 .a_res_sfu_req_epoch(a_res_sfu_req_epoch),
 .a_res_sfu_req_phase(a_res_sfu_req_phase),
 .a_res_sfu_req_tag(a_res_sfu_req_tag),
 .a_res_sfu_req_x(a_res_sfu_req_x),
 .a_res_sfu_reject_valid(a_res_sfu_reject_valid),
 .a_res_sfu_rsp_valid(a_res_sfu_rsp_valid),
 .a_res_sfu_rsp_ready(a_res_sfu_rsp_ready),
 .a_res_sfu_rsp_tag(a_res_sfu_rsp_tag),
 .a_res_sfu_rsp_data(a_res_sfu_rsp_data),
 .a_res_sfu_pending_vectors(a_res_sfu_pending_vectors),
 .a_res_sfu_in_flight_vectors(a_res_sfu_in_flight_vectors),
 .a_res_sfu_protocol_fault(a_res_sfu_protocol_fault),
 .a_res_div_lease_valid(a_res_div_lease_valid),
 .a_res_div_lease_ready(a_res_div_lease_ready),
 .a_res_div_lease_request_id(a_res_div_lease_request_id),
 .a_res_div_lease_generation(a_res_div_lease_generation),
 .a_res_div_lease_epoch(a_res_div_lease_epoch),
 .a_res_div_lease_head(a_res_div_lease_head),
 .a_res_div_lease_phase(a_res_div_lease_phase),
 .a_res_div_release_valid(a_res_div_release_valid),
 .a_res_div_release_phase(a_res_div_release_phase),
 .a_res_div_release_epoch(a_res_div_release_epoch),
 .a_res_div_phase_debt_clear(a_res_div_phase_debt_clear),
 .a_res_div_lease_active(a_res_div_lease_active),
 .a_res_div_req_valid(a_res_div_req_valid),
 .a_res_div_req_ready(a_res_div_req_ready),
 .a_res_div_req_generation(a_res_div_req_generation),
 .a_res_div_req_epoch(a_res_div_req_epoch),
 .a_res_div_req_phase(a_res_div_req_phase),
 .a_res_div_req_lane_mask(a_res_div_req_lane_mask),
 .a_res_div_req_tag(a_res_div_req_tag),
 .a_res_div_req_a(a_res_div_req_a),
 .a_res_div_req_b(a_res_div_req_b),
 .a_res_div_protocol_reject_valid(a_res_div_protocol_reject_valid),
 .a_res_div_rsp_valid(a_res_div_rsp_valid),
 .a_res_div_rsp_ready(a_res_div_rsp_ready),
 .a_res_div_rsp_tag(a_res_div_rsp_tag),
 .a_res_div_rsp_numeric_error(a_res_div_rsp_numeric_error),
 .a_res_div_rsp_data(a_res_div_rsp_data),
 .a_res_div_pending_vectors(a_res_div_pending_vectors),
 .a_res_div_in_flight_vectors(a_res_div_in_flight_vectors),
 .a_res_div_in_flight_scalars(a_res_div_in_flight_scalars),
 .a_res_div_protocol_fault(a_res_div_protocol_fault),
 .a_res_scale_valid(a_res_scale_valid),
 .a_res_scale_ready(a_res_scale_ready),
 .a_res_scale_tag(a_res_scale_tag),
 .a_res_scale_input(a_res_scale_input),
 .a_res_scale_rsp_valid(a_res_scale_rsp_valid),
 .a_res_scale_rsp_ready(a_res_scale_rsp_ready),
 .a_res_scale_rsp_tag(a_res_scale_rsp_tag),
 .a_res_scale_data(a_res_scale_data),
 .a_res_scale_pending(a_res_scale_pending),
 .a_res_scale_fault(a_res_scale_fault),
 .a_rope_owner_valid(a_rope_owner_valid),
 .a_rope_owner_request_id(a_rope_owner_request_id),
 .a_rope_owner_generation(a_rope_owner_generation),
 .a_rope_owner_epoch(a_rope_owner_epoch),
 .a_rope_wr_valid(a_rope_wr_valid),
 .a_rope_wr_ready(a_rope_wr_ready),
 .a_rope_wr_request_id(a_rope_wr_request_id),
 .a_rope_wr_generation(a_rope_wr_generation),
 .a_rope_wr_epoch(a_rope_wr_epoch),
 .a_rope_wr_head(a_rope_wr_head),
 .a_rope_wr_token(a_rope_wr_token),
 .a_rope_wr_tag(a_rope_wr_tag),
 .a_rope_wr_q(a_rope_wr_q),
 .a_rope_wr_k(a_rope_wr_k),
 .a_rope_wr_commit_valid(a_rope_wr_commit_valid),
 .a_rope_wr_commit_tag(a_rope_wr_commit_tag),
 .a_rope_reject_valid(a_rope_reject_valid),
 .a_rope_reject_code(a_rope_reject_code),
 .a_cache_bound_valid(a_cache_bound_valid),
 .a_cache_bound_model_id(a_cache_bound_model_id),
 .a_cache_bound_numeric_id(a_cache_bound_numeric_id),
 .a_cache_bound_table_key(a_cache_bound_table_key),
 .a_cache_family_complete(a_cache_family_complete),
 .a_cache_owner_valid(a_cache_owner_valid),
 .a_cache_owner_request_id(a_cache_owner_request_id),
 .a_cache_owner_generation(a_cache_owner_generation),
 .a_cache_owner_epoch(a_cache_owner_epoch),
 .a_cache_rd_valid(a_cache_rd_valid),
 .a_cache_rd_ready(a_cache_rd_ready),
 .a_cache_rd_family(a_cache_rd_family),
 .a_cache_rd_row(a_cache_rd_row),
 .a_cache_rd_tag(a_cache_rd_tag),
 .a_cache_rd_request_id(a_cache_rd_request_id),
 .a_cache_rd_generation(a_cache_rd_generation),
 .a_cache_rd_epoch(a_cache_rd_epoch),
 .a_cache_rd_reject_valid(a_cache_rd_reject_valid),
 .a_cache_rd_reject_code(a_cache_rd_reject_code),
 .a_cache_rsp_valid(a_cache_rsp_valid),
 .a_cache_rsp_ready(a_cache_rsp_ready),
 .a_cache_rsp_family(a_cache_rsp_family),
 .a_cache_rsp_row(a_cache_rsp_row),
 .a_cache_rsp_tag(a_cache_rsp_tag),
 .a_cache_rsp_data(a_cache_rsp_data),
 .g_producer_cancel_valid(g_producer_cancel_valid),
 .g_producer_cancel_ready(g_producer_cancel_ready),
 .g_producer_cancel_request_id(g_producer_cancel_request_id),
 .g_producer_cancel_generation(g_producer_cancel_generation),
 .g_producer_cancel_epoch(g_producer_cancel_epoch),
 .g_producer_cancel_reject_valid(g_producer_cancel_reject_valid),
 .g_cmd_valid(g_cmd_valid),
 .g_cmd_ready(g_cmd_ready),
 .g_cmd_request_id(g_cmd_request_id),
 .g_cmd_generation(g_cmd_generation),
 .g_cmd_epoch(g_cmd_epoch),
 .g_storage_owner_valid(g_storage_owner_valid),
 .g_storage_owner_request_id(g_storage_owner_request_id),
 .g_storage_owner_generation(g_storage_owner_generation),
 .g_storage_owner_epoch(g_storage_owner_epoch),
 .g_storage_owner_phase(g_storage_owner_phase),
 .g_sfu_owner_valid(g_sfu_owner_valid),
 .g_sfu_owner_request_id(g_sfu_owner_request_id),
 .g_sfu_owner_generation(g_sfu_owner_generation),
 .g_sfu_owner_epoch(g_sfu_owner_epoch),
 .g_sfu_owner_phase(g_sfu_owner_phase),
 .g_fill_valid(g_fill_valid),
 .g_fill_ready(g_fill_ready),
 .g_fill_request_id(g_fill_request_id),
 .g_fill_generation(g_fill_generation),
 .g_fill_epoch(g_fill_epoch),
 .g_fill_slot(g_fill_slot),
 .g_fill_half(g_fill_half),
 .g_fill_s(g_fill_s),
 .g_fill_row(g_fill_row),
 .g_fill_data(g_fill_data),
 .g_fill_reject_valid(g_fill_reject_valid),
 .g_fill_reject_code(g_fill_reject_code),
 .g_out_valid(g_out_valid),
 .g_out_ready(g_out_ready),
 .g_out_data(g_out_data),
 .g_out_status(g_out_status),
 .g_out_tag(g_out_tag),
 .g_out_s(g_out_s),
 .g_out_row(g_out_row),
 .g_out_chunk(g_out_chunk),
 .g_done_valid(g_done_valid),
 .g_done_ready(g_done_ready),
 .g_done_cancelled(g_done_cancelled),
 .g_done_status(g_done_status),
 .g_done_error_rank(g_done_error_rank),
 .g_done_error_row(g_done_error_row),
 .g_done_error_column(g_done_error_column),
 .g_rsp_request_id(g_rsp_request_id),
 .g_rsp_generation(g_rsp_generation),
 .g_rsp_epoch(g_rsp_epoch),
 .g_discard_valid(g_discard_valid),
 .g_discard_ready(g_discard_ready),
 .g_discard_request_id(g_discard_request_id),
 .g_discard_generation(g_discard_generation),
 .g_discard_epoch(g_discard_epoch),
 .g_discard_reject_valid(g_discard_reject_valid),
 .g_engine_idle(g_engine_idle),
 .g_active(g_active),
 .g_needs_discard(g_needs_discard),
 .g_protocol_fault(g_protocol_fault),
 .g_slot_active(g_slot_active),
 .g_slot_ready(g_slot_ready),
 .g_slot_s(g_slot_s),
 .g_slot_consumed_vectors(g_slot_consumed_vectors),
 .g_slot_math_pending(g_slot_math_pending),
 .g_slot_sfu_debt(g_slot_sfu_debt),
 .g_slot_fp_debt(g_slot_fp_debt),
 .g_covered(g_covered),
 .g_evaluated(g_evaluated),
 .g_pool_reset_n(g_pool_reset_n),
 .g_fp_req_valid(g_fp_req_valid),
 .g_fp_req_ready(g_fp_req_ready),
 .g_fp_req_tag(g_fp_req_tag),
 .g_fp_req_a(g_fp_req_a),
 .g_fp_req_b(g_fp_req_b),
 .g_fp_rsp_valid(g_fp_rsp_valid),
 .g_fp_rsp_tag(g_fp_rsp_tag),
 .g_fp_rsp_data(g_fp_rsp_data),
 .g_fp_rsp_status(g_fp_rsp_status),
 .g_fp_pool_fault(g_fp_pool_fault),
 .g_sfu_req_valid(g_sfu_req_valid),
 .g_sfu_req_ready(g_sfu_req_ready),
 .g_sfu_req_tag(g_sfu_req_tag),
 .g_sfu_req_mask(g_sfu_req_mask),
 .g_sfu_req_x(g_sfu_req_x),
 .g_sfu_rsp_valid(g_sfu_rsp_valid),
 .g_sfu_rsp_ready(g_sfu_rsp_ready),
 .g_sfu_rsp_tag(g_sfu_rsp_tag),
 .g_sfu_rsp_data(g_sfu_rsp_data),
 .g_sfu_rsp_status(g_sfu_rsp_status),
 .g_sfu_protocol_fault(g_sfu_protocol_fault),
 .g_sfu_reject_valid(g_sfu_reject_valid),
 .g_g_wr_valid(g_g_wr_valid),
 .g_g_wr_ready(g_g_wr_ready),
 .g_g_wr_mask(g_g_wr_mask),
 .g_g_wr_addr(g_g_wr_addr),
 .g_g_wr_data(g_g_wr_data),
 .g_g_wr_tag(g_g_wr_tag),
 .g_g_wr_rsp_valid(g_g_wr_rsp_valid),
 .g_g_wr_rsp_ready(g_g_wr_rsp_ready),
 .g_g_wr_rsp_tag(g_g_wr_rsp_tag),
 .g_g_rd_valid(g_g_rd_valid),
 .g_g_rd_ready(g_g_rd_ready),
 .g_g_rd_mask(g_g_rd_mask),
 .g_g_rd_addr(g_g_rd_addr),
 .g_g_rd_tag(g_g_rd_tag),
 .g_g_rd_rsp_valid(g_g_rd_rsp_valid),
 .g_g_rd_rsp_ready(g_g_rd_rsp_ready),
 .g_g_rd_rsp_data(g_g_rd_rsp_data),
 .g_g_rd_rsp_mask(g_g_rd_rsp_mask),
 .g_g_rd_rsp_tag(g_g_rd_rsp_tag),
 .ln_cmd_valid(ln_cmd_valid),
 .ln_cmd_ready(ln_cmd_ready),
 .ln_cmd_request_id(ln_cmd_request_id),
 .ln_cmd_generation(ln_cmd_generation),
 .ln_cmd_epoch(ln_cmd_epoch),
 .ln_cmd_rows(ln_cmd_rows),
 .ln_cmd_gamma(ln_cmd_gamma),
 .ln_cmd_model(ln_cmd_model),
 .ln_cmd_key(ln_cmd_key),
 .ln_gamma_begin_valid(ln_gamma_begin_valid),
 .ln_gamma_begin_ready(ln_gamma_begin_ready),
 .ln_gamma_model(ln_gamma_model),
 .ln_gamma_key(ln_gamma_key),
 .ln_gamma_valid(ln_gamma_valid),
 .ln_gamma_ready(ln_gamma_ready),
 .ln_gamma_chunk(ln_gamma_chunk),
 .ln_gamma_data(ln_gamma_data),
 .ln_gamma_done_valid(ln_gamma_done_valid),
 .ln_gamma_done_ready(ln_gamma_done_ready),
 .ln_gamma_done_error(ln_gamma_done_error),
 .ln_gamma_loaded(ln_gamma_loaded),
 .ln_in_valid(ln_in_valid),
 .ln_in_ready(ln_in_ready),
 .ln_in_request_id(ln_in_request_id),
 .ln_in_generation(ln_in_generation),
 .ln_in_epoch(ln_in_epoch),
 .ln_in_row(ln_in_row),
 .ln_in_chunk(ln_in_chunk),
 .ln_in_tag(ln_in_tag),
 .ln_in_data(ln_in_data),
 .ln_out_valid(ln_out_valid),
 .ln_out_ready(ln_out_ready),
 .ln_out_request_id(ln_out_request_id),
 .ln_out_generation(ln_out_generation),
 .ln_out_epoch(ln_out_epoch),
 .ln_out_row(ln_out_row),
 .ln_out_chunk(ln_out_chunk),
 .ln_out_tag(ln_out_tag),
 .ln_out_data(ln_out_data),
 .ln_done_valid(ln_done_valid),
 .ln_done_ready(ln_done_ready),
 .ln_done_error(ln_done_error),
 .ln_error_stage(ln_error_stage),
 .ln_error_level(ln_error_level),
 .ln_error_row(ln_error_row),
 .ln_error_node(ln_error_node),
 .ln_reject_valid(ln_reject_valid),
 .ln_reject_code(ln_reject_code),
 .ln_active(ln_active),
 .ln_debt_clear(ln_debt_clear),
 .ln_op_request_id(ln_op_request_id),
 .ln_op_generation(ln_op_generation),
 .ln_op_epoch(ln_op_epoch),
 .ln_mul_req_valid(ln_mul_req_valid),
 .ln_mul_req_ready(ln_mul_req_ready),
 .ln_mul_req_tag(ln_mul_req_tag),
 .ln_mul_a(ln_mul_a),
 .ln_mul_b(ln_mul_b),
 .ln_mul_rsp_valid(ln_mul_rsp_valid),
 .ln_mul_rsp_ready(ln_mul_rsp_ready),
 .ln_mul_rsp_tag(ln_mul_rsp_tag),
 .ln_mul_rsp_data(ln_mul_rsp_data),
 .ln_mul_pending(ln_mul_pending),
 .ln_add_req_valid(ln_add_req_valid),
 .ln_add_req_ready(ln_add_req_ready),
 .ln_add_req_tag(ln_add_req_tag),
 .ln_add_a(ln_add_a),
 .ln_add_b(ln_add_b),
 .ln_add_rsp_valid(ln_add_rsp_valid),
 .ln_add_rsp_ready(ln_add_rsp_ready),
 .ln_add_rsp_tag(ln_add_rsp_tag),
 .ln_add_rsp_data(ln_add_rsp_data),
 .ln_add_pending(ln_add_pending),
 .ln_div_req_valid(ln_div_req_valid),
 .ln_div_req_ready(ln_div_req_ready),
 .ln_div_req_tag(ln_div_req_tag),
 .ln_div_a(ln_div_a),
 .ln_div_b(ln_div_b),
 .ln_div_rsp_valid(ln_div_rsp_valid),
 .ln_div_rsp_ready(ln_div_rsp_ready),
 .ln_div_rsp_tag(ln_div_rsp_tag),
 .ln_div_rsp_data(ln_div_rsp_data),
 .ln_div_rsp_error(ln_div_rsp_error),
 .ln_div_pending(ln_div_pending),
 .ln_wr_valid(ln_wr_valid),
 .ln_wr_ready(ln_wr_ready),
 .ln_wr_mask(ln_wr_mask),
 .ln_wr_addr(ln_wr_addr),
 .ln_wr_data(ln_wr_data),
 .ln_wr_tag(ln_wr_tag),
 .ln_wr_rsp_valid(ln_wr_rsp_valid),
 .ln_wr_rsp_ready(ln_wr_rsp_ready),
 .ln_wr_rsp_tag(ln_wr_rsp_tag),
 .ln_rd_valid(ln_rd_valid),
 .ln_rd_ready(ln_rd_ready),
 .ln_rd_mask(ln_rd_mask),
 .ln_rd_addr(ln_rd_addr),
 .ln_rd_tag(ln_rd_tag),
 .ln_rd_rsp_valid(ln_rd_rsp_valid),
 .ln_rd_rsp_ready(ln_rd_rsp_ready),
 .ln_rd_rsp_data(ln_rd_rsp_data),
 .ln_rd_rsp_tag(ln_rd_rsp_tag),
 .ln_bank_idle(ln_bank_idle),
 .ln_trace_add_valid(ln_trace_add_valid),
 .ln_trace_add_meta(ln_trace_add_meta),
 .ln_trace_mul_valid(ln_trace_mul_valid),
 .ln_trace_mul_meta(ln_trace_mul_meta),
 .ln_trace_scalar_valid(ln_trace_scalar_valid),
 .ln_trace_scalar_ctx(ln_trace_scalar_ctx),
 .ln_trace_scalar_data(ln_trace_scalar_data),
 .ln_trace_row_start(ln_trace_row_start),
 .ln_trace_row(ln_trace_row),
 .ln_ctx_active(ln_ctx_active),
 .ln_ctx_row(ln_ctx_row),
 .ln_raw_coverage(ln_raw_coverage),
 .ln_delta_coverage(ln_delta_coverage),
 .ln_cycle_count(ln_cycle_count),
 .ln_peak_add_pending(ln_peak_add_pending),
 .ln_peak_mul_pending(ln_peak_mul_pending),
 .ln_control_clear(ln_control_clear),
 .ln_reject_ready(ln_reject_ready),
 .ln_cancel_valid(j_ln_cancel_valid),
 .ln_cancel_ready(j_ln_cancel_ready),
 .ln_cancel_request_id(j_ln_cancel_request_id),
 .ln_cancel_generation(j_ln_cancel_generation),
 .ln_cancel_epoch(j_ln_cancel_epoch),
 .ln_done_kind(ln_done_kind),
 .ln_cancel_rsp_valid(ln_cancel_rsp_valid),
 .ln_protocol_fault(ln_protocol_fault),
 .ln_protocol_code(ln_protocol_code),
 .ln_protocol_location(ln_protocol_location),
 .ln_error_class(ln_error_class),
 .ln_error_check(ln_error_check),
 .ln_cmd_source_finite_qualified(ln_cmd_source_finite_qualified),
 .ln_cmd_source_summary_valid(ln_cmd_source_summary_valid),
 .ln_cmd_source_bad_valid(ln_cmd_source_bad_valid),
 .ln_cmd_source_bad_row(ln_cmd_source_bad_row),
 .ln_cmd_source_bad_element(ln_cmd_source_bad_element),
 .vector_owner_valid(vector_owner_valid),
 .vector_inputs_ready(vector_inputs_ready),
 .vector_owner_request_id(vector_owner_request_id),
 .vector_owner_generation(vector_owner_generation),
 .vector_owner_epoch(vector_owner_epoch),
 .vector_start_valid(vector_start_valid),
 .vector_start_ready(vector_start_ready),
 .vector_start_op(vector_start_op),
 .vector_start_request_id(vector_start_request_id),
 .vector_start_generation(vector_start_generation),
 .vector_start_epoch(vector_start_epoch),
 .vector_start_reject_valid(vector_start_reject_valid),
 .vector_done_valid(vector_done_valid),
 .vector_done_ready(vector_done_ready),
 .vector_done_status(vector_done_status),
 .vector_done_error_row(vector_done_error_row),
 .vector_done_error_column(vector_done_error_column),
 .vector_idle(vector_idle),
 .vector_issued_vectors(vector_issued_vectors),
 .vector_retired_vectors(vector_retired_vectors),
 .vector_h_rd_valid(vector_h_rd_valid),
 .vector_h_rd_ready(vector_h_rd_ready),
 .vector_h_rd_addr(vector_h_rd_addr),
 .vector_h_rsp_valid(vector_h_rsp_valid),
 .vector_h_rsp_ready(vector_h_rsp_ready),
 .vector_h_rsp_addr(vector_h_rsp_addr),
 .vector_h_rsp_data(vector_h_rsp_data),
 .vector_q_rd_valid(vector_q_rd_valid),
 .vector_q_rd_ready(vector_q_rd_ready),
 .vector_q_rd_addr(vector_q_rd_addr),
 .vector_q_rsp_valid(vector_q_rsp_valid),
 .vector_q_rsp_ready(vector_q_rsp_ready),
 .vector_q_rsp_addr(vector_q_rsp_addr),
 .vector_q_rsp_data(vector_q_rsp_data),
 .vector_h_wr_valid(vector_h_wr_valid),
 .vector_h_wr_ready(vector_h_wr_ready),
 .vector_h_wr_addr(vector_h_wr_addr),
 .vector_h_wr_data(vector_h_wr_data),
 .vector_h_wr_commit(vector_h_wr_commit),
 .vector_fp_lease_valid(vector_fp_lease_valid),
 .vector_fp_lease_ready(vector_fp_lease_ready),
 .vector_fp_lease_request_id(vector_fp_lease_request_id),
 .vector_fp_lease_generation(vector_fp_lease_generation),
 .vector_fp_lease_epoch(vector_fp_lease_epoch),
 .vector_fp_lease_head(vector_fp_lease_head),
 .vector_fp_lease_phase(vector_fp_lease_phase),
 .vector_fp_release_valid(vector_fp_release_valid),
 .vector_fp_release_ready(vector_fp_release_ready),
 .vector_fp_release_phase(vector_fp_release_phase),
 .vector_fp_release_epoch(vector_fp_release_epoch),
 .vector_fp_phase_debt_clear(vector_fp_phase_debt_clear),
 .vector_fp_lease_active(vector_fp_lease_active),
 .vector_fp_rsp_request_id(vector_fp_rsp_request_id),
 .vector_fp_rsp_generation(vector_fp_rsp_generation),
 .vector_fp_rsp_epoch(vector_fp_rsp_epoch),
 .vector_fp_rsp_head(vector_fp_rsp_head),
 .vector_fp_rsp_phase(vector_fp_rsp_phase),
 .vector_fp_protocol_fault(vector_fp_protocol_fault),
 .vector_add_req_valid(vector_add_req_valid),
 .vector_add_req_is_root(vector_add_req_is_root),
 .vector_add_req_ready(vector_add_req_ready),
 .vector_add_req_phase(vector_add_req_phase),
 .vector_add_req_epoch(vector_add_req_epoch),
 .vector_add_req_tag(vector_add_req_tag),
 .vector_add_a(vector_add_a),
 .vector_add_b(vector_add_b),
 .vector_add_rsp_valid(vector_add_rsp_valid),
 .vector_add_rsp_ready(vector_add_rsp_ready),
 .vector_add_rsp_tag(vector_add_rsp_tag),
 .vector_add_rsp_data(vector_add_rsp_data)
 );
 laya_attention_resources_v1 resources(
 .clk(clk),
 .rst_n(rst_n),
 .res_qkv_wr_valid(r_res_qkv_wr_valid),
 .res_qkv_wr_ready(r_res_qkv_wr_ready),
 .res_qkv_wr_plane(r_res_qkv_wr_plane),
 .res_qkv_wr_head(r_res_qkv_wr_head),
 .res_qkv_wr_token(r_res_qkv_wr_token),
 .res_qkv_wr_half(r_res_qkv_wr_half),
 .res_qkv_wr_data(r_res_qkv_wr_data),
 .res_qkv_rd_valid(r_res_qkv_rd_valid),
 .res_qkv_rd_ready(r_res_qkv_rd_ready),
 .res_qkv_rd_head(r_res_qkv_rd_head),
 .res_qkv_rd_token(r_res_qkv_rd_token),
 .res_qkv_rd_tag(r_res_qkv_rd_tag),
 .res_qkv_rd_rsp_valid(r_res_qkv_rd_rsp_valid),
 .res_qkv_rd_rsp_ready(r_res_qkv_rd_rsp_ready),
 .res_qkv_rd_rsp_head(r_res_qkv_rd_rsp_head),
 .res_qkv_rd_rsp_token(r_res_qkv_rd_rsp_token),
 .res_qkv_rd_rsp_tag(r_res_qkv_rd_rsp_tag),
 .res_qkv_rd_rsp_data(r_res_qkv_rd_rsp_data),
 .res_st_bind_valid(r_res_st_bind_valid),
 .res_st_bind_ready(r_res_st_bind_ready),
 .res_st_bind_request_id(r_res_st_bind_request_id),
 .res_st_bind_generation(r_res_st_bind_generation),
 .res_st_bind_epoch(r_res_st_bind_epoch),
 .res_st_bind_head(r_res_st_bind_head),
 .res_st_bind_phase(r_res_st_bind_phase),
 .res_st_op_request_id(r_res_st_op_request_id),
 .res_st_op_generation(r_res_st_op_generation),
 .res_st_op_epoch(r_res_st_op_epoch),
 .res_st_op_phase(r_res_st_op_phase),
 .res_st_rsp_request_id(r_res_st_rsp_request_id),
 .res_st_rsp_generation(r_res_st_rsp_generation),
 .res_st_rsp_epoch(r_res_st_rsp_epoch),
 .res_st_rsp_head(r_res_st_rsp_head),
 .res_st_rsp_phase(r_res_st_rsp_phase),
 .res_st_ps_wr_valid(r_res_st_ps_wr_valid),
 .res_st_ps_wr_ready(r_res_st_ps_wr_ready),
 .res_st_ps_wr_mask(r_res_st_ps_wr_mask),
 .res_st_ps_wr_addr(r_res_st_ps_wr_addr),
 .res_st_ps_wr_data(r_res_st_ps_wr_data),
 .res_st_ps_wr_tag(r_res_st_ps_wr_tag),
 .res_st_ps_wr_rsp_valid(r_res_st_ps_wr_rsp_valid),
 .res_st_ps_wr_rsp_ready(r_res_st_ps_wr_rsp_ready),
 .res_st_ps_wr_rsp_tag(r_res_st_ps_wr_rsp_tag),
 .res_st_ps_rd_valid(r_res_st_ps_rd_valid),
 .res_st_ps_rd_ready(r_res_st_ps_rd_ready),
 .res_st_ps_rd_mask(r_res_st_ps_rd_mask),
 .res_st_ps_rd_addr(r_res_st_ps_rd_addr),
 .res_st_ps_rd_tag(r_res_st_ps_rd_tag),
 .res_st_ps_rd_rsp_valid(r_res_st_ps_rd_rsp_valid),
 .res_st_ps_rd_rsp_ready(r_res_st_ps_rd_rsp_ready),
 .res_st_ps_rd_rsp_data(r_res_st_ps_rd_rsp_data),
 .res_st_ps_rd_rsp_mask(r_res_st_ps_rd_rsp_mask),
 .res_st_ps_rd_rsp_tag(r_res_st_ps_rd_rsp_tag),
 .res_st_g_wr_valid(r_res_st_g_wr_valid),
 .res_st_g_wr_ready(r_res_st_g_wr_ready),
 .res_st_g_wr_mask(r_res_st_g_wr_mask),
 .res_st_g_wr_addr(r_res_st_g_wr_addr),
 .res_st_g_wr_data(r_res_st_g_wr_data),
 .res_st_g_wr_tag(r_res_st_g_wr_tag),
 .res_st_g_wr_rsp_valid(r_res_st_g_wr_rsp_valid),
 .res_st_g_wr_rsp_ready(r_res_st_g_wr_rsp_ready),
 .res_st_g_wr_rsp_tag(r_res_st_g_wr_rsp_tag),
 .res_st_g_rd_valid(r_res_st_g_rd_valid),
 .res_st_g_rd_ready(r_res_st_g_rd_ready),
 .res_st_g_rd_mask(r_res_st_g_rd_mask),
 .res_st_g_rd_addr(r_res_st_g_rd_addr),
 .res_st_g_rd_tag(r_res_st_g_rd_tag),
 .res_st_g_rd_rsp_valid(r_res_st_g_rd_rsp_valid),
 .res_st_g_rd_rsp_ready(r_res_st_g_rd_rsp_ready),
 .res_st_g_rd_rsp_data(r_res_st_g_rd_rsp_data),
 .res_st_g_rd_rsp_mask(r_res_st_g_rd_rsp_mask),
 .res_st_g_rd_rsp_tag(r_res_st_g_rd_rsp_tag),
 .res_st_context_wr_valid(r_res_st_context_wr_valid),
 .res_st_context_wr_ready(r_res_st_context_wr_ready),
 .res_st_context_wr_mask(r_res_st_context_wr_mask),
 .res_st_context_wr_addr(r_res_st_context_wr_addr),
 .res_st_context_wr_data(r_res_st_context_wr_data),
 .res_st_context_wr_tag(r_res_st_context_wr_tag),
 .res_st_context_wr_rsp_valid(r_res_st_context_wr_rsp_valid),
 .res_st_context_wr_rsp_ready(r_res_st_context_wr_rsp_ready),
 .res_st_context_wr_rsp_tag(r_res_st_context_wr_rsp_tag),
 .res_st_context_rd_valid(r_res_st_context_rd_valid),
 .res_st_context_rd_ready(r_res_st_context_rd_ready),
 .res_st_context_rd_mask(r_res_st_context_rd_mask),
 .res_st_context_rd_addr(r_res_st_context_rd_addr),
 .res_st_context_rd_tag(r_res_st_context_rd_tag),
 .res_st_context_rd_rsp_valid(r_res_st_context_rd_rsp_valid),
 .res_st_context_rd_rsp_ready(r_res_st_context_rd_rsp_ready),
 .res_st_context_rd_rsp_data(r_res_st_context_rd_rsp_data),
 .res_st_context_rd_rsp_mask(r_res_st_context_rd_rsp_mask),
 .res_st_context_rd_rsp_tag(r_res_st_context_rd_rsp_tag),
 .res_st_idle(r_res_st_idle),
 .res_fp_lease_valid(r_res_fp_lease_valid),
 .res_fp_lease_ready(r_res_fp_lease_ready),
 .res_fp_lease_request_id(r_res_fp_lease_request_id),
 .res_fp_lease_generation(r_res_fp_lease_generation),
 .res_fp_lease_epoch(r_res_fp_lease_epoch),
 .res_fp_lease_head(r_res_fp_lease_head),
 .res_fp_lease_phase(r_res_fp_lease_phase),
 .res_fp_release_valid(r_res_fp_release_valid),
 .res_fp_release_ready(r_res_fp_release_ready),
 .res_fp_release_phase(r_res_fp_release_phase),
 .res_fp_release_epoch(r_res_fp_release_epoch),
 .res_fp_phase_debt_clear(r_res_fp_phase_debt_clear),
 .res_fp_lease_active(r_res_fp_lease_active),
 .res_fp_draining(r_res_fp_draining),
 .res_fp_rsp_request_id(r_res_fp_rsp_request_id),
 .res_fp_rsp_generation(r_res_fp_rsp_generation),
 .res_fp_rsp_epoch(r_res_fp_rsp_epoch),
 .res_fp_rsp_head(r_res_fp_rsp_head),
 .res_fp_rsp_phase(r_res_fp_rsp_phase),
 .res_fp_mul_req_valid(r_res_fp_mul_req_valid),
 .res_fp_mul_req_ready(r_res_fp_mul_req_ready),
 .res_fp_mul_req_phase(r_res_fp_mul_req_phase),
 .res_fp_mul_req_epoch(r_res_fp_mul_req_epoch),
 .res_fp_mul_req_tag(r_res_fp_mul_req_tag),
 .res_fp_mul_a(r_res_fp_mul_a),
 .res_fp_mul_b(r_res_fp_mul_b),
 .res_fp_mul_rsp_valid(r_res_fp_mul_rsp_valid),
 .res_fp_mul_rsp_ready(r_res_fp_mul_rsp_ready),
 .res_fp_mul_rsp_tag(r_res_fp_mul_rsp_tag),
 .res_fp_mul_rsp_data(r_res_fp_mul_rsp_data),
 .res_fp_add_req_valid(r_res_fp_add_req_valid),
 .res_fp_add_req_is_root(r_res_fp_add_req_is_root),
 .res_fp_add_req_ready(r_res_fp_add_req_ready),
 .res_fp_add_req_phase(r_res_fp_add_req_phase),
 .res_fp_add_req_epoch(r_res_fp_add_req_epoch),
 .res_fp_add_req_tag(r_res_fp_add_req_tag),
 .res_fp_add_a(r_res_fp_add_a),
 .res_fp_add_b(r_res_fp_add_b),
 .res_fp_add_rsp_valid(r_res_fp_add_rsp_valid),
 .res_fp_add_rsp_ready(r_res_fp_add_rsp_ready),
 .res_fp_add_rsp_tag(r_res_fp_add_rsp_tag),
 .res_fp_add_rsp_data(r_res_fp_add_rsp_data),
 .res_fp_mul_pending(r_res_fp_mul_pending),
 .res_fp_add_pending(r_res_fp_add_pending),
 .res_fp_protocol_fault(r_res_fp_protocol_fault),
 .res_ln_bind_valid(r_res_ln_bind_valid),
 .res_ln_bind_ready(r_res_ln_bind_ready),
 .res_ln_bind_request_id(r_res_ln_bind_request_id),
 .res_ln_bind_generation(r_res_ln_bind_generation),
 .res_ln_bind_epoch(r_res_ln_bind_epoch),
 .res_ln_bind_head(r_res_ln_bind_head),
 .res_ln_bind_phase(r_res_ln_bind_phase),
 .res_ln_op_request_id(r_res_ln_op_request_id),
 .res_ln_op_generation(r_res_ln_op_generation),
 .res_ln_op_epoch(r_res_ln_op_epoch),
 .res_ln_op_phase(r_res_ln_op_phase),
 .res_ln_rsp_request_id(r_res_ln_rsp_request_id),
 .res_ln_rsp_generation(r_res_ln_rsp_generation),
 .res_ln_rsp_epoch(r_res_ln_rsp_epoch),
 .res_ln_rsp_head(r_res_ln_rsp_head),
 .res_ln_rsp_phase(r_res_ln_rsp_phase),
 .res_ln_wr_valid(r_res_ln_wr_valid),
 .res_ln_wr_ready(r_res_ln_wr_ready),
 .res_ln_wr_mask(r_res_ln_wr_mask),
 .res_ln_wr_addr(r_res_ln_wr_addr),
 .res_ln_wr_data(r_res_ln_wr_data),
 .res_ln_wr_tag(r_res_ln_wr_tag),
 .res_ln_wr_rsp_valid(r_res_ln_wr_rsp_valid),
 .res_ln_wr_rsp_ready(r_res_ln_wr_rsp_ready),
 .res_ln_wr_rsp_tag(r_res_ln_wr_rsp_tag),
 .res_ln_rd_valid(r_res_ln_rd_valid),
 .res_ln_rd_ready(r_res_ln_rd_ready),
 .res_ln_rd_mask(r_res_ln_rd_mask),
 .res_ln_rd_addr(r_res_ln_rd_addr),
 .res_ln_rd_tag(r_res_ln_rd_tag),
 .res_ln_rd_rsp_valid(r_res_ln_rd_rsp_valid),
 .res_ln_rd_rsp_ready(r_res_ln_rd_rsp_ready),
 .res_ln_rd_rsp_data(r_res_ln_rd_rsp_data),
 .res_ln_rd_rsp_mask(r_res_ln_rd_rsp_mask),
 .res_ln_rd_rsp_tag(r_res_ln_rd_rsp_tag),
 .res_ln_idle(r_res_ln_idle),
 .res_sfu_lease_valid(r_res_sfu_lease_valid),
 .res_sfu_lease_ready(r_res_sfu_lease_ready),
 .res_sfu_lease_request_id(r_res_sfu_lease_request_id),
 .res_sfu_lease_generation(r_res_sfu_lease_generation),
 .res_sfu_lease_epoch(r_res_sfu_lease_epoch),
 .res_sfu_lease_head(r_res_sfu_lease_head),
 .res_sfu_lease_phase(r_res_sfu_lease_phase),
 .res_sfu_release_valid(r_res_sfu_release_valid),
 .res_sfu_release_phase(r_res_sfu_release_phase),
 .res_sfu_release_epoch(r_res_sfu_release_epoch),
 .res_sfu_phase_debt_clear(r_res_sfu_phase_debt_clear),
 .res_sfu_lease_active(r_res_sfu_lease_active),
 .res_sfu_context_valid(r_res_sfu_context_valid),
 .res_sfu_context_row_hi(r_res_sfu_context_row_hi),
 .res_sfu_req_valid(r_res_sfu_req_valid),
 .res_sfu_req_ready(r_res_sfu_req_ready),
 .res_sfu_req_mode(r_res_sfu_req_mode),
 .res_sfu_req_generation(r_res_sfu_req_generation),
 .res_sfu_req_epoch(r_res_sfu_req_epoch),
 .res_sfu_req_phase(r_res_sfu_req_phase),
 .res_sfu_req_tag(r_res_sfu_req_tag),
 .res_sfu_req_x(r_res_sfu_req_x),
 .res_sfu_reject_valid(r_res_sfu_reject_valid),
 .res_sfu_rsp_valid(r_res_sfu_rsp_valid),
 .res_sfu_rsp_ready(r_res_sfu_rsp_ready),
 .res_sfu_rsp_tag(r_res_sfu_rsp_tag),
 .res_sfu_rsp_data(r_res_sfu_rsp_data),
 .res_sfu_pending_vectors(r_res_sfu_pending_vectors),
 .res_sfu_in_flight_vectors(r_res_sfu_in_flight_vectors),
 .res_sfu_protocol_fault(r_res_sfu_protocol_fault),
 .res_div_lease_valid(r_res_div_lease_valid),
 .res_div_lease_ready(r_res_div_lease_ready),
 .res_div_lease_request_id(r_res_div_lease_request_id),
 .res_div_lease_generation(r_res_div_lease_generation),
 .res_div_lease_epoch(r_res_div_lease_epoch),
 .res_div_lease_head(r_res_div_lease_head),
 .res_div_lease_phase(r_res_div_lease_phase),
 .res_div_release_ready(r_res_div_release_ready),
 .res_div_draining(r_res_div_draining),
 .res_div_rsp_request_id(r_res_div_rsp_request_id),
 .res_div_rsp_generation(r_res_div_rsp_generation),
 .res_div_rsp_epoch(r_res_div_rsp_epoch),
 .res_div_rsp_head(r_res_div_rsp_head),
 .res_div_rsp_phase(r_res_div_rsp_phase),
 .res_div_protocol_reject_code(r_res_div_protocol_reject_code),
 .res_div_rsp_lane_mask(r_res_div_rsp_lane_mask),
 .res_div_release_valid(r_res_div_release_valid),
 .res_div_release_phase(r_res_div_release_phase),
 .res_div_release_epoch(r_res_div_release_epoch),
 .res_div_phase_debt_clear(r_res_div_phase_debt_clear),
 .res_div_lease_active(r_res_div_lease_active),
 .res_div_req_valid(r_res_div_req_valid),
 .res_div_req_ready(r_res_div_req_ready),
 .res_div_req_generation(r_res_div_req_generation),
 .res_div_req_epoch(r_res_div_req_epoch),
 .res_div_req_phase(r_res_div_req_phase),
 .res_div_req_lane_mask(r_res_div_req_lane_mask),
 .res_div_req_tag(r_res_div_req_tag),
 .res_div_req_a(r_res_div_req_a),
 .res_div_req_b(r_res_div_req_b),
 .res_div_protocol_reject_valid(r_res_div_protocol_reject_valid),
 .res_div_rsp_valid(r_res_div_rsp_valid),
 .res_div_rsp_ready(r_res_div_rsp_ready),
 .res_div_rsp_tag(r_res_div_rsp_tag),
 .res_div_rsp_numeric_error(r_res_div_rsp_numeric_error),
 .res_div_rsp_data(r_res_div_rsp_data),
 .res_div_pending_vectors(r_res_div_pending_vectors),
 .res_div_in_flight_vectors(r_res_div_in_flight_vectors),
 .res_div_in_flight_scalars(r_res_div_in_flight_scalars),
 .res_div_protocol_fault(r_res_div_protocol_fault),
 .res_scale_valid(r_res_scale_valid),
 .res_scale_ready(r_res_scale_ready),
 .res_scale_tag(r_res_scale_tag),
 .res_scale_input(r_res_scale_input),
 .res_scale_rsp_valid(r_res_scale_rsp_valid),
 .res_scale_rsp_ready(r_res_scale_rsp_ready),
 .res_scale_rsp_tag(r_res_scale_rsp_tag),
 .res_scale_data(r_res_scale_data),
 .res_scale_pending(r_res_scale_pending),
 .res_scale_fault(r_res_scale_fault),
 .rope_owner_valid(r_rope_owner_valid),
 .rope_owner_request_id(r_rope_owner_request_id),
 .rope_owner_generation(r_rope_owner_generation),
 .rope_owner_epoch(r_rope_owner_epoch),
 .rope_wr_valid(r_rope_wr_valid),
 .rope_wr_ready(r_rope_wr_ready),
 .rope_wr_request_id(r_rope_wr_request_id),
 .rope_wr_generation(r_rope_wr_generation),
 .rope_wr_epoch(r_rope_wr_epoch),
 .rope_wr_head(r_rope_wr_head),
 .rope_wr_token(r_rope_wr_token),
 .rope_wr_tag(r_rope_wr_tag),
 .rope_wr_q(r_rope_wr_q),
 .rope_wr_k(r_rope_wr_k),
 .rope_wr_commit_valid(r_rope_wr_commit_valid),
 .rope_wr_commit_tag(r_rope_wr_commit_tag),
 .rope_reject_valid(r_rope_reject_valid),
 .rope_reject_code(r_rope_reject_code)
 );
endmodule
