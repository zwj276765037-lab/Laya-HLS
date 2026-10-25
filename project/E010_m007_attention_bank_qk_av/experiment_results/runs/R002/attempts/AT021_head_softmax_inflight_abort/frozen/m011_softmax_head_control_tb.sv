`timescale 1ns/1ps
module m011_softmax_head_control_tb;
 logic  clk=0;
 logic  rst_n=0;
 logic  prepare_valid=0;
 logic  prepare_ready;
 logic [63:0] prepare_request_id=0;
 logic [31:0] prepare_generation=0;
 logic [31:0] prepare_epoch=0;
 logic [3:0] prepare_head=0;
 logic  prepare_sliding=0;
 logic [127:0] prepare_mask=0;
 logic  qkv_wr_valid=0;
 logic  qkv_wr_ready;
 logic [31:0] qkv_wr_generation=0;
 logic [1:0] qkv_wr_plane=0;
 logic [6:0] qkv_wr_token=0;
 logic  qkv_wr_half=0;
 logic [31:0][31:0] qkv_wr_data=0;
 logic  start_valid=0;
 logic  start_ready;
 logic [63:0] start_request_id=0;
 logic [31:0] start_generation=0;
 logic  abort_valid=0;
 logic  abort_ready;
 logic [2:0] qkv_read_grant=0;
 logic  ps_grant=0;
 logic  g_grant=0;
 logic  context_grant=0;
 logic  fp_grant=0;
 logic  sfu_grant=0;
 logic  exp_grant=0;
 logic  div_grant=0;
 logic  done_valid;
 logic  done_ready=0;
 logic [63:0] done_request_id;
 logic [31:0] done_generation;
 logic [3:0] done_head;
 logic [7:0] done_status;
 logic [31:0] done_cycles;
 logic [31:0] qk_cycles;
 logic [31:0] softmax_cycles;
 logic [31:0] av_cycles;
 logic [31:0] first_score_cycle;
 logic [31:0] first_context_cycle;
 logic [31:0] max_feedback_cycles;
 logic [31:0] first_row_cycle;
 logic [31:0] max_sum_tail;
 logic [31:0] max_row_launch_gap;
 logic  error_valid;
 logic [63:0] error_rank;
 logic [4:0] error_phase;
 logic [31:0] error_element;
 logic [127:0][31:0] maximum;
 logic  result_rd_valid=0;
 logic  result_rd_ready;
 logic [31:0] result_rd_generation=0;
 logic [31:0] result_rd_tag=0;
 logic [6:0] result_rd_query=0;
 logic  result_rd_half=0;
 logic  result_rsp_valid;
 logic  result_rsp_ready=0;
 logic [31:0] result_rsp_tag;
 logic [31:0][31:0] result_rsp_data;
 laya_attention_head_v1 dut(.clk,.rst_n,.prepare_valid,.prepare_ready,.prepare_request_id,.prepare_generation,.prepare_epoch,.prepare_head,.prepare_sliding,.prepare_mask,.qkv_wr_valid,.qkv_wr_ready,.qkv_wr_generation,.qkv_wr_plane,.qkv_wr_token,.qkv_wr_half,.qkv_wr_data,.start_valid,.start_ready,.start_request_id,.start_generation,.abort_valid,.abort_ready,.qkv_read_grant,.ps_grant,.g_grant,.context_grant,.fp_grant,.sfu_grant,.exp_grant,.div_grant,.done_valid,.done_ready,.done_request_id,.done_generation,.done_head,.done_status,.done_cycles,.qk_cycles,.softmax_cycles,.av_cycles,.first_score_cycle,.first_context_cycle,.max_feedback_cycles,.first_row_cycle,.max_sum_tail,.max_row_launch_gap,.error_valid,.error_rank,.error_phase,.error_element,.maximum,.result_rd_valid,.result_rd_ready,.result_rd_generation,.result_rd_tag,.result_rd_query,.result_rd_half,.result_rsp_valid,.result_rsp_ready,.result_rsp_tag,.result_rsp_data);
 always #1.6665 clk=~clk;
 string mode="reset",data_dir,prefix;int sliding=0,cycle=0,start_cycle=-1,nstart=0,nprepare=0,nqkv=0,nscore=0,nshift=0,nexp=0,ndiv=0,nwrite=0,nack=0,ncontext=0,nqmul=0,namul=0,nscale=0,naadd=0,nphase=0,nlease=0;int nqadd[7],nsum[7];logic[2047:0]write_seen,ack_seen;bit checking=0;
 logic[31:0]q[0:8191],k[0:8191],v[0:8191],gold_score[0:16383],gold_max[0:127],gold_shift[0:16383],gold_exp[0:16383],gold_prob[0:16383],outgold[0:8191],maskmem[0:127];
 logic[31:0]ql0[0:1048575],ql1[0:524287],ql2[0:262143],ql3[0:131071],ql4[0:65535],ql5[0:32767],ql6[0:16383],qscale[0:16383],avprod[0:1048575],avpartial[0:1048575];
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

 function automatic int qlo(input int g);case(g)0:return 0;1:return 128;2:return 192;3:return 224;4:return 240;5:return 248;default:return 252;endcase endfunction
 function automatic int qwidth(input int g);case(g)0:return 32;1:return 16;2:return 8;3:return 4;4:return 2;default:return 1;endcase endfunction
 function automatic logic[31:0]qgold(input int lev,row,key,node);case(lev)1:return ql1[(row*128+key)*32+node];2:return ql2[(row*128+key)*16+node];3:return ql3[(row*128+key)*8+node];4:return ql4[(row*128+key)*4+node];5:return ql5[(row*128+key)*2+node];default:return ql6[row*128+key];endcase endfunction
 initial begin
  if(!$value$plusargs("MODE=%s",mode))mode="reset";
  if(!$value$plusargs("DATA=%s",data_dir))$fatal(1,"DATA required");if(!$value$plusargs("SLIDING=%d",sliding))sliding=0;prefix=sliding?"sliding_":"full_";
  $readmemh({data_dir,"/q.mem"},q);$readmemh({data_dir,"/k.mem"},k);$readmemh({data_dir,"/v.mem"},v);$readmemh({data_dir,"/mask.mem"},maskmem);
  $readmemh({data_dir,"/",prefix,"score.mem"},gold_score);$readmemh({data_dir,"/",prefix,"maximum.mem"},gold_max);$readmemh({data_dir,"/",prefix,"shift.mem"},gold_shift);$readmemh({data_dir,"/",prefix,"exp.mem"},gold_exp);$readmemh({data_dir,"/",prefix,"prob.mem"},gold_prob);$readmemh({data_dir,"/",prefix,"out.mem"},outgold);
  $readmemh({data_dir,"/qk_l0.mem"},ql0);$readmemh({data_dir,"/qk_l1.mem"},ql1);$readmemh({data_dir,"/qk_l2.mem"},ql2);$readmemh({data_dir,"/qk_l3.mem"},ql3);$readmemh({data_dir,"/qk_l4.mem"},ql4);$readmemh({data_dir,"/qk_l5.mem"},ql5);$readmemh({data_dir,"/qk_l6.mem"},ql6);$readmemh({data_dir,"/qk_scale.mem"},qscale);$readmemh({data_dir,"/",prefix,"av_product.mem"},avprod);$readmemh({data_dir,"/",prefix,"av_partial.mem"},avpartial);
  $readmemh({data_dir,"/",prefix,"sum_l1.mem"},gold_sum0);
  $readmemh({data_dir,"/",prefix,"sum_l2.mem"},gold_sum1);
  $readmemh({data_dir,"/",prefix,"sum_l3.mem"},gold_sum2);
  $readmemh({data_dir,"/",prefix,"sum_l4.mem"},gold_sum3);
  $readmemh({data_dir,"/",prefix,"sum_l5.mem"},gold_sum4);
  $readmemh({data_dir,"/",prefix,"sum_l6.mem"},gold_sum5);
  $readmemh({data_dir,"/",prefix,"sum_l7.mem"},gold_sum6);

  for(int i=0;i<7;i++)begin nqadd[i]=0;nsum[i]=0;end write_seen=0;ack_seen=0;
  qkv_read_grant=7;ps_grant=1;g_grant=1;context_grant=1;fp_grant=1;sfu_grant=1;exp_grant=1;div_grant=1;
  prepare_request_id=3;prepare_generation=1;prepare_epoch=200;prepare_head=0;prepare_sliding=1'(sliding);for(int r=0;r<128;r++)prepare_mask[r]=maskmem[r][0];qkv_wr_generation=1;start_request_id=3;start_generation=1;result_rd_generation=1;
  repeat(4)@(negedge clk);rst_n=1;@(negedge clk);prepare_valid=1;do @(posedge clk);while(!prepare_ready);@(negedge clk);prepare_valid=0;
  qkv_wr_generation=0;qkv_wr_valid=1;start_generation=0;start_valid=1;#0.1;if(qkv_wr_ready||start_ready)$fatal(1,"HEAD_OLD_GENERATION");@(negedge clk);qkv_wr_valid=0;start_valid=0;qkv_wr_generation=1;start_generation=1;
  for(int pl=0;pl<3;pl++)for(int r=0;r<128;r++)for(int h=0;h<2;h++)begin
   qkv_wr_valid=1;qkv_wr_plane=2'(pl);qkv_wr_token=7'(r);qkv_wr_half=1'(h);for(int c=0;c<32;c++)case(pl)0:qkv_wr_data[c]=q[r*64+h*32+c];1:qkv_wr_data[c]=k[r*64+h*32+c];default:qkv_wr_data[c]=v[r*64+h*32+c];endcase
   do @(posedge clk);while(!qkv_wr_ready);@(negedge clk);
  end
  qkv_wr_valid=0;checking=1;start_valid=1;do @(posedge clk);while(!start_ready);@(negedge clk);start_valid=0;
  if(mode=="abort")begin
   wait(dut.state==7&&dut.sfu_inflight>=16);@(negedge clk);
   if(dut.sfu_pending==0||dut.softmax.sfu_vectors==0)$fatal(1,"HEAD_ABORT_NOT_INFLIGHT");
   $display("M011_HEAD_ABORT_INFLIGHT phase%0d sfu_pending%0d sfu_inflight%0d fp_pending%h",dut.phase,dut.sfu_pending,dut.sfu_inflight,dut.add_pending);
   abort_valid=1;do @(posedge clk);while(!abort_ready);@(negedge clk);abort_valid=0;
   wait(done_valid);@(negedge clk);
   if(done_status!==2||done_request_id!==3||done_generation!==1||error_valid||dut.mul_pending||dut.add_pending||dut.sfu_pending||dut.div_pending||!dut.storage_idle||!dut.ln_idle)$fatal(1,"HEAD_ABORT_NOT_DRAINED status%0d",done_status);
   result_rd_valid=1;#0.1;if(result_rd_ready||result_rsp_valid)$fatal(1,"HEAD_ABORT_PUBLICATION");result_rd_valid=0;
   repeat(3)begin @(posedge clk);if(!done_valid||done_status!==2||prepare_ready)$fatal(1,"HEAD_ABORT_HOLD");end
   @(negedge clk);checking=0;done_ready=1;@(posedge clk);@(negedge clk);done_ready=0;wait(prepare_ready);@(negedge clk);
   prepare_request_id=4;prepare_generation=2;prepare_epoch=201;prepare_valid=1;do @(posedge clk);while(!prepare_ready);@(negedge clk);prepare_valid=0;
   qkv_wr_valid=1;qkv_wr_generation=1;start_valid=1;start_generation=1;#0.1;if(qkv_wr_ready||start_ready)$fatal(1,"HEAD_ABORT_OLD_GEN");
   @(negedge clk);qkv_wr_generation=2;start_generation=2;start_request_id=4;start_valid=0;qkv_wr_plane=0;qkv_wr_token=0;qkv_wr_half=0;for(int c=0;c<32;c++)qkv_wr_data[c]=q[c];
   do @(posedge clk);while(!qkv_wr_ready);@(negedge clk);qkv_wr_valid=0;#0.1;if(start_ready)$fatal(1,"HEAD_ABORT_INVENTED_LOAD_COVERAGE");
   $display("HARDWARE_AGENT_SIM_PASS M011_HEAD_CONTROL modeabort actual_phase3_SFU_inflight1 abort_drains_FP_SFU_storage_div1 status2 donehold3 no_result_publication1 release_debt0 newgen2_old_gen_reject1 partial_reload_not_complete1");$finish;
  end else begin
   wait(dut.q_root_accepted>=128);@(negedge clk);
   if(dut.mul_pending==0||dut.add_pending==0)$fatal(1,"HEAD_RESET_NOT_INFLIGHT");
   $display("M011_HEAD_RESET_INFLIGHT phase%0d roots%0d mulpending%0d addpending%h",dut.phase,dut.q_root_accepted,dut.mul_pending,dut.add_pending);
   checking=0;rst_n=0;repeat(3)@(negedge clk);
   if(done_valid||dut.mul_pending||dut.add_pending||dut.sfu_pending||dut.div_pending||!dut.storage_idle||!dut.ln_idle||dut.fp_owned||dut.sfu_owned||dut.div_owned)$fatal(1,"HEAD_RESET_DEBT");
   rst_n=1;nscore=0;nshift=0;nexp=0;ndiv=0;nwrite=0;nack=0;ncontext=0;nqmul=0;namul=0;nscale=0;naadd=0;nphase=0;nlease=0;nstart=0;nprepare=0;nqkv=0;write_seen=0;ack_seen=0;for(int i=0;i<7;i++)begin nqadd[i]=0;nsum[i]=0;end
   prepare_request_id=4;prepare_generation=2;prepare_epoch=201;qkv_wr_generation=2;start_request_id=4;start_generation=2;result_rd_generation=2;
   @(negedge clk);prepare_valid=1;do @(posedge clk);while(!prepare_ready);@(negedge clk);prepare_valid=0;
   qkv_wr_generation=1;qkv_wr_valid=1;start_generation=1;start_valid=1;#0.1;if(qkv_wr_ready||start_ready)$fatal(1,"HEAD_RESET_OLD_GENERATION");@(negedge clk);qkv_wr_valid=0;start_valid=0;qkv_wr_generation=2;start_generation=2;
   for(int pl=0;pl<3;pl++)for(int r=0;r<128;r++)for(int h=0;h<2;h++)begin
    qkv_wr_valid=1;qkv_wr_plane=2'(pl);qkv_wr_token=7'(r);qkv_wr_half=1'(h);for(int c=0;c<32;c++)case(pl)0:qkv_wr_data[c]=q[r*64+h*32+c];1:qkv_wr_data[c]=k[r*64+h*32+c];default:qkv_wr_data[c]=v[r*64+h*32+c];endcase
    do @(posedge clk);while(!qkv_wr_ready);@(negedge clk);
   end
   qkv_wr_valid=0;checking=1;start_valid=1;do @(posedge clk);while(!start_ready);@(negedge clk);start_valid=0;
  end
  wait(done_valid);@(negedge clk);
  $display("M011_HEAD_RESULT sliding%0d status%0d total%0d qk%0d sm%0d av%0d firstscore%0d firstrow%0d tail%0d rowgap%0d firstcontext%0d feedback%0d",sliding,done_status,done_cycles,qk_cycles,softmax_cycles,av_cycles,first_score_cycle,first_row_cycle,max_sum_tail,max_row_launch_gap,first_context_cycle,max_feedback_cycles);
  if(done_status!==0||error_valid||done_request_id!==4||done_generation!==2||done_head!==0)$fatal(1,"HEAD_DONE_STATUS phase%0d rank%h state%0d qstate%0d protocol%0d/%0d",error_phase,error_rank,dut.state,dut.qkav.state,dut.qkav.protocol_bad,dut.softmax.protocol_bad);
  if(done_cycles>11648||qk_cycles>4352||softmax_cycles>2688||av_cycles>4608||first_score_cycle>160||first_row_cycle>544||max_sum_tail>56||max_row_launch_gap>16||first_context_cycle>4288||max_feedback_cycles>24)$fatal(1,"HEAD_CYCLE_BOUND");
  if(nprepare!=1||nstart!=1||nqkv!=768||nphase!=3||nlease!=3||nscore!=16384||nshift!=16384||nexp!=16384||ndiv!=16384||nwrite!=16384||nack!=2048||ncontext!=8192||nqmul!=4096||namul!=4096||nscale!=4096||naadd!=4096||write_seen!='1||ack_seen!='1)$fatal(1,"HEAD_COVERAGE prep%0d start%0d qkv%0d phase%0d lease%0d score%0d shift%0d exp%0d div%0d wr%0d ack%0d ctx%0d qm%0d am%0d scale%0d aa%0d",nprepare,nstart,nqkv,nphase,nlease,nscore,nshift,nexp,ndiv,nwrite,nack,ncontext,nqmul,namul,nscale,naadd);
  for(int g=0;g<7;g++)if(nsum[g]!=128*(64>>g)||nqadd[g]!=4096)$fatal(1,"HEAD_TREE_COUNTS g%0d sm%0d qk%0d",g,nsum[g],nqadd[g]);
  for(int r=0;r<128;r++)if(maximum[r]!==gold_max[r])$fatal(1,"HEAD_MAX r%0d",r);
  repeat(3)begin @(posedge clk);if(!done_valid||done_status!=0)$fatal(1,"HEAD_DONE_HOLD");end @(negedge clk);
  for(int r=0;r<128;r++)for(int h=0;h<2;h++)begin
   result_rd_valid=1;result_rd_query=7'(r);result_rd_half=1'(h);result_rd_tag=32'(r*2+h+4096);result_rsp_ready=0;
   do @(posedge clk);while(!result_rd_ready);@(negedge clk);result_rd_valid=0;wait(result_rsp_valid);@(negedge clk);
   if(result_rsp_tag!==32'(r*2+h+4096))$fatal(1,"HEAD_RESULT_TAG");for(int c=0;c<32;c++)if(result_rsp_data[c]!==outgold[r*64+h*32+c])$fatal(1,"HEAD_RESULT_BANK r%0d h%0d c%0d got%h gold%h",r,h,c,result_rsp_data[c],outgold[r*64+h*32+c]);
   if(r==127&&h==1)begin done_ready=1;@(posedge clk);@(negedge clk);done_ready=0;repeat(3)begin @(posedge clk);if(!result_rsp_valid||prepare_ready||!dut.fp_owned||result_rsp_tag!==32'(r*2+h+4096))$fatal(1,"HEAD_HELD_RELEASE");for(int c=0;c<32;c++)if(result_rsp_data[c]!==outgold[r*64+h*32+c])$fatal(1,"HEAD_HELD_DATA");end @(negedge clk);end
   result_rsp_ready=1;@(posedge clk);@(negedge clk);result_rsp_ready=0;
  end
  checking=0;wait(prepare_ready);@(negedge clk);
  if(dut.fp_owned||dut.sfu_owned||dut.div_owned||!dut.storage_idle||!dut.ln_idle)$fatal(1,"HEAD_RELEASE_DEBT");
  $display("HARDWARE_AGENT_SIM_PASS M011_HEAD_CONTROL modereset generation2_full_reload_after_inflight_reset1 sliding%0d one_command1 actualQKV768 no_score_prob_injection1 score16384 max128 prob16384 context8192 allQKmul_tree_scale1 allSoftmaxShiftExpTreeDiv1 allAVmul_partial1 real_commit1 full_context_bankread1 donehold3 done_consumed_readheld3 debt0 total%0d qk%0d sm%0d av%0d",sliding,done_cycles,qk_cycles,softmax_cycles,av_cycles);$finish;
 end
 always @(posedge clk)begin
  cycle=cycle+1;if(cycle>30000)$fatal(1,"HEAD_TIMEOUT state%0d qstate%0d smstate%0d qroot%0d qscore%0d qpartial%0d smrow%0d/%0d pending%0d/%h/%0d/%0d",dut.state,dut.qkav.state,dut.softmax.state,dut.q_root_accepted,dut.q_score_commits,dut.q_partial_commits,dut.softmax.read_row,dut.softmax.norm_row,dut.mul_pending,dut.add_pending,dut.sfu_pending,dut.div_pending);
  if(rst_n)begin
   if(prepare_valid&&prepare_ready)nprepare++;if(qkv_wr_valid&&qkv_wr_ready)nqkv++;if(start_valid&&start_ready)begin nstart++;start_cycle=cycle;end
   if(dut.p_st_bind_valid&&dut.p_st_bind_ready)begin
    if(dut.p_st_bind_phase!==3'(nphase+2)||dut.mul_pending||dut.add_pending||dut.sfu_pending||dut.div_pending||!dut.storage_idle)$fatal(1,"HEAD_PHASE_HANDOFF phase%0d index%0d",dut.p_st_bind_phase,nphase);
    if(nphase==2&&dut.sm_probability_commits!=2048)$fatal(1,"HEAD_AV_BEFORE_PROB_COMMIT");nphase++;
   end
   if(dut.p_fp_lease_valid&&dut.p_fp_lease_ready)begin if(dut.p_fp_lease_phase!==3'(nlease+2))$fatal(1,"HEAD_FP_LEASE_PHASE");nlease++;end
  end
  if(rst_n&&checking)begin
   if(dut.state==2&&dut.q_done_valid)$display("M011_HEAD_PHASE_PASS QK status%0d cycles%0d score%0d",dut.q_done_status,dut.q_done_cycles,nscore);
   if(dut.state==7&&dut.sm_done_valid)$display("M011_HEAD_PHASE_PASS SM status%0d cycles%0d prob%0d",dut.sm_done_status,dut.sm_done_cycles,nwrite);
   if(dut.fp_fault||dut.sfu_fault||dut.div_fault||dut.sfu_reject||dut.div_reject)$fatal(1,"HEAD_RESOURCE_FAULT");
   if(dut.p_fp_mul_rsp_valid&&dut.p_fp_mul_rsp_ready)begin int group,key;group=dut.phase==2?int'(dut.p_fp_mul_rsp_tag[11:7]):int'(dut.p_fp_mul_rsp_tag[4:0]);key=dut.phase==2?int'(dut.p_fp_mul_rsp_tag[6:0]):int'(dut.p_fp_mul_rsp_tag[11:5]);
    for(int r=0;r<4;r++)for(int c=0;c<64;c++)begin logic[31:0]gold;gold=dut.phase==2?ql0[((group*4+r)*128+key)*64+c]:avprod[(key*128+group*4+r)*64+c];if(dut.p_fp_mul_rsp_data[r*64+c]!==gold)$fatal(1,"HEAD_MUL phase%0d r%0d k%0d c%0d got%h gold%h",dut.phase,group*4+r,key,c,dut.p_fp_mul_rsp_data[r*64+c],gold);end
    if(dut.phase==2)nqmul++;else if(dut.phase==4)namul++;else $fatal(1,"HEAD_MUL_PHASE");
   end
   if(dut.phase==2)begin
    for(int g=0;g<7;g++)if(dut.p_fp_add_rsp_valid[g]&&dut.p_fp_add_rsp_ready[g])begin int group,key;group=int'(dut.p_fp_add_rsp_tag[g][11:7]);key=int'(dut.p_fp_add_rsp_tag[g][6:0]);
     for(int r=0;r<4;r++)for(int n=0;n<qwidth(g);n++)begin logic[31:0]gold;gold=g==6?gold_score[(group*4+r)*128+key]:qgold(g+1,group*4+r,key,n);if(dut.p_fp_add_rsp_data[qlo(g)+r*qwidth(g)+n]!==gold)$fatal(1,"HEAD_QK_TREE row%0d key%0d lev%0d node%0d",group*4+r,key,g,n);end nqadd[g]++;
    end
    if(dut.q_res_scale_rsp_valid&&dut.q_res_scale_rsp_ready)begin int group,key;group=int'(dut.q_res_scale_rsp_tag[11:7]);key=int'(dut.q_res_scale_rsp_tag[6:0]);for(int r=0;r<4;r++)if(dut.q_res_scale_data[r]!==qscale[(group*4+r)*128+key])$fatal(1,"HEAD_SCALE");nscale++;end
    if(dut.p_st_ps_wr_valid&&dut.p_st_ps_wr_ready)begin int group,key;group=int'(dut.p_st_ps_wr_tag[11:7]);key=int'(dut.p_st_ps_wr_tag[6:0]);for(int r=0;r<4;r++)begin int row,b;row=group*4+r;b=dut.sb(row,key);if(dut.p_st_ps_wr_data[b]!==gold_score[row*128+key])$fatal(1,"HEAD_SCORE_WRITE");nscore++;end end
   end
   if(dut.phase==4&&dut.p_fp_add_rsp_valid[0]&&dut.p_fp_add_rsp_ready[0])begin int group,key;group=int'(dut.p_fp_add_rsp_tag[0][4:0]);key=int'(dut.p_fp_add_rsp_tag[0][11:5]);for(int r=0;r<4;r++)for(int c=0;c<64;c++)if(dut.p_fp_add_rsp_data[r*64+c]!==avpartial[(key*128+group*4+r)*64+c])$fatal(1,"HEAD_AV_PARTIAL row%0d key%0d c%0d",group*4+r,key,c);naadd++;end
   if(dut.p_st_context_wr_valid&&dut.p_st_context_wr_ready)for(int c=0;c<64;c++)if(dut.p_st_context_wr_mask[c])begin int r;r=int'(dut.p_st_context_wr_addr[c][6:0]);if(dut.p_st_context_wr_data[c]!==outgold[r*64+c])$fatal(1,"HEAD_CONTEXT_COMMIT r%0d c%0d",r,c);ncontext++;end
   if(dut.sm_fp_rsp_valid&&dut.sm_fp_rsp_ready)for(int g=0;g<8;g++)if(tv(dut.sm_fp_rsp_tag,g))begin
    int r,node,index;r=tr(dut.sm_fp_rsp_tag,g);node=ti(dut.sm_fp_rsp_tag,g);
    for(int i=0;i<nn(g);i++)begin
     index=g<4?node*nn(g)+i:node;
     if(g==0)begin if(dut.sm_fp_rsp_data[i]!==gold_shift[r*128+index])$fatal(1,"SOFTMAX_SHIFT row%0d node%0d got%h gold%h",r,index,dut.sm_fp_rsp_data[i],gold_shift[r*128+index]);nshift++;end
     else begin if(dut.sm_fp_rsp_data[lo(g)+i]!==sumgold(g-1,r*(128>>g)+index))$fatal(1,"SOFTMAX_SUM row%0d level%0d node%0d got%h gold%h",r,g,index,dut.sm_fp_rsp_data[lo(g)+i],sumgold(g-1,r*(128>>g)+index));nsum[g-1]++;end
    end
   end
   if(dut.sm_sfu_rsp_valid&&dut.sm_sfu_rsp_ready)begin int r,c;r=int'(dut.sm_sfu_rsp_tag[10:4]);c=int'(dut.sm_sfu_rsp_tag[3:0]);for(int i=0;i<8;i++)begin if(dut.sm_sfu_rsp_data[i]!==gold_exp[r*128+c*8+i])$fatal(1,"SOFTMAX_EXP");nexp++;end end
   if(dut.sm_div_rsp_valid&&dut.sm_div_rsp_ready)begin int r,c;r=int'(dut.sm_div_rsp_tag[10:4]);c=int'(dut.sm_div_rsp_tag[3:0]);if(dut.sm_div_rsp_error!=0)$fatal(1,"SOFTMAX_DIV_ERROR");for(int i=0;i<8;i++)begin if(dut.sm_div_rsp_data[i]!==gold_prob[r*128+c*8+i])$fatal(1,"SOFTMAX_DIV row%0d chunk%0d lane%0d got%h gold%h",r,c,i,dut.sm_div_rsp_data[i],gold_prob[r*128+c*8+i]);ndiv++;end end
   if(dut.sm_prob_wr_valid&&dut.sm_prob_wr_ready)begin int r,c;r=int'(dut.sm_prob_wr_tag[10:4]);c=int'(dut.sm_prob_wr_tag[3:0]);if(write_seen[dut.sm_prob_wr_tag])$fatal(1,"SOFTMAX_DUPLICATE_WRITE");write_seen[dut.sm_prob_wr_tag]=1;for(int i=0;i<8;i++)begin if(dut.sm_prob_wr_data[i]!==gold_prob[r*128+c*8+i])$fatal(1,"SOFTMAX_PROB_WRITE");nwrite++;end end
   if(dut.sm_prob_wr_ack_valid&&dut.sm_prob_wr_ack_ready)begin if(ack_seen[dut.sm_prob_wr_ack_tag])$fatal(1,"SOFTMAX_DUPLICATE_ACK");ack_seen[dut.sm_prob_wr_ack_tag]=1;nack++;end
  end
 end
endmodule
