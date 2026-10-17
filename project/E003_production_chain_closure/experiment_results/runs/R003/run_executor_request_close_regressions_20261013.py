#!/usr/bin/env python3
"""Affected compatibility only, one immutable guarded tool at a time."""
import json,subprocess,sys
from pathlib import Path
P=Path('/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS')
E=P/'project/E002_Laya_HLS/experiment';R=P/'project/E003_production_chain_closure/experiment_results/runs/R003'
T=E/'vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb'
C=R/'executor_request_close_shell_rtl_02/fixture'
plan=[('executor_actor_host_07','run_executor_actor_host.py',[]),
 ('executor_handoff_portal_rtl_11','run_executor_handoff_portal_rtl.py',['--control-fixture',str(C)]),
 ('executor_handoff_portal_rtl_12','run_executor_handoff_portal_rtl.py',['--control-fixture',str(C),'--query-case','1'])]
state={'schema':1,'serial':True,'entries':[]}
for name,runner,args in plan:
 command=[sys.executable,str(T/runner),'--attempt',str(R/name),*args]
 print('REQUEST_CLOSE_COMPAT_START '+name,flush=True)
 result=subprocess.run(command,cwd=E)
 state['entries'].append({'attempt':name,'command':command,'runner_exit_code':result.returncode})
 (R/'executor_request_close_regression_commands_20261013.json').write_text(json.dumps(state,indent=2)+'\n')
 if result.returncode:sys.exit(result.returncode)
print('REQUEST_CLOSE_COMPAT_COMPLETED',flush=True)
