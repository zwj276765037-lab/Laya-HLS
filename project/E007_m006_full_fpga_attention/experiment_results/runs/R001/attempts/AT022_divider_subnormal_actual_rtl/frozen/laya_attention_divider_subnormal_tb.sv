`timescale 1ns/1ps

// Independent exact binary32 cases for the generated 8-cycle direct divider.
module laya_attention_divider_subnormal_tb;
  logic clk = 0;
  always #5 clk = ~clk;
  logic avalid = 0, bvalid = 0, out_valid;
  logic [31:0] a = 0, b = 0, result;
  int cycle = 0, sent = 0, received = 0, first_accept = -1;
  int first_latency = -1, last_return_cycle = -1;

  laya_attention_fdiv_lane_v1_ip dut (
    .aclk(clk), .aclken(1'b1),
    .s_axis_a_tvalid(avalid), .s_axis_a_tdata(a),
    .s_axis_b_tvalid(bvalid), .s_axis_b_tdata(b),
    .m_axis_result_tvalid(out_valid), .m_axis_result_tdata(result)
  );

  function automatic logic [31:0] numerator(input int k);
    case (k % 8)
      0: numerator = 32'h3f800000; // 1 / 1
      1: numerator = 32'h3f800000; // 1 / 2
      2: numerator = 32'h40400000; // 3 / 2
      3: numerator = 32'h3f800000; // 1 / 3
      4: numerator = 32'h00800000; // min normal / 2
      5: numerator = 32'h00000001; // min subnormal / 1
      6: numerator = 32'h80800000; // -min normal / 2
      default: numerator = 32'h80000001; // -min subnormal / 1
    endcase
  endfunction
  function automatic logic [31:0] denominator(input int k);
    case (k % 8)
      0,5,7: denominator = 32'h3f800000;
      1,2,4,6: denominator = 32'h40000000;
      default: denominator = 32'h40400000;
    endcase
  endfunction
  function automatic logic [31:0] expected(input int k);
    case (k % 8)
      0: expected = 32'h3f800000;
      1: expected = 32'h3f000000;
      2: expected = 32'h3fc00000;
      3: expected = 32'h3eaaaaab;
      4: expected = 32'h00400000;
      5: expected = 32'h00000001;
      6: expected = 32'h80400000;
      default: expected = 32'h80000001;
    endcase
  endfunction

  initial begin
    repeat (5) @(negedge clk);
    for (int k = 0; k < 16; k++) begin
      @(negedge clk);
      avalid = 1; bvalid = 1;
      a = numerator(k); b = denominator(k);
      @(posedge clk);
      if (k > 0 && sent != k)
        $fatal(1, "DIV_INPUT_GAP k=%0d sent=%0d", k, sent);
    end
    @(negedge clk); avalid = 0; bvalid = 0;
    wait (received == 16);
    repeat (10) @(negedge clk);
    if (first_latency != 8 || received != 16)
      $fatal(1, "DIV_LATENCY_OR_COUNT latency=%0d received=%0d", first_latency, received);
    $display("DIV_SUBNORMAL_PASS count=16 latency=%0d", first_latency);
    $finish;
  end

  always @(posedge clk) begin
    cycle <= cycle + 1;
    if (cycle > 100) $fatal(1, "DIV_TIMEOUT");
    if (avalid && bvalid) begin
      if (first_accept < 0) first_accept <= cycle;
      sent <= sent + 1;
    end
    if (out_valid) begin
      if (received >= sent || received >= 16 || result !== expected(received))
        $fatal(1, "DIV_RESULT index=%0d got=%h expected=%h sent=%0d",
               received, result, expected(received), sent);
      if (last_return_cycle >= 0 && cycle != last_return_cycle + 1)
        $fatal(1, "DIV_OUTPUT_GAP index=%0d cycle=%0d previous=%0d",
               received, cycle, last_return_cycle);
      if (first_latency < 0) first_latency <= cycle - first_accept;
      last_return_cycle <= cycle;
      received <= received + 1;
    end
  end
endmodule
