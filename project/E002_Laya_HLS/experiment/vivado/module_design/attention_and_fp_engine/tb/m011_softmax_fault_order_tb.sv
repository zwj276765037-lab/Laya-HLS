`timescale 1ns/1ps
module m011_softmax_fault_order_tb;
 logic  clk=0;
 logic  rst_n=0;
 logic  prepare_valid=0;
 logic  prepare_ready;
 logic [63:0] prepare_request_id=0;
 logic [31:0] prepare_generation=0;
 logic [31:0] prepare_epoch=0;
 logic [3:0] prepare_head=0;
 logic [127:0][31:0] prepare_maximum=0;
 logic  score_wr_valid=0;
 logic  score_wr_ready;
 logic [31:0] score_wr_generation=0;
 logic [6:0] score_wr_row=0;
 logic [3:0] score_wr_chunk=0;
 logic [7:0][31:0] score_wr_data=0;
 logic  start_valid=0;
 logic  start_ready;
 logic [63:0] start_request_id=0;
 logic [31:0] start_generation=0;
 logic  abort_valid=0;
 logic  abort_ready;
 logic  score_grant=0;
 logic  fp_grant=0;
 logic  sfu_grant=0;
 logic  exp_grant=0;
 logic  div_grant=0;
 logic  prob_grant=0;
 logic  done_valid;
 logic  done_ready=0;
 logic [7:0] done_status;
 logic [31:0] done_cycles;
 logic [31:0] first_row_cycle;
 logic [31:0] max_sum_tail;
 logic [31:0] max_row_launch_gap;
 logic [7:0] rows_launched;
 logic [7:0] rows_retired;
 logic [11:0] probability_commits;
 logic  error_valid;
 logic [63:0] error_rank;
 logic [4:0] error_phase;
 logic [6:0] error_row;
 logic [6:0] error_node;
 logic [31:0] error_element;
 logic  prob_rd_valid=0;
 logic  prob_rd_ready;
 logic [31:0] prob_rd_generation=0;
 logic [31:0] prob_rd_tag=0;
 logic [6:0] prob_rd_row=0;
 logic [3:0] prob_rd_chunk=0;
 logic  prob_rsp_valid;
 logic  prob_rsp_ready=0;
 logic [31:0] prob_rsp_tag;
 logic [7:0][31:0] prob_rsp_data;
 laya_attention_softmax_v1 dut(.clk,.rst_n,.prepare_valid,.prepare_ready,.prepare_request_id,.prepare_generation,.prepare_epoch,.prepare_head,.prepare_maximum,.score_wr_valid,.score_wr_ready,.score_wr_generation,.score_wr_row,.score_wr_chunk,.score_wr_data,.start_valid,.start_ready,.start_request_id,.start_generation,.abort_valid,.abort_ready,.score_grant,.fp_grant,.sfu_grant,.exp_grant,.div_grant,.prob_grant,.done_valid,.done_ready,.done_status,.done_cycles,.first_row_cycle,.max_sum_tail,.max_row_launch_gap,.rows_launched,.rows_retired,.probability_commits,.error_valid,.error_rank,.error_phase,.error_row,.error_node,.error_element,.prob_rd_valid,.prob_rd_ready,.prob_rd_generation,.prob_rd_tag,.prob_rd_row,.prob_rd_chunk,.prob_rsp_valid,.prob_rsp_ready,.prob_rsp_tag,.prob_rsp_data);
 always #1.6665 clk=~clk;
 string data_dir;logic[31:0]gold_score[0:16383],gold_max[0:127],gold_prob[0:16383];int cycle=0,faultcase=0,nscore=0,nprob=0,nack=0;bit checking=0;logic[2047:0]seen;logic[31:0]expect_phase;int first_physical_error=-1;
 task automatic run_case(input int kind);
  faultcase=kind;nscore=0;nprob=0;nack=0;seen=0;
  @(negedge clk);score_grant=1;fp_grant=1;sfu_grant=1;exp_grant=1;div_grant=1;prob_grant=1;
  prepare_request_id=64'(20+kind);prepare_generation=32'(10+kind);prepare_epoch=32'(300+kind);prepare_head=0;
  for(int r=0;r<128;r++)prepare_maximum[r]=gold_max[r];
  case(kind)1,5:prepare_maximum[0]=32'h7f7fffff;2,3:prepare_maximum[0]=0;default:;endcase
  prepare_valid=1;do @(posedge clk);while(!prepare_ready);@(negedge clk);prepare_valid=0;
  for(int r=0;r<128;r++)for(int c=0;c<16;c++)begin
   score_wr_valid=1;score_wr_generation=prepare_generation;score_wr_row=7'(r);score_wr_chunk=4'(c);
   for(int i=0;i<8;i++)begin score_wr_data[i]=gold_score[r*128+c*8+i];if(r==0)case(kind)0:if(c==0&&i==0)score_wr_data[i]=32'h7fc12345;1,5:score_wr_data[i]=32'hff7fffff;2:score_wr_data[i]=32'h3f800000;3:score_wr_data[i]=32'hc4fa0000;default:;endcase if(kind==5&&r==127&&c==15&&i==7)score_wr_data[i]=32'h7fc12345;end
   do @(posedge clk);while(!score_wr_ready);@(negedge clk);
  end
  score_wr_valid=0;checking=1;start_valid=1;start_request_id=prepare_request_id;start_generation=prepare_generation;do @(posedge clk);while(!start_ready);@(negedge clk);start_valid=0;
  wait(done_valid);@(negedge clk);checking=0;score_grant=1;fp_grant=1;sfu_grant=1;exp_grant=1;div_grant=1;prob_grant=1;
  expect_phase=(kind==0||kind==5)?7:kind==1?8:kind==2?9:17;
  if(kind<4||kind==5)begin
   if(done_status!==1||!error_valid||error_phase!==expect_phase[4:0]||error_row!==(kind==5?7'd127:7'd0)||error_node!==(kind==5?7'd127:7'd0)||error_element!==(kind==5?32'd16383:32'd0)||error_rank!==(64'h4000000000000000|(64'(expect_phase)<<48)|(kind==5?64'h7f007f:64'd0)))$fatal(1,"SM_FAULT_CHECK kind%0d status%0d phase%0d row%0d node%0d rank%h",kind,done_status,error_phase,error_row,error_node,error_rank);
   if(nprob!=(kind==5?16128:16256)||nack!=(kind==5?2016:2032)||probability_commits!=(kind==5?2016:2032)||nscore!=16384||rows_launched!=128||rows_retired!=128||dut.engine.active!=0||!dut.resource_debt_clear)$fatal(1,"SM_FAULT_DEBT kind%0d prob%0d ack%0d score%0d rows%0d/%0d",kind,nprob,nack,nscore,rows_launched,rows_retired);
   prob_rd_valid=1;prob_rd_generation=prepare_generation;#0.1;if(prob_rd_ready||prob_rsp_valid)$fatal(1,"SM_FAULT_PUBLISH");prob_rd_valid=0;
  end else begin if(done_status!==0||error_valid||nprob!=16384||nack!=2048||nscore!=16384||seen!='1||probability_commits!=2048||!dut.resource_debt_clear)$fatal(1,"SM_STALL_CHECK status%0d prob%0d ack%0d score%0d",done_status,nprob,nack,nscore);end
  if(kind==5&&first_physical_error!=8)$fatal(1,"SM_LOGICAL_ORDER_PHYSICAL_FIRST %0d",first_physical_error);
  repeat(3)begin @(posedge clk);if(!done_valid||done_status!==((kind<4||kind==5)?8'd1:8'd0))$fatal(1,"SM_FAULT_DONE_HOLD");end @(negedge clk);done_ready=1;@(posedge clk);@(negedge clk);done_ready=0;wait(prepare_ready);@(negedge clk);
  $display("M011_SOFTMAX_FAULT_PASS kind%0d phase%0d score16384 rows128 probability_scalars%0d commits%0d cycles%0d no_error_result_publication1 donehold3 debt0 newgen%0d",kind,error_phase,nprob,nack,done_cycles,prepare_generation);
 endtask
 initial begin
  if(!$value$plusargs("DATA=%s",data_dir))$fatal(1,"DATA required");$readmemh({data_dir,"/full_score.mem"},gold_score);$readmemh({data_dir,"/full_maximum.mem"},gold_max);$readmemh({data_dir,"/full_prob.mem"},gold_prob);
  repeat(4)@(negedge clk);rst_n=1;run_case(5);
  $display("HARDWARE_AGENT_SIM_PASS M011_FAULT_ORDER first_physical_phase8_row0 selected_logical_phase7_row127_node1271 allscore16384 checked_goodprob16128 commits2016 real_debt0");$finish;
 end
 always @(negedge clk)if(rst_n&&checking&&faultcase==4)begin score_grant=cycle%29!=0;fp_grant=cycle%43>2;sfu_grant=cycle%17!=0;exp_grant=cycle%37>1;div_grant=cycle%31!=0;prob_grant=cycle%23>2;end
 always @(posedge clk)begin
  cycle=cycle+1;if(cycle>40000)$fatal(1,"SM_FAULT_TIMEOUT kind%0d state%0d eng%0d row%0d/%0d active%h fault%0d",faultcase,dut.state,dut.engine.state,dut.engine.read_row,dut.engine.norm_row,dut.engine.active,dut.engine.protocol_bad);
  if(rst_n&&checking)begin
   if(dut.resource_fault)$fatal(1,"SM_FAULT_RESOURCE");
   if(dut.score_rsp_valid&&dut.score_rsp_ready)begin nscore+=8;if(dut.score_rsp_tag==2047&&first_physical_error<0)first_physical_error=7;end
   if(dut.fp_rsp_valid&&dut.fp_rsp_ready&&dut.engine.tv(dut.fp_rsp_tag,0)&&dut.engine.tr(dut.fp_rsp_tag,0)==0)begin
    if(faultcase==5&&first_physical_error<0)first_physical_error=8;
    for(int i=0;i<8;i++)case(faultcase)1,5:if(dut.fp_rsp_data[i]!==32'hff800000)$fatal(1,"SM_EXPECT_SHIFT_INF");2:if(dut.fp_rsp_data[i]!==32'h3f800000)$fatal(1,"SM_EXPECT_SHIFT_POSITIVE");3:if(dut.fp_rsp_data[i]!==32'hc4fa0000)$fatal(1,"SM_EXPECT_SHIFT_NEG2000");default:;endcase
   end
   if(dut.sfu_rsp_valid&&dut.sfu_rsp_ready&&dut.sfu_rsp_tag[10:4]==0&&faultcase==3)for(int i=0;i<8;i++)if(dut.sfu_rsp_data[i]!==0)$fatal(1,"SM_EXPECT_EXP_ZERO");
   if(dut.fp_rsp_valid&&dut.fp_rsp_ready&&dut.engine.tv(dut.fp_rsp_tag,7)&&dut.engine.tr(dut.fp_rsp_tag,7)==0&&faultcase==3&&dut.fp_rsp_data[18]!==0)$fatal(1,"SM_EXPECT_TOTAL_ZERO");
   if(dut.prob_wr_valid&&dut.prob_wr_ready)begin int row,ch;row=int'(dut.prob_wr_tag[10:4]);ch=int'(dut.prob_wr_tag[3:0]);if((row==0&&(faultcase<4||faultcase==5))||(row==127&&faultcase==5))$fatal(1,"SM_BAD_ROW_WRITE");if(seen[dut.prob_wr_tag])$fatal(1,"SM_FAULT_DUP_WRITE");seen[dut.prob_wr_tag]=1;for(int i=0;i<8;i++)if(dut.prob_wr_data[i]!==gold_prob[row*128+ch*8+i])$fatal(1,"SM_FAULT_GOOD_ROW_VALUE kind%0d row%0d ch%0d",faultcase,row,ch);nprob+=8;end
   if(dut.prob_wr_ack_valid&&dut.prob_wr_ack_ready)nack++;
  end
 end
endmodule
