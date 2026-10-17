#!/usr/bin/env python3
"""Compile affected production numeric calls and independent service fixtures."""
import argparse,hashlib,json,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
MODULE=Path(__file__).resolve().parents[1]
ap=argparse.ArgumentParser();ap.add_argument('--work',type=Path,required=True);ap.add_argument('--quant-fixture',type=Path,required=True);ap.add_argument('--tm4-fixture',type=Path,required=True);args=ap.parse_args()
work=args.work.resolve();work.mkdir(parents=True,exist_ok=False)
flags=['-std=c++17','-O2','-fno-fast-math','-fno-associative-math','-ffp-contract=off','-I'+str(ROOT/'include'),'-I'+str(ROOT/'tests')]
def run(name,sources,env=None):
 import os
 out=work/name
 subprocess.run(['/usr/bin/g++',*flags,*map(str,sources),'-o',str(out)],check=True,cwd=ROOT)
 print('ACT_BLACKBOX_CPU_COMPILED name='+name,flush=True)
 subprocess.run([str(out)],check=True,cwd=ROOT,env=os.environ|dict(env or {}))
 print('ACT_BLACKBOX_CPU_CHECK_COMPLETE name='+name,flush=True)
common=ROOT/'hls/common/laya_numeric.cpp'
production=[common,ROOT/'hls/operators/activation_quantizer_compute.cpp',ROOT/'hls/operators/q8_linear_compute.cpp']
for module in ['activation_quantizer','q8_linear_and_restore']:
 run('production_'+module,production+[ROOT/'vivado/module_design'/module/'tb/numeric_tb.cpp'])
run('owned_seven_shapes',production+[MODULE/'tb/tm4_owned_shapes_tb.cpp'])
for name,fixture in [('quant',args.quant_fixture),('tm4',args.tm4_fixture)]:
 bb=MODULE/'source/blackbox'
 run(name+'_fixture',[common,bb/('laya_'+name+'_group_service.cpp'),bb/('laya_'+name+'_blackbox_smoke.cpp'),MODULE/'tb'/(name+'_blackbox_csim_tb.cpp')],{'LAYA_'+name.upper()+'_FIXTURE':str(fixture.resolve())})
print('ACT_PRODUCTION_BLACKBOX_CPU_PASS affected_numeric=2 independent_services=2',flush=True)
