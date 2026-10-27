#!/usr/bin/python3
"""Fixed AT019 recovery: temporarily modify 48 guard RX-padding bytes, restore all.

Administrator --execute is the only production mutation entry. Default is a
read-only plan with no attach. The Vivado process is never traced or signalled.
"""
if not __debug__:
    raise RuntimeError('Optimized Python forbidden')
import argparse
import datetime as dt
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import time
import uuid

HERE=Path(__file__).resolve().parent
EXPECTED={
    'admin_harts_diagnostic_v2_d38.py':'75f3ea56536e1786f98fce471242a379cd5dc6381d3e6a502a7443247530c9af',
    'guard_selfstop_native_d38.py':'89cd5cfa91888f2e8cc0bc4329fc793a4429ff712ae146e806fa3d0fff556577',
    'guard_reap_maintenance_d38.py':'5a52d2d3cfc657920ad57532926ecfb60417554a13e3bf47d2074be481356003',
    'handoff_guard_d38.py':'4ead4e76d8a2ef334e8e33c80315be899bdae434ab54c8abe0c1f7846b8aa1ec',
    'run_physical_d38.py':'42164971755a1dcc57a01ddc0c9101cb6af19a2db5506924a2debd7007569f89'}
for filename,digest in EXPECTED.items():
    assert hashlib.sha256((HERE/filename).read_bytes()).hexdigest()==digest,'Recovery dependency changed: '+filename
sys.path.insert(0,str(HERE))
import guard_selfstop_native_d38 as native
import guard_reap_maintenance_d38 as maintenance
spec=importlib.util.spec_from_file_location('fixed_v2_preflight',HERE/'admin_harts_diagnostic_v2_d38.py')
diagnostic=importlib.util.module_from_spec(spec);spec.loader.exec_module(diagnostic)
base=diagnostic.base
CHILD,CHILD_START=3633734,66420454
DG=base.DEST/'DG_OBJECT_20261026T104830Z_8a4d5837'
EVIDENCE={
    'object_fields.json':'cc9c74587da72b2a6a6a25b75e794a682cde05ba7ba5352d1414dd803694dce2',
    'capture.json':'3603798f135d5f788659eb5f6d483be14766fa7ae84a74fc585bb1316c57148d',
    'postflight.json':'c9224a37218691d0893624fcfea5412d629fecc26262442474ef42b9d917b1a2',
    'script_identity.json':'97d569754219949bf7c024bdb2fb9aa5f03632cada208cab2ce26aa8c4547000'}

def preflight():
    result=diagnostic.preflight()
    for filename,digest in EVIDENCE.items():
        assert hashlib.sha256((DG/filename).read_bytes()).hexdigest()==digest,'Object evidence changed'
    fields=base.read(DG/'object_fields.json')
    assert fields['valid'] is True and fields['worker_count']==1 and fields['termination_flag']==1
    assert fields['worker_pids']==[CHILD]
    child=base.proc(CHILD)
    assert child and child['start']==CHILD_START and child['state']=='Z' and child['ppid']==base.GUARD
    assert child['pgid']==child['sid']==3583000 and child['tracer_pid']==0
    stat=Path(f'/proc/{CHILD}/stat').read_text().rsplit(')',1)[1].split()
    assert int(stat[49])==0,'Original zombie exit status must remain zero'
    result['exact_child']=child
    result['guard_native_location']=native.location(base.GUARD)
    assert result['guard_native_location']['bias']==0x77f6f6600000
    result['scope']='One native wait4(exact child,NULL,WNOHANG,NULL); temporary 48 bytes in guard private libc RX page, exact restore; no Vivado attach/signal'
    return result

def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--execute',action='store_true');args=parser.parse_args()
    diagnostic.policy();before=preflight()
    if not args.execute:
        print(json.dumps(dict(mode='plan_only_no_attach',preflight=before,dependencies=EXPECTED,
                   temporary_guard_bytes=48,stub_bytes=44,stub_hex=native.stub(CHILD,base.GUARD).hex(),
                   expected_padding_bytes='48 zero bytes; actual target bytes checked only by administrator snapshot',
                   maintenance_deadline_seconds=4,heartbeat_writes=False,future_guard_prevention_ready=True)))
        return
    assert os.geteuid()==0,'Administrator execution required; no sudo is invoked'
    out=base.DEST/(dt.datetime.now(dt.timezone.utc).strftime('RC_EXACT_%Y%m%dT%H%M%SZ_')+uuid.uuid4().hex[:8])
    out.mkdir(mode=0o750)
    try:
        maintenance.dump(out/'preflight.json',before)
        identity=dict(path=str(Path(__file__).resolve()),sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),dependencies=EXPECTED,object_evidence=EVIDENCE)
        maintenance.dump(out/'script_identity.json',identity)
        frozen=out/'frozen';frozen.mkdir()
        for filename in ['guard_selfstop_native_d38.py','guard_reap_maintenance_d38.py','handoff_guard_d38.py']:
            shutil.copyfile(HERE/filename,frozen/filename)
            assert hashlib.sha256((frozen/filename).read_bytes()).hexdigest()==EXPECTED[filename]
        # Journal is durable before monitor pause or any guard text/register write.
        journal=native.snapshot(base.GUARD,base.GUARD_START,CHILD,CHILD_START)
        maintenance.dump(out/'journal.json',journal)
        c=base.read(base.HANDOFF/'config.json')
        c.update(maintenance_output=str(out),handoff=str(base.HANDOFF),known=base.read(base.HANDOFF/'heartbeat.json')['known'],
                 monitor=dict(pid=before['supervisors']['monitor']['pid'],start=before['supervisors']['monitor']['start']),
                 watchdog=dict(pid=before['supervisors']['watchdog']['pid'],start=before['supervisors']['watchdog']['start']),
                 observer=dict(pid=before['supervisors']['observer']['pid'],start=before['supervisors']['observer']['start']))
        maintenance.dump(out/'maintenance_config.json',c)
        env=os.environ.copy();env.update(D38_PROJECT_ROOT=str(base.ROOT),PYTHONUNBUFFERED='1')
        argv=[sys.executable,str(frozen/'guard_reap_maintenance_d38.py'),'--run',str(out/'maintenance_config.json')]
        begun=time.monotonic()
        with (out/'coordinator.stdout').open('w') as stdout,(out/'coordinator.stderr').open('w') as stderr:
            completed=subprocess.run(argv,env=env,stdin=subprocess.DEVNULL,stdout=stdout,stderr=stderr,timeout=7)
        result=base.read(out/'result.json') if (out/'result.json').exists() else {}
        restore=base.read(out/'restoration.json') if (out/'restoration.json').exists() else {}
        raw=base.read(out/'native_result.json') if (out/'native_result.json').exists() else {}
        after=dict(guard=base.proc(base.GUARD),vivado=base.proc(base.TARGET),original_child=base.proc(CHILD),elapsed_seconds=time.monotonic()-begun,
                   coordinator_exit=completed.returncode,result=result,restoration=restore,native_result=raw)
        maintenance.dump(out/'postflight.json',after)
        assert completed.returncode==0 and result.get('PASS') is True and result.get('unified_deadline_met') is True
        assert restore.get('full_registers_and_48_bytes_verified') is True and raw.get('wait4_return')==CHILD
        assert restore['guard']['start']==base.GUARD_START and restore['guard']['state']=='T' and restore['guard']['tracer']==0
        assert after['original_child'] is None or after['original_child']['start']!=CHILD_START
        print(json.dumps(dict(output=str(out),exact_child_reaped=CHILD,guard_T_at_handoff=True,current_guard_observation=after['guard'],registers_and_48_bytes_restored=True,
                              maintenance_seconds=result['unified_maintenance_elapsed_seconds'],monitor_resumed=True,
                              scope='Recovery action only; hardware completion/resource/timing remain unassessed')))
    except BaseException as exc:
        helpers={}
        for role,filename in [('worker','worker_identity.json'),('tracer','tracer_identity.json')]:
            if (out/filename).exists():
                item=base.read(out/filename);helpers[role]=dict(recorded=item,current=base.proc(item['pid']))
        maintenance.dump(out/'error.json',dict(utc=base.now(),error=repr(exc),coordinator_timeout=isinstance(exc,subprocess.TimeoutExpired),
              guard=base.proc(base.GUARD),vivado=base.proc(base.TARGET),monitor=base.proc(before['supervisors']['monitor']['pid']),helpers=helpers,
              restoration=base.read(out/'restoration.json') if (out/'restoration.json').exists() else None,
              failed_closed=base.read(out/'failed_closed.json') if (out/'failed_closed.json').exists() else None,
              boundary='Seven-second timeout kills only the newly launched coordinator. The separately launched worker retains its own four-second deadline; arbitrary OS/filesystem stalls are not a real-time guarantee. Do not CONT original guard. Inspect helper identities, restoration/failed_closed/monitor state. No second wait4 or recovery retry is performed.'))
        raise
    finally:base.permissions(out)

if __name__=='__main__':main()
