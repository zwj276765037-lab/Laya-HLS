`timescale 1ns/1ps
module tm1tn8_trace_axi32_writer_tb;
  logic clk=0;
  always #5 clk=~clk;
  logic rst_n, command_start, command_done;
  logic [63:0] observed_base, observed_span;
  logic [5:0] group_limit;
  logic [415:0] trace_tdata;
  logic trace_tvalid, trace_tready;
  logic trace_ack_valid, trace_ack_ok, debt_zero, fault;
  logic [1:0] trace_ack_slot;
  logic [159:0] trace_ack_tag;
  logic [31:0] aw_count, w_count, b_count;
  logic [63:0] m_axi_awaddr;
  logic [7:0] m_axi_awlen;
  logic [2:0] m_axi_awsize;
  logic [1:0] m_axi_awburst;
  logic m_axi_awvalid, m_axi_awready;
  logic [31:0] m_axi_wdata;
  logic [3:0] m_axi_wstrb;
  logic m_axi_wlast, m_axi_wvalid, m_axi_wready;
  logic [1:0] m_axi_bresp;
  logic m_axi_bvalid, m_axi_bready;
  logic [159:0] owner_tag;
  localparam logic [63:0] BASE=64'h0000_0001_0000_1000;
  localparam logic [5:0] GROUP=6'd7;
  int aw_seen, w_seen, b_seen;
  tm1tn8_trace_axi32_writer dut (.*);

  initial begin : test
    int timeout;
    rst_n=0; command_start=0; command_done=0;
    observed_base=BASE; observed_span=64'd131072; group_limit=6'd8;
    trace_tdata=0; trace_tvalid=0;
    m_axi_awready=0; m_axi_wready=0;
    m_axi_bvalid=0; m_axi_bresp=0;
    aw_seen=0; w_seen=0; b_seen=0;
    owner_tag=160'h48_1234_5678_9abc_def0;
    owner_tag[16:11]=GROUP;
    owner_tag[7]=1;
    owner_tag[6:5]=2;
    repeat (3) @(negedge clk);
    rst_n=1;
    command_start=1;
    @(negedge clk); command_start=0;
    if (!trace_tready || !debt_zero || fault)
      $fatal(1,"trace writer start");
    trace_tdata={owner_tag,256'h0800_0007_4000_0000_3f80_0000_3f00_0000_3e80_0000_3f80_0000_0000_0000_ffff_ff80};
    trace_tvalid=1;
    @(negedge clk); trace_tvalid=0;
    if (trace_tready || debt_zero) $fatal(1,"trace event was not held");
    for (int word=0; word<8; word++) begin
      timeout=0;
      while (!m_axi_awvalid) begin
        @(negedge clk);
        if (++timeout>15) $fatal(1,"AW timeout word=%0d",word);
      end
      if (m_axi_awaddr !== BASE+64'd70656+64'(GROUP)*32+64'(word)*4 ||
          m_axi_awlen !== 0 || m_axi_awsize !== 2 ||
          m_axi_awburst !== 2'b01)
        $fatal(1,"AW address/control word=%0d",word);
      repeat (word%3+1) begin
        @(negedge clk);
        if (!m_axi_awvalid ||
            m_axi_awaddr !== BASE+64'd70656+64'(GROUP)*32+64'(word)*4)
          $fatal(1,"AW changed under backpressure word=%0d",word);
      end
      m_axi_awready=1;
      @(negedge clk); m_axi_awready=0; aw_seen++;
      timeout=0;
      while (!m_axi_wvalid) begin
        @(negedge clk);
        if (++timeout>15) $fatal(1,"W timeout word=%0d",word);
      end
      if (m_axi_wdata !== trace_tdata[word*32 +: 32] ||
          m_axi_wstrb !== 4'hf || !m_axi_wlast)
        $fatal(1,"W data/control word=%0d",word);
      repeat (2) begin
        @(negedge clk);
        if (!m_axi_wvalid ||
            m_axi_wdata !== trace_tdata[word*32 +: 32])
          $fatal(1,"W changed under backpressure word=%0d",word);
      end
      m_axi_wready=1;
      @(negedge clk); m_axi_wready=0; w_seen++;
      if (word==7) repeat (12) begin
        @(negedge clk);
        if (trace_ack_valid || debt_zero || !m_axi_bready ||
            b_count!==7)
          $fatal(1,"D4 released before eighth physical B");
      end
      m_axi_bvalid=1;
      @(negedge clk); m_axi_bvalid=0; b_seen++;
      if (word<7 && trace_ack_valid)
        $fatal(1,"early trace ACK word=%0d",word);
    end
    if (!trace_ack_valid || !trace_ack_ok ||
        trace_ack_slot!==2 || trace_ack_tag!==owner_tag ||
        aw_count!==8 || w_count!==8 || b_count!==8 || fault)
      $fatal(1,"eighth B terminal ACK/tag/count");
    @(negedge clk);
    if (!debt_zero || trace_ack_valid) $fatal(1,"trace drain");
    command_done=1;
    @(negedge clk); command_done=0;
    if (fault) $fatal(1,"trace writer completion fault");
    $display("TM1TN8_TRACE_AXI32_PASS aw=%0d w=%0d b=%0d",aw_seen,w_seen,b_seen);
    $finish;
  end
endmodule
