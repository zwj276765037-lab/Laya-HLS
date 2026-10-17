#!/usr/bin/env python3
from pathlib import Path
import os,re,subprocess,sys
os.environ['SIM_VER_XSIM']='2025.2'
os.environ['GCC_VER_XSIM']='9.3.0'
command = ['/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/xsim', 'attention_service_tb_behav', '-tclbatch', '/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/compute_throughput_optimization_20261010/attempts/t5_attention_service_rtl_head128_01/work/run_all.tcl', '-log', '/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/compute_throughput_optimization_20261010/attempts/t5_attention_service_rtl_head128_01/work/simulate.log', '-wdb', '/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/compute_throughput_optimization_20261010/attempts/t5_attention_service_rtl_head128_01/work/attention_service_head128.wdb', '-testplusarg', 'FIXTURE=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/compute_throughput_optimization_20261010/attempts/t5_attention_fixture_01/work/fixture', '-testplusarg', 'ROWS=128', '-testplusarg', 'PROTOCOL=1']
print('ATTENTION_SERVICE_RTL_BEGIN rows=128 compiled_snapshot_replay=1',flush=True)
rc=subprocess.call(command)
log=Path('/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/compute_throughput_optimization_20261010/attempts/t5_attention_service_rtl_head128_01/work/simulate.log')
data=log.read_text(errors='replace') if log.exists() else ''
marker='ATTENTION_SERVICE_RTL_PASS rows=128 keys128 D64'
if rc!=0 or marker not in data or re.search(r'(^|\n)(?:Fatal:|ERROR:)',data):
 print(f'ATTENTION_SERVICE_RTL_REPLAY_FAILED returncode={rc} exact_pass={marker in data}',flush=True)
 sys.exit(rc if rc else 1)
print('ATTENTION_SERVICE_RTL_END rows=128 exact_pass=1',flush=True)
