#!/usr/bin/env python3
"""Continue only authorized R003 validation. Each actual child acquires one lock."""
import json,subprocess,sys,time
from pathlib import Path
root=Path(__file__).resolve().parents[5];run=root/'project/E012_m007_matrix_compute/experiment_results/runs/R003'
runner=root/'project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tb/m007_matrix_f32_run.py'
old=root/'project/E012_m007_matrix_compute/experiment_results/runs/R002/attempts'
fixture=old/'AT002_full_local_prebias_fixtures/work/fixture';inputs=run/'attempts/AT007_original_quant_global_errors/work/fixture'
build=run/'attempts/AT024_stronger_observation_build';receipt=build/'receipt_static.json'
print('WAITING_EXISTING_AT024_BUILD_RECEIPT no new build launched',flush=True)
while not receipt.exists():time.sleep(1)
if json.loads(receipt.read_text())['verdict']!='PASS':raise SystemExit('existing AT024 build did not pass')
# Same actual DUT, current strengthened observation TB only.
bm=json.loads((build/'source_manifest.json').read_text());prior=json.loads((run/'attempts/AT018_f32_shared_div_idle_build/source_manifest.json').read_text())
def dut(m):return {s['frozen']:s['sha256'] for s in m['sources'] if s['path'].endswith('.sv') and '/rtl/' in s['path']}
assert dut(bm)==dut(prior),'do not silently switch shared/owned DUT version'
jobs=[('AT025_quant_response_full_hold',0,7,3,120,None,None,0),('AT026_full_input_identity_reject',0,4,3,120,None,None,0),('AT027_current_wi_pilot',2,0,3,120,None,None,0),('AT028_current_full_wi_cost_gate',2,0,0,1200,'AT027_current_wi_pilot','AT016_full_wi',800),('AT029_current_down_pilot',3,0,2,120,None,None,0),('AT030_current_complete_f32_down',3,0,0,1000,'AT029_current_down_pilot','AT017_full_down',240),('AT031_current_fc1_bias_pilot',4,0,3,120,None,None,0),('AT032_current_complete_f32_fc1',4,0,0,1200,'AT031_current_fc1_bias_pilot',None,120),('AT033_current_fc2_bias_pilot',5,0,2,120,None,None,0),('AT034_current_complete_f32_fc2',5,0,0,1200,'AT033_current_fc2_bias_pilot',None,0)]
status=[]
for attempt,case,stress,prefix,timeout,pilot,baseline,reserve in jobs:
 if pilot:
  p=run/'attempts'/pilot/'receipt_rtl.json'
  if not p.exists() or json.loads(p.read_text())['verdict']!='PASS':
   status.append({'attempt':attempt,'verdict':'NOT_RUN','reason':'required actual same-build pilot did not complete; no simulation/attempt fabricated'})
   (run/'remaining_shape_sequence_status.json').write_text(json.dumps(status,indent=2)+'\n');continue
 argv=[sys.executable,str(runner),'rtl',attempt,'--compiled-sources','--fixture',str(fixture),'--input-fixture',str(inputs),'--build',str(build),'--case',str(case),'--stress',str(stress),'--prefix',str(prefix),'--timeout',str(timeout)]
 if pilot:argv+=['--pilot',str(run/'attempts'/pilot),'--reserve-rtl',str(reserve)]
 if baseline:argv+=['--cost-baseline',str(old/baseline)]
 print('DISPATCH_RUNNER '+attempt+' actual_prefix='+str(prefix),flush=True)
 rc=subprocess.call(argv,cwd=root)
 p=run/'attempts'/attempt/'receipt_rtl.json';r=json.loads(p.read_text()) if p.exists() else None
 status.append({'attempt':attempt,'runner_exit':rc,'verdict':r['verdict'] if r else 'PRELAUNCH_ERROR','wall_s':r['wall_s'] if r else 0})
 (run/'remaining_shape_sequence_status.json').write_text(json.dumps(status,indent=2)+'\n')
 print('ACTUAL_RECEIPT '+attempt+' '+str(status[-1]),flush=True)
 if rc and (r is None or r['verdict']!='COST_STOP'):raise SystemExit(rc)
print('R003_REMAINING_AUTHORIZED_SEQUENCE_COMPLETE check scoped receipts; no new batch started',flush=True)
