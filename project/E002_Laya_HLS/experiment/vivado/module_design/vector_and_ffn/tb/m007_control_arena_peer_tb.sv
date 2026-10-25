`timescale 1ns/1ps
module m007_control_arena_peer_tb;
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
 logic peer_enable=1,peer_injected;
 m007_control_arena_peer_shell dut(.*);
 logic [383:0] vectors[0:335871];string vf,pf;integer progress_fd;
 int cycles=0,phase=0,accepted=0,consumed=0,released=0,writes=0,acks=0,reads=0,returns=0,injects=0,peer_outputs=0;
 int total_checked=0,node_checks=0,main_accepted=0,main_reads=0,main_writes=0,held_done=0;
 task automatic progress;
  $fdisplay(progress_fd,"{\"schema\":\"m007-tanh-consumed-v1\",\"checked\":%0d,\"node_checks\":%0d,\"cycle\":%0d,\"phase\":1,\"returned\":%0d}",total_checked,node_checks,cycles,total_checked/8);$fflush(progress_fd);
 endtask
 task automatic bind_resources;
  @(negedge clk);bind_valid=1;#0.001;while(!bind_ready)begin @(negedge clk);#0.001;end
  @(posedge clk);@(negedge clk);bind_valid=0;if(!resources_bound)$fatal(1,"ACTUAL_BIND");
 endtask
 task automatic command;
  @(negedge clk);cmd_valid=1;#0.001;while(!cmd_ready)begin @(negedge clk);#0.001;end
  @(posedge clk);@(negedge clk);cmd_valid=0;
 endtask
 task automatic produce(input int group_count);
  for(int i=0;i<group_count*256&&!protocol_fault;i++)begin
   int g,h,r;g=i/256;h=(i%256)/128;r=i%128;
   @(negedge clk);
   if(!protocol_fault)begin
    fill_valid=1;fill_slot=g%2;fill_s=7'(g);fill_half=1'(h);fill_row=7'(r);
    for(int c=0;c<32;c++)fill_data[c]=vectors[r*2624+g*32+c][383-h*32-:32];
    #0.001;while(!fill_ready&&!protocol_fault)begin @(negedge clk);#0.001;end
   end
  end
  @(negedge clk);fill_valid=0;
 endtask
 task automatic debt_zero;
  if(writes!=acks||reads!=returns||sfu_pending||sfu_flight||slot_math_pending||slot_sfu_debt||slot_fp_debt)$fatal(1,"REAL_OWNED_DEBT");
 endtask
 initial begin
  if(!$value$plusargs("VECTORS=%s",vf)||!$value$plusargs("PROGRESS_FILE=%s",pf))$fatal(1,"ARGS");
  $readmemh(vf,vectors);progress_fd=$fopen(pf,"w");if(!progress_fd)$fatal(1,"PROGRESS_OPEN");
  repeat(5)@(negedge clk);rst_n=1;bind_resources();command();produce(2);wait(done_valid);repeat(3)@(negedge clk);
  debt_zero();main_accepted=accepted;main_reads=reads;main_writes=writes;
  if(done_status!=8||!needs_discard||active||!protocol_fault||injects!=1||peer_outputs!=1||accepted!=consumed||accepted<65||accepted>=512||slot_active==0||dut.engine.math.first_error_valid)$fatal(1,"PEER_DONE_VERDICT accepted=%0d consumed=%0d status=%0d",accepted,consumed,done_status);
  for(int rank=0;rank<8;rank++)if(covered[rank]!=accepted*8||covered[rank]==335872)$fatal(1,"NO_FAKE_FULL_COVERAGE");
  progress();
  repeat(17)begin @(negedge clk);held_done=held_done+1;if(!done_valid||done_status!=8||cmd_ready||rsp_generation!=generation||rsp_epoch!=epoch)$fatal(1,"HELD_PEER_DONE");end
  done_ready=1;@(posedge clk);@(negedge clk);done_ready=0;discard_valid=1;#0.001;
  while(!discard_ready)begin @(negedge clk);#0.001;end
  @(posedge clk);@(negedge clk);discard_valid=0;
  if(needs_discard||!engine_idle||slot_active||protocol_fault||covered||evaluated)$fatal(1,"EXPLICIT_PARTIAL_DISCARD");
  release_valid=1;#0.001;while(!release_ready)begin @(negedge clk);#0.001;end
  @(posedge clk);@(negedge clk);release_valid=0;
  generation=generation+1;epoch=epoch+1;phase=1;peer_enable=0;accepted=0;consumed=0;released=0;writes=0;acks=0;reads=0;returns=0;
  bind_resources();command();produce(3);wait(consumed==1536&&released==3);repeat(3)@(negedge clk);debt_zero();
  if(accepted!=1536||protocol_fault||needs_discard||!active||done_valid||slot_active||rsp_generation!=generation)$fatal(1,"RECOVERY_PREFIX");
  for(int rank=0;rank<8;rank++)if(covered[rank]!=12288||evaluated[rank]!=12288)$fatal(1,"RECOVERY_COVERAGE");
  if(node_checks!=(main_accepted+1536)*80-10)$fatal(1,"NODE_EXACT_COUNT got=%0d expected=%0d",node_checks,(main_accepted+1536)*80-10);
  $fclose(progress_fd);$display("HARDWARE_AGENT_SIM_PASS G_PEER main_accepted_vectors=%0d main_read_vectors=%0d main_writes=%0d partial_done8=1 matching_real_return_fault=1 injections=%0d peer_outputs=%0d held_done17=%0d explicit_discard=1 no_reset_newgen=1 recovery_checked=12288 total_checked=%0d node_checks=%0d all_real_debt_zero=1",main_accepted,main_reads,main_writes,injects,peer_outputs,held_done,total_checked,node_checks);$finish;
 end
 always @(posedge clk)begin
  cycles=cycles+1;if(cycles>15000)$fatal(1,"TIMEOUT");
  if(rst_n)begin
   if(fill_reject_valid||discard_reject_valid||(phase==1&&protocol_fault))$fatal(1,"UNEXPECTED_PROTOCOL");
   if(dut.engine.math.in_valid&&dut.engine.math.in_ready)accepted=accepted+1;
   if(g_wr_valid&&g_wr_ready)writes=writes+1;if(g_wr_rsp_valid&&g_wr_rsp_ready)acks=acks+1;
   if(g_rd_valid&&g_rd_ready)reads=reads+1;if(g_rd_rsp_valid&&g_rd_rsp_ready)returns=returns+1;
   if(peer_injected)begin
    injects=injects+1;$display("G_PEER_INJECT generation=%0d epoch=%0d node=0 vector=64 lane=0 actual_matching_return=1 accepted_vectors=%0d reads=%0d writes=%0d",generation,epoch,accepted,reads,writes);
   end
   for(int n=0;n<9;n++)if(fp_rsp_valid[n])begin
    int vi,si,word_no;logic [31:0] expected,observed;vi=int'(fp_rsp_tag[n][15:0]);word_no=n==0?2:n==1?3:n==2?4:n==3?5:n==4?6:n==5?8:n==6?9:n==7?10:11;
    if(fp_rsp_tag[n][95:64]!=generation||fp_rsp_tag[n][63:32]!=epoch)$fatal(1,"OLD_FP_RETURN");
    for(int l=0;l<8;l++)begin
     if(fp_rsp_status[n][l]!==((phase==0&&n==0&&vi==64&&l==0)?32'd8:32'd0))$fatal(1,"PEER_STATUS_EXPECTATION");
     if(!(phase==0&&vi==64&&l==0))begin
      si=((vi%512)/4)*2624+(vi/512)*32+(vi%4)*8+l;expected=vectors[si][383-word_no*32-:32];observed=fp_rsp_data[n][l];
      if(expected!==observed)$fatal(1,"FP_NODE");node_checks=node_checks+1;
     end
    end
   end
   if(sfu_rsp_valid&&sfu_rsp_ready)begin
    int vi,si;logic [31:0] expected,observed;vi=int'(sfu_rsp_tag[15:0]);
    if(sfu_rsp_tag[95:64]!=generation||sfu_rsp_tag[63:32]!=epoch||sfu_rsp_mask!==8'hff||sfu_rsp_status!==0)$fatal(1,"SFU_RETURN");
    for(int l=0;l<8;l++)if(!(phase==0&&vi==64&&l==0))begin
     si=((vi%512)/4)*2624+(vi/512)*32+(vi%4)*8+l;expected=vectors[si][159:128];observed=sfu_rsp_data[l];if(expected!==observed)$fatal(1,"TANH_H");node_checks=node_checks+1;
    end
   end
   if(out_valid&&out_ready)begin
    int si;logic [7:0][31:0] expected,status;
    if(out_tag[95:64]!=generation||out_tag[63:32]!=epoch||out_tag[15:0]!=consumed)$fatal(1,"OUT_IDENTITY");
    for(int l=0;l<8;l++)begin
     si=((consumed%512)/4)*2624+(consumed/512)*32+(consumed%4)*8+l;expected[l]=vectors[si][31:0];status[l]=0;
     if(phase==0&&consumed==64&&l==0)begin expected[l]=0;status[l]=8;peer_outputs=peer_outputs+1;end
    end
    if(out_data!==expected||out_status!==status)$fatal(1,"PEER_ERROR_OUTPUT");consumed=consumed+1;total_checked=total_checked+8;
    if(phase==1&&consumed%128==0)progress();
   end
   if(slot_release_fire)begin
    if(slot_math_pending[slot_release_slot]||slot_sfu_debt[slot_release_slot]||slot_fp_debt[slot_release_slot])$fatal(1,"REAL_RELEASE");released=released+1;
   end
  end
 end
endmodule
