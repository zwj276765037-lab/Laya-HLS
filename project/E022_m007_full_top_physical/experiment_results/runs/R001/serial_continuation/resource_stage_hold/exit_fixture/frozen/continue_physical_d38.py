#!/usr/bin/env python3
"""Serial, no-retry continuation of the actual AT019 physical experiment.

This driver waits for the existing run; it never launches or repeats core_synth.
Stage PASS means tool execution only. Full hardware acceptance remains reviewed.
"""
import argparse
import fcntl
import hashlib
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import time

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[6]
RUN=ROOT/'project/E022_m007_full_top_physical/experiment_results/runs/R001'
OUT=RUN/'serial_continuation'
CORE=RUN/'attempts/AT019_core_synth'
HANDOFF=CORE/'unlimited_wall_handoff'
SCRIPTS=Path('/home/zwj/.codex/skills/research-agent/scripts')
STAGES=['report_core','facade_synth','facade_link','resident_synth','parent_synth',
        'full_link','report_full','opt','place','report_place','phys_opt','route','report_route']
sys.path.insert(0,str(HERE))
import handoff_guard_d38 as h
import run_physical_d38 as runner

def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def rel(p):return str(Path(p).relative_to(ROOT))

class Continuation:
 def __init__(self):
  self.records=[];self.requested_stop=False;self.child=None
  self.state={'schema':'m007-d38-serial-continuation-v1','started_utc':h.now(),
              'pid':os.getpid(),'start_time_ticks':h.owned.process_start(os.getpid()),
              'execution_state':'running','phase':'waiting_existing_AT019','plan':STAGES,
              'current_attempt':str(CORE),'completed_stages':self.records,
              'no_core_retry':True,'wall_time_limit_disabled_categories':sorted(runner.UNLIMITED_WALL_CATEGORIES),
              'not_a_hardware_acceptance':True}
  self.base=h.read(RUN/'publication_AT019_unlimited_active.json')
 def save(self,**changes):
  self.state.update(changes);self.state['updated_utc']=h.now();h.dump(OUT/'state.json',self.state)
 def event(self,name,**data):
  value={'event':name,'utc':h.now(),**data}
  with (OUT/'events.jsonl').open('a')as f:f.write(json.dumps(value)+'\n')
  print(json.dumps(value),flush=True)
 def stop(self,signum,frame):
  self.requested_stop=True
  if self.child is not None and self.child.poll()is None:
   # This PID is the exact Python guard launched by this driver.
   self.child.send_signal(signal.SIGTERM)
 def publish(self,stage,attempt,state='running',note=''):
  evidence=list(self.base['evidence'])+[rel(OUT/'state.json')]
  for record in self.records:
   if record.get('receipt'):evidence.append(rel(record['receipt']))
   for name in ['utilization.rpt','utilization_hierarchical.rpt','ram_utilization.rpt','timing_summary.rpt','check_timing.rpt','netlist_checks.tsv','route_status.rpt','drc.rpt']:
    report=Path(record['attempt'])/'reports'/name
    if report.exists():evidence.append(rel(report))
  if attempt:
   for name in ['command.json','launch.json','receipt.json']:
    p=Path(attempt)/name
    if p.exists():evidence.append(rel(p))
  table='\n'.join('- '+x['stage']+': '+x['verdict']+', '+str(x['elapsed_seconds'])+' s; '+rel(x['receipt']) for x in self.records)
  status=('# E022 actual serial physical execution\n\nexecution_state: '+state+
          '\nverdict: unassessed\n\nCurrent stage: '+stage+'\nCurrent attempt: '+str(attempt)+
          '\n\n'+note+'\n\nPhysical synthesis/implementation/reports have explicit null single and cumulative wall limits. '
          '256 GiB owned RSS, MemAvailable>192 GiB, CPU0-3, nice19, idle IO, one heavy lock, '
          'one synthesis worker and the 300 s real CPU/file progress guard remain. '
          'No RTL, XDC, numeric, capacity or PS candidate change.\n\n'
          'Actual stage receipts:\n'+table+'\n\n'
          'Tool-stage completion does not establish resource fit or 300 MHz closure. '
          'Final complete linked resources and routed setup/hold/coverage reports require engineering review. '
          'No automatic retry. Controller owns two-hour user reports and timer shutdown.')
  payload={**self.base,'status':status,'execution_state':state,
           'results':'# E022 actual stage evidence\n\n'+table+'\n\n'+note+
           '\n\nAT015 remains historical COST_STOP/no DCP; original receipts/costs are retained. '
           'AT019 used the same f849 production sources with only core -no_timing_driven. '
           'Its current no-deadline handoff retained the original Vivado PID/start. '
           'Old rebuildable caches were removed under user authorization as recorded in cache_cleanup_controller_reference.json. '
           'No full hardware acceptance is inferred by this execution driver.',
           'verdict':'inconclusive'if state in ('blocked','failed','completed','paused')else'unassessed',
           'evidence':list(dict.fromkeys(evidence))}
  safe=stage.replace('/','_').replace(' ','_')
  p=OUT/(safe+'_'+state+'_publication.json');h.dump(p,payload)
  c={'execution_state':state,'current_task':stage,'stage':stage,'blocker':note if state in ('blocked','failed')else None,
     'next_step':'Review actual full resources and routed setup/hold/coverage'if state=='completed'else'Continue authorized real physical stages; stop on actual failure',
     'runtime_id':'/root/m007_weight_supply_engineering','thread_id':None}
  cp=OUT/(safe+'_'+state+'_console.json');h.dump(cp,c)
  for command in [[sys.executable,str(SCRIPTS/'research.py'),'publish','--root',str(ROOT),'--experiment','E022','--input',str(p)],
                  [sys.executable,str(SCRIPTS/'console.py'),'report','--root',str(ROOT),'--agent','A010','--input',str(cp)]]:
   result=subprocess.run(command,cwd=ROOT,capture_output=True,text=True)
   with (OUT/'publication.log').open('a')as f:f.write(result.stdout+result.stderr)
   if result.returncode:self.event('METADATA_PUBLICATION_FAILURE',stage=stage,returncode=result.returncode,output=result.stdout+result.stderr)
 def wait_existing(self):
  c=h.read(HANDOFF/'config.json')
  self.event('WAIT_EXISTING_AT019',core_attempt=str(CORE),same_vivado_pid=c['actual_vivado_pid'],same_vivado_start=c['actual_vivado_start'])
  while not (HANDOFF/'effective_receipt.json').exists():
   if self.requested_stop:raise InterruptedError('Continuation waiting cancelled; existing AT019 has not been signalled')
   if (HANDOFF/'handoff_end.json').exists():
    end=h.read(HANDOFF/'handoff_end.json')
    if end.get('reason'):raise RuntimeError('Existing core supervision ended with '+str(end['reason'])+'; no continuation launched')
   if h.state(c['monitor_pid'],c['monitor_start'])is None and not (HANDOFF/'effective_receipt.json').exists():
    raise RuntimeError('Existing core supervisor exited without effective receipt; no continuation launched')
   time.sleep(1)
  e=h.read(HANDOFF/'effective_receipt.json');raw=CORE/'receipt.json'
  assert sha(raw)==e['original_receipt_sha256'],'Original receipt byte identity mismatch'
  assert e['verdict']=='PASS'and e['source_verify_after']is True and not e['owned_after_cleanup'],e['verdict']
  assert e['wall_time_limit_disabled']is True and e['effective_maximum_seconds']is None
  assert e['source_identity']==runner.verify_inputs('core_synth'),'Actual source identity changed'
  watchdog=h.read(HANDOFF/'watchdog_ready.json');observer=h.read(HANDOFF/'observer/ready.json')
  supervisors=[(c['guard_pid'],c['guard_start']),(c['monitor_pid'],c['monitor_start']),
               (watchdog['pid'],watchdog['start']),(observer['pid'],observer['start'])]
  while any(h.owned.process_start(p)==s for p,s in supervisors):
   if self.requested_stop:raise InterruptedError('Continuation cancelled before next stage')
   time.sleep(.2)
  assert not h.lock_held(c['lock']),'Core lock still held'
  known={int(k):v for k,v in e['known_owned_identities'].items()}
  assert not h.owned.owned_processes(h.owned.process_table(),c['leader'],known),'Core owned cleanup incomplete'
  cp=RUN/'checkpoints/core_synth.dcp';meta=h.read(cp.with_suffix('.identity.json'))
  assert meta['produced_by']==str(CORE)and meta['checkpoint']['sha256']==sha(cp)
  assert meta['source_identity']==e['source_identity']
  self.records.append({'stage':'core_synth','attempt':str(CORE),'verdict':e['verdict'],'elapsed_seconds':e['elapsed_seconds'],'receipt':str(HANDOFF/'effective_receipt.json')})
  self.save(phase='core_actual_PASS')
  self.event('CORE_ACTUAL_PASS',checkpoint=str(cp),sha256=sha(cp),receipt=str(HANDOFF/'effective_receipt.json'))
  self.publish('core_synth complete',CORE,note='Actual core DCP verified; full-top resources and implementation remain pending.')
 def stage(self,stage):
  assert not self.requested_stop
  prior=set((RUN/'attempts').iterdir());attempt=None;published=False
  command=[sys.executable,str(HERE/'run_physical_d38.py'),'--stage',stage]
  with (OUT/(stage+'_driver.log')).open('w')as log:
   self.child=subprocess.Popen(command,cwd=ROOT,stdout=log,stderr=subprocess.STDOUT,start_new_session=True)
   guard={'pid':self.child.pid,'start_time_ticks':h.owned.process_start(self.child.pid),'argv':command}
   self.save(phase='launching_'+stage,current_stage=stage,current_guard=guard,current_attempt=None)
   while self.child.poll()is None:
    if attempt is None:
     fresh=[p for p in (RUN/'attempts').iterdir()if p not in prior and p.name.endswith('_'+stage)]
     assert len(fresh)<=1,'Multiple actual attempts for a single stage'
     if fresh:attempt=fresh[0]
    if attempt and (attempt/'launch.json').exists()and not published:
     self.save(phase='running_'+stage,current_attempt=str(attempt),current_launch=h.read(attempt/'launch.json'))
     self.event('ACTUAL_STAGE_LAUNCH',stage=stage,attempt=str(attempt),guard=guard,launch=h.read(attempt/'launch.json'))
     self.publish(stage,attempt,note='Actual tool stage running. No measured completion percentage is available.')
     published=True
    time.sleep(1)
   rc=self.child.wait();self.child=None
  if attempt is None:
   fresh=[p for p in (RUN/'attempts').iterdir()if p not in prior and p.name.endswith('_'+stage)]
   if len(fresh)==1:attempt=fresh[0]
  if not attempt or not (attempt/'receipt.json').exists():raise RuntimeError(stage+' exited '+str(rc)+' without a complete actual receipt; see '+str(OUT/(stage+'_driver.log')))
  receipt=h.read(attempt/'receipt.json')
  self.records.append({'stage':stage,'attempt':str(attempt),'verdict':receipt['verdict'],'elapsed_seconds':receipt['elapsed_seconds'],'receipt':str(attempt/'receipt.json')})
  self.save(phase='finished_'+stage,current_attempt=str(attempt),current_guard=None)
  self.event('ACTUAL_STAGE_COMPLETE',**self.records[-1],returncode=rc)
  assert rc==0 and receipt['verdict']=='PASS'and receipt['source_verify_after']is True and not receipt['owned_after_cleanup'],stage+' actual '+receipt['verdict']
  assert receipt['maximum_seconds']is None and receipt['wall_time_limit_disabled']is True
  self.publish(stage+' complete',attempt,note='Actual stage PASS is retained; final acceptance remains pending actual resources and timing review.')
 def run(self):
  OUT.mkdir(parents=True,exist_ok=True)
  self.save()
  try:
   self.wait_existing()
   for stage in STAGES:
    if self.requested_stop:raise InterruptedError('Continuation cancelled before next stage')
    self.stage(stage)
   self.save(execution_state='completed',phase='all_actual_stages_complete_pending_review')
   self.event('ALL_ACTUAL_STAGES_COMPLETE_REVIEW_PENDING')
   self.publish('physical execution complete',self.state.get('current_attempt'),'completed','All planned tool stages actually completed; resource fit, timing and coverage still require evidence review. Notify controller to stop two-hour timer.')
   return 0
  except (Exception,KeyboardInterrupt)as exc:
   if self.child is not None and self.child.poll()is None:
    self.event('OWNED_STAGE_GUARD_STOP_AFTER_DRIVER_EXCEPTION',pid=self.child.pid,reason=repr(exc))
    self.child.send_signal(signal.SIGTERM)
    self.child.wait()
    self.child=None
   state='paused'if self.requested_stop else'blocked'
   self.save(execution_state=state,phase='stopped_no_retry',error=repr(exc))
   self.event('CONTINUATION_STOPPED_NO_RETRY',reason=repr(exc),execution_state=state)
   # While waiting, cancellation does not change the existing core's state.
   if not (self.requested_stop and not self.records):
    self.publish('physical continuation stopped',self.state.get('current_attempt'),state,str(exc))
   return 3 if self.requested_stop else 1

def main():
 p=argparse.ArgumentParser();p.add_argument('--run',action='store_true');a=p.parse_args()
 if not a.run:
  print(json.dumps({'wait_existing':str(CORE),'stages':STAGES,'no_core_retry':True,'wall_time_limit_disabled_categories':sorted(runner.UNLIMITED_WALL_CATEGORIES)}));return 0
 os.sched_setaffinity(0,{0,1,2,3});os.nice(19);subprocess.run(['/usr/bin/ionice','-c','3','-p',str(os.getpid())],check=True,capture_output=True)
 with (ROOT/'.research-agent/d38_serial_continuation.lock').open('a+')as lock:
  fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
  assert not (OUT/'state.json').exists(),'Do not relaunch an existing continuation blindly'
  c=Continuation();signal.signal(signal.SIGTERM,c.stop);signal.signal(signal.SIGINT,c.stop)
  return c.run()

if __name__=='__main__':sys.exit(main())
