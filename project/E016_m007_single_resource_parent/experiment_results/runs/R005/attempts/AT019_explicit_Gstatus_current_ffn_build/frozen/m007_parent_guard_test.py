#!/usr/bin/env python3
"""Synthetic guard counterexamples only: no hardware/numerical run claim."""
import argparse,importlib.util,json,subprocess,sys,time
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--guard',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
spec=importlib.util.spec_from_file_location('parent_guard',a.guard);g=importlib.util.module_from_spec(spec);spec.loader.exec_module(g)
h=None
for line,ok in [('Completed arbitrary text',False),('M007_PARENT_CHECKED checked=4096 phase=QKV cycle=5',True),('M007_PARENT_CHECKED checked=4096 phase=QKV cycle=6',False),('M007_PARENT_CHECKED checked=4095 phase=QKV cycle=7',False),('M007_PARENT_CHECKED checked=8192 phase=QKV cycle=8',True)]:
 advanced,h=g.semantic_progress_advances(line,h,'rtl');assert advanced is ok,(line,advanced)
records=[]
for name in ['stall','duplicate_and_file_growth','real_checked_progress']:
 w=a.out/name;w.mkdir();child=w/'synthetic_child.py'
 code='import time\nfrom pathlib import Path\n'
 if name=='stall':code+='time.sleep(8)\n'
 elif name=='duplicate_and_file_growth':code+='for i in range(24):\n print("Completed generic heartbeat",flush=True)\n print("M007_PARENT_CHECKED checked=4096 phase=QKV cycle=1",flush=True)\n Path("growing_noise.bin").write_bytes(b"x"*(i+1)*1024)\n time.sleep(0.25)\n'
 else:code+='for i in range(12):\n print(f"M007_PARENT_CHECKED checked={(i+1)*4096} phase=QKV cycle={i+1}",flush=True)\n time.sleep(0.25)\n'
 child.write_text(code)
 command=[sys.executable,str(a.guard),'--out',str(w/'guard'),'--cwd',str(w),'--rss-gib','4','--timeout-seconds','12','--semantic-stall-seconds','2','--phase','rtl','--',sys.executable,str(child)]
 rc=subprocess.call(command);d=json.loads((w/'guard/guard_result.json').read_text());assert d['artifact_progress_enabled'] is False
 if name=='real_checked_progress':assert rc==0 and d['trigger'] is None and d['checked_highwater']==[49152,12]
 else:assert rc==1 and d['trigger']=='semantic_stall' and d['elapsed_seconds']<6
 records.append({'case':name,'command':command,'exit':rc,'result':d})
(a.out/'guard_contract_results.json').write_text(json.dumps({'scope':'Synthetic scaled2s tests; production stall remains120s','records':records},indent=2)+'\n')
print('M007_PARENT_GUARD_CONTRACT_PASS cases=3 duplicate_counter_and_file_growth_cannot_refresh=1 production_stall120_unchanged=1')
