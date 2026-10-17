#!/usr/bin/env python3
"""Record a bounded, read-only M003 dependency and launch preparation audit."""
import argparse
import datetime as dt
import hashlib
import json
import os
from pathlib import Path
import platform
import re
import shutil
import subprocess
import time


def now():
    return dt.datetime.now(dt.timezone.utc).isoformat()


def record(path):
    path = path.resolve()
    digest = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(block)
    return {'path': str(path), 'bytes': path.stat().st_size,
            'sha256': digest.hexdigest()}


def write(path, data):
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2, sort_keys=True) + '\n')


def resources(root):
    mem = {k: int(v.split()[0]) for k, v in
           (line.split(':', 1) for line in Path('/proc/meminfo').read_text().splitlines())}
    candidates = []
    names = {'vivado', 'vitis-run', 'vitis_hls', 'xsim', 'xelab', 'xvlog',
             'cc1plus', 'g++', 'iverilog', 'vvp', 'verilator', 'vsim'}
    for proc in Path('/proc').iterdir():
        if not proc.name.isdigit():
            continue
        try:
            name = (proc / 'comm').read_text().strip()
            if name not in names:
                continue
            command = (proc / 'cmdline').read_bytes().replace(b'\0', b' ').decode(errors='replace')
            cwd = str((proc / 'cwd').resolve())
            owned = str(root) in command or cwd.startswith(str(root))
            candidates.append({'pid': int(proc.name), 'name': name, 'cwd': cwd,
                               'command': command, 'this_project': owned})
        except (FileNotFoundError, PermissionError, ProcessLookupError):
            continue
    return {'at': now(), 'mem_available_kb': mem['MemAvailable'],
            'cpu_affinity': sorted(os.sched_getaffinity(0)),
            'nice': os.getpriority(os.PRIO_PROCESS, 0),
            'heavy_process_candidates': candidates,
            'project_heavy_count': sum(x['this_project'] for x in candidates)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, required=True)
    parser.add_argument('--run', type=Path, required=True)
    args = parser.parse_args()
    root, run = args.root.resolve(), args.run.resolve()
    implementation = root / 'project/E002_Laya_HLS/experiment'
    baseline = root.parent / 'LLAMA-HLS/Laya-baseline'
    stage = implementation / 'results/compute_throughput_optimization_20261010'
    audit_root = root / 'project/E002_Laya_HLS/experiment_results/engineering_acceptance_evidence_20261011'
    package = implementation / 'build/model-current-production-v2-20261011'
    tb_root = implementation / 'vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb'
    started, clock = now(), time.monotonic()
    output = run / 'preparation'
    output.mkdir(exist_ok=False)
    preflight = resources(root)
    write(output / 'resource_preflight.json', preflight)
    assert preflight['mem_available_kb'] > 192 * 1024 * 1024
    assert preflight['project_heavy_count'] == 0
    assert preflight['cpu_affinity'] == [0, 1, 2, 3] and preflight['nice'] == 19

    old = json.loads((stage / 'attempts/current_production_build_02/work/build_manifest.json').read_text())
    old_preimage = json.loads((package / 'build_preimage.json').read_text())
    flags = [x.replace(str(baseline), str(implementation)) for x in old['flags']]
    source_config = implementation / 'config/full_sources.cmake'
    production = re.findall(r'^\s*(hls/[^\s]+\.cpp)\s*$', source_config.read_text(), re.M)
    services = re.findall(r'^\s*(vivado/module_design/[^\s]+\.cpp)\s*$', source_config.read_text(), re.M)
    assert len(production) == 27 and len(services) == 2
    units = production + services + ['tests/current_production_full_csim_tb.cpp',
        'host/cpu_embedding_raw.cpp', 'vivado/module_design/activation_quantizer/tb/numeric_tb.cpp',
        'vivado/module_design/q8_linear_and_restore/tb/numeric_tb.cpp']
    dep_dir = output / 'dependencies'
    dep_dir.mkdir()
    closure, commands = set(), []
    for index, unit in enumerate(units):
        command = ['/usr/bin/g++', *flags, '-MM', '-MT', 'dependency_probe', str(implementation / unit)]
        result = subprocess.run(command, cwd=implementation, capture_output=True, text=True, timeout=20)
        (dep_dir / f'{index:02d}.d').write_text(result.stdout)
        (dep_dir / f'{index:02d}.stderr').write_text(result.stderr)
        commands.append({'unit': unit, 'command': command, 'cwd': str(implementation),
                         'exit_code': result.returncode, 'dependency_file': f'dependencies/{index:02d}.d'})
        write(output / 'dependency_commands.json', commands)
        assert result.returncode == 0, unit
        body = result.stdout.replace('\\\n', ' ').split(':', 1)[1]
        for name in body.split():
            dependency = Path(name)
            if not dependency.is_absolute():
                dependency = implementation / dependency
            dependency = dependency.resolve()
            assert dependency.is_relative_to(implementation), str(dependency)
            closure.add(dependency)
        print('FULL_CURRENT_DEPENDENCY unit=' + unit, flush=True)
    dependencies = [record(p) for p in sorted(closure)]
    snapshot = output / 'frozen_compiler_closure'
    frozen = []
    for item in dependencies:
        original = Path(item['path'])
        target = snapshot / original.relative_to(implementation)
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(original, target)
        copied = record(target)
        assert copied['sha256'] == item['sha256']
        frozen.append({'original': item, 'snapshot': copied})
    old_dependencies = {x['path'].replace(str(baseline), str(implementation)): x for x in old['compiled_dependencies']}
    current = {x['path']: x for x in dependencies}
    difference = {'old_count': len(old_dependencies), 'current_count': len(current),
        'added': [v for k, v in current.items() if k not in old_dependencies],
        'removed': [v for k, v in old_dependencies.items() if k not in current],
        'changed': [{'old': old_dependencies[k], 'current': v} for k, v in current.items()
                    if k in old_dependencies and v['sha256'] != old_dependencies[k]['sha256']]}
    write(output / 'compiler_dependency_difference.json', difference)

    # This is an inventory of existing module evidence, not a generated production-top closure.
    inherited_audits = [json.loads((audit_root / name).read_text()) for name in
                        ['identity_audit.json', 'supplemental_identity_audit.json']]
    inventory_paths = {implementation / x['path'] for x in old_preimage['sources']}
    inventory_paths.update([source_config, tb_root / 'current_production_csim_config.py',
        tb_root / 'current_production_csim_receipt.py', tb_root / 'production_guard.py',
        implementation / 'tools/hls_guard_helpers.py',
        implementation / 'config/production_rtl_blackboxes.json',
        implementation / 'config/full_module_registry.json',
        implementation / 'config/u55c_link.cfg', stage / 'source/design.md'])
    for audit in inherited_audits:
        for doc in audit['documents']:
            for ref in doc['references']:
                path = Path(ref['mapped_path'])
                if path.is_relative_to(implementation) and path.suffix in {
                        '.sv', '.v', '.vh', '.vhd', '.tcl', '.xdc', '.xci', '.h', '.cpp', '.cfg'}:
                    inventory_paths.add(path)
    inventory = [record(p) for p in sorted(inventory_paths)]
    source_preimage_difference = [{'relative_path': x['path'], 'expected_sha256': x['sha256'],
        'current_sha256': record(implementation / x['path'])['sha256']}
        for x in old_preimage['sources'] if record(implementation / x['path'])['sha256'] != x['sha256']]
    write(output / 'existing_module_source_inventory.json', inventory)
    write(output / 'old_package_preimage_difference.json', source_preimage_difference)

    inherited = []
    for name in ['input_checks.json', 'core_checks.json', 'identity_audit.json',
                 'supplemental_identity_audit.json', 'delivery_verification.json']:
        inherited.append(record(audit_root / name))
    input_check = json.loads((audit_root / 'input_checks.json').read_text())
    input_stats = []
    for x in input_check['package_BO_checks']:
        path = root / x['path']
        input_stats.append({'path': str(path), 'bytes_now': path.stat().st_size,
                            'verified_sha256': x['actual_sha256'], 'method': 'inherited audited SHA; current size check'})
        assert path.stat().st_size == x['bytes']
    input_stats.append({'path': input_check['source_model']['path'],
        'bytes_now': Path(input_check['source_model']['path']).stat().st_size,
        'verified_sha256': input_check['source_model']['sha256'], 'method': 'inherited audited SHA; current size check'})
    requests = implementation / 'build/current-production-requests-v2-20261011'
    identities = [record(package / name) for name in ['manifest.json', 'build_preimage.json',
        'numeric_preimage.txt', 'layout_preimage.json']]
    identities += [record(requests / name) for name in ['identity_manifest.json', 'raw_identity_manifest.json']]
    write(output / 'inherited_input_reference_identity.json', {'audit_evidence': inherited,
        'current_identity_documents': identities, 'payload_stat_checks': input_stats,
        'payload_rehashed_in_R001': False, 'independent_gold': 'inherited from input_checks/core_checks/identity_audit; unchanged inputs are reusable within their recorded scope'})

    compiler = subprocess.check_output(['/usr/bin/g++', '--version'], text=True)
    tool_paths = ['/usr/bin/g++', '/usr/bin/nice', '/usr/bin/ionice', '/usr/bin/taskset',
        '/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis/bin/vitis-run',
        '/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado']
    tools = {'compiler_version_query': compiler, 'platform': platform.platform(),
        'python': platform.python_version(), 'glibc': platform.libc_ver(),
        'executables': [record(Path(p)) for p in tool_paths],
        'eda_version_query': 'NOT_RUN; historical Vitis2025.2 identity retained as historical',
        'eda_license_checkout': 'NOT_RUN', 'target_part': 'xcu55c-fsvh2892-2L-e',
        'target_hz': 150000000, 'achieved_timing': 'NOT_RUN'}
    write(output / 'tool_identity.json', tools)

    registry = json.loads((root / '.research-agent/project.json').read_text())
    model = subprocess.run(['python3', '/home/zwj/.codex/skills/research-agent/scripts/research.py',
        'model-resolve', '--root', str(root), '--role', 'engineering', '--small-mission', 'SM003'],
        capture_output=True, text=True, check=True)
    write(output / 'ownership_model_identity.json', {'authoritative_contracts': [record(root / name) for name in
        ['mission/M003_当前身份生产链接入与回归.md', 'mission/M004_完整Laya加速器搭建与性能优化.md',
         'project/missions/SM003.md', 'project/missions/SM004.md', 'project/missions/SM005.md']],
        'A002_registration_at_preparation': registry['records']['agent']['A002'],
        'requested_model_resolution': json.loads(model.stdout),
        'actual_model': None, 'actual_effort': None,
        'stale_registration_action': 'controller synchronize A002 M003/SM003/E003 binding; no engineering registry edit'})
    plan = {'schema': 'laya-m003-launch-preparation-v1', 'implementation_root': str(implementation),
        'baseline_read_only': str(baseline), 'flags_for_dependency_probe': flags,
        'reuse_payload_package_read_only': str(package), 'reuse_request_identity_read_only': str(requests),
        'oracle_root': str(implementation / 'results/attention_rtl_repair_20261008/d2_cpu_full_official/oracle'),
        'future_build_root': str(implementation / 'build/model-m003-final-IDENTITY'),
        'future_requests_root': str(implementation / 'build/m003-final-requests-IDENTITY'),
        'future_run_root': str(run.parent), 'launch_commands_ready': False,
        'required_before_full_regression': ['finish L1-L3 integration', 'freeze final source and generated hardware closure',
            'export a new package/build tag', 'rebind original four requests and raw identities without changing payload/gold',
            'generate real CSim config from the new compiled manifest', 'recheck resource ownership and license'],
        'budgets': {'preparation_rss_gib': 4, 'preparation_wall_seconds': 120,
            'static_rss_gib': 24, 'static_wall_seconds': 1800, 'cpu_csim_rss_gib': 16,
            'cpu_csim_wall_seconds': 1800, 'rtl_rss_gib': 8, 'rtl_wall_seconds': 3600,
            'rtl_cycle_limit': 40000000, 'rtl_pilot_seconds': 120,
            'new_ooc_authorized_in_M003': False, 'G_remaining_ooc_seconds': 2338.224019}}
    write(output / 'launch_path_plan.json', plan)
    preimage = {'schema': 'laya-m003-l0-preparation-preimage-v1', 'started_at': started,
        'compiler_dependencies': dependencies, 'frozen_compiler_dependencies': frozen,
        'existing_module_inventory': record(output / 'existing_module_source_inventory.json'),
        'compiler_dependency_commands': record(output / 'dependency_commands.json'),
        'tool_identity': record(output / 'tool_identity.json'),
        'input_reference_identity': record(output / 'inherited_input_reference_identity.json'),
        'launch_path_plan': record(output / 'launch_path_plan.json'),
        'configuration_generator': record(tb_root / 'current_production_csim_config.py'),
        'scope': 'pre-change dependency extraction and launch preparation; no compiled executable, numerical regression, HLS synthesis, RTL simulation or OOC',
        'L0_acceptance': 'PARTIAL: current C closure verified; production generated top/IP/XDC final closure and new package binding pending'}
    write(output / 'preimage.json', preimage)
    receipt = {'schema': 'laya-m003-preparation-receipt-v1', 'started_at': started, 'finished_at': now(),
        'wall_seconds': time.monotonic() - clock, 'execution_state': 'completed',
        'preparation_verdict': 'PASS', 'mission_verdict': 'unassessed', 'L0': 'PARTIAL',
        'translation_units': len(units), 'current_dependency_count': len(dependencies),
        'old_dependency_count': len(old_dependencies), 'old_dependency_changed': len(difference['changed']),
        'added_dependency_count': len(difference['added']), 'existing_module_inventory_count': len(inventory),
        'preimage': record(output / 'preimage.json'), 'project_heavy_tools_started': 0,
        'full_cpu_csim_rtl': 'NOT_RUN', 'resources_after': resources(root)}
    write(output / 'receipt.json', receipt)
    print('FULL_CURRENT_PREPARATION_PASS ' + json.dumps({k: receipt[k] for k in
        ['translation_units', 'current_dependency_count', 'old_dependency_changed', 'added_dependency_count', 'L0']}) , flush=True)


if __name__ == '__main__':
    main()
