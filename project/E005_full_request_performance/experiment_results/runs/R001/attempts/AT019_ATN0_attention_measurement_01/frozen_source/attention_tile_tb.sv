`timescale 1ns/1ps
module attention_tile_tb;
 reg ap_clk=0;always #5 ap_clk=~ap_clk;
 reg ap_rst=1,ap_ce=1,ap_start=0,ap_continue=0;
 reg [31:0] command=0,index=0,payload=0,epoch=0;
 wire ap_done,ap_idle,ap_ready,result_ap_vld,status_ap_vld;
 wire [31:0] result,status;
 attention_tile_service_v1 dut(.*);
 reg [31:0] q[0:8191],k[0:8191],v[0:8191],mask[0:127],identity[0:20];
 reg [31:0] score[0:16383],ex[0:16383],prob[0:16383],out_gold[0:8191],max_gold[0:127],sum_gold[0:127];
 reg [31:0] qk_product[0:1048575],qk_tree[0:1032191],av_trace[0:1048575];
 typedef logic [63:0] pair_t;
 reg [31:0] mul_oracle[pair_t],add_oracle[pair_t],div_oracle[pair_t];
 reg [31:0] mg[0:13][0:15],ag[0:5][0:15],dg[0:11][0:3];
 reg [13:0] mv=0;reg [5:0] av=0;reg [11:0] dv=0;
 reg [4:0] ml[0:13],al[0:5];
 integer cycles=0,calls=0,rows=4,protocol=0;
 integer checked_m=0,checked_a=0,checked_d=0,checked_products=0,checked_trees=0,checked_av=0,checked_exp=0;
 integer qk_cycles=0,sm_cycles=0,av_cycles=0,load_cycles=0;
 integer cm0,ca0,cd0,base_row=0;
 reg oracle_enable=0;
 `include "attention_tile_state.svh"
 integer pause_debit=0;
 bit paused_qk=0,paused_sm=0,paused_av=0;
 integer accepted_calls=0,retired_calls=0,reset_cancelled=0;
 bit active_call=0;
 bit setup_bad_q=0;
 integer enabled_cycles=0,phase_cycles[0:2],m_issue_edges[0:2],a_issue_edges[0:2],d_issue_edges[0:2];
 integer m_lanes[0:2],a_lanes[0:2],d_lanes[0:2],m_credit[0:2],a_credit[0:2],m_wait[0:2],a_wait[0:2],d_wait[0:2];
 integer exp_began[0:3],exp_hist[0:3][0:128];
 bit exp_inflight[0:3];
 // Passive ATN0 counters. The four state buckets and launch/report bucket
 // partition enabled edges from a normal SM command's launch to first done.
 bit sm_window=0,sm_waiting_consume=0;
 integer sm_start_enabled=0,sm_first_done_cycle=0;
 integer sm_state_edges[0:4],sm_total_enabled=0,sm_total_wall=0;
 integer sm_done_to_consume_wall=0,sm_commands=0;
 integer sm_a_sub_issue=0,sm_a_sub_retire=0,sm_a_tree_issue=0,sm_a_tree_retire=0;
 integer sm_d_issue=0,sm_d_return_lanes=0,sm_exp_issue_credit=0,sm_exp_issue_other=0;
 integer sm_tree_credit=0,sm_div_credit=0;
 integer exp_launch_count[0:3],exp_done_count[0:3],exp_commit_count[0:3];
 integer exp_input_edges[0:3],exp_service_edges[0:3],exp_commit_wait_edges[0:3],exp_idle_edges[0:3];
 integer exp_done_edge[0:3],exp_done_to_commit[0:3];
 integer cmd_done_wall[19:21],cmd_done_enabled[19:21];
 integer cmd_consume_wall[19:21],cmd_consume_enabled[19:21],cmd_count[19:21];
 always @(posedge ap_clk)begin
  if(ap_rst)for(integer n=0;n<4;n=n+1)exp_inflight[n]=0;
  else if(ap_ce)begin
   enabled_cycles=enabled_cycles+1;
   if(oracle_enable)begin
    integer ph;
    ph=dut.state==3?0:((dut.state>=4&&dut.state<=7)?1:((dut.state==8||dut.state==9)?2:-1));
    if(ph>=0)begin
     phase_cycles[ph]=phase_cycles[ph]+1;
     if(dut.m_req)m_issue_edges[ph]=m_issue_edges[ph]+1;
     if(dut.a_req)a_issue_edges[ph]=a_issue_edges[ph]+1;
     if(dut.d_req)d_issue_edges[ph]=d_issue_edges[ph]+1;
     if(dut.m_read_valid)m_lanes[ph]=m_lanes[ph]+(dut.m_read_type==0||dut.m_read_type==3?16:1);
     if(dut.a_read_valid)a_lanes[ph]=a_lanes[ph]+dut.a_read_lanes;
     if(dut.d_read_valid)d_lanes[ph]=d_lanes[ph]+4;
     if(!dut.m_req)begin
      if(dut.mq_state[dut.mq_wp]!=0)m_credit[ph]=m_credit[ph]+1;else m_wait[ph]=m_wait[ph]+1;
     end
     if(!dut.a_req)begin
      if(dut.aq_state[dut.aq_wp]!=0)a_credit[ph]=a_credit[ph]+1;else a_wait[ph]=a_wait[ph]+1;
     end
     if(dut.state==7&&!dut.d_req&&dut.norm_key<dut.S)d_wait[ph]=d_wait[ph]+1;
    end
    if(sm_window)begin
     if(dut.state>=4&&dut.state<=7)sm_state_edges[dut.state-4]=sm_state_edges[dut.state-4]+1;
     else sm_state_edges[4]=sm_state_edges[4]+1;
     if(dut.a_req&&dut.a_req_type==4)sm_a_sub_issue=sm_a_sub_issue+1;
     if(dut.a_retire&&dut.aq_type[dut.aq_rp]==4)sm_a_sub_retire=sm_a_sub_retire+1;
     if(dut.a_req&&dut.a_req_type==5)sm_a_tree_issue=sm_a_tree_issue+1;
     if(dut.a_retire&&dut.aq_type[dut.aq_rp]==5)sm_a_tree_retire=sm_a_tree_retire+1;
     if(dut.d_req)sm_d_issue=sm_d_issue+1;
     if(dut.state==7)begin
      for(integer n=0;n<4;n=n+1)if(dut.dq_state[n][dut.dq_rp[n]]==2)sm_d_return_lanes=sm_d_return_lanes+1;
      if(dut.norm_key<dut.S&&!dut.d_req)sm_div_credit=sm_div_credit+1;
     end
     if(dut.state==5&&dut.exp_key<dut.S&&dut.subcount>0&&!dut.a_req)begin
      if(dut.aq_state[dut.aq_wp]!=0)sm_exp_issue_credit=sm_exp_issue_credit+1;
      else sm_exp_issue_other=sm_exp_issue_other+1;
     end
     if(dut.state==6&&dut.tree_issue<(dut.sm_width/2+15)/16&&!dut.a_req&&dut.aq_state[dut.aq_wp]!=0)
      sm_tree_credit=sm_tree_credit+1;
     if(dut.state==5)for(integer n=0;n<4;n=n+1)begin
      case(dut.worker_state[n])
       0:exp_idle_edges[n]=exp_idle_edges[n]+1;
       1:exp_input_edges[n]=exp_input_edges[n]+1;
       2:exp_service_edges[n]=exp_service_edges[n]+1;
       3:exp_commit_wait_edges[n]=exp_commit_wait_edges[n]+1;
      endcase
     end
    end
   end
   for(integer n=0;n<4;n=n+1)begin
    if(dut.worker_launch[n])begin
     exp_inflight[n]=1;exp_began[n]=enabled_cycles;
     if(sm_window)exp_launch_count[n]=exp_launch_count[n]+1;
    end
    else if(exp_inflight[n]&&dut.exp_done[n])begin
     integer gap;gap=enabled_cycles-exp_began[n];
     if(gap>128)$fatal(1,"Original EXP exceeded finite histogram range");
     if(oracle_enable)begin
      exp_hist[n][gap]=exp_hist[n][gap]+1;
      if(sm_window)begin exp_done_count[n]=exp_done_count[n]+1;exp_done_edge[n]=enabled_cycles;end
     end
     exp_inflight[n]=0;
    end
   end
   if(oracle_enable&&sm_window&&dut.exp_retire)begin
    if(dut.wsel<0||dut.wsel>3||exp_done_edge[dut.wsel]==0)$fatal(1,"EXP committed without observed completion");
    exp_commit_count[dut.wsel]=exp_commit_count[dut.wsel]+1;
    exp_done_to_commit[dut.wsel]=exp_done_to_commit[dut.wsel]+enabled_cycles-exp_done_edge[dut.wsel];
    exp_done_edge[dut.wsel]=0;
   end
  end
 end
 always @(posedge ap_clk)begin
  if(ap_rst)begin if(active_call)reset_cancelled=reset_cancelled+1;active_call=0;end
  else if(ap_ce)begin
   if(ap_idle&&ap_start)begin if(active_call)$fatal(1,"Overlapping true launch");accepted_calls=accepted_calls+1;active_call=1;end
   if(ap_done&&ap_continue)begin if(!active_call)$fatal(1,"Retirement without launch");retired_calls=retired_calls+1;active_call=0;end
  end
  if(accepted_calls!=retired_calls+reset_cancelled+integer'(active_call))$fatal(1,"Call conservation failed");
 end
 string fixture,trace_dir;
 task automatic cmp(input string label_,input integer n,input [31:0] actual,expected);
  if(actual!==expected)$fatal(1,"ATTENTION_TILE_NUMERIC_FAIL %s element=%0d got=%08x gold=%08x",label_,n,actual,expected);
 endtask
 task automatic load_oracle(input integer op,count);
  integer fa,fb,fg,rv;reg [31:0] a,b,c;string name;
  name=op==0?"mul":(op==1?"add":"div");
  fa=$fopen({fixture,"/",name,"_a.mem"},"r");fb=$fopen({fixture,"/",name,"_b.mem"},"r");fg=$fopen({fixture,"/",name,"_gold.mem"},"r");
  if(!fa||!fb||!fg)$fatal(1,"Missing frozen basic oracle");
  for(integer n=0;n<count;n=n+1)begin
   rv=$fscanf(fa,"%h\n",a);if(rv!=1)$fatal(1,"Truncated basic a");rv=$fscanf(fb,"%h\n",b);if(rv!=1)$fatal(1,"Truncated basic b");rv=$fscanf(fg,"%h\n",c);if(rv!=1)$fatal(1,"Truncated basic gold");
   case(op)0:mul_oracle[{a,b}]=c;1:add_oracle[{a,b}]=c;2:div_oracle[{a,b}]=c;endcase
  end
  $fclose(fa);$fclose(fb);$fclose(fg);
  $display("ATTENTION_SERVICE_PROGRESS tile oracle=%s count=%0d",name,count);
 endtask
 always @(posedge ap_clk)begin
  cycles=cycles+1;if(cycles>40000000)$fatal(1,"Attention tile 40M cycle cap");
  if(ap_rst)begin mv<=0;av<=0;dv<=0;end
  else if(ap_ce)begin
   if(oracle_enable)begin
    if(mv[13])for(integer n=0;n<16;n=n+1)if(n<ml[13])begin cmp("M lane",n,dut.mo[n],mg[13][n]);checked_m=checked_m+1;end
    if(av[5])for(integer n=0;n<16;n=n+1)if(n<al[5])begin cmp("A lane",n,dut.ao[n],ag[5][n]);checked_a=checked_a+1;end
    if(dv[11])for(integer n=0;n<4;n=n+1)begin cmp("D lane",n,dut.do_[n],dg[11][n]);checked_d=checked_d+1;end
   end
   mv<={mv[12:0],dut.m_read_valid&&oracle_enable};av<={av[4:0],dut.a_read_valid&&oracle_enable};dv<={dv[10:0],dut.d_read_valid&&oracle_enable};
   ml[0]<=dut.m_read_type==0||dut.m_read_type==3?16:1;al[0]<=dut.a_read_lanes;
   for(integer t=1;t<14;t=t+1)begin ml[t]<=ml[t-1];for(integer n=0;n<16;n=n+1)mg[t][n]<=mg[t-1][n];end
   for(integer t=1;t<6;t=t+1)begin al[t]<=al[t-1];for(integer n=0;n<16;n=n+1)ag[t][n]<=ag[t-1][n];end
   for(integer t=1;t<12;t=t+1)for(integer n=0;n<4;n=n+1)dg[t][n]<=dg[t-1][n];
   if(oracle_enable&&dut.m_read_valid)for(integer n=0;n<16;n=n+1)if(dut.m_read_type==0||dut.m_read_type==3||n==0)begin
    if(!mul_oracle.exists({dut.ma[n],dut.mb[n]}))$fatal(1,"Unknown M operands lane=%0d a=%08x b=%08x mode=%0d",n,dut.ma[n],dut.mb[n],dut.m_read_type);
    mg[0][n]<=mul_oracle[{dut.ma[n],dut.mb[n]}];
   end
   if(oracle_enable&&dut.a_read_valid)for(integer n=0;n<16;n=n+1)if(n<dut.a_read_lanes)begin
    if(!add_oracle.exists({dut.aa[n],dut.ab[n]}))$fatal(1,"Unknown A operands lane=%0d a=%08x b=%08x mode=%0d",n,dut.aa[n],dut.ab[n],dut.a_read_type);
    ag[0][n]<=add_oracle[{dut.aa[n],dut.ab[n]}];
   end
   if(oracle_enable&&dut.d_read_valid)for(integer n=0;n<4;n=n+1)begin
    if(!div_oracle.exists({dut.da[n],dut.db[n]}))$fatal(1,"Unknown D operands lane=%0d a=%08x b=%08x",n,dut.da[n],dut.db[n]);
    dg[0][n]<=div_oracle[{dut.da[n],dut.db[n]}];
   end
   if(oracle_enable&&dut.m_retire&&dut.state==3&&dut.mq_type[dut.mq_rp]==0)for(integer n=0;n<16;n=n+1)begin
    integer ix;ix=((base_row+dut.mq_row[dut.mq_rp])*128+dut.mq_key[dut.mq_rp])*64+dut.mq_stripe[dut.mq_rp]*16+n;
    cmp("QK product commit",ix,dut.mq_data[dut.mq_rp][n],qk_product[ix]);checked_products=checked_products+1;
   end
   if(oracle_enable&&dut.a_retire&&dut.aq_type[dut.aq_rp]==0)for(integer n=0;n<16;n=n+1)if(n<dut.aq_lanes[dut.aq_rp])begin
    integer ix;ix=((base_row+dut.aq_row[dut.aq_rp])*128+dut.aq_key[dut.aq_rp])*63+64-(64>>dut.aq_level[dut.aq_rp])+dut.aq_stripe[dut.aq_rp]*16+n;
    cmp("QK tree commit",ix,dut.aq_data[dut.aq_rp][n],qk_tree[ix]);checked_trees=checked_trees+1;
   end
   if(oracle_enable&&dut.a_retire&&dut.aq_type[dut.aq_rp]==6)for(integer n=0;n<16;n=n+1)begin
    integer ix;ix=((base_row+dut.aq_row[dut.aq_rp])*128+dut.aq_key[dut.aq_rp])*64+dut.aq_stripe[dut.aq_rp]*16+n;
    cmp("AV each-key commit",ix,dut.aq_data[dut.aq_rp][n],av_trace[ix]);checked_av=checked_av+1;
   end
   if(oracle_enable&&dut.exp_retire)begin
    integer ix;ix=(base_row+dut.sm_row)*128+dut.worker_key[dut.wsel];cmp("EXP commit",ix,dut.worker_y[dut.wsel],ex[ix]);checked_exp=checked_exp+1;
   end
  end
 end
 task automatic pause_active(input integer kind);
  reg [TILE_STATE_BITS-1:0] saved;
  integer began;
  began=cycles;
  while(!(kind==0?dut.mv[7]:(kind==1?dut.av[3]:(kind==2?dut.dv[7]:exp_native_advance))))begin
   @(negedge ap_clk);if(ap_done||cycles-began>200000)$fatal(1,"No real active pipeline kind=%0d",kind);
  end
  ap_ce=0;#1;saved=read_tile_state();
  repeat(8)begin @(negedge ap_clk);#1;if(read_tile_state()!==saved||exp_native_advance)$fatal(1,"Global CE changed sequential state kind=%0d",kind);end
  ap_ce=1;pause_debit=pause_debit+8;
  $display("ATTENTION_SERVICE_TILE_CE_PASS kind=%0d cycles=%0d",kind,cycles);
 endtask
 task automatic reset_active(input integer kind,ep);
  reg [31:0] value;
  integer began;
  while(!ap_idle)@(negedge ap_clk);
  command=kind<2?19:20;index=0;payload=0;epoch=ep;ap_start=1;
  @(negedge ap_clk);ap_start=0;began=cycles;
  while(!(kind==0?dut.mv[7]:(kind==1?dut.av[3]:(kind==2?dut.dv[7]:exp_native_advance))))begin
   @(negedge ap_clk);if(ap_done||cycles-began>200000)$fatal(1,"Reset lacked real active pipeline kind=%0d",kind);
  end
  ap_ce=0;repeat(2)@(negedge ap_clk);ap_rst=1;repeat(8)@(negedge ap_clk);
  if(!ap_idle||ap_done||dut.phase!=0||dut.mv||dut.av||dut.dv||dut.m_occupancy||dut.a_occupancy)$fatal(1,"Reset failed to preempt CE or cancel reservations");
  ap_rst=0;ap_ce=1;repeat(3)@(negedge ap_clk);
  invoke(18,0,q[0],ep,2,value);invoke(10,0,0,ep,2,value);
  $display("ATTENTION_SERVICE_TILE_RESET_PASS kind=%0d reset_preempted_ce=1 cycles=%0d",kind,cycles);
 endtask
 task automatic invoke(input integer cmd,idx,data,ep,expected_status,output reg [31:0] value);
  integer start_cycle,start_enabled;reg [31:0] saved_result,saved_status;
  while(!ap_idle)@(negedge ap_clk);
  command=cmd;index=idx;payload=data;epoch=ep;ap_start=1;start_cycle=cycles;start_enabled=enabled_cycles;pause_debit=0;
  if(oracle_enable&&expected_status==0&&cmd==20)begin
   if(sm_window||sm_waiting_consume)$fatal(1,"SM measurement windows overlap");
   sm_window=1;sm_start_enabled=start_enabled;
  end
  if(protocol&&oracle_enable&&cmd==19&&!paused_qk)begin ap_ce=0;repeat(3)@(negedge ap_clk);if(!ap_idle||ap_done)$fatal(1,"Launch occurred while CE low");ap_ce=1;pause_debit=pause_debit+3;end
  @(negedge ap_clk);ap_start=0;
  if(protocol&&oracle_enable)begin
   if(cmd==19&&!paused_qk)begin pause_active(0);pause_active(1);paused_qk=1;end
   if(cmd==20&&!paused_sm)begin pause_active(3);pause_active(2);paused_sm=1;end
   if(cmd==21&&!paused_av)begin pause_active(1);paused_av=1;end
  end
  while(!ap_done)begin @(negedge ap_clk);if(cycles-start_cycle>4000000)$fatal(1,"Attention tile call stalled cmd=%0d state=%0d phase=%0d",cmd,dut.state,dut.phase);end
  if(!result_ap_vld||!status_ap_vld||status!==32'(expected_status))$fatal(1,"Attention tile status cmd=%0d got=%0d expected=%0d result=%0d",cmd,status,expected_status,result);
  value=result;saved_result=result;saved_status=status;
  if(oracle_enable&&expected_status==0)begin
   if(cmd==19)qk_cycles=qk_cycles+cycles-start_cycle-pause_debit;if(cmd==20)sm_cycles=sm_cycles+cycles-start_cycle-pause_debit;if(cmd==21)av_cycles=av_cycles+cycles-start_cycle-pause_debit;
   if(cmd>=19&&cmd<=21)$display("ATTENTION_SERVICE_TILE_RUN_PROFILE first=%0d cmd=%0d normal_cycles=%0d",base_row,cmd,cycles-start_cycle-pause_debit);
   if(cmd>=19&&cmd<=21)begin
    cmd_count[cmd]=cmd_count[cmd]+1;
    cmd_done_wall[cmd]=cmd_done_wall[cmd]+cycles-start_cycle;
    cmd_done_enabled[cmd]=cmd_done_enabled[cmd]+enabled_cycles-start_enabled;
   end
   if(cmd==20)begin
    sm_window=0;sm_waiting_consume=1;sm_first_done_cycle=cycles;
    sm_commands=sm_commands+1;sm_total_wall=sm_total_wall+cycles-start_cycle;
    sm_total_enabled=sm_total_enabled+enabled_cycles-sm_start_enabled;
   end
  end
  if(cmd==4||cmd==5||cmd==6||cmd==18)load_cycles=load_cycles+cycles-start_cycle;
  repeat(2)begin @(negedge ap_clk);if(!ap_done||result!==saved_result||status!==saved_status)$fatal(1,"Attention tile done did not hold");end
  if(protocol&&oracle_enable&&cmd>=19&&cmd<=21)begin
   reg [TILE_STATE_BITS-1:0] saved;ap_ce=0;#1;saved=read_tile_state();repeat(8)begin @(negedge ap_clk);#1;if(!ap_done||read_tile_state()!==saved)$fatal(1,"Completed response lost across CE");end ap_ce=1;
  end
  ap_continue=1;@(negedge ap_clk);ap_continue=0;@(negedge ap_clk);calls=calls+1;
  if(oracle_enable&&expected_status==0&&cmd>=19&&cmd<=21)begin
   cmd_consume_wall[cmd]=cmd_consume_wall[cmd]+cycles-start_cycle-1;
   cmd_consume_enabled[cmd]=cmd_consume_enabled[cmd]+enabled_cycles-start_enabled-1;
   if(cmd==20)begin
    if(!sm_waiting_consume)$fatal(1,"SM actual completion was not pending");
    sm_done_to_consume_wall=sm_done_to_consume_wall+cycles-sm_first_done_cycle-1;
    sm_waiting_consume=0;
   end
  end
  if(calls%4096==0)$display("ATTENTION_SERVICE_PROGRESS tile calls=%0d cycles=%0d",calls,cycles);
 endtask
 task automatic bind_only(input integer first,count,ep,seq,bad_ref);
  reg [31:0] words[0:54],value;
  base_row=first;
  invoke(0,0,0,ep,0,value);
  for(integer n=0;n<55;n=n+1)words[n]=0;
  for(integer n=0;n<21;n=n+1)words[n]=identity[n];
  words[4]=(seq<<16)|1;
  for(integer n=0;n<3;n=n+1)begin words[21+4*n]=100+n;words[22+4*n]='h250+n;words[23+4*n]=(count<<16)|first;end
  for(integer n=0;n<7;n=n+1)begin words[33+3*n]=n==0?'h25:(n==3?'h28:(n==4?8:(n==5?5:(n==6?'h105:'h26))));words[34+3*n]=n==2?2:1;end
  if(bad_ref)words[42]='h29;
  for(integer n=0;n<55;n=n+1)invoke(1,n,words[n],ep,0,value);
  for(integer n=0;n<55;n=n+1)begin invoke(17,n,0,ep,0,value);cmp("binding",n,value,words[n]);end
 endtask
 task automatic setup(input integer first,count,ep);
  reg [31:0] value;
  bind_only(first,count,ep,128,0);
  invoke(2,128,first,ep,0,value);invoke(19,0,0,ep,2,value);
  for(integer n=0;n<8192;n=n+1)begin invoke(4,n,k[n],ep,0,value);invoke(5,n,v[n],ep,0,value);end
  for(integer n=0;n<128;n=n+1)invoke(6,n,mask[n],ep,0,value);
  for(integer n=0;n<count*64;n=n+1)begin
   invoke(18,n,setup_bad_q&&n==count*64-1?32'h7fc00000:q[first*64+n],ep,0,value);
  end
 endtask
 // Independent directed inputs: only finite max-normal products can reach
 // the selected adjacent-tree overflow, and all expected indices are from
 // original qk_row's row-local Q / key*64+parent contract.
 task automatic first_error_case(input integer kind);
  reg [31:0] value,kbits,qbits;reg [TILE_STATE_BITS-1:0] saved;
  integer ep,count,expected,completed;
  ep=200+kind;count=kind==4?16:2;expected=kind==0?323:(kind==3?7:(kind==5?4095:63));completed=kind==0||kind==5?64:(kind==4?960:0);
  bind_only(0,count,ep,64,0);invoke(2,64,0,ep,0,value);
  for(integer n=0;n<4096;n=n+1)begin
   kbits=kind==5?(n==4095?32'h7f7fffff:0):((n==326||n==327)?32'h7f7fffff:0);
   invoke(4,n,kbits,ep,0,value);invoke(5,n,0,ep,0,value);
  end
  for(integer n=0;n<64;n=n+1)invoke(6,n,1,ep,0,value);
  for(integer n=0;n<count*64;n=n+1)begin
   qbits=kind==4||(kind==1&&n<64)?0:32'h3f800000;
   if((kind==0||kind==5)&&n==127||kind==1&&n==63||kind==2&&n==63||kind==3&&(n==7||n==63||n==64)||kind==4&&n==1023)qbits=kind==4?32'h7f800000:32'h7fc00000;
   if(kind==5&&n==63)qbits=32'h40000000;
   invoke(18,n,qbits,ep,0,value);
  end
  if(kind==3)begin
   ap_ce=0;#1;saved=read_tile_state();repeat(8)begin @(negedge ap_clk);#1;if(read_tile_state()!==saved)$fatal(1,"Pending Q first-error changed under CE");end ap_ce=1;
  end
  invoke(19,0,0,ep,1,value);cmp("ordered tile QK first-error",kind,value,expected);
  if(dut.qk_written!=completed||!dut.queues_empty||dut.mv||dut.av||dut.dv)$fatal(1,"Bad-Q boundary issued wrong rows or retained debt kind=%0d completed=%0d",kind,dut.qk_written);
  invoke(10,0,0,ep,2,value);invoke(20,0,0,ep,2,value);
  $display("ATTENTION_SERVICE_TILE_FIRST_ERROR_CASE_PASS kind=%0d bad_element=%0d prior_row_scores=%0d",kind,expected,completed);
  if(kind==3)begin
   ap_ce=0;ap_rst=1;repeat(8)@(negedge ap_clk);
   if(dut.q_bad_valid||dut.nq||dut.qk_target_rows||dut.err_valid||!ap_idle)$fatal(1,"Reset did not clear pending Q first-error while CE low");
   ap_rst=0;ap_ce=1;repeat(3)@(negedge ap_clk);invoke(18,0,0,ep,2,value);
   $display("ATTENTION_SERVICE_TILE_FIRST_ERROR_RESET_PASS reset_preempted_ce=1");
  end
 endtask
 initial begin
  reg [31:0] value;integer count,ep;
  if(!$value$plusargs("FIXTURE=%s",fixture)||!$value$plusargs("TRACE=%s",trace_dir))$fatal(1,"Frozen fixtures required");
  if($value$plusargs("ROWS=%d",rows))begin end
  if($value$plusargs("PROTOCOL=%d",protocol))begin end
  if(rows!=1&&rows!=4&&rows!=16&&rows!=128)$fatal(1,"Rows 1/4/16/128 only");
  for(integer ph=0;ph<3;ph=ph+1)begin phase_cycles[ph]=0;m_issue_edges[ph]=0;a_issue_edges[ph]=0;d_issue_edges[ph]=0;m_lanes[ph]=0;a_lanes[ph]=0;d_lanes[ph]=0;m_credit[ph]=0;a_credit[ph]=0;m_wait[ph]=0;a_wait[ph]=0;d_wait[ph]=0;end
  for(integer n=0;n<4;n=n+1)begin exp_inflight[n]=0;for(integer gap=0;gap<=128;gap=gap+1)exp_hist[n][gap]=0;end
  for(integer n=0;n<5;n=n+1)sm_state_edges[n]=0;
  for(integer n=19;n<=21;n=n+1)begin cmd_done_wall[n]=0;cmd_done_enabled[n]=0;cmd_consume_wall[n]=0;cmd_consume_enabled[n]=0;cmd_count[n]=0;end
  for(integer n=0;n<4;n=n+1)begin exp_launch_count[n]=0;exp_done_count[n]=0;exp_commit_count[n]=0;
   exp_input_edges[n]=0;exp_service_edges[n]=0;exp_commit_wait_edges[n]=0;exp_idle_edges[n]=0;exp_done_edge[n]=0;exp_done_to_commit[n]=0;end
  $readmemh({fixture,"/q.mem"},q);$readmemh({fixture,"/k.mem"},k);$readmemh({fixture,"/v.mem"},v);$readmemh({fixture,"/mask.mem"},mask);$readmemh({fixture,"/identity_words.mem"},identity);
  $readmemh({fixture,"/score.mem"},score);$readmemh({fixture,"/exp.mem"},ex);$readmemh({fixture,"/prob.mem"},prob);$readmemh({fixture,"/out.mem"},out_gold);$readmemh({fixture,"/maximum.mem"},max_gold);$readmemh({fixture,"/sum.mem"},sum_gold);
  $readmemh({trace_dir,"/qk_product.mem"},qk_product);$readmemh({trace_dir,"/qk_tree.mem"},qk_tree);$readmemh({trace_dir,"/av_trace.mem"},av_trace);
  load_oracle(0,rows*16640);load_oracle(1,rows*16767);load_oracle(2,rows*128);
  repeat(8)@(negedge ap_clk);ap_rst=0;repeat(3)@(negedge ap_clk);
  if(protocol)begin
   for(integer kind=0;kind<4;kind=kind+1)begin
    setup(0,4,100+kind);if(kind>=2)invoke(19,0,0,100+kind,0,value);reset_active(kind,100+kind);
   end
   setup(0,4,104);invoke(18,256,0,104,2,value);invoke(2,128,4,104,2,value);invoke(19,1,0,104,2,value);
   invoke(2,128,1<<16,104,2,value);
   bind_only(0,4,105,128,1);invoke(2,128,0,105,2,value);
   setup_bad_q=1;setup(0,4,106);setup_bad_q=0;invoke(19,0,0,106,1,value);cmp("last nonfinite Q dimension",255,value,63);invoke(10,127,0,106,2,value);
   for(integer kind=0;kind<6;kind=kind+1)first_error_case(kind);
   $display("ATTENTION_SERVICE_TILE_FIRST_ERROR_PASS cases=6 pending_Q_CE_reset=1");
   invoke(0,0,0,105,0,value);
   $display("ATTENTION_SERVICE_TILE_PROTOCOL_PASS resets=4 wrong_epoch_row=1");
  end
  for(integer first=0;first<rows;first=first+16)begin
   count=rows<16?rows:16;ep=first/16+1;
   setup(first,count,ep);oracle_enable=1;cm0=checked_m;ca0=checked_a;cd0=checked_d;
   invoke(19,0,0,ep,0,value);
   $display("ATTENTION_SERVICE_PROGRESS tile QK first=%0d rows=%0d cycles=%0d",first,count,cycles);
   for(integer row=first;row<first+count;row=row+1)begin invoke(2,128,row,ep,0,value);for(integer key=0;key<128;key=key+1)begin invoke(10,key,0,ep,0,value);cmp("score",row*128+key,value,score[row*128+key]);end end
   invoke(20,0,0,ep,0,value);
   for(integer row=first;row<first+count;row=row+1)begin
    cmp("max retained",row,dut.maximum[row-first],max_gold[row]);cmp("sum retained",row,dut.total[row-first],sum_gold[row]);
    invoke(2,128,row,ep,0,value);
    if(row-first>=count-8)begin invoke(13,0,0,ep,0,value);cmp("max",row,value,max_gold[row]);invoke(15,0,0,ep,0,value);cmp("sum",row,value,sum_gold[row]);end
    else begin invoke(13,0,0,ep,2,value);invoke(15,0,0,ep,2,value);invoke(14,0,0,ep,2,value);end
    for(integer key=0;key<128;key=key+1)begin invoke(11,key,0,ep,0,value);cmp("prob",row*128+key,value,prob[row*128+key]);
     if(row-first>=count-8)begin invoke(14,key,0,ep,0,value);cmp("exp",row*128+key,value,ex[row*128+key]);end
    end
   end
   $display("ATTENTION_SERVICE_PROGRESS tile SM first=%0d rows=%0d cycles=%0d",first,count,cycles);
   invoke(21,0,0,ep,0,value);
   for(integer row=first;row<first+count;row=row+1)begin invoke(2,128,row,ep,0,value);for(integer d=0;d<64;d=d+1)begin invoke(12,d,0,ep,0,value);cmp("out",row*64+d,value,out_gold[row*64+d]);end end
   if(checked_m-cm0!=count*16640||checked_a-ca0!=count*16767||checked_d-cd0!=count*128)$fatal(1,"Semantic operation coverage M=%0d A=%0d D=%0d",checked_m-cm0,checked_a-ca0,checked_d-cd0);
   $display("ATTENTION_SERVICE_TILE_PASS first=%0d rows=%0d qk=%0d sm=%0d av=%0d M=%0d A=%0d D=%0d Mpeak=%0d Apeak=%0d Mcredit=%0d busy=%0d exp_hold=%0d",first,count,qk_cycles,sm_cycles,av_cycles,checked_m-cm0,checked_a-ca0,checked_d-cd0,dut.m_peak,dut.a_peak,dut.m_credit_stall,dut.av_busy_stall,dut.exp_hold_stall);
   oracle_enable=0;invoke(16,0,0,ep,0,value);invoke(12,0,0,ep,2,value);
  end
  if(checked_products!=rows*128*64||checked_trees!=rows*128*63||checked_av!=rows*128*64||checked_exp!=rows*128)$fatal(1,"Tagged intermediate coverage incomplete");
  if(active_call||accepted_calls!=retired_calls+reset_cancelled)$fatal(1,"Outstanding call at terminal");
  if(sm_window||sm_waiting_consume||sm_commands!=(rows+15)/16)$fatal(1,"Incomplete SM measurement lifecycle");
  if(sm_state_edges[0]+sm_state_edges[1]+sm_state_edges[2]+sm_state_edges[3]+sm_state_edges[4]!=sm_total_enabled)
   $fatal(1,"SM enabled state partition mismatch");
  // S=128: ASUB=128/4, tree stripes=4+2+1+1+1+1+1, DIV=128/4.
  if(sm_a_sub_issue!=rows*32||sm_a_tree_issue!=rows*11||sm_d_issue!=rows*32||
     sm_a_sub_retire!=sm_a_sub_issue||sm_a_tree_retire!=sm_a_tree_issue||sm_d_return_lanes!=rows*128)
   $fatal(1,"SM observed operation issue counts changed");
  if(!protocol&&sm_total_wall!=sm_cycles)$fatal(1,"SM wall interval differs from frozen command profile");
  for(integer n=0;n<4;n=n+1)if(exp_launch_count[n]!=exp_done_count[n]||exp_done_count[n]!=exp_commit_count[n]||exp_done_edge[n]!=0)
   $fatal(1,"EXP worker measurement did not drain worker=%0d",n);
  $display("ATTENTION_SERVICE_TILE_SM_MEASURE commands=%0d wall_to_done=%0d enabled_to_done=%0d done_to_consume_wall=%0d MAX=%0d EXP=%0d TREE=%0d DIV=%0d launch_report=%0d A_sub_issue=%0d A_sub_retire=%0d A_tree_issue=%0d A_tree_retire=%0d D_issue=%0d D_return_lanes=%0d EXP_A_credit=%0d EXP_other_wait=%0d TREE_A_credit=%0d DIV_D_credit=%0d",sm_commands,sm_total_wall,sm_total_enabled,sm_done_to_consume_wall,sm_state_edges[0],sm_state_edges[1],sm_state_edges[2],sm_state_edges[3],sm_state_edges[4],sm_a_sub_issue,sm_a_sub_retire,sm_a_tree_issue,sm_a_tree_retire,sm_d_issue,sm_d_return_lanes,sm_exp_issue_credit,sm_exp_issue_other,sm_tree_credit,sm_div_credit);
  for(integer n=19;n<=21;n=n+1)$display("ATTENTION_SERVICE_TILE_CMD_MEASURE cmd=%0d calls=%0d wall_to_done=%0d enabled_to_done=%0d wall_to_consume=%0d enabled_to_consume=%0d",n,cmd_count[n],cmd_done_wall[n],cmd_done_enabled[n],cmd_consume_wall[n],cmd_consume_enabled[n]);
  for(integer n=0;n<4;n=n+1)$display("ATTENTION_SERVICE_TILE_EXP_MEASURE worker=%0d launch=%0d done=%0d commit=%0d input_wait=%0d core_busy=%0d commit_wait=%0d idle=%0d done_to_commit_sum=%0d",n,exp_launch_count[n],exp_done_count[n],exp_commit_count[n],exp_input_edges[n],exp_service_edges[n],exp_commit_wait_edges[n],exp_idle_edges[n],exp_done_to_commit[n]);
  $display("ATTENTION_SERVICE_TILE_LEDGER_PASS accepted=%0d retired=%0d cancelled=%0d",accepted_calls,retired_calls,reset_cancelled);
  for(integer ph=0;ph<3;ph=ph+1)$display("ATTENTION_SERVICE_TILE_PROFILE phase=%0d enabled=%0d M_edges=%0d A_edges=%0d D_edges=%0d M_lanes=%0d A_lanes=%0d D_lanes=%0d M_credit=%0d A_credit=%0d M_wait=%0d A_wait=%0d D_wait=%0d",ph,phase_cycles[ph],m_issue_edges[ph],a_issue_edges[ph],d_issue_edges[ph],m_lanes[ph],a_lanes[ph],d_lanes[ph],m_credit[ph],a_credit[ph],m_wait[ph],a_wait[ph],d_wait[ph]);
  for(integer n=0;n<4;n=n+1)for(integer gap=0;gap<=128;gap=gap+1)if(exp_hist[n][gap])$display("ATTENTION_SERVICE_TILE_EXP_PROFILE worker=%0d launch_done_enabled_gap=%0d count=%0d",n,gap,exp_hist[n][gap]);
  $display("ATTENTION_SERVICE_TILE_RTL_PASS rows=%0d keys128 D64 cycles=%0d qk=%0d sm=%0d av=%0d load=%0d M=%0d A=%0d D=%0d products=%0d trees=%0d av_steps=%0d exp=%0d",rows,cycles,qk_cycles,sm_cycles,av_cycles,load_cycles,checked_m,checked_a,checked_d,checked_products,checked_trees,checked_av,checked_exp);
  $finish;
 end
endmodule
