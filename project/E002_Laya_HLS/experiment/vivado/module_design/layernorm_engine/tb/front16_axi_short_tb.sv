`timescale 1ns/1ps
module front16_axi_short_tb;
  logic clk=0, rst_n=0, pressure=0;
  always #5 clk=~clk;
  logic AWVALID=0, AWREADY, AWID=0;
  logic [63:0] AWADDR=0;
  logic [7:0] AWLEN=0;
  logic [2:0] AWSIZE=2;
  logic [1:0] AWBURST=1;
  logic WVALID=0, WREADY, WLAST=1;
  logic [31:0] WDATA=32'h12345678;
  logic [3:0] WSTRB=4'hf;
  logic ARVALID=0, ARREADY, ARID=0;
  logic [63:0] ARADDR=0;
  logic [7:0] ARLEN=0;
  logic [2:0] ARSIZE=2;
  logic [1:0] ARBURST=1;
  logic RVALID, RREADY=1, RLAST, RID;
  logic [31:0] RDATA;
  logic [1:0] RRESP;
  logic BVALID, BREADY=1, BID;
  logic [1:0] BRESP;
  logic debt_zero;
  logic [31:0] ar_count,r_count,aw_count,w_count,b_count;
  logic [31:0] r_hold_hits,b_hold_hits,r_hold_cycles,b_hold_cycles;

  front16_axi_memory #(.DATA_W(32),.PORT_INDEX(2)) dut(
    .clk(clk),.rst_n(rst_n),.pressure(pressure),
    .AWVALID(AWVALID),.AWREADY(AWREADY),.AWADDR(AWADDR),.AWID(AWID),
    .AWLEN(AWLEN),.AWSIZE(AWSIZE),.AWBURST(AWBURST),
    .WVALID(WVALID),.WREADY(WREADY),.WDATA(WDATA),.WSTRB(WSTRB),.WLAST(WLAST),
    .ARVALID(ARVALID),.ARREADY(ARREADY),.ARADDR(ARADDR),.ARID(ARID),
    .ARLEN(ARLEN),.ARSIZE(ARSIZE),.ARBURST(ARBURST),
    .RVALID(RVALID),.RREADY(RREADY),.RDATA(RDATA),.RLAST(RLAST),.RID(RID),.RRESP(RRESP),
    .BVALID(BVALID),.BREADY(BREADY),.BRESP(BRESP),.BID(BID),
    .debt_zero(debt_zero),.ar_count(ar_count),.r_count(r_count),
    .aw_count(aw_count),.w_count(w_count),.b_count(b_count),
    .r_hold_hits(r_hold_hits),.b_hold_hits(b_hold_hits),
    .r_hold_cycles(r_hold_cycles),.b_hold_cycles(b_hold_cycles));

  task automatic tick;
    @(posedge clk); #1ps;
  endtask
  task automatic send_aw(input logic [63:0] address);
    @(negedge clk); AWADDR=address; AWVALID=1;
    if (!AWREADY) $fatal(1,"AW not ready for new transaction");
    tick();
    @(negedge clk); AWVALID=0;
  endtask
  task automatic send_w;
    @(negedge clk); WVALID=1; WLAST=1;
    if (!WREADY) $fatal(1,"W not ready for active AW");
    tick();
    @(negedge clk); WVALID=0;
  endtask
  task automatic take_b;
    if (!BVALID) $fatal(1,"B missing after final W");
    tick();
    if (!debt_zero) $fatal(1,"debt not retired after B");
  endtask

  initial begin
    repeat (4) @(negedge clk);
    rst_n=1;
    if ($test$plusargs("BAD_WLAST")) begin
      send_aw(0);
      @(negedge clk); WVALID=1; WLAST=0;
      tick();
      $fatal(1,"malformed WLAST escaped endpoint check");
    end

    // W appears before AW and remains stable while WREADY is low.
    @(negedge clk); WVALID=1; WLAST=1;
    if (WREADY) $fatal(1,"early W unexpectedly accepted");
    tick();
    @(negedge clk); AWVALID=1; AWADDR=0;
    tick();
    @(negedge clk); AWVALID=0;
    if (!WREADY) $fatal(1,"W did not become ready after AW");
    tick();
    @(negedge clk); WVALID=0;
    take_b();
    if (aw_count!=1 || w_count!=1 || b_count!=1)
      $fatal(1,"early-W transaction count mismatch");

    // A second AW is held stable while the first has outstanding W/B.
    send_aw(4);
    @(negedge clk); AWADDR=8; AWVALID=1;
    repeat (3) begin
      if (AWREADY) $fatal(1,"second AW accepted before first W/B retired");
      tick();
    end
    @(negedge clk); WVALID=1;
    tick();
    @(negedge clk); WVALID=0;
    if (AWREADY) $fatal(1,"second AW accepted before B");
    tick();
    @(negedge clk);
    if (!AWREADY) $fatal(1,"second AW still blocked after B");
    tick();
    @(negedge clk); AWVALID=0;
    send_w();
    take_b();
    if (aw_count!=3 || w_count!=3 || b_count!=3)
      $fatal(1,"independent AW/W count mismatch");

    // Reset an unfinished write and prove no old response survives.
    send_aw(12);
    if (debt_zero) $fatal(1,"unfinished AW has no debt");
    @(negedge clk); rst_n=0;
    repeat (3) tick();
    if (!debt_zero || BVALID) $fatal(1,"reset did not clear endpoint debt");
    @(negedge clk); rst_n=1;
    send_aw(16); send_w(); take_b();
    if (aw_count!=1 || w_count!=1 || b_count!=1)
      $fatal(1,"post-reset transaction count mismatch");
    $display("FRONT16_AXI_SHORT_PASS independent_AW_W=1 W_before_AW=1 AW_stall=1 reset_recovery=1");
    $finish;
  end
  initial begin #10000; $fatal(1,"short endpoint timeout"); end
endmodule
