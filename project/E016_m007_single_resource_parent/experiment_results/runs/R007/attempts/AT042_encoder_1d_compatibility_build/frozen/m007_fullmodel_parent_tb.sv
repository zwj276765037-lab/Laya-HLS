`timescale 1ns/1ps
module m007_fullmodel_parent_tb;
 logic clk;
 logic rst_n;
 logic setup_valid;
 logic setup_ready;
 logic [63:0] setup_request;
 logic [31:0] setup_generation;
 logic [127:0] setup_build_id;
 logic [127:0] setup_table_key;
 logic [255:0] setup_model_sha256;
 logic [255:0] setup_graph_sha256;
 logic [255:0] setup_numeric_sha256;
 logic [255:0] setup_layout_sha256;
 logic [255:0] setup_package_build_sha256;
 logic [63:0] setup_catalog_base;
 logic [63:0] setup_catalog_span;
 logic [255:0] setup_records_sha256;
 logic [63:0] setup_records_crc;
 logic invalidate_valid;
 logic invalidate_ready;
 logic [63:0] invalidate_request;
 logic [31:0] invalidate_generation;
 logic [127:0] invalidate_build_id;
 logic model_word_valid;
 logic model_word_ready;
 logic [63:0] model_word_request;
 logic [31:0] model_word_generation;
 logic [1:0] model_word_kind;
 logic [9:0] model_word_index;
 logic [31:0][31:0] model_word_data;
 logic model_committed;
 logic [1:0] done_op;
 logic reject_valid;
 logic [2:0] reject_port;
 logic [7:0] reject_code;
 logic [95:0] reject_tuple;
 logic [1:0] cmd_qtype;
 logic [15:0][31:0] cmd_marker_rows;
 logic [15:0] cmd_marker_mask;
 logic [4:0] cmd_candidate_count;
 logic tail_begin_valid;
 logic tail_begin_ready;
 logic [63:0] tail_request;
 logic [31:0] tail_generation;
 logic [31:0] tail_source_epoch;
 logic [31:0] tail_expected_bytes;
 logic tail_commit_valid;
 logic tail_commit_ready;
 logic [63:0] tail_commit_request;
 logic [31:0] tail_commit_generation;
 logic [31:0] tail_commit_source_epoch;
 logic [31:0] tail_commit_bytes;
 logic [7:0] tail_commit_status;
 logic tail_abort_valid;
 logic tail_abort_ready;
 logic tail_owner_idle;
 logic cmd_valid;
 logic cmd_ready;
 logic [63:0] cmd_request;
 logic [31:0] cmd_generation;
 logic [31:0] cmd_epoch;
 logic [127:0] cmd_model_id;
 logic [127:0] cmd_numeric_id;
 logic [127:0] cmd_table_key;
 logic [127:0] cmd_graph_id;
 logic [127:0] cmd_layout_id;
 logic [127:0] cmd_build_id;
 logic [2:0] cmd_kind;
 logic [4:0] cmd_layer;
 logic [127:0] cmd_mask;
 logic in_valid;
 logic in_ready;
 logic [31:0][31:0] in_data;
 logic [63:0] in_request;
 logic [31:0] in_generation;
 logic [31:0] in_epoch;
 logic [7:0] in_row;
 logic [7:0] in_group;
 logic producer_fail_valid;
 logic [7:0] producer_fail_code;
 logic [79:0] producer_fail_detail;
 logic [63:0] producer_fail_request;
 logic [31:0] producer_fail_generation;
 logic [31:0] producer_fail_epoch;
 logic producer_fail_ready;
 logic out_valid;
 logic out_ready;
 logic [31:0][31:0] out_data;
 logic [6:0] out_row;
 logic [15:0] out_col;
 logic [4:0] out_slot;
 logic done_valid;
 logic done_ready;
 logic [7:0] done_status;
 logic [2:0] error_domain;
 logic [95:0] error_tuple;
 logic [7:0] source_status;
 logic [63:0] done_request;
 logic [31:0] done_generation;
 logic [31:0] done_epoch;
 logic [6:0] parent_state;
 logic [31:0] elapsed_cycles;
 logic [15:0] layer_head_completed;
 logic coeff_bind_valid;
 logic coeff_bind_ready;
 logic [127:0] coeff_bind_model_id;
 logic [127:0] coeff_bind_numeric_id;
 logic [127:0] coeff_bind_table_key;
 logic coeff_bound_valid;
 logic [127:0] coeff_bound_model_id;
 logic [127:0] coeff_bound_numeric_id;
 logic [127:0] coeff_bound_table_key;
 logic [1:0] coeff_family_complete;
 logic coeff_wr_valid;
 logic coeff_wr_ready;
 logic [127:0] coeff_wr_model_id;
 logic [127:0] coeff_wr_numeric_id;
 logic [127:0] coeff_wr_table_key;
 logic [1:0] coeff_wr_table;
 logic [6:0] coeff_wr_row;
 logic coeff_wr_half;
 logic [31:0][31:0] coeff_wr_data;
 logic coeff_wr_reject_valid;
 logic [2:0] coeff_wr_reject_code;
 logic [4:0] coeff_wr_nonfinite_lane;
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
 localparam logic[255:0] PLATFORM_SHA=256'hf0df35cc7013643161e135ae0949473a9b5c0f13d5a4e3aea3675c2cf607db18;
 laya_m007_single_parent_v3 #(.ADDRESS_PROFILE(1),.HBM_PORT_BASE(0),.HBM_PORT_SPAN({4{64'h100000000}}),.PLATFORM_MANIFEST_SHA256(PLATFORM_SHA)) dut(.*);
 always #1 clk=~clk;
 logic[511:0]catalog_mem[0:127];logic[31:0]bias_mem[0:18431],gamma_mem[0:1023],type_mem[0:3071];
 logic[31:0]rope_mem[0:3][0:8191];logic[1023:0]original_h[0:4095];
 integer cycle=0,checked=0,mode=0,ar_count=0,r_count=0,model_count=0,h_count=0,catalog_runtime=0;
 integer bus_word=0,held_word=0;logic pending=0,drain_pending=0,fault_injected=0,response_consumed=0;
 string data_dir,rope_dir,h_path,matrix_dir;
 logic[511:0]w_mem0[0:13823],w_mem1[0:13823],w_mem2[0:13823],w_mem3[0:13823];
 logic[1023:0]qkv_gold[0:12287];logic[271:0]a_gold[0:4095];
 logic[7:0]w_live[0:3];logic[63:0]w_address[0:3][0:7];
 integer w_length[0:3][0:7],w_pos[0:3][0:7],w_rotate[0:3];logic[3:0]w_last_fire;
 integer qkv_outputs=0,a_writes=0,a_acks=0,matrices=0,begin_cycle=0;
 integer stop_qkv_blocks=3,stop_after_head=0,matrix_begin_cycle=0,qkv_retire_count=0;
 integer qkv_count=0,nrope=0,nscore=0,nprob=0,ncontext=0,nprob_ack=0,nheads=0,head_start_cycle=-1,layer_starts=0;
 integer head_score[0:15],head_prob[0:15],head_context[0:15],head_prob_ack[0:15],head_maximum[0:15];
 logic[15:0]max_checked=0;
 logic[31:0]qkvgold[0:393215],postgold[0:393215],scoregold[0:262143],maxgold[0:2047],probgold[0:262143],contextgold[0:131071];
 function automatic logic[511:0]w_word(input int p,idx);
  case(p)0:return w_mem0[idx];1:return w_mem1[idx];2:return w_mem2[idx];default:return w_mem3[idx];endcase
 endfunction
 logic[63:0]held_addr;logic held_ar=0;
 // SIM D2H peer writes accepted data into a separately owned target. Commit
 // qualifies actual writes; independent numerical comparison is a later step.
 logic[31:0][31:0]tail_target[0:543];integer tail_writes=0,tail_bytes_written=0;
 logic tail_active=0;integer tail_delay=0;
 assign tail_begin_ready=!tail_active&&!tail_commit_valid;
 assign tail_abort_ready=tail_delay==0&&!tail_commit_valid;
 assign tail_owner_idle=!tail_active&&!tail_commit_valid;
 always@(posedge clk)if(rst_n)begin
  if(tail_begin_valid&&tail_begin_ready)begin if(tail_expected_bytes!=69632)$fatal(1,"SIM peer expected bytes");tail_active<=1;tail_writes<=0;tail_bytes_written<=0;tail_delay<=0;end
  if(out_valid&&out_ready&&tail_active)begin
   if(out_slot!=tail_writes/32||out_col!=(tail_writes%32)*32)$fatal(1,"SIM peer public slot/chunk order");
   tail_target[tail_writes]<=out_data;tail_writes<=tail_writes+1;tail_bytes_written<=tail_bytes_written+128;
   if(tail_writes==543)tail_delay<=7;
  end
  if(tail_delay>0)tail_delay<=tail_delay-1;
  if(tail_active&&tail_writes==544&&tail_delay==1)begin
   tail_commit_valid<=1;tail_commit_request<=tail_request;tail_commit_generation<=tail_generation;tail_commit_source_epoch<=tail_source_epoch;tail_commit_bytes<=tail_bytes_written;tail_commit_status<=0;tail_active<=0;
  end
  if(tail_commit_valid&&tail_commit_ready)tail_commit_valid<=0;
  if(tail_abort_valid&&tail_abort_ready)begin tail_active<=0;tail_writes<=0;tail_bytes_written<=0;end
 end
 task automatic step;begin @(posedge clk);#0.1;end endtask
 task automatic progress(input int n,input string phase);
  begin checked+=n;$display("M007_PARENT_CHECKED checked=%0d phase=%s cycle=%0d",checked,phase,cycle);$fflush();end
 endtask
 integer attention_last_checked=0;
 task automatic attention_checked(input int n,input string phase);
  begin checked+=n;if(checked-attention_last_checked>=4096)begin $display("M007_PARENT_CHECKED checked=%0d phase=%s cycle=%0d",checked,phase,cycle);$fflush();attention_last_checked=checked;end end
 endtask
 task automatic send_begin;begin @(negedge clk);cmd_valid=1;do @(posedge clk);while(!cmd_ready);@(negedge clk);cmd_valid=0;end endtask
 task automatic send_setup;begin @(negedge clk);setup_valid=1;do @(posedge clk);while(!setup_ready);@(negedge clk);setup_valid=0;end endtask
 task automatic consume_done(input int op,st,dom,src);
  logic[244:0]hold;
  begin
   wait(done_valid);@(negedge clk);hold={done_op,done_status,error_domain,source_status,error_tuple,done_request,done_generation,done_epoch};
   if(done_op!=op||done_status!=st||error_domain!=dom||source_status!=src)$fatal(1,"DONE op%0d status%0d domain%0d source%0d tuple%h state%0d",done_op,done_status,error_domain,source_status,error_tuple,parent_state);
   repeat(4)begin step();if(!done_valid||{done_op,done_status,error_domain,source_status,error_tuple,done_request,done_generation,done_epoch}!==hold)$fatal(1,"held DONE unstable");end
   @(negedge clk);done_ready=1;step();@(negedge clk);done_ready=0;wait(parent_state==0);progress(1,"DONE");
  end
 endtask
 task automatic offer_word(input int kind_id,index_id);
  begin
   @(negedge clk);model_word_valid=1;model_word_kind=kind_id;model_word_index=index_id;
   for(int j=0;j<32;j++)model_word_data[j]=kind_id==0?bias_mem[index_id*32+j]:kind_id==1?gamma_mem[index_id*32+j]:type_mem[index_id*32+j];
   do @(posedge clk);while(!model_word_ready);@(negedge clk);model_word_valid=0;
  end
 endtask
 task automatic load_rope;
  begin
   @(negedge clk);coeff_bind_valid=1;do @(posedge clk);while(!coeff_bind_ready);@(negedge clk);coeff_bind_valid=0;
   for(int t=0;t<4;t++)for(int r=0;r<128;r++)for(int half=0;half<2;half++)begin
    coeff_wr_valid=1;coeff_wr_table=t;coeff_wr_row=r;coeff_wr_half=half;
    for(int j=0;j<32;j++)coeff_wr_data[j]=rope_mem[t][r*64+half*32+j];
    do @(posedge clk);while(!coeff_wr_ready);@(negedge clk);
   end
   coeff_wr_valid=0;wait(coeff_family_complete==3);progress(1024,"ROPE");
  end
 endtask
 // One actual catalog request with held response; no combinational fake ready.
 always@(negedge clk)if(rst_n&&dut.catalog_owns)begin
  if(response_consumed)begin rvalid[0]=0;response_consumed=0;end
  if(drain_pending&&rvalid[0])begin rlast[0]=1;rdata[0]=0;drain_pending=0;end
  arready=0;if(!pending&&!rvalid[0]&&cycle%3!=0)arready[0]=1;
  if(pending&&!rvalid[0])begin
   rvalid[0]=1;rid[0]=7;rresp[0]=0;rdata[0]=catalog_mem[bus_word];rlast[0]=1;
   if(mode==2&&!fault_injected)begin rlast[0]=0;fault_injected=1;end
   if(mode==3&&bus_word==123)rdata[0][88]=~rdata[0][88];
   pending=0;
  end
 end
 always@(negedge clk)if(rst_n&&!dut.catalog_owns)begin
  arready=(mode==5||mode==8)?4'b1111:4'b0;
  for(int p=0;p<4;p++)if(!rvalid[p]||w_last_fire[p]||p==0&&response_consumed)begin
   int pick;pick=-1;rvalid[p]=0;
   for(int j=7;j>=0;j--)if(w_live[p][(w_rotate[p]+j)%8])pick=(w_rotate[p]+j)%8;
   if(pick>=0&&cycle%2==0)begin
    rvalid[p]=1;rid[p]=3'(pick);rresp[p]=0;rlast[p]=w_pos[p][pick]+1==w_length[p][pick];
    rdata[p]=w_word(p,int'((w_address[p][pick]-64'd1048576)>>6)+w_pos[p][pick]);
   end
  end
  response_consumed=0;
 end
 always@(posedge clk)begin
  w_last_fire<=rvalid&rready;
  if(!rst_n)for(int p=0;p<4;p++)begin w_live[p]<=0;w_rotate[p]<=0;end
  else if(!dut.catalog_owns&&(mode==5||mode==8))for(int p=0;p<4;p++)begin
   if(arvalid[p]&&arready[p])begin
    if(w_live[p][arid[p]]||araddr[p]<1048576||araddr[p]+64*(arlen[p]+1)>1048576+884736||arlen[p]>15)$fatal(1,"real QKV W request/identity/span");
    w_live[p][arid[p]]<=1;w_address[p][arid[p]]<=araddr[p];w_length[p][arid[p]]<=arlen[p]+1;w_pos[p][arid[p]]<=0;
   end
   if(rvalid[p]&&rready[p])begin
    if(w_pos[p][rid[p]]+1==w_length[p][rid[p]])w_live[p][rid[p]]<=0;
    else w_pos[p][rid[p]]<=w_pos[p][rid[p]]+1;
    w_rotate[p]<=(rid[p]+1)%8;
   end
  end
 end
 always@(posedge clk)if(rst_n)begin
  cycle++;
  if(dut.catalog_owns&&arvalid!=0&&arvalid!=1)$fatal(1,"catalog must own only port0");
  if(dut.catalog_owns&&arvalid[0]&&!arready[0])begin
   if(held_ar&&araddr[0]!==held_addr)$fatal(1,"AR address changed while held");held_addr=araddr[0];held_ar=1;
  end
  if(dut.catalog_owns&&arvalid[0]&&arready[0])begin
   if(arid[0]!=7||arlen[0]!=0||araddr[0]<65536||araddr[0]>=65536+7936)$fatal(1,"invalid catalog transaction");
   pending=1;bus_word=(araddr[0]-65536)/64;ar_count++;held_ar=0;held_word=bus_word;
   if(!dut.m_transport_idle)$fatal(1,"catalog admitted before actual W transport idle");
  end
  if(dut.catalog_owns&&rvalid[0]&&rready[0])begin
   r_count++;
   if(!rlast[0])begin
    if(dut.cat_word!=held_word)$fatal(1,"catalog origin changed before drain");
    drain_pending=1;
   end else begin
    response_consumed=1;
   end
  end
  if(model_word_valid&&model_word_ready)begin
   model_count++;if(model_count%32==0)progress(32,"MODEL");
   if(model_word_kind==2&&!dut.type_word_commit)$fatal(1,"model type missing true commit");
  end
  if(in_valid&&in_ready)begin h_count++;if(!dut.v2_h_wr_commit)$fatal(1,"H accepted without actual commit");if(h_count%128==0)progress(128,"H");end
  if(dut.runtime_catalog&&dut.cat_rsp_valid&&dut.cat_rsp_ready&&!dut.cat_fault)catalog_runtime++;
  if(mode==5||mode==8)begin
   if(cmd_valid&&cmd_ready)begin begin_cycle=cycle;$display("M007_FULLMODEL_BEGIN cycle=%0d",cycle);$fflush();end
   if(dut.q_awr_valid&&dut.q_awr_ready)begin
    if(dut.q_awr_data!==a_gold[32*dut.q_awr_row+dut.q_awr_group])$fatal(1,"actual QKV quant A original bits");
    a_writes++;if(a_writes%128==0)progress(4096,"QUANT_A");
   end
   if(dut.q_awr_rsp_valid&&dut.q_awr_rsp_ready)a_acks++;
   if(dut.m_cmd_valid&&dut.m_cmd_ready)begin
    matrices++;matrix_begin_cycle=cycle;if(a_writes!=4096||a_acks!=4096||!dut.front.a_published||!dut.front.producer_closed||!dut.front.producer_success||dut.front.a_write_debt!=0||dut.front.q_reservations!=0)$fatal(1,"matrix before actual A ACK/publication/debt barrier");
    $display("M007_FULLMODEL_MATRIX_BEGIN cycle=%0d",cycle);$fflush();
   end
   if(dut.m_out_valid&&dut.m_out_ready)begin
    if(dut.m_out_data!==qkv_gold[qkv_outputs]||dut.m_out_s!=qkv_outputs/256||dut.m_out_row!=(qkv_outputs%256)/2||dut.m_out_col!=64*(qkv_outputs/256)+32*(qkv_outputs%2)||dut.m_out_request!=cmd_request||dut.m_out_generation!=cmd_generation||dut.m_out_epoch!=cmd_epoch+1)$fatal(1,"actual QKV first block F32/coordinates/identity");
    if(mode==8)for(int c=0;c<32;c++)if(dut.m_out_data[c]!==qkvgold[int'(dut.m_out_row)*3072+int'(dut.m_out_col)+c])$fatal(1,"original Attention QKV mapping");
    qkv_outputs++;qkv_count=qkv_outputs;if(qkv_outputs%32==0)progress(1024,"QKV");
    if(qkv_outputs%256==0)begin $display("M007_FULLMODEL_MATRIX_BLOCK phase=QKV block=%0d values=%0d cycle=%0d",qkv_outputs/256-1,qkv_outputs*32,cycle);$fflush();end
    if(mode==8&&stop_qkv_blocks>0&&stop_qkv_blocks<48&&qkv_outputs==256*stop_qkv_blocks)begin
     if(done_valid||matrices!=1||h_count!=4096||catalog_runtime!=2||layer_starts!=0)$fatal(1,"normal B1 QKV prefix boundary");
     $display("M007_FULLMODEL_NORMAL_QKV_PREFIX blocks=%0d values=%0d command_cycles=%0d unfinished=1",stop_qkv_blocks,qkv_outputs*32,cycle-begin_cycle);$display("HARDWARE_AGENT_SIM_PASS M007_FULLMODEL_NORMAL_PREFIX");$fflush();$finish;
    end
    if(mode==5&&qkv_outputs==256)begin
     if(done_valid||matrices!=1||h_count!=4096||catalog_runtime!=2)$fatal(1,"unfinished current v3 prefix boundary");
     $display("M007_FULLMODEL_QKV1 values=8192 command_cycles=%0d unfinished=1",cycle-begin_cycle);$display("HARDWARE_AGENT_SIM_PASS M007_FULLMODEL_QKV_PREFIX");$fflush();$finish;
    end
   end
  end
  if(mode==8&&dut.m_done_valid&&dut.m_done_ready)begin
   if(dut.m_status!=0||qkv_outputs!=12288||dut.m_done_request!=cmd_request||dut.m_done_generation!=cmd_generation||dut.m_done_epoch!=cmd_epoch+1)$fatal(1,"actual full QKV terminal identity/count/status");
   qkv_retire_count++;$display("M007_FULLMODEL_QKV_RETIRED vectors=%0d cycle=%0d",qkv_outputs,cycle);$fflush();
   if(stop_qkv_blocks==48)begin if(done_valid||layer_starts!=0)$fatal(1,"QKV retirement remains unfinished parent");$display("HARDWARE_AGENT_SIM_PASS M007_FULLMODEL_NORMAL_PREFIX");$fflush();$finish;end
  end
  if(mode==8&&dut.l_start_valid&&dut.l_start_ready)begin layer_starts++;if(qkv_outputs!=12288||qkv_retire_count!=1||matrices!=1||a_writes!=4096||a_acks!=4096)$fatal(1,"Attention start before real full QKV retirement");$display("M007_FULLMODEL_ATTENTION_BEGIN cycle=%0d",cycle);$fflush();end
  if(mode==8&&h_count>0&&done_valid)$fatal(1,"unexpected parent terminal in unfinished normal-chain cost pilot");
  if(cycle>40000000)$fatal(1,"40M cycle watchdog");
 end
 always @(posedge clk)if(rst_n&&mode==8&&parent_state==7)begin
  if(dut.resident.joint.layer.rope_wr_commit_valid)begin
   for(int c=0;c<64;c++)if(dut.resident.joint.layer.rope_wr_q[c]!==postgold[(dut.resident.joint.layer.rope_wr_token*3*16+dut.resident.joint.layer.rope_wr_head)*64+c]||dut.resident.joint.layer.rope_wr_k[c]!==postgold[((dut.resident.joint.layer.rope_wr_token*3+1)*16+dut.resident.joint.layer.rope_wr_head)*64+c])$fatal(1,"parent real RoPE data");nrope=nrope+1;attention_checked(128,"ROPE");
   if(nrope%512==0)begin $display("MATRIX_PROGRESS parent_RoPE_commits=%0d cycle=%0d",nrope,cycle);$fflush();end
  end
  if(dut.resident.joint.layer.h_start_valid&&dut.resident.joint.layer.h_start_ready)begin head_start_cycle=cycle;$display("M007_FULLMODEL_HEAD_BEGIN head=%0d cycle=%0d",dut.resident.joint.layer.active_head,cycle);$fflush();end
  if(dut.resident.a_res_fp_rsp_phase==2&&dut.resident.a_res_st_ps_wr_valid&&dut.resident.a_res_st_ps_wr_ready)begin
   int group,key;group=int'(dut.resident.a_res_st_ps_wr_tag[11:7]);key=int'(dut.resident.a_res_st_ps_wr_tag[6:0]);
   for(int q=0;q<4;q++)begin int r,b;r=group*4+q;b=(key/64)*512+(r%16)*32+key%32;if(dut.resident.a_res_st_ps_wr_data[b]!==scoregold[(int'(dut.resident.joint.layer.active_head)*128+r)*128+key])$fatal(1,"parent real score");nscore=nscore+1;head_score[dut.resident.joint.layer.active_head]=head_score[dut.resident.joint.layer.active_head]+1;attention_checked(1,"SCORE");end
   if(nscore%4096==0)begin $display("MATRIX_PROGRESS parent_score_words=%0d cycle=%0d",nscore,cycle);$fflush();end
  end
  if(dut.resident.joint.layer.state==7&&dut.resident.joint.layer.h_check_qk_done&&!max_checked[dut.resident.joint.layer.active_head])begin for(int r=0;r<128;r++)if(dut.resident.joint.layer.h_maximum[r]!==maxgold[int'(dut.resident.joint.layer.active_head)*128+r])$fatal(1,"parent real maximum");max_checked[dut.resident.joint.layer.active_head]=1;head_maximum[dut.resident.joint.layer.active_head]=128;attention_checked(128,"MAXIMUM");end
  if(dut.resident.joint.layer.head.sm_prob_wr_valid&&dut.resident.joint.layer.head.sm_prob_wr_ready)begin
   int r,k;r=int'(dut.resident.joint.layer.head.sm_prob_wr_tag[10:4]);k=int'(dut.resident.joint.layer.head.sm_prob_wr_tag[3:0])*8;
   for(int c=0;c<8;c++)begin if(dut.resident.joint.layer.head.sm_prob_wr_data[c]!==probgold[(int'(dut.resident.joint.layer.active_head)*128+r)*128+k+c])$fatal(1,"parent real probability");nprob=nprob+1;head_prob[dut.resident.joint.layer.active_head]=head_prob[dut.resident.joint.layer.active_head]+1;attention_checked(1,"PROB");end
  end
  if(dut.resident.joint.layer.head.sm_prob_wr_ack_valid&&dut.resident.joint.layer.head.sm_prob_wr_ack_ready)begin nprob_ack=nprob_ack+1;head_prob_ack[dut.resident.joint.layer.active_head]=head_prob_ack[dut.resident.joint.layer.active_head]+1;if(nprob_ack%512==0)begin $display("MATRIX_PROGRESS parent_prob_ack=%0d cycle=%0d",nprob_ack,cycle);$fflush();end end
  if(dut.resident.a_res_st_context_wr_valid&&dut.resident.a_res_st_context_wr_ready)for(int c=0;c<64;c++)if(dut.resident.a_res_st_context_wr_mask[c])begin
   int h,r;h=int'(dut.resident.a_res_st_context_wr_addr[c][10:7]);r=int'(dut.resident.a_res_st_context_wr_addr[c][6:0]);if(dut.resident.a_res_st_context_wr_data[c]!==contextgold[(h*128+r)*64+c])$fatal(1,"parent real context");ncontext=ncontext+1;head_context[dut.resident.joint.layer.active_head]=head_context[dut.resident.joint.layer.active_head]+1;attention_checked(1,"CONTEXT");
  end
  if(dut.resident.joint.layer.h_done_valid&&dut.resident.joint.layer.h_done_ready)begin
   if(dut.resident.joint.layer.h_done_status!=0||dut.resident.joint.layer.h_done_cycles>11648||head_score[dut.resident.joint.layer.active_head]!=16384||head_prob[dut.resident.joint.layer.active_head]!=16384||head_context[dut.resident.joint.layer.active_head]!=8192||head_prob_ack[dut.resident.joint.layer.active_head]!=2048||head_maximum[dut.resident.joint.layer.active_head]!=128||!max_checked[dut.resident.joint.layer.active_head]||nrope!=2048||qkv_count!=12288||layer_starts!=1||dut.resident.joint.layer.active_head!=nheads||dut.resident.joint.layer.h_done_request_id!=cmd_request||dut.resident.joint.layer.h_done_generation!=cmd_generation||dut.resident.joint.layer.h_done_head!=nheads)$fatal(1,"parent per-head numeric/maximum/event/identity/cycle coverage");
   $display("M007_FULLMODEL_HEAD_END head=%0d cycle=%0d head_cycles=%0d",dut.resident.joint.layer.active_head,cycle,dut.resident.joint.layer.h_done_cycles);$fflush();nheads=nheads+1;
   if(stop_after_head>0&&nheads==stop_after_head)begin
    if(done_valid||matrices!=1||qkv_retire_count!=1)$fatal(1,"head pilot must remain unfinished actual parent");
    $display("M007_FULLMODEL_HEAD_PREFIX_PASS heads=%0d QKV32=%0d score=%0d prob=%0d context=%0d maxima=%0d elapsed=%0d",nheads,qkv_count,nscore,nprob,ncontext,128*nheads,cycle-begin_cycle);$display("HARDWARE_AGENT_SIM_PASS M007_FULLMODEL_HEAD_PREFIX");$fflush();$finish;
   end
  end
 end

 initial begin
  clk='0;
  rst_n='0;
  setup_valid='0;
  setup_request='0;
  setup_generation='0;
  setup_build_id='0;
  setup_table_key='0;
  setup_model_sha256='0;
  setup_graph_sha256='0;
  setup_numeric_sha256='0;
  setup_layout_sha256='0;
  setup_package_build_sha256='0;
  setup_catalog_base='0;
  setup_catalog_span='0;
  setup_records_sha256='0;
  setup_records_crc='0;
  invalidate_valid='0;
  invalidate_request='0;
  invalidate_generation='0;
  invalidate_build_id='0;
  model_word_valid='0;
  model_word_request='0;
  model_word_generation='0;
  model_word_kind='0;
  model_word_index='0;
  model_word_data='0;
  cmd_qtype='0;
  cmd_marker_rows='0;
  cmd_marker_mask='0;
  cmd_candidate_count='0;
  tail_commit_valid='0;
  tail_commit_request='0;
  tail_commit_generation='0;
  tail_commit_source_epoch='0;
  tail_commit_bytes='0;
  tail_commit_status='0;
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
  in_valid='0;
  in_data='0;
  in_request='0;
  in_generation='0;
  in_epoch='0;
  in_row='0;
  in_group='0;
  producer_fail_valid='0;
  producer_fail_code='0;
  producer_fail_detail='0;
  producer_fail_request='0;
  producer_fail_generation='0;
  producer_fail_epoch='0;
  out_ready='0;
  done_ready='0;
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
  arready='0;
  rvalid='0;
  rid='0;
  rdata='0;
  rresp='0;
  rlast='0;
  if(!$value$plusargs("DATA=%s",data_dir)||!$value$plusargs("ROPE=%s",rope_dir)||!$value$plusargs("H=%s",h_path))$fatal(1,"original product paths required");
  if(!$value$plusargs("MODE=%d",mode))mode=0;
  if(mode==8)begin
   if(!$value$plusargs("STOP_QKV_BLOCKS=%d",stop_qkv_blocks))stop_qkv_blocks=3;
   if(!$value$plusargs("STOP_AFTER_HEAD=%d",stop_after_head))stop_after_head=0;
   if(!(stop_qkv_blocks==0||stop_qkv_blocks==1||stop_qkv_blocks==3||stop_qkv_blocks==48)||!(stop_after_head==0||stop_after_head==1||stop_after_head==2)||((stop_qkv_blocks==0)==(stop_after_head==0)))$fatal(1,"bounded normal pilot endpoint");
   for(int h=0;h<16;h++)begin head_score[h]=0;head_prob[h]=0;head_context[h]=0;head_prob_ack[h]=0;head_maximum[h]=0;end
  end
  $display("M007_FULLMODEL_FIXTURE_BEGIN mode=%0d",mode);$fflush();
  if(mode==5||mode==8)begin
   if(!$value$plusargs("MATRIX=%s",matrix_dir))$fatal(1,"original matrix fixtures required");
   $readmemh({matrix_dir,"/qkv_0_weight/p0.hex"},w_mem0);$readmemh({matrix_dir,"/qkv_0_weight/p1.hex"},w_mem1);$readmemh({matrix_dir,"/qkv_0_weight/p2.hex"},w_mem2);$readmemh({matrix_dir,"/qkv_0_weight/p3.hex"},w_mem3);
   $readmemh({matrix_dir,"/qkv_0_weight/output.hex"},qkv_gold);$readmemh({matrix_dir,"/qkv_0_weight/a_write.hex"},a_gold);
  end
  $readmemh({data_dir,"/catalog.hex"},catalog_mem);$readmemh({data_dir,"/bias.words.hex"},bias_mem);$readmemh({data_dir,"/gamma.words.hex"},gamma_mem);$readmemh({data_dir,"/type.words.hex"},type_mem);
  $readmemh({rope_dir,"/cos_full.mem"},rope_mem[0]);$readmemh({rope_dir,"/sin_full.mem"},rope_mem[1]);$readmemh({rope_dir,"/cos_slide.mem"},rope_mem[2]);$readmemh({rope_dir,"/sin_slide.mem"},rope_mem[3]);$readmemh(h_path,original_h);
  if(mode==8)begin
   $readmemh({rope_dir,"/encoder0_pre_qkv.mem"},qkvgold);$readmemh({rope_dir,"/encoder0_post_qkv.mem"},postgold);$readmemh({rope_dir,"/encoder0_score.mem"},scoregold);$readmemh({rope_dir,"/encoder0_maximum.mem"},maxgold);$readmemh({rope_dir,"/encoder0_prob.mem"},probgold);$readmemh({rope_dir,"/encoder0_context.mem"},contextgold);
  end
  $display("M007_FULLMODEL_FIXTURE_END mode=%0d",mode);$fflush();
  cmd_model_id=dut.MODEL_ID;cmd_graph_id=dut.GRAPH_ID;cmd_numeric_id=dut.NUMERIC_ID;cmd_layout_id=dut.LAYOUT_ID;cmd_table_key=dut.TABLE_KEY;cmd_build_id=dut.BUILD_ID;cmd_kind=5;cmd_layer=0;cmd_request=41;cmd_generation=7;cmd_epoch=16;cmd_mask=mode==8?128'h00000000000000ffffffffffffffffff:'1;
  setup_model_sha256=dut.MODEL_SHA256;setup_graph_sha256=dut.GRAPH_SHA256;setup_numeric_sha256=dut.NUMERIC_SHA256;setup_layout_sha256=dut.LAYOUT_SHA256;setup_package_build_sha256=dut.PACKAGE_BUILD_SHA256;setup_build_id=dut.BUILD_ID;setup_table_key=dut.TABLE_KEY;
  setup_request=22;setup_generation=3;setup_catalog_base=65536;setup_catalog_span=8192;setup_records_sha256=256'h36455736a0e39bf63b37a63ceb46c95b2c60678cc50d23671cc1b676c36cd87c;setup_records_crc=64'hcb4a2935cd23ffc8;
  model_word_request=setup_request;model_word_generation=setup_generation;
  coeff_bind_model_id=cmd_model_id;coeff_bind_numeric_id=cmd_numeric_id;coeff_bind_table_key=cmd_table_key;coeff_wr_model_id=cmd_model_id;coeff_wr_numeric_id=cmd_numeric_id;coeff_wr_table_key=cmd_table_key;
  invalidate_request=19;invalidate_generation=2;invalidate_build_id=dut.BUILD_ID;
  repeat(4)step();@(negedge clk);rst_n=1;wait(cmd_ready);
  send_begin();consume_done(2,5,1,12);if(ar_count!=0||h_count!=0)$fatal(1,"uncommitted work");
  if(mode==0)begin
   // Same-edge arbitration consumes one INVALIDATE, then SETUP, then BEGIN.
   @(negedge clk);invalidate_valid=1;setup_valid=1;cmd_valid=1;#0.1;
   if(!invalidate_ready||setup_ready||cmd_ready)$fatal(1,"entry priority INVALIDATE");
   step();@(negedge clk);invalidate_valid=0;setup_valid=0;cmd_valid=0;consume_done(1,0,0,0);
   setup_build_id=0;send_setup();consume_done(0,4,1,2);
   cmd_kind=4;send_begin();consume_done(2,5,1,12);
   $display("HARDWARE_AGENT_SIM_PASS M007_FULLMODEL_ABI");$fflush();$finish;
  end
  load_rope();send_setup();
  if(mode==2)begin
   consume_done(0,2,7,9);if(ar_count!=1||r_count!=2)$fatal(1,"missing RLAST did not truly drain");
   $display("HARDWARE_AGENT_SIM_PASS M007_FULLMODEL_CATALOG_DRAIN");$fflush();$finish;
  end
  if(mode==3)begin
   consume_done(0,5,1,5);if(ar_count!=124||model_count!=0)$fatal(1,"CRC last-record check");
   $display("HARDWARE_AGENT_SIM_PASS M007_FULLMODEL_CRC");$fflush();$finish;
  end
  wait(parent_state==65);
  @(negedge clk);model_word_valid=1;model_word_kind=0;model_word_index=1;
  repeat(3)begin #0.1;if(model_word_ready||!reject_valid||reject_port!=2)$fatal(1,"jumped modelword accepted");step();end
  @(negedge clk);model_word_valid=0;
  for(int j=0;j<576;j++)offer_word(0,j);
  wait(parent_state==68);for(int j=0;j<32;j++)offer_word(1,j);
  wait(parent_state==70);for(int j=0;j<96;j++)offer_word(2,j);
  wait(done_valid);if(model_committed)$fatal(1,"premature setup publication");consume_done(0,0,0,0);
  if(!model_committed||model_count!=704||ar_count!=124||r_count!=124)$fatal(1,"actual setup missing work");
  if(mode==1)begin
   cmd_kind=4;send_begin();consume_done(2,4,1,1);if(error_tuple[95:88]!=8'h03)$fatal(1,"invalid kind op");
   cmd_kind=5;cmd_layer=28;send_begin();consume_done(2,4,1,3);
   cmd_kind=6;cmd_layer=2;send_begin();consume_done(2,4,1,3);
   cmd_kind=7;cmd_layer=0;cmd_qtype=2;cmd_marker_mask=3;cmd_candidate_count=2;cmd_marker_rows[0]=23;cmd_marker_rows[1]=33;cmd_mask=128'h00000000000000ffffffffffffffffff;
   cmd_marker_rows[3]=1;send_begin();consume_done(2,4,1,3);cmd_marker_rows[3]=0;
   send_begin();wait(parent_state==32);if(!tail_active)$fatal(1,"kind7 H started before actual tail arm");
   @(negedge clk);producer_fail_valid=1;producer_fail_request=cmd_request;producer_fail_generation=cmd_generation;producer_fail_epoch=cmd_epoch;producer_fail_code=77;producer_fail_detail=80'h0123456789abcdef0123;
   do @(posedge clk);while(!producer_fail_ready);@(negedge clk);producer_fail_valid=0;consume_done(2,3,2,77);if(tail_active||tail_writes!=0)$fatal(1,"actual SIM tail abort not drained");
   cmd_kind=6;cmd_qtype=0;cmd_marker_mask=0;cmd_candidate_count=0;cmd_marker_rows=0;cmd_layer=0;send_begin();wait(parent_state==32);
   if(dut.layer_index!=28)$fatal(1,"kind6 local0 did not map global28");
   @(negedge clk);producer_fail_valid=1;do @(posedge clk);while(!producer_fail_ready);@(negedge clk);producer_fail_valid=0;consume_done(2,3,2,77);if(error_tuple[87:83]!=28)$fatal(1,"Decision error global layer lost");
   @(negedge clk);invalidate_build_id=0;invalidate_valid=1;do @(posedge clk);while(!invalidate_ready);@(negedge clk);invalidate_valid=0;consume_done(1,4,1,2);if(!model_committed)$fatal(1,"bad invalidate erased commit");
   @(negedge clk);invalidate_build_id=dut.BUILD_ID;invalidate_valid=1;do @(posedge clk);while(!invalidate_ready);@(negedge clk);invalidate_valid=0;consume_done(1,0,0,0);if(model_committed)$fatal(1,"invalidate failed");
   $display("HARDWARE_AGENT_SIM_PASS M007_FULLMODEL_SETUP");$fflush();$finish;
  end
  send_begin();wait(parent_state==32);
  for(int j=0;j<4096;j++)begin
   @(negedge clk);in_valid=1;in_data=original_h[j];in_request=cmd_request;in_generation=cmd_generation;in_epoch=cmd_epoch;in_row=j/32;in_group=j%32;
   do @(posedge clk);while(!in_ready);@(negedge clk);in_valid=0;
  end
  wait(catalog_runtime==2);#0.001;if(h_count!=4096||dut.active_epoch_offset!=1||dut.tensor_id[0]!=4||dut.tensor_id[1]!=32)$fatal(1,"real H/two catalog slot prefix");
  progress(2,"CATALOG");if(mode==5||mode==8)wait(0);
  $display("HARDWARE_AGENT_SIM_PASS M007_FULLMODEL_H_CATALOG_PREFIX");$fflush();$finish;
 end
endmodule
