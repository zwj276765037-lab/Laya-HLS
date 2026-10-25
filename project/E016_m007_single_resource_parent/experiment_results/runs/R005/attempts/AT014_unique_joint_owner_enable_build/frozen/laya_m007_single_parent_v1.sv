`timescale 1ns/1ps
module laya_m007_single_parent_v1 #(
 parameter logic [127:0] MODEL_ID=128'h6eb6ef58bc4f99bd9db40381604108af,
 parameter logic [127:0] NUMERIC_ID=128'haeb13e7937d29fe6a2c68c407249f294,
 parameter logic [127:0] TABLE_KEY=128'hb1fdc9ca482c0210982c7245cc50c965,
 parameter logic [127:0] GRAPH_ID=128'hf33f7848434b73048f957dcd232e1bd4,
 parameter logic [127:0] LAYOUT_ID=128'h2d848b5fb78236c795cb1d442f088393,
 parameter logic [127:0] BUILD_ID=128'h7209eb09c3f265363cfb274f7790a733
)(
 input logic clk,rst_n,
 input logic cmd_valid,output logic cmd_ready,
 input logic [63:0] cmd_request,input logic [31:0] cmd_generation,cmd_epoch,
 input logic [127:0] cmd_model_id,cmd_numeric_id,cmd_table_key,cmd_graph_id,cmd_layout_id,cmd_build_id,
 input logic [1:0] cmd_kind,input logic [4:0] cmd_layer,input logic [127:0] cmd_mask,
 input logic [1:0][31:0] cmd_tensor,
 input logic [1:0][3:0][63:0] cmd_base,cmd_span,
 input logic in_valid,output logic in_ready,input logic [31:0][31:0] in_data,
 input logic [63:0] in_request,input logic [31:0] in_generation,in_epoch,input logic [7:0] in_row,in_group,
 output logic input_reject_valid,output logic [3:0] input_reject_code,
 input logic producer_fail_valid,input logic [95:0] producer_fail_tuple,
 input logic [63:0] producer_fail_request,input logic [31:0] producer_fail_generation,producer_fail_epoch,
 output logic producer_fail_ready,
 output logic out_valid,input logic out_ready,output logic [31:0][31:0] out_data,
 output logic [6:0] out_row,output logic [15:0] out_col,
 output logic done_valid,input logic done_ready,output logic [7:0] done_status,
 output logic [2:0] error_domain,output logic [95:0] error_tuple,
 output logic [7:0] source_status,
 input logic [127:0] bias_model_id,bias_numeric_id,
 output logic [63:0] done_request,output logic [31:0] done_generation,done_epoch,
 output logic [4:0] parent_state,output logic [31:0] elapsed_cycles,
 output logic [15:0] layer_head_completed,
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
 input logic  coef_cfg_valid,
 output logic  coef_cfg_ready,
 input logic [63:0] coef_model,
 input logic [63:0] coef_request,
 input logic [31:0] coef_tensor,
 input logic [31:0] coef_generation,
 input logic [31:0] coef_epoch,
 input logic [15:0] coef_n,
 input logic  coef_wr_valid,
 output logic  coef_wr_ready,
 input logic [6:0] coef_wr_addr,
 input logic [31:0][31:0] coef_wr_data,
 output logic  coef_rsp_valid,
 input logic  coef_rsp_ready,
 output logic [1:0] coef_status,
 output logic [15:0] coef_error_col,
 output logic [3:0] arvalid,
 input logic [3:0] arready,
 output logic [3:0][63:0] araddr,
 output logic [3:0][2:0] arid,
 output logic [3:0][7:0] arlen,
 input logic [3:0] rvalid,
 output logic [3:0] rready,
 input logic [3:0][2:0] rid,
 input logic [3:0][511:0] rdata,
 input logic [3:0][1:0] rresp,
 input logic [3:0] rlast
);
 function automatic logic [31:0] tensor_key(input logic [1:0] k,input logic [4:0] l,input logic wo);
  if(k==3)return l==0?(wo?32'd88:32'd60):32'hffffffff;
  case({k==2,l,wo})
   7'd0:return 32'd4; // qkv.0.weight
   7'd2:return 32'd5; // qkv.1.weight
   7'd4:return 32'd6; // qkv.2.weight
   7'd6:return 32'd7; // qkv.3.weight
   7'd8:return 32'd8; // qkv.4.weight
   7'd10:return 32'd9; // qkv.5.weight
   7'd12:return 32'd10; // qkv.6.weight
   7'd14:return 32'd11; // qkv.7.weight
   7'd16:return 32'd12; // qkv.8.weight
   7'd18:return 32'd13; // qkv.9.weight
   7'd20:return 32'd14; // qkv.10.weight
   7'd22:return 32'd15; // qkv.11.weight
   7'd24:return 32'd16; // qkv.12.weight
   7'd26:return 32'd17; // qkv.13.weight
   7'd28:return 32'd18; // qkv.14.weight
   7'd30:return 32'd19; // qkv.15.weight
   7'd32:return 32'd20; // qkv.16.weight
   7'd34:return 32'd21; // qkv.17.weight
   7'd36:return 32'd22; // qkv.18.weight
   7'd38:return 32'd23; // qkv.19.weight
   7'd40:return 32'd24; // qkv.20.weight
   7'd42:return 32'd25; // qkv.21.weight
   7'd44:return 32'd26; // qkv.22.weight
   7'd46:return 32'd27; // qkv.23.weight
   7'd48:return 32'd28; // qkv.24.weight
   7'd50:return 32'd29; // qkv.25.weight
   7'd52:return 32'd30; // qkv.26.weight
   7'd54:return 32'd31; // qkv.27.weight
   7'd1:return 32'd32; // wo.0.weight
   7'd3:return 32'd33; // wo.1.weight
   7'd5:return 32'd34; // wo.2.weight
   7'd7:return 32'd35; // wo.3.weight
   7'd9:return 32'd36; // wo.4.weight
   7'd11:return 32'd37; // wo.5.weight
   7'd13:return 32'd38; // wo.6.weight
   7'd15:return 32'd39; // wo.7.weight
   7'd17:return 32'd40; // wo.8.weight
   7'd19:return 32'd41; // wo.9.weight
   7'd21:return 32'd42; // wo.10.weight
   7'd23:return 32'd43; // wo.11.weight
   7'd25:return 32'd44; // wo.12.weight
   7'd27:return 32'd45; // wo.13.weight
   7'd29:return 32'd46; // wo.14.weight
   7'd31:return 32'd47; // wo.15.weight
   7'd33:return 32'd48; // wo.16.weight
   7'd35:return 32'd49; // wo.17.weight
   7'd37:return 32'd50; // wo.18.weight
   7'd39:return 32'd51; // wo.19.weight
   7'd41:return 32'd52; // wo.20.weight
   7'd43:return 32'd53; // wo.21.weight
   7'd45:return 32'd54; // wo.22.weight
   7'd47:return 32'd55; // wo.23.weight
   7'd49:return 32'd56; // wo.24.weight
   7'd51:return 32'd57; // wo.25.weight
   7'd53:return 32'd58; // wo.26.weight
   7'd55:return 32'd59; // wo.27.weight
   7'd64:return 32'd117; // head_qkv.0.weight
   7'd66:return 32'd119; // head_qkv.1.weight
   7'd65:return 32'd121; // head_wo.0.weight
   7'd67:return 32'd123; // head_wo.1.weight
   default:return 0;
  endcase
 endfunction logic  l_prepare_valid;
 logic  l_prepare_ready;
 logic [63:0] l_prepare_request_id;
 logic [127:0] l_prepare_model_id;
 logic [31:0] l_prepare_generation;
 logic [31:0] l_prepare_epoch;
 logic [127:0] l_prepare_numeric_id;
 logic [127:0] l_prepare_table_key;
 logic [1:0] l_prepare_kind;
 logic [4:0] l_prepare_layer;
 logic [127:0] l_prepare_mask;
 logic  l_qkv_wr_valid;
 logic  l_qkv_wr_ready;
 logic [63:0] l_qkv_wr_request_id;
 logic [31:0] l_qkv_wr_generation;
 logic [31:0] l_qkv_wr_epoch;
 logic [1:0] l_qkv_wr_plane;
 logic [3:0] l_qkv_wr_head;
 logic [6:0] l_qkv_wr_token;
 logic  l_qkv_wr_half;
 logic [31:0][31:0] l_qkv_wr_data;
 logic  l_start_valid;
 logic  l_start_ready;
 logic [63:0] l_start_request_id;
 logic [31:0] l_start_generation;
 logic  l_reject_valid;
 logic [3:0] l_reject_code;
 logic  l_abort_valid;
 logic  l_abort_ready;
 logic [2:0] l_qkv_read_grant;
 logic  l_ps_grant;
 logic  l_g_grant;
 logic  l_context_grant;
 logic  l_fp_grant;
 logic  l_sfu_grant;
 logic  l_exp_grant;
 logic  l_div_grant;
 logic  l_rope_write_grant;
 logic  l_done_valid;
 logic  l_done_ready;
 logic [63:0] l_done_request_id;
 logic [31:0] l_done_generation;
 logic [7:0] l_done_status;
 logic [31:0] l_done_cycles;
 logic [31:0] l_rope_cycles;
 logic [15:0] l_head_completed;
 logic [15:0] l_head_context_valid;
 logic [3:0] l_active_head;
 logic  l_error_valid;
 logic [95:0] l_error_tuple;
 logic [25:0][15:0] l_check_completed;
 logic [25:0][15:0] l_check_unreachable;
 logic [25:0][15:0] l_check_dominated;
 logic [2047:0] l_av_check_completed;
 logic [2047:0] l_av_check_unreachable;
 logic [2047:0] l_av_check_dominated;
 logic  l_result_rd_valid;
 logic  l_result_rd_ready;
 logic [31:0] l_result_rd_generation;
 logic [31:0] l_result_rd_tag;
 logic [3:0] l_result_rd_head;
 logic [6:0] l_result_rd_query;
 logic  l_result_rd_half;
 logic  l_result_rsp_valid;
 logic  l_result_rsp_ready;
 logic [31:0] l_result_rsp_tag;
 logic [31:0][31:0] l_result_rsp_data;
 logic  l_result_discard_valid;
 logic  l_result_discard_ready;
 logic [31:0] l_result_discard_generation;
 logic  l_context_discarded;
 logic [31:0] l_producer_done_cycles;
 logic [31:0] l_context_release_cycles;
 logic  l_prepare_cancel_valid;
 logic  l_prepare_cancel_ready;
 logic [63:0] l_prepare_cancel_request_id;
 logic [31:0] l_prepare_cancel_generation;
 logic [31:0] l_prepare_cancel_epoch;
 logic  l_prepare_cancel_rsp_valid;
 logic  l_prepare_cancel_rsp_ready;
 logic [63:0] l_prepare_cancel_rsp_request_id;
 logic [31:0] l_prepare_cancel_rsp_generation;
 logic [31:0] l_prepare_cancel_rsp_epoch;
 logic [7:0] l_prepare_cancel_rsp_status;
 logic  l_layer_idle;
 logic  l_check_coverage_fault;
 logic [31:0] l_check_first_conflict;
 logic  l_res_qkv_wr_valid;
 logic  l_res_qkv_wr_ready;
 logic [1:0] l_res_qkv_wr_plane;
 logic [3:0] l_res_qkv_wr_head;
 logic [6:0] l_res_qkv_wr_token;
 logic  l_res_qkv_wr_half;
 logic [31:0][31:0] l_res_qkv_wr_data;
 logic [2:0] l_res_qkv_rd_valid;
 logic [2:0] l_res_qkv_rd_ready;
 logic [2:0][3:0] l_res_qkv_rd_head;
 logic [2:0][6:0] l_res_qkv_rd_token;
 logic [2:0][31:0] l_res_qkv_rd_tag;
 logic [2:0] l_res_qkv_rd_rsp_valid;
 logic [2:0] l_res_qkv_rd_rsp_ready;
 logic [2:0][3:0] l_res_qkv_rd_rsp_head;
 logic [2:0][6:0] l_res_qkv_rd_rsp_token;
 logic [2:0][31:0] l_res_qkv_rd_rsp_tag;
 logic [2:0][63:0][31:0] l_res_qkv_rd_rsp_data;
 logic  l_res_st_bind_valid;
 logic  l_res_st_bind_ready;
 logic [63:0] l_res_st_bind_request_id;
 logic [31:0] l_res_st_bind_generation;
 logic [31:0] l_res_st_bind_epoch;
 logic [3:0] l_res_st_bind_head;
 logic [2:0] l_res_st_bind_phase;
 logic [63:0] l_res_st_op_request_id;
 logic [31:0] l_res_st_op_generation;
 logic [31:0] l_res_st_op_epoch;
 logic [2:0] l_res_st_op_phase;
 logic [63:0] l_res_st_rsp_request_id;
 logic [31:0] l_res_st_rsp_generation;
 logic [31:0] l_res_st_rsp_epoch;
 logic [3:0] l_res_st_rsp_head;
 logic [2:0] l_res_st_rsp_phase;
 logic  l_res_st_ps_wr_valid;
 logic  l_res_st_ps_wr_ready;
 logic [1023:0] l_res_st_ps_wr_mask;
 logic [1023:0][3:0] l_res_st_ps_wr_addr;
 logic [1023:0][31:0] l_res_st_ps_wr_data;
 logic [95:0] l_res_st_ps_wr_tag;
 logic  l_res_st_ps_wr_rsp_valid;
 logic  l_res_st_ps_wr_rsp_ready;
 logic [95:0] l_res_st_ps_wr_rsp_tag;
 logic  l_res_st_ps_rd_valid;
 logic  l_res_st_ps_rd_ready;
 logic [1023:0] l_res_st_ps_rd_mask;
 logic [1023:0][3:0] l_res_st_ps_rd_addr;
 logic [95:0] l_res_st_ps_rd_tag;
 logic  l_res_st_ps_rd_rsp_valid;
 logic  l_res_st_ps_rd_rsp_ready;
 logic [1023:0][31:0] l_res_st_ps_rd_rsp_data;
 logic [1023:0] l_res_st_ps_rd_rsp_mask;
 logic [95:0] l_res_st_ps_rd_rsp_tag;
 logic  l_res_st_g_wr_valid;
 logic  l_res_st_g_wr_ready;
 logic [255:0] l_res_st_g_wr_mask;
 logic [255:0][5:0] l_res_st_g_wr_addr;
 logic [255:0][31:0] l_res_st_g_wr_data;
 logic [95:0] l_res_st_g_wr_tag;
 logic  l_res_st_g_wr_rsp_valid;
 logic  l_res_st_g_wr_rsp_ready;
 logic [95:0] l_res_st_g_wr_rsp_tag;
 logic  l_res_st_g_rd_valid;
 logic  l_res_st_g_rd_ready;
 logic [255:0] l_res_st_g_rd_mask;
 logic [255:0][5:0] l_res_st_g_rd_addr;
 logic [95:0] l_res_st_g_rd_tag;
 logic  l_res_st_g_rd_rsp_valid;
 logic  l_res_st_g_rd_rsp_ready;
 logic [255:0][31:0] l_res_st_g_rd_rsp_data;
 logic [255:0] l_res_st_g_rd_rsp_mask;
 logic [95:0] l_res_st_g_rd_rsp_tag;
 logic  l_res_st_context_wr_valid;
 logic  l_res_st_context_wr_ready;
 logic [63:0] l_res_st_context_wr_mask;
 logic [63:0][10:0] l_res_st_context_wr_addr;
 logic [63:0][31:0] l_res_st_context_wr_data;
 logic [95:0] l_res_st_context_wr_tag;
 logic  l_res_st_context_wr_rsp_valid;
 logic  l_res_st_context_wr_rsp_ready;
 logic [95:0] l_res_st_context_wr_rsp_tag;
 logic  l_res_st_context_rd_valid;
 logic  l_res_st_context_rd_ready;
 logic [63:0] l_res_st_context_rd_mask;
 logic [63:0][10:0] l_res_st_context_rd_addr;
 logic [95:0] l_res_st_context_rd_tag;
 logic  l_res_st_context_rd_rsp_valid;
 logic  l_res_st_context_rd_rsp_ready;
 logic [63:0][31:0] l_res_st_context_rd_rsp_data;
 logic [63:0] l_res_st_context_rd_rsp_mask;
 logic [95:0] l_res_st_context_rd_rsp_tag;
 logic  l_res_st_idle;
 logic  l_res_fp_lease_valid;
 logic  l_res_fp_lease_ready;
 logic [63:0] l_res_fp_lease_request_id;
 logic [31:0] l_res_fp_lease_generation;
 logic [31:0] l_res_fp_lease_epoch;
 logic [3:0] l_res_fp_lease_head;
 logic [2:0] l_res_fp_lease_phase;
 logic  l_res_fp_release_valid;
 logic  l_res_fp_release_ready;
 logic [2:0] l_res_fp_release_phase;
 logic [31:0] l_res_fp_release_epoch;
 logic  l_res_fp_phase_debt_clear;
 logic  l_res_fp_lease_active;
 logic  l_res_fp_draining;
 logic [63:0] l_res_fp_rsp_request_id;
 logic [31:0] l_res_fp_rsp_generation;
 logic [31:0] l_res_fp_rsp_epoch;
 logic [3:0] l_res_fp_rsp_head;
 logic [2:0] l_res_fp_rsp_phase;
 logic  l_res_fp_mul_req_valid;
 logic  l_res_fp_mul_req_ready;
 logic [2:0] l_res_fp_mul_req_phase;
 logic [31:0] l_res_fp_mul_req_epoch;
 logic [95:0] l_res_fp_mul_req_tag;
 logic [255:0][31:0] l_res_fp_mul_a;
 logic [255:0][31:0] l_res_fp_mul_b;
 logic  l_res_fp_mul_rsp_valid;
 logic  l_res_fp_mul_rsp_ready;
 logic [95:0] l_res_fp_mul_rsp_tag;
 logic [255:0][31:0] l_res_fp_mul_rsp_data;
 logic [6:0] l_res_fp_add_req_valid;
 logic [6:0] l_res_fp_add_req_is_root;
 logic [6:0] l_res_fp_add_req_ready;
 logic [6:0][2:0] l_res_fp_add_req_phase;
 logic [6:0][31:0] l_res_fp_add_req_epoch;
 logic [6:0][95:0] l_res_fp_add_req_tag;
 logic [255:0][31:0] l_res_fp_add_a;
 logic [255:0][31:0] l_res_fp_add_b;
 logic [6:0] l_res_fp_add_rsp_valid;
 logic [6:0] l_res_fp_add_rsp_ready;
 logic [6:0][95:0] l_res_fp_add_rsp_tag;
 logic [255:0][31:0] l_res_fp_add_rsp_data;
 logic [6:0] l_res_fp_mul_pending;
 logic [6:0][6:0] l_res_fp_add_pending;
 logic  l_res_fp_protocol_fault;
 logic  l_res_ln_bind_valid;
 logic  l_res_ln_bind_ready;
 logic [63:0] l_res_ln_bind_request_id;
 logic [31:0] l_res_ln_bind_generation;
 logic [31:0] l_res_ln_bind_epoch;
 logic [3:0] l_res_ln_bind_head;
 logic [2:0] l_res_ln_bind_phase;
 logic [63:0] l_res_ln_op_request_id;
 logic [31:0] l_res_ln_op_generation;
 logic [31:0] l_res_ln_op_epoch;
 logic [2:0] l_res_ln_op_phase;
 logic [63:0] l_res_ln_rsp_request_id;
 logic [31:0] l_res_ln_rsp_generation;
 logic [31:0] l_res_ln_rsp_epoch;
 logic [3:0] l_res_ln_rsp_head;
 logic [2:0] l_res_ln_rsp_phase;
 logic  l_res_ln_wr_valid;
 logic  l_res_ln_wr_ready;
 logic [255:0] l_res_ln_wr_mask;
 logic [255:0][4:0] l_res_ln_wr_addr;
 logic [255:0][31:0] l_res_ln_wr_data;
 logic [95:0] l_res_ln_wr_tag;
 logic  l_res_ln_wr_rsp_valid;
 logic  l_res_ln_wr_rsp_ready;
 logic [95:0] l_res_ln_wr_rsp_tag;
 logic  l_res_ln_rd_valid;
 logic  l_res_ln_rd_ready;
 logic [255:0] l_res_ln_rd_mask;
 logic [255:0][4:0] l_res_ln_rd_addr;
 logic [95:0] l_res_ln_rd_tag;
 logic  l_res_ln_rd_rsp_valid;
 logic  l_res_ln_rd_rsp_ready;
 logic [255:0][31:0] l_res_ln_rd_rsp_data;
 logic [255:0] l_res_ln_rd_rsp_mask;
 logic [95:0] l_res_ln_rd_rsp_tag;
 logic  l_res_ln_idle;
 logic  l_res_sfu_lease_valid;
 logic  l_res_sfu_lease_ready;
 logic [63:0] l_res_sfu_lease_request_id;
 logic [31:0] l_res_sfu_lease_generation;
 logic [31:0] l_res_sfu_lease_epoch;
 logic [3:0] l_res_sfu_lease_head;
 logic [2:0] l_res_sfu_lease_phase;
 logic  l_res_sfu_release_valid;
 logic [2:0] l_res_sfu_release_phase;
 logic [31:0] l_res_sfu_release_epoch;
 logic  l_res_sfu_phase_debt_clear;
 logic  l_res_sfu_lease_active;
 logic [63:0] l_res_sfu_context_valid;
 logic [63:0] l_res_sfu_context_row_hi;
 logic  l_res_sfu_req_valid;
 logic  l_res_sfu_req_ready;
 logic [1:0] l_res_sfu_req_mode;
 logic [31:0] l_res_sfu_req_generation;
 logic [31:0] l_res_sfu_req_epoch;
 logic [2:0] l_res_sfu_req_phase;
 logic [10:0] l_res_sfu_req_tag;
 logic [7:0][31:0] l_res_sfu_req_x;
 logic  l_res_sfu_reject_valid;
 logic  l_res_sfu_rsp_valid;
 logic  l_res_sfu_rsp_ready;
 logic [10:0] l_res_sfu_rsp_tag;
 logic [7:0][31:0] l_res_sfu_rsp_data;
 logic [8:0] l_res_sfu_pending_vectors;
 logic [8:0] l_res_sfu_in_flight_vectors;
 logic  l_res_sfu_protocol_fault;
 logic  l_res_div_lease_valid;
 logic  l_res_div_lease_ready;
 logic [63:0] l_res_div_lease_request_id;
 logic [31:0] l_res_div_lease_generation;
 logic [31:0] l_res_div_lease_epoch;
 logic [3:0] l_res_div_lease_head;
 logic [2:0] l_res_div_lease_phase;
 logic  l_res_div_release_valid;
 logic [2:0] l_res_div_release_phase;
 logic [31:0] l_res_div_release_epoch;
 logic  l_res_div_phase_debt_clear;
 logic  l_res_div_lease_active;
 logic  l_res_div_req_valid;
 logic  l_res_div_req_ready;
 logic [31:0] l_res_div_req_generation;
 logic [31:0] l_res_div_req_epoch;
 logic [2:0] l_res_div_req_phase;
 logic [7:0] l_res_div_req_lane_mask;
 logic [95:0] l_res_div_req_tag;
 logic [7:0][31:0] l_res_div_req_a;
 logic [7:0][31:0] l_res_div_req_b;
 logic  l_res_div_protocol_reject_valid;
 logic  l_res_div_rsp_valid;
 logic  l_res_div_rsp_ready;
 logic [95:0] l_res_div_rsp_tag;
 logic [7:0] l_res_div_rsp_numeric_error;
 logic [7:0][31:0] l_res_div_rsp_data;
 logic [5:0] l_res_div_pending_vectors;
 logic [5:0] l_res_div_in_flight_vectors;
 logic [8:0] l_res_div_in_flight_scalars;
 logic  l_res_div_protocol_fault;
 logic  l_res_scale_valid;
 logic  l_res_scale_ready;
 logic [95:0] l_res_scale_tag;
 logic [3:0][31:0] l_res_scale_input;
 logic  l_res_scale_rsp_valid;
 logic  l_res_scale_rsp_ready;
 logic [95:0] l_res_scale_rsp_tag;
 logic [3:0][31:0] l_res_scale_data;
 logic [6:0] l_res_scale_pending;
 logic  l_res_scale_fault;
 logic  l_rope_owner_valid;
 logic [63:0] l_rope_owner_request_id;
 logic [31:0] l_rope_owner_generation;
 logic [31:0] l_rope_owner_epoch;
 logic  l_rope_wr_valid;
 logic  l_rope_wr_ready;
 logic [63:0] l_rope_wr_request_id;
 logic [31:0] l_rope_wr_generation;
 logic [31:0] l_rope_wr_epoch;
 logic [3:0] l_rope_wr_head;
 logic [6:0] l_rope_wr_token;
 logic [95:0] l_rope_wr_tag;
 logic [63:0][31:0] l_rope_wr_q;
 logic [63:0][31:0] l_rope_wr_k;
 logic  l_rope_wr_commit_valid;
 logic [95:0] l_rope_wr_commit_tag;
 logic  l_rope_reject_valid;
 logic [2:0] l_rope_reject_code;
 logic  l_cache_bound_valid;
 logic [127:0] l_cache_bound_model_id;
 logic [127:0] l_cache_bound_numeric_id;
 logic [127:0] l_cache_bound_table_key;
 logic [1:0] l_cache_family_complete;
 logic  l_cache_owner_valid;
 logic [63:0] l_cache_owner_request_id;
 logic [31:0] l_cache_owner_generation;
 logic [31:0] l_cache_owner_epoch;
 logic  l_cache_rd_valid;
 logic  l_cache_rd_ready;
 logic  l_cache_rd_family;
 logic [6:0] l_cache_rd_row;
 logic [95:0] l_cache_rd_tag;
 logic [63:0] l_cache_rd_request_id;
 logic [31:0] l_cache_rd_generation;
 logic [31:0] l_cache_rd_epoch;
 logic  l_cache_rd_reject_valid;
 logic [2:0] l_cache_rd_reject_code;
 logic  l_cache_rsp_valid;
 logic  l_cache_rsp_ready;
 logic  l_cache_rsp_family;
 logic [6:0] l_cache_rsp_row;
 logic [95:0] l_cache_rsp_tag;
 logic [127:0][31:0] l_cache_rsp_data;
 logic  m_cmd_valid;
 logic  m_cmd_ready;
 logic  m_descriptor_precheck_ok;
 logic [31:0] m_cmd_version;
 logic [63:0] m_cmd_request;
 logic [63:0] m_cmd_model;
 logic [31:0] m_cmd_generation;
 logic [31:0] m_cmd_epoch;
 logic [31:0] m_cmd_tensor;
 logic [15:0] m_cmd_k;
 logic [15:0] m_cmd_n;
 logic  m_cmd_a_slot;
 logic  m_cmd_bias;
 logic [3:0][63:0] m_cmd_base;
 logic [3:0][63:0] m_cmd_span;
 logic  m_done_valid;
 logic  m_done_ready;
 logic [2:0] m_status;
 logic [63:0] m_done_request;
 logic [31:0] m_done_generation;
 logic [31:0] m_done_epoch;
 logic [6:0] m_error_row;
 logic [15:0] m_error_col;
 logic [7:0] m_error_group;
 logic [3:0] m_error_stage;
 logic  m_out_valid;
 logic  m_out_ready;
 logic [31:0][31:0] m_out_data;
 logic [6:0] m_out_row;
 logic [15:0] m_out_col;
 logic [15:0] m_out_s;
 logic [63:0] m_out_request;
 logic [31:0] m_out_generation;
 logic [31:0] m_out_epoch;
 logic  m_acfg_valid;
 logic  m_acfg_ready;
 logic  m_acfg_slot;
 logic [15:0] m_acfg_k;
 logic [63:0] m_acfg_request;
 logic [31:0] m_acfg_generation;
 logic [31:0] m_acfg_epoch;
 logic  m_acfg_rsp_valid;
 logic  m_acfg_rsp_ready;
 logic [1:0] m_acfg_status;
 logic  m_fill_cancel_valid;
 logic  m_fill_cancel_ready;
 logic  m_fill_cancel_slot;
 logic [63:0] m_fill_cancel_request;
 logic [31:0] m_fill_cancel_generation;
 logic [31:0] m_fill_cancel_epoch;
 logic  m_fill_cancel_reject_valid;
 logic [3:0] m_fill_cancel_reject_code;
 logic  m_fill_cancel_rsp_valid;
 logic  m_fill_cancel_rsp_ready;
 logic  m_fill_cancel_rsp_slot;
 logic [63:0] m_fill_cancel_rsp_request;
 logic [31:0] m_fill_cancel_rsp_generation;
 logic [31:0] m_fill_cancel_rsp_epoch;
 logic  m_awr_valid;
 logic  m_awr_ready;
 logic [6:0] m_awr_row;
 logic [6:0] m_awr_group;
 logic [271:0] m_awr_data;
 logic [63:0] m_awr_request;
 logic [31:0] m_awr_generation;
 logic [31:0] m_awr_epoch;
 logic  m_awr_rsp_valid;
 logic  m_awr_rsp_ready;
 logic  m_coef_cfg_valid;
 logic  m_coef_cfg_ready;
 logic [63:0] m_coef_model;
 logic [63:0] m_coef_request;
 logic [31:0] m_coef_tensor;
 logic [31:0] m_coef_generation;
 logic [31:0] m_coef_epoch;
 logic [15:0] m_coef_n;
 logic  m_coef_wr_valid;
 logic  m_coef_wr_ready;
 logic [6:0] m_coef_wr_addr;
 logic [31:0][31:0] m_coef_wr_data;
 logic  m_coef_rsp_valid;
 logic  m_coef_rsp_ready;
 logic [1:0] m_coef_status;
 logic [15:0] m_coef_error_col;
 logic [3:0] m_arvalid;
 logic [3:0] m_arready;
 logic [3:0][63:0] m_araddr;
 logic [3:0][2:0] m_arid;
 logic [3:0][7:0] m_arlen;
 logic [3:0] m_rvalid;
 logic [3:0] m_rready;
 logic [3:0][2:0] m_rid;
 logic [3:0][511:0] m_rdata;
 logic [3:0][1:0] m_rresp;
 logic [3:0] m_rlast;
 logic  m_run_enable;
 logic [31:0] m_elapsed_cycles;
 logic [31:0] m_first_output_cycle;
 logic [31:0] m_w_wait_cycles;
 logic [31:0] m_ctx_wait_cycles;
 logic [15:0] m_blocks_issued;
 logic [15:0] m_blocks_computed;
 logic [15:0] m_blocks_retired;
 logic [31:0] m_ps_merged_reads;
 logic [31:0] m_ps_response_holds;
 logic [31:0] m_bias_add_conflicts;
 logic [31:0] m_compute_output_overlap;
 logic [7:0] m_peak_return_reservations;
 logic [6:0] m_arithmetic_debt;
 logic [6:0] m_peak_arithmetic_reservations;
 logic  m_profile_valid;
 logic [63:0] m_fp_owner_request;
 logic [31:0] m_fp_owner_generation;
 logic [31:0] m_fp_owner_epoch;
 logic  m_bind_new_lease;
 logic  m_fp_release_valid;
 logic  m_fp_phase_debt_clear;
 logic  m_fp_lease_ready;
 logic  m_fp_release_ready;
 logic  m_fp_lease_active;
 logic  m_fp_draining;
 logic  m_fp_fault;
 logic  m_storage_bind_ready;
 logic  m_storage_idle;
 logic  m_mul_req_valid;
 logic  m_mul_rsp_ready;
 logic  m_mul_req_ready;
 logic  m_mul_rsp_valid;
 logic [95:0] m_mul_req_tag;
 logic [95:0] m_mul_rsp_tag;
 logic [255:0][31:0] m_mul_a;
 logic [255:0][31:0] m_mul_b;
 logic [255:0][31:0] m_mul_rsp_data;
 logic [6:0] m_mul_pending;
 logic [6:0] m_add_req_valid;
 logic [6:0] m_add_req_is_root;
 logic [6:0] m_add_rsp_ready;
 logic [6:0] m_add_req_ready;
 logic [6:0] m_add_rsp_valid;
 logic [6:0][2:0] m_add_req_phase;
 logic [6:0][31:0] m_add_req_epoch;
 logic [6:0][95:0] m_add_req_tag;
 logic [6:0][95:0] m_add_rsp_tag;
 logic [255:0][31:0] m_add_a;
 logic [255:0][31:0] m_add_b;
 logic [255:0][31:0] m_add_rsp_data;
 logic [6:0][6:0] m_add_pending;
 logic  m_ps_wr_valid;
 logic  m_ps_wr_rsp_ready;
 logic  m_ps_rd_valid;
 logic  m_ps_rd_rsp_ready;
 logic  m_ps_wr_ready;
 logic  m_ps_wr_rsp_valid;
 logic  m_ps_rd_ready;
 logic  m_ps_rd_rsp_valid;
 logic [1023:0] m_ps_wr_mask;
 logic [1023:0] m_ps_rd_mask;
 logic [1023:0] m_ps_rd_rsp_mask;
 logic [1023:0][3:0] m_ps_wr_addr;
 logic [1023:0][3:0] m_ps_rd_addr;
 logic [1023:0][31:0] m_ps_wr_data;
 logic [1023:0][31:0] m_ps_rd_rsp_data;
 logic [95:0] m_ps_wr_tag;
 logic [95:0] m_ps_rd_tag;
 logic [95:0] m_ps_wr_rsp_tag;
 logic [95:0] m_ps_rd_rsp_tag;
 logic  q_run_enable;
 logic  q_cmd_valid;
 logic  q_cmd_ready;
 logic  q_cmd_slot;
 logic [15:0] q_cmd_k;
 logic [63:0] q_cmd_request;
 logic [31:0] q_cmd_generation;
 logic [31:0] q_cmd_epoch;
 logic  q_in_valid;
 logic  q_in_ready;
 logic [31:0][31:0] q_in_data;
 logic [63:0] q_in_request;
 logic [31:0] q_in_generation;
 logic [31:0] q_in_epoch;
 logic [7:0] q_in_row;
 logic [7:0] q_in_group;
 logic  q_producer_close_valid;
 logic  q_producer_close_ready;
 logic  q_producer_close_success;
 logic  q_done_valid;
 logic  q_done_ready;
 logic [2:0] q_status;
 logic [2:0] q_quant_phase;
 logic [6:0] q_quant_row;
 logic [6:0] q_quant_group;
 logic [4:0] q_quant_element;
 logic [31:0] q_quant_accepted;
 logic [31:0] q_quant_retired;
 logic [31:0] q_a_writes;
 logic [31:0] q_a_write_acks;
 logic  q_quant_last_event;
 logic  q_a_publish_event;
 logic  q_acfg_valid;
 logic  q_acfg_ready;
 logic  q_acfg_slot;
 logic [15:0] q_acfg_k;
 logic [63:0] q_acfg_request;
 logic [31:0] q_acfg_generation;
 logic [31:0] q_acfg_epoch;
 logic  q_acfg_rsp_valid;
 logic  q_acfg_rsp_ready;
 logic [1:0] q_acfg_status;
 logic  q_awr_valid;
 logic  q_awr_ready;
 logic [6:0] q_awr_row;
 logic [6:0] q_awr_group;
 logic [271:0] q_awr_data;
 logic [63:0] q_awr_request;
 logic [31:0] q_awr_generation;
 logic [31:0] q_awr_epoch;
 logic  q_awr_rsp_valid;
 logic  q_awr_rsp_ready;
 logic  q_fill_cancel_valid;
 logic  q_fill_cancel_ready;
 logic  q_fill_cancel_slot;
 logic [63:0] q_fill_cancel_request;
 logic [31:0] q_fill_cancel_generation;
 logic [31:0] q_fill_cancel_epoch;
 logic  q_fill_cancel_reject_valid;
 logic [3:0] q_fill_cancel_reject_code;
 logic  q_fill_cancel_rsp_valid;
 logic  q_fill_cancel_rsp_ready;
 logic  q_fill_cancel_rsp_slot;
 logic [63:0] q_fill_cancel_rsp_request;
 logic [31:0] q_fill_cancel_rsp_generation;
 logic [31:0] q_fill_cancel_rsp_epoch;
 logic  q_d_lease_valid;
 logic  q_d_lease_ready;
 logic [63:0] q_d_lease_request_id;
 logic [31:0] q_d_lease_generation;
 logic [31:0] q_d_lease_epoch;
 logic [3:0] q_d_lease_head;
 logic [2:0] q_d_lease_phase;
 logic  q_d_release_valid;
 logic  q_d_release_ready;
 logic [2:0] q_d_release_phase;
 logic [31:0] q_d_release_epoch;
 logic  q_d_phase_debt_clear;
 logic  q_d_lease_active;
 logic  q_d_draining;
 logic [63:0] q_d_rsp_request_id;
 logic [31:0] q_d_rsp_generation;
 logic [31:0] q_d_rsp_epoch;
 logic [3:0] q_d_rsp_head;
 logic [2:0] q_d_rsp_phase;
 logic  q_d_req_valid;
 logic  q_d_req_ready;
 logic [31:0] q_d_req_generation;
 logic [31:0] q_d_req_epoch;
 logic [2:0] q_d_req_phase;
 logic [7:0] q_d_req_lane_mask;
 logic [95:0] q_d_req_tag;
 logic [7:0][31:0] q_d_req_a;
 logic [7:0][31:0] q_d_req_b;
 logic  q_d_protocol_reject_valid;
 logic [3:0] q_d_protocol_reject_code;
 logic  q_d_rsp_valid;
 logic  q_d_rsp_ready;
 logic [95:0] q_d_rsp_tag;
 logic [7:0] q_d_rsp_lane_mask;
 logic [7:0] q_d_rsp_numeric_error;
 logic [7:0][31:0] q_d_rsp_data;
 logic [5:0] q_d_pending_vectors;
 logic [5:0] q_d_in_flight_vectors;
 logic [8:0] q_d_in_flight_scalars;
 logic  q_d_protocol_fault;
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

 localparam [4:0] IDLE=0,PREP=1,QSUB=2,QRUN=3,QMSUB=4,QMRUN=5,LSTART=6,LRUN=7,CSUB=8,CRUN=9,CDRAIN=10,WMSUB=11,WMRUN=12,PCANCEL=13,PCWAIT=14,DISCARD=15,DISCWAIT=16,FINISH=17,ACANCEL=18,ACWAIT=19;
 localparam [4:0] F_ARENA=20,F_NQSUB=21,F_NQRUN=22,F_WISUB=23,F_GQSUB=24,F_RUN=25,F_CLOSE=26,F_QDRAIN=27,F_ABORT=28,F_DISCARD=29,F_RELEASE=30,F_RETURN=31;
  logic [4:0] state;
 logic [63:0] request_id;logic [31:0] generation,epoch;
 logic [1:0] kind;logic [4:0] layer_index;logic [127:0] mask;
 logic [1:0][31:0] tensor_id;logic [1:0][3:0][63:0] base,span;
 logic [12:0] inputs_accepted;
 logic producer_failed,context_failed;
  logic g_producer_cancel_valid;
  logic g_producer_cancel_ready;
  logic [63:0] g_producer_cancel_request_id;
  logic [31:0] g_producer_cancel_generation;
  logic [31:0] g_producer_cancel_epoch;
  logic g_producer_cancel_reject_valid;
  logic g_done_cancelled;
  logic g_cmd_valid;
  logic g_cmd_ready;
  logic [63:0] g_cmd_request_id;
  logic [31:0] g_cmd_generation;
  logic [31:0] g_cmd_epoch;
  logic g_storage_owner_valid;
  logic [63:0] g_storage_owner_request_id;
  logic [31:0] g_storage_owner_generation;
  logic [31:0] g_storage_owner_epoch;
  logic [2:0] g_storage_owner_phase;
  logic g_sfu_owner_valid;
  logic [63:0] g_sfu_owner_request_id;
  logic [31:0] g_sfu_owner_generation;
  logic [31:0] g_sfu_owner_epoch;
  logic [2:0] g_sfu_owner_phase;
  logic g_fill_valid;
  logic g_fill_ready;
  logic [63:0] g_fill_request_id;
  logic [31:0] g_fill_generation;
  logic [31:0] g_fill_epoch;
  logic g_fill_slot;
  logic g_fill_half;
  logic [6:0] g_fill_s;
  logic [6:0] g_fill_row;
  logic [31:0][31:0] g_fill_data;
  logic g_fill_reject_valid;
  logic [1:0] g_fill_reject_code;
  logic g_out_valid;
  logic g_out_ready;
  logic [7:0][31:0] g_out_data;
  logic [7:0][31:0] g_out_status;
  logic [95:0] g_out_tag;
  logic [6:0] g_out_s;
  logic [6:0] g_out_row;
  logic [1:0] g_out_chunk;
  logic g_done_valid;
  logic g_done_ready;
  logic [31:0] g_done_status;
  logic [2:0] g_done_error_rank;
  logic [6:0] g_done_error_row;
  logic [11:0] g_done_error_column;
  logic [63:0] g_rsp_request_id;
  logic [31:0] g_rsp_generation;
  logic [31:0] g_rsp_epoch;
  logic g_discard_valid;
  logic g_discard_ready;
  logic [63:0] g_discard_request_id;
  logic [31:0] g_discard_generation;
  logic [31:0] g_discard_epoch;
  logic g_discard_reject_valid;
  logic g_engine_idle;
  logic g_active;
  logic g_needs_discard;
  logic g_protocol_fault;
  logic [1:0] g_slot_active;
  logic [1:0] g_slot_ready;
  logic [1:0][6:0] g_slot_s;
  logic [1:0][9:0] g_slot_consumed_vectors;
  logic [1:0][8:0] g_slot_math_pending;
  logic [1:0][8:0] g_slot_sfu_debt;
  logic [1:0][7:0] g_slot_fp_debt;
  logic [7:0][18:0] g_covered;
  logic [7:0][18:0] g_evaluated;
  logic g_pool_reset_n;
  logic [8:0] g_fp_req_valid;
  logic [8:0] g_fp_req_ready;
  logic [8:0][95:0] g_fp_req_tag;
  logic [8:0][7:0][31:0] g_fp_req_a;
  logic [8:0][7:0][31:0] g_fp_req_b;
  logic [8:0] g_fp_rsp_valid;
  logic [8:0][95:0] g_fp_rsp_tag;
  logic [8:0][7:0][31:0] g_fp_rsp_data;
  logic [8:0][7:0][31:0] g_fp_rsp_status;
  logic g_fp_pool_fault;
  logic g_sfu_req_valid;
  logic g_sfu_req_ready;
  logic [95:0] g_sfu_req_tag;
  logic [7:0] g_sfu_req_mask;
  logic [7:0][31:0] g_sfu_req_x;
  logic g_sfu_rsp_valid;
  logic g_sfu_rsp_ready;
  logic [95:0] g_sfu_rsp_tag;
  logic [7:0][31:0] g_sfu_rsp_data;
  logic [7:0][31:0] g_sfu_rsp_status;
  logic g_sfu_protocol_fault;
  logic g_sfu_reject_valid;
  logic g_g_wr_valid;
  logic g_g_wr_ready;
  logic [255:0] g_g_wr_mask;
  logic [255:0][5:0] g_g_wr_addr;
  logic [255:0][31:0] g_g_wr_data;
  logic [95:0] g_g_wr_tag;
  logic g_g_wr_rsp_valid;
  logic g_g_wr_rsp_ready;
  logic [95:0] g_g_wr_rsp_tag;
  logic g_g_rd_valid;
  logic g_g_rd_ready;
  logic [255:0] g_g_rd_mask;
  logic [255:0][5:0] g_g_rd_addr;
  logic [95:0] g_g_rd_tag;
  logic g_g_rd_rsp_valid;
  logic g_g_rd_rsp_ready;
  logic [255:0][31:0] g_g_rd_rsp_data;
  logic [255:0] g_g_rd_rsp_mask;
  logic [95:0] g_g_rd_rsp_tag;
  logic ws_owner_req_valid,ws_owner_req_g,ws_owner_req_ready,ws_a_enable,ws_g_enable,ws_rearm,ws_owner_g;
  logic [15:0] pack_seq; logic pack_full,pack_fault,g_cancel_sent,q_close_sent;
  logic [31:0][31:0] pack_data;
  wire [15:0] pack_previous=pack_seq-1'b1;
  wire ffn_mode=kind==3;
  wire ffn_state=state>=20;

  wire [8:0] tanh_pending,tanh_flight;
  logic tanh_lease_ready,tanh_lease_active,tanh_draining,tanh_release_ready;
  logic [63:0] tanh_request;logic [31:0] tanh_generation,tanh_epoch;logic [2:0] tanh_phase;
  logic [7:0] tanh_rsp_mask;logic [1:0] tanh_reject_code;
  wire g_all_covered=&{g_covered[0]==335872,g_covered[1]==335872,g_covered[2]==335872,g_covered[3]==335872,g_covered[4]==335872,g_covered[5]==335872,g_covered[6]==335872,g_covered[7]==335872};
  wire g_output_fire=g_out_valid&&g_out_ready;
  wire ffn_close_fire=q_producer_close_valid&&q_producer_close_ready;
  wire ffn_failure=pack_fault||g_protocol_fault||done_status!=0;
 wire producer_fail_fire=producer_fail_valid&&producer_fail_ready;
 wire producer_failure=producer_failed||producer_fail_fire;
 function automatic logic [7:0] matrix_status_map(input logic [2:0] v);
  case(v)0:return 0;1:return 5;2:return 1;default:return 2;endcase
 endfunction
 function automatic logic [7:0] layer_status_map(input logic [7:0] v);
  case(v)0:return 0;1:return 1;2:return 6;default:return 2;endcase
 endfunction
 wire context_phase=state==CSUB||state==CRUN||state==CDRAIN||state==DISCARD||state==DISCWAIT;
 wire matrix_owner=(state>=QSUB&&state<=QMRUN)||state==WMSUB||state==WMRUN||ffn_state;
 wire front_owner=matrix_owner||context_phase;
 wire wo_phase=state==WMSUB||state==WMRUN;
 wire legal_input=(state==QRUN||state==F_NQRUN)&&!producer_failed&&inputs_accepted<4096&&in_request==request_id&&in_generation==generation&&in_epoch==epoch&&in_row=={1'b0,inputs_accepted[11:5]}&&in_group=={3'b0,inputs_accepted[4:0]};
 wire identity_ok=cmd_model_id==MODEL_ID&&cmd_numeric_id==NUMERIC_ID&&cmd_table_key==TABLE_KEY&&cmd_graph_id==GRAPH_ID&&cmd_layout_id==LAYOUT_ID&&cmd_build_id==BUILD_ID;
 wire tables_ready=cmd_kind==3||cmd_kind==2||(coeff_bound_valid&&coeff_bound_model_id==MODEL_ID&&coeff_bound_numeric_id==NUMERIC_ID&&coeff_bound_table_key==TABLE_KEY&&coeff_family_complete[cmd_kind==1]);
 logic spans_ok;
 always_comb begin
  spans_ok=1;
  for(int t=0;t<2;t++)for(int p=0;p<4;p++)begin
   if(cmd_base[t][p][11:0]!=0||cmd_span[t][p]<(cmd_kind==3?(t==0?64'd1511424:64'd755712):(t==0?64'd884736:64'd294912))||({1'b0,cmd_base[t][p]}+{1'b0,cmd_span[t][p]})>65'hffffffffffffffff)spans_ok=0;
  end
 end
 wire tensor_ok=cmd_tensor[0]==tensor_key(cmd_kind,cmd_layer,0)&&cmd_tensor[1]==tensor_key(cmd_kind,cmd_layer,1);
 wire bias_identity_ok=bias_model_id==MODEL_ID&&bias_numeric_id==NUMERIC_ID&&coef_model==MODEL_ID[63:0]&&coef_request==(state==IDLE?cmd_request:request_id)&&coef_generation==(state==IDLE?cmd_generation:generation)&&coef_epoch==(state==IDLE?cmd_epoch:epoch)&&coef_tensor==tensor_key(state==IDLE?cmd_kind:kind,state==IDLE?cmd_layer:layer_index,coef_n==1024)&&((coef_n==3072&&state==IDLE)||(coef_n==1024&&(state==IDLE||state==LRUN||state==CSUB||state==CRUN||state==CDRAIN)));
 wire kind_ok=(cmd_kind==0&&cmd_layer<28&&cmd_layer%3==0)||(cmd_kind==1&&cmd_layer<28&&cmd_layer%3!=0)||(cmd_kind==2&&cmd_layer<2)||(cmd_kind==3&&cmd_layer==0);
 logic c_rd_valid,c_rd_ready,c_rsp_valid,c_rsp_ready,c_out_valid,c_out_ready,c_idle,c_complete,c_fault,c_start_ready;
 logic [31:0] c_rd_generation,c_rd_tag,c_rsp_tag;logic [3:0] c_rd_head;logic [6:0] c_rd_query;logic c_rd_half;
 logic [31:0][31:0] c_rsp_data,c_out_data;logic [7:0] c_out_row,c_out_group;logic [12:0] c_accepted,c_consumed;
 assign parent_state=state;
 assign cmd_ready=rst_n&&state==IDLE&&l_layer_idle&&!coef_cfg_valid&&!coef_wr_valid;
 assign done_valid=state==FINISH;
 assign done_request=request_id;assign done_generation=generation;assign done_epoch=epoch;
 assign producer_fail_ready=rst_n&&!producer_failed&&producer_fail_request==request_id&&producer_fail_generation==generation&&producer_fail_epoch==epoch&&(state==QRUN||state==QMRUN||state==CRUN||state==F_NQRUN);
 assign in_ready=legal_input&&q_in_ready;
 assign input_reject_valid=rst_n&&in_valid&&!legal_input;
 assign input_reject_code=state!=QRUN?1:in_request!=request_id?2:in_generation!=generation?3:in_epoch!=epoch?4:in_row!={1'b0,inputs_accepted[11:5]}?5:6;
 assign out_valid=state==WMRUN&&m_out_valid;assign out_data=m_out_data;assign out_row=m_out_row;assign out_col=m_out_col;
 assign layer_head_completed=l_head_completed;
 always_ff @(posedge clk)begin
  if(!rst_n)begin state<=IDLE;request_id<=0;generation<=0;epoch<=0;kind<=0;layer_index<=0;mask<=0;tensor_id<=0;base<=0;span<=0;inputs_accepted<=0;producer_failed<=0;context_failed<=0;done_status<=0;error_domain<=0;error_tuple<=0;source_status<=0;elapsed_cycles<=0;end
  else begin
   if(state!=IDLE&&state!=FINISH)elapsed_cycles<=elapsed_cycles+1;
   if(cmd_valid&&cmd_ready)begin
    request_id<=cmd_request;generation<=cmd_generation;epoch<=cmd_epoch;kind<=cmd_kind;layer_index<=cmd_layer;mask<=cmd_mask;tensor_id<=cmd_tensor;base<=cmd_base;span<=cmd_span;inputs_accepted<=0;producer_failed<=0;context_failed<=0;done_status<=0;error_domain<=0;error_tuple<=0;source_status<=0;elapsed_cycles<=0;
    if(!identity_ok||!kind_ok||!tensor_ok)begin state<=FINISH;done_status<=4;error_domain<=1;end else if(!tables_ready||!spans_ok)begin state<=FINISH;done_status<=5;source_status<=1;error_domain<=1;end else state<=cmd_kind==3?F_ARENA:PREP;
   end
   if(producer_fail_fire)begin producer_failed<=1;done_status<=3;source_status<=3;error_domain<=2;error_tuple<=producer_fail_tuple;end
   if(in_valid&&in_ready)inputs_accepted<=inputs_accepted+1;
   if(state==PREP&&l_prepare_valid&&l_prepare_ready)state<=QSUB;
   if(state==QSUB)begin
    if(!m_descriptor_precheck_ok)begin state<=PCANCEL;done_status<=5;source_status<=1;error_domain<=1;end
    else if(q_cmd_valid&&q_cmd_ready)state<=QRUN;
   end
   if(state==QRUN&&q_done_valid&&q_done_ready)begin
    if(q_status!=0||producer_failure)begin
     state<=producer_failure?ACANCEL:PCANCEL;
     if(!producer_failure)begin done_status<=matrix_status_map(q_status);source_status<={5'b0,q_status};error_domain<=3;error_tuple<={8'b0,16'(q_quant_phase),16'(q_quant_row),16'(q_quant_group),16'(q_quant_element),24'b0};end
    end else state<=QMSUB;
   end
   if(state==QMSUB&&m_cmd_valid&&m_cmd_ready)state<=QMRUN;
   if(state==QMRUN&&m_done_valid&&m_done_ready)begin
    if(m_status!=0||producer_failure)begin
     state<=producer_failure?ACANCEL:PCANCEL;
     if(!producer_failure)begin done_status<=matrix_status_map(m_status);source_status<={5'b0,m_status};error_domain<=4;error_tuple<={8'b0,16'(m_error_stage),16'(m_error_row),m_error_col,16'(m_error_group),24'b0};end
    end else state<=LSTART;
   end
   if(state==ACANCEL&&m_fill_cancel_valid&&m_fill_cancel_ready)state<=ACWAIT;
   if(state==ACWAIT&&m_fill_cancel_rsp_valid&&m_fill_cancel_rsp_ready)state<=PCANCEL;
   if(state==PCANCEL&&l_prepare_cancel_valid&&l_prepare_cancel_ready)state<=PCWAIT;
   if(state==PCWAIT&&l_prepare_cancel_rsp_valid&&l_prepare_cancel_rsp_ready)state<=DISCWAIT;
   if(state==LSTART&&l_start_valid&&l_start_ready)state<=LRUN;
   if(state==LRUN&&l_done_valid&&l_done_ready)begin
    if(l_done_status!=0)begin state<=DISCWAIT;done_status<=layer_status_map(l_done_status);source_status<=l_done_status;error_domain<=5;error_tuple<=l_error_tuple;end
    else state<=CSUB;
   end
   if(state==CSUB&&q_cmd_valid&&q_cmd_ready&&c_start_ready)begin state<=CRUN;inputs_accepted<=0;end
   if(state==CRUN&&q_done_valid&&q_done_ready)begin
    state<=CDRAIN;
    if(q_status!=0||producer_failure||c_fault)begin context_failed<=1;if(!producer_failure)begin done_status<=q_status==0?2:matrix_status_map(q_status);source_status<={5'b0,q_status};error_domain<=3;error_tuple<={8'b0,16'(q_quant_phase),16'(q_quant_row),16'(q_quant_group),16'(q_quant_element),24'b0};end end
   end
   if(state==CDRAIN&&c_idle)begin
    if(context_failed)begin if(l_layer_idle)state<=FINISH;else state<=DISCARD;end
    else if(c_complete&&l_layer_idle)state<=WMSUB;
   end
   if(state==DISCARD&&l_result_discard_valid&&l_result_discard_ready)state<=DISCWAIT;
   if(state==DISCWAIT&&l_layer_idle)state<=FINISH;
   if(state==WMSUB&&m_cmd_valid&&m_cmd_ready)state<=WMRUN;
   if(state==WMRUN&&m_done_valid&&m_done_ready)begin state<=ffn_mode?F_RETURN:FINISH;done_status<=matrix_status_map(m_status);source_status<={5'b0,m_status};error_domain<=m_status==0?0:4;error_tuple<={8'b0,16'(m_error_stage),16'(m_error_row),m_error_col,16'(m_error_group),24'b0};end
   
    if(state==F_ARENA&&ws_g_enable)state<=F_NQSUB;
    if(state==F_NQSUB&&q_cmd_valid&&q_cmd_ready)state<=F_NQRUN;
    if(state==F_NQRUN&&q_done_valid&&q_done_ready)begin
     if(q_status!=0||producer_failure)begin state<=F_RELEASE;if(!producer_failure)begin done_status<=matrix_status_map(q_status);source_status<={5'b0,q_status};error_domain<=3;error_tuple<={8'd1,16'(q_quant_phase),16'(q_quant_row),16'(q_quant_group),16'(q_quant_element),24'b0};end end
     else state<=F_WISUB;
    end
    if(state==F_WISUB&&m_cmd_valid&&m_cmd_ready)state<=F_GQSUB;
    if(state==F_GQSUB&&g_cmd_valid&&g_cmd_ready&&q_cmd_valid&&q_cmd_ready)state<=F_RUN;
    if((state==F_RUN||state==F_GQSUB)&&(pack_fault||g_protocol_fault||(m_done_valid&&m_status!=0)))state<=F_ABORT;
    if(state==F_RUN&&m_done_valid&&m_status==0&&g_done_valid)begin
     if(g_done_status!=0||g_done_cancelled)state<=F_ABORT;
     else if(pack_seq==41984&&!pack_full&&g_all_covered&&q_quant_accepted==10496)state<=F_CLOSE;
    end
    if(state==F_CLOSE&&ffn_close_fire)state<=F_QDRAIN;
    if(state==F_QDRAIN&&q_done_valid&&q_done_ready)begin
     state<=F_RELEASE;
     if(q_status!=0)begin done_status<=matrix_status_map(q_status);source_status<={5'b0,q_status};error_domain<=3;error_tuple<={8'd4,16'(q_quant_phase),16'(q_quant_row),16'(q_quant_group),16'(q_quant_element),24'b0};end
    end
    if(state==F_ABORT)begin
     if(m_done_valid&&m_done_ready&&m_status!=0)begin done_status<=matrix_status_map(m_status);source_status<={5'b0,m_status};error_domain<=4;error_tuple<={8'd2,16'(m_error_stage),16'(m_error_row),m_error_col,16'(m_error_group),24'b0};end
     else if(g_done_valid&&g_done_ready&&error_domain!=4)begin done_status<=g_done_status==6?8'd1:8'd2;source_status<=g_done_status==6?8'd6:8'd8;error_domain<=6;error_tuple<={8'd3,16'(g_done_error_rank),16'(g_done_error_row),16'(g_done_error_column),16'b0,24'b0};end
     else if((pack_fault||g_protocol_fault)&&done_status==0)begin done_status<=2;source_status<=8;error_domain<=7;error_tuple<={8'd3,56'b0,16'b0,pack_seq};end
     if(m_cmd_ready&&!g_active&&!g_done_valid&&q_cmd_ready&&(g_needs_discard||g_engine_idle))state<=F_DISCARD;
    end
    if(state==F_DISCARD&&(!g_needs_discard||(g_discard_valid&&g_discard_ready)))state<=F_RELEASE;
    if(state==F_RELEASE&&g_engine_idle&&!tanh_lease_active&&r_res_st_idle&&!r_res_fp_lease_active&&!r_res_div_lease_active&&m_cmd_ready&&q_cmd_ready)state<=done_status==0?WMSUB:F_RETURN;
    if(state==F_RETURN&&ws_a_enable)state<=FINISH;
    if(done_valid&&done_ready)state<=IDLE;
  end
 end
 assign coef_cfg_ready=m_coef_cfg_ready&&bias_identity_ok;
 assign coef_wr_ready=m_coef_wr_ready;
 assign coef_rsp_valid=m_coef_rsp_valid;
 assign coef_status=m_coef_status;
 assign coef_error_col=m_coef_error_col;
 assign arvalid=m_arvalid;
 assign araddr=m_araddr;
 assign arid=m_arid;
 assign arlen=m_arlen;
 assign rready=m_rready;
 laya_rope_coeff_cache_v1 coeff(.clk(clk),.rst_n(rst_n),.bind_valid(coeff_bind_valid),.bind_ready(coeff_bind_ready),.bind_model_id(coeff_bind_model_id),.bind_numeric_id(coeff_bind_numeric_id),.bind_table_key(coeff_bind_table_key),.bound_valid(coeff_bound_valid),.bound_model_id(coeff_bound_model_id),.bound_numeric_id(coeff_bound_numeric_id),.bound_table_key(coeff_bound_table_key),.family_complete(coeff_family_complete),.wr_valid(coeff_wr_valid),.wr_ready(coeff_wr_ready),.wr_model_id(coeff_wr_model_id),.wr_numeric_id(coeff_wr_numeric_id),.wr_table_key(coeff_wr_table_key),.wr_table(coeff_wr_table),.wr_row(coeff_wr_row),.wr_half(coeff_wr_half),.wr_data(coeff_wr_data),.wr_reject_valid(coeff_wr_reject_valid),.wr_reject_code(coeff_wr_reject_code),.wr_nonfinite_lane(coeff_wr_nonfinite_lane),.owner_valid(l_cache_owner_valid),.owner_request_id(l_cache_owner_request_id),.owner_generation(l_cache_owner_generation),.owner_epoch(l_cache_owner_epoch),.rd_valid(l_cache_rd_valid),.rd_ready(l_cache_rd_ready),.rd_family(l_cache_rd_family),.rd_row(l_cache_rd_row),.rd_tag(l_cache_rd_tag),.rd_request_id(l_cache_rd_request_id),.rd_generation(l_cache_rd_generation),.rd_epoch(l_cache_rd_epoch),.rd_reject_valid(l_cache_rd_reject_valid),.rd_reject_code(l_cache_rd_reject_code),.rsp_valid(l_cache_rsp_valid),.rsp_ready(l_cache_rsp_ready),.rsp_family(l_cache_rsp_family),.rsp_row(l_cache_rsp_row),.rsp_tag(l_cache_rsp_tag),.rsp_data(l_cache_rsp_data));
 assign l_prepare_valid=state==PREP;
 assign l_prepare_request_id=request_id;
 assign l_prepare_model_id=MODEL_ID;
 assign l_prepare_generation=generation;
 assign l_prepare_epoch=epoch;
 assign l_prepare_numeric_id=NUMERIC_ID;
 assign l_prepare_table_key=TABLE_KEY;
 assign l_prepare_kind=kind;
 assign l_prepare_layer=layer_index;
 assign l_prepare_mask=mask;
 assign l_qkv_wr_valid=ffn_mode?(!ffn_mode&&state==QMRUN&&m_out_valid):(state==QMRUN&&m_out_valid);
 assign l_qkv_wr_request_id=m_out_request;
 assign l_qkv_wr_generation=m_out_generation;
 assign l_qkv_wr_epoch=m_out_epoch;
 assign l_qkv_wr_plane=m_out_col[11:10];
 assign l_qkv_wr_head=m_out_col[9:6];
 assign l_qkv_wr_token=m_out_row;
 assign l_qkv_wr_half=m_out_col[5];
 assign l_qkv_wr_data=m_out_data;
 assign l_start_valid=state==LSTART;
 assign l_start_request_id=request_id;
 assign l_start_generation=generation;
 assign l_abort_valid=1'b0;
 assign l_qkv_read_grant=3'b111;
 assign l_ps_grant=1'b1;
 assign l_g_grant=1'b1;
 assign l_context_grant=1'b1;
 assign l_fp_grant=1'b1;
 assign l_sfu_grant=1'b1;
 assign l_exp_grant=1'b1;
 assign l_div_grant=1'b1;
 assign l_rope_write_grant=1'b1;
 assign l_done_ready=state==LRUN;
 assign l_result_rd_valid=c_rd_valid;
 assign l_result_rd_generation=c_rd_generation;
 assign l_result_rd_tag=c_rd_tag;
 assign l_result_rd_head=c_rd_head;
 assign l_result_rd_query=c_rd_query;
 assign l_result_rd_half=c_rd_half;
 assign l_result_rsp_ready=c_rsp_ready;
 assign l_result_discard_valid=state==DISCARD;
 assign l_result_discard_generation=generation;
 assign l_prepare_cancel_valid=state==PCANCEL;
 assign l_prepare_cancel_request_id=request_id;
 assign l_prepare_cancel_generation=generation;
 assign l_prepare_cancel_epoch=epoch;
 assign l_prepare_cancel_rsp_ready=state==PCWAIT;
 assign l_res_qkv_wr_ready=r_res_qkv_wr_ready;
 assign l_res_qkv_rd_ready=r_res_qkv_rd_ready;
 assign l_res_qkv_rd_rsp_valid=r_res_qkv_rd_rsp_valid;
 assign l_res_qkv_rd_rsp_head=r_res_qkv_rd_rsp_head;
 assign l_res_qkv_rd_rsp_token=r_res_qkv_rd_rsp_token;
 assign l_res_qkv_rd_rsp_tag=r_res_qkv_rd_rsp_tag;
 assign l_res_qkv_rd_rsp_data=r_res_qkv_rd_rsp_data;
 assign l_res_st_bind_ready=(matrix_owner?'0:r_res_st_bind_ready);
 assign l_res_st_rsp_request_id=r_res_st_rsp_request_id;
 assign l_res_st_rsp_generation=r_res_st_rsp_generation;
 assign l_res_st_rsp_epoch=r_res_st_rsp_epoch;
 assign l_res_st_rsp_head=r_res_st_rsp_head;
 assign l_res_st_rsp_phase=r_res_st_rsp_phase;
 assign l_res_st_ps_wr_ready=(matrix_owner?'0:r_res_st_ps_wr_ready);
 assign l_res_st_ps_wr_rsp_valid=(matrix_owner?'0:r_res_st_ps_wr_rsp_valid);
 assign l_res_st_ps_wr_rsp_tag=(matrix_owner?'0:r_res_st_ps_wr_rsp_tag);
 assign l_res_st_ps_rd_ready=(matrix_owner?'0:r_res_st_ps_rd_ready);
 assign l_res_st_ps_rd_rsp_valid=(matrix_owner?'0:r_res_st_ps_rd_rsp_valid);
 assign l_res_st_ps_rd_rsp_data=(matrix_owner?'0:r_res_st_ps_rd_rsp_data);
 assign l_res_st_ps_rd_rsp_mask=(matrix_owner?'0:r_res_st_ps_rd_rsp_mask);
 assign l_res_st_ps_rd_rsp_tag=(matrix_owner?'0:r_res_st_ps_rd_rsp_tag);
 assign l_res_st_g_wr_ready=r_res_st_g_wr_ready;
 assign l_res_st_g_wr_rsp_valid=r_res_st_g_wr_rsp_valid;
 assign l_res_st_g_wr_rsp_tag=r_res_st_g_wr_rsp_tag;
 assign l_res_st_g_rd_ready=r_res_st_g_rd_ready;
 assign l_res_st_g_rd_rsp_valid=r_res_st_g_rd_rsp_valid;
 assign l_res_st_g_rd_rsp_data=r_res_st_g_rd_rsp_data;
 assign l_res_st_g_rd_rsp_mask=r_res_st_g_rd_rsp_mask;
 assign l_res_st_g_rd_rsp_tag=r_res_st_g_rd_rsp_tag;
 assign l_res_st_context_wr_ready=r_res_st_context_wr_ready;
 assign l_res_st_context_wr_rsp_valid=r_res_st_context_wr_rsp_valid;
 assign l_res_st_context_wr_rsp_tag=r_res_st_context_wr_rsp_tag;
 assign l_res_st_context_rd_ready=r_res_st_context_rd_ready;
 assign l_res_st_context_rd_rsp_valid=r_res_st_context_rd_rsp_valid;
 assign l_res_st_context_rd_rsp_data=r_res_st_context_rd_rsp_data;
 assign l_res_st_context_rd_rsp_mask=r_res_st_context_rd_rsp_mask;
 assign l_res_st_context_rd_rsp_tag=r_res_st_context_rd_rsp_tag;
 assign l_res_st_idle=r_res_st_idle;
 assign l_res_fp_lease_ready=(matrix_owner?'0:r_res_fp_lease_ready);
 assign l_res_fp_release_ready=(matrix_owner?'0:r_res_fp_release_ready);
 assign l_res_fp_lease_active=r_res_fp_lease_active;
 assign l_res_fp_draining=r_res_fp_draining;
 assign l_res_fp_rsp_request_id=r_res_fp_rsp_request_id;
 assign l_res_fp_rsp_generation=r_res_fp_rsp_generation;
 assign l_res_fp_rsp_epoch=r_res_fp_rsp_epoch;
 assign l_res_fp_rsp_head=r_res_fp_rsp_head;
 assign l_res_fp_rsp_phase=r_res_fp_rsp_phase;
 assign l_res_fp_mul_req_ready=(matrix_owner?'0:r_res_fp_mul_req_ready);
 assign l_res_fp_mul_rsp_valid=(matrix_owner?'0:r_res_fp_mul_rsp_valid);
 assign l_res_fp_mul_rsp_tag=(matrix_owner?'0:r_res_fp_mul_rsp_tag);
 assign l_res_fp_mul_rsp_data=(matrix_owner?'0:r_res_fp_mul_rsp_data);
 assign l_res_fp_add_req_ready=(matrix_owner?'0:r_res_fp_add_req_ready);
 assign l_res_fp_add_rsp_valid=(matrix_owner?'0:r_res_fp_add_rsp_valid);
 assign l_res_fp_add_rsp_tag=(matrix_owner?'0:r_res_fp_add_rsp_tag);
 assign l_res_fp_add_rsp_data=(matrix_owner?'0:r_res_fp_add_rsp_data);
 assign l_res_fp_mul_pending=(matrix_owner?'0:r_res_fp_mul_pending);
 assign l_res_fp_add_pending=(matrix_owner?'0:r_res_fp_add_pending);
 assign l_res_fp_protocol_fault=(matrix_owner?'0:r_res_fp_protocol_fault);
 assign l_res_ln_bind_ready=r_res_ln_bind_ready;
 assign l_res_ln_rsp_request_id=r_res_ln_rsp_request_id;
 assign l_res_ln_rsp_generation=r_res_ln_rsp_generation;
 assign l_res_ln_rsp_epoch=r_res_ln_rsp_epoch;
 assign l_res_ln_rsp_head=r_res_ln_rsp_head;
 assign l_res_ln_rsp_phase=r_res_ln_rsp_phase;
 assign l_res_ln_wr_ready=r_res_ln_wr_ready;
 assign l_res_ln_wr_rsp_valid=r_res_ln_wr_rsp_valid;
 assign l_res_ln_wr_rsp_tag=r_res_ln_wr_rsp_tag;
 assign l_res_ln_rd_ready=r_res_ln_rd_ready;
 assign l_res_ln_rd_rsp_valid=r_res_ln_rd_rsp_valid;
 assign l_res_ln_rd_rsp_data=r_res_ln_rd_rsp_data;
 assign l_res_ln_rd_rsp_mask=r_res_ln_rd_rsp_mask;
 assign l_res_ln_rd_rsp_tag=r_res_ln_rd_rsp_tag;
 assign l_res_ln_idle=r_res_ln_idle;
 assign l_res_sfu_lease_ready=r_res_sfu_lease_ready;
 assign l_res_sfu_lease_active=r_res_sfu_lease_active;
 assign l_res_sfu_req_ready=r_res_sfu_req_ready;
 assign l_res_sfu_reject_valid=r_res_sfu_reject_valid;
 assign l_res_sfu_rsp_valid=r_res_sfu_rsp_valid;
 assign l_res_sfu_rsp_tag=r_res_sfu_rsp_tag;
 assign l_res_sfu_rsp_data=r_res_sfu_rsp_data;
 assign l_res_sfu_pending_vectors=r_res_sfu_pending_vectors;
 assign l_res_sfu_in_flight_vectors=r_res_sfu_in_flight_vectors;
 assign l_res_sfu_protocol_fault=r_res_sfu_protocol_fault;
 assign l_res_div_lease_ready=(front_owner?'0:r_res_div_lease_ready);
 assign l_res_div_lease_active=r_res_div_lease_active;
 assign l_res_div_req_ready=(front_owner?'0:r_res_div_req_ready);
 assign l_res_div_protocol_reject_valid=(front_owner?'0:r_res_div_protocol_reject_valid);
 assign l_res_div_rsp_valid=(front_owner?'0:r_res_div_rsp_valid);
 assign l_res_div_rsp_tag=(front_owner?'0:r_res_div_rsp_tag);
 assign l_res_div_rsp_numeric_error=(front_owner?'0:r_res_div_rsp_numeric_error);
 assign l_res_div_rsp_data=(front_owner?'0:r_res_div_rsp_data);
 assign l_res_div_pending_vectors=(front_owner?'0:r_res_div_pending_vectors);
 assign l_res_div_in_flight_vectors=(front_owner?'0:r_res_div_in_flight_vectors);
 assign l_res_div_in_flight_scalars=(front_owner?'0:r_res_div_in_flight_scalars);
 assign l_res_div_protocol_fault=(front_owner?'0:r_res_div_protocol_fault);
 assign l_res_scale_ready=r_res_scale_ready;
 assign l_res_scale_rsp_valid=r_res_scale_rsp_valid;
 assign l_res_scale_rsp_tag=r_res_scale_rsp_tag;
 assign l_res_scale_data=r_res_scale_data;
 assign l_res_scale_pending=r_res_scale_pending;
 assign l_res_scale_fault=r_res_scale_fault;
 assign l_rope_wr_ready=r_rope_wr_ready;
 assign l_rope_wr_commit_valid=r_rope_wr_commit_valid;
 assign l_rope_wr_commit_tag=r_rope_wr_commit_tag;
 assign l_rope_reject_valid=r_rope_reject_valid;
 assign l_rope_reject_code=r_rope_reject_code;
 assign l_cache_bound_valid=coeff_bound_valid;
 assign l_cache_bound_model_id=coeff_bound_model_id;
 assign l_cache_bound_numeric_id=coeff_bound_numeric_id;
 assign l_cache_bound_table_key=coeff_bound_table_key;
 assign l_cache_family_complete=coeff_family_complete;
 assign m_cmd_valid=ffn_mode?(state==QMSUB||state==WMSUB||state==F_WISUB):(state==QMSUB||state==WMSUB);
 assign m_cmd_version=32'd1;
 assign m_cmd_request=request_id;
 assign m_cmd_model=MODEL_ID[63:0];
 assign m_cmd_generation=generation;
 assign m_cmd_epoch=epoch;
 assign m_cmd_tensor=tensor_id[wo_phase];
 assign m_cmd_k=ffn_mode?(ffn_mode&&wo_phase?16'd2624:16'd1024):(16'd1024);
 assign m_cmd_n=ffn_mode?(wo_phase?16'd1024:(ffn_mode?16'd5248:16'd3072)):(wo_phase?16'd1024:16'd3072);
 assign m_cmd_a_slot=ffn_mode?(ffn_mode&&wo_phase):(1'b0);
 assign m_cmd_bias=kind==2;
 assign m_cmd_base=base[wo_phase];
 assign m_cmd_span=span[wo_phase];
 assign m_done_ready=ffn_mode?(state==QMRUN||state==WMRUN||(state==F_CLOSE&&ffn_close_fire)||state==F_ABORT):(state==QMRUN||state==WMRUN);
 assign m_out_ready=ffn_mode?(ffn_mode?(wo_phase?out_ready:(state==F_ABORT?1'b1:g_fill_ready)):wo_phase?out_ready:l_qkv_wr_ready):(state==QMRUN?l_qkv_wr_ready:(state==WMRUN&&out_ready));
 assign m_acfg_valid=q_acfg_valid;
 assign m_acfg_slot=q_acfg_slot;
 assign m_acfg_k=q_acfg_k;
 assign m_acfg_request=q_acfg_request;
 assign m_acfg_generation=q_acfg_generation;
 assign m_acfg_epoch=q_acfg_epoch;
 assign m_acfg_rsp_ready=q_acfg_rsp_ready;
 assign m_fill_cancel_valid=(state==ACANCEL||state==ACWAIT)?(state==ACANCEL):q_fill_cancel_valid;
 assign m_fill_cancel_slot=(state==ACANCEL||state==ACWAIT)?(1'b0):q_fill_cancel_slot;
 assign m_fill_cancel_request=(state==ACANCEL||state==ACWAIT)?(request_id):q_fill_cancel_request;
 assign m_fill_cancel_generation=(state==ACANCEL||state==ACWAIT)?(generation):q_fill_cancel_generation;
 assign m_fill_cancel_epoch=(state==ACANCEL||state==ACWAIT)?(epoch):q_fill_cancel_epoch;
 assign m_fill_cancel_rsp_ready=(state==ACANCEL||state==ACWAIT)?(1'b1):q_fill_cancel_rsp_ready;
 assign m_awr_valid=q_awr_valid;
 assign m_awr_row=q_awr_row;
 assign m_awr_group=q_awr_group;
 assign m_awr_data=q_awr_data;
 assign m_awr_request=q_awr_request;
 assign m_awr_generation=q_awr_generation;
 assign m_awr_epoch=q_awr_epoch;
 assign m_awr_rsp_ready=q_awr_rsp_ready;
 assign m_coef_cfg_valid=coef_cfg_valid&&bias_identity_ok;
 assign m_coef_model=coef_model;
 assign m_coef_request=coef_request;
 assign m_coef_tensor=coef_tensor;
 assign m_coef_generation=coef_generation;
 assign m_coef_epoch=coef_epoch;
 assign m_coef_n=coef_n;
 assign m_coef_wr_valid=coef_wr_valid;
 assign m_coef_wr_addr=coef_wr_addr;
 assign m_coef_wr_data=coef_wr_data;
 assign m_coef_rsp_ready=coef_rsp_ready;
 assign m_arready=arready;
 assign m_rvalid=rvalid;
 assign m_rid=rid;
 assign m_rdata=rdata;
 assign m_rresp=rresp;
 assign m_rlast=rlast;
 assign m_run_enable=1'b1;
 assign m_fp_lease_ready=(matrix_owner?r_res_fp_lease_ready:'0);
 assign m_fp_release_ready=(matrix_owner?r_res_fp_release_ready:'0);
 assign m_fp_lease_active=r_res_fp_lease_active;
 assign m_fp_draining=r_res_fp_draining;
 assign m_fp_fault=r_res_fp_protocol_fault;
 assign m_storage_bind_ready=(matrix_owner?r_res_st_bind_ready:'0);
 assign m_storage_idle=r_res_st_idle;
 assign m_mul_req_ready=(matrix_owner?r_res_fp_mul_req_ready:'0);
 assign m_mul_rsp_valid=(matrix_owner?r_res_fp_mul_rsp_valid:'0);
 assign m_mul_rsp_tag=(matrix_owner?r_res_fp_mul_rsp_tag:'0);
 assign m_mul_rsp_data=(matrix_owner?r_res_fp_mul_rsp_data:'0);
 assign m_mul_pending=(matrix_owner?r_res_fp_mul_pending:'0);
 assign m_add_req_ready=(matrix_owner?r_res_fp_add_req_ready:'0);
 assign m_add_rsp_valid=(matrix_owner?r_res_fp_add_rsp_valid:'0);
 assign m_add_rsp_tag=(matrix_owner?r_res_fp_add_rsp_tag:'0);
 assign m_add_rsp_data=(matrix_owner?r_res_fp_add_rsp_data:'0);
 assign m_add_pending=(matrix_owner?r_res_fp_add_pending:'0);
 assign m_ps_wr_ready=(matrix_owner?r_res_st_ps_wr_ready:'0);
 assign m_ps_wr_rsp_valid=(matrix_owner?r_res_st_ps_wr_rsp_valid:'0);
 assign m_ps_rd_ready=(matrix_owner?r_res_st_ps_rd_ready:'0);
 assign m_ps_rd_rsp_valid=(matrix_owner?r_res_st_ps_rd_rsp_valid:'0);
 assign m_ps_rd_rsp_mask=(matrix_owner?r_res_st_ps_rd_rsp_mask:'0);
 assign m_ps_rd_rsp_data=(matrix_owner?r_res_st_ps_rd_rsp_data:'0);
 assign m_ps_wr_rsp_tag=(matrix_owner?r_res_st_ps_wr_rsp_tag:'0);
 assign m_ps_rd_rsp_tag=(matrix_owner?r_res_st_ps_rd_rsp_tag:'0);
 assign q_run_enable=1'b1;
 assign q_cmd_valid=ffn_mode?(state==QSUB||state==CSUB||state==F_NQSUB||(state==F_GQSUB&&g_cmd_ready)):((state==QSUB&&m_descriptor_precheck_ok)||(state==CSUB&&c_start_ready));
 assign q_cmd_slot=ffn_mode?(state==F_GQSUB):(1'b0);
 assign q_cmd_k=ffn_mode?(state==F_GQSUB?16'd2624:16'd1024):(16'd1024);
 assign q_cmd_request=request_id;
 assign q_cmd_generation=generation;
 assign q_cmd_epoch=epoch;
 assign q_in_valid=ffn_mode?(ffn_mode?((state==F_NQRUN)?(in_valid&&legal_input):((state==F_RUN||state==F_CLOSE||state==F_ABORT)&&pack_full&&!q_close_sent)):(context_phase?c_out_valid:(in_valid&&legal_input))):(state==CRUN?c_out_valid:(in_valid&&legal_input));
 assign q_in_data=ffn_mode?(ffn_mode&&state!=F_NQRUN?pack_data:context_phase?c_out_data:in_data):(state==CRUN?c_out_data:in_data);
 assign q_in_request=request_id;
 assign q_in_generation=generation;
 assign q_in_epoch=epoch;
 assign q_in_row=ffn_mode?(ffn_mode&&state!=F_NQRUN?{1'b0,pack_previous[8:2]}:context_phase?c_out_row:in_row):(state==CRUN?c_out_row:in_row);
 assign q_in_group=ffn_mode?(ffn_mode&&state!=F_NQRUN?{1'b0,pack_previous[15:9]}:context_phase?c_out_group:in_group):(state==CRUN?c_out_group:in_group);
 assign q_producer_close_valid=ffn_mode?(ffn_mode?((state==F_NQRUN)&&(inputs_accepted==4096||producer_failure)||(state==F_CLOSE)||(state==F_ABORT&&!q_close_sent&&!q_cmd_ready&&!q_done_valid)):(state==QRUN&&(inputs_accepted==4096||producer_failure)||state==CRUN&&(c_complete||producer_failure||c_fault))):((state==QRUN&&(inputs_accepted==4096||producer_failed))||(state==CRUN&&(c_complete||producer_failed||c_fault)));
 assign q_producer_close_success=ffn_mode?(ffn_mode?(state!=F_ABORT&&!producer_failure):(!producer_failure&&!c_fault)):(!producer_failed&&(state!=CRUN||!c_fault));
 assign q_done_ready=ffn_mode?(state==QRUN||state==CRUN||state==F_NQRUN||state==F_QDRAIN||state==F_ABORT):(state==QRUN||state==CRUN);
 assign q_acfg_ready=m_acfg_ready;
 assign q_acfg_rsp_valid=m_acfg_rsp_valid;
 assign q_acfg_status=m_acfg_status;
 assign q_awr_ready=m_awr_ready;
 assign q_awr_rsp_valid=m_awr_rsp_valid;
 assign q_fill_cancel_ready=(state==ACANCEL||state==ACWAIT)?'0:m_fill_cancel_ready;
 assign q_fill_cancel_reject_valid=(state==ACANCEL||state==ACWAIT)?'0:m_fill_cancel_reject_valid;
 assign q_fill_cancel_reject_code=(state==ACANCEL||state==ACWAIT)?'0:m_fill_cancel_reject_code;
 assign q_fill_cancel_rsp_valid=(state==ACANCEL||state==ACWAIT)?'0:m_fill_cancel_rsp_valid;
 assign q_fill_cancel_rsp_slot=(state==ACANCEL||state==ACWAIT)?'0:m_fill_cancel_rsp_slot;
 assign q_fill_cancel_rsp_request=(state==ACANCEL||state==ACWAIT)?'0:m_fill_cancel_rsp_request;
 assign q_fill_cancel_rsp_generation=(state==ACANCEL||state==ACWAIT)?'0:m_fill_cancel_rsp_generation;
 assign q_fill_cancel_rsp_epoch=(state==ACANCEL||state==ACWAIT)?'0:m_fill_cancel_rsp_epoch;
 assign q_d_lease_ready=(front_owner?r_res_div_lease_ready:'0);
 assign q_d_release_ready=(front_owner?r_res_div_release_ready:'0);
 assign q_d_lease_active=r_res_div_lease_active;
 assign q_d_draining=r_res_div_draining;
 assign q_d_rsp_request_id=r_res_div_rsp_request_id;
 assign q_d_rsp_generation=r_res_div_rsp_generation;
 assign q_d_rsp_epoch=r_res_div_rsp_epoch;
 assign q_d_rsp_head=r_res_div_rsp_head;
 assign q_d_rsp_phase=r_res_div_rsp_phase;
 assign q_d_req_ready=(front_owner?r_res_div_req_ready:'0);
 assign q_d_protocol_reject_valid=(front_owner?r_res_div_protocol_reject_valid:'0);
 assign q_d_protocol_reject_code=r_res_div_protocol_reject_code;
 assign q_d_rsp_valid=(front_owner?r_res_div_rsp_valid:'0);
 assign q_d_rsp_tag=(front_owner?r_res_div_rsp_tag:'0);
 assign q_d_rsp_lane_mask=r_res_div_rsp_lane_mask;
 assign q_d_rsp_numeric_error=(front_owner?r_res_div_rsp_numeric_error:'0);
 assign q_d_rsp_data=(front_owner?r_res_div_rsp_data:'0);
 assign q_d_pending_vectors=(front_owner?r_res_div_pending_vectors:'0);
 assign q_d_in_flight_vectors=(front_owner?r_res_div_in_flight_vectors:'0);
 assign q_d_in_flight_scalars=(front_owner?r_res_div_in_flight_scalars:'0);
 assign q_d_protocol_fault=(front_owner?r_res_div_protocol_fault:'0);
 assign r_res_qkv_wr_valid=l_res_qkv_wr_valid;
 assign r_res_qkv_wr_plane=l_res_qkv_wr_plane;
 assign r_res_qkv_wr_head=l_res_qkv_wr_head;
 assign r_res_qkv_wr_token=l_res_qkv_wr_token;
 assign r_res_qkv_wr_half=l_res_qkv_wr_half;
 assign r_res_qkv_wr_data=l_res_qkv_wr_data;
 assign r_res_qkv_rd_valid=l_res_qkv_rd_valid;
 assign r_res_qkv_rd_head=l_res_qkv_rd_head;
 assign r_res_qkv_rd_token=l_res_qkv_rd_token;
 assign r_res_qkv_rd_tag=l_res_qkv_rd_tag;
 assign r_res_qkv_rd_rsp_ready=l_res_qkv_rd_rsp_ready;
 assign r_res_st_bind_valid=matrix_owner?m_bind_new_lease:l_res_st_bind_valid;
 assign r_res_st_bind_request_id=matrix_owner?m_fp_owner_request:l_res_st_bind_request_id;
 assign r_res_st_bind_generation=matrix_owner?m_fp_owner_generation:l_res_st_bind_generation;
 assign r_res_st_bind_epoch=matrix_owner?m_fp_owner_epoch:l_res_st_bind_epoch;
 assign r_res_st_bind_head=matrix_owner?4'b0:l_res_st_bind_head;
 assign r_res_st_bind_phase=matrix_owner?3'd1:l_res_st_bind_phase;
 assign r_res_st_op_request_id=matrix_owner?m_fp_owner_request:l_res_st_op_request_id;
 assign r_res_st_op_generation=matrix_owner?m_fp_owner_generation:l_res_st_op_generation;
 assign r_res_st_op_epoch=matrix_owner?m_fp_owner_epoch:l_res_st_op_epoch;
 assign r_res_st_op_phase=matrix_owner?3'd1:l_res_st_op_phase;
 assign r_res_st_ps_wr_valid=matrix_owner?m_ps_wr_valid:l_res_st_ps_wr_valid;
 assign r_res_st_ps_wr_mask=matrix_owner?m_ps_wr_mask:l_res_st_ps_wr_mask;
 assign r_res_st_ps_wr_addr=matrix_owner?m_ps_wr_addr:l_res_st_ps_wr_addr;
 assign r_res_st_ps_wr_data=matrix_owner?m_ps_wr_data:l_res_st_ps_wr_data;
 assign r_res_st_ps_wr_tag=matrix_owner?m_ps_wr_tag:l_res_st_ps_wr_tag;
 assign r_res_st_ps_wr_rsp_ready=matrix_owner?m_ps_wr_rsp_ready:l_res_st_ps_wr_rsp_ready;
 assign r_res_st_ps_rd_valid=matrix_owner?m_ps_rd_valid:l_res_st_ps_rd_valid;
 assign r_res_st_ps_rd_mask=matrix_owner?m_ps_rd_mask:l_res_st_ps_rd_mask;
 assign r_res_st_ps_rd_addr=matrix_owner?m_ps_rd_addr:l_res_st_ps_rd_addr;
 assign r_res_st_ps_rd_tag=matrix_owner?m_ps_rd_tag:l_res_st_ps_rd_tag;
 assign r_res_st_ps_rd_rsp_ready=matrix_owner?m_ps_rd_rsp_ready:l_res_st_ps_rd_rsp_ready;
 assign r_res_st_g_wr_valid=ffn_mode?g_g_wr_valid:l_res_st_g_wr_valid;
 assign r_res_st_g_wr_mask=ffn_mode?g_g_wr_mask:l_res_st_g_wr_mask;
 assign r_res_st_g_wr_addr=ffn_mode?g_g_wr_addr:l_res_st_g_wr_addr;
 assign r_res_st_g_wr_data=ffn_mode?g_g_wr_data:l_res_st_g_wr_data;
 assign r_res_st_g_wr_tag=ffn_mode?g_g_wr_tag:l_res_st_g_wr_tag;
 assign r_res_st_g_wr_rsp_ready=ffn_mode?g_g_wr_rsp_ready:l_res_st_g_wr_rsp_ready;
 assign r_res_st_g_rd_valid=ffn_mode?g_g_rd_valid:l_res_st_g_rd_valid;
 assign r_res_st_g_rd_mask=ffn_mode?g_g_rd_mask:l_res_st_g_rd_mask;
 assign r_res_st_g_rd_addr=ffn_mode?g_g_rd_addr:l_res_st_g_rd_addr;
 assign r_res_st_g_rd_tag=ffn_mode?g_g_rd_tag:l_res_st_g_rd_tag;
 assign r_res_st_g_rd_rsp_ready=ffn_mode?g_g_rd_rsp_ready:l_res_st_g_rd_rsp_ready;
 assign r_res_st_context_wr_valid=l_res_st_context_wr_valid;
 assign r_res_st_context_wr_mask=l_res_st_context_wr_mask;
 assign r_res_st_context_wr_addr=l_res_st_context_wr_addr;
 assign r_res_st_context_wr_data=l_res_st_context_wr_data;
 assign r_res_st_context_wr_tag=l_res_st_context_wr_tag;
 assign r_res_st_context_wr_rsp_ready=l_res_st_context_wr_rsp_ready;
 assign r_res_st_context_rd_valid=l_res_st_context_rd_valid;
 assign r_res_st_context_rd_mask=l_res_st_context_rd_mask;
 assign r_res_st_context_rd_addr=l_res_st_context_rd_addr;
 assign r_res_st_context_rd_tag=l_res_st_context_rd_tag;
 assign r_res_st_context_rd_rsp_ready=l_res_st_context_rd_rsp_ready;
 assign r_res_fp_lease_valid=matrix_owner?m_bind_new_lease:l_res_fp_lease_valid;
 assign r_res_fp_lease_request_id=matrix_owner?m_fp_owner_request:l_res_fp_lease_request_id;
 assign r_res_fp_lease_generation=matrix_owner?m_fp_owner_generation:l_res_fp_lease_generation;
 assign r_res_fp_lease_epoch=matrix_owner?m_fp_owner_epoch:l_res_fp_lease_epoch;
 assign r_res_fp_lease_head=matrix_owner?4'b0:l_res_fp_lease_head;
 assign r_res_fp_lease_phase=matrix_owner?3'd1:l_res_fp_lease_phase;
 assign r_res_fp_release_valid=matrix_owner?m_fp_release_valid:l_res_fp_release_valid;
 assign r_res_fp_release_phase=matrix_owner?3'd1:l_res_fp_release_phase;
 assign r_res_fp_release_epoch=matrix_owner?m_fp_owner_epoch:l_res_fp_release_epoch;
 assign r_res_fp_phase_debt_clear=matrix_owner?m_fp_phase_debt_clear:l_res_fp_phase_debt_clear;
 assign r_res_fp_mul_req_valid=matrix_owner?m_mul_req_valid:l_res_fp_mul_req_valid;
 assign r_res_fp_mul_req_phase=matrix_owner?3'd1:l_res_fp_mul_req_phase;
 assign r_res_fp_mul_req_epoch=matrix_owner?m_fp_owner_epoch:l_res_fp_mul_req_epoch;
 assign r_res_fp_mul_req_tag=matrix_owner?m_mul_req_tag:l_res_fp_mul_req_tag;
 assign r_res_fp_mul_a=matrix_owner?m_mul_a:l_res_fp_mul_a;
 assign r_res_fp_mul_b=matrix_owner?m_mul_b:l_res_fp_mul_b;
 assign r_res_fp_mul_rsp_ready=matrix_owner?m_mul_rsp_ready:l_res_fp_mul_rsp_ready;
 assign r_res_fp_add_req_valid=matrix_owner?m_add_req_valid:l_res_fp_add_req_valid;
 assign r_res_fp_add_req_is_root=matrix_owner?m_add_req_is_root:l_res_fp_add_req_is_root;
 assign r_res_fp_add_req_phase=matrix_owner?m_add_req_phase:l_res_fp_add_req_phase;
 assign r_res_fp_add_req_epoch=matrix_owner?m_add_req_epoch:l_res_fp_add_req_epoch;
 assign r_res_fp_add_req_tag=matrix_owner?m_add_req_tag:l_res_fp_add_req_tag;
 assign r_res_fp_add_a=matrix_owner?m_add_a:l_res_fp_add_a;
 assign r_res_fp_add_b=matrix_owner?m_add_b:l_res_fp_add_b;
 assign r_res_fp_add_rsp_ready=matrix_owner?m_add_rsp_ready:l_res_fp_add_rsp_ready;
 assign r_res_ln_bind_valid=l_res_ln_bind_valid;
 assign r_res_ln_bind_request_id=l_res_ln_bind_request_id;
 assign r_res_ln_bind_generation=l_res_ln_bind_generation;
 assign r_res_ln_bind_epoch=l_res_ln_bind_epoch;
 assign r_res_ln_bind_head=l_res_ln_bind_head;
 assign r_res_ln_bind_phase=l_res_ln_bind_phase;
 assign r_res_ln_op_request_id=l_res_ln_op_request_id;
 assign r_res_ln_op_generation=l_res_ln_op_generation;
 assign r_res_ln_op_epoch=l_res_ln_op_epoch;
 assign r_res_ln_op_phase=l_res_ln_op_phase;
 assign r_res_ln_wr_valid=l_res_ln_wr_valid;
 assign r_res_ln_wr_mask=l_res_ln_wr_mask;
 assign r_res_ln_wr_addr=l_res_ln_wr_addr;
 assign r_res_ln_wr_data=l_res_ln_wr_data;
 assign r_res_ln_wr_tag=l_res_ln_wr_tag;
 assign r_res_ln_wr_rsp_ready=l_res_ln_wr_rsp_ready;
 assign r_res_ln_rd_valid=l_res_ln_rd_valid;
 assign r_res_ln_rd_mask=l_res_ln_rd_mask;
 assign r_res_ln_rd_addr=l_res_ln_rd_addr;
 assign r_res_ln_rd_tag=l_res_ln_rd_tag;
 assign r_res_ln_rd_rsp_ready=l_res_ln_rd_rsp_ready;
 assign r_res_sfu_lease_valid=l_res_sfu_lease_valid;
 assign r_res_sfu_lease_request_id=l_res_sfu_lease_request_id;
 assign r_res_sfu_lease_generation=l_res_sfu_lease_generation;
 assign r_res_sfu_lease_epoch=l_res_sfu_lease_epoch;
 assign r_res_sfu_lease_head=l_res_sfu_lease_head;
 assign r_res_sfu_lease_phase=l_res_sfu_lease_phase;
 assign r_res_sfu_release_valid=l_res_sfu_release_valid;
 assign r_res_sfu_release_phase=l_res_sfu_release_phase;
 assign r_res_sfu_release_epoch=l_res_sfu_release_epoch;
 assign r_res_sfu_phase_debt_clear=l_res_sfu_phase_debt_clear;
 assign r_res_sfu_context_valid=l_res_sfu_context_valid;
 assign r_res_sfu_context_row_hi=l_res_sfu_context_row_hi;
 assign r_res_sfu_req_valid=l_res_sfu_req_valid;
 assign r_res_sfu_req_mode=l_res_sfu_req_mode;
 assign r_res_sfu_req_generation=l_res_sfu_req_generation;
 assign r_res_sfu_req_epoch=l_res_sfu_req_epoch;
 assign r_res_sfu_req_phase=l_res_sfu_req_phase;
 assign r_res_sfu_req_tag=l_res_sfu_req_tag;
 assign r_res_sfu_req_x=l_res_sfu_req_x;
 assign r_res_sfu_rsp_ready=l_res_sfu_rsp_ready;
 assign r_res_div_lease_valid=front_owner?q_d_lease_valid:l_res_div_lease_valid;
 assign r_res_div_lease_request_id=front_owner?q_d_lease_request_id:l_res_div_lease_request_id;
 assign r_res_div_lease_generation=front_owner?q_d_lease_generation:l_res_div_lease_generation;
 assign r_res_div_lease_epoch=front_owner?q_d_lease_epoch:l_res_div_lease_epoch;
 assign r_res_div_lease_head=front_owner?q_d_lease_head:l_res_div_lease_head;
 assign r_res_div_lease_phase=front_owner?q_d_lease_phase:l_res_div_lease_phase;
 assign r_res_div_release_valid=front_owner?q_d_release_valid:l_res_div_release_valid;
 assign r_res_div_release_phase=front_owner?q_d_release_phase:l_res_div_release_phase;
 assign r_res_div_release_epoch=front_owner?q_d_release_epoch:l_res_div_release_epoch;
 assign r_res_div_phase_debt_clear=front_owner?q_d_phase_debt_clear:l_res_div_phase_debt_clear;
 assign r_res_div_req_valid=front_owner?q_d_req_valid:l_res_div_req_valid;
 assign r_res_div_req_generation=front_owner?q_d_req_generation:l_res_div_req_generation;
 assign r_res_div_req_epoch=front_owner?q_d_req_epoch:l_res_div_req_epoch;
 assign r_res_div_req_phase=front_owner?q_d_req_phase:l_res_div_req_phase;
 assign r_res_div_req_lane_mask=front_owner?q_d_req_lane_mask:l_res_div_req_lane_mask;
 assign r_res_div_req_tag=front_owner?q_d_req_tag:l_res_div_req_tag;
 assign r_res_div_req_a=front_owner?q_d_req_a:l_res_div_req_a;
 assign r_res_div_req_b=front_owner?q_d_req_b:l_res_div_req_b;
 assign r_res_div_rsp_ready=front_owner?q_d_rsp_ready:l_res_div_rsp_ready;
 assign r_res_scale_valid=l_res_scale_valid;
 assign r_res_scale_tag=l_res_scale_tag;
 assign r_res_scale_input=l_res_scale_input;
 assign r_res_scale_rsp_ready=l_res_scale_rsp_ready;
 assign r_rope_owner_valid=l_rope_owner_valid;
 assign r_rope_owner_request_id=l_rope_owner_request_id;
 assign r_rope_owner_generation=l_rope_owner_generation;
 assign r_rope_owner_epoch=l_rope_owner_epoch;
 assign r_rope_wr_valid=l_rope_wr_valid;
 assign r_rope_wr_request_id=l_rope_wr_request_id;
 assign r_rope_wr_generation=l_rope_wr_generation;
 assign r_rope_wr_epoch=l_rope_wr_epoch;
 assign r_rope_wr_head=l_rope_wr_head;
 assign r_rope_wr_token=l_rope_wr_token;
 assign r_rope_wr_tag=l_rope_wr_tag;
 assign r_rope_wr_q=l_rope_wr_q;
 assign r_rope_wr_k=l_rope_wr_k;

 assign c_rd_ready=l_result_rd_ready;assign c_rsp_valid=l_result_rsp_valid;assign c_rsp_tag=l_result_rsp_tag;assign c_rsp_data=l_result_rsp_data;
 assign c_out_ready=state==CRUN&&q_in_ready;
 laya_m007_context_quant_adapter_v1 context_adapter(
  .clk,.rst_n,.start_valid(state==CSUB&&q_cmd_valid&&q_cmd_ready),.start_ready(c_start_ready),.generation,.cancel(producer_failed||c_fault||context_failed),
  .rd_valid(c_rd_valid),.rd_ready(c_rd_ready),.rd_generation(c_rd_generation),.rd_tag(c_rd_tag),.rd_head(c_rd_head),.rd_query(c_rd_query),.rd_half(c_rd_half),
  .rsp_valid(c_rsp_valid),.rsp_ready(c_rsp_ready),.rsp_tag(c_rsp_tag),.rsp_data(c_rsp_data),.out_valid(c_out_valid),.out_ready(c_out_ready),.out_data(c_out_data),.out_row(c_out_row),.out_group(c_out_group),
  .idle(c_idle),.complete(c_complete),.protocol_fault(c_fault),.accepted_reads(c_accepted),.consumed_groups(c_consumed));  laya_m007_control_workspace_joint_v1 layer(
   .clk(clk),
   .rst_n(rst_n),
   .a_prepare_valid(l_prepare_valid),
   .a_prepare_ready(l_prepare_ready),
   .a_prepare_request_id(l_prepare_request_id),
   .a_prepare_model_id(l_prepare_model_id),
   .a_prepare_generation(l_prepare_generation),
   .a_prepare_epoch(l_prepare_epoch),
   .a_prepare_numeric_id(l_prepare_numeric_id),
   .a_prepare_table_key(l_prepare_table_key),
   .a_prepare_kind(l_prepare_kind),
   .a_prepare_layer(l_prepare_layer),
   .a_prepare_mask(l_prepare_mask),
   .a_qkv_wr_valid(l_qkv_wr_valid),
   .a_qkv_wr_ready(l_qkv_wr_ready),
   .a_qkv_wr_request_id(l_qkv_wr_request_id),
   .a_qkv_wr_generation(l_qkv_wr_generation),
   .a_qkv_wr_epoch(l_qkv_wr_epoch),
   .a_qkv_wr_plane(l_qkv_wr_plane),
   .a_qkv_wr_head(l_qkv_wr_head),
   .a_qkv_wr_token(l_qkv_wr_token),
   .a_qkv_wr_half(l_qkv_wr_half),
   .a_qkv_wr_data(l_qkv_wr_data),
   .a_start_valid(l_start_valid),
   .a_start_ready(l_start_ready),
   .a_start_request_id(l_start_request_id),
   .a_start_generation(l_start_generation),
   .a_reject_valid(l_reject_valid),
   .a_reject_code(l_reject_code),
   .a_abort_valid(l_abort_valid),
   .a_abort_ready(l_abort_ready),
   .a_qkv_read_grant(l_qkv_read_grant),
   .a_ps_grant(l_ps_grant),
   .a_g_grant(l_g_grant),
   .a_context_grant(l_context_grant),
   .a_fp_grant(l_fp_grant),
   .a_sfu_grant(l_sfu_grant),
   .a_exp_grant(l_exp_grant),
   .a_div_grant(l_div_grant),
   .a_rope_write_grant(l_rope_write_grant),
   .a_done_valid(l_done_valid),
   .a_done_ready(l_done_ready),
   .a_done_request_id(l_done_request_id),
   .a_done_generation(l_done_generation),
   .a_done_status(l_done_status),
   .a_done_cycles(l_done_cycles),
   .a_rope_cycles(l_rope_cycles),
   .a_head_completed(l_head_completed),
   .a_head_context_valid(l_head_context_valid),
   .a_active_head(l_active_head),
   .a_error_valid(l_error_valid),
   .a_error_tuple(l_error_tuple),
   .a_check_completed(l_check_completed),
   .a_check_unreachable(l_check_unreachable),
   .a_check_dominated(l_check_dominated),
   .a_av_check_completed(l_av_check_completed),
   .a_av_check_unreachable(l_av_check_unreachable),
   .a_av_check_dominated(l_av_check_dominated),
   .a_result_rd_valid(l_result_rd_valid),
   .a_result_rd_ready(l_result_rd_ready),
   .a_result_rd_generation(l_result_rd_generation),
   .a_result_rd_tag(l_result_rd_tag),
   .a_result_rd_head(l_result_rd_head),
   .a_result_rd_query(l_result_rd_query),
   .a_result_rd_half(l_result_rd_half),
   .a_result_rsp_valid(l_result_rsp_valid),
   .a_result_rsp_ready(l_result_rsp_ready),
   .a_result_rsp_tag(l_result_rsp_tag),
   .a_result_rsp_data(l_result_rsp_data),
   .a_result_discard_valid(l_result_discard_valid),
   .a_result_discard_ready(l_result_discard_ready),
   .a_result_discard_generation(l_result_discard_generation),
   .a_context_discarded(l_context_discarded),
   .a_producer_done_cycles(l_producer_done_cycles),
   .a_context_release_cycles(l_context_release_cycles),
   .a_prepare_cancel_valid(l_prepare_cancel_valid),
   .a_prepare_cancel_ready(l_prepare_cancel_ready),
   .a_prepare_cancel_request_id(l_prepare_cancel_request_id),
   .a_prepare_cancel_generation(l_prepare_cancel_generation),
   .a_prepare_cancel_epoch(l_prepare_cancel_epoch),
   .a_prepare_cancel_rsp_valid(l_prepare_cancel_rsp_valid),
   .a_prepare_cancel_rsp_ready(l_prepare_cancel_rsp_ready),
   .a_prepare_cancel_rsp_request_id(l_prepare_cancel_rsp_request_id),
   .a_prepare_cancel_rsp_generation(l_prepare_cancel_rsp_generation),
   .a_prepare_cancel_rsp_epoch(l_prepare_cancel_rsp_epoch),
   .a_prepare_cancel_rsp_status(l_prepare_cancel_rsp_status),
   .a_layer_idle(l_layer_idle),
   .a_check_coverage_fault(l_check_coverage_fault),
   .a_check_first_conflict(l_check_first_conflict),
   .a_res_qkv_wr_valid(l_res_qkv_wr_valid),
   .a_res_qkv_wr_ready(l_res_qkv_wr_ready),
   .a_res_qkv_wr_plane(l_res_qkv_wr_plane),
   .a_res_qkv_wr_head(l_res_qkv_wr_head),
   .a_res_qkv_wr_token(l_res_qkv_wr_token),
   .a_res_qkv_wr_half(l_res_qkv_wr_half),
   .a_res_qkv_wr_data(l_res_qkv_wr_data),
   .a_res_qkv_rd_valid(l_res_qkv_rd_valid),
   .a_res_qkv_rd_ready(l_res_qkv_rd_ready),
   .a_res_qkv_rd_head(l_res_qkv_rd_head),
   .a_res_qkv_rd_token(l_res_qkv_rd_token),
   .a_res_qkv_rd_tag(l_res_qkv_rd_tag),
   .a_res_qkv_rd_rsp_valid(l_res_qkv_rd_rsp_valid),
   .a_res_qkv_rd_rsp_ready(l_res_qkv_rd_rsp_ready),
   .a_res_qkv_rd_rsp_head(l_res_qkv_rd_rsp_head),
   .a_res_qkv_rd_rsp_token(l_res_qkv_rd_rsp_token),
   .a_res_qkv_rd_rsp_tag(l_res_qkv_rd_rsp_tag),
   .a_res_qkv_rd_rsp_data(l_res_qkv_rd_rsp_data),
   .a_res_st_bind_valid(l_res_st_bind_valid),
   .a_res_st_bind_ready(l_res_st_bind_ready),
   .a_res_st_bind_request_id(l_res_st_bind_request_id),
   .a_res_st_bind_generation(l_res_st_bind_generation),
   .a_res_st_bind_epoch(l_res_st_bind_epoch),
   .a_res_st_bind_head(l_res_st_bind_head),
   .a_res_st_bind_phase(l_res_st_bind_phase),
   .a_res_st_op_request_id(l_res_st_op_request_id),
   .a_res_st_op_generation(l_res_st_op_generation),
   .a_res_st_op_epoch(l_res_st_op_epoch),
   .a_res_st_op_phase(l_res_st_op_phase),
   .a_res_st_rsp_request_id(l_res_st_rsp_request_id),
   .a_res_st_rsp_generation(l_res_st_rsp_generation),
   .a_res_st_rsp_epoch(l_res_st_rsp_epoch),
   .a_res_st_rsp_head(l_res_st_rsp_head),
   .a_res_st_rsp_phase(l_res_st_rsp_phase),
   .a_res_st_ps_wr_valid(l_res_st_ps_wr_valid),
   .a_res_st_ps_wr_ready(l_res_st_ps_wr_ready),
   .a_res_st_ps_wr_mask(l_res_st_ps_wr_mask),
   .a_res_st_ps_wr_addr(l_res_st_ps_wr_addr),
   .a_res_st_ps_wr_data(l_res_st_ps_wr_data),
   .a_res_st_ps_wr_tag(l_res_st_ps_wr_tag),
   .a_res_st_ps_wr_rsp_valid(l_res_st_ps_wr_rsp_valid),
   .a_res_st_ps_wr_rsp_ready(l_res_st_ps_wr_rsp_ready),
   .a_res_st_ps_wr_rsp_tag(l_res_st_ps_wr_rsp_tag),
   .a_res_st_ps_rd_valid(l_res_st_ps_rd_valid),
   .a_res_st_ps_rd_ready(l_res_st_ps_rd_ready),
   .a_res_st_ps_rd_mask(l_res_st_ps_rd_mask),
   .a_res_st_ps_rd_addr(l_res_st_ps_rd_addr),
   .a_res_st_ps_rd_tag(l_res_st_ps_rd_tag),
   .a_res_st_ps_rd_rsp_valid(l_res_st_ps_rd_rsp_valid),
   .a_res_st_ps_rd_rsp_ready(l_res_st_ps_rd_rsp_ready),
   .a_res_st_ps_rd_rsp_data(l_res_st_ps_rd_rsp_data),
   .a_res_st_ps_rd_rsp_mask(l_res_st_ps_rd_rsp_mask),
   .a_res_st_ps_rd_rsp_tag(l_res_st_ps_rd_rsp_tag),
   .a_res_st_g_wr_valid(l_res_st_g_wr_valid),
   .a_res_st_g_wr_ready(l_res_st_g_wr_ready),
   .a_res_st_g_wr_mask(l_res_st_g_wr_mask),
   .a_res_st_g_wr_addr(l_res_st_g_wr_addr),
   .a_res_st_g_wr_data(l_res_st_g_wr_data),
   .a_res_st_g_wr_tag(l_res_st_g_wr_tag),
   .a_res_st_g_wr_rsp_valid(l_res_st_g_wr_rsp_valid),
   .a_res_st_g_wr_rsp_ready(l_res_st_g_wr_rsp_ready),
   .a_res_st_g_wr_rsp_tag(l_res_st_g_wr_rsp_tag),
   .a_res_st_g_rd_valid(l_res_st_g_rd_valid),
   .a_res_st_g_rd_ready(l_res_st_g_rd_ready),
   .a_res_st_g_rd_mask(l_res_st_g_rd_mask),
   .a_res_st_g_rd_addr(l_res_st_g_rd_addr),
   .a_res_st_g_rd_tag(l_res_st_g_rd_tag),
   .a_res_st_g_rd_rsp_valid(l_res_st_g_rd_rsp_valid),
   .a_res_st_g_rd_rsp_ready(l_res_st_g_rd_rsp_ready),
   .a_res_st_g_rd_rsp_data(l_res_st_g_rd_rsp_data),
   .a_res_st_g_rd_rsp_mask(l_res_st_g_rd_rsp_mask),
   .a_res_st_g_rd_rsp_tag(l_res_st_g_rd_rsp_tag),
   .a_res_st_context_wr_valid(l_res_st_context_wr_valid),
   .a_res_st_context_wr_ready(l_res_st_context_wr_ready),
   .a_res_st_context_wr_mask(l_res_st_context_wr_mask),
   .a_res_st_context_wr_addr(l_res_st_context_wr_addr),
   .a_res_st_context_wr_data(l_res_st_context_wr_data),
   .a_res_st_context_wr_tag(l_res_st_context_wr_tag),
   .a_res_st_context_wr_rsp_valid(l_res_st_context_wr_rsp_valid),
   .a_res_st_context_wr_rsp_ready(l_res_st_context_wr_rsp_ready),
   .a_res_st_context_wr_rsp_tag(l_res_st_context_wr_rsp_tag),
   .a_res_st_context_rd_valid(l_res_st_context_rd_valid),
   .a_res_st_context_rd_ready(l_res_st_context_rd_ready),
   .a_res_st_context_rd_mask(l_res_st_context_rd_mask),
   .a_res_st_context_rd_addr(l_res_st_context_rd_addr),
   .a_res_st_context_rd_tag(l_res_st_context_rd_tag),
   .a_res_st_context_rd_rsp_valid(l_res_st_context_rd_rsp_valid),
   .a_res_st_context_rd_rsp_ready(l_res_st_context_rd_rsp_ready),
   .a_res_st_context_rd_rsp_data(l_res_st_context_rd_rsp_data),
   .a_res_st_context_rd_rsp_mask(l_res_st_context_rd_rsp_mask),
   .a_res_st_context_rd_rsp_tag(l_res_st_context_rd_rsp_tag),
   .a_res_st_idle(l_res_st_idle),
   .a_res_fp_lease_valid(l_res_fp_lease_valid),
   .a_res_fp_lease_ready(l_res_fp_lease_ready),
   .a_res_fp_lease_request_id(l_res_fp_lease_request_id),
   .a_res_fp_lease_generation(l_res_fp_lease_generation),
   .a_res_fp_lease_epoch(l_res_fp_lease_epoch),
   .a_res_fp_lease_head(l_res_fp_lease_head),
   .a_res_fp_lease_phase(l_res_fp_lease_phase),
   .a_res_fp_release_valid(l_res_fp_release_valid),
   .a_res_fp_release_ready(l_res_fp_release_ready),
   .a_res_fp_release_phase(l_res_fp_release_phase),
   .a_res_fp_release_epoch(l_res_fp_release_epoch),
   .a_res_fp_phase_debt_clear(l_res_fp_phase_debt_clear),
   .a_res_fp_lease_active(l_res_fp_lease_active),
   .a_res_fp_draining(l_res_fp_draining),
   .a_res_fp_rsp_request_id(l_res_fp_rsp_request_id),
   .a_res_fp_rsp_generation(l_res_fp_rsp_generation),
   .a_res_fp_rsp_epoch(l_res_fp_rsp_epoch),
   .a_res_fp_rsp_head(l_res_fp_rsp_head),
   .a_res_fp_rsp_phase(l_res_fp_rsp_phase),
   .a_res_fp_mul_req_valid(l_res_fp_mul_req_valid),
   .a_res_fp_mul_req_ready(l_res_fp_mul_req_ready),
   .a_res_fp_mul_req_phase(l_res_fp_mul_req_phase),
   .a_res_fp_mul_req_epoch(l_res_fp_mul_req_epoch),
   .a_res_fp_mul_req_tag(l_res_fp_mul_req_tag),
   .a_res_fp_mul_a(l_res_fp_mul_a),
   .a_res_fp_mul_b(l_res_fp_mul_b),
   .a_res_fp_mul_rsp_valid(l_res_fp_mul_rsp_valid),
   .a_res_fp_mul_rsp_ready(l_res_fp_mul_rsp_ready),
   .a_res_fp_mul_rsp_tag(l_res_fp_mul_rsp_tag),
   .a_res_fp_mul_rsp_data(l_res_fp_mul_rsp_data),
   .a_res_fp_add_req_valid(l_res_fp_add_req_valid),
   .a_res_fp_add_req_is_root(l_res_fp_add_req_is_root),
   .a_res_fp_add_req_ready(l_res_fp_add_req_ready),
   .a_res_fp_add_req_phase(l_res_fp_add_req_phase),
   .a_res_fp_add_req_epoch(l_res_fp_add_req_epoch),
   .a_res_fp_add_req_tag(l_res_fp_add_req_tag),
   .a_res_fp_add_a(l_res_fp_add_a),
   .a_res_fp_add_b(l_res_fp_add_b),
   .a_res_fp_add_rsp_valid(l_res_fp_add_rsp_valid),
   .a_res_fp_add_rsp_ready(l_res_fp_add_rsp_ready),
   .a_res_fp_add_rsp_tag(l_res_fp_add_rsp_tag),
   .a_res_fp_add_rsp_data(l_res_fp_add_rsp_data),
   .a_res_fp_mul_pending(l_res_fp_mul_pending),
   .a_res_fp_add_pending(l_res_fp_add_pending),
   .a_res_fp_protocol_fault(l_res_fp_protocol_fault),
   .a_res_ln_bind_valid(l_res_ln_bind_valid),
   .a_res_ln_bind_ready(l_res_ln_bind_ready),
   .a_res_ln_bind_request_id(l_res_ln_bind_request_id),
   .a_res_ln_bind_generation(l_res_ln_bind_generation),
   .a_res_ln_bind_epoch(l_res_ln_bind_epoch),
   .a_res_ln_bind_head(l_res_ln_bind_head),
   .a_res_ln_bind_phase(l_res_ln_bind_phase),
   .a_res_ln_op_request_id(l_res_ln_op_request_id),
   .a_res_ln_op_generation(l_res_ln_op_generation),
   .a_res_ln_op_epoch(l_res_ln_op_epoch),
   .a_res_ln_op_phase(l_res_ln_op_phase),
   .a_res_ln_rsp_request_id(l_res_ln_rsp_request_id),
   .a_res_ln_rsp_generation(l_res_ln_rsp_generation),
   .a_res_ln_rsp_epoch(l_res_ln_rsp_epoch),
   .a_res_ln_rsp_head(l_res_ln_rsp_head),
   .a_res_ln_rsp_phase(l_res_ln_rsp_phase),
   .a_res_ln_wr_valid(l_res_ln_wr_valid),
   .a_res_ln_wr_ready(l_res_ln_wr_ready),
   .a_res_ln_wr_mask(l_res_ln_wr_mask),
   .a_res_ln_wr_addr(l_res_ln_wr_addr),
   .a_res_ln_wr_data(l_res_ln_wr_data),
   .a_res_ln_wr_tag(l_res_ln_wr_tag),
   .a_res_ln_wr_rsp_valid(l_res_ln_wr_rsp_valid),
   .a_res_ln_wr_rsp_ready(l_res_ln_wr_rsp_ready),
   .a_res_ln_wr_rsp_tag(l_res_ln_wr_rsp_tag),
   .a_res_ln_rd_valid(l_res_ln_rd_valid),
   .a_res_ln_rd_ready(l_res_ln_rd_ready),
   .a_res_ln_rd_mask(l_res_ln_rd_mask),
   .a_res_ln_rd_addr(l_res_ln_rd_addr),
   .a_res_ln_rd_tag(l_res_ln_rd_tag),
   .a_res_ln_rd_rsp_valid(l_res_ln_rd_rsp_valid),
   .a_res_ln_rd_rsp_ready(l_res_ln_rd_rsp_ready),
   .a_res_ln_rd_rsp_data(l_res_ln_rd_rsp_data),
   .a_res_ln_rd_rsp_mask(l_res_ln_rd_rsp_mask),
   .a_res_ln_rd_rsp_tag(l_res_ln_rd_rsp_tag),
   .a_res_ln_idle(l_res_ln_idle),
   .a_res_sfu_lease_valid(l_res_sfu_lease_valid),
   .a_res_sfu_lease_ready(l_res_sfu_lease_ready),
   .a_res_sfu_lease_request_id(l_res_sfu_lease_request_id),
   .a_res_sfu_lease_generation(l_res_sfu_lease_generation),
   .a_res_sfu_lease_epoch(l_res_sfu_lease_epoch),
   .a_res_sfu_lease_head(l_res_sfu_lease_head),
   .a_res_sfu_lease_phase(l_res_sfu_lease_phase),
   .a_res_sfu_release_valid(l_res_sfu_release_valid),
   .a_res_sfu_release_phase(l_res_sfu_release_phase),
   .a_res_sfu_release_epoch(l_res_sfu_release_epoch),
   .a_res_sfu_phase_debt_clear(l_res_sfu_phase_debt_clear),
   .a_res_sfu_lease_active(l_res_sfu_lease_active),
   .a_res_sfu_context_valid(l_res_sfu_context_valid),
   .a_res_sfu_context_row_hi(l_res_sfu_context_row_hi),
   .a_res_sfu_req_valid(l_res_sfu_req_valid),
   .a_res_sfu_req_ready(l_res_sfu_req_ready),
   .a_res_sfu_req_mode(l_res_sfu_req_mode),
   .a_res_sfu_req_generation(l_res_sfu_req_generation),
   .a_res_sfu_req_epoch(l_res_sfu_req_epoch),
   .a_res_sfu_req_phase(l_res_sfu_req_phase),
   .a_res_sfu_req_tag(l_res_sfu_req_tag),
   .a_res_sfu_req_x(l_res_sfu_req_x),
   .a_res_sfu_reject_valid(l_res_sfu_reject_valid),
   .a_res_sfu_rsp_valid(l_res_sfu_rsp_valid),
   .a_res_sfu_rsp_ready(l_res_sfu_rsp_ready),
   .a_res_sfu_rsp_tag(l_res_sfu_rsp_tag),
   .a_res_sfu_rsp_data(l_res_sfu_rsp_data),
   .a_res_sfu_pending_vectors(l_res_sfu_pending_vectors),
   .a_res_sfu_in_flight_vectors(l_res_sfu_in_flight_vectors),
   .a_res_sfu_protocol_fault(l_res_sfu_protocol_fault),
   .a_res_div_lease_valid(l_res_div_lease_valid),
   .a_res_div_lease_ready(l_res_div_lease_ready),
   .a_res_div_lease_request_id(l_res_div_lease_request_id),
   .a_res_div_lease_generation(l_res_div_lease_generation),
   .a_res_div_lease_epoch(l_res_div_lease_epoch),
   .a_res_div_lease_head(l_res_div_lease_head),
   .a_res_div_lease_phase(l_res_div_lease_phase),
   .a_res_div_release_valid(l_res_div_release_valid),
   .a_res_div_release_phase(l_res_div_release_phase),
   .a_res_div_release_epoch(l_res_div_release_epoch),
   .a_res_div_phase_debt_clear(l_res_div_phase_debt_clear),
   .a_res_div_lease_active(l_res_div_lease_active),
   .a_res_div_req_valid(l_res_div_req_valid),
   .a_res_div_req_ready(l_res_div_req_ready),
   .a_res_div_req_generation(l_res_div_req_generation),
   .a_res_div_req_epoch(l_res_div_req_epoch),
   .a_res_div_req_phase(l_res_div_req_phase),
   .a_res_div_req_lane_mask(l_res_div_req_lane_mask),
   .a_res_div_req_tag(l_res_div_req_tag),
   .a_res_div_req_a(l_res_div_req_a),
   .a_res_div_req_b(l_res_div_req_b),
   .a_res_div_protocol_reject_valid(l_res_div_protocol_reject_valid),
   .a_res_div_rsp_valid(l_res_div_rsp_valid),
   .a_res_div_rsp_ready(l_res_div_rsp_ready),
   .a_res_div_rsp_tag(l_res_div_rsp_tag),
   .a_res_div_rsp_numeric_error(l_res_div_rsp_numeric_error),
   .a_res_div_rsp_data(l_res_div_rsp_data),
   .a_res_div_pending_vectors(l_res_div_pending_vectors),
   .a_res_div_in_flight_vectors(l_res_div_in_flight_vectors),
   .a_res_div_in_flight_scalars(l_res_div_in_flight_scalars),
   .a_res_div_protocol_fault(l_res_div_protocol_fault),
   .a_res_scale_valid(l_res_scale_valid),
   .a_res_scale_ready(l_res_scale_ready),
   .a_res_scale_tag(l_res_scale_tag),
   .a_res_scale_input(l_res_scale_input),
   .a_res_scale_rsp_valid(l_res_scale_rsp_valid),
   .a_res_scale_rsp_ready(l_res_scale_rsp_ready),
   .a_res_scale_rsp_tag(l_res_scale_rsp_tag),
   .a_res_scale_data(l_res_scale_data),
   .a_res_scale_pending(l_res_scale_pending),
   .a_res_scale_fault(l_res_scale_fault),
   .a_rope_owner_valid(l_rope_owner_valid),
   .a_rope_owner_request_id(l_rope_owner_request_id),
   .a_rope_owner_generation(l_rope_owner_generation),
   .a_rope_owner_epoch(l_rope_owner_epoch),
   .a_rope_wr_valid(l_rope_wr_valid),
   .a_rope_wr_ready(l_rope_wr_ready),
   .a_rope_wr_request_id(l_rope_wr_request_id),
   .a_rope_wr_generation(l_rope_wr_generation),
   .a_rope_wr_epoch(l_rope_wr_epoch),
   .a_rope_wr_head(l_rope_wr_head),
   .a_rope_wr_token(l_rope_wr_token),
   .a_rope_wr_tag(l_rope_wr_tag),
   .a_rope_wr_q(l_rope_wr_q),
   .a_rope_wr_k(l_rope_wr_k),
   .a_rope_wr_commit_valid(l_rope_wr_commit_valid),
   .a_rope_wr_commit_tag(l_rope_wr_commit_tag),
   .a_rope_reject_valid(l_rope_reject_valid),
   .a_rope_reject_code(l_rope_reject_code),
   .a_cache_bound_valid(l_cache_bound_valid),
   .a_cache_bound_model_id(l_cache_bound_model_id),
   .a_cache_bound_numeric_id(l_cache_bound_numeric_id),
   .a_cache_bound_table_key(l_cache_bound_table_key),
   .a_cache_family_complete(l_cache_family_complete),
   .a_cache_owner_valid(l_cache_owner_valid),
   .a_cache_owner_request_id(l_cache_owner_request_id),
   .a_cache_owner_generation(l_cache_owner_generation),
   .a_cache_owner_epoch(l_cache_owner_epoch),
   .a_cache_rd_valid(l_cache_rd_valid),
   .a_cache_rd_ready(l_cache_rd_ready),
   .a_cache_rd_family(l_cache_rd_family),
   .a_cache_rd_row(l_cache_rd_row),
   .a_cache_rd_tag(l_cache_rd_tag),
   .a_cache_rd_request_id(l_cache_rd_request_id),
   .a_cache_rd_generation(l_cache_rd_generation),
   .a_cache_rd_epoch(l_cache_rd_epoch),
   .a_cache_rd_reject_valid(l_cache_rd_reject_valid),
   .a_cache_rd_reject_code(l_cache_rd_reject_code),
   .a_cache_rsp_valid(l_cache_rsp_valid),
   .a_cache_rsp_ready(l_cache_rsp_ready),
   .a_cache_rsp_family(l_cache_rsp_family),
   .a_cache_rsp_row(l_cache_rsp_row),
   .a_cache_rsp_tag(l_cache_rsp_tag),
   .a_cache_rsp_data(l_cache_rsp_data),
   .owner_req_valid(ws_owner_req_valid),
   .owner_req_g(ws_owner_req_g),
   .owner_req_ready(ws_owner_req_ready),
   .a_enable(ws_a_enable),
   .g_enable(ws_g_enable),
   .rearm(ws_rearm),
   .owner_g(ws_owner_g),
   .g_producer_cancel_valid(g_producer_cancel_valid),
   .g_producer_cancel_ready(g_producer_cancel_ready),
   .g_producer_cancel_request_id(g_producer_cancel_request_id),
   .g_producer_cancel_generation(g_producer_cancel_generation),
   .g_producer_cancel_epoch(g_producer_cancel_epoch),
   .g_producer_cancel_reject_valid(g_producer_cancel_reject_valid),
   .g_done_cancelled(g_done_cancelled),
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
   .g_g_rd_rsp_tag(g_g_rd_rsp_tag)
  );
 laya_m007_matrix_facade_v1 #(.PROFILE_ENABLE(0)) matrix(
 .clk(clk),
 .rst_n(rst_n),
 .cmd_valid(m_cmd_valid),
 .cmd_ready(m_cmd_ready),
 .descriptor_precheck_ok(m_descriptor_precheck_ok),
 .cmd_version(m_cmd_version),
 .cmd_request(m_cmd_request),
 .cmd_model(m_cmd_model),
 .cmd_generation(m_cmd_generation),
 .cmd_epoch(m_cmd_epoch),
 .cmd_tensor(m_cmd_tensor),
 .cmd_k(m_cmd_k),
 .cmd_n(m_cmd_n),
 .cmd_a_slot(m_cmd_a_slot),
 .cmd_bias(m_cmd_bias),
 .cmd_base(m_cmd_base),
 .cmd_span(m_cmd_span),
 .done_valid(m_done_valid),
 .done_ready(m_done_ready),
 .status(m_status),
 .done_request(m_done_request),
 .done_generation(m_done_generation),
 .done_epoch(m_done_epoch),
 .error_row(m_error_row),
 .error_col(m_error_col),
 .error_group(m_error_group),
 .error_stage(m_error_stage),
 .out_valid(m_out_valid),
 .out_ready(m_out_ready),
 .out_data(m_out_data),
 .out_row(m_out_row),
 .out_col(m_out_col),
 .out_s(m_out_s),
 .out_request(m_out_request),
 .out_generation(m_out_generation),
 .out_epoch(m_out_epoch),
 .acfg_valid(m_acfg_valid),
 .acfg_ready(m_acfg_ready),
 .acfg_slot(m_acfg_slot),
 .acfg_k(m_acfg_k),
 .acfg_request(m_acfg_request),
 .acfg_generation(m_acfg_generation),
 .acfg_epoch(m_acfg_epoch),
 .acfg_rsp_valid(m_acfg_rsp_valid),
 .acfg_rsp_ready(m_acfg_rsp_ready),
 .acfg_status(m_acfg_status),
 .fill_cancel_valid(m_fill_cancel_valid),
 .fill_cancel_ready(m_fill_cancel_ready),
 .fill_cancel_slot(m_fill_cancel_slot),
 .fill_cancel_request(m_fill_cancel_request),
 .fill_cancel_generation(m_fill_cancel_generation),
 .fill_cancel_epoch(m_fill_cancel_epoch),
 .fill_cancel_reject_valid(m_fill_cancel_reject_valid),
 .fill_cancel_reject_code(m_fill_cancel_reject_code),
 .fill_cancel_rsp_valid(m_fill_cancel_rsp_valid),
 .fill_cancel_rsp_ready(m_fill_cancel_rsp_ready),
 .fill_cancel_rsp_slot(m_fill_cancel_rsp_slot),
 .fill_cancel_rsp_request(m_fill_cancel_rsp_request),
 .fill_cancel_rsp_generation(m_fill_cancel_rsp_generation),
 .fill_cancel_rsp_epoch(m_fill_cancel_rsp_epoch),
 .awr_valid(m_awr_valid),
 .awr_ready(m_awr_ready),
 .awr_row(m_awr_row),
 .awr_group(m_awr_group),
 .awr_data(m_awr_data),
 .awr_request(m_awr_request),
 .awr_generation(m_awr_generation),
 .awr_epoch(m_awr_epoch),
 .awr_rsp_valid(m_awr_rsp_valid),
 .awr_rsp_ready(m_awr_rsp_ready),
 .coef_cfg_valid(m_coef_cfg_valid),
 .coef_cfg_ready(m_coef_cfg_ready),
 .coef_model(m_coef_model),
 .coef_request(m_coef_request),
 .coef_tensor(m_coef_tensor),
 .coef_generation(m_coef_generation),
 .coef_epoch(m_coef_epoch),
 .coef_n(m_coef_n),
 .coef_wr_valid(m_coef_wr_valid),
 .coef_wr_ready(m_coef_wr_ready),
 .coef_wr_addr(m_coef_wr_addr),
 .coef_wr_data(m_coef_wr_data),
 .coef_rsp_valid(m_coef_rsp_valid),
 .coef_rsp_ready(m_coef_rsp_ready),
 .coef_status(m_coef_status),
 .coef_error_col(m_coef_error_col),
 .arvalid(m_arvalid),
 .arready(m_arready),
 .araddr(m_araddr),
 .arid(m_arid),
 .arlen(m_arlen),
 .rvalid(m_rvalid),
 .rready(m_rready),
 .rid(m_rid),
 .rdata(m_rdata),
 .rresp(m_rresp),
 .rlast(m_rlast),
 .run_enable(m_run_enable),
 .elapsed_cycles(m_elapsed_cycles),
 .first_output_cycle(m_first_output_cycle),
 .w_wait_cycles(m_w_wait_cycles),
 .ctx_wait_cycles(m_ctx_wait_cycles),
 .blocks_issued(m_blocks_issued),
 .blocks_computed(m_blocks_computed),
 .blocks_retired(m_blocks_retired),
 .ps_merged_reads(m_ps_merged_reads),
 .ps_response_holds(m_ps_response_holds),
 .bias_add_conflicts(m_bias_add_conflicts),
 .compute_output_overlap(m_compute_output_overlap),
 .peak_return_reservations(m_peak_return_reservations),
 .arithmetic_debt(m_arithmetic_debt),
 .peak_arithmetic_reservations(m_peak_arithmetic_reservations),
 .profile_valid(m_profile_valid),
 .fp_owner_request(m_fp_owner_request),
 .fp_owner_generation(m_fp_owner_generation),
 .fp_owner_epoch(m_fp_owner_epoch),
 .bind_new_lease(m_bind_new_lease),
 .fp_release_valid(m_fp_release_valid),
 .fp_phase_debt_clear(m_fp_phase_debt_clear),
 .fp_lease_ready(m_fp_lease_ready),
 .fp_release_ready(m_fp_release_ready),
 .fp_lease_active(m_fp_lease_active),
 .fp_draining(m_fp_draining),
 .fp_fault(m_fp_fault),
 .storage_bind_ready(m_storage_bind_ready),
 .storage_idle(m_storage_idle),
 .mul_req_valid(m_mul_req_valid),
 .mul_rsp_ready(m_mul_rsp_ready),
 .mul_req_ready(m_mul_req_ready),
 .mul_rsp_valid(m_mul_rsp_valid),
 .mul_req_tag(m_mul_req_tag),
 .mul_rsp_tag(m_mul_rsp_tag),
 .mul_a(m_mul_a),
 .mul_b(m_mul_b),
 .mul_rsp_data(m_mul_rsp_data),
 .mul_pending(m_mul_pending),
 .add_req_valid(m_add_req_valid),
 .add_req_is_root(m_add_req_is_root),
 .add_rsp_ready(m_add_rsp_ready),
 .add_req_ready(m_add_req_ready),
 .add_rsp_valid(m_add_rsp_valid),
 .add_req_phase(m_add_req_phase),
 .add_req_epoch(m_add_req_epoch),
 .add_req_tag(m_add_req_tag),
 .add_rsp_tag(m_add_rsp_tag),
 .add_a(m_add_a),
 .add_b(m_add_b),
 .add_rsp_data(m_add_rsp_data),
 .add_pending(m_add_pending),
 .ps_wr_valid(m_ps_wr_valid),
 .ps_wr_rsp_ready(m_ps_wr_rsp_ready),
 .ps_rd_valid(m_ps_rd_valid),
 .ps_rd_rsp_ready(m_ps_rd_rsp_ready),
 .ps_wr_ready(m_ps_wr_ready),
 .ps_wr_rsp_valid(m_ps_wr_rsp_valid),
 .ps_rd_ready(m_ps_rd_ready),
 .ps_rd_rsp_valid(m_ps_rd_rsp_valid),
 .ps_wr_mask(m_ps_wr_mask),
 .ps_rd_mask(m_ps_rd_mask),
 .ps_rd_rsp_mask(m_ps_rd_rsp_mask),
 .ps_wr_addr(m_ps_wr_addr),
 .ps_rd_addr(m_ps_rd_addr),
 .ps_wr_data(m_ps_wr_data),
 .ps_rd_rsp_data(m_ps_rd_rsp_data),
 .ps_wr_tag(m_ps_wr_tag),
 .ps_rd_tag(m_ps_rd_tag),
 .ps_wr_rsp_tag(m_ps_wr_rsp_tag),
 .ps_rd_rsp_tag(m_ps_rd_rsp_tag)
 );
 laya_m007_quant_a_fill_v1 front(
 .clk(clk),
 .rst_n(rst_n),
 .run_enable(q_run_enable),
 .cmd_valid(q_cmd_valid),
 .cmd_ready(q_cmd_ready),
 .cmd_slot(q_cmd_slot),
 .cmd_k(q_cmd_k),
 .cmd_request(q_cmd_request),
 .cmd_generation(q_cmd_generation),
 .cmd_epoch(q_cmd_epoch),
 .in_valid(q_in_valid),
 .in_ready(q_in_ready),
 .in_data(q_in_data),
 .in_request(q_in_request),
 .in_generation(q_in_generation),
 .in_epoch(q_in_epoch),
 .in_row(q_in_row),
 .in_group(q_in_group),
 .producer_close_valid(q_producer_close_valid),
 .producer_close_ready(q_producer_close_ready),
 .producer_close_success(q_producer_close_success),
 .done_valid(q_done_valid),
 .done_ready(q_done_ready),
 .status(q_status),
 .quant_phase(q_quant_phase),
 .quant_row(q_quant_row),
 .quant_group(q_quant_group),
 .quant_element(q_quant_element),
 .quant_accepted(q_quant_accepted),
 .quant_retired(q_quant_retired),
 .a_writes(q_a_writes),
 .a_write_acks(q_a_write_acks),
 .quant_last_event(q_quant_last_event),
 .a_publish_event(q_a_publish_event),
 .acfg_valid(q_acfg_valid),
 .acfg_ready(q_acfg_ready),
 .acfg_slot(q_acfg_slot),
 .acfg_k(q_acfg_k),
 .acfg_request(q_acfg_request),
 .acfg_generation(q_acfg_generation),
 .acfg_epoch(q_acfg_epoch),
 .acfg_rsp_valid(q_acfg_rsp_valid),
 .acfg_rsp_ready(q_acfg_rsp_ready),
 .acfg_status(q_acfg_status),
 .awr_valid(q_awr_valid),
 .awr_ready(q_awr_ready),
 .awr_row(q_awr_row),
 .awr_group(q_awr_group),
 .awr_data(q_awr_data),
 .awr_request(q_awr_request),
 .awr_generation(q_awr_generation),
 .awr_epoch(q_awr_epoch),
 .awr_rsp_valid(q_awr_rsp_valid),
 .awr_rsp_ready(q_awr_rsp_ready),
 .fill_cancel_valid(q_fill_cancel_valid),
 .fill_cancel_ready(q_fill_cancel_ready),
 .fill_cancel_slot(q_fill_cancel_slot),
 .fill_cancel_request(q_fill_cancel_request),
 .fill_cancel_generation(q_fill_cancel_generation),
 .fill_cancel_epoch(q_fill_cancel_epoch),
 .fill_cancel_reject_valid(q_fill_cancel_reject_valid),
 .fill_cancel_reject_code(q_fill_cancel_reject_code),
 .fill_cancel_rsp_valid(q_fill_cancel_rsp_valid),
 .fill_cancel_rsp_ready(q_fill_cancel_rsp_ready),
 .fill_cancel_rsp_slot(q_fill_cancel_rsp_slot),
 .fill_cancel_rsp_request(q_fill_cancel_rsp_request),
 .fill_cancel_rsp_generation(q_fill_cancel_rsp_generation),
 .fill_cancel_rsp_epoch(q_fill_cancel_rsp_epoch),
 .d_lease_valid(q_d_lease_valid),
 .d_lease_ready(q_d_lease_ready),
 .d_lease_request_id(q_d_lease_request_id),
 .d_lease_generation(q_d_lease_generation),
 .d_lease_epoch(q_d_lease_epoch),
 .d_lease_head(q_d_lease_head),
 .d_lease_phase(q_d_lease_phase),
 .d_release_valid(q_d_release_valid),
 .d_release_ready(q_d_release_ready),
 .d_release_phase(q_d_release_phase),
 .d_release_epoch(q_d_release_epoch),
 .d_phase_debt_clear(q_d_phase_debt_clear),
 .d_lease_active(q_d_lease_active),
 .d_draining(q_d_draining),
 .d_rsp_request_id(q_d_rsp_request_id),
 .d_rsp_generation(q_d_rsp_generation),
 .d_rsp_epoch(q_d_rsp_epoch),
 .d_rsp_head(q_d_rsp_head),
 .d_rsp_phase(q_d_rsp_phase),
 .d_req_valid(q_d_req_valid),
 .d_req_ready(q_d_req_ready),
 .d_req_generation(q_d_req_generation),
 .d_req_epoch(q_d_req_epoch),
 .d_req_phase(q_d_req_phase),
 .d_req_lane_mask(q_d_req_lane_mask),
 .d_req_tag(q_d_req_tag),
 .d_req_a(q_d_req_a),
 .d_req_b(q_d_req_b),
 .d_protocol_reject_valid(q_d_protocol_reject_valid),
 .d_protocol_reject_code(q_d_protocol_reject_code),
 .d_rsp_valid(q_d_rsp_valid),
 .d_rsp_ready(q_d_rsp_ready),
 .d_rsp_tag(q_d_rsp_tag),
 .d_rsp_lane_mask(q_d_rsp_lane_mask),
 .d_rsp_numeric_error(q_d_rsp_numeric_error),
 .d_rsp_data(q_d_rsp_data),
 .d_pending_vectors(q_d_pending_vectors),
 .d_in_flight_vectors(q_d_in_flight_vectors),
 .d_in_flight_scalars(q_d_in_flight_scalars),
 .d_protocol_fault(q_d_protocol_fault)
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
  assign ws_owner_req_valid=state==F_ARENA||state==F_RETURN;
  assign ws_owner_req_g=state==F_ARENA;
  assign g_cmd_valid=state==F_GQSUB&&q_cmd_ready;
  assign g_cmd_request_id=request_id;assign g_cmd_generation=generation;assign g_cmd_epoch=epoch;
  assign g_storage_owner_valid=ffn_mode&&r_res_fp_lease_active&&r_res_fp_rsp_request_id==request_id&&r_res_fp_rsp_generation==generation&&r_res_fp_rsp_epoch==epoch;
  assign g_storage_owner_request_id=r_res_st_rsp_request_id;assign g_storage_owner_generation=r_res_st_rsp_generation;assign g_storage_owner_epoch=r_res_st_rsp_epoch;assign g_storage_owner_phase=r_res_st_rsp_phase;
  assign g_sfu_owner_valid=tanh_lease_active;assign g_sfu_owner_request_id=tanh_request;assign g_sfu_owner_generation=tanh_generation;assign g_sfu_owner_epoch=tanh_epoch;assign g_sfu_owner_phase=tanh_phase;
  assign g_fill_valid=ffn_mode&&g_active&&state!=F_ABORT&&m_out_valid&&!wo_phase;
  assign g_fill_request_id=m_out_request;assign g_fill_generation=m_out_generation;assign g_fill_epoch=m_out_epoch;
  assign g_fill_slot=m_out_s[0];assign g_fill_s=m_out_s[6:0];assign g_fill_half=m_out_col>=2624;assign g_fill_row=m_out_row;assign g_fill_data=m_out_data;
  assign g_out_ready=state==F_ABORT?1'b1:((state==F_RUN||state==F_CLOSE)&&(!pack_full||q_in_ready)&&pack_seq<41984);
  assign g_done_ready=(state==F_CLOSE&&ffn_close_fire)||state==F_ABORT;
  assign g_producer_cancel_valid=state==F_ABORT&&g_active&&!g_cancel_sent;
  assign g_producer_cancel_request_id=request_id;assign g_producer_cancel_generation=generation;assign g_producer_cancel_epoch=epoch;
  assign g_discard_valid=state==F_DISCARD&&g_needs_discard;
  assign g_discard_request_id=request_id;assign g_discard_generation=generation;assign g_discard_epoch=epoch;
  always_ff @(posedge clk)begin
   if(!rst_n)begin pack_seq<=0;pack_full<=0;pack_fault<=0;g_cancel_sent<=0;q_close_sent<=0;end
   else begin
    if(cmd_valid&&cmd_ready)begin pack_seq<=0;pack_full<=0;pack_fault<=0;g_cancel_sent<=0;q_close_sent<=0;end
    if(q_in_valid&&q_in_ready&&ffn_mode&&state!=F_NQRUN)pack_full<=0;
    if(g_output_fire&&state!=F_ABORT)begin
     if(g_out_tag!={generation,epoch,16'b0,pack_seq})pack_fault<=1;
     pack_data[8*pack_seq[1:0]+:8]<=g_out_data;pack_seq<=pack_seq+1'b1;
     if(pack_seq[1:0]==3)pack_full<=1;
    end
    if(g_producer_cancel_valid&&g_producer_cancel_ready)g_cancel_sent<=1;
    if(ffn_close_fire&&ffn_mode&&state!=F_NQRUN)begin q_close_sent<=1;if(state==F_ABORT)pack_full<=0;end
   end
  end
  laya_m007_g_vector_pool_v1 g_pool(.clk,.rst_n(g_pool_reset_n),.req_valid(g_fp_req_valid),.req_ready(g_fp_req_ready),.req_tag(g_fp_req_tag),.req_a(g_fp_req_a),.req_b(g_fp_req_b),.rsp_valid(g_fp_rsp_valid),.rsp_tag(g_fp_rsp_tag),.rsp_data(g_fp_rsp_data),.rsp_status(g_fp_rsp_status),.protocol_fault(g_fp_pool_fault));
  laya_m007_tanh8_v1 g_tanh(.clk,.rst_n,.lease_valid(state==F_GQSUB&&!tanh_lease_active&&ws_g_enable),.lease_ready(tanh_lease_ready),.lease_request_id(request_id),.lease_generation(generation),.lease_epoch(epoch),.lease_phase(3'd1),
   .release_valid(state==F_RELEASE&&tanh_lease_active&&g_engine_idle&&r_res_st_idle&&tanh_pending==0&&tanh_flight==0),.release_ready(tanh_release_ready),.release_phase(3'd1),.release_epoch(epoch),.phase_debt_clear(g_engine_idle&&r_res_st_idle),
   .lease_active(tanh_lease_active),.draining(tanh_draining),.rsp_request_id(tanh_request),.rsp_generation(tanh_generation),.rsp_epoch(tanh_epoch),.rsp_phase(tanh_phase),
   .req_valid(g_sfu_req_valid),.req_ready(g_sfu_req_ready),.req_mode(2'd1),.req_request_id(g_rsp_request_id),.req_generation(g_rsp_generation),.req_epoch(g_rsp_epoch),.req_phase(3'd1),.req_tag(g_sfu_req_tag),.req_mask(g_sfu_req_mask),.req_x(g_sfu_req_x),
   .reject_valid(g_sfu_reject_valid),.reject_code(tanh_reject_code),.rsp_valid(g_sfu_rsp_valid),.rsp_ready(g_sfu_rsp_ready),.rsp_tag(g_sfu_rsp_tag),.rsp_mask(tanh_rsp_mask),.rsp_data(g_sfu_rsp_data),.rsp_status(g_sfu_rsp_status),.pending_vectors(tanh_pending),.in_flight_vectors(tanh_flight),.protocol_fault(g_sfu_protocol_fault));
  assign g_g_wr_ready=ffn_mode?r_res_st_g_wr_ready:'0;
  assign g_g_wr_rsp_valid=ffn_mode?r_res_st_g_wr_rsp_valid:'0;
  assign g_g_wr_rsp_tag=ffn_mode?r_res_st_g_wr_rsp_tag:'0;
  assign g_g_rd_ready=ffn_mode?r_res_st_g_rd_ready:'0;
  assign g_g_rd_rsp_valid=ffn_mode?r_res_st_g_rd_rsp_valid:'0;
  assign g_g_rd_rsp_data=ffn_mode?r_res_st_g_rd_rsp_data:'0;
  assign g_g_rd_rsp_mask=ffn_mode?r_res_st_g_rd_rsp_mask:'0;
  assign g_g_rd_rsp_tag=ffn_mode?r_res_st_g_rd_rsp_tag:'0;

endmodule
