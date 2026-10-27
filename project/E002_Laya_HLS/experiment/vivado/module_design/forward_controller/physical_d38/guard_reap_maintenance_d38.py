#!/usr/bin/python3
"""Four-second maintenance of one monitor; separate coordinator and restorer."""
if not __debug__:
    raise RuntimeError('Optimized Python forbidden')
import hashlib
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import time
import guard_selfstop_native_d38 as n
import handoff_guard_d38 as h

HERE=Path(__file__).resolve().parent
def dump(path,value):
    path=Path(path);tmp=path.with_name(path.name+'.'+str(os.getpid())+'.tmp')
    with tmp.open('w') as f:
        json.dump(value,f,indent=2);f.write('\n');f.flush();os.fsync(f.fileno())
    tmp.replace(path)

def policy():
    os.sched_setaffinity(0,{0,1,2,3});os.setpriority(os.PRIO_PROCESS,0,19)
    subprocess.run(['/usr/bin/ionice','-c','3','-p',str(os.getpid())],check=True,timeout=1)

def state(identity):return n.same(identity['pid'],identity['start'])

def budget(deadline):
    remaining=deadline-time.monotonic()
    if remaining<=0:raise TimeoutError('Unified maintenance deadline expired; monitor must remain stopped')
    return remaining

def maintenance_deadline(out):
    path=Path(out)/'maintenance_started.json'
    assert path.exists(),'Durable maintenance deadline missing; no fresh pause budget is allowed'
    return h.read(path)['deadline_monotonic']

def original_receipt(c):
    path=Path(c['attempt'])/'receipt.json'
    if (Path(c['maintenance_output'])/'restoration.json').exists() and path.exists():
        value=h.read(path)
        assert not value['owned_after_cleanup']
        return dict(path=str(path),verdict=value['verdict'],scope='Original flow result; recovery does not certify hardware acceptance')
    return None

def resources(c,deadline=None):
    completed=original_receipt(c)
    if completed:return dict(epoch=time.time(),original_stage_receipt=completed)
    assert h.lock_held(c['lock']) and Path(c['lock']).stat().st_ino==c['lock_inode']
    known={int(k):v for k,v in c['known'].items()}
    timeout=min(.2,budget(deadline)) if deadline is not None else .2
    listing=subprocess.run(['/usr/bin/ps','-eo','pid=,ppid=,pgid=,rss=,ni=,stat=,comm='],capture_output=True,text=True,check=True,timeout=timeout)
    table={}
    for line in listing.stdout.splitlines():
        fields=line.split(maxsplit=6)
        if len(fields)!=7:continue
        try:
            pid,ppid,pgid,rss=map(int,fields[:4]);nice=int(fields[4])
        except ValueError:continue
        table[pid]=dict(pid=pid,ppid=ppid,pgid=pgid,rss_kb=rss,nice=nice,state=fields[5],command=fields[6])
    items=h.owned.owned_processes(table,c['leader'],known)
    rss=sum(v['rss_kb'] for v in items.values());available=h.owned.mem_available_kb()
    assert rss<c['rss_limit_kb'] and available>c['minimum_available_kb'],'Resource protection triggered'
    for item in items.values():
        if item['state']=='Z':continue
        assert item['nice']==19 and set(os.sched_getaffinity(item['pid'])).issubset({0,1,2,3})
    for role in ['watchdog','observer']:
        assert state(c[role])['state'] not in ('T','t')
    state(c['monitor']);n.same(c['guard_pid'],c['guard_start'])
    assert not (Path(c['handoff'])/'watchdog_fallback.json').exists()
    assert not (Path(c['handoff'])/'observer/fallback_started.json').exists()
    assert not (Path(c['handoff'])/'observer/fallback_owned_cleanup.json').exists()
    return dict(epoch=time.time(),rss_kb=rss,available_kb=available,lock_held=True,active_owned=sum(not v['state'].startswith('Z') for v in items.values()))

def wait_plain_stop(pid,start,timeout=.3):
    end=time.monotonic()+timeout
    while time.monotonic()<end:
        value=n.same(pid,start)
        if value['state']=='T' and value['tracer']==0:return value
        time.sleep(.001)
    raise RuntimeError('Untraced real T not established')

def kill_helper(identity):
    item=n.proc(identity['pid'])
    if item and item['start']==identity['start'] and item['state']!='Z':
        os.kill(identity['pid'],signal.SIGKILL)

def cleanup(c,journal,deadline=None):
    """Sole worker owns cleanup; coordinator calls only after worker is dead."""
    out=Path(c['maintenance_output'])
    deadline=maintenance_deadline(out) if deadline is None else deadline
    completed=original_receipt(c)
    if completed:return dict(original_stage_receipt=completed,guard_at_restoration=h.read(out/'restoration.json')['guard'])
    if (out/'tracer_identity.json').exists():
        identity=h.read(out/'tracer_identity.json');kill_helper(identity)
        end=time.monotonic()+min(.15,max(0,deadline-time.monotonic()))
        while time.monotonic()<end:
            if n.same(c['guard_pid'],c['guard_start'])['tracer']==0:break
            time.sleep(.001)
    guard=n.same(c['guard_pid'],c['guard_start'])
    os.kill(guard['pid'],signal.SIGSTOP)
    wait_plain_stop(guard['pid'],guard['start'],min(.15,max(.001,deadline-time.monotonic())))
    budget(deadline)
    restored=n.restore(journal)
    budget(deadline)
    assert restored['state']=='T' and restored['tracer']==0
    dump(out/'restoration.json',dict(epoch=time.time(),monotonic=time.monotonic(),deadline_monotonic=deadline,guard=restored,full_registers_and_48_bytes_verified=True))
    monitor=state(c['monitor'])
    before=h.read(Path(c['handoff'])/'heartbeat.json')['epoch']
    budget(deadline)
    if monitor['state']=='T':
        os.kill(monitor['pid'],signal.SIGCONT)
    else:
        assert monitor['state'] not in ('t','Z')
    end=min(time.monotonic()+1.15,deadline)
    while time.monotonic()<end:
        sample=resources(c,deadline)
        if sample.get('original_stage_receipt'):return sample
        beat=h.read(Path(c['handoff'])/'heartbeat.json')
        if beat['epoch']>before and state(c['monitor'])['state'] not in ('T','t'):
            current=n.proc(c['guard_pid'])
            assert (current and current['start']==c['guard_start'] and current['state']=='T') or sample['active_owned']==0
            return dict(guard_at_restoration=restored,current_guard_observation=current,monitor=state(c['monitor']),heartbeat_epoch=beat['epoch'],active_owned=sample['active_owned'])
        time.sleep(.01)
    raise RuntimeError('Monitor heartbeat not confirmed within unified deadline')

def worker(config):
    policy();c=h.read(config);out=Path(c['maintenance_output']);journal=h.read(out/'journal.json')
    resources(c)
    dump(out/'worker_ready.json',dict(pid=os.getpid(),start=n.proc(os.getpid())['start']))
    heartbeat=h.read(Path(c['handoff'])/'heartbeat.json')
    assert 0<=time.time()-heartbeat['epoch']<.8,'Fresh original heartbeat required'
    started=time.monotonic();deadline=started+4
    dump(out/'maintenance_started.json',dict(epoch=time.time(),monotonic=started,deadline_monotonic=deadline,original_heartbeat=heartbeat,scope='Durable intent before SIGSTOP; budget begins before actual pause'))
    monitor=state(c['monitor']);assert monitor['state'] not in ('T','t')
    os.kill(monitor['pid'],signal.SIGSTOP);wait_plain_stop(monitor['pid'],monitor['start'])
    tracer=None;error=None;samples=[]
    try:
        tracer=subprocess.Popen([sys.executable,__file__,'--native',str(config)],start_new_session=True,
                                stdout=(out/'native.stdout').open('w'),stderr=(out/'native.stderr').open('w'))
        dump(out/'tracer_identity.json',dict(pid=tracer.pid,start=n.proc(tracer.pid)['start']))
        dump(out/'native_go.json',dict(parent=os.getpid()))
        while tracer.poll() is None:
            samples.append(resources(c,deadline))
            if c.get('test_kill_worker') and (out/'native_running.json').exists():os.kill(os.getpid(),signal.SIGKILL)
            if time.monotonic()>started+.6:
                tracer.kill();raise TimeoutError('Native helper exceeded maintenance budget')
            time.sleep(.01)
        if tracer.returncode!=0: error='Native helper exit '+str(tracer.returncode)
    except BaseException as exc:
        error=repr(exc)
    finally:
        restored=cleanup(c,journal,deadline)
        elapsed=time.monotonic()-started
        result=dict(PASS=error is None,error=error,elapsed_seconds=elapsed,within_four_seconds=elapsed<4,
                    restoration=restored,resource_samples=samples,original_heartbeat_not_written=True)
        assert elapsed<4,result
        dump(out/'worker_result.json',result)
    return result

def native(config):
    policy();c=h.read(config);out=Path(c['maintenance_output']);journal=h.read(out/'journal.json')
    if c.get('fixture') is not True:
        assert (journal['pid'],journal['start'],journal['child'],journal['child_start'])==(3582995,66052065,3633734,66420454)
        assert not c.get('test_fault') and not c.get('test_kill_worker') and not c.get('test_hold_native')
    end=time.monotonic()+.5
    while not (out/'native_go.json').exists() and time.monotonic()<end:time.sleep(.001)
    assert (out/'native_go.json').exists()
    def hook(phase):
        if phase=='after_registers' and c.get('test_hold_native'):
            assert c.get('fixture') is True
            time.sleep(10)
        if phase=='running_1':dump(out/'native_running.json',dict(epoch=time.time()))
        if c.get('test_fault')==phase:
            assert c.get('fixture') is True
            os.kill(os.getpid(),signal.SIGKILL)
        if phase=='running_1' and c.get('test_kill_worker'):
            assert c.get('fixture') is True
            time.sleep(.15)
    result=n.execute(journal,hook);dump(out/'native_result.json',result)

def run(config):
    policy();c=h.read(config);out=Path(c['maintenance_output'])
    assert out.is_dir() and not (out/'worker_ready.json').exists()
    resources(c);journal=h.read(out/'journal.json')
    child=subprocess.Popen([sys.executable,__file__,'--worker',str(config)],start_new_session=True,
                           stdout=(out/'worker.stdout').open('w'),stderr=(out/'worker.stderr').open('w'))
    child_identity=dict(pid=child.pid,start=n.proc(child.pid)['start']);dump(out/'worker_identity.json',child_identity)
    begun=time.monotonic();samples=[];backup=False;deadline=begun+4
    try:
        while child.poll() is None:
            if (out/'maintenance_started.json').exists():deadline=maintenance_deadline(out)
            samples.append(resources(c,deadline))
            takeover=((out/'maintenance_started.json').exists() and not (out/'restoration.json').exists() and time.monotonic()>deadline-3)
            if takeover or (not (out/'maintenance_started.json').exists() and time.monotonic()-begun>1.5):
                child.kill();child.wait(timeout=.2);backup=True;break
            time.sleep(.01)
        if not (out/'worker_result.json').exists():
            backup=True
            cleanup(c,journal,deadline)
        result=h.read(out/'worker_result.json') if (out/'worker_result.json').exists() else dict(PASS=False,error='Maintenance worker lost; independent coordinator restored state')
        deadline=maintenance_deadline(out)
        started=h.read(out/'maintenance_started.json')['monotonic'] if (out/'maintenance_started.json').exists() else begun
        result.update(coordinator_backup_used=backup,coordinator_samples=samples,coordinator_elapsed_seconds=time.monotonic()-begun,
                      unified_maintenance_elapsed_seconds=time.monotonic()-started,unified_deadline_monotonic=deadline,unified_deadline_met=time.monotonic()<deadline)
        assert result['unified_deadline_met'],result
        dump(out/'result.json',result)
        return result
    except BaseException as exc:
        kill_helper(child_identity);child.wait(timeout=.3)
        try:
            cleanup(c,journal,deadline)
        except BaseException as recovery_error:
            dump(out/'failed_closed.json',dict(error=repr(exc),recovery_error=repr(recovery_error),guard=n.proc(c['guard_pid']),monitor=n.proc(c['monitor']['pid']),
                   guarantee='No monitor CONT after failed context restoration. Native guard self-stop remains; original watchdog/observer retain their existing heartbeat-failure fallback.',deadline_monotonic=deadline))
        raise

if __name__=='__main__':
    if sys.argv[1]=='--native':native(Path(sys.argv[2]))
    elif sys.argv[1]=='--worker':worker(Path(sys.argv[2]))
    elif sys.argv[1]=='--run':run(Path(sys.argv[2]))
    else:raise RuntimeError('No implicit operation')
