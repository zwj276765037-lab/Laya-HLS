`timescale 1ns/1ps

// Exact U/127 on the binary32 subnormal grid. Six registered stages, each
// advancing five MSB-first restoring-division bits; one request per clock.
module quant16_tiny_div127 (
    input  logic        clk,
    input  logic        rst,
    input  logic        req_valid,
    input  logic [31:0] req_amax_bits,
    input  logic [4:0]  req_index,
    input  logic [101:0] req_tag,
    output logic        resp_valid,
    output logic [31:0] resp_bits,
    output logic [4:0]  resp_index,
    output logic [101:0] resp_tag
);
  logic [29:0] units [0:5], quotient [0:5];
  logic [6:0] remainder [0:5];
  logic [4:0] index_pipe [0:5];
  logic [101:0] tag_pipe [0:5];
  logic valid_pipe [0:5];

  function automatic logic [29:0] make_units(input logic [31:0] bits);
    logic [29:0] u;
    u = '0;
    if (bits[30:23] == 0)
      u = {7'b0, bits[22:0]};
    else
      u = {6'b0, 1'b1, bits[22:0]} << (bits[30:23] - 8'd1);
    return u;
  endfunction
  wire [29:0] req_units = make_units(req_amax_bits);

  function automatic logic [36:0] advance5(
      input logic [29:0] old_quotient,
      input logic [6:0] old_remainder,
      input logic [4:0] next_bits);
    logic [29:0] q;
    logic [6:0] r;
    logic [7:0] trial;
    q = old_quotient;
    r = old_remainder;
    for (int bit_index = 4; bit_index >= 0; bit_index--) begin
      trial = {r, next_bits[bit_index]};
      q = {q[28:0], trial >= 8'd127};
      r = trial >= 8'd127 ? 7'(trial - 8'd127) : trial[6:0];
    end
    return {q,r};
  endfunction

  always_ff @(posedge clk) begin
    if (rst) begin
      for (int s=0; s<6; s++) valid_pipe[s] <= 0;
    end else begin
      valid_pipe[0] <= req_valid;
      if (req_valid) begin
        units[0] <= req_units;
        {quotient[0],remainder[0]} <=
            advance5(30'b0,7'b0,req_units[29:25]);
        index_pipe[0] <= req_index;
        tag_pipe[0] <= req_tag;
      end
      for (int s=1; s<6; s++) begin
        valid_pipe[s] <= valid_pipe[s-1];
        if (valid_pipe[s-1]) begin
          units[s] <= units[s-1];
          {quotient[s],remainder[s]} <=
              advance5(quotient[s-1],remainder[s-1],
                       units[s-1][29-5*s -: 5]);
          index_pipe[s] <= index_pipe[s-1];
          tag_pipe[s] <= tag_pipe[s-1];
        end
      end
    end
  end
  assign resp_valid = valid_pipe[5];
  assign resp_index = index_pipe[5];
  assign resp_tag = tag_pipe[5];
  assign resp_bits = {8'b0, (quotient[5][23:0] +
                             {23'b0,(remainder[5] >= 7'd64)})};
endmodule
