`timescale 1ns/1ps
module m007_control_workspace_tb;
 logic clk=0;always #1 clk=~clk;logic rst_n=0;
 logic owner_req_valid=0,owner_req_g=0,owner_req_ready;
 logic a_retired=0,g_retired=0,a_private_idle=1,g_private_idle=1;
 logic [12287:0]a_next=0,state_q;logic [11342:0]g_next=0;
 logic a_enable,g_enable,rearm,owner_g;
 laya_m007_control_workspace_v1 dut(.*);
 task automatic step;@(posedge clk);#0.01;endtask
 initial begin
  step();rst_n=1;@(negedge clk);a_next[0]=1;a_next[4095]=1;a_next[12287]=1;step();
  if(state_q!==a_next||!a_enable||g_enable)$fatal(1,"A_PARALLEL_WRITES");
  @(negedge clk);owner_req_valid=1;owner_req_g=1;g_next='1;step();
  if(owner_req_ready||state_q!==a_next||rearm)$fatal(1,"EARLY_SWITCH_ACCEPTED");
  @(negedge clk);owner_req_g=0;step();if(state_q!==a_next||rearm||owner_g)$fatal(1,"SAME_OWNER_CLEARED");
  @(negedge clk);owner_req_g=1;a_retired=1;g_private_idle=0;step();if(owner_req_ready||rearm)$fatal(1,"TARGET_PRIVATE_BUSY");
  @(negedge clk);g_private_idle=1;#0.01;if(!owner_req_ready)$fatal(1,"SWITCH_NOT_READY");step();
  if(!rearm||a_enable||g_enable||state_q!==0||!owner_g)$fatal(1,"REARM_FIRST");
  @(negedge clk);owner_req_valid=0;step();if(rearm||!g_enable||a_enable||state_q!==0)$fatal(1,"REARM_NOT_EXACTLY_ONE");
  @(negedge clk);g_next=0;g_next[0]=1;g_next[11342]=1;a_next='1;step();
  if(state_q!=={945'b0,g_next})$fatal(1,"G_VIEW_PARALLEL_AND_TAIL");
  repeat(5)begin step();if(state_q!=={945'b0,g_next})$fatal(1,"HOLD");end
  @(negedge clk);owner_req_g=0;owner_req_valid=1;step();if(owner_req_ready||rearm)$fatal(1,"G_DEBT_SWITCH");
  @(negedge clk);g_retired=1;step();if(!rearm||state_q!==0)$fatal(1,"G_TO_A_REARM");
  @(negedge clk);owner_req_valid=0;step();if(!a_enable||g_enable||state_q!==0)$fatal(1,"A_RELOAD_CLEAR");
  $display("HARDWARE_AGENT_SIM_PASS CONTROL_WORKSPACE parallel_writes=5 same_owner_hold=1 early_reject=3 rearm_cycles=2 workspace_bits=12288 owner_bits=2");$finish;
 end
 initial begin #1000;$fatal(1,"TIMEOUT");end
endmodule
