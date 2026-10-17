#!/usr/bin/env python3
"""Seal the source-only D2-I mode3 compiler and runtime inputs, without running them."""
from __future__ import annotations

from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path

BASE = Path('/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline')
REVIEW = BASE / 'results/attention_rtl_repair_20261008'
D2 = REVIEW / 'd2_controller_reachable'
ROOT = D2 / 'rtl_static_mode3_v1'
TB = ROOT / 'tb'
RTL = D2 / 'runs/v3/csynth_vector_work/hls/syn/verilog'
IP = D2 / 'runs/v3/csynth_vector_work/hls/impl/ip/subcore_prj/subcore_prj.gen/sources_1/ip'
GATE = REVIEW / 'reviewer_d2_i_vector_mode3_static_source_preparation_release.json'
PREDICTION = REVIEW / 'd2_i_vector_mode3_static_schedule_ports_budget_precheck.json'
ERRATUM = REVIEW / 'd2_i_vector_mode3_static_schedule_ports_budget_precheck_io_scope_erratum.json'
INDEPENDENT = REVIEW / 'reviewer_d2_i_mode3_static_precheck_independent_review.json'
MANIFEST = D2 / 'ir_audit_v3/rtl_hash_manifest.json'
ENDPOINT = REVIEW / 'd2_axi_allocation_diagnostic/bounded_static_v1/rtl/axi_static_memory.sv'
ATT_TB = REVIEW / 'd2_attention_preloaded/v5/rtl_static_cold_v2/tb'
ATT_PACKET = REVIEW / 'd2_attention_preloaded/v5/rtl_static_cold_v2/source/source_packet.json'
STATIC_GUARD = D2 / 'source/guard_16g.py'
RUNTIME_GUARD = REVIEW / 'd2_axi_allocation_diagnostic/guard_trace_v5/tb/guard_runtime_4g.py'
VIVADO = Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado')
VIVADO_BIN = VIVADO / 'bin'
OUT = ROOT / 'source/source_packet.json'
EXPECTED = {
    GATE: '853ff64b50b2fb1d879453e6aff8759222d5c949e94916cc0b26c8ac72882466',
    PREDICTION: 'cc2b6dfb20af23caa5f9e1f5f951f0de5cb830b193c43057d7f155cda9a1bb5d',
    ERRATUM: '623518d02b2ae86e463ba9df30bd12cdc085d25e3f8f47ee2c7844ffcda75e2f',
    INDEPENDENT: 'e715dfcd5a695c2a014f184007f4a422993bb7da9b1178919bd9256f5eb4e25c',
}


def sha(path: Path) -> str:
    h = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1 << 20), b''):
            h.update(block)
    return h.hexdigest()


def record(path: Path) -> dict:
    if not path.is_file():
        raise FileNotFoundError(path)
    return {'path': str(path.resolve()), 'bytes': path.stat().st_size,
            'mode': oct(path.stat().st_mode & 0o777), 'sha256': sha(path)}


def inventory(paths) -> list[dict]:
    return [record(path) for path in sorted(paths)]


def main() -> int:
    for path, expected in EXPECTED.items():
        if sha(path) != expected:
            raise ValueError(f'frozen authority changed: {path}')
    prediction = json.loads(PREDICTION.read_text())
    old_refs = prediction['source_refs']
    if len(old_refs) != 102:
        raise ValueError(f'precheck binding count {len(old_refs)}')
    mutable_doc_drift = {}
    for label, info in old_refs.items():
        path = Path(info['path'])
        if (path.stat().st_size, sha(path)) != (info['bytes'], info['sha256']):
            if label != 'mission_read' or path != BASE / 'mission/task.md':
                raise ValueError(f'precheck original source changed: {label}')
            mutable_doc_drift[label] = {
                'original': info,
                'current_at_packet_creation': record(path),
                'disposition': 'Mutable activity log only; old binding retained verbatim. Not a compiler, DUT, fixture or gold input.',
            }
    if set(mutable_doc_drift) != {'mission_read'}:
        raise ValueError('expected single mutable mission log drift')
    rtl_manifest = json.loads(MANIFEST.read_text())
    accepted = {Path(info['path']).name: info for info in
                rtl_manifest['runs']['vector']['verilog']['files']}
    verilog = sorted(RTL.glob('*.v'))
    data = sorted(RTL.glob('*.dat'))
    wrappers = sorted(IP.glob('*/sim/*_ip.vhd'))
    if (len(verilog), len(data), len(wrappers)) != (226, 73, 8):
        raise ValueError('generated source closure count')
    if len(accepted) != len(verilog):
        raise ValueError('accepted generated top set')
    for path in verilog:
        info = accepted[path.name]
        if (path.stat().st_size, sha(path)) != (info['bytes'], info['sha256']):
            raise ValueError(f'generated Verilog changed: {path}')
    local = sorted(path for path in TB.iterdir() if path.is_file() and
                   path.suffix in ('.py', '.sh', '.sv', '.svh'))
    local += [ROOT / 'source/design.md', ROOT / 'source/results.md',
              ROOT / 'source/source_delta.diff',
              ROOT / 'rtl/README.md',
              ROOT / 'source/history/before_source_completion_20261009/manifest.json']
    external = [ENDPOINT] + [ATT_TB / name for name in
                ('att_static_axi_stall.sv', 'att_axi_monitor.sv',
                 'att_axi_port.sv', 'att_axi_lite_master.sv')]
    guards = [STATIC_GUARD, STATIC_GUARD.with_name('hls_guard_helpers.py'),
              RUNTIME_GUARD, RUNTIME_GUARD.with_name('hls_guard_helpers.py')]
    inherited = json.loads(ATT_PACKET.read_text())
    libraries = inherited['installed_library_files']
    for name, files in libraries.items():
        if not files:
            raise ValueError(f'empty installed library: {name}')
        for info in files:
            path = Path(info['path'])
            if not path.is_file() or path.stat().st_size != info['bytes']:
                raise ValueError(f'inherited installed library path/size changed: {path}')
    static_build_root = ROOT / 'runs/static_build_mode3_v1'
    snapshot_root = static_build_root / 'xsim.dir'
    runtime_root = ROOT / 'runs/rtl_mode3_first_v1'
    prepared_root = ROOT / 'runs/materialize_mode3_v1/prepared'
    snapshot_manifest = static_build_root / 'snapshot_manifest.json'
    sources = inventory(local)
    source_by_name = {Path(info['path']).name: info for info in sources}
    compile_argv = {
        'xvhdl': [str(VIVADO_BIN / 'xvhdl'), '-work', 'xil_defaultlib',
                   *[str(path) for path in wrappers], '-log', 'xvhdl.log'],
        'xvlog_dut': [str(VIVADO_BIN / 'xvlog'), '-work', 'xil_defaultlib',
                      *[str(path) for path in verilog], '-log', 'xvlog_dut.log'],
        'xvlog_tb': [str(VIVADO_BIN / 'xvlog'), '--sv', '-work', 'xil_defaultlib',
                     '-i', str(TB), *[str(path) for path in external],
                     str(TB / 'vector_mode3_top.sv'), '-log', 'xvlog_tb.log'],
        'xelab': [str(VIVADO_BIN / 'xelab'), 'xil_defaultlib.vector_mode3_top',
                   '-L', 'floating_point_v7_1_21', '-L', 'unisims_ver',
                   '-L', 'xpm', '-L', 'secureip', '--relax', '-mt', 'off',
                   '-s', 'vector_mode3_static', '-log', 'xelab.log'],
    }
    check = [str(TB / 'verify_binding.py'), str(OUT)]
    packet = {
        'schema': 'd2_i_vector_mode3_exact_source_packet_v1',
        'created_utc': datetime.now(timezone.utc).isoformat(),
        'status': 'SOURCE_ONLY_NO_MATERIALIZATION_CPU_COMPILATION_OR_SIMULATION',
        'scope': 'One cold B1/S64 APPLY_CAND_MASK, full 16 candidates, production D2-I v3 Controller',
        'authority': inventory(EXPECTED),
        'prior_102_bindings': old_refs,
        'prior_102_binding_status': '101 immutable paths freshly match; original 102 records preserved verbatim; mission_read is the one explicit mutable task-log drift',
        'mutable_document_drift': mutable_doc_drift,
        'accepted_generated_manifest': record(MANIFEST),
        'generated_verilog': inventory(verilog),
        'generated_dat': inventory(data),
        'fp_sim_vhdl_wrappers': inventory(wrappers),
        'local_active_sources': sources,
        'reused_accepted_endpoint_sources': inventory(external),
        'guard_sources': inventory(guards),
        'preimage_manifest': source_by_name['manifest.json'],
        'installed_library_provenance_packet': record(ATT_PACKET),
        'installed_library_files': libraries,
        'installed_library_status': 'Inherited exact SHA-256 records from accepted Attention V5 source packet; current paths and byte sizes checked. Fresh 2GB library rehash deferred to a reviewed compiler gate.',
        'xsim_ini': record(VIVADO.parent / 'data/xsim/xsim.ini'),
        'xsim_plusarg_manual': record(VIVADO / 'doc/eng/man/xsim'),
        'paths': {
            'module_root': str(ROOT), 'rtl_root': str(RTL),
            'fp_wrapper_root': str(IP), 'tb_root': str(TB),
            'static_build_root': str(static_build_root),
            'snapshot_root': str(snapshot_root),
            'snapshot_manifest': str(snapshot_manifest),
            'runtime_root': str(runtime_root),
            'prepared_root': str(prepared_root),
            'source_packet': str(OUT),
        },
        'compile_argv': compile_argv,
        'stage_argv_source_only': {
            'source_check': ['python3', *check, '--stage', 'source'],
            'future_materialize_NOT_RELEASED': ['python3', str(TB / 'materialize_mode3.py'),
                                                str(prepared_root)],
            'future_materialization_check_NOT_RELEASED': ['python3', str(TB / 'check_materialized.py'),
                                                           str(prepared_root)],
            'future_cpu_gold_check_NOT_RELEASED': ['python3', str(TB / 'check_cpu_gold.py'),
                                                    str(ROOT / 'runs/cpu_gold_mode3_v1.json')],
            'future_build_NOT_RELEASED': ['/usr/bin/bash', str(TB / 'build_static.sh'),
                                           str(static_build_root)],
            'future_guarded_build_NOT_RELEASED': ['python3', str(STATIC_GUARD),
                '--out', str(static_build_root / 'guard'), '--cwd', str(static_build_root),
                '--rss-gib', '16', '--timeout-seconds', '300', '--',
                '/usr/bin/bash', str(TB / 'build_static.sh'), str(static_build_root)],
            'future_snapshot_seal_NOT_RELEASED': ['python3', str(TB / 'seal_snapshot.py'),
                                                   str(snapshot_root), str(snapshot_manifest)],
            'future_snapshot_binding_NOT_RELEASED': ['python3', *check,
                '--stage', 'snapshot', '--static-build-root', str(static_build_root)],
            'future_runtime_NOT_RELEASED': ['/usr/bin/bash', str(TB / 'run_mode3.sh'),
                                             str(static_build_root), str(runtime_root),
                                             str(prepared_root), '131072', '140000'],
            'future_guarded_runtime_NOT_RELEASED': ['python3', str(RUNTIME_GUARD),
                '--out', str(runtime_root / 'guard'), '--cwd', str(runtime_root),
                '--rss-gib', '4', '--timeout-seconds', '120', '--',
                '/usr/bin/bash', str(TB / 'run_mode3.sh'), str(static_build_root),
                str(runtime_root), str(prepared_root), '131072', '140000'],
            'future_numeric_check_within_guard_NOT_RELEASED': ['python3', str(TB / 'check_runtime_mode3.py'),
                str(runtime_root), str(runtime_root / 'independent_numeric_check.json')],
        },
        'candidate_budget_advice_only': {'dut_cycles': 131072, 'total_cycles': 140000,
                                          'runtime_seconds': 120, 'runtime_rss_gib': 4,
                                          'static_seconds': 300, 'static_rss_gib': 16,
                                          'adapter_allowance_cycles_per_work_unit': 64,
                                          'status': 'NOT_EXECUTION_RELEASED_OR_PROVEN_WCET'},
        'expected_physical_prediction_only': prediction['physical_AXI_static_prediction']['totals'],
        'mandatory_io_erratum': 'DUT reads unique IO offsets 0..831; TB maps and checks all 8 IO pages (32768 bytes).',
        'snapshot_note': 'The compiled snapshot is uncreated. A later seal must bind exact xsim.dir files before any runtime; runtime must verify the manifest at its explicit static_build_root.',
        'policy': 'One Laya heavy tool. No new run follows from this source packet; first failure is preserved and a separate execution gate is required.',
    }
    OUT.write_text(json.dumps(packet, indent=2, sort_keys=True) + '\n')
    print('D2_MODE3_SOURCE_PACKET_SOURCE_ONLY', OUT, 'prior_refs=102',
          'verilog=226 dat=73 fp_wrappers=8 local=', len(sources))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
