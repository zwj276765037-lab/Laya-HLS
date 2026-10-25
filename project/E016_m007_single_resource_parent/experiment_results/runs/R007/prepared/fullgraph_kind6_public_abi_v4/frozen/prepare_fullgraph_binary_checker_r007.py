#!/usr/bin/env python3
"""Prepare a separate true kind6/7 checker from original setup and checkpoints."""
from pathlib import Path
import hashlib,json,re,time
ROOT=Path(__file__).resolve().parents[3];R=ROOT/'project/E016_m007_single_resource_parent/experiment_results/runs/R007';M=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design';S=Path(__file__).parent
OUT=M/'forward_controller/tb/m007_fullgraph_binary_tb.sv'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 start=time.monotonic();base=R/'attempts/AT036_complete_Encoder_progress_alias_build/frozen/m007_fullmodel_encoder_tb.sv';assert sha(base)=='37e8c14793d66b990a9b65efa3fb7c5c3fc5991c189ccd4155ecc65aea6ed755';original=base.read_text();parent=R/'attempts/AT026_parent_normal_cost_checker_build/frozen/m007_fullmodel_parent_tb.sv';old=parent.read_text();binary=M/'forward_controller/tb/m007_fullmodel_encoder_binary_tb.sv';peer=binary.read_text()
 prefix=old[:old.index(' logic[511:0]catalog_mem')].replace('module m007_fullmodel_parent_tb;','module m007_fullgraph_binary_tb;',1)
 body=(S/'fullgraph_binary_checker_r007.svpart').read_text()
 helper=original[original.index(' task automatic step;'):original.index(' // One actual catalog request')]
 helper=helper.replace(' task automatic progress(input int n,input string phase);begin checked(n,phase);end endtask\n','',1)
 mux=peer[peer.index(' // §17 original binary source.'):peer.index(' always @(negedge clk)begin',peer.index(' // §17 original binary source.'))]
 catalog=peer[peer.index(' // One actual catalog request'):peer.index(' always@(posedge clk)if(rst_n)begin\n  cycle++;')]
 defaults=original[original.index(' initial begin')+len(' initial begin'):original.index('  if(!$value$plusargs("ORIGINAL=')]
 for name in ['arready','rvalid','rid','rdata','rresp','rlast']:defaults=defaults.replace(f"  {name}='0;",f"  catalog_{name}='0;")
 config=original[original.index('  cmd_model_id=dut.MODEL_ID;'):original.index('  repeat(4)step();@(negedge clk);rst_n=1;')]
 config=config.replace('  for(int row=0;row<128;row++)if(cmd_mask[row]!==maskmem[row][0])$fatal(1,"B1 mask differs from independent original fixture");\n','',1)
 init='''
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
'''+config+'''
  cmd_kind=3'(kind_run);cmd_layer=kind_run==7?0:5'(decision_local);
  if(kind_run==7)begin cmd_qtype=2;cmd_marker_rows=0;cmd_marker_rows[0]=23;cmd_marker_rows[1]=33;cmd_marker_mask=16'h0003;cmd_candidate_count=2;end
  else begin cmd_qtype=0;cmd_marker_rows=0;cmd_marker_mask=0;cmd_candidate_count=0;end
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
'''
 text=prefix+body+helper+mux+catalog+'\n initial begin'+defaults+init
 assert text.count('task automatic progress(')==1 and 'checked('not in text and 'maskmem'not in text
 previous=R/'prepared/fullgraph_kind6_kind7_public_boundary_v2/frozen/m007_fullgraph_binary_tb.sv'
 assert sha(previous)=='677e5bc9f74c6189ca37355fd6de569599a46a3a853961d933f9dda9266e8033'
 observer=re.search(r'   // RTL_RETIRE_OBSERVER_BEGIN.*?   // RTL_RETIRE_OBSERVER_END\n',text,re.S).group()
 declaration=' longint unsigned rtl_retired=0,rtl_last_retired=0;\n'
 old_command="  cmd_kind=3'(kind_run);cmd_layer=kind_run==7?0:5'(decision_local);cmd_qtype=2;cmd_marker_rows=0;cmd_marker_rows[0]=23;cmd_marker_rows[1]=33;cmd_marker_mask=16'h0003;cmd_candidate_count=2;\n"
 new_command="  cmd_kind=3'(kind_run);cmd_layer=kind_run==7?0:5'(decision_local);\n  if(kind_run==7)begin cmd_qtype=2;cmd_marker_rows=0;cmd_marker_rows[0]=23;cmd_marker_rows[1]=33;cmd_marker_mask=16'h0003;cmd_candidate_count=2;end\n  else begin cmd_qtype=0;cmd_marker_rows=0;cmd_marker_mask=0;cmd_candidate_count=0;end\n"
 previous_v3=R/'prepared/fullgraph_retire_progress_v3/frozen/m007_fullgraph_binary_tb.sv'
 assert sha(previous_v3)=='8b556ca2b32f2a41f7ca1d259d5f7c714a8dd473d131e8949f6dcabd1a3ea570'
 assert text.count(new_command)==1 and text.replace(new_command,old_command,1)==previous_v3.read_text()
 assert text.replace(new_command,old_command,1).replace(declaration,'',1).replace(observer,'',1)==previous.read_text()
 OUT.write_text(text)
 report={'schema':'m007-r007-fullgraph-binary-checker-source-v1','status':'SOURCE_PREPARED_NOT_COMPILED_NOT_RUN','source':str(OUT.relative_to(ROOT)),'sha256':sha(OUT),'generator_sha256':sha(Path(__file__)),'new_checker_body':str((S/'fullgraph_binary_checker_r007.svpart').relative_to(ROOT)),'new_checker_body_sha256':sha(S/'fullgraph_binary_checker_r007.svpart'),'source_setup_baseline':str(base.relative_to(ROOT)),'source_setup_baseline_sha256':sha(base),'peer':str((M/'forward_controller/tb/m007_binary_weight_peer_tb.sv').relative_to(ROOT)),'peer_sha256':sha(M/'forward_controller/tb/m007_binary_weight_peer_tb.sv'),'supported_public_kinds':[6,7],'kind7_full_layers':30,'kind7_initial_input_only':'embedding_norm','old_kind5_checker_and_1d_compat_unchanged':True,'production_RTL_changed':False,'new_F32_gold_or_model_run_or_full120_weight_pack':False,'endpoint_checks':['actual all30 residual H endpoint writes at true global layer identity','actual final gamma LN Q writes','actual type-add H writes','actual Decision1 marker+CLS gather544 vectors','standalone public Decision0/1 full outputs'],'protocol_checks':['one BEGIN/one4096 public input','actual120 catalog refill order/address and transport idle','all120 matrix shapes/tensor IDs/four-port base-span','all16 heads for30 layers and full/sliding/Decision kinds','60LN/60residual+type/28GEGLU counts','Decision FC1/ReLU/K4096 A1 full16384write+ACK beforeFC2','actual output bytes written/flushed before independent tail commit','final heldDONE/identity/full transport-resource retirement'],'not_run':['SV compile','kind6 execution','kind7 execution','new backend cost gate','physical/DMA/board'],'wall_s':time.monotonic()-start}
 report.update({'revision':2,'previous_frozen_source':'prepared/fullgraph_kind6_kind7/frozen/m007_fullgraph_binary_tb.sv','previous_source_sha256':'87cca31b48f3ae9d027b2341ac1be683c22b0ebbc439cac628bcdd5ee4c2835b','public_ABI_assertions_added':['Every real kind7 output row matches fixed original marker23/33/inactive0 or CLS0 source row','tail_begin actual acceptance checks request/generation/source_epoch and69632B','SIM tail commit uses accepted immutable identity and asserts it while held'],'normal_source_only_change':True})
 report.update({'revision':3,'previous_frozen_source':str(previous.relative_to(R)),'previous_source_sha256':sha(previous),'only_retirement_observer_added':True,'removing_only_observer_and_its_two_counters_reconstructs_previous_top':True,'retirement_marker':'M007_RTL_RETIRE_PROGRESS retired=<actual accepted result/ACK events> cycle=<existing real cycle>','retirement_emit_interval':128,'retirement_counter_cross_layer_monotonic':True,'original_gold_checked_marker_and_all_assertions_unchanged':True,'retirement_events':['matrix core PS write response accepted','quant A write response accepted','Attention PS write response accepted','Attention context write response accepted','resident LN Q valid/ready/commit','G result valid/ready','resident VECTOR H valid/ready/commit']})
 report.update({'revision':4,'previous_frozen_source':str(previous_v3.relative_to(R)),'previous_source_sha256':sha(previous_v3),'only_retirement_observer_added':False,'removing_only_observer_and_its_two_counters_reconstructs_previous_top':False,'reversing_only_kind6_public_command_field_conditional_reconstructs_8b55':True,'only_change_from_v3':'Only kind6 qtype,all16marker_rows,marker_mask,candidate_count are zero; kind7 keeps exact original assignment order/values. No delay/eval/stimulus schedule/clock/assertion/production/gold changes.','kind7_original_command_assignment_sequence_preserved':True,'kind6_public_ABI_fields_zero':True})
 (R/'fullgraph_binary_checker_source_preparation_v4.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report))
if __name__=='__main__':main()
