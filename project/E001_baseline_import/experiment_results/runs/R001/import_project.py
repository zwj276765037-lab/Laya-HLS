#!/usr/bin/env python3
"""Run only after the baseline's current owners and tools reach terminal state."""
import csv, datetime, hashlib, json, os, pathlib, stat, subprocess, time, socket, shutil
S = pathlib.Path('/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline').resolve()
N = pathlib.Path('/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS')
HELPER = '/home/zwj/.codex/skills/research-agent/scripts/research.py'
def tool(*a):
    r = subprocess.run(['python3', HELPER, *a], text=True, capture_output=True, check=True)
    print(r.stdout.strip(), flush=True)
    return json.loads(r.stdout)
def sha(p):
    h=hashlib.sha256()
    with p.open('rb') as f:
        for b in iter(lambda:f.read(1024*1024),b''): h.update(b)
    return h.hexdigest()
def dump(p,d):
    p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n')
started=datetime.datetime.now(datetime.timezone.utc).isoformat()
if any(N.iterdir()): raise SystemExit('Destination is no longer empty; inspect before merging.')
tool('init','--parent',str(N.parent),'--name',N.name)
records=[
 ('mission','M001','工程复制与Research接入',None,None,None,None),
 ('mission','M002','完整Laya加速器实现',None,None,None,None),
 ('small-mission','SM001','完整复制与一致性验证','M001',None,None,None),
 ('small-mission','SM002','真实生产接口与推理吞吐闭合','M002',None,None,None),
 ('experiment','E001','baseline_import','M001','SM001',None,None),
 ('experiment','E002','Laya_HLS','M002','SM002',None,None),
 ('agent','A001','项目主控与架构评判','M002','SM002','controller','E002'),
 ('agent','A002','工程实现与验证','M002','SM002','engineering','E002'),
 ('agent','A003','研究探索与瓶颈分析','M002','SM002','research','E002')]
for kind,i,title,m,sm,role,e in records:
    a=['add','--root',str(N),'--kind',kind,'--id',i,'--title',title]
    if m:a+=['--mission',m]
    if sm:a+=['--small-mission',sm]
    if role:a+=['--role',role]
    if e:a+=['--experiment',e]
    if kind=='experiment':a+=['--experiment-kind','generic' if i=='E001' else 'hardware']
    tool(*a)
for role,model in [('controller','gpt-6-astra'),('engineering','gpt-6.1-sol'),('research','gpt-6-astra')]:
    tool('model-set','--root',str(N),'--scope','role','--id',role,'--model',model,'--effort','xhigh')
tool('run','--root',str(N),'--experiment','E001','--id','R001')
D=N/'project/E002_Laya_HLS/experiment'
R=N/'project/E001_baseline_import/experiment_results/runs/R001'
shutil.copy2(__file__,R/'import_project.py')
dump(R/'execution_identity.json',{'host':socket.gethostname(),'script_sha256':sha(pathlib.Path(__file__)),'command':'taskset -c 0-3 nice -n 19 ionice -c 3 python3 /tmp/laya_hls_import_20261011.py','cwd':os.getcwd(),'source':str(S),'destination':str(D),'rsync_version':subprocess.check_output(['rsync','--version'],text=True).splitlines()[0],'python_version':subprocess.check_output(['python3','--version'],text=True).strip(),'started_at':started,'new_hardware_tools_run':False,'resource_policy':'CPU0-3, nice19, idle IO; single sequential copy/verification process after old phase tool exit'})
entries=[]
for root,dirs,files in os.walk(S,followlinks=False):
    for name in dirs+files:
        p=pathlib.Path(root)/name;st=p.lstat()
        if p.is_symlink(): typ='symlink'
        elif p.is_file():typ='file'
        elif p.is_dir():typ='dir'
        else:raise RuntimeError('Unexpected special source entry: '+str(p))
        entries.append((p.relative_to(S).as_posix(),typ,st.st_size,st.st_mtime_ns,stat.S_IMODE(st.st_mode)))
dump(R/'source_inventory.json',entries)
print('COPY_BEGIN entries='+str(len(entries)),flush=True)
with (R/'copy.log').open('w') as log:
    subprocess.run(['rsync','-aH','--info=stats2',str(S)+'/',str(D)+'/'],stdout=log,stderr=subprocess.STDOUT,check=True)
print('COPY_DONE',flush=True)
links=[]
for rel,typ,size,mtime,mode in entries:
    if typ!='symlink':continue
    old=S/rel; new=D/rel;raw=os.readlink(old)
    target=pathlib.Path(os.path.normpath(raw if os.path.isabs(raw) else str(old.parent/raw)))
    if target.is_relative_to(S):
        copied=D/target.relative_to(S)
        mapped=os.path.relpath(copied,new.parent)
    else:
        mapped=str(target)
    if os.readlink(new)!=mapped:
        new.unlink();new.symlink_to(mapped)
    links.append({'path':rel,'source_target':raw,'copied_target':mapped,'exists':new.exists()})
dump(R/'symlink_mapping.json',links)
counts={'file':0,'dir':0,'symlink':0};bytes_checked=0;errors=[];t=time.monotonic();last=t
manifest=R/'file_sha256.jsonl'
with manifest.open('w') as out:
    for rel,typ,size,mtime,mode in entries:
        src=S/rel;dst=D/rel;ss=src.lstat();ds=dst.lstat();counts[typ]+=1
        if ss.st_mtime_ns!=mtime or (typ!='dir' and ss.st_size!=size):errors.append({'path':rel,'error':'source_changed_during_import'})
        if typ=='file':
            if not stat.S_ISREG(ds.st_mode):errors.append({'path':rel,'error':'destination_not_regular'});continue
            if (ss.st_dev,ss.st_ino)==(ds.st_dev,ds.st_ino):errors.append({'path':rel,'error':'cross_source_hardlink'})
            hs=sha(src);hd=sha(dst);bytes_checked+=size
            if hs!=hd:errors.append({'path':rel,'error':'content_mismatch'})
            out.write(json.dumps({'path':rel,'bytes':size,'sha256':hs,'copy_sha256':hd},ensure_ascii=False)+'\n')
        elif typ=='dir' and not stat.S_ISDIR(ds.st_mode):errors.append({'path':rel,'error':'destination_not_directory'})
        elif typ=='symlink' and not stat.S_ISLNK(ds.st_mode):errors.append({'path':rel,'error':'destination_not_symlink'})
        if typ!='symlink' and stat.S_IMODE(ds.st_mode)!=mode:errors.append({'path':rel,'error':'mode_mismatch'})
        now=time.monotonic()
        if now-last>30:
            print('VERIFY files=%d bytes=%d elapsed=%.1f'%(counts['file'],bytes_checked,now-t),flush=True);last=now
source_set={x[0] for x in entries};destination_set=set()
for root,dirs,files in os.walk(D,followlinks=False):
    for name in dirs+files:destination_set.add((pathlib.Path(root)/name).relative_to(D).as_posix())
if source_set!=destination_set:errors.append({'error':'entry_set_mismatch','missing':sorted(source_set-destination_set),'extra':sorted(destination_set-source_set)})
for link in links:
    if not link['exists']:errors.append({'path':link['path'],'error':'broken_copied_link'})
receipt={'schema':1,'status':'PASS_COPY_VERIFIED' if not errors else 'FAIL_COPY_VERIFICATION','source':str(S),'destination':str(D),'project_root':str(N),'started_at':started,'finished_at':datetime.datetime.now(datetime.timezone.utc).isoformat(),'counts':counts,'logical_regular_file_bytes':bytes_checked,'sha256_manifest':{'path':str(manifest.relative_to(N)),'sha256':sha(manifest)},'symlink_mapping':{'path':str((R/'symlink_mapping.json').relative_to(N)),'sha256':sha(R/'symlink_mapping.json')},'source_inventory':{'path':str((R/'source_inventory.json').relative_to(N)),'sha256':sha(R/'source_inventory.json')},'source_deleted':False,'source_regular_files_modified':False,'copied_regular_files_byte_identical':not errors,'source_and_copy_share_regular_file_inodes':False,'symlinks_rebased_to_copy':len(links),'errors':errors,'hardware_validation_run_by_import':False,'new_agents_launched':False}
dump(R/'copy_receipt.json',receipt)
dump(N/'source/path_mapping.json',{'original_baseline_root':str(S),'copied_baseline_root':str(D),'project_root':str(N),'shared_model_root':str(S.parents[1]/'model'),'history_policy':'Keep original content and absolute paths in frozen logs/receipts. For new execution use copied code and regenerate configuration under new root.','regular_files_rewritten':False})
print(json.dumps(receipt,ensure_ascii=False),flush=True)
if errors:raise SystemExit(2)
