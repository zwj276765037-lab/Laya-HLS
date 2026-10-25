`timescale 1ns/1ps
module m007_quant_engine_tb;
 logic clk=0,rst_n=0;always#5 clk=~clk;
 logic lease_valid=0,lease_ready;logic[63:0]lease_request_id=64'h1234567800001001;
 logic[31:0]lease_generation=1,lease_source_epoch=17;logic[12:0]lease_k=1024;
 logic release_valid=0,release_ready;logic[63:0]release_request_id;
 logic[31:0]release_generation,release_source_epoch;logic lease_active,draining;
 logic in_valid=0,in_ready;logic[63:0]in_request_id;logic[31:0]in_generation,in_source_epoch;
 logic[7:0]in_row=0,in_group=0;logic[95:0]in_tag=0;logic[1023:0]in_data=0;
 logic protocol_reject_valid;logic[3:0]protocol_reject_code;
 logic out_valid,out_ready=0;logic[63:0]out_request_id;logic[31:0]out_generation,out_source_epoch;
 logic[12:0]out_k;logic[7:0]out_row,out_group;logic[95:0]out_tag;logic[271:0]out_data;
 logic[7:0]out_status,out_stage;logic[4:0]out_source_element;logic[31:0]out_amax,out_d_full,out_inverse;
 logic out_d_valid,out_inverse_valid;logic[8:0]reservations;logic protocol_fault;
 logic[31:0]accepted_groups,retired_groups,scale_divisions,inverse_divisions;
 logic trace_mul_valid;logic[95:0]trace_mul_tag;logic[1023:0]trace_mul_products;
 logic d_lease_valid,d_lease_ready;logic[63:0]d_lease_request_id;
 logic[31:0]d_lease_generation,d_lease_epoch;logic[3:0]d_lease_head;logic[2:0]d_lease_phase;
 logic d_release_valid,d_release_ready;logic[2:0]d_release_phase;logic[31:0]d_release_epoch;
 logic d_phase_debt_clear,d_lease_active,d_draining;logic[63:0]d_rsp_request_id;
 logic[31:0]d_rsp_generation,d_rsp_epoch;logic[3:0]d_rsp_head;logic[2:0]d_rsp_phase;
 logic d_req_valid,d_req_ready;logic[31:0]d_req_generation,d_req_epoch;logic[2:0]d_req_phase;
 logic[7:0]d_req_lane_mask;logic[95:0]d_req_tag;logic[7:0][31:0]d_req_a,d_req_b;
 logic d_protocol_reject_valid;logic[3:0]d_protocol_reject_code;
 logic d_rsp_valid,d_rsp_ready;logic[95:0]d_rsp_tag;
 logic[7:0]d_rsp_lane_mask,d_rsp_numeric_error;logic[7:0][31:0]d_rsp_data;
 logic[5:0]d_pending_vectors,d_in_flight_vectors;logic[8:0]d_in_flight_scalars;logic d_protocol_fault;
 laya_m007_quant_group32_v1 dut(.*);
 // Exactly one production shared8divide service. No TB arithmetic responder.
 laya_shared_div8_v1 divider(.clk,.rst_n,
  .lease_valid(d_lease_valid),.lease_ready(d_lease_ready),.lease_request_id(d_lease_request_id),
  .lease_generation(d_lease_generation),.lease_epoch(d_lease_epoch),.lease_head(d_lease_head),.lease_phase(d_lease_phase),
  .release_valid(d_release_valid),.release_ready(d_release_ready),.release_phase(d_release_phase),.release_epoch(d_release_epoch),.phase_debt_clear(d_phase_debt_clear),
  .lease_active(d_lease_active),.draining(d_draining),.rsp_request_id(d_rsp_request_id),.rsp_generation(d_rsp_generation),.rsp_epoch(d_rsp_epoch),.rsp_head(d_rsp_head),.rsp_phase(d_rsp_phase),
  .req_valid(d_req_valid),.req_ready(d_req_ready),.req_generation(d_req_generation),.req_epoch(d_req_epoch),.req_phase(d_req_phase),.req_lane_mask(d_req_lane_mask),.req_tag(d_req_tag),.req_a(d_req_a),.req_b(d_req_b),
  .protocol_reject_valid(d_protocol_reject_valid),.protocol_reject_code(d_protocol_reject_code),
  .rsp_valid(d_rsp_valid),.rsp_ready(d_rsp_ready),.rsp_tag(d_rsp_tag),.rsp_lane_mask(d_rsp_lane_mask),.rsp_numeric_error(d_rsp_numeric_error),.rsp_data(d_rsp_data),
  .pending_vectors(d_pending_vectors),.in_flight_vectors(d_in_flight_vectors),.in_flight_scalars(d_in_flight_scalars),.protocol_fault(d_protocol_fault));
 logic[1023:0]inputs[0:16383],products[0:16383];logic[271:0]packed_gold[0:16383];logic[95:0]scalar_gold[0:16383];
 logic[1023:0]edge_inputs[0:15],edge_products[0:15];logic[391:0]edge_gold[0:15];
 bit product_seen[0:16383];
 string fixture,diagnostics,mode,current_name;integer cycle=0,accepted=0,received=0,product_count=0;
 integer count=0,current_k=1024,segment=0,first_accept=0,first_output=0,last_output=0,last_accept=0,previous_output=0,max_reservations=0;
 integer rejected=0,releases=0;bit checking=0,edge_mode=0,strict_ii=0;
 integer lease_assert_cycle=0,lease_accept_cycle=0,lease_wait_cycles=0,reset_edges_total=0;
 bit was_held=0,was_div_held=0;logic[643:0]held_output;logic[682:0]held_div;
 wire[643:0]output_record={out_request_id,out_generation,out_source_epoch,out_k,out_row,out_group,out_tag,out_data,out_status,out_stage,out_source_element,out_amax,out_d_full,out_inverse,out_d_valid,out_inverse_valid};
 wire[682:0]divide_record={d_req_generation,d_req_epoch,d_req_phase,d_req_lane_mask,d_req_tag,d_req_a,d_req_b};
 always@(posedge clk)begin:monitor
  integer index;logic[391:0]gold;
  cycle=cycle+1;if(cycle>500000)$fatal(1,"bounded engine cycle limit");
  if(!rst_n)begin was_held=0;was_div_held=0;reset_edges_total=reset_edges_total+1;end
  else begin
   if(lease_valid&&lease_ready)begin lease_accept_cycle=cycle;lease_wait_cycles=cycle-lease_assert_cycle;end
   if(protocol_fault)$fatal(1,"actual protocol_fault cycle=%0d reservations=%0d accepted=%0d retired=%0d",cycle,reservations,accepted_groups,retired_groups);
   if(d_protocol_reject_valid)$fatal(1,"unexpected service reject code=%0d",d_protocol_reject_code);
   if(reservations>128)$fatal(1,"reservation overflow");
   if(was_held&&(!out_valid||output_record!==held_output))$fatal(1,"held output changed");
   if(was_div_held&&(!d_req_valid||divide_record!==held_div))$fatal(1,"held divide changed");
   was_held=out_valid&&!out_ready;held_output=output_record;
   was_div_held=d_req_valid&&!d_req_ready;held_div=divide_record;
   if(protocol_reject_valid)rejected=rejected+1;
   if(release_valid&&release_ready)releases=releases+1;
   if(checking)begin
    if(reservations>max_reservations)max_reservations=reservations;
    if(in_valid&&in_ready)begin
     if(accepted==0)first_accept=cycle;
     else if(strict_ii&&cycle-last_accept!=1)$fatal(1,"input II violation index=%0d delta=%0d",accepted,cycle-last_accept);
     last_accept=cycle;accepted=accepted+1;
    end
    if(trace_mul_valid)begin
     index=int'(trace_mul_tag[31:0]);
     if(index>=count||trace_mul_tag[63:32]!=32'(segment)||product_seen[index])$fatal(1,"multiply tag/duplicate index=%0d tag=%h",index,trace_mul_tag);
     if(edge_mode)begin
      if(edge_gold[index][391:384]!=0)$fatal(1,"arithmetic continued beyond earlier edge error index=%0d stage=%0d",index,edge_gold[index][383:376]);
      if(trace_mul_products!==edge_products[index])$fatal(1,"edge original products mismatch index=%0d",index);
     end else if(trace_mul_products!==products[index])$fatal(1,"normal original products mismatch index=%0d actual=%h expected=%h",index,trace_mul_products,products[index]);
     product_seen[index]=1;product_count=product_count+1;
    end
    if(out_valid&&out_ready)begin
     if(received>=count)$fatal(1,"extra/stale output tag=%h",out_tag);
     if(received==0)first_output=cycle;
     else if(strict_ii&&cycle-previous_output!=1)$fatal(1,"output II violation index=%0d delta=%0d",received,cycle-previous_output);
     previous_output=cycle;last_output=cycle;
     if(out_request_id!==lease_request_id||out_generation!==lease_generation||out_source_epoch!==lease_source_epoch||out_k!==13'(current_k)||
        out_row!==8'(received/(current_k/32))||out_group!==8'(received%(current_k/32))||out_tag!=={32'hb16b00b5,32'(segment),32'(received)})$fatal(1,"output identity/order mismatch index=%0d tag=%h",received,out_tag);
     if(edge_mode)begin
      gold=edge_gold[received];
      if(out_status!==gold[391:384]||out_stage!==gold[383:376]||out_source_element!==gold[372:368]||out_amax!==gold[367:336])$fatal(1,"edge status/amax mismatch index=%0d status=%0d stage=%0d element=%0d amax=%h gold=%h",received,out_status,out_stage,out_source_element,out_amax,gold);
      if(out_d_valid!==(gold[383:376]!=1)||out_d_full!==gold[335:304])$fatal(1,"edge actual d mismatch index=%0d",received);
      if(gold[383:376]==3)begin if(out_inverse_valid)$fatal(1,"inverse issued after half failure");end
      else if(gold[383:376]==1)begin if(out_inverse_valid)$fatal(1,"inverse issued after input failure");end
      else if(!out_inverse_valid||out_inverse!==gold[303:272])$fatal(1,"edge actual inverse mismatch index=%0d actual=%h expected=%h",received,out_inverse,gold[303:272]);
      if(out_status==0)begin if(out_data!==gold[271:0]||!product_seen[received])$fatal(1,"edge packed/product mismatch index=%0d",received);end
      else if(out_data!==0||product_seen[received])$fatal(1,"error record incorrectly contains success data/products");
     end else begin
      if(out_status!==0||out_stage!==0||out_source_element!==0||out_data!==packed_gold[received])$fatal(1,"normal packed mismatch index=%0d status=%0d actual=%h expected=%h",received,out_status,out_data,packed_gold[received]);
      if(!out_d_valid||!out_inverse_valid||{out_amax,out_d_full,out_inverse}!==scalar_gold[received]||!product_seen[received])$fatal(1,"normal intermediate mismatch index=%0d",received);
     end
     received=received+1;
    end
   end else if(out_valid)$fatal(1,"output outside active expected sequence tag=%h",out_tag);
  end
 end
 task automatic reset_common;
  @(negedge clk);rst_n=0;in_valid=0;lease_valid=0;release_valid=0;out_ready=0;checking=0;
  repeat(3)@(negedge clk);rst_n=1;repeat(2)@(negedge clk);
 endtask
 task automatic bind_lease(input integer K);
  @(negedge clk);lease_k=13'(K);lease_valid=1;lease_assert_cycle=cycle;
  do @(posedge clk);while(!lease_ready);
  @(negedge clk);lease_valid=0;in_request_id=lease_request_id;in_generation=lease_generation;in_source_epoch=lease_source_epoch;
  release_request_id=lease_request_id;release_generation=lease_generation;release_source_epoch=lease_source_epoch;
 endtask
 task automatic release_lease;
  @(negedge clk);release_valid=1;
  do @(posedge clk);while(!release_ready);
  @(negedge clk);release_valid=0;
  if(lease_active||d_lease_active||reservations!=0||d_pending_vectors!=0||d_in_flight_vectors!=0||d_in_flight_scalars!=0)$fatal(1,"release completed with real debt");
 endtask
 task automatic prepare(input string name,input integer K,input integer groups,input bit edges_mode,input bit no_stalls);
  current_name=name;current_k=K;count=groups;edge_mode=edges_mode;strict_ii=no_stalls;segment=segment+1;
  accepted=0;received=0;product_count=0;max_reservations=0;first_accept=0;first_output=0;last_output=0;last_accept=0;previous_output=0;
  for(int i=0;i<count;i++)product_seen[i]=0;
  checking=1;
 endtask
 task automatic drive(input integer index);
  in_valid=1;in_row=8'(index/(current_k/32));in_group=8'(index%(current_k/32));
  in_tag={32'hb16b00b5,32'(segment),32'(index)};in_data=edge_mode?edge_inputs[index]:inputs[index];
 endtask
 task automatic finish_check(input bit performance);
  wait(received==count);@(negedge clk);in_valid=0;
  if(accepted!=count||accepted_groups!=32'(count)||retired_groups!=32'(count)||reservations!=0)$fatal(1,"final real count/debt mismatch");
  if(performance&&(first_output-first_accept+1>128||last_output-first_accept+1>4*current_k+128))$fatal(1,"cycle budget fail first=%0d span=%0d",first_output-first_accept+1,last_output-first_accept+1);
  if(edge_mode)begin if(scale_divisions!=13||inverse_divisions!=6||product_count!=7)$fatal(1,"edge actual operation counts scale=%0d inverse=%0d product=%0d",scale_divisions,inverse_divisions,product_count);end
  else if(scale_divisions!=32'(count)||inverse_divisions!=32'(count)||product_count!=count)$fatal(1,"normal actual operation counts");
  $display("M007_QUANT_STREAM_PASS name=%s groups=%0d first_cycles=%0d span_cycles=%0d max_reservations=%0d products=%0d",current_name,count,first_output-first_accept+1,last_output-first_accept+1,max_reservations,product_count);
  $display("M007_QUANT_LEASE_METRIC name=%s wait_cycles=%0d lease_to_first_input=%0d observed_reset_edges_total=%0d",current_name,lease_wait_cycles,first_accept-lease_accept_cycle,reset_edges_total);
  checking=0;
 endtask
 task automatic load_normal(input string name);
  $readmemh({fixture,"/",name,"/input.hex"},inputs);$readmemh({fixture,"/",name,"/packed.hex"},packed_gold);
  $readmemh({diagnostics,"/",name,"/scalars.hex"},scalar_gold);$readmemh({diagnostics,"/",name,"/products.hex"},products);
 endtask
 task automatic normal_stream(input string name,input integer K,input integer groups,input bit stalls);
  load_normal(name);bind_lease(K);prepare(name,K,groups,0,!stalls);out_ready=1;
  while(accepted<count)begin
   @(negedge clk);out_ready=!stalls||(cycle%17>=5);
   if(accepted<count&&(!stalls||cycle%11>=3))drive(accepted);else in_valid=0;
  end
  @(negedge clk);in_valid=0;out_ready=1;finish_check(!stalls);release_lease;
 endtask
 task automatic edge_stream;
  bind_lease(1024);prepare("edge16",1024,16,1,0);out_ready=1;
  while(accepted<count)begin @(negedge clk);if(accepted<count)drive(accepted);else in_valid=0;end
  @(negedge clk);in_valid=0;finish_check(0);release_lease;
 endtask
 task automatic reject_input(input integer kind,input integer expected_code);
  @(negedge clk);in_request_id=lease_request_id;in_generation=lease_generation;in_source_epoch=lease_source_epoch;in_row=0;in_group=0;in_valid=1;
  case(kind)0:in_request_id=lease_request_id+1;1:in_generation=lease_generation+1;2:in_source_epoch=lease_source_epoch+1;3:in_row=128;4:in_group=32;endcase
  #1;if(in_ready||!protocol_reject_valid||protocol_reject_code!=expected_code)$fatal(1,"identity/coordinate rejection failed kind=%0d code=%0d",kind,protocol_reject_code);
  @(posedge clk);@(negedge clk);in_valid=0;
  if(reservations!=0||accepted_groups!=0)$fatal(1,"rejected input consumed reservation");
  in_request_id=lease_request_id;in_generation=lease_generation;in_source_epoch=lease_source_epoch;in_row=0;in_group=0;
 endtask
 task automatic protocol_tests;
  integer before_release;
  load_normal("enc0_norm128_K1024");
  @(negedge clk);lease_valid=1;lease_k=2048;#1;if(lease_ready||!protocol_reject_valid||protocol_reject_code!=6)$fatal(1,"invalid K lease accepted");
  @(posedge clk);@(negedge clk);lease_valid=0;
  bind_lease(1024);for(int i=0;i<5;i++)reject_input(i,i<3?i+2:5);
  @(negedge clk);release_valid=1;release_generation=lease_generation+1;#1;
  if(release_ready||!protocol_reject_valid||protocol_reject_code!=7)$fatal(1,"wrong release accepted");
  @(posedge clk);@(negedge clk);release_valid=0;release_generation=lease_generation;
  prepare("credit128_hold129",1024,129,0,0);out_ready=0;
  while(accepted<128)begin @(negedge clk);if(accepted<128)drive(accepted);else in_valid=0;end
  @(negedge clk);drive(128);
  repeat(150)begin @(negedge clk);if(in_ready||reservations!=128||accepted_groups!=128)$fatal(1,"129th group bypassed128 real credits");end
  if(!out_valid)$fatal(1,"no held output after saturation");out_ready=1;
  wait(accepted==129);@(negedge clk);in_valid=0;finish_check(0);
  if(max_reservations!=128)$fatal(1,"128 real reservations not observed");release_lease;
  normal_stream("enc0_norm128_K1024",1024,256,1);
  bind_lease(1024);prepare("release_debt16",1024,16,0,0);out_ready=0;
  while(accepted<16)begin @(negedge clk);if(accepted<16)drive(accepted);else in_valid=0;end
  @(negedge clk);in_valid=0;release_valid=1;before_release=releases;
  repeat(150)begin @(negedge clk);if(release_ready||!lease_active||in_ready||reservations!=16)$fatal(1,"release crossed unconsumed output debt");end
  out_ready=1;
  wait(releases==before_release+1);@(negedge clk);release_valid=0;
  finish_check(0);if(lease_active||d_lease_active)$fatal(1,"release drain did not return shared lease");
  // Discard actual divider work using only common reset, then bind a new gen.
  bind_lease(1024);prepare("aborted_reset",1024,32,0,0);out_ready=0;
  while(accepted<24)begin @(negedge clk);if(accepted<24)drive(accepted);else in_valid=0;end
  @(negedge clk);in_valid=0;repeat(4)@(negedge clk);
  if(d_in_flight_vectors==0||reservations!=24)$fatal(1,"reset lacked actual divide in flight");
  reset_common;lease_generation=2;lease_source_epoch=18;
  bind_lease(1024);repeat(100)@(negedge clk);
  if(out_valid||reservations!=0||d_pending_vectors!=0||d_in_flight_vectors!=0||d_in_flight_scalars!=0)$fatal(1,"old work leaked after common reset/newgen");
  @(negedge clk);in_valid=1;in_generation=1;#1;
  if(in_ready||!protocol_reject_valid||protocol_reject_code!=3)$fatal(1,"old generation accepted after reset");
  @(posedge clk);@(negedge clk);in_valid=0;in_generation=lease_generation;
  prepare("new_generation128",1024,128,0,1);out_ready=1;
  while(accepted<count)begin @(negedge clk);if(accepted<count)drive(accepted);else in_valid=0;end
  @(negedge clk);in_valid=0;finish_check(1);release_lease;
  $display("M007_QUANT_PROTOCOL_PASS rejects=%0d releases=%0d saturation=128 held=1 release_debt=1 active_reset=1 new_generation=2",rejected,releases);
 endtask
 initial begin
  if(!$value$plusargs("FIXTURE=%s",fixture)||!$value$plusargs("DIAGNOSTICS=%s",diagnostics)||!$value$plusargs("MODE=%s",mode))$fatal(1,"fixture args required");
  $readmemh({fixture,"/edge_input.hex"},edge_inputs);$readmemh({fixture,"/edge_gold.hex"},edge_gold);$readmemh({diagnostics,"/edge_products.hex"},edge_products);
  reset_common;
  if(mode=="pilot")begin normal_stream("enc0_norm128_K1024",1024,128,0);edge_stream;end
  else if(mode=="full")begin
   normal_stream("enc0_norm128_K1024",1024,4096,0);
   normal_stream("diagnostic128_K2624",2624,10496,0);
   normal_stream("diagnostic128_K4096",4096,16384,0);edge_stream;
  end else if(mode=="protocol")protocol_tests;
  else $fatal(1,"unknown mode");
  repeat(8)@(negedge clk);$display("HARDWARE_AGENT_SIM_PASS M007_QUANT_ENGINE mode=%s real_div8=1 real_mul32=1",mode);$finish;
 end
endmodule
