#!/usr/bin/env python3
import subprocess,sys
from pathlib import Path
root=Path(__file__).resolve().parents[5]
runner=root/'project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tb/m007_matrix_f32_run.py'
run=root/'project/E012_m007_matrix_compute/experiment_results/runs/R003'
fixture=root/'project/E012_m007_matrix_compute/experiment_results/runs/R002/attempts/AT002_full_local_prebias_fixtures/work/fixture'
inputs=run/'attempts/AT007_original_quant_global_errors/work/fixture'
jobs=[('AT012_failed_publication_peer','m007_quant_a_peer_tb','AT010_failed_publication_peer_build',0,0),('AT013_global_inverse_error_recovery','m007_matrix_f32_tb','AT006_f32_shell_build',0,6),('AT014_global_input_error_recovery','m007_matrix_f32_tb','AT006_f32_shell_build',0,7),('AT015_last_quant_and_A_ack_hold','m007_matrix_f32_tb','AT006_f32_shell_build',0,5),('AT016_input_identity_order_reject','m007_matrix_f32_tb','AT006_f32_shell_build',0,4),('AT017_quant_inflight_reset_recovery','m007_matrix_f32_tb','AT006_f32_shell_build',0,8)]
for attempt,top,build,case,stress in jobs:
 argv=[sys.executable,str(runner),'rtl',attempt,'--compiled-sources','--top',top,'--fixture',str(fixture),'--input-fixture',str(inputs),'--build',str(run/'attempts'/build),'--case',str(case),'--stress',str(stress),'--prefix','3','--timeout','120']
 print('ACTUAL_SEQUENCE_START '+attempt,flush=True)
 rc=subprocess.call(argv,cwd=root)
 print('ACTUAL_SEQUENCE_END '+attempt+' exit='+str(rc),flush=True)
 if rc:raise SystemExit(rc)
