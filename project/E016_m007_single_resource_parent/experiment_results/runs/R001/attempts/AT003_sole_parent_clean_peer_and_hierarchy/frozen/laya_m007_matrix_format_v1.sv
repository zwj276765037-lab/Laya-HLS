`timescale 1ns/1ps
// Scale format work begins at the same accepted issue as the six-boundary dot.
// Align its exact result with one registered exact I32 conversion after dot.
module laya_m007_matrix_format_v1(
 input logic clk,rst_n,issue_valid,input logic [95:0] issue_tag,
 input logic [15:0][15:0] a_scale,w_scale,
 input logic dot_valid,input logic [95:0] dot_tag,input logic [255:0][20:0] dot,
 output logic rsp_valid,output logic [95:0] rsp_tag,
 output logic [255:0][31:0] converted,scale_product,
 output logic [255:0] domain_error
);
 logic [255:0] hv,dv,hbad,dbad;logic [255:0][31:0] hp;
 logic [255:0][95:0] htag,dtag;
 logic [3:0] sv;logic [3:0][255:0][31:0] aligned;
 logic [3:0][255:0] aligned_bad;
 for(genvar lane=0;lane<256;lane++)begin:lanes
  laya_m007_half_product_v1 #(.TAG_W(96)) scale(.clk,.rst_n,.req_valid(issue_valid),.req_tag(issue_tag),.a(a_scale[lane/16]),.b(w_scale[lane%16]),.rsp_valid(hv[lane]),.rsp_tag(htag[lane]),.result(hp[lane]),.nonfinite(hbad[lane]));
  laya_m007_dot_to_f32_v1 #(.TAG_W(96)) convert(.clk,.rst_n,.req_valid(dot_valid),.req_tag(dot_tag),.dot(dot[lane]),.rsp_valid(dv[lane]),.rsp_tag(dtag[lane]),.result(converted[lane]),.domain_error(dbad[lane]));
 end
 always_ff @(posedge clk)begin
  if(!rst_n)sv<=0;
  else begin
   sv<={sv[2:0],hv[0]};
   if(hv[0])begin aligned[0]<=hp;aligned_bad[0]<=hbad;end
   for(integer s=1;s<4;s++)if(sv[s-1])begin aligned[s]<=aligned[s-1];aligned_bad[s]<=aligned_bad[s-1];end
  end
 end
 assign rsp_valid=dv[0];assign rsp_tag=dtag[0];assign scale_product=aligned[3];assign domain_error=dbad|aligned_bad[3];
endmodule
