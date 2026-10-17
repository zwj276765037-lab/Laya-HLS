"""Bounded static identities/integer port-map checks; never imports DUT/oracle."""
import hashlib
import json
import os
from pathlib import Path
import resource
import subprocess
import time

start = time.monotonic()
root = Path(__file__).resolve().parents[2]
rtl = Path('project/E002_Laya_HLS/experiment/vivado/module_design')
core_dir = rtl / 'q8_linear_and_restore/tm1tn8_gs32_512/rtl'
paths = {
    'core': core_dir / 'laya_lnq_wi_gqdown_row_v1.sv',
    'wrapper': core_dir / 'laya_qkv_scratch_row_v1.sv',
    'sequencer': core_dir / 'laya_qkv_s128_request_v1.sv',
    'lnq': rtl / 'layernorm_engine/rtl/laya_lnq_row_v1.sv',
    'writer': core_dir / 'tm1tn8_axi512_writer.sv',
    'source_reader': rtl / 'hbm_loader_and_cache/rtl/t4_w_reader_port_v1.sv',
    'aux_reader': rtl / 'hbm_loader_and_cache/rtl/t4_aux_bias_reader_v1.sv',
    'rev18_report': Path('project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev18_q16_owner_ln128_cost_engineering_handoff_20261015.md'),
}
expected = {
    'core': 'a73632b8a85fae646b36c0355065b19a5f91b4067440c5f96f14726726197e54',
    'wrapper': '5c88716f2a9c60f065dab6358c7d9b1d336ab1eaba689f04ae37e31b74158e26',
    'sequencer': 'a4c999e5e7e5ea63c95dd7abf9d70d0eb4362b06b36e080b2670807c9500bca4',
}
identities = []
for role, path in paths.items():
    data = (root / path).read_bytes()
    digest = hashlib.sha256(data).hexdigest()
    if role in expected:
        assert digest == expected[role], (role, digest)
    identities.append(dict(role=role, path=str(path), bytes=len(data), sha256=digest))

checks = {
    'single_final_bank_payload_bytes': 8*656*4,
    'ln_norm_tile_range': [3072//8, 4095//8],
    'q16_window_words': 16*272,
    'q16_last_row_prep_overlap_bytes': len(set(range(15*272,16*272)) & set(range(4224,5248)))*4,
    'g_output_addr_range': [0, 2623//8],
    'g_gate_addr_range': [328, 655],
    'g_gate_write_address_overlap': bool(set(range(328)) & set(range(328,656))),
    'norm_row_result_tiles': 1024//8,
    'norm_row_writer_beats': 4096//64,
    'ln128_norm_words': 128*1024,
    'ln128_norm_okay_b': 128*4096//64,
}
assert checks['single_final_bank_payload_bytes'] == 20992
assert checks['ln_norm_tile_range'] == [384,511]
assert checks['q16_window_words'] == 4352
assert checks['q16_last_row_prep_overlap_bytes'] == 512
assert checks['g_output_addr_range'] == [0,327]
assert not checks['g_gate_write_address_overlap']
assert checks['norm_row_result_tiles'] == 128
assert checks['norm_row_writer_beats'] == 64
assert checks['ln128_norm_words'] == 131072
assert checks['ln128_norm_okay_b'] == 8192

record = {
    'task': 'm004-ln128-production-partition-interface-question-20261015',
    'scope': 'STATIC_DESIGN_ONLY; no EDA, DUT execution, model/oracle/gold or RTL modification',
    'identities': identities,
    'script_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
    'integer_checks': checks,
    'prior_cost_source': 'rev18_report (engineering report; no new guard re-audit)',
    'design': {
        'route': 'one LNQ/bank leaf plus one source/norm IO+staged sequencer service; both are actual parent instances',
        'bank_ports': 'preserve synchronous G 8-lane read plus scalar return write on distinct addresses; never drop non-backpressurable matrix/G/ADD returns',
        'writer_readers': 'move existing shared instances and route locks; no additional reader/writer or whole-row RAM',
        'regression_groups': 4,
        'new_execution': 'NOT_RUN',
        'full_parent_same_runtime': 'NOT_RUN',
        'performance_gain': 'UNKNOWN',
    },
    'measurement_before_record_write': {
        'monotonic_s': time.monotonic()-start,
        'maxrss_kib': resource.getrusage(resource.RUSAGE_SELF).ru_maxrss,
        'affinity': sorted(os.sched_getaffinity(0)),
        'nice': os.getpriority(os.PRIO_PROCESS,0),
        'io_priority': subprocess.check_output(['ionice','-p',str(os.getpid())], text=True).strip(),
        'interactive_reads_cumulative': 'UNKNOWN',
    },
    'external_measurement': 'ln128_partition_static_time_20261015.txt',
}
assert record['measurement_before_record_write']['affinity'] == [0,1,2,3]
assert record['measurement_before_record_write']['nice'] == 19
assert record['measurement_before_record_write']['io_priority'] == 'idle'
out = Path(__file__).with_name('ln128_production_partition_20261015.json')
out.write_text(json.dumps(record,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({'status':'PASS_STATIC_IDENTITIES_AND_INTEGER_MAP', 'identities':len(identities), 'record':str(out.relative_to(root))}))
