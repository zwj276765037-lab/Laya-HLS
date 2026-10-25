from pathlib import Path
from decimal import Decimal
import hashlib,json
ROOT=Path(__file__).resolve().parents[3];RUN=ROOT/'project/E019_m007_residual_ln_residency/experiment_results/runs/R003'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def read(p):return json.loads(p.read_text())
def save(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
force='AT002_force1_residual128_LN16';auto='AT004_auto0_residual128_LN16'
results={}
for name,at in [('force1',force),('auto0',auto)]:
 p=RUN/'attempts'/at;r=read(p/'receipt.json');m=read(p/'work/report.json');assert r['status']=='EXIT_ZERO'and m['status']=='PASS'and m['metrics']['rows']==16
 begin=next(x for x in m['wall_events']if x['line'].startswith('JOINT23_LN_BEGIN'))['elapsed_s'];end=next(x for x in m['wall_events']if x['line'].startswith('JOINT23_LN_END'))['elapsed_s'];ln=end-begin
 results[name]={'attempt':at,'guarded_total_s':r['child_wall_s'],'runtime_body_wall_s':m['runtime_body_wall_s'],'startup_to_TB_marker_s':next(x for x in m['wall_events']if x['line'].startswith('JOINT27_START'))['elapsed_s'],'LN16_s':ln,'fixed_s':r['child_wall_s']-ln,'cycles':m['cycles'],'metrics':m['metrics'],'CE_metrics':m['CE_metrics'],'trace_sha256':m['functional_cycle_trace_sha256'],'trace_bytes':m['functional_cycle_trace_bytes'],'receipt_sha256':sha(p/'receipt.json'),'report_sha256':sha(p/'work/report.json'),'build_manifest_sha256':m['build_manifest_sha256']}
f=results['force1'];a=results['auto0']
assert f['cycles']==a['cycles']and f['metrics']==a['metrics']and f['trace_sha256']==a['trace_sha256']and f['trace_bytes']==a['trace_bytes']
bf=RUN/'attempts/AT001_force1_joint_build/work';ba=RUN/'attempts/AT003_auto0_joint_build/work';mf=read(bf/'report.json');ma=read(ba/'report.json')
assert mf['compiled_source_sha256']==ma['compiled_source_sha256']and mf['force_core_ce']==1 and ma['force_core_ce']==0
comp={'schema':'m007-joint27-current-source-CE-cost-comparison-v1','status':'PASS','same_frozen_compiled_source':True,'source_builds':{'force1':str(bf),'auto0':str(ba)},'configurations':results,'exact_cycle_control_trace_equal':True,'trace_signal_count':221,'numeric_assertions_equal':True,'guarded_wall_speedup':f['guarded_total_s']/a['guarded_total_s'],'LN16_wall_speedup':f['LN16_s']/a['LN16_s'],'timing_scope':'One actual run per configuration, identical221-signal cycle trace/original independent values; wall speedup is this tool/host/constraint comparison only; no hardware throughput claim'}
save(RUN/'force1_auto0_comparison.json',comp)
used=sum((json.loads(q.read_text(),parse_float=Decimal).get('child_wall_s',Decimal(0))for q in(RUN/'attempts').glob('AT*/receipt.json')if read(q)['phase']=='rtl'),Decimal(0));remaining=Decimal(900)-used
estimate=a['fixed_s']+1.35*8*a['LN16_s']+10;allowed=estimate<=120 and remaining>=Decimal(str(estimate))+120
fullat='AT005_auto0_residual128_LN128';out=RUN/'attempts'/fullat/'work';driver=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/attention_and_fp_engine/tb/m007_joint27_run.py';cmd=['python3',str(driver),'rtl','--force-ce','0','--rows','128','--output',str(out),'--build',str(ba)]
gate={'schema':'m007-joint27-full128-cost-gate-v1','status':'ADMITTED'if allowed else'COST_STOP','pilot_attempt':auto,'formula':'t_fixed+1.35*8*t_LN16+10','measured_auto0_total_s':a['guarded_total_s'],'measured_auto0_LN16_s':a['LN16_s'],'fixed_s':a['fixed_s'],'estimate_s':estimate,'cap_s':120,'remaining_rtl_s':str(remaining),'required_reserve_s':120,'full128_launched':False,'reason':'measured same-build estimate and independent remaining budget both satisfy original gate'if allowed else'measured same-build estimate or remaining budget fails original gate; no timeout extension','same_frozen_source_comparison':'force1_auto0_comparison.json'}
save(RUN/'LN128_cost_gate.json',gate)
if allowed:
 save(RUN/'LN128_cost_plan.json',{'schema':'m007-joint27-cost-v1','command':cmd,'requested_timeout_s':120,'pilot_attempt':auto,'pilot_receipt_sha256':a['receipt_sha256'],'pilot_report_sha256':a['report_sha256'],'conservative_bound_s':estimate,'remaining_rtl_s':float(remaining),'build_work':str(ba),'build_manifest_sha256':a['build_manifest_sha256']})
print(json.dumps({'comparison':comp,'gate':gate},indent=2))
