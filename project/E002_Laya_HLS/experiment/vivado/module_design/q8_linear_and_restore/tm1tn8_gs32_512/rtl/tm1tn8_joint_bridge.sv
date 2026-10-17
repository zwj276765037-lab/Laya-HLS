`timescale 1ns/1ps

// HLS LOAD/quant streams -> clocked PS/FP/bias -> real 512-bit AXI writers.
// The selected-group trace port must be connected to an observed-AXI writer;
// trace_ack_valid is permitted only after that writer's actual B retirement.
module tm1tn8_joint_bridge (
  input  logic          clk,
  input  logic          rst_n,
  input  logic [255:0]  cfg_tdata,
  input  logic          cfg_tvalid,
  output logic          cfg_tready,
  input  logic [255:0]  compute_cfg_tdata,
  input  logic          compute_cfg_tvalid,
  output logic          compute_cfg_tready,
  input  logic [287:0]  bias_tdata,
  input  logic          bias_tvalid,
  output logic          bias_tready,
  input  logic [2815:0] group_tdata,
  input  logic          group_tvalid,
  output logic          group_tready,
  input  logic          finish_tvalid,
  output logic          finish_tready,
  output logic [511:0]  completion_tdata,
  output logic          completion_tvalid,
  input  logic          completion_tready,
  input  logic [63:0]   observed_base,
  input  logic [63:0]   observed_span,
  input  logic          trace_command_start,
  output logic [63:0]   observed_awaddr,
  output logic [7:0]    observed_awlen,
  output logic [2:0]    observed_awsize,
  output logic [1:0]    observed_awburst,
  output logic          observed_awvalid,
  input  logic          observed_awready,
  output logic [31:0]   observed_wdata,
  output logic [3:0]    observed_wstrb,
  output logic          observed_wlast,
  output logic          observed_wvalid,
  input  logic          observed_wready,
  input  logic [1:0]    observed_bresp,
  input  logic          observed_bvalid,
  output logic          observed_bready,
  output logic [63:0]   m0_awaddr,
  output logic [7:0]    m0_awlen,
  output logic [2:0]    m0_awsize,
  output logic [1:0]    m0_awburst,
  output logic          m0_awvalid,
  input  logic          m0_awready,
  output logic [511:0]  m0_wdata,
  output logic [63:0]   m0_wstrb,
  output logic          m0_wlast,
  output logic          m0_wvalid,
  input  logic          m0_wready,
  input  logic [1:0]    m0_bresp,
  input  logic          m0_bvalid,
  output logic          m0_bready,
  output logic [63:0]   m1_awaddr,
  output logic [7:0]    m1_awlen,
  output logic [2:0]    m1_awsize,
  output logic [1:0]    m1_awburst,
  output logic          m1_awvalid,
  input  logic          m1_awready,
  output logic [511:0]  m1_wdata,
  output logic [63:0]   m1_wstrb,
  output logic          m1_wlast,
  output logic          m1_wvalid,
  input  logic          m1_wready,
  input  logic [1:0]    m1_bresp,
  input  logic          m1_bvalid,
  output logic          m1_bready,
  output logic          all_writer_debt_zero,
  output logic          any_writer_fault
);
  logic ps_cfg_ready, bias_cfg_ready, bias_loaded;
  logic [319:0] ps_tile_data;
  logic ps_tile_valid, ps_tile_ready;
  logic [287:0] tile0_tdata, tile1_tdata;
  logic tile0_tvalid, tile1_tvalid, tile0_tready, tile1_tready;
  logic [159:0] trace_tag;
  logic [255:0] trace_payload;
  logic [1:0] trace_slot;
  logic [415:0] trace_event_tdata;
  logic trace_event_tvalid, trace_event_tready;
  logic trace_ack_valid;
  logic [1:0] trace_ack_slot;
  logic [159:0] trace_ack_tag;
  logic trace_ack_ok;
  logic trace_debt_zero, trace_fault;
  logic [31:0] trace_aw_count, trace_w_count, trace_b_count;
  logic output_writer_debt_zero, output_writer_fault;
  logic ps_compute_done, flush_pending, writer_finish_ready;
  logic bias_drain_empty, writer_finish_valid;
  logic [128:0] writer_completion_data;
  logic writer_completion_valid;
  logic [63:0] ps_rank, ps_bad_element, bias_rank, bias_bad_element;
  logic [31:0] ps_detail, bias_detail;
  logic ps_numeric, bias_numeric, ps_protocol, bias_protocol;
  logic [31:0] groups_accepted, groups_retired, groups_processed;
  logic [31:0] committed_elements, trace_ack_count;
  logic [31:0] trace_b_start;
  logic [63:0] active_macs;
  logic [5:0] result_free, result_reserved, result_returned;
  logic [2:0] trace_free;
  logic [63:0] selected_bad_element;
  logic [31:0] selected_detail;
  logic ps_cfg_valid, bias_cfg_valid;

  assign compute_cfg_tready = ps_cfg_ready && bias_cfg_ready;
  assign ps_cfg_valid = compute_cfg_tvalid && compute_cfg_tready;
  assign bias_cfg_valid = ps_cfg_valid;
  assign group_tready = bias_loaded && ps_group_ready;
  logic ps_group_ready;
  assign trace_event_tdata = {trace_tag,trace_payload};
  assign completion_tvalid = writer_completion_valid && trace_debt_zero;
  assign all_writer_debt_zero = output_writer_debt_zero && trace_debt_zero;
  assign any_writer_fault = output_writer_fault || trace_fault;
  assign selected_bad_element =
      ps_rank <= bias_rank ? ps_bad_element : bias_bad_element;
  assign selected_detail = ps_rank <= bias_rank ? ps_detail : bias_detail;
  always_comb begin
    completion_tdata = 0;
    completion_tdata[0] = writer_completion_data[0] ||
                           ps_protocol || bias_protocol || trace_fault;
    completion_tdata[64:1] = writer_completion_data[64:1];
    completion_tdata[128:65] = writer_completion_data[128:65];
    completion_tdata[129] = ps_numeric || bias_numeric;
    completion_tdata[161:130] = selected_detail;
    completion_tdata[225:162] = selected_bad_element;
    completion_tdata[257:226] = groups_retired;
    completion_tdata[289:258] = committed_elements;
    completion_tdata[353:290] = active_macs;
    completion_tdata[385:354] = groups_accepted;
    completion_tdata[417:386] = trace_b_count - trace_b_start;
    completion_tdata[449:418] = trace_ack_count;
  end

  tm1tn8_ps_controller ps_controller (
    .clk(clk), .rst_n(rst_n),
    .cfg_tdata(compute_cfg_tdata), .cfg_tvalid(ps_cfg_valid),
    .cfg_tready(ps_cfg_ready),
    .group_tdata(group_tdata),
    .group_tvalid(group_tvalid && bias_loaded),
    .group_tready(ps_group_ready),
    .finish_tvalid(finish_tvalid),
    .finish_tready(finish_tready),
    .compute_done(ps_compute_done),
    .tile_tdata(ps_tile_data),
    .tile_tvalid(ps_tile_valid),
    .tile_tready(ps_tile_ready),
    .trace_valid(trace_event_tvalid),
    .trace_ready(trace_event_tready),
    .trace_slot(trace_slot), .trace_tag(trace_tag),
    .trace_payload(trace_payload),
    .trace_ack_valid(trace_ack_valid),
    .trace_ack_slot(trace_ack_slot),
    .trace_ack_tag(trace_ack_tag),
    .trace_ack_ok(trace_ack_ok),
    .numerical_error(ps_numeric),
    .first_error_rank(ps_rank),
    .first_bad_element(ps_bad_element),
    .first_error_detail(ps_detail),
    .protocol_error(ps_protocol),
    .groups_accepted(groups_accepted),
    .groups_retired(groups_retired),
    .groups_processed(groups_processed),
    .active_macs(active_macs),
    .result_free(result_free),
    .result_reserved(result_reserved),
    .result_returned(result_returned),
    .trace_free(trace_free));
  tm1tn8_bias_output bias_output (
    .clk(clk), .rst_n(rst_n),
    .cfg_tdata(compute_cfg_tdata),
    .cfg_tvalid(bias_cfg_valid),
    .cfg_tready(bias_cfg_ready),
    .bias_tdata(bias_tdata),
    .bias_tvalid(bias_tvalid),
    .bias_tready(bias_tready),
    .bias_loaded(bias_loaded),
    .tile_tdata(ps_tile_data),
    .tile_tvalid(ps_tile_valid),
    .tile_tready(ps_tile_ready),
    .out0_tdata(tile0_tdata),
    .out0_tvalid(tile0_tvalid),
    .out0_tready(tile0_tready),
    .out1_tdata(tile1_tdata),
    .out1_tvalid(tile1_tvalid),
    .out1_tready(tile1_tready),
    .drain_empty(bias_drain_empty),
    .command_done(completion_tvalid && completion_tready),
    .numerical_error(bias_numeric),
    .first_error_rank(bias_rank),
    .first_bad_element(bias_bad_element),
    .first_error_detail(bias_detail),
    .protocol_error(bias_protocol),
    .committed_elements(committed_elements));
  tm1tn8_writer_bridge writers (
    .clk(clk), .rst_n(rst_n),
    .tile0_tdata(tile0_tdata),
    .tile0_tvalid(tile0_tvalid),
    .tile0_tready(tile0_tready),
    .tile1_tdata(tile1_tdata),
    .tile1_tvalid(tile1_tvalid),
    .tile1_tready(tile1_tready),
    .finish_tvalid(writer_finish_valid),
    .finish_tready(writer_finish_ready),
    .completion_tdata(writer_completion_data),
    .completion_tvalid(writer_completion_valid),
    .completion_tready(completion_tready && trace_debt_zero),
    .all_writer_debt_zero(output_writer_debt_zero),
    .any_writer_fault(output_writer_fault),
    .*);
  tm1tn8_trace_axi32_writer trace_writer (
    .clk(clk), .rst_n(rst_n),
    .command_start(trace_command_start),
    .command_done(completion_tvalid && completion_tready),
    .observed_base(observed_base), .observed_span(observed_span),
    .trace_tdata(trace_event_tdata), .trace_tvalid(trace_event_tvalid),
    .trace_tready(trace_event_tready),
    .trace_ack_valid(trace_ack_valid), .trace_ack_slot(trace_ack_slot),
    .trace_ack_tag(trace_ack_tag), .trace_ack_ok(trace_ack_ok),
    .debt_zero(trace_debt_zero), .fault(trace_fault),
    .group_limit(6'd32),
    .aw_count(trace_aw_count), .w_count(trace_w_count),
    .b_count(trace_b_count),
    .m_axi_awaddr(observed_awaddr), .m_axi_awlen(observed_awlen),
    .m_axi_awsize(observed_awsize), .m_axi_awburst(observed_awburst),
    .m_axi_awvalid(observed_awvalid), .m_axi_awready(observed_awready),
    .m_axi_wdata(observed_wdata), .m_axi_wstrb(observed_wstrb),
    .m_axi_wlast(observed_wlast), .m_axi_wvalid(observed_wvalid),
    .m_axi_wready(observed_wready), .m_axi_bresp(observed_bresp),
    .m_axi_bvalid(observed_bvalid), .m_axi_bready(observed_bready));
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      flush_pending <= 0;
      trace_ack_count <= 0;
      trace_b_start <= 0;
    end else begin
      if (compute_cfg_tvalid && compute_cfg_tready) begin
        trace_ack_count <= 0;
        trace_b_start <= trace_b_count;
      end else if (trace_ack_valid && trace_ack_ok)
        trace_ack_count <= trace_ack_count + 1;
      if (ps_compute_done) flush_pending <= 1;
      if (writer_finish_valid && writer_finish_ready) flush_pending <= 0;
    end
  end
  assign writer_finish_valid = flush_pending && bias_drain_empty;
endmodule
