`timescale 1ns/1ps
module m007_matrix_dot_tb;
 logic clk=0;always #1 clk=~clk;
 logic rst_n=0,req_valid=0,req_ready,rsp_valid;logic [95:0] req_tag,rsp_tag;
 logic [4095:0] a,w;logic [255:0][20:0] dot;
 laya_m007_matrix_dot_v1 dut(.*);
 logic [4095:0] av[0:1023],wv[0:1023];logic [8191:0] expected[0:1023];
 string fixture;integer checks=0,scalar_checks=0,cycle=0,last_return=-1,first_issue=-1,last_issue=-1;
 always @(posedge clk)begin
  cycle=cycle+1;
  if(req_valid&&req_ready)begin if(first_issue<0)first_issue=cycle;last_issue=cycle;end
  #0.001;
  if(rst_n&&rsp_valid)begin
   if(rsp_tag[95:32]!=64'h123456789abcdef0||rsp_tag[31:0]!=checks)$fatal(1,"dot tag/order");
   if(checks>0&&cycle-last_return!=1)$fatal(1,"full256dot output II not1");last_return=cycle;
   for(integer lane=0;lane<256;lane=lane+1)begin
    if($signed(dot[lane])!==$signed(expected[checks][32*lane+:32]))$fatal(1,"dot lane mismatch vector=%0d lane=%0d got=%0d gold=%0d",checks,lane,$signed(dot[lane]),$signed(expected[checks][32*lane+:32]));
    scalar_checks=scalar_checks+1;
   end
   checks=checks+1;
  end
  if(cycle>2048)$fatal(1,"dot cycle watchdog");
 end
 initial begin
  if(!$value$plusargs("FIXTURE=%s",fixture))$fatal(1,"FIXTURE required");
  $readmemh({fixture,"/dot_a.hex"},av);$readmemh({fixture,"/dot_w.hex"},wv);$readmemh({fixture,"/dot_expected.hex"},expected);
  repeat(5)@(negedge clk);rst_n=1;
  for(integer i=0;i<1024;i=i+1)begin @(negedge clk);req_valid=1;req_tag={64'h123456789abcdef0,32'(i)};a=av[i];w=wv[i];if(!req_ready)$fatal(1,"full dot not ready");end
  @(negedge clk);req_valid=0;
  wait(checks==1024);@(negedge clk);
  if(last_issue-first_issue!=1023)$fatal(1,"dot issue not continuous");
  $display("HARDWARE_AGENT_SIM_PASS M007_MATRIX_DOT vectors=%0d scalar_dots=%0d INT8_MAC_per_issue=8192 II=1 first_issue=%0d last_issue=%0d final_return=%0d",checks,scalar_checks,first_issue,last_issue,last_return);$finish;
 end
endmodule
