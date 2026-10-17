`timescale 1ns/1ps
// Actual generated AXI pins -> finite timing adapters -> accepted static RAM.
// No generated DUT sideband is discarded: the complete request payload reaches
// the endpoint-side monitor even though the RAM itself uses only AXI fields.
module att_axi_port #(
    parameter int DATA_BITS = 32,
    parameter int PORT = 0,
    parameter int PAGE_COUNT = 1,
    parameter logic [PAGE_COUNT*64-1:0] PAGE_BASES = 64'h0
) (
    input logic clk, resetn,
    input logic [3:0][63:0] read_lo, read_hi,
    input logic [3:0][63:0] write_lo, write_hi,
    input logic hold_final_r, hold_final_b,
    output logic r_hold_applied, b_hold_applied,
    output logic [31:0] r_special_wait_cycles, b_special_wait_cycles,
    input logic awvalid,
    output logic awready,
    input logic [63:0] awaddr,
    input logic awid,
    input logic [7:0] awlen,
    input logic [2:0] awsize,
    input logic [1:0] awburst, awlock,
    input logic [3:0] awcache, awqos, awregion,
    input logic [2:0] awprot,
    input logic awuser,
    input logic wvalid,
    output logic wready,
    input logic [DATA_BITS-1:0] wdata,
    input logic [DATA_BITS/8-1:0] wstrb,
    input logic wlast, wid, wuser,
    output logic bvalid,
    input logic bready,
    output logic [1:0] bresp,
    output logic bid, buser,
    input logic arvalid,
    output logic arready,
    input logic [63:0] araddr,
    input logic arid,
    input logic [7:0] arlen,
    input logic [2:0] arsize,
    input logic [1:0] arburst, arlock,
    input logic [3:0] arcache, arqos, arregion,
    input logic [2:0] arprot,
    input logic aruser,
    output logic rvalid,
    input logic rready,
    output logic [DATA_BITS-1:0] rdata,
    output logic [1:0] rresp,
    output logic rlast, rid, ruser,
    output logic [31:0] dut_aw_count, dut_w_count, dut_b_count,
    output logic [31:0] dut_ar_count, dut_r_count, dut_rlast_count,
    output logic [63:0] dut_read_bus_bytes, dut_write_bus_bytes,
    output logic [63:0] dut_write_useful_bytes,
    output logic dut_write_pending, dut_read_pending,
    output logic [31:0] ram_aw_count, ram_w_count, ram_b_count,
    output logic [31:0] ram_ar_count, ram_r_count, ram_rlast_count,
    output logic [63:0] ram_read_bus_bytes, ram_write_bus_bytes,
    output logic [63:0] ram_write_useful_bytes,
    output logic ram_write_pending, ram_read_pending,
    output logic [118:0] ram_accepted_r_record,
    output logic [31:0] accepted [0:4], delivered [0:4]
);
  localparam int WB = DATA_BITS/8;
  localparam int A_PAYLOAD = 96;
  localparam int W_PAYLOAD = DATA_BITS+WB+3;
  localparam int R_PAYLOAD = DATA_BITS+5;
  logic e_awvalid,e_awready,e_wvalid,e_wready,e_bvalid,e_bready;
  logic e_arvalid,e_arready,e_rvalid,e_rready;
  logic [63:0] e_awaddr,e_araddr;
  logic e_awid,e_arid,e_wid,e_wlast,e_wuser;
  logic [7:0] e_awlen,e_arlen;
  logic [2:0] e_awsize,e_arsize,e_awprot,e_arprot;
  logic [1:0] e_awburst,e_arburst,e_awlock,e_arlock;
  logic [3:0] e_awcache,e_awqos,e_awregion;
  logic [3:0] e_arcache,e_arqos,e_arregion;
  logic e_awuser,e_aruser;
  logic [DATA_BITS-1:0] e_wdata,e_rdata;
  logic [WB-1:0] e_wstrb;
  logic [1:0] e_bresp,e_rresp;
  logic e_bid,e_buser,e_rid,e_rlast,e_ruser;
  logic [A_PAYLOAD-1:0] aw_packet, ar_packet;
  logic [W_PAYLOAD-1:0] w_packet;
  logic [3:0] b_packet;
  logic [R_PAYLOAD-1:0] r_packet;
  logic [118:0] dut_monitor_accepted_r_record, ram_monitor_accepted_r_record;
  logic port_reset_seen_posedge = 1'b0;
  logic port_reset_diag_emitted = 1'b0;
  logic port_first_r_diag_emitted = 1'b0;
  assign ram_accepted_r_record = ram_monitor_accepted_r_record;

  // Both observations occur after the monitor's positive-edge record update.
  // The reset witness requires a preceding reset positive edge, not time zero.
  always @(posedge clk) port_reset_seen_posedge <= !resetn;
  always @(negedge clk) begin
    if (!resetn) begin
      port_first_r_diag_emitted=1'b0;
      if (port_reset_seen_posedge && !port_reset_diag_emitted) begin
        if ($isunknown({dut_monitor_accepted_r_record,
                        ram_monitor_accepted_r_record,ram_accepted_r_record,
                        dut_r_count,ram_r_count}) ||
            dut_monitor_accepted_r_record !== 119'd0 ||
            ram_monitor_accepted_r_record !== 119'd0 ||
            ram_accepted_r_record !== 119'd0 ||
            dut_r_count !== 32'd0 || ram_r_count !== 32'd0)
          $fatal(1,"ATT_R_RECORD_PORT_RESET port=%0d",PORT);
        $display("ATT_R_RECORD_PORT_RESET port=%0d raw=%h count=%0d",
                 PORT,ram_accepted_r_record,ram_r_count);
        port_reset_diag_emitted=1'b1;
      end
    end else begin
      port_reset_diag_emitted=1'b0;
      if (!port_first_r_diag_emitted && ram_r_count !== 32'd0) begin
        if ($isunknown({ram_monitor_accepted_r_record,
                        ram_accepted_r_record,ram_r_count}) ||
            ram_r_count !== 32'd1 ||
            ram_accepted_r_record !== ram_monitor_accepted_r_record ||
            ram_accepted_r_record[118] !== 1'b1 ||
            ram_accepted_r_record[117:86] !== ram_r_count)
          $fatal(1,"ATT_R_RECORD_PORT_FIRST port=%0d",PORT);
        $display("ATT_R_RECORD_PORT_FIRST port=%0d raw=%h valid=%b ordinal=%0d addr=%h beat=%0d len=%0d size=%0d arid=%b rid=%b last=%b",
                 PORT,ram_accepted_r_record,ram_accepted_r_record[118],
                 ram_accepted_r_record[117:86],ram_accepted_r_record[85:22],
                 ram_accepted_r_record[21:14],ram_accepted_r_record[13:6],
                 ram_accepted_r_record[5:3],ram_accepted_r_record[2],
                 ram_accepted_r_record[1],ram_accepted_r_record[0]);
        port_first_r_diag_emitted=1'b1;
      end
    end
  end

  att_static_axi_stall #(.WIDTH(A_PAYLOAD),.SEED(17),.PORT(PORT),.CHANNEL(0)) aw_delay (
    .clk(clk),.resetn(resetn),.source_valid(awvalid),.source_ready(awready),
    .source_payload({awaddr,awid,awlen,awsize,awburst,awlock,awcache,
                     awprot,awqos,awregion,awuser}),
    .sink_valid(e_awvalid),.sink_ready(e_awready),.sink_payload(aw_packet),
    .add_final_hold(1'b0),.special_hold_applied(),.special_wait_cycles(),
    .accepted_count(accepted[0]),.delivered_count(delivered[0]));
  assign {e_awaddr,e_awid,e_awlen,e_awsize,e_awburst,e_awlock,e_awcache,
          e_awprot,e_awqos,e_awregion,e_awuser}=aw_packet;
  att_static_axi_stall #(.WIDTH(W_PAYLOAD),.SEED(19),.PORT(PORT),.CHANNEL(1)) w_delay (
    .clk(clk),.resetn(resetn),.source_valid(wvalid),.source_ready(wready),
    .source_payload({wdata,wstrb,wlast,wid,wuser}),
    .sink_valid(e_wvalid),.sink_ready(e_wready),.sink_payload(w_packet),
    .add_final_hold(1'b0),.special_hold_applied(),.special_wait_cycles(),
    .accepted_count(accepted[1]),.delivered_count(delivered[1]));
  assign {e_wdata,e_wstrb,e_wlast,e_wid,e_wuser}=w_packet;
  att_static_axi_stall #(.WIDTH(4),.SEED(23),.PORT(PORT),.CHANNEL(2)) b_delay (
    .clk(clk),.resetn(resetn),.source_valid(e_bvalid),.source_ready(e_bready),
    .source_payload({e_bid,e_bresp,e_buser}),
    .sink_valid(bvalid),.sink_ready(bready),.sink_payload(b_packet),
    .add_final_hold(hold_final_b),.special_hold_applied(b_hold_applied),
    .special_wait_cycles(b_special_wait_cycles),
    .accepted_count(accepted[2]),.delivered_count(delivered[2]));
  assign {bid,bresp,buser}=b_packet;
  att_static_axi_stall #(.WIDTH(A_PAYLOAD),.SEED(29),.PORT(PORT),.CHANNEL(3)) ar_delay (
    .clk(clk),.resetn(resetn),.source_valid(arvalid),.source_ready(arready),
    .source_payload({araddr,arid,arlen,arsize,arburst,arlock,arcache,
                     arprot,arqos,arregion,aruser}),
    .sink_valid(e_arvalid),.sink_ready(e_arready),.sink_payload(ar_packet),
    .add_final_hold(1'b0),.special_hold_applied(),.special_wait_cycles(),
    .accepted_count(accepted[3]),.delivered_count(delivered[3]));
  assign {e_araddr,e_arid,e_arlen,e_arsize,e_arburst,e_arlock,e_arcache,
          e_arprot,e_arqos,e_arregion,e_aruser}=ar_packet;
  att_static_axi_stall #(.WIDTH(R_PAYLOAD),.SEED(31),.PORT(PORT),.CHANNEL(4)) r_delay (
    .clk(clk),.resetn(resetn),.source_valid(e_rvalid),.source_ready(e_rready),
    .source_payload({e_rid,e_rdata,e_rresp,e_rlast,e_ruser}),
    .sink_valid(rvalid),.sink_ready(rready),.sink_payload(r_packet),
    .add_final_hold(hold_final_r),.special_hold_applied(r_hold_applied),
    .special_wait_cycles(r_special_wait_cycles),
    .accepted_count(accepted[4]),.delivered_count(delivered[4]));
  assign {rid,rdata,rresp,rlast,ruser}=r_packet;
  assign e_buser=1'b0;
  assign e_ruser=1'b0;

  axi_static_memory #(.DATA_BITS(DATA_BITS),.ADDR_BITS(64),.ID_BITS(1),
                      .PAGE_CAPACITY(PAGE_COUNT),.PAGE_BASES(PAGE_BASES)) u_mem (
    .aclk(clk),.aresetn(resetn),
    .awid(e_awid),.awaddr(e_awaddr),.awlen(e_awlen),.awsize(e_awsize),
    .awburst(e_awburst),.awvalid(e_awvalid),.awready(e_awready),
    .wid(e_wid),.wdata(e_wdata),.wstrb(e_wstrb),.wlast(e_wlast),
    .wvalid(e_wvalid),.wready(e_wready),
    .bid(e_bid),.bresp(e_bresp),.bvalid(e_bvalid),.bready(e_bready),
    .arid(e_arid),.araddr(e_araddr),.arlen(e_arlen),.arsize(e_arsize),
    .arburst(e_arburst),.arvalid(e_arvalid),.arready(e_arready),
    .rid(e_rid),.rdata(e_rdata),.rresp(e_rresp),.rlast(e_rlast),
    .rvalid(e_rvalid),.rready(e_rready));

  att_axi_monitor #(.DATA_BITS(DATA_BITS),.PORT(PORT),.SIDE(0)) dut_mon (
    .clk(clk),.resetn(resetn),.read_lo(read_lo),.read_hi(read_hi),
    .write_lo(write_lo),.write_hi(write_hi),
    .awvalid(awvalid),.awready(awready),.awaddr(awaddr),.awid(awid),
    .awlen(awlen),.awsize(awsize),.awburst(awburst),.awlock(awlock),
    .awcache(awcache),.awqos(awqos),.awregion(awregion),.awprot(awprot),
    .awuser(awuser),.wvalid(wvalid),.wready(wready),.wdata(wdata),
    .wstrb(wstrb),.wlast(wlast),.wid(wid),.wuser(wuser),
    .bvalid(bvalid),.bready(bready),.bresp(bresp),.bid(bid),.buser(buser),
    .arvalid(arvalid),.arready(arready),.araddr(araddr),.arid(arid),
    .arlen(arlen),.arsize(arsize),.arburst(arburst),.arlock(arlock),
    .arcache(arcache),.arqos(arqos),.arregion(arregion),.arprot(arprot),
    .aruser(aruser),.rvalid(rvalid),.rready(rready),.rdata(rdata),
    .rresp(rresp),.rlast(rlast),.rid(rid),.ruser(ruser),
    .aw_count(dut_aw_count),.w_count(dut_w_count),.b_count(dut_b_count),
    .ar_count(dut_ar_count),.r_count(dut_r_count),.rlast_count(dut_rlast_count),
    .read_bus_bytes(dut_read_bus_bytes),.write_bus_bytes(dut_write_bus_bytes),
    .write_useful_bytes(dut_write_useful_bytes),
    .write_pending(dut_write_pending),.read_pending(dut_read_pending),
    .accepted_r_record(dut_monitor_accepted_r_record));
  att_axi_monitor #(.DATA_BITS(DATA_BITS),.PORT(PORT),.SIDE(1)) ram_mon (
    .clk(clk),.resetn(resetn),.read_lo(read_lo),.read_hi(read_hi),
    .write_lo(write_lo),.write_hi(write_hi),
    .awvalid(e_awvalid),.awready(e_awready),.awaddr(e_awaddr),.awid(e_awid),
    .awlen(e_awlen),.awsize(e_awsize),.awburst(e_awburst),.awlock(e_awlock),
    .awcache(e_awcache),.awqos(e_awqos),.awregion(e_awregion),.awprot(e_awprot),
    .awuser(e_awuser),.wvalid(e_wvalid),.wready(e_wready),.wdata(e_wdata),
    .wstrb(e_wstrb),.wlast(e_wlast),.wid(e_wid),.wuser(e_wuser),
    .bvalid(e_bvalid),.bready(e_bready),.bresp(e_bresp),.bid(e_bid),
    .buser(e_buser),.arvalid(e_arvalid),.arready(e_arready),
    .araddr(e_araddr),.arid(e_arid),.arlen(e_arlen),.arsize(e_arsize),
    .arburst(e_arburst),.arlock(e_arlock),.arcache(e_arcache),
    .arqos(e_arqos),.arregion(e_arregion),.arprot(e_arprot),
    .aruser(e_aruser),.rvalid(e_rvalid),.rready(e_rready),.rdata(e_rdata),
    .rresp(e_rresp),.rlast(e_rlast),.rid(e_rid),.ruser(e_ruser),
    .aw_count(ram_aw_count),.w_count(ram_w_count),.b_count(ram_b_count),
    .ar_count(ram_ar_count),.r_count(ram_r_count),.rlast_count(ram_rlast_count),
    .read_bus_bytes(ram_read_bus_bytes),.write_bus_bytes(ram_write_bus_bytes),
    .write_useful_bytes(ram_write_useful_bytes),
    .write_pending(ram_write_pending),.read_pending(ram_read_pending),
    .accepted_r_record(ram_monitor_accepted_r_record));
endmodule
