#!/usr/bin/env python3
import json,subprocess,sys
from pathlib import Path
root=Path(__file__).resolve().parents[5];run=root/'project/E012_m007_matrix_compute/experiment_results/runs/R004';runner=root/'project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tb/m007_matrix_pure_run.py';old=root/'project/E012_m007_matrix_compute/experiment_results/runs/R002/attempts/AT002_full_local_prebias_fixtures/work/fixture';inputs=root/'project/E012_m007_matrix_compute/experiment_results/runs/R003/attempts/AT007_original_quant_global_errors/work/fixture'
status=[]
for stage,name,build,profile in [('rtl','AT002_pure_production_qkv3','AT001_pure_production_build',False),('build','AT003_profile_compatibility_build',None,True),('rtl','AT004_profile_compatibility_qkv3','AT003_profile_compatibility_build',True)]:
 argv=[sys.executable,str(runner),stage,name,'--timeout','120']
 if stage=='rtl':argv+=['--compiled-sources','--build',str(run/'attempts'/build),'--fixture',str(old),'--input-fixture',str(inputs),'--case','0','--prefix','3']
 if profile:argv+=['--profile']
 print('DISPATCH '+name,flush=True);rc=subprocess.call(argv,cwd=root);p=run/'attempts'/name/('receipt_rtl.json' if stage=='rtl' else 'receipt_static.json');r=json.loads(p.read_text()) if p.exists() else None;status.append({'attempt':name,'runner_exit':rc,'verdict':r['verdict'] if r else 'PRELAUNCH_ERROR','wall_s':r['wall_s'] if r else 0});(run/'initial_sequence_status.json').write_text(json.dumps(status,indent=2)+'\n')
 if rc:raise SystemExit(rc)
print('R004_INITIAL_PROFILE_COMPARISON_COMPLETE',flush=True)
