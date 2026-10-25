#!/usr/bin/env python3
import json,subprocess,sys
from pathlib import Path
root=Path(__file__).resolve().parents[5];run=root/'project/E012_m007_matrix_compute/experiment_results/runs/R004';runner=root/'project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tb/m007_matrix_pure_run.py';fixture=run/'attempts/AT005_original_context_wo_fixture/work/fixture';build=run/'attempts/AT006_pure_response_error_build'
assert json.loads((build/'receipt_static.json').read_text())['verdict']=='PASS'
status=[]
for name,prefix,timeout in [('AT007_real_context_wo3',3,120),('AT008_complete_real_context_wo',0,600)]:
 argv=[sys.executable,str(runner),'rtl',name,'--compiled-sources','--build',str(build),'--fixture',str(fixture),'--input-fixture',str(fixture),'--case','1','--prefix',str(prefix),'--timeout',str(timeout)]
 if prefix==0:
  argv+=['--pilot',str(run/'attempts/AT007_real_context_wo3'),'--reserve-rtl','240']
  for prior in ['AT023_current_complete_f32_wo','AT030_current_complete_f32_down']:argv+=['--cost-baseline',str(root/'project/E012_m007_matrix_compute/experiment_results/runs/R003/attempts'/prior)]
 print('DISPATCH '+name,flush=True);rc=subprocess.call(argv,cwd=root);p=run/'attempts'/name/'receipt_rtl.json';r=json.loads(p.read_text()) if p.exists() else None;status.append({'attempt':name,'runner_exit':rc,'verdict':r['verdict'] if r else 'PRELAUNCH_ERROR','wall_s':r['wall_s'] if r else 0});(run/'real_context_wo_sequence_status.json').write_text(json.dumps(status,indent=2)+'\n')
 if rc and (r is None or r['verdict']!='COST_STOP'):raise SystemExit(rc)
 if prefix and (r is None or r['verdict']!='PASS'):break
print('R004_REAL_CONTEXT_WO_SEQUENCE_EXIT',flush=True)
