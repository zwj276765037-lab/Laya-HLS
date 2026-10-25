#!/usr/bin/env python3
"""Five required bounded same-DUT directed cases under independent guard caps."""
import subprocess,sys
from pathlib import Path
root=Path.cwd();r=root/'project/E012_m007_matrix_compute/experiment_results/runs/R002';runner=root/'project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tb/m007_matrix_full_run.py'
for name,case,stress in [('AT022_fc1_finite_stalls',4,1),('AT023_prefetch_error_new_identity',0,2),('AT024_common_reset_new_identity',0,3),('AT025_decision_qkv_bias_prefix',6,0),('AT026_decision_wo_bias_prefix',7,0)]:
 print('START_ACTUAL_DIRECTED',name,flush=True)
 p=subprocess.run([sys.executable,str(runner),'rtl',name,'--case',str(case),'--prefix','3','--stress',str(stress),'--timeout','120','--fixture',str(r/'attempts/AT002_full_local_prebias_fixtures/work/fixture'),'--build',str(r/'attempts/AT021_directed_barrier_build')])
 if p.returncode:raise SystemExit(p.returncode)
 print('FINISHED_PASS',name,flush=True)
