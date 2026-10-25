`timescale 1ns/1ps
// Original stage-dependent tuple: {stage8,a16,b16,c16,d16,e16,f8}.
// Input:token/plane/head/channel. RoPE:token/head/pair or channel.
// QK:head/tile/level/tile-query/key/node. SM:head/query/node.
// AV:key/head/query/channel. Local rank numbers are never compared across heads.
module laya_attention_check_order_v1(
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
