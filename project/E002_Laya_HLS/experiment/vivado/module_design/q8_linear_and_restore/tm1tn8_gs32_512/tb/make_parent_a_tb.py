#!/usr/bin/env python3
"""Emit a parent pin test around the actual complete dual-A store."""
from pathlib import Path
import re

MODULE = Path(__file__).resolve().parents[1]
QUANT = MODULE.parents[1] / 'activation_quantizer'

def ports(path, name):
    header=path.read_text().split('module '+name,1)[1].split('(',1)[1].split(');',1)[0]
    result=[]; direction=width=''
    for token in header.split(','):
        token=token.strip();m=re.fullmatch(r'(input|output)\s+logic\s*((?:\[[^]]+\]\s*)*)(\w+)',token)
        if m: direction,width,key=m.groups()
        else: assert re.fullmatch(r'\w+',token),token; key=token
        result.append((direction,width.strip(),key))
    return result

cache=ports(QUANT/'rtl/quant_dual_a_v1.sv','quant_dual_a_v1')
parent=ports(MODULE/'rtl/laya_parent_a_lease_v2.sv','laya_parent_a_lease_v2')
s='''`timescale 1ns/1ps
// Prequantized diagnostic payload only: verifies a real A lease/store across
// four views, not GEGLU/quant arithmetic, generated caller, or full-model PASS.
module laya_parent_a_lease_tb_v2;
  import laya_compute_portal_layout_v1::*;
'''
seen=set()
for _,width,name in cache+parent:
    if name not in seen:s+=f'  logic {width} {name};\n'.replace('logic  ','logic ');seen.add(name)
s+='  quant_dual_a_v1 cache(\n'+',\n'.join('    .'+n for _,_,n in cache)+'\n  );\n'
s+='  laya_parent_a_lease_v2 parent(\n'+',\n'.join('    .'+n for _,_,n in parent)+'\n  );\n'
s+='''  initial clk=0;always #5 clk=~clk;
  logic [511:0] fixture_beats[0:15];logic [8191:0] base_command,packet;
  string fixture;int cycles=0,physical_acquires=0,physical_releases=0,view_grants=0,view_releases=0,checks=0,rejections=0,fills=0;
  logic debt_hold=0;
  assign physical_debt_zero=read_debt_zero && !debt_hold;
  assign acquire_valid=physical_acquire_valid;assign physical_acquire_ready=acquire_ready;
  assign physical_acquire_done=acquire_done;assign physical_acquire_error=acquire_error;
  assign {acquire_slot,acquire_slot_epoch,acquire_K,acquire_rows,acquire_numeric_identity,
    acquire_linear_context,acquire_a_ref,acquire_w_ref,acquire_dst_ref}=physical_acquire_handle;
  assign release_valid=physical_release_valid;assign physical_release_ready=release_ready;
  assign physical_release_done=release_done;assign physical_release_error=release_error;
  assign {release_slot,release_slot_epoch,release_numeric_identity,release_linear_context,release_a_ref}=physical_release_handle;
  always @(posedge clk)begin
    cycles++;if(cycles>100000)$fatal(1,"parent A cycle cap");
    if(rst_n)begin
      if(acquire_valid && acquire_ready)physical_acquires++;
      if(release_valid && release_ready)physical_releases++;
      if(local_acquire_valid && local_acquire_ready)view_grants++;
      if(local_release_valid && local_release_ready)view_releases++;
      if(view_rejected)rejections++;
      if(fill_valid && fill_ready)fills++;
    end
  end
  task automatic tick;@(posedge clk);#1;endtask
  function automatic logic [7:0] expected_byte(input int row,group,index);
    return 8'(row*29+group*7+index*3+11);
  endfunction
  task automatic fill(input int epoch,input int request_add);
    @(negedge clk);packet=base_command;packet[GENERATION*8+:64]=1;
    packet[IDENTITY*8+:64]+=64'(request_add);packet[A_EPOCH*8+:32]=32'(epoch);packet[A_REF*8+:32]=32'(epoch);
    packet[DST_REF*8+:64]=64'h000000030000000d;packet[FUTURE_DST_REF*8+:64]=packet[DST_REF*8+:64];
    packet[ROWS*8+:8]=4;packet[ROW_BLOCK*8+:8]=0;
    fill_slot=0;fill_slot_epoch=32'(epoch);fill_K=2624;fill_rows=16;
    fill_numeric_identity=packet[IDENTITY*8+:672];fill_producer_context=packet[PRODUCER_CONTEXT*8+:96];
    fill_quant_context=packet[QUANT_CONTEXT*8+:96];fill_linear_context=packet[LINEAR_CONTEXT*8+:96];
    fill_source_ref=packet[SOURCE_REF*8+:64];fill_a_ref=packet[A_REF*8+:64];
    fill_w_ref=packet[W_REF*8+:64];fill_dst_ref=packet[DST_REF*8+:64];
    fill_owner_admitted=1;fill_source_published=1;fill_valid=1;
    do @(posedge clk);while(!fill_ready);#1;if(fill_reject)$fatal(1,"physical fill rejected");
    @(negedge clk);fill_valid=0;
    commit_numeric_identity=fill_numeric_identity;commit_quant_context=fill_quant_context;commit_a_ref=fill_a_ref;
    for(int row=0;row<16;row++)begin
      for(int group=0;group<82;group++)for(int half=0;half<2;half++)begin
        commit_row=4'(row);commit_group=7'(group);commit_half=1'(half);commit_scale=half==1 ? 16'h3c00 : 0;
        for(int i=0;i<16;i++)commit_q[i*8+:8]=expected_byte(row,group,half*16+i);
        commit_valid=1;do @(posedge clk);while(!commit_ready);#1;
        if(commit_error)$fatal(1,"diagnostic physical A commit");@(negedge clk);commit_valid=0;
      end
      row_done_row=4'(row);row_done_status=0;row_done_debt_zero=1;row_done_valid=1;
      do @(posedge clk);while(!row_done_ready);@(negedge clk);row_done_valid=0;
    end
    finish_debt_zero=1;finish_valid=1;do @(posedge clk);while(!finish_ready);
    #1;if(!fill_done || fill_error || !publish_valid || slot_state[0]!=2)$fatal(1,"full parent A production coverage");
    @(negedge clk);finish_valid=0;
  endtask
  task automatic begin_view(input int row,input int generation,input bit accepted=1);
    @(negedge clk);view_command=packet;view_command[ROW_BLOCK*8+:8]=8'(row);view_command[GENERATION*8+:64]=64'(generation);
    view_valid=1;#1;
    if(!view_ready || view_admitted!=accepted)$fatal(1,"parent view admission row=%0d accepted=%0d",row,accepted);
    tick();@(negedge clk);view_valid=0;
  endtask
  task automatic acquire_view;
    local_acquire_handle={packet[A_SLOT*8],packet[A_EPOCH*8+:32],13'd2624,5'd16,
      packet[IDENTITY*8+:672],packet[LINEAR_CONTEXT*8+:96],packet[A_REF*8+:64],packet[W_REF*8+:64],packet[DST_REF*8+:64]};
    local_acquire_valid=1;do @(posedge clk);while(!local_acquire_ready);@(negedge clk);local_acquire_valid=0;
    wait(local_acquire_done);#1;if(local_acquire_error || !parent_pinned || slot_state[0]!=3)$fatal(1,"view lacks physical A pin");
    @(negedge clk);
  endtask
  task automatic read_view(input int row);
    read_slot=0;read_slot_epoch=packet[A_EPOCH*8+:32];read_numeric_identity=packet[IDENTITY*8+:672];
    read_linear_context=packet[LINEAR_CONTEXT*8+:96];read_a_ref=packet[A_REF*8+:64];read_row_block_base=4'(row);read_rows=4;
    local_release_handle={packet[A_SLOT*8],packet[A_EPOCH*8+:32],packet[IDENTITY*8+:672],packet[LINEAR_CONTEXT*8+:96],packet[A_REF*8+:64]};
    for(int group=0;group<82;group++)begin
      read_group=7'(group);read_valid=1;do @(posedge clk);while(!read_ready);
      #1;if(read_error)$fatal(1,"real A read failed");@(negedge clk);read_valid=0;
      wait(ret_valid);#1;
      if(ret_row_block_base!=row || ret_rows!=4 || ret_group!=group || ret_slot_epoch!=packet[A_EPOCH*8+:32])$fatal(1,"A return binding");
      for(int r=0;r<4;r++)begin
        if(ret_scale[r]!=16'h3c00)$fatal(1,"independent A scale");
        for(int i=0;i<32;i++)begin checks++;if(ret_q[r][i*8+:8]!==expected_byte(row+r,group,i))$fatal(1,"independent A byte row=%0d group=%0d index=%0d",row+r,group,i);end
      end
      if(group==81)begin
        local_release_valid=1;
        repeat(7)begin tick();if(local_release_ready || physical_release_valid || read_debt_zero)$fatal(1,"held A return released parent early");end
        @(negedge clk);local_release_valid=0;
      end
      ret_ready=1;tick();@(negedge clk);ret_ready=0;
    end
  endtask
  task automatic end_view(input bit last);
    local_release_valid=1;do @(posedge clk);while(!local_release_ready);
    @(negedge clk);local_release_valid=0;wait(local_release_done);#1;
    if(local_release_error || slot_state[0]!=(last ? 0 : 3) || parent_pinned==last)$fatal(1,"parent release extent");
    @(negedge clk);view_done=1;tick();@(negedge clk);view_done=0;tick();@(negedge clk);
  endtask
  task automatic reject_changed(input int mutation);
    logic [8191:0] saved;
    saved=packet;
    case(mutation)
      0:packet[PRODUCER_CONTEXT*8+:32]-=1;
      1:packet[(MODEL_IDENTITY+100)*8]=!packet[(MODEL_IDENTITY+100)*8];
      2:begin packet[FUTURE_DST_REF*8+:32]+=1;packet[DST_REF*8+:32]+=1;end
      3:begin packet[A_EPOCH*8+:32]+=1;packet[A_REF*8+:32]+=1;end
      4:packet[IDENTITY*8+:64]+=1;
    endcase
    if(!command_frame_ok(packet))$fatal(1,"entity mutation must have valid schema");
    begin_view(4,50,0);packet=saved;
    if(!parent_pinned || slot_state[0]!=3 || physical_acquires!=1 || physical_releases!=0)$fatal(1,"rejected entity disturbed pin");
  endtask
  initial begin
    if(!$value$plusargs("FIXTURE=%s",fixture))$fatal(1,"FIXTURE required");
    $readmemh({fixture,"/command.hex"},fixture_beats);
    for(int b=0;b<16;b++)base_command[b*512+:512]=fixture_beats[b];
'''
assigned={'clk','physical_debt_zero','acquire_valid','release_valid','physical_acquire_ready','physical_acquire_done','physical_acquire_error','physical_release_ready','physical_release_done','physical_release_error'}
assigned.update(n for _,_,n in cache if n.startswith(('acquire_','release_')))
for direction,_,name in cache+parent:
    if direction=='input' and name not in assigned and name not in {'physical_acquire_handle','physical_release_handle'}:
        s+=f'    {name}=0;\n';assigned.add(name)
s+='''    repeat(5)tick();@(negedge clk);rst_n=1;tick();
    fill(1,0);
    begin_view(0,1);acquire_view();read_view(0);end_view(0);
    if(next_row!=4 || origin_generation!=1 || physical_acquires!=1 || physical_releases!=0)$fatal(1,"first view destroyed A");
    begin_view(0,5,0);begin_view(8,5,0);
    for(int mutation=0;mutation<5;mutation++)reject_changed(mutation);
    for(int v=1;v<4;v++)begin
      begin_view(v*4,v+1);acquire_view();read_view(v*4);end_view(v==3);
      if(v<3 && (physical_acquires!=1 || physical_releases!=0 || origin_generation!=1))$fatal(1,"A reacquired or released between views");
    end
    if(physical_acquires!=1 || physical_releases!=1 || parent_live || slot_epoch[0]!=1 || fills!=1)$fatal(1,"parent physical lease count");
    // Same session, next request: cancel in the inter-view gap with a real pin.
    fill(2,1);begin_view(0,10);acquire_view();read_view(0);end_view(0);
    debt_hold=1;cancel=1;tick();@(negedge clk);cancel=0;
    repeat(9)begin tick();if(!parent_pinned || physical_release_valid || slot_state[0]!=3)$fatal(1,"idle pin cancelled before enclosing debt zero");end
    @(negedge clk);debt_hold=0;wait(cancel_done);#1;
    if(parent_pinned || parent_live || slot_state[0]!=0 || slot_epoch[0]!=2)$fatal(1,"inter-view cancellation did not safely release");
    @(negedge clk);fill(3,2);
    for(int v=0;v<4;v++)begin begin_view(v*4,20+v);acquire_view();read_view(v*4);end_view(v==3);end
    if(physical_acquires!=3 || physical_releases!=3 || fills!=3 || view_grants!=9 || view_releases!=9 || rejections!=7 || checks!=94464)
      $fatal(1,"parent coverage counters acquire=%0d release=%0d fill=%0d views=%0d/%0d reject=%0d checks=%0d",physical_acquires,physical_releases,fills,view_grants,view_releases,rejections,checks);
    $display("FULL_CURRENT_PARENT_A_PASS real_dual_A=1 parent_rows=16 views=4 distinct_g=1 physical_acquires=%0d physical_releases=%0d view_grants=%0d one_fill_per_parent=1 entity_rejects=%0d held_return_release_barrier=1 inter_view_cancel=1 same_session_recovery=1 independent_q_bytes=%0d cycles=%0d",physical_acquires,physical_releases,view_grants,rejections,checks,cycles);
    $finish;
  end
endmodule
'''
(MODULE/'tb/laya_parent_a_lease_tb_v2.sv').write_text(s)
print('FULL_CURRENT_PARENT_A_TB_GENERATED')
