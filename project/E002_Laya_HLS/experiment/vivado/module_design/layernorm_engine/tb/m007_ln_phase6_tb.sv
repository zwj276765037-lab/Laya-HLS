`timescale 1ns/1ps
module m007_ln_phase6_tb;
 localparam int LANES=256,ADD_GROUPS=7;
 logic clk=0,rst_n=0;always#5 clk=~clk;
 logic lease_valid=0,lease_ready,release_valid=0,release_ready,phase_debt_clear=1,lease_active,draining;
 logic[63:0]lease_request_id=64'h14600001,rsp_request_id;
 logic[31:0]lease_generation=31,lease_epoch=51,release_epoch=51,rsp_generation,rsp_epoch;
 logic[3:0]lease_head=0,rsp_head;logic[2:0]lease_phase=6,release_phase=6,rsp_phase;
 logic mul_req_valid,mul_req_ready,mul_rsp_valid,mul_rsp_ready;
 logic[2:0]mul_req_phase;logic[31:0]mul_req_epoch;logic[95:0]mul_req_tag,mul_rsp_tag;
 logic[255:0][31:0]mul_a,mul_b,mul_rsp_data;
 logic[6:0]add_req_valid,add_req_is_root,add_req_ready,add_rsp_valid,add_rsp_ready;
 logic[6:0][2:0]add_req_phase;logic[6:0][31:0]add_req_epoch;logic[6:0][95:0]add_req_tag,add_rsp_tag;
 logic[255:0][31:0]add_a,add_b,add_rsp_data;
 logic[6:0]mul_pending;logic[6:0][6:0]add_pending;logic protocol_fault;
 laya_shared_fp256_v2#(.LANES(256),.ADD_GROUPS(7))dut(.*);
 logic[1023:0]raw[0:4095];logic[31:0]tree_gold[0:130943];string fixture;
 integer mode=0,cycle=0,target=10,init_sent=0,init_total=2,tree_done=0;
 integer expected_latency=8,nodes_checked=0,chains=0,full_add_sent=0,full_mul_sent=0,full_add_got=0,full_mul_got=0;
 integer mul_level_sent=0,mul_chain_done=0,add_at[0:63],mul_at[0:63];bit add_seen[0:63],mul_seen[0:63];
 bit consume=1,extra=0;logic[31:0]left_root;bit left_valid=0;integer tree_hold_delay=0;
 bit held_add=0,held_mul=0;logic[8287:0]held_add_record,held_mul_record;integer held_cycles=0;
 function automatic integer tree_offset(input integer level);return 1024-(1024>>(level-1));endfunction
 function automatic logic[31:0]source_word(input integer index);return raw[index/32][32*(index%32)+:32];endfunction
 function automatic logic[95:0]tree_tag(input integer level,input integer half,input integer count);return {64'h4c4e54524545,8'(level),8'(half),16'(count)};endfunction
 wire[7:0]return_level=add_rsp_tag[0][31:24],return_half=add_rsp_tag[0][23:16];wire[15:0]return_count=add_rsp_tag[0][15:0];
 always_comb begin
  add_req_valid=0;add_req_is_root=0;add_req_tag=0;add_rsp_ready=0;add_req_phase=0;add_req_epoch=0;
  mul_req_valid=0;mul_rsp_ready=0;mul_req_tag=0;mul_req_phase=lease_phase;mul_req_epoch=lease_epoch;
  add_a=0;add_b=0;mul_a=0;mul_b=0;
  for(int g=0;g<7;g++)begin add_req_phase[g]=lease_phase;add_req_epoch[g]=lease_epoch;end
  if(mode==1)begin
   add_rsp_ready[0]=consume;
   if(init_sent<init_total)begin
    add_req_valid[0]=1;add_req_is_root[0]=1;add_req_tag[0]=tree_tag(1,init_sent,target==10?256:64);
    for(int l=0;l<256;l++)if(l<(target==10?256:64))begin add_a[l]=source_word(init_sent*512+2*l);add_b[l]=source_word(init_sent*512+2*l+1);end
   end else if(add_rsp_valid[0]&&consume&&return_level<target)begin
    if(target==10&&return_level==9)begin
     if(return_half==1)begin add_req_valid[0]=1;add_req_tag[0]=tree_tag(10,0,1);add_a[0]=left_root;add_b[0]=add_rsp_data[0];end
    end else begin
     add_req_valid[0]=1;add_req_tag[0]=tree_tag(return_level+1,return_half,return_count/2);
     for(int l=0;l<128;l++)if(l<return_count/2)begin add_a[l]=add_rsp_data[2*l];add_b[l]=add_rsp_data[2*l+1];end
    end
   end
  end else if(mode==2)begin
   add_req_valid[0]=full_add_sent<64||extra;mul_req_valid=full_mul_sent<64||extra;add_req_is_root[0]=1;
   add_rsp_ready[0]=consume;mul_rsp_ready=consume;add_req_tag[0]={64'h46414444,32'(full_add_sent)};mul_req_tag={64'h464d554c,32'(full_mul_sent)};
   for(int l=0;l<256;l++)begin add_a[l]=32'h3f800000;add_b[l]=32'h3f800000;mul_a[l]=32'h3f800000;mul_b[l]=32'h3f800000;end
  end else if(mode==3)begin
   mul_rsp_ready=consume;
   if(mul_level_sent==0)begin mul_req_valid=1;mul_req_tag=1;for(int l=0;l<256;l++)begin mul_a[l]=32'h3f800000;mul_b[l]=32'h40000000;end end
   else if(mul_rsp_valid&&consume&&mul_rsp_tag<10)begin mul_req_valid=1;mul_req_tag=mul_rsp_tag+1'b1;for(int l=0;l<256;l++)begin mul_a[l]=mul_rsp_data[l];mul_b[l]=32'h40000000;end end
  end
 end
 always@(posedge clk)begin:monitor
  integer key,base;
  cycle++;if(cycle>200000)$fatal(1,"phase6 cycle limit");
  if(!rst_n)begin held_add=0;held_mul=0;end
  else begin
   if(protocol_fault)$fatal(1,"actual shared FP fault");
   if(held_add&&(!add_rsp_valid[0]||{add_rsp_tag[0],add_rsp_data}!==held_add_record))$fatal(1,"held atomic add result changed");
   if(held_mul&&(!mul_rsp_valid||{mul_rsp_tag,mul_rsp_data}!==held_mul_record))$fatal(1,"held atomic mul result changed");
   held_add=add_rsp_valid[0]&&!add_rsp_ready[0];held_mul=mul_rsp_valid&&!mul_rsp_ready;
   held_add_record={add_rsp_tag[0],add_rsp_data};held_mul_record={mul_rsp_tag,mul_rsp_data};if(held_add||held_mul)held_cycles++;
   if((add_rsp_valid&7'h7e)!=0)$fatal(1,"nonQK atomic return exposed multiple ports");
   if(mode==1)begin
    if(add_req_valid[0]&&add_req_ready[0])begin key=int'(add_req_tag[0][31:24])*2+int'(add_req_tag[0][23:16]);add_at[key]=cycle;add_seen[key]=0;if(add_req_tag[0][31:24]==1)init_sent++;end
    if(add_rsp_valid[0])begin
     key=int'(return_level)*2+int'(return_half);
     if(!add_seen[key])begin
      if(cycle-add_at[key]!=expected_latency+((return_level==1&&return_half==1)?tree_hold_delay:0))$fatal(1,"add dependency latency phase=%0d level=%0d got=%0d expected=%0d head_wait=%0d",lease_phase,return_level,cycle-add_at[key],expected_latency,tree_hold_delay);
      add_seen[key]=1;
     end
     if(!add_rsp_ready[0])tree_hold_delay++;
     base=tree_offset(return_level)+int'(return_half)*int'(return_count);
     for(int l=0;l<256;l++)if(l<return_count&&add_rsp_data[l]!==tree_gold[base+l])$fatal(1,"actual tree node mismatch phase=%0d level=%0d half=%0d node=%0d",lease_phase,return_level,return_half,l);
     if(add_rsp_ready[0])begin
      nodes_checked+=int'(return_count);
      if(target==10&&return_level==9&&return_half==0)begin left_root=add_rsp_data[0];left_valid=1;end
      if(target==10&&return_level==9&&return_half==1&&!left_valid)$fatal(1,"right root before real left");
      if(return_level==target)tree_done=1;
     end
    end
   end else if(mode==2)begin
    if(add_req_valid[0]&&add_req_ready[0])begin if(full_add_sent>=64)$fatal(1,"65th add credit accepted");full_add_sent++;end
    if(mul_req_valid&&mul_req_ready)begin if(full_mul_sent>=64)$fatal(1,"65th mul credit accepted");full_mul_sent++;end
    if(add_rsp_valid[0]&&add_rsp_ready[0])begin if(add_rsp_tag[0][31:0]!=32'(full_add_got))$fatal(1,"full add tag");for(int l=0;l<256;l++)if(add_rsp_data[l]!==32'h40000000)$fatal(1,"full add data");full_add_got++;end
    if(mul_rsp_valid&&mul_rsp_ready)begin if(mul_rsp_tag[31:0]!=32'(full_mul_got))$fatal(1,"full mul tag");for(int l=0;l<256;l++)if(mul_rsp_data[l]!==32'h3f800000)$fatal(1,"full mul data");full_mul_got++;end
   end else if(mode==3)begin
    if(mul_req_valid&&mul_req_ready)begin key=int'(mul_req_tag);mul_at[key]=cycle;mul_seen[key]=0;mul_level_sent=key;end
    if(mul_rsp_valid)begin
     key=int'(mul_rsp_tag);
     if(!mul_seen[key])begin if(cycle-mul_at[key]!=expected_latency)$fatal(1,"mul dependency latency phase=%0d got=%0d",lease_phase,cycle-mul_at[key]);mul_seen[key]=1;end
     for(int l=0;l<256;l++)if(mul_rsp_data[l]!==32'h3f800000+(32'(key)<<23))$fatal(1,"dependent mul power mismatch");
     if(mul_rsp_ready&&key==10)mul_chain_done=1;
    end
   end
  end
 end
 task automatic bind_phase(input integer phase);
  @(negedge clk);lease_phase=3'(phase);release_phase=3'(phase);lease_valid=1;
  do @(posedge clk);while(!lease_ready);
  @(negedge clk);lease_valid=0;expected_latency=phase==1?9:8;
 endtask
 task automatic release_phase_task;
  @(negedge clk);mode=0;release_valid=1;
  do @(posedge clk);while(!release_ready);
  @(negedge clk);release_valid=0;if(lease_active||mul_pending||add_pending!='0)$fatal(1,"FP lease release with real debt");
 endtask
 task automatic tree_test(input integer levels,input bit hold_first);
  @(negedge clk);target=levels;init_sent=0;init_total=levels==10?2:1;tree_done=0;left_valid=0;tree_hold_delay=0;consume=!hold_first;mode=1;
  if(hold_first)begin wait(add_rsp_valid[0]);repeat(5)@(negedge clk);consume=1;end
  wait(tree_done);@(negedge clk);mode=0;chains++;
  $display("M007_LN_FP_TREE_PASS phase=%0d levels=%0d dependency_cycles=%0d hold=%0d",lease_phase,levels,expected_latency,hold_first);
 endtask
 task automatic mul_test;
  @(negedge clk);mul_level_sent=0;mul_chain_done=0;consume=1;mode=3;
  wait(mul_chain_done);@(negedge clk);mode=0;chains++;
 endtask
 initial begin
  if(!$value$plusargs("FIXTURE=%s",fixture))$fatal(1,"fixture arg required");
  $readmemh({fixture,"/plain_encoder00/raw.hex"},raw);$readmemh({fixture,"/plain_encoder00/tree1.hex"},tree_gold);
  repeat(4)@(negedge clk);rst_n=1;
  for(int p=0;p<3;p++)begin
   bind_phase(p==0?6:p==1?1:3);tree_test(7,0);tree_test(10,0);mul_test;release_phase_task;
  end
  bind_phase(6);tree_test(10,1);
  @(negedge clk);full_add_sent=0;full_mul_sent=0;full_add_got=0;full_mul_got=0;consume=0;mode=2;
  wait(full_add_sent==64&&full_mul_sent==64);@(negedge clk);extra=1;
  repeat(16)begin @(negedge clk);if(mul_pending!=64||add_pending[0]!=64||mul_req_ready||add_req_ready[0])$fatal(1,"real64 vector full credit failure");end
  extra=0;consume=1;wait(full_add_got==64&&full_mul_got==64);@(negedge clk);mode=0;release_phase_task;
  // A common reset while both actual physical arrays have pending operations.
  bind_phase(6);@(negedge clk);full_add_sent=0;full_mul_sent=0;full_add_got=0;full_mul_got=0;consume=0;mode=2;
  wait(full_add_sent>=4&&full_mul_sent>=4);@(negedge clk);mode=0;
  if(mul_pending==0||add_pending[0]==0)$fatal(1,"reset lacks actual FP work");rst_n=0;
  repeat(3)@(negedge clk);rst_n=1;lease_generation=32;lease_epoch=52;release_epoch=52;
  repeat(16)@(negedge clk);if(mul_rsp_valid||add_rsp_valid||mul_pending||add_pending!='0)$fatal(1,"old FP work leaked after reset");
  bind_phase(6);tree_test(10,0);mul_test;release_phase_task;
  $display("HARDWARE_AGENT_SIM_PASS M007_LN_PHASE6 full_lanes=256 chains=%0d checked_tree_nodes=%0d phase6=8 phase1=9 phase3=8 full_credit64=1 hold_cycles=%0d active_reset=1",chains,nodes_checked,held_cycles);$finish;
 end
endmodule
