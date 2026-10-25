`timescale 1ns/1ps
module m007_catalog_tb;
 logic clk=0;always #5 clk=~clk;
 logic rst_n=0,req_valid=0,req_ready;logic[6:0]req_word=0;logic[63:0]catalog_base=64'h10000;
 logic rsp_valid,rsp_ready=0;logic[511:0]rsp_data;logic fault;logic[2:0]rsp_rid;logic[1:0]rsp_rresp;logic rsp_rlast,idle;
 logic arvalid,arready=0;logic[63:0]araddr;logic[2:0]arid;logic[7:0]arlen;logic[2:0]arsize;logic[1:0]arburst;
 logic rvalid=0,rready;logic[511:0]rdata=0;logic[2:0]rid=7;logic[1:0]rresp=0;logic rlast=1;
 laya_m007_catalog_reader_v1 dut(.*);
 logic[511:0]catalog[0:127];
 // Two descriptor slots are TB parent peer state; the DUT stores none.
 logic[511:0]slots[0:1];logic[1:0]slot_valid=0;logic[511:0]saved0,saved1;
 logic pending=0,ar_seen=0;logic[6:0]held_word;logic[63:0]held_base;
 integer cycle=0,requests=0,ars=0,rs=0,responses=0,faults=0,drains=0,commits=0;
 integer ar_held=0,r_held=0,drain_bubbles=0,checked=0,progress_fd,reset_edges=0;
 integer index;string fixture_path,progress_path;
 task automatic progress(input integer event_kind);
  begin
   checked=checked+1;
   $fwrite(progress_fd,"{\"schema\":\"m007-catalog-consumed-v1\",\"checked\":%0d,\"cycle\":%0d,\"event\":%0d,\"responses\":%0d,\"drains\":%0d}\n",checked,cycle,event_kind,responses,drains);
   $fflush(progress_fd);
  end
 endtask
 always @(posedge clk)begin
  cycle=cycle+1;
  if(!rst_n)begin
   if(req_ready||arvalid||rsp_valid||rready||idle)$fatal(1,"RESET_OUTPUT_GATE");
   pending=0;ar_seen=0;slot_valid=0;reset_edges=reset_edges+1;
  end else begin
   if(!idle&&req_ready)$fatal(1,"BUSY_ADMISSION");
   if(req_valid&&req_ready)begin
    if(pending||!idle)$fatal(1,"REQUEST_WITH_DEBT");
    requests=requests+1;pending=1;ar_seen=0;held_word=req_word;held_base=catalog_base;
   end
   if(pending&&(req_word!==held_word||catalog_base!==held_base))$fatal(1,"TB_PARENT_HOLD_OBLIGATION");
   if(arvalid)begin
    if(!pending||ar_seen||idle)$fatal(1,"AR_OWNERSHIP");
    if(araddr!==held_base+64*held_word||arid!==3'd7||arlen!==0||arsize!==6||arburst!==1)$fatal(1,"AR_FIXED_FIELDS");
    if(!arready)ar_held=ar_held+1;
   end
   if(arvalid&&arready)begin ars=ars+1;ar_seen=1;end
   if(rsp_valid)begin
    if(!pending||!ar_seen||idle||!rvalid)$fatal(1,"RESPONSE_DEBT");
    if(rsp_data!==rdata||rsp_rid!==rid||rsp_rresp!==rresp||rsp_rlast!==rlast)$fatal(1,"REAL_R_TRANSPARENCY");
    if(rsp_data!==catalog[held_word])$fatal(1,"INDEPENDENT_CATALOG_WORD %0d",held_word);
    if(fault!==(rid!=7||rresp!=0||!rlast))$fatal(1,"FAULT_DECODE");
    if(!rsp_ready)begin
     if(rready)$fatal(1,"RESPONSE_BACKPRESSURE");
     r_held=r_held+1;
    end
   end
   if(rvalid&&rready)begin
    if(!pending||!ar_seen||idle)$fatal(1,"ACTUAL_R_WITHOUT_DEBT");
    rs=rs+1;
    if(!rsp_valid)begin
     drains=drains+1;
     if(fault)$fatal(1,"DRAIN_PARENT_RESPONSE");
     progress(2);
    end
   end
   if(rsp_valid&&rsp_ready)begin
    if(!(rvalid&&rready))$fatal(1,"PARENT_GHOST_ACCEPT");
    responses=responses+1;
    if(fault)faults=faults+1;
    else if(held_word>=4)begin
     slots[(held_word-4)%2]=rsp_data;slot_valid[(held_word-4)%2]=1;commits=commits+1;
    end
    progress(1);
   end
   if(rvalid&&rready&&rlast)begin pending=0;ar_seen=0;end
   if(pending&&ar_seen&&!rsp_valid&&!rvalid)drain_bubbles=drain_bubbles+1;
  end
  if(cycle>10000)$fatal(1,"CYCLE_CAP");
 end
 task automatic common_reset;
  begin
   @(negedge clk);rst_n=0;req_valid=0;arready=0;rvalid=0;rsp_ready=0;
   repeat(2)begin @(posedge clk);#1;if(idle||arvalid||rsp_valid||rready||req_ready)$fatal(1,"RESET_GHOST");end
   @(negedge clk);rst_n=1;
   @(posedge clk);#1;if(!idle||arvalid||rsp_valid||rready)$fatal(1,"RESET_RECOVERY");
  end
 endtask
 task automatic request_word(input integer word_index);
  begin
   @(negedge clk);req_word=word_index;req_valid=1;
   #1;if(!req_ready||!idle)$fatal(1,"REQUEST_READY word=%0d",word_index);
   @(posedge clk);#1;if(idle||!arvalid)$fatal(1,"REQUEST_NOT_BUSY");
   @(negedge clk);req_valid=0;
  end
 endtask
 task automatic take_ar(input integer held_cycles);
  begin
   for(integer k=0;k<held_cycles;k=k+1)begin
    @(posedge clk);#1;if(!arvalid||idle||rsp_valid)$fatal(1,"HELD_AR_RETRACTED");
   end
   @(negedge clk);arready=1;
   @(posedge clk);#1;if(arvalid||idle)$fatal(1,"AR_NOT_RETIRED");
   @(negedge clk);arready=0;
  end
 endtask
 task automatic response_word(input integer response_id,input integer response_code,input integer last_bit,input integer held_cycles);
  begin
   @(negedge clk);rdata=catalog[req_word];rid=response_id;rresp=response_code;rlast=last_bit;rvalid=1;rsp_ready=(held_cycles==0);
   for(integer k=0;k<held_cycles;k=k+1)begin
    @(posedge clk);#1;
    if(!rsp_valid||idle||rready||rsp_data!==catalog[req_word]||rsp_rid!==response_id[2:0]||rsp_rresp!==response_code[1:0]||rsp_rlast!==last_bit[0])$fatal(1,"HELD_R_STABILITY");
   end
   if(held_cycles>0)begin @(negedge clk);rsp_ready=1;end
   @(posedge clk);#1;
   if(last_bit&&!idle)$fatal(1,"LAST_NOT_IDLE");
   if(!last_bit&&(idle||rsp_valid||!rready))$fatal(1,"MISSING_LAST_NOT_DRAIN");
   @(negedge clk);rvalid=0;rsp_ready=0;
  end
 endtask
 task automatic drain_beat(input integer last_bit,input integer bubbles);
  begin
   for(integer k=0;k<bubbles;k=k+1)begin
    @(posedge clk);#1;if(idle||rsp_valid||!rready)$fatal(1,"DRAIN_FALSE_IDLE_BUBBLE");
   end
   @(negedge clk);rvalid=1;rdata=512'hdeadbeef;rid=3;rresp=2;rlast=last_bit;
   @(posedge clk);#1;
   if(last_bit&&!idle)$fatal(1,"DRAIN_FINAL_NOT_IDLE");
   if(!last_bit&&(idle||rsp_valid||!rready))$fatal(1,"DRAIN_EARLY_IDLE");
   @(negedge clk);rvalid=0;
  end
 endtask
 task automatic rejected_request(input logic[6:0]word_index,input logic[63:0]base_value);
  begin
   @(negedge clk);req_valid=1;req_word=word_index;catalog_base=base_value;
   repeat(3)begin @(posedge clk);#1;if(req_ready||!idle||arvalid||rsp_valid)$fatal(1,"ILLEGAL_REQUEST_ACCEPT");end
   @(negedge clk);req_valid=0;catalog_base=64'h10000;req_word=0;
  end
 endtask
 initial begin
  if(!$value$plusargs("CATALOG=%s",fixture_path)||!$value$plusargs("PROGRESS_FILE=%s",progress_path))$fatal(1,"EXPLICIT_FIXTURE_REQUIRED");
  $readmemh(fixture_path,catalog);progress_fd=$fopen(progress_path,"w");if(!progress_fd)$fatal(1,"PROGRESS_OPEN");
  common_reset();
  rejected_request(124,64'h10000);rejected_request(0,64'h10001);rejected_request(0,64'hffffffffffffe000);
  request_word(1);repeat(3)begin @(posedge clk);#1;if(!arvalid||idle)$fatal(1,"RESET_BEFORE_AR_BUSY");end
  common_reset();
  request_word(0);take_ar(17);response_word(7,0,1,0);
  for(index=0;index<124;index=index+1)begin
   request_word(index);take_ar(0);response_word(7,0,1,index==4?17:0);
  end
  if(commits!=120||slot_valid!=3||slots[0]!==catalog[122]||slots[1]!==catalog[123])$fatal(1,"TWO_SLOT_FULL_SCAN");
  saved0=slots[0];saved1=slots[1];
  request_word(4);take_ar(0);response_word(6,0,1,0);
  request_word(123);take_ar(0);response_word(7,2,1,0);
  request_word(4);take_ar(0);response_word(7,0,0,0);
  drain_beat(0,3);drain_beat(0,2);drain_beat(1,4);
  if(commits!=120||slots[0]!==saved0||slots[1]!==saved1||faults!=3||drains!=3)$fatal(1,"FAULT_SLOT_OR_DRAIN");
  // In-flight reset uses common peer reset; arbitrary late old RID7 is outside this contract.
  request_word(5);take_ar(0);common_reset();
  request_word(6);take_ar(0);
  @(negedge clk);rvalid=1;rdata=catalog[6];rid=7;rresp=0;rlast=1;rsp_ready=0;
  repeat(17)begin @(posedge clk);#1;if(!rsp_valid||idle||rready)$fatal(1,"END_RESET_HELD_R");end
  common_reset();
  request_word(123);take_ar(0);response_word(7,0,1,0);
  repeat(3)begin @(posedge clk);#1;if(!idle||arvalid||rsp_valid||rready)$fatal(1,"END_GHOST");end
  if(requests!=132||ars!=131||rs!=132||responses!=129||faults!=3||drains!=3||commits!=121||ar_held<17||r_held!=34)$fatal(1,"FINAL_COUNTS req=%0d ar=%0d r=%0d rsp=%0d faults=%0d drains=%0d commits=%0d arheld=%0d rheld=%0d",requests,ars,rs,responses,faults,drains,commits,ar_held,r_held);
  $display("CATALOG_READER_PASS requests=%0d ar=%0d r=%0d responses=%0d faults=%0d drains=%0d commits=%0d ar_held=%0d r_held=%0d drain_bubbles=%0d reset_edges=%0d cycles=%0d",requests,ars,rs,responses,faults,drains,commits,ar_held,r_held,drain_bubbles,reset_edges,cycle);
  $display("HARDWARE_AGENT_SIM_PASS CATALOG_READER");$fclose(progress_fd);$finish;
 end
endmodule
