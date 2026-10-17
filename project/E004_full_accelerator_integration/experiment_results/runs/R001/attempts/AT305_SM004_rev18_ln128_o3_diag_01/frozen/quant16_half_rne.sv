`timescale 1ns/1ps

// Bit-exact F32 -> binary16 round-to-nearest-even used for the saved scale.
// This is independent of the ties-away rounding used for Q8 elements.
module quant16_half_rne (
    input  logic [31:0] f32_bits,
    output logic [15:0] half_bits
);
  logic [15:0] sign;
  logic [7:0] exponent;
  logic [31:0] mantissa, result, remainder, halfway, mask;
  integer signed half_exp, shift;
  always_comb begin
    sign={f32_bits[31],15'd0};
    exponent=f32_bits[30:23];
    mantissa={9'd0,f32_bits[22:0]};
    result=0; remainder=0; halfway=0; mask=0;
    half_exp=integer'(exponent)-127+15;
    shift=0;
    if (exponent==8'hff) begin
      half_bits=sign | (mantissa!=0 ? 16'h7e00 : 16'h7c00);
    end else if (half_exp>=31) begin
      half_bits=sign | 16'h7c00;
    end else if (half_exp<=-11) begin
      half_bits=sign;
    end else if (half_exp<=0) begin
      mantissa=mantissa | 32'h00800000;
      shift=14-half_exp;
      result=mantissa >> shift;
      mask=(32'h1 << shift)-1;
      remainder=mantissa & mask;
      halfway=32'h1 << (shift-1);
      if (remainder>halfway || (remainder==halfway && result[0]))
        result=result+1;
      half_bits=sign | result[15:0];
    end else begin
      result=(32'(half_exp)<<10) | (mantissa>>13);
      remainder=mantissa & 32'h1fff;
      if (remainder>32'h1000 || (remainder==32'h1000 && result[0]))
        result=result+1;
      half_bits=sign | result[15:0];
    end
  end
endmodule
