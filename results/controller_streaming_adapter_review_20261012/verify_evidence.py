"""Read-only controller audit of streaming adapter handoff; no heavy tools."""
import hashlib
import json
import math
import re
import shutil
import xml.etree.ElementTree as ET
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).resolve().parent
BASE = ROOT/'project/E003_production_chain_closure/experiment_results/runs/R003'
MODULE = Path('vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512')
NAMES = ['controller_transaction_adapter_12','controller_transaction_adapter_hls_03','controller_transaction_adapter_rtl_01']
D = {'review_id':'R-SM003-CONTROLLER-STREAMING-ADAPTER-20261012',
     'checked_at':datetime.now(timezone.utc).isoformat(),'attempts':{},'snapshots':[]}
CACHE = {}

def sha(path):
    p=Path(path); st=p.stat(); key=(str(p),st.st_mtime_ns,st.st_size)
    if key not in CACHE:
        h=hashlib.sha256()
        with p.open('rb') as f:
            for part in iter(lambda:f.read(1024*1024),b''): h.update(part)
        CACHE[key]=h.hexdigest()
    return CACHE[key]

def refs(x,key=''):
    if isinstance(x,dict):
        if 'path' in x and 'sha256' in x: yield key,x
        for k,v in x.items():yield from refs(v,key+'/'+str(k))
    elif isinstance(x,list):
        for k,v in enumerate(x):yield from refs(v,key+'/'+str(k))

def snapshot(p):
    rel=p.relative_to(ROOT); dest=OUT/'snapshot'/rel
    dest.parent.mkdir(parents=True,exist_ok=True)
    if dest.exists():assert sha(dest)==sha(p)
    else:shutil.copyfile(p,dest)
    D['snapshots'].append({'source':str(rel),'path':str(dest.relative_to(ROOT)),'sha256':sha(dest)})

for name in NAMES:
    folder=BASE/name; m=json.loads((folder/'input_manifest.json').read_text()); r=json.loads((folder/'receipt.json').read_text())
    a={'manifest_sha256':sha(folder/'input_manifest.json'),'receipt_sha256':sha(folder/'receipt.json'),
       'pairs':[],'references':[],'stages':{}}
    for p in m['files']:
        x,y=p['original'],p['frozen']
        a['pairs'].append({'path':x['path'],'current_match':sha(x['path'])==x['sha256'],
            'frozen_match':sha(y['path'])==y['sha256'],'declared_pair_match':x['sha256']==y['sha256']})
    for label,obj in [('manifest',m),('receipt',r)]:
        for field,ref in refs(obj,label):
            actual=sha(ref['path']) if Path(ref['path']).is_file() else None
            a['references'].append({'field':field,'path':ref['path'],'expected':ref['sha256'],'actual':actual,'match':actual==ref['sha256']})
    for log in sorted(folder.glob('guard*/driver.log')):
        gdir=log.parent; plan=json.loads((gdir/'guard_plan.json').read_text()); guard=json.loads((gdir/'guard_result.json').read_text())
        policy=json.loads((gdir/'policy_checks.json').read_text()); stage=gdir.name.removeprefix('guard_')
        markers=r.get(stage,{}).get('marker',[])
        static=stage in ['guard','static']
        a['stages'][stage]={'plan':plan,'guard':guard,'policy_count':len(policy),
            'policy_all_match':bool(policy) and all(x['matches'] for x in policy),
            'markers':markers,'markers_in_log':all(x in log.read_text() for x in markers),
            'caps_ok':plan['maximum_owned_rss_kb']<=(24 if static else 8)*1024**2
                and plan['maximum_seconds']<=(1800 if static else 120)
                and plan['semantic_stall_seconds']==120 and plan['selected_cpu_ids']==[0,1,2,3]
                and plan['minimum_mem_available_kb']>=192*1024**2,
            'result_ok':guard['child_exit_code']==0 and guard['trigger'] is None
                and guard['elapsed_seconds']<=plan['maximum_seconds']
                and guard['peak_owned_rss_kb']<=plan['maximum_owned_rss_kb']}
        for fn in ['guard_result.json','guard_plan.json','policy_checks.json','driver.log']:snapshot(gdir/fn)
    commands=r.get('commands',[])
    a['host_commands']=[{'exit_code':c['exit_code'],'elapsed_seconds':c['elapsed_seconds'],'log':c['log']} for c in commands]
    a['markers_in_host_logs']=all(any(marker in Path(c['log']['path']).read_text() for c in commands) for marker in r.get('markers',[]))
    a['summary']={'pairs':len(a['pairs']),'current_matches':sum(x['current_match'] for x in a['pairs']),
       'frozen_matches':sum(x['frozen_match'] for x in a['pairs']),
       'declared_pair_matches':sum(x['declared_pair_match'] for x in a['pairs']),
       'references':len(a['references']),'reference_matches':sum(x['match'] for x in a['references'])}
    D['attempts'][name]=a
    snapshot(folder/'input_manifest.json');snapshot(folder/'receipt.json')
    for c in commands:snapshot(Path(c['log']['path']))

hls=BASE/NAMES[1]; rtl=BASE/NAMES[2]
top=hls/'laya_command_provenance_adapter.v'; text=top.read_text()
header=re.search(r'module\s+laya_command_provenance_adapter\s*\((.*?)\);',text,re.S).group(1)
ports=set(re.findall(r'\b[A-Za-z_]\w*\b',header)); expected={}
for name in ['transaction_request','compute_response','provenance_response','producer_completion']:
    expected.update({name+'_dout':('input',512),name+'_empty_n':('input',1),name+'_read':('output',1)})
for name in ['transaction_completion','compute_command','provenance_command','producer_request']:
    expected.update({name+'_din':('output',512),name+'_full_n':('input',1),name+'_write':('output',1)})
actual={n:(direction,int(msb)+1 if msb else 1) for direction,msb,n in re.findall(r'^(input|output)\s+(?:\[(\d+):0\]\s+)?(\w+)\s*;',text,re.M)}
D['independent_top_audit']={'ports':sorted(ports),'fifo_match':{n:n in ports and actual.get(n)==v for n,v in expected.items()},
    'controls_match':all(actual.get(n)==('input',1) for n in ['ap_clk','ap_rst','cancel']),
    'no_top_hs':not (ports & {'ap_start','ap_done','ap_idle','ap_ready'}),
    'internal_hs_present':all('.'+n+'(' in text for n in ['ap_start','ap_done','ap_idle','ap_ready']),
    'generated_top_sha256':sha(top),'original_receipt_status':json.loads((hls/'receipt.json').read_text())['status']}
report=hls/'work/hls/syn/report/laya_command_provenance_adapter_csynth.xml'
xt=ET.parse(report).getroot();D['hls_resource_estimates']={x.tag:int(x.text) for x in xt.find('AreaEstimates/Resources')}
D['generated_files']={'verilog':len(list((hls/'work/hls/syn/verilog').glob('*.v'))),'dat':len(list((hls/'work/hls/syn/verilog').glob('*.dat')))}
r=json.loads((rtl/'receipt.json').read_text());m=json.loads((rtl/'input_manifest.json').read_text());c=r['cost_decision']
D['cost_stop']={'decision':c,'manifest_receipt_equal':m['cost_decision']==c,
    'rate_match':c['current_cycles_per_second']==c['current_pilot_cycles']/c['current_pilot_seconds'],
    'reference_match':c['reference_full_cycles']==c['current_pilot_cycles']*8*3,
    'projection_match':c['projected_full_seconds']==math.ceil(c['reference_full_cycles']*1.5/c['current_cycles_per_second']),
    'padded_cycles':c['reference_full_cycles']*1.5,'cycle_cap_exceeded':c['reference_full_cycles']*1.5>c['maximum_cycles'],
    'full_not_started':r['full']=={'status':'COST_STOP','started':False} and not (rtl/'guard_full').exists()}
D['rom_staging']=[{'path':x['staged']['path'],'match':sha(x['source']['path'])==sha(x['staged']['path'])==x['source']['sha256']==x['staged']['sha256']} for x in r['rom_dat_staging']]
D['extra_reference_audit']={}
for fn in ['controller_adapter_hls_03_port_verification_20261012.json','controller_streaming_adapter_verification_20261012.json']:
    p=BASE/fn; obj=json.loads(p.read_text());rr=[]
    for key,x in refs(obj):rr.append({'field':key,'path':x['path'],'match':sha(x['path'])==x['sha256']})
    D['extra_reference_audit'][fn]={'sha256':sha(p),'references':rr};snapshot(p)
expected_hashes={
NAMES[0]:['7b43128bfd4e76cb599bb1638cdf43ca717210659a54604130460dce9e4ece31','730763ba65e4882360b7cd9c629ab264bf5b373c714f4c16aadfa8c5a0339be7'],
NAMES[1]:['b730243127cd828e099d1f8e2196e43f80b121f602063c99cadc2dd67350f2a6','661589aded6a147e4f940f4d0532c86295fc37562c3e6bcb98e32da01070472b'],
NAMES[2]:['530d94d615bdd53b3b6704206572303188760e33e545dc37be88ab5e32a7afd5','0fb9400ef49251987df38e79d318f0be815f66024802e338688223a7fda7c0a1']}
D['handoff_hash_checks']=[D['attempts'][n][k]==v for n,h in expected_hashes.items() for k,v in zip(['manifest_sha256','receipt_sha256'],h)]
D['handoff_hash_checks'] += [sha(BASE/fn)==v for fn,v in [
    ('controller_adapter_hls_03_port_verification_20261012.json','042dada160a8f11aa97b29994dd18a71eff8d6e426724755b73d7d16b97e37fd'),
    ('controller_streaming_adapter_verification_20261012.json','57de57b2af3ddbeac6a3ea2a2730e304ea992ffdcb18b289c450a3c6f3c05707')]]
for p in [top,report,report.with_suffix('.rpt'),hls/'frozen/hls/platform/controller_transaction_adapter.cpp',
    hls/'frozen/include/laya_controller_request_mapping.h',rtl/'frozen'/MODULE/'tb/laya_controller_transaction_adapter_tb_v1.sv',
    rtl/'frozen'/MODULE/'rtl/laya_private_fifo2_v1.sv',rtl/'frozen'/MODULE/'tb/run_controller_transaction_adapter_rtl.py',
    BASE/NAMES[0]/'frozen/tests/controller_transaction_adapter_test.cpp',
    ROOT/'project/E002_Laya_HLS/experiment/config/production_hls_partitions.json']:
    snapshot(p)
for fn in ['results/overview.md','results/reviews/SM003.md','results/review_queue.md','mission/current.md',
    'results/production_hls_partition_contract_20261012.md','agent/A001/result.md','agent/A001/state.json','agent/A001/status.md','agent/A002/state.json',
    'project/E003_production_chain_closure/experiment_source/summary.md','project/E003_production_chain_closure/experiment_results/summary.md','project/E003_production_chain_closure/experiment_status/summary.md']:
    snapshot(ROOT/fn)
D['total']={k:sum(a['summary'][k] for a in D['attempts'].values()) for k in D['attempts'][NAMES[0]]['summary']}
(OUT/'verification.json').write_text(json.dumps(D,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({'total':D['total'],'attempts':{n:a['summary'] for n,a in D['attempts'].items()},
    'mismatches':[x for a in D['attempts'].values() for x in a['references'] if not x['match']],
    'guard_checks':{n:{k:{f:v[f] for f in ['policy_all_match','markers_in_log','caps_ok','result_ok']} for k,v in a['stages'].items()} for n,a in D['attempts'].items()},
    'port':D['independent_top_audit'],'resources':D['hls_resource_estimates'],'generated':D['generated_files'],
    'cost_stop':D['cost_stop'],'hashes':D['handoff_hash_checks'],'roms_match':all(x['match'] for x in D['rom_staging'])},ensure_ascii=False))
