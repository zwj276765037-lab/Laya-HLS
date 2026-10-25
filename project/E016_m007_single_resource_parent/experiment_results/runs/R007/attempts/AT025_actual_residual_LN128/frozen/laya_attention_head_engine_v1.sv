`timescale 1ns/1ps
// One production head command, no score/prob prep or normal phase reset.
// Pure engines share exactly one physical instance of each declared service.
module laya_attention_head_engine_v1 #(parameter bit RESIDENT_ONLY=0)(
 input logic clk,rst_n,
 input logic prepare_valid,output logic prepare_ready,input logic[63:0]prepare_request_id,input logic[31:0]prepare_generation,prepare_epoch,input logic[3:0]prepare_head,input logic prepare_sliding,input logic[127:0]prepare_mask,
 input logic qkv_wr_valid,output logic qkv_wr_ready,input logic[31:0]qkv_wr_generation,input logic[1:0]qkv_wr_plane,input logic[6:0]qkv_wr_token,input logic qkv_wr_half,input logic[31:0][31:0]qkv_wr_data,
 input logic start_valid,output logic start_ready,input logic[63:0]start_request_id,input logic[31:0]start_generation,
 input logic abort_valid,output logic abort_ready,input logic[2:0]qkv_read_grant,input logic ps_grant,g_grant,context_grant,fp_grant,sfu_grant,exp_grant,div_grant,
 output logic done_valid,input logic done_ready,output logic[63:0]done_request_id,output logic[31:0]done_generation,output logic[3:0]done_head,output logic[7:0]done_status,
 output logic[31:0]done_cycles,qk_cycles,softmax_cycles,av_cycles,first_score_cycle,first_context_cycle,max_feedback_cycles,first_row_cycle,max_sum_tail,max_row_launch_gap,
 output logic error_valid,output logic[63:0]error_rank,output logic[4:0]error_phase,output logic[31:0]error_element,output logic[127:0][31:0]maximum,
 input logic result_rd_valid,output logic result_rd_ready,input logic[31:0]result_rd_generation,result_rd_tag,input logic[6:0]result_rd_query,input logic result_rd_half,
 output logic result_rsp_valid,input logic result_rsp_ready,output logic[31:0]result_rsp_tag,output logic[31:0][31:0]result_rsp_data
,
 output logic check_qk_done,check_sm_done,check_av_done,output logic[7:0]check_qk_status,check_sm_status,check_av_status,output logic[63:0]check_qk_rank,check_sm_rank,output logic[4:0]check_qk_phase,check_sm_phase,
 input logic resident_valid,output logic resident_ready,input logic[63:0]resident_request_id,input logic[31:0]resident_generation,resident_epoch,input logic[3:0]resident_head,
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
 input logic res_scale_fault);
 localparam H_IDLE=0,H_PREP=1,H_QK=2,H_WAIT_QK=3,H_BIND_SM=4,H_CLAIM_SM=5,H_START_SM=6,H_SM=7,H_RELEASE_SM=8,H_BIND_AV=9,H_RESUME_AV=10,H_AV=11,H_DONE=12,H_RELEASE=13,H_PREP_ABORT=14;
 logic[3:0]state;logic[1:0]owner;logic[63:0]request_id;logic[31:0]generation,epoch,clock_count,start_stamp;logic[3:0]head;
 logic engine_idle,continue_av_ready,fp_owned,sfu_owned,div_owned,storage_idle,ln_idle,fp_fault,sfu_fault,div_fault,sfu_reject,div_reject;
 logic fp_lease_ready,sfu_lease_ready,div_lease_ready,sfu_ready_raw,div_ready_raw;logic[8:0]sfu_pending,sfu_inflight,div_scalars;logic[5:0]div_pending,div_inflight;
 logic[6:0]mul_pending;logic[6:0][6:0]add_pending;
 wire select_sm=(state>=H_BIND_SM&&state<=H_RELEASE_SM)||((state==H_DONE||state==H_RELEASE)&&owner==1);
 wire all_lease_ready=fp_lease_ready&&sfu_lease_ready&&div_lease_ready;
 wire sm_lease_fire=state==H_CLAIM_SM&&all_lease_ready;
 wire sm_release=state==H_RELEASE_SM||(state==H_RELEASE&&owner==1);
 wire sm_local_idle=storage_idle&&ln_idle;
 wire[2:0]phase=select_sm?3'd3:((state>=H_BIND_AV&&state<=H_AV)||((state==H_DONE||state==H_RELEASE)&&owner==2))?3'd4:3'd2;
 logic  sm_start_valid;
 logic  sm_start_ready;
 logic [63:0] sm_start_request_id;
 logic [31:0] sm_start_generation;
 logic [31:0] sm_start_epoch;
 logic [3:0] sm_start_head;
 logic  sm_abort_valid;
 logic  sm_abort_ready;
 logic  sm_done_valid;
 logic  sm_done_ready;
 logic [7:0] sm_done_status;
 logic [31:0] sm_done_cycles;
 logic [31:0] sm_first_row_cycle;
 logic [31:0] sm_max_sum_tail;
 logic [31:0] sm_max_row_launch_gap;
 logic [7:0] sm_rows_launched;
 logic [7:0] sm_rows_retired;
 logic [11:0] sm_probability_commits;
 logic  sm_error_valid;
 logic [63:0] sm_error_rank;
 logic [4:0] sm_error_phase;
 logic [6:0] sm_error_row;
 logic [6:0] sm_error_node;
 logic [31:0] sm_error_element;
 logic [63:0] sm_context_valid;
 logic [63:0] sm_context_row_hi;
 logic  sm_resource_debt_clear;
 logic  sm_resource_fault;
 logic  sm_score_rd_valid;
 logic  sm_score_rd_ready;
 logic [10:0] sm_score_rd_tag;
 logic  sm_score_rsp_valid;
 logic  sm_score_rsp_ready;
 logic [10:0] sm_score_rsp_tag;
 logic [7:0][31:0] sm_score_rsp_data;
 logic  sm_fp_req_valid;
 logic  sm_fp_req_ready;
 logic [95:0] sm_fp_req_tag;
 logic [255:0][31:0] sm_fp_a;
 logic [255:0][31:0] sm_fp_b;
 logic  sm_fp_rsp_valid;
 logic  sm_fp_rsp_ready;
 logic [95:0] sm_fp_rsp_tag;
 logic [255:0][31:0] sm_fp_rsp_data;
 logic  sm_sfu_req_valid;
 logic  sm_sfu_req_ready;
 logic [10:0] sm_sfu_req_tag;
 logic [7:0][31:0] sm_sfu_req_x;
 logic  sm_sfu_rsp_valid;
 logic  sm_sfu_rsp_ready;
 logic [10:0] sm_sfu_rsp_tag;
 logic [7:0][31:0] sm_sfu_rsp_data;
 logic  sm_exp_wr_valid;
 logic  sm_exp_wr_ready;
 logic [10:0] sm_exp_wr_tag;
 logic [7:0][31:0] sm_exp_wr_data;
 logic  sm_exp_wr_ack_valid;
 logic  sm_exp_wr_ack_ready;
 logic [10:0] sm_exp_wr_ack_tag;
 logic  sm_exp_rd_valid;
 logic  sm_exp_rd_ready;
 logic [10:0] sm_exp_rd_tag;
 logic  sm_exp_rsp_valid;
 logic  sm_exp_rsp_ready;
 logic [10:0] sm_exp_rsp_tag;
 logic [7:0][31:0] sm_exp_rsp_data;
 logic  sm_div_req_valid;
 logic  sm_div_req_ready;
 logic [95:0] sm_div_req_tag;
 logic [7:0][31:0] sm_div_a;
 logic [7:0][31:0] sm_div_b;
 logic  sm_div_rsp_valid;
 logic  sm_div_rsp_ready;
 logic [95:0] sm_div_rsp_tag;
 logic [7:0][31:0] sm_div_rsp_data;
 logic [7:0] sm_div_rsp_error;
 logic  sm_prob_wr_valid;
 logic  sm_prob_wr_ready;
 logic [10:0] sm_prob_wr_tag;
 logic [7:0][31:0] sm_prob_wr_data;
 logic  sm_prob_wr_ack_valid;
 logic  sm_prob_wr_ack_ready;
 logic [10:0] sm_prob_wr_ack_tag;
 logic  q_prepare_ready;
 logic  q_start_ready;
 logic  q_abort_ready;
 logic  q_done_valid;
 logic [63:0] q_done_request_id;
 logic [31:0] q_done_generation;
 logic [3:0] q_done_head;
 logic  q_done_av;
 logic [7:0] q_done_status;
 logic [31:0] q_done_cycles;
 logic [31:0] q_first_score_cycle;
 logic [31:0] q_first_context_cycle;
 logic [31:0] q_max_feedback_cycles;
 logic  q_error_valid;
 logic [63:0] q_error_rank;
 logic [4:0] q_error_phase;
 logic [3:0] q_error_tile;
 logic [31:0] q_error_element;
 logic [12:0] q_root_accepted;
 logic [12:0] q_score_commits;
 logic [12:0] q_partial_commits;
 logic [8:0] q_context_commits;
 logic  q_res_qkv_wr_valid;
 logic  q_res_qkv_wr_ready;
 logic [1:0] q_res_qkv_wr_plane;
 logic [3:0] q_res_qkv_wr_head;
 logic [6:0] q_res_qkv_wr_token;
 logic  q_res_qkv_wr_half;
 logic [31:0][31:0] q_res_qkv_wr_data;
 logic [2:0] q_res_qkv_rd_valid;
 logic [2:0] q_res_qkv_rd_ready;
 logic [2:0][3:0] q_res_qkv_rd_head;
 logic [2:0][6:0] q_res_qkv_rd_token;
 logic [2:0][31:0] q_res_qkv_rd_tag;
 logic [2:0] q_res_qkv_rd_rsp_valid;
 logic [2:0] q_res_qkv_rd_rsp_ready;
 logic [2:0][3:0] q_res_qkv_rd_rsp_head;
 logic [2:0][6:0] q_res_qkv_rd_rsp_token;
 logic [2:0][31:0] q_res_qkv_rd_rsp_tag;
 logic [2:0][63:0][31:0] q_res_qkv_rd_rsp_data;
 logic  q_res_st_bind_valid;
 logic  q_res_st_bind_ready;
 logic [63:0] q_res_st_bind_request_id;
 logic [31:0] q_res_st_bind_generation;
 logic [31:0] q_res_st_bind_epoch;
 logic [3:0] q_res_st_bind_head;
 logic [2:0] q_res_st_bind_phase;
 logic [63:0] q_res_st_op_request_id;
 logic [31:0] q_res_st_op_generation;
 logic [31:0] q_res_st_op_epoch;
 logic [2:0] q_res_st_op_phase;
 logic [63:0] q_res_st_rsp_request_id;
 logic [31:0] q_res_st_rsp_generation;
 logic [31:0] q_res_st_rsp_epoch;
 logic [3:0] q_res_st_rsp_head;
 logic [2:0] q_res_st_rsp_phase;
 logic  q_res_st_ps_wr_valid;
 logic  q_res_st_ps_wr_ready;
 logic [1023:0] q_res_st_ps_wr_mask;
 logic [1023:0][3:0] q_res_st_ps_wr_addr;
 logic [1023:0][31:0] q_res_st_ps_wr_data;
 logic [95:0] q_res_st_ps_wr_tag;
 logic  q_res_st_ps_wr_rsp_valid;
 logic  q_res_st_ps_wr_rsp_ready;
 logic [95:0] q_res_st_ps_wr_rsp_tag;
 logic  q_res_st_ps_rd_valid;
 logic  q_res_st_ps_rd_ready;
 logic [1023:0] q_res_st_ps_rd_mask;
 logic [1023:0][3:0] q_res_st_ps_rd_addr;
 logic [95:0] q_res_st_ps_rd_tag;
 logic  q_res_st_ps_rd_rsp_valid;
 logic  q_res_st_ps_rd_rsp_ready;
 logic [1023:0][31:0] q_res_st_ps_rd_rsp_data;
 logic [1023:0] q_res_st_ps_rd_rsp_mask;
 logic [95:0] q_res_st_ps_rd_rsp_tag;
 logic  q_res_st_g_wr_valid;
 logic  q_res_st_g_wr_ready;
 logic [255:0] q_res_st_g_wr_mask;
 logic [255:0][5:0] q_res_st_g_wr_addr;
 logic [255:0][31:0] q_res_st_g_wr_data;
 logic [95:0] q_res_st_g_wr_tag;
 logic  q_res_st_g_wr_rsp_valid;
 logic  q_res_st_g_wr_rsp_ready;
 logic [95:0] q_res_st_g_wr_rsp_tag;
 logic  q_res_st_g_rd_valid;
 logic  q_res_st_g_rd_ready;
 logic [255:0] q_res_st_g_rd_mask;
 logic [255:0][5:0] q_res_st_g_rd_addr;
 logic [95:0] q_res_st_g_rd_tag;
 logic  q_res_st_g_rd_rsp_valid;
 logic  q_res_st_g_rd_rsp_ready;
 logic [255:0][31:0] q_res_st_g_rd_rsp_data;
 logic [255:0] q_res_st_g_rd_rsp_mask;
 logic [95:0] q_res_st_g_rd_rsp_tag;
 logic  q_res_st_context_wr_valid;
 logic  q_res_st_context_wr_ready;
 logic [63:0] q_res_st_context_wr_mask;
 logic [63:0][10:0] q_res_st_context_wr_addr;
 logic [63:0][31:0] q_res_st_context_wr_data;
 logic [95:0] q_res_st_context_wr_tag;
 logic  q_res_st_context_wr_rsp_valid;
 logic  q_res_st_context_wr_rsp_ready;
 logic [95:0] q_res_st_context_wr_rsp_tag;
 logic  q_res_st_context_rd_valid;
 logic  q_res_st_context_rd_ready;
 logic [63:0] q_res_st_context_rd_mask;
 logic [63:0][10:0] q_res_st_context_rd_addr;
 logic [95:0] q_res_st_context_rd_tag;
 logic  q_res_st_context_rd_rsp_valid;
 logic  q_res_st_context_rd_rsp_ready;
 logic [63:0][31:0] q_res_st_context_rd_rsp_data;
 logic [63:0] q_res_st_context_rd_rsp_mask;
 logic [95:0] q_res_st_context_rd_rsp_tag;
 logic  q_res_st_idle;
 logic  q_res_fp_lease_valid;
 logic  q_res_fp_lease_ready;
 logic [63:0] q_res_fp_lease_request_id;
 logic [31:0] q_res_fp_lease_generation;
 logic [31:0] q_res_fp_lease_epoch;
 logic [3:0] q_res_fp_lease_head;
 logic [2:0] q_res_fp_lease_phase;
 logic  q_res_fp_release_valid;
 logic  q_res_fp_release_ready;
 logic [2:0] q_res_fp_release_phase;
 logic [31:0] q_res_fp_release_epoch;
 logic  q_res_fp_phase_debt_clear;
 logic  q_res_fp_lease_active;
 logic  q_res_fp_draining;
 logic [63:0] q_res_fp_rsp_request_id;
 logic [31:0] q_res_fp_rsp_generation;
 logic [31:0] q_res_fp_rsp_epoch;
 logic [3:0] q_res_fp_rsp_head;
 logic [2:0] q_res_fp_rsp_phase;
 logic  q_res_fp_mul_req_valid;
 logic  q_res_fp_mul_req_ready;
 logic [2:0] q_res_fp_mul_req_phase;
 logic [31:0] q_res_fp_mul_req_epoch;
 logic [95:0] q_res_fp_mul_req_tag;
 logic [256-1:0][31:0] q_res_fp_mul_a;
 logic [256-1:0][31:0] q_res_fp_mul_b;
 logic  q_res_fp_mul_rsp_valid;
 logic  q_res_fp_mul_rsp_ready;
 logic [95:0] q_res_fp_mul_rsp_tag;
 logic [256-1:0][31:0] q_res_fp_mul_rsp_data;
 logic [7-1:0] q_res_fp_add_req_valid;
 logic [7-1:0] q_res_fp_add_req_is_root;
 logic [7-1:0] q_res_fp_add_req_ready;
 logic [7-1:0][2:0] q_res_fp_add_req_phase;
 logic [7-1:0][31:0] q_res_fp_add_req_epoch;
 logic [7-1:0][95:0] q_res_fp_add_req_tag;
 logic [256-1:0][31:0] q_res_fp_add_a;
 logic [256-1:0][31:0] q_res_fp_add_b;
 logic [7-1:0] q_res_fp_add_rsp_valid;
 logic [7-1:0] q_res_fp_add_rsp_ready;
 logic [7-1:0][95:0] q_res_fp_add_rsp_tag;
 logic [256-1:0][31:0] q_res_fp_add_rsp_data;
 logic [6:0] q_res_fp_mul_pending;
 logic [7-1:0][6:0] q_res_fp_add_pending;
 logic  q_res_fp_protocol_fault;
 logic  q_res_scale_valid;
 logic  q_res_scale_ready;
 logic [95:0] q_res_scale_tag;
 logic [3:0][31:0] q_res_scale_input;
 logic  q_res_scale_rsp_valid;
 logic  q_res_scale_rsp_ready;
 logic [95:0] q_res_scale_rsp_tag;
 logic [3:0][31:0] q_res_scale_data;
 logic [6:0] q_res_scale_pending;
 logic  q_res_scale_fault;
 logic  p_qkv_wr_valid;
 logic  p_qkv_wr_ready;
 logic [1:0] p_qkv_wr_plane;
 logic [3:0] p_qkv_wr_head;
 logic [6:0] p_qkv_wr_token;
 logic  p_qkv_wr_half;
 logic [31:0][31:0] p_qkv_wr_data;
 logic [2:0] p_qkv_rd_valid;
 logic [2:0] p_qkv_rd_ready;
 logic [2:0][3:0] p_qkv_rd_head;
 logic [2:0][6:0] p_qkv_rd_token;
 logic [2:0][31:0] p_qkv_rd_tag;
 logic [2:0] p_qkv_rd_rsp_valid;
 logic [2:0] p_qkv_rd_rsp_ready;
 logic [2:0][3:0] p_qkv_rd_rsp_head;
 logic [2:0][6:0] p_qkv_rd_rsp_token;
 logic [2:0][31:0] p_qkv_rd_rsp_tag;
 logic [2:0][63:0][31:0] p_qkv_rd_rsp_data;
 logic  p_st_bind_valid;
 logic  p_st_bind_ready;
 logic [63:0] p_st_bind_request_id;
 logic [31:0] p_st_bind_generation;
 logic [31:0] p_st_bind_epoch;
 logic [3:0] p_st_bind_head;
 logic [2:0] p_st_bind_phase;
 logic [63:0] p_st_op_request_id;
 logic [31:0] p_st_op_generation;
 logic [31:0] p_st_op_epoch;
 logic [2:0] p_st_op_phase;
 logic [63:0] p_st_rsp_request_id;
 logic [31:0] p_st_rsp_generation;
 logic [31:0] p_st_rsp_epoch;
 logic [3:0] p_st_rsp_head;
 logic [2:0] p_st_rsp_phase;
 logic  p_st_ps_wr_valid;
 logic  sm_st_ps_wr_valid;
 logic  p_st_ps_wr_ready;
 logic [1023:0] p_st_ps_wr_mask;
 logic [1023:0] sm_st_ps_wr_mask;
 logic [1023:0][3:0] p_st_ps_wr_addr;
 logic [1023:0][3:0] sm_st_ps_wr_addr;
 logic [1023:0][31:0] p_st_ps_wr_data;
 logic [1023:0][31:0] sm_st_ps_wr_data;
 logic [95:0] p_st_ps_wr_tag;
 logic [95:0] sm_st_ps_wr_tag;
 logic  p_st_ps_wr_rsp_valid;
 logic  p_st_ps_wr_rsp_ready;
 logic  sm_st_ps_wr_rsp_ready;
 logic [95:0] p_st_ps_wr_rsp_tag;
 logic  p_st_ps_rd_valid;
 logic  sm_st_ps_rd_valid;
 logic  p_st_ps_rd_ready;
 logic [1023:0] p_st_ps_rd_mask;
 logic [1023:0] sm_st_ps_rd_mask;
 logic [1023:0][3:0] p_st_ps_rd_addr;
 logic [1023:0][3:0] sm_st_ps_rd_addr;
 logic [95:0] p_st_ps_rd_tag;
 logic [95:0] sm_st_ps_rd_tag;
 logic  p_st_ps_rd_rsp_valid;
 logic  p_st_ps_rd_rsp_ready;
 logic  sm_st_ps_rd_rsp_ready;
 logic [1023:0][31:0] p_st_ps_rd_rsp_data;
 logic [1023:0] p_st_ps_rd_rsp_mask;
 logic [95:0] p_st_ps_rd_rsp_tag;
 logic  p_st_g_wr_valid;
 logic  sm_st_g_wr_valid;
 logic  p_st_g_wr_ready;
 logic [255:0] p_st_g_wr_mask;
 logic [255:0] sm_st_g_wr_mask;
 logic [255:0][5:0] p_st_g_wr_addr;
 logic [255:0][5:0] sm_st_g_wr_addr;
 logic [255:0][31:0] p_st_g_wr_data;
 logic [255:0][31:0] sm_st_g_wr_data;
 logic [95:0] p_st_g_wr_tag;
 logic [95:0] sm_st_g_wr_tag;
 logic  p_st_g_wr_rsp_valid;
 logic  p_st_g_wr_rsp_ready;
 logic  sm_st_g_wr_rsp_ready;
 logic [95:0] p_st_g_wr_rsp_tag;
 logic  p_st_g_rd_valid;
 logic  sm_st_g_rd_valid;
 logic  p_st_g_rd_ready;
 logic [255:0] p_st_g_rd_mask;
 logic [255:0] sm_st_g_rd_mask;
 logic [255:0][5:0] p_st_g_rd_addr;
 logic [255:0][5:0] sm_st_g_rd_addr;
 logic [95:0] p_st_g_rd_tag;
 logic [95:0] sm_st_g_rd_tag;
 logic  p_st_g_rd_rsp_valid;
 logic  p_st_g_rd_rsp_ready;
 logic  sm_st_g_rd_rsp_ready;
 logic [255:0][31:0] p_st_g_rd_rsp_data;
 logic [255:0] p_st_g_rd_rsp_mask;
 logic [95:0] p_st_g_rd_rsp_tag;
 logic  p_st_context_wr_valid;
 logic  sm_st_context_wr_valid;
 logic  p_st_context_wr_ready;
 logic [63:0] p_st_context_wr_mask;
 logic [63:0] sm_st_context_wr_mask;
 logic [63:0][10:0] p_st_context_wr_addr;
 logic [63:0][10:0] sm_st_context_wr_addr;
 logic [63:0][31:0] p_st_context_wr_data;
 logic [63:0][31:0] sm_st_context_wr_data;
 logic [95:0] p_st_context_wr_tag;
 logic [95:0] sm_st_context_wr_tag;
 logic  p_st_context_wr_rsp_valid;
 logic  p_st_context_wr_rsp_ready;
 logic  sm_st_context_wr_rsp_ready;
 logic [95:0] p_st_context_wr_rsp_tag;
 logic  p_st_context_rd_valid;
 logic  sm_st_context_rd_valid;
 logic  p_st_context_rd_ready;
 logic [63:0] p_st_context_rd_mask;
 logic [63:0] sm_st_context_rd_mask;
 logic [63:0][10:0] p_st_context_rd_addr;
 logic [63:0][10:0] sm_st_context_rd_addr;
 logic [95:0] p_st_context_rd_tag;
 logic [95:0] sm_st_context_rd_tag;
 logic  p_st_context_rd_rsp_valid;
 logic  p_st_context_rd_rsp_ready;
 logic  sm_st_context_rd_rsp_ready;
 logic [63:0][31:0] p_st_context_rd_rsp_data;
 logic [63:0] p_st_context_rd_rsp_mask;
 logic [95:0] p_st_context_rd_rsp_tag;
 logic  p_st_idle;
 logic  p_fp_lease_valid;
 logic  p_fp_lease_ready;
 logic [63:0] p_fp_lease_request_id;
 logic [31:0] p_fp_lease_generation;
 logic [31:0] p_fp_lease_epoch;
 logic [3:0] p_fp_lease_head;
 logic [2:0] p_fp_lease_phase;
 logic  p_fp_release_valid;
 logic  p_fp_release_ready;
 logic [2:0] p_fp_release_phase;
 logic [31:0] p_fp_release_epoch;
 logic  p_fp_phase_debt_clear;
 logic  p_fp_lease_active;
 logic  p_fp_draining;
 logic [63:0] p_fp_rsp_request_id;
 logic [31:0] p_fp_rsp_generation;
 logic [31:0] p_fp_rsp_epoch;
 logic [3:0] p_fp_rsp_head;
 logic [2:0] p_fp_rsp_phase;
 logic  p_fp_mul_req_valid;
 logic  p_fp_mul_req_ready;
 logic [2:0] p_fp_mul_req_phase;
 logic [31:0] p_fp_mul_req_epoch;
 logic [95:0] p_fp_mul_req_tag;
 logic [256-1:0][31:0] p_fp_mul_a;
 logic [256-1:0][31:0] p_fp_mul_b;
 logic  p_fp_mul_rsp_valid;
 logic  p_fp_mul_rsp_ready;
 logic [95:0] p_fp_mul_rsp_tag;
 logic [256-1:0][31:0] p_fp_mul_rsp_data;
 logic [7-1:0] p_fp_add_req_valid;
 logic [7-1:0] p_fp_add_req_is_root;
 logic [7-1:0] p_fp_add_req_ready;
 logic [7-1:0][2:0] p_fp_add_req_phase;
 logic [7-1:0][31:0] p_fp_add_req_epoch;
 logic [7-1:0][95:0] p_fp_add_req_tag;
 logic [256-1:0][31:0] p_fp_add_a;
 logic [256-1:0][31:0] p_fp_add_b;
 logic [7-1:0] p_fp_add_rsp_valid;
 logic [7-1:0] p_fp_add_rsp_ready;
 logic [7-1:0][95:0] p_fp_add_rsp_tag;
 logic [256-1:0][31:0] p_fp_add_rsp_data;
 logic [6:0] p_fp_mul_pending;
 logic [7-1:0][6:0] p_fp_add_pending;
 logic  p_fp_protocol_fault;
 logic  p_ln_bind_valid;
 logic  p_ln_bind_ready;
 logic [63:0] p_ln_bind_request_id;
 logic [31:0] p_ln_bind_generation;
 logic [31:0] p_ln_bind_epoch;
 logic [3:0] p_ln_bind_head;
 logic [2:0] p_ln_bind_phase;
 logic [63:0] p_ln_op_request_id;
 logic [31:0] p_ln_op_generation;
 logic [31:0] p_ln_op_epoch;
 logic [2:0] p_ln_op_phase;
 logic [63:0] p_ln_rsp_request_id;
 logic [31:0] p_ln_rsp_generation;
 logic [31:0] p_ln_rsp_epoch;
 logic [3:0] p_ln_rsp_head;
 logic [2:0] p_ln_rsp_phase;
 logic  p_ln_wr_valid;
 logic  sm_ln_wr_valid;
 logic  p_ln_wr_ready;
 logic [255:0] p_ln_wr_mask;
 logic [255:0] sm_ln_wr_mask;
 logic [255:0][4:0] p_ln_wr_addr;
 logic [255:0][4:0] sm_ln_wr_addr;
 logic [255:0][31:0] p_ln_wr_data;
 logic [255:0][31:0] sm_ln_wr_data;
 logic [95:0] p_ln_wr_tag;
 logic [95:0] sm_ln_wr_tag;
 logic  p_ln_wr_rsp_valid;
 logic  p_ln_wr_rsp_ready;
 logic  sm_ln_wr_rsp_ready;
 logic [95:0] p_ln_wr_rsp_tag;
 logic  p_ln_rd_valid;
 logic  sm_ln_rd_valid;
 logic  p_ln_rd_ready;
 logic [255:0] p_ln_rd_mask;
 logic [255:0] sm_ln_rd_mask;
 logic [255:0][4:0] p_ln_rd_addr;
 logic [255:0][4:0] sm_ln_rd_addr;
 logic [95:0] p_ln_rd_tag;
 logic [95:0] sm_ln_rd_tag;
 logic  p_ln_rd_rsp_valid;
 logic  p_ln_rd_rsp_ready;
 logic  sm_ln_rd_rsp_ready;
 logic [255:0][31:0] p_ln_rd_rsp_data;
 logic [255:0] p_ln_rd_rsp_mask;
 logic [95:0] p_ln_rd_rsp_tag;
 logic  p_ln_idle;

 assign check_qk_done=state==H_QK&&q_done_valid;assign check_sm_done=state==H_SM&&sm_done_valid;assign check_av_done=state==H_AV&&q_done_valid;
 assign check_qk_status=q_done_status;assign check_sm_status=sm_done_status;assign check_av_status=q_done_status;assign check_qk_rank=q_error_rank;assign check_sm_rank=sm_error_rank;assign check_qk_phase=q_error_phase;assign check_sm_phase=sm_error_phase;
 assign prepare_ready=state==H_IDLE&&q_prepare_ready&&!sfu_owned&&!div_owned;
 assign start_ready=state==H_PREP&&q_start_ready&&!(RESIDENT_ONLY&&abort_valid);
 assign abort_ready=state==H_SM?sm_abort_ready:((state==H_QK||state==H_AV||(RESIDENT_ONLY&&state==H_PREP))?q_abort_ready:1'b0);
 assign done_valid=state==H_DONE&&(owner==1?sm_done_valid:q_done_valid);
 assign done_status=owner==1?sm_done_status:q_done_status;
 assign done_request_id=request_id;assign done_generation=generation;assign done_head=head;
 assign error_valid=owner==1?sm_error_valid:q_error_valid;assign error_rank=owner==1?sm_error_rank:q_error_rank;assign error_phase=owner==1?sm_error_phase:q_error_phase;assign error_element=owner==1?sm_error_element:q_error_element;
 assign sm_start_valid=state==H_START_SM;assign sm_start_request_id=request_id;assign sm_start_generation=generation;assign sm_start_epoch=epoch;assign sm_start_head=head;
 assign sm_abort_valid=abort_valid&&state==H_SM;
 assign sm_done_ready=(state==H_SM&&sm_done_valid&&sm_done_status==0)||(state==H_DONE&&owner==1&&done_ready);
 assign sm_resource_debt_clear=sm_local_idle&&mul_pending==0&&add_pending==0&&sfu_pending==0&&div_pending==0;
 assign sm_resource_fault=fp_fault||sfu_fault||div_fault||sfu_reject||div_reject;
 always_ff @(posedge clk)begin
  if(!rst_n)begin state<=H_IDLE;owner<=0;request_id<=0;generation<=0;epoch<=0;head<=0;clock_count<=0;start_stamp<=0;done_cycles<=0;qk_cycles<=0;softmax_cycles<=0;av_cycles<=0;first_score_cycle<=0;first_context_cycle<=0;max_feedback_cycles<=0;first_row_cycle<=0;max_sum_tail<=0;max_row_launch_gap<=0;end
  else begin
   clock_count<=clock_count+1'b1;
   if(state==H_IDLE&&prepare_valid&&prepare_ready)begin state<=H_PREP;owner<=0;request_id<=prepare_request_id;generation<=prepare_generation;epoch<=prepare_epoch;head<=prepare_head;done_cycles<=0;qk_cycles<=0;softmax_cycles<=0;av_cycles<=0;end
   if(RESIDENT_ONLY&&state==H_PREP&&abort_valid&&abort_ready)state<=H_PREP_ABORT;
   if(state==H_PREP_ABORT&&q_done_valid)begin state<=H_DONE;done_cycles<=0;end
   if(state==H_PREP&&start_valid&&start_ready)begin state<=H_QK;start_stamp<=clock_count;end
   if(state==H_QK&&q_done_valid)begin qk_cycles<=q_done_cycles;first_score_cycle<=q_first_score_cycle;if(q_done_status==0)state<=H_WAIT_QK;else begin state<=H_DONE;done_cycles<=clock_count-start_stamp+1'b1;end end
   if(state==H_WAIT_QK&&engine_idle&&!fp_owned&&storage_idle)begin state<=H_BIND_SM;owner<=1;end
   if(state==H_BIND_SM&&p_st_bind_valid&&p_st_bind_ready&&p_ln_bind_ready)state<=H_CLAIM_SM;
   if(sm_lease_fire)state<=H_START_SM;
   if(state==H_START_SM&&sm_start_ready)state<=H_SM;
   if(state==H_SM&&sm_done_valid)begin
    softmax_cycles<=sm_done_cycles;first_row_cycle<=sm_first_row_cycle;max_sum_tail<=sm_max_sum_tail;max_row_launch_gap<=sm_max_row_launch_gap;
    if(sm_done_status==0)state<=H_RELEASE_SM;else begin state<=H_DONE;done_cycles<=clock_count-start_stamp+1'b1;end
   end
   if(state==H_RELEASE_SM&&!fp_owned&&!sfu_owned&&!div_owned&&sm_local_idle)begin state<=H_BIND_AV;owner<=2;end
   if(state==H_BIND_AV&&p_st_bind_valid&&p_st_bind_ready)state<=H_RESUME_AV;
   if(state==H_RESUME_AV&&continue_av_ready)state<=H_AV;
   if(state==H_AV&&q_done_valid)begin av_cycles<=q_done_cycles;first_context_cycle<=q_first_context_cycle;max_feedback_cycles<=q_max_feedback_cycles;done_cycles<=clock_count-start_stamp+1'b1;state<=H_DONE;end
   if(state==H_DONE&&done_valid&&done_ready)state<=H_RELEASE;
   if(state==H_RELEASE&&!fp_owned&&!sfu_owned&&!div_owned&&storage_idle&&ln_idle&&(owner==1||engine_idle))state<=H_IDLE;
  end
 end
 laya_attention_qk_av_engine_v1 #(.RESIDENT_ONLY(RESIDENT_ONLY)) qkav(.resident_valid,.resident_ready,.resident_request_id,.resident_generation,.resident_epoch,.resident_head,.clk(clk),.rst_n(rst_n),.prepare_valid(prepare_valid&&state==H_IDLE),.prepare_ready(q_prepare_ready),.prepare_request_id(prepare_request_id),.prepare_generation(prepare_generation),.prepare_epoch(prepare_epoch),.prepare_head(prepare_head),.prepare_av(1'b0),.prepare_sliding(prepare_sliding),.prepare_mask(prepare_mask),.qkv_wr_valid(qkv_wr_valid),.qkv_wr_ready(qkv_wr_ready),.qkv_wr_generation(qkv_wr_generation),.qkv_wr_plane(qkv_wr_plane),.qkv_wr_token(qkv_wr_token),.qkv_wr_half(qkv_wr_half),.qkv_wr_data(qkv_wr_data),.prob_wr_valid('0),.prob_wr_ready(),.prob_wr_generation('0),.prob_wr_query('0),.prob_wr_keybase('0),.prob_wr_data('0),.start_valid(start_valid&&state==H_PREP),.start_ready(q_start_ready),.start_request_id(start_request_id),.start_generation(start_generation),.abort_valid(abort_valid&&(state==H_QK||state==H_AV||(RESIDENT_ONLY&&state==H_PREP))),.abort_ready(q_abort_ready),.qkv_read_grant(qkv_read_grant),.ps_grant(ps_grant),.g_grant(g_grant),.context_grant(context_grant),.done_valid(q_done_valid),.done_ready((state==H_QK&&q_done_valid&&q_done_status==0)||(state==H_DONE&&done_ready&&owner!=1)),.done_request_id(q_done_request_id),.done_generation(q_done_generation),.done_head(q_done_head),.done_av(q_done_av),.done_status(q_done_status),.done_cycles(q_done_cycles),.first_score_cycle(q_first_score_cycle),.first_context_cycle(q_first_context_cycle),.max_feedback_cycles(q_max_feedback_cycles),.error_valid(q_error_valid),.error_rank(q_error_rank),.error_phase(q_error_phase),.error_tile(q_error_tile),.error_element(q_error_element),.root_accepted(q_root_accepted),.score_commits(q_score_commits),.partial_commits(q_partial_commits),.context_commits(q_context_commits),.maximum(maximum),.score_rd_valid('0),.score_rd_ready(),.score_rd_generation('0),.score_rd_tag('0),.score_rd_query('0),.score_rd_keybase('0),.score_rsp_valid(),.score_rsp_ready(1'b1),.score_rsp_tag(),.score_rsp_data(),.result_rd_valid(result_rd_valid&&state==H_DONE&&owner==2&&done_status==0),.result_rd_ready(result_rd_ready),.result_rd_generation(result_rd_generation),.result_rd_tag(result_rd_tag),.result_rd_query(result_rd_query),.result_rd_half(result_rd_half),.result_rsp_valid(result_rsp_valid),.result_rsp_ready(result_rsp_ready),.result_rsp_tag(result_rsp_tag),.result_rsp_data(result_rsp_data),.continue_av_valid(state==H_RESUME_AV),.continue_av_ready(continue_av_ready),.engine_idle(engine_idle),.res_qkv_wr_valid(q_res_qkv_wr_valid),.res_qkv_wr_ready(q_res_qkv_wr_ready),.res_qkv_wr_plane(q_res_qkv_wr_plane),.res_qkv_wr_head(q_res_qkv_wr_head),.res_qkv_wr_token(q_res_qkv_wr_token),.res_qkv_wr_half(q_res_qkv_wr_half),.res_qkv_wr_data(q_res_qkv_wr_data),.res_qkv_rd_valid(q_res_qkv_rd_valid),.res_qkv_rd_ready(q_res_qkv_rd_ready),.res_qkv_rd_head(q_res_qkv_rd_head),.res_qkv_rd_token(q_res_qkv_rd_token),.res_qkv_rd_tag(q_res_qkv_rd_tag),.res_qkv_rd_rsp_valid(q_res_qkv_rd_rsp_valid),.res_qkv_rd_rsp_ready(q_res_qkv_rd_rsp_ready),.res_qkv_rd_rsp_head(q_res_qkv_rd_rsp_head),.res_qkv_rd_rsp_token(q_res_qkv_rd_rsp_token),.res_qkv_rd_rsp_tag(q_res_qkv_rd_rsp_tag),.res_qkv_rd_rsp_data(q_res_qkv_rd_rsp_data),.res_st_bind_valid(q_res_st_bind_valid),.res_st_bind_ready(q_res_st_bind_ready),.res_st_bind_request_id(q_res_st_bind_request_id),.res_st_bind_generation(q_res_st_bind_generation),.res_st_bind_epoch(q_res_st_bind_epoch),.res_st_bind_head(q_res_st_bind_head),.res_st_bind_phase(q_res_st_bind_phase),.res_st_op_request_id(q_res_st_op_request_id),.res_st_op_generation(q_res_st_op_generation),.res_st_op_epoch(q_res_st_op_epoch),.res_st_op_phase(q_res_st_op_phase),.res_st_rsp_request_id(q_res_st_rsp_request_id),.res_st_rsp_generation(q_res_st_rsp_generation),.res_st_rsp_epoch(q_res_st_rsp_epoch),.res_st_rsp_head(q_res_st_rsp_head),.res_st_rsp_phase(q_res_st_rsp_phase),.res_st_ps_wr_valid(q_res_st_ps_wr_valid),.res_st_ps_wr_ready(q_res_st_ps_wr_ready),.res_st_ps_wr_mask(q_res_st_ps_wr_mask),.res_st_ps_wr_addr(q_res_st_ps_wr_addr),.res_st_ps_wr_data(q_res_st_ps_wr_data),.res_st_ps_wr_tag(q_res_st_ps_wr_tag),.res_st_ps_wr_rsp_valid(q_res_st_ps_wr_rsp_valid),.res_st_ps_wr_rsp_ready(q_res_st_ps_wr_rsp_ready),.res_st_ps_wr_rsp_tag(q_res_st_ps_wr_rsp_tag),.res_st_ps_rd_valid(q_res_st_ps_rd_valid),.res_st_ps_rd_ready(q_res_st_ps_rd_ready),.res_st_ps_rd_mask(q_res_st_ps_rd_mask),.res_st_ps_rd_addr(q_res_st_ps_rd_addr),.res_st_ps_rd_tag(q_res_st_ps_rd_tag),.res_st_ps_rd_rsp_valid(q_res_st_ps_rd_rsp_valid),.res_st_ps_rd_rsp_ready(q_res_st_ps_rd_rsp_ready),.res_st_ps_rd_rsp_data(q_res_st_ps_rd_rsp_data),.res_st_ps_rd_rsp_mask(q_res_st_ps_rd_rsp_mask),.res_st_ps_rd_rsp_tag(q_res_st_ps_rd_rsp_tag),.res_st_g_wr_valid(q_res_st_g_wr_valid),.res_st_g_wr_ready(q_res_st_g_wr_ready),.res_st_g_wr_mask(q_res_st_g_wr_mask),.res_st_g_wr_addr(q_res_st_g_wr_addr),.res_st_g_wr_data(q_res_st_g_wr_data),.res_st_g_wr_tag(q_res_st_g_wr_tag),.res_st_g_wr_rsp_valid(q_res_st_g_wr_rsp_valid),.res_st_g_wr_rsp_ready(q_res_st_g_wr_rsp_ready),.res_st_g_wr_rsp_tag(q_res_st_g_wr_rsp_tag),.res_st_g_rd_valid(q_res_st_g_rd_valid),.res_st_g_rd_ready(q_res_st_g_rd_ready),.res_st_g_rd_mask(q_res_st_g_rd_mask),.res_st_g_rd_addr(q_res_st_g_rd_addr),.res_st_g_rd_tag(q_res_st_g_rd_tag),.res_st_g_rd_rsp_valid(q_res_st_g_rd_rsp_valid),.res_st_g_rd_rsp_ready(q_res_st_g_rd_rsp_ready),.res_st_g_rd_rsp_data(q_res_st_g_rd_rsp_data),.res_st_g_rd_rsp_mask(q_res_st_g_rd_rsp_mask),.res_st_g_rd_rsp_tag(q_res_st_g_rd_rsp_tag),.res_st_context_wr_valid(q_res_st_context_wr_valid),.res_st_context_wr_ready(q_res_st_context_wr_ready),.res_st_context_wr_mask(q_res_st_context_wr_mask),.res_st_context_wr_addr(q_res_st_context_wr_addr),.res_st_context_wr_data(q_res_st_context_wr_data),.res_st_context_wr_tag(q_res_st_context_wr_tag),.res_st_context_wr_rsp_valid(q_res_st_context_wr_rsp_valid),.res_st_context_wr_rsp_ready(q_res_st_context_wr_rsp_ready),.res_st_context_wr_rsp_tag(q_res_st_context_wr_rsp_tag),.res_st_context_rd_valid(q_res_st_context_rd_valid),.res_st_context_rd_ready(q_res_st_context_rd_ready),.res_st_context_rd_mask(q_res_st_context_rd_mask),.res_st_context_rd_addr(q_res_st_context_rd_addr),.res_st_context_rd_tag(q_res_st_context_rd_tag),.res_st_context_rd_rsp_valid(q_res_st_context_rd_rsp_valid),.res_st_context_rd_rsp_ready(q_res_st_context_rd_rsp_ready),.res_st_context_rd_rsp_data(q_res_st_context_rd_rsp_data),.res_st_context_rd_rsp_mask(q_res_st_context_rd_rsp_mask),.res_st_context_rd_rsp_tag(q_res_st_context_rd_rsp_tag),.res_st_idle(q_res_st_idle),.res_fp_lease_valid(q_res_fp_lease_valid),.res_fp_lease_ready(q_res_fp_lease_ready),.res_fp_lease_request_id(q_res_fp_lease_request_id),.res_fp_lease_generation(q_res_fp_lease_generation),.res_fp_lease_epoch(q_res_fp_lease_epoch),.res_fp_lease_head(q_res_fp_lease_head),.res_fp_lease_phase(q_res_fp_lease_phase),.res_fp_release_valid(q_res_fp_release_valid),.res_fp_release_ready(q_res_fp_release_ready),.res_fp_release_phase(q_res_fp_release_phase),.res_fp_release_epoch(q_res_fp_release_epoch),.res_fp_phase_debt_clear(q_res_fp_phase_debt_clear),.res_fp_lease_active(q_res_fp_lease_active),.res_fp_draining(q_res_fp_draining),.res_fp_rsp_request_id(q_res_fp_rsp_request_id),.res_fp_rsp_generation(q_res_fp_rsp_generation),.res_fp_rsp_epoch(q_res_fp_rsp_epoch),.res_fp_rsp_head(q_res_fp_rsp_head),.res_fp_rsp_phase(q_res_fp_rsp_phase),.res_fp_mul_req_valid(q_res_fp_mul_req_valid),.res_fp_mul_req_ready(q_res_fp_mul_req_ready),.res_fp_mul_req_phase(q_res_fp_mul_req_phase),.res_fp_mul_req_epoch(q_res_fp_mul_req_epoch),.res_fp_mul_req_tag(q_res_fp_mul_req_tag),.res_fp_mul_a(q_res_fp_mul_a),.res_fp_mul_b(q_res_fp_mul_b),.res_fp_mul_rsp_valid(q_res_fp_mul_rsp_valid),.res_fp_mul_rsp_ready(q_res_fp_mul_rsp_ready),.res_fp_mul_rsp_tag(q_res_fp_mul_rsp_tag),.res_fp_mul_rsp_data(q_res_fp_mul_rsp_data),.res_fp_add_req_valid(q_res_fp_add_req_valid),.res_fp_add_req_is_root(q_res_fp_add_req_is_root),.res_fp_add_req_ready(q_res_fp_add_req_ready),.res_fp_add_req_phase(q_res_fp_add_req_phase),.res_fp_add_req_epoch(q_res_fp_add_req_epoch),.res_fp_add_req_tag(q_res_fp_add_req_tag),.res_fp_add_a(q_res_fp_add_a),.res_fp_add_b(q_res_fp_add_b),.res_fp_add_rsp_valid(q_res_fp_add_rsp_valid),.res_fp_add_rsp_ready(q_res_fp_add_rsp_ready),.res_fp_add_rsp_tag(q_res_fp_add_rsp_tag),.res_fp_add_rsp_data(q_res_fp_add_rsp_data),.res_fp_mul_pending(q_res_fp_mul_pending),.res_fp_add_pending(q_res_fp_add_pending),.res_fp_protocol_fault(q_res_fp_protocol_fault),.res_scale_valid(q_res_scale_valid),.res_scale_ready(q_res_scale_ready),.res_scale_tag(q_res_scale_tag),.res_scale_input(q_res_scale_input),.res_scale_rsp_valid(q_res_scale_rsp_valid),.res_scale_rsp_ready(q_res_scale_rsp_ready),.res_scale_rsp_tag(q_res_scale_rsp_tag),.res_scale_data(q_res_scale_data),.res_scale_pending(q_res_scale_pending),.res_scale_fault(q_res_scale_fault));
 laya_attention_softmax_engine_v1 softmax(.clk(clk),.rst_n(rst_n),.start_valid(sm_start_valid),.start_ready(sm_start_ready),.start_request_id(sm_start_request_id),.start_generation(sm_start_generation),.start_epoch(sm_start_epoch),.start_head(sm_start_head),.maximum(maximum),.abort_valid(sm_abort_valid),.abort_ready(sm_abort_ready),.done_valid(sm_done_valid),.done_ready(sm_done_ready),.done_status(sm_done_status),.done_cycles(sm_done_cycles),.first_row_cycle(sm_first_row_cycle),.max_sum_tail(sm_max_sum_tail),.max_row_launch_gap(sm_max_row_launch_gap),.rows_launched(sm_rows_launched),.rows_retired(sm_rows_retired),.probability_commits(sm_probability_commits),.error_valid(sm_error_valid),.error_rank(sm_error_rank),.error_phase(sm_error_phase),.error_row(sm_error_row),.error_node(sm_error_node),.error_element(sm_error_element),.context_valid(sm_context_valid),.context_row_hi(sm_context_row_hi),.resource_debt_clear(sm_resource_debt_clear),.resource_fault(sm_resource_fault),.score_rd_valid(sm_score_rd_valid),.score_rd_ready(sm_score_rd_ready),.score_rd_tag(sm_score_rd_tag),.score_rsp_valid(sm_score_rsp_valid),.score_rsp_ready(sm_score_rsp_ready),.score_rsp_tag(sm_score_rsp_tag),.score_rsp_data(sm_score_rsp_data),.fp_req_valid(sm_fp_req_valid),.fp_req_ready(sm_fp_req_ready),.fp_req_tag(sm_fp_req_tag),.fp_a(sm_fp_a),.fp_b(sm_fp_b),.fp_rsp_valid(sm_fp_rsp_valid),.fp_rsp_ready(sm_fp_rsp_ready),.fp_rsp_tag(sm_fp_rsp_tag),.fp_rsp_data(sm_fp_rsp_data),.sfu_req_valid(sm_sfu_req_valid),.sfu_req_ready(sm_sfu_req_ready),.sfu_req_tag(sm_sfu_req_tag),.sfu_req_x(sm_sfu_req_x),.sfu_rsp_valid(sm_sfu_rsp_valid),.sfu_rsp_ready(sm_sfu_rsp_ready),.sfu_rsp_tag(sm_sfu_rsp_tag),.sfu_rsp_data(sm_sfu_rsp_data),.exp_wr_valid(sm_exp_wr_valid),.exp_wr_ready(sm_exp_wr_ready),.exp_wr_tag(sm_exp_wr_tag),.exp_wr_data(sm_exp_wr_data),.exp_wr_ack_valid(sm_exp_wr_ack_valid),.exp_wr_ack_ready(sm_exp_wr_ack_ready),.exp_wr_ack_tag(sm_exp_wr_ack_tag),.exp_rd_valid(sm_exp_rd_valid),.exp_rd_ready(sm_exp_rd_ready),.exp_rd_tag(sm_exp_rd_tag),.exp_rsp_valid(sm_exp_rsp_valid),.exp_rsp_ready(sm_exp_rsp_ready),.exp_rsp_tag(sm_exp_rsp_tag),.exp_rsp_data(sm_exp_rsp_data),.div_req_valid(sm_div_req_valid),.div_req_ready(sm_div_req_ready),.div_req_tag(sm_div_req_tag),.div_a(sm_div_a),.div_b(sm_div_b),.div_rsp_valid(sm_div_rsp_valid),.div_rsp_ready(sm_div_rsp_ready),.div_rsp_tag(sm_div_rsp_tag),.div_rsp_data(sm_div_rsp_data),.div_rsp_error(sm_div_rsp_error),.prob_wr_valid(sm_prob_wr_valid),.prob_wr_ready(sm_prob_wr_ready),.prob_wr_tag(sm_prob_wr_tag),.prob_wr_data(sm_prob_wr_data),.prob_wr_ack_valid(sm_prob_wr_ack_valid),.prob_wr_ack_ready(sm_prob_wr_ack_ready),.prob_wr_ack_tag(sm_prob_wr_ack_tag));
 assign p_qkv_wr_valid=q_res_qkv_wr_valid;
 assign q_res_qkv_wr_ready=p_qkv_wr_ready;
 assign p_qkv_wr_plane=q_res_qkv_wr_plane;
 assign p_qkv_wr_head=q_res_qkv_wr_head;
 assign p_qkv_wr_token=q_res_qkv_wr_token;
 assign p_qkv_wr_half=q_res_qkv_wr_half;
 assign p_qkv_wr_data=q_res_qkv_wr_data;
 assign p_qkv_rd_valid=q_res_qkv_rd_valid;
 assign q_res_qkv_rd_ready=p_qkv_rd_ready;
 assign p_qkv_rd_head=q_res_qkv_rd_head;
 assign p_qkv_rd_token=q_res_qkv_rd_token;
 assign p_qkv_rd_tag=q_res_qkv_rd_tag;
 assign q_res_qkv_rd_rsp_valid=p_qkv_rd_rsp_valid;
 assign p_qkv_rd_rsp_ready=q_res_qkv_rd_rsp_ready;
 assign q_res_qkv_rd_rsp_head=p_qkv_rd_rsp_head;
 assign q_res_qkv_rd_rsp_token=p_qkv_rd_rsp_token;
 assign q_res_qkv_rd_rsp_tag=p_qkv_rd_rsp_tag;
 assign q_res_qkv_rd_rsp_data=p_qkv_rd_rsp_data;
 assign q_res_st_bind_ready=p_st_bind_ready;
 assign q_res_st_rsp_request_id=p_st_rsp_request_id;
 assign q_res_st_rsp_generation=p_st_rsp_generation;
 assign q_res_st_rsp_epoch=p_st_rsp_epoch;
 assign q_res_st_rsp_head=p_st_rsp_head;
 assign q_res_st_rsp_phase=p_st_rsp_phase;
 assign q_res_st_ps_wr_ready=p_st_ps_wr_ready;
 assign q_res_st_ps_wr_rsp_valid=p_st_ps_wr_rsp_valid;
 assign q_res_st_ps_wr_rsp_tag=p_st_ps_wr_rsp_tag;
 assign q_res_st_ps_rd_ready=p_st_ps_rd_ready;
 assign q_res_st_ps_rd_rsp_valid=p_st_ps_rd_rsp_valid;
 assign q_res_st_ps_rd_rsp_data=p_st_ps_rd_rsp_data;
 assign q_res_st_ps_rd_rsp_mask=p_st_ps_rd_rsp_mask;
 assign q_res_st_ps_rd_rsp_tag=p_st_ps_rd_rsp_tag;
 assign q_res_st_g_wr_ready=p_st_g_wr_ready;
 assign q_res_st_g_wr_rsp_valid=p_st_g_wr_rsp_valid;
 assign q_res_st_g_wr_rsp_tag=p_st_g_wr_rsp_tag;
 assign q_res_st_g_rd_ready=p_st_g_rd_ready;
 assign q_res_st_g_rd_rsp_valid=p_st_g_rd_rsp_valid;
 assign q_res_st_g_rd_rsp_data=p_st_g_rd_rsp_data;
 assign q_res_st_g_rd_rsp_mask=p_st_g_rd_rsp_mask;
 assign q_res_st_g_rd_rsp_tag=p_st_g_rd_rsp_tag;
 assign q_res_st_context_wr_ready=p_st_context_wr_ready;
 assign q_res_st_context_wr_rsp_valid=p_st_context_wr_rsp_valid;
 assign q_res_st_context_wr_rsp_tag=p_st_context_wr_rsp_tag;
 assign q_res_st_context_rd_ready=p_st_context_rd_ready;
 assign q_res_st_context_rd_rsp_valid=p_st_context_rd_rsp_valid;
 assign q_res_st_context_rd_rsp_data=p_st_context_rd_rsp_data;
 assign q_res_st_context_rd_rsp_mask=p_st_context_rd_rsp_mask;
 assign q_res_st_context_rd_rsp_tag=p_st_context_rd_rsp_tag;
 assign q_res_st_idle=p_st_idle;
 assign q_res_fp_lease_ready=(p_fp_lease_ready & !select_sm);
 assign q_res_fp_release_ready=(p_fp_release_ready & !select_sm);
 assign q_res_fp_lease_active=p_fp_lease_active;
 assign q_res_fp_draining=p_fp_draining;
 assign q_res_fp_rsp_request_id=p_fp_rsp_request_id;
 assign q_res_fp_rsp_generation=p_fp_rsp_generation;
 assign q_res_fp_rsp_epoch=p_fp_rsp_epoch;
 assign q_res_fp_rsp_head=p_fp_rsp_head;
 assign q_res_fp_rsp_phase=p_fp_rsp_phase;
 assign q_res_fp_mul_req_ready=p_fp_mul_req_ready;
 assign q_res_fp_mul_rsp_valid=(p_fp_mul_rsp_valid & !select_sm);
 assign q_res_fp_mul_rsp_tag=p_fp_mul_rsp_tag;
 assign q_res_fp_mul_rsp_data=p_fp_mul_rsp_data;
 assign q_res_fp_add_req_ready=p_fp_add_req_ready;
 assign q_res_fp_add_rsp_valid=(p_fp_add_rsp_valid & {7{!select_sm}});
 assign q_res_fp_add_rsp_tag=p_fp_add_rsp_tag;
 assign q_res_fp_add_rsp_data=p_fp_add_rsp_data;
 assign q_res_fp_mul_pending=p_fp_mul_pending;
 assign q_res_fp_add_pending=p_fp_add_pending;
 assign q_res_fp_protocol_fault=p_fp_protocol_fault;
 assign p_st_bind_valid=state==H_BIND_SM?(p_st_bind_ready&&p_ln_bind_ready):state==H_BIND_AV?1'b1:q_res_st_bind_valid;
 assign p_st_bind_request_id=state==H_IDLE?prepare_request_id:request_id;
 assign p_st_bind_generation=state==H_IDLE?prepare_generation:generation;
 assign p_st_bind_epoch=state==H_IDLE?prepare_epoch:epoch;
 assign p_st_bind_head=state==H_IDLE?prepare_head:head;
 assign p_st_bind_phase=phase;
 assign p_st_op_request_id=request_id;
 assign p_st_op_generation=generation;
 assign p_st_op_epoch=epoch;
 assign p_st_op_phase=phase;
 assign p_st_ps_wr_valid=select_sm?sm_st_ps_wr_valid:q_res_st_ps_wr_valid;
 assign p_st_ps_wr_mask=select_sm?sm_st_ps_wr_mask:q_res_st_ps_wr_mask;
 assign p_st_ps_wr_addr=select_sm?sm_st_ps_wr_addr:q_res_st_ps_wr_addr;
 assign p_st_ps_wr_data=select_sm?sm_st_ps_wr_data:q_res_st_ps_wr_data;
 assign p_st_ps_wr_tag=select_sm?sm_st_ps_wr_tag:q_res_st_ps_wr_tag;
 assign p_st_ps_wr_rsp_ready=select_sm?sm_st_ps_wr_rsp_ready:q_res_st_ps_wr_rsp_ready;
 assign p_st_ps_rd_valid=select_sm?sm_st_ps_rd_valid:q_res_st_ps_rd_valid;
 assign p_st_ps_rd_mask=select_sm?sm_st_ps_rd_mask:q_res_st_ps_rd_mask;
 assign p_st_ps_rd_addr=select_sm?sm_st_ps_rd_addr:q_res_st_ps_rd_addr;
 assign p_st_ps_rd_tag=select_sm?sm_st_ps_rd_tag:q_res_st_ps_rd_tag;
 assign p_st_ps_rd_rsp_ready=select_sm?sm_st_ps_rd_rsp_ready:q_res_st_ps_rd_rsp_ready;
 assign p_st_g_wr_valid=select_sm?sm_st_g_wr_valid:q_res_st_g_wr_valid;
 assign p_st_g_wr_mask=select_sm?sm_st_g_wr_mask:q_res_st_g_wr_mask;
 assign p_st_g_wr_addr=select_sm?sm_st_g_wr_addr:q_res_st_g_wr_addr;
 assign p_st_g_wr_data=select_sm?sm_st_g_wr_data:q_res_st_g_wr_data;
 assign p_st_g_wr_tag=select_sm?sm_st_g_wr_tag:q_res_st_g_wr_tag;
 assign p_st_g_wr_rsp_ready=select_sm?sm_st_g_wr_rsp_ready:q_res_st_g_wr_rsp_ready;
 assign p_st_g_rd_valid=select_sm?sm_st_g_rd_valid:q_res_st_g_rd_valid;
 assign p_st_g_rd_mask=select_sm?sm_st_g_rd_mask:q_res_st_g_rd_mask;
 assign p_st_g_rd_addr=select_sm?sm_st_g_rd_addr:q_res_st_g_rd_addr;
 assign p_st_g_rd_tag=select_sm?sm_st_g_rd_tag:q_res_st_g_rd_tag;
 assign p_st_g_rd_rsp_ready=select_sm?sm_st_g_rd_rsp_ready:q_res_st_g_rd_rsp_ready;
 assign p_st_context_wr_valid=select_sm?sm_st_context_wr_valid:q_res_st_context_wr_valid;
 assign p_st_context_wr_mask=select_sm?sm_st_context_wr_mask:q_res_st_context_wr_mask;
 assign p_st_context_wr_addr=select_sm?sm_st_context_wr_addr:q_res_st_context_wr_addr;
 assign p_st_context_wr_data=select_sm?sm_st_context_wr_data:q_res_st_context_wr_data;
 assign p_st_context_wr_tag=select_sm?sm_st_context_wr_tag:q_res_st_context_wr_tag;
 assign p_st_context_wr_rsp_ready=select_sm?sm_st_context_wr_rsp_ready:q_res_st_context_wr_rsp_ready;
 assign p_st_context_rd_valid=select_sm?sm_st_context_rd_valid:q_res_st_context_rd_valid;
 assign p_st_context_rd_mask=select_sm?sm_st_context_rd_mask:q_res_st_context_rd_mask;
 assign p_st_context_rd_addr=select_sm?sm_st_context_rd_addr:q_res_st_context_rd_addr;
 assign p_st_context_rd_tag=select_sm?sm_st_context_rd_tag:q_res_st_context_rd_tag;
 assign p_st_context_rd_rsp_ready=select_sm?sm_st_context_rd_rsp_ready:q_res_st_context_rd_rsp_ready;
 assign p_ln_bind_valid=state==H_BIND_SM&&p_st_bind_ready&&p_ln_bind_ready;
 assign p_ln_bind_request_id=request_id;
 assign p_ln_bind_generation=generation;
 assign p_ln_bind_epoch=epoch;
 assign p_ln_bind_head=head;
 assign p_ln_bind_phase=3'd3;
 assign p_ln_op_request_id=request_id;
 assign p_ln_op_generation=generation;
 assign p_ln_op_epoch=epoch;
 assign p_ln_op_phase=3'd3;
 assign p_ln_wr_valid=sm_ln_wr_valid;
 assign p_ln_wr_mask=sm_ln_wr_mask;
 assign p_ln_wr_addr=sm_ln_wr_addr;
 assign p_ln_wr_data=sm_ln_wr_data;
 assign p_ln_wr_tag=sm_ln_wr_tag;
 assign p_ln_wr_rsp_ready=sm_ln_wr_rsp_ready;
 assign p_ln_rd_valid=sm_ln_rd_valid;
 assign p_ln_rd_mask=sm_ln_rd_mask;
 assign p_ln_rd_addr=sm_ln_rd_addr;
 assign p_ln_rd_tag=sm_ln_rd_tag;
 assign p_ln_rd_rsp_ready=sm_ln_rd_rsp_ready;
 assign storage_idle=p_st_idle;assign ln_idle=p_ln_idle;assign fp_owned=p_fp_lease_active;assign fp_lease_ready=p_fp_lease_ready;assign fp_fault=p_fp_protocol_fault;assign mul_pending=p_fp_mul_pending;assign add_pending=p_fp_add_pending;
 assign p_fp_lease_valid=select_sm?sm_lease_fire:q_res_fp_lease_valid;
 assign p_fp_lease_request_id=select_sm?request_id:q_res_fp_lease_request_id;
 assign p_fp_lease_generation=select_sm?generation:q_res_fp_lease_generation;
 assign p_fp_lease_epoch=select_sm?epoch:q_res_fp_lease_epoch;
 assign p_fp_lease_head=select_sm?head:q_res_fp_lease_head;
 assign p_fp_lease_phase=select_sm?3'd3:q_res_fp_lease_phase;
 assign p_fp_release_valid=select_sm?sm_release&&fp_owned:q_res_fp_release_valid;
 assign p_fp_release_phase=select_sm?3'd3:q_res_fp_release_phase;
 assign p_fp_release_epoch=select_sm?epoch:q_res_fp_release_epoch;
 assign p_fp_phase_debt_clear=select_sm?sm_local_idle:q_res_fp_phase_debt_clear;
 assign p_fp_mul_req_valid=select_sm?1'b0:q_res_fp_mul_req_valid;
 assign p_fp_mul_req_phase=select_sm?3'd3:q_res_fp_mul_req_phase;
 assign p_fp_mul_req_epoch=select_sm?epoch:q_res_fp_mul_req_epoch;
 assign p_fp_mul_req_tag=select_sm?96'b0:q_res_fp_mul_req_tag;
 assign p_fp_mul_a=select_sm?8192'b0:q_res_fp_mul_a;
 assign p_fp_mul_b=select_sm?8192'b0:q_res_fp_mul_b;
 assign p_fp_mul_rsp_ready=select_sm?1'b1:q_res_fp_mul_rsp_ready;
 assign p_fp_add_req_valid=select_sm?{6'b0,(sm_fp_req_valid&&fp_grant)}:q_res_fp_add_req_valid;
 assign p_fp_add_req_is_root=select_sm?7'b0:q_res_fp_add_req_is_root;
 assign p_fp_add_req_phase=select_sm?{7{3'd3}}:q_res_fp_add_req_phase;
 assign p_fp_add_req_epoch=select_sm?{7{epoch}}:q_res_fp_add_req_epoch;
 assign p_fp_add_req_tag=select_sm?{576'b0,sm_fp_req_tag}:q_res_fp_add_req_tag;
 assign p_fp_add_a=select_sm?sm_fp_a:q_res_fp_add_a;
 assign p_fp_add_b=select_sm?sm_fp_b:q_res_fp_add_b;
 assign p_fp_add_rsp_ready=select_sm?{6'b0,(sm_fp_rsp_ready&&fp_grant)}:q_res_fp_add_rsp_ready;
 assign sm_fp_req_ready=select_sm&&p_fp_add_req_ready[0]&&fp_grant;assign sm_fp_rsp_valid=select_sm&&p_fp_add_rsp_valid[0]&&fp_grant;assign sm_fp_rsp_tag=p_fp_add_rsp_tag[0];assign sm_fp_rsp_data=p_fp_add_rsp_data;


 assign sm_sfu_req_ready=sfu_ready_raw&&sfu_grant;
 assign sm_div_req_ready=div_ready_raw&&div_grant;
 function automatic int sb(input int r,k);return(k/64)*512+(r%16)*32+k%32;endfunction
 function automatic int sa(input int r,k);return(r/16)*2+(k%64)/32;endfunction
 function automatic int gb(input int r,k);return(r%8)*32+k%32;endfunction
 function automatic int ga(input int r,k);return(r/8)*4+k/32;endfunction
 function automatic int la(input int r,k);return((r%64)/8)*4+k/32;endfunction
 always_comb begin
  sm_st_ps_wr_valid=0;sm_st_ps_wr_mask=0;sm_st_ps_wr_addr=0;sm_st_ps_wr_data=0;sm_st_ps_wr_tag=0;sm_st_ps_wr_rsp_ready=1;
  sm_st_ps_rd_valid=select_sm&&sm_score_rd_valid&&ps_grant;sm_st_ps_rd_mask=0;sm_st_ps_rd_addr=0;sm_st_ps_rd_tag={85'b0,sm_score_rd_tag};sm_score_rd_ready=p_st_ps_rd_ready&&ps_grant&&select_sm;
  for(int i=0;i<8;i++)begin int r,k,b;r=int'(sm_score_rd_tag[10:4]);k=int'(sm_score_rd_tag[3:0])*8+i;b=sb(r,k);sm_st_ps_rd_mask[b]=1;sm_st_ps_rd_addr[b]=4'(sa(r,k));end
  sm_score_rsp_valid=p_st_ps_rd_rsp_valid&&select_sm;sm_score_rsp_tag=p_st_ps_rd_rsp_tag[10:0];sm_st_ps_rd_rsp_ready=sm_score_rsp_ready;
  for(int i=0;i<8;i++)sm_score_rsp_data[i]=p_st_ps_rd_rsp_data[sb(int'(p_st_ps_rd_rsp_tag[10:4]),int'(p_st_ps_rd_rsp_tag[3:0])*8+i)];
  sm_ln_wr_valid=select_sm&&sm_exp_wr_valid&&exp_grant;sm_ln_wr_mask=0;sm_ln_wr_addr=0;sm_ln_wr_data=0;sm_ln_wr_tag={85'b0,sm_exp_wr_tag};sm_exp_wr_ready=p_ln_wr_ready&&exp_grant&&select_sm;
  for(int i=0;i<8;i++)begin int r,k,b;r=int'(sm_exp_wr_tag[10:4]);k=int'(sm_exp_wr_tag[3:0])*8+i;b=gb(r,k);sm_ln_wr_mask[b]=1;sm_ln_wr_addr[b]=5'(la(r,k));sm_ln_wr_data[b]=sm_exp_wr_data[i];end
  sm_exp_wr_ack_valid=p_ln_wr_rsp_valid&&select_sm;sm_exp_wr_ack_tag=p_ln_wr_rsp_tag[10:0];sm_ln_wr_rsp_ready=sm_exp_wr_ack_ready;
  sm_ln_rd_valid=select_sm&&sm_exp_rd_valid&&exp_grant;sm_ln_rd_mask=0;sm_ln_rd_addr=0;sm_ln_rd_tag={85'b0,sm_exp_rd_tag};sm_exp_rd_ready=p_ln_rd_ready&&exp_grant&&select_sm;
  for(int i=0;i<8;i++)begin int r,k,b;r=int'(sm_exp_rd_tag[10:4]);k=int'(sm_exp_rd_tag[3:0])*8+i;b=gb(r,k);sm_ln_rd_mask[b]=1;sm_ln_rd_addr[b]=5'(la(r,k));end
  sm_exp_rsp_valid=p_ln_rd_rsp_valid&&select_sm;sm_exp_rsp_tag=p_ln_rd_rsp_tag[10:0];sm_ln_rd_rsp_ready=sm_exp_rsp_ready;
  for(int i=0;i<8;i++)sm_exp_rsp_data[i]=p_ln_rd_rsp_data[gb(int'(p_ln_rd_rsp_tag[10:4]),int'(p_ln_rd_rsp_tag[3:0])*8+i)];
  sm_st_g_wr_valid=select_sm&&sm_prob_wr_valid&&g_grant;sm_st_g_wr_mask=0;sm_st_g_wr_addr=0;sm_st_g_wr_data=0;sm_st_g_wr_tag={85'b0,sm_prob_wr_tag};sm_prob_wr_ready=p_st_g_wr_ready&&g_grant&&select_sm;
  for(int i=0;i<8;i++)begin int r,k,b;r=int'(sm_prob_wr_tag[10:4]);k=int'(sm_prob_wr_tag[3:0])*8+i;b=gb(r,k);sm_st_g_wr_mask[b]=1;sm_st_g_wr_addr[b]=6'(ga(r,k));sm_st_g_wr_data[b]=sm_prob_wr_data[i];end
  sm_prob_wr_ack_valid=p_st_g_wr_rsp_valid&&select_sm;sm_prob_wr_ack_tag=p_st_g_wr_rsp_tag[10:0];sm_st_g_wr_rsp_ready=sm_prob_wr_ack_ready;
  sm_st_g_rd_valid=0;sm_st_g_rd_mask=0;sm_st_g_rd_addr=0;sm_st_g_rd_tag=0;sm_st_g_rd_rsp_ready=1;
  sm_st_context_wr_valid=0;sm_st_context_wr_mask=0;sm_st_context_wr_addr=0;sm_st_context_wr_data=0;sm_st_context_wr_tag=0;sm_st_context_wr_rsp_ready=1;
  sm_st_context_rd_valid=0;sm_st_context_rd_mask=0;sm_st_context_rd_addr=0;sm_st_context_rd_tag=0;sm_st_context_rd_rsp_ready=1;
 end

 assign res_qkv_wr_valid=p_qkv_wr_valid;
 assign p_qkv_wr_ready=res_qkv_wr_ready;
 assign res_qkv_wr_plane=p_qkv_wr_plane;
 assign res_qkv_wr_head=p_qkv_wr_head;
 assign res_qkv_wr_token=p_qkv_wr_token;
 assign res_qkv_wr_half=p_qkv_wr_half;
 assign res_qkv_wr_data=p_qkv_wr_data;
 assign res_qkv_rd_valid=p_qkv_rd_valid;
 assign p_qkv_rd_ready=res_qkv_rd_ready;
 assign res_qkv_rd_head=p_qkv_rd_head;
 assign res_qkv_rd_token=p_qkv_rd_token;
 assign res_qkv_rd_tag=p_qkv_rd_tag;
 assign p_qkv_rd_rsp_valid=res_qkv_rd_rsp_valid;
 assign res_qkv_rd_rsp_ready=p_qkv_rd_rsp_ready;
 assign p_qkv_rd_rsp_head=res_qkv_rd_rsp_head;
 assign p_qkv_rd_rsp_token=res_qkv_rd_rsp_token;
 assign p_qkv_rd_rsp_tag=res_qkv_rd_rsp_tag;
 assign p_qkv_rd_rsp_data=res_qkv_rd_rsp_data;
 assign res_st_bind_valid=p_st_bind_valid;
 assign p_st_bind_ready=res_st_bind_ready;
 assign res_st_bind_request_id=p_st_bind_request_id;
 assign res_st_bind_generation=p_st_bind_generation;
 assign res_st_bind_epoch=p_st_bind_epoch;
 assign res_st_bind_head=p_st_bind_head;
 assign res_st_bind_phase=p_st_bind_phase;
 assign res_st_op_request_id=p_st_op_request_id;
 assign res_st_op_generation=p_st_op_generation;
 assign res_st_op_epoch=p_st_op_epoch;
 assign res_st_op_phase=p_st_op_phase;
 assign p_st_rsp_request_id=res_st_rsp_request_id;
 assign p_st_rsp_generation=res_st_rsp_generation;
 assign p_st_rsp_epoch=res_st_rsp_epoch;
 assign p_st_rsp_head=res_st_rsp_head;
 assign p_st_rsp_phase=res_st_rsp_phase;
 assign res_st_ps_wr_valid=p_st_ps_wr_valid;
 assign p_st_ps_wr_ready=res_st_ps_wr_ready;
 assign res_st_ps_wr_mask=p_st_ps_wr_mask;
 assign res_st_ps_wr_addr=p_st_ps_wr_addr;
 assign res_st_ps_wr_data=p_st_ps_wr_data;
 assign res_st_ps_wr_tag=p_st_ps_wr_tag;
 assign p_st_ps_wr_rsp_valid=res_st_ps_wr_rsp_valid;
 assign res_st_ps_wr_rsp_ready=p_st_ps_wr_rsp_ready;
 assign p_st_ps_wr_rsp_tag=res_st_ps_wr_rsp_tag;
 assign res_st_ps_rd_valid=p_st_ps_rd_valid;
 assign p_st_ps_rd_ready=res_st_ps_rd_ready;
 assign res_st_ps_rd_mask=p_st_ps_rd_mask;
 assign res_st_ps_rd_addr=p_st_ps_rd_addr;
 assign res_st_ps_rd_tag=p_st_ps_rd_tag;
 assign p_st_ps_rd_rsp_valid=res_st_ps_rd_rsp_valid;
 assign res_st_ps_rd_rsp_ready=p_st_ps_rd_rsp_ready;
 assign p_st_ps_rd_rsp_data=res_st_ps_rd_rsp_data;
 assign p_st_ps_rd_rsp_mask=res_st_ps_rd_rsp_mask;
 assign p_st_ps_rd_rsp_tag=res_st_ps_rd_rsp_tag;
 assign res_st_g_wr_valid=p_st_g_wr_valid;
 assign p_st_g_wr_ready=res_st_g_wr_ready;
 assign res_st_g_wr_mask=p_st_g_wr_mask;
 assign res_st_g_wr_addr=p_st_g_wr_addr;
 assign res_st_g_wr_data=p_st_g_wr_data;
 assign res_st_g_wr_tag=p_st_g_wr_tag;
 assign p_st_g_wr_rsp_valid=res_st_g_wr_rsp_valid;
 assign res_st_g_wr_rsp_ready=p_st_g_wr_rsp_ready;
 assign p_st_g_wr_rsp_tag=res_st_g_wr_rsp_tag;
 assign res_st_g_rd_valid=p_st_g_rd_valid;
 assign p_st_g_rd_ready=res_st_g_rd_ready;
 assign res_st_g_rd_mask=p_st_g_rd_mask;
 assign res_st_g_rd_addr=p_st_g_rd_addr;
 assign res_st_g_rd_tag=p_st_g_rd_tag;
 assign p_st_g_rd_rsp_valid=res_st_g_rd_rsp_valid;
 assign res_st_g_rd_rsp_ready=p_st_g_rd_rsp_ready;
 assign p_st_g_rd_rsp_data=res_st_g_rd_rsp_data;
 assign p_st_g_rd_rsp_mask=res_st_g_rd_rsp_mask;
 assign p_st_g_rd_rsp_tag=res_st_g_rd_rsp_tag;
 assign res_st_context_wr_valid=p_st_context_wr_valid;
 assign p_st_context_wr_ready=res_st_context_wr_ready;
 assign res_st_context_wr_mask=p_st_context_wr_mask;
 assign res_st_context_wr_addr=p_st_context_wr_addr;
 assign res_st_context_wr_data=p_st_context_wr_data;
 assign res_st_context_wr_tag=p_st_context_wr_tag;
 assign p_st_context_wr_rsp_valid=res_st_context_wr_rsp_valid;
 assign res_st_context_wr_rsp_ready=p_st_context_wr_rsp_ready;
 assign p_st_context_wr_rsp_tag=res_st_context_wr_rsp_tag;
 assign res_st_context_rd_valid=p_st_context_rd_valid;
 assign p_st_context_rd_ready=res_st_context_rd_ready;
 assign res_st_context_rd_mask=p_st_context_rd_mask;
 assign res_st_context_rd_addr=p_st_context_rd_addr;
 assign res_st_context_rd_tag=p_st_context_rd_tag;
 assign p_st_context_rd_rsp_valid=res_st_context_rd_rsp_valid;
 assign res_st_context_rd_rsp_ready=p_st_context_rd_rsp_ready;
 assign p_st_context_rd_rsp_data=res_st_context_rd_rsp_data;
 assign p_st_context_rd_rsp_mask=res_st_context_rd_rsp_mask;
 assign p_st_context_rd_rsp_tag=res_st_context_rd_rsp_tag;
 assign p_st_idle=res_st_idle;
 assign res_fp_lease_valid=p_fp_lease_valid;
 assign p_fp_lease_ready=res_fp_lease_ready;
 assign res_fp_lease_request_id=p_fp_lease_request_id;
 assign res_fp_lease_generation=p_fp_lease_generation;
 assign res_fp_lease_epoch=p_fp_lease_epoch;
 assign res_fp_lease_head=p_fp_lease_head;
 assign res_fp_lease_phase=p_fp_lease_phase;
 assign res_fp_release_valid=p_fp_release_valid;
 assign p_fp_release_ready=res_fp_release_ready;
 assign res_fp_release_phase=p_fp_release_phase;
 assign res_fp_release_epoch=p_fp_release_epoch;
 assign res_fp_phase_debt_clear=p_fp_phase_debt_clear;
 assign p_fp_lease_active=res_fp_lease_active;
 assign p_fp_draining=res_fp_draining;
 assign p_fp_rsp_request_id=res_fp_rsp_request_id;
 assign p_fp_rsp_generation=res_fp_rsp_generation;
 assign p_fp_rsp_epoch=res_fp_rsp_epoch;
 assign p_fp_rsp_head=res_fp_rsp_head;
 assign p_fp_rsp_phase=res_fp_rsp_phase;
 assign res_fp_mul_req_valid=p_fp_mul_req_valid;
 assign p_fp_mul_req_ready=res_fp_mul_req_ready;
 assign res_fp_mul_req_phase=p_fp_mul_req_phase;
 assign res_fp_mul_req_epoch=p_fp_mul_req_epoch;
 assign res_fp_mul_req_tag=p_fp_mul_req_tag;
 assign res_fp_mul_a=p_fp_mul_a;
 assign res_fp_mul_b=p_fp_mul_b;
 assign p_fp_mul_rsp_valid=res_fp_mul_rsp_valid;
 assign res_fp_mul_rsp_ready=p_fp_mul_rsp_ready;
 assign p_fp_mul_rsp_tag=res_fp_mul_rsp_tag;
 assign p_fp_mul_rsp_data=res_fp_mul_rsp_data;
 assign res_fp_add_req_valid=p_fp_add_req_valid;
 assign res_fp_add_req_is_root=p_fp_add_req_is_root;
 assign p_fp_add_req_ready=res_fp_add_req_ready;
 assign res_fp_add_req_phase=p_fp_add_req_phase;
 assign res_fp_add_req_epoch=p_fp_add_req_epoch;
 assign res_fp_add_req_tag=p_fp_add_req_tag;
 assign res_fp_add_a=p_fp_add_a;
 assign res_fp_add_b=p_fp_add_b;
 assign p_fp_add_rsp_valid=res_fp_add_rsp_valid;
 assign res_fp_add_rsp_ready=p_fp_add_rsp_ready;
 assign p_fp_add_rsp_tag=res_fp_add_rsp_tag;
 assign p_fp_add_rsp_data=res_fp_add_rsp_data;
 assign p_fp_mul_pending=res_fp_mul_pending;
 assign p_fp_add_pending=res_fp_add_pending;
 assign p_fp_protocol_fault=res_fp_protocol_fault;
 assign res_ln_bind_valid=p_ln_bind_valid;
 assign p_ln_bind_ready=res_ln_bind_ready;
 assign res_ln_bind_request_id=p_ln_bind_request_id;
 assign res_ln_bind_generation=p_ln_bind_generation;
 assign res_ln_bind_epoch=p_ln_bind_epoch;
 assign res_ln_bind_head=p_ln_bind_head;
 assign res_ln_bind_phase=p_ln_bind_phase;
 assign res_ln_op_request_id=p_ln_op_request_id;
 assign res_ln_op_generation=p_ln_op_generation;
 assign res_ln_op_epoch=p_ln_op_epoch;
 assign res_ln_op_phase=p_ln_op_phase;
 assign p_ln_rsp_request_id=res_ln_rsp_request_id;
 assign p_ln_rsp_generation=res_ln_rsp_generation;
 assign p_ln_rsp_epoch=res_ln_rsp_epoch;
 assign p_ln_rsp_head=res_ln_rsp_head;
 assign p_ln_rsp_phase=res_ln_rsp_phase;
 assign res_ln_wr_valid=p_ln_wr_valid;
 assign p_ln_wr_ready=res_ln_wr_ready;
 assign res_ln_wr_mask=p_ln_wr_mask;
 assign res_ln_wr_addr=p_ln_wr_addr;
 assign res_ln_wr_data=p_ln_wr_data;
 assign res_ln_wr_tag=p_ln_wr_tag;
 assign p_ln_wr_rsp_valid=res_ln_wr_rsp_valid;
 assign res_ln_wr_rsp_ready=p_ln_wr_rsp_ready;
 assign p_ln_wr_rsp_tag=res_ln_wr_rsp_tag;
 assign res_ln_rd_valid=p_ln_rd_valid;
 assign p_ln_rd_ready=res_ln_rd_ready;
 assign res_ln_rd_mask=p_ln_rd_mask;
 assign res_ln_rd_addr=p_ln_rd_addr;
 assign res_ln_rd_tag=p_ln_rd_tag;
 assign p_ln_rd_rsp_valid=res_ln_rd_rsp_valid;
 assign res_ln_rd_rsp_ready=p_ln_rd_rsp_ready;
 assign p_ln_rd_rsp_data=res_ln_rd_rsp_data;
 assign p_ln_rd_rsp_mask=res_ln_rd_rsp_mask;
 assign p_ln_rd_rsp_tag=res_ln_rd_rsp_tag;
 assign p_ln_idle=res_ln_idle;
 assign res_sfu_lease_valid=sm_lease_fire;
 assign sfu_lease_ready=res_sfu_lease_ready;
 assign res_sfu_lease_request_id=request_id;
 assign res_sfu_lease_generation=generation;
 assign res_sfu_lease_epoch=epoch;
 assign res_sfu_lease_head=head;
 assign res_sfu_lease_phase=3'd3;
 assign res_sfu_release_valid=sm_release&&sfu_owned;
 assign res_sfu_release_phase=3'd3;
 assign res_sfu_release_epoch=epoch;
 assign res_sfu_phase_debt_clear=sm_local_idle;
 assign sfu_owned=res_sfu_lease_active;
 assign res_sfu_context_valid=sm_context_valid;
 assign res_sfu_context_row_hi=sm_context_row_hi;
 assign res_sfu_req_valid=sm_sfu_req_valid&&sfu_grant;
 assign sfu_ready_raw=res_sfu_req_ready;
 assign res_sfu_req_mode=2'b0;
 assign res_sfu_req_generation=generation;
 assign res_sfu_req_epoch=epoch;
 assign res_sfu_req_phase=3'd3;
 assign res_sfu_req_tag=sm_sfu_req_tag;
 assign res_sfu_req_x=sm_sfu_req_x;
 assign sfu_reject=res_sfu_reject_valid;
 assign sm_sfu_rsp_valid=res_sfu_rsp_valid;
 assign res_sfu_rsp_ready=sm_sfu_rsp_ready;
 assign sm_sfu_rsp_tag=res_sfu_rsp_tag;
 assign sm_sfu_rsp_data=res_sfu_rsp_data;
 assign sfu_pending=res_sfu_pending_vectors;
 assign sfu_inflight=res_sfu_in_flight_vectors;
 assign sfu_fault=res_sfu_protocol_fault;
 assign res_div_lease_valid=sm_lease_fire;
 assign div_lease_ready=res_div_lease_ready;
 assign res_div_lease_request_id=request_id;
 assign res_div_lease_generation=generation;
 assign res_div_lease_epoch=epoch;
 assign res_div_lease_head=head;
 assign res_div_lease_phase=3'd3;
 assign res_div_release_valid=sm_release&&div_owned;
 assign res_div_release_phase=3'd3;
 assign res_div_release_epoch=epoch;
 assign res_div_phase_debt_clear=sm_local_idle;
 assign div_owned=res_div_lease_active;
 assign res_div_req_valid=sm_div_req_valid&&div_grant;
 assign div_ready_raw=res_div_req_ready;
 assign res_div_req_generation=generation;
 assign res_div_req_epoch=epoch;
 assign res_div_req_phase=3'd3;
 assign res_div_req_lane_mask=8'hff;
 assign res_div_req_tag=sm_div_req_tag;
 assign res_div_req_a=sm_div_a;
 assign res_div_req_b=sm_div_b;
 assign div_reject=res_div_protocol_reject_valid;
 assign sm_div_rsp_valid=res_div_rsp_valid;
 assign res_div_rsp_ready=sm_div_rsp_ready;
 assign sm_div_rsp_tag=res_div_rsp_tag;
 assign sm_div_rsp_error=res_div_rsp_numeric_error;
 assign sm_div_rsp_data=res_div_rsp_data;
 assign div_pending=res_div_pending_vectors;
 assign div_inflight=res_div_in_flight_vectors;
 assign div_scalars=res_div_in_flight_scalars;
 assign div_fault=res_div_protocol_fault;
 assign res_scale_valid=q_res_scale_valid;
 assign q_res_scale_ready=res_scale_ready;
 assign res_scale_tag=q_res_scale_tag;
 assign res_scale_input=q_res_scale_input;
 assign q_res_scale_rsp_valid=res_scale_rsp_valid;
 assign res_scale_rsp_ready=q_res_scale_rsp_ready;
 assign q_res_scale_rsp_tag=res_scale_rsp_tag;
 assign q_res_scale_data=res_scale_data;
 assign q_res_scale_pending=res_scale_pending;
 assign q_res_scale_fault=res_scale_fault;
endmodule
