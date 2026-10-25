`timescale 1ns/1ps
module m007_matrix_a_tb;
 logic clk=0;always #1 clk=~clk;
 logic rst_n=0,cfg_valid=0,cfg_ready,cfg_slot=0;logic [15:0] cfg_k=1024;
 logic [63:0] cfg_request=0;logic [31:0] cfg_generation=0,cfg_epoch=0;
 logic cfg_rsp_valid,cfg_rsp_ready=0,cfg_rsp_slot;logic [1:0] cfg_status;logic [15:0] cfg_rsp_k;logic [63:0] cfg_rsp_request;logic [31:0] cfg_rsp_generation,cfg_rsp_epoch;logic [6:0] error_row,error_group;
 logic wr_valid=0,wr_ready;logic [6:0] wr_row,wr_group;logic [271:0] wr_data;logic [63:0] wr_request;logic [31:0] wr_generation,wr_epoch;
 logic wr_rsp_valid,wr_rsp_ready=1;logic [6:0] wr_rsp_row,wr_rsp_group;
 logic lease_valid=0,lease_ready,lease_slot=0;logic [63:0] lease_request;logic [31:0] lease_generation,lease_epoch;
 logic rd_valid=0,rd_ready,rd_slot=0;logic [2:0] rd_m;logic [6:0] rd_group;logic [95:0] rd_tag;logic [63:0] rd_request;logic [31:0] rd_generation,rd_epoch;
 logic rd_rsp_valid,rd_rsp_ready,rd_rsp_slot;logic [95:0] rd_rsp_tag;logic [4351:0] rd_rsp_data;
 logic ret_valid,ret_ready,ret_slot;logic [95:0] ret_tag;logic [63:0] ret_request;logic [31:0] ret_generation,ret_epoch;
 logic release_valid=0,release_ready,release_slot=0;logic [63:0] release_request;logic [31:0] release_generation,release_epoch;
 logic [1:0] slot_valid,slot_leased;logic [6:0] read_debt;
 laya_m007_a_cache_v1 dut(.fill_cancel_ready(),.fill_cancel_reject_valid(),.fill_cancel_reject_code(),.fill_cancel_rsp_valid(),.fill_cancel_rsp_slot(),.fill_cancel_rsp_request(),.fill_cancel_rsp_generation(),.fill_cancel_rsp_epoch(),.fill_cancel_valid(1'b0),.fill_cancel_slot(1'b0),.fill_cancel_request(64'b0),.fill_cancel_generation(32'b0),.fill_cancel_epoch(32'b0),.fill_cancel_rsp_ready(1'b1),.*);
 logic [63:0] requests[0:1];logic [31:0] generations[0:1],epochs[0:1];integer groups[0:1];
 logic [95:0] returns[0:63];logic return_slots[0:63];integer qhead=0,qtail=0,qcount=0;
 logic allow_return=1,wrong_return=0,stall_output=0;
 integer cycle=0,checks=0,writes=0,overlap=0,peak_debt=0,first_accept,last_accept,accepted_in_scan;
 logic stalled=0;logic [4351:0] held_data;logic [95:0] held_tag;
 function automatic logic [271:0] word(input integer r,g,slot,input logic [31:0] gen);
  logic [255:0] q;logic [15:0] scale;
  for(integer j=0;j<32;j=j+1)q[8*j+:8]=8'(r*13+g*7+j*3+47*slot+gen);
  scale=16'h3000+((r+g)%1024);if(r==0&&g==0)scale=16'h8000;
  return {scale,q};
 endfunction
 function automatic logic [4351:0] record(input integer m,g,slot);
  logic [4095:0] q;logic [255:0] scales;logic [271:0] b;
  for(integer a=0;a<16;a=a+1)begin b=word(16*m+a,g,slot,generations[slot]);q[256*a+:256]=b[255:0];scales[16*a+:16]=b[271:256];end
  return {scales,q};
 endfunction
 always_comb begin
  ret_valid=allow_return&&qcount>0;ret_slot=return_slots[qtail];ret_tag=returns[qtail]^(wrong_return?96'd1:96'd0);
  ret_request=requests[ret_slot];ret_generation=generations[ret_slot];ret_epoch=epochs[ret_slot];
 end
 always @(negedge clk)rd_rsp_ready<=!(stall_output&&cycle%17<3);
 always @(posedge clk)begin
  cycle<=cycle+1;
  if(!rst_n)begin qhead<=0;qtail<=0;qcount<=0;stalled=0;end
  else begin
   if(stalled&&(!rd_rsp_valid||rd_rsp_data!==held_data||rd_rsp_tag!=held_tag))$fatal(1,"A read response hold");
   stalled=rd_rsp_valid&&!rd_rsp_ready;held_data=rd_rsp_data;held_tag=rd_rsp_tag;
   if(ret_valid&&ret_ready)qtail<=(qtail+1)%64;
   if(rd_rsp_valid&&rd_rsp_ready)begin
    if(rd_rsp_data!==record(rd_rsp_tag[9:7],rd_rsp_tag[6:0],rd_rsp_slot))$fatal(1,"A record data/scale mapping slot=%0d m=%0d g=%0d",rd_rsp_slot,rd_rsp_tag[9:7],rd_rsp_tag[6:0]);
    returns[qhead]<=rd_rsp_tag;return_slots[qhead]<=rd_rsp_slot;qhead<=(qhead+1)%64;checks=checks+1;
    if(dut.filling)overlap=overlap+1;
   end
   case({rd_rsp_valid&&rd_rsp_ready,ret_valid&&ret_ready})2'b10:qcount<=qcount+1;2'b01:qcount<=qcount-1;default:;endcase
   if(read_debt>peak_debt)peak_debt=read_debt;
   if(wr_valid&&wr_ready)writes=writes+1;
  end
  if(cycle>250000)$fatal(1,"A cache bounded cycle watchdog");
 end
 task automatic fill(input integer target,k,mode);
  integer gg,rr,group;logic [271:0] data;
  begin
   @(negedge clk);cfg_slot=target;cfg_k=k;cfg_request=cfg_request+1;cfg_generation=cfg_generation+1;cfg_epoch=cfg_epoch+1;cfg_valid=1;
   do @(posedge clk);while(!cfg_ready);
   @(negedge clk);cfg_valid=0;gg=k/32;
   wr_request=cfg_request;wr_generation=cfg_generation;wr_epoch=cfg_epoch;
   for(integer r=0;r<128;r=r+1)for(integer g=0;g<gg;g=g+1)begin
    rr=(mode==1)?127-r:r;group=(mode==1)?gg-1-g:g;
    @(negedge clk);wr_valid=1;wr_row=rr;wr_group=group;data=word(rr,group,target,cfg_generation);
    if(mode==1&&((rr==7&&group==5)||(rr==1&&group==2)))data[271:256]=16'hbc00;
    wr_data=data;
    do @(posedge clk);while(!wr_ready);
    if(mode==2&&r==0&&g==0)begin @(negedge clk);do @(posedge clk);while(!wr_ready);end
   end
   @(negedge clk);wr_valid=0;wr_rsp_ready=0;
   repeat(5)begin @(negedge clk);if(cfg_rsp_valid)$fatal(1,"A published before last write ack consumption");end
   wr_rsp_ready=1;wait(cfg_rsp_valid);@(negedge clk);
   if(cfg_status!=(mode==1?2:mode==2?3:0)||cfg_rsp_request!=cfg_request||cfg_rsp_generation!=cfg_generation||cfg_rsp_epoch!=cfg_epoch||cfg_rsp_k!=k||cfg_rsp_slot!=target)$fatal(1,"A cfg status or identity mode=%0d status=%0d",mode,cfg_status);
   if(mode==1&&(error_row!=1||error_group!=2))$fatal(1,"A numeric error not minimum original row/group");
   repeat(3)begin @(negedge clk);if(!cfg_rsp_valid)$fatal(1,"A cfg response hold");end
   requests[target]=cfg_request;generations[target]=cfg_generation;epochs[target]=cfg_epoch;groups[target]=gg;
   cfg_rsp_ready=1;@(negedge clk);cfg_rsp_ready=0;
  end
 endtask
 task automatic acquire(input integer sl);
  begin
   @(negedge clk);lease_slot=sl;lease_request=requests[sl];lease_generation=generations[sl];lease_epoch=epochs[sl]+1;lease_valid=1;
   @(posedge clk);if(lease_ready)$fatal(1,"A wrong source epoch lease accepted");
   @(negedge clk);lease_epoch=epochs[sl];@(posedge clk);if(!lease_ready)$fatal(1,"A correct lease rejected");
   @(negedge clk);lease_valid=0;
  end
 endtask
 task automatic issue_reads(input integer sl,count,offset,rate);
  begin
   first_accept=-1;last_accept=-1;accepted_in_scan=0;
   for(integer i=offset;i<offset+count;i=i+1)begin
    @(negedge clk);rd_slot=sl;rd_m=i/groups[sl];rd_group=i%groups[sl];rd_tag={32'h12120000,32'(i),22'b0,3'(i/groups[sl]),7'(i%groups[sl])};rd_request=requests[sl];rd_generation=generations[sl];rd_epoch=epochs[sl];rd_valid=1;
    do @(posedge clk);while(!rd_ready);
    if(first_accept<0)first_accept=cycle;
    if(rate&&last_accept>=0&&cycle-last_accept!=1)$fatal(1,"A peak accept II not1");
    last_accept=cycle;accepted_in_scan=accepted_in_scan+1;
   end
   @(negedge clk);rd_valid=0;
  end
 endtask
 task automatic release_slot_task(input integer sl);
  begin
   wait(read_debt==0&&qcount==0);@(negedge clk);release_slot=sl;release_request=requests[sl];release_generation=generations[sl];release_epoch=epochs[sl];release_valid=1;
   @(posedge clk);if(!release_ready)$fatal(1,"A release blocked with zero debt");@(negedge clk);release_valid=0;
  end
 endtask
 initial begin
  for(integer sl=0;sl<2;sl++)begin requests[sl]=0;generations[sl]=0;epochs[sl]=0;groups[sl]=32;end
  repeat(5)@(negedge clk);rst_n=1;
  fill(0,1024,0);acquire(0);stall_output=1;
  fork fill(1,4096,0);issue_reads(0,256,0,0);join
  if(overlap==0)$fatal(1,"A no real alternate fill/read overlap");
  stall_output=0;release_slot_task(0);acquire(1);issue_reads(1,1024,0,1);release_slot_task(1);
  fill(0,2624,0);acquire(0);allow_return=0;issue_reads(0,64,0,1);wait(qcount==64);
  @(negedge clk);rd_slot=0;rd_group=64;rd_m=0;rd_tag=64;rd_valid=1;
  release_slot=0;release_request=requests[0];release_generation=generations[0];release_epoch=epochs[0];release_valid=1;
  repeat(5)begin @(posedge clk);if(rd_ready||release_ready||read_debt!=64)$fatal(1,"A return credit/release protection");end
  @(negedge clk);rd_valid=0;release_valid=0;wrong_return=1;allow_return=1;
  repeat(3)begin @(posedge clk);if(ret_ready)$fatal(1,"A wrong return tag accepted");end
  @(negedge clk);wrong_return=0;wait(read_debt==0&&qcount==0);
  issue_reads(0,656,0,1);wait(read_debt==0&&qcount==0);
  @(negedge clk);rd_group=82;rd_m=0;rd_valid=1;repeat(3)begin @(posedge clk);if(rd_ready)$fatal(1,"A G82 read overrun");end
  @(negedge clk);rd_valid=0;
  fill(1,1024,1);if(slot_valid[1]||!slot_valid[0]||!slot_leased[0])$fatal(1,"A numeric failed alternate isolation");issue_reads(0,1,0,0);
  wait(read_debt==0&&qcount==0);fill(1,1024,2);if(slot_valid[1]||!slot_valid[0])$fatal(1,"A duplicate coverage accepted");
  // Retain one accepted record debt across reset; retained payload cannot publish.
  allow_return=0;issue_reads(0,1,0,0);wait(qcount==1);@(negedge clk);rst_n=0;repeat(4)@(negedge clk);rst_n=1;allow_return=1;
  if(slot_valid!=0||slot_leased!=0||read_debt!=0||rd_rsp_valid)$fatal(1,"A reset retained validity/debt");
  fill(0,1024,0);acquire(0);issue_reads(0,256,0,1);release_slot_task(0);
  if(peak_debt!=64)$fatal(1,"A actual64 reservations not reached");
  $display("HARDWARE_AGENT_SIM_PASS M007_MATRIX_A public_records=%0d group_writes=%0d overlap_records=%0d peak_return_reservations=%0d II=1 dual_slot_payload_bytes=1114112 cycles=%0d",checks,writes,overlap,peak_debt,cycle);$finish;
 end
endmodule
