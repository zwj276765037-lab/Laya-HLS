`timescale 1ns/1ps
module m007_weight_supply_tb;
 logic clk=0;always #1.667 clk=~clk;
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
 laya_m007_w_supply_v1 dut(.*);
 logic [511:0] mem0[0:1151],mem1[0:1151],mem2[0:1151],mem3[0:1151];
 logic [4351:0] expected[0:511],saved[0:511];
 logic [7:0] live[0:3];integer bleft[0:3][0:7],bpos[0:3][0:7],eligible[0:3][0:7];logic [63:0] baddr[0:3][0:7];
 integer pick[0:3],rotate[0:3];integer cycle=0,mode=0,total_ar=0,total_r=0,record_checks=0,overlap_reads=0;
 integer peak_tb[0:3],outstanding[0:3];integer first_ar_cycle,rogue_sent=0,late_beats=0,page_splits=0,reordered_completions=0,interleaved_beats=0;
 logic [3:0] ar_stalled;logic [3:0][74:0] held_ar;integer last_id[0:3];logic [63:0] oldest;
 logic [3:0][63:0] memory_start;
 string fixture,casepath;integer gcount=32;
 logic [3:0][31:0] ar_before;integer sl;logic [63:0] active_req[0:1];logic [31:0] active_gen[0:1],active_tensor[0:1];
 function automatic logic [511:0] get_word(input integer p,input integer idx);
  case(p)0:return mem0[idx];1:return mem1[idx];2:return mem2[idx];default:return mem3[idx];endcase
 endfunction
 always_comb begin
  arready=4'hf;rvalid=0;rid=0;rdata=0;rresp=0;rlast=0;
  for(integer p=0;p<4;p=p+1)begin
   if(mode==7&&cycle%11==0)arready[p]=0;
   pick[p]=-1;
   for(integer x=7;x>=0;x=x-1)if(live[p][(rotate[p]+x)%8]&&cycle>=eligible[p][(rotate[p]+x)%8])pick[p]=(rotate[p]+x)%8;
   if(pick[p]>=0&&cycle%2==0&&!(mode==7&&cycle%13<3))begin
    if(!(mode==10&&p==0&&(baddr[p][pick[p]]+64*bpos[p][pick[p]]==memory_start[p]+gcount*576-64)))begin
    if(!(mode==6&&(baddr[p][pick[p]]+64*bpos[p][pick[p]]==memory_start[p]+gcount*576-64)&&cycle<eligible[p][pick[p]]+180))begin
     rvalid[p]=1;rid[p]=pick[p];
     rdata[p]=get_word(p,((baddr[p][pick[p]]-memory_start[p])>>6)+bpos[p][pick[p]]);
     rlast[p]=(bpos[p][pick[p]]+1==bleft[p][pick[p]]);
     if(baddr[p][pick[p]]+64*bpos[p][pick[p]]==memory_start[p]+512&&p==0)begin
      if(mode==1)rdata[p][256]=~rdata[p][256];
      if(mode==2||mode==8)rdata[p][14:10]=31;
      if(mode==9)rdata[p][15]=1;
     end
     if(baddr[p][pick[p]]==memory_start[p]&&bpos[p][pick[p]]==0&&p==0)begin
      if(mode==3||mode==8)rresp[p]=2;
      if(mode==4)rlast[p]=1;
     end
    end
   end
    end
   if(mode==5&&!rogue_sent&&p==0&&arvalid[0]&&live[0]==0)begin rvalid[0]=1;rid[0]=7;rdata[0]=0;rlast[0]=1;end
  end
 end
 always @(posedge clk)begin
  cycle<=cycle+1;
  if(rst)begin
   for(integer p=0;p<4;p=p+1)begin live[p]<=0;rotate[p]<=0;peak_tb[p]<=0;outstanding[p]<=0;end
   rogue_sent<=0;ar_stalled<=0;for(integer p=0;p<4;p=p+1)last_id[p]<=-1;
  end else begin
   for(integer p=0;p<4;p=p+1)begin
    if(ar_stalled[p]&&(!arvalid[p]||held_ar[p]!={araddr[p],arid[p],arlen[p]}))$fatal(1,"AR hold violated");
    ar_stalled[p]<=arvalid[p]&&!arready[p];held_ar[p]<={araddr[p],arid[p],arlen[p]};
    if(arvalid[p]&&arready[p])begin
     if(live[p][arid[p]])$fatal(1,"AXI ID reused with accepted debt");
     if(arlen[p]>15||araddr[p][5:0]!=0||({1'b0,araddr[p][11:0]}+64*(arlen[p]+1)>4096))$fatal(1,"AXI page/length/alignment");
     if(araddr[p][11:0]==0&&araddr[p]!=memory_start[p])page_splits<=page_splits+1;
     live[p][arid[p]]<=1;baddr[p][arid[p]]<=araddr[p];bleft[p][arid[p]]<=arlen[p]+1;bpos[p][arid[p]]<=0;eligible[p][arid[p]]<=cycle+40+2*(7-arid[p]);
     total_ar<=total_ar+1;
    end
    if(rvalid[p]&&rready[p])begin
     total_r<=total_r+1;
      end
   if(mode==5&&!rogue_sent&&p==0&&live[0]==0)rogue_sent<=1;
     else begin
      if(!live[p][rid[p]])$fatal(1,"peer lost burst");
      if(last_id[p]>=0&&last_id[p]!=rid[p])interleaved_beats=interleaved_beats+1;
      last_id[p]<=rid[p];
      if(bpos[p][rid[p]]+1==bleft[p][rid[p]])begin
       oldest=baddr[p][rid[p]];
       for(integer id=0;id<8;id=id+1)if(live[p][id]&&baddr[p][id]<oldest)oldest=baddr[p][id];
       if(baddr[p][rid[p]]>oldest)reordered_completions=reordered_completions+1;
       live[p][rid[p]]<=0;
      end
      else bpos[p][rid[p]]<=bpos[p][rid[p]]+1;
      rotate[p]<=(rid[p]+1)%8;
     end
    end
    outstanding[p]=0;for(integer z=0;z<8;z=z+1)if(live[p][z])outstanding[p]=outstanding[p]+1;
    if(outstanding[p]>peak_tb[p])peak_tb[p]<=outstanding[p];
   end
  end
  if(cycle>1000000)$fatal(1,"bounded cycle watchdog");
 end
 task automatic prepare(input integer which);
  begin
   case(which)
    0:begin casepath={fixture,"/qkv_0_weight"};load_k=1024;load_n=3072;load_s=0;end
    1:begin casepath={fixture,"/mlp_wi_0_weight"};load_k=1024;load_n=5248;load_s=81;end
    2:begin casepath={fixture,"/mlp_wo_0_weight"};load_k=2624;load_n=1024;load_s=0;end
    3:begin casepath={fixture,"/head_fc2_0_weight"};load_k=4096;load_n=1024;load_s=0;end
   endcase
   gcount=load_k/32;
   $readmemh({casepath,"/p0.hex"},mem0,0,gcount*9-1);$readmemh({casepath,"/p1.hex"},mem1,0,gcount*9-1);
   $readmemh({casepath,"/p2.hex"},mem2,0,gcount*9-1);$readmemh({casepath,"/p3.hex"},mem3,0,gcount*9-1);$readmemh({casepath,"/expected.hex"},expected,0,gcount*4-1);
   for(integer p=0;p<4;p=p+1)begin
    load_base[p]=64'h100000000+64'h10000000*p;load_span[p]=576*gcount*((load_n==5248)?82:(load_n/64));
    memory_start[p]=load_base[p]+load_s*gcount*576;
   end
   load_request=load_request+1;load_generation=load_generation+1;load_tensor=which+1;
  end
 endtask
 task automatic begin_load(input integer target);
  begin
   @(negedge clk);ar_before=accepted_ar;load_slot=target;load_valid=1;
   do @(posedge clk);while(!load_ready);
   @(negedge clk);load_valid=0;
  end
 endtask
 task automatic finish_load(input integer status,input integer perf);
  integer cap;logic [1023:0] held;
  begin
   wait(load_rsp_valid);@(negedge clk);
   if(load_status!=status)$fatal(1,"load status got=%d expected=%d errors n=%d g=%d reader=%h pad=%h coverage_err=%h covered=%d groups=%d beat=%h",load_status,status,error_n,error_g,dut.reader_errors,dut.pad_error,dut.coverage_error,dut.covered,dut.groups,dut.beat);
   if(rsp_version!=load_version||rsp_model!=load_model||rsp_tensor!=load_tensor||rsp_request!=load_request||rsp_generation!=load_generation||rsp_k!=load_k||rsp_n!=load_n||rsp_s!=load_s||rsp_slot!=load_slot||rsp_base!=load_base||rsp_span!=load_span)$fatal(1,"LOAD response identity");
   if(status==1&&(accepted_ar!=ar_before||arvalid!=0))$fatal(1,"invalid descriptor issued AR");
   if(perf)begin
    cap=256+(4*gcount*576+95)/96;
    if(load_cycles>cap)$fatal(1,"service curve cycles=%d cap=%d",load_cycles,cap);
    for(integer p=0;p<4;p=p+1)if(peak_inflight[p]!=8||peak_tb[p]!=8)$fatal(1,"not eight actual outstanding port=%d DUT=%d peer=%d",p,peak_inflight[p],peak_tb[p]);
    $display("M007_SERVICE_PASS K=%0d N=%0d s=%0d cycles=%0d cap=%0d bytes=%0d AR=%0d,%0d,%0d,%0d R=%0d,%0d,%0d,%0d peak=8,8,8,8",load_k,load_n,load_s,load_cycles,cap,4*gcount*576,accepted_ar[0],accepted_ar[1],accepted_ar[2],accepted_ar[3],accepted_r[0],accepted_r[1],accepted_r[2],accepted_r[3]);
   end
   for(integer p=0;p<4;p=p+1)if(live[p]!=0)$fatal(1,"LOAD completed with accepted AXI debt");
   held={load_status,rsp_request,rsp_generation,rsp_model,rsp_tensor,rsp_base,rsp_span};
   repeat(5)begin @(negedge clk);if(!load_rsp_valid||held!={load_status,rsp_request,rsp_generation,rsp_model,rsp_tensor,rsp_base,rsp_span})$fatal(1,"LOAD response hold");end
   active_req[load_slot]=rsp_request;active_gen[load_slot]=rsp_generation;active_tensor[load_slot]=rsp_tensor;
   load_rsp_ready=1;@(negedge clk);load_rsp_ready=0;
  end
 endtask
 task automatic acquire(input integer target);
  begin
   @(negedge clk);lease_slot=target;lease_request=active_req[target];lease_generation=active_gen[target];lease_model=load_model;lease_tensor=active_tensor[target];lease_valid=1;
   lease_generation=lease_generation+1;@(posedge clk);if(lease_ready)$fatal(1,"wrong-generation lease accepted");
   @(negedge clk);lease_generation=active_gen[target];
   @(posedge clk);if(!lease_ready)$fatal(1,"lease rejected");
   @(negedge clk);lease_valid=0;
  end
 endtask
 task automatic read_one(input integer target,input integer address,input logic [4351:0] gold,input integer windows);
  logic [4351:0] hold_data;logic [63:0] tag;
  begin
   @(negedge clk);rd_slot=target;rd_addr=address;rd_model=load_model;rd_tensor=active_tensor[target];rd_request=active_req[target];rd_generation=active_gen[target];rd_tag=64'habc00000+record_checks;tag=rd_tag;
   // Wrong generation must never produce an effective read.
   rd_generation=rd_generation+1;rd_valid=1;@(posedge clk);if(rd_ready)$fatal(1,"wrong generation read accepted");
   @(negedge clk);rd_generation=active_gen[target];rd_model=load_model^1;
   @(posedge clk);if(rd_ready)$fatal(1,"wrong model epoch accepted");
   @(negedge clk);rd_model=load_model;rd_tensor=active_tensor[target]^1;
   @(posedge clk);if(rd_ready)$fatal(1,"wrong tensor key accepted");
   @(negedge clk);rd_tensor=active_tensor[target];
   do @(posedge clk);while(!rd_ready);
   @(negedge clk);rd_valid=0;
   release_slot=target;release_request=active_req[target];release_generation=active_gen[target];release_valid=1;
   if(release_ready)$fatal(1,"release accepted with pending synchronous read");
   wait(rd_rsp_valid);@(negedge clk);
   if(rd_rsp_data!==gold||rd_rsp_tag!=tag||rd_rsp_slot!=target)$fatal(1,"cache read mismatch slot=%d address=%d",target,address);
   hold_data=rd_rsp_data;
   for(integer w=0;w<windows;w=w+1)begin
    @(negedge clk);if(!rd_rsp_valid||rd_rsp_data!==hold_data||rd_rsp_tag!=tag)$fatal(1,"record hold at M16 window %d",w);
    if(dut.loading)overlap_reads=overlap_reads+1;
   end
   release_slot=target;release_request=active_req[target];release_generation=active_gen[target];release_valid=1;
   @(posedge clk);if(release_ready)$fatal(1,"released while response unconsumed");
   @(negedge clk);release_valid=0;rd_rsp_ready=1;
   @(negedge clk);rd_rsp_ready=0;
   ret_slot=target;ret_request=active_req[target];ret_generation=active_gen[target]+1;ret_tag=tag;ret_valid=1;
   @(posedge clk);if(ret_ready)$fatal(1,"wrong generation return accepted");
   @(negedge clk);ret_generation=active_gen[target];
   @(posedge clk);if(!ret_ready)$fatal(1,"correct return blocked");
   @(negedge clk);ret_valid=0;record_checks=record_checks+1;
  end
 endtask
 task automatic drop_lease(input integer target);
  begin
   @(negedge clk);release_slot=target;release_request=active_req[target];release_generation=active_gen[target];release_valid=1;
   @(posedge clk);if(!release_ready)$fatal(1,"release blocked without debt");
   @(negedge clk);release_valid=0;
  end
 endtask
 task automatic scan(input integer target,input integer groups,input integer usesaved);
  begin for(integer a=0;a<4*groups;a=a+1)read_one(target,a,usesaved?saved[a]:expected[a],8);end
 endtask
 initial begin
  if(!$value$plusargs("FIXTURE=%s",fixture))$fatal(1,"FIXTURE required");
  load_base=0;load_span=0;memory_start=0;
  repeat(5)@(negedge clk);rst=0;
  prepare(0);begin_load(0);finish_load(0,1);acquire(0);
  for(integer a=0;a<128;a=a+1)saved[a]=expected[a];
  // Leased active slot rejects overwrite without issuing any AR.
  @(negedge clk);load_valid=1;load_slot=0;repeat(4)begin @(posedge clk);if(load_ready)$fatal(1,"active leased slot overwritten");end
  @(negedge clk);load_valid=0;
  prepare(3);begin_load(1);
  fork
   begin scan(0,32,1);end
   begin finish_load(0,1);end
  join
  if(overlap_reads==0)$fatal(1,"no actual active-read/prefetch overlap");drop_lease(0);acquire(1);scan(1,128,0);drop_lease(1);
  prepare(1);begin_load(0);finish_load(0,1);acquire(0);scan(0,32,0);drop_lease(0);
  prepare(2);begin_load(0);finish_load(0,1);acquire(0);scan(0,82,0);
  for(integer a=0;a<328;a=a+1)saved[a]=expected[a];
  // Failure of alternate slot must leave every byte of leased slot zero intact.
  for(integer m=1;m<=8;m=m+1)begin
   prepare(0);mode=m;begin_load(1);finish_load((m==1||m==4||m==5)?3:((m==2)?4:((m==6||m==7)?0:2)),m==7);
   if(m==2&&(error_n!=0||error_g!=0))$fatal(1,"numeric global coordinates");
   if(!slot_valid[0]||!slot_leased[0])$fatal(1,"alternate failure destroyed active slot");
   read_one(0,0,saved[0],8);read_one(0,327,saved[327],8);
   mode=0;
  end
  // Finite negative scales remain legal, without redefining source expectations.
  prepare(0);mode=9;begin_load(1);finish_load(0,0);mode=0;
  // Illegal descriptors issue no AR, with full response identity and hold.
  prepare(0);load_span[2]=64;begin_load(1);finish_load(1,0);
  prepare(0);load_base[0]=load_base[0]+64;begin_load(1);finish_load(1,0);
  prepare(0);load_base[0]=64'hfffffffffffff000;begin_load(1);finish_load(1,0);
  prepare(0);load_k=1000;begin_load(1);finish_load(1,0);
  prepare(1);load_s=82;begin_load(1);finish_load(1,0);
  drop_lease(0);
  // Common reset discards all pre-reset transaction validity. New generation must
  // build real coverage before any new read; peer reset clears its old debts.
  prepare(0);mode=10;begin_load(1);repeat(1000)@(negedge clk);
  if(load_rsp_valid||live[0]==0)$fatal(1,"missing real R debt was fabricated/forgotten");
  $display("M007_MISSING_R_DEBT_PASS pending_port0=%h accepted_R=%0d",live[0],accepted_r[0]);
  rst=1;repeat(4)@(negedge clk);rst=0;mode=0;
  if(slot_valid!=0||slot_leased!=0||rd_rsp_valid||load_rsp_valid)$fatal(1,"reset retained validity");
  prepare(0);begin_load(0);finish_load(0,1);acquire(0);scan(0,32,0);drop_lease(0);
  if(reordered_completions==0||interleaved_beats==0)$fatal(1,"no real out-of-order/interleaved responses");
  $display("M007_REORDER_PASS reordered_burst_completions=%0d interleaved_R_beats=%0d",reordered_completions,interleaved_beats);
  $display("HARDWARE_AGENT_SIM_PASS M007_WEIGHT_SUPPLY records=%0d unique_source_records=1096 repeated_error_isolation=16 reset_rechecks=128 overlap_windows=%0d page_boundaries=%0d cycles=%0d",record_checks,overlap_reads,page_splits,cycle);$finish;
 end
endmodule
