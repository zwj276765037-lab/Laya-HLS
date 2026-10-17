#!/usr/bin/env python3
"""Collect real tile terminal/guard/profile evidence without modifying logs."""
from pathlib import Path
import argparse,hashlib,json,re
def rec(p):
 b=p.read_bytes();return dict(path=str(p.resolve()),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
p=argparse.ArgumentParser();p.add_argument('attempt',type=Path);p.add_argument('run');p.add_argument('--guard',required=True);p.add_argument('--manifest',required=True);p.add_argument('--rows',type=int,required=True);args=p.parse_args()
a=args.attempt.resolve();w=a/args.run;log=(w/'simulate.log').read_text();g=json.loads((a/args.guard/'guard_result.json').read_text());manifest=a/args.manifest
assert g['child_exit_code']==0 and g['trigger'] is None
assert not re.search(r'(^|\n)(Fatal:|ERROR:)',log)
marker=next(x for x in log.splitlines() if x.startswith(f'ATTENTION_SERVICE_TILE_RTL_PASS rows={args.rows} keys128 D64 '))
def fields(line):return {k:int(v) for k,v in re.findall(r'(\w+)=(\d+)',line)}
values=fields(marker)
for key,per in [('M',16640),('A',16767),('D',128),('products',8192),('trees',8064),('av_steps',8192),('exp',128)]:assert values[key]==args.rows*per,(key,values[key])
runs=[fields(x) for x in log.splitlines() if x.startswith('ATTENTION_SERVICE_TILE_RUN_PROFILE ')]
assert len(runs)==3*((args.rows+15)//16)
normal={name:sum(x['normal_cycles'] for x in runs if x['cmd']==cmd) for name,cmd in [('QK',19),('SM',20),('AV',21)]}
assert normal==dict(QK=values['qk'],SM=values['sm'],AV=values['av'])
profiles=[fields(x) for x in log.splitlines() if x.startswith('ATTENTION_SERVICE_TILE_PROFILE ')]
exp=[fields(x) for x in log.splitlines() if x.startswith('ATTENTION_SERVICE_TILE_EXP_PROFILE ')]
assert sum(x['count'] for x in exp)==args.rows*128
runtime=json.loads((w/'input_manifest.json').read_text())
tile_profiles=[fields(x) for x in log.splitlines() if x.startswith('ATTENTION_SERVICE_TILE_PASS ')]
ledger=fields(next(x for x in log.splitlines() if x.startswith('ATTENTION_SERVICE_TILE_LEDGER_PASS ')))
assert ledger['accepted']==ledger['retired']+ledger['cancelled']
cases=[fields(x) for x in log.splitlines() if x.startswith('ATTENTION_SERVICE_TILE_FIRST_ERROR_CASE_PASS ')]
ce=sorted(set(int(x) for x in re.findall(r'ATTENTION_SERVICE_TILE_CE_PASS kind=(\d+)',log)))
resets=sorted(set(int(x) for x in re.findall(r'ATTENTION_SERVICE_TILE_RESET_PASS kind=(\d+)',log)))
if runtime['protocol']:
 assert [(x['kind'],x['bad_element'],x['prior_row_scores']) for x in cases]==[(0,323,64),(1,63,0),(2,63,0),(3,7,0),(4,63,960),(5,4095,64)]
 assert ce==[0,1,2,3]
 assert 'ATTENTION_SERVICE_TILE_FIRST_ERROR_RESET_PASS reset_preempted_ce=1' in log
 if args.manifest=='source_manifest_v10.json':
  assert resets==[0,1,2,3]
 else:
  assert resets==[0,1,2,3,4,5]
  for marker in ('ATTENTION_SERVICE_TILE_PROTOCOL_PASS resets=6 wrong_epoch_row=1 prefetch_pending_ready=1',
                 'ATTENTION_SERVICE_TILE_PREFETCH_CE_PASS kind=4 pending=1 ready=0',
                 'ATTENTION_SERVICE_TILE_PREFETCH_CE_PASS kind=5 pending=0 ready=4',
                 'ATTENTION_SERVICE_TILE_PREFETCH_RESET_PASS kind=4',
                 'ATTENTION_SERVICE_TILE_PREFETCH_RESET_PASS kind=5'):
   assert marker in log,marker
body=dict(schema='attention-tile-rtl-numeric-profile-result-v1',status='PASS',scope=f'Real enc0/head0/B1/S128 queries0..{args.rows-1}, full D64/K128, original independent basic/intermediate/final bit checks; one continuous process',
 source_manifest=str(manifest),source_manifest_sha256=rec(manifest)['sha256'],source_identity=rec(manifest),guard=g,raw_log=rec(w/'simulate.log'),runtime_manifest=rec(w/'input_manifest.json'),
 terminal=values,normal_command_cycles=normal,normal_compute_cycles=sum(normal.values()),normal_runs=runs,enabled_state_profiles=profiles,exp_actual_launch_done_enabled_gaps=exp,
 collector=rec(Path(__file__).resolve()),tile_terminal_profiles=tile_profiles,call_ledger=ledger,protocol_enabled=runtime['protocol'],first_error_cases=cases,real_CE_active_kinds=ce,real_reset_active_kinds=resets,
 measurement_convention='Normal command counter includes the accepted launch edge and ends at true done, excludes deliberate CE pauses/rejected calls/reset work. Enabled state profile excludes the launch edge; wait fields are no-issue edges and include idle arithmetic modes, not all credit stalls.',
 actual_launch_to_done_edge_intervals={name:normal[name]-len(runs)//3 for name in normal},
 limitations='No production caller/physical BO writer/last-B time, B2/new-shape numerical proof, complete accelerator fit or P&R/realized frequency claim.')
(w/'numeric_result.json').write_text(json.dumps(body,indent=2)+'\n')
print('ATTENTION_SERVICE_TILE_RECEIPT_PASS rows='+str(args.rows)+' normal_compute_cycles='+str(sum(normal.values())))
