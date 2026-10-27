`timescale 1ns/1ps
// Frozen design contract: R/source/design.md 8.3.1. One task, one shared
// M16/A16/D4 pool, four original exp workers. Every RAM has synchronous 1R1W.
module attention_tile_bank #(parameter DEPTH=4096)(
 input wire clk,ce,re,we,input wire [11:0] ra,wa,input wire [31:0] wd,
 output reg [31:0] rd);
 (* ram_style="block" *) reg [31:0] mem[0:DEPTH-1];
 always @(posedge clk) if(ce)begin
  if(re)rd<=mem[ra];
  if(we)mem[wa]<=wd;
 end
endmodule

module attention_tile_service_v1(
 input wire ap_clk,ap_rst,ap_ce,ap_start,ap_continue,
 input wire [31:0] command,index,payload,epoch,
 output wire ap_done,ap_idle,ap_ready,
 output reg [31:0] result,status,
 output wire result_ap_vld,status_ap_vld);
 localparam IDLE=0,REPORT=1,READ=2,QK=3,SM_MAX=4,SM_EXP=5,
 SM_TREE=6,SM_DIV=7,AV_ZERO=8,AV=9;
 localparam MPROD=0,MSCALE=1,MPAD=2,MAV=3;
 localparam ATREE=0,AMASK=1,ABIAS=2,AFINAL=3,ASUB=4,ASMTREE=5,AAV=6;
 wire gce=ap_ce|ap_rst;
 reg [3:0] state;
 reg [2:0] phase;
 reg [31:0] binding[0:54],bound_epoch,bind_count;
 reg [10:0] S,query,row0;reg [4:0] rows;reg [3:0] head;
 reg sliding;
 reg [31:0] nq,nk,nv,nmask;
 reg q_bad_valid;
 reg [9:0] q_bad_index;
 reg [4:0] qk_target_rows;
 reg [7:0] mask[0:1023];
 reg [31:0] maximum[0:15],total[0:15];
 reg [4:0] scratch_row[0:7];
 reg scratch_valid[0:7];
 reg [31:0] selected_cmd,selected_index;
 assign ap_idle=state==IDLE;
 assign ap_done=state==REPORT;
 assign ap_ready=state==REPORT&&ap_continue&&ap_ce&&!ap_rst;
 assign result_ap_vld=ap_done;
 assign status_ap_vld=ap_done;
 function automatic finite(input [31:0] x);finite=x[30:23]!=255;endfunction
 function automatic greater(input [31:0] a,b);
  if(a[30:0]==0&&b[30:0]==0)greater=0;
  else if(a[31]!=b[31])greater=!a[31];
  else greater=a[31]?(a[30:0]<b[30:0]):(a[30:0]>b[30:0]);
 endfunction
 reg err_valid;
 reg [63:0] err_rank;
 reg [31:0] err_element;
 // Ordered reduction includes every independently accepted element. Poisoned
 // dependent data are replaced by safe zero; the original first error remains.
 task automatic note_error(input [63:0] rank,input [31:0] element);
  if(!err_valid||rank<err_rank)begin err_valid=1;err_rank=rank;err_element=element;end
 endtask
 task automatic complete_run(input [2:0] successful_phase);
  begin phase<=err_valid?6:successful_phase;status<=err_valid?1:0;
   result<=err_valid?err_element:0;state<=REPORT;end
 endtask

 // Explicit physical banks: d%16 for K/V/Q/Y, key%16 for score/prob/exp.
 reg kr[0:15],kw[0:15],vr[0:15],vw[0:15],qr[0:15],qw[0:15],yr[0:15],yw[0:15];
 reg sr[0:15],sw[0:15],pr[0:15],pw[0:15],er[0:15],ew[0:15];
 reg [11:0] kra[0:15],kwa[0:15],vra[0:15],vwa[0:15],qra[0:15],qwa[0:15],yra[0:15],ywa[0:15];
 reg [11:0] sra[0:15],swa[0:15],pra[0:15],pwa[0:15],era[0:15],ewa[0:15];
 reg [31:0] kwd[0:15],vwd[0:15],qwd[0:15],ywd[0:15],swd[0:15],pwd[0:15],ewd[0:15];
 wire [31:0] kd[0:15],vd[0:15],qd[0:15],yd[0:15],sd[0:15],pd[0:15],ed[0:15];
 genvar g,l;
 generate for(g=0;g<16;g=g+1)begin: banks
  attention_tile_bank #(.DEPTH(4096)) k(.clk(ap_clk),.ce(ap_ce&&!ap_rst),.re(kr[g]),.we(kw[g]),.ra(kra[g]),.wa(kwa[g]),.wd(kwd[g]),.rd(kd[g]));
  attention_tile_bank #(.DEPTH(4096)) v(.clk(ap_clk),.ce(ap_ce&&!ap_rst),.re(vr[g]),.we(vw[g]),.ra(vra[g]),.wa(vwa[g]),.wd(vwd[g]),.rd(vd[g]));
  attention_tile_bank #(.DEPTH(64)) q(.clk(ap_clk),.ce(ap_ce&&!ap_rst),.re(qr[g]),.we(qw[g]),.ra(qra[g]),.wa(qwa[g]),.wd(qwd[g]),.rd(qd[g]));
  attention_tile_bank #(.DEPTH(64)) y(.clk(ap_clk),.ce(ap_ce&&!ap_rst),.re(yr[g]),.we(yw[g]),.ra(yra[g]),.wa(ywa[g]),.wd(ywd[g]),.rd(yd[g]));
  attention_tile_bank #(.DEPTH(1024)) score(.clk(ap_clk),.ce(ap_ce&&!ap_rst),.re(sr[g]),.we(sw[g]),.ra(sra[g]),.wa(swa[g]),.wd(swd[g]),.rd(sd[g]));
  attention_tile_bank #(.DEPTH(1024)) prob(.clk(ap_clk),.ce(ap_ce&&!ap_rst),.re(pr[g]),.we(pw[g]),.ra(pra[g]),.wa(pwa[g]),.wd(pwd[g]),.rd(pd[g]));
  attention_tile_bank #(.DEPTH(512)) ex(.clk(ap_clk),.ce(ap_ce&&!ap_rst),.re(er[g]),.we(ew[g]),.ra(era[g]),.wa(ewa[g]),.wd(ewd[g]),.rd(ed[g]));
 end endgenerate
 // Dot slots preserve each original level. Actual bank count shrinks above
 // level1, so the total payload is exactly 16*(64+32+16+8+4+2+1)*4 B.
 reg tr[0:6][0:31],tw[0:6][0:31];
 reg [11:0] tra[0:6][0:31],twa[0:6][0:31];
 reg [31:0] twd[0:6][0:31];
 wire [31:0] td[0:6][0:31];
 generate for(l=0;l<7;l=l+1)begin: dot_levels
  for(g=0;g<32;g=g+1)begin: bank
   if(g<(64>>l))begin: live
    attention_tile_bank #(.DEPTH(l==0?32:16)) ram(.clk(ap_clk),.ce(ap_ce&&!ap_rst),.re(tr[l][g]),.we(tw[l][g]),.ra(tra[l][g]),.wa(twa[l][g]),.wd(twd[l][g]),.rd(td[l][g]));
   end else begin: unused assign td[l][g]=0;end
  end
 end endgenerate
 reg str[0:31],stw[0:31];reg [11:0] stra[0:31],stwa[0:31];
 reg [31:0] stwd[0:31];wire [31:0] std[0:31];
 generate for(g=0;g<32;g=g+1)begin: softmax_tree
  attention_tile_bank #(.DEPTH(256)) ram(.clk(ap_clk),.ce(ap_ce&&!ap_rst),.re(str[g]),.we(stw[g]),.ra(stra[g]),.wa(stwa[g]),.wd(stwd[g]),.rd(std[g]));
 end endgenerate

 // Two fixed 32-stripe reservation queues; data are physical holding slots,
 // not a behavioral latency oracle. Return validity is delayed with actual CE.
 reg [1:0] mq_state[0:31],aq_state[0:31];
 reg [31:0] mq_data[0:31][0:15],aq_data[0:31][0:15];
 reg [2:0] mq_type[0:31],aq_type[0:31];
 reg [3:0] mq_dot[0:31],aq_dot[0:31];
 reg [4:0] mq_row[0:31],aq_row[0:31];
 reg [10:0] mq_key[0:31],aq_key[0:31];
 reg [5:0] mq_stripe[0:31],aq_stripe[0:31];
 reg [3:0] aq_level[0:31];reg [4:0] aq_lanes[0:31];
 reg [1:0] aq_workers[0:31][0:3];
 reg [4:0] mq_wp,mq_rp,aq_wp,aq_rp;
 reg m_read_valid,a_read_valid,d_read_valid;
 reg [4:0] m_read_q,a_read_q;
 reg [2:0] m_read_type,a_read_type;
 reg [3:0] m_read_dot,a_read_dot;
 reg [4:0] m_read_row,a_read_row;
 reg [10:0] m_read_key,a_read_key;
 reg [5:0] m_read_stripe,a_read_stripe;
 reg [3:0] a_read_level;reg [4:0] a_read_lanes;
 reg [31:0] m_direct_a[0:15],m_direct_b[0:15],a_direct_a[0:15],a_direct_b[0:15];
 wire [31:0] mo[0:15],ao[0:15],do_[0:3];
 reg [31:0] ma[0:15],mb[0:15],aa[0:15],ab[0:15],da[0:3],db[0:3];
 reg [13:0] mv;reg [5:0] av;reg [11:0] dv;
 reg [4:0] mtag[0:13],atag[0:5];
 reg [4:0] dtag[0:11][0:3];
 reg [3:0] d_read_lanes;
 reg [4:0] d_read_q[0:3];reg [10:0] d_read_key[0:3];
 reg [1:0] dq_state[0:3][0:31];reg [31:0] dq_data[0:3][0:31];
 reg [4:0] dq_row[0:3][0:31],dq_wp[0:3],dq_rp[0:3];
 reg [10:0] dq_key[0:3][0:31];
 generate for(g=0;g<16;g=g+1)begin: pool
  attention_tile_ce_tanh_libm_stream_leaf_stream_mul_node_14_s mul(.ap_clk(ap_clk),.ap_rst(ap_rst),.ap_ce(gce),.laya_global_ce(gce),.a(ma[g]),.b(mb[g]),.ap_return(mo[g]));
  attention_tile_ce_tanh_libm_stream_leaf_stream_add_node_0_s add(.ap_clk(ap_clk),.ap_rst(ap_rst),.ap_ce(gce),.laya_global_ce(gce),.a(aa[g]),.b(ab[g]),.ap_return(ao[g]));
 end
 for(g=0;g<4;g=g+1)begin: div_pool
  attention_tile_ce_tanh_libm_stream_leaf_stream_div_node_0_s div(.ap_clk(ap_clk),.ap_rst(ap_rst),.ap_ce(gce),.laya_global_ce(gce),.a(da[g]),.b(db[g]),.ap_return(do_[g]));
 end endgenerate
 // Dot states: fill, tree, scale, mask subtract, pad multiply, optional bias,
 // final add, score write, retired. Each dependency changes only on commit.
 reg [3:0] dot_state[0:15],dot_level[0:15];
 reg [2:0] dot_prod_issue[0:15],dot_prod_commit[0:15];
 reg [2:0] dot_tree_issue[0:15],dot_tree_commit[0:15];
 reg [4:0] dot_row[0:15];reg [10:0] dot_key[0:15];
 reg [31:0] dot_root[0:15],dot_scaled[0:15],dot_pad[0:15],dot_bias[0:15],dot_final[0:15];
 reg [31:0] qk_group,qk_written;reg [4:0] group_row;reg [10:0] group_key;
 reg [4:0] sm_row;reg [10:0] scan_key,exp_key,exp_written,norm_key,norm_written;
 reg max_pending;reg [10:0] max_key;
 reg [3:0] sm_level;reg [10:0] sm_width,tree_issue,tree_commit;
 reg [1:0] worker_state[0:3];reg worker_launch[0:3];
 reg [31:0] worker_x[0:3],worker_y[0:3];reg [10:0] worker_key[0:3];
 // One same-row ASUB batch may be prepared while the four original EXP
 // workers are busy. These four private values are never published as EXP.
 reg [31:0] staged_x[0:3];reg [10:0] staged_key[0:3];
 reg [2:0] staged_count,staged_cursor;reg staged_pending;
 reg [3:0] staged_dispatch;reg [1:0] staged_slot[0:3];integer staged_take;
 wire [3:0] exp_done,exp_idle,exp_ready;
 wire [31:0] exp_out[0:3];
 generate for(g=0;g<4;g=g+1)begin: exp_pool
  laya_attention_service_attention_exp_bits kernel(.ap_clk(ap_clk),.ap_rst(ap_rst),.ap_ce(ap_ce),.laya_global_ce(gce),
   .ap_start(worker_launch[g]),.ap_done(exp_done[g]),.ap_idle(exp_idle[g]),.ap_ready(exp_ready[g]),.x(worker_x[g]),.ap_return(exp_out[g]));
 end endgenerate
 reg [31:0] av_issue,av_committed,zero_index;reg [10:0] av_key;reg [4:0] av_row;reg [1:0] av_stripe;
 reg ybusy[0:15][0:3];
 // Machine-visible real service counters. They do not control numerical data.
 reg [63:0] m_accept,a_accept,d_accept,exp_accept,exp_return;
 reg [63:0] m_credit_stall,a_credit_stall,exp_hold_stall,av_busy_stall;
 reg [5:0] m_occupancy,a_occupancy,m_peak,a_peak;
 integer i,j,z,lev,b,addr;
 integer msel,asel,wsel,alcount,subcount,nodes;
 reg m_req,a_req,d_req;
 reg [2:0] m_req_type,a_req_type;
 reg [3:0] m_req_dot,a_req_dot,a_req_level;
 reg [4:0] m_req_row,a_req_row;
 reg [10:0] m_req_key,a_req_key;
 reg [5:0] m_req_stripe,a_req_stripe;
 reg [4:0] a_req_lanes;
 reg [31:0] m_req_a[0:15],m_req_b[0:15],a_req_a[0:15],a_req_b[0:15];
 reg [1:0] sub_worker[0:3];
 reg m_retire,a_retire,exp_retire;
 reg [31:0] max_candidate;
 reg config_bad,load_ok;
 wire queues_empty=(mq_wp==mq_rp)&&(aq_wp==aq_rp)&&!m_read_valid&&!a_read_valid&&mv==0&&av==0;
 always @* begin
  config_bad=bind_count!=55||(index!=64&&index!=128&&index!=256&&index!=512&&index!=1024)||
   payload[15:0]>=index||payload[23:16]>=16||payload[31:25]!=0||binding[4][31:16]!=index||binding[4][15:0]!=1||
   payload[15:0]<binding[23][15:0]||payload[15:0]>=binding[23][15:0]+binding[23][23:16]||
   binding[23]!=binding[27]||binding[23]!=binding[31]||binding[22][7:0]!=8'h50||binding[26][7:0]!=8'h51||binding[30][7:0]!=8'h52||
   binding[22][31:8]!=binding[26][31:8]||binding[22][31:8]!=binding[30][31:8]||
   (binding[22][15:8]!=2&&binding[22][15:8]!=4)||binding[22][31:24]!=0||binding[24]!=0||binding[28]!=0||binding[32]!=0||
   binding[23][23:16]==0||binding[23][23:16]>16||binding[23][15:0]+binding[23][23:16]>index||
   binding[33]!=32'h25||binding[36]!=32'h26||binding[39]!=32'h26||binding[42]!=32'h28||binding[45]!=8||binding[48]!=5||binding[51]!=32'h105||
   binding[40]!=binding[37]+1||binding[54][7:0]!=payload[23:16]||binding[54][8]!=payload[24]||
   payload[24]!=(binding[22][15:8]==2&&binding[22][23:16]%3!=0)||phase==6;
  for(i=0;i<7;i=i+1)if(binding[35+3*i]!=0||binding[34+3*i]==0)config_bad=1;
  load_ok=state==IDLE&&ap_start&&epoch==bound_epoch&&epoch!=0&&phase==1;
  m_req=0;a_req=0;d_req=0;m_retire=0;a_retire=0;exp_retire=0;
  m_req_type=0;a_req_type=0;m_req_dot=0;a_req_dot=0;m_req_row=0;a_req_row=0;m_req_key=0;a_req_key=0;
  m_req_stripe=0;a_req_stripe=0;a_req_level=0;a_req_lanes=0;
  msel=-1;asel=-1;wsel=-1;alcount=0;subcount=0;nodes=0;max_candidate=maximum[sm_row];
  staged_take=0;staged_dispatch=0;
  for(i=0;i<4;i=i+1)staged_slot[i]=0;
  for(i=0;i<16;i=i+1)begin
   kr[i]=0;kw[i]=0;vr[i]=0;vw[i]=0;qr[i]=0;qw[i]=0;yr[i]=0;yw[i]=0;sr[i]=0;sw[i]=0;pr[i]=0;pw[i]=0;er[i]=0;ew[i]=0;
   kra[i]=0;kwa[i]=0;vra[i]=0;vwa[i]=0;qra[i]=0;qwa[i]=0;yra[i]=0;ywa[i]=0;sra[i]=0;swa[i]=0;pra[i]=0;pwa[i]=0;era[i]=0;ewa[i]=0;
   kwd[i]=payload;vwd[i]=payload;qwd[i]=payload;ywd[i]=0;swd[i]=0;pwd[i]=0;ewd[i]=0;
   m_req_a[i]=0;m_req_b[i]=0;a_req_a[i]=0;a_req_b[i]=0;
   ma[i]=0;mb[i]=0;aa[i]=0;ab[i]=0;
  end
  for(lev=0;lev<7;lev=lev+1)for(b=0;b<32;b=b+1)begin tr[lev][b]=0;tw[lev][b]=0;tra[lev][b]=0;twa[lev][b]=0;twd[lev][b]=0;end
  for(b=0;b<32;b=b+1)begin str[b]=0;stw[b]=0;stra[b]=0;stwa[b]=0;stwd[b]=0;end
  for(i=0;i<4;i=i+1)begin da[i]=0;db[i]=total[sm_row];sub_worker[i]=0;end
  // A command's RAM write is committed on its real launch edge.
  if(load_ok)begin
   if(command==4&&index==nk&&index<S*64&&finite(payload))begin kw[index%16]=1;kwa[index%16]=index/16;end
   if(command==5&&index==nv&&index<S*64&&finite(payload))begin vw[index%16]=1;vwa[index%16]=index/16;end
   if(command==18&&index==nq&&index<rows*64)begin qw[index%16]=1;qwa[index%16]=index/16;end
  end
  if(state==IDLE&&ap_start&&epoch==bound_epoch&&epoch!=0)begin
   if(command==10&&phase>=2&&phase<=4&&index<S)begin sr[index%16]=1;sra[index%16]=(query-row0)*64+index/16;end
   if(command==11&&phase>=3&&phase<=4&&index<S)begin pr[index%16]=1;pra[index%16]=(query-row0)*64+index/16;end
   if(command==12&&phase==4&&index<64)begin yr[index%16]=1;yra[index%16]=(query-row0)*4+index/16;end
   if(command==14&&phase>=3&&phase<=4&&index<S&&scratch_valid[(query-row0)%8]&&scratch_row[(query-row0)%8]==query-row0)begin er[index%16]=1;era[index%16]=((query-row0)%8)*64+index/16;end
  end
  if(state==QK)begin
   // Oldest eligible dot, lowest unfinished dependency/stripe.
   for(i=15;i>=0;i=i-1)begin
    if((dot_state[i]==1&&dot_prod_issue[i]<4)||dot_state[i]==3||dot_state[i]==5)msel=i;
    if((dot_state[i]==2&&dot_tree_issue[i]<((dot_level[i]==0)?2:1))||dot_state[i]==4||dot_state[i]==6||dot_state[i]==7)asel=i;
   end
   if(msel>=0&&mq_state[mq_wp]==0)begin
    m_req=1;m_req_dot=msel;m_req_row=dot_row[msel];m_req_key=dot_key[msel];
    if(dot_state[msel]==1)begin m_req_type=MPROD;m_req_stripe=dot_prod_issue[msel];
     for(i=0;i<16;i=i+1)begin qr[i]=1;qra[i]=dot_row[msel]*4+dot_prod_issue[msel];kr[i]=1;kra[i]=dot_key[msel]*4+dot_prod_issue[msel];end
    end else if(dot_state[msel]==3)begin m_req_type=MSCALE;m_req_a[0]=dot_root[msel];m_req_b[0]=32'h3e000000;end
    else begin m_req_type=MPAD;m_req_a[0]=dot_pad[msel];m_req_b[0]=32'h461c4000;end
   end
   if(asel>=0&&aq_state[aq_wp]==0)begin
    a_req=1;a_req_dot=asel;a_req_row=dot_row[asel];a_req_key=dot_key[asel];
    if(dot_state[asel]==2)begin
     a_req_type=ATREE;a_req_level=dot_level[asel];a_req_stripe=dot_tree_issue[asel];
     nodes=(64>>dot_level[asel])/2;a_req_lanes=nodes>=16?16:nodes;
     for(i=0;i<32;i=i+1)if(i<2*a_req_lanes)begin
      addr=dot_tree_issue[asel]*32+i;b=addr%32;
      tr[dot_level[asel]][b]=1;tra[dot_level[asel]][b]=asel*(dot_level[asel]==0?2:1)+addr/32;
     end
    end else begin
     a_req_lanes=1;
     if(dot_state[asel]==4)begin a_req_type=AMASK;a_req_a[0]=mask[dot_key[asel]]?32'h3f800000:0;a_req_b[0]=32'hbf800000;end
     else if(dot_state[asel]==6)begin a_req_type=ABIAS;a_req_b[0]=dot_pad[asel];a_req_a[0]=((row0+dot_row[asel]>dot_key[asel]?row0+dot_row[asel]-dot_key[asel]:dot_key[asel]-row0-dot_row[asel])>64)?32'hc61c4000:0;end
     else begin a_req_type=AFINAL;a_req_a[0]=dot_scaled[asel];a_req_b[0]=dot_bias[asel];end
    end
   end
  end
  if(state==SM_MAX)begin
   if(scan_key<S)for(i=0;i<8;i=i+1)begin sr[(scan_key+i)%16]=1;sra[(scan_key+i)%16]=sm_row*64+(scan_key+i)/16;end
   if(max_pending)for(i=0;i<8;i=i+1)if(max_key+i<S&&greater(sd[(max_key+i)%16],max_candidate))max_candidate=sd[(max_key+i)%16];
  end
  if(state==SM_EXP)begin
   if(!staged_pending&&staged_count==0&&exp_key<S&&aq_state[aq_wp]==0)begin
    subcount=S-exp_key>=4?4:S-exp_key;
    a_req=1;a_req_type=ASUB;a_req_row=sm_row;a_req_key=exp_key;a_req_lanes=subcount;
    for(i=0;i<4;i=i+1)if(i<subcount)begin sr[(exp_key+i)%16]=1;sra[(exp_key+i)%16]=sm_row*64+(exp_key+i)/16;end
   end
   for(i=0;i<4;i=i+1)if(worker_state[i]==0&&!worker_launch[i]&&staged_take<staged_count)begin
    staged_dispatch[i]=1;staged_slot[i]=(staged_cursor+staged_take)&3;staged_take=staged_take+1;
   end
   for(i=3;i>=0;i=i-1)if(worker_state[i]==3)wsel=i;
   if(wsel>=0)begin
    exp_retire=1;ew[worker_key[wsel]%16]=1;ewa[worker_key[wsel]%16]=(sm_row%8)*64+worker_key[wsel]/16;ewd[worker_key[wsel]%16]=finite(worker_y[wsel])?worker_y[wsel]:0;
    stw[worker_key[wsel]%32]=1;stwa[worker_key[wsel]%32]=(sm_row%8)*32+worker_key[wsel]/32;stwd[worker_key[wsel]%32]=finite(worker_y[wsel])?worker_y[wsel]:0;
   end
  end
  if(state==SM_TREE&&tree_issue<(sm_width/2+15)/16&&aq_state[aq_wp]==0)begin
   a_req=1;a_req_type=ASMTREE;a_req_row=sm_row;a_req_level=sm_level;a_req_stripe=tree_issue;
   nodes=sm_width/2-tree_issue*16;a_req_lanes=nodes>=16?16:nodes;
   for(i=0;i<32;i=i+1)if(i<2*a_req_lanes)begin addr=tree_issue*32+i;str[addr%32]=1;stra[addr%32]=(sm_row%8)*32+addr/32;end
  end
  if(state==SM_DIV&&norm_key<S)begin
   d_req=1;for(i=0;i<4;i=i+1)if(dq_state[i][dq_wp[i]]!=0)d_req=0;
   if(d_req)for(i=0;i<4;i=i+1)begin er[(norm_key+i)%16]=1;era[(norm_key+i)%16]=(sm_row%8)*64+(norm_key+i)/16;end
  end
  if(state==AV_ZERO)for(i=0;i<16;i=i+1)begin yw[i]=1;ywa[i]=zero_index;end
  if(state==AV&&av_key<S&&mq_state[mq_wp]==0)begin
   m_req=1;m_req_type=MAV;m_req_key=av_key;m_req_row=av_row;m_req_stripe=av_stripe;
   pr[m_req_key%16]=1;pra[m_req_key%16]=m_req_row*64+m_req_key/16;
   for(i=0;i<16;i=i+1)begin vr[i]=1;vra[i]=m_req_key*4+m_req_stripe;end
  end
  // Oldest queue entries retire once, even when FP latency differs by mode.
  if(mq_state[mq_rp]==2)begin
   if(state==QK)begin
    m_retire=1;
    if(mq_type[mq_rp]==MPROD)for(i=0;i<16;i=i+1)begin addr=mq_stripe[mq_rp]*16+i;b=addr%32;tw[0][b]=1;twa[0][b]=mq_dot[mq_rp]*2+addr/32;twd[0][b]=finite(mq_data[mq_rp][i])?mq_data[mq_rp][i]:0;end
   end else if(state==AV&&aq_state[aq_wp]==0&&!ybusy[mq_row[mq_rp]][mq_stripe[mq_rp]])begin
    a_req=1;a_req_type=AAV;a_req_row=mq_row[mq_rp];a_req_key=mq_key[mq_rp];a_req_stripe=mq_stripe[mq_rp];a_req_lanes=16;
    for(i=0;i<16;i=i+1)begin yr[i]=1;yra[i]=mq_row[mq_rp]*4+mq_stripe[mq_rp];a_req_b[i]=finite(mq_data[mq_rp][i])?mq_data[mq_rp][i]:0;end
    m_retire=1;
   end
  end
  if(aq_state[aq_rp]==2)begin
   a_retire=1;
   if(aq_type[aq_rp]==ATREE)for(i=0;i<16;i=i+1)if(i<aq_lanes[aq_rp])begin addr=aq_stripe[aq_rp]*16+i;b=addr%32;tw[aq_level[aq_rp]+1][b]=1;twa[aq_level[aq_rp]+1][b]=aq_dot[aq_rp];twd[aq_level[aq_rp]+1][b]=finite(aq_data[aq_rp][i])?aq_data[aq_rp][i]:0;end
   if(aq_type[aq_rp]==ASMTREE)for(i=0;i<16;i=i+1)if(i<aq_lanes[aq_rp])begin addr=aq_stripe[aq_rp]*16+i;b=addr%32;stw[b]=1;stwa[b]=(aq_row[aq_rp]%8)*32+addr/32;stwd[b]=finite(aq_data[aq_rp][i])?aq_data[aq_rp][i]:0;end
   if(aq_type[aq_rp]==AAV)for(i=0;i<16;i=i+1)begin yw[i]=1;ywa[i]=aq_row[aq_rp]*4+aq_stripe[aq_rp];ywd[i]=finite(aq_data[aq_rp][i])?aq_data[aq_rp][i]:0;end
  end
  if(state==QK)for(i=0;i<16;i=i+1)if(dot_state[i]==8)begin
   // One score write per cycle; lexicographic slot order is deterministic.
   if(wsel<0)begin wsel=i;sw[dot_key[i]%16]=1;swa[dot_key[i]%16]=dot_row[i]*64+dot_key[i]/16;swd[dot_key[i]%16]=dot_final[i];end
  end
  if(state==SM_DIV)for(i=0;i<4;i=i+1)if(dq_state[i][dq_rp[i]]==2)begin
   pw[dq_key[i][dq_rp[i]]%16]=1;pwa[dq_key[i][dq_rp[i]]%16]=dq_row[i][dq_rp[i]]*64+dq_key[i][dq_rp[i]]/16;pwd[dq_key[i][dq_rp[i]]%16]=finite(dq_data[i][dq_rp[i]])?dq_data[i][dq_rp[i]]:0;
  end
  // Actual helpers capture operands one edge after a synchronous RAM request.
  if(m_read_valid)for(i=0;i<16;i=i+1)begin
   if(m_read_type==MPROD)begin ma[i]=qd[i];mb[i]=kd[i];end
   else if(m_read_type==MAV)begin ma[i]=pd[m_read_key%16];mb[i]=vd[i];end
   else begin ma[i]=m_direct_a[i];mb[i]=m_direct_b[i];end
  end
  if(a_read_valid)for(i=0;i<16;i=i+1)if(i<a_read_lanes)begin
   if(a_read_type==ATREE)begin aa[i]=td[a_read_level][(2*i)%32];ab[i]=td[a_read_level][(2*i+1)%32];end
   else if(a_read_type==ASMTREE)begin aa[i]=std[(2*i)%32];ab[i]=std[(2*i+1)%32];end
   else if(a_read_type==ASUB)begin aa[i]=sd[(a_read_key+i)%16];ab[i]=maximum[a_read_row]^32'h80000000;end
   else if(a_read_type==AAV)begin aa[i]=yd[i];ab[i]=a_direct_b[i];end
   else begin aa[i]=a_direct_a[i];ab[i]=a_direct_b[i];end
  end
  if(d_read_valid)for(i=0;i<4;i=i+1)begin da[i]=ed[d_read_key[i]%16];db[i]=total[sm_row];end
 end

 // Tags/queues and real arithmetic capture/commit are all globally frozen.
 integer si,sj;
 reg [63:0] rank;
 reg [31:0] element;
 integer returned_norm,active_dots;
 always @(posedge ap_clk)begin
  if(ap_rst)begin
   state<=IDLE;phase<=0;bound_epoch<=0;bind_count<=0;S<=0;query<=0;row0<=0;rows<=0;head<=0;sliding<=0;
   result<=0;status<=0;nq<=0;nk<=0;nv<=0;nmask<=0;
   q_bad_valid<=0;q_bad_index<=0;qk_target_rows<=0;
   err_valid=0;err_rank=0;err_element=0;
   mq_wp<=0;mq_rp<=0;aq_wp<=0;aq_rp<=0;mv<=0;av<=0;dv<=0;
   m_read_valid<=0;a_read_valid<=0;d_read_valid<=0;max_pending<=0;
   m_accept<=0;a_accept<=0;d_accept<=0;exp_accept<=0;exp_return<=0;m_credit_stall<=0;a_credit_stall<=0;exp_hold_stall<=0;av_busy_stall<=0;
   m_occupancy<=0;a_occupancy<=0;m_peak<=0;a_peak<=0;
   sm_row<=0;scan_key<=0;exp_key<=0;exp_written<=0;norm_key<=0;norm_written<=0;sm_width<=0;sm_level<=0;tree_issue<=0;tree_commit<=0;
   staged_count<=0;staged_cursor<=0;staged_pending<=0;
   av_issue<=0;av_committed<=0;zero_index<=0;av_key<=0;av_row<=0;av_stripe<=0;qk_group<=0;qk_written<=0;group_row<=0;group_key<=0;
   for(si=0;si<32;si=si+1)begin mq_state[si]<=0;aq_state[si]<=0;end
   for(si=0;si<16;si=si+1)begin
    dot_state[si]<=0;dot_level[si]<=0;dot_prod_issue[si]<=0;dot_prod_commit[si]<=0;dot_tree_issue[si]<=0;dot_tree_commit[si]<=0;
    maximum[si]<=0;total[si]<=0;for(sj=0;sj<4;sj=sj+1)ybusy[si][sj]<=0;
   end
   for(si=0;si<8;si=si+1)begin scratch_valid[si]<=0;scratch_row[si]<=0;end
   for(si=0;si<4;si=si+1)begin worker_state[si]<=0;worker_launch[si]<=0;worker_x[si]<=0;worker_y[si]<=0;worker_key[si]<=0;staged_x[si]<=0;staged_key[si]<=0;dq_wp[si]<=0;dq_rp[si]<=0;
    for(sj=0;sj<32;sj=sj+1)dq_state[si][sj]<=0;
   end
  end else if(ap_ce)begin
   m_read_valid<=m_req;a_read_valid<=a_req;d_read_valid<=d_req;
   mv<={mv[12:0],m_read_valid};av<={av[4:0],a_read_valid};dv<={dv[10:0],d_read_valid};
   mtag[0]<=m_read_q;atag[0]<=a_read_q;
   for(si=1;si<14;si=si+1)mtag[si]<=mtag[si-1];
   for(si=1;si<6;si=si+1)atag[si]<=atag[si-1];
   for(si=0;si<4;si=si+1)begin dtag[0][si]<=d_read_q[si];for(sj=1;sj<12;sj=sj+1)dtag[sj][si]<=dtag[sj-1][si];end
   if(m_read_valid)m_accept<=m_accept+(m_read_type==MPROD||m_read_type==MAV?16:1);
   if(a_read_valid)a_accept<=a_accept+a_read_lanes;
   if(d_read_valid)d_accept<=d_accept+4;
   if(m_req)begin
    mq_state[mq_wp]<=1;mq_type[mq_wp]<=m_req_type;mq_dot[mq_wp]<=m_req_dot;mq_row[mq_wp]<=m_req_row;mq_key[mq_wp]<=m_req_key;mq_stripe[mq_wp]<=m_req_stripe;
    m_read_q<=mq_wp;m_read_type<=m_req_type;m_read_dot<=m_req_dot;m_read_row<=m_req_row;m_read_key<=m_req_key;m_read_stripe<=m_req_stripe;
    for(si=0;si<16;si=si+1)begin m_direct_a[si]<=m_req_a[si];m_direct_b[si]<=m_req_b[si];end
    mq_wp<=mq_wp+1;
    if(state==QK)begin
     if(m_req_type==MPROD)dot_prod_issue[m_req_dot]<=dot_prod_issue[m_req_dot]+1;
     else dot_state[m_req_dot]<=9;
    end
    if(state==AV)begin av_issue<=av_issue+1;av_stripe<=av_stripe+1;
     if(av_stripe==3)begin if(av_row==rows-1)begin av_row<=0;av_key<=av_key+1;end else av_row<=av_row+1;end
    end
   end
   if(a_req)begin
    aq_state[aq_wp]<=1;aq_type[aq_wp]<=a_req_type;aq_dot[aq_wp]<=a_req_dot;aq_row[aq_wp]<=a_req_row;aq_key[aq_wp]<=a_req_key;aq_stripe[aq_wp]<=a_req_stripe;aq_level[aq_wp]<=a_req_level;aq_lanes[aq_wp]<=a_req_lanes;
    a_read_q<=aq_wp;a_read_type<=a_req_type;a_read_dot<=a_req_dot;a_read_row<=a_req_row;a_read_key<=a_req_key;a_read_stripe<=a_req_stripe;a_read_level<=a_req_level;a_read_lanes<=a_req_lanes;
    for(si=0;si<16;si=si+1)begin a_direct_a[si]<=a_req_a[si];a_direct_b[si]<=a_req_b[si];end
    aq_wp<=aq_wp+1;
    if(a_req_type==ATREE)dot_tree_issue[a_req_dot]<=dot_tree_issue[a_req_dot]+1;
    else if(state==QK)dot_state[a_req_dot]<=9;
    if(a_req_type==ASMTREE)tree_issue<=tree_issue+1;
    if(a_req_type==ASUB)begin
     exp_key<=exp_key+a_req_lanes;staged_pending<=1;
    end
    if(a_req_type==AAV)ybusy[a_req_row][a_req_stripe]<=1;
   end
   // Queue occupancy includes read stage, pipeline, and returned held payload.
   case({m_req,m_retire})2'b10:m_occupancy<=m_occupancy+1;2'b01:m_occupancy<=m_occupancy-1;default:;endcase
   case({a_req,a_retire})2'b10:a_occupancy<=a_occupancy+1;2'b01:a_occupancy<=a_occupancy-1;default:;endcase
   if(m_occupancy>m_peak)m_peak<=m_occupancy;if(a_occupancy>a_peak)a_peak<=a_occupancy;
   if((state==QK&&msel>=0||state==AV&&av_issue<S*rows*4)&&mq_state[mq_wp]!=0)m_credit_stall<=m_credit_stall+1;
   if((state==QK&&asel>=0||state==SM_TREE)&&aq_state[aq_wp]!=0)a_credit_stall<=a_credit_stall+1;
   if(state==AV&&mq_state[mq_rp]==2&&ybusy[mq_row[mq_rp]][mq_stripe[mq_rp]])av_busy_stall<=av_busy_stall+1;
   if(mv[13])begin mq_state[mtag[13]]<=2;for(si=0;si<16;si=si+1)mq_data[mtag[13]][si]<=mo[si];end
   if(av[5])begin aq_state[atag[5]]<=2;for(si=0;si<16;si=si+1)aq_data[atag[5]][si]<=ao[si];end
   if(m_retire)begin
    mq_state[mq_rp]<=0;mq_rp<=mq_rp+1;
    for(si=0;si<16;si=si+1)if((mq_type[mq_rp]==MPROD||mq_type[mq_rp]==MAV||si==0)&&!finite(mq_data[mq_rp][si]))begin
     if(state==QK)begin rank=(dot_row[mq_dot[mq_rp]]<<21)+1024+(dot_key[mq_dot[mq_rp]]<<10)+(mq_type[mq_rp]==MPROD?mq_stripe[mq_rp]*16+si:(mq_type[mq_rp]==MSCALE?512:514));element=mq_type[mq_rp]==MPROD?dot_key[mq_dot[mq_rp]]*64+mq_stripe[mq_rp]*16+si:dot_key[mq_dot[mq_rp]];end
     else begin rank=(mq_row[mq_rp]<<24)+((mq_stripe[mq_rp]*16+si)<<11)+(mq_key[mq_rp]<<1);element=mq_key[mq_rp]*64+mq_stripe[mq_rp]*16+si;end
     note_error(rank,element);
    end
    if(state==QK)begin
     if(mq_type[mq_rp]==MPROD)begin
      dot_prod_commit[mq_dot[mq_rp]]<=dot_prod_commit[mq_dot[mq_rp]]+1;
      if(dot_prod_commit[mq_dot[mq_rp]]==3)dot_state[mq_dot[mq_rp]]<=2;
     end else if(mq_type[mq_rp]==MSCALE)begin dot_scaled[mq_dot[mq_rp]]<=finite(mq_data[mq_rp][0])?mq_data[mq_rp][0]:0;dot_state[mq_dot[mq_rp]]<=4;end
     else begin dot_pad[mq_dot[mq_rp]]<=finite(mq_data[mq_rp][0])?mq_data[mq_rp][0]:0;
      dot_bias[mq_dot[mq_rp]]<=finite(mq_data[mq_rp][0])?mq_data[mq_rp][0]:0;dot_state[mq_dot[mq_rp]]<=sliding?6:7;end
    end
   end
   if(a_retire)begin
    aq_state[aq_rp]<=0;aq_rp<=aq_rp+1;
    for(si=0;si<16;si=si+1)if(si<aq_lanes[aq_rp]&&!finite(aq_data[aq_rp][si]))begin
     if(state==QK)begin rank=(aq_row[aq_rp]<<21)+1024+(aq_key[aq_rp]<<10)+(aq_type[aq_rp]==ATREE?64+aq_level[aq_rp]*64+aq_stripe[aq_rp]*16+si:(aq_type[aq_rp]==AMASK?513:(aq_type[aq_rp]==ABIAS?515:516)));element=aq_type[aq_rp]==ATREE?aq_key[aq_rp]*64+aq_stripe[aq_rp]*16+si:aq_key[aq_rp];end
     else if(state==AV)begin rank=(aq_row[aq_rp]<<24)+((aq_stripe[aq_rp]*16+si)<<11)+(aq_key[aq_rp]<<1)+1;element=aq_key[aq_rp]*64+aq_stripe[aq_rp]*16+si;end
     else begin rank=aq_row[aq_rp]*32768+(aq_type[aq_rp]==ASUB?2048+(aq_key[aq_rp]+si)*2:8192+aq_level[aq_rp]*1024+aq_stripe[aq_rp]*16+si);element=aq_type[aq_rp]==ASUB?aq_key[aq_rp]+si:aq_stripe[aq_rp]*16+si;end
     note_error(rank,element);
    end
    case(aq_type[aq_rp])
     ATREE:begin
      dot_tree_commit[aq_dot[aq_rp]]<=dot_tree_commit[aq_dot[aq_rp]]+1;
      if(dot_tree_commit[aq_dot[aq_rp]]==(aq_level[aq_rp]==0?1:0))begin
       dot_tree_issue[aq_dot[aq_rp]]<=0;dot_tree_commit[aq_dot[aq_rp]]<=0;
       if(aq_level[aq_rp]==5)begin dot_root[aq_dot[aq_rp]]<=finite(aq_data[aq_rp][0])?aq_data[aq_rp][0]:0;dot_state[aq_dot[aq_rp]]<=3;end
       else dot_level[aq_dot[aq_rp]]<=dot_level[aq_dot[aq_rp]]+1;
      end
     end
     AMASK:begin dot_pad[aq_dot[aq_rp]]<=finite(aq_data[aq_rp][0])?aq_data[aq_rp][0]:0;dot_state[aq_dot[aq_rp]]<=5;end
     ABIAS:begin dot_bias[aq_dot[aq_rp]]<=finite(aq_data[aq_rp][0])?aq_data[aq_rp][0]:0;dot_state[aq_dot[aq_rp]]<=7;end
     AFINAL:begin dot_final[aq_dot[aq_rp]]<=finite(aq_data[aq_rp][0])?aq_data[aq_rp][0]:0;dot_state[aq_dot[aq_rp]]<=8;end
     ASUB:begin
      // Retired ASUB lanes keep their original keys until a real worker is
      // available. The original A queue still validates and retires once.
      staged_pending<=0;staged_count<=aq_lanes[aq_rp];staged_cursor<=0;
      for(si=0;si<4;si=si+1)if(si<aq_lanes[aq_rp])begin
       staged_x[si]<=finite(aq_data[aq_rp][si])?aq_data[aq_rp][si]:0;
       staged_key[si]<=aq_key[aq_rp]+si;
      end
     end
     ASMTREE:begin tree_commit<=tree_commit+1;
      if(tree_commit==(sm_width/2+15)/16-1)begin
       tree_issue<=0;tree_commit<=0;
       if(sm_width==2)begin total[sm_row]<=finite(aq_data[aq_rp][0])?aq_data[aq_rp][0]:0;
        if(!finite(aq_data[aq_rp][0])||aq_data[aq_rp][0][31]||aq_data[aq_rp][0][30:0]==0)note_error(sm_row*32768+20480,0);
        norm_key<=0;norm_written<=0;
        if(!finite(aq_data[aq_rp][0])||aq_data[aq_rp][0][31]||aq_data[aq_rp][0][30:0]==0)complete_run(3);else state<=SM_DIV;
       end else begin sm_width<=sm_width/2;sm_level<=sm_level+1;end
      end
     end
     AAV:begin ybusy[aq_row[aq_rp]][aq_stripe[aq_rp]]<=0;av_committed<=av_committed+1;end
     default:;
    endcase
   end
   if(state==SM_EXP&&staged_take>0)begin
    staged_count<=staged_count-staged_take;staged_cursor<=staged_cursor+staged_take;
    for(si=0;si<4;si=si+1)if(staged_dispatch[si])begin
     worker_x[si]<=staged_x[staged_slot[si]];worker_key[si]<=staged_key[staged_slot[si]];
     worker_launch[si]<=1;worker_state[si]<=1;
    end
   end
   for(si=0;si<4;si=si+1)begin
    if(worker_launch[si])begin worker_launch[si]<=0;worker_state[si]<=2;end
    if(worker_state[si]==2&&exp_done[si])begin worker_y[si]<=exp_out[si];worker_state[si]<=3;end
   end
   if(worker_launch[0]||worker_launch[1]||worker_launch[2]||worker_launch[3])exp_accept<=exp_accept+worker_launch[0]+worker_launch[1]+worker_launch[2]+worker_launch[3];
   if(exp_retire)begin
    worker_state[wsel]<=0;exp_written<=exp_written+1;exp_return<=exp_return+1;
    if(!finite(worker_y[wsel]))note_error(sm_row*32768+2048+worker_key[wsel]*2+1,worker_key[wsel]);
    if(exp_written==S-1)begin state<=SM_TREE;sm_width<=S;sm_level<=0;tree_issue<=0;tree_commit<=0;end
   end
   if(state==SM_EXP)for(si=0;si<4;si=si+1)if(worker_state[si]==3&&si!=wsel)exp_hold_stall<=exp_hold_stall+1;
   if(d_req)begin
    norm_key<=norm_key+4;
    for(si=0;si<4;si=si+1)begin dq_state[si][dq_wp[si]]<=1;dq_key[si][dq_wp[si]]<=norm_key+si;dq_row[si][dq_wp[si]]<=sm_row;d_read_q[si]<=dq_wp[si];d_read_key[si]<=norm_key+si;dq_wp[si]<=dq_wp[si]+1;end
   end
   if(dv[11])for(si=0;si<4;si=si+1)begin dq_data[si][dtag[11][si]]<=do_[si];dq_state[si][dtag[11][si]]<=2;end
   returned_norm=0;
   if(state==SM_DIV)for(si=0;si<4;si=si+1)if(dq_state[si][dq_rp[si]]==2)begin
    returned_norm=returned_norm+1;dq_state[si][dq_rp[si]]<=0;dq_rp[si]<=dq_rp[si]+1;
    if(!finite(dq_data[si][dq_rp[si]]))note_error(sm_row*32768+21504+dq_key[si][dq_rp[si]],dq_key[si][dq_rp[si]]);
   end
   if(returned_norm!=0)begin
    norm_written<=norm_written+returned_norm;
    if(norm_written+returned_norm==S)begin
     if(sm_row==rows-1)complete_run(3);
     else begin sm_row<=sm_row+1;maximum[sm_row+1]<=32'hff7fffff;scan_key<=0;max_pending<=0;state<=SM_MAX;scratch_valid[(sm_row+1)%8]<=1;scratch_row[(sm_row+1)%8]<=sm_row+1;end
    end
   end
   if(state==SM_MAX)begin
    max_pending<=scan_key<S;
    if(scan_key<S)begin max_key<=scan_key;scan_key<=scan_key+8;end
    if(max_pending)begin
     maximum[sm_row]<=max_candidate;
     for(si=0;si<8;si=si+1)if(!finite(sd[(max_key+si)%16]))note_error(sm_row*32768+max_key+si,max_key+si);
     if(max_key+8==S)begin state<=SM_EXP;exp_key<=0;exp_written<=0;staged_count<=0;staged_cursor<=0;staged_pending<=0;end
    end
   end
   if(state==QK&&wsel>=0)begin dot_state[wsel]<=10;qk_written<=qk_written+1;end
   if(state==QK)begin
    active_dots=0;for(si=0;si<16;si=si+1)if(dot_state[si]!=10)active_dots=active_dots+1;
    if(active_dots==0&&queues_empty)begin
     if(qk_written==S*qk_target_rows)complete_run(2);
     else begin qk_group<=qk_group+16;
      if(group_key+16==S)begin group_row<=group_row+1;group_key<=0;end else group_key<=group_key+16;
      for(si=0;si<16;si=si+1)begin dot_state[si]<=1;dot_row[si]<=group_key+16==S?group_row+1:group_row;dot_key[si]<=group_key+16==S?si:group_key+16+si;dot_prod_issue[si]<=0;dot_prod_commit[si]<=0;dot_tree_issue[si]<=0;dot_tree_commit[si]<=0;dot_level[si]<=0;end
     end
    end
   end
   if(state==AV_ZERO)begin
    zero_index<=zero_index+1;if(zero_index==rows*4-1)state<=AV;
   end
   if(state==AV&&av_committed==S*rows*4&&queues_empty)complete_run(4);
   if(state==REPORT&&ap_continue)state<=IDLE;
   if(state==READ)begin
    case(selected_cmd)
     10:result<=sd[selected_index%16];11:result<=pd[selected_index%16];12:result<=yd[selected_index%16];14:result<=ed[selected_index%16];default:result<=0;
    endcase
    state<=REPORT;
   end
   if(state==IDLE&&ap_start)begin
    result<=0;status<=0;state<=REPORT;
    if(command==0||command==16)begin
     if(command==16&&epoch!=bound_epoch)status<=2;
     else begin bound_epoch<=epoch;bind_count<=0;phase<=0;S<=0;nq<=0;nk<=0;nv<=0;nmask<=0;q_bad_valid<=0;q_bad_index<=0;qk_target_rows<=0;for(si=0;si<8;si=si+1)scratch_valid[si]<=0;end
    end else if(epoch!=bound_epoch||epoch==0)status<=2;
    else if(command==1)begin if(phase!=0||index!=bind_count||index>=55)status<=2;else begin binding[index]<=payload;bind_count<=bind_count+1;end end
    else if(command==17)begin if(index>=bind_count)status<=2;else result<=binding[index];end
    else if(command==2)begin
     if(config_bad)status<=2;
     else begin S<=index[10:0];query<=payload[10:0];row0<=binding[23][10:0];rows<=binding[23][20:16];head<=payload[19:16];sliding<=payload[24];if(phase==0)phase<=1;end
    end else if(command==4||command==5||command==6||command==18)begin
     if(phase!=1)status<=2;
     else if(command==6)begin if(index!=nmask||index>=S||payload>1)status<=2;else begin mask[index]<=payload;nmask<=nmask+1;end end
     else if((command==18&&(index!=nq||index>=rows*64))||(command==4&&(index!=nk||index>=S*64))||(command==5&&(index!=nv||index>=S*64)))status<=2;
     else if(command==18)begin
      nq<=nq+1;
      if(!finite(payload)&&!q_bad_valid)begin q_bad_valid<=1;q_bad_index<=index[9:0];end
     end else if(!finite(payload))begin status<=1;result<=index;phase<=6;end
     else if(command==4)nk<=nk+1;else nv<=nv+1;
    end else if(command==19)begin
     if(index!=0||payload!=0||phase!=1||nq!=rows*64||nk!=S*64||nv!=S*64||nmask!=S)status<=2;
     else begin err_valid=0;err_rank=0;err_element=0;qk_group<=0;qk_written<=0;group_row<=0;group_key<=0;
      qk_target_rows<=q_bad_valid?{1'b0,q_bad_index[9:6]}:rows;
      if(q_bad_valid)note_error(({54'b0,q_bad_index}>>6)*64'd2097152+q_bad_index[5:0],{26'b0,q_bad_index[5:0]});
      if(q_bad_valid&&q_bad_index<64)complete_run(2);
      else begin state<=QK;
       for(si=0;si<16;si=si+1)begin dot_state[si]<=1;dot_row[si]<=0;dot_key[si]<=si;dot_prod_issue[si]<=0;dot_prod_commit[si]<=0;dot_tree_issue[si]<=0;dot_tree_commit[si]<=0;dot_level[si]<=0;end
      end
     end
    end else if(command==20)begin
     if(index!=0||payload!=0||phase!=2||!queues_empty)status<=2;
     else begin state<=SM_MAX;err_valid=0;err_rank=0;err_element=0;sm_row<=0;scan_key<=0;max_pending<=0;maximum[0]<=32'hff7fffff;scratch_valid[0]<=1;scratch_row[0]<=0;end
    end else if(command==21)begin
     if(index!=0||payload!=0||phase!=3||!queues_empty)status<=2;
     else begin state<=AV_ZERO;err_valid=0;err_rank=0;err_element=0;zero_index<=0;av_issue<=0;av_committed<=0;av_key<=0;av_row<=0;av_stripe<=0;end
    end else if(command==13||command==15)begin
     if(phase<3||phase>4||!scratch_valid[(query-row0)%8]||scratch_row[(query-row0)%8]!=query-row0)status<=2;
     else result<=command==13?maximum[query-row0]:total[query-row0];
    end else if((command==10&&phase>=2&&phase<=4&&index<S)||(command==11&&phase>=3&&phase<=4&&index<S)||(command==12&&phase==4&&index<64)||
      (command==14&&phase>=3&&phase<=4&&index<S&&scratch_valid[(query-row0)%8]&&scratch_row[(query-row0)%8]==query-row0))begin selected_cmd<=command;selected_index<=index;state<=READ;end
    else status<=2;
   end
  end
 end
endmodule
