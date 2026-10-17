`timescale 1ns/1ps
module tanh_libm_canonical_netlist_tb;
 reg clk=0;always #3.333333 clk=~clk;
 reg reset=1,in_valid=0,out_ready=0;
 reg [31:0] in_data=0,in_tag=0;
 wire in_ready,out_valid;wire [31:0] out_data,out_tag,out_status;
 tanh_libm_canonical_wrapper dut(.*);
 reg [31:0] x[0:3269],gold[0:3269];
 integer chosen[0:127],accepted_cycle[0:127];
 integer cycle=0,mode=0,accepted=0,retired=0,i,first_accept=0,last_retire=0;
 reg stalled=0;reg [95:0] held;
 string xf,gf;
 always @(negedge clk)begin
  if(reset)out_ready<=0;
  else out_ready<=mode==0 || (cycle%19)>=7;
 end
 always @(posedge clk)begin
  cycle=cycle+1;if(cycle>40000000)$fatal(1,"CANONICAL_NETLIST_CYCLE_CAP");
  if(reset)stalled=0;
  else begin
   if(stalled && (!out_valid || {out_data,out_tag,out_status}!==held))$fatal(1,"CANONICAL_NETLIST_OUTPUT_CHANGED");
   stalled=out_valid&&!out_ready;if(stalled)held={out_data,out_tag,out_status};
   if(in_valid&&in_ready)begin
    if(accepted>=128 || in_tag[15:0]!==accepted)$fatal(1,"CANONICAL_NETLIST_ACCEPT_TAG");
    accepted_cycle[accepted]=cycle;if(accepted==0)first_accept=cycle;accepted=accepted+1;
   end
   if(out_valid)begin
    if(retired>=accepted || out_tag!=={16'(mode+1),16'(retired)} ||
       out_data!==gold[chosen[retired]] ||
       out_status!==((x[chosen[retired]]&32'h7fffffff)>=32'h7f800000?32'd1:32'd0))
     $fatal(1,"CANONICAL_NETLIST_RESULT ordinal=%0d got=%08x gold=%08x tag=%08x status=%0d",retired,out_data,gold[chosen[retired]],out_tag,out_status);
    if(cycle-accepted_cycle[retired]<385)$fatal(1,"CANONICAL_NETLIST_EARLY_OUTPUT");
    if(out_ready)begin retired=retired+1;last_retire=cycle;end
   end
  end
 end
 task run_profile(input integer selected_mode);
  begin
   @(negedge clk);mode=selected_mode;accepted=0;retired=0;
   for(i=0;i<128;i=i+1)begin
    @(negedge clk);in_valid=1;in_data=x[chosen[i]];in_tag={16'(mode+1),16'(i)};
    do @(posedge clk);while(!in_ready);
   end
   @(negedge clk);in_valid=0;
   wait(retired==128);@(negedge clk);
   if(accepted!=128)$fatal(1,"CANONICAL_NETLIST_DEBT");
   $display("TANH_PROGRESS canonical_netlist mode=%0d accepted=%0d retired=%0d span=%0d",mode,accepted,retired,last_retire-first_accept);
  end
 endtask
 initial begin
  if(!$value$plusargs("X_FILE=%s",xf)||!$value$plusargs("GOLD_FILE=%s",gf))$fatal(1,"CANONICAL_NETLIST_MISSING_FIXTURE");
  $readmemh(xf,x);$readmemh(gf,gold);
  for(i=0;i<3270;i=i+1)if($isunknown(x[i])||$isunknown(gold[i]))$fatal(1,"CANONICAL_NETLIST_UNKNOWN_FIXTURE");
  for(i=0;i<128;i=i+1)chosen[i]=i<64?i*41:(i<122?2624+(i-64)*10:3264+i-122);
  repeat(32)@(negedge clk);reset=0;
  run_profile(0);run_profile(1);
  $display("TANH_LIBM_CANONICAL_NETLIST_PASS selected_fixture=128 profiles=2 original_gold_unchanged=1 cycles=%0d",cycle);$finish;
 end
endmodule
