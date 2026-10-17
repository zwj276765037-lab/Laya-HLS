`timescale 1ns/1ps

// Two signed INT8 products sharing one activation. Mapping is an intent;
// generated structure must establish whether one DSP implements the multiply.
module tm1tn8_signed_pack_pair (
  input  logic signed [7:0] a,
  input  logic signed [7:0] w0,
  input  logic signed [7:0] w1,
  output logic signed [15:0] p0,
  output logic signed [15:0] p1
);
  logic signed [26:0] w0_ext;
  logic signed [26:0] w1_ext;
  logic signed [26:0] x;
  logic signed [17:0] y;
  (* use_dsp = "yes" *) logic signed [44:0] p45;
  logic signed [44:0] high_product;
  logic signed [44:0] corrected_product;

  assign w0_ext = {{19{w0[7]}}, w0};
  assign w1_ext = {{19{w1[7]}}, w1};
  assign x = (w1_ext <<< 17) + w0_ext;
  assign y = {{10{a[7]}}, a};
  assign p45 = x * y;
  assign p0 = $signed(p45[15:0]);
  assign high_product = p45 >>> 17;
  assign corrected_product = high_product + (p0[15] ? 45'sd1 : 45'sd0);
  assign p1 = corrected_product[15:0];
endmodule
