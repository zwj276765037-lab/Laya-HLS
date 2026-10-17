#!/usr/bin/env python3
"""FFN4: type-check the newly compiled Wi-bound runtime and replay cold xsim."""

import argparse
import datetime as dt
import hashlib
import json
import os
from pathlib import Path
import re
import resource
import shutil
import signal
import subprocess
import sys
import tempfile
import time

ROOT = Path('/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS')
ATTEMPTS = ROOT / 'project/E005_full_request_performance/experiment_results/runs/R001/attempts'
OLD = ATTEMPTS / 'AT063_FFN4_wi_descriptor_01'
NEW = ATTEMPTS / 'AT063_FFN4_wi_descriptor_01'
OLD_CWD = OLD / 'work_static/vivado/ffn4_chain_tb_v1.sim/sim_1/behav/xsim'
SNAP = 'ffn0_chain_tb_v1_behav'
XBIN = Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/xsim')
BIN = XBIN.parent
LIB = BIN.parent / 'lib/lnx64.o'
PREFIX_SOURCE = ATTEMPTS / 'AT057_FFN0_single_runtime_03/prefix_run.tcl'
FIXTURE_KEYS = ('GFIXTURE', 'AFIXTURE', 'WFIXTURE', 'STREAMS', 'WI_AFIXTURE',
                'WI_WFIXTURE', 'WI_STREAMS', 'LN_FIXTURE', 'BOUND_FIXTURE',
                'FFN_FIXTURE', 'FIXTURE')
TOOL_FILES = (XBIN, BIN / 'loader', BIN / 'setupEnv.sh', BIN / 'rdiArgs.sh',
              BIN / 'ldlibpath.sh', Path('/usr/bin/bash'),
              BIN / 'unwrapped/lnx64.o/xsim',
              LIB / 'libxv_simulator_kernel.so',
              LIB / 'libxv_simbridge_kernel.so')
PHASE_START = 0.0


def cumulative_host_seconds():
    ledger = NEW / 'host_budget.json'
    return sum(x['wall_seconds'] for x in json.loads(ledger.read_text())['phases']) if ledger.exists() else 0.0


def stamp():
    return dt.datetime.now(dt.timezone.utc).isoformat()


def write(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2, sort_keys=True) + '\n')


def digest(path):
    h = hashlib.sha256()
    with path.open('rb') as f:
        for block in iter(lambda: f.read(1024 * 1024), b''):
            h.update(block)
    return {'bytes': path.stat().st_size, 'sha256': h.hexdigest()}


def same(path, record):
    return path.is_file() and digest(path) == {k: record[k] for k in ('bytes', 'sha256')}


def files(root):
    result = []
    for p in sorted(root.rglob('*')):
        if p.is_symlink():
            raise RuntimeError(f'symlink in runtime package: {p}')
        if p.is_file():
            result.append(p)
    return result


def kind(path):
    with path.open('rb') as f:
        magic = f.read(4)
    if magic == b'\x7fELF':
        return 'ELF'
    if magic[:2] == b'#!':
        return 'script'
    raise RuntimeError(f'unsupported executable type: {path}')


def identity(path):
    target = path.resolve(strict=True)
    return {'path': str(path), 'resolved_path': str(target),
            'symlink': path.is_symlink(), 'kind': kind(target), **digest(target)}


def probe(label, command, env=None):
    """Preserve original output and return code for each read-only child."""
    start = time.monotonic()
    remaining = 120 - cumulative_host_seconds() - (start - PHASE_START)
    if remaining <= 1:
        raise RuntimeError('host preparation budget exhausted before ' + label)
    proc = subprocess.run(command, env=env, capture_output=True,
                          timeout=min(30, remaining), check=False)
    (NEW / 'host_raw').mkdir(parents=True, exist_ok=True)
    (NEW / 'host_raw' / (label + '.stdout')).write_bytes(proc.stdout)
    (NEW / 'host_raw' / (label + '.stderr')).write_bytes(proc.stderr)
    write(NEW / 'host_raw' / (label + '.json'), {
        'command': command, 'returncode': proc.returncode,
        'wall_seconds': time.monotonic() - start,
        'stdout': label + '.stdout', 'stderr': label + '.stderr'})
    if proc.returncode:
        raise RuntimeError(f'{label} returned {proc.returncode}')
    return proc.stdout.decode('utf-8', errors='replace')


def wrapper_environment():
    # Execute the vendor environment setup verbatim up to, but excluding,
    # RDI_EXEC_COMMANDS.  $0 remains the actual vendor xsim wrapper path.
    script = '''
        . "$(dirname "$0")/setupEnv.sh"
        RDI_PROG=xsim
        export _RDI_NEEDS_PYTHON=True RDI_USE_JDK21=1
        eval "$(sed '$d' "$(dirname "$0")/loader")"
        for key in RDI_PROG RDI_LIBDIR RDI_PATCHROOT RDI_JAVAROOT LD_LIBRARY_PATH LD_PRELOAD PYTHONHOME TCL_LIBRARY RT_LIBPATH RT_TCL_PATH; do
          printf '%s=%s\\n' "$key" "${!key}"
        done
    '''
    output = probe('wrapper_environment', ['bash', '-c', script, str(XBIN),
                                           '-exec', 'xsim'])
    values = dict(line.split('=', 1) for line in output.splitlines()
                  if '=' in line and line.split('=', 1)[0] in {
                    'RDI_PROG', 'RDI_LIBDIR', 'RDI_PATCHROOT', 'RDI_JAVAROOT',
                    'LD_LIBRARY_PATH', 'LD_PRELOAD', 'PYTHONHOME',
                    'TCL_LIBRARY', 'RT_LIBPATH', 'RT_TCL_PATH'})
    if values.get('RDI_PROG') != str(BIN / 'unwrapped/lnx64.o/xsim'):
        raise RuntimeError('actual wrapper selected unexpected executable')
    if not values.get('LD_LIBRARY_PATH'):
        raise RuntimeError('wrapper did not produce library search path')
    return values


def runtime_dependencies():
    """ELF DT_NEEDED closure under the wrapper's actual search path."""
    values = wrapper_environment()
    env = dict(os.environ)
    for key in ('LD_LIBRARY_PATH', 'LD_PRELOAD', 'PYTHONHOME', 'TCL_LIBRARY'):
        if values.get(key):
            env[key] = values[key]
    roots = (OLD_CWD / 'xsim.dir' / SNAP / 'xsimk',
             Path(values['RDI_PROG']), Path('/usr/bin/bash'),
             LIB / 'libxv_simulator_kernel.so',
             LIB / 'libxv_simbridge_kernel.so')
    found = {}
    details = []
    for index, path in enumerate(roots):
        if kind(path) != 'ELF':
            raise RuntimeError(f'ELF root has wrong type: {path}')
        dynamic = probe(f'elf_{index}_readelf', ['readelf', '-l', '-d', str(path)])
        needed = re.findall(r'\(NEEDED\).*?\[(.*?)\]', dynamic)
        interpreter = re.findall(r'Requesting program interpreter: ([^\]]+)', dynamic)
        ldd = probe(f'elf_{index}_ldd', ['ldd', str(path)], env=env)
        if 'not found' in ldd or 'not a dynamic executable' in ldd:
            raise RuntimeError(f'unresolved or invalid ELF root: {path}')
        paths = re.findall(r'=>\s+(/[^\s]+)|^\s*(/[^\s]+)\s+\(', ldd, re.M)
        for pair in paths:
            resolved = Path(next(word for word in pair if word)).resolve(strict=True)
            found[str(resolved)] = identity(resolved)
        found[str(path.resolve(strict=True))] = identity(path)
        for interp in interpreter:
            resolved = Path(interp).resolve(strict=True)
            found[str(resolved)] = identity(resolved)
        details.append({'root': identity(path), 'needed': needed,
                        'interpreter': interpreter,
                        'readelf_log': f'elf_{index}_readelf',
                        'ldd_log': f'elf_{index}_ldd'})
    return values, details, sorted(found.values(), key=lambda x: x['path'])


def expected_command(cwd, phase, roots):
    if phase not in ('pilot', 'full') or set(roots) != set(FIXTURE_KEYS):
        raise RuntimeError('bad phase or fixture root set')
    command = [str(XBIN), SNAP, '-tclbatch',
               str(NEW / 'frozen/prefix_run.tcl' if phase == 'pilot'
                   else NEW / 'frozen/full_run.tcl')]
    for key in FIXTURE_KEYS:
        command += ['-testplusarg', f'{key}={roots[key]}']
    if phase == 'pilot':
        command += ['-testplusarg', 'PREFIX=1']
    return command


def old_roots():
    record = json.loads((OLD / 'direct_xsim_candidate_readonly.json').read_text())
    args = record['command']
    roots = {}
    for index, word in enumerate(args[:-1]):
        if word == '-testplusarg' and '=' in args[index + 1]:
            key, value = args[index + 1].split('=', 1)
            if key in FIXTURE_KEYS:
                if key in roots:
                    raise RuntimeError('duplicate fixture root')
                roots[key] = value
    return roots


def prepare():
    if (NEW / 'package_manifest.json').exists():
        raise RuntimeError('FFN4 package already committed; never overwrite it')
    if not (OLD_CWD / 'xsim.dir' / SNAP / 'xsimk').is_file():
        raise RuntimeError('missing elaborated AT059 snapshot')
    frozen = NEW / 'frozen'
    frozen.mkdir(parents=True, exist_ok=True)
    shutil.copy2(Path(__file__), frozen / Path(__file__).name)
    shutil.copy2(OLD / 'frozen_new/ffn0_guard.py', frozen / 'ffn0_guard.py')
    shutil.copy2(OLD / 'frozen_new/hls_guard_helpers.py', frozen / 'hls_guard_helpers.py')
    shutil.copy2(OLD / 'frozen_new/verify_ffn1_runtime_v1.py',
                 frozen / 'verify_ffn1_runtime_v1.py')
    shutil.copy2(PREFIX_SOURCE, frozen / 'prefix_run.tcl')
    (frozen / 'full_run.tcl').write_text('run all\nexit\n')
    for name in ('source_manifest.json', 'functional_DUT_identity.json',
                 'guard_host_test.json', 'result_micro.json'):
        if (OLD / name).is_file():
            shutil.copy2(OLD / name, frozen / f'at059_{name}')
    old_manifest = json.loads((OLD / 'source_manifest.json').read_text())
    if len(old_manifest['files']) != 342:
        raise RuntimeError('unexpected FFN4 source closure')
    for item in old_manifest['files']:
        if not same(Path(item['path']), item):
            raise RuntimeError(f'AT059 frozen source changed: {item["path"]}')
    shutil.copytree(OLD_CWD, NEW / 'bundle')
    entries = []
    for p in files(NEW / 'bundle'):
        rel = str(p.relative_to(NEW / 'bundle'))
        role = ('compiled_snapshot' if rel.startswith('xsim.dir/') else
                'LN_ROM_target' if rel.endswith('ROM_AUTO_1R.dat') else
                'xsim_config' if rel == 'xsim.ini' else 'elaboration_sidecar')
        entries.append({'relative': rel, 'role': role,
                        'source': str(OLD_CWD / rel), **digest(p)})
        if not same(OLD_CWD / rel, entries[-1]):
            raise RuntimeError(f'copied snapshot differs: {rel}')
    if len([x for x in entries if x['role'] == 'LN_ROM_target']) != 7:
        raise RuntimeError('wrong ROM target count')
    mandatory = ('xsim.dir/' + SNAP + '/' + n for n in
                 ('xsimk', 'xsim.mem', 'xsim.reloc', 'xsim.dbg', 'xsim.xdbg',
                  'xsim.version', 'Compile_Options.txt'))
    by_rel = {x['relative'] for x in entries}
    if not set(mandatory).issubset(by_rel) or 'xsim.ini' not in by_rel:
        raise RuntimeError('incomplete binary/memory/relocation/config closure')
    tools = [identity(p) for p in TOOL_FILES]
    if [item['kind'] for item in tools[:5]] != ['script'] * 5:
        raise RuntimeError('Vivado script chain changed type')
    if any(item['kind'] != 'ELF' for item in tools[5:]):
        raise RuntimeError('Vivado ELF entry changed type')
    environment, elf_details, libraries = runtime_dependencies()
    source_chain = [item for item in tools if item['kind'] == 'script']
    source = [{'path': str(p), **digest(p)} for p in files(frozen)]
    write(NEW / 'package_manifest.json', {
        'schema': 'ffn4_typed_snapshot_package_v1', 'at': stamp(),
        'source_at': str(OLD), 'source_cwd': str(OLD_CWD),
        'source_manifest': digest(OLD / 'source_manifest.json'),
        'snapshot_name': SNAP, 'vivado_version': '2025.2',
        'runtime_files': entries, 'vendor_tool_files': tools,
        'resolved_runtime_libraries': libraries,
        'source_chain': source_chain,
        'elf_details': elf_details,
        'wrapper_environment': environment,
        'dependency_limit': 'DT_NEEDED and listed late-load roots; runtime dlopen and script assets require prefix observation',
        'frozen_files': source,
        'dynamic_outputs': ['xsim.log', 'xsim.jou', 'xsim.dir/' + SNAP +
                            '/xsim_script.tcl', 'xsim.dir/' + SNAP +
                            '/xsimSettings.ini', 'xsim.dir/' + SNAP +
                            '/xsimkernel.log', 'xsim.dir/' + SNAP +
                            '/xsimcrash.log'],
        'fixture_roots': old_roots(),
        'notes': 'Entire AT059 elaborated xsim cwd copied without links. '
                 'Loader-derived search path used for ELF roots; libraries '
                 'remain in installed paths.'})
    print(f'FFN4_PREPARED runtime_files={len(entries)} bytes='
          f'{sum(x["bytes"] for x in entries)}')


def verify(cwd, phase, command, output):
    result = {'schema': 'ffn4_prelaunch_v1', 'at': stamp(), 'phase': phase,
              'cwd': str(cwd), 'command': command, 'spawned': False,
              'status': 'REJECT'}
    try:
        manifest = json.loads((NEW / 'package_manifest.json').read_text())
        roots = manifest['fixture_roots']
        if command != expected_command(cwd, phase, roots):
            raise RuntimeError('actual command/fixture plusargs differ from freeze')
        if roots['FIXTURE'] != roots['LN_FIXTURE']:
            raise RuntimeError('FIXTURE/LN_FIXTURE alias changed')
        if cwd.is_symlink() or not cwd.is_dir():
            raise RuntimeError('missing or linked runtime cwd')
        actual = {str(p.relative_to(cwd)): p for p in files(cwd)}
        expected = {x['relative']: x for x in manifest['runtime_files']}
        if set(actual) != set(expected):
            raise RuntimeError('runtime package file set differs')
        for rel, item in expected.items():
            if not same(actual[rel], item):
                raise RuntimeError(f'runtime package bytes/SHA differ: {rel}')
        for item in manifest['vendor_tool_files']:
            if identity(Path(item['path'])) != item:
                raise RuntimeError(f'vendor tool identity differs: {item["path"]}')
        for item in manifest['resolved_runtime_libraries']:
            if identity(Path(item['path'])) != item:
                raise RuntimeError(f'resolved library identity differs: {item["path"]}')
        for item in manifest['frozen_files']:
            if not same(Path(item['path']), item):
                raise RuntimeError(f'frozen launcher/support differs: {item["path"]}')
        old = OLD / 'source_manifest.json'
        if not same(old, manifest['source_manifest']):
            raise RuntimeError('AT059 source manifest changed')
        old_entries = json.loads(old.read_text())['files']
        for item in old_entries:
            if not same(Path(item['path']), item):
                raise RuntimeError(f'frozen source differs: {item["path"]}')
        roots_path = {k: Path(v).resolve(strict=True) for k, v in roots.items()}
        if len({str(v) for k, v in roots_path.items() if k != 'FIXTURE'}) != 10:
            raise RuntimeError('fixture roots unexpectedly alias')
        expected_fixture = {Path(item['path']).resolve() for item in old_entries
                            if item['role'] in ('downstream_fixtures', 'LN_fixture',
                                                'bound_identity', 'ffn_fixture')}
        for key, root in roots_path.items():
            actual_fixture = {p.resolve() for p in root.iterdir() if p.is_file()}
            wanted = {p for p in expected_fixture if root in p.parents}
            if not wanted or actual_fixture != wanted:
                raise RuntimeError(f'fixture set differs: {key}')
        result.update(status='ACCEPT', runtime_files=len(expected),
                      fixtures=len(expected_fixture), roms=sum(
                          x['role'] == 'LN_ROM_target' for x in expected.values()),
                      manifest_sha256=digest(NEW / 'package_manifest.json')['sha256'])
        code = 0
    except (OSError, ValueError, KeyError, RuntimeError) as exc:
        result['reason'] = str(exc)
        code = 2
    write(output, result)
    return code


def negatives():
    if (NEW / 'preflight_negatives.json').exists():
        raise RuntimeError('negative preflight already recorded')
    manifest = json.loads((NEW / 'package_manifest.json').read_text())
    records = []
    with tempfile.TemporaryDirectory(prefix='ffn3_negative_', dir=NEW) as tmp:
        cwd = Path(tmp) / 'runtime'
        shutil.copytree(NEW / 'bundle', cwd)
        command = expected_command(cwd, 'pilot', manifest['fixture_roots'])
        rom = next(x for x in manifest['runtime_files'] if
                   x['role'] == 'LN_ROM_target')['relative']
        reloc = 'xsim.dir/' + SNAP + '/xsim.reloc'
        for case in ('intact', 'missing_rom', 'corrupt_rom', 'missing_reloc'):
            if case == 'missing_rom':
                (cwd / rom).unlink()
            elif case == 'corrupt_rom':
                shutil.copy2(NEW / 'bundle' / rom, cwd / rom)
                with (cwd / rom).open('ab') as f:
                    f.write(b'corrupt')
            elif case == 'missing_reloc':
                shutil.copy2(NEW / 'bundle' / rom, cwd / rom)
                (cwd / reloc).unlink()
            output = NEW / f'preflight_{case}.json'
            rc = verify(cwd, 'pilot', command, output)
            rec = json.loads(output.read_text())
            expected = 0 if case == 'intact' else 2
            if rc != expected or rec['spawned'] is not False:
                raise RuntimeError(f'preflight negative failed: {case}')
            records.append({'case': case, 'exit_code': rc, 'status': rec['status'],
                            'spawned': False, 'record': str(output)})
    # In-memory manifest copies test vendor identities without touching the
    # shared Vivado installation.  The same verify path rejects before spawn.
    manifest_path = NEW / 'package_manifest.json'
    original = manifest_path.read_bytes()
    try:
        for case, field in (('bad_elf_identity', 'vendor_tool_files'),
                            ('bad_library_identity', 'resolved_runtime_libraries')):
            changed = json.loads(original)
            entry = next(x for x in changed[field] if x['kind'] == 'ELF')
            entry['sha256'] = '0' * 64
            write(manifest_path, changed)
            output = NEW / f'preflight_{case}.json'
            rc = verify(NEW / 'bundle', 'pilot',
                        expected_command(NEW / 'bundle', 'pilot', changed['fixture_roots']),
                        output)
            rec = json.loads(output.read_text())
            if rc != 2 or rec['spawned'] is not False:
                raise RuntimeError(f'preflight negative failed: {case}')
            records.append({'case': case, 'exit_code': rc,
                            'status': rec['status'], 'spawned': False,
                            'record': str(output)})
    finally:
        manifest_path.write_bytes(original)
    write(NEW / 'preflight_negatives.json', {'at': stamp(), 'cases': records,
                                            'verdict': 'PASS'})
    print('FFN4_PREFLIGHT_NEGATIVES_PASS cases=6')


def launch(phase):
    if phase not in ('pilot', 'full'):
        raise RuntimeError('bad phase')
    if (NEW / f'launch_{phase}.json').exists():
        raise RuntimeError(f'{phase} already launched')
    if json.loads((NEW / 'preflight_negatives.json').read_text())['verdict'] != 'PASS':
        raise RuntimeError('preflight negative tests required')
    if phase == 'full':
        decision = json.loads((NEW / 'full_cost_decision.json').read_text())
        if decision.get('admit') is not True or json.loads(
                (NEW / 'result_pilot.json').read_text()).get('verdict') != 'PASS':
            raise RuntimeError('full not admitted')
    cwd = NEW / f'runtime_{phase}'
    if cwd.exists():
        raise RuntimeError('runtime already prepared')
    shutil.copytree(NEW / 'bundle', cwd)
    manifest = json.loads((NEW / 'package_manifest.json').read_text())
    command = expected_command(cwd, phase, manifest['fixture_roots'])
    out = NEW / f'preflight_{phase}.json'
    if verify(cwd, phase, command, out) != 0:
        raise RuntimeError(f'{phase} preflight rejected; xsim not spawned')
    guard = [sys.executable, str(NEW / 'frozen/ffn0_guard.py'), '--out',
             str(NEW / f'guard_{phase}'), '--cwd', str(cwd), '--rss-gib', '8',
             '--timeout-seconds', '120' if phase == 'pilot' else '3600',
             '--semantic-stall-seconds', '120', '--phase', phase, '--', *command]
    write(NEW / f'launch_{phase}.json', {
        'at': stamp(), 'phase': phase, 'cwd': str(cwd), 'command': command,
        'guard_command': guard, 'preflight': str(out),
        'preflight_sha256': digest(out)['sha256'], 'spawn_requested': True})
    result = subprocess.run(guard, cwd=cwd, check=False)
    guard_result = json.loads((NEW / f'guard_{phase}/guard_result.json').read_text())
    log = (NEW / f'guard_{phase}/driver.log').read_text(errors='replace')
    marker = 'FFN0_PREFIX_PILOT_PASS' if phase == 'pilot' else 'FFN0_CHAIN_PASS'
    ok = (result.returncode == 0 and guard_result['trigger'] is None and
          guard_result['simulation_started'] is True and marker in log and
          'Fatal:' not in log and 'ERROR:' not in log)
    if phase == 'pilot':
        match = re.search(r'FFN0_PREFIX_PILOT_PASS cycle=(\d+) source_AR=(\d+) source_R=(\d+) work=(\d+)', log)
        ok = bool(ok and match and int(match[2]) >= 1 and int(match[3]) >= 64)
    write(NEW / f'result_{phase}.json', {
        'at': stamp(), 'verdict': 'PASS' if ok else 'FAIL', 'marker': marker,
        'guard_exit': result.returncode, 'guard': guard_result,
        'prefix': {k: int(v) for k, v in zip(
            ('cycle', 'source_AR', 'source_R', 'work'), match.groups())}
            if phase == 'pilot' and match else None})
    print(f'FFN4_{phase.upper()}_{"PASS" if ok else "FAIL"}')
    return 0 if ok else 1


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('phase', choices=('prepare', 'negatives', 'pilot', 'full'))
    phase = parser.parse_args().phase
    if phase in ('prepare', 'negatives'):
        global PHASE_START
        NEW.mkdir(parents=True, exist_ok=True)
        previous = cumulative_host_seconds()
        remaining = 120 - previous
        if remaining <= 1:
            raise RuntimeError('cumulative host budget exhausted')
        allowed = os.sched_getaffinity(0)
        if allowed != {0, 1, 2, 3} or os.getpriority(os.PRIO_PROCESS, 0) != 19:
            raise RuntimeError(f'host policy differs: affinity={sorted(allowed)} nice={os.getpriority(os.PRIO_PROCESS, 0)}')
        available = next(int(line.split()[1]) for line in Path('/proc/meminfo').read_text().splitlines() if line.startswith('MemAvailable:'))
        if available <= 192 * 1024 * 1024:
            raise RuntimeError('MemAvailable below 192GiB')
        resource.setrlimit(resource.RLIMIT_AS, (8 * 1024**3, 8 * 1024**3))
        PHASE_START = time.monotonic()
        def timeout_handler(_signum, _frame):
            raise TimeoutError('cumulative host wall budget exhausted')
        signal.signal(signal.SIGALRM, timeout_handler)
        signal.setitimer(signal.ITIMER_REAL, remaining)
        try:
            if phase == 'prepare':
                prepare()
            else:
                negatives()
            return 0
        finally:
            signal.setitimer(signal.ITIMER_REAL, 0)
            duration = time.monotonic() - PHASE_START
            ledger = NEW / 'host_budget.json'
            record = json.loads(ledger.read_text()) if ledger.exists() else {'schema': 'ffn4_cumulative_host_budget_v1', 'phases': []}
            record['phases'].append({'phase': phase, 'at': stamp(),
                                     'wall_seconds': duration,
                                     'self_maxrss_kib': resource.getrusage(resource.RUSAGE_SELF).ru_maxrss,
                                     'children_maxrss_kib': resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss,
                                     'affinity': sorted(allowed), 'nice': 19,
                                     'memavailable_start_kib': available})
            record['cumulative_wall_seconds'] = sum(x['wall_seconds'] for x in record['phases'])
            write(ledger, record)
    return launch(phase)


if __name__ == '__main__':
    raise SystemExit(main())
