#!/usr/bin/env python3
"""Host unit checks of guard parser/timers; these are not DUT simulation runs."""
import argparse,importlib.util,json,os
from pathlib import Path
def main():
 p=argparse.ArgumentParser();p.add_argument('--guard',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();o=a.output;o.mkdir(parents=True,exist_ok=False)
 spec=importlib.util.spec_from_file_location('checked_guard',a.guard);g=importlib.util.module_from_spec(spec);spec.loader.exec_module(g)
 checks=[]
 for path in(a.guard,a.guard.with_name('m007_tanh_lane_run.py'),a.guard.with_name('m007_tanh_cost_plan.py')):compile(path.read_text(),str(path),'exec');checks.append('syntax:'+path.name)
 f=o/'unit_progress.jsonl';s=g.SemanticProgress(f,0.)
 assert not s.stalled(119.999)and s.stalled(120.);checks.append('initial_120s_stall_boundary')
 f.write_text('');os.utime(f,None);s.sample(119.);assert s.last==0. and s.stalled(120.);checks.append('mtime_and_empty_file_do_not_advance')
 valid={'schema':'m007-tanh-consumed-v1','checked':4096,'node_checks':172032,'cycle':4249,'phase':1,'returned':4096}
 f.write_text(json.dumps(valid));s.sample(119.);assert s.last==0.;checks.append('partial_record_does_not_advance')
 with f.open('a')as out:out.write('\n')
 s.sample(119.);assert s.last==119. and not s.stalled(238.999)and s.stalled(239.);checks.append('strict_counter_advance_renews_exact_120s')
 with f.open('a')as out:out.write(json.dumps(valid)+'\n')
 try:s.sample(200.);raise AssertionError('duplicate accepted')
 except g.SemanticObserverError:pass
 assert s.last==119.;checks.append('duplicate_does_not_renew')
 for field,value in(('schema','heartbeat'),('checked',4095),('cycle',4248),('node_checks',0),('phase',3)):
  t=o/('invalid_'+field+'.jsonl');z=g.SemanticProgress(t,0.);t.write_text(json.dumps(valid)+'\n');z.sample(1.)
  bad=dict(valid,checked=8192,cycle=8345,node_checks=344064);bad[field]=value
  with t.open('a')as out:out.write(json.dumps(bad)+'\n')
  try:z.sample(50.);raise AssertionError('invalid event accepted')
  except g.SemanticObserverError:pass
  assert z.last==1.;checks.append('invalid_'+field+'_does_not_renew')
 f.write_text('')
 try:s.sample(201.);raise AssertionError('truncation accepted')
 except g.SemanticObserverError:pass
 checks.append('truncation_rejected')
 report={'status':'PASS','scope':'host parser/timer unit checks with injected event records and synthetic monotonic values; no DUT result or 120s real process-stall claim','checks':checks,'guard_working_sha256':g.sha(a.guard)}
 (o/'report.json').write_text(json.dumps(report,indent=2)+'\n');print('M007_SEMANTIC_GUARD_UNIT_PASS checks='+str(len(checks)),flush=True)
if __name__=='__main__':main()
