`timescale 1ns/1ps
module m007_g_error_engine_tb;
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
 m007_g_engine_validation_shell dut(.*);
 logic [383:0] vectors[0:335871];logic [511:0] patches[0:1];string vf,pf,patch_file;integer progress_fd;
 int groups,patch_count,expected_rank_arg,expected_row_arg,expected_col_arg;
 int cycles=0,issued=0,consumed=0,released=0,writes=0,write_acks=0,phase=0,total_checked=0,total_node_checks=0,error_outputs=0;
 int expected_eval[0:7],expected_rank,expected_row,expected_col,expected_errors;
 int main_checked=0,main_error_outputs=0,main_node_checks=0,held_done_cycles=0,wrong_discard_cycles=0,recovery_checked=0;
 bit use_patches=1;
 task automatic progress;
  $fdisplay(progress_fd,"{\"schema\":\"m007-tanh-consumed-v1\",\"checked\":%0d,\"node_checks\":%0d,\"cycle\":%0d,\"phase\":1,\"returned\":%0d}",total_checked,total_node_checks,cycles,total_checked/8);$fflush(progress_fd);
 endtask
 task automatic expected_domains(input int group_count);
  expected_rank=8;expected_row=128;expected_col=2624;expected_errors=0;
  for(int rank=0;rank<8;rank++)expected_eval[rank]=group_count*4096;
  if(use_patches)for(int p=0;p<patch_count;p++)begin
   int si,row,col,word_no;logic [15:0] eval_mask;logic [31:0] value;
   si=int'(patches[p][511:480]);row=si/2624;col=si%2624;eval_mask=patches[p][79:64];
   if(col<group_count*32)begin
    expected_errors=expected_errors+1;
    for(int rank=0;rank<8;rank++)begin
     expected_eval[rank]=expected_eval[rank]-int'(!eval_mask[rank]);
     word_no=rank==0?0:rank<6?rank+1:rank==6?10:11;value=patches[p][479-word_no*32-:32];
     if(eval_mask[rank]&&value[30:23]==255&&(rank<expected_rank||(rank==expected_rank&&(row<expected_row||(row==expected_row&&col<expected_col)))))begin
      expected_rank=rank;expected_row=row;expected_col=col;
     end
    end
   end
  end
 endtask
 task automatic reset_phase_counters;
  issued=0;consumed=0;released=0;writes=0;write_acks=0;error_outputs=0;
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
  for(int g=0;g<group_count;g++)for(int h=0;h<2;h++)for(int r=0;r<128;r++)begin
   @(negedge clk);fill_valid=1;fill_slot=g%2;fill_s=7'(g);fill_half=1'(h);fill_row=7'(r);
   for(int c=0;c<32;c++)fill_data[c]=vectors[r*2624+g*32+c][383-h*32-:32];
   #0.001;while(!fill_ready)begin @(negedge clk);#0.001;end
  end
  @(negedge clk);fill_valid=0;
 endtask
 task automatic check_drained(input int group_count);
  wait(consumed==group_count*512&&released==group_count);repeat(3)@(negedge clk);
  if(issued!=group_count*512||writes!=group_count*256||write_acks!=writes||sfu_pending||sfu_flight||slot_active||slot_math_pending||slot_sfu_debt||slot_fp_debt||protocol_fault)$fatal(1,"REAL_DEBT_DRAIN");
  for(int rank=0;rank<8;rank++)if(covered[rank]!=group_count*4096||evaluated[rank]!=expected_eval[rank])$fatal(1,"DOMAIN_COVERAGE phase=%0d rank=%0d covered=%0d evaluated=%0d expected=%0d",phase,rank,covered[rank],evaluated[rank],expected_eval[rank]);
  if(error_outputs!=expected_errors)$fatal(1,"ERROR_OUTPUT_COUNT got=%0d expected=%0d",error_outputs,expected_errors);
 endtask
 initial begin
  if(!$value$plusargs("VECTORS=%s",vf)||!$value$plusargs("PATCH_FILE=%s",patch_file)||!$value$plusargs("PROGRESS_FILE=%s",pf)||!$value$plusargs("GROUPS=%d",groups)||!$value$plusargs("PATCH_COUNT=%d",patch_count)||!$value$plusargs("ERROR_RANK=%d",expected_rank_arg)||!$value$plusargs("ERROR_ROW=%d",expected_row_arg)||!$value$plusargs("ERROR_COLUMN=%d",expected_col_arg)||groups<8||groups>82||patch_count!=2)$fatal(1,"ARGS");
  $readmemh(vf,vectors);$readmemh(patch_file,patches);
  for(int p=0;p<patch_count;p++)vectors[patches[p][511:480]]=patches[p][479:96];
  progress_fd=$fopen(pf,"w");if(!progress_fd)$fatal(1,"PROGRESS_OPEN");
  expected_domains(groups);repeat(5)@(negedge clk);rst_n=1;bind_resources();command();produce(groups);check_drained(groups);
  main_checked=consumed*8;main_error_outputs=error_outputs;main_node_checks=total_node_checks;
  if(groups==82)begin
   if(expected_rank!=expected_rank_arg||expected_row!=expected_row_arg||expected_col!=expected_col_arg)$fatal(1,"REFERENCE_FIRST_ERROR");
   wait(done_valid);@(negedge clk);
   if(done_status!=6||done_error_rank!=expected_rank||done_error_row!=expected_row||done_error_column!=expected_col||active||!needs_discard)$fatal(1,"FULL_ERROR_ORDER got=%0d/%0d/%0d expected=%0d/%0d/%0d status=%0d",done_error_rank,done_error_row,done_error_column,expected_rank,expected_row,expected_col,done_status);
   repeat(17)begin
    @(negedge clk);held_done_cycles=held_done_cycles+1;
    if(!done_valid||done_status!=6||done_error_rank!=expected_rank||done_error_row!=expected_row||done_error_column!=expected_col||cmd_ready||rsp_request_id!=request_id||rsp_generation!=generation||rsp_epoch!=epoch)$fatal(1,"HELD_ERROR_DONE");
   end
   done_ready=1;@(posedge clk);@(negedge clk);done_ready=0;if(!needs_discard||cmd_ready||engine_idle)$fatal(1,"ERROR_REQUIRES_DISCARD");
   // Reject wrong generation after actual done consumption. No valid/debt
   // state is forced, and the real public matching discard clears private G.
   generation=generation+1;discard_valid=1;#0.001;
   repeat(17)begin
    if(discard_ready||!discard_reject_valid||!needs_discard)$fatal(1,"WRONG_DISCARD_IDENTITY");
    @(negedge clk);wrong_discard_cycles=wrong_discard_cycles+1;
   end
   generation=generation-1;#0.001;while(!discard_ready)begin @(negedge clk);#0.001;end
   @(posedge clk);@(negedge clk);discard_valid=0;if(needs_discard||!engine_idle)$fatal(1,"MATCHING_DISCARD");
   release_valid=1;#0.001;while(!release_ready)begin @(negedge clk);#0.001;end
   @(posedge clk);@(negedge clk);release_valid=0;if(resources_bound)$fatal(1,"LEASE_RELEASE");
   generation=generation+1;epoch=epoch+1;phase=1;use_patches=0;$readmemh(vf,vectors);reset_phase_counters();expected_domains(3);
   bind_resources();command();produce(3);check_drained(3);recovery_checked=consumed*8;
   if(!active||done_valid||needs_discard||engine_idle||rsp_generation!=generation||rsp_epoch!=epoch)$fatal(1,"NO_RESET_NEWGEN_PREFIX");
  end else begin
   if(!active||done_valid||needs_discard||engine_idle)$fatal(1,"PREFIX_NO_FAKE_DONE");
   if(!dut.engine.math.first_error_valid||dut.engine.math.first_error_rank!=expected_rank||dut.engine.math.first_error_row!=expected_row||dut.engine.math.first_error_column!=expected_col)$fatal(1,"PREFIX_ERROR_CANDIDATE");
  end
  $fclose(progress_fd);
  $display("HARDWARE_AGENT_SIM_PASS G_ERROR groups=%0d main_checked=%0d main_node_checks=%0d total_checked=%0d node_checks=%0d error_outputs=%0d expected_rank=%0d expected_row=%0d expected_column=%0d full_error_done=%0d held_done17=%0d wrong_discard17=%0d recovery_checked=%0d no_reset_newgen=%0d accepted_debt_zero=1",groups,main_checked,main_node_checks,total_checked,total_node_checks,main_error_outputs,expected_rank_arg,expected_row_arg,expected_col_arg,groups==82,held_done_cycles,wrong_discard_cycles,recovery_checked,groups==82);$finish;
 end
 always @(posedge clk)begin
  cycles=cycles+1;if(cycles>150000)$fatal(1,"TIMEOUT");
  if(rst_n)begin
   if(protocol_fault||fill_reject_valid)$fatal(1,"PEER_PROTOCOL_FAULT");
   if(g_wr_valid&&g_wr_ready)writes=writes+1;if(g_wr_rsp_valid&&g_wr_rsp_ready)write_acks=write_acks+1;
   if(g_rd_valid&&g_rd_ready)begin
    if(g_rd_tag[95:64]!=generation||g_rd_tag[63:32]!=epoch||g_rd_tag[15:0]!=issued)$fatal(1,"READ_IDENTITY");issued=issued+1;
   end
   for(int n=0;n<9;n++)if(fp_rsp_valid[n])begin
    int word_no,vi,si;logic [31:0] expected,observed;logic [15:0] checks;
    word_no=n==0?2:n==1?3:n==2?4:n==3?5:n==4?6:n==5?8:n==6?9:n==7?10:11;vi=int'(fp_rsp_tag[n][15:0]);
    if(fp_rsp_tag[n][95:64]!=generation||fp_rsp_tag[n][63:32]!=epoch)$fatal(1,"OLD_FP_RETURN");
    for(int l=0;l<8;l++)begin
     si=((vi%512)/4)*2624+(vi/512)*32+(vi%4)*8+l;checks=16'h3ff;
     if(use_patches)for(int p=0;p<patch_count;p++)if(patches[p][511:480]==si)checks=patches[p][95:80];
     if(fp_rsp_status[n][l]!==0)$fatal(1,"FP_PEER_STATUS");
     if(checks[n])begin
      expected=vectors[si][383-word_no*32-:32];observed=fp_rsp_data[n][l];
      if(observed!==expected)$fatal(1,"FP_NODE phase=%0d n=%0d vi=%0d lane=%0d got=%h expected=%h",phase,n,vi,l,observed,expected);total_node_checks=total_node_checks+1;
     end
    end
   end
   if(sfu_rsp_valid&&sfu_rsp_ready)begin
    int vi,si;logic [15:0] checks;logic [31:0] expected,observed;vi=int'(sfu_rsp_tag[15:0]);
    if(sfu_rsp_tag[95:64]!=generation||sfu_rsp_tag[63:32]!=epoch||sfu_rsp_mask!==8'hff||sfu_rsp_status!==0)$fatal(1,"SFU_PEER_IDENTITY_STATUS");
    for(int l=0;l<8;l++)begin
     si=((vi%512)/4)*2624+(vi/512)*32+(vi%4)*8+l;checks=16'h3ff;
     if(use_patches)for(int p=0;p<patch_count;p++)if(patches[p][511:480]==si)checks=patches[p][95:80];
     if(checks[9])begin expected=vectors[si][159:128];observed=sfu_rsp_data[l];if(observed!==expected)$fatal(1,"TANH_H");total_node_checks=total_node_checks+1;end
    end
   end
   if(out_valid&&out_ready)begin
    int si;logic [7:0][31:0] expected,expected_status;
    if(out_tag[95:64]!=generation||out_tag[63:32]!=epoch||out_tag[15:0]!=consumed)$fatal(1,"OUTPUT_IDENTITY");
    for(int l=0;l<8;l++)begin
     si=((consumed%512)/4)*2624+(consumed/512)*32+(consumed%4)*8+l;expected[l]=vectors[si][31:0];expected_status[l]=0;
     if(use_patches)for(int p=0;p<patch_count;p++)if(patches[p][511:480]==si)begin expected[l]=patches[p][63:32];expected_status[l]=patches[p][31:0];end
     if(expected_status[l]==6)error_outputs=error_outputs+1;
    end
    if(out_data!==expected||out_status!==expected_status)$fatal(1,"OUTPUT_ERROR_RECORD phase=%0d vi=%0d got=%h expected=%h status=%h expected_status=%h",phase,consumed,out_data,expected,out_status,expected_status);
    consumed=consumed+1;total_checked=total_checked+8;if(consumed%128==0)progress();
   end
   if(slot_release_fire)begin
    if(slot_consumed_vectors[slot_release_slot]!=512||slot_math_pending[slot_release_slot]||slot_sfu_debt[slot_release_slot]||slot_fp_debt[slot_release_slot])$fatal(1,"SLOT_RELEASE_DEBT");released=released+1;
   end
  end
 end
endmodule
