`timescale 1ns/1ps
module m007_ffn_parent_tb;
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
 logic[1023:0]norm_input[0:4095],wi_gold[0:20991],down_gold[0:4095];
 logic[271:0]norm_a[0:4095],g_a[0:10495];
 logic[383:0]vectors[0:335871];
 logic[511:0]wi_mem0[0:23615],wi_mem1[0:23615],wi_mem2[0:23615],wi_mem3[0:23615];
 logic[511:0]down_mem0[0:11807],down_mem1[0:11807],down_mem2[0:11807],down_mem3[0:11807];
 logic[7:0]live[0:3];logic[63:0]baddr[0:3][0:7],bbase[0:3][0:7];logic bphase[0:3][0:7];
 integer bsize[0:3][0:7],bpos[0:3][0:7],eligible[0:3][0:7],rotate[0:3];logic[3:0]last_r_fire;
 integer cycle=0,command_cycle=-1,old_state=-1,stop_blocks=3,matrix_phase=0,qphase=0,commands=0,mcommands=0,gcommands=0;
 integer input_count=0,quant_returns[0:1],awrites[0:1],aacks[0:1],publications[0:1],wi_outputs=0,down_outputs=0,g_outputs=0,node_checks=0,g_writes=0,g_acks=0,g_reads=0,g_releases=0;
 integer wi_done=0,g_done=0,down_done=0,parent_retired=0,checked_words=0,last_checked=0;
 integer issues[0:1][0:81],commits[0:1][0:81],outputs[0:1][0:81],first_issue[0:1][0:81],last_issue[0:1][0:81];
 integer g_ready_cycle[0:81],g_eligible_cycle[0:81],g_first_read[0:81],g_last_read[0:81],g_first_consume[0:81],g_last_consume[0:81],g_read_count[0:81],g_output_count[0:81],g_release_cycle[0:81];
 integer g_cmd_cycle=-1,m_start_cycle[0:1],m_first_out[0:1],m_done_cycle[0:1],g_tail_start=-1;
 integer issue_time[0:63],ps_time[0:63],issue_seq[0:63],max_issue_ack=0,max_ps_feedback=0;logic[63:0]issue_owned,ps_owned;
 logic[4351:0]expected_w,expected_a;logic[511:0]temp;logic[242:0]expected_done;
 integer mid_held=0,last_held=0,mid_hold_left=0,last_hold_left=0;logic mid_started=0,last_started=0,holding=0;logic[1046:0]held_out;
 string fixture,wi_weights,down_weights,g_fixture;
 task automatic step;begin @(posedge clk);#0.1;end endtask
 task automatic checked(input int n);
  checked_words+=n;
  if(checked_words-last_checked>=4096)begin $display("M007_PARENT_CHECKED checked=%0d phase=FFN cycle=%0d",checked_words,cycle);$fflush();last_checked=checked_words;end
 endtask
 function automatic logic[511:0] word_at(input int phase,p,idx);
  if(phase)case(p)0:return down_mem0[idx];1:return down_mem1[idx];2:return down_mem2[idx];default:return down_mem3[idx];endcase
  else case(p)0:return wi_mem0[idx];1:return wi_mem1[idx];2:return wi_mem2[idx];default:return wi_mem3[idx];endcase
 endfunction
 function automatic logic[271:0] a_at(input int phase,row,group);
  if(phase)return g_a[row*82+group];else return norm_a[row*32+group];
 endfunction
 function automatic logic[1023:0] m_at(input int phase,idx);if(phase)return down_gold[idx];else return wi_gold[idx];endfunction
 always_comb arready=15;
 always @(negedge clk)begin
  if(!rst_n)begin rvalid=0;rid=0;rdata=0;rresp=0;rlast=0;end
  else for(int p=0;p<4;p++)if(!rvalid[p]||last_r_fire[p])begin
   int pick;pick=-1;for(int q=7;q>=0;q--)if(live[p][(rotate[p]+q)%8]&&cycle>=eligible[p][(rotate[p]+q)%8])pick=(rotate[p]+q)%8;
   rvalid[p]=0;
   if(pick>=0&&cycle%2==0)begin rvalid[p]=1;rid[p]=pick;rdata[p]=word_at(bphase[p][pick],p,((baddr[p][pick]-bbase[p][pick])>>6)+bpos[p][pick]);rlast[p]=bpos[p][pick]+1==bsize[p][pick];rresp[p]=0;end
  end
  if(rst_n)begin
   out_ready=1;
   if(out_valid&&down_outputs==100&&!mid_started)begin mid_started=1;mid_hold_left=8;end
   if(out_valid&&down_outputs==4095&&!last_started)begin last_started=1;last_hold_left=17;end
   if(mid_hold_left>0)begin out_ready=0;mid_hold_left--;mid_held++;end
   if(last_hold_left>0)begin out_ready=0;last_hold_left--;last_held++;end
  end
 end
 always @(posedge clk)begin
  cycle++;last_r_fire<=rvalid&rready;
  if(!rst_n)begin issue_owned=0;ps_owned=0;for(int p=0;p<4;p++)begin live[p]<=0;rotate[p]<=0;end end
  else begin
   if(cycle==30&&parent_state==20)$fatal(1,"initial safe workspace switch blocked a_retired=%b g_private_idle=%b real_idle=%b l_st_idle=%b",dut.layer.a_retired,dut.layer.g_private_idle,dut.layer.layer.real_idle,dut.l_res_st_idle);
   if(parent_state!=old_state)begin $display("M007_FFN_STATE state=%0d cycle=%0d wi=%0d G=%0d Down=%0d",parent_state,cycle,wi_outputs,g_outputs,down_outputs);$fflush();old_state=parent_state;end
   if(cmd_valid&&cmd_ready)begin commands++;command_cycle=cycle;expected_done={8'd0,8'd0,3'd0,96'd0,cmd_request,cmd_generation,cmd_epoch};if(commands!=1)$fatal(1,"only one parent command");end
   if(in_valid&&in_ready)input_count++;
   if(dut.l_prepare_valid||dut.l_start_valid)$fatal(1,"kind3 may not fake Attention prepare/start");
   if(dut.q_cmd_valid&&dut.q_cmd_ready)begin qphase=dut.q_cmd_k==2624;$display("M007_FFN_QUANT_BEGIN phase=%0d cycle=%0d",qphase,cycle);$fflush();end
   if(dut.q_awr_valid&&dut.q_awr_ready)begin
    if(dut.q_awr_data!==a_at(qphase,dut.q_awr_row,dut.q_awr_group))$fatal(1,"Q8/A independent bits phase=%0d row=%0d group=%0d",qphase,dut.q_awr_row,dut.q_awr_group);
    awrites[qphase]++;checked(32);
   end
   if(dut.q_awr_rsp_valid&&dut.q_awr_rsp_ready)begin aacks[qphase]++;if(qphase&&aacks[1]%128==0)begin $display("M007_FFN_Q8_ACK groups=%0d cycle=%0d",aacks[1],cycle);$fflush();end end
   if(dut.front.q_out_valid&&dut.front.q_out_ready)quant_returns[qphase]++;
   if(dut.q_acfg_rsp_valid&&dut.q_acfg_rsp_ready)begin
    if(dut.q_acfg_status!=0||awrites[qphase]!=(qphase?10496:4096)||aacks[qphase]!=(qphase?10496:4096))$fatal(1,"premature/failed real A publication");publications[qphase]++;
   end
   if(dut.g_cmd_valid&&dut.g_cmd_ready)begin gcommands++;g_cmd_cycle=cycle;if(gcommands!=1||!dut.ws_g_enable||!dut.r_res_fp_lease_active)$fatal(1,"real G/workspace admission");end
   if(dut.m_cmd_valid&&dut.m_cmd_ready)begin
    matrix_phase=dut.m_cmd_n==1024;mcommands++;m_start_cycle[matrix_phase]=cycle;
    if(dut.m_cmd_k!=(matrix_phase?2624:1024)||dut.m_cmd_n!=(matrix_phase?1024:5248)||dut.m_cmd_a_slot!=matrix_phase||dut.m_cmd_bias||dut.m_cmd_tensor!=cmd_tensor[matrix_phase]||dut.m_cmd_base!==cmd_base[matrix_phase]||dut.m_cmd_span!==cmd_span[matrix_phase])$fatal(1,"matrix exact descriptor/key/base/slot");
    if(input_count!=4096||publications[matrix_phase]!=1||awrites[matrix_phase]!=(matrix_phase?10496:4096)||aacks[matrix_phase]!=(matrix_phase?10496:4096)||dut.front.q_lease_active||dut.q_d_lease_active||dut.front.a_write_debt!=0)$fatal(1,"matrix before actual A/quant debt retirement");
    if(matrix_phase&&(wi_done!=1||g_done!=1||g_outputs!=41984||dut.pack_seq!=41984||dut.pack_full||!dut.g_engine_idle||dut.tanh_lease_active||!dut.r_res_st_idle||dut.r_res_fp_lease_active||dut.r_res_div_lease_active))$fatal(1,"Down before complete real success barrier");
    $display("M007_FFN_MATRIX_BEGIN phase=%0d cycle=%0d",matrix_phase,cycle);$fflush();
   end
   for(int p=0;p<4;p++)begin
    if(arvalid[p]&&arready[p])begin
     int ph;ph=-1;for(int h=0;h<2;h++)if(araddr[p]>=cmd_base[h][p]&&araddr[p]+64*(arlen[p]+1)<=cmd_base[h][p]+cmd_span[h][p])begin if(ph>=0)$fatal(1,"ambiguous W source");ph=h;end
     if(ph<0||ph!=matrix_phase||live[p][arid[p]]||arlen[p]>15||araddr[p][5:0]!=0||{1'b0,araddr[p][11:0]}+64*(arlen[p]+1)>4096)$fatal(1,"AXI source/ID/page/span");
     bphase[p][arid[p]]<=ph;bbase[p][arid[p]]<=cmd_base[ph][p];live[p][arid[p]]<=1;baddr[p][arid[p]]<=araddr[p];bsize[p][arid[p]]<=arlen[p]+1;bpos[p][arid[p]]<=0;eligible[p][arid[p]]<=cycle+40+2*(7-arid[p]);
    end
    if(rvalid[p]&&rready[p])begin if(bpos[p][rid[p]]+1==bsize[p][rid[p]])live[p][rid[p]]<=0;else bpos[p][rid[p]]<=bpos[p][rid[p]]+1;rotate[p]<=(rid[p]+1)%8;end
   end
   if(dut.matrix.core.trace_issue)begin
    int ss,seq,idx,groups;ss=dut.matrix.core.trace_block_s;seq=dut.matrix.core.trace_issue_seq;groups=matrix_phase?82:32;
    if(ss>=(matrix_phase?16:82)||seq!=issues[matrix_phase][ss])$fatal(1,"real matrix issue order");
    if(last_issue[matrix_phase][ss]>=0&&cycle-last_issue[matrix_phase][ss]!=1)$fatal(1,"continuous K issue");
    if(first_issue[matrix_phase][ss]<0)first_issue[matrix_phase][ss]=cycle;last_issue[matrix_phase][ss]=cycle;issues[matrix_phase][ss]++;
    issue_time[seq%64]=cycle;issue_seq[seq%64]=seq;issue_owned[seq%64]=1;ps_owned[seq%64]=0;
    if(seq%8==0)begin idx=9*(ss*groups+seq/32);for(int a=0;a<8;a++)expected_w[512*a+:512]=word_at(matrix_phase,(seq%32)/8,idx+a);temp=word_at(matrix_phase,(seq%32)/8,idx+8);expected_w[4096+:256]=temp[255:0];if({dut.matrix.core.trace_w_scale,dut.matrix.core.trace_w_q}!==expected_w)$fatal(1,"actual W mapping");end
    if(ss==0&&seq%32<8)begin for(int a=0;a<16;a++)begin logic[271:0]av;av=a_at(matrix_phase,16*(seq%8)+a,seq/32);expected_a[256*a+:256]=av[255:0];expected_a[4096+16*a+:16]=av[271:256];end if({dut.matrix.core.trace_a_scale,dut.matrix.core.trace_a_q}!==expected_a)$fatal(1,"actual A mapping");end
   end
   if(dut.matrix.core.math_read_fire)begin ps_time[dut.matrix.core.ps_next[5:0]]=cycle;ps_owned[dut.matrix.core.ps_next[5:0]]=1;end
   if(dut.matrix.core.state==2&&dut.matrix.core.normal_write_ack)begin
    int ix;ix=dut.matrix.core.ps_wr_rsp_tag[5:0];
    if(ps_owned[ix])begin if(cycle-ps_time[ix]>24)$fatal(1,"actual PS feedback cap24");if(cycle-ps_time[ix]>max_ps_feedback)max_ps_feedback=cycle-ps_time[ix];end
   end
   if(dut.matrix.core.trace_commit)begin
    int ss,seq,k;ss=dut.matrix.core.trace_block_s;seq=dut.matrix.core.trace_commit_seq;k=matrix_phase?2624:1024;
    if(seq!=commits[matrix_phase][ss]||!issue_owned[seq%64]||issue_seq[seq%64]!=seq)$fatal(1,"real issue/ACK ownership");
    if(cycle-issue_time[seq%64]>max_issue_ack)max_issue_ack=cycle-issue_time[seq%64];if(cycle-issue_time[seq%64]>48)$fatal(1,"issue ACK cap48");commits[matrix_phase][ss]++;
    if(seq>=k-32)for(int m=0;m<16;m++)for(int n=0;n<16;n++)begin logic[1023:0]ev;int rr,pp;rr=16*(seq%8)+m;pp=(seq%32)/8;ev=m_at(matrix_phase,ss*256+2*rr+pp/2);if(dut.matrix.core.trace_commit_data[16*m+n]!==ev[32*(16*(pp%2)+n)+:32])$fatal(1,"independent final prebias ACK");end
   end
   if(dut.m_out_valid&&dut.m_out_ready)begin
    int count;logic[1023:0]ev;count=matrix_phase?down_outputs:wi_outputs;ev=m_at(matrix_phase,count);
    if(dut.m_out_data!==ev||dut.m_out_s!=count/256||dut.m_out_row!=(count%256)/2||dut.m_out_col!=(matrix_phase?(64*(count/256)+32*(count%2)):(32*(count/256)+2624*(count%2))))$fatal(1,"real matrix output native bits/coords phase=%0d count=%0d",matrix_phase,count);
    if(m_first_out[matrix_phase]<0)m_first_out[matrix_phase]=cycle;outputs[matrix_phase][count/256]++;if(matrix_phase)down_outputs++;else wi_outputs++;checked(32);
    if(!matrix_phase&&count==20991)g_tail_start=cycle;
    if(count%256==255)begin $display("M007_FFN_MATRIX_BLOCK phase=%0d s=%0d cycle=%0d values=%0d",matrix_phase,count/256,cycle,(count+1)*32);$fflush();end
   end
   if(dut.g_g_wr_valid&&dut.g_g_wr_ready)g_writes++;
   if(dut.g_g_wr_rsp_valid&&dut.g_g_wr_rsp_ready)begin g_acks++;if(dut.g_g_wr_rsp_tag[1]&&dut.g_g_wr_rsp_tag[8:2]==127)g_ready_cycle[dut.g_g_wr_rsp_tag[15:9]]=cycle;end
   if(dut.g_g_rd_valid&&dut.g_g_rd_ready)begin
    int ss;ss=dut.g_g_rd_tag[15:9];if(g_read_count[ss]==0)g_first_read[ss]=cycle;else if(cycle-g_last_read[ss]!=1)$fatal(1,"G in-block read II1");g_last_read[ss]=cycle;g_read_count[ss]++;g_reads++;
   end
   for(int ss=0;ss<82;ss++)if(g_eligible_cycle[ss]<0&&g_ready_cycle[ss]>=0)begin
    if(ss==0&&g_cmd_cycle>=0)g_eligible_cycle[ss]=g_ready_cycle[ss]>g_cmd_cycle?g_ready_cycle[ss]:g_cmd_cycle;
    else if(ss>0&&g_read_count[ss-1]==512)g_eligible_cycle[ss]=g_ready_cycle[ss]>g_last_read[ss-1]+1?g_ready_cycle[ss]:g_last_read[ss-1]+1;
   end
   if(dut.layer.g_engine.pair_release_valid&&dut.layer.g_engine.pair_release_ready)begin
    int ss;ss=dut.layer.g_engine.pair_release_s;g_releases++;g_release_cycle[ss]=cycle;
    if(g_output_count[ss]!=512||g_read_count[ss]!=512||g_first_read[ss]<g_eligible_cycle[ss]||g_first_read[ss]>g_eligible_cycle[ss]+1||g_first_consume[ss]-g_eligible_cycle[ss]>256||cycle-g_eligible_cycle[ss]>768)$fatal(1,"real G eligible/block service cap s=%0d",ss);
   end
   for(int n=0;n<9;n++)if(dut.g_fp_rsp_valid[n])begin
    int gw,vi,si;gw=n==0?2:n==1?3:n==2?4:n==3?5:n==4?6:n==5?8:n==6?9:n==7?10:11;vi=int'(dut.g_fp_rsp_tag[n][15:0]);
    for(int l=0;l<8;l++)begin si=((vi%512)/4)*2624+(vi/512)*32+(vi%4)*8+l;if(dut.g_fp_rsp_data[n][l]!==vectors[si][383-gw*32-:32]||dut.g_fp_rsp_status[n][l]!==0)$fatal(1,"original FP node n=%0d vi=%0d lane=%0d",n,vi,l);node_checks++;end
   end
   if(dut.g_sfu_rsp_valid&&dut.g_sfu_rsp_ready)begin
    int vi,si;vi=int'(dut.g_sfu_rsp_tag[15:0]);if(dut.tanh_rsp_mask!==8'hff)$fatal(1,"original TANH mask");
    for(int l=0;l<8;l++)begin si=((vi%512)/4)*2624+(vi/512)*32+(vi%4)*8+l;if(dut.g_sfu_rsp_data[l]!==vectors[si][159:128]||dut.g_sfu_rsp_status[l]!==0)$fatal(1,"original TANH H");node_checks++;end
   end
   if(dut.g_out_valid&&dut.g_out_ready)begin
    int si;logic[7:0][31:0]ev;
    for(int l=0;l<8;l++)begin si=((g_outputs%512)/4)*2624+(g_outputs/512)*32+(g_outputs%4)*8+l;ev[l]=vectors[si][31:0];end
    if(dut.g_out_tag!=={cmd_generation,cmd_epoch,16'b0,16'(g_outputs)}||dut.g_out_data!==ev||dut.g_out_status!==256'b0)$fatal(1,"real G output bits/tag/status");if(g_output_count[g_outputs/512]==0)g_first_consume[g_outputs/512]=cycle;else if(cycle-g_last_consume[g_outputs/512]!=1)$fatal(1,"G in-block output II1");g_last_consume[g_outputs/512]=cycle;g_output_count[g_outputs/512]++;g_outputs++;checked(8);
    if(g_outputs%512==0)begin $display("M007_FFN_G_BLOCK s=%0d cycle=%0d values=%0d nodes=%0d",g_outputs/512-1,cycle,g_outputs*8,node_checks);$fflush();end
   end
   if(dut.m_done_valid&&dut.m_done_ready)begin
    if(dut.m_status!=0||dut.m_done_request!=cmd_request||dut.m_done_generation!=cmd_generation||dut.m_done_epoch!=cmd_epoch)$fatal(1,"real matrix DONE identity/status");
    m_done_cycle[matrix_phase]=cycle;
    for(int ss=0;ss<(matrix_phase?16:82);ss++)if(issues[matrix_phase][ss]!=(matrix_phase?2624:1024)||commits[matrix_phase][ss]!=(matrix_phase?2624:1024)||outputs[matrix_phase][ss]!=256)$fatal(1,"full matrix issue/ACK/output coverage");
    if(matrix_phase&&cycle-m_start_cycle[1]>56576)$fatal(1,"Down matrix service cap");
    if(matrix_phase)begin down_done++;if(down_outputs!=4096)$fatal(1,"early Down done");end else begin wi_done++;if(wi_outputs!=20992)$fatal(1,"early Wi done");end
   end
   if(dut.g_done_valid&&dut.g_done_ready)begin g_done++;if(cycle-g_tail_start>1280)$fatal(1,"FFN unhidden tail cap1280");if(dut.g_done_status!=0||dut.g_done_cancelled||g_outputs!=41984||g_releases!=82||g_reads!=41984||g_writes!=20992||g_acks!=20992||node_checks!=3358720)$fatal(1,"early/failed G full DONE");end
   if(holding)begin if(!out_valid||{out_data,out_row,out_col}!==held_out)$fatal(1,"held Down stable");if(out_ready)holding=0;end
   if(out_valid&&!out_ready&&!holding)begin holding=1;held_out={out_data,out_row,out_col};end
   if(done_valid)begin
    if({done_status,source_status,error_domain,error_tuple,done_request,done_generation,done_epoch}!==expected_done||mcommands!=2||gcommands!=1||wi_done!=1||g_done!=1||down_done!=1||down_outputs!=4096||!dut.ws_a_enable||dut.ws_rearm||!dut.g_engine_idle||dut.r_res_fp_lease_active||dut.r_res_div_lease_active||!dut.r_res_st_idle)$fatal(1,"independently expected parent243bit success/full barriers");
   end
   if(done_valid&&done_ready)parent_retired++;
   if(cycle>40000000)$fatal(1,"40Mcycle cap");
  end
 end
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


  if(!$value$plusargs("FIXTURE=%s",fixture))$fatal(1,"FIXTURE required");if(!$value$plusargs("WI=%s",wi_weights))$fatal(1,"WI required");if(!$value$plusargs("DOWN=%s",down_weights))$fatal(1,"DOWN required");if(!$value$plusargs("G=%s",g_fixture))$fatal(1,"G required");if(!$value$plusargs("BLOCKS=%d",stop_blocks))stop_blocks=3;
  $readmemh({fixture,"/norm_ff_quant/source_f32_groups.hex"},norm_input);$readmemh({fixture,"/norm_ff_quant/a_write_row_major.hex"},norm_a);$readmemh({fixture,"/g_quant/a_write_row_major.hex"},g_a);$readmemh({fixture,"/wi_native_output.hex"},wi_gold);$readmemh({fixture,"/down/output.hex"},down_gold);$readmemh(g_fixture,vectors);
  $readmemh({wi_weights,"/p0.hex"},wi_mem0);$readmemh({wi_weights,"/p1.hex"},wi_mem1);$readmemh({wi_weights,"/p2.hex"},wi_mem2);$readmemh({wi_weights,"/p3.hex"},wi_mem3);
  $readmemh({down_weights,"/p0.hex"},down_mem0);$readmemh({down_weights,"/p1.hex"},down_mem1);$readmemh({down_weights,"/p2.hex"},down_mem2);$readmemh({down_weights,"/p3.hex"},down_mem3);
  for(int ss=0;ss<82;ss++)begin g_ready_cycle[ss]=-1;g_eligible_cycle[ss]=-1;g_first_read[ss]=-1;g_last_read[ss]=-1;g_first_consume[ss]=-1;g_last_consume[ss]=-1;g_read_count[ss]=0;g_output_count[ss]=0;g_release_cycle[ss]=-1;end
  for(int ph=0;ph<2;ph++)begin m_start_cycle[ph]=-1;m_first_out[ph]=-1;m_done_cycle[ph]=-1;quant_returns[ph]=0;awrites[ph]=0;aacks[ph]=0;publications[ph]=0;for(int ss=0;ss<82;ss++)begin issues[ph][ss]=0;commits[ph][ss]=0;outputs[ph][ss]=0;first_issue[ph][ss]=-1;last_issue[ph][ss]=-1;end end
  cmd_request=77;cmd_generation=8;cmd_epoch=9;cmd_model_id=128'h6eb6ef58bc4f99bd9db40381604108af;cmd_numeric_id=128'haeb13e7937d29fe6a2c68c407249f294;cmd_table_key=128'hb1fdc9ca482c0210982c7245cc50c965;cmd_graph_id=128'hf33f7848434b73048f957dcd232e1bd4;cmd_layout_id=128'h2d848b5fb78236c795cb1d442f088393;cmd_build_id=128'h7209eb09c3f265363cfb274f7790a733;cmd_kind=3;cmd_layer=0;cmd_mask='1;cmd_tensor[0]=60;cmd_tensor[1]=88;
  for(int p=0;p<4;p++)begin cmd_base[0][p]=64'h100000000+64'h10000000*p;cmd_span[0][p]=1511424;cmd_base[1][p]=64'h200000000+64'h10000000*p;cmd_span[1][p]=755712;end
  out_ready=1;repeat(4)step();@(negedge clk);rst_n=1;repeat(2)step();@(negedge clk);cmd_valid=1;do @(posedge clk);while(!cmd_ready);@(negedge clk);cmd_valid=0;
  for(int i=0;i<4096;i++)begin in_valid=1;in_request=cmd_request;in_generation=cmd_generation;in_epoch=cmd_epoch;in_row=i/32;in_group=i%32;in_data=norm_input[i];do @(posedge clk);while(!in_ready);@(negedge clk);end in_valid=0;in_request=64'hffffffffffffffff;in_generation=32'hffffffff;in_epoch=32'hffffffff;
  if(stop_blocks>0)begin
   wait(g_outputs>=stop_blocks*512&&wi_outputs>=stop_blocks*256);@(negedge clk);
   if(done_valid||mcommands!=1||gcommands!=1||publications[1]!=0||wi_done!=0||g_done!=0||down_outputs!=0||parent_state!=25)$fatal(1,"prefix must remain actual unfinished parent");
   for(int ss=0;ss<stop_blocks;ss++)if(issues[0][ss]!=1024||commits[0][ss]!=1024||outputs[0][ss]!=256)$fatal(1,"prefix actual Wi issue/ACK/output coverage");
   $display("M007_FFN_PREFIX_PASS blocks=%0d Wi_values=%0d G_values=%0d G_nodes=%0d A1_writes=%0d A1_acks=%0d cycles=%0d unfinished=1",stop_blocks,wi_outputs*32,g_outputs*8,node_checks,awrites[1],aacks[1],cycle-command_cycle);$display("HARDWARE_AGENT_SIM_PASS M007_FFN_PREFIX");$fflush();$finish;
  end
  wait(done_valid);@(negedge clk);repeat(5)begin step();if(!done_valid||{done_status,source_status,error_domain,error_tuple,done_request,done_generation,done_epoch}!==expected_done)$fatal(1,"held parent243bit expected response");end
  if(cycle-command_cycle>150016)$fatal(1,"full FFN cycle cap150016");
  if(mid_held<8||last_held<17||!mid_started||!last_started)$fatal(1,"actual finite Down held coverage");
  @(negedge clk);done_ready=1;step();@(negedge clk);done_ready=0;repeat(3)step();if(!cmd_ready||done_valid||parent_retired!=1)$fatal(1,"normal parent exactly once retired");
  $display("M007_FFN_FULL_PASS Wi_values=%0d G_values=%0d G_nodes=%0d A1_groups=%0d Down_values=%0d cycles=%0d held_mid=%0d held_last=%0d",wi_outputs*32,g_outputs*8,node_checks,awrites[1],down_outputs*32,cycle-command_cycle,mid_held,last_held);$display("HARDWARE_AGENT_SIM_PASS M007_FFN_FULL");$fflush();$finish;
 end
endmodule
