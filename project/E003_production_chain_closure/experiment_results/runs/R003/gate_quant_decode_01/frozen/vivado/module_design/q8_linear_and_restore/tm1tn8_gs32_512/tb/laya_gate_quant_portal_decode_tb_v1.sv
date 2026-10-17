`timescale 1ns/1ps
module laya_gate_quant_portal_decode_tb_v1;
  import laya_compute_portal_layout_v1::*;
  logic [8191:0] service_command;
  logic [12:0][63:0] latched_bo_base,latched_bo_span;
  logic g_command_ok,q_command_ok,q_gate_command_ok;
  logic [671:0] numeric_identity;logic [95:0] producer_context,quant_context,linear_context;
  logic [63:0] source_ref,a_ref,w_ref,ps_ref,dst_ref,future_dst_ref;
  logic a_slot;logic [31:0] a_slot_epoch;logic [6:0] window;
  logic [7:0] source_role,output_role,gate_region,dst_region;
  logic [63:0] source_bo_base,source_bo_span,source_region_base,source_region_span;
  logic [63:0] output_bo_base,output_bo_span,output_region_base,output_region_span;
  logic [327:0] output_binding;
  int checks=0;
  laya_gate_quant_portal_decode_v1 dut(.*);
  task automatic check(input bit condition,input string label);
    checks++;if(!condition)$fatal(1,"gate/quant decode %s",label);
  endtask
  task automatic make_context(output logic [95:0] c,input int task_id,input int op,input int row0,input int rows);
    c=0;c[31:0]=32'(task_id);c[39:32]=8'(op);c[47:40]=2;c[55:48]=0;
    c[63:56]=0;c[71:64]=0;c[87:72]=16'(row0);c[95:88]=8'(rows);
  endtask
  task automatic common(input int service,input int rows,input int row0);
    logic [95:0] p,q,l;
    service_command=0;
    make_context(p,1,8'h60,row0,rows);make_context(q,2,8'h20,row0,rows);make_context(l,3,8'h33,row0,rows);
    service_command[MAGIC*8+:32]=CMD_MAGIC;service_command[VER*8+:16]=VERSION;
    service_command[OP_STATUS*8+:16]=16'(service);service_command[GENERATION*8+:64]=1;
    service_command[TASK*8+:32]=service==4 ? 1 : 2;
    service_command[COMMAND_BEATS*8+:16]=CMD_BEATS;service_command[RESPONSE_BEATS*8+:16]=RSP_BEATS;
    service_command[IDENTITY*8+:64]=64'h11;service_command[(IDENTITY+8)*8+:64]=64'h22;
    service_command[(IDENTITY+16)*8+:16]=1;service_command[(IDENTITY+18)*8+:16]=64;
    service_command[CONTEXT*8+:96]=service==4 ? p : q;
    service_command[PRODUCER_CONTEXT*8+:96]=p;service_command[QUANT_CONTEXT*8+:96]=q;
    service_command[LINEAR_CONTEXT*8+:96]=l;
    service_command[A_REF*8+:64]=64'h0000002200000001;
    service_command[W_REF*8+:64]=64'h0000002300000001;
    service_command[PS_REF*8+:64]=64'h0000002400000001;
    service_command[FUTURE_DST_REF*8+:64]=64'h0000000300000001;
    service_command[K*8+:16]=2624;service_command[N*8+:16]=1024;
    service_command[ROWS*8+:8]=8'(rows);service_command[A_SLOT*8]=0;service_command[W_SLOT*8]=0;
    service_command[A_EPOCH*8+:32]=1;service_command[W_EPOCH*8+:32]=1;
    service_command[WEIGHT_KEY*8+:16]=4;
  endtask
  task automatic make_g(input int rows,input int row0);
    common(4,rows,row0);
    service_command[SOURCE_REF*8+:64]=64'h0000000600000001;
    service_command[DST_REF*8+:64]=64'h0000000700000001;
    service_command[SOURCE_ROLE*8+:8]=10;service_command[OUT0_ROLE*8+:8]=11;
    service_command[SOURCE_OFFSET*8+:64]=64'h1000;service_command[SOURCE_SPAN*8+:64]=64'h200000;
    service_command[SOURCE_STRIDE*8+:64]=20992;
    service_command[OUTPUT_RANGES*8+:64]=latched_bo_span[11];
    service_command[(OUTPUT_RANGES+8)*8+:64]=64'h1000;
    service_command[(OUTPUT_RANGES+16)*8+:64]=64'h100000;
    service_command[ROW_STRIDE*8+:64]=10496;service_command[BATCH_STRIDE*8+:64]=10747904;
  endtask
  task automatic make_q(input int rows,input int row0);
    common(2,rows,row0);
    service_command[SOURCE_REF*8+:64]=64'h0000000700000001;
    service_command[DST_REF*8+:64]=service_command[A_REF*8+:64];
    service_command[SOURCE_ROLE*8+:8]=11;
    service_command[SOURCE_OFFSET*8+:64]=64'h1000;service_command[SOURCE_SPAN*8+:64]=64'h100000;
    service_command[SOURCE_STRIDE*8+:64]=10496;
    service_command[ROW_STRIDE*8+:64]=10496;service_command[BATCH_STRIDE*8+:64]=10747904;
  endtask
  initial begin
    latched_bo_base=0;latched_bo_span=0;
    latched_bo_base[10]=64'h100000000;latched_bo_span[10]=64'h4000000;
    latched_bo_base[11]=64'h200000000;latched_bo_span[11]=64'h4000000;
    make_g(16,0);#1;
    check(g_command_ok && !q_command_ok && !q_gate_command_ok,"valid GEGLU");
    check(source_region_base==64'h100001000 && output_region_base==64'h200001000,"GEGLU absolute ranges");
    check(source_region_span==64'h200000 && output_region_span==64'h100000,"GEGLU spans");
    check(source_role==10 && output_role==11 && window==0,"GEGLU roles/window");
    service_command[SOURCE_STRIDE*8+:64]=10496;#1;check(!g_command_ok,"GEGLU source stride mutation");
    make_g(16,0);service_command[(OUTPUT_RANGES+16)*8+:64]=64'h4000001;#1;check(!g_command_ok,"GEGLU output overflow");
    make_g(16,0);service_command[OUTPUT_RANGES*8+:64]^=1;#1;check(!g_command_ok,"GEGLU BO span mismatch");
    make_g(16,0);service_command[SOURCE_ROLE*8+:8]=9;#1;check(!g_command_ok,"GEGLU source role mutation");
    make_g(16,16);#1;check(g_command_ok && window==1,"GEGLU second window");
    make_q(16,0);#1;
    check(!g_command_ok && q_command_ok && q_gate_command_ok,"valid GATE QUANT");
    check(source_region_base==64'h200001000 && source_region_span==64'h100000,"QUANT absolute range");
    check(source_bo_base==latched_bo_base[11] && a_slot_epoch==1,"QUANT physical binding");
    service_command[BATCH_STRIDE*8+:64]=64'd671744;#1;check(!q_command_ok,"QUANT runtime-S stride mutation");
    make_q(16,0);service_command[SOURCE_SPAN*8+:64]=64'd4096;#1;check(!q_command_ok,"QUANT short source range");
    make_q(16,0);service_command[SOURCE_REF*8+32+:8]=1;#1;
    check(q_command_ok && !q_gate_command_ok,"ordinary QUANT excluded from GATE path");
    make_q(16,0);service_command[CONTEXT*8+:32]=4;#1;check(!q_command_ok,"QUANT context mismatch");
    $display("FULL_CURRENT_GATE_QUANT_PORTAL_DECODE_PASS checks=%0d",checks);
    $finish;
  end
endmodule
