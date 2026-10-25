#!/usr/bin/env python3
"""Frozen v1 / v2 force-CE / v2 automatic-CE public equivalence runner."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import re
import subprocess
import tarfile
import time

MODULE = Path(__file__).resolve().parents[1]
ROOT = MODULE.parents[2]
LOCAL = MODULE.relative_to(ROOT)
PROJECT = ROOT.parents[2]
RUN = PROJECT / 'project/E015_m007_tanh_geglu8/experiment_results/runs/R002'
VIV = Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin')
NAMES = ('laya_m007_tanh_fast_leaves_v1.sv', 'laya_m007_tanh_add3_e_v1.sv',
         'laya_m007_tanh_div12_r4_v1.sv', 'laya_m007_tanh_lane_v1.sv',
         'laya_m007_tanh8_v1.sv', 'laya_m007_tanh_core_v2.sv', 'laya_m007_tanh8_v2.sv')
SOURCES = [LOCAL / 'rtl' / name for name in NAMES] + [
    Path('vivado/module_design/attention_and_fp_engine/rtl/laya_return_vector_credit_v1.sv'),
    LOCAL / 'tb/m007_tanh_ce_tb.sv']


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def save(path, value):
    path.write_text(json.dumps(value, indent=2) + '\n')


def inventory(path):
    return {str(p.relative_to(path)): sha(p) for p in sorted((path / 'xsim.dir').rglob('*')) if p.is_file()}


def execute(argv, cwd, events=None):
    print('COMMAND', [str(x) for x in argv], flush=True)
    start = time.monotonic()
    process = subprocess.Popen([str(x) for x in argv], cwd=cwd, stdout=subprocess.PIPE,
                               stderr=subprocess.STDOUT, text=True, bufsize=1)
    lines = []
    for line in process.stdout:
        print(line, end='', flush=True)
        lines.append(line)
        if events is not None and (line.strip() == 'run -all' or line.startswith('TANH_CE_EQUIVALENCE_PASS')):
            events.append({'received_utc': datetime.now(timezone.utc).isoformat(),
                           'seconds_since_launch': time.monotonic() - start, 'line': line.rstrip()})
    code = process.wait()
    log = ''.join(lines)
    if code or re.search(r'(?im)^\s*(?:Fatal|ERROR):', log):
        raise RuntimeError(f'tool failure exit={code}')
    return log


def audit(frozen, output):
    rtl = frozen / LOCAL / 'rtl'
    old = (rtl / NAMES[3]).read_text().split('\nendmodule', 1)[0] + '\nendmodule\n'
    new = (rtl / NAMES[5]).read_text()
    inverse = new.replace('laya_m007_tanh_core_v2(input wire clk,reset,in_valid,core_ce,',
                          'laya_m007_tanh_core_v1(input wire clk,reset,in_valid,')
    inverse = inverse.replace('commit_valid,token_empty,', 'commit_valid,')
    inverse = inverse.replace('else if(core_ce)valid_pipe', 'else valid_pipe')
    inverse = inverse.replace('always @(posedge clk) if(core_ce) ', 'always @(posedge clk) ')
    inverse = inverse.replace('.aclken(core_ce)', '.aclken(1\'b1)')
    inverse = inverse.replace(' assign token_empty=~(|valid_pipe[151:0]);\n', '')
    assert inverse == old
    assert new.count('always @(posedge clk)') == new.count('if(core_ce)') == 2447
    assert new.count('.aclken(core_ce)') == 42
    blocks = [{'line': i + 1, 'text': line.strip()} for i, line in enumerate(new.splitlines()) if 'always @(posedge clk)' in line]
    leaves = []
    for name, kind, expected in ((NAMES[0], 'laya_m007_tanh_mul4_v1', 1),
                                 (NAMES[1], 'laya_m007_tanh_add3_e_v1', 1),
                                 (NAMES[2], 'laya_m007_tanh_div12_r4_v1', 2)):
        text = (rtl / name).read_text()
        module = re.search(r'\bmodule\s+' + kind + r'\b[\s\S]*?\bendmodule\b', text)[0]
        seq = [line.strip() for line in module.splitlines() if 'always_ff' in line]
        assert len(seq) == expected
        assert 'if(!aresetn)begin valid<=0;m_axis_result_tdata<=0;end' in module
        assert 'else if(aclken)begin' in module
        if expected == 2:
            assert 'always_ff @(posedge aclk)if(aresetn&&aclken)begin' in module
        leaves.append({'module': kind, 'source_sha256': sha(rtl / name),
                       'sequential_statements': seq, 'reset_priority': 'original reset before CE; original no-reset stage holds under reset',
                       'generated_stage_instances': 8 if expected == 2 else 0})
    old_wrapper = (rtl / NAMES[4]).read_text()
    new_wrapper = (rtl / NAMES[6]).read_text()
    start = ' always_ff @(posedge clk)begin'
    end = ' for(genvar lane='
    assert old_wrapper[old_wrapper.index(start):old_wrapper.index(end)] == new_wrapper[new_wrapper.index(start):new_wrapper.index(end)]
    assert new_wrapper.count('always_ff') == old_wrapper.count('always_ff') == 1
    expression = re.search(r'wire core_ce=([^;]+);', new_wrapper)[1]
    expression = re.sub(r'\s+', '', expression)
    assert expression == 'FORCE_CORE_CE||!rst_n||lease_active||lease_fire||req_fire||(pending_vectors!=0)||(in_flight_vectors!=0)||!all_token_empty||protocol_fault'
    assert 'wire all_token_empty=&core_token_empty;' in new_wrapper
    save(output / 'complete_CE_reset_coverage.json', {
        'status': 'STATIC_REVERSIBLE_TRANSFORM_AND_COMPLETE_CE_COVERAGE_PASS',
        'new_state_bits': 0, 'clock_gates': 0, 'core_sequential_blocks': blocks,
        'core_block_count': 2447, 'core_leaf_count': 42, 'leaf_internal_coverage': leaves,
        'unchanged_lease_credit_fault_sequential_and_instance_text': True,
        'exact_CE_expression': expression, 'protocol_fault_high_implies_CE1_static': True,
        'internal_fault_dynamic_injection': 'NOT_RUN; no legal public injection and no forced state',
        'token_empty': 'full152bit reduction; all8 cores AND',
        'timing_or_speedup': 'NOT_RUN'})


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('stage', choices=('build', 'rtl'))
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--schedule', type=Path)
    parser.add_argument('--build', type=Path)
    parser.add_argument('--fixture', type=Path)
    parser.add_argument('--nodes', type=Path)
    parser.add_argument('--count', type=int, default=4096)
    args = parser.parse_args()
    output = args.output
    output.mkdir(parents=True, exist_ok=False)
    frozen = output / 'frozen'
    frozen.mkdir()
    with tarfile.open(output.parent / 'sources.tar.gz', 'r:gz') as archive:
        archive.extractall(frozen, filter='data')
    if args.stage == 'build':
        schedule = json.loads(args.schedule.read_text())
        assert schedule['selected_result_edge'] == 152
        assert sha(frozen / LOCAL / 'rtl' / NAMES[3]) == schedule['generated_rtl_sha256']
        for name, digest in schedule['leaf_sources_sha256'].items():
            assert sha(frozen / LOCAL / 'rtl' / name) == digest
        audit(frozen, output)
        checks = []
        nodes = sorted(schedule['nodes'], key=lambda n: ({'add': 0, 'mul': 1, 'div': 2}[n['op']], int(re.search(r'\d+', n['name'])[0])))
        for lane in range(8):
            for index, node in enumerate(nodes):
                edge, name = node['consumer_edge'], node['name']
                checks.append(f'''always @(posedge clk)if(rst_n&&dut.tanh_lane[{lane}].core.valid_pipe[{edge-1}]&&mask_pipe[{edge-1}][{lane}])begin
 if(dut.tanh_lane[{lane}].core.{name}!==nodes[id_pipe[{edge-1}][{lane}]][{1343-32*index}-:32])$fatal(1,"NODE_{name} lane={lane} index=%0d",id_pipe[{edge-1}][{lane}]);
 node_checks=node_checks+1;end''')
        (output / 'm007_tanh8_node_checks.svh').write_text('\n'.join(checks) + '\n')
        execute([VIV / 'xvlog', '--sv', '-i', output, *[frozen / p for p in SOURCES]], output)
        execute([VIV / 'xelab', 'work.m007_tanh_ce_tb', '--relax', '-mt', '4', '--O3', '-s', 'tanh_ce26_sim'], output)
        save(output / 'report.json', {'status': 'BUILD_COMPLETE', 'source_sha256': {str(p): sha(frozen / p) for p in SOURCES},
             'driver_sha256': sha(Path(__file__)), 'schedule_sha256': sha(args.schedule),
             'coverage_sha256': sha(output / 'complete_CE_reset_coverage.json'), 'snapshot': inventory(output)})
    else:
        assert 384 <= args.count <= 8192, 'Only bounded equivalence samples, no unchanged full suite'
        manifest = json.loads((args.build / 'report.json').read_text())
        assert sha(Path(__file__)) == manifest['driver_sha256']
        for name, digest in manifest['source_sha256'].items():
            assert sha(frozen / name) == digest and sha(ROOT / name) == digest
        for name, digest in manifest['snapshot'].items():
            assert sha(args.build / name) == digest
        fixture = json.loads((args.fixture / 'report.json').read_text())
        nodes = json.loads((args.nodes / 'report.json').read_text())
        vectors_path = args.fixture / 'tanh_vectors.hex'
        nodes_path = args.nodes / 'nodes.hex'
        assert sha(vectors_path) == fixture['tanh_vectors']['sha256'] == nodes['input_sha256']
        assert sha(nodes_path) == nodes['nodes_sha256'] and fixture['count'] == nodes['count']
        save(output / 'input_identity.json', {'fixture_report_sha256': sha(args.fixture / 'report.json'),
             'node_report_sha256': sha(args.nodes / 'report.json'), 'vectors_sha256': sha(vectors_path),
             'nodes_sha256': sha(nodes_path), 'count': args.count, 'boundary384_selected': True,
             'selection': 'Main first384 slots map to existing boundary records total_count-390..-7; rest to real prefix. Other phases unchanged; nonfinite6 retained.'})
        save(output / 'snapshot_prerun_sha256.json', inventory(args.build))
        events = []
        log = execute([VIV / 'xsim', 'tanh_ce26_sim', '-runall', '-testplusarg', 'COUNT=' + str(args.count),
                       '-testplusarg', 'TOTAL_COUNT=' + str(fixture['count']), '-testplusarg', 'VECTORS=' + str(vectors_path),
                       '-testplusarg', 'NODES=' + str(nodes_path), '-testplusarg', 'PROGRESS_FILE=' + str(output / 'semantic_progress.jsonl')], args.build, events)
        (output / 'xsim.log').write_text(log)
        assert 'HARDWARE_AGENT_SIM_PASS TANH8' in log
        match = re.search(r'TANH_CE_EQUIVALENCE_PASS idle_ce0=(\d+) active_ce1=(\d+) pending_empty_pipe=(\d+) first=(\d+) middle=(\d+) last=(\d+) valid_events=(\d+) core152_checks=(\d+) wrapper_consume_latency=(\d+) no_reset_newgen8=1 boundary384=1', log)
        assert match and int(match[9]) == 153
        progress = [json.loads(line) for line in (output / 'semantic_progress.jsonl').read_text().splitlines()]
        assert progress and progress[-1]['checked'] == args.count + 2630
        post = inventory(args.build)
        assert all(post[name] == digest for name, digest in manifest['snapshot'].items())
        save(output / 'snapshot_postrun_sha256.json', post)
        save(output / 'report.json', {'status': 'PASS_THREE_VERSION_TANH_CE_PUBLIC_EQUIVALENCE',
             'main_count': args.count, 'measurements': dict(zip(('idle_ce0_cycles', 'active_ce1_cycles', 'pending_empty_pipe_cycles', 'first_stage_cycles', 'middle_stage_cycles', 'last_stage_cycles', 'valid_response_events', 'core152_latency_checks', 'wrapper_consume_latency'), map(int, match.groups()))),
             'build_manifest_sha256': sha(args.build / 'report.json'), 'source_sha256': manifest['source_sha256'],
             'input_identity_sha256': sha(output / 'input_identity.json'), 'last_semantic_progress': progress[-1],
             'runtime_events': events, 'protocol_internal_fault_injection': 'NOT_RUN; no forced state/credit/token',
             'joint_speedup': 'NOT_RUN', 'physical_timing': 'NOT_RUN'})


if __name__ == '__main__':
    main()
