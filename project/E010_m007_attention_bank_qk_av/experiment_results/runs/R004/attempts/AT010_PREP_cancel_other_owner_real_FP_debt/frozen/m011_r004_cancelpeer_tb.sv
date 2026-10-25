`timescale 1ns/1ps
`define READ_ORIGINAL_BIN(PATH,ARR) begin integer fd,nb;fd=$fopen(PATH,"rb");if(fd==0)$fatal(1,"original binary missing %s",PATH);nb=$fread(ARR,fd);if($fgetc(fd)!=-1)$fatal(1,"original binary trailing bytes %s",PATH);$fclose(fd);if(nb!=$size(ARR)*4)$fatal(1,"original binary size %s bytes%0d",PATH,nb);for(int bi=0;bi<$size(ARR);bi++)ARR[bi]={ARR[bi][7:0],ARR[bi][15:8],ARR[bi][23:16],ARR[bi][31:24]};end
module m011_r004_cancelpeer_tb;
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


 logic peer_owner=0,peer_lease_valid=0,peer_mul_valid=0,peer_rsp_ready=0,peer_release_valid=0,peer_lease_ready,peer_mul_ready,peer_rsp_valid,peer_active,peer_fault;logic[6:0]peer_pending;
 initial clk=0;always #1.6665 clk=~clk;
 m011_r004_cancelpeer_shell dut(.*);
 int nwrite=0,nmul=0,nret=0,ncancel=0;
 task automatic step;@(posedge clk);#0.1;endtask
 task automatic prep(input int gen);
  @(negedge clk);prepare_valid=1;prepare_request_id=64'h1111222233334444;prepare_generation=gen;prepare_epoch=gen+10;#0.1;if(!prepare_ready)$fatal(1,"legal PREP not ready");step();@(negedge clk);prepare_valid=0;
 endtask
 task automatic cancel_accept;
  @(negedge clk);prepare_cancel_valid=1;prepare_cancel_request_id=prepare_request_id;prepare_cancel_generation=prepare_generation;prepare_cancel_epoch=prepare_epoch;#0.1;if(!prepare_cancel_ready)$fatal(1,"other owner blocked matching PREP cancel");step();@(negedge clk);prepare_cancel_valid=0;
 endtask
 initial begin
  rst_n=0;prepare_valid=0;prepare_request_id=0;prepare_model_id=128'h6eb6ef58bc4f99bd9db40381604108af;prepare_generation=0;prepare_epoch=0;prepare_numeric_id=128'haeb13e7937d29fe6a2c68c407249f294;prepare_table_key=128'hb1fdc9ca482c0210982c7245cc50c965;prepare_kind=2;prepare_layer=0;prepare_mask='1;
  qkv_wr_valid=0;qkv_wr_request_id=0;qkv_wr_generation=0;qkv_wr_epoch=0;qkv_wr_plane=0;qkv_wr_head=0;qkv_wr_token=0;qkv_wr_half=0;qkv_wr_data={32{32'h3f800000}};start_valid=0;start_request_id=0;start_generation=0;abort_valid=0;qkv_read_grant=7;ps_grant=1;g_grant=1;context_grant=1;fp_grant=1;sfu_grant=1;exp_grant=1;div_grant=1;rope_write_grant=1;done_ready=0;result_rd_valid=0;result_rd_generation=0;result_rd_tag=0;result_rd_head=0;result_rd_query=0;result_rd_half=0;result_rsp_ready=0;result_discard_valid=0;result_discard_generation=0;coeff_bind_valid=0;coeff_bind_model_id=0;coeff_bind_numeric_id=0;coeff_bind_table_key=0;coeff_wr_valid=0;coeff_wr_model_id=0;coeff_wr_numeric_id=0;coeff_wr_table_key=0;coeff_wr_table=0;coeff_wr_row=0;coeff_wr_half=0;coeff_wr_data=0;
  repeat(4)step();@(negedge clk);rst_n=1;step();prep(1);
  @(negedge clk);qkv_wr_request_id=prepare_request_id;qkv_wr_generation=prepare_generation;qkv_wr_epoch=prepare_epoch;qkv_wr_valid=1;
  for(int i=0;i<10;i++)begin qkv_wr_token=7'(i/2);qkv_wr_half=1'(i%2);#0.1;if(!qkv_wr_ready)$fatal(1,"real partial write blocked");step();@(negedge clk);end qkv_wr_valid=0;
  peer_owner=1;peer_lease_valid=1;#0.1;if(!peer_lease_ready)$fatal(1,"actual other lease not ready");step();@(negedge clk);peer_lease_valid=0;peer_mul_valid=1;#0.1;if(!peer_mul_ready)$fatal(1,"other actual mul not ready");step();@(negedge clk);peer_mul_valid=0;while(!peer_rsp_valid)step();
  if(!peer_active||peer_pending!=1||dut.engine.real_idle)$fatal(1,"no real other-owner credit debt");cancel_accept();
  repeat(7)begin
   if(!prepare_cancel_rsp_valid||prepare_cancel_rsp_request_id!==prepare_request_id||prepare_cancel_rsp_generation!==prepare_generation||prepare_cancel_rsp_epoch!==prepare_epoch||!peer_active||peer_pending!=1||!peer_rsp_valid||peer_fault||prepare_ready||layer_idle||dut.engine.res_fp_release_valid)$fatal(1,"cancel disturbed other owner held debt");
   for(int i=0;i<256;i++)if(dut.res_fp_mul_rsp_data[i]!==32'h40000000)$fatal(1,"held real mul data mismatch");step();
  end
  @(negedge clk);prepare_cancel_rsp_ready=1;step();@(negedge clk);prepare_cancel_rsp_ready=0;if(layer_idle||prepare_ready||!peer_active||peer_pending!=1)$fatal(1,"false global idle while peer active");peer_rsp_ready=1;step();@(negedge clk);peer_rsp_ready=0;peer_release_valid=1;while(peer_active)step();@(negedge clk);peer_release_valid=0;peer_owner=0;step();if(!layer_idle||peer_fault)$fatal(1,"actual peer release did not restore idle");
  prep(2);if(dut.engine.qkv_coverage!=0)$fatal(1,"newgen inherited partial coverage");cancel_accept();@(negedge clk);prepare_cancel_rsp_ready=1;step();@(negedge clk);prepare_cancel_rsp_ready=0;step();
  if(nwrite!=10||nmul!=1||nret!=1||ncancel!=2||!layer_idle)$fatal(1,"actual counts %0d/%0d/%0d/%0d",nwrite,nmul,nret,ncancel);
  $display("HARDWARE_AGENT_SIM_PASS M011_R004_CANCELPEER actual_FP_lease_mul256_held_credit1 PREP_cancel_while_other_owner real_return_release noreset_newgen no_fake_debt");$finish;
 end
 always@(posedge clk)if(rst_n)begin if(qkv_wr_valid&&qkv_wr_ready)nwrite++;if(peer_mul_valid&&peer_mul_ready)nmul++;if(peer_rsp_valid&&peer_rsp_ready)nret++;if(prepare_cancel_valid&&prepare_cancel_ready)ncancel++;end
 initial begin repeat(10000)@(posedge clk);$fatal(1,"peer cancel cycle cap");end
endmodule

`timescale 1ns/1ps
// Compatibility shell: one pure layer and one physical instance of every service.
module m011_r004_cancelpeer_shell(
 input logic clk,rst_n,
 input logic prepare_valid,output logic prepare_ready,input logic[63:0]prepare_request_id,input logic[127:0]prepare_model_id,input logic[31:0]prepare_generation,prepare_epoch,input logic[127:0]prepare_numeric_id,input logic[127:0]prepare_table_key,input logic[1:0]prepare_kind,input logic[4:0]prepare_layer,input logic[127:0]prepare_mask,
 input logic qkv_wr_valid,output logic qkv_wr_ready,input logic[63:0]qkv_wr_request_id,input logic[31:0]qkv_wr_generation,qkv_wr_epoch,input logic[1:0]qkv_wr_plane,input logic[3:0]qkv_wr_head,input logic[6:0]qkv_wr_token,input logic qkv_wr_half,input logic[31:0][31:0]qkv_wr_data,
 input logic start_valid,output logic start_ready,input logic[63:0]start_request_id,input logic[31:0]start_generation,
 output logic reject_valid,output logic[3:0]reject_code,
 input logic abort_valid,output logic abort_ready,input logic[2:0]qkv_read_grant,input logic ps_grant,g_grant,context_grant,fp_grant,sfu_grant,exp_grant,div_grant,rope_write_grant,
 output logic done_valid,input logic done_ready,output logic[63:0]done_request_id,output logic[31:0]done_generation,output logic[7:0]done_status,output logic[31:0]done_cycles,rope_cycles,output logic[15:0]head_completed,head_context_valid,output logic[3:0]active_head,
 output logic error_valid,output logic[95:0]error_tuple,output logic[25:0][15:0]check_completed,check_unreachable,check_dominated,output logic[2047:0]av_check_completed,av_check_unreachable,av_check_dominated,
 input logic result_rd_valid,output logic result_rd_ready,input logic[31:0]result_rd_generation,result_rd_tag,input logic[3:0]result_rd_head,input logic[6:0]result_rd_query,input logic result_rd_half,output logic result_rsp_valid,input logic result_rsp_ready,output logic[31:0]result_rsp_tag,output logic[31:0][31:0]result_rsp_data,
 input logic result_discard_valid,output logic result_discard_ready,input logic[31:0]result_discard_generation,output logic context_discarded,output logic[31:0]producer_done_cycles,context_release_cycles,
 input logic coeff_bind_valid,
 output logic coeff_bind_ready,
 input logic[127:0] coeff_bind_model_id,
 input logic[127:0] coeff_bind_numeric_id,
 input logic[127:0] coeff_bind_table_key,
 output logic coeff_bound_valid,
 output logic[127:0] coeff_bound_model_id,
 output logic[127:0] coeff_bound_numeric_id,
 output logic[127:0] coeff_bound_table_key,
 output logic[1:0] coeff_family_complete,
 input logic coeff_wr_valid,
 output logic coeff_wr_ready,
 input logic[127:0] coeff_wr_model_id,
 input logic[127:0] coeff_wr_numeric_id,
 input logic[127:0] coeff_wr_table_key,
 input logic[1:0] coeff_wr_table,
 input logic[6:0] coeff_wr_row,
 input logic coeff_wr_half,
 input logic[31:0][31:0] coeff_wr_data,
 output logic coeff_wr_reject_valid,
 output logic[2:0] coeff_wr_reject_code,
 output logic[4:0] coeff_wr_nonfinite_lane,
 input logic prepare_cancel_valid,output logic prepare_cancel_ready,input logic[63:0]prepare_cancel_request_id,input logic[31:0]prepare_cancel_generation,prepare_cancel_epoch,
 output logic prepare_cancel_rsp_valid,input logic prepare_cancel_rsp_ready,output logic[63:0]prepare_cancel_rsp_request_id,output logic[31:0]prepare_cancel_rsp_generation,prepare_cancel_rsp_epoch,output logic[7:0]prepare_cancel_rsp_status,
 output logic layer_idle,check_coverage_fault,output logic[31:0]check_first_conflict ,input logic peer_owner,peer_lease_valid,peer_mul_valid,peer_rsp_ready,peer_release_valid,
 output logic peer_lease_ready,peer_mul_ready,peer_rsp_valid,peer_active,peer_fault,output logic[6:0]peer_pending
);
 logic res_qkv_wr_valid;
 logic res_qkv_wr_ready;
 logic[1:0] res_qkv_wr_plane;
 logic[3:0] res_qkv_wr_head;
 logic[6:0] res_qkv_wr_token;
 logic res_qkv_wr_half;
 logic[31:0][31:0] res_qkv_wr_data;
 logic[2:0] res_qkv_rd_valid;
 logic[2:0] res_qkv_rd_ready;
 logic[2:0][3:0] res_qkv_rd_head;
 logic[2:0][6:0] res_qkv_rd_token;
 logic[2:0][31:0] res_qkv_rd_tag;
 logic[2:0] res_qkv_rd_rsp_valid;
 logic[2:0] res_qkv_rd_rsp_ready;
 logic[2:0][3:0] res_qkv_rd_rsp_head;
 logic[2:0][6:0] res_qkv_rd_rsp_token;
 logic[2:0][31:0] res_qkv_rd_rsp_tag;
 logic[2:0][63:0][31:0] res_qkv_rd_rsp_data;
 logic res_st_bind_valid;
 logic res_st_bind_ready;
 logic[63:0] res_st_bind_request_id;
 logic[31:0] res_st_bind_generation;
 logic[31:0] res_st_bind_epoch;
 logic[3:0] res_st_bind_head;
 logic[2:0] res_st_bind_phase;
 logic[63:0] res_st_op_request_id;
 logic[31:0] res_st_op_generation;
 logic[31:0] res_st_op_epoch;
 logic[2:0] res_st_op_phase;
 logic[63:0] res_st_rsp_request_id;
 logic[31:0] res_st_rsp_generation;
 logic[31:0] res_st_rsp_epoch;
 logic[3:0] res_st_rsp_head;
 logic[2:0] res_st_rsp_phase;
 logic res_st_ps_wr_valid;
 logic res_st_ps_wr_ready;
 logic[1023:0] res_st_ps_wr_mask;
 logic[1023:0][3:0] res_st_ps_wr_addr;
 logic[1023:0][31:0] res_st_ps_wr_data;
 logic[95:0] res_st_ps_wr_tag;
 logic res_st_ps_wr_rsp_valid;
 logic res_st_ps_wr_rsp_ready;
 logic[95:0] res_st_ps_wr_rsp_tag;
 logic res_st_ps_rd_valid;
 logic res_st_ps_rd_ready;
 logic[1023:0] res_st_ps_rd_mask;
 logic[1023:0][3:0] res_st_ps_rd_addr;
 logic[95:0] res_st_ps_rd_tag;
 logic res_st_ps_rd_rsp_valid;
 logic res_st_ps_rd_rsp_ready;
 logic[1023:0][31:0] res_st_ps_rd_rsp_data;
 logic[1023:0] res_st_ps_rd_rsp_mask;
 logic[95:0] res_st_ps_rd_rsp_tag;
 logic res_st_g_wr_valid;
 logic res_st_g_wr_ready;
 logic[255:0] res_st_g_wr_mask;
 logic[255:0][5:0] res_st_g_wr_addr;
 logic[255:0][31:0] res_st_g_wr_data;
 logic[95:0] res_st_g_wr_tag;
 logic res_st_g_wr_rsp_valid;
 logic res_st_g_wr_rsp_ready;
 logic[95:0] res_st_g_wr_rsp_tag;
 logic res_st_g_rd_valid;
 logic res_st_g_rd_ready;
 logic[255:0] res_st_g_rd_mask;
 logic[255:0][5:0] res_st_g_rd_addr;
 logic[95:0] res_st_g_rd_tag;
 logic res_st_g_rd_rsp_valid;
 logic res_st_g_rd_rsp_ready;
 logic[255:0][31:0] res_st_g_rd_rsp_data;
 logic[255:0] res_st_g_rd_rsp_mask;
 logic[95:0] res_st_g_rd_rsp_tag;
 logic res_st_context_wr_valid;
 logic res_st_context_wr_ready;
 logic[63:0] res_st_context_wr_mask;
 logic[63:0][10:0] res_st_context_wr_addr;
 logic[63:0][31:0] res_st_context_wr_data;
 logic[95:0] res_st_context_wr_tag;
 logic res_st_context_wr_rsp_valid;
 logic res_st_context_wr_rsp_ready;
 logic[95:0] res_st_context_wr_rsp_tag;
 logic res_st_context_rd_valid;
 logic res_st_context_rd_ready;
 logic[63:0] res_st_context_rd_mask;
 logic[63:0][10:0] res_st_context_rd_addr;
 logic[95:0] res_st_context_rd_tag;
 logic res_st_context_rd_rsp_valid;
 logic res_st_context_rd_rsp_ready;
 logic[63:0][31:0] res_st_context_rd_rsp_data;
 logic[63:0] res_st_context_rd_rsp_mask;
 logic[95:0] res_st_context_rd_rsp_tag;
 logic res_st_idle;
 logic res_fp_lease_valid;
 logic res_fp_lease_ready;
 logic[63:0] res_fp_lease_request_id;
 logic[31:0] res_fp_lease_generation;
 logic[31:0] res_fp_lease_epoch;
 logic[3:0] res_fp_lease_head;
 logic[2:0] res_fp_lease_phase;
 logic res_fp_release_valid;
 logic res_fp_release_ready;
 logic[2:0] res_fp_release_phase;
 logic[31:0] res_fp_release_epoch;
 logic res_fp_phase_debt_clear;
 logic res_fp_lease_active;
 logic res_fp_draining;
 logic[63:0] res_fp_rsp_request_id;
 logic[31:0] res_fp_rsp_generation;
 logic[31:0] res_fp_rsp_epoch;
 logic[3:0] res_fp_rsp_head;
 logic[2:0] res_fp_rsp_phase;
 logic res_fp_mul_req_valid;
 logic res_fp_mul_req_ready;
 logic[2:0] res_fp_mul_req_phase;
 logic[31:0] res_fp_mul_req_epoch;
 logic[95:0] res_fp_mul_req_tag;
 logic[255:0][31:0] res_fp_mul_a;
 logic[255:0][31:0] res_fp_mul_b;
 logic res_fp_mul_rsp_valid;
 logic res_fp_mul_rsp_ready;
 logic[95:0] res_fp_mul_rsp_tag;
 logic[255:0][31:0] res_fp_mul_rsp_data;
 logic[6:0] res_fp_add_req_valid;
 logic[6:0] res_fp_add_req_is_root;
 logic[6:0] res_fp_add_req_ready;
 logic[6:0][2:0] res_fp_add_req_phase;
 logic[6:0][31:0] res_fp_add_req_epoch;
 logic[6:0][95:0] res_fp_add_req_tag;
 logic[255:0][31:0] res_fp_add_a;
 logic[255:0][31:0] res_fp_add_b;
 logic[6:0] res_fp_add_rsp_valid;
 logic[6:0] res_fp_add_rsp_ready;
 logic[6:0][95:0] res_fp_add_rsp_tag;
 logic[255:0][31:0] res_fp_add_rsp_data;
 logic[6:0] res_fp_mul_pending;
 logic[6:0][6:0] res_fp_add_pending;
 logic res_fp_protocol_fault;
 logic res_ln_bind_valid;
 logic res_ln_bind_ready;
 logic[63:0] res_ln_bind_request_id;
 logic[31:0] res_ln_bind_generation;
 logic[31:0] res_ln_bind_epoch;
 logic[3:0] res_ln_bind_head;
 logic[2:0] res_ln_bind_phase;
 logic[63:0] res_ln_op_request_id;
 logic[31:0] res_ln_op_generation;
 logic[31:0] res_ln_op_epoch;
 logic[2:0] res_ln_op_phase;
 logic[63:0] res_ln_rsp_request_id;
 logic[31:0] res_ln_rsp_generation;
 logic[31:0] res_ln_rsp_epoch;
 logic[3:0] res_ln_rsp_head;
 logic[2:0] res_ln_rsp_phase;
 logic res_ln_wr_valid;
 logic res_ln_wr_ready;
 logic[255:0] res_ln_wr_mask;
 logic[255:0][4:0] res_ln_wr_addr;
 logic[255:0][31:0] res_ln_wr_data;
 logic[95:0] res_ln_wr_tag;
 logic res_ln_wr_rsp_valid;
 logic res_ln_wr_rsp_ready;
 logic[95:0] res_ln_wr_rsp_tag;
 logic res_ln_rd_valid;
 logic res_ln_rd_ready;
 logic[255:0] res_ln_rd_mask;
 logic[255:0][4:0] res_ln_rd_addr;
 logic[95:0] res_ln_rd_tag;
 logic res_ln_rd_rsp_valid;
 logic res_ln_rd_rsp_ready;
 logic[255:0][31:0] res_ln_rd_rsp_data;
 logic[255:0] res_ln_rd_rsp_mask;
 logic[95:0] res_ln_rd_rsp_tag;
 logic res_ln_idle;
 logic res_sfu_lease_valid;
 logic res_sfu_lease_ready;
 logic[63:0] res_sfu_lease_request_id;
 logic[31:0] res_sfu_lease_generation;
 logic[31:0] res_sfu_lease_epoch;
 logic[3:0] res_sfu_lease_head;
 logic[2:0] res_sfu_lease_phase;
 logic res_sfu_release_valid;
 logic[2:0] res_sfu_release_phase;
 logic[31:0] res_sfu_release_epoch;
 logic res_sfu_phase_debt_clear;
 logic res_sfu_lease_active;
 logic[63:0] res_sfu_context_valid;
 logic[63:0] res_sfu_context_row_hi;
 logic res_sfu_req_valid;
 logic res_sfu_req_ready;
 logic[1:0] res_sfu_req_mode;
 logic[31:0] res_sfu_req_generation;
 logic[31:0] res_sfu_req_epoch;
 logic[2:0] res_sfu_req_phase;
 logic[10:0] res_sfu_req_tag;
 logic[7:0][31:0] res_sfu_req_x;
 logic res_sfu_reject_valid;
 logic res_sfu_rsp_valid;
 logic res_sfu_rsp_ready;
 logic[10:0] res_sfu_rsp_tag;
 logic[7:0][31:0] res_sfu_rsp_data;
 logic[8:0] res_sfu_pending_vectors;
 logic[8:0] res_sfu_in_flight_vectors;
 logic res_sfu_protocol_fault;
 logic res_div_lease_valid;
 logic res_div_lease_ready;
 logic[63:0] res_div_lease_request_id;
 logic[31:0] res_div_lease_generation;
 logic[31:0] res_div_lease_epoch;
 logic[3:0] res_div_lease_head;
 logic[2:0] res_div_lease_phase;
 logic res_div_release_valid;
 logic[2:0] res_div_release_phase;
 logic[31:0] res_div_release_epoch;
 logic res_div_phase_debt_clear;
 logic res_div_lease_active;
 logic res_div_req_valid;
 logic res_div_req_ready;
 logic[31:0] res_div_req_generation;
 logic[31:0] res_div_req_epoch;
 logic[2:0] res_div_req_phase;
 logic[7:0] res_div_req_lane_mask;
 logic[95:0] res_div_req_tag;
 logic[7:0][31:0] res_div_req_a;
 logic[7:0][31:0] res_div_req_b;
 logic res_div_protocol_reject_valid;
 logic res_div_rsp_valid;
 logic res_div_rsp_ready;
 logic[95:0] res_div_rsp_tag;
 logic[7:0] res_div_rsp_numeric_error;
 logic[7:0][31:0] res_div_rsp_data;
 logic[5:0] res_div_pending_vectors;
 logic[5:0] res_div_in_flight_vectors;
 logic[8:0] res_div_in_flight_scalars;
 logic res_div_protocol_fault;
 logic res_scale_valid;
 logic res_scale_ready;
 logic[95:0] res_scale_tag;
 logic[3:0][31:0] res_scale_input;
 logic res_scale_rsp_valid;
 logic res_scale_rsp_ready;
 logic[95:0] res_scale_rsp_tag;
 logic[3:0][31:0] res_scale_data;
 logic[6:0] res_scale_pending;
 logic res_scale_fault;
 logic rope_owner_valid;
 logic[63:0] rope_owner_request_id;
 logic[31:0] rope_owner_generation;
 logic[31:0] rope_owner_epoch;
 logic rope_wr_valid;
 logic rope_wr_ready;
 logic[63:0] rope_wr_request_id;
 logic[31:0] rope_wr_generation;
 logic[31:0] rope_wr_epoch;
 logic[3:0] rope_wr_head;
 logic[6:0] rope_wr_token;
 logic[95:0] rope_wr_tag;
 logic[63:0][31:0] rope_wr_q;
 logic[63:0][31:0] rope_wr_k;
 logic rope_wr_commit_valid;
 logic[95:0] rope_wr_commit_tag;
 logic rope_reject_valid;
 logic[2:0] rope_reject_code;
 logic cache_owner_valid;
 logic[63:0] cache_owner_request_id;
 logic[31:0] cache_owner_generation;
 logic[31:0] cache_owner_epoch;
 logic cache_rd_valid;
 logic cache_rd_ready;
 logic cache_rd_family;
 logic[6:0] cache_rd_row;
 logic[95:0] cache_rd_tag;
 logic[63:0] cache_rd_request_id;
 logic[31:0] cache_rd_generation;
 logic[31:0] cache_rd_epoch;
 logic cache_rd_reject_valid;
 logic[2:0] cache_rd_reject_code;
 logic cache_rsp_valid;
 logic cache_rsp_ready;
 logic cache_rsp_family;
 logic[6:0] cache_rsp_row;
 logic[95:0] cache_rsp_tag;
 logic[127:0][31:0] cache_rsp_data;
 laya_attention_layer_engine_v1 engine(
  .clk(clk),
  .rst_n(rst_n),
  .prepare_valid(prepare_valid),
  .prepare_ready(prepare_ready),
  .prepare_request_id(prepare_request_id),
  .prepare_model_id(prepare_model_id),
  .prepare_generation(prepare_generation),
  .prepare_epoch(prepare_epoch),
  .prepare_numeric_id(prepare_numeric_id),
  .prepare_table_key(prepare_table_key),
  .prepare_kind(prepare_kind),
  .prepare_layer(prepare_layer),
  .prepare_mask(prepare_mask),
  .qkv_wr_valid(qkv_wr_valid),
  .qkv_wr_ready(qkv_wr_ready),
  .qkv_wr_request_id(qkv_wr_request_id),
  .qkv_wr_generation(qkv_wr_generation),
  .qkv_wr_epoch(qkv_wr_epoch),
  .qkv_wr_plane(qkv_wr_plane),
  .qkv_wr_head(qkv_wr_head),
  .qkv_wr_token(qkv_wr_token),
  .qkv_wr_half(qkv_wr_half),
  .qkv_wr_data(qkv_wr_data),
  .start_valid(start_valid),
  .start_ready(start_ready),
  .start_request_id(start_request_id),
  .start_generation(start_generation),
  .reject_valid(reject_valid),
  .reject_code(reject_code),
  .abort_valid(abort_valid),
  .abort_ready(abort_ready),
  .qkv_read_grant(qkv_read_grant),
  .ps_grant(ps_grant),
  .g_grant(g_grant),
  .context_grant(context_grant),
  .fp_grant(fp_grant),
  .sfu_grant(sfu_grant),
  .exp_grant(exp_grant),
  .div_grant(div_grant),
  .rope_write_grant(rope_write_grant),
  .done_valid(done_valid),
  .done_ready(done_ready),
  .done_request_id(done_request_id),
  .done_generation(done_generation),
  .done_status(done_status),
  .done_cycles(done_cycles),
  .rope_cycles(rope_cycles),
  .head_completed(head_completed),
  .head_context_valid(head_context_valid),
  .active_head(active_head),
  .error_valid(error_valid),
  .error_tuple(error_tuple),
  .check_completed(check_completed),
  .check_unreachable(check_unreachable),
  .check_dominated(check_dominated),
  .av_check_completed(av_check_completed),
  .av_check_unreachable(av_check_unreachable),
  .av_check_dominated(av_check_dominated),
  .result_rd_valid(result_rd_valid),
  .result_rd_ready(result_rd_ready),
  .result_rd_generation(result_rd_generation),
  .result_rd_tag(result_rd_tag),
  .result_rd_head(result_rd_head),
  .result_rd_query(result_rd_query),
  .result_rd_half(result_rd_half),
  .result_rsp_valid(result_rsp_valid),
  .result_rsp_ready(result_rsp_ready),
  .result_rsp_tag(result_rsp_tag),
  .result_rsp_data(result_rsp_data),
  .result_discard_valid(result_discard_valid),
  .result_discard_ready(result_discard_ready),
  .result_discard_generation(result_discard_generation),
  .context_discarded(context_discarded),
  .producer_done_cycles(producer_done_cycles),
  .context_release_cycles(context_release_cycles),
  .prepare_cancel_valid(prepare_cancel_valid),
  .prepare_cancel_ready(prepare_cancel_ready),
  .prepare_cancel_request_id(prepare_cancel_request_id),
  .prepare_cancel_generation(prepare_cancel_generation),
  .prepare_cancel_epoch(prepare_cancel_epoch),
  .prepare_cancel_rsp_valid(prepare_cancel_rsp_valid),
  .prepare_cancel_rsp_ready(prepare_cancel_rsp_ready),
  .prepare_cancel_rsp_request_id(prepare_cancel_rsp_request_id),
  .prepare_cancel_rsp_generation(prepare_cancel_rsp_generation),
  .prepare_cancel_rsp_epoch(prepare_cancel_rsp_epoch),
  .prepare_cancel_rsp_status(prepare_cancel_rsp_status),
  .layer_idle(layer_idle),
  .check_coverage_fault(check_coverage_fault),
  .check_first_conflict(check_first_conflict),
  .res_qkv_wr_valid(res_qkv_wr_valid),
  .res_qkv_wr_ready(res_qkv_wr_ready),
  .res_qkv_wr_plane(res_qkv_wr_plane),
  .res_qkv_wr_head(res_qkv_wr_head),
  .res_qkv_wr_token(res_qkv_wr_token),
  .res_qkv_wr_half(res_qkv_wr_half),
  .res_qkv_wr_data(res_qkv_wr_data),
  .res_qkv_rd_valid(res_qkv_rd_valid),
  .res_qkv_rd_ready(res_qkv_rd_ready),
  .res_qkv_rd_head(res_qkv_rd_head),
  .res_qkv_rd_token(res_qkv_rd_token),
  .res_qkv_rd_tag(res_qkv_rd_tag),
  .res_qkv_rd_rsp_valid(res_qkv_rd_rsp_valid),
  .res_qkv_rd_rsp_ready(res_qkv_rd_rsp_ready),
  .res_qkv_rd_rsp_head(res_qkv_rd_rsp_head),
  .res_qkv_rd_rsp_token(res_qkv_rd_rsp_token),
  .res_qkv_rd_rsp_tag(res_qkv_rd_rsp_tag),
  .res_qkv_rd_rsp_data(res_qkv_rd_rsp_data),
  .res_st_bind_valid(res_st_bind_valid),
  .res_st_bind_ready(res_st_bind_ready),
  .res_st_bind_request_id(res_st_bind_request_id),
  .res_st_bind_generation(res_st_bind_generation),
  .res_st_bind_epoch(res_st_bind_epoch),
  .res_st_bind_head(res_st_bind_head),
  .res_st_bind_phase(res_st_bind_phase),
  .res_st_op_request_id(res_st_op_request_id),
  .res_st_op_generation(res_st_op_generation),
  .res_st_op_epoch(res_st_op_epoch),
  .res_st_op_phase(res_st_op_phase),
  .res_st_rsp_request_id(res_st_rsp_request_id),
  .res_st_rsp_generation(res_st_rsp_generation),
  .res_st_rsp_epoch(res_st_rsp_epoch),
  .res_st_rsp_head(res_st_rsp_head),
  .res_st_rsp_phase(res_st_rsp_phase),
  .res_st_ps_wr_valid(res_st_ps_wr_valid),
  .res_st_ps_wr_ready(res_st_ps_wr_ready),
  .res_st_ps_wr_mask(res_st_ps_wr_mask),
  .res_st_ps_wr_addr(res_st_ps_wr_addr),
  .res_st_ps_wr_data(res_st_ps_wr_data),
  .res_st_ps_wr_tag(res_st_ps_wr_tag),
  .res_st_ps_wr_rsp_valid(res_st_ps_wr_rsp_valid),
  .res_st_ps_wr_rsp_ready(res_st_ps_wr_rsp_ready),
  .res_st_ps_wr_rsp_tag(res_st_ps_wr_rsp_tag),
  .res_st_ps_rd_valid(res_st_ps_rd_valid),
  .res_st_ps_rd_ready(res_st_ps_rd_ready),
  .res_st_ps_rd_mask(res_st_ps_rd_mask),
  .res_st_ps_rd_addr(res_st_ps_rd_addr),
  .res_st_ps_rd_tag(res_st_ps_rd_tag),
  .res_st_ps_rd_rsp_valid(res_st_ps_rd_rsp_valid),
  .res_st_ps_rd_rsp_ready(res_st_ps_rd_rsp_ready),
  .res_st_ps_rd_rsp_data(res_st_ps_rd_rsp_data),
  .res_st_ps_rd_rsp_mask(res_st_ps_rd_rsp_mask),
  .res_st_ps_rd_rsp_tag(res_st_ps_rd_rsp_tag),
  .res_st_g_wr_valid(res_st_g_wr_valid),
  .res_st_g_wr_ready(res_st_g_wr_ready),
  .res_st_g_wr_mask(res_st_g_wr_mask),
  .res_st_g_wr_addr(res_st_g_wr_addr),
  .res_st_g_wr_data(res_st_g_wr_data),
  .res_st_g_wr_tag(res_st_g_wr_tag),
  .res_st_g_wr_rsp_valid(res_st_g_wr_rsp_valid),
  .res_st_g_wr_rsp_ready(res_st_g_wr_rsp_ready),
  .res_st_g_wr_rsp_tag(res_st_g_wr_rsp_tag),
  .res_st_g_rd_valid(res_st_g_rd_valid),
  .res_st_g_rd_ready(res_st_g_rd_ready),
  .res_st_g_rd_mask(res_st_g_rd_mask),
  .res_st_g_rd_addr(res_st_g_rd_addr),
  .res_st_g_rd_tag(res_st_g_rd_tag),
  .res_st_g_rd_rsp_valid(res_st_g_rd_rsp_valid),
  .res_st_g_rd_rsp_ready(res_st_g_rd_rsp_ready),
  .res_st_g_rd_rsp_data(res_st_g_rd_rsp_data),
  .res_st_g_rd_rsp_mask(res_st_g_rd_rsp_mask),
  .res_st_g_rd_rsp_tag(res_st_g_rd_rsp_tag),
  .res_st_context_wr_valid(res_st_context_wr_valid),
  .res_st_context_wr_ready(res_st_context_wr_ready),
  .res_st_context_wr_mask(res_st_context_wr_mask),
  .res_st_context_wr_addr(res_st_context_wr_addr),
  .res_st_context_wr_data(res_st_context_wr_data),
  .res_st_context_wr_tag(res_st_context_wr_tag),
  .res_st_context_wr_rsp_valid(res_st_context_wr_rsp_valid),
  .res_st_context_wr_rsp_ready(res_st_context_wr_rsp_ready),
  .res_st_context_wr_rsp_tag(res_st_context_wr_rsp_tag),
  .res_st_context_rd_valid(res_st_context_rd_valid),
  .res_st_context_rd_ready(res_st_context_rd_ready),
  .res_st_context_rd_mask(res_st_context_rd_mask),
  .res_st_context_rd_addr(res_st_context_rd_addr),
  .res_st_context_rd_tag(res_st_context_rd_tag),
  .res_st_context_rd_rsp_valid(res_st_context_rd_rsp_valid),
  .res_st_context_rd_rsp_ready(res_st_context_rd_rsp_ready),
  .res_st_context_rd_rsp_data(res_st_context_rd_rsp_data),
  .res_st_context_rd_rsp_mask(res_st_context_rd_rsp_mask),
  .res_st_context_rd_rsp_tag(res_st_context_rd_rsp_tag),
  .res_st_idle(res_st_idle),
  .res_fp_lease_valid(res_fp_lease_valid),
  .res_fp_lease_ready(res_fp_lease_ready),
  .res_fp_lease_request_id(res_fp_lease_request_id),
  .res_fp_lease_generation(res_fp_lease_generation),
  .res_fp_lease_epoch(res_fp_lease_epoch),
  .res_fp_lease_head(res_fp_lease_head),
  .res_fp_lease_phase(res_fp_lease_phase),
  .res_fp_release_valid(res_fp_release_valid),
  .res_fp_release_ready(res_fp_release_ready),
  .res_fp_release_phase(res_fp_release_phase),
  .res_fp_release_epoch(res_fp_release_epoch),
  .res_fp_phase_debt_clear(res_fp_phase_debt_clear),
  .res_fp_lease_active(res_fp_lease_active),
  .res_fp_draining(res_fp_draining),
  .res_fp_rsp_request_id(res_fp_rsp_request_id),
  .res_fp_rsp_generation(res_fp_rsp_generation),
  .res_fp_rsp_epoch(res_fp_rsp_epoch),
  .res_fp_rsp_head(res_fp_rsp_head),
  .res_fp_rsp_phase(res_fp_rsp_phase),
  .res_fp_mul_req_valid(res_fp_mul_req_valid),
  .res_fp_mul_req_ready(res_fp_mul_req_ready),
  .res_fp_mul_req_phase(res_fp_mul_req_phase),
  .res_fp_mul_req_epoch(res_fp_mul_req_epoch),
  .res_fp_mul_req_tag(res_fp_mul_req_tag),
  .res_fp_mul_a(res_fp_mul_a),
  .res_fp_mul_b(res_fp_mul_b),
  .res_fp_mul_rsp_valid(res_fp_mul_rsp_valid),
  .res_fp_mul_rsp_ready(res_fp_mul_rsp_ready),
  .res_fp_mul_rsp_tag(res_fp_mul_rsp_tag),
  .res_fp_mul_rsp_data(res_fp_mul_rsp_data),
  .res_fp_add_req_valid(res_fp_add_req_valid),
  .res_fp_add_req_is_root(res_fp_add_req_is_root),
  .res_fp_add_req_ready(res_fp_add_req_ready),
  .res_fp_add_req_phase(res_fp_add_req_phase),
  .res_fp_add_req_epoch(res_fp_add_req_epoch),
  .res_fp_add_req_tag(res_fp_add_req_tag),
  .res_fp_add_a(res_fp_add_a),
  .res_fp_add_b(res_fp_add_b),
  .res_fp_add_rsp_valid(res_fp_add_rsp_valid),
  .res_fp_add_rsp_ready(res_fp_add_rsp_ready),
  .res_fp_add_rsp_tag(res_fp_add_rsp_tag),
  .res_fp_add_rsp_data(res_fp_add_rsp_data),
  .res_fp_mul_pending(res_fp_mul_pending),
  .res_fp_add_pending(res_fp_add_pending),
  .res_fp_protocol_fault(res_fp_protocol_fault),
  .res_ln_bind_valid(res_ln_bind_valid),
  .res_ln_bind_ready(res_ln_bind_ready),
  .res_ln_bind_request_id(res_ln_bind_request_id),
  .res_ln_bind_generation(res_ln_bind_generation),
  .res_ln_bind_epoch(res_ln_bind_epoch),
  .res_ln_bind_head(res_ln_bind_head),
  .res_ln_bind_phase(res_ln_bind_phase),
  .res_ln_op_request_id(res_ln_op_request_id),
  .res_ln_op_generation(res_ln_op_generation),
  .res_ln_op_epoch(res_ln_op_epoch),
  .res_ln_op_phase(res_ln_op_phase),
  .res_ln_rsp_request_id(res_ln_rsp_request_id),
  .res_ln_rsp_generation(res_ln_rsp_generation),
  .res_ln_rsp_epoch(res_ln_rsp_epoch),
  .res_ln_rsp_head(res_ln_rsp_head),
  .res_ln_rsp_phase(res_ln_rsp_phase),
  .res_ln_wr_valid(res_ln_wr_valid),
  .res_ln_wr_ready(res_ln_wr_ready),
  .res_ln_wr_mask(res_ln_wr_mask),
  .res_ln_wr_addr(res_ln_wr_addr),
  .res_ln_wr_data(res_ln_wr_data),
  .res_ln_wr_tag(res_ln_wr_tag),
  .res_ln_wr_rsp_valid(res_ln_wr_rsp_valid),
  .res_ln_wr_rsp_ready(res_ln_wr_rsp_ready),
  .res_ln_wr_rsp_tag(res_ln_wr_rsp_tag),
  .res_ln_rd_valid(res_ln_rd_valid),
  .res_ln_rd_ready(res_ln_rd_ready),
  .res_ln_rd_mask(res_ln_rd_mask),
  .res_ln_rd_addr(res_ln_rd_addr),
  .res_ln_rd_tag(res_ln_rd_tag),
  .res_ln_rd_rsp_valid(res_ln_rd_rsp_valid),
  .res_ln_rd_rsp_ready(res_ln_rd_rsp_ready),
  .res_ln_rd_rsp_data(res_ln_rd_rsp_data),
  .res_ln_rd_rsp_mask(res_ln_rd_rsp_mask),
  .res_ln_rd_rsp_tag(res_ln_rd_rsp_tag),
  .res_ln_idle(res_ln_idle),
  .res_sfu_lease_valid(res_sfu_lease_valid),
  .res_sfu_lease_ready(res_sfu_lease_ready),
  .res_sfu_lease_request_id(res_sfu_lease_request_id),
  .res_sfu_lease_generation(res_sfu_lease_generation),
  .res_sfu_lease_epoch(res_sfu_lease_epoch),
  .res_sfu_lease_head(res_sfu_lease_head),
  .res_sfu_lease_phase(res_sfu_lease_phase),
  .res_sfu_release_valid(res_sfu_release_valid),
  .res_sfu_release_phase(res_sfu_release_phase),
  .res_sfu_release_epoch(res_sfu_release_epoch),
  .res_sfu_phase_debt_clear(res_sfu_phase_debt_clear),
  .res_sfu_lease_active(res_sfu_lease_active),
  .res_sfu_context_valid(res_sfu_context_valid),
  .res_sfu_context_row_hi(res_sfu_context_row_hi),
  .res_sfu_req_valid(res_sfu_req_valid),
  .res_sfu_req_ready(res_sfu_req_ready),
  .res_sfu_req_mode(res_sfu_req_mode),
  .res_sfu_req_generation(res_sfu_req_generation),
  .res_sfu_req_epoch(res_sfu_req_epoch),
  .res_sfu_req_phase(res_sfu_req_phase),
  .res_sfu_req_tag(res_sfu_req_tag),
  .res_sfu_req_x(res_sfu_req_x),
  .res_sfu_reject_valid(res_sfu_reject_valid),
  .res_sfu_rsp_valid(res_sfu_rsp_valid),
  .res_sfu_rsp_ready(res_sfu_rsp_ready),
  .res_sfu_rsp_tag(res_sfu_rsp_tag),
  .res_sfu_rsp_data(res_sfu_rsp_data),
  .res_sfu_pending_vectors(res_sfu_pending_vectors),
  .res_sfu_in_flight_vectors(res_sfu_in_flight_vectors),
  .res_sfu_protocol_fault(res_sfu_protocol_fault),
  .res_div_lease_valid(res_div_lease_valid),
  .res_div_lease_ready(res_div_lease_ready),
  .res_div_lease_request_id(res_div_lease_request_id),
  .res_div_lease_generation(res_div_lease_generation),
  .res_div_lease_epoch(res_div_lease_epoch),
  .res_div_lease_head(res_div_lease_head),
  .res_div_lease_phase(res_div_lease_phase),
  .res_div_release_valid(res_div_release_valid),
  .res_div_release_phase(res_div_release_phase),
  .res_div_release_epoch(res_div_release_epoch),
  .res_div_phase_debt_clear(res_div_phase_debt_clear),
  .res_div_lease_active(res_div_lease_active),
  .res_div_req_valid(res_div_req_valid),
  .res_div_req_ready(res_div_req_ready),
  .res_div_req_generation(res_div_req_generation),
  .res_div_req_epoch(res_div_req_epoch),
  .res_div_req_phase(res_div_req_phase),
  .res_div_req_lane_mask(res_div_req_lane_mask),
  .res_div_req_tag(res_div_req_tag),
  .res_div_req_a(res_div_req_a),
  .res_div_req_b(res_div_req_b),
  .res_div_protocol_reject_valid(res_div_protocol_reject_valid),
  .res_div_rsp_valid(res_div_rsp_valid),
  .res_div_rsp_ready(res_div_rsp_ready),
  .res_div_rsp_tag(res_div_rsp_tag),
  .res_div_rsp_numeric_error(res_div_rsp_numeric_error),
  .res_div_rsp_data(res_div_rsp_data),
  .res_div_pending_vectors(res_div_pending_vectors),
  .res_div_in_flight_vectors(res_div_in_flight_vectors),
  .res_div_in_flight_scalars(res_div_in_flight_scalars),
  .res_div_protocol_fault(res_div_protocol_fault),
  .res_scale_valid(res_scale_valid),
  .res_scale_ready(res_scale_ready),
  .res_scale_tag(res_scale_tag),
  .res_scale_input(res_scale_input),
  .res_scale_rsp_valid(res_scale_rsp_valid),
  .res_scale_rsp_ready(res_scale_rsp_ready),
  .res_scale_rsp_tag(res_scale_rsp_tag),
  .res_scale_data(res_scale_data),
  .res_scale_pending(res_scale_pending),
  .res_scale_fault(res_scale_fault),
  .rope_owner_valid(rope_owner_valid),
  .rope_owner_request_id(rope_owner_request_id),
  .rope_owner_generation(rope_owner_generation),
  .rope_owner_epoch(rope_owner_epoch),
  .rope_wr_valid(rope_wr_valid),
  .rope_wr_ready(rope_wr_ready),
  .rope_wr_request_id(rope_wr_request_id),
  .rope_wr_generation(rope_wr_generation),
  .rope_wr_epoch(rope_wr_epoch),
  .rope_wr_head(rope_wr_head),
  .rope_wr_token(rope_wr_token),
  .rope_wr_tag(rope_wr_tag),
  .rope_wr_q(rope_wr_q),
  .rope_wr_k(rope_wr_k),
  .rope_wr_commit_valid(rope_wr_commit_valid),
  .rope_wr_commit_tag(rope_wr_commit_tag),
  .rope_reject_valid(rope_reject_valid),
  .rope_reject_code(rope_reject_code),
  .cache_bound_valid(coeff_bound_valid),
  .cache_bound_model_id(coeff_bound_model_id),
  .cache_bound_numeric_id(coeff_bound_numeric_id),
  .cache_bound_table_key(coeff_bound_table_key),
  .cache_family_complete(coeff_family_complete),
  .cache_owner_valid(cache_owner_valid),
  .cache_owner_request_id(cache_owner_request_id),
  .cache_owner_generation(cache_owner_generation),
  .cache_owner_epoch(cache_owner_epoch),
  .cache_rd_valid(cache_rd_valid),
  .cache_rd_ready(cache_rd_ready),
  .cache_rd_family(cache_rd_family),
  .cache_rd_row(cache_rd_row),
  .cache_rd_tag(cache_rd_tag),
  .cache_rd_request_id(cache_rd_request_id),
  .cache_rd_generation(cache_rd_generation),
  .cache_rd_epoch(cache_rd_epoch),
  .cache_rd_reject_valid(cache_rd_reject_valid),
  .cache_rd_reject_code(cache_rd_reject_code),
  .cache_rsp_valid(cache_rsp_valid),
  .cache_rsp_ready(cache_rsp_ready),
  .cache_rsp_family(cache_rsp_family),
  .cache_rsp_row(cache_rsp_row),
  .cache_rsp_tag(cache_rsp_tag),
  .cache_rsp_data(cache_rsp_data)
 );
 laya_attention_resources_v1 resources(.clk,.rst_n,.res_qkv_wr_valid(res_qkv_wr_valid),.res_qkv_wr_ready(res_qkv_wr_ready),.res_qkv_wr_plane(res_qkv_wr_plane),.res_qkv_wr_head(res_qkv_wr_head),.res_qkv_wr_token(res_qkv_wr_token),.res_qkv_wr_half(res_qkv_wr_half),.res_qkv_wr_data(res_qkv_wr_data),.res_qkv_rd_valid(res_qkv_rd_valid),.res_qkv_rd_ready(res_qkv_rd_ready),.res_qkv_rd_head(res_qkv_rd_head),.res_qkv_rd_token(res_qkv_rd_token),.res_qkv_rd_tag(res_qkv_rd_tag),.res_qkv_rd_rsp_valid(res_qkv_rd_rsp_valid),.res_qkv_rd_rsp_ready(res_qkv_rd_rsp_ready),.res_qkv_rd_rsp_head(res_qkv_rd_rsp_head),.res_qkv_rd_rsp_token(res_qkv_rd_rsp_token),.res_qkv_rd_rsp_tag(res_qkv_rd_rsp_tag),.res_qkv_rd_rsp_data(res_qkv_rd_rsp_data),.res_st_bind_valid(res_st_bind_valid),.res_st_bind_ready(res_st_bind_ready),.res_st_bind_request_id(res_st_bind_request_id),.res_st_bind_generation(res_st_bind_generation),.res_st_bind_epoch(res_st_bind_epoch),.res_st_bind_head(res_st_bind_head),.res_st_bind_phase(res_st_bind_phase),.res_st_op_request_id(res_st_op_request_id),.res_st_op_generation(res_st_op_generation),.res_st_op_epoch(res_st_op_epoch),.res_st_op_phase(res_st_op_phase),.res_st_rsp_request_id(res_st_rsp_request_id),.res_st_rsp_generation(res_st_rsp_generation),.res_st_rsp_epoch(res_st_rsp_epoch),.res_st_rsp_head(res_st_rsp_head),.res_st_rsp_phase(res_st_rsp_phase),.res_st_ps_wr_valid(res_st_ps_wr_valid),.res_st_ps_wr_ready(res_st_ps_wr_ready),.res_st_ps_wr_mask(res_st_ps_wr_mask),.res_st_ps_wr_addr(res_st_ps_wr_addr),.res_st_ps_wr_data(res_st_ps_wr_data),.res_st_ps_wr_tag(res_st_ps_wr_tag),.res_st_ps_wr_rsp_valid(res_st_ps_wr_rsp_valid),.res_st_ps_wr_rsp_ready(res_st_ps_wr_rsp_ready),.res_st_ps_wr_rsp_tag(res_st_ps_wr_rsp_tag),.res_st_ps_rd_valid(res_st_ps_rd_valid),.res_st_ps_rd_ready(res_st_ps_rd_ready),.res_st_ps_rd_mask(res_st_ps_rd_mask),.res_st_ps_rd_addr(res_st_ps_rd_addr),.res_st_ps_rd_tag(res_st_ps_rd_tag),.res_st_ps_rd_rsp_valid(res_st_ps_rd_rsp_valid),.res_st_ps_rd_rsp_ready(res_st_ps_rd_rsp_ready),.res_st_ps_rd_rsp_data(res_st_ps_rd_rsp_data),.res_st_ps_rd_rsp_mask(res_st_ps_rd_rsp_mask),.res_st_ps_rd_rsp_tag(res_st_ps_rd_rsp_tag),.res_st_g_wr_valid(res_st_g_wr_valid),.res_st_g_wr_ready(res_st_g_wr_ready),.res_st_g_wr_mask(res_st_g_wr_mask),.res_st_g_wr_addr(res_st_g_wr_addr),.res_st_g_wr_data(res_st_g_wr_data),.res_st_g_wr_tag(res_st_g_wr_tag),.res_st_g_wr_rsp_valid(res_st_g_wr_rsp_valid),.res_st_g_wr_rsp_ready(res_st_g_wr_rsp_ready),.res_st_g_wr_rsp_tag(res_st_g_wr_rsp_tag),.res_st_g_rd_valid(res_st_g_rd_valid),.res_st_g_rd_ready(res_st_g_rd_ready),.res_st_g_rd_mask(res_st_g_rd_mask),.res_st_g_rd_addr(res_st_g_rd_addr),.res_st_g_rd_tag(res_st_g_rd_tag),.res_st_g_rd_rsp_valid(res_st_g_rd_rsp_valid),.res_st_g_rd_rsp_ready(res_st_g_rd_rsp_ready),.res_st_g_rd_rsp_data(res_st_g_rd_rsp_data),.res_st_g_rd_rsp_mask(res_st_g_rd_rsp_mask),.res_st_g_rd_rsp_tag(res_st_g_rd_rsp_tag),.res_st_context_wr_valid(res_st_context_wr_valid),.res_st_context_wr_ready(res_st_context_wr_ready),.res_st_context_wr_mask(res_st_context_wr_mask),.res_st_context_wr_addr(res_st_context_wr_addr),.res_st_context_wr_data(res_st_context_wr_data),.res_st_context_wr_tag(res_st_context_wr_tag),.res_st_context_wr_rsp_valid(res_st_context_wr_rsp_valid),.res_st_context_wr_rsp_ready(res_st_context_wr_rsp_ready),.res_st_context_wr_rsp_tag(res_st_context_wr_rsp_tag),.res_st_context_rd_valid(res_st_context_rd_valid),.res_st_context_rd_ready(res_st_context_rd_ready),.res_st_context_rd_mask(res_st_context_rd_mask),.res_st_context_rd_addr(res_st_context_rd_addr),.res_st_context_rd_tag(res_st_context_rd_tag),.res_st_context_rd_rsp_valid(res_st_context_rd_rsp_valid),.res_st_context_rd_rsp_ready(res_st_context_rd_rsp_ready),.res_st_context_rd_rsp_data(res_st_context_rd_rsp_data),.res_st_context_rd_rsp_mask(res_st_context_rd_rsp_mask),.res_st_context_rd_rsp_tag(res_st_context_rd_rsp_tag),.res_st_idle(res_st_idle),.res_fp_lease_valid(peer_owner?peer_lease_valid:res_fp_lease_valid),.res_fp_lease_ready(res_fp_lease_ready),.res_fp_lease_request_id(peer_owner?64'h9988776655443322:res_fp_lease_request_id),.res_fp_lease_generation(peer_owner?32'd77:res_fp_lease_generation),.res_fp_lease_epoch(peer_owner?32'd77:res_fp_lease_epoch),.res_fp_lease_head(peer_owner?4'd0:res_fp_lease_head),.res_fp_lease_phase(peer_owner?3'd1:res_fp_lease_phase),.res_fp_release_valid(peer_owner?peer_release_valid:res_fp_release_valid),.res_fp_release_ready(res_fp_release_ready),.res_fp_release_phase(peer_owner?3'd1:res_fp_release_phase),.res_fp_release_epoch(peer_owner?32'd77:res_fp_release_epoch),.res_fp_phase_debt_clear(peer_owner?(res_st_idle&&res_ln_idle):res_fp_phase_debt_clear),.res_fp_lease_active(res_fp_lease_active),.res_fp_draining(res_fp_draining),.res_fp_rsp_request_id(res_fp_rsp_request_id),.res_fp_rsp_generation(res_fp_rsp_generation),.res_fp_rsp_epoch(res_fp_rsp_epoch),.res_fp_rsp_head(res_fp_rsp_head),.res_fp_rsp_phase(res_fp_rsp_phase),.res_fp_mul_req_valid(peer_owner?peer_mul_valid:res_fp_mul_req_valid),.res_fp_mul_req_ready(res_fp_mul_req_ready),.res_fp_mul_req_phase(peer_owner?3'd1:res_fp_mul_req_phase),.res_fp_mul_req_epoch(peer_owner?32'd77:res_fp_mul_req_epoch),.res_fp_mul_req_tag(peer_owner?96'h1234:res_fp_mul_req_tag),.res_fp_mul_a(peer_owner?{256{32'h3f800000}}:res_fp_mul_a),.res_fp_mul_b(peer_owner?{256{32'h40000000}}:res_fp_mul_b),.res_fp_mul_rsp_valid(res_fp_mul_rsp_valid),.res_fp_mul_rsp_ready(peer_owner?peer_rsp_ready:res_fp_mul_rsp_ready),.res_fp_mul_rsp_tag(res_fp_mul_rsp_tag),.res_fp_mul_rsp_data(res_fp_mul_rsp_data),.res_fp_add_req_valid(res_fp_add_req_valid),.res_fp_add_req_is_root(res_fp_add_req_is_root),.res_fp_add_req_ready(res_fp_add_req_ready),.res_fp_add_req_phase(res_fp_add_req_phase),.res_fp_add_req_epoch(res_fp_add_req_epoch),.res_fp_add_req_tag(res_fp_add_req_tag),.res_fp_add_a(res_fp_add_a),.res_fp_add_b(res_fp_add_b),.res_fp_add_rsp_valid(res_fp_add_rsp_valid),.res_fp_add_rsp_ready(res_fp_add_rsp_ready),.res_fp_add_rsp_tag(res_fp_add_rsp_tag),.res_fp_add_rsp_data(res_fp_add_rsp_data),.res_fp_mul_pending(res_fp_mul_pending),.res_fp_add_pending(res_fp_add_pending),.res_fp_protocol_fault(res_fp_protocol_fault),.res_ln_bind_valid(res_ln_bind_valid),.res_ln_bind_ready(res_ln_bind_ready),.res_ln_bind_request_id(res_ln_bind_request_id),.res_ln_bind_generation(res_ln_bind_generation),.res_ln_bind_epoch(res_ln_bind_epoch),.res_ln_bind_head(res_ln_bind_head),.res_ln_bind_phase(res_ln_bind_phase),.res_ln_op_request_id(res_ln_op_request_id),.res_ln_op_generation(res_ln_op_generation),.res_ln_op_epoch(res_ln_op_epoch),.res_ln_op_phase(res_ln_op_phase),.res_ln_rsp_request_id(res_ln_rsp_request_id),.res_ln_rsp_generation(res_ln_rsp_generation),.res_ln_rsp_epoch(res_ln_rsp_epoch),.res_ln_rsp_head(res_ln_rsp_head),.res_ln_rsp_phase(res_ln_rsp_phase),.res_ln_wr_valid(res_ln_wr_valid),.res_ln_wr_ready(res_ln_wr_ready),.res_ln_wr_mask(res_ln_wr_mask),.res_ln_wr_addr(res_ln_wr_addr),.res_ln_wr_data(res_ln_wr_data),.res_ln_wr_tag(res_ln_wr_tag),.res_ln_wr_rsp_valid(res_ln_wr_rsp_valid),.res_ln_wr_rsp_ready(res_ln_wr_rsp_ready),.res_ln_wr_rsp_tag(res_ln_wr_rsp_tag),.res_ln_rd_valid(res_ln_rd_valid),.res_ln_rd_ready(res_ln_rd_ready),.res_ln_rd_mask(res_ln_rd_mask),.res_ln_rd_addr(res_ln_rd_addr),.res_ln_rd_tag(res_ln_rd_tag),.res_ln_rd_rsp_valid(res_ln_rd_rsp_valid),.res_ln_rd_rsp_ready(res_ln_rd_rsp_ready),.res_ln_rd_rsp_data(res_ln_rd_rsp_data),.res_ln_rd_rsp_mask(res_ln_rd_rsp_mask),.res_ln_rd_rsp_tag(res_ln_rd_rsp_tag),.res_ln_idle(res_ln_idle),.res_sfu_lease_valid(res_sfu_lease_valid),.res_sfu_lease_ready(res_sfu_lease_ready),.res_sfu_lease_request_id(res_sfu_lease_request_id),.res_sfu_lease_generation(res_sfu_lease_generation),.res_sfu_lease_epoch(res_sfu_lease_epoch),.res_sfu_lease_head(res_sfu_lease_head),.res_sfu_lease_phase(res_sfu_lease_phase),.res_sfu_release_valid(res_sfu_release_valid),.res_sfu_release_phase(res_sfu_release_phase),.res_sfu_release_epoch(res_sfu_release_epoch),.res_sfu_phase_debt_clear(res_sfu_phase_debt_clear),.res_sfu_lease_active(res_sfu_lease_active),.res_sfu_context_valid(res_sfu_context_valid),.res_sfu_context_row_hi(res_sfu_context_row_hi),.res_sfu_req_valid(res_sfu_req_valid),.res_sfu_req_ready(res_sfu_req_ready),.res_sfu_req_mode(res_sfu_req_mode),.res_sfu_req_generation(res_sfu_req_generation),.res_sfu_req_epoch(res_sfu_req_epoch),.res_sfu_req_phase(res_sfu_req_phase),.res_sfu_req_tag(res_sfu_req_tag),.res_sfu_req_x(res_sfu_req_x),.res_sfu_reject_valid(res_sfu_reject_valid),.res_sfu_rsp_valid(res_sfu_rsp_valid),.res_sfu_rsp_ready(res_sfu_rsp_ready),.res_sfu_rsp_tag(res_sfu_rsp_tag),.res_sfu_rsp_data(res_sfu_rsp_data),.res_sfu_pending_vectors(res_sfu_pending_vectors),.res_sfu_in_flight_vectors(res_sfu_in_flight_vectors),.res_sfu_protocol_fault(res_sfu_protocol_fault),.res_div_lease_valid(res_div_lease_valid),.res_div_lease_ready(res_div_lease_ready),.res_div_lease_request_id(res_div_lease_request_id),.res_div_lease_generation(res_div_lease_generation),.res_div_lease_epoch(res_div_lease_epoch),.res_div_lease_head(res_div_lease_head),.res_div_lease_phase(res_div_lease_phase),.res_div_release_valid(res_div_release_valid),.res_div_release_phase(res_div_release_phase),.res_div_release_epoch(res_div_release_epoch),.res_div_phase_debt_clear(res_div_phase_debt_clear),.res_div_lease_active(res_div_lease_active),.res_div_req_valid(res_div_req_valid),.res_div_req_ready(res_div_req_ready),.res_div_req_generation(res_div_req_generation),.res_div_req_epoch(res_div_req_epoch),.res_div_req_phase(res_div_req_phase),.res_div_req_lane_mask(res_div_req_lane_mask),.res_div_req_tag(res_div_req_tag),.res_div_req_a(res_div_req_a),.res_div_req_b(res_div_req_b),.res_div_protocol_reject_valid(res_div_protocol_reject_valid),.res_div_rsp_valid(res_div_rsp_valid),.res_div_rsp_ready(res_div_rsp_ready),.res_div_rsp_tag(res_div_rsp_tag),.res_div_rsp_numeric_error(res_div_rsp_numeric_error),.res_div_rsp_data(res_div_rsp_data),.res_div_pending_vectors(res_div_pending_vectors),.res_div_in_flight_vectors(res_div_in_flight_vectors),.res_div_in_flight_scalars(res_div_in_flight_scalars),.res_div_protocol_fault(res_div_protocol_fault),.res_scale_valid(res_scale_valid),.res_scale_ready(res_scale_ready),.res_scale_tag(res_scale_tag),.res_scale_input(res_scale_input),.res_scale_rsp_valid(res_scale_rsp_valid),.res_scale_rsp_ready(res_scale_rsp_ready),.res_scale_rsp_tag(res_scale_rsp_tag),.res_scale_data(res_scale_data),.res_scale_pending(res_scale_pending),.res_scale_fault(res_scale_fault),.rope_owner_valid(rope_owner_valid),.rope_owner_request_id(rope_owner_request_id),.rope_owner_generation(rope_owner_generation),.rope_owner_epoch(rope_owner_epoch),.rope_wr_valid(rope_wr_valid),.rope_wr_ready(rope_wr_ready),.rope_wr_request_id(rope_wr_request_id),.rope_wr_generation(rope_wr_generation),.rope_wr_epoch(rope_wr_epoch),.rope_wr_head(rope_wr_head),.rope_wr_token(rope_wr_token),.rope_wr_tag(rope_wr_tag),.rope_wr_q(rope_wr_q),.rope_wr_k(rope_wr_k),.rope_wr_commit_valid(rope_wr_commit_valid),.rope_wr_commit_tag(rope_wr_commit_tag),.rope_reject_valid(rope_reject_valid),.rope_reject_code(rope_reject_code));
 laya_rope_coeff_cache_v1 coeff(.clk(clk),.rst_n(rst_n),.bind_valid(coeff_bind_valid),.bind_ready(coeff_bind_ready),.bind_model_id(coeff_bind_model_id),.bind_numeric_id(coeff_bind_numeric_id),.bind_table_key(coeff_bind_table_key),.bound_valid(coeff_bound_valid),.bound_model_id(coeff_bound_model_id),.bound_numeric_id(coeff_bound_numeric_id),.bound_table_key(coeff_bound_table_key),.family_complete(coeff_family_complete),.wr_valid(coeff_wr_valid),.wr_ready(coeff_wr_ready),.wr_model_id(coeff_wr_model_id),.wr_numeric_id(coeff_wr_numeric_id),.wr_table_key(coeff_wr_table_key),.wr_table(coeff_wr_table),.wr_row(coeff_wr_row),.wr_half(coeff_wr_half),.wr_data(coeff_wr_data),.wr_reject_valid(coeff_wr_reject_valid),.wr_reject_code(coeff_wr_reject_code),.wr_nonfinite_lane(coeff_wr_nonfinite_lane),.owner_valid(cache_owner_valid),.owner_request_id(cache_owner_request_id),.owner_generation(cache_owner_generation),.owner_epoch(cache_owner_epoch),.rd_valid(cache_rd_valid),.rd_ready(cache_rd_ready),.rd_family(cache_rd_family),.rd_row(cache_rd_row),.rd_tag(cache_rd_tag),.rd_request_id(cache_rd_request_id),.rd_generation(cache_rd_generation),.rd_epoch(cache_rd_epoch),.rd_reject_valid(cache_rd_reject_valid),.rd_reject_code(cache_rd_reject_code),.rsp_valid(cache_rsp_valid),.rsp_ready(cache_rsp_ready),.rsp_family(cache_rsp_family),.rsp_row(cache_rsp_row),.rsp_tag(cache_rsp_tag),.rsp_data(cache_rsp_data));
 assign peer_lease_ready=res_fp_lease_ready;assign peer_mul_ready=res_fp_mul_req_ready;assign peer_rsp_valid=res_fp_mul_rsp_valid;assign peer_active=res_fp_lease_active;assign peer_pending=res_fp_mul_pending;assign peer_fault=res_fp_protocol_fault;
endmodule
