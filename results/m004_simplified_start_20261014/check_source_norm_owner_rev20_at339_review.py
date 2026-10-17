"""Bounded, read-only audit of AT332-339; no EDA or reference evaluation."""
import hashlib
import json
import os
import re
import resource
import subprocess
from decimal import Decimal
from pathlib import Path

resource.setrlimit(resource.RLIMIT_AS, (1024**3, 1024**3))
ROOT = Path(__file__).resolve().parents[2]
BASE = ROOT / 'project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts'
ATT = {n: next(BASE.glob(f'AT{n}_*')) for n in range(331, 340)}
checks, identities, guards = [], [], []
counts = {'frozen': 0, 'fixture': 0, 'probe': 0, 'policy_samples': 0}
sums = {'static': Decimal(0), 'rtl': Decimal(0)}

def check(name, value):
    checks.append({'name': name, 'pass': bool(value)})

def read(path, expected=None):
    data = path.read_bytes()
    digest = hashlib.sha256(data).hexdigest()
    identities.append({'path': str(path.relative_to(ROOT)), 'sha256': digest, 'bytes': len(data)})
    if expected is not None:
        check('sha:' + str(path.relative_to(ROOT)), digest == expected)
    return data

prior = json.loads(read(Path(__file__).with_name('source_norm_owner_rev20_at331_review_20261016.json')))
check('prior_audit_passed', prior['check_count'] == 1878 and not prior['failures'])
for n in range(332, 340):
    at = ATT[n]
    manifest = json.loads(read(at / 'source_manifest.json'))
    for entry in manifest.get('files', []):
        path = at / (entry.get('path') or 'frozen/' + entry['name'])
        data = read(path, entry['sha256'])
        if 'bytes' in entry:
            check(f'AT{n}:size:{path.name}', len(data) == entry['bytes'])
        counts['fixture' if path.parent.name == 'fixture' else 'frozen'] += 1
    if 'tcl_sha256' in manifest:
        tcl = read(at / 'probe.tcl', manifest['tcl_sha256']).decode()
        check(f'AT{n}:read_only_probe', not re.search(r'\b(force|restart|add_force|remove_forces)\b', tcl) and 'run 160 us' in tcl)
        check(f'AT{n}:base_snapshot', manifest['snapshot'] == 'AT336/rev20_norm_store_parent_sim')
        counts['probe'] += 1
    for folder in sorted(at.glob('guard_*')):
        kind = folder.name.removeprefix('guard_')
        result = json.loads(read(folder / 'guard_result.json'), parse_float=Decimal)
        plan = json.loads(read(folder / 'guard_plan.json'))
        policy = json.loads(read(folder / 'policy_checks.json'))
        log = read(folder / 'driver.log').decode()
        expected = (1, None) if n == 333 else (-9, 'timeout') if n == 336 and kind == 'rtl' else (0, None)
        check(f'AT{n}:{kind}:terminal', (result['child_exit_code'], result['trigger']) == expected)
        check(f'AT{n}:{kind}:memory', result['minimum_mem_available_kb'] > 192 * 1024**2 and result['peak_owned_rss_kb'] <= plan['maximum_owned_rss_kb'])
        check(f'AT{n}:{kind}:plan', plan['selected_cpu_ids'] == [0, 1, 2, 3] and plan['maximum_seconds'] <= (600 if kind == 'static' else 120))
        check(f'AT{n}:{kind}:log', bool(re.search(r'^ERROR:', log, re.M)) if n == 333 else not re.search(r'^(Fatal:|ERROR:)', log, re.M))
        for i, sample in enumerate(policy):
            check(f'AT{n}:{kind}:policy:{i}', sample['matches'] and sample['affinity'] == [0, 1, 2, 3] and sample['nice'] == 19 and sample['ionice'] == 'idle' and sample['ionice_exit'] == 0)
        counts['policy_samples'] += len(policy)
        sums[kind] += result['elapsed_seconds']
        guards.append({'attempt': at.name, 'guard': folder.name, 'seconds': str(result['elapsed_seconds']), 'child_exit_code': result['child_exit_code'], 'trigger': result['trigger'], 'policy_samples': len(policy)})

def source(n, name):
    return (ATT[n] / 'frozen' / name).read_text()

upper = source(339, 'laya_source_norm_service_v1.sv')
old_upper = source(336, 'laya_source_norm_service_v1.sv')
wrapper = source(336, 'laya_qkv_scratch_row_v1.sv')
sequencer = source(336, 'laya_qkv_s128_request_v1.sv')
tb = source(336, 'laya_staged_ln128_pilot_tb.sv')
check('AT339_only_flush_done_connection_change', upper.replace('    .flush_done(writer_flush_done),\n', '', 1) == old_upper and upper.count('.flush_done(writer_flush_done)') == 1)
check('wrapper_old_input_fsm_and_holding_removed', not re.search(r'\b(IN_BEGIN|IN_LOAD|IN_WAIT|IN_COMMIT|IN_ERROR|input_hold|input_hold_valid)\b', wrapper))
check('source_prep_owner_in_upper', all(x in upper for x in ['stage_prep_state==SP_LOAD', 'stage_prep_state==SP_COMMIT', 'stage_prep_hold', "stage_prep_words==11'd1024", 'stage_prep_load_active']))
check('staged_norm_uses_upper_fsm', 'state <= active_staged_ln ? STAGE_STORE : SEG_PREP;' in wrapper and 'STAGE_STORE:if(stage_store_done_valid)' in wrapper and 'stage_store_start(state==Q_WAIT && core_row_valid' in wrapper)
check('upper_norm_debt_and_release', all(x in upper for x in ['writer_flush_done && writer_debt_zero', 'SS_UNFLUSH:', "writer_b_count!=32'd64", '!stage_store_read_pending &&', 'stage_store_release_ready)']))
check('remaining_parent_control_explicit', all(x in sequencer for x in ['S_SEND:if(row_cmd_ready)', 'S_ROW:if(row_done_valid)', 'S_STAGE_READY:', 'drain_store_window']) and 'IN_CORE_CMD:' in wrapper and 'Q_DONE: if (core_done_valid)' in wrapper and 'stage_row_done_fire' in upper)
check('one_real_bank_in_upper', len(re.findall(r'laya_lnq_bank_service_v1\s+\w+\s*\(', upper)) == 1)
for name in ['laya_lnq_bank_service_v1.sv', 'laya_lnq_wi_gqdown_row_v1.sv', 'laya_qkv_s128_request_v1.sv', 'laya_lnq_row_v1.sv', 't4_w_reader_port_v1.sv', 't4_aux_bias_reader_v1.sv', 'tm1tn8_axi512_writer.sv']:
    check('unchanged_dependency:' + name, read(ATT[336] / 'frozen' / name) == read(ATT[331] / 'frozen' / name))
check('same_parent_checker', tb == source(334, 'laya_staged_ln128_pilot_tb.sv') == source(331, 'laya_staged_ln128_pilot_tb.sv'))
check('checker_real_request_and_prefix', all(x in tb for x in ['cmd_valid=1', "dut.retired_rows==8'd1", 'source_r_count!=64', 'gamma_r_count!=256', 'norm_total!=1024', 'norm_mem[i]!==norm_gold[i]', '$finish;']))
check('checker_real_W_gold', 'm_axi_wdata[2][lane*32+:32]!==norm_gold' in tb)
marker = 'STAGED_LN_ROW0_PREFIX_PASS norm=1024 B=64 sourceR=64 gammaR=256'
for n in [334, 339]:
    log = (ATT[n] / 'guard_rtl/driver.log').read_text()
    check(f'AT{n}:prefix_terminal', log.count(marker) == 1 and '$finish called at time : 153810 ns' in log)
    compile_log = (ATT[n] / 'guard_static/driver.log').read_text()
    check(f'AT{n}:real_parent_elaborated', all(x in compile_log for x in ['Compiling module work.laya_qkv_s128_request_v1', 'Compiling module work.laya_lnq_wi_gqdown_row_engine_v1', 'Compiling module work.laya_source_norm_service_v1']))
check('AT336_no_success_marker', marker not in (ATT[336] / 'guard_rtl/driver.log').read_text())
probe1 = (ATT[337] / 'guard_rtl/driver.log').read_text()
probe2 = (ATT[338] / 'guard_rtl/driver.log').read_text()
check('probe_stall_at_flush_no_debt', all(x in probe1 for x in ['PROBE writer_flush_done=X', 'PROBE writer_debt_zero=1', 'PROBE stage_store_state=4', 'PROBE stage_store_ok_b=64', 'PROBE stage_store_read_pending=0']))
check('probe_writer_completed_flush', '/writer/flush_reported=1' in probe2 and '/writer/flush_req=1' in probe2 and '/writer/held_valid=0' in probe2 and '/writer/tx_valid=0' in probe2)
plan339 = json.loads((ATT[339] / 'guard_static/guard_plan.json').read_text())
rtl339 = json.loads((ATT[339] / 'guard_rtl/guard_plan.json').read_text())
check('AT339_explicit_AT336_work_lineage', Path(plan339['cwd']) == ATT[336] / 'work' == Path(rtl339['cwd']) and str(ATT[336] / 'work') in plan339['command'])
check('AT339_incremental_recompile_and_elab', '"$bin/xvlog" --sv "$at/frozen/laya_source_norm_service_v1.sv"' in source(339, 'build_incremental.sh') and '"$bin/xelab" work.laya_staged_ln128_pilot_tb' in source(339, 'build_incremental.sh'))
full_build = source(336, 'build_parent_full.sh')
check('AT336_full_frozen_source_build', all(x in full_build for x in ['"$f"/*.vhd', '"$f"/*.v', '"$f"/*.sv', '"$bin/xelab" work.laya_staged_ln128_pilot_tb']))
for name in ['expected_aux_header.hex', 'model_identity.hex', 'raw_s128.hex', 'norm_s128.hex', 'gamma.hex']:
    check('actual_fixture_lineage:' + name, read(ATT[336] / 'fixture' / name) == read(ATT[331] / 'fixture' / name) == read(ATT[334] / 'fixture' / name))
check('AT339_actual_fixture_binding', 'FIXTURE=../fixture' in rtl339['command'])
totals = {k: Decimal(prior['totals'][k]) + sums[k] for k in sums}
check('reported_static_total', totals['static'] == Decimal('1183.5299725364893745'))
check('reported_rtl_total', totals['rtl'] == Decimal('589.942395463585853'))
remaining = {k: Decimal(1800 if k == 'static' else 3600) - totals[k] for k in sums}
report = {'through': 'AT339', 'checks': checks, 'check_count': len(checks), 'failures': [x for x in checks if not x['pass']], 'identities': identities, 'increment_counts': counts, 'new_guards': guards, 'totals': {k: str(v) for k, v in totals.items()}, 'remaining': {k: str(v) for k, v in remaining.items()}, 'static_after_400s_reserve': str(remaining['static'] - 400), 'cumulative_guard_count': len(prior['guards']) + len(guards), 'cumulative_policy_samples': prior['policy_samples'] + counts['policy_samples'], 'scope': 'AT334 source-prep row0 and AT339 source+norm row0 only; staged request loop/error barrier/descriptor+Check ownership remain in parent; independent stage and real16/LN128 NOT_RUN', 'host_complete_cumulative': 'UNKNOWN', 'controller_policy': {'affinity': sorted(os.sched_getaffinity(0)), 'nice': os.getpriority(os.PRIO_PROCESS, 0), 'ionice': subprocess.check_output(['ionice', '-p', str(os.getpid())], text=True).strip()}}
Path(__file__).with_name('source_norm_owner_rev20_at339_review_20261016.json').write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n')
print(json.dumps({k: report[k] for k in ['check_count', 'failures', 'increment_counts', 'totals', 'remaining', 'static_after_400s_reserve', 'cumulative_guard_count', 'cumulative_policy_samples']}, ensure_ascii=False))
raise SystemExit(bool(report['failures']))
