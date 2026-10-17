`timescale 1ns/1ps
// Physical PS/destination producer ledger for one parent and sequential views.
// Source A/W READY states come exclusively from their real cache leases.
// This local ledger is not the complete 13BO runtime ledger.
module tm4tn8_matrix_owner_ledger_v2 (
  input logic clk,rst_n,
  input logic claim_valid,
  output logic claim_ready,claim_admitted,claim_reject,
  input logic [15:0] claim_K,claim_N,
  input logic [2:0] claim_rows,
  input logic [3:0] claim_row_block_base,
  input logic [671:0] claim_numeric_identity,
  input logic [95:0] claim_parent_context,
  input logic [63:0] claim_source_ref,claim_a_ref,claim_w_ref,claim_ps_ref,claim_dst_ref,
  input logic [3327:0] claim_model_identity,
  input logic invalidate_valid,
  input logic cancel_parent,
  input logic retire_valid,
  output logic retire_ready,retire_error,
  input logic retire_success,retire_debt_zero,
  input logic [3:0] retire_row_block_base,
  input logic [2:0] retire_rows,
  output logic [2:0] ps_state,dst_state,
  output logic target_invalidated,parent_complete,parent_error,
  output logic [15:0] checked_rows,covered_rows,
  output logic [31:0] claims,view_retirements,parent_publications
);
  localparam logic [2:0] EMPTY=0,FILL=1,READY=2,INVALID=4;
  logic parent_live,view_active,failed,aborting;
  logic [671:0] numeric_id;
  logic [95:0] parent_context;
  logic [63:0] source_ref,a_ref,w_ref,ps_ref,dst_ref;
  logic [3327:0] model_id;
  logic [15:0] K,N;
  logic [4:0] next_row;
  logic [3:0] view_row;
  logic [2:0] view_rows;
  logic [31:0] last_ps_epoch,last_dst_epoch[0:5],last_task_id;
  logic [2:0] destination_index;
  logic destination_ok,shape_ok,base_ok,same_parent,admission_ok;
  always_comb begin
    destination_ok=1;destination_index=0;shape_ok=0;
    case(claim_parent_context[39:32])
      8'h30:begin destination_index=0;shape_ok=claim_K==1024 && claim_N==3072 && claim_dst_ref[39:32]==5;end
      8'h31:begin destination_index=1;shape_ok=claim_K==1024 && claim_N==1024 && claim_dst_ref[39:32]==3;end
      8'h32:begin destination_index=2;shape_ok=claim_K==1024 && claim_N==5248 && claim_dst_ref[39:32]==6;end
      8'h33:begin destination_index=1;shape_ok=claim_K==2624 && claim_N==1024 && claim_dst_ref[39:32]==3;end
      8'h34:begin destination_index=3;shape_ok=claim_K==1024 && claim_N==4096 && claim_dst_ref[39:32]==9;end
      8'h35:begin destination_index=1;shape_ok=claim_K==4096 && claim_N==1024 && claim_dst_ref[39:32]==3;end
      8'h36:begin destination_index=4;shape_ok=claim_K==1024 && claim_N==1024 && claim_dst_ref[39:32]==10 && claim_dst_ref[55:48]==0;end
      8'h37:begin destination_index=5;shape_ok=claim_K==256 && claim_N==2 && claim_dst_ref[39:32]==10 && claim_dst_ref[55:48]==4;end
      default:destination_ok=0;
    endcase
    base_ok=shape_ok && destination_ok &&
      claim_numeric_identity[63:0]!=0 && claim_numeric_identity[127:64]!=0 &&
      claim_numeric_identity[143:128]>=1 && claim_numeric_identity[143:128]<=2 &&
      claim_numeric_identity[159:144]>=64 && claim_numeric_identity[159:144]<=1024 &&
      claim_numeric_identity[671:160]==claim_model_identity[511:0] &&
      claim_parent_context[31:0]!=0 && claim_parent_context[95:88]>=1 &&
      claim_parent_context[95:88]<=16 && (claim_rows==1 || claim_rows==4) &&
      (5'(claim_row_block_base)+5'(claim_rows))<=claim_parent_context[95:88] &&
      claim_a_ref[39:32]==8'h22 && claim_w_ref[39:32]==8'h23 && claim_ps_ref[39:32]==8'h24 &&
      claim_source_ref[31:0]!=0 && claim_a_ref[31:0]!=0 && claim_w_ref[31:0]!=0 &&
      claim_ps_ref[31:0]!=0 && claim_dst_ref[31:0]!=0 &&
      claim_source_ref[63:56]==0 && claim_a_ref[63:56]==0 && claim_w_ref[63:56]==0 &&
      claim_ps_ref[63:56]==0 && claim_dst_ref[63:56]==0;
    same_parent=claim_numeric_identity==numeric_id && claim_parent_context==parent_context &&
      claim_source_ref==source_ref && claim_a_ref==a_ref && claim_w_ref==w_ref &&
      claim_ps_ref==ps_ref && claim_dst_ref==dst_ref && claim_model_identity==model_id &&
      claim_K==K && claim_N==N;
    admission_ok=base_ok && (parent_live ? same_parent && claim_row_block_base==next_row :
      claim_row_block_base==0 && claim_parent_context[31:0]>last_task_id &&
      last_ps_epoch!=32'hffffffff && claim_ps_ref[31:0]==last_ps_epoch+1 &&
      last_dst_epoch[destination_index]!=32'hffffffff &&
      claim_dst_ref[31:0]==last_dst_epoch[destination_index]+1);
  end
  assign claim_ready=rst_n && !view_active;
  assign claim_admitted=claim_ready && admission_ok;
  assign target_invalidated=dst_state==INVALID;
  assign retire_ready=rst_n && view_active && retire_debt_zero;
  assign retire_error=retire_valid && retire_ready &&
      (retire_row_block_base!=view_row || retire_rows!=view_rows);
  always_ff @(posedge clk)begin
    if(!rst_n)begin
      parent_live<=0;view_active<=0;failed<=0;aborting<=0;ps_state<=EMPTY;dst_state<=EMPTY;
      last_ps_epoch<=0;last_task_id<=0;next_row<=0;view_row<=0;view_rows<=0;
      checked_rows<=0;covered_rows<=0;parent_complete<=0;parent_error<=0;
      claims<=0;view_retirements<=0;parent_publications<=0;claim_reject<=0;
      for(int d=0;d<6;d++)last_dst_epoch[d]<=0;
    end else begin
      claim_reject<=0;parent_complete<=0;
      if(claim_valid && claim_ready)begin
        claim_reject<=!admission_ok;
        if(admission_ok)begin
          view_active<=1;view_row<=claim_row_block_base;view_rows<=claim_rows;claims<=claims+1;
          if(!parent_live)begin
            parent_live<=1;failed<=0;aborting<=0;parent_error<=0;ps_state<=FILL;dst_state<=FILL;
            next_row<=0;checked_rows<=0;covered_rows<=0;
            K<=claim_K;N<=claim_N;numeric_id<=claim_numeric_identity;parent_context<=claim_parent_context;
            source_ref<=claim_source_ref;a_ref<=claim_a_ref;w_ref<=claim_w_ref;
            ps_ref<=claim_ps_ref;dst_ref<=claim_dst_ref;model_id<=claim_model_identity;
            last_ps_epoch<=claim_ps_ref[31:0];last_dst_epoch[destination_index]<=claim_dst_ref[31:0];
            last_task_id<=claim_parent_context[31:0];
          end
        end
      end
      if(invalidate_valid && parent_live)begin failed<=1;parent_error<=1;ps_state<=INVALID;dst_state<=INVALID;end
      if(cancel_parent && parent_live)begin
        aborting<=1;failed<=1;parent_error<=1;ps_state<=INVALID;dst_state<=INVALID;
      end
      if(parent_live && !view_active && (aborting || cancel_parent) && retire_debt_zero)begin
        parent_live<=0;aborting<=0;
      end
      if(retire_valid && retire_ready)begin
        if(retire_row_block_base!=view_row || retire_rows!=view_rows)begin
          failed<=1;parent_error<=1;ps_state<=INVALID;dst_state<=INVALID;
        end else begin
          view_active<=0;view_retirements<=view_retirements+1;
          next_row<=5'(view_row)+5'(view_rows);
          for(int r=0;r<4;r++)if(r<view_rows)begin
            checked_rows[int'(view_row)+r]<=1;
            if(retire_success && !failed && !invalidate_valid)covered_rows[int'(view_row)+r]<=1;
          end
          if(!retire_success)begin failed<=1;parent_error<=1;ps_state<=INVALID;dst_state<=INVALID;end
          if(5'(view_row)+5'(view_rows)==parent_context[95:88] || aborting || cancel_parent)begin
            parent_live<=0;parent_complete<=1;aborting<=0;
            if(!failed && retire_success && !invalidate_valid && !aborting && !cancel_parent)begin
              ps_state<=READY;dst_state<=READY;parent_publications<=parent_publications+1;
            end else begin ps_state<=INVALID;dst_state<=INVALID;parent_error<=1;end
          end
        end
      end
    end
  end
endmodule
