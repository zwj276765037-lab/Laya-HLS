`timescale 1ns/1ps

// One 16-lane finite/absolute-max reduction per accepted clock. The four
// registered adjacent levels retain the lowest lane on a magnitude tie,
// including +0/-0. A bad lane is reported independently and takes the lowest
// input index. The caller merges half0 and half1 in original element order.
module quant16_amax16 (
    input  logic         clk,
    input  logic         rst,
    input  logic         req_valid,
    input  logic [511:0] req_lanes,
    input  logic [101:0] req_tag,
    output logic         ret_valid,
    output logic [31:0]  ret_amax_bits,
    output logic [3:0]   ret_max_lane,
    output logic [4:0]   ret_first_bad_lane,
    output logic [101:0] ret_tag
);
  logic [36:0] max1 [0:7], max2 [0:3], max3 [0:1], max4;
  logic [4:0] bad1 [0:7], bad2 [0:3], bad3 [0:1], bad4;
  logic [101:0] tag1, tag2, tag3, tag4;
  logic valid1, valid2, valid3, valid4;

  function automatic logic [36:0] choose_max(
      input logic [36:0] left, input logic [36:0] right);
    if (right[31:0] > left[31:0]) choose_max=right;
    else choose_max=left;
  endfunction
  function automatic logic [4:0] choose_bad(
      input logic [4:0] left, input logic [4:0] right);
    if (right < left) choose_bad=right;
    else choose_bad=left;
  endfunction
  function automatic logic [36:0] leaf(
      input logic [31:0] bits, input logic [4:0] lane);
    leaf={lane,1'b0,bits[30:0]};
  endfunction
  function automatic logic [4:0] bad_leaf(
      input logic [31:0] bits, input logic [4:0] lane);
    if (bits[30:23]==8'hff) bad_leaf=lane;
    else bad_leaf=5'd16;
  endfunction

  always_ff @(posedge clk) begin
    if (rst) begin
      valid1<=0; valid2<=0; valid3<=0; valid4<=0;
    end else begin
      valid1<=req_valid;
      valid2<=valid1;
      valid3<=valid2;
      valid4<=valid3;
    end
    tag1<=req_tag;
    tag2<=tag1;
    tag3<=tag2;
    tag4<=tag3;
    for (int pair=0;pair<8;pair++) begin
      max1[pair]<=choose_max(
          leaf(req_lanes[(2*pair)*32 +: 32],5'(2*pair)),
          leaf(req_lanes[(2*pair+1)*32 +: 32],5'(2*pair+1)));
      bad1[pair]<=choose_bad(
          bad_leaf(req_lanes[(2*pair)*32 +: 32],5'(2*pair)),
          bad_leaf(req_lanes[(2*pair+1)*32 +: 32],5'(2*pair+1)));
    end
    for (int pair=0;pair<4;pair++) begin
      max2[pair]<=choose_max(max1[2*pair],max1[2*pair+1]);
      bad2[pair]<=choose_bad(bad1[2*pair],bad1[2*pair+1]);
    end
    for (int pair=0;pair<2;pair++) begin
      max3[pair]<=choose_max(max2[2*pair],max2[2*pair+1]);
      bad3[pair]<=choose_bad(bad2[2*pair],bad2[2*pair+1]);
    end
    max4<=choose_max(max3[0],max3[1]);
    bad4<=choose_bad(bad3[0],bad3[1]);
  end
  assign ret_valid=valid4;
  assign ret_tag=tag4;
  assign ret_amax_bits=max4[31:0];
  assign ret_max_lane=max4[35:32];
  assign ret_first_bad_lane=bad4;
endmodule
