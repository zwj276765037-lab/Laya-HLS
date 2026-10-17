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
  output logic [31:0] done_id,
  input logic tensor_release_valid,
  output logic tensor_release_ready,
  input logic tensor_release_discard,
  input logic [31:0] tensor_release_epoch,
  input logic [63:0] tensor_release_request, tensor_release_generation,
  output logic tensor_raw_valid,
  output logic [127:0] row_written,
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
  output logic [1:0] scratch_error_bresp
);
  localparam logic [63:0] QKV_BO_SPAN = 64'd12582912;
  localparam logic [63:0] HIDDEN_SPAN = 64'd8388608;
  typedef enum logic [3:0] {
    IDLE, F_WAIT, F_ROW, F_DONE, Q_WAIT, SEG_PREP, READ_REQ,
    READ_RSP, FLUSH_SEG, UNFLUSH_SEG, ERR_READ, ERR_FLUSH,
    ERR_UNFLUSH, RELEASE_ROW, Q_DONE, OUT_DONE
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
  logic [31:0] okay_b_count [0:2];

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
  wire begin_ok = !tensor_active && last_released_epoch != 32'hffffffff &&
      cmd_tensor_epoch == last_released_epoch + 1'b1;
  wire continue_ok = tensor_active && !tensor_failed &&
      !tensor_raw_valid && !row_written[cmd_row] &&
      cmd_tensor_epoch == tensor_epoch &&
      cmd_model_identity == tensor_model_identity &&
      cmd_numeric_identity == tensor_numeric_identity &&
      cmd_task_context[71:32] == tensor_task_fixed &&
      cmd_dst_epoch == tensor_dst_epoch &&
      cmd_dst_base == tensor_dst_base &&
      cmd_dst_span == tensor_dst_span;
  wire qkv_admission_ok = common_identity_ok && descriptor_set_ok &&
      (cmd_tensor_begin ? begin_ok : continue_ok);

  assign tensor_release_ready = state == IDLE && tensor_active &&
      writer_debt_zero && !read_pending &&
      tensor_release_epoch == tensor_epoch &&
      tensor_release_request == tensor_request &&
      tensor_release_generation == tensor_generation &&
      (tensor_release_discard ? !tensor_raw_valid : tensor_raw_valid);
  assign cmd_ready = state == IDLE && !tensor_release_valid &&
      core_cmd_ready && (!cmd_mode || !qkv_admission_ok ||
                         writer_rearm_ready);
  assign core_cmd_valid = state == IDLE && cmd_valid && cmd_ready &&
                          (!cmd_mode || qkv_admission_ok);
  assign writer_rearm_valid = state == IDLE && cmd_valid && cmd_ready &&
                              cmd_mode && qkv_admission_ok;

  assign row_valid = state == F_ROW && core_row_valid;
  assign rd_ready = state == F_ROW && core_rd_ready;
  assign rsp_valid = state == F_ROW && core_rsp_valid;
  assign rsp_tile = state == F_ROW ? core_rsp_tile : '0;
  assign rsp_bits = state == F_ROW ? core_rsp_bits : '0;
  assign row_release_ready = state == F_ROW && core_release_ready;
  assign done_valid = state == OUT_DONE ||
                      (state == F_DONE && core_done_valid);
  assign done_status = state == F_DONE ? core_done_status : out_status;
  assign done_phase = state == F_DONE ? core_done_phase : out_phase;
  assign done_bad_element = state == F_DONE ? core_done_bad : out_bad;

  assign core_rd_valid = (state == F_ROW && rd_valid) ||
                         (state == READ_REQ && !writer_fault &&
                          !local_error);
  assign core_rd_tile = state == F_ROW ? rd_tile : expected_tile;
  assign core_rsp_ready = (state == F_ROW && rsp_ready) ||
      (state == READ_RSP && (local_error || writer_fault ||
          core_rsp_tile != expected_tile || writer_tile_ready)) ||
      state == ERR_READ;
  assign core_release_valid = (state == F_ROW && row_release_valid) ||
                              state == RELEASE_ROW;
  assign core_done_ready = (state == F_DONE && done_ready) ||
                           state == Q_DONE ||
                           (state == Q_WAIT && core_done_valid &&
                            !core_row_valid);

  laya_lnq_wi_gqdown_row_v1 core (
    .*, .cmd_valid(core_cmd_valid), .cmd_ready(core_cmd_ready),
    .row_valid(core_row_valid), .rd_valid(core_rd_valid),
    .rd_ready(core_rd_ready), .rd_tile(core_rd_tile),
    .rsp_valid(core_rsp_valid), .rsp_ready(core_rsp_ready),
    .rsp_tile(core_rsp_tile), .rsp_bits(core_rsp_bits),
    .row_release_valid(core_release_valid),
    .row_release_ready(core_release_ready),
    .done_valid(core_done_valid), .done_ready(core_done_ready),
    .done_status(core_done_status), .done_phase(core_done_phase),
    .done_bad_element(core_done_bad),
    .result_mode(core_result_mode), .result_row(core_result_row)
  );

  assign writer_tile_valid = state == READ_RSP && core_rsp_valid &&
      core_rsp_tile == expected_tile && !local_error && !writer_fault;
  assign writer_flush_req = state == FLUSH_SEG || state == ERR_FLUSH;
  tm1tn8_axi512_writer #(.SHARD(1'b0)) writer (
    .clk,.rst_n,.tile_valid(writer_tile_valid),.tile_ready(writer_tile_ready),
    .tile_f32(core_rsp_bits),.tile_n0(writer_n0),
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
      tensor_failed <= 0; row_written <= '0;
      tensor_epoch <= 0; last_released_epoch <= 0;
      tensor_request <= 0; tensor_generation <= 0;
      tensor_model_identity <= 0; tensor_numeric_identity <= 0;
      tensor_task_fixed <= 0;
      tensor_dst_epoch <= '0; tensor_dst_base <= '0;
      tensor_dst_span <= '0;
      done_id <= 0; result_mode <= 0; result_row <= 0;
      active_row <= 0; active_qkv_admitted <= 0;
      out_status <= 0; out_phase <= 4'd7;
      out_bad <= 32'hffffffff; local_error <= 0;
      segment <= 0; segment_tile <= 0; route <= 0;
      segment_base <= 0; segment_span <= 0;
      read_pending <= 0; scratch_rsp_count <= 0;
      scratch_flush_count <= 0;
      scratch_aw_count <= '0; scratch_w_count <= '0;
      scratch_b_count <= '0;
      okay_b_count[0] <= 0; okay_b_count[1] <= 0;
      okay_b_count[2] <= 0;
      scratch_error_dst <= 0; scratch_error_ordinal <= 0;
      scratch_error_bresp <= 0;
    end else begin
      if (core_rd_valid && core_rd_ready && state == READ_REQ)
        read_pending <= 1;
      if (core_rsp_valid && core_rsp_ready && state != F_ROW)
        read_pending <= 0;
      if (writer_awvalid && writer_awready)
        scratch_aw_count[route] <= scratch_aw_count[route] + 1'b1;
      if (writer_wvalid && writer_wready)
        scratch_w_count[route] <= scratch_w_count[route] + 1'b1;
      if (writer_b_fire) begin
        scratch_b_count[route] <= scratch_b_count[route] + 1'b1;
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
            last_released_epoch <= tensor_epoch;
            tensor_active <= 0; tensor_raw_valid <= 0;
            tensor_failed <= 0; row_written <= '0;
            tensor_epoch <= 0;
          end else if (cmd_valid && cmd_ready) begin
            done_id <= cmd_id; result_mode <= cmd_mode;
            result_row <= cmd_row;
            active_row <= cmd_row;
            active_qkv_admitted <= cmd_mode && qkv_admission_ok;
            out_status <= 0; out_phase <= 4'd7;
            out_bad <= 32'hffffffff; local_error <= 0;
            scratch_error_dst <= 0; scratch_error_ordinal <= 0;
            scratch_error_bresp <= 0;
            if (cmd_mode && !qkv_admission_ok) begin
              out_status <= 4'd7; out_phase <= 4'd12;
              state <= OUT_DONE;
            end else if (cmd_mode) begin
              if (cmd_tensor_begin) begin
                tensor_active <= 1; tensor_raw_valid <= 0;
                tensor_failed <= 0; row_written <= '0;
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
              segment <= 0; segment_tile <= 0;
              scratch_rsp_count <= 0; scratch_flush_count <= 0;
              scratch_aw_count <= '0; scratch_w_count <= '0;
              scratch_b_count <= '0;
              okay_b_count[0] <= 0; okay_b_count[1] <= 0;
              okay_b_count[2] <= 0;
              state <= Q_WAIT;
            end else state <= F_WAIT;
          end
        end
        F_WAIT: begin
          if (core_row_valid) state <= F_ROW;
          else if (core_done_valid) state <= F_DONE;
        end
        F_ROW: if (core_release_valid && core_release_ready) state <= F_DONE;
        F_DONE: if (core_done_valid && done_ready) state <= IDLE;
        Q_WAIT: begin
          if (core_row_valid) state <= SEG_PREP;
          else if (core_done_valid) begin
            out_status <= core_done_status == 0 ? 4'd7 : core_done_status;
            out_phase <= core_done_status == 0 ? 4'd12 : core_done_phase;
            out_bad <= core_done_status == 0 ? 32'hffffffff : core_done_bad;
            tensor_failed <= 1;
            state <= OUT_DONE;
          end
        end
        SEG_PREP: begin
          if (!next_segment_ok || !writer_debt_zero || read_pending) begin
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
          if (writer_fault || local_error) state <= ERR_FLUSH;
          else if (core_rd_valid && core_rd_ready) state <= READ_RSP;
        end
        READ_RSP: begin
          if (writer_fault || local_error) state <= ERR_READ;
          else if (core_rsp_valid && core_rsp_ready) begin
            scratch_rsp_count <= scratch_rsp_count + 1'b1;
            if (core_rsp_tile != expected_tile) begin
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
          if (writer_fault || local_error) state <= ERR_FLUSH;
          else if (writer_flush_done && writer_debt_zero) begin
            scratch_flush_count <= scratch_flush_count + 1'b1;
            state <= UNFLUSH_SEG;
          end
        end
        UNFLUSH_SEG: begin
          if (writer_fault || local_error) state <= ERR_FLUSH;
          else if (writer_tile_ready && writer_debt_zero) begin
            if (segment == 6'd48) begin
              if (scratch_rsp_count != 10'd512 ||
                  scratch_flush_count != 6'd49 ||
                  writer_aw_count != 32'd256 ||
                  writer_w_count != 32'd256 ||
                  writer_b_count != 32'd256 ||
                  okay_b_count[0] != 32'd96 ||
                  okay_b_count[1] != 32'd96 ||
                  okay_b_count[2] != 32'd64) begin
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
        ERR_FLUSH: begin
          if (writer_fault && writer_debt_zero) state <= RELEASE_ROW;
          else if (!writer_fault && writer_flush_done && writer_debt_zero)
            state <= ERR_UNFLUSH;
        end
        ERR_UNFLUSH: if (writer_debt_zero) state <= RELEASE_ROW;
        RELEASE_ROW: if (core_release_valid && core_release_ready)
          state <= Q_DONE;
        Q_DONE: if (core_done_valid) begin
          if (local_error || writer_fault) begin
            out_status <= 4'd7; out_phase <= 4'd12;
            out_bad <= 32'hffffffff; tensor_failed <= 1;
          end else if (core_done_status != 0) begin
            out_status <= core_done_status;
            out_phase <= core_done_phase;
            out_bad <= core_done_bad; tensor_failed <= 1;
          end else begin
            out_status <= 0; out_phase <= 4'd7;
            out_bad <= 32'hffffffff;
            row_written[active_row] <= 1;
          end
          state <= OUT_DONE;
        end
        OUT_DONE: if (done_ready) begin
          if (active_qkv_admitted && out_status == 0 &&
              &row_written && !tensor_failed && writer_debt_zero)
            tensor_raw_valid <= 1;
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
