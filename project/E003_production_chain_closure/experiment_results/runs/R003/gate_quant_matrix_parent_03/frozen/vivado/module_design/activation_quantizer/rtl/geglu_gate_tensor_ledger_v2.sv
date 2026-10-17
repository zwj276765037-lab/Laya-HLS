`timescale 1ns/1ps

// Persistent GATE tensor owner and finite per-window provenance table.
// Payload remains in the external FF BO; this block records only identities,
// row coverage, consumer bindings and real write/read retirement.
module geglu_gate_tensor_ledger_v2(
  input logic clk,rst_n,cancel,
  input logic claim_valid,
  output logic claim_ready,claim_admitted,claim_rejected,
  input logic claim_plan_admitted,
  input logic [671:0] claim_numeric_identity,
  input logic [95:0] claim_producer_context,claim_quant_context,claim_linear_context,
  input logic [63:0] claim_source_ref,claim_gate_ref,claim_a_ref,claim_w_ref,claim_ps_ref,claim_dst_ref,
  input logic [7:0] claim_gate_region,claim_dst_region,
  input logic [327:0] claim_output_binding,
  input logic window_retire_valid,
  output logic window_retire_ready,window_retire_error,
  input logic window_retire_success,window_write_debt_zero,
  output logic tensor_published,cancel_done,
  output logic [2:0] gate_owner_state,
  output logic [7:0] next_window,
  output logic [127:0] valid_windows,covered_windows,consumed_windows,
  output logic [2047:0] covered_rows,
  input logic gate_acquire_valid,
  output logic gate_acquire_ready,gate_acquire_done,gate_acquire_error,
  input logic [671:0] gate_acquire_numeric_identity,
  input logic [63:0] gate_acquire_ref,
  input logic [6:0] gate_acquire_window,
  input logic [551:0] gate_acquire_binding,
  input logic gate_release_valid,
  output logic gate_release_ready,gate_release_done,gate_release_error,
  input logic [671:0] gate_release_numeric_identity,
  input logic [63:0] gate_release_ref,
  input logic [6:0] gate_release_window,
  input logic [551:0] gate_release_binding,
  input logic gate_release_read_debt_zero,
  input logic tensor_release_valid,
  output logic tensor_release_ready,tensor_release_done,tensor_release_error,
  input logic [671:0] tensor_release_numeric_identity,
  input logic [63:0] tensor_release_ref,
  input logic tensor_release_debt_zero
);
  localparam logic [2:0] EMPTY=0,FILL=1,READY=2,LEASED=3,INVALID=4;
  localparam int TENSOR_KEY_BITS=1152;
  logic [2:0] owner_state;
  logic [TENSOR_KEY_BITS-1:0] tensor_key,claim_key;
  logic [551:0] binding[0:127],claim_binding;
  logic [671:0] numeric_identity;
  logic [63:0] gate_ref;
  logic [31:0] last_gate_epoch;
  logic [7:0] windows_total,claim_windows_total;
  logic [11:0] rows_total,claim_rows_total,claim_global_row0,active_global_row0;
  logic [6:0] claim_window,active_window,leased_window;
  logic [4:0] active_rows;
  logic window_active,read_leased,aborting;
  logic context_ok,refs_ok,new_tensor,same_tensor,claim_ok,acquire_ok,release_ok;
  logic [31:0] last_producer_task,last_quant_task,last_linear_task;
  logic [2047:0] prospective_rows;
  logic [127:0] prospective_windows,window_mask;
  logic all_rows_after,all_windows_after,all_consumed;

  always_comb begin
    claim_rows_total=12'(claim_numeric_identity[143:128])*12'(claim_numeric_identity[159:144]);
    claim_global_row0=12'(claim_producer_context[63:56])*12'(claim_numeric_identity[159:144])+
      12'(claim_producer_context[87:72]);
    claim_window=7'(claim_producer_context[63:56])*
      7'((claim_numeric_identity[159:144]+15)/16)+7'(claim_producer_context[87:72]>>4);
    claim_windows_total=8'(claim_numeric_identity[143:128])*8'((claim_numeric_identity[159:144]+15)/16);
    context_ok=claim_numeric_identity[63:0]!=0 && claim_numeric_identity[127:64]!=0 &&
      claim_numeric_identity[143:128]>=1 && claim_numeric_identity[143:128]<=2 &&
      (claim_numeric_identity[159:144]==64 || claim_numeric_identity[159:144]==128 ||
       claim_numeric_identity[159:144]==256 || claim_numeric_identity[159:144]==512 ||
       claim_numeric_identity[159:144]==1024) && claim_windows_total>=1 && claim_windows_total<=128 &&
      claim_producer_context[31:0]!=0 && claim_quant_context[31:0]!=0 && claim_linear_context[31:0]!=0 &&
      claim_producer_context[39:32]==8'h60 && claim_quant_context[39:32]==8'h20 &&
      claim_linear_context[39:32]==8'h33 && claim_producer_context[47:40]==2 &&
      claim_producer_context[71:64]==0 && claim_producer_context[63:56]<claim_numeric_identity[143:128] &&
      claim_producer_context[75:72]==0 && claim_producer_context[95:88]>=1 &&
      claim_producer_context[95:88]<=16 &&
      17'(claim_producer_context[87:72])+17'(claim_producer_context[95:88])<=17'(claim_numeric_identity[159:144]) &&
      claim_quant_context[87:40]==claim_producer_context[87:40] &&
      claim_quant_context[95:88]==claim_producer_context[95:88] &&
      claim_linear_context[87:40]==claim_producer_context[87:40] &&
      claim_linear_context[95:88]==claim_producer_context[95:88] &&
      claim_producer_context[31:0]<claim_quant_context[31:0] &&
      claim_quant_context[31:0]<claim_linear_context[31:0];
    refs_ok=claim_source_ref[39:32]==6 && claim_gate_ref[39:32]==7 &&
      claim_a_ref[39:32]==8'h22 && claim_w_ref[39:32]==8'h23 &&
      claim_ps_ref[39:32]==8'h24 && claim_dst_ref[39:32]==3 &&
      claim_source_ref[31:0]!=0 && claim_gate_ref[31:0]!=0 && claim_a_ref[31:0]!=0 &&
      claim_w_ref[31:0]!=0 && claim_ps_ref[31:0]!=0 && claim_dst_ref[31:0]!=0 &&
      claim_source_ref[63:56]==0 && claim_gate_ref[63:56]==0 && claim_a_ref[63:56]==0 &&
      claim_w_ref[63:56]==0 && claim_ps_ref[63:56]==0 && claim_dst_ref[63:56]==0;
    claim_key={claim_numeric_identity,claim_source_ref,claim_gate_ref,claim_gate_region,
      claim_output_binding,claim_producer_context[55:40]};
    claim_binding={claim_producer_context,claim_quant_context,claim_linear_context,
      claim_a_ref,claim_w_ref,claim_ps_ref,claim_dst_ref,claim_dst_region};
    new_tensor=(owner_state==EMPTY || owner_state==INVALID) && claim_gate_ref[31:0]!=32'hffffffff &&
      claim_gate_ref[31:0]==last_gate_epoch+1 && claim_window==0;
    same_tensor=owner_state==FILL && claim_key==tensor_key && claim_gate_ref==gate_ref;
    claim_ok=claim_plan_admitted && context_ok && refs_ok && claim_window<128 &&
      (new_tensor || (same_tensor && claim_window==next_window && !valid_windows[claim_window] &&
       claim_producer_context[31:0]>last_producer_task &&
       claim_quant_context[31:0]>last_quant_task && claim_linear_context[31:0]>last_linear_task));
    prospective_rows=covered_rows;
    for(int r=0;r<16;r++)if(r<active_rows && active_global_row0+r<2048 && window_retire_success)
      prospective_rows[active_global_row0+r]=1;
    prospective_windows=covered_windows;
    if(window_retire_success)prospective_windows[active_window]=1;
    window_mask=0;
    for(int w=0;w<128;w++)if(w<windows_total)window_mask[w]=1;
    all_rows_after=1;
    for(int r=0;r<2048;r++)if(r<rows_total && !prospective_rows[r])all_rows_after=0;
    all_windows_after=(prospective_windows & window_mask)==window_mask;
    acquire_ok=owner_state==READY && gate_acquire_numeric_identity==numeric_identity &&
      gate_acquire_ref==gate_ref && gate_acquire_window<windows_total &&
      valid_windows[gate_acquire_window] && covered_windows[gate_acquire_window] &&
      !consumed_windows[gate_acquire_window] && gate_acquire_binding==binding[gate_acquire_window];
    release_ok=read_leased && gate_release_numeric_identity==numeric_identity &&
      gate_release_ref==gate_ref && gate_release_window==leased_window &&
      gate_release_binding==binding[leased_window];
    all_consumed=(consumed_windows & window_mask)==window_mask;
  end

  assign gate_owner_state=read_leased ? LEASED : owner_state;
  assign claim_ready=rst_n && !window_active && !read_leased && !aborting && owner_state!=READY;
  assign claim_admitted=claim_ready && claim_ok;
  assign window_retire_ready=rst_n && window_active && window_write_debt_zero;
  assign gate_acquire_ready=rst_n && !window_active && !read_leased && !aborting;
  assign gate_release_ready=rst_n && read_leased && gate_release_read_debt_zero;
  assign tensor_release_ready=rst_n && owner_state==READY && !read_leased && !window_active &&
    all_consumed && tensor_release_debt_zero;

  always_ff @(posedge clk)begin
    if(!rst_n)begin
      owner_state<=EMPTY;tensor_key<=0;numeric_identity<=0;gate_ref<=0;last_gate_epoch<=0;
      last_producer_task<=0;last_quant_task<=0;last_linear_task<=0;
      windows_total<=0;rows_total<=0;next_window<=0;valid_windows<=0;covered_windows<=0;consumed_windows<=0;
      covered_rows<=0;window_active<=0;active_window<=0;active_rows<=0;active_global_row0<=0;read_leased<=0;
      leased_window<=0;aborting<=0;claim_rejected<=0;window_retire_error<=0;
      tensor_published<=0;cancel_done<=0;
      gate_acquire_done<=0;gate_acquire_error<=0;gate_release_done<=0;gate_release_error<=0;
      tensor_release_done<=0;tensor_release_error<=0;
      for(int w=0;w<128;w++)binding[w]<=0;
    end else begin
      claim_rejected<=0;window_retire_error<=0;tensor_published<=0;cancel_done<=0;
      gate_acquire_done<=0;gate_acquire_error<=0;gate_release_done<=0;gate_release_error<=0;
      tensor_release_done<=0;tensor_release_error<=0;
      if(cancel && owner_state!=EMPTY)begin aborting<=1;owner_state<=INVALID;end
      if(claim_valid && claim_ready)begin
        claim_rejected<=!claim_ok;
        if(claim_ok)begin
          if(new_tensor)begin
            owner_state<=FILL;tensor_key<=claim_key;numeric_identity<=claim_numeric_identity;
            gate_ref<=claim_gate_ref;last_gate_epoch<=claim_gate_ref[31:0];
            windows_total<=claim_windows_total;rows_total<=claim_rows_total;
            next_window<=0;valid_windows<=0;covered_windows<=0;consumed_windows<=0;covered_rows<=0;
          end
          last_producer_task<=claim_producer_context[31:0];
          last_quant_task<=claim_quant_context[31:0];last_linear_task<=claim_linear_context[31:0];
          binding[claim_window]<=claim_binding;valid_windows[claim_window]<=1;
          window_active<=1;active_window<=claim_window;active_rows<=claim_producer_context[95:88];
          active_global_row0<=claim_global_row0;
        end
      end
      if(window_retire_valid && window_retire_ready)begin
        window_active<=0;
        window_retire_error<=!window_retire_success;
        if(window_retire_success && !cancel && !aborting)begin
          covered_rows<=prospective_rows;covered_windows<=prospective_windows;next_window<=8'(active_window)+1;
          if(all_rows_after && all_windows_after)begin owner_state<=READY;tensor_published<=1;end
        end else begin owner_state<=INVALID;aborting<=cancel || aborting;end
      end
      if(gate_acquire_valid && gate_acquire_ready)begin
        gate_acquire_done<=1;gate_acquire_error<=!acquire_ok;
        if(acquire_ok)begin read_leased<=1;leased_window<=gate_acquire_window;end
      end
      if(gate_release_valid && gate_release_ready)begin
        gate_release_done<=1;gate_release_error<=!release_ok;
        if(release_ok)begin
          read_leased<=0;consumed_windows[leased_window]<=1;
          if(aborting)owner_state<=INVALID;
        end
      end
      if(tensor_release_valid && tensor_release_ready)begin
        tensor_release_done<=1;
        if(tensor_release_numeric_identity==numeric_identity && tensor_release_ref==gate_ref)begin
          owner_state<=EMPTY;aborting<=0;
        end else tensor_release_error<=1;
      end
      if(aborting && !window_active && !read_leased)begin cancel_done<=1;aborting<=0;owner_state<=INVALID;end
    end
  end
endmodule
