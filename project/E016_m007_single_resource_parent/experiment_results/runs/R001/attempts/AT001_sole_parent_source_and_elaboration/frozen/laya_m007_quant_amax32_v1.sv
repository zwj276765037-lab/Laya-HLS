`timescale 1ns/1ps
// Five fixed stages, II1; only positive finite magnitudes participate. An input
// error retains the lowest source element and publishes canonical scalar0.
module laya_m007_quant_amax32_v1#(parameter integer TAG_WIDTH=7)(
 input logic clk,rst_n,in_valid,input logic[1023:0]in_data,input logic[TAG_WIDTH-1:0]in_tag,
 output logic out_valid,output logic[31:0]out_amax,output logic out_bad,
 output logic[4:0]out_bad_element,output logic[TAG_WIDTH-1:0]out_tag
);
 logic[30:0]s0[16],s1[8],s2[4],s3[2],s4;
 logic[4:0]valid,bad;logic[4:0]bad_element[5];logic[TAG_WIDTH-1:0]tag[5];
 logic capture_bad;logic[4:0]capture_element;
 logic[30:0]magnitude[32];
 always_comb begin
  capture_bad=0;capture_element=0;
  for(int lane=0;lane<32;lane++)begin
   magnitude[lane]=in_data[32*lane+23+:8]==255?31'b0:in_data[32*lane+:31];
   if(in_data[32*lane+23+:8]==255&&!capture_bad)begin capture_bad=1;capture_element=5'(lane);end
  end
 end
 always_ff@(posedge clk)begin
  if(!rst_n)begin valid<=0;bad<=0;end
  else begin
   valid<={valid[3:0],in_valid};bad<={bad[3:0],capture_bad};
   tag[0]<=in_tag;bad_element[0]<=capture_element;
   for(int stage=1;stage<5;stage++)begin tag[stage]<=tag[stage-1];bad_element[stage]<=bad_element[stage-1];end
   for(int i=0;i<16;i++)s0[i]<=magnitude[2*i]>=magnitude[2*i+1]?magnitude[2*i]:magnitude[2*i+1];
   for(int i=0;i<8;i++)s1[i]<=s0[2*i]>=s0[2*i+1]?s0[2*i]:s0[2*i+1];
   for(int i=0;i<4;i++)s2[i]<=s1[2*i]>=s1[2*i+1]?s1[2*i]:s1[2*i+1];
   for(int i=0;i<2;i++)s3[i]<=s2[2*i]>=s2[2*i+1]?s2[2*i]:s2[2*i+1];
   s4<=s3[0]>=s3[1]?s3[0]:s3[1];
  end
 end
 assign out_valid=valid[4];assign out_bad=bad[4];assign out_bad_element=bad_element[4];
 assign out_tag=tag[4];assign out_amax=bad[4]?32'b0:{1'b0,s4};
endmodule
