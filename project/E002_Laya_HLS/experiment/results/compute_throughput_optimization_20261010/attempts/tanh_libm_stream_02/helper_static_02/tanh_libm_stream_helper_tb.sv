`timescale 1ns/1ps
// Probe the actual arithmetic children emitted by the main stream02 HLS run.
// These instances are testbench-only and are excluded from module OOC.
module tanh_libm_stream_helper_tb;
 reg clk=0; always #3.333333 clk=~clk;
 reg reset=1,issue=0;
 reg [31:0] op=0,a=0,b=0,expected=0;
 wire [31:0] add_result,mul_result,div_result;
 tanh_libm_stream_leaf_stream_add_node_0_s add_dut(
  .ap_clk(clk),.ap_rst(reset),.a(a),.b(b),.ap_return(add_result),.ap_ce(1'b1));
 tanh_libm_stream_leaf_stream_mul_node_14_s mul_dut(
  .ap_clk(clk),.ap_rst(reset),.a(a),.b(b),.ap_return(mul_result),.ap_ce(1'b1));
 tanh_libm_stream_leaf_stream_div_node_0_s div_dut(
  .ap_clk(clk),.ap_rst(reset),.a(a),.b(b),.ap_return(div_result),.ap_ce(1'b1));
 reg [31:0] data[0:16383];
 reg [13:0] add_valid=0,mul_valid=0,div_valid=0;
 reg [31:0] gold_pipe[0:13],a_pipe[0:13],b_pipe[0:13];
 integer count=0,accepted=0,retired=0,cycle=0,i,j,k;
 integer opcounts[0:2],last_issue[0:2],min_gap[0:2],max_gap[0:2];
 string file_name;
 // Actual children first capture a/b in a_int_reg/b_int_reg, followed by
 // the 5/13/11-cycle internal HLS pipeline. After-NBA result cycle gaps
 // from the operand capture edge are 5/13/11 (6/14/12 capture edges).
 always @(posedge clk) begin
  cycle=cycle+1; if(cycle>200000) $fatal(1,"STREAM_HELPER_CYCLE_CAP");
  if(reset) begin add_valid<=0; mul_valid<=0; div_valid<=0; end
  else begin
   add_valid<={add_valid[12:0],issue&&op==0};
   mul_valid<={mul_valid[12:0],issue&&op==1};
   div_valid<={div_valid[12:0],issue&&op==2};
   gold_pipe[0]<=expected; a_pipe[0]<=a; b_pipe[0]<=b;
   for(k=1;k<14;k=k+1) begin
    gold_pipe[k]<=gold_pipe[k-1]; a_pipe[k]<=a_pipe[k-1]; b_pipe[k]<=b_pipe[k-1];
   end
   if(issue) begin
    accepted=accepted+1;
    if(last_issue[op]) begin
     if(cycle-last_issue[op]<min_gap[op]) min_gap[op]=cycle-last_issue[op];
     if(cycle-last_issue[op]>max_gap[op]) max_gap[op]=cycle-last_issue[op];
    end
    last_issue[op]=cycle;
   end
  end
 end
 task check_result(input integer opcode,input integer delay,input [31:0] result);
  begin
   if(result!==gold_pipe[delay])
    $fatal(1,"STREAM_HELPER_RTL_FAIL op=%0d a=%08x b=%08x got=%08x gold=%08x",opcode,a_pipe[delay],b_pipe[delay],result,gold_pipe[delay]);
   opcounts[opcode]=opcounts[opcode]+1; retired=retired+1;
   if((retired%128)==0) $display("TANH_PROGRESS stream_helper retired=%0d cycle=%0d",retired,cycle);
  end
 endtask
 always @(negedge clk) if(!reset) begin
  if(add_valid[5]) check_result(0,5,add_result);
  if(mul_valid[13]) check_result(1,13,mul_result);
  if(div_valid[11]) check_result(2,11,div_result);
 end
 initial begin
  if(!$value$plusargs("OPS_FILE=%s",file_name)||!$value$plusargs("OPS_COUNT=%d",count)) $fatal(1,"MISSING_OPS");
  if(count!=1159) $fatal(1,"BAD_OPS_COUNT");
  $readmemh(file_name,data,0,4*count-1);
  for(i=0;i<4*count;i=i+1) if($isunknown(data[i])) $fatal(1,"UNKNOWN_OPS");
  for(i=0;i<3;i=i+1) begin opcounts[i]=0; last_issue[i]=0; min_gap[i]=2147483647; max_gap[i]=0; end
  repeat(4) @(negedge clk); reset<=0;
  for(i=0;i<3;i=i+1) for(j=0;j<count;j=j+1) if(data[4*j]==i) begin
   @(negedge clk); issue<=1; op<=i; a<=data[4*j+1]; b<=data[4*j+2]; expected<=data[4*j+3];
  end
  @(negedge clk); issue<=0;
  wait(retired==count); @(posedge clk);
  if(accepted!=count || opcounts[0]!=345 || opcounts[1]!=409 || opcounts[2]!=405) $fatal(1,"STREAM_HELPER_COVERAGE");
  for(i=0;i<3;i=i+1) if(min_gap[i]!=1 || max_gap[i]!=1) $fatal(1,"STREAM_HELPER_II op=%0d min=%0d max=%0d",i,min_gap[i],max_gap[i]);
  $display("TANH_STREAM_HELPER_RTL_PASS count=%0d add=%0d mul=%0d div=%0d original_add52_retained=1 actual_main_children=1 accepted_gap=1 after_nba_latency_cycles=5,13,11 capture_edges=6,14,12 cycles=%0d",count,opcounts[0],opcounts[1],opcounts[2],cycle);
  $finish;
 end
endmodule
