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
 task automatic invoke(input integer cmd,idx,data,ep,expected_status,output reg [31:0] value);
  integer start_cycle;reg [31:0] saved_result,saved_status;
  while(!ap_idle)@(negedge ap_clk);
  command=cmd;index=idx;payload=data;epoch=ep;ap_start=1;start_cycle=cycles;
  @(negedge ap_clk);ap_start=0;
  while(!ap_done)begin @(negedge ap_clk);if(cycles-start_cycle>4000000)$fatal(1,"Attention tile call stalled cmd=%0d state=%0d phase=%0d",cmd,dut.state,dut.phase);end
  if(!result_ap_vld||!status_ap_vld||status!==32'(expected_status))$fatal(1,"Attention tile status cmd=%0d got=%0d expected=%0d result=%0d",cmd,status,expected_status,result);
  value=result;saved_result=result;saved_status=status;
  if(cmd==19)qk_cycles=qk_cycles+cycles-start_cycle;if(cmd==20)sm_cycles=sm_cycles+cycles-start_cycle;if(cmd==21)av_cycles=av_cycles+cycles-start_cycle;
  if(cmd==4||cmd==5||cmd==6||cmd==18)load_cycles=load_cycles+cycles-start_cycle;
  repeat(2)begin @(negedge ap_clk);if(!ap_done||result!==saved_result||status!==saved_status)$fatal(1,"Attention tile done did not hold");end
  ap_continue=1;@(negedge ap_clk);ap_continue=0;@(negedge ap_clk);calls=calls+1;
  if(calls%4096==0)$display("ATTENTION_SERVICE_PROGRESS tile calls=%0d cycles=%0d",calls,cycles);
 endtask
 task automatic setup(input integer first,count,ep);
  reg [31:0] words[0:54],value;
  base_row=first;
  invoke(0,0,0,ep,0,value);
  for(integer n=0;n<55;n=n+1)words[n]=0;
  for(integer n=0;n<21;n=n+1)words[n]=identity[n];
  for(integer n=0;n<3;n=n+1)begin words[21+4*n]=100+n;words[22+4*n]='h250+n;words[23+4*n]=(count<<16)|first;end
  for(integer n=0;n<7;n=n+1)begin words[33+3*n]=n==0?'h25:(n==3?'h28:(n==4?8:(n==5?5:(n==6?'h105:'h26))));words[34+3*n]=n==2?2:1;end
  for(integer n=0;n<55;n=n+1)invoke(1,n,words[n],ep,0,value);
  for(integer n=0;n<55;n=n+1)begin invoke(17,n,0,ep,0,value);cmp("binding",n,value,words[n]);end
  invoke(2,128,first,ep,0,value);invoke(19,0,0,ep,2,value);
  for(integer n=0;n<8192;n=n+1)begin invoke(4,n,k[n],ep,0,value);invoke(5,n,v[n],ep,0,value);end
  for(integer n=0;n<128;n=n+1)invoke(6,n,mask[n],ep,0,value);
  for(integer n=0;n<count*64;n=n+1)invoke(18,n,q[first*64+n],ep,0,value);
 endtask
 initial begin
  reg [31:0] value;integer count,ep;
  if(!$value$plusargs("FIXTURE=%s",fixture)||!$value$plusargs("TRACE=%s",trace_dir))$fatal(1,"Frozen fixtures required");
  if($value$plusargs("ROWS=%d",rows))begin end
  if($value$plusargs("PROTOCOL=%d",protocol))begin end
  if(rows!=1&&rows!=4&&rows!=16&&rows!=128)$fatal(1,"Rows 1/4/16/128 only");
  $readmemh({fixture,"/q.mem"},q);$readmemh({fixture,"/k.mem"},k);$readmemh({fixture,"/v.mem"},v);$readmemh({fixture,"/mask.mem"},mask);$readmemh({fixture,"/identity_words.mem"},identity);
  $readmemh({fixture,"/score.mem"},score);$readmemh({fixture,"/exp.mem"},ex);$readmemh({fixture,"/prob.mem"},prob);$readmemh({fixture,"/out.mem"},out_gold);$readmemh({fixture,"/maximum.mem"},max_gold);$readmemh({fixture,"/sum.mem"},sum_gold);
  $readmemh({trace_dir,"/qk_product.mem"},qk_product);$readmemh({trace_dir,"/qk_tree.mem"},qk_tree);$readmemh({trace_dir,"/av_trace.mem"},av_trace);
  load_oracle(0,rows*16640);load_oracle(1,rows*16767);load_oracle(2,rows*128);
  repeat(8)@(negedge ap_clk);ap_rst=0;repeat(3)@(negedge ap_clk);
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
  $display("ATTENTION_SERVICE_TILE_RTL_PASS rows=%0d keys128 D64 cycles=%0d qk=%0d sm=%0d av=%0d load=%0d M=%0d A=%0d D=%0d products=%0d trees=%0d av_steps=%0d exp=%0d",rows,cycles,qk_cycles,sm_cycles,av_cycles,load_cycles,checked_m,checked_a,checked_d,checked_products,checked_trees,checked_av,checked_exp);
  $finish;
 end
endmodule
