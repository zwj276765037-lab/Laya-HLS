#!/usr/bin/env python3
"""One-time, exact-PID resource-stage hold; never signals an EDA/guard/group."""
from pathlib import Path
import datetime, hashlib, json, os, signal, time
ROOT=Path(__file__).resolve().parents[7]
OUT=Path(__file__).resolve().parent
R=OUT.parents[1]
SERIAL=(3603650,66216629)
GUARD=(109263,71064760)
WRAPPER=(109276,71064911)
def now(): return datetime.datetime.now(datetime.timezone.utc).isoformat()
def proc(pid):
 p=Path('/proc')/str(pid)
 try:
  raw=(p/'stat').read_text(); s=raw[raw.rfind(')')+2:].split()
  return {'pid':pid,'state':s[0],'ppid':int(s[1]),'pgid':int(s[2]),'sid':int(s[3]),'start_time_ticks':int(s[19]),'cmdline':(p/'cmdline').read_bytes().replace(b'\0',b' ').decode()}
 except FileNotFoundError: return None
def dump(name,v):
 p=OUT/name; tmp=p.with_suffix(p.suffix+'.tmp'); tmp.write_text(json.dumps(v,indent=2)+'\n'); tmp.replace(p)
assert not (OUT/'hold_receipt.json').exists(), 'Do not duplicate a completed signal action'
state_path=R/'serial_continuation/state.json'
state_bytes=state_path.read_bytes(); state=json.loads(state_bytes)
assert state['pid']==SERIAL[0] and state['start_time_ticks']==SERIAL[1]
assert state['current_stage']=='report_core' and state['current_guard']['pid']==GUARD[0]
assert state['current_guard']['start_time_ticks']==GUARD[1]
assert state['phase']=='running_report_core'
before={name:proc(pair[0]) for name,pair in [('serial',SERIAL),('guard',GUARD),('wrapper',WRAPPER)]}
for name,pair in [('serial',SERIAL),('guard',GUARD),('wrapper',WRAPPER)]:
 assert before[name] and before[name]['start_time_ticks']==pair[1], (name,before[name])
assert before['serial']['state'] not in ('T','t','Z','X')
assert before['guard']['ppid']==SERIAL[0] and before['guard']['sid']==GUARD[0]
assert before['wrapper']['ppid']==GUARD[0] and before['wrapper']['sid']==WRAPPER[0]
assert len({before[k]['sid'] for k in before})==3
assert not (R/'attempts/AT020_report_core/receipt.json').exists(), 'Stage already completed; re-evaluate before action'
receipt={'schema':'m007-d38-exact-serial-resource-stage-hold-v1','created_utc':now(),'reason':'Central review of actual synthesized core CLB LUT 2139515 (164.11% device; user full-kernel budget 900000), prevent automatic facade/parent/place successor. AT020 report_core continues without deadline.','authority':'Controller /root requested safe serial hold and then instructed to complete it after minimum viable SIGSTOP option was reported.','mechanism':'SIGSTOP to exact serial PID only via pidfd; no process group, guard, wrapper or tool signal.','source_sha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),'before':before,'canonical_state_before_sha256':hashlib.sha256(state_bytes).hexdigest(),'canonical_state_is_historical_snapshot':True,'publication_owner_while_held':'A010 engineering; serial cannot publish while T','resume_requires_controller_direction':True,'signal_sent':False,'not_a_hardware_acceptance':True}
dump('hold_preflight.json',receipt)
fd=os.pidfd_open(SERIAL[0],0)
try:
 matched=proc(SERIAL[0]); assert matched and matched['start_time_ticks']==SERIAL[1]
 signal.pidfd_send_signal(fd,signal.SIGSTOP,None,0)
 receipt['signal_sent']=True;receipt['signal_utc']=now()
finally: os.close(fd)
for _ in range(100):
 after=proc(SERIAL[0])
 if after and after['start_time_ticks']==SERIAL[1] and after['state']=='T': break
 time.sleep(.01)
else: raise AssertionError(('Exact serial did not enter T',after))
receipt['after']={name:proc(pair[0]) for name,pair in [('serial',SERIAL),('guard',GUARD),('wrapper',WRAPPER)]}
assert receipt['after']['guard'] and receipt['after']['guard']['start_time_ticks']==GUARD[1] and receipt['after']['guard']['state'] not in ('T','t','Z','X')
assert receipt['after']['wrapper'] and receipt['after']['wrapper']['start_time_ticks']==WRAPPER[1] and receipt['after']['wrapper']['state'] not in ('T','t','Z','X')
assert state_path.read_bytes()==state_bytes, 'Canonical state changed unexpectedly'
receipt['verified_utc']=now();receipt['serial_held']=True;receipt['at020_remains_running']=True;receipt['canonical_state_unchanged']=True
receipt['effective_execution_state']='report_core_running_successor_queue_held_for_resource_review'
dump('hold_receipt.json',receipt)
print(json.dumps(receipt,indent=2))
