#!/usr/bin/env python3
"""Measured same-build cost gate; no target-cycle-only performance claim."""
import argparse,hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[7];RUN=ROOT/'project/E015_m007_tanh_geglu8/experiment_results/runs/R001'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);p.add_argument('--pilot',required=True);p.add_argument('--attempt',required=True);p.add_argument('--target-count',type=int,required=True);p.add_argument('--seconds',type=int,required=True);a=p.parse_args();o=a.output;o.mkdir(parents=True,exist_ok=False)
 pilot=RUN/'attempts'/a.pilot;r=json.loads((pilot/'receipt.json').read_text());m=json.loads((pilot/'work/report.json').read_text());i=json.loads((pilot/'work/input_identity.json').read_text());assert r['status']=='EXIT_ZERO'and r['phase']=='rtl'and m['status']=='PASS'and m['main_input_count']>=4096
 events=m['actual_runtime_events'];begin=next(x for x in events if x['event']=='main_begin');end=next(x for x in events if x['event']=='main_end');assert end['seconds_since_xsim_launch']>begin['seconds_since_xsim_launch']
 build=Path(r['command'][r['command'].index('--build')+1]);assert build.is_relative_to(ROOT)and sha(build/'report.json')==m['build_manifest_sha256'];manifest=json.loads((build/'report.json').read_text())
 assert manifest['semantic_progress_schema']=='m007-tanh-consumed-v1'and r['schema']=='m007-tanh-g8-guard-v3'
 assert r['semantic_progress']['last_checked']==m['last_semantic_progress']['checked']and r['semantic_progress']['event_count']>0
 assert sha(pilot/'work/semantic_progress.jsonl')==m['semantic_progress_sha256']
 driver=Path(r['command'][1]);driver=driver if driver.is_absolute()else ROOT/driver;assert driver.is_relative_to(ROOT)and sha(driver)==manifest['driver_sha256']==m['driver_sha256']
 count=m['main_input_count'];bound=r['child_wall_s']*a.target_count/count*1.10+10;assert 120<a.seconds<=1200 and bound<=a.seconds
 fixture=RUN/'attempts/AT007_encoder0_real_local_reference/work';nodes=RUN/'attempts/AT018_original_tanh_native_node_reference/work';assert sha(fixture/'report.json')==i['fixture_report_sha256']and sha(nodes/'report.json')==i['node_report_sha256'];assert a.target_count==json.loads((fixture/'report.json').read_text())['count']
 spent=sum(json.loads(x.read_text()).get('child_wall_s',0)for x in(RUN/'attempts').glob('AT*/receipt.json')if json.loads(x.read_text()).get('phase')=='rtl');assert spent+a.seconds<=3000
 cmd=list(r['command']);cmd[cmd.index('--count')+1]=str(a.target_count);cmd[cmd.index('--output')+1]=str(RUN/'attempts'/a.attempt/'work')
 plan={'schema':'m007-tanh-same-build-cost-v2','phase':'rtl','pilot_attempt':a.pilot,'pilot_receipt_sha256':sha(pilot/'receipt.json'),'pilot_report_sha256':sha(pilot/'work/report.json'),'pilot_input_identity_sha256':sha(pilot/'work/input_identity.json'),'pilot_guard_sha256':r['guard_self_sha256_at_startup'],'pilot_semantic_progress_sha256':m['semantic_progress_sha256'],'semantic_progress_path':str(RUN/'attempts'/a.attempt/'work/semantic_progress.jsonl'),'driver_sha256':sha(driver),'pilot_count':count,'target_count':a.target_count,'measured_pilot_child_wall_s':r['child_wall_s'],'actual_main_host_interval_s':end['seconds_since_xsim_launch']-begin['seconds_since_xsim_launch'],'conservative_wall_bound_s':bound,'bound_formula':'whole_guarded_pilot_wall * target_count/pilot_count *1.10 +10s; cold startup/held/reset overhead retained conservatively','requested_timeout_s':a.seconds,'current_measured_rtl_spent_s':spent,'phase_budget_s':3000,'build_work':str(build),'build_manifest_sha256':m['build_manifest_sha256'],'fixture_report_sha256':i['fixture_report_sha256'],'node_report_sha256':i['node_report_sha256'],'command':cmd,'scope':'same compiled original-DAG TANH and checked-consume observer functional RTL only; selected DUT/TB/driver identities are bound by build manifest;42-node assertions retained; physical timing applicability remains separate'}
 (o/'cost_plan.json').write_text(json.dumps(plan,indent=2)+'\n');print('M007_TANH_SAME_BUILD_COST_GATE_PASS '+json.dumps({'pilot_count':count,'target_count':a.target_count,'measured_child_s':r['child_wall_s'],'bound_s':bound,'timeout_s':a.seconds}),flush=True)
if __name__=='__main__':main()
