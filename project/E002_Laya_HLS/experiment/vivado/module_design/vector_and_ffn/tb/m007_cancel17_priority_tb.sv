`timescale 1ns/1ps
module m007_cancel17_priority_tb;
 logic clk=0;always #1.6665 clk=~clk;logic rst_n=0;
 logic hold_wr=0,hold_rd=0,hold_ack=0,hold_bank_rsp=0,peer_enable=0,peer_injected;
 logic producer_cancel_valid=0,producer_cancel_ready,producer_cancel_reject_valid,done_cancelled,control_retired;
 logic [63:0]producer_cancel_request_id=0;logic[31:0]producer_cancel_generation=0,producer_cancel_epoch=0;
 logic bind_valid=0,bind_ready,resources_bound,release_valid=0,release_ready;
 logic [63:0]request_id=64'h123456789abcdef0,rsp_request_id;
 logic [31:0]generation=7,epoch=9,rsp_generation,rsp_epoch;
 logic cmd_valid=0,cmd_ready,fill_valid=0,fill_ready,fill_slot=0,fill_half=0;
 logic [6:0]fill_s=0,fill_row=0;logic [31:0][31:0]fill_data=0;
 logic fill_reject_valid;logic [1:0]fill_reject_code;
 logic out_valid,out_ready=1;logic[7:0][31:0]out_data,out_status;logic[95:0]out_tag;logic[6:0]out_s,out_row;logic[1:0]out_chunk;
 logic done_valid,done_ready=0;logic[31:0]done_status;logic[2:0]done_error_rank;logic[6:0]done_error_row;logic[11:0]done_error_column;
 logic discard_valid=0,discard_ready,discard_reject_valid;logic engine_idle,active,needs_discard,protocol_fault;
 logic[1:0]slot_active,slot_ready;logic[1:0][6:0]slot_s;logic[1:0][9:0]slot_consumed_vectors;
 logic[1:0][8:0]slot_math_pending,slot_sfu_debt;logic[1:0][7:0]slot_fp_debt;
 logic[7:0][18:0]covered,evaluated;logic[8:0]sfu_pending,sfu_flight;
 logic slot_release_fire,slot_release_slot;logic[6:0]slot_release_s;
 logic g_wr_valid,g_wr_ready,g_wr_rsp_valid,g_wr_rsp_ready,g_rd_valid,g_rd_ready,g_rd_rsp_valid,g_rd_rsp_ready;
 logic[95:0]g_wr_rsp_tag,g_rd_tag,g_rd_rsp_tag;
 logic[8:0]fp_rsp_valid;logic[8:0][95:0]fp_rsp_tag;logic[8:0][7:0][31:0]fp_rsp_data,fp_rsp_status;
 logic sfu_rsp_valid,sfu_rsp_ready;logic[95:0]sfu_rsp_tag;logic[7:0]sfu_rsp_mask;logic[7:0][31:0]sfu_rsp_data,sfu_rsp_status;
 m007_cancel17_validation_shell dut(.*);
 logic[383:0]vectors[0:335871];string vf,pf;integer progress_fd;
 int cancel_terminal_same=0,done_records=0;logic previous_done=0;
 int cancel_read_limit=-1,cancel_write_limit=-1;
 int cancel_fill_same=0,cancel_read_same=0,cancel_bank_return_same=0,cancel_fp_accept_same=0,cancel_fp_return_same=0,cancel_sfu_accept_same=0,cancel_sfu_return_same=0,cancel_ack_same=0,cancel_out_same=0;
 int mode,phase=0,cycles=0,accepted=0,outputs=0,reads=0,returns=0,writes=0,acks=0,releases=0,total_checked=0,node_checks=0,cancels=0,rejects=0,peer_events=0,held_output=0,held_bank=0,last_progress=0;
 int main_accepted,main_reads,main_writes;logic[607:0]out_record;logic[10079:0]write_record;logic[1887:0]read_record;
 function automatic int si(input int vi,l);return ((vi%512)/4)*2624+(vi/512)*32+(vi%4)*8+l;endfunction
 task automatic tick;@(posedge clk);#0.01;endtask
 task automatic cancel_identity;producer_cancel_request_id=request_id;producer_cancel_generation=generation;producer_cancel_epoch=epoch;endtask
 task automatic bind_resources;
  @(negedge clk);bind_valid=1;#0.001;while(!bind_ready)begin @(negedge clk);#0.001;end
  @(posedge clk);@(negedge clk);bind_valid=0;if(!resources_bound)$fatal(1,"ACTUAL_BIND");
 endtask
 task automatic command;
  @(negedge clk);cmd_valid=1;#0.001;while(!cmd_ready)begin @(negedge clk);#0.001;end
  @(posedge clk);@(negedge clk);cmd_valid=0;
 endtask
 task automatic drive_row(input int index);
  int g,h,r;g=index/256;h=(index%256)/128;r=index%128;
  fill_valid=1;fill_slot=1'(g%2);fill_s=7'(g);fill_half=1'(h);fill_row=7'(r);
  for(int c=0;c<32;c++)fill_data[c]=vectors[r*2624+g*32+c][383-h*32-:32];
  if(mode==6&&phase==0&&index==0)fill_data[0]=32'h7fc00001;
 endtask
 task automatic produce(input int rows,input bit cancel_last);
  for(int i=0;i<rows;i++)begin
   @(negedge clk);drive_row(i);#0.001;while(!fill_ready)begin @(negedge clk);#0.001;end
   if(cancel_last&&i==rows-1)begin cancel_identity();producer_cancel_valid=1;#0.001;if(!producer_cancel_ready)$fatal(1,"SAME_EDGE_FILL_CANCEL_NOT_READY");end
  end
  @(negedge clk);fill_valid=0;producer_cancel_valid=0;
 endtask
 task automatic request_cancel;
  @(negedge clk);cancel_identity();producer_cancel_valid=1;#0.001;if(!producer_cancel_ready)$fatal(1,"CANCEL_NOT_READY");tick();@(negedge clk);producer_cancel_valid=0;
 endtask
 task automatic progress;
  if(total_checked>last_progress)begin
   $fdisplay(progress_fd,"{\"schema\":\"m007-tanh-consumed-v1\",\"checked\":%0d,\"node_checks\":%0d,\"cycle\":%0d,\"phase\":1,\"returned\":%0d}",total_checked,node_checks,cycles,total_checked/8);$fflush(progress_fd);last_progress=total_checked;
  end
 endtask
 task automatic rejected_cancel(input int which);
  @(negedge clk);cancel_identity();if(which==0)producer_cancel_request_id=request_id^64'd1;if(which==1)producer_cancel_generation=generation+1;if(which==2)producer_cancel_epoch=epoch+1;
  producer_cancel_valid=1;repeat(3)begin #0.001;if(producer_cancel_ready||!producer_cancel_reject_valid)$fatal(1,"WRONG_OR_INACTIVE_CANCEL_ACCEPTED");tick();@(negedge clk);end
  producer_cancel_valid=0;cancel_identity();
 endtask
 initial begin
  if(!$value$plusargs("VECTORS=%s",vf)||!$value$plusargs("PROGRESS_FILE=%s",pf)||!$value$plusargs("CANCEL_MODE=%d",mode)||mode<0||mode>6)$fatal(1,"ARGS");
  $readmemh(vf,vectors);progress_fd=$fopen(pf,"w");if(!progress_fd)$fatal(1,"PROGRESS_OPEN");
  repeat(5)@(negedge clk);rst_n=1;bind_resources();rejected_cancel(3);command();
  rejected_cancel(0);rejected_cancel(1);rejected_cancel(2);
  if(accepted||reads||writes||done_valid||done_cancelled)$fatal(1,"REJECT_CANCEL_CHANGED_WORK");
  if(mode==0)begin
   hold_ack=1;produce(1,0);if(!dut.engine.write_pending)$fatal(1,"REAL_WRITE_DEBT_REQUIRED");request_cancel();
   repeat(17)begin tick();if(done_valid||control_retired||!dut.engine.write_pending)$fatal(1,"ACK_DEBT_CLEARED_EARLY");end
   @(negedge clk);hold_ack=0;
  end else if(mode==1)produce(129,1);
  else if(mode==3)begin
   hold_rd=1;produce(256,0);wait(g_rd_valid);@(negedge clk);read_record={dut.g_rd_mask,dut.g_rd_addr,g_rd_tag};request_cancel();
   repeat(17)begin tick();if(!g_rd_valid||g_rd_ready||{dut.g_rd_mask,dut.g_rd_addr,g_rd_tag}!==read_record||done_valid||control_retired)$fatal(1,"PUBLISHED_READ_WITHDRAWN");held_bank++;end
   @(negedge clk);hold_rd=0;
  end else if(mode==4)begin
   hold_wr=1;@(negedge clk);drive_row(0);#0.001;if(!g_wr_valid||g_wr_ready)$fatal(1,"HELD_WRITE_REQUIRED");write_record={dut.g_wr_mask,dut.g_wr_addr,dut.g_wr_data,dut.g_wr_tag};request_cancel();
   repeat(17)begin tick();if(!g_wr_valid||g_wr_ready||{dut.g_wr_mask,dut.g_wr_addr,dut.g_wr_data,dut.g_wr_tag}!==write_record||done_valid||control_retired)$fatal(1,"PUBLISHED_WRITE_WITHDRAWN");held_bank++;end
   @(negedge clk);hold_wr=0;#0.001;while(!fill_ready)begin @(negedge clk);#0.001;end
   @(posedge clk);@(negedge clk);fill_valid=0;
  end else if(mode==5)begin
   peer_enable=1;produce(256,0);wait(peer_events==1);
   @(negedge clk);while(!(dut.engine.math_idle&&dut.engine.math_control_retired&&!dut.engine.write_pending&&dut.engine.bank_issued==dut.engine.bank_returned&&protocol_fault))@(negedge clk);
   cancel_identity();producer_cancel_valid=1;#0.001;if(!producer_cancel_ready)$fatal(1,"REAL_TERMINAL_CANCEL_READY");
   tick();@(negedge clk);producer_cancel_valid=0;if(done_valid)$fatal(1,"TERMINAL_CANCEL_MUST_WIN_EDGE");
  end else begin
   out_ready=0;produce(320,0);wait(out_valid);@(negedge clk);hold_bank_rsp=0;out_record={out_data,out_status,out_tag};
   if(slot_fp_debt==0||slot_sfu_debt==0||dut.engine.bank_issued==dut.engine.bank_returned)$fatal(1,"REAL_BANK_FP_SFU_DEBT_REQUIRED");request_cancel();hold_bank_rsp=1;
   repeat(17)begin tick();if(!out_valid||{out_data,out_status,out_tag}!==out_record||done_valid||control_retired)$fatal(1,"HELD_OUTPUT_CANCEL");held_output++;end
   @(negedge clk);hold_bank_rsp=0;out_ready=1;
  end
  // A duplicate request cannot mutate accepted work while cancellation drains.
  @(negedge clk);cancel_identity();producer_cancel_valid=1;#0.001;if(producer_cancel_ready||!producer_cancel_reject_valid)$fatal(1,"DUPLICATE_CANCEL");tick();@(negedge clk);producer_cancel_valid=0;
  wait(done_valid);@(negedge clk);main_accepted=accepted;main_reads=reads;main_writes=writes;progress();
  if(!done_cancelled||!needs_discard||active||cancels!=1||writes!=acks||reads!=returns||accepted!=reads||reads!=cancel_read_limit||writes!=cancel_write_limit||outputs!=accepted||slot_math_pending||slot_fp_debt||slot_sfu_debt||sfu_pending||sfu_flight||out_valid||control_retired||covered[0]==335872)$fatal(1,"CANCEL_DONE_REAL_DRAIN");
  if(done_status!=(mode==5?8:mode==6?6:0))$fatal(1,"CANCEL_STATUS_PRIORITY got=%0d",done_status);
  if(mode==6&&(done_error_rank||done_error_row||done_error_column))$fatal(1,"OBSERVED_NUMERIC_LOCATION");
  begin logic[182:0]record;record={done_cancelled,done_status,done_error_rank,done_error_row,done_error_column,rsp_request_id,rsp_generation,rsp_epoch};
   repeat(17)begin @(negedge clk);cancel_identity();producer_cancel_valid=1;#0.001;if(!done_valid||{done_cancelled,done_status,done_error_rank,done_error_row,done_error_column,rsp_request_id,rsp_generation,rsp_epoch}!==record||producer_cancel_ready||!producer_cancel_reject_valid||control_retired||cmd_ready)$fatal(1,"CANCEL_DONE_HELD17");end
  end
  producer_cancel_valid=0;done_ready=1;@(posedge clk);@(negedge clk);done_ready=0;
  if(engine_idle||control_retired||!needs_discard)$fatal(1,"DONE_CONSUME_NOT_DISCARD");
  request_id=request_id^64'd1;discard_valid=1;repeat(3)begin #0.001;if(discard_ready||!discard_reject_valid)$fatal(1,"WRONG_DISCARD");tick();@(negedge clk);end
  request_id=request_id^64'd1;#0.001;while(!discard_ready)begin @(negedge clk);#0.001;end
  @(posedge clk);@(negedge clk);discard_valid=0;
  if(!engine_idle||!control_retired||needs_discard||slot_active||covered||evaluated||protocol_fault)$fatal(1,"ACTUAL_DISCARD_NOT_RETIRED");
  release_valid=1;#0.001;while(!release_ready)begin @(negedge clk);#0.001;end
  @(posedge clk);@(negedge clk);release_valid=0;
  generation++;epoch++;phase=1;peer_enable=0;accepted=0;outputs=0;reads=0;returns=0;writes=0;acks=0;releases=0;
  bind_resources();command();produce(768,0);wait(outputs==1536&&releases==3);repeat(3)@(negedge clk);progress();
  if(accepted!=1536||reads!=1536||returns!=1536||writes!=768||acks!=768||protocol_fault||done_cancelled||needs_discard||done_valid||!active||slot_math_pending||slot_fp_debt||slot_sfu_debt||sfu_pending||sfu_flight)$fatal(1,"NO_RESET_NEWGEN_RECOVERY");
  for(int rank=0;rank<8;rank++)if(covered[rank]!=12288||evaluated[rank]!=12288)$fatal(1,"RECOVERY_COVERAGE");
  $fclose(progress_fd);$display("HARDWARE_AGENT_SIM_PASS G_CANCEL17 mode=%0d main_accepted_vectors=%0d main_read_vectors=%0d main_writes=%0d cancel_fires=%0d rejected_cycles=%0d done_cancelled=1 done_held17=17 explicit_discard=1 recovery_checked=12288 total_checked=%0d node_checks=%0d output_held17=%0d bank_held17=%0d peer_events=%0d all_real_debt_zero=1 cancel_fill_same=%0d cancel_read_same=%0d cancel_bank_return_same=%0d cancel_fp_accept_same=%0d cancel_fp_return_same=%0d cancel_sfu_accept_same=%0d cancel_sfu_return_same=%0d cancel_ack_same=%0d cancel_out_same=%0d cancel_terminal_same=%0d done_records=%0d",mode,main_accepted,main_reads,main_writes,cancels,rejects,total_checked,node_checks,held_output,held_bank,peer_events,cancel_fill_same,cancel_read_same,cancel_bank_return_same,cancel_fp_accept_same,cancel_fp_return_same,cancel_sfu_accept_same,cancel_sfu_return_same,cancel_ack_same,cancel_out_same,cancel_terminal_same,done_records);$finish;
 end
 always @(posedge clk)begin
  cycles++;if(cycles>25000)$fatal(1,"TIMEOUT");
  if(rst_n)begin
   if(done_valid&&!previous_done)done_records++;previous_done=done_valid;
   if(producer_cancel_valid&&producer_cancel_ready)begin
    if(dut.engine.math_idle&&dut.engine.math_control_retired&&!dut.engine.write_pending&&dut.engine.bank_issued==dut.engine.bank_returned&&protocol_fault)cancel_terminal_same++;
    cancel_read_limit=reads+int'(g_rd_valid);cancel_write_limit=writes+int'(g_wr_valid);
    cancels++;cancel_fill_same+=int'(fill_valid&&fill_ready);cancel_read_same+=int'(g_rd_valid&&g_rd_ready);cancel_bank_return_same+=int'(g_rd_rsp_valid&&g_rd_rsp_ready);
    cancel_fp_accept_same+=int'(|(dut.fp_req_valid&dut.fp_req_ready));cancel_fp_return_same+=int'(|fp_rsp_valid);
    cancel_sfu_accept_same+=int'(dut.sfu_req_valid&&dut.sfu_req_ready);cancel_sfu_return_same+=int'(sfu_rsp_valid&&sfu_rsp_ready);
    cancel_ack_same+=int'(g_wr_rsp_valid&&g_wr_rsp_ready);cancel_out_same+=int'(out_valid&&out_ready);
   end
   if(producer_cancel_reject_valid)rejects++;
   if(peer_injected)peer_events++;
   if(protocol_fault&&!(phase==0&&mode==5))$fatal(1,"UNEXPECTED_PROTOCOL");
   if(dut.engine.math.accept)accepted++;
   if(g_wr_valid&&g_wr_ready)writes++;if(g_wr_rsp_valid&&g_wr_rsp_ready)acks++;
   if(g_rd_valid&&g_rd_ready)reads++;if(g_rd_rsp_valid&&g_rd_rsp_ready)returns++;
   if(slot_release_fire)releases++;
   for(int n=0;n<9;n++)if(fp_rsp_valid[n])begin
    int vi,word_no;vi=int'(fp_rsp_tag[n][15:0]);word_no=n==0?2:n==1?3:n==2?4:n==3?5:n==4?6:n==5?8:n==6?9:n==7?10:11;
    if(fp_rsp_tag[n][95:64]!=generation||fp_rsp_tag[n][63:32]!=epoch)$fatal(1,"FP_TAG");
    for(int l=0;l<8;l++)begin
     if(!(mode==6&&phase==0&&vi==0&&l==0))begin
      if(fp_rsp_data[n][l]!==vectors[si(vi,l)][383-word_no*32-:32])$fatal(1,"FP_ORIGINAL_NODE n=%0d vi=%0d lane=%0d",n,vi,l);node_checks++;
     end
     if(fp_rsp_status[n][l]!==((phase==0&&mode==5&&n==8&&vi==511&&l==0)?32'd8:32'd0))$fatal(1,"FP_STATUS");
    end
   end
   if(sfu_rsp_valid&&sfu_rsp_ready)for(int l=0;l<8;l++)begin
    if(!(mode==6&&phase==0&&sfu_rsp_tag[15:0]==0&&l==0))begin if(sfu_rsp_data[l]!==vectors[si(int'(sfu_rsp_tag[15:0]),l)][159:128])$fatal(1,"SFU_ORIGINAL_NODE");node_checks++;end
    if(sfu_rsp_status[l]!==0)$fatal(1,"SFU_STATUS");
   end
   if(out_valid&&out_ready)begin
    if(out_tag!=={generation,epoch,16'b0,16'(outputs)})$fatal(1,"OUTPUT_TAG");
    for(int l=0;l<8;l++)begin
     if(mode==6&&phase==0&&outputs==0&&l==0)begin if(out_status[l]!==6||out_data[l]!==0)$fatal(1,"CANCEL_NUMERIC_STATUS");end
     else begin
      if(out_data[l]!==vectors[si(outputs,l)][31:0])$fatal(1,"ORIGINAL_OUTPUT vector=%0d lane=%0d",outputs,l);
      if(out_status[l]!==((mode==5&&phase==0&&outputs==511&&l==0)?32'd8:32'd0))$fatal(1,"OUTPUT_STATUS");
     end
    end
    outputs++;total_checked+=8;if(outputs%128==0)progress();
   end
  end
 end
endmodule
