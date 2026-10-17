"""Read-only identity/layout checks; no arithmetic reference or new gold."""
import hashlib
import json
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
started = time.monotonic()
wi_root = ROOT / 'project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/attempts/t2_widown_av_fixtures_01/work/fixtures'
ln_root = ROOT / 'project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT040_LNF0_ffn4_02/fixture'
p1_root = ROOT / 'project/E002_Laya_HLS/experiment/results/engineering_p1/20261007T021236Z-1800667/fixture/cases/wi_ln_rows1'

def sha(data):
    return hashlib.sha256(data).hexdigest()

def identity(path):
    data = path.read_bytes()
    return {'path': str(path.relative_to(ROOT)), 'bytes': len(data), 'sha256': sha(data)}

manifest = json.loads((wi_root / 'manifest.json').read_text())
case = next(c for c in manifest['cases'] if c['name'] == 'wi_rows4')
assert (case['rows'], case['K'], case['N']) == (4, 1024, 5248)
records = {}
data = {}
for name, record in case['products'].items():
    path = wi_root / Path(record['path']).name
    records[name] = identity(path)
    assert records[name]['bytes'] == record['bytes']
    assert records[name]['sha256'] == record['sha256']
    if name in ('source_f32', 'a8_q', 'a8_scale', 'output_f32'):
        data[name] = path.read_bytes()
ln_fixture = json.loads((ln_root / 'fixture.json').read_text())
for name in ('source', 'gold'):
    path = ln_root / Path(ln_fixture[name]['path']).name
    records['ln_' + name] = identity(path)
    assert records['ln_' + name]['sha256'] == ln_fixture[name]['sha256']
ln_input = (ln_root / 'source_rows4.f32.bin').read_bytes()
ln_gold = (ln_root / 'gold_rows4.f32.bin').read_bytes()
assert ln_gold == data['source_f32']
p1_input = (p1_root / 'input_f32.bin').read_bytes()
p1_q = (p1_root / 'dut.q8.bin').read_bytes()
p1_a = b''.join(p1_q[g * 34 + 2:g * 34 + 34] for g in range(32))
p1_s = b''.join(p1_q[g * 34:g * 34 + 2] for g in range(32))
row0 = {
    'pre_ln_input': {'bytes': 4096, 'sha256': sha(ln_input[:4096])},
    'ln_output': {'bytes': 4096, 'sha256': sha(ln_gold[:4096])},
    'q8': {'bytes': 1024, 'sha256': sha(data['a8_q'][:1024])},
    'scale': {'bytes': 64, 'sha256': sha(data['a8_scale'][:64])},
    'final': {'bytes': 5248 * 4, 'sha256': sha(data['output_f32'][:5248 * 4])},
}
steps_path = wi_root / Path(case['products']['steps_u32x6']['path']).name
with steps_path.open('rb') as stream:
    first_row_steps = stream.read(32 * 5248 * 24)
row0['steps_u32x6'] = {'bytes': len(first_row_steps), 'sha256': sha(first_row_steps),
                        'layout': '[row,group,column,6] little-endian u32: dot,sa,sw,product,term,PS'}
source_paths = [
    'project/E002_Laya_HLS/experiment/vivado/module_design/layernorm_engine/rtl/laya_lnq_row_v1.sv',
    'project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/tm4tn8_sync_ps_front_v2.sv',
    'project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/tm4tn8_row_pipeline_v1.sv',
    'project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/tm4tn8_fp_restore_v1.sv',
    'project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/tm4tn8_matrix_resident_v2.sv',
    'project/E002_Laya_HLS/experiment/vivado/module_design/hbm_loader_and_cache/rtl/t4_dual_w_cache_v1.sv',
    'project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/make_real_fixtures.py',
    'project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/make_tm4_real_streams.py',
]
result = {
    'scope': 'static identities/layout only; no new gold or numerical execution',
    'source_identities': [identity(ROOT / p) for p in source_paths],
    'fixture_manifest': identity(wi_root / 'manifest.json'),
    'ln_fixture_manifest': identity(ln_root / 'fixture.json'),
    'products': records,
    'ln_gold_equals_wi_quant_source_all_four_rows': True,
    'row0': row0,
    'p1_same_pre_ln_input': p1_input == ln_input[:4096],
    'p1_same_ln_output': (p1_root / 'dut.ln.bin').read_bytes() == ln_gold[:4096],
    'p1_same_quantized_row': p1_a == data['a8_q'][:1024] and p1_s == data['a8_scale'][:64],
    'p1_final_columns': (p1_root / 'dut.linear.bin').stat().st_size // 4,
    'wi_bias_kind': case['model_record']['bias_kind'],
    'static_counts': {'groups': 32, 'tiles': 656, 'stripes': 32 * 656,
                      'macs_one_row': 1024 * 5248, 'ps_lane_group_one_row': 32 * 5248,
                      'final_bytes_one_row': 5248 * 4, 'cold_w_payload_bytes': 2 * 2686976 + 335872,
                      'cold_w_64B_beats': [2686976 // 64, 2686976 // 64, 335872 // 64],
                      'ps_payload_four_physical_rows': 4 * 8 * 656 * 4,
                      'ps_meta_four_physical_rows': 4 * 656 * 2},
    'process_seconds': time.monotonic() - started,
}
out = Path(__file__).with_name('lnq_matrix_binding_20261015.json')
out.write_text(json.dumps(result, ensure_ascii=False, indent=2) + '\n')
print(json.dumps({k: result[k] for k in ['ln_gold_equals_wi_quant_source_all_four_rows', 'row0',
      'p1_same_pre_ln_input', 'p1_same_ln_output', 'p1_same_quantized_row', 'p1_final_columns',
      'wi_bias_kind', 'static_counts', 'process_seconds']}, ensure_ascii=False))
