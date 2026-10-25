from pathlib import Path
m=Path('/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/vivado/module_design/attention_and_fp_engine')
newdecl=''' logic prepare_cancel_valid=0,prepare_cancel_ready,prepare_cancel_rsp_valid,prepare_cancel_rsp_ready=0,layer_idle,check_coverage_fault;
 logic[63:0]prepare_cancel_request_id=0,prepare_cancel_rsp_request_id;logic[31:0]prepare_cancel_generation=0,prepare_cancel_epoch=0,prepare_cancel_rsp_generation,prepare_cancel_rsp_epoch,check_first_conflict;logic[7:0]prepare_cancel_rsp_status;
'''
p=m/'tb/m011_r004_layer_tb.sv';s=p.read_text().replace(' laya_attention_layer_v1 dut(.*);',newdecl+' laya_attention_layer_v1 dut(.*);');p.write_text(s)
# Independent legacy classifier is a preserved pre-R004 source peer.
base=(m.parents[4]/'E010_m007_attention_bank_qk_av/experiment_results/runs/R004/baseline/laya_attention_check_order_v1.sv').read_text().replace('module laya_attention_check_order_v1(','module m011_r004_legacy_check(')
s=(m/'tb/m011_layer_order_tb.sv').read_text().replace('module m011_layer_order_tb;','module m011_r004_check_tb;').replace(' laya_attention_check_order_v1 dut(.*);',''' logic[31:0]first_conflict;
 logic old_error_valid,old_all_accounted,old_final_ready,old_coverage_fault;logic[95:0]old_error_tuple;
 logic[25:0][15:0]old_completed,old_unreachable,old_dominated;logic[2047:0]old_av_completed,old_av_unreachable,old_av_dominated;
 laya_attention_check_order_v1 dut(.*);
 m011_r004_legacy_check original(.clk,.rst_n,.clear,.candidate_valid,.candidate_tuple,.complete_set,.unreachable_set,.dominated_set,.av_complete_set,.av_unreachable_set,.av_dominated_set,.real_debts_clear,.error_valid(old_error_valid),.error_tuple(old_error_tuple),.completed(old_completed),.unreachable(old_unreachable),.dominated(old_dominated),.av_completed(old_av_completed),.av_unreachable(old_av_unreachable),.av_dominated(old_av_dominated),.all_accounted(old_all_accounted),.final_ready(old_final_ready),.coverage_fault(old_coverage_fault));
 task automatic equivalent;
  if({error_valid,error_tuple,completed,unreachable,dominated,av_completed,av_unreachable,av_dominated,all_accounted,final_ready,coverage_fault}!=={old_error_valid,old_error_tuple,old_completed,old_unreachable,old_dominated,old_av_completed,old_av_unreachable,old_av_dominated,old_all_accounted,old_final_ready,old_coverage_fault})$fatal(1,"legal classification differs from original peer");
 endtask
 task automatic clean;
  @(negedge clk);clear=1;candidate_valid=0;complete_set=0;unreachable_set=0;dominated_set=0;av_complete_set=0;av_unreachable_set=0;av_dominated_set=0;step();@(negedge clk);clear=0;step();equivalent();
 endtask
 task automatic put_class(input int kind,index,cls);
  if(kind==0)case(cls)1:complete_set[index/16][index%16]=1;2:unreachable_set[index/16][index%16]=1;3:dominated_set[index/16][index%16]=1;endcase
  else case(cls)1:av_complete_set[index]=1;2:av_unreachable_set[index]=1;3:av_dominated_set[index]=1;endcase
 endtask
''')
old='  $display("HARDWARE_AGENT_SIM_PASS M011_LAYER_ORDER six_reverse_candidates=1 actual_vs_unreachable=1 true_debt_gate=1 peer_scope_only=1");$finish;'
new='''  equivalent();
  clean();
  @(negedge clk);for(int i=0;i<416;i++)put_class(0,i,1+i%3);for(int i=0;i<2048;i++)put_class(1,i,1+i%3);step();equivalent();step();equivalent();
  if(!final_ready||coverage_fault)$fatal(1,"legal repeated classification failed");
  for(int kind=0;kind<2;kind++)for(int oldclass=1;oldclass<=3;oldclass++)for(int newclass=1;newclass<=3;newclass++)if(oldclass!=newclass)begin
   logic[31:0]first;int index;index=kind?2047:415;clean();@(negedge clk);put_class(kind,index,oldclass);step();equivalent();@(negedge clk);complete_set=0;unreachable_set=0;dominated_set=0;av_complete_set=0;av_unreachable_set=0;av_dominated_set=0;put_class(kind,index,newclass);step();
   first={14'b0,1'(kind),12'(index),2'(oldclass),3'(1<<(newclass-1))};
   if(!coverage_fault||final_ready||all_accounted||first_conflict!==first)$fatal(1,"class conflict record kind%0d old%0d new%0d got%h expected%h",kind,oldclass,newclass,first_conflict,first);
   @(negedge clk);put_class(0,0,1);put_class(0,0,2);real_debts_clear=0;step();if(first_conflict!==first||final_ready)$fatal(1,"first fault not sticky");
  end
  for(int mask=3;mask<8;mask++)if(mask!=4)begin
   logic[31:0]first;clean();@(negedge clk);complete_set[0][0]=mask[0];unreachable_set[0][0]=mask[1];dominated_set[0][0]=mask[2];step();first={14'b0,1'b0,12'b0,2'b0,3'(mask)};if(!coverage_fault||first_conflict!==first||final_ready)$fatal(1,"same-edge class conflict mask%0d",mask);
  end
  clean();real_debts_clear=1;step();equivalent();
  $display("HARDWARE_AGENT_SIM_PASS M011_R004_CHECK original_reverse6 all2464legal_exact repeated3classes12conflicts sameedge4 first_fault_hold debt_gate clear_recovery peer_scope_only");$finish;'''
assert old in s;s=s.replace(old,new);(m/'tb/m011_r004_check_tb.sv').write_text(s+'\n'+base)
# Short public PREP cancellation test, no internal state injection.
base=(m/'tb/m011_layer_integration_tb.sv').read_text();decl=base.split(' initial clk=0;',1)[0].replace('module m011_layer_integration_tb;','module m011_r004_cancel_tb;')
(m/'tb/m011_r004_cancel_tb.sv').write_text(decl+newdecl+'''
 initial clk=0;always #1.6665 clk=~clk;
 laya_attention_layer_v1 dut(.*);
 int writes=0,cancels=0;
 task automatic step;@(posedge clk);#0.1;endtask
 task automatic prep(input int gen);
  @(negedge clk);prepare_generation=gen;prepare_epoch=32'(90+gen);prepare_valid=1;while(!prepare_ready)step();step();@(negedge clk);prepare_valid=0;
  if(layer_idle||prepare_ready)$fatal(1,"PREP not owned");
 endtask
 task automatic word_write(input int n);
  @(negedge clk);qkv_wr_valid=1;qkv_wr_request_id=prepare_request_id;qkv_wr_generation=prepare_generation;qkv_wr_epoch=prepare_epoch;qkv_wr_plane=2'(n/256%3);qkv_wr_head=4'(n/768);qkv_wr_token=7'(n/2%128);qkv_wr_half=1'(n%2);qkv_wr_data={32{32'h3f800000}};while(!qkv_wr_ready)step();step();@(negedge clk);qkv_wr_valid=0;
 endtask
 task automatic cancel;
  @(negedge clk);prepare_cancel_valid=1;prepare_cancel_request_id=prepare_request_id;prepare_cancel_generation=prepare_generation;prepare_cancel_epoch=prepare_epoch;
  #0.1;if(!prepare_cancel_ready)$fatal(1,"matching cancel not ready");step();@(negedge clk);prepare_cancel_valid=0;
  repeat(7)begin
   if(!prepare_cancel_rsp_valid||prepare_cancel_rsp_request_id!==prepare_request_id||prepare_cancel_rsp_generation!==prepare_generation||prepare_cancel_rsp_epoch!==prepare_epoch||prepare_cancel_rsp_status!=4||prepare_ready||start_ready||qkv_wr_ready||layer_idle||done_valid)$fatal(1,"held cancel response/protocol");step();
  end
  @(negedge clk);prepare_cancel_rsp_ready=1;step();@(negedge clk);prepare_cancel_rsp_ready=0;step();if(!layer_idle||prepare_cancel_rsp_valid)$fatal(1,"cancel did not retire to actual idle");
 endtask
 initial begin
  rst_n=0;prepare_valid=0;prepare_request_id=64'h1234567812345678;prepare_model_id=128'h6eb6ef58bc4f99bd9db40381604108af;prepare_numeric_id=128'haeb13e7937d29fe6a2c68c407249f294;prepare_table_key=128'hb1fdc9ca482c0210982c7245cc50c965;prepare_generation=1;prepare_epoch=91;prepare_kind=2;prepare_layer=0;prepare_mask='1;
  qkv_wr_valid=0;qkv_wr_request_id=0;qkv_wr_generation=0;qkv_wr_epoch=0;qkv_wr_plane=0;qkv_wr_head=0;qkv_wr_token=0;qkv_wr_half=0;qkv_wr_data=0;start_valid=0;start_request_id=prepare_request_id;start_generation=1;abort_valid=0;qkv_read_grant=7;ps_grant=1;g_grant=1;context_grant=1;fp_grant=1;sfu_grant=1;exp_grant=1;div_grant=1;rope_write_grant=1;done_ready=0;result_rd_valid=0;result_rd_generation=0;result_rd_tag=0;result_rd_head=0;result_rd_query=0;result_rd_half=0;result_rsp_ready=0;result_discard_valid=0;result_discard_generation=0;
  coeff_bind_valid=0;coeff_bind_model_id=0;coeff_bind_numeric_id=0;coeff_bind_table_key=0;coeff_wr_valid=0;coeff_wr_model_id=0;coeff_wr_numeric_id=0;coeff_wr_table_key=0;coeff_wr_table=0;coeff_wr_row=0;coeff_wr_half=0;coeff_wr_data=0;
  repeat(4)step();@(negedge clk);rst_n=1;step();prep(1);cancel();
  prep(2);for(int i=0;i<19;i++)word_write(i);
  for(int field=0;field<3;field++)begin
   @(negedge clk);prepare_cancel_valid=1;prepare_cancel_request_id=prepare_request_id+(field==0);prepare_cancel_generation=prepare_generation+(field==1);prepare_cancel_epoch=prepare_epoch+(field==2);step();if(prepare_cancel_ready||prepare_cancel_rsp_valid||layer_idle||$countones(dut.engine.qkv_coverage)!=19)$fatal(1,"wrong cancel damaged real coverage");
  end
  @(negedge clk);prepare_cancel_valid=0;cancel();
  // Prior real writes committed; same-edge new narrow write and start lose to matching cancellation.
  prep(3);word_write(0);@(negedge clk);prepare_cancel_valid=1;prepare_cancel_request_id=prepare_request_id;prepare_cancel_generation=prepare_generation;prepare_cancel_epoch=prepare_epoch;start_generation=prepare_generation;start_valid=1;qkv_wr_valid=1;qkv_wr_generation=prepare_generation;qkv_wr_epoch=prepare_epoch;
  #0.1;if(!prepare_cancel_ready||qkv_wr_ready||start_ready||dut.engine.res_qkv_wr_valid)$fatal(1,"cancel priority");step();@(negedge clk);start_valid=0;qkv_wr_valid=0;prepare_cancel_valid=0;if(!prepare_cancel_rsp_valid||dut.engine.qkv_coverage!=0)$fatal(1,"cancel coverage not invalidated");prepare_cancel_rsp_ready=1;step();@(negedge clk);prepare_cancel_rsp_ready=0;step();
  prep(4);if(dut.engine.qkv_coverage!=0||dut.engine.qkv_complete||start_ready)$fatal(1,"newgen reused prior input");cancel();
  if(writes!=20||cancels!=4)$fatal(1,"actual counts writes%0d cancels%0d",writes,cancels);
  $display("HARDWARE_AGENT_SIM_PASS M011_R004_CANCEL zero_partial20wrong3 sameedge_write_start_cancel held7 noreset4gens actual_idle no_internal_injection");$finish;
 end
 always@(posedge clk)if(rst_n)begin
  if(qkv_wr_valid&&qkv_wr_ready)writes++;
  if(prepare_cancel_valid&&prepare_cancel_ready)cancels++;
  if(dut.resources.res_fp_lease_active||dut.resources.res_div_lease_active||dut.resources.res_sfu_lease_active)$fatal(1,"PREP cancel leased arithmetic");
 end
 initial begin repeat(10000)@(posedge clk);$fatal(1,"cycle cap");end
endmodule
''')
