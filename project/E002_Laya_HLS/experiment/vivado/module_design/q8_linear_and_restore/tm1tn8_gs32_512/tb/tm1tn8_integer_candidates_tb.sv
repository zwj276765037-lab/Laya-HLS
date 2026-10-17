`timescale 1ns/1ps

module tm1tn8_integer_candidates_tb;
  localparam int TAG_W = 160;
  localparam int TEST_CYCLES = 1040;
  logic clk = 1'b0;
  always #5 clk = ~clk;

  logic rst_n = 1'b0;
  logic req_valid;
  logic [TAG_W-1:0] req_tag;
  logic [255:0] req_old_ps;
  logic [255:0] req_a;
  logic [2047:0] req_w;
  logic [2:0] req_ready;
  logic [2:0] ret_valid;
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

  logic signed [7:0] pair_a, pair_w0, pair_w1;
  logic signed [15:0] pair_p0, pair_p1;
  tm1tn8_signed_pack_pair pair_dut (
    .a(pair_a), .w0(pair_w0), .w1(pair_w1),
    .p0(pair_p0), .p1(pair_p1));

  bit expected_valid [0:TEST_CYCLES+5];
  logic [TAG_W-1:0] expected_tag [0:TEST_CYCLES+5];
  logic [255:0] expected_ps [0:TEST_CYCLES+5];
  longint signed expected_dot [0:TEST_CYCLES+5][0:7];
  longint signed dot, got;
  integer signed av, wv, pair_expected0, pair_expected1;
  logic [31:0] lfsr = 32'h8f19_c35a;
  int accepted = 0;
  int flushed = 0;
  int checked_lanes = 0;
  int checked_pairs = 0;

  initial begin
    req_valid = 0;
    req_tag = '0;
    req_old_ps = '0;
    req_a = '0;
    req_w = '0;
    pair_a = '0;
    pair_w0 = '0;
    pair_w1 = '0;
    for (int c = 0; c <= TEST_CYCLES+5; c++) expected_valid[c] = 0;
    repeat (3) @(posedge clk);
    #1;
    if (ret_valid !== 3'b000) $fatal(1, "reset valid");

    for (int c = 0; c < TEST_CYCLES; c++) begin
      @(negedge clk);
      rst_n = (c != 600 && c != 601);
      lfsr = {lfsr[30:0], lfsr[31] ^ lfsr[21] ^ lfsr[1] ^ lfsr[0]};
      req_valid = c < 256 || (c < 1024 && lfsr[2:0] != 3'b000);
      req_tag = {32'hf093_4d20 ^ c, 32'h59ae_1003 + c,
                 32'hd781_6642 ^ (c << 5), 32'h0123_ffff - c,
                 32'hc681_9a0b + (c << 1)};
      for (int lane = 0; lane < 8; lane++)
        req_old_ps[lane*32 +: 32] = (32'h8000_0000 ^ (c * 1021)) + lane * 29;
      for (int k = 0; k < 32; k++) begin
        av = ((c + 17*k) % 256) - 128;
        if (c % 43 == 0) av = -128;
        if (c % 43 == 1) av = 127;
        if (c % 43 == 2) av = 0;
        req_a[k*8 +: 8] = av[7:0];
      end
      for (int lane = 0; lane < 8; lane++) begin
        dot = 0;
        for (int k = 0; k < 32; k++) begin
          case ((c + lane + k) % 7)
            0: wv = -128;
            1: wv = 127;
            2: wv = 0;
            default: wv = ((c * 11 + lane * 43 + k * 37) % 256) - 128;
          endcase
          req_w[lane*256 + k*8 +: 8] = wv[7:0];
          av = $signed(req_a[k*8 +: 8]);
          dot += av * wv;
        end
        if (req_valid && rst_n) expected_dot[c+5][lane] = dot;
      end
      pair_a = (c % 256) - 128;
      case ((c / 256) % 4)
        0: begin pair_w0 = -128; pair_w1 = -128; end
        1: begin pair_w0 = -128; pair_w1 = 127; end
        2: begin pair_w0 = 127; pair_w1 = -128; end
        3: begin pair_w0 = 127; pair_w1 = 127; end
      endcase
      if (c >= 1024) begin
        pair_w0 = c % 2 ? 0 : -1;
        pair_w1 = c % 3 ? 1 : 0;
      end
      pair_expected0 = $signed(pair_a) * $signed(pair_w0);
      pair_expected1 = $signed(pair_a) * $signed(pair_w1);
      #1;  // Let reset-gated req_ready settle before the handshake check.
      if (!rst_n) begin
        for (int j = c; j <= c+5; j++) begin
          if (expected_valid[j]) flushed++;
          expected_valid[j] = 0;
        end
      end else if (req_valid) begin
        if (req_ready !== 3'b111) $fatal(1, "unexpected backpressure c=%0d", c);
        expected_valid[c+5] = 1;
        expected_tag[c+5] = req_tag;
        expected_ps[c+5] = req_old_ps;
        accepted++;
      end
      if (!rst_n && req_ready !== 3'b000)
        $fatal(1, "reset accepted request c=%0d", c);

      @(posedge clk);
      #1;
      if ($signed(pair_p0) !== pair_expected0 ||
          $signed(pair_p1) !== pair_expected1)
        $fatal(1, "pair c=%0d a=%0d w0=%0d w1=%0d got=%0d,%0d expected=%0d,%0d",
               c, pair_a, pair_w0, pair_w1, pair_p0, pair_p1,
               pair_expected0, pair_expected1);
      checked_pairs++;
      for (int m = 0; m < 3; m++) begin
        if (ret_valid[m] !== expected_valid[c])
          $fatal(1, "valid c=%0d module=%0d got=%b expected=%b",
                 c, m, ret_valid[m], expected_valid[c]);
        if (expected_valid[c]) begin
          if (ret_tag[m] !== expected_tag[c] ||
              ret_old_ps[m] !== expected_ps[c])
            $fatal(1, "tag/oldPS c=%0d module=%0d", c, m);
          for (int lane = 0; lane < 8; lane++) begin
            got = $signed(ret_dot21[m][lane*21 +: 21]);
            if (got !== expected_dot[c][lane])
              $fatal(1, "dot c=%0d module=%0d lane=%0d got=%0d expected=%0d",
                     c, m, lane, got, expected_dot[c][lane]);
            if (m != 0 && ret_dot21[m][lane*21 +: 21] !==
                          ret_dot21[0][lane*21 +: 21])
              $fatal(1, "lockstep c=%0d module=%0d lane=%0d", c, m, lane);
            checked_lanes++;
          end
        end
      end
    end
    if (accepted < 256 || checked_pairs != TEST_CYCLES ||
        checked_lanes < 3*8*256 || accepted != checked_lanes/(3*8) + flushed)
      $fatal(1, "coverage accepted=%0d returned=%0d flushed=%0d pairs=%0d",
             accepted, checked_lanes/(3*8), flushed, checked_pairs);
    $display("TM1TN8_INTEGER_CANDIDATES_PASS accepted=%0d returned=%0d flushed=%0d checked_lanes=%0d checked_pairs=%0d",
             accepted, checked_lanes/(3*8), flushed, checked_lanes, checked_pairs);
    $finish;
  end
endmodule
