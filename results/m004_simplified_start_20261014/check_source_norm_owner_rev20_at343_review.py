"""Read-only bounded AT340-343 evidence audit; no EDA or numerical oracle."""
import hashlib
import json
import os
import re
import resource
import subprocess
from datetime import datetime
from decimal import Decimal
from pathlib import Path

resource.setrlimit(resource.RLIMIT_AS, (1024**3, 1024**3))
ROOT = Path(__file__).resolve().parents[2]
BASE = ROOT / 'project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts'
ATT = {n: next(BASE.glob(f'AT{n}_*')) for n in [336, 340, 341, 342, 343]}
checks, identities, guards, observations = [], [], [], {}
counts = {'early_frozen_sha_entries': 0, 'final_frozen': 0, 'fixture_entries': 0, 'policy_samples': 0}
sums = {'static': Decimal(0), 'rtl': Decimal(0)}
receipts, plans = {}, {}

def check(name, value):
    checks.append({'name': name, 'pass': bool(value)})

def read(path, expected=None):
    data = path.read_bytes()
    digest = hashlib.sha256(data).hexdigest()
    identities.append({'path': str(path.relative_to(ROOT)), 'sha256': digest, 'bytes': len(data)})
    if expected is not None:
        check('sha:' + str(path.relative_to(ROOT)), digest == expected)
    return data

prior = json.loads(read(Path(__file__).with_name('source_norm_owner_rev20_at339_review_20261016.json')))
check('prior_audit_passed', prior['check_count'] == 986 and not prior['failures'])
for n in range(340, 344):
    at = ATT[n]
    if n < 343:
        for line in read(at / 'source_sha256.txt').decode().splitlines():
            digest, filename = line.split(None, 1)
            path = Path(filename.strip())
            check(f'AT{n}:frozen_location:{path.name}', path.parent == at / 'frozen')
            read(path, digest)
            counts['early_frozen_sha_entries'] += 1
        for script in (at / 'frozen').glob('build_*.sh'):
            read(script)
    else:
        manifest = json.loads(read(at / 'source_manifest.json'))
        for entry in manifest['files'] + manifest['runtime_fixture']:
            data = read(at / entry['path'], entry['sha256'])
            check('bytes:' + entry['path'], len(data) == entry['bytes'])
            counts['fixture_entries' if entry['path'].startswith('fixture/') else 'final_frozen'] += 1
    if n == 342:
        for line in read(at / 'fixture_sha256.txt').decode().splitlines():
            digest, filename = line.split(None, 1)
            read(Path(filename.strip()), digest)
            counts['fixture_entries'] += 1
    for folder in sorted(at.glob('guard_*')):
        kind = 'static' if folder.name == 'guard_static' else 'rtl'
        result = json.loads(read(folder / 'guard_result.json'), parse_float=Decimal)
        plan = json.loads(read(folder / 'guard_plan.json'))
        policy = json.loads(read(folder / 'policy_checks.json'))
        log = read(folder / 'driver.log').decode()
        key = (n, folder.name)
        receipts[key], plans[key] = result, plan
        check(f'AT{n}:{folder.name}:terminal', result['child_exit_code'] == (1 if n == 340 else 0) and result['trigger'] is None)
        check(f'AT{n}:{folder.name}:memory', result['minimum_mem_available_kb'] > 192 * 1024**2 and result['peak_owned_rss_kb'] <= plan['maximum_owned_rss_kb'])
        cap = 600 if kind == 'static' else 1800 if 'full128' in folder.name else 120
        check(f'AT{n}:{folder.name}:plan', plan['selected_cpu_ids'] == [0, 1, 2, 3] and plan['maximum_seconds'] <= cap)
        check(f'AT{n}:{folder.name}:log', bool(re.search(r'^ERROR:', log, re.M)) if n == 340 else not re.search(r'^(Fatal:|ERROR:)', log, re.M))
        for i, sample in enumerate(policy):
            check(f'AT{n}:{folder.name}:policy:{i}', sample['matches'] and sample['affinity'] == [0, 1, 2, 3] and sample['nice'] == 19 and sample['ionice'] == 'idle' and sample['ionice_exit'] == 0)
        counts['policy_samples'] += len(policy)
        sums[kind] += result['elapsed_seconds']
        guards.append({'attempt': at.name, 'guard': folder.name, 'seconds': str(result['elapsed_seconds']), 'child_exit_code': result['child_exit_code'], 'trigger': result['trigger'], 'policy_samples': len(policy)})

def src(name):
    return (ATT[343] / 'frozen' / name).read_text()

upper = src('laya_source_norm_service_v1.sv')
lower = src('laya_lnq_bank_service_v1.sv')
wrapper = src('laya_qkv_scratch_row_v1.sv')
seq = src('laya_qkv_s128_request_v1.sv')
tb = src('laya_source_norm_stage_tb.sv')
parent_tb = src('laya_staged_ln128_pilot_tb.sv')
build = src('build_final.sh')
base_manifest = json.loads(read(ATT[336] / 'source_manifest.json'))
base_sha = {e['path']: e['sha256'] for e in base_manifest['files']}
same, changed, added = [], [], []
for entry in manifest['files']:
    path = entry['path']
    if path not in base_sha:
        added.append(path)
    elif entry['sha256'] == base_sha[path]:
        same.append(path)
    else:
        changed.append(path)
check('compiled_source_closure_changes', sorted(changed) == sorted('frozen/' + x for x in ['laya_qkv_s128_request_v1.sv', 'laya_qkv_scratch_row_v1.sv', 'laya_source_norm_service_v1.sv', 'laya_staged_ln128_pilot_tb.sv']))
check('compiled_source_closure_additions', sorted(added) == ['frozen/build_final.sh', 'frozen/laya_source_norm_stage_tb.sv'] and len(same) == 124)
for name in changed + ['frozen/laya_source_norm_stage_tb.sv']:
    check('recompiled:' + name, '$at/' + name in build)
check('two_real_snapshot_builds', 'work.laya_source_norm_stage_tb' in build and 'work.laya_staged_ln128_pilot_tb' in build and build.count('"$bin/xelab"') == 2 and '-d SYNTHESIS' not in build)
compile_log = (ATT[343] / 'guard_static/driver.log').read_text()
check('both_snapshot_success', all(x in compile_log for x in ['Built simulation snapshot rev20_final_independent_stage_sim', 'Built simulation snapshot rev20_final_parent_stage_sim']))
check('unchanged_real_lower_and_core', all('frozen/' + x in same for x in ['laya_lnq_bank_service_v1.sv', 'laya_lnq_wi_gqdown_row_v1.sv', 'laya_lnq_row_v1.sv', 't4_w_reader_port_v1.sv', 't4_aux_bias_reader_v1.sv', 'tm1tn8_axi512_writer.sv']))
for filename in ['expected_aux_header.hex', 'model_identity.hex', 'raw_s128.hex', 'norm_s128.hex', 'gamma.hex']:
    check('fixture_lineage:' + filename, read(ATT[343] / 'fixture' / filename) == read(ATT[342] / 'fixture' / filename) == read(ATT[336] / 'fixture' / filename))
for group in ['guard_rtl_16', 'guard_rtl_full128', 'guard_rtl_parent_row0']:
    plan = plans[(343, group)]
    check(group + ':actual_fixture', Path(plan['cwd']) == ATT[343] / 'work' and 'FIXTURE=../fixture' in plan['command'])
check('single_production_upper_in_independent_tb', len(re.findall(r'laya_source_norm_service_v1\s+\w+\s*\(', tb)) == 1 and 'laya_qkv_s128_request_v1 dut' not in tb)
check('single_real_lower_in_upper', len(re.findall(r'laya_lnq_bank_service_v1\s+\w+\s*\(', upper)) == 1)
check('no_force_or_norm_input', not re.search(r'\bforce\b|\brelease\s+dut', tb) and 'state0_rdata[32*lane+:32]=raw[' in tb and 'aux_rdata[32*lane+:32]=gamma[' in tb and not re.search(r'(state0_rdata|aux_rdata).*=[^;]*norm_gold', tb))
check('one_request_and_idle_external_clients', tb.count('cmd_valid=1;') == 1 and '.stage_input_start(cmd_valid)' in tb and '.stage_row_done_fire(1\'b0)' in tb and '.stage_store_start(1\'b0)' in tb)
check('lower_enforces_actual_state_and_tokens', all(x in lower for x in ['staged_ln_cmd_ready=staged_state==ST_IDLE', 'prepared_match && gamma_match && ln_cmd_ready', '!result_pending && !result_rsp_valid', 'prep_active && !prep_fault']))
check('upper_owns_loop_and_identity', all(x in upper for x in ['stage_base_id<=stage_input_id;', 'stage_epoch<=stage_input_epoch;', 'stage_model<=stage_input_model;', 'stage_loop_row<=stage_loop_row+1\'b1;', 'stage_loop_row==7\'d127', 'stage_drain_window', 'stage_source_dest_disjoint']))
check('parent_staged_branch_no_row_loop', 'S_ROW:if(q_staged_ln)begin' in seq and 'S_SEND' not in seq.split('S_ROW:if(q_staged_ln)begin', 1)[1].split('end else if(row_done_valid)', 1)[0] and 'drain_store_window' not in seq)
check('wrapper_staged_Check_proxy', 'STAGE_PREP:if(stage_input_done_valid && active_staged_ln)' in wrapper and 'out_bad64<=stage_done_bad64;' in wrapper and 'else state<=STAGE_HOLD;' in wrapper)
check('actual_parent_request_tb', 'laya_qkv_s128_request_v1 dut' in parent_tb and 'source_norm_service.stage_retired_rows' in parent_tb and 'STAGED_LN128_EARLY_COMPLETION' in parent_tb)
check('real_W_and_final_memory_checker', 'm_axi_wdata[2][lane*32+:32]!==norm_gold' in tb and 'for(int i=0;i<131072;i++)' in tb and 'norm_mem[i]!==norm_gold[i]' in tb)
check('full_terminal_guards', all(x in tb for x in ['dut.stage_retired_rows!=8\'d128', "norm_written!=='1", 'b_count!=8192', 'source_r_count!=8192', 'gamma_r_count!=256']))
specs = [('guard_rtl_16', 16, 'STAGED_LN_16_PREFIX_PASS norm=16384 B=1024 sourceR=1024 gammaR=256', '2267010'), ('guard_rtl_full128', 128, 'STAGED_LN128_REAL_PASS rows=128 norm=131072 B=8192 gammaR=256', '18045570'), ('guard_rtl_parent_row0', 1, 'STAGED_LN_ROW0_PREFIX_PASS norm=1024 B=64 sourceR=64 gammaR=256', '153820')]
for group, count, marker, end_ns in specs:
    log = (ATT[343] / group / 'driver.log').read_text()
    events = [tuple(map(int, x)) for x in re.findall(r'^STAGED_LN_ROW_RETIRED row=(\d+) B=(\d+) sourceR=(\d+) cycle=(\d+)', log, re.M)]
    check(group + ':unique_terminal', log.count(marker) == 1 and '$finish called at time : ' + end_ns + ' ns' in log)
    check(group + ':preceding_row_sequence', len(events) == count - 1 and all(r == i and b == (i + 1) * 64 and s == b for i, (r, b, s, cycle) in enumerate(events)))
    observations[group] = {'row_log_events': len(events), 'last_row_via_terminal_checks': count - 1, 'finish_ns': int(end_ns), 'marker': marker}
for n, pilot_name in [(342, 'guard_rtl'), (343, 'guard_rtl_16')]:
    pilot = receipts[(n, pilot_name)]
    full = receipts[(n, 'guard_rtl_full128')]
    forecast = pilot['elapsed_seconds'] * 20
    spent_before = Decimal(prior['totals']['rtl']) + sum((r['elapsed_seconds'] for (a, g), r in receipts.items() if g.startswith('guard_rtl') and datetime.fromisoformat(r['finished_at']) <= datetime.fromisoformat(pilot['finished_at'])), Decimal(0))
    check(f'AT{n}:automatic_cost_gate', forecast <= 1440 and Decimal(3600) - spent_before >= 1800 and datetime.fromisoformat(pilot['finished_at']) < datetime.fromisoformat(plans[(n, 'guard_rtl_full128')]['at']))
    observations[f'AT{n}_launch_gate'] = {'forecast_seconds': str(forecast), 'remaining_rtl_before_full': str(Decimal(3600) - spent_before)}
totals = {k: Decimal(prior['totals'][k]) + sums[k] for k in sums}
check('reported_static_total', totals['static'] == Decimal('1413.8123060390353384'))
check('reported_rtl_total', totals['rtl'] == Decimal('1213.266668045893288'))
report = {'through': 'AT343', 'checks': checks, 'check_count': len(checks), 'failures': [x for x in checks if not x['pass']], 'identities': identities, 'counts': counts, 'new_guards': guards, 'observations': observations, 'unchanged_closure_files': same, 'recompiled_changed_files': changed, 'totals': {k: str(v) for k, v in totals.items()}, 'remaining': {k: str(Decimal(1800 if k == 'static' else 3600) - totals[k]) for k in totals}, 'cumulative_guard_count': prior['cumulative_guard_count'] + len(guards), 'cumulative_policy_samples': prior['cumulative_policy_samples'] + counts['policy_samples'], 'scope': 'Final SHA independent production LN128 normal path and same-SHA real parent request row0; faults/backpressure/reset/recovery pending; full parent128 and model NOT_RUN', 'limitations': ['Independent TB absent request/RAW/FINAL flags are constants, not an observed publication interface; parent row0 checks real flags.', 'Retirement event logs omit last row because negedge terminal finishes before next posedge logging; final counter/coverage/B/memory assertions prove terminal row.', 'No per-stage monotonic wall-time profile; guard elapsed establishes cost gate.'], 'host_complete_cumulative': 'UNKNOWN', 'controller_policy': {'affinity': sorted(os.sched_getaffinity(0)), 'nice': os.getpriority(os.PRIO_PROCESS, 0), 'ionice': subprocess.check_output(['ionice', '-p', str(os.getpid())], text=True).strip()}}
Path(__file__).with_name('source_norm_owner_rev20_at343_review_20261016.json').write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n')
print(json.dumps({k: report[k] for k in ['check_count', 'failures', 'counts', 'totals', 'remaining', 'cumulative_guard_count', 'cumulative_policy_samples']}, ensure_ascii=False))
raise SystemExit(bool(report['failures']))
