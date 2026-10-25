`timescale 1ns/1ps
`define READ_ORIGINAL_BIN(PATH,ARR) begin integer fd,nb;fd=$fopen(PATH,"rb");if(fd==0)$fatal(1,"original binary missing %s",PATH);nb=$fread(ARR,fd);if($fgetc(fd)!=-1)$fatal(1,"original binary trailing bytes %s",PATH);$fclose(fd);if(nb!=$size(ARR)*4)$fatal(1,"original binary size %s bytes%0d",PATH,nb);for(int bi=0;bi<$size(ARR);bi++)ARR[bi]={ARR[bi][7:0],ARR[bi][15:8],ARR[bi][23:16],ARR[bi][31:24]};end
module m011_layer_integration_tb;
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
 initial clk=0;always #1.6665 clk=~clk;
 laya_attention_layer_v1 dut(.*);
 string data,which,prefix;int prep_only=0;int pilot=0,casekind=0,cycle=0,nprepare=0,nstart=0,nqkv=0,nheads=0,nrope=0,nscore=0,nprob=0,ncontext=0,nread=0;bit checking=0,selected=0;int av_retired_progress=0;
 int hs,hp,hc,hqm,ham,hscale,haadd,hshift,hexp,hdiv,hack;int hqadd[7],hsum[7];
 logic[31:0]pre[0:393215],postgold[0:393215],allscore[0:262143],allmax[0:2047],allprob[0:262143],allcontext[0:131071],maskmem[0:127],cf[0:8191],sf[0:8191],cs[0:8191],ss[0:8191];
 logic[31:0]ql0[0:1048575],ql1[0:524287],ql2[0:262143],ql3[0:131071],ql4[0:65535],ql5[0:32767],ql6[0:16383],qscale[0:16383],avprod[0:1048575],avpartial[0:1048575],gold_shift[0:16383],gold_exp[0:16383];
 logic[31:0]gold_sum0[0:8191],gold_sum1[0:4095],gold_sum2[0:2047],gold_sum3[0:1023],gold_sum4[0:511],gold_sum5[0:255],gold_sum6[0:127];
 function automatic logic[31:0]sumgold(input int g,index);case(g)0:return gold_sum0[index];1:return gold_sum1[index];2:return gold_sum2[index];3:return gold_sum3[index];4:return gold_sum4[index];5:return gold_sum5[index];default:return gold_sum6[index];endcase endfunction
 function automatic bit tv(input logic[95:0]t,input int g);case(g)0:return t[11];1:return t[23];2:return t[35];3:return t[47];4:return t[58];5:return t[68];6:return t[77];default:return t[85];endcase endfunction
 function automatic int tr(input logic[95:0]t,input int g);case(g)0:return int'(t[10:4]);1:return int'(t[22:16]);2:return int'(t[34:28]);3:return int'(t[46:40]);4:return int'(t[57:51]);5:return int'(t[67:61]);6:return int'(t[76:70]);default:return int'(t[84:78]);endcase endfunction
 function automatic int ti(input logic[95:0]t,input int g);case(g)0:return int'(t[3:0]);1:return int'(t[15:12]);2:return int'(t[27:24]);3:return int'(t[39:36]);4:return int'(t[50:48]);5:return int'(t[60:59]);6:return int'(t[69]);default:return 0;endcase endfunction
 function automatic int lo(input int g);case(g)0:return 0;1:return 8;2:return 12;3:return 14;4:return 15;5:return 16;6:return 17;default:return 18;endcase endfunction
 function automatic int nn(input int g);case(g)0:return 8;1:return 4;2:return 2;default:return 1;endcase endfunction

 function automatic int qlo(input int g);case(g)0:return 0;1:return 128;2:return 192;3:return 224;4:return 240;5:return 248;default:return 252;endcase endfunction
 function automatic int qwidth(input int g);case(g)0:return 32;1:return 16;2:return 8;3:return 4;4:return 2;default:return 1;endcase endfunction
 function automatic logic[31:0]qgold(input int lev,row,key,node);case(lev)1:return ql1[(row*128+key)*32+node];2:return ql2[(row*128+key)*16+node];3:return ql3[(row*128+key)*8+node];4:return ql4[(row*128+key)*4+node];5:return ql5[(row*128+key)*2+node];default:return ql6[row*128+key];endcase endfunction

 function automatic int qi(input int t,p,h,c);return ((t*3+p)*16+h)*64+c;endfunction
 function automatic logic[31:0]coeffgold(input int t,r,c);case(t)0:return cf[r*64+c];1:return sf[r*64+c];2:return cs[r*64+c];3:return ss[r*64+c];endcase endfunction
 task automatic step;@(posedge clk);#0.1;endtask
 task automatic selected_gold(input int h);
  prefix=$sformatf("%s/%s_h%02d_",data,which,h);
  `READ_ORIGINAL_BIN(({prefix,"qk_l0.bin"}),ql0);`READ_ORIGINAL_BIN(({prefix,"qk_l1.bin"}),ql1);`READ_ORIGINAL_BIN(({prefix,"qk_l2.bin"}),ql2);`READ_ORIGINAL_BIN(({prefix,"qk_l3.bin"}),ql3);`READ_ORIGINAL_BIN(({prefix,"qk_l4.bin"}),ql4);`READ_ORIGINAL_BIN(({prefix,"qk_l5.bin"}),ql5);`READ_ORIGINAL_BIN(({prefix,"qk_l6.bin"}),ql6);`READ_ORIGINAL_BIN(({prefix,"qk_scale.bin"}),qscale);`READ_ORIGINAL_BIN(({prefix,"av_product.bin"}),avprod);`READ_ORIGINAL_BIN(({prefix,"av_partial.bin"}),avpartial);`READ_ORIGINAL_BIN(({prefix,"shift.bin"}),gold_shift);`READ_ORIGINAL_BIN(({prefix,"exp.bin"}),gold_exp);
  `READ_ORIGINAL_BIN(({prefix,"sum_l1.bin"}),gold_sum0);`READ_ORIGINAL_BIN(({prefix,"sum_l2.bin"}),gold_sum1);`READ_ORIGINAL_BIN(({prefix,"sum_l3.bin"}),gold_sum2);`READ_ORIGINAL_BIN(({prefix,"sum_l4.bin"}),gold_sum3);`READ_ORIGINAL_BIN(({prefix,"sum_l5.bin"}),gold_sum4);`READ_ORIGINAL_BIN(({prefix,"sum_l6.bin"}),gold_sum5);`READ_ORIGINAL_BIN(({prefix,"sum_l7.bin"}),gold_sum6);
 endtask
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
  result_discard_valid=0;result_discard_generation=8;
  if(!$value$plusargs("DATA=%s",data))$fatal(1,"DATA required");if(!$value$plusargs("CASE=%s",which))which="encoder0";if(!$value$plusargs("PILOT_HEADS=%d",pilot))pilot=0;if(!$value$plusargs("PREP_ONLY=%d",prep_only))prep_only=0;casekind=which=="decision0"?2:which=="encoder1"?1:0;
  `READ_ORIGINAL_BIN(({data,"/",which,"_pre_qkv.bin"}),pre);`READ_ORIGINAL_BIN(({data,"/",which,"_post_qkv.bin"}),postgold);`READ_ORIGINAL_BIN(({data,"/",which,"_score.bin"}),allscore);`READ_ORIGINAL_BIN(({data,"/",which,"_maximum.bin"}),allmax);`READ_ORIGINAL_BIN(({data,"/",which,"_prob.bin"}),allprob);`READ_ORIGINAL_BIN(({data,"/",which,"_context.bin"}),allcontext);$readmemh({data,"/mask.mem"},maskmem);
  `READ_ORIGINAL_BIN(({data,"/cos_full.bin"}),cf);`READ_ORIGINAL_BIN(({data,"/sin_full.bin"}),sf);`READ_ORIGINAL_BIN(({data,"/cos_slide.bin"}),cs);`READ_ORIGINAL_BIN(({data,"/sin_slide.bin"}),ss);
  qkv_read_grant=7;ps_grant=1;g_grant=1;context_grant=1;fp_grant=1;sfu_grant=1;exp_grant=1;div_grant=1;rope_write_grant=1;
  prepare_request_id=77;prepare_generation=8;prepare_epoch=9;prepare_model_id=128'h6eb6ef58bc4f99bd9db40381604108af;prepare_numeric_id=128'haeb13e7937d29fe6a2c68c407249f294;prepare_table_key=128'hb1fdc9ca482c0210982c7245cc50c965;prepare_kind=casekind;prepare_layer=casekind==1?1:0;for(int r=0;r<128;r++)prepare_mask[r]=maskmem[r][0];
  qkv_wr_request_id=77;qkv_wr_generation=8;qkv_wr_epoch=9;start_request_id=77;start_generation=8;result_rd_generation=8;
  coeff_bind_model_id=128'h6eb6ef58bc4f99bd9db40381604108af;coeff_bind_numeric_id=128'haeb13e7937d29fe6a2c68c407249f294;coeff_bind_table_key=128'hb1fdc9ca482c0210982c7245cc50c965;coeff_wr_model_id=128'h6eb6ef58bc4f99bd9db40381604108af;coeff_wr_numeric_id=128'haeb13e7937d29fe6a2c68c407249f294;coeff_wr_table_key=128'hb1fdc9ca482c0210982c7245cc50c965;
  repeat(4)step();@(negedge clk);rst_n=1;coeff_bind_valid=1;#0.1;if(!coeff_bind_ready)$fatal(1,"cache bind");step();@(negedge clk);coeff_bind_valid=0;
  for(int t=0;t<4;t++)for(int r=0;r<128;r++)for(int half=0;half<2;half++)begin
   coeff_wr_valid=1;coeff_wr_table=t;coeff_wr_row=r;coeff_wr_half=half;for(int c=0;c<32;c++)coeff_wr_data[c]=coeffgold(t,r,half*32+c);#0.1;if(!coeff_wr_ready||coeff_wr_reject_valid)$fatal(1,"coeff loader");step();@(negedge clk);
  end coeff_wr_valid=0;
  prepare_valid=1;prepare_kind=3;#0.1;if(prepare_ready||!reject_valid||reject_code!=6)$fatal(1,"illegal kind accepted");step();@(negedge clk);prepare_kind=0;prepare_layer=1;#0.1;if(prepare_ready||!reject_valid)$fatal(1,"full index mismatch accepted");step();@(negedge clk);prepare_kind=1;prepare_layer=0;#0.1;if(prepare_ready||!reject_valid)$fatal(1,"slide index mismatch accepted");step();@(negedge clk);prepare_kind=2;prepare_layer=2;#0.1;if(prepare_ready||!reject_valid)$fatal(1,"Decision index bounds accepted");step();@(negedge clk);prepare_kind=casekind;prepare_layer=casekind==1?1:0;#0.1;if(!prepare_ready)$fatal(1,"layer prepare");step();@(negedge clk);prepare_valid=0;
  qkv_wr_valid=1;qkv_wr_generation=7;start_valid=1;start_generation=7;#0.1;if(qkv_wr_ready||start_ready||!reject_valid)$fatal(1,"old identity accepted");step();@(negedge clk);qkv_wr_valid=0;start_valid=0;qkv_wr_generation=8;start_generation=8;
  for(int t=0;t<128;t++)for(int p=0;p<3;p++)for(int h=0;h<16;h++)for(int half=0;half<2;half++)begin
   qkv_wr_valid=1;qkv_wr_plane=p;qkv_wr_head=h;qkv_wr_token=t;qkv_wr_half=half;for(int c=0;c<32;c++)qkv_wr_data[c]=pre[qi(t,p,h,half*32+c)];#0.1;if(!qkv_wr_ready)$fatal(1,"layer public QKV load");if(nqkv<12287&&start_ready)$fatal(1,"partial QKV start");step();@(negedge clk);
  end qkv_wr_valid=0;checking=1;start_valid=1;#0.1;if(!start_ready)$fatal(1,"complete start not ready");step();@(negedge clk);start_valid=0;
  while(!done_valid)step();if(done_status!=0||error_valid||head_completed!==16'hffff||head_context_valid!==16'hffff)$fatal(1,"layer done status%0d tuple%h maps%h/%h",done_status,error_tuple,head_completed,head_context_valid);
  if(nheads!=16||nprepare!=1||nstart!=1||nqkv!=12288||nscore!=262144||nprob!=262144||ncontext!=131072||nrope!=(casekind==2?0:2048))$fatal(1,"layer final coverage heads%0d score%0d prob%0d context%0d rope%0d",nheads,nscore,nprob,ncontext,nrope);
  if(done_cycles>(casekind==2?186368:188544)||rope_cycles>(casekind==2?0:2176))$fatal(1,"layer cycle bound total%0d rope%0d",done_cycles,rope_cycles);
  for(int s=0;s<26;s++)begin if(casekind==2&&s>=1&&s<=10)begin if(check_unreachable[s]!==16'hffff||check_completed[s]!=0)$fatal(1,"Decision RoPE stage classification");end else if(check_completed[s]!==16'hffff)$fatal(1,"missing actual Check stage%0d",s);end
  if(av_check_completed!={2048{1'b1}}||av_check_unreachable!=0||av_check_dominated!=0)$fatal(1,"AV actual key/head map");
  $display("M011_LAYER_COMPLETE case=%s cycles=%0d rope=%0d all16head=1 score262144 prob262144 context131072",which,done_cycles,rope_cycles);
  repeat(3)begin step();if(!done_valid||prepare_ready)$fatal(1,"layer DONE hold");end
  // The first response stays held while DONE is consumed. All remaining
  // context words then retire at one32F32 response per cycle with no gaps.
  @(negedge clk);result_rd_valid=1;result_rd_head=0;result_rd_query=0;result_rd_half=0;result_rd_tag=0;result_rsp_ready=0;#0.1;if(!result_rd_ready)$fatal(1,"first native read ready");step();@(negedge clk);result_rd_valid=0;
  if(!result_rsp_valid||result_rsp_tag!=0)$fatal(1,"first native response");done_ready=1;step();@(negedge clk);done_ready=0;
  repeat(3)begin step();if(!result_rsp_valid||prepare_ready||done_valid||result_rsp_tag!=0)$fatal(1,"DONE consumed/unread context retain");end
  for(int id=1;id<4096;id++)begin
   @(negedge clk);result_rd_valid=1;result_rd_head=4'(id/256);result_rd_query=7'((id%256)/2);result_rd_half=1'(id%2);result_rd_tag=id;result_rsp_ready=1;#0.1;if(!result_rd_ready)$fatal(1,"native II1 read stall id%0d",id);step();
  end
  @(negedge clk);result_rd_valid=0;result_rsp_ready=0;if(!result_rsp_valid||result_rsp_tag!=4095)$fatal(1,"tail native response");
  repeat(3)begin step();if(!result_rsp_valid||prepare_ready||result_rsp_tag!=4095)$fatal(1,"last held response/rebind");for(int c=0;c<32;c++)if(result_rsp_data[c]!==allcontext[131040+c])$fatal(1,"tail held data");end
  @(negedge clk);result_rsp_ready=1;step();@(negedge clk);result_rsp_ready=0;
  checking=0;while(!prepare_ready)step();if(nread!=131072||!dut.real_idle||context_release_cycles<=producer_done_cycles||context_release_cycles>(casekind==2?186368:188544)||context_discarded)$fatal(1,"final read debt");
  $display("M011_LAYER_CONTEXT_RELEASE producer_done=%0d context_release=%0d output_consumption=%0d",producer_done_cycles,context_release_cycles,context_release_cycles-producer_done_cycles);
  $display("HARDWARE_AGENT_SIM_PASS M011_LAYER_INTEGRATION case=%s one_prepare=1 public_QKV32=12288 one_start=1 heads=16 original_score=262144 original_prob=262144 original_context=131072 native_context_read=131072 selected_head0_15_all_intermediates=1 held_done_response=1 unread_context_retained_after_DONE=1",which);$finish;
 end
 always@(posedge clk)begin
  cycle++;if(cycle>40000000)$fatal(1,"cycle guard");
  if(rst_n)begin
   if(prepare_valid&&prepare_ready)nprepare++;if(start_valid&&start_ready)nstart++;if(qkv_wr_valid&&qkv_wr_ready)begin nqkv++;if(nqkv%4096==0)$display("M011_LAYER_PROGRESS stage=PUBLIC_QKV32 accepted=%0d cycle=%0d",nqkv,cycle);end
   if(dut.h_prepare_valid&&dut.h_prepare_ready)begin selected=active_head==0||active_head==15;if(selected)selected_gold(active_head);end
   if(dut.h_start_valid&&dut.h_start_ready)begin
    av_retired_progress=0;hs=0;hp=0;hc=0;hqm=0;ham=0;hscale=0;haadd=0;hshift=0;hexp=0;hdiv=0;hack=0;for(int g=0;g<7;g++)begin hqadd[g]=0;hsum[g]=0;end
    $display("M011_LAYER_HEAD_BEGIN head=%0d cycle=%0d",active_head,cycle);
    if(prep_only)begin if(nqkv!=12288||nrope!=(casekind==2?0:2048))$fatal(1,"prep scope coverage");$display("HARDWARE_AGENT_SIM_PASS M011_LAYER_PREP_PILOT case=%s public_QKV32=12288 original_atomic_RoPE=%0d actual_first_head_start=1 no_QK_completion_claim=1",which,nrope);$finish;end
   end
  end
  if(rst_n&&checking)begin
   if(result_rsp_valid&&result_rsp_ready)begin
    int id,h,r,half;id=int'(result_rsp_tag);h=id/256;r=(id%256)/2;half=id%2;if(id!=nread/32)$fatal(1,"native output order/duplicate id%0d expected%0d",id,nread/32);
    for(int c=0;c<32;c++)begin if(result_rsp_data[c]!==allcontext[(h*128+r)*64+half*32+c])$fatal(1,"native output h%0d r%0d c%0d",h,r,c);nread++;if(nread%32768==0)$display("M011_LAYER_PROGRESS stage=PUBLIC_CONTEXT consumed_words=%0d cycle=%0d",nread,cycle);end
   end
   if(dut.res_fp_protocol_fault||dut.head.sm_resource_fault||dut.coverage_fault)$fatal(1,"layer resource fault");
   if(dut.rope_wr_commit_valid)begin
    for(int c=0;c<64;c++)if(dut.rope_wr_q[c]!==postgold[qi(dut.rope_wr_token,0,dut.rope_wr_head,c)]||dut.rope_wr_k[c]!==postgold[qi(dut.rope_wr_token,1,dut.rope_wr_head,c)])$fatal(1,"layer RoPE mismatch");nrope++;if(nrope%512==0)$display("M011_LAYER_PROGRESS stage=ROPE_ATOMIC committed=%0d cycle=%0d",nrope,cycle);
   end
   if(dut.res_fp_rsp_phase==2&&dut.res_st_ps_wr_valid&&dut.res_st_ps_wr_ready)begin
    int group,key;group=int'(dut.res_st_ps_wr_tag[11:7]);key=int'(dut.res_st_ps_wr_tag[6:0]);for(int q=0;q<4;q++)begin int r,b;r=group*4+q;b=(key/64)*512+(r%16)*32+key%32;if(dut.res_st_ps_wr_data[b]!==allscore[(int'(active_head)*128+r)*128+key])$fatal(1,"layer score h%0d r%0d k%0d",active_head,r,key);hs++;nscore++;if(hs%4096==0)$display("M011_LAYER_PROGRESS head=%0d stage=QK_SCORE checked_words=%0d cycle=%0d",active_head,hs,cycle);end
   end
   if(dut.h_check_qk_done)for(int r=0;r<128;r++)if(dut.h_maximum[r]!==allmax[int'(active_head)*128+r])$fatal(1,"layer maximum h%0d r%0d",active_head,r);
   if(dut.head.sm_prob_wr_valid&&dut.head.sm_prob_wr_ready)begin int r,k;r=int'(dut.head.sm_prob_wr_tag[10:4]);k=int'(dut.head.sm_prob_wr_tag[3:0])*8;for(int c=0;c<8;c++)begin if(dut.head.sm_prob_wr_data[c]!==allprob[(int'(active_head)*128+r)*128+k+c])$fatal(1,"layer prob h%0d r%0d k%0d",active_head,r,k+c);hp++;nprob++;end end
   if(dut.head.sm_prob_wr_ack_valid&&dut.head.sm_prob_wr_ack_ready)begin hack++;if(hack%512==0)$display("M011_LAYER_PROGRESS head=%0d stage=SM_BANK_ACK vectors=%0d cycle=%0d",active_head,hack,cycle);end
   if(dut.res_st_context_wr_valid&&dut.res_st_context_wr_ready)for(int c=0;c<64;c++)if(dut.res_st_context_wr_mask[c])begin int h,r;h=int'(dut.res_st_context_wr_addr[c][10:7]);r=int'(dut.res_st_context_wr_addr[c][6:0]);if(h!=active_head||dut.res_st_context_wr_data[c]!==allcontext[(h*128+r)*64+c])$fatal(1,"layer context h%0d r%0d c%0d",h,r,c);hc++;ncontext++;end
   if(dut.res_fp_rsp_phase==4&&dut.res_fp_add_rsp_valid[0]&&dut.res_fp_add_rsp_ready[0])begin av_retired_progress++;if(av_retired_progress%512==0)$display("M011_LAYER_PROGRESS head=%0d stage=AV_ACC_RETIRE vectors=%0d cycle=%0d",active_head,av_retired_progress,cycle);end
   if(selected&&dut.res_fp_rsp_phase!=7)begin
    if(dut.res_fp_mul_rsp_valid&&dut.res_fp_mul_rsp_ready)begin int group,key;group=dut.res_fp_rsp_phase==2?int'(dut.res_fp_mul_rsp_tag[11:7]):int'(dut.res_fp_mul_rsp_tag[4:0]);key=dut.res_fp_rsp_phase==2?int'(dut.res_fp_mul_rsp_tag[6:0]):int'(dut.res_fp_mul_rsp_tag[11:5]);
     for(int q=0;q<4;q++)for(int c=0;c<64;c++)begin logic[31:0]gold;gold=dut.res_fp_rsp_phase==2?ql0[((group*4+q)*128+key)*64+c]:avprod[(key*128+group*4+q)*64+c];if(dut.res_fp_mul_rsp_data[q*64+c]!==gold)$fatal(1,"selected mul head%0d phase%0d",active_head,dut.res_fp_rsp_phase);end if(dut.res_fp_rsp_phase==2)hqm++;else ham++;
    end
    if(dut.res_fp_rsp_phase==2)begin
     for(int g=0;g<7;g++)if(dut.res_fp_add_rsp_valid[g]&&dut.res_fp_add_rsp_ready[g])begin int group,key;group=int'(dut.res_fp_add_rsp_tag[g][11:7]);key=int'(dut.res_fp_add_rsp_tag[g][6:0]);for(int q=0;q<4;q++)for(int n=0;n<qwidth(g);n++)begin logic[31:0]gold;gold=g==6?allscore[(int'(active_head)*128+group*4+q)*128+key]:qgold(g+1,group*4+q,key,n);if(dut.res_fp_add_rsp_data[qlo(g)+q*qwidth(g)+n]!==gold)$fatal(1,"selected QK tree head%0d level%0d",active_head,g);end hqadd[g]++;end
     if(dut.head.q_res_scale_rsp_valid&&dut.head.q_res_scale_rsp_ready)begin int group,key;group=int'(dut.head.q_res_scale_rsp_tag[11:7]);key=int'(dut.head.q_res_scale_rsp_tag[6:0]);for(int q=0;q<4;q++)if(dut.head.q_res_scale_data[q]!==qscale[(group*4+q)*128+key])$fatal(1,"selected scale");hscale++;end
    end
    if(dut.res_fp_rsp_phase==4&&dut.res_fp_add_rsp_valid[0]&&dut.res_fp_add_rsp_ready[0])begin int group,key;group=int'(dut.res_fp_add_rsp_tag[0][4:0]);key=int'(dut.res_fp_add_rsp_tag[0][11:5]);for(int q=0;q<4;q++)for(int c=0;c<64;c++)if(dut.res_fp_add_rsp_data[q*64+c]!==avpartial[(key*128+group*4+q)*64+c])$fatal(1,"selected AV accumulator");haadd++;end
    if(dut.head.sm_fp_rsp_valid&&dut.head.sm_fp_rsp_ready)for(int g=0;g<8;g++)if(tv(dut.head.sm_fp_rsp_tag,g))begin int r,node,index;r=tr(dut.head.sm_fp_rsp_tag,g);node=ti(dut.head.sm_fp_rsp_tag,g);for(int i=0;i<nn(g);i++)begin index=g<4?node*nn(g)+i:node;if(g==0)begin if(dut.head.sm_fp_rsp_data[i]!==gold_shift[r*128+index])$fatal(1,"selected shift");hshift++;end else begin if(dut.head.sm_fp_rsp_data[lo(g)+i]!==sumgold(g-1,r*(128>>g)+index))$fatal(1,"selected sum g%0d",g);hsum[g-1]++;end end end
    if(dut.head.sm_sfu_rsp_valid&&dut.head.sm_sfu_rsp_ready)begin int r,k;r=int'(dut.head.sm_sfu_rsp_tag[10:4]);k=int'(dut.head.sm_sfu_rsp_tag[3:0])*8;for(int c=0;c<8;c++)begin if(dut.head.sm_sfu_rsp_data[c]!==gold_exp[r*128+k+c])$fatal(1,"selected EXP");hexp++;end end
    if(dut.head.sm_div_rsp_valid&&dut.head.sm_div_rsp_ready)begin int r,k;r=int'(dut.head.sm_div_rsp_tag[10:4]);k=int'(dut.head.sm_div_rsp_tag[3:0])*8;if(dut.head.sm_div_rsp_error!=0)$fatal(1,"selected DIV error");for(int c=0;c<8;c++)begin if(dut.head.sm_div_rsp_data[c]!==allprob[(int'(active_head)*128+r)*128+k+c])$fatal(1,"selected DIV");hdiv++;end end
   end
   if(dut.h_done_valid&&dut.h_done_ready)begin
    if(dut.h_done_status!=0||dut.h_done_cycles>11648||hs!=16384||hp!=16384||hc!=8192||hack!=2048)$fatal(1,"head complete coverage/status h%0d st%0d score%0d prob%0d context%0d",active_head,dut.h_done_status,hs,hp,hc);
    if(selected)begin if(hqm!=4096||ham!=4096||hscale!=4096||haadd!=4096||hshift!=16384||hexp!=16384||hdiv!=16384)$fatal(1,"selected intermediate counts");for(int g=0;g<7;g++)if(hqadd[g]!=4096||hsum[g]!=128*(64>>g))$fatal(1,"selected tree counts");end
    nheads++;$display("M011_LAYER_HEAD_END head=%0d cycle=%0d cycles=%0d qk=%0d sm=%0d av=%0d score=%0d prob=%0d context=%0d",active_head,cycle,dut.h_done_cycles,dut.h_qk_cycles,dut.h_softmax_cycles,dut.h_av_cycles,hs,hp,hc);
    if(pilot!=0&&nheads==pilot)begin $display("HARDWARE_AGENT_SIM_PASS M011_LAYER_PILOT case=%s heads=%0d partial_layer_only=1 same_source=1 score=%0d prob=%0d context=%0d",which,nheads,nscore,nprob,ncontext);$finish;end
   end
  end
 end
endmodule
