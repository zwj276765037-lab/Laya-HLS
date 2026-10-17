"""Read-only revision20 closeout evidence audit. No EDA or new oracle."""
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
RUN = ROOT / 'project/E004_full_accelerator_integration/experiment_results/runs/R001'
BASE = RUN / 'attempts'
AT = {n: next(BASE.glob(f'AT{n}_*')) for n in range(343, 352)}
checks, identities, guards = [], [], []
sums = {'static': Decimal(0), 'rtl': Decimal(0)}
policies = 0
file_counts = {'frozen': 0, 'fixture': 0}

def check(name, value):
    checks.append({'name': name, 'pass': bool(value)})

def read(path, expected=None):
    data = path.read_bytes()
    digest = hashlib.sha256(data).hexdigest()
    identities.append({'path': str(path.relative_to(ROOT)), 'sha256': digest, 'bytes': len(data)})
    if expected is not None:
        check('sha:' + str(path.relative_to(ROOT)), digest == expected)
    return data

ledger = json.loads(read(RUN / 'reports/SM004_rev20_guard_ledger_AT326_AT351_20261016.json'))
increment = json.loads(read(RUN / 'reports/SM004_rev20_AT344_AT351_incremental_identity_20261016.json'))
prior = json.loads(read(Path(__file__).with_name('source_norm_owner_rev20_at343_review_20261016.json')))
check('prior_AT343_verified', prior['check_count'] == 434 and not prior['failures'])
read(AT[343] / 'source_manifest.json', ledger['production_source_manifest_sha256'])
check('same_manifest_binding', increment['production_source_manifest_sha256'] == ledger['production_source_manifest_sha256'])
prior_sums = {'static': Decimal(0), 'rtl': Decimal(0)}
for entry in ledger['guards']:
    at = BASE / entry['attempt']
    n = int(at.name[2:5])
    folder = at / entry['guard']
    result = json.loads(read(folder / 'guard_result.json'), parse_float=Decimal)
    plan = json.loads(read(folder / 'guard_plan.json'))
    policy = json.loads(read(folder / 'policy_checks.json'))
    kind = entry['kind']
    check(f'{at.name}:{folder.name}:receipt', str(result['elapsed_seconds']) == entry['elapsed_seconds'] and result['child_exit_code'] == entry['child_exit_code'] and result['trigger'] == entry['trigger'])
    check(f'{at.name}:{folder.name}:memory', result['minimum_mem_available_kb'] > 192 * 1024**2 and result['peak_owned_rss_kb'] <= plan['maximum_owned_rss_kb'])
    check(f'{at.name}:{folder.name}:policy_count', len(policy) == entry['policy_samples'])
    for i, sample in enumerate(policy):
        check(f'{at.name}:{folder.name}:policy:{i}', sample['matches'] and sample['affinity'] == [0, 1, 2, 3] and sample['nice'] == 19 and sample['ionice'] == 'idle' and sample['ionice_exit'] == 0)
    policies += len(policy)
    sums[kind] += result['elapsed_seconds']
    if n <= 343:
        prior_sums[kind] += result['elapsed_seconds']
    else:
        log = read(folder / 'driver.log').decode()
        outcome = entry['scope_outcome']
        if outcome.startswith('FAIL_TB'):
            check(f'AT{n}:{folder.name}:fatal_preserved', 'Fatal:' in log and result['child_exit_code'] == 0)
        elif n == 351:
            check('AT351_cost_stop_no_snapshot', result['child_exit_code'] == -9 and result['trigger'] == 'timeout' and plan['maximum_seconds'] == 80 and 'Built simulation snapshot rev20_local_reject_recovery_sim' not in log and not list(at.glob('guard_rtl*')))
        else:
            check(f'AT{n}:{folder.name}:clean', result['child_exit_code'] == 0 and result['trigger'] is None and not re.search(r'^(Fatal:|ERROR:)', log, re.M))
        guards.append(entry)
check('49guards_356policies', len(ledger['guards']) == ledger['guard_count'] == 49 and policies == ledger['policy_samples'] == 356)
for kind in sums:
    check(kind + ':AT343_checkpoint', prior_sums[kind] == Decimal(prior['totals'][kind]) == Decimal(ledger['at343_controller_accepted_' + kind + '_seconds']))
    check(kind + ':final_total', sums[kind] == Decimal(ledger[kind + '_seconds']))
    check(kind + ':remaining', Decimal(ledger[kind + '_limit_seconds']) - sums[kind] == Decimal(ledger[kind + '_remaining_seconds']))

for entry in increment['attempts']:
    at = BASE / entry['attempt']
    n = int(at.name[2:5])
    for item in entry['files']:
        path = at / item['path']
        data = read(path, item['sha256'])
        check(f'AT{n}:bytes:{path.name}', len(data) == item['bytes'])
        key = 'fixture' if path.parent.name == 'fixture' else 'frozen'
        file_counts[key] += 1
        if key == 'fixture':
            check(f'AT{n}:fixture_lineage:{path.name}', data == read(AT[343] / 'fixture' / path.name))
        if path.suffix == '.sh':
            script = data.decode()
            check(f'AT{n}:TB_only_compile', 'xvlog' in script and not re.search(r'frozen/(laya_source_norm_service_v1|laya_lnq_bank_service_v1|laya_qkv_scratch_row_v1|laya_qkv_s128_request_v1)\.sv', script))
    for folder in at.glob('guard_rtl*'):
        plan = json.loads((folder / 'guard_plan.json').read_text())
        check(f'AT{n}:{folder.name}:actual_fixture', 'FIXTURE=../fixture' in plan['command'] and Path(plan['cwd']) == at / 'work')

def text(n, name):
    return (AT[n] / 'frozen' / name).read_text()

expected_markers = [(344, 'guard_rtl_source', 'STAGE_ERROR_RECOVERY_PASS case=SOURCE_LATE_RRESP row0_norm=1024 B=64'), (344, 'guard_rtl_lastb', 'STAGE_ERROR_RECOVERY_PASS case=     LAST_B_FAULT row0_norm=1024 B=64'), (345, 'guard_rtl_bus', 'STAGED_LN_BUS_PAGE_PASS norm=1024 B=64 sourceR=64 gammaR=256 sourceAR=2'), (346, 'guard_rtl_gamma', 'STAGE_ERROR_RECOVERY_PASS case=  GAMMA_NONFINITE row0_norm=1024 B=64'), (349, 'guard_rtl', 'STAGE_REJECT_RECOVERY_PASS norm=1024 B=64 sourceR=64 gammaR=256'), (350, 'guard_rtl', 'STAGE_RESET_RECOVERY_PASS norm=1024 B=64 sourceR=64 gammaR=256')]
for n, guard, marker in expected_markers:
    log = (AT[n] / guard / 'driver.log').read_text()
    check(f'AT{n}:{guard}:unique_final_marker', log.count(marker) == 1)
error = text(344, 'laya_source_norm_stage_error_tb.sv')
check('real_store_window_counts', all(x in error for x in ['source_r_count!=1024', 'b_count!=64', 'norm_total!=16384', "dut.stage_discarded_rows!=8'd15", 'norm_written!=0']))
check('independent_release_peer_boundary', '.stage_release_fire(release_valid)' in error and 'bank_link.prep_abort_valid=release_valid' in error and 'cmd_state0_epoch=2;' in error)
check('no_reset_error_recovery', error.count('rst_n=1;') == 1 and error.count('rst_n=0') == 1 and 'norm_mem[i]!==norm_gold[i]' in error)
bus = text(345, 'laya_source_norm_stage_bus_tb.sv')
check('bus_page_stalls_actual', all(x in bus for x in ["64'h20000fc0", 'source_ar_count!=2', 'STAGED_LN_AR_HOLD', 'STAGED_LN_AW_HOLD', 'STAGED_LN_W_HOLD', 'STAGED_LN_EARLY_NORM_BEFORE_B']))
gamma = text(346, 'laya_source_norm_stage_error_tb.sv')
check('gamma_nonfinite_not_bus_error', "gamma[0]=32'h7fc00000" in gamma and 'STAGE_GAMMA_ABORT_NOT_DRAINED' in gamma and 'gamma[0]=gamma_backup' in gamma)
reject = text(349, 'laya_source_norm_stage_reject_tb.sv')
assertion = reject.split('if(!stage_result_valid ||', 1)[1].split('$fatal(1,"STAGE_REJECT_CHECK', 1)[0]
check('reject_actual_Check_fields', all(x in assertion for x in ['done_op', 'done_check_status', 'done_detail', 'done_bad64', 'done_phase', 'done_id']) and 'done_bad_element' not in assertion and 'result_row' not in assertion)
check('reject_hold_only_after_three_cycles', 'repeat(3)@(negedge clk);' in reject and 'done_check_status!=16\'d7' in reject and 'done_detail!=32\'h0710_0005' in reject)
check('reject_zero_side_effects_and_recovery', 'STAGE_REJECT_SIDE_EFFECT' in reject and 'dut.bank_service.staged_ln_cmd_valid' in reject and "cmd_dst_base[2]=64'h10000000;" in reject and 'norm_mem[i]!==norm_gold[i]' in reject)
reset = text(350, 'laya_source_norm_stage_reset_tb.sv')
check('real_prep_reset_510_not_LN', all(x in reset for x in ['gamma_r_count<8', '!bank_link.prep_active', 'norm_total!=0', 'repeat(510)@(negedge clk);', 'gamma_active=0;gamma_left=0;gamma_beat=0;', 'STAGE_RESET_STALE_VISIBLE']))
report = {'through': 'AT351', 'check_count': len(checks), 'checks': checks, 'failures': [x for x in checks if not x['pass']], 'identities': identities, 'incremental_file_counts': file_counts, 'new_guards': guards, 'guard_count': len(ledger['guards']), 'policy_samples': policies, 'totals': {k: str(v) for k, v in sums.items()}, 'remaining': {k: ledger[k + '_remaining_seconds'] for k in sums}, 'scope': 'AT343 unchanged production normal LN128 and parent row0 retained; AT344-350 independent stage scoped errors/bus/prep-reset accepted; AT351 no snapshot/RTL.', 'limitations': ['AT349 omits bad_element/row assertions; status/detail checked at three-cycle endpoint, not all fields each cycle.', 'Independent explicit release+prep-abort and epoch2 recovery are not parent tensor_release or e/e+1/e+2 lifecycle tests.', 'AT344 last-B count64 includes final error response; only first63 B are OKAY, successful row coverage remains zero.', 'Gamma load_done bus fault, store-vs-numeric priority, pending/rsp or last-B legacy handoff, LN/replay inflight reset, parent128 and AT330 third command remain open.'], 'host_complete_cumulative': 'UNKNOWN', 'controller_policy': {'affinity': sorted(os.sched_getaffinity(0)), 'nice': os.getpriority(os.PRIO_PROCESS, 0), 'ionice': subprocess.check_output(['ionice', '-p', str(os.getpid())], text=True).strip()}}
Path(__file__).with_name('source_norm_owner_rev20_at351_review_20261016.json').write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n')
print(json.dumps({k: report[k] for k in ['check_count', 'failures', 'incremental_file_counts', 'guard_count', 'policy_samples', 'totals', 'remaining']}, ensure_ascii=False))
raise SystemExit(bool(report['failures']))
