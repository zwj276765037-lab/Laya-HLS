`timescale 1ns/1ps
module m007_fullmodel_encoder_1d_tb;
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

 logic full_active=0;integer mode=9,ar_count=0,r_count=0,model_count=0,h_count=0,catalog_runtime=0;
 integer bus_word=0,held_word=0;logic pending=0,drain_pending=0,fault_injected=0,response_consumed=0;
 logic[63:0]held_addr;logic held_ar=0;
 logic[511:0]catalog_mem[0:127];logic[31:0]bias_mem[0:18431],gamma_mem[0:1023],type_mem[0:3071];
 logic[31:0]rope_load[0:8191];
 logic[31:0]rope_mem[0:3][0:8191];string data_dir,rope_dir;
 localparam logic[255:0] PLATFORM_SHA=256'hf0df35cc7013643161e135ae0949473a9b5c0f13d5a4e3aea3675c2cf607db18;
 laya_m007_single_parent_v3 #(.ADDRESS_PROFILE(1),.HBM_PORT_BASE(0),.HBM_PORT_SPAN({4{64'h100000000}}),.PLATFORM_MANIFEST_SHA256(PLATFORM_SHA)) dut(.*);
 m007_public_f32_capture_tb_v2 observed_output(.clk,.rst_n,.command_fire(full_active&&cmd_valid&&cmd_ready),.request_id(cmd_request),.generation(cmd_generation),.source_epoch(cmd_epoch),.layer_index(cmd_layer),.kind(cmd_kind),.input_fire(in_valid&&in_ready),.input_row(in_row),.input_group(in_group),.input_data(in_data),.output_fire(out_valid&&out_ready),.row(out_row),.col(out_col),.data(out_data),.receipt_fire(full_active&&done_op==2&&done_valid&&done_ready),.receipt_status(done_status),.receipt_source_status(source_status),.receipt_domain(error_domain),.receipt_tuple(error_tuple),.all_resources_retired(dut.v2_shared_resources_idle&&dut.v2_resident_bank_idle&&dut.v2_scratch_retired&&dut.m_cmd_ready&&dut.q_cmd_ready&&dut.ws_a_enable&&!dut.ws_rearm));
 always #1 clk=~clk;
 logic[31:0]residual_scalar[0:131071];
 logic [1023:0] original_qkv_input[0:4095],initial_h[0:4095],final_h[0:4095],residual_a[0:4095],norm_ff[0:4095];
 logic [1023:0] qkv_gold[0:12287],wo_gold[0:4095],wi_gold[0:20991],down_gold[0:4095];
 logic [271:0] initial_a[0:4095],context_a[0:4095],norm_a[0:4095],g_a[0:10495];
 logic [1023:0] wo_inputs[0:4095];
 logic [8191:0] qkv_prebias[0:1535],wo_prebias[0:511];
 logic [511:0] qkv_mem0[0:13823];
 logic [511:0] qkv_mem1[0:13823];
 logic [511:0] qkv_mem2[0:13823];
 logic [511:0] qkv_mem3[0:13823];
 logic [511:0] wo_mem0[0:4607];
 logic [511:0] wo_mem1[0:4607];
 logic [511:0] wo_mem2[0:4607];
 logic [511:0] wo_mem3[0:4607];
 logic [511:0] wi_mem0[0:23615];
 logic [511:0] wi_mem1[0:23615];
 logic [511:0] wi_mem2[0:23615];
 logic [511:0] wi_mem3[0:23615];
 logic [511:0] down_mem0[0:11807];
 logic [511:0] down_mem1[0:11807];
 logic [511:0] down_mem2[0:11807];
 logic [511:0] down_mem3[0:11807];
 logic [383:0] vectors[0:335871];
 logic [255:0] node_expected[0:8][0:41983],tanh_expected[0:41983],g_expected[0:41983];
 logic [31:0] cf[0:8191],sf[0:8191],maskmem[0:127],qkvgold[0:393215];
 logic [31:0] postgold[0:393215],scoregold[0:262143],maxgold[0:2047],probgold[0:262143],contextgold[0:131071];
 logic [15:0] max_checked=0;
 logic [3:0][3:0][63:0] fixture_base,fixture_span;
 logic [7:0] live[0:3];logic [63:0] baddr[0:3][0:7],bbase[0:3][0:7];integer bphase[0:3][0:7];
 integer bsize[0:3][0:7],bpos[0:3][0:7],eligible[0:3][0:7],rotate[0:3];logic [3:0] last_r_fire;
 integer cycle=0,command_cycle=-1,old_state=-1,kind_run=5,packed_check=1,stop_qkv_blocks=0,stop_after_head=0,stop_ffn_blocks=0,stop_down_blocks=0;
 integer commands=0,mcommands=0,qcommands=0,matrix_phase=0,qphase=0,descriptors=0,input_count=0,export_count=0,parent_retired=0;
 integer checked_words=0,last_checked=0,m_outputs[0:3],m_done_count[0:3],quant_returns[0:3],awrites[0:3],aacks[0:3],publications[0:3];
 integer m_start_cycle[0:3],m_first_out[0:3],m_done_cycle[0:3],q_start_cycle[0:3];
 integer issues[0:3][0:81],commits[0:3][0:81],outputs[0:3][0:81],first_issue[0:3][0:81],last_issue[0:3][0:81];
 integer issue_time[0:63],issue_seq[0:63],ps_time[0:63],max_issue_ack=0,max_ps_feedback=0;logic [63:0] issue_owned,ps_owned;
 logic [4351:0] expected_w,expected_a;logic [511:0] temp;logic [242:0] expected_done;
 integer gcommands=0,g_cmd_cycle=-1,g_outputs=0,node_checks=0,g_writes=0,g_acks=0,g_reads=0,g_releases=0,g_done=0,g_tail_start=-1;
 integer g_ready_cycle[0:81],g_eligible_cycle[0:81],g_first_read[0:81],g_last_read[0:81],g_first_consume[0:81],g_last_consume[0:81],g_read_count[0:81],g_output_count[0:81],g_release_cycle[0:81];
 integer qkv_count=0,nrope=0,nscore=0,nprob=0,ncontext=0,nprob_ack=0,nheads=0,head_start_cycle=-1,layer_starts=0,layer_done_count=0;
 integer head_score[0:15],head_prob[0:15],head_context[0:15],head_prob_ack[0:15],head_maximum[0:15];
 integer ctx_reads=0,ctx_responses=0,ctx_inputs=0,ctx_pending=0;logic ctx_owned=0;
 integer h_commits=0,wo_q_commits=0,down_q_commits=0,ln_q_commits=0,vector_h_commits[0:1],vector_done_count=0,ln_done_count=0;
 integer last_h_commit=-1,last_export=-1,first_done=-1,mid_held=0,last_held=0,mid_hold_left=0,last_hold_left=0;logic mid_started=0,last_started=0,holding=0;logic [1051:0] held_out;
 string original_fixture,matrix_fixture,input_fixture,attention_fixture,context_fixture,ffn_fixture,wi_weights,down_weights,g_fixture,residual_fixture;
 task automatic checked(input int n,input string phase);
  checked_words+=n;
  if(checked_words-last_checked>=4096)begin $display("M007_PARENT_CHECKED checked=%0d phase=%s cycle=%0d",checked_words,phase,cycle);$fflush();last_checked=checked_words;end
 endtask
 function automatic logic [31:0] op_epoch(input int code);return cmd_epoch+(kind_run==5?code:0);endfunction
 function automatic int blocks_at(input int ph);case(ph)0:return 48;1:return 16;2:return 82;default:return 16;endcase endfunction
 function automatic int k_at(input int ph);return ph==3?2624:1024;endfunction
 function automatic int n_at(input int ph);case(ph)0:return 3072;1:return 1024;2:return 5248;default:return 1024;endcase endfunction
 function automatic int tensor_at(input int ph);case(ph)0:return 4;1:return 32;2:return 60;default:return 88;endcase endfunction
 function automatic logic [511:0] word_at(input int ph,p,idx);case(ph)0:case(p)0:return qkv_mem0[idx];1:return qkv_mem1[idx];2:return qkv_mem2[idx];default:return qkv_mem3[idx];endcase 1:case(p)0:return wo_mem0[idx];1:return wo_mem1[idx];2:return wo_mem2[idx];default:return wo_mem3[idx];endcase 2:case(p)0:return wi_mem0[idx];1:return wi_mem1[idx];2:return wi_mem2[idx];default:return wi_mem3[idx];endcase 3:case(p)0:return down_mem0[idx];1:return down_mem1[idx];2:return down_mem2[idx];default:return down_mem3[idx];endcase endcase endfunction
 function automatic logic [271:0] a_at(input int ph,row,group_index);case(ph)0:return initial_a[row*32+group_index];1:return context_a[row*32+group_index];2:return norm_a[row*32+group_index];default:return g_a[row*82+group_index];endcase endfunction
 function automatic logic [1023:0] m_at(input int ph,idx);case(ph)0:return qkv_gold[idx];1:return wo_gold[idx];2:return wi_gold[idx];default:return down_gold[idx];endcase endfunction
 always @(negedge clk)begin
  if(!rst_n)begin rvalid=0;rid=0;rdata=0;rresp=0;rlast=0;end
  else if(!dut.catalog_owns)begin
   arready=15;
   for(int p=0;p<4;p++)if(!rvalid[p]||last_r_fire[p])begin
   int pick;pick=-1;for(int q=7;q>=0;q--)if(live[p][(rotate[p]+q)%8]&&cycle>=eligible[p][(rotate[p]+q)%8])pick=(rotate[p]+q)%8;
   rvalid[p]=0;
   if(pick>=0&&cycle%2==0)begin rvalid[p]=1;rid[p]=pick;rdata[p]=word_at(bphase[p][pick],p,((baddr[p][pick]-bbase[p][pick])>>6)+bpos[p][pick]);rlast[p]=bpos[p][pick]+1==bsize[p][pick];rresp[p]=0;end
  end
  end
  if(rst_n&&full_active)begin
   out_ready=1;
   if(out_valid&&export_count==100&&!mid_started)begin mid_started=1;mid_hold_left=8;end
   if(out_valid&&export_count==4095&&!last_started)begin last_started=1;last_hold_left=17;end
   if(mid_hold_left>0)begin out_ready=0;mid_hold_left--;mid_held++;end
   if(last_hold_left>0)begin out_ready=0;last_hold_left--;last_held++;end
  end
 end
 always @(posedge clk)begin
  last_r_fire<=rvalid&rready;
  if(!rst_n)begin issue_owned=0;ps_owned=0;for(int p=0;p<4;p++)begin live[p]<=0;rotate[p]<=0;end end
  else if(full_active)begin
   if(parent_state!=old_state)begin $display("M007_FULLMODEL_ENCODER0_STATE state=%0d op_epoch=%0d cycle=%0d H=%0d QWO=%0d QLN=%0d QDown=%0d export=%0d",parent_state,dut.operation_epoch,cycle,h_commits,wo_q_commits,ln_q_commits,down_q_commits,export_count);$fflush();old_state=parent_state;end
   if(cmd_valid&&cmd_ready)begin commands++;command_cycle=cycle;expected_done={8'd0,8'd0,3'd0,96'd0,cmd_request,cmd_generation,cmd_epoch};if(commands!=1)$fatal(1,"one public parent BEGIN");$display("M007_FULLMODEL_ENCODER0_BEGIN kind=%0d cycle=%0d",cmd_kind,cycle);$fflush();end
   if(in_valid&&in_ready)input_count++;
   if(dut.v2_h_wr_commit)begin
    if(kind_run!=5||parent_state!=32||dut.v2_h_wr_addr!=h_commits||dut.v2_h_wr_data!==initial_h[h_commits]||dut.operation_epoch!=op_epoch(0))$fatal(1,"initial actual H commit/source");h_commits++;checked(32,"H_LOAD");
    if(h_commits==4096)begin $display("M007_FULLMODEL_ENCODER0_H_LOAD_END cycle=%0d vectors=4096",cycle);$fflush();end
   end
   if(dut.q_cmd_valid&&dut.q_cmd_ready)begin
    qphase=(kind_run==5?0:2)+qcommands;qcommands++;q_start_cycle[qphase]=cycle;
    if(qphase>3||dut.q_cmd_request!=cmd_request||dut.q_cmd_generation!=cmd_generation||dut.q_cmd_epoch!=op_epoch(qphase<2?1:4)||dut.q_cmd_slot!=(qphase==3)||dut.q_cmd_k!=(qphase==3?2624:1024))$fatal(1,"real quant command phase/identity/shape");
    $display("M007_FULLMODEL_ENCODER0_QUANT_BEGIN phase=%0d cycle=%0d",qphase,cycle);$fflush();
   end
   if(dut.q_awr_valid&&dut.q_awr_ready)begin if(dut.q_awr_data!==a_at(qphase,dut.q_awr_row,dut.q_awr_group))$fatal(1,"independent real quant/A bits phase%0d row%0d group%0d",qphase,dut.q_awr_row,dut.q_awr_group);awrites[qphase]++;checked(32,"QUANT_A");end
   if(dut.q_awr_rsp_valid&&dut.q_awr_rsp_ready)aacks[qphase]++;
   if(dut.front.q_out_valid&&dut.front.q_out_ready)quant_returns[qphase]++;
   if(dut.q_acfg_rsp_valid&&dut.q_acfg_rsp_ready)begin if(dut.q_acfg_status!=0||awrites[qphase]!=(qphase==3?10496:4096)||aacks[qphase]!=(qphase==3?10496:4096)||quant_returns[qphase]!=(qphase==3?10496:4096))$fatal(1,"complete real publication/writeACK/coverage");publications[qphase]++;$display("M007_FULLMODEL_ENCODER0_A_PUBLISH phase=%0d cycle=%0d",qphase,cycle);$fflush();end
   if(dut.m_cmd_valid&&dut.m_cmd_ready)begin
    matrix_phase=(kind_run==5?0:2)+mcommands;mcommands++;m_start_cycle[matrix_phase]=cycle;
    if(matrix_phase>3||dut.m_cmd_tensor!=tensor_at(matrix_phase)||dut.m_cmd_k!=k_at(matrix_phase)||dut.m_cmd_n!=n_at(matrix_phase)||dut.m_cmd_a_slot!=(matrix_phase==3)||dut.m_cmd_bias||dut.m_cmd_request!=cmd_request||dut.m_cmd_generation!=cmd_generation||dut.m_cmd_epoch!=op_epoch(matrix_phase<2?1:4)||dut.m_cmd_base!==fixture_base[matrix_phase]||dut.m_cmd_span!==fixture_span[matrix_phase])$fatal(1,"exact actual four-matrix descriptor/identity");
    if(input_count!=4096||publications[matrix_phase]!=1||dut.front.q_lease_active||dut.q_d_lease_active||dut.front.q_reservations!=0||dut.front.a_write_debt!=0||!dut.front.a_published||!dut.front.producer_closed||!dut.front.producer_success)$fatal(1,"matrix before actual quant/A publication and debt retirement");
    if(matrix_phase==1&&(layer_done_count!=1||nheads!=16||ctx_reads!=4096||ctx_responses!=4096||ctx_inputs!=4096||ctx_owned||!dut.c_idle||!dut.c_complete||!dut.l_layer_idle||!dut.v2_scratch_owner_active))$fatal(1,"WO before real context/layer retirement and scratch acquire");
    if(matrix_phase==2&&kind_run==5&&(catalog_runtime!=4||vector_done_count!=1||ln_done_count!=1||ln_q_commits!=4096))$fatal(1,"Wi before actual residual/plainLN/descriptor success");
    if(matrix_phase==3&&(m_done_count[2]!=1||g_done!=1||g_outputs!=41984||dut.pack_seq!=41984||dut.pack_full||!dut.g_engine_idle||dut.tanh_lease_active||!dut.r_res_st_idle||dut.r_res_fp_lease_active||dut.r_res_div_lease_active))$fatal(1,"Down before actual complete Wi/G/quant barrier");
    $display("M007_FULLMODEL_ENCODER0_MATRIX_BEGIN phase=%0d tensor=%0d K=%0d N=%0d cycle=%0d",matrix_phase,dut.m_cmd_tensor,dut.m_cmd_k,dut.m_cmd_n,cycle);$fflush();
   end
   if(!dut.catalog_owns)for(int p=0;p<4;p++)begin
    if(arvalid[p]&&arready[p])begin
     int ph;ph=-1;for(int h=0;h<4;h++)if(araddr[p]>=fixture_base[h][p]&&araddr[p]+64*(arlen[p]+1)<=fixture_base[h][p]+fixture_span[h][p])begin if(ph>=0)$fatal(1,"ambiguous original W source");ph=h;end
     if(ph<0||ph!=matrix_phase||live[p][arid[p]]||arlen[p]>15||araddr[p][5:0]!=0||{1'b0,araddr[p][11:0]}+64*(arlen[p]+1)>4096)$fatal(1,"actual four-source AXI ID/page/span");
     bphase[p][arid[p]]<=ph;bbase[p][arid[p]]<=fixture_base[ph][p];live[p][arid[p]]<=1;baddr[p][arid[p]]<=araddr[p];bsize[p][arid[p]]<=arlen[p]+1;bpos[p][arid[p]]<=0;eligible[p][arid[p]]<=cycle+40+2*(7-arid[p]);
    end
    if(rvalid[p]&&rready[p])begin if(bpos[p][rid[p]]+1==bsize[p][rid[p]])live[p][rid[p]]<=0;else bpos[p][rid[p]]<=bpos[p][rid[p]]+1;rotate[p]<=(rid[p]+1)%8;end
   end
   if(dut.matrix.core.trace_issue)begin
    int ss,seq,idx,groups;ss=dut.matrix.core.trace_block_s;seq=dut.matrix.core.trace_issue_seq;groups=k_at(matrix_phase)/32;
    if(ss>=blocks_at(matrix_phase)||seq!=issues[matrix_phase][ss])$fatal(1,"real four-matrix issue order");
    if(last_issue[matrix_phase][ss]>=0&&cycle-last_issue[matrix_phase][ss]!=1)$fatal(1,"continuous K issue");
    if(first_issue[matrix_phase][ss]<0)first_issue[matrix_phase][ss]=cycle;last_issue[matrix_phase][ss]=cycle;issues[matrix_phase][ss]++;
    issue_time[seq%64]=cycle;issue_seq[seq%64]=seq;issue_owned[seq%64]=1;ps_owned[seq%64]=0;
    if(seq%8==0)begin idx=9*(ss*groups+seq/32);for(int a=0;a<8;a++)expected_w[512*a+:512]=word_at(matrix_phase,(seq%32)/8,idx+a);temp=word_at(matrix_phase,(seq%32)/8,idx+8);expected_w[4096+:256]=temp[255:0];if({dut.matrix.core.trace_w_scale,dut.matrix.core.trace_w_q}!==expected_w)$fatal(1,"real W bytes/group mapping");end
    if(ss==0&&seq%32<8)begin for(int a=0;a<16;a++)begin logic[271:0]av;av=a_at(matrix_phase,16*(seq%8)+a,seq/32);expected_a[256*a+:256]=av[255:0];expected_a[4096+16*a+:16]=av[271:256];end if({dut.matrix.core.trace_a_scale,dut.matrix.core.trace_a_q}!==expected_a)$fatal(1,"actual A mapping");end
   end
   if(dut.matrix.core.math_read_fire)begin ps_time[dut.matrix.core.ps_next[5:0]]=cycle;ps_owned[dut.matrix.core.ps_next[5:0]]=1;end
   if(dut.matrix.core.state==2&&dut.matrix.core.normal_write_ack)begin int ix;ix=dut.matrix.core.ps_wr_rsp_tag[5:0];if(ps_owned[ix])begin if(cycle-ps_time[ix]>24)$fatal(1,"actual PS feedback24");if(cycle-ps_time[ix]>max_ps_feedback)max_ps_feedback=cycle-ps_time[ix];end end
   if(dut.matrix.core.trace_commit)begin
    int ss,seq,k;ss=dut.matrix.core.trace_block_s;seq=dut.matrix.core.trace_commit_seq;k=k_at(matrix_phase);
    if(seq!=commits[matrix_phase][ss]||!issue_owned[seq%64]||issue_seq[seq%64]!=seq)$fatal(1,"real issue/commit ownership");
    if(cycle-issue_time[seq%64]>max_issue_ack)max_issue_ack=cycle-issue_time[seq%64];if(cycle-issue_time[seq%64]>(matrix_phase<2?64:48))$fatal(1,"original per-island issueACK cap");commits[matrix_phase][ss]++;
    if(seq>=k-32)begin
     if(matrix_phase<2)begin if(dut.matrix.core.trace_commit_data!==(matrix_phase==0?qkv_prebias[32*ss+seq-992]:wo_prebias[32*ss+seq-992]))$fatal(1,"original QKV/WO prebias bits");end
     else for(int m=0;m<16;m++)for(int n=0;n<16;n++)begin logic[1023:0]ev;int rr,pp;rr=16*(seq%8)+m;pp=(seq%32)/8;ev=m_at(matrix_phase,ss*256+2*rr+pp/2);if(dut.matrix.core.trace_commit_data[16*m+n]!==ev[32*(16*(pp%2)+n)+:32])$fatal(1,"original FFN final prebias bits");end
    end
   end
   if(dut.m_out_valid&&dut.m_out_ready)begin
    int count,column;logic [1023:0] ev;count=m_outputs[matrix_phase];ev=m_at(matrix_phase,count);column=matrix_phase==2?32*(count/256)+2624*(count%2):64*(count/256)+32*(count%2);
    if(dut.m_out_data!==ev||dut.m_out_s!=count/256||dut.m_out_row!=(count%256)/2||dut.m_out_col!=column||dut.m_out_request!=cmd_request||dut.m_out_generation!=cmd_generation||dut.m_out_epoch!=op_epoch(matrix_phase<2?1:4))$fatal(1,"original full matrix bits/coords/identity phase%0d count%0d",matrix_phase,count);
    if(m_first_out[matrix_phase]<0)m_first_out[matrix_phase]=cycle;outputs[matrix_phase][count/256]++;m_outputs[matrix_phase]++;checked(32,"MATRIX");
    if(matrix_phase==2&&count==20991)begin g_tail_start=cycle;if(cycle-q_start_cycle[2]>92160)$fatal(1,"original quant acceptance through Wi last cap92160");end
    if(matrix_phase==0&&count==12287&&cycle-q_start_cycle[0]>57344)$fatal(1,"original QKV quant acceptance through last cap57344");
    if(count%256==255)begin $display("M007_FULLMODEL_ENCODER0_MATRIX_BLOCK phase=%0d block=%0d values=%0d cycle=%0d",matrix_phase,count/256,(count+1)*32,cycle);$fflush();end
    if(matrix_phase==0)begin qkv_count++;for(int c=0;c<32;c++)if(dut.m_out_data[c]!==qkvgold[((count%256)/2)*3072+column+c])$fatal(1,"independent original Attention preQKV source");end
    if(matrix_phase==0&&stop_qkv_blocks>0&&m_outputs[0]==stop_qkv_blocks*256)begin if(done_valid||mcommands!=1||layer_starts!=0||qkv_count!=stop_qkv_blocks*256)$fatal(1,"actual unfinished QKV prefix");observed_output.finish_capture(0);$display("M007_FULLMODEL_ENCODER0_QKV_PREFIX_PASS blocks=%0d values=%0d cycles=%0d unfinished=1",stop_qkv_blocks,qkv_count*32,cycle-command_cycle);$display("HARDWARE_AGENT_SIM_PASS M007_FULLMODEL_ENCODER0_QKV_PREFIX");$fflush();$finish;end
   end
   if(dut.v2_q_wr_commit)begin if(!dut.v2_scratch_owner_active||dut.v2_q_wr_addr!={dut.m_out_row,dut.m_out_col[9:5]}||dut.v2_q_wr_data!==dut.m_out_data)$fatal(1,"actual projection Q commit");if(matrix_phase==1)wo_q_commits++;else if(matrix_phase==3)down_q_commits++;else $fatal(1,"wrong projection Q producer");end
   if(dut.m_done_valid&&dut.m_done_ready)begin
    if(dut.m_status!=0||dut.m_done_request!=cmd_request||dut.m_done_generation!=cmd_generation||dut.m_done_epoch!=op_epoch(matrix_phase<2?1:4))$fatal(1,"actual real matrix terminal identity/status");m_done_count[matrix_phase]++;m_done_cycle[matrix_phase]=cycle;
    for(int ss=0;ss<blocks_at(matrix_phase);ss++)if(issues[matrix_phase][ss]!=k_at(matrix_phase)||commits[matrix_phase][ss]!=k_at(matrix_phase)||outputs[matrix_phase][ss]!=256)$fatal(1,"full actual matrix issue/ACK/output shape");
    if(matrix_phase==1&&kind_run==5&&wo_q_commits!=4096||matrix_phase==3&&kind_run==5&&down_q_commits!=4096)$fatal(1,"matrix done without4096 actual Q commits");
    if(matrix_phase==3&&cycle-m_start_cycle[3]>56576)$fatal(1,"Down real service cap56576");
    $display("M007_FULLMODEL_ENCODER0_MATRIX_END phase=%0d cycle=%0d",matrix_phase,cycle);$fflush();
   end
   if(dut.g_cmd_valid&&dut.g_cmd_ready)begin gcommands++;g_cmd_cycle=cycle;if(gcommands!=1||!dut.ws_g_enable||!dut.r_res_fp_lease_active)$fatal(1,"real G admission/unique arena");end
   if(dut.resident.g_g_wr_valid&&dut.resident.g_g_wr_ready)g_writes++;
   if(dut.resident.g_g_wr_rsp_valid&&dut.resident.g_g_wr_rsp_ready)begin g_acks++;if(dut.resident.g_g_wr_rsp_tag[1]&&dut.resident.g_g_wr_rsp_tag[8:2]==127)g_ready_cycle[dut.resident.g_g_wr_rsp_tag[15:9]]=cycle;end
   if(dut.resident.g_g_rd_valid&&dut.resident.g_g_rd_ready)begin
    int ss;ss=dut.resident.g_g_rd_tag[15:9];if(g_read_count[ss]==0)g_first_read[ss]=cycle;else if(cycle-g_last_read[ss]!=1)$fatal(1,"G in-block read II1");g_last_read[ss]=cycle;g_read_count[ss]++;g_reads++;
   end
   for(int ss=0;ss<82;ss++)if(g_eligible_cycle[ss]<0&&g_ready_cycle[ss]>=0)begin
    if(ss==0&&g_cmd_cycle>=0)g_eligible_cycle[ss]=g_ready_cycle[ss]>g_cmd_cycle?g_ready_cycle[ss]:g_cmd_cycle;
    else if(ss>0&&g_read_count[ss-1]==512)g_eligible_cycle[ss]=g_ready_cycle[ss]>g_last_read[ss-1]+1?g_ready_cycle[ss]:g_last_read[ss-1]+1;
   end
   if(dut.resident.joint.g_engine.pair_release_valid&&dut.resident.joint.g_engine.pair_release_ready)begin
    int ss;ss=dut.resident.joint.g_engine.pair_release_s;g_releases++;g_release_cycle[ss]=cycle;
    if(g_output_count[ss]!=512||g_read_count[ss]!=512||g_first_read[ss]<g_eligible_cycle[ss]||g_first_read[ss]>g_eligible_cycle[ss]+1||g_first_consume[ss]-g_eligible_cycle[ss]>256||cycle-g_eligible_cycle[ss]>768)$fatal(1,"real G eligible/block service cap s=%0d",ss);
    $display("M007_FFN_G_SERVICE s=%0d ready=%0d eligible=%0d first_read=%0d first_output=%0d release=%0d service=%0d supply_wait=%0d",ss,g_ready_cycle[ss],g_eligible_cycle[ss],g_first_read[ss],g_first_consume[ss],cycle,cycle-g_eligible_cycle[ss],ss==0?0:g_ready_cycle[ss]-g_last_read[ss-1]-1);$fflush();
   end
   for(int n=0;n<9;n++)if(dut.resident.g_fp_rsp_valid[n])begin
    int gw,vi,si;gw=n==0?2:n==1?3:n==2?4:n==3?5:n==4?6:n==5?8:n==6?9:n==7?10:11;vi=int'(dut.resident.g_fp_rsp_tag[n][15:0]);
    if(packed_check&&(vi>=0&&vi<41984)&&(dut.resident.g_fp_rsp_data[n]===node_expected[n][vi])&&(dut.resident.g_fp_rsp_status[n]===256'b0))node_checks+=8;
    else begin
    for(int l=0;l<8;l++)begin si=((vi%512)/4)*2624+(vi/512)*32+(vi%4)*8+l;if(dut.resident.g_fp_rsp_data[n][l]!==vectors[si][383-gw*32-:32]||dut.resident.g_fp_rsp_status[n][l]!==0)$fatal(1,"original FP node n=%0d vi=%0d lane=%0d",n,vi,l);node_checks++;end
    end
   end
   if(dut.resident.g_sfu_rsp_valid&&dut.resident.g_sfu_rsp_ready)begin
    int vi,si;vi=int'(dut.resident.g_sfu_rsp_tag[15:0]);if(dut.resident.tanh_rsp_mask!==8'hff)$fatal(1,"original TANH mask");
    if(packed_check&&(vi>=0&&vi<41984)&&(dut.resident.g_sfu_rsp_data===tanh_expected[vi])&&(dut.resident.g_sfu_rsp_status===256'b0))node_checks+=8;
    else begin
    for(int l=0;l<8;l++)begin si=((vi%512)/4)*2624+(vi/512)*32+(vi%4)*8+l;if(dut.resident.g_sfu_rsp_data[l]!==vectors[si][159:128]||dut.resident.g_sfu_rsp_status[l]!==0)$fatal(1,"original TANH H");node_checks++;end
    end
   end
   if(dut.g_out_valid&&dut.g_out_ready)begin
    int si;logic[7:0][31:0]ev;
    if(packed_check&&g_outputs>=0&&g_outputs<41984)ev=g_expected[g_outputs];
    else begin
    for(int l=0;l<8;l++)begin si=((g_outputs%512)/4)*2624+(g_outputs/512)*32+(g_outputs%4)*8+l;ev[l]=vectors[si][31:0];end
    end
    if(dut.g_out_tag!=={cmd_generation,op_epoch(4),16'b0,16'(g_outputs)}||dut.g_out_data!==ev||dut.g_out_status!==256'b0)$fatal(1,"real G output bits/tag/status");if(g_output_count[g_outputs/512]==0)g_first_consume[g_outputs/512]=cycle;else if(cycle-g_last_consume[g_outputs/512]!=1)$fatal(1,"G in-block output II1");g_last_consume[g_outputs/512]=cycle;g_output_count[g_outputs/512]++;g_outputs++;checked(8,"G");
    if(g_outputs%512==0)begin $display("M007_FFN_G_BLOCK s=%0d cycle=%0d values=%0d nodes=%0d",g_outputs/512-1,cycle,g_outputs*8,node_checks);$fflush();end
   end

   if(dut.g_done_valid&&dut.g_done_ready)begin g_done++;if(cycle-g_tail_start>1280)$fatal(1,"original FFN unhidden tail1280");if(dut.g_done_status!=0||dut.g_done_cancelled||g_outputs!=41984||g_releases!=82||g_reads!=41984||g_writes!=20992||g_acks!=20992||node_checks!=3358720)$fatal(1,"actual complete G nodes/data/service/debt terminal");end
   if(stop_ffn_blocks>0&&g_outputs>=stop_ffn_blocks*512&&m_outputs[2]>=stop_ffn_blocks*256)begin if(done_valid||publications[3]!=0||m_done_count[2]!=0||g_done!=0||m_outputs[3]!=0)$fatal(1,"FFN prefix must remain unfinished");observed_output.finish_capture(0);$display("M007_FULLMODEL_ENCODER0_FFN_PREFIX_PASS blocks=%0d Wi_values=%0d G_values=%0d nodes=%0d packed=%0d cycles=%0d unfinished=1",stop_ffn_blocks,m_outputs[2]*32,g_outputs*8,node_checks,packed_check,cycle-command_cycle);$display("HARDWARE_AGENT_SIM_PASS M007_FULLMODEL_ENCODER0_FFN_PREFIX");$fflush();$finish;end
   if(dut.l_start_valid&&dut.l_start_ready)begin if(qkv_count!=12288||m_done_count[0]!=1)$fatal(1,"Attention before all actual QKV outputs and receipt");layer_starts++;end
   if(dut.c_rd_valid&&dut.c_rd_ready)begin if(ctx_owned||dut.c_rd_tag!=ctx_reads||dut.c_rd_query!=ctx_reads/32||dut.c_rd_head!=(ctx_reads%32)/2||dut.c_rd_half!=ctx_reads%2||dut.c_rd_generation!=cmd_generation)$fatal(1,"actual public context read identity/order");ctx_pending=ctx_reads;ctx_owned=1;ctx_reads++;end
   if(dut.c_rsp_valid&&dut.c_rsp_ready)begin int q,h,half;q=ctx_pending/32;h=(ctx_pending%32)/2;half=ctx_pending%2;if(!ctx_owned||dut.c_rsp_tag!=ctx_pending)$fatal(1,"actual context response debt/tag");for(int c=0;c<32;c++)if(dut.c_rsp_data[c]!==contextgold[(h*128+q)*64+half*32+c])$fatal(1,"original actual public context bits");ctx_owned=0;ctx_responses++;checked(32,"CONTEXT_PUBLIC");end
   if(dut.c_out_valid&&dut.c_out_ready)begin if(dut.c_out_row!=ctx_inputs/32||dut.c_out_group!=ctx_inputs%32||dut.c_out_data!==wo_inputs[ctx_inputs])$fatal(1,"original context to quant stream");ctx_inputs++;end
   if(dut.l_done_valid&&dut.l_done_ready)begin
    if(dut.l_done_status!=0||dut.l_done_request_id!=cmd_request||dut.l_done_generation!=cmd_generation||nheads!=16||layer_head_completed!=16'hffff||dut.l_head_context_valid!=16'hffff||dut.l_error_valid||dut.l_done_cycles>188544)$fatal(1,"original full Attention layer terminal/coverage/cycle");
    for(int st=0;st<26;st++)if((dut.l_check_completed[st]|dut.l_check_unreachable[st]|dut.l_check_dominated[st])!==16'hffff||((dut.l_check_completed[st]&dut.l_check_unreachable[st])|(dut.l_check_completed[st]&dut.l_check_dominated[st])|(dut.l_check_unreachable[st]&dut.l_check_dominated[st]))!=0)$fatal(1,"Attention Check classification/overlap");
    if((dut.l_av_check_completed|dut.l_av_check_unreachable|dut.l_av_check_dominated)!=={2048{1'b1}}||((dut.l_av_check_completed&dut.l_av_check_unreachable)|(dut.l_av_check_completed&dut.l_av_check_dominated)|(dut.l_av_check_unreachable&dut.l_av_check_dominated))!=0)$fatal(1,"AV Check classification/overlap");
    layer_done_count++;$display("M007_FULLMODEL_ENCODER0_ATTENTION_END heads=%0d cycle=%0d layer_cycles=%0d",nheads,cycle,dut.l_done_cycles);$fflush();
   end
   if(dut.v2_vector_start_valid&&dut.v2_vector_start_ready)begin if(!dut.v2_resident_inputs_ready||!dut.v2_scratch_owner_active||dut.operation_epoch!=op_epoch(vector_done_count==0?2:5))$fatal(1,"real residual context/epoch/source qualification");$display("M007_FULLMODEL_ENCODER0_VECTOR_BEGIN phase=%0d cycle=%0d",vector_done_count,cycle);$fflush();end
   if(dut.resident.vector_h_wr_valid&&dut.resident.vector_h_wr_ready)begin int ph,addr;ph=vector_done_count;addr=dut.resident.vector_h_wr_addr;if(!dut.resident.vector_h_wr_commit||dut.resident.vector_h_wr_data!==(ph==0?residual_a[addr]:final_h[addr]))$fatal(1,"original real residual H write bits/commit phase%0d address%0d",ph,addr);vector_h_commits[ph]++;last_h_commit=cycle;checked(32,"RESIDUAL_H");if(vector_h_commits[ph]==4096)begin $display("M007_FULLMODEL_ENCODER0_VECTOR_LAST_H phase=%0d cycle=%0d",ph,cycle);$fflush();end end
   if(dut.v2_vector_done_valid&&dut.v2_vector_done_ready)begin if(dut.v2_vector_done_status!=0||dut.v2_vector_issued_vectors!=4096||dut.v2_vector_retired_vectors!=4096||vector_h_commits[vector_done_count]!=4096||!dut.v2_h_bank_idle||dut.r_res_fp_lease_active)$fatal(1,"actual residual full finite H/debt/release terminal");$display("M007_FULLMODEL_ENCODER0_VECTOR_END phase=%0d cycle=%0d",vector_done_count,cycle);$fflush();vector_done_count++;end
   if(dut.v2_resident_ln_start_valid&&dut.v2_resident_ln_start_ready)begin if(vector_done_count!=1||!dut.v2_resident_ln_source_qualified||dut.operation_epoch!=op_epoch(3))$fatal(1,"LN finite witness must come from real full successful residual");$display("M007_FULLMODEL_ENCODER0_LN_BEGIN cycle=%0d",cycle);$fflush();end
   if(dut.resident.p_q_wr_commit)begin int addr;addr=dut.resident.p_q_wr_addr;if(dut.resident.p_q_wr_data!==norm_ff[addr]||dut.operation_epoch!=op_epoch(3))$fatal(1,"original full actual plainLN Q commit bits/epoch");ln_q_commits++;checked(32,"LN_Q");if(ln_q_commits==4096)begin $display("M007_FULLMODEL_ENCODER0_LN_LAST_Q cycle=%0d",cycle);$fflush();end end
   if(dut.v2_resident_ln_done_valid&&dut.v2_resident_ln_done_ready)begin if(dut.v2_resident_ln_done_status!=0||dut.v2_resident_ln_done_kind!=0||dut.v2_resident_ln_issued_vectors!=4096||dut.v2_resident_ln_written_vectors!=4096||ln_q_commits!=4096||dut.r_res_fp_lease_active||dut.r_res_div_lease_active)$fatal(1,"actual LN full Q/native bank/FP/DIV terminal");ln_done_count++;$display("M007_FULLMODEL_ENCODER0_LN_END cycle=%0d",cycle);$fflush();end
   if(holding&&(!out_valid||{out_data,out_row,out_col,out_slot}!==held_out))$fatal(1,"public final H/Down stable under held ready");holding=out_valid&&!out_ready;held_out={out_data,out_row,out_col,out_slot};
   if(out_valid&&out_ready)begin
    if(out_slot!=0)$fatal(1,"single Encoder output slot");
    if(kind_run==5)begin if(parent_state!=56||export_count>=4096||out_row!=export_count/32||out_col!=32*(export_count%32)||out_data!==final_h[export_count]||vector_done_count!=2||ln_done_count!=1)$fatal(1,"original final actual H export/source/order");end
    else if(parent_state!=12||out_data!==down_gold[export_count])$fatal(1,"actual standalone Down public output");
    export_count++;last_export=cycle;checked(32,"FINAL_PUBLIC");if(export_count==4096)begin $display("M007_FULLMODEL_ENCODER0_EXPORT_LAST cycle=%0d values=131072",cycle);$fflush();end
   end
   if(done_valid)begin
    if(done_op!=2)$fatal(1,"v3 BEGIN receipt op");
    if({done_status,source_status,error_domain,error_tuple,done_request,done_generation,done_epoch}!==expected_done||mcommands!=(kind_run==5?4:2)||qcommands!=(kind_run==5?4:2)||gcommands!=1||g_done!=1||export_count!=4096||m_done_count[3]!=1||!dut.ws_a_enable||dut.ws_rearm||!dut.v2_shared_resources_idle||!dut.v2_resident_bank_idle||!dut.v2_scratch_retired)$fatal(1,"complete independent parent success/debt/identity response");
    if(first_done<0)begin first_done=cycle;$display("M007_FULLMODEL_ENCODER0_FIRST_DONE cycle=%0d last_H=%0d last_export=%0d",cycle,last_h_commit,last_export);$fflush();end
   end
   if(done_valid&&done_ready)parent_retired++;
   if(dut.r_res_fp_protocol_fault||dut.r_res_div_protocol_fault||dut.l_check_coverage_fault)$fatal(1,"actual shared protocol/coverage fault");
   if(cycle>40000000)$fatal(1,"40Mcycle cap");
   if(stop_down_blocks>0&&m_outputs[3]>=stop_down_blocks*256&&(kind_run==5?down_q_commits:export_count)>=stop_down_blocks*256)begin
    if(done_valid||m_done_count[3]!=0||m_done_count[2]!=1||g_done!=1||g_outputs!=41984||node_checks!=3358720||publications[3]!=1||awrites[3]!=10496||aacks[3]!=10496||quant_returns[3]!=10496)$fatal(1,"Down prefix requires actual complete Wi/G/A1 producer and unfinished Down");
    // Let all observation callbacks finish the accepted edge before closing files.
    #0.1;observed_output.finish_capture(0);
    $display("M007_FULLMODEL_ENCODER0_DOWN_PREFIX_PASS kind=%0d blocks=%0d Wi_values=%0d G_values=%0d nodes=%0d A1_groups=%0d Down_values=%0d actual_Q_commits=%0d public_groups=%0d cycles=%0d unfinished=1",kind_run,stop_down_blocks,m_outputs[2]*32,g_outputs*8,node_checks,aacks[3],m_outputs[3]*32,down_q_commits,export_count,cycle-command_cycle);
    $display("HARDWARE_AGENT_SIM_PASS M007_FULLMODEL_ENCODER0_DOWN_PREFIX");$fflush();$finish;
   end
  end
 end
 always @(posedge clk)if(rst_n&&parent_state==7)begin
  if(dut.resident.joint.layer.rope_wr_commit_valid)begin
   for(int c=0;c<64;c++)if(dut.resident.joint.layer.rope_wr_q[c]!==postgold[(dut.resident.joint.layer.rope_wr_token*3*16+dut.resident.joint.layer.rope_wr_head)*64+c]||dut.resident.joint.layer.rope_wr_k[c]!==postgold[((dut.resident.joint.layer.rope_wr_token*3+1)*16+dut.resident.joint.layer.rope_wr_head)*64+c])$fatal(1,"parent real RoPE data");nrope=nrope+1;checked(128,"ROPE");
   if(nrope%512==0)begin $display("MATRIX_PROGRESS parent_RoPE_commits=%0d cycle=%0d",nrope,cycle);$fflush();end
  end
  if(dut.resident.joint.layer.h_start_valid&&dut.resident.joint.layer.h_start_ready)begin head_start_cycle=cycle;$display("M007_FULLMODEL_HEAD_BEGIN head=%0d cycle=%0d",dut.resident.joint.layer.active_head,cycle);$fflush();end
  if(dut.resident.a_res_fp_rsp_phase==2&&dut.resident.a_res_st_ps_wr_valid&&dut.resident.a_res_st_ps_wr_ready)begin
   int group,key;group=int'(dut.resident.a_res_st_ps_wr_tag[11:7]);key=int'(dut.resident.a_res_st_ps_wr_tag[6:0]);
   for(int q=0;q<4;q++)begin int r,b;r=group*4+q;b=(key/64)*512+(r%16)*32+key%32;if(dut.resident.a_res_st_ps_wr_data[b]!==scoregold[(int'(dut.resident.joint.layer.active_head)*128+r)*128+key])$fatal(1,"parent real score");nscore=nscore+1;head_score[dut.resident.joint.layer.active_head]=head_score[dut.resident.joint.layer.active_head]+1;checked(1,"SCORE");end
   if(nscore%4096==0)begin $display("MATRIX_PROGRESS parent_score_words=%0d cycle=%0d",nscore,cycle);$fflush();end
  end
  if(dut.resident.joint.layer.state==7&&dut.resident.joint.layer.h_check_qk_done&&!max_checked[dut.resident.joint.layer.active_head])begin for(int r=0;r<128;r++)if(dut.resident.joint.layer.h_maximum[r]!==maxgold[int'(dut.resident.joint.layer.active_head)*128+r])$fatal(1,"parent real maximum");max_checked[dut.resident.joint.layer.active_head]=1;head_maximum[dut.resident.joint.layer.active_head]=128;checked(128,"MAXIMUM");end
  if(dut.resident.joint.layer.head.sm_prob_wr_valid&&dut.resident.joint.layer.head.sm_prob_wr_ready)begin
   int r,k;r=int'(dut.resident.joint.layer.head.sm_prob_wr_tag[10:4]);k=int'(dut.resident.joint.layer.head.sm_prob_wr_tag[3:0])*8;
   for(int c=0;c<8;c++)begin if(dut.resident.joint.layer.head.sm_prob_wr_data[c]!==probgold[(int'(dut.resident.joint.layer.active_head)*128+r)*128+k+c])$fatal(1,"parent real probability");nprob=nprob+1;head_prob[dut.resident.joint.layer.active_head]=head_prob[dut.resident.joint.layer.active_head]+1;checked(1,"PROB");end
  end
  if(dut.resident.joint.layer.head.sm_prob_wr_ack_valid&&dut.resident.joint.layer.head.sm_prob_wr_ack_ready)begin nprob_ack=nprob_ack+1;head_prob_ack[dut.resident.joint.layer.active_head]=head_prob_ack[dut.resident.joint.layer.active_head]+1;if(nprob_ack%512==0)begin $display("MATRIX_PROGRESS parent_prob_ack=%0d cycle=%0d",nprob_ack,cycle);$fflush();end end
  if(dut.resident.a_res_st_context_wr_valid&&dut.resident.a_res_st_context_wr_ready)for(int c=0;c<64;c++)if(dut.resident.a_res_st_context_wr_mask[c])begin
   int h,r;h=int'(dut.resident.a_res_st_context_wr_addr[c][10:7]);r=int'(dut.resident.a_res_st_context_wr_addr[c][6:0]);if(dut.resident.a_res_st_context_wr_data[c]!==contextgold[(h*128+r)*64+c])$fatal(1,"parent real context");ncontext=ncontext+1;head_context[dut.resident.joint.layer.active_head]=head_context[dut.resident.joint.layer.active_head]+1;checked(1,"CONTEXT");
  end
  if(dut.resident.joint.layer.h_done_valid&&dut.resident.joint.layer.h_done_ready)begin
   if(dut.resident.joint.layer.h_done_status!=0||dut.resident.joint.layer.h_done_cycles>11648||head_score[dut.resident.joint.layer.active_head]!=16384||head_prob[dut.resident.joint.layer.active_head]!=16384||head_context[dut.resident.joint.layer.active_head]!=8192||head_prob_ack[dut.resident.joint.layer.active_head]!=2048||head_maximum[dut.resident.joint.layer.active_head]!=128||!max_checked[dut.resident.joint.layer.active_head]||nrope!=2048||qkv_count!=12288||layer_starts!=1||dut.resident.joint.layer.active_head!=nheads||dut.resident.joint.layer.h_done_request_id!=cmd_request||dut.resident.joint.layer.h_done_generation!=cmd_generation||dut.resident.joint.layer.h_done_head!=nheads)$fatal(1,"parent per-head numeric/maximum/event/identity/cycle coverage");
   $display("M007_FULLMODEL_HEAD_END head=%0d cycle=%0d head_cycles=%0d",dut.resident.joint.layer.active_head,cycle,dut.resident.joint.layer.h_done_cycles);$fflush();nheads=nheads+1;
   if(stop_after_head>0&&nheads==stop_after_head)begin
    if(done_valid||mcommands!=1||ctx_reads!=0||m_outputs[1]!=0)$fatal(1,"head pilot must remain unfinished actual parent");
    observed_output.finish_capture(0);$display("M007_FULLMODEL_ENCODER0_HEAD_PREFIX_PASS heads=%0d QKV32=%0d score=%0d prob=%0d context=%0d maxima=%0d elapsed=%0d",nheads,qkv_count,nscore,nprob,ncontext,128*nheads,cycle-command_cycle);$display("HARDWARE_AGENT_SIM_PASS M007_FULLMODEL_ENCODER0_HEAD_PREFIX");$fflush();$finish;
   end
  end
 end

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
 task automatic progress(input int n,input string phase);begin checked(n,phase);end endtask
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
  if(dut.runtime_catalog&&dut.cat_rsp_valid&&dut.cat_rsp_ready&&!dut.cat_fault)begin
   if(catalog_runtime>=4||dut.cat_word!=4+catalog_runtime||!dut.m_transport_idle||!dut.q_cmd_ready||dut.q_done_valid)$fatal(1,"runtime refill before real old debt retirement/order");
   if(catalog_runtime>=2&&(m_done_count[1]!=1||ctx_responses!=4096||!dut.l_layer_idle||dut.v2_scratch_owner_active))$fatal(1,"FFN catalog before true WO/context/scratch retirement");
   catalog_runtime++;$display("M007_FULLMODEL_ENCODER0_CATALOG_REFILL count=%0d epoch=%0d cycle=%0d",catalog_runtime,dut.operation_epoch,cycle);$fflush();
  end
  if(cycle>40000000)$fatal(1,"40Mcycle watchdog");
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
  if(!$value$plusargs("ORIGINAL=%s",original_fixture))$fatal(1,"original embedding_norm/final checker fixture required");
  if(!$value$plusargs("MATRIX=%s",matrix_fixture))$fatal(1,"original QKV matrix fixture required");
  if(!$value$plusargs("INPUT=%s",input_fixture))$fatal(1,"original matrix input fixture required");
  if(!$value$plusargs("ATTENTION=%s",attention_fixture))$fatal(1,"original Attention fixture required");
  if(!$value$plusargs("CONTEXT=%s",context_fixture))$fatal(1,"original WO fixture required");
  if(!$value$plusargs("FFN=%s",ffn_fixture))$fatal(1,"original FFN checker fixture required");
  if(!$value$plusargs("WI=%s",wi_weights))$fatal(1,"original Wi weights required");
  if(!$value$plusargs("DOWN=%s",down_weights))$fatal(1,"original Down weights required");
  if(!$value$plusargs("G=%s",g_fixture))$fatal(1,"original G node record required");
  if(!$value$plusargs("RESIDUAL=%s",residual_fixture))$fatal(1,"original residual checker required");
  if(!$value$plusargs("KIND=%d",kind_run))kind_run=5;
  if(!$value$plusargs("PACKED=%d",packed_check))packed_check=1;
  if(!$value$plusargs("STOP_QKV_BLOCKS=%d",stop_qkv_blocks))stop_qkv_blocks=0;
  if(!$value$plusargs("STOP_AFTER_HEAD=%d",stop_after_head))stop_after_head=0;
  if(!$value$plusargs("STOP_FFN_BLOCKS=%d",stop_ffn_blocks))stop_ffn_blocks=0;
  if(!$value$plusargs("STOP_DOWN_BLOCKS=%d",stop_down_blocks))stop_down_blocks=0;
  if(!(kind_run==5)||!(packed_check==0||packed_check==1)||!(stop_qkv_blocks==0||stop_qkv_blocks==1||stop_qkv_blocks==3)||!(stop_after_head==0||stop_after_head==1||stop_after_head==2)||!(stop_ffn_blocks==0||stop_ffn_blocks==1||stop_ffn_blocks==3||stop_ffn_blocks==16)||!(stop_down_blocks==0||stop_down_blocks==1))$fatal(1,"bounded approved checker modes");
  if(int'(stop_qkv_blocks>0)+int'(stop_after_head>0)+int'(stop_ffn_blocks>0)+int'(stop_down_blocks>0)>1)$fatal(1,"one actual prefix endpoint per run");
  $display("M007_ENCODER0_FIXTURE_BEGIN kind=%0d packed=%0d",kind_run,packed_check);$fflush();
  $readmemh({input_fixture,"/qkv_0_weight/input.hex"},original_qkv_input);$readmemh({original_fixture,"/embedding_norm.groups1024.hex"},initial_h);for(int idx=0;idx<4096;idx++)if(initial_h[idx]!==original_qkv_input[idx])$fatal(1,"original embedding_norm source differs from independent QKV fixture input");$readmemh({original_fixture,"/encoder_00_out.groups1024.hex"},final_h);
  $readmemh({residual_fixture,"/GOLD.hex"},residual_scalar);
  for(int group_index=0;group_index<4096;group_index++)for(int lane=0;lane<32;lane++)residual_a[group_index][32*lane+:32]=residual_scalar[32*group_index+lane];
  $readmemh({matrix_fixture,"/qkv_0_weight/output.hex"},qkv_gold);$readmemh({matrix_fixture,"/qkv_0_weight/pre_bias.hex"},qkv_prebias);$readmemh({matrix_fixture,"/qkv_0_weight/a_write.hex"},initial_a);
  $readmemh({context_fixture,"/wo_0_weight/output.hex"},wo_gold);$readmemh({context_fixture,"/wo_0_weight/input.hex"},wo_inputs);$readmemh({context_fixture,"/wo_0_weight/a_write.hex"},context_a);$readmemh({context_fixture,"/wo_0_weight/pre_bias.hex"},wo_prebias);
  $readmemh({ffn_fixture,"/norm_ff_quant/source_f32_groups.hex"},norm_ff);$readmemh({ffn_fixture,"/norm_ff_quant/a_write_row_major.hex"},norm_a);$readmemh({ffn_fixture,"/g_quant/a_write_row_major.hex"},g_a);$readmemh({ffn_fixture,"/wi_native_output.hex"},wi_gold);$readmemh({ffn_fixture,"/down/output.hex"},down_gold);$readmemh(g_fixture,vectors);
  $readmemh({matrix_fixture,"/qkv_0_weight/p0.hex"},qkv_mem0);
  $readmemh({matrix_fixture,"/qkv_0_weight/p1.hex"},qkv_mem1);
  $readmemh({matrix_fixture,"/qkv_0_weight/p2.hex"},qkv_mem2);
  $readmemh({matrix_fixture,"/qkv_0_weight/p3.hex"},qkv_mem3);
  $readmemh({context_fixture,"/wo_0_weight/p0.hex"},wo_mem0);
  $readmemh({context_fixture,"/wo_0_weight/p1.hex"},wo_mem1);
  $readmemh({context_fixture,"/wo_0_weight/p2.hex"},wo_mem2);
  $readmemh({context_fixture,"/wo_0_weight/p3.hex"},wo_mem3);
  $readmemh({wi_weights,"/p0.hex"},wi_mem0);
  $readmemh({wi_weights,"/p1.hex"},wi_mem1);
  $readmemh({wi_weights,"/p2.hex"},wi_mem2);
  $readmemh({wi_weights,"/p3.hex"},wi_mem3);
  $readmemh({down_weights,"/p0.hex"},down_mem0);
  $readmemh({down_weights,"/p1.hex"},down_mem1);
  $readmemh({down_weights,"/p2.hex"},down_mem2);
  $readmemh({down_weights,"/p3.hex"},down_mem3);
  $readmemh({attention_fixture,"/cos_full.mem"},cf);$readmemh({attention_fixture,"/sin_full.mem"},sf);$readmemh({attention_fixture,"/mask.mem"},maskmem);$readmemh({attention_fixture,"/encoder0_pre_qkv.mem"},qkvgold);$readmemh({attention_fixture,"/encoder0_post_qkv.mem"},postgold);$readmemh({attention_fixture,"/encoder0_score.mem"},scoregold);$readmemh({attention_fixture,"/encoder0_maximum.mem"},maxgold);$readmemh({attention_fixture,"/encoder0_prob.mem"},probgold);$readmemh({attention_fixture,"/encoder0_context.mem"},contextgold);
  $display("M007_ENCODER0_FIXTURE_END");$fflush();
  if(packed_check)begin
   $display("M007_ENCODER0_PREPACK_BEGIN bytes=14778368");$fflush();
   for(int vi=0;vi<41984;vi++)for(int lane=0;lane<8;lane++)begin
    int si;si=((vi%512)/4)*2624+(vi/512)*32+(vi%4)*8+lane;
    for(int node=0;node<9;node++)begin int gw;gw=node==0?2:node==1?3:node==2?4:node==3?5:node==4?6:node==5?8:node==6?9:node==7?10:11;node_expected[node][vi][32*lane+:32]=vectors[si][383-gw*32-:32];end
    tanh_expected[vi][32*lane+:32]=vectors[si][159:128];g_expected[vi][32*lane+:32]=vectors[si][31:0];
   end
   $display("M007_ENCODER0_PREPACK_END vectors=41984 unchanged_original_records=335872");$fflush();
  end
  for(int ph=0;ph<4;ph++)begin m_outputs[ph]=0;m_done_count[ph]=0;quant_returns[ph]=0;awrites[ph]=0;aacks[ph]=0;publications[ph]=0;m_start_cycle[ph]=-1;m_first_out[ph]=-1;m_done_cycle[ph]=-1;q_start_cycle[ph]=-1;for(int ss=0;ss<82;ss++)begin issues[ph][ss]=0;commits[ph][ss]=0;outputs[ph][ss]=0;first_issue[ph][ss]=-1;last_issue[ph][ss]=-1;end end
  for(int ss=0;ss<82;ss++)begin g_ready_cycle[ss]=-1;g_eligible_cycle[ss]=-1;g_first_read[ss]=-1;g_last_read[ss]=-1;g_first_consume[ss]=-1;g_last_consume[ss]=-1;g_read_count[ss]=0;g_output_count[ss]=0;g_release_cycle[ss]=-1;end
  for(int h=0;h<16;h++)begin head_score[h]=0;head_prob[h]=0;head_context[h]=0;head_prob_ack[h]=0;head_maximum[h]=0;end
  vector_h_commits[0]=0;vector_h_commits[1]=0;
  fixture_base[0][0]=64'd1048576;fixture_span[0][0]=64'd884736;
  fixture_base[0][1]=64'd1048576;fixture_span[0][1]=64'd884736;
  fixture_base[0][2]=64'd1048576;fixture_span[0][2]=64'd884736;
  fixture_base[0][3]=64'd1048576;fixture_span[0][3]=64'd884736;
  fixture_base[1][0]=64'd1933312;fixture_span[1][0]=64'd294912;
  fixture_base[1][1]=64'd1933312;fixture_span[1][1]=64'd294912;
  fixture_base[1][2]=64'd1933312;fixture_span[1][2]=64'd294912;
  fixture_base[1][3]=64'd1933312;fixture_span[1][3]=64'd294912;
  fixture_base[2][0]=64'd2228224;fixture_span[2][0]=64'd1511424;
  fixture_base[2][1]=64'd2228224;fixture_span[2][1]=64'd1511424;
  fixture_base[2][2]=64'd2228224;fixture_span[2][2]=64'd1511424;
  fixture_base[2][3]=64'd2228224;fixture_span[2][3]=64'd1511424;
  fixture_base[3][0]=64'd3739648;fixture_span[3][0]=64'd755712;
  fixture_base[3][1]=64'd3739648;fixture_span[3][1]=64'd755712;
  fixture_base[3][2]=64'd3739648;fixture_span[3][2]=64'd755712;
  fixture_base[3][3]=64'd3739648;fixture_span[3][3]=64'd755712;

  if(!$value$plusargs("DATA=%s",data_dir))$fatal(1,"v3 original model coefficients required");
  rope_dir=attention_fixture;
  $readmemh({data_dir,"/catalog.hex"},catalog_mem);$readmemh({data_dir,"/bias.words.hex"},bias_mem);$readmemh({data_dir,"/gamma.words.hex"},gamma_mem);$readmemh({data_dir,"/type.words.hex"},type_mem);
  $readmemh({rope_dir,"/cos_full.mem"},rope_load);for(int j=0;j<8192;j++)rope_mem[0][j]=rope_load[j];$readmemh({rope_dir,"/sin_full.mem"},rope_load);for(int j=0;j<8192;j++)rope_mem[1][j]=rope_load[j];$readmemh({rope_dir,"/cos_slide.mem"},rope_load);for(int j=0;j<8192;j++)rope_mem[2][j]=rope_load[j];$readmemh({rope_dir,"/sin_slide.mem"},rope_load);for(int j=0;j<8192;j++)rope_mem[3][j]=rope_load[j];
  cmd_model_id=dut.MODEL_ID;cmd_graph_id=dut.GRAPH_ID;cmd_numeric_id=dut.NUMERIC_ID;cmd_layout_id=dut.LAYOUT_ID;cmd_table_key=dut.TABLE_KEY;cmd_build_id=dut.BUILD_ID;cmd_kind=5;cmd_layer=0;cmd_request=41;cmd_generation=7;cmd_epoch=16;cmd_mask=128'h00000000000000ffffffffffffffffff;
  setup_model_sha256=dut.MODEL_SHA256;setup_graph_sha256=dut.GRAPH_SHA256;setup_numeric_sha256=dut.NUMERIC_SHA256;setup_layout_sha256=dut.LAYOUT_SHA256;setup_package_build_sha256=dut.PACKAGE_BUILD_SHA256;setup_build_id=dut.BUILD_ID;setup_table_key=dut.TABLE_KEY;
  setup_request=22;setup_generation=3;setup_catalog_base=65536;setup_catalog_span=8192;setup_records_sha256=256'h36455736a0e39bf63b37a63ceb46c95b2c60678cc50d23671cc1b676c36cd87c;setup_records_crc=64'hcb4a2935cd23ffc8;
  model_word_request=setup_request;model_word_generation=setup_generation;
  coeff_bind_model_id=cmd_model_id;coeff_bind_numeric_id=cmd_numeric_id;coeff_bind_table_key=cmd_table_key;coeff_wr_model_id=cmd_model_id;coeff_wr_numeric_id=cmd_numeric_id;coeff_wr_table_key=cmd_table_key;
  invalidate_request=19;invalidate_generation=2;invalidate_build_id=dut.BUILD_ID;

  if(cmd_mask!==128'h00000000000000ffffffffffffffffff)$fatal(1,"original B1 mask required");
  for(int row=0;row<128;row++)if(cmd_mask[row]!==maskmem[row][0])$fatal(1,"B1 mask differs from independent original fixture");
  repeat(4)step();@(negedge clk);rst_n=1;wait(cmd_ready);
  load_rope();send_setup();wait(parent_state==65);for(int j=0;j<576;j++)offer_word(0,j);
  wait(parent_state==68);for(int j=0;j<32;j++)offer_word(1,j);
  wait(parent_state==70);for(int j=0;j<96;j++)offer_word(2,j);
  consume_done(0,0,0,0);if(!model_committed||model_count!=704||ar_count!=124||r_count!=124)$fatal(1,"complete real v3 setup");
  full_active=1;out_ready=1;send_begin();wait(parent_state==32);
  for(int index=0;index<4096;index++)begin
   @(negedge clk);in_valid=1;in_data=initial_h[index];in_request=cmd_request;in_generation=cmd_generation;in_epoch=cmd_epoch;in_row=index/32;in_group=index%32;
   do @(posedge clk);while(!in_ready);
  end
  @(negedge clk);in_valid=0;
  wait(done_valid);@(negedge clk);repeat(5)begin step();if(!done_valid||{done_status,source_status,error_domain,error_tuple,done_request,done_generation,done_epoch}!==expected_done)$fatal(1,"original independent held243bit success");end
  if(mid_held<8||last_held<17||!mid_started||!last_started)$fatal(1,"real public output hold coverage");
  if(kind_run==5&&(h_commits!=4096||wo_q_commits!=4096||down_q_commits!=4096||ln_q_commits!=4096||vector_done_count!=2||ln_done_count!=1||catalog_runtime!=4||vector_h_commits[0]!=4096||vector_h_commits[1]!=4096||!(last_h_commit<last_export&&last_export<first_done)))$fatal(1,"complete real Encoder0 resident/epoch/retirement boundaries");
  for(int ph=kind_run==5?0:2;ph<4;ph++)if(m_done_count[ph]!=1||m_outputs[ph]!=blocks_at(ph)*256||publications[ph]!=1)$fatal(1,"complete original shape/phase coverage");
  @(negedge clk);done_ready=1;step();@(negedge clk);done_ready=0;repeat(3)step();if(!cmd_ready||done_valid||parent_retired!=1)$fatal(1,"actual parent exactly once retired");
  observed_output.finish_capture(1);
  $display("M007_FULLMODEL_ENCODER0_COMPLETE_PASS kind=%0d matrices=%0d QKV_values=%0d WO_values=%0d Wi_values=%0d G_values=%0d G_nodes=%0d Down_values=%0d final_values=%0d heads=%0d residuals=%0d LN=%0d packed=%0d cycles=%0d last_H=%0d last_export=%0d first_done=%0d",kind_run,mcommands,m_outputs[0]*32,m_outputs[1]*32,m_outputs[2]*32,g_outputs*8,node_checks,m_outputs[3]*32,export_count*32,nheads,vector_done_count,ln_q_commits,packed_check,cycle-command_cycle,last_h_commit,last_export,first_done);$display("HARDWARE_AGENT_SIM_PASS M007_FULLMODEL_ENCODER0_COMPLETE");$fflush();$finish;
 end
endmodule
