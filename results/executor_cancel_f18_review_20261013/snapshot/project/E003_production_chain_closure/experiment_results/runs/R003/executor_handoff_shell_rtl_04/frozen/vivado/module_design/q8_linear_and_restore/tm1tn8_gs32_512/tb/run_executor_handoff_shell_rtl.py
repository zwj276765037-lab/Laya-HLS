#!/usr/bin/env python3
"""Bounded shell control FSM only; physical authority inputs are controlled."""
import argparse,json,shutil,subprocess,sys
from pathlib import Path
import run_executor_checkpoint_rtl as common
ROOT=common.ROOT;PROJECT=common.PROJECT;M=common.MODULE

def main():
    ap=argparse.ArgumentParser();ap.add_argument('--attempt',type=Path,required=True)
    ap.add_argument('--helper-attempt',type=Path,required=True);a=ap.parse_args()
    out=a.attempt.resolve();out.mkdir(exist_ok=False);helper=a.helper_attempt.resolve()
    receipt=json.loads((helper/'receipt.json').read_text())
    if receipt['status']!='PASS' or not any('FULL_CURRENT_EXECUTOR_SHELL_HELPER_PASS' in s for s in receipt['run']['markers']):
        raise RuntimeError('actual helper run required')
    launcher=common.launcher_state();(out/'launcher.json').write_text(json.dumps(launcher,indent=2)+'\n')
    if not launcher['pass']:raise RuntimeError('launcher rejected')
    frozen=out/'frozen';records=[]
    def freeze(p,rel):
        dst=frozen/rel;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,dst)
        records.append({'original':common.rec(p),'frozen':common.rec(dst)})
    files=[M/'rtl/laya_executor_handoff_layout_v1.sv',M/'rtl/laya_executor_handoff_shell_v1.sv',
        M/'tb/laya_executor_handoff_shell_tb_v1.sv',M/'tb/run_executor_handoff_shell.tcl',
        M/'tb/production_guard.py',M/'tb/run_executor_checkpoint_rtl.py',Path('tools/hls_guard_helpers.py'),
        Path(__file__).resolve().relative_to(ROOT),Path('tests/executor_handoff_shell_fixture.py')]
    for p in files:freeze(ROOT/p,p)
    for name in ['actual_helper_hold.bin','actual_helper_query.bin','helper_proof_stimulus.bin',
                 'actual_helper_import_ok.bin','actual_helper_abort.bin','control_2.bin','control_3.bin','control_4.bin','control_6.bin']:
        freeze(helper/'fixture'/name,Path('external/helper')/name)
    for name in ['input_manifest.json','receipt.json']:
        freeze(helper/name,Path('external/helper_run')/name)
    for name in ['executor_checkpoint_import_handshake_contract_20261013.md','executor_checkpoint_high_water_contract_20261012.md']:
        freeze(PROJECT/'results'/name,Path('external/contracts')/name)
    fixture=out/'fixture'
    oracle=[sys.executable,str(frozen/'tests/executor_handoff_shell_fixture.py'),
            '--helper',str(frozen/'external/helper'),'--output',str(fixture)]
    vivado=Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado')
    rtl=[str(vivado),'-mode','batch','-notrace','-log',str(out/'vivado.log'),'-journal',str(out/'vivado.jou'),
         '-source',str(frozen/M/'tb/run_executor_handoff_shell.tcl'),'-tclargs',str(out/'work'),str(frozen),str(fixture)]
    scope=('LHC1 single-pending control shell prototype: full bound HOLD/DRAIN/HELD, '
           'count 16 actual TB consumer pulses with proof bytes, IMPORT_PENDING without authority, '
           'offline actual C++ helper success IMPORT_OK and reservation-hole commit0 ABORT, '
           'literal return oracle, held/tail/import/grant stalls, same-edge cancel/base and '
           'active session/request revoke, persistent old owner, precommit no-reset same-request retry. '
           'Physical safety, predecessor completion, protections and query transport are controlled. '
           'No real hub/LPV/monitor/FIFO/action/F10, generated helper same-runtime, committed error '
           'close or accepted-request hardware rearm claim.')
    commands={'oracle':oracle,'rtl':rtl}
    manifest={'schema':'laya-executor-handoff-shell-rtl-input-v1','scope':scope,'files':records,
              'helper_attempt':str(helper),'helper_manifest':common.rec(helper/'input_manifest.json'),
              'helper_receipt':common.rec(helper/'receipt.json'),'launcher':common.rec(out/'launcher.json'),
              'tool':common.rec(vivado),'planned_commands':commands,'cycle_cap':6000}
    mp=out/'input_manifest.json';mp.write_text(json.dumps(manifest,indent=2)+'\n')
    result={'schema':'laya-executor-handoff-shell-rtl-receipt-v1','status':'RUNNING','scope':scope,'input_manifest':common.rec(mp)}
    for stage,cmd in commands.items():
        guarded=[sys.executable,str(frozen/M/'tb/production_guard.py'),'--out',str(out/('guard_'+stage)),
          '--cwd',str(frozen),'--rss-gib','8','--timeout-seconds','120','--semantic-stall-seconds','120','--',*cmd]
        p=subprocess.run(guarded);guard=json.loads((out/('guard_'+stage)/'guard_result.json').read_text())
        log=out/('guard_'+stage)/'driver.log';body=log.read_text()
        marker='FULL_CURRENT_EXECUTOR_HANDOFF_SHELL_'+('FIXTURE_PASS' if stage=='oracle' else 'RTL_PASS')
        passed=p.returncode==0 and guard['child_exit_code']==0 and guard['trigger'] is None and body.count(marker)==1
        result[stage]={'status':'PASS' if passed else 'FAIL','guard':guard,'runner_exit_code':p.returncode,
                      'driver_log':common.rec(log),'markers':[s for s in body.splitlines() if marker in s]}
        result['status']='PASS' if stage=='rtl' and passed else 'RUNNING' if passed else 'FAIL'
        result['fixture_files']=[common.rec(p) for p in sorted(fixture.rglob('*')) if p.is_file()]
        (out/'receipt.json').write_text(json.dumps(result,indent=2)+'\n')
        print('FULL_CURRENT_EXECUTOR_HANDOFF_SHELL_'+stage.upper()+'_'+('PASS' if passed else 'FAIL'),flush=True)
        if not passed:return 1
    return 0
if __name__=='__main__':raise SystemExit(main())
