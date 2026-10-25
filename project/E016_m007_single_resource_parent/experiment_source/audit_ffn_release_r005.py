#!/usr/bin/env python3
"""Reconcile current complete chain with immutable inputs and actual receipts."""
import argparse,hashlib,json,re
from decimal import Decimal
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--root',type=Path,required=True);p.add_argument('--full',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args();ROOT=a.root.resolve();R=ROOT/'project/E016_m007_single_resource_parent/experiment_results/runs/R005';full=a.full.resolve();checks=[];mutable=[]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def read(p):return json.loads(p.read_text())
def check(b,label):
 checks.append({'passed':bool(b),'label':label})
 assert b,label
ref=read(R/'attempts/AT009_merge_original128_reference/work/report.json');check(ref['status']=='PASS'and ref['coverage']==list(range(128))and ref['g_groups']==10496 and ref['g_codes']==335872 and ref['down_f32']==131072 and ref['arithmetic_recomputed_at_merge']is False,'original independent128row reference coverage and merge boundaries')
fixture=read(R/'fixtures/manifest.json')
for e in fixture['files']:
 check(sha(R/'fixtures'/e['frozen'])==e['sha256'],'immutable frozen fixture '+e['frozen']);check(sha(Path(e['original']))==e['sha256'],'original fixture unchanged '+e['frozen'])
fr=read(full/'receipt_rtl.json');check(fr['verdict']=='PASS'and fr['blocks']==0,'complete normal RTL receipt PASS')
fi=read(full/'fixture_identity.json');build=Path(fi['build']);check(sha(build/'source_manifest.json')==fi['build_manifest_sha256'],'exact current compiled build identity');check(fi['fixture_manifest_sha256']==sha(R/'fixtures/manifest.json'),'full original fixture identity')
bm=read(build/'source_manifest.json')
for e in bm['files']:check(sha(build/'frozen'/e['frozen'])==e['sha256'],'current frozen build '+e['frozen'])
for name in ['laya_m007_single_parent_v1.sv','laya_m007_control_workspace_joint_v1.sv','laya_m007_g_engine_v1.sv']:
 entry=next(e for e in bm['files']if e['frozen']==name);check(sha(Path(entry['source']))==entry['sha256'],'current production source unchanged '+name)
aud=read(build/'source_control_hierarchy_audit.json');check(aud['status']=='PASS'and aud['exact_control_bytes']==4038.875 and aud['added_control_bits']==20 and aud['new_numeric_payload_bytes']==128,'actual hierarchy/control and numeric holding')
checks_for_runs=['AT021_current_status_three_block_pilot','AT023_real_Wi_error_newgen_recovery','AT025_affected_legacy_QKV3_regression','AT026_current_sixteen_block_cost_pilot',full.name]
for name in checks_for_runs:
 t=R/'attempts'/name;r=read(t/'receipt_rtl.json');check(r['verdict']=='PASS','affected run PASS '+name);x=read(t/'fixture_identity.json');b=Path(x['build']);check(sha(b/'source_manifest.json')==x['build_manifest_sha256'],'run build unchanged '+name)
 for e in x['snapshot_files']:
  q=t/'work'/e['path'];h=sha(q)
  if h!=e['sha256']:
   check(q.name in ['xsim_script.tcl','xsimkernel.log'],'only simulator runtime config/log mutable '+name+' '+e['path']);mutable.append({'attempt':name,'path':e['path'],'before':e['sha256'],'after':h})
  else:check(True,'compiled binary stable '+name+' '+e['path'])
 log=(t/'guard_rtl/driver.log').read_text();check(not re.search(r'(?im)(?:^|\s)(?:FATAL_ERROR|FATAL|Fatal|ERROR)\s*[:\[]',log),'no ERROR/FATAL '+name)
 command=read(t/'command_rtl.json')
 if 'actual_orchestrator_sha256'in command:check(sha(t/'actual_orchestrator.py')==command['actual_orchestrator_sha256'],'actual orchestration archived '+name)
 plan=read(t/'guard_rtl/guard_plan.json');check(plan['selected_cpu_ids']==[0,1,2,3]and plan['maximum_owned_rss_kb']==8388608 and plan['minimum_mem_available_kb']==201326592 and plan['semantic_stall_seconds']==120,'actual runtime resource policy '+name)
 check(r['guard']['minimum_mem_available_kb']>201326592 and r['guard']['peak_owned_rss_kb']<8388608 and r['guard']['child_exit_code']==0 and r['guard']['trigger']is None,'observed runtime resources '+name)
log=(full/'guard_rtl/driver.log').read_text();m=re.search(r'M007_FFN_FULL_PASS Wi_values=(\d+) G_values=(\d+) G_nodes=(\d+) A1_groups=(\d+) Down_values=(\d+) cycles=(\d+) held_mid=(\d+) held_last=(\d+)',log);check(m is not None,'complete checker final marker');numbers=list(map(int,m.groups()));check(numbers[:5]==[671744,335872,3358720,10496,131072]and numbers[5]<=150016 and numbers[6]>=8 and numbers[7]>=17,'full independent numeric coverage and cycle/held caps')
wb=re.findall(r'M007_FFN_MATRIX_BLOCK phase=0 s=(\d+) cycle=(\d+) values=(\d+)',log);db=re.findall(r'M007_FFN_MATRIX_BLOCK phase=1 s=(\d+) cycle=(\d+) values=(\d+)',log);gb=re.findall(r'M007_FFN_G_BLOCK s=(\d+) cycle=(\d+) values=(\d+) nodes=(\d+)',log)
check([int(x[0])for x in wb]==list(range(82))and[int(x[0])for x in db]==list(range(16))and[int(x[0])for x in gb]==list(range(82)),'all actual native block sequences Wi82/G82/Down16')
services=re.findall(r'M007_FFN_G_SERVICE s=(\d+) ready=(\d+) eligible=(\d+) first_read=(\d+) first_output=(\d+) release=(\d+) service=(\d+) supply_wait=(-?\d+)',log);check(len(services)==82,'all actual G block eligibility/service records');first_lat=[];service=[]
for row in services:
 v=list(map(int,row));first_lat.append(v[4]-v[2]);service.append(v[6]);check(0<=v[3]-v[2]<=1 and v[4]-v[2]<=256 and v[6]<=768,'G actual service cap s='+str(v[0]))
qbegin=re.search(r'M007_FFN_QUANT_BEGIN phase=0 cycle=(\d+)',log);wbegin=re.search(r'M007_FFN_MATRIX_BEGIN phase=0 cycle=(\d+)',log);dbegin=re.search(r'M007_FFN_MATRIX_BEGIN phase=1 cycle=(\d+)',log)
metrics={'Wi_values':numbers[0],'G_values':numbers[1],'G_node_checks':numbers[2],'A1_groups':numbers[3],'Down_values':numbers[4],'TB_parent_command_to_held_and_retired_finish_cycles':numbers[5],'Down_held_middle_cycles':numbers[6],'Down_held_last_cycles':numbers[7],'maximum_G_first_output_from_eligible_cycles':max(first_lat),'maximum_G_eligible_to_release_cycles':max(service),'norm_quant_command_to_Wi_last_output_cycles':int(wb[-1][1])-int(qbegin[1]),'Wi_matrix_command_to_last_output_cycles':int(wb[-1][1])-int(wbegin[1]),'Down_matrix_command_to_last_output_cycles':int(db[-1][1])-int(dbegin[1]),'Down_drain_and_parent_retirement_are_also_checked_in_TB':True,'guarded_child_wall_s':fr['wall_s']}
check(metrics['norm_quant_command_to_Wi_last_output_cycles']<=92160,'Wi quant acceptance through last real output <=92160');check(metrics['Down_matrix_command_to_last_output_cycles']<=56576,'prequant Down command through last real output <=56576')
gate=read(R/'reports/full_cost_gate.json');check(gate['passed']and gate['cap_s']==3600 and gate['reserve_s']==300 and gate['estimate_s']<=3600,'original actual16 full launch cost gate');check(gate['build_manifest_sha256']==fi['build_manifest_sha256'],'same-build actual16 launch bound');check(sum(read(q).get('blocks')==0 for q in(R/'attempts').glob('*/receipt_rtl.json'))==1,'one complete RTL request attempt')
wall=read(full/'work/ffn_wall_events.json');begin=next(e['elapsed_s']for e in wall['events']if e['line'].startswith('M007_FFN_MATRIX_BEGIN phase=1 '));last=next(e['elapsed_s']for e in wall['events']if e['line'].startswith('M007_FFN_MATRIX_BLOCK phase=1 s=15 '));allowance=16*(2624/1024)*gate['maximum_observed_block_s']+gate['additional_Down_cold_first_block_allowance_s']+gate['additional_terminal_allowance_s'];metrics['actual_Down_command_to_last_output_wall_s']=last-begin;metrics['original_uninflated_Down_cold_work_terminal_allowance_s']=allowance;metrics['Down_posthoc_within_original_uninflated_allowance']=last-begin<=allowance
records=[];cost={k:Decimal(0)for k in ['reference','static','rtl','ooc']}
for q in sorted((R/'attempts').glob('*/receipt*.json')):
 x=read(q);cat=x.get('category',x.get('phase'));value=Decimal(str(x.get('wall_s',x.get('child_wall_s',0))));cost[cat]+=value;records.append({'path':str(q.relative_to(ROOT)),'sha256':sha(q),'category':cat,'wall_s_exact':str(value),'verdict':x.get('verdict',x.get('status'))})
check(all(cost[k]<=Decimal(str(v))for k,v in {'reference':180,'static':900,'rtl':6000,'ooc':0}.items()),'independent R005 exact budgets before this final audit charge')
old=read(ROOT/'project/E016_m007_single_resource_parent/experiment_results/runs/R003/current_version_evidence.json');check(sha(ROOT/old['full_attempt']/'receipt_rtl.json')==old['full_receipt_sha256'],'old e354 complete Attention receipt unchanged')
a.out.mkdir(parents=True,exist_ok=True);report={'schema':'m007-ffn-chain20-release-audit-v1','status':'PASS','scope':'Complete original Encoder0 FFN island from public norm_ff plus affected error/newgen and legacyQKV3, functional RTL only','checks':checks,'check_count':len(checks),'metrics':metrics,'full_attempt':str(full),'full_receipt_sha256':sha(full/'receipt_rtl.json'),'parent_sha256':aud['parent_sha256'],'build_manifest_sha256':fi['build_manifest_sha256'],'fixture_manifest_sha256':fi['fixture_manifest_sha256'],'exact_control_bytes':aud['exact_control_bytes'],'new_numeric_payload_bytes':128,'mutable_runtime_differences':mutable,'budget_before_current_audit_charge_s_exact':{k:str(v)for k,v in cost.items()},'receipts':records,'limits':['Error243bit tuple hold/retirement tested; injected Wi tuple numerical coordinates are not independently asserted','Unknown32bit G status preservation statically checked, no legal public producer of unknown G code','Integrated directed G hold/third-slot backpressure NOT_RUN: no public parent control','Residual/LN/complete Encoder/30layers, physical OOC/P&R/board remain separate later scope']}
(a.out/'release_audit.json').write_text(json.dumps(report,indent=2)+'\n');print('M007_FFN_RELEASE_AUDIT_PASS checks='+str(len(checks))+' metrics='+json.dumps(metrics))
