`timescale 1ns/1ps

// Fixed shared source/AUX readers and output writer. These are the original
// production engines; the surrounding request FSM grants each fixed client
// and holds its selected route until the engine's real debt retires.
module laya_source_norm_service_v1 (
  input logic clk, rst_n,
  laya_lnq_bank_link_v1 bank_link,
  input logic reader_cancel,
  input logic scratch_reader_load_valid,
  output logic scratch_reader_load_ready,
  input logic [63:0] scratch_reader_load_base,
  input logic [31:0] scratch_reader_load_bytes,
  input logic [31:0] scratch_reader_load_epoch,
  output logic scratch_reader_done, scratch_reader_error,
  output logic [31:0] scratch_reader_bytes,
  output logic [63:0] scratch_reader_araddr,
  output logic [7:0] scratch_reader_arlen,
  output logic [2:0] scratch_reader_arsize,
  output logic [1:0] scratch_reader_arburst,
  output logic scratch_reader_arvalid,
  output logic scratch_reader_rready,
  input logic source_load_active,
  input logic [1:0] rope_route,
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
  output logic [1:0][63:0] rope_araddr,
  output logic [1:0][7:0] rope_arlen,
  output logic [1:0][2:0] rope_arsize,
  output logic [1:0][1:0] rope_arburst,
  output logic [1:0] rope_arvalid,
  input logic [1:0] rope_arready,
  input logic [1:0][511:0] rope_rdata,
  input logic [1:0][1:0] rope_rresp,
  input logic [1:0] rope_rlast, rope_rvalid,
  output logic [1:0] rope_rready,
  output logic [511:0] scratch_reader_out_data,
  output logic [31:0] scratch_reader_offset, scratch_reader_epoch,
  output logic [6:0] scratch_reader_out_bytes,
  output logic scratch_reader_last, scratch_reader_out_valid,
  input logic scratch_reader_out_ready,

  input logic table_reader_load_valid,
  output logic table_reader_load_ready,
  input logic [63:0] table_reader_load_base,
  input logic [31:0] table_reader_load_bytes,
  input logic [31:0] table_reader_load_epoch,
  output logic table_reader_done, table_reader_error,
  output logic [31:0] table_reader_bytes,
  output logic [63:0] table_reader_araddr,
  output logic [7:0] table_reader_arlen,
  output logic [2:0] table_reader_arsize,
  output logic [1:0] table_reader_arburst,
  output logic table_reader_arvalid,
  output logic table_reader_rready,
  input logic rope_aux_owner,
  input logic [63:0] core_aux_araddr,
  input logic [7:0] core_aux_arlen,
  input logic [2:0] core_aux_arsize,
  input logic [1:0] core_aux_arburst,
  input logic core_aux_arvalid,
  output logic core_aux_arready,
  output logic [127:0] core_aux_rdata,
  output logic [1:0] core_aux_rresp,
  output logic core_aux_rlast, core_aux_rvalid,
  input logic core_aux_rready,
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
  output logic [127:0] table_reader_out_data,
  output logic [31:0] table_reader_offset, table_reader_epoch,
  output logic [4:0] table_reader_out_bytes,
  output logic table_reader_last, table_reader_out_valid,
  input logic table_reader_out_ready,

  input logic writer_tile_valid,
  output logic writer_tile_ready,
  input logic [255:0] writer_tile_f32,
  input logic [11:0] writer_tile_n0,
  input logic writer_rearm_valid,
  output logic writer_rearm_ready,
  input logic writer_flush_req,
  output logic writer_flush_done, writer_debt_zero, writer_fault,
  input logic segment_begin_valid,
  input logic [1:0] segment_begin_route,
  input logic [63:0] segment_begin_base, segment_begin_span,
  input logic stage_row_accept, stage_tensor_begin,
  input logic [6:0] stage_row,
  input logic stage_row_discard,
  input logic stage_row_done_fire,
  input logic [3:0] stage_row_done_status,
  input logic stage_release_fire,
  output logic [127:0] norm_written,
  output logic norm_stage_ready, stage_store_fault,
  output logic [1:0] segment_route,
  output logic [63:0] writer_output_base, writer_output_span,
  output logic [31:0] writer_aw_count, writer_w_count, writer_b_count,
  output logic [63:0] writer_useful_bytes, writer_physical_bytes,
  output logic [63:0] writer_awaddr,
  output logic [7:0] writer_awlen,
  output logic [2:0] writer_awsize,
  output logic [1:0] writer_awburst,
  output logic writer_awvalid,
  output logic writer_awready,
  output logic [511:0] writer_wdata,
  output logic [63:0] writer_wstrb,
  output logic writer_wlast, writer_wvalid,
  output logic writer_wready,
  output logic [1:0] writer_bresp,
  output logic writer_bvalid,
  output logic writer_bready,
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
  output logic [2:0] m_axi_bready
);
  laya_lnq_bank_service_v1 bank_service (
    .clk(clk),
    .rst_n(rst_n),
    .ln_cmd_valid(bank_link.ln_cmd_valid),
    .ln_cmd_ready(bank_link.ln_cmd_ready),
    .ln_source_mode(bank_link.ln_source_mode),
    .ln_gamma_kind(bank_link.ln_gamma_kind),
    .ln_cmd_row(bank_link.ln_cmd_row),
    .ln_only_ready(bank_link.ln_only_ready),
    .staged_ln_cmd_valid(bank_link.staged_ln_cmd_valid),
    .staged_ln_cmd_ready(bank_link.staged_ln_cmd_ready),
    .staged_ln_row(bank_link.staged_ln_row),
    .staged_ln_view_valid(bank_link.staged_ln_view_valid),
    .staged_ln_rd_valid(bank_link.staged_ln_rd_valid),
    .staged_ln_rd_tile(bank_link.staged_ln_rd_tile),
    .staged_ln_rd_ready(bank_link.staged_ln_rd_ready),
    .staged_ln_release_valid(bank_link.staged_ln_release_valid),
    .staged_ln_release_discard(bank_link.staged_ln_release_discard),
    .staged_ln_release_ready(bank_link.staged_ln_release_ready),
    .staged_ln_done_valid(bank_link.staged_ln_done_valid),
    .staged_ln_done_ready(bank_link.staged_ln_done_ready),
    .staged_ln_done_status(bank_link.staged_ln_done_status),
    .staged_ln_done_phase(bank_link.staged_ln_done_phase),
    .staged_ln_done_bad(bank_link.staged_ln_done_bad),
    .staged_ln_done_id(bank_link.staged_ln_done_id),
    .staged_ln_done_epoch(bank_link.staged_ln_done_epoch),
    .staged_ln_done_row(bank_link.staged_ln_done_row),
    .staged_ln_result_exec(bank_link.staged_ln_result_exec),
    .staged_ln_done_op(bank_link.staged_ln_done_op),
    .staged_ln_done_check_status(bank_link.staged_ln_done_check_status),
    .staged_ln_done_detail(bank_link.staged_ln_done_detail),
    .staged_ln_done_bad64(bank_link.staged_ln_done_bad64),
    .ln_x_valid(bank_link.ln_x_valid),
    .ln_x_ready(bank_link.ln_x_ready),
    .ln_x_bits(bank_link.ln_x_bits),
    .ln_gamma_valid(bank_link.ln_gamma_valid),
    .ln_gamma_ready(bank_link.ln_gamma_ready),
    .ln_gamma_bits(bank_link.ln_gamma_bits),
    .ln_row_valid(bank_link.ln_row_valid),
    .ln_rd_valid(bank_link.ln_rd_valid),
    .ln_rd_ready(bank_link.ln_rd_ready),
    .ln_rd_group(bank_link.ln_rd_group),
    .ln_rsp_valid(bank_link.ln_rsp_valid),
    .ln_rsp_ready(bank_link.ln_rsp_ready),
    .ln_rsp_group(bank_link.ln_rsp_group),
    .ln_rsp_q(bank_link.ln_rsp_q),
    .ln_rsp_scale(bank_link.ln_rsp_scale),
    .ln_release_valid(bank_link.ln_release_valid),
    .ln_release_ready(bank_link.ln_release_ready),
    .ln_done_valid(bank_link.ln_done_valid),
    .ln_done_ready(bank_link.ln_done_ready),
    .ln_done_status(bank_link.ln_done_status),
    .ln_done_bad(bank_link.ln_done_bad),
    .ln_mean(bank_link.ln_mean),
    .ln_variance(bank_link.ln_variance),
    .ln_inverse(bank_link.ln_inverse),
    .norm_valid(bank_link.norm_valid),
    .norm_index(bank_link.norm_index),
    .norm_bits(bank_link.norm_bits),
    .q16_fill_cmd_valid(bank_link.q16_fill_cmd_valid),
    .q16_fill_cmd_ready(bank_link.q16_fill_cmd_ready),
    .q16_fill_done_valid(bank_link.q16_fill_done_valid),
    .q16_fill_done_ready(bank_link.q16_fill_done_ready),
    .q16_fill_done_status(bank_link.q16_fill_done_status),
    .q16_fill_done_bad(bank_link.q16_fill_done_bad),
    .q16_retire_success(bank_link.q16_retire_success),
    .q16_window_begin(bank_link.q16_window_begin),
    .q16_row(bank_link.q16_row),
    .q16_epoch(bank_link.q16_epoch),
    .q16_model(bank_link.q16_model),
    .q16_numeric(bank_link.q16_numeric),
    .q16_done(bank_link.q16_done),
    .q16_fault(bank_link.q16_fault),
    .q16_partial_owned(bank_link.q16_partial_owned),
    .q16_window_ok(bank_link.q16_window_ok),
    .q16_next_row(bank_link.q16_next_row),
    .a_window_ready(bank_link.a_window_ready),
    .a_window_release_valid(bank_link.a_window_release_valid),
    .a_window_discard(bank_link.a_window_discard),
    .a_window_release_ready(bank_link.a_window_release_ready),
    .bank_idle(bank_link.bank_idle),
    .prep_begin_idle(bank_link.prep_begin_idle),
    .prep_begin_allow(bank_link.prep_begin_allow),
    .prep_begin_valid(bank_link.prep_begin_valid),
    .prep_begin_ready(bank_link.prep_begin_ready),
    .prep_kind(bank_link.prep_kind),
    .prep_id(bank_link.prep_id),
    .prep_row(bank_link.prep_row),
    .prep_epoch(bank_link.prep_epoch),
    .prep_model_identity(bank_link.prep_model_identity),
    .prep_numeric_identity(bank_link.prep_numeric_identity),
    .prep_gamma_aux_base(bank_link.prep_gamma_aux_base),
    .prep_gamma_aux_span(bank_link.prep_gamma_aux_span),
    .prep_write_valid(bank_link.prep_write_valid),
    .prep_write_ready(bank_link.prep_write_ready),
    .prep_write_index(bank_link.prep_write_index),
    .prep_write_bits(bank_link.prep_write_bits),
    .prep_commit_valid(bank_link.prep_commit_valid),
    .prep_commit_ready(bank_link.prep_commit_ready),
    .prep_abort_valid(bank_link.prep_abort_valid),
    .prep_abort_ready(bank_link.prep_abort_ready),
    .prep_active(bank_link.prep_active),
    .prep_token_valid(bank_link.prep_token_valid),
    .gamma_token_valid(bank_link.gamma_token_valid),
    .prep_fault(bank_link.prep_fault),
    .prep_consume(bank_link.prep_consume),
    .match_id(bank_link.match_id),
    .match_row(bank_link.match_row),
    .match_epoch(bank_link.match_epoch),
    .match_model_identity(bank_link.match_model_identity),
    .match_numeric_identity(bank_link.match_numeric_identity),
    .match_kind(bank_link.match_kind),
    .match_gamma_aux_base(bank_link.match_gamma_aux_base),
    .match_gamma_aux_span(bank_link.match_gamma_aux_span),
    .prepared_basic_match(bank_link.prepared_basic_match),
    .prepared_match(bank_link.prepared_match),
    .gamma_match(bank_link.gamma_match),
    .norm_store_valid(bank_link.norm_store_valid),
    .norm_store_index(bank_link.norm_store_index),
    .norm_store_bits(bank_link.norm_store_bits),
    .ps_store_valid(bank_link.ps_store_valid),
    .ps_store_tile(bank_link.ps_store_tile),
    .ps_store_bits(bank_link.ps_store_bits),
    .g_store_valid(bank_link.g_store_valid),
    .g_store_index(bank_link.g_store_index),
    .g_store_bits(bank_link.g_store_bits),
    .res_store_valid(bank_link.res_store_valid),
    .res_store_index(bank_link.res_store_index),
    .res_store_bits(bank_link.res_store_bits),
    .feed_start(bank_link.feed_start),
    .feed_active(bank_link.feed_active),
    .feed_state(bank_link.feed_state),
    .replay_hold(bank_link.replay_hold),
    .result_reset(bank_link.result_reset),
    .result_accept(bank_link.result_accept),
    .result_physical_addr(bank_link.result_physical_addr),
    .result_logical_tile(bank_link.result_logical_tile),
    .result_pending(bank_link.result_pending),
    .result_rsp_valid(bank_link.result_rsp_valid),
    .result_rsp_ready(bank_link.result_rsp_ready),
    .result_rsp_tile(bank_link.result_rsp_tile),
    .result_rsp_bits(bank_link.result_rsp_bits),
    .g_x_read_valid(bank_link.g_x_read_valid),
    .g_x_read_tile(bank_link.g_x_read_tile),
    .g_x_hold(bank_link.g_x_hold),
    .g_gate_read_valid(bank_link.g_gate_read_valid),
    .g_gate_read_tile(bank_link.g_gate_read_tile),
    .g_gate_hold(bank_link.g_gate_hold),
    .qd_read_valid(bank_link.qd_read_valid),
    .qd_read_word(bank_link.qd_read_word),
    .qd_word(bank_link.qd_word),
    .res_read_valid(bank_link.res_read_valid),
    .res_read_index(bank_link.res_read_index),
    .res_b_hold(bank_link.res_b_hold)
  );
  logic scratch_reader_arready;
  logic [511:0] scratch_reader_rdata;
  logic [1:0] scratch_reader_rresp;
  logic scratch_reader_rlast, scratch_reader_rvalid;
  logic table_reader_arready;
  logic [127:0] table_reader_rdata;
  logic [1:0] table_reader_rresp;
  logic table_reader_rlast, table_reader_rvalid;
  logic stage_row_active, stage_discard_q, stage_flush_seen;
  logic [6:0] stage_row_q;
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
  assign table_reader_rdata = aux_rdata;
  assign table_reader_rresp = aux_rresp;
  assign table_reader_rlast = aux_rlast;
  assign table_reader_rvalid = rope_aux_owner && aux_rvalid;
  always_ff @(posedge clk)begin
    if(!rst_n)begin
      segment_route<=0;
      writer_output_base<=0;writer_output_span<=0;
      norm_written<='0;
      norm_stage_ready<=0;
      stage_store_fault<=0;
      stage_row_active<=0;stage_discard_q<=0;
      stage_flush_seen<=0;stage_row_q<=0;
    end else if(segment_begin_valid)begin
      segment_route<=segment_begin_route;
      writer_output_base<=segment_begin_base;
      writer_output_span<=segment_begin_span;
    end
    if(rst_n)begin
      if(stage_release_fire ||
         (stage_row_accept && stage_tensor_begin))begin
        norm_written<='0;
        norm_stage_ready<=0;
        stage_store_fault<=0;
      end else if(stage_row_active)begin
        if(writer_fault)stage_store_fault<=1;
        if(writer_flush_done && writer_debt_zero)
          stage_flush_seen<=1;
        if(stage_row_done_fire)begin
          if(stage_row_done_status==0 && !stage_discard_q &&
             !writer_fault && writer_debt_zero && stage_flush_seen &&
             writer_aw_count==32'd64 && writer_w_count==32'd64 &&
             writer_b_count==32'd64)begin
            norm_written[stage_row_q]<=1;
            if(stage_row_q==7'd127 && &norm_written[126:0] &&
               !stage_store_fault)norm_stage_ready<=1;
          end
          stage_row_active<=0;
        end
      end
      if(stage_row_accept)begin
        stage_row_active<=1;
        stage_row_q<=stage_row;
        stage_discard_q<=stage_row_discard;
        stage_flush_seen<=0;
      end
      if(stage_release_fire)begin
        stage_row_active<=0;
        stage_flush_seen<=0;
      end
    end
  end
  always_comb begin
    m_axi_awaddr='0;m_axi_awlen='0;
    m_axi_awsize='0;m_axi_awburst='0;m_axi_awvalid='0;
    m_axi_wdata='0;m_axi_wstrb='0;
    m_axi_wlast='0;m_axi_wvalid='0;m_axi_bready='0;
    writer_awready=m_axi_awready[segment_route];
    writer_wready=m_axi_wready[segment_route];
    writer_bvalid=m_axi_bvalid[segment_route];
    writer_bresp=m_axi_bresp[segment_route];
    m_axi_awaddr[segment_route]=writer_awaddr;
    m_axi_awlen[segment_route]=writer_awlen;
    m_axi_awsize[segment_route]=writer_awsize;
    m_axi_awburst[segment_route]=writer_awburst;
    m_axi_awvalid[segment_route]=writer_awvalid;
    m_axi_wdata[segment_route]=writer_wdata;
    m_axi_wstrb[segment_route]=writer_wstrb;
    m_axi_wlast[segment_route]=writer_wlast;
    m_axi_wvalid[segment_route]=writer_wvalid;
    m_axi_bready[segment_route]=writer_bready;
  end
`ifndef SYNTHESIS
  always_ff @(posedge clk)if(rst_n && segment_begin_valid)
    assert(writer_debt_zero && !writer_flush_req && !writer_tile_valid)
      else $fatal(1,"source/norm writer route changed with outstanding debt");
`endif
  t4_w_reader_port_v1 #(.SCALE_MODE(1'b0)) rope_scratch_reader (
    .clk,.rst_n,.cancel(reader_cancel),
    .load_valid(scratch_reader_load_valid),
    .load_ready(scratch_reader_load_ready),
    .load_base(scratch_reader_load_base),
    .load_bytes(scratch_reader_load_bytes),
    .load_epoch(scratch_reader_load_epoch),
    .load_done(scratch_reader_done),.load_error(scratch_reader_error),
    .committed_bytes(scratch_reader_bytes),
    .araddr(scratch_reader_araddr),.arlen(scratch_reader_arlen),
    .arsize(scratch_reader_arsize),.arburst(scratch_reader_arburst),
    .arvalid(scratch_reader_arvalid),.arready(scratch_reader_arready),
    .rdata(scratch_reader_rdata),.rresp(scratch_reader_rresp),
    .rlast(scratch_reader_rlast),.rvalid(scratch_reader_rvalid),
    .rready(scratch_reader_rready),
    .out_data(scratch_reader_out_data),.out_offset(scratch_reader_offset),
    .out_epoch(scratch_reader_epoch),.out_bytes(scratch_reader_out_bytes),
    .out_last(scratch_reader_last),.out_valid(scratch_reader_out_valid),
    .out_ready(scratch_reader_out_ready)
  );
  t4_aux_bias_reader_v1 rope_table_reader (
    .clk,.rst_n,.cancel(reader_cancel),
    .load_valid(table_reader_load_valid),.load_ready(table_reader_load_ready),
    .load_base(table_reader_load_base),
    .load_bytes(table_reader_load_bytes),
    .load_epoch(table_reader_load_epoch),
    .load_done(table_reader_done),.load_error(table_reader_error),
    .committed_bytes(table_reader_bytes),
    .araddr(table_reader_araddr),.arlen(table_reader_arlen),
    .arsize(table_reader_arsize),.arburst(table_reader_arburst),
    .arvalid(table_reader_arvalid),.arready(table_reader_arready),
    .rdata(table_reader_rdata),.rresp(table_reader_rresp),
    .rlast(table_reader_rlast),.rvalid(table_reader_rvalid),
    .rready(table_reader_rready),
    .out_data(table_reader_out_data),.out_offset(table_reader_offset),
    .out_epoch(table_reader_epoch),.out_bytes(table_reader_out_bytes),
    .out_last(table_reader_last),.out_valid(table_reader_out_valid),
    .out_ready(table_reader_out_ready)
  );
  tm1tn8_axi512_writer #(.SHARD(1'b0)) writer (
    .clk,.rst_n,.tile_valid(writer_tile_valid),.tile_ready(writer_tile_ready),
    .tile_f32(writer_tile_f32),.tile_n0(writer_tile_n0),
    .tile_row_local(2'd0),.tile_row0(10'd0),.tile_batch(1'b0),
    .tile_lanes(4'd8),.mode_qkv(1'b0),
    .rearm_valid(writer_rearm_valid),.rearm_ready(writer_rearm_ready),
    .flush_req(writer_flush_req),.flush_done(writer_flush_done),
    .debt_zero(writer_debt_zero),.output_base(writer_output_base),
    .output_span(writer_output_span),.fault(writer_fault),
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
endmodule
