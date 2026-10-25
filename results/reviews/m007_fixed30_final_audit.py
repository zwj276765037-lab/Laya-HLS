"""Independent controller review of D37 artifacts; never generates DUT inputs."""
from pathlib import Path
from datetime import datetime, timezone
import hashlib
import json
import re
import time

ROOT = Path(__file__).resolve().parents[2]
RUN = ROOT / 'project/E021_m007_compiled_rtl_validation/experiment_results/runs/R005'
ATTEMPT = RUN / 'attempts/AT002_fixed_original30_kind7'


def read(path):
    return json.loads(path.read_text())


def sha(path):
    h = hashlib.sha256()
    with path.open('rb') as f:
        for b in iter(lambda: f.read(4 * 1024 * 1024), b''):
            h.update(b)
    return h.hexdigest()


def main():
    started = time.monotonic()
    work = ATTEMPT / 'work'
    manifest = read(ATTEMPT / 'source_manifest.json')
    checked = 0
    for entry in manifest['sources_and_inputs']:
        p = Path(entry['path'])
        assert p.stat().st_size == entry['bytes'] and sha(p) == entry['sha256'], p
        checked += 1
    assert manifest['actual_parameter'] == 0
    config = read(ATTEMPT / 'config.json')
    assert '-GVERIFY_POST_ENCODER27_H=0' in config['verilator_flags']
    assert '+KIND=7' in config['plusargs'] and '+LAYER=0' in config['plusargs']
    assert not any('POST_ENCODER27_H' in a or a.startswith('+STOP') for a in config['plusargs'])
    guard = read(ATTEMPT / 'guard_rtl/guard_result.json')
    driver = read(work / 'fixed30_driver_receipt.json')
    assert guard['child_exit_code'] == 0 and guard['trigger'] is None
    assert driver['verdict'] == 'PASS' and driver['raw_child_return_code'] == 0
    assert driver['completed_global_layers'] == list(range(30))
    assert not driver['error_or_fatal']
    raw = (ATTEMPT / 'guard_rtl/driver.log').read_text()
    marker = 'HARDWARE_AGENT_SIM_PASS M007_FULLGRAPH_BINARY kind=7 layers=30 matrix=120 outputs=544 actual_tail_commit=1'
    assert raw.splitlines().count(marker) == 1
    assert not re.search(r'%Error|%Fatal|Assertion failed|\bAborting\b|M007_(?:LAYER|ENDPOINT)_CAPTURE_ERROR', raw)
    raw_layers = [int(x) for x in re.findall(r'^M007_FULLGRAPH_LAYER_END global=(\d+) ', raw, re.M)]
    assert raw_layers == list(range(30))
    fc2 = re.findall(r'^M007_DECISION_FC2_ADMITTED global=(\d+) writes=16384 acks=16384 closed=1 success=1 published=1 debt=0 cycle=\d+$', raw, re.M)
    assert fc2 == ['28', '29']
    obs_lines = re.findall(r'^M007_FULLGRAPH_OBS .*$', raw, re.M)
    assert obs_lines
    observations = [{k: int(v) for k, v in re.findall(r'([a-zA-Z0-9_]+)=(\d+)', line)} for line in obs_lines]
    counts = observations[-1]
    expected = dict(commands=1, h_count=4096, catalog_runtime=120, matrix_commands=120,
                    layers_completed=30, ln_commands=60, vector_commands=61,
                    g_commands=28, exports=544, tail_commits=1, tail_writes=544,
                    final_norm_count=4096, type_count=4096, global_layer=29)
    assert all(counts.get(k) == v for k, v in expected.items())
    for key, maximum in expected.items():
        values = [o[key] for o in observations]
        assert all(a <= b for a, b in zip(values, values[1:])) and max(values) == maximum
    stages = driver['completed_stages']
    assert len(stages) == 782
    raw_lines = set(raw.splitlines())
    for stage in stages:
        assert stage['actual_success_line'] in raw_lines
        assert stage['duration_seconds'] <= 120
    heads = [s for s in stages if re.fullmatch(r'head\d+_success', s['stage'])]
    assert len(heads) == 480
    for layer in range(30):
        assert [s['stage'] for s in heads if s['global_layer'] == layer] == [f'head{i}_success' for i in range(16)]
    assert max(x['duration_seconds'] for x in driver['layer_records']) <= 600
    assert guard['elapsed_seconds'] <= 15000
    assert driver['whole_bridge_complete']
    bridge = driver['actual_output_integrity']['whole_Encoder27_finalLN_type_Decision0preLN_seconds']
    assert bridge <= 120
    assert set(x['threads'] for x in driver['actual_thread_samples']) == {1}
    capture = read(ROOT / 'results/reviews/m007_fixed30_all_layer_capture_review_20261024.json')
    assert capture['complete_layer_captures_verified'] == 30
    binding = ROOT / 'project/E016_m007_single_resource_parent/experiment_results/runs/R007/attempts/AT044_original47_fullgraph_byte_binding/work/fixture/manifest.json'
    refs = {x['name']: x for x in read(binding)['original_checkpoints_47']}
    for name, suffix in [('embedding_norm', 'H0'), ('final_norm', 'final_norm.f32'), ('type_add', 'type_add.f32')]:
        actual = work / ('actual_fullgraph.' + suffix + '.bin')
        original = ROOT / refs[name]['path']
        assert sha(original) == refs[name]['sha256']
        assert actual.read_bytes() == original.read_bytes()
    decision = (work / 'actual_fullgraph.layer29.f32.bin').read_bytes()
    tail = (work / 'actual_fullgraph.output.bin').read_bytes()
    gathered = b''.join(decision[row * 4096:(row + 1) * 4096] for row in [23, 33] + [0] * 15)
    assert len(tail) == 69632 and tail == gathered
    tail_hex = binding.parent / 'tail544.hex'
    assert tail == b''.join(int(x, 16).to_bytes(128, 'little') for x in tail_hex.read_text().splitlines() if x.strip())
    receipt = (work / 'actual_fullgraph.receipt.txt').read_text()
    assert 'BEGIN=1 layers=30 matrices=120 LN=60 vector=61 GEGLU=28 tail_commits=1 done_consumed=1 ' in receipt
    cycles = int(re.search(r'cycles=(\d+)', receipt).group(1))
    assert cycles < 40000000
    result = dict(
        decision='D-M007-SM012-FIXED-ORIGINAL30-37', checked_utc=datetime.now(timezone.utc).isoformat(),
        verdict='PASS_FIXED_ORIGINAL30_ONCE_BEGIN_NORMAL_PATH',
        scope='Repair version, parameter0, original embedding input, 28Encoder+2Decision, one continuous kind7 BEGIN',
        attempt=str(ATTEMPT), frozen_execution_identity_entries_rechecked=checked,
        execution_manifest_sha256=sha(ATTEMPT / 'source_manifest.json'),
        actual_source_parameter=0, original_raw_terminal=marker, raw_child_return_code=0,
        counts=counts, heads=480, independently_reconstructed_actual_layers=30,
        layer_capture_review='results/reviews/m007_fixed30_all_layer_capture_review_20261024.json',
        finalLN_type_capture_review='results/reviews/m007_fixed30_finalLN_type_actual_review_20261024.json',
        initial_H_bytes=524288, final_output_bytes=len(tail), final_output_sha256=hashlib.sha256(tail).hexdigest(),
        actual_gather_from_Decision1_equal_original_tail=True, original_receipt=receipt,
        cycles=cycles, RTL_guard_seconds=guard['elapsed_seconds'], driver_seconds=driver['elapsed_seconds'],
        max_layer_seconds=max(x['duration_seconds'] for x in driver['layer_records']),
        max_stage_seconds=max(x['duration_seconds'] for x in stages),
        whole_finalLN_handoff_seconds=bridge, checked_stage_count=len(stages),
        actual_model_thread_counts=[1], owned_peak_RSS_KiB=guard['peak_owned_rss_kb'],
        raw_cumulative_observations=len(observations), cumulative_counts_monotone_to_exact_final=True,
        minimum_MemAvailable_KiB=guard['minimum_mem_available_kb'],
        historical_D35_FAIL_and_D36_segmented_PASS_preserved=True,
        limitations=['One original request normal path in validated two-state compiled RTL backend',
                     'No claim of all fault/reset or four-state behavior',
                     'No OOC/P&R, achieved Fmax, board, Host/DMA integration or measured FPGA throughput'],
        final_archive_and_pause='PENDING_AGENT_ARCHIVE_AND_CONTROLLER_CLEANUP_RECHECK',
        review_wall_seconds=time.monotonic() - started)
    output = ROOT / 'results/reviews/m007_fixed30_final_review_20261024.json'
    output.write_text(json.dumps(result, ensure_ascii=False, indent=2) + '\n')
    print(json.dumps({'verdict': result['verdict'], 'identity_entries': checked,
                      'cycles': cycles, 'RTL_seconds': guard['elapsed_seconds'], 'review': str(output)}))


if __name__ == '__main__':
    main()
