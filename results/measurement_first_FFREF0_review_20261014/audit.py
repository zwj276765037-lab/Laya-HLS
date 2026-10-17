"""Controller audit of AT050 bytes/identity/guard; no reference or DUT run."""
from pathlib import Path
from datetime import datetime, timezone
import hashlib,json,shutil,struct

ROOT=Path(__file__).resolve().parents[2];OUT=Path(__file__).resolve().parent
RUN=ROOT/'project/E005_full_request_performance/experiment_results/runs/R001'
P=RUN/'attempts/AT050_FFREF0_reference_01'
for name in ['mission/current.md','results/overview.md','results/hardware_metrics.md','results/hardware_progress.md',
             'results/review_queue.md','results/reviews/SM005.md','project/missions/SM005.md','agent/A001/result.md',
             'agent/A001/state.json','NEW_CHAT_START.md']:
    dst=OUT/'prior_records'/name;dst.parent.mkdir(parents=True,exist_ok=True)
    if not dst.exists():shutil.copy2(ROOT/name,dst)
cache={};checks=[]
def ident(path):
    p=Path(path)
    if not p.is_absolute():p=ROOT/p
    if str(p) not in cache:
        h=hashlib.sha256();n=0
        with p.open('rb') as f:
            while b:=f.read(4*1024**2):h.update(b);n+=len(b)
        cache[str(p)]=dict(path=str(p),bytes=n,sha256=h.hexdigest())
    return cache[str(p)]
def refs(obj,origin):
    if isinstance(obj,dict):
        if {'path','bytes','sha256'}<=obj.keys():
            a=ident(obj['path']);ok=all(a[k]==obj[k] for k in ['bytes','sha256'])
            checks.append(dict(origin=origin,expected=obj,actual=a,match=ok));assert ok,origin
        else:
            for k,v in obj.items():
                if k.startswith('/') and isinstance(v,dict) and {'bytes','sha256'}<=v.keys() and '::' not in k:
                    refs(dict(v,path=k),origin+'/'+k)
                else:refs(v,origin+'/'+k)
    elif isinstance(obj,list):
        for i,v in enumerate(obj):refs(v,origin+'/'+str(i))
def j(path):return json.loads(Path(path).read_text())
manifest=j(P/'source_manifest.json');report=j(P/'output/ffn_residual_reference_report.json');receipt=j(P/'receipt.json')
refs(manifest,'manifest');refs(report,'report')
assert len(manifest['files'])==19 and len({x['path'] for x in manifest['files']})==19
assert receipt['status']=='PASS_SCOPED_HOST_REFERENCE'
assert report['status']=='PASS_EXACT_INDEPENDENT_FFN_REFERENCE'
for k,v in receipt.items():
    if isinstance(v,str) and v.startswith('/'):ident(v)
for n in ['preparation_note.json','runner.diff','guard/driver.log','guard/guard_plan.json','guard/guard_result.json','guard/policy_checks.json']:
    ident(P/n)
plan=j(P/'guard/guard_plan.json');guard=j(P/'guard/guard_result.json');policy=j(P/'guard/policy_checks.json')
assert plan['maximum_seconds']==120 and plan['maximum_owned_rss_kb']==8*1024**2
assert plan['minimum_mem_available_kb']==192*1024**2 and plan['semantic_stall_seconds']==120
assert plan['selected_cpu_ids']==[0,1,2,3] and guard['child_exit_code']==0 and guard['trigger'] is None
assert guard['elapsed_seconds']<120 and guard['minimum_mem_available_kb']>192*1024**2
assert guard['peak_owned_rss_kb']<8*1024**2
assert len(policy)==1 and all(x['matches'] and x['affinity']==[0,1,2,3] and x['nice']==19 and x['ionice']=='idle' and x['ionice_exit']==0 for x in policy)
assert datetime.fromisoformat(manifest['created_utc'])<datetime.fromisoformat(plan['at'])
assert '/usr/bin/python3' in plan['command'] and 'ffn_residual_reference_prefix.py' in ' '.join(plan['command'])
assert (P/'guard/driver.log').read_text().strip()=='FFREF0_RESULT PASS_EXACT_INDEPENDENT_FFN_REFERENCE down_diff 0 enc0_diff 0'

frame=Path(report['abi_request']['path']).read_bytes()
assert len(frame)==1152 and frame[:4]==b'LYRQ' and struct.unpack_from('<HHQQ',frame,20)==(1,128,3,1)
for i,entry in enumerate(report['abi_inputs']):
    off,length=struct.unpack_from('<II',frame,128+i*32+4)
    assert Path(entry['path']).read_bytes()==frame[off:off+length]
for i,k in enumerate(['model','numeric','layout','build']):assert frame[40+i*16:56+i*16].hex()==report['abi_package_tags'][k]
assert report['reference']['sha256']==report['imported_reference']['sha256']=='fe9678e44030ef4c5b46b02e907caf2022c97ecfaa612c2eb377a4fbbf2e9784'

out=report['outputs'];obs=report['observations'];comp={}
def compare(name,a,b):
    assert len(a)==len(b) and len(a)%4==0
    different=sum(a[i:i+4]!=b[i:i+4] for i in range(0,len(a),4))
    expected=report['comparisons'][name]
    assert different==expected['bit_diff_count']==0 and len(a)//4==expected['elements']
    comp[name]=dict(elements=len(a)//4,bit_pattern_differences=different)
def data(entry):return Path(entry['path']).read_bytes()
for name in ['skip','ln_ffn','down','enc0_out']:
    full=data(out[name]['full128']);four=data(out[name]['rows4'])
    assert len(full)==524288 and len(four)==16384 and full[:16384]==four
    assert all((x[0]&0x7f800000)!=0x7f800000 for x in struct.iter_unpack('<I',full))
for name,prefix in [('skip','skip'),('ln_ffn','ln')]:
    compare(prefix+'_full_vs_AT038',data(out[name]['full128']),data(obs['AT038_'+prefix+'_full']))
    compare(prefix+'_rows4_vs_AT038',data(out[name]['rows4']),data(obs['AT038_'+prefix+'_rows4']))
words=Path(obs['AT049_down_mem']['path']).read_text().splitlines()
assert len(words)==4096
decoded=b''.join(int(x,16).to_bytes(4,'little') for x in words)
compare('down_rows4_vs_AT049_mem',data(out['down']['rows4']),decoded)
compare('down_rows4_vs_independent_binary',data(out['down']['rows4']),data(obs['Down_independent_binary']))
compare('enc0_full_vs_independent_oracle',data(out['enc0_out']['full128']),data(obs['original_encoder_00_out']))
compare('enc0_rows4_vs_oracle_prefix',data(out['enc0_out']['rows4']),data(obs['original_encoder_00_out'])[:16384])
at49=j(obs['AT049_manifest']['path'])
assert any(x['path']==obs['AT049_down_mem']['path'] and x['sha256']==obs['AT049_down_mem']['sha256'] for x in at49['files'])
oracle=j(obs['original_oracle_report']['path'])
old=next(x for x in oracle['runs']['B1_from_b0_S128']['checkpoints'] if x['name']=='encoder_00_out')
assert old['bytes']==out['enc0_out']['full128']['bytes'] and old['sha256']==out['enc0_out']['full128']['sha256']
weight_checks=[]
for name,x in report['weights'].items():
    path,name=name.split('::')
    with Path(path).open('rb') as f:f.seek(x['absolute_file_offset']);b=f.read(x['bytes'])
    assert len(b)==x['bytes'] and hashlib.sha256(b).hexdigest()==x['sha256']
    weight_checks.append(dict(name=name,bytes=len(b),sha256=x['sha256'],match=True))
assert len(weight_checks)==10
source=Path(report['runner']['path']).read_text()
assert source.index('ref.full_forward_graph(*inputs, weight, checkpoint)')<source.index('old_skip_full =')
assert 'result = original_add(lhs, rhs)' in source and 'result = original_ln(values, gamma)' in source
assert 'graph_add_lines == [770, 777]' in source and 'except PrefixComplete:' in source
assert 'ref.add = original_add' in source and 'ref.layernorm_many = original_ln' in source

# Observe exact AT049 IP identity separately from engineering's nominated XCI.
xci=RUN/'attempts/AT049_LNQ2_runtime_01/work_static/vivado/lnq0_chain_tb_v1.srcs/sources_1/ip/tm1tn8_fadd_ip/tm1tn8_fadd_ip.xci'
ip=j(xci);params=ip['ip_inst']['parameters']['component_parameters']
def pv(k):return params[k][0]['value']
important={k:pv(k) for k in ['Operation_Type','Add_Sub_Value','A_Precision_Type','Result_Precision_Type','C_Latency','C_Rate','Flow_Control','Has_RESULT_TREADY','Has_ACLKEN','Has_ARESETn']}
assert important==dict(Operation_Type='Add_Subtract',Add_Sub_Value='Add',A_Precision_Type='Single',Result_Precision_Type='Single',C_Latency='11',C_Rate='1',Flow_Control='NonBlocking',Has_RESULT_TREADY='false',Has_ACLKEN='true',Has_ARESETn='true')
ipid=ident(xci)
result=dict(at=datetime.now(timezone.utc).isoformat(),scope='Controller bytes/source/guard audit only; no reference or DUT execution',
 references=checks,reference_count=len(checks),unique_hashed_paths=len(cache),all_references_match=True,
 manifest_entries=19,outputs=out,comparisons=comp,weight_segments=weight_checks,
 original_reference_SHA=report['reference']['sha256'],guard=guard,plan=plan,policy_samples=1,
 graph_observation='Original LN/add executed first; captures copied from real graph; old artifacts read only after prefix completes',
 preparation='One pre-run copy-path omission preserved; one guarded host run',
 AT049_fadd=dict(identity=ipid,configuration=important),
 nominee_XCI='See arithmetic_route_verification.json for resolved exact paths and configuration differences; distinct file identities retained',
 verdict='PASS_SCOPED_HOST_REFERENCE; residual RTL NOT_RUN; M003/M004 open')
(OUT/'verification.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({k:result[k] for k in ['reference_count','unique_hashed_paths','manifest_entries','policy_samples','verdict']},ensure_ascii=False))
