#!/usr/bin/env python3
"""One D33-budgeted XSim control for the identical mixed zero-delay fixture."""
import argparse, fcntl, importlib.util, json, os, subprocess, sys
from pathlib import Path
here = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('d33_xsim', here / 'run.py')
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)
p = argparse.ArgumentParser()
p.add_argument('stage', choices=['build', 'rtl'])
a = p.parse_args()
at = m.RUN / 'attempts/AT021_mixed_xsim_control'
work = at / 'work'
work.mkdir(parents=True, exist_ok=True)
source = m.RUN / 'attempts/AT018_mixed_zero_clock_fixture/frozen/mixed_zero_clock_tb.sv'
kit = Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin')
guard = Path(json.loads((m.RUN / 'attempts/AT019_mixed_converge512/config.json').read_text())['guard_path'])
manifest = at / 'source_manifest.json'
if not manifest.exists():
    m.dump(manifest, {'sources_and_inputs': [m.identify(q) for q in [source, guard, Path(__file__),
                 kit / 'xvlog', kit / 'xelab', kit / 'xsim']], 'budget': 'D33 only; no R007 balance'})
for x in json.loads(manifest.read_text())['sources_and_inputs']:
    if m.sha(Path(x['path'])) != x['sha256']:
        raise SystemExit('frozen identity changed')
category = 'static' if a.stage == 'build' else 'rtl'
if m.budget()[category] + 120 > (1800 if category == 'static' else 1500):
    raise SystemExit('D33 budget preflight')
if a.stage == 'build':
    commands = [[str(kit / 'xvlog'), '--sv', str(source)],
                [str(kit / 'xelab'), 'work.mixed_zero_clock_tb', '--relax', '-debug', 'off',
                 '-mt', '4', '--O3', '-s', 'mixed_zero_clock_sim']]
    driver = at / 'build_commands.py'
    driver.write_text('import subprocess\n' + '\n'.join('subprocess.run(' + repr(c) + ', check=True)' for c in commands) + '\n')
    cmd = [sys.executable, str(driver)]
else:
    if json.loads((at / 'receipt_build.json').read_text())['verdict'] != 'PASS':
        raise SystemExit('actual build PASS required')
    cmd = [str(kit / 'xsim'), 'mixed_zero_clock_sim', '-runall']
out = at / ('guard_' + a.stage)
if out.exists():
    raise SystemExit('preserve prior attempt stage')
argv = [sys.executable, str(guard), '--out', str(out), '--cwd', str(work), '--rss-gib',
        '24' if category == 'static' else '8', '--timeout-seconds', '120',
        '--semantic-stall-seconds', '120', '--phase', category]
if category == 'static':
    argv += ['--artifact-progress-root', str(work)]
argv += ['--', *cmd]
m.dump(at / ('command_' + a.stage + '.json'), {'category': category, 'argv': argv,
       'source': m.identify(source), 'budget_before_seconds': m.budget(), 'budget_owner': 'D33'})
env = os.environ.copy()
env['PYTHONPATH'] = str(m.ROOT / 'project/E002_Laya_HLS/experiment/tools')
with (m.ROOT / '.research-agent/m007_heavy.lock').open('a+') as lock:
    print('WAITING_PROJECT_HEAVY_LOCK', flush=True)
    fcntl.flock(lock, fcntl.LOCK_EX)
    print('ACQUIRED_PROJECT_HEAVY_LOCK', flush=True)
    with (at / (a.stage + '_wrapper.log')).open('w') as stream:
        rc = subprocess.call(argv, cwd=work, env=env, stdout=stream, stderr=subprocess.STDOUT)
g = json.loads((out / 'guard_result.json').read_text())
log = (out / 'driver.log').read_text(errors='replace')
marker = 'HARDWARE_AGENT_SIM_PASS MIXED_ZERO_CLOCK_COMPLETE'
ok = rc == 0 and not g.get('trigger') and (a.stage == 'build' or marker in log)
x = {'category': category, 'stage': a.stage, 'verdict': 'PASS' if ok else ('COST_STOP' if g.get('trigger') else 'FAIL'),
     'guard': g, 'guard_wrapper_exit': rc, 'source': m.identify(source), 'driver_sha256': m.sha(out / 'driver.log'),
     'required_marker': marker if a.stage == 'rtl' else None, 'budget_owner': 'D33'}
m.dump(at / ('receipt_' + a.stage + '.json'), x)
print(json.dumps({'stage': a.stage, 'verdict': x['verdict'], 'elapsed_seconds': g['elapsed_seconds']}), flush=True)
raise SystemExit(0 if ok else 1)
