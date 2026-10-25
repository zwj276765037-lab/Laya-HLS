#!/usr/bin/env python3
"""Read-only post-fixture TB and exact EXP initialization source audit."""
import argparse
import ctypes
import hashlib
import json
import os
from pathlib import Path
import re
import resource
import time


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def main():
    start = time.monotonic()
    ap = argparse.ArgumentParser()
    ap.add_argument('--root', type=Path, required=True)
    ap.add_argument('--out', type=Path, required=True)
    a = ap.parse_args()
    root, out = a.root.resolve(), a.out.resolve()
    out.mkdir(parents=True, exist_ok=False)
    resource.setrlimit(resource.RLIMIT_AS, (1024 ** 3, 1024 ** 3))
    affinity = sorted(os.sched_getaffinity(0))
    nice = os.getpriority(os.PRIO_PROCESS, 0)
    io = ctypes.CDLL(None).syscall(252, 1, 0)
    available = int(next(x.split()[1] for x in Path('/proc/meminfo').read_text().splitlines() if x.startswith('MemAvailable:')))
    assert affinity and set(affinity) <= set(range(4)) and nice == 19 and io >> 13 == 3
    assert available > 192 * 1024 * 1024
    source_attempt = root / 'project/E021_m007_compiled_rtl_validation/experiment_results/runs/R001/attempts/AT013_residual_gold_group32'
    manifest_path = source_attempt / 'source_manifest.json'
    manifest = json.loads(manifest_path.read_text())
    files = [Path(x['path']) for x in manifest['sources_and_inputs'] if Path(x['path']).suffix in ('.sv', '.v')]
    byname = {p.name: p for p in files}
    top, leaf = byname['m007_fullmodel_encoder_1d_tb.sv'], byname['attention_exp_leaf.v']
    identities = {x['path']: x['sha256'] for x in manifest['sources_and_inputs']}
    assert all(sha(p) == identities[str(p)] for p in (top, leaf))
    tb, lv = top.read_text(), leaf.read_text()
    clean = lambda t: re.sub(r'"(?:\\.|[^"\\])*"', '""', re.sub(r'/\*.*?\*/|//[^\n]*', '', t, flags=re.S))
    assert not re.search(r'\b(fork|join|join_any|join_none|disable|event)\b', clean(tb))
    assert not re.search(r'#\s*0\b(?!\.)', clean(tb))
    assert 'task automatic step;begin @(posedge clk);#0.1;end endtask' in tb
    assert 'repeat(4)step();@(negedge clk);rst_n=1;wait(cmd_ready);' in tb
    init = re.search(r'// power-on initialization\s*initial begin(.*?)\nend', lv, re.S)
    assignments = re.findall(r'#0\s+(\w+)\s*=\s*([^;]+);', init.group(1))
    assert len(assignments) == 168
    assert assignments[0] == ('ap_CS_fsm', "1'd1")
    assert assignments[1:] == [('ap_enable_reg_pp0_iter' + str(k), "1'b0") for k in range(1, 168)]
    assert all(re.search(r'if\s*\(ap_rst == 1\x27b1\)\s*begin\s*' + var + r'\s*<=\s*1\x27b0;', lv) for var, value in assignments[1:])
    assert "parameter    ap_ST_fsm_pp0_stage0 = 1'd1;" in lv
    assert re.search(r'if\s*\(ap_rst == 1\x27b1\)\s*begin\s*ap_CS_fsm\s*<=\s*ap_ST_fsm_pp0_stage0;', lv)
    zero_sources = []
    for p in files:
        n = len(re.findall(r'#\s*0\b(?!\.)', clean(p.read_text())))
        if n:
            zero_sources.append({'path': str(p.relative_to(root)), 'sha256': sha(p), 'explicit_zero_delay_count': n})
    assert len(zero_sources) == 1 and zero_sources[0]['explicit_zero_delay_count'] == 168
    generated = []
    lanes = {str(k): [] for k in range(8)}
    pattern = r'co_await vlSelf->__VdlySched.delay\(0U,\s*nullptr,\s*"([^"]+)",\s*(\d+)\);\s*(vlSelf->[^;]+;)'
    for p in sorted((source_attempt / 'work/obj').glob('*.cpp')):
        cpp = p.read_text()
        matches = []
        for match in re.finditer(pattern, cpp):
            if match[1] != str(leaf):
                continue
            lane = re.search(r'exp_lane__BRA__(\d+)__KET__', match[3]).group(1)
            line = int(match[2])
            assert 913 <= line <= 1080
            assert assignments[line - 913][0] in match[3]
            lanes[lane].append(line)
            matches.append({'lane': int(lane), 'source_line': line, 'generated_line': cpp[:match.start()].count('\n') + 1})
        if matches:
            generated.append({'file': str(p.relative_to(root)), 'sha256': sha(p), 'matches': matches})
    assert all(sorted(lines) == list(range(913, 1081)) for lines in lanes.values())
    (out / 'original_initial_block.vpart').write_text(init.group() + '\n')
    tb_lines = tb.splitlines()
    (out / 'original_TB_timing_excerpts.svpart').write_text('\n'.join(tb_lines[430:460]) + '\n\n' + '\n'.join(tb_lines[631:692]) + '\n')
    result = {'schema': 'm007-r007-original-zero-delay-source-review-v1', 'status': 'EXACT_ZERO_DELAY_INITIALIZATION_CANDIDATE_BOUND_SOURCE_ONLY', 'top': {'path': str(top.relative_to(root)), 'sha256': sha(top), 'fixture_end_line': 632, 'first_timed_sequence_line': 676, 'step_task_line': 431, 'fork_join_disable_named_event': False, 'explicit_zero_delay': False, 'finding': 'No evidence for a wait/event/task cancellation defect. First task timing is posedge then 0.1ns delay. Macro expansion of step would be equivalent but the generated source already inlines its body and this does not address the observed zero-delay queue.'}, 'source_manifest_sha256': sha(manifest_path), 'leaf_initialization': {'path': str(leaf.relative_to(root)), 'sha256': sha(leaf), 'block_lines': [912, 1081], 'zero_delay_statement_lines': [913, 1080], 'statements': len(assignments), 'all_initialized_variables_reset_synchronously_to_same_values': True}, 'all_closure_explicit_zero_delay_sources': zero_sources, 'generated_binding': generated, 'actual_generated_zero_delay_count': sum(len(x) for x in lanes.values()), 'lane_count': len(lanes), 'diagnosis_boundary': 'A012 reports its disassembly/runtime audit locates the crashing clear in VlDelayScheduler m_zeroDelayed. This source audit binds the exact repeated #0 sequence; it does not itself execute a reproduction or prove a runtime fix.', 'minimal_reproduction_suggestion': 'A012-owned small same-tool/same-flags test: initial begin #0 a=1; #0 b=0; end, then expand independently to168 sequential #0 and8 instances if needed. Keep event/delay completion assertions. No full production build is needed to test the reentrant zero-delay-queue hypothesis.', 'compatibility_assessment': 'Do not modify TB waits or remove #0 without evidence. Removing/coalescing the168 #0 changes IEEE t0 inactive-region ordering and is not a general SV-equivalent rewrite. Its post-reset data equality would require a separately authorized reset-bound compatibility proof. A runtime queue batch fix can preserve the original source, gold and delta semantics and belongs to A012 isolated tooling, subject to actual small reproduction and regression.', 'code_changes': [], 'EDA_or_CXX_compile_or_RTL_or_floating_model_run': False, 'scope_limit': 'Read-only exact source/generated binding, not complete Encoder math, runtime repair, timing or physical evidence.', 'resource_policy_self': {'affinity': affinity, 'nice': nice, 'ioprio_class': io >> 13, 'initial_MemAvailable_KiB': available, 'max_RSS_KiB': resource.getrusage(resource.RUSAGE_SELF).ru_maxrss, 'address_space_limit_B': 1024 ** 3}, 'wall_s': time.monotonic() - start}
    (out / 'zero_delay_source_review.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({k: result[k] for k in ('status', 'actual_generated_zero_delay_count', 'lane_count', 'code_changes', 'resource_policy_self', 'wall_s')}))


if __name__ == '__main__':
    main()
