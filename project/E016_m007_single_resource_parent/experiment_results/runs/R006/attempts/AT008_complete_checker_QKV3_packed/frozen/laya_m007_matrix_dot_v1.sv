`timescale 1ns/1ps
module laya_m007_dot_m8n16_v1 #(parameter int TAG_W=96)(
 input logic clk,rst_n,req_valid,output logic req_ready,input logic [TAG_W-1:0] req_tag,
 input logic [2047:0] a,input logic [4095:0] w,
 output logic rsp_valid,output logic [TAG_W-1:0] rsp_tag,output logic [127:0][20:0] dot
);
 logic [15:0] ready,valid;logic [15:0][TAG_W-1:0] tags;
 for(genvar r=0;r<8;r++)begin:rows
  for(genvar c=0;c<2;c++)begin:columns
   tm1tn8_integer_tree_packed #(.TAG_W(TAG_W)) tree(.clk,.rst_n,.req_valid(req_valid&&req_ready),.req_ready(ready[2*r+c]),.req_tag,.req_old_ps(256'b0),.req_a(a[256*r+:256]),.req_w(w[2048*c+:2048]),.ret_valid(valid[2*r+c]),.ret_tag(tags[2*r+c]),.ret_old_ps(),.ret_dot21(dot[16*r+8*c+:8]));
  end
 end
 assign req_ready=rst_n&&(&ready);assign rsp_valid=&valid;assign rsp_tag=tags[0];
endmodule
module laya_m007_matrix_dot_v1 #(parameter int TAG_W=96)(
 input logic clk,rst_n,req_valid,output logic req_ready,input logic [TAG_W-1:0] req_tag,
 input logic [4095:0] a,w,
 output logic rsp_valid,output logic [TAG_W-1:0] rsp_tag,output logic [255:0][20:0] dot
);
 logic [1:0] ready,valid;logic [1:0][TAG_W-1:0] tags;
 for(genvar t=0;t<2;t++)begin:tiles
  laya_m007_dot_m8n16_v1 #(.TAG_W(TAG_W)) tile(.clk,.rst_n,.req_valid(req_valid&&req_ready),.req_ready(ready[t]),.req_tag,.a(a[2048*t+:2048]),.w,.rsp_valid(valid[t]),.rsp_tag(tags[t]),.dot(dot[128*t+:128]));
 end
 assign req_ready=rst_n&&(&ready);assign rsp_valid=&valid;assign rsp_tag=tags[0];
endmodule
