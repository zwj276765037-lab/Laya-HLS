#!/usr/bin/env python3
import subprocess,sys
from pathlib import Path
root=Path(__file__).resolve().parents[5]
runner=root/'project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tb/m007_matrix_f32_run.py'
run=root/'project/E012_m007_matrix_compute/experiment_results/runs/R003'
old=root/'project/E012_m007_matrix_compute/experiment_results/runs/R002/attempts'
fixture=old/'AT002_full_local_prebias_fixtures/work/fixture'
inputs=run/'attempts/AT007_original_quant_global_errors/work/fixture'
build=run/'attempts/AT018_f32_shared_div_idle_build'
jobs=[('AT019_current_div_release_idle_recovery',0,6,3,120,None,None,0),('AT020_current_f32_qkv_pilot',0,0,3,120,None,None,0),('AT021_current_f32_wo_bias_pilot',7,0,3,120,None,None,0),('AT022_current_complete_f32_qkv',0,0,0,900,'AT020_current_f32_qkv_pilot','AT015_full_qkv',400),('AT023_current_complete_f32_wo',1,0,0,400,'AT021_current_f32_wo_bias_pilot','AT032_repaired_complete_wo',300)]
for attempt,case,stress,prefix,timeout,pilot,baseline,reserve in jobs:
 argv=[sys.executable,str(runner),'rtl',attempt,'--compiled-sources','--fixture',str(fixture),'--input-fixture',str(inputs),'--build',str(build),'--case',str(case),'--stress',str(stress),'--prefix',str(prefix),'--timeout',str(timeout)]
 if pilot:argv+=['--pilot',str(run/'attempts'/pilot),'--cost-baseline',str(old/baseline),'--reserve-rtl',str(reserve)]
 print('ACTUAL_SEQUENCE_START '+attempt,flush=True)
 rc=subprocess.call(argv,cwd=root)
 print('ACTUAL_SEQUENCE_END '+attempt+' exit='+str(rc),flush=True)
 if rc:raise SystemExit(rc)
