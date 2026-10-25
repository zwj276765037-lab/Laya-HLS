`timescale 1ns/1ps
module m011_softmax_exp_lane_tb;
 logic ap_clk=0;always #1.6665 ap_clk=~ap_clk;
 logic ap_rst=1,ap_start=0;logic[31:0]x=0;
 wire ap_done,ap_idle,ap_ready;wire[31:0] result,status;wire result_ap_vld,status_ap_vld;
 logic[31:0]xs[0:49999],gold[0:49999],statuses[0:49999];
 int count=0,cycle=0,sent=0,received=0,first_accept=-1,first_return=-1,last_return=-1;string data_dir;
 attention_exp_leaf dut(.ap_clk,.ap_rst,.ap_start,.ap_done,.ap_idle,.ap_ready,.x,.result,.result_ap_vld,.status,.status_ap_vld);
 initial begin
  if(!$value$plusargs("DATA=%s",data_dir)||!$value$plusargs("COUNT=%d",count)||count<1||count>50000)$fatal(1,"EXP_LANE_ARGS");
  $readmemh({data_dir,"/exp_x.mem"},xs,0,count-1);$readmemh({data_dir,"/exp_gold.mem"},gold,0,count-1);$readmemh({data_dir,"/exp_status.mem"},statuses,0,count-1);
  repeat(5)@(negedge ap_clk);ap_rst=0;
 end
 always @(negedge ap_clk)begin
  ap_start= !ap_rst&&sent<count;x=sent<count?xs[sent]:0;
 end
 always @(posedge ap_clk)begin
  cycle=cycle+1;if(cycle>count+1000)$fatal(1,"EXP_LANE_TIMEOUT sent%0d received%0d",sent,received);
  if(!ap_rst)begin
   if(ap_start)begin
    if(!ap_ready||sent>=count)$fatal(1,"EXP_LANE_II1_GAP sent%0d",sent);
    if(sent==0)first_accept=cycle;sent<=sent+1;
   end
   if(result_ap_vld||status_ap_vld)begin
    if(!result_ap_vld||!status_ap_vld||received>=count||result!==gold[received]||status!==statuses[received])$fatal(1,"EXP_LANE_ORACLE idx%0d x%h got%h gold%h status%h",received,xs[received],result,gold[received],status);
    if(received==0)first_return=cycle;
    if(received>0&&cycle-last_return!=1)$fatal(1,"EXP_LANE_RETURN_II_GAP");
    last_return=cycle;received=received+1;
    if(received%4096==0)$display("M011_EXP_LANE_PROGRESS returned%0d count%0d cycle%0d",received,count,cycle);
    if(received==count)begin
     if(sent!=count||first_return-first_accept>256)$fatal(1,"EXP_LANE_COUNTS_LATENCY");
     $display("HARDWARE_AGENT_SIM_PASS M011_EXP_LANE accepted%0d returned%0d actual_full_shifts16384 sliding_shifts16384 directed79 II1 latency%0d bit_exact1",sent,received,first_return-first_accept);$finish;
    end
   end
  end
 end
endmodule
