`timescale 1ns/1ps
// Sole12288-bit packedFF arena. Consumer retirement/private probes are wired
// to real resources by the production joint composition, never inactive q.
module laya_m007_control_workspace_v2 #(parameter int LN_CONTROL_BITS=12120)(
 input logic clk,rst_n,owner_req_valid,input logic[1:0]owner_req,
 output logic owner_req_ready,output logic[1:0]owner,output logic rearm,
 input logic a_retired,g_retired,ln_retired,vector_retired,
 input logic a_private_idle,g_private_idle,ln_private_idle,vector_private_idle,
 input logic[3:0]admission_quiet,
 input logic[12287:0]a_next,ln_next,input logic[11342:0]g_next,
 input logic[47:0]vector_next,
 output logic[12287:0]state_q,
 output logic a_enable,g_enable,ln_enable,vector_enable
);
 logic[3:0]retired,private_idle;
 wire switch_fire=owner_req_valid&&owner_req_ready&&owner_req!=owner;
 assign retired={vector_retired,ln_retired,g_retired,a_retired};
 assign private_idle={vector_private_idle,ln_private_idle,g_private_idle,a_private_idle};
 assign a_enable=rst_n&&!rearm&&owner==0;
 assign g_enable=rst_n&&!rearm&&owner==1;
 assign ln_enable=rst_n&&!rearm&&owner==2;
 assign vector_enable=rst_n&&!rearm&&owner==3;
 assign owner_req_ready=rst_n&&!rearm&&((owner_req==owner)||(retired[owner]&&private_idle[owner_req]&&admission_quiet[owner]));
 always_ff @(posedge clk)begin
  if(!rst_n)begin state_q<=0;owner<=0;rearm<=0;end
  else if(switch_fire)begin state_q<=0;owner<=owner_req;rearm<=1;end
  else if(rearm)begin state_q<=0;rearm<=0;end
  else case(owner)
   0:state_q<=a_next;
   1:state_q<={{945{1'b0}},g_next};
   2:state_q<={{(12288-LN_CONTROL_BITS){1'b0}},ln_next[LN_CONTROL_BITS-1:0]};
   3:state_q<={{12240{1'b0}},vector_next};
  endcase
 end
endmodule
