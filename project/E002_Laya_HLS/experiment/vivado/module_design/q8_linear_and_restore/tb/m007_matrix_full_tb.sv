`timescale 1ns/1ps
module m007_matrix_full_tb;
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
 logic acfg_valid;logic acfg_ready;logic acfg_slot;logic [15:0] acfg_k;
 logic [63:0] acfg_request;logic [31:0] acfg_generation,acfg_epoch;
 logic acfg_rsp_valid;logic acfg_rsp_ready;logic [1:0] acfg_status;
 logic awr_valid;logic awr_ready;logic [6:0] awr_row,awr_group;logic [271:0] awr_data;
 logic [63:0] awr_request;logic [31:0] awr_generation,awr_epoch;
 logic awr_rsp_valid;logic awr_rsp_ready;
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
 laya_m007_matrix_full_v1 dut(.descriptor_precheck_ok(),.fill_cancel_ready(),.fill_cancel_reject_valid(),.fill_cancel_reject_code(),.fill_cancel_rsp_valid(),.fill_cancel_rsp_slot(),.fill_cancel_rsp_request(),.fill_cancel_rsp_generation(),.fill_cancel_rsp_epoch(),.fill_cancel_valid(1'b0),.fill_cancel_slot(1'b0),.fill_cancel_request(64'b0),.fill_cancel_generation(32'b0),.fill_cancel_epoch(32'b0),.fill_cancel_rsp_ready(1'b1),.*);
 always #1 clk=~clk;
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
 string fixture,casepath;
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
  end else begin out_ready=1;run_enable=1;end
 end
 always @(posedge clk)begin
  cycle<=cycle+1;last_r_fire<=rvalid&rready;
  if(!rst_n)begin
   for(integer p=0;p<4;p++)begin live[p]<=0;rotate[p]<=0;ar_total[p]=0;r_total[p]=0;peer_peak[p]=0;end
  end else begin
   for(integer p=0;p<4;p++)begin
    if(arvalid[p]&&arready[p])begin
     if(live[p][arid[p]]||arlen[p]>15||araddr[p][5:0]!=0||{1'b0,araddr[p][11:0]}+64*(arlen[p]+1)>4096||araddr[p]<cmd_base[p]||araddr[p]+64*(arlen[p]+1)>cmd_base[p]+cmd_span[p])$fatal(1,"full actual AXI ID/page/span");
     live[p][arid[p]]<=1;baddr[p][arid[p]]<=araddr[p];bsize[p][arid[p]]<=arlen[p]+1;bpos[p][arid[p]]<=0;eligible[p][arid[p]]<=cycle+40+2*(7-arid[p]);ar_total[p]=ar_total[p]+1;
    end
    if(rvalid[p]&&rready[p])begin
     if(rresp[p]!=0)actual_fault_accepts=actual_fault_accepts+1;
     if(bpos[p][rid[p]]+1==bsize[p][rid[p]])live[p][rid[p]]<=0;else bpos[p][rid[p]]<=bpos[p][rid[p]]+1;rotate[p]<=(rid[p]+1)%8;r_total[p]=r_total[p]+1;
     if(dut.core.state==2)prefetch_overlap=prefetch_overlap+1;
    end
    if($countones(live[p])>peer_peak[p])peer_peak[p]=$countones(live[p]);
   end
   if(dut.core.trace_issue&&dut.core.bias_write_ack&&dut.core.ps_wr_rsp_tag[31]!=dut.core.trace_compute_ctx)bias_return_new_math_overlap=bias_return_new_math_overlap+1;
   if(dut.core.add_rsp_valid[0]&&dut.core.add_rsp_tag[0][30]&&dut.core.state==2&&dut.core.write_next<dut.core.issue_count&&dut.core.pool_state[dut.core.write_next[5:0]]==8)bias_write_contentions=bias_write_contentions+1;
   if(dut.core_cmd_valid&&!dut.core_cmd_ready&&dut.issue_next>=2&&dut.core.state==0&&dut.core.ctx_busy_debug[dut.issue_next[0]])reuse_wait_cycles=reuse_wait_cycles+1;
   if(out_valid&&!out_ready)output_hold_cycles=output_hold_cycles+1;
   if(dut.core.ps_rd_rsp_valid&&!dut.core.ps_rd_rsp_ready&&dut.core.ps_rd_rsp_tag[29]&&dut.core.ps_rd_rsp_tag[31])merged_hold_cycles=merged_hold_cycles+1;
   if(cmd_valid&&cmd_ready)begin $display("MATRIX_PROGRESS full_command_accept request=%h generation=%0d epoch=%0d K=%0d N=%0d",cmd_request,cmd_generation,cmd_epoch,cmd_k,cmd_n);$fflush();end
   if(dut.w_complete)begin $display("MATRIX_PROGRESS actual_W_complete request=%h generation=%0d s=%0d status=%0d",dut.w_complete_request,dut.w_complete_generation,dut.w_complete_s,dut.w_complete_status);$fflush();end
   if(dut.core_cmd_valid&&dut.core_cmd_ready)begin
    $display("MATRIX_PROGRESS actual_core_command request=%h generation=%0d s=%0d",dut.request_id,dut.generation,dut.issue_next);$fflush();
    accepted_cycle[dut.issue_next]=cycle;
    if(dut.issue_next>=2&&retired[dut.issue_next-2]!=256)$fatal(1,"ctx reused before all prior output consumption s=%0d previous=%0d",dut.issue_next,retired[dut.issue_next-2]);
    if(dut.issue_next<3&&dut.issue_next[0]!=(dut.issue_next%2))$fatal(1,"ctx rotation");
   end
   if(dut.core.trace_issue)begin
    scoreboard_s=dut.core.trace_block_s;scoreboard_seq=dut.core.trace_issue_seq;
    if(scoreboard_s>=blocks||scoreboard_seq!=issues[scoreboard_s])$fatal(1,"full real issue order s=%0d seq=%0d expected=%0d",scoreboard_s,scoreboard_seq,issues[scoreboard_s]);
    if(stress!=1&&last_issue[scoreboard_s]>=0&&cycle-last_issue[scoreboard_s]!=1)$fatal(1,"full continuous K issue gap s=%0d seq=%0d gap=%0d debt=%0d biasdebt=%0d",scoreboard_s,scoreboard_seq,cycle-last_issue[scoreboard_s],arithmetic_debt,dut.core.bias_debt);
    if(first_issue[scoreboard_s]<0)first_issue[scoreboard_s]=cycle;last_issue[scoreboard_s]=cycle;issues[scoreboard_s]=issues[scoreboard_s]+1;
    if(scoreboard_seq%8==0)begin
     scoreboard_idx=9*(scoreboard_s*groups+scoreboard_seq/32);
     for(integer q=0;q<8;q++)expected_w[512*q+:512]=word((scoreboard_seq%32)/8,scoreboard_idx+q);
     temp_word=word((scoreboard_seq%32)/8,scoreboard_idx+8);expected_w[4096+:256]=temp_word[255:0];
     if({dut.core.trace_w_scale,dut.core.trace_w_q}!==expected_w)$fatal(1,"full actual W record mapping s=%0d seq=%0d",scoreboard_s,scoreboard_seq);w_checks=w_checks+1;
    end
    if(scoreboard_s==0&&(scoreboard_seq%32)<8)begin
     for(integer a=0;a<16;a++)begin expected_a[256*a+:256]=a_words[(16*(scoreboard_seq%8)+a)*groups+scoreboard_seq/32][255:0];expected_a[4096+16*a+:16]=a_words[(16*(scoreboard_seq%8)+a)*groups+scoreboard_seq/32][271:256];end
     if({dut.core.trace_a_scale,dut.core.trace_a_q}!==expected_a)$fatal(1,"full actual A record mapping seq=%0d",scoreboard_seq);a_checks=a_checks+1;
    end
   end
   if(dut.core.trace_commit)begin
    scoreboard_s=dut.core.trace_block_s;scoreboard_seq=dut.core.trace_commit_seq;
    if(scoreboard_seq!=commits[scoreboard_s])$fatal(1,"full real PS acknowledgement order");commits[scoreboard_s]=commits[scoreboard_s]+1;
    if(scoreboard_seq>=cmd_k-32&&dut.core.trace_commit_data!==pre_bias[32*scoreboard_s+scoreboard_seq-(cmd_k-32)])$fatal(1,"full independent last-group PS s=%0d seq=%0d data0=%h gold0=%h",scoreboard_s,scoreboard_seq,dut.core.trace_commit_data[0],pre_bias[32*scoreboard_s+scoreboard_seq-(cmd_k-32)][31:0]);
   end
   if(dut.core.bias_read_fire)bias_reads[dut.core.ctx_s[dut.core.bias_ctx]]=bias_reads[dut.core.ctx_s[dut.core.bias_ctx]]+1;
   if(dut.core.bias_add_fire)bias_adds[dut.core.ctx_s[dut.core.add_req_tag[0][31]]]=bias_adds[dut.core.ctx_s[dut.core.add_req_tag[0][31]]]+1;
   if(dut.core.bias_write_ack)bias_acks[dut.core.ctx_s[dut.core.ps_wr_rsp_tag[31]]]=bias_acks[dut.core.ctx_s[dut.core.ps_wr_rsp_tag[31]]]+1;
   if(dut.core.state==2&&arithmetic_debt>arith_peak[dut.core.trace_block_s])arith_peak[dut.core.trace_block_s]=arithmetic_debt;
   if(out_held&&(!out_valid||out_data!==held_data||out_row!=held_row||out_col!=held_col||out_s!=held_s||out_request!=held_request||out_generation!=held_generation||out_epoch!=held_epoch))$fatal(1,"full public output hold");
   out_held=out_valid&&!out_ready;held_data=out_data;held_row=out_row;held_col=out_col;held_s=out_s;held_request=out_request;held_generation=out_generation;held_epoch=out_epoch;
   if(ps_held&&(!dut.core.ps_rd_rsp_valid||dut.core.ps_rd_rsp_tag!==held_ps_tag||dut.core.ps_rd_rsp_data!==held_ps_data||dut.core.ps_rd_rsp_mask!==held_ps_mask))$fatal(1,"merged PS response hold");
   ps_held=dut.core.ps_rd_rsp_valid&&!dut.core.ps_rd_rsp_ready;held_ps_tag=dut.core.ps_rd_rsp_tag;held_ps_data=dut.core.ps_rd_rsp_data;held_ps_mask=dut.core.ps_rd_rsp_mask;
   if(out_valid&&out_ready)begin
    scoreboard_s=outputs/256;scoreboard_seq=outputs%256;
    if(out_s!=scoreboard_s||out_row!=scoreboard_seq/2||out_col!=column(scoreboard_s,scoreboard_seq%2)||out_request!=cmd_request||out_generation!=cmd_generation||out_epoch!=cmd_epoch||out_data!==gold[outputs])$fatal(1,"full final output index=%0d s=%0d/%0d row=%0d col=%0d data0=%h gold0=%h",outputs,out_s,scoreboard_s,out_row,out_col,out_data[0],gold[outputs][31:0]);
    if(commits[scoreboard_s]!=cmd_k||(cmd_bias&&(bias_reads[scoreboard_s]!=32||bias_adds[scoreboard_s]!=32||bias_acks[scoreboard_s]!=32)))$fatal(1,"output before real math/bias acknowledgements s=%0d commit=%0d bias=%0d/%0d/%0d",scoreboard_s,commits[scoreboard_s],bias_reads[scoreboard_s],bias_adds[scoreboard_s],bias_acks[scoreboard_s]);
    outputs=outputs+1;retired[scoreboard_s]=retired[scoreboard_s]+1;output_cycle[scoreboard_s]=cycle;
    if(retired[scoreboard_s]==256)begin $display("MATRIX_PROGRESS real_retired_s=%0d final_outputs=%0d actual_commits=%0d bias_acks=%0d retire_debt_before_edge=%0d cycle=%0d",scoreboard_s,outputs,commits[scoreboard_s],bias_acks[scoreboard_s],dut.core.retire_debt,cycle);$fflush();end
    if(stress==0&&retired[scoreboard_s]==256&&cycle-accepted_cycle[scoreboard_s]>cmd_k+384)$fatal(1,"full per-block accept-to-last-output cap s=%0d elapsed=%0d",scoreboard_s,cycle-accepted_cycle[scoreboard_s]);
   end
   if(arithmetic_debt>64||dut.core.reserved_vectors>128||peak_return_reservations>128)$fatal(1,"full global arithmetic/return reservations");
   if(stress==0&&(dut.max_issue_commit>64||dut.max_ps_feedback>24))$fatal(1,"full arithmetic commit/feedback latency %0d/%0d",dut.max_issue_commit,dut.max_ps_feedback);
  end
  if(recovery_start>=0&&outputs<prefix*256&&cycle-recovery_start>4*cmd_k+2048)$fatal(1,"bounded new-identity recovery status=%0d topactive=%0d abort=%0d issue_next=%0d load_next=%0d load_pending=%0d corestate=%0d coreactive=%0d coreabort=%0d ctxbusy=%b Avalid=%b Aleased=%b Wvalid=%b Wleased=%b slot_ready=%b slot_in_use=%b I0=%0d C0=%0d",status,dut.active,dut.aborting,dut.issue_next,dut.load_next,dut.load_pending,dut.core.state,dut.core.matrix_active,dut.core.aborting,dut.core.ctx_busy,dut.a_slot_valid,dut.a_slot_leased,dut.w_slot_valid,dut.w_slot_leased,dut.slot_ready,dut.slot_in_use,issues[0],commits[0]);
  if(cycle>2000000)$fatal(1,"full bounded simulation cycle watchdog");
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
   bias_return_new_math_overlap=0;bias_write_contentions=0;outputs=0;w_checks=0;a_checks=0;prefetch_overlap=0;reuse_wait_cycles=0;output_hold_cycles=0;merged_hold_cycles=0;out_held=0;ps_held=0;
   groups=cmd_k/32;blocks=(cmd_n==5248)?82:cmd_n/64;cmd_tensor=which+1;
   for(integer p=0;p<4;p++)begin cmd_base[p]=64'h100000000+64'h10000000*p;cmd_span[p]=576*groups*blocks;end
   $readmemh({casepath,"/a_write.hex"},a_words,0,128*groups-1);$readmemh({casepath,"/output.hex"},gold,0,blocks*256-1);$readmemh({casepath,"/pre_bias.hex"},pre_bias,0,blocks*32-1);$readmemh({casepath,"/bias.hex"},bias_words,0,cmd_n/32-1);
   $readmemh({casepath,"/p0.hex"},mem0,0,9*groups*blocks-1);$readmemh({casepath,"/p1.hex"},mem1,0,9*groups*blocks-1);$readmemh({casepath,"/p2.hex"},mem2,0,9*groups*blocks-1);$readmemh({casepath,"/p3.hex"},mem3,0,9*groups*blocks-1);
   for(integer s=0;s<82;s++)begin issues[s]=0;commits[s]=0;first_issue[s]=-1;last_issue[s]=-1;retired[s]=0;bias_reads[s]=0;bias_adds[s]=0;bias_acks[s]=0;arith_peak[s]=0;accepted_cycle[s]=-1;output_cycle[s]=-1;end
  end
 endtask
 task automatic fill_a;
  integer fill_start;
  begin
   fill_start=cycle;
   @(negedge clk);acfg_slot=cmd_a_slot;acfg_k=cmd_k;acfg_request=cmd_request;acfg_generation=cmd_generation;acfg_epoch=cmd_epoch;acfg_valid=1;
   do begin @(posedge clk);if(cycle-fill_start>64)$fatal(1,"bounded A cfg ready req=%h filling=%0d cfgrsp=%0d wrsp=%0d leased=%b",cmd_request,dut.a_cache.filling,acfg_rsp_valid,awr_rsp_valid,dut.a_slot_leased);end while(!acfg_ready);$display("MATRIX_PROGRESS actual_A_cfg request=%h generation=%0d epoch=%0d slot=%0d",cmd_request,cmd_generation,cmd_epoch,cmd_a_slot);$fflush();@(negedge clk);acfg_valid=0;
   for(integer r=0;r<128;r++)for(integer g=0;g<groups;g++)begin @(negedge clk);awr_valid=1;awr_row=r;awr_group=g;awr_data=a_words[r*groups+g];awr_request=cmd_request;awr_generation=cmd_generation;awr_epoch=cmd_epoch;do begin @(posedge clk);if(cycle-fill_start>128*groups+512)$fatal(1,"bounded A write req=%h row=%0d group=%0d filling=%0d fill_count=%0d ready=%0d",cmd_request,r,g,dut.a_cache.filling,dut.a_cache.fill_count,awr_ready);end while(!awr_ready);end
   @(negedge clk);awr_valid=0;for(integer t=0;!acfg_rsp_valid;t++)begin @(negedge clk);if(t>32)$fatal(1,"bounded A publish req=%h filling=%0d count=%0d target=%0d wrsp=%0d",cmd_request,dut.a_cache.filling,dut.a_cache.fill_count,dut.a_cache.target_count,awr_rsp_valid);end
   $display("MATRIX_PROGRESS actual_A_publication request=%h generation=%0d slot=%0d",cmd_request,cmd_generation,cmd_a_slot);$fflush();@(negedge clk);if(acfg_status!=0)$fatal(1,"full real A preload");acfg_rsp_ready=1;@(negedge clk);acfg_rsp_ready=0;
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
  begin @(negedge clk);cmd_valid=1;submit_start=cycle;do begin @(posedge clk);if(cycle-submit_start>256)$fatal(1,"bounded full command ready active=%0d done=%0d corestate=%0d",dut.active,done_valid,dut.core.state);end while(!cmd_ready);@(negedge clk);cmd_valid=0;end
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
    $display("M007_FULL_COEFFICIENT_IDENTITY_PASS original_model_restored=1 zero_AR=1");
   end
  end
 endtask
 task automatic report_blocks(input integer count);
  begin
   for(integer ss=0;ss<count;ss++)begin
    if(issues[ss]!=cmd_k||commits[ss]!=cmd_k||retired[ss]!=256||(!stress&&last_issue[ss]-first_issue[ss]+1!=cmd_k))$fatal(1,"full block event/continuous coverage s=%0d I=%0d C=%0d O=%0d span=%0d",ss,issues[ss],commits[ss],retired[ss],last_issue[ss]-first_issue[ss]+1);
    $display("M007_FULL_BLOCK_PASS s=%0d ctx=%0d issue_span=%0d gap_from_previous=%0d bias_read=%0d bias_add=%0d bias_ack=%0d peak_arithmetic=%0d accept_to_last_output=%0d",ss,ss%2,last_issue[ss]-first_issue[ss]+1,ss?first_issue[ss]-last_issue[ss-1]-1:0,bias_reads[ss],bias_adds[ss],bias_acks[ss],arith_peak[ss],output_cycle[ss]-accepted_cycle[ss]);
   end
   if(compute_output_overlap==0||ps_merged_reads==0||prefetch_overlap==0)$fatal(1,"full genuine compute/PS/output/W overlap missing");
   for(integer p=0;p<4;p++)if(peer_peak[p]!=8)$fatal(1,"full eight actual AXI ID outstanding coverage");
   if(stress==1&&(ps_response_holds==0||merged_hold_cycles==0||reuse_wait_cycles==0||output_hold_cycles==0))$fatal(1,"full affected hold/reuse coverage missing holds=%0d merged=%0d reuse=%0d output=%0d",ps_response_holds,merged_hold_cycles,reuse_wait_cycles,output_hold_cycles);
   if(cmd_bias)begin
    if(bias_return_new_math_overlap==0)$fatal(1,"actual old-context bias acknowledgement/new-context math issue overlap missing");
    $display("M007_FULL_BIAS_OVERLAP_PASS actual_bias_ack_new_issue=%0d shared_add_conflicts=%0d shared_PS_write_conflicts=%0d",bias_return_new_math_overlap,bias_add_conflicts,bias_write_contentions);
   end
   if(stress==1)$display("M007_FULL_STRESS_PASS merged_hold=%0d ctx_reuse_wait=%0d output_hold=%0d bias_math_conflicts=%0d",merged_hold_cycles,reuse_wait_cycles,output_hold_cycles,bias_add_conflicts);
  end
 endtask
 task automatic held_done_check(input logic [2:0] expected_status);
  begin
   @(negedge clk);cmd_valid=1;
   repeat(5)begin @(negedge clk);if(!done_valid||status!=expected_status||cmd_ready||out_valid)$fatal(1,"full held done/new command barrier status=%0d",status);end
   cmd_valid=0;done_ready=1;@(negedge clk);done_ready=0;
  end
 endtask
 task automatic directed_fault;
  integer error_issue_count,drain_cycle;
  begin
   peer_fault=1;fault_injected=0;submit;
   wait(fault_injected);error_issue_count=issues[0];drain_cycle=cycle;
   wait(done_valid);@(negedge clk);
   if(!fault_injected||actual_fault_accepts!=1||status!=3||blocks_issued!=1||issues[1]!=0||outputs!=0||issues[0]==0||commits[0]!=issues[0]||dut.a_slot_leased!=0||dut.w_slot_leased!=0||dut.a_read_debt!=0||arithmetic_debt!=0||dut.core.bias_debt!=0||dut.core.retire_debt!=0||dut.load_pending||live[0]!=0||live[1]!=0||live[2]!=0||live[3]!=0)$fatal(1,"full W prefetch failure isolation/drain status=%0d issued=%0d I0=%0d C0=%0d O=%0d live=%h/%h/%h/%h",status,blocks_issued,issues[0],commits[0],outputs,live[0],live[1],live[2],live[3]);
   $display("M007_FULL_PREFETCH_ERROR_PASS actual_accepted_fault=1 block0_issue_at_fault=%0d accepted_math=%0d committed_math=%0d drain_cycles=%0d error_col=%0d group=%0d stage=%0d",error_issue_count,issues[0],commits[0],cycle-drain_cycle,error_col,error_group,error_stage);
   held_done_check(3);peer_fault=0;
   // No reset here: a new tensor, values, slot and complete identity must recover.
   which=1;cmd_request=cmd_request+64'h100;cmd_generation=cmd_generation+1;cmd_epoch=cmd_epoch+1;cmd_a_slot=1;prepare;fill_a;fill_coef;submit;recovery_start=cycle;
  end
 endtask
 task automatic directed_reset;
  integer live_math,live_a,live_axi;
  begin
   submit;
   wait(issues[0]>=64&&arithmetic_debt>0&&dut.a_read_debt>0&&(live[0]!=0||live[1]!=0||live[2]!=0||live[3]!=0));
   live_math=arithmetic_debt;live_a=dut.a_read_debt;live_axi=$countones(live[0])+$countones(live[1])+$countones(live[2])+$countones(live[3]);
   @(negedge clk);rst_n=0;cmd_valid=0;peer_fault=0;out_held=0;ps_held=0;
   repeat(5)@(negedge clk);rst_n=1;
   repeat(12)begin @(negedge clk);if(out_valid||done_valid||arvalid!=0||acfg_rsp_valid||awr_rsp_valid||dut.a_slot_leased!=0||dut.w_slot_leased!=0||arithmetic_debt!=0||dut.a_read_debt!=0)$fatal(1,"full reset stale valid/debt");end
   $display("M007_FULL_COMMON_RESET_PASS live_math=%0d live_A=%0d live_AXI=%0d stale_free_clocks=12",live_math,live_a,live_axi);
   which=1;cmd_request=cmd_request+64'h200;cmd_generation=cmd_generation+2;cmd_epoch=cmd_epoch+2;cmd_a_slot=1;prepare;fill_a;fill_coef;submit;
  end
 endtask
 initial begin
  clk=0;rst_n=0;cmd_valid=0;cmd_version=1;cmd_request=64'h2200000001;cmd_model=64'h6eb6ef58bc4f99bd;cmd_generation=1;cmd_epoch=1;cmd_a_slot=0;done_ready=0;out_ready=1;run_enable=1;
  acfg_valid=0;acfg_rsp_ready=0;awr_valid=0;awr_rsp_ready=1;coef_cfg_valid=0;coef_wr_valid=0;coef_rsp_ready=0;rvalid=0;rid=0;rdata=0;rresp=0;rlast=0;last_r_fire=0;
  if(!$value$plusargs("FIXTURE=%s",fixture))$fatal(1,"FIXTURE required");if(!$value$plusargs("CASE=%d",which))which=0;if(!$value$plusargs("PREFIX=%d",prefix))prefix=3;if(!$value$plusargs("STRESS=%d",stress))stress=0;
  prepare;repeat(5)@(negedge clk);rst_n=1;fill_a;fill_coef;invalid_coefficient_identity;invalid_span;
  if(stress==2)directed_fault;else if(stress==3)directed_reset;else submit;
  if(prefix!=0)begin
   wait(outputs==prefix*256);@(negedge clk);report_blocks(prefix);
   $display("M007_FULL_PREFIX_PASS case=%0d blocks=%0d total_cycles=%0d matrix_cycles=%0d first_output=%0d merged_reads=%0d response_holds=%0d bias_conflicts=%0d compute_output_overlap=%0d W_prefetch_R_overlap=%0d peak_arithmetic=%0d peak_return=%0d",which,prefix,cycle,dut.tick,first_output_cycle,ps_merged_reads,ps_response_holds,bias_add_conflicts,compute_output_overlap,prefetch_overlap,peak_arithmetic_reservations,peak_return_reservations);
   $display("HARDWARE_AGENT_SIM_PASS M007_MATRIX_FULL_PREFIX case=%0d",which);$finish;
  end else begin
   wait(done_valid);@(negedge clk);report_blocks(blocks);
   if(status!=0||done_request!=cmd_request||done_generation!=cmd_generation||done_epoch!=cmd_epoch||outputs!=blocks*256||blocks_issued!=blocks||blocks_computed!=blocks||blocks_retired!=blocks||dut.a_slot_leased!=0||dut.w_slot_leased!=0||dut.a_read_debt!=0||arithmetic_debt!=0||dut.load_pending||live[0]!=0||live[1]!=0||live[2]!=0||live[3]!=0)$fatal(1,"full done status/identity/output/debt coverage status=%0d outputs=%0d issued=%0d computed=%0d retired=%0d",status,outputs,blocks_issued,blocks_computed,blocks_retired);
   if(stress==0)begin
    integer cap;case(which)0,6:cap=53120;1,7:cap=18304;2:cap=87936;3:cap=45952;default:cap=69504;endcase
    if(elapsed_cycles>cap||first_output_cycle>((cmd_k==1024)?1024:(cmd_k==2624)?2224:3328)+cmd_k+192)$fatal(1,"full matrix service cap elapsed=%0d cap=%0d first_output=%0d",elapsed_cycles,cap,first_output_cycle);
   end
   for(integer p=0;p<4;p++)if(r_total[p]!=9*groups*blocks)$fatal(1,"full exact accepted W bytes");
   held_done_check(0);
   $display("M007_FULL_MATRIX_PASS case=%0d K=%0d N=%0d blocks=%0d final_values=%0d total_cycles=%0d matrix_cycles=%0d first_output=%0d W_wait=%0d ctx_wait=%0d merged_reads=%0d bias_conflicts=%0d compute_output_overlap=%0d peak_arithmetic=%0d peak_return=%0d",which,cmd_k,cmd_n,blocks,128*cmd_n,cycle,elapsed_cycles,first_output_cycle,w_wait_cycles,ctx_wait_cycles,ps_merged_reads,bias_add_conflicts,compute_output_overlap,peak_arithmetic_reservations,peak_return_reservations);
   done_ready=1;@(negedge clk);$display("HARDWARE_AGENT_SIM_PASS M007_MATRIX_FULL case=%0d",which);$finish;
  end
 end
endmodule
