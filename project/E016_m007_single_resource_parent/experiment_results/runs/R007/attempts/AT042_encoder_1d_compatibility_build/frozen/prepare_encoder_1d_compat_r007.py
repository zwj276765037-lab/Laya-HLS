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
 assert reconstructed==old;OUT.write_text(new)
 report={'schema':'m007-r007-encoder-1d-compat-source-v1','status':'SOURCE_PREPARED_NOT_COMPILED_NOT_RUN','source':str(OUT.relative_to(ROOT)),'sha256':sha(OUT),'baseline':str(BASE.relative_to(ROOT)),'baseline_sha256':sha(BASE),'baseline_reconstructed_exactly':True,'changes':changes,'additional_changes':['top module name','8192x32bit simulation temporary array'],'clock_delay_or_fixture_or_assertion_or_W_peer_change':False,'production_RTL_changed':False,'new_model_or_gold':False,'wall_s':time.monotonic()-start}
 (R/'encoder_1d_compat_source_preparation.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report))
if __name__=='__main__':main()
