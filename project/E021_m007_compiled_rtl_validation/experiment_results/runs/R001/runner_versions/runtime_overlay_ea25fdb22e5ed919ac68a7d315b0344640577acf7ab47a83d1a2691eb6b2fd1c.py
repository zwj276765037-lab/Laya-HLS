#!/usr/bin/env python3
"""Relink preserved generated objects against one explicitly local timing runtime."""
import argparse, datetime as dt, fcntl, importlib.util, json, os, re, shlex, subprocess, sys
from pathlib import Path

here = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('d33_overlay', here / 'run.py')
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)
p = argparse.ArgumentParser()
p.add_argument('stage', choices=['prepare', 'build'])
p.add_argument('attempt')
p.add_argument('--source-attempt')
p.add_argument('--patch', type=Path, default=here / 'runtime_fixed_batch_v1/verilated_timing.cpp')
a = p.parse_args()
if not re.fullmatch(r'AT\d{3}_[A-Za-z0-9_]+', a.attempt):
    p.error('stable attempt required')
at = m.RUN / 'attempts' / a.attempt
work = at / 'work'
obj = work / 'obj'

def validate(manifest):
    for x in manifest['sources_and_inputs']:
        if m.sha(Path(x['path'])) != x['sha256']:
            raise SystemExit('identity changed: ' + x['path'])

if a.stage == 'prepare':
    source = m.RUN / 'attempts' / a.source_attempt
    cfg = json.loads((source / 'config.json').read_text())
    prior = json.loads((source / 'source_manifest.json').read_text())
    validate(prior)
    if (at / 'config.json').exists():
        raise SystemExit('preserve prior attempt')
    obj.mkdir(parents=True, exist_ok=True)
    source_obj = source / 'work/obj'
    runtime_records = []
    for q in (source / 'cxx_units').glob('*.json'):
        x = json.loads(q.read_text())
        if any(Path(s).name == 'verilated_timing.cpp' for s in x['source_arguments']):
            runtime_records.append((q, x))
    if len(runtime_records) != 1 or runtime_records[0][1]['state'] != 'COMPLETE':
        raise SystemExit('one actual successful runtime compile required')
    record_path, record = runtime_records[0]
    compile_argv = list(record['argv'][1:])
    compile_argv[compile_argv.index('-o') + 1] = str(obj / 'verilated_timing.o')
    for i, token in enumerate(compile_argv):
        if token.endswith('/verilated_timing.cpp'):
            compile_argv[i] = str(a.patch.resolve())
    compile_cmd = [sys.executable, str(here / 'cxx_record.py'), '--records', str(at / 'cxx_units'), '--', *compile_argv]
    link_lines = []
    for q in source.glob('guard_build*/driver.log'):
        for line in q.read_text(errors='replace').splitlines():
            if line.startswith('g++ ') and 'verilated_timing.o' in line and ' -o V' in line:
                link_lines.append((q, line))
    if len(link_lines) != 1:
        raise SystemExit('one actual successful link recipe required')
    link_log, link_line = link_lines[0]
    link_argv = shlex.split(link_line)
    if link_argv[0] != 'g++':
        raise SystemExit('unexpected linker')
    link_argv[0] = '/usr/bin/g++'
    link_inputs = []
    for i, token in enumerate(link_argv):
        if token.endswith(('.o', '.a')):
            path = source_obj / token
            link_inputs.append(path)
            link_argv[i] = str(obj / 'verilated_timing.o') if token == 'verilated_timing.o' else str(path)
    link_argv[link_argv.index('-o') + 1] = str(obj / ('V' + cfg['top']))
    link_cmd = [sys.executable, str(here / 'cxx_record.py'), '--records', str(at / 'cxx_units'), '--', *link_argv[1:]]
    cfg['case'] = cfg['case'] + '_local_fixed_batch_runtime'
    cfg['runtime_identity'] = 'Verilator 5.020 + local fixed-batch v1; not stock'
    cfg['source_attempt'] = str(source)
    cfg['plusargs'] = [x.replace(str(source / 'work'), str(work)) if x.startswith('+EXPORT=') else x for x in cfg.get('plusargs', [])]
    for q in (source / 'work').glob('*.dat'):
        (work / q.name).symlink_to(q)
    m.dump(at / 'config.json', cfg)
    commands = {'cwd': str(source_obj), 'compile': compile_cmd, 'link': link_cmd,
                'actual_original_compile_record': m.identify(record_path),
                'actual_original_link_log': m.identify(link_log), 'actual_original_link_line': link_line}
    m.dump(at / 'overlay_commands.json', commands)
    (at / 'frozen_overlay.py').write_bytes(Path(__file__).read_bytes())
    paths = [Path(x['path']) for x in prior['sources_and_inputs']]
    paths += [source / 'config.json', source / 'source_manifest.json', source_obj / ('V' + cfg['top']), *link_inputs]
    paths += list(m.VROOT.joinpath('include').glob('verilated*.h'))
    paths += [m.VROOT / 'include/verilated_timing.cpp', a.patch.resolve(), a.patch.resolve().with_name('manifest.json'),
              Path(__file__), at / 'frozen_overlay.py', at / 'overlay_commands.json', here / 'cxx_record.py']
    manifest = {'created_at': dt.datetime.now(dt.timezone.utc).isoformat(),
                'sources_and_inputs': [m.identify(q) for q in dict.fromkeys(paths)],
                'runtime_identity': cfg['runtime_identity'], 'generated_objects_unchanged': True,
                'original_runtime_unchanged': True, 'production_and_gold_unchanged': True,
                'actual_model': 'UNKNOWN', 'actual_effort': 'UNKNOWN'}
    m.dump(at / 'source_manifest.json', manifest)
    print('PREPARED_RUNTIME_OVERLAY', a.attempt, flush=True)
    raise SystemExit(0)

validate(json.loads((at / 'source_manifest.json').read_text()))
cfg = json.loads((at / 'config.json').read_text())
commands = json.loads((at / 'overlay_commands.json').read_text())
out = at / 'guard_build'
if out.exists():
    raise SystemExit('preserve prior build')
if m.budget()['static'] + 120 > 1800:
    raise SystemExit('static D33 budget')
driver = at / 'build_overlay_commands.py'
driver.write_text('import subprocess\n' + '\n'.join('subprocess.run(' + repr(commands[k]) + ', cwd=' + repr(commands['cwd']) + ', check=True)'
                                                   for k in ['compile', 'link']) + '\n')
guard = Path(cfg.get('guard_path', str(m.GUARD)))
argv = [sys.executable, str(guard), '--out', str(out), '--cwd', str(work), '--rss-gib', '24',
        '--timeout-seconds', '120', '--semantic-stall-seconds', '120', '--artifact-progress-root', str(work)]
if cfg.get('guard_phase_option', False):
    argv += ['--phase', 'static']
argv += ['--', sys.executable, str(driver)]
m.dump(at / 'command_build.json', {'category': 'static', 'argv': argv, 'driver': m.identify(driver),
                                  'budget_before_seconds': m.budget(), 'runtime_identity': cfg['runtime_identity']})
env = os.environ.copy()
env['VERILATOR_ROOT'] = str(m.VROOT)
env['PYTHONPATH'] = str(m.ROOT / 'project/E002_Laya_HLS/experiment/tools')
with (m.ROOT / '.research-agent/m007_heavy.lock').open('a+') as lock:
    print('WAITING_PROJECT_HEAVY_LOCK', flush=True)
    fcntl.flock(lock, fcntl.LOCK_EX)
    print('ACQUIRED_PROJECT_HEAVY_LOCK', flush=True)
    with (at / 'build_guard_wrapper.log').open('w') as stream:
        rc = subprocess.call(argv, cwd=commands['cwd'], env=env, stdout=stream, stderr=subprocess.STDOUT)
g = json.loads((out / 'guard_result.json').read_text())
exe = obj / ('V' + cfg['top'])
ok = rc == 0 and not g.get('trigger') and exe.is_file()
x = {'category': 'static', 'stage': 'build', 'verdict': 'PASS' if ok else ('COST_STOP' if g.get('trigger') else 'FAIL'),
     'guard': g, 'guard_wrapper_exit': rc, 'runtime_identity': cfg['runtime_identity'],
     'new_runtime_object': m.identify(obj / 'verilated_timing.o') if (obj / 'verilated_timing.o').exists() else None,
     'executable': m.identify(exe) if exe.exists() else None, 'generated_objects_recompiled': False}
m.dump(at / 'receipt_build.json', x)
print(json.dumps({'verdict': x['verdict'], 'elapsed_seconds': g['elapsed_seconds']}), flush=True)
raise SystemExit(0 if ok else 1)
