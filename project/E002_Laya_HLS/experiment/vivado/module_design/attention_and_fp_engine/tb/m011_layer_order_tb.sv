`timescale 1ns/1ps
module m011_layer_order_tb;
 logic clk=0,rst_n=0,clear=0;always #5 clk=~clk;
 logic[3:0]candidate_valid;logic[3:0][95:0]candidate_tuple;logic[25:0][15:0]complete_set,unreachable_set,dominated_set,completed,unreachable,dominated;logic[2047:0]av_complete_set,av_unreachable_set,av_dominated_set,av_completed,av_unreachable,av_dominated;logic real_debts_clear,error_valid,all_accounted,final_ready,coverage_fault;logic[95:0]error_tuple;
 laya_attention_check_order_v1 dut(.*);
 function automatic logic[95:0]t(input int s,a,b,c,d,e,f);return {8'(s),16'(a),16'(b),16'(c),16'(d),16'(e),8'(f)};endfunction
 task automatic step;@(posedge clk);#1;endtask
 task automatic pair(input logic[95:0]late,early);
  @(negedge clk);clear=1;step();@(negedge clk);clear=0;candidate_valid=1;candidate_tuple[0]=late;step();if(!error_valid||error_tuple!==late||final_ready)$fatal(1,"late candidate/gate");
  @(negedge clk);candidate_valid=2;candidate_tuple[1]=early;step();if(error_tuple!==early||final_ready)$fatal(1,"logical earlier candidate lost");@(negedge clk);candidate_valid=0;
 endtask
 initial begin
  candidate_valid=0;candidate_tuple=0;complete_set=0;unreachable_set=0;dominated_set=0;av_complete_set=0;av_unreachable_set=0;av_dominated_set=0;real_debts_clear=1;repeat(3)step();@(negedge clk);rst_n=1;
  pair(t(22,0,0,0,0,0,0),t(11,1,0,0,0,0,0));
  pair(t(11,1,0,0,0,0,0),t(11,0,15,6,7,127,0));
  pair(t(24,0,0,0,0,0,0),t(14,1,0,0,0,0,0));
  pair(t(25,127,0,0,0,0,0),t(25,0,1,0,0,0,0));
  pair(t(5,0,0,0,0,0,0),t(4,127,15,31,0,0,0));
  pair(t(0,1,0,0,0,0,0),t(0,0,2,15,63,0,0));
  // This peer supplies explicit coverage events; it does not claim layer execution.
  complete_set='1;complete_set[25]=0;av_complete_set='1;real_debts_clear=0;step();@(negedge clk);complete_set=0;av_complete_set=0;
  if(final_ready||all_accounted)$fatal(1,"missing stage coverage accepted");
  complete_set[25]=16'h00ff;unreachable_set[25]=16'hff00;step();@(negedge clk);complete_set=0;unreachable_set=0;if(!all_accounted||final_ready||coverage_fault)$fatal(1,"debt gate/classification");real_debts_clear=1;#1;if(!final_ready)$fatal(1,"covered and drained final");
  if(completed[25]!==16'h00ff||unreachable[25]!==16'hff00||dominated[25]!=0)$fatal(1,"coverage fabricated");
  $display("HARDWARE_AGENT_SIM_PASS M011_LAYER_ORDER six_reverse_candidates=1 actual_vs_unreachable=1 true_debt_gate=1 peer_scope_only=1");$finish;
 end
 initial begin repeat(1000)@(posedge clk);$fatal(1,"cycle cap");end
endmodule
