`timescale 1ns/1ps

module tm1tn8_integer_real_replay_tb;
  localparam int TAG_W = 160;
  localparam int ISSUES = 136;
  localparam int CYCLES = ISSUES + 8;
  logic clk = 0;
  always #5 clk = ~clk;
  logic rst_n = 0;
  logic req_valid;
  logic [2:0] req_ready, ret_valid;
  logic [TAG_W-1:0] req_tag;
  logic [255:0] req_old_ps, req_a;
  logic [2047:0] req_w;
  logic [TAG_W-1:0] ret_tag [0:2];
  logic [255:0] ret_old_ps [0:2];
  logic [167:0] ret_dot21 [0:2];

  tm1tn8_integer_tree #(.TAG_W(TAG_W)) baseline (
    .clk, .rst_n, .req_valid, .req_ready(req_ready[0]),
    .req_tag, .req_old_ps, .req_a, .req_w,
    .ret_valid(ret_valid[0]), .ret_tag(ret_tag[0]),
    .ret_old_ps(ret_old_ps[0]), .ret_dot21(ret_dot21[0]));
  tm1tn8_integer_tree_lut #(.TAG_W(TAG_W)) lut_candidate (
    .clk, .rst_n, .req_valid, .req_ready(req_ready[1]),
    .req_tag, .req_old_ps, .req_a, .req_w,
    .ret_valid(ret_valid[1]), .ret_tag(ret_tag[1]),
    .ret_old_ps(ret_old_ps[1]), .ret_dot21(ret_dot21[1]));
  tm1tn8_integer_tree_packed #(.TAG_W(TAG_W)) packed_candidate (
    .clk, .rst_n, .req_valid, .req_ready(req_ready[2]),
    .req_tag, .req_old_ps, .req_a, .req_w,
    .ret_valid(ret_valid[2]), .ret_tag(ret_tag[2]),
    .ret_old_ps(ret_old_ps[2]), .ret_dot21(ret_dot21[2]));

  logic [255:0] va [0:ISSUES-1];
  logic [2047:0] vw [0:ISSUES-1];
  logic [7:0] vmask [0:ISSUES-1];
  logic [255:0] vdot [0:ISSUES-1];
  longint signed expected_dot [0:CYCLES+5][0:7];
  logic [TAG_W-1:0] expected_tag [0:CYCLES+5];
  logic [255:0] expected_ps [0:CYCLES+5];
  bit expected_valid [0:CYCLES+5];
  integer signed av, wv;
  longint signed dot, got;
  int checked = 0;
  string vec_dir;

  initial begin
    if (!$value$plusargs("VEC_DIR=%s", vec_dir)) $fatal(1, "missing VEC_DIR");
    $readmemh({vec_dir, "/a.hex"}, va);
    $readmemh({vec_dir, "/w.hex"}, vw);
    $readmemh({vec_dir, "/mask.hex"}, vmask);
    $readmemh({vec_dir, "/dot.hex"}, vdot);
    req_valid = 0;
    req_tag = '0;
    req_old_ps = '0;
    req_a = '0;
    req_w = '0;
    for (int c = 0; c <= CYCLES+5; c++) expected_valid[c] = 0;
    repeat (3) @(posedge clk);
    #1;
    if (ret_valid !== 3'b000) $fatal(1, "reset valid");
    rst_n = 1;
    #1;
    for (int c = 0; c < CYCLES; c++) begin
      @(negedge clk);
      req_valid = c < ISSUES;
      req_tag = {32'hff17_0000 + c, 32'h87a1_0000 ^ c,
                 32'hc930_0000 + c, 32'h0000_a950 ^ c, 32'h4071_8000 + c};
      for (int lane = 0; lane < 8; lane++)
        req_old_ps[lane*32 +: 32] = 32'h9ace_0000 ^ (c * 37 + lane);
      req_a = req_valid ? va[c] : '0;
      req_w = req_valid ? vw[c] : '0;
      #1;
      if (req_ready !== 3'b111) $fatal(1, "real replay ready c=%0d", c);
      if (req_valid) begin
        expected_valid[c+5] = 1;
        expected_tag[c+5] = req_tag;
        expected_ps[c+5] = req_old_ps;
        for (int lane = 0; lane < 8; lane++) begin
          dot = 0;
          for (int k = 0; k < 32; k++) begin
            av = $signed(req_a[k*8 +: 8]);
            wv = $signed(req_w[lane*256 + k*8 +: 8]);
            dot += av * wv;
          end
          expected_dot[c+5][lane] = dot;
          if (vmask[c][lane] &&
              dot !== $signed(vdot[c][lane*32 +: 32]))
            $fatal(1, "real fixture dot c=%0d lane=%0d got=%0d fixture=%0d",
                   c, lane, dot, $signed(vdot[c][lane*32 +: 32]));
        end
      end
      @(posedge clk);
      #1;
      for (int m = 0; m < 3; m++) begin
        if (ret_valid[m] !== expected_valid[c])
          $fatal(1, "real replay valid c=%0d module=%0d", c, m);
        if (expected_valid[c]) begin
          if (ret_tag[m] !== expected_tag[c] ||
              ret_old_ps[m] !== expected_ps[c])
            $fatal(1, "real replay metadata c=%0d module=%0d", c, m);
          for (int lane = 0; lane < 8; lane++) begin
            got = $signed(ret_dot21[m][lane*21 +: 21]);
            if (got !== expected_dot[c][lane])
              $fatal(1, "real replay dot c=%0d module=%0d lane=%0d got=%0d expected=%0d",
                     c, m, lane, got, expected_dot[c][lane]);
            if (m != 0 && ret_dot21[m][lane*21 +: 21] !==
                          ret_dot21[0][lane*21 +: 21])
              $fatal(1, "real replay lockstep c=%0d module=%0d lane=%0d", c, m, lane);
            checked++;
          end
        end
      end
    end
    if (checked != ISSUES*3*8) $fatal(1, "real replay count=%0d", checked);
    $display("TM1TN8_INTEGER_REAL_REPLAY_PASS act=8 qkv=128 issues=%0d checked_lanes=%0d",
             ISSUES, checked);
    $finish;
  end
endmodule
