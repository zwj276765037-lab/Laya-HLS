`timescale 1ns/1ps
module m007_matrix_pure_tb #(parameter bit PROFILE_ENABLE=0);
 logic clk,rst_n;
 logic cmd_valid;logic cmd_ready;logic [31:0] cmd_version;
 logic [63:0] cmd_request,cmd_model;logic [31:0] cmd_generation,cmd_epoch,cmd_tensor;
 logic [15:0] cmd_k,cmd_n;logic cmd_a_slot,cmd_bias;
 logic [3:0][63:0] cmd_base,cmd_span;
 logic done_valid;logic done_ready;logic [2:0] status;
 logic [63:0] done_request;logic [31:0] done_generation,done_epoch;
 logic [6:0] error_row;logic [15:0] error_col;logic [7:0] error_group;logic [3:0] error_stage;
 logic out_valid;logic out_ready;logic [31:0][31:0] out_data;
 logic [6:0] out_row;logic [15:0] out_col,out_s;
 logic [63:0] out_request;logic [31:0] out_generation,out_epoch;
 logic coef_cfg_valid;logic coef_cfg_ready;logic [63:0] coef_model,coef_request;logic [31:0] coef_tensor,coef_generation,coef_epoch;logic [15:0] coef_n;
 logic coef_wr_valid;logic coef_wr_ready;logic [6:0] coef_wr_addr;logic [31:0][31:0] coef_wr_data;
 logic coef_rsp_valid;logic coef_rsp_ready;logic [1:0] coef_status;logic [15:0] coef_error_col;
 logic [3:0] arvalid;logic [3:0] arready;logic [3:0][63:0] araddr;logic [3:0][2:0] arid;logic [3:0][7:0] arlen;
 logic [3:0] rvalid;logic [3:0] rready;logic [3:0][2:0] rid;logic [3:0][511:0] rdata;logic [3:0][1:0] rresp;logic [3:0] rlast;
 logic run_enable;
 logic [31:0] elapsed_cycles,first_output_cycle,w_wait_cycles,ctx_wait_cycles;
 logic [15:0] blocks_issued,blocks_computed,blocks_retired;
 logic [31:0] ps_merged_reads,ps_response_holds,bias_add_conflicts,compute_output_overlap;
 logic [7:0] peak_return_reservations;logic [6:0] arithmetic_debt,peak_arithmetic_reservations;
 logic in_valid,in_ready;logic [31:0][31:0] in_data;logic [63:0] in_request;logic [31:0] in_generation,in_epoch;logic [7:0] in_row,in_group;
 logic input_reject_valid;logic [3:0] input_reject_code;logic [1:0] error_domain;
 logic [2:0] quant_phase;logic [6:0] quant_row,quant_group;logic [4:0] quant_element;
 logic [31:0] first_input_cycle,last_input_cycle,quant_last_cycle,a_publish_cycle,first_w_cycle,first_matrix_cycle,matrix_elapsed_cycles;
 logic [31:0] quant_accepted,quant_retired,a_writes,a_write_acks;
 laya_m007_matrix_f32_v1 #(.PROFILE_ENABLE(PROFILE_ENABLE)) dut(.*);
 always #1 clk=~clk;
 logic [1023:0] input_words[0:16383];string input_fixture;
 logic front_hold=0;integer input_count=0,write_count=0,ack_count=0,fill_configs=0,div_leases=0,matrix_commands=0,reject_count=0;
 integer div_idle_clocks=0,div_new_epoch_handoffs=0,div_last_release=-1;logic [31:0] div_previous_epoch=0;integer coefficient_load_start=-1;integer f32_accept_cycle=-1,front_quant_hold=0,front_ack_hold=0;
 logic [31:0] actual_first_core_cycle=0;
 integer observed_issue_time[0:63],observed_ps_time[0:63];
 logic [63:0] observed_issue_valid,observed_ps_valid;
 logic [63:0][12:0] observed_issue_seq;
 integer observed_max_issue_ack=0,observed_max_ps_feedback=0;

 logic [511:0] mem0[0:24575],mem1[0:24575],mem2[0:24575],mem3[0:24575];
 logic [271:0] a_words[0:16383];logic [1023:0] gold[0:20991],bias_words[0:127];logic [8191:0] pre_bias[0:2623];
 logic [7:0] live[0:3];logic [63:0] baddr[0:3][0:7];integer bsize[0:3][0:7],bpos[0:3][0:7],eligible[0:3][0:7],rotate[0:3];logic [3:0] last_r_fire;
 integer cycle=0,which=0,prefix=3,stress=0,groups=32,blocks=48,outputs=0,w_checks=0,a_checks=0,prefetch_overlap=0;integer ar_total[0:3],r_total[0:3],peer_peak[0:3];
 integer issues[0:81],commits[0:81],first_issue[0:81],last_issue[0:81],retired[0:81],bias_reads[0:81],bias_adds[0:81],bias_acks[0:81],arith_peak[0:81],accepted_cycle[0:81],output_cycle[0:81];
 integer bias_return_new_math_overlap=0,bias_write_contentions=0;
 integer reuse_wait_cycles=0,output_hold_cycles=0,merged_hold_cycles=0;
 integer scoreboard_s,scoreboard_seq,scoreboard_idx;logic [4351:0] expected_w,expected_a;logic [511:0] temp_word;logic peer_fault=0,fault_injected=0;integer actual_fault_accepts=0,recovery_start=-1;
 logic out_held=0;logic [1023:0] held_data;logic [6:0] held_row;logic [15:0] held_col,held_s;logic [63:0] held_request;logic [31:0] held_generation,held_epoch;
 logic ps_held=0;logic [95:0] held_ps_tag;logic [1023:0][31:0] held_ps_data;logic [1023:0] held_ps_mask;
 string fixture,casepath,input_casepath;
 function automatic logic [511:0] word(input integer p,idx);
  case(p)0:return mem0[idx];1:return mem1[idx];2:return mem2[idx];default:return mem3[idx];endcase
 endfunction
 function automatic integer column(input integer ss,half);
  if(cmd_n==5248)return 32*ss+(half?2624:0);
  return 64*ss+32*half;
 endfunction
 always_comb arready=(stress==1&&cycle%17<3)?0:15;
 always @(negedge clk)begin
  if(!rst_n)begin rvalid=0;rid=0;rdata=0;rresp=0;rlast=0;end
  else for(integer p=0;p<4;p++)begin
   if(!rvalid[p]||last_r_fire[p])begin
    integer pick;pick=-1;
    for(integer q=7;q>=0;q--)if(live[p][(rotate[p]+q)%8]&&cycle>=eligible[p][(rotate[p]+q)%8])pick=(rotate[p]+q)%8;
    rvalid[p]=0;
    if(pick>=0&&cycle%2==0)begin
     rvalid[p]=1;rid[p]=pick;rdata[p]=word(p,((baddr[p][pick]-cmd_base[p])>>6)+bpos[p][pick]);rlast[p]=bpos[p][pick]+1==bsize[p][pick];rresp[p]=0;
     if(peer_fault&&!fault_injected&&baddr[p][pick]-cmd_base[p]>=576*groups)begin rresp[p]=2;fault_injected=1;end
    end
   end
  end
  if(stress==1)begin
   out_ready=cycle%19>5;
   // Hold only the last already-buffered output: all old PS reads have returned, so the second math context can finish and ctx2 must truly wait.
   if(outputs>=255&&retired[0]<256&&first_issue[1]>=0&&cycle<first_issue[1]+2*cmd_k+180)out_ready=0;
   run_enable=cycle%23>2;
  end else begin out_ready=1;run_enable=!front_hold;end
 end
 always @(posedge clk)begin
  cycle<=cycle+1;last_r_fire<=rvalid&rready;
  if(!rst_n)begin
   observed_issue_valid=0;observed_ps_valid=0;observed_max_issue_ack=0;observed_max_ps_feedback=0;
   for(integer p=0;p<4;p++)begin live[p]<=0;rotate[p]<=0;ar_total[p]=0;r_total[p]=0;peer_peak[p]=0;end
  end else begin
   if(dut.matrix.facade.core.trace_issue)begin
    observed_issue_time[dut.matrix.facade.core.trace_issue_seq[5:0]]=cycle;
    observed_issue_seq[dut.matrix.facade.core.trace_issue_seq[5:0]]=dut.matrix.facade.core.trace_issue_seq;
    observed_issue_valid[dut.matrix.facade.core.trace_issue_seq[5:0]]=1;
    observed_ps_valid[dut.matrix.facade.core.trace_issue_seq[5:0]]=0;
   end
   if(dut.matrix.facade.core.math_read_fire)begin
    observed_ps_time[dut.matrix.facade.core.ps_next[5:0]]=cycle;
    observed_ps_valid[dut.matrix.facade.core.ps_next[5:0]]=1;
   end
   if(dut.matrix.facade.core.state==2&&dut.matrix.facade.core.normal_write_ack)begin
    if(!observed_issue_valid[dut.matrix.facade.core.ps_wr_rsp_tag[5:0]]||observed_issue_seq[dut.matrix.facade.core.ps_wr_rsp_tag[5:0]]!=dut.matrix.facade.core.ps_wr_rsp_tag[12:0])$fatal(1,"passive real issue/write-ack ledger mismatch");
    if(cycle-observed_issue_time[dut.matrix.facade.core.ps_wr_rsp_tag[5:0]]>64)$fatal(1,"passive issue-to-actual-PS-write-ack exceeds64");
    if(cycle-observed_issue_time[dut.matrix.facade.core.ps_wr_rsp_tag[5:0]]>observed_max_issue_ack)observed_max_issue_ack=cycle-observed_issue_time[dut.matrix.facade.core.ps_wr_rsp_tag[5:0]];
    if(observed_ps_valid[dut.matrix.facade.core.ps_wr_rsp_tag[5:0]])begin
     if(cycle-observed_ps_time[dut.matrix.facade.core.ps_wr_rsp_tag[5:0]]>24)$fatal(1,"passive actual PS read-to-write-ack feedback exceeds24");
     if(cycle-observed_ps_time[dut.matrix.facade.core.ps_wr_rsp_tag[5:0]]>observed_max_ps_feedback)observed_max_ps_feedback=cycle-observed_ps_time[dut.matrix.facade.core.ps_wr_rsp_tag[5:0]];
    end
    observed_issue_valid[dut.matrix.facade.core.ps_wr_rsp_tag[5:0]]=0;
   end
   if(dut.d_lease_active&&!dut.divider.leaf_ce)$fatal(1,"DIV numerical leaves paused during actual active ownership");
   if(!dut.d_lease_active&&dut.d_pending_vectors==0&&dut.d_in_flight_vectors==0&&dut.d_in_flight_scalars==0&&dut.divider.leaf_ce===1'b0)div_idle_clocks=div_idle_clocks+1;
   if(dut.d_release_valid&&dut.d_release_ready)begin div_last_release=cycle;div_previous_epoch=cmd_epoch;end
   if(dut.d_lease_valid&&dut.d_lease_ready&&div_last_release>=0&&cmd_epoch!=div_previous_epoch)begin
    if(cycle<=div_last_release||div_idle_clocks==0)$fatal(1,"new DIV epoch without actual idle handoff");div_new_epoch_handoffs=div_new_epoch_handoffs+1;
   end
   if(coef_cfg_valid&&coef_cfg_ready)coefficient_load_start=cycle;
   if(coef_rsp_valid&&coef_rsp_ready)begin $display("F32_COEFFICIENT_LOAD real_cfg_accept_to_response_consumed=%0d N=%0d original_model_key=%h tensor_key=%0d request=%h generation=%0d epoch=%0d",cycle-coefficient_load_start,coef_n,coef_model,coef_tensor,coef_request,coef_generation,coef_epoch);$fflush();end
   if(cmd_valid&&cmd_ready)f32_accept_cycle=cycle;
   if(in_valid&&in_ready)begin
    if(in_request!=cmd_request||in_generation!=cmd_generation||in_epoch!=cmd_epoch||in_row!=input_count/groups||in_group!=input_count%groups)$fatal(1,"actual F32 accepted identity/order");
    input_count=input_count+1;
   end
   if(input_reject_valid)begin if(in_ready)$fatal(1,"rejected input accepted");reject_count=reject_count+1;end
   if(dut.acfg_valid&&dut.acfg_ready)fill_configs=fill_configs+1;
   if(dut.d_lease_valid&&dut.d_lease_ready)div_leases=div_leases+1;
   if(dut.awr_valid&&dut.awr_ready)begin
    if(dut.awr_data!==a_words[dut.awr_row*groups+dut.awr_group]||dut.awr_request!=cmd_request||dut.awr_generation!=cmd_generation||dut.awr_epoch!=cmd_epoch)$fatal(1,"actual quant-to-A independent bytes/identity row=%0d group=%0d",dut.awr_row,dut.awr_group);
    write_count=write_count+1;
   end
   if(dut.awr_rsp_valid&&dut.awr_rsp_ready)ack_count=ack_count+1;
   if(dut.matrix_cmd_valid&&dut.matrix_cmd_ready)begin
    matrix_commands=matrix_commands+1;
    if(input_count!=128*groups||write_count!=128*groups||ack_count!=128*groups||quant_accepted!=128*groups||quant_retired!=128*groups||dut.front.q_reservations!=0||dut.front.q_lease_active||dut.d_lease_active||dut.front.a_write_debt!=0||!dut.front.a_published||!dut.front.producer_closed||!dut.front.producer_success)$fatal(1,"matrix launched before real quant/A/publication/producer release");
    $display("F32_PROGRESS matrix_handoff cycle=%0d inputs=%0d writes=%0d acks=%0d",dut.tick,input_count,write_count,ack_count);$fflush();
   end
   if(dut.matrix.facade.core_cmd_valid&&dut.matrix.facade.core_cmd_ready&&actual_first_core_cycle==0)actual_first_core_cycle=dut.tick;
   for(integer p=0;p<4;p++)begin
    if(arvalid[p]&&arready[p])begin
     if(live[p][arid[p]]||arlen[p]>15||araddr[p][5:0]!=0||{1'b0,araddr[p][11:0]}+64*(arlen[p]+1)>4096||araddr[p]<cmd_base[p]||araddr[p]+64*(arlen[p]+1)>cmd_base[p]+cmd_span[p])$fatal(1,"full actual AXI ID/page/span");
     live[p][arid[p]]<=1;baddr[p][arid[p]]<=araddr[p];bsize[p][arid[p]]<=arlen[p]+1;bpos[p][arid[p]]<=0;eligible[p][arid[p]]<=cycle+40+2*(7-arid[p]);ar_total[p]=ar_total[p]+1;
    end
    if(rvalid[p]&&rready[p])begin
     if(rresp[p]!=0)actual_fault_accepts=actual_fault_accepts+1;
     if(bpos[p][rid[p]]+1==bsize[p][rid[p]])live[p][rid[p]]<=0;else bpos[p][rid[p]]<=bpos[p][rid[p]]+1;rotate[p]<=(rid[p]+1)%8;r_total[p]=r_total[p]+1;
     if(dut.matrix.facade.core.state==2)prefetch_overlap=prefetch_overlap+1;
    end
    if($countones(live[p])>peer_peak[p])peer_peak[p]=$countones(live[p]);
   end
   if(dut.matrix.facade.core.trace_issue&&dut.matrix.facade.core.bias_write_ack&&dut.matrix.facade.core.ps_wr_rsp_tag[31]!=dut.matrix.facade.core.trace_compute_ctx)bias_return_new_math_overlap=bias_return_new_math_overlap+1;
   if(dut.matrix.facade.core.add_rsp_valid[0]&&dut.matrix.facade.core.add_rsp_tag[0][30]&&dut.matrix.facade.core.state==2&&dut.matrix.facade.core.write_next<dut.matrix.facade.core.issue_count&&dut.matrix.facade.core.pool_state[dut.matrix.facade.core.write_next[5:0]]==8)bias_write_contentions=bias_write_contentions+1;
   if(dut.matrix.facade.core_cmd_valid&&!dut.matrix.facade.core_cmd_ready&&dut.matrix.facade.issue_next>=2&&dut.matrix.facade.core.state==0&&dut.matrix.facade.core.ctx_busy_debug[dut.matrix.facade.issue_next[0]])reuse_wait_cycles=reuse_wait_cycles+1;
   if(out_valid&&!out_ready)output_hold_cycles=output_hold_cycles+1;
   if(dut.matrix.facade.core.ps_rd_rsp_valid&&!dut.matrix.facade.core.ps_rd_rsp_ready&&dut.matrix.facade.core.ps_rd_rsp_tag[29]&&dut.matrix.facade.core.ps_rd_rsp_tag[31])merged_hold_cycles=merged_hold_cycles+1;
   if(cmd_valid&&cmd_ready)begin $display("MATRIX_PROGRESS full_command_accept request=%h generation=%0d epoch=%0d K=%0d N=%0d",cmd_request,cmd_generation,cmd_epoch,cmd_k,cmd_n);$fflush();end
   if(dut.matrix.facade.w_complete)begin $display("MATRIX_PROGRESS actual_W_complete request=%h generation=%0d s=%0d status=%0d",dut.matrix.facade.w_complete_request,dut.matrix.facade.w_complete_generation,dut.matrix.facade.w_complete_s,dut.matrix.facade.w_complete_status);$fflush();end
   if(dut.matrix.facade.core_cmd_valid&&dut.matrix.facade.core_cmd_ready)begin
    $display("MATRIX_PROGRESS actual_core_command request=%h generation=%0d s=%0d",dut.matrix.facade.request_id,dut.matrix.facade.generation,dut.matrix.facade.issue_next);$fflush();
    accepted_cycle[dut.matrix.facade.issue_next]=cycle;
    if(dut.matrix.facade.issue_next>=2&&retired[dut.matrix.facade.issue_next-2]!=256)$fatal(1,"ctx reused before all prior output consumption s=%0d previous=%0d",dut.matrix.facade.issue_next,retired[dut.matrix.facade.issue_next-2]);
    if(dut.matrix.facade.issue_next<3&&dut.matrix.facade.issue_next[0]!=(dut.matrix.facade.issue_next%2))$fatal(1,"ctx rotation");
   end
   if(dut.matrix.facade.core.trace_issue)begin
    scoreboard_s=dut.matrix.facade.core.trace_block_s;scoreboard_seq=dut.matrix.facade.core.trace_issue_seq;
    if(scoreboard_s>=blocks||scoreboard_seq!=issues[scoreboard_s])$fatal(1,"full real issue order s=%0d seq=%0d expected=%0d",scoreboard_s,scoreboard_seq,issues[scoreboard_s]);
    if(stress!=1&&last_issue[scoreboard_s]>=0&&cycle-last_issue[scoreboard_s]!=1)$fatal(1,"full continuous K issue gap s=%0d seq=%0d gap=%0d debt=%0d biasdebt=%0d",scoreboard_s,scoreboard_seq,cycle-last_issue[scoreboard_s],arithmetic_debt,dut.matrix.facade.core.bias_debt);
    if(first_issue[scoreboard_s]<0)first_issue[scoreboard_s]=cycle;last_issue[scoreboard_s]=cycle;issues[scoreboard_s]=issues[scoreboard_s]+1;
    if(scoreboard_seq%8==0)begin
     scoreboard_idx=9*(scoreboard_s*groups+scoreboard_seq/32);
     for(integer q=0;q<8;q++)expected_w[512*q+:512]=word((scoreboard_seq%32)/8,scoreboard_idx+q);
     temp_word=word((scoreboard_seq%32)/8,scoreboard_idx+8);expected_w[4096+:256]=temp_word[255:0];
     if({dut.matrix.facade.core.trace_w_scale,dut.matrix.facade.core.trace_w_q}!==expected_w)$fatal(1,"full actual W record mapping s=%0d seq=%0d",scoreboard_s,scoreboard_seq);w_checks=w_checks+1;
    end
    if(scoreboard_s==0&&(scoreboard_seq%32)<8)begin
     for(integer a=0;a<16;a++)begin expected_a[256*a+:256]=a_words[(16*(scoreboard_seq%8)+a)*groups+scoreboard_seq/32][255:0];expected_a[4096+16*a+:16]=a_words[(16*(scoreboard_seq%8)+a)*groups+scoreboard_seq/32][271:256];end
     if({dut.matrix.facade.core.trace_a_scale,dut.matrix.facade.core.trace_a_q}!==expected_a)$fatal(1,"full actual A record mapping seq=%0d",scoreboard_seq);a_checks=a_checks+1;
    end
   end
   if(dut.matrix.facade.core.trace_commit)begin
    scoreboard_s=dut.matrix.facade.core.trace_block_s;scoreboard_seq=dut.matrix.facade.core.trace_commit_seq;
    if(scoreboard_seq!=commits[scoreboard_s])$fatal(1,"full real PS acknowledgement order");commits[scoreboard_s]=commits[scoreboard_s]+1;
    if(scoreboard_seq>=cmd_k-32&&dut.matrix.facade.core.trace_commit_data!==pre_bias[32*scoreboard_s+scoreboard_seq-(cmd_k-32)])$fatal(1,"full independent last-group PS s=%0d seq=%0d data0=%h gold0=%h",scoreboard_s,scoreboard_seq,dut.matrix.facade.core.trace_commit_data[0],pre_bias[32*scoreboard_s+scoreboard_seq-(cmd_k-32)][31:0]);
   end
   if(dut.matrix.facade.core.bias_read_fire)bias_reads[dut.matrix.facade.core.ctx_s[dut.matrix.facade.core.bias_ctx]]=bias_reads[dut.matrix.facade.core.ctx_s[dut.matrix.facade.core.bias_ctx]]+1;
   if(dut.matrix.facade.core.bias_add_fire)bias_adds[dut.matrix.facade.core.ctx_s[dut.matrix.facade.core.add_req_tag[0][31]]]=bias_adds[dut.matrix.facade.core.ctx_s[dut.matrix.facade.core.add_req_tag[0][31]]]+1;
   if(dut.matrix.facade.core.bias_write_ack)bias_acks[dut.matrix.facade.core.ctx_s[dut.matrix.facade.core.ps_wr_rsp_tag[31]]]=bias_acks[dut.matrix.facade.core.ctx_s[dut.matrix.facade.core.ps_wr_rsp_tag[31]]]+1;
   if(dut.matrix.facade.core.state==2&&arithmetic_debt>arith_peak[dut.matrix.facade.core.trace_block_s])arith_peak[dut.matrix.facade.core.trace_block_s]=arithmetic_debt;
   if(out_held&&(!out_valid||out_data!==held_data||out_row!=held_row||out_col!=held_col||out_s!=held_s||out_request!=held_request||out_generation!=held_generation||out_epoch!=held_epoch))$fatal(1,"full public output hold");
   out_held=out_valid&&!out_ready;held_data=out_data;held_row=out_row;held_col=out_col;held_s=out_s;held_request=out_request;held_generation=out_generation;held_epoch=out_epoch;
   if(ps_held&&(!dut.matrix.facade.core.ps_rd_rsp_valid||dut.matrix.facade.core.ps_rd_rsp_tag!==held_ps_tag||dut.matrix.facade.core.ps_rd_rsp_data!==held_ps_data||dut.matrix.facade.core.ps_rd_rsp_mask!==held_ps_mask))$fatal(1,"merged PS response hold");
   ps_held=dut.matrix.facade.core.ps_rd_rsp_valid&&!dut.matrix.facade.core.ps_rd_rsp_ready;held_ps_tag=dut.matrix.facade.core.ps_rd_rsp_tag;held_ps_data=dut.matrix.facade.core.ps_rd_rsp_data;held_ps_mask=dut.matrix.facade.core.ps_rd_rsp_mask;
   if(out_valid&&out_ready)begin
    scoreboard_s=outputs/256;scoreboard_seq=outputs%256;
    if(out_s!=scoreboard_s||out_row!=scoreboard_seq/2||out_col!=column(scoreboard_s,scoreboard_seq%2)||out_request!=cmd_request||out_generation!=cmd_generation||out_epoch!=cmd_epoch||out_data!==gold[outputs])$fatal(1,"full final output index=%0d s=%0d/%0d row=%0d col=%0d data0=%h gold0=%h",outputs,out_s,scoreboard_s,out_row,out_col,out_data[0],gold[outputs][31:0]);
    if(commits[scoreboard_s]!=cmd_k||(cmd_bias&&(bias_reads[scoreboard_s]!=32||bias_adds[scoreboard_s]!=32||bias_acks[scoreboard_s]!=32)))$fatal(1,"output before real math/bias acknowledgements s=%0d commit=%0d bias=%0d/%0d/%0d",scoreboard_s,commits[scoreboard_s],bias_reads[scoreboard_s],bias_adds[scoreboard_s],bias_acks[scoreboard_s]);
    outputs=outputs+1;retired[scoreboard_s]=retired[scoreboard_s]+1;output_cycle[scoreboard_s]=cycle;
    if(retired[scoreboard_s]==256)begin $display("MATRIX_PROGRESS real_retired_s=%0d final_outputs=%0d actual_commits=%0d bias_acks=%0d retire_debt_before_edge=%0d cycle=%0d",scoreboard_s,outputs,commits[scoreboard_s],bias_acks[scoreboard_s],dut.matrix.facade.core.retire_debt,cycle);$fflush();end
    if(stress==0&&retired[scoreboard_s]==256&&cycle-accepted_cycle[scoreboard_s]>cmd_k+384)$fatal(1,"full per-block accept-to-last-output cap s=%0d elapsed=%0d",scoreboard_s,cycle-accepted_cycle[scoreboard_s]);
   end
   if(arithmetic_debt>64||dut.matrix.facade.core.reserved_vectors>128||peak_return_reservations>128)$fatal(1,"full global arithmetic/return reservations");
   if(stress==0&&(dut.matrix.facade.max_issue_commit>64||dut.matrix.facade.max_ps_feedback>24))$fatal(1,"full arithmetic commit/feedback latency %0d/%0d",dut.matrix.facade.max_issue_commit,dut.matrix.facade.max_ps_feedback);
  end
  if(recovery_start>=0&&outputs<prefix*256&&cycle-recovery_start>4*cmd_k+2048)$fatal(1,"bounded new-identity recovery status=%0d topactive=%0d abort=%0d issue_next=%0d load_next=%0d load_pending=%0d corestate=%0d coreactive=%0d coreabort=%0d ctxbusy=%b Avalid=%b Aleased=%b Wvalid=%b Wleased=%b slot_ready=%b slot_in_use=%b I0=%0d C0=%0d",status,dut.matrix.facade.active,dut.matrix.facade.aborting,dut.matrix.facade.issue_next,dut.matrix.facade.load_next,dut.matrix.facade.load_pending,dut.matrix.facade.core.state,dut.matrix.facade.core.matrix_active,dut.matrix.facade.core.aborting,dut.matrix.facade.core.ctx_busy,dut.matrix.facade.a_slot_valid,dut.matrix.facade.a_slot_leased,dut.matrix.facade.w_slot_valid,dut.matrix.facade.w_slot_leased,dut.matrix.facade.slot_ready,dut.matrix.facade.slot_in_use,issues[0],commits[0]);
  if(cycle>300000)$fatal(1,"full bounded simulation cycle watchdog");
 end
 task automatic prepare;
  begin
   case(which)
    0:begin casepath={fixture,"/qkv_0_weight"};cmd_k=1024;cmd_n=3072;cmd_bias=0;end
    1:begin casepath={fixture,"/wo_0_weight"};cmd_k=1024;cmd_n=1024;cmd_bias=0;end
    2:begin casepath={fixture,"/mlp_wi_0_weight"};cmd_k=1024;cmd_n=5248;cmd_bias=0;end
    3:begin casepath={fixture,"/mlp_wo_0_weight"};cmd_k=2624;cmd_n=1024;cmd_bias=0;end
    4:begin casepath={fixture,"/head_fc1_0_weight"};cmd_k=1024;cmd_n=4096;cmd_bias=1;end
    5:begin casepath={fixture,"/head_fc2_0_weight"};cmd_k=4096;cmd_n=1024;cmd_bias=1;end
    6:begin casepath={fixture,"/head_qkv_0_weight"};cmd_k=1024;cmd_n=3072;cmd_bias=1;end
    7:begin casepath={fixture,"/head_wo_0_weight"};cmd_k=1024;cmd_n=1024;cmd_bias=1;end
   endcase
   input_count=0;write_count=0;ack_count=0;fill_configs=0;div_leases=0;matrix_commands=0;reject_count=0;actual_first_core_cycle=0;
   bias_return_new_math_overlap=0;bias_write_contentions=0;outputs=0;w_checks=0;a_checks=0;prefetch_overlap=0;reuse_wait_cycles=0;output_hold_cycles=0;merged_hold_cycles=0;out_held=0;ps_held=0;
   groups=cmd_k/32;blocks=(cmd_n==5248)?82:cmd_n/64;cmd_tensor=which+1;
   for(integer p=0;p<4;p++)begin cmd_base[p]=64'h100000000+64'h10000000*p;cmd_span[p]=576*groups*blocks;end
   input_casepath={input_fixture,casepath.substr(fixture.len(),casepath.len()-1)};
   $readmemh({input_casepath,"/input.hex"},input_words,0,128*groups-1);
   $readmemh({casepath,"/a_write.hex"},a_words,0,128*groups-1);$readmemh({casepath,"/output.hex"},gold,0,blocks*256-1);$readmemh({casepath,"/pre_bias.hex"},pre_bias,0,blocks*32-1);$readmemh({casepath,"/bias.hex"},bias_words,0,cmd_n/32-1);
   $readmemh({casepath,"/p0.hex"},mem0,0,9*groups*blocks-1);$readmemh({casepath,"/p1.hex"},mem1,0,9*groups*blocks-1);$readmemh({casepath,"/p2.hex"},mem2,0,9*groups*blocks-1);$readmemh({casepath,"/p3.hex"},mem3,0,9*groups*blocks-1);
   for(integer s=0;s<82;s++)begin issues[s]=0;commits[s]=0;first_issue[s]=-1;last_issue[s]=-1;retired[s]=0;bias_reads[s]=0;bias_adds[s]=0;bias_acks[s]=0;arith_peak[s]=0;accepted_cycle[s]=-1;output_cycle[s]=-1;end
  end
 endtask
 task automatic fill_coef;
  begin
   if(cmd_bias)begin
    @(negedge clk);coef_model=cmd_model;coef_tensor=cmd_tensor;coef_request=cmd_request;coef_generation=cmd_generation;coef_epoch=cmd_epoch;coef_n=cmd_n;coef_cfg_valid=1;do @(posedge clk);while(!coef_cfg_ready);@(negedge clk);coef_cfg_valid=0;
    for(integer b=0;b<cmd_n/32;b++)begin @(negedge clk);coef_wr_valid=1;coef_wr_addr=b;coef_wr_data=bias_words[b];do @(posedge clk);while(!coef_wr_ready);end
    @(negedge clk);coef_wr_valid=0;wait(coef_rsp_valid);repeat(3)@(negedge clk);if(coef_status!=0)$fatal(1,"full coefficient preload status=%0d",coef_status);coef_rsp_ready=1;@(negedge clk);coef_rsp_ready=0;
   end
  end
 endtask
 task automatic submit;
  integer submit_start;
  begin @(negedge clk);cmd_valid=1;submit_start=cycle;do begin @(posedge clk);if(cycle-submit_start>256)$fatal(1,"bounded full command ready active=%0d done=%0d corestate=%0d",dut.matrix.facade.active,done_valid,dut.matrix.facade.core.state);end while(!cmd_ready);@(negedge clk);cmd_valid=0;end
 endtask
 task automatic invalid_span;
  integer before_ar;
  begin
   before_ar=ar_total[0]+ar_total[1]+ar_total[2]+ar_total[3];cmd_span[0]=cmd_span[0]-1;submit;wait(done_valid);repeat(4)@(negedge clk);
   if(status!=1||outputs!=0||before_ar!=ar_total[0]+ar_total[1]+ar_total[2]+ar_total[3])$fatal(1,"full illegal span emitted work");done_ready=1;@(negedge clk);done_ready=0;cmd_span[0]=cmd_span[0]+1;
  end
 endtask
 task automatic invalid_coefficient_identity;
  integer before_ar;logic [63:0] original_model;
  begin
   if(cmd_bias)begin
    original_model=cmd_model;before_ar=ar_total[0]+ar_total[1]+ar_total[2]+ar_total[3];cmd_model=cmd_model^64'd1;submit;wait(done_valid);repeat(3)@(negedge clk);
    if(status!=1||outputs!=0||before_ar!=ar_total[0]+ar_total[1]+ar_total[2]+ar_total[3])$fatal(1,"full coefficient identity emitted work");
    done_ready=1;@(negedge clk);done_ready=0;cmd_model=original_model;
    $display("M007_F32_COEFFICIENT_IDENTITY_PASS original_model_restored=1 zero_AR=1");
   end
  end
 endtask
 task automatic report_blocks(input integer count);
  begin
   for(integer ss=0;ss<count;ss++)begin
    if(issues[ss]!=cmd_k||commits[ss]!=cmd_k||retired[ss]!=256||(!stress&&last_issue[ss]-first_issue[ss]+1!=cmd_k))$fatal(1,"full block event/continuous coverage s=%0d I=%0d C=%0d O=%0d span=%0d",ss,issues[ss],commits[ss],retired[ss],last_issue[ss]-first_issue[ss]+1);
    $display("M007_F32_BLOCK_PASS s=%0d ctx=%0d issue_span=%0d gap_from_previous=%0d bias_read=%0d bias_add=%0d bias_ack=%0d peak_arithmetic=%0d accept_to_last_output=%0d",ss,ss%2,last_issue[ss]-first_issue[ss]+1,ss?first_issue[ss]-last_issue[ss-1]-1:0,bias_reads[ss],bias_adds[ss],bias_acks[ss],arith_peak[ss],output_cycle[ss]-accepted_cycle[ss]);
   end
   if(compute_output_overlap==0||ps_merged_reads==0||prefetch_overlap==0)$fatal(1,"full genuine compute/PS/output/W overlap missing");
   for(integer p=0;p<4;p++)if(peer_peak[p]!=8)$fatal(1,"full eight actual AXI ID outstanding coverage");
   if(stress==1&&(ps_response_holds==0||merged_hold_cycles==0||reuse_wait_cycles==0||output_hold_cycles==0))$fatal(1,"full affected hold/reuse coverage missing holds=%0d merged=%0d reuse=%0d output=%0d",ps_response_holds,merged_hold_cycles,reuse_wait_cycles,output_hold_cycles);
   if(cmd_bias)begin
    if(bias_return_new_math_overlap==0)$fatal(1,"actual old-context bias acknowledgement/new-context math issue overlap missing");
    $display("M007_F32_BIAS_OVERLAP_PASS actual_bias_ack_new_issue=%0d shared_add_conflicts=%0d shared_PS_write_conflicts=%0d",bias_return_new_math_overlap,bias_add_conflicts,bias_write_contentions);
   end
   if(stress==1)$display("M007_F32_STRESS_PASS merged_hold=%0d ctx_reuse_wait=%0d output_hold=%0d bias_math_conflicts=%0d",merged_hold_cycles,reuse_wait_cycles,output_hold_cycles,bias_add_conflicts);
  end
 endtask
 task automatic passive_profile_check;
  begin
   if(dut.matrix.facade.profile_valid!==PROFILE_ENABLE)$fatal(1,"profile validity mismatch");
   if(observed_max_issue_ack==0||observed_max_ps_feedback==0)$fatal(1,"missing passive actual issue/PS timing evidence");
   if(PROFILE_ENABLE)begin
    if(dut.matrix.facade.core.max_issue_commit!=observed_max_issue_ack||dut.matrix.facade.core.max_ps_feedback!=observed_max_ps_feedback)$fatal(1,"profile-on/passive timing mismatch");
   end else if(dut.matrix.facade.core.max_issue_commit!=0||dut.matrix.facade.core.max_ps_feedback!=0)$fatal(1,"invalid production metric not zero");
   $display("M007_PURE_PROFILE_OBSERVATION enabled=%0d profile_valid=%0d passive_issue_to_ack=%0d passive_actual_PS_feedback=%0d",PROFILE_ENABLE,dut.matrix.facade.profile_valid,observed_max_issue_ack,observed_max_ps_feedback);
  end
 endtask
 task automatic held_done_check(input logic [2:0] expected_status);
  logic [189:0] held_response;
  begin
   @(negedge clk);held_response={status,done_request,done_generation,done_epoch,error_domain,quant_phase,quant_row,quant_group,quant_element,error_row,error_col,error_group,error_stage};cmd_valid=1;
   repeat(5)begin @(negedge clk);if(!done_valid||status!=expected_status||cmd_ready||out_valid||{status,done_request,done_generation,done_epoch,error_domain,quant_phase,quant_row,quant_group,quant_element,error_row,error_col,error_group,error_stage}!==held_response)$fatal(1,"full held done/new command barrier status=%0d",status);end
   cmd_valid=0;done_ready=1;@(negedge clk);done_ready=0;
  end
 endtask
 task automatic send_inputs;
  begin:stream
   for(integer idx=0;idx<128*groups;idx++)begin
    @(negedge clk);if(!rst_n)disable stream;
    in_valid=1;in_request=cmd_request;in_generation=cmd_generation;in_epoch=cmd_epoch;in_row=idx/groups;in_group=idx%groups;in_data=input_words[idx];
    if(stress==4&&idx==0)begin
     in_request=cmd_request+1;@(posedge clk);if(in_ready||!input_reject_valid)$fatal(1,"wrong identity not rejected");
     @(negedge clk);in_request=cmd_request;in_generation=cmd_generation+1;@(posedge clk);if(in_ready||!input_reject_valid)$fatal(1,"wrong generation not rejected");
     @(negedge clk);in_generation=cmd_generation;in_epoch=cmd_epoch+1;@(posedge clk);if(in_ready||!input_reject_valid)$fatal(1,"wrong epoch not rejected");
     @(negedge clk);in_epoch=cmd_epoch;in_row=1;@(posedge clk);if(in_ready||!input_reject_valid)$fatal(1,"out of order row not rejected");
     @(negedge clk);in_row=0;in_group=1;@(posedge clk);if(in_ready||!input_reject_valid)$fatal(1,"out of order not rejected");@(negedge clk);in_group=0;
    end
    do begin @(posedge clk);if(!rst_n)disable stream;end while(!in_ready);
    if(stress==4&&idx==1)begin
     @(negedge clk);in_group=0;@(posedge clk);if(in_ready||!input_reject_valid)$fatal(1,"duplicate input not rejected");
    end
   end
   @(negedge clk);in_valid=0;
  end
 endtask
 task automatic hold_front;
  wait(dut.front.q_out_valid&&quant_retired==128*groups-1);@(negedge clk);front_hold=1;run_enable=0;
  repeat(8)begin
   @(negedge clk);if(!dut.front.q_out_valid||quant_retired!=128*groups-1||matrix_commands||arvalid!=0||done_valid)$fatal(1,"last quant held barrier");front_quant_hold=front_quant_hold+1;
  end
  front_hold=0;run_enable=1;wait(quant_retired==128*groups);@(negedge clk);front_hold=1;run_enable=0;
  repeat(8)begin
   @(negedge clk);if(!dut.awr_rsp_valid||ack_count!=128*groups-1||matrix_commands||arvalid!=0||done_valid||dut.acfg_rsp_valid)$fatal(1,"last A ack held barrier");front_ack_hold=front_ack_hold+1;
  end
  front_hold=0;run_enable=1;
 endtask
 task automatic quant_reset;
  integer live_groups,live_div,live_writes;
  wait(quant_accepted>=128&&quant_retired>0&&dut.front.q_reservations>0&&dut.d_in_flight_vectors>0);
  live_groups=dut.front.q_reservations;live_div=dut.d_in_flight_vectors;live_writes=a_writes;
  @(negedge clk);rst_n=0;in_valid=0;cmd_valid=0;out_held=0;ps_held=0;
  repeat(5)@(negedge clk);rst_n=1;
  repeat(12)begin @(negedge clk);if(out_valid||done_valid||arvalid!=0||dut.acfg_rsp_valid||dut.awr_rsp_valid||dut.front.q_reservations!=0||dut.d_lease_active||dut.matrix.facade.a_slot_valid!=0)$fatal(1,"quant common reset stale response/debt");end
  $display("M007_F32_QUANT_RESET_PASS actual_live_groups=%0d actual_live_DIV=%0d actual_A_writes=%0d stale_free_clocks=12",live_groups,live_div,live_writes);
 endtask
 task automatic error_then_recovery;
  integer oldstress;
  oldstress=stress;
  input_words[1]={32{32'h7f7fffff}};
  if(stress==6)input_words[128*groups-1]={32{32'h0000007f}};
  else input_words[128*groups-1][32*17+:32]=32'h7fc00000;
  submit;send_inputs;wait(done_valid);@(negedge clk);
  if(status!=2||error_domain!=2||quant_phase!=(stress==6?3:1)||quant_row!=127||quant_group!=groups-1||quant_element!=(stress==6?0:17)||input_count!=128*groups||quant_retired!=128*groups||matrix_commands!=0||outputs!=0||ar_total[0]+ar_total[1]+ar_total[2]+ar_total[3]!=0||write_count!=ack_count||write_count==0||dut.front.q_reservations||dut.d_lease_active||dut.matrix.facade.a_slot_valid[cmd_a_slot]||dut.front.a_write_debt)$fatal(1,"global quant rank/real cancellation status=%0d phase=%0d row=%0d group=%0d elem=%0d writes=%0d acks=%0d",status,quant_phase,quant_row,quant_group,quant_element,write_count,ack_count);
  if(dut.front.q_scale_divisions!=(stress==6?4096:4095)||dut.front.q_inverse_divisions!=(stress==6?4095:4094))$fatal(1,"actual quant division counts, no synthetic skipped inverse");
  $display("M007_F32_GLOBAL_QUANT_ERROR_PASS mode=%0d phase=%0d row=%0d group=%0d elem=%0d actual_inputs=%0d retired=%0d real_A_writes=%0d real_A_acks=%0d zero_W_AR=1 zero_matrix=1 scale_divisions=%0d inverse_divisions=%0d",stress,quant_phase,quant_row,quant_group,quant_element,input_count,quant_retired,write_count,ack_count,dut.front.q_scale_divisions,dut.front.q_inverse_divisions);
  held_done_check(2);
  // Actual no-reset different source/request/generation/epoch and slot recovery.
  which=1;stress=0;cmd_request=cmd_request+256;cmd_generation=cmd_generation+1;cmd_epoch=cmd_epoch+1;cmd_a_slot=1;prepare;fill_coef;submit;send_inputs;
 endtask
 initial begin
  clk=0;rst_n=0;cmd_valid=0;cmd_version=1;cmd_request=64'h3300000001;cmd_model=64'h6eb6ef58bc4f99bd;cmd_generation=1;cmd_epoch=1;cmd_a_slot=0;done_ready=0;out_ready=1;run_enable=1;
  in_valid=0;in_data=0;in_request=0;in_generation=0;in_epoch=0;in_row=0;in_group=0;
  coef_cfg_valid=0;coef_wr_valid=0;coef_rsp_ready=0;rvalid=0;rid=0;rdata=0;rresp=0;rlast=0;last_r_fire=0;
  if(!$value$plusargs("FIXTURE=%s",fixture))$fatal(1,"FIXTURE required");if(!$value$plusargs("INPUT_FIXTURE=%s",input_fixture))$fatal(1,"INPUT_FIXTURE required");if(!$value$plusargs("CASE=%d",which))which=0;if(!$value$plusargs("PREFIX=%d",prefix))prefix=3;if(!$value$plusargs("STRESS=%d",stress))stress=0;
  prepare;repeat(5)@(negedge clk);rst_n=1;fill_coef;invalid_coefficient_identity;invalid_span;
  if(fill_configs||div_leases||input_count||write_count||matrix_commands)$fatal(1,"illegal descriptor performed front work");
  if(stress==6||stress==7)error_then_recovery;
  else if(stress==8)begin
   submit;fork send_inputs;quant_reset;join
   which=1;stress=0;cmd_request=cmd_request+512;cmd_generation=cmd_generation+2;cmd_epoch=cmd_epoch+2;cmd_a_slot=1;prepare;fill_coef;submit;send_inputs;
  end else if(stress==5)begin submit;fork send_inputs;hold_front;join end
  else begin submit;send_inputs;end
  if(prefix!=0)begin
   wait(outputs==prefix*256);@(negedge clk);report_blocks(prefix);
   if(input_count!=128*groups||write_count!=128*groups||ack_count!=128*groups||matrix_commands!=1||fill_configs!=1||div_leases!=1)$fatal(1,"real F32 front exact event counts");
   if(stress==4&&reject_count<6)$fatal(1,"wrong/order/duplicate rejection missing");
   if(stress==5&&(front_quant_hold!=8||front_ack_hold!=8))$fatal(1,"actual front holds not observed");
   $display("M007_F32_PREFIX_PASS case=%0d blocks=%0d total_cycles=%0d f32_cycles=%0d first_input=%0d last_input=%0d quant_last=%0d A_publish=%0d first_W=%0d matrix_handoff=%0d first_real_core=%0d first_output=%0d real_inputs=%0d real_Awrites=%0d real_Aacks=%0d",which,prefix,cycle,dut.tick,first_input_cycle,last_input_cycle,quant_last_cycle,a_publish_cycle,first_w_cycle,first_matrix_cycle,actual_first_core_cycle,first_output_cycle,input_count,write_count,ack_count);
   $display("M007_F32_DIV_GATE_OBSERVATION actual_idle_clocks=%0d new_epoch_handoffs=%0d active_leaf_pause=0",div_idle_clocks,div_new_epoch_handoffs);
   $display("HARDWARE_AGENT_SIM_PASS M007_MATRIX_F32_PREFIX case=%0d",which);passive_profile_check;$finish;
  end else begin
   wait(done_valid);@(negedge clk);report_blocks(blocks);
   if(status!=0||error_domain!=0||done_request!=cmd_request||done_generation!=cmd_generation||done_epoch!=cmd_epoch||outputs!=blocks*256||blocks_issued!=blocks||blocks_computed!=blocks||blocks_retired!=blocks||dut.matrix.facade.a_slot_leased!=0||dut.matrix.facade.w_slot_leased!=0||dut.matrix.facade.a_read_debt!=0||arithmetic_debt!=0||dut.matrix.facade.load_pending||live[0]!=0||live[1]!=0||live[2]!=0||live[3]!=0||dut.d_lease_active||dut.front.q_reservations!=0||write_count!=128*groups||ack_count!=128*groups||input_count!=128*groups||matrix_commands!=1)$fatal(1,"F32 final identity/output/debt/counter coverage status=%0d outputs=%0d",status,outputs);
   if(stress==0)begin
    integer cap;case(which)0,6:cap=57344;1,7:cap=22528;2:cap=92160;3:cap=56576;4:cap=73728;default:cap=86016;endcase
    if(elapsed_cycles>cap)$fatal(1,"F32 joint cap actual=%0d cap=%0d",elapsed_cycles,cap);
   end
   for(integer p=0;p<4;p++)if(r_total[p]!=9*groups*blocks)$fatal(1,"F32 exact cold W bytes");
   passive_profile_check;held_done_check(0);
   $display("M007_F32_MATRIX_PASS case=%0d K=%0d N=%0d blocks=%0d final_values=%0d total_cycles=%0d f32_cycles=%0d first_input=%0d last_input=%0d quant_last=%0d A_publish=%0d first_W=%0d matrix_handoff=%0d first_real_core=%0d first_output=%0d real_inputs=%0d real_Awrites=%0d real_Aacks=%0d",which,cmd_k,cmd_n,blocks,128*cmd_n,cycle,elapsed_cycles,first_input_cycle,last_input_cycle,quant_last_cycle,a_publish_cycle,first_w_cycle,first_matrix_cycle,actual_first_core_cycle,first_output_cycle,input_count,write_count,ack_count);
   $display("HARDWARE_AGENT_SIM_PASS M007_MATRIX_F32 case=%0d",which);$finish;
  end
 end
endmodule
