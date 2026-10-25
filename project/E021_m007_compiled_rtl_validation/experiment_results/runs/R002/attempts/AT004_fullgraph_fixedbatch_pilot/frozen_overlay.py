#!/usr/bin/env python3
"""Relink preserved generated objects against one explicitly local timing runtime."""
import argparse, datetime as dt, fcntl, importlib.util, json, os, re, shlex, subprocess, sys
from pathlib import Path

here = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('d33_overlay', here / 'fullgraph_run_r002.py')
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
    historical_bindings = []
    prior_paths = []
    design_paths = set(cfg['sources'] + cfg.get('inputs', []))
    for x in prior['sources_and_inputs']:
        q = Path(x['path'])
        if m.sha(q) == x['sha256']:
            prior_paths.append(q)
            continue
        if str(q) in design_paths:
            raise SystemExit('original design/input changed: ' + str(q))
        archives = [source / 'frozen_runner.py', *list((m.RUN / 'runner_versions').glob('*.py'))]
        matching = next((z for z in archives if z.is_file() and m.sha(z) == x['sha256']), None)
        if matching is None:
            raise SystemExit('historical provenance identity not bound: ' + str(q))
        prior_paths.append(matching)
        historical_bindings.append({'original': x, 'exact_archived_bytes': m.identify(matching)})
    if (at / 'config.json').exists():
        raise SystemExit('preserve prior attempt')
    obj.mkdir(parents=True, exist_ok=True)
    source_obj = source / 'work/obj'
    runtime_records = []
    for q in (source / 'cxx_units').glob('*.json'):
        x = json.loads(q.read_text())
        if any(Path(s).name == 'verilated_timing.cpp' for s in x['source_arguments']):
            runtime_records.append((q, x))
    if not runtime_records:
        for q in source.glob('guard_build*/driver.log'):
            for line in q.read_text(errors='replace').splitlines():
                if line.startswith('g++ ') and ' -c ' in line and line.endswith('/verilated_timing.cpp'):
                    actual = shlex.split(line)
                    actual[0] = '/usr/bin/g++'
                    runtime_records.append((q, {'argv': actual, 'state': 'COMPLETE',
                                                'basis': 'actual successful original make stdout'}))
    if len(runtime_records) != 1 or runtime_records[0][1]['state'] != 'COMPLETE':
        raise SystemExit('one actual successful runtime compile record or stdout required')
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
    # Main-only additional real phase observations use actual emitted root fields.
    main_name = 'V' + cfg['top'] + '__main.cpp'
    main_source = source_obj / main_name
    derived_main = obj / main_name
    main_text = main_source.read_text()
    main_text = main_text.replace('    // Simulate until $finish', '    unsigned last_phase_state = ~0U, last_head_mask = ~0U, last_matrix_done = ~0U, last_global = ~0U;\n    // Simulate until $finish')
    base = cfg['top'] + '__DOT__'
    rh = (source_obj / ('V' + cfg['top'] + '___024root.h')).read_text()
    names = [base+'dut__DOT__state',base+'dut__DOT__l_head_completed',base+'dut__DOT__layer_index',base+'layer_mdone',base+'cycle']
    if any(name not in rh for name in names):
        raise SystemExit('actual root phase fields required before deriving main')
    observe = '\n        { const unsigned gl = topp->rootp->'+names[2]+'; const unsigned st = topp->rootp->'+names[0]+'; const unsigned hm = topp->rootp->'+names[1]+'; const unsigned md = gl < 30 ? topp->rootp->'+names[3]+'[gl] : ~0U; if (st != last_phase_state || hm != last_head_mask || md != last_matrix_done || gl != last_global) { std::printf("M007_FULLGRAPH_PHASE global=%u state=%u heads=%u matrix_done=%u cycle=%llu\\n", gl, st, hm, md, static_cast<unsigned long long>(topp->rootp->'+names[4]+')); std::fflush(stdout); last_phase_state=st; last_head_mask=hm; last_matrix_done=md; last_global=gl; } }\n'
    main_text = main_text.replace('        topp->eval();', '        topp->eval();'+observe)
    if main_text.count('topp->eval();') != main_source.read_text().count('topp->eval();'):
        raise SystemExit('no extra eval calls allowed')
    derived_main.write_text(main_text)
    main_records=[]
    for q in (source/'cxx_units').glob('*.json'):
        row=json.loads(q.read_text())
        if main_name in row.get('source_arguments',[]):main_records.append((q,row))
    if len(main_records)!=1 or main_records[0][1]['state']!='COMPLETE':raise SystemExit('actual successful main compile invocation required')
    main_record_path,main_record=main_records[0]
    main_args=list(main_record['argv'][1:]);main_args[main_args.index(main_name)]=str(derived_main);main_args[main_args.index('-o')+1]=str(obj/(Path(main_name).stem+'.o'))
    main_compile=[sys.executable,str(here/'cxx_record.py'),'--records',str(at/'cxx_units'),'--',*main_args]
    source_archive=next(q for q in link_inputs if q.suffix=='.a')
    new_archive=obj/source_archive.name
    link_argv[link_argv.index(str(source_archive))]=str(new_archive)
    link_cmd=[sys.executable,str(here/'cxx_record.py'),'--records',str(at/'cxx_units'),'--',*link_argv[1:]]
    archive_cmd=['/usr/bin/ar','-r',str(new_archive),str(obj/(Path(main_name).stem+'.o'))]
    cfg['case'] = cfg['case'] + '_local_fixed_batch_runtime'
    cfg['runtime_identity'] = 'Verilator 5.020 + local fixed-batch v1; not stock' + ('; converge-limit512' if '--converge-limit' in cfg.get('verilator_flags', []) and '512' in cfg['verilator_flags'] else '; original generated convergence limit')
    if '--threads' in cfg.get('verilator_flags', []):
        n = cfg['verilator_flags'][cfg['verilator_flags'].index('--threads') + 1]
        cfg['runtime_identity'] += '; generated model threads' + n + '/explicit context threads' + n
    cfg['runtime_identity'] += '; generated model threads1/explicit context threads1'
    cfg['source_attempt'] = str(source)
    cfg['plusargs'] = [x.replace(str(source / 'work'), str(work)) if x.startswith('+EXPORT=') else x for x in cfg.get('plusargs', [])]
    for q in (source / 'work').glob('*.dat'):
        (work / q.name).symlink_to(q)
    m.dump(at / 'config.json', cfg)
    commands = {'cwd': str(source_obj), 'compile': compile_cmd, 'main_compile': main_compile, 'archive': archive_cmd, 'source_archive': str(source_archive), 'new_archive': str(new_archive), 'link': link_cmd,
                'actual_original_compile_record': m.identify(record_path),
                'actual_original_link_log': m.identify(link_log), 'actual_original_link_line': link_line}
    m.dump(at / 'overlay_commands.json', commands)
    (at / 'frozen_overlay.py').write_bytes(Path(__file__).read_bytes())
    paths = prior_paths
    paths += [source / 'config.json', source / 'source_manifest.json', source_obj / ('V' + cfg['top']), *link_inputs]
    paths += list(m.VROOT.joinpath('include').glob('verilated*.h'))
    paths += list(source.glob('generated_main_context_override.json'))
    paths += list(source.joinpath('frozen').glob('generated_main_context*.cpp'))
    paths += [source_obj / ('V' + cfg['top'] + '.cpp'), derived_main, main_record_path, source / 'generated_build_inputs.json']
    paths += [Path(v['path']) for v in json.loads((source / 'generated_build_inputs.json').read_text())['sources_and_inputs']]
    paths += list(source_obj.glob('*pch*'))
    paths += [m.VROOT / 'include/verilated_timing.cpp', a.patch.resolve(), a.patch.resolve().with_name('manifest.json'),
              Path(__file__), at / 'frozen_overlay.py', at / 'overlay_commands.json', here / 'cxx_record.py']
    manifest = {'created_at': dt.datetime.now(dt.timezone.utc).isoformat(),
                'sources_and_inputs': [m.identify(q) for q in dict.fromkeys(paths)],
                'runtime_identity': cfg['runtime_identity'], 'generated_objects_unchanged': 'all generated mathematical model objects unchanged; main-only observer member recompiled',
                'main_observer_no_signal_writes_or_extra_eval': True,
                'original_runtime_unchanged': True, 'production_and_gold_unchanged': True,
                'historical_provenance_bindings': historical_bindings,
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
if m.budget()['static'] + 120 > 1200:
    raise SystemExit('static D34 budget')
driver = at / 'build_overlay_commands.py'
driver.write_text('import shutil,subprocess\nshutil.copy2('+repr(commands['source_archive'])+','+repr(commands['new_archive'])+')\n' + '\n'.join('subprocess.run(' + repr(commands[k]) + ', cwd=' + repr(commands['cwd']) + ', check=True)'
                                                   for k in ['compile', 'main_compile', 'archive', 'link']) + '\n')
guard = Path(cfg.get('guard_path', str(m.GUARD)))
source_dispatch=json.loads((Path(cfg['source_attempt'])/'complete_build_dispatch.json').read_text())
cap=min(120,int(500-source_dispatch['elapsed_seconds']-5))
if cap<1:raise SystemExit('first build total500 remaining cap exhausted')
argv = [sys.executable, str(guard), '--out', str(out), '--cwd', str(work), '--rss-gib', '24',
        '--timeout-seconds', str(cap), '--semantic-stall-seconds', '120', '--artifact-progress-root', str(work)]
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
