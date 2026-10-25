#!/usr/bin/env python3
"""Legal AXI Wi failure then real cancel/close/discard and newgen without reset."""
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];M=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/forward_controller';s=(M/'tb/m007_ffn_parent_tb.sv').read_text().replace('module m007_ffn_parent_tb;','module m007_ffn_fault_tb;')
s=s.replace('string fixture,', '''logic fault_mode=1,fault_injected=0;integer actual_rresp=0,actual_gcancel=0,actual_failed_close=0,actual_discard=0,actual_qdone=0;
 string fixture,''')
s=s.replace('rresp[p]=0;end', 'rresp[p]=0;if(fault_mode&&!fault_injected&&g_outputs>=512&&bphase[p][pick]==0)begin rresp[p]=2;fault_injected=1;end end')
s=s.replace('if(parent_state!=old_state)', '''for(int pp=0;pp<4;pp++)if(rvalid[pp]&&rready[pp]&&rresp[pp]!=0)actual_rresp++;
   if(dut.g_producer_cancel_valid&&dut.g_producer_cancel_ready)actual_gcancel++;
   if(dut.q_producer_close_valid&&dut.q_producer_close_ready&&!dut.q_producer_close_success)actual_failed_close++;
   if(dut.g_discard_valid&&dut.g_discard_ready)actual_discard++;
   if(fault_mode&&dut.q_done_valid&&dut.q_done_ready)actual_qdone++;
   if(parent_state!=old_state)''')
s=s.replace('if(dut.m_status!=0||dut.m_done_request', 'if((!fault_mode&&dut.m_status!=0)||dut.m_done_request')
s=s.replace('for(int ss=0;ss<(matrix_phase?16:82);ss++)', 'if(!fault_mode)for(int ss=0;ss<(matrix_phase?16:82);ss++)')
s=s.replace('if(wi_outputs!=20992)', 'if(!fault_mode&&wi_outputs!=20992)')
start=s.index('   if(dut.g_done_valid&&dut.g_done_ready)begin');end=s.index('\n   if(holding)',start)
s=s[:start]+'''   if(dut.g_done_valid&&dut.g_done_ready)begin
    g_done++;
    if(fault_mode)begin if(!dut.g_done_cancelled||dut.g_done_status!=0)$fatal(1,"real Wi failure G cancel qualification");end
    else if(dut.g_done_status!=0||dut.g_done_cancelled||g_outputs!=41984||g_releases!=82||g_reads!=41984||g_writes!=20992||g_acks!=20992||node_checks!=3358720)$fatal(1,"normal G full DONE");
   end'''+s[end:]
s=s.replace('if(done_valid)begin', 'if(done_valid&&!fault_mode)begin')
# Reuse the exact original input stream and observer initialisation for recovery.
init_start=s.index('  for(int ss=0;ss<82;ss++)begin g_ready_cycle');init_end=s.index('  cmd_request=77;',init_start);initialise=s[init_start:init_end]
input_start=s.index('  for(int i=0;i<4096;i++)begin');input_end=s.index('\n  if(stop_blocks>0)',input_start);stream=s[input_start:input_end]
recovery=r'''
  wait(done_valid);@(negedge clk);
  if(done_status!=2||source_status!=3||error_domain!=4||done_request!=cmd_request||done_generation!=cmd_generation||done_epoch!=cmd_epoch||actual_rresp!=1||actual_gcancel!=1||actual_failed_close!=1||actual_discard!=1||actual_qdone!=2||wi_done!=1||g_done!=1||g_outputs<512||mcommands!=1||gcommands!=1||publications[1]!=0||down_outputs!=0||!dut.ws_a_enable||!dut.g_engine_idle||dut.tanh_lease_active||dut.r_res_fp_lease_active||dut.r_res_div_lease_active||!dut.r_res_st_idle||dut.matrix.a_slot_leased!=0||dut.matrix.w_slot_leased!=0)$fatal(1,"real Wi fail cancel/failedclose/discard/retirement chain rresp=%0d cancel=%0d close=%0d discard=%0d qdone=%0d status=%0d/%0d/%0d",actual_rresp,actual_gcancel,actual_failed_close,actual_discard,actual_qdone,done_status,source_status,error_domain);
  begin logic[242:0]held;held={done_status,source_status,error_domain,error_tuple,done_request,done_generation,done_epoch};repeat(5)begin step();if(!done_valid||{done_status,source_status,error_domain,error_tuple,done_request,done_generation,done_epoch}!==held||cmd_ready)$fatal(1,"held full parent failure");end end
  $display("M007_FFN_WIFI_FAIL_PASS real_G_values=%0d RRESP=%0d Gcancel=%0d failed_close=%0d discard=%0d no_reset=1",g_outputs*8,actual_rresp,actual_gcancel,actual_failed_close,actual_discard);$fflush();
  @(negedge clk);done_ready=1;step();@(negedge clk);done_ready=0;wait(cmd_ready);
  fault_mode=0;cmd_request=78;cmd_generation=9;cmd_epoch=10;
  commands=0;mcommands=0;gcommands=0;input_count=0;wi_outputs=0;down_outputs=0;g_outputs=0;node_checks=0;g_writes=0;g_acks=0;g_reads=0;g_releases=0;wi_done=0;g_done=0;down_done=0;parent_retired=0;issue_owned=0;ps_owned=0;g_cmd_cycle=-1;g_tail_start=-1;
 INITIALISE
  @(negedge clk);cmd_valid=1;do @(posedge clk);while(!cmd_ready);@(negedge clk);cmd_valid=0;
 STREAM
'''.replace(' INITIALISE',initialise).replace(' STREAM',stream)
s=s[:input_end]+recovery+s[input_end:]
s=s.replace('$display("HARDWARE_AGENT_SIM_PASS M007_FFN_PREFIX");', '$display("M007_FFN_NEWGEN_RECOVERY_PASS generation=%0d epoch=%0d real_G_values=%0d A0=%0d A1prefix=%0d no_reset=1",cmd_generation,cmd_epoch,g_outputs*8,awrites[0],awrites[1]);$display("HARDWARE_AGENT_SIM_PASS M007_FFN_WIFI_ERROR_RECOVERY");')
(M/'tb/m007_ffn_fault_tb.sv').write_text(s)
