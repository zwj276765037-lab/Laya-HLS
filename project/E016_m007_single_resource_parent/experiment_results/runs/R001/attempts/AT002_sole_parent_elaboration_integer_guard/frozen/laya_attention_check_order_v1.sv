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
 output logic all_accounted,final_ready,coverage_fault,output logic[31:0]first_conflict
);
 // NONE00/COMPLETE01/UNREACHABLE10/DOMINATED11 in two packed planes.
 logic[25:0][15:0]class_lo,class_hi;
 logic[2047:0]av_class_lo,av_class_hi;
 logic[25:0][15:0]stage_conflict;
 logic[2047:0]av_conflict;
 logic next_valid;logic[95:0]next_tuple;
 logic conflict_found;logic[31:0]conflict_record;
 assign completed=class_lo&~class_hi;
 assign unreachable=class_hi&~class_lo;
 assign dominated=class_lo&class_hi;
 assign av_completed=av_class_lo&~av_class_hi;
 assign av_unreachable=av_class_hi&~av_class_lo;
 assign av_dominated=av_class_lo&av_class_hi;
 assign stage_conflict=((completed|complete_set)&(unreachable|unreachable_set))|((completed|complete_set)&(dominated|dominated_set))|((unreachable|unreachable_set)&(dominated|dominated_set));
 assign av_conflict=((av_completed|av_complete_set)&(av_unreachable|av_unreachable_set))|((av_completed|av_complete_set)&(av_dominated|av_dominated_set))|((av_unreachable|av_unreachable_set)&(av_dominated|av_dominated_set));
 always_comb begin
  next_valid=error_valid;next_tuple=error_tuple;
  for(int i=0;i<4;i++)if(candidate_valid[i]&&(!next_valid||candidate_tuple[i]<next_tuple))begin next_valid=1;next_tuple=candidate_tuple[i];end
  all_accounted=(&(class_lo|class_hi))&&(&(av_class_lo|av_class_hi))&&!coverage_fault;
  conflict_found=0;conflict_record=0;
  // Priority only encodes a real conflict; normal operation updates packed planes.
  if(!coverage_fault&&(|stage_conflict))begin
   for(int s=0;s<26;s++)for(int h=0;h<16;h++)if(!conflict_found&&stage_conflict[s][h])begin
    conflict_found=1;conflict_record={14'b0,1'b0,12'(s*16+h),class_hi[s][h],class_lo[s][h],dominated_set[s][h],unreachable_set[s][h],complete_set[s][h]};
   end
  end else if(!coverage_fault&&(|av_conflict))begin
   for(int i=0;i<2048;i++)if(!conflict_found&&av_conflict[i])begin
    conflict_found=1;conflict_record={14'b0,1'b1,12'(i),av_class_hi[i],av_class_lo[i],av_dominated_set[i],av_unreachable_set[i],av_complete_set[i]};
   end
  end
  if(conflict_found)all_accounted=0;
 end
 assign final_ready=rst_n&&all_accounted&&real_debts_clear&&!coverage_fault;
 always_ff@(posedge clk)begin
  if(!rst_n||clear)begin
   error_valid<=0;error_tuple<=0;class_lo<=0;class_hi<=0;av_class_lo<=0;av_class_hi<=0;coverage_fault<=0;first_conflict<=0;
  end else begin
   error_valid<=next_valid;error_tuple<=next_tuple;
   class_lo<=class_lo|complete_set|dominated_set;class_hi<=class_hi|unreachable_set|dominated_set;
   av_class_lo<=av_class_lo|av_complete_set|av_dominated_set;av_class_hi<=av_class_hi|av_unreachable_set|av_dominated_set;
   if(conflict_found)begin coverage_fault<=1;first_conflict<=conflict_record;end
  end
 end
endmodule
