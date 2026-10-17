package r0_fp_bits_pkg;
  // Combinational finite-domain helpers. Callers check documented domains.
  localparam logic [31:0] R0_TINY_MAX = 32'h03fe0000;
  localparam logic [31:0] R0_MIN_NORMAL = 32'h00800000;

  function automatic logic [31:0] abs_bits(input logic [31:0] bits);
    return {1'b0, bits[30:0]};
  endfunction

  function automatic logic is_finite(input logic [31:0] bits);
    return bits[30:23] != 8'hff;
  endfunction

  function automatic logic is_zero_bits(input logic [31:0] bits);
    return bits[30:0] == 31'b0;
  endfunction

  function automatic logic is_subnormal(input logic [31:0] bits);
    return bits[30:23] == 8'b0 && bits[22:0] != 23'b0;
  endfunction

  function automatic logic is_normal(input logic [31:0] bits);
    return bits[30:23] != 8'b0 && bits[30:23] != 8'hff;
  endfunction

  function automatic logic d_is_zero(input logic [31:0] d_bits);
    return is_zero_bits(d_bits);
  endfunction

  function automatic logic [31:0] max_magnitude_bits(
      input logic [31:0] a_bits, input logic [31:0] b_bits);
    return (abs_bits(a_bits) >= abs_bits(b_bits)) ? abs_bits(a_bits) : abs_bits(b_bits);
  endfunction

  function automatic logic [4:0] msb_index23(input logic [22:0] value);
    logic [4:0] index;
    index = 5'd0;
    for (int i = 0; i < 23; i++) begin
      if (value[i]) index = i[4:0];
    end
    return index;
  endfunction

  // Requires nonnegative finite amax <= 0x03fe0000. The 30-bit divide
  // implements exact U/127 rounding on the binary32 subnormal grid.
  function automatic logic [31:0] tiny_div127_bits(input logic [31:0] amax_bits);
    logic [29:0] units;
    logic [29:0] quotient;
    logic [6:0] remainder;
    logic [23:0] rounded;
    units = 30'b0;
    if (amax_bits[30:23] == 8'b0) begin
      units = {7'b0, amax_bits[22:0]};
    end else begin
      units = {6'b0, 1'b1, amax_bits[22:0]} << (amax_bits[30:23] - 8'd1);
    end
    quotient = units / 30'd127;
    remainder = units % 30'd127;
    rounded = quotient[23:0] + {23'b0, (remainder >= 7'd64)};
    return {8'b0, rounded};
  endfunction

  // Requires a nonzero subnormal; multiplication by 2^24 is bit-exact.
  function automatic logic [31:0] subnormal_up24(input logic [31:0] bits);
    logic [4:0] k;
    logic [7:0] exponent;
    logic [22:0] fraction;
    k = msb_index23(bits[22:0]);
    exponent = {3'b0, k} + 8'd2;
    fraction = (bits[22:0] << (5'd23 - k)) & 23'h7fffff;
    return {bits[31], exponent, fraction};
  endfunction

  // Requires a normal finite operand with exponent >=25.
  function automatic logic [31:0] normal_down24(input logic [31:0] bits);
    return {bits[31], (bits[30:23] - 8'd24), bits[22:0]};
  endfunction

  // Requires a positive normal result of 1/(subnormal_d*2^24).
  // A 9-bit exponent sum prevents wrap at the overflow boundary.
  function automatic logic [31:0] positive_normal_up24_or_inf(input logic [31:0] bits);
    logic [8:0] exponent_sum;
    exponent_sum = {1'b0, bits[30:23]} + 9'd24;
    if (exponent_sum >= 9'd255) return 32'h7f800000;
    return {1'b0, exponent_sum[7:0], bits[22:0]};
  endfunction

  // Requires nonzero finite operand; exponent is the exact floor(log2|x|).
  function automatic logic signed [10:0] floor_binary_exponent(input logic [31:0] bits);
    if (bits[30:23] == 8'b0)
      return $signed({6'b0, msb_index23(bits[22:0])}) - 11'sd149;
    return $signed({3'b0, bits[30:23]}) - 11'sd127;
  endfunction

  // 0=d-zero, 1=x-zero or proven small product, 2=ordinary FP product,
  // 3=FP product with exact x-up24/r-down24 operand scaling.
  function automatic logic [1:0] quant_route(
      input logic [31:0] x_bits, input logic [31:0] reciprocal_bits,
      input logic d_zero);
    logic signed [11:0] exponent_sum;
    if (d_zero) return 2'd0;
    if (is_zero_bits(x_bits)) return 2'd1;
    exponent_sum = floor_binary_exponent(x_bits) + floor_binary_exponent(reciprocal_bits);
    if (exponent_sum <= -12'sd4) return 2'd1;
    if (is_subnormal(x_bits)) return 2'd3;
    return 2'd2;
  endfunction

  function automatic logic [31:0] quant_x_operand(
      input logic [31:0] x_bits, input logic [1:0] route);
    return route == 2'd3 ? subnormal_up24(x_bits) : x_bits;
  endfunction

  function automatic logic [31:0] quant_reciprocal_operand(
      input logic [31:0] reciprocal_bits, input logic [1:0] route);
    return route == 2'd3 ? normal_down24(reciprocal_bits) : reciprocal_bits;
  endfunction

  // 0=PS+0 selects bias, 1=tiny bias selects PS, 2=ordinary FP add,
  // 3=outside proved restore domain (-0 PS).
  function automatic logic [1:0] bias_route(
      input logic [31:0] ps_bits, input logic [31:0] bias_bits);
    if (ps_bits == 32'h00000000) return 2'd0;
    if (ps_bits == 32'h80000000) return 2'd3;
    if (abs_bits(bias_bits) < R0_MIN_NORMAL) return 2'd1;
    return 2'd2;
  endfunction

  function automatic logic [31:0] bias_direct_bits(
      input logic [31:0] ps_bits, input logic [31:0] bias_bits,
      input logic [1:0] route);
    if (route == 2'd0) return is_zero_bits(bias_bits) ? 32'h00000000 : bias_bits;
    if (route == 2'd1) return ps_bits;
    return 32'hxxxxxxxx;
  endfunction
endpackage

module r0_group_bit_scan(
    input  logic [1023:0] lanes_flat,
    output logic [31:0] amax_bits,
    output logic [5:0] first_bad);
  import r0_fp_bits_pkg::*;
  logic [31:0] lane_bits;
  always_comb begin
    amax_bits = 32'h00000000;
    first_bad = 6'd32;
    lane_bits = 32'b0;
    for (int i = 0; i < 32; i++) begin
      lane_bits = lanes_flat[32*i +: 32];
      if (!is_finite(lane_bits)) begin
        if (first_bad == 6'd32) first_bad = i[5:0];
      end else if (abs_bits(lane_bits) > amax_bits) begin
        amax_bits = abs_bits(lane_bits);
      end
    end
  end
endmodule
