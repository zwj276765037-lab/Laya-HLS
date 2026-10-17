"""Read-only controller F10 audit; no simulation, compilation or synthesis."""
import hashlib
import json
import re
import shutil
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).resolve().parent
BASE = ROOT/'project/E003_production_chain_closure/experiment_results/runs/R003'
ATT = BASE/'controller_transaction_adapter_rtl_03'
MODULE = Path('vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512')
D = {'review_id':'R-SM003-CONTROLLER-TRANSACTION-ADAPTER-F10-20261012',
     'checked_at':datetime.now(timezone.utc).isoformat(),'pairs':[],'references':[],
     'stages':{},'snapshots':[]}

def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def refs(x,key=''):
    if isinstance(x,dict):
        if 'path' in x and 'sha256' in x:yield key,x
        for k,v in x.items():yield from refs(v,key+'/'+str(k))
    elif isinstance(x,list):
        for k,v in enumerate(x):yield from refs(v,key+'/'+str(k))
def snapshot(p):
    rel=p.relative_to(ROOT);dest=OUT/'snapshot'/rel
    assert not dest.exists(),dest
    dest.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,dest)
    D['snapshots'].append({'source':str(rel),'path':str(dest.relative_to(ROOT)),'sha256':sha(dest)})

m=json.loads((ATT/'input_manifest.json').read_text());r=json.loads((ATT/'receipt.json').read_text())
for x in m['files']:
    a,b=x['original'],x['frozen']
    D['pairs'].append({'path':a['path'],'current_match':sha(a['path'])==a['sha256'],
        'frozen_match':sha(b['path'])==b['sha256'],'declared_pair_match':a['sha256']==b['sha256']})
for label,obj in [('manifest',m),('receipt',r)]:
    for key,x in refs(obj,label):
        actual=sha(x['path']) if Path(x['path']).is_file() else None
        D['references'].append({'field':key,'path':x['path'],'expected':x['sha256'],'actual':actual,'match':actual==x['sha256']})
prev_finished=None
for name in ['static']+['case_'+c for c in m['case_order']]:
    folder=ATT/('guard_'+name)
    plan=json.loads((folder/'guard_plan.json').read_text());g=json.loads((folder/'guard_result.json').read_text())
    policy=json.loads((folder/'policy_checks.json').read_text());log=(folder/'driver.log').read_text()
    rr=r['static'] if name=='static' else r['cases'][name[5:]]
    cycles=None if name=='static' else int(re.search(r'cycles=(\d+)',rr['marker'][0]).group(1))
    static=name=='static'
    D['stages'][name]={'plan':plan,'guard':g,'cycles':cycles,'markers':rr['marker'],
        'markers_in_raw_log':all(s in log for s in rr['marker']),
        'tail_checks_in_marker':static or all(s in rr['marker'][0] for s in ['completion_tail14_stall=1','completion_tail15_stall=1']),
        'policy_samples':len(policy),'all_policy_match':bool(policy) and all(x['matches'] for x in policy),
        'caps_ok':plan['maximum_seconds']==(1800 if static else 120)
            and plan['maximum_owned_rss_kb']==(24 if static else 8)*1024**2
            and plan['semantic_stall_seconds']==120 and plan['selected_cpu_ids']==[0,1,2,3]
            and plan['minimum_mem_available_kb']>=192*1024**2,
        'result_ok':rr['status']=='PASS' and rr['exit_code']==0 and g['child_exit_code']==0 and g['trigger'] is None
            and g['elapsed_seconds']<=plan['maximum_seconds'] and g['peak_owned_rss_kb']<=plan['maximum_owned_rss_kb']
            and g['minimum_mem_available_kb']>=plan['minimum_mem_available_kb']
            and (static or cycles<m['maximum_cycles_per_case']),
        'after_previous_finished':prev_finished is None or plan['at']>=prev_finished}
    prev_finished=g['finished_at']
    for fn in ['guard_result.json','guard_plan.json','policy_checks.json','driver.log']:snapshot(folder/fn)
D['launcher']=json.loads((ATT/'launcher.json').read_text())
D['rom_staging']=[{'path':x['staged']['path'],'match':sha(x['source']['path'])==sha(x['staged']['path'])==x['source']['sha256']==x['staged']['sha256']} for x in r['rom_dat_staging']]
engine=ATT/'frozen/external/adapter_rtl'
D['reused_generation']={'verilog_count':len(list(engine.glob('*.v'))),'dat_count':len(list(engine.glob('*.dat'))),
    'top_matches_hls_03':sha(engine/'laya_command_provenance_adapter.v')==sha(BASE/'controller_transaction_adapter_hls_03/laya_command_provenance_adapter.v')}
old=json.loads((BASE/'controller_transaction_adapter_rtl_01/input_manifest.json').read_text())
# The path after /frozen/ is a stable label even for generated file pairs.
before={x['frozen']['path'].split('/frozen/',1)[1]:x['frozen']['sha256'] for x in old['files']}
after={x['frozen']['path'].split('/frozen/',1)[1]:x['frozen']['sha256'] for x in m['files']}
D['delta_rtl01_to_03']={'common':len(before.keys() & after.keys()),
    'added':sorted(after.keys()-before.keys()),'changed':sorted(k for k in before.keys() & after.keys() if before[k]!=after[k])}
pre=BASE/'controller_transaction_adapter_rtl_02'
D['preflight_02']={'launcher':json.loads((pre/'launcher.json').read_text()),
                  'files':sorted(p.name for p in pre.iterdir()),'no_tool_directory':not any(p.is_dir() for p in pre.iterdir())}
registry=ROOT/'project/E002_Laya_HLS/experiment/config/production_hls_partitions.json'
D['catalog']={'current_sha256':sha(registry),'expected_match':sha(registry)=='69bbb69d8718214dc1132b95575a1d05e7faf9bec9a8e4be3ec483ac1b505fd6',
    'in_attempt':any(x['original']['path']==str(registry) for x in m['files'])}
D['scope']={'status':r['status'],'case_order':m['case_order'],'cost_decision':r['cost_decision'],
    'manifest_receipt_cost_equal':m['cost_decision']==r['cost_decision'],
    'no_full_run':not (ATT/'guard_full').exists(),'fixture_build_run_exit0':m['fixture_build']['exit_code']==m['fixture_run']['exit_code']==0,
    'rtl01_full_still_cost_stop':json.loads((BASE/'controller_transaction_adapter_rtl_01/receipt.json').read_text())['full'],
    'hls03_receipt_still_fail':json.loads((BASE/'controller_transaction_adapter_hls_03/receipt.json').read_text())['status']}
hashes={ATT/'input_manifest.json':'1e0a3baa17545ddd86bcb999d6175a423540c57cea8a64a862eafafd62406d32',
    ATT/'receipt.json':'7a0281acdf386f8ec8ff499f64308c4a196cb53492c0a3bd8ef73b62712bc096',
    BASE/'controller_transaction_adapter_f10_verification_20261012.json':'05a22919e8f7e46fc695fcee36324f83cbd313df1ba609a8bc69ad00eeb2ab8d',
    pre/'launcher.json':'a1c0cff78e1fbbc4caca6a96dab54d4c94d20d934660fb0352f493c4534512bf',
    BASE/'controller_transaction_adapter_f10_catalog_verification_20261012.json':'968ee114332370d5dc499235ca6eb6100499f11d54a3af6ce08dfcd76b2bc34e'}
D['handoff_hash_checks']=[{'path':str(p.relative_to(ROOT)),'match':sha(p)==h} for p,h in hashes.items()]
for p in list(hashes)+[ATT/'launcher.json',registry,
    ATT/'frozen'/MODULE/'rtl/laya_controller_transaction_adapter_shell_v1.sv',
    ATT/'frozen'/MODULE/'tb/laya_controller_transaction_adapter_tb_v1.sv',
    ATT/'frozen'/MODULE/'tb/run_controller_transaction_adapter_rtl.py',
    ATT/'frozen'/MODULE/'tb/run_controller_transaction_adapter_rtl_v1.tcl',
    ATT/'frozen/tests/controller_transaction_adapter_rtl_fixture.cpp']:
    snapshot(p)
for n in ['results/overview.md','results/reviews/SM003.md','results/review_queue.md','mission/current.md',
    'agent/A001/result.md','agent/A001/status.md','agent/A001/state.json','agent/A002/state.json',
    'project/E003_production_chain_closure/experiment_source/summary.md',
    'project/E003_production_chain_closure/experiment_results/summary.md',
    'project/E003_production_chain_closure/experiment_status/summary.md']:snapshot(ROOT/n)
D['summary']={'pairs':len(D['pairs']),'current_matches':sum(x['current_match'] for x in D['pairs']),
    'frozen_matches':sum(x['frozen_match'] for x in D['pairs']),'declared_pair_matches':sum(x['declared_pair_match'] for x in D['pairs']),
    'references':len(D['references']),'reference_matches':sum(x['match'] for x in D['references']),
    'receipt_references':sum(x['field'].startswith('receipt/') for x in D['references'])}
(OUT/'verification.json').write_text(json.dumps(D,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({'summary':D['summary'],'mismatches':[x for x in D['references'] if not x['match']],
    'guards':{n:{k:s[k] for k in ['cycles','all_policy_match','caps_ok','result_ok','markers_in_raw_log','tail_checks_in_marker','after_previous_finished']} for n,s in D['stages'].items()},
    'hashes':D['handoff_hash_checks'],'generation':D['reused_generation'],'catalog':D['catalog'],
    'rom_all_match':all(x['match'] for x in D['rom_staging']),'delta':D['delta_rtl01_to_03'],'scope':D['scope'],
    'preflight_only_launcher':D['preflight_02']['files']==['launcher.json']},ensure_ascii=False))
