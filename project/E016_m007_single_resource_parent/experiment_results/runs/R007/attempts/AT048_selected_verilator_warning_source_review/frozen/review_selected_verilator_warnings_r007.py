#!/usr/bin/env python3
"""Read-only audit of exactly AT013's 3 SIDEEFFECT and 2 MODDUP warnings."""
import argparse
import ast
import ctypes
import difflib
import hashlib
import json
import os
from pathlib import Path
import re
import resource
import time


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def brace_block(text, opening):
    depth = 0
    for i in range(opening, len(text)):
        depth += (text[i] == '{') - (text[i] == '}')
        if depth == 0:
            return text[opening + 1:i], i + 1
    raise AssertionError('unclosed generated block')


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
    attempt = root / 'project/E021_m007_compiled_rtl_validation/experiment_results/runs/R001/attempts/AT013_residual_gold_group32'
    manifest_path = attempt / 'source_manifest.json'
    manifest = json.loads(manifest_path.read_text())
    files = [Path(x['path']) for x in manifest['sources_and_inputs'] if Path(x['path']).suffix in ('.sv', '.v')]
    identities = {x['path']: x['sha256'] for x in manifest['sources_and_inputs']}
    byname = {p.name: p for p in files}
    old = byname['attention_tile_service_v1.sv']
    pref = byname['attention_tile_service_prefetch_v1.sv']
    soft = byname['laya_attention_softmax_engine_v1.sv']
    for p in (old, pref, soft):
        assert sha(p) == identities[str(p)]
    log_path = attempt / 'guard_translate/driver.log'
    log = log_path.read_text()
    selected = [line for line in log.splitlines() if re.match(r'%Warning-(SIDEEFFECT|MODDUP):', line)]
    assert sum('Warning-SIDEEFFECT:' in s for s in selected) == 3
    assert sum('Warning-MODDUP:' in s for s in selected) == 2
    (out / 'selected_diagnostics.txt').write_text('\n'.join(log.splitlines()[:26]) + '\n')
    module_results = []
    for name in ('attention_tile_bank', 'attention_tile_service_v1'):
        extract = lambda p: re.search(r'\bmodule\s+' + name + r'\b.*?\bendmodule\b', p.read_text(), re.S).group()
        aa, bb = extract(pref), extract(old)
        (out / (name + '.diff')).write_text('\n'.join(difflib.unified_diff(bb.splitlines(), aa.splitlines(), fromfile=old.name, tofile=pref.name)) + '\n')
        refs = []
        for p in files:
            if p in (old, pref):
                continue
            clean = re.sub(r'/\*.*?\*/|//[^\n]*', '', p.read_text(), flags=re.S)
            for m in re.finditer(r'\b' + name + r'\b', clean):
                refs.append({'file': str(p.relative_to(root)), 'offset': m.start()})
        assert not refs
        module_results.append({'module': name, 'module_bodies_byte_identical': aa == bb, 'prefetch_body_sha256': hashlib.sha256(aa.encode()).hexdigest(), 'old_body_sha256': hashlib.sha256(bb.encode()).hexdigest(), 'body_bytes': [len(aa.encode()), len(bb.encode())], 'references_outside_the_two_definition_files': refs, 'active_instance_in_current_top': False})
    assert module_results[0]['module_bodies_byte_identical']
    assert not module_results[1]['module_bodies_byte_identical']
    text = soft.read_text()
    functions = {name: re.search(r'function automatic (?:int|bit) ' + name + r'\b.*?endfunction', text, re.S).group() for name in ('tr', 'tv')}
    assert all('input logic[95:0]t,input int g' in f and 'case(g)' in f for f in functions.values())
    assert all(not re.search(r'\+\+|--|\$|\b(ref|inout)\b|<=', f) for f in functions.values())
    assert 'dfp[tr(fp_req_tag,g)%64]++;' in text
    assert [int(x) for x in re.findall(r"int'\(t\[\d+:(\d+)\]\)", functions['tr'])] == [4, 16, 28, 40, 51, 61, 70, 78]
    assert [int(x) for x in re.findall(r'return t\[(\d+)\]', functions['tv'])] == [11, 23, 35, 47, 58, 68, 77, 85]
    (out / 'source_functions.txt').write_text('\n'.join(functions.values()) + '\n' + text.splitlines()[151] + '\n')
    obj = attempt / 'work/obj'
    generated = sorted(p for p in obj.iterdir() if p.suffix in ('.cpp', '.h'))
    prefix = 'vlSelf->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__head__DOT__'
    lowered = []
    generated_absent_names = []
    for p in generated:
        cpp = p.read_text()
        assert not any(n in cpp for n in ('attention_tile_bank', 'attention_tile_service_v1'))
        generated_absent_names.append(p.name)
        for fire in re.finditer(r'if \(' + re.escape(prefix) + r'softmax__DOT__fp_fire\) \{', cpp):
            body, end = brace_block(cpp, fire.end() - 1)
            temps = list(re.finditer(r'(__Vtemp_\d+) = \(\(IData\)\(1U\) \+ ' + re.escape(prefix) + r'softmax__DOT__dfp', body))
            assert len(temps) == 8
            blocks = []
            for g, match in enumerate(temps):
                write_end = re.search(r'= ' + match[1] + r';', body[match.end():])
                assert write_end
                segment = body[match.start():match.end() + write_end.end()]
                calls = re.findall(r'\(\[&\]\(\) \{(.*?)\}\(\), (?:vlSelf->)?(\w+__Vfuncout)\)', segment, re.S)
                assert len(calls) == 2
                read, write = calls
                normalize = lambda s: re.sub(r'\s+', '', re.sub(r'__Vlabel\d+', '__LABEL', re.sub(r'__tr__\d+__', '__tr__CALL__', s)))
                assert normalize(read[0]) == normalize(write[0])
                for call, result in calls:
                    local = result.removesuffix('__Vfuncout')
                    assert re.search(re.escape(local) + r'__g = ' + str(g) + r'U;', call)
                    expressions = re.findall(re.escape(result) + r'\s*=\s*(.*?);', call, re.S)
                    assert len(expressions) == 8
                    for branch, expression in enumerate(expressions):
                        e = re.sub(r'(?:vlSelf->)?' + re.escape(local) + r'__t', 't', expression)
                        e = re.sub(r'(0x[0-9a-f]+|\d+)U\b', r'\1', e)
                        tree = ast.parse(e.strip(), mode='eval')
                        assert all(isinstance(n, (ast.Expression, ast.BinOp, ast.BitAnd, ast.BitOr, ast.LShift, ast.RShift, ast.Name, ast.Load, ast.Subscript, ast.Constant)) for n in ast.walk(tree))
                        for tag in [0, (1 << 96) - 1] + [1 << b for b in range(96)]:
                            words = [(tag >> (32 * k)) & 0xffffffff for k in range(3)]
                            actual = eval(compile(tree, '<pure generated index expression>', 'eval'), {'__builtins__': {}}, {'t': words})
                            expected = (tag >> [4, 16, 28, 40, 51, 61, 70, 78][branch]) & 127
                            assert actual == expected
                assert len(re.findall(re.escape(prefix) + r'softmax__DOT__dfp', segment)) == 2
                blocks.append({'group': g, 'temporary': match[1], 'read_and_write_index_lambda_bodies_identical': True, 'both_index_evaluations_receive_same_group_and_tag': True, 'all_8_return_branches_match_7bit_source_slices_on_zero_ones_and_96_onehot_tags': True})
            assert not re.search(re.escape(prefix) + r'sm_fp_req_tag\[[^\]]+\]\s*=', body)
            raw = cpp[fire.start():end]
            evidence_name = p.stem + '_fp_fire.txt'
            (out / evidence_name).write_text(raw)
            lowered.append({'file': str(p.relative_to(root)), 'sha256': sha(p), 'start_line': cpp[:fire.start()].count('\n') + 1, 'groups_in_sequential_order': blocks, 'snapshot': evidence_name})
    assert len(lowered) == 3
    result = {'schema': 'm007-r007-selected-warning-source-review-v1', 'status': 'NO_RESULT_CHANGING_RISK_IDENTIFIED_IN_THE_FIVE_SELECTED_WARNINGS_SOURCE_ONLY', 'source_attempt': str(attempt.relative_to(root)), 'warning_log_sha256': sha(log_path), 'source_manifest_sha256': sha(manifest_path), 'selected_warning_counts': {'SIDEEFFECT': 3, 'MODDUP': 2}, 'selected_diagnostics': selected, 'module_duplicate_audit': module_results, 'duplicate_declaration_binding': 'Translation log identifies prefetch file as original declaration, old file as duplicate; neither service/bank has an active current-top instance. Current source uses layer.head.softmax_engine_v1 and shared resources storage_v1.', 'source_functions': functions, 'SIDEEFFECT_assessment': 'Standalone postfix ++ discards old expression value. tr/tv are automatic input-only bit extraction with no observable side effects. Generated code repeats only pure index calculation, reads current dfp into temporary old+1 then writes the identical index before the next group. Colliding groups accumulate sequentially; return/decrement logic follows. No concrete semantics mismatch was found.', 'generated_increment_blocks': lowered, 'generated_files_checked_for_absence': generated_absent_names, 'latent_boundary': 'The two unused service module definitions are not byte-identical and must not be treated as interchangeable for a future top that instantiates this legacy name. No cleanup or production edit is authorized or performed here.', 'code_changes': [], 'EDA_or_CXX_compile_or_RTL_or_floating_model_run': False, 'scope_limit': 'Read-only source/generated-code inspection for exactly five diagnostics. No claim about the other 513 warnings, X propagation, complete Encoder/fullgraph correctness or performance. Actual gold execution remains A012-owned.', 'resource_policy_self': {'affinity': affinity, 'nice': nice, 'ioprio_class': io >> 13, 'initial_MemAvailable_KiB': available, 'max_RSS_KiB': resource.getrusage(resource.RUSAGE_SELF).ru_maxrss, 'address_space_limit_B': 1024 ** 3}, 'wall_s': time.monotonic() - start}
    (out / 'warning_source_review.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({k: result[k] for k in ('status', 'selected_warning_counts', 'code_changes', 'resource_policy_self', 'wall_s')}))


if __name__ == '__main__':
    main()
