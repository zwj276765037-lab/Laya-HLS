`timescale 1ns/1ps

module t4_three_port_reader_short_tb;
  logic clk = 0;
  always #5 clk = ~clk;
  logic rst_n = 0, load_valid = 0;
  logic load_ready, load_done, load_error;
  logic [2:0][63:0] load_base, araddr;
  logic [2:0][31:0] load_bytes, committed_bytes, out_offset, out_epoch;
  logic [31:0] load_epoch;
  logic [2:0][7:0] arlen;
  logic [2:0][2:0] arsize;
  logic [2:0][1:0] arburst, rresp;
  logic [2:0] arvalid, arready, rlast, rvalid, rready;
  logic [2:0][511:0] rdata, out_data;
  logic [2:0][6:0] out_bytes;
  logic [2:0] out_last, out_valid, out_ready;
  logic [63:0] fixture_cfg [0:6];
  logic [511:0] q0 [0:127], q1 [0:127], scale [0:127];
  string case_dir;
  integer fault_port = -1;
  integer cycle = 0;
  integer requested [0:2];
  integer returned [0:2];
  integer delivered [0:2];
  integer bursts [0:2];
  integer read_index [0:2];
  integer beats_left [0:2];
  bit active [0:2];

  t4_three_port_reader_v1 dut (.cancel(1'b0),.*);

  function automatic logic [511:0] expected_beat(input int p, input int i);
    case (p)
      0: return q0[i];
      1: return q1[i];
      2: return scale[i];
      default: return 'x;
    endcase
  endfunction

  always_comb begin
    for (int p=0; p<3; p++) begin
      arready[p] = !active[p] && (cycle+p)%3 != 0;
      rvalid[p] = active[p] && (cycle+p)%5 != 0;
      rdata[p] = expected_beat(p, read_index[p]);
      rlast[p] = active[p] && beats_left[p] == 1;
      rresp[p] = (fault_port == p && read_index[p] == 5) ? 2'b10 : 2'b00;
      out_ready[p] = cycle > 180 && (cycle+p)%7 != 0;
    end
  end

  always @(posedge clk) begin : scoreboard
    int beats, remaining, page_beats, expected_total, expected_bursts;
    logic [511:0] expected;
    logic [127:0] scale_chunk;
    if (!rst_n) cycle <= 0;
    else begin
      cycle <= cycle + 1;
      for (int p=0; p<3; p++) begin
        if (arvalid[p] && arready[p]) begin
          if (active[p] || araddr[p] != load_base[p] + requested[p] ||
              arsize[p] != 3'd6 || arburst[p] != 2'b01)
            $fatal(1, "AR identity/protocol port=%0d cycle=%0d", p, cycle);
          remaining = (load_bytes[p] - requested[p]) / 64;
          page_beats = (4096 - int'(araddr[p] % 4096)) / 64;
          beats = remaining < 64 ? remaining : 64;
          if (beats > page_beats) beats = page_beats;
          if (beats <= 0 || arlen[p] + 1 != beats)
            $fatal(1, "AR burst split port=%0d len=%0d expected=%0d", p,
                   arlen[p]+1, beats);
          read_index[p] <= requested[p] / 64;
          beats_left[p] <= beats;
          requested[p] <= requested[p] + beats*64;
          bursts[p] <= bursts[p] + 1;
          active[p] <= 1;
        end
        if (rvalid[p] && rready[p]) begin
          if (!active[p] || beats_left[p] <= 0 ||
              rdata[p] !== expected_beat(p, read_index[p]) ||
              rlast[p] != (beats_left[p] == 1))
            $fatal(1, "R data/order/last port=%0d index=%0d", p,
                   read_index[p]);
          read_index[p] <= read_index[p] + 1;
          beats_left[p] <= beats_left[p] - 1;
          returned[p] <= returned[p] + 64;
          if (rlast[p]) active[p] <= 0;
        end
        if (out_valid[p] && out_ready[p]) begin
          if (out_offset[p] != delivered[p] ||
              out_epoch[p] != load_epoch ||
              out_bytes[p] != (p == 2 ? 7'd16 : 7'd64) ||
              out_last[p] != (delivered[p] + int'(out_bytes[p]) == load_bytes[p]))
            $fatal(1, "output identity/coverage port=%0d offset=%0d", p,
                   out_offset[p]);
          expected = expected_beat(p, delivered[p] / 64);
          if (p == 2) begin
            scale_chunk = expected >> ((delivered[p] % 64) * 8);
            if (out_data[p][127:0] !== scale_chunk)
              $fatal(1, "scale byte mismatch offset=%0d", delivered[p]);
          end else if (out_data[p] !== expected)
            $fatal(1, "q byte mismatch port=%0d offset=%0d", p, delivered[p]);
          delivered[p] <= delivered[p] + int'(out_bytes[p]);
        end
      end
      if (load_done) begin
        for (int p=0; p<3; p++) begin
          expected_total = p == fault_port ? 4096 : int'(load_bytes[p]);
          expected_bursts = p == fault_port ? 1 : 2;
          if (requested[p] != expected_total ||
              returned[p] != expected_total ||
              delivered[p] != expected_total ||
              committed_bytes[p] != expected_total ||
              bursts[p] != expected_bursts)
            $fatal(1, "retirement bytes/bursts port=%0d ar=%0d r=%0d out=%0d bursts=%0d",
                   p, requested[p], returned[p], delivered[p], bursts[p]);
        end
        if (load_error != (fault_port >= 0))
          $fatal(1, "fault propagation expected=%0d got=%0d",
                 fault_port >= 0, load_error);
        $display("T4_THREE_PORT_READER_SHORT_PASS case=%s fault_port=%0d cycles=%0d q0_bursts=%0d q1_bursts=%0d scale_bursts=%0d",
                 case_dir, fault_port, cycle, bursts[0], bursts[1], bursts[2]);
        $finish;
      end
      if (cycle > 5000) $fatal(1, "reader timeout");
    end
  end

  initial begin
    if (!$value$plusargs("CASE_DIR=%s", case_dir))
      $fatal(1, "CASE_DIR is required");
    void'($value$plusargs("FAULT_PORT=%d", fault_port));
    if (fault_port < -1 || fault_port > 2) $fatal(1, "bad fault port");
    $readmemh({case_dir,"/config.hex"}, fixture_cfg);
    $readmemh({case_dir,"/q0.hex"}, q0);
    $readmemh({case_dir,"/q1.hex"}, q1);
    $readmemh({case_dir,"/scale.hex"}, scale);
    for (int p=0; p<3; p++) begin
      load_base[p] = fixture_cfg[p];
      load_bytes[p] = fixture_cfg[3+p][31:0];
      requested[p] = 0; returned[p] = 0; delivered[p] = 0;
      bursts[p] = 0; read_index[p] = 0; beats_left[p] = 0; active[p] = 0;
    end
    load_epoch = fixture_cfg[6][31:0];
    repeat (5) @(negedge clk);
    rst_n = 1;
    @(negedge clk);
    if (!load_ready) $fatal(1, "reader not ready after reset");
    load_valid = 1;
    @(negedge clk);
    load_valid = 0;
  end
endmodule
