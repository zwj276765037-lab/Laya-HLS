#!/usr/bin/env python3
import json,subprocess,sys
from pathlib import Path
root=Path(__file__).resolve().parents[5];run=root/'project/E012_m007_matrix_compute/experiment_results/runs/R003';runner=root/'project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tb/m007_matrix_f32_run.py';old=root/'project/E012_m007_matrix_compute/experiment_results/runs/R002/attempts'
common=['--compiled-sources','--fixture',str(old/'AT002_full_local_prebias_fixtures/work/fixture'),'--input-fixture',str(run/'attempts/AT007_original_quant_global_errors/work/fixture'),'--build',str(run/'attempts/AT024_stronger_observation_build'),'--case','5','--stress','0']
name='AT035_current_fc2_bias_single_pilot';print('DISPATCH '+name+' actual_prefix=1 timeout=120',flush=True);rc=subprocess.call([sys.executable,str(runner),'rtl',name,*common,'--prefix','1','--timeout','120'],cwd=root);p=run/'attempts'/name/'receipt_rtl.json';r=json.loads(p.read_text()) if p.exists() else None
status=[{'attempt':name,'actual_prefix':1,'runner_exit':rc,'verdict':r['verdict'] if r else 'PRELAUNCH_ERROR','wall_s':r['wall_s'] if r else 0}]
if r and r['verdict']=='PASS':
 name='AT036_current_complete_f32_fc2';print('DISPATCH '+name+' actual_prefix=0 timeout<=1200 cost gate required',flush=True);rc=subprocess.call([sys.executable,str(runner),'rtl',name,*common,'--prefix','0','--timeout','1200','--pilot',str(p.parent),'--reserve-rtl','0'],cwd=root);q=run/'attempts'/name/'receipt_rtl.json';r=json.loads(q.read_text()) if q.exists() else None;status.append({'attempt':name,'runner_exit':rc,'verdict':r['verdict'] if r else 'PRELAUNCH_ERROR','wall_s':r['wall_s'] if r else 0})
else:status.append({'attempt':'AT036_current_complete_f32_fc2','verdict':'NOT_RUN','reason':'one-block bounded pilot did not pass; no further timeout extension or attempt fabricated'})
(run/'fc2_pilot_replan_status.json').write_text(json.dumps(status,indent=2)+'\n');print('R003_FC2_REPLAN_EXIT '+json.dumps(status),flush=True)
