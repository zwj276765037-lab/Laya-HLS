`timescale 1ns/1ps
// Pure production layer: no resource or coefficient-cache instance.
module laya_attention_layer_engine_v1(
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
 input logic prepare_cancel_valid,output logic prepare_cancel_ready,input logic[63:0]prepare_cancel_request_id,input logic[31:0]prepare_cancel_generation,prepare_cancel_epoch,
 output logic prepare_cancel_rsp_valid,input logic prepare_cancel_rsp_ready,output logic[63:0]prepare_cancel_rsp_request_id,output logic[31:0]prepare_cancel_rsp_generation,prepare_cancel_rsp_epoch,output logic[7:0]prepare_cancel_rsp_status,
 output logic layer_idle,check_coverage_fault,output logic[31:0]check_first_conflict,
 output logic res_qkv_wr_valid,
 input logic res_qkv_wr_ready,
 output logic[1:0] res_qkv_wr_plane,
 output logic[3:0] res_qkv_wr_head,
 output logic[6:0] res_qkv_wr_token,
 output logic res_qkv_wr_half,
 output logic[31:0][31:0] res_qkv_wr_data,
 output logic[2:0] res_qkv_rd_valid,
 input logic[2:0] res_qkv_rd_ready,
 output logic[2:0][3:0] res_qkv_rd_head,
 output logic[2:0][6:0] res_qkv_rd_token,
 output logic[2:0][31:0] res_qkv_rd_tag,
 input logic[2:0] res_qkv_rd_rsp_valid,
 output logic[2:0] res_qkv_rd_rsp_ready,
 input logic[2:0][3:0] res_qkv_rd_rsp_head,
 input logic[2:0][6:0] res_qkv_rd_rsp_token,
 input logic[2:0][31:0] res_qkv_rd_rsp_tag,
 input logic[2:0][63:0][31:0] res_qkv_rd_rsp_data,
 output logic res_st_bind_valid,
 input logic res_st_bind_ready,
 output logic[63:0] res_st_bind_request_id,
 output logic[31:0] res_st_bind_generation,
 output logic[31:0] res_st_bind_epoch,
 output logic[3:0] res_st_bind_head,
 output logic[2:0] res_st_bind_phase,
 output logic[63:0] res_st_op_request_id,
 output logic[31:0] res_st_op_generation,
 output logic[31:0] res_st_op_epoch,
 output logic[2:0] res_st_op_phase,
 input logic[63:0] res_st_rsp_request_id,
 input logic[31:0] res_st_rsp_generation,
 input logic[31:0] res_st_rsp_epoch,
 input logic[3:0] res_st_rsp_head,
 input logic[2:0] res_st_rsp_phase,
 output logic res_st_ps_wr_valid,
 input logic res_st_ps_wr_ready,
 output logic[1023:0] res_st_ps_wr_mask,
 output logic[1023:0][3:0] res_st_ps_wr_addr,
 output logic[1023:0][31:0] res_st_ps_wr_data,
 output logic[95:0] res_st_ps_wr_tag,
 input logic res_st_ps_wr_rsp_valid,
 output logic res_st_ps_wr_rsp_ready,
 input logic[95:0] res_st_ps_wr_rsp_tag,
 output logic res_st_ps_rd_valid,
 input logic res_st_ps_rd_ready,
 output logic[1023:0] res_st_ps_rd_mask,
 output logic[1023:0][3:0] res_st_ps_rd_addr,
 output logic[95:0] res_st_ps_rd_tag,
 input logic res_st_ps_rd_rsp_valid,
 output logic res_st_ps_rd_rsp_ready,
 input logic[1023:0][31:0] res_st_ps_rd_rsp_data,
 input logic[1023:0] res_st_ps_rd_rsp_mask,
 input logic[95:0] res_st_ps_rd_rsp_tag,
 output logic res_st_g_wr_valid,
 input logic res_st_g_wr_ready,
 output logic[255:0] res_st_g_wr_mask,
 output logic[255:0][5:0] res_st_g_wr_addr,
 output logic[255:0][31:0] res_st_g_wr_data,
 output logic[95:0] res_st_g_wr_tag,
 input logic res_st_g_wr_rsp_valid,
 output logic res_st_g_wr_rsp_ready,
 input logic[95:0] res_st_g_wr_rsp_tag,
 output logic res_st_g_rd_valid,
 input logic res_st_g_rd_ready,
 output logic[255:0] res_st_g_rd_mask,
 output logic[255:0][5:0] res_st_g_rd_addr,
 output logic[95:0] res_st_g_rd_tag,
 input logic res_st_g_rd_rsp_valid,
 output logic res_st_g_rd_rsp_ready,
 input logic[255:0][31:0] res_st_g_rd_rsp_data,
 input logic[255:0] res_st_g_rd_rsp_mask,
 input logic[95:0] res_st_g_rd_rsp_tag,
 output logic res_st_context_wr_valid,
 input logic res_st_context_wr_ready,
 output logic[63:0] res_st_context_wr_mask,
 output logic[63:0][10:0] res_st_context_wr_addr,
 output logic[63:0][31:0] res_st_context_wr_data,
 output logic[95:0] res_st_context_wr_tag,
 input logic res_st_context_wr_rsp_valid,
 output logic res_st_context_wr_rsp_ready,
 input logic[95:0] res_st_context_wr_rsp_tag,
 output logic res_st_context_rd_valid,
 input logic res_st_context_rd_ready,
 output logic[63:0] res_st_context_rd_mask,
 output logic[63:0][10:0] res_st_context_rd_addr,
 output logic[95:0] res_st_context_rd_tag,
 input logic res_st_context_rd_rsp_valid,
 output logic res_st_context_rd_rsp_ready,
 input logic[63:0][31:0] res_st_context_rd_rsp_data,
 input logic[63:0] res_st_context_rd_rsp_mask,
 input logic[95:0] res_st_context_rd_rsp_tag,
 input logic res_st_idle,
 output logic res_fp_lease_valid,
 input logic res_fp_lease_ready,
 output logic[63:0] res_fp_lease_request_id,
 output logic[31:0] res_fp_lease_generation,
 output logic[31:0] res_fp_lease_epoch,
 output logic[3:0] res_fp_lease_head,
 output logic[2:0] res_fp_lease_phase,
 output logic res_fp_release_valid,
 input logic res_fp_release_ready,
 output logic[2:0] res_fp_release_phase,
 output logic[31:0] res_fp_release_epoch,
 output logic res_fp_phase_debt_clear,
 input logic res_fp_lease_active,
 input logic res_fp_draining,
 input logic[63:0] res_fp_rsp_request_id,
 input logic[31:0] res_fp_rsp_generation,
 input logic[31:0] res_fp_rsp_epoch,
 input logic[3:0] res_fp_rsp_head,
 input logic[2:0] res_fp_rsp_phase,
 output logic res_fp_mul_req_valid,
 input logic res_fp_mul_req_ready,
 output logic[2:0] res_fp_mul_req_phase,
 output logic[31:0] res_fp_mul_req_epoch,
 output logic[95:0] res_fp_mul_req_tag,
 output logic[255:0][31:0] res_fp_mul_a,
 output logic[255:0][31:0] res_fp_mul_b,
 input logic res_fp_mul_rsp_valid,
 output logic res_fp_mul_rsp_ready,
 input logic[95:0] res_fp_mul_rsp_tag,
 input logic[255:0][31:0] res_fp_mul_rsp_data,
 output logic[6:0] res_fp_add_req_valid,
 output logic[6:0] res_fp_add_req_is_root,
 input logic[6:0] res_fp_add_req_ready,
 output logic[6:0][2:0] res_fp_add_req_phase,
 output logic[6:0][31:0] res_fp_add_req_epoch,
 output logic[6:0][95:0] res_fp_add_req_tag,
 output logic[255:0][31:0] res_fp_add_a,
 output logic[255:0][31:0] res_fp_add_b,
 input logic[6:0] res_fp_add_rsp_valid,
 output logic[6:0] res_fp_add_rsp_ready,
 input logic[6:0][95:0] res_fp_add_rsp_tag,
 input logic[255:0][31:0] res_fp_add_rsp_data,
 input logic[6:0] res_fp_mul_pending,
 input logic[6:0][6:0] res_fp_add_pending,
 input logic res_fp_protocol_fault,
 output logic res_ln_bind_valid,
 input logic res_ln_bind_ready,
 output logic[63:0] res_ln_bind_request_id,
 output logic[31:0] res_ln_bind_generation,
 output logic[31:0] res_ln_bind_epoch,
 output logic[3:0] res_ln_bind_head,
 output logic[2:0] res_ln_bind_phase,
 output logic[63:0] res_ln_op_request_id,
 output logic[31:0] res_ln_op_generation,
 output logic[31:0] res_ln_op_epoch,
 output logic[2:0] res_ln_op_phase,
 input logic[63:0] res_ln_rsp_request_id,
 input logic[31:0] res_ln_rsp_generation,
 input logic[31:0] res_ln_rsp_epoch,
 input logic[3:0] res_ln_rsp_head,
 input logic[2:0] res_ln_rsp_phase,
 output logic res_ln_wr_valid,
 input logic res_ln_wr_ready,
 output logic[255:0] res_ln_wr_mask,
 output logic[255:0][4:0] res_ln_wr_addr,
 output logic[255:0][31:0] res_ln_wr_data,
 output logic[95:0] res_ln_wr_tag,
 input logic res_ln_wr_rsp_valid,
 output logic res_ln_wr_rsp_ready,
 input logic[95:0] res_ln_wr_rsp_tag,
 output logic res_ln_rd_valid,
 input logic res_ln_rd_ready,
 output logic[255:0] res_ln_rd_mask,
 output logic[255:0][4:0] res_ln_rd_addr,
 output logic[95:0] res_ln_rd_tag,
 input logic res_ln_rd_rsp_valid,
 output logic res_ln_rd_rsp_ready,
 input logic[255:0][31:0] res_ln_rd_rsp_data,
 input logic[255:0] res_ln_rd_rsp_mask,
 input logic[95:0] res_ln_rd_rsp_tag,
 input logic res_ln_idle,
 output logic res_sfu_lease_valid,
 input logic res_sfu_lease_ready,
 output logic[63:0] res_sfu_lease_request_id,
 output logic[31:0] res_sfu_lease_generation,
 output logic[31:0] res_sfu_lease_epoch,
 output logic[3:0] res_sfu_lease_head,
 output logic[2:0] res_sfu_lease_phase,
 output logic res_sfu_release_valid,
 output logic[2:0] res_sfu_release_phase,
 output logic[31:0] res_sfu_release_epoch,
 output logic res_sfu_phase_debt_clear,
 input logic res_sfu_lease_active,
 output logic[63:0] res_sfu_context_valid,
 output logic[63:0] res_sfu_context_row_hi,
 output logic res_sfu_req_valid,
 input logic res_sfu_req_ready,
 output logic[1:0] res_sfu_req_mode,
 output logic[31:0] res_sfu_req_generation,
 output logic[31:0] res_sfu_req_epoch,
 output logic[2:0] res_sfu_req_phase,
 output logic[10:0] res_sfu_req_tag,
 output logic[7:0][31:0] res_sfu_req_x,
 input logic res_sfu_reject_valid,
 input logic res_sfu_rsp_valid,
 output logic res_sfu_rsp_ready,
 input logic[10:0] res_sfu_rsp_tag,
 input logic[7:0][31:0] res_sfu_rsp_data,
 input logic[8:0] res_sfu_pending_vectors,
 input logic[8:0] res_sfu_in_flight_vectors,
 input logic res_sfu_protocol_fault,
 output logic res_div_lease_valid,
 input logic res_div_lease_ready,
 output logic[63:0] res_div_lease_request_id,
 output logic[31:0] res_div_lease_generation,
 output logic[31:0] res_div_lease_epoch,
 output logic[3:0] res_div_lease_head,
 output logic[2:0] res_div_lease_phase,
 output logic res_div_release_valid,
 output logic[2:0] res_div_release_phase,
 output logic[31:0] res_div_release_epoch,
 output logic res_div_phase_debt_clear,
 input logic res_div_lease_active,
 output logic res_div_req_valid,
 input logic res_div_req_ready,
 output logic[31:0] res_div_req_generation,
 output logic[31:0] res_div_req_epoch,
 output logic[2:0] res_div_req_phase,
 output logic[7:0] res_div_req_lane_mask,
 output logic[95:0] res_div_req_tag,
 output logic[7:0][31:0] res_div_req_a,
 output logic[7:0][31:0] res_div_req_b,
 input logic res_div_protocol_reject_valid,
 input logic res_div_rsp_valid,
 output logic res_div_rsp_ready,
 input logic[95:0] res_div_rsp_tag,
 input logic[7:0] res_div_rsp_numeric_error,
 input logic[7:0][31:0] res_div_rsp_data,
 input logic[5:0] res_div_pending_vectors,
 input logic[5:0] res_div_in_flight_vectors,
 input logic[8:0] res_div_in_flight_scalars,
 input logic res_div_protocol_fault,
 output logic res_scale_valid,
 input logic res_scale_ready,
 output logic[95:0] res_scale_tag,
 output logic[3:0][31:0] res_scale_input,
 input logic res_scale_rsp_valid,
 output logic res_scale_rsp_ready,
 input logic[95:0] res_scale_rsp_tag,
 input logic[3:0][31:0] res_scale_data,
 input logic[6:0] res_scale_pending,
 input logic res_scale_fault,
 output logic rope_owner_valid,
 output logic[63:0] rope_owner_request_id,
 output logic[31:0] rope_owner_generation,
 output logic[31:0] rope_owner_epoch,
 output logic rope_wr_valid,
 input logic rope_wr_ready,
 output logic[63:0] rope_wr_request_id,
 output logic[31:0] rope_wr_generation,
 output logic[31:0] rope_wr_epoch,
 output logic[3:0] rope_wr_head,
 output logic[6:0] rope_wr_token,
 output logic[95:0] rope_wr_tag,
 output logic[63:0][31:0] rope_wr_q,
 output logic[63:0][31:0] rope_wr_k,
 input logic rope_wr_commit_valid,
 input logic[95:0] rope_wr_commit_tag,
 input logic rope_reject_valid,
 input logic[2:0] rope_reject_code,
 input logic cache_bound_valid,
 input logic[127:0] cache_bound_model_id,
 input logic[127:0] cache_bound_numeric_id,
 input logic[127:0] cache_bound_table_key,
 input logic[1:0] cache_family_complete,
 output logic cache_owner_valid,
 output logic[63:0] cache_owner_request_id,
 output logic[31:0] cache_owner_generation,
 output logic[31:0] cache_owner_epoch,
 output logic cache_rd_valid,
 input logic cache_rd_ready,
 output logic cache_rd_family,
 output logic[6:0] cache_rd_row,
 output logic[95:0] cache_rd_tag,
 output logic[63:0] cache_rd_request_id,
 output logic[31:0] cache_rd_generation,
 output logic[31:0] cache_rd_epoch,
 input logic cache_rd_reject_valid,
 input logic[2:0] cache_rd_reject_code,
 input logic cache_rsp_valid,
 output logic cache_rsp_ready,
 input logic cache_rsp_family,
 input logic[6:0] cache_rsp_row,
 input logic[95:0] cache_rsp_tag,
 input logic[127:0][31:0] cache_rsp_data
);
 logic h_prepare_valid;
 logic h_prepare_ready;
 logic [63:0] h_prepare_request_id;
 logic [31:0] h_prepare_generation;
 logic [31:0] h_prepare_epoch;
 logic [3:0] h_prepare_head;
 logic h_prepare_sliding;
 logic [127:0] h_prepare_mask;
 logic h_qkv_wr_valid;
 logic h_qkv_wr_ready;
 logic [31:0] h_qkv_wr_generation;
 logic [1:0] h_qkv_wr_plane;
 logic [6:0] h_qkv_wr_token;
 logic h_qkv_wr_half;
 logic [31:0][31:0] h_qkv_wr_data;
 logic h_start_valid;
 logic h_start_ready;
 logic [63:0] h_start_request_id;
 logic [31:0] h_start_generation;
 logic h_abort_valid;
 logic h_abort_ready;
 logic [2:0] h_qkv_read_grant;
 logic h_ps_grant;
 logic h_g_grant;
 logic h_context_grant;
 logic h_fp_grant;
 logic h_sfu_grant;
 logic h_exp_grant;
 logic h_div_grant;
 logic h_done_valid;
 logic h_done_ready;
 logic [63:0] h_done_request_id;
 logic [31:0] h_done_generation;
 logic [3:0] h_done_head;
 logic [7:0] h_done_status;
 logic [31:0] h_done_cycles;
 logic [31:0] h_qk_cycles;
 logic [31:0] h_softmax_cycles;
 logic [31:0] h_av_cycles;
 logic [31:0] h_first_score_cycle;
 logic [31:0] h_first_context_cycle;
 logic [31:0] h_max_feedback_cycles;
 logic [31:0] h_first_row_cycle;
 logic [31:0] h_max_sum_tail;
 logic [31:0] h_max_row_launch_gap;
 logic h_error_valid;
 logic [63:0] h_error_rank;
 logic [4:0] h_error_phase;
 logic [31:0] h_error_element;
 logic [127:0][31:0] h_maximum;
 logic h_result_rd_valid;
 logic h_result_rd_ready;
 logic [31:0] h_result_rd_generation;
 logic [31:0] h_result_rd_tag;
 logic [6:0] h_result_rd_query;
 logic h_result_rd_half;
 logic h_result_rsp_valid;
 logic h_result_rsp_ready;
 logic [31:0] h_result_rsp_tag;
 logic [31:0][31:0] h_result_rsp_data;
 logic h_check_qk_done;
 logic h_check_sm_done;
 logic h_check_av_done;
 logic [7:0] h_check_qk_status;
 logic [7:0] h_check_sm_status;
 logic [7:0] h_check_av_status;
 logic [63:0] h_check_qk_rank;
 logic [63:0] h_check_sm_rank;
 logic [4:0] h_check_qk_phase;
 logic [4:0] h_check_sm_phase;
 logic h_resident_valid;
 logic h_resident_ready;
 logic [63:0] h_resident_request_id;
 logic [31:0] h_resident_generation;
 logic [31:0] h_resident_epoch;
 logic [3:0] h_resident_head;
 logic h_res_qkv_wr_valid;
 logic h_res_qkv_wr_ready;
 logic [1:0] h_res_qkv_wr_plane;
 logic [3:0] h_res_qkv_wr_head;
 logic [6:0] h_res_qkv_wr_token;
 logic h_res_qkv_wr_half;
 logic [31:0][31:0] h_res_qkv_wr_data;
 logic [2:0] h_res_qkv_rd_valid;
 logic [2:0] h_res_qkv_rd_ready;
 logic [2:0][3:0] h_res_qkv_rd_head;
 logic [2:0][6:0] h_res_qkv_rd_token;
 logic [2:0][31:0] h_res_qkv_rd_tag;
 logic [2:0] h_res_qkv_rd_rsp_valid;
 logic [2:0] h_res_qkv_rd_rsp_ready;
 logic [2:0][3:0] h_res_qkv_rd_rsp_head;
 logic [2:0][6:0] h_res_qkv_rd_rsp_token;
 logic [2:0][31:0] h_res_qkv_rd_rsp_tag;
 logic [2:0][63:0][31:0] h_res_qkv_rd_rsp_data;
 logic h_res_st_bind_valid;
 logic h_res_st_bind_ready;
 logic [63:0] h_res_st_bind_request_id;
 logic [31:0] h_res_st_bind_generation;
 logic [31:0] h_res_st_bind_epoch;
 logic [3:0] h_res_st_bind_head;
 logic [2:0] h_res_st_bind_phase;
 logic [63:0] h_res_st_op_request_id;
 logic [31:0] h_res_st_op_generation;
 logic [31:0] h_res_st_op_epoch;
 logic [2:0] h_res_st_op_phase;
 logic [63:0] h_res_st_rsp_request_id;
 logic [31:0] h_res_st_rsp_generation;
 logic [31:0] h_res_st_rsp_epoch;
 logic [3:0] h_res_st_rsp_head;
 logic [2:0] h_res_st_rsp_phase;
 logic h_res_st_ps_wr_valid;
 logic h_res_st_ps_wr_ready;
 logic [1023:0] h_res_st_ps_wr_mask;
 logic [1023:0][3:0] h_res_st_ps_wr_addr;
 logic [1023:0][31:0] h_res_st_ps_wr_data;
 logic [95:0] h_res_st_ps_wr_tag;
 logic h_res_st_ps_wr_rsp_valid;
 logic h_res_st_ps_wr_rsp_ready;
 logic [95:0] h_res_st_ps_wr_rsp_tag;
 logic h_res_st_ps_rd_valid;
 logic h_res_st_ps_rd_ready;
 logic [1023:0] h_res_st_ps_rd_mask;
 logic [1023:0][3:0] h_res_st_ps_rd_addr;
 logic [95:0] h_res_st_ps_rd_tag;
 logic h_res_st_ps_rd_rsp_valid;
 logic h_res_st_ps_rd_rsp_ready;
 logic [1023:0][31:0] h_res_st_ps_rd_rsp_data;
 logic [1023:0] h_res_st_ps_rd_rsp_mask;
 logic [95:0] h_res_st_ps_rd_rsp_tag;
 logic h_res_st_g_wr_valid;
 logic h_res_st_g_wr_ready;
 logic [255:0] h_res_st_g_wr_mask;
 logic [255:0][5:0] h_res_st_g_wr_addr;
 logic [255:0][31:0] h_res_st_g_wr_data;
 logic [95:0] h_res_st_g_wr_tag;
 logic h_res_st_g_wr_rsp_valid;
 logic h_res_st_g_wr_rsp_ready;
 logic [95:0] h_res_st_g_wr_rsp_tag;
 logic h_res_st_g_rd_valid;
 logic h_res_st_g_rd_ready;
 logic [255:0] h_res_st_g_rd_mask;
 logic [255:0][5:0] h_res_st_g_rd_addr;
 logic [95:0] h_res_st_g_rd_tag;
 logic h_res_st_g_rd_rsp_valid;
 logic h_res_st_g_rd_rsp_ready;
 logic [255:0][31:0] h_res_st_g_rd_rsp_data;
 logic [255:0] h_res_st_g_rd_rsp_mask;
 logic [95:0] h_res_st_g_rd_rsp_tag;
 logic h_res_st_context_wr_valid;
 logic h_res_st_context_wr_ready;
 logic [63:0] h_res_st_context_wr_mask;
 logic [63:0][10:0] h_res_st_context_wr_addr;
 logic [63:0][31:0] h_res_st_context_wr_data;
 logic [95:0] h_res_st_context_wr_tag;
 logic h_res_st_context_wr_rsp_valid;
 logic h_res_st_context_wr_rsp_ready;
 logic [95:0] h_res_st_context_wr_rsp_tag;
 logic h_res_st_context_rd_valid;
 logic h_res_st_context_rd_ready;
 logic [63:0] h_res_st_context_rd_mask;
 logic [63:0][10:0] h_res_st_context_rd_addr;
 logic [95:0] h_res_st_context_rd_tag;
 logic h_res_st_context_rd_rsp_valid;
 logic h_res_st_context_rd_rsp_ready;
 logic [63:0][31:0] h_res_st_context_rd_rsp_data;
 logic [63:0] h_res_st_context_rd_rsp_mask;
 logic [95:0] h_res_st_context_rd_rsp_tag;
 logic h_res_st_idle;
 logic h_res_fp_lease_valid;
 logic h_res_fp_lease_ready;
 logic [63:0] h_res_fp_lease_request_id;
 logic [31:0] h_res_fp_lease_generation;
 logic [31:0] h_res_fp_lease_epoch;
 logic [3:0] h_res_fp_lease_head;
 logic [2:0] h_res_fp_lease_phase;
 logic h_res_fp_release_valid;
 logic h_res_fp_release_ready;
 logic [2:0] h_res_fp_release_phase;
 logic [31:0] h_res_fp_release_epoch;
 logic h_res_fp_phase_debt_clear;
 logic h_res_fp_lease_active;
 logic h_res_fp_draining;
 logic [63:0] h_res_fp_rsp_request_id;
 logic [31:0] h_res_fp_rsp_generation;
 logic [31:0] h_res_fp_rsp_epoch;
 logic [3:0] h_res_fp_rsp_head;
 logic [2:0] h_res_fp_rsp_phase;
 logic h_res_fp_mul_req_valid;
 logic h_res_fp_mul_req_ready;
 logic [2:0] h_res_fp_mul_req_phase;
 logic [31:0] h_res_fp_mul_req_epoch;
 logic [95:0] h_res_fp_mul_req_tag;
 logic [255:0][31:0] h_res_fp_mul_a;
 logic [255:0][31:0] h_res_fp_mul_b;
 logic h_res_fp_mul_rsp_valid;
 logic h_res_fp_mul_rsp_ready;
 logic [95:0] h_res_fp_mul_rsp_tag;
 logic [255:0][31:0] h_res_fp_mul_rsp_data;
 logic [6:0] h_res_fp_add_req_valid;
 logic [6:0] h_res_fp_add_req_is_root;
 logic [6:0] h_res_fp_add_req_ready;
 logic [6:0][2:0] h_res_fp_add_req_phase;
 logic [6:0][31:0] h_res_fp_add_req_epoch;
 logic [6:0][95:0] h_res_fp_add_req_tag;
 logic [255:0][31:0] h_res_fp_add_a;
 logic [255:0][31:0] h_res_fp_add_b;
 logic [6:0] h_res_fp_add_rsp_valid;
 logic [6:0] h_res_fp_add_rsp_ready;
 logic [6:0][95:0] h_res_fp_add_rsp_tag;
 logic [255:0][31:0] h_res_fp_add_rsp_data;
 logic [6:0] h_res_fp_mul_pending;
 logic [6:0][6:0] h_res_fp_add_pending;
 logic h_res_fp_protocol_fault;
 logic h_res_ln_bind_valid;
 logic h_res_ln_bind_ready;
 logic [63:0] h_res_ln_bind_request_id;
 logic [31:0] h_res_ln_bind_generation;
 logic [31:0] h_res_ln_bind_epoch;
 logic [3:0] h_res_ln_bind_head;
 logic [2:0] h_res_ln_bind_phase;
 logic [63:0] h_res_ln_op_request_id;
 logic [31:0] h_res_ln_op_generation;
 logic [31:0] h_res_ln_op_epoch;
 logic [2:0] h_res_ln_op_phase;
 logic [63:0] h_res_ln_rsp_request_id;
 logic [31:0] h_res_ln_rsp_generation;
 logic [31:0] h_res_ln_rsp_epoch;
 logic [3:0] h_res_ln_rsp_head;
 logic [2:0] h_res_ln_rsp_phase;
 logic h_res_ln_wr_valid;
 logic h_res_ln_wr_ready;
 logic [255:0] h_res_ln_wr_mask;
 logic [255:0][4:0] h_res_ln_wr_addr;
 logic [255:0][31:0] h_res_ln_wr_data;
 logic [95:0] h_res_ln_wr_tag;
 logic h_res_ln_wr_rsp_valid;
 logic h_res_ln_wr_rsp_ready;
 logic [95:0] h_res_ln_wr_rsp_tag;
 logic h_res_ln_rd_valid;
 logic h_res_ln_rd_ready;
 logic [255:0] h_res_ln_rd_mask;
 logic [255:0][4:0] h_res_ln_rd_addr;
 logic [95:0] h_res_ln_rd_tag;
 logic h_res_ln_rd_rsp_valid;
 logic h_res_ln_rd_rsp_ready;
 logic [255:0][31:0] h_res_ln_rd_rsp_data;
 logic [255:0] h_res_ln_rd_rsp_mask;
 logic [95:0] h_res_ln_rd_rsp_tag;
 logic h_res_ln_idle;
 logic h_res_sfu_lease_valid;
 logic h_res_sfu_lease_ready;
 logic [63:0] h_res_sfu_lease_request_id;
 logic [31:0] h_res_sfu_lease_generation;
 logic [31:0] h_res_sfu_lease_epoch;
 logic [3:0] h_res_sfu_lease_head;
 logic [2:0] h_res_sfu_lease_phase;
 logic h_res_sfu_release_valid;
 logic [2:0] h_res_sfu_release_phase;
 logic [31:0] h_res_sfu_release_epoch;
 logic h_res_sfu_phase_debt_clear;
 logic h_res_sfu_lease_active;
 logic [63:0] h_res_sfu_context_valid;
 logic [63:0] h_res_sfu_context_row_hi;
 logic h_res_sfu_req_valid;
 logic h_res_sfu_req_ready;
 logic [1:0] h_res_sfu_req_mode;
 logic [31:0] h_res_sfu_req_generation;
 logic [31:0] h_res_sfu_req_epoch;
 logic [2:0] h_res_sfu_req_phase;
 logic [10:0] h_res_sfu_req_tag;
 logic [7:0][31:0] h_res_sfu_req_x;
 logic h_res_sfu_reject_valid;
 logic h_res_sfu_rsp_valid;
 logic h_res_sfu_rsp_ready;
 logic [10:0] h_res_sfu_rsp_tag;
 logic [7:0][31:0] h_res_sfu_rsp_data;
 logic [8:0] h_res_sfu_pending_vectors;
 logic [8:0] h_res_sfu_in_flight_vectors;
 logic h_res_sfu_protocol_fault;
 logic h_res_div_lease_valid;
 logic h_res_div_lease_ready;
 logic [63:0] h_res_div_lease_request_id;
 logic [31:0] h_res_div_lease_generation;
 logic [31:0] h_res_div_lease_epoch;
 logic [3:0] h_res_div_lease_head;
 logic [2:0] h_res_div_lease_phase;
 logic h_res_div_release_valid;
 logic [2:0] h_res_div_release_phase;
 logic [31:0] h_res_div_release_epoch;
 logic h_res_div_phase_debt_clear;
 logic h_res_div_lease_active;
 logic h_res_div_req_valid;
 logic h_res_div_req_ready;
 logic [31:0] h_res_div_req_generation;
 logic [31:0] h_res_div_req_epoch;
 logic [2:0] h_res_div_req_phase;
 logic [7:0] h_res_div_req_lane_mask;
 logic [95:0] h_res_div_req_tag;
 logic [7:0][31:0] h_res_div_req_a;
 logic [7:0][31:0] h_res_div_req_b;
 logic h_res_div_protocol_reject_valid;
 logic h_res_div_rsp_valid;
 logic h_res_div_rsp_ready;
 logic [95:0] h_res_div_rsp_tag;
 logic [7:0] h_res_div_rsp_numeric_error;
 logic [7:0][31:0] h_res_div_rsp_data;
 logic [5:0] h_res_div_pending_vectors;
 logic [5:0] h_res_div_in_flight_vectors;
 logic [8:0] h_res_div_in_flight_scalars;
 logic h_res_div_protocol_fault;
 logic h_res_scale_valid;
 logic h_res_scale_ready;
 logic [95:0] h_res_scale_tag;
 logic [3:0][31:0] h_res_scale_input;
 logic h_res_scale_rsp_valid;
 logic h_res_scale_rsp_ready;
 logic [95:0] h_res_scale_rsp_tag;
 logic [3:0][31:0] h_res_scale_data;
 logic [6:0] h_res_scale_pending;
 logic h_res_scale_fault;
 logic r_start_valid;
 logic r_start_ready;
 logic [63:0] r_start_request_id;
 logic [31:0] r_start_generation;
 logic [31:0] r_start_epoch;
 logic r_start_family;
 logic r_qkv_complete;
 logic r_coeff_complete;
 logic r_abort_valid;
 logic r_abort_ready;
 logic r_read_grant;
 logic r_fp_grant;
 logic r_write_grant;
 logic r_done_valid;
 logic r_done_ready;
 logic [7:0] r_done_status;
 logic [31:0] r_done_cycles;
 logic [31:0] r_first_commit_cycle;
 logic [11:0] r_commits;
 logic r_error_valid;
 logic [63:0] r_error_rank;
 logic [4:0] r_error_stage;
 logic [31:0] r_error_element;
 logic r_resource_debt_clear;
 logic r_owner_valid;
 logic r_fp_lease_valid;
 logic r_fp_lease_ready;
 logic r_fp_release_valid;
 logic r_fp_release_ready;
 logic r_fp_fault;
 logic [63:0] r_fp_rsp_request_id;
 logic [31:0] r_fp_rsp_generation;
 logic [31:0] r_fp_rsp_epoch;
 logic [3:0] r_fp_rsp_head;
 logic [2:0] r_fp_rsp_phase;
 logic [6:0] r_fp_mul_pending;
 logic [6:0][6:0] r_fp_add_pending;
 logic [2:0] r_qkv_rd_valid;
 logic [2:0] r_qkv_rd_ready;
 logic [2:0][3:0] r_qkv_rd_head;
 logic [2:0][6:0] r_qkv_rd_token;
 logic [2:0][31:0] r_qkv_rd_tag;
 logic [2:0] r_qkv_rsp_valid;
 logic [2:0] r_qkv_rsp_ready;
 logic [2:0][3:0] r_qkv_rsp_head;
 logic [2:0][6:0] r_qkv_rsp_token;
 logic [2:0][31:0] r_qkv_rsp_tag;
 logic [2:0][63:0][31:0] r_qkv_rsp_data;
 logic r_coeff_rd_ready;
 logic r_coeff_rsp_valid;
 logic r_coeff_rsp_family;
 logic [6:0] r_coeff_rsp_row;
 logic [95:0] r_coeff_rsp_tag;
 logic [127:0][31:0] r_coeff_rsp_data;
 logic r_mul_req_valid;
 logic r_mul_req_ready;
 logic [95:0] r_mul_req_tag;
 logic [255:0][31:0] r_mul_a;
 logic [255:0][31:0] r_mul_b;
 logic r_mul_rsp_valid;
 logic r_mul_rsp_ready;
 logic [95:0] r_mul_rsp_tag;
 logic [255:0][31:0] r_mul_rsp_data;
 logic r_add_req_valid;
 logic r_add_req_ready;
 logic [95:0] r_add_req_tag;
 logic [255:0][31:0] r_add_a;
 logic [255:0][31:0] r_add_b;
 logic r_add_rsp_valid;
 logic r_add_rsp_ready;
 logic [95:0] r_add_rsp_tag;
 logic [255:0][31:0] r_add_rsp_data;
 logic r_wr_valid;
 logic r_wr_ready;
 logic [3:0] r_wr_head;
 logic [6:0] r_wr_token;
 logic [95:0] r_wr_tag;
 logic [63:0][31:0] r_wr_q;
 logic [63:0][31:0] r_wr_k;
 logic r_wr_commit_valid;
 logic [95:0] r_wr_commit_tag;
 localparam L_IDLE=0,L_PREP=1,L_RSTART=2,L_ROPE=3,L_HPREP=4,L_HRES=5,L_HSTART=6,L_HEAD=7,L_WAIT=8,L_DONE=9,L_RELEASE=10,L_CANCEL=11;
 logic [3:0]state;logic [63:0]request_id;logic [127:0]model_id,numeric_id;logic [31:0]generation,epoch,clock_count,start_stamp;logic [127:0]table_key,mask;logic [1:0]kind;logic [4:0]layer_index;
 logic qkv_complete;
 wire prepare_descriptor_ok=(prepare_kind==0&&prepare_layer<28&&prepare_layer%3==0)||(prepare_kind==1&&prepare_layer<28&&prepare_layer%3!=0)||(prepare_kind==2&&prepare_layer<2);
 logic [12287:0]qkv_coverage;logic aborted,protocol_bad,public_read_owned;logic [31:0]av_groups;logic [6:0]av_key;
 logic [3:0]candidate_valid;logic [3:0][95:0]candidate_tuple;logic [25:0][15:0]complete_set,unreachable_set,dominated_set;logic [2047:0]av_complete_set,av_unreachable_set,av_dominated_set;logic check_clear,check_all,check_ready,coverage_fault;
 logic real_idle;wire qkv_identity=qkv_wr_request_id==request_id&&qkv_wr_generation==generation&&qkv_wr_epoch==epoch;
 wire tables_match=cache_bound_valid&&cache_bound_model_id==model_id&&cache_bound_numeric_id==numeric_id&&cache_bound_table_key==table_key&&cache_family_complete[kind==1];
 wire context_public_zone=state==L_DONE||state==L_RELEASE;
 wire head_retire=h_done_valid&&h_done_ready;wire layer_start=start_valid&&start_ready;wire public_read_fire=result_rd_valid&&result_rd_ready;
 wire[4095:0]output_consumed=qkv_coverage[4095:0];
 assign cache_owner_valid=state!=L_IDLE;
 assign cache_owner_request_id=request_id;
 assign cache_owner_generation=generation;
 assign cache_owner_epoch=epoch;
 wire cancel_fire=(prepare_cancel_valid===1'b1)&&prepare_cancel_ready;
 assign prepare_cancel_ready=rst_n&&state==L_PREP&&prepare_cancel_request_id==request_id&&prepare_cancel_generation==generation&&prepare_cancel_epoch==epoch;
 assign prepare_cancel_rsp_valid=state==L_CANCEL;
 assign prepare_cancel_rsp_request_id=request_id;assign prepare_cancel_rsp_generation=generation;assign prepare_cancel_rsp_epoch=epoch;assign prepare_cancel_rsp_status=8'd4;
 assign layer_idle=rst_n&&state==L_IDLE&&real_idle;
 assign check_coverage_fault=coverage_fault;
 function automatic logic[95:0]tuple(input int s,a,b,c,d,e,f);return {8'(s),16'(a),16'(b),16'(c),16'(d),16'(e),8'(f)};endfunction
 function automatic int alo(input int g);case(g)0:return 0;1:return 128;2:return 192;3:return 224;4:return 240;5:return 248;default:return 252;endcase endfunction
 function automatic int an(input int g);case(g)0:return 128;1:return 64;2:return 32;3:return 16;4:return 8;default:return 4;endcase endfunction
 assign real_idle=res_st_idle&&res_ln_idle&&!res_fp_lease_active&&!res_sfu_lease_active&&!res_div_lease_active&&!public_read_owned&&!res_st_context_rd_rsp_valid&&!r_owner_valid&&res_qkv_rd_rsp_valid==0;
 assign prepare_ready=rst_n&&state==L_IDLE&&real_idle&&h_prepare_ready&&prepare_descriptor_ok;
 assign start_ready=rst_n&&state==L_PREP&&!cancel_fire&&start_request_id==request_id&&start_generation==generation&&(&qkv_coverage)&&(kind==2||tables_match);
 assign abort_ready=rst_n&&state>=L_RSTART&&state<=L_WAIT&&!aborted;
 assign done_valid=state==L_DONE;assign done_request_id=request_id;assign done_generation=generation;
 assign done_status=protocol_bad||coverage_fault?8'd3:aborted?8'd2:error_valid?8'd1:8'd0;
 assign qkv_wr_ready=rst_n&&state==L_PREP&&!cancel_fire&&qkv_identity&&qkv_wr_plane<3&&res_qkv_wr_ready;
 assign check_clear=prepare_valid&&prepare_ready;
 always_comb begin
  reject_code=0;
  if(qkv_wr_valid&&(state!=L_PREP||!qkv_identity))reject_code=1;
  else if(qkv_wr_valid&&qkv_wr_plane==3)reject_code=2;
  else if(start_valid&&state==L_PREP&&(start_request_id!=request_id||start_generation!=generation))reject_code=3;
  else if(start_valid&&state==L_PREP&&!(&qkv_coverage))reject_code=4;
  else if(start_valid&&state==L_PREP&&kind!=2&&!tables_match)reject_code=5;
  else if(prepare_valid&&state==L_IDLE&&!prepare_descriptor_ok)reject_code=6;
  reject_valid=rst_n&&reject_code!=0;
 end
 assign producer_done_cycles=done_cycles;
 assign result_discard_ready=rst_n&&context_public_zone&&done_status==0&&result_discard_generation==generation&&!context_discarded;
 assign result_rd_ready=rst_n&&context_public_zone&&done_status==0&&!context_discarded&&result_rd_generation==generation&&head_context_valid[result_rd_head]&&res_st_context_rd_ready;
 assign result_rsp_valid=context_public_zone&&public_read_owned&&res_st_context_rd_rsp_valid;
 assign result_rsp_tag=res_st_context_rd_rsp_tag[31:0];
 for(genvar c=0;c<32;c++)assign result_rsp_data[c]=res_st_context_rd_rsp_data[int'(res_st_context_rd_rsp_tag[32])*32+c];
 assign h_prepare_valid=state==L_HPREP&&!coverage_fault;
 assign h_prepare_request_id=request_id;
 assign h_prepare_generation=generation;
 assign h_prepare_epoch=epoch;
 assign h_prepare_head=active_head;
 assign h_prepare_sliding=kind==1;
 assign h_prepare_mask=mask;
 assign h_qkv_wr_valid=1'b0;
 assign h_qkv_wr_generation=generation;
 assign h_qkv_wr_plane=2'b0;
 assign h_qkv_wr_token=7'b0;
 assign h_qkv_wr_half=1'b0;
 assign h_qkv_wr_data=1024'b0;
 assign h_start_valid=state==L_HSTART&&!coverage_fault;
 assign h_start_request_id=request_id;
 assign h_start_generation=generation;
 assign h_abort_valid=(aborted||protocol_bad||coverage_fault)&&h_abort_ready;
 assign h_qkv_read_grant=qkv_read_grant;
 assign h_ps_grant=ps_grant;
 assign h_g_grant=g_grant;
 assign h_context_grant=context_grant;
 assign h_fp_grant=fp_grant;
 assign h_sfu_grant=sfu_grant;
 assign h_exp_grant=exp_grant;
 assign h_div_grant=div_grant;
 assign h_done_ready=state==L_HEAD||(coverage_fault&&(state==L_HRES||state==L_HSTART));
 assign h_result_rd_valid=1'b0;
 assign h_result_rd_generation=generation;
 assign h_result_rd_tag=32'b0;
 assign h_result_rd_query=7'b0;
 assign h_result_rd_half=1'b0;
 assign h_result_rsp_ready=1'b1;
 assign h_resident_valid=state==L_HRES&&qkv_complete&&!coverage_fault;
 assign h_resident_request_id=request_id;
 assign h_resident_generation=generation;
 assign h_resident_epoch=epoch;
 assign h_resident_head=active_head;
 assign r_start_valid=state==L_RSTART&&!coverage_fault;
 assign r_start_request_id=request_id;
 assign r_start_generation=generation;
 assign r_start_epoch=epoch;
 assign r_start_family=kind==1;
 assign r_qkv_complete=qkv_complete;
 assign r_coeff_complete=tables_match;
 assign r_abort_valid=(aborted||protocol_bad||coverage_fault)&&r_abort_ready;
 assign r_read_grant=&qkv_read_grant[1:0];
 assign r_fp_grant=fp_grant;
 assign r_write_grant=rope_write_grant;
 assign r_done_ready=state==L_ROPE;
 assign r_fp_lease_ready=res_fp_lease_ready;
 assign r_fp_release_ready=res_fp_release_ready;
 assign r_fp_fault=res_fp_protocol_fault;
 assign r_fp_rsp_request_id=res_fp_rsp_request_id;
 assign r_fp_rsp_generation=res_fp_rsp_generation;
 assign r_fp_rsp_epoch=res_fp_rsp_epoch;
 assign r_fp_rsp_head=res_fp_rsp_head;
 assign r_fp_rsp_phase=res_fp_rsp_phase;
 assign r_fp_mul_pending=res_fp_mul_pending;
 assign r_fp_add_pending=res_fp_add_pending;
 assign r_qkv_rd_ready=r_owner_valid?res_qkv_rd_ready:3'b0;
 assign r_qkv_rsp_valid=r_owner_valid?res_qkv_rd_rsp_valid:3'b0;
 assign r_qkv_rsp_head=res_qkv_rd_rsp_head;
 assign r_qkv_rsp_token=res_qkv_rd_rsp_token;
 assign r_qkv_rsp_tag=res_qkv_rd_rsp_tag;
 assign r_qkv_rsp_data=res_qkv_rd_rsp_data;
 assign r_coeff_rd_ready=cache_rd_ready;
 assign r_coeff_rsp_valid=cache_rsp_valid;
 assign r_coeff_rsp_family=cache_rsp_family;
 assign r_coeff_rsp_row=cache_rsp_row;
 assign r_coeff_rsp_tag=cache_rsp_tag;
 assign r_coeff_rsp_data=cache_rsp_data;
 assign r_mul_req_ready=res_fp_mul_req_ready;
 assign r_mul_rsp_valid=r_owner_valid&&res_fp_mul_rsp_valid;
 assign r_mul_rsp_tag=res_fp_mul_rsp_tag;
 assign r_mul_rsp_data=res_fp_mul_rsp_data;
 assign r_add_req_ready=res_fp_add_req_ready[0];
 assign r_add_rsp_valid=r_owner_valid&&res_fp_add_rsp_valid[0];
 assign r_add_rsp_tag=res_fp_add_rsp_tag[0];
 assign r_add_rsp_data=res_fp_add_rsp_data;
 assign r_wr_ready=rope_wr_ready;
 assign r_wr_commit_valid=rope_wr_commit_valid;
 assign r_wr_commit_tag=rope_wr_commit_tag;
 assign res_qkv_wr_valid=state==L_PREP&&!cancel_fire&&qkv_wr_valid&&qkv_identity&&qkv_wr_plane<3;
 assign h_res_qkv_wr_ready=res_qkv_wr_ready;
 assign res_qkv_wr_plane=qkv_wr_plane;
 assign res_qkv_wr_head=qkv_wr_head;
 assign res_qkv_wr_token=qkv_wr_token;
 assign res_qkv_wr_half=qkv_wr_half;
 assign res_qkv_wr_data=qkv_wr_data;
 assign res_qkv_rd_valid=r_owner_valid?r_qkv_rd_valid:h_res_qkv_rd_valid;
 assign h_res_qkv_rd_ready=r_owner_valid?3'b0:res_qkv_rd_ready;
 assign res_qkv_rd_head=r_owner_valid?r_qkv_rd_head:h_res_qkv_rd_head;
 assign res_qkv_rd_token=r_owner_valid?r_qkv_rd_token:h_res_qkv_rd_token;
 assign res_qkv_rd_tag=r_owner_valid?r_qkv_rd_tag:h_res_qkv_rd_tag;
 assign h_res_qkv_rd_rsp_valid=r_owner_valid?3'b0:res_qkv_rd_rsp_valid;
 assign res_qkv_rd_rsp_ready=r_owner_valid?r_qkv_rsp_ready:h_res_qkv_rd_rsp_ready;
 assign h_res_qkv_rd_rsp_head=res_qkv_rd_rsp_head;
 assign h_res_qkv_rd_rsp_token=res_qkv_rd_rsp_token;
 assign h_res_qkv_rd_rsp_tag=res_qkv_rd_rsp_tag;
 assign h_res_qkv_rd_rsp_data=res_qkv_rd_rsp_data;
 assign res_st_bind_valid=h_res_st_bind_valid;
 assign h_res_st_bind_ready=res_st_bind_ready;
 assign res_st_bind_request_id=h_res_st_bind_request_id;
 assign res_st_bind_generation=h_res_st_bind_generation;
 assign res_st_bind_epoch=h_res_st_bind_epoch;
 assign res_st_bind_head=h_res_st_bind_head;
 assign res_st_bind_phase=h_res_st_bind_phase;
 assign res_st_op_request_id=context_public_zone?request_id:h_res_st_op_request_id;
 assign res_st_op_generation=context_public_zone?generation:h_res_st_op_generation;
 assign res_st_op_epoch=context_public_zone?epoch:h_res_st_op_epoch;
 assign res_st_op_phase=context_public_zone?3'd4:h_res_st_op_phase;
 assign h_res_st_rsp_request_id=res_st_rsp_request_id;
 assign h_res_st_rsp_generation=res_st_rsp_generation;
 assign h_res_st_rsp_epoch=res_st_rsp_epoch;
 assign h_res_st_rsp_head=res_st_rsp_head;
 assign h_res_st_rsp_phase=res_st_rsp_phase;
 assign res_st_ps_wr_valid=h_res_st_ps_wr_valid;
 assign h_res_st_ps_wr_ready=res_st_ps_wr_ready;
 assign res_st_ps_wr_mask=h_res_st_ps_wr_mask;
 assign res_st_ps_wr_addr=h_res_st_ps_wr_addr;
 assign res_st_ps_wr_data=h_res_st_ps_wr_data;
 assign res_st_ps_wr_tag=h_res_st_ps_wr_tag;
 assign h_res_st_ps_wr_rsp_valid=res_st_ps_wr_rsp_valid;
 assign res_st_ps_wr_rsp_ready=h_res_st_ps_wr_rsp_ready;
 assign h_res_st_ps_wr_rsp_tag=res_st_ps_wr_rsp_tag;
 assign res_st_ps_rd_valid=h_res_st_ps_rd_valid;
 assign h_res_st_ps_rd_ready=res_st_ps_rd_ready;
 assign res_st_ps_rd_mask=h_res_st_ps_rd_mask;
 assign res_st_ps_rd_addr=h_res_st_ps_rd_addr;
 assign res_st_ps_rd_tag=h_res_st_ps_rd_tag;
 assign h_res_st_ps_rd_rsp_valid=res_st_ps_rd_rsp_valid;
 assign res_st_ps_rd_rsp_ready=h_res_st_ps_rd_rsp_ready;
 assign h_res_st_ps_rd_rsp_data=res_st_ps_rd_rsp_data;
 assign h_res_st_ps_rd_rsp_mask=res_st_ps_rd_rsp_mask;
 assign h_res_st_ps_rd_rsp_tag=res_st_ps_rd_rsp_tag;
 assign res_st_g_wr_valid=h_res_st_g_wr_valid;
 assign h_res_st_g_wr_ready=res_st_g_wr_ready;
 assign res_st_g_wr_mask=h_res_st_g_wr_mask;
 assign res_st_g_wr_addr=h_res_st_g_wr_addr;
 assign res_st_g_wr_data=h_res_st_g_wr_data;
 assign res_st_g_wr_tag=h_res_st_g_wr_tag;
 assign h_res_st_g_wr_rsp_valid=res_st_g_wr_rsp_valid;
 assign res_st_g_wr_rsp_ready=h_res_st_g_wr_rsp_ready;
 assign h_res_st_g_wr_rsp_tag=res_st_g_wr_rsp_tag;
 assign res_st_g_rd_valid=h_res_st_g_rd_valid;
 assign h_res_st_g_rd_ready=res_st_g_rd_ready;
 assign res_st_g_rd_mask=h_res_st_g_rd_mask;
 assign res_st_g_rd_addr=h_res_st_g_rd_addr;
 assign res_st_g_rd_tag=h_res_st_g_rd_tag;
 assign h_res_st_g_rd_rsp_valid=res_st_g_rd_rsp_valid;
 assign res_st_g_rd_rsp_ready=h_res_st_g_rd_rsp_ready;
 assign h_res_st_g_rd_rsp_data=res_st_g_rd_rsp_data;
 assign h_res_st_g_rd_rsp_mask=res_st_g_rd_rsp_mask;
 assign h_res_st_g_rd_rsp_tag=res_st_g_rd_rsp_tag;
 assign res_st_context_wr_valid=h_res_st_context_wr_valid;
 assign h_res_st_context_wr_ready=res_st_context_wr_ready;
 assign res_st_context_wr_mask=h_res_st_context_wr_mask;
 assign res_st_context_wr_addr=h_res_st_context_wr_addr;
 assign res_st_context_wr_data=h_res_st_context_wr_data;
 assign res_st_context_wr_tag=h_res_st_context_wr_tag;
 assign h_res_st_context_wr_rsp_valid=res_st_context_wr_rsp_valid;
 assign res_st_context_wr_rsp_ready=h_res_st_context_wr_rsp_ready;
 assign h_res_st_context_wr_rsp_tag=res_st_context_wr_rsp_tag;
 assign res_st_context_rd_valid=context_public_zone?(result_rd_valid&&context_public_zone&&done_status==0&&!context_discarded&&result_rd_generation==generation&&head_context_valid[result_rd_head]):h_res_st_context_rd_valid;
 assign h_res_st_context_rd_ready=res_st_context_rd_ready;
 assign res_st_context_rd_mask=context_public_zone?(result_rd_half?64'hffffffff00000000:64'h00000000ffffffff):h_res_st_context_rd_mask;
 assign res_st_context_rd_tag=context_public_zone?{52'b0,result_rd_head,result_rd_query,result_rd_half,result_rd_tag}:h_res_st_context_rd_tag;
 assign h_res_st_context_rd_rsp_valid=res_st_context_rd_rsp_valid;
 assign res_st_context_rd_rsp_ready=context_public_zone?(public_read_owned&&result_rsp_ready):h_res_st_context_rd_rsp_ready;
 assign h_res_st_context_rd_rsp_data=res_st_context_rd_rsp_data;
 assign h_res_st_context_rd_rsp_mask=res_st_context_rd_rsp_mask;
 assign h_res_st_context_rd_rsp_tag=res_st_context_rd_rsp_tag;
 assign h_res_st_idle=res_st_idle;
 assign res_fp_lease_valid=r_owner_valid?r_fp_lease_valid:h_res_fp_lease_valid;
 assign h_res_fp_lease_ready=!r_owner_valid&&res_fp_lease_ready;
 assign res_fp_lease_request_id=r_owner_valid?cache_rd_request_id:h_res_fp_lease_request_id;
 assign res_fp_lease_generation=r_owner_valid?cache_rd_generation:h_res_fp_lease_generation;
 assign res_fp_lease_epoch=r_owner_valid?cache_rd_epoch:h_res_fp_lease_epoch;
 assign res_fp_lease_head=r_owner_valid?4'b0:h_res_fp_lease_head;
 assign res_fp_lease_phase=r_owner_valid?3'd7:h_res_fp_lease_phase;
 assign res_fp_release_valid=r_owner_valid?r_fp_release_valid:h_res_fp_release_valid;
 assign h_res_fp_release_ready=res_fp_release_ready;
 assign res_fp_release_phase=r_owner_valid?3'd7:h_res_fp_release_phase;
 assign res_fp_release_epoch=r_owner_valid?cache_rd_epoch:h_res_fp_release_epoch;
 assign res_fp_phase_debt_clear=r_owner_valid?r_resource_debt_clear:h_res_fp_phase_debt_clear;
 assign h_res_fp_lease_active=res_fp_lease_active;
 assign h_res_fp_draining=res_fp_draining;
 assign h_res_fp_rsp_request_id=res_fp_rsp_request_id;
 assign h_res_fp_rsp_generation=res_fp_rsp_generation;
 assign h_res_fp_rsp_epoch=res_fp_rsp_epoch;
 assign h_res_fp_rsp_head=res_fp_rsp_head;
 assign h_res_fp_rsp_phase=res_fp_rsp_phase;
 assign res_fp_mul_req_valid=r_owner_valid?r_mul_req_valid:h_res_fp_mul_req_valid;
 assign h_res_fp_mul_req_ready=res_fp_mul_req_ready;
 assign res_fp_mul_req_phase=r_owner_valid?3'd7:h_res_fp_mul_req_phase;
 assign res_fp_mul_req_epoch=r_owner_valid?cache_rd_epoch:h_res_fp_mul_req_epoch;
 assign res_fp_mul_req_tag=r_owner_valid?r_mul_req_tag:h_res_fp_mul_req_tag;
 assign res_fp_mul_a=r_owner_valid?r_mul_a:h_res_fp_mul_a;
 assign res_fp_mul_b=r_owner_valid?r_mul_b:h_res_fp_mul_b;
 assign h_res_fp_mul_rsp_valid=res_fp_mul_rsp_valid;
 assign res_fp_mul_rsp_ready=r_owner_valid?r_mul_rsp_ready:h_res_fp_mul_rsp_ready;
 assign h_res_fp_mul_rsp_tag=res_fp_mul_rsp_tag;
 assign h_res_fp_mul_rsp_data=res_fp_mul_rsp_data;
 assign res_fp_add_req_valid=r_owner_valid?{6'b0,r_add_req_valid}:h_res_fp_add_req_valid;
 assign res_fp_add_req_is_root=r_owner_valid?7'b0:h_res_fp_add_req_is_root;
 assign h_res_fp_add_req_ready=res_fp_add_req_ready;
 assign res_fp_add_req_phase=r_owner_valid?{7{3'd7}}:h_res_fp_add_req_phase;
 assign res_fp_add_req_epoch=r_owner_valid?{7{cache_rd_epoch}}:h_res_fp_add_req_epoch;
 assign res_fp_add_req_tag=r_owner_valid?{576'b0,r_add_req_tag}:h_res_fp_add_req_tag;
 assign res_fp_add_a=r_owner_valid?r_add_a:h_res_fp_add_a;
 assign res_fp_add_b=r_owner_valid?r_add_b:h_res_fp_add_b;
 assign h_res_fp_add_rsp_valid=res_fp_add_rsp_valid;
 assign res_fp_add_rsp_ready=r_owner_valid?{6'b0,r_add_rsp_ready}:h_res_fp_add_rsp_ready;
 assign h_res_fp_add_rsp_tag=res_fp_add_rsp_tag;
 assign h_res_fp_add_rsp_data=res_fp_add_rsp_data;
 assign h_res_fp_mul_pending=res_fp_mul_pending;
 assign h_res_fp_add_pending=res_fp_add_pending;
 assign h_res_fp_protocol_fault=res_fp_protocol_fault;
 assign res_ln_bind_valid=h_res_ln_bind_valid;
 assign h_res_ln_bind_ready=res_ln_bind_ready;
 assign res_ln_bind_request_id=h_res_ln_bind_request_id;
 assign res_ln_bind_generation=h_res_ln_bind_generation;
 assign res_ln_bind_epoch=h_res_ln_bind_epoch;
 assign res_ln_bind_head=h_res_ln_bind_head;
 assign res_ln_bind_phase=h_res_ln_bind_phase;
 assign res_ln_op_request_id=h_res_ln_op_request_id;
 assign res_ln_op_generation=h_res_ln_op_generation;
 assign res_ln_op_epoch=h_res_ln_op_epoch;
 assign res_ln_op_phase=h_res_ln_op_phase;
 assign h_res_ln_rsp_request_id=res_ln_rsp_request_id;
 assign h_res_ln_rsp_generation=res_ln_rsp_generation;
 assign h_res_ln_rsp_epoch=res_ln_rsp_epoch;
 assign h_res_ln_rsp_head=res_ln_rsp_head;
 assign h_res_ln_rsp_phase=res_ln_rsp_phase;
 assign res_ln_wr_valid=h_res_ln_wr_valid;
 assign h_res_ln_wr_ready=res_ln_wr_ready;
 assign res_ln_wr_mask=h_res_ln_wr_mask;
 assign res_ln_wr_addr=h_res_ln_wr_addr;
 assign res_ln_wr_data=h_res_ln_wr_data;
 assign res_ln_wr_tag=h_res_ln_wr_tag;
 assign h_res_ln_wr_rsp_valid=res_ln_wr_rsp_valid;
 assign res_ln_wr_rsp_ready=h_res_ln_wr_rsp_ready;
 assign h_res_ln_wr_rsp_tag=res_ln_wr_rsp_tag;
 assign res_ln_rd_valid=h_res_ln_rd_valid;
 assign h_res_ln_rd_ready=res_ln_rd_ready;
 assign res_ln_rd_mask=h_res_ln_rd_mask;
 assign res_ln_rd_addr=h_res_ln_rd_addr;
 assign res_ln_rd_tag=h_res_ln_rd_tag;
 assign h_res_ln_rd_rsp_valid=res_ln_rd_rsp_valid;
 assign res_ln_rd_rsp_ready=h_res_ln_rd_rsp_ready;
 assign h_res_ln_rd_rsp_data=res_ln_rd_rsp_data;
 assign h_res_ln_rd_rsp_mask=res_ln_rd_rsp_mask;
 assign h_res_ln_rd_rsp_tag=res_ln_rd_rsp_tag;
 assign h_res_ln_idle=res_ln_idle;
 assign res_sfu_lease_valid=h_res_sfu_lease_valid;
 assign h_res_sfu_lease_ready=res_sfu_lease_ready;
 assign res_sfu_lease_request_id=h_res_sfu_lease_request_id;
 assign res_sfu_lease_generation=h_res_sfu_lease_generation;
 assign res_sfu_lease_epoch=h_res_sfu_lease_epoch;
 assign res_sfu_lease_head=h_res_sfu_lease_head;
 assign res_sfu_lease_phase=h_res_sfu_lease_phase;
 assign res_sfu_release_valid=h_res_sfu_release_valid;
 assign res_sfu_release_phase=h_res_sfu_release_phase;
 assign res_sfu_release_epoch=h_res_sfu_release_epoch;
 assign res_sfu_phase_debt_clear=h_res_sfu_phase_debt_clear;
 assign h_res_sfu_lease_active=res_sfu_lease_active;
 assign res_sfu_context_valid=h_res_sfu_context_valid;
 assign res_sfu_context_row_hi=h_res_sfu_context_row_hi;
 assign res_sfu_req_valid=h_res_sfu_req_valid;
 assign h_res_sfu_req_ready=res_sfu_req_ready;
 assign res_sfu_req_mode=h_res_sfu_req_mode;
 assign res_sfu_req_generation=h_res_sfu_req_generation;
 assign res_sfu_req_epoch=h_res_sfu_req_epoch;
 assign res_sfu_req_phase=h_res_sfu_req_phase;
 assign res_sfu_req_tag=h_res_sfu_req_tag;
 assign res_sfu_req_x=h_res_sfu_req_x;
 assign h_res_sfu_reject_valid=res_sfu_reject_valid;
 assign h_res_sfu_rsp_valid=res_sfu_rsp_valid;
 assign res_sfu_rsp_ready=h_res_sfu_rsp_ready;
 assign h_res_sfu_rsp_tag=res_sfu_rsp_tag;
 assign h_res_sfu_rsp_data=res_sfu_rsp_data;
 assign h_res_sfu_pending_vectors=res_sfu_pending_vectors;
 assign h_res_sfu_in_flight_vectors=res_sfu_in_flight_vectors;
 assign h_res_sfu_protocol_fault=res_sfu_protocol_fault;
 assign res_div_lease_valid=h_res_div_lease_valid;
 assign h_res_div_lease_ready=res_div_lease_ready;
 assign res_div_lease_request_id=h_res_div_lease_request_id;
 assign res_div_lease_generation=h_res_div_lease_generation;
 assign res_div_lease_epoch=h_res_div_lease_epoch;
 assign res_div_lease_head=h_res_div_lease_head;
 assign res_div_lease_phase=h_res_div_lease_phase;
 assign res_div_release_valid=h_res_div_release_valid;
 assign res_div_release_phase=h_res_div_release_phase;
 assign res_div_release_epoch=h_res_div_release_epoch;
 assign res_div_phase_debt_clear=h_res_div_phase_debt_clear;
 assign h_res_div_lease_active=res_div_lease_active;
 assign res_div_req_valid=h_res_div_req_valid;
 assign h_res_div_req_ready=res_div_req_ready;
 assign res_div_req_generation=h_res_div_req_generation;
 assign res_div_req_epoch=h_res_div_req_epoch;
 assign res_div_req_phase=h_res_div_req_phase;
 assign res_div_req_lane_mask=h_res_div_req_lane_mask;
 assign res_div_req_tag=h_res_div_req_tag;
 assign res_div_req_a=h_res_div_req_a;
 assign res_div_req_b=h_res_div_req_b;
 assign h_res_div_protocol_reject_valid=res_div_protocol_reject_valid;
 assign h_res_div_rsp_valid=res_div_rsp_valid;
 assign res_div_rsp_ready=h_res_div_rsp_ready;
 assign h_res_div_rsp_tag=res_div_rsp_tag;
 assign h_res_div_rsp_numeric_error=res_div_rsp_numeric_error;
 assign h_res_div_rsp_data=res_div_rsp_data;
 assign h_res_div_pending_vectors=res_div_pending_vectors;
 assign h_res_div_in_flight_vectors=res_div_in_flight_vectors;
 assign h_res_div_in_flight_scalars=res_div_in_flight_scalars;
 assign h_res_div_protocol_fault=res_div_protocol_fault;
 assign res_scale_valid=h_res_scale_valid;
 assign h_res_scale_ready=res_scale_ready;
 assign res_scale_tag=h_res_scale_tag;
 assign res_scale_input=h_res_scale_input;
 assign h_res_scale_rsp_valid=res_scale_rsp_valid;
 assign res_scale_rsp_ready=h_res_scale_rsp_ready;
 assign h_res_scale_rsp_tag=res_scale_rsp_tag;
 assign h_res_scale_data=res_scale_data;
 assign h_res_scale_pending=res_scale_pending;
 assign h_res_scale_fault=res_scale_fault;
 always_comb begin for(int c=0;c<64;c++)res_st_context_rd_addr[c]=context_public_zone?{result_rd_head,result_rd_query}:h_res_st_context_rd_addr[c];end
 assign rope_owner_valid=r_owner_valid;
 assign rope_owner_request_id=cache_rd_request_id;
 assign rope_owner_generation=cache_rd_generation;
 assign rope_owner_epoch=cache_rd_epoch;
 assign rope_wr_valid=r_wr_valid;
 assign rope_wr_request_id=cache_rd_request_id;
 assign rope_wr_generation=cache_rd_generation;
 assign rope_wr_epoch=cache_rd_epoch;
 assign rope_wr_head=r_wr_head;
 assign rope_wr_token=r_wr_token;
 assign rope_wr_tag=r_wr_tag;
 assign rope_wr_q=r_wr_q;
 assign rope_wr_k=r_wr_k;
 laya_attention_head_engine_v1 #(.RESIDENT_ONLY(1)) head(.clk(clk),.rst_n(rst_n),.prepare_valid(h_prepare_valid),.prepare_ready(h_prepare_ready),.prepare_request_id(h_prepare_request_id),.prepare_generation(h_prepare_generation),.prepare_epoch(h_prepare_epoch),.prepare_head(h_prepare_head),.prepare_sliding(h_prepare_sliding),.prepare_mask(h_prepare_mask),.qkv_wr_valid(h_qkv_wr_valid),.qkv_wr_ready(h_qkv_wr_ready),.qkv_wr_generation(h_qkv_wr_generation),.qkv_wr_plane(h_qkv_wr_plane),.qkv_wr_token(h_qkv_wr_token),.qkv_wr_half(h_qkv_wr_half),.qkv_wr_data(h_qkv_wr_data),.start_valid(h_start_valid),.start_ready(h_start_ready),.start_request_id(h_start_request_id),.start_generation(h_start_generation),.abort_valid(h_abort_valid),.abort_ready(h_abort_ready),.qkv_read_grant(h_qkv_read_grant),.ps_grant(h_ps_grant),.g_grant(h_g_grant),.context_grant(h_context_grant),.fp_grant(h_fp_grant),.sfu_grant(h_sfu_grant),.exp_grant(h_exp_grant),.div_grant(h_div_grant),.done_valid(h_done_valid),.done_ready(h_done_ready),.done_request_id(h_done_request_id),.done_generation(h_done_generation),.done_head(h_done_head),.done_status(h_done_status),.done_cycles(h_done_cycles),.qk_cycles(h_qk_cycles),.softmax_cycles(h_softmax_cycles),.av_cycles(h_av_cycles),.first_score_cycle(h_first_score_cycle),.first_context_cycle(h_first_context_cycle),.max_feedback_cycles(h_max_feedback_cycles),.first_row_cycle(h_first_row_cycle),.max_sum_tail(h_max_sum_tail),.max_row_launch_gap(h_max_row_launch_gap),.error_valid(h_error_valid),.error_rank(h_error_rank),.error_phase(h_error_phase),.error_element(h_error_element),.maximum(h_maximum),.result_rd_valid(h_result_rd_valid),.result_rd_ready(h_result_rd_ready),.result_rd_generation(h_result_rd_generation),.result_rd_tag(h_result_rd_tag),.result_rd_query(h_result_rd_query),.result_rd_half(h_result_rd_half),.result_rsp_valid(h_result_rsp_valid),.result_rsp_ready(h_result_rsp_ready),.result_rsp_tag(h_result_rsp_tag),.result_rsp_data(h_result_rsp_data),.check_qk_done(h_check_qk_done),.check_sm_done(h_check_sm_done),.check_av_done(h_check_av_done),.check_qk_status(h_check_qk_status),.check_sm_status(h_check_sm_status),.check_av_status(h_check_av_status),.check_qk_rank(h_check_qk_rank),.check_sm_rank(h_check_sm_rank),.check_qk_phase(h_check_qk_phase),.check_sm_phase(h_check_sm_phase),.resident_valid(h_resident_valid),.resident_ready(h_resident_ready),.resident_request_id(h_resident_request_id),.resident_generation(h_resident_generation),.resident_epoch(h_resident_epoch),.resident_head(h_resident_head),.res_qkv_wr_valid(h_res_qkv_wr_valid),.res_qkv_wr_ready(h_res_qkv_wr_ready),.res_qkv_wr_plane(h_res_qkv_wr_plane),.res_qkv_wr_head(h_res_qkv_wr_head),.res_qkv_wr_token(h_res_qkv_wr_token),.res_qkv_wr_half(h_res_qkv_wr_half),.res_qkv_wr_data(h_res_qkv_wr_data),.res_qkv_rd_valid(h_res_qkv_rd_valid),.res_qkv_rd_ready(h_res_qkv_rd_ready),.res_qkv_rd_head(h_res_qkv_rd_head),.res_qkv_rd_token(h_res_qkv_rd_token),.res_qkv_rd_tag(h_res_qkv_rd_tag),.res_qkv_rd_rsp_valid(h_res_qkv_rd_rsp_valid),.res_qkv_rd_rsp_ready(h_res_qkv_rd_rsp_ready),.res_qkv_rd_rsp_head(h_res_qkv_rd_rsp_head),.res_qkv_rd_rsp_token(h_res_qkv_rd_rsp_token),.res_qkv_rd_rsp_tag(h_res_qkv_rd_rsp_tag),.res_qkv_rd_rsp_data(h_res_qkv_rd_rsp_data),.res_st_bind_valid(h_res_st_bind_valid),.res_st_bind_ready(h_res_st_bind_ready),.res_st_bind_request_id(h_res_st_bind_request_id),.res_st_bind_generation(h_res_st_bind_generation),.res_st_bind_epoch(h_res_st_bind_epoch),.res_st_bind_head(h_res_st_bind_head),.res_st_bind_phase(h_res_st_bind_phase),.res_st_op_request_id(h_res_st_op_request_id),.res_st_op_generation(h_res_st_op_generation),.res_st_op_epoch(h_res_st_op_epoch),.res_st_op_phase(h_res_st_op_phase),.res_st_rsp_request_id(h_res_st_rsp_request_id),.res_st_rsp_generation(h_res_st_rsp_generation),.res_st_rsp_epoch(h_res_st_rsp_epoch),.res_st_rsp_head(h_res_st_rsp_head),.res_st_rsp_phase(h_res_st_rsp_phase),.res_st_ps_wr_valid(h_res_st_ps_wr_valid),.res_st_ps_wr_ready(h_res_st_ps_wr_ready),.res_st_ps_wr_mask(h_res_st_ps_wr_mask),.res_st_ps_wr_addr(h_res_st_ps_wr_addr),.res_st_ps_wr_data(h_res_st_ps_wr_data),.res_st_ps_wr_tag(h_res_st_ps_wr_tag),.res_st_ps_wr_rsp_valid(h_res_st_ps_wr_rsp_valid),.res_st_ps_wr_rsp_ready(h_res_st_ps_wr_rsp_ready),.res_st_ps_wr_rsp_tag(h_res_st_ps_wr_rsp_tag),.res_st_ps_rd_valid(h_res_st_ps_rd_valid),.res_st_ps_rd_ready(h_res_st_ps_rd_ready),.res_st_ps_rd_mask(h_res_st_ps_rd_mask),.res_st_ps_rd_addr(h_res_st_ps_rd_addr),.res_st_ps_rd_tag(h_res_st_ps_rd_tag),.res_st_ps_rd_rsp_valid(h_res_st_ps_rd_rsp_valid),.res_st_ps_rd_rsp_ready(h_res_st_ps_rd_rsp_ready),.res_st_ps_rd_rsp_data(h_res_st_ps_rd_rsp_data),.res_st_ps_rd_rsp_mask(h_res_st_ps_rd_rsp_mask),.res_st_ps_rd_rsp_tag(h_res_st_ps_rd_rsp_tag),.res_st_g_wr_valid(h_res_st_g_wr_valid),.res_st_g_wr_ready(h_res_st_g_wr_ready),.res_st_g_wr_mask(h_res_st_g_wr_mask),.res_st_g_wr_addr(h_res_st_g_wr_addr),.res_st_g_wr_data(h_res_st_g_wr_data),.res_st_g_wr_tag(h_res_st_g_wr_tag),.res_st_g_wr_rsp_valid(h_res_st_g_wr_rsp_valid),.res_st_g_wr_rsp_ready(h_res_st_g_wr_rsp_ready),.res_st_g_wr_rsp_tag(h_res_st_g_wr_rsp_tag),.res_st_g_rd_valid(h_res_st_g_rd_valid),.res_st_g_rd_ready(h_res_st_g_rd_ready),.res_st_g_rd_mask(h_res_st_g_rd_mask),.res_st_g_rd_addr(h_res_st_g_rd_addr),.res_st_g_rd_tag(h_res_st_g_rd_tag),.res_st_g_rd_rsp_valid(h_res_st_g_rd_rsp_valid),.res_st_g_rd_rsp_ready(h_res_st_g_rd_rsp_ready),.res_st_g_rd_rsp_data(h_res_st_g_rd_rsp_data),.res_st_g_rd_rsp_mask(h_res_st_g_rd_rsp_mask),.res_st_g_rd_rsp_tag(h_res_st_g_rd_rsp_tag),.res_st_context_wr_valid(h_res_st_context_wr_valid),.res_st_context_wr_ready(h_res_st_context_wr_ready),.res_st_context_wr_mask(h_res_st_context_wr_mask),.res_st_context_wr_addr(h_res_st_context_wr_addr),.res_st_context_wr_data(h_res_st_context_wr_data),.res_st_context_wr_tag(h_res_st_context_wr_tag),.res_st_context_wr_rsp_valid(h_res_st_context_wr_rsp_valid),.res_st_context_wr_rsp_ready(h_res_st_context_wr_rsp_ready),.res_st_context_wr_rsp_tag(h_res_st_context_wr_rsp_tag),.res_st_context_rd_valid(h_res_st_context_rd_valid),.res_st_context_rd_ready(h_res_st_context_rd_ready),.res_st_context_rd_mask(h_res_st_context_rd_mask),.res_st_context_rd_addr(h_res_st_context_rd_addr),.res_st_context_rd_tag(h_res_st_context_rd_tag),.res_st_context_rd_rsp_valid(h_res_st_context_rd_rsp_valid),.res_st_context_rd_rsp_ready(h_res_st_context_rd_rsp_ready),.res_st_context_rd_rsp_data(h_res_st_context_rd_rsp_data),.res_st_context_rd_rsp_mask(h_res_st_context_rd_rsp_mask),.res_st_context_rd_rsp_tag(h_res_st_context_rd_rsp_tag),.res_st_idle(h_res_st_idle),.res_fp_lease_valid(h_res_fp_lease_valid),.res_fp_lease_ready(h_res_fp_lease_ready),.res_fp_lease_request_id(h_res_fp_lease_request_id),.res_fp_lease_generation(h_res_fp_lease_generation),.res_fp_lease_epoch(h_res_fp_lease_epoch),.res_fp_lease_head(h_res_fp_lease_head),.res_fp_lease_phase(h_res_fp_lease_phase),.res_fp_release_valid(h_res_fp_release_valid),.res_fp_release_ready(h_res_fp_release_ready),.res_fp_release_phase(h_res_fp_release_phase),.res_fp_release_epoch(h_res_fp_release_epoch),.res_fp_phase_debt_clear(h_res_fp_phase_debt_clear),.res_fp_lease_active(h_res_fp_lease_active),.res_fp_draining(h_res_fp_draining),.res_fp_rsp_request_id(h_res_fp_rsp_request_id),.res_fp_rsp_generation(h_res_fp_rsp_generation),.res_fp_rsp_epoch(h_res_fp_rsp_epoch),.res_fp_rsp_head(h_res_fp_rsp_head),.res_fp_rsp_phase(h_res_fp_rsp_phase),.res_fp_mul_req_valid(h_res_fp_mul_req_valid),.res_fp_mul_req_ready(h_res_fp_mul_req_ready),.res_fp_mul_req_phase(h_res_fp_mul_req_phase),.res_fp_mul_req_epoch(h_res_fp_mul_req_epoch),.res_fp_mul_req_tag(h_res_fp_mul_req_tag),.res_fp_mul_a(h_res_fp_mul_a),.res_fp_mul_b(h_res_fp_mul_b),.res_fp_mul_rsp_valid(h_res_fp_mul_rsp_valid),.res_fp_mul_rsp_ready(h_res_fp_mul_rsp_ready),.res_fp_mul_rsp_tag(h_res_fp_mul_rsp_tag),.res_fp_mul_rsp_data(h_res_fp_mul_rsp_data),.res_fp_add_req_valid(h_res_fp_add_req_valid),.res_fp_add_req_is_root(h_res_fp_add_req_is_root),.res_fp_add_req_ready(h_res_fp_add_req_ready),.res_fp_add_req_phase(h_res_fp_add_req_phase),.res_fp_add_req_epoch(h_res_fp_add_req_epoch),.res_fp_add_req_tag(h_res_fp_add_req_tag),.res_fp_add_a(h_res_fp_add_a),.res_fp_add_b(h_res_fp_add_b),.res_fp_add_rsp_valid(h_res_fp_add_rsp_valid),.res_fp_add_rsp_ready(h_res_fp_add_rsp_ready),.res_fp_add_rsp_tag(h_res_fp_add_rsp_tag),.res_fp_add_rsp_data(h_res_fp_add_rsp_data),.res_fp_mul_pending(h_res_fp_mul_pending),.res_fp_add_pending(h_res_fp_add_pending),.res_fp_protocol_fault(h_res_fp_protocol_fault),.res_ln_bind_valid(h_res_ln_bind_valid),.res_ln_bind_ready(h_res_ln_bind_ready),.res_ln_bind_request_id(h_res_ln_bind_request_id),.res_ln_bind_generation(h_res_ln_bind_generation),.res_ln_bind_epoch(h_res_ln_bind_epoch),.res_ln_bind_head(h_res_ln_bind_head),.res_ln_bind_phase(h_res_ln_bind_phase),.res_ln_op_request_id(h_res_ln_op_request_id),.res_ln_op_generation(h_res_ln_op_generation),.res_ln_op_epoch(h_res_ln_op_epoch),.res_ln_op_phase(h_res_ln_op_phase),.res_ln_rsp_request_id(h_res_ln_rsp_request_id),.res_ln_rsp_generation(h_res_ln_rsp_generation),.res_ln_rsp_epoch(h_res_ln_rsp_epoch),.res_ln_rsp_head(h_res_ln_rsp_head),.res_ln_rsp_phase(h_res_ln_rsp_phase),.res_ln_wr_valid(h_res_ln_wr_valid),.res_ln_wr_ready(h_res_ln_wr_ready),.res_ln_wr_mask(h_res_ln_wr_mask),.res_ln_wr_addr(h_res_ln_wr_addr),.res_ln_wr_data(h_res_ln_wr_data),.res_ln_wr_tag(h_res_ln_wr_tag),.res_ln_wr_rsp_valid(h_res_ln_wr_rsp_valid),.res_ln_wr_rsp_ready(h_res_ln_wr_rsp_ready),.res_ln_wr_rsp_tag(h_res_ln_wr_rsp_tag),.res_ln_rd_valid(h_res_ln_rd_valid),.res_ln_rd_ready(h_res_ln_rd_ready),.res_ln_rd_mask(h_res_ln_rd_mask),.res_ln_rd_addr(h_res_ln_rd_addr),.res_ln_rd_tag(h_res_ln_rd_tag),.res_ln_rd_rsp_valid(h_res_ln_rd_rsp_valid),.res_ln_rd_rsp_ready(h_res_ln_rd_rsp_ready),.res_ln_rd_rsp_data(h_res_ln_rd_rsp_data),.res_ln_rd_rsp_mask(h_res_ln_rd_rsp_mask),.res_ln_rd_rsp_tag(h_res_ln_rd_rsp_tag),.res_ln_idle(h_res_ln_idle),.res_sfu_lease_valid(h_res_sfu_lease_valid),.res_sfu_lease_ready(h_res_sfu_lease_ready),.res_sfu_lease_request_id(h_res_sfu_lease_request_id),.res_sfu_lease_generation(h_res_sfu_lease_generation),.res_sfu_lease_epoch(h_res_sfu_lease_epoch),.res_sfu_lease_head(h_res_sfu_lease_head),.res_sfu_lease_phase(h_res_sfu_lease_phase),.res_sfu_release_valid(h_res_sfu_release_valid),.res_sfu_release_phase(h_res_sfu_release_phase),.res_sfu_release_epoch(h_res_sfu_release_epoch),.res_sfu_phase_debt_clear(h_res_sfu_phase_debt_clear),.res_sfu_lease_active(h_res_sfu_lease_active),.res_sfu_context_valid(h_res_sfu_context_valid),.res_sfu_context_row_hi(h_res_sfu_context_row_hi),.res_sfu_req_valid(h_res_sfu_req_valid),.res_sfu_req_ready(h_res_sfu_req_ready),.res_sfu_req_mode(h_res_sfu_req_mode),.res_sfu_req_generation(h_res_sfu_req_generation),.res_sfu_req_epoch(h_res_sfu_req_epoch),.res_sfu_req_phase(h_res_sfu_req_phase),.res_sfu_req_tag(h_res_sfu_req_tag),.res_sfu_req_x(h_res_sfu_req_x),.res_sfu_reject_valid(h_res_sfu_reject_valid),.res_sfu_rsp_valid(h_res_sfu_rsp_valid),.res_sfu_rsp_ready(h_res_sfu_rsp_ready),.res_sfu_rsp_tag(h_res_sfu_rsp_tag),.res_sfu_rsp_data(h_res_sfu_rsp_data),.res_sfu_pending_vectors(h_res_sfu_pending_vectors),.res_sfu_in_flight_vectors(h_res_sfu_in_flight_vectors),.res_sfu_protocol_fault(h_res_sfu_protocol_fault),.res_div_lease_valid(h_res_div_lease_valid),.res_div_lease_ready(h_res_div_lease_ready),.res_div_lease_request_id(h_res_div_lease_request_id),.res_div_lease_generation(h_res_div_lease_generation),.res_div_lease_epoch(h_res_div_lease_epoch),.res_div_lease_head(h_res_div_lease_head),.res_div_lease_phase(h_res_div_lease_phase),.res_div_release_valid(h_res_div_release_valid),.res_div_release_phase(h_res_div_release_phase),.res_div_release_epoch(h_res_div_release_epoch),.res_div_phase_debt_clear(h_res_div_phase_debt_clear),.res_div_lease_active(h_res_div_lease_active),.res_div_req_valid(h_res_div_req_valid),.res_div_req_ready(h_res_div_req_ready),.res_div_req_generation(h_res_div_req_generation),.res_div_req_epoch(h_res_div_req_epoch),.res_div_req_phase(h_res_div_req_phase),.res_div_req_lane_mask(h_res_div_req_lane_mask),.res_div_req_tag(h_res_div_req_tag),.res_div_req_a(h_res_div_req_a),.res_div_req_b(h_res_div_req_b),.res_div_protocol_reject_valid(h_res_div_protocol_reject_valid),.res_div_rsp_valid(h_res_div_rsp_valid),.res_div_rsp_ready(h_res_div_rsp_ready),.res_div_rsp_tag(h_res_div_rsp_tag),.res_div_rsp_numeric_error(h_res_div_rsp_numeric_error),.res_div_rsp_data(h_res_div_rsp_data),.res_div_pending_vectors(h_res_div_pending_vectors),.res_div_in_flight_vectors(h_res_div_in_flight_vectors),.res_div_in_flight_scalars(h_res_div_in_flight_scalars),.res_div_protocol_fault(h_res_div_protocol_fault),.res_scale_valid(h_res_scale_valid),.res_scale_ready(h_res_scale_ready),.res_scale_tag(h_res_scale_tag),.res_scale_input(h_res_scale_input),.res_scale_rsp_valid(h_res_scale_rsp_valid),.res_scale_rsp_ready(h_res_scale_rsp_ready),.res_scale_rsp_tag(h_res_scale_rsp_tag),.res_scale_data(h_res_scale_data),.res_scale_pending(h_res_scale_pending),.res_scale_fault(h_res_scale_fault));
 laya_attention_rope_engine_v1 rope(.clk(clk),.rst_n(rst_n),.start_valid(r_start_valid),.start_ready(r_start_ready),.start_request_id(r_start_request_id),.start_generation(r_start_generation),.start_epoch(r_start_epoch),.start_family(r_start_family),.qkv_complete(r_qkv_complete),.coeff_complete(r_coeff_complete),.abort_valid(r_abort_valid),.abort_ready(r_abort_ready),.read_grant(r_read_grant),.fp_grant(r_fp_grant),.write_grant(r_write_grant),.done_valid(r_done_valid),.done_ready(r_done_ready),.done_status(r_done_status),.done_cycles(r_done_cycles),.first_commit_cycle(r_first_commit_cycle),.commits(r_commits),.error_valid(r_error_valid),.error_rank(r_error_rank),.error_stage(r_error_stage),.error_element(r_error_element),.resource_debt_clear(r_resource_debt_clear),.owner_valid(r_owner_valid),.request_id(cache_rd_request_id),.generation(cache_rd_generation),.epoch(cache_rd_epoch),.fp_lease_valid(r_fp_lease_valid),.fp_lease_ready(r_fp_lease_ready),.fp_release_valid(r_fp_release_valid),.fp_release_ready(r_fp_release_ready),.fp_fault(r_fp_fault),.fp_rsp_request_id(r_fp_rsp_request_id),.fp_rsp_generation(r_fp_rsp_generation),.fp_rsp_epoch(r_fp_rsp_epoch),.fp_rsp_head(r_fp_rsp_head),.fp_rsp_phase(r_fp_rsp_phase),.fp_mul_pending(r_fp_mul_pending),.fp_add_pending(r_fp_add_pending),.qkv_rd_valid(r_qkv_rd_valid),.qkv_rd_ready(r_qkv_rd_ready),.qkv_rd_head(r_qkv_rd_head),.qkv_rd_token(r_qkv_rd_token),.qkv_rd_tag(r_qkv_rd_tag),.qkv_rsp_valid(r_qkv_rsp_valid),.qkv_rsp_ready(r_qkv_rsp_ready),.qkv_rsp_head(r_qkv_rsp_head),.qkv_rsp_token(r_qkv_rsp_token),.qkv_rsp_tag(r_qkv_rsp_tag),.qkv_rsp_data(r_qkv_rsp_data),.coeff_rd_valid(cache_rd_valid),.coeff_rd_ready(r_coeff_rd_ready),.coeff_rd_family(cache_rd_family),.coeff_rd_row(cache_rd_row),.coeff_rd_tag(cache_rd_tag),.coeff_rsp_valid(r_coeff_rsp_valid),.coeff_rsp_ready(cache_rsp_ready),.coeff_rsp_family(r_coeff_rsp_family),.coeff_rsp_row(r_coeff_rsp_row),.coeff_rsp_tag(r_coeff_rsp_tag),.coeff_rsp_data(r_coeff_rsp_data),.mul_req_valid(r_mul_req_valid),.mul_req_ready(r_mul_req_ready),.mul_req_tag(r_mul_req_tag),.mul_a(r_mul_a),.mul_b(r_mul_b),.mul_rsp_valid(r_mul_rsp_valid),.mul_rsp_ready(r_mul_rsp_ready),.mul_rsp_tag(r_mul_rsp_tag),.mul_rsp_data(r_mul_rsp_data),.add_req_valid(r_add_req_valid),.add_req_ready(r_add_req_ready),.add_req_tag(r_add_req_tag),.add_a(r_add_a),.add_b(r_add_b),.add_rsp_valid(r_add_rsp_valid),.add_rsp_ready(r_add_rsp_ready),.add_rsp_tag(r_add_rsp_tag),.add_rsp_data(r_add_rsp_data),.wr_valid(r_wr_valid),.wr_ready(r_wr_ready),.wr_head(r_wr_head),.wr_token(r_wr_token),.wr_tag(r_wr_tag),.wr_q(r_wr_q),.wr_k(r_wr_k),.wr_commit_valid(r_wr_commit_valid),.wr_commit_tag(r_wr_commit_tag));
 laya_attention_check_order_v1 checks(.clk,.rst_n,.clear(check_clear),.candidate_valid,.candidate_tuple,.complete_set,.unreachable_set,.dominated_set,.av_complete_set,.av_unreachable_set,.av_dominated_set,.real_debts_clear(real_idle),.error_valid,.error_tuple,.completed(check_completed),.unreachable(check_unreachable),.dominated(check_dominated),.av_completed(av_check_completed),.av_unreachable(av_check_unreachable),.av_dominated(av_check_dominated),.all_accounted(check_all),.final_ready(check_ready),.coverage_fault,.first_conflict(check_first_conflict));
 task automatic offer(input logic[95:0]t,inout logic valid,inout logic[95:0]rank);if(!valid||t<rank)begin valid=1;rank=t;end endtask
 always_comb begin
  candidate_valid=0;candidate_tuple=0;complete_set=0;unreachable_set=0;dominated_set=0;av_complete_set=0;av_unreachable_set=0;av_dominated_set=0;
  if(qkv_wr_valid&&qkv_wr_ready)for(int c=0;c<32;c++)if(qkv_wr_data[c][30:23]==8'hff)offer(tuple(0,qkv_wr_token,qkv_wr_plane,qkv_wr_head,int'(qkv_wr_half)*32+c,0,0),candidate_valid[0],candidate_tuple[0]);
  if(layer_start)complete_set[0]='1;
  if(state==L_RSTART&&r_start_valid&&r_start_ready)begin end
  if(state==L_ROPE&&r_done_valid&&r_done_status<=1)begin
   for(int s=1;s<=10;s++)complete_set[s]='1;
   if(r_error_valid)begin
    int token,h,node;token=r_error_stage==0?int'(r_error_element)/3072:(r_error_stage==5||r_error_stage==10)?int'(r_error_element)/1024:int'(r_error_element)/512;
    h=(r_error_stage==5||r_error_stage==10)?(int'(r_error_element)%1024)/64:(int'(r_error_element)%512)/32;node=(r_error_stage==5||r_error_stage==10)?int'(r_error_element)%64:int'(r_error_element)%32;
    candidate_valid[1]=1;candidate_tuple[1]=tuple(r_error_stage,token,h,node,0,0,0);
   end
  end
  if(layer_start&&kind==2)for(int s=1;s<=10;s++)unreachable_set[s]='1;
  if(layer_start&&error_valid)begin for(int s=1;s<26;s++)unreachable_set[s]='1;av_unreachable_set='1;end
  if(state==L_ROPE&&r_done_valid&&(r_done_status!=0||aborted))begin
   for(int s=11;s<26;s++)unreachable_set[s]='1;av_unreachable_set='1;
   if(r_done_status>1)for(int s=1;s<=10;s++)unreachable_set[s]='1;
  end
  if(h_check_qk_done&&h_check_qk_status<=1)begin
   complete_set[11][active_head]=1;complete_set[12][active_head]=1;
   if(h_check_qk_status==1)begin
    candidate_valid[2]=1;
    if(h_check_qk_phase==7)candidate_tuple[2]=tuple(12,active_head,int'(h_check_qk_rank[22:16]),int'(h_check_qk_rank[6:0]),0,0,0);
    else candidate_tuple[2]=tuple(11,active_head,int'(h_check_qk_rank[51:48]),int'(h_check_qk_rank[42:40]),int'(h_check_qk_rank[34:32]),int'(h_check_qk_rank[22:16]),int'(h_check_qk_rank[5:0]));
    for(int s=13;s<26;s++)unreachable_set[s][active_head]=1;
    for(int k=0;k<128;k++)av_unreachable_set[k*16+int'(active_head)]=1;
   end
  end
  if(h_check_sm_done&&h_check_sm_status<=1)begin
   int stopstage;stopstage=h_check_sm_status==0?25:int'(h_check_sm_phase)+6;
   for(int s=13;s<25;s++)begin if(s<stopstage)complete_set[s][active_head]=1;else if(s==stopstage)dominated_set[s][active_head]=1;else unreachable_set[s][active_head]=1;end
   if(h_check_sm_status==1)begin candidate_valid[2]=1;candidate_tuple[2]=tuple(stopstage,active_head,int'(h_check_sm_rank[22:16]),int'(h_check_sm_rank[6:0]),0,0,0);unreachable_set[25][active_head]=1;for(int k=0;k<128;k++)av_unreachable_set[k*16+int'(active_head)]=1;end
  end
  if(state==L_HEAD&&res_fp_rsp_phase==4&&res_fp_add_rsp_valid[0]&&res_fp_add_rsp_ready[0])begin
   for(int q=0;q<4;q++)for(int c=0;c<64;c++)if(res_fp_add_rsp_data[q*64+c][30:23]==8'hff)offer(tuple(25,int'(res_fp_add_rsp_tag[0][11:5]),active_head,int'(res_fp_add_rsp_tag[0][4:0])*4+q,c,0,0),candidate_valid[3],candidate_tuple[3]);
   if((av_groups|(32'b1<<res_fp_add_rsp_tag[0][4:0]))==32'hffffffff)av_complete_set[int'(res_fp_add_rsp_tag[0][11:5])*16+int'(active_head)]=1;
  end
  if(h_check_av_done&&h_check_av_status<=1)complete_set[25][active_head]=1;
  if(head_retire&&state==L_HEAD&&(h_done_status>1||aborted))begin
   for(int s=11;s<26;s++)for(int h=0;h<16;h++)if(h>=int'(active_head)&&!check_completed[s][h]&&!check_unreachable[s][h]&&!check_dominated[s][h])unreachable_set[s][h]=1;
   for(int k=0;k<128;k++)for(int h=0;h<16;h++)if(h>=int'(active_head)&&!av_check_completed[k*16+h])av_unreachable_set[k*16+h]=1;
  end
 end
 always_ff@(posedge clk)begin
  if(!rst_n)begin state<=L_IDLE;request_id<=0;model_id<=0;generation<=0;epoch<=0;numeric_id<=0;table_key<=0;kind<=0;layer_index<=0;mask<=0;qkv_coverage<=0;aborted<=0;protocol_bad<=0;public_read_owned<=0;qkv_complete<=0;context_discarded<=0;context_release_cycles<=0;head_completed<=0;head_context_valid<=0;active_head<=0;clock_count<=0;start_stamp<=0;done_cycles<=0;rope_cycles<=0;av_groups<=0;av_key<=0;end
  else begin
   clock_count<=clock_count+1;
   if(prepare_valid&&prepare_ready&&prepare_kind!=3)begin
    state<=L_PREP;request_id<=prepare_request_id;model_id<=prepare_model_id;generation<=prepare_generation;epoch<=prepare_epoch;numeric_id<=prepare_numeric_id;table_key<=prepare_table_key;kind<=prepare_kind;layer_index<=prepare_layer;mask<=prepare_mask;qkv_coverage<=0;qkv_complete<=0;context_discarded<=0;context_release_cycles<=0;aborted<=0;protocol_bad<=0;head_completed<=0;head_context_valid<=0;active_head<=0;done_cycles<=0;rope_cycles<=0;av_groups<=0;av_key<=0;
   end
   if(qkv_wr_valid&&qkv_wr_ready)qkv_coverage[((int'(qkv_wr_head)*3+int'(qkv_wr_plane))*128+int'(qkv_wr_token))*2+int'(qkv_wr_half)]<=1;
   if(layer_start)begin qkv_complete<=1;qkv_coverage[4095:0]<=0;start_stamp<=clock_count;if(error_valid)begin state<=L_DONE;done_cycles<=1;context_discarded<=1;end else state<=kind==2?L_HPREP:L_RSTART;end
   if(abort_valid&&abort_ready)aborted<=1;
   if(coverage_fault)begin protocol_bad<=1;if(state==L_HPREP||state==L_RSTART)state<=L_WAIT;end
   if(cancel_fire)begin state<=L_CANCEL;qkv_coverage<=0;qkv_complete<=0;end
   if(state==L_CANCEL&&prepare_cancel_rsp_ready)state<=L_IDLE;
   if(state==L_RSTART&&r_start_valid&&r_start_ready)state<=L_ROPE;
   if(state==L_ROPE&&r_done_valid)begin rope_cycles<=r_done_cycles;if(r_done_status!=0||aborted)begin state<=L_WAIT;if(r_done_status==3)protocol_bad<=1;if(r_done_status==2)aborted<=1;end else state<=L_HPREP;end
   if(state==L_HPREP&&h_prepare_valid&&h_prepare_ready)state<=L_HRES;
   if(state==L_HRES&&h_resident_valid&&h_resident_ready)state<=L_HSTART;
   if(state==L_HSTART&&h_start_valid&&h_start_ready)begin state<=L_HEAD;av_groups<=0;av_key<=0;end
   if(state==L_HEAD&&res_fp_rsp_phase==4&&res_fp_add_rsp_valid[0]&&res_fp_add_rsp_ready[0])begin
    if(res_fp_add_rsp_tag[0][11:5]!=av_key||av_groups[res_fp_add_rsp_tag[0][4:0]])protocol_bad<=1;
    if((av_groups|(32'b1<<res_fp_add_rsp_tag[0][4:0]))==32'hffffffff)begin av_groups<=0;av_key<=av_key+1;end else av_groups<=av_groups|(32'b1<<res_fp_add_rsp_tag[0][4:0]);
   end
   if(head_retire)begin if(state==L_HEAD)head_completed[active_head]<=1;if(state==L_HEAD&&h_done_status==0)head_context_valid[active_head]<=1;if(h_done_status==3)protocol_bad<=1;if(h_done_status==2)aborted<=1;state<=L_WAIT;end
   if(state==L_WAIT&&real_idle&&h_prepare_ready)begin
    if(aborted||protocol_bad||coverage_fault||(r_done_status!=0&&!head_completed[0])||active_head==15)begin if(check_ready||coverage_fault)begin state<=L_DONE;done_cycles<=clock_count-start_stamp+1;if(error_valid||aborted||protocol_bad||coverage_fault)context_discarded<=1;end end
    else begin active_head<=active_head+1;state<=L_HPREP;end
   end
   if(result_discard_valid&&result_discard_ready)context_discarded<=1;
   if(result_rsp_valid&&result_rsp_ready)qkv_coverage[res_st_context_rd_rsp_tag[43:32]]<=1;
   if(public_read_fire)public_read_owned<=1;
   else if(result_rsp_valid&&result_rsp_ready)public_read_owned<=0;
   if(done_valid&&done_ready)state<=L_RELEASE;
   if(state==L_RELEASE&&real_idle&&h_prepare_ready&&(done_status!=0||context_discarded||(&output_consumed)))begin state<=L_IDLE;context_release_cycles<=clock_count-start_stamp+1;end
  end
 end
endmodule
