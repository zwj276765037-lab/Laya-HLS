#!/usr/bin/env python3
"""Prepare a binary-source successor without touching the frozen kind5 checker."""
from pathlib import Path
import hashlib,json,re,time
ROOT=Path(__file__).resolve().parents[3]
R=ROOT/'project/E016_m007_single_resource_parent/experiment_results/runs/R007'
M=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design'
BASE=R/'attempts/AT036_complete_Encoder_progress_alias_build/frozen/m007_fullmodel_encoder_tb.sv'
OUT=M/'forward_controller/tb/m007_fullmodel_encoder_binary_tb.sv'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 start=time.monotonic();assert sha(BASE)=='37e8c14793d66b990a9b65efa3fb7c5c3fc5991c189ccd4155ecc65aea6ed755'
 baseline=BASE.read_text();text=baseline.replace('module m007_fullmodel_encoder_tb;','module m007_fullmodel_encoder_binary_tb;',1)
 start_old=text.index(' always @(negedge clk)begin\n  if(!rst_n)begin rvalid=0;');stop=text.index('  if(rst_n&&full_active)begin',start_old)
 removed=text[start_old:stop];text=text[:start_old]+' always @(negedge clk)begin\n'+text[stop:]
 # All matrix/Attention/quant/G/LN/residual/output checker code is unchanged.
 # The old arrays and word_at remain solely independent expected values.
 begin=text.index(' // One actual catalog request with held response;');end=text.index(' always@(posedge clk)if(rst_n)begin\n  cycle++;',begin)
 catalog_old=text[begin:end]
 mapping={'arready':'catalog_arready','rvalid':'catalog_rvalid','rid':'catalog_rid','rdata':'catalog_rdata','rresp':'catalog_rresp','rlast':'catalog_rlast'}
 catalog_new=re.sub(r'\b(arready|rvalid|rid|rdata|rresp|rlast)\b',lambda m:mapping[m.group(0)],catalog_old)
 text=text[:begin]+catalog_new+text[end:]
 for old,new in mapping.items():
  needle=f"  {old}='0;";assert text.count(needle)==1;text=text.replace(needle,f"  {new}='0;",1)
 addition='''
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
'''
 pos=text.index(' always @(negedge clk)begin');text=text[:pos]+addition+text[pos:]
 
 residual_decl=' logic[31:0]residual_scalar[0:131071];\n'
 residual_old='  $readmemh({residual_fixture,"/GOLD.hex"},residual_a);'
 residual_packed='  $readmemh({residual_fixture,"/GOLD.hex"},residual_scalar);\n  for(int group_index=0;group_index<4096;group_index++)for(int lane=0;lane<32;lane++)residual_a[group_index][32*lane+:32]=residual_scalar[32*group_index+lane];'
 assert text.count(residual_old)==1
 position=text.index(' logic [1023:0] original_qkv_input')
 text=text[:position]+residual_decl+text[position:]
 text=text.replace(residual_old,residual_packed,1)
 OUT.write_text(text)
 # Reconstruct byte-for-byte baseline from the strictly enumerated edits.
 proof=text.replace(residual_decl,'',1).replace(residual_packed,residual_old,1).replace(addition,'',1).replace('module m007_fullmodel_encoder_binary_tb;','module m007_fullmodel_encoder_tb;',1)
 proof=proof.replace(' always @(negedge clk)begin\n  if(rst_n&&full_active)begin',removed+'  if(rst_n&&full_active)begin',1)
 proof=proof.replace(catalog_new,catalog_old,1)
 for old,new in mapping.items():proof=proof.replace(f"  {new}='0;",f"  {old}='0;",1)
 assert proof==baseline,'any non-peer numerical/checker source modification is forbidden'
 report={'schema':'m007-r007-binary-encoder-checker-source-v1','status':'SOURCE_PREPARED_NOT_COMPILED_NOT_RUN','source':str(OUT.relative_to(ROOT)),'sha256':sha(OUT),'baseline':str(BASE.relative_to(ROOT)),'baseline_sha256':sha(BASE),'peer':str((M/'forward_controller/tb/m007_binary_weight_peer_tb.sv').relative_to(ROOT)),'peer_sha256':sha(M/'forward_controller/tb/m007_binary_weight_peer_tb.sv'),'exact_baseline_reconstruction':True,'kind5_layer0_only':True,'all120_binary_source_available':True,'all_numerical_assertions_and_original_fixture_reads_unchanged':True,'production_RTL_changes':False,'new_floating_gold_or_model_run_or_full120_pack':False,'changes':['top name','replace old W response scheduler by §17 peer','catalog/W response mux and peer-idle assertion','catalog driver signal namespace'],'not_run':['successor build','production W-reader/cache unit','new parent mathematical prefix','kind6/7 full checker'],'wall_s':time.monotonic()-start}
 report.update({'revision':2,'original_fixture_loads_except_residual_unchanged':True,'residual_scalar_pack':'131072 original32bit words ->4096x32 lanes with exact little-endian bit positions; no truncation, endpoint cap or floating arithmetic','all_numerical_assertions_and_original_fixture_reads_unchanged':False,'original_fixtures_and_numerical_assertions_unchanged':True})
 (R/'binary_encoder_residual_pack_source_preparation.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report))
if __name__=='__main__':main()
