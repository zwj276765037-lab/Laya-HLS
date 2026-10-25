#!/usr/bin/env python3
"""Record one real g++ invocation without changing its arguments or result."""
import argparse,datetime as dt,json,os,resource,subprocess,sys,time
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--records',required=True,type=Path);a,argv=p.parse_known_args()
if argv and argv[0]=='--':argv=argv[1:]
if not argv:raise SystemExit('compiler arguments required')
a.records.mkdir(parents=True,exist_ok=True);start=time.monotonic();utc=dt.datetime.now(dt.timezone.utc).isoformat();record=a.records/(str(time.time_ns())+'_'+str(os.getpid())+'.json');cmd=['/usr/bin/g++',*argv]
x={'started_at':utc,'wrapper_pid':os.getpid(),'wrapper_start_ticks':Path('/proc/self/stat').read_text().split()[21],'argv':cmd,'cwd':str(Path.cwd()),'kind':'compile' if '-c' in argv else 'link_or_probe','source_arguments':[s for s in argv if s.endswith(('.cpp','.cc','.cxx'))],'state':'RUNNING','unit_resource_note':'ru_maxrss is maximum child-process RSS, not aggregate concurrent RSS; outer guard owns aggregate limit'}
record.write_text(json.dumps(x,indent=2)+'\n');print('M007_CXX_UNIT_BEGIN record='+str(record),flush=True)
try:
 child=subprocess.Popen(cmd);x['compiler_pid']=child.pid
 try:x['compiler_start_ticks']=Path('/proc/'+str(child.pid)+'/stat').read_text().split()[21]
 except OSError:x['compiler_start_ticks']='UNKNOWN'
 rc=child.wait()
except Exception as exc:
 x['exception']=repr(exc);rc=125
x.update({'finished_at':dt.datetime.now(dt.timezone.utc).isoformat(),'elapsed_seconds':time.monotonic()-start,'exit_code':rc,'state':'COMPLETE' if rc==0 else 'FAIL'});usage=resource.getrusage(resource.RUSAGE_CHILDREN);x['child_cpu_user_seconds']=usage.ru_utime;x['child_cpu_system_seconds']=usage.ru_stime;x['child_maxrss_kb']=usage.ru_maxrss;record.write_text(json.dumps(x,indent=2)+'\n');print('M007_CXX_UNIT_END record='+str(record)+' elapsed='+str(x['elapsed_seconds'])+' exit='+str(rc),flush=True);raise SystemExit(rc)
