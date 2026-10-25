`timescale 1ns/1ps
module m007_quant_A_cancel_r007_tb;
 logic clk=0;always #1 clk=~clk;logic rst_n=0,run_enable=1;
 logic cmd_valid=0,cmd_ready,cmd_slot=0;logic [15:0] cmd_k=1024;
 logic [63:0] cmd_request=1;logic [31:0] cmd_generation=1,cmd_epoch=1;
 logic in_valid=0,in_ready;logic [31:0][31:0] in_data;
 logic [63:0] in_request;logic [31:0] in_generation,in_epoch;logic [7:0] in_row,in_group;
 logic producer_close_valid=0,producer_close_ready,producer_close_success=1;
 logic done_valid,done_ready=0;logic [2:0] status,quant_phase;logic [6:0] quant_row,quant_group;logic [4:0] quant_element;
 logic [31:0] quant_accepted,quant_retired,a_writes,a_write_acks;logic quant_last_event,a_publish_event;
 logic acfg_valid;logic acfg_ready;logic acfg_slot;logic [15:0] acfg_k;
 logic [63:0] acfg_request;logic [31:0] acfg_generation,acfg_epoch;
 logic acfg_rsp_valid;logic acfg_rsp_ready;logic [1:0] acfg_status;
 logic awr_valid;logic awr_ready;logic [6:0] awr_row,awr_group;logic [271:0] awr_data;
 logic [63:0] awr_request;logic [31:0] awr_generation,awr_epoch;
 logic awr_rsp_valid;logic awr_rsp_ready;
 logic fill_cancel_valid;logic fill_cancel_ready;logic fill_cancel_slot;
 logic [63:0] fill_cancel_request;logic [31:0] fill_cancel_generation,fill_cancel_epoch;
 logic fill_cancel_reject_valid;logic [3:0] fill_cancel_reject_code;
 logic fill_cancel_rsp_valid;logic fill_cancel_rsp_ready;logic fill_cancel_rsp_slot;
 logic [63:0] fill_cancel_rsp_request;logic [31:0] fill_cancel_rsp_generation,fill_cancel_rsp_epoch;
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


 laya_m007_quant_a_fill_v1 dut(.*);
 logic [1023:0] inputs[0:4095];logic [271:0] expected[0:4095];
 string fixture,input_fixture;
 integer cycle=0,operation=0,writes=0,acks=0,total_writes=0,total_acks=0,publications=0,close_count=0;

 logic[1:0]actual_slots,actual_leases;logic[6:0]actual_read_debt;
 laya_m007_a_cache_v1 cache(.clk,.rst_n,.cfg_valid(acfg_valid),.cfg_ready(acfg_ready),.cfg_slot(acfg_slot),.cfg_k(acfg_k),.cfg_request(acfg_request),.cfg_generation(acfg_generation),.cfg_epoch(acfg_epoch),.cfg_rsp_valid(acfg_rsp_valid),.cfg_rsp_ready(acfg_rsp_ready),.cfg_status(acfg_status),.cfg_rsp_slot(),.cfg_rsp_k(),.cfg_rsp_request(),.cfg_rsp_generation(),.cfg_rsp_epoch(),.error_row(),.error_group(),
 .fill_cancel_valid,.fill_cancel_ready,.fill_cancel_slot,.fill_cancel_request,.fill_cancel_generation,.fill_cancel_epoch,.fill_cancel_reject_valid,.fill_cancel_reject_code,.fill_cancel_rsp_valid,.fill_cancel_rsp_ready,.fill_cancel_rsp_slot,.fill_cancel_rsp_request,.fill_cancel_rsp_generation,.fill_cancel_rsp_epoch,
 .wr_valid(awr_valid),.wr_ready(awr_ready),.wr_row(awr_row),.wr_group(awr_group),.wr_data(awr_data),.wr_request(awr_request),.wr_generation(awr_generation),.wr_epoch(awr_epoch),.wr_rsp_valid(awr_rsp_valid),.wr_rsp_ready(awr_rsp_ready),.wr_rsp_row(),.wr_rsp_group(),
 .lease_valid(1'b0),.lease_ready(),.lease_slot(1'b0),.lease_request(64'b0),.lease_generation(32'b0),.lease_epoch(32'b0),
 .rd_valid(1'b0),.rd_ready(),.rd_slot(1'b0),.rd_m(3'b0),.rd_group(7'b0),.rd_tag(96'b0),.rd_request(64'b0),.rd_generation(32'b0),.rd_epoch(32'b0),.rd_rsp_valid(),.rd_rsp_ready(1'b1),.rd_rsp_slot(),.rd_rsp_tag(),.rd_rsp_data(),
 .ret_valid(1'b0),.ret_ready(),.ret_slot(1'b0),.ret_tag(96'b0),.ret_request(64'b0),.ret_generation(32'b0),.ret_epoch(32'b0),.release_valid(1'b0),.release_ready(),.release_slot(1'b0),.release_request(64'b0),.release_generation(32'b0),.release_epoch(32'b0),.slot_valid(actual_slots),.slot_leased(actual_leases),.read_debt(actual_read_debt));
 integer cancels=0,cancel_responses=0,held_responses=0;
 always@(posedge clk)if(rst_n)begin
  cycle++;
  if(awr_valid&&awr_ready)begin
   if(awr_data!==expected[awr_row*32+(awr_group%32)]||awr_epoch!=cmd_epoch)$fatal(1,"real quant/A original data or operationepoch");
   writes++;total_writes++;
   if(writes%128==0)begin $display("M007_PARENT_CHECKED checked=%0d phase=QUANT_A_CANCEL cycle=%0d",total_writes*32,cycle);$fflush();end
  end
  if(awr_rsp_valid&&awr_rsp_ready)begin acks++;total_acks++;end
  if(awr_rsp_valid&&!awr_rsp_ready)held_responses++;
  if(fill_cancel_valid&&fill_cancel_ready)begin
   cancels++;if(fill_cancel_epoch!=cmd_epoch||fill_cancel_epoch==32'd100||fill_cancel_generation!=cmd_generation)$fatal(1,"real partial-fill cancel identity/sourceepoch mix");
  end
  if(fill_cancel_rsp_valid&&fill_cancel_rsp_ready)cancel_responses++;
  if(acfg_rsp_valid&&acfg_rsp_ready)begin if(acfg_status!=0)$fatal(1,"unexpected actual A publication failure");publications++;end
  if(cycle>50000)$fatal(1,"actual cancel/recovery watchdog");
 end
 task automatic send_group(input int idx);
  begin @(negedge clk);in_valid=1;in_request=cmd_request;in_generation=cmd_generation;in_epoch=cmd_epoch;in_row=idx/(cmd_k/32);in_group=idx%(cmd_k/32);in_data=inputs[(idx/(cmd_k/32))*32+(idx%32)];do @(posedge clk);while(!in_ready);end
 endtask
 task automatic do_operation(input bit fail_early);
  begin
   writes=0;acks=0;producer_close_success=!fail_early;
   @(negedge clk);cmd_valid=1;do @(posedge clk);while(!cmd_ready);@(negedge clk);cmd_valid=0;
   for(int j=0;j<(fail_early?256:128*(cmd_k/32));j++)send_group(j);
   @(negedge clk);in_valid=0;
   if(fail_early)begin
    if(writes==0||dut.q_reservations==0)$fatal(1,"cancel did not overlap real quant/A work");wait(awr_rsp_valid);run_enable=0;
   end
   producer_close_valid=1;do @(posedge clk);while(!producer_close_ready);@(negedge clk);producer_close_valid=0;
   if(!fail_early&&cmd_k==4096)begin
    wait(awr_valid&&awr_ready&&awr_row==127&&awr_group==127);@(posedge clk);#0.001;run_enable=0;
    repeat(11)begin @(negedge clk);if(!awr_rsp_valid||acfg_rsp_valid||done_valid||!actual_slots[0])$fatal(1,"last127/127 real ACK/publication held barrier");end
    run_enable=1;
   end
   if(fail_early)begin repeat(7)begin @(negedge clk);if(done_valid||cmd_ready)$fatal(1,"cancel fabricated immediate debt retirement");end run_enable=1;end
   wait(done_valid);@(negedge clk);
   if(status!=(fail_early?3:0)||quant_accepted!=(fail_early?256:128*(cmd_k/32))||quant_retired!=quant_accepted||a_writes!=a_write_acks||writes!=acks||dut.q_reservations!=0||dut.a_write_debt!=0||d_lease_active||dut.q_lease_active||actual_read_debt!=0||actual_leases!=0)$fatal(1,"real cancel/recovery final debt");
   if(fail_early)begin if(actual_slots[cmd_slot]||cancels!=1||cancel_responses!=1||publications!=0)$fatal(1,"partial A escaped after real cancel");end
   else if(!actual_slots[cmd_slot]||writes!=128*(cmd_k/32)||acks!=128*(cmd_k/32)||publications!=(cmd_k==4096?2:1))$fatal(1,"new-generation complete actual A publication");
   repeat(5)begin @(negedge clk);if(!done_valid||cmd_ready)$fatal(1,"held terminal");end
   done_ready=1;@(negedge clk);done_ready=0;cmd_request++;cmd_generation++;cmd_epoch++;
  end
 endtask
 initial begin
  if(!$value$plusargs("FIXTURE=%s",fixture)||!$value$plusargs("INPUT_FIXTURE=%s",input_fixture))$fatal(1,"original inputs required");
  $readmemh({input_fixture,"/qkv_0_weight/input.hex"},inputs);$readmemh({fixture,"/qkv_0_weight/a_write.hex"},expected);
  cmd_epoch=101;repeat(5)@(negedge clk);rst_n=1;do_operation(1);do_operation(0);cmd_k=4096;cmd_slot=1;do_operation(0);
  if(held_responses==0)$fatal(1,"real A writeACK was not held");
  $display("HARDWARE_AGENT_SIM_PASS M007_QUANT_A_CANCEL real_quant=1 real_DIV=1 real_A=1 cancel_epoch=101 source_epoch=100 cancels=%0d cancel_responses=%0d held_ACK=%0d newgen_A_writes=4096 newgen_A_ACKs=4096 capacity_K=4096 capacity_A1_writes=16384 capacity_A1_ACKs=16384 last127_127_held=11 cycles=%0d",cancels,cancel_responses,held_responses,cycle);$fflush();$finish;
 end
 laya_shared_div8_v1 divider(.clk,.rst_n,
  .lease_valid(d_lease_valid),.lease_ready(d_lease_ready),.lease_request_id(d_lease_request_id),
  .lease_generation(d_lease_generation),.lease_epoch(d_lease_epoch),.lease_head(d_lease_head),.lease_phase(d_lease_phase),
  .release_valid(d_release_valid),.release_ready(d_release_ready),.release_phase(d_release_phase),.release_epoch(d_release_epoch),.phase_debt_clear(d_phase_debt_clear),
  .lease_active(d_lease_active),.draining(d_draining),.rsp_request_id(d_rsp_request_id),.rsp_generation(d_rsp_generation),.rsp_epoch(d_rsp_epoch),.rsp_head(d_rsp_head),.rsp_phase(d_rsp_phase),
  .req_valid(d_req_valid),.req_ready(d_req_ready),.req_generation(d_req_generation),.req_epoch(d_req_epoch),.req_phase(d_req_phase),.req_lane_mask(d_req_lane_mask),.req_tag(d_req_tag),.req_a(d_req_a),.req_b(d_req_b),
  .protocol_reject_valid(d_protocol_reject_valid),.protocol_reject_code(d_protocol_reject_code),
  .rsp_valid(d_rsp_valid),.rsp_ready(d_rsp_ready),.rsp_tag(d_rsp_tag),.rsp_lane_mask(d_rsp_lane_mask),.rsp_numeric_error(d_rsp_numeric_error),.rsp_data(d_rsp_data),
  .pending_vectors(d_pending_vectors),.in_flight_vectors(d_in_flight_vectors),.in_flight_scalars(d_in_flight_scalars),.protocol_fault(d_protocol_fault));
endmodule
