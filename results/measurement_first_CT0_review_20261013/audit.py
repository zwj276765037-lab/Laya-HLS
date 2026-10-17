from pathlib import Path
from datetime import datetime, timezone
import hashlib, json, re
R=Path(__file__).resolve().parents[2];D=Path(__file__).resolve().parent
B=R/'project/E005_full_request_performance/experiment_results/runs/R001'
H=B/'attempts/AT006_CT0_owner_table_hls_03';T=B/'attempts/AT012_CT0_owner_table_rtl_06'
def get(p):return json.loads(p.read_text())
def sha(p):
    with p.open('rb') as f:return hashlib.file_digest(f,'sha256').hexdigest()
verified={}
def check(x):
    p=Path(x['path']);p=p if p.is_absolute() else R/p
    assert p.is_file() and sha(p)==x['sha256'],str(p)
    if 'bytes' in x:assert p.stat().st_size==x['bytes'],str(p)
    verified[str(p)]={'sha256':sha(p),'bytes':p.stat().st_size};return p
def refs(x):
    if isinstance(x,dict):
        if {'path','sha256'}<=x.keys():check(x)
        else:
            for k,v in x.items():
                if k not in ['original','design','contract']:refs(v)
    elif isinstance(x,list):
        for v in x:refs(v)
h,t=get(H/'receipt.json'),get(T/'receipt.json');hm,tm=get(H/'input_manifest.json'),get(T/'input_manifest.json')
assert h['status']=='PASS_SCOPED_GENERATION' and t['status']=='PASS_SCOPED_RTL'
for x in [h,t,hm,tm]:refs(x)
assert len(hm['sources'])==19 and len(tm['frozen_files'])==39
gen=H/'work/hls/syn/verilog';generated=[]
for x in tm['frozen_files']:
    p=Path(x['path'])
    if p.parent.name=='generated':
        assert sha(gen/p.name)==x['sha256'],p.name
        generated.append(p.name)
for p in gen.glob('*'):
    if p.suffix in ['.v','.dat']:assert p.name in generated,p.name
top=(gen/'laya_owner_ct0.v').read_text();memory=(gen/'laya_owner_ct0_table_r_RAM_1P_BRAM_1R1W.v').read_text()
for p in ['request_dout','response_din']:assert re.search(r'\[511:0\]\s+'+p+r'\b',top)
for p in ['request_empty_n','request_read','response_full_n','response_write','ap_clk','ap_rst']:assert p in top
assert 'ap_start' not in top.split(');',1)[0]
for s in ['parameter DataWidth = 5009;','parameter AddressRange = 32;','ram[0:AddressRange-1]','ram[address0] <= d0;','q0 <= ram[address0];']:assert s in memory
report=(H/'work/hls/syn/report/laya_owner_ct0_csynth.rpt').read_text()
assert re.search(r'\|Total\s+\|\s*8\|\s*1\|\s*49533\|\s*39937\|\s*0\|',report)
normal='CT0_HOST_PASS checks=783 operations=16 records=32 commits=6 trace_transactions=131'
assert normal in check(t['host_run']['log']).read_text()
assert sha(H/'frozen/hls/control/owner_ct0/owner_ct0.cpp')==sha(T/'frozen/hls/control/owner_ct0/owner_ct0.cpp')
host=(T/'frozen/hls/control/owner_ct0/owner_ct0_host_tb.cpp').read_text()
for s in ['full::full_require_owner','full::full_acquire_owner','full::full_release_read_owner','out.record == record','out.commit_count == commits','wrong epoch reject no write','wrong spec reject no write','readers 255 reject','++ref.owners.record[0].identity.request_id']:assert s in host
tb=(T/'frozen/hls/control/owner_ct0/owner_ct0_tb.sv').read_text()
assert 'response_din !== expected[response_words]' in tb and "dut.phase == 3'd7 && !response_full_n" in tb
counts=[]
for name,folder,n,cycles,held,maxcommit in [('full','trace',131,73429,617,6),('request_off','trace_request_off',9,5073,40,1),('model_off','trace_model_off',9,5073,40,1)]:
    marker=f'cycles={cycles} transactions={n} input_words={n*12} output_words={n*11} held_cycles={held}'
    assert marker in t[name]['marker'] and marker in check(t[name]['log']).read_text()
    commands=(T/folder/'commands.mem').read_text().splitlines();responses=(T/folder/'responses.mem').read_text().splitlines()
    assert len(commands)==1572 and len(responses)==1441
    assert all(len(s)==128 for s in commands+responses)
    if n==9:assert all(int(s,16)==0 for s in commands[108:]+responses[99:])
    packets=[sum(int(responses[11*i+j],16)<<(512*j) for j in range(11)) for i in range(n)]
    commits=[(p>>117)&0xffffffff for p in packets]
    assert max(commits)==maxcommit and all(b-a in (0,1) for a,b in zip(commits,commits[1:]))
    assert sum(b-a for a,b in zip(commits,commits[1:]))==maxcommit
    counts.append({'case':name,'transactions':n,'cycles':cycles,'blocked_response_cycles':held,'reported_commit_count':maxcommit})
intervals=[];policy_count=0;missing_policy=[]
for base in [H,T]:
    for gp in base.glob('guard_*/guard_result.json'):
        g=get(gp);plan=get(gp.parent/'guard_plan.json')
        policy_path=gp.parent/'policy_checks.json';pol=get(policy_path) if policy_path.exists() else []
        assert g['child_exit_code']==0 and g['trigger'] is None and plan['semantic_stall_seconds']==120
        assert g['minimum_mem_available_kb']>192*1024*1024
        assert all(x['matches'] and x['affinity']==[0,1,2,3] and x['nice']==19 and x['ionice']=='idle' for x in pol)
        policy_count+=len(pol)
        if not pol:missing_policy.append(str(gp.relative_to(R)))
        intervals.append({'path':str(gp.relative_to(R)),'start':get(gp.parent/'launch.json')['at'],'end':g['finished_at']})
intervals.sort(key=lambda x:x['start']);assert all(a['end']<=b['start'] for a,b in zip(intervals,intervals[1:]))
assert t['pilot']['guard']['elapsed_seconds']<=120
fail=get(B/'attempts/AT005_CT0_owner_table_hls_02/receipt.json');assert fail['status']=='FAIL'
assert (B/'attempts/AT005_CT0_owner_table_hls_02/guard_hls/driver.log').read_text().count('Unsupported aggregate pragma/directive')==2
inventory=get(B/'reports/ln_q_inventory_20261013.json')
for x in [inventory['attempts'][0]['receipt'],inventory['attempts'][0]['manifest'],inventory['data']['fixture'],inventory['generated_LN']['top']]:check(x)
paths=[H/'receipt.json',H/'input_manifest.json',T/'receipt.json',T/'input_manifest.json',gen/'laya_owner_ct0_table_r_RAM_1P_BRAM_1R1W.v',H/'work/hls/syn/report/laya_owner_ct0_csynth.rpt',B/'reports/CT0_owner_table_scoped_20261013.md',B/'reports/CT0_owner_table_verification_20261013.json',B/'reports/ln_q_inventory_20261013.json']
snapshots=[]
for p in paths:
    q=D/'snapshot'/p.relative_to(R);q.parent.mkdir(parents=True,exist_ok=True);q.write_bytes(p.read_bytes());snapshots.append({'source':str(p.relative_to(R)),'sha256':sha(q)})
result={'review':'R-SM005-CT0-20261013','at':datetime.now(timezone.utc).isoformat(),'source_files':19,'RTL_frozen_files':39,'generated_files_unchanged':generated,'unique_referenced_files':len(verified),'verified_files':verified,'guards':len(intervals),'policy_records':policy_count,'guards_without_policy_samples':missing_policy,'serial_intervals':intervals,'cases':counts,'HLS_seconds':h['hls']['guard']['elapsed_seconds'],'RTL_full_seconds':t['full']['guard']['elapsed_seconds'],'resource_level':'HLS_ESTIMATE_ONLY','scope':'original-helper checked C trace and generated RTL replay; not production or all-state proof; no per-edge independent RAM write audit','snapshots':snapshots,'no_DUT_tools_run':True}
(D/'verification.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({k:result[k] for k in ['source_files','RTL_frozen_files','unique_referenced_files','guards','policy_records','guards_without_policy_samples','HLS_seconds','RTL_full_seconds']},ensure_ascii=False))
