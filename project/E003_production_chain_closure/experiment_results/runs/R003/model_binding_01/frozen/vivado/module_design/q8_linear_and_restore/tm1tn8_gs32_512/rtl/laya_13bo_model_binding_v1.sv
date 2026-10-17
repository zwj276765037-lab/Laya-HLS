`timescale 1ns/1ps
// Persistent binding for the five model BOs in the original 13-BO instance.
// rst_n and an explicitly drained cold_rebind are the only clearing domains.
module laya_13bo_model_binding_v1(
  input logic clk,rst_n,
  input logic start_valid,
  output logic start_ready,start_fire,
  input logic [12:0][63:0] candidate_bo_base,
  input logic soft_cancel,
  input logic cold_rebind,domain_drained,
  output logic binding_valid,
  output logic [4:0][63:0] bound_model_base,
  output logic candidate_valid,candidate_matches,
  output logic binding_conflict,cold_rebind_rejected,
  output logic [31:0] accepted_starts,rejected_starts
);
  import laya_model_identity_13bo_generated_v1::*;
  logic [4:0][63:0] candidate_model_base;
  logic [4:0][63:0] model_bytes;
  logic [4:0][64:0] model_end;
  always_comb begin
    candidate_model_base[0]=candidate_bo_base[0];
    candidate_model_base[1]=candidate_bo_base[2];
    candidate_model_base[2]=candidate_bo_base[3];
    candidate_model_base[3]=candidate_bo_base[4];
    candidate_model_base[4]=candidate_bo_base[5];
    model_bytes[0]=MODEL_BYTES_EMBEDDING;
    model_bytes[1]=MODEL_BYTES_W_Q0;
    model_bytes[2]=MODEL_BYTES_W_Q1;
    model_bytes[3]=MODEL_BYTES_W_SCALE;
    model_bytes[4]=MODEL_BYTES_AUX;
    candidate_valid=1;
    for(int i=0;i<5;i++)begin
      model_end[i]={1'b0,candidate_model_base[i]}+{1'b0,model_bytes[i]};
      candidate_valid=candidate_valid && candidate_model_base[i]!=0 &&
        candidate_model_base[i][5:0]==0 && !model_end[i][64];
    end
    candidate_matches=candidate_model_base==bound_model_base;
    start_ready=!cold_rebind && candidate_valid &&
      (!binding_valid || candidate_matches);
    start_fire=start_valid && start_ready;
  end
  always_ff @(posedge clk)begin
    if(!rst_n)begin
      binding_valid<=0;bound_model_base<=0;binding_conflict<=0;
      cold_rebind_rejected<=0;accepted_starts<=0;rejected_starts<=0;
    end else begin
      // soft_cancel intentionally leaves the persistent binding untouched.
      if(cold_rebind)begin
        if(domain_drained)begin
          binding_valid<=0;bound_model_base<=0;binding_conflict<=0;
          cold_rebind_rejected<=0;
        end else cold_rebind_rejected<=1;
      end else if(start_valid)begin
        if(start_ready)begin
          if(!binding_valid)begin
            binding_valid<=1;bound_model_base<=candidate_model_base;
          end
          accepted_starts<=accepted_starts+1;
        end else begin
          binding_conflict<=binding_conflict || (binding_valid && !candidate_matches);
          rejected_starts<=rejected_starts+1;
        end
      end
    end
  end
endmodule
