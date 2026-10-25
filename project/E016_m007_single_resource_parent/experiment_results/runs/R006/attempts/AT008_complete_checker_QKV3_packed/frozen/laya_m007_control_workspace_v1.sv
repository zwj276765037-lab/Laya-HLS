`timescale 1ns/1ps
// Exactly one physical FF control store. View layout: E018 g_control_layout_v1.
module laya_m007_control_workspace_v1(
 input logic clk,rst_n,
 input logic owner_req_valid,input logic owner_req_g,output logic owner_req_ready,
 input logic a_retired,g_retired,a_private_idle,g_private_idle,
 input logic [12287:0] a_next,input logic [11342:0] g_next,
 output logic [12287:0] state_q,output logic a_enable,g_enable,rearm,owner_g
);
 wire switch_fire=owner_req_valid&&owner_req_ready&&(owner_req_g!=owner_g);
 assign a_enable=rst_n&&!rearm&&!owner_g;
 assign g_enable=rst_n&&!rearm&&owner_g;
 assign owner_req_ready=rst_n&&!rearm&&((owner_req_g==owner_g)||
  ((!owner_g?a_retired:g_retired)&&(owner_req_g?g_private_idle:a_private_idle)));
 always_ff @(posedge clk)begin
  if(!rst_n)begin state_q<=0;owner_g<=0;rearm<=0;end
  else if(switch_fire)begin state_q<=0;owner_g<=owner_req_g;rearm<=1;end
  else if(rearm)begin state_q<=0;rearm<=0;end
  else if(a_enable)state_q<=a_next;
  else if(g_enable)state_q<={{945{1'b0}},g_next};
 end
endmodule
