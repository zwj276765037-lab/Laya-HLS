`timescale 1ns/1ps
module m011_core_tb;
 logic clk,rst_n;
 logic prepare_valid;
 logic prepare_ready;
 logic [63:0] prepare_request_id;
 logic [31:0] prepare_generation,prepare_epoch;
 logic [3:0] prepare_head;
 logic prepare_av,prepare_sliding;
 logic [127:0] prepare_mask;
 logic qkv_wr_valid;
 logic qkv_wr_ready;
 logic [31:0] qkv_wr_generation;
 logic [1:0] qkv_wr_plane;
 logic [6:0] qkv_wr_token;
 logic qkv_wr_half;
 logic [31:0][31:0] qkv_wr_data;
 logic prob_wr_valid;
 logic prob_wr_ready;
 logic [31:0] prob_wr_generation;
 logic [6:0] prob_wr_query,prob_wr_keybase;
 logic [7:0][31:0] prob_wr_data;
 logic start_valid;
 logic start_ready;
 logic [63:0] start_request_id;
 logic [31:0] start_generation;
 logic abort_valid;
 logic abort_ready;
 logic [2:0] qkv_read_grant;
 logic ps_grant,g_grant,context_grant;
 logic done_valid;
 logic done_ready;
 logic [63:0] done_request_id;
 logic [31:0] done_generation;
 logic [3:0] done_head;
 logic done_av;
 logic [7:0] done_status;
 logic [31:0] done_cycles,first_score_cycle,first_context_cycle,max_feedback_cycles;
 logic error_valid;
 logic [63:0] error_rank;
 logic [4:0] error_phase;
 logic [3:0] error_tile;
 logic [31:0] error_element;
 logic [12:0] root_accepted,score_commits,partial_commits;
 logic [8:0] context_commits;
 logic [127:0][31:0] maximum;
 logic score_rd_valid;
 logic score_rd_ready;
 logic [31:0] score_rd_generation,score_rd_tag;
 logic [6:0] score_rd_query,score_rd_keybase;
 logic score_rsp_valid;
 logic score_rsp_ready;
 logic [31:0] score_rsp_tag;
 logic [7:0][31:0] score_rsp_data;
 logic result_rd_valid;
 logic result_rd_ready;
 logic [31:0] result_rd_generation,result_rd_tag;
 logic [6:0] result_rd_query;
 logic result_rd_half;
 logic result_rsp_valid;
 logic result_rsp_ready;
 logic [31:0] result_rsp_tag;
 logic [31:0][31:0] result_rsp_data;
 laya_attention_qk_av_v1 dut(.*);
 always #1.6665 clk=~clk;
 string mode="qk",data_dir;
 logic [31:0] q[0:8191],k[0:8191],v[0:8191],prob[0:16383],score[0:16383],maxgold[0:127],outgold[0:8191],maskmem[0:127];
 logic [31:0] ql0[0:1048575],ql1[0:524287],ql2[0:262143],ql3[0:131071],ql4[0:65535],ql5[0:32767],ql6[0:16383],qscale[0:16383];
 logic [31:0] avprod[0:1048575],avpartial[0:1048575];
 int sim_cycle=0,start_cycle=-1,done_seen=0,score_seen=0,result_seen=0;
 int mul_seen=0,adds_seen[0:6],scales_seen=0,qreads=0,kreads=0,vreads=0,greads=0,psreads=0,pswrites=0,ctxwrites=0;
 bit running=0,isav=0,isstalled=0,iserror=0,isabort=0,isreset=0;
 logic [31:0] error_expected[0:4];int first_bad_phase=-1,first_bad_cycle=0;
 function automatic int lo(input int g);case(g)0:return 0;1:return 128;2:return 192;3:return 224;4:return 240;5:return 248;default:return 252;endcase endfunction
 function automatic int width(input int g);case(g)0:return 32;1:return 16;2:return 8;3:return 4;4:return 2;default:return 1;endcase endfunction
 function automatic logic[31:0] qgold(input int lev,row,key,node);
  case(lev)1:return ql1[(row*128+key)*32+node];2:return ql2[(row*128+key)*16+node];3:return ql3[(row*128+key)*8+node];4:return ql4[(row*128+key)*4+node];5:return ql5[(row*128+key)*2+node];default:return ql6[row*128+key];endcase
 endfunction
 task automatic write_qkv(input int pl,tok,halfrow);
  @(negedge clk);qkv_wr_valid=1;qkv_wr_plane=2'(pl);qkv_wr_token=7'(tok);qkv_wr_half=1'(halfrow);
  for(int c=0;c<32;c++)case(pl)0:qkv_wr_data[c]=q[tok*64+halfrow*32+c];1:qkv_wr_data[c]=k[tok*64+halfrow*32+c];default:qkv_wr_data[c]=v[tok*64+halfrow*32+c];endcase
  do @(posedge clk);while(!qkv_wr_ready);
 endtask
 initial begin
  clk=0;rst_n=0;prepare_valid=0;prepare_request_id=3;prepare_generation=1;prepare_epoch=11;prepare_head=0;prepare_av=0;prepare_sliding=0;prepare_mask=0;
  qkv_wr_valid=0;qkv_wr_generation=1;qkv_wr_plane=0;qkv_wr_token=0;qkv_wr_half=0;qkv_wr_data=0;
  prob_wr_valid=0;prob_wr_generation=1;prob_wr_query=0;prob_wr_keybase=0;prob_wr_data=0;
  start_valid=0;start_request_id=3;start_generation=1;abort_valid=0;qkv_read_grant=7;ps_grant=1;g_grant=1;context_grant=1;done_ready=0;
  score_rd_valid=0;score_rd_generation=1;score_rd_tag=0;score_rd_query=0;score_rd_keybase=0;score_rsp_ready=1;
  result_rd_valid=0;result_rd_generation=1;result_rd_tag=0;result_rd_query=0;result_rd_half=0;result_rsp_ready=1;
  if(!$value$plusargs("DATA=%s",data_dir))$fatal(1,"DATA_REQUIRED");if(!$value$plusargs("MODE=%s",mode))mode="qk";
  isav=mode=="av";isstalled=mode=="stall";iserror=mode=="error";isabort=mode=="abort";isreset=mode=="reset";prepare_av=isav;prepare_sliding=mode=="sliding";
  $readmemh({data_dir,"/q.mem"},q);$readmemh({data_dir,"/k.mem"},k);$readmemh({data_dir,"/v.mem"},v);$readmemh({data_dir,"/prob.mem"},prob);$readmemh({data_dir,"/out.mem"},outgold);$readmemh({data_dir,"/mask.mem"},maskmem);
  if(prepare_sliding)begin $readmemh({data_dir,"/score_sliding.mem"},score);$readmemh({data_dir,"/max_sliding.mem"},maxgold);end
  else begin $readmemh({data_dir,"/score.mem"},score);$readmemh({data_dir,"/save_max.mem"},maxgold);end
  $readmemh({data_dir,"/qk_l0.mem"},ql0);$readmemh({data_dir,"/qk_l1.mem"},ql1);$readmemh({data_dir,"/qk_l2.mem"},ql2);$readmemh({data_dir,"/qk_l3.mem"},ql3);$readmemh({data_dir,"/qk_l4.mem"},ql4);$readmemh({data_dir,"/qk_l5.mem"},ql5);$readmemh({data_dir,"/qk_l6.mem"},ql6);$readmemh({data_dir,"/qk_scale.mem"},qscale);$readmemh({data_dir,"/av_product.mem"},avprod);$readmemh({data_dir,"/av_partial.mem"},avpartial);
  if(iserror)begin $readmemh({data_dir,"/error_q.mem"},q);$readmemh({data_dir,"/error_k.mem"},k);$readmemh({data_dir,"/error_expected.mem"},error_expected);end
  for(int r=0;r<128;r++)prepare_mask[r]=maskmem[r][0];
  for(int g=0;g<7;g++)adds_seen[g]=0;
  repeat(4)@(negedge clk);rst_n=1;
  @(negedge clk);prepare_valid=1;do @(posedge clk);while(!prepare_ready);@(negedge clk);prepare_valid=0;
  // Legal public rejection probes do not alter payload or debt.
  qkv_wr_generation=0;qkv_wr_valid=1;start_valid=1;start_generation=0;#0.1;if(qkv_wr_ready||start_ready)$fatal(1,"GENERATION_REJECT");
  @(negedge clk);qkv_wr_valid=0;start_valid=0;start_generation=1;qkv_wr_generation=1;
  for(int pl=0;pl<3;pl++)if(!isav||pl==2)for(int tok=0;tok<128;tok++)for(int h=0;h<2;h++)write_qkv(pl,tok,h);
  @(negedge clk);qkv_wr_valid=0;
  if(isav)begin
   for(int row=0;row<128;row++)for(int key=0;key<128;key+=8)begin
    @(negedge clk);prob_wr_valid=1;prob_wr_query=7'(row);prob_wr_keybase=7'(key);for(int c=0;c<8;c++)prob_wr_data[c]=prob[row*128+key+c];
    do @(posedge clk);while(!prob_wr_ready);
   end
   @(negedge clk);prob_wr_valid=0;
  end
  @(negedge clk);start_valid=1;do @(posedge clk);while(!start_ready);running=1;
  @(negedge clk);start_valid=0;
  if(isreset)begin
   wait(root_accepted>=128);@(negedge clk);
   if(dut.m_pending==0||dut.a_pending==0)$fatal(1,"RESET_NOT_IN_FLIGHT");
   $display("M011_RESET_IN_FLIGHT roots%0d mulpending%0d addpending%h",root_accepted,dut.m_pending,dut.a_pending);
   running=0;rst_n=0;repeat(3)@(negedge clk);
   if(done_valid||dut.m_pending||dut.a_pending||!dut.storage_idle)$fatal(1,"RESET_DEBT");
   rst_n=1;prepare_request_id=4;prepare_generation=2;prepare_epoch=12;qkv_wr_generation=2;start_request_id=4;start_generation=2;score_rd_generation=2;result_rd_generation=2;
   mul_seen=0;scales_seen=0;qreads=0;kreads=0;vreads=0;greads=0;psreads=0;pswrites=0;ctxwrites=0;score_seen=0;result_seen=0;done_seen=0;for(int g=0;g<7;g++)adds_seen[g]=0;
   @(negedge clk);prepare_valid=1;do @(posedge clk);while(!prepare_ready);@(negedge clk);prepare_valid=0;
   qkv_wr_valid=1;qkv_wr_generation=1;start_valid=1;start_generation=1;#0.1;if(qkv_wr_ready||start_ready)$fatal(1,"RESET_OLD_GENERATION_ACCEPT");
   @(negedge clk);qkv_wr_valid=0;qkv_wr_generation=2;start_valid=0;start_generation=2;
   for(int pl=0;pl<3;pl++)for(int tok=0;tok<128;tok++)for(int h=0;h<2;h++)write_qkv(pl,tok,h);
   @(negedge clk);qkv_wr_valid=0;start_valid=1;do @(posedge clk);while(!start_ready);running=1;@(negedge clk);start_valid=0;
  end
  if(isabort)begin
   wait(root_accepted>=128);@(negedge clk);abort_valid=1;
   @(posedge clk);if(!abort_ready)$fatal(1,"ABORT_REJECT");@(negedge clk);abort_valid=0;
   wait(done_valid);@(negedge clk);
   if(done_status!==2||root_accepted==0||root_accepted>=4096||score_commits!==root_accepted||mul_seen!=int'(root_accepted)||scales_seen!=int'(root_accepted))$fatal(1,"ABORT_NOT_DRAINED status%0d root%0d score%0d mul%0d scale%0d",done_status,root_accepted,score_commits,mul_seen,scales_seen);
   for(int g=0;g<7;g++)if(adds_seen[g]!=int'(root_accepted))$fatal(1,"ABORT_TREE_DEBT");
   repeat(3)begin @(negedge clk);if(!done_valid||done_status!==2||prepare_ready||dut.m_pending||dut.a_pending||!dut.storage_idle)$fatal(1,"ABORT_DONE_HOLD");end
   done_ready=1;repeat(4)@(negedge clk);running=0;
   if(dut.fp_owned||!prepare_ready)$fatal(1,"ABORT_LEASE_RELEASE");
   prepare_request_id=4;prepare_generation=2;prepare_epoch=12;prepare_valid=1;
   do @(posedge clk);while(!prepare_ready);@(negedge clk);prepare_valid=0;qkv_wr_generation=1;qkv_wr_valid=1;
   #0.1;if(qkv_wr_ready||start_ready)$fatal(1,"ABORT_NEW_OWNER_OLD_GENERATION");
   @(negedge clk);qkv_wr_valid=0;qkv_wr_generation=2;write_qkv(0,0,0);@(negedge clk);qkv_wr_valid=0;
   if(start_ready)$fatal(1,"ABORT_COVERAGE_INVENTED");
   $display("HARDWARE_AGENT_SIM_PASS M011_CORE modeabort accepted_roots%0d committed_scores%0d cycles%0d real_debt0 lease_release1 donehold3 new_generation2 partial_reload1",root_accepted,score_commits,done_cycles);$finish;
  end
  wait(done_valid);@(negedge clk);
  if(done_request_id!==(isreset?64'd4:64'd3)||done_generation!==(isreset?32'd2:32'd1)||done_head!==0||done_av!==isav||done_status!==(iserror?8'd1:8'd0)||error_valid!==iserror)$fatal(1,"DONE_ID_STATUS status%0d err%0d rank%h phase%0d",done_status,error_valid,error_rank,error_phase);
  if(root_accepted!==4096||mul_seen!=4096)$fatal(1,"ROOT_COUNT %0d %0d",root_accepted,mul_seen);
  if(!isav)begin
   if(score_commits!==4096||qreads!=128||kreads!=4096||scales_seen!=4096||pswrites!=4096)$fatal(1,"QK_COUNTS score%0d qr%0d kr%0d scale%0d psw%0d",score_commits,qreads,kreads,scales_seen,pswrites);
   for(int g=0;g<7;g++)if(adds_seen[g]!=4096)$fatal(1,"TREE_COUNT g%0d n%0d",g,adds_seen[g]);
   for(int row=0;row<128;row++)if(!iserror&&maximum[row]!==maxgold[row])$fatal(1,"MAX row%0d got%h gold%h",row,maximum[row],maxgold[row]);
   if(!isstalled&&(done_cycles>4352||first_score_cycle>160))$fatal(1,"QK_CYCLE done%0d first%0d",done_cycles,first_score_cycle);
  end else begin
   if(partial_commits!==4096||context_commits!==256||vreads!=128||greads!=4096||pswrites!=4096||ctxwrites!=256||adds_seen[0]!=4096)$fatal(1,"AV_COUNTS partial%0d ctx%0d vr%0d gr%0d psw%0d cw%0d add%0d",partial_commits,context_commits,vreads,greads,pswrites,ctxwrites,adds_seen[0]);
   if(done_cycles>4608||first_context_cycle>4288||max_feedback_cycles>24)$fatal(1,"AV_CYCLE done%0d first%0d feedback%0d",done_cycles,first_context_cycle,max_feedback_cycles);
  end
  $display("M011_DONE mode%s cycles%0d firstscore%0d firstcontext%0d feedback%0d roots%0d",mode,done_cycles,first_score_cycle,first_context_cycle,max_feedback_cycles,root_accepted);
  begin logic[255:0] held;held={done_request_id,done_generation,done_head,done_av,done_status,done_cycles,first_score_cycle,first_context_cycle,max_feedback_cycles};
   repeat(3)begin @(negedge clk);if(!done_valid||held!=={done_request_id,done_generation,done_head,done_av,done_status,done_cycles,first_score_cycle,first_context_cycle,max_feedback_cycles})$fatal(1,"DONE_HOLD");end
  end
  if(iserror)begin
   if(error_rank!=={error_expected[1],error_expected[0]}||error_phase!==error_expected[2][4:0]||error_tile!==error_expected[3][3:0]||error_element!==error_expected[4]||first_bad_phase!=1)$fatal(1,"CHECK_LOGICAL_ORDER rank%h phase%0d tile%0d element%0d firstphysical%0d",error_rank,error_phase,error_tile,error_element,first_bad_phase);
   $display("M011_CHECK_LOGICAL_PASS firstphysical_phase%0d cycle%0d selected_rank%h phase%0d tile%0d element%0d",first_bad_phase,first_bad_cycle,error_rank,error_phase,error_tile,error_element);
  end
  done_ready=1;repeat(4)@(negedge clk);running=0;
  if(iserror)begin
   score_rd_valid=1;#0.1;if(score_rd_ready||score_rsp_valid||dut.fp_owned||!dut.storage_idle)$fatal(1,"CHECK_ERROR_PUBLICATION");score_rd_valid=0;
   $display("HARDWARE_AGENT_SIM_PASS M011_CORE modeerror roots%0d all_tree_levels_retired1 scorecommits%0d logical_rank%h physical_phase1 selected_phase0 status1 donehold3 real_debt0 lease_release1",root_accepted,score_commits,error_rank);$finish;
  end
  if(!isav)begin
   for(int row=0;row<128;row++)for(int key=0;key<128;key+=8)begin
    score_rd_valid=1;score_rd_query=7'(row);score_rd_keybase=7'(key);score_rd_tag=32'(row*16+key/8);do @(posedge clk);while(!score_rd_ready);@(negedge clk);
   end
   score_rd_valid=0;wait(score_seen==2048);repeat(2)@(negedge clk);
  end else begin
   for(int row=0;row<128;row++)for(int h=0;h<2;h++)begin
    result_rd_valid=1;result_rd_query=7'(row);result_rd_half=1'(h);result_rd_tag=32'(row*2+h);do @(posedge clk);while(!result_rd_ready);@(negedge clk);
   end
   result_rd_valid=0;wait(result_seen==256);repeat(2)@(negedge clk);
  end
  if(dut.fp_owned||!dut.storage_idle||dut.m_pending||dut.a_pending)$fatal(1,"RELEASE_NOT_DRAINED");
  $display("HARDWARE_AGENT_SIM_PASS M011_CORE mode%s scores%0d max%0d context%0d cycles%0d firstscore%0d firstcontext%0d feedback%0d qread%0d kread%0d vread%0d gread%0d psread%0d pswrite%0d contextwrite%0d hold3 generationreject1",mode,score_seen*8,isav?0:128,result_seen*32,done_cycles,first_score_cycle,first_context_cycle,max_feedback_cycles,qreads,kreads,vreads,greads,psreads,pswrites,ctxwrites);$finish;
 end
 always @(posedge clk)begin
  sim_cycle=sim_cycle+1;if(sim_cycle>40000)$fatal(1,"CORE_TIMEOUT state%0d roots%0d score%0d partial%0d ctx%0d qr%0d kr%0d vr%0d gr%0d busy%h pending%0d",dut.state,root_accepted,score_commits,partial_commits,context_commits,qreads,kreads,vreads,greads,dut.busy,dut.m_pending);
  if(rst_n)begin
   if(start_valid&&start_ready)start_cycle=sim_cycle;
   if(isstalled&&running)begin qkv_read_grant<=sim_cycle%13==0?0:7;ps_grant<=sim_cycle%17!=0;end
   if(dut.qr_valid[0]&&dut.qr_ready[0])qreads++;
   if(dut.qr_valid[1]&&dut.qr_ready[1])kreads++;
   if(dut.qr_valid[2]&&dut.qr_ready[2])vreads++;
   if(dut.g_rd_valid&&dut.g_rd_ready)greads++;
   if(dut.ps_rd_valid&&dut.ps_rd_ready)psreads++;
   if(dut.ps_wr_rsp_valid&&dut.ps_wr_rsp_ready)pswrites++;
   if(dut.context_wr_rsp_valid&&dut.context_wr_rsp_ready)ctxwrites++;
   if(done_valid&&done_seen==0)begin done_seen=sim_cycle;if(done_cycles!==32'(sim_cycle-start_cycle))$fatal(1,"DONE_EVENT_CYCLE got%0d observed%0d",done_cycles,sim_cycle-start_cycle);end
   if(dut.m_rsp_valid&&dut.m_rsp_ready)begin
    int row,key,group;group=isav?int'(dut.m_rsp_tag[4:0]):int'(dut.m_rsp_tag[11:7]);key=isav?int'(dut.m_rsp_tag[11:5]):int'(dut.m_rsp_tag[6:0]);
    for(int r=0;r<4;r++)for(int c=0;c<64;c++)begin
     logic[31:0] gold;row=group*4+r;gold=isav?avprod[(key*128+row)*64+c]:ql0[(row*128+key)*64+c];
     if(!iserror&&dut.m_data[r*64+c]!==gold)$fatal(1,"MUL mode%s q%0d k%0d c%0d got%h gold%h",mode,row,key,c,dut.m_data[r*64+c],gold);
    end
    if(iserror&&first_bad_phase<0)for(int c=0;c<256;c++)if(dut.m_data[c][30:23]==255&&first_bad_phase<0)begin first_bad_phase=0;first_bad_cycle=sim_cycle-start_cycle;end
    mul_seen++;if(mul_seen%1024==0)$display("M011_PROGRESS mode%s mul%0d cycle%0d",mode,mul_seen,sim_cycle-start_cycle);
   end
   if(!isav)begin
    for(int g=0;g<7;g++)if(dut.a_rsp_valid[g]&&dut.a_rsp_ready[g])begin
     int group,key;group=int'(dut.a_rsp_tag[g][11:7]);key=int'(dut.a_rsp_tag[g][6:0]);
     for(int r=0;r<4;r++)for(int n=0;n<width(g);n++)begin
      logic[31:0] gold;gold=g==6?score[(group*4+r)*128+key]:qgold(g+1,group*4+r,key,n);
      if(!iserror&&dut.a_data[lo(g)+r*width(g)+n]!==gold)$fatal(1,"TREE g%0d q%0d k%0d n%0d got%h gold%h",g,group*4+r,key,n,dut.a_data[lo(g)+r*width(g)+n],gold);
     end
     if(iserror&&first_bad_phase<0)for(int c=0;c<width(g)*4;c++)if(dut.a_data[lo(g)+c][30:23]==255&&first_bad_phase<0)begin first_bad_phase=g+1;first_bad_cycle=sim_cycle-start_cycle;end
     adds_seen[g]++;
    end
    if(dut.scale_rsp_valid&&dut.scale_rsp_ready)begin
     for(int r=0;r<4;r++)if(!iserror&&dut.scale_data[r]!==qscale[(int'(dut.scale_rsp_tag[11:7])*4+r)*128+int'(dut.scale_rsp_tag[6:0])])$fatal(1,"SCALE");scales_seen++;
    end
   end else if(dut.a_rsp_valid[0]&&dut.a_rsp_ready[0])begin
    int group,key;group=int'(dut.a_rsp_tag[0][4:0]);key=int'(dut.a_rsp_tag[0][11:5]);
    for(int r=0;r<4;r++)for(int c=0;c<64;c++)if(dut.a_data[r*64+c]!==avpartial[(key*128+group*4+r)*64+c])$fatal(1,"AV_PARTIAL q%0d k%0d c%0d got%h gold%h",group*4+r,key,c,dut.a_data[r*64+c],avpartial[(key*128+group*4+r)*64+c]);adds_seen[0]++;
   end
   if(score_rsp_valid&&score_rsp_ready)begin
    for(int i=0;i<8;i++)if(score_rsp_data[i]!==score[int'(score_rsp_tag)*8+i])$fatal(1,"SCORE_READ tag%0d i%0d got%h gold%h",score_rsp_tag,i,score_rsp_data[i],score[int'(score_rsp_tag)*8+i]);score_seen++;
   end
   if(result_rsp_valid&&result_rsp_ready)begin
    for(int i=0;i<32;i++)if(result_rsp_data[i]!==outgold[int'(result_rsp_tag)*32+i])$fatal(1,"CONTEXT_READ tag%0d i%0d got%h gold%h",result_rsp_tag,i,result_rsp_data[i],outgold[int'(result_rsp_tag)*32+i]);result_seen++;
   end
  end
 end
endmodule
