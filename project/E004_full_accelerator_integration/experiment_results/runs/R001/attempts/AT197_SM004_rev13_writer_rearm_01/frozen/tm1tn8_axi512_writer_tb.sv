`timescale 1ns/1ps

module tm1tn8_axi512_writer_tb;
  logic clk = 1'b0;
  always #5 clk = ~clk;
  logic rst_n, tile_valid, tile_ready, tile_batch, mode_qkv;
  logic [255:0] tile_f32;
  logic [11:0] tile_n0;
  logic [1:0] tile_row_local;
  logic [9:0] tile_row0;
  logic [3:0] tile_lanes;
  logic flush_req, flush_done, debt_zero, fault;
  logic rearm_valid = 1'b0, rearm_ready;
  logic [63:0] output_base, output_span;
  logic [31:0] aw_count, w_count, b_count;
  logic [63:0] useful_bytes, physical_bytes;
  logic [63:0] m_axi_awaddr;
  logic [7:0] m_axi_awlen;
  logic [2:0] m_axi_awsize;
  logic [1:0] m_axi_awburst;
  logic m_axi_awvalid, m_axi_awready;
  logic [511:0] m_axi_wdata;
  logic [63:0] m_axi_wstrb;
  logic m_axi_wlast, m_axi_wvalid, m_axi_wready;
  logic [1:0] m_axi_bresp;
  logic m_axi_bvalid, m_axi_bready;

  tm1tn8_axi512_writer #(.SHARD(1'b0)) dut (.*);

  logic [63:0] exp_addr [0:15], exp_strb [0:15];
  logic [511:0] exp_data [0:15];
  integer exp_n, aw_seen, w_seen, b_seen, cycle_count, b_delay;
  integer b_delay_setting, aw_block_until, w_block_until;
  logic saw_w_before_aw, saw_aw_before_w;
  logic pending_b;
  logic held_aw, held_w;
  logic [63:0] held_awaddr, held_wstrb;
  logic [511:0] held_wdata;

  task automatic add_expected_word(input logic [63:0] addr,
                                   input logic [31:0] bits);
    logic [63:0] aligned;
    integer index, slot;
    begin
      aligned = {addr[63:6], 6'b0};
      slot = -1;
      for (integer i = 0; i < exp_n; i++)
        if (exp_addr[i] == aligned) slot = i;
      if (slot < 0) begin
        slot = exp_n;
        if (slot > 15) $fatal(1, "expected queue overflow");
        exp_addr[slot] = aligned;
        exp_strb[slot] = '0;
        exp_data[slot] = '0;
        exp_n++;
      end
      index = addr[5:2];
      exp_strb[slot][index*4 +: 4] = 4'hf;
      exp_data[slot][index*32 +: 32] = bits;
    end
  endtask

  task automatic reset_case(input logic [63:0] base, span,
                            input logic qkv);
    begin
      @(negedge clk);
      rst_n = 0;
      tile_valid = 0;
      rearm_valid = 0;
      flush_req = 0;
      tile_f32 = '0;
      tile_n0 = 0;
      tile_row_local = 0;
      tile_row0 = 0;
      tile_batch = 0;
      tile_lanes = 0;
      mode_qkv = qkv;
      output_base = base;
      output_span = span;
      m_axi_bresp = 0;
      exp_n = 0;
      aw_seen = 0;
      w_seen = 0;
      b_seen = 0;
      pending_b = 0;
      b_delay = 0;
      b_delay_setting = 9;
      aw_block_until = 0;
      w_block_until = 0;
      saw_w_before_aw = 0;
      saw_aw_before_w = 0;
      held_aw = 0;
      held_w = 0;
      repeat (3) @(negedge clk);
      rst_n = 1;
    end
  endtask

  task automatic send_tile(input logic [11:0] n0,
                           input logic [3:0] count);
    logic [255:0] payload;
    integer col, plane, feature, head, d, relative;
    begin
      payload = '0;
      for (integer lane = 0; lane < 8; lane++)
        payload[lane*32 +: 32] = 32'h3f800000 + n0 + lane;
      @(negedge clk);
      while (!tile_ready) @(negedge clk);
      tile_n0 = n0;
      tile_lanes = count;
      tile_f32 = payload;
      tile_valid = 1;
      @(negedge clk);
      tile_valid = 0;
      for (integer lane = 0; lane < count; lane++) begin
        if (mode_qkv) begin
          col = n0 + lane;
          plane = col / 1024;
          feature = col % 1024;
          head = feature / 64;
          d = feature % 64;
          relative = (((((plane * 2 + tile_batch) * 8 + head/2) *
                         1024 + tile_row0 + tile_row_local) * 64) + d) * 4;
          add_expected_word(output_base + relative,
                            32'h3f800000 + n0 + lane);
        end else
          add_expected_word(output_base + (n0 + lane) * 4,
                            32'h3f800000 + n0 + lane);
      end
    end
  endtask

  task automatic finish_case(input integer expected_words);
    integer timeout;
    begin
      @(negedge clk);
      flush_req = 1;
      timeout = 0;
      do begin
        @(negedge clk);
        timeout++;
        if (timeout > 400) $fatal(1, "writer timeout");
      end while (!flush_done);
      flush_req = 0;
      if (fault || !debt_zero || exp_n != aw_seen || aw_seen != w_seen ||
          w_seen != b_seen || b_seen != aw_count ||
          aw_count != w_count || w_count != b_count ||
          useful_bytes != expected_words * 4 ||
          physical_bytes != exp_n * 64)
        $fatal(1, "writer terminal debt or byte counts");
    end
  endtask

  always @(negedge clk) begin
    if (rst_n) begin
      cycle_count = cycle_count + 1;
      m_axi_awready = cycle_count > aw_block_until &&
                       (cycle_count % 5 != 0);
      m_axi_wready = cycle_count > w_block_until &&
                      (cycle_count % 7 != 0);
      m_axi_bvalid = pending_b && b_delay == 0;
    end else begin
      cycle_count = 0;
      m_axi_awready = 0;
      m_axi_wready = 0;
      m_axi_bvalid = 0;
    end
  end

  always @(posedge clk) begin
    if (rst_n) begin
      if (held_aw && (!m_axi_awvalid || m_axi_awaddr !== held_awaddr))
        $fatal(1, "AW changed under backpressure");
      if (held_w && (!m_axi_wvalid || m_axi_wdata !== held_wdata ||
                     m_axi_wstrb !== held_wstrb))
        $fatal(1, "W changed under backpressure");
      held_aw = m_axi_awvalid && !m_axi_awready;
      held_w = m_axi_wvalid && !m_axi_wready;
      held_awaddr = m_axi_awaddr;
      held_wdata = m_axi_wdata;
      held_wstrb = m_axi_wstrb;
      if (m_axi_awvalid && m_axi_awready) begin
        if (w_seen > aw_seen) saw_w_before_aw = 1;
        if (aw_seen >= exp_n || m_axi_awaddr !== exp_addr[aw_seen] ||
            m_axi_awlen !== 0 || m_axi_awsize !== 6 ||
            m_axi_awburst !== 1 || m_axi_awaddr[11:0] > 12'd4032)
          $fatal(1, "AW addr/burst mismatch tx=%0d", aw_seen);
        aw_seen++;
      end
      if (m_axi_wvalid && m_axi_wready) begin
        if (aw_seen > w_seen && !(m_axi_awvalid && m_axi_awready))
          saw_aw_before_w = 1;
        if (w_seen >= exp_n || m_axi_wdata !== exp_data[w_seen] ||
            m_axi_wstrb !== exp_strb[w_seen] || m_axi_wlast !== 1)
          $fatal(1, "W data/STRB mismatch tx=%0d", w_seen);
        w_seen++;
        pending_b = 1;
        b_delay = b_delay_setting;
      end
      if (pending_b && b_delay > 0) b_delay--;
      if (m_axi_bvalid && m_axi_bready) begin
        if (b_seen >= w_seen) $fatal(1, "B before W");
        b_seen++;
        pending_b = 0;
      end
      if (flush_done && b_seen != w_seen)
        $fatal(1, "flush before B retirement");
    end
  end

  initial begin
    rst_n = 0;
    cycle_count = 0;
    reset_case(64'h1004, 8, 0);
    send_tile(0, 2);
    finish_case(2);
    if (exp_n != 1 || exp_strb[0] !== 64'h0000000000000ff0)
      $fatal(1, "ACT N2 tail WSTRB");

    reset_case(64'h2000, 12 * 1024 * 1024, 1);
    tile_row0 = 3;
    send_tile(0, 8);
    send_tile(8, 8);
    finish_case(16);
    if (exp_n != 1 || exp_strb[0] !== '1)
      $fatal(1, "aligned QKV two-tile pack");

    reset_case(64'h2004, 12 * 1024 * 1024, 1);
    tile_row0 = 3;
    send_tile(0, 8);
    send_tile(8, 8);
    finish_case(16);
    if (exp_n != 2 || exp_strb[0] !== 64'hfffffffffffffff0 ||
        exp_strb[1] !== 64'h000000000000000f)
      $fatal(1, "misaligned QKV two-beat pack");

    reset_case(64'h2cfc, 12 * 1024 * 1024, 1);
    tile_row0 = 3;
    send_tile(0, 8);
    send_tile(8, 8);
    finish_case(16);
    if (exp_n != 2 || exp_addr[0] !== 64'h2fc0 ||
        exp_addr[1] !== 64'h3000 ||
        exp_strb[0] !== 64'hf000000000000000 ||
        exp_strb[1] !== 64'h0fffffffffffffff)
      $fatal(1, "4 KiB boundary split and partial WSTRB");

    reset_case(64'h2000, 12 * 1024 * 1024, 1);
    tile_row0 = 3;
    b_delay_setting = 70;
    send_tile(0, 8);
    send_tile(8, 8);
    send_tile(16, 8);
    send_tile(24, 8);
    repeat (2) @(negedge clk);
    if (!dut.tx_valid || !dut.pack_valid)
      $fatal(1, "next pack did not fill while TX waited for B");
    rearm_valid = 1;
    if (rearm_ready) $fatal(1, "rearm accepted while TX/pack debt exists");
    @(negedge clk);
    rearm_valid = 0;
    send_tile(32, 8);
    repeat (3) begin
      @(negedge clk);
      if (tile_ready) $fatal(1, "third full beat bypassed TX/B capacity");
    end
    send_tile(40, 8);
    finish_case(48);
    if (exp_n != 3) $fatal(1, "three-beat pack count");

    reset_case(64'h2000, 12 * 1024 * 1024, 1);
    tile_row0 = 3;
    send_tile(0, 8);
    send_tile(8, 8);
    send_tile(128, 8);
    send_tile(136, 8);
    send_tile(1024, 8);
    send_tile(1032, 8);
    finish_case(48);
    if (exp_n != 3 || exp_addr[0] == exp_addr[1] ||
        exp_addr[1] == exp_addr[2])
      $fatal(1, "head/plane scatter pack count");

    reset_case(64'h2000, 12 * 1024 * 1024, 1);
    tile_row0 = 3;
    w_block_until = 35;
    send_tile(0, 8);
    send_tile(8, 8);
    finish_case(16);
    if (!saw_aw_before_w) $fatal(1, "AW-before-W not exercised");

    reset_case(64'h2000, 12 * 1024 * 1024, 1);
    tile_row0 = 3;
    aw_block_until = 35;
    send_tile(0, 8);
    send_tile(8, 8);
    finish_case(16);
    if (!saw_w_before_aw) $fatal(1, "W-before-AW not exercised");

    reset_case(64'h2000, 12 * 1024 * 1024, 1);
    tile_row0 = 3;
    b_delay_setting = 20;
    send_tile(0, 8);
    send_tile(8, 8);
    @(negedge clk);
    flush_req = 1;
    m_axi_bresp = 2;
    repeat (100) begin
      @(negedge clk);
      if (fault && debt_zero) break;
    end
    if (!fault || !debt_zero || flush_done || aw_count != 1 ||
        w_count != 1 || b_count != 1 || physical_bytes != 64 ||
        useful_bytes != 64)
      $fatal(1, "BRESP error did not drain physical TX debt");
    if (rearm_ready) $fatal(1, "rearm accepted while flush is requested");
    flush_req = 0;
    repeat (2) @(negedge clk);
    if (!rearm_ready) $fatal(1, "debt-free writer did not permit rearm");
    rearm_valid = 1;
    @(negedge clk);
    rearm_valid = 0;
    if (fault || aw_count || w_count || b_count || useful_bytes ||
        physical_bytes || !debt_zero)
      $fatal(1, "rearm did not clear row state and fault");
    exp_n = 0; aw_seen = 0; w_seen = 0; b_seen = 0;
    pending_b = 0; m_axi_bresp = 0; b_delay_setting = 0;
    send_tile(0, 8);
    send_tile(8, 8);
    finish_case(16);
    $display("TM1TN8_AXI512_WRITER_PASS cases=9 error_drain=1 rearm=1");
    $finish;
  end
endmodule
