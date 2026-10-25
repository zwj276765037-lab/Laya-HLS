#!/usr/bin/env python3
import argparse,datetime as dt,json,re,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];RUN=ROOT/'project/E016_m007_single_resource_parent/experiment_results/runs/R003';p=argparse.ArgumentParser();p.add_argument('attempt');p.add_argument('--session',type=int);a=p.parse_args();at=RUN/'attempts'/a.attempt;log=(at/'guard_rtl/driver.log').read_text(errors='replace');cmd=json.loads((at/'command_rtl.json').read_text());scope=cmd['scope'];target=2 if scope=='head2' else 16
ret=[int(x) for x in re.findall(r'MATRIX_PROGRESS parent_QKV_retired_s=(\d+)',log)];heads=[int(x) for x in re.findall(r'M007_PARENT_HEAD_END head=(\d+)',log)];begins=[int(x) for x in re.findall(r'M007_PARENT_HEAD_BEGIN head=(\d+)',log)];rope=[int(x) for x in re.findall(r'MATRIX_PROGRESS parent_RoPE_commits=(\d+)',log)];wo=[int(x) for x in re.findall(r'M007_PARENT_WO_BLOCK_END block=(\d+)',log)];checked=re.findall(r'M007_PARENT_CHECKED checked=(\d+) phase=([A-Za-z0-9_]+) cycle=(\d+)',log)
phase='QKV';progress={'completed':max(ret)+1 if ret else 0,'total':48,'unit':'真实QKV超块'}
if rope and not begins:phase='RoPE';progress={'completed':rope[-1],'total':2048,'unit':'真实RoPE提交'}
if begins:phase='HEAD';progress={'completed':len(heads),'total':target,'unit':'真实head退休'}
if 'parent_state=9 ' in log:phase='CONTEXT';progress=None
if wo or 'M007_PARENT_WO_BEGIN' in log:phase='WO';progress={'completed':wo[-1]+1 if wo else 0,'total':16,'unit':'真实WO超块'}
if 'M007_PARENT_FIRST_SUCCESS' in log:phase='PARENT_DONE';progress=None
receipt=at/'receipt_rtl.json';closed=json.loads(receipt.read_text()) if receipt.exists() else None
plan=json.loads((at/'guard_rtl/guard_plan.json').read_text());elapsed=(dt.datetime.now(dt.timezone.utc)-dt.datetime.fromisoformat(plan['at'])).total_seconds();result={'attempt':a.attempt,'scope':scope,'phase':phase,'progress':progress,'heads_retired':heads,'head_started':begins[-1] if begins else None,'last_checked':{'checked':int(checked[-1][0]),'phase':checked[-1][1],'cycle':int(checked[-1][2])} if checked else None,'wall_since_actual_guard_launch_s':elapsed,'closed_verdict':closed['verdict'] if closed else None,'raw_log':str((at/'guard_rtl/driver.log').relative_to(ROOT))};(RUN/'latest_actual_progress.json').write_text(json.dumps(result,indent=2)+'\n');state=json.loads((RUN/'engineering_state_current.json').read_text());old=state.get('observed_phase');state.update(stage=a.attempt+' actual '+phase+(' closed '+closed['verdict'] if closed else ' active'),observed_phase=phase,active_exec_session=None if closed else a.session,reported_at=dt.datetime.now(dt.timezone.utc).isoformat(),actual_progress_evidence=str((RUN/'latest_actual_progress.json').relative_to(ROOT)))
if progress:state['progress']=progress
else:state.pop('progress',None)
state.update(json.loads((RUN/'budget_ledger.json').read_text()));(RUN/'engineering_state_current.json').write_text(json.dumps(state,indent=2)+'\n');keys=['execution_state','current_task','stage','blocker','next_step','runtime_id','thread_id']+(['progress'] if progress else []);report={k:state[k] for k in keys};(RUN/'console_report_current.json').write_text(json.dumps(report,indent=2)+'\n')
if old!=phase:subprocess.run(["python3","/home/zwj/.codex/skills/research-agent/scripts/console.py","report","--root",str(ROOT),"--agent","A010","--input",str(RUN/'console_report_current.json')],check=True,stdout=subprocess.DEVNULL)
print(json.dumps(result,ensure_ascii=False))
