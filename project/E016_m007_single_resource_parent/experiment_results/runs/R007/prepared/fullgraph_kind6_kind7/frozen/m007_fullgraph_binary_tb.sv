`timescale 1ns/1ps
module m007_fullgraph_binary_tb;
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
 // Original layer endpoints, never connected to an activation producer.
 logic[1023:0]initial_h[0:4095],checkpoint_gold[0:131071],tail_gold[0:543];
 logic[735:0]metadata[0:119];logic[31:0]tensor_ids[0:119],rope_load[0:8191];
 logic[511:0]catalog_mem[0:127];logic[31:0]bias_mem[0:18431],gamma_mem[0:1023],type_mem[0:3071],rope_mem[0:3][0:8191];
 integer cycle=0,checked=0,last_checked=0,mode=9,ar_count=0,r_count=0,model_count=0,h_count=0,catalog_runtime=0;
 integer bus_word=0,held_word=0;logic pending=0,drain_pending=0,fault_injected=0,response_consumed=0;logic[63:0]held_addr;logic held_ar=0;
 integer kind_run=7,decision_local=0,commands=0,exports=0,layers_completed=0,final_norm_count=0,type_count=0,matrix_commands=0,attention_layers=0,ln_commands=0,vector_commands=0,g_commands=0;
 integer layer_H_count[0:29],layer_mcount[0:29],layer_mdone[0:29],layer_attention[0:29],fc1_Awrites[0:1],fc1_Aacks[0:1];
 logic[4095:0]layer_H_seen[0:29];logic[4095:0]final_norm_seen=0,type_H_seen=0;logic[16383:0]fc1_Aseen[0:1];logic[29:0]layer_start_seen=0,layer_complete_seen=0;logic[119:0]catalog_seen=0;
 logic[31:0]active_quant_K;logic active_quant_slot;logic full_active=0;
 string data_dir,rope_dir,original_dir,export_path,meta_path;
 integer input_fd,output_fd,receipt_fd;integer tail_writes=0,tail_delay=0,tail_commits=0;logic tail_active=0;
 logic holding=0;logic[1051:0]held_output;integer held_left=0;logic mid_hold_started=0,last_hold_started=0;
 task automatic progress(input integer n,input string phase);
  begin checked+=n;if(checked-last_checked>=4096)begin $display("M007_PARENT_CHECKED checked=%0d phase=%s cycle=%0d",checked,phase,cycle);$fflush();last_checked=checked;end end
 endtask
 function automatic integer checkpoint_index(input integer global_layer);return global_layer<28?global_layer:global_layer+2;endfunction
 function automatic integer output_limit;return kind_run==7?544:4096;endfunction
 assign tail_begin_ready=!tail_active&&!tail_commit_valid;
 assign tail_abort_ready=1;assign tail_owner_idle=!tail_active&&!tail_commit_valid;
 always@(negedge clk)if(rst_n&&full_active)begin
  out_ready=1;
  if(out_valid&&exports==256&&!mid_hold_started)begin mid_hold_started=1;held_left=8;end
  if(out_valid&&exports==output_limit()-1&&!last_hold_started)begin last_hold_started=1;held_left=17;end
  if(held_left>0)begin out_ready=0;held_left--;end
 end
 always@(posedge clk)begin
  if(!rst_n)begin tail_commit_valid<=0;tail_active<=0;tail_writes<=0;tail_delay<=0;end
  else begin
   if(tail_begin_valid&&tail_begin_ready)begin
    if(kind_run!=7||tail_expected_bytes!=69632||commands!=1)$fatal(1,"real tail owner arm/one BEGIN");tail_active<=1;tail_writes<=0;
   end
   if(full_active&&out_valid&&out_ready&&kind_run==7)begin
    if(!tail_active||tail_writes>=544)$fatal(1,"tail write without actual owner");
    for(int byte_index=0;byte_index<128;byte_index++)$fwrite(output_fd,"%c",out_data[byte_index/4][8*(byte_index%4)+:8]);
    tail_writes<=tail_writes+1;if(tail_writes==543)begin $fflush(output_fd);tail_delay<=7;end
   end
   if(tail_delay>0)tail_delay<=tail_delay-1;
   if(tail_active&&tail_writes==544&&tail_delay==1)begin
    tail_commit_valid<=1;tail_commit_request<=tail_request;tail_commit_generation<=tail_generation;tail_commit_source_epoch<=tail_source_epoch;tail_commit_bytes<=69632;tail_commit_status<=0;
   end
   if(tail_commit_valid&&tail_commit_ready)begin tail_commit_valid<=0;tail_active<=0;tail_commits++;end
   if(tail_abort_valid)$fatal(1,"unexpected normal-graph tail abort");
  end
 end
 always@(posedge clk)if(rst_n)begin
  cycle++;
  if(dut.catalog_owns&&arvalid!=0&&arvalid!=1)$fatal(1,"catalog only physical port0");
  if(dut.catalog_owns&&arvalid[0]&&!arready[0])begin if(held_ar&&araddr[0]!==held_addr)$fatal(1,"catalog held address changed");held_addr=araddr[0];held_ar=1;end
  if(dut.catalog_owns&&arvalid[0]&&arready[0])begin
   if(arid[0]!=7||arlen[0]!=0||araddr[0]<65536||araddr[0]>=65536+7936||!dut.m_transport_idle||!weight_idle)$fatal(1,"catalog source/real W retirement");
   pending=1;bus_word=(araddr[0]-65536)/64;ar_count++;held_ar=0;held_word=bus_word;
  end
  if(dut.catalog_owns&&rvalid[0]&&rready[0])begin if(!rlast[0])$fatal(1,"normal catalog actual last R");r_count++;response_consumed=1;end
  if(model_word_valid&&model_word_ready)begin model_count++;progress(32,"MODEL");end
  if(full_active)begin
   integer gl;gl=int'(dut.layer_index);
   if(reject_valid||done_status!=0||dut.r_res_fp_protocol_fault||dut.r_res_div_protocol_fault||dut.l_check_coverage_fault)$fatal(1,"normal graph error/check/reject protocol");
   if(cmd_valid&&cmd_ready)begin commands++;if(commands!=1)$fatal(1,"one public BEGIN only");end
   if(in_valid&&in_ready)begin
    if(h_count>=4096||!dut.v2_h_wr_commit||in_data!==initial_h[h_count])$fatal(1,"only original public H input and real commit");
    for(int j=0;j<128;j++)$fwrite(input_fd,"%c",in_data[j/4][8*(j%4)+:8]);h_count++;progress(32,"PUBLIC_H");
   end
   if(dut.runtime_catalog&&dut.cat_rsp_valid&&dut.cat_rsp_ready)begin
    integer ri;ri=int'(dut.cat_word)-4;
    if(ri<0||ri>=120||catalog_seen[ri]||ri/4!=gl||dut.cat_fault||!dut.m_transport_idle||!weight_idle||!dut.q_cmd_ready||dut.q_done_valid)$fatal(1,"actual layer catalog identity/refill before true old retirement");
    if(kind_run==7&&ri!=catalog_runtime)$fatal(1,"once-BEGIN catalog order");catalog_seen[ri]=1;catalog_runtime++;
   end
   if(dut.m_cmd_valid&&dut.m_cmd_ready)begin
    integer ri;ri=4*gl+layer_mcount[gl];
    if(gl>=30||layer_mcount[gl]>=4||dut.m_cmd_tensor!=tensor_ids[ri]||dut.m_cmd_k!=metadata[ri][15:0]||dut.m_cmd_n!=metadata[ri][31:16]||dut.m_cmd_request!=cmd_request||dut.m_cmd_generation!=cmd_generation)$fatal(1,"actual global-layer matrix descriptor/shape/identity");
    for(int p=0;p<4;p++)if(dut.m_cmd_base[p]!==metadata[ri][224+128*p+:64]||dut.m_cmd_span[p]!==metadata[ri][288+128*p+:64])$fatal(1,"actual matrix full catalog base/span");
    if(gl>=28&&layer_mcount[gl]==3&&(fc1_Awrites[gl-28]!=16384||fc1_Aacks[gl-28]!=16384||fc1_Aseen[gl-28]!={16384{1'b1}}||!dut.front.producer_closed||!dut.front.producer_success||!dut.front.a_published||dut.front.a_write_debt!=0))$fatal(1,"FC2 before full actual FC1/ReLU/K4096 A1 retirement");
    layer_mcount[gl]++;matrix_commands++;
   end
   if(dut.m_done_valid&&dut.m_done_ready)begin if(dut.m_status!=0)$fatal(1,"matrix mathematical failure");layer_mdone[gl]++;end
   if(dut.q_cmd_valid&&dut.q_cmd_ready)begin active_quant_slot=dut.q_cmd_slot;active_quant_K=dut.q_cmd_k;end
   if(gl>=28&&active_quant_slot&&active_quant_K==4096)begin
    if(dut.q_awr_valid&&dut.q_awr_ready)begin integer ai;ai=128*int'(dut.q_awr_row)+int'(dut.q_awr_group);if(fc1_Aseen[gl-28][ai]||dut.q_awr_request!=cmd_request||dut.q_awr_generation!=cmd_generation)$fatal(1,"unique actual FC1 A1 group/identity");fc1_Aseen[gl-28][ai]=1;fc1_Awrites[gl-28]++;end
    if(dut.q_awr_rsp_valid&&dut.q_awr_rsp_ready)fc1_Aacks[gl-28]++;
   end
   if(dut.l_prepare_valid&&dut.l_prepare_ready)begin
    if(layer_start_seen[gl]||dut.l_prepare_kind!=(gl>=28?2:(gl%3==0?0:1))||dut.l_prepare_layer!=(gl>=28?gl-28:gl)||h_count!=4096)$fatal(1,"actual full/sliding/Decision layer identity/no repeat");
    if(kind_run==7&&gl>0&&!layer_complete_seen[gl-1])$fatal(1,"layer handoff before actual previous endpoint");if(kind_run==7&&gl==28&&(final_norm_count!=4096||type_count!=4096||type_H_seen!={4096{1'b1}}))$fatal(1,"Decision0 before actual final norm/type checkpoint");layer_start_seen[gl]=1;attention_layers++;
   end
   if(dut.l_done_valid&&dut.l_done_ready)begin
    if(dut.l_done_status!=0||layer_head_completed!=16'hffff||dut.l_head_context_valid!=16'hffff)$fatal(1,"all16 real head completions");layer_attention[gl]++;
   end
   if(dut.v2_resident_ln_start_valid&&dut.v2_resident_ln_start_ready)ln_commands++;
   if(dut.v2_vector_start_valid&&dut.v2_vector_start_ready)vector_commands++;
   if(dut.g_cmd_valid&&dut.g_cmd_ready)begin if(gl>=28)$fatal(1,"Decision must use ReLU not GEGLU");g_commands++;end
   if(dut.resident.p_q_wr_commit&&parent_state==90)begin
    integer a;a=int'(dut.resident.p_q_wr_addr);if(kind_run!=7||final_norm_seen[a]||dut.active_epoch_offset!=448||dut.resident.p_q_wr_data!==checkpoint_gold[28*4096+a])$fatal(1,"original final gamma LN checkpoint");final_norm_seen[a]=1;final_norm_count++;progress(32,"FINAL_NORM");
   end
   if(dut.resident.vector_h_wr_valid&&dut.resident.vector_h_wr_ready)begin
    integer a;a=int'(dut.resident.vector_h_wr_addr);if(!dut.resident.vector_h_wr_commit)$fatal(1,"vector H accepted without commit");
    if(parent_state==54)begin
     if(layer_H_seen[gl][a]||dut.resident.vector_h_wr_data!==checkpoint_gold[4096*checkpoint_index(gl)+a])$fatal(1,"original per-layer actual residual H bits global=%0d address=%0d",gl,a);
     layer_H_seen[gl][a]=1;layer_H_count[gl]++;progress(32,"LAYER_H");
    end else if(parent_state==95)begin
     if(kind_run!=7||type_H_seen[a]||final_norm_count!=4096||final_norm_seen!={4096{1'b1}}||dut.resident.vector_h_wr_data!==checkpoint_gold[29*4096+a])$fatal(1,"original type-add H checkpoint");type_H_seen[a]=1;type_count++;progress(32,"TYPE_H");
    end
   end
   if(parent_state==97&&dut.resident_retired&&dut.v2_scratch_retired&&dut.ws_a_enable)begin
    if(layer_complete_seen[gl]||layer_H_count[gl]!=4096||layer_H_seen[gl]!={4096{1'b1}}||layer_mcount[gl]!=4||layer_mdone[gl]!=4||layer_attention[gl]!=1)$fatal(1,"actual complete layer handoff/coverage/retirement");
    layer_complete_seen[gl]=1;layers_completed++;$display("M007_FULLGRAPH_LAYER_END global=%0d checkpoint=%0d cycle=%0d",gl,checkpoint_index(gl),cycle);$fflush();
   end
   if(holding&&(!out_valid||{out_data,out_row,out_col,out_slot}!==held_output))$fatal(1,"public output unstable while held");holding=out_valid&&!out_ready;held_output={out_data,out_row,out_col,out_slot};
   if(out_valid&&out_ready)begin
    if(exports>=output_limit()||out_col!=32*(exports%32)||out_slot!=(kind_run==7?exports/32:0))$fatal(1,"public output count/order/slot");
    if(kind_run==7)begin if(out_data!==tail_gold[exports]||layers_completed!=30||final_norm_count!=4096||type_count!=4096)$fatal(1,"original Decision1 gather/CLS and fullgraph prerequisites");end
    else begin if(out_row!=exports/32||out_data!==checkpoint_gold[checkpoint_index(28+decision_local)*4096+exports]||layers_completed!=1)$fatal(1,"original full Decision public output");for(int j=0;j<128;j++)$fwrite(output_fd,"%c",out_data[j/4][8*(j%4)+:8]);end
    exports++;progress(32,"PUBLIC_OUTPUT");
   end
   if(done_valid)begin
    if(done_op!=2||done_request!=cmd_request||done_generation!=cmd_generation||done_epoch!=cmd_epoch||done_status!=0||source_status!=0||error_domain!=0||error_tuple!=0||exports!=output_limit()||!weight_idle||!dut.m_transport_idle||!dut.global_idle)$fatal(1,"full parent identity/success/real idle receipt");
    if(kind_run==7&&(commands!=1||catalog_runtime!=120||catalog_seen!={120{1'b1}}||matrix_commands!=120||layers_completed!=30||attention_layers!=30||ln_commands!=60||vector_commands!=61||g_commands!=28||tail_commits!=1||tail_writes!=544))$fatal(1,"once-BEGIN original30 graph coverage and real tail commit");
    if(kind_run==6&&(catalog_runtime!=4||matrix_commands!=4||layers_completed!=1||attention_layers!=1||ln_commands!=2||vector_commands!=2||g_commands!=0||tail_commits!=0))$fatal(1,"complete Decision component coverage");
   end
  end
  if(cycle>40000000)$fatal(1,"40Mcycle fullgraph watchdog");
 end
 task automatic step;begin @(posedge clk);#0.1;end endtask
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
 // §17 original binary source. Catalog and W have distinct simulation drivers.
 logic[3:0]catalog_arready=0,catalog_rvalid=0,weight_arready,weight_rvalid,weight_rlast;
 logic[3:0][2:0]catalog_rid=0,weight_rid,weight_arsize;
 logic[3:0][511:0]catalog_rdata=0,weight_rdata;
 logic[3:0][1:0]catalog_rresp=0,weight_rresp,weight_arburst;
 logic[3:0]catalog_rlast=0;logic weight_enable,weight_idle;
 integer weight_AR_count,weight_R_count,weight_peak_live,weight_cache_hits,weight_cache_misses;
 assign weight_enable=full_active&&!dut.catalog_owns;
 assign weight_arsize={4{3'd6}};assign weight_arburst={4{2'd1}};
 m007_binary_weight_peer binary_weight_peer(
  .clk,.rst_n,.enable(weight_enable),.arvalid(arvalid&{4{weight_enable}}),.arready(weight_arready),
  .araddr,.arid,.arlen,.arsize(weight_arsize),.arburst(weight_arburst),
  .rvalid(weight_rvalid),.rready(rready&{4{weight_enable}}),.rid(weight_rid),.rdata(weight_rdata),.rresp(weight_rresp),.rlast(weight_rlast),
  .idle(weight_idle),.accepted_ar(weight_AR_count),.returned_beats(weight_R_count),.peak_live(weight_peak_live),.cache_hits(weight_cache_hits),.cache_misses(weight_cache_misses));
 always_comb begin
  arready=dut.catalog_owns?catalog_arready:weight_arready;
  rvalid=dut.catalog_owns?catalog_rvalid:weight_rvalid;
  rid=dut.catalog_owns?catalog_rid:weight_rid;
  rdata=dut.catalog_owns?catalog_rdata:weight_rdata;
  rresp=dut.catalog_owns?catalog_rresp:weight_rresp;
  rlast=dut.catalog_owns?catalog_rlast:weight_rlast;
 end
 always@(negedge clk)if(rst_n&&!dut.catalog_owns)begin
  catalog_arready=0;if(response_consumed)begin catalog_rvalid=0;response_consumed=0;end
 end
 always@(posedge clk)if(rst_n&&dut.catalog_owns&&!weight_idle)$fatal(1,"catalog owns before immutable binary peer real R drain");
 // One actual catalog request with held response; no combinational fake ready.
 always@(negedge clk)if(rst_n&&dut.catalog_owns)begin
  if(response_consumed)begin catalog_rvalid[0]=0;response_consumed=0;end
  if(drain_pending&&catalog_rvalid[0])begin catalog_rlast[0]=1;catalog_rdata[0]=0;drain_pending=0;end
  catalog_arready=0;if(!pending&&!catalog_rvalid[0]&&cycle%3!=0)catalog_arready[0]=1;
  if(pending&&!catalog_rvalid[0])begin
   catalog_rvalid[0]=1;catalog_rid[0]=7;catalog_rresp[0]=0;catalog_rdata[0]=catalog_mem[bus_word];catalog_rlast[0]=1;
   if(mode==2&&!fault_injected)begin catalog_rlast[0]=0;fault_injected=1;end
   if(mode==3&&bus_word==123)catalog_rdata[0][88]=~catalog_rdata[0][88];
   pending=0;
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
  catalog_arready='0;
  catalog_rvalid='0;
  catalog_rid='0;
  catalog_rdata='0;
  catalog_rresp='0;
  catalog_rlast='0;

  if(!$value$plusargs("DATA=%s",data_dir)||!$value$plusargs("ROPE=%s",rope_dir)||!$value$plusargs("ORIGINAL_GRAPH=%s",original_dir)||!$value$plusargs("PEER_META=%s",meta_path)||!$value$plusargs("EXPORT=%s",export_path))$fatal(1,"source-bound original graph paths required");
  if(!$value$plusargs("KIND=%d",kind_run))kind_run=7;if(!$value$plusargs("LAYER=%d",decision_local))decision_local=0;
  if(!(kind_run==6||kind_run==7)||decision_local<0||decision_local>1||kind_run==7&&decision_local!=0)$fatal(1,"true kind6/7 only; no prefix stop or repeated Encoder0");
  $readmemh(meta_path,metadata);$readmemh({original_dir,"/tensor_ids.hex"},tensor_ids);$readmemh({original_dir,"/checkpoints.hex"},checkpoint_gold);$readmemh({original_dir,"/tail544.hex"},tail_gold);
  if(kind_run==7)$readmemh({original_dir,"/initial_H.hex"},initial_h);
  else if(decision_local==0)$readmemh({original_dir,"/decision0_input.hex"},initial_h);else $readmemh({original_dir,"/decision1_input.hex"},initial_h);
  $readmemh({data_dir,"/catalog.hex"},catalog_mem);$readmemh({data_dir,"/bias.words.hex"},bias_mem);$readmemh({data_dir,"/gamma.words.hex"},gamma_mem);$readmemh({data_dir,"/type.words.hex"},type_mem);
  $readmemh({rope_dir,"/cos_full.mem"},rope_load);for(int j=0;j<8192;j++)rope_mem[0][j]=rope_load[j];
  $readmemh({rope_dir,"/sin_full.mem"},rope_load);for(int j=0;j<8192;j++)rope_mem[1][j]=rope_load[j];
  $readmemh({rope_dir,"/cos_slide.mem"},rope_load);for(int j=0;j<8192;j++)rope_mem[2][j]=rope_load[j];
  $readmemh({rope_dir,"/sin_slide.mem"},rope_load);for(int j=0;j<8192;j++)rope_mem[3][j]=rope_load[j];
  cmd_model_id=dut.MODEL_ID;cmd_graph_id=dut.GRAPH_ID;cmd_numeric_id=dut.NUMERIC_ID;cmd_layout_id=dut.LAYOUT_ID;cmd_table_key=dut.TABLE_KEY;cmd_build_id=dut.BUILD_ID;cmd_kind=5;cmd_layer=0;cmd_request=41;cmd_generation=7;cmd_epoch=16;cmd_mask=128'h00000000000000ffffffffffffffffff;
  setup_model_sha256=dut.MODEL_SHA256;setup_graph_sha256=dut.GRAPH_SHA256;setup_numeric_sha256=dut.NUMERIC_SHA256;setup_layout_sha256=dut.LAYOUT_SHA256;setup_package_build_sha256=dut.PACKAGE_BUILD_SHA256;setup_build_id=dut.BUILD_ID;setup_table_key=dut.TABLE_KEY;
  setup_request=22;setup_generation=3;setup_catalog_base=65536;setup_catalog_span=8192;setup_records_sha256=256'h36455736a0e39bf63b37a63ceb46c95b2c60678cc50d23671cc1b676c36cd87c;setup_records_crc=64'hcb4a2935cd23ffc8;
  model_word_request=setup_request;model_word_generation=setup_generation;
  coeff_bind_model_id=cmd_model_id;coeff_bind_numeric_id=cmd_numeric_id;coeff_bind_table_key=cmd_table_key;coeff_wr_model_id=cmd_model_id;coeff_wr_numeric_id=cmd_numeric_id;coeff_wr_table_key=cmd_table_key;
  invalidate_request=19;invalidate_generation=2;invalidate_build_id=dut.BUILD_ID;

  if(cmd_mask!==128'h00000000000000ffffffffffffffffff)$fatal(1,"original B1 mask required");

  cmd_kind=3'(kind_run);cmd_layer=kind_run==7?0:5'(decision_local);cmd_qtype=2;cmd_marker_rows=0;cmd_marker_rows[0]=23;cmd_marker_rows[1]=33;cmd_marker_mask=16'h0003;cmd_candidate_count=2;
  for(int gl=0;gl<30;gl++)begin layer_H_count[gl]=0;layer_mcount[gl]=0;layer_mdone[gl]=0;layer_attention[gl]=0;layer_H_seen[gl]=0;end
  for(int d=0;d<2;d++)begin fc1_Awrites[d]=0;fc1_Aacks[d]=0;fc1_Aseen[d]=0;end
  input_fd=$fopen({export_path,".H0.bin"},"wb");output_fd=$fopen({export_path,".output.bin"},"wb");if(!input_fd||!output_fd)$fatal(1,"actual public capture open");
  repeat(4)step();@(negedge clk);rst_n=1;wait(cmd_ready);load_rope();send_setup();wait(parent_state==65);for(int j=0;j<576;j++)offer_word(0,j);
  wait(parent_state==68);for(int j=0;j<32;j++)offer_word(1,j);wait(parent_state==70);for(int j=0;j<96;j++)offer_word(2,j);
  consume_done(0,0,0,0);if(!model_committed||model_count!=704||ar_count!=124||r_count!=124)$fatal(1,"real complete model setup");
  full_active=1;send_begin();wait(parent_state==32);
  for(int index=0;index<4096;index++)begin
   @(negedge clk);in_valid=1;in_data=initial_h[index];in_request=cmd_request;in_generation=cmd_generation;in_epoch=cmd_epoch;in_row=index/32;in_group=index%32;do @(posedge clk);while(!in_ready);
  end
  @(negedge clk);in_valid=0;$fflush(input_fd);wait(done_valid);repeat(17)step();consume_done(2,0,0,0);
  if(commands!=1||h_count!=4096||exports!=output_limit()||!weight_idle||!dut.global_idle)$fatal(1,"actual final heldDONE/retirement/one input chain");
  $fflush(output_fd);$fclose(input_fd);$fclose(output_fd);receipt_fd=$fopen({export_path,".receipt.txt"},"w");if(!receipt_fd)$fatal(1,"actual success receipt open");
  $fdisplay(receipt_fd,"kind=%0d layer=%0d request=%0d generation=%0d source_epoch=%0d input_bytes=524288 output_bytes=%0d BEGIN=1 layers=%0d matrices=%0d LN=%0d vector=%0d GEGLU=%0d tail_commits=%0d done_consumed=1 cycles=%0d",kind_run,decision_local,cmd_request,cmd_generation,cmd_epoch,128*exports,layers_completed,matrix_commands,ln_commands,vector_commands,g_commands,tail_commits,cycle);$fclose(receipt_fd);
  $display("HARDWARE_AGENT_SIM_PASS M007_FULLGRAPH_BINARY kind=%0d layers=%0d matrix=%0d outputs=%0d actual_tail_commit=%0d",kind_run,layers_completed,matrix_commands,exports,tail_commits);$fflush();$finish;
 end
endmodule
