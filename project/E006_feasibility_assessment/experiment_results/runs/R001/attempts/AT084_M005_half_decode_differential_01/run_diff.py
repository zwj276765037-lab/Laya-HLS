from pathlib import Path
import hashlib,json,os,subprocess,time,resource
root=Path(__file__).resolve().parent
work=root/'work';work.mkdir(exist_ok=True)
binroot=Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin')
files=['old_eval.sv','new_eval.sv','half_decode_tb.sv']
inputs={name:{'bytes':(root/name).stat().st_size,'sha256':hashlib.sha256((root/name).read_bytes()).hexdigest()} for name in files}
(root/'run_inputs.json').write_text(json.dumps(inputs,indent=2)+'\n')
commands=[
 ('compile',[str(binroot/'xvlog'),'-sv','-work','work',*[str(root/name) for name in files]],120),
 ('elaborate',[str(binroot/'xelab'),'--debug','typical','-s','half_decode_tb_behav','half_decode_tb'],120),
 ('simulate',[str(binroot/'xsim'),'half_decode_tb_behav','-runall'],120),
]
results=[]
for label,argv,cap in commands:
    if int(Path('/proc/meminfo').read_text().split('MemAvailable:')[1].split()[0])<=201326592:
        raise RuntimeError('MemAvailable <=192GiB')
    cmd=['ionice','-c','3','nice','-n','19',*argv]
    before=resource.getrusage(resource.RUSAGE_CHILDREN)
    started=time.monotonic()
    with (root/f'{label}.log').open('w') as log:
      try:
        proc=subprocess.run(cmd,cwd=work,stdout=log,stderr=subprocess.STDOUT,timeout=cap,
             preexec_fn=lambda:os.sched_setaffinity(0,{0,1,2,3}))
        code=proc.returncode;timed_out=False
      except subprocess.TimeoutExpired:
        code=None;timed_out=True
    after=resource.getrusage(resource.RUSAGE_CHILDREN)
    item={'stage':label,'argv':cmd,'elapsed_seconds':time.monotonic()-started,
      'child_exit_code':code,'timed_out':timed_out,'cpu_affinity':[0,1,2,3],
      'nice':19,'ionice':'idle','child_maxrss_kib':after.ru_maxrss,
      'child_user_cpu_seconds_delta':after.ru_utime-before.ru_utime,
      'child_system_cpu_seconds_delta':after.ru_stime-before.ru_stime}
    results.append(item)
    (root/'run_result.json').write_text(json.dumps({'stages':results},indent=2)+'\n')
    if timed_out or code!=0:raise SystemExit(1)
print(json.dumps({'stages':results},indent=2))
