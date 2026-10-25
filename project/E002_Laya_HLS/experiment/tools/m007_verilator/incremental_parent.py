#!/usr/bin/env python3
"""Build only byte-changed converge512 units and an isolated local timing runtime."""
import fcntl, importlib.util, json, os, shlex, subprocess, sys
from pathlib import Path
here = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('d33_incremental', here / 'run.py')
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)
at = m.RUN / 'attempts/AT026_parent_converge512'
old = m.RUN / 'attempts/AT013_residual_gold_group32'
obj = at / 'work/obj'
prior = old / 'work/obj'
cfg = json.loads((at / 'config.json').read_text())
delta = json.loads((at / 'translation_delta.json').read_text())
if not delta['all_generated_header_bytes_equal'] or delta['*.cpp']['added'] or delta['*.cpp']['removed']:
    raise SystemExit('no header/layout or source-set changes authorized for object reuse')
if (at / 'runtime_build_manifest.json').exists():
    raise SystemExit('preserve prior incremental build')
for x in json.loads((at / 'source_manifest.json').read_text())['sources_and_inputs']:
    if m.sha(Path(x['path'])) != x['sha256']:
        raise SystemExit('frozen parent input changed')
if json.loads((at / 'receipt_translate.json').read_text())['verdict'] != 'PASS':
    raise SystemExit('actual translation PASS required')
for kind in ['*.h', '*.cpp']:
    for side, base in [('old', prior), ('new', obj)]:
        for name, digest in delta[kind][side].items():
            if m.sha(base / name) != digest:
                raise SystemExit('translated source identity changed')
changed = delta['*.cpp']['changed']
if len(changed) != 2:
    raise SystemExit('review unexpected changed TU scope')
old_receipt = json.loads((old / 'receipt_build.json').read_text())
original_objects = {Path(x['path']).name: x for x in old_receipt['completed_objects']}
reused_objects = []
for name in delta['*.cpp']['new']:
    if name in changed:
        continue
    o = prior / (Path(name).stem + '.o')
    if o.name not in original_objects or m.sha(o) != original_objects[o.name]['sha256']:
        raise SystemExit('not an exact successful original object')
    reused_objects.append(m.identify(o))
records = [json.loads(q.read_text()) | {'record_path': str(q)} for q in (old / 'cxx_units').glob('*.json')]
commands = []
paths = [at / 'translation_delta.json', old / 'receipt_build.json', at / 'config.json', at / 'source_manifest.json']
for name in changed:
    matches = [r for r in records if name in r['source_arguments']]
    if len(matches) != 1 or matches[0]['state'] != 'COMPLETE':
        raise SystemExit('successful exact original compiler flags required')
    r = matches[0]
    args = list(r['argv'][1:])
    args[args.index('-o') + 1] = str(obj / (Path(name).stem + '.o'))
    args[args.index(name)] = str(obj / name)
    commands.append([sys.executable, str(here / 'cxx_record.py'), '--records', str(at / 'cxx_units'), '--', *args])
    paths += [Path(r['record_path']), obj / name]
timing_records = [r for r in records if any(Path(s).name == 'verilated_timing.cpp' for s in r['source_arguments'])]
if len(timing_records) != 1 or timing_records[0]['state'] != 'COMPLETE':
    raise SystemExit('actual original timing compiler invocation required')
r = timing_records[0]
patch = here / 'runtime_fixed_batch_v1/verilated_timing.cpp'
args = list(r['argv'][1:])
args[args.index('-o') + 1] = str(obj / 'verilated_timing.o')
args[args.index(r['source_arguments'][0])] = str(patch)
commands.append([sys.executable, str(here / 'cxx_record.py'), '--records', str(at / 'cxx_units'), '--', *args])
paths += [patch, patch.with_name('manifest.json'), Path(r['record_path'])]
archive = 'V' + cfg['top'] + '__ALL.a'
link_lines = []
for q in old.glob('guard_build*/driver.log'):
    for line in q.read_text(errors='replace').splitlines():
        if line.startswith('g++ ') and 'verilated_timing.o' in line and ' -o V' in line:
            link_lines.append((q, line))
if len(link_lines) != 1:
    raise SystemExit('actual successful original link recipe required')
link_log, link_line = link_lines[0]
link = shlex.split(link_line)
link[0] = '/usr/bin/g++'
for i, token in enumerate(link):
    if token.endswith(('.o', '.a')):
        path = (obj if token in ['verilated_timing.o', archive] else prior) / token
        link[i] = str(path)
        if path.parent == prior:
            paths.append(path)
link[link.index('-o') + 1] = str(obj / ('V' + cfg['top']))
commands += [['/usr/bin/ar', '-r', str(obj / archive), *[str(obj / (Path(n).stem + '.o')) for n in changed]],
             [sys.executable, str(here / 'cxx_record.py'), '--records', str(at / 'cxx_units'), '--', *link[1:]]]
paths += [prior / archive, link_log, Path(__file__), here / 'cxx_record.py', *prior.glob('*pch*.gch')]
dependency_paths = set()
for q in prior.glob('*.d'):
    body = q.read_text().replace('\\\n', ' ')
    if ':' not in body:
        continue
    for token in shlex.split(body.split(':', 1)[1]):
        path = Path(token)
        path = path if path.is_absolute() else prior / path
        if path.is_file():
            dependency_paths.add(path.resolve())
paths += list(dependency_paths)
paths += list(obj.glob('*.h'))
paths += list(prior.glob('*.h'))
driver = at / 'incremental_build_commands.py'
driver.write_text('import shutil,subprocess\nshutil.copy2(' + repr(str(prior / archive)) + ',' + repr(str(obj / archive)) + ')\n'
                  + '\n'.join('subprocess.run(' + repr(c) + ', cwd=' + repr(str(prior)) + ', check=True)' for c in commands) + '\n')
paths.append(driver)
for q in (old / 'work').glob('*.dat'):
    (at / 'work' / q.name).symlink_to(q)
    paths.append(q)
manifest = {'runtime_identity': 'Verilator 5.020 + local fixed-batch v1 + converge-limit512; not stock',
            'sources_and_inputs': [m.identify(q) for q in dict.fromkeys(paths)],
            'exact_reused_successful_generated_object_count': len(reused_objects),
            'exact_reused_successful_generated_objects': reused_objects,
            'recompiled_generated_TUs': changed, 'all_generated_headers_equal': True,
            'transitive_non_system_dependency_count': len(dependency_paths),
            'PCH_reuse': 'exact original successful O2 fast/O1 slow bytes; original cwd/include paths and flags',
            'compile_commands': commands, 'original_link_recipe': link_line,
            'production_and_gold_unchanged': True, 'original_objects_and_archive_unchanged': True}
m.dump(at / 'runtime_build_manifest.json', manifest)
if m.budget()['static'] + 120 > 1800:
    raise SystemExit('D33 static budget preflight')
out = at / 'guard_incremental_build'
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
     'executable': m.identify(exe) if exe.exists() else None,
     'runtime_build_manifest': m.identify(at / 'runtime_build_manifest.json'),
     'generated_TUs_recompiled': len(changed), 'original_generated_objects_reused': len(reused_objects)}
m.dump(at / 'receipt_build.json', x)
print(json.dumps({'verdict': x['verdict'], 'elapsed_seconds': g['elapsed_seconds']}), flush=True)
raise SystemExit(0 if ok else 1)
