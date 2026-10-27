#!/usr/bin/env python3
"""Small real-process supervision tests; these are not hardware/tool runs."""
import datetime as dt
import fcntl
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import time

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import handoff_guard_d38 as h

def wait_for(p, timeout=15):
    until = time.monotonic()+timeout
    while time.monotonic() < until:
        if p.exists(): return h.read(p)
        time.sleep(.05)
    raise RuntimeError('Missing '+str(p))

def toy_guard(out, duration):
    out.mkdir(parents=True, exist_ok=True)
    with (out/'lock').open('a+') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX|fcntl.LOCK_NB)
        started = h.now(); t = time.monotonic()
        code = 'import time; x=bytearray(8*1024*1024); end=time.monotonic()+'+str(duration)+'\nwhile time.monotonic()<end:\n for n in range(10000): n*n\n'
        p = subprocess.Popen(['/usr/bin/nice','-n','19','/usr/bin/ionice','-c','3','/usr/bin/taskset','-c','0-3',sys.executable,'-c',code], start_new_session=True)
        known = {p.pid:h.owned.process_start(p.pid)}; peak = 0; minimum=h.owned.mem_available_kb()
        h.dump(out/'launch.json', {'pid':p.pid,'start':known[p.pid], 'guard_pid':os.getpid(), 'guard_start':h.owned.process_start(os.getpid()), 'started_utc':started})
        while p.poll() is None:
            items = h.owned.owned_processes(h.owned.process_table(),p.pid,known)
            peak=max(peak,sum(x['rss_kb'] for x in items.values())); minimum=min(minimum,h.owned.mem_available_kb())
            h.dump(out/'live_status.json', {'utc':h.now(),'last_progress_age_seconds':0,'owned_rss_kb':peak})
            time.sleep(.2)
        h.dump(out/'receipt.json', {'verdict':'PASS' if p.returncode==0 else 'FAIL','elapsed_seconds':time.monotonic()-t,
            'peak_owned_rss_kb':peak,'minimum_MemAvailable_kb':minimum,'known_owned_identities':known,
            'policy_samples':[], 'guard_trigger':None,'owned_after_cleanup':[],'source_verify_after':True})

def tests(out):
    out.mkdir(parents=True,exist_ok=True); results=[]
    for mode in ['normal','rss_stop','monitor_killed','watchdog_killed','guard_killed']:
        case=out/mode; case.mkdir(); (case/'checkpoints').mkdir()
        guard=subprocess.Popen([sys.executable,str(Path(__file__).resolve()),'--toy',str(case),'5'])
        launch=wait_for(case/'launch.json'); wait_for(case/'live_status.json')
        config={'attempt':str(case),'output':str(case/'handoff'),'guard_pid':launch['guard_pid'],'guard_start':launch['guard_start'],
            'leader':launch['pid'],'leader_start':launch['start'],'lock':str(case/'lock'),'lock_inode':(case/'lock').stat().st_ino,
            'started_utc':launch['started_utc'],'maximum_seconds':30,'old_cap_kb':1024**2,'old_cap_gib':1,
            'rss_limit_kb':1 if mode=='rss_stop' else 1024**2,'minimum_available_kb':0,
            'checkpoint_directory':str(case/'checkpoints'),'sample_seconds':.1,'watchdog_timeout':4}
        cfg=case/'config.json'; h.dump(cfg,config)
        with (case/'monitor.log').open('w') as log:
            monitor=subprocess.Popen([sys.executable,str(HERE/'handoff_guard_d38.py'),'--supervise',str(cfg)],stdout=log,stderr=subprocess.STDOUT)
            activation=wait_for(case/'handoff/activation.json')
            assert h.state(launch['guard_pid'],launch['guard_start']) in ('T','t')
            assert h.lock_held(case/'lock')
            observer=subprocess.Popen([sys.executable,str(HERE/'handoff_observer_d38.py'),str(cfg)])
            wait_for(case/'handoff/observer/ready.json')
            if mode=='monitor_killed':
                monitor.kill(); monitor.wait(timeout=10)
                fallback=wait_for(case/'handoff/watchdog_fallback_confirmed.json')
                assert fallback['effective_cap_GiB']==1
            elif mode=='watchdog_killed':
                wd=wait_for(case/'handoff/watchdog_ready.json'); os.kill(wd['pid'],signal.SIGKILL)
                assert monitor.wait(timeout=15)==2
                confirmation=wait_for(case/'handoff/return_confirmation.json')
                assert confirmation['confirmed']
                wait_for(case/'handoff/observer/fallback_confirmed.json')
            elif mode=='guard_killed':
                guard.kill(); guard.wait(timeout=5)
                assert monitor.wait(timeout=15)==2
                wait_for(case/'handoff/observer/fallback_owned_cleanup.json')
            else:
                rc=monitor.wait(timeout=30)
                effective=wait_for(case/'handoff/effective_receipt.json')
                assert rc==(1 if mode=='rss_stop' else 0), (mode,rc,(case/'monitor.log').read_text())
                assert effective['verdict']==('COST_STOP' if mode=='rss_stop' else 'PASS')
                assert effective['original_receipt_sha256']==__import__('hashlib').sha256((case/'receipt.json').read_bytes()).hexdigest()
                assert effective['peak_owned_rss_kb']>=h.read(case/'receipt.json')['peak_owned_rss_kb']
            guard.wait(timeout=20)
            observer.wait(timeout=15)
        assert not h.lock_held(case/'lock')
        assert h.state(launch['pid'],launch['start']) is None
        results.append({'test':mode,'result':'PASS','evidence':str(case)})
    h.dump(out/'test_result.json',{'utc':h.now(),'scope':'real small Python process guard handoff, not Vivado or hardware validation','tests':results})
    print(json.dumps(results),flush=True)

if __name__=='__main__':
    if sys.argv[1]=='--toy': toy_guard(Path(sys.argv[2]),float(sys.argv[3]))
    else: tests(Path(sys.argv[1]))
