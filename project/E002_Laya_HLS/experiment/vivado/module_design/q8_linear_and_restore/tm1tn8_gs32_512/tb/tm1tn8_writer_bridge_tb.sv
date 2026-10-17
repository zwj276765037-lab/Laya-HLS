`timescale 1ns/1ps

module tm1tn8_writer_bridge_tb;
  logic clk = 0;
  always #5 clk = ~clk;
  logic rst_n = 0;
  logic [255:0] cfg_tdata;
  logic cfg_tvalid, cfg_tready;
  logic [287:0] tile0_tdata, tile1_tdata;
  logic tile0_tvalid, tile0_tready, tile1_tvalid, tile1_tready;
  logic finish_tvalid, finish_tready;
  logic [128:0] completion_tdata;
  logic completion_tvalid, completion_tready;
  logic [63:0] m0_awaddr, m1_awaddr;
  logic [7:0] m0_awlen, m1_awlen;
  logic [2:0] m0_awsize, m1_awsize;
  logic [1:0] m0_awburst, m1_awburst;
  logic m0_awvalid, m1_awvalid, m0_awready, m1_awready;
  logic [511:0] m0_wdata, m1_wdata;
  logic [63:0] m0_wstrb, m1_wstrb;
  logic m0_wlast, m1_wlast, m0_wvalid, m1_wvalid;
  logic m0_wready, m1_wready;
  logic [1:0] m0_bresp, m1_bresp;
  logic m0_bvalid, m1_bvalid, m0_bready, m1_bready;
  logic all_writer_debt_zero, any_writer_fault;
  tm1tn8_writer_bridge dut (.*);

  integer cycles, b_delay0, b_delay1;
  integer aw0, w0, b0, aw1, w1, b1;
  logic pending0, pending1;
  logic [128:0] held_completion;

  initial begin
    #50000;
    $fatal(1, "bridge global watchdog cycles=%0d configured=%b draining=%b ready=%b/%b held=%b/%b pack=%b/%b tx=%b/%b fault=%b/%b",
           cycles,dut.configured,dut.draining,tile0_tready,tile1_tready,
           dut.writer0.held_valid,dut.writer1.held_valid,
           dut.writer0.pack_valid,dut.writer1.pack_valid,
           dut.writer0.tx_valid,dut.writer1.tx_valid,
           dut.writer0.fault,dut.writer1.fault);
  end

  always @(negedge clk) begin
    if (rst_n) begin
      cycles++;
      m0_awready = cycles % 3 != 0;
      m0_wready = cycles % 4 != 0;
      m1_awready = cycles % 5 != 0;
      m1_wready = cycles % 6 != 0;
      m0_bvalid = pending0 && b_delay0 == 0;
      m1_bvalid = pending1 && b_delay1 == 0;
    end else begin
      cycles = 0;
      m0_awready = 0;
      m0_wready = 0;
      m1_awready = 0;
      m1_wready = 0;
      m0_bvalid = 0;
      m1_bvalid = 0;
    end
  end

  always @(posedge clk) begin
    if (rst_n) begin
      if (m0_awvalid && m0_awready) begin
        if (m0_awlen != 0 || m0_awsize != 6 || m0_awaddr[5:0] != 0)
          $fatal(1, "out0 AW");
        aw0++;
      end
      if (m1_awvalid && m1_awready) begin
        if (m1_awlen != 0 || m1_awsize != 6 || m1_awaddr[5:0] != 0)
          $fatal(1, "out1 AW");
        aw1++;
      end
      if (m0_wvalid && m0_wready) begin
        if (!m0_wlast || m0_wstrb == 0) $fatal(1, "out0 W");
        w0++;
        pending0 = 1;
        b_delay0 = 25;
      end
      if (m1_wvalid && m1_wready) begin
        if (!m1_wlast || m1_wstrb == 0) $fatal(1, "out1 W");
        w1++;
        pending1 = 1;
        b_delay1 = 35;
      end
      if (pending0 && b_delay0 > 0) b_delay0--;
      if (pending1 && b_delay1 > 0) b_delay1--;
      if (m0_bvalid && m0_bready) begin b0++; pending0 = 0; end
      if (m1_bvalid && m1_bready) begin b1++; pending1 = 0; end
      if (completion_tvalid && (b0 != w0 || b1 != w1))
        $fatal(1, "completion before physical B");
    end
  end

  task automatic send_config(input logic [63:0] base0, span0,
                             input logic [63:0] base1, span1);
    begin
      @(negedge clk);
      while (!cfg_tready) @(negedge clk);
      cfg_tdata = {span1, base1, span0, base0};
      cfg_tvalid = 1;
      @(negedge clk);
      cfg_tvalid = 0;
      $display("BRIDGE_CFG_ACCEPT cycle=%0d",cycles);
    end
  endtask

  task automatic send_tile(input bit shard, input logic [11:0] n0,
                           input logic [3:0] lanes, input bit qkv);
    logic [287:0] packet;
    begin
      packet = '0;
      for (integer lane = 0; lane < 8; lane++)
        packet[lane*32 +: 32] = 32'h3f800000 + n0 + lane;
      packet[267:256] = n0;
      packet[269:268] = 0;
      packet[279:270] = 0;
      packet[280] = 0;
      packet[284:281] = lanes;
      packet[285] = qkv;
      @(negedge clk);
      if (shard) begin
        while (!tile1_tready) @(negedge clk);
        tile1_tdata = packet;
        tile1_tvalid = 1;
      end else begin
        while (!tile0_tready) @(negedge clk);
        tile0_tdata = packet;
        tile0_tvalid = 1;
      end
      @(negedge clk);
      tile0_tvalid = 0;
      tile1_tvalid = 0;
      $display("BRIDGE_TILE_ACCEPT cycle=%0d shard=%0d n0=%0d",cycles,shard,n0);
    end
  endtask

  task automatic finish_and_check(input logic [63:0] expected0,
                                  input logic [63:0] expected1);
    integer timeout;
    begin
      @(negedge clk);
      while (!finish_tready) @(negedge clk);
      finish_tvalid = 1;
      @(negedge clk);
      finish_tvalid = 0;
      $display("BRIDGE_FINISH_ACCEPT cycle=%0d",cycles);
      timeout = 0;
      while (!completion_tvalid) begin
        @(negedge clk);
        timeout++;
        if (timeout > 450) $fatal(1, "bridge completion timeout");
      end
      held_completion = completion_tdata;
      repeat (7) begin
        @(negedge clk);
        if (!completion_tvalid || completion_tdata !== held_completion)
          $fatal(1, "completion backpressure hold");
      end
      if (completion_tdata[0] || completion_tdata[64:1] !== expected0 ||
          completion_tdata[128:65] !== expected1 || any_writer_fault)
        $fatal(1, "completion status/physical byte count");
      completion_tready = 1;
      @(negedge clk);
      completion_tready = 0;
      if (!all_writer_debt_zero || aw0 != w0 || w0 != b0 ||
          aw1 != w1 || w1 != b1)
        $fatal(1, "bridge terminal debt");
    end
  endtask

  initial begin
    cfg_tdata = 0;
    cfg_tvalid = 0;
    tile0_tdata = 0;
    tile1_tdata = 0;
    tile0_tvalid = 0;
    tile1_tvalid = 0;
    finish_tvalid = 0;
    completion_tready = 0;
    m0_bresp = 0;
    m1_bresp = 0;
    pending0 = 0;
    pending1 = 0;
    b_delay0 = 0;
    b_delay1 = 0;
    aw0 = 0; w0 = 0; b0 = 0;
    aw1 = 0; w1 = 0; b1 = 0;
    repeat (4) @(negedge clk);
    rst_n = 1;
    send_config(64'h1004, 8, 0, 0);
    send_tile(0, 0, 2, 0);
    finish_and_check(64, 0);
    send_config(64'h2000, 12*1024*1024, 64'h3000, 12*1024*1024);
    send_tile(0, 0, 8, 1);
    send_tile(1, 64, 8, 1);
    finish_and_check(64, 64);
    $display("TM1TN8_WRITER_BRIDGE_PASS commands=2 B0=%0d B1=%0d", b0, b1);
    $finish;
  end
endmodule
