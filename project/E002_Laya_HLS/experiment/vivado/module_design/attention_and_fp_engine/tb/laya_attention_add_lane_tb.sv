`timescale 1ns/1ps

// Fixed binary32 RNE expectations; the input values and expected bits are
// independent of the generated IP and are checked at actual valid returns.
module laya_attention_add_lane_tb;
  logic clk = 0;
  always #5 clk = ~clk;
  logic rst_n = 0, avalid = 0, bvalid = 0, out_valid;
  logic [31:0] a = 0, b = 0, result;
  int cycle = 0, sent = 0, received = 0, first_accept = -1;
  int first_latency = -1, last_return_cycle = -1;

  laya_attention_fadd_lane_v2_ip dut (
    .aclk(clk), .aclken(1'b1), .aresetn(rst_n),
    .s_axis_a_tvalid(avalid), .s_axis_a_tdata(a),
    .s_axis_b_tvalid(bvalid), .s_axis_b_tdata(b),
    .m_axis_result_tvalid(out_valid), .m_axis_result_tdata(result)
  );

  function automatic logic [31:0] arg_a(input int k);
    case (k % 10)
      0: arg_a = 32'h3f800000; // 1
      1: arg_a = 32'hbf800000; // -1
      2: arg_a = 32'h80000000; // -0
      3: arg_a = 32'h00000000; // +0
      4: arg_a = 32'h3f000000; // 0.5
      5: arg_a = 32'h3f800000; // 1
      6: arg_a = 32'h3f800000; // 1
      7: arg_a = 32'h00800000; // min normal
      8: arg_a = 32'h00000001; // min subnormal
      default: arg_a = 32'h007fffff; // max subnormal
    endcase
  endfunction
  function automatic logic [31:0] arg_b(input int k);
    case (k % 10)
      0: arg_b = 32'h40000000; // 2
      1: arg_b = 32'h3f800000; // 1
      2: arg_b = 32'h80000000; // -0
      3: arg_b = 32'h80000000; // -0
      4: arg_b = 32'h3e800000; // 0.25
      5: arg_b = 32'h33800000; // half-ULP tie
      6: arg_b = 32'h34000000; // one ULP
      7: arg_b = 32'h80800000; // -min normal
      8: arg_b = 32'h00000001; // min subnormal
      default: arg_b = 32'h00000001; // min subnormal
    endcase
  endfunction
  function automatic logic [31:0] expected(input int k);
    case (k % 10)
      0: expected = 32'h40400000;
      1: expected = 32'h00000000;
      2: expected = 32'h80000000;
      3: expected = 32'h00000000;
      4: expected = 32'h3f400000;
      5: expected = 32'h3f800000;
      6: expected = 32'h3f800001;
      7: expected = 32'h00000000;
      8: expected = 32'h00000002;
      default: expected = 32'h00800000;
    endcase
  endfunction

  initial begin
    repeat(5) @(negedge clk);
    rst_n = 1;
    for (int k = 0; k < 20; k++) begin
      @(negedge clk);
      avalid = 1; bvalid = 1;
      a = arg_a(k); b = arg_b(k);
      @(posedge clk);
      if (k > 0 && sent != k)
        $fatal(1, "ADD_INPUT_GAP k=%0d sent=%0d", k, sent);
    end
    @(negedge clk); avalid = 0; bvalid = 0;
    wait (received == 20);
    repeat(10) @(negedge clk);
    if (first_latency != 8 || received != 20)
      $fatal(1, "ADD_LATENCY_OR_COUNT latency=%0d received=%0d", first_latency, received);
    $display("ADD_LANE_PASS count=20 ii=1 first_latency=%0d", first_latency);
    $finish;
  end

  always @(posedge clk) begin
    cycle <= cycle + 1;
    if (cycle > 100) $fatal(1, "ADD_TIMEOUT");
    if (rst_n && avalid && bvalid) begin
      if (first_accept < 0) first_accept <= cycle;
      sent <= sent + 1;
    end
    if (rst_n && out_valid) begin
      if (received >= sent || received >= 20 || result !== expected(received))
        $fatal(1, "ADD_RESULT index=%0d got=%h expected=%h sent=%0d",
               received, result, expected(received), sent);
      if (last_return_cycle >= 0 && cycle != last_return_cycle + 1)
        $fatal(1, "ADD_OUTPUT_GAP index=%0d cycle=%0d previous=%0d",
               received, cycle, last_return_cycle);
      if (first_latency < 0) first_latency <= cycle - first_accept;
      last_return_cycle <= cycle;
      received <= received + 1;
    end
  end
endmodule
