`timescale 1ns/1ps
`define READ_ORIGINAL_BIN(PATH,ARR) begin integer fd,nb;fd=$fopen(PATH,"rb");if(fd==0)$fatal(1,"original binary missing %s",PATH);nb=$fread(ARR,fd);if($fgetc(fd)!=-1)$fatal(1,"original binary trailing bytes %s",PATH);$fclose(fd);if(nb!=$size(ARR)*4)$fatal(1,"original binary size %s bytes%0d",PATH,nb);for(int bi=0;bi<$size(ARR);bi++)ARR[bi]={ARR[bi][7:0],ARR[bi][15:8],ARR[bi][23:16],ARR[bi][31:24]};end
module m011_r004_cancel_tb;
 logic  clk;
 logic  rst_n;
 logic  prepare_valid;
 logic  prepare_ready;
 logic [63:0] prepare_request_id;
 logic [127:0] prepare_model_id;
 logic [31:0] prepare_generation;
 logic [31:0] prepare_epoch;
 logic [127:0] prepare_numeric_id;
 logic [127:0] prepare_table_key;
 logic [1:0] prepare_kind;
 logic [4:0] prepare_layer;
 logic [127:0] prepare_mask;
 logic  qkv_wr_valid;
 logic  qkv_wr_ready;
 logic [63:0] qkv_wr_request_id;
 logic [31:0] qkv_wr_generation;
 logic [31:0] qkv_wr_epoch;
 logic [1:0] qkv_wr_plane;
 logic [3:0] qkv_wr_head;
 logic [6:0] qkv_wr_token;
 logic  qkv_wr_half;
 logic [31:0][31:0] qkv_wr_data;
 logic  start_valid;
 logic  start_ready;
 logic [63:0] start_request_id;
 logic [31:0] start_generation;
 logic  reject_valid;
 logic [3:0] reject_code;
 logic  abort_valid;
 logic  abort_ready;
 logic [2:0] qkv_read_grant;
 logic  ps_grant;
 logic  g_grant;
 logic  context_grant;
 logic  fp_grant;
 logic  sfu_grant;
 logic  exp_grant;
 logic  div_grant;
 logic  rope_write_grant;
 logic  done_valid;
 logic  done_ready;
 logic [63:0] done_request_id;
 logic [31:0] done_generation;
 logic [7:0] done_status;
 logic [31:0] done_cycles;
 logic [31:0] rope_cycles;
 logic [15:0] head_completed;
 logic [15:0] head_context_valid;
 logic [3:0] active_head;
 logic  error_valid;
 logic [95:0] error_tuple;
 logic [25:0][15:0] check_completed;
 logic [25:0][15:0] check_unreachable;
 logic [25:0][15:0] check_dominated;
 logic [2047:0] av_check_completed;
 logic [2047:0] av_check_unreachable;
 logic [2047:0] av_check_dominated;
 logic  result_rd_valid;
 logic  result_rd_ready;
 logic [31:0] result_rd_generation;
 logic [31:0] result_rd_tag;
 logic [3:0] result_rd_head;
 logic [6:0] result_rd_query;
 logic  result_rd_half;
 logic  result_rsp_valid;
 logic  result_rsp_ready;
 logic [31:0] result_rsp_tag;
 logic [31:0][31:0] result_rsp_data;
 logic  coeff_bind_valid;
 logic  coeff_bind_ready;
 logic [127:0] coeff_bind_model_id;
 logic [127:0] coeff_bind_numeric_id;
 logic [127:0] coeff_bind_table_key;
 logic  coeff_bound_valid;
 logic [127:0] coeff_bound_model_id;
 logic [127:0] coeff_bound_numeric_id;
 logic [127:0] coeff_bound_table_key;
 logic [1:0] coeff_family_complete;
 logic  coeff_wr_valid;
 logic  coeff_wr_ready;
 logic [127:0] coeff_wr_model_id;
 logic [127:0] coeff_wr_numeric_id;
 logic [127:0] coeff_wr_table_key;
 logic [1:0] coeff_wr_table;
 logic [6:0] coeff_wr_row;
 logic  coeff_wr_half;
 logic [31:0][31:0] coeff_wr_data;
 logic  coeff_wr_reject_valid;
 logic [2:0] coeff_wr_reject_code;
 logic [4:0] coeff_wr_nonfinite_lane;
 logic result_discard_valid,result_discard_ready,context_discarded;logic[31:0]result_discard_generation,producer_done_cycles,context_release_cycles;
 logic prepare_cancel_valid=0,prepare_cancel_ready,prepare_cancel_rsp_valid,prepare_cancel_rsp_ready=0,layer_idle,check_coverage_fault;
 logic[63:0]prepare_cancel_request_id=0,prepare_cancel_rsp_request_id;logic[31:0]prepare_cancel_generation=0,prepare_cancel_epoch=0,prepare_cancel_rsp_generation,prepare_cancel_rsp_epoch,check_first_conflict;logic[7:0]prepare_cancel_rsp_status;

 initial clk=0;always #1.6665 clk=~clk;
 laya_attention_layer_v1 dut(.*);
 int writes=0,cancels=0;
 task automatic step;@(posedge clk);#0.1;endtask
 task automatic prep(input int gen);
  @(negedge clk);prepare_generation=gen;prepare_epoch=32'(90+gen);prepare_valid=1;while(!prepare_ready)step();step();@(negedge clk);prepare_valid=0;
  if(layer_idle||prepare_ready)$fatal(1,"PREP not owned");
 endtask
 task automatic word_write(input int n);
  @(negedge clk);qkv_wr_valid=1;qkv_wr_request_id=prepare_request_id;qkv_wr_generation=prepare_generation;qkv_wr_epoch=prepare_epoch;qkv_wr_plane=2'(n/256%3);qkv_wr_head=4'(n/768);qkv_wr_token=7'(n/2%128);qkv_wr_half=1'(n%2);qkv_wr_data={32{32'h3f800000}};while(!qkv_wr_ready)step();step();@(negedge clk);qkv_wr_valid=0;
 endtask
 task automatic cancel;
  @(negedge clk);prepare_cancel_valid=1;prepare_cancel_request_id=prepare_request_id;prepare_cancel_generation=prepare_generation;prepare_cancel_epoch=prepare_epoch;
  #0.1;if(!prepare_cancel_ready)$fatal(1,"matching cancel not ready");step();@(negedge clk);prepare_cancel_valid=0;
  repeat(7)begin
   if(!prepare_cancel_rsp_valid||prepare_cancel_rsp_request_id!==prepare_request_id||prepare_cancel_rsp_generation!==prepare_generation||prepare_cancel_rsp_epoch!==prepare_epoch||prepare_cancel_rsp_status!=4||prepare_ready||start_ready||qkv_wr_ready||layer_idle||done_valid)$fatal(1,"held cancel response/protocol");step();
  end
  @(negedge clk);prepare_cancel_rsp_ready=1;step();@(negedge clk);prepare_cancel_rsp_ready=0;step();if(!layer_idle||prepare_cancel_rsp_valid)$fatal(1,"cancel did not retire to actual idle");
 endtask
 initial begin
  rst_n=0;prepare_valid=0;prepare_request_id=64'h1234567812345678;prepare_model_id=128'h6eb6ef58bc4f99bd9db40381604108af;prepare_numeric_id=128'haeb13e7937d29fe6a2c68c407249f294;prepare_table_key=128'hb1fdc9ca482c0210982c7245cc50c965;prepare_generation=1;prepare_epoch=91;prepare_kind=2;prepare_layer=0;prepare_mask='1;
  qkv_wr_valid=0;qkv_wr_request_id=0;qkv_wr_generation=0;qkv_wr_epoch=0;qkv_wr_plane=0;qkv_wr_head=0;qkv_wr_token=0;qkv_wr_half=0;qkv_wr_data=0;start_valid=0;start_request_id=prepare_request_id;start_generation=1;abort_valid=0;qkv_read_grant=7;ps_grant=1;g_grant=1;context_grant=1;fp_grant=1;sfu_grant=1;exp_grant=1;div_grant=1;rope_write_grant=1;done_ready=0;result_rd_valid=0;result_rd_generation=0;result_rd_tag=0;result_rd_head=0;result_rd_query=0;result_rd_half=0;result_rsp_ready=0;result_discard_valid=0;result_discard_generation=0;
  coeff_bind_valid=0;coeff_bind_model_id=0;coeff_bind_numeric_id=0;coeff_bind_table_key=0;coeff_wr_valid=0;coeff_wr_model_id=0;coeff_wr_numeric_id=0;coeff_wr_table_key=0;coeff_wr_table=0;coeff_wr_row=0;coeff_wr_half=0;coeff_wr_data=0;
  repeat(4)step();@(negedge clk);rst_n=1;step();prep(1);cancel();
  prep(2);for(int i=0;i<19;i++)word_write(i);
  for(int field=0;field<3;field++)begin
   @(negedge clk);prepare_cancel_valid=1;prepare_cancel_request_id=prepare_request_id+(field==0);prepare_cancel_generation=prepare_generation+(field==1);prepare_cancel_epoch=prepare_epoch+(field==2);step();if(prepare_cancel_ready||prepare_cancel_rsp_valid||layer_idle||$countones(dut.engine.qkv_coverage)!=19)$fatal(1,"wrong cancel damaged real coverage");
  end
  @(negedge clk);prepare_cancel_valid=0;cancel();
  // Prior real writes committed; same-edge new narrow write and start lose to matching cancellation.
  prep(3);word_write(0);@(negedge clk);prepare_cancel_valid=1;prepare_cancel_request_id=prepare_request_id;prepare_cancel_generation=prepare_generation;prepare_cancel_epoch=prepare_epoch;start_generation=prepare_generation;start_valid=1;qkv_wr_valid=1;qkv_wr_generation=prepare_generation;qkv_wr_epoch=prepare_epoch;
  #0.1;if(!prepare_cancel_ready||qkv_wr_ready||start_ready||dut.engine.res_qkv_wr_valid)$fatal(1,"cancel priority");step();@(negedge clk);start_valid=0;qkv_wr_valid=0;prepare_cancel_valid=0;if(!prepare_cancel_rsp_valid||dut.engine.qkv_coverage!=0)$fatal(1,"cancel coverage not invalidated");prepare_cancel_rsp_ready=1;step();@(negedge clk);prepare_cancel_rsp_ready=0;step();
  prep(4);if(dut.engine.qkv_coverage!=0||dut.engine.qkv_complete||start_ready)$fatal(1,"newgen reused prior input");cancel();
  if(writes!=20||cancels!=4)$fatal(1,"actual counts writes%0d cancels%0d",writes,cancels);
  $display("HARDWARE_AGENT_SIM_PASS M011_R004_CANCEL zero_partial20wrong3 sameedge_write_start_cancel held7 noreset4gens actual_idle no_internal_injection");$finish;
 end
 always@(posedge clk)if(rst_n)begin
  if(qkv_wr_valid&&qkv_wr_ready)writes++;
  if(prepare_cancel_valid&&prepare_cancel_ready)cancels++;
  if(dut.resources.res_fp_lease_active||dut.resources.res_div_lease_active||dut.resources.res_sfu_lease_active)$fatal(1,"PREP cancel leased arithmetic");
 end
 initial begin repeat(10000)@(posedge clk);$fatal(1,"cycle cap");end
endmodule
