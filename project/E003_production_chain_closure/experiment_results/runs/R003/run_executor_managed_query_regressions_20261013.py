#!/usr/bin/env python3
"""Serial affected regressions. Every entry keeps its own immutable guard/receipt."""
import json,subprocess,sys
from pathlib import Path
P=Path('/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS')
E=P/'project/E002_Laya_HLS/experiment';R=P/'project/E003_production_chain_closure/experiment_results/runs/R003'
T=E/'vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb'
C=R/'executor_handoff_shell_rtl_04/fixture'
plan=[
 ('executor_handoff_portal_rtl_09','run_executor_handoff_portal_rtl.py',['--control-fixture',str(C),'--query-case','4']),
 ('executor_handoff_portal_rtl_10','run_executor_handoff_portal_rtl.py',['--control-fixture',str(C)]),
 ('executor_handoff_shell_rtl_05','run_executor_handoff_shell_rtl.py',['--helper-attempt',str(R/'executor_handoff_shell_helper_host_02')]),
 ('executor_checkpoint_rtl_08','run_executor_checkpoint_rtl.py',[]),
 ('bootstrap_source_guard_rtl_10','run_bootstrap_source_guard.py',[]),
 ('generated_store_monitor_rtl_16','run_generated_store_monitor.py',[]),
 ('executor_managed_query_decode_host_01','run_executor_managed_query_decode.py',['--rtl-attempts',*[str(R/name) for name in ['executor_handoff_portal_rtl_06','executor_handoff_portal_rtl_07','executor_handoff_portal_rtl_08']]])]
state={'schema':1,'serial':True,'entries':[]}
for name,runner,arguments in plan:
    command=[sys.executable,str(T/runner),'--attempt',str(R/name),*arguments]
    print('MANAGED_QUERY_REGRESSION_START '+name,flush=True)
    result=subprocess.run(command,cwd=E)
    state['entries'].append({'attempt':name,'command':command,'runner_exit_code':result.returncode})
    (R/'executor_managed_query_regression_commands_20261013.json').write_text(json.dumps(state,indent=2)+'\n')
    if result.returncode:sys.exit(result.returncode)
print('MANAGED_QUERY_REGRESSIONS_COMPLETED',flush=True)
