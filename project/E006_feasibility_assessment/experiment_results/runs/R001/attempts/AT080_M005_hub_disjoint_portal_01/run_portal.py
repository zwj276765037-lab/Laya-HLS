from pathlib import Path
import json,os,signal,subprocess,time
root=Path(__file__).resolve().parent
work=root/'work';work.mkdir(exist_ok=True)
mem_avail=int(Path('/proc/meminfo').read_text().split('MemAvailable:')[1].split()[0])
if mem_avail<=201326592:raise RuntimeError('MemAvailable <=192GiB')
exe='/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado'
tcl=root/'frozen/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/run_generated_provenance_portal.tcl'
cmd=['ionice','-c','3','nice','-n','19',exe,'-mode','batch','-notrace','-log',str(root/'vivado.log'),'-journal',str(root/'vivado.jou'),'-source',str(tcl),'-tclargs',str(work),str(root/'frozen'),str(root/'fixture')]
started=time.monotonic();status='running';peak=0
with (root/'driver.log').open('w') as log:
 p=subprocess.Popen(cmd,cwd=work,stdout=log,stderr=subprocess.STDOUT,start_new_session=True,
     preexec_fn=lambda:os.sched_setaffinity(0,{0,1,2,3}))
 (root/'launch.json').write_text(json.dumps({'pid':p.pid,'argv':cmd,'cpu_affinity':[0,1,2,3],'nice':19,'ionice':'idle','mem_available_kib_before':mem_avail},indent=2)+'\n')
 while p.poll() is None:
  if time.monotonic()-started>=120:status='timeout';os.killpg(p.pid,signal.SIGKILL);break
  rss=0
  for q in Path('/proc').glob('[0-9]*'):
   try:
    st=(q/'stat').read_text().split();pid=int(st[0]);pgid=int(st[4]);
    if pgid!=p.pid:continue
    for line in (q/'status').read_text().splitlines():
     if line.startswith('VmRSS:'):rss+=int(line.split()[1]);break
   except (OSError,ValueError,IndexError):pass
  peak=max(peak,rss)
  if rss>8*1024*1024:status='rss_limit';os.killpg(p.pid,signal.SIGKILL);break
  time.sleep(.25)
 code=p.wait()
result={'elapsed_seconds':time.monotonic()-started,'child_exit_code':code,'stop_reason':status,'peak_owned_rss_kib_sampled':peak}
(root/'run_result.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result))
if status!='running' or code!=0:raise SystemExit(1)
