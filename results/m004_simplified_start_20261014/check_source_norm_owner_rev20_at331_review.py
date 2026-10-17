"""Read-only milestone audit; no EDA, reference evaluation or production edits."""
import hashlib,json,os,re,subprocess
from pathlib import Path
from decimal import Decimal
R=Path(__file__).resolve().parents[2]
B=R/'project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts'
A={n:next(B.glob(f'AT{n}_*')) for n in range(326,332)}
checks=[];identities=[];guards=[];manifests={}
def ck(name,value):checks.append({'name':name,'pass':bool(value)})
def read(p,want=None):
    b=p.read_bytes();h=hashlib.sha256(b).hexdigest();identities.append({'path':str(p.relative_to(R)),'sha256':h,'bytes':len(b)})
    if want:ck('sha:'+str(p.relative_to(R)),h==want)
    return b
ledger=json.loads(read(B.parent/'reports/SM004_rev20_guard_ledger_AT326_AT331_20261016.json'))
frozen=fixture=policy=0;sums={'static':Decimal(0),'rtl':Decimal(0)}
for e in ledger['attempts']:
    a=B/e['attempt'];n=int(a.name[2:5]);m=json.loads(read(a/'source_manifest.json',e['manifest_sha256']));manifests[n]=m
    ck(a.name+':manifest_counts',len(m['entries'])==e['frozen_entries'] and len(m.get('fixture_entries',[]))==e['fixture_entries'])
    for x in m['entries']:
        b=read(a/'frozen'/x['name'],x['sha256']);ck(a.name+':bytes:'+x['name'],len(b)==x['bytes']);frozen+=1
    for x in m.get('fixture_entries',[]):
        b=read(a/'fixture'/x['name'],x['sha256']);old=read(Path(m['fixture_source'])/x['name']);ck(a.name+':fixture:'+x['name'],b==old and len(b)==x['bytes']);fixture+=1
    for x in e['guards']:
        g=a/('guard_'+x['kind']);r=json.loads(read(g/'guard_result.json'),parse_float=Decimal);p=json.loads(read(g/'guard_plan.json'));log=read(g/'driver.log').decode();pol=json.loads(read(g/'policy_checks.json'))
        ck(a.name+':'+g.name+':receipt',r['elapsed_seconds']==Decimal(x['elapsed_seconds']) and r['child_exit_code']==x['child_exit_code']==0 and r['trigger']==x['trigger'] is None)
        ck(a.name+':'+g.name+':log',not re.search(r'^(?:Fatal:|ERROR:)',log,re.M))
        ck(a.name+':'+g.name+':memory',r['minimum_mem_available_kb']>192*1024**2 and r['peak_owned_rss_kb']<=p['maximum_owned_rss_kb'])
        ck(a.name+':'+g.name+':policies',len(pol)==x['policy_samples'])
        for j,v in enumerate(pol):ck(a.name+':'+g.name+':policy'+str(j),v['matches'] and v['affinity']==[0,1,2,3] and v['nice']==19 and v['ionice']=='idle' and v['ionice_exit']==0)
        policy+=len(pol);sums[x['kind']]+=r['elapsed_seconds'];guards.append({'attempt':a.name,'guard':g.name,'seconds':str(r['elapsed_seconds']),'meaning':'BUG_REPRODUCED_NOT_CORRECTNESS_PASS' if n==329 and x['kind']=='rtl' else 'SCOPED_EVIDENCE'})
ck('773_entries_100_policies_12guards',frozen+fixture==773==ledger['total_manifest_entries'] and policy==100==ledger['policy_samples'] and len(guards)==12)
for k in sums:
    ck(k+':total',sums[k]==Decimal(ledger[k+'_seconds']))
    ck(k+':remaining',Decimal(1800 if k=='static' else 3600)-sums[k]==Decimal(ledger[k+'_remaining_seconds']))
def src(n,name):return (A[n]/'frozen'/name).read_text()
name='laya_lnq_bank_service_v1.sv'
old=src(327,name);current=src(331,name)
old_body=old[old.index('module laya_lnq_bank_service_v1'):];body=current[current.index('module laya_lnq_bank_service_v1'):]
ck('physical_lower_body_unchanged',old_body==body)
interface=current.split('interface laya_lnq_bank_link_v1;',1)[1].split('endinterface',1)[0]
ck('interface_declarations_only',not re.search(r'\b(always|always_ff|always_comb|assign|initial|task|function)\b',interface))
header=old_body.split(');',1)[0].split('(',1)[1]
ports={}
for direction,decl in re.findall(r'\b(input|output)\s+logic\s+(.*?)(?=,\s*(?:input|output)\s+logic|\Z)',header,re.S):
    widths=re.match(r'((?:\[[^]]+\]\s*)*)',decl).group(1)
    names=decl[len(widths):].strip().rstrip(',')
    for v in names.split(','):ports[v.strip()]=(direction,re.sub(r'\s+','',widths))
link={}
for widths,names in re.findall(r'logic\s+((?:\[[^]]+\]\s*)*)([^;]+);',interface):
    for v in names.split(','):link[v.strip()]=re.sub(r'\s+','',widths)
ck('151_original_signals_names_widths',len(link)==151 and link=={k:v[1] for k,v in ports.items() if k not in ['clk','rst_n']})

def connections(text,marker):
    s=text.split(marker,1)[1];s=s[:s.index(');')];out={};i=0
    while i<len(s):
        m=re.search(r'\.(\w+)',s[i:])
        if not m:break
        key=m.group(1);i+=m.end()
        while i<len(s) and s[i].isspace():i+=1
        if i<len(s) and s[i]=='(':
            i+=1;start=i;depth=1
            while depth and i<len(s):
                if s[i]=='(':depth+=1
                elif s[i]==')':depth-=1
                i+=1
            value=s[start:i-1]
        else:value=key
        out[key]=re.sub(r'\s+','',value)
    return out
original_core=src(327,'laya_lnq_wi_gqdown_row_v1.sv');core=src(331,'laya_lnq_wi_gqdown_row_v1.sv')
engine=core.split('endmodule',1)[0]
prior_wires=connections(original_core,'laya_lnq_bank_service_v1 bank_service (')
assigns={re.sub(r'\s+','',a):re.sub(r'\s+','',b) for a,b in re.findall(r'assign\s+([^;=]+)=([^;]+);',engine,re.S)}
for signal in link:
    expected=prior_wires[signal]
    ck('fixed_wire:'+signal,assigns.get('bank_link.'+signal)==expected if ports[signal][0]=='input' else assigns.get(expected)=='bank_link.'+signal)
upper=src(331,'laya_source_norm_service_v1.sv');wrapper=src(331,'laya_qkv_scratch_row_v1.sv')
upper_wires=connections(upper,'laya_lnq_bank_service_v1 bank_service (')
ck('upper_direct_bank_mapping',all(upper_wires[k]=='bank_link.'+k for k in link))
ck('parent_engine_not_compat_shell','laya_lnq_wi_gqdown_row_engine_v1 core' in wrapper and not re.search(r'laya_lnq_wi_gqdown_row_v1\s+\w+\s*\(',wrapper))
ck('one_bank_in_upper',len(re.findall(r'laya_lnq_bank_service_v1\s+\w+\s*\(',upper))==1 and 'laya_lnq_bank_service_v1 bank_service' not in engine)
compile_log=(A[331]/'guard_static/driver.log').read_text()
ck('parent_elab_engine_not_shell','Compiling module work.laya_lnq_wi_gqdown_row_engine_v1' in compile_log and not re.search(r'^Compiling module work.laya_lnq_wi_gqdown_row_v1(?:$|_)',compile_log,re.M))
ck('real_request_snapshot','Compiling module work.laya_qkv_s128_request_v1' in compile_log)
for n,mark in [(328,'STAGED_LN_ROW0_PREFIX_PASS norm=1024 B=64 sourceR=64 gammaR=256'),(329,'LN_LOCAL_OLD_CHECK_BUG_REPRODUCED status=7 check=0 detail=0 lower_accepts=1'),(330,'LN_LOCAL_REJECT_CHECK_PASS first_lower=1 second_lower=0 axi=0'),(331,'STAGED_LN_ROW0_PREFIX_PASS norm=1024 B=64 sourceR=64 gammaR=256')]:
    ck(f'AT{n}:unique_marker',(A[n]/'guard_rtl/driver.log').read_text().count(mark)==1)
ck('fix_same_engine_as_final_parent',src(330,'laya_lnq_wi_gqdown_row_v1.sv')==core)
ck('delegated_on_actual_accept','staged_ln_delegated<=staged_ln_accept;' in engine and 'staged_ln_admissible && staged_ln_cmd_ready;' in engine)
ck('local_reject_uses_own_Check','!staged_ln_delegated || staged_ln_identity_bad' in engine)
tb=src(330,'laya_ln_only_local_reject_tb.sv')
ck('test_no_third_command',tb[tb.index('LN_LOCAL_REPEAT_CHECK'):].count('cmd_valid=1')==0)
report={'through':'AT331','checks':checks,'check_count':len(checks),'failures':[c for c in checks if not c['pass']], 'identities':identities,'frozen_entries':frozen,'fixture_entries':fixture,'total_entries':frozen+fixture,'guards':guards,'policy_samples':policy,
 'totals':{k:str(v) for k,v in sums.items()},'remaining':{k:ledger[k+'_remaining_seconds'] for k in sums},
 'issue':{'id':'REV20-LOCAL-REJECT-CHECK','status':'CLOSED_SCOPED_REPRO_AND_CHECK_FIX','old':'AT329 old AT327 monolithic core, real zero-input/one-gamma LN then same-identity no-token reject','fix':'AT330 compatibility shell plus fixed shared engine; AT331 same fixed engine real parent row0','not_run':'error-done consumption followed by third lawful command in same runtime; other Check branches'},
 'physical_extract':'151 fixed wires statically identical; physical lower body unchanged; parent uses engine and one upper-owned bank, compatibility shell unused in parent',
 'scope':'normal parent row0 and local missing-token Check only; upper128/source/norm owner migration incomplete, independent16/128 NOT_RUN',
 'host_complete_cumulative':'UNKNOWN','controller_policy':{'affinity':sorted(os.sched_getaffinity(0)),'nice':os.getpriority(os.PRIO_PROCESS,0),'ionice':subprocess.check_output(['ionice','-p',str(os.getpid())],text=True).strip()}}
Path(__file__).with_name('source_norm_owner_rev20_at331_review_20261016.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({k:report[k] for k in ['check_count','failures','total_entries','policy_samples','totals','remaining']}))
raise SystemExit(bool(report['failures']))
