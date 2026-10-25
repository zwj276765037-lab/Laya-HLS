`timescale 1ns/1ps
module m007_single_parent_tb;
 logic  clk;
 logic  rst_n;
 logic  cmd_valid;
 logic  cmd_ready;
 logic [63:0] cmd_request;
 logic [31:0] cmd_generation;
 logic [31:0] cmd_epoch;
 logic [127:0] cmd_model_id;
 logic [127:0] cmd_numeric_id;
 logic [127:0] cmd_table_key;
 logic [127:0] cmd_graph_id;
 logic [127:0] cmd_layout_id;
 logic [127:0] cmd_build_id;
 logic [1:0] cmd_kind;
 logic [4:0] cmd_layer;
 logic [127:0] cmd_mask;
 logic [1:0][31:0] cmd_tensor;
 logic [1:0][3:0][63:0] cmd_base;
 logic [1:0][3:0][63:0] cmd_span;
 logic  in_valid;
 logic  in_ready;
 logic [31:0][31:0] in_data;
 logic [63:0] in_request;
 logic [31:0] in_generation;
 logic [31:0] in_epoch;
 logic [7:0] in_row;
 logic [7:0] in_group;
 logic  input_reject_valid;
 logic [3:0] input_reject_code;
 logic  producer_fail_valid;
 logic [95:0] producer_fail_tuple;
 logic [63:0] producer_fail_request;
 logic [31:0] producer_fail_generation;
 logic [31:0] producer_fail_epoch;
 logic  producer_fail_ready;
 logic  out_valid;
 logic  out_ready;
 logic [31:0][31:0] out_data;
 logic [6:0] out_row;
 logic [15:0] out_col;
 logic  done_valid;
 logic  done_ready;
 logic [7:0] done_status;
 logic [2:0] error_domain;
 logic [95:0] error_tuple;
 logic [7:0] source_status;
 logic [127:0] bias_model_id;
 logic [127:0] bias_numeric_id;
 logic [63:0] done_request;
 logic [31:0] done_generation;
 logic [31:0] done_epoch;
 logic [4:0] parent_state;
 logic [31:0] elapsed_cycles;
 logic [15:0] layer_head_completed;
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
 logic  coef_cfg_valid;
 logic  coef_cfg_ready;
 logic [63:0] coef_model;
 logic [63:0] coef_request;
 logic [31:0] coef_tensor;
 logic [31:0] coef_generation;
 logic [31:0] coef_epoch;
 logic [15:0] coef_n;
 logic  coef_wr_valid;
 logic  coef_wr_ready;
 logic [6:0] coef_wr_addr;
 logic [31:0][31:0] coef_wr_data;
 logic  coef_rsp_valid;
 logic  coef_rsp_ready;
 logic [1:0] coef_status;
 logic [15:0] coef_error_col;
 logic [3:0] arvalid;
 logic [3:0] arready;
 logic [3:0][63:0] araddr;
 logic [3:0][2:0] arid;
 logic [3:0][7:0] arlen;
 logic [3:0] rvalid;
 logic [3:0] rready;
 logic [3:0][2:0] rid;
 logic [3:0][511:0] rdata;
 logic [3:0][1:0] rresp;
 logic [3:0] rlast;
 laya_m007_single_parent_v1 dut(.*);
 always #1 clk=~clk;

 logic [1023:0] inputs[0:4095],gold[0:12287];logic [271:0] agold[0:4095];logic [8191:0] prebias[0:1535];
 logic [511:0] mem0[0:13823],mem1[0:13823],mem2[0:13823],mem3[0:13823];
 logic [31:0] cf[0:8191],sf[0:8191],maskmem[0:127],qkvgold[0:393215];
 logic [7:0] live[0:3];logic [63:0] baddr[0:3][0:7];integer bsize[0:3][0:7],bpos[0:3][0:7],eligible[0:3][0:7],rotate[0:3];logic [3:0] last_r_fire;
 integer cycle=0,qkv_count=0,input_count=0,awrites=0,aacks=0,matrix_accepts=0,layer_starts=0,layer_prepares=0,prefix=3,mode=0,command_cycle=-1;
 integer ar_count=0,r_count=0,issues[0:47],acks[0:47],retired[0:47],first_issue[0:47],last_issue[0:47];
 integer issue_time[0:63],ps_time[0:63],issue_seq[0:63];logic[63:0]issue_owned,ps_owned;integer max_issue_ack=0,max_ps_feedback=0;
 logic [4351:0] expected_w,expected_a;logic [511:0] temp;
 logic [31:0] old_state=0;string matrix_fixture,input_fixture,attention_fixture;
 function automatic logic [511:0] word(input integer p,idx);case(p)0:return mem0[idx];1:return mem1[idx];2:return mem2[idx];default:return mem3[idx];endcase endfunction
 task automatic step;begin @(posedge clk);#0.1;end endtask
 always_comb arready=15;
 always @(negedge clk)begin
  if(!rst_n)begin rvalid=0;rid=0;rdata=0;rresp=0;rlast=0;end
  else for(integer p=0;p<4;p++)if(!rvalid[p]||last_r_fire[p])begin
   integer pick;pick=-1;for(integer q=7;q>=0;q--)if(live[p][(rotate[p]+q)%8]&&cycle>=eligible[p][(rotate[p]+q)%8])pick=(rotate[p]+q)%8;
   rvalid[p]=0;
   if(pick>=0&&cycle%2==0)begin rvalid[p]=1;rid[p]=pick;rdata[p]=word(p,((baddr[p][pick]-cmd_base[0][p])>>6)+bpos[p][pick]);rlast[p]=bpos[p][pick]+1==bsize[p][pick];rresp[p]=0;end
  end
 end
 always @(posedge clk)begin
  cycle=cycle+1;last_r_fire<=rvalid&rready;
  if(!rst_n)begin issue_owned=0;ps_owned=0;for(integer p=0;p<4;p++)begin live[p]<=0;rotate[p]<=0;end end
  else begin
   if(cmd_valid&&cmd_ready)command_cycle=cycle;
   if(dut.l_prepare_valid&&dut.l_prepare_ready)layer_prepares=layer_prepares+1;
   if(dut.l_start_valid&&dut.l_start_ready)begin if(qkv_count!=12288||matrix_accepts!=1||dut.m_done_valid)$fatal(1,"layer start before complete real QKV/receipt");layer_starts=layer_starts+1;end
   if(parent_state!=old_state)begin $display("MATRIX_PROGRESS parent_state=%0d cycle=%0d QKV=%0d",parent_state,cycle,qkv_count);$fflush();old_state=parent_state;end
   if(in_valid&&in_ready)input_count=input_count+1;
   if(dut.q_awr_valid&&dut.q_awr_ready)begin if(dut.q_awr_data!==agold[dut.q_awr_row*32+dut.q_awr_group])$fatal(1,"actual quant/A bytes row%0d group%0d",dut.q_awr_row,dut.q_awr_group);awrites=awrites+1;end
   if(dut.q_awr_rsp_valid&&dut.q_awr_rsp_ready)aacks=aacks+1;
   if(dut.m_cmd_valid&&dut.m_cmd_ready)begin
    matrix_accepts=matrix_accepts+1;
    if(input_count!=4096||awrites!=4096||aacks!=4096||dut.front.q_lease_active||dut.q_d_lease_active||dut.front.q_reservations!=0||dut.front.a_write_debt!=0||!dut.front.a_published||!dut.front.producer_closed||!dut.front.producer_success)$fatal(1,"parent matrix before real input/quant/A/debt release");
   end
   for(integer p=0;p<4;p++)begin
    if(arvalid[p]&&arready[p])begin
     if(live[p][arid[p]]||arlen[p]>15||araddr[p][5:0]!=0||{1'b0,araddr[p][11:0]}+64*(arlen[p]+1)>4096||araddr[p]<cmd_base[0][p]||araddr[p]+64*(arlen[p]+1)>cmd_base[0][p]+cmd_span[0][p])$fatal(1,"real AXI ID/page/span");
     live[p][arid[p]]<=1;baddr[p][arid[p]]<=araddr[p];bsize[p][arid[p]]<=arlen[p]+1;bpos[p][arid[p]]<=0;eligible[p][arid[p]]<=cycle+40+2*(7-arid[p]);ar_count=ar_count+1;
    end
    if(rvalid[p]&&rready[p])begin if(bpos[p][rid[p]]+1==bsize[p][rid[p]])live[p][rid[p]]<=0;else bpos[p][rid[p]]<=bpos[p][rid[p]]+1;rotate[p]<=(rid[p]+1)%8;r_count=r_count+1;end
   end
   if(dut.matrix.core.trace_issue)begin
    integer ss,seq,idx;ss=dut.matrix.core.trace_block_s;seq=dut.matrix.core.trace_issue_seq;
    if(ss>=48||seq!=issues[ss])$fatal(1,"real core issue order");if(last_issue[ss]>=0&&cycle-last_issue[ss]!=1)$fatal(1,"continuous K issue");if(first_issue[ss]<0)first_issue[ss]=cycle;last_issue[ss]=cycle;issues[ss]=issues[ss]+1;
    issue_time[seq%64]=cycle;issue_seq[seq%64]=seq;issue_owned[seq%64]=1;ps_owned[seq%64]=0;
    if(seq%8==0)begin idx=9*(ss*32+seq/32);for(integer a=0;a<8;a++)expected_w[512*a+:512]=word((seq%32)/8,idx+a);temp=word((seq%32)/8,idx+8);expected_w[4096+:256]=temp[255:0];if({dut.matrix.core.trace_w_scale,dut.matrix.core.trace_w_q}!==expected_w)$fatal(1,"actual W mapping");end
    if(ss==0&&seq%32<8)begin for(integer a=0;a<16;a++)begin expected_a[256*a+:256]=agold[(16*(seq%8)+a)*32+seq/32][255:0];expected_a[4096+16*a+:16]=agold[(16*(seq%8)+a)*32+seq/32][271:256];end if({dut.matrix.core.trace_a_scale,dut.matrix.core.trace_a_q}!==expected_a)$fatal(1,"actual A mapping");end
   end
   if(dut.matrix.core.math_read_fire)begin ps_time[dut.matrix.core.ps_next[5:0]]=cycle;ps_owned[dut.matrix.core.ps_next[5:0]]=1;end
   if(dut.matrix.core.trace_commit)begin
    integer ss,seq;ss=dut.matrix.core.trace_block_s;seq=dut.matrix.core.trace_commit_seq;
    if(seq!=acks[ss])$fatal(1,"real commit order");acks[ss]=acks[ss]+1;
    if(seq>=992&&dut.matrix.core.trace_commit_data!==prebias[32*ss+seq-992])$fatal(1,"independent prebias ss%0d seq%0d",ss,seq);
   end
   if(dut.matrix.core.state==2&&dut.matrix.core.normal_write_ack)begin
    integer ix;ix=dut.matrix.core.ps_wr_rsp_tag[5:0];if(!issue_owned[ix]||issue_seq[ix]!=dut.matrix.core.ps_wr_rsp_tag[12:0]||cycle-issue_time[ix]>64)$fatal(1,"passive issue/PSack64");if(cycle-issue_time[ix]>max_issue_ack)max_issue_ack=cycle-issue_time[ix];
    if(ps_owned[ix])begin if(cycle-ps_time[ix]>24)$fatal(1,"passive PSfeedback24");if(cycle-ps_time[ix]>max_ps_feedback)max_ps_feedback=cycle-ps_time[ix];end issue_owned[ix]=0;
   end
   if(dut.l_qkv_wr_valid&&dut.l_qkv_wr_ready)begin
    integer ss,off,col;ss=qkv_count/256;off=qkv_count%256;col=ss*64+32*(off%2);
    if(dut.l_qkv_wr_token!=off/2||dut.l_qkv_wr_plane!=col/1024||dut.l_qkv_wr_head!=(col%1024)/64||dut.l_qkv_wr_half!=(col%64)/32||dut.l_qkv_wr_data!==gold[qkv_count]||dut.l_qkv_wr_request_id!=cmd_request||dut.l_qkv_wr_generation!=cmd_generation||dut.l_qkv_wr_epoch!=cmd_epoch)$fatal(1,"actual public QKV mapping/value index%0d",qkv_count);
    for(int c=0;c<32;c++)if(dut.l_qkv_wr_data[c]!==qkvgold[(off/2)*3072+col+c])$fatal(1,"independent Attention preQKV source mismatch");
    if(!(dut.r_res_qkv_wr_valid&&dut.r_res_qkv_wr_ready)||dut.r_res_qkv_wr_data!==dut.l_qkv_wr_data)$fatal(1,"resource QKV path masked by phase1 math owner");
    if(acks[ss]!=1024||dut.l_start_valid||layer_starts!=0)$fatal(1,"public QKV before math commit or premature layer start");
    qkv_count=qkv_count+1;retired[ss]=retired[ss]+1;
    if(retired[ss]==256)begin $display("MATRIX_PROGRESS parent_QKV_retired_s=%0d groups=%0d cycle=%0d",ss,qkv_count,cycle);$fflush();end
   end
   if(dut.r_res_fp_protocol_fault||dut.r_res_div_protocol_fault||dut.l_check_coverage_fault)$fatal(1,"parent actual shared protocol fault");
   if(done_valid&&done_status!=0&&mode==0)$fatal(1,"parent unexpected done status%0d source%0d domain%0d tuple%h",done_status,source_status,error_domain,error_tuple);
   if(cycle>40000000)$fatal(1,"parent40Mcycle watchdog");
  end
 end
 task automatic send_command;
  begin @(negedge clk);cmd_valid=1;do @(posedge clk);while(!cmd_ready);@(negedge clk);cmd_valid=0;end
 endtask
 initial begin
  clk='0;
  rst_n='0;
  cmd_valid='0;
  cmd_request='0;
  cmd_generation='0;
  cmd_epoch='0;
  cmd_model_id='0;
  cmd_numeric_id='0;
  cmd_table_key='0;
  cmd_graph_id='0;
  cmd_layout_id='0;
  cmd_build_id='0;
  cmd_kind='0;
  cmd_layer='0;
  cmd_mask='0;
  cmd_tensor='0;
  cmd_base='0;
  cmd_span='0;
  in_valid='0;
  in_data='0;
  in_request='0;
  in_generation='0;
  in_epoch='0;
  in_row='0;
  in_group='0;
  producer_fail_valid='0;
  producer_fail_tuple='0;
  producer_fail_request='0;
  producer_fail_generation='0;
  producer_fail_epoch='0;
  out_ready='0;
  done_ready='0;
  bias_model_id='0;
  bias_numeric_id='0;
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
  coef_cfg_valid='0;
  coef_model='0;
  coef_request='0;
  coef_tensor='0;
  coef_generation='0;
  coef_epoch='0;
  coef_n='0;
  coef_wr_valid='0;
  coef_wr_addr='0;
  coef_wr_data='0;
  coef_rsp_ready='0;
  arready='0;
  rvalid='0;
  rid='0;
  rdata='0;
  rresp='0;
  rlast='0;

  if(!$value$plusargs("MATRIX=%s",matrix_fixture))$fatal(1,"MATRIX required");if(!$value$plusargs("INPUT=%s",input_fixture))$fatal(1,"INPUT required");if(!$value$plusargs("ATTENTION=%s",attention_fixture))$fatal(1,"ATTENTION required");if(!$value$plusargs("PREFIX=%d",prefix))prefix=3;
  $readmemh({matrix_fixture,"/qkv_0_weight/output.hex"},gold);$readmemh({matrix_fixture,"/qkv_0_weight/pre_bias.hex"},prebias);$readmemh({matrix_fixture,"/qkv_0_weight/a_write.hex"},agold);
  $readmemh({input_fixture,"/qkv_0_weight/input.hex"},inputs);
  $readmemh({matrix_fixture,"/qkv_0_weight/p0.hex"},mem0);$readmemh({matrix_fixture,"/qkv_0_weight/p1.hex"},mem1);$readmemh({matrix_fixture,"/qkv_0_weight/p2.hex"},mem2);$readmemh({matrix_fixture,"/qkv_0_weight/p3.hex"},mem3);
  $readmemh({attention_fixture,"/cos_full.mem"},cf);$readmemh({attention_fixture,"/sin_full.mem"},sf);$readmemh({attention_fixture,"/mask.mem"},maskmem);$readmemh({attention_fixture,"/encoder0_pre_qkv.mem"},qkvgold);
  for(int ss=0;ss<48;ss++)begin issues[ss]=0;acks[ss]=0;retired[ss]=0;first_issue[ss]=-1;last_issue[ss]=-1;end
  cmd_request=77;cmd_generation=8;cmd_epoch=9;cmd_model_id=dut.MODEL_ID;cmd_numeric_id=dut.NUMERIC_ID;cmd_table_key=dut.TABLE_KEY;cmd_graph_id=dut.GRAPH_ID;cmd_layout_id=dut.LAYOUT_ID;cmd_build_id=dut.BUILD_ID;cmd_kind=0;cmd_layer=0;cmd_tensor[0]=1;cmd_tensor[1]=2;
  for(int r=0;r<128;r++)cmd_mask[r]=maskmem[r][0];
  for(int p=0;p<4;p++)begin cmd_base[0][p]=64'h100000000+64'h10000000*p;cmd_span[0][p]=884736;cmd_base[1][p]=64'h200000000+64'h10000000*p;cmd_span[1][p]=294912;end
  coeff_bind_model_id=cmd_model_id;coeff_bind_numeric_id=cmd_numeric_id;coeff_bind_table_key=cmd_table_key;coeff_wr_model_id=cmd_model_id;coeff_wr_numeric_id=cmd_numeric_id;coeff_wr_table_key=cmd_table_key;
  bias_model_id=cmd_model_id;bias_numeric_id=cmd_numeric_id;out_ready=1;
  repeat(4)step();@(negedge clk);rst_n=1;coeff_bind_valid=1;do @(posedge clk);while(!coeff_bind_ready);@(negedge clk);coeff_bind_valid=0;
  for(int t=0;t<2;t++)for(int r=0;r<128;r++)for(int half=0;half<2;half++)begin
   coeff_wr_valid=1;coeff_wr_table=t;coeff_wr_row=r;coeff_wr_half=half;for(int c=0;c<32;c++)coeff_wr_data[c]=t?sf[r*64+half*32+c]:cf[r*64+half*32+c];#0.1;if(!coeff_wr_ready||coeff_wr_reject_valid)$fatal(1,"real original coefficient loader");@(posedge clk);@(negedge clk);
  end coeff_wr_valid=0;
  send_command();
  for(int g=0;g<4096;g++)begin in_valid=1;in_request=cmd_request;in_generation=cmd_generation;in_epoch=cmd_epoch;in_row=g/32;in_group=g%32;in_data=inputs[g];do @(posedge clk);while(!in_ready);@(negedge clk);end in_valid=0;
  if(prefix>0)begin
   wait(qkv_count==prefix*256);@(negedge clk);
   if(done_valid||layer_starts!=0||layer_prepares!=1||matrix_accepts!=1||input_count!=4096||awrites!=4096||aacks!=4096||parent_state!=5)$fatal(1,"prefix must remain actual unfinished parent");
   for(int ss=0;ss<prefix;ss++)if(issues[ss]!=1024||acks[ss]!=1024||retired[ss]!=256||last_issue[ss]-first_issue[ss]+1!=1024)$fatal(1,"prefix actual block coverage");
   $display("M007_PARENT_QKV_PREFIX_PASS blocks=%0d final_values=%0d public_QKV32_writes=%0d inputs=%0d Awrites=%0d Aacks=%0d elapsed=%0d actual_issue_ack=%0d actual_PS_feedback=%0d unfinished_parent=1",prefix,prefix*8192,qkv_count,input_count,awrites,aacks,cycle-command_cycle,max_issue_ack,max_ps_feedback);
   $display("HARDWARE_AGENT_SIM_PASS M007_PARENT_QKV_PREFIX");$fflush();$finish;
  end
  $fatal(1,"complete parent not enabled without actual same-build cost gate");
 end
endmodule
