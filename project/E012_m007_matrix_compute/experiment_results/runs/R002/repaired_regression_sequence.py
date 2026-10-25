#!/usr/bin/env python3
"""Affected post-cleanup regression; preserves prior full-N identities separately."""
import json,subprocess,sys,time
from pathlib import Path
root=Path.cwd();r=root/'project/E012_m007_matrix_compute/experiment_results/runs/R002';runner=root/'project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tb/m007_matrix_full_run.py'
probe=r/'attempts/AT030_cancel_completion_recovery/receipt_rtl.json'
while not probe.exists():time.sleep(1)
if json.loads(probe.read_text())['verdict']!='PASS':raise SystemExit('Corrected recovery did not pass; stop dependent regressions')
base=[sys.executable,str(runner),'rtl'];common=['--fixture',str(r/'attempts/AT002_full_local_prebias_fixtures/work/fixture'),'--build',str(r/'attempts/AT029_cancel_completion_build')]
cases=[('AT031_repaired_normal_qkv_prefix',['--case','0','--prefix','3','--timeout','120']),('AT032_repaired_complete_wo',['--case','1','--prefix','0','--timeout','420','--pilot',str(r/'attempts/AT031_repaired_normal_qkv_prefix'),'--cost-baseline',str(r/'attempts/AT016_full_wi')]),('AT033_repaired_common_reset',['--case','0','--prefix','3','--stress','3','--timeout','120']),('AT034_repaired_decision_qkv_bias',['--case','6','--prefix','3','--timeout','120']),('AT035_repaired_decision_wo_bias',['--case','7','--prefix','3','--timeout','120'])]
for name,args in cases:
 print('START_ACTUAL_REPAIRED_REGRESSION',name,flush=True)
 p=subprocess.run([*base,name,*args,*common])
 if p.returncode:raise SystemExit(p.returncode)
 print('FINISHED_PASS',name,flush=True)
