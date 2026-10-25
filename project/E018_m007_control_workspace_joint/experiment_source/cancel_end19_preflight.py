#!/usr/bin/env python3
import argparse,ast,difflib,hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
R2=ROOT/'project/E018_m007_control_workspace_joint/experiment_results/runs/R002'
R3=ROOT/'project/E018_m007_control_workspace_joint/experiment_results/runs/R003'
TB='project/E002_Laya_HLS/experiment/vivado/module_design/vector_and_ffn/tb/m007_cancel17_normal_tb.sv'
DRIVER='project/E002_Laya_HLS/experiment/vivado/module_design/vector_and_ffn/tb/m007_cancel17_normal_run.py'
GUARD=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/vector_and_ffn/tb/m007_cancel_end19_guard_v1.py'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def save(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=False)
old=R2/'attempts/AT002_normal_build/work';build=R2/'attempts/AT021_corrected_normal_tb_build/work';fixture=ROOT/'project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT058_g_original_product_fixture/work'
om=json.loads((old/'report.json').read_text());m=json.loads((build/'report.json').read_text())
assert m['status']=='BUILD_COMPLETE' and m['source_sha256'].keys()==om['source_sha256'].keys()
for name,digest in m['source_sha256'].items():
 assert sha(ROOT/name)==sha(build/'frozen'/name)==digest,'AT021/current mismatch '+name
 if name!=TB:assert digest==om['source_sha256'][name],'production mismatch '+name
for name,digest in m['snapshot'].items():assert sha(build/name)==digest,'AT021 snapshot mismatch '+name
before=(old/'frozen'/TB).read_text();after=(build/'frozen'/TB).read_text()
assert before.replace('slot_fp_debt||protocol_fault||needs_discard)$fatal(1,"FINAL_REAL_DEBT")','slot_fp_debt||protocol_fault||(needs_discard&&mode!=2))$fatal(1,"FINAL_REAL_DEBT")',1)==after
(a.output/'TB_only_diff.patch').write_text(''.join(difflib.unified_diff(before.splitlines(True),after.splitlines(True),fromfile='R002_AT002',tofile='R002_AT021_current')))
budget=json.loads((R2/'final_budget.json').read_text());frozen={x['attempt']:x['receipt_sha256'] for x in budget['receipts']}
for n,digest in frozen.items():assert sha(R2/'attempts'/n/'receipt.json')==digest,'R002 receipt changed '+n
nr=json.loads((R2/'attempts/AT018_full_original_normal/receipt.json').read_text());nm=json.loads((R2/'attempts/AT018_full_original_normal/work/report.json').read_text());fr=json.loads((R2/'attempts/AT020_full_terminal_cancel_priority/receipt.json').read_text())
assert nr['status']=='EXIT_ZERO' and nm['status']=='PASS' and nm['metrics']['checked']==335872 and nm['metrics']['node_checks']==3358720
assert fr['status']=='FAIL' and fr['semantic_progress']['last_checked']==335872
assert sha(ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/vector_and_ffn/rtl/laya_m007_g_engine_v1.sv')=='6b8b0114f64bdab6391ad7df251c0fd2fb3d31cfd1bde89305accd08eda8a106'
fi=json.loads((fixture/'report.json').read_text());assert fi['count']==335872 and sha(fixture/'geglu_vectors.hex')==fi['vectors_sha256']
ast.parse(GUARD.read_text());assert "runs/R003'" in GUARD.read_text() and "'rtl':300" in GUARD.read_text() and '60s RTL reserve required' in GUARD.read_text()
bound=nr['child_wall_s']*1.35+10;assert bound<=200 and fr['child_wall_s']<200 and 300-200>=60
out=R3/'attempts/AT002_corrected_full_terminal_cancel/work';cmd=['python3',DRIVER,'rtl','--groups','82','--mode','2','--count','335872','--build',str(build),'--fixture',str(fixture),'--output',str(out)]
protocol=ROOT/'project/E018_m007_control_workspace_joint/experiment_source/protocol_r003.md'
plan={'schema':'m007-cancel-end19-corrected-build-cost-v1','command':cmd,'requested_timeout_s':200,'required_RTL_reserve_s':60,'normal_child_wall_s':nr['child_wall_s'],'failed_prefixed_TB_child_wall_s':fr['child_wall_s'],'conservative_wall_bound_s':bound,'build_work':str(build),'build_manifest_sha256':sha(build/'report.json'),'driver_sha256':sha(ROOT/DRIVER),'fixture_report_sha256':sha(fixture/'report.json'),'fixture_vectors_sha256':fi['vectors_sha256'],'frozen_R002_receipt_sha256':frozen,'authority_files_sha256':{str(protocol.relative_to(ROOT)):sha(protocol)},'semantic_progress_path':str(out/'semantic_progress.jsonl')}
save(R3/'AT002_cost_plan.json',plan)
contract=ROOT/'mission/M007_完整Attention高性能主干与部署闭合/tasks/SM012.md';s=contract.read_text();start=s.index('### D-M007-SM012-CANCEL-END-19');end=s.index('### D-M007-SM012-FFN-CHAIN-20',start);(R3/'contract_excerpt.md').write_text(s[start:end])
record={'schema':'m007-cancel-end19-preflight-v1','status':'PASS','contract_sha256_at_check':sha(contract),'contract_excerpt_sha256':sha(R3/'contract_excerpt.md'),'R002_receipts_unchanged':len(frozen),'corrected_build':str(build.relative_to(ROOT)),'build_manifest_sha256':sha(build/'report.json'),'snapshot_files_checked':len(m['snapshot']),'selected_sources_checked':len(m['source_sha256']),'selected_source_sha256':m['source_sha256'],'only_TB_expression_changed':True,'production_unchanged':True,'normal_wall_s':nr['child_wall_s'],'failed_full_wall_s':fr['child_wall_s'],'conservative_bound_s':bound,'new_full_cap_s':200,'new_caps_s':{'reference':0,'static':120,'rtl':300,'ooc':0},'cost_plan_sha256':sha(R3/'AT002_cost_plan.json'),'R002_receipt_sha256':frozen,'R001_receipt_sha256':{str(p.relative_to(ROOT)):sha(p) for p in (ROOT/'project/E018_m007_control_workspace_joint/experiment_results/runs/R001/attempts').glob('AT*/receipt.json')}}
save(a.output/'report.json',record);print(json.dumps({k:record[k]for k in ['status','R002_receipts_unchanged','snapshot_files_checked','selected_sources_checked','only_TB_expression_changed','conservative_bound_s']}))
