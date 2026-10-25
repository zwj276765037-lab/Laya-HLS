#!/usr/bin/env python3
"""Sequential authorized full shapes; one existing guarded runner owns the tool lock."""
import json,subprocess,sys,time
from pathlib import Path
root=Path.cwd();run=root/'project/E012_m007_matrix_compute/experiment_results/runs/R002'
wo=run/'attempts/AT014_full_wo_progress/receipt_rtl.json'
while not wo.exists():time.sleep(1)
if json.loads(wo.read_text())['verdict']!='PASS':raise SystemExit('WO did not pass; preserve evidence and stop dependent sequence')
runner=root/'project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tb/m007_matrix_full_run.py'
fixture=run/'attempts/AT002_full_local_prebias_fixtures/work/fixture';build=run/'attempts/AT012_semantic_directed_build';pilot=run/'attempts/AT013_semantic_qkv_pilot'
for name,case,timeout in [('AT015_full_qkv',0,600),('AT016_full_wi',2,900),('AT017_full_down',3,600),('AT018_full_fc1_bias',4,600),('AT019_full_fc2_bias',5,900)]:
 print('START_ACTUAL_ATTEMPT',name,flush=True)
 p=subprocess.run([sys.executable,str(runner),'rtl',name,'--case',str(case),'--prefix','0','--timeout',str(timeout),'--fixture',str(fixture),'--build',str(build),'--pilot',str(pilot)])
 if p.returncode:raise SystemExit(p.returncode)
 print('FINISHED_PASS',name,flush=True)
