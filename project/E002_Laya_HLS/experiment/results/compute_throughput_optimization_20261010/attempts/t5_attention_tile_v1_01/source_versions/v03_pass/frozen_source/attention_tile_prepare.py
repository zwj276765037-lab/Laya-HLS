#!/usr/bin/env python3
"""Freeze actual Attention tile inputs without changing canonical/exp sources."""
from pathlib import Path
import sys,json,hashlib,shutil
import numpy as np
P=Path(__file__).resolve().parents[4]
R=P/'results/compute_throughput_optimization_20261010'
M=P/'vivado/module_design/attention_and_fp_engine'
def rec(p):
 b=p.read_bytes();return dict(path=str(p.resolve()),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def main():
 a=Path(sys.argv[1]).resolve();a.mkdir(exist_ok=False)
 for n in ['rtl','frozen_source','trace','build']:(a/n).mkdir()
 ce=R/'attempts/t5_attention_service_ce_rtl_01/hls_project/solution1/syn/verilog'
 can=R/'attempts/tanh_libm_canonical_01/rtl'
 sources=[]
 for root in [ce,can]:
  for p in sorted(root.iterdir()):
   if p.suffix=='.v' or p.suffix=='.dat' or p.name.endswith('_ip.tcl'):
    dst=a/'rtl'/p.name
    if dst.exists():assert dst.read_bytes()==p.read_bytes()
    else:shutil.copy2(p,dst)
    sources.append(dict(source=rec(p),frozen=rec(dst),unchanged=True))
 for name in ['rtl/attention_tile_service_v1.sv','tb/attention_tile_tb.sv','tb/attention_tile_build.tcl','tb/attention_tile_prepare.py','tb/attention_guard.py']:
  p=M/name;dst=a/'frozen_source'/p.name;shutil.copy2(p,dst);sources.append(dict(source=rec(p),frozen=rec(dst)))
 helper=R/'attempts/t5_attention_service_rtl_head128_01/frozen_module/tb/hls_guard_helpers.py'
 shutil.copy2(helper,a/'frozen_source'/helper.name);sources.append(dict(source=rec(helper),frozen=rec(a/'frozen_source'/helper.name)))
 f=R/'attempts/t5_attention_fixture_01/work/fixture'
 manifest=json.loads((f/'manifest.json').read_text())
 for r in manifest['products'].values():assert rec(Path(r['path']))==r
 # Extract previously generated, independently rounded intermediate gold.
 mg=np.loadtxt(f/'mul_gold.mem',dtype='<u4',converters={0:lambda x:int(x,16)}).reshape(128,16640)
 ag=np.loadtxt(f/'add_gold.mem',dtype='<u4',converters={0:lambda x:int(x,16)}).reshape(128,16767)
 values={'qk_product':mg[:,:8448].reshape(128,128,66)[:,:,:64],
         'qk_tree':ag[:,:8320].reshape(128,128,65)[:,:,:63],
         'av_trace':ag[:,8575:]}
 for n,v in values.items():(a/'trace'/f'{n}.mem').write_text(''.join(f'{int(x):08x}\n' for x in v.reshape(-1)))
 body=dict(schema='laya-attention-tile-source-v1',contract=rec(R/'source/design.md'),candidate='M16/A16/D4/EXP4 S1024 full capacity',
  baseline=rec(R/'attempts/t5_attention_service_rtl_head128_01/numeric_result.json'),canonical_manifest=rec(R/'attempts/tanh_libm_canonical_01/source_manifest_v04.json'),
  ce_manifest=rec(R/'attempts/t5_attention_service_ce_rtl_01/ce_patch_manifest.json'),fixture_manifest=rec(f/'manifest.json'),fixture=str(f),
  sources=sources,trace={p.name:rec(p) for p in (a/'trace').iterdir()},actual_part='xcu55c-fsvh2892-2L-e',numerical_gold_unchanged=True)
 (a/'source_manifest.json').write_text(json.dumps(body,indent=2,sort_keys=True)+'\n')
 print('ATTENTION_SERVICE_TILE_FREEZE_PASS',a,flush=True)
if __name__=='__main__':main()
