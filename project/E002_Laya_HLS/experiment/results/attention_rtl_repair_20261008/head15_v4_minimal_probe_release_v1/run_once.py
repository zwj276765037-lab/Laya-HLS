#!/usr/bin/env python3
import json,sys,hashlib,subprocess,time,os,re
from pathlib import Path
mode,manifest,recipe=sys.argv[1:4]
for row in json.loads(Path(manifest).read_text()):
 p=Path(row['path']);h=hashlib.sha256()
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1048576),b''):h.update(b)
 if p.stat().st_size!=row['bytes'] or h.hexdigest()!=row['sha256']:raise ValueError('input drift: '+str(p))
if mode=='check':print('HEAD15_V4_PROBE_BINDINGS_OK');raise SystemExit(0)
if mode!='run':raise ValueError('bad mode')
r=json.loads(Path(recipe).read_text());work=Path(r['work'])
if work.exists():raise ValueError('fresh work required')
work.mkdir(parents=True);actual=[]
for stage in r['stages']:
 start=time.monotonic()
 with (work/(stage['stage']+'_stdout_stderr.log')).open('wb') as out:
  p=subprocess.run(stage['argv'],cwd=work,stdout=out,stderr=subprocess.STDOUT)
 row={**stage,'process_exit_code':p.returncode,'elapsed_seconds':time.monotonic()-start}
 effective=p.returncode
 if stage['stage']=='xsim':
  log=(work/'xsim_probe.log').read_text(errors='replace') if (work/'xsim_probe.log').exists() else ''
  row['fatal_lines']=re.findall(r'^Fatal:.*$',log,re.M)
  row['pass_marker_count']=len(re.findall(r'^ATT_PROBE_PASS phases=4 ports=7 cycles=5$',log,re.M))
  if row['fatal_lines'] or row['pass_marker_count']!=1:effective=effective or 1
 row['effective_exit_code']=effective;actual.append(row)
 (work/'stage_results.json').write_text(json.dumps(actual,indent=2)+'\n')
 if effective:raise SystemExit(effective)
print('HEAD15_V4_MINIMAL_PROBE_COMPLETE_NO_DUT')
