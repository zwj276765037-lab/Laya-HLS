`timescale 1ns/1ps
package laya_compute_portal_layout_v1;
  localparam logic [31:0] CMD_MAGIC=32'h3150434c,RSP_MAGIC=32'h3152434c;
  localparam int VERSION=2,CMD_BYTES=1024,RSP_BYTES=512,CMD_BEATS=16,RSP_BEATS=8;
  localparam int MAGIC=0,VER=4,OP_STATUS=6,GENERATION=8,TASK=16,FLAGS_DETAIL=20;
  localparam int COMMAND_BEATS=24,RESPONSE_BEATS=26;
  localparam int IDENTITY=64,CONTEXT=148,SOURCE_REF=160,A_REF=168,W_REF=176,PS_REF=184,DST_REF=192;
  localparam int MODEL_IDENTITY=200,K=616,N=618,ROWS=620,ROW_BLOCK=621,A_SLOT=622,W_SLOT=623;
  localparam int A_EPOCH=624,W_EPOCH=628,WEIGHT_KEY=632,BIAS_KIND=634;
  localparam int OUT0_ROLE=635,OUT1_ROLE=636,SOURCE_ROLE=637;
  localparam int OUTPUT_RANGES=640,ROW_STRIDE=688,BATCH_STRIDE=696,WEIGHT_RANGES=704;
  localparam int EXPECTED_AUX_HEADER=752,AUX_OFFSET=880,BIAS_OFFSET=888,BIAS_BYTES=896;
  localparam int SOURCE_OFFSET=904,SOURCE_SPAN=912,SOURCE_STRIDE=920;
  localparam int PRODUCER_CONTEXT=928,QUANT_CONTEXT=940,LINEAR_CONTEXT=952,FUTURE_DST_REF=964,COMMAND_USED=972;
  localparam int RANK=24,BAD_ELEMENT=32,ELEMENTS=40,UNIT=44,RETIRE_FLAGS=45,CYCLES=48,COUNTERS=64;
  localparam int RESPONSE_IDENTITY=128,RESPONSE_CONTEXT=212,RESPONSE_REFS=224;
  localparam int RESPONSE_A_EPOCH=264,RESPONSE_W_EPOCH=268;
  localparam int RESPONSE_PRODUCER_CONTEXT=272,RESPONSE_QUANT_CONTEXT=284,RESPONSE_LINEAR_CONTEXT=296;
  localparam int RESPONSE_FUTURE_DST_REF=308,RESPONSE_ROWS=316,RESPONSE_ROW_BLOCK=317,RESPONSE_SERVICE=318,RESPONSE_USED=320;
  localparam logic [15:0] E_ABI=1,E_PROTOCOL=7;

  // The historical filename remains an implementation path; VERSION alone
  // determines the wire dialect. All bindings use this shared v2 definition.
  function automatic logic context_ok(input logic [95:0] c,input logic [15:0] b,s);
    logic valid,control_op,legal_op;
    logic [7:0] op,stage,layer,batch,space,rows;
    logic [15:0] row0;
    op=c[32+:8];stage=c[40+:8];layer=c[48+:8];batch=c[56+:8];
    space=c[64+:8];row0=c[72+:16];rows=c[88+:8];
    case(op)
      8'h01,8'h02,8'h10,8'h11,8'h12,8'h13,8'h14,8'h20,
      8'h30,8'h31,8'h32,8'h33,8'h34,8'h35,8'h36,8'h37,
      8'h40,8'h50,8'h51,8'h52,8'h53,8'h54,8'h55,
      8'h60,8'h61,8'h62,8'h63,8'h64,8'h65,8'h66,
      8'h70,8'h71,8'h72,8'h80,8'h81,8'h82,8'h83,8'h84,8'h85:legal_op=1;
      default:legal_op=0;
    endcase
    control_op=op>=8'h80 && op<=8'h85;
    valid=legal_op && c[0+:32]!=0 && c[0+:32]!=32'hffffffff && b>=1 && b<=2 &&
      (s==64 || s==128 || s==256 || s==512 || s==1024) && stage<=7 &&
      rows>=1 && rows<=16 && batch<b;
    case(space)
      0:valid=valid && (32'(row0)+32'(rows)<=32'(s));
      1:valid=valid && (32'(row0)+32'(rows)<=16);
      2:valid=valid && row0==0 && rows==1;
      default:valid=0;
    endcase
    if(stage==2)valid=valid && layer<=27 && (control_op || space==0);
    if(stage==4)valid=valid && layer<=1 && (control_op || space==0);
    if(control_op)valid=valid && space==2 && batch==0 && row0==0 && rows==1;
    if(op==8'h84)valid=valid && stage==0;
    if(op==8'h85)valid=valid && stage==7;
    if(stage!=2 && stage!=4)valid=valid && layer==255;
    return valid;
  endfunction
  function automatic logic ref_ok(input logic [63:0] r);
    logic [7:0] id,bank,region;
    logic dual;
    id=r[32+:8];bank=r[40+:8];region=r[48+:8];
    if(id==0)return r==0;
    dual=id==1 || id==5 || (id>=8'h20 && id<=8'h2b);
    return ((id>=1 && id<=11) || (id>=8'h20 && id<=8'h2b)) &&
      r[0+:32]!=0 && r[0+:32]!=32'hffffffff && r[56+:8]==0 &&
      bank<=(dual ? 1 : 0) && (id==10 ? region<=7 : region==0);
  endfunction
  function automatic logic same_window(input logic [95:0] a,b);
    return a[40+:56]==b[40+:56];
  endfunction
  function automatic logic operation_fields_ok(input logic [8191:0] p);
    logic valid;
    logic [95:0] c,producer,q,l;
    logic [15:0] b,s,service,k;
    logic [63:0] stride;
    c=p[CONTEXT*8+:96];producer=p[PRODUCER_CONTEXT*8+:96];
    q=p[QUANT_CONTEXT*8+:96];l=p[LINEAR_CONTEXT*8+:96];
    b=p[(IDENTITY+16)*8+:16];s=p[(IDENTITY+18)*8+:16];
    service=p[OP_STATUS*8+:16];k=p[K*8+:16];stride=64'(k)*4;
    valid=p[IDENTITY*8+:64]!=0 && p[(IDENTITY+8)*8+:64]!=0 && context_ok(c,b,s);
    for(int off=SOURCE_REF;off<=DST_REF;off+=8)valid=valid && ref_ok(p[off*8+:64]);
    valid=valid && ref_ok(p[FUTURE_DST_REF*8+:64]) && p[(W_REF+4)*8+:8]==8'h23 &&
      p[(W_REF+5)*8+:8]==p[W_SLOT*8+:8] && p[W_REF*8+:32]==p[W_EPOCH*8+:32];
    if(service==1)return valid && c[32+:8]==8'h80 &&
      p[SOURCE_REF*8+:128]==0 && p[PS_REF*8+:128]==0 &&
      p[PRODUCER_CONTEXT*8+:(COMMAND_USED-PRODUCER_CONTEXT)*8]==0 &&
      p[ROWS*8+:24]==0 && p[A_EPOCH*8+:32]==0 &&
      p[OUT0_ROLE*8+:(WEIGHT_RANGES-OUT0_ROLE)*8]==0 &&
      p[SOURCE_OFFSET*8+:(PRODUCER_CONTEXT-SOURCE_OFFSET)*8]==0;
    valid=valid && p[(A_REF+4)*8+:8]==8'h22 && p[(A_REF+5)*8+:8]==p[A_SLOT*8+:8] &&
      p[A_REF*8+:32]==p[A_EPOCH*8+:32] && p[(PS_REF+4)*8+:8]==8'h24 &&
      p[SOURCE_REF*8+:64]!=0 && p[FUTURE_DST_REF*8+:64]!=0 &&
      context_ok(producer,b,s) && context_ok(q,b,s) && context_ok(l,b,s) &&
      q[32+:8]==8'h20 && l[32+:8]>=8'h30 && l[32+:8]<=8'h37 && same_window(q,l) &&
      producer[0+:32]<q[0+:32] && q[0+:32]<l[0+:32] &&
      p[WEIGHT_RANGES*8+:(SOURCE_OFFSET-WEIGHT_RANGES)*8]==0;
    if(p[(SOURCE_REF+4)*8+:8]==7)valid=valid && producer[32+:8]==8'h60 && same_window(producer,q);
    if(service==3)begin
      valid=valid && c==l && p[DST_REF*8+:64]==p[FUTURE_DST_REF*8+:64] &&
        (p[ROWS*8+:8]==1 || p[ROWS*8+:8]==4) &&
        32'(p[ROW_BLOCK*8+:8])+32'(p[ROWS*8+:8])<=32'(l[88+:8]) &&
        p[SOURCE_ROLE*8+:8]==0 && p[SOURCE_OFFSET*8+:(PRODUCER_CONTEXT-SOURCE_OFFSET)*8]==0;
      if(c[32+:8]!=8'h30)valid=valid && p[OUT1_ROLE*8+:8]==0 && p[(OUTPUT_RANGES+24)*8+:192]==0;
    end else if(service==2)begin
      valid=valid && c==q && p[DST_REF*8+:64]==p[A_REF*8+:64] &&
        p[ROWS*8+:8]==c[88+:8] && p[ROW_BLOCK*8+:8]==0 &&
        p[SOURCE_STRIDE*8+:64]==stride && p[ROW_STRIDE*8+:64]==stride &&
        p[BATCH_STRIDE*8+:64]==stride*(c[64+:8]==0 ? 1024 : c[64+:8]==1 ? 16 : 1) &&
        p[SOURCE_ROLE*8+:8]>=6 && p[OUT0_ROLE*8+:16]==0 && p[OUTPUT_RANGES*8+:384]==0;
    end else if(service==4)begin
      valid=valid && c==producer && c[32+:8]==8'h60 && l[32+:8]==8'h33 && same_window(producer,q) &&
        c[64+:8]==0 && k==2624 && p[N*8+:16]==1024 &&
        p[(SOURCE_REF+4)*8+:8]==6 && p[(DST_REF+4)*8+:8]==7 &&
        p[ROWS*8+:8]==c[88+:8] && p[ROW_BLOCK*8+:8]==0 &&
        p[SOURCE_ROLE*8+:8]==10 && p[OUT0_ROLE*8+:8]==11 &&
        p[SOURCE_STRIDE*8+:64]==stride*2 && p[ROW_STRIDE*8+:64]==stride &&
        p[BATCH_STRIDE*8+:64]==stride*1024 &&
        p[OUT1_ROLE*8+:8]==0 && p[(OUTPUT_RANGES+24)*8+:192]==0;
    end else valid=0;
    return valid;
  endfunction
  function automatic logic command_header_ok(input logic [511:0] h);
    return h[MAGIC*8+:32]==CMD_MAGIC && h[VER*8+:16]==VERSION &&
      h[OP_STATUS*8+:16]>=1 && h[OP_STATUS*8+:16]<=4 && h[GENERATION*8+:64]!=0 &&
      h[TASK*8+:32]!=0 && h[TASK*8+:32]!=32'hffffffff &&
      h[COMMAND_BEATS*8+:16]==CMD_BEATS && h[RESPONSE_BEATS*8+:16]==RSP_BEATS &&
      h[FLAGS_DETAIL*8+:32]==0 && h[28*8+:36*8]==0;
  endfunction
  function automatic logic command_frame_ok(input logic [8191:0] p);
    logic valid;
    valid=p[0+:32]==CMD_MAGIC && p[VER*8+:16]==VERSION &&
      p[OP_STATUS*8+:16]>=1 && p[OP_STATUS*8+:16]<=4 &&
      p[GENERATION*8+:64]!=0 && p[TASK*8+:32]!=0 &&
      p[TASK*8+:32]==p[CONTEXT*8+:32] &&
      p[COMMAND_BEATS*8+:16]==CMD_BEATS && p[RESPONSE_BEATS*8+:16]==RSP_BEATS &&
      p[FLAGS_DETAIL*8+:32]==0 && p[28*8+:36*8]==0 &&
      p[638*8+:16]==0 && p[900*8+:32]==0 && p[COMMAND_USED*8+:(CMD_BYTES-COMMAND_USED)*8]==0 &&
      p[A_SLOT*8+:8]<=1 && p[W_SLOT*8+:8]<=1 && p[BIAS_KIND*8+:8]<=1 &&
      p[OUT0_ROLE*8+:8]<=12 && p[OUT1_ROLE*8+:8]<=12 && p[SOURCE_ROLE*8+:8]<=12;
    for(int refbyte=SOURCE_REF;refbyte<=DST_REF;refbyte+=8)
      valid=valid && p[(refbyte+7)*8+:8]==0;
    valid=valid && p[(A_REF+6)*8+:8]==0 && p[(W_REF+6)*8+:8]==0 && p[(PS_REF+6)*8+:8]==0;
    return valid && command_header_ok(p[0+:512]) && operation_fields_ok(p);
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
      r[46*8+:16]==0 && r[56*8+:64]==0 && r[120*8+:64]==0 && r[RESPONSE_USED*8+:(RSP_BYTES-RESPONSE_USED)*8]==0 &&
      r[RESPONSE_PRODUCER_CONTEXT*8+:352]==c[PRODUCER_CONTEXT*8+:352] &&
      r[RESPONSE_ROWS*8+:8]==c[ROWS*8+:8] && r[RESPONSE_ROW_BLOCK*8+:8]==c[ROW_BLOCK*8+:8] &&
      r[RESPONSE_SERVICE*8+:16]==c[OP_STATUS*8+:16];
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
    r[RESPONSE_PRODUCER_CONTEXT*8+:352]=c[PRODUCER_CONTEXT*8+:352];
    r[RESPONSE_ROWS*8+:8]=c[ROWS*8+:8];r[RESPONSE_ROW_BLOCK*8+:8]=c[ROW_BLOCK*8+:8];
    r[RESPONSE_SERVICE*8+:16]=c[OP_STATUS*8+:16];
    return r;
  endfunction
endpackage
