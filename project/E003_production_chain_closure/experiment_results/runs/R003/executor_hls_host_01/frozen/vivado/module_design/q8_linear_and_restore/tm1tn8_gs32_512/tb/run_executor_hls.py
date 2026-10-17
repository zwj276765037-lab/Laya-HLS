#!/usr/bin/env python3
"""Freeze and guard the FIRST-only executor host test and HLS generation."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[5]
PROJECT = ROOT.parents[2]
MODULE = Path('vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512')
MODEL = Path('build/model-current-production-v2-20261011')
SOURCE_LIST = Path('config/executor_hls_sources.cmake')
ACTOR_LIST = Path('config/executor_actor_sources.cmake')
TEST = Path('tests/executor_hls_top_test.cpp')
TOP = 'laya_task_lifecycle_executor'
VITIS = Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis/bin/v++')
VITIS_INCLUDE = VITIS.parents[1] / 'include'
DEFINES = ['-DLAYA_PARTITIONED_PRODUCTION_CALLER',
           '-DLAYA_CONTROLLER_TRANSACTION_SEQUENCER',
           '-DLAYA_TRANSACTION_SEQUENCER_CODEC', '-DLAYA_EXECUTOR_FIRST_REQUEST',
           '-DAP_INT_MAX_W=8192']
CASES = ['success', 'bad-owner-echo', 'io-address-mismatch',
         'aux-address-mismatch', 'bad-request', 'bad-model']
FIFOS = {
    'admission_owner': (True,512), 'admission_owner_receipt': (False,512),
    'control_request': (True,512), 'control_request_receipt': (False,512),
    'control_response': (False,512), 'host_result_receipt': (False,512),
    'checkpoint_request': (True,512), 'checkpoint_response': (False,512),
    'accepted_command': (True,512), 'program_result': (False,512), 'request_result': (True,512),
    'action_request': (False,512), 'action_completion': (True,512),
    'transaction_request': (True,512), 'transaction_completion': (False,512),
    'action_completion_receipt': (False,512),
    'control_response_receipt': (True,8192), 'control_response_rejection': (True,8192),
}
SCALARS = {
    'io': ('input', 64), 'aux': ('input', 64),
    'first_valid': ('input', 1), 'hardware_session': ('input', 64),
    'physical_config': ('input', 2496), 'physical_safe': ('input', 1),
    'cancel': ('input', 1), 'checkpoint_valid': ('input', 1),
    'source_epoch': ('input', 32), 'handoff_epoch': ('input', 64),
    'predecessor_held': ('input', 1), 'source_held': ('input', 1),
    'target_held': ('input', 1),
    'first_ready': ('output', 1), 'admission_valid': ('output', 1),
    'admission_rejected': ('output', 1), 'program_result_consumed': ('output', 1),
}
SCOPE = ('FIRST-only metadata executor candidate: actual aligned LYRQ/LYMP IO/AUX, '
         'complete 13-role epoch/address/capacity LAD1, downstream full-frame decode '
         'and original-packet receipts, HOLD/HELD, LBR2 actual helper import, '
         'IMPORT_OK/GRANTED and decoded LGP1 host preparation. Six independent host '
         'processes retain static top state within each case and exercise tail2/tail1 '
         '12-step waits, foreign A echo, pointer mismatch, parser/model refusal and '
         'one FIRST handshake with no second admission. Eleven adapter-owned BO '
         'addresses and shell HOLD/GRANT/safety are controlled host inputs; software '
         'streams are unbounded; wide receipt host reads do not prove direct RTL '
         'full_n consumption by the unique shell. 25-source generation excludes adapter, external '
         'service codecs and complete forward controller. No production wrapper '
         'whole chain, LAP1 bound cancellation, actual RTL FIFO depth2, actual LN/Q '
         'numerics/cycles, CLOSE/rearm, joint resources, timing or board PASS.')


def rec(path):
    path = Path(path).resolve()
    digest = hashlib.sha256()
    count = 0
    with path.open('rb') as stream:
        for data in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(data)
            count += len(data)
    return {'path': str(path), 'bytes': count, 'sha256': digest.hexdigest()}


def write_json(path, value):
    path.write_text(json.dumps(value, indent=2, sort_keys=True) + '\n')


def launcher_state():
    available = next(int(line.split()[1]) for line in
                     Path('/proc/meminfo').read_text().splitlines()
                     if line.startswith('MemAvailable:'))
    state = {'pid': os.getpid(), 'cpu_affinity': sorted(os.sched_getaffinity(0)),
             'nice': os.getpriority(os.PRIO_PROCESS, 0),
             'ionice': subprocess.run(['ionice', '-p', str(os.getpid())],
                                      check=True, text=True,
                                      capture_output=True).stdout.strip(),
             'mem_available_kib': available,
             'required_mem_available_kib': 192 * 1024 * 1024}
    state['pass'] = (state['cpu_affinity'] == [0, 1, 2, 3] and state['nice'] == 19
                     and state['ionice'].startswith('idle') and
                     available > state['required_mem_available_kib'])
    return state


def sources_from_config():
    # Resolve the one nested actor list explicitly. Parsing only top-level
    # hls lines would silently generate a one-source empty closure.
    top = (ROOT / SOURCE_LIST).read_text()
    actor = (ROOT / ACTOR_LIST).read_text()
    if (top.count('include(${CMAKE_CURRENT_LIST_DIR}/executor_actor_sources.cmake)') != 1
            or top.count('${LAYA_EXECUTOR_ACTOR_SOURCES}') != 1):
        raise RuntimeError('executor nested source-list contract changed')
    paths = [Path(p) for p in re.findall(r'^\s*(hls/[^\s]+\.cpp)\s*$', actor, re.M)]
    paths += [Path(p) for p in re.findall(r'^\s*(hls/[^\s]+\.cpp)\s*$', top, re.M)]
    forbidden = {'compute_portal_codec.cpp', 'generated_provenance_codec.cpp',
                 'producer_engine_codec.cpp', 'compute_portal_hls.cpp',
                 'generated_provenance_hls.cpp', 'producer_engine_hls.cpp',
                 'controller_transaction_adapter.cpp', 'full_forward_controller.cpp',
                 'task_lifecycle_executor.cpp', 'controller_transaction_dispatch.cpp',
                 'controller_transaction_hls.cpp'}
    names = {p.name for p in paths}
    required = {'executor_actor.cpp', 'executor_stream.cpp', 'executor_hls.cpp',
                'executor_checkpoint.cpp', 'admission_owner_protocol.cpp',
                'task_lifecycle_fsm.cpp', 'task_lifecycle_port.cpp'}
    if (len(paths) != 25 or len(set(paths)) != 25 or names & forbidden or
            not required.issubset(names) or paths[-1] != Path('hls/control/executor_hls.cpp')):
        raise RuntimeError('executor 25-source closure rejected')
    return paths


def guarded(attempt, name, command, cwd, guard, pilot=False, artifact=None, marker=None):
    output = attempt / ('guard_' + name)
    if output.exists():
        raise RuntimeError('guard output would overwrite an earlier operation')
    args = [sys.executable, str(guard), '--out', str(output), '--cwd', str(cwd),
            '--rss-gib', '8' if pilot else '24', '--timeout-seconds',
            '120' if pilot else '1800', '--semantic-stall-seconds', '120']
    if artifact is not None:
        args += ['--artifact-progress-root', str(artifact)]
    args += ['--', *map(str, command)]
    completed = subprocess.run(args, cwd=cwd)
    result_path = output / 'guard_result.json'
    result = (json.loads(result_path.read_text()) if result_path.is_file() else
              {'child_exit_code': None, 'trigger': 'guard_result_missing'})
    log = output / 'driver.log'
    body = log.read_text(errors='replace') if log.is_file() else ''
    passed = (completed.returncode == 0 and result.get('child_exit_code') == 0
              and result.get('trigger') is None and
              (marker is None or body.count(marker) == 1))
    return {'status': 'PASS' if passed else 'COST_STOP' if result.get('trigger') else 'FAIL',
            'started': True, 'command': args, 'runner_exit_code': completed.returncode,
            'guard': result, 'driver_log': rec(log) if log.is_file() else None,
            'markers': [line for line in body.splitlines() if marker and marker in line]}


def dependency_worker(spec_path):
    spec = json.loads(spec_path.read_text())
    root = Path(spec['root']).resolve()
    closure = set()
    commands = []
    for i, unit in enumerate(spec['units']):
        command = [spec['compiler'], *spec['flags'], '-MM', str(root / unit)]
        commands.append(command)
        dependency = subprocess.check_output(command, cwd=root, text=True)
        # One translation unit per command means exactly one make target.
        for name in dependency.replace('\\\n', ' ').split(':', 1)[1].split():
            path = Path(name).resolve()
            if root in path.parents:
                closure.add(path)
        print(f'FULL_CURRENT_EXECUTOR_HLS_DEPENDENCY_PROGRESS units={i+1}', flush=True)
    write_json(Path(spec['output']), {'files': [rec(p) for p in sorted(closure)],
                                    'commands': commands})
    print('FULL_CURRENT_EXECUTOR_HLS_DEPENDENCY_PASS', flush=True)


def build_worker(spec_path):
    spec = json.loads(spec_path.read_text())
    objects = []
    output = Path(spec['objects']); output.mkdir(exist_ok=False)
    for i, unit in enumerate(spec['units']):
        obj = output / f'{i:02d}_{Path(unit).stem}.o'
        subprocess.run([spec['compiler'], *spec['flags'], '-c', unit,
                        '-o', str(obj)], cwd=spec['cwd'], check=True)
        objects.append(str(obj))
        print(f'FULL_CURRENT_EXECUTOR_HLS_BUILD_PROGRESS units={i+1}', flush=True)
    subprocess.run([spec['compiler'], *objects, '-pthread', '-o', spec['binary']],
                   cwd=spec['cwd'], check=True)
    print('FULL_CURRENT_EXECUTOR_HLS_BUILD_PASS', flush=True)


def declarations(path):
    body = path.read_text(errors='replace')
    module = re.search(r'\bmodule\s+' + re.escape(TOP) + r'\s*\((.*?)\);', body, re.S)
    if module is None:
        raise RuntimeError('generated executor module absent')
    names = set(re.findall(r'\b[A-Za-z_]\w*\b', module.group(1)))
    result = {}
    for match in re.finditer(r'\b(input|output|inout)\s+(?:(?:wire|reg|logic)\s+)?'
                             r'(?:\[\s*(\d+)\s*:\s*(\d+)\s*\]\s*)?'
                             r'([A-Za-z_]\w*)\s*;', body):
        direction, hi, lo, name = match.groups()
        if name in names:
            result[name] = {'direction': direction,
                            'width': abs(int(hi)-int(lo))+1 if hi else 1}
    return names, result


def port_evidence(path):
    names, ports = declarations(path)
    def match(base, direction, width):
        actual = [name for name in (base, base + '_V') if name in names]
        valid = len(actual) == 1 and ports.get(actual[0]) == {'direction': direction, 'width': width}
        return {'pass': valid, 'actual': actual,
                'expected_direction': direction, 'expected_width': width}
    fifos = {}
    for name, (outgoing,width) in FIFOS.items():
        suffixes = [('din', 'output', width), ('full_n', 'input', 1), ('write', 'output', 1)] if outgoing else [
            ('dout', 'input', width), ('empty_n', 'input', 1), ('read', 'output', 1)]
        fifos[name] = {suffix: match(name+'_'+suffix, direction, width)
                       for suffix, direction, width in suffixes}
    scalars = {name: match(name, *expect) for name, expect in SCALARS.items()}
    masters = sorted({match.group(1).lower() for name in names
                      if (match := re.match(r'm_axi_([^_]+)_', name, re.I))})
    axi = {}
    for bundle in ['io', 'aux']:
        def signals(suffix, direction, width=None):
            found = [name for name in names if name.lower() == f'm_axi_{bundle}_{suffix}'.lower()]
            valid = len(found) == 1 and ports.get(found[0], {}).get('direction') == direction
            if width is not None:
                valid = valid and ports.get(found[0], {}).get('width') == width
            return {'pass': valid, 'actual': {name: ports.get(name) for name in found}}
        axi[bundle] = {'ARADDR': signals('ARADDR', 'output', 64),
                       'ARVALID': signals('ARVALID', 'output', 1),
                       'ARREADY': signals('ARREADY', 'input', 1),
                       'RDATA': signals('RDATA', 'input'),
                       'RVALID': signals('RVALID', 'input', 1),
                       'RREADY': signals('RREADY', 'output', 1),
                       'RLAST': signals('RLAST', 'input', 1)}
    forbidden = {name: name in names for name in ('ap_start', 'ap_done', 'ap_idle', 'ap_ready')}
    matched_fifo = sum(item['pass'] for fifo in fifos.values() for item in fifo.values())
    matched_scalar = all(item['pass'] for item in scalars.values())
    extra_fifos = sorted(name for name in names
                        if re.search(r'_(?:din|dout|empty_n|full_n|read|write)$', name)
                        and not any(name.startswith(base+'_') for base in FIFOS))
    passed = (matched_fifo == 54 and matched_scalar and masters == ['aux', 'io']
              and all(item['pass'] for bundle in axi.values() for item in bundle.values())
              and 'ap_clk' in names and bool({'ap_rst', 'ap_rst_n'} & names)
              and not any(forbidden.values()) and not extra_fifos)
    return {'pass': passed, 'generated': rec(path), 'fifo_count': 18,
            'fifo_width_counts': {'512':16,'8192':2},
            'fifo_signal_count': matched_fifo, 'fifos': fifos, 'scalars': scalars,
            'axi_master_bundles': masters, 'axi_read_signals': axi,
            'forbidden_control': forbidden, 'unexpected_fifo_signals': extra_fifos,
            'declared_top_ports': sorted(names), 'declarations': ports}


def resource_evidence(work):
    reports = []
    for path in sorted(work.glob('**/syn/report/*_csynth.xml')):
        try:
            tree = ET.parse(path)
            used = tree.find('.//AreaEstimates/Resources')
            reports.append({'file': rec(path), 'module': path.stem.replace('_csynth', ''),
                            'estimated_resources': {child.tag: child.text for child in used}
                            if used is not None else None,
                            'kind': 'module_HLS_estimate_only'})
        except ET.ParseError:
            reports.append({'file': rec(path), 'parse_error': True})
    return {'modules': reports, 'joint_resource_total': None,
            'physical_timing': 'NOT_RUN', 'board': 'NOT_RUN'}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--attempt', type=Path)
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument('--prepare-only', action='store_true')
    mode.add_argument('--host-only', action='store_true')
    parser.add_argument('--dependency-worker', type=Path, help=argparse.SUPPRESS)
    parser.add_argument('--build-worker', type=Path, help=argparse.SUPPRESS)
    args = parser.parse_args()
    if args.dependency_worker:
        dependency_worker(args.dependency_worker); return 0
    if args.build_worker:
        build_worker(args.build_worker); return 0
    if not args.attempt:
        parser.error('--attempt is required')
    attempt = args.attempt.resolve(); attempt.mkdir(parents=True, exist_ok=False)
    launcher = launcher_state(); write_json(attempt/'launcher.json', launcher)
    receipt = {'schema': 'laya-executor-hls-receipt-v1', 'scope': SCOPE,
               'status': 'PREPARING', 'operations': {},
               'hls': {'status': 'NOT_RUN', 'started': False},
               'whole_production_chain': 'NOT_RUN', 'close_rearm': 'NOT_RUN'}
    manifest = {'schema': 'laya-executor-hls-input-v1', 'scope': SCOPE,
                'top': TOP, 'files': [], 'launcher': rec(attempt/'launcher.json'),
                'profile': {'cpu_ids': [0,1,2,3], 'nice': 19, 'io_class': 'idle',
                            'minimum_mem_available_gib': 192,
                            'static_rss_gib': 24, 'static_seconds': 1800,
                            'semantic_stall_seconds': 120,
                            'oracle_rss_gib': 8, 'oracle_seconds': 120,
                            'one_heavy_tool_at_a_time': True},
                'defines': DEFINES, 'host_cases': CASES,
                'host_cases_separate_processes': True}
    manifest_path=attempt/'input_manifest.json'
    def save():
        write_json(manifest_path,manifest)
        receipt['input_manifest']=rec(manifest_path)
        write_json(attempt/'receipt.json',receipt)
    save()
    if not launcher['pass']:
        receipt['status']='FAIL_LAUNCHER';save();return 1
    try:
        sources=sources_from_config()
        compiler=Path(shutil.which('g++') or '/missing-g++').resolve()
        manifest['compiler']=rec(compiler)
        manifest['tool']={'executable':rec(VITIS),
                          'external_headers':[rec(VITIS_INCLUDE/'ap_int.h'),
                                              rec(VITIS_INCLUDE/'hls_stream.h')]}
        manifest['sources']=[str(p) for p in sources]
        manifest['source_count']=25;manifest['forbidden_sources']=[]
        frozen=attempt/'frozen';records=manifest['files']
        def copy(source,relative,expected=None):
            source=Path(source).resolve();target=frozen/relative
            original=rec(source)
            if expected and original['sha256']!=expected['sha256']:
                raise RuntimeError('source changed after dependency extraction: '+str(source))
            if target.exists():
                if rec(target)['sha256']!=original['sha256']:
                    raise RuntimeError('source changed during freeze: '+str(source))
                return
            target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(source,target)
            copied=rec(target)
            if copied['sha256']!=original['sha256']:
                raise RuntimeError('source changed while copied: '+str(source))
            records.append({'relative':str(relative),'original':original,'frozen':copied})
        runner=Path(__file__).resolve().relative_to(ROOT)
        fixed=sources+[TEST,SOURCE_LIST,ACTOR_LIST,runner,
            Path('include/laya_executor_hls.h'),Path('config/production_hls_partitions.json'),
            Path('config/full_module_registry.json'),Path('config/graph_action_registry.json'),
            MODEL/'laya_model_layout_generated.h',MODEL/'manifest.json',MODEL/'aux.bin',
            Path('tests/executor_handoff_fixture.py'),Path('tests/executor_checkpoint_fixture.py'),
            Path('tests/executor_bootstrap_fixture.py'),Path('tests/admission_owner_fixture.py'),
            Path('tests/program_pending_fixture.py'),MODULE/'tb/production_guard.py',
            Path('tools/hls_guard_helpers.py'),MODULE/'rtl/laya_admission_owner_layout_v1.sv',
            MODULE/'rtl/laya_executor_handoff_layout_v1.sv',
            MODULE/'rtl/laya_executor_checkpoint_layout_v2.sv',
            MODULE/'rtl/laya_model_identity_13bo_generated_v1.sv',
            MODULE/'rtl/laya_program_pending_layout_v1.sv',
            MODULE/'rtl/laya_controller_transaction_layout_v1.sv',
            MODULE/'rtl/laya_graph_action_layout_v1.sv',MODULE/'rtl/laya_graph_program_layout_v1.sv']
        for relative in sorted(set(fixed)):copy(ROOT/relative,relative)
        contracts=['production_hls_partition_contract_20261012.md',
            'executor_bootstrap_source_contract_20261012.md',
            'executor_checkpoint_high_water_contract_20261012.md',
            'executor_checkpoint_import_handshake_contract_20261013.md',
            'executor_close_rearm_contract_20261013.md',
            'executor_managed_lpv_owner_contract_20261013.md',
            'executor_minimum_hardware_chain_reply_20261013.md']
        for name in contracts:copy(PROJECT/'results'/name,Path('external/contracts')/name)
        guard=frozen/MODULE/'tb/production_guard.py'
        live_flags=['-std=c++17',*DEFINES,'-I'+str(ROOT/'include'),
                    '-I'+str(ROOT/'hls'),'-I'+str(ROOT/'hls/platform'),
                    '-I'+str(ROOT/MODEL),'-isystem',str(VITIS_INCLUDE)]
        dep_spec=attempt/'dependency_spec.json';dep_output=attempt/'dependencies.json'
        write_json(dep_spec,{'root':str(ROOT),'compiler':str(compiler),
                            'units':[str(p) for p in sources+[TEST]],
                            'flags':live_flags,'output':str(dep_output)})
        dependency=guarded(attempt,'dependencies',[sys.executable,str(frozen/runner),
            '--dependency-worker',str(dep_spec)],ROOT,guard,
            marker='FULL_CURRENT_EXECUTOR_HLS_DEPENDENCY_PASS')
        receipt['operations']['dependencies']=dependency
        manifest['dependency_spec']=rec(dep_spec)
        if dependency['status']!='PASS':
            receipt['status']=dependency['status'];save();return 1
        dependencies=json.loads(dep_output.read_text())
        for item in dependencies['files']:
            path=Path(item['path']);copy(path,path.relative_to(ROOT),item)
        manifest['dependencies']=rec(dep_output)
        includes=['-I'+str(frozen/'include'),'-I'+str(frozen/'hls'),
                  '-I'+str(frozen/'hls/platform'),'-I'+str(frozen/MODEL)]
        flags=['-std=c++17','-O1','-Wall','-Wextra','-Werror','-Wno-unknown-pragmas',
               '-Wno-unused-parameter','-Wno-aggressive-loop-optimizations',
               '-fno-fast-math','-fno-associative-math','-ffp-contract=off',
               *DEFINES,*includes,'-isystem',str(VITIS_INCLUDE),'-pthread']
        binary=attempt/'executor_hls_top_test'
        build_spec=attempt/'host_build_spec.json'
        write_json(build_spec,{'cwd':str(frozen),'compiler':str(compiler),
            'flags':flags,'units':[str(frozen/p) for p in sources+[TEST]],
            'objects':str(attempt/'host_objects'),'binary':str(binary)})
        manifest['host_build_spec']=rec(build_spec)
        config=attempt/'executor.cfg'
        lines=['part=xcu55c-fsvh2892-2L-e','freqhz=150000000','[hls]',
               'flow_target=vivado',f'syn.top={TOP}','syn.compile.pipeline_loops=0',
               'syn.array_partition.throughput_driven=off','syn.array_partition.complete_threshold=0']
        lines += [f'syn.file={frozen/p}' for p in sources]
        lines += ['syn.cflags='+' '.join([*DEFINES,*includes,'-std=c++17',
                   '-fno-fast-math','-fno-associative-math','-ffp-contract=off'])]
        config.write_text('\n'.join(lines)+'\n');manifest['derived_config']=rec(config)
        fixture=attempt/'fixture'
        oracle=[sys.executable,str(frozen/'tests/executor_handoff_fixture.py'),
                '--model-header',str(frozen/MODEL/'laya_model_layout_generated.h'),
                '--model-aux',str(frozen/MODEL/'aux.bin'),'--output',str(fixture)]
        build=[sys.executable,str(frozen/runner),'--build-worker',str(build_spec)]
        hls=[str(VITIS),'--compile','--mode','hls','--config',str(config),
             '--work_dir',str(attempt/'work')]
        manifest['planned_commands']={'oracle':oracle,'build':build,
            'host':[[str(binary),str(fixture),case] for case in CASES],'hls':hls}
        manifest['frozen_closure_complete']=True;save()
        version=guarded(attempt,'tool_version',[str(VITIS),'--version'],frozen,guard,pilot=True)
        receipt['operations']['tool_version']=version
        compiler_version=guarded(attempt,'compiler_version',[str(compiler),'--version'],frozen,guard,pilot=True)
        receipt['operations']['compiler_version']=compiler_version
        if version['status']!='PASS' or compiler_version['status']!='PASS':
            receipt['status']='FAIL_TOOL_IDENTITY';save();return 1
        manifest['tool']['version_log']=version['driver_log']
        manifest['compiler_version_log']=compiler_version['driver_log']
        receipt['status']='PREPARED';save()
        if args.prepare_only:
            print('FULL_CURRENT_EXECUTOR_HLS_PREPARED',flush=True);return 0
        result=guarded(attempt,'oracle',oracle,frozen,guard,pilot=True,
                       marker='FULL_CURRENT_EXECUTOR_HANDOFF_FIXTURE_PASS')
        receipt['operations']['oracle']=result
        receipt['fixture_files']=[rec(p) for p in sorted(fixture.rglob('*')) if p.is_file()]
        save()
        if result['status']!='PASS':receipt['status']=result['status'];save();return 1
        result=guarded(attempt,'host_build',build,attempt,guard,
                       artifact=attempt/'host_objects',marker='FULL_CURRENT_EXECUTOR_HLS_BUILD_PASS')
        receipt['operations']['host_build']=result;save()
        if result['status']!='PASS':receipt['status']=result['status'];save();return 1
        receipt['executable']=rec(binary)
        for case in CASES:
            result=guarded(attempt,'host_'+case,[str(binary),str(fixture),case],frozen,guard,
                           marker='FULL_CURRENT_EXECUTOR_HLS_TOP_PASS case='+case)
            receipt['operations']['host_'+case]=result;save()
            if result['status']!='PASS':receipt['status']=result['status'];save();return 1
        receipt['status']='PASS_SCOPED_HOST';save()
        if args.host_only:
            print('FULL_CURRENT_EXECUTOR_HLS_PASS_SCOPED_HOST',flush=True);return 0
        receipt['hls']=guarded(attempt,'hls',hls,attempt,guard,artifact=attempt/'work')
        candidates=sorted((attempt/'work').glob(f'**/syn/verilog/{TOP}.v'))
        receipt['generated_candidates']=[str(path) for path in candidates]
        ports=None
        if len(candidates)==1:
            generated=attempt/(TOP+'.v');shutil.copyfile(candidates[0],generated)
            ports=port_evidence(generated)
        receipt['port_evidence']=ports
        receipt['resource_evidence']=resource_evidence(attempt/'work')
        receipt['generated_artifacts']=[rec(p) for p in sorted((attempt/'work').rglob('*')) if p.is_file()]
        receipt['status']=('PASS_SCOPED_GENERATION' if receipt['hls']['status']=='PASS'
                           and ports and ports['pass'] else
                           receipt['hls']['status'] if receipt['hls']['status']!='PASS' else 'FAIL_PORTS')
        save();print('FULL_CURRENT_EXECUTOR_HLS_'+receipt['status'],flush=True)
        return 0 if receipt['status']=='PASS_SCOPED_GENERATION' else 1
    except Exception as error:
        receipt['status']='FAIL_RUNNER';receipt['error']=str(error);save();raise


if __name__=='__main__':
    raise SystemExit(main())
