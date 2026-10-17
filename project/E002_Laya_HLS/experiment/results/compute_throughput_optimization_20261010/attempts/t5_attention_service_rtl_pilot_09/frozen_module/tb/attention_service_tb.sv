`timescale 1ns/1ps
module attention_service_tb;
 logic ap_clk=0;always #5 ap_clk=~ap_clk;
 logic ap_rst=1,ap_start=0,ap_continue=0,ap_ce=1,ap_done,ap_idle,ap_ready;
 logic[31:0] command=0,index=0,payload=0,epoch=0,result,status;
 logic result_ap_vld,status_ap_vld;
 laya_attention_service dut(.*);
 logic exp_start=0,exp_done,exp_idle,exp_ready;
 logic[31:0] exp_x=0,exp_y,exp_directed_x[0:11],exp_directed_gold[0:11];
 laya_attention_service_attention_exp_bits exp_boundary_dut(
  .ap_clk(ap_clk),.ap_rst(ap_rst),.ap_ce(ap_ce),.ap_start(exp_start),.ap_done(exp_done),
  .ap_idle(exp_idle),.ap_ready(exp_ready),.x(exp_x),.ap_return(exp_y),
  .laya_global_ce(ap_ce|ap_rst));
 logic[31:0] q[0:8191],k[0:8191],v[0:8191],mask[0:127],identity[0:20];
 logic[31:0] score[0:16383],ex[0:16383],prob[0:16383],out_gold[0:8191];
 logic[31:0] max_gold[0:127],sum_gold[0:127];
 string fixture;int rows=8,cycles=0,total_calls=0;
 logic check_finish=0;
 `include "attention_fp_monitors.svh"
 int qk_cycles=0,sm_cycles=0,av_cycles=0,load_cycles=0;
 bit pause_checked=0;
 bit call_active=0,saw_result_valid=0,saw_status_valid=0;
 logic[31:0] captured_result,captured_status;
 int call_started=0,return_updates=0;
 // ap_vld is an update pulse and may precede ap_done. Capture every update
 // in the accepted call and require the last valid data to be held at done.
 task automatic capture_returns;
  if(call_active&&ap_ce)begin
   if(result_ap_vld)begin saw_result_valid=1;captured_result=result;return_updates++;end
   if(status_ap_vld)begin saw_status_valid=1;captured_status=status;return_updates++;end
  end
 endtask
 always @(posedge ap_clk)capture_returns();
 always @(posedge ap_clk) begin
  cycles++;
  if(cycles>40000000)$fatal(1,"ATTENTION_SERVICE 40M cycle cap");
  if(call_active&&cycles-call_started>(command>=7&&command<=9?500000:1000))
   $fatal(1,"ATTENTION_SERVICE call stalled cmd%0d idx%0d calls%0d fsm%0h",command,index,total_calls,dut.ap_CS_fsm);
 end
 task automatic invoke(input int cmd,idx,data,ep,expected_status,output logic[31:0]value);
  int began;
  while(!(ap_idle||ap_ready))@(negedge ap_clk);
  saw_result_valid=0;saw_status_valid=0;call_started=cycles;call_active=1;
  command=cmd;index=idx;payload=data;epoch=ep;ap_start=1;
  began=cycles;@(negedge ap_clk);ap_start=0;
  if(cmd==7&&expected_status==0&&!pause_checked)begin
   logic[31:0] saved_result,saved_status;logic[511:0] saved_fsm,saved_fp;int saved_updates;
   logic[ATTENTION_STATE_BITS-1:0] saved_state;
   while(!attention_mul_advance)@(negedge ap_clk);
   // Pause after a populated real multiplication pipeline, so held values
   // cannot be explained by an empty core or unchanged startup data.
   repeat(16)@(negedge ap_clk);
   ap_ce=0;#1;saved_result=result;saved_status=status;
   saved_fsm=dut.ap_CS_fsm;saved_fp=attention_fp_returns;saved_updates=return_updates;
   saved_state=attention_state_snapshot;
   repeat(8)begin
    @(negedge ap_clk);
    if(dut.ap_CS_fsm!==saved_fsm||result!==saved_result||status!==saved_status||
       attention_fp_returns!==saved_fp||ap_done||return_updates!=saved_updates||
       attention_state_snapshot!==saved_state||attention_mul_advance||attention_add_advance)
      $fatal(1,"ATTENTION_SERVICE ap_ce pause changed active state/return");
   end
   ap_ce=1;pause_checked=1;
   $display("ATTENTION_SERVICE_CE_HOLD_PASS cycles=%0d",cycles);
  end
  while(!ap_done)@(negedge ap_clk);
  capture_returns();
  if(!saw_result_valid||!saw_status_valid)$fatal(1,"ATTENTION_SERVICE missing scalar return valid cmd%0d",cmd);
  if(result!==captured_result||status!==captured_status)
   $fatal(1,"ATTENTION_SERVICE last valid return not held at done cmd%0d",cmd);
  if(status!==32'(expected_status))$fatal(1,"ATTENTION_SERVICE status cmd%0d idx%0d got%0d expected%0d",cmd,idx,status,expected_status);
  value=result;total_calls++;
  if(total_calls<=8||total_calls%1024==0)
   $display("ATTENTION_SERVICE_PROGRESS phase=CALL_RETIRE calls=%0d cmd=%0d cycles=%0d",total_calls,cmd,cycles);
  if(cmd==7)qk_cycles+=cycles-began;
  if(cmd==8)sm_cycles+=cycles-began;
  if(cmd==9)av_cycles+=cycles-began;
  if(cmd>=3&&cmd<=6)load_cycles+=cycles-began;
  // Hold every completed command for two enabled clocks before retirement.
  repeat(2)begin
   logic[31:0] saved_result,saved_status;
   saved_result=result;saved_status=status;@(negedge ap_clk);
   if(!ap_done||result!==saved_result||status!==saved_status)
    $fatal(1,"ATTENTION_SERVICE chain completion changed before continue cmd%0d",cmd);
  end
  call_active=0;ap_continue=1;@(negedge ap_clk);ap_continue=0;@(negedge ap_clk);
 endtask
 task automatic compare(input string phase,input int element,input logic[31:0]got,gold);
  if(got!==gold)$fatal(1,"ATTENTION_SERVICE numeric phase%s element%0d got%08x gold%08x",phase,element,got,gold);
 endtask
 task automatic bind_complete(input int ep,input logic[31:0] words[0:54]);
  logic[31:0] value;
  invoke(0,0,0,ep,0,value);
  for(int i=0;i<55;i++)invoke(1,i,words[i],ep,0,value);
  for(int i=0;i<55;i++)begin invoke(17,i,0,ep,0,value);compare("full binding",i,value,words[i]);end
  invoke(2,128,words[23]&'hffff,ep,0,value);
 endtask
 task automatic load_kv(input int ep);
  logic[31:0] value;
  for(int i=0;i<8192;i++)begin invoke(4,i,k[i],ep,0,value);invoke(5,i,v[i],ep,0,value);end
  for(int i=0;i<128;i++)invoke(6,i,mask[i],ep,0,value);
  $display("ATTENTION_SERVICE_PROGRESS phase=KV_LOAD epoch=%0d cycles=%0d",ep,cycles);
 endtask
 task automatic reset_active(input int ep,row,kind);
  logic[31:0] value;int start_cycle;
  for(int d=0;d<64;d++)invoke(3,d,q[row*64+d],ep,0,value);
  while(!(ap_idle||ap_ready))@(negedge ap_clk);
  command=7;index=0;payload=0;epoch=ep;ap_start=1;
  @(negedge ap_clk);ap_start=0;start_cycle=cycles;
  while(!(kind==0?attention_mul_advance:attention_add_advance))begin
   @(negedge ap_clk);
   if(ap_done||cycles-start_cycle>10000)$fatal(1,"Attention reset point lacked active real FP kind%0d",kind);
  end
  ap_rst=1;ap_continue=0;ap_ce=1;repeat(8)@(negedge ap_clk);
  ap_rst=0;repeat(3)@(negedge ap_clk);
  invoke(3,0,q[row*64],ep,2,value);invoke(10,0,0,ep,2,value);
  $display("ATTENTION_SERVICE_RESET_PASS real_fp_kind=%0d old_epoch=%0d cycles=%0d",kind,ep,cycles);
 endtask
 initial begin
  logic[31:0] value,binding[0:54];int ep,tile_rows,protocol;
  if(!$value$plusargs("FIXTURE=%s",fixture))$fatal(1,"FIXTURE required");
  if($value$plusargs("ROWS=%d",rows))begin end
  protocol=rows>1;if($value$plusargs("PROTOCOL=%d",protocol))begin end
  if(rows!=1&&rows!=8&&rows!=16&&rows!=128)$fatal(1,"ROWS1/8/16/128 only");
  $readmemh({fixture,"/q.mem"},q);$readmemh({fixture,"/k.mem"},k);$readmemh({fixture,"/v.mem"},v);
  $readmemh({fixture,"/mask.mem"},mask);$readmemh({fixture,"/identity_words.mem"},identity);
  $readmemh({fixture,"/score.mem"},score);$readmemh({fixture,"/exp.mem"},ex);$readmemh({fixture,"/prob.mem"},prob);
  $readmemh({fixture,"/out.mem"},out_gold);$readmemh({fixture,"/maximum.mem"},max_gold);$readmemh({fixture,"/sum.mem"},sum_gold);
  $readmemh({fixture,"/exp_directed_x.mem"},exp_directed_x);
  $readmemh({fixture,"/exp_directed_gold.mem"},exp_directed_gold);
  repeat(8)@(negedge ap_clk);ap_rst=0;repeat(3)@(negedge ap_clk);
  for(int i=0;i<12;i++)begin
   exp_x=exp_directed_x[i];exp_start=1;@(negedge ap_clk);exp_start=0;
   while(!exp_done)@(negedge ap_clk);
   compare("exp_directed",i,exp_y,exp_directed_gold[i]);@(negedge ap_clk);
  end
  $display("ATTENTION_EXP_RTL_DIRECTED_PASS count=12");
  for(int first=0;first<rows;first+=16)begin
    tile_rows=rows<16?rows:16;
    ep=first/16+1;invoke(0,0,0,ep,0,value);
    for(int i=0;i<55;i++)binding[i]=0;
    for(int i=0;i<21;i++)binding[i]=identity[i];
    for(int j=0;j<3;j++)begin
     binding[21+j*4]=100+j+(first/16)*3;binding[22+j*4]='h250+j;
     binding[23+j*4]=(tile_rows<<16)+first;binding[24+j*4]=0;
    end
    for(int j=0;j<7;j++)begin
     binding[33+j*3]=j==0?'h25:(j==3?'h28:(j==4?8:(j==5?5:(j==6?'h105:'h26))));
     binding[34+j*3]=j==2?2:1;
    end
    if(protocol&&first==0)begin
     binding[54]=1;
     for(int i=0;i<55;i++)invoke(1,i,binding[i],ep,0,value);
     invoke(2,128,first,ep,2,value);binding[54]=0;
     ep++;invoke(0,0,0,ep,0,value);binding[34]=0;
     for(int i=0;i<55;i++)invoke(1,i,binding[i],ep,0,value);
     invoke(2,128,first,ep,2,value);binding[34]=1;ep++;
     $display("ATTENTION_SERVICE_BIND_REJECT_PASS wrong_head_ref");
    end
    bind_complete(ep,binding);invoke(7,0,0,ep,2,value);load_kv(ep);
    if(protocol&&first==0)begin
     for(int kind=0;kind<2;kind++)begin
      reset_active(ep,first,kind);ep++;bind_complete(ep,binding);load_kv(ep);
     end
     for(int d=0;d<63;d++)invoke(3,d,q[first*64+d],ep,0,value);
     invoke(3,63,'h7f800000,ep,1,value);compare("last input error",63,value,63);
     invoke(10,0,0,ep,2,value);ep++;bind_complete(ep,binding);load_kv(ep);
     $display("ATTENTION_SERVICE_LAST_F32_REJECT_PASS element=63 no_score_publish");
    end
   for(int row=first;row<first+tile_rows;row++)begin
   if(row!=first)invoke(2,128,row,ep,0,value);
   invoke(3,0,0,ep+100,2,value);
   for(int d=0;d<64;d++)invoke(3,d,q[row*64+d],ep,0,value);
   invoke(7,0,0,ep,0,value);
   for(int key=0;key<128;key++)begin invoke(10,key,0,ep,0,value);compare("score",row*128+key,value,score[row*128+key]);end
   $display("ATTENTION_SERVICE_PROGRESS phase=QK row=%0d cycles=%0d",row,cycles);
   end
   for(int row=first;row<first+tile_rows;row++)begin
   invoke(2,128,row,ep,0,value);
   invoke(8,0,0,ep,0,value);
   invoke(13,0,0,ep,0,value);compare("max",row,value,max_gold[row]);
   invoke(15,0,0,ep,0,value);compare("sum",row,value,sum_gold[row]);
   for(int key=0;key<128;key++)begin
    invoke(14,key,0,ep,0,value);compare("exp",row*128+key,value,ex[row*128+key]);
    invoke(11,key,0,ep,0,value);compare("prob",row*128+key,value,prob[row*128+key]);
   end
   $display("ATTENTION_SERVICE_PROGRESS phase=SOFTMAX row=%0d cycles=%0d",row,cycles);
   end
   if(tile_rows>1)begin
    invoke(2,128,first,ep,0,value);invoke(13,0,0,ep,2,value);
    invoke(14,0,0,ep,2,value);invoke(15,0,0,ep,2,value);
   end
   for(int row=first;row<first+tile_rows;row++)begin
   invoke(2,128,row,ep,0,value);
   invoke(9,0,0,ep,0,value);
   for(int d=0;d<64;d++)begin invoke(12,d,0,ep,0,value);compare("out",row*64+d,value,out_gold[row*64+d]);end
   $display("ATTENTION_SERVICE_PROGRESS rows=%0d cycles=%0d qk=%0d sm=%0d av=%0d calls=%0d",row+1,cycles,qk_cycles,sm_cycles,av_cycles,total_calls);
   end
   if(tile_rows>1)begin invoke(2,128,first,ep,0,value);invoke(12,0,0,ep,2,value);end
   invoke(16,0,0,ep,0,value);invoke(12,0,0,ep,2,value);
  end
  check_finish=1;repeat(2)@(negedge ap_clk);
  $display("ATTENTION_SERVICE_RTL_PASS rows=%0d keys128 D64 cycles=%0d qk=%0d sm=%0d av=%0d load=%0d",rows,cycles,qk_cycles,sm_cycles,av_cycles,load_cycles);
  $finish;
 end
endmodule
