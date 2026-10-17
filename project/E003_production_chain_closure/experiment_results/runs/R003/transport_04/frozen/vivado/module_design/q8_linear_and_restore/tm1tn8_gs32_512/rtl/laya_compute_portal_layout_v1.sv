`timescale 1ns/1ps
package laya_compute_portal_layout_v1;
  localparam logic [31:0] CMD_MAGIC=32'h3150434c,RSP_MAGIC=32'h3152434c;
  localparam int VERSION=1,CMD_BYTES=1024,RSP_BYTES=512,CMD_BEATS=16,RSP_BEATS=8;
  localparam int MAGIC=0,VER=4,OP_STATUS=6,GENERATION=8,TASK=16,FLAGS_DETAIL=20;
  localparam int COMMAND_BEATS=24,RESPONSE_BEATS=26;
  localparam int IDENTITY=64,CONTEXT=148,SOURCE_REF=160,A_REF=168,W_REF=176,PS_REF=184,DST_REF=192;
  localparam int MODEL_IDENTITY=200,K=616,N=618,ROWS=620,ROW_BLOCK=621,A_SLOT=622,W_SLOT=623;
  localparam int A_EPOCH=624,W_EPOCH=628,WEIGHT_KEY=632,BIAS_KIND=634;
  localparam int OUT0_ROLE=635,OUT1_ROLE=636,SOURCE_ROLE=637;
  localparam int OUTPUT_RANGES=640,ROW_STRIDE=688,BATCH_STRIDE=696,WEIGHT_RANGES=704;
  localparam int EXPECTED_AUX_HEADER=752,AUX_OFFSET=880,BIAS_OFFSET=888,BIAS_BYTES=896;
  localparam int SOURCE_OFFSET=904,SOURCE_SPAN=912,SOURCE_STRIDE=920,COMMAND_USED=928;
  localparam int RANK=24,BAD_ELEMENT=32,ELEMENTS=40,UNIT=44,RETIRE_FLAGS=45,CYCLES=48,COUNTERS=64;
  localparam int RESPONSE_IDENTITY=128,RESPONSE_CONTEXT=212,RESPONSE_REFS=224;
  localparam int RESPONSE_A_EPOCH=264,RESPONSE_W_EPOCH=268,RESPONSE_USED=272;
  localparam logic [15:0] E_ABI=1,E_PROTOCOL=7;

  function automatic logic command_frame_ok(input logic [8191:0] p);
    logic valid;
    valid=p[0+:32]==CMD_MAGIC && p[VER*8+:16]==VERSION &&
      p[OP_STATUS*8+:16]>=1 && p[OP_STATUS*8+:16]<=4 &&
      p[GENERATION*8+:64]!=0 && p[TASK*8+:32]!=0 &&
      p[TASK*8+:32]==p[CONTEXT*8+:32] &&
      p[COMMAND_BEATS*8+:16]==CMD_BEATS && p[RESPONSE_BEATS*8+:16]==RSP_BEATS &&
      p[FLAGS_DETAIL*8+:32]==0 && p[28*8+:36*8]==0 &&
      p[638*8+:16]==0 && p[900*8+:32]==0 && p[COMMAND_USED*8+:96*8]==0 &&
      p[A_SLOT*8+:8]<=1 && p[W_SLOT*8+:8]<=1 && p[BIAS_KIND*8+:8]<=1 &&
      p[OUT0_ROLE*8+:8]<=12 && p[OUT1_ROLE*8+:8]<=12 && p[SOURCE_ROLE*8+:8]<=12;
    for(int refbyte=SOURCE_REF;refbyte<=DST_REF;refbyte+=8)
      valid=valid && p[(refbyte+7)*8+:8]==0;
    valid=valid && p[(A_REF+6)*8+:8]==0 && p[(W_REF+6)*8+:8]==0 && p[(PS_REF+6)*8+:8]==0;
    return valid;
  endfunction
  function automatic logic response_binding_ok(input logic [4095:0] r,input logic [8191:0] c);
    logic valid;
    valid=r[0+:32]==RSP_MAGIC && r[VER*8+:16]==VERSION && r[OP_STATUS*8+:16]<=8 &&
      r[GENERATION*8+:64]==c[GENERATION*8+:64] && r[TASK*8+:32]==c[TASK*8+:32] &&
      r[RESPONSE_IDENTITY*8+:672]==c[IDENTITY*8+:672] &&
      r[RESPONSE_CONTEXT*8+:96]==c[CONTEXT*8+:96] &&
      r[RESPONSE_REFS*8+:320]==c[SOURCE_REF*8+:320] &&
      r[RESPONSE_A_EPOCH*8+:32]==c[A_EPOCH*8+:32] &&
      r[RESPONSE_W_EPOCH*8+:32]==c[W_EPOCH*8+:32] &&
      r[UNIT*8+:8]<=3 && r[RETIRE_FLAGS*8+:8]<=3 && r[RETIRE_FLAGS*8] &&
      r[46*8+:16]==0 && r[56*8+:64]==0 && r[120*8+:64]==0 && r[RESPONSE_USED*8+:240*8]==0;
    if(r[OP_STATUS*8+:16]!=0)
      valid=valid && r[ELEMENTS*8+:32]==0 && r[UNIT*8+:8]==0 && !r[RETIRE_FLAGS*8+1];
    return valid;
  endfunction
  function automatic logic [4095:0] rejected_response(input logic [8191:0] c,
      input logic [15:0] status,input logic [31:0] detail);
    logic [4095:0] r;
    r=0;r[0+:32]=RSP_MAGIC;r[VER*8+:16]=VERSION;r[OP_STATUS*8+:16]=status;
    r[GENERATION*8+:64]=c[GENERATION*8+:64];r[TASK*8+:32]=c[TASK*8+:32];
    r[FLAGS_DETAIL*8+:32]=detail;r[RANK*8+:64]='1;r[BAD_ELEMENT*8+:64]='1;
    r[RETIRE_FLAGS*8]=1;
    r[RESPONSE_IDENTITY*8+:672]=c[IDENTITY*8+:672];
    r[RESPONSE_CONTEXT*8+:96]=c[CONTEXT*8+:96];
    r[RESPONSE_REFS*8+:320]=c[SOURCE_REF*8+:320];
    r[RESPONSE_A_EPOCH*8+:32]=c[A_EPOCH*8+:32];
    r[RESPONSE_W_EPOCH*8+:32]=c[W_EPOCH*8+:32];
    return r;
  endfunction
endpackage
