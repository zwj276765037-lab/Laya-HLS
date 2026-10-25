#!/usr/bin/env python3
from pathlib import Path
import hashlib,json
ROOT=Path(__file__).resolve().parents[3];M=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/forward_controller';s=(M/'tb/m007_single_parent_tb.sv').read_text();original=s
changes=[]
def rep(old,new):
 global s
 assert s.count(old)==1,(old[:90],s.count(old));s=s.replace(old,new);changes.append(old[:120])
rep('module m007_single_parent_tb;','module m007_full_parent_tb;')
rep(' logic max_checked=0;',''' logic [15:0] max_checked=0;
 logic [1023:0] wo_gold[0:4095],wo_inputs[0:4095];logic [271:0] wo_agold[0:4095];logic [8191:0] wo_prebias[0:511];
 logic [511:0] wo_mem0[0:4607],wo_mem1[0:4607],wo_mem2[0:4607],wo_mem3[0:4607];
 logic bphase[0:3][0:7];logic [63:0] bbase[0:3][0:7];
 integer matrix_phase=0,stop_after_head=0,quant_returns[0:1],fill_writes[0:1],fill_acks[0:1],publications[0:1];
 integer layer_done_count=0,ctx_reads=0,ctx_responses=0,ctx_inputs=0,ctx_pending=0;logic ctx_owned=0;
 integer wo_outputs=0,wo_matrix_done=0,parent_done_count=0,normal_cmd_count=0,head_score[0:15],head_prob[0:15],head_context[0:15],head_prob_ack[0:15],head_maximum[0:15];
 integer qkv_cmd_cycle=-1,qkv_last_cycle=-1,layer_start_cycle=-1,layer_done_cycle=-1,context_start_cycle=-1,context_last_cycle=-1,wo_cmd_cycle=-1,wo_last_cycle=-1,wo_done_cycle=-1;
 integer first_parent_done_cycle=-1;integer wo_mid_hold=0,wo_last_hold=0;logic wo_mid_done=0,wo_last_done=0,out_held=0;logic [1174:0] held_out;
 logic normal_started=0,cycle_failed=0;integer dispatch[0:6],dispatch_total=0,prepare_cycle=-1,qcmd_cycle=-1,qdone_cycle=-1,mdone_cycle=-1,drain_eligible_cycle=-1;
 logic [242:0] expected_done;
 wire fill_phase=layer_done_count!=0;
 string context_fixture;''')
rep(' integer ar_count=0,r_count=0,issues[0:47],acks[0:47],retired[0:47],first_issue[0:47],last_issue[0:47];',' integer ar_count=0,r_count=0,issues[0:1][0:47],acks[0:1][0:47],retired[0:1][0:47],first_issue[0:1][0:47],last_issue[0:1][0:47];')
rep(' function automatic logic [511:0] word(input integer p,idx);case(p)0:return mem0[idx];1:return mem1[idx];2:return mem2[idx];default:return mem3[idx];endcase endfunction',''' function automatic logic [511:0] word_at(input integer phase,p,idx);
  if(phase)case(p)0:return wo_mem0[idx];1:return wo_mem1[idx];2:return wo_mem2[idx];default:return wo_mem3[idx];endcase
  else case(p)0:return mem0[idx];1:return mem1[idx];2:return mem2[idx];default:return mem3[idx];endcase
 endfunction
 function automatic logic [511:0] word(input integer p,idx);return word_at(matrix_phase,p,idx);endfunction
 function automatic logic [271:0] a_at(input integer phase,idx);return phase?wo_agold[idx]:agold[idx];endfunction''')
rep('word(p,((baddr[p][pick]-cmd_base[0][p])>>6)+bpos[p][pick])','word_at(bphase[p][pick],p,((baddr[p][pick]-bbase[p][pick])>>6)+bpos[p][pick])')
rep('   if(cmd_valid&&cmd_ready)command_cycle=cycle;','''   if(cmd_valid&&cmd_ready)begin
    command_cycle=cycle;
    if(mode==0)begin normal_started=1;normal_cmd_count=normal_cmd_count+1;expected_done={8'd0,8'd0,3'd0,96'd0,cmd_request,cmd_generation,cmd_epoch};if(normal_cmd_count!=1)$fatal(1,"normal parent command must be accepted exactly once");end
   end''')
rep('   if(dut.l_prepare_valid&&dut.l_prepare_ready)layer_prepares=layer_prepares+1;','   if(dut.l_prepare_valid&&dut.l_prepare_ready)begin layer_prepares=layer_prepares+1;prepare_cycle=cycle;dispatch[0]=cycle-command_cycle;end')
rep('layer_starts=layer_starts+1;end','layer_starts=layer_starts+1;layer_start_cycle=cycle;dispatch[3]=cycle-mdone_cycle;if(cycle-command_cycle>57344)begin cycle_failed=1;$display("M007_PARENT_CYCLE_VIOLATION QKV_command_to_layer_start=%0d cap=57344",cycle-command_cycle);end end')
rep('   if(dut.q_awr_valid&&dut.q_awr_ready)begin if(dut.q_awr_data!==agold[dut.q_awr_row*32+dut.q_awr_group])$fatal(1,"actual quant/A bytes row%0d group%0d",dut.q_awr_row,dut.q_awr_group);awrites=awrites+1;checked(32,"QUANT_A");end','''   if(dut.q_awr_valid&&dut.q_awr_ready)begin if(dut.q_awr_data!==a_at(fill_phase,dut.q_awr_row*32+dut.q_awr_group))$fatal(1,"actual quant/A bytes phase%0d row%0d group%0d",fill_phase,dut.q_awr_row,dut.q_awr_group);awrites=awrites+1;fill_writes[fill_phase]=fill_writes[fill_phase]+1;checked(32,fill_phase?"CONTEXT_QUANT_A":"QUANT_A");end''')
rep('   if(dut.q_awr_rsp_valid&&dut.q_awr_rsp_ready)aacks=aacks+1;','''   if(dut.q_awr_rsp_valid&&dut.q_awr_rsp_ready)begin aacks=aacks+1;fill_acks[fill_phase]=fill_acks[fill_phase]+1;end
   if(dut.front.q_out_valid&&dut.front.q_out_ready)quant_returns[fill_phase]=quant_returns[fill_phase]+1;
   if(dut.q_acfg_rsp_valid&&dut.q_acfg_rsp_ready)begin if(dut.q_acfg_status!=0)$fatal(1,"actual A publication status");publications[fill_phase]=publications[fill_phase]+1;$display("M007_PARENT_A_PUBLISH phase=%0d cycle=%0d",fill_phase,cycle);$fflush();end
   if(dut.q_cmd_valid&&dut.q_cmd_ready)begin if(fill_phase)begin context_start_cycle=cycle;dispatch[4]=cycle-layer_done_cycle;end else begin qcmd_cycle=cycle;dispatch[1]=cycle-prepare_cycle;end end
   if(dut.q_done_valid&&dut.q_done_ready&&!fill_phase)qdone_cycle=cycle;
   if(dut.m_done_valid&&dut.m_done_ready)begin
    if(dut.m_done_request!=cmd_request||dut.m_done_generation!=cmd_generation||dut.m_done_epoch!=cmd_epoch||dut.m_status!=0)$fatal(1,"actual successful matrix response identity/status");
    if(matrix_phase==0)mdone_cycle=cycle;else begin wo_matrix_done=wo_matrix_done+1;wo_done_cycle=cycle;if(wo_outputs!=4096||dut.matrix.a_slot_leased!=0||dut.matrix.w_slot_leased!=0||dut.m_arithmetic_debt!=0||dut.r_res_fp_lease_active)$fatal(1,"WO done before actual outputs and resource retirement");$display("M007_PARENT_WO_DONE cycle=%0d",cycle);$fflush();end
   end
   if(parent_state==10&&dut.c_idle&&dut.c_complete&&dut.l_layer_idle&&drain_eligible_cycle<0)drain_eligible_cycle=cycle;''')
old='''    matrix_accepts=matrix_accepts+1;
    if(input_count!=4096||awrites!=4096||aacks!=4096||dut.front.q_lease_active||dut.q_d_lease_active||dut.front.q_reservations!=0||dut.front.a_write_debt!=0||!dut.front.a_published||!dut.front.producer_closed||!dut.front.producer_success)$fatal(1,"parent matrix before real input/quant/A/debt release");'''
new='''    matrix_phase=dut.m_cmd_n==1024;matrix_accepts=matrix_accepts+1;
    if(input_count!=4096||fill_writes[matrix_phase]!=4096||fill_acks[matrix_phase]!=4096||quant_returns[matrix_phase]!=4096||publications[matrix_phase]!=1||dut.front.q_lease_active||dut.q_d_lease_active||dut.front.q_reservations!=0||dut.front.a_write_debt!=0||!dut.front.a_published||!dut.front.producer_closed||!dut.front.producer_success)$fatal(1,"parent matrix before real input/quant/A/debt release");
    if(dut.m_cmd_request!=cmd_request||dut.m_cmd_generation!=cmd_generation||dut.m_cmd_epoch!=cmd_epoch||dut.m_cmd_tensor!=cmd_tensor[matrix_phase]||dut.m_cmd_k!=1024||dut.m_cmd_n!=(matrix_phase?1024:3072)||dut.m_cmd_base!==cmd_base[matrix_phase]||dut.m_cmd_span!==cmd_span[matrix_phase])$fatal(1,"real matrix descriptor identity/key/base remap");
    if(matrix_phase)begin
     wo_cmd_cycle=cycle;dispatch[5]=cycle-drain_eligible_cycle;
     if(matrix_accepts!=2||layer_done_count!=1||nheads!=16||ctx_reads!=4096||ctx_responses!=4096||ctx_inputs!=4096||ctx_owned||dut.c_accepted!=4096||dut.c_consumed!=4096||!dut.c_idle||!dut.c_complete||!dut.l_layer_idle||dut.r_res_fp_lease_active||!dut.r_res_st_idle||dut.matrix.a_slot_leased!=0||dut.matrix.w_slot_leased!=0||rvalid!=0)$fatal(1,"WO start before actual full context ownership/debt retirement");
     for(int pp=0;pp<4;pp++)if(live[pp]!=0)$fatal(1,"WO rebind before old QKV AR/R debt drained");
     $display("M007_PARENT_WO_BEGIN cycle=%0d context_first_cycle=%0d context_last_cycle=%0d",cycle,context_start_cycle,context_last_cycle);$fflush();
    end else begin if(matrix_accepts!=1)$fatal(1,"duplicate QKV command");qkv_cmd_cycle=cycle;dispatch[2]=cycle-qdone_cycle;end'''
rep(old,new)
old='''     if(live[p][arid[p]]||arlen[p]>15||araddr[p][5:0]!=0||{1'b0,araddr[p][11:0]}+64*(arlen[p]+1)>4096||araddr[p]<cmd_base[0][p]||araddr[p]+64*(arlen[p]+1)>cmd_base[0][p]+cmd_span[0][p])$fatal(1,"real AXI ID/page/span");
     live[p][arid[p]]<=1;baddr[p][arid[p]]<=araddr[p];'''
new='''     integer source_index;source_index=-1;
     for(int ph=0;ph<2;ph++)if(araddr[p]>=cmd_base[ph][p]&&araddr[p]+64*(arlen[p]+1)<=cmd_base[ph][p]+cmd_span[ph][p])begin if(source_index>=0)$fatal(1,"ambiguous fixture address source");source_index=ph;end
     if(live[p][arid[p]]||arlen[p]>15||araddr[p][5:0]!=0||{1'b0,araddr[p][11:0]}+64*(arlen[p]+1)>4096||source_index<0||source_index!=matrix_phase)$fatal(1,"real AXI ID/page/span/source");
     bphase[p][arid[p]]<=source_index;bbase[p][arid[p]]<=cmd_base[source_index][p];
     live[p][arid[p]]<=1;baddr[p][arid[p]]<=araddr[p];'''
rep(old,new)
for name in ['issues','acks','retired','first_issue','last_issue']:s=s.replace(name+'[ss]',name+'[matrix_phase][ss]')
rep('if(ss>=48||seq!=issues[matrix_phase][ss])','if(ss>=(matrix_phase?16:48)||seq!=issues[matrix_phase][ss])')
rep('agold[(16*(seq%8)+a)*32+seq/32][255:0]','a_at(matrix_phase,(16*(seq%8)+a)*32+seq/32)[255:0]')
rep('agold[(16*(seq%8)+a)*32+seq/32][271:256]','a_at(matrix_phase,(16*(seq%8)+a)*32+seq/32)[271:256]')
rep('dut.matrix.core.trace_commit_data!==prebias[32*ss+seq-992]','dut.matrix.core.trace_commit_data!==(matrix_phase?wo_prebias[32*ss+seq-992]:prebias[32*ss+seq-992])')
rep('qkv_count=qkv_count+1;retired[matrix_phase][ss]=retired[matrix_phase][ss]+1;checked(32,"QKV_PUBLIC");','''qkv_count=qkv_count+1;retired[matrix_phase][ss]=retired[matrix_phase][ss]+1;checked(32,"QKV_PUBLIC");
    if(qkv_count==12288)begin qkv_last_cycle=cycle;$display("M007_PARENT_QKV_ALL_END cycle=%0d values=393216",cycle);$fflush();end''')
rep('   if(done_valid&&done_status!=0&&mode==0)$fatal(1,"parent unexpected done status%0d source%0d domain%0d tuple%h",done_status,source_status,error_domain,error_tuple);','''   if(done_valid&&mode==0&&normal_started)begin
    if(nheads!=16||layer_done_count!=1||ctx_responses!=4096||fill_writes[1]!=4096||fill_acks[1]!=4096||publications[1]!=1||wo_outputs!=4096||wo_matrix_done!=1||{done_status,source_status,error_domain,error_tuple,done_request,done_generation,done_epoch}!==expected_done)$fatal(1,"first parent success before complete real chain or incorrect243bit expected response");
    if(first_parent_done_cycle<0)begin first_parent_done_cycle=cycle;dispatch[6]=cycle-wo_done_cycle;$display("M007_PARENT_FIRST_SUCCESS cycle=%0d",cycle);$fflush();end
    if(done_ready)parent_done_count=parent_done_count+1;
   end
   if(out_held&&(!out_valid||{out_data,out_row,out_col,dut.m_out_request,dut.m_out_generation,dut.m_out_epoch}!==held_out))$fatal(1,"full WO output hold fields");
   out_held=out_valid&&!out_ready;held_out={out_data,out_row,out_col,dut.m_out_request,dut.m_out_generation,dut.m_out_epoch};
   if(out_valid&&!out_ready)begin if(wo_outputs==128)wo_mid_hold=wo_mid_hold+1;if(wo_outputs==4095)wo_last_hold=wo_last_hold+1;if(done_valid||dut.m_done_valid)$fatal(1,"held WO output produced early done");end
   if(out_valid&&out_ready)begin
    integer ss,off;ss=wo_outputs/256;off=wo_outputs%256;
    if(parent_state!=12||ss>=16||out_row!=off/2||out_col!=64*ss+32*(off%2)||out_data!==wo_gold[wo_outputs]||dut.m_out_request!=cmd_request||dut.m_out_generation!=cmd_generation||dut.m_out_epoch!=cmd_epoch||acks[1][ss]!=1024)$fatal(1,"actual original WO public output mapping/value/identity");
    retired[1][ss]=retired[1][ss]+1;wo_outputs=wo_outputs+1;checked(32,"WO_PUBLIC");
    if(wo_outputs%256==0)begin $display("M007_PARENT_WO_BLOCK_END block=%0d groups=%0d cycle=%0d",ss,wo_outputs,cycle);$fflush();end
    if(wo_outputs==4096)begin wo_last_cycle=cycle;$display("M007_PARENT_WO_ALL_END cycle=%0d values=131072",cycle);$fflush();end
   end
   if(dut.c_rsp_valid&&dut.c_rsp_ready)begin
    integer q,h,half;q=ctx_pending/32;h=(ctx_pending%32)/2;half=ctx_pending%2;
    if(!ctx_owned||dut.c_rsp_tag!=ctx_pending)$fatal(1,"actual public context response credit/tag");
    for(int c=0;c<32;c++)if(dut.c_rsp_data[c]!==contextgold[(h*128+q)*64+half*32+c])$fatal(1,"actual original public context value");
    ctx_owned=0;ctx_responses=ctx_responses+1;checked(32,"CONTEXT_PUBLIC");
    if(ctx_responses==4096)begin context_last_cycle=cycle;$display("M007_PARENT_CONTEXT_ALL_END cycle=%0d groups=4096",cycle);$fflush();end
   end
   if(dut.c_rd_valid&&dut.c_rd_ready)begin
    if(ctx_owned||ctx_reads>=4096||dut.c_rd_generation!=cmd_generation||dut.c_rd_tag!=ctx_reads||dut.c_rd_query!=ctx_reads/32||dut.c_rd_head!=(ctx_reads%32)/2||dut.c_rd_half!=ctx_reads%2)$fatal(1,"actual public context query/head/half order");
    ctx_pending=ctx_reads;ctx_owned=1;ctx_reads=ctx_reads+1;
   end
   if(dut.c_out_valid&&dut.c_out_ready)begin if(dut.c_out_row!=ctx_inputs/32||dut.c_out_group!=ctx_inputs%32||dut.c_out_data!==wo_inputs[ctx_inputs])$fatal(1,"real context to original quant input order/value");ctx_inputs=ctx_inputs+1;end
   if(dut.l_done_valid&&dut.l_done_ready)begin
    if(dut.l_done_status!=0||dut.l_done_request_id!=cmd_request||dut.l_done_generation!=cmd_generation||nheads!=16||layer_head_completed!=16'hffff||dut.l_head_context_valid!=16'hffff||dut.l_error_valid)$fatal(1,"actual layer full-head done identity/coverage");
    for(int st=0;st<26;st++)if((dut.l_check_completed[st]|dut.l_check_unreachable[st]|dut.l_check_dominated[st])!==16'hffff||((dut.l_check_completed[st]&dut.l_check_unreachable[st])|(dut.l_check_completed[st]&dut.l_check_dominated[st])|(dut.l_check_unreachable[st]&dut.l_check_dominated[st]))!=0)$fatal(1,"layer Check classification coverage/overlap");
    if((dut.l_av_check_completed|dut.l_av_check_unreachable|dut.l_av_check_dominated)!=={2048{1'b1}}||((dut.l_av_check_completed&dut.l_av_check_unreachable)|(dut.l_av_check_completed&dut.l_av_check_dominated)|(dut.l_av_check_unreachable&dut.l_av_check_dominated))!=0)$fatal(1,"layer AV Check coverage/overlap");
    layer_done_count=layer_done_count+1;layer_done_cycle=cycle;if(dut.l_done_cycles>188544)begin cycle_failed=1;$display("M007_PARENT_CYCLE_VIOLATION layer=%0d cap=188544",dut.l_done_cycles);end
    $display("M007_PARENT_LAYER_ALL_END cycle=%0d layer_cycles=%0d heads=16",cycle,dut.l_done_cycles);$fflush();
   end''')
# Head observations retain every original numerical comparison; counters are per head and total.
rep('nscore=nscore+1;checked(1,"SCORE");','nscore=nscore+1;head_score[dut.layer.active_head]=head_score[dut.layer.active_head]+1;checked(1,"SCORE");')
rep('nprob=nprob+1;checked(1,"PROB");','nprob=nprob+1;head_prob[dut.layer.active_head]=head_prob[dut.layer.active_head]+1;checked(1,"PROB");')
rep('ncontext=ncontext+1;checked(1,"CONTEXT");','ncontext=ncontext+1;head_context[dut.layer.active_head]=head_context[dut.layer.active_head]+1;checked(1,"CONTEXT");')
rep('nprob_ack=nprob_ack+1;','nprob_ack=nprob_ack+1;head_prob_ack[dut.layer.active_head]=head_prob_ack[dut.layer.active_head]+1;')
rep('if(dut.layer.h_check_qk_done&&!max_checked)begin for(int r=0;r<128;r++)if(dut.layer.h_maximum[r]!==maxgold[int\'(dut.layer.active_head)*128+r])$fatal(1,"parent real maximum");max_checked=1;end','''if(dut.layer.state==7&&dut.layer.h_check_qk_done&&!max_checked[dut.layer.active_head])begin for(int r=0;r<128;r++)if(dut.layer.h_maximum[r]!==maxgold[int'(dut.layer.active_head)*128+r])$fatal(1,"parent real maximum");max_checked[dut.layer.active_head]=1;head_maximum[dut.layer.active_head]=128;checked(128,"MAXIMUM");end''')
old='''   if(dut.layer.h_done_status!=0||dut.layer.h_done_cycles>11648||nscore!=16384||nprob!=16384||ncontext!=8192||nprob_ack!=2048||nrope!=2048||qkv_count!=12288||layer_starts!=1)$fatal(1,"parent first head numeric/event coverage");
   nheads=nheads+1;$display("M007_PARENT_FIRST_HEAD_PASS public_QKV32=12288 original_QKV_values=393216 RoPE_commits=2048 score=16384 prob=16384 context=8192 head_cycles=%0d QKV_to_head_end_cycles=%0d unfinished_parent=1",dut.layer.h_done_cycles,cycle-command_cycle);$display("HARDWARE_AGENT_SIM_PASS M007_PARENT_FIRST_HEAD");$fflush();$finish;'''
new='''   if(dut.layer.h_done_status!=0||dut.layer.h_done_cycles>11648||head_score[dut.layer.active_head]!=16384||head_prob[dut.layer.active_head]!=16384||head_context[dut.layer.active_head]!=8192||head_prob_ack[dut.layer.active_head]!=2048||head_maximum[dut.layer.active_head]!=128||!max_checked[dut.layer.active_head]||nrope!=2048||qkv_count!=12288||layer_starts!=1||dut.layer.active_head!=nheads||dut.layer.h_done_request_id!=cmd_request||dut.layer.h_done_generation!=cmd_generation||dut.layer.h_done_head!=nheads)$fatal(1,"parent per-head numeric/maximum/event/identity/cycle coverage");
   $display("M007_PARENT_HEAD_END head=%0d cycle=%0d head_cycles=%0d",dut.layer.active_head,cycle,dut.layer.h_done_cycles);$fflush();nheads=nheads+1;
   if(stop_after_head>0&&nheads==stop_after_head)begin
    if(done_valid||matrix_accepts!=1||ctx_reads!=0||wo_outputs!=0)$fatal(1,"head pilot must remain unfinished actual parent");
    $display("M007_PARENT_TWO_HEAD_PASS heads=%0d QKV32=%0d score=%0d prob=%0d context=%0d maxima=%0d elapsed=%0d",nheads,qkv_count,nscore,nprob,ncontext,128*nheads,cycle-command_cycle);$display("HARDWARE_AGENT_SIM_PASS M007_PARENT_TWO_HEAD");$fflush();$finish;
   end'''
rep(old,new)
# Legal WO backpressure only; this observer never drives an internal DUT signal.
pos=s.index(' task automatic invalid_identity')
s=s[:pos]+''' always @(negedge clk)if(rst_n&&normal_started)begin
  if(parent_state==12&&wo_outputs==128&&!wo_mid_done)begin out_ready=0;if(wo_mid_hold>=8)begin out_ready=1;wo_mid_done=1;end end
  else if(parent_state==12&&wo_outputs==4095&&!wo_last_done)begin out_ready=0;if(wo_last_hold>=12)begin out_ready=1;wo_last_done=1;end end
  else out_ready=1;
 end
'''+s[pos:]
rep('if(!$value$plusargs("PREFIX=%d",prefix))prefix=3;','''if(!$value$plusargs("PREFIX=%d",prefix))prefix=0;
  if(!$value$plusargs("STOP_AFTER_HEAD=%d",stop_after_head))stop_after_head=0;
  if(stop_after_head!=0&&stop_after_head!=2)$fatal(1,"only actual second-head pilot or full endpoint allowed");
  if(!$value$plusargs("CONTEXT=%s",context_fixture))$fatal(1,"original WO fixture required");
  $readmemh({context_fixture,"/wo_0_weight/output.hex"},wo_gold);$readmemh({context_fixture,"/wo_0_weight/input.hex"},wo_inputs);$readmemh({context_fixture,"/wo_0_weight/a_write.hex"},wo_agold);$readmemh({context_fixture,"/wo_0_weight/pre_bias.hex"},wo_prebias);
  $readmemh({context_fixture,"/wo_0_weight/p0.hex"},wo_mem0);$readmemh({context_fixture,"/wo_0_weight/p1.hex"},wo_mem1);$readmemh({context_fixture,"/wo_0_weight/p2.hex"},wo_mem2);$readmemh({context_fixture,"/wo_0_weight/p3.hex"},wo_mem3);
  for(int ph=0;ph<2;ph++)begin quant_returns[ph]=0;fill_writes[ph]=0;fill_acks[ph]=0;publications[ph]=0;end
  for(int h=0;h<16;h++)begin head_score[h]=0;head_prob[h]=0;head_context[h]=0;head_prob_ack[h]=0;head_maximum[h]=0;end
  for(int i=0;i<7;i++)dispatch[i]=-1;''')
old='for(int ss=0;ss<48;ss++)begin issues[matrix_phase][ss]=0;acks[matrix_phase][ss]=0;retired[matrix_phase][ss]=0;first_issue[matrix_phase][ss]=-1;last_issue[matrix_phase][ss]=-1;end'
new='for(int pp=0;pp<2;pp++)for(int ss=0;ss<48;ss++)begin issues[pp][ss]=0;acks[pp][ss]=0;retired[pp][ss]=0;first_issue[pp][ss]=-1;last_issue[pp][ss]=-1;end';rep(old,new)
rep('  wait(nheads==1);','''  wait(done_valid);@(negedge clk);
  if({done_status,source_status,error_domain,error_tuple,done_request,done_generation,done_epoch}!==expected_done||cmd_ready||wo_outputs!=4096||nheads!=16||nscore!=262144||nprob!=262144||ncontext!=131072||nprob_ack!=32768||max_checked!=16'hffff||!wo_mid_done||!wo_last_done||wo_mid_hold<8||wo_last_hold<12||normal_cmd_count!=1||matrix_accepts!=2||layer_done_count!=1||ctx_responses!=4096||ctx_inputs!=4096||ctx_reads!=4096||wo_matrix_done!=1)$fatal(1,"full parent expected successful243bit response/complete coverage");
  for(int ss=0;ss<16;ss++)if(issues[1][ss]!=1024||acks[1][ss]!=1024||retired[1][ss]!=256||last_issue[1][ss]-first_issue[1][ss]+1!=1024)$fatal(1,"WO complete block coverage");
  for(int ss=0;ss<48;ss++)if(issues[0][ss]!=1024||acks[0][ss]!=1024||retired[0][ss]!=256||last_issue[0][ss]-first_issue[0][ss]+1!=1024)$fatal(1,"QKV complete block coverage");
  repeat(5)begin step();if(!done_valid||cmd_ready||{done_status,source_status,error_domain,error_tuple,done_request,done_generation,done_epoch}!==expected_done)$fatal(1,"normal successful parent independently expected243bit held response");end
  $display("M007_PARENT_SUCCESS_HELD_PASS response_bits=243 held_cycles=5 status=0 source=0 domain=0 tuple=0 request=%0d generation=%0d epoch=%0d",done_request,done_generation,done_epoch);$fflush();
  @(negedge clk);done_ready=1;step();@(negedge clk);done_ready=0;repeat(3)step();
  if(!cmd_ready||done_valid||out_valid||parent_done_count!=1)$fatal(1,"one actual normal parent retirement and IDLE");
  dispatch_total=0;for(int i=0;i<7;i++)begin if(dispatch[i]<0||dispatch[i]>16)begin cycle_failed=1;$display("M007_PARENT_CYCLE_VIOLATION dispatch_index=%0d cycles=%0d cap=16",i,dispatch[i]);end dispatch_total=dispatch_total+dispatch[i];end
  if(dispatch_total>128||wo_last_cycle-context_start_cycle>22528||wo_last_cycle-command_cycle>268416)begin cycle_failed=1;$display("M007_PARENT_CYCLE_VIOLATION dispatch_total=%0d WO_context_to_last=%0d parent_cmd_to_last=%0d",dispatch_total,wo_last_cycle-context_start_cycle,wo_last_cycle-command_cycle);end
  $display("M007_PARENT_ALL_NUMERIC_PASS QKV_values=393216 heads=16 score=262144 prob=262144 context=131072 public_context_groups=4096 context_quant_Agroups=4096 WO_values=131072 successful_parent_retired=1 held_mid=%0d held_last=%0d",wo_mid_hold,wo_last_hold);
  $display("M007_PARENT_FULL_CYCLES parent_cmd=%0d QKV_cmd=%0d QKV_last=%0d layer_start=%0d layer_done=%0d context_start=%0d context_last=%0d WO_cmd=%0d WO_last=%0d WO_done=%0d dispatch_total=%0d raw_parent_cmd_to_WO_last=%0d raw_QKV_cmd_to_WO_last=%0d cycle_pass=%0d",command_cycle,qkv_cmd_cycle,qkv_last_cycle,layer_start_cycle,layer_done_cycle,context_start_cycle,context_last_cycle,wo_cmd_cycle,wo_last_cycle,wo_done_cycle,dispatch_total,wo_last_cycle-command_cycle,wo_last_cycle-qkv_cmd_cycle,!cycle_failed);$fflush();
  if(cycle_failed)$fatal(1,"complete parent numeric PASS but cycle contract FAIL");
  $display("HARDWARE_AGENT_SIM_PASS M007_PARENT_FULL");$fflush();$finish;''')
# Function-return part selects use explicit local whole-word holder for broad xvlog support.
s=s.replace('expected_a[256*a+:256]=a_at(matrix_phase,(16*(seq%8)+a)*32+seq/32)[255:0];expected_a[4096+16*a+:16]=a_at(matrix_phase,(16*(seq%8)+a)*32+seq/32)[271:256];','begin logic [271:0] av;av=a_at(matrix_phase,(16*(seq%8)+a)*32+seq/32);expected_a[256*a+:256]=av[255:0];expected_a[4096+16*a+:16]=av[271:256];end')
# Packed output hold width =1024+7+16+64+32+32=1175.
(M/'tb/m007_full_parent_tb.sv').write_text(s)
report={'original_tb_sha256':hashlib.sha256(original.encode()).hexdigest(),'full_tb_sha256':hashlib.sha256(s.encode()).hexdigest(),'generator_scope':'Preserve original QKV/numerical/AXI/continuous issue/PS feedback/identity checks; extend exact checks by actual operation/head and add full success endpoint','targeted_replacements':changes,'original_fatal_messages_retained_or_phase_generalized':True,'production_RTL_modified':False}
(ROOT/'project/E016_m007_single_resource_parent/experiment_results/runs/R003/tb_extension_boundary.json').write_text(json.dumps(report,indent=2)+'\n')
print('M007_FULL_PARENT_TB_GENERATED')
