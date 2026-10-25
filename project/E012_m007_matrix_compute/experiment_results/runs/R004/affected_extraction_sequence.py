#!/usr/bin/env python3
import json,subprocess,sys
from pathlib import Path
root=Path(__file__).resolve().parents[5];run=root/'project/E012_m007_matrix_compute/experiment_results/runs/R004';runner=root/'project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tb/m007_matrix_pure_run.py';fixture=root/'project/E012_m007_matrix_compute/experiment_results/runs/R002/attempts/AT002_full_local_prebias_fixtures/work/fixture';inputs=root/'project/E012_m007_matrix_compute/experiment_results/runs/R003/attempts/AT007_original_quant_global_errors/work/fixture';build=run/'attempts/AT006_pure_response_error_build';status=[]
for name,case,prefix,stress in [('AT011_pure_down2',3,2,0),('AT012_pure_decision_wo_bias3',7,3,0),('AT013_pure_fc2_bias1',5,1,0),('AT014_pure_matrix_error_release_recovery',0,3,9),('AT015_pure_bias_PS_output_holds',4,3,1),('AT016_pure_last_quant_A_ack_holds',0,3,5)]:
 argv=[sys.executable,str(runner),'rtl',name,'--compiled-sources','--build',str(build),'--fixture',str(fixture),'--input-fixture',str(inputs),'--case',str(case),'--prefix',str(prefix),'--stress',str(stress),'--timeout','120']
 print('DISPATCH '+name,flush=True);rc=subprocess.call(argv,cwd=root);p=run/'attempts'/name/'receipt_rtl.json';r=json.loads(p.read_text()) if p.exists() else None;status.append({'attempt':name,'runner_exit':rc,'verdict':r['verdict'] if r else 'PRELAUNCH_ERROR','wall_s':r['wall_s'] if r else 0});(run/'affected_sequence_status.json').write_text(json.dumps(status,indent=2)+'\n')
 if rc:raise SystemExit(rc)
print('R004_AFFECTED_SEQUENCE_EXIT',flush=True)
