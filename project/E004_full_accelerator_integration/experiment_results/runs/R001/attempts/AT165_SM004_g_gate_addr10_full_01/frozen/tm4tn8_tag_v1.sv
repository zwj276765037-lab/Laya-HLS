`timescale 1ns/1ps

// TM4 v1 metadata encoding. The 160 old bit positions stay fixed, while
// group[6], tile[9] and the version occupy the new high word.
module tm4tn8_tag_v1 (
  input  logic [159:0] identity,
  input  logic [6:0]   group,
  input  logic [9:0]   tile,
  input  logic [1:0]   row,
  input  logic [5:0]   result_slot,
  input  logic [1:0]   trace_slot,
  input  logic         trace_enable,
  input  logic [2:0]   trace_lane,
  input  logic [7:0]   lane_mask,
  output logic [191:0] tag
);
  always_comb begin
    tag = '0;
    tag[159:64] = identity[159:64];
    tag[62:36] = identity[62:36];
    tag[63] = result_slot[5];
    tag[4:0] = result_slot[4:0];
    tag[6:5] = trace_slot;
    tag[7] = trace_enable;
    tag[10:8] = trace_lane;
    tag[16:11] = group[5:0];
    tag[25:17] = tile[8:0];
    tag[27:26] = row;
    tag[35:28] = lane_mask;
    tag[160] = group[6];
    tag[161] = tile[9];
    tag[167:164] = 4'd1;
  end
endmodule
