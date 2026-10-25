`timescale 1ns/1ps
module m007_ln_bank_tb;
 logic clk=0,rst_n=0;always#5 clk=~clk;
 logic bind_valid=0,bind_ready;logic[63:0]bind_request_id=64'h14000001,op_request_id=64'h14000001,rsp_request_id;
 logic[31:0]bind_generation=6,bind_epoch=77,op_generation=6,op_epoch=77,rsp_generation,rsp_epoch;
 logic[3:0]bind_head=0,rsp_head;logic[2:0]bind_phase=6,op_phase=6,rsp_phase;
 logic wr_valid=0,wr_ready,wr_rsp_valid,wr_rsp_ready=1;
 logic[255:0]wr_mask=0;logic[255:0][4:0]wr_addr=0;logic[255:0][31:0]wr_data=0;logic[95:0]wr_tag=0,wr_rsp_tag;
 logic rd_valid=0,rd_ready,rd_rsp_valid,rd_rsp_ready=1;logic[255:0]rd_mask=0,rd_rsp_mask;
 logic[255:0][4:0]rd_addr=0;logic[255:0][31:0]rd_rsp_data;logic[95:0]rd_tag=0,rd_rsp_tag;logic idle;
 laya_ln_exp_storage_v1 dut(.*);
 logic[31:0]expected[0:255][0:31];logic[255:0][31:0]expected_read;logic[255:0]expected_mask;
 logic[95:0]expected_read_tag,expected_write_tag;bit read_pending=0,write_pending=0,held_read=0,held_write=0;
 logic[8543:0]read_hold;logic[95:0]write_hold;integer cycle=0,writes=0,reads=0,read_returns=0,write_returns=0,held_cycles=0,collisions=0,parallel_ops=0;
 always@(posedge clk)begin
  cycle++;if(cycle>10000)$fatal(1,"bank cycle limit");
  if(!rst_n)begin read_pending=0;write_pending=0;held_read=0;held_write=0;end
  else begin
   if(held_read&&(!rd_rsp_valid||{rd_rsp_tag,rd_rsp_mask,rd_rsp_data}!==read_hold))$fatal(1,"held native LN read changed");
   if(held_write&&(!wr_rsp_valid||wr_rsp_tag!==write_hold))$fatal(1,"held native LN write ack changed");
   held_read=rd_rsp_valid&&!rd_rsp_ready;held_write=wr_rsp_valid&&!wr_rsp_ready;
   read_hold={rd_rsp_tag,rd_rsp_mask,rd_rsp_data};write_hold=wr_rsp_tag;if(held_read||held_write)held_cycles++;
   if(rd_rsp_valid)begin
    if(!read_pending||rd_rsp_tag!==expected_read_tag||rd_rsp_mask!==expected_mask)$fatal(1,"native read tag/mask/unreserved return");
    for(int bank=0;bank<256;bank++)if(expected_mask[bank]&&rd_rsp_data[bank]!==expected_read[bank])$fatal(1,"LN bank data mismatch bank=%0d actual=%h expected=%h",bank,rd_rsp_data[bank],expected_read[bank]);
    if(rd_rsp_ready)begin read_pending=0;read_returns++;end
   end
   if(wr_rsp_valid)begin if(!write_pending||wr_rsp_tag!==expected_write_tag)$fatal(1,"native write ack tag/debt mismatch");if(wr_rsp_ready)begin write_pending=0;write_returns++;end end
   // Independent expected memory snapshots the real accepted request before
   // writes, matching the specified public read-priority collision semantics.
   if(rd_valid&&rd_ready)begin
    if(read_pending)$fatal(1,"read response reservation overwritten");read_pending=1;expected_read_tag=rd_tag;expected_mask=rd_mask;
    for(int bank=0;bank<256;bank++)if(rd_mask[bank])expected_read[bank]=expected[bank][rd_addr[bank]];reads++;
   end
   if(wr_valid&&wr_ready)begin
    if(write_pending)$fatal(1,"write ack reservation overwritten");write_pending=1;expected_write_tag=wr_tag;
    for(int bank=0;bank<256;bank++)if(wr_mask[bank])expected[bank][wr_addr[bank]]=wr_data[bank];writes++;
   end
   if(wr_valid&&rd_valid&&wr_ready&&rd_ready)parallel_ops++;
   if(wr_valid&&!wr_ready&&rd_valid&&rd_ready)collisions++;
  end
 end
 task automatic take_binding;
  @(negedge clk);bind_valid=1;do @(posedge clk);while(!bind_ready);@(negedge clk);bind_valid=0;
 endtask
 task automatic wait_idle;
  @(negedge clk);wr_valid=0;rd_valid=0;wr_rsp_ready=1;rd_rsp_ready=1;
  wait(idle);@(negedge clk);
 endtask
 task automatic read_all(input integer address,input integer tag);
  @(negedge clk);rd_valid=1;rd_mask='1;rd_tag=96'(tag);for(int bank=0;bank<256;bank++)rd_addr[bank]=5'(address);
  do @(posedge clk);while(!rd_ready);@(negedge clk);rd_valid=0;
 endtask
 initial begin
  repeat(4)@(negedge clk);rst_n=1;take_binding;
  // Four contexts × raw/delta ×32 banks ×32 words: all32768B through real ports.
  for(int address=0;address<32;address++)begin
   @(negedge clk);wr_valid=1;wr_mask='1;wr_tag=96'(address);
   for(int bank=0;bank<256;bank++)begin wr_addr[bank]=5'(address);wr_data[bank]=32'h3f000000|(32'(bank)<<8)|32'(address);end
   do @(posedge clk);while(!wr_ready);
  end
  wait_idle;
  for(int address=0;address<32;address++)read_all(address,256+address);
  wait_idle;
  // Same physical bank/address: real read wins, write stays unaccepted.
  @(negedge clk);rd_valid=1;wr_valid=1;rd_mask=1;wr_mask=1;rd_addr=0;wr_addr=0;rd_tag=512;wr_tag=513;wr_data[0]=32'h40000000;
  #1;if(!rd_ready||wr_ready)$fatal(1,"same-context alias collision not blocked");
  @(posedge clk);@(negedge clk);rd_valid=0;
  do @(posedge clk);while(!wr_ready);wait_idle;read_all(0,514);wait_idle;
  // Different context banks may accept one atomic read and write together.
  @(negedge clk);rd_valid=1;wr_valid=1;rd_mask=256'hffffffff;wr_mask=256'hffffffff<<96;rd_addr=0;wr_addr=0;rd_tag=768;wr_tag=769;
  for(int bank=96;bank<128;bank++)wr_data[bank]=32'h40400000+32'(bank);
  #1;if(!rd_ready||!wr_ready)$fatal(1,"different-context real operations did not overlap");
  @(posedge clk);wait_idle;read_all(0,770);wait_idle;
  // Real held read and write ack prevent rebind and preserve all fields.
  @(negedge clk);rd_rsp_ready=0;wr_rsp_ready=0;rd_valid=1;wr_valid=1;rd_mask='1;wr_mask=1;rd_addr=0;wr_addr=0;wr_addr[0]=1;rd_tag=1024;wr_tag=1025;wr_data[0]=32'h40800000;
  @(posedge clk);if(!rd_ready||!wr_ready)$fatal(1,"held pilot requests not accepted");
  @(negedge clk);rd_valid=0;wr_valid=0;bind_valid=1;bind_generation=7;bind_epoch=78;
  repeat(12)begin @(negedge clk);if(bind_ready||idle||!rd_rsp_valid||!wr_rsp_valid)$fatal(1,"rebind crossed held native return debt");end
  bind_valid=0;wr_rsp_ready=1;rd_rsp_ready=1;wait_idle;take_binding;
  // The old operation identity cannot access a new binding.
  @(negedge clk);rd_valid=1;wr_valid=1;rd_mask=1;wr_mask=1;#1;if(rd_ready||wr_ready)$fatal(1,"old LN bank generation accepted");
  @(posedge clk);@(negedge clk);rd_valid=0;wr_valid=0;op_generation=7;op_epoch=78;
  read_all(1,1280);wait_idle;
  // Active reset discards actual response metadata, retains payload, then newgen.
  @(negedge clk);rd_rsp_ready=0;rd_valid=1;rd_mask='1;rd_addr=0;rd_tag=1536;
  @(posedge clk);@(negedge clk);rd_valid=0;if(!rd_rsp_valid)$fatal(1,"reset no real LN read response");rst_n=0;
  repeat(3)@(negedge clk);rst_n=1;rd_rsp_ready=1;bind_generation=8;bind_epoch=79;op_generation=8;op_epoch=79;
  repeat(4)@(negedge clk);if(rd_rsp_valid||wr_rsp_valid)$fatal(1,"stale native return after reset");take_binding;
  read_all(0,1792);read_all(1,1793);wait_idle;
  if(collisions<1||parallel_ops<2||held_cycles<12)$fatal(1,"native bank coverage incomplete");
  $display("HARDWARE_AGENT_SIM_PASS M007_LN_BANK banks=256 depth=32 bytes=32768 writes=%0d reads=%0d read_returns=%0d write_returns=%0d collision=%0d parallel=%0d held_cycles=%0d active_reset=1 newgen=8",writes,reads,read_returns,write_returns,collisions,parallel_ops,held_cycles);$finish;
 end
endmodule
