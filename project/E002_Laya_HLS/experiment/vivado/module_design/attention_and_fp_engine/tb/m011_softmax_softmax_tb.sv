`timescale 1ns/1ps
module m011_softmax_softmax_tb;
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
 always #1.6665 clk=~clk;
 laya_attention_softmax_v1 dut(.clk,.rst_n,.prepare_valid,.prepare_ready,.prepare_request_id,.prepare_generation,.prepare_epoch,.prepare_head,.prepare_maximum,.score_wr_valid,.score_wr_ready,.score_wr_generation,.score_wr_row,.score_wr_chunk,.score_wr_data,.start_valid,.start_ready,.start_request_id,.start_generation,.abort_valid,.abort_ready,.score_grant,.fp_grant,.sfu_grant,.exp_grant,.div_grant,.prob_grant,.done_valid,.done_ready,.done_status,.done_cycles,.first_row_cycle,.max_sum_tail,.max_row_launch_gap,.rows_launched,.rows_retired,.probability_commits,.error_valid,.error_rank,.error_phase,.error_row,.error_node,.error_element,.prob_rd_valid,.prob_rd_ready,.prob_rd_generation,.prob_rd_tag,.prob_rd_row,.prob_rd_chunk,.prob_rsp_valid,.prob_rsp_ready,.prob_rsp_tag,.prob_rsp_data);
 string data_dir;logic[31:0]gold_score[0:16383],gold_max[0:127],gold_shift[0:16383],gold_exp[0:16383],gold_prob[0:16383];
 int cycle=0,testcase=0;bit checking=0;int nscore,nshift,nexp,nsum[7],ndiv,nwrite,nack;logic[2047:0]write_seen,ack_seen;
 logic[31:0]gold_sum0[0:8191];
 logic[31:0]gold_sum1[0:4095];
 logic[31:0]gold_sum2[0:2047];
 logic[31:0]gold_sum3[0:1023];
 logic[31:0]gold_sum4[0:511];
 logic[31:0]gold_sum5[0:255];
 logic[31:0]gold_sum6[0:127];
 function automatic logic[31:0]sumgold(input int g,index);case(g)0:return gold_sum0[index];1:return gold_sum1[index];2:return gold_sum2[index];3:return gold_sum3[index];4:return gold_sum4[index];5:return gold_sum5[index];default:return gold_sum6[index];endcase endfunction
 function automatic bit tv(input logic[95:0]t,input int g);case(g)0:return t[11];1:return t[23];2:return t[35];3:return t[47];4:return t[58];5:return t[68];6:return t[77];default:return t[85];endcase endfunction
 function automatic int tr(input logic[95:0]t,input int g);case(g)0:return int'(t[10:4]);1:return int'(t[22:16]);2:return int'(t[34:28]);3:return int'(t[46:40]);4:return int'(t[57:51]);5:return int'(t[67:61]);6:return int'(t[76:70]);default:return int'(t[84:78]);endcase endfunction
 function automatic int ti(input logic[95:0]t,input int g);case(g)0:return int'(t[3:0]);1:return int'(t[15:12]);2:return int'(t[27:24]);3:return int'(t[39:36]);4:return int'(t[50:48]);5:return int'(t[60:59]);6:return int'(t[69]);default:return 0;endcase endfunction
 function automatic int lo(input int g);case(g)0:return 0;1:return 8;2:return 12;3:return 14;4:return 15;5:return 16;6:return 17;default:return 18;endcase endfunction
 function automatic int nn(input int g);case(g)0:return 8;1:return 4;2:return 2;default:return 1;endcase endfunction
 task automatic load_gold(input string prefix);
  $readmemh({data_dir,"/",prefix,"score.mem"},gold_score);$readmemh({data_dir,"/",prefix,"maximum.mem"},gold_max);$readmemh({data_dir,"/",prefix,"shift.mem"},gold_shift);$readmemh({data_dir,"/",prefix,"exp.mem"},gold_exp);$readmemh({data_dir,"/",prefix,"prob.mem"},gold_prob);
  $readmemh({data_dir,"/",prefix,"sum_l1.mem"},gold_sum0);
  $readmemh({data_dir,"/",prefix,"sum_l2.mem"},gold_sum1);
  $readmemh({data_dir,"/",prefix,"sum_l3.mem"},gold_sum2);
  $readmemh({data_dir,"/",prefix,"sum_l4.mem"},gold_sum3);
  $readmemh({data_dir,"/",prefix,"sum_l5.mem"},gold_sum4);
  $readmemh({data_dir,"/",prefix,"sum_l6.mem"},gold_sum5);
  $readmemh({data_dir,"/",prefix,"sum_l7.mem"},gold_sum6);

 endtask
 task automatic run_case(input string prefix);
  load_gold(prefix);nscore=0;nshift=0;nexp=0;ndiv=0;nwrite=0;nack=0;write_seen=0;ack_seen=0;for(int g=0;g<7;g++)nsum[g]=0;
  @(negedge clk);prepare_request_id=64'(3+testcase);prepare_generation=32'(1+testcase);prepare_epoch=32'(100+testcase);prepare_head=0;
  for(int r=0;r<128;r++)prepare_maximum[r]=gold_max[r];prepare_valid=1;
  do @(posedge clk);while(!prepare_ready);@(negedge clk);prepare_valid=0;
  for(int r=0;r<128;r++)for(int c=0;c<16;c++)begin
   score_wr_valid=1;score_wr_generation=prepare_generation;score_wr_row=7'(r);score_wr_chunk=4'(c);for(int i=0;i<8;i++)score_wr_data[i]=gold_score[r*128+c*8+i];
   do @(posedge clk);while(!score_wr_ready);@(negedge clk);
  end
  score_wr_valid=0;start_valid=1;start_request_id=prepare_request_id;start_generation=prepare_generation;checking=1;
  do @(posedge clk);while(!start_ready);@(negedge clk);start_valid=0;
  wait(done_valid);@(negedge clk);
  $display("M011_SOFTMAX_RESULT case%0d status%0d cycles%0d firstrow%0d tail%0d rowgap%0d rows%0d/%0d commits%0d counts score%0d shift%0d exp%0d div%0d write%0d ack%0d",testcase,done_status,done_cycles,first_row_cycle,max_sum_tail,max_row_launch_gap,rows_launched,rows_retired,probability_commits,nscore,nshift,nexp,ndiv,nwrite,nack);
  if(done_status!=0)$fatal(1,"SOFTMAX_STATUS phase%0d row%0d node%0d err%0d rank%h protocol%0d",error_phase,error_row,error_node,error_valid,error_rank,dut.engine.protocol_bad);
  if(done_cycles>2688||first_row_cycle>544||max_sum_tail>56||max_row_launch_gap>16)$fatal(1,"SOFTMAX_CYCLE_BOUND");
  if(nscore!=16384||nshift!=16384||nexp!=16384||ndiv!=16384||nwrite!=16384||nack!=2048||write_seen!='1||ack_seen!='1||rows_launched!=128||rows_retired!=128||probability_commits!=2048)$fatal(1,"SOFTMAX_COVERAGE");
  for(int g=0;g<7;g++)if(nsum[g]!=128*(64>>g))$fatal(1,"SOFTMAX_SUM_COVERAGE level%0d got%0d",g+1,nsum[g]);
  repeat(3)begin @(posedge clk);if(!done_valid||done_status!=0)$fatal(1,"SOFTMAX_DONE_HOLD");end
  @(negedge clk);
  for(int r=0;r<128;r++)for(int c=0;c<16;c++)begin
   prob_rd_valid=1;prob_rd_generation=prepare_generation;prob_rd_tag=32'(r*16+c+8192);prob_rd_row=7'(r);prob_rd_chunk=4'(c);prob_rsp_ready=0;
   do @(posedge clk);while(!prob_rd_ready);@(negedge clk);prob_rd_valid=0;
   wait(prob_rsp_valid);@(negedge clk);
   if(prob_rsp_tag!==32'(r*16+c+8192))$fatal(1,"SOFTMAX_READ_TAG");for(int i=0;i<8;i++)if(prob_rsp_data[i]!==gold_prob[r*128+c*8+i])$fatal(1,"SOFTMAX_BANK_READ r%0d c%0d i%0d got%h gold%h",r,c,i,prob_rsp_data[i],gold_prob[r*128+c*8+i]);
   if(r==127&&c==15)begin
    done_ready=1;@(posedge clk);@(negedge clk);done_ready=0;
    repeat(3)begin @(posedge clk);if(!prob_rsp_valid||prepare_ready||prob_rsp_tag!==32'(r*16+c+8192))$fatal(1,"SOFTMAX_RELEASE_HELD");for(int i=0;i<8;i++)if(prob_rsp_data[i]!==gold_prob[r*128+c*8+i])$fatal(1,"SOFTMAX_RELEASE_DATA");end
    @(negedge clk);
   end
   prob_rsp_ready=1;@(posedge clk);@(negedge clk);prob_rsp_ready=0;
  end
  checking=0;wait(prepare_ready);@(negedge clk);
  $display("M011_SOFTMAX_CASE_PASS case%0d full16384prob bankread16384 shifts16384 exp16384 all7sumlevels div16384 actualGcommits2048 done_hold3 done_consumed_read_held3 release_debt0 cycles%0d firstrow%0d tail%0d rowgap%0d",testcase,done_cycles,first_row_cycle,max_sum_tail,max_row_launch_gap);
  testcase++;
 endtask
 initial begin
  if(!$value$plusargs("DATA=%s",data_dir))$fatal(1,"DATA required");score_grant=1;fp_grant=1;sfu_grant=1;exp_grant=1;div_grant=1;prob_grant=1;
  repeat(4)@(negedge clk);rst_n=1;run_case("full_");run_case("sliding_");
  $display("HARDWARE_AGENT_SIM_PASS M011_SOFTMAX full1 sliding1 real_score_PS1 LNexp1 G1 FP2561 EXP8_167 DIV8_32");$finish;
 end
 always @(posedge clk)begin
  cycle=cycle+1;if(cycle>60000)$fatal(1,"SOFTMAX_TIMEOUT state%0d eng%0d row%0d/%0d chunks%0d retired%0d fp%0d sfu%0d div%0d active%h protocol%0d error%0d",dut.state,dut.engine.state,dut.engine.read_row,dut.engine.norm_row,dut.engine.read_chunk,rows_retired,dut.engine.fp_vectors,dut.sfu_pending,dut.div_pending,dut.context_valid,dut.engine.protocol_bad,error_valid);
  if(rst_n&&checking)begin
   if(dut.resource_fault)$fatal(1,"SOFTMAX_RESOURCE_FAULT fp%0d sfu%0d div%0d reject%0d/%0d",dut.fp_fault,dut.sfu_fault,dut.div_fault,dut.sfu_reject,dut.div_reject);
   if(dut.score_rsp_valid&&dut.score_rsp_ready)begin int r,c;r=int'(dut.score_rsp_tag[10:4]);c=int'(dut.score_rsp_tag[3:0]);for(int i=0;i<8;i++)begin if(dut.score_rsp_data[i]!==gold_score[r*128+c*8+i])$fatal(1,"SOFTMAX_SCORE_INPUT");nscore++;end end
   if(dut.fp_rsp_valid&&dut.fp_rsp_ready)for(int g=0;g<8;g++)if(tv(dut.fp_rsp_tag,g))begin
    int r,node,index;r=tr(dut.fp_rsp_tag,g);node=ti(dut.fp_rsp_tag,g);
    for(int i=0;i<nn(g);i++)begin
     index=g<4?node*nn(g)+i:node;
     if(g==0)begin if(dut.fp_rsp_data[i]!==gold_shift[r*128+index])$fatal(1,"SOFTMAX_SHIFT row%0d node%0d got%h gold%h",r,index,dut.fp_rsp_data[i],gold_shift[r*128+index]);nshift++;end
     else begin if(dut.fp_rsp_data[lo(g)+i]!==sumgold(g-1,r*(128>>g)+index))$fatal(1,"SOFTMAX_SUM row%0d level%0d node%0d got%h gold%h",r,g,index,dut.fp_rsp_data[lo(g)+i],sumgold(g-1,r*(128>>g)+index));nsum[g-1]++;end
    end
   end
   if(dut.sfu_rsp_valid&&dut.sfu_rsp_ready)begin int r,c;r=int'(dut.sfu_rsp_tag[10:4]);c=int'(dut.sfu_rsp_tag[3:0]);for(int i=0;i<8;i++)begin if(dut.sfu_rsp_data[i]!==gold_exp[r*128+c*8+i])$fatal(1,"SOFTMAX_EXP");nexp++;end end
   if(dut.div_rsp_valid&&dut.div_rsp_ready)begin int r,c;r=int'(dut.div_rsp_tag[10:4]);c=int'(dut.div_rsp_tag[3:0]);if(dut.div_rsp_error!=0)$fatal(1,"SOFTMAX_DIV_ERROR");for(int i=0;i<8;i++)begin if(dut.div_rsp_data[i]!==gold_prob[r*128+c*8+i])$fatal(1,"SOFTMAX_DIV row%0d chunk%0d lane%0d got%h gold%h",r,c,i,dut.div_rsp_data[i],gold_prob[r*128+c*8+i]);ndiv++;end end
   if(dut.prob_wr_valid&&dut.prob_wr_ready)begin int r,c;r=int'(dut.prob_wr_tag[10:4]);c=int'(dut.prob_wr_tag[3:0]);if(write_seen[dut.prob_wr_tag])$fatal(1,"SOFTMAX_DUPLICATE_WRITE");write_seen[dut.prob_wr_tag]=1;for(int i=0;i<8;i++)begin if(dut.prob_wr_data[i]!==gold_prob[r*128+c*8+i])$fatal(1,"SOFTMAX_PROB_WRITE");nwrite++;end end
   if(dut.prob_wr_ack_valid&&dut.prob_wr_ack_ready)begin if(ack_seen[dut.prob_wr_ack_tag])$fatal(1,"SOFTMAX_DUPLICATE_ACK");ack_seen[dut.prob_wr_ack_tag]=1;nack++;end
  end
 end
endmodule
