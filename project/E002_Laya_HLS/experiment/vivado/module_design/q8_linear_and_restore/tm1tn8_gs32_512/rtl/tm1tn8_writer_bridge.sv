`timescale 1ns/1ps

// Couples HLS tile streams to the two physical 512-bit writers. The completion
// stream is withheld until both physical B channels have retired and both
// writer packs are empty. One writer configuration/finish pair per command.
module tm1tn8_writer_bridge (
  input  logic          clk,
  input  logic          rst_n,
  input  logic [255:0]  cfg_tdata,
  input  logic          cfg_tvalid,
  output logic          cfg_tready,
  input  logic [287:0]  tile0_tdata,
  input  logic          tile0_tvalid,
  output logic          tile0_tready,
  input  logic [287:0]  tile1_tdata,
  input  logic          tile1_tvalid,
  output logic          tile1_tready,
  input  logic          finish_tvalid,
  output logic          finish_tready,
  output logic [128:0]  completion_tdata,
  output logic          completion_tvalid,
  input  logic          completion_tready,
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
  logic configured, draining, done0, done1;
  logic [63:0] base0, span0, base1, span1;
  logic [63:0] start_phy0, start_phy1;
  logic [63:0] phy0, phy1, useful0, useful1;
  logic [31:0] aw0, w0, b0, aw1, w1, b1;
  logic ready0, ready1, flush0, flush1, debt0, debt1, fault0, fault1;
  logic done_now0, done_now1;

  assign cfg_tready = !configured && !completion_tvalid;
  assign finish_tready = configured && !draining && !completion_tvalid;
  assign tile0_tready = configured && !draining && ready0;
  assign tile1_tready = configured && !draining && ready1;
  assign done_now0 = done0 || flush0 || (fault0 && debt0);
  assign done_now1 = done1 || flush1 || (fault1 && debt1);
  assign all_writer_debt_zero = debt0 && debt1 && !draining;
  assign any_writer_fault = fault0 || fault1;

  tm1tn8_axi512_writer #(.SHARD(1'b0)) writer0 (
    .clk(clk), .rst_n(rst_n),
    .tile_valid(tile0_tvalid && configured && !draining),
    .tile_ready(ready0), .tile_f32(tile0_tdata[255:0]),
    .tile_n0(tile0_tdata[267:256]),
    .tile_row_local(tile0_tdata[269:268]),
    .tile_row0(tile0_tdata[279:270]), .tile_batch(tile0_tdata[280]),
    .tile_lanes(tile0_tdata[284:281]), .mode_qkv(tile0_tdata[285]),
    .rearm_valid(1'b0), .rearm_ready(),
    .flush_req(draining), .flush_done(flush0), .debt_zero(debt0),
    .output_base(base0), .output_span(span0), .fault(fault0),
    .aw_count(aw0), .w_count(w0), .b_count(b0),
    .useful_bytes(useful0), .physical_bytes(phy0),
    .m_axi_awaddr(m0_awaddr), .m_axi_awlen(m0_awlen),
    .m_axi_awsize(m0_awsize), .m_axi_awburst(m0_awburst),
    .m_axi_awvalid(m0_awvalid), .m_axi_awready(m0_awready),
    .m_axi_wdata(m0_wdata), .m_axi_wstrb(m0_wstrb),
    .m_axi_wlast(m0_wlast), .m_axi_wvalid(m0_wvalid),
    .m_axi_wready(m0_wready), .m_axi_bresp(m0_bresp),
    .m_axi_bvalid(m0_bvalid), .m_axi_bready(m0_bready));

  tm1tn8_axi512_writer #(.SHARD(1'b1)) writer1 (
    .clk(clk), .rst_n(rst_n),
    .tile_valid(tile1_tvalid && configured && !draining),
    .tile_ready(ready1), .tile_f32(tile1_tdata[255:0]),
    .tile_n0(tile1_tdata[267:256]),
    .tile_row_local(tile1_tdata[269:268]),
    .tile_row0(tile1_tdata[279:270]), .tile_batch(tile1_tdata[280]),
    .tile_lanes(tile1_tdata[284:281]), .mode_qkv(tile1_tdata[285]),
    .rearm_valid(1'b0), .rearm_ready(),
    .flush_req(draining), .flush_done(flush1), .debt_zero(debt1),
    .output_base(base1), .output_span(span1), .fault(fault1),
    .aw_count(aw1), .w_count(w1), .b_count(b1),
    .useful_bytes(useful1), .physical_bytes(phy1),
    .m_axi_awaddr(m1_awaddr), .m_axi_awlen(m1_awlen),
    .m_axi_awsize(m1_awsize), .m_axi_awburst(m1_awburst),
    .m_axi_awvalid(m1_awvalid), .m_axi_awready(m1_awready),
    .m_axi_wdata(m1_wdata), .m_axi_wstrb(m1_wstrb),
    .m_axi_wlast(m1_wlast), .m_axi_wvalid(m1_wvalid),
    .m_axi_wready(m1_wready), .m_axi_bresp(m1_bresp),
    .m_axi_bvalid(m1_bvalid), .m_axi_bready(m1_bready));

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      configured <= 1'b0;
      draining <= 1'b0;
      done0 <= 1'b0;
      done1 <= 1'b0;
      base0 <= '0;
      span0 <= '0;
      base1 <= '0;
      span1 <= '0;
      start_phy0 <= '0;
      start_phy1 <= '0;
      completion_tdata <= '0;
      completion_tvalid <= 1'b0;
    end else begin
      if (cfg_tvalid && cfg_tready) begin
        base0 <= cfg_tdata[63:0];
        span0 <= cfg_tdata[127:64];
        base1 <= cfg_tdata[191:128];
        span1 <= cfg_tdata[255:192];
        start_phy0 <= phy0;
        start_phy1 <= phy1;
        configured <= 1'b1;
      end
      if (finish_tvalid && finish_tready) begin
        draining <= 1'b1;
        done0 <= 1'b0;
        done1 <= 1'b0;
      end
      if (draining) begin
        done0 <= done_now0;
        done1 <= done_now1;
        if (done_now0 && done_now1) begin
          completion_tdata[0] <= fault0 || fault1 ||
                                 aw0 != w0 || w0 != b0 ||
                                 aw1 != w1 || w1 != b1;
          completion_tdata[64:1] <= phy0 - start_phy0;
          completion_tdata[128:65] <= phy1 - start_phy1;
          completion_tvalid <= 1'b1;
          draining <= 1'b0;
        end
      end
      if (completion_tvalid && completion_tready) begin
        completion_tvalid <= 1'b0;
        configured <= 1'b0;
      end
    end
  end
endmodule
