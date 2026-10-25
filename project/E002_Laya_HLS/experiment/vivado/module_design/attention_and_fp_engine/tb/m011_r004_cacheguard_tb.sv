`timescale 1ns/1ps
`define READ_ORIGINAL_BIN(PATH,ARR) begin integer fd,nb;fd=$fopen(PATH,"rb");if(fd==0)$fatal(1,"original binary missing %s",PATH);nb=$fread(ARR,fd);if($fgetc(fd)!=-1)$fatal(1,"original binary trailing bytes %s",PATH);$fclose(fd);if(nb!=$size(ARR)*4)$fatal(1,"original binary size %s bytes%0d",PATH,nb);for(int bi=0;bi<$size(ARR);bi++)ARR[bi]={ARR[bi][7:0],ARR[bi][15:8],ARR[bi][23:16],ARR[bi][31:24]};end
module m011_r004_cacheguard_tb;
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
 int binds=0,writes=0,cancels=0;
 task automatic step;@(posedge clk);#0.1;endtask
 task automatic cancel;
  @(negedge clk);prepare_cancel_valid=1;prepare_cancel_request_id=prepare_request_id;prepare_cancel_generation=prepare_generation;prepare_cancel_epoch=prepare_epoch;#0.1;if(!prepare_cancel_ready)$fatal(1,"matching cancel not accepted");step();@(negedge clk);prepare_cancel_valid=0;
  repeat(7)begin if(!prepare_cancel_rsp_valid||!dut.engine.cache_owner_valid||coeff_bind_ready||coeff_wr_ready||prepare_ready)$fatal(1,"held cancel released coefficient ownership");step();end
  @(negedge clk);coeff_wr_valid=0;prepare_cancel_rsp_ready=1;step();@(negedge clk);prepare_cancel_rsp_ready=0;step();if(!layer_idle||dut.engine.cache_owner_valid||!coeff_bind_ready)$fatal(1,"cancel consumption did not release coeff owner");
 endtask
 initial begin
  rst_n=0;prepare_valid=0;prepare_request_id=64'h123456789abcdef0;prepare_model_id=128'h6eb6ef58bc4f99bd9db40381604108af;prepare_numeric_id=128'haeb13e7937d29fe6a2c68c407249f294;prepare_table_key=128'hb1fdc9ca482c0210982c7245cc50c965;prepare_generation=1;prepare_epoch=11;prepare_kind=0;prepare_layer=0;prepare_mask='1;
  qkv_wr_valid=0;qkv_wr_request_id=0;qkv_wr_generation=0;qkv_wr_epoch=0;qkv_wr_plane=0;qkv_wr_head=0;qkv_wr_token=0;qkv_wr_half=0;qkv_wr_data=0;start_valid=0;start_request_id=0;start_generation=0;abort_valid=0;qkv_read_grant=7;ps_grant=1;g_grant=1;context_grant=1;fp_grant=1;sfu_grant=1;exp_grant=1;div_grant=1;rope_write_grant=1;done_ready=0;result_rd_valid=0;result_rd_generation=0;result_rd_tag=0;result_rd_head=0;result_rd_query=0;result_rd_half=0;result_rsp_ready=0;result_discard_valid=0;result_discard_generation=0;
  coeff_bind_valid=0;coeff_bind_model_id=prepare_model_id;coeff_bind_numeric_id=prepare_numeric_id;coeff_bind_table_key=prepare_table_key;coeff_wr_valid=0;coeff_wr_model_id=prepare_model_id;coeff_wr_numeric_id=prepare_numeric_id;coeff_wr_table_key=prepare_table_key;coeff_wr_table=0;coeff_wr_row=0;coeff_wr_half=0;coeff_wr_data={32{32'h3f800000}};
  repeat(4)step();@(negedge clk);rst_n=1;coeff_bind_valid=1;#0.1;if(!coeff_bind_ready)$fatal(1,"initial coeff bind");step();@(negedge clk);coeff_bind_valid=0;coeff_wr_valid=1;#0.1;if(!coeff_wr_ready||coeff_wr_reject_valid)$fatal(1,"initial legal cache load");step();@(negedge clk);coeff_wr_valid=0;prepare_valid=1;#0.1;if(!prepare_ready)$fatal(1,"real PREP");step();@(negedge clk);prepare_valid=0;
  coeff_bind_model_id=prepare_model_id^128'd1;coeff_bind_valid=1;
  repeat(4)begin #0.1;if(coeff_bind_ready||!dut.engine.cache_owner_valid)$fatal(1,"PREP external rebind admitted");step();end
  @(negedge clk);coeff_bind_valid=0;coeff_wr_valid=1;coeff_wr_data={32{32'h40000000}};
  repeat(4)begin #0.1;if(coeff_wr_ready||!coeff_wr_reject_valid||coeff_wr_reject_code!=2||coeff_bound_model_id!==prepare_model_id||dut.coeff.coverage!==1024'd1)$fatal(1,"PREP legal external load changed held coefficients");step();end
  cancel();@(negedge clk);coeff_wr_valid=0;coeff_bind_valid=1;#0.1;if(!coeff_bind_ready)$fatal(1,"released coeff rebind denied");step();@(negedge clk);coeff_bind_valid=0;coeff_wr_model_id=coeff_bind_model_id;coeff_wr_valid=1;#0.1;if(!coeff_wr_ready||coeff_wr_reject_valid)$fatal(1,"new descriptor load after release");step();@(negedge clk);coeff_wr_valid=0;
  if(coeff_bound_model_id!==coeff_bind_model_id||dut.coeff.coverage!==1024'd1||binds!=2||writes!=2||cancels!=1)$fatal(1,"actual cache ownership counts/state %0d/%0d/%0d",binds,writes,cancels);
  $display("HARDWARE_AGENT_SIM_PASS M011_R004_CACHEGUARD PREP_rebind4_load4_reject held_cancel7_owner1 actual_cancel_consumption_release new_descriptor_bind_load no_reset");$finish;
 end
 always@(posedge clk)if(rst_n)begin if(coeff_bind_valid&&coeff_bind_ready)binds++;if(coeff_wr_valid&&coeff_wr_ready)writes++;if(prepare_cancel_valid&&prepare_cancel_ready)cancels++;end
 initial begin repeat(10000)@(posedge clk);$fatal(1,"cache owner cycle cap");end
endmodule
