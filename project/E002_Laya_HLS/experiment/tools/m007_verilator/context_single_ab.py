#!/usr/bin/env python3
"""Main-only harness A/B: explicit one-thread context for an unchanged one-thread model."""
import fcntl, importlib.util, json, os, subprocess, sys
from pathlib import Path
here = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('d33_context', here / 'run.py')
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)
at = m.RUN / 'attempts/AT028_single_context_QKV1'
source = m.RUN / 'attempts/AT026_parent_converge512'
original = m.RUN / 'attempts/AT013_residual_gold_group32'
cfg = json.loads((at / 'config.json').read_text())
obj = at / 'work/obj'
obj.mkdir(exist_ok=True)
out = at / 'guard_build'
if out.exists() or (at / 'runtime_build_manifest.json').exists():
    raise SystemExit('preserve prior attempt')
prior = json.loads((source / 'runtime_build_manifest.json').read_text())
for manifest in [json.loads((at / 'source_manifest.json').read_text()), prior]:
    for x in manifest['sources_and_inputs']:
        if m.sha(Path(x['path'])) != x['sha256']:
            raise SystemExit('frozen build input changed: ' + x['path'])
name = 'V' + cfg['top'] + '__main.cpp'
matches = []
for q in (original / 'cxx_units').glob('*.json'):
    r = json.loads(q.read_text())
    if name in r['source_arguments']:
        matches.append((q, r))
if len(matches) != 1 or matches[0][1]['state'] != 'COMPLETE':
    raise SystemExit('exact successful main compiler record required')
record_path, record = matches[0]
args = list(record['argv'][1:])
main = at / 'frozen' / name
new_object = obj / (Path(name).stem + '.o')
args[args.index(name)] = str(main)
args[args.index('-o') + 1] = str(new_object)
compile_cmd = [sys.executable, str(here / 'cxx_record.py'), '--records', str(at / 'cxx_units'), '--', *args]
archive_name = 'V' + cfg['top'] + '__ALL.a'
archive = obj / archive_name
source_archive = source / 'work/obj' / archive_name
old_link = prior['compile_commands'][-1]
link_args = list(old_link[old_link.index('--') + 1:])
link_args[link_args.index(str(source_archive))] = str(archive)
link_args[link_args.index('-o') + 1] = str(obj / ('V' + cfg['top']))
link_cmd = [sys.executable, str(here / 'cxx_record.py'), '--records', str(at / 'cxx_units'), '--', *link_args]
commands = [compile_cmd, ['/usr/bin/ar', '-r', str(archive), str(new_object)], link_cmd]
driver = at / 'main_build_commands.py'
driver.write_text('import shutil,subprocess\nshutil.copy2(' + repr(str(source_archive)) + ',' + repr(str(archive)) + ')\n'
                 + '\n'.join('subprocess.run(' + repr(c) + ', cwd=' + repr(record['cwd']) + ', check=True)' for c in commands) + '\n')
for q in (source / 'work').glob('*.dat'):
    (at / 'work' / q.name).symlink_to(q)
paths = [Path(x['path']) for x in prior['sources_and_inputs']]
paths += [source_archive, source / 'receipt_build.json', source / 'receipt_rtl.json', source / 'runtime_build_manifest.json',
          at / 'config.json', at / 'source_manifest.json', main, record_path, driver, Path(__file__), here / 'cxx_record.py']
manifest = {'runtime_identity': cfg['runtime_identity'], 'sources_and_inputs': [m.identify(q) for q in dict.fromkeys(paths)],
            'only_new_design_archive_member': new_object.name, 'production_RTL_TB_gold_unchanged': True,
            'original_executable_and_archive_unchanged': True, 'model_threads': 1, 'explicit_context_threads': 1,
            'actual_original_main_compile_record': m.identify(record_path), 'compile_commands': commands,
            'baseline_CPU_time': 'UNKNOWN; not captured in prior AT026 run; do not infer from wall time'}
m.dump(at / 'runtime_build_manifest.json', manifest)
if m.budget()['static'] + 120 > 1800:
    raise SystemExit('D33 static budget preflight')
guard = Path(cfg['guard_path'])
argv = [sys.executable, str(guard), '--out', str(out), '--cwd', str(at / 'work'), '--rss-gib', '24',
        '--timeout-seconds', '120', '--semantic-stall-seconds', '120', '--phase', 'static',
        '--artifact-progress-root', str(at / 'work'), '--', sys.executable, str(driver)]
m.dump(at / 'command_build.json', {'category': 'static', 'argv': argv, 'budget_before_seconds': m.budget(),
                                  'runtime_build_manifest': m.identify(at / 'runtime_build_manifest.json')})
env = os.environ.copy()
env['VERILATOR_ROOT'] = str(m.VROOT)
env['PYTHONPATH'] = str(m.ROOT / 'project/E002_Laya_HLS/experiment/tools')
with (m.ROOT / '.research-agent/m007_heavy.lock').open('a+') as lock:
    print('WAITING_PROJECT_HEAVY_LOCK', flush=True)
    fcntl.flock(lock, fcntl.LOCK_EX)
    print('ACQUIRED_PROJECT_HEAVY_LOCK', flush=True)
    with (at / 'build_guard_wrapper.log').open('w') as stream:
        rc = subprocess.call(argv, cwd=at / 'work', env=env, stdout=stream, stderr=subprocess.STDOUT)
g = json.loads((out / 'guard_result.json').read_text())
exe = obj / ('V' + cfg['top'])
ok = rc == 0 and not g.get('trigger') and exe.exists()
x = {'category': 'static', 'stage': 'build', 'verdict': 'PASS' if ok else ('COST_STOP' if g.get('trigger') else 'FAIL'),
     'guard': g, 'guard_wrapper_exit': rc, 'runtime_identity': manifest['runtime_identity'],
     'executable': m.identify(exe) if exe.exists() else None, 'only_main_object_recompiled': True,
     'runtime_build_manifest': m.identify(at / 'runtime_build_manifest.json')}
m.dump(at / 'receipt_build.json', x)
print(json.dumps({'verdict': x['verdict'], 'elapsed_seconds': g['elapsed_seconds']}), flush=True)
raise SystemExit(0 if ok else 1)
