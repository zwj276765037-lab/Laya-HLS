#!/usr/bin/env python3
"""Final affected identities, serial guarded execution."""
import json,subprocess,sys
from pathlib import Path
P=Path('/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS')
E=P/'project/E002_Laya_HLS/experiment';R=P/'project/E003_production_chain_closure/experiment_results/runs/R003'
T=E/'vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb'
C=R/'executor_request_close_shell_rtl_03/fixture'
plan=[('executor_request_close_host_05','run_executor_actor_host.py',['--request-close','--closed-rtl-attempt',str(R/'executor_request_close_shell_rtl_03')]),
 ('executor_handoff_portal_rtl_13','run_executor_handoff_portal_rtl.py',['--control-fixture',str(C)]),
 ('executor_handoff_portal_rtl_14','run_executor_handoff_portal_rtl.py',['--control-fixture',str(C),'--query-case','1'])]
state={'schema':1,'serial':True,'entries':[]}
for name,runner,args in plan:
 command=[sys.executable,str(T/runner),'--attempt',str(R/name),*args]
 print('REQUEST_CLOSE_FINAL_START '+name,flush=True)
 result=subprocess.run(command,cwd=E)
 state['entries'].append({'attempt':name,'command':command,'runner_exit_code':result.returncode})
 (R/'executor_request_close_final_commands_20261013.json').write_text(json.dumps(state,indent=2)+'\n')
 if result.returncode:sys.exit(result.returncode)
print('REQUEST_CLOSE_FINAL_COMPLETED',flush=True)
