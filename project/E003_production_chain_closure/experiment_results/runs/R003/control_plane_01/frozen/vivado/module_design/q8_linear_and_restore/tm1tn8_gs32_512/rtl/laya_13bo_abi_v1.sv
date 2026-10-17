`timescale 1ns/1ps
package laya_13bo_abi_v1;
  localparam logic [7:0] EMBEDDING_LOW=8'h10, EMBEDDING_HIGH=8'h14;
  localparam logic [7:0] IO_LOW=8'h1c, IO_HIGH=8'h20;
  localparam logic [7:0] W_Q0_LOW=8'h28, W_Q0_HIGH=8'h2c;
  localparam logic [7:0] W_Q1_LOW=8'h34, W_Q1_HIGH=8'h38;
  localparam logic [7:0] W_SCALE_LOW=8'h40, W_SCALE_HIGH=8'h44;
  localparam logic [7:0] AUX_LOW=8'h4c, AUX_HIGH=8'h50;
  localparam logic [7:0] STATE0_LOW=8'h58, STATE0_HIGH=8'h5c;
  localparam logic [7:0] STATE1_LOW=8'h64, STATE1_HIGH=8'h68;
  localparam logic [7:0] QKV0_LOW=8'h70, QKV0_HIGH=8'h74;
  localparam logic [7:0] QKV1_LOW=8'h7c, QKV1_HIGH=8'h80;
  localparam logic [7:0] FF0_LOW=8'h88, FF0_HIGH=8'h8c;
  localparam logic [7:0] FF1_LOW=8'h94, FF1_HIGH=8'h98;
  localparam logic [7:0] ATT_OUT_LOW=8'ha0, ATT_OUT_HIGH=8'ha4;
  function automatic int role_of(input logic [7:0] address);
    case(address)
      EMBEDDING_LOW,EMBEDDING_HIGH: return 0;
      IO_LOW,IO_HIGH: return 1;
      W_Q0_LOW,W_Q0_HIGH: return 2;
      W_Q1_LOW,W_Q1_HIGH: return 3;
      W_SCALE_LOW,W_SCALE_HIGH: return 4;
      AUX_LOW,AUX_HIGH: return 5;
      STATE0_LOW,STATE0_HIGH: return 6;
      STATE1_LOW,STATE1_HIGH: return 7;
      QKV0_LOW,QKV0_HIGH: return 8;
      QKV1_LOW,QKV1_HIGH: return 9;
      FF0_LOW,FF0_HIGH: return 10;
      FF1_LOW,FF1_HIGH: return 11;
      ATT_OUT_LOW,ATT_OUT_HIGH: return 12;
      default:return -1;
    endcase
  endfunction
  function automatic bit high_half(input logic [7:0] address);
    case(address)
      EMBEDDING_HIGH,IO_HIGH,W_Q0_HIGH,W_Q1_HIGH,W_SCALE_HIGH,AUX_HIGH,STATE0_HIGH,STATE1_HIGH,QKV0_HIGH,QKV1_HIGH,FF0_HIGH,FF1_HIGH,ATT_OUT_HIGH:return 1;
      default:return 0;
    endcase
  endfunction
endpackage
