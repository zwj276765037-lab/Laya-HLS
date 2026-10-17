`timescale 1ns/1ps
module tanh_libm_stream_helper_tb;
 reg clk=0; always #3.333333 clk=~clk;
 reg reset=1,start=0;
 reg [31:0] op=0,a=0,b=0;
 wire ready,idle,done,valid; wire [31:0] result;
 tanh_libm_stream_helper dut(.ap_clk(clk),.ap_rst(reset),.ap_start(start),
  .ap_ready(ready),.ap_idle(idle),.ap_done(done),.op(op),.a(a),.b(b),
  .result(result),.result_ap_vld(valid));
 reg [31:0] data[0:16383];
 integer count=0,accepted=0,retired=0,cycle=0,i,j,opcounts[0:2];
 string file_name;
 always @(posedge clk) begin
  cycle=cycle+1; if(cycle>200000) $fatal(1,"STREAM_HELPER_CYCLE_CAP");
  if(!reset) begin
   if(start&&ready) accepted=accepted+1;
   if(valid) begin
    if(retired>=accepted || result!==data[4*retired+3])
     $fatal(1,"STREAM_HELPER_RTL_FAIL index=%0d op=%0d a=%08x b=%08x got=%08x gold=%08x",retired,data[4*retired],data[4*retired+1],data[4*retired+2],result,data[4*retired+3]);
    opcounts[data[4*retired]]=opcounts[data[4*retired]]+1;
    retired=retired+1;
    if((retired%128)==0) $display("TANH_PROGRESS stream_helper retired=%0d cycle=%0d",retired,cycle);
   end
  end
 end
 initial begin
  if(!$value$plusargs("OPS_FILE=%s",file_name)||!$value$plusargs("OPS_COUNT=%d",count)) $fatal(1,"MISSING_OPS");
  if(count<1030 || count>4096) $fatal(1,"BAD_OPS_COUNT");
  $readmemh(file_name,data,0,4*count-1);
  for(i=0;i<4*count;i=i+1) if($isunknown(data[i])) $fatal(1,"UNKNOWN_OPS");
  for(i=0;i<3;i=i+1) opcounts[i]=0;
  repeat(4) @(negedge clk); reset=0; start=1;
  for(j=0;j<count;j=j+1) begin
   op=data[4*j]; a=data[4*j+1]; b=data[4*j+2];
   do @(posedge clk); while(!ready);
   @(negedge clk);
  end
  start=0; wait(retired==count); @(negedge clk);
  $display("TANH_STREAM_HELPER_RTL_PASS count=%0d add=%0d mul=%0d div=%0d original_add52_retained=1 cycles=%0d",count,opcounts[0],opcounts[1],opcounts[2],cycle);
  $finish;
 end
endmodule
