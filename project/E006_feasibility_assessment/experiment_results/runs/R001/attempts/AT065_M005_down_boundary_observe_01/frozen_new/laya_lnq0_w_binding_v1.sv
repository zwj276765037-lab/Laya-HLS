`timescale 1ns/1ps
// Fixed, checked BO mapping for the four-row LNQ0 simulation. The strict W
// cache still performs its normal physical reads, AUX compare and lease checks.
module laya_lnq0_w_binding_v1 (
  input logic clk,rst_n,
  input logic request_valid,
  output logic request_ready,request_reject,
  input logic cache_ready,
  output logic cache_valid,
  input logic [3327:0] model_identity,
  input logic [1023:0] expected_aux_header,
  input logic [63:0] aux_base,
  input logic [2:0][63:0] load_base,
  input logic [2:0][31:0] load_bytes,
  input logic [15:0] K,N,
  input logic [15:0] weight_key,
  input logic [31:0] bias_bytes
);
  import laya_lnq0_bound_identity_generated_v1::*;
  import laya_model_identity_13bo_generated_v1::*;
  logic binding_ok,range_ok,shape_ok;
  logic [64:0] end0,end1,end2;
  always_comb begin
    binding_ok=model_identity==W_IDENTITY &&
      model_identity[0+:512]==L13M_CANONICAL[0+:512] &&
      model_identity[64*8+:32]==32'd0 &&
      model_identity[72*8+:64]==BINDING_GENERATION &&
      expected_aux_header==AUX_HEADER && aux_base==AUX_BASE;
    for(int i=0;i<5;i++)begin
      case(i)
        0:binding_ok=binding_ok &&
            model_identity[(256+32*i)*8+:32]==32'd0 &&
            model_identity[(256+32*i+8)*8+:64]==EMBEDDING_BASE &&
            model_identity[(256+32*i+16)*8+:64]==EMBEDDING_BYTES;
        1:binding_ok=binding_ok &&
            model_identity[(256+32*i)*8+:32]==32'd2 &&
            model_identity[(256+32*i+8)*8+:64]==W_Q0_BASE &&
            model_identity[(256+32*i+16)*8+:64]==W_Q0_BYTES;
        2:binding_ok=binding_ok &&
            model_identity[(256+32*i)*8+:32]==32'd3 &&
            model_identity[(256+32*i+8)*8+:64]==W_Q1_BASE &&
            model_identity[(256+32*i+16)*8+:64]==W_Q1_BYTES;
        3:binding_ok=binding_ok &&
            model_identity[(256+32*i)*8+:32]==32'd4 &&
            model_identity[(256+32*i+8)*8+:64]==W_SCALE_BASE &&
            model_identity[(256+32*i+16)*8+:64]==W_SCALE_BYTES;
        default:binding_ok=binding_ok &&
            model_identity[(256+32*i)*8+:32]==32'd5 &&
            model_identity[(256+32*i+8)*8+:64]==AUX_BASE &&
            model_identity[(256+32*i+16)*8+:64]==AUX_BYTES;
      endcase
      binding_ok=binding_ok &&
        model_identity[(256+32*i+4)*8+:32]==32'd1 &&
        model_identity[(256+32*i+24)*8+:64]!=0;
    end
    end0={1'b0,load_base[0]}+{33'd0,load_bytes[0]};
    end1={1'b0,load_base[1]}+{33'd0,load_bytes[1]};
    end2={1'b0,load_base[2]}+{33'd0,load_bytes[2]};
    range_ok=!end0[64] && !end1[64] && !end2[64] &&
      load_base[0]>=W_Q0_BASE && end0<={1'b0,W_Q0_BASE}+{1'b0,W_Q0_BYTES} &&
      load_base[1]>=W_Q1_BASE && end1<={1'b0,W_Q1_BASE}+{1'b0,W_Q1_BYTES} &&
      load_base[2]>=W_SCALE_BASE && end2<={1'b0,W_SCALE_BASE}+{1'b0,W_SCALE_BYTES};
    shape_ok=0;
    if(K==16'd1024 && N==16'd5248 && weight_key==16'd3)begin
      shape_ok=load_base[0]==W_Q0_BASE+64'd58720256 &&
        load_base[1]==W_Q1_BASE+64'd58720256 &&
        load_base[2]==W_SCALE_BASE+64'd7340032 &&
        load_bytes[0]==32'd2686976 && load_bytes[1]==32'd2686976 &&
        load_bytes[2]==32'd335872;
    end
    if(K==16'd2624 && N==16'd1024 && weight_key==16'd4)begin
      shape_ok=load_base[0]==W_Q0_BASE+64'd133955584 &&
        load_base[1]==W_Q1_BASE+64'd133955584 &&
        load_base[2]==W_SCALE_BASE+64'd16744448 &&
        load_bytes[0]==32'd1343488 && load_bytes[1]==32'd1343488 &&
        load_bytes[2]==32'd167936;
    end
    shape_ok=shape_ok && bias_bytes==0;
  end
  assign request_ready=cache_ready;
  assign cache_valid=request_valid && binding_ok && range_ok && shape_ok;
  always_ff @(posedge clk) begin
    if(!rst_n)request_reject<=0;
    else request_reject<=request_valid && request_ready &&
      !(binding_ok && range_ok && shape_ok);
  end
endmodule
