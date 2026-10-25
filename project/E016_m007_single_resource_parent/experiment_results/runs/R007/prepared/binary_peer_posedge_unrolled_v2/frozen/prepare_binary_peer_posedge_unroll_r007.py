#!/usr/bin/env python3
"""Freeze only a constant-port expansion of the original peer posedge loop."""
from pathlib import Path
import difflib
import hashlib
import json
import re

ROOT = Path(__file__).resolve().parents[3]
R = ROOT / 'project/E016_m007_single_resource_parent/experiment_results/runs/R007'
BASE = R / 'prepared/fullgraph_kind6_kind7_public_boundary_v2/frozen/m007_binary_weight_peer_tb.sv'
OUT = ROOT / 'project/E002_Laya_HLS/experiment/vivado/module_design/forward_controller/tb/m007_binary_weight_peer_tb.sv'
PREP = R / 'prepared/binary_peer_posedge_unrolled_v2'
OLD_MANIFEST = R / 'prepared/fullgraph_retire_progress_v3/source_manifest.json'
OLD_SHA = '4d9265c219d1712327c31a0a0f3558d858563e84f0dc83374fc9431a0d31abe8'


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def rel(p):
    return str(p.relative_to(ROOT))


def dump(p, value):
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(json.dumps(value, indent=2) + '\n')


def main():
    assert sha(BASE) == OLD_SHA
    old = BASE.read_text()
    header = '   for(int p=0;p<4;p++)begin\n'
    start = old.index(header, old.index(' always@(posedge clk)begin\n'))
    end = old.index('   live=0;', start)
    loop = old[start:end]
    assert loop.endswith('   end\n') and loop.count(header) == 1
    body = loop[len(header):-len('   end\n')]
    # This body contains no comments or diagnostic strings with a standalone p.
    # Replace only the loop variable, preserving every original statement token.
    assert all(not re.search(r'\bp\b', s) for s in re.findall(r'"[^"\n]*"', body))
    blocks = [
        f'   begin : m007_peer_posedge_port_{p}\n'
        + re.sub(r'\bp\b', str(p), body) + '   end\n'
        for p in range(4)
    ]
    replacement = ''.join(blocks)
    new = old[:start] + replacement + old[end:]
    assert new.replace(replacement, loop, 1) == old
    assert new.count(' always@(posedge clk)begin\n') == old.count(' always@(posedge clk)begin\n')
    # Preserve any edit from another author rather than silently overwriting it.
    assert OUT.read_text() in (old, new), 'live peer changed outside this owner repair'
    frozen = PREP / 'frozen/m007_binary_weight_peer_tb.sv'
    frozen.parent.mkdir(parents=True, exist_ok=True)
    if frozen.exists():
        assert frozen.read_text() == new
    else:
        frozen.write_text(new)
    OUT.write_text(new)
    generator = PREP / 'frozen/prepare_binary_peer_posedge_unroll_r007.py'
    if generator.exists():
        assert generator.read_bytes() == Path(__file__).read_bytes()
    else:
        generator.write_bytes(Path(__file__).read_bytes())
    patch = R / 'binary_peer_posedge_unroll_v2.patch'
    patch.write_text(''.join(difflib.unified_diff(old.splitlines(True), new.splitlines(True),
                                              fromfile=rel(BASE), tofile=rel(frozen))))
    previous = json.loads(OLD_MANIFEST.read_text())
    rows = []
    replaced = 0
    for row in previous['compile_sources']:
        assert sha(ROOT / row['path']) == row['sha256'], row['path']
        if row['path'] == rel(BASE):
            rows.append({'path': rel(frozen), 'sha256': sha(frozen)})
            replaced += 1
        else:
            rows.append(row)
    assert replaced == 1 and len(rows) == 94
    report = {
        'schema': 'm007-r007-binary-peer-posedge-constant-port-source-v2',
        'status': 'SOURCE_FROZEN_INVERSE_PROOF_PASS_NOT_COMPILED_NOT_RUN',
        'module': 'm007_binary_weight_peer',
        'source': rel(frozen), 'sha256': sha(frozen),
        'live_source': rel(OUT), 'previous_source': rel(BASE), 'previous_sha256': OLD_SHA,
        'only_change': 'Expand only the original main posedge p=0..3 loop into four sequential constant-port begin blocks in the same always process, ordered0,1,2,3.',
        'inverse_reconstructs_previous_source_byte_exactly': True,
        'per_port_original_body_exact_after_only_loop_variable_substitution': [True] * 4,
        'original_NBA_operators_per_port': body.count('<='),
        'same_posedge_process_count': True,
        'reset_comb_negedge_functions_unit_checker_unchanged': True,
        'NBA_semantics_statement_order_function_calls_assertions_unchanged': True,
        'peer_cache_protocol_identity_unchanged': True,
        'production_top8b55_gold_changed': False,
        'patch': rel(patch), 'patch_sha256': sha(patch),
        'generator': rel(generator), 'generator_sha256': sha(generator),
        'compile_or_RTL': 'NOT_RUN_BY_A010',
        'prior_fullgraph_manifest': rel(OLD_MANIFEST),
        'prior_fullgraph_manifest_sha256': sha(OLD_MANIFEST),
        'fullgraph_top': previous['top'], 'fullgraph_top_source': previous['source'],
        'fullgraph_top_sha256': previous['sha256'],
        'compile_sources': rows, 'compile_source_count': len(rows),
        'unchanged_compile_source_records': 93,
        'ROM_initialization_files': previous['ROM_initialization_files'],
        'independent_expected_bytes': 'Reuse original AT038/039 fixture; no gold generation or math/model change.',
    }
    dump(PREP / 'source_manifest.json', report)
    dump(R / 'binary_peer_posedge_unroll_delivery.json', {
        k: v for k, v in report.items() if k != 'compile_sources'
    } | {'source_manifest': rel(PREP / 'source_manifest.json'),
         'source_manifest_sha256': sha(PREP / 'source_manifest.json')})
    print(json.dumps({'source': rel(frozen), 'sha256': sha(frozen),
                      'manifest': rel(PREP / 'source_manifest.json'),
                      'inverse_exact': True, 'compile_sources': len(rows),
                      'NBA_operators_per_port': body.count('<=')}, indent=2))


if __name__ == '__main__':
    main()
