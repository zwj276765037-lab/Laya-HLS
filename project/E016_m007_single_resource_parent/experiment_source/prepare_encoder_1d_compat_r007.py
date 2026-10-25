#!/usr/bin/env python3
"""1D readmemh compatibility only, keeping the original kind5 math/peer."""
from pathlib import Path
import hashlib,json,time
ROOT=Path(__file__).resolve().parents[3];R=ROOT/'project/E016_m007_single_resource_parent/experiment_results/runs/R007';M=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design';BASE=R/'attempts/AT036_complete_Encoder_progress_alias_build/frozen/m007_fullmodel_encoder_tb.sv';OUT=M/'forward_controller/tb/m007_fullmodel_encoder_1d_tb.sv'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 start=time.monotonic();assert sha(BASE)=='37e8c14793d66b990a9b65efa3fb7c5c3fc5991c189ccd4155ecc65aea6ed755';old=BASE.read_text();new=old.replace('module m007_fullmodel_encoder_tb;','module m007_fullmodel_encoder_1d_tb;',1);decl=' logic[31:0]rope_load[0:8191];\n';pos=new.index(' logic[31:0]rope_mem[0:3][0:8191];');new=new[:pos]+decl+new[pos:];changes=[]
 for t,name in enumerate(['cos_full.mem','sin_full.mem','cos_slide.mem','sin_slide.mem']):
  before=f'$readmemh({{rope_dir,"/{name}"}},rope_mem[{t}]);';after=f'$readmemh({{rope_dir,"/{name}"}},rope_load);for(int j=0;j<8192;j++)rope_mem[{t}][j]=rope_load[j];';assert new.count(before)==1;new=new.replace(before,after,1);changes.append({'before':before,'after':after})
 reconstructed=new.replace('module m007_fullmodel_encoder_1d_tb;','module m007_fullmodel_encoder_tb;',1).replace(decl,'',1)
 for c in changes:reconstructed=reconstructed.replace(c['after'],c['before'],1)
 assert reconstructed==old
 residual_decl=' logic[31:0]residual_scalar[0:131071];\n'
 residual_old='  $readmemh({residual_fixture,"/GOLD.hex"},residual_a);'
 residual_packed='  $readmemh({residual_fixture,"/GOLD.hex"},residual_scalar);\n  for(int group_index=0;group_index<4096;group_index++)for(int lane=0;lane<32;lane++)residual_a[group_index][32*lane+:32]=residual_scalar[32*group_index+lane];'
 assert new.count(residual_old)==1
 position=new.index(' logic [1023:0] original_qkv_input')
 new=new[:position]+residual_decl+new[position:]
 new=new.replace(residual_old,residual_packed,1)
 # A single-credit adapter may retire an old response and accept its replacement
 # on one edge. Check the old response before updating the pending coordinate.
 previous_sha=hashlib.sha256(new.encode()).hexdigest()
 assert previous_sha=='172d301937532841baaa938e45eb2f48913b7821b60bb6776671ba52f6d5d555'
 read_check=next(line for line in new.splitlines(True) if 'if(dut.c_rd_valid&&dut.c_rd_ready)begin if(ctx_owned||' in line)
 response_check=next(line for line in new.splitlines(True) if 'if(dut.c_rsp_valid&&dut.c_rsp_ready)begin int q,h,half;' in line)
 assert new.count(read_check+response_check)==1
 new=new.replace(read_check+response_check,response_check+read_check,1)
 assert hashlib.sha256(new.replace(response_check+read_check,read_check+response_check,1).encode()).hexdigest()==previous_sha
 OUT.write_text(new)
 report={'schema':'m007-r007-encoder-1d-compat-source-v1','status':'SOURCE_PREPARED_NOT_COMPILED_NOT_RUN','source':str(OUT.relative_to(ROOT)),'sha256':sha(OUT),'baseline':str(BASE.relative_to(ROOT)),'baseline_sha256':sha(BASE),'baseline_reconstructed_exactly':True,'changes':changes,'additional_changes':['top module name','8192x32bit rope temporary array','131072x32bit residual scalar temporary plus zero-delay group32 pack'],'clock_delay_or_fixture_or_assertion_or_W_peer_change':False,'production_RTL_changed':False,'new_model_or_gold':False,'wall_s':time.monotonic()-start}
 report.update({'revision':2,'residual_scalar_pack':{'mapping':'residual_a[group][32*lane+:32]=original_GOLD_scalar[32*group+lane]','scalar_count':131072,'groups':4096,'lanes':32,'original_file_unchanged':True},'original_zero_extended_truncated_residual_loader_corrected':True,'changes_before_residual_pack':changes,'actual_clock_delay_or_assertions_or_W_peer_changed':False})
 report.update({'revision':3,'context_credit_observer':'Consume/check old matching response before checking/registering same-edge replacement read; all original identity, ordering, payload and debt predicates unchanged','previous_residual_pack_top_sha256':previous_sha,'reversing_only_context_observer_order_reconstructs_previous_top':True,'actual_clock_delay_or_assertions_or_W_peer_changed':False})
 (R/'encoder_1d_context_credit_source_preparation.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report))
if __name__=='__main__':main()
