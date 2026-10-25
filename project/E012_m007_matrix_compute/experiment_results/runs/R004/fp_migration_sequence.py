#!/usr/bin/env python3
import json,subprocess,sys
from pathlib import Path
root=Path(__file__).resolve().parents[5];run=root/'project/E012_m007_matrix_compute/experiment_results/runs/R004';runner=root/'project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tb/m007_matrix_pure_run.py';selection=json.loads((run/'fp_migration_selection.json').read_text());oldfixture=root/'project/E012_m007_matrix_compute/experiment_results/runs/R002/attempts/AT002_full_local_prebias_fixtures/work/fixture';oldinput=root/'project/E012_m007_matrix_compute/experiment_results/runs/R003/attempts/AT007_original_quant_global_errors/work/fixture';realfixture=run/'attempts/AT005_original_context_wo_fixture/work/fixture';build=run/'attempts/AT019_new_FP_consumer_build';status=[]
for name in ['AT011_pure_down2','AT012_pure_decision_wo_bias3','AT013_pure_fc2_bias1','AT014_pure_matrix_error_release_recovery','AT015_pure_bias_PS_output_holds','AT016_pure_last_quant_A_ack_holds','AT018_actual_DIV_live_producer_close']:assert json.loads((run/'attempts'/name/'receipt_rtl.json').read_text())['verdict']=='PASS'
jobs=[('build','AT019_new_FP_consumer_build',0,3,0,False),('rtl','AT020_new_FP_qkv3',0,3,0,False),('rtl','AT021_new_FP_error_release_recovery',0,3,9,False),('rtl','AT022_new_FP_bias_PS_output_holds',4,3,1,False),('rtl','AT023_new_FP_real_context_wo3',1,3,0,True),('rtl','AT024_new_FP_complete_real_context_wo',1,0,0,True)]
for stage,name,case,prefix,stress,real in jobs:
 argv=[sys.executable,str(runner),stage,name,'--timeout',str(600 if prefix==0 else 120)]
 if stage=='build':argv+=['--compiled-sources','--build',str(run/'attempts/AT006_pure_response_error_build'),'--fp-source',str(root/selection['selected_source']),'--fp-sha',selection['selected_FP_sha256']]
 else:
  fixture=realfixture if real else oldfixture;inputs=realfixture if real else oldinput;argv+=['--compiled-sources','--build',str(build),'--fixture',str(fixture),'--input-fixture',str(inputs),'--case',str(case),'--prefix',str(prefix),'--stress',str(stress)]
  if prefix==0:
   argv+=['--pilot',str(run/'attempts/AT023_new_FP_real_context_wo3'),'--reserve-rtl','240','--cost-baseline',str(run/'attempts/AT008_complete_real_context_wo'),'--cost-baseline',str(root/'project/E012_m007_matrix_compute/experiment_results/runs/R003/attempts/AT030_current_complete_f32_down')]
 print('EXPLICIT_NEW_FP_DISPATCH '+name,flush=True);rc=subprocess.call(argv,cwd=root);p=run/'attempts'/name/('receipt_static.json' if stage=='build' else 'receipt_rtl.json');r=json.loads(p.read_text()) if p.exists() else None;status.append({'attempt':name,'runner_exit':rc,'verdict':r['verdict'] if r else 'PRELAUNCH_ERROR','wall_s':r['wall_s'] if r else 0});(run/'fp_migration_status.json').write_text(json.dumps(status,indent=2)+'\n')
 if rc:
  if r and r['verdict']=='COST_STOP':print('NEW_FP_SCOPE_BOUNDED_COST_EXIT no old result migrated',flush=True)
  raise SystemExit(rc)
print('R004_EXPLICIT_NEW_FP_MIGRATION_EXIT old/new scopes stay distinct',flush=True)
