`timescale 1ns/1ps
module m007_binary_weight_transport_tb;
 logic clk=0;always #1 clk=~clk;
 logic rst=1,load_valid=0,load_ready,load_rsp_valid,load_rsp_ready=0;
 logic [31:0] load_version=1,load_tensor=1,load_generation=1;
 logic [63:0] load_model=64'h6eb6ef58bc4f99bd,load_request=100;
 logic [15:0] load_k=1024,load_n=3072,load_s=0;logic load_slot=0;
 logic [3:0][63:0] load_base,load_span;logic [2:0] load_status;
 logic [31:0] rsp_version,rsp_tensor,rsp_generation;logic [63:0] rsp_model,rsp_request;
 logic [15:0] rsp_k,rsp_n,rsp_s,error_n,error_g;logic rsp_slot;
 logic [3:0][63:0] rsp_base,rsp_span;logic [31:0] load_cycles;
 logic [3:0] arvalid,arready,rvalid,rready,rlast;
 logic [3:0][63:0] araddr;logic [3:0][2:0] arid,rid;
 logic [3:0][7:0] arlen;logic [3:0][511:0] rdata;logic [3:0][1:0] rresp;
 logic [3:0][3:0] peak_inflight;logic [3:0][31:0] accepted_ar,accepted_r;
 logic lease_valid=0,lease_slot=0,lease_ready;logic [63:0] lease_model,lease_request;logic [31:0] lease_tensor,lease_generation;
 logic rd_valid=0,rd_ready,rd_slot=0;logic [8:0] rd_addr;logic [63:0] rd_tag,rd_model,rd_request;logic [31:0] rd_tensor,rd_generation;
 logic rd_rsp_valid,rd_rsp_ready=0,rd_rsp_slot;logic [4351:0] rd_rsp_data;logic [63:0] rd_rsp_tag;
 logic ret_valid=0,ret_slot=0,ret_ready;logic [63:0] ret_tag,ret_request;logic [31:0] ret_generation;
 logic release_valid=0,release_slot=0,release_ready;logic [63:0] release_request;logic [31:0] release_generation;
 logic [1:0] slot_valid,slot_leased;
 logic transport_idle;
 laya_m007_w_supply_v2 dut(.*);
 logic[735:0]metadata[0:119];logic[127:0]loads[0:15];logic[4351:0]expected[0:4095];
 logic[3:0]peer_arready,peer_rvalid,peer_rlast,allow_ar=0,allow_r=0;
 logic[3:0][2:0]peer_rid;logic[3:0][511:0]peer_rdata;logic[3:0][1:0]peer_rresp;
 logic peer_idle;integer peer_AR,peer_R,peer_peak,peer_hits,peer_misses;
 integer load_count,record_count,cycle=0,records_checked=0,checked_bytes=0,last_progress=0,loads_checked=0;
 integer parser_burst_retirements=0,last_R_before_parser_idle_cycles=0,held_AR=0,held_R=0,held_last=0,overlap_read_cycles=0;
 integer stage_R_goal=0;logic[7:0]reserved[0:3],terminal_seen[0:3];
 logic[3:0]was_AR_held=0,was_R_held=0;logic[3:0][74:0]held_AR_packet;logic[3:0][517:0]held_R_packet;
 logic[3:0]parser_fire,parser_last;logic[3:0][2:0]parser_id;
 logic[63:0]slot_request[0:1];logic[31:0]slot_generation[0:1],slot_tensor[0:1];
 string data_path,meta_path;
 assign arready=peer_arready&allow_ar;assign rvalid=peer_rvalid&allow_r;assign rid=peer_rid;assign rdata=peer_rdata;assign rresp=peer_rresp;assign rlast=peer_rlast;
 m007_binary_weight_peer peer(.clk,.rst_n(!rst),.enable(1'b1),.arvalid(arvalid&allow_ar),.arready(peer_arready),.araddr,.arid,.arlen,.arsize({4{3'd6}}),.arburst({4{2'd1}}),.rvalid(peer_rvalid),.rready(rready&allow_r),.rid(peer_rid),.rdata(peer_rdata),.rresp(peer_rresp),.rlast(peer_rlast),.idle(peer_idle),.accepted_ar(peer_AR),.returned_beats(peer_R),.peak_live(peer_peak),.cache_hits(peer_hits),.cache_misses(peer_misses));
 generate for(genvar p=0;p<4;p++)begin:probes
  assign parser_fire[p]=dut.stream_valid[p]&&dut.stream_ready[p];
  assign parser_last[p]=dut.ports[p].reader.out_last;
  assign parser_id[p]=dut.ports[p].reader.out_slot;
 end endgenerate
 always@(negedge clk)if(!rst)for(int p=0;p<4;p++)begin allow_ar[p]=(cycle%19>2+p);allow_r[p]=(cycle>48)&&(cycle%23>3+p);end
 always@(posedge clk)begin
  cycle++;
  if(rst)for(int p=0;p<4;p++)begin reserved[p]<=0;terminal_seen[p]<=0;end
  else begin
   for(int p=0;p<4;p++)begin
    if(was_AR_held[p]&&(!arvalid[p]||{araddr[p],arid[p],arlen[p]}!==held_AR_packet[p]))$fatal(1,"production AR source/ID changed while held");
    was_AR_held[p]=arvalid[p]&&!arready[p];held_AR_packet[p]={araddr[p],arid[p],arlen[p]};if(was_AR_held[p])held_AR++;
    if(was_R_held[p]&&(!peer_rvalid[p]||{peer_rid[p],peer_rdata[p],peer_rresp[p],peer_rlast[p]}!==held_R_packet[p]))$fatal(1,"immutable source R changed while held");
    was_R_held[p]=peer_rvalid[p]&&!(rready[p]&&allow_r[p]);held_R_packet[p]={peer_rid[p],peer_rdata[p],peer_rresp[p],peer_rlast[p]};if(was_R_held[p])begin held_R++;if(peer_rlast[p])held_last++;end
    if(arvalid[p]&&arready[p])begin
     if(reserved[p][arid[p]])$fatal(1,"production ID reused before actual last parser consumption");reserved[p][arid[p]]<=1;terminal_seen[p][arid[p]]<=0;
    end
    if(rvalid[p]&&rready[p]&&rlast[p])begin if(!reserved[p][rid[p]])$fatal(1,"real last R without parser reservation");terminal_seen[p][rid[p]]<=1;end
    if(parser_fire[p]&&parser_last[p])begin
     if(!reserved[p][parser_id[p]]||!terminal_seen[p][parser_id[p]])$fatal(1,"last parser consumption before actual last R/debt");
     reserved[p][parser_id[p]]<=0;terminal_seen[p][parser_id[p]]<=0;parser_burst_retirements++;
    end
    if(dut.reader_idle[p]&&(dut.stream_valid[p]||reserved[p]!=0))$fatal(1,"reader idle with held output/parser reservation");
   end
   if(stage_R_goal>0&&peer_R==stage_R_goal&&peer_idle&&!(&dut.reader_idle))last_R_before_parser_idle_cycles++;
   if(load_rsp_valid&&(!peer_idle||!(&dut.reader_idle)))$fatal(1,"LOAD response before real parser/transport drain");
   if(rd_rsp_valid&&dut.loading)overlap_read_cycles++;
   if(cycle>200000)$fatal(1,"bounded production transport watchdog");
  end
 end
 task automatic begin_load(input integer ci,target);
  integer d;
  begin
   @(negedge clk);d=int'(loads[ci][6:0]);load_version=1;load_model=64'h6eb6ef58bc4f99bd;load_tensor=loads[ci][54:23];load_request=100+ci;load_generation=1+ci;load_k=metadata[d][15:0];load_n=metadata[d][31:16];load_s=loads[ci][22:7];load_slot=target;
   for(int p=0;p<4;p++)begin load_base[p]=metadata[d][224+128*p+:64];load_span[p]=metadata[d][288+128*p+:64];end
   stage_R_goal=peer_R+4*(load_k/32)*9;load_valid=1;do @(posedge clk);while(!load_ready);
   @(negedge clk);load_valid=0;
   // The current caller descriptor changes while accepted ARs are still live.
   // A correct source is selected only from immutable AR-address metadata.
   load_tensor=32'hdeadbeef;load_k=4096;load_n=1024;load_s=15;load_base=0;load_span=0;load_request=64'hbad;load_generation=32'hbad;
  end
 endtask
 task automatic finish_load(input integer ci,target);
  integer d;logic[787:0]held;
  begin
   d=int'(loads[ci][6:0]);wait(load_rsp_valid);@(negedge clk);
   if(load_status!=0||rsp_version!=1||rsp_model!=64'h6eb6ef58bc4f99bd||rsp_tensor!=loads[ci][54:23]||rsp_request!=100+ci||rsp_generation!=1+ci||rsp_k!=metadata[d][15:0]||rsp_n!=metadata[d][31:16]||rsp_s!=loads[ci][22:7]||rsp_slot!=target)$fatal(1,"actual catalog descriptor load status/identity ci=%0d status=%0d",ci,load_status);
   for(int p=0;p<4;p++)if(rsp_base[p]!==metadata[d][224+128*p+:64]||rsp_span[p]!==metadata[d][288+128*p+:64]||reserved[p]!=0)$fatal(1,"response descriptor changed before parser drain");
   held={load_status,rsp_version,rsp_model,rsp_tensor,rsp_request,rsp_generation,rsp_k,rsp_n,rsp_s,rsp_slot,rsp_base,rsp_span};
   repeat(6)begin @(negedge clk);if(!load_rsp_valid||transport_idle||held!=={load_status,rsp_version,rsp_model,rsp_tensor,rsp_request,rsp_generation,rsp_k,rsp_n,rsp_s,rsp_slot,rsp_base,rsp_span})$fatal(1,"held LOAD response/true idle");end
   slot_request[target]=rsp_request;slot_generation[target]=rsp_generation;slot_tensor[target]=rsp_tensor;
   load_rsp_ready=1;@(negedge clk);load_rsp_ready=0;loads_checked++;
   $display("M007_BINARY_TRANSPORT_LOAD ci=%0d tensor=%0d K=%0d N=%0d s=%0d parser_retired=%0d cycle=%0d",ci,rsp_tensor,rsp_k,rsp_n,rsp_s,parser_burst_retirements,cycle);$fflush();
  end
 endtask
 task automatic acquire(input integer target);
  begin
   @(negedge clk);lease_slot=target;lease_request=slot_request[target];lease_generation=slot_generation[target];lease_model=64'h6eb6ef58bc4f99bd;lease_tensor=slot_tensor[target];lease_valid=1;
   do @(posedge clk);while(!lease_ready);@(negedge clk);lease_valid=0;if(transport_idle)$fatal(1,"leased slot hidden by transport idle");
  end
 endtask
 task automatic release_slot_task(input integer target);
  begin
   @(negedge clk);release_slot=target;release_request=slot_request[target];release_generation=slot_generation[target];release_valid=1;
   do @(posedge clk);while(!release_ready);@(negedge clk);release_valid=0;
  end
 endtask
 task automatic scan(input integer ci,target);
  integer groups,base_record;logic[4351:0]gold,held;logic[63:0]tag;
  begin
   groups=int'(metadata[int'(loads[ci][6:0])][15:0])/32;base_record=int'(loads[ci][86:55]);
   for(int a=0;a<4*groups;a++)begin
    gold=expected[base_record+a];tag=64'habc00000+64'(records_checked);
    @(negedge clk);rd_slot=target;rd_addr=9'(a);rd_model=64'h6eb6ef58bc4f99bd;rd_tensor=slot_tensor[target];rd_request=slot_request[target];rd_generation=slot_generation[target];rd_tag=tag;rd_valid=1;
    do @(posedge clk);while(!rd_ready);@(negedge clk);rd_valid=0;wait(rd_rsp_valid);@(negedge clk);
    if(rd_rsp_data!==gold||rd_rsp_tag!=tag||rd_rsp_slot!=target)$fatal(1,"direct GGUF cache record mismatch ci=%0d record=%0d",ci,a);
    held=rd_rsp_data;
    if(a==0||a==4*groups-1)repeat(7)begin @(negedge clk);if(!rd_rsp_valid||rd_rsp_data!==held||rd_rsp_tag!=tag||transport_idle)$fatal(1,"held actual cache response not stable/debt idle");end
    rd_rsp_ready=1;@(negedge clk);rd_rsp_ready=0;ret_slot=target;ret_request=slot_request[target];ret_generation=slot_generation[target];ret_tag=tag;ret_valid=1;
    do @(posedge clk);while(!ret_ready);@(negedge clk);ret_valid=0;
    records_checked++;checked_bytes+=544;if(checked_bytes-last_progress>=4096)begin $display("M007_PARENT_CHECKED checked=%0d phase=BINARY_W_TRANSPORT cycle=%0d",checked_bytes,cycle);$fflush();last_progress=checked_bytes;end
   end
  end
 endtask
 initial begin
  if(!$value$plusargs("PEER_DATA=%s",data_path)||!$value$plusargs("PEER_META=%s",meta_path)||!$value$plusargs("LOADS=%d",load_count)||!$value$plusargs("RECORDS=%d",record_count))$fatal(1,"production transport fixture arguments");
  if(load_count<2||load_count>16||record_count>4096)$fatal(1,"bounded transport fixture capacity");
  $readmemh(meta_path,metadata);$readmemh({data_path,"/transport_loads.hex"},loads,0,load_count-1);$readmemh({data_path,"/transport_expected.hex"},expected,0,record_count-1);
  load_base=0;load_span=0;repeat(5)@(negedge clk);rst=0;
  begin_load(0,0);finish_load(0,0);acquire(0);
  for(int ci=1;ci<load_count;ci++)begin
   begin_load(ci,ci%2);
   fork begin scan(ci-1,(ci-1)%2);end begin finish_load(ci,ci%2);end join
   release_slot_task((ci-1)%2);acquire(ci%2);
  end
  scan(load_count-1,(load_count-1)%2);release_slot_task((load_count-1)%2);wait(transport_idle);repeat(5)@(negedge clk);
  if(records_checked!=record_count||loads_checked!=load_count||peer_AR!=parser_burst_retirements||!peer_idle||slot_leased!=0||held_AR==0||held_R==0||held_last==0||last_R_before_parser_idle_cycles==0||overlap_read_cycles==0)$fatal(1,"production transport coverage/retirement counts");
  $display("HARDWARE_AGENT_SIM_PASS M007_BINARY_W_TRANSPORT loads=%0d records=%0d checked_bytes=%0d AR=%0d R=%0d parser_bursts=%0d peak_live=%0d held_AR=%0d held_R=%0d held_last=%0d lastR_before_parser_idle=%0d overlap_reads=%0d cycles=%0d",loads_checked,records_checked,checked_bytes,peer_AR,peer_R,parser_burst_retirements,peer_peak,held_AR,held_R,held_last,last_R_before_parser_idle_cycles,overlap_read_cycles,cycle);$fflush();$finish;
 end
endmodule
