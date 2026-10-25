#!/usr/bin/env python3
"""Audit R002 versioned evidence; never reruns R001 or migrates old full-N results."""
import argparse,datetime as dt,hashlib,json,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];RUN=ROOT/'project/E012_m007_matrix_compute/experiment_results/runs/R002';ATT=RUN/'attempts'
PRIOR=['AT014_full_wo_progress','AT015_full_qkv','AT016_full_wi','AT017_full_down']
CURRENT=['AT030_cancel_completion_recovery','AT031_repaired_normal_qkv_prefix','AT032_repaired_complete_wo','AT033_repaired_common_reset','AT034_repaired_decision_qkv_bias','AT035_repaired_decision_wo_bias']
CAP={0:53120,1:18304,2:87936,3:45952,4:69504,5:69504};cache={}
REPAIR='''   // A repeated parent cancel may still update the final error above. Once
   // actual A/FP release and PS idle already completed, the inactive request
   // must not retain a stale abort latch and block the next real identity.
   if(state==FINALRELEASE&&release_a_done&&release_fp_done&&storage_idle)aborting<=0;
'''
def read(p):return json.loads(p.read_text())
def rel(p):return str(p.relative_to(ROOT))
def sha(p):
 p=Path(p);key=(str(p),p.stat().st_size,p.stat().st_mtime_ns)
 if key not in cache:
  h=hashlib.sha256()
  with p.open('rb') as f:
   for b in iter(lambda:f.read(1024*1024),b''):h.update(b)
  cache[key]=h.hexdigest()
 return cache[key]
def entry(p,e):assert p.is_file() and p.stat().st_size==e['bytes'] and sha(p)==e['sha256'],str(p)
def metrics(line):return {k:int(v) for k,v in re.findall(r'(\w+)=([0-9]+)',line)}
def dut(m):return {e['frozen']:e for e in m['sources'] if e['path'].endswith('.sv') and '/rtl/' in e['path']}
def audit(name,prior_core=False):
 d=ATT/name;m=read(d/'source_manifest.json');fi=read(d/'fixture_identity.json');build=Path(fi['build'])
 assert sha(build/'source_manifest.json')==fi['build_source_manifest_sha256']
 for e in m['sources']:
  entry(d/'frozen'/e['frozen'],e)
  if e['path'].endswith('.sv'):
   assert sha(build/'frozen'/e['frozen'])==e['sha256'],'compiled closure '+e['frozen']
   if '/rtl/' in e['path']:
    if prior_core and e['frozen']=='laya_m007_matrix_superblock_v1.sv':assert e['sha256']==sha(ATT/'AT012_semantic_directed_build/frozen'/e['frozen'])
    else:entry(Path(e['path']),e)
 for e in fi['files']:entry(Path(e['path']),e)
 for e in fi['snapshot_files']:entry(d/'work'/e['path'],e)
 r=read(d/'receipt_rtl.json');log=d/'guard_rtl/driver.log';raw=log.read_text()
 assert sha(log)==r['driver_sha256'] and r['verdict']=='PASS' and r['guard_exit']==0 and r['guard']['child_exit_code']==0 and not r['guard']['trigger'] and not r['error_or_fatal'] and r['marker_found']
 assert not re.search(r'(?im)(?:^|\s)(?:FATAL|Fatal|ERROR)\s*[:\[]',raw)
 policy=read(d/'guard_rtl/policy_checks.json');assert policy and all(x['matches'] for x in policy)
 assert r['guard']['minimum_mem_available_kb']>192*1024*1024 and r['guard']['peak_owned_rss_kb']<8*1024*1024
 blocks=[metrics(x) for x in raw.splitlines() if x.startswith('M007_FULL_BLOCK_PASS ')]
 full=[metrics(x) for x in raw.splitlines() if x.startswith('M007_FULL_MATRIX_PASS ')]
 for x in full:
  assert len(blocks)==x['blocks'] and x['final_values']==128*x['N'] and x['matrix_cycles']<=CAP[x['case']] and x['peak_arithmetic']<=64 and x['peak_return']<=128
  assert x['first_output']<=({1024:1024,2624:2224,4096:3328}[x['K']]+x['K']+192)
  assert all(b['issue_span']==x['K'] and b['accept_to_last_output']<=x['K']+384 for b in blocks)
  assert len([s for s in raw.splitlines() if s.startswith('MATRIX_PROGRESS real_retired_s=')])==x['blocks']
  x['integer_MACs']=128*x['K']*x['N'];x['integer_MACs_per_prequantized_service_cycle']=x['integer_MACs']/x['matrix_cycles']
 return {'attempt':name,'core_revision':'prior_complete_N_AT012' if prior_core else 'current_cancel_cleanup_AT029','source_manifest':rel(d/'source_manifest.json'),'fixture_identity':rel(d/'fixture_identity.json'),'build':rel(build),'guard_log':rel(log),'receipt':rel(d/'receipt_rtl.json'),'command':rel(d/'command_rtl.json'),'policy':rel(d/'guard_rtl/policy_checks.json'),'wall_s':r['wall_s'],'peak_rss_kb':r['guard']['peak_owned_rss_kb'],'minimum_mem_available_kb':r['guard']['minimum_mem_available_kb'],'frozen_source_files':len(m['sources']),'fixture_files':len(fi['files']),'snapshot_files':len(fi['snapshot_files']),'full_metrics':full,'block_metrics':blocks,'markers':[s for s in raw.splitlines() if s.startswith(('M007_FULL_','HARDWARE_AGENT_SIM_PASS'))]}
def main():
 p=argparse.ArgumentParser();p.add_argument('--deferred',action='append',default=[]);a=p.parse_args()
 old=read(ATT/'AT012_semantic_directed_build/source_manifest.json');new=read(ATT/'AT029_cancel_completion_build/source_manifest.json');od,nd=dut(old),dut(new)
 assert set(od)==set(nd)
 changed=[k for k in od if od[k]['sha256']!=nd[k]['sha256']];assert changed==['laya_m007_matrix_superblock_v1.sv']
 previous=(ATT/'AT012_semantic_directed_build/frozen/laya_m007_matrix_superblock_v1.sv').read_text();current=(ATT/'AT029_cancel_completion_build/frozen/laya_m007_matrix_superblock_v1.sv').read_text()
 assert current.count(REPAIR)==1 and current.replace(REPAIR,'')==previous
 assert sha(Path(nd[changed[0]]['path']))==nd[changed[0]]['sha256']
 prior=[audit(n,True) for n in PRIOR];actual=[audit(n) for n in CURRENT];stress=audit('AT022_fc1_finite_stalls',True)
 assert {x['case'] for r in prior for x in r['full_metrics']}=={0,1,2,3}
 assert [x['case'] for r in actual for x in r['full_metrics']]==[1]
 text='\n'.join(s for r in actual for s in r['markers']);st='\n'.join(stress['markers'])
 assert all(x in text for x in ['M007_FULL_PREFETCH_ERROR_PASS actual_accepted_fault=1','M007_FULL_COMMON_RESET_PASS','M007_FULL_PREFIX_PASS case=6','M007_FULL_PREFIX_PASS case=7','M007_FULL_COEFFICIENT_IDENTITY_PASS'])
 sm=next(metrics(s) for s in stress['markers'] if s.startswith('M007_FULL_STRESS_PASS '));assert sm['merged_hold']>0 and sm['ctx_reuse_wait']>0 and sm['output_hold']>0
 assert any('peak_arithmetic=64' in s for s in stress['markers']) and 'M007_FULL_BIAS_OVERLAP_PASS' in st
 reset=next(metrics(s) for r in actual for s in r['markers'] if s.startswith('M007_FULL_COMMON_RESET_PASS '));assert reset['live_math']>0 and reset['live_A']>0 and reset['live_AXI']>0 and reset['stale_free_clocks']==12
 fault=next(metrics(s) for r in actual for s in r['markers'] if s.startswith('M007_FULL_PREFETCH_ERROR_PASS '));assert fault['actual_accepted_fault']==1 and fault['accepted_math']==fault['committed_math'] and fault['accepted_math']>0
 deferred=[]
 for n in a.deferred:
  d=ATT/n;r=read(d/'receipt_rtl.json');assert r['verdict']=='COST_STOP' and r['wall_s']==0 and not (d/'guard_rtl').exists();deferred.append({'attempt':n,'receipt':rel(d/'receipt_rtl.json'),'reason':r['reason'],'cost_gate':r['cost_gate']})
 inherited=[];conditional=[];r1build=ROOT/'project/E012_m007_matrix_compute/experiment_results/runs/R001/attempts/AT027_matrix_stall_watchdog_build';r1=dut(read(r1build/'source_manifest.json'))
 for name,e in nd.items():
  if name not in r1 or name==changed[0]:continue
  if e['sha256']==r1[name]['sha256']:inherited.append({'file':name,'sha256':e['sha256']});continue
  assert name=='laya_shared_fp256_v2.sv','unclassified changed component '+name
  prior_shared=(r1build/'frozen'/name).read_text();now_shared=(ATT/'AT029_cancel_completion_build/frozen'/name).read_text();before="bypass_enable(held_phase==3'd3)";after="bypass_enable(held_phase==3'd3||held_phase==3'd6)"
  assert prior_shared.count(before)==2 and prior_shared.replace(before,after)==now_shared
  assert ".lease_phase(3'd1)" in current
  conditional.append({'file':name,'R001_sha256':r1[name]['sha256'],'R002_sha256':e['sha256'],'exact_change':'Only two mul/add return-credit bypass enables extend phase3 to phase3||phase6; exact textual replacement verified','reuse_boundary':'Matrix uses phase1, where both enables remain false. Numeric leaves and credit module are byte-identical; R002 actual frozen shared wrapper is directly exercised in all full-N/current runs. No phase6 validation is claimed by E012.'})
 used={k:0. for k in ['reference','static','rtl','ooc']};attempts=[]
 for rp in sorted(ATT.glob('*/receipt_*.json')):
  r=read(rp);used[r['category']]+=r['wall_s'];d=rp.parent
  manifest=read(d/'source_manifest.json')
  for e in manifest['sources']:entry(d/'frozen'/e['frozen'],e)
  if 'driver_sha256' in r:
   gl=d/('guard_'+r['category'])/'driver.log';assert sha(gl)==r['driver_sha256'];assert read(d/('guard_'+r['category'])/'guard_result.json')==r['guard']
  attempts.append({'receipt':rel(rp),'verdict':r['verdict'],'category':r['category'],'wall_s':r['wall_s']})
 ledger=read(RUN/'budget_ledger.json');assert ledger['limits_s']=={'reference':900,'static':1800,'rtl':3600,'ooc':600}
 assert all(abs(used[k]-ledger['used_s'][k])<1e-6 and used[k]<=ledger['limits_s'][k] for k in used)
 out={'schema':2,'created_at':dt.datetime.now(dt.timezone.utc).isoformat(),'scope':'R002 FULLN-04 functional simulation and declared cost exit; full FC1/FC2 unverified','execution_state':'completed','verdict':'inconclusive','requested_model':'gpt-6.1-sol','requested_effort':'xhigh','actual_model':'UNKNOWN','actual_effort':'UNKNOWN','runtime_id':'/root/m007_weight_supply_engineering','audit_source':{'path':rel(Path(__file__)),'sha256':sha(Path(__file__))},'current_build':rel(ATT/'AT029_cancel_completion_build'),'prior_full_build':rel(ATT/'AT012_semantic_directed_build'),'version_boundary':{'only_RTL_change':changed[0],'old_sha256':od[changed[0]]['sha256'],'current_sha256':nd[changed[0]]['sha256'],'exact_added_text':REPAIR,'exact_single_addition_verified':True,'meaning':'Clear only inactive abort latch at real final release; cancel status preserved, no debt clear or earlier done. The four earlier complete-N measurements remain frozen prior-core evidence. Current complete WO and directed tests validate affected cleanup; they do not turn prior QKV/Wi/Down into newly executed current-core full-N tests. Stress prefix ends before matrix-wide final release, so its tested branch is unchanged.','testbench_boundary':'AT012/AT021/AT029 preserve exact TB/build/snapshot. Later TB adds true event logs and bounded recovery checks; changed A publication observation can shift AXI peer global phase and cold service. Do not attribute a cold-cycle difference to the abort repair.'},'prior_complete_N_runs':prior,'current_affected_runs':actual,'unchanged_prefix_stress':stress,'cost_deferred_no_tool_runs':deferred,'unchanged_R001_numeric_cache_shared_dependencies':inherited,'R001_component_version_boundaries':conditional,'inherited_R001_frozen_evidence':'project/E012_m007_matrix_compute/experiment_results/runs/R001/current_version_evidence.json','budget_used_s':used,'all_attempt_receipts':attempts,'unverified':['complete FC1/FC2 on any R002 revision','current-cleanup complete QKV/Wi/Down (prior frozen measurements preserved)','F32 quantizer/A joint matrix','global original matrix/parent first-error equivalence','physical HBM/CDC','whole-array synthesis, routed300MHz and joint resource budget','board or sustained end-to-end throughput']}
 (RUN/'current_version_evidence.json').write_text(json.dumps(out,indent=2)+'\n');print(json.dumps({'audit':'PASS_SCOPED_VERSIONED_COST_EXIT','prior_full_shapes':4,'current_full_shapes':1,'current_affected_runs':len(actual),'unique_hashed_files':len(cache),'used_s':used}))
if __name__=='__main__':main()
