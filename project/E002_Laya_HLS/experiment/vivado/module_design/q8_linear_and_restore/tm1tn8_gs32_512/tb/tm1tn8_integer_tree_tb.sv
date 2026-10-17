`timescale 1ns/1ps

module tm1tn8_integer_tree_tb;
  localparam int TAG_W = 160;
  localparam int TEST_CYCLES = 144;
  logic clk = 1'b0;
  always #5 clk = ~clk;
  logic rst_n = 1'b0;
  logic req_valid;
  logic req_ready;
  logic [TAG_W-1:0] req_tag;
  logic [255:0] req_old_ps;
  logic [255:0] req_a;
  logic [2047:0] req_w;
  logic ret_valid;
  logic [TAG_W-1:0] ret_tag;
  logic [255:0] ret_old_ps;
  logic [167:0] ret_dot21;

  tm1tn8_integer_tree #(.TAG_W(TAG_W)) dut (.*);

  bit expected_valid [0:TEST_CYCLES];
  logic [TAG_W-1:0] expected_tag [0:TEST_CYCLES];
  logic [255:0] expected_ps [0:TEST_CYCLES];
  integer signed expected_dot [0:TEST_CYCLES][0:7];
  integer signed av, wv, dot, got;
  integer checks = 0;

  initial begin
    req_valid = 0;
    req_tag = '0;
    req_old_ps = '0;
    req_a = '0;
    req_w = '0;
    for (int c = 0; c <= TEST_CYCLES; c++)
      expected_valid[c] = 0;
    repeat (3) @(posedge clk);
    #1;
    if (ret_valid !== 1'b0) $fatal(1, "reset valid");
    rst_n = 1;

    for (int c = 0; c < TEST_CYCLES; c++) begin
      @(negedge clk);
      req_valid = (c < TEST_CYCLES - 8) && ((c % 7) != 3);
      req_tag = c * 73 + 17;
      req_old_ps = '0;
      for (int lane = 0; lane < 8; lane++)
        req_old_ps[lane*32 +: 32] = c * 1021 + lane * 29;
      for (int k = 0; k < 32; k++) begin
        case (c % 4)
          0: av = -128;
          1: av = 127;
          2: av = 0;
          default: av = ((c * 17 + k * 29) % 256) - 128;
        endcase
        req_a[k*8 +: 8] = av[7:0];
      end
      for (int lane = 0; lane < 8; lane++) begin
        dot = 0;
        for (int k = 0; k < 32; k++) begin
          case ((c + lane) % 4)
            0: wv = -128;
            1: wv = -127;
            2: wv = 127;
            default: wv = ((c * 11 + lane * 43 + k * 37) % 256) - 128;
          endcase
          req_w[lane*256 + k*8 +: 8] = wv[7:0];
          av = $signed(req_a[k*8 +: 8]);
          dot = dot + av * wv;
        end
        if (req_valid) expected_dot[c+5][lane] = dot;
      end
      if (req_valid) begin
        if (!req_ready) $fatal(1, "unexpected backpressure");
        expected_valid[c+5] = 1;
        expected_tag[c+5] = req_tag;
        expected_ps[c+5] = req_old_ps;
      end
      @(posedge clk);
      #1;
      if (ret_valid !== expected_valid[c])
        $fatal(1, "valid cycle=%0d got=%b expected=%b", c, ret_valid,
               expected_valid[c]);
      if (expected_valid[c]) begin
        if (ret_tag !== expected_tag[c] || ret_old_ps !== expected_ps[c])
          $fatal(1, "tag/oldPS cycle=%0d", c);
        for (int lane = 0; lane < 8; lane++) begin
          got = $signed(ret_dot21[lane*21 +: 21]);
          if (got !== expected_dot[c][lane])
            $fatal(1, "dot cycle=%0d lane=%0d got=%0d expected=%0d",
                   c, lane, got, expected_dot[c][lane]);
          checks++;
        end
      end
    end
    $display("TM1TN8_INTEGER_TREE_PASS checked_lanes=%0d", checks);
    $finish;
  end
endmodule
