#!/usr/bin/env python3
"""Bounded, recorded host-only analysis. Never launches EDA or reference inference."""
import datetime, hashlib, json, os, resource, signal, subprocess, sys, time
from pathlib import Path

HERE = Path(__file__).resolve().parent
RUNS = HERE / 'host_runs'
RUNS.mkdir(exist_ok=True)
name, *command = sys.argv[1:]
assert name and command and '/' not in name
receipt = RUNS / (name + '.json')
assert not receipt.exists(), 'Use a new job identity; old receipts are immutable.'
used = sum(json.loads(p.read_text()).get('elapsed_seconds', 0) for p in RUNS.glob('*.json'))
assert used < 600, 'Cumulative host budget exhausted'
limit = min(120, 600-used)
def available():
    return int(next(l.split()[1] for l in Path('/proc/meminfo').read_text().splitlines() if l.startswith('MemAvailable:')))
assert available() > 192*1024*1024, 'MemAvailable admission rejected'
start = datetime.datetime.now(datetime.timezone.utc).isoformat()
def policy():
    os.setsid()
    os.sched_setaffinity(0, {0,1,2,3})
    os.nice(19)
    resource.setrlimit(resource.RLIMIT_AS, (8*1024**3, 8*1024**3))
actual = ['ionice', '-c', '3'] + command
logpath=RUNS/(name+'.log')
t0=time.monotonic(); peak=0; samples=[]; min_mem=available(); trigger=None
with logpath.open('w') as log:
    p=subprocess.Popen(actual, cwd=HERE, stdout=log, stderr=subprocess.STDOUT, preexec_fn=policy)
    while p.poll() is None:
        min_mem=min(min_mem,available())
        try:
            raw=Path(f'/proc/{p.pid}/status').read_text()
            rss=int(next((l.split()[1] for l in raw.splitlines() if l.startswith('VmRSS:')),0))
            cpus=next(l.split(':',1)[1].strip() for l in raw.splitlines() if l.startswith('Cpus_allowed_list:'))
            peak=max(peak,rss); samples.append({'rss_kib':rss,'cpus':cpus,'nice':os.getpriority(os.PRIO_PROCESS,p.pid)})
        except (FileNotFoundError, ProcessLookupError): pass
        if time.monotonic()-t0>limit or min_mem <=192*1024*1024:
            trigger='wall_limit' if time.monotonic()-t0>limit else 'MemAvailable'
            os.killpg(p.pid, signal.SIGKILL); break
        time.sleep(.05)
    rc=p.wait()
elapsed=time.monotonic()-t0
identities=[]
for arg in command:
    q=Path(arg)
    if q.is_file():
        blob=q.read_bytes(); identities.append({'path':str(q.resolve()),'bytes':len(blob),'sha256':hashlib.sha256(blob).hexdigest()})
result={'command':actual,'cwd':str(HERE),'started_at':start,'finished_at':datetime.datetime.now(datetime.timezone.utc).isoformat(),
 'elapsed_seconds':elapsed,'cumulative_seconds':used+elapsed,'wall_limit_seconds':limit,'exit_status':rc,'trigger':trigger,
 'sample_count':len(samples),'peak_sampled_rss_kib':peak if samples else 'UNKNOWN',
 'rusage_child_maxrss_kib':resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss,
 'minimum_mem_available_kib':min_mem,'samples':samples,'policy_requested':{'cpu':'0-3','nice':19,'io':'idle','address_space_bytes':8*1024**3},
 'io_policy_sampled':'UNKNOWN; ionice command applied, no separate process observation',
 'command_file_identities_after_run':identities,'log':str(logpath)}
receipt.write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({k:result[k] for k in ['elapsed_seconds','cumulative_seconds','exit_status','trigger','sample_count','peak_sampled_rss_kib','minimum_mem_available_kib']}))
sys.exit(rc if rc>=0 else 1)
