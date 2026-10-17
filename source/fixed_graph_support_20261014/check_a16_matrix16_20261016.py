#!/usr/bin/env python3
"""Read-only frozen-source/byte/integer checks. Never imports a numeric oracle."""
import hashlib
import json
from pathlib import Path
import resource
import struct
import time

START = time.monotonic()
ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).parent
ATT = ROOT / 'project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts'
RTL = ROOT / 'project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl'
AT368 = ATT / 'AT368_SM004_rev21_chain_leaf_observer_01'
AT367 = ATT / 'AT367_SM004_rev21_parent_elab_mt4_01'
AT372 = ATT / 'AT372_SM004_rev21_core_wprep_o3_pilot_01'

def identity(p):
    b = p.read_bytes()
    return {'path': str(p.relative_to(ROOT)), 'bytes': len(b),
            'sha256': hashlib.sha256(b).hexdigest()}

checks = {}
sources = []
for attempt, names in [
    (AT368, ['laya_source_norm_service_v1.sv', 'laya_lnq_bank_service_v1.sv',
             'laya_w_prep_service_v1.sv', 't4_dual_w_cache_v1.sv']),
    (AT372, ['laya_lnq_wi_gqdown_row_v1.sv', 'tm4tn8_sync_ps_front_v2.sv',
             'tm4tn8_row_pipeline_v1.sv', 'laya_qkv_scratch_row_v1.sv']),
    (AT367, ['laya_qkv_s128_request_v1.sv']),
]:
    manifest = json.loads((attempt / 'source_manifest.json').read_text())
    entries = {e['path']: e for e in manifest['entries']}
    for name in names:
        frozen = identity(attempt / 'frozen' / name)
        e = entries['frozen/' + name]
        assert (frozen['sha256'], frozen['bytes']) == (e['sha256'], e['bytes'])
        current = (ROOT / 'project/E002_Laya_HLS/experiment/vivado/module_design/hbm_loader_and_cache/rtl' / name
                   if name == 't4_dual_w_cache_v1.sv' else RTL / name)
        now = identity(current)
        sources.append({'frozen': frozen, 'current_at_read': now,
                        'equal_at_read': frozen['sha256'] == now['sha256']})
checks['nine_selected_frozen_files_match_their_manifest'] = len(sources) == 9
old_engine = (AT367/'frozen/laya_lnq_wi_gqdown_row_v1.sv').read_text().split('module laya_lnq_wi_gqdown_row_v1 (')[0]
new_engine = (AT372/'frozen/laya_lnq_wi_gqdown_row_v1.sv').read_text().split('module laya_lnq_wi_gqdown_row_v1 (')[0]
checks['AT367_AT372_engine_prefix_equal'] = old_engine == new_engine

prior = json.loads((OUT/'embedding_qkv_binding_20261015.json').read_text())
products = prior['fixture_products']['qkv_rows4']
data = {k: (ROOT/v['path']).read_bytes() for k, v in products.items()}
# Parent identities are reused from the prior binding; selected windows below
# get fresh byte digests, with no floating point arithmetic.
checks['saved_product_sizes_match_prior_binding'] = all(len(data[k]) == v['bytes'] for k,v in products.items())
steps, final = data['steps_u32x6'], data['output_f32']
window_records = []
for tile in [0, 1, 127, 128, 255, 256, 383]:
    for r in range(4):
        indices = [((r*32+g)*3072+8*tile)*24 for g in range(32)]
        payload = b''.join(steps[x:x+192] for x in indices)
        foff = (r*3072+8*tile)*4
        fb = final[foff:foff+32]
        for lane in range(8):
            so = (((r*32+31)*3072+8*tile+lane)*6+5)*4
            assert steps[so:so+4] == fb[lane*4:lane*4+4]
        window_records.append({'row': r, 'tile': tile, 'n0': tile*8,
            'steps_group0_offset': indices[0], 'steps_group_stride': 3072*24,
            'steps_each_group_bytes': 192, 'steps_concat_bytes': len(payload),
            'steps_concat_sha256': hashlib.sha256(payload).hexdigest(),
            'final_offset': foff, 'final_bytes': 32,
            'final_sha256': hashlib.sha256(fb).hexdigest()})
checks['28_selected_windows_last_PS_equals_saved_final'] = True
scat = data['scatter_u32x4']
for r in range(4):
    for tile in [0, 1, 127, 128, 255, 256, 383]:
        for lane in range(8):
            n = tile*8+lane
            plane, rem = divmod(n, 1024)
            head, d = divmod(rem, 64)
            offset = ((((plane*2)*8+head//2)*1024+r)*64+d)*4
            record = struct.unpack_from('<4I', scat, (r*3072+n)*16)
            assert record == (head&1, offset, struct.unpack_from('<I',final,(r*3072+n)*4)[0],r)
checks['224_selected_scatter_records_match_integer_layout'] = True

# Exact physical word ownership: Q16 is dense, PS is disjoint and r15
# overlap is real. No RAM image or expected numeric result is generated.
words = set()
for r in range(16):
    for g in range(32):
        for j in range(8):
            w = 272*r+8*g+j
            assert (w%8,w//8) == (j,34*r+g)
            words.add(w)
        scale_word = 272*r+256+g//2
        assert scale_word//8 == 34*r+32+g//16
        assert scale_word%8 == (g//2)%8
        words.add(scale_word)
checks['A16_dense4352_words'] = words == set(range(4352))
checks['PS128_words_disjoint_and_fit'] = not words.intersection(range(4352,4480)) and 4479//8 < 656
checks['r15_norm_overlap512B'] = len(set(range(4080,4352)) & set(range(4224,5248)))*4 == 512
checks['descriptor_full_work'] = 384*4*32 == 49152 and 49152*4 == 196608
checks['first_TN8_work'] = 4*32 == 128 and 128*4 == 512
checks['A_sync_requests_first_TN8'] = 128*4*2 == 1024
checks['payload_increment108B'] = (1024-256+128-32)//8 == 108
checks['priority_counterexample_bad_values'] = 5248*128+31 == 671775 and 8*128 == 1024
assert all(checks.values()), checks

result = {'task': 'm004-a16-matrix16-next-interface-question-20261016',
 'scope': 'STATIC_ONLY: frozen identities, saved byte equality, integer layout. No oracle/RTL/EDA/profile.',
 'frozen_sources': sources, 'checks': checks,
 'manifest_identities': [identity(a/'source_manifest.json') for a in [AT368,AT367,AT372]],
 'reused_reference_binding': identity(OUT/'embedding_qkv_binding_20261015.json'),
 'reused_reference_products': products,
 'reference_parent_full_SHA_rehashed_this_run': False,
 'selected_windows': window_records,
 'workload': {'rows':16,'K':1024,'N':3072,'first_tile':0,'last_tile':383,
              'step_stripes':32,'step_row_group_retirements':128,
              'TN8_stripes':128,'TN8_row_group_retirements':512,
              'TN8_A_sync_requests':1024,'TN8_W_reads':128,'TN8_final_F32':128,
              'TN8_AW_W_B_each':16,'TN8_useful_bytes':512,'TN8_physical_bytes':1024,
              'parent_stripes':49152,'parent_row_group_retirements':196608,
              'parent_final_F32':49152,'parent_AW_W_B_each':6144},
 'new_gold': False, 'implementation_or_dynamic_result': 'NOT_RUN',
 'interactive_read_cost': 'UNKNOWN',
 'script': identity(Path(__file__)),
 'in_process_before_output': {'wall_seconds':time.monotonic()-START,
      'maxrss_KiB':resource.getrusage(resource.RUSAGE_SELF).ru_maxrss}}
(OUT/'a16_matrix16_interface_20261016.json').write_text(json.dumps(result,indent=2,ensure_ascii=False)+'\n')
print(json.dumps({'checks':len(checks),'frozen_files':len(sources),
 'current_matches':sum(x['equal_at_read'] for x in sources),
 'selected_windows':len(window_records),'all_checks':True}))
