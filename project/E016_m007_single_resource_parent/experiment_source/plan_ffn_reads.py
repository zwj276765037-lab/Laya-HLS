#!/usr/bin/env python3
import argparse,datetime as dt,hashlib,json,os,resource,subprocess,time
from pathlib import Path
resource.setrlimit(resource.RLIMIT_AS,(1024**3,1024**3));os.sched_setaffinity(0,{0,1,2,3});started=time.monotonic()
ROOT=Path(__file__).resolve().parents[3];OUT=ROOT/'project/E016_m007_single_resource_parent/experiment_results/planning/ffn_control_arena_20261022';p=argparse.ArgumentParser();p.add_argument('stage');a=p.parse_args();records=[];excerpts={}
def load(rel):
 q=ROOT/rel;b=q.read_bytes();records.append({'path':rel,'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest()});return b.decode()
if a.stage=='scope':
 rel='mission/M007_完整Attention高性能主干与部署闭合/tasks/SM012.md';data=load(rel);mark=data.rfind('CONTROL-ARENA-16');excerpts['contract']=data[max(0,mark-5):] if mark>=0 else data[-18000:]
 args=['rg','--files','project/E002_Laya_HLS/experiment/vivado/module_design','project/E015_m007_tanh_geglu8/experiment_source','project/E015_m007_tanh_geglu8/experiment_results/runs/R001','source']
 r=subprocess.run(args,cwd=ROOT,capture_output=True,text=True,check=True);terms=['geglu','tanh','gate','m007_matrix_facade','m007_matrix_f32','m007_ffn','control_arena','arena']
 excerpts['candidate_files']='\n'.join(x for x in r.stdout.splitlines() if any(t in x.lower() for t in terms) and '/work/' not in x and '/frozen/' not in x and '/xsim.dir/' not in x and '/attempts/' not in x)[:18000]
 for rel in ['project/E015_m007_tanh_geglu8/experiment_source/summary.md','project/E015_m007_tanh_geglu8/experiment_results/summary.md','project/E015_m007_tanh_geglu8/experiment_status/summary.md']:
  excerpts[rel]=load(rel)
else:
 request=json.loads((OUT/(a.stage+'_request.json')).read_text())
 for pattern in request.get('discover',[]):
  excerpts['discover:'+pattern]='\n'.join(str(q.relative_to(ROOT)) for q in sorted(ROOT.glob(pattern)) if q.is_file())
 for item in request['files']:
  rel=item['path'];data=load(rel);lines=data.splitlines();selected=set()
  if item.get('full'):selected=set(range(len(lines)))
  for i,line in enumerate(lines):
   if any(t in line for t in item.get('terms',[])):selected.update(range(max(0,i-item.get('context',1)),min(len(lines),i+item.get('context',1)+1)))
  for lo,hi in item.get('ranges',[]):selected.update(range(max(0,lo-1),min(len(lines),hi)))
  excerpts[rel]='\n'.join(f'{i+1}: {lines[i]}' for i in sorted(selected) if len(lines[i])<=item.get('max_line',1000))
elapsed=time.monotonic()-started;assert elapsed<20;receipt={'stage':a.stage,'started_at':dt.datetime.now(dt.timezone.utc).isoformat(),'elapsed_s':elapsed,'peak_self_rss_kb':resource.getrusage(resource.RUSAGE_SELF).ru_maxrss,'peak_child_rss_kb':resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss,'address_space_limit_bytes':1024**3,'timeout_s':20,'cpu_ids':sorted(os.sched_getaffinity(0)),'nice':os.getpriority(os.PRIO_PROCESS,0),'ionice':'idle actual launch','files':records,'scope':'read-only light source/gold inspection; no RTL edits/EDA/new gold'}
(OUT/(a.stage+'_read_receipt.json')).write_text(json.dumps(receipt,indent=2)+'\n');(OUT/(a.stage+'_excerpts.json')).write_text(json.dumps(excerpts,indent=2,ensure_ascii=False)+'\n');receipts=[json.loads(q.read_text()) for q in sorted(OUT.glob('*_read_receipt.json'))];used=sum(x['elapsed_s'] for x in receipts);assert used<=60;(OUT/'planning_ledger.json').write_text(json.dumps({'limits_s':{'planning_read':60},'used_s':used,'remaining_s':60-used,'receipts':receipts,'R003_balances_transferred':False},indent=2)+'\n')
for k,v in excerpts.items():print('\n'+k+'\n'+v)
print('FFN_BOUNDED_READ_PASS '+json.dumps({k:receipt[k] for k in ['stage','elapsed_s','peak_self_rss_kb','peak_child_rss_kb','cpu_ids','nice']}))
