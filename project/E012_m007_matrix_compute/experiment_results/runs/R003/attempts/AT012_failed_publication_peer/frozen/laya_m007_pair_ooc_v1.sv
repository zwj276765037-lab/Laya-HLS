`timescale 1ns/1ps
// Only a registered OOC boundary around the unchanged exact signed pair.
module laya_m007_pair_ooc_v1(input logic clk,input logic signed[7:0] a,w0,w1,output logic signed[15:0] p0,p1);
 logic signed[7:0] aq,xq,yq;logic signed[15:0] u,v;
 always_ff @(posedge clk)begin aq<=a;xq<=w0;yq<=w1;p0<=u;p1<=v;end
 tm1tn8_signed_pack_pair pair(.a(aq),.w0(xq),.w1(yq),.p0(u),.p1(v));
endmodule
