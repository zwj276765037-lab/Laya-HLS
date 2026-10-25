`timescale 1ns/1ps
module m011_layer_reachable_fault_tb;
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
 logic  result_discard_valid;
 logic  result_discard_ready;
 logic [31:0] result_discard_generation;
 logic  context_discarded;
 logic [31:0] producer_done_cycles;
 logic [31:0] context_release_cycles;
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
 initial clk=0;always #1.6665 clk=~clk;laya_attention_layer_v1 dut(.*);
 logic[31:0]pre[0:393215],maskmem[0:127];logic[15:0]product_faults;logic[95:0]expected_tuple;string data;int fd,nb,pilot=0,cycle=0,nload=0,nheads=0,ncontexts=0,nmul=0,nscore=0;
 task automatic step;@(posedge clk);#0.1;endtask
 function automatic int qi(input int t,p,h,c);return((t*3+p)*16+h)*64+c;endfunction
 initial begin
  clk='0;
  rst_n='0;
  prepare_valid='0;
  prepare_request_id='0;
  prepare_model_id='0;
  prepare_generation='0;
  prepare_epoch='0;
  prepare_numeric_id='0;
  prepare_table_key='0;
  prepare_kind='0;
  prepare_layer='0;
  prepare_mask='0;
  qkv_wr_valid='0;
  qkv_wr_request_id='0;
  qkv_wr_generation='0;
  qkv_wr_epoch='0;
  qkv_wr_plane='0;
  qkv_wr_head='0;
  qkv_wr_token='0;
  qkv_wr_half='0;
  qkv_wr_data='0;
  start_valid='0;
  start_request_id='0;
  start_generation='0;
  abort_valid='0;
  qkv_read_grant='0;
  ps_grant='0;
  g_grant='0;
  context_grant='0;
  fp_grant='0;
  sfu_grant='0;
  exp_grant='0;
  div_grant='0;
  rope_write_grant='0;
  done_ready='0;
  result_rd_valid='0;
  result_rd_generation='0;
  result_rd_tag='0;
  result_rd_head='0;
  result_rd_query='0;
  result_rd_half='0;
  result_rsp_ready='0;
  result_discard_valid='0;
  result_discard_generation='0;
  coeff_bind_valid='0;
  coeff_bind_model_id='0;
  coeff_bind_numeric_id='0;
  coeff_bind_table_key='0;
  coeff_wr_valid='0;
  coeff_wr_model_id='0;
  coeff_wr_numeric_id='0;
  coeff_wr_table_key='0;
  coeff_wr_table='0;
  coeff_wr_row='0;
  coeff_wr_half='0;
  coeff_wr_data='0;
  if(!$value$plusargs("DATA=%s",data))$fatal(1,"DATA");if(!$value$plusargs("PILOT_HEADS=%d",pilot))pilot=1;
  fd=$fopen({data,"/decision0_reverse_qk_pre.bin"},"rb");if(fd==0)$fatal(1,"fault fixture");nb=$fread(pre,fd);if(nb!=1572864||$fgetc(fd)!=-1)$fatal(1,"fault input size/tail");$fclose(fd);for(int i=0;i<393216;i++)begin pre[i]={pre[i][7:0],pre[i][15:8],pre[i][23:16],pre[i][31:24]};if(pre[i][30:23]==8'hff)$fatal(1,"fault input not finite");end
  $readmemh({data,"/mask.mem"},maskmem);expected_tuple={8'd11,16'd0,16'd15,16'd0,16'd7,16'd0,8'd0};product_faults=0;
  qkv_read_grant=7;ps_grant=1;g_grant=1;context_grant=1;fp_grant=1;sfu_grant=1;exp_grant=1;div_grant=1;rope_write_grant=1;
  prepare_request_id=77;prepare_generation=8;prepare_epoch=9;prepare_model_id=128'h6eb6ef58bc4f99bd9db40381604108af;prepare_numeric_id=128'haeb13e7937d29fe6a2c68c407249f294;prepare_table_key=128'hb1fdc9ca482c0210982c7245cc50c965;prepare_kind=2;prepare_layer=0;for(int r=0;r<128;r++)prepare_mask[r]=maskmem[r][0];qkv_wr_request_id=77;qkv_wr_generation=8;qkv_wr_epoch=9;start_request_id=77;start_generation=8;result_rd_generation=8;
  repeat(4)step();@(negedge clk);rst_n=1;prepare_valid=1;#0.1;if(!prepare_ready)$fatal(1,"fault prepare");step();@(negedge clk);prepare_valid=0;
  for(int t=0;t<128;t++)for(int p=0;p<3;p++)for(int h=0;h<16;h++)for(int half=0;half<2;half++)begin
   qkv_wr_valid=1;qkv_wr_plane=p;qkv_wr_head=h;qkv_wr_token=t;qkv_wr_half=half;for(int c=0;c<32;c++)qkv_wr_data[c]=pre[qi(t,p,h,half*32+c)];#0.1;if(!qkv_wr_ready)$fatal(1,"fault public QKV load");step();@(negedge clk);
  end qkv_wr_valid=0;start_valid=1;#0.1;if(!start_ready)$fatal(1,"fault start");step();@(negedge clk);start_valid=0;
  while(!done_valid)step();if(done_status!=1||!error_valid||error_tuple!==expected_tuple||head_completed!==16'hffff||head_context_valid!=0||product_faults!==16'hffff||nheads!=16||ncontexts!=0||nload!=12288)$fatal(1,"reachable layer Check status%0d tuple%h heads%h valid%h",done_status,error_tuple,head_completed,head_context_valid);
  if(check_completed[0]!==16'hffff||check_completed[11]!==16'hffff||check_completed[12]!==16'hffff)$fatal(1,"actual QK coverage missing");
  for(int s=1;s<26;s++)if(s!=11&&s!=12)begin if(check_unreachable[s]!==16'hffff||check_completed[s]!=0)$fatal(1,"unreachable stage fabricated%0d",s);end
  if(av_check_unreachable!={2048{1'b1}}||av_check_completed!=0||!context_discarded||dut.output_consumed!=0||!dut.real_idle)$fatal(1,"invalid context/drain classification");
  result_rd_valid=1;#0.1;if(result_rd_ready)$fatal(1,"bad context exposed");repeat(3)step();@(negedge clk);result_rd_valid=0;done_ready=1;step();@(negedge clk);done_ready=0;while(!prepare_ready)step();
  // Real no-reset ownership recovery: new preparation cannot inherit coverage.
  @(negedge clk);prepare_generation=9;prepare_valid=1;step();@(negedge clk);prepare_valid=0;start_valid=1;start_generation=8;qkv_wr_valid=1;qkv_wr_generation=8;#0.1;if(start_ready||qkv_wr_ready)$fatal(1,"old generation ownership");step();@(negedge clk);start_valid=0;qkv_wr_valid=0;start_generation=9;qkv_wr_generation=9;
  for(int half=0;half<2;half++)begin qkv_wr_valid=1;qkv_wr_plane=0;qkv_wr_head=0;qkv_wr_token=0;qkv_wr_half=half;for(int c=0;c<32;c++)qkv_wr_data[c]=0;#0.1;if(!qkv_wr_ready)$fatal(1,"new generation refill");step();@(negedge clk);end qkv_wr_valid=0;start_valid=1;#0.1;if(start_ready)$fatal(1,"partial generation inherited old coverage");step();@(negedge clk);start_valid=0;
  $display("HARDWARE_AGENT_SIM_PASS M011_LAYER_REACHABLE_FAULT heads16 finite_public_inputs393216 original_head0_tile15_selected1 later_heads_tile0_rejected_as_first1 real_QK_products_and_trees1 no_bad_context1 separate_actual_unreachable_maps1 no_reset_newgen_ownership1 partial_refill_not_arithmetic_recovery1");$finish;
 end
 always@(posedge clk)begin
  cycle++;if(cycle>40000000)$fatal(1,"cycle cap");
  if(rst_n)begin
   if(qkv_wr_valid&&qkv_wr_ready)nload++;
   if(dut.h_start_valid&&dut.h_start_ready)begin nmul=0;nscore=0;$display("M011_LAYER_HEAD_BEGIN head=%0d cycle=%0d",active_head,cycle);end
   if(dut.res_st_context_wr_valid&&dut.res_st_context_wr_ready)ncontexts++;
   if(dut.res_sfu_lease_valid||dut.res_div_lease_valid||dut.h_check_sm_done||dut.h_check_av_done)$fatal(1,"badhead entered downstream");
   if(dut.res_fp_rsp_phase==2&&dut.res_fp_mul_rsp_valid&&dut.res_fp_mul_rsp_ready)begin
    nmul++;for(int q=0;q<4;q++)for(int c=0;c<64;c++)if(dut.res_fp_mul_rsp_data[q*64+c][30:23]==8'hff)begin
     int row,key;row=int'(dut.res_fp_mul_rsp_tag[11:7])*4+q;key=int'(dut.res_fp_mul_rsp_tag[6:0]);if(row!=(active_head==0?127:0)||key!=0||c!=0)$fatal(1,"unexpected actual product fault");product_faults[active_head]=1;
    end
   end
   if(dut.res_fp_rsp_phase==2&&dut.res_st_ps_wr_valid&&dut.res_st_ps_wr_ready)nscore++;
   if(dut.h_done_valid&&dut.h_done_ready)begin
    if(dut.h_done_status!=1||dut.h_error_phase!=0||nmul!=4096||nscore!=4096||dut.h_softmax_cycles!=0||dut.h_av_cycles!=0||!product_faults[active_head])$fatal(1,"fault head coverage h%0d m%0d score%0d",active_head,nmul,nscore);
    nheads++;if(!error_valid||error_tuple!==expected_tuple)$fatal(1,"crosshead original tuple lost");$display("M011_LAYER_HEAD_END head=%0d cycle=%0d cycles=%0d actual_QK_only=1",active_head,cycle,dut.h_done_cycles);
    if(pilot!=0&&nheads==pilot)begin if(done_valid||dut.check_ready)$fatal(1,"premature global first-error publish");$display("HARDWARE_AGENT_SIM_PASS M011_LAYER_FAULT_PILOT heads=%0d real_finite_overflow1 head0_tile15_before_head1_tile0=1 partial_scope_only1",nheads);$finish;end
   end
  end
 end
endmodule
