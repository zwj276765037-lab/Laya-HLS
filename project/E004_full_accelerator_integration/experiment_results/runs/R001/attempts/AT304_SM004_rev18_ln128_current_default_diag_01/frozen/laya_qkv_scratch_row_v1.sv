`timescale 1ns/1ps

// One fixed Wi -> canonical G -> Down row with shared Q/matrix/W services.
module laya_qkv_scratch_row_v1 (
  input logic clk, rst_n,
  input logic cmd_valid,
  output logic cmd_ready,
  input logic [31:0] cmd_id,
  input logic cmd_cold,
  input logic cmd_mode,
  input logic [6:0] cmd_row,
  input logic [31:0] cmd_w_epoch,
  input logic [15:0] cmd_weight_key,
  input logic [3327:0] cmd_model_identity,
  input logic [671:0] cmd_numeric_identity,
  input logic [95:0] cmd_task_context,
  input logic [1023:0] cmd_expected_aux_header,
  input logic [2:0][63:0] cmd_load_base,
  input logic [2:0][31:0] cmd_load_bytes,
  input logic [63:0] cmd_aux_base,
  input logic [63:0] cmd_bias_base,
  input logic [31:0] cmd_bias_bytes,
  input logic [31:0] cmd_down_w_epoch,
  input logic [15:0] cmd_down_weight_key,
  input logic [1023:0] cmd_down_expected_aux_header,
  input logic [2:0][63:0] cmd_down_load_base,
  input logic [2:0][31:0] cmd_down_load_bytes,
  input logic [63:0] cmd_down_aux_base,
  input logic [63:0] cmd_down_bias_base,
  input logic [31:0] cmd_down_bias_bytes,
  input logic x_valid,
  output logic x_ready,
  input logic [31:0] x_bits,
  input logic gamma_valid,
  output logic gamma_ready,
  input logic [31:0] gamma_bits,
  output logic row_valid,
  input logic rd_valid,
  output logic rd_ready,
  input logic [9:0] rd_tile,
  output logic rsp_valid,
  input logic rsp_ready,
  output logic [9:0] rsp_tile,
  output logic [255:0] rsp_bits,
  input logic row_release_valid,
  output logic row_release_ready,
  output logic done_valid,
  input logic done_ready,
  output logic [3:0] done_status,
  output logic [3:0] done_phase,
  output logic result_mode,
  output logic [6:0] result_row,
  output logic [31:0] done_bad_element,
  output logic [31:0] mean_bits, variance_bits, inverse_bits,
  output logic [31:0] actual_w_reads, actual_w_returns,
  output logic [31:0] actual_stripes, actual_ps_commits,
  output logic [2:0][63:0] araddr,
  output logic [2:0][7:0] arlen,
  output logic [2:0][2:0] arsize,
  output logic [2:0][1:0] arburst,
  output logic [2:0] arvalid,
  input logic [2:0] arready,
  input logic [2:0][511:0] rdata,
  input logic [2:0][1:0] rresp,
  input logic [2:0] rlast, rvalid,
  output logic [2:0] rready,
  output logic [63:0] aux_araddr,
  output logic [7:0] aux_arlen,
  output logic [2:0] aux_arsize,
  output logic [1:0] aux_arburst,
  output logic aux_arvalid,
  input logic aux_arready,
  input logic [127:0] aux_rdata,
  input logic [1:0] aux_rresp,
  input logic aux_rlast, aux_rvalid,
  output logic aux_rready,
  input logic cmd_tensor_begin,
  input logic [31:0] cmd_tensor_epoch,
  input logic [2:0][31:0] cmd_dst_epoch,
  input logic [2:0][63:0] cmd_dst_base, cmd_dst_span,
  input logic cmd_source_hidden_bank,
  input logic cmd_rope_enable,
  input logic [63:0] cmd_rope_aux_base, cmd_rope_aux_span,
  input logic cmd_input_from_state0,
  input logic cmd_staged_ln,
  input logic cmd_stage_discard_norm,
  input logic [63:0] cmd_state0_base, cmd_state0_span,
  input logic [31:0] cmd_state0_epoch,
  output logic [63:0] state0_araddr,
  output logic [7:0] state0_arlen,
  output logic [2:0] state0_arsize,
  output logic [1:0] state0_arburst,
  output logic state0_arvalid,
  input logic state0_arready,
  input logic [511:0] state0_rdata,
  input logic [1:0] state0_rresp,
  input logic state0_rlast, state0_rvalid,
  output logic state0_rready,
  output logic [31:0] done_id,
  input logic tensor_release_valid,
  output logic tensor_release_ready,
  input logic tensor_release_discard,
  input logic [31:0] tensor_release_epoch,
  input logic [63:0] tensor_release_request, tensor_release_generation,
  output logic tensor_raw_valid,
  output logic tensor_rope_enable,
  output logic [127:0] row_final,
  output logic tensor_final_valid,
  output logic [2:0][31:0] tensor_final_dst_epoch,
  output logic [127:0] row_written,
  output logic [127:0] norm_written,
  output logic norm_stage_ready,
  output logic stage_store_fault,
  output logic tensor_failed,
  output logic [31:0] tensor_epoch,
  output logic [63:0] tensor_request, tensor_generation,
  output logic [3327:0] tensor_model_identity,
  output logic [671:0] tensor_numeric_identity,
  output logic [2:0][31:0] tensor_dst_epoch,
  output logic [2:0][63:0] tensor_dst_base, tensor_dst_span,
  output logic [2:0][63:0] m_axi_awaddr,
  output logic [2:0][7:0] m_axi_awlen,
  output logic [2:0][2:0] m_axi_awsize,
  output logic [2:0][1:0] m_axi_awburst,
  output logic [2:0] m_axi_awvalid,
  input logic [2:0] m_axi_awready,
  output logic [2:0][511:0] m_axi_wdata,
  output logic [2:0][63:0] m_axi_wstrb,
  output logic [2:0] m_axi_wlast, m_axi_wvalid,
  input logic [2:0] m_axi_wready,
  input logic [2:0][1:0] m_axi_bresp,
  input logic [2:0] m_axi_bvalid,
  output logic [2:0] m_axi_bready,
  output logic [2:0][31:0] scratch_aw_count, scratch_w_count,
  output logic [2:0][31:0] scratch_b_count,
  output logic [9:0] scratch_rsp_count,
  output logic [5:0] scratch_flush_count,
  output logic [1:0] scratch_error_dst,
  output logic [31:0] scratch_error_ordinal,
  output logic [1:0] scratch_error_bresp,
  output logic done_rope_check_valid,
  output logic [127:0] done_rope_check,
  output logic [3:0] done_rope_head,
  output logic done_rope_plane,
  output logic [7:0] done_op,
  output logic [15:0] done_check_status,
  output logic [31:0] done_detail,
  output logic [63:0] done_bad64,
  output logic [1:0][63:0] rope_araddr,
  output logic [1:0][7:0] rope_arlen,
  output logic [1:0][2:0] rope_arsize,
  output logic [1:0][1:0] rope_arburst,
  output logic [1:0] rope_arvalid,
  input logic [1:0] rope_arready,
  input logic [1:0][511:0] rope_rdata,
  input logic [1:0][1:0] rope_rresp,
  input logic [1:0] rope_rlast, rope_rvalid,
  output logic [1:0] rope_rready
);
  localparam logic [63:0] QKV_BO_SPAN = 64'd12582912;
  localparam logic [63:0] HIDDEN_SPAN = 64'd8388608;
  typedef enum logic [5:0] {
    IDLE, F_WAIT, F_ROW, F_DONE, Q_WAIT, SEG_PREP, READ_REQ,
    READ_RSP, FLUSH_SEG, UNFLUSH_SEG, ERR_READ, ERR_FLUSH,
    ERR_UNFLUSH, RELEASE_ROW, Q_DONE, OUT_DONE,
    F_DRAIN, F_REJECT, F_REJECT_DONE,
    R_REARM, R_TABLE_RESET, R_TABLE_LOAD, R_TABLE_WAIT,
    R_HEAD_PREP, R_HEAD_LOAD, R_HEAD_WAIT, R_LEAF_START,
    R_LEAF_WAIT, R_WRITE, R_FLUSH, R_UNFLUSH, R_ERR,
    IN_BEGIN, IN_RAW_LOAD, IN_RAW_WAIT, IN_GAMMA_LOAD,
    IN_GAMMA_WAIT, IN_COMMIT, IN_CORE_CMD, IN_ERR
  } state_t;
  state_t state;
  logic tensor_active;
  logic [31:0] last_released_epoch;
  logic [39:0] tensor_task_fixed;
  logic [6:0] active_row;
  logic active_qkv_admitted;
  logic [3:0] out_status, out_phase;
  logic [31:0] out_bad;
  logic local_error;
  logic [5:0] segment;
  logic [7:0] segment_tile;
  logic [1:0] route;
  logic [63:0] segment_base, segment_span;
  logic read_pending;
  logic ffn_identity_error;
  logic [31:0] okay_b_count [0:2];
  logic active_rope;
  logic [63:0] tensor_rope_aux_base, tensor_rope_aux_span;
  logic [4:0] rope_head_index;
  logic rope_table_sin;
  logic [2:0] rope_tile_index;
  logic [1:0] rope_block_index;
  logic [4:0] rope_table_block_index;
  logic [7:0] rope_head_count;
  logic [7:0] rope_flush_count;
  logic [7:0] rope_b_ok_count;
  logic rope_error;
  logic [3:0] rope_error_status;
  logic scratch_load_active, table_load_active;
  logic rope_aux_owner;
  logic source_active, input_error, input_hold_valid;
  logic active_staged_ln, tensor_staged_ln, stage_gamma_init;
  logic active_stage_discard_norm;
  logic gamma_nonfinite;
  logic [7:0] out_op;
  logic [15:0] out_check_status;
  logic [31:0] out_detail;
  logic [63:0] out_bad64;
  logic raw_done_seen, gamma_done_seen, source_load_active;
  logic [511:0] input_hold;
  logic [10:0] raw_words, gamma_words;
  logic [63:0] source_base, source_span;
  logic [31:0] source_epoch;
  logic tensor_source_active;
  logic [63:0] tensor_source_base, tensor_source_span;
  logic [31:0] tensor_source_epoch;
  logic [31:0] held_cmd_id, held_cmd_w_epoch, held_cmd_down_w_epoch;
  logic [15:0] held_cmd_weight_key, held_cmd_down_weight_key;
  logic [6:0] held_cmd_row;
  logic held_cmd_cold, held_cmd_mode;
  logic [3327:0] held_cmd_model_identity;
  logic [671:0] held_cmd_numeric_identity;
  logic [95:0] held_cmd_task_context;
  logic [1023:0] held_cmd_expected_aux_header;
  logic [1023:0] held_cmd_down_expected_aux_header;
  logic [2:0][63:0] held_cmd_load_base, held_cmd_down_load_base;
  logic [2:0][31:0] held_cmd_load_bytes, held_cmd_down_load_bytes;
  logic [63:0] held_cmd_aux_base, held_cmd_bias_base;
  logic [63:0] held_cmd_down_aux_base, held_cmd_down_bias_base;
  logic [31:0] held_cmd_bias_bytes, held_cmd_down_bias_bytes;
  logic core_prep_begin_ready, core_prep_write_ready;
  logic core_prep_commit_ready, core_prep_abort_ready;
  logic core_prep_abort_valid;
  logic core_prep_token_valid, core_prep_fault;
  logic core_gamma_token_valid;
  logic [2:0] core_result_exec;
  logic [7:0] core_done_op;
  logic [15:0] core_done_check_status;
  logic [31:0] core_done_detail;
  logic [63:0] core_done_bad64;
  wire [64:0] source_row_address =
      {1'b0,source_base} + ({58'd0,active_row} * 65'd4096);
  wire [64:0] source_cmd_limit =
      {1'b0,cmd_state0_base} + {1'b0,cmd_state0_span};
  wire [64:0] source_cmd_row_address =
      {1'b0,cmd_state0_base} + ({58'd0,cmd_row} * 65'd4096);
  wire [64:0] source_cmd_aux_limit =
      {1'b0,cmd_rope_aux_base} + {1'b0,cmd_rope_aux_span};
  wire [64:0] source_cmd_gamma_address =
      {1'b0,cmd_rope_aux_base} + 65'd128;
  wire source_descriptor_ok = !cmd_input_from_state0 ||
      (cmd_mode && !cmd_source_hidden_bank &&
       cmd_state0_epoch == cmd_tensor_epoch &&
       cmd_state0_base[5:0] == 0 &&
       cmd_state0_span >= 64'd8388608 && !source_cmd_limit[64] &&
       !source_cmd_row_address[64] &&
       ({58'd0,cmd_row} * 65'd4096) + 65'd4096 <=
         {1'b0,cmd_state0_span} &&
       cmd_rope_aux_base[3:0] == 0 &&
       cmd_rope_aux_span >= 64'd1142528 &&
       !source_cmd_aux_limit[64] && !source_cmd_gamma_address[64] &&
       65'd4224 <= {1'b0,cmd_rope_aux_span});

  logic core_cmd_valid, core_cmd_ready, core_row_valid;
  logic core_rd_valid, core_rd_ready, core_rsp_valid, core_rsp_ready;
  logic [9:0] core_rd_tile, core_rsp_tile;
  logic [255:0] core_rsp_bits;
  logic core_release_valid, core_release_ready;
  logic core_done_valid, core_done_ready;
  logic [3:0] core_done_status, core_done_phase;
  logic [31:0] core_done_bad;
  logic core_result_mode;
  logic [6:0] core_result_row;
  logic [63:0] core_aux_araddr;
  logic [7:0] core_aux_arlen;
  logic [2:0] core_aux_arsize;
  logic [1:0] core_aux_arburst;
  logic core_aux_arvalid, core_aux_arready;
  logic [127:0] core_aux_rdata;
  logic [1:0] core_aux_rresp;
  logic core_aux_rlast, core_aux_rvalid, core_aux_rready;
  wire core_identity_bad = core_result_mode != result_mode ||
                           core_result_row != result_row ||
                           core_result_exec !=
                             (active_staged_ln ? 3'd1 : 3'd0);

  logic writer_rearm_valid, writer_rearm_ready;
  logic writer_tile_valid, writer_tile_ready, writer_flush_req;
  logic writer_flush_done, writer_debt_zero, writer_fault;
  logic [31:0] writer_aw_count, writer_w_count, writer_b_count;
  logic [63:0] writer_useful_bytes, writer_physical_bytes;
  logic [63:0] writer_awaddr;
  logic [7:0] writer_awlen;
  logic [2:0] writer_awsize;
  logic [1:0] writer_awburst;
  logic writer_awvalid, writer_awready;
  logic [511:0] writer_wdata;
  logic [63:0] writer_wstrb;
  logic writer_wlast, writer_wvalid, writer_wready;
  logic [1:0] writer_bresp;
  logic writer_bvalid, writer_bready;
  logic scratch_reader_load_valid, scratch_reader_load_ready;
  logic scratch_reader_done, scratch_reader_error;
  logic [31:0] scratch_reader_bytes, scratch_reader_offset;
  logic [31:0] scratch_reader_epoch;
  logic [6:0] scratch_reader_out_bytes;
  logic scratch_reader_last, scratch_reader_out_valid, scratch_reader_out_ready;
  logic [511:0] scratch_reader_out_data;
  logic [63:0] scratch_reader_araddr;
  logic [7:0] scratch_reader_arlen;
  logic [2:0] scratch_reader_arsize;
  logic [1:0] scratch_reader_arburst;
  logic scratch_reader_arvalid, scratch_reader_arready;
  logic [511:0] scratch_reader_rdata;
  logic [1:0] scratch_reader_rresp;
  logic scratch_reader_rlast, scratch_reader_rvalid, scratch_reader_rready;
  logic table_reader_load_valid, table_reader_load_ready;
  logic table_reader_done, table_reader_error;
  logic [31:0] table_reader_bytes, table_reader_offset;
  logic [31:0] table_reader_epoch;
  logic [4:0] table_reader_out_bytes;
  logic table_reader_last, table_reader_out_valid, table_reader_out_ready;
  assign core_prep_abort_valid = (state == IN_ERR &&
      !source_load_active && !table_load_active &&
      !scratch_reader_out_valid && !table_reader_out_valid &&
      !input_hold_valid) ||
      (state == IDLE && tensor_staged_ln && tensor_release_valid &&
       tensor_release_ready);
  logic [127:0] table_reader_out_data;
  logic [63:0] table_reader_araddr;
  logic [7:0] table_reader_arlen;
  logic [2:0] table_reader_arsize;
  logic [1:0] table_reader_arburst;
  logic table_reader_arvalid, table_reader_arready;
  logic table_reader_rready;
  logic rope_start_ready, rope_result_valid, rope_result_ready;
  logic [127:0] rope_result_check;
  logic rope_result_protocol_error, rope_leaf_active, rope_leaf_done;
  logic [255:0] rope_y_tile;
  logic [63:0] rope_x_coverage, rope_cos_coverage;
  logic [63:0] rope_sin_coverage, rope_y_coverage;
  wire [63:0] rope_offset =
      ({59'd0,rope_head_index[0]} * 64'd16 +
       {60'd0,rope_head_index[4:2]}) * 64'd262144 +
      {57'd0,active_row} * 64'd256;
  wire [1:0] rope_route = {1'b0,rope_head_index[1]};
  wire [64:0] rope_base_sum =
      {1'b0,tensor_dst_base[rope_route]} + {1'b0,rope_offset};
  wire [64:0] table_base_sum = {1'b0,tensor_rope_aux_base} +
      (rope_table_sin ? 65'd880128 : 65'd617728) +
      ({58'd0,active_row} * 65'd256);
  wire rope_head_address_ok = !rope_base_sum[64] &&
      rope_offset <= tensor_dst_span[rope_route] &&
      64'd256 <= tensor_dst_span[rope_route] - rope_offset;
  wire rope_table_address_ok = !table_base_sum[64] &&
      (rope_table_sin ? 64'd880128 : 64'd617728) +
      {57'd0,active_row} * 64'd256 + 64'd256 <= tensor_rope_aux_span;

  function automatic logic [63:0] offset_for_segment(
      input logic [5:0] seg, input logic [6:0] row);
    logic [63:0] pair_index;
    begin
      if (seg == 6'd48) return {57'd0,row} * 64'd4096;
      pair_index = ({62'd0,seg[5:4]} * 64'd16) +
                   {61'd0,seg[3:1]};
      return pair_index * 64'd262144 + {57'd0,row} * 64'd256;
    end
  endfunction

  wire [1:0] next_route = segment == 6'd48 ? 2'd2 :
                          (segment[0] ? 2'd1 : 2'd0);
  wire [63:0] next_offset = offset_for_segment(segment,active_row);
  wire [63:0] next_span = segment == 6'd48 ? 64'd4096 : 64'd256;
  wire [64:0] next_base_sum = {1'b0,tensor_dst_base[next_route]} +
                               {1'b0,next_offset};
  wire next_segment_ok = next_offset <= tensor_dst_span[next_route] &&
      next_span <= tensor_dst_span[next_route] - next_offset &&
      !next_base_sum[64] && next_base_sum[5:0] == 0;
  wire [9:0] expected_tile = segment == 6'd48 ?
      10'd384 + {2'd0,segment_tile} :
      {segment,3'b000} + {2'd0,segment_tile};
  // LN_NORM_VIEW exposes local tile 0..127 and maps it to bank 384..511.
  wire [9:0] expected_core_tile = active_staged_ln ?
      {2'd0,segment_tile} : expected_tile;
  wire last_tile_in_segment = segment == 6'd48 ?
      segment_tile == 8'd127 : segment_tile == 8'd7;
  wire [11:0] writer_n0 = segment == 6'd48 ?
      {1'b0,segment_tile,3'b000} : {6'd0,segment_tile[2:0],3'b000};
  wire writer_b_fire = writer_bready && writer_bvalid;

  function automatic logic descriptor_ok(
      input logic [63:0] base, span, required_span);
    logic [64:0] limit;
    begin
      limit = {1'b0,base} + {1'b0,span};
      return base[5:0] == 0 && span >= required_span && !limit[64];
    end
  endfunction

  wire common_identity_ok = cmd_id != 0 &&
      cmd_numeric_identity[63:0] != 0 &&
      cmd_numeric_identity[127:64] != 0 &&
      cmd_numeric_identity[143:128] == 16'd1 &&
      cmd_numeric_identity[159:144] == 16'd128 &&
      cmd_task_context[95:88] == 8'd1 &&
      cmd_task_context[87:72] == {9'd0,cmd_row} &&
      cmd_task_context[71:64] == 8'd128 &&
      cmd_task_context[63:32] == 32'h01000001 &&
      cmd_task_context[31:0] != 0 && !cmd_source_hidden_bank;
  wire descriptor_set_ok =
      descriptor_ok(cmd_dst_base[0],cmd_dst_span[0],QKV_BO_SPAN) &&
      descriptor_ok(cmd_dst_base[1],cmd_dst_span[1],QKV_BO_SPAN) &&
      descriptor_ok(cmd_dst_base[2],cmd_dst_span[2],HIDDEN_SPAN) &&
      cmd_tensor_epoch != 0 &&
      cmd_dst_epoch[0] == cmd_tensor_epoch &&
      cmd_dst_epoch[1] == cmd_tensor_epoch &&
      cmd_dst_epoch[2] == cmd_tensor_epoch;
  wire rope_descriptor_ok = !cmd_rope_enable ||
      (cmd_tensor_epoch <= 32'hffff_fffe &&
       cmd_rope_aux_base[3:0] == 0 &&
       cmd_rope_aux_span >= 64'd1142528 &&
       ({1'b0,cmd_rope_aux_base} + {1'b0,cmd_rope_aux_span}) <=
         65'h0ffff_ffff_ffff_ffff);
  wire begin_ok = !tensor_active && last_released_epoch != 32'hffffffff &&
      cmd_tensor_epoch == last_released_epoch + 1'b1;
  wire continue_ok = tensor_active &&
      (!tensor_failed ||
       (cmd_staged_ln && cmd_stage_discard_norm && stage_store_fault)) &&
      !tensor_raw_valid && !row_written[cmd_row] &&
      cmd_staged_ln == tensor_staged_ln &&
      (!cmd_staged_ln || !norm_written[cmd_row]) &&
      cmd_tensor_epoch == tensor_epoch &&
      cmd_model_identity == tensor_model_identity &&
      cmd_numeric_identity == tensor_numeric_identity &&
      cmd_task_context[71:32] == tensor_task_fixed &&
      cmd_dst_epoch == tensor_dst_epoch &&
      cmd_dst_base == tensor_dst_base &&
      cmd_dst_span == tensor_dst_span &&
      cmd_rope_enable == tensor_rope_enable &&
      cmd_input_from_state0 == tensor_source_active &&
      (!cmd_input_from_state0 ||
       (cmd_state0_base == tensor_source_base &&
        cmd_state0_span == tensor_source_span &&
        cmd_state0_epoch == tensor_source_epoch)) &&
      (!(cmd_rope_enable || cmd_input_from_state0) ||
       (cmd_rope_aux_base == tensor_rope_aux_base &&
        cmd_rope_aux_span == tensor_rope_aux_span));
  wire qkv_admission_ok = common_identity_ok && descriptor_set_ok &&
      rope_descriptor_ok && source_descriptor_ok &&
      (!cmd_staged_ln || (cmd_input_from_state0 && cmd_mode)) &&
      (!cmd_stage_discard_norm ||
       (cmd_staged_ln && !cmd_tensor_begin && stage_store_fault)) &&
      (cmd_tensor_begin ? begin_ok : continue_ok);

  assign tensor_release_ready = state == IDLE && tensor_active &&
      writer_debt_zero && !read_pending &&
      (!tensor_staged_ln ||
       (core_cmd_ready &&
        (core_prep_abort_ready ||
         (!core_prep_token_valid && !core_gamma_token_valid &&
          !core_prep_fault)))) &&
      tensor_release_epoch ==
        ((tensor_rope_enable && !tensor_release_discard) ?
         tensor_epoch + 1'b1 : tensor_epoch) &&
      tensor_release_request == tensor_request &&
      tensor_release_generation == tensor_generation &&
      (tensor_release_discard ?
       !(tensor_rope_enable ? tensor_final_valid : tensor_raw_valid) :
       (tensor_rope_enable ? tensor_final_valid : tensor_raw_valid));
  assign cmd_ready = state == IDLE && !tensor_release_valid &&
      core_cmd_ready && (!cmd_mode || !qkv_admission_ok ||
                         writer_rearm_ready);
  assign core_cmd_valid =
      (state == IDLE && cmd_valid && cmd_ready &&
       !cmd_input_from_state0 && (!cmd_mode || qkv_admission_ok)) ||
      state == IN_CORE_CMD;
  assign writer_rearm_valid = (state == IDLE && cmd_valid && cmd_ready &&
                               cmd_mode && qkv_admission_ok) ||
                              state == R_REARM;

  assign row_valid = state == F_ROW && core_row_valid &&
                     !core_identity_bad && !core_done_valid;
  assign rd_ready = state == F_ROW && !core_identity_bad && core_rd_ready;
  assign rsp_valid = state == F_ROW && !core_identity_bad && core_rsp_valid;
  assign rsp_tile = state == F_ROW ? core_rsp_tile : '0;
  assign rsp_bits = state == F_ROW ? core_rsp_bits : '0;
  assign row_release_ready = state == F_ROW && !core_identity_bad &&
                             core_release_ready;
  assign done_valid = state == OUT_DONE ||
                      (state == F_DONE && core_done_valid);
  assign done_status = state == F_DONE ? core_done_status : out_status;
  assign done_phase = state == F_DONE ? core_done_phase : out_phase;
  assign done_bad_element = state == F_DONE ? core_done_bad : out_bad;
  assign done_op = state == F_DONE ? core_done_op : out_op;
  assign done_check_status = state == F_DONE ? core_done_check_status :
      out_check_status;
  assign done_detail = state == F_DONE ? core_done_detail : out_detail;
  assign done_bad64 = state == F_DONE ? core_done_bad64 : out_bad64;

  assign core_rd_valid = (state == F_ROW && !core_identity_bad && rd_valid) ||
                         (state == READ_REQ && !writer_fault &&
                          !local_error && !core_identity_bad);
  assign core_rd_tile = state == F_ROW ? rd_tile : expected_core_tile;
  assign core_rsp_ready = (state == F_ROW &&
                           (core_identity_bad || rsp_ready)) ||
      state == F_DRAIN ||
      (state == READ_RSP && (local_error || writer_fault ||
          core_identity_bad ||
          core_rsp_tile != expected_core_tile || writer_tile_ready)) ||
      state == ERR_READ || state == ERR_FLUSH;
  assign core_release_valid = (state == F_ROW && !core_identity_bad &&
                               row_release_valid) || state == F_REJECT ||
                              state == RELEASE_ROW;
  assign core_done_ready = (state == F_DONE && done_ready) ||
                           state == F_REJECT_DONE || state == Q_DONE ||
                           (state == Q_WAIT && core_done_valid &&
                            !core_row_valid);

  assign rope_aux_owner = state == R_REARM || state == R_TABLE_RESET ||
      state == R_TABLE_LOAD || state == R_TABLE_WAIT ||
      state == R_HEAD_PREP || state == R_HEAD_LOAD ||
      state == R_HEAD_WAIT || state == R_LEAF_START ||
      state == R_LEAF_WAIT || state == R_WRITE ||
      state == R_FLUSH || state == R_UNFLUSH || state == R_ERR ||
      state == IN_GAMMA_LOAD || state == IN_GAMMA_WAIT ||
      (state == IN_ERR && table_load_active);
  assign aux_araddr = rope_aux_owner ? table_reader_araddr : core_aux_araddr;
  assign aux_arlen = rope_aux_owner ? table_reader_arlen : core_aux_arlen;
  assign aux_arsize = rope_aux_owner ? table_reader_arsize : core_aux_arsize;
  assign aux_arburst = rope_aux_owner ? table_reader_arburst : core_aux_arburst;
  assign aux_arvalid = rope_aux_owner ? table_reader_arvalid : core_aux_arvalid;
  assign core_aux_arready = rope_aux_owner ? 1'b0 : aux_arready;
  assign core_aux_rdata = aux_rdata;
  assign core_aux_rresp = aux_rresp;
  assign core_aux_rlast = aux_rlast;
  assign core_aux_rvalid = rope_aux_owner ? 1'b0 : aux_rvalid;
  assign aux_rready = rope_aux_owner ? table_reader_rready : core_aux_rready;
  assign table_reader_arready = rope_aux_owner && aux_arready;

  assign scratch_reader_arready = source_load_active ?
      state0_arready : rope_arready[rope_route];
  assign scratch_reader_rdata = source_load_active ?
      state0_rdata : rope_rdata[rope_route];
  assign scratch_reader_rresp = source_load_active ?
      state0_rresp : rope_rresp[rope_route];
  assign scratch_reader_rlast = source_load_active ?
      state0_rlast : rope_rlast[rope_route];
  assign scratch_reader_rvalid = source_load_active ?
      state0_rvalid : rope_rvalid[rope_route];
  assign state0_araddr = source_load_active ? scratch_reader_araddr : '0;
  assign state0_arlen = source_load_active ? scratch_reader_arlen : '0;
  assign state0_arsize = source_load_active ? scratch_reader_arsize : '0;
  assign state0_arburst = source_load_active ? scratch_reader_arburst : '0;
  assign state0_arvalid = source_load_active && scratch_reader_arvalid;
  assign state0_rready = source_load_active && scratch_reader_rready;
  always_comb begin
    rope_araddr = '0; rope_arlen = '0; rope_arsize = '0;
    rope_arburst = '0; rope_arvalid = '0; rope_rready = '0;
    if (!source_load_active) begin
      rope_araddr[rope_route] = scratch_reader_araddr;
      rope_arlen[rope_route] = scratch_reader_arlen;
      rope_arsize[rope_route] = scratch_reader_arsize;
      rope_arburst[rope_route] = scratch_reader_arburst;
      rope_arvalid[rope_route] = scratch_reader_arvalid;
      rope_rready[rope_route] = scratch_reader_rready;
    end
  end

  laya_lnq_wi_gqdown_row_v1 core (
    .*, .cmd_valid(core_cmd_valid), .cmd_ready(core_cmd_ready),
    .cmd_id(source_active ? held_cmd_id : cmd_id),
    .cmd_cold(source_active ? held_cmd_cold : cmd_cold),
    .cmd_mode(source_active ? held_cmd_mode : cmd_mode),
    .cmd_row(source_active ? held_cmd_row : cmd_row),
    .cmd_w_epoch(source_active ? held_cmd_w_epoch : cmd_w_epoch),
    .cmd_weight_key(source_active ? held_cmd_weight_key : cmd_weight_key),
    .cmd_model_identity(source_active ? held_cmd_model_identity : cmd_model_identity),
    .cmd_numeric_identity(source_active ? held_cmd_numeric_identity : cmd_numeric_identity),
    .cmd_task_context(source_active ? held_cmd_task_context : cmd_task_context),
    .cmd_expected_aux_header(source_active ? held_cmd_expected_aux_header : cmd_expected_aux_header),
    .cmd_load_base(source_active ? held_cmd_load_base : cmd_load_base),
    .cmd_load_bytes(source_active ? held_cmd_load_bytes : cmd_load_bytes),
    .cmd_aux_base(source_active ? held_cmd_aux_base : cmd_aux_base),
    .cmd_bias_base(source_active ? held_cmd_bias_base : cmd_bias_base),
    .cmd_bias_bytes(source_active ? held_cmd_bias_bytes : cmd_bias_bytes),
    .cmd_down_w_epoch(source_active ? held_cmd_down_w_epoch : cmd_down_w_epoch),
    .cmd_down_weight_key(source_active ? held_cmd_down_weight_key : cmd_down_weight_key),
    .cmd_down_expected_aux_header(source_active ? held_cmd_down_expected_aux_header : cmd_down_expected_aux_header),
    .cmd_down_load_base(source_active ? held_cmd_down_load_base : cmd_down_load_base),
    .cmd_down_load_bytes(source_active ? held_cmd_down_load_bytes : cmd_down_load_bytes),
    .cmd_down_aux_base(source_active ? held_cmd_down_aux_base : cmd_down_aux_base),
    .cmd_down_bias_base(source_active ? held_cmd_down_bias_base : cmd_down_bias_base),
    .cmd_down_bias_bytes(source_active ? held_cmd_down_bias_bytes : cmd_down_bias_bytes),
    .cmd_prepared_source(source_active),
    .cmd_source_epoch(source_epoch),
    .cmd_exec(active_staged_ln ? 3'd1 : 3'd0),
    .cmd_gamma_aux_base(tensor_rope_aux_base),
    .cmd_gamma_aux_span(tensor_rope_aux_span),
    .prep_begin_valid(state == IN_BEGIN),
    .prep_begin_ready(core_prep_begin_ready),
    .prep_kind(active_staged_ln ?
               (stage_gamma_init ? 2'b11 : 2'b01) : 2'b00),
    .prep_id(held_cmd_id),.prep_row(held_cmd_row),
    .prep_epoch(source_epoch),
    .prep_model_identity(held_cmd_model_identity),
    .prep_numeric_identity(held_cmd_numeric_identity),
    .prep_gamma_aux_base(tensor_rope_aux_base),
    .prep_gamma_aux_span(tensor_rope_aux_span),
    .prep_write_valid(input_hold_valid && !input_error &&
        (state == IN_RAW_WAIT || state == IN_GAMMA_WAIT)),
    .prep_write_ready(core_prep_write_ready),
    .prep_write_index(state == IN_RAW_WAIT ? raw_words :
                      (active_staged_ln ? gamma_words :
                         11'd1024 + gamma_words)),
    .prep_write_bits(input_hold[31:0]),
    .prep_commit_valid(state == IN_COMMIT),
    .prep_commit_ready(core_prep_commit_ready),
    .prep_abort_valid(core_prep_abort_valid),
    .prep_abort_ready(core_prep_abort_ready),
    .prep_token_valid(core_prep_token_valid),
    .gamma_token_valid(core_gamma_token_valid),
    .prep_fault(core_prep_fault),
    .a_window_ready(),.a_window_release_valid(1'b0),
    .a_window_discard(1'b0),.a_window_release_ready(),
    .row_valid(core_row_valid), .rd_valid(core_rd_valid),
    .rd_ready(core_rd_ready), .rd_tile(core_rd_tile),
    .rsp_valid(core_rsp_valid), .rsp_ready(core_rsp_ready),
    .rsp_tile(core_rsp_tile), .rsp_bits(core_rsp_bits),
    .row_release_valid(core_release_valid),
    .row_release_discard(active_staged_ln &&
                         (active_stage_discard_norm || local_error ||
                          writer_fault)),
    .row_release_ready(core_release_ready),
    .done_valid(core_done_valid), .done_ready(core_done_ready),
    .done_status(core_done_status), .done_phase(core_done_phase),
    .done_op(core_done_op),
    .done_check_status(core_done_check_status),
    .done_detail(core_done_detail),.done_bad64(core_done_bad64),
    .done_bad_element(core_done_bad),
    .result_exec(core_result_exec),
    .result_mode(core_result_mode), .result_row(core_result_row),
    .aux_araddr(core_aux_araddr),.aux_arlen(core_aux_arlen),
    .aux_arsize(core_aux_arsize),.aux_arburst(core_aux_arburst),
    .aux_arvalid(core_aux_arvalid),.aux_arready(core_aux_arready),
    .aux_rdata(core_aux_rdata),.aux_rresp(core_aux_rresp),
    .aux_rlast(core_aux_rlast),.aux_rvalid(core_aux_rvalid),
    .aux_rready(core_aux_rready)
  );

  assign scratch_reader_load_valid =
      (state == R_HEAD_LOAD && rope_head_address_ok) ||
      (state == IN_RAW_LOAD && !input_error);
  assign scratch_reader_out_ready = state == R_HEAD_WAIT || state == R_ERR ||
      state == IN_ERR ||
      (state == IN_RAW_WAIT && !input_hold_valid && !input_error);
  t4_w_reader_port_v1 #(.SCALE_MODE(1'b0)) rope_scratch_reader (
    .clk,.rst_n,.cancel(rope_error || input_error),
    .load_valid(scratch_reader_load_valid),
    .load_ready(scratch_reader_load_ready),
    .load_base(state == IN_RAW_LOAD ? source_row_address[63:0] :
               rope_base_sum[63:0]),
    .load_bytes(state == IN_RAW_LOAD ? 32'd4096 : 32'd256),
    .load_epoch(state == IN_RAW_LOAD ? source_epoch : tensor_epoch),
    .load_done(scratch_reader_done),
    .load_error(scratch_reader_error),
    .committed_bytes(scratch_reader_bytes),
    .araddr(scratch_reader_araddr),.arlen(scratch_reader_arlen),
    .arsize(scratch_reader_arsize),.arburst(scratch_reader_arburst),
    .arvalid(scratch_reader_arvalid),.arready(scratch_reader_arready),
    .rdata(scratch_reader_rdata),.rresp(scratch_reader_rresp),
    .rlast(scratch_reader_rlast),.rvalid(scratch_reader_rvalid),
    .rready(scratch_reader_rready),
    .out_data(scratch_reader_out_data),
    .out_offset(scratch_reader_offset),
    .out_epoch(scratch_reader_epoch),
    .out_bytes(scratch_reader_out_bytes),
    .out_last(scratch_reader_last),
    .out_valid(scratch_reader_out_valid),
    .out_ready(scratch_reader_out_ready)
  );

  assign table_reader_load_valid =
      (state == R_TABLE_LOAD && rope_table_address_ok) ||
      (state == IN_GAMMA_LOAD && !input_error);
  assign table_reader_out_ready = state == R_TABLE_WAIT || state == R_ERR ||
      state == IN_ERR ||
      (state == IN_GAMMA_WAIT && !input_hold_valid && !input_error);
  t4_aux_bias_reader_v1 rope_table_reader (
    .clk,.rst_n,.cancel(rope_error || input_error),
    .load_valid(table_reader_load_valid),
    .load_ready(table_reader_load_ready),
    .load_base(state == IN_GAMMA_LOAD ?
               tensor_rope_aux_base + 64'd128 : table_base_sum[63:0]),
    .load_bytes(state == IN_GAMMA_LOAD ? 32'd4096 : 32'd256),
    .load_epoch(tensor_epoch),.load_done(table_reader_done),
    .load_error(table_reader_error),
    .committed_bytes(table_reader_bytes),
    .araddr(table_reader_araddr),.arlen(table_reader_arlen),
    .arsize(table_reader_arsize),.arburst(table_reader_arburst),
    .arvalid(table_reader_arvalid),.arready(table_reader_arready),
    .rdata(aux_rdata),.rresp(aux_rresp),
    .rlast(aux_rlast),.rvalid(rope_aux_owner && aux_rvalid),
    .rready(table_reader_rready),
    .out_data(table_reader_out_data),
    .out_offset(table_reader_offset),
    .out_epoch(table_reader_epoch),
    .out_bytes(table_reader_out_bytes),
    .out_last(table_reader_last),
    .out_valid(table_reader_out_valid),
    .out_ready(table_reader_out_ready)
  );

  assign rope_result_ready = state == R_LEAF_WAIT;
  laya_rope_head_adapter_v1 rope_adapter (
    .clk,.rst_n,.table_reset(state == R_TABLE_RESET),
    .head_prepare(state == R_HEAD_PREP),
    .x_block_valid(state == R_HEAD_WAIT &&
                   scratch_reader_out_valid && scratch_reader_out_ready &&
                   !rope_error && scratch_reader_offset ==
                     {24'd0,rope_block_index,6'b000000} &&
                   scratch_reader_epoch == tensor_epoch &&
                   scratch_reader_out_bytes == 7'd64),
    .x_block(rope_block_index),.x_block_data(scratch_reader_out_data),
    .cos_block_valid(state == R_TABLE_WAIT && !rope_table_sin &&
                     table_reader_out_valid && table_reader_out_ready &&
                     !rope_error && table_reader_offset ==
                       {23'd0,rope_table_block_index,4'b0000} &&
                     table_reader_epoch == tensor_epoch &&
                     table_reader_out_bytes == 5'd16),
    .sin_block_valid(state == R_TABLE_WAIT && rope_table_sin &&
                     table_reader_out_valid && table_reader_out_ready &&
                     !rope_error && table_reader_offset ==
                       {23'd0,rope_table_block_index,4'b0000} &&
                     table_reader_epoch == tensor_epoch &&
                     table_reader_out_bytes == 5'd16),
    .table_block(rope_table_block_index[3:0]),
    .table_block_data(table_reader_out_data),
    .start_valid(state == R_LEAF_START),.start_ready(rope_start_ready),
    .result_valid(rope_result_valid),.result_ready(rope_result_ready),
    .result_check(rope_result_check),
    .result_protocol_error(rope_result_protocol_error),
    .y_tile_index(rope_tile_index),.y_tile(rope_y_tile),
    .x_coverage(rope_x_coverage),.cos_coverage(rope_cos_coverage),
    .sin_coverage(rope_sin_coverage),.y_coverage(rope_y_coverage),
    .leaf_active(rope_leaf_active),.leaf_ap_done(rope_leaf_done)
  );

  assign writer_tile_valid = (state == READ_RSP && core_rsp_valid &&
      core_rsp_tile == expected_core_tile && !local_error && !writer_fault &&
      !core_identity_bad) || (state == R_WRITE && !rope_error &&
                             !writer_fault);
  assign writer_flush_req = state == FLUSH_SEG || state == ERR_FLUSH ||
                            state == R_FLUSH || state == R_ERR;
  tm1tn8_axi512_writer #(.SHARD(1'b0)) writer (
    .clk,.rst_n,.tile_valid(writer_tile_valid),.tile_ready(writer_tile_ready),
    .tile_f32(state == R_WRITE ? rope_y_tile : core_rsp_bits),
    .tile_n0(state == R_WRITE ? {6'd0,rope_tile_index,3'b000} : writer_n0),
    .tile_row_local(2'd0),.tile_row0(10'd0),.tile_batch(1'b0),
    .tile_lanes(4'd8),.mode_qkv(1'b0),
    .rearm_valid(writer_rearm_valid),.rearm_ready(writer_rearm_ready),
    .flush_req(writer_flush_req),.flush_done(writer_flush_done),
    .debt_zero(writer_debt_zero),.output_base(segment_base),
    .output_span(segment_span),.fault(writer_fault),
    .aw_count(writer_aw_count),.w_count(writer_w_count),
    .b_count(writer_b_count),.useful_bytes(writer_useful_bytes),
    .physical_bytes(writer_physical_bytes),
    .m_axi_awaddr(writer_awaddr),.m_axi_awlen(writer_awlen),
    .m_axi_awsize(writer_awsize),.m_axi_awburst(writer_awburst),
    .m_axi_awvalid(writer_awvalid),.m_axi_awready(writer_awready),
    .m_axi_wdata(writer_wdata),.m_axi_wstrb(writer_wstrb),
    .m_axi_wlast(writer_wlast),.m_axi_wvalid(writer_wvalid),
    .m_axi_wready(writer_wready),.m_axi_bresp(writer_bresp),
    .m_axi_bvalid(writer_bvalid),.m_axi_bready(writer_bready)
  );

  always_comb begin
    m_axi_awaddr = '0; m_axi_awlen = '0;
    m_axi_awsize = '0; m_axi_awburst = '0; m_axi_awvalid = '0;
    m_axi_wdata = '0; m_axi_wstrb = '0;
    m_axi_wlast = '0; m_axi_wvalid = '0; m_axi_bready = '0;
    writer_awready = m_axi_awready[route];
    writer_wready = m_axi_wready[route];
    writer_bvalid = m_axi_bvalid[route];
    writer_bresp = m_axi_bresp[route];
    m_axi_awaddr[route] = writer_awaddr;
    m_axi_awlen[route] = writer_awlen;
    m_axi_awsize[route] = writer_awsize;
    m_axi_awburst[route] = writer_awburst;
    m_axi_awvalid[route] = writer_awvalid;
    m_axi_wdata[route] = writer_wdata;
    m_axi_wstrb[route] = writer_wstrb;
    m_axi_wlast[route] = writer_wlast;
    m_axi_wvalid[route] = writer_wvalid;
    m_axi_bready[route] = writer_bready;
  end

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      state <= IDLE;
      tensor_active <= 0; tensor_raw_valid <= 0;
      tensor_final_valid <= 0; tensor_rope_enable <= 0;
      tensor_failed <= 0; row_written <= '0; row_final <= '0;
      tensor_epoch <= 0; last_released_epoch <= 0;
      tensor_request <= 0; tensor_generation <= 0;
      tensor_model_identity <= 0; tensor_numeric_identity <= 0;
      tensor_task_fixed <= 0;
      tensor_dst_epoch <= '0; tensor_dst_base <= '0;
      tensor_dst_span <= '0;
      tensor_final_dst_epoch <= '0;
      tensor_rope_aux_base <= 0; tensor_rope_aux_span <= 0;
      done_id <= 0; result_mode <= 0; result_row <= 0;
      done_rope_check_valid <= 0; done_rope_check <= 0;
      done_rope_head <= 0; done_rope_plane <= 0;
      active_rope <= 0; rope_head_index <= 0;
      rope_table_sin <= 0; rope_tile_index <= 0;
      rope_block_index <= 0; rope_table_block_index <= 0;
      rope_head_count <= 0; rope_flush_count <= 0;
      rope_b_ok_count <= 0; rope_error <= 0;
      rope_error_status <= 0;
      scratch_load_active <= 0; table_load_active <= 0;
      active_row <= 0; active_qkv_admitted <= 0;
      out_status <= 0; out_phase <= 4'd7;
      out_bad <= 32'hffffffff; local_error <= 0;
      segment <= 0; segment_tile <= 0; route <= 0;
      segment_base <= 0; segment_span <= 0;
      read_pending <= 0; ffn_identity_error <= 0;
      scratch_rsp_count <= 0;
      scratch_flush_count <= 0;
      scratch_aw_count <= '0; scratch_w_count <= '0;
      scratch_b_count <= '0;
      okay_b_count[0] <= 0; okay_b_count[1] <= 0;
      okay_b_count[2] <= 0;
      scratch_error_dst <= 0; scratch_error_ordinal <= 0;
      scratch_error_bresp <= 0;
      source_active <= 0; input_error <= 0;
      active_staged_ln <= 0; tensor_staged_ln <= 0;
      active_stage_discard_norm <= 0; stage_store_fault <= 0;
      stage_gamma_init <= 0; gamma_nonfinite <= 0;
      norm_written <= '0; norm_stage_ready <= 0;
      out_op <= 0; out_check_status <= 0;
      out_detail <= 0; out_bad64 <= 64'hffff_ffff_ffff_ffff;
      input_hold_valid <= 0; input_hold <= 0;
      raw_done_seen <= 0; gamma_done_seen <= 0;
      source_load_active <= 0;
      raw_words <= 0; gamma_words <= 0;
      source_base <= 0; source_span <= 0; source_epoch <= 0;
      tensor_source_active <= 0; tensor_source_base <= 0;
      tensor_source_span <= 0; tensor_source_epoch <= 0;
    end else begin
      if (state == IN_RAW_WAIT && scratch_reader_out_valid &&
          scratch_reader_out_ready) begin
        if (scratch_reader_offset != {19'd0,raw_words,2'b00} ||
            scratch_reader_epoch != source_epoch ||
            scratch_reader_out_bytes != 7'd64 ||
            scratch_reader_last != (raw_words == 11'd1008))
          input_error <= 1;
        else begin
          input_hold <= scratch_reader_out_data;
          input_hold_valid <= 1;
        end
      end
      if (state == IN_GAMMA_WAIT && table_reader_out_valid &&
          table_reader_out_ready) begin
        if (active_staged_ln)
          for (int word = 0; word < 4; word++)
            if (table_reader_out_data[word*32+23+:8] == 8'hff)
              gamma_nonfinite <= 1;
        if (table_reader_offset != {19'd0,gamma_words,2'b00} ||
            table_reader_epoch != source_epoch ||
            table_reader_out_bytes != 5'd16 ||
            table_reader_last != (gamma_words == 11'd1020))
          input_error <= 1;
        else begin
          input_hold <= {384'd0,table_reader_out_data};
          input_hold_valid <= 1;
        end
      end
      if (input_hold_valid && !input_error &&
          (state == IN_RAW_WAIT || state == IN_GAMMA_WAIT)) begin
        if (core_prep_write_ready) begin
          input_hold <= {32'd0,input_hold[511:32]};
          if (state == IN_RAW_WAIT) begin
            raw_words <= raw_words + 1'b1;
            if (raw_words[3:0] == 4'd15) input_hold_valid <= 0;
          end else begin
            gamma_words <= gamma_words + 1'b1;
            if (gamma_words[1:0] == 2'd3) input_hold_valid <= 0;
          end
        end else input_error <= 1;
      end
      if (core_rd_valid && core_rd_ready &&
          (state == READ_REQ || state == F_ROW))
        read_pending <= 1;
      if (core_rsp_valid && core_rsp_ready)
        read_pending <= 0;
      if (writer_awvalid && writer_awready)
        scratch_aw_count[route] <= scratch_aw_count[route] + 1'b1;
      if (writer_wvalid && writer_wready)
        scratch_w_count[route] <= scratch_w_count[route] + 1'b1;
      if (writer_b_fire) begin
        scratch_b_count[route] <= scratch_b_count[route] + 1'b1;
        if (rope_aux_owner && writer_bresp == 0)
          rope_b_ok_count <= rope_b_ok_count + 1'b1;
        if (writer_bresp == 2'b00)
          okay_b_count[route] <= okay_b_count[route] + 1'b1;
        else if (!local_error) begin
          local_error <= 1;
          scratch_error_dst <= route;
          scratch_error_ordinal <= writer_b_count;
          scratch_error_bresp <= writer_bresp;
        end
      end
      case (state)
        IDLE: begin
          if (tensor_release_valid && tensor_release_ready) begin
            last_released_epoch <= tensor_epoch +
                {31'd0,tensor_rope_enable};
            tensor_active <= 0; tensor_raw_valid <= 0;
            tensor_final_valid <= 0;
            tensor_failed <= 0; row_written <= '0; row_final <= '0;
            norm_written <= '0; norm_stage_ready <= 0;
            tensor_staged_ln <= 0;
            stage_store_fault <= 0;
            tensor_epoch <= 0;
          end else if (cmd_valid && cmd_ready) begin
            done_id <= cmd_id; result_mode <= cmd_mode;
            result_row <= cmd_row;
            active_row <= cmd_row;
            active_staged_ln <= cmd_staged_ln;
            active_stage_discard_norm <= cmd_stage_discard_norm;
            active_qkv_admitted <= cmd_mode && qkv_admission_ok;
            active_rope <= cmd_mode && cmd_rope_enable && qkv_admission_ok;
            ffn_identity_error <= 0;
            out_status <= 0; out_phase <= 4'd7;
            out_bad <= 32'hffffffff; local_error <= 0;
            out_op <= cmd_staged_ln ? 8'h10 : 8'h00;
            out_check_status <= 0; out_detail <= 0;
            out_bad64 <= 64'hffff_ffff_ffff_ffff;
            done_rope_check_valid <= 0;
            done_rope_check <= 0;
            done_rope_head <= 0; done_rope_plane <= 0;
            rope_error <= 0; rope_error_status <= 0;
            source_active <= cmd_input_from_state0 && cmd_mode &&
                             qkv_admission_ok;
            source_base <= cmd_state0_base;
            source_span <= cmd_state0_span;
            source_epoch <= cmd_state0_epoch;
            input_error <= 0; input_hold_valid <= 0;
            gamma_nonfinite <= 0;
            stage_gamma_init <= cmd_staged_ln && cmd_tensor_begin;
            raw_done_seen <= 0; gamma_done_seen <= 0;
            source_load_active <= 0;
            raw_words <= 0; gamma_words <= 0;
            held_cmd_id <= cmd_id; held_cmd_cold <= cmd_cold;
            held_cmd_mode <= cmd_mode; held_cmd_row <= cmd_row;
            held_cmd_w_epoch <= cmd_w_epoch;
            held_cmd_weight_key <= cmd_weight_key;
            held_cmd_model_identity <= cmd_model_identity;
            held_cmd_numeric_identity <= cmd_numeric_identity;
            held_cmd_task_context <= cmd_task_context;
            held_cmd_expected_aux_header <= cmd_expected_aux_header;
            held_cmd_load_base <= cmd_load_base;
            held_cmd_load_bytes <= cmd_load_bytes;
            held_cmd_aux_base <= cmd_aux_base;
            held_cmd_bias_base <= cmd_bias_base;
            held_cmd_bias_bytes <= cmd_bias_bytes;
            held_cmd_down_w_epoch <= cmd_down_w_epoch;
            held_cmd_down_weight_key <= cmd_down_weight_key;
            held_cmd_down_expected_aux_header <=
                cmd_down_expected_aux_header;
            held_cmd_down_load_base <= cmd_down_load_base;
            held_cmd_down_load_bytes <= cmd_down_load_bytes;
            held_cmd_down_aux_base <= cmd_down_aux_base;
            held_cmd_down_bias_base <= cmd_down_bias_base;
            held_cmd_down_bias_bytes <= cmd_down_bias_bytes;
            scratch_error_dst <= 0; scratch_error_ordinal <= 0;
            scratch_error_bresp <= 0;
            if (cmd_input_from_state0 && !cmd_mode) begin
              out_status <= 4'd7; out_phase <= 4'd14;
              state <= OUT_DONE;
            end else if (cmd_mode && !qkv_admission_ok) begin
              out_status <= 4'd7;
              out_phase <= cmd_input_from_state0 ? 4'd14 : 4'd12;
              state <= OUT_DONE;
            end else if (cmd_mode) begin
              if (cmd_tensor_begin) begin
                tensor_active <= 1; tensor_raw_valid <= 0;
                tensor_final_valid <= 0;
                tensor_rope_enable <= cmd_rope_enable;
                tensor_staged_ln <= cmd_staged_ln;
                tensor_rope_aux_base <= cmd_rope_aux_base;
                tensor_rope_aux_span <= cmd_rope_aux_span;
                tensor_source_active <= cmd_input_from_state0;
                tensor_source_base <= cmd_state0_base;
                tensor_source_span <= cmd_state0_span;
                tensor_source_epoch <= cmd_state0_epoch;
                tensor_final_dst_epoch <= cmd_dst_epoch;
                if (cmd_rope_enable) begin
                  tensor_final_dst_epoch[0] <= cmd_tensor_epoch + 1'b1;
                  tensor_final_dst_epoch[1] <= cmd_tensor_epoch + 1'b1;
                end
                tensor_failed <= 0; row_written <= '0;
                stage_store_fault <= 0;
                norm_written <= '0; norm_stage_ready <= 0;
                row_final <= '0;
                tensor_epoch <= cmd_tensor_epoch;
                tensor_request <= cmd_numeric_identity[63:0];
                tensor_generation <= cmd_numeric_identity[127:64];
                tensor_model_identity <= cmd_model_identity;
                tensor_numeric_identity <= cmd_numeric_identity;
                tensor_task_fixed <= cmd_task_context[71:32];
                tensor_dst_epoch <= cmd_dst_epoch;
                tensor_dst_base <= cmd_dst_base;
                tensor_dst_span <= cmd_dst_span;
              end
              segment <= cmd_staged_ln ? 6'd48 : 6'd0;
              segment_tile <= 0;
              scratch_rsp_count <= 0; scratch_flush_count <= 0;
              scratch_aw_count <= '0; scratch_w_count <= '0;
              scratch_b_count <= '0;
              okay_b_count[0] <= 0; okay_b_count[1] <= 0;
              okay_b_count[2] <= 0;
              rope_head_index <= 0;
              rope_head_count <= 0; rope_flush_count <= 0;
              rope_b_ok_count <= 0;
              scratch_load_active <= 0; table_load_active <= 0;
              state <= cmd_input_from_state0 ? IN_BEGIN : Q_WAIT;
            end else state <= F_WAIT;
          end
        end
        IN_BEGIN: if (core_prep_begin_ready)
          state <= stage_gamma_init ? IN_GAMMA_LOAD : IN_RAW_LOAD;
        IN_RAW_LOAD: if (scratch_reader_load_valid &&
                         scratch_reader_load_ready) begin
          source_load_active <= 1;
          state <= IN_RAW_WAIT;
        end
        IN_RAW_WAIT: begin
          if (scratch_reader_done) begin
            raw_done_seen <= 1;
            source_load_active <= 0;
            if (scratch_reader_error ||
                scratch_reader_bytes != 32'd4096) input_error <= 1;
          end
          if (core_prep_fault) input_error <= 1;
          if (input_error) state <= IN_ERR;
          else if (raw_done_seen && !input_hold_valid &&
                   raw_words == 11'd1024 &&
                   !scratch_reader_out_valid)
            state <= active_staged_ln ? IN_COMMIT : IN_GAMMA_LOAD;
        end
        IN_GAMMA_LOAD: if (table_reader_load_valid &&
                           table_reader_load_ready) begin
          table_load_active <= 1;
          state <= IN_GAMMA_WAIT;
        end
        IN_GAMMA_WAIT: begin
          if (table_reader_done) begin
            gamma_done_seen <= 1;
            table_load_active <= 0;
            if (table_reader_error ||
                table_reader_bytes != 32'd4096) input_error <= 1;
          end
          if (core_prep_fault) input_error <= 1;
          if (input_error) state <= IN_ERR;
          else if (gamma_done_seen && !input_hold_valid &&
                   gamma_words == 11'd1024 &&
                   !table_reader_out_valid)
            state <= IN_COMMIT;
        end
        IN_COMMIT: begin
          if (core_prep_fault ||
              (active_staged_ln ?
                (stage_gamma_init ?
                  (!gamma_done_seen || gamma_words != 11'd1024 ||
                   gamma_nonfinite) :
                  (!raw_done_seen || raw_words != 11'd1024 ||
                   !core_gamma_token_valid)) :
                (!raw_done_seen || !gamma_done_seen ||
                 raw_words != 11'd1024 || gamma_words != 11'd1024)))
            state <= IN_ERR;
          else if (core_prep_commit_ready) begin
            if (active_staged_ln && stage_gamma_init) begin
              stage_gamma_init <= 0;
              state <= IN_BEGIN;
            end else state <= IN_CORE_CMD;
          end
        end
        IN_CORE_CMD: if (core_cmd_valid && core_cmd_ready)
          state <= Q_WAIT;
        IN_ERR: begin
          input_error <= 1;
          input_hold_valid <= 0;
          if (scratch_reader_done) source_load_active <= 0;
          if (table_reader_done) table_load_active <= 0;
          if (core_prep_abort_ready && core_prep_abort_valid) begin
            out_status <= gamma_nonfinite ? 4'd6 : 4'd7;
            out_phase <= 4'd14;
            out_bad <= 32'hffffffff;
            out_check_status <= gamma_nonfinite ? 16'd6 : 16'd7;
            out_detail <= gamma_nonfinite ? 32'h0710_000f :
                          32'h0710_0005;
            out_bad64 <= 64'hffff_ffff_ffff_ffff;
            tensor_failed <= 1;
            state <= OUT_DONE;
          end
        end
        F_WAIT: begin
          if (core_row_valid) begin
            if (core_identity_bad) begin
              ffn_identity_error <= 1;
              state <= F_REJECT;
            end else state <= F_ROW;
          end else if (core_done_valid) begin
            if (core_identity_bad) begin
              ffn_identity_error <= 1;
              state <= F_REJECT_DONE;
            end else state <= F_DONE;
          end
        end
        F_ROW: begin
          if (core_identity_bad) begin
            ffn_identity_error <= 1;
            state <= F_DRAIN;
          end else if (core_done_valid) state <= F_DRAIN;
          else if (core_release_valid && core_release_ready) state <= F_DONE;
        end
        F_DRAIN: if (!read_pending && !core_rsp_valid) begin
          if (ffn_identity_error) begin
            if (core_done_valid) state <= F_REJECT_DONE;
            else state <= F_REJECT;
          end else if (core_done_valid) state <= F_DONE;
        end
        F_REJECT: if (core_release_valid && core_release_ready)
          state <= F_REJECT_DONE;
        F_REJECT_DONE: if (core_done_valid) begin
          out_status <= 4'd7; out_phase <= 4'd7;
          out_bad <= 32'hffffffff;
          state <= OUT_DONE;
        end
        F_DONE: if (core_done_valid && done_ready) state <= IDLE;
        Q_WAIT: begin
          if (core_row_valid) begin
            if (core_identity_bad) begin
              local_error <= 1;
              state <= ERR_FLUSH;
            end else state <= active_stage_discard_norm ?
                              RELEASE_ROW : SEG_PREP;
          end
          else if (core_done_valid) begin
            out_status <= core_identity_bad || core_done_status == 0 ?
                          4'd7 : core_done_status;
            out_phase <= core_identity_bad || core_done_status == 0 ?
                         4'd12 : core_done_phase;
            out_bad <= core_identity_bad || core_done_status == 0 ?
                       32'hffffffff : core_done_bad;
            out_op <= core_done_op;
            out_check_status <= core_identity_bad || core_done_status == 0 ?
                                16'd7 : core_done_check_status;
            out_detail <= core_identity_bad || core_done_status == 0 ?
                          32'h0710_0005 : core_done_detail;
            out_bad64 <= core_identity_bad || core_done_status == 0 ?
                         64'hffff_ffff_ffff_ffff : core_done_bad64;
            tensor_failed <= 1;
            state <= OUT_DONE;
          end
        end
        SEG_PREP: begin
          if (core_identity_bad || !next_segment_ok ||
              !writer_debt_zero || read_pending) begin
            local_error <= 1;
            scratch_error_dst <= next_route;
            scratch_error_ordinal <= writer_b_count;
            state <= ERR_FLUSH;
          end else begin
            route <= next_route;
            segment_base <= next_base_sum[63:0];
            segment_span <= next_span;
            segment_tile <= 0;
            state <= READ_REQ;
          end
        end
        READ_REQ: begin
          if (writer_fault || local_error || core_identity_bad) begin
            local_error <= 1;
            state <= ERR_FLUSH;
          end
          else if (core_rd_valid && core_rd_ready) state <= READ_RSP;
        end
        READ_RSP: begin
          if (writer_fault || local_error || core_identity_bad) begin
            local_error <= 1;
            state <= ERR_READ;
          end
          else if (core_rsp_valid && core_rsp_ready) begin
            scratch_rsp_count <= scratch_rsp_count + 1'b1;
            if (core_rsp_tile != expected_core_tile) begin
              local_error <= 1;
              scratch_error_dst <= route;
              scratch_error_ordinal <= writer_b_count;
              state <= ERR_FLUSH;
            end else if (last_tile_in_segment) state <= FLUSH_SEG;
            else begin
              segment_tile <= segment_tile + 1'b1;
              state <= READ_REQ;
            end
          end
        end
        FLUSH_SEG: begin
          if (writer_fault || local_error || core_identity_bad) begin
            local_error <= 1;
            state <= ERR_FLUSH;
          end
          else if (writer_flush_done && writer_debt_zero) begin
            scratch_flush_count <= scratch_flush_count + 1'b1;
            state <= UNFLUSH_SEG;
          end
        end
        UNFLUSH_SEG: begin
          if (writer_fault || local_error || core_identity_bad) begin
            local_error <= 1;
            state <= ERR_FLUSH;
          end
          else if (writer_tile_ready && writer_debt_zero) begin
            if (segment == 6'd48) begin
              if (active_staged_ln ?
                  (scratch_rsp_count != 10'd128 ||
                   scratch_flush_count != 6'd1 ||
                   writer_aw_count != 32'd64 ||
                   writer_w_count != 32'd64 ||
                   writer_b_count != 32'd64 ||
                   okay_b_count[2] != 32'd64 ||
                   okay_b_count[0] != 0 || okay_b_count[1] != 0) :
                  (scratch_rsp_count != 10'd512 ||
                   scratch_flush_count != 6'd49 ||
                   writer_aw_count != 32'd256 ||
                   writer_w_count != 32'd256 ||
                   writer_b_count != 32'd256 ||
                   okay_b_count[0] != 32'd96 ||
                   okay_b_count[1] != 32'd96 ||
                   okay_b_count[2] != 32'd64)) begin
                local_error <= 1;
                state <= ERR_FLUSH;
              end else state <= RELEASE_ROW;
            end else begin
              segment <= segment + 1'b1;
              state <= SEG_PREP;
            end
          end
        end
        ERR_READ: if (!read_pending || (core_rsp_valid && core_rsp_ready))
          state <= ERR_FLUSH;
        // A successful flush_done may coincide with the error which enters
        // this state; the writer reports it only once. Keep flush asserted to
        // drain accepted payload, then retire using actual read/write debts.
        ERR_FLUSH: if (!read_pending && !core_rsp_valid &&
                       writer_debt_zero) state <= RELEASE_ROW;
        ERR_UNFLUSH: if (writer_debt_zero) state <= RELEASE_ROW;
        RELEASE_ROW: if (core_release_valid && core_release_ready)
          state <= Q_DONE;
        Q_DONE: if (core_done_valid) begin
          if (local_error || writer_fault || core_identity_bad) begin
            out_status <= 4'd7; out_phase <= 4'd12;
            out_bad <= 32'hffffffff; tensor_failed <= 1;
            out_op <= active_staged_ln ? 8'h10 : 8'h00;
            out_check_status <= 16'd7;
            out_detail <= active_staged_ln ? 32'h0710_0005 : 0;
            out_bad64 <= 64'hffff_ffff_ffff_ffff;
            if (active_staged_ln && (writer_fault ||
                                     scratch_error_bresp != 0))
              stage_store_fault <= 1;
          end else if (active_stage_discard_norm &&
                       core_done_status == 4'd7 &&
                       core_done_phase == 4'd12 &&
                       core_done_op == 8'h10 &&
                       core_done_check_status == 16'd7 &&
                       core_done_detail == 32'h0710_0005 &&
                       core_done_bad64 == 64'hffff_ffff_ffff_ffff) begin
            // This row's LN succeeded. The explicit release discard reports
            // a core-local protocol status because no norm view is kept;
            // retain the tensor's earlier store failure for the window.
            out_status <= 0; out_phase <= 4'd7;
            out_bad <= 32'hffffffff;
            out_op <= 8'h10; out_check_status <= 0;
            out_detail <= 0;
            out_bad64 <= 64'hffff_ffff_ffff_ffff;
          end else if (core_done_status != 0) begin
            out_status <= core_done_status;
            out_phase <= core_done_phase;
            out_bad <= core_done_bad; tensor_failed <= 1;
            out_op <= core_done_op;
            out_check_status <= core_done_check_status;
            out_detail <= core_done_detail;
            out_bad64 <= core_done_bad64;
          end else begin
            out_status <= 0; out_phase <= 4'd7;
            out_bad <= 32'hffffffff;
            out_op <= core_done_op; out_check_status <= 0;
            out_detail <= 0;
            out_bad64 <= 64'hffff_ffff_ffff_ffff;
            if (active_staged_ln && !active_stage_discard_norm)
              norm_written[active_row] <= 1;
            else row_written[active_row] <= 1;
          end
          if (!active_staged_ln && !local_error && !writer_fault &&
              !core_identity_bad && core_done_status == 0 && active_rope)
            state <= R_REARM;
          else state <= OUT_DONE;
        end
        R_REARM: if (writer_rearm_valid && writer_rearm_ready)
          state <= R_TABLE_RESET;
        R_TABLE_RESET: begin
          rope_table_sin <= 0;
          rope_table_block_index <= 0;
          state <= R_TABLE_LOAD;
        end
        R_TABLE_LOAD: begin
          if (!rope_table_address_ok) begin
            rope_error <= 1; rope_error_status <= 4'd7;
            state <= R_ERR;
          end else if (table_reader_load_valid && table_reader_load_ready) begin
            table_load_active <= 1;
            state <= R_TABLE_WAIT;
          end
        end
        R_TABLE_WAIT: begin
          if (table_reader_out_valid && table_reader_out_ready) begin
            if (table_reader_offset !=
                {23'd0,rope_table_block_index,4'b0000} ||
                table_reader_epoch != tensor_epoch ||
                table_reader_out_bytes != 5'd16 ||
                table_reader_last != (rope_table_block_index == 5'd15)) begin
              rope_error <= 1; rope_error_status <= 4'd7;
              state <= R_ERR;
            end else rope_table_block_index <= rope_table_block_index + 1'b1;
          end
          if (table_reader_done) begin
            table_load_active <= 0;
            if (table_reader_error || table_reader_bytes != 32'd256 ||
                rope_table_block_index != 5'd16) begin
              rope_error <= 1; rope_error_status <= 4'd7;
              state <= R_ERR;
            end else if (!rope_table_sin) begin
              rope_table_sin <= 1;
              rope_table_block_index <= 0;
              state <= R_TABLE_LOAD;
            end else if (&rope_cos_coverage && &rope_sin_coverage)
              state <= R_HEAD_PREP;
            else begin
              rope_error <= 1; rope_error_status <= 4'd7;
              state <= R_ERR;
            end
          end
        end
        R_HEAD_PREP: begin
          if (!rope_head_address_ok || !writer_debt_zero ||
              scratch_load_active || table_load_active) begin
            rope_error <= 1; rope_error_status <= 4'd7;
            state <= R_ERR;
          end else begin
            route <= rope_route;
            segment_base <= rope_base_sum[63:0];
            segment_span <= 64'd256;
            rope_block_index <= 0;
            state <= R_HEAD_LOAD;
          end
        end
        R_HEAD_LOAD: begin
          if (!rope_head_address_ok) begin
            rope_error <= 1; rope_error_status <= 4'd7;
            state <= R_ERR;
          end else if (scratch_reader_load_valid &&
                       scratch_reader_load_ready) begin
            scratch_load_active <= 1;
            state <= R_HEAD_WAIT;
          end
        end
        R_HEAD_WAIT: begin
          if (scratch_reader_out_valid && scratch_reader_out_ready) begin
            if (scratch_reader_offset !=
                {24'd0,rope_block_index,6'b000000} ||
                scratch_reader_epoch != tensor_epoch ||
                scratch_reader_out_bytes != 7'd64 ||
                scratch_reader_last != (rope_block_index == 2'd3)) begin
              rope_error <= 1; rope_error_status <= 4'd7;
              state <= R_ERR;
            end else rope_block_index <= rope_block_index + 1'b1;
          end
          if (scratch_reader_done) begin
            scratch_load_active <= 0;
            if (scratch_reader_error || scratch_reader_bytes != 32'd256 ||
                rope_block_index != 0 || !(&rope_x_coverage)) begin
              rope_error <= 1; rope_error_status <= 4'd7;
              state <= R_ERR;
            end else state <= R_LEAF_START;
          end
        end
        R_LEAF_START: if (rope_start_ready) state <= R_LEAF_WAIT;
        R_LEAF_WAIT: if (rope_result_valid && rope_result_ready) begin
          done_rope_check_valid <= 1;
          done_rope_check <= rope_result_check;
          done_rope_head <= rope_head_index[4:1];
          done_rope_plane <= rope_head_index[0];
          if (rope_result_protocol_error ||
              (rope_result_check[15:0] != 0 &&
               rope_result_check[15:0] != 16'd6)) begin
            rope_error <= 1; rope_error_status <= 4'd7;
            state <= R_ERR;
          end else if (rope_result_check[15:0] == 16'd6) begin
            rope_error <= 1; rope_error_status <= 4'd6;
            out_bad <= {21'd0,rope_head_index[0],rope_head_index[4:1],6'd0} +
                       rope_result_check[95:64];
            state <= R_ERR;
          end else if (!(&rope_y_coverage)) begin
            rope_error <= 1; rope_error_status <= 4'd7;
            state <= R_ERR;
          end else begin
            rope_tile_index <= 0;
            state <= R_WRITE;
          end
        end
        R_WRITE: begin
          if (writer_fault) begin
            rope_error <= 1; rope_error_status <= 4'd7;
            state <= R_ERR;
          end else if (writer_tile_valid && writer_tile_ready) begin
            if (rope_tile_index == 3'd7) state <= R_FLUSH;
            else rope_tile_index <= rope_tile_index + 1'b1;
          end
        end
        R_FLUSH: begin
          if (writer_fault || rope_error) begin
            rope_error <= 1; rope_error_status <= 4'd7;
            state <= R_ERR;
          end else if (writer_flush_done && writer_debt_zero) begin
            rope_flush_count <= rope_flush_count + 1'b1;
            state <= R_UNFLUSH;
          end
        end
        R_UNFLUSH: begin
          if (writer_fault || rope_error) begin
            rope_error <= 1; rope_error_status <= 4'd7;
            state <= R_ERR;
          end else if (writer_tile_ready && writer_debt_zero) begin
            rope_head_count <= rope_head_count + 1'b1;
            if (rope_head_index == 5'd31) begin
              if (rope_flush_count != 8'd32 ||
                  rope_b_ok_count != 8'd128 ||
                  writer_aw_count != 32'd128 ||
                  writer_w_count != 32'd128 ||
                  writer_b_count != 32'd128) begin
                rope_error <= 1; rope_error_status <= 4'd7;
                state <= R_ERR;
              end else begin
                row_final[active_row] <= 1;
                state <= OUT_DONE;
              end
            end else begin
              rope_head_index <= rope_head_index + 1'b1;
              state <= R_HEAD_PREP;
            end
          end
        end
        R_ERR: begin
          if (scratch_reader_done) scratch_load_active <= 0;
          if (table_reader_done) table_load_active <= 0;
          if (!scratch_load_active && !table_load_active &&
              !scratch_reader_out_valid && !table_reader_out_valid &&
              !rope_leaf_active && !rope_result_valid &&
              writer_debt_zero) begin
            out_status <= rope_error_status;
            out_phase <= 4'd13;
            if (rope_error_status != 4'd6) out_bad <= 32'hffffffff;
            tensor_failed <= 1;
            state <= OUT_DONE;
          end
        end
        OUT_DONE: if (done_ready) begin
          if (active_staged_ln && out_status == 0 &&
              &norm_written && !tensor_failed && writer_debt_zero)
            norm_stage_ready <= 1;
          if (active_qkv_admitted && out_status == 0 &&
              !tensor_rope_enable && &row_written && !tensor_failed &&
              writer_debt_zero) tensor_raw_valid <= 1;
          if (active_qkv_admitted && out_status == 0 &&
              tensor_rope_enable && &row_written && &row_final &&
              !tensor_failed && writer_debt_zero)
            tensor_final_valid <= 1;
          source_active <= 0;
          state <= IDLE;
        end
        default: state <= IDLE;
      endcase
    end
  end
`ifndef SYNTHESIS
  always_ff @(posedge clk) if (rst_n) begin
    if (writer_awvalid && !writer_awready)
      assert(m_axi_awaddr[route] == writer_awaddr &&
             m_axi_awlen[route] == 0 && m_axi_awsize[route] == 3'd6 &&
             m_axi_awburst[route] == 2'b01);
    if (writer_bready) assert(writer_debt_zero == 0);
    if (state == F_ROW) assert(!writer_awvalid && !writer_wvalid);
    if (tensor_raw_valid) assert(&row_written && !tensor_failed);
  end
`endif
endmodule
