`timescale 1ns/1ps
module m011_r004_check_tb;
 logic clk=0,rst_n=0,clear=0;always #5 clk=~clk;
 logic[3:0]candidate_valid;logic[3:0][95:0]candidate_tuple;logic[25:0][15:0]complete_set,unreachable_set,dominated_set,completed,unreachable,dominated;logic[2047:0]av_complete_set,av_unreachable_set,av_dominated_set,av_completed,av_unreachable,av_dominated;logic real_debts_clear,error_valid,all_accounted,final_ready,coverage_fault;logic[95:0]error_tuple;
 logic[31:0]first_conflict;
 logic old_error_valid,old_all_accounted,old_final_ready,old_coverage_fault;logic[95:0]old_error_tuple;
 logic[25:0][15:0]old_completed,old_unreachable,old_dominated;logic[2047:0]old_av_completed,old_av_unreachable,old_av_dominated;
 laya_attention_check_order_v1 dut(.*);
 m011_r004_legacy_check original(.clk,.rst_n,.clear,.candidate_valid,.candidate_tuple,.complete_set,.unreachable_set,.dominated_set,.av_complete_set,.av_unreachable_set,.av_dominated_set,.real_debts_clear,.error_valid(old_error_valid),.error_tuple(old_error_tuple),.completed(old_completed),.unreachable(old_unreachable),.dominated(old_dominated),.av_completed(old_av_completed),.av_unreachable(old_av_unreachable),.av_dominated(old_av_dominated),.all_accounted(old_all_accounted),.final_ready(old_final_ready),.coverage_fault(old_coverage_fault));
 task automatic equivalent;
  if({error_valid,error_tuple,completed,unreachable,dominated,av_completed,av_unreachable,av_dominated,all_accounted,final_ready,coverage_fault}!=={old_error_valid,old_error_tuple,old_completed,old_unreachable,old_dominated,old_av_completed,old_av_unreachable,old_av_dominated,old_all_accounted,old_final_ready,old_coverage_fault})$fatal(1,"legal classification differs from original peer");
 endtask
 task automatic clean;
  @(negedge clk);clear=1;candidate_valid=0;complete_set=0;unreachable_set=0;dominated_set=0;av_complete_set=0;av_unreachable_set=0;av_dominated_set=0;step();@(negedge clk);clear=0;step();equivalent();
 endtask
 task automatic put_class(input int kind,index,cls);
  if(kind==0)case(cls)1:complete_set[index/16][index%16]=1;2:unreachable_set[index/16][index%16]=1;3:dominated_set[index/16][index%16]=1;endcase
  else case(cls)1:av_complete_set[index]=1;2:av_unreachable_set[index]=1;3:av_dominated_set[index]=1;endcase
 endtask

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
  equivalent();
  clean();
  @(negedge clk);for(int i=0;i<416;i++)put_class(0,i,1+i%3);for(int i=0;i<2048;i++)put_class(1,i,1+i%3);step();equivalent();step();equivalent();
  if(!final_ready||coverage_fault)$fatal(1,"legal repeated classification failed");
  for(int kind=0;kind<2;kind++)for(int oldclass=1;oldclass<=3;oldclass++)for(int newclass=1;newclass<=3;newclass++)if(oldclass!=newclass)begin
   logic[31:0]first;int index;index=kind?2047:415;clean();@(negedge clk);put_class(kind,index,oldclass);step();equivalent();@(negedge clk);complete_set=0;unreachable_set=0;dominated_set=0;av_complete_set=0;av_unreachable_set=0;av_dominated_set=0;put_class(kind,index,newclass);step();
   first={14'b0,1'(kind),12'(index),2'(oldclass),3'(1<<(newclass-1))};
   if(!coverage_fault||final_ready||all_accounted||first_conflict!==first)$fatal(1,"class conflict record kind%0d old%0d new%0d got%h expected%h",kind,oldclass,newclass,first_conflict,first);
   @(negedge clk);put_class(0,0,1);put_class(0,0,2);real_debts_clear=0;step();if(first_conflict!==first||final_ready)$fatal(1,"first fault not sticky");
  end
  for(int mask=3;mask<8;mask++)if(mask!=4)begin
   logic[31:0]first;clean();@(negedge clk);complete_set[0][0]=mask[0];unreachable_set[0][0]=mask[1];dominated_set[0][0]=mask[2];step();first={14'b0,1'b0,12'b0,2'b0,3'(mask)};if(!coverage_fault||first_conflict!==first||final_ready)$fatal(1,"same-edge class conflict mask%0d",mask);
  end
  clean();real_debts_clear=1;@(negedge clk);complete_set='1;av_complete_set='1;step();@(negedge clk);complete_set=0;av_complete_set=0;#0.1;if(!final_ready)$fatal(1,"full legal cover not ready");unreachable_set[0][0]=1;#0.1;if(final_ready||all_accounted)$fatal(1,"same-edge conflicting final accepted");step();if(!coverage_fault)$fatal(1,"same-edge final conflict not latched");
  clean();real_debts_clear=1;step();equivalent();
  $display("HARDWARE_AGENT_SIM_PASS M011_R004_CHECK original_reverse6 all2464legal_exact repeated3classes12conflicts sameedge4 first_fault_hold debt_gate clear_recovery peer_scope_only");$finish;
 end
 initial begin repeat(1000)@(posedge clk);$fatal(1,"cycle cap");end
endmodule

`timescale 1ns/1ps
// Original stage-dependent tuple: {stage8,a16,b16,c16,d16,e16,f8}.
// Input:token/plane/head/channel. RoPE:token/head/pair or channel.
// QK:head/tile/level/tile-query/key/node. SM:head/query/node.
// AV:key/head/query/channel. Local rank numbers are never compared across heads.
module m011_r004_legacy_check(
 input logic clk,rst_n,clear,
 input logic[3:0]candidate_valid,input logic[3:0][95:0]candidate_tuple,
 input logic[25:0][15:0]complete_set,unreachable_set,dominated_set,
 input logic[2047:0]av_complete_set,av_unreachable_set,av_dominated_set,
 input logic real_debts_clear,
 output logic error_valid,output logic[95:0]error_tuple,
 output logic[25:0][15:0]completed,unreachable,dominated,
 output logic[2047:0]av_completed,av_unreachable,av_dominated,
 output logic all_accounted,final_ready,coverage_fault
);
 logic next_valid;logic[95:0]next_tuple;
 always_comb begin
  next_valid=error_valid;next_tuple=error_tuple;
  for(int i=0;i<4;i++)if(candidate_valid[i]&&(!next_valid||candidate_tuple[i]<next_tuple))begin next_valid=1;next_tuple=candidate_tuple[i];end
  all_accounted=1;
  for(int s=0;s<26;s++)if((completed[s]|unreachable[s]|dominated[s])!=16'hffff)all_accounted=0;
  if((av_completed|av_unreachable|av_dominated)!={2048{1'b1}})all_accounted=0;
 end
 assign final_ready=rst_n&&all_accounted&&real_debts_clear&&!coverage_fault;
 always_ff@(posedge clk)begin
  if(!rst_n||clear)begin error_valid<=0;error_tuple<=0;completed<=0;unreachable<=0;dominated<=0;av_completed<=0;av_unreachable<=0;av_dominated<=0;coverage_fault<=0;end
  else begin
   error_valid<=next_valid;error_tuple<=next_tuple;
   completed<=completed|complete_set;unreachable<=unreachable|unreachable_set;dominated<=dominated|dominated_set;
   av_completed<=av_completed|av_complete_set;av_unreachable<=av_unreachable|av_unreachable_set;av_dominated<=av_dominated|av_dominated_set;
   if(((completed|complete_set)&(unreachable|unreachable_set))!=0||((completed|complete_set)&(dominated|dominated_set))!=0||((unreachable|unreachable_set)&(dominated|dominated_set))!=0)coverage_fault<=1;
   if(((av_completed|av_complete_set)&(av_unreachable|av_unreachable_set))!=0||((av_completed|av_complete_set)&(av_dominated|av_dominated_set))!=0||((av_unreachable|av_unreachable_set)&(av_dominated|av_dominated_set))!=0)coverage_fault<=1;
  end
 end
endmodule
