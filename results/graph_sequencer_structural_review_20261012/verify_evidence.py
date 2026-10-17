"""Read-only audit before the controller structure decision; no heavy tools."""
import hashlib
import json
import re
import shutil
from datetime import datetime, timezone
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
OUT=Path(__file__).resolve().parent
BASE=ROOT/'project/E003_production_chain_closure/experiment_results/runs/R003'
ATT=BASE/'graph_sequencer_hls_01'
D={'review_id':'R-SM003-GRAPH-SEQUENCER-STRUCTURAL-20261012',
   'checked_at':datetime.now(timezone.utc).isoformat(),'pairs':[],'references':[],'snapshots':[]}

def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def refs(x,key=''):
    if isinstance(x,dict):
        if 'path' in x and 'sha256' in x:yield key,x
        for k,v in x.items():yield from refs(v,key+'/'+str(k))
    elif isinstance(x,list):
        for k,v in enumerate(x):yield from refs(v,key+'/'+str(k))
def snapshot(p):
    rel=p.relative_to(ROOT);dst=OUT/'snapshot'/rel
    assert not dst.exists(),dst
    dst.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,dst)
    D['snapshots'].append({'source':str(rel),'path':str(dst.relative_to(ROOT)),'sha256':sha(dst)})

m=json.loads((ATT/'input_manifest.json').read_text());r=json.loads((ATT/'receipt.json').read_text())
for x in m['files']:
    a,b=x['original'],x['frozen']
    D['pairs'].append({'path':a['path'],'current_match':sha(a['path'])==a['sha256'],
        'frozen_match':sha(b['path'])==b['sha256'],'declared_pair_match':a['sha256']==b['sha256']})
for label,obj in [('manifest',m),('receipt',r)]:
    for key,x in refs(obj,label):
        actual=sha(x['path']) if Path(x['path']).is_file() else None
        D['references'].append({'field':key,'path':x['path'],'expected':x['sha256'],'actual':actual,'match':actual==x['sha256']})
g=json.loads((ATT/'guard/guard_result.json').read_text());plan=json.loads((ATT/'guard/guard_plan.json').read_text())
policy=json.loads((ATT/'guard/policy_checks.json').read_text())
timeline=[json.loads(x) for x in (ATT/'guard/semantic_timeline.jsonl').read_text().splitlines()]
log=(ATT/'guard/driver.log').read_text();last=timeline[-1]
report=ATT/'work/hls/syn/report/csynth_design_size.rpt';size=report.read_text()
D['guard']={'result':g,'plan':plan,'policy_count':len(policy),'all_policy_match':all(x['matches'] for x in policy),
    'caps':plan['maximum_seconds']==1800 and plan['maximum_owned_rss_kb']==24*1024**2
       and plan['semantic_stall_seconds']==120 and plan['minimum_mem_available_kb']>=192*1024**2
       and plan['selected_cpu_ids']==[0,1,2,3],
    'under_rss_wall_caps':g['elapsed_seconds']<1800 and g['peak_owned_rss_kb']<24*1024**2,
    'final_timeline':last,'final_progress_age_estimate_seconds':g['elapsed_seconds']-(last['elapsed_seconds']-last['seconds_since_progress']),
    'last_two_same_artifact_highwater':timeline[-2]['artifact_highwater']==last['artifact_highwater'],
    'synthesizability_0_error':'0 error(s)' in log,'loop_optimization_lines':[l for l in log.splitlines() if 'Loop' in l and ('optimization' in l.lower() or 'function' in l.lower())][-3:]}
D['host']={name:{'exit_code':r[name]['exit_code'],'log':r[name]['log'],
    'text':Path(r[name]['log']['path']).read_text() if name=='host_run' else None} for name in ['host_build','host_run']}
D['generation']={'receipt_status':r['status'],'runner_exit_code':r['exit_code'],
    'candidates':r['generated_candidates'],'port_evidence':r['port_evidence'],
    'actual_top_paths':[str(p.relative_to(ROOT)) for p in (ATT/'work').glob('**/syn/verilog/laya_typed_q8_forward_graph_sequencer.v')],
    'partial_file_count':len(r['partial_work_files']),'source_count':m['source_count'],'forbidden_sources':m['forbidden_sources']}
D['size']={'summary_lines':size.splitlines()[:34],
    'graph_action_lines':[l for l in size.splitlines() if 'graph_partitioned' in l or 'execute_graph_action' in l],
    'action_to_graph_compile_link_ratio':2144057/2145023,
    'compile_link':2223180,'hw_transforms':1122623,
    'interpretation':'inclusive compile sizes; removing PC alone does not demonstrate a smaller action executor or hardware performance'}
expected={ATT/'receipt.json':'fa1e3f7446a82ff0c36d6d23b8c5fa373ac4fa9cd20e9716a13b6e95041354da',
    ATT/'input_manifest.json':'528f2f1e62c00bc423f9c7c8fd16fa3879451ba6a9a1d5506bb4baca666db899',
    ATT/'guard/guard_result.json':'18a9fb74d169fe07fc13e8623083db07b63be77cac1bed624a55bc4cbd91cadb',
    report:'3f43a7d35d8de0b688777a6881f0ab34170415d3871ba3546465032992909c3c'}
D['handoff_hash_checks']=[{'path':str(p.relative_to(ROOT)),'match':sha(p)==h} for p,h in expected.items()]
for p in list(expected)+[ATT/'guard/guard_plan.json',ATT/'guard/policy_checks.json',ATT/'guard/driver.log',
    ATT/'guard/semantic_timeline.jsonl',ATT/'host_run.log',ATT/'launcher.json',ATT/'graph_sequencer.cfg',
    ATT/'frozen/hls/control/full_forward_controller.cpp',ATT/'frozen/include/laya_full_runtime.h',
    ATT/'frozen/config/graph_sequencer_sources.cmake',ATT/'frozen/config/production_hls_partitions.json']:
    snapshot(p)
for n in ['results/production_hls_partition_contract_20261012.md','results/overview.md','results/reviews/SM003.md',
    'results/review_queue.md','mission/current.md','agent/A001/result.md','agent/A001/state.json','agent/A001/status.md',
    'agent/A002/state.json','project/E003_production_chain_closure/experiment_source/summary.md',
    'project/E003_production_chain_closure/experiment_results/summary.md','project/E003_production_chain_closure/experiment_status/summary.md']:
    snapshot(ROOT/n)
D['summary']={'pairs':len(D['pairs']),'current_matches':sum(x['current_match'] for x in D['pairs']),
    'frozen_matches':sum(x['frozen_match'] for x in D['pairs']),'declared_pair_matches':sum(x['declared_pair_match'] for x in D['pairs']),
    'references':len(D['references']),'reference_matches':sum(x['match'] for x in D['references'])}
(OUT/'verification.json').write_text(json.dumps(D,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({'summary':D['summary'],'mismatches':[x for x in D['references'] if not x['match']],
    'hashes':D['handoff_hash_checks'],'generation':D['generation'],
    'policy':D['guard']['all_policy_match'],'caps':D['guard']['caps'],
    'stop_seconds_since_progress_estimate':D['guard']['final_progress_age_estimate_seconds'],
    'loop_optimization':D['guard']['loop_optimization_lines'],
    'action_to_graph_ratio':D['size']['action_to_graph_compile_link_ratio'],'host':D['host']},ensure_ascii=False))
