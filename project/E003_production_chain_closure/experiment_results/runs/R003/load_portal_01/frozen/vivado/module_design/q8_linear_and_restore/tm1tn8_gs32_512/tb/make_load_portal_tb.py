#!/usr/bin/env python3
"""Generate a native physical-cache LOAD/cancel test with manual AXI peers."""
from pathlib import Path
import re

MODULE=Path(__file__).resolve().parents[1]
raw=(MODULE/'rtl/laya_load_portal_binding_v1.sv').read_text().split('module laya_load_portal_binding_v1(',1)[1].split(');',1)[0]
ports=[];direction=width=''
for token in raw.split(','):
    token=token.strip();match=re.fullmatch(r'(input|output)\s+logic\s*((?:\[[^]]+\]\s*)*)(\w+)',token)
    if match:direction,width,name=match.groups()
    else:assert re.fullmatch(r'\w+',token),token;name=token
    ports.append((direction,width.strip(),name))
s='''`timescale 1ns/1ps
module laya_load_portal_tb_v1;
  import laya_compute_portal_layout_v1::*;
'''
s+=''.join(f'  logic {w} {n};\n'.replace('logic  ','logic ') for _,w,n in ports)
s+='  laya_load_portal_binding_v1 dut(\n'+',\n'.join('    .'+n for _,_,n in ports)+'\n  );\n'
s+='''  initial clk=0;always #5 clk=~clk;
  int cycles=0,commands=0,replies=0,total_ar=0,total_r=0;
  logic [2:0] reading=0;
  logic [2:0][63:0] saved_addr;
  int read_index[3],read_beats[3];
  logic aux_reading=0,aux_hold=0,q_hold=0,q_ar_block=0;
  logic [63:0] aux_addr;
  int aux_index=0,aux_beats=0;
  logic [2:0] aux_size;
  int q_ar=0,q_r=0,aux_ar=0,aux_r=0;
  logic inject_aux_error=0;
  logic [8191:0] packet;
  logic [4095:0] captured;
  assign arready=rst_n ? {2'b11,!q_ar_block} : 0;
  assign aux_arready=rst_n && !aux_reading;
  assign physical_debt_zero=reading==0 && !aux_reading && rvalid==0 && !aux_rvalid && arvalid==0 && !aux_arvalid;
  task automatic tick;@(posedge clk);#1;endtask
  function automatic logic [7:0] qbyte(input int address);
    return 8'(address*13+17);
  endfunction
  function automatic logic [127:0] aux_value(input int address);
    if(address==256)return {64'd0,32'hc0200000,32'h3fc00000};
    return 0;
  endfunction
  always @(posedge clk)begin : peer
    int relative;
    cycles++;if(cycles>30000)$fatal(1,"LOAD portal cycle cap commands=%0d replies=%0d busy=%0d cache_fill=%0d",commands,replies,dut.active,dut.cache.fill_busy);
    if(rst_n)begin
      for(int p=0;p<3;p++)begin
        if(arvalid[p] && arready[p])begin
          if(reading[p] || arsize[p]!=6 || arburst[p]!=1 || araddr[p]<latched_bo_base[p+2] ||
             araddr[p][5:0]!=0 || int'(araddr[p][11:0])+64*(int'(arlen[p])+1)>4096)$fatal(1,"LOAD actual AR");
          reading[p]<=1;saved_addr[p]<=araddr[p];read_index[p]<=0;read_beats[p]<=int'(arlen[p])+1;
          total_ar++;if(p==0)q_ar++;
        end
        if(reading[p] && !rvalid[p] && cycles%3!=0 && !(p==0 && q_hold))begin
          relative=int'(saved_addr[p]-latched_bo_base[p+2])+read_index[p]*64;
          if(p==2)for(int lane=0;lane<32;lane++)rdata[p][lane*16+:16]<=16'h3c00;
          else for(int j=0;j<64;j++)rdata[p][j*8+:8]<=qbyte(relative+j);
          rresp[p]<=0;rlast[p]<=read_index[p]==read_beats[p]-1;rvalid[p]<=1;
        end
        if(rvalid[p] && rready[p])begin
          rvalid[p]<=0;read_index[p]<=read_index[p]+1;total_r++;if(p==0)q_r++;
          if(rlast[p])reading[p]<=0;
        end
      end
      if(aux_arvalid && aux_arready)begin
        if(aux_arsize!=4 && aux_arsize!=3)$fatal(1,"AUX actual size");
        aux_reading<=1;aux_addr<=aux_araddr;aux_index<=0;aux_beats<=int'(aux_arlen)+1;aux_size<=aux_arsize;aux_ar++;
      end
      if(aux_reading && !aux_rvalid && cycles%4!=1 && !aux_hold)begin
        relative=int'(aux_addr-latched_bo_base[5])+(aux_index<<aux_size);
        aux_rdata<=aux_value(relative);aux_rresp<=inject_aux_error ? 2 : 0;
        aux_rlast<=aux_index==aux_beats-1;aux_rvalid<=1;
      end
      if(aux_rvalid && aux_rready)begin
        aux_rvalid<=0;aux_index<=aux_index+1;aux_r++;
        if(aux_rlast)aux_reading<=0;
      end
      if(service_completion_valid && !physical_debt_zero)$fatal(1,"LOAD completion before physical retirement");
      if(service_command_valid && service_command_ready)commands++;
      if(service_completion_valid && service_completion_ready)replies++;
    end
  end
  task automatic prepare(input int epoch,input int command_id);
    packet=0;packet[0+:32]=CMD_MAGIC;packet[VER*8+:16]=VERSION;packet[OP_STATUS*8+:16]=1;
    packet[GENERATION*8+:64]=64'(command_id);packet[TASK*8+:32]=32'(command_id);
    packet[COMMAND_BEATS*8+:16]=16;packet[RESPONSE_BEATS*8+:16]=8;
    packet[IDENTITY*8+:64]=1;packet[(IDENTITY+8)*8+:64]=1;packet[(IDENTITY+16)*8+:16]=1;packet[(IDENTITY+18)*8+:16]=128;
    packet[CONTEXT*8+:32]=32'(command_id);packet[(CONTEXT+4)*8+:8]=8'h80;
    packet[(CONTEXT+5)*8+:8]=6;packet[(CONTEXT+6)*8+:8]=255;packet[(CONTEXT+8)*8+:8]=2;packet[(CONTEXT+11)*8+:8]=1;
    packet[W_REF*8+:32]=32'(epoch);packet[(W_REF+4)*8+:8]=8'h23;
    packet[MODEL_IDENTITY*8+576+:64]=1;packet[K*8+:16]=256;packet[N*8+:16]=2;packet[ROWS*8+:8]=1;
    packet[W_EPOCH*8+:32]=32'(epoch);packet[WEIGHT_KEY*8+:16]=16'hff0a;packet[BIAS_KIND*8+:8]=1;
    packet[(WEIGHT_RANGES+8)*8+:64]=2048;packet[(WEIGHT_RANGES+40)*8+:64]=128;
    packet[BIAS_OFFSET*8+:64]=256;packet[BIAS_BYTES*8+:32]=8;
  endtask
  task automatic submit;
    @(negedge clk);service_command=packet;service_command_valid=1;
    do @(posedge clk);while(!service_command_ready);
    @(negedge clk);service_command_valid=0;
  endtask
  task automatic completion(input int status,input int state,input int epoch);
    wait(service_completion_valid);#1;captured=service_completion;
    if(!response_binding_ok(captured,packet) || captured[OP_STATUS*8+:16]!=status ||
      slot_state[0]!=state || slot_epoch[0]!=epoch || !physical_debt_zero)$fatal(1,"LOAD response/status/cache owner status=%0d expected=%0d state=%0d expected=%0d",captured[OP_STATUS*8+:16],status,slot_state[0],state);
    repeat(8)begin tick();if(!service_completion_valid || service_completion!==captured)$fatal(1,"LOAD response changed under backpressure");end
    @(negedge clk);service_completion_ready=1;tick();@(negedge clk);service_completion_ready=0;service_cancel=0;repeat(3)tick();
  endtask
  task automatic check_stripe(input int epoch);
    @(negedge clk);lease_valid=1;lease_slot=0;lease_epoch=32'(epoch);lease_k=256;lease_n=2;
    lease_weight_key=16'hff0a;lease_model_identity=packet[MODEL_IDENTITY*8+:3328];lease_numeric_identity=packet[IDENTITY*8+:672];
    lease_task_context=96'h01000000ff063700000063;
    do @(posedge clk);while(!lease_ready);
    #1;if(!lease_done || lease_error)$fatal(1,"actual W lease failed");@(negedge clk);lease_valid=0;
    read_valid=1;read_slot=0;read_epoch=32'(epoch);read_tile=0;read_group=3;read_pair=0;
    read_model_identity=lease_model_identity;read_numeric_identity=lease_numeric_identity;read_task_context=lease_task_context;
    do @(posedge clk);while(!read_ready);
    @(negedge clk);read_valid=0;wait(ret_valid);#1;
    if(ret_epoch!=epoch || ret_group!=3 || ret_mask[0]!=8'h03 || ret_bias[0][0]!=32'h3fc00000 || ret_bias[0][1]!=32'hc0200000)$fatal(1,"actual stripe metadata/bias");
    for(int lane=0;lane<8;lane++)begin
      if(ret_scale[0][lane]!=16'h3c00)$fatal(1,"actual stripe scale");
      for(int k=0;k<32;k++)if(ret_q[0][lane][k*8+:8]!==qbyte(3*256+lane*32+k))$fatal(1,"actual stripe q lane=%0d k=%0d",lane,k);
    end
    repeat(5)tick();@(negedge clk);ret_ready=1;tick();@(negedge clk);ret_ready=0;
    release_valid=1;release_slot=0;release_epoch=32'(epoch);release_numeric_identity=lease_numeric_identity;release_task_context=lease_task_context;
    do @(posedge clk);while(!release_ready);
    #1;if(!release_done || release_error)$fatal(1,"actual W release failed");@(negedge clk);release_valid=0;repeat(3)tick();
  endtask
  initial begin
'''
for d,_,name in ports:
    if d=='input' and name not in ('clk','physical_debt_zero','arready','aux_arready'):
        s+=f'    {name}=0;\n'
s+='''    for(int bo=0;bo<13;bo++)begin latched_bo_base[bo]=64'h100000000+64'(bo*65536);latched_bo_span[bo]=65536;end
    for(int p=0;p<3;p++)begin read_index[p]=0;read_beats[p]=0;end
    repeat(5)tick();@(negedge clk);rst_n=1;repeat(3)tick();
    prepare(1,1);submit();completion(0,2,1);
    if(captured[ELEMENTS*8+:32]!=2176 || captured[UNIT*8+:8]!=3 || !captured[RETIRE_FLAGS*8+1] ||
       slot_coverage[0][0]!=2048 || slot_coverage[0][2]!=128 || slot_coverage[0][3]!=8)$fatal(1,"normal complete LOAD coverage");
    check_stripe(1);
    // Cancel after a real AR, before any q return. Its debt must survive.
    q_hold=1;prepare(2,2);submit();wait(reading[0]);@(negedge clk);service_cancel=1;
    repeat(15)begin tick();if(service_completion_valid || !reading[0] || slot_epoch[0]!=2)$fatal(1,"accepted q AR cancel lost debt");end
    @(negedge clk);q_hold=0;completion(7,4,2);
    // Offered AR is stable until actual acceptance, even across cancel.
    q_ar_block=1;prepare(3,3);submit();wait(arvalid[0]);repeat(2)tick();@(negedge clk);service_cancel=1;
    repeat(8)begin tick();if(!arvalid[0] || service_completion_valid)$fatal(1,"offered LOAD AR withdrawn on cancel");end
    @(negedge clk);q_ar_block=0;completion(7,4,3);
    // AUX returns are also non-cancellable physical debt.
    aux_hold=1;prepare(4,4);submit();wait(aux_reading);@(negedge clk);service_cancel=1;
    repeat(12)begin tick();if(service_completion_valid || !aux_reading)$fatal(1,"accepted AUX AR cancel lost debt");end
    @(negedge clk);aux_hold=0;completion(7,4,4);
    // Real response error drains the complete accepted burst, invalidates W.
    inject_aux_error=1;prepare(5,5);submit();completion(7,4,5);inject_aux_error=0;
    // Reject u65 overflow before claims or reads; prior high-water is intact.
    prepare(6,6);packet[WEIGHT_RANGES*8+:64]=64'hffffffffffffffc0;submit();completion(5,4,5);
    prepare(6,7);submit();completion(0,2,6);check_stripe(6);
    if(commands!=7 || replies!=7 || slot_readers[0]!=0 || !physical_debt_zero)$fatal(1,"LOAD portal coverage counts");
    $display("FULL_CURRENT_LOAD_PORTAL_PASS commands=%0d replies=%0d cancel_cases=3 AUX_error=1 overflow_reject=1 recoveries=1 actual_q_AR=%0d actual_q_R=%0d actual_aux_AR=%0d actual_aux_R=%0d independent_q_scale_nonzero_bias=2 full_capacity_cache=1 cycles=%0d",commands,replies,q_ar,q_r,aux_ar,aux_r,cycles);$finish;
  end
endmodule
'''
(MODULE/'tb/laya_load_portal_tb_v1.sv').write_text(s)
print('FULL_CURRENT_LOAD_PORTAL_TB_GENERATED')
