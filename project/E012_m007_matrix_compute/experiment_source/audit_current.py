#!/usr/bin/env python3
"""Audit preserved E012 artifacts; performs no DUT execution or gold generation."""
import datetime as dt
import hashlib
import json
import re
from pathlib import Path

ROOT=Path(__file__).resolve().parents[3]
RUN=ROOT/'project/E012_m007_matrix_compute/experiment_results/runs/R001'
ATT=RUN/'attempts'
FINAL=[
 'AT021_matrix_finite_stalls',
 'AT022_matrix_common_reset_newgen',
 'AT023_matrix_error_newepoch_recovery',
 'AT024_current_down_superblock',
 'AT025_current_fc2_superblock',
 'AT028_current_fc2_finite_stalls',
]
REUSE=['AT003_exact_leaf_rtl','AT005_full256_dot_rtl','AT007_a_cache_rtl']

def sha(p):
 h=hashlib.sha256()
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1024*1024),b''):h.update(b)
 return h.hexdigest()

def read(p):return json.loads(p.read_text())
def rel(p):return str(p.relative_to(ROOT))
def check_entry(p,entry):
 assert p.is_file(),str(p)
 assert p.stat().st_size==entry['bytes'],str(p)
 assert sha(p)==entry['sha256'],str(p)

def audit(at,require_current):
 d=ATT/at;m=read(d/'source_manifest.json');sources=m['sources'];current=[]
 for e in sources:
  check_entry(d/'frozen'/e['frozen'],e)
  p=Path(e['path'])
  if require_current or (p.suffix=='.sv' and '/rtl/' in str(p)):
   if p.name=='m007_matrix_matrix_tb.sv' and sha(p)!=e['sha256']:
    # AT020 and AT027 differ only in the finite-stall TB watchdog, not DUT or gold checks.
    assert e['sha256']==sha(ATT/'AT020_matrix_final_coverage_build/frozen/m007_matrix_matrix_tb.sv')
   else:
    check_entry(p,e);current.append(rel(p))
 fi=read(d/'fixture_identity.json')
 for e in fi['files']:check_entry(Path(e['path']),e)
 for e in fi['snapshot_files']:check_entry(d/'work'/e['path'],e)
 build=Path(fi['build'])
 assert sha(build/'source_manifest.json')==fi['build_source_manifest_sha256']
 r=read(d/'receipt_rtl.json');log=d/'guard_rtl/driver.log';raw=log.read_text()
 assert sha(log)==r['driver_sha256']
 assert r['verdict']=='PASS' and r['guard_exit']==0 and r['guard']['child_exit_code']==0
 assert not r['error_or_fatal'] and r['marker_found'] and not r['guard']['trigger']
 assert not re.search(r'(?im)(?:^|\s)(?:FATAL|Fatal|ERROR)\s*[:\[]',raw)
 policy=read(d/'guard_rtl/policy_checks.json')
 assert policy and all(e['matches'] for e in policy)
 assert r['guard']['minimum_mem_available_kb']>192*1024*1024
 assert r['guard']['peak_owned_rss_kb']<8*1024*1024
 metrics=[]
 for line in raw.splitlines():
  if line.startswith('M007_MATRIX_SUPERBLOCK_PASS '):
   metrics.append({k:int(v) for k,v in re.findall(r'(\w+)=([0-9]+)',line)})
 return {'attempt':at,'source_manifest':rel(d/'source_manifest.json'),'fixture_identity':rel(d/'fixture_identity.json'),
  'command':rel(d/'command_rtl.json'),'guard_plan':rel(d/'guard_rtl/guard_plan.json'),
  'guard_log':rel(log),'receipt':rel(d/'receipt_rtl.json'),'policy':rel(d/'guard_rtl/policy_checks.json'),
  'frozen_sources_verified':len(sources),'current_sources_verified':len(current),'current_source_paths':current,
  'fixture_files_verified':len(fi['files']),'snapshot_files_verified':len(fi['snapshot_files']),
  'wall_s':r['wall_s'],'peak_rss_kb':r['guard']['peak_owned_rss_kb'],
  'minimum_mem_available_kb':r['guard']['minimum_mem_available_kb'],'superblock_metrics':metrics,
  'markers':[s for s in raw.splitlines() if s.startswith('M007_MATRIX_') or s.startswith('HARDWARE_AGENT_SIM_PASS')]}

def main():
 old=read(ATT/'AT020_matrix_final_coverage_build/source_manifest.json')
 new=read(ATT/'AT027_matrix_stall_watchdog_build/source_manifest.json')
 def dut(m):return {e['path']:e['sha256'] for e in m['sources'] if e['path'].endswith('.sv') and '/rtl/' in e['path']}
 assert dut(old)==dut(new)
 final=[audit(a,True) for a in FINAL]
 reused=[audit(a,False) for a in REUSE]
 assert all(x['superblock_metrics'] for x in final)
 for x in final:
  for v in x['superblock_metrics']:
   assert v['outputs']==8192 and v['max_dot_commit']<=64 and v['max_PS_feedback']<=24 and v['peak_reserved']<=128
   if not v['stress']:
    assert v['issue_span']==v['K'] and v['warm_last_output']<=v['K']+384 and v['done']<=v['K']+384 and v['output_bubbles']==0
 assert any('RESET_LIVE' in s and 'arithmetic=32' in s and 'A_debt=2' in s for s in final[1]['markers'])
 assert any('RESET_NEW_GENERATION_PASS' in s for s in final[1]['markers'])
 assert any('MIXED_PROTOCOL_NUMERIC_PASS' in s for s in final[2]['markers'])
 assert any('ERROR_RECOVERY_PASS' in s and 'generation=2 epoch=2' in s for s in final[2]['markers'])
 used={k:0.0 for k in ['reference','static','rtl','ooc']}
 receipts=[]
 for p in ATT.glob('*/receipt_*.json'):
  x=read(p);used[x['category']]+=x['wall_s'];receipts.append({'path':rel(p),'sha256':sha(p),'verdict':x['verdict'],'wall_s':x['wall_s']})
 ledger=read(RUN/'budget_ledger.json')
 assert all(abs(v-ledger['used_s'][k])<1e-6 and v<ledger['limits_s'][k] for k,v in used.items())
 fx=ATT/'AT010_local_model_superblocks/work/fixture/matrix_fixture_report.json'
 f=read(fx)
 result={'schema':1,'created_at':dt.datetime.now(dt.timezone.utc).isoformat(),
  'scope':'D-M007-SM010-MATRIX-02 autonomous prequantized A/W M128xN64 only',
  'execution_state':'completed','verdict':'supported','requested_model':'gpt-6.1-sol','requested_effort':'xhigh',
  'actual_model':'UNKNOWN','actual_effort':'UNKNOWN','runtime_id':'/root/m007_weight_supply_engineering',
  'audit_source':{'path':rel(Path(__file__).resolve()),'sha256':sha(Path(__file__))},
  'current_build':'project/E012_m007_matrix_compute/experiment_results/runs/R001/attempts/AT027_matrix_stall_watchdog_build',
  'testbench_version_boundary':'AT021-025 use frozen AT020 TB; AT028 uses AT027 TB. Only finite-stall functional watchdog and failure diagnostic changed; normal K+384 assertions and all independent numeric/identity checks unchanged. All DUT SV hashes match both builds/current source.',
  'current_final_runs':final,'unchanged_component_reuse':reused,
  'fixture_provenance':{'path':rel(fx),'sha256':sha(fx),'reference':f['reference'],'norm128':f['norm128'],
   'cases':[{k:c[k] for k in ['case','tensor','K','N','s','activation_classification','original_model_real_rows','legacy_gold_exact_rows']} for c in f['cases']]},
  'preserved_failures':[
   {'attempt':'AT017_matrix_error_drain','verdict':read(ATT/'AT017_matrix_error_drain/receipt_rtl.json')['verdict'],'repair':'Actual accepted W request tag retained; full echo validated, ret only after actual payload copy.'},
   {'attempt':'AT026_current_fc2_finite_stalls','verdict':read(ATT/'AT026_current_fc2_finite_stalls/receipt_rtl.json')['verdict'],'repair':'New TB functional watchdog K+1024 omitted fixed external-stall allowance; finite-stall watchdog corrected to2*K+1024. Tool120s budget and normal K+384 gate unchanged.'}],
  'local_ooc':[{'attempt':a,'receipt':read(ATT/a/'receipt_ooc.json')} for a in ['AT008_pair_scale_a_bank_ooc','AT009_a_bank_only_ooc']],
  'budget_ledger':{'path':rel(RUN/'budget_ledger.json'),'sha256':sha(RUN/'budget_ledger.json'),'recomputed_used_s':used,'recorded':ledger},
  'all_charged_receipts':receipts,
  'not_verified':['F32 activation quantizer integration','complete N/all120 matrices','parent Attention/phase arbitration','global original first error equivalence','real HBM/CDC','whole-array synthesis/resource fit','300MHz P&R timing','board/model throughput']}
 (RUN/'current_version_evidence.json').write_text(json.dumps(result,indent=2)+'\n')
 print('M007_MATRIX_CURRENT_EVIDENCE_PASS final_runs='+str(len(final))+' reused_components='+str(len(reused)))
 print(json.dumps({'used_s':used,'final_source_fixture_snapshot_counts':[(x['attempt'],x['frozen_sources_verified'],x['fixture_files_verified'],x['snapshot_files_verified']) for x in final]}))
if __name__=='__main__':main()
