`timescale 1ns/1ps
module m007_control_arena_engine_tb;
 logic clk=0;always #1.6665 clk=~clk;logic rst_n=0;
 logic bind_valid=0,bind_ready,resources_bound,release_valid=0,release_ready;
 logic [63:0] request_id=64'h123456789abcdef0,rsp_request_id;
 logic [31:0] generation=7,epoch=9,rsp_generation,rsp_epoch;
 logic cmd_valid=0,cmd_ready,fill_valid=0,fill_ready,fill_slot=0,fill_half=0;
 logic [6:0] fill_s=0,fill_row=0;logic [31:0][31:0] fill_data=0;
 logic fill_reject_valid;logic [1:0] fill_reject_code;
 logic out_valid,out_ready=1;logic [7:0][31:0] out_data,out_status;logic [95:0] out_tag;
 logic [6:0] out_s,out_row;logic [1:0] out_chunk;
 logic done_valid,done_ready=0;logic [31:0] done_status;logic [2:0] done_error_rank;
 logic [6:0] done_error_row;logic [11:0] done_error_column;
 logic discard_valid=0,discard_ready,discard_reject_valid;
 logic engine_idle,active,needs_discard,protocol_fault;
 logic [1:0] slot_active,slot_ready;logic [1:0][6:0] slot_s;
 logic [1:0][9:0] slot_consumed_vectors;
 logic [1:0][8:0] slot_math_pending,slot_sfu_debt;logic [1:0][7:0] slot_fp_debt;
 logic [7:0][18:0] covered,evaluated;logic [8:0] sfu_pending,sfu_flight;
 logic slot_release_fire,slot_release_slot;logic [6:0] slot_release_s;
 logic g_wr_valid,g_wr_ready,g_wr_rsp_valid,g_wr_rsp_ready,g_rd_valid,g_rd_ready,g_rd_rsp_valid,g_rd_rsp_ready;
 logic [95:0] g_wr_rsp_tag,g_rd_tag,g_rd_rsp_tag;
 logic [8:0] fp_rsp_valid;logic [8:0][95:0] fp_rsp_tag;logic [8:0][7:0][31:0] fp_rsp_data,fp_rsp_status;
 logic sfu_rsp_valid,sfu_rsp_ready;logic [95:0] sfu_rsp_tag;logic [7:0] sfu_rsp_mask;
 logic [7:0][31:0] sfu_rsp_data,sfu_rsp_status;
 m007_control_arena_validation_shell dut(.*);
 logic owner_req_valid=0,owner_req_g=0,owner_req_ready,a_enable,g_enable,rearm,owner_g;
 logic  a_prepare_valid='0;
 logic  a_prepare_ready;
 logic  a_qkv_wr_valid='0;
 logic  a_qkv_wr_ready;
 logic [1:0] a_qkv_wr_plane='0;
 logic [3:0] a_qkv_wr_head='0;
 logic [6:0] a_qkv_wr_token='0;
 logic  a_qkv_wr_half='0;
 logic [31:0][31:0] a_qkv_wr_data='0;
 logic  a_prepare_cancel_valid='0;
 logic  a_prepare_cancel_ready;
 logic  a_prepare_cancel_rsp_valid;
 logic  a_prepare_cancel_rsp_ready='0;
 logic  a_layer_idle;
 task automatic edge_step;@(posedge clk);#0.01;endtask
 task automatic prep;
  @(negedge clk);a_prepare_valid=1;owner_req_valid=1;owner_req_g=1;#0.01;
  if(owner_req_ready)$fatal(1,"CONCURRENT_PREP_SWITCH_RACE");
  if(!a_prepare_ready)$fatal(1,"ACTUAL_LAYER_PREP_NOT_READY state=%0d real_idle=%0d h_ready=%0d q_ready=%0d bind=%0d lease=%0d",dut.joint.layer.state,dut.joint.layer.real_idle,dut.joint.layer.h_prepare_ready,dut.joint.layer.head.q_prepare_ready,dut.a_res_st_bind_ready,dut.a_res_fp_lease_ready);edge_step();@(negedge clk);a_prepare_valid=0;owner_req_valid=0;
  if(dut.joint.state_q!==0)$fatal(1,"PREP_COVERAGE_NOT_CLEAR");
 endtask
 task automatic write_coverage(input int index);
  @(negedge clk);a_qkv_wr_valid=1;a_qkv_wr_half=1'(index%2);a_qkv_wr_token=7'((index/2)%128);a_qkv_wr_plane=2'((index/256)%3);a_qkv_wr_head=4'(index/768);a_qkv_wr_data={32{32'h3f800000}};#0.01;
  if(!a_qkv_wr_ready)$fatal(1,"REAL_QKV_WRITE_NOT_READY");edge_step();@(negedge clk);a_qkv_wr_valid=0;
  if(dut.joint.state_q[index]!==1)$fatal(1,"ACTUAL_LAYER_COVERAGE index=%0d",index);
 endtask
 task automatic cancel_and_hold;
  @(negedge clk);a_prepare_cancel_valid=1;#0.01;if(!a_prepare_cancel_ready)$fatal(1,"CANCEL_NOT_READY");edge_step();@(negedge clk);a_prepare_cancel_valid=0;
  repeat(17)begin edge_step();if(!a_prepare_cancel_rsp_valid||owner_req_ready||dut.joint.state_q!==0)$fatal(1,"HELD_CANCEL_SWITCH_BARRIER");end
  @(negedge clk);a_prepare_cancel_rsp_ready=1;edge_step();@(negedge clk);a_prepare_cancel_rsp_ready=0;
  if(!a_layer_idle)$fatal(1,"CANCEL_NOT_ACTUALLY_IDLE");
 endtask
 task automatic switch_owner(input bit target);
  @(negedge clk);owner_req_valid=1;owner_req_g=target;#0.01;
  if(!owner_req_ready)$fatal(1,"ACTUAL_RETIREMENT_NOT_READY target=%0d a=%0d g=%0d",target,dut.joint.a_retired,dut.joint.g_retired);edge_step();
  if(!rearm||a_enable||g_enable||dut.joint.state_q!==0)$fatal(1,"ACTUAL_REARM");
  @(negedge clk);owner_req_valid=0;edge_step();
  if(rearm||g_enable!=target||a_enable==target||dut.joint.state_q!==0)$fatal(1,"ACTUAL_ENABLE_AFTER_REARM");
 endtask
 task automatic layer_prefix;
  prep();write_coverage(0);write_coverage(1);write_coverage(255);write_coverage(256);write_coverage(4095);write_coverage(4096);write_coverage(12287);write_coverage(0);write_coverage(12287);
  if($countones(dut.joint.state_q)!=7)$fatal(1,"DUPLICATE_OR_BOUNDARY_COVERAGE");
  @(negedge clk);owner_req_valid=1;owner_req_g=0;edge_step();if(rearm||$countones(dut.joint.state_q)!=7)$fatal(1,"ACTUAL_SAME_OWNER_CLEARED");
  @(negedge clk);owner_req_g=1;repeat(3)begin edge_step();if(owner_req_ready||rearm||g_enable)$fatal(1,"PREP_EARLY_SWITCH");end
  cancel_and_hold();owner_req_valid=0;switch_owner(1);
  $display("CONTROL_A_TO_G_PASS coverage_unique=7 real_qkv_writes=9 cancel_held=17");
 endtask
 task automatic layer_return;
  switch_owner(0);prep();write_coverage(12287);write_coverage(0);
  if($countones(dut.joint.state_q)!=2)$fatal(1,"RETURN_A_COVERAGE_RELOAD");
  owner_req_g=1;owner_req_valid=1;cancel_and_hold();owner_req_valid=0;
  $display("CONTROL_G_TO_A_PASS actual_done_consumed=1 resources_retired=1 coverage_reload=2");
 endtask
 always @(posedge clk)if(rst_n)begin
  if(!a_enable&&(a_prepare_ready||a_qkv_wr_ready||a_prepare_cancel_rsp_valid||dut.a_res_qkv_wr_valid||dut.a_res_qkv_rd_valid||dut.a_done_valid||dut.a_cache_rd_valid))$fatal(1,"INACTIVE_LAYER_PUBLISHED");
  if(!g_enable&&(out_valid||done_valid||dut.fp_req_valid||dut.sfu_req_valid||g_wr_valid||g_rd_valid||dut.pool_reset_n))$fatal(1,"INACTIVE_G_PUBLISHED");
  if(dut.a_start_valid||dut.a_res_fp_mul_req_valid||dut.a_res_sfu_req_valid)$fatal(1,"LAYER_LOCAL_MUST_NOT_LAUNCH_ARITHMETIC");
 end
 logic [383:0] vectors[0:335871];string vf,pf;integer progress_fd;
 int groups,mode,cycles=0,cmd_cycle=-1,issued=0,consumed=0,released=0,writes=0,write_acks=0,node_checks=0;
 int first_ready[0:81],eligible[0:81],first_read[0:81],last_read[0:81],last_consume[0:81],release_cycle[0:81];
 int first_output=-1,last_output=-1,max_read_gap=0,max_output_gap=0,overlap=0,independent_release=0,held_cycles=0,peak=0,done_cycle=-1;
 int read_count[0:81],output_count[0:81];bit hold_started=0,hold_finished=0;
 logic holding=0;logic [607:0] held_record;
 task automatic emit_progress;
  $fdisplay(progress_fd,"{\"schema\":\"m007-tanh-consumed-v1\",\"checked\":%0d,\"node_checks\":%0d,\"cycle\":%0d,\"phase\":1,\"returned\":%0d}",consumed*8,node_checks,cycles,consumed);$fflush(progress_fd);
 endtask
 initial begin
  if(!$value$plusargs("VECTORS=%s",vf)||!$value$plusargs("PROGRESS_FILE=%s",pf)||!$value$plusargs("GROUPS=%d",groups)||!$value$plusargs("MODE=%d",mode)||groups<3||groups>82||mode<0||mode>1)$fatal(1,"ARGS");
  for(int g=0;g<82;g++)begin first_ready[g]=-1;eligible[g]=-1;first_read[g]=-1;last_read[g]=-1;last_consume[g]=-1;release_cycle[g]=-1;read_count[g]=0;output_count[g]=0;end
  $readmemh(vf,vectors);progress_fd=$fopen(pf,"w");if(!progress_fd)$fatal(1,"PROGRESS_OPEN");
  repeat(5)@(negedge clk);rst_n=1;layer_prefix();bind_valid=1;#0.001;
  while(!bind_ready)begin @(negedge clk);#0.001;end
  @(posedge clk);@(negedge clk);bind_valid=0;
  if(!resources_bound)$fatal(1,"ACTUAL_RESOURCE_BIND");cmd_valid=1;#0.001;
  while(!cmd_ready)begin @(negedge clk);#0.001;end
  @(posedge clk);@(negedge clk);cmd_valid=0;
  // Only the producer schedules fills; the production FSM independently
  // dispatches all s/row/chunk reads from a single complete-task command.
  for(int g=0;g<groups;g++)for(int h=0;h<2;h++)for(int r=0;r<128;r++)begin
   @(negedge clk);fill_valid=1;fill_slot=g%2;fill_s=7'(g);fill_half=1'(h);fill_row=7'(r);
   for(int c=0;c<32;c++)fill_data[c]=vectors[r*2624+g*32+c][383-h*32-:32];
   #0.001;while(!fill_ready)begin @(negedge clk);#0.001;end
  end
  @(negedge clk);fill_valid=0;
  wait(consumed==groups*512&&released==groups);repeat(3)@(negedge clk);
  if(issued!=groups*512||writes!=groups*256||write_acks!=writes||sfu_pending||sfu_flight||slot_active||slot_math_pending||slot_sfu_debt||slot_fp_debt||protocol_fault||needs_discard)$fatal(1,"FINAL_REAL_DEBT");
  for(int rank=0;rank<8;rank++)if(covered[rank]!=groups*4096||evaluated[rank]!=groups*4096)$fatal(1,"COVERAGE rank=%0d covered=%0d evaluated=%0d",rank,covered[rank],evaluated[rank]);
  if(overlap==0||independent_release==0)$fatal(1,"MISSING_REAL_OVERLAP");
  if(mode==1&&held_cycles!=17)$fatal(1,"HELD_COUNT got=%0d",held_cycles);
  if(mode==0&&(max_read_gap!=1||max_output_gap!=1))$fatal(1,"CROSS_S_GAP read=%0d out=%0d",max_read_gap,max_output_gap);
  if(first_output-eligible[0]>256)$fatal(1,"FIRST_OUTPUT");
  for(int g=0;g<groups;g++)begin
   if(first_read[g]<eligible[g]||first_read[g]>eligible[g]+1||last_consume[g]<first_read[g]||release_cycle[g]<last_consume[g])$fatal(1,"TIMING_ORDER s=%0d",g);
   if(mode==0&&release_cycle[g]-eligible[g]>768)$fatal(1,"BLOCK_768 s=%0d cycles=%0d",g,release_cycle[g]-eligible[g]);
   $display("G_BLOCK s=%0d first_ready=%0d eligible=%0d first_read=%0d last_consume=%0d release=%0d queued_wait=%0d service_cycles=%0d",g,first_ready[g],eligible[g],first_read[g],last_consume[g],release_cycle[g],eligible[g]-first_ready[g],release_cycle[g]-eligible[g]);
  end
  if(groups==82)begin
   wait(done_valid);@(negedge clk);
   if(done_status||done_error_rank||done_error_row||done_error_column||active)$fatal(1,"FULL_DONE_ERROR");
   repeat(17)begin @(negedge clk);if(!done_valid||done_status||cmd_ready||rsp_request_id!=request_id||rsp_generation!=generation||rsp_epoch!=epoch)$fatal(1,"DONE_HELD");end
   if(mode==0&&done_cycle-eligible[0]>42240)$fatal(1,"FULL_42240 cycles=%0d",done_cycle-eligible[0]);
   done_ready=1;@(posedge clk);@(negedge clk);done_ready=0;
   if(!engine_idle)$fatal(1,"POST_DONE_NOT_IDLE");release_valid=1;#0.001;
   while(!release_ready)begin @(negedge clk);#0.001;end
   @(posedge clk);@(negedge clk);release_valid=0;if(resources_bound)$fatal(1,"RESOURCE_RELEASE");layer_return();
  end else begin
   if(!active||done_valid||engine_idle)$fatal(1,"PREFIX_MUST_RETAIN_WAITING_COMMAND");
   @(negedge clk);owner_req_valid=1;owner_req_g=0;repeat(3)begin edge_step();if(owner_req_ready||rearm||!g_enable)$fatal(1,"ACTIVE_G_EARLY_SWITCH");end
   @(negedge clk);owner_req_valid=0;
  end
  $fclose(progress_fd);
  $display("HARDWARE_AGENT_SIM_PASS G_ENGINE groups=%0d checked=%0d node_checks=%0d prefix=%0d writes=%0d write_acks=%0d read_vectors=%0d releases=%0d first_actual_consume=%0d full_done_cycles=%0d max_read_gap=%0d max_output_gap=%0d actual_overlap=%0d independent_slot_release=%0d held_final17=%0d pending_peak=%0d all_accepted_debt_zero=1",groups,consumed*8,node_checks,groups!=82,writes,write_acks,issued,released,first_output-eligible[0],done_cycle<0?0:done_cycle-eligible[0],max_read_gap,max_output_gap,overlap,independent_release,held_cycles,peak);$finish;
 end
 // Hold the actual last result of s0. Filling s2 is already waiting on slot0;
 // it must remain blocked while the other slot has genuine accepted work.
 always @(negedge clk)begin
  if(rst_n&&mode==1&&!hold_finished&&out_valid&&out_tag[15:0]==511)begin
   if(!hold_started)begin hold_started=1;out_ready=0;end
   else if(held_cycles==17)begin hold_finished=1;out_ready=1;end
  end
 end
 always @(posedge clk)begin
  cycles=cycles+1;if(cycles>100000)$fatal(1,"TIMEOUT");
  if(rst_n)begin
   if(protocol_fault||fill_reject_valid||discard_reject_valid)$fatal(1,"PROTOCOL_FAULT code=%0d",fill_reject_code);
   if(cmd_valid&&cmd_ready)cmd_cycle=cycles;
   if(done_valid&&done_cycle<0)done_cycle=cycles;
   if(g_wr_valid&&g_wr_ready)writes=writes+1;
   if(g_wr_rsp_valid&&g_wr_rsp_ready)begin
    write_acks=write_acks+1;
    if(g_wr_rsp_tag[1]&&g_wr_rsp_tag[8:2]==127)first_ready[g_wr_rsp_tag[15:9]]=cycles;
   end
   if(g_wr_valid&&g_wr_ready&&g_rd_valid&&g_rd_ready)overlap=overlap+1;
   if(g_rd_valid&&g_rd_ready)begin
    int g;g=int'(g_rd_tag[15:9]);
    if(g_rd_tag[95:64]!=generation||g_rd_tag[63:32]!=epoch||g_rd_tag[15:0]!=issued)$fatal(1,"READ_IDENTITY");
    if(read_count[g]==0)first_read[g]=cycles;
    if(issued>0&&cycles-last_read[(issued-1)/512]>max_read_gap)max_read_gap=cycles-last_read[(issued-1)/512];
    last_read[g]=cycles;read_count[g]=read_count[g]+1;issued=issued+1;
   end
   for(int g=0;g<groups;g++)if(eligible[g]<0&&first_ready[g]>=0)begin
    if(g==0&&cmd_cycle>=0)eligible[g]=first_ready[g]>cmd_cycle?first_ready[g]:cmd_cycle;
    else if(g>0&&read_count[g-1]==512)eligible[g]=first_ready[g]>last_read[g-1]+1?first_ready[g]:last_read[g-1]+1;
   end
   for(int n=0;n<9;n++)if(fp_rsp_valid[n])begin
    int gold_word,vi,si;logic [31:0] expected,observed;
    gold_word=n==0?2:n==1?3:n==2?4:n==3?5:n==4?6:n==5?8:n==6?9:n==7?10:11;vi=int'(fp_rsp_tag[n][15:0]);
    for(int l=0;l<8;l++)begin
     si=((vi%512)/4)*2624+(vi/512)*32+(vi%4)*8+l;expected=vectors[si][383-gold_word*32-:32];observed=fp_rsp_data[n][l];
     if(observed!==expected||fp_rsp_status[n][l]!==0)$fatal(1,"FP_NODE n=%0d vi=%0d lane=%0d got=%h expected=%h",n,vi,l,observed,expected);node_checks=node_checks+1;
    end
   end
   if(sfu_rsp_valid&&sfu_rsp_ready)begin
    int vi,si;logic [31:0] expected,observed;vi=int'(sfu_rsp_tag[15:0]);
    if(sfu_rsp_mask!==8'hff)$fatal(1,"TANH_MASK");
    for(int l=0;l<8;l++)begin
     si=((vi%512)/4)*2624+(vi/512)*32+(vi%4)*8+l;expected=vectors[si][159:128];observed=sfu_rsp_data[l];
     if(observed!==expected||sfu_rsp_status[l]!==0)$fatal(1,"TANH_H vi=%0d lane=%0d got=%h expected=%h",vi,l,observed,expected);node_checks=node_checks+1;
    end
   end
   if(holding&&(!out_valid||{out_data,out_status,out_tag}!==held_record))$fatal(1,"HELD_RESULT_CHANGED");
   holding=out_valid&&!out_ready;if(holding)begin
    held_record={out_data,out_status,out_tag};held_cycles=held_cycles+1;
    if(!slot_active[0]||slot_s[0]!=0||slot_consumed_vectors[0]!=511||slot_math_pending[0]==0||!fill_valid||fill_s!=2||fill_ready)$fatal(1,"HELD_SLOT_REUSE");
   end
   if(out_valid&&out_ready)begin
    int si,g;logic [7:0][31:0] expected;g=consumed/512;
    if(out_tag[95:64]!=generation||out_tag[63:32]!=epoch||out_tag[15:0]!=consumed||out_s!=g||out_row!=(consumed%512)/4||out_chunk!=consumed%4)$fatal(1,"OUTPUT_IDENTITY");
    for(int l=0;l<8;l++)begin si=((consumed%512)/4)*2624+(consumed/512)*32+(consumed%4)*8+l;expected[l]=vectors[si][31:0];end
    if(out_data!==expected||out_status!==256'b0)$fatal(1,"OUTPUT vi=%0d got=%h expected=%h status=%h",consumed,out_data,expected,out_status);
    if(first_output<0)first_output=cycles;if(last_output>=0&&cycles-last_output>max_output_gap)max_output_gap=cycles-last_output;last_output=cycles;
    last_consume[g]=cycles;output_count[g]=output_count[g]+1;consumed=consumed+1;
    if(consumed%128==0)emit_progress();
   end
   if(slot_release_fire)begin
    int g,other;g=int'(slot_release_s);other=1-int'(slot_release_slot);
    if(output_count[g]!=512||slot_math_pending[slot_release_slot]||slot_sfu_debt[slot_release_slot]||slot_fp_debt[slot_release_slot])$fatal(1,"RELEASE_WITH_REAL_DEBT");
    if(slot_math_pending[other]>0&&slot_sfu_debt[other]>0)independent_release=independent_release+1;
    release_cycle[g]=cycles;released=released+1;
   end
   if(int'(slot_math_pending[0])+int'(slot_math_pending[1])>peak)peak=int'(slot_math_pending[0])+int'(slot_math_pending[1]);
  end
 end
endmodule
