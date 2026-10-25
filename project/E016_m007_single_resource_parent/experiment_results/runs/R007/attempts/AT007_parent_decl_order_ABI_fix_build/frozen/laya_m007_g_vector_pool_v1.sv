`timescale 1ns/1ps
// G's separate original 7M+2A nodes across8 lanes: exactly56mul/16add.
// No shared256 matrix FP copy and no TANH. Engine owns all return capacity.
module laya_m007_g_vector_pool_v1(
 input logic clk,rst_n,
 input logic [8:0] req_valid,output logic [8:0] req_ready,
 input logic [8:0][95:0] req_tag,
 input logic [8:0][7:0][31:0] req_a,req_b,
 output logic [8:0] rsp_valid,output logic [8:0][95:0] rsp_tag,
 output logic [8:0][7:0][31:0] rsp_data,rsp_status,
 output logic protocol_fault
);
 logic [8:0][7:0] leaf_valid;
 logic [8:0] alignment_fault;
 // G-only request domain, not an arbitrary96-bit-tag service. Bind once on
 // first real accept and retain through empty intervals until pool reset.
 logic [63:0] tag_context,candidate_context;
 logic context_valid,context_fault,candidate_found;
 logic [8:0][15:0] next_seq;
 logic [8:0] domain_ok,accept;
 assign rsp_status=0;assign protocol_fault=(|alignment_fault)||context_fault;
 always_comb begin
  candidate_context=tag_context;candidate_found=context_valid;
  if(!context_valid)for(int n=0;n<9;n++)if(req_valid[n]&&!candidate_found)begin
   candidate_context=req_tag[n][95:32];candidate_found=1;
  end
  domain_ok=0;req_ready=0;accept=0;
  for(int n=0;n<9;n++)begin
   domain_ok[n]=req_tag[n][95:32]==candidate_context&&req_tag[n][31:16]==0&&req_tag[n][15:0]<41984&&req_tag[n][15:0]==next_seq[n];
   req_ready[n]=rst_n&&!context_fault&&(!req_valid[n]||domain_ok[n]);
   accept[n]=req_valid[n]&&req_ready[n];
  end
 end
 always_ff @(posedge clk)begin
  if(!rst_n)begin tag_context<=0;context_valid<=0;context_fault<=0;next_seq<=0;end
  else begin
   if(!context_valid&&|accept)begin tag_context<=candidate_context;context_valid<=1;end
   for(int n=0;n<9;n++)begin
    if(req_valid[n]&&!domain_ok[n])context_fault<=1;
    if(accept[n])next_seq[n]<=next_seq[n]+1'b1;
   end
  end
 end
 for(genvar node=0;node<9;node++)begin:op
  localparam int LAT=(node==2||node==5)?3:4;
  logic [LAT-1:0] valid_pipe;logic [15:0] tags[0:LAT-1];
  assign rsp_valid[node]=leaf_valid[node][0];assign rsp_tag[node]={tag_context,16'b0,tags[LAT-1]};
  always_ff @(posedge clk)begin
   if(!rst_n)begin valid_pipe<=0;alignment_fault[node]<=0;end
   else begin
    valid_pipe<={valid_pipe[LAT-2:0],req_valid[node]&&req_ready[node]};
    tags[0]<=req_tag[node][15:0];for(int i=1;i<LAT;i++)tags[i]<=tags[i-1];
    if(leaf_valid[node]!={8{valid_pipe[LAT-1]}})alignment_fault[node]<=1;
   end
  end
  for(genvar lane=0;lane<8;lane++)begin:lane_op
   if(node==2||node==5)begin:add_op
    laya_m007_tanh_add3_e_v1 leaf(.aclk(clk),.aclken(1'b1),.aresetn(rst_n),
     .s_axis_a_tvalid(req_valid[node]&&req_ready[node]),.s_axis_b_tvalid(req_valid[node]&&req_ready[node]),
     .s_axis_a_tdata(req_valid[node]?req_a[node][lane]:32'b0),.s_axis_b_tdata(req_valid[node]?req_b[node][lane]:32'b0),
     .m_axis_result_tvalid(leaf_valid[node][lane]),.m_axis_result_tdata(rsp_data[node][lane]));
   end else begin:mul_op
    laya_m007_tanh_mul4_v1 leaf(.aclk(clk),.aclken(1'b1),.aresetn(rst_n),
     .s_axis_a_tvalid(req_valid[node]&&req_ready[node]),.s_axis_b_tvalid(req_valid[node]&&req_ready[node]),
     .s_axis_a_tdata(req_valid[node]?req_a[node][lane]:32'b0),.s_axis_b_tdata(req_valid[node]?req_b[node][lane]:32'b0),
     .m_axis_result_tvalid(leaf_valid[node][lane]),.m_axis_result_tdata(rsp_data[node][lane]));
   end
  end
 end
endmodule
