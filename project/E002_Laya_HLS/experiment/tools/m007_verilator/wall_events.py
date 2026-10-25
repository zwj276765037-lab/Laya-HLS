#!/usr/bin/env python3
"""Forward original RTL output unchanged and append real event timestamps."""
import argparse,json,resource,subprocess,time
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--events',type=Path,required=True);p.add_argument('cmd',nargs=argparse.REMAINDER);a=p.parse_args();assert a.cmd[0]=='--';start=time.monotonic();child=subprocess.Popen(a.cmd[1:],stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,bufsize=1);first_stdout_threads=None
with a.events.open('x') as events:
 for line in child.stdout:
  if first_stdout_threads is None:
   try:first_stdout_threads=len(list(Path('/proc',str(child.pid),'task').iterdir()))
   except OSError:first_stdout_threads='UNKNOWN'
  stamp=time.monotonic()-start;print(line,end='',flush=True)
  if line.startswith(('M007_','JOINT','HARDWARE_AGENT_SIM_PASS','%Error')):
   events.write(json.dumps({'line':line.rstrip('\n'),'elapsed_s':stamp})+'\n');events.flush()
rc=child.wait()
usage=resource.getrusage(resource.RUSAGE_CHILDREN)
a.events.with_name(a.events.stem+'.process.json').write_text(json.dumps({'raw_child_return_code':rc,'terminating_signal':-rc if rc<0 else None,'elapsed_seconds':time.monotonic()-start,'child_cpu_user_seconds':usage.ru_utime,'child_cpu_system_seconds':usage.ru_stime,'child_cpu_total_seconds':usage.ru_utime+usage.ru_stime,'observed_child_thread_count_at_first_stdout':first_stdout_threads,'child_maxrss_kb':usage.ru_maxrss,'CPU_basis':'waited child process getrusage(RUSAGE_CHILDREN), includes child threads; not inferred from wall time','RSS_limit_owner':'outer guard measures aggregate RSS'},indent=2)+'\n')
raise SystemExit(128-rc if rc<0 else rc)
