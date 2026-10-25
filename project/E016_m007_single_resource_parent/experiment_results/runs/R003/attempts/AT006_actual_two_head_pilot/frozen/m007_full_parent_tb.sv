`timescale 1ns/1ps
module m007_full_parent_tb;
 logic  clk;
 logic  rst_n;
 logic  cmd_valid;
 logic  cmd_ready;
 logic [63:0] cmd_request;
 logic [31:0] cmd_generation;
 logic [31:0] cmd_epoch;
 logic [127:0] cmd_model_id;
 logic [127:0] cmd_numeric_id;
 logic [127:0] cmd_table_key;
 logic [127:0] cmd_graph_id;
 logic [127:0] cmd_layout_id;
 logic [127:0] cmd_build_id;
 logic [1:0] cmd_kind;
 logic [4:0] cmd_layer;
 logic [127:0] cmd_mask;
 logic [1:0][31:0] cmd_tensor;
 logic [1:0][3:0][63:0] cmd_base;
 logic [1:0][3:0][63:0] cmd_span;
 logic  in_valid;
 logic  in_ready;
 logic [31:0][31:0] in_data;
 logic [63:0] in_request;
 logic [31:0] in_generation;
 logic [31:0] in_epoch;
 logic [7:0] in_row;
 logic [7:0] in_group;
 logic  input_reject_valid;
 logic [3:0] input_reject_code;
 logic  producer_fail_valid;
 logic [95:0] producer_fail_tuple;
 logic [63:0] producer_fail_request;
 logic [31:0] producer_fail_generation;
 logic [31:0] producer_fail_epoch;
 logic  producer_fail_ready;
 logic  out_valid;
 logic  out_ready;
 logic [31:0][31:0] out_data;
 logic [6:0] out_row;
 logic [15:0] out_col;
 logic  done_valid;
 logic  done_ready;
 logic [7:0] done_status;
 logic [2:0] error_domain;
 logic [95:0] error_tuple;
 logic [7:0] source_status;
 logic [127:0] bias_model_id;
 logic [127:0] bias_numeric_id;
 logic [63:0] done_request;
 logic [31:0] done_generation;
 logic [31:0] done_epoch;
 logic [4:0] parent_state;
 logic [31:0] elapsed_cycles;
 logic [15:0] layer_head_completed;
 logic  coeff_bind_valid;
 logic  coeff_bind_ready;
 logic [127:0] coeff_bind_model_id;
 logic [127:0] coeff_bind_numeric_id;
 logic [127:0] coeff_bind_table_key;
 logic  coeff_bound_valid;
 logic [127:0] coeff_bound_model_id;
 logic [127:0] coeff_bound_numeric_id;
 logic [127:0] coeff_bound_table_key;
 logic [1:0] coeff_family_complete;
 logic  coeff_wr_valid;
 logic  coeff_wr_ready;
 logic [127:0] coeff_wr_model_id;
 logic [127:0] coeff_wr_numeric_id;
 logic [127:0] coeff_wr_table_key;
 logic [1:0] coeff_wr_table;
 logic [6:0] coeff_wr_row;
 logic  coeff_wr_half;
 logic [31:0][31:0] coeff_wr_data;
 logic  coeff_wr_reject_valid;
 logic [2:0] coeff_wr_reject_code;
 logic [4:0] coeff_wr_nonfinite_lane;
 logic  coef_cfg_valid;
 logic  coef_cfg_ready;
 logic [63:0] coef_model;
 logic [63:0] coef_request;
 logic [31:0] coef_tensor;
 logic [31:0] coef_generation;
 logic [31:0] coef_epoch;
 logic [15:0] coef_n;
 logic  coef_wr_valid;
 logic  coef_wr_ready;
 logic [6:0] coef_wr_addr;
 logic [31:0][31:0] coef_wr_data;
 logic  coef_rsp_valid;
 logic  coef_rsp_ready;
 logic [1:0] coef_status;
 logic [15:0] coef_error_col;
 logic [3:0] arvalid;
 logic [3:0] arready;
 logic [3:0][63:0] araddr;
 logic [3:0][2:0] arid;
 logic [3:0][7:0] arlen;
 logic [3:0] rvalid;
 logic [3:0] rready;
 logic [3:0][2:0] rid;
 logic [3:0][511:0] rdata;
 logic [3:0][1:0] rresp;
 logic [3:0] rlast;
 laya_m007_single_parent_v1 dut(.*);
 always #1 clk=~clk;

 logic [1023:0] inputs[0:4095],gold[0:12287];logic [271:0] agold[0:4095];logic [8191:0] prebias[0:1535];
 logic [511:0] mem0[0:13823],mem1[0:13823],mem2[0:13823],mem3[0:13823];
 logic [31:0] cf[0:8191],sf[0:8191],maskmem[0:127],qkvgold[0:393215];
 logic [7:0] live[0:3];logic [63:0] baddr[0:3][0:7];integer bsize[0:3][0:7],bpos[0:3][0:7],eligible[0:3][0:7],rotate[0:3];logic [3:0] last_r_fire;
 logic [31:0] postgold[0:393215],scoregold[0:262143],maxgold[0:2047],probgold[0:262143],contextgold[0:131071];
 logic [15:0] max_checked=0;
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
 string context_fixture;
 integer cycle=0;
 integer checked_words=0,last_checked_report=0;
 task automatic checked(input int words,input string phase);
  checked_words=checked_words+words;
  if(checked_words-last_checked_report>=4096)begin $display("M007_PARENT_CHECKED checked=%0d phase=%s cycle=%0d",checked_words,phase,cycle);$fflush();last_checked_report=checked_words;end
 endtask
 integer nrope=0,nscore=0,nprob=0,ncontext=0,nprob_ack=0,nheads=0,head_start_cycle=-1;
 integer qkv_count=0,input_count=0,awrites=0,aacks=0,matrix_accepts=0,layer_starts=0,layer_prepares=0,prefix=3,mode=0,command_cycle=-1;
 integer ar_count=0,r_count=0,issues[0:1][0:47],acks[0:1][0:47],retired[0:1][0:47],first_issue[0:1][0:47],last_issue[0:1][0:47];
 integer issue_time[0:63],ps_time[0:63],issue_seq[0:63];logic[63:0]issue_owned,ps_owned;integer max_issue_ack=0,max_ps_feedback=0;
 logic [4351:0] expected_w,expected_a;logic [511:0] temp;
 logic [31:0] old_state=0;string matrix_fixture,input_fixture,attention_fixture;
 function automatic logic [511:0] word_at(input integer phase,p,idx);
  if(phase)case(p)0:return wo_mem0[idx];1:return wo_mem1[idx];2:return wo_mem2[idx];default:return wo_mem3[idx];endcase
  else case(p)0:return mem0[idx];1:return mem1[idx];2:return mem2[idx];default:return mem3[idx];endcase
 endfunction
 function automatic logic [511:0] word(input integer p,idx);return word_at(matrix_phase,p,idx);endfunction
 function automatic logic [271:0] a_at(input integer phase,idx);if(phase)return wo_agold[idx];else return agold[idx];endfunction
 task automatic step;begin @(posedge clk);#0.1;end endtask
 always_comb arready=15;
 always @(negedge clk)begin
  if(!rst_n)begin rvalid=0;rid=0;rdata=0;rresp=0;rlast=0;end
  else for(integer p=0;p<4;p++)if(!rvalid[p]||last_r_fire[p])begin
   integer pick;pick=-1;for(integer q=7;q>=0;q--)if(live[p][(rotate[p]+q)%8]&&cycle>=eligible[p][(rotate[p]+q)%8])pick=(rotate[p]+q)%8;
   rvalid[p]=0;
   if(pick>=0&&cycle%2==0)begin rvalid[p]=1;rid[p]=pick;rdata[p]=word_at(bphase[p][pick],p,((baddr[p][pick]-bbase[p][pick])>>6)+bpos[p][pick]);rlast[p]=bpos[p][pick]+1==bsize[p][pick];rresp[p]=0;end
  end
 end
 always @(posedge clk)begin
  cycle=cycle+1;last_r_fire<=rvalid&rready;
  if(!rst_n)begin issue_owned=0;ps_owned=0;for(integer p=0;p<4;p++)begin live[p]<=0;rotate[p]<=0;end end
  else begin
   if(cmd_valid&&cmd_ready)begin
    command_cycle=cycle;
    if(mode==0)begin normal_started=1;normal_cmd_count=normal_cmd_count+1;expected_done={8'd0,8'd0,3'd0,96'd0,cmd_request,cmd_generation,cmd_epoch};if(normal_cmd_count!=1)$fatal(1,"normal parent command must be accepted exactly once");end
   end
   if(dut.l_prepare_valid&&dut.l_prepare_ready)begin layer_prepares=layer_prepares+1;prepare_cycle=cycle;dispatch[0]=cycle-command_cycle;end
   if(dut.l_start_valid&&dut.l_start_ready)begin if(qkv_count!=12288||matrix_accepts!=1||dut.m_done_valid)$fatal(1,"layer start before complete real QKV/receipt");layer_starts=layer_starts+1;layer_start_cycle=cycle;dispatch[3]=cycle-mdone_cycle;if(cycle-command_cycle>57344)begin cycle_failed=1;$display("M007_PARENT_CYCLE_VIOLATION QKV_command_to_layer_start=%0d cap=57344",cycle-command_cycle);end end
   if(parent_state!=old_state)begin $display("MATRIX_PROGRESS parent_state=%0d cycle=%0d QKV=%0d",parent_state,cycle,qkv_count);$fflush();old_state=parent_state;end
   if(in_valid&&in_ready)input_count=input_count+1;
   if(dut.q_awr_valid&&dut.q_awr_ready)begin if(fill_writes[fill_phase]==0)begin $display("M007_PARENT_FIRST_AWRITE phase=%0d row=%0d group=%0d",fill_phase,dut.q_awr_row,dut.q_awr_group);$fflush();end if(dut.q_awr_data!==a_at(fill_phase,dut.q_awr_row*32+dut.q_awr_group))$fatal(1,"actual quant/A bytes phase%0d row%0d group%0d",fill_phase,dut.q_awr_row,dut.q_awr_group);awrites=awrites+1;fill_writes[fill_phase]=fill_writes[fill_phase]+1;if(fill_phase)checked(32,"CONTEXT_QUANT_A");else checked(32,"QUANT_A");end
   if(dut.q_awr_rsp_valid&&dut.q_awr_rsp_ready)begin aacks=aacks+1;fill_acks[fill_phase]=fill_acks[fill_phase]+1;end
   if(dut.front.q_out_valid&&dut.front.q_out_ready)quant_returns[fill_phase]=quant_returns[fill_phase]+1;
   if(dut.q_acfg_rsp_valid&&dut.q_acfg_rsp_ready)begin if(dut.q_acfg_status!=0)$fatal(1,"actual A publication status");publications[fill_phase]=publications[fill_phase]+1;$display("M007_PARENT_A_PUBLISH phase=%0d cycle=%0d",fill_phase,cycle);$fflush();end
   if(dut.q_cmd_valid&&dut.q_cmd_ready)begin if(fill_phase)begin context_start_cycle=cycle;dispatch[4]=cycle-layer_done_cycle;end else begin qcmd_cycle=cycle;dispatch[1]=cycle-prepare_cycle;end end
   if(dut.q_done_valid&&dut.q_done_ready&&!fill_phase)qdone_cycle=cycle;
   if(dut.m_done_valid&&dut.m_done_ready)begin
    if(dut.m_done_request!=cmd_request||dut.m_done_generation!=cmd_generation||dut.m_done_epoch!=cmd_epoch||dut.m_status!=0)$fatal(1,"actual successful matrix response identity/status");
    if(matrix_phase==0)mdone_cycle=cycle;else begin wo_matrix_done=wo_matrix_done+1;wo_done_cycle=cycle;if(wo_outputs!=4096||dut.matrix.a_slot_leased!=0||dut.matrix.w_slot_leased!=0||dut.m_arithmetic_debt!=0||dut.r_res_fp_lease_active)$fatal(1,"WO done before actual outputs and resource retirement");$display("M007_PARENT_WO_DONE cycle=%0d",cycle);$fflush();end
   end
   if(parent_state==10&&dut.c_idle&&dut.c_complete&&dut.l_layer_idle&&drain_eligible_cycle<0)drain_eligible_cycle=cycle;
   if(dut.m_cmd_valid&&dut.m_cmd_ready)begin
    matrix_phase=dut.m_cmd_n==1024;matrix_accepts=matrix_accepts+1;
    if(input_count!=4096||fill_writes[matrix_phase]!=4096||fill_acks[matrix_phase]!=4096||quant_returns[matrix_phase]!=4096||publications[matrix_phase]!=1||dut.front.q_lease_active||dut.q_d_lease_active||dut.front.q_reservations!=0||dut.front.a_write_debt!=0||!dut.front.a_published||!dut.front.producer_closed||!dut.front.producer_success)$fatal(1,"parent matrix before real input/quant/A/debt release");
    if(dut.m_cmd_request!=cmd_request||dut.m_cmd_generation!=cmd_generation||dut.m_cmd_epoch!=cmd_epoch||dut.m_cmd_tensor!=cmd_tensor[matrix_phase]||dut.m_cmd_k!=1024||dut.m_cmd_n!=(matrix_phase?1024:3072)||dut.m_cmd_base!==cmd_base[matrix_phase]||dut.m_cmd_span!==cmd_span[matrix_phase])$fatal(1,"real matrix descriptor identity/key/base remap");
    if(matrix_phase)begin
     wo_cmd_cycle=cycle;dispatch[5]=cycle-drain_eligible_cycle;
     if(matrix_accepts!=2||layer_done_count!=1||nheads!=16||ctx_reads!=4096||ctx_responses!=4096||ctx_inputs!=4096||ctx_owned||dut.c_accepted!=4096||dut.c_consumed!=4096||!dut.c_idle||!dut.c_complete||!dut.l_layer_idle||dut.r_res_fp_lease_active||!dut.r_res_st_idle||dut.matrix.a_slot_leased!=0||dut.matrix.w_slot_leased!=0||rvalid!=0)$fatal(1,"WO start before actual full context ownership/debt retirement");
     for(int pp=0;pp<4;pp++)if(live[pp]!=0)$fatal(1,"WO rebind before old QKV AR/R debt drained");
     $display("M007_PARENT_WO_BEGIN cycle=%0d context_first_cycle=%0d context_last_cycle=%0d",cycle,context_start_cycle,context_last_cycle);$fflush();
    end else begin if(matrix_accepts!=1)$fatal(1,"duplicate QKV command");qkv_cmd_cycle=cycle;dispatch[2]=cycle-qdone_cycle;end
   end
   for(integer p=0;p<4;p++)begin
    if(arvalid[p]&&arready[p])begin
     integer source_index;source_index=-1;
     for(int ph=0;ph<2;ph++)if(araddr[p]>=cmd_base[ph][p]&&araddr[p]+64*(arlen[p]+1)<=cmd_base[ph][p]+cmd_span[ph][p])begin if(source_index>=0)$fatal(1,"ambiguous fixture address source");source_index=ph;end
     if(live[p][arid[p]]||arlen[p]>15||araddr[p][5:0]!=0||{1'b0,araddr[p][11:0]}+64*(arlen[p]+1)>4096||source_index<0||source_index!=matrix_phase)$fatal(1,"real AXI ID/page/span/source");
     bphase[p][arid[p]]<=source_index;bbase[p][arid[p]]<=cmd_base[source_index][p];
     live[p][arid[p]]<=1;baddr[p][arid[p]]<=araddr[p];bsize[p][arid[p]]<=arlen[p]+1;bpos[p][arid[p]]<=0;eligible[p][arid[p]]<=cycle+40+2*(7-arid[p]);ar_count=ar_count+1;
    end
    if(rvalid[p]&&rready[p])begin if(bpos[p][rid[p]]+1==bsize[p][rid[p]])live[p][rid[p]]<=0;else bpos[p][rid[p]]<=bpos[p][rid[p]]+1;rotate[p]<=(rid[p]+1)%8;r_count=r_count+1;end
   end
   if(dut.matrix.core.trace_issue)begin
    integer ss,seq,idx;ss=dut.matrix.core.trace_block_s;seq=dut.matrix.core.trace_issue_seq;
    if(ss>=(matrix_phase?16:48)||seq!=issues[matrix_phase][ss])$fatal(1,"real core issue order");if(last_issue[matrix_phase][ss]>=0&&cycle-last_issue[matrix_phase][ss]!=1)$fatal(1,"continuous K issue");if(first_issue[matrix_phase][ss]<0)first_issue[matrix_phase][ss]=cycle;last_issue[matrix_phase][ss]=cycle;issues[matrix_phase][ss]=issues[matrix_phase][ss]+1;
    issue_time[seq%64]=cycle;issue_seq[seq%64]=seq;issue_owned[seq%64]=1;ps_owned[seq%64]=0;
    if(seq%8==0)begin idx=9*(ss*32+seq/32);for(integer a=0;a<8;a++)expected_w[512*a+:512]=word((seq%32)/8,idx+a);temp=word((seq%32)/8,idx+8);expected_w[4096+:256]=temp[255:0];if({dut.matrix.core.trace_w_scale,dut.matrix.core.trace_w_q}!==expected_w)$fatal(1,"actual W mapping");end
    if(ss==0&&seq%32<8)begin for(integer a=0;a<16;a++)begin begin logic [271:0] av;av=a_at(matrix_phase,(16*(seq%8)+a)*32+seq/32);expected_a[256*a+:256]=av[255:0];expected_a[4096+16*a+:16]=av[271:256];end end if({dut.matrix.core.trace_a_scale,dut.matrix.core.trace_a_q}!==expected_a)$fatal(1,"actual A mapping");end
   end
   if(dut.matrix.core.math_read_fire)begin ps_time[dut.matrix.core.ps_next[5:0]]=cycle;ps_owned[dut.matrix.core.ps_next[5:0]]=1;end
   if(dut.matrix.core.trace_commit)begin
    integer ss,seq;ss=dut.matrix.core.trace_block_s;seq=dut.matrix.core.trace_commit_seq;
    if(seq!=acks[matrix_phase][ss])$fatal(1,"real commit order");acks[matrix_phase][ss]=acks[matrix_phase][ss]+1;
    if(seq>=992&&dut.matrix.core.trace_commit_data!==(matrix_phase?wo_prebias[32*ss+seq-992]:prebias[32*ss+seq-992]))$fatal(1,"independent prebias ss%0d seq%0d",ss,seq);
   end
   if(dut.matrix.core.state==2&&dut.matrix.core.normal_write_ack)begin
    integer ix;ix=dut.matrix.core.ps_wr_rsp_tag[5:0];if(!issue_owned[ix]||issue_seq[ix]!=dut.matrix.core.ps_wr_rsp_tag[12:0]||cycle-issue_time[ix]>64)$fatal(1,"passive issue/PSack64");if(cycle-issue_time[ix]>max_issue_ack)max_issue_ack=cycle-issue_time[ix];
    if(ps_owned[ix])begin if(cycle-ps_time[ix]>24)$fatal(1,"passive PSfeedback24");if(cycle-ps_time[ix]>max_ps_feedback)max_ps_feedback=cycle-ps_time[ix];end issue_owned[ix]=0;
   end
   if(dut.l_qkv_wr_valid&&dut.l_qkv_wr_ready)begin
    integer ss,off,col;ss=qkv_count/256;off=qkv_count%256;col=ss*64+32*(off%2);
    if(dut.l_qkv_wr_token!=off/2||dut.l_qkv_wr_plane!=col/1024||dut.l_qkv_wr_head!=(col%1024)/64||dut.l_qkv_wr_half!=(col%64)/32||dut.l_qkv_wr_data!==gold[qkv_count]||dut.l_qkv_wr_request_id!=cmd_request||dut.l_qkv_wr_generation!=cmd_generation||dut.l_qkv_wr_epoch!=cmd_epoch)$fatal(1,"actual public QKV mapping/value index%0d",qkv_count);
    for(int c=0;c<32;c++)if(dut.l_qkv_wr_data[c]!==qkvgold[(off/2)*3072+col+c])$fatal(1,"independent Attention preQKV source mismatch");
    if(!(dut.r_res_qkv_wr_valid&&dut.r_res_qkv_wr_ready)||dut.r_res_qkv_wr_data!==dut.l_qkv_wr_data)$fatal(1,"resource QKV path masked by phase1 math owner");
    if(acks[matrix_phase][ss]!=1024||dut.l_start_valid||layer_starts!=0)$fatal(1,"public QKV before math commit or premature layer start");
    qkv_count=qkv_count+1;retired[matrix_phase][ss]=retired[matrix_phase][ss]+1;checked(32,"QKV_PUBLIC");
    if(qkv_count==12288)begin qkv_last_cycle=cycle;$display("M007_PARENT_QKV_ALL_END cycle=%0d values=393216",cycle);$fflush();end
    if(retired[matrix_phase][ss]==256)begin $display("MATRIX_PROGRESS parent_QKV_retired_s=%0d groups=%0d cycle=%0d",ss,qkv_count,cycle);$fflush();end
   end
   if(dut.r_res_fp_protocol_fault||dut.r_res_div_protocol_fault||dut.l_check_coverage_fault)$fatal(1,"parent actual shared protocol fault");
   if(done_valid&&mode==0&&normal_started)begin
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
   end
   if(cycle>40000000)$fatal(1,"parent40Mcycle watchdog");
  end
 end
 always @(posedge clk)if(rst_n&&parent_state==7)begin
  if(dut.layer.rope_wr_commit_valid)begin
   for(int c=0;c<64;c++)if(dut.layer.rope_wr_q[c]!==postgold[(dut.layer.rope_wr_token*3*16+dut.layer.rope_wr_head)*64+c]||dut.layer.rope_wr_k[c]!==postgold[((dut.layer.rope_wr_token*3+1)*16+dut.layer.rope_wr_head)*64+c])$fatal(1,"parent real RoPE data");nrope=nrope+1;checked(128,"ROPE");
   if(nrope%512==0)begin $display("MATRIX_PROGRESS parent_RoPE_commits=%0d cycle=%0d",nrope,cycle);$fflush();end
  end
  if(dut.layer.h_start_valid&&dut.layer.h_start_ready)begin head_start_cycle=cycle;$display("M007_PARENT_HEAD_BEGIN head=%0d cycle=%0d",dut.layer.active_head,cycle);$fflush();end
  if(dut.l_res_fp_rsp_phase==2&&dut.l_res_st_ps_wr_valid&&dut.l_res_st_ps_wr_ready)begin
   int group,key;group=int'(dut.l_res_st_ps_wr_tag[11:7]);key=int'(dut.l_res_st_ps_wr_tag[6:0]);
   for(int q=0;q<4;q++)begin int r,b;r=group*4+q;b=(key/64)*512+(r%16)*32+key%32;if(dut.l_res_st_ps_wr_data[b]!==scoregold[(int'(dut.layer.active_head)*128+r)*128+key])$fatal(1,"parent real score");nscore=nscore+1;head_score[dut.layer.active_head]=head_score[dut.layer.active_head]+1;checked(1,"SCORE");end
   if(nscore%4096==0)begin $display("MATRIX_PROGRESS parent_score_words=%0d cycle=%0d",nscore,cycle);$fflush();end
  end
  if(dut.layer.state==7&&dut.layer.h_check_qk_done&&!max_checked[dut.layer.active_head])begin for(int r=0;r<128;r++)if(dut.layer.h_maximum[r]!==maxgold[int'(dut.layer.active_head)*128+r])$fatal(1,"parent real maximum");max_checked[dut.layer.active_head]=1;head_maximum[dut.layer.active_head]=128;checked(128,"MAXIMUM");end
  if(dut.layer.head.sm_prob_wr_valid&&dut.layer.head.sm_prob_wr_ready)begin
   int r,k;r=int'(dut.layer.head.sm_prob_wr_tag[10:4]);k=int'(dut.layer.head.sm_prob_wr_tag[3:0])*8;
   for(int c=0;c<8;c++)begin if(dut.layer.head.sm_prob_wr_data[c]!==probgold[(int'(dut.layer.active_head)*128+r)*128+k+c])$fatal(1,"parent real probability");nprob=nprob+1;head_prob[dut.layer.active_head]=head_prob[dut.layer.active_head]+1;checked(1,"PROB");end
  end
  if(dut.layer.head.sm_prob_wr_ack_valid&&dut.layer.head.sm_prob_wr_ack_ready)begin nprob_ack=nprob_ack+1;head_prob_ack[dut.layer.active_head]=head_prob_ack[dut.layer.active_head]+1;if(nprob_ack%512==0)begin $display("MATRIX_PROGRESS parent_prob_ack=%0d cycle=%0d",nprob_ack,cycle);$fflush();end end
  if(dut.l_res_st_context_wr_valid&&dut.l_res_st_context_wr_ready)for(int c=0;c<64;c++)if(dut.l_res_st_context_wr_mask[c])begin
   int h,r;h=int'(dut.l_res_st_context_wr_addr[c][10:7]);r=int'(dut.l_res_st_context_wr_addr[c][6:0]);if(dut.l_res_st_context_wr_data[c]!==contextgold[(h*128+r)*64+c])$fatal(1,"parent real context");ncontext=ncontext+1;head_context[dut.layer.active_head]=head_context[dut.layer.active_head]+1;checked(1,"CONTEXT");
  end
  if(dut.layer.h_done_valid&&dut.layer.h_done_ready)begin
   if(dut.layer.h_done_status!=0||dut.layer.h_done_cycles>11648||head_score[dut.layer.active_head]!=16384||head_prob[dut.layer.active_head]!=16384||head_context[dut.layer.active_head]!=8192||head_prob_ack[dut.layer.active_head]!=2048||head_maximum[dut.layer.active_head]!=128||!max_checked[dut.layer.active_head]||nrope!=2048||qkv_count!=12288||layer_starts!=1||dut.layer.active_head!=nheads||dut.layer.h_done_request_id!=cmd_request||dut.layer.h_done_generation!=cmd_generation||dut.layer.h_done_head!=nheads)$fatal(1,"parent per-head numeric/maximum/event/identity/cycle coverage");
   $display("M007_PARENT_HEAD_END head=%0d cycle=%0d head_cycles=%0d",dut.layer.active_head,cycle,dut.layer.h_done_cycles);$fflush();nheads=nheads+1;
   if(stop_after_head>0&&nheads==stop_after_head)begin
    if(done_valid||matrix_accepts!=1||ctx_reads!=0||wo_outputs!=0)$fatal(1,"head pilot must remain unfinished actual parent");
    $display("M007_PARENT_TWO_HEAD_PASS heads=%0d QKV32=%0d score=%0d prob=%0d context=%0d maxima=%0d elapsed=%0d",nheads,qkv_count,nscore,nprob,ncontext,128*nheads,cycle-command_cycle);$display("HARDWARE_AGENT_SIM_PASS M007_PARENT_TWO_HEAD");$fflush();$finish;
   end
  end
 end
 always @(negedge clk)if(rst_n&&normal_started)begin
  if(parent_state==12&&wo_outputs==128&&!wo_mid_done)begin out_ready=0;if(wo_mid_hold>=8)begin out_ready=1;wo_mid_done=1;end end
  else if(parent_state==12&&wo_outputs==4095&&!wo_last_done)begin out_ready=0;if(wo_last_hold>=12)begin out_ready=1;wo_last_done=1;end end
  else out_ready=1;
 end
 task automatic invalid_identity(input int field);
  logic [127:0] saved;logic [242:0] held;
  begin
   mode=1;
   case(field)0:begin saved=cmd_model_id;cmd_model_id[127]=!cmd_model_id[127];end 1:begin saved=cmd_numeric_id;cmd_numeric_id[127]=!cmd_numeric_id[127];end 2:begin saved=cmd_table_key;cmd_table_key[127]=!cmd_table_key[127];end 3:begin saved=cmd_graph_id;cmd_graph_id[127]=!cmd_graph_id[127];end 4:begin saved=cmd_layout_id;cmd_layout_id[127]=!cmd_layout_id[127];end 5:begin saved=cmd_build_id;cmd_build_id[127]=!cmd_build_id[127];end 6:cmd_tensor[0]=5;7:cmd_tensor[1]=33;endcase
   send_command();wait(done_valid);@(negedge clk);
   held={done_status,source_status,error_domain,error_tuple,done_request,done_generation,done_epoch};
   repeat(5)begin step();if(!done_valid||{done_status,source_status,error_domain,error_tuple,done_request,done_generation,done_epoch}!==held||done_status!=4||layer_prepares!=0||qkv_count!=0||awrites!=0||ar_count!=0)$fatal(1,"full source identity/tensor rejected without work and held243bit response");end
   @(negedge clk);done_ready=1;step();@(negedge clk);done_ready=0;wait(cmd_ready);
   case(field)0:cmd_model_id=saved;1:cmd_numeric_id=saved;2:cmd_table_key=saved;3:cmd_graph_id=saved;4:cmd_layout_id=saved;5:cmd_build_id=saved;6:cmd_tensor[0]=4;7:cmd_tensor[1]=32;endcase
   $display("M007_PARENT_IDENTITY_REJECT_PASS field=%0d highhalf_or_crosslayer_key=1 actual_work=0 held_response_bits=243 held_cycles=5",field);mode=0;
  end
 endtask
 task automatic send_command;
  begin @(negedge clk);cmd_valid=1;do @(posedge clk);while(!cmd_ready);@(negedge clk);cmd_valid=0;end
 endtask
 initial begin
  clk='0;
  rst_n='0;
  cmd_valid='0;
  cmd_request='0;
  cmd_generation='0;
  cmd_epoch='0;
  cmd_model_id='0;
  cmd_numeric_id='0;
  cmd_table_key='0;
  cmd_graph_id='0;
  cmd_layout_id='0;
  cmd_build_id='0;
  cmd_kind='0;
  cmd_layer='0;
  cmd_mask='0;
  cmd_tensor='0;
  cmd_base='0;
  cmd_span='0;
  in_valid='0;
  in_data='0;
  in_request='0;
  in_generation='0;
  in_epoch='0;
  in_row='0;
  in_group='0;
  producer_fail_valid='0;
  producer_fail_tuple='0;
  producer_fail_request='0;
  producer_fail_generation='0;
  producer_fail_epoch='0;
  out_ready='0;
  done_ready='0;
  bias_model_id='0;
  bias_numeric_id='0;
  coeff_bind_valid='0;
  coeff_bind_model_id='0;
  coeff_bind_numeric_id='0;
  coeff_bind_table_key='0;
  coeff_wr_valid='0;
  coeff_wr_model_id='0;
  coeff_wr_numeric_id='0;
  coeff_wr_table_key='0;
  coeff_wr_table='0;
  coeff_wr_row='0;
  coeff_wr_half='0;
  coeff_wr_data='0;
  coef_cfg_valid='0;
  coef_model='0;
  coef_request='0;
  coef_tensor='0;
  coef_generation='0;
  coef_epoch='0;
  coef_n='0;
  coef_wr_valid='0;
  coef_wr_addr='0;
  coef_wr_data='0;
  coef_rsp_ready='0;
  rvalid='0;
  rid='0;
  rdata='0;
  rresp='0;
  rlast='0;

  if(!$value$plusargs("MATRIX=%s",matrix_fixture))$fatal(1,"MATRIX required");if(!$value$plusargs("INPUT=%s",input_fixture))$fatal(1,"INPUT required");if(!$value$plusargs("ATTENTION=%s",attention_fixture))$fatal(1,"ATTENTION required");if(!$value$plusargs("PREFIX=%d",prefix))prefix=0;
  if(!$value$plusargs("STOP_AFTER_HEAD=%d",stop_after_head))stop_after_head=0;
  if(stop_after_head!=0&&stop_after_head!=2)$fatal(1,"only actual second-head pilot or full endpoint allowed");
  if(!$value$plusargs("CONTEXT=%s",context_fixture))$fatal(1,"original WO fixture required");
  $readmemh({context_fixture,"/wo_0_weight/output.hex"},wo_gold);$readmemh({context_fixture,"/wo_0_weight/input.hex"},wo_inputs);$readmemh({context_fixture,"/wo_0_weight/a_write.hex"},wo_agold);$readmemh({context_fixture,"/wo_0_weight/pre_bias.hex"},wo_prebias);
  $readmemh({context_fixture,"/wo_0_weight/p0.hex"},wo_mem0);$readmemh({context_fixture,"/wo_0_weight/p1.hex"},wo_mem1);$readmemh({context_fixture,"/wo_0_weight/p2.hex"},wo_mem2);$readmemh({context_fixture,"/wo_0_weight/p3.hex"},wo_mem3);
  for(int ph=0;ph<2;ph++)begin quant_returns[ph]=0;fill_writes[ph]=0;fill_acks[ph]=0;publications[ph]=0;end
  for(int h=0;h<16;h++)begin head_score[h]=0;head_prob[h]=0;head_context[h]=0;head_prob_ack[h]=0;head_maximum[h]=0;end
  for(int i=0;i<7;i++)dispatch[i]=-1;
  $readmemh({matrix_fixture,"/qkv_0_weight/output.hex"},gold);$readmemh({matrix_fixture,"/qkv_0_weight/pre_bias.hex"},prebias);$readmemh({matrix_fixture,"/qkv_0_weight/a_write.hex"},agold);
  $readmemh({input_fixture,"/qkv_0_weight/input.hex"},inputs);
  $readmemh({matrix_fixture,"/qkv_0_weight/p0.hex"},mem0);$readmemh({matrix_fixture,"/qkv_0_weight/p1.hex"},mem1);$readmemh({matrix_fixture,"/qkv_0_weight/p2.hex"},mem2);$readmemh({matrix_fixture,"/qkv_0_weight/p3.hex"},mem3);
  $readmemh({attention_fixture,"/cos_full.mem"},cf);$readmemh({attention_fixture,"/sin_full.mem"},sf);$readmemh({attention_fixture,"/mask.mem"},maskmem);$readmemh({attention_fixture,"/encoder0_pre_qkv.mem"},qkvgold);
  $readmemh({attention_fixture,"/encoder0_post_qkv.mem"},postgold);$readmemh({attention_fixture,"/encoder0_score.mem"},scoregold);$readmemh({attention_fixture,"/encoder0_maximum.mem"},maxgold);$readmemh({attention_fixture,"/encoder0_prob.mem"},probgold);$readmemh({attention_fixture,"/encoder0_context.mem"},contextgold);
  for(int pp=0;pp<2;pp++)for(int ss=0;ss<48;ss++)begin issues[pp][ss]=0;acks[pp][ss]=0;retired[pp][ss]=0;first_issue[pp][ss]=-1;last_issue[pp][ss]=-1;end
  cmd_request=77;cmd_generation=8;cmd_epoch=9;cmd_model_id=128'h6eb6ef58bc4f99bd9db40381604108af;cmd_numeric_id=128'haeb13e7937d29fe6a2c68c407249f294;cmd_table_key=128'hb1fdc9ca482c0210982c7245cc50c965;cmd_graph_id=128'hf33f7848434b73048f957dcd232e1bd4;cmd_layout_id=128'h2d848b5fb78236c795cb1d442f088393;cmd_build_id=128'h7209eb09c3f265363cfb274f7790a733;cmd_kind=0;cmd_layer=0;cmd_tensor[0]=4;cmd_tensor[1]=32;
  for(int r=0;r<128;r++)cmd_mask[r]=maskmem[r][0];
  for(int p=0;p<4;p++)begin cmd_base[0][p]=64'h100000000+64'h10000000*p;cmd_span[0][p]=884736;cmd_base[1][p]=64'h200000000+64'h10000000*p;cmd_span[1][p]=294912;end
  coeff_bind_model_id=cmd_model_id;coeff_bind_numeric_id=cmd_numeric_id;coeff_bind_table_key=cmd_table_key;coeff_wr_model_id=cmd_model_id;coeff_wr_numeric_id=cmd_numeric_id;coeff_wr_table_key=cmd_table_key;
  bias_model_id=cmd_model_id;bias_numeric_id=cmd_numeric_id;out_ready=1;
  repeat(4)step();@(negedge clk);rst_n=1;coeff_bind_valid=1;do @(posedge clk);while(!coeff_bind_ready);@(negedge clk);coeff_bind_valid=0;
  for(int t=0;t<2;t++)for(int r=0;r<128;r++)for(int half=0;half<2;half++)begin
   coeff_wr_valid=1;coeff_wr_table=t;coeff_wr_row=r;coeff_wr_half=half;for(int c=0;c<32;c++)coeff_wr_data[c]=t?sf[r*64+half*32+c]:cf[r*64+half*32+c];#0.1;if(!coeff_wr_ready||coeff_wr_reject_valid)$fatal(1,"real original coefficient loader");@(posedge clk);@(negedge clk);
  end coeff_wr_valid=0;
  for(int field=0;field<8;field++)invalid_identity(field);
  send_command();
  for(int g=0;g<4096;g++)begin in_valid=1;in_request=cmd_request;in_generation=cmd_generation;in_epoch=cmd_epoch;in_row=g/32;in_group=g%32;in_data=inputs[g];do @(posedge clk);while(!in_ready);@(negedge clk);end in_valid=0;
  if(prefix>0)begin
   wait(qkv_count==prefix*256);@(negedge clk);
   if(done_valid||layer_starts!=0||layer_prepares!=1||matrix_accepts!=1||input_count!=4096||awrites!=4096||aacks!=4096||parent_state!=5)$fatal(1,"prefix must remain actual unfinished parent");
   for(int ss=0;ss<prefix;ss++)if(issues[matrix_phase][ss]!=1024||acks[matrix_phase][ss]!=1024||retired[matrix_phase][ss]!=256||last_issue[matrix_phase][ss]-first_issue[matrix_phase][ss]+1!=1024)$fatal(1,"prefix actual block coverage");
   $display("M007_PARENT_QKV_PREFIX_PASS blocks=%0d final_values=%0d public_QKV32_writes=%0d inputs=%0d Awrites=%0d Aacks=%0d elapsed=%0d actual_issue_ack=%0d actual_PS_feedback=%0d unfinished_parent=1",prefix,prefix*8192,qkv_count,input_count,awrites,aacks,cycle-command_cycle,max_issue_ack,max_ps_feedback);
   $display("HARDWARE_AGENT_SIM_PASS M007_PARENT_QKV_PREFIX");$fflush();$finish;
  end
  wait(done_valid);@(negedge clk);
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
  $display("HARDWARE_AGENT_SIM_PASS M007_PARENT_FULL");$fflush();$finish;
 end
endmodule
