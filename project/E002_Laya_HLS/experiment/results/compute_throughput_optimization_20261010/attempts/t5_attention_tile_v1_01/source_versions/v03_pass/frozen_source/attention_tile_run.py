#!/usr/bin/env python3
"""Replay the real compiled tile snapshot and require its exact terminal PASS."""
from pathlib import Path
import argparse,os,subprocess,re,sys,json,hashlib,shutil
def rec(p):
 b=p.read_bytes();return dict(path=str(p.resolve()),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def main():
 p=argparse.ArgumentParser();p.add_argument('attempt',type=Path);p.add_argument('name');p.add_argument('rows',type=int);p.add_argument('--protocol',type=int,default=0);args=p.parse_args()
 a=args.attempt.resolve();work=a/args.name;work.mkdir(exist_ok=False)
 build=a/'build/vivado/attention_tile.sim/sim_1/behav/xsim'
 shutil.copytree(build/'xsim.dir',work/'xsim.dir')
 for f in [*build.glob('*.dat'),*build.glob('*.ini')]:shutil.copy2(f,work/f.name)
 manifest=json.loads((a/'source_manifest_v03.json').read_text())
 for r in manifest['sources']:assert rec(Path(r['frozen']['path']))==r['frozen']
 (work/'run.tcl').write_text('run all\nquit\n')
 os.environ['SIM_VER_XSIM']='2025.2';os.environ['GCC_VER_XSIM']='9.3.0'
 command=['/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/xsim','attention_tile_tb_behav','-tclbatch',str(work/'run.tcl'),'-log',str(work/'simulate.log'),'-wdb',str(work/'tile.wdb'),
  '-testplusarg',f"FIXTURE={manifest['fixture']}",'-testplusarg',f'TRACE={a}/trace','-testplusarg',f'ROWS={args.rows}','-testplusarg',f'PROTOCOL={args.protocol}']
 (work/'input_manifest.json').write_text(json.dumps(dict(source_manifest=rec(a/'source_manifest_v03.json'),compiled_snapshot={str(f.relative_to(work)):rec(f) for f in (work/'xsim.dir').rglob('*') if f.is_file()},command=command,rows=args.rows,protocol=args.protocol),indent=2,sort_keys=True)+'\n')
 print(f'ATTENTION_SERVICE_TILE_RTL_BEGIN rows={args.rows}',flush=True)
 rc=subprocess.call(command,cwd=work)
 log=(work/'simulate.log').read_text(errors='replace') if (work/'simulate.log').exists() else ''
 marker=f'ATTENTION_SERVICE_TILE_RTL_PASS rows={args.rows} keys128 D64'
 if rc or marker not in log or re.search(r'(^|\n)(Fatal:|ERROR:)',log):sys.exit(rc if rc else 1)
 print(f'ATTENTION_SERVICE_TILE_RTL_END rows={args.rows} exact_pass=1',flush=True)
if __name__=='__main__':main()
