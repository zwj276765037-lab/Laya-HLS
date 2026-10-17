`timescale 1ns/1ps
module r0_adapter_probe_top;
  import r0_fp_bits_pkg::*;
  logic clk = 1'b0;
  logic reset = 1'b0;
  logic ce = 1'b1;
  logic [31:0] din0 = 32'b0, din1 = 32'b0;
  logic [4:0] opcode = 5'd1;
  logic [1023:0] lanes_flat = 1024'b0;
  wire [31:0] scan_amax;
  wire [5:0] scan_bad;
  wire [31:0] out_div, out_mul2, out_mul3, out_add, out_sitofp;
  wire out_cmp1, out_cmp2;
  longint unsigned cycle_count = 0;
  int raw_fd;
  int mismatch_count = 0;
  int group_cases = 0;
  int scalar_cases = 0;
  int restore_cases = 0;
  int expected_group_cases = -1;
  int expected_scalar_cases = -1;
  int expected_restore_cases = -1;

  r0_group_bit_scan group_scan(.lanes_flat(lanes_flat),
                               .amax_bits(scan_amax), .first_bad(scan_bad));
  // The exact seven accepted HLS outer wrappers, not arithmetic behavioral stubs.
  q8_joint_tm4tn8_fdiv_32ns_32ns_32_8_no_dsp_1 dut_div
    (.clk(clk), .reset(reset), .ce(ce), .din0(din0), .din1(din1), .dout(out_div));
  q8_joint_tm4tn8_fmul_32ns_32ns_32_2_max_dsp_1 dut_mul2
    (.clk(clk), .reset(reset), .ce(ce), .din0(din0), .din1(din1), .dout(out_mul2));
  q8_joint_tm4tn8_fmul_32ns_32ns_32_3_max_dsp_1 dut_mul3
    (.clk(clk), .reset(reset), .ce(ce), .din0(din0), .din1(din1), .dout(out_mul3));
  q8_joint_tm4tn8_fadd_32ns_32ns_32_4_full_dsp_1 dut_add
    (.clk(clk), .reset(reset), .ce(ce), .din0(din0), .din1(din1), .dout(out_add));
  q8_joint_tm4tn8_sitofp_32ns_32_2_no_dsp_1 dut_sitofp
    (.clk(clk), .reset(reset), .ce(ce), .din0(din0), .dout(out_sitofp));
  q8_joint_tm4tn8_fcmp_32ns_32ns_1_1_no_dsp_1 dut_cmp1
    (.din0(din0), .din1(din1), .opcode(opcode), .dout(out_cmp1));
  q8_joint_tm4tn8_fcmp_32ns_32ns_1_2_no_dsp_1 dut_cmp2
    (.clk(clk), .reset(reset), .ce(ce), .din0(din0), .din1(din1),
     .opcode(opcode), .dout(out_cmp2));

  always #5ns clk = ~clk;
  always @(posedge clk) begin
    cycle_count <= cycle_count + 1;
    if (cycle_count > 500000) $fatal(1, "R0_ADAPTER_PROBE_WATCHDOG");
  end

  task automatic check32(input string id, field,
                         input logic [31:0] actual, expected);
    $fdisplay(raw_fd, "R0_RAW|case=%s|field=%s|actual=%08x|expected=%08x|cycle=%0d",
              id, field, actual, expected, cycle_count);
    $fflush(raw_fd);
    if ($isunknown(actual) || actual !== expected) mismatch_count++;
  endtask

  task automatic check16(input string id, field,
                         input logic [15:0] actual, expected);
    $fdisplay(raw_fd, "R0_RAW|case=%s|field=%s|actual=%04x|expected=%04x|cycle=%0d",
              id, field, actual, expected, cycle_count);
    $fflush(raw_fd);
    if ($isunknown(actual) || actual !== expected) mismatch_count++;
  endtask

  task automatic check2(input string id, field,
                        input logic [1:0] actual, expected);
    $fdisplay(raw_fd, "R0_RAW|case=%s|field=%s|actual=%b|expected=%b|cycle=%0d",
              id, field, actual, expected, cycle_count);
    $fflush(raw_fd);
    if ($isunknown(actual) || actual !== expected) mismatch_count++;
  endtask

  task automatic check1(input string id, field,
                        input logic actual, expected);
    $fdisplay(raw_fd, "R0_RAW|case=%s|field=%s|actual=%b|expected=%b|cycle=%0d",
              id, field, actual, expected, cycle_count);
    $fflush(raw_fd);
    if ($isunknown(actual) || actual !== expected) mismatch_count++;
  endtask

  task automatic hold_operands(input logic [31:0] a_bits, b_bits);
    @(negedge clk);
    din0 = a_bits;
    din1 = b_bits;
    opcode = 5'd1;
    repeat (32) @(posedge clk);
    #1ps;
  endtask

  task automatic sample_div(input string id, service,
                            input logic [31:0] a_bits, b_bits,
                            output logic [31:0] result);
    logic [31:0] first, second;
    hold_operands(a_bits, b_bits);
    first = out_div;
    @(posedge clk); #1ps; second = out_div;
    @(posedge clk); #1ps; result = out_div;
    check32(id, {service, "_stable_0"}, first, second);
    check32(id, {service, "_stable_1"}, second, result);
    check1(id, {service, "_valid"}, dut_div.r_tvalid, 1'b1);
  endtask

  task automatic sample_mul(input string id,
                            input logic [31:0] a_bits, b_bits,
                            output logic [31:0] product2, product3);
    logic [31:0] first2, second2, first3, second3;
    hold_operands(a_bits, b_bits);
    first2 = out_mul2;
    first3 = out_mul3;
    @(posedge clk); #1ps;
    second2 = out_mul2;
    second3 = out_mul3;
    @(posedge clk); #1ps;
    product2 = out_mul2;
    product3 = out_mul3;
    check32(id, "mul2_stable_0", first2, second2);
    check32(id, "mul2_stable_1", second2, product2);
    check32(id, "mul3_stable_0", first3, second3);
    check32(id, "mul3_stable_1", second3, product3);
    check1(id, "mul2_valid", dut_mul2.r_tvalid, 1'b1);
    check1(id, "mul3_valid", dut_mul3.r_tvalid, 1'b1);
  endtask

  task automatic sample_add(input string id,
                            input logic [31:0] a_bits, b_bits,
                            output logic [31:0] result);
    logic [31:0] first, second;
    hold_operands(a_bits, b_bits);
    first = out_add;
    @(posedge clk); #1ps; second = out_add;
    @(posedge clk); #1ps; result = out_add;
    check32(id, "adder_stable_0", first, second);
    check32(id, "adder_stable_1", second, result);
    check1(id, "adder_valid", dut_add.r_tvalid, 1'b1);
  endtask

  function automatic logic [15:0] original_half_rne(input logic [31:0] bits);
    logic [15:0] sign;
    logic [7:0] exponent;
    logic [31:0] mantissa, result, remainder, halfway;
    int signed half_exp;
    int unsigned shift;
    sign = {bits[31], 15'b0};
    exponent = bits[30:23];
    mantissa = {9'b0, bits[22:0]};
    if (exponent == 8'hff)
      return sign | (mantissa != 0 ? 16'h7e00 : 16'h7c00);
    half_exp = int'(exponent) - 127 + 15;
    if (half_exp >= 31) return sign | 16'h7c00;
    if (half_exp <= -11) return sign;
    if (half_exp <= 0) begin
      mantissa = mantissa | 32'h00800000;
      shift = 14 - half_exp;
      result = mantissa >> shift;
      remainder = mantissa & ((32'd1 << shift) - 1);
      halfway = 32'd1 << (shift - 1);
      if (remainder > halfway || (remainder == halfway && result[0])) result++;
      return sign | result[15:0];
    end
    result = (half_exp << 10) | (mantissa >> 13);
    remainder = mantissa & 32'h1fff;
    if (remainder > 32'h1000 || (remainder == 32'h1000 && result[0])) result++;
    return sign | result[15:0];
  endfunction

  function automatic int signed roundf_away_from_product(input logic [31:0] bits);
    int unsigned exponent, shift, significand, magnitude, remainder;
    exponent = bits[30:23];
    if (exponent == 255) return 1024;
    if (exponent <= 125) return 0;
    if (exponent >= 134) return bits[31] ? -128 : 128;
    shift = 150 - exponent;
    significand = 32'h00800000 | {9'b0, bits[22:0]};
    magnitude = significand >> shift;
    remainder = significand & ((32'd1 << shift) - 1);
    if (remainder >= (32'd1 << (shift - 1))) magnitude++;
    return bits[31] ? -int'(magnitude) : int'(magnitude);
  endfunction

  task automatic normal_wrapper_smoke;
    hold_operands(32'h3f800000, 32'h3f800000);
    check32("normal_wrapper_smoke", "div", out_div, 32'h3f800000);
    check32("normal_wrapper_smoke", "mul2", out_mul2, 32'h3f800000);
    check32("normal_wrapper_smoke", "mul3", out_mul3, 32'h3f800000);
    check32("normal_wrapper_smoke", "add", out_add, 32'h40000000);
    check1("normal_wrapper_smoke", "cmp1_eq", out_cmp1, 1'b1);
    check1("normal_wrapper_smoke", "cmp2_eq", out_cmp2, 1'b1);
    hold_operands(32'h00000001, 32'h3f800000);
    check32("normal_wrapper_smoke", "sitofp", out_sitofp, 32'h3f800000);
  endtask

  task automatic run_recip_scalar(
      input logic [31:0] d_bits, expected_divider_input,
      expected_normalized_result, expected_reciprocal,
      input logic expected_normalized, expected_d_zero);
    logic [31:0] divider_input, normalized_result, reciprocal;
    logic zero_at_reciprocal, zero_at_quantization, normalize;
    string id;
    id = $sformatf("recip_%08x", d_bits);
    zero_at_reciprocal = d_is_zero(d_bits);
    zero_at_quantization = d_is_zero(d_bits);
    check1(id, "d_is_zero_at_reciprocal", zero_at_reciprocal, expected_d_zero);
    check1(id, "d_is_zero_at_quantization", zero_at_quantization, expected_d_zero);
    normalize = is_subnormal(d_bits);
    check1(id, "normalize", normalize, expected_normalized);
    if (zero_at_reciprocal) begin
      divider_input = 0;
      normalized_result = 0;
      reciprocal = 0;
    end else begin
      divider_input = normalize ? subnormal_up24(d_bits) : d_bits;
      sample_div(id, "reciprocal_div", 32'h3f800000,
                 divider_input, normalized_result);
      reciprocal = normalize ? positive_normal_up24_or_inf(normalized_result) : normalized_result;
    end
    check32(id, "divider_input", divider_input, expected_divider_input);
    check32(id, "normalized_divider_result", normalized_result, expected_normalized_result);
    check32(id, "reciprocal", reciprocal, expected_reciprocal);
    scalar_cases++;
  endtask

  task automatic run_half_scalar(input logic [31:0] d_bits,
                                 input logic [15:0] expected_saved);
    check16($sformatf("half_%08x", d_bits), "saved_half",
            original_half_rne(d_bits), expected_saved);
    scalar_cases++;
  endtask

  task automatic run_restore(input string id,
      input logic [31:0] ps_bits, bias_bits,
      input logic [1:0] expected_route,
      input logic [31:0] expected_result);
    logic [1:0] route;
    logic [31:0] result;
    route = bias_route(ps_bits, bias_bits);
    check2(id, "bias_route", route, expected_route);
    if (route == 2'd3) begin
      check32(id, "outside_domain_ps", ps_bits, 32'h80000000);
    end else begin
      if (route == 2'd2) sample_add(id, ps_bits, bias_bits, result);
      else result = bias_direct_bits(ps_bits, bias_bits, route);
      check32(id, "restore_result", result, expected_result);
    end
    restore_cases++;
  endtask

  task automatic run_group(input string id,
      input logic [1023:0] input_lanes,
      input logic [31:0] expected_amax, expected_d, expected_reciprocal,
      input logic [15:0] expected_half,
      input logic expected_d_zero,
      input logic [31:0] expected_status,
      input logic signed [31:0] expected_bad,
      input logic expected_commit,
      input logic [255:0] expected_q,
      input logic [63:0] expected_routes,
      input logic [1023:0] expected_products,
      input logic [31:0] expected_product_mask);
    logic [31:0] amax, d_bits, reciprocal_bits, normalized_result, div_input;
    logic [31:0] x_bits, product2, product3;
    logic [15:0] saved_half;
    logic zero_reciprocal, zero_quantization;
    logic [1:0] route;
    logic [255:0] observed_q;
    int signed rounded;
    int unsigned status, bad;
    bit committed;
    string lane_id;
    lanes_flat = input_lanes;
    #1ps;
    observed_q = 256'b0;
    status = 0;
    bad = 32'hffffffff;
    committed = 0;
    if (scan_bad < 6'd32) begin
      status = 6;
      bad = {26'b0, scan_bad};
      check32(id, "first_nonfinite_input", {26'b0, scan_bad}, expected_bad);
    end else begin
      amax = scan_amax;
      check32(id, "amax_bits", amax, expected_amax);
      if (amax <= R0_TINY_MAX) d_bits = tiny_div127_bits(amax);
      else sample_div(id, "group_div127", amax, 32'h42fe0000, d_bits);
      check32(id, "d_full_bits", d_bits, expected_d);
      if ($isunknown(d_bits)) begin
        mismatch_count++;
        group_cases++;
        return;
      end
      zero_reciprocal = d_is_zero(d_bits);
      zero_quantization = d_is_zero(d_bits);
      check1(id, "d_is_zero_at_reciprocal", zero_reciprocal, expected_d_zero);
      check1(id, "d_is_zero_at_quantization", zero_quantization, expected_d_zero);
      if (zero_reciprocal) reciprocal_bits = 32'h00000000;
      else begin
        div_input = is_subnormal(d_bits) ? subnormal_up24(d_bits) : d_bits;
        sample_div(id, "reciprocal_div", 32'h3f800000,
                   div_input, normalized_result);
        reciprocal_bits = is_subnormal(d_bits) ?
                          positive_normal_up24_or_inf(normalized_result) : normalized_result;
      end
      check32(id, "reciprocal_bits", reciprocal_bits, expected_reciprocal);
      saved_half = original_half_rne(d_bits);
      check16(id, "saved_half", saved_half, expected_half);
      if (!is_finite(d_bits) || !is_finite(reciprocal_bits) ||
          (saved_half & 16'h7c00) == 16'h7c00) begin
        status = 6;
        bad = 0;
      end else begin
        for (int i = 0; i < 32; i++) begin
          x_bits = input_lanes[32*i +: 32];
          route = quant_route(x_bits, reciprocal_bits, zero_quantization);
          lane_id = $sformatf("%s_lane_%0d", id, i);
          check2(lane_id, "quant_route", route, expected_routes[2*i +: 2]);
          if (route <= 2'd1) begin
            rounded = 0;
            check1(lane_id, "product_bypassed", expected_product_mask[i], 1'b0);
          end else begin
            sample_mul(lane_id, quant_x_operand(x_bits, route),
                       quant_reciprocal_operand(reciprocal_bits, route),
                       product2, product3);
            check1(lane_id, "product_expected", expected_product_mask[i], 1'b1);
            check32(lane_id, "product_mul2", product2, expected_products[32*i +: 32]);
            check32(lane_id, "product_mul3", product3, expected_products[32*i +: 32]);
            rounded = roundf_away_from_product(product3);
          end
          if (rounded < -127 || rounded > 127 ||
              (route >= 2'd2 && (!is_finite(product2) || !is_finite(product3)))) begin
            status = 6;
            bad = i;
            break;
          end
          observed_q[8*i +: 8] = rounded[7:0];
        end
        if (status == 0) committed = 1;
      end
    end
    check32(id, "status", status, expected_status);
    check32(id, "bad_element", bad, expected_bad);
    check1(id, "group_committed", committed, expected_commit);
    if (committed) begin
      for (int i = 0; i < 32; i++)
        check32($sformatf("%s_lane_%0d", id, i), "q_byte",
                {24'b0, observed_q[8*i +: 8]}, {24'b0, expected_q[8*i +: 8]});
    end
    group_cases++;
  endtask

  initial begin
    raw_fd = $fopen("r0_adapter_raw.log", "w");
    if (raw_fd == 0) $fatal(1, "R0_ADAPTER_RAW_OPEN");
    repeat (32) @(posedge clk);
    normal_wrapper_smoke();
`include "generated_cases.svh"
    $fdisplay(raw_fd,
      "R0_ADAPTER_PROBE_COMPLETE|groups=%0d|scalar=%0d|restore=%0d|mismatches=%0d",
      group_cases, scalar_cases, restore_cases, mismatch_count);
    $fflush(raw_fd);
    $display("R0_ADAPTER_PROBE_COMPLETE groups=%0d scalar=%0d restore=%0d mismatches=%0d",
             group_cases, scalar_cases, restore_cases, mismatch_count);
    $fclose(raw_fd);
    if (group_cases != expected_group_cases || scalar_cases != expected_scalar_cases ||
        restore_cases != expected_restore_cases)
      $fatal(1, "R0_ADAPTER_CASE_COUNT");
    if (mismatch_count != 0) $fatal(1, "R0_ADAPTER_CONFORMANCE_FAIL mismatches=%0d", mismatch_count);
    $display("R0_ADAPTER_CONFORMANCE_PASS groups=%0d scalar=%0d restore=%0d",
             group_cases, scalar_cases, restore_cases);
    $finish;
  end
endmodule
